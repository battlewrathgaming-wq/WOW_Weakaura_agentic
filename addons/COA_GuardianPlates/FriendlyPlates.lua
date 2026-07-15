-- COA_GuardianPlates - FriendlyPlates.lua
--
-- FRIENDLY vs THREAT (v3.0.1, 2026-07-08) - Battlewrath, refining the v3.0
-- module split further: "If the supression has to live in Guardian, then
-- I'd say don't split NPC / Healer from it. Instead move it from being
-- 'guardian' to 'Friendly plates'. And then the NPC/Friendlyplayer/Guardian
-- all live in there. Then threat plates is working against enemy plates.
-- Both are signal/behaviour only, and never author content."
--
-- Renamed from GuardianPlates.lua accordingly. The reasoning: suppression's
-- per-frame alpha-fight (see the CONFIRMED LIVE note near ReapplySuppressed
-- below - Ascension's own native driver re-asserts alpha every rendered
-- frame, so our own suppression has to keep winning that race at the same
-- cadence) has to live somewhere with its own OnUpdate loop. The NPC/pet
-- color override and healer-mode reveal are both small, friendly-side
-- behaviors with no growth trajectory of their own (unlike threat coloring,
-- which genuinely grew into its own subsystem before the v3.0 split) - so
-- rather than fragment them into their own lanes purely for symmetry with
-- Guardian/Threat, they stay bundled here under the honest umbrella of
-- "everything this addon does to FRIENDLY plates," paired against
-- EnemyPlates.lua ("everything this addon does to HOSTILE/enemy plates").
-- ns.Guardian was renamed to ns.Friendly throughout to match (and
-- ThreatPlates.lua/ns.Threat was later renamed to EnemyPlates.lua/ns.Enemy
-- in the same spirit, as part of the v3.1 "State Plates" brand pivot).
--
-- Both this file and EnemyPlates.lua are signal/behaviour layers only -
-- neither one ever authors plate content. The actual plates are drawn by
-- the client's native (backported) nameplate driver, the same one
-- TurboPlates itself sits on (see Core.lua's top doc comment) - this file
-- only ever reads that content's classification and asks Core's executor
-- primitives to suppress, tint, or reveal what's already there.
--
-- Owns: suppressing friendly PLAYER nameplates while leaving friendly
-- guardian/pet/NPC nameplates untouched, the optional NPC/pet color
-- override, the healer-mode partial reveal, `/coagp`, and the main "COA
-- State Plates" options panel. It never touches a plate's visual state
-- directly - every actual draw happens through Core's executor primitives
-- (ns.SetSuppressed, ns.SetPartialReveal, ns.SetHealthBarColor,
-- ns.SetNameColor, and their Clear* counterparts).
--
-- REWRITTEN (pre-v2.0) after a real live crash proved the original premise
-- wrong. This addon originally assumed stock WotLK 3.3.5 nameplates with NO
-- unit token (the standard assumption for this client version - pre-Legion
-- nameplates normally have no GetNamePlateForUnit/C_NamePlate API at all),
-- so it tried to reconstruct player-vs-guardian identity itself by watching
-- COMBAT_LOG_EVENT_UNFILTERED flags and matching by display NAME - a known,
-- if fragile, technique for that era. That crashed live ("bad argument #1
-- to 'band' (number expected, got string)") because this server's CLEU
-- argument layout didn't match the stock assumption either.
--
-- Root cause of BOTH problems: the premise itself was wrong for this
-- specific server. Battlewrath installed TurboPlates (an Ascension-
-- approved nameplate replacement addon) and its own source shows
-- Ascension's client actually BACKPORTS the modern (post-Legion) nameplate
-- API: C_NamePlate.GetNamePlateForUnit(unit), and the NAME_PLATE_UNIT_ADDED/
-- NAME_PLATE_UNIT_REMOVED events, all with a REAL unit token per plate -
-- the exact thing that supposedly didn't exist in this era. There was
-- never a need to guess at unit identity at all. Core.lua now wraps that
-- native driver and hands this file (and EnemyPlates.lua) the same
-- unit/plate stream symmetrically.
--
-- Confirmed distinct from the game's own separate friendly/enemy nameplate
-- toggles: there is no stock "nameplateShowFriendlyPlayers" CVar anywhere,
-- which is the actual gap this addon exists to fill. Suppression here only
-- ever fires for a unit that is BOTH a player AND friendly, so an enemy
-- player's nameplate (e.g. in a battleground) is never touched.
--
-- Usage:
--   /coagp on|off|toggle  -> persistent (SavedVariables) enable switch.
--   /coagp status         -> prints current state + active plate count.
--   /coagp healermode on|off|threshold <n>|ttl <secs> -> see HEALER MODE
--                            doc block below.
--   /coagp scan           -> one-shot dump of every currently active
--                            nameplate to COA_GuardianPlatesDB.lastScan.
--                            /reload after running to flush to disk.
--   /coagp probe          -> one-shot frame-structure dump of the first
--                            suppressed friendly-player plate found, to
--                            COA_GuardianPlatesDB.lastProbe.
--   /coagp options|config -> opens ESC > Interface > AddOns > COA Guardian
--                            Plates directly.
--   /coagp diag           -> prints how many REMOVED-restore events have
--                            been logged and how many needed the cached-
--                            plate fallback (SANITATION FIX v2 below).
--
-- Config is per-character (## SavedVariablesPerCharacter in the TOC), so
-- each of Battlewrath's characters keeps its own enabled/disabled state -
-- useful since a character mained as a healer may want full friendly
-- health bars visible rather than suppressed.
--
-- Optional guardian/pet/NPC color override (not a must, per Battlewrath -
-- the native default blue read as too bold/high-contrast): two independent
-- color swatches in the options panel (NPC, and Pet/Guardian/Totem), split
-- via UnitPlayerControlled. Each swatch opens Blizzard's stock
-- ColorPickerFrame; right-clicking restores the native color.
--
-- NAME TEXT TINT (Battlewrath: "Is it cheap to tint the name too?"): yes -
-- cheap, since the floating name FontString is already resolved for the
-- alpha-preserve suppression logic, so tinting it just adds one more
-- SetTextColor call alongside the existing SetStatusBarColor call, no new
-- per-frame cost.
--
-- ARMED GATE (Battlewrath, re: turning the addon off: "This goes to trust.
-- We shouldn't hijack the user's UI. We only apply anything when we're
-- armed."): color tinting only ever applies while COA_GuardianPlatesDB.
-- enabled is true. DisarmNPCColors() (called from SetEnabled(false))
-- reverts every live-tinted plate back to native the instant the switch
-- flips off. The saved color preference itself is untouched while disarmed
-- - only the live plates are - so re-enabling reapplies the same saved
-- color automatically.
--
-- SANITATION FIX / SANITATION FIX v2 (live-observed bug, Battlewrath:
-- "enemy NPCs losing their level indicators"): nameplate frames on this
-- client are pooled and reused across unrelated units. If a suppressed/
-- recolored plate's actual visual state isn't restored before our own
-- tracking is wiped, that pooled frame can get silently handed to a
-- completely different unit while still carrying our modified state. Now
-- handled centrally by Core.lua's event dispatch (OnUnitRemoved is called,
-- and this file restores via Core's Clear* primitives, BEFORE Core wipes
-- its own shared tables) - see Core.lua's diagnostic log
-- (COA_GuardianPlatesDB.removedLog, `/coagp diag`) which CONFIRMED
-- (2026-07-07, 20/20 events) that the cached-plate fallback is the norm on
-- this client, not an edge case - the direct GetNamePlateForUnit(unit)
-- lookup never once resolved at REMOVED time.
--
-- HEALER MODE (v2.1, 2026-07-08) - a sub-option of suppression itself, NOT
-- an independent capability. Battlewrath's framing, verbatim: "Maybe this
-- is a healer option to the suppression?" - correct, and simpler than how
-- this was first sketched (as a fourth independent toggle): the whole
-- premise only means anything while a plate would otherwise BE suppressed,
-- so it lives entirely inside the existing enabled-suppression codepath.
--
-- What it does: for a friendly PLAYER who is also in your party or raid
-- (IsGroupOrRaidFriendlyPlayer), suppression behaves exactly as normal
-- (name-only) until that unit's health drops below
-- COA_GuardianPlatesDB.healerModeThreshold (default 80%) - at that point
-- the plate's health bar becomes visible alongside the name (Core's
-- SetPartialReveal). Level text, portrait, cast bar, and everything else
-- stays hidden. Live-test feedback, Battlewrath: "The only thing I would
-- omit from the healer display is the target's level element. It's just
-- the health bar we want." Every friendly player NOT in your group/raid is
-- untouched by this.
--
-- An earlier revision also drew a custom %HP FontString on top of the
-- revealed bar. Removed per Battlewrath's live-test call: "Bar only. Then
-- let upstream handle how it is presented." - the reveal shows only the
-- real native health bar.
--
-- ANTI-FLICKER TTL (Battlewrath, verbatim: "Hang open with a TTL... then
-- collapse back down... It's intent is to filter who needs attention vs
-- does not. Without becoming a flicker show."): healAlertExpire[unit] is
-- pushed forward every time health is recomputed and is STILL below
-- threshold, to GetTime() + healerModeTTL (default 4s). The moment health
-- recovers above threshold, this stops refreshing - but the existing
-- timestamp is left alone rather than cleared, so the reveal keeps holding
-- until that TTL genuinely runs out. Only SweepHealAlertExpirations (run
-- via Core's OnThrottledTick, piggybacked on the 0.5s reclassify cadence)
-- clears the alert and lets suppression resume, once BOTH health is back
-- at/above threshold AND the TTL has genuinely passed.
--
-- COST: health changes are event-driven (UNIT_HEALTH/UNIT_MAXHEALTH via
-- Core's OnHealthEvent dispatch), not polled, so there's no per-frame race
-- to win here the way alpha suppression has.

local addonName, ns = ...

-- ---------------------------------------------------------------------
-- DB defaults / migration
-- ---------------------------------------------------------------------

COA_GuardianPlatesDB = COA_GuardianPlatesDB or {}
if COA_GuardianPlatesDB.enabled == nil then
    COA_GuardianPlatesDB.enabled = true
end

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

local Print = ns.Print

-- ---------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------

-- units we've actively suppressed, so we can restore them on removal or if
-- their classification ever changes (e.g. a mind-control edge case).
local suppressed = {}

-- unit token -> true while this group/raid member's plate is currently
-- revealed (partial reveal) due to dropping below healerModeThreshold.
local healAlerted = {}

-- unit token -> GetTime() this unit's reveal is allowed to collapse at. See
-- the ANTI-FLICKER TTL doc note above.
local healAlertExpire = {}

-- ---------------------------------------------------------------------
-- NPC/pet/guardian color override
-- ---------------------------------------------------------------------

-- DEBOUNCE (v3.5.11, 2026-07-09) - mirrors EnemyPlates.lua's
-- ApplyThreatColorForUnit/StatesMatch pattern (see its own doc note).
-- ApplyNPCColorForUnit used to call Core's SetHealthBarColor/SetNameColor
-- (or their Clear* counterparts) unconditionally every single 0.5s
-- reclassify tick, for every friendly NPC/pet/guardian currently classified
-- - even though the configured override color never changes tick to tick.
-- Harmless functionally (same color reapplied is a no-op visually), but
-- confirmed newly RELEVANT once v3.5.7 added logging to those same executor
-- calls: with a color configured and /coasp log on, every one of those
-- redundant reapplies logs its own "applied"/"restored" line, burying the
-- handful of lines that actually matter under a flood of repeats - exactly
-- the kind of noise Battlewrath hit trying to isolate the render test's own
-- output. Same shape as Enemy's lastAppliedState/StatesMatch: cache the
-- color actually applied per unit (or `false` for "explicitly cleared/no
-- override"), skip Core entirely when nothing has actually changed.
local lastAppliedNPCColor = {} -- [unit] = { r=, g=, b= } (applied) or false (cleared/no override)

local function NPCColorStatesMatch(unit, override)
    local prev = lastAppliedNPCColor[unit]
    if override then
        return prev and prev ~= false and prev.r == override.r and prev.g == override.g and prev.b == override.b
    end
    return prev == false
end

local function ApplyNPCColorForUnit(unit, plate)
    local override
    if ns.IsFriendlyPetOrGuardian(unit) then
        override = COA_GuardianPlatesDB.petColor
    elseif ns.IsFriendlyNPC(unit) then
        override = COA_GuardianPlatesDB.npcColor
    end

    if NPCColorStatesMatch(unit, override) then
        return -- nothing has actually changed since the last apply - skip Core entirely
    end
    lastAppliedNPCColor[unit] = override and { r = override.r, g = override.g, b = override.b } or false

    if override then
        ns.SetHealthBarColor(unit, plate, override)
        ns.SetNameColor(unit, plate, override)
    else
        if ns.HasHealthBarColorOverride(unit) then
            ns.ClearHealthBarColor(unit, plate)
        end
        if ns.HasNameColorOverride(unit) then
            ns.ClearNameColor(unit, plate)
        end
    end
end

-- ---------------------------------------------------------------------
-- Suppression + healer-mode + NPC-color dispatch - all of what used to be
-- the single UpdatePlateForUnit. Called on ADD and on every reclassify
-- tick (see ns.Friendly.OnUnitAdded/OnReclassify below).
-- ---------------------------------------------------------------------

local function UpdatePlateForUnit(unit, plate)
    if not plate then return end

    -- Healer mode (v2.1): a group/raid member currently below the HP
    -- threshold still counts as "suppressed" here (shouldSuppress stays
    -- true) - what changes is HOW: Core's SetPartialReveal shows just the
    -- health bar instead of the full name-only suppression.
    local shouldSuppress = COA_GuardianPlatesDB.enabled and ns.IsFriendlyPlayer(unit)

    if shouldSuppress then
        if healAlerted[unit] then
            pcall(ns.SetPartialReveal, plate)
        else
            local okSelective, didSelective = pcall(ns.SetSuppressed, plate, true)
            if not (okSelective and didSelective) then
                plate:SetAlpha(0) -- fallback: hides the name too, better than nothing
            end
        end
        suppressed[unit] = true
    elseif suppressed[unit] then
        pcall(ns.SetSuppressed, plate, false)
        plate:SetAlpha(1)
        suppressed[unit] = nil
    end

    -- ARMED GATE: color tinting only fires while COA_GuardianPlatesDB.enabled
    -- is true - see the doc note above.
    if COA_GuardianPlatesDB.enabled and ns.IsFriendlyNonPlayer(unit) then
        pcall(ApplyNPCColorForUnit, unit, plate)
    end
end

-- Recomputes heal-alert state for a single group/raid friendly-player unit
-- and re-derives suppression from it. Only ever ARMS the alert - clearing
-- it is SweepHealAlertExpirations()'s job alone, so the TTL's anti-flicker
-- behavior is never accidentally short-circuited by this function running
-- again while still above threshold.
local function UpdateHealAlertForUnit(unit)
    if not COA_GuardianPlatesDB.healerModeEnabled then return end
    if not COA_GuardianPlatesDB.enabled then return end -- sub-option of suppression
    if not ns.IsGroupOrRaidFriendlyPlayer(unit) then return end

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
    if ok and plate then
        UpdatePlateForUnit(unit, plate) -- re-derives suppression from healAlerted
    end
end

-- Throttled sweep (via ns.Friendly.OnThrottledTick, piggybacked on Core's
-- 0.5s reclassifier - no new per-frame cost) that's the ONLY thing allowed
-- to clear a heal alert.
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

            local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
            if ok and plate then
                UpdatePlateForUnit(unit, plate) -- re-suppresses now that healAlerted is clear
            end
        end
    end
end

-- Reverts every currently-tinted guardian/pet/NPC plate back to its
-- captured native color - called the instant the addon is disarmed
-- (SetEnabled(false)). Also wipes the v3.5.11 debounce cache - a disarm
-- forces the visual back to native regardless of what the cache thinks was
-- last applied, so the cache must be reset too or a later re-enable would
-- wrongly see "nothing changed" and skip reapplying the override.
local function DisarmNPCColors()
    for unit in pairs(ns.activeUnits) do
        if ns.HasHealthBarColorOverride(unit) or ns.HasNameColorOverride(unit) then
            local plate = ns.ResolvePlateForRemoval(unit)
            ns.ClearHealthBarColor(unit, plate)
            ns.ClearNameColor(unit, plate)
        end
    end
    wipe(lastAppliedNPCColor)
end

-- Shared enable/disable path - used by both the slash command and the
-- Interface Options checkbox.
local function SetEnabled(enabled)
    COA_GuardianPlatesDB.enabled = enabled and true or false
    if not COA_GuardianPlatesDB.enabled then
        for unit in pairs(suppressed) do
            local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
            if ok and plate then
                pcall(ns.SetSuppressed, plate, false)
                plate:SetAlpha(1)
            end
        end
        wipe(suppressed)
        pcall(DisarmNPCColors)
    end
end

-- Shared setter for healer mode - actively collapses back to baseline on
-- disable rather than waiting for a TTL or a despawn to do it eventually
-- (Battlewrath: "Turning something off shouldn't lead to more work because
-- it was on. Instead letting the base line behaviour take over.").
local function SetHealerModeEnabled(enabled)
    COA_GuardianPlatesDB.healerModeEnabled = enabled and true or false
    if not COA_GuardianPlatesDB.healerModeEnabled then
        wipe(healAlerted)
        wipe(healAlertExpire)
        for unit in pairs(ns.activeUnits) do
            local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
            if ok and plate then
                UpdatePlateForUnit(unit, plate)
            end
        end
    end
end

-- ---------------------------------------------------------------------
-- Core dispatch contract implementation (see Core.lua's DISPATCH CONTRACT
-- doc note)
-- ---------------------------------------------------------------------

function ns.Friendly.OnUnitAdded(unit, plate)
    UpdatePlateForUnit(unit, plate)
    -- Healer mode: catch a unit that's already below threshold the moment
    -- their plate first appears (e.g. joining a fight in progress), rather
    -- than waiting for the next health event.
    pcall(UpdateHealAlertForUnit, unit)
end

function ns.Friendly.OnReclassify(unit, plate)
    UpdatePlateForUnit(unit, plate)
end

function ns.Friendly.OnThrottledTick()
    pcall(SweepHealAlertExpirations)
end

function ns.Friendly.OnHealthEvent(unit)
    if COA_GuardianPlatesDB.healerModeEnabled then
        pcall(UpdateHealAlertForUnit, unit)
    end
end

function ns.Friendly.IsSuppressed(unit)
    return suppressed[unit] and true or false
end

-- Restores this unit's suppression/color state (called by Core BEFORE it
-- wipes its own shared tables) - returns true if anything was actually
-- restored, for Core's diagnostic log.
function ns.Friendly.OnUnitRemoved(unit, plate)
    local restoredSuppress = false
    local restoredColor = false

    if plate then
        if suppressed[unit] then
            pcall(ns.SetSuppressed, plate, false)
            pcall(plate.SetAlpha, plate, 1)
            restoredSuppress = true
        end
    end

    if ns.HasHealthBarColorOverride(unit) then
        ns.ClearHealthBarColor(unit, plate)
        restoredColor = true
    end
    if ns.HasNameColorOverride(unit) then
        ns.ClearNameColor(unit, plate)
        restoredColor = true
    end

    suppressed[unit] = nil
    healAlerted[unit] = nil
    healAlertExpire[unit] = nil
    lastAppliedNPCColor[unit] = nil -- v3.5.11 - unit ids get recycled onto pooled plates, same reasoning as Enemy's ClearAppliedState

    return restoredSuppress or restoredColor
end

-- ---------------------------------------------------------------------
-- Per-frame reapply (CONFIRMED LIVE, Battlewrath): running the reapply
-- every single frame, rather than a throttle, fixed the flicker -
-- Ascension's own baked-in nameplate driver recalculates alpha every
-- rendered frame, so anything less than full per-frame cadence loses that
-- race most of the time. Only walks `suppressed` - the friendly players
-- we've already decided to fight for - not every active plate, since
-- guardians/pets/NPCs never need touching once classified (that
-- reclassification happens on Core's slower 0.5s tick instead). This is
-- the concrete reason suppression can't be split into its own lane apart
-- from the rest of this file's friendly-side behaviors - see the v3.0.1
-- doc note at the top of this file.
-- ---------------------------------------------------------------------

local function ReapplySuppressed()
    for unit in pairs(suppressed) do
        local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
        if ok and plate then
            if healAlerted[unit] then
                pcall(ns.SetPartialReveal, plate)
            else
                local okSelective, didSelective = pcall(ns.SetSuppressed, plate, true)
                if not (okSelective and didSelective) then
                    plate:SetAlpha(0)
                end
            end
        end
    end
end

local scanner = CreateFrame("Frame")
scanner:SetScript("OnUpdate", function(self, elapsed)
    ReapplySuppressed()
end)

-- ---------------------------------------------------------------------
-- Interface Options panel (ESC -> Interface -> AddOns -> COA State
-- Plates). BRAND PIVOT (v3.1): the addon's outward brand became "COA State
-- Plates" (was "COA Guardian Plates" - cosmetic only, per Battlewrath: "The
-- brand, I think, should be 'State plates'." AddOns folder name,
-- COA_GuardianPlatesDB SavedVariables key, and .toc filename all stay put).
-- This panel still hosts Friendly's own controls directly on the brand's
-- root category page, with EnemyPlates.lua's "Enemy Plates" nested as its
-- own sub-category beneath it - see EnemyPlates.lua for that half of the
-- pivot (ns.Threat -> ns.Enemy, threat coloring reframed as Enemy's first
-- sub-mode).
-- ---------------------------------------------------------------------

local optionsPanel = CreateFrame("Frame", "COA_GuardianPlatesOptionsPanel", UIParent)
optionsPanel.name = "COA State Plates"
ns.optionsPanel = optionsPanel -- exposed so EnemyPlates.lua can nest its own sub-panel under this one

local optionsTitle = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
optionsTitle:SetPoint("TOPLEFT", 16, -16)
optionsTitle:SetText("COA State Plates - Friendly Plates")

local optionsSubtitle = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
optionsSubtitle:SetPoint("TOPLEFT", optionsTitle, "BOTTOMLEFT", 0, -8)
optionsSubtitle:SetWidth(500)
optionsSubtitle:SetJustifyH("LEFT")
optionsSubtitle:SetText("Suppresses friendly PLAYER nameplates while leaving friendly guardian/pet/NPC nameplates visible. Healer mode below is its sub-mode.")

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

local healerModeCheckbox = CreateFrame("CheckButton", "COA_GuardianPlatesHealerModeCheckbox", optionsPanel, "InterfaceOptionsCheckButtonTemplate")
healerModeCheckbox:SetPoint("TOPLEFT", optionsCheckbox, "BOTTOMLEFT", 0, -4)
local okHealerLabel, healerModeCheckboxLabel = pcall(function() return _G[healerModeCheckbox:GetName() .. "Text"] end)
if okHealerLabel and healerModeCheckboxLabel then
    healerModeCheckboxLabel:SetText("Healer mode: reveal group/raid members on low HP")
end
healerModeCheckbox:SetChecked(COA_GuardianPlatesDB.healerModeEnabled and true or false)
healerModeCheckbox:SetScript("OnClick", function(self)
    SetHealerModeEnabled(self:GetChecked() and true or false)
end)

local function ApplyNPCColorToAllActive()
    for unit in pairs(ns.activeUnits) do
        local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
        if ok and plate then
            UpdatePlateForUnit(unit, plate)
        end
    end
end

local function CreateColorRow(anchorWidget, labelText, colorKey)
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
        ApplyNPCColorToAllActive()
    end

    local function ClearColor()
        COA_GuardianPlatesDB[colorKey] = nil
        Refresh()
        ApplyNPCColorToAllActive()
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

local npcColorSwatch, RefreshNPCColorSwatch = CreateColorRow(healerModeCheckbox, "NPC nameplate color", "npcColor")
local petColorSwatch, RefreshPetColorSwatch = CreateColorRow(npcColorSwatch, "Pet / Guardian / Totem nameplate color", "petColor")

optionsPanel.refresh = function()
    optionsCheckbox:SetChecked(COA_GuardianPlatesDB.enabled and true or false)
    healerModeCheckbox:SetChecked(COA_GuardianPlatesDB.healerModeEnabled and true or false)
    RefreshNPCColorSwatch()
    RefreshPetColorSwatch()
end
RefreshNPCColorSwatch()
RefreshPetColorSwatch()

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
        for _ in pairs(ns.activeUnits) do activeCount = activeCount + 1 end
        for _ in pairs(suppressed) do suppressedCount = suppressedCount + 1 end
        for _ in pairs(healAlerted) do healAlertedCount = healAlertedCount + 1 end
        Print(string.format(
            "enabled=%s, active plate(s)=%d, currently suppressed=%d, healerMode=%s (threshold=%d%%, ttl=%ss, currently revealed=%d)",
            tostring(COA_GuardianPlatesDB.enabled), activeCount, suppressedCount,
            tostring(COA_GuardianPlatesDB.healerModeEnabled), COA_GuardianPlatesDB.healerModeThreshold or 80,
            tostring(COA_GuardianPlatesDB.healerModeTTL or 4), healAlertedCount))
    elseif cmd == "healermode on" or cmd == "healermode off" then
        local arg = cmd:match("^healermode%s+(%S+)$")
        SetHealerModeEnabled(arg == "on")
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
        ns.ScanNow()
    elseif cmd == "probe" then
        ns.ProbeNow()
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
        Print("Usage: /coagp on | off | toggle | status | healermode on|off|threshold <n>|ttl <secs> | scan | probe | diag | options  (see /coaep for Enemy Plates / threat coloring)")
    end
end
