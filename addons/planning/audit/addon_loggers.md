# Audit — combat-log consumers at volume (Recount · Details · Skada)

_Independent mechanism audit, read-only, from files under
`F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns\`. Lens: LOGGING — how a mature
CLEU consumer reads `COMBAT_LOG_EVENT_UNFILTERED`, what it costs, how it bounds the cost. Cites are
`file:line`. Paths below are relative to that AddOns root. Nothing here was executed in the client;
"on this client" claims are drawn from the files plus one repo record cited where used._

Builds audited:
- **Recount** — `Recount/Recount.toc:1` `## Interface: 40100`, `X-Curse-Packaged-Version: v4.1.0a release` (a Cataclysm-4.1 build running on a 3.3.5 client; it carries its own pre-4.1 shim, §1).
- **Skada** — `Skada/Skada.toc:1` `## Interface: 30300`, `Version: 1.9.1` (Kader's 3.3.5 fork; carries `Modules/Ascension.lua`).
- **Details** — `Details/Details.toc:1` `## Interface: 30300`, `Version: #Details.20240508.12893.160` (a retail-era codebase back-ported; core only read: `core/parser.lua`, `core/control.lua`, `core/gears.lua`, `core/util.lua`, `boot.lua`, `startup.lua`).

---

## 1. REGISTRATION

### Recount
- Registered through AceEvent-3.0 as a **method-name callback**, one handler:
  `Recount/Recount.lua:2043` `Recount:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED","CombatLogEvent")` inside `Recount:OnEnable` (`:2017`).
- AceEvent's single shared frame does the actual `RegisterEvent`: `Recount/Libs/AceEvent-3.0/AceEvent-3.0.lua:32-34` `function AceEvent.events:OnUsed(target, eventname) AceEvent.frame:RegisterEvent(eventname)`; dispatch is `AceEvent.frame:SetScript("OnEvent", function(this, event, ...)` (`:119`), so the method receives `(self, event, ...)`.
- Argument style: **varargs**. Handler signature `Recount/Tracker.lua:977`
  `function Recount:CombatLogEvent(_,timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)` — `_` is the event name.
- **Shim, cited:** `Recount/Tracker.lua:968-975` computes `TOC = major*10000 + minor*100` from `GetBuildInfo()`; then `:986-991`:
  ```lua
  if TOC < 40100 and hideCaster ~= dummyTable then
      -- Insert a dummy for the new argument introduced in 4.1 and perform a tail call
      return self:CombatLogEvent(_,timestamp, eventtype, dummyTable, hideCaster, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
  end
  ```
  On a 3.3.5 build (`TOC = 30300`) **every event pays a second call** to re-shape the pre-4.1 tuple (`ts, sub, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...`) into the 4.1 shape. Note the shim runs *after* the two early exits at `:978-984`, so quick-exited events pay only one call.
- `CombatLogGetCurrentEventInfo`: **not referenced anywhere in Recount** (grep over `Recount/**/*.lua`: zero hits).
- OFF: `Recount:OnDisable` → `Recount:UnregisterAllEvents()` (`Recount/Recount.lua:2052-2058`).

### Skada
- AceEvent method callback, one handler: `Skada/Core/Core.lua:3237` `self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "CombatLogEvent")` in `Skada:OnEnable` (`:3230`).
- Signature is the **classic 3.3.5 varargs tuple, no hideCaster**: `Skada/Core/Core.lua:3844`
  `function Skada:CombatLogEvent(_, timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)`.
- No `CombatLogGetCurrentEventInfo` anywhere in `Skada/` (grep: zero hits).
- Same event is also **re-registered / unregistered at runtime** by `Skada:SetActive` (`:1291-1320`): `:1310` `self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")` when hidden+`hidedisables`; `:1316` re-registers.
- Modules do **not** register CLEU themselves; they subscribe to the core via `Skada:RegisterForCL(callback, "SUBEVENT", ..., flagsTable)` (`:3744-3765`), e.g. Deaths: `Skada/Modules/Deaths.lua:773-779` `Skada:RegisterForCL(UnitDied, "UNIT_DIED", "UNIT_DESTROYED", "UNIT_DISSIPATES", flags_dst_nopets)`.

### Details
- Own dedicated frame: `Details/boot.lua:288` `Details222.parser_frame = CreateFrame("Frame")`; registration `Details/startup.lua:289` `Details222.parser_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")`; handler set `Details/core/parser.lua:6141` `Details222.parser_frame:SetScript("OnEvent", Details222.Parser.OnParserEvent)`.
- Argument style: **`CombatLogGetCurrentEventInfo(...)` with the varargs forwarded** — `Details/core/parser.lua:6087-6094`:
  ```lua
  function Details222.Parser.OnParserEvent(self, event, ...)
      local time, token, hidding, who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, A1, ... = CombatLogGetCurrentEventInfo(...)
      local func = token_list[token]
      if (func) then return func(nil, token, time, who_serial, ...) end
  end
  ```
  The global is captured as an upvalue at `:16` `local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo`. **No shim defining it exists in Details** (grep for a definition across `Details/`: only the `:16` capture and call sites at `:6088/6097/6122/6134` plus `frames/*` and `functions/plater.lua`).
- **What the client provides — from the repo, not from Details:** `addons/planning/pet_parser_scope.md:20-27` records a live capture: "`CombatLogGetCurrentEventInfo` EXISTS but is FURNITURE at the handler level … the global returns nothing useful inside a live CLEU handler. The real layout is the CLASSIC 3.3.5 varargs tuple … `1 ts · 2 subevent · 3 srcGUID · 4 srcName · 5 srcFlags · 6 dstGUID · 7 dstName · 8 dstFlags · 9+ suffix` (no hideCaster)". That capture called it with **no arguments**. Details calls it **with `...` forwarded**; whether the fork's function echoes forwarded args was not verified by this audit (read-only). Data point only: three other local addons hedge on this — `LibellusLeti/CombatLog.lua:5` (`return _G.CombatLogGetCurrentEventInfo`, a normalizer), `TurboPlates/HealerDetection.lua:144` comment "Ascension uses modern CLEU format via CombatLogGetCurrentEventInfo", `COA_DevDump/task_petlog.lua:52-53` (`if CombatLogGetCurrentEventInfo then local t = { CombatLogGetCurrentEventInfo() }` — the fallback-first design that produced the record above).
- Details also has a **second dedicated frame** for the alt-parser swap (`Details/core/gears.lua:783-787`, `Details222.Parser.EventFrame` registered for PEW/ZONE/REGEN) — but its OnEvent body starts with `do return end` (`:789`), i.e. **the swap logic is disabled in this build**; the parser stays on `OnParserEvent`.

**REUSABLE MECHANISM**
- One frame, one `OnEvent`, one CLEU registration (Details' `parser_frame`, `boot.lua:288` / `startup.lua:289`); no library indirection on the hot path.
- Treat the tuple as **positional varargs** (Skada `Core.lua:3844` shape) — that is the shape the repo record confirms on this client.
- Capture globals as upvalues at file top (`Details/core/parser.lua:16-17`, `Recount/Tracker.lua:19,38`).

**POSTURE NOT TO INHERIT**
- Recount's build-detect + tail-call re-shape (`Tracker.lua:986-991`) — a per-event second call to paper over a TOC mismatch. Write for the client you have.
- Details' `CombatLogGetCurrentEventInfo(...)` forwarding — depends on a fork behaviour the repo has already found to be "furniture" when called bare; a small addon should not stake correctness on it.
- AceEvent method-name dispatch through CallbackHandler for the single hottest event in the game (Recount/Skada) — fine at meter scale, unnecessary indirection for a one-event listener.

---

## 2. DISPATCH

### Recount (`Recount/Tracker.lua`)
- **First checks, in order** (`:977-1021`):
  1. `:978` `if not Recount.db.profile.GlobalDataCollect or not Recount.CurrentDataCollect then return end` — global on/off and the zone/group collection flag.
  2. `:982` `if QuickExitEvents[eventtype] then return end` — a table of subevents "we don't care about" (`:847-869`: `SPELL_AURA_APPLIED_DOSE`, `_REMOVED_DOSE`, `SPELL_CAST_START/SUCCESS/FAILED`, `SPELL_DRAIN`, `PARTY_KILL`, `SPELL_PERIODIC_DRAIN`, `SPELL_DISPEL_FAILED`, `SPELL_DURABILITY_*`, `ENCHANT_*`, `SPELL_CREATE`, `SPELL_BUILDING_DAMAGE`), extended at load time for tracker modules that are absent (`:871-891`, e.g. `if not Recount.SpellResurrect then QuickExitEvents["SPELL_RESURRECT"] = true`).
  3. `:987` the pre-4.1 shim tail call (§1).
  4. `:993-998` **flag retention** on both actors: `srcRetention = Recount:CheckRetentionFromFlags(srcFlags,...)`, `dstRetention = ...(dstFlags,...)`, `if not srcRetention and not dstRetention then return end`.
  5. `:1003-1012` `MatchGUID` (learns the player's own GUID from `LIB_FILTER_ME` flags, `:385-392`).
  6. `:1014-1020` **table lookup by subevent string**: `parsefunc = EventParse[eventtype]; if parsefunc then parsefunc(self, timestamp, eventtype, srcGUID, ..., ...) else Recount:Print("Unknown combat log event type: "..eventtype)`.
- `EventParse` (`:792-845`) maps ~50 subevents to handlers, e.g. `["UNIT_DIED"] = Recount.UnitDied` (`:832`), `["UNIT_DESTROYED"] = Recount.UnitDied` (`:833`), `["UNIT_DISSIPATES"] = Recount.UnitDied` (`:844`), `["PARTY_KILL"] = Recount.PartyKill` (`:831`, a no-op at `:775-778`).
- **Flag tests** — `bit_band` against locally-defined constants with `or 0x…` fallbacks (`:38-76`); retention filter `CheckRetentionFromFlags` (`:901-961`) walks the profile's Data filters: `Grouped` = `band(flags, MINE+PARTY+RAID) ~= 0` (`:907`), `Self` = `band(flags, MINE+TYPE_PLAYER) == mask` (`:911`), `Ungrouped`, `Hostile` = `band(flags, CONTROL_PLAYER) ~= 0` (`:919`), pets, and NPCs where `Recount.IsBoss(nameGUID)` decides Boss vs Trivial/Nontrivial (`:943-955`). Note `:905` `if not nameFlags then return end -- Since 4.1 this can be nil`.

### Skada (`Skada/Core/Core.lua:3844-4033`)
- **First checks, in order:**
  1. `:3846` `if disabled or self.testMode then return end`.
  2. `:3849` `if ignored_events[eventtype] and not (spellcast_events[eventtype] and self.current) then return end` — `ignored_events` (`:3703-3717`) is Recount's list minus doses/aura-doses (`SPELL_AURA_REMOVED_DOSE`, `SPELL_CAST_*`, `SPELL_DRAIN`, `PARTY_KILL`, `SPELL_PERIODIC_DRAIN`, `SPELL_DISPEL_FAILED`, `SPELL_DURABILITY_*`, `ENCHANT_*`, `SPELL_CREATE`); casts are let through only once a segment exists.
  3. `:3854-3874` **tentative combat start** (only when no current segment, option on, and `trigger_events[eventtype]` = the 5 damage subevents `:3720-3726`).
  4. `:3877` `SPELL_SUMMON` special-case.
  5. `:3882` `if self.current then` — everything else only runs inside a segment.
  6. `:3906` `if combatlog_events[eventtype] then` — **table lookup by subevent → set of (callback, flags)**; `:3927` `for func, flags in next, combatlog_events[eventtype] do` evaluate the callback's declared interest flags then `func(timestamp, eventtype, srcGUID, ...)` (`:3982`).
- **Flag tests** — computed **once per event, lazily, memoised into locals**: `src_is_interesting = band(srcFlags, BITMASK_GROUP) ~= 0 or (band(srcFlags, BITMASK_PETS) ~= 0 and pets[srcGUID]) or players[srcGUID]` (`:3951`, `:3855`); `_nopets` variant `band(flags, BITMASK_GROUP) ~= 0 and band(flags, BITMASK_PETS) == 0 or players[guid]` (`:3931`, `:3941`). Masks: `:115` `BITMASK_GROUP = MINE + PARTY + RAID`, `:116` `BITMASK_PETS = TYPE_PET + TYPE_GUARDIAN`. GUID caches `players[]`/`pets[]` are filled by roster scans (`:2497-2503`, throttled 0.5 s at `:2491-2495`).
- Callback interest is **declarative**: `RegisterForCL(func, events..., {dst_is_interesting_nopets = true})` (`:3744-3765`); the core rejects with `fail = true` before calling (`:3928-3969`).

### Details (`Details/core/parser.lua`)
- **First check:** `token_list[token]` (`:6089-6093`) — pure table lookup, **no gating before it**; an unknown or disabled token costs one hash miss and the `CombatLogGetCurrentEventInfo(...)` unpack (§1).
- `token_list` (`:4460-4464` base = `SPELL_SUMMON` only) is populated per capture type by `Details:CaptureEnable` (`:4630-4678`, e.g. `token_list ["UNIT_DIED"] = parser.dead`, `["UNIT_DESTROYED"] = parser.dead` `:4677-4678`) and **nil'd out** by `Details:CaptureDisable` (`:4556-4612`, e.g. `token_list ["UNIT_DIED"] = nil` `:4611`). Disabling a capture class removes the tokens from dispatch entirely — the cheapest possible early exit.
- Per-handler early exits are inside each `parser:*` function: `parser:spell_dmg` `:486-491` (`sourceSerial == ""` + pet flags → return), `:520-523` `if (not targetName) then return end`; combat-start check `:658-699` (below, §7).
- **Flag tests** — `bitBand(flags, CONST)` with file-local constants (`AFFILIATION_GROUP`, `OBJECT_TYPE_PLAYER`, `OBJECT_TYPE_ENEMY`, `OBJECT_TYPE_PETS`, `OBJECT_TYPE_GUARDIAN` — captured in the parser preamble). Literal masks also appear inline: `parser:dead` `:4129` `bitBand(targetFlags, 0x00000008)` (OUTSIDER), `:4131` `0x00000400`/`0x00000040`/`0x00000020`; `outofcombat_spell_damage` `:6108` `IS_GROUP_OBJECT = 0x00000007`.

**REUSABLE MECHANISM**
- **Table lookup keyed by subevent string, nothing before it** (Details `:6089`; Skada `:3906`; Recount `:1014`) — every one of the three converges here.
- **Absent key = ignore** (Details `CaptureDisable` nils the token) rather than an explicit ignore-list. For a one-unit death listener the table has three keys: `UNIT_DIED`, `UNIT_DESTROYED`, `UNIT_DISSIPATES` (all three loggers alias them: Recount `:832-844`, Skada `death_events` `:3735-3739`, Details `:4677-4678` for the first two).
- Compute a flag predicate **once and memoise into a local** for the rest of the event (Skada `src_is_interesting`/`dst_is_interesting`, `:3851-3852`, `:3951`, `:3961`).
- Constants as **file-local upvalues with `or 0x…` fallback** (Recount `Tracker.lua:40-76`) — cheap, and survives a client that lacks a global.

**POSTURE NOT TO INHERIT**
- Recount's **two `CheckRetentionFromFlags` calls per event** walking a profile-filter table (`:993-994`) — that is meter policy (who to record), not liveness.
- Recount's `Recount:Print("Unknown combat log event type")` on a miss (`:1019`) — a chat message inside the hottest handler on an unlisted subevent.
- Skada's `RegisterForCL` multi-subscriber fan-out with per-callback flag negotiation (`:3927-3984`) — a plugin bus; a single-purpose listener has one callback.
- Details' inline literal masks (`0x00000008`, `0x00000007`) mixed with named constants — pick one vocabulary.

---

## 3. UNIT_DIED / BOSS DETECTION

### Recount
- Death path: `EventParse["UNIT_DIED"|"UNIT_DESTROYED"|"UNIT_DISSIPATES"] = Recount.UnitDied` (`Recount/Tracker.lua:832,833,844`) →
  `:780-782` `function Recount:UnitDied(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags) Recount:AddDeathData(nil, dstName, nil, srcGUID, srcFlags, dstGUID, dstFlags, nil) end`.
- Attribution key = **`dstName`** (after `Recount:DetectPet(victim, dstGUID, dstFlags)` `:2036` rewrites pet names to `"Pet <Owner>"`); combatant table is name-keyed (`dbCombatants[victim]` `:2056-2060`). `dstGUID`/`dstFlags` are carried along only for pet/owner resolution and the delayed death-log (`deathargs[3]=dstGUID; deathargs[4]=dstFlags` `:2108-2109`).
- Gate before recording: `dstRetention` (`:2053`) — the flag-retention filter from §2, so a death is only recorded for actors the profile keeps.
- Feign death filtered by **name-as-unit-token**: `:2065` `if Recount:InGroup(dstFlags) and UnitIsFeignDeath(victim) then return end`.
- Double-death suppression: `:2076-2082` `timeofdeath = GetTime(); doubleDeathDelay = victimData.DoubleDeathTime and timeofdeath-victimData.DoubleDeathTime or 10` and `:2092` `elseif not victimData.DoubleDeathSpellID or doubleDeathDelay >= 2 then Recount:AddAmount(victimData,"DeathCount",1)` — Spirit of Redemption / ghoul re-death within 2 s does not count.
- The death log itself is **deferred 2 s**: `:2102-2110` "We delay the saving of the event logs just in case more messages come later … `Recount:ScheduleTimer("HandleDeath",2,deathargs)`"; `HandleDeath` (`:2117-2172`) copies the victim's ring buffer of last events (`MessagesTracked` deep, `:2130,2150-2161`) into a `DeathLog` built from recycled tables (`Recount:GetTable()` `:2131-2140`).
- Death recording is **explicitly not combat-gated**: `:2019-2022` the `RecordCombatOnly` check is commented out with `-- Record all deaths.`
- **Boss detection = static NPC-id list**, no unit tokens: `:352-356`
  ```lua
  local bossIDs = BossIDs.BossIDs
  function Recount.IsBoss(GUID)
     return GUID and bossIDs[tonumber(GUID:sub(7, 10), 16)]
  end
  ```
  from `LibBossIDs-1.0` (`Recount/Libs/LibBossIDs-1.0/LibBossIDs-1.0.lua:18-21` "provides a table that flags mobIDs true if the mob linked to the ID is a boss … How to get mobID from GUID: `localmobID = tonumber(GUID:sub(-13, -9), 16)`"; the list is Cataclysm-era, first block `:30-36` "Abyssal Maw: Throne of the Tides"). Used in two places: retention (`:945`) and the segment name `Recount:BossFightWhoFromFlags` (`:1523-1533`: `if Recount.IsBoss(victimGUID) then Recount.FightingWho = victim; Recount.FightingLevel = -1`).
- **GUID decoder mismatch, cited not judged:** Recount `GUID:sub(7,10)` (`Tracker.lua:355`), the lib's own comment `GUID:sub(-13,-9)` (`LibBossIDs-1.0.lua:21`), Skada `guid:sub(9,12)` (`Skada/Libs/LibCompat-1.0/LibCompat-1.0.lua:444-446`), Details `select(6, strsplit("-", guid))` (`Details/core/util.lua:417-423`, the retail dash format). Three-plus decoders for one client — none verified here against a live GUID.
- No `INSTANCE_ENCOUNTER_ENGAGE_UNIT`, no `boss1..5`, no `UnitClassification` anywhere in Recount's death/boss path (grep: `boss1` zero hits in `Recount/*.lua`).

### Skada
- Core-level death use (segment control, not attribution): `Skada/Core/Core.lua:3893` `if eventtype == "UNIT_DIED" and ((band(srcFlags, BITMASK_GROUP) ~= 0 and band(srcFlags, BITMASK_PETS) == 0) or players[srcGUID]) then death_counter = death_counter + 1` — note this tests **`srcFlags`/`srcGUID`** on a death event; `:3900` `SPELL_RESURRECT` decrements. Wipe = `death_counter / starting_members >= 0.5` (`:3896`) → `StopSegment(L["Stopping for wipe."])`.
- Deaths module (`Skada/Modules/Deaths.lua`): subscribes `UNIT_DIED/UNIT_DESTROYED/UNIT_DISSIPATES` with `flags_dst_nopets = {dst_is_interesting_nopets = true}` (`:729`, `:773-779`) — i.e. the core pre-filters to **group players by dstFlags (`BITMASK_GROUP` set, `BITMASK_PETS` clear) or `players[dstGUID]`** before the callback fires (`Core.lua:3940-3947`).
- Handler `:260-264` `local function UnitDied(_, event, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags) if not UnitIsFeignDeath(dstName) then Skada:DispatchSets(log_death, dstGUID, dstName, dstFlags) end end` → attribution by **`dstGUID` + `dstName` + `dstFlags`** through `Skada:GetPlayer(set, playerid, playername, playerflags)` (`:217`).
- Spirit of Redemption handled as a death by aura: `:266-270` `if spellid == 27827 then Skada:ScheduleTimer(function() UnitDied(...) end, 0.01)`.
- Timestamps on the death record: `:227-228` `deathlog.time = set.last_time or GetTime(); deathlog.timeod = set.last_action or time()` (both clocks, §5). Old log rows ≥ 60 s before death are dropped (`:230-236`); same-timestamp rows get `+ (i * 0.001)` for sort stability (`:237-240`).
- **Boss detection**: `Skada:IsEncounter(guid, name)` (`Skada/Core/Functions.lua:400-414`) → `Skada:IsBoss(guid)` (`:387-398`) → `creatureToBoss[id] / creatureToFight[id]` where `id = self.GetCreatureId(guid)`; `creatureToBoss` falls back to `LibBossIDs-1.0` via metatable (`Skada/Core/Tables.lua:15-19` "use LibBossIDs-1.0 as backup plan … `setmetatable(creatureToBoss, {__index = LBI.BossIDs})`"). Called from the CLEU handler once per new hostile dst name (`Core.lua:4004-4027`); on hit `self.current.gotboss = bossid or true` and `SendMessage("COMBAT_ENCOUNTER_START")` (`:4013-4014`); non-bosses are remembered in `_targets[dstName]` so the lookup is **once per name per segment** (`:4017-4018`).
- Boss defeat from the log alone: `:4029-4030` `elseif not self.bossmod and self.current.gotboss and death_events[eventtype] and self.current.gotboss == GetCreatureId(dstGUID) then self:ScheduleTimer("BossDefeated", ...)` — **the death of the creature whose id was flagged as the boss**. If BigWigs/DBM are present the boss-mod path is preferred (`:3249-3257`, `:3287-3330`).
- `boss1`..: only inside LibCompat's `GetUnitIdFromGUID` fallback (`LibCompat-1.0.lua:385-390`, `for i = 1, MAX_BOSS_FRAMES do if UnitExists("boss"..i) and UnitGUID("boss"..i) == guid`) — used for health lookups, **not** for boss detection. No `INSTANCE_ENCOUNTER_ENGAGE_UNIT`.

### Details
- Death path: `token_list["UNIT_DIED"|"UNIT_DESTROYED"] = parser.dead` (`Details/core/parser.lua:4677-4678`); `parser:dead(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags)` (`:4115`).
- Order inside `parser:dead`: `:4117-4119` pet removal by **`targetSerial`** (`petContainer.RemovePet`); `:4122` `if (not targetName) then return end`; `:4127` `damageActor = _current_damage_container:GetActor(targetName)` — actor lookup by **name**; then a fork:
  - **enemy/outsider death** (`:4129` `_in_combat and targetFlags and (not damageActor or (bitBand(targetFlags, 0x00000008) ~= 0 and not damageActor.grupo))`) → counted as a "frag" keyed by `targetName` (`:4135-4141`);
  - **player death** (`:4144-4152`): `not UnitIsFeignDeath(targetName)` and `bitBand(targetFlags, AFFILIATION_GROUP) ~= 0 or damageActor.grupo` and `bitBand(targetFlags, OBJECT_TYPE_PLAYER) ~= 0` and `_in_combat` → builds the death log from a per-name ring buffer (`last_events_cache[targetName]`, `:4185-4236`, ring size `_amount_of_last_events = 16` `:332`), with the comment `:4190-4192` "during a regular combat, 99.9% of the events aren't used by the death log hence the process of getting data for the death log is made as fast as it can be; when a death occurs, the death log data is then parsed and built".
- **Boss detection is layered, unit-token first:**
  1. `ENCOUNTER_START` event (`Details/startup.lua:271` registration; handler `parser.lua:5011-5092` fills `Details.encounter_table.{id,name,start=GetTime(),...}`); `Details222.StartCombat` uses it if `encounter_table.start >= GetTime() - 3` (`control.lua:394-397`).
  2. Otherwise `Details:ReadBossFrames()` scheduled at +1 s and +30 s (`control.lua:401-402`): iterates `Details222.UnitIdCache.Boss` = `"boss1".."boss9"` (`Details/boot.lua:1313-1316`), `UnitGUID(bossUnitId)` → `Details:GetNpcIdFromGuid` → `Details:GetBossIds(zoneMapID)[npcId]` (`control.lua:192-213`; the id table is a static per-zone list, `Details/functions/boss.lua:161-163` `Details.EncounterInformation[mapid].boss_ids`).
  3. At combat end, `Details:FindBoss()` (`control.lua:217-266`) scans non-group actors' serials against the same `boss_ids` (`:231-241`); the Encounter-Journal name scan is hard-disabled (`:245` `noJournalSearch = true --disabling the scan on encounter journal`).
- `PLAYER_REGEN_DISABLED` also samples `UnitName("boss1target")` on the next frame (`parser.lua:5207-5217`), and `combatTicker` reads `UnitHealth("boss1")` each second while `encounter_table.start` is set (`util.lua:1255-1259`).
- No `INSTANCE_ENCOUNTER_ENGAGE_UNIT` in `Details/core/*` (grep: zero); no `UnitClassification` in the death/boss path.

**REUSABLE MECHANISM**
- Alias the three death tokens to one handler (all three loggers).
- Attribute by **dst** — the dead unit is `dst`; `src` is empty on a death row (Recount passes `nil` as source `Tracker.lua:781`; Skada Deaths filters on `dst_is_interesting_nopets` `Deaths.lua:729`; Details keys `targetName`/`targetSerial`). Guard `not dstName` first (Details `:4122`).
- Keep the pre-death ring buffer cheap and only **assemble on death** (Details `:4190-4192`; Recount defers assembly 2 s `:2110`).
- Skada's log-only boss-kill test: **remember the boss's creature id when the segment is flagged, then treat `death_events[eventtype] and id == GetCreatureId(dstGUID)` as the kill** (`Core.lua:4029`). For a listener that already knows the named unit, that reduces to a GUID (or name) equality on a death row.
- Details' `boss1..N` + `UnitGUID` scan (`control.lua:192-213`) is the only unit-token confirmation path in the three; note it is a **fallback**, run on a timer, not on every event.

**POSTURE NOT TO INHERIT**
- Feign-death checks by passing a **name as the unit token** (`UnitIsFeignDeath(victim)` Recount `:2065`, Skada `:261`, Details `:4144`) — meter-era convenience; a one-unit listener knows its unit token or GUID.
- Static creature-id lists (LibBossIDs, `boss_ids`) as the definition of "boss" — a Cataclysm list (Recount) or a per-zone table (Details) is content policy, not mechanism, and each decoder in §3 slices the GUID differently.
- Skada core's `srcFlags` test on `UNIT_DIED` for the wipe counter (`Core.lua:3893`) — copying it would test the wrong side of a death row.
- Recount's name-keyed combatant table (`dbCombatants[victim]`) with pet-name rewriting — a display model, not an identity model.

---

## 4. COST BOUNDING

### Recount
- **No per-event budget, no batching, no deferred queue.** Every non-quick-exited event is processed synchronously to completion inside `CombatLogEvent` (`Recount/Tracker.lua:977-1021`); the only deferral is the 2 s death-log assembly (`:2110`).
- **Gating, cheapest first**: `GlobalDataCollect`/`CurrentDataCollect` (`:978`) → `QuickExitEvents[eventtype]` (`:982`) → flag retention (`:993-998`). `CurrentDataCollect` is a zone×group policy flag set by `Recount:SetZoneGroupFilter` (`Recount/zonefilters.lua:50-66`, `Recount.CurrentDataCollect = true|false`) driven from `DetectInstanceChange` on `ZONE_CHANGED_NEW_AREA` / `PLAYER_ENTERING_WORLD` (`Recount/Recount.lua:2032-2033`; `Recount/deletion.lua:11-58`).
- **"Only in combat" is a recording policy, not a registration policy**: `RecordCombatOnly` is checked inside the damage/heal handlers (`Tracker.lua:1543-1547` `if not Recount.InCombat and Recount.db.profile.RecordCombatOnly then … Recount:PutInCombat()`), and CLEU stays registered out of combat. Deaths ignore it (`:2019-2022`).
- Logging is turned OFF only by `Recount:OnDisable` → `UnregisterAllEvents()` (`Recount.lua:2057`), or by the collection flags above (handler still fires, returns at `:978`).
- **Per-second housekeeping** on a repeating AceTimer: `Recount:ScheduleRepeatingTimer("TimeTick",1)` (`Recount.lua:2024`); `TimeTick` (`:1629-1735`) does combat-exit checking (`:1637-1639`), sets `Recount.CurTime`/`UnitLockout` (`:1640-1641`), and — only when time-data filters are on (`Recount.TickTimeData`, `:1618-1627`) — walks **every combatant** to fold their `TimeWindows` (`:1655-1725`), deleting idle unknowns after 30 s (`:1709-1717`) and old time-data every 10 s (`:1731-1733`).
- **Memory**: a global recycled-table pool — `Recount:GetTable()` / `Recount:FreeTable(t)` / `FreeTableRecurse` (`Recount.lua:2068-2147`), with a linear duplicate check on free (`:2079-2083`) and a warning if a recycled table is non-empty (`:2128`). Combatants are name-keyed tables in `Recount.db2.combatants` (SavedVariables), i.e. **memory scales with distinct names seen** until deletion policies fire (`deletion.lua`, `Recount:DeleteOldTimeData` `:1820-1839`).
- GUID caching: only the player's own (`MatchGUID`, `Tracker.lua:385-392`) and pet/guardian owner maps (`AddPetCombatant`, `Recount.lua:1313`).

### Skada
- **No per-event budget, no batching.** All work synchronous in `Skada:CombatLogEvent` (`Skada/Core/Core.lua:3844-4033`); the callback list per subevent (`combatlog_events[eventtype]`) is walked in full each event (`:3927`).
- **Gating**: `disabled or self.testMode` (`:3846`) → `ignored_events` (`:3849`) → `if self.current then` (`:3882`) — outside a segment only the tentative-start block (`:3854-3874`) and `SPELL_SUMMON` (`:3877`) run. So out-of-combat cost ≈ two table lookups + a flag test on 5 damage subevents.
- **Registration-level OFF**: `Skada:SetActive(false)` with `hidedisables` → `self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")` (`:1305-1310`, also sets `disabled = true`); `CheckZone` calls `SetActive(false)` in PvP when `hidepvp` (`:2529-2535`). This is the only one of the three that **unregisters CLEU as a runtime policy**.
- **Segment-end**: `EndSegment` cancels the display and tick timers (`:3579-3592`) and schedules `CleanGarbage` at +5 s (`:3594`) — `collectgarbage("collect")` only when `memorycheck` and `not InCombatLockdown()` (`:3346-3351`; the comment above it says "collect" "blocks all execution for too long", yet the body calls it).
- **Memory check**: `Skada:CheckMemory` (`:3332-3342`) `UpdateAddOnMemoryUsage(); GetAddOnMemoryUsage("Skada")` vs `self.maxmeme * 1024`, notify if high — scheduled once at +3 s after enable (`:3264`).
- **Table pool**: `local new, del, clear = Skada.TablePool("kv")` (`:61`) → `LibCompat-1.0.lua:205-247`: weak-keyed pool, `new()` = `next(pool) or {}`, `del(t)` wipes and re-pools; the Deaths module builds/frees log rows with it (`Deaths.lua:49`, `:99`, `:235`).
- **Roster/GUID caches**: `players[guid] = unit`, `pets[guid]` filled by `Skada:CheckGroup` (`Core.lua:2497-2503`), **throttled to once per 0.5 s** (`:2488-2495` `if lastCheckGroup and (checkTime - lastCheckGroup) <= 0.5 then return end`); roster events bucketed at 0.25 s via AceBucket (`:3240` `RegisterBucketEvent({"PARTY_MEMBERS_CHANGED","RAID_ROSTER_UPDATE"}, 0.25, "UpdateRoster")`).
- **Display refresh** decoupled from events: `update_timer = ScheduleRepeatingTimer("UpdateDisplay", updatefrequency or 0.5)` (`:3836`); `tick_timer = ScheduleRepeatingTimer("Tick", 1)` (`:3837`) for combat-exit polling.

### Details
- **No per-event budget, no batching, no deferral** on the CLEU path (`Details/core/parser.lua:6087-6094`); handlers set `need_refresh` flags (`:702` `_current_damage_container.need_refresh = true`) and **windows redraw on their own ticker**, not per event.
- **Gating by absence**: disabled capture classes remove tokens from `token_list` (`:4556-4612`), so an ignored subevent costs one hash miss after the tuple unpack. Within handlers `_in_combat` (a file-local mirror of `Details.in_combat`, `:326`, refreshed by `Details:UpdateParser`-family at `:6479`) gates the heavy branches (`:658`, `:1947`, `:2077`, `:4129`, `:4151`).
- **Alt parser for out-of-combat** exists — `OnParserEventOutOfCombat` (`:6121-6130`) dispatches only `SPELL_SUMMON`, `SWING_DAMAGE`, `SPELL_DAMAGE` (`out_of_combat_interresting_events` `:6115-6119`, the damage two only for `IS_GROUP_OBJECT` sources `:6106-6113`) and a `SPELL_AURA_APPLIED/REFRESH` source-cache — but the swap driver is short-circuited (`gears.lua:789` `do return end`; `checkForGroupCombat_Ticker` `:760-778` unreachable). Net: **this build parses everything, always** through `OnParserEvent`.
- **Per-second tickers**: `combatTicker` (`Details/core/util.lua:1249-1308`, `Details.Schedules.NewTicker(1, combatTicker)` `:1314`) started by `StartCombat` (`control.lua:369`) — polls `InCombatLockdown()`, `UnitAffectingCombat("player")`, then every `raidN`/`partyN` from cached unit-id arrays (`:1281-1296`, ids pre-built at `boot.lua:1305-1310`), and ends combat when nobody is (`:1305-1306`). `TimeMachine.Ticker` (`timemachine.lua:53-63`) refreshes `_tempo` and pauses actor activity clocks idle > 10 s (`:39-48`).
- **Garbage collector**: own scheduler `Details222.GarbageCollector` — `intervalTime = 300`, `NewTicker(300, RestartInternalGarbageCollector)` (`Details/startup.lua:249-251`); `Details:ClearParserCache` wipes all parser lookup caches at combat end / GC restart (`parser.lua:6207-6219`, comment "called when restaring the garbage collector, on some options change, at the end of a combat").
- **Actor caches**: `damage_cache[serial]`, `damage_cache_pets[serial]`, `damage_cache_petsOwners[serial]`, `healing_cache`, `misc_cache[name]`, `npcid_cache`, `enemy_cast_cache` (`:707`, `:6148-6150`, `:6207-6218`) — GUID/name → actor object, rebuilt per combat.
- **Death-log ring buffer** sized 16 (`:332`), per-name, index-recycled (`:4209-4236`).

**REUSABLE MECHANISM**
- **Registration-level OFF as policy** (Skada `SetActive`, `Core.lua:1305-1316`): when the addon has nothing to listen for, `UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")` rather than early-return; re-register on arm. For a listener that is "only while armed", this is the whole cost model.
- Table-lookup gating where an **absent key means ignore** (Details `token_list`).
- Poll group-combat state on a **1 s ticker started at segment start and cancelled at segment end** (Skada `tick_timer` `:3837`/`:3584-3587`; Details `combatTicker` `util.lua:1310-1321`), never per event.
- Cheap unit-id arrays pre-built once (`Details/boot.lua:1305-1316` `"raid"..i`, `"boss"..i`) instead of string concatenation in loops.
- Skada's throttle idiom for roster scans (`GetTime()` delta ≤ 0.5 → return, `Core.lua:2491-2495`).

**POSTURE NOT TO INHERIT**
- Always-on CLEU with policy checks inside the handler (Recount `:978`; Details this build) — the meter *wants* to see everything; an armed listener does not.
- Per-second full-combatant walks (Recount `TimeTick` `:1655-1725`) and per-combat cache rebuilds (Details `ClearParserCache`) — meter-scale bookkeeping.
- Global table pools with linear duplicate scans (Recount `FreeTable` `:2079-2083`) — cost proportional to pool size on every free.
- `collectgarbage("collect")` on a timer (Skada `:3348`) — a frame hitch policy, not a listener's business.
- SavedVariables-resident hot data (Recount `db2.combatants`) — persistence bleeding into the hot path.

---

## 5. TIME

### Recount
- **Three clocks**, each for a distinct purpose:
  - `time()` (unix seconds) → `Recount.CurTime` set every `TimeTick` (`Recount/Recount.lua:1634,1640`; also at init `:1954`) — the **coarse activity clock**: `SetActive` stamps `who.LastActive=Recount.CurTime` (`Tracker.lua:1023-1027`), `DeathLog.DeathAt=Recount.CurTime` (`:2133`), `UnitLockout=Time-5` (`Recount.lua:1641`), fight windows `Recount.db2.CombatTimes[…]={Recount.InCombatT,Time,…}` (`:1797`), idle deletion (`:1712`).
  - `GetTime()` (session float) → sub-second deltas: `AddTimeEvent` active-time accrual (`Tracker.lua:1035-1045`, capped at 3.5 s per event), death ring-buffer stamps `who.LastEventTimes[…]=GetTime()` (`:1073`) and death time `timeofdeath = GetTime()` (`:2076`), double-death window (`:2077-2079`), extra-attack proc timeout (`:1570`), `Recount.InCombatT2=GetTime()` for time-since-pull on the death graph (`Recount.lua:1740`; `Tracker.lua:2168`).
  - the **CLEU `timestamp`** → passed through to handlers but used only by the absorb-guess heuristic (`AddGuessedAbsorbData(... timestamp)` `:413-416`, `local last_timestamp` `:409`); **not** used for segmenting or death timing.
  - `date("%H:%M:%S")` for human-readable fight labels (`Recount.lua:1741`, `:1797`).

### Skada
- **Two clocks, deliberately paired** on every accepted event: `Core.lua:3909-3910` `self.current.last_action = time(); self.current.last_time = GetTime()` — `last_action` (unix) for wall-clock stamps and set bookkeeping (`starttime`/`endtime`, `EndSegment` `curtime = time()` `:3509`, `StopSegment` `:3599`, `set.time = max(1, endtime - starttime)` `:3617`), `last_time` (GetTime) for intra-fight deltas.
- Deaths use both: `deathlog.time = set.last_time or GetTime()` (delta base) and `deathlog.timeod = set.last_action or time()` (display, `date("%H:%M:%S", deathlog.timeod)` `Deaths.lua:370`) (`Deaths.lua:227-228`); pre-death rows keep `log.time = set.last_time or GetTime()` (`:64`).
- CLEU `timestamp` is received (`:3844`) and **forwarded to callbacks unchanged** (`:3982`) but the core never reads it for timing (it does pass it in `COMBAT_PLAYER_ENTER` `:3888`).
- Throttles use `GetTime()` (`:2491`).

### Details
- **Cached unix second `_tempo`**: `local _tempo = time()` (`parser.lua:30`; also `control.lua:5`, `boot.lua:275`), refreshed **once per second** by `Details222.TimeMachine.Ticker` (`timemachine.lua:53-56` `_tempo = _time(); Details._tempo = _tempo; Details:UpdateGears()` → `Details:UpdateParser()` `parser.lua:6144-6146` copies it into the parser's upvalue). Handlers stamp `sourceActor.last_event = _tempo` (`:815`, `:1100`, `:1256`, …) — **no clock call per event**; DoT-restart rule `Details.last_combat_time + 10 < _tempo` (`:694`).
- `GetTime()` for elapsed/encounter windows: `encounter_table.start = GetTime()` (`:5074`), `["end"] = GetTime()` (`:5120`), `CombatStartedAt/CombatEndedAt = GetTime()` (`:5253`, `:5557`), death `combatElapsedTime = GetTime() - _current_combat:GetStartTime()` (`:4357`), ENCOUNTER debounce windows (`:5020` +10 s, `:5115` +15 s), `Details.LatestCombatDone = GetTime()` (`:5554`).
- The CLEU `time` argument is **passed as `time` into every handler** (`:6092`) and used as the row stamp in the death ring buffer (`eventTable[4] = time --unix time` `:4200`; window test `recordedEvents[i][4]+_amount_of_last_events > time` `:4218`) and in `enemy_cast_cache[time]` (`:4248-4261`) — Details is the one of the three that **uses the log timestamp as data**.
- Wall clock for records: `unixtime = time()` in boss tables (`control.lua:127`, `:152`).

**REUSABLE MECHANISM**
- **`GetTime()` for every delta/window; `time()` only for a human label** (Skada's pairing `Core.lua:3909-3910` is the cleanest statement of it).
- Cache the coarse second in an upvalue refreshed by a 1 s ticker when many events need "roughly now" (Details `_tempo`) — zero clock calls on the hot path.
- Treat the CLEU `timestamp` as **event data** (ordering, ring-buffer windows — Details `:4218`), not as the addon's clock; none of the three drives segment start/end from it.

**POSTURE NOT TO INHERIT**
- Recount's three-clock split with `time()` as the *primary* activity clock (`CurTime`) — 1 s granularity leaks into `UnitLockout`, idle deletion, and fight-window arithmetic (`abs(Time-Recount.InCombatT)>3` `Recount.lua:1796`).
- Stamping SavedVariables with wall-clock fight windows (`CombatTimes`) — persistence policy.

---

## 6. SELF-MEASUREMENT

### Recount
- **No CPU/profiling readout** (grep `GetAddOnCPUUsage|debugprofilestop|UpdateAddOnCPUUsage` over `Recount/*.lua`: zero). Only diagnostic prints: table-pool sanity (`Recount.lua:2128` "WARNING! For some reason there is … entries left"), `Recount:HowManyTables` (`:2136-2143`), `DPrint` debug lines (`Tracker.lua:1567`, `:1573`).
- Hot-path comments: `Tracker.lua:982` `-- Counter bursty combat log events we don't care about.`; `:871` `-- This is to allow modularity of the tracker code. Functions that are not registered to be handled will be quickexited.`; `:1612` `--Fight tracking purposes to speed up leaving combat` (the `LastFightIn` stamp); `:2102` `--We delay the saving of the event logs just in case more messages come later`; `roster.lua:51` `-- Elsia: Speed boost, yay.` (`UnitExists(name)` before a roster walk).

### Skada
- **Memory only**: `Skada:CheckMemory` → `UpdateAddOnMemoryUsage(); GetAddOnMemoryUsage("Skada")` (`Core.lua:3332-3342`), plus slash `memorycheck|memory|ram` (`:2245`); options `memorycheck = true` default (`Options.lua:105`). No CPU readout (grep zero).
- Comments on cost: `Core.lua:3344-3345` `-- this can be used to clear combat log and garbage.` / `-- note that "collect" isn't used because it blocks all execution for too long.`; `Deaths.lua:222` `-- saving this to total set may become a memory hog deluxe.`; `Core.lua:2490` `-- throttle group check.`; `Core.lua:3702` `-- list of combat events that we don't care about`.

### Details
- **Has an opt-in profiler**: `Details222.Profiling.ProfileStart/ProfileStop` are no-ops until `EnableProfiler()` swaps in `profileStartFunc/profileStopFunc` using `debugprofilestop()` and a per-function `{elapsed, startTime, runs}` cache (`Details/boot.lua:1360-1383`). `Details222.Perf.WindowUpdate` counters are reset on `ENCOUNTER_START` (`parser.lua:5016-5017`). Ad-hoc `debugprofilestop()` deltas in `control.lua:1563-1582` and `gears.lua:2858-2860`. A dead statistics hook remains commented in the damage path (`parser.lua:701` `--[[statistics]]-- _detalhes.statistics.damage_calls = …`).
- Hot-path comments: `parser.lua:4190-4192` (death log "made as fast as it can be", quoted in §3); `:325-335` "cache data for fast access during parsing" (the `_in_combat`, `_amount_of_last_events` upvalues); `:6206` on when caches are wiped; `control.lua:399` "if we don't have this infor right now, lets check in few seconds".
- `Details:PrintParserCacheIndexes()` (`parser.lua:6158-6196`) prints cache cardinalities on demand.

**REUSABLE MECHANISM**
- A **no-op-by-default profiler pair swapped in on demand** (Details `boot.lua:1376-1381`) — zero cost when off, `debugprofilestop()` deltas when on.
- A one-line "how big are my caches" dump (Details `PrintParserCacheIndexes`) for a listener's own tables.

**POSTURE NOT TO INHERIT**
- Measuring by `GetAddOnMemoryUsage` and nagging the user (Skada `CheckMemory`) — a symptom monitor for a data-accumulating meter, not for a listener that holds one unit.
- Chat prints inside the hot path (Recount `:1019`, `:2128`).

---

## 7. SEGMENTS — bracketing a fight from the log

### Recount — **log-in, poll-out**
- **START (from CLEU only)**: `Recount:PutInCombat()` (`Recount/Recount.lua:1737-1763`) is called from the damage/heal handlers when `not Recount.InCombat and RecordCombatOnly` and the row is not friendly-fire and either actor is grouped: `Tracker.lua:1543-1547`
  ```lua
  if not Recount.InCombat and Recount.db.profile.RecordCombatOnly then
      if (not FriendlyFire) and (Recount:InGroup(srcFlags) or Recount:InGroup(dstFlags)) then
          Recount:PutInCombat()
  ```
  (heal path `:1883`). `InGroup(flags) = band(flags, MINE+PARTY+RAID) ~= 0` (`Recount.lua:1302-1304`). No `PLAYER_REGEN_DISABLED` registration (grep `PLAYER_REGEN` in `Recount/*.lua` excluding `Libs/`: zero). `PutInCombat` stamps `InCombatT=CurTime`, `InCombatT2=GetTime()`, `InCombatF=date(...)`, resets `FightingWho=""`, `FightingLevel=0` (`:1738-1743`).
- **NAME**: the fight's opponent is decided as events arrive — `BossFightWhoFromFlags` (`Tracker.lua:1523-1533`): first hostile dst of a grouped src, overridden by any `IsBoss(victimGUID)` hit (`FightingLevel=-1`).
- **END (polled, 1 s)**: `TimeTick` (`Recount.lua:1637-1639`) → `CheckCombat` (`:1766-1775`) → `Recount:CheckPartyCombatWithPets()` (`Recount/roster.lua:14-42`: `UnitAffectingCombat` over `raidN`/`raidpetN`, `partyN`/`partypetN`, then `"player"`) → if none, `Recount:LeaveCombat(Time)` (`:1778-1818`).
- **CLOSE RULES** in `LeaveCombat`: `:1786-1789` `Recount.InCombat=false; if (Recount.FightingWho=="") then return end` — a fight with no named opponent is not archived; `:1796` `if abs(Time-Recount.InCombatT)>3 then` archive `{InCombatT, Time, InCombatF, date, FightingWho}` into `db2.CombatTimes`, `Recount.Fights:MoveFights()`, `FightNum+1`; else `Recount.Fights:CopyCurrentFights()` (fights ≤ 3 s are folded, not archived). `MoveFights` (`Recount/Fights.lua:31-49`) rotates per-combatant `Fight1..MaxFights` and honours `SegmentBosses` (only `FightingLevel == -1` fights get their own slot).
- Per-combatant participation is a stamp, not a scan: `LastFightIn = Recount.db2.FightNum` on every touch (`Tracker.lua:1613`, `:1735`, `:2071`, …); `MoveFights` copies only those (`Fights.lua:41`).

### Skada — **event-or-log-in, poll-out, with stop/resume**
- **START**: two paths —
  1. `PLAYER_REGEN_DISABLED` → `Skada:StartCombat()` if no current segment (`Skada/Core/Core.lua:3474-3479`).
  2. **Tentative combat** from the log (`tentativecombatstart` option): on a `trigger_events` damage row (`:3720-3726`) with an interesting src or dst and `srcGUID ~= dstGUID`, create `self.current`, arm a **1 s cancel timer** (`:3867-3871` `self.current = nil` on expiry), `tentative = 0`; each accepted callback increments (`:3970-3972`), and **at 5 accepted events** the segment is confirmed (`:3973-3978` `if tentative == 5 then … self:StartCombat()`).
- `StartCombat` (`:3775-3842`): resets the wipe counters (`death_counter = 0; starting_members = GetNumGroupMembers()`), ends a running segment if any (`:3784-3787`), creates `self.current`, starts `update_timer` (0.5 s) and `tick_timer` (1 s) (`:3836-3837`).
- **First-event flagging**: `:3884-3889` on the first CLEU row inside a segment `self.current.started = true`, `self.current.type = insType`, `SendMessage("COMBAT_PLAYER_ENTER", ...)`.
- **NAME**: `:3988-4002` first hostile counterpart (`band(dstFlags, REACTION_FRIENDLY) == 0` from an interesting src, or vice-versa); overridden by `IsEncounter` boss hit (`:4012`); PvP/arena take `GetInstanceInfo()` (`:3989-3996`).
- **END (polled)**: `Skada:Tick()` (`:3767-3773`) `if not disabled and self.current and not InCombatLockdown() and not IsGroupInCombat() and self.insType ~= "pvp" and self.insType ~= "arena" then self:EndSegment()`. `IsGroupInCombat` = `UnitAffectingCombat` over the LibCompat unit iterator (`LibCompat-1.0.lua:368-375`).
- **STOP vs END**: `StopSegment` (`:3597-3635`) freezes `endtime`/`time` but keeps the segment open, then **registers `PLAYER_REGEN_ENABLED` only now** (`:3632`); the `PLAYER_REGEN_ENABLED` handler unregisters itself and calls `EndSegment` if stopped or nobody in combat (`:3461-3472`, comment `:3460` "never initially registered."). Autostop-on-wipe triggers `StopSegment` from the death counter (`:3892-3899`); `ResumeSegment` (`:3637-3672`) undoes it.
- **CLOSE RULES**: `EndSegment` (`:3504-3595`) → `ProcessSet` keeps a set only if `set.mobname ~= nil and curtime - set.starttime >= minsetlength (5)` and (`onlykeepbosses` off or `gotboss`) (`:230-232`); boss fights may be pinned (`alwayskeepbosses` `:238-240`); `EndSegment` also drops `players[i].last`, adds `current.time` to total if ≥ `minsetlength` (`:3543-3545`), and schedules GC (+5 s).
- **Boss success** from the log alone: §3 (`:4029-4030`), else BigWigs/DBM (`:3287-3330`).

### Details — **event-or-log-in, poll-out, encounter-event override**
- **START**: three entries into `Details222.StartCombat` (`Details/core/control.lua:318-438`):
  1. From CLEU inside `parser:spell_dmg` (`Details/core/parser.lua:658-699`): when `not _in_combat`, a **non-periodic** damage row where the grouped side is **actually in combat by API** — `(band(sourceFlags, AFFILIATION_GROUP) ~= 0 and UnitAffectingCombat(sourceName)) or (band(targetFlags, AFFILIATION_GROUP) ~= 0 and UnitAffectingCombat(targetName)) or (not Details.in_group and band(sourceFlags, AFFILIATION_GROUP) ~= 0)`; blacklist `spells_cant_start_combat[spellId]` for the player (`:668-670`); a **DoT can start combat only for the player and only if the last combat ended > 10 s ago** (`:688-697` `Details.last_combat_time + 10 < _tempo`). Heals have a parallel gate (`:2077`).
  2. `PLAYER_REGEN_DISABLED` (`:5207-5237`): bumps `combat_id_global`, and calls `Details222.StartCombat()` **only** in BG without the server parser or when damage capture is off (`:5228-5237`); otherwise it lets the log start the segment. Also samples `boss1target` next frame (`:5208-5217`).
  3. `ENCOUNTER_START` (`:5011-5092`): debounced against a recent `ENCOUNTER_END` (`:5019-5022`, 10 s), **ends a non-boss combat in progress** (`:5025-5027` `if (_in_combat and not Details.tabela_vigente.is_boss) … Details:SairDoCombate()`), fills `encounter_table` (`:5066-5089`), sends `COMBAT_ENCOUNTER_START` (`:5092`).
- `StartCombat`: `Details.in_combat = true` (`control.lua:354`), new combat object with `SetDateToNow` (`:357`), `Details:StartCombatTicker()` (`:369`), wipes per-combat caches (`:373-380`), adopts `encounter_table` if `start >= GetTime() - 3` (`:394-397`) else schedules `ReadBossFrames` at +1/+30 s (`:400-403`), fires `COMBAT_PLAYER_ENTER` (`:426`).
- **END (polled, 1 s)**: `combatTicker` (`Details/core/util.lua:1249-1308`): stays in combat if coach server, BG server parser, arena, `InCombatLockdown()`, `UnitAffectingCombat("player")`, or any `raidN`/`partyN` in combat; otherwise `Details:StopCombatTicker(); Details:SairDoCombate()` (`:1305-1306`).
- **END (event)**: `PLAYER_REGEN_ENABLED` (`parser.lua:5548-5599`): stamps `CombatEndedAt`, `TotalElapsedCombatTime`; **solo → end immediately** (`:5563-5565` `if (not IsInGroup() and not IsInRaid()) then … Details:SairDoCombate()`); grouped → wait 1 s then check `UnitAffectingCombat` across the group (`:5568-5597`), plus `C_Timer.After(10, checkIfEncounterIsDone)` (`:5560`, `:5310-5340`).
- **END (encounter)**: `ENCOUNTER_END` (`:5098-5165`) debounced 15 s (`:5114-5119`), sets `encounter_table["end"] = GetTime()`, marks kill/wipe and calls `SairDoCombate(bossKilled, {...})` (`:5127-5133`); if the combat had already ended within 2 s it back-fills the segment's start/end to the encounter window (`:5136-5138`).
- **CLOSE RULES**: `SairDoCombate` (`control.lua:455-…`) is idempotent (`bIsClosed` `:467-470`), sets `Details.last_combat_time = _tempo` (`:480`), tries `FindBoss()` if none known (`:492-494`), and drops segments shorter than `minimum_combat_time` (tutorial text `:277` "combat ignored: less than 5 seconds").

**REUSABLE MECHANISM**
- **Open on the log, close on a 1 s poll of `UnitAffectingCombat` across the group** — all three do exactly this (Recount `roster.lua:14-42`; Skada `Tick` `:3767`; Details `combatTicker` `util.lua:1249`). None trusts `PLAYER_REGEN_ENABLED` alone for the close; Skada does not even register it until a stop (`:3460`, `:3632`), Details waits 1 s and re-checks (`:5568`).
- Details' **"start only if the API agrees"** gate — a damage row starts combat only when `UnitAffectingCombat(sourceName|targetName)` for the grouped side (`parser.lua:661-663`) — and the **DoT cool-off** (`:694`) so trailing periodic ticks do not reopen a fight.
- Skada's **tentative segment**: create on first trigger, cancel after 1 s unless N (=5) accepted events confirm (`:3854-3874`, `:3970-3979`) — a bounded, log-only "is this a fight?" filter.
- Recount's **`LastFightIn` stamp** (`Tracker.lua:1613`) — mark participation with the current fight number instead of scanning at close.
- Debounce encounter-edge events against each other by `GetTime()` windows (Details `:5019-5022`, `:5114-5119`).
- **Discard fights shorter than a floor** (Recount 3 s `Recount.lua:1796`; Skada `minsetlength` 5 s `:232`; Details `minimum_combat_time` 5 s).

**POSTURE NOT TO INHERIT**
- Recount's requirement that a fight have a **named opponent** before it counts (`FightingWho == ""` → return, `Recount.lua:1787`) — display policy.
- Skada's stop/resume/wipe-percentage machinery (`:3597-3672`, `:3892-3899`) — a segment editor, not a bracket.
- Details' three-way start (log / regen / ENCOUNTER_START) with the ENCOUNTER path **ending** a running combat (`:5025-5027`) — encounter-journal semantics; on a listener that already knows its unit, the bracket is "armed → death row seen".
- Any of the three's segment **archives** (Recount `MoveFights` rotation, Skada `ProcessSet`, Details segment tables) — persistence for a meter.

---

## 8. COMPARISON TABLE

| Axis | Recount (`Recount/`) | Details (`Details/`) | Skada (`Skada/`) |
|---|---|---|---|
| **Registration** | AceEvent method `RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED","CombatLogEvent")` `Recount.lua:2043`; shared AceEvent frame; **varargs + pre-4.1 tail-call shim** `Tracker.lua:986-991` | Own frame `boot.lua:288`, `parser_frame:RegisterEvent(...)` `startup.lua:289`, `SetScript("OnEvent", OnParserEvent)` `parser.lua:6141`; **`CombatLogGetCurrentEventInfo(...)` with varargs forwarded** `parser.lua:6088` (fork behaviour unverified here; repo record says bare call is furniture) | AceEvent method `RegisterEvent(..., "CombatLogEvent")` `Core.lua:3237`; **classic varargs, no hideCaster** `Core.lua:3844`; **runtime Unregister/Register** in `SetActive` `:1310/:1316` |
| **Dispatch** | `EventParse[eventtype]` table → handler `Tracker.lua:1014-1017`; ~50 keys `:792-845` | `token_list[token]` table → handler `parser.lua:6089-6093`; keys added/removed per capture class `:4556-4678` | `combatlog_events[eventtype]` table → **set of (callback, flags)** with per-callback interest negotiation `Core.lua:3906-3984`; modules subscribe via `RegisterForCL` `:3744` |
| **First early-exit** | `GlobalDataCollect`/`CurrentDataCollect` `:978`, then `QuickExitEvents[eventtype]` `:982`, then flag retention on src+dst `:993-998` | none before the table lookup; disabled tokens are simply absent (`:6089`); handler-local: `sourceSerial == ""`+pet flags `:486`, `not targetName` `:520` | `disabled or testMode` `:3846`, then `ignored_events[eventtype]` `:3849`, then `if self.current` `:3882` |
| **Death detection** | `UNIT_DIED/UNIT_DESTROYED/UNIT_DISSIPATES → UnitDied → AddDeathData(nil, dstName, …, dstGUID, dstFlags)` `:780-782`; keyed by **dstName** `:2056`; feign via `UnitIsFeignDeath(name)` `:2065`; 2 s deferred log `:2110`; not combat-gated `:2019-2022` | `UNIT_DIED/UNIT_DESTROYED → parser.dead` `:4677-4678`; pet removal by **targetSerial** `:4117`; actor by **targetName** `:4127`; frag vs player-death fork on `targetFlags` `:4129/:4144-4152`; requires `_in_combat` `:4151` | core: wipe counter on `UNIT_DIED` testing **srcFlags** `:3893`; Deaths module: `RegisterForCL(UnitDied, 3 tokens, {dst_is_interesting_nopets})` `Deaths.lua:773-779` → `log_death(set, dstGUID, dstName, dstFlags)` `:260-264`; SoR aura 27827 as death `:266-270` |
| **Boss detection** | **LibBossIDs creature-id list**, `GUID:sub(7,10)` `Tracker.lua:352-356`; sets `FightingWho`/`FightingLevel=-1` `:1523-1533`; no unit tokens | **ENCOUNTER_START** table `parser.lua:5011-5092` → else **`boss1..9` + `UnitGUID` → per-zone `boss_ids`** `control.lua:192-213` (timers +1/+30 s) → else actor-serial scan at end `:217-266`; `select(6, strsplit("-", guid))` decoder `util.lua:417` | `IsEncounter/IsBoss` → `creatureToBoss[GetCreatureId(guid)]` with **LibBossIDs fallback** `Functions.lua:387-414`, `Tables.lua:15-19`; `guid:sub(9,12)` `LibCompat:444`; once per dst name per segment `Core.lua:4004-4027`; **log-only kill = death row of that creature id** `:4029-4030`; BigWigs/DBM preferred if present |
| **Cost bounding** | none per event; policy flags in-handler; 1 s `TimeTick` full-combatant walk `Recount.lua:1629-1735`; recycled-table pool with linear dup check `:2068-2147`; SV-resident combatants | none per event; capture-class token removal; **alt out-of-combat parser exists but swap disabled** `gears.lua:789`; 1 s `combatTicker`; 300 s GC ticker `startup.lua:249-251`; per-combat cache wipe `parser.lua:6207` | none per event; **CLEU unregistered when hidden/PvP** `Core.lua:1305-1310`; out-of-segment work ≈ 2 lookups; 0.5 s display timer, 1 s tick; roster scan throttled 0.5 s `:2491`; weak table pool `LibCompat:205-247`; `collectgarbage` +5 s after segment `:3594` |
| **Segment bracketing** | **open** on grouped non-FF damage/heal row `Tracker.lua:1543-1547`; **close** by 1 s poll `CheckPartyCombatWithPets` `roster.lua:14-42`; archive only if `FightingWho ~= ""` and > 3 s `Recount.lua:1786-1816` | **open** on non-periodic damage row where the grouped side is `UnitAffectingCombat` `parser.lua:658-699` (DoT only after 10 s cool-off) / REGEN_DISABLED in narrow cases / ENCOUNTER_START; **close** by 1 s `combatTicker` `util.lua:1249-1308`, REGEN_ENABLED (+1 s recheck) `parser.lua:5548-5599`, ENCOUNTER_END `:5098-5165`; floor 5 s | **open** on `PLAYER_REGEN_DISABLED` `:3474` or **tentative** (5 accepted events within 1 s) `:3854-3874/:3970-3979`; **close** by 1 s `Tick` `:3767-3773`; `PLAYER_REGEN_ENABLED` registered only after `StopSegment` `:3632`; keep if `mobname` and ≥ `minsetlength` `:230-232` |

**REUSABLE MECHANISM (whole-table read)**
- Positional-varargs handler on a private frame; three death tokens → one function; **dst is the dead unit**; open on the log, **close on a 1 s `UnitAffectingCombat` poll**; unregister CLEU when not armed (Skada `SetActive`).
- Skada's log-only "the flagged creature died" test (`Core.lua:4029`) is the one line in 60k that answers "did the named unit die" from CLEU alone.

**POSTURE NOT TO INHERIT (whole-table read)**
- Everything that exists because a meter must attribute *every* actor: retention filters, name-keyed actor tables, creature-id boss lists with divergent GUID slicing, segment archives, memory nags, GC timers, and per-second full walks.
- Details' `CombatLogGetCurrentEventInfo(...)` reliance and Recount's build-shim: both are compatibility debt, not mechanism.
