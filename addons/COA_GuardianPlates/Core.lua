-- COA_GuardianPlates - Core.lua
--
-- MODULE SPLIT (v3.0, 2026-07-08) - Battlewrath: "I'd say we do the
-- seperation first. Then any further development is self contained.
-- Guardian stays as friend plate facing. Threat plate stays about hostile
-- plates. Ascencion plater is the content driver."
--
-- Clarified in the same conversation: "Ascencion plater is the server
-- specific tool for changing things like font. That we're built ontop on."
-- - i.e. TurboPlates (the Ascension-approved nameplate replacement addon)
-- is the thing that actually renders the plates we hook into; we're built
-- on top of the same native (backported) nameplate driver TurboPlates
-- itself uses (C_NamePlate, NAME_PLATE_UNIT_ADDED/REMOVED), not a driver of
-- our own.
--
-- Then, refining the split further: "It might be worth having core as the
-- executor. So we only have one draw editing tool. And then it pulls
-- requirements from what we attach to it." This is the actual architecture
-- below: Core.lua is the ONLY code in this addon that ever calls SetAlpha,
-- SetStatusBarColor, SetTextColor, or drives the glow library directly -
-- every actual "draw" primitive lives here (SetSuppressed, SetHealthBarColor,
-- SetNameColor, SetGlow, and their Clear* counterparts). FriendlyPlates.lua
-- and EnemyPlates.lua never touch a plate's visual state directly - they
-- only compute WHAT should be true for a given unit (their own domain
-- logic: suppression rules, healer thresholds, threat state, colors from
-- the DB) and hand that requirement to one of Core's primitives. This
-- collapses what used to be near-duplicate capture/restore logic
-- (ApplyGuardianColorForUnit and ApplyThreatColorForUnit each had their own
-- copy of "capture native color once, restore it later") into one real
-- implementation, and means a future capability never has to reinvent
-- "how do I safely tint a health bar and put it back."
--
-- The other half of Core's job is the shared plate-driver plumbing: it
-- wraps the client's native nameplate driver and hands both other modules
-- the same unit/plate stream symmetrically - neither Friendly nor Enemy
-- owns or gates the other, both are independent consumers of what Core
-- relays. Also owns: the unit index/GUID cache, classification helpers
-- (friendly/hostile/group), and the generic debug scan/probe tools.
--
-- Pure structural refactor - no behavior changes from v2.7. The combat-gate
-- gap Battlewrath flagged ("I think it doesn't check if the unit is in
-- combat") is deliberately NOT fixed here - explicitly deferred until after
-- this split lands, so the split itself stays a clean, reviewable, no-
-- behavior-change move.
--
-- RENAME (v3.0.1, 2026-07-08) - Battlewrath, refining the split further:
-- "If the supression has to live in Guardian, then I'd say don't split NPC
-- / Healer from it. Instead move it from being 'guardian' to 'Friendly
-- plates'. And then the NPC/Friendlyplayer/Guardian all live in there.
-- Then threat plates is working against enemy plates. Both are
-- signal/behaviour only, and never author content." ns.Guardian was
-- renamed to ns.Friendly throughout accordingly - GuardianPlates.lua became
-- FriendlyPlates.lua, still bundling suppression + healer mode + NPC/pet
-- color together (they don't split apart cleanly - see FriendlyPlates.lua's
-- own doc note).
--
-- BRAND PIVOT (v3.1, 2026-07-08) - Battlewrath, continuing the same
-- conversation: "The brand, I think, should be 'State plates', and threat
-- plate becomes enemy plate. With the threat capability one sub-mode. Much
-- like healer is a sub-node of Friendly plates. A bit of leg work now but
-- puts us in good stead." The overall addon brand becomes "COA State
-- Plates" (was "COA Guardian Plates" - cosmetic only, per Battlewrath:
-- AddOns folder name, COA_GuardianPlatesDB SavedVariables key, and .toc
-- filename all stay put, so existing saved settings and the deploy path
-- are unaffected). ns.Threat was renamed to ns.Enemy throughout
-- (ThreatPlates.lua became EnemyPlates.lua), and threat coloring is now
-- explicitly framed as Enemy Plates' first SUB-MODE rather than a synonym
-- for the whole module - the same shape as healer mode nesting inside
-- Friendly's suppression. This deliberately leaves room for future
-- enemy-facing sub-modes (see the still-pending "Needs-action highlight"
-- and "DPS threat-cue" capabilities) to slot in as siblings of threat
-- coloring later without another rename.
--
-- Neither Friendly nor Enemy ever authors plate content; both only ever
-- apply a signal/behavior on top of what the native driver ("Ascension
-- plater," see above) already renders - Core's executor primitives below
-- are the only place that content actually gets touched.
--
-- DISPATCH CONTRACT: Core pre-creates ns.Friendly = {} and ns.Enemy = {}
-- (each module's own file, loaded after this one per the .toc order, fills
-- in its own functions on those tables). Core's event frame and reclassify
-- ticker below call into whichever of these functions exist, wrapped in
-- pcall, so neither module has to exist for the other to keep working:
--   ns.Friendly.OnUnitAdded(unit, plate) / ns.Enemy.OnUnitAdded(unit, plate)
--   ns.Friendly.OnUnitRemoved(unit, plate) -> returns true if it restored
--     anything / ns.Enemy.OnUnitRemoved(unit, plate) -> same contract.
--     Called BEFORE Core clears its own shared tables (ns.ClearUnitState),
--     same "restore before wipe" ordering the original SANITATION FIX
--     relied on.
--   ns.Friendly.OnReclassify(unit, plate) / ns.Enemy.OnReclassify(unit, plate)
--     - called once per unit on the 0.5s reclassify tick.
--   ns.Friendly.OnThrottledTick() / ns.Enemy.OnThrottledTick() - called
--     once per 0.5s tick (not per unit) - Friendly's home for
--     SweepHealAlertExpirations.
--   ns.Enemy.OnThreatEvent(unit, plate) - called on
--     UNIT_THREAT_SITUATION_UPDATE/UNIT_THREAT_LIST_UPDATE - threat
--     coloring's own event hook, as Enemy's current sub-mode.
--   ns.Friendly.OnHealthEvent(unit) - called on UNIT_HEALTH/UNIT_MAXHEALTH.
--   ns.Friendly.IsSuppressed(unit) - read by Core's ScanNow debug dump.

local addonName, ns = ...

ns.Friendly = ns.Friendly or {}
ns.Enemy = ns.Enemy or {}
ns.Aggro = ns.Aggro or {} -- v3.6.0: the native threat-steering module (AggroPlates.lua)

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[COA_GuardianPlates]|r " .. tostring(msg))
end
ns.Print = Print

-- ---------------------------------------------------------------------
-- Shared unit/plate tracking substrate
-- ---------------------------------------------------------------------

-- unit token -> true, populated straight from NAME_PLATE_UNIT_ADDED/
-- REMOVED - the only source of truth this addon uses for "what plates
-- currently exist," so it never has to guess at field names on whatever
-- internal nameplate-manager table this client build actually has.
ns.activeUnits = {}

-- DUPLICATE-ALIAS GUARD (v3.5.1) - live capture with the new
-- ns.DescribeUnit() GUID tagging (v3.5.0) caught something real: the same
-- physical creature showing up under TWO different unit tokens at once -
-- e.g. "Rot Hide Mongrel[nameplate1|02BD93]" AND
-- "Rot Hide Mongrel[target|02BD93]", same GUID, same tick. NAME_PLATE_UNIT_ADDED
-- fired for both tokens for what C_NamePlate.GetNamePlateForUnit resolves
-- to the identical plate Frame - almost certainly this Ascension client's
-- nameplate-unit-ID backport re-announcing a mob's plate under "target"
-- once you target it, on top of its regular "nameplateN" token. Without a
-- guard, both tokens get processed independently every reclassify tick,
-- each with its OWN state cache (lastAppliedState[unit], etc.), writing
-- to the SAME health bar/glow frame - a very plausible root cause for
-- both the rapid state swings and the reported disappearing-plate bug.
-- plateOwner maps the actual plate Frame -> whichever unit token was
-- first to claim it, so a later alias for the same plate gets recognized
-- and skipped instead of double-tracked.
ns.plateOwner = {}

-- UNIT INDEX (v2.2, 2026-07-08) - a single standard record per tracked
-- unit: unit token -> { plate, guid, lastSeen }. GetNamePlateForUnit(unit)
-- may already fail to resolve by the time NAME_PLATE_UNIT_REMOVED fires -
-- the unit-to-plate association can be torn down before the REMOVED handler
-- runs, in which case a fresh lookup returns nil and any restore logic
-- keyed off it silently no-ops. This cache gives ResolvePlateForRemoval
-- below a fallback: the plate is just a Lua Frame reference, so it stays
-- valid even after the client severs the unit<->plate association. GUID
-- matters specifically because it's stable per-entity even when a pooled
-- nameplate frame gets reassigned to a different occupant, unlike the unit
-- token itself. Kept internal to this addon only for now.
ns.unitIndex = {}

-- Populates/refreshes a unit's index record. Called on NAME_PLATE_UNIT_ADDED
-- and every 0.5s reclassify sweep, so the GUID and plate reference stay
-- current without needing their own separate event wiring.
function ns.IndexUnit(unit, plate)
    local okGuid, guid = pcall(UnitGUID, unit)
    ns.unitIndex[unit] = {
        plate = plate,
        guid = okGuid and guid or nil,
        lastSeen = GetTime(),
    }
end

function ns.GetIndexedPlate(unit)
    local entry = ns.unitIndex[unit]
    return entry and entry.plate
end

function ns.GetUnitGUID(unit)
    local entry = ns.unitIndex[unit]
    return entry and entry.guid
end

-- Resolves a unit's plate for restoration purposes (used on REMOVED and by
-- each module's own Disarm* sweep): try the direct client lookup first,
-- fall back to the cached index reference if that fails (SANITATION FIX v2 -
-- CONFIRMED live, 2026-07-07: the direct lookup needed the cached fallback
-- 20/20 times in Battlewrath's own capture, so this fallback is the norm on
-- this client, not an edge case).
function ns.ResolvePlateForRemoval(unit)
    local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
    if ok and plate then
        return plate, true, false
    end
    plate = ns.GetIndexedPlate(unit)
    if plate then
        return plate, false, true
    end
    return nil, false, false
end

-- ---------------------------------------------------------------------
-- Classification helpers - generic "what kind of unit is this," shared by
-- both modules.
-- ---------------------------------------------------------------------

function ns.IsFriendlyPlayer(unit)
    if not unit or not UnitExists(unit) then return false end
    local okPlayer, isPlayer = pcall(UnitIsPlayer, unit)
    if not okPlayer or not isPlayer then return false end
    local okFriend, isFriend = pcall(UnitIsFriend, "player", unit)
    if not okFriend then return false end
    return isFriend and true or false
end

-- The complement of IsFriendlyPlayer: friendly guardians/pets/NPCs.
function ns.IsFriendlyNonPlayer(unit)
    if not unit or not UnitExists(unit) then return false end
    local okPlayer, isPlayer = pcall(UnitIsPlayer, unit)
    if not okPlayer then return false end
    local okFriend, isFriend = pcall(UnitIsFriend, "player", unit)
    if not okFriend or not isFriend then return false end
    return (not isPlayer) and true or false
end

-- Splits IsFriendlyNonPlayer's bucket into two using UnitPlayerControlled -
-- a reliable, long-standing API for "this unit is owned/summoned by a
-- player" (pets, guardians, totems) vs a plain NPC (quest giver, vendor,
-- guard, etc). A true three-way pet/guardian/totem split isn't reliably
-- exposed via a single Lua call for units you don't own yourself, so this
-- stays a clean two-way split per Battlewrath's call.
function ns.IsFriendlyPetOrGuardian(unit)
    if not ns.IsFriendlyNonPlayer(unit) then return false end
    local okControlled, controlled = pcall(UnitPlayerControlled, unit)
    return okControlled and controlled and true or false
end

function ns.IsFriendlyNPC(unit)
    if not ns.IsFriendlyNonPlayer(unit) then return false end
    local okControlled, controlled = pcall(UnitPlayerControlled, unit)
    return okControlled and (not controlled) and true or false
end

-- Healer mode only ever concerns friendly players who are also in your
-- party or raid - a general "show everyone's health" toggle would just add
-- noise for players you're not responsible for.
function ns.IsGroupOrRaidFriendlyPlayer(unit)
    if not ns.IsFriendlyPlayer(unit) then return false end
    local okParty, inParty = pcall(UnitInParty, unit)
    local okRaid, inRaid = pcall(UnitInRaid, unit)
    return ((okParty and inParty) or (okRaid and inRaid)) and true or false
end

-- ns.IsHostileUnit(unit) (v3.5.21) - hostile+attackable check WITHOUT the
-- UnitAffectingCombat gate IsPotentialThreatUnit adds below. Battlewrath's
-- aggroBroadcast render-test capture showed every visible mob reporting
-- "IsPotentialThreatUnit -> false (UnitAffectingCombat=nil)" the entire
-- time - none of them had been pulled - which meant reusing
-- IsPotentialThreatUnit as that test's own filter silently touched ZERO
-- plates regardless of whether ForceShowNativeAggroHighlight itself worked,
-- since the loop never even got to try a single one. IsPotentialThreatUnit's
-- own combat gate is deliberate, verified production behavior (see its own
-- doc note - never color an unpulled mob) and is NOT being touched; this is
-- a separate, lighter function for test tooling that wants "any hostile
-- plate on screen" regardless of real engagement, matching how
-- RenderTestApply already bypasses the real threat-table read entirely for
-- your target.
function ns.IsHostileUnit(unit)
    if not unit or not UnitExists(unit) then return false end
    local okFriend, isFriend = pcall(UnitIsFriend, "player", unit)
    if okFriend and isFriend then return false end
    local okAttack, canAttack = pcall(UnitCanAttack, "player", unit)
    return okAttack and canAttack and true or false
end

-- A hostile/attackable unit is the complement of the friendly buckets
-- above - the pool threat coloring considers.
--
-- COMBAT GATE (v3.4.1, 2026-07-08) - Battlewrath: "The rendering also
-- applies to all mobs. Not those where a threat table has been
-- established. (Party members, self, threat)" This closes the gap this
-- function's own doc note used to flag as "real but deliberately
-- deferred": without a combat check, GetThreatColorForUnit's tank-view
-- branch treated ANY untouched, never-engaged mob the same as a live add
-- the tank has lost aggro on - `isTanking` is simply `false` for a mob
-- nobody has threat on at all, same as a mob actively being tanked by
-- someone else, so it fell into the same "danger" branch as a real
-- lost-aggro case. `UnitAffectingCombat(unit)` is true only once a mob is
-- actually engaged by someone (that's what puts an entry on its threat
-- table in the first place), so gating here means threat coloring never
-- renders on a mob nobody in the group has pulled/engaged - only on mobs
-- with a real, live threat table.
function ns.IsPotentialThreatUnit(unit)
    if not unit or not UnitExists(unit) then return false end
    local okFriend, isFriend = pcall(UnitIsFriend, "player", unit)
    if okFriend and isFriend then return false end
    local okAttack, canAttack = pcall(UnitCanAttack, "player", unit)
    if not (okAttack and canAttack) then
        if ns.IsLogging() then
            ns.Log("Core", "IsPotentialThreatUnit(%s) -> false (can't attack)", ns.DescribeUnit(unit))
        end
        return false
    end
    local okCombat, inCombat = pcall(UnitAffectingCombat, unit)
    local result = okCombat and inCombat and true or false
    if ns.IsLogging() then
        ns.Log("Core", "IsPotentialThreatUnit(%s) -> %s (UnitAffectingCombat=%s)",
            ns.DescribeUnit(unit), tostring(result), tostring(okCombat and inCombat))
    end
    return result
end

