-- task_petlog.lua - the pet parser's capture gate (pass 1 of the build;
-- addons/planning/pet_parser_scope.md = the spec, the v0 checklist = why).
--
--   /coadump st petlog     start (then: summon the army, fight)
--   /coadump sp            stop -> one envelope; /reload lands it
--
-- PURE CAPTURE, no verdicts (the standing rule). One fight answers checklist
-- facts 1-4 offline:
--   1. CombatLogGetCurrentEventInfo in a live handler - every event row is
--      stamped with which read produced it ("canon" or "varargs"), and the
--      raw suffix args land untouched.
--   2. Pet-sourced CLEU with flag bits - rows kept when source OR dest is a
--      registry GUID, or sourceFlags carries PET|GUARDIAN (0x1000|0x3000
--      family) + MINE; flags land raw.
--   3. Plate-window stat snapshots - registered pets resolved via the proven
--      nameplate scan; UnitDamage/AttackPower/AttackSpeed/Armor/level PAIRED
--      with same-tick owner stats (the scaling-lab row shape).
--   4. Miss vocabulary - missType strings land raw in the suffix args.
-- Plus the validation witness feed: a player-aura sweep (name/stacks/spellId)
-- rides each snapshot tick so the minion-count buff identifies offline
-- (registry-count == buff-stacks, the continuous two-witness).
--
-- Bounds: 4000 event rows / 400 snapshot rows / ~10 min. Registry is CLEU
-- SPELL_SUMMON sourceGUID=player (the guardian-tracker primitive verbatim).

local ADDON, D = ...

local AFF_MINE, TYPE_PET, TYPE_GUARDIAN = 0x1, 0x1000, 0x2000

local frames, payload, registry

local function bandOk(flags, mask)
    if type(flags) ~= "number" then return false end
    return bit and bit.band and (bit.band(flags, mask) ~= 0)
end

local function petFlags(flags)
    return bandOk(flags, AFF_MINE) and bandOk(flags, TYPE_PET + TYPE_GUARDIAN)
end

local function readCleu(...)
    -- fact 1: prefer the backported canonical read; stamp which path answered
    if CombatLogGetCurrentEventInfo then
        local t = { CombatLogGetCurrentEventInfo() }
        if t[2] then return "canon", t end
    end
    return "varargs", { ... }
end

