-- feed_live.lua - the REAL feed (pass 3). Everything here stands on the
-- petlog record's verified facts (addons/planning/pet_parser_scope.md):
--
-- ★★★ FACT: [SILENT] CLEU on 3.3.5 is the classic VARARGS tuple - 1 ts, 2 sub, 3-5 src, 6-8 dst
--   (CombatLogGetCurrentEventInfo is furniture on this fork). Verified in
--   addons/planning/pet_parser_scope.md. This is what makes select(8) = dstFlags correct.
--   * CLEU is the classic 3.3.5 varargs tuple (the canonical API is furniture):
--     1 ts, 2 sub, 3 srcGUID, 4 srcName, 5 srcFlags, 6 dstGUID, 7 dstName,
--     8 dstFlags, 9+ suffix. SWING crit=15, SPELL amount=12/crit=18,
--     SWING_MISSED missType=9, SPELL_MISSED missType=12.
--   * Necro minions carry TYPE_PET 0x1000 (not GUARDIAN) + MINE 0x1.
--   * UNIT_DIED is SILENT for OVERWRITE-despawn (proven; 0 of 71 in the record,
--     which contained overwrites but NO enemy-kills - death-by-enemy untested,
--     sample bias). Liveness therefore comes from the buff-instance witness +
--     TTLs; UNIT_DIED stays a bonus path either way.
--   * Minion buffs are ONE INSTANCE PER INDIVIDUAL (3 ghouls = 3 auras) -
--     the per-type instance count is the liveness AUTHORITY for Raise types;
--     CLEU attributes which GUID. Animates have no buff: TTL-governed.
--   * Adoption after /reload: any MINE+PET-flagged source not in the registry
--     registers by its CLEU srcName (the name types it; no entry decode).
--
-- NORMALS DISCIPLINE: rates lead (crit/miss per attempt, self-normalizing);
-- damage is fight-scoped display + raw lifetime totals only, never a
-- normalized family claim. ALL individuals fold into SV normals on close
-- (Raise deaths AND Animate expiries) - the lifetime tier. Cadence is
-- relaxed by design: the averages settle over time; perfect tracking gains
-- little.

local ADDON, NS = ...

local band = bit.band
local AFF_MINE, TYPE_PET, TYPE_GUARDIAN = 0x1, 0x1000, 0x2000

