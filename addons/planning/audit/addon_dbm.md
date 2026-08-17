# Audit: DBM-Core (Deadly Boss Mods, Ascension fork) — mechanisms conditional on encounter / character state

Independent read-only audit, from files only. Target: `F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns\DBM-Core` (Core 5.21, r5021, TOC `## Interface: 30300`, `## Notes: Deadly Boss Mods - heavily modified to suit Project Ascension raid fights.` — `DBM-Core.toc:1,9`) plus per-instance module `DBM-Party-BC` (read: `.toc`, `Hellfire_Ramp/Vazruden.lua`, `Hellfire_Ramp/Omor.lua`, `MagistersTerrace/Kael'thas.lua`, `MagistersTerrace/Delrissa.lua`, `CoT_BlackMorass/Temporus.lua`, `CoT_BlackMorass/PortalTimers.lua`, `Mythic_Champion.lua`, head of `localization.en.lua`).

Files loaded by Core (`DBM-Core.toc:15-28`): 8 localization files, `DBT-Template.xml`, `DBT.lua`, `DBM-Core.lua`, `DBM-Arrow.lua`, `DBM-RangeCheck.lua`, `DBM-BossHealth.lua`, `DBM-BossHealth.xml`. **`DBM-HelpFunctions.lua` is present in the folder but NOT listed in the TOC** — dead file; ignored below except one note.

Cite convention: `Core:NNN` = `DBM-Core\DBM-Core.lua:NNN`; `RC:NNN` = `DBM-RangeCheck.lua`; `BH:NNN` = `DBM-BossHealth.lua`; `DBT:NNN` = `DBT.lua`; `BC/<file>:NNN` = `DBM-Party-BC\<file>`.

Headline finding, stated up front so the rest reads as evidence: **DBM on this client has no boss-unit API at all.** No `boss1..boss5`, no `INSTANCE_ENCOUNTER_ENGAGE_UNIT`, no `IsEncounterInProgress`, no `PLAYER_REGEN_ENABLED` — grep of the whole Core folder for those tokens returns nothing (only `GetInstanceInfo` at `Core:2562`, used for difficulty). Engage/kill/HP detection is all built out of **`UnitGUID` scans over `target` + `raidN target` / `partyN target`**, **CLEU `UNIT_DIED`**, **monster chat messages**, and **`UnitAffectingCombat` on the group** — every one of which needs an authored creature ID or authored message string to bind to a specific boss.

---

## 1. ENCOUNTER START

Two entry points, both gated by an authored per-mod `combatInfo` record built by `RegisterCombat` (§4). Order is not "precedence" — they are independent triggers that all funnel into `DBM:StartCombat`, which is idempotent per mod (`Core:1867 if not checkEntry(inCombat, mod) then`).

### 1a. `PLAYER_REGEN_DISABLED` → target-list GUID scan (type `"combat"`)

- Registered at `Core:1385`. Handler `Core:1747-1784`.
- Gate 1: `if not combatInitialized then return end` (`Core:1748`) — set true 1.5 s after ADDON_LOADED (`Core:1402 DBM:Schedule(1.5, setCombatInitialized)`), so a reload mid-fight does not fire this path.
- Gate 2: `if combatInfo[GetRealZoneText()] or combatInfo[GetCurrentMapAreaID()] then` (`Core:1749`) — the zone must have at least one registered mod.
- `buildTargetList()` (`Core:1711-1721`): iterates `i = 0 .. max(GetNumRaidMembers(), GetNumPartyMembers())`, unit = `"target"` for i=0 else `"raid"..i.."target"` / `"party"..i.."target"`; reads `UnitGUID(id)`; keeps only creatures/vehicles: `bit.band(guid:sub(1, 5), 0x00F) == 3 or ... == 5` (`Core:1716`); parses `cId = tonumber(guid:sub(9, 12), 16)` (`Core:1717`) → `targetList[cId] = unitToken`.
- For each combatInfo entry with `v.type == "combat"` (`Core:1753`), `checkForPull(mob, v)` (`Core:1737-1745`): if the group is targeting that cId **and** `UnitAffectingCombat(uId)` → `DBM:StartCombat(combatInfo.mod, 0)`; if targeted but not yet in combat → `DBM:Schedule(3, scanForCombat, mod, mob)` (`Core:1743`) which re-checks once after 3 s and starts with delay 3 (`Core:1727-1735`, `DBM:StartCombat(mod, 3)`).
- Multi-mob: `v.multiMobPullDetection` (from `SetCreatureID` with >1 id, `Core:2477-2485`) — loops all ids and breaks on first hit (`Core:1754-1759`).
- **This is the mechanism DBM-Party-BC dungeon mods use almost exclusively**: `mod:RegisterCombat("combat")` (`BC/Hellfire_Ramp/Omor.lua:9`, `Vazruden.lua:7`, `Kael'thas.lua:7`, `Temporus.lua:7`; `Delrissa.lua:7 mod:RegisterCombat("combat", 24560)`).

### 1b. Monster chat messages (type `"yell"` / `"emote"` / `"say"`)

