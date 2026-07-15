-- task_plates.lua - record every ACTIVE nameplate via the client's own
-- enumerator (C_NamePlateManager.EnumerateActiveNamePlates), cursor-free.
--
-- Why not `frames`? The native plates are WorldFrame children and the
-- smooth-stacking mode stretches WorldFrame 8x (C_NamePlateManager.lua:216),
-- so cursor-rect hit-testing in UIParent coordinates misses them; what the
-- cursor finds is the rendered visual layer without the token. The manager's
-- iterator IS the authority: each plate carries `_unit` (set at
-- NAME_PLATE_UNIT_ADDED, C_NamePlateManager.lua:88).
--
-- Per plate: unit token + name/health/max/GUID/reaction/classification -
-- everything the guardian-tracking question needs, recorded not printed.

local ADDON, D = ...

D.RegisterTask{
    name = "plates",
    mode = "oneshot",
    help = "plates - record every active nameplate: token, name, hp/max, GUID, reaction, classification",
    run = function(args)
        if not (C_NamePlateManager and C_NamePlateManager.EnumerateActiveNamePlates) then
            D.Print("C_NamePlateManager.EnumerateActiveNamePlates not available - wrong client?")
            return
        end

        local payload = D.Begin("plates", args)
        payload.plates = {}

        for np in C_NamePlateManager.EnumerateActiveNamePlates() do
            pcall(function()
                local u = np._unit or (np.GetAttribute and np:GetAttribute("unit"))
                local entry = { unit = u }
                if u then
                    pcall(function() entry.name = UnitName(u) end)
                    pcall(function() entry.health = UnitHealth(u) end)
                    pcall(function() entry.healthMax = UnitHealthMax(u) end)
                    pcall(function() entry.guid = UnitGUID(u) end)
                    pcall(function() entry.reaction = UnitReaction("player", u) end)
                    pcall(function() entry.creatureType = UnitCreatureType(u) end)
                    pcall(function() entry.isPlayer = UnitIsPlayer(u) or nil end)
                    pcall(function()
                        entry.playerControlled = UnitPlayerControlled(u) or nil
                    end)
                    pcall(function()
                        -- who owns this summon, if the API can say
                        if UnitIsUnit(u, "pet") then entry.isMyPet = true end
                    end)
                end
                payload.plates[#payload.plates + 1] = entry
            end)
        end

        D.Commit(("plates: %d active nameplate(s) recorded"):format(#payload.plates))
    end,
}
