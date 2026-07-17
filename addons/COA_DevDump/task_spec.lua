-- task_spec.lua - the spec-slot capture (addons/backlog.md #1), PURE READS ONLY.
--
-- Source finding that reframed the mission (SpecializationUtil.lua, patch-B
-- extraction, 2026-07-17): spec NAMES are PLAYER-AUTHORED labels in a
-- per-character custom WTF file (SetSpecializationName -> SpecializationSaved;
-- default "Specialization N") - NOT class facts. The mechanical key is the
-- INDEX; the per-slot game facts are the swap spell and unlock state.
--
-- DELIBERATELY NOT CALLED: SpecializationUtil.GetSpecializationInfo - it runs
-- ConvertOldSavedSpec (migrates AND CLEARS legacy AscensionUI_CDB.CA2 fields =
-- a real state mutation) and auto-creates default db entries. Names, if ever
-- wanted, decode OFFLINE from WTF/SpecializationSaved.wtf instead.
--
-- Everything below is a pure getter (verified against the extraction source):
-- counts, unlock flags (IsSpellKnown-derived), swap spell ids, active ids from
-- both systems (SpecializationUtil + C_CharacterAdvancement).

local ADDON, D = ...

local function try(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c = pcall(fn, ...)
    if ok then return a, b, c end
    return nil
end

D.RegisterTask{
    name = "spec",
    mode = "oneshot",
    help = "spec - spec-slot capture, pure reads (counts, unlocks, swap spells, active ids; names are player labels, skipped)",
    run = function(args)
        local SU = SpecializationUtil
        local CA = C_CharacterAdvancement
        if not SU and not CA then
            D.Print("Neither SpecializationUtil nor C_CharacterAdvancement present - wrong client?")
            return
        end

        local payload = D.Begin("spec", args)
        payload.util = {}
        payload.ca = {}

        if SU then
            payload.util.numSpecs = try(SU.GetNumSpecializations)
            payload.util.numUnlocked = try(SU.GetNumSpecializationsUnlocked)
            payload.util.activeSpec = try(SU.GetActiveSpecialization)
            payload.util.slots = {}
            local n = payload.util.numSpecs or 0
            for i = 1, n do
                payload.util.slots[i] = {
                    unlocked = try(SU.IsSpecializationUnlocked, i),
                    swapSpell = try(SU.GetSpecializationSpell, i),
                }
            end
        end

        if CA then
            payload.ca.activeSpecID = try(CA.GetActiveSpecID)
            payload.ca.canSwitch = try(CA.CanSwitchActiveChrSpec)
            local chr = try(CA.GetActiveChrSpec)
            if type(chr) == "table" then
                -- shallow scalar copy + key inventory; no interpretation
                local scalars, keys = {}, {}
                for k, v in pairs(chr) do
                    keys[#keys + 1] = tostring(k)
                    local t = type(v)
                    if t == "string" or t == "number" or t == "boolean" then
                        scalars[tostring(k)] = v
                    end
                end
                table.sort(keys)
                payload.ca.activeChrSpec = { keys = keys, scalars = scalars }
            else
                payload.ca.activeChrSpec = chr
            end
        end

        D.Commit(("spec: %s slots (%s unlocked), active util=%s ca=%s")
            :format(tostring(payload.util.numSpecs), tostring(payload.util.numUnlocked),
                    tostring(payload.util.activeSpec), tostring(payload.ca.activeSpecID)))
    end,
}