- `CHAT_MSG_MONSTER_YELL / _EMOTE / _SAY / CHAT_MSG_RAID_BOSS_EMOTE` registered `Core:1390-1393`; all route to `onMonsterMessage(type, msg)` (`Core:1789-1815`).
- Match: `if v.type == type and checkEntry(v.msgs, msg) then DBM:StartCombat(v.mod, 0)` (`Core:1793`) — **exact string equality** against authored `msgs` (`checkEntry` is `v == val`, `Core:184-191`).
- Used by raid mods, not the dungeon module: e.g. `DBM-Karazhan/Moroes.lua:7 mod:RegisterCombat("yell", L.DBM_MOROES_YELL_START)`, `DBM-BWL/Nefarian.lua:6`. Comment at `DBM-BWL/Razorgore.lua:7`: `--Will fail if msg find isn't used, msg match won't find yell since a line break is omitted` (an authored-string fragility acknowledged in-source).

### 1c. Sync from another client (`DBMv4-Pull`)

- `Core:1521-1531`: parses `delay\tmodName\trevision`; validates mod exists, sender's zone matches mod zones, revision ≥ `minSyncRevision`; then `DBM:StartCombat(mod, delay + lag, true)` where lag = `select(3, GetNetStats()) / 1000` (`Core:1524`). Ignored in `pvp` instances (`Core:1522`).

### 1d. Timer recovery on login/reload (`DBMv4-CombatInfo`)

- `PLAYER_ENTERING_WORLD` → if `#inCombat == 0`, `requestTimers` (`Core:2134-2137`), which asks the highest-revision connected raid member (`Core:2028-2039`) only if someone in the group is `UnitAffectingCombat` and alive (`Core:2123-2132`). `ReceiveCombatInfo` inserts the mod into `inCombat` with `combatInfo.pull = GetTime() - time + lag` (`Core:2041-2051`), accepted only from `requestedFrom` within 5 s.

### What `StartCombat` does (`Core:1866-1912`)

- Requires `mod.combatInfo` (`Core:1868`); vehicle hack `Core:1869`; inserts into `inCombat`; chat msg; pull stats by difficulty; `mod.combatInfo.pull = GetTime() - delay` (`Core:1883`); **schedules the wipe checker** `self:Schedule(mod.minCombatTime or 3, checkWipe)` (`Core:1884`); optional health frame; `mod:OnCombatStart(delay)` (`Core:1895`); broadcasts `DBMv4-Pull` unless synced (`Core:1897`); fires callback `"pull"`.

### Not present on this client

- No `boss1..boss5`, no `INSTANCE_ENCOUNTER_ENGAGE_UNIT`, no `UNIT_TARGET` handler, no CLEU-first-hit engage. `GetInstanceInfo` only for difficulty (`Core:2562`).

**REUSABLE MECHANISM (generic)**
- Group-target GUID scan (`Core:1711-1721`) — enumerating `target` + `raidN target`/`partyN target`, filtering creature/vehicle GUID types, parsing cId — is fully generic.
- `PLAYER_REGEN_DISABLED` + `UnitAffectingCombat(unitToken)` as the "a pull is happening" signal, plus the 3 s re-scan for "targeted but not yet in combat" (`Core:1743`).
- The `combatInitialized` 1.5 s post-load guard (`Core:1402,1748`) — a cheap protection against reload-in-combat false engages.
- Idempotent engage (`Core:1867`) and `pull = GetTime() - delay` back-dating (`Core:1883`).

**POSTURE NOT TO INHERIT (per-dungeon knowledge or product-specific)**
- Which cId(s) constitute "the boss" (`SetCreatureID`, `Core:2477`) — authored per mod.
- Engage-by-yell string tables (`RegisterCombat("yell", L.X)`) — authored, locale-bound, exact-match.
- The zone-keyed `combatInfo[zone]` index (`Core:3739-3742`) which requires the mod's TOC LoadZone list to be correct.
- `noCombatInVehicle` HACK (`Core:1869`), BigBrother hook, `FixCLEUOnCombatStart` — product-specific.

---

## 2. ENCOUNTER END

### 2a. Kill via CLEU `UNIT_DIED` / `UNIT_DESTROYED` (creature-ID match)

- Core registers `UNIT_DIED`, `UNIT_DESTROYED` as CLEU sub-events (`Core:1386-1387`); the CLEU dispatcher (`Core:356-467`) fills `args` and calls `handleEvent(nil, event, args)`, so `DBM:UNIT_DIED(args)` (`Core:2013-2018`) receives it. `DBM.UNIT_DESTROYED = DBM.UNIT_DIED` (`Core:2018`).
- Filter creature/vehicle: `bit.band(args.destGUID:sub(1, 5), 0x00F) == 3 or == 5` (`Core:2014`); parse `tonumber(args.destGUID:sub(9, 12), 16)` (`Core:2015`) → `OnMobKill(cId)`.
- `OnMobKill` (`Core:1983-2011`): if the mod has `killMobs` (multi-kill), mark that cId false and end when all are down (`Core:1989-2003`); else if `cId == v.combatInfo.mob and not killMobs and not multiMobPullDetection` → `EndCombat(v)` (`Core:2004-2009`). Broadcasts `DBMv4-Kill` if not synced.
- Note the guard: a multi-mob pull-detection mod without explicit killMobs still gets killMobs auto-filled from `multiMobPullDetection` (`Core:3731-3736`), so all listed cIds must die.

### 2b. Kill via authored monster message (`RegisterKill`)

