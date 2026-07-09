-- COA_GuardianPlates - EnemyPlates.lua
--
-- BRAND PIVOT (v3.1, 2026-07-08) - Battlewrath: "The brand, I think, should
-- be 'State plates', and threat plate becomes enemy plate. With the threat
-- capability one sub-mode. Much like healer is a sub-node of Friendly
-- plates. A bit of leg work now but puts us in good stead."
--
-- Renamed from ThreatPlates.lua/ns.Threat to EnemyPlates.lua/ns.Enemy
-- accordingly. This file is now framed as "Enemy Plates" - the hostile-
-- facing counterpart to "Friendly Plates" - and threat coloring (the whole
-- capability this file has held since v2.0) is reframed as its first
-- SUB-MODE, not the whole of what this module is. The parallel is
-- deliberate: FriendlyPlates.lua's suppression is its main behaviour with
-- healer mode as a sub-mode nested inside it; EnemyPlates.lua's threat
-- coloring is likewise just its first sub-mode, not a synonym for the
-- module. This leaves explicit room for future enemy-facing sub-modes
-- without another rename - the two already-scoped future capabilities
-- (see Core.lua's task history: "Needs-action highlight" and "DPS
-- threat-cue") are exactly the kind of thing that would slot in here as
-- siblings of threat coloring, each gated by their own DB flag, all still
-- living under the one "Enemy Plates" umbrella.
--
-- This file's OWN scope/functionality is otherwise unchanged by the pivot
-- - purely a naming/framing change (ns.Threat -> ns.Enemy, `/coatp` ->
-- `/coaep`, options panel re-titled and re-parented to the new "COA State
-- Plates" brand). Overall addon brand ("COA Guardian Plates" -> "COA State
-- Plates") is cosmetic-only per Battlewrath's explicit call: the AddOns
-- folder name, COA_GuardianPlatesDB SavedVariables key, and .toc filename
-- all stay as-is, so existing saved settings and the deploy path are
-- unaffected. See FriendlyPlates.lua for the brand-level framing; this
-- file only needed the Threat->Enemy half of it.
--
-- Hostile-plate-facing capabilities only, per the v3.0 module split (see
-- Core.lua's top doc comment for the full split rationale). This file owns
-- threat coloring - an animated glow border around a hostile unit's health
-- bar based on the player's own threat standing, plus an opt-in fill
-- channel for dungeons/raids - `/coaep`, and its own "Enemy Plates"
-- options sub-panel nested under the main "COA State Plates" category
-- (the addon's outward brand identity - see FriendlyPlates.lua for why the
-- internal friendly-facing module itself is named "Friendly," not
-- "Guardian"). It never touches a plate's visual state directly - every
-- actual draw happens through Core's executor primitives (ns.SetGlow,
-- ns.ClearGlow, ns.SetHealthBarColor, ns.ClearHealthBarColor). Like
-- FriendlyPlates.lua, this file is signal/behaviour only and never authors
-- plate content.
--
-- THREAT COLORING (v2.0, 2026-07-08 - history) - first of three
-- capabilities picked from the nameplate-addon code review + role research
-- (Battlewrath's brief: capture what TurboPlates/Kui_Nameplates/etc. do
-- well, then build very light, independently-toggleable versions rather
-- than adopting any of their full option surfaces). Colors HOSTILE/enemy
-- nameplate health bars based on the player's own threat standing on that
-- unit, using UnitDetailedThreatSituation("player", unit) - a genuine
-- WotLK-era API (added in patch 3.0.2), not a modern-client backport like
-- the nameplate system itself.
--
-- Originally a tri-state (threatMode: 0=Off, 1=Smart, 2=Always On),
-- mirroring the shape TurboPlates/Kui_Nameplates both converged on.
-- "Smart" auto-detected a tank spec via real talent-point introspection
-- (IsTank(), ported from Kui_Nameplates' TankMode.lua). SUPERSEDED in v2.5
-- - Battlewrath confirmed CoA's classes are entirely custom (none of the 4
-- stock classes IsTank() checked - Warrior/Paladin/Druid/DeathKnight -
-- exist here), so UnitClass("player") never matched any branch and "Smart"
-- always silently resolved to DPS-view. Auto-detection was dropped in
-- favor of a manual "Tanking" checkbox - see the MIGRATION note below.
--
-- THREAT BORDER + INSTANCE FILL (v2.4) - WoW's health bar fill already
-- carries native meaning (red=enemy, green=friendly, grey=tap-denied/
-- tagged by someone else), and early threat coloring unconditionally
-- overwrote that same fill color. Restructured into two channels sharing
-- the same 3 configured colors: a border/glow (mirroring TurboPlates' own
-- live-proven target-glow technique) is the ALWAYS-ON signal everywhere -
-- it never touches the bar's own fill, so tag-grey/native color stays
-- readable underneath at all times. The fill-override behavior is an
-- opt-in "Instance Fill" checkbox (off by default - Battlewrath: "more
-- intrusive than a new boarder element"), and even when on, only takes
-- effect while IsInstanceFillZone() reports eligible instance content -
-- deliberately excludes arena/battleground: "Threat isn't really a
-- mechanic as it's player driven" in PvP, per Battlewrath.
--
-- MANUAL TANKING TOGGLE + SECURE-GLOW SUPPRESSION (v2.5) - "Smart"
-- auto-detection is gone (see above). threatMode is now a plain Off(0)/
-- On(1) toggle, and threatTanking manually picks the view. Separately: the
-- border/glow used to show for all three states, including "secure."
-- Battlewrath's observation: for whichever role reaches "secure," it's the
-- boring, expected default (a tank holding aggro correctly spends most of
-- a fight there) - a constant glow there doesn't drive behaviour, only the
-- transition to warning/danger does. ApplyThreatColorForUnit suppresses
-- the glow specifically for stateName == "secure". The FILL channel is
-- deliberately untouched by this - still paints all 3 states, so a tank
-- glancing across a dense pull in an instance still gets a steady
-- "everything's fine" color read at a glance; the glow is reserved for
-- outliers. Battlewrath: "being able to see stable colors and then the
-- single outliers is important in high density... but that's more boring
-- than glows everywhere. Boring is good here."
--
-- GROUP GATE (v2.6) - threat coloring only ever engages while IsInGroup()
-- is true. Solo, you're always the only possible threat generator on
-- whatever you're fighting - every state would read as "you have aggro,"
-- which isn't information, it's noise. Checked against TurboPlates' own
-- source first - it has no equivalent gate at all, it colors every solo
-- pull exactly like a group threat situation, so this is a genuine
-- improvement over it, not borrowed prior art. Deliberately keyed on
-- actual group membership, not zone/instance type (separate from, and
-- narrower than, IsInstanceFillZone, which still only governs the FILL
-- channel). KNOWN OPEN EDGE CASE, not solved here: a solo player's own
-- pet/guardian could in theory hold aggro independently even while solo.
--
-- ANIMATED GLOW (v2.7) - Battlewrath's live-test finding: "Currently it's
-- just the actual boarder. A bit too discrete when the HP bar is red." A
-- static solid-color edge blends into a similarly-saturated health bar.
-- Both TurboPlates and WeakAuras already embed LibCustomGlow-1.0 (the
-- standard shared WoW glow library); TurboPlates' own Castbars.lua uses its
-- PixelGlow effect for its cast-bar highlight - the closest real
-- comparison to our rectangular health-bar border. Motion reads clearly
-- regardless of what color sits underneath it. Now implemented via Core's
-- generic ns.SetGlow/ns.ClearGlow primitives (Battlewrath: "core as the
-- executor... one draw editing tool"), embedding our OWN copy of LibStub +
-- LibCustomGlow-1.0 rather than relying on TurboPlates'/WeakAuras'
-- already-loaded copy, so this keeps working even if both of those addons
-- are ever disabled.
--
-- MODULE SPLIT (v3.0) - this file used to be interleaved with friendly-
-- plate logic in one COA_GuardianPlates.lua. Now hostile-plate-only, per
-- Battlewrath: "Guardian stays as friend plate facing. Threat plate stays
-- about hostile plates." NOT YET DONE as part of this split (deliberately
-- deferred, per Battlewrath: "we do the seperation first. Then any further
-- development is self contained"): a combat-gate check
-- (UnitAffectingCombat) - currently a hostile unit that's simply standing
-- in the world, in combat with no one, still reads as "danger" under tank
-- view (isTanking is false for it, same as any other non-tanked unit).
--
-- RENAME (v3.0.1) - the friendly-facing sibling module (formerly
-- GuardianPlates.lua) was renamed to FriendlyPlates.lua/ns.Friendly per
-- Battlewrath: "Then threat plates is working against enemy plates. Both
-- are signal/behaviour only, and never author content." This file itself
-- needed no functional changes (it never referenced ns.Guardian), just
-- doc-comment cross-references updated to match.
--
-- ROLE AUTO-DETECT (v3.2, 2026-07-08) - Battlewrath: "I'd say let core.lua
-- build the player index/profile. And have everything be a consumer.
-- Instead of rebuilding per module." Core.lua now exposes ns.GetPlayerRole()
-- (TANK/HEALER/DAMAGER/NONE, sourced from UnitGroupRolesAssigned - only
-- populated for a Dungeon/Raid Finder-formed group, per confirmed research -
-- see Core.lua's own doc note for the full rationale, including why
-- spec-based inference was deliberately rejected). IsEffectivelyTanking()
-- below prefers that signal when the game actually has one, and only falls
-- back to the manual threatTanking checkbox when it doesn't (NONE) - see
-- the GetThreatColorForUnit doc block further down.
--
-- Usage:
--   /coaep on|off               -> threat-coloring sub-mode toggle.
--   /coaep tanking on|off       -> manually picks tank view (aggro =
--                                  boring/secure) vs DPS view (no aggro =
--                                  boring/safe). Only consulted when the
--                                  game has no LFG/LFR role for the player
--                                  - see the ROLE AUTO-DETECT note above.
--   /coaep instancefill on|off  -> also fills the health bar (not just the
--                                  glow) while inside eligible instance
--                                  content.
--   /coaep caution <pct>        -> tunes the Mob Aggro Cue's early-warning
--                                  threshold (default 80) - see the MOB
--                                  AGGRO CUE doc note further down.
--   /coaep status               -> prints current threat-coloring state.
--   /coaep options              -> opens the Enemy Plates options
--                                  sub-panel directly.
--
-- The render test rig (force a state onto your current target's plate for
-- testing) lives under Core's shared /coasp rendertest now, not here - see
-- Core.lua's RENDER TEST REGISTRY doc note and this file's own
-- ns.Enemy.RenderTestApply further down for the full reasoning.

local addonName, ns = ...

-- ---------------------------------------------------------------------
-- DB defaults / migration
-- ---------------------------------------------------------------------

COA_GuardianPlatesDB = COA_GuardianPlatesDB or {}

-- MIGRATION (v2.5) - threatMode used to be a 3-way Off/Smart/Always On
-- (0/1/2). "Smart" auto-detected a tank spec via UnitClass + talent points
-- on the 4 stock Wrath classes - Battlewrath confirmed CoA's classes are
-- custom (none of those 4 classes exist here), so UnitClass("player")
-- never matched any of them and IsTank() always returned false. "Smart"
-- was silently non-functional on this server from the moment it shipped:
-- it always resolved to DPS-view, for every class, regardless of what was
-- actually being played. Old value 2 (Always On) migrates to threatMode=1,
-- threatTanking=true - same intent as before. Old value 1 (Smart) migrates
-- to threatMode=1, threatTanking=false - matching what it was ACTUALLY
-- doing the whole time (permanent DPS-view), not what it claimed to do.
if COA_GuardianPlatesDB.threatMode == 2 then
    COA_GuardianPlatesDB.threatMode = 1
    if COA_GuardianPlatesDB.threatTanking == nil then
        COA_GuardianPlatesDB.threatTanking = true
    end
elseif COA_GuardianPlatesDB.threatMode == 1 then
    if COA_GuardianPlatesDB.threatTanking == nil then
        COA_GuardianPlatesDB.threatTanking = false
    end
end
if COA_GuardianPlatesDB.threatMode == nil then
    COA_GuardianPlatesDB.threatMode = 0
end
if COA_GuardianPlatesDB.threatTanking == nil then
    COA_GuardianPlatesDB.threatTanking = false
end

-- Instance Fill (v2.4) - off by default, per Battlewrath: "Instance fill
-- should be off by default, as it's more intrusive than a new boarder
-- element."
if COA_GuardianPlatesDB.threatInstanceFillEnabled == nil then
    COA_GuardianPlatesDB.threatInstanceFillEnabled = false
end

-- MOB AGGRO CUE (v3.3) - percentage threshold for the early-warning cue
-- below (see GetThreatColorForUnit's own doc note). 80 matches bdThreat's
-- own proven "warn" threshold (found in Battlewrath's addon reference
-- folder) rather than an invented number.
if COA_GuardianPlatesDB.threatCautionPct == nil then
    COA_GuardianPlatesDB.threatCautionPct = 80
end

local Print = ns.Print

-- User-configurable via 3 color pickers in the options panel (Battlewrath:
-- "make 3 color pickers for each state... so a DPS and Tank can define
-- what each state means to them"). These constants are the SEED/RESET
-- values - live reads come from COA_GuardianPlatesDB.threatColor{Secure,
-- Warning,Danger} instead. Naming stays state-based (secure/warning/
-- danger), not tank/non-tank, since GetThreatColorForUnit below already
-- flips which literal situation maps to which state depending on
-- threatTanking - a single stable color per state, not per role.
local THREAT_COLOR_DEFAULT_SECURE  = { r = 0.1, g = 0.9, b = 0.2 } -- holding aggro safely (tank view)
local THREAT_COLOR_DEFAULT_WARNING = { r = 1.0, g = 0.6, b = 0.0 } -- transitional / approaching threat cap
local THREAT_COLOR_DEFAULT_DANGER  = { r = 1.0, g = 0.1, b = 0.1 } -- lost aggro (tank view) / has aggro (non-tank view)

local function SeedThreatColorDefault(colorKey, default)
    if COA_GuardianPlatesDB[colorKey] == nil then
        COA_GuardianPlatesDB[colorKey] = { r = default.r, g = default.g, b = default.b }
    end
end
SeedThreatColorDefault("threatColorSecure", THREAT_COLOR_DEFAULT_SECURE)
SeedThreatColorDefault("threatColorWarning", THREAT_COLOR_DEFAULT_WARNING)
SeedThreatColorDefault("threatColorDanger", THREAT_COLOR_DEFAULT_DANGER)

-- LOOKUP HARDENING (v3.5.12, 2026-07-09) - Battlewrath: "The first cycle
-- failed. I had to go into color pickers, pick a color for each, then
-- re-run. Instead of it being first initialized with default. So maybe no
-- saved variable for it?" SeedThreatColorDefault above already seeds all 3
-- keys unconditionally at load, before any slash command can even be typed
-- - so a genuinely nil DB value shouldn't be reachable under normal
-- operation, and the exact first-run cause wasn't caught by /coasp log (it
-- wasn't on for that attempt). But GetThreatColorForUnit and
-- RenderTestApply both used to read COA_GuardianPlatesDB.threatColorX
-- directly with no fallback of their own - unlike the color-picker
-- swatches' own Refresh(), which already does `COA_GuardianPlatesDB[colorKey]
-- or defaultColor`. If the DB value was ever nil/malformed for any reason,
-- the actual render would have silently done nothing (color = nil -> no
-- glow, no fill, no error - the exact symptom reported) rather than falling
-- back to a visible default. One centralized lookup, used by every call
-- site that resolves a state to a color, closes that gap regardless of
-- root cause - manually setting a color via the picker is no longer the
-- only way to guarantee a non-nil color.
local function GetConfiguredThreatColor(stateName)
    if stateName == "secure" then
        return COA_GuardianPlatesDB.threatColorSecure or THREAT_COLOR_DEFAULT_SECURE
    elseif stateName == "warning" then
        return COA_GuardianPlatesDB.threatColorWarning or THREAT_COLOR_DEFAULT_WARNING
    elseif stateName == "danger" then
        return COA_GuardianPlatesDB.threatColorDanger or THREAT_COLOR_DEFAULT_DANGER
    end
    return nil
end

-- Fixed key passed to Core's SetGlow/ClearGlow - only one threat glow is
-- ever active per health bar at a time, so a fixed key is enough (Core's
-- glow primitive supports multiple independently-keyed glows on the same
-- bar, for any future capability that wants its own).
local THREAT_GLOW_KEY = "coagp_threat"

-- v3.5.30 tried recoloring the native aggroHighlight to a fixed neutral
-- white (Battlewrath: "Can we modify the colour? Keep it white so our glow
-- isn't being competed with signal wise.") instead of letting it echo the
-- resolved threat-state color. v3.5.38 retired the native recolor from this
-- production path entirely (see ApplyThreatColorForUnit's own doc note for
-- the full verdict - three research passes plus this addon's own live
-- traces confirmed the native highlight is driven by a mechanism this addon
-- has no Lua-reachable path into), so the NATIVE_AGGRO_NEUTRAL_COLOR
-- constant that used to feed both call sites is gone too - nothing reads it
-- anymore. ns.SetNativeAggroHighlightColor itself is untouched in Core.lua
-- and still backs the isolated "nativeAggroColor" render-test module below.

-- Instance-fill eligibility gate (v2.4) - single named extension point,
-- per Battlewrath's explicit request: "leave the door open for that
-- party... and raid. Incase CoA has unique responses." CoA may have its
-- own custom instance-like content that doesn't cleanly report as "party"/
-- "raid" under the stock API - if that's ever confirmed live, this is the
-- one function to extend. Deliberately excludes "pvp"/"arena" - Battlewrath:
-- "Threat isn't really a mechanic as it's player driven" in PvP.
local function IsInstanceFillZone()
    local okInst, inInstance, instanceType = pcall(IsInInstance)
    if not okInst or not inInstance then return false end
    return instanceType == "party" or instanceType == "raid"
end

-- Returns color, stateName - or nil (nil = leave native, no glow, no
-- fill). Caller must already have confirmed `unit` is a valid hostile/
-- enemy nameplate unit via ns.IsPotentialThreatUnit. Uses
-- UnitDetailedThreatSituation("player", unit) - isTanking = "player" is
-- this unit's current primary target; status further distinguishes secure
-- (3) tanking from about-to-lose-it (2), or safe (0) from about-to-pull-
-- aggro (1) when not tanking. Tank view and non-tank view intentionally
-- read the same isTanking/status pair differently - see ROLE_RESEARCH.md
-- for why (a tank without aggro is bad for a tank, but exactly the safe
-- default state for everyone else). Which view applies comes from
-- IsEffectivelyTanking() below - see the v3.2 doc note above.
--
-- GROUP GATE (v2.6): only ever engages while IsInGroup() is true - see the
-- v2.6 doc block near the top of this file.
--
-- ROLE RESOLUTION (v3.2) - Core.lua now builds a shared player-role index
-- (ns.GetPlayerRole(), see its own doc note) instead of this file guessing
-- at role itself. TANK from Core (only ever populated for a Dungeon/Raid
-- Finder-formed group) wins outright; HEALER/DAMAGER from Core means the
-- game is equally sure the player ISN'T tanking, so that also wins outright
-- rather than falling through to the manual setting. Only NONE (the game
-- doesn't know - manually-formed group, solo, or LFG/LFR unused) falls back
-- to the manual threatTanking checkbox, which stays this file's own
-- concept - Core doesn't know or care about threat coloring, it only ever
-- supplies the raw role fact.
local function IsEffectivelyTanking()
    local role = ns.GetPlayerRole and ns.GetPlayerRole()
    if role == "TANK" then
        return true
    elseif role == "HEALER" or role == "DAMAGER" then
        return false
    end
    return COA_GuardianPlatesDB.threatTanking and true or false
end

-- MOB AGGRO CUE (v3.3, 2026-07-08) - Battlewrath, reframing the original
-- "DPS threat-cue" idea: "I think more cleanly it is Mob_aggro_cue, as the
-- same values let the tank know someone else is pulling aggro. So it's a
-- general state change signal (tanking, not tanking, the mob, state)." Not
-- a DPS-only bolt-on - one signal, read from whichever side of the mob's
-- aggro state is relevant to the viewer.
--
-- RESEARCH (Battlewrath's addon reference folder, confirmed against
-- Blizzard's own documented behavior): UnitDetailedThreatSituation's 3rd
-- return value (rawPercentage) is "the unit's threat percentage against
-- mobUnit relative to the threat of mobUnit's primary target... can be
-- greater than 100... Stops updating when you become the primary target."
-- That last clause matters: while tanking, the PLAYER's OWN rawPercentage
-- is frozen, so it can never tell a tank "someone else is closing in" -
-- only querying OTHER group members' rawPercentage against the same mob
-- can. Two symmetric halves, same underlying signal:
--   - Not tanking: the player's OWN rawPercentage crossing
--     threatCautionPct is an earlier heads-up than Blizzard's own status
--     (which stays 0 all the way up to 100% raw threat - no granularity
--     below that at all).
--   - Tanking: scanning OTHER group members' rawPercentage (via
--     IsAnotherMemberApproachingAggro below) surfaces the same "someone's
--     threat is climbing" risk before Blizzard's own status flips to 2,
--     which only happens once someone has ALREADY cleared 100%.
-- Both halves are folded into the existing "warning" color/glow rather
-- than a new 4th state - same signal, earlier timing, no new UI surface.
--
-- POLLING (v3.3.1, 2026-07-08) - Battlewrath, after asking exactly what
-- this scan's cadence and trigger were: "People might be running more
-- dedicated threat tools. 0.5 is fine for that. And we already have the
-- tighter probing on damage events it sounds like. Those are a great
-- stack of limiting traffic against CoA." Two fixes, both applied:
--   1. The party/raid roster list used to be rebuilt from scratch (fresh
--      table, fresh GetNumRaidMembers/GetNumPartyMembers loop) on every
--      single call - now reads Core's cached ns.GetGroupUnits() instead,
--      which only rebuilds on GROUP_ROSTER_UPDATE.
--   2. This scan itself only runs from the 0.5s reclassify tick (and the
--      one-off NAME_PLATE_UNIT_ADDED) now, not from the higher-frequency
--      UNIT_THREAT_SITUATION_UPDATE/UNIT_THREAT_LIST_UPDATE event path -
--      see the `allowAggroCueScan` parameter threaded through
--      GetThreatColorForUnit/ApplyThreatColorForUnit/TryApply below.
--      Dedicated threat-meter addons already give tight, real-time
--      per-damage-event feedback; this cue only needs to catch up within
--      half a second, not instantly, so the expensive part of it doesn't
--      need to ride the same cadence as the status-based coloring does.
--
-- KNOWN SCOPE LIMIT: only scans party/raid member units (via Core's
-- roster), not their pets - keeps this a small, fixed number of calls at
-- the cost of missing a pet independently pulling ahead. Same category of
-- gap as the already-documented solo pet/guardian edge case in
-- ns.IsPotentialThreatUnit's doc note.
local function IsAnotherMemberApproachingAggro(mob)
    local perfStart = ns.PerfStart()
    local cautionPct = COA_GuardianPlatesDB.threatCautionPct or 80
    local groupUnits = ns.GetGroupUnits and ns.GetGroupUnits() or {}
    for _, unit in ipairs(groupUnits) do
        if UnitExists(unit) and not UnitIsUnit(unit, "player") then
            local ok, isTanking, _, _, rawPct = pcall(UnitDetailedThreatSituation, unit, mob)
            if ok and not isTanking and rawPct and rawPct >= cautionPct then
                if perfStart then ns.PerfEnd("Enemy", "IsAnotherMemberApproachingAggro", perfStart) end
                return true
            end
        end
    end
    if perfStart then ns.PerfEnd("Enemy", "IsAnotherMemberApproachingAggro", perfStart) end
    return false
end

-- GROUP THREAT-TABLE EXISTENCE SCAN (v3.4.5, 2026-07-08) - Battlewrath,
-- after watching v3.4.2 live in a real group: "I was in a group, so when I
-- was watching the player, the addon never said 'get aggro from them'."
-- The v3.4.2 nil-check correctly excludes a mob NOBODY in the group has
-- any relationship to (an unrelated bystander's fight elsewhere) - but it
-- over-corrected: it also went silent on a mob the GROUP has genuinely
-- engaged (a party/raid member has a real entry on its threat table) while
-- the PLAYER personally hasn't landed a hit on it yet. That second case is
-- exactly "Safe when I am in a group, and it is attacking me [my group]"
-- from Battlewrath's own framing - and for a tank, it's the single most
-- useful case to flag: an add the group is already fighting that the tank
-- hasn't picked up at all is a real "go get it" moment, not silence.
--
-- Same roster-scan shape as IsAnotherMemberApproachingAggro (Core's cached
-- ns.GetGroupUnits(), same cost profile), but a different question: not
-- "is someone else close to pulling it," just "does ANYONE else have a
-- real entry on this mob's table at all" - confirming the mob has a
-- genuine, group-relevant threat table before GetThreatColorForUnit ever
-- substitutes zero-threat defaults for the player's own missing entry.
--
-- CACHED, not re-scanned every call (see groupThreatEntryCache below) -
-- this only actually runs from the same allowAggroCueScan-gated cadence
-- (0.5s tick / unit-added) as the Mob Aggro Cue's own scan, for the same
-- "don't ride the high-frequency threat-event path" reason. The hot event
-- path reads the cached answer instead of either re-scanning (expensive)
-- or blindly returning nil (which would flicker the color off between
-- ticks even though the 0.5s tick already knows the group has this mob).
-- ROSTER VISIBILITY (v3.4.6) - added after v3.4.5's own log showed this
-- scan genuinely running (0.00ms, cheap) and still finding nothing, for a
-- mob that stayed in combat the whole time. That's not necessarily a bug -
-- it's exactly the correct, silent result if nobody in the scanned roster
-- (self + Core's ns.GetGroupUnits()) actually has any relationship to this
-- specific mob (someone outside the party/raid could be the one fighting
-- it). But that conclusion was previously unverifiable from the log alone
-- - there was no way to see whether the roster being scanned was actually
-- what Battlewrath expected (their real party members) or something
-- smaller/empty/stale. Logs the roster once per scan (unit + name) and
-- each member's own isTanking read, so a "found nothing" result can be
-- read as either "confirmed nobody I'm grouped with is on this table" or
-- "the roster itself looks wrong" - not just taken on faith.
local function HasAnyGroupThreatEntry(mob)
    local perfStart = ns.PerfStart()
    local groupUnits = ns.GetGroupUnits and ns.GetGroupUnits() or {}
    local logging = ns.IsLogging()

    if logging then
        local names = {}
        for _, u in ipairs(groupUnits) do
            table.insert(names, string.format("%s=%s", u, UnitExists(u) and (UnitName(u) or "?") or "gone"))
        end
        ns.Log("Enemy", "HasAnyGroupThreatEntry(%s) scanning roster: %s",
            ns.DescribeUnit(mob), (#names > 0) and table.concat(names, ", ") or "<empty>")
    end

    for _, unit in ipairs(groupUnits) do
        if UnitExists(unit) and not UnitIsUnit(unit, "player") then
            local ok, isTanking = pcall(UnitDetailedThreatSituation, unit, mob)
            if logging then
                ns.Log("Enemy", "  %s vs %s -> isTanking=%s", unit, ns.DescribeUnit(mob), tostring(ok and isTanking))
            end
            if ok and isTanking ~= nil then
                if perfStart then ns.PerfEnd("Enemy", "HasAnyGroupThreatEntry", perfStart) end
                return true
            end
        end
    end
    if perfStart then ns.PerfEnd("Enemy", "HasAnyGroupThreatEntry", perfStart) end
    return false
end

-- [unit] = true/false, last answer from HasAnyGroupThreatEntry. Cleared on
-- unit removal (ns.Enemy.OnUnitRemoved below) so a reused/pooled unit
-- token never inherits a stale answer for a different occupant.
local groupThreatEntryCache = {}

-- stateName is returned alongside the color specifically so
-- ApplyThreatColorForUnit can decide glow visibility by NAME (the glow is
-- deliberately suppressed for "secure") rather than by comparing the
-- color's live RGB value, which would break the moment a user recolors a
-- swatch to match another state.
--
-- `allowAggroCueScan` gates ONLY the expensive tank-side other-member scan
-- (IsAnotherMemberApproachingAggro) - see its own POLLING doc note above.
-- The non-tanking side's own rawPct check is always active regardless,
-- since it costs nothing extra (rawPct is already returned by the same
-- UnitDetailedThreatSituation call made either way).
--
-- THREAT-TABLE GATE (v3.4.2, 2026-07-08) - Battlewrath's own framing, kept
-- verbatim since it's the actual design boundary: "A group is the basis
-- for the threat table. We can: safe when it is attacking me. Safe when I
-- am in a group, and it is attacking me. We can not: assess our threat
-- relationship from the mob, to every creature around me and then player
-- (not in group), until I get all the aggro." That second "can not" is
-- structural, not a missing feature - UnitDetailedThreatSituation requires
-- a real Blizzard unit token as its first argument (self/pet/party/raid/
-- target/focus/mouseover), and there is no token for an arbitrary nearby
-- non-grouped player, so their relationship to a mob is simply
-- unaddressable from here. Group is the only multi-entity boundary we have
-- tokens for at all.
--
-- The IsInGroup() gate above already enforces the "group is the basis"
-- half. This part enforces the other half ("safe when it is attacking
-- me"): UnitDetailedThreatSituation("player", unit) returns nil across the
-- board when player has no entry at all on this mob's own threat table -
-- previously `isTanking = isTanking and true or false` silently collapsed
-- that "no relationship exists" nil into the same false as "on the table,
-- not currently tanking," so a mob engaged only by an unrelated bystander
-- (in combat via UnitAffectingCombat, but never on OUR threat table) could
-- still fall through to the tank-view "not tanking -> danger" branch. The
-- explicit nil check below is the fix - mirrors TidyPlates_ThreatPlates'
-- own UpdateThreatStatus, which checks `if UnitThreatSituation("player",
-- unit.unitid) then` before doing anything else, rather than gating on
-- UnitAffectingCombat (which it tracks as a separate, non-gating
-- attribute). UnitAffectingCombat stays in ns.IsPotentialThreatUnit purely
-- as a cheap pre-filter to skip idle world mobs before this real check
-- runs, not as the source of truth for "has a threat table."
-- LOGGING (v3.4.3) - restructured to a single return point so every
-- resolution (including "nothing to show") gets one log line when
-- /coasp log is on: unit name, the raw isTanking/status/rawPct
-- UnitDetailedThreatSituation actually returned, which lens
-- (tanking/non-tanking) it was read through, and what it resolved to. This
-- is the direct diagnostic for "not performing the expected response" -
-- rather than guessing which branch fired, watch the log during a real
-- pull and read the raw values straight from the API. Branch logic itself
-- is unchanged from v3.4.2 - only the control flow (locals + one return)
-- and the log call are new.
local function GetThreatColorForUnit(unit, allowAggroCueScan)
    if not COA_GuardianPlatesDB.threatMode or COA_GuardianPlatesDB.threatMode == 0 then
        return nil
    end

    local okGroup, inGroup = pcall(IsInGroup)
    if not okGroup or not inGroup then return nil end

    local okThreat, isTanking, status, _, rawPct = pcall(UnitDetailedThreatSituation, "player", unit)
    if not okThreat then return nil end
    if isTanking == nil then
        -- GROUP SUBSTITUTION (v3.4.5) - see HasAnyGroupThreatEntry's own
        -- doc note above. Player has no personal entry, but before giving
        -- up, check (or read the cached answer for) whether the GROUP has
        -- one - only actually scanning on the allowAggroCueScan-gated
        -- cadence, same cost discipline as the Mob Aggro Cue's own scan.
        local groupHasEntry
        if allowAggroCueScan then
            groupHasEntry = HasAnyGroupThreatEntry(unit)
            groupThreatEntryCache[unit] = groupHasEntry
        else
            groupHasEntry = groupThreatEntryCache[unit] or false
        end

        if not groupHasEntry then
            if ns.IsLogging() then
                ns.Log("Enemy", "GetThreatColorForUnit(%s) -> nil (isTanking=nil, no threat-table entry for player or group)",
                    ns.DescribeUnit(unit))
            end
            return nil -- neither player nor group has any relationship to this mob - nothing to show
        end

        -- Group has a real, established relationship with this mob;
        -- player's own is just empty - treat that as zero personal threat
        -- rather than "nothing to show," so tank view's "not tanking"
        -- branch can still fire its "go get it" danger color.
        if ns.IsLogging() then
            ns.Log("Enemy", "GetThreatColorForUnit(%s) isTanking=nil but group has an entry - substituting zero personal threat",
                ns.DescribeUnit(unit))
        end
        isTanking, status, rawPct = false, 0, 0
    end
    status = status or 0
    rawPct = rawPct or 0
    local cautionPct = COA_GuardianPlatesDB.threatCautionPct or 80
    local tanking = IsEffectivelyTanking()
    local color, stateName

    if tanking then
        if isTanking and status == 3 then
            -- MOB AGGRO CUE (tank side) - see doc note above.
            if allowAggroCueScan and IsAnotherMemberApproachingAggro(unit) then
                stateName = "warning"
            else
                stateName = "secure"
            end
        elseif isTanking and status == 2 then
            stateName = "warning"
        elseif not isTanking then
            stateName = "danger" -- a tank without aggro needs to taunt back
        end
    else
        if isTanking then
            stateName = "danger" -- non-tank holding aggro is bad
        elseif status == 1 then
            stateName = "warning" -- approaching the tank's threat
        elseif rawPct >= cautionPct then
            stateName = "warning" -- MOB AGGRO CUE (non-tank side) - see doc note above
        end
        -- else: safe, leave native (color/stateName stay nil)
    end
    if stateName then
        -- Deliberately not `stateName and GetConfiguredThreatColor(stateName)
        -- or nil` - the exact and/or-ternary shape that broke RenderTestApply
        -- in v3.5.10. Harmless here in practice (GetConfiguredThreatColor
        -- never returns falsy for a recognized stateName), but a plain if
        -- costs nothing and doesn't leave that footgun-shaped idiom sitting
        -- in the code for a future edit to trip over.
        color = GetConfiguredThreatColor(stateName)
    end

    if ns.IsLogging() then
        ns.Log("Enemy", "GetThreatColorForUnit(%s) tanking=%s isTanking=%s status=%d rawPct=%.0f -> %s",
            ns.DescribeUnit(unit), tostring(tanking), tostring(isTanking), status, rawPct, tostring(stateName))
    end

    return color, stateName
end

-- DEBOUNCE (v3.4) - mirrors TidyPlates' own Modules/Threat.lua
-- UpdateThreatLevel pattern: only touch Core's executor primitives
-- (SetGlow/ClearGlow/SetHealthBarColor/ClearHealthBarColor) when the
-- resolved state has actually changed since the last apply for this unit,
-- not on every dispatch. OnThreatEvent especially can fire many times in a
-- row with the exact same resulting color/state (e.g. repeated threat
-- events while nobody's relative standing has changed), so this avoids
-- redundant library calls (animation restarts, table writes) on every one
-- of them. Keyed by unit id; cleared on unit removal and on Disarm so a
-- reused/reset unit token or a re-enabled threatMode always reapplies
-- rather than trusting a stale cache entry.
local lastAppliedState = {} -- [unit] = { stateName = ..., r = ..., g = ..., b = ..., filled = bool }

local function StatesMatch(prev, stateName, color, filled)
    if not prev then return false end
    if prev.stateName ~= stateName or prev.filled ~= filled then return false end
    if not color then return prev.r == nil end
    return prev.r == color.r and prev.g == color.g and prev.b == color.b
end

local function ClearAppliedState(unit)
    lastAppliedState[unit] = nil
    groupThreatEntryCache[unit] = nil -- v3.4.5 - see HasAnyGroupThreatEntry's cache doc note
end

-- Applies (or clears) the threat glow, and additionally the health-bar
-- FILL color, on a hostile plate. Two channels, one shared color set:
--   1. Glow (Core's ns.SetGlow/ns.ClearGlow) - shown for the "warning"/
--      "danger" states, everywhere (open world, dungeon/raid, arena/pvp) -
--      never touches the health bar's own native fill. DELIBERATELY
--      SUPPRESSED for "secure" (v2.5) - see the doc block above.
--   2. Fill (Core's ns.SetHealthBarColor/ns.ClearHealthBarColor) - only
--      engaged when threatInstanceFillEnabled is true AND
--      IsInstanceFillZone() - i.e. only in eligible instance content, off
--      everywhere else regardless of the checkbox. UNCHANGED by the v2.5
--      secure-glow suppression - fill still paints all 3 states, "secure"
--      included.
-- Deliberately leaves the name text untouched on both channels.
-- `allowAggroCueScan` is threaded straight through to GetThreatColorForUnit
-- - see its own doc note for what this gates and why.
--
-- VISUAL REDESIGN (v3.4) - "warning" uses the "cue" glow style (an
-- immediate ambient bloom, no motion) and "danger" uses the "danger" style
-- (wider, more saturated, in motion) - see Core.lua's SetGlow doc note for
-- what each LibCustomGlow technique actually does. "secure" still gets no
-- glow at all.
-- RENDER-SIDE LOGGING (v3.5.7) - Battlewrath: "I think we should shift onto
-- the render side. As whilst we've seen bits. I don't have strong
-- confidence it's working as we desire." Every log line up to this point
-- (GetThreatColorForUnit, HasAnyGroupThreatEntry, etc.) only ever confirmed
-- the DECISION layer - what state/color was resolved - never whether that
-- decision actually reached the screen. The debounce skip (StatesMatch) and
-- the executor calls below (SetGlow/ClearGlow/SetHealthBarColor) were
-- entirely silent before this, so a debounce misfire (e.g. wrongly treating
-- a pooled-plate reuse as "no change") or a failed glow/fill application
-- would have been invisible to /coasp log - only ever catchable by eye at
-- the game client. This logs the debounce outcome and what was actually
-- dispatched to Core; Core's own SetGlow/ClearGlow/SetHealthBarColor/
-- ClearHealthBarColor (see their doc notes) log whether the dispatched call
-- actually found a frame to act on, closing the loop end to end.
local function ApplyThreatColorForUnit(unit, plate, allowAggroCueScan)
    local color, stateName = GetThreatColorForUnit(unit, allowAggroCueScan)
    local shouldFill = color and COA_GuardianPlatesDB.threatInstanceFillEnabled and IsInstanceFillZone()

    if StatesMatch(lastAppliedState[unit], stateName, color, shouldFill) then
        if ns.IsLogging() then
            ns.Log("Enemy", "ApplyThreatColorForUnit(%s) -> debounce skip, state unchanged (stateName=%s filled=%s)",
                ns.DescribeUnit(unit), tostring(stateName), tostring(shouldFill))
        end
        return -- nothing has actually changed since the last apply - skip Core entirely
    end
    lastAppliedState[unit] = {
        stateName = stateName,
        r = color and color.r, g = color and color.g, b = color and color.b,
        filled = shouldFill,
    }

    -- HAND-ROLLED GLOW IS THE ADDON'S ONLY THREAT SIGNAL (v3.5.29, native
    -- recolor formally retired v3.5.38) - Battlewrath, once the halo's
    -- shape/position was fully tuned (through v3.5.28): "Can we wire this in
    -- to the glow constant we made? Or do we now have a legacy hidden
    -- element to compute?" Answer to both: yes, and yes.
    --
    -- The v3.5.19 "native-first, glow-as-fallback" scheme above was built on
    -- an assumption later disproven by live testing (v3.5.20-3.5.23):
    -- SetNativeAggroHighlightColor succeeding (nativeApplied=true) only ever
    -- meant "the native aggroHighlight texture exists and accepted a
    -- SetVertexColor call" - NOT that the frame is actually visible.
    -- Ascension_NamePlates only ever Shows that frame on your own CURRENT
    -- TARGET, and even a forced Show()/SetAlpha(1) couldn't override its own
    -- visibility logic on other plates.
    --
    -- v3.5.30-37 then chased whether the native highlight's COLOR (not its
    -- visibility) could at least be made to hold white instead of red, even
    -- on the rare plate where it IS visible - v3.5.32 confirmed a real
    -- re-assert race (native code re-drives the color faster than our
    -- one-shot call can hold it, not Blizzard protection), v3.5.33/34 tried
    -- a hooksecurefunc fix against UnitFrame_UpdateThreatIndicator,
    -- v3.5.35/36 checked for a mutable color table (clean negative),
    -- v3.5.37 checked for a hidden closure-captured table (blocked by this
    -- client's addon sandbox). v3.5.38: three independent research passes
    -- against real 3.3.5a FrameXML source (two mirrors) plus this addon's
    -- own live tfunc traces converged: UnitFrame_UpdateThreatIndicator is
    -- structurally unit-token-gated and never receives a nameplate's
    -- indicator (every real trace only ever showed party/pet frame
    -- "...Flash" traffic) - the hook was targeting a function nameplates
    -- can't reach. Separately, a live /coasp probe DID find a real
    -- "aggroHighlight"-named frame on THIS client (a Cataclysm-era
    -- CompactUnitFrame concept, absent from stock 3.3.5a entirely) -
    -- Ascension backported or reimplemented something aggroHighlight-shaped,
    -- but it's driven by a mechanism this addon has no Lua-reachable path
    -- into (no hookable function, no color table, no closure upvalue).
    -- SetNativeAggroHighlightColor is retired from this production path as
    -- a result - it never reliably held its color anyway, so calling it
    -- bought nothing. ns.SetNativeAggroHighlightColor/ClearNativeAggroHighlightColor
    -- and the isolated "nativeAggroColor"/"aggroBroadcast" render-test
    -- modules stay in Core/EnemyPlates as diagnostic tools, not production
    -- signal.
    --
    -- ns.SetHandRolledGlow/ns.ClearHandRolledGlow (the fully owned
    -- "bonusobjectives-bar-glow-ring" texture, proven live and tuned through
    -- v3.5.28) is the addon's real, sole, production threat signal for
    -- ordinary warning/danger state - always renders, no re-assert race, no
    -- per-frame OnUpdate cost. GLOW_STYLE_PARAMS/SetGlow themselves are NOT
    -- removed from Core - kept as reusable infrastructure for the still-open
    -- "what's that extra signal good for" candidates (Needs-action
    -- highlight #197, healer aggro-shift awareness #251).
    local showGlow = color and stateName ~= "secure"
    if showGlow then
        if ns.IsLogging() then
            ns.Log("Enemy", "ApplyThreatColorForUnit(%s) -> dispatching SetHandRolledGlow (stateName=%s)",
                ns.DescribeUnit(unit), tostring(stateName))
        end
        pcall(ns.SetHandRolledGlow, plate, color)
    else
        if ns.IsLogging() then
            ns.Log("Enemy", "ApplyThreatColorForUnit(%s) -> dispatching ClearHandRolledGlow (stateName=%s)",
                ns.DescribeUnit(unit), tostring(stateName))
        end
        pcall(ns.ClearHandRolledGlow, plate)
    end

    if shouldFill then
        if ns.IsLogging() then
            ns.Log("Enemy", "ApplyThreatColorForUnit(%s) -> dispatching SetHealthBarColor (Instance Fill)",
                ns.DescribeUnit(unit))
        end
        ns.SetHealthBarColor(unit, plate, color)
    elseif ns.HasHealthBarColorOverride(unit) then
        if ns.IsLogging() then
            ns.Log("Enemy", "ApplyThreatColorForUnit(%s) -> dispatching ClearHealthBarColor (Instance Fill no longer applies)",
                ns.DescribeUnit(unit))
        end
        ns.ClearHealthBarColor(unit, plate)
    end
end

-- Reverts every currently threat-colored plate back to its captured native
-- fill color AND clears any visible glow - called the instant threatMode
-- flips to 0. Also wipes the debounce cache (v3.4) - otherwise a later
-- re-enable of threatMode could see the same resolved state as before the
-- disarm and (wrongly) skip reapplying it since nothing has visibly
-- changed *from the cache's point of view*, even though the executor
-- primitives were just forcibly cleared.
local function DisarmThreatColors()
    for unit in pairs(ns.activeUnits) do
        local plate = ns.ResolvePlateForRemoval(unit)
        if ns.HasHealthBarColorOverride(unit) then
            ns.ClearHealthBarColor(unit, plate)
        end
        if plate then
            pcall(ns.ClearGlow, plate, THREAT_GLOW_KEY) -- legacy path; harmless no-op now that production never starts it
            pcall(ns.ClearHandRolledGlow, plate) -- v3.5.29 - the real production glow, now needs clearing here too
            pcall(ns.ClearNativeAggroHighlightColor, plate) -- v3.5.18 - restore native red, don't leave our last color stuck on it
        end
        ClearAppliedState(unit)
    end
end

-- Shared setter - used by both the options panel checkbox and the
-- `/coaep` slash subcommand. Plain Off(0)/On(1) since v2.5.
local function SetThreatMode(mode)
    mode = tonumber(mode) or 0
    if mode < 0 or mode > 1 then mode = 0 end
    COA_GuardianPlatesDB.threatMode = mode
    if mode == 0 then
        pcall(DisarmThreatColors)
    end
end

-- Manual one-off refresh (options panel / slash commands) - allows the
-- full aggro-cue scan since this isn't a hot path.
local function ApplyThreatColorToAllActive()
    for unit in pairs(ns.activeUnits) do
        local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
        if ok and plate and ns.IsPotentialThreatUnit(unit) then
            pcall(ApplyThreatColorForUnit, unit, plate, true)
        end
    end
end

-- ---------------------------------------------------------------------
-- Core dispatch contract implementation (see Core.lua's DISPATCH CONTRACT
-- doc note)
-- ---------------------------------------------------------------------

-- `allowAggroCueScan` (see GetThreatColorForUnit's doc note): true from
-- OnUnitAdded (one-off, cheap either way) and OnReclassify (the 0.5s tick
-- this scan is meant to ride), false from OnThreatEvent - that path can
-- fire much more often during heavy combat, and per Battlewrath's own
-- call, dedicated threat-meter addons already cover that tighter cadence;
-- this cue only needs to catch up within the next 0.5s tick, not instantly.
local function TryApply(unit, plate, allowAggroCueScan)
    if not plate then return end
    if COA_GuardianPlatesDB.threatMode and COA_GuardianPlatesDB.threatMode > 0 and ns.IsPotentialThreatUnit(unit) then
        pcall(ApplyThreatColorForUnit, unit, plate, allowAggroCueScan)
    end
end

function ns.Enemy.OnUnitAdded(unit, plate)
    TryApply(unit, plate, true)
end

-- OVERLOAD SAFETY VALVE (v3.5.6) - OnReclassify normally allows the Mob
-- Aggro Cue's group scans (same as OnUnitAdded), but defers to Core's
-- ns.IsReclassifyOverloaded() first - see Core.lua's own doc note for the
-- full reasoning (Battlewrath: raid-scale insurance against the reclassify
-- tick genuinely ballooning, not a response to any observed problem). Only
-- the expensive scans are skipped for a tick when overloaded; the cheap
-- isTanking/status check that drives all core threat coloring still runs
-- every single tick regardless, via ApplyThreatColorForUnit/
-- GetThreatColorForUnit's own always-on branch logic.
function ns.Enemy.OnReclassify(unit, plate)
    local allowAggroCueScan = not (ns.IsReclassifyOverloaded and ns.IsReclassifyOverloaded())
    TryApply(unit, plate, allowAggroCueScan)
end

function ns.Enemy.OnThreatEvent(unit, plate)
    TryApply(unit, plate, false)
end

-- Restores this unit's threat-color/glow state (called by Core BEFORE it
-- wipes its own shared tables) - returns true if anything was actually
-- restored, for Core's diagnostic log. Glow-clear is unconditional (the
-- glow can be visible on its own, with no health-bar-color override in
-- play at all) so it isn't counted toward the returned flag, matching the
-- original SANITATION FIX's accounting.
function ns.Enemy.OnUnitRemoved(unit, plate)
    local restoredColor = false
    if ns.HasHealthBarColorOverride(unit) then
        ns.ClearHealthBarColor(unit, plate)
        restoredColor = true
    end
    if plate then
        pcall(ns.ClearGlow, plate, THREAT_GLOW_KEY) -- legacy path; harmless no-op now that production never starts it
        pcall(ns.ClearHandRolledGlow, plate) -- v3.5.29 - real production glow, must be cleared on pooled-plate reuse too
    end
    -- v3.4: wipe the debounce cache too - unit ids get recycled onto pooled
    -- plates, so a stale cached state here could cause a future, unrelated
    -- mob to wrongly skip its first real apply.
    ClearAppliedState(unit)
    return restoredColor
end

-- ---------------------------------------------------------------------
-- Options sub-panel - nested under the main "COA State Plates" category
-- via the standard classic-era parent-name convention. Titled "Enemy
-- Plates" (the module), with threat coloring's controls presented as its
-- one current sub-mode - room left below for future sibling sub-modes.
-- ---------------------------------------------------------------------

local optionsPanel = CreateFrame("Frame", "COA_GuardianPlatesThreatOptionsPanel", UIParent)
optionsPanel.name = "Enemy Plates"
optionsPanel.parent = "COA State Plates"

local optionsTitle = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
optionsTitle:SetPoint("TOPLEFT", 16, -16)
optionsTitle:SetText("COA State Plates - Enemy Plates")

local optionsSubtitle = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
optionsSubtitle:SetPoint("TOPLEFT", optionsTitle, "BOTTOMLEFT", 0, -8)
optionsSubtitle:SetWidth(500)
optionsSubtitle:SetJustifyH("LEFT")
optionsSubtitle:SetText("Signal/behaviour only against hostile plates. Threat coloring below is its current sub-mode.")

local threatEnabledCheckbox = CreateFrame("CheckButton", "COA_GuardianPlatesThreatEnabledCheckbox", optionsPanel, "InterfaceOptionsCheckButtonTemplate")
threatEnabledCheckbox:SetPoint("TOPLEFT", optionsSubtitle, "BOTTOMLEFT", 0, -16)
local okThreatEnabledLabel, threatEnabledCheckboxLabel = pcall(function() return _G[threatEnabledCheckbox:GetName() .. "Text"] end)
if okThreatEnabledLabel and threatEnabledCheckboxLabel then
    threatEnabledCheckboxLabel:SetText("Enable threat coloring")
end
threatEnabledCheckbox:SetChecked((COA_GuardianPlatesDB.threatMode or 0) > 0)
threatEnabledCheckbox:SetScript("OnClick", function(self)
    SetThreatMode(self:GetChecked() and 1 or 0)
end)

-- Manual role choice (v2.5) - replaces the old "Smart" auto-detection.
local threatTankingCheckbox = CreateFrame("CheckButton", "COA_GuardianPlatesThreatTankingCheckbox", optionsPanel, "InterfaceOptionsCheckButtonTemplate")
threatTankingCheckbox:SetPoint("TOPLEFT", threatEnabledCheckbox, "BOTTOMLEFT", 0, -4)
local okThreatTankingLabel, threatTankingCheckboxLabel = pcall(function() return _G[threatTankingCheckbox:GetName() .. "Text"] end)
if okThreatTankingLabel and threatTankingCheckboxLabel then
    threatTankingCheckboxLabel:SetText("Tanking (unchecked = DPS view) - used only when the game has no LFG/LFR role")
end
threatTankingCheckbox:SetChecked(COA_GuardianPlatesDB.threatTanking and true or false)
threatTankingCheckbox:SetScript("OnClick", function(self)
    COA_GuardianPlatesDB.threatTanking = self:GetChecked() and true or false
    pcall(ApplyThreatColorToAllActive)
end)

-- 3 independently-configurable threat-color pickers (v2.3) - one per state
-- (secure/warning/danger), so a DPS and a Tank can each define what a given
-- state should look like to them. Deliberately a separate factory from
-- FriendlyPlates.lua's CreateColorRow, because the semantics
-- genuinely differ: a guardian/NPC swatch's un-set state is meaningful
-- (nil = "no override, use native color"), but a threat state has no
-- native fallback - it's either colored per the active threat scheme or
-- not shown at all. So here right-click resets to that state's DEFAULT
-- color, never clears to nil, and DB values are seeded non-nil at load.
local function CreateThreatColorRow(anchorWidget, labelText, colorKey, defaultColor)
    local rowLabel = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    rowLabel:SetPoint("TOPLEFT", anchorWidget, "BOTTOMLEFT", 0, -20)
    rowLabel:SetText(labelText .. " (right-click swatch to reset to default):")

    local swatch = CreateFrame("Button", nil, optionsPanel)
    swatch:SetPoint("TOPLEFT", rowLabel, "BOTTOMLEFT", 4, -6)
    swatch:SetWidth(24)
    swatch:SetHeight(24)
    swatch:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    local border = swatch:CreateTexture(nil, "BACKGROUND")
    border:SetAllPoints()
    border:SetTexture(0, 0, 0, 1)

    local fill = swatch:CreateTexture(nil, "ARTWORK")
    fill:SetPoint("TOPLEFT", 2, -2)
    fill:SetPoint("BOTTOMRIGHT", -2, 2)
    fill:SetTexture(1, 1, 1, 1)

    local function Refresh()
        local c = COA_GuardianPlatesDB[colorKey] or defaultColor
        fill:SetVertexColor(c.r, c.g, c.b)
    end

    local function SetColor(r, g, b)
        COA_GuardianPlatesDB[colorKey] = { r = r, g = g, b = b }
        Refresh()
        ApplyThreatColorToAllActive()
    end

    local function ResetColor()
        SetColor(defaultColor.r, defaultColor.g, defaultColor.b)
    end

    swatch:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "RightButton" then
            ResetColor()
            return
        end

        if not ColorPickerFrame then
            Print("Color picker not found on this client.")
            return
        end

        local current = COA_GuardianPlatesDB[colorKey] or defaultColor

        ColorPickerFrame.func = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            SetColor(r, g, b)
        end
        ColorPickerFrame.cancelFunc = function(previousValues)
            if previousValues then
                SetColor(previousValues.r, previousValues.g, previousValues.b)
            else
                ResetColor()
            end
        end
        ColorPickerFrame.hasOpacity = false

        local okShow = pcall(function()
            ColorPickerFrame:SetColorRGB(current.r, current.g, current.b)
            ShowUIPanel(ColorPickerFrame)
        end)
        if not okShow then
            Print("Could not open the color picker on this client.")
        end
    end)

    return swatch, Refresh
end

local threatColorSecureSwatch, RefreshThreatColorSecureSwatch = CreateThreatColorRow(
    threatTankingCheckbox, "Threat color - secure", "threatColorSecure", THREAT_COLOR_DEFAULT_SECURE)
local threatColorWarningSwatch, RefreshThreatColorWarningSwatch = CreateThreatColorRow(
    threatColorSecureSwatch, "Threat color - warning", "threatColorWarning", THREAT_COLOR_DEFAULT_WARNING)
local threatColorDangerSwatch, RefreshThreatColorDangerSwatch = CreateThreatColorRow(
    threatColorWarningSwatch, "Threat color - danger", "threatColorDanger", THREAT_COLOR_DEFAULT_DANGER)

-- Instance Fill (v2.4) - off by default. The glow above always shows
-- regardless of this checkbox; this only adds the bar-fill channel, and
-- only while actually inside eligible instance content.
local instanceFillCheckbox = CreateFrame("CheckButton", "COA_GuardianPlatesInstanceFillCheckbox", optionsPanel, "InterfaceOptionsCheckButtonTemplate")
instanceFillCheckbox:SetPoint("TOPLEFT", threatColorDangerSwatch, "BOTTOMLEFT", -4, -20)
local okInstFillLabel, instanceFillCheckboxLabel = pcall(function() return _G[instanceFillCheckbox:GetName() .. "Text"] end)
if okInstFillLabel and instanceFillCheckboxLabel then
    instanceFillCheckboxLabel:SetText("Instance fill: also color the bar fill in dungeons/raids")
end
instanceFillCheckbox:SetChecked(COA_GuardianPlatesDB.threatInstanceFillEnabled and true or false)
instanceFillCheckbox:SetScript("OnClick", function(self)
    COA_GuardianPlatesDB.threatInstanceFillEnabled = self:GetChecked() and true or false
    pcall(ApplyThreatColorToAllActive)
end)

optionsPanel.refresh = function()
    threatEnabledCheckbox:SetChecked((COA_GuardianPlatesDB.threatMode or 0) > 0)
    threatTankingCheckbox:SetChecked(COA_GuardianPlatesDB.threatTanking and true or false)
    RefreshThreatColorSecureSwatch()
    RefreshThreatColorWarningSwatch()
    RefreshThreatColorDangerSwatch()
    instanceFillCheckbox:SetChecked(COA_GuardianPlatesDB.threatInstanceFillEnabled and true or false)
end
RefreshThreatColorSecureSwatch()
RefreshThreatColorWarningSwatch()
RefreshThreatColorDangerSwatch()

if InterfaceOptions_AddCategory then
    pcall(InterfaceOptions_AddCategory, optionsPanel)
end

-- ---------------------------------------------------------------------
-- Slash command
-- ---------------------------------------------------------------------

-- RENDER TEST RIG (v3.5.8, moved under Core's /coasp in v3.5.9) -
-- Battlewrath: "Are we able to feed dummy input into it? Like I have a
-- target, then it builds a data stream off them?" Calls the exact same
-- Core executor primitives ApplyThreatColorForUnit itself dispatches to
-- (ns.SetGlow/ns.ClearGlow/ns.SetHealthBarColor/ns.ClearHealthBarColor)
-- against your CURRENT TARGET with a FORCED state - bypassing
-- GetThreatColorForUnit's real threat-table read entirely. This tests the
-- render pipeline itself (does the glow actually start? does the fill
-- actually paint? does it clear correctly?) on demand - standing still on
-- a training dummy or anything else with a nameplate, in or out of combat,
-- solo or grouped, no need to wait for real threat conditions to line up.
-- Debug/test-only: doesn't touch threatMode, the group gate, or the
-- debounce cache (lastAppliedState), so it can't leave the addon in a
-- different real-mode state afterward, and a subsequent real
-- ApplyThreatColorForUnit call on the same unit isn't fooled by a stale
-- debounce entry from a forced test state.
--
-- v3.5.9 (2026-07-09) - Battlewrath's correction: "How come coaep? I'd
-- stated core should carry everything." Moved out of this file's own
-- /coaep and registered with Core's shared /coasp instead (see Core.lua's
-- RENDER TEST REGISTRY doc note) - exposed as ns.Enemy.RenderTestApply so
-- Core's generic dispatcher/cycle engine can call it without needing to
-- know anything about threat colors itself.
function ns.Enemy.RenderTestApply(stateName, forceFill)
    if not UnitExists("target") then
        Print("Render test: no target selected.")
        return
    end
    local okPlate, plate = pcall(C_NamePlate.GetNamePlateForUnit, "target")
    if not okPlate or not plate then
        Print("Render test: target has no active nameplate.")
        return
    end

    if stateName == "clear" then
        pcall(ns.ClearGlow, plate, THREAT_GLOW_KEY) -- legacy path; harmless no-op now
        pcall(ns.ClearHandRolledGlow, plate) -- v3.5.29 - real production glow
        pcall(ns.ClearNativeAggroHighlightColor, plate) -- v3.5.18
        if ns.HasHealthBarColorOverride("target") then
            pcall(ns.ClearHealthBarColor, "target", plate)
        end
        Print("Render test: cleared.")
        return
    end

    -- v3.5.10 fix: this used to be `(stateName == "secure" and
    -- COA_GuardianPlatesDB.threatColorSecure) or (...) or (...)` - the
    -- classic Lua and/or-ternary footgun. That idiom breaks whenever the
    -- "true" branch's own value is itself falsy: if threatColorSecure ever
    -- happened to be nil, `stateName == "secure" and nil` evaluates to nil
    -- regardless of the match, so the whole chain fell through and reported
    -- "unknown state" for a perfectly valid, correctly-typed name. Confirmed
    -- live: Battlewrath's /coasp rendertest cycle ran all 6 registered steps
    -- correctly in sequence (proving the cycle engine itself works) but
    -- every color-based step reported "unknown state" regardless of which
    -- state it was - the signature of this exact footgun, not a real typo
    -- or dispatch bug. Rewritten as explicit if/elseif with no idiom to trip
    -- over, and split into two distinct failure modes: an actually-
    -- unrecognized name vs. a recognized name with a missing/nil color
    -- config, so the message tells you which one it really is.
    if stateName ~= "secure" and stateName ~= "warning" and stateName ~= "danger" then
        Print("Render test: unknown state '" .. tostring(stateName) .. "' - use secure|warning|danger|clear, optionally followed by 'fill'.")
        return
    end

    -- v3.5.12: reads through the same GetConfiguredThreatColor helper
    -- GetThreatColorForUnit now uses (see its own LOOKUP HARDENING doc note
    -- above) - falls back to that state's built-in default the moment the DB
    -- value is nil/missing, instead of trusting COA_GuardianPlatesDB directly
    -- and only finding out it was empty when nothing rendered. The "missing/
    -- nil" message below is kept as defense-in-depth but shouldn't be
    -- reachable in practice anymore - a recognized stateName always resolves
    -- to a real color now, seeded or not.
    local color = GetConfiguredThreatColor(stateName)
    if not color then
        Print("Render test: state '" .. stateName .. "' is recognized, but its configured color is missing/nil - check the threat color pickers in Enemy Plates options.")
        return
    end

    -- v3.5.29 - matches ApplyThreatColorForUnit's own production switch to
    -- the hand-rolled glow (see its doc note for the full history of why the
    -- native-first/glow-fallback scheme, then the native-recolor-as-bonus
    -- scheme, were each tried and retired - v3.5.38 is the final verdict:
    -- the native highlight is driven by a mechanism this addon has no
    -- Lua-reachable path into, so SetNativeAggroHighlightColor is no longer
    -- called here either). Hand-rolled glow is the addon's sole signal.

    if stateName == "secure" then
        pcall(ns.ClearHandRolledGlow, plate) -- secure never glows
    else
        pcall(ns.SetHandRolledGlow, plate, color)
    end

    if forceFill then
        pcall(ns.SetHealthBarColor, "target", plate, color)
    elseif ns.HasHealthBarColorOverride("target") then
        pcall(ns.ClearHealthBarColor, "target", plate)
    end

    Print(string.format("Render test: forced state=%s%s on target (hand-rolled glow). Watch /coasp log for the matching Core confirmation lines.",
        stateName, forceFill and " (+fill)" or ""))
end

-- AGGRO-HIGHLIGHT BROADCAST TEST (v3.5.20) - Battlewrath's follow-up after
-- v3.5.19: "This only highlights your current target... Can we reuse that
-- texture, so the same one that is on our current target, can [be] seen
-- across the aggro cue group and such." Separate registered render-test
-- module (not folded into "threat" above) since it operates on a DIFFERENT
-- set of plates - every currently active hostile plate at once, same filter
-- ApplyThreatColorToAllActive already uses (ns.activeUnits +
-- ns.IsPotentialThreatUnit), not just your target - and calls Core's new
-- force-show test primitives (ns.ForceShowNativeAggroHighlight/
-- ClearForcedNativeAggroHighlight) rather than the normal
-- SetNativeAggroHighlightColor, specifically to test whether forcing the
-- native frame Shown on a NON-targeted plate actually sticks, or whether
-- Ascension_NamePlates silently re-hides it (visually testable by
-- Battlewrath, since a fought-back Show() would just never appear). Because
-- it's a second registered module, /coasp rendertest cycle automatically
-- concatenates its steps in after "threat"'s own - one cycle run now
-- exercises both the per-target real path AND this group-wide force-show
-- test back to back.
local function RenderTestAggroBroadcast(stateName)
    local color
    if stateName ~= "clear" then
        color = GetConfiguredThreatColor(stateName)
        if not color then
            Print("Render test (aggro broadcast): state '" .. stateName .. "' has no configured color, skipped.")
            return
        end
    end

    local touched = 0
    for unit in pairs(ns.activeUnits) do
        -- v3.5.21 fix: was ns.IsPotentialThreatUnit(unit), which also
        -- requires UnitAffectingCombat - a deliberate production gate (see
        -- its own doc note) that's wrong for a synthetic force-show test.
        -- Battlewrath's own capture showed every visible mob reporting
        -- combat=nil (nothing pulled), so the old filter meant this loop
        -- silently never even reached ForceShowNativeAggroHighlight once.
        -- ns.IsHostileUnit skips the combat requirement - any hostile,
        -- attackable unit currently on screen qualifies, pulled or not.
        if ns.IsHostileUnit(unit) then
            local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
            if ok and plate then
                if stateName == "clear" then
                    pcall(ns.ClearForcedNativeAggroHighlight, plate)
                else
                    -- v3.5.20 fix: pcall's FIRST return is just "did the call
                    -- error", not ForceShowNativeAggroHighlight's own boolean
                    -- result (found the frame + Show()'d it) - need the
                    -- second return to count correctly, same ok/applied
                    -- pattern used in RenderTestApply/ApplyThreatColorForUnit
                    -- above. `local shown = pcall(...)` would have silently
                    -- counted every unit as touched regardless of whether a
                    -- native frame was actually found on that plate.
                    local ok2, shown = pcall(ns.ForceShowNativeAggroHighlight, plate, color)
                    if ok2 and shown then touched = touched + 1 end
                end
            end
        end
    end

    if stateName == "clear" then
        Print("Render test (aggro broadcast): cleared forced highlight across active hostile plates.")
    else
        Print(string.format("Render test (aggro broadcast): forced state=%s across %d hostile plate(s). Look at plates OTHER than your current target - if they light up and stay lit, the native frame's visibility can be overridden; if they don't, Ascension_NamePlates is fighting it back.",
            stateName, touched))
    end
end

-- HAND-ROLLED GLOW RENDER TEST (v3.5.23) - isolated test for
-- ns.SetHandRolledGlow/ns.ClearHandRolledGlow (see Core.lua's own doc note
-- on the "bonusobjectives-bar-glow-ring" sprite Battlewrath found). Kept
-- separate from "threat" and "aggroBroadcast" above so this can be eyeballed
-- on its own before any decision is made about folding it into the real
-- ApplyThreatColorForUnit path - operates on target only, like "threat"
-- does, since the point right now is just "does this look right at all",
-- not group-wide behavior.
local function RenderTestHandRolledGlow(stateName)
    if not UnitExists("target") then
        Print("Render test (hand-rolled glow): no target selected.")
        return
    end
    local okPlate, plate = pcall(C_NamePlate.GetNamePlateForUnit, "target")
    if not okPlate or not plate then
        Print("Render test (hand-rolled glow): target has no active nameplate.")
        return
    end

    if stateName == "clear" then
        pcall(ns.ClearHandRolledGlow, plate)
        Print("Render test (hand-rolled glow): cleared.")
        return
    end

    local color = GetConfiguredThreatColor(stateName)
    if not color then
        Print("Render test (hand-rolled glow): state '" .. stateName .. "' has no configured color, skipped.")
        return
    end
    pcall(ns.SetHandRolledGlow, plate, color)
    Print("Render test (hand-rolled glow): forced state=" .. stateName .. " on target.")
end

-- NATIVE AGGRO HIGHLIGHT COLOR SWAP TEST (v3.5.31) - Battlewrath: "Shall we
-- add a render test to swap its colors on the threat system on its own? I
-- can't test if it works when it already defaults to white outside of
-- conditions." Now that production always recolors the native highlight to
-- the same fixed white (v3.5.30), there's no real-condition way to compare
-- "is the recolor call actually taking effect" against anything else - it's
-- always the same color whenever it's visible. This is a dedicated,
-- state-logic-free test: it forces raw colors straight at
-- ns.SetNativeAggroHighlightColor on your CURRENT TARGET only, cycling
-- through a few obviously-different swatches (not threat states) purely so
-- the recolor mechanism itself can be visually confirmed. It does NOT force
-- the frame Shown (that was already proven not to stick on plates
-- Ascension_NamePlates isn't already choosing to show - see the
-- aggroBroadcast module's own doc note) - so this is only actually visible
-- while you genuinely hold aggro on your real current target, same
-- limitation as the production path itself.
local NATIVE_COLOR_TEST_SWATCHES = {
    white = { r = 1, g = 1, b = 1 },
    red = { r = 1, g = 0, b = 0 },
    yellow = { r = 1, g = 0.82, b = 0 },
    green = { r = 0, g = 1, b = 0 },
}

local function RenderTestNativeAggroColor(colorName)
    if not UnitExists("target") then
        Print("Render test (native aggro color): no target selected.")
        return
    end
    local okPlate, plate = pcall(C_NamePlate.GetNamePlateForUnit, "target")
    if not okPlate or not plate then
        Print("Render test (native aggro color): target has no active nameplate.")
        return
    end

    if colorName == "clear" then
        pcall(ns.ClearNativeAggroHighlightColor, plate)
        Print("Render test (native aggro color): cleared, restored native red default.")
        return
    end

    local swatch = NATIVE_COLOR_TEST_SWATCHES[colorName]
    if not swatch then
        Print("Render test (native aggro color): unknown color '" .. tostring(colorName) .. "' - use white|red|yellow|green|clear.")
        return
    end
    local ok, applied = pcall(ns.SetNativeAggroHighlightColor, plate, swatch)
    Print(string.format("Render test (native aggro color): set %s (%s). Only visible while you're genuinely holding aggro on your current target right now - this doesn't force the frame Shown.",
        colorName, (ok and applied) and "texture found on this plate" or "texture NOT found on this plate"))
end

-- Registers this module's testable states with Core's shared /coasp
-- rendertest command - see Core.lua's RegisterRenderTest doc note. Order
-- matters here: it's the sequence /coasp rendertest cycle steps through.
if ns.RegisterRenderTest then
    ns.RegisterRenderTest("threat", ns.Enemy.RenderTestApply, {
        { state = "secure" },
        { state = "warning" },
        { state = "warning", fill = true },
        { state = "danger" },
        { state = "danger", fill = true },
        { state = "clear" },
    })
    ns.RegisterRenderTest("aggroBroadcast", RenderTestAggroBroadcast, {
        { state = "secure" },
        { state = "warning" },
        { state = "danger" },
        { state = "clear" },
    })
    ns.RegisterRenderTest("handRolledGlow", RenderTestHandRolledGlow, {
        { state = "secure" },
        { state = "warning" },
        { state = "danger" },
        { state = "clear" },
    })
    -- v3.5.31 - own vocabulary (color swatches, not threat states) since
    -- this test is deliberately independent of threat-state logic. A direct
    -- one-off command (e.g. "/coasp rendertest white") still broadcasts to
    -- every registered module, so "threat"/"aggroBroadcast"/"handRolledGlow"
    -- will each print their own harmless "unknown state" message for these
    -- - same as how they already tolerate any unrecognized name.
    ns.RegisterRenderTest("nativeAggroColor", RenderTestNativeAggroColor, {
        { state = "white" },
        { state = "red" },
        { state = "yellow" },
        { state = "green" },
        { state = "clear" },
    })
end

SLASH_COAENEMYPLATES1 = "/coaep"
SlashCmdList["COAENEMYPLATES"] = function(msg)
    local cmd = (msg or ""):trim():lower()

    if cmd == "on" or cmd == "off" then
        SetThreatMode(cmd == "on" and 1 or 0)
        if threatEnabledCheckbox then
            pcall(function() threatEnabledCheckbox:SetChecked((COA_GuardianPlatesDB.threatMode or 0) > 0) end)
        end
        Print("Threat coloring: " .. ((COA_GuardianPlatesDB.threatMode or 0) > 0 and "On" or "Off"))
    elseif cmd == "tanking on" or cmd == "tanking off" then
        local arg = cmd:match("^tanking%s+(%S+)$")
        COA_GuardianPlatesDB.threatTanking = (arg == "on")
        if threatTankingCheckbox then
            threatTankingCheckbox:SetChecked(COA_GuardianPlatesDB.threatTanking)
        end
        pcall(ApplyThreatColorToAllActive)
        Print("Threat view: " .. (COA_GuardianPlatesDB.threatTanking and "Tanking" or "DPS"))
    elseif cmd == "instancefill on" or cmd == "instancefill off" then
        local arg = cmd:match("^instancefill%s+(%S+)$")
        COA_GuardianPlatesDB.threatInstanceFillEnabled = (arg == "on")
        if instanceFillCheckbox then
            instanceFillCheckbox:SetChecked(COA_GuardianPlatesDB.threatInstanceFillEnabled)
        end
        pcall(ApplyThreatColorToAllActive)
        Print("Instance fill: " .. (COA_GuardianPlatesDB.threatInstanceFillEnabled and "On" or "Off"))
    elseif cmd:match("^caution%s+%d+$") then
        local n = tonumber(cmd:match("^caution%s+(%d+)$"))
        if n and n >= 1 and n <= 255 then
            COA_GuardianPlatesDB.threatCautionPct = n
            pcall(ApplyThreatColorToAllActive)
            Print("Mob aggro cue caution threshold: " .. n .. "%")
        end
    elseif cmd == "status" then
        local okZone, inInstance, instanceType = pcall(IsInInstance)
        local zoneReadout
        if okZone and IsInstanceFillZone() then
            zoneReadout = "eligible (party/raid)"
        elseif okZone and inInstance then
            zoneReadout = "not eligible - " .. tostring(instanceType)
        else
            zoneReadout = "not eligible"
        end
        local threatReadout
        if (COA_GuardianPlatesDB.threatMode or 0) == 0 then
            threatReadout = "Off"
        else
            local okGroup, inGroup = pcall(IsInGroup)
            local groupReadout = (okGroup and inGroup) and "grouped" or "solo - inactive"
            local role = ns.GetPlayerRole and ns.GetPlayerRole() or "NONE"
            local roleSourceReadout
            if role == "TANK" or role == "HEALER" or role == "DAMAGER" then
                roleSourceReadout = "auto - LFG/LFR role: " .. role
            else
                roleSourceReadout = "manual"
            end
            threatReadout = "On (" .. (IsEffectivelyTanking() and "Tanking" or "DPS") .. " view [" .. roleSourceReadout .. "], " .. groupReadout .. ")"
        end
        Print(string.format(
            "threat=%s, instanceFill=%s (currently %s), aggroCue caution=%d%%, glow=%s",
            threatReadout, tostring(COA_GuardianPlatesDB.threatInstanceFillEnabled), zoneReadout,
            COA_GuardianPlatesDB.threatCautionPct or 80,
            ns.LCG and "animated (PixelGlow)" or "static border (fallback - LibCustomGlow not loaded)"))
    elseif cmd == "options" or cmd == "config" then
        if InterfaceOptionsFrame_OpenToCategory then
            pcall(InterfaceOptionsFrame_OpenToCategory, optionsPanel)
            pcall(InterfaceOptionsFrame_OpenToCategory, optionsPanel)
        else
            Print("Interface Options panel API not found on this client - open ESC > Interface > AddOns manually.")
        end
    else
        Print("Usage: /coaep on|off | tanking on|off | instancefill on|off | caution <pct> | status | options - render testing moved to /coasp rendertest")
    end
end