local function onCleu(...)
    local mode, a = readCleu(...)
    -- canonical layout: 1 ts, 2 subevent, 3 hideCaster?, then src/dst blocks.
    -- We DON'T assume positions beyond subevent: land the first 20 args raw,
    -- and do the keep-filter on a scan for registry GUIDs / pet flags.
    local subevent = a[2]
    local keep = false
    if subevent == "SPELL_SUMMON" or subevent == "UNIT_DIED" then keep = true end
    if not keep then
        for i = 3, 10 do
            local v = a[i]
            if type(v) == "string" and registry[v] then keep = true break end
            if type(v) == "number" and petFlags(v) then keep = true break end
        end
    end
    if not keep then return end

    -- registry maintenance: find src/dst GUID-ish strings positionally-tolerantly
    if subevent == "SPELL_SUMMON" then
        local myGuid = UnitGUID and UnitGUID("player")
        for i = 3, 8 do
            if a[i] == myGuid then
                for j = i + 1, i + 6 do
                    local v = a[j]
                    if type(v) == "string" and v ~= myGuid and v:find("^0x") then
                        registry[v] = { summoned = GetTime() }
                        payload.registry_events[#payload.registry_events + 1] =
                            { t = GetTime(), what = "summon", guid = v }
                        break
                    end
                end
                break
            end
        end
    elseif subevent == "UNIT_DIED" then
        for i = 3, 12 do
            local v = a[i]
            if type(v) == "string" and registry[v] then
                registry[v].died = GetTime()
                payload.registry_events[#payload.registry_events + 1] =
                    { t = GetTime(), what = "died", guid = v }
            end
        end
    end

    if #payload.events >= 4000 then return end
    local row = { mode = mode, t = GetTime() }
    for i = 1, 20 do row[i] = a[i] end
    payload.events[#payload.events + 1] = row
end

local function snapshotTick()
    if #payload.snapshots >= 400 then return end
    local snap = { t = GetTime(), pets = {}, auras = {} }
    -- owner side of the lab pair
    pcall(function()
        local base, pos, neg = UnitAttackPower("player")
        snap.ownerAP = { base, pos, neg }
    end)
    pcall(function() snap.ownerStamina = { UnitStat("player", 3) } end)
    pcall(function()
        if GetSpellBonusDamage then snap.ownerSP_shadow = GetSpellBonusDamage(6) end
    end)
    -- registered pets currently plate-bound (the proven resolver)
    for i = 1, 40 do
        local u = "nameplate" .. i
        local ok, g = pcall(UnitGUID, u)
        if ok and g and registry[g] then
            local p = { guid = g, unit = u }
            pcall(function() p.hp, p.hpMax = UnitHealth(u), UnitHealthMax(u) end)
            pcall(function() p.level = UnitLevel(u) end)
            pcall(function()
                local minD, maxD = UnitDamage(u)
                p.dmgMin, p.dmgMax = minD, maxD
            end)
            pcall(function()
                local base, pos, neg = UnitAttackPower(u)
                p.ap = { base, pos, neg }
            end)
            pcall(function() p.atkSpeed = { UnitAttackSpeed(u) } end)
            pcall(function() p.armor = { UnitArmor(u) } end)
            snap.pets[#snap.pets + 1] = p
        end
    end
    -- the buff-stack witness feed (identify the minion-count buff offline)
    for i = 1, 40 do
        local ok, name, _, _, count, _, _, _, _, _, _, spellId =
            pcall(UnitAura, "player", i)
        if not ok or not name then break end
        snap.auras[#snap.auras + 1] = { name, count, spellId }
    end
    if #snap.pets > 0 or #snap.auras > 0 then
        payload.snapshots[#payload.snapshots + 1] = snap
    end
end

D.RegisterTask{
    name = "petlog",
    mode = "session",
    help = "petlog - pet-parser capture gate: registry + raw CLEU + plate stat/owner pairs + aura-stack witness (summon, fight, sp)",
    start = function(args)
        payload = D.Begin("petlog", args)
        payload.canonApi = CombatLogGetCurrentEventInfo and true or false
        payload.events, payload.snapshots, payload.registry_events = {}, {}, {}
        registry = {}

        frames = {}
        local ev = CreateFrame("Frame")
        ev:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        ev:SetScript("OnEvent", function(_, _, ...)
            local ok = pcall(onCleu, ...)
            if not ok then payload.handler_errors = (payload.handler_errors or 0) + 1 end
        end)
        frames.ev = ev

        local tick = CreateFrame("Frame")
        local acc = 0
        tick:SetScript("OnUpdate", function(_, dt)
            acc = acc + dt
            if acc < 2.0 then return end
            acc = 0
            pcall(snapshotTick)
        end)
        frames.tick = tick
    end,
    stop = function()
        if frames then
            if frames.ev then frames.ev:UnregisterAllEvents() frames.ev:SetScript("OnEvent", nil) end
            if frames.tick then frames.tick:SetScript("OnUpdate", nil) end
        end
        local nReg = 0
        for _ in pairs(registry) do nReg = nReg + 1 end
        payload.registry_final = {}
        for g, r in pairs(registry) do
            payload.registry_final[g] = r
        end
        D.Commit(("petlog: %d events, %d snapshots, %d registered pets, canonApi=%s, errors=%s")
            :format(#payload.events, #payload.snapshots, nReg,
                    tostring(payload.canonApi), tostring(payload.handler_errors or 0)))
    end,
}