- `onMonsterMessage` tail (`Core:1808-1814`): for each in-combat mod, `if v.combatInfo.killType == type and v.combatInfo.killMsgs[msg] then DBM:EndCombat(v)`. Table set by `RegisterKill(msgType, ...)` (`Core:3746-3759`). Example: `BC/MagistersTerrace/Delrissa.lua:8 mod:RegisterKill("yell", L.DelrissaEnd)` with comment on line 7 `--Not working right yet, so yell for kill still required`.
- Note `Core:1810 if not v.combatInfo then return end` — an early `return` (not `continue`) inside the loop; a mod without combatInfo aborts the whole kill scan.

### 2c. Wipe via "nobody alive is in combat" poll (`checkWipe`)

- `checkWipe(confirm)` (`Core:1839-1864`): iterates `player` + `raidN`/`partyN`; wipe stays true unless some unit is `UnitAffectingCombat(id) and not UnitIsDeadOrGhost(id)` (`Core:1845`).
  - Not a wipe → re-poll in **3 s** (`Core:1851`).
  - Looks like a wipe, unconfirmed → schedule the confirm pass after `maxDelayTime` = **5 s** or the largest `combatInfo.wipeTimer` among in-combat mods (`Core:1857-1861`; `SetWipeTime`, `Core:3778`).
  - Confirmed → `EndCombat(mod, true)` for all (`Core:1853-1855`).
- First poll scheduled at engage after `mod.minCombatTime or 3` s (`Core:1884`, `SetMinCombatTime` `Core:3773`).
- Also exposed as `bossModPrototype:IsWipe()` (`Core:3798-3809`) with the same body.
- No `PLAYER_REGEN_ENABLED` anywhere; no `IsEncounterInProgress`.

### 2d. Sync (`DBMv4-Kill`)

- `Core:1533-1537`: `OnMobKill(cId, true)`; ignored in pvp.

### What `EndCombat` does (`Core:1915-1981`)

- `mod:Stop()` (stops all timers + unschedules mod tasks, `Core:2552-2557`); `blockSyncs = true` (`Core:1919`); resets killMobs to true; on wipe: if fight `< 30` s, decrement pull count (`Core:1927`); on kill: stats + best-time; auto-respond whispers; `mod:OnCombatEnd(wipe)`; hides health frame + arrow.

**REUSABLE MECHANISM (generic)**
- CLEU `UNIT_DIED` with GUID-type filter and cId parse (`Core:2013-2017`).
- The group `UnitAffectingCombat && !UnitIsDeadOrGhost` wipe poll with its 3 s / 5 s two-pass confirm (`Core:1839-1864`), and the "<30 s = not a real pull" rule (`Core:1927`).
- Stop-everything-on-end discipline (`mod:Stop()` = cancel timers + unschedule all mod tasks, `Core:2552-2557`).

**POSTURE NOT TO INHERIT**
- Which cId(s) must die (`combatInfo.mob` / `killMobs`) — authored.
- Kill-by-yell strings (`RegisterKill`) — authored, locale-bound.
- Per-mod `wipeTimer` / `minCombatTime` overrides — authored tuning.
- Kill/best-time stats keyed on `IsDifficulty("normal5","heroic5",…)` with hard-coded module names in `GetDifficulty` (`Core:2575,2578`: `self.modId == "DBM-Party-WotLK" or self.modId == "DBM-Party-BC"`).

---

## 3. BOSS IDENTITY

- Binding is by **creature ID**, declared per mod: `mod:SetCreatureID(17308)` (`BC/Hellfire_Ramp/Omor.lua:5`), multi `mod:SetCreatureID(17537, 17536)` (`Vazruden.lua:5`), 9 ids for the council (`Delrissa.lua:6`). Stored as `self.creatureId` (first id) + `self.multiMobPullDetection` (`Core:2477-2485`).
- GUID → cId parse everywhere is the 3.3.5 layout: type nibble `bit.band(guid:sub(1, 5), 0x00F)` == 3 (creature) or 5 (vehicle), id `tonumber(guid:sub(9, 12), 16)` — `Core:311,315` (`args:GetSrcCreatureID/GetDestCreatureID`), `Core:1716-1717`, `Core:2014-2015`, `Core:2519-2526` (`GetUnitCreatureId`, `GetCIDFromGUID`), `Core:3787`, `BH:171-177`. **No `strsplit("-", guid)` — the modern GUID form is not assumed anywhere.**
- Names are **display only**: `combatInfo.name = self.localization.general.name or self.id` (`Core:3715`), set per locale by the module's `localization.*.lua` (`BC/localization.en.lua:11 name = "Watchkeeper Gargolmar"`), falling back to the mod id when unlocalized (`Core:2436`, `returnKey` metatable `Core:3964`). Names never drive detection.
- Zone: mod inherits its zone list from the addon TOC (`SetZone()` with no args, `Core:2457-2469`) — a name list (`X-DBM-Mod-LoadZone`) and/or numeric `X-DBM-Mod-LoadZoneID` (`Core:1354-1355`), matched against `GetRealZoneText()` / `GetCurrentMapAreaID()` at event-dispatch time (`Core:321`) and in combatInfo lookup (`Core:1749`).
- Locating the boss unit at runtime (for HP / target-of-boss): scan `focus`, `target`, `raidN target`/`partyN target` and compare cId (`Core:2528-2537 GetBossTarget`, `Core:3782-3792 GetBossHPString`, `BH:200-219` with a per-cId unit-token cache refreshed each 0.5 s).
- Localisation: `DBM:GetModLocalization(name)` returns a table whose sub-tables (`general`, `warnings`, `timers`, `options`, `miscStrings`, `cats`) default to returning the key itself (`Core:3960-4048`); auto-localized announces/timers pull the spell name from `GetSpellInfo(spellId)` (`Core:2777`, `Core:3467`), so **spellId-based objects need no authored locale strings**, while yells/kill-strings/phase yells do (`Kael'thas.lua:60 if msg == L.KaelP2`).

