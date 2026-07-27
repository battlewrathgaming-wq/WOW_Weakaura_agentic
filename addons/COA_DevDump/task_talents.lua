-- task_talents.lua - the selected-build capture (addons/backlog.md #5, the
-- Class_design cross-lane ask). PURE READS ONLY.
--
-- Getter path, not widget walk: the client's own CA UI reads the selected
-- build exactly this way (patch-B, Ascension_CharacterAdvancementSeason9/
-- CharacterAdvancement.lua:1062/:1144 + CASpellButton.lua):
--   C_CharacterAdvancement.GetKnownTalentEntries()  -> { entry, ... } (.ID at least)
--   C_CharacterAdvancement.GetKnownSpellEntries()   -> { entry, ... }
--   C_CharacterAdvancement.GetTalentRankByID(id)    -> rank, maxRank
-- All Get* C-side reads - no tab limit, no pooled-widget noise, and none of
-- the GetSpecializationInfo-style Lua mutation trap (nothing here touches a
-- saved table). ExportBuild() is captured as a BONUS third witness (the
-- client's own build string, comparable to the ascension.gg codec).
--
-- Payload shape mirrors the offline witness (Class_design/tools/
-- decode_build.py: talents = node-id + rank, abilities = spellId,
-- presence = selected) so the acceptance diff is a straight join. Entries
-- are captured as RAW shallow scalar copies + a key inventory (emission
-- over interpretation - we don't guess which field is "the" id).

local ADDON, D = ...

local function shallow(entry)
    local scalars, keys, arrays = {}, {}, {}
    for k, v in pairs(entry) do
        keys[#keys + 1] = tostring(k)
        local t = type(v)
        if t == "string" or t == "number" or t == "boolean" then
            scalars[tostring(k)] = v
        elseif t == "table" then
            -- v2: capture flat scalar ARRAYS too (e.g. Spells = the per-rank
            -- spellId list - the entry->spell bridge the rank join needs)
            local arr, ok = {}, true
            for i, av in ipairs(v) do
                local at = type(av)
                if at == "string" or at == "number" or at == "boolean" then
                    arr[i] = av
                else
                    ok = false
                    break
                end
            end
            if ok and #arr > 0 then arrays[tostring(k)] = arr end
        end
    end
    table.sort(keys)
    local out = { keys = keys, scalars = scalars }
    if next(arrays) then out.arrays = arrays end
    return out
end

D.RegisterTask{
    name = "talents",
    mode = "oneshot",
    help = "talents - capture the selected build via CA getters (pure reads; diff-ready vs the build-string decode)",
    run = function(args)
        local CA = C_CharacterAdvancement
        if not CA then
            D.Print("C_CharacterAdvancement not present - wrong client?")
            return
        end

        local payload = D.Begin("talents", args)
        payload.talents, payload.spells = {}, {}

        local okT, te = pcall(CA.GetKnownTalentEntries)
        if okT and type(te) == "table" then
            for _, entry in ipairs(te) do
                local row = shallow(entry)
                if entry.ID and CA.GetTalentRankByID then
                    local okR, rank, maxRank = pcall(CA.GetTalentRankByID, entry.ID)
                    if okR then
                        row.rank, row.maxRank = rank, maxRank
                    end
                end
                payload.talents[#payload.talents + 1] = row
            end
        else
            payload.talents_error = okT and "non-table return" or tostring(te)
        end

        local okS, se = pcall(CA.GetKnownSpellEntries)
        if okS and type(se) == "table" then
            for _, entry in ipairs(se) do
                local row = shallow(entry)
                -- v2: ranks for ability entries too (the UI calls this on any entry)
                if entry.ID and CA.GetTalentRankByID then
                    local okR, rank, maxRank = pcall(CA.GetTalentRankByID, entry.ID)
                    if okR then
                        row.rank, row.maxRank = rank, maxRank
                    end
                end
                payload.spells[#payload.spells + 1] = row
            end
        else
            payload.spells_error = okS and "non-table return" or tostring(se)
        end

        -- bonus third witness: the client's own build string (raw return, untouched)
        if CA.ExportBuild then
            local okE, a, b = pcall(CA.ExportBuild)
            if okE then payload.exportBuild = { a, b } end
        end

        -- context that joins to the other witnesses
        payload.classToken = select(3, pcall(UnitClass, "player"))
        if CA.GetActiveSpecID then
            local okA, id = pcall(CA.GetActiveSpecID)
            if okA then payload.activeSpecID = id end
        end

        D.Commit(("talents: %d talent entries, %d spell entries, export=%s")
            :format(#payload.talents, #payload.spells,
                    payload.exportBuild and "captured" or "n/a"))
    end,
}
