-- MancerLedger core.lua - v0.1.0: the CONSUMER plugin.
--
-- Mancer (LtGenZombie's addon) is the DRIVER: it parses fights and auto-commits
-- each pull on leaving combat into MancerDB.minionDps.fights - a 10-deep ring,
-- newest first, deduped by fingerprint (startedAt:endedAt:totalDamage). This
-- addon is the LONG-TERM COMPONENT it doesn't have: it folds unseen ring
-- entries into the ACTIVE PROFILE's accumulating log.
--
-- PROFILES are user-controlled (no epoch guessing): a profile = name + a
-- character-state capture at creation (level/stam/int/spirit/shadowSP/AP/crit)
-- + the log. Regear -> /mledger new <name> -> compare -> pick which is live.
--
-- Verified driver contract (LibellusLeti 0.9.434 source, refs_libellus):
--   fight = { startedAt, endedAt, minions = { [minionId] = bucket }, ... }
--   bucket = { damage, hits, activeSeconds, summonCount,
--              spells = { [key] = { label, spellId, damage, hits } } }
--   minionId = lowercase slug ("ghoul"); no crit/miss fields YET (his dev
--   line adds the miss vocabulary - the fold extends additively when it ships).
--
-- DISCIPLINE: read-only on MancerDB. Fold only KNOWN fields; unknown numeric
-- bucket fields are NOTED (drift visibility), never folded. Shape violations
-- skip the fight and say so ONCE, loudly. Damage is raw labeled totals, never
-- a normalized per-family claim.
--
--   /mledger new <name>     capture character state, create + activate
--   /mledger use <name>     switch the live profile (pending fights fold first)
--   /mledger list           profiles + captures
--   /mledger stats [name]   the accumulated log (active by default)
--   /mledger compare <a> <b>
--   /mledger resetlog <name>
--   /mledger delete <name> sure
--   /mledger harvest        manual fold now
--   /mledger status         driver version, ring, cursor, drift notes

local ADDON = ...

local SEEN_CAP = 60          -- folded-fingerprint FIFO (ring is only 10 deep)
local HARVEST_DELAY = 1.5    -- s after regen, so the driver commits first

local db                     -- MancerLedgerDB
local saidOnce = {}          -- session: one loud line per reason

local function say(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffb08ef0MancerLedger|r: " .. msg)
end

local function sayOnce(key, msg)
    if saidOnce[key] then return end
    saidOnce[key] = true
    say(msg)
end

-- ---------------------------------------------------------------- driver
local function driverDb()
    return _G.MancerDB and _G.MancerDB.minionDps or nil
end

local function driverVersion()
    if GetAddOnMetadata then
        for _, name in ipairs({ "LibellusLeti", "Mancer" }) do
            local ok, v = pcall(GetAddOnMetadata, name, "Version")
            if ok and v then return name .. " " .. v end
        end
    end
    return "unknown"
end

-- the driver's own fingerprint recipe, recomputed (it isn't stored per fight)
local function fingerprint(fight)
    local damage = 0
    for _, bucket in pairs(fight.minions or {}) do
        damage = damage + (tonumber(bucket.damage) or 0)
    end
    return string.format("%.3f:%.3f:%.0f",
        tonumber(fight.startedAt) or 0, tonumber(fight.endedAt) or 0, damage)
end

-- ---------------------------------------------------------------- profiles
local function captureState()
    local s = { at = date("%Y-%m-%d %H:%M") }
    pcall(function() s.level = UnitLevel("player") end)
    pcall(function() s.stam = (select(1, UnitStat("player", 3))) end)
    pcall(function() s.int = (select(1, UnitStat("player", 4))) end)
    pcall(function() s.spirit = (select(1, UnitStat("player", 5))) end)
    pcall(function()
        if GetSpellBonusDamage then s.shadowSP = GetSpellBonusDamage(6) end
    end)
    pcall(function()
        local base, pos, neg = UnitAttackPower("player")
        s.ap = (base or 0) + (pos or 0) + (neg or 0)
    end)
    pcall(function()
        if GetSpellCritChance then s.spellCrit = GetSpellCritChance(6) end
    end)
    return s
end

local function stateLine(s)
    if not s then return "?" end
    return string.format("L%s stam %s / int %s / spi %s / shadowSP %s / AP %s / crit %s%%",
        tostring(s.level or "?"), tostring(s.stam or "?"), tostring(s.int or "?"),
        tostring(s.spirit or "?"), tostring(s.shadowSP or "?"), tostring(s.ap or "?"),
        s.spellCrit and string.format("%.1f", s.spellCrit) or "?")
end

local function getProfile(name)
    return name and db.profiles[name] or nil
end

local function activeProfile()
    return getProfile(db.active)
end

-- ---------------------------------------------------------------- folding
local VALID_BUCKET_NUM = { damage = true, hits = true, activeSeconds = true, summonCount = true }
local KNOWN_BUCKET = { damage = true, hits = true, activeSeconds = true, summonCount = true,
                       spells = true, firstSeen = true, lastSeen = true }

local function validFight(fight)
    if type(fight) ~= "table" then return false, "fight not a table" end
    if type(fight.minions) ~= "table" then return false, "fight.minions missing" end
    for id, bucket in pairs(fight.minions) do
        if type(bucket) ~= "table" then return false, "bucket not a table: " .. tostring(id) end
        for f in pairs(VALID_BUCKET_NUM) do
            if bucket[f] ~= nil and type(bucket[f]) ~= "number" then
                return false, "bucket." .. f .. " not a number: " .. tostring(id)
            end
        end
    end
    return true
end

local function foldFight(profile, fight)
    for id, bucket in pairs(fight.minions) do
        local log = profile.log[id]
        if not log then
            log = { damage = 0, hits = 0, activeSeconds = 0, summonCount = 0,
                    fights = 0, spells = {} }
            profile.log[id] = log
        end
        log.damage = log.damage + (bucket.damage or 0)
        log.hits = log.hits + (bucket.hits or 0)
        log.activeSeconds = log.activeSeconds + (bucket.activeSeconds or 0)
        log.summonCount = log.summonCount + (bucket.summonCount or 0)
        log.fights = log.fights + 1
        for key, sp in pairs(bucket.spells or {}) do
            if type(sp) == "table" then
                local dst = log.spells[key]
                if not dst then
                    dst = { label = sp.label, spellId = sp.spellId, damage = 0, hits = 0 }
                    log.spells[key] = dst
                end
                dst.damage = dst.damage + (tonumber(sp.damage) or 0)
                dst.hits = dst.hits + (tonumber(sp.hits) or 0)
            end
        end
        -- drift visibility: fields the driver added that we do NOT fold
        for f, v in pairs(bucket) do
            if not KNOWN_BUCKET[f] and type(v) == "number" then
                profile.drift[f] = true
                sayOnce("extra:" .. f,
                    "driver bucket carries a field I don't fold yet: '" .. f
                    .. "' - additive update wanted (" .. driverVersion() .. ")")
            end
        end
    end
    profile.folds = profile.folds + 1
    profile.lastFold = date("%Y-%m-%d %H:%M")
end

local seenSet  -- session mirror of db.seen for O(1) checks
local function rebuildSeen()
    seenSet = {}
    for _, fp in ipairs(db.seen) do seenSet[fp] = true end
end

local function markSeen(fp)
    if seenSet[fp] then return end
    seenSet[fp] = true
    table.insert(db.seen, fp)
    while #db.seen > SEEN_CAP do
        local old = table.remove(db.seen, 1)
        seenSet[old] = nil
    end
end

local skippedFp = {}  -- session-only: invalid fights we refuse (no SV mark - a
                      -- fixed consumer build should get another chance at them)

local function harvest()
    local mdb = driverDb()
    if not mdb then
        sayOnce("nodriver", "Mancer not detected (no MancerDB) - nothing to fold.")
        return 0
    end
    local fights = mdb.fights
    if type(fights) ~= "table" or #fights == 0 then return 0 end

    local profile = activeProfile()
    if not profile then
        sayOnce("noprofile",
            #fights .. " fight(s) in the driver ring but NO ACTIVE PROFILE - "
            .. "/mledger new <name> to start folding.")
        return 0
    end

    local folded = 0
    for i = #fights, 1, -1 do  -- oldest first
        local fight = fights[i]
        local okShape, why = validFight(fight)
        if okShape then
            local fp = fingerprint(fight)
            if not seenSet[fp] then
                foldFight(profile, fight)
                markSeen(fp)
                folded = folded + 1
            end
        else
            local id = tostring(fight and fight.startedAt or i)
            if not skippedFp[id] then
                skippedFp[id] = true
                sayOnce("shape:" .. tostring(why),
                    "SHAPE DRIFT - fight skipped (" .. tostring(why) .. "); driver "
                    .. driverVersion() .. ". The fold code needs updating; refusing to guess.")
            end
        end
    end
    if folded > 0 then
        say(folded .. " fight(s) folded into '" .. profile.name .. "' (" .. profile.folds .. " total).")
    end
    return folded
end

-- ---------------------------------------------------------------- output
local function fmtN(v)
    v = tonumber(v) or 0
    if v >= 10000 then return string.format("%.0fk", v / 1000) end
    if v >= 1000 then return string.format("%.1fk", v / 1000) end
    return tostring(math.floor(v))
end

local function prettyId(id)
    return (tostring(id):gsub("_", " "):gsub("^%l", string.upper))
end

local function statsFor(name)
    local profile = name and getProfile(name) or activeProfile()
    if not profile then
        say("no such profile" .. (name and (": " .. name) or " (none active)"))
        return
    end
    say("profile '" .. profile.name .. "'" .. (db.active == profile.name and " (LIVE)" or "")
        .. " - " .. profile.folds .. " fights folded - captured: " .. stateLine(profile.snapshot))
    local any = false
    for id, log in pairs(profile.log) do
        any = true
        local cadence = log.activeSeconds > 0
            and string.format("%.1f", log.hits / (log.activeSeconds / 60)) or "-"
        say(string.format("  %s: %d summons, %ds unit-time, %d hits (%s hits/unit-min), dmg %s (raw)",
            prettyId(id), log.summonCount, math.floor(log.activeSeconds), log.hits,
            cadence, fmtN(log.damage)))
        -- ability mix by hit share (composition self-normalizes; magnitudes don't)
        local spells = {}
        for _, sp in pairs(log.spells) do spells[#spells + 1] = sp end
        table.sort(spells, function(a, b) return a.hits > b.hits end)
        for i = 1, math.min(3, #spells) do
            local sp = spells[i]
            local share = log.hits > 0 and math.floor(sp.hits / log.hits * 100 + 0.5) or 0
            say(string.format("     %s: %d%% of hits, dmg %s",
                tostring(sp.label or "?"), share, fmtN(sp.damage)))
        end
    end
    if not any then say("  (log empty - fight with the army out, fold happens on leaving combat)") end
    local drifts = {}
    for f in pairs(profile.drift) do drifts[#drifts + 1] = f end
    if #drifts > 0 then
        say("  unfolded driver fields seen: " .. table.concat(drifts, ", ") .. " (awaiting fold support)")
    end
    say("  (rates await driver support - crit/miss counters are in Mancer's dev line, not yet shipped)")
end

local function compare(a, b)
    local pa, pb = getProfile(a), getProfile(b)
    if not pa or not pb then
        say("compare needs two existing profiles: /mledger compare <a> <b>")
        return
    end
    say("compare '" .. pa.name .. "' vs '" .. pb.name .. "':")
    say("  A capture: " .. stateLine(pa.snapshot))
    say("  B capture: " .. stateLine(pb.snapshot))
    local ids = {}
    for id in pairs(pa.log) do ids[id] = true end
    for id in pairs(pb.log) do ids[id] = true end
    for id in pairs(ids) do
        local la, lb = pa.log[id], pb.log[id]
        local function cad(l)
            return (l and l.activeSeconds and l.activeSeconds > 0)
                and string.format("%.1f", l.hits / (l.activeSeconds / 60)) or "-"
        end
        say(string.format("  %s: summons %s vs %s | unit-time %ss vs %ss | hits/unit-min %s vs %s | dmg(raw) %s vs %s",
            prettyId(id),
            la and la.summonCount or 0, lb and lb.summonCount or 0,
            la and math.floor(la.activeSeconds) or 0, lb and math.floor(lb.activeSeconds) or 0,
            cad(la), cad(lb),
            la and fmtN(la.damage) or 0, lb and fmtN(lb.damage) or 0))
    end
end

-- ---------------------------------------------------------------- events
local pendingHarvest = nil
local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_REGEN_ENABLED")
ev:RegisterEvent("PLAYER_ENTERING_WORLD")
ev:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" then
        if name ~= ADDON then return end
        MancerLedgerDB = MancerLedgerDB or {}
        db = MancerLedgerDB
        db.profiles = db.profiles or {}
        db.seen = db.seen or {}
        rebuildSeen()
    elseif event == "PLAYER_REGEN_ENABLED" then
        pendingHarvest = HARVEST_DELAY  -- let the driver's commit land first
    elseif event == "PLAYER_ENTERING_WORLD" then
        pendingHarvest = 3.0            -- login/reload catch-up
    end
end)
ev:SetScript("OnUpdate", function(_, dt)
    if not pendingHarvest then return end
    pendingHarvest = pendingHarvest - dt
    if pendingHarvest <= 0 then
        pendingHarvest = nil
        pcall(harvest)
    end
end)

-- ---------------------------------------------------------------- slash
SLASH_MANCERLEDGER1 = "/mledger"
SlashCmdList["MANCERLEDGER"] = function(msg)
    local cmd, arg, arg2 = msg:match("^(%S*)%s*(%S*)%s*(%S*)")
    cmd = cmd:lower()
    if cmd == "new" and arg ~= "" then
        if getProfile(arg) then
            say("profile '" .. arg .. "' already exists - /mledger use " .. arg .. " to activate it.")
            return
        end
        harvest()  -- pending fights belong to the OLD profile
        db.profiles[arg] = {
            name = arg, snapshot = captureState(),
            folds = 0, log = {}, drift = {},
            driver = driverVersion(),
        }
        db.active = arg
        say("profile '" .. arg .. "' created and LIVE - " .. stateLine(db.profiles[arg].snapshot))
    elseif cmd == "use" and arg ~= "" then
        if not getProfile(arg) then say("no such profile: " .. arg) return end
        harvest()  -- flush to the old profile before switching
        db.active = arg
        say("profile '" .. arg .. "' is LIVE.")
    elseif cmd == "list" then
        local any = false
        for name, p in pairs(db.profiles) do
            any = true
            say((db.active == name and "> " or "  ") .. name
                .. " (" .. p.folds .. " fights, created " .. (p.snapshot and p.snapshot.at or "?")
                .. ") - " .. stateLine(p.snapshot))
        end
        if not any then say("no profiles yet - /mledger new <name>") end
    elseif cmd == "stats" then
        statsFor(arg ~= "" and arg or nil)
    elseif cmd == "compare" and arg ~= "" and arg2 ~= "" then
        compare(arg, arg2)
    elseif cmd == "resetlog" and arg ~= "" then
        local p = getProfile(arg)
        if not p then say("no such profile: " .. arg) return end
        p.log, p.folds, p.drift = {}, 0, {}
        say("log reset for '" .. arg .. "' (capture kept).")
    elseif cmd == "delete" and arg ~= "" then
        if arg2 ~= "sure" then
            say("this deletes profile '" .. arg .. "' and its log - /mledger delete " .. arg .. " sure")
            return
        end
        if not getProfile(arg) then say("no such profile: " .. arg) return end
        db.profiles[arg] = nil
        if db.active == arg then db.active = nil end
        say("profile '" .. arg .. "' deleted.")
    elseif cmd == "harvest" then
        local n = harvest()
        if n == 0 then say("nothing new to fold.") end
    elseif cmd == "status" then
        local mdb = driverDb()
        say("driver: " .. driverVersion() .. " - ring: "
            .. (mdb and mdb.fights and #mdb.fights or "ABSENT")
            .. " fight(s) - cursor: " .. #db.seen .. " folded fingerprints - live profile: "
            .. tostring(db.active or "NONE"))
    else
        say("/mledger new <name> | use <name> | list | stats [name] | compare <a> <b> | resetlog <name> | delete <name> sure | harvest | status")
    end
end
