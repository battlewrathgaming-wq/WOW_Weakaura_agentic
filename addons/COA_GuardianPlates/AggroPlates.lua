-- AggroPlates.lua (ns.Aggro) - the NATIVE threat-steering module (v3.6.0).
--
-- THE DISTINCT SURFACE for a tank / anyone interested in aggro. This module
-- draws NOTHING itself: it steers the client's own (dormant) threat visuals
-- by writing per-plate optionTable overrides through Core's steering
-- primitives. The native driver then renders and RE-ASSERTS everything on
-- its own events - the exact machinery that used to beat our repaints now
-- works for us. Source basis (patch-B extraction, CompactUnitFrame.lua):
--
--   UpdateHealthBorder (:804) - a complete native tank-threat border system,
--     active when optionTable.tankThreatBorderColor AND
--     tankNoThreatBorderColor are set AND the player is grouped. Colors are
--     read via :GetRGBA() (Color-like objects required). Role decides
--     meaning natively (IsPlayerEffectivelyTank): for a TANK, "tanking" is
--     the good state; for a DPS the same slot means "you pulled aggro" -
--     so this module keeps two palettes and applies by current role.
--   UpdateAggroHighlight (:770) - gated on optionTable.displayAggroHighlight;
--     flipping it false makes the NATIVE code hide its own red highlight
--     (the suppression the v3.5.42 Show()-race hook could never win).
--
-- Nothing here needs restoring on unit-remove: the driver re-runs SetUpFrame
-- on every plate (re)assignment, which resets optionTable to the shared
-- default - native recycling IS the cleanup. We re-apply on OnUnitAdded
-- (which runs AFTER the driver's handler: Ascension_NamePlates registers
-- first by load order, so our wrapper always lands on top).

local addonName, ns = ...

local Aggro = ns.Aggro