**REUSABLE MECHANISM (generic)**
- 3.3.5 GUID parse: type nibble at hex 5, cId at hex 9-12 (`Core:1716-1717`).
- Locating a creature by cId across `focus/target/raidN target/partyN target` with a unit-token cache (`BH:170-219`).
- Key-echo localisation tables (`Core:3964`) and `GetSpellInfo`-derived text so spellId objects self-localise.

**POSTURE NOT TO INHERIT**
- The cId list itself, per boss.
- Localized boss names per mod (`localization.*.lua` in the module — 1170 lines for Party-BC).
- Zone lists in TOC metadata (`X-DBM-Mod-LoadZone`) — a name-keyed table maintained per locale (`DBM-Party-BC.toc:14-18`).

---

## 4. MOD STRUCTURE

### Declaration (minimal mod = `BC/Hellfire_Ramp/Vazruden.lua`, 11 lines)

```
local mod = DBM:NewMod("Vazruden", "DBM-Party-BC", 1)   -- id, addon (modId), subTab index
local L   = mod:GetLocalizedStrings()
mod:SetRevision(...)
mod:SetCreatureID(17537, 17536)
mod:RegisterCombat("combat")
mod:RegisterEvents("SPELL_AURA_APPLIED", "SPELL_AURA_REMOVED")
```
- `DBM:NewMod` (`Core:2407-2442`): unique id enforced (`Core:2408`), builds Options/announces/timers/`vb` tables, links `obj.addon` from `DBM.AddOns` by modId (`Core:2430-2435`), adds a `HealthFrame` bool option, calls `SetZone()` → zones from TOC.
- `RegisterCombat(cType, ...)` (`Core:3708-3743`): builds `combatInfo{type, mob=self.creatureId, name, msgs (if not "combat"), mod, multiMobPullDetection?, killMobs? (numbers in varargs)}` and **indexes it under every zone in `self.zones`** (`Core:3739-3742`) — this is what makes 1a/1b find it. Without `RegisterCombat` a mod gets no engage/end at all (`Core:1868 if not mod.combatInfo then return end`) — `PortalTimers.lua` deliberately does this (no RegisterCombat, works purely off `UPDATE_WORLD_STATES` + `UNIT_DIED`, `BC/CoT_BlackMorass/PortalTimers.lua:6-10`).
- `RegisterEvents(...)` (`Core:327-334`, shared by DBM and mods via `Core:2453`): appends the mod to `registeredEvents[ev]` and registers on the single `mainFrame`. Dispatch (`Core:318-325`) calls `v[event](v, ...)` only if the mod defines that method, its zone matches now, and `Options.Enabled`. CLEU sub-events are registered by sub-event name (e.g. `"SPELL_AURA_APPLIED"`) and dispatched from the CLEU unpacker (`Core:466`).
- Per-mod state: `mod.vb` (`Core:2422`), file-local upvalues (`Mythic_Champion.lua:47-53,87`), reset in `OnCombatStart` (`Kael'thas.lua:26-30`, `Mythic_Champion.lua:91-93`).
- Options: `AddBoolOption/AddSliderOption/AddDropdownOption` (`Core:3614-3675`) with saved vars per addon: `_G[modId:gsub("-","").."_SavedVars"]` (`Core:1283`).

### Loading per zone (avoiding loading everything)

- Every module addon is `## LoadOnDemand: 1` and `## RequiredDeps: DBM-Core` (`DBM-Party-BC.toc:6-7`) and self-describes with `X-DBM-Mod`, `X-DBM-Mod-LoadZone[-locale]`, optional `X-DBM-Mod-LoadZoneID` (`.toc:9-18`).
- At `ADDON_LOADED("DBM-Core")` Core walks `GetNumAddOns()` and collects every addon with metadata `X-DBM-Mod` into `self.AddOns` (`Core:1348-1378`), reading zone lists via `GetAddOnMetadata` — **no code from the module is executed at this point**.
- `ZONE_CHANGED_NEW_AREA` (`Core:1429-1448`): for each not-yet-loaded entry whose zone list contains `GetRealZoneText()` or `GetCurrentMapAreaID()`, `DBM:Schedule(3, DBM.LoadMod, DBM, v)` — 3 s deferred because of a noted WotLK-beta bug (`Core:1434-1435`). `LoadMod` (`Core:1450-1479`): `EnableAddOn` if disabled, `LoadAddOn(mod.modId)`, then `loadModOptions`, propagate `hasHeroic`, GC. Also called once at load (`Core:1399`).
- Special-cases: PvP module force-loaded in `pvp` instances (`Core:1440-1447`) and by polling `GetBattlefieldStatus` every 1 s until loaded (`Core:1481-1501`).
- Granularity is **one addon per expansion-tier group of dungeons** (Party-BC = 16 dungeons, 59 boss files, `.toc:29-90`), not per dungeon; once loaded, all mods in it stay resident and are filtered per event by zone (`Core:321`).
- Observed defect: both `DBM-Party-BC.toc:24` and `DBM-Party-Vanilla.toc` list `MythicChampion.lua`, but the file on disk is `Mythic_Champion.lua` — that entry does not load (silent).