-- the derived tables (Input talents + Battlewrath's class knowledge)
local RAISE_LF = {
    ["Ghoul"] = 1, ["Lesser Skeletal Warrior"] = 1, ["Greater Skeletal Warrior"] = 1,
    ["Banshee"] = 2, ["Skeletal Mage"] = 2,
    ["Abomination"] = 3, ["Decaying Colossus"] = 3, ["Gargoyle"] = 3,
}
local ANIMATE_TTL = {
    ["Zombie"] = 15, ["Greater Zombie"] = 15, ["Skeletal Archer"] = 15,
    ["Tomb King"] = 15, ["Bone Wraith"] = 15, ["Plaguefather"] = 15,
    ["Bone Construct"] = 20, ["Frost Wyrm"] = 30,
}
-- record-verified minion buffs (instance-per-individual). Banshee / Skeletal
-- Mage / Gargoyle buff ids are a NAMED GAP (never summoned in the record) -
-- those types fall back to activity+plate liveness until captured.
local BUFF_TYPE = {
    [805019] = "Ghoul", [805017] = "Abomination", [805022] = "Decaying Colossus",
    [805016] = "Lesser Skeletal Warrior", [807927] = "Greater Skeletal Warrior",
}
local TYPE_HAS_BUFF = {}
for _, t in pairs(BUFF_TYPE) do TYPE_HAS_BUFF[t] = true end

local STALE_AFTER = 3      -- s without a plate read -> HP greys
local ORPHAN_AFTER = 60    -- s without ANY signal -> buffless raise types close
local SAMPLE_FLOOR = 20    -- attempts before a rate shows (else "-")

-- ---------------------------------------------------------------- state
local reg = {}        -- guid -> rec
local regCount = 0
local playerGuid
local inCombat = false
local mismatchNote = 0

local function newAcc()
    return { hits = 0, crits = 0, misses = 0, dodges = 0, parries = 0,
             dmg = 0, taken = 0 }
end

local function newRec(guid, name)
    local now = GetTime()
    local rec = {
        guid = guid, name = name,
        summonedAt = now, lastSeen = now,
        fight = newAcc(), life = newAcc(),
        row = {},  -- the reused display table (kind/name/... written in place)
    }
    if RAISE_LF[name] then
        rec.lane, rec.lf = "raise", RAISE_LF[name]
    elseif ANIMATE_TTL[name] then
        rec.lane = "animate"
        rec.ttlMax = ANIMATE_TTL[name]
        rec.expiresAt = now + rec.ttlMax
    else
        -- unknown minion name: treat as raise-lane floor weight, honest
        rec.lane, rec.lf = "raise", 1
    end
    reg[guid] = rec
    regCount = regCount + 1
    return rec
end

-- fold on close: EVERY individual (both lanes) feeds the lifetime normals
local function close(rec)
    local n = NS.db.normals[rec.name]
    if not n then
        n = { n = 0, hits = 0, crits = 0, misses = 0, dodges = 0, parries = 0,
              dmg = 0, taken = 0, activeSeconds = 0 }
        NS.db.normals[rec.name] = n
    end
    n.n = n.n + 1
    local L = rec.life
    n.hits, n.crits = n.hits + L.hits, n.crits + L.crits
    n.misses, n.dodges, n.parries = n.misses + L.misses, n.dodges + L.dodges, n.parries + L.parries
    n.dmg, n.taken = n.dmg + L.dmg, n.taken + L.taken
    n.activeSeconds = n.activeSeconds + (GetTime() - rec.summonedAt)
    reg[rec.guid] = nil
    regCount = regCount - 1
end

-- ---------------------------------------------------------------- CLEU
local function bump(rec, field, amount)
    rec.fight[field] = rec.fight[field] + (amount or 1)
    rec.life[field] = rec.life[field] + (amount or 1)
    rec.lastSeen = GetTime()
end

local function missField(missType)
    if missType == "DODGE" then return "dodges" end
    if missType == "PARRY" then return "parries" end
    return "misses"
end

local function onCleu(...)
    local sub = select(2, ...)
    local srcGUID, srcName, srcFlags = select(3, ...), select(4, ...), select(5, ...)
    local dstGUID, dstName = select(6, ...), select(7, ...)

    if sub == "SPELL_SUMMON" then
        if srcGUID == playerGuid and type(dstGUID) == "string" and not reg[dstGUID] then
            newRec(dstGUID, dstName or "?")
        end
        return
    end

    local src = reg[srcGUID]
    -- adoption: a MINE pet/guardian source we never saw summoned (/reload case)
    if not src and type(srcFlags) == "number"
        and band(srcFlags, AFF_MINE) ~= 0
        and band(srcFlags, TYPE_PET + TYPE_GUARDIAN) ~= 0 then
        src = newRec(srcGUID, srcName or "?")
    end
    local dst = reg[dstGUID]
    if not src and not dst then return end

    if sub == "UNIT_DIED" then
        -- the bonus fast-path (silent for pets in the record, but honor it)
        if dst then close(dst) end
        return
    end

    if sub == "SWING_DAMAGE" then
        local amount, crit = select(9, ...), select(15, ...)
        if src then
            bump(src, crit and "crits" or "hits")
            bump(src, "dmg", tonumber(amount) or 0)
        end
        if dst then bump(dst, "taken", tonumber(amount) or 0) end
    elseif sub == "SWING_MISSED" then
        if src then bump(src, missField(select(9, ...))) end
    elseif sub == "SPELL_DAMAGE" or sub == "SPELL_PERIODIC_DAMAGE" then
        local amount, crit = select(12, ...), select(18, ...)
        if src then
            bump(src, crit and "crits" or "hits")
            bump(src, "dmg", tonumber(amount) or 0)
        end
        if dst then bump(dst, "taken", tonumber(amount) or 0) end
    elseif sub == "SPELL_MISSED" then
        if src then bump(src, missField(select(12, ...))) end
    elseif src then
        src.lastSeen = GetTime()  -- any other pet-sourced event = alive signal
    end
end

-- ---------------------------------------------------------------- liveness
-- the buff-instance witness: count auras per known minion type
local buffCounts = {}
local function sweepBuffs()
    for t in pairs(buffCounts) do buffCounts[t] = 0 end
    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, _, spellId = UnitAura("player", i)
        if not name then break end
        local t = BUFF_TYPE[spellId]
        if t then buffCounts[t] = (buffCounts[t] or 0) + 1 end
    end
end

local plateSeen = {}
local function scanPlates()
    for g in pairs(plateSeen) do plateSeen[g] = nil end
    for i = 1, 40 do
        local u = "nameplate" .. i
        local g = UnitGUID(u)
        if g and reg[g] then
            local rec = reg[g]
            local hp, hpMax = UnitHealth(u), UnitHealthMax(u)
            if hp and hpMax and hpMax > 0 then
                rec.hpFrac, rec.hpAt = hp / hpMax, GetTime()
            end
            rec.lastSeen = GetTime()
            plateSeen[g] = true
        end
    end
end

-- per-type reconcile: buff count is the AUTHORITY; close the excess picked by
-- least-recent signal, never a plate-visible one first
local pickBuf = {}
local function reconcile()
    local now = GetTime()
    -- live raise counts per type
    local have = {}
    for _, rec in pairs(reg) do
        if rec.lane == "raise" and TYPE_HAS_BUFF[rec.name] then
            have[rec.name] = (have[rec.name] or 0) + 1
        end
    end
    for t, n in pairs(have) do
        local want = buffCounts[t] or 0
        if n > want then
            -- collect this type's recs, oldest-signal first, plate-visible last
            local k = 0
            for _, rec in pairs(reg) do
                if rec.lane == "raise" and rec.name == t then
                    k = k + 1; pickBuf[k] = rec
                end
            end
            table.sort(pickBuf, function(a, b)
                local pa, pb = plateSeen[a.guid] and 1 or 0, plateSeen[b.guid] and 1 or 0
                if pa ~= pb then return pa < pb end
                return a.lastSeen < b.lastSeen
            end)
            for i = 1, n - want do close(pickBuf[i]) end
            for i = 1, k do pickBuf[i] = nil end
        elseif want > n then
            mismatchNote = mismatchNote + 1  -- summon we missed; CLEU adoption will catch it on its first act
        end
    end
    -- animate expiry + buffless-raise orphan sweep
    for _, rec in pairs(reg) do
        if rec.lane == "animate" and now >= rec.expiresAt then
            close(rec)
        elseif rec.lane == "raise" and not TYPE_HAS_BUFF[rec.name]
            and (now - rec.lastSeen) > ORPHAN_AFTER and not plateSeen[rec.guid] then
            close(rec)
        end
    end
end

-- ---------------------------------------------------------------- rows
local function fmtPct(num, den)
    if den < SAMPLE_FLOOR then return "-" end
    return math.floor(num / den * 100 + 0.5) .. "%"
end

local function fmtDmg(v)
    if v >= 10000 then return string.format("%.0fk", v / 1000) end
    if v >= 1000 then return string.format("%.1fk", v / 1000) end
    return tostring(math.floor(v))
end

local function rates(acc)
    local landed = acc.hits + acc.crits
    local attempts = landed + acc.misses + acc.dodges + acc.parries
    return fmtPct(acc.crits, landed), fmtPct(acc.misses + acc.dodges + acc.parries, attempts)
end

local raiseRows, familyRows = {}, {}
local famAgg = {}
local lastSig = ""

local function buildRows()
    local now = GetTime()
    for i = #raiseRows, 1, -1 do raiseRows[i] = nil end
    for i = #familyRows, 1, -1 do familyRows[i] = nil end

    for _, rec in pairs(reg) do
        if rec.lane == "raise" then
            local row = rec.row
            row.kind, row.name, row.lf = "raise", rec.name, rec.lf
            row.hpFrac = rec.hpFrac
            row.state = (rec.hpAt and (now - rec.hpAt) <= STALE_AFTER) and "live" or "stale"
            row.dmg = fmtDmg(rec.fight.dmg)
            row.crit, row.miss = rates(rec.fight)
            raiseRows[#raiseRows + 1] = row
        else
            local f = famAgg[rec.name]
            if not f then
                f = { kind = "family", name = rec.name, acc = newAcc() }
                famAgg[rec.name] = f
            end
            if not f.touched then
                f.count, f.nextExpiry = 0, math.huge
                f.acc = newAcc()
                f.touched = true
            end
            f.count = f.count + 1
            if rec.expiresAt < f.nextExpiry then f.nextExpiry = rec.expiresAt end
            local A, R = f.acc, rec.fight
            A.hits, A.crits = A.hits + R.hits, A.crits + R.crits
            A.misses, A.dodges, A.parries = A.misses + R.misses, A.dodges + R.dodges, A.parries + R.parries
        end
    end

    -- LF-desc, name tiebreak: investment order, stable rows
    table.sort(raiseRows, function(a, b)
        if a.lf ~= b.lf then return a.lf > b.lf end
        return a.name < b.name
    end)

    for name, f in pairs(famAgg) do
        if f.touched then
            f.touched = nil
            f.ttl = math.max(0, f.nextExpiry - now)
            f.ttlMax = ANIMATE_TTL[name] or 15
            f.crit, f.miss = rates(f.acc)
            familyRows[#familyRows + 1] = f
        end
    end
    table.sort(familyRows, function(a, b) return a.name < b.name end)

    -- set signature: layout only when membership/order changes
    local sig = ""
    for _, row in ipairs(raiseRows) do sig = sig .. row.name .. "|" end
    sig = sig .. "//"
    for _, f in ipairs(familyRows) do sig = sig .. f.name .. "|" end
    if sig ~= lastSig then
        lastSig = sig
        NS.layout(raiseRows, familyRows)
    end
end

-- ---------------------------------------------------------------- the feed
local ev = CreateFrame("Frame")
ev:Hide()
ev:SetScript("OnEvent", function(_, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local ok = pcall(onCleu, ...)
        if not ok then NS.cleuErrors = (NS.cleuErrors or 0) + 1 end
    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
        for _, rec in pairs(reg) do rec.fight = newAcc() end
    elseif event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
    end
end)

local scanFlip = false

NS.feeds.live = {
    start = function()
        playerGuid = UnitGUID("player")
        ev:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        ev:RegisterEvent("PLAYER_REGEN_ENABLED")
        ev:RegisterEvent("PLAYER_REGEN_DISABLED")
        lastSig = ""
    end,
    stop = function()
        ev:UnregisterAllEvents()
        for guid, rec in pairs(reg) do close(rec) end
        NS.layout({}, {})
        NS.root:Hide()
    end,
    update = function(dt)
        sweepBuffs()
        scanFlip = not scanFlip
        if scanFlip then scanPlates() end  -- plates at 1s, the relaxed cadence
        reconcile()
        buildRows()
        NS.writeRows()
        -- empty grid hides when locked; stays visible unlocked so it can be placed
        if #raiseRows == 0 and #familyRows == 0 and NS.db.locked then
            NS.root:Hide()
        else
            NS.root:Show()
        end
    end,
    slash = function(cmd)
        if cmd == "stats" then
            local out = DEFAULT_CHAT_FRAME
            out:AddMessage("|cff88ff88PetGrid|r lifetime normals (rates lead; dmg raw, context-soaked):")
            local any = false
            for name, n in pairs(NS.db.normals) do
                any = true
                local crit, miss = rates(n)
                out:AddMessage(string.format(
                    "  %s: n=%d crit=%s miss=%s active=%ds dmg=%s taken=%s",
                    name, n.n, crit, miss, math.floor(n.activeSeconds),
                    fmtDmg(n.dmg), fmtDmg(n.taken)))
            end
            if not any then out:AddMessage("  (nothing folded yet)") end
            if mismatchNote > 0 then
                out:AddMessage("  witness mismatches this session: " .. mismatchNote)
            end
            return true
        elseif cmd == "resetstats" then
            NS.db.normals = {}
            DEFAULT_CHAT_FRAME:AddMessage("|cff88ff88PetGrid|r lifetime normals reset.")
            return true
        end
        return false
    end,
}