-- ---------------------------------------------------------------------
-- Config (per-character, under the addon's existing SavedVariables)
-- ---------------------------------------------------------------------

local function GetConfig()
    COA_GuardianPlatesDB.aggro = COA_GuardianPlatesDB.aggro or {
        enabled = false,
        borders = true,        -- steer the native tank-threat border system
        hideNativeHighlight = false, -- suppress the native red aggro highlight
    }
    return COA_GuardianPlatesDB.aggro
end

-- Minimal Color-like object: the native border reader calls :GetRGBA().
local function Color(r, g, b, a)
    return {
        r = r, g = g, b = b, a = a or 1,
        GetRGBA = function(self) return self.r, self.g, self.b, self.a end,
        GetRGB = function(self) return self.r, self.g, self.b end,
    }
end

-- Two palettes for the same native slots - the slots' MEANING flips with
-- role (see the header note). Values are the taste layer; tune freely.
local PALETTES = {
    TANK = { -- tanking = secure (calm); not tanking = losing aggro (alarm)
        threat         = Color(0.15, 0.85, 0.25),  -- I hold it, not my target
        threatTarget   = Color(0.30, 1.00, 0.40),  -- I hold it, my target
        noThreat       = Color(1.00, 0.15, 0.10),  -- on threat list, NOT holding
        noThreatTarget = Color(1.00, 0.35, 0.15),
    },
    DPS = { -- native only borders a DPS's plates when they ARE tanking = pulled
        threat         = Color(1.00, 0.15, 0.10),  -- you pulled it
        threatTarget   = Color(1.00, 0.35, 0.15),
        noThreat       = Color(1.00, 0.15, 0.10),  -- (unreached branch for DPS)
        noThreatTarget = Color(1.00, 0.35, 0.15),
    },
}

local function CurrentPalette()
    local role = (ns.GetPlayerRole and ns.GetPlayerRole()) or "NONE"
    return (role == "TANK") and PALETTES.TANK or PALETTES.DPS
end

-- ---------------------------------------------------------------------
-- Apply / clear (all writes go through Core's steering primitives)
-- ---------------------------------------------------------------------

local function Apply(unit, plate)
    -- v3.7.0 inert-core gate: nothing writes until the satellite attaches
    if not (COAStatePlates and COAStatePlates.Aggro and COAStatePlates.Aggro.attached) then return end
    local cfg = GetConfig()
    if not cfg.enabled then return end
    if not (ns.IsHostileUnit and ns.IsHostileUnit(unit)) then return end
    plate = plate or (ns.GetIndexedPlate and ns.GetIndexedPlate(unit))
    if not plate then return end

    if cfg.borders then
        local p = CurrentPalette()
        ns.SetPlateOption(unit, plate, "tankThreatBorderColor", p.threat)
        ns.SetPlateOption(unit, plate, "tankThreatTargetBorderColor", p.threatTarget)
        ns.SetPlateOption(unit, plate, "tankNoThreatBorderColor", p.noThreat)
        ns.SetPlateOption(unit, plate, "tankNoThreatTargetBorderColor", p.noThreatTarget)
        ns.RefreshPlateBorder(plate)
    end

    if cfg.hideNativeHighlight then
        ns.SetNativeAggro(unit, plate, false)
    end
end

local function ApplyAll()
    for unit in pairs(ns.activeUnits) do
        pcall(Apply, unit, nil)
    end
end

-- Steering leaves nothing to restore per-unit (native recycling resets the
-- optionTable), but a live DISABLE should un-steer plates that are still on
-- screen right now.
local function ClearAll()
    for unit in pairs(ns.activeUnits) do
        local plate = ns.GetIndexedPlate and ns.GetIndexedPlate(unit)
        if plate then
            ns.SetPlateOption(unit, plate, "tankThreatBorderColor", nil)
            ns.SetPlateOption(unit, plate, "tankThreatTargetBorderColor", nil)
            ns.SetPlateOption(unit, plate, "tankNoThreatBorderColor", nil)
            ns.SetPlateOption(unit, plate, "tankNoThreatTargetBorderColor", nil)
            ns.SetNativeAggro(unit, plate, nil) -- nil = fall back to the shared default
            ns.RefreshPlateBorder(plate)
        end
    end
end

-- ---------------------------------------------------------------------
-- Module contract (Core dispatches these, pcall-wrapped)
-- ---------------------------------------------------------------------

function Aggro.OnUnitAdded(unit, plate)
    Apply(unit, plate)
end

function Aggro.OnUnitRemoved(unit, plate)
    return false -- nothing applied that native recycling doesn't reset
end

-- Reclassify sweep: catches role changes (palette flip) and hostiles that
-- classified late; cheap - rawset on a table + native delta guards.
function Aggro.OnReclassify(unit, plate)
    Apply(unit, plate)
end

-- ---------------------------------------------------------------------
-- PUBLIC API (v3.6.1) - the curated cross-addon surface. Core owns ALL
-- machinery and runs baseline-OFF; satellite "I care about this" addons
-- (COA_StatePlates_Aggro's native options page) flip these switches.
-- Separate addons cannot see the private ns, so this global is the door.
-- ---------------------------------------------------------------------

COAStatePlates = COAStatePlates or {}
COAStatePlates.Aggro = {
    attached = false, -- the satellite sets this (v3.7.0 inert-core gate)
    GetConfig = function() return GetConfig() end,
    SetEnabled = function(on)
        local cfg = GetConfig()
        cfg.enabled = not not on
        if cfg.enabled then ApplyAll() else ClearAll() end
        return cfg.enabled
    end,
    SetHideNativeHighlight = function(hide)
        local cfg = GetConfig()
        cfg.hideNativeHighlight = not not hide
        if cfg.enabled then ApplyAll() end
        return cfg.hideNativeHighlight
    end,
    Reapply = function()
        if GetConfig().enabled then ApplyAll() end
    end,
}

-- ---------------------------------------------------------------------
-- Slash surface (Core routes `/coasp aggro ...` here; shorthand-first)
-- ---------------------------------------------------------------------

function Aggro.HandleCommand(rest)
    local cfg = GetConfig()
    local sub, arg = (rest or ""):match("^(%S*)%s*(.-)$")
    sub = (sub or ""):lower()

    if sub == "on" then
        cfg.enabled = true
        ApplyAll()
        ns.Print("Aggro steering ON (native borders" ..
            (cfg.hideNativeHighlight and " + native highlight hidden" or "") ..
            "). Borders show while GROUPED (native gate).")
    elseif sub == "off" then
        cfg.enabled = false
        ClearAll()
        ns.Print("Aggro steering OFF - native defaults restored.")
    elseif sub == "hl" then
        cfg.hideNativeHighlight = (arg:lower() == "off")
        -- 'hl off' = hide the native highlight; 'hl on' = leave it native
        if cfg.enabled then ApplyAll() end
        ns.Print("Native aggro highlight: " .. (cfg.hideNativeHighlight and "HIDDEN (steered)" or "native (untouched)"))
    elseif sub == "status" then
        local role = (ns.GetPlayerRole and ns.GetPlayerRole()) or "?"
        ns.Print(string.format("Aggro steering: %s | borders: %s | native highlight: %s | role/palette: %s",
            cfg.enabled and "ON" or "OFF",
            cfg.borders and "on" or "off",
            cfg.hideNativeHighlight and "hidden" or "native",
            role))
    else
        ns.Print("/coasp aggro on|off|status|hl on|off - steer the client's own threat borders/highlight (no drawing, no races; borders need a group).")
    end
end