**REUSABLE MECHANISM (generic)**
- Metadata-driven LoD: read `X-*` TOC fields via `GetAddOnMetadata` at boot, `LoadAddOn` on `ZONE_CHANGED_NEW_AREA` when zone name/id matches (`Core:1348-1378, 1429-1439, 1450-1479`).
- Single event frame + per-event subscriber list + "call the method if the subscriber defines it" dispatch (`Core:318-334`).
- Prototype/constructor pattern (`NewMod` → `bossModPrototype`), per-mod option tables auto-persisted under a derived saved-var name (`Core:1282-1311`).
- Callback bus `DBM:RegisterCallback` / `fireEvent("pull"|"kill"|"wipe"|"DBM_TimerStart"…)` (`Core:475-505`).

**POSTURE NOT TO INHERIT**
- Every `SetCreatureID`, `RegisterCombat`, `RegisterKill`, spellId list, timer duration, `OnCombatStart` phase reset — authored per boss (e.g. `Mythic_Champion.lua:14-44` is a hand-transcribed timeline).
- Zone lists per locale in TOC; hard-coded module-name checks in `GetDifficulty` (`Core:2575`); banned-mods list (`Core:160`).

---

## 5. CHARACTER STATE CONDITIONS

- **Role/spec** (`Core:2609-2678`): class token from `UnitClass("player")` plus talent-tab point counts `select(3, GetTalentTabInfo(n)) >= 51` for spec (`IsMelee/IsRanged/IsTank/IsHealer/IsPhysical/CanRemoveEnrage`); DK/Druid tank inferred from specific talent point spends via `getTalentpointsSpent(spellID)` scanning `GetTalentInfo` by name (`Core:2609-2620, 2649-2664`). Mods also inline it: `Temporus.lua:15-17 local isDispeller = select(2, UnitClass("player")) == "MAGE" or ...` used as the **option default** for a special warning (`Temporus.lua:23`). Note this is 3.3.5 class/talent knowledge and is evaluated at file-load time in the mod (not re-evaluated on respec).
- **In combat**: `bossModPrototype:IsInCombat()` = `self.inCombat` (`Core:3769-3771`), i.e. the mod's own engage state, not `UnitAffectingCombat("player")`. Used to suppress trash-time announces: `Delrissa.lua:26 if args:IsSpellID(17843) and self:IsInCombat()`. Player combat state is only read by the wipe poll (§2c) and by RangeCheck sounds (`RC:229 if not UnitAffectingCombat("player") then return end`).
- **Self-only filters** on CLEU: `args:IsPlayer()` = destFlags has `COMBATLOG_OBJECT_AFFILIATION_MINE` and `TYPE_PLAYER` (`Core:278-280`); `IsPlayerSource`, `IsPet`, `IsSrcTypePlayer/IsDestTypePlayer`, `IsSrcTypeHostile/IsDestTypeHostile` (`Core:282-308`). Used: `Omor.lua:28 if args:IsPlayer() then specwarnBane:Show()`; `Temporus.lua:33 ... and not args:IsDestTypePlayer()`; `Mythic_Champion.lua:148`.
- **Target**: `GetBossTarget(cid)` (`Core:2528-2537`) — finds a raid member targeting the boss then reads `raidN targettarget` (or `focustarget`); `GetThreatTarget` uses `UnitDetailedThreatSituation("raid"..x, "raid"..i.."target") == 1` (`Core:2539-2550`). Both iterate `1..GetNumRaidMembers()` only — **they do not work in a 5-man party** (party loop absent).
- **Range** (`DBM-RangeCheck.lua`): three mechanisms, chosen by requested yardage:
  - `CheckInteractDistance(uId, 2|3|4)` for 11 / 10 / 28 yd (`RC:328-339`).
  - `IsItemInRange(bandageItemId, uId)` for 15 yd, trying a list of bandage item ids and requiring one to be in the item cache (`RC:395-407`).
  - Any other range → `mapRangeCheck` via `GetPlayerMapPosition` × authored map dimensions `DBM.MapSizes[GetMapInfo()][GetCurrentMapDungeonLevel()]` (`RC:342-393`, `Core:2380-2391 RegisterMapSize`); returns unsupported if the zone has no registered size (`RC:314`).
  - Frame is a `GameTooltip` refreshed every 0.5 s (`RC:273-279`) listing up to 5 raid members (`RC:300-311`, again `raid`-only), optional per-mod `filter(uId)` (`RC:413-425`), sound every 5 s while in combat (`RC:316-320, 228-241`). No `UnitPosition`.