-- ---------------------------------------------------------------------
-- PLAYER ROLE PROFILE (v3.2, 2026-07-08) - Battlewrath: "I'd say let
-- core.lua build the player index/profile. And have everything be a
-- consumer. Instead of rebuilding per module." Mirrors the existing
-- ns.unitIndex shape (a cached fact table, refreshed on the events that can
-- change it, exposed via a getter) but for the PLAYER's own state instead
-- of per-nameplate state - a generic, reusable fact, not an Enemy-specific
-- concept, so it belongs here rather than duplicated inside EnemyPlates.lua.
--
-- RESEARCH (2026-07-08, prompted by Battlewrath's own field notes: "In the
-- LFG/LFR system, you do get assigned a tag. In user-driven content, there
-- are less system tags to rely on. And there is no loot specialization
-- selection. We do know each spec, so we could filter by spec, but then
-- that's something to maintain."): confirmed via UnitGroupRolesAssigned's
-- own documented behavior - it returns a real TANK/HEALER/DAMAGER role only
-- for a group formed through the Dungeon/Raid Finder tool; a manually
-- formed group (guild run, world group - most of what "user-driven content"
-- means on this server) gets NONE back, exactly as Battlewrath described.
-- Spec-based inference (talent points) is a real, working pattern elsewhere
-- - Tidy Plates: Threat Plates does it on retail, and TWThreat does it on
-- Turtle WoW (a custom-class private server, the same situation as CoA) -
-- but both require a maintained spec->role table that silently goes stale
-- the moment a class gets retuned. Given CoA's classes are already fully
-- custom (the reason IsTank()-style auto-detect failed here originally -
-- see EnemyPlates.lua's MIGRATION note), that table would be entirely
-- ours to build AND keep current, with no upstream addon to inherit fixes
-- from. Deliberately NOT built - matches the addon's standing preference
-- for locking in simple choices over configurability/maintenance burden.
--
-- So this is a two-layer resolution, not a three-layer one: ns.GetPlayerRole
-- returns the game's own answer (TANK/HEALER/DAMAGER/NONE) whenever it has
-- one (LFG/LFR-formed groups - free, zero maintenance), and NONE otherwise
-- (manually-formed groups, solo, or LFG/LFR not used) - callers that care
-- about role are expected to fall back to their own manual setting when
-- they see NONE, exactly as EnemyPlates.lua's threatTanking checkbox
-- already does. That manual fallback stays owned by EnemyPlates.lua (it's
-- Enemy's own opinion about what to show when the game doesn't know) -
-- Core only ever supplies the raw, reusable fact.
ns.playerRole = "NONE"

local function RefreshPlayerRole()
    local ok, role = pcall(UnitGroupRolesAssigned, "player")
    ns.playerRole = (ok and role) or "NONE"
end
RefreshPlayerRole()

-- Returns "TANK", "HEALER", "DAMAGER", or "NONE" (NONE = the game doesn't
-- know - not in a Dungeon/Raid Finder-formed group, or role unset). Any
-- future module that cares about the player's own role (not just Enemy's
-- tank/dps view) reads this same cached value instead of re-querying
-- UnitGroupRolesAssigned itself.
function ns.GetPlayerRole()
    return ns.playerRole
end

-- GROUP ROSTER INDEX (v3.3, 2026-07-08) - a cached list of the player's
-- current party/raid member unit tokens (excluding the player), refreshed
-- on GROUP_ROSTER_UPDATE rather than rebuilt from scratch by every caller.
-- Added for the same reason as the player role index above (Battlewrath:
-- "have core as the executor... everything pulls requirements from what
-- we attach to it") - EnemyPlates.lua's Mob Aggro Cue was rebuilding this
-- exact list via GetNumRaidMembers/GetNumPartyMembers on every single
-- reclassify tick AND every threat event, for every currently-tanked unit -
-- real, avoidable work once more than one such unit was active at once.
-- KNOWN SCOPE LIMIT carried over unchanged from EnemyPlates.lua's original
-- version: party/raid member units only, not pets.
--
-- PARTY FIX (v3.4.7, 2026-07-08) - GetNumPartyMembers() was returning an
-- empty roster on this Ascension client even while genuinely grouped -
-- confirmed live via /coasp log (HasAnyGroupThreatEntry's "scanning
-- roster: <empty>" line, for a full session, despite IsInGroup() already
-- having passed the gate above it in GetThreatColorForUnit). Cross-checked
-- against TurboPlates' own Nameplates.lua (installed and presumably
-- working on this exact server): it builds its own party roster with
-- `for i = 1, GetNumGroupMembers() - 1 do -- -1 because player not in
-- party array`, i.e. the modern (Cataclysm 4.1.0+ on a stock client)
-- GetNumGroupMembers() API, not GetNumPartyMembers()/GetNumRaidMembers().
-- Its presence and use in a real, live addon on this server is strong
-- evidence Ascension backported it as a convenience global. Now preferred
-- here too, with the old pair kept only as a fallback if it's ever somehow
-- unavailable. GetNumGroupMembers() counts the player too (unlike
-- GetNumPartyMembers(), which didn't) - hence the "-1" for the party case,
-- taken directly from TurboPlates' own comment; raid numbering already
-- included the player under the old API too, so no offset needed there.
ns.groupUnits = {}

local function RefreshGroupRoster()
    wipe(ns.groupUnits)
    local okRaid, inRaid = pcall(IsInRaid)
    local usedApi, rawOk, rawNum, branch
    if okRaid and inRaid then
        branch = "raid"
        local okNum, num
        if GetNumGroupMembers then
            usedApi = "GetNumGroupMembers"
            okNum, num = pcall(GetNumGroupMembers)
        else
            usedApi = "GetNumRaidMembers"
            okNum, num = pcall(GetNumRaidMembers)
        end
        rawOk, rawNum = okNum, num
        num = (okNum and num) or 0
        for i = 1, num do
            table.insert(ns.groupUnits, "raid" .. i)
        end
    else
        branch = "party"
        local okNum, num
        if GetNumGroupMembers then
            usedApi = "GetNumGroupMembers"
            okNum, num = pcall(GetNumGroupMembers)
            rawOk, rawNum = okNum, num
            num = (okNum and num) or 0
            num = math.max(0, num - 1) -- player isn't in the party1..N array
        else
            usedApi = "GetNumPartyMembers"
            okNum, num = pcall(GetNumPartyMembers)
            rawOk, rawNum = okNum, num
            num = (okNum and num) or 0
        end
        for i = 1, num do
            table.insert(ns.groupUnits, "party" .. i)
        end
    end
    if ns.IsLogging and ns.IsLogging() then
        ns.Log("Core", "RefreshGroupRoster: okRaid=%s inRaid=%s branch=%s api=%s rawOk=%s rawNum=%s -> %d unit(s): %s",
            tostring(okRaid), tostring(inRaid), branch, tostring(usedApi), tostring(rawOk), tostring(rawNum),
            #ns.groupUnits, (#ns.groupUnits > 0) and table.concat(ns.groupUnits, ",") or "<empty>")
    end
end
RefreshGroupRoster()

-- Returns the cached party/raid member unit token list (excluding the
-- player) - callers should treat this as read-only; it's overwritten in
-- place on every GROUP_ROSTER_UPDATE, not replaced, so a caller that kept
-- a reference across a refresh would see it mutate out from under them.
function ns.GetGroupUnits()
    return ns.groupUnits
end

local function DoRefresh(reason)
    if ns.IsLogging and ns.IsLogging() then
        ns.Log("Core", "groupEventFrame refresh: %s", tostring(reason))
    end
    local okRole, errRole = pcall(RefreshPlayerRole)
    local okRoster, errRoster = pcall(RefreshGroupRoster)
    if ns.IsLogging and ns.IsLogging() then
        if not okRole then
            ns.Log("Core", "RefreshPlayerRole ERROR: %s", tostring(errRole))
        end
        if not okRoster then
            ns.Log("Core", "RefreshGroupRoster ERROR: %s", tostring(errRoster))
        end
    end
end

-- LOGIN/RELOAD RACE FIX (v3.4.9), GENERALIZED (v3.5.3) - live capture
-- showed the roster sitting genuinely empty for ~13 minutes after a
-- /reload while already grouped, then correcting itself on its own the
-- moment something else nudged GROUP_ROSTER_UPDATE. Classic WotLK timing
-- gotcha: the event can fire before the client's own group-roster data is
-- fully populated, so the first refresh reads a real (not buggy) 0 or
-- stale count. Originally only guarded against on PLAYER_ENTERING_WORLD,
-- but Battlewrath reported the identical symptom on a plain mid-session
-- roster change: "roster doesn't update on player join. I had to manually
-- run it once when someone joined" - the same race, just triggered by
-- GROUP_ROSTER_UPDATE instead of a reload. Generalized the delayed
-- re-check to run after ANY of these events, not just entering world.
-- It re-runs the same refresh ~2s later, by which point the client's
-- group data is reliably settled, instead of depending on luck (or
-- /coasp roster run by hand) to correct it.
--
-- v3.5.5 (2026-07-09): swaps the original manual OnUpdate elapsed-time
-- accumulator (a tiny frame counting elapsed time itself, built because
-- WotLK 3.3.5 has no C_Timer) for C_Timer.After, now that C_Timer is
-- confirmed a genuine Ascension client global - not a shim, already relied
-- on directly by TurboPlates' own Nameplates.lua/Auras.lua/Core.lua. Same
-- ~2s one-shot re-check, but the client's own timer does the waiting
-- instead of this addon polling every single rendered frame during that
-- window. Battlewrath: "It gives us basis to use that for other similar
-- event handling. So we don't engrain custom internal clocks when we can
-- have the game do it for us." recheckPending is still a plain boolean
-- guard (mirrors TurboPlates' own ScheduleThreatUpdate/ScheduleHealthUpdate
-- pending-timer-flag pattern) rather than a cancel/reset - a second event
-- arriving while one is already pending does not restart the wait, matching
-- the old OnUpdate version's exact behavior.
local recheckPending = false
local recheckReason = nil

local groupEventFrame = CreateFrame("Frame")
groupEventFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
groupEventFrame:RegisterEvent("ROLE_CHANGED_INFORM")
groupEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
groupEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
groupEventFrame:SetScript("OnEvent", function(self, event)
    DoRefresh(event)
    if not recheckPending then
        recheckPending = true
        recheckReason = event
        C_Timer.After(2, function()
            recheckPending = false
            DoRefresh((recheckReason or "?") .. " delayed re-check")
        end)
    end
end)

-- ---------------------------------------------------------------------
-- Plate structure resolution
-- ---------------------------------------------------------------------

-- Finds the plate's name FontString + the container it lives in. Tries the
-- common CompactUnitFrame-style layout first (plate.UnitFrame.name), then
-- falls back to the name living directly on the plate. Returns nil, nil if
-- neither matches, so callers can fall back to old-style full suppression.
function ns.GetNameRegion(plate)
    if plate.UnitFrame and plate.UnitFrame.name then
        return plate.UnitFrame.name, plate.UnitFrame
    end
    if plate.name then
        return plate.name, plate
    end
    return nil, nil
end

-- Finds the plate's health bar StatusBar, using the same UnitFrame
-- container GetNameRegion already resolves. Returns nil if not found, so
-- callers can just skip coloring rather than error.
function ns.GetHealthBar(plate)
    if plate.UnitFrame and plate.UnitFrame.healthBar then
        return plate.UnitFrame.healthBar
    end
    if plate.healthBar then
        return plate.healthBar
    end
    return nil
end

-- ---------------------------------------------------------------------
-- EXECUTOR PRIMITIVES (v3.0) - the only code in this addon that actually
-- touches a plate's visual state. Friendly and Threat compute what they
-- want and call these; neither ever calls SetAlpha/SetStatusBarColor/
-- SetTextColor/the glow library directly. See the v3.0 doc note above.
-- ---------------------------------------------------------------------

-- SIBLING CACHE (v2.2, 2026-07-08) - GetChildren()/GetRegions() were being
-- re-queried from scratch every single rendered frame just to hide the same
-- set of regions over and over. A pooled nameplate frame's structural
-- children are fixed by its XML template - only the OCCUPANT changes, not
-- the container's own child/region list - so the sibling set is cached
-- directly on the container the first time it's resolved and only
-- recomputed on the reclassify cadence (RefreshPlateSiblings) rather than
-- every frame.
local function RefreshSiblingsCache(container, nameRegion)
    local siblings = {}

    local childResults = { pcall(container.GetChildren, container) }
    if childResults[1] then
        for i = 2, #childResults do
            local child = childResults[i]
            if child and child ~= nameRegion then
                table.insert(siblings, child)
            end
        end
    end

    local regionResults = { pcall(container.GetRegions, container) }
    if regionResults[1] then
        for i = 2, #regionResults do
            local region = regionResults[i]
            if region and region ~= nameRegion then
                table.insert(siblings, region)
            end
        end
    end

    container.coagpSiblings = siblings
    return siblings
end

local function GetSiblings(container, nameRegion)
    return container.coagpSiblings or RefreshSiblingsCache(container, nameRegion)
end

-- Forces a fresh sibling-list requery for a plate - called on ADD and every
-- reclassify tick so the cache's staleness window is bounded to that
-- cadence rather than "however long this plate happens to stay suppressed."
function ns.RefreshPlateSiblings(plate)
    local nameRegion, container = ns.GetNameRegion(plate)
    if nameRegion and container then
        pcall(RefreshSiblingsCache, container, nameRegion)
    end
end

-- Hides every sibling of the name region (health bar, portrait, border,
-- cast bar, etc.) while explicitly keeping the name itself at alpha 1, so
-- the floating name stays visible even while the rest of the plate is
-- suppressed. Returns false (does nothing else) if the expected structure
-- isn't found, so the caller can fall back to full-plate SetAlpha.
function ns.SetSuppressed(plate, hidden)
    local nameRegion, container = ns.GetNameRegion(plate)
    if not nameRegion or not container then
        return false
    end

    for _, region in ipairs(GetSiblings(container, nameRegion)) do
        pcall(region.SetAlpha, region, hidden and 0 or 1)
    end

    pcall(nameRegion.SetAlpha, nameRegion, 1)
    return true
end

-- Reveals ONLY the health bar on top of an otherwise-suppressed plate
-- (healer mode's partial reveal) - name stays visible as usual, everything
-- else (level text, portrait, cast bar) stays hidden.
function ns.SetPartialReveal(plate)
    local okSelective, didSelective = pcall(ns.SetSuppressed, plate, true)
    if not (okSelective and didSelective) then
        pcall(plate.SetAlpha, plate, 0) -- fallback: no partial reveal possible
        return
    end
    local healthBar = ns.GetHealthBar(plate)
    if healthBar then
        pcall(healthBar.SetAlpha, healthBar, 1)
    end
end

-- Health bar color - capture-native-once, tint, restore-on-clear. Shared by
-- both modules (Friendly's NPC/pet tint, Enemy's instance-fill tint) since
-- they operate on disjoint friendly/hostile unit sets - one capture table
-- is enough, and centralizing it means there's exactly one implementation
-- of "how do I safely tint a health bar and put it back" in the addon.
local originalHealthBarColors = {}

-- RENDER-SIDE LOGGING (v3.5.7) - see EnemyPlates.lua's ApplyThreatColorForUnit
-- doc note for the full reasoning. These executor primitives were entirely
-- silent before - a caller's dispatch could be logged as "sent" while the
-- actual write silently no-op'd here (e.g. GetHealthBar failing to resolve
-- a region), with no way to tell the two apart from /coasp log alone.
function ns.SetHealthBarColor(unit, plate, color)
    local healthBar = ns.GetHealthBar(plate)
    if not healthBar then
        if ns.IsLogging() then
            ns.Log("Core", "SetHealthBarColor(%s) -> no health bar resolved, NOT applied", tostring(unit))
        end
        return
    end
    if not originalHealthBarColors[unit] then
        local okGet, r, g, b = pcall(healthBar.GetStatusBarColor, healthBar)
        if okGet and r then
            originalHealthBarColors[unit] = { r = r, g = g, b = b }
        end
    end
    pcall(healthBar.SetStatusBarColor, healthBar, color.r, color.g, color.b)
    -- v3.6.0 STALENESS FIX: also arm the NATIVE override slot
    -- (optionTable.healthBarColorOverride, UpdateHealthColor:523) - the
    -- native event-driven repaints that used to sneak native colors back in
    -- between our ticks now re-assert OUR tint instead. The direct paint
    -- above stays for structures without a UnitFrame (fallback layout).
    local armed = ns.SetPlateOption(unit, plate, "healthBarColorOverride",
        { r = color.r, g = color.g, b = color.b })
    if ns.IsLogging() then
        ns.Log("Core", "SetHealthBarColor(%s) -> applied (r=%.2f g=%.2f b=%.2f)%s",
            tostring(unit), color.r, color.g, color.b,
            armed and " + native override armed" or " (no UnitFrame - direct paint only)")
    end
end

-- `plate` may be nil (unit already gone) - if so, and a capture exists,
-- there's nothing left to visually restore, but the capture is still
-- forgotten so a future override starts from a fresh baseline.
function ns.ClearHealthBarColor(unit, plate)
    -- v3.6.0: disarm the native override first, then let the native logic
    -- repaint the CORRECT current color itself (better than restoring a
    -- possibly-stale captured color; the captured restore below stays as
    -- the fallback for structures without a UnitFrame).
    if plate and ns.SetPlateOption(unit, plate, "healthBarColorOverride", nil) then
        ns.RefreshPlateColor(plate)
    end
    local c = originalHealthBarColors[unit]
    if not c then return end
    if plate then
        local healthBar = ns.GetHealthBar(plate)
        if healthBar then
            pcall(healthBar.SetStatusBarColor, healthBar, c.r, c.g, c.b)
            if ns.IsLogging() then
                ns.Log("Core", "ClearHealthBarColor(%s) -> restored native color", tostring(unit))
            end
        elseif ns.IsLogging() then
            ns.Log("Core", "ClearHealthBarColor(%s) -> plate given but no health bar resolved, native color NOT restored", tostring(unit))
        end
    elseif ns.IsLogging() then
        ns.Log("Core", "ClearHealthBarColor(%s) -> no plate, capture forgotten without visual restore", tostring(unit))
    end
    originalHealthBarColors[unit] = nil
end

function ns.HasHealthBarColorOverride(unit)
    return originalHealthBarColors[unit] ~= nil
end

-- Name text color - same capture/restore shape as health bar color, kept as
-- a separate table since the name region is a different object (FontString,
-- not StatusBar) and may resolve even when the health bar doesn't (or vice
-- versa) depending on layout. Only Friendly uses this today (name tinting
-- alongside the NPC/pet health-bar tint), but it's a generic Core primitive
-- like everything else in this section.
local originalNameColors = {}

function ns.SetNameColor(unit, plate, color)
    local nameRegion = select(1, ns.GetNameRegion(plate))
    if not nameRegion then return end
    if not originalNameColors[unit] then
        local okGet, r, g, b = pcall(nameRegion.GetTextColor, nameRegion)
        if okGet and r then
            originalNameColors[unit] = { r = r, g = g, b = b }
        end
    end
    pcall(nameRegion.SetTextColor, nameRegion, color.r, color.g, color.b)
end

function ns.ClearNameColor(unit, plate)
    local c = originalNameColors[unit]
    if not c then return end
    if plate then
        local nameRegion = select(1, ns.GetNameRegion(plate))
        if nameRegion then
            pcall(nameRegion.SetTextColor, nameRegion, c.r, c.g, c.b)
        end
    end
    originalNameColors[unit] = nil
end

function ns.HasNameColorOverride(unit)
    return originalNameColors[unit] ~= nil
end

-- GLOW (v2.4-2.7 history, generalized v3.0) - an animated PixelGlow border
-- via the shared LibCustomGlow-1.0 library (embedded under Libs\ - own copy,
-- not relying on TurboPlates'/WeakAuras' already-loaded one, so this keeps
-- working even if both of those addons are ever disabled), falling back to
-- a static Backdrop-border technique if the library ever fails to load.
-- Generalized from the original threat-only implementation into a Core
-- primitive keyed by `key`, since LibCustomGlow's own PixelGlow_Start
-- supports multiple independent named glows on the same frame - a future
-- capability (e.g. the deferred "needs action" highlight) can request its
-- own glow via its own key without colliding with Threat's.
local LCG = LibStub and LibStub("LibCustomGlow-1.0", true)
ns.LCG = LCG

local function GetOrCreateGlowFrame(healthBar)
    local glowFrame = healthBar.coagpGlowFrame
    if glowFrame then return glowFrame end

    glowFrame = CreateFrame("Frame", nil, healthBar)
    glowFrame:SetFrameLevel(healthBar:GetFrameLevel() + 5)
    glowFrame:Hide()

    healthBar.coagpGlowFrame = glowFrame
    return glowFrame
end

-- Static border fallback (v2.4-2.6 original technique) - single instance
-- per health bar, not keyed, since it's only ever a degraded fallback for
-- when LCG isn't available at all (not expected to coexist with multiple
-- simultaneous glow requesters in practice).
local function GetOrCreateFallbackBorder(healthBar)
    local border = healthBar.coagpFallbackBorder
    if border then return border end

    border = CreateFrame("Frame", nil, healthBar)
    border:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -2, 2)
    border:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 2, -2)
    border:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8 })
    border:SetFrameLevel(healthBar:GetFrameLevel() + 1)
    border:EnableMouse(false)
    border:Hide()

    healthBar.coagpFallbackBorder = border
    return border
