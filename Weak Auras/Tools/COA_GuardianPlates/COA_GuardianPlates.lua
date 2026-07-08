-- COA_GuardianPlates
-- Suppresses friendly PLAYER nameplates while leaving friendly guardian/
-- pet/NPC nameplates untouched, whenever the game's native "Friendly
-- Nameplates" option shows them. Low-risk theorycraft companion addon for
-- Conquest of Azeroth.
--
-- REWRITTEN after a real live crash proved the original premise wrong.
-- This addon originally assumed stock WotLK 3.3.5 nameplates with NO unit
-- token (the standard assumption for this client version - pre-Legion
-- nameplates normally have no GetNamePlateForUnit/C_NamePlate API at
-- all), so it tried to reconstruct player-vs-guardian identity itself by
-- watching COMBAT_LOG_EVENT_UNFILTERED flags and matching by display
-- NAME - a known, if fragile, technique for that era. That crashed live
-- ("bad argument #1 to 'band' (number expected, got string)") because
-- this server's CLEU argument layout didn't match the stock assumption
-- either.
--
-- Root cause of BOTH problems: the premise itself was wrong for this
-- specific server. Battlewrath installed TurboPlates (an Ascension-
-- approved nameplate replacement addon) and its own source (Core.lua,
-- Nameplates.lua) shows Ascension's client actually BACKPORTS the modern
-- (post-Legion) nameplate API: C_NamePlateManager.EnumerateActiveNamePlates(),
-- C_NamePlate.GetNamePlateForUnit(unit), and the NAME_PLATE_UNIT_ADDED/
-- NAME_PLATE_UNIT_REMOVED events, all with a REAL unit token per plate
-- (e.g. "nameplate3") - the exact thing that supposedly didn't exist in
-- this era. TurboPlates itself relies on exactly this (its own code
-- stores `myPlate.unit = unit` and calls UnitIsPlayer(unit)/
-- UnitPlayerControlled(unit) directly - no name-matching heuristics).
-- There was never a need to guess at unit identity at all.
--
-- This rewrite drops the entire combat-log/name-matching mechanism from
-- the original version and just uses the real API directly:
-- UnitIsPlayer(unit) + UnitIsFriend("player", unit) on the real per-plate
-- unit token, tracked via our own small table populated straight from the
-- NAME_PLATE_UNIT_ADDED/REMOVED events (not by re-deriving unit tokens
-- from EnumerateActiveNamePlates() each tick, since the exact field name
-- Ascension's backport uses there wasn't independently confirmed - the
-- ADDED/REMOVED events themselves hand us a guaranteed-correct unit token
-- directly, so there's no need to rely on that at all).
--
-- Confirmed distinct from the game's own separate friendly/enemy
-- nameplate toggles: TurboPlates' OptionsGUI.lua just wraps the stock
-- nameplateShowFriends/nameplateShowEnemies CVar family (plus their pet/
-- guardian/totem children) - there is no stock "nameplateShowFriendlyPlayers"
-- CVar anywhere, which is the actual gap this addon exists to fill.
-- Suppression here only ever fires for a unit that is BOTH a player AND
-- friendly, so an enemy player's nameplate (e.g. in a battleground, if
-- both toggles are on at once) is never touched.
--
-- Usage:
--   /coagp on|off|toggle  -> persistent (SavedVariables) enable switch.
--   /coagp status         -> prints current state + active plate count.
--   /coagp threat off|smart|always -> tri-state threat-coloring capability
--                            (v2.0, independent of the on/off switch above)
--                            - colors HOSTILE nameplate health bars by
--                            threat standing. See THREAT COLORING doc
--                            block further down for the full design.
--   /coagp scan           -> one-shot dump of every currently active
--                            nameplate (unit token, name, isPlayer,
--                            isFriend) to COA_GuardianPlatesDB.lastScan.
--                            /reload after running to flush to disk.
--   /coagp probe          -> one-shot frame-structure dump (children +
--                            regions) of the first suppressed friendly-
--                            player plate found, to
--                            COA_GuardianPlatesDB.lastProbe. Only needed
--                            if the floating name still disappears despite
--                            the selective-suppression path below - tells
--                            us the real field names to target on this
--                            client build. /reload after running to flush.
--   /coagp options|config -> opens ESC > Interface > AddOns > COA
--                            Guardian Plates directly. The GUI panel is
--                            deliberately just the on/off switch - scan
--                            and probe are debugging aids, not something a
--                            regular user needs, so they stay slash-only.
--   /coagp diag           -> prints how many REMOVED-restore events have
--                            been logged and how many needed the cached-
--                            plate fallback (see SANITATION FIX v2 note
--                            below). /reload then check
--                            COA_GuardianPlatesDB.removedLog for full
--                            per-event detail.
--
-- NOTE on "kills the name that hovers above" (live-test finding,
-- Battlewrath): SetAlpha() on the whole plate cascades multiplicatively to
-- every child region, so the floating name FontString can't stay visible
-- while its parent frame is at alpha 0 - there's no way to keep the name
-- and hide the rest by operating on the plate as a single object. Fixed
-- below by targeting the plate's sub-elements directly (health bar,
-- portrait, etc.) and explicitly re-asserting alpha 1 on the name region,
-- instead of collapsing the whole frame. This assumes the common
-- CompactUnitFrame-style layout (plate.UnitFrame.name as the name
-- FontString, sibling children/regions as the bar/portrait/etc.) since
-- this client's modern nameplate API is itself a backport of that system.
-- NOT independently confirmed against this client's exact field names yet
-- - if the name still vanishes, run /coagp probe and we'll adjust the
-- field names in GetNameRegion()/SetPlateBarsHidden() below to match
-- whatever this build actually uses. Falls back to old full-plate
-- SetAlpha(0) automatically if the expected structure isn't found, so
-- suppression still works (just without preserving the name) in that case.
--
-- Config is per-character (## SavedVariablesPerCharacter in the TOC), so
-- each of Battlewrath's characters keeps its own enabled/disabled state -
-- useful since a character mained as a healer may want full friendly
-- health bars visible rather than suppressed. Spec-aware auto-toggling
-- (e.g. auto-disable on a healer spec) was considered but deliberately
-- left out for now - it needs its own research pass to confirm the right
-- spec-change event on this client before wiring it up.
--
-- Optional guardian/pet/NPC color override (not a must, per Battlewrath -
-- the native default blue read as too bold/high-contrast): two independent
-- color swatches in the options panel (NPC, and Pet/Guardian/Totem),
-- split via UnitPlayerControlled - a reliable API for "owned by a player"
-- vs a plain NPC. A true three-way pet/guardian/totem split isn't cleanly
-- exposed via a single Lua call for units you don't own, so that stays a
-- combined bucket for now per Battlewrath's call, rather than guessing at
-- a heuristic. Each swatch opens Blizzard's stock ColorPickerFrame;
-- right-clicking restores the native color captured in `originalColors`
-- the first time it was overridden.
--
-- NAME TEXT TINT (Battlewrath: "Is it cheap to tint the name too?"): yes -
-- cheap, since the floating name FontString is already resolved via
-- GetNameRegion() for the alpha-preserve suppression logic above, so
-- tinting it just adds one more SetTextColor call alongside the existing
-- SetStatusBarColor call in ApplyGuardianColorForUnit, no new per-frame
-- cost. Native name color captured/restored via `originalNameColors`,
-- mirroring `originalColors` for the health bar.
--
-- ARMED GATE (Battlewrath, re: turning the addon off: "This goes to trust.
-- We shouldn't hijack the user's UI. We only apply anything when we're
-- armed."): color tinting was originally independent of the on/off switch
-- (framed as "purely cosmetic, doesn't hide anything" so it seemed
-- harmless to leave it running even while suppression was off). Changed
-- so tinting only ever applies while COA_GuardianPlatesDB.enabled is true
-- - see the gate in UpdatePlateForUnit and DisarmGuardianColors() (called
-- from SetEnabled(false)), which reverts every live-tinted plate back to
-- native the instant the switch flips off. The saved color preference
-- itself is untouched while disarmed - only the live plates are - so
-- re-enabling reapplies the same saved color automatically.
--
-- SANITATION FIX (live-observed bug, Battlewrath: "enemy NPCs losing their
-- level indicators"): nameplate frames on this client are pooled and
-- reused across unrelated units. The NAME_PLATE_UNIT_REMOVED handler used
-- to only clear our own bookkeeping tables without restoring the plate's
-- actual alpha/color first - so a suppressed/recolored friendly unit's
-- pooled frame could get silently handed to a completely different unit
-- (friend or foe) while still carrying our modified state. Fixed via
-- RestorePlateOnRemoved(), which explicitly restores the plate to its true
-- native state before our tracking tables are wiped - see the comment
-- above the event handler for the full explanation.
--
-- SANITATION FIX v2 (bug CONFIRMED STILL PRESENT after the above,
-- Battlewrath's live re-test): the v1 fix assumed GetNamePlateForUnit(unit)
-- still resolves at the exact moment NAME_PLATE_UNIT_REMOVED fires. If this
-- client actually severs the unit<->plate association before running our
-- handler, that lookup returns nil and the "restore" silently no-ops -
-- meaning v1 may have done nothing at all. Fixed by caching every plate
-- reference we successfully resolve (`platesByUnit`, populated in
-- UpdatePlateForUnit) and falling back to that cached Lua object reference
-- in RestorePlateOnRemoved if the direct lookup fails - a plain Frame
-- reference stays valid even after the client-side association is torn
-- down. Also added a small diagnostic log (removedLog, /coagp diag) that
-- records whether each restore resolved the plate directly or needed the
-- cache, so this can be CONFIRMED live instead of assumed again.
--
-- CONFIRMED (Battlewrath's removedLog capture, 2026-07-07, 20/20 events):
-- every single REMOVED-restore needed the cached-plate fallback -
-- resolvedDirectly was false and resolvedViaCache was true 100% of the
-- time. This isn't an edge case on this client, it's the norm: v1's direct
-- GetNamePlateForUnit(unit) lookup never once succeeds at REMOVED time, so
-- v1 alone really was doing nothing at all, confirming the theory above
-- rather than leaving it as a guess. The same capture's /coagp scan also
-- showed clean classification (friendly players suppressed, friendly
-- pets/enemies left alone) and a probe matching the known UnitFrame
-- container layout at a different pool index (Template21 vs the earlier
-- Template63) - further evidence the pool really is being recycled as
-- theorized.
--
-- THREAT COLORING (v2.0, 2026-07-08) - first of three capabilities picked
-- from the nameplate-addon code review + role research written up in
-- CAPABILITY_INVENTORY.md / ROLE_RESEARCH.md (Battlewrath's brief: capture
-- what TurboPlates/Kui_Nameplates/etc. do well, then build very light,
-- independently-toggleable versions into this addon rather than adopting
-- any of their full option surfaces). This is a genuinely new dimension
-- for the addon - everything above only ever touches FRIENDLY nameplates
-- (suppress players, tint pets/guardians/NPCs). Threat coloring instead
-- colors HOSTILE/enemy nameplates' health bars based on the player's own
-- threat standing on that unit, using UnitDetailedThreatSituation("player",
-- unit) - a genuine WotLK-era API (added in patch 3.0.2), not a modern-
-- client backport like the nameplate system itself, so there's no
-- "confirmed via TurboPlates" caveat needed here the way there was for the
-- nameplate API - this one is native to this exact expansion.
--
-- Tri-state (COA_GuardianPlatesDB.threatMode: 0=Off, 1=Smart, 2=Always On)
-- mirrors the exact shape both TurboPlates (`tankMode`) and Kui_Nameplates
-- (`tankmode.enabled`) independently converged on - two unrelated addon
-- authors landing on the same three-state design is a signal it's the
-- right default. "Smart" auto-detects a tank spec via real talent-point
-- introspection (IsTank(), ported from Kui_Nameplates' TankMode.lua, which
-- itself credits the idea to the ElitistJerks addon) rather than "whichever
-- tab has the most points," since a Feral druid or a Death Knight can't be
-- told apart from their DPS counterpart that way. "Always On" skips
-- detection and just always uses the tank-view color scheme, for anyone
-- who tanks without a dedicated tank-only spec.
--
-- This is its own independent toggle, deliberately NOT gated behind
-- COA_GuardianPlatesDB.enabled (the friendly-suppression switch) - a
-- genuine per-capability on/off selector, per Battlewrath's brief, so
-- suppression and threat coloring can each be on or off independently.
-- Same ARMED GATE discipline applies on its own terms though: nothing is
-- ever colored while threatMode is 0, and DisarmThreatColors() reverts
-- every live-colored plate back to native the instant it's switched off,
-- mirroring DisarmGuardianColors() above.
--
-- NOT YET LIVE-TESTED (flagged per this project's own "confirm before
-- trusting" discipline): the status-value semantics documented above
-- (0=safe, 1=approaching threat cap, 2=tanking-but-insecure, 3=tanking-
-- securely) are the standard documented behavior for this API era, but
-- haven't been independently confirmed against a real pull on this
-- specific server yet. `/coagp threat off|smart|always` is provided for
-- quick in-combat toggling to make that easy to check without alt-tabbing
-- to Interface Options.
--
-- HEALER MODE (v2.1, 2026-07-08) - a sub-option of suppression itself,
-- NOT an independent capability like threat coloring above. Battlewrath's
-- framing, verbatim: "Maybe this is a healer option to the suppression?" -
-- correct, and simpler than how this was first sketched (as a fourth
-- independent toggle): the whole premise only means anything while a
-- plate would otherwise BE suppressed, so it lives entirely inside the
-- existing enabled-suppression codepath rather than beside it.
--
-- What it does: for a friendly PLAYER who is also in your party or raid
-- (IsGroupOrRaidFriendlyPlayer), suppression behaves exactly as normal
-- (name-only) until that unit's health drops below
-- COA_GuardianPlatesDB.healerModeThreshold (default 80%) - at that point
-- the plate is un-suppressed (full health bar restored) and a new %HP
-- FontString is shown on it (GetOrCreateHealAlertText), since nameplates
-- don't ship a health-percent readout natively. Every friendly player NOT
-- in your group/raid is untouched by this - Battlewrath was explicit this
-- is about "who needs attention," not a general "show all ally health"
-- toggle, and showing every friendly player's health in a city would just
-- be noise.
--
-- ANTI-FLICKER TTL (Battlewrath, verbatim: "Hang open with a TTL... then
-- collapse back down... It's intent is to filter who needs attention vs
-- does not. Without becoming a flicker show."): a naive "un-suppress
-- below threshold, re-suppress above it" rule would flicker constantly
-- under any HoT or heal landing right at the threshold line. Fixed by
-- healAlertExpire[unit]: every time health is recomputed and is STILL
-- below threshold, this timestamp is pushed forward to
-- GetTime() + healerModeTTL (default 4s). The moment health recovers
-- above threshold, this stops refreshing - but the existing timestamp is
-- left alone rather than cleared, so the reveal keeps holding until that
-- TTL genuinely runs out. Only once BOTH conditions are true at the same
-- check (health >= threshold AND GetTime() >= healAlertExpire[unit]) does
-- SweepHealAlertExpirations() (piggybacked on the existing 0.5s
-- reclassifier throttle - no new per-frame cost) clear the alert and let
-- suppression resume.
--
-- COST (Battlewrath asked directly: "does that incur too much
-- processing? get hp, process amount, decide, redraw"): no - health
-- changes are event-driven (UNIT_HEALTH/UNIT_MAXHEALTH), not polled, so
-- there's no per-frame race to win here the way alpha suppression has.
-- One event, one division, one SetText() call, only for units that are
-- both friendly players AND in your group/raid - a small, bounded set
-- even in a 40-plate pull.
--
-- NOT YET LIVE-TESTED: same discipline as threat coloring above -
-- watch a real heal/damage exchange with a grouped, low-threshold test
-- (e.g. `/coagp healermode threshold 95`) and confirm the reveal/collapse
-- timing feels right before trusting the default 80%/4s values blind.

COA_GuardianPlatesDB = COA_GuardianPlatesDB or {}
if COA_GuardianPlatesDB.enabled == nil then
    COA_GuardianPlatesDB.enabled = true
end

-- Threat coloring is its own independent capability toggle (0=Off,
-- 1=Smart, 2=Always On) - see the v2.0 THREAT COLORING doc block above.
-- Deliberately separate from .enabled above.
if COA_GuardianPlatesDB.threatMode == nil then
    COA_GuardianPlatesDB.threatMode = 0
end

-- Healer mode (v2.1) is NOT an independent capability like threatMode
-- above - it's a sub-option of suppression itself (Battlewrath: "Maybe
-- this is a healer option to the suppression?" - correct call: the whole
-- premise is "reveal a plate that would otherwise be suppressed," so it
-- only ever does anything while COA_GuardianPlatesDB.enabled is true).
-- See the v2.1 HEALER MODE doc block above.
if COA_GuardianPlatesDB.healerModeEnabled == nil then
    COA_GuardianPlatesDB.healerModeEnabled = false
end
if COA_GuardianPlatesDB.healerModeThreshold == nil then
    COA_GuardianPlatesDB.healerModeThreshold = 80 -- percent
end
if COA_GuardianPlatesDB.healerModeTTL == nil then
    COA_GuardianPlatesDB.healerModeTTL = 4 -- seconds to hold the reveal open
end

-- Migrate the old single-bucket guardianColor (pre-split) into both new
-- buckets, so anyone who already set a custom color keeps it instead of
-- silently reverting to native on their next login.
if COA_GuardianPlatesDB.guardianColor and not COA_GuardianPlatesDB.npcColor and not COA_GuardianPlatesDB.petColor then
    local old = COA_GuardianPlatesDB.guardianColor
    COA_GuardianPlatesDB.npcColor = { r = old.r, g = old.g, b = old.b }
    COA_GuardianPlatesDB.petColor = { r = old.r, g = old.g, b = old.b }
end
COA_GuardianPlatesDB.guardianColor = nil

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[COA_GuardianPlates]|r " .. tostring(msg))
end

-- ---------------------------------------------------------------------
-- Core classification + suppression
-- ---------------------------------------------------------------------

-- unit token -> true, populated straight from NAME_PLATE_UNIT_ADDED/
-- REMOVED - the only source of truth this addon uses for "what plates
-- currently exist," so it never has to guess at field names on whatever
-- internal nameplate-manager table this client build actually has.
local activeUnits = {}

-- units we've actively dimmed, so we can restore them on removal or if
-- their classification ever changes (e.g. a mind-control edge case).
local suppressed = {}

-- unit token -> plate object, cached every time we successfully resolve
-- one via GetNamePlateForUnit. Exists because GetNamePlateForUnit(unit)
-- may already fail to resolve by the time NAME_PLATE_UNIT_REMOVED fires -
-- the unit-to-plate association can be torn down before our REMOVED
-- handler runs, in which case a fresh lookup returns nil and any restore
-- logic keyed off it silently no-ops. This cache gives RestorePlateOnRemoved
-- a fallback: the plate is just a Lua Frame reference, so it stays valid
-- even after the client severs the unit<->plate association.
local platesByUnit = {}

local function IsFriendlyPlayer(unit)
    if not unit or not UnitExists(unit) then return false end
    local okPlayer, isPlayer = pcall(UnitIsPlayer, unit)
    if not okPlayer or not isPlayer then return false end
    local okFriend, isFriend = pcall(UnitIsFriend, "player", unit)
    if not okFriend then return false end
    return isFriend and true or false
end

-- The complement of IsFriendlyPlayer: friendly guardians/pets/NPCs - the
-- exact bucket the color override below targets, independent of whether
-- suppression itself is enabled.
local function IsFriendlyNonPlayer(unit)
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
-- exposed via a single Lua call for units you don't own yourself - it'd
-- need heuristics (creature type, family) that risk misclassifying edge
-- cases, so this stays a clean two-way split per Battlewrath's call.
local function IsFriendlyPetOrGuardian(unit)
    if not IsFriendlyNonPlayer(unit) then return false end
    local okControlled, controlled = pcall(UnitPlayerControlled, unit)
    return okControlled and controlled and true or false
end

local function IsFriendlyNPC(unit)
    if not IsFriendlyNonPlayer(unit) then return false end
    local okControlled, controlled = pcall(UnitPlayerControlled, unit)
    return okControlled and (not controlled) and true or false
end

-- Healer mode (v2.1) only ever concerns friendly players who are also in
-- your party or raid - a general "show everyone's health" toggle would
-- just add noise for players you're not responsible for. See the v2.1
-- HEALER MODE doc block near the top of this file.
local function IsGroupOrRaidFriendlyPlayer(unit)
    if not IsFriendlyPlayer(unit) then return false end
    local okParty, inParty = pcall(UnitInParty, unit)
    local okRaid, inRaid = pcall(UnitInRaid, unit)
    return ((okParty and inParty) or (okRaid and inRaid)) and true or false
end

-- ---------------------------------------------------------------------
-- Tank-spec detection ("Smart" threat-coloring mode) - ported from
-- Kui_Nameplates' TankMode.lua (see CAPABILITY_INVENTORY.md). Real talent-
-- point introspection rather than "whichever tab has the most points,"
-- since e.g. Feral druid covers both cat-DPS and bear-tank builds off the
-- same tab, and Death Knights have no single dedicated tank tab in Wrath
-- at all (tank DKs are built from talents across all three trees, usually
-- Blood-heavy). Only used when threatMode == 1 (Smart); mode 2 (Always On)
-- skips this entirely.
-- ---------------------------------------------------------------------

local function GetTalentPointsSpent(spellID)
    local okName, spellName = pcall(GetSpellInfo, spellID)
    if not okName or not spellName then return 0 end
    local okTabs, numTabs = pcall(GetNumTalentTabs)
    if not okTabs or not numTabs then return 0 end
    for tabIndex = 1, numTabs do
        local okNumTalents, numTalents = pcall(GetNumTalents, tabIndex)
        if okNumTalents and numTalents then
            for talentIndex = 1, numTalents do
                local okInfo, name, _, _, _, spent = pcall(GetTalentInfo, tabIndex, talentIndex)
                if okInfo and name == spellName then
                    return spent or 0
                end
            end
        end
    end
    return 0
end

local function IsDeathKnightTank()
    -- idea taken from addon 'ElitistJerks' (via Kui_Nameplates)
    local tankTalents =
        (GetTalentPointsSpent(16271) >= 5 and 1 or 0) + -- Anticipation
        (GetTalentPointsSpent(49042) >= 5 and 1 or 0) + -- Toughness
        (GetTalentPointsSpent(55225) >= 5 and 1 or 0)   -- Blade Barrier
    return tankTalents >= 2
end

local function IsDruidTank()
    -- idea taken from addon 'ElitistJerks' (via Kui_Nameplates)
    local tankTalents =
        (GetTalentPointsSpent(57881) >= 2 and 1 or 0) + -- Natural Reaction
        (GetTalentPointsSpent(16929) >= 3 and 1 or 0) + -- Thick Hide
        (GetTalentPointsSpent(61336) >= 1 and 1 or 0) + -- Survival Instincts
        (GetTalentPointsSpent(57877) >= 3 and 1 or 0)   -- Protector of the Pack
    return tankTalents >= 3
end

local function IsTank()
    local okClass, _, class = pcall(UnitClass, "player")
    if not okClass or not class then return false end

    if class == "WARRIOR" then
        local okTab, _, _, points = pcall(GetTalentTabInfo, 3) -- Protection
        return okTab and points and points >= 51 and true or false
    elseif class == "PALADIN" then
        local okTab, _, _, points = pcall(GetTalentTabInfo, 2) -- Protection
        return okTab and points and points >= 51 and true or false
    elseif class == "DRUID" then
        local okTab, _, _, points = pcall(GetTalentTabInfo, 2) -- Feral
        return okTab and points and points >= 51 and IsDruidTank() and true or false
    elseif class == "DEATHKNIGHT" then
        return IsDeathKnightTank() and true or false
    end
    return false
end

-- A hostile/attackable unit is the complement of the friendly buckets
-- above - the pool threat coloring below considers. Deliberately not
-- keyed off combat state (UnitAffectingCombat) since a fresh pull's very
-- first GCD is exactly when a tank most wants to see this).
local function IsPotentialThreatUnit(unit)
    if not unit or not UnitExists(unit) then return false end
    local okFriend, isFriend = pcall(UnitIsFriend, "player", unit)
    if okFriend and isFriend then return false end
    local okAttack, canAttack = pcall(UnitCanAttack, "player", unit)
    return okAttack and canAttack and true or false
end

-- Finds the plate's name FontString + the container it lives in. Tries the
-- common CompactUnitFrame-style layout first (plate.UnitFrame.name), then
-- falls back to the name living directly on the plate. Returns nil, nil if
-- neither matches, so callers can fall back to old-style full suppression.
local function GetNameRegion(plate)
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
local function GetHealthBar(plate)
    if plate.UnitFrame and plate.UnitFrame.healthBar then
        return plate.UnitFrame.healthBar
    end
    if plate.healthBar then
        return plate.healthBar
    end
    return nil
end

-- ---------------------------------------------------------------------
-- Healer mode (v2.1) - state + the %HP text overlay. See the v2.1 HEALER
-- MODE doc block near the top of this file for the full design.
-- ---------------------------------------------------------------------

-- unit token -> true while this group/raid member's plate is currently
-- revealed (un-suppressed + %HP text shown) due to dropping below
-- healerModeThreshold. Cleared on NAME_PLATE_UNIT_REMOVED like every
-- other per-unit table.
local healAlerted = {}

-- unit token -> GetTime() this unit's reveal is allowed to collapse at.
-- Refreshed forward every time health is recomputed and still below
-- threshold; left alone (not cleared) once health recovers, so the
-- reveal keeps holding until this timestamp genuinely passes - this is
-- what gives the anti-flicker "hang open with a TTL" behavior instead of
-- an instant collapse the moment a heal lands.
local healAlertExpire = {}

-- Looks up (without creating) the %HP FontString already attached to a
-- plate's container, or nil if none exists yet. Used by cleanup paths
-- that only need to hide an existing text, not conjure a new one just to
-- immediately hide it.
local function GetHealAlertText(plate)
    local _, container = GetNameRegion(plate)
    container = container or plate
    return container and container.coagpHealAlertText
end

-- Lazily creates (once per pooled plate) a small FontString showing HP%,
-- centered on the health bar. Nameplates don't ship one of these
-- natively, unlike the name FontString GetNameRegion() already finds.
-- Cached directly on the plate's container so it survives pooled-frame
-- reuse safely - mirrors TurboPlates' own EnsureHealerIcon pattern
-- (create once, Hide() by default, only Show() when actually relevant).
local function GetOrCreateHealAlertText(plate)
    local _, container = GetNameRegion(plate)
    container = container or plate
    if not container then return nil end
    if container.coagpHealAlertText then
        return container.coagpHealAlertText
    end

    local healthBar = GetHealthBar(plate)
    if not healthBar then return nil end

    local text = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
    text:Hide()
    container.coagpHealAlertText = text
    return text
end

-- unit token -> {r,g,b} native color, captured the first time we override
-- a given unit's health bar color this occupancy (cleared on
-- NAME_PLATE_UNIT_REMOVED, same lifetime as `suppressed`) - lets us put
-- the original color back exactly, without hardcoding a guess at what
-- "native blue" actually is.
local originalColors = {}

-- Same idea as originalColors, but for the floating name FontString's text
-- color (Battlewrath: "Is it cheap to tint the name too?"). Kept as a
-- separate table rather than folded into originalColors since the name
-- region is a different object (FontString, not StatusBar) and may resolve
-- even when the health bar doesn't (or vice versa) depending on layout.
local originalNameColors = {}

-- Optional cosmetic recolor for friendly guardian/pet/NPC health bars AND
-- their floating name text - only ever pushed onto a live plate while the
-- addon is armed (see the ARMED GATE note near the top of this file; the
-- call site in UpdatePlateForUnit gates this whole function on
-- COA_GuardianPlatesDB.enabled). Split into two independently-configurable
-- buckets: COA_GuardianPlatesDB.npcColor (plain NPCs) and .petColor (pets/
-- guardians/totems, anything UnitPlayerControlled), both nil by default
-- (native color untouched). Once set via the options panel color picker,
-- this pushes the relevant bucket's color onto both the health bar and the
-- name text of matching units, and restores each captured native color if
-- later cleared. Name tinting rides the exact same GetNameRegion() lookup
-- the alpha-preserve suppression logic already uses, so there's no new
-- per-frame cost - just one more SetTextColor call alongside the existing
-- SetStatusBarColor call, both only on the 0.5s reclassify sweep (or on
-- ADD), same as before.
local function ApplyGuardianColorForUnit(unit, plate)
    local healthBar = GetHealthBar(plate)
    local nameRegion = GetNameRegion(plate)

    local override
    if IsFriendlyPetOrGuardian(unit) then
        override = COA_GuardianPlatesDB.petColor
    elseif IsFriendlyNPC(unit) then
        override = COA_GuardianPlatesDB.npcColor
    end

    if healthBar then
        if override then
            if not originalColors[unit] then
                local okGet, r, g, b = pcall(healthBar.GetStatusBarColor, healthBar)
                if okGet and r then
                    originalColors[unit] = { r = r, g = g, b = b }
                end
            end
            pcall(healthBar.SetStatusBarColor, healthBar, override.r, override.g, override.b)
        elseif originalColors[unit] then
            local c = originalColors[unit]
            pcall(healthBar.SetStatusBarColor, healthBar, c.r, c.g, c.b)
        end
    end

    if nameRegion then
        if override then
            if not originalNameColors[unit] then
                local okGet, r, g, b = pcall(nameRegion.GetTextColor, nameRegion)
                if okGet and r then
                    originalNameColors[unit] = { r = r, g = g, b = b }
                end
            end
            pcall(nameRegion.SetTextColor, nameRegion, override.r, override.g, override.b)
        elseif originalNameColors[unit] then
            local c = originalNameColors[unit]
            pcall(nameRegion.SetTextColor, nameRegion, c.r, c.g, c.b)
        end
    end
end

-- ---------------------------------------------------------------------
-- Threat coloring (v2.0) - colors a HOSTILE unit's health bar based on the
-- player's own threat standing on it. See the THREAT COLORING doc block
-- near the top of this file for the full design reasoning.
-- ---------------------------------------------------------------------

-- unit token -> native health-bar color, captured the first time we apply
-- a threat override. Kept separate from originalColors above (the
-- friendly guardian/pet/NPC bucket) since these two sets are effectively
-- disjoint (friendly vs hostile) - a shared table would only ever risk
-- confusion on a genuine mind-control edge case.
local originalThreatColors = {}

-- Fixed colors, not user-configurable yet - kept deliberately light per
-- Battlewrath's brief ("very light versions... per capability on/off
-- selector"). A color picker could be added later the same way
-- npcColor/petColor already work, if wanted.
local THREAT_COLOR_SECURE  = { r = 0.1, g = 0.9, b = 0.2 } -- holding aggro safely (tank view)
local THREAT_COLOR_WARNING = { r = 1.0, g = 0.6, b = 0.0 } -- transitional / approaching threat cap
local THREAT_COLOR_DANGER  = { r = 1.0, g = 0.1, b = 0.1 } -- lost aggro (tank view) / has aggro (non-tank view)

-- Returns {r,g,b} or nil (nil = leave native). Caller must already have
-- confirmed `unit` is a valid hostile/enemy nameplate unit via
-- IsPotentialThreatUnit. Uses UnitDetailedThreatSituation("player", unit) -
-- isTanking = "player" is this unit's current primary target; status
-- further distinguishes secure (3) tanking from about-to-lose-it (2), or
-- safe (0) from about-to-pull-aggro (1) when not tanking. Tank view and
-- non-tank view intentionally read the same isTanking/status pair
-- differently - see ROLE_RESEARCH.md for why (a tank without aggro is bad
-- for a tank, but exactly the safe default state for everyone else).
local function GetThreatColorForUnit(unit)
    local mode = COA_GuardianPlatesDB.threatMode
    if not mode or mode == 0 then return nil end

    local okThreat, isTanking, status = pcall(UnitDetailedThreatSituation, "player", unit)
    if not okThreat then return nil end
    isTanking = isTanking and true or false
    status = status or 0

    local tankView
    if mode == 2 then
        tankView = true -- Always On: skip detection, force tank-view scheme
    else
        tankView = IsTank() -- Smart
    end

    if tankView then
        if isTanking and status == 3 then
            return THREAT_COLOR_SECURE
        elseif isTanking and status == 2 then
            return THREAT_COLOR_WARNING
        elseif not isTanking then
            return THREAT_COLOR_DANGER -- a tank without aggro needs to taunt back
        end
        return nil
    else
        if isTanking then
            return THREAT_COLOR_DANGER -- non-tank holding aggro is bad
        elseif status == 1 then
            return THREAT_COLOR_WARNING -- approaching the tank's threat
        end
        return nil -- status 0: safe, leave native
    end
end

-- Applies (or clears) the threat color override on a hostile plate's
-- health bar - same capture-native-then-restore shape as
-- ApplyGuardianColorForUnit above, keyed off originalThreatColors instead.
-- Deliberately leaves the name text untouched (the bar color IS the
-- signal here - every reference addon in CAPABILITY_INVENTORY.md works
-- this way too).
local function ApplyThreatColorForUnit(unit, plate)
    local healthBar = GetHealthBar(plate)
    if not healthBar then return end

    local color = GetThreatColorForUnit(unit)

    if color then
        if not originalThreatColors[unit] then
            local okGet, r, g, b = pcall(healthBar.GetStatusBarColor, healthBar)
            if okGet and r then
                originalThreatColors[unit] = { r = r, g = g, b = b }
            end
        end
        pcall(healthBar.SetStatusBarColor, healthBar, color.r, color.g, color.b)
    elseif originalThreatColors[unit] then
        local c = originalThreatColors[unit]
        pcall(healthBar.SetStatusBarColor, healthBar, c.r, c.g, c.b)
        originalThreatColors[unit] = nil
    end
end

-- Reverts every currently threat-colored plate back to its captured native
-- color - called the instant threatMode flips to 0, mirroring
-- DisarmGuardianColors()'s "don't leave anything of ours on a plate once
-- the capability is switched off" discipline, applied to this capability's
-- own independent toggle.
local function DisarmThreatColors()
    for unit in pairs(activeUnits) do
        if originalThreatColors[unit] then
            local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
            if not ok or not plate then
                plate = platesByUnit[unit]
            end
            if plate then
                local healthBar = GetHealthBar(plate)
                if healthBar then
                    local c = originalThreatColors[unit]
                    pcall(healthBar.SetStatusBarColor, healthBar, c.r, c.g, c.b)
                end
            end
            originalThreatColors[unit] = nil
        end
    end
end

-- Shared setter - used by both the options panel dropdown and the
-- `/coagp threat` slash subcommand, so there's only one place that knows
-- how to disarm cleanly.
local function SetThreatMode(mode)
    mode = tonumber(mode) or 0
    if mode < 0 or mode > 2 then mode = 0 end
    COA_GuardianPlatesDB.threatMode = mode
    if mode == 0 then
        pcall(DisarmThreatColors)
    end
end

-- Hides every sibling of the name region (health bar, portrait, border,
-- cast bar, etc.) while explicitly keeping the name itself at alpha 1, so
-- the floating name stays visible even while the rest of the plate is
-- suppressed. Returns false (and does nothing) if the expected structure
-- isn't found, so the caller can fall back to full-plate SetAlpha.
local function SetPlateBarsHidden(plate, hidden)
    local nameRegion, container = GetNameRegion(plate)
    if not nameRegion or not container then
        return false
    end

    -- GetChildren()/GetRegions() return every result as separate values,
    -- not a single table - pack them all via {...} so none get dropped.
    local childResults = { pcall(container.GetChildren, container) }
    if childResults[1] then
        for i = 2, #childResults do
            local child = childResults[i]
            if child and child ~= nameRegion then
                pcall(child.SetAlpha, child, hidden and 0 or 1)
            end
        end
    end

    local regionResults = { pcall(container.GetRegions, container) }
    if regionResults[1] then
        for i = 2, #regionResults do
            local region = regionResults[i]
            if region and region ~= nameRegion then
                pcall(region.SetAlpha, region, hidden and 0 or 1)
            end
        end
    end

    pcall(nameRegion.SetAlpha, nameRegion, 1)
    return true
end

local function UpdatePlateForUnit(unit)
    if not unit then return end
    local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
    if not ok or not plate then return end

    platesByUnit[unit] = plate

    -- Healer mode (v2.1): a group/raid member currently below the HP
    -- threshold overrides suppression for their own plate only - this is
    -- the entire mechanism, no separate arm/disarm lifecycle needed since
    -- it's read fresh here every time suppression itself is (re)computed.
    -- See the v2.1 HEALER MODE doc block near the top of this file.
    local shouldSuppress = COA_GuardianPlatesDB.enabled and IsFriendlyPlayer(unit) and not healAlerted[unit]

    if shouldSuppress then
        local okSelective, didSelective = pcall(SetPlateBarsHidden, plate, true)
        if not (okSelective and didSelective) then
            plate:SetAlpha(0) -- fallback: hides the name too, better than nothing
        end
        suppressed[unit] = true
    elseif suppressed[unit] then
        pcall(SetPlateBarsHidden, plate, false)
        plate:SetAlpha(1)
        suppressed[unit] = nil
    end

    -- ARMED GATE (Battlewrath: "This goes to trust. We shouldn't hijack
    -- the user's UI. We only apply anything when we're armed."): color
    -- tinting only fires while COA_GuardianPlatesDB.enabled is true. This
    -- used to be independent of the on/off switch entirely (color was
    -- framed as "purely cosmetic, doesn't hide anything" so it seemed
    -- harmless to leave running) - but on reflection, the addon shouldn't
    -- be touching the client's nameplates AT ALL while the user has
    -- switched it off, tinting included. See DisarmGuardianColors() below
    -- for the matching revert step run the moment the switch flips off.
    if COA_GuardianPlatesDB.enabled and IsFriendlyNonPlayer(unit) then
        pcall(ApplyGuardianColorForUnit, unit, plate)
    end

    -- Threat coloring (v2.0) - its own independent toggle, not gated by
    -- COA_GuardianPlatesDB.enabled above. See THREAT COLORING doc block.
    if COA_GuardianPlatesDB.threatMode and COA_GuardianPlatesDB.threatMode > 0 and IsPotentialThreatUnit(unit) then
        pcall(ApplyThreatColorForUnit, unit, plate)
    end
end

-- ---------------------------------------------------------------------
-- Healer mode (v2.1) - reveal/collapse logic. See the v2.1 HEALER MODE
-- doc block near the top of this file for the full design.
-- ---------------------------------------------------------------------

-- Recomputes heal-alert state for a single group/raid friendly-player
-- unit and re-derives suppression/the %HP text from it. Only ever ARMS
-- the alert (sets healAlerted[unit] = true and pushes healAlertExpire
-- forward) - clearing it is SweepHealAlertExpirations()'s job alone, so
-- the TTL's anti-flicker behavior (hold open until genuinely expired) is
-- never accidentally short-circuited by this function running again
-- while still above threshold.
local function UpdateHealAlertForUnit(unit)
    if not COA_GuardianPlatesDB.healerModeEnabled then return end
    if not COA_GuardianPlatesDB.enabled then return end -- sub-option of suppression
    if not IsGroupOrRaidFriendlyPlayer(unit) then return end

    local okMax, maxHP = pcall(UnitHealthMax, unit)
    if not okMax or not maxHP or maxHP <= 0 then return end
    local okHP, hp = pcall(UnitHealth, unit)
    if not okHP or not hp then return end

    local percent = (hp / maxHP) * 100
    local threshold = COA_GuardianPlatesDB.healerModeThreshold or 80
    local ttl = COA_GuardianPlatesDB.healerModeTTL or 4

    if percent < threshold then
        healAlerted[unit] = true
        healAlertExpire[unit] = GetTime() + ttl
    end

    local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
    if not ok or not plate then return end

    pcall(UpdatePlateForUnit, unit) -- re-derives suppression from healAlerted

    if healAlerted[unit] then
        local text = GetOrCreateHealAlertText(plate)
        if text then
            text:SetText(string.format("%d%%", math.floor(percent + 0.5)))
            text:Show()
        end
    end
end

-- Throttled sweep (piggybacked on the existing 0.5s reclassifier below -
-- no new per-frame cost) that's the ONLY thing allowed to clear a heal
-- alert: only once health is back at/above threshold AND the TTL
-- timestamp has genuinely passed does the plate re-suppress and the %HP
-- text hide. This is what turns "threshold crossed" into "hang open,
-- then collapse" instead of an instant, flicker-prone toggle.
local function SweepHealAlertExpirations()
    if not COA_GuardianPlatesDB.healerModeEnabled then return end
    local now = GetTime()

    for unit in pairs(healAlerted) do
        local okMax, maxHP = pcall(UnitHealthMax, unit)
        local okHP, hp = pcall(UnitHealth, unit)
        local percent = 0
        if okMax and okHP and maxHP and maxHP > 0 and hp then
            percent = (hp / maxHP) * 100
        end
        local threshold = COA_GuardianPlatesDB.healerModeThreshold or 80

        if percent >= threshold and now >= (healAlertExpire[unit] or 0) then
            healAlerted[unit] = nil
            healAlertExpire[unit] = nil

            pcall(UpdatePlateForUnit, unit) -- re-suppresses now that healAlerted is clear

            local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
            if ok and plate then
                local text = GetHealAlertText(plate)
                if text then text:Hide() end
            end
        end
    end
end

-- Reverts every currently-tinted guardian/pet/NPC plate (health bar + name
-- text) back to its captured native color, then clears the capture -
-- called the instant the addon is disarmed (SetEnabled(false)) so nothing
-- of ours is left on a plate while the user has switched us off. Walks
-- every activeUnit (not just whichever one triggered this), since plates
-- can still be on screen at the moment of disarming. Clearing the capture
-- (rather than leaving it) matters so re-arming captures a fresh native
-- baseline instead of "restoring" an already-restored value. The saved
-- preference itself (npcColor/petColor in SavedVariables) is untouched -
-- only the live plates are - so re-enabling reapplies the same color
-- automatically via the normal ApplyGuardianColorForUnit path.
local function DisarmGuardianColors()
    for unit in pairs(activeUnits) do
        if originalColors[unit] or originalNameColors[unit] then
            local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
            if not ok or not plate then
                plate = platesByUnit[unit]
            end

            if plate then
                if originalColors[unit] then
                    local healthBar = GetHealthBar(plate)
                    if healthBar then
                        local c = originalColors[unit]
                        pcall(healthBar.SetStatusBarColor, healthBar, c.r, c.g, c.b)
                    end
                end
                if originalNameColors[unit] then
                    local nameRegion = GetNameRegion(plate)
                    if nameRegion then
                        local c = originalNameColors[unit]
                        pcall(nameRegion.SetTextColor, nameRegion, c.r, c.g, c.b)
                    end
                end
            end

            originalColors[unit] = nil
            originalNameColors[unit] = nil
        end
    end
end

-- Shared enable/disable path - used by both the slash command and the
-- Interface Options checkbox, so there's only one place that knows how to
-- restore every currently-suppressed plate (and, per the ARMED GATE note
-- above, every currently-tinted plate) on disable.
local function SetEnabled(enabled)
    COA_GuardianPlatesDB.enabled = enabled and true or false
    if not COA_GuardianPlatesDB.enabled then
        for unit in pairs(suppressed) do
            local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
            if ok and plate then
                pcall(SetPlateBarsHidden, plate, false)
                plate:SetAlpha(1)
            end
        end
        wipe(suppressed)
        pcall(DisarmGuardianColors)
    end
end

-- BUGFIX (live-observed, Battlewrath): "enemy NPCs losing their level
-- indicators" traced back to here. Nameplate frames on this client are
-- POOLED and reused across unrelated units over time (confirmed via
-- /coagp probe - the container name literally reads
-- "NamePlateDriverFramePoolFrameNamePlateUnitFrameTemplate63..."). The old
-- REMOVED handler only cleared our own bookkeeping tables (suppressed,
-- originalColors) without ever restoring the plate's actual alpha/color -
-- so if a friendly player we'd suppressed (health bar/portrait/level text
-- all hidden, only name left visible) walked out of nameplate range, that
-- same pooled frame object would get silently handed to the NEXT unit
-- placed on it - potentially a totally unrelated enemy NPC - while still
-- carrying our alpha-0 state on everything but the name region. Same leak
-- applies to a custom health bar color if one was active. Sanitized by
-- restoring the plate to its true native state (unhide via
-- SetPlateBarsHidden/SetAlpha, and restore the captured native color)
-- BEFORE wiping our own tracking, not just after - this closes the gap
-- for any unit occupying this pooled frame next, friend or foe.
-- Small rolling diagnostic log (capped at 20 entries), so we can CONFIRM
-- rather than assume whether GetNamePlateForUnit(unit) was still resolving
-- at REMOVED time on this client - the live bug report ("still present"
-- after the first version of this fix) means that assumption needs
-- checking rather than trusting. Only logs when there was actually
-- something to restore, to keep it meaningful.
local function LogRemovedRestore(unit, resolvedDirectly, resolvedViaCache, restoredSuppress, restoredColor)
    COA_GuardianPlatesDB.removedLog = COA_GuardianPlatesDB.removedLog or {}
    local log = COA_GuardianPlatesDB.removedLog
    table.insert(log, {
        capturedAt = date("%Y-%m-%d %H:%M:%S"),
        unit = unit,
        resolvedDirectly = resolvedDirectly,
        resolvedViaCache = resolvedViaCache,
        restoredSuppress = restoredSuppress,
        restoredColor = restoredColor,
    })
    while #log > 20 do
        table.remove(log, 1)
    end
end

local function RestorePlateOnRemoved(unit)
    local plate
    local resolvedDirectly = false
    local resolvedViaCache = false

    local ok, resolved = pcall(C_NamePlate.GetNamePlateForUnit, unit)
    if ok and resolved then
        plate = resolved
        resolvedDirectly = true
    elseif platesByUnit[unit] then
        -- Direct lookup failed - fall back to our cached reference from
        -- the last time this unit's plate was successfully resolved.
        plate = platesByUnit[unit]
        resolvedViaCache = true
    end

    local restoredSuppress = false
    local restoredColor = false

    if plate then
        if suppressed[unit] then
            pcall(SetPlateBarsHidden, plate, false)
            pcall(plate.SetAlpha, plate, 1)
            restoredSuppress = true
        end

        if originalColors[unit] then
            local healthBar = GetHealthBar(plate)
            if healthBar then
                local c = originalColors[unit]
                pcall(healthBar.SetStatusBarColor, healthBar, c.r, c.g, c.b)
                restoredColor = true
            end
        end

        if originalNameColors[unit] then
            local nameRegion = GetNameRegion(plate)
            if nameRegion then
                local c = originalNameColors[unit]
                pcall(nameRegion.SetTextColor, nameRegion, c.r, c.g, c.b)
                restoredColor = true
            end
        end

        if originalThreatColors[unit] then
            local healthBar = GetHealthBar(plate)
            if healthBar then
                local c = originalThreatColors[unit]
                pcall(healthBar.SetStatusBarColor, healthBar, c.r, c.g, c.b)
                restoredColor = true
            end
        end

        -- Healer mode (v2.1): hide (not recreate) any %HP text so a
        -- pooled frame handed to an unrelated next occupant doesn't carry
        -- a stale reveal-text leftover, same pooled-frame-safety
        -- discipline as the suppression/color restores above.
        if healAlerted[unit] then
            local text = GetHealAlertText(plate)
            if text then text:Hide() end
        end
    end

    if suppressed[unit] or originalColors[unit] or originalNameColors[unit] or originalThreatColors[unit] or healAlerted[unit] then
        pcall(LogRemovedRestore, unit, resolvedDirectly, resolvedViaCache, restoredSuppress, restoredColor)
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
-- Threat coloring (v2.0): these fire whenever the client itself recomputes
-- a unit's threat standing (any unit it's currently tracking for display
-- purposes - target/party/nameplate units all qualify), so we get
-- near-real-time recoloring instead of waiting on the 0.5s reclassifier
-- sweep below. Genuine WotLK-era events (added alongside
-- UnitDetailedThreatSituation in patch 3.0.2), not a modern-client
-- backport, so no "confirmed via TurboPlates" caveat needed here.
eventFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
eventFrame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
-- Healer mode (v2.1): health changes are event-driven, not polled - see
-- the COST paragraph in the v2.1 HEALER MODE doc block near the top of
-- this file. UNIT_MAXHEALTH also matters on its own (e.g. a buff/debuff
-- changing max health without a matching UNIT_HEALTH tick would otherwise
-- leave the percentage stale).
eventFrame:RegisterEvent("UNIT_HEALTH")
eventFrame:RegisterEvent("UNIT_MAXHEALTH")
eventFrame:SetScript("OnEvent", function(self, event, unit)
    if event == "NAME_PLATE_UNIT_ADDED" then
        activeUnits[unit] = true
        pcall(UpdatePlateForUnit, unit)
        -- Healer mode: catch a unit that's already below threshold the
        -- moment their plate first appears (e.g. joining a fight in
        -- progress), rather than waiting for the next health event.
        pcall(UpdateHealAlertForUnit, unit)
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        pcall(RestorePlateOnRemoved, unit)
        activeUnits[unit] = nil
        suppressed[unit] = nil
        originalColors[unit] = nil
        originalNameColors[unit] = nil
        originalThreatColors[unit] = nil
        healAlerted[unit] = nil
        healAlertExpire[unit] = nil
        platesByUnit[unit] = nil
    elseif event == "UNIT_THREAT_SITUATION_UPDATE" or event == "UNIT_THREAT_LIST_UPDATE" then
        if COA_GuardianPlatesDB.threatMode and COA_GuardianPlatesDB.threatMode > 0 and unit then
            local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
            if ok and plate and IsPotentialThreatUnit(unit) then
                pcall(ApplyThreatColorForUnit, unit, plate)
            end
        end
    elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        if unit and COA_GuardianPlatesDB.healerModeEnabled then
            pcall(UpdateHealAlertForUnit, unit)
        end
    end
end)

-- CONFIRMED LIVE (Battlewrath): running the reapply every single frame,
-- rather than a 0.15s throttle, fixed the flicker - Ascension's own baked-
-- in nameplate driver recalculates alpha every rendered frame, so anything
-- less than full per-frame cadence loses that race most of the time.
-- Selective bar suppression (SetPlateBarsHidden, above) is also confirmed
-- live: probing a real plate showed plate.UnitFrame as the container, with
-- a Name FontString region sitting alongside healthBar/PowerBar/castBar
-- StatusBars and a few unnamed Frames/Textures - suppression now leaves
-- the floating name up while hiding the rest.
--
-- LEAN REFINEMENT: the original version reclassified every active plate
-- (UnitIsPlayer/UnitIsFriend, the more expensive half of this addon's
-- work) on every single frame, even for guardians/pets/NPCs that never
-- need touching once classified. Split into two loops instead:
--   1. ReapplySuppressed(), driven by `scanner` below, runs every frame
--      but only walks the `suppressed` table - just the friendly players
--      we've already decided to fight for - re-asserting suppression with
--      no reclassification. This is the loop that actually needs to win
--      the per-frame race against the native driver.
--   2. `reclassifier` below walks the full `activeUnits` set on a slower
--      throttle (RECLASSIFY_INTERVAL), to catch anything the ADD/REMOVED
--      events alone would miss - a unit's friend/player status changing
--      without a plate remove/add cycle (e.g. a mind-control edge case).
-- In a busy area (the 51-plate scan Battlewrath captured), this drops the
-- per-frame classification cost from ~51 units to just however many are
-- actually suppressed friendly players, since guardians/pets/NPCs no
-- longer pay any per-frame cost at all.
--
-- The guardian/NPC color override (ApplyGuardianColorForUnit, above) rides
-- on this same infrastructure for free - it's called from inside
-- UpdatePlateForUnit, so it already gets reapplied on every ADD event and
-- on this 0.5s reclassify sweep, with no separate loop needed. NOT YET
-- CONFIRMED LIVE whether that cadence is fast enough - alpha needed full
-- per-frame cadence to stick because the native driver recalculates it
-- every frame, but bar *color* is more commonly set once per relevant
-- event (health/faction change) rather than every frame, so 0.5s may well
-- be enough. If a custom guardian color visibly reverts/flickers in
-- testing, move ApplyGuardianColorForUnit into ReapplySuppressed's every-
-- frame loop instead (would need its own tracked-unit set, mirroring
-- `suppressed`, since ReapplySuppressed only walks that table today).
local function ReapplySuppressed()
    for unit in pairs(suppressed) do
        local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
        if ok and plate then
            local okSelective, didSelective = pcall(SetPlateBarsHidden, plate, true)
            if not (okSelective and didSelective) then
                plate:SetAlpha(0)
            end
        end
    end
end

local scanner = CreateFrame("Frame")
scanner:SetScript("OnUpdate", function(self, elapsed)
    ReapplySuppressed()
end)

local reclassifier = CreateFrame("Frame")
local reclassifyElapsed = 0
local RECLASSIFY_INTERVAL = 0.5 -- cosmetic filter, not combat-critical

reclassifier:SetScript("OnUpdate", function(self, elapsed)
    reclassifyElapsed = reclassifyElapsed + elapsed
    if reclassifyElapsed < RECLASSIFY_INTERVAL then return end
    reclassifyElapsed = 0

    for unit in pairs(activeUnits) do
        pcall(UpdatePlateForUnit, unit)
    end

    -- Healer mode (v2.1): piggybacked on this same throttle rather than a
    -- new ticker frame - the TTL expiry check only needs to run a couple
    -- times a second, not every frame, and this cadence already exists.
    pcall(SweepHealAlertExpirations)
end)

-- ---------------------------------------------------------------------
-- Debug scan - dumps what's actually active right now, same "confirm
-- before trusting" discipline as COA_DevDump's probe commands.
-- ---------------------------------------------------------------------

local function ScanNow()
    local found = {}
    for unit in pairs(activeUnits) do
        local ok = pcall(function()
            -- plateName lets us cross-reference pooled-frame reuse
            -- directly: if the same plateName shows up first under a
            -- suppressed friendly player and later under an unrelated
            -- (possibly enemy) unit, that's concrete evidence of the
            -- pooled-frame-reuse theory rather than an assumption.
            --
            -- BUGFIX (Battlewrath's live scan data, 2026-07-07: plateName
            -- was missing from every single entry, friend and enemy alike):
            -- this was calling GetName() on the outer plate object returned
            -- by GetNamePlateForUnit(unit), which is an ANONYMOUS frame -
            -- GetName() always succeeded but always returned nil, so
            -- plateName silently never got set. The actual named, pooled
            -- object is one level in - confirmed by /coagp probe, which
            -- shows plate.UnitFrame is the container named e.g.
            -- "NamePlateDriverFramePoolFrameNamePlateUnitFrameTemplate21"
            -- (same container GetNameRegion() already resolves for the
            -- alpha-preserve suppression logic). Fixed by reading the name
            -- off that container instead of the outer plate.
            local plateName
            local okPlate, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
            if okPlate and plate then
                local _, container = GetNameRegion(plate)
                local target = container or plate
                local okName, name = pcall(target.GetName, target)
                if okName then plateName = name end
            end
            table.insert(found, {
                unit = unit,
                name = UnitName(unit),
                isPlayer = UnitIsPlayer(unit) and true or false,
                isFriend = UnitIsFriend("player", unit) and true or false,
                suppressed = suppressed[unit] and true or false,
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

-- ---------------------------------------------------------------------
-- Frame-structure probe - only needed if the name still disappears
-- despite SetPlateBarsHidden's guess. Walks the first suppressed friendly
-- player's plate (falling back to any tracked friendly player if none are
-- currently suppressed) and records every child/region it finds, so we
-- can read off the real field names instead of guessing further.
-- ---------------------------------------------------------------------

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
    end
    return entry
end

local function ProbeNow()
    local targetUnit
    for unit in pairs(suppressed) do
        targetUnit = unit
        break
    end
    if not targetUnit then
        for unit in pairs(activeUnits) do
            if IsFriendlyPlayer(unit) then
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

    local nameRegion, container = GetNameRegion(plate)

    local dump = {
        capturedAt = date("%Y-%m-%d %H:%M:%S"),
        unit = targetUnit,
        name = UnitName(targetUnit),
        foundNameRegion = nameRegion ~= nil,
        plateChildren = {},
        plateRegions = {},
        containerChildren = {},
        containerRegions = {},
    }

    local plateChildren = { pcall(plate.GetChildren, plate) }
    if plateChildren[1] then
        for i = 2, #plateChildren do
            if plateChildren[i] then
                table.insert(dump.plateChildren, DescribeRegion(plateChildren[i]))
            end
        end
    end

    local plateRegions = { pcall(plate.GetRegions, plate) }
    if plateRegions[1] then
        for i = 2, #plateRegions do
            if plateRegions[i] then
                table.insert(dump.plateRegions, DescribeRegion(plateRegions[i]))
            end
        end
    end

    if container then
        local containerChildren = { pcall(container.GetChildren, container) }
        if containerChildren[1] then
            for i = 2, #containerChildren do
                if containerChildren[i] then
                    table.insert(dump.containerChildren, DescribeRegion(containerChildren[i]))
                end
            end
        end

        local containerRegions = { pcall(container.GetRegions, container) }
        if containerRegions[1] then
            for i = 2, #containerRegions do
                if containerRegions[i] then
                    table.insert(dump.containerRegions, DescribeRegion(containerRegions[i]))
                end
            end
        end
    end

    COA_GuardianPlatesDB.lastProbe = dump
    Print(string.format(
        "Probed %s - foundNameRegion=%s, plate has %d child(ren)/%d region(s). /reload to flush to disk.",
        tostring(dump.name), tostring(dump.foundNameRegion), #dump.plateChildren, #dump.plateRegions))
end

-- ---------------------------------------------------------------------
-- Interface Options panel (ESC -> Interface -> AddOns -> COA Guardian
-- Plates). Deliberately just the on/off switch, per Battlewrath: scan and
-- probe are debugging aids, not something a regular user needs to reach
-- through a GUI, so they stay slash-only. Uses Blizzard's own stock
-- InterfaceOptions templates - a long-standing, stable part of this
-- client (unlike the nameplate API, nothing here is a surprising backport)
-- - so no custom art or XML file, just a checkbox wired to the same
-- SetEnabled() the slash command uses.
-- ---------------------------------------------------------------------

local optionsPanel = CreateFrame("Frame", "COA_GuardianPlatesOptionsPanel", UIParent)
optionsPanel.name = "COA Guardian Plates"

local optionsTitle = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
optionsTitle:SetPoint("TOPLEFT", 16, -16)
optionsTitle:SetText("COA Guardian Plates")

local optionsSubtitle = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
optionsSubtitle:SetPoint("TOPLEFT", optionsTitle, "BOTTOMLEFT", 0, -8)
optionsSubtitle:SetWidth(500)
optionsSubtitle:SetJustifyH("LEFT")
optionsSubtitle:SetText("Suppresses friendly PLAYER nameplates while leaving friendly guardian/pet/NPC nameplates visible.")

local optionsCheckbox = CreateFrame("CheckButton", "COA_GuardianPlatesEnabledCheckbox", optionsPanel, "InterfaceOptionsCheckButtonTemplate")
optionsCheckbox:SetPoint("TOPLEFT", optionsSubtitle, "BOTTOMLEFT", 0, -16)
local okLabel, checkboxLabel = pcall(function() return _G[optionsCheckbox:GetName() .. "Text"] end)
if okLabel and checkboxLabel then
    checkboxLabel:SetText("Enable suppression")
end
optionsCheckbox:SetChecked(COA_GuardianPlatesDB.enabled and true or false)
optionsCheckbox:SetScript("OnClick", function(self)
    SetEnabled(self:GetChecked() and true or false)
end)

-- Healer mode (v2.1) - a sub-option of suppression, not an independent
-- capability (Battlewrath: "Maybe this is a healer option to the
-- suppression?"), so it's placed directly under the main enable checkbox
-- rather than in its own section. Only ever does anything while the
-- checkbox above is also checked - see the v2.1 HEALER MODE doc block and
-- UpdateHealAlertForUnit's own COA_GuardianPlatesDB.enabled guard.
-- Threshold/TTL stay slash-only tunables (`/coagp healermode threshold|
-- ttl`) rather than GUI sliders, matching this addon's existing split
-- between GUI (everyday on/off) and slash-only (tuning/debugging aids).
local healerModeCheckbox = CreateFrame("CheckButton", "COA_GuardianPlatesHealerModeCheckbox", optionsPanel, "InterfaceOptionsCheckButtonTemplate")
healerModeCheckbox:SetPoint("TOPLEFT", optionsCheckbox, "BOTTOMLEFT", 0, -4)
local okHealerLabel, healerModeCheckboxLabel = pcall(function() return _G[healerModeCheckbox:GetName() .. "Text"] end)
if okHealerLabel and healerModeCheckboxLabel then
    healerModeCheckboxLabel:SetText("Healer mode: reveal group/raid members on low HP")
end
healerModeCheckbox:SetChecked(COA_GuardianPlatesDB.healerModeEnabled and true or false)
healerModeCheckbox:SetScript("OnClick", function(self)
    COA_GuardianPlatesDB.healerModeEnabled = self:GetChecked() and true or false
end)

-- Guardian/pet/NPC color override - optional cosmetic recolor. Tints BOTH
-- the health bar and the floating name text (Battlewrath: "Is it cheap to
-- tint the name too?" - yes, since the name FontString is already
-- resolved via GetNameRegion() for the alpha-preserve suppression logic,
-- so this just rides that same lookup). Only ever applied to a live plate
-- while the addon is armed (COA_GuardianPlatesDB.enabled) - see the ARMED
-- GATE note near the top of this file and DisarmGuardianColors() above:
-- changing a swatch here while disarmed still saves the preference, it
-- just won't touch any live plate until re-armed. Split into two
-- independent rows (NPC vs Pet/Guardian/Totem, per Battlewrath's call on
-- the two-way UnitPlayerControlled split above) using a shared factory so
-- the picker logic isn't duplicated. Uses Blizzard's own stock
-- ColorPickerFrame (a long-standing, stable widget since way before this
-- client's era) rather than building a custom picker - left-click opens
-- the picker, right-click resets both the bar and name text to their
-- native colors, captured in originalColors/originalNameColors.
local function ApplyGuardianColorToAllActive()
    for unit in pairs(activeUnits) do
        pcall(UpdatePlateForUnit, unit)
    end
end

local function CreateGuardianColorRow(anchorWidget, labelText, colorKey)
    local rowLabel = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    rowLabel:SetPoint("TOPLEFT", anchorWidget, "BOTTOMLEFT", 0, -20)
    rowLabel:SetText(labelText .. " (right-click swatch to reset):")

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
        local c = COA_GuardianPlatesDB[colorKey]
        if c then
            fill:SetVertexColor(c.r, c.g, c.b)
        else
            fill:SetVertexColor(1, 1, 1) -- neutral placeholder = native color in use
        end
    end

    local function SetColor(r, g, b)
        COA_GuardianPlatesDB[colorKey] = { r = r, g = g, b = b }
        Refresh()
        ApplyGuardianColorToAllActive()
    end

    local function ClearColor()
        COA_GuardianPlatesDB[colorKey] = nil
        Refresh()
        ApplyGuardianColorToAllActive()
    end

    swatch:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "RightButton" then
            ClearColor()
            return
        end

        if not ColorPickerFrame then
            Print("Color picker not found on this client.")
            return
        end

        local current = COA_GuardianPlatesDB[colorKey] or { r = 0.2, g = 0.5, b = 1.0 }

        ColorPickerFrame.func = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            SetColor(r, g, b)
        end
        ColorPickerFrame.cancelFunc = function(previousValues)
            if previousValues then
                SetColor(previousValues.r, previousValues.g, previousValues.b)
            else
                ClearColor()
            end
        end
        ColorPickerFrame.hasOpacity = false

        -- BUGFIX (live-observed, Battlewrath: "color picks report not being
        -- available"): SetColor() isn't a valid method on this client's
        -- ColorPickerFrame - confirmed via Bartender4's own (live, working)
        -- AceGUIWidget-ColorPicker.lua, which uses SetColorRGB() instead.
        -- The .func/.cancelFunc/.hasOpacity + ShowUIPanel pattern above is
        -- otherwise correct legacy API for this client (no version-detect
        -- branching needed - this build is purely the older API, no
        -- SetupColorPickerAndShow present anywhere in the client).
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

local npcColorSwatch, RefreshNPCColorSwatch = CreateGuardianColorRow(healerModeCheckbox, "NPC nameplate color", "npcColor")
local petColorSwatch, RefreshPetColorSwatch = CreateGuardianColorRow(npcColorSwatch, "Pet / Guardian / Totem nameplate color", "petColor")

-- Threat coloring (v2.0) - independent capability, its own tri-state
-- dropdown rather than a checkbox since it's Off/Smart/Always, not just
-- on/off. See the THREAT COLORING doc block near the top of this file.
local THREAT_MODE_LABELS = { [0] = "Off", [1] = "Smart (auto-detect spec)", [2] = "Always On" }

local threatModeLabel = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
threatModeLabel:SetPoint("TOPLEFT", petColorSwatch, "BOTTOMLEFT", -4, -24)
threatModeLabel:SetText("Threat coloring (enemy nameplate health bars):")

local threatModeDropdown = CreateFrame("Frame", "COA_GuardianPlatesThreatModeDropdown", optionsPanel, "UIDropDownMenuTemplate")
threatModeDropdown:SetPoint("TOPLEFT", threatModeLabel, "BOTTOMLEFT", -16, -4)
UIDropDownMenu_SetWidth(threatModeDropdown, 160)

local function RefreshThreatModeDropdown()
    UIDropDownMenu_SetText(threatModeDropdown, THREAT_MODE_LABELS[COA_GuardianPlatesDB.threatMode or 0])
end

UIDropDownMenu_Initialize(threatModeDropdown, function(self, level)
    for mode = 0, 2 do
        local info = UIDropDownMenu_CreateInfo()
        info.text = THREAT_MODE_LABELS[mode]
        info.value = mode
        info.checked = (COA_GuardianPlatesDB.threatMode or 0) == mode
        info.func = function()
            SetThreatMode(mode)
            RefreshThreatModeDropdown()
        end
        UIDropDownMenu_AddButton(info)
    end
end)

optionsPanel.refresh = function()
    optionsCheckbox:SetChecked(COA_GuardianPlatesDB.enabled and true or false)
    healerModeCheckbox:SetChecked(COA_GuardianPlatesDB.healerModeEnabled and true or false)
    RefreshNPCColorSwatch()
    RefreshPetColorSwatch()
    RefreshThreatModeDropdown()
end
RefreshNPCColorSwatch()
RefreshPetColorSwatch()
RefreshThreatModeDropdown()

if InterfaceOptions_AddCategory then
    pcall(InterfaceOptions_AddCategory, optionsPanel)
end

-- ---------------------------------------------------------------------
-- Slash command
-- ---------------------------------------------------------------------

SLASH_COAGUARDIANPLATES1 = "/coagp"
SlashCmdList["COAGUARDIANPLATES"] = function(msg)
    local cmd = (msg or ""):trim():lower()

    if cmd == "on" then
        SetEnabled(true)
        Print("Enabled - friendly player nameplates will be suppressed.")
    elseif cmd == "off" then
        SetEnabled(false)
        Print("Disabled - all nameplates restored.")
    elseif cmd == "toggle" then
        SetEnabled(not COA_GuardianPlatesDB.enabled)
        Print(COA_GuardianPlatesDB.enabled and "Enabled." or "Disabled.")
    elseif cmd == "status" then
        local activeCount, suppressedCount, healAlertedCount = 0, 0, 0
        for _ in pairs(activeUnits) do activeCount = activeCount + 1 end
        for _ in pairs(suppressed) do suppressedCount = suppressedCount + 1 end
        for _ in pairs(healAlerted) do healAlertedCount = healAlertedCount + 1 end
        Print(string.format(
            "enabled=%s, active plate(s)=%d, currently suppressed=%d, threatMode=%s, healerMode=%s (threshold=%d%%, ttl=%ss, currently revealed=%d)",
            tostring(COA_GuardianPlatesDB.enabled), activeCount, suppressedCount,
            THREAT_MODE_LABELS[COA_GuardianPlatesDB.threatMode or 0],
            tostring(COA_GuardianPlatesDB.healerModeEnabled), COA_GuardianPlatesDB.healerModeThreshold or 80,
            tostring(COA_GuardianPlatesDB.healerModeTTL or 4), healAlertedCount))
    elseif cmd == "threat off" or cmd == "threat smart" or cmd == "threat always" then
        local arg = cmd:match("^threat%s+(%S+)$")
        local newMode = (arg == "off" and 0) or (arg == "smart" and 1) or (arg == "always" and 2) or 0
        SetThreatMode(newMode)
        if threatModeDropdown then
            pcall(RefreshThreatModeDropdown)
        end
        Print("Threat coloring: " .. THREAT_MODE_LABELS[COA_GuardianPlatesDB.threatMode or 0])
    elseif cmd == "healermode on" or cmd == "healermode off" then
        local arg = cmd:match("^healermode%s+(%S+)$")
        COA_GuardianPlatesDB.healerModeEnabled = (arg == "on")
        if healerModeCheckbox then
            healerModeCheckbox:SetChecked(COA_GuardianPlatesDB.healerModeEnabled)
        end
        Print("Healer mode: " .. (COA_GuardianPlatesDB.healerModeEnabled and "On" or "Off"))
    elseif cmd:match("^healermode threshold%s+%d+$") then
        local n = tonumber(cmd:match("^healermode threshold%s+(%d+)$"))
        if n and n >= 1 and n <= 100 then
            COA_GuardianPlatesDB.healerModeThreshold = n
            Print("Healer mode threshold: " .. n .. "%")
        end
    elseif cmd:match("^healermode ttl%s+[%d%.]+$") then
        local n = tonumber(cmd:match("^healermode ttl%s+([%d%.]+)$"))
        if n and n > 0 then
            COA_GuardianPlatesDB.healerModeTTL = n
            Print("Healer mode TTL: " .. n .. "s")
        end
    elseif cmd == "scan" then
        ScanNow()
    elseif cmd == "probe" then
        ProbeNow()
    elseif cmd == "diag" then
        local log = COA_GuardianPlatesDB.removedLog or {}
        local viaCacheCount = 0
        for _, entry in ipairs(log) do
            if entry.resolvedViaCache then viaCacheCount = viaCacheCount + 1 end
        end
        Print(string.format(
            "removedLog has %d entr%s (%d needed the cached-plate fallback). /reload then check COA_GuardianPlatesDB.removedLog for details.",
            #log, (#log == 1) and "y" or "ies", viaCacheCount))
    elseif cmd == "options" or cmd == "config" then
        if InterfaceOptionsFrame_OpenToCategory then
            pcall(InterfaceOptionsFrame_OpenToCategory, optionsPanel)
            -- called twice - a long-standing Blizzard quirk where the first
            -- call can open to the wrong category on a fresh Interface
            -- Options load; harmless to call again if already open.
            pcall(InterfaceOptionsFrame_OpenToCategory, optionsPanel)
        else
            Print("Interface Options panel API not found on this client - open ESC > Interface > AddOns manually.")
        end
    else
        Print("Usage: /coagp on | off | toggle | status | threat off|smart|always | healermode on|off|threshold <n>|ttl <secs> | scan | probe | diag | options")
    end
end