- **Health thresholds**: `GetBossHPString(cId)` / `GetHP()` scan targets and return `floor(UnitHealth/UnitHealthMax*100).."%"` (`Core:3782-3796`); `GetHealth(unit)` (`Core:3946-3949`); BossHealth frame updates every 0.5 s (`BH:183-226`). No core HP-threshold trigger — mods poll or use `RegisterOnUpdateHandler(func, interval)` (`Core:2504-2509`, ticked from the scheduler's OnUpdate `Core:645-654`).
- **Latency**: `LatencyCheck()` = `select(3, GetNetStats()) < DBM.Options.LatencyThreshold` (default 250, `Core:110, 2605-2607`).
- **Vehicle**: `UnitInVehicle("player")` blocks engage if `noCombatInVehicle` (`Core:1869`).
- **Announce gating on group rank**: raid-warning broadcast only if `DBM:GetRaidRank() > 0 or (GetNumRaidMembers() == 0 and GetNumPartyMembers() >= 1)` (`Core:2702`); icons only if rank > 0 and no higher-version promoted player (`Core:3874`, `enableIcons` `Core:158,1149,1552`).

**REUSABLE MECHANISM (generic)**
- CLEU flag helpers (`IsPlayer`, `IsDestTypePlayer`, hostile checks) — `Core:278-308`.
- `CheckInteractDistance` tiers and the `IsItemInRange` trick (`RC:328-339, 395-407`); the 0.5 s tooltip-frame refresh pattern.
- Mod-own `inCombat` as the "we are in the fight" predicate rather than `UnitAffectingCombat("player")`.
- Talent-tab-count spec inference (`GetTalentTabInfo`) — generic in shape, though its numbers are 3.3.5 class knowledge.
- `UnitDetailedThreatSituation` for tank identification.

**POSTURE NOT TO INHERIT**
- Map-size tables per zone/level for the fallback range check (`RegisterMapSize`, authored per instance).
- Raid-only loops in `GetBossTarget/GetThreatTarget/RangeCheck onUpdate` (`Core:2530, 2541`, `RC:300`) — a product limitation to be aware of, not a mechanism.
- Class/talent thresholds hard-coded for retail 3.3.5 classes (`Core:2622-2678`) — wrong for a custom-class server; `Temporus.lua:15` computes them once at file load.

---

## 6. TIMERS + ANNOUNCE

### Scheduler (no `C_Timer`)

- Own **binary min-heap** of `{time, func, mod, args...}` (`Core:548-631`), drained from `mainFrame`'s `OnUpdate` every frame: `while nextTask and nextTask.time <= time do deleteMin(); nextTask.func(unpack(nextTask))` (`Core:633-643`). Time base `GetTime()`.
- `schedule(t, f, mod, ...)` / `unschedule(f, mod, ...)` (`Core:664-690`); unschedule is a linear `removeAllMatching` with partial-arg matching then heap rebuild (`Core:607-630`). Small-task table recycling, cap 8 (`Core:512-541`).
- Mod-facing: `mod:Schedule/Unschedule/ScheduleMethod/UnscheduleMethod` (`Core:3845-3867`); `mod:Stop()` unschedules everything owned by the mod (`Core:2556`).
- Same OnUpdate also ticks per-mod `RegisterOnUpdateHandler` functions with their own interval (`Core:645-654`) and expires one `modSyncSpam` entry per frame (`Core:658-661`).

### Bars (DBT)

- `DBT:CreateBar(timer, id, icon, …)` (`DBT:379-439`) — **hard cap 15 live bars** (`DBT:381 if (self.numBars or 0) >= 15 and not isDummy then return end`); an existing id is *updated* not duplicated (`DBT:382-390`); bar objects recycled (`DBT:392-407`). Bars tick from a separate frame OnUpdate (`DBT:667-677`) with `self.timer = self.timer - elapsed` (`DBT:584`), flashing under 7.75 s (`DBT:611`), enlarge under `EnlargeBarsTime`.
- Timer objects (`Core:3227-3549`): `Start(timer, ...)` builds `id = self.id .. "\t"..args` (`Core:3237`) so per-target instances are separate bars; keeps `startedTimers` list; schedules its own removal at expiry (`Core:3253-3255`); `Stop/Cancel/Update/AddTime/RemoveTime/GetTime/IsStarted`. Auto-localized constructors `NewTargetTimer/NewCastTimer/NewCDTimer/NewNextTimer/NewBuffActiveTimer/NewPhaseTimer/NewAchievementTimer` derive text and icon from `GetSpellInfo(spellId)` (`Core:3453-3503`, `localization.en.lua:109-117`). `NewCastTimer` with a spellId as first arg divides `GetSpellInfo` cast time by the player's haste measured against Dalaran Portal 53142 (`Core:3513-3522`, same trick `Core:2781`).
- `NewBerserkTimer` = bar + auto-scheduled 10/5/3/1 min and 30/10 s warnings (`Core:3555-3607`).

### Announcements

- Announce object `Show(...)` (`Core:2700-2744`): per-object bool option; optional raid-warning broadcast `SendChatMessage("*** %s ***", "RAID_WARNING"|"PARTY")` gated on `mod.Options.Announce` (default false, `Core:2413`) and rank (`Core:2702`); on-screen via `RaidNotice_AddMessage(RaidWarningFrame, …)` (`Core:2727`); optional chat echo; `PlaySoundFile(DBM.Options.RaidWarningSound)` (`Core:2741`) — **one sound per Show, no throttle in the object**. `Schedule/Cancel` go through the heap.
- Special warning (`Core:2998-3146`): single centered fontstring, 5 s timer with fade (`Core:3028-3037,3046`), plus `LowHealthFrame` flash, sound `SpecialWarningSound` unless `noSound`.
- Yell objects (`Core:2887-2993`) `SendChatMessage(..., "SAY"|"YELL")`.
- Sound objects (`Core:2848-2882`).

### Throttling / anti-spam

- `DBM:AntiSpam(times, id)` (`Core:2364-2375`): per-mod (or per-id) "return true if > `times` (default 2.5 s) since last true" — **opt-in, mods must call it**; not used by the Party-BC files read.
- Sync spam: `modSyncSpam[modId..event..arg]` 2.5 s window on both send and receive (`Core:3822, 3831`).
- Timer bar dedupe by id (`DBT:382`), 15-bar cap.
- Whisper auto-respond once per sender per fight (`autoRespondSpam`, `Core:2188-2192`, wiped at `EndCombat` `Core:1976`).
- `SendTimers` 0.4 s guard (`Core:2069`).
- Chat filters hide DBM's own `***` raid warnings and whispers (`Core:2210-2269`).
- Announce/emit paths recompute strings each call (`Core:2700` comment `-- todo: reduce amount of unneeded strings`).

**REUSABLE MECHANISM (generic)**
- Heap scheduler on OnUpdate with owner-tagged tasks and mass-unschedule-by-owner (`Core:548-690, 2552-2557`).
- Bar identity = name + "\t" + args, so target-instanced timers coexist and re-Start updates in place (`Core:3237`, `DBT:382`); hard live-bar cap.
- `AntiSpam(window, id)` pattern (`Core:2364`).
- Option-per-emitter (`AddBoolOption` at construction) so every announce/timer is user-toggleable.

**POSTURE NOT TO INHERIT**
- Every timer duration / cast time (`NewNextTimer(68, …)`, "Best guess based on limited CL data" `Kael'thas.lua:22-23`) — authored knowledge.
- Haste-normalisation via Dalaran Portal 53142 (`Core:2781, 3517`) — assumes that spell exists with 10 s base cast on this server.
- RaidWarningFrame/LowHealthFrame reuse and the fake-`CHAT_MSG_RAID_WARNING` injection into other frames (`Core:2730-2736`) — product-specific UI choices.

---

## 7. SYNC

- Transport `sendSync(prefix, msg)` (`Core:207-216`): `SendAddonMessage` to `BATTLEGROUND` in pvp/arena, else `RAID` if any raid members, else `PARTY`. Inbound `CHAT_MSG_ADDON` (`Core:1621-1629`): non-whisper channels → `syncHandlers[prefix]`; `WHISPER` only from someone in `raid[]` roster → `whisperSyncHandlers`.
- Prefixes and what they treat as authoritative:
  - `DBMv4-Pull` (`Core:1521-1531`) — any sender's engage is accepted (with lag added) if zone and `minSyncRevision` match → **engage is peer-authoritative** (first sync wins because `StartCombat` is idempotent).
  - `DBMv4-Kill` (`Core:1533-1537`) — any peer's kill cId accepted.
  - `DBMv4-Mod` (`Core:1512-1519`) → `mod:ReceiveSync(event, arg, sender, revision)` (`Core:3828-3835`): dropped if within 2.5 s of same `id..event..arg`, if `blockSyncs` (set true at EndCombat, cleared at Start, `Core:1882,1919`), or if sender revision < `minSyncRevision`. `SendSync` calls own `ReceiveSync` locally first (`Core:3823`), so **local and remote are treated identically — the mod's `OnSync` is the single state entry**. Example `PortalTimers.lua:64 self:SendSync("Wipe")`.
  - `DBMv4-Ver` (`Core:1539-1576`) — version roster; a promoted player with newer version disables *your* icon-setting (`enableIcons`, `Core:1551-1552`, `Core:1145-1149`) → **icon authority = highest version among rank≥1**.
  - `DBMv4-Pizza` / `-Cancel` — only from rank>0 senders (`Core:1580, 1592`).
  - Whisper: `DBMv4-RequestTimers` → `SendTimers` (`Core:2068-2084`), `DBMv4-CombatInfo`, `DBMv4-TimerInfo` (`Core:2041-2063`) — accepted only from the single `requestedFrom` peer chosen as highest-revision connected non-ghost (`Core:2028-2039`) within 5 s → **timer recovery authority = one elected best-version peer**.
- Roster: `raid[name]` built from `GetRaidRosterInfo` / party `UnitName` (`Core:1130-1218`); `GetRaidRank/GetRaidUnitId/GetRaidClass` read it.
- No sync of phase or HP; no leader-election beyond the commented-out `ElectMaster` (`Core:887-934`).

**REUSABLE MECHANISM (generic)**
- Prefix-dispatch table + channel selection (`Core:207-216, 1621-1629`), whisper-only-from-roster guard.
- Local==remote single-entry `OnSync` with a 2.5 s dedupe key (`Core:3816-3835`).
- Timer/combat recovery on reload from one elected peer with a 5 s acceptance window (`Core:2024-2063`).

**POSTURE NOT TO INHERIT**
- Trusting any peer's `Pull`/`Kill` (no rank check) — a product trust posture.
- Version-based icon authority and version-nag popup (`Core:1554-1571`).
- `SendBGTimers` name-based mod lookup with `-- FIXME: this doesn't work for non-english clients` (`Core:2092`).

---

## 8. THE LINE BETWEEN MECHANISM AND KNOWLEDGE

| # | Mechanism | Generic? | Needs authored data? | Cite |
|---|---|---|---|---|
| 1 | Group-target GUID scan + `UnitAffectingCombat` on `PLAYER_REGEN_DISABLED` | yes | cId(s) of the boss to match; zone list to index under | `Core:1711-1784`, `Core:3739` |
| 1 | 3 s re-scan for "targeted, not yet in combat" | yes | (same cId) | `Core:1743` |
| 1 | Engage-by-monster-message | mechanism generic (exact-match table lookup) | **yes: authored, locale-bound strings** | `Core:1789-1797` |
| 1 | `combatInitialized` reload guard | yes | no | `Core:1402,1748` |
| 1 | Peer `Pull` sync with lag compensation | yes | mod id must exist locally | `Core:1521-1531` |
| 2 | CLEU `UNIT_DIED` cId kill | yes | cId(s) that must die | `Core:2013-2017, 1983-2011` |
| 2 | Kill-by-monster-message | generic lookup | **authored strings** | `Core:1808-1814, 3746` |
| 2 | Group wipe poll 3 s / confirm 5 s | yes | optional per-mod `wipeTimer`/`minCombatTime` | `Core:1839-1864` |
| 2 | <30 s = not-a-pull | yes | no | `Core:1927` |
| 3 | GUID parse (nibble 5 == 3/5, hex 9-12) | yes (3.3.5-shaped) | no | `Core:1716-1717` |
| 3 | Locate creature by cId across focus/target/raidN target | yes | cId | `BH:170-219` |
| 3 | Boss display name | — | **authored per locale** | `Core:3715`, module `localization.*.lua` |
| 4 | Metadata-driven LoadOnDemand by zone | yes | **authored `X-DBM-Mod-LoadZone[-locale]` lists per module** | `Core:1348-1378, 1429-1479` |
| 4 | Event bus / prototype / options persistence | yes | no | `Core:318-334, 2407-2442, 1282-1311` |
| 4 | Everything inside a boss file (cIds, spellIds, timers, phase logic) | — | **100% authored** | `BC/*` |
| 5 | CLEU flag helpers (`IsPlayer` etc.) | yes | no | `Core:278-308` |
| 5 | Mod-own `inCombat` predicate | yes | no | `Core:3769` |
| 5 | Spec inference from talent tabs / talent spends | shape generic | **class-knowledge constants (retail 3.3.5)** | `Core:2609-2678` |
| 5 | Range: `CheckInteractDistance` 10/11/28, `IsItemInRange` 15 | yes | no | `RC:328-339, 395-407` |
| 5 | Range: map-position fallback | mechanism generic | **authored map sizes per zone/level** | `RC:342-393`, `Core:2382` |
| 5 | Boss HP by target scan | yes | cId | `Core:3782-3796` |
| 5 | Threat-target via `UnitDetailedThreatSituation` | yes (raid-only as written) | cId | `Core:2539-2550` |
| 6 | Heap scheduler on OnUpdate; owner-tagged unschedule | yes | no | `Core:548-690` |
| 6 | Bar id = name+args, dedupe/update in place, 15 cap | yes | no | `Core:3237`, `DBT:379-439` |
| 6 | Auto-text/icon from `GetSpellInfo(spellId)` | yes | spellId | `Core:2776-2814, 3453-3503` |
| 6 | `AntiSpam(window,id)` | yes | no | `Core:2364` |
| 6 | Timer durations, cast times, phase yells | — | **authored** | e.g. `Kael'thas.lua:20-24` |
| 6 | Haste-normalisation via spell 53142 | no (server-specific assumption) | — | `Core:2781, 3517` |
| 7 | Prefix-dispatch addon-message bus, channel choice | yes | no | `Core:207-216, 1621` |
| 7 | `OnSync` local==remote, 2.5 s dedupe, `blockSyncs` after end | yes | mod-defined event names | `Core:3816-3835` |
| 7 | Reload recovery from best-version peer | yes | no | `Core:2024-2063` |
| 7 | Version-authority for icons | product | — | `Core:1145-1149, 1551` |

Summary of the line: **the Core is a generic engine for "engage on group-target-in-combat / end on cId death or group-out-of-combat / schedule and display", parameterised entirely by authored (cId, spellId, string, duration, zone) tuples supplied by per-boss files.** Nothing in Core knows any boss; nothing in a boss file knows how detection works. The only Core-resident *knowledge* is: 3.3.5 class/talent constants for role inference (`Core:2609-2678`), the Dalaran-Portal haste probe (`Core:2781,3517`), the bandage item ids (`RC:396`), the hard-coded `DBM-Party-BC/WotLK` names in `GetDifficulty` (`Core:2575,2578`), and the banned-mods list (`Core:160`).

Non-mechanism observations recorded for completeness: `DBM-HelpFunctions.lua` (Ascension helper file referencing `AscensionBuffFrames_*` and undefined `DBM_BOSS_DATA`, `DBM_send_mess`, `DBM_GetS`) is not in the TOC and never loads; `DBM-Party-BC.toc:24` and `DBM-Party-Vanilla.toc` reference `MythicChampion.lua` while the file is `Mythic_Champion.lua`; `Core:1810` uses `return` where `break`/skip is intended.