end

-- Reusable color table (mirrors TurboPlates' own highlightColorTable) to
-- avoid creating garbage on every reapply.
local glowColorTable = { 1, 1, 1, 1 }

-- VISUAL REDESIGN (v3.4, 2026-07-08) - Battlewrath's words: "the dash lines
-- are very.. technical, for a fantasy game... Cue/threat change: A immidiate
-- glow around the plate. Danger state: A wider glow area, stronger
-- saturation. Motion if we find something that looks nice." The rotating
-- dashed PixelGlow border (kept below as a legacy fallback technique only)
-- reads well at the small icon scale used elsewhere in the project (40x30px
-- WeakAuras rotation icons) but not at nameplate scale. Three tiers now map
-- to three different LibCustomGlow techniques instead of one dash style at
-- varying color:
--   "cue"    - ButtonGlow: the classic soft "ability ready" bloom (inner +
--              outer glow plus a fading spark/ants ring). No discrete motion,
--              just an ambient pulse that appears immediately - matches
--              "an immediate glow around the plate".
--   "danger" - AutoCastGlow: small shimmering particles orbiting a ring
--              pushed further out from the plate than the Cue bloom, with
--              boosted color saturation - matches "a wider glow area,
--              stronger saturation. Motion".
--   "pixel"  - the original rotating dashed-segment technique. No longer
--              used by Enemy Plates as of v3.4, kept only as the default
--              fallback style for any future caller that doesn't specify one.
-- Secure state uses no glow at all (health-bar fill only) - unchanged, see
-- EnemyPlates.lua's `showGlow = color and stateName ~= "secure"` gate.
--
-- Because ButtonGlow_Start has no `key` concept of its own (one glow per
-- frame, full stop), and a given (healthBar, key) pair may switch technique
-- across calls (e.g. warning -> danger), we track the last-applied style per
-- (healthBar, key) so ClearGlow/SetGlow can stop the *correct* LCG function
-- before starting a new one instead of leaking a still-animating glow.
local activeGlowStyle = {} -- [healthBar] = { [key] = a GLOW_STYLE_PARAMS key }

-- GLOW STYLE PARAMETERS (v3.5.13, 2026-07-09) - Battlewrath: "Texture /
-- properties being constants, if we can / one lookup location we can
-- modify." These were previously inline literal arguments scattered through
-- each LCG *_Start branch in SetGlow below, each with its own inline comment
-- explaining what the positional argument meant - correct, but tuning any
-- one value meant editing SetGlow's own control flow to find it. Centralized
-- here instead: one table per named LOOK, one lookup - retuning means
-- editing a value in this table, never SetGlow's own logic.
--
-- RESTRUCTURED (v3.5.14, 2026-07-09) - originally keyed by LCG TECHNIQUE
-- name (cue/danger/pixel), which conflated "which look is this" with "which
-- LCG function renders it." That broke down the moment Battlewrath handed
-- over concrete tuned numbers from a WeakAuras aurabar prototype (its glow
-- subregion export) for BOTH threat states using the SAME technique
-- (glowType: "Pixel") but different N/frequency/thickness per state - there
-- was no way to have two different "Pixel" tunings under the old cue/danger/
-- pixel technique-name keys. Now each entry names a LOOK (what EnemyPlates.lua
-- actually asks for) and carries its own `technique` field (which LCG
-- function to call) plus that technique's own tuned parameters - decoupled,
-- so two looks can share a technique with different numbers, or a future
-- look could pick a different technique entirely, all from this one table.
-- `cue`/`autocast`/`pixel` are kept as generic, technique-named base
-- entries for any future caller that just wants "the stock bloom/shimmer/
-- dash" as-is; `threatWarning`/`threatDanger` are Enemy Plates' own tuned
-- looks (see their own doc note below for where the numbers came from).
local GLOW_STYLE_PARAMS = {
    cue = {
        -- ButtonGlow_Start(frame, color, frequency, frameLevel)
        technique = "cue",
        frequency = 0,
        frameLevel = 8,
    },
    autocast = {
        -- AutoCastGlow_Start(frame, color, N, frequency, scale, xOffset, yOffset, key, frameLevel)
        -- These are the original v3.4.1 "danger" tier numbers (Battlewrath:
        -- "still a big aggressive... lots of dotted points tracing around
        -- super fast... something that says 'you should act' not 'panic
        -- panic panic'") - kept here as the generic AutoCastGlow base entry
        -- now that Enemy Plates' own danger tier has moved to PixelGlow
        -- (see threatDanger below); still available to any future caller
        -- that wants this specific shimmer look.
        technique = "autocast",
        saturationBoost = 1.6,
        n = 2,
        frequency = 0.18,
        scale = 1.8,
        xOffset = 3,
        yOffset = 3,
        frameLevel = 8,
    },
    pixel = {
        -- PixelGlow_Start(frame, color, N, frequency, length, thickness, xOffset, yOffset, border, key, frameLevel)
        -- Generic default/fallback look - used when SetGlow is called with
        -- no style at all, or an unrecognized one.
        technique = "pixel",
        n = 8,
        frequency = 0.25,
        length = 6,
        thickness = 2,
        xOffset = 1,
        yOffset = 1,
        border = false,
        frameLevel = 8,
    },

    -- PORTED FROM WEAKAURAS PROTOTYPE (v3.5.14, 2026-07-09) - Battlewrath
    -- built and live-tuned "Danger"/"Warning" aurabar prototypes in
    -- WeakAuras (per the earlier note: "Still need to test with weak aura
    -- the lib effects to land on something"), then exported both and said
    -- "Focus is the glow effect properties only" - i.e. read past the
    -- aurabar/texture/spark/border container (that was just the WeakAuras
    -- scratch canvas) straight to each aura's "subglow" subRegion, which is
    -- WeakAuras' own LibCustomGlow-backed glow widget - the exact same
    -- library this addon embeds. Both tuned looks use glowType "Pixel", so
    -- both threat tiers now render via PixelGlow_Start instead of the
    -- previous ButtonGlow("cue")/AutoCastGlow("danger") split.
    --
    -- `length` is deliberately OMITTED for threatWarning, not ported as a
    -- literal pixel value - the WeakAuras prototype's glowLength (10) was
    -- tuned against its own 148x6.8px scratch aurabar, which has no fixed
    -- relationship to a real nameplate's much smaller health bar.
    -- PixelGlow_Start already auto-derives a proportional dash length from
    -- whatever frame it's actually applied to when `length` is nil (see
    -- LibCustomGlow-1.0.lua's own `length = length or floor((width + height)
    -- * (2 / N - 0.1))`) - letting the library do that math means the look
    -- scales correctly onto our actual health bar frame size instead of
    -- guessing a fixed number. threatDanger CANNOT rely on this auto-derive,
    -- though - see its own v3.5.15 doc note below for why an explicit
    -- `length` is required there instead.
    -- `xOffset`/`yOffset` came through as 0/0 in both prototypes (WeakAuras'
    -- own glow subregion was anchored flush to its "bg" area with no extra
    -- padding) - see SetGlow's own glowFrame anchor below (tightened from
    -- +/-2px to +/-0.5px per Battlewrath's "pad it from the bar border 0.5px
    -- or something") for where the remaining, separate outer-frame padding
    -- lives.
    threatWarning = {
        technique = "pixel",
        n = 10,            -- glowLines
        frequency = -0.05, -- glowFrequency (sign preserved - spins opposite to danger)
        thickness = 1,     -- glowThickness
        xOffset = 0,
        yOffset = 0,
        border = false,    -- glowBorder
        frameLevel = 8,
    },
    threatDanger = {
        technique = "pixel",
        saturationBoost = 1.6, -- kept from the old AutoCastGlow danger tuning - still reads as more intense than warning even off the same 3 user-configured colors
        n = 30,            -- glowLines
        frequency = 0.05,  -- glowFrequency
        thickness = 1,     -- glowThickness
        xOffset = 0,
        yOffset = 0,
        border = false,    -- glowBorder
        frameLevel = 8,
        -- LENGTH BUG FIX (v3.5.15, 2026-07-09) - Battlewrath live-tested this
        -- and confirmed: "The danger glow isn't rendering." Root cause: this
        -- entry deliberately left `length` nil (see the v3.5.14 doc note
        -- above) so PixelGlow_Start would auto-derive a proportional dash
        -- length via its own `floor((width + height) * (2 / N - 0.1))`
        -- formula - but that formula goes NEGATIVE once N reaches 20
        -- (2/30 - 0.1 = -0.033 here), and a negative length gets passed
        -- straight into a Frame:SetSize() call inside the library's OnUpdate
        -- script, which silently fails every frame - nothing ever draws, no
        -- error surfaced to /coasp log since it happens inside LCG's own
        -- per-frame callback, outside our SetGlow pcall. threatWarning's
        -- N=10 stayed safe (2/10 - 0.1 = 0.1, positive) - that's why only
        -- danger broke. Explicit small positive length here sidesteps the
        -- auto-formula's unsafe domain entirely for this N.
        length = 4,
    },
}

local function StopGlowStyle(healthBar, key, style)
    local glowFrame = healthBar.coagpGlowFrame
    if not LCG or not glowFrame then return end
    local params = GLOW_STYLE_PARAMS[style] or GLOW_STYLE_PARAMS.pixel
    if params.technique == "cue" then
        pcall(LCG.ButtonGlow_Stop, glowFrame)
    elseif params.technique == "autocast" then
        pcall(LCG.AutoCastGlow_Stop, glowFrame, key)
    else
        pcall(LCG.PixelGlow_Stop, glowFrame, key)
    end
end

-- Boosts HSV saturation by `factor` (capped at 1) so the Danger tier reads
-- as more intense than Cue even though both draw from the same 3 user-
-- configured colors - literal "stronger saturation" per Battlewrath's spec.
local function BoostSaturation(r, g, b, factor)
    local maxC, minC = math.max(r, g, b), math.min(r, g, b)
    local delta = maxC - minC
    if delta <= 0 or maxC <= 0 then
        return r, g, b -- gray or black - nothing to boost
    end

    local h
    if maxC == r then
        h = ((g - b) / delta) % 6
    elseif maxC == g then
        h = (b - r) / delta + 2
    else
        h = (r - g) / delta + 4
    end
    h = h * 60

    local s = math.min((delta / maxC) * factor, 1)
    local v = maxC

    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c
    local r2, g2, b2
    if h < 60 then r2, g2, b2 = c, x, 0
    elseif h < 120 then r2, g2, b2 = x, c, 0
    elseif h < 180 then r2, g2, b2 = 0, c, x
    elseif h < 240 then r2, g2, b2 = 0, x, c
    elseif h < 300 then r2, g2, b2 = x, 0, c
    else r2, g2, b2 = c, 0, x
    end

    return r2 + m, g2 + m, b2 + m
end

-- Starts (or restarts, with a possibly-new color/style) an animated glow on
-- a plate's health bar, keyed by `key` so multiple independent glows could
-- coexist on the same bar in the future. `style` selects a GLOW_STYLE_PARAMS
-- entry above (name + technique + tuning); defaults to the generic "pixel"
-- look for backward compatibility if omitted or unrecognized.
function ns.SetGlow(plate, color, key, style)
    local healthBar = ns.GetHealthBar(plate)
    if not healthBar then
        if ns.IsLogging() then
            ns.Log("Core", "SetGlow(key=%s, style=%s) -> no health bar resolved, glow NOT applied", tostring(key), tostring(style))
        end
        return
    end
    style = style or "pixel"
    local p = GLOW_STYLE_PARAMS[style] or GLOW_STYLE_PARAMS.pixel

    if LCG then
        local glowFrame = GetOrCreateGlowFrame(healthBar)
        glowFrame:ClearAllPoints()
        -- PADDING (v3.5.14) - tightened from +/-2px to +/-0.5px, Battlewrath:
        -- "Might need to see if you can pad it from the bar border 0.5 px or
        -- something" - matches how the WeakAuras prototype anchored its own
        -- glow subregion flush to its "bg" area (glowXOffset/glowYOffset both
        -- 0) rather than floating a couple pixels out from it.
        glowFrame:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -0.5, 0.5)
        glowFrame:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 0.5, -0.5)
        glowFrame:Show()

        activeGlowStyle[healthBar] = activeGlowStyle[healthBar] or {}
        local lastStyle = activeGlowStyle[healthBar][key]
        if lastStyle and lastStyle ~= style then
            StopGlowStyle(healthBar, key, lastStyle)
        end
        activeGlowStyle[healthBar][key] = style
        if ns.IsLogging() then
            ns.Log("Core", "SetGlow(key=%s) -> style=%s (technique=%s) started via LibCustomGlow%s",
                tostring(key), style, tostring(p.technique), (lastStyle and lastStyle ~= style) and (" (switched from " .. tostring(lastStyle) .. ")") or "")
        end

        local r, g, b = color.r, color.g, color.b
        if p.saturationBoost and p.saturationBoost ~= 1 then
            r, g, b = BoostSaturation(color.r, color.g, color.b, p.saturationBoost)
        end
        glowColorTable[1], glowColorTable[2], glowColorTable[3], glowColorTable[4] = r, g, b, 1

        if p.technique == "cue" then
            local ok, err = pcall(LCG.ButtonGlow_Start, glowFrame, glowColorTable, p.frequency, p.frameLevel)
            if not ok and ns.IsLogging() then
                ns.Log("Core", "SetGlow(key=%s) -> ButtonGlow_Start ERROR: %s", tostring(key), tostring(err))
            end

        elseif p.technique == "autocast" then
            local ok, err = pcall(LCG.AutoCastGlow_Start, glowFrame, glowColorTable, p.n, p.frequency, p.scale, p.xOffset, p.yOffset, key, p.frameLevel)
            if not ok and ns.IsLogging() then
                ns.Log("Core", "SetGlow(key=%s) -> AutoCastGlow_Start ERROR: %s", tostring(key), tostring(err))
            end

        else -- "pixel"
            local ok, err = pcall(LCG.PixelGlow_Start, glowFrame, glowColorTable, p.n, p.frequency, p.length, p.thickness, p.xOffset, p.yOffset, p.border, key, p.frameLevel)
            if not ok and ns.IsLogging() then
                ns.Log("Core", "SetGlow(key=%s) -> PixelGlow_Start ERROR: %s", tostring(key), tostring(err))
            end
        end
    else
        -- FALLBACK: LCG failed to load, use the static border instead.
        local border = GetOrCreateFallbackBorder(healthBar)
        pcall(border.SetBackdropBorderColor, border, color.r, color.g, color.b, 1)
        border:Show()
        if ns.IsLogging() then
            ns.Log("Core", "SetGlow(key=%s) -> LibCustomGlow unavailable, fallback static border applied", tostring(key))
        end
    end
end

-- Stops a glow started via SetGlow, if currently running. Safe to call even
-- if no glow was ever started (each LCG *_Stop already no-ops in that case).
-- `plate` may be nil (unit already gone) - nothing to stop in that case
-- since the frame reference is gone with it. Looks up the style that was
-- actually last applied for this (healthBar, key) so it stops the right
-- LCG technique rather than assuming "pixel".
function ns.ClearGlow(plate, key)
    if not plate then
        if ns.IsLogging() then
            ns.Log("Core", "ClearGlow(key=%s) -> no plate, nothing to clear", tostring(key))
        end
        return
    end
    local healthBar = ns.GetHealthBar(plate)
    if not healthBar then
        if ns.IsLogging() then
            ns.Log("Core", "ClearGlow(key=%s) -> no health bar resolved, nothing to clear", tostring(key))
        end
        return
    end

    local clearedSomething = false
    if healthBar.coagpGlowFrame then
        local styles = activeGlowStyle[healthBar]
        local style = styles and styles[key]
        if LCG then
            StopGlowStyle(healthBar, key, style or "pixel")
        end
        if styles then styles[key] = nil end
        healthBar.coagpGlowFrame:Hide()
        clearedSomething = true
    end
    if healthBar.coagpFallbackBorder then
        healthBar.coagpFallbackBorder:Hide()
        clearedSomething = true
    end
    if ns.IsLogging() then
        ns.Log("Core", "ClearGlow(key=%s) -> %s", tostring(key), clearedSomething and "glow/border hidden" or "no active glow found, no-op")
    end
end

-- NATIVE AGGRO HIGHLIGHT RECOLOR (v3.5.18) - Battlewrath's /coasp probe
-- capture found a native nameplate region we don't own: a Frame named
-- "...aggroHighlight" nested inside the health bar (sibling of
-- healthBarElements), holding one Texture ("...aggroHighlightTexture",
-- texture Interface/TargetingFrame/UI-TargetingFrame-BarFill) hardcoded to
-- vertexColor 1,0,0,1 at the OVERLAY layer - Ascension_NamePlates' own
-- built-in "you have aggro" indicator, entirely separate from and drawn on
-- top of this addon's own LibCustomGlow effect. Battlewrath's call after
-- seeing it ("Recolor to match our states"): drive this native texture's
-- color from our own resolved threat color instead of leaving it always
-- red, so the native signal reinforces ours instead of contradicting it.
-- Located via the same GetRegions() child-scan the probe tool already
-- proved works for the texture itself. (This comment originally claimed
-- aggroHighlight was reachable as a stable Lua field on the health bar,
-- matching how GetHealthBar reaches plate.UnitFrame.healthBar - that claim
-- was WRONG, an unverified guess that live testing disproved 100% of the
-- time; see GetNativeAggroHighlightFrame's own v3.5.22 doc note for the
-- correction and the actual, proven lookup.)
-- v3.5.20 - split out the frame lookup on its own (was inlined inside
-- GetNativeAggroHighlightTexture) since ForceShowNativeAggroHighlight below
-- needs the FRAME itself (to Show()/SetAlpha it), not just its child
-- texture - see that function's own doc note for why.
--
-- v3.5.22 FIX - `healthBar.aggroHighlight` was a guess based on how the
-- frame's NAME looked in the original probe capture (healthBar's own name +
-- an "aggroHighlight" suffix) - but that probe actually found the frame by
-- enumerating healthBar:GetChildren() positionally, never through that Lua
-- key. Live testing exposed this: Battlewrath's captures showed
-- SetNativeAggroHighlightColor/ForceShowNativeAggroHighlight reporting "not
-- found" 100% of the time, including on Moonrage Whitescalp while it was
-- actively tanked and targeted - the exact mob an earlier probe had proven
-- has this structure. A 100%, deterministic failure on a known-good plate
-- rules out "maybe it's lazily created" and points squarely at the lookup
-- itself being wrong (indexing a Lua field that was never actually set just
-- silently returns nil - no error, so this went undetected until live play
-- surfaced it). Fixed to try the frame's own predictable global name first
-- (healthBar's name + "aggroHighlight", the exact pattern every probe
-- capture has shown), falling back to the same GetChildren() scan the probe
-- tool itself has always used and proven reliable if the name guess ever
-- doesn't resolve (e.g. a differently-numbered template).
-- ---------------------------------------------------------------------
-- STEERING PRIMITIVES (v3.6.0) - the at-source lane.
--
-- Source basis (patch-B extraction, readable since 2026-07-15):
-- CompactUnitFrame.lua drives every native plate visual off
-- `self.optionTable`, assigned BY REFERENCE to the shared global
-- DefaultCompactNamePlate*FrameOptions in SetUpFrame (:2188). Two facts
-- make steering strictly better than repainting/hooking:
--   1. optionTable.healthBarColorOverride is the FIRST-priority branch of
--      UpdateHealthColor (:523) - set it and every native repaint paints
--      OUR color. The event-driven re-asserts that caused the staleness
--      leak become the enforcement mechanism.
--   2. The aggro highlight, threat borders and aggro flash are all
--      option-gated - the native code hides/shows/colors its own visuals
--      when the options say so. No Show()/SetVertexColor races ever again.
--
-- Per-unit steering without touching other plates: wrap the frame's
-- optionTable in a per-frame table that __index-falls-through to the
-- shared one. The driver re-runs SetUpFrame on every plate (re)assignment,
-- which resets optionTable to the shared default - so recycling cleans up
-- after us, and modules re-apply in OnUnitAdded (which runs after the
-- driver's own handler by addon load order: Ascension_* < COA_*).
--
-- The driver's own config refresh (NamePlateDriver.lua:48-72) never writes
-- the fields we steer (verified by source grep 2026-07-17), so nothing
-- fights these overrides.
-- ---------------------------------------------------------------------

-- Resolves the plate's CompactUnitFrame (the thing that owns optionTable
-- and the Update* methods). Same container GetNameRegion resolves.
function ns.GetUnitFrame(plate)
    return plate and plate.UnitFrame or nil
end

-- Ensures the frame has its own steerable optionTable wrapper; returns it.
-- Reads fall through to the shared table (driver config stays live), our
-- rawset overrides sit on top. Idempotent per assignment cycle.
function ns.EnsureSteerableOptions(plate)
    local uf = ns.GetUnitFrame(plate)
    if not uf or not uf.optionTable then return nil end
    local opts = uf.optionTable
    if rawget(opts, "coaspSteered") then return opts end
    local wrapped = setmetatable({ coaspSteered = true }, { __index = opts })
    local ok = pcall(uf.SetOptionTable, uf, wrapped)
    if not ok then return nil end
    return wrapped
end

-- The generic steering write: set (or clear, value=nil) one option override
-- on one plate. Returns true if the write landed.
function ns.SetPlateOption(unit, plate, key, value)
    plate = plate or ns.GetIndexedPlate(unit)
    local opts = ns.EnsureSteerableOptions(plate)
    if not opts then return false end
    rawset(opts, key, value)
    return true
end

-- Immediate-apply helpers: the native code repaints on its own events, but
-- a fresh override deserves a same-tick refresh rather than waiting.
function ns.RefreshPlateColor(plate)
    local uf = ns.GetUnitFrame(plate)
    if uf and uf.UpdateHealthColor then pcall(uf.UpdateHealthColor, uf) end
end

function ns.RefreshPlateBorder(plate)
    local uf = ns.GetUnitFrame(plate)
    if uf and uf.UpdateHealthBorder then pcall(uf.UpdateHealthBorder, uf) end
end

-- Health-bar color via the native override slot (UpdateHealthColor:523).
-- color = {r=,g=,b=} or nil to clear back to native logic.
function ns.SetPlateColorOverride(unit, plate, color)
    plate = plate or ns.GetIndexedPlate(unit)
    if not ns.SetPlateOption(unit, plate, "healthBarColorOverride", color) then
        return false
    end
    ns.RefreshPlateColor(plate)
    return true
end

-- Native aggro highlight steering (UpdateAggroHighlight:770-776):
-- enabled=false hides it natively; nil falls back to the shared default.
function ns.SetNativeAggro(unit, plate, enabled)
    plate = plate or ns.GetIndexedPlate(unit)
    if not ns.SetPlateOption(unit, plate, "displayAggroHighlight", enabled) then
        return false
    end
    local uf = ns.GetUnitFrame(plate)
    if uf and uf.UpdateAggroHighlight then pcall(uf.UpdateAggroHighlight, uf) end
    return true
end

function ns.GetNativeAggroHighlightFrame(plate)
    local healthBar = ns.GetHealthBar(plate)
    if not healthBar then return nil end

    local okName, healthBarName = pcall(healthBar.GetName, healthBar)
    if okName and healthBarName then
        local byName = _G[healthBarName .. "aggroHighlight"]
        if byName then return byName end
    end

    local children = { pcall(healthBar.GetChildren, healthBar) }
    if children[1] then
        for i = 2, #children do
            local child = children[i]
            if child then
                local okChildName, childName = pcall(child.GetName, child)
                if okChildName and childName and childName:find("aggroHighlight$") then
                    return child
                end
            end
        end
    end
    return nil
end

function ns.GetNativeAggroHighlightTexture(plate)
    local frame = ns.GetNativeAggroHighlightFrame(plate)
    if not frame then return nil end

    local regions = { pcall(frame.GetRegions, frame) }
    if regions[1] then
        for i = 2, #regions do
            local region = regions[i]
            if region then
                local okType, objType = pcall(region.GetObjectType, region)
                if okType and objType == "Texture" then
                    return region
                end
            end
        end
    end
    return nil
end

-- NATIVE_AGGRO_DEFAULT_COLOR - the vertexColor the probe capture actually
-- observed on this texture (pure red, full alpha) - what ClearNative...
-- restores to, since that's this client's own native default, not a made-up
-- placeholder.
local NATIVE_AGGRO_DEFAULT_COLOR = { r = 1, g = 0, b = 0 }

-- v3.5.40 - REAL FIX, this time confirmed against a live callstack rather
-- than a guessed function name. "/coasp watchaggro" caught the actual
-- driver red-handed: CompactUnitFrame.lua:773 UpdateAggroHighlight, called
-- via UpdateAll <- SetUnit <- Ascension_NamePlates\NamePlateDriver.lua:227 -
-- confirming this client backports the Legion/BfA CompactUnitFrame
-- nameplate system (see v3.5.39's doc note for the research that predicted
-- this and the corroborating GetHealthBar fallback). The watchaggro hook
-- that caught this was already installed on the aggroHighlight TEXTURE
-- INSTANCE's own SetVertexColor method via hooksecurefunc(texture,
-- "SetVertexColor", ...) - not a global function name - which is exactly
-- why it fired regardless of what UpdateAggroHighlight is actually called
-- or where it lives (CompactUnitFrame.lua is packed inside this client's
-- MPQ archives, not a loose readable file, so the source itself was never
-- inspectable - the instance hook doesn't need it to be). v3.5.33's old
-- hook failed because it targeted the WRONG function entirely
-- (UnitFrame_UpdateThreatIndicator, which nameplates never pass through);
-- this one is confirmed, by direct observation, to intercept every call
-- that actually touches this exact texture, no matter its source.
--
-- Upgraded from a one-shot SetVertexColor call to a PERSISTENT per-texture
-- post-hook: the first time SetNativeAggroHighlightColor is called for a
-- given texture, a hooksecurefunc is installed that re-applies whatever
-- color is currently "desired" for that texture immediately after ANY
-- native SetVertexColor call - including the one CompactUnitFrame_Update-
-- AggroHighlight itself makes. A re-entrancy guard (reapplyingAggroColor)
-- is required because our own reapply call is itself a SetVertexColor call
-- on the same hooked instance, which would otherwise retrigger the hook
-- and recurse. ClearNativeAggroHighlightColor sets the desired color to nil
-- (the hook then leaves native color alone entirely) rather than uninstalling
-- the hook, since hooksecurefunc hooks can't be removed once installed
-- anyway - an absent desired-color entry is a cheap, permanent off-switch.
local aggroTextureDesiredColor = {}
local reapplyingAggroColor = {}
local recolorHookInstalled = {}

local function EnsureAggroRecolorHook(texture)
    if recolorHookInstalled[texture] then return end
    recolorHookInstalled[texture] = true
    hooksecurefunc(texture, "SetVertexColor", function(self, r, g, b, a)
        if reapplyingAggroColor[self] then return end
        local desired = aggroTextureDesiredColor[self]
        if not desired then return end
        if r == desired.r and g == desired.g and b == desired.b then return end
        reapplyingAggroColor[self] = true
        local ok = pcall(self.SetVertexColor, self, desired.r, desired.g, desired.b, 1)
        reapplyingAggroColor[self] = nil
        if ns.IsLogging() then
            ns.Log("Core", "Native aggroHighlight recolor -> re-asserted (native set r=%.2f g=%.2f b=%.2f, forced back to r=%.2f g=%.2f b=%.2f, %s)",
                r or -1, g or -1, b or -1, desired.r, desired.g, desired.b, ok and "succeeded" or "FAILED")
        end
    end)
end

function ns.SetNativeAggroHighlightColor(plate, color)
    local texture = ns.GetNativeAggroHighlightTexture(plate)
    if not texture then
        if ns.IsLogging() then
            ns.Log("Core", "SetNativeAggroHighlightColor -> no native aggroHighlight texture found, skipped")
        end
        return false
    end
    EnsureAggroRecolorHook(texture)
    aggroTextureDesiredColor[texture] = { r = color.r, g = color.g, b = color.b }
    reapplyingAggroColor[texture] = true
    local ok = pcall(texture.SetVertexColor, texture, color.r, color.g, color.b, 1)
    reapplyingAggroColor[texture] = nil
    if ns.IsLogging() then
        ns.Log("Core", "SetNativeAggroHighlightColor -> %s (r=%.2f g=%.2f b=%.2f), persistent re-assert hook active",
            ok and "applied" or "SetVertexColor call failed", color.r, color.g, color.b)
    end
    return ok
end

function ns.ClearNativeAggroHighlightColor(plate)
    local texture = ns.GetNativeAggroHighlightTexture(plate)
    if not texture then return end
    aggroTextureDesiredColor[texture] = nil
    reapplyingAggroColor[texture] = true
    pcall(texture.SetVertexColor, texture, NATIVE_AGGRO_DEFAULT_COLOR.r, NATIVE_AGGRO_DEFAULT_COLOR.g, NATIVE_AGGRO_DEFAULT_COLOR.b, 1)
    reapplyingAggroColor[texture] = nil
    if ns.IsLogging() then
        ns.Log("Core", "ClearNativeAggroHighlightColor -> restored native default (red), re-assert hook now inert for this texture")
    end
end

-- SUPPRESS PRIMITIVE (v3.5.42) - Battlewrath found a CurseForge addon
-- (TargetNameplateIndicator) hooking a global named
-- "CompactUnitFrame_UpdateAggroFlash" to Hide() frame.aggroFlash. Treated as
-- unverified rather than copied directly: our own real live callstack
-- capture (v3.5.40's watchaggro probe) named the actual function
-- "UpdateAggroHighlight" (not "AggroFlash"), file-local to CompactUnitFrame.lua
-- (called via a method-style invocation, not a bare global) - the exact
-- "renamed/localized function" possibility v3.5.39 already flagged as a
-- known blind spot for a plain _G name search. A hooksecurefunc on the
-- pasted name would almost certainly error (no such global on this client).
-- Rather than chase another possibly-wrong name, this reuses the SAME
-- instance-scoped hooksecurefunc technique already proven live in v3.5.40
-- (hooking the actual, already-located aggroHighlight FRAME object directly,
-- not a guessed function) - just Hide()ing it back down instead of
-- re-asserting a color, which is a simpler, more surefire way to answer
-- Battlewrath's original ask ("Can we disable the aggression highlight? And
-- then we could replace it with a second of our own?") than fighting the
-- recolor race ever was. Test-only for now via /coasp suppressaggro - not
-- wired into ApplyThreatColorForUnit; see task #266 (focus indicator).
local aggroSuppressDesired = {}
local reapplyingAggroSuppress = {}
local suppressHookInstalled = {}

local function EnsureAggroSuppressHook(frame)
    if suppressHookInstalled[frame] then return end
    suppressHookInstalled[frame] = true
    hooksecurefunc(frame, "Show", function(self)
        if reapplyingAggroSuppress[self] then return end
        if not aggroSuppressDesired[self] then return end
        reapplyingAggroSuppress[self] = true
        local ok = pcall(self.Hide, self)
        reapplyingAggroSuppress[self] = nil
        if ns.IsLogging() then
            ns.Log("Core", "Native aggroHighlight suppress -> re-hidden after native Show() (%s)",
                ok and "succeeded" or "FAILED")
        end
    end)
end

function ns.SuppressNativeAggroHighlight(plate)
    local frame = ns.GetNativeAggroHighlightFrame(plate)
    if not frame then
        if ns.IsLogging() then
            ns.Log("Core", "SuppressNativeAggroHighlight -> no native aggroHighlight frame found, skipped")
        end
        return false
    end
    EnsureAggroSuppressHook(frame)
    aggroSuppressDesired[frame] = true
    local ok = pcall(frame.Hide, frame)
    if ns.IsLogging() then
        ns.Log("Core", "SuppressNativeAggroHighlight -> %s, persistent re-hide hook active",
            ok and "applied" or "Hide() call failed")
    end
    return ok
end

function ns.ClearNativeAggroHighlightSuppress(plate)
    local frame = ns.GetNativeAggroHighlightFrame(plate)
    if not frame then return end
    aggroSuppressDesired[frame] = nil
    if ns.IsLogging() then
        ns.Log("Core", "ClearNativeAggroHighlightSuppress -> suppress hook now inert for this frame (native Show() will render again)")
    end
end

-- v3.5.39 - REOPENED. Battlewrath's follow-up research argues this client is
-- a Legion/BfA-era CompactUnitFrame nameplate backport (C-side event layer
-- roughly matching FrostAtom's awesome_wotlk, plus a custom client-side
-- FrameXML rewrite of CompactUnitFrame's aggro/selection-highlight routines)
-- rather than the plain WotLK UnitFrame_UpdateThreatIndicator path v3.5.38
-- concluded was unreachable. Real corroborating evidence already in THIS
-- addon: ns.GetHealthBar's very first branch checks plate.UnitFrame.healthBar
-- before falling back to plate.healthBar directly - written defensively for
-- exactly this possibility. Counter-evidence: our own live
-- "/coasp scanglobals aggro" sweep never found CompactUnitFrame_UpdateAggro-
-- Highlight (or anything like it) as a global function on this client - but
-- that doesn't disprove a rewritten/renamed/localized version, it just means
-- the exact identifier can't be confirmed from a name search alone. Rather
-- than trust an unverified name (the same mistake the v3.5.32 speculative-
-- candidate-list made), this hooks the ACTUAL, already-confirmed-real
-- aggroHighlight frame/texture instance directly (via the same locators
-- SetNativeAggroHighlightColor already uses) and logs a trimmed debugstack
-- every time Show/Hide/SetVertexColor fires on it - whatever function name
-- that stack names IS the real driver on this client, discovered rather
-- than guessed. hooksecurefunc's table+method-name form (hooksecurefunc(obj,
-- "Method", handler)) hooks that specific instance's calls, not a global
-- function, so this works regardless of whether the driver is a global,
-- local, or renamed function - the instance's own methods are the one thing
-- guaranteed to be called no matter what calls them.
local watchedAggroObjects = {}
local function LogAggroStackHook(label)
    return function(self, ...)
        if ns.IsLogging() then
            local ok, stack = pcall(debugstack, 2, 6, 0)
            ns.Log("Core", "AGGRO STACK WATCH: %s fired. Callstack:\n%s",
                label, ok and tostring(stack) or "<debugstack unavailable on this client>")
        end
    end
end

function ns.WatchNativeAggroHighlight(plate)
    local frame = ns.GetNativeAggroHighlightFrame(plate)
    local texture = ns.GetNativeAggroHighlightTexture(plate)
    if frame and not watchedAggroObjects[frame] then
        watchedAggroObjects[frame] = true
        pcall(hooksecurefunc, frame, "Show", LogAggroStackHook("aggroHighlight FRAME:Show()"))
        pcall(hooksecurefunc, frame, "Hide", LogAggroStackHook("aggroHighlight FRAME:Hide()"))
    end
    if texture and not watchedAggroObjects[texture] then
        watchedAggroObjects[texture] = true
        pcall(hooksecurefunc, texture, "SetVertexColor", LogAggroStackHook("aggroHighlightTexture:SetVertexColor()"))
    end
    return frame ~= nil, texture ~= nil
end

-- FORCE-SHOW TEST PRIMITIVE (v3.5.20) - Battlewrath's live observation after
-- v3.5.19: "This only highlights your current target" - the aggroHighlight
-- Frame/Texture exists on every plate (SetNativeAggroHighlightColor already
-- runs group-wide via ApplyThreatColorForUnit, not just on your target), but
-- Ascension_NamePlates' own logic evidently only ever Shows that frame on
-- whichever plate is your current target - recoloring a Hidden texture has
-- no visible effect elsewhere. Battlewrath: "Can we reuse that texture, so
-- the same one that is on our current target, can [be] seen across the
-- aggro cue group and such" - this is the diagnostic half of answering that:
-- force the frame Shown + colored on a plate regardless of whether it's
-- your target, so a live test can reveal whether Ascension_NamePlates fights
-- that back (re-hides it on its own next update, the same invisible-failure
-- shape as the earlier negative-length PixelGlow bug) or lets it stick.
-- Test-only for now - NOT wired into ApplyThreatColorForUnit's real per-tick
-- path; see EnemyPlates.lua's new "aggroBroadcast" render-test module, which
-- is what actually calls this, across every active hostile plate at once.
function ns.ForceShowNativeAggroHighlight(plate, color)
    local frame = ns.GetNativeAggroHighlightFrame(plate)
    if not frame then
        if ns.IsLogging() then
            ns.Log("Core", "ForceShowNativeAggroHighlight -> no native aggroHighlight frame found, skipped")
        end
        return false
    end
    if color then
        pcall(ns.SetNativeAggroHighlightColor, plate, color)
    end
    pcall(frame.SetAlpha, frame, 1)
    local ok = pcall(frame.Show, frame)
    if ns.IsLogging() then
        ns.Log("Core", "ForceShowNativeAggroHighlight -> %s", ok and "Show()/SetAlpha(1) called" or "Show() call failed")
    end
    return ok
end

-- Undoes ForceShowNativeAggroHighlight - restores the texture to native red
-- and Hides the frame again (handing control back to Ascension_NamePlates'
-- own logic, whatever that turns out to be, rather than leaving it stuck
-- forced-visible after the test ends).
function ns.ClearForcedNativeAggroHighlight(plate)
    local frame = ns.GetNativeAggroHighlightFrame(plate)
    if not frame then return end
    pcall(ns.ClearNativeAggroHighlightColor, plate)
    pcall(frame.Hide, frame)
    if ns.IsLogging() then
        ns.Log("Core", "ClearForcedNativeAggroHighlight -> Hide() called, native red restored")
    end
end

-- NATIVE RE-ASSERT RACE - CONFIRMED AND FIXED (v3.5.32 diagnostic ->
-- v3.5.33 real fix). Battlewrath's live test (grouped, real combat) showed
-- the aggroHighlight staying stock red despite SetNativeAggroHighlightColor
-- reporting "applied" every time at the Lua level with zero errors - native
-- code was re-driving the texture's own color faster than our one-shot-
-- per-state-change call could hold it. Kept ns.ScanGlobalsForPattern (see
-- below) as the general-purpose diagnostic tool, but the hook target search
-- itself is done: "/coasp scanglobals threat" turned up
-- UnitFrame_UpdateThreatIndicator - the real, confirmed WotLK 3.3.5 global
-- (its own source: `indicator:SetVertexColor(GetThreatStatusColor(status))`)
-- - while "/coasp scanglobals aggro" and a highlight-pattern scan turned up
-- NOTHING resembling a nameplate-specific update function (only unrelated
-- UI helpers and the InterfaceOptions aggro-warning checkbox callbacks) -
-- ruling out the retail-style CompactUnitFrame_UpdateAggroHighlight guess
-- entirely; Ascension's nameplate reuses the plain WotLK function as-is.
-- Confirmed live: "/coasp log" showed SPECULATIVE AGGRO HOOK FIRED lines
-- for UnitFrame_UpdateThreatIndicator firing in real combat, right on
-- schedule.
--
-- Upgraded the hook from observe-only to a real fix: whenever
-- UnitFrame_UpdateThreatIndicator fires for ANY unit frame (this function
-- is shared by PlayerFrame/TargetFrame/PartyFrame/BossFrame/nameplates
-- alike - hence 4 hook fires per burst in the log, one per currently-shown
-- frame using it), only recolor if the `indicator` argument's own name
-- contains "aggroHighlight" - the nameplate-specific naming Ascension chose
-- (TargetFrame/PartyFrame's own indicators are named "...Flash" instead, so
-- this cleanly leaves every other unit frame's real native red threat flash
-- untouched, with no need to cross-reference against a specific plate).
-- hooksecurefunc guarantees this runs AFTER the native SetVertexColor call
-- on every single invocation, so it's a real fix rather than a race, and
-- being a plain post-hook (not an override) it can't itself introduce
-- taint the way directly replacing the function would risk.
function ns.ScanGlobalsForPattern(substring)
    local results = {}
    if not substring or substring == "" then return results end
    local needle = substring:lower()
    for key, value in pairs(_G) do
        if type(key) == "string" and type(value) == "function" and key:lower():find(needle, 1, true) then
            table.insert(results, key)
        end
    end
    table.sort(results)
    return results
end

-- v3.5.35 - Battlewrath: "I'd rather work it as a part of the system" -
-- researched (via an AI-assisted search) whether the recolor race is a known
-- problem, and while several of the specific function/CVar names that came
-- back read like retail-era API (CompactUnitFrame_UpdateThreatBorder,
-- THREAT_STATUS_COLORS, nameplateShowThreatGlow - none of which showed up in
-- our own real /coasp scanglobals sweep of this client), the underlying
-- principle is sound and matches real WotLK 3.3.5 FrameXML convention:
-- GetThreatStatusColor (a confirmed-real global on this client, per the
-- scanglobals "threat" sweep) plausibly reads its colors from a plain global
-- table rather than hardcoding them, the same way stock UnitFrame.lua keys
-- ThreatColor/ThreatBarColor by status. If such a table exists, mutating its
-- entries once at load time would make our colors the system's OWN source of
-- truth - no hook, no race, genuinely "part of the system" - rather than
-- fighting a function that re-asserts on its own schedule. ScanGlobalsForPattern
-- only ever matched type(value)=="function", so a color table would have been
-- invisible to it; this sibling scans for tables instead, so we can check for
-- real (rather than trust the pasted, unverified names).
function ns.ScanGlobalTablesForPattern(substring)
    local results = {}
    if not substring or substring == "" then return results end
    local needle = substring:lower()
    for key, value in pairs(_G) do
        if type(key) == "string" and type(value) == "table" and key:lower():find(needle, 1, true) then
            table.insert(results, key)
        end
    end
    table.sort(results)
    return results
end

-- v3.5.37 - Battlewrath: "Can we feed a function and ask what tables it
-- calls?" The v3.5.35/36 scans only ever walked _G, so a color table that
-- GetThreatStatusColor captures as a plain closure UPVALUE (a local from its
-- enclosing scope, never assigned to any global name) would be completely
-- invisible to them - but Lua's own debug library can still see it, since an
-- upvalue doesn't need to be global to exist. debug.getupvalue(fn, i) walks
-- a function's captured locals by index until it returns nil; this dumps
-- every one, and for any that are themselves tables, samples their contents
-- (including one level of nested sub-tables, since a status-indexed color
-- table's own entries - {r=.., g=.., b=..} - are exactly that shape). This
-- is read-only introspection (debug.get*, never debug.set*) - it cannot
-- itself change behavior, hook anything, or introduce taint.
function ns.DumpFunctionUpvalues(fn)
    local lines = {}
    if type(fn) ~= "function" then
        table.insert(lines, "not a function")
        return lines
    end
    if type(debug) ~= "table" or type(debug.getupvalue) ~= "function" then
        table.insert(lines, "debug.getupvalue not available on this client")
        return lines
    end
    local i = 1
    while true do
        local ok, upvalName, value = pcall(debug.getupvalue, fn, i)
        if not ok or upvalName == nil then break end
        local desc = string.format("#%d %s = %s", i, tostring(upvalName), type(value))
        if type(value) == "table" then
            local count, sample = 0, {}
            for k, v in pairs(value) do
                count = count + 1
                if count <= 8 then
                    if type(v) == "table" then
                        local parts = {}
                        for k2, v2 in pairs(v) do
                            table.insert(parts, tostring(k2) .. "=" .. tostring(v2))
                        end
                        table.insert(sample, tostring(k) .. "={" .. table.concat(parts, ", ") .. "}")
                    else
                        table.insert(sample, tostring(k) .. "=" .. tostring(v))
                    end
                end
            end
            desc = desc .. string.format(" (%d entries): %s", count, table.concat(sample, "; "))
        end
        table.insert(lines, desc)
        i = i + 1
    end
    if #lines == 0 then
        table.insert(lines, "function has no upvalues (values are locals/literals/globals only)")
    end
    return lines
end

-- v3.5.34 - Battlewrath rebooted the client fully (stronger than /reload,
-- guarantees fresh code) and confirmed no change - still red. That's real
-- evidence, but the v3.5.33 hook had a silent blind spot: it only logged
-- INSIDE the "name contains aggroHighlight" branch, so "the hook never
-- fires at all" and "the hook fires constantly on something that ISN'T a
-- nameplate" were both totally silent and indistinguishable in the log.
-- UnitFrame_UpdateThreatIndicator is a genuinely shared function - stock
-- WotLK wires it up for TargetFrame/FocusFrame/PartyMemberFrame1-4/
-- BossTargetFrame1-4 (see UnitFrameThreatIndicator_Initialize's callers),
-- and the 4 firings-per-burst seen live are equally consistent with "these
-- are just the standard party/target frames doing their own normal thing"
-- as with "nameplates route through here too" - the correlation was never
-- actually proven, only assumed from the function existing and firing on
-- a plausible cadence. Logging unconditionally (every invocation's
-- indicator name, matched or not) was added to settle it for certain.
--
-- v3.5.38 - RETIRED. Battlewrath spun up three independent research passes
-- against real 3.3.5a FrameXML source (two separate mirrors, Gethe's and
-- andrew6180's build-12340 dump) plus this addon's own real live tfunc
-- traces on UnitFrame_UpdateThreatIndicator (both captures: PartyMemberFrame
-- 1/2PetFrameFlash, party-pet threat-flash traffic, never anything named
-- aggroHighlight). Combined verdict: the function is structurally gated on
-- indicator.unit/indicator.feedbackUnit and calls UnitThreatSituation(...)
-- against a real unit token - nameplates in this client's underlying model
-- have no such token reaching this function, so it CANNOT be the nameplate
-- aggroHighlight's driver, confirmed rather than assumed. Separately,
-- "aggroHighlight" itself is a Cataclysm 4.0.1 CompactUnitFrame concept
-- (parentKey-driven, CompactUnitFrame_UpdateAggroHighlight), absent from
-- stock 3.3.5a entirely - a real frame matching that name genuinely exists
-- on THIS client (found via /coasp probe on Moonrage Whitescalp), so
-- Ascension backported or reimplemented something aggroHighlight-shaped,
-- but through a mechanism with no Lua-reachable hook, color table (v3.5.35/
-- 36, clean scantables negative), or closure upvalue (v3.5.37, blocked by
-- this client's addon sandbox) - nothing this addon can reach. The
-- hooksecurefunc installation, OnUnitFrameUpdateThreatIndicator, and the
-- InstallAggroIndicatorHook/GetSpeculativeAggroHookStatus API are removed
-- as a result - they were confirmed to be watching a function nameplates
-- never pass through. ns.SetNativeAggroHighlightColor/
-- ns.ClearNativeAggroHighlightColor themselves are untouched below and
-- still back the isolated "nativeAggroColor"/"aggroBroadcast" render-test
-- modules - this retirement is specifically about the hooksecurefunc
-- chase, not about the locate/recolor primitives, which remain valid
-- diagnostic tools. Hand-rolled glow (v3.5.29) is the addon's sole
-- production threat signal going forward.
function ns.GetSpeculativeAggroHookStatus()
    return "UnitFrame_UpdateThreatIndicator -> retired v3.5.38 (confirmed structurally unable to reach nameplates - see doc note above). Hand-rolled glow is the sole production signal."
end

-- HAND-ROLLED GLOW TEXTURE (v3.5.23) - Battlewrath's live test showed
-- ForceShowNativeAggroHighlight succeeding at the Lua level (Show()/
-- SetAlpha(1)/SetVertexColor all reported success) but producing NO visible
-- change on screen - Ascension_NamePlates' own logic evidently still governs
-- whether that frame actually renders, regardless of what we call on it.
-- Rather than keep fighting a frame we don't own, Battlewrath found a real
-- answer inside Ascension's own client (queried via its in-game atlas/dev
-- console): "bonusobjectives-bar-glow-ring", a soft horizontal glow-ring
-- sprite baked into Interface\QuestFrame\bonusobjectives (240x51,
-- texcoords 0.474609-0.943359 left/right, 0.511719-0.611328 top/bottom) -
-- "Same key way design. That's a texture in the game. Can we tint / hand
-- roll that?" This is a texture WE create and own, so Show()/Hide()/
-- SetVertexColor are guaranteed to actually apply - no external frame's
-- visibility logic to fight. Also a static texture, not an OnUpdate-driven
-- LibCustomGlow effect, so it carries none of LCG's per-frame animation
-- cost - directly answers the earlier ask ("set our current to something
-- that doesn't actually render / cost performance"). Test-only for now,
-- exposed via EnemyPlates.lua's new "handRolledGlow" render-test module -
-- not wired into ApplyThreatColorForUnit's real path pending a live look.
local HAND_ROLLED_GLOW_TEXTURE = "Interface\\QuestFrame\\bonusobjectives"
local HAND_ROLLED_GLOW_COORDS = { left = 0.474609, right = 0.943359, top = 0.511719, bottom = 0.611328 }

-- v3.5.24 SIZING FIX - Battlewrath's screenshots showed the v3.5.23 anchor
-- (±0.5px, same size as the health bar) rendering the glow INSIDE the bar's
-- own bounds, essentially just tinting the fill - not the "halo behind and
-- around the plate" look the reference image showed. Two changes: (1)
-- anchored well past the health bar's own edges (not flush to them) so the
-- glow actually extends beyond the bar's silhouette, matching the desired
-- mockup's proportions; (2) draw layer dropped from OVERLAY to BACKGROUND,
-- the lowest layer, so the health bar's own fill/border art (ARTWORK/BORDER)
-- draws ON TOP of the overlapping middle portion - only the part spilling
-- past the bar's own edges (where nothing else is drawn) shows through as a
-- halo, rather than the whole texture sitting visibly on top of the bar.
-- These exact padding numbers are a first pass, not measured against a real
-- nameplate's dimensions - expect to retune after the next live look.
--
-- v3.5.25 TUNING PASS - Battlewrath, after seeing v3.5.24 render as a real
-- halo for the first time ("Not bad at all, you know."): "Let's play a
-- little with the halo. It wants scaling down a touch. And moving to the
-- right of the anchor. So that the round head on the right is framing the
-- level circle on the right." Scaled the padding down slightly (12->9
-- horizontal, 10->7 vertical) and shifted the whole box right by 6px
-- (added +6 to both TOPLEFT/BOTTOMRIGHT x-offsets, which moves the texture
-- without changing its width) so the sprite's rounded end lands over the
-- level-circle icon on the bar's right edge instead of centered on the bar.
--
-- v3.5.26 TUNING PASS - Battlewrath: "Generally great. The right side round
-- part doesn't fully encapsulate the level indicator. So it could be
-- stretched to the right. And maybe as the alert it wants to be scaled
-- slightly bigger - but if their all the same image but tinted. then just
-- stretched to the right. So the level circle is surrounded by the halo."
-- Deliberately NOT adding per-state sizing (secure/warning/danger all share
-- this one texture, just tinted via SetVertexColor - a separate size per
-- state would need 3 anchor variants for zero real benefit) - simplest fix
-- matching what was actually asked for: stretch the right edge further
-- (BOTTOMRIGHT x: 15->22) so the round head fully wraps the level circle,
-- plus a touch more vertical (7->8) for the "scaled slightly bigger" ask.
--
-- v3.5.27 TUNING PASS - Battlewrath, zoomed into the level-icon corner:
-- "It's almost 100%. If you look to the very right side, it doesn't quite
-- sit central. So moving slightly to the left and maybe down to split the
-- difference. So it looks like a shadow around the key." Shifted the whole
-- box left by 3px and down by 2px (both TOPLEFT/BOTTOMRIGHT offsets moved
-- together, so width/height are unchanged - only position moves) to
-- recenter the round head on the level-circle icon.
--
-- v3.5.28 TUNING PASS - Battlewrath, comparing against the v3.5.26 state:
-- "Now up a touch. Can you see how it is lop sided?" The v3.5.27 down-shift
-- made top/bottom padding asymmetric (6 vs 10), which both tilted the halo
-- off-center AND pushed it down too far. Restored symmetric vertical padding
-- (8/8, matching v3.5.26) while keeping v3.5.27's leftward horizontal shift,
-- which fixes both complaints in one move: less lopsided, and net shifted
-- up by 2px.
local function GetOrCreateHandRolledGlow(healthBar)
    if healthBar.coagpHandGlow then return healthBar.coagpHandGlow end
    local tex = healthBar:CreateTexture(nil, "BACKGROUND")
    tex:SetTexture(HAND_ROLLED_GLOW_TEXTURE)
    tex:SetTexCoord(HAND_ROLLED_GLOW_COORDS.left, HAND_ROLLED_GLOW_COORDS.right, HAND_ROLLED_GLOW_COORDS.top, HAND_ROLLED_GLOW_COORDS.bottom)
    tex:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -6, 8)
    tex:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 19, -8)
    tex:Hide()
    healthBar.coagpHandGlow = tex
    return tex
end

function ns.SetHandRolledGlow(plate, color)
    local healthBar = ns.GetHealthBar(plate)
    if not healthBar then
        if ns.IsLogging() then
            ns.Log("Core", "SetHandRolledGlow -> no health bar resolved, skipped")
        end
        return false
    end
    local tex = GetOrCreateHandRolledGlow(healthBar)
    local ok = pcall(tex.SetVertexColor, tex, color.r, color.g, color.b, 1)
    tex:Show()
    if ns.IsLogging() then
        ns.Log("Core", "SetHandRolledGlow -> %s (r=%.2f g=%.2f b=%.2f)",
            ok and "applied" or "SetVertexColor call failed", color.r, color.g, color.b)
    end
    return ok
end

function ns.ClearHandRolledGlow(plate)
    local healthBar = ns.GetHealthBar(plate)
    if not healthBar or not healthBar.coagpHandGlow then return end
    healthBar.coagpHandGlow:Hide()
    if ns.IsLogging() then
        ns.Log("Core", "ClearHandRolledGlow -> hidden")
    end
end

-- ---------------------------------------------------------------------
-- Diagnostic log (SANITATION FIX v2) - shared, since a pooled-frame
-- restore concerns both modules equally (either one's state could be left
-- stuck on a pooled frame that gets reassigned to an unrelated unit).
-- ---------------------------------------------------------------------

local function LogRemovedRestore(unit, resolvedDirectly, resolvedViaCache, restoredSomething)
    if not restoredSomething then return end
    COA_GuardianPlatesDB.removedLog = COA_GuardianPlatesDB.removedLog or {}
    local log = COA_GuardianPlatesDB.removedLog
    table.insert(log, {
        capturedAt = date("%Y-%m-%d %H:%M:%S"),
        unit = unit,
        resolvedDirectly = resolvedDirectly,
        resolvedViaCache = resolvedViaCache,
    })
    while #log > 20 do
        table.remove(log, 1)
    end
end
ns.LogRemovedRestore = LogRemovedRestore

-- Clears ONLY the shared tables this file owns. Each module clears its own
-- per-unit tables inside its own OnUnitRemoved handler, called before this
-- (same "restore then clear" order the original ClearUnitState relied on).
function ns.ClearUnitState(unit)
    ns.activeUnits[unit] = nil
    ns.unitIndex[unit] = nil
end

-- ---------------------------------------------------------------------
-- Event dispatch - the native nameplate driver, relayed symmetrically to
-- both modules. See the DISPATCH CONTRACT doc note above.
-- ---------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
eventFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
eventFrame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
eventFrame:RegisterEvent("UNIT_HEALTH")
eventFrame:RegisterEvent("UNIT_MAXHEALTH")
eventFrame:SetScript("OnEvent", function(self, event, unit)
    if event == "NAME_PLATE_UNIT_ADDED" then
        local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
        plate = (ok and plate) or nil

        if plate and ns.plateOwner[plate] and ns.plateOwner[plate] ~= unit and ns.activeUnits[ns.plateOwner[plate]] then
            -- Duplicate alias for a plate we're already tracking under a
            -- different unit token - skip entirely rather than double-track.
            if ns.IsLogging and ns.IsLogging() then
                ns.Log("Core", "NAME_PLATE_UNIT_ADDED(%s) -> skipped, duplicate alias for already-tracked plate owned by %s",
                    ns.DescribeUnit and ns.DescribeUnit(unit) or unit, tostring(ns.plateOwner[plate]))
            end
            return
        end

        ns.activeUnits[unit] = true
        if plate then
            ns.plateOwner[plate] = unit
            pcall(ns.IndexUnit, unit, plate)
            pcall(ns.RefreshPlateSiblings, plate)
        end
        if ns.Friendly.OnUnitAdded then pcall(ns.Friendly.OnUnitAdded, unit, plate) end
        if ns.Enemy.OnUnitAdded then pcall(ns.Enemy.OnUnitAdded, unit, plate) end
        if ns.Aggro.OnUnitAdded then pcall(ns.Aggro.OnUnitAdded, unit, plate) end

    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        if not ns.activeUnits[unit] then
            -- Never tracked (e.g. a duplicate alias skipped at ADD time) -
            -- nothing was ever applied under this token, so there's
            -- nothing to restore/clear.
            return
        end

        local plate, resolvedDirectly, resolvedViaCache = ns.ResolvePlateForRemoval(unit)

        local restoredByFriendly = false
        local restoredByEnemy = false
        if ns.Friendly.OnUnitRemoved then
            local ok, restored = pcall(ns.Friendly.OnUnitRemoved, unit, plate)
            restoredByFriendly = ok and restored
        end
        if ns.Enemy.OnUnitRemoved then
            local ok, restored = pcall(ns.Enemy.OnUnitRemoved, unit, plate)
            restoredByEnemy = ok and restored
        end

        if plate and ns.plateOwner[plate] == unit then
            ns.plateOwner[plate] = nil
        end

        LogRemovedRestore(unit, resolvedDirectly, resolvedViaCache, restoredByFriendly or restoredByEnemy)
        ns.ClearUnitState(unit)

    elseif event == "UNIT_THREAT_SITUATION_UPDATE" or event == "UNIT_THREAT_LIST_UPDATE" then
        -- DUPLICATE-ALIAS GUARD (v3.5.2) - these two events fire with
        -- whatever unit token Blizzard's own event system hands us
        -- directly, completely bypassing ns.activeUnits/plateOwner - so
        -- the v3.5.1 guard on the ADD/REMOVE/reclassify paths never saw
        -- this one at all. This is also the highest-frequency of the
        -- three paths (fires on every real threat change in combat), so
        -- it's almost certainly the dominant source of the double
        -- processing, more so than the ADD/reclassify paths. Same fix:
        -- if this unit isn't the plate's recognized canonical owner (and
        -- that owner is still active), skip it as a duplicate alias
        -- (e.g. "target" for a plate already owned by "nameplate3").
        if unit and ns.Enemy.OnThreatEvent then
            local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
            if ok and plate then
                local owner = ns.plateOwner[plate]
                if not owner or owner == unit or not ns.activeUnits[owner] then
                    pcall(ns.Enemy.OnThreatEvent, unit, plate)
                elseif ns.IsLogging and ns.IsLogging() then
                    ns.Log("Core", "%s(%s) -> skipped, duplicate alias for already-tracked plate owned by %s",
                        event, ns.DescribeUnit and ns.DescribeUnit(unit) or unit, tostring(owner))
                end
            end
        end

    elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        if unit and ns.Friendly.OnHealthEvent then
            pcall(ns.Friendly.OnHealthEvent, unit)
        end
    end
end)

-- Reclassify ticker (v2.2 LEAN REFINEMENT) - catches anything the ADD/
-- REMOVED events alone would miss (a unit's friend/player status changing
-- without a plate remove/add cycle, e.g. a mind-control edge case). Runs on
-- a slower throttle than per-frame reapplication (Friendly's own concern -
-- see FriendlyPlates.lua's scanner) since reclassification itself is a
-- cosmetic filter, not combat-critical.
local reclassifier = CreateFrame("Frame")
local reclassifyElapsed = 0
local RECLASSIFY_INTERVAL = 0.5

-- OVERLOAD SAFETY VALVE (v3.5.6, 2026-07-09) - Battlewrath, thinking ahead
-- to raid-scale content: "Should we build in a suspend when that hangs too
-- much? Raids can have 40 units in the play space." Math from measured
-- dungeon-scale numbers (this tick's own PERF line: ~0.03ms/unit marginal
-- cost) put even a 40-unit raid pull around ~1ms/tick on the reclassify
-- loop itself - the real multiplier is engaged-mobs x raid-roster-size in
-- EnemyPlates' own group scans (HasAnyGroupThreatEntry/
-- IsAnotherMemberApproachingAggro), which a rough worst case (10 adds x a
-- 40-man roster) still only put around 5-6ms/tick. Nothing measured or
-- extrapolated so far justifies throttling - but per Battlewrath's own
-- framing ("add that insurance now at the very open end (so a long wait),
-- just so we have some catchment when that system balloons/spider-webs"),
-- this is a deliberately loose catchment for genuine runaway cases, not a
-- response to an observed problem.
--
-- RECLASSIFY_OVERLOAD_MS sits far above anything real measured/extrapolated
-- (worst-case raid estimate ~5-6ms) so it only trips on an actual blow-up,
-- never on ordinary raid load. ns.lastReclassifyMs is measured
-- unconditionally (debugprofilestop() is cheap enough to call every 0.5s
-- regardless of logging state - unlike ns.PerfStart/PerfEnd, this is a real
-- functional signal, not a debug-only instrument) so the guard works live
-- even with /coasp log off. ns.IsReclassifyOverloaded() re-evaluates every
-- tick against the PREVIOUS tick's duration - not sticky/latched - so it
-- self-recovers the instant load drops, the same auto-correcting shape as
-- the roster delayed re-check rather than needing manual intervention.
-- EnemyPlates.lua's OnReclassify reads this to decide whether to allow the
-- expensive Mob Aggro Cue scans this tick; the cheap isTanking/status
-- check that drives all core threat coloring is never gated by this at all.
local RECLASSIFY_OVERLOAD_MS = 15
ns.lastReclassifyMs = 0

function ns.IsReclassifyOverloaded()
    return ns.lastReclassifyMs > RECLASSIFY_OVERLOAD_MS
end

reclassifier:SetScript("OnUpdate", function(self, elapsed)
    reclassifyElapsed = reclassifyElapsed + elapsed
    if reclassifyElapsed < RECLASSIFY_INTERVAL then return end
    reclassifyElapsed = 0

    if ns.IsReclassifyOverloaded() and ns.IsLogging() then
        ns.Log("Core", "reclassify tick overloaded (previous took %.2fms > %dms) - skipping Mob Aggro Cue scans this tick",
            ns.lastReclassifyMs, RECLASSIFY_OVERLOAD_MS)
    end

    local tickStart = debugprofilestop()
    local unitCount = 0

    for unit in pairs(ns.activeUnits) do
        local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
        if ok and plate then
            -- Defense-in-depth against the same duplicate-alias case the
            -- ADD handler guards against (v3.5.1) - if this plate's
            -- canonical owner is a different, still-active unit token,
            -- skip processing this one a second time.
            local owner = ns.plateOwner[plate]
            if not owner or owner == unit or not ns.activeUnits[owner] then
                if not owner then ns.plateOwner[plate] = unit end
                unitCount = unitCount + 1
                pcall(ns.IndexUnit, unit, plate)
                pcall(ns.RefreshPlateSiblings, plate)
                if ns.Friendly.OnReclassify then pcall(ns.Friendly.OnReclassify, unit, plate) end
                if ns.Enemy.OnReclassify then pcall(ns.Enemy.OnReclassify, unit, plate) end
                if ns.Aggro.OnReclassify then pcall(ns.Aggro.OnReclassify, unit, plate) end
            end
        end
    end

    if ns.Friendly.OnThrottledTick then pcall(ns.Friendly.OnThrottledTick) end
    if ns.Enemy.OnThrottledTick then pcall(ns.Enemy.OnThrottledTick) end

    ns.lastReclassifyMs = debugprofilestop() - tickStart
    if ns.IsLogging() then
        ns.Log("Core", "PERF reclassify tick (%d unit(s)) took %.2fms", unitCount, ns.lastReclassifyMs)
    end

    -- Safety net for the player role index - the event set above should
    -- catch every real change, but this costs one cheap API call per tick
    -- and guarantees ns.GetPlayerRole() can never drift stale for long.
    pcall(RefreshPlayerRole)
end)

-- ---------------------------------------------------------------------
-- Debug scan/probe - generic plate inspection, not tied to either module's
-- own behavior. ns.Friendly.IsSuppressed is read (if defined) purely for
-- the scan dump's "suppressed" field.
-- ---------------------------------------------------------------------

function ns.ScanNow()
    local found = {}
    for unit in pairs(ns.activeUnits) do
        local ok = pcall(function()
            local plateName
            local okPlate, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
            if okPlate and plate then
                local _, container = ns.GetNameRegion(plate)
                local target = container or plate
                local okName, name = pcall(target.GetName, target)
                if okName then plateName = name end
            end
            table.insert(found, {
                unit = unit,
                name = UnitName(unit),
                isPlayer = UnitIsPlayer(unit) and true or false,
                isFriend = UnitIsFriend("player", unit) and true or false,
                suppressed = (ns.Friendly.IsSuppressed and ns.Friendly.IsSuppressed(unit)) and true or false,
                plateName = plateName,
            })
        end)
        if not ok then
            table.insert(found, { unit = unit, error = true })
        end
    end

    COA_GuardianPlatesDB.lastScan = {
        capturedAt = date("%Y-%m-%d %H:%M:%S"),
        count = #found,
        plates = found,
    }

    Print(string.format("Scan found %d active nameplate(s). /reload to flush to disk.", #found))
end

-- TEXTURE DETAIL (v3.5.16, 2026-07-09) - Battlewrath, considering a possible
-- native-border color override for Enemy Plates: "Shall we add boarder
-- correction? A single color wheel picker for enemy plates?" Before that's
-- buildable at all, we need to know whether Ascension_NamePlates (the
-- client-embedded, unreadable-source nameplate driver - confirmed via the
-- character's own AddOns.txt: TurboPlates disabled, Ascension_NamePlates
-- enabled) actually draws a separate colorable BORDER region at all, or
-- whether what looked like one is just baked into the health bar's own
-- native texture with nothing separate to grab. DescribeRegion previously
-- only captured enough to identify a FontString's text - now also captures
-- a Texture region's file path, current vertex color, and draw layer, so a
-- probe dump can actually show "here's a texture region tinted red" instead
-- of just "here's a Texture, no further detail."
local function DescribeRegion(region)
    local okType, objType = pcall(region.GetObjectType, region)
    local okName, name = pcall(region.GetName, region)
    local entry = {
        objectType = okType and objType or "?",
        name = okName and name or nil,
    }
    if okType and objType == "FontString" then
        local okText, text = pcall(region.GetText, region)
        entry.text = okText and text or nil
    elseif okType and objType == "Texture" then
        local okTex, texPath = pcall(region.GetTexture, region)
        entry.texture = okTex and tostring(texPath) or nil
        local okColor, r, g, b, a = pcall(region.GetVertexColor, region)
        if okColor then
            entry.vertexColor = string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a)
        end
        local okLayer, layer = pcall(region.GetDrawLayer, region)
        entry.drawLayer = okLayer and layer or nil
    end
    return entry
end

-- Recursive tree walk (v3.5.17) - Battlewrath's first live probe capture
-- surfaced 4 unnamed Frame children under the health bar container that the
-- v3.5.16 one-level-deep walk never opened up (Frames don't stop at
-- GetChildren/GetRegions - they can nest further Frames/Textures inside
-- themselves, e.g. a "selection highlight" sub-frame holding its own tinted
-- texture). Descends into every Frame-capable child up to maxDepth, tagging
-- each entry with a slash-separated path so the dump reads as a tree instead
-- of a flat, ambiguous list. Depth-limited (not unbounded) purely as a safety
-- valve against a pathological frame graph - real nameplate trees are only
-- ever a few levels deep.
local PROBE_MAX_DEPTH = 5

local function WalkProbeTree(frame, path, depth, out)
    if depth > PROBE_MAX_DEPTH then return end

    local regions = { pcall(frame.GetRegions, frame) }
    if regions[1] then
        for i = 2, #regions do
            if regions[i] then
                local entry = DescribeRegion(regions[i])
                entry.path = path .. "/" .. (entry.name or "region")
                entry.depth = depth
                table.insert(out, entry)
            end
        end
    end

    local children = { pcall(frame.GetChildren, frame) }
    if children[1] then
        for i = 2, #children do
            local child = children[i]
            if child then
                local entry = DescribeRegion(child)
                entry.path = path .. "/" .. (entry.name or "child")
                entry.depth = depth
                table.insert(out, entry)
                WalkProbeTree(child, entry.path, depth + 1, out)
            end
        end
    end
end

-- Shared dump-builder (v3.5.16, tree walk added v3.5.17) - factored out of
-- the old ProbeNow so a new explicit-unit probe (ns.ProbeUnit below) doesn't
-- duplicate this same walk for both the plate and its name-region container.
local function BuildProbeDump(targetUnit, plate)
    local nameRegion, container = ns.GetNameRegion(plate)

    local dump = {
        capturedAt = date("%Y-%m-%d %H:%M:%S"),
        unit = targetUnit,
        name = UnitName(targetUnit),
        foundNameRegion = nameRegion ~= nil,
        plateTree = {},
        containerTree = {},
    }

    WalkProbeTree(plate, "plate", 0, dump.plateTree)
    if container then
        WalkProbeTree(container, "container", 0, dump.containerTree)
    end

    return dump
end

function ns.ProbeNow()
    local targetUnit
    for unit in pairs(ns.activeUnits) do
        if (ns.Friendly.IsSuppressed and ns.Friendly.IsSuppressed(unit)) then
            targetUnit = unit
            break
        end
    end
    if not targetUnit then
        for unit in pairs(ns.activeUnits) do
            if ns.IsFriendlyPlayer(unit) then
                targetUnit = unit
                break
            end
        end
    end

    if not targetUnit then
        Print("No friendly player plate currently active - stand near one and try again.")
        return
    end

    local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, targetUnit)
    if not ok or not plate then
        Print("Could not resolve a plate for " .. tostring(targetUnit) .. ".")
        return
    end

    local dump = BuildProbeDump(targetUnit, plate)
    COA_GuardianPlatesDB.lastProbe = dump
    Print(string.format(
        "Probed %s - foundNameRegion=%s, plate tree has %d entries. /reload to flush to disk.",
        tostring(dump.name), tostring(dump.foundNameRegion), #dump.plateTree))
end

-- Formats one region entry (see DescribeRegion) as a single readable line
-- for the copy box - texture path + vertex color are exactly what's needed
-- to spot "here's a texture region tinted red" among a plate's regions.
-- v3.5.17: indents by entry.depth so the recursive walk reads as a tree
-- instead of a flat list, and shows the full slash-separated path so a
-- nested region can be pinpointed exactly (which unnamed Frame it's under).
local function FormatRegionLine(entry)
    local indent = string.rep("  ", entry.depth or 0)
    local parts = { entry.objectType, entry.name or "<unnamed>" }
    if entry.text then
        table.insert(parts, "text=\"" .. entry.text .. "\"")
    end
    if entry.texture then
        table.insert(parts, "texture=" .. entry.texture)
    end
    if entry.vertexColor then
        table.insert(parts, "vertexColor=" .. entry.vertexColor)
    end
    if entry.drawLayer then
        table.insert(parts, "layer=" .. tostring(entry.drawLayer))
    end
    return indent .. table.concat(parts, " | ")
end

local function DumpSectionLines(lines, title, entries)
    table.insert(lines, string.format("-- %s (%d) --", title, #entries))
    for _, entry in ipairs(entries) do
        table.insert(lines, FormatRegionLine(entry))
    end
end

-- EXPLICIT-UNIT PROBE (v3.5.16) - unlike ProbeNow (which searches for a
-- suppressed/friendly-player plate specifically - a Friendly-facing tool),
-- this probes whatever unit token you give it directly - built for
-- inspecting a HOSTILE plate (your current target) instead, per Battlewrath's
-- border-correction question above: "Shall we add boarder correction? A
-- single color wheel picker for enemy plates?" This is the prerequisite
-- investigation step - before that's buildable, we need to know whether
-- Ascension_NamePlates (client-embedded, no extractable source) actually
-- draws a separate colorable border region at all, or whether the red tint
-- observed live is baked into the health bar's own native texture with
-- nothing separate to grab. Pops the same copyable text box /coasp log copy
-- uses (Ctrl+A/Ctrl+C) instead of requiring a /reload + SavedVariables dig,
-- so the result can be pasted straight back for review.
function ns.ProbeUnit(unitToken)
    unitToken = unitToken or "target"
    if not UnitExists(unitToken) then
        Print("Probe: no unit '" .. tostring(unitToken) .. "' exists (no target selected?).")
        return
    end
    local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unitToken)
    if not ok or not plate then
        Print("Probe: '" .. tostring(unitToken) .. "' has no active nameplate.")
        return
    end

    local dump = BuildProbeDump(unitToken, plate)
    COA_GuardianPlatesDB.lastTargetProbe = dump

    local lines = {
        string.format("Probe: %s (%s), captured %s", tostring(dump.name), unitToken, dump.capturedAt),
        string.format("foundNameRegion=%s", tostring(dump.foundNameRegion)),
        "",
    }
    DumpSectionLines(lines, "plate tree", dump.plateTree)
    table.insert(lines, "")
    DumpSectionLines(lines, "health bar container tree", dump.containerTree)

    ns.ShowCopyableText(string.format("COA State Plates - Probe: %s", tostring(dump.name)), table.concat(lines, "\n"))
    Print(string.format("Probed %s (%s) - copyable dump opened (Ctrl+A/Ctrl+C).", tostring(dump.name), unitToken))
end

-- ---------------------------------------------------------------------
-- UNIFIED LOG + PERF MONITOR (v3.4.3, 2026-07-08) - Battlewrath, after the
-- v3.4.2 threat-table gate fixed the over-triggering but the tank/DPS
-- coloring still wasn't showing the expected response: "Would a logger and
-- performance monitor help here? /coasp log, it can be a unified log for
-- anything loaded. lives in the call time to /reload." Built here, not in
-- Friendly or Enemy, for the same reason the unit index/role/roster caches
-- live here - it's shared infrastructure both modules (and Core itself)
-- can write into, one buffer, one command, rather than each module growing
-- its own private debug log. Confirmed via Wowpedia read before using it:
-- `debugprofilestop()` is a genuine WotLK 3.3.5 API (returns a
-- free-running millisecond counter, safe to call anywhere, not combat-
-- restricted), so the perf-timing half doesn't need its own availability
-- guard the way LibCustomGlow does.
--
-- Cheap when off: every call site below checks ns.IsLogging() first and
-- bails before doing any string.format/table work, so leaving logging
-- disabled (the default) costs one boolean read per call, not a hidden
-- tax on the hot paths this whole session has been trying to keep light.
-- Same "/reload to flush to disk" convention as removedLog/lastScan/
-- lastProbe above - COA_GuardianPlatesDB.log holds the full ring buffer,
-- but `/coasp log dump` also prints the most recent entries straight to
-- chat since a short string is cheap to read live, unlike the bigger
-- structured scan/probe dumps that only ever make sense post-reload.
local MAX_LOG_ENTRIES = 300

-- STORE-TIME FILTER (v3.5.41, 2026-07-09) - Battlewrath, live-testing the
-- native aggro recolor: "in 300 events it already ran through. so no budget
-- to catch it." The v3.5.11 keyword filter only narrows results at READ time
-- (dump/copy) - the 300-entry ring buffer itself still fills with ordinary
-- per-tick PERF/IsPotentialThreatUnit noise regardless, so during active
-- multi-mob combat the handful of aggro-recolor lines that matter can get
-- pushed out of the buffer entirely before there's a chance to read them,
-- even with a read-time filter - there's nothing left matching to find.
-- This is a SEPARATE, STORE-time filter: when set, ns.Log silently drops any
-- entry that doesn't match before it ever counts against the 300-entry
-- budget, so the whole buffer is effectively reserved for only what you
-- actually care about that session. Independent of the read-time filter -
-- both can be used together (e.g. store-filter to "aggro" so the buffer
-- only ever holds aggro-related lines, then dump/copy with no filter at all
-- to read all of them back).
local logStoreFilter = nil

function ns.SetLogStoreFilter(needle)
    logStoreFilter = (needle and needle ~= "") and needle:lower() or nil
end

function ns.GetLogStoreFilter()
    return logStoreFilter
end

function ns.IsLogging()
    return COA_GuardianPlatesDB.logEnabled and true or false
end

-- source: short string identifying the caller ("Core", "Enemy", "Friendly").
-- fmt/... : string.format arguments, only ever formatted if logging is on.
function ns.Log(source, fmt, ...)
    if not COA_GuardianPlatesDB.logEnabled then return end
    local ok, msg = pcall(string.format, fmt, ...)
    local finalMsg = ok and msg or ("<log format error: " .. tostring(msg) .. ">")
    if logStoreFilter then
        local matches = finalMsg:lower():find(logStoreFilter, 1, true) or source:lower():find(logStoreFilter, 1, true)
        if not matches then return end
    end
    COA_GuardianPlatesDB.log = COA_GuardianPlatesDB.log or {}
    local log = COA_GuardianPlatesDB.log
    table.insert(log, {
        capturedAt = date("%H:%M:%S"),
        source = source,
        msg = finalMsg,
    })
    while #log > MAX_LOG_ENTRIES do
        table.remove(log, 1)
    end
end

-- DIAGNOSTIC UNIT DESCRIBER (v3.5.0) - live capture repeatedly showed a
-- single displayed mob name (e.g. "Rot Hide Mongrel") swinging between
-- wildly different threat states within a couple of seconds, which read
-- like one mob's threat table flickering (later partly explained by
-- Battlewrath taunting repeatedly - see README). But every log line only
-- ever printed UnitName(unit), never the underlying nameplate token or
-- the creature's actual GUID - so there was no way to tell "one real
-- mob's state is genuinely swinging" apart from "the client recycled this
-- pooled nameplate slot onto a different physical mob that happens to
-- share the same name" (plausible for a generic name with several up at
-- once). Logs now carry both the raw unit token (stable per plate slot,
-- e.g. "nameplate3") and a short GUID suffix (unique per physical
-- creature) so a future capture can prove or disprove plate-recycling
-- directly instead of guessing from name-only lines.
local function ShortGUID(unit)
    local ok, guid = pcall(UnitGUID, unit)
    if not ok or not guid then return "?" end
    return guid:sub(-6)
end

function ns.DescribeUnit(unit)
    if not unit then return "?" end
    local name = UnitName(unit) or "?"
    return string.format("%s[%s|%s]", name, tostring(unit), ShortGUID(unit))
end

-- Perf pair - bracket exactly the code being measured. Returns nil when
-- logging is off so a call site can skip the matching PerfEnd cheaply
-- (`local t = ns.PerfStart(); ...; if t then ns.PerfEnd("Enemy", "label", t) end`).
function ns.PerfStart()
    if not COA_GuardianPlatesDB.logEnabled then return nil end
    return debugprofilestop()
end

function ns.PerfEnd(source, label, startTime)
    if not startTime then return end
    local elapsedMs = debugprofilestop() - startTime
    ns.Log(source, "PERF %s took %.2fms", label, elapsedMs)
end

local function SetLogging(enabled)
    COA_GuardianPlatesDB.logEnabled = enabled and true or false
    Print("Log/perf monitor " .. (enabled and "ON" or "OFF") .. ".")
end

-- KEYWORD FILTER (v3.5.11, 2026-07-09) - Battlewrath, after a render test
-- capture came back readable but hard to isolate: "That log path is too
-- noisy to capture the test." A dungeon/open-world session logs every
-- unit's PERF reclassify tick and IsPotentialThreatUnit result every 0.5s
-- regardless of what you actually care about that moment, so the handful of
-- render-test-relevant lines (SetGlow/ClearGlow/SetHealthBarColor/
-- ClearHealthBarColor) get buried in between. `filter`, if given, keeps only
-- entries whose source OR message contains it (plain substring, case-
-- insensitive - not a Lua pattern, so special characters like parentheses
-- in a message don't need escaping). Filtering happens BEFORE the count
-- slice, not after - otherwise a noisy log could exhaust the last N raw
-- entries without ever reaching an actual match further back.
local function MatchesFilter(entry, needle)
    if not needle then return true end
    return entry.msg:lower():find(needle, 1, true) ~= nil or entry.source:lower():find(needle, 1, true) ~= nil
end

local function DumpLog(count, filter)
    local log = COA_GuardianPlatesDB.log or {}
    if #log == 0 then
        Print("Log is empty.")
        return
    end
    local needle = filter and filter:lower() or nil
    local filtered = log
    if needle then
        filtered = {}
        for _, entry in ipairs(log) do
            if MatchesFilter(entry, needle) then
                table.insert(filtered, entry)
            end
        end
        if #filtered == 0 then
            Print(string.format("Log has %d total entr%s, none match filter '%s'.", #log, (#log == 1) and "y" or "ies", filter))
            return
        end
    end
    count = tonumber(count) or 20
    local from = math.max(1, #filtered - count + 1)
    for i = from, #filtered do
        local entry = filtered[i]
        Print(string.format("[%s][%s] %s", entry.capturedAt, entry.source, entry.msg))
    end
    Print(string.format("Showing %d of %d%s entr%s. Full buffer in COA_GuardianPlatesDB.log - /reload to flush to disk.",
        #filtered - from + 1, #filtered, filter and (" matching '" .. filter .. "'") or "", (#filtered == 1) and "y" or "ies"))
end

-- ---------------------------------------------------------------------
-- COPYABLE EXPORT BOX (v3.4.4, 2026-07-08) - Battlewrath: "There is a copy
-- function that can appear in the chat / the debugger. Can we feed
-- responses to them? I can't copy raw from chat." Correct - WotLK's
-- default chat frame has no text-selection/copy support at all, a real
-- client limitation, not something fixable from inside the chat frame
-- itself. This is the standard WoW addon workaround (the same trick
-- WeakAuras' own Import/Export window uses): a plain popup frame holding a
-- single multi-line EditBox, pre-filled and pre-selected on open, so
-- Ctrl+A/Ctrl+C works immediately. Deliberately generic (title + text
-- in, nothing log-specific) so any future export need can reuse it
-- instead of rebuilding this - `ns.ShowCopyableText` is the one entry
-- point. No "BackdropTemplate" mixin needed on the frame - that's only
-- required on Retail (8.0+); this is a 3.3.5 client, where SetBackdrop
-- works directly on any plain Frame, matching how GetOrCreateFallbackBorder
-- already does it above.
-- ---------------------------------------------------------------------

local copyFrame

local function GetOrCreateCopyFrame()
    if copyFrame then return copyFrame end

    local f = CreateFrame("Frame", "COA_GuardianPlatesCopyFrame", UIParent)
    f:SetSize(520, 380)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetClampedToScreen(true)
    f:Hide()

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("TOP", 0, -16)
    f.title:SetText("COA State Plates")

    local hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOP", f.title, "BOTTOM", 0, -4)
    hint:SetText("Ctrl+A, Ctrl+C to copy - Esc to close")

    local closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -4, -4)
    closeButton:SetScript("OnClick", function() f:Hide() end)

    local scrollFrame = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 16, -56)
    scrollFrame:SetPoint("BOTTOMRIGHT", -32, 16)

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetFontObject(ChatFontNormal)
    editBox:SetWidth(452)
    editBox:SetAutoFocus(false)
    editBox:SetScript("OnEscapePressed", function() f:Hide() end)
    -- Re-select-all on every keystroke would fight the user editing/
    -- scrolling within the box, so this only happens once, right after
    -- ShowCopyableText populates it - not wired to OnTextChanged.
    scrollFrame:SetScrollChild(editBox)

    f.editBox = editBox
    copyFrame = f
    return f
end

-- Generic entry point: pops the box, sets `title`, fills `text`, focuses
-- and selects all of it. Safe to call with a large string - it's a plain
-- EditBox, not a chat line, so there's no message-length truncation.
function ns.ShowCopyableText(title, text)
    local f = GetOrCreateCopyFrame()
    f.title:SetText(title or "COA State Plates")
    f.editBox:SetText(text or "")
    f:Show()
    f.editBox:SetFocus()
    f.editBox:HighlightText()
end

-- Builds the same [time][source] msg lines DumpLog prints to chat, joined
-- with real newlines for the copy box. `count` nil means "all of it" -
-- unlike DumpLog's chat-friendly default of a short recent slice, the
-- point of copying out is usually getting the whole session's trace.
-- KEYWORD FILTER (v3.5.11) - same reasoning/shape as DumpLog's own filter
-- above, applied before the count slice for the same reason.
local function CopyLog(count, filter)
    local log = COA_GuardianPlatesDB.log or {}
    if #log == 0 then
        Print("Log is empty - nothing to copy.")
        return
    end
    local needle = filter and filter:lower() or nil
    local filtered = log
    if needle then
        filtered = {}
        for _, entry in ipairs(log) do
            if MatchesFilter(entry, needle) then
                table.insert(filtered, entry)
            end
        end
        if #filtered == 0 then
            Print(string.format("Log has %d total entr%s, none match filter '%s'.", #log, (#log == 1) and "y" or "ies", filter))
            return
        end
    end
    local n = tonumber(count)
    local from = n and math.max(1, #filtered - n + 1) or 1
    local lines = {}
    for i = from, #filtered do
        local entry = filtered[i]
        table.insert(lines, string.format("[%s][%s] %s", entry.capturedAt, entry.source, entry.msg))
    end
    ns.ShowCopyableText(string.format("COA State Plates - Log (%d entries%s)", #lines, filter and (" matching '" .. filter .. "'") or ""), table.concat(lines, "\n"))
end

-- RENDER TEST REGISTRY (v3.5.9) - moved here from EnemyPlates.lua's own
-- /coaep after Battlewrath's correction: "How come coaep? I'd stated core
-- should carry everything." Matches the same principle already on record
-- for the player-role index (see its own doc note above): "have core as
-- the executor... everything pulls requirements from what we attach to
-- it." Core owns the shared command surface and the generic cycle engine;
-- a module (EnemyPlates.lua today, a future capability like the deferred
-- "needs action highlight" tomorrow) just registers what states it can
-- render-test and how to apply one - it never needs its own parallel
-- /coa** rendertest command.
--
-- ns.RegisterRenderTest(name, applyFn, steps) - applyFn(stateName, forceFill)
-- does the actual work (module-specific: knows its own colors/keys/executor
-- calls); steps is an ordered list of { state = "...", fill = bool } used
-- by the "cycle" command below. Multiple modules can register; direct
-- state tests are broadcast to all of them (harmless today with only one
-- registrant - each ignores a stateName it doesn't recognize), and "cycle"
-- concatenates every registered module's steps into one sequence.
ns.renderTestModules = {}

function ns.RegisterRenderTest(name, applyFn, steps)
    table.insert(ns.renderTestModules, { name = name, apply = applyFn, steps = steps })
end

-- CYCLE ENGINE (v3.5.9) - Battlewrath: "Can we not just run a test cycle
-- that I kick off? Moving through every testable state with a c-time
-- delay?" Chains C_Timer.After calls (one step, wait, next step) rather
-- than a frame-based loop - same reasoning as the v3.5.5 delayed re-check
-- refactor, the client's own timer does the waiting. A generation token
-- (renderTestCycleGen) guards against two cycles racing each other: every
-- new /coasp rendertest invocation (cycle OR a direct one-off state) bumps
-- the generation, so any older in-flight chain's next scheduled step sees
-- it's been superseded and quietly stops instead of continuing to write
-- over whatever the newer command is doing.
local renderTestCycleGen = 0

local function RunRenderTestCycle(delayArg)
    if #ns.renderTestModules == 0 then
        Print("Render test: no module has registered a test cycle.")
        return
    end
    local delaySeconds = tonumber(delayArg) or 3

    local sequence = {}
    for _, mod in ipairs(ns.renderTestModules) do
        for _, step in ipairs(mod.steps) do
            table.insert(sequence, { apply = mod.apply, state = step.state, fill = step.fill })
        end
    end

    local myGen = renderTestCycleGen
    local total = #sequence

    local function RunStep(i)
        if myGen ~= renderTestCycleGen then return end -- superseded by a newer cycle/clear
        if i > total then
            Print("Render test cycle: complete.")
            return
        end
        local step = sequence[i]
        Print(string.format("Render test cycle: step %d/%d - %s%s", i, total, tostring(step.state), step.fill and " (+fill)" or ""))
        pcall(step.apply, step.state, step.fill)
        C_Timer.After(delaySeconds, function() RunStep(i + 1) end)
    end

    Print(string.format("Render test cycle: starting, %d step(s), %.1fs apart. Make sure your test unit is targeted.", total, delaySeconds))
    RunStep(1)
end

SLASH_COASTATEPLATES1 = "/coasp"
SlashCmdList["COASTATEPLATES"] = function(msg)
    msg = msg or ""
    local cmd, rest = msg:match("^(%S*)%s*(.-)$")
    cmd = (cmd or ""):lower()

    if cmd == "aggro" then
        -- v3.6.0: the native threat-steering module's own surface
        if ns.Aggro.HandleCommand then
            pcall(ns.Aggro.HandleCommand, rest)
        else
            Print("AggroPlates module not loaded.")
        end
    elseif cmd == "log" then
        local subcmd, subrest = rest:match("^(%S*)%s*(.-)$")
        subcmd = (subcmd or ""):lower()
        if subcmd == "on" then
            SetLogging(true)
        elseif subcmd == "off" then
            SetLogging(false)
        elseif subcmd == "toggle" then
            -- v3.5.4 - quick on/off flip for live-testing sessions (a
            -- dungeon run needs to flip logging around specific pulls
            -- without remembering current state or retyping on/off).
            SetLogging(not ns.IsLogging())
        elseif subcmd == "status" then
            local count = COA_GuardianPlatesDB.log and #COA_GuardianPlatesDB.log or 0
            Print(string.format("Log/perf monitor: %s. %d entr%s buffered.",
                ns.IsLogging() and "ON" or "OFF", count, (count == 1) and "y" or "ies"))
        elseif subcmd == "dump" then
            -- v3.5.11: dump [n] [filter] - a leading numeric token is the
            -- count, everything after it is a plain substring filter (see
            -- DumpLog's own doc note). Either half is optional.
            local n, filterText = subrest:match("^(%d*)%s*(.-)$")
            DumpLog(n ~= "" and n or nil, filterText ~= "" and filterText or nil)
        elseif subcmd == "copy" then
            local n, filterText = subrest:match("^(%d*)%s*(.-)$")
            CopyLog(n ~= "" and n or nil, filterText ~= "" and filterText or nil)
        elseif subcmd == "clear" then
            COA_GuardianPlatesDB.log = {}
            Print("Log cleared.")
        elseif subcmd == "filter" then
            -- v3.5.41 - the STORE-time filter (see ns.SetLogStoreFilter's own
            -- doc note) - reserves the whole 300-entry buffer for matching
            -- lines instead of narrowing after the fact, for exactly the
            -- "noisy production combat blew through my budget before I could
            -- look" problem.
            local filterArg = subrest
            if filterArg == "" or filterArg:lower() == "status" then
                local current = ns.GetLogStoreFilter()
                Print("Log store-filter: " .. (current and ("'" .. current .. "' (only matching entries are being kept)") or "off (all entries kept, subject to the 300-entry cap)"))
            elseif filterArg:lower() == "off" then
                ns.SetLogStoreFilter(nil)
                Print("Log store-filter cleared - all entries will be kept again (up to the 300-entry cap).")
            else
                ns.SetLogStoreFilter(filterArg)
                Print("Log store-filter set to '" .. filterArg .. "' - only matching entries will be kept from now on (existing buffered entries are untouched; consider /coasp log clear first).")
            end
        else
            Print("/coasp log on|off|toggle|status|dump [n] [filter]|copy [n] [filter]|clear|filter <substring>|off|status - dump/copy's filter narrows what's READ back; 'log filter' narrows what's STORED in the first place, so a noisy session doesn't burn through the 300-entry buffer before you can look (e.g. 'log filter aggro' then 'log clear' to start a clean, aggro-only capture).")
        end
    elseif cmd == "roster" then
        local wasLogging = ns.IsLogging()
        if not wasLogging then SetLogging(true) end
        RefreshGroupRoster()
        if not wasLogging then SetLogging(false) end
        local units = ns.GetGroupUnits()
        Print(string.format("Roster: %d unit(s): %s",
            #units, (#units > 0) and table.concat(units, ", ") or "<empty>"))
    elseif cmd == "rendertest" then
        renderTestCycleGen = renderTestCycleGen + 1 -- any new invocation supersedes an in-flight cycle
        local sub, subrest = rest:match("^(%S*)%s*(.-)$")
        sub = (sub or ""):lower()
        if sub == "cycle" then
            RunRenderTestCycle(subrest)
        elseif sub ~= "" and tonumber(sub) then
            -- v3.5.10 - Battlewrath tried "/coasp rendertest 5" expecting it
            -- to just run the cycle with a 5s delay, skipping the word
            -- "cycle" entirely. Reasonable shorthand - a bare number can only
            -- ever mean a delay (no real state name is numeric), so accept
            -- it directly instead of falling through to "unknown state '5'".
            RunRenderTestCycle(sub)
        elseif sub ~= "" then
            local forceFill = subrest:lower() == "fill"
            if #ns.renderTestModules == 0 then
                Print("Render test: no module has registered a test.")
            else
                for _, mod in ipairs(ns.renderTestModules) do
                    pcall(mod.apply, sub, forceFill)
                end
            end
        else
            Print("/coasp rendertest secure|warning|danger|clear [fill] | rendertest cycle|<delaySeconds>")
        end
    elseif cmd == "probe" then
        -- v3.5.16 - Battlewrath: "Shall we add boarder correction? A single
        -- color wheel picker for enemy plates?" Before promising that feature,
        -- we need to know whether Ascension_NamePlates (the confirmed-active
        -- driver, client-embedded/unreadable source) actually draws a
        -- separate, colorable native border region on enemy plates, or
        -- whether the observed red tint is baked into the health bar's own
        -- texture with nothing separate to grab. This dumps every
        -- child/region under the target's plate (textures now included, with
        -- texture path/vertex color/draw layer) into a copyable text box so
        -- we can inspect it without a /reload + SavedVariables round-trip.
        ns.ProbeUnit(rest ~= "" and rest or nil)
    elseif cmd == "scanglobals" then
        -- v3.5.32 - see ns.ScanGlobalsForPattern's own doc note. Finds real
        -- candidate function names for the native-recolor-race hook instead
        -- of guessing blind, e.g. "/coasp scanglobals aggro" or "threat".
        if rest == "" then
            Print("/coasp scanglobals <substring> - lists every global function whose name contains it, e.g. 'scanglobals aggro'.")
        else
            local matches = ns.ScanGlobalsForPattern(rest)
            if #matches == 0 then
                Print("scanglobals '" .. rest .. "': no global functions matched.")
            else
                ns.ShowCopyableText(string.format("COA State Plates - Global functions matching '%s' (%d)", rest, #matches), table.concat(matches, "\n"))
                Print(string.format("scanglobals '%s': %d match(es) - copyable dump opened.", rest, #matches))
            end
        end
    elseif cmd == "aggrohooks" then
        -- v3.5.32 - reports whether any of the speculative candidate names
        -- actually exist as globals on this client (existing doesn't prove
        -- it's the real driver - only a live SPECULATIVE AGGRO HOOK FIRED
        -- log line during combat proves that).
        Print("Speculative aggro hook candidates:\n" .. ns.GetSpeculativeAggroHookStatus())
    elseif cmd == "scantables" then
        -- v3.5.35 - see ns.ScanGlobalTablesForPattern's own doc note. Checks
        -- for a real global color table (e.g. ThreatColor/ThreatBarColor)
        -- that GetThreatStatusColor might read from, so a fix could mutate
        -- the system's own data instead of hooksecurefunc-fighting a redraw.
        if rest == "" then
            Print("/coasp scantables <substring> - lists every global TABLE whose name contains it, e.g. 'scantables threat' or 'scantables color'.")
        else
            local matches = ns.ScanGlobalTablesForPattern(rest)
            if #matches == 0 then
                Print("scantables '" .. rest .. "': no global tables matched.")
            else
                ns.ShowCopyableText(string.format("COA State Plates - Global tables matching '%s' (%d)", rest, #matches), table.concat(matches, "\n"))
                Print(string.format("scantables '%s': %d match(es) - copyable dump opened.", rest, #matches))
            end
        end
    elseif cmd == "upvalues" then
        -- v3.5.37 - see ns.DumpFunctionUpvalues's own doc note. A color table
        -- captured only as a closure upvalue (never assigned to a global)
        -- would be invisible to scanglobals/scantables but not to this -
        -- e.g. "/coasp upvalues GetThreatStatusColor" or "upvalues UnitFrame_UpdateThreatIndicator".
        if rest == "" then
            Print("/coasp upvalues <globalFunctionName> - dumps a function's captured closure upvalues (including any table contents), e.g. 'upvalues GetThreatStatusColor'.")
        else
            local fn = _G[rest]
            if type(fn) ~= "function" then
                Print("upvalues '" .. rest .. "': not a known global function.")
            else
                local lines = ns.DumpFunctionUpvalues(fn)
                ns.ShowCopyableText(string.format("COA State Plates - Upvalues of %s", rest), table.concat(lines, "\n"))
                Print(string.format("upvalues '%s': %d upvalue(s) - copyable dump opened.", rest, #lines))
            end
        end
    elseif cmd == "watchaggro" then
        -- v3.5.39 - see ns.WatchNativeAggroHighlight's own doc note. Hooks
        -- the REAL aggroHighlight frame/texture instance on a plate directly
        -- (not a guessed global function name) and logs a debugstack every
        -- time Show/Hide/SetVertexColor fires on it - whatever function name
        -- shows up in that stack is the real driver on this client. Turn on
        -- /coasp log first, then hold/lose aggro on the watched unit.
        local unit = rest ~= "" and rest or "target"
        if not UnitExists(unit) then
            Print("/coasp watchaggro [unit] - no such unit ('" .. unit .. "'). Defaults to target.")
        else
            local okPlate, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
            if not okPlate or not plate then
                Print("watchaggro: '" .. unit .. "' has no active nameplate.")
            else
                local hasFrame, hasTexture = ns.WatchNativeAggroHighlight(plate)
                Print(string.format(
                    "watchaggro '%s': aggroHighlight frame %s, texture %s. Make sure /coasp log is ON, then hold/lose aggro on this unit and watch for 'AGGRO STACK WATCH' lines - the function named in that callstack is the real driver.",
                    unit, hasFrame and "found+hooked" or "NOT found", hasTexture and "found+hooked" or "NOT found"))
            end
        end
    elseif cmd == "suppressaggro" then
        -- v3.5.42 - see ns.SuppressNativeAggroHighlight's own doc note.
        -- Test-only: persistently Hide()s a unit's native aggroHighlight
        -- frame (instance-scoped hook, same proven mechanism as the v3.5.40
        -- recolor hook) so it can be verified live before any production
        -- wiring - the answer to Battlewrath's original "can we disable it"
        -- question. Usage: "/coasp suppressaggro on [unit]" or
        -- "/coasp suppressaggro off [unit]" (unit defaults to target).
        local sub, unitArg = rest:match("^(%S*)%s*(.-)$")
        sub = sub and sub:lower() or ""
        local unit = unitArg ~= "" and unitArg or "target"
        if sub ~= "on" and sub ~= "off" then
            Print("/coasp suppressaggro on|off [unit] - persistently Hide()s (on) or releases (off) a unit's native aggroHighlight frame. Defaults to target.")
        elseif not UnitExists(unit) then
            Print("/coasp suppressaggro - no such unit ('" .. unit .. "'). Defaults to target.")
        else
            local okPlate, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
            if not okPlate or not plate then
                Print("suppressaggro: '" .. unit .. "' has no active nameplate.")
            elseif sub == "on" then
                local ok = ns.SuppressNativeAggroHighlight(plate)
                Print("suppressaggro on '" .. unit .. "': " .. (ok and "applied, hold/lose aggro on this unit to verify it stays hidden." or "no native aggroHighlight frame found."))
            else
                ns.ClearNativeAggroHighlightSuppress(plate)
                Print("suppressaggro off '" .. unit .. "': cleared, native Show() will render again.")
            end
        end
    else
        Print("/coasp log on|off|toggle|status|dump [n] [filter]|copy [n] [filter]|clear|filter <substring>|off|status - unified debug log + perf monitor, shared by Core/Friendly/Enemy (dump/copy's filter narrows what's READ back; 'log filter' narrows what's STORED, reserving the 300-entry buffer for only what matches, e.g. 'log filter aggro' before a noisy combat session). /coasp roster - force a roster refresh and print the result now. /coasp rendertest secure|warning|danger|clear [fill] | cycle|<delaySeconds> - forces a state onto your current target's plate via the real executor calls, or auto-cycles through every registered state (a bare number is shorthand for cycle with that delay). /coasp probe [unit] - dumps every region/texture under a unit's nameplate (default target) into a copyable box, to inspect native border/texture structure. /coasp scanglobals <substring> - lists global functions matching a name pattern (e.g. 'aggro'). /coasp scantables <substring> - same, but for global tables (e.g. 'threat' or 'color') - checks for a mutable color table behind GetThreatStatusColor. /coasp aggrohooks - shows which speculative native-function hook candidates exist on this client. /coasp upvalues <funcname> - dumps a global function's captured closure upvalues, including table contents - finds color tables a scan of _G can't see, e.g. 'upvalues GetThreatStatusColor'. /coasp watchaggro [unit] - hooks the real aggroHighlight frame/texture on a unit's plate (default target) and logs a callstack every time it Shows/Hides/recolors, to discover the real driver function name regardless of what it's called. /coasp suppressaggro on|off [unit] - persistently Hide()s (on) or releases (off) a unit's native aggroHighlight frame via the same instance-scoped hook technique as watchaggro, to test disabling the native highlight outright.")
    end
end
