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
-- Verified driver contract (LibellusLeti 0.9.553 dev drop, silo-archived;
-- fingerprint recipe + ring cap unchanged since 0.9.434):
--   fight = { startedAt, endedAt, minions = { [minionId] = bucket }, ... }
--   bucket = { damage, hits, misses, missTypes = { DODGE/PARRY/BLOCK/RESIST/
--              ABSORB/IMMUNE = n }, activeSeconds, summonCount,
--              spells = { [key] = { label, spellId, damage, hits, misses,
--              missTypes } }, units = {...} (per-GUID, deliberately unfolded -
--              our grain is per-type) }
--   minionId = lowercase slug ("ghoul"). NO crit tracking in the driver yet.
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

local ADDON, NS = ...

local SEEN_CAP = 60          -- folded-fingerprint FIFO (ring is only 10 deep)
local HARVEST_DELAY = 1.5    -- s after regen, so the driver commits first

local db                     -- MancerLedgerDB
local saidOnce = {}          -- session: one loud line per reason
local chatEcho = false       -- true only inside a slash invocation (you asked
                             -- in chat, you get answered in chat)

local HISTORY_CAP = 50

local function pushHistory(msg)
    if not db then return end
    db.history = db.history or {}
    local clean = tostring(msg):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    table.insert(db.history, 1, { t = date("%H:%M:%S"), d = date("%m/%d"), msg = clean })
    while #db.history > HISTORY_CAP do table.remove(db.history) end
end

local function chat(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffb08ef0MancerLedger|r: " .. msg)
end

-- the log history IS the record (Battlewrath: history, not chat dumping).
-- Chat additionally only when: you're answering a typed command, or it's a
-- loud one-time warning.
local function say(msg)
    pushHistory(msg)
    if chatEcho then chat(msg) end
end

local function sayOnce(key, msg)
    if saidOnce[key] then return end
    saidOnce[key] = true
    pushHistory(msg)
    chat(msg)  -- warnings stay loud
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
local VALID_BUCKET_NUM = { damage = true, hits = true, misses = true,
                           activeSeconds = true, summonCount = true }
local KNOWN_BUCKET = { damage = true, hits = true, misses = true, missTypes = true,
                       activeSeconds = true, summonCount = true,
                       spells = true, firstSeen = true, lastSeen = true,
                       units = true }  -- per-GUID grain: deliberately unfolded

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
            log = { damage = 0, hits = 0, misses = 0, missTypes = {},
                    activeSeconds = 0, summonCount = 0, fights = 0, spells = {} }
            profile.log[id] = log
        end
        log.misses = log.misses or 0          -- pre-0.2 profile logs lack these
        log.missTypes = log.missTypes or {}
        log.damage = log.damage + (bucket.damage or 0)
        log.hits = log.hits + (bucket.hits or 0)
        log.misses = log.misses + (bucket.misses or 0)
        if type(bucket.missTypes) == "table" then
            for mt, n in pairs(bucket.missTypes) do
                if type(n) == "number" then
                    log.missTypes[mt] = (log.missTypes[mt] or 0) + n
                end
            end
        end
        log.activeSeconds = log.activeSeconds + (bucket.activeSeconds or 0)
        log.summonCount = log.summonCount + (bucket.summonCount or 0)
        log.fights = log.fights + 1
        for key, sp in pairs(bucket.spells or {}) do
            if type(sp) == "table" then
                local dst = log.spells[key]
                if not dst then
                    dst = { label = sp.label, spellId = sp.spellId,
                            damage = 0, hits = 0, misses = 0, missTypes = {} }
                    log.spells[key] = dst
                end
                dst.misses = dst.misses or 0
                dst.missTypes = dst.missTypes or {}
                dst.damage = dst.damage + (tonumber(sp.damage) or 0)
                dst.hits = dst.hits + (tonumber(sp.hits) or 0)
                dst.misses = dst.misses + (tonumber(sp.misses) or 0)
                if type(sp.missTypes) == "table" then
                    for mt, n in pairs(sp.missTypes) do
                        if type(n) == "number" then
                            dst.missTypes[mt] = (dst.missTypes[mt] or 0) + n
                        end
                    end
                end
            end
        end
        -- drift visibility: fields the driver added that we do NOT fold.
        -- Tables count too - 0.9.553's missTypes was invisible to a
        -- numbers-only check; never again.
        for f, v in pairs(bucket) do
            if not KNOWN_BUCKET[f] and (type(v) == "number" or type(v) == "table") then
                profile.drift[f] = driverVersion()  -- WHICH driver introduced it
                sayOnce("extra:" .. f,
                    "driver bucket carries a field I don't fold yet: '" .. f
                    .. "' - additive update wanted (" .. driverVersion() .. ")")
            end
        end
    end
    profile.folds = profile.folds + 1
    profile.lastFold = date("%Y-%m-%d %H:%M")
    profile.lastDriver = driverVersion()  -- version history: created-with + last-fed-by
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
        if NS.ui and NS.ui.RefreshIfShown then NS.ui.RefreshIfShown() end
        if NS.onFold then pcall(NS.onFold, folded) end  -- minimap blue blink
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
    -- lesser_zombie -> Lesser Zombie (every word, not just the first)
    return (tostring(id):gsub("_", " "):gsub("%f[%a]%l", string.upper))
end

local SAMPLE_FLOOR = 20
local function missPct(log)
    local attempts = (log.hits or 0) + (log.misses or 0)
    if attempts < SAMPLE_FLOOR then return "-" end
    return math.floor((log.misses or 0) / attempts * 100 + 0.5) .. "%"
end

local function missBreakdown(log)
    local parts = {}
    for mt, n in pairs(log.missTypes or {}) do
        parts[#parts + 1] = string.lower(mt) .. " " .. n
    end
    table.sort(parts)
    return #parts > 0 and table.concat(parts, ", ") or nil
end

-- Cadence (hits/unit-min) is only honest when the summon windows plausibly
-- COVER the hits. The driver accrues unit-time from in-fight summon windows
-- only ("Animate CD uptime/DPS") - a PERMANENT raised before the pull buckets
-- hits with no window, and one observed re-raise would divide all-fight hits
-- by a sliver of time (live-caught: 174.9 hits/min on a lone warrior). Temp
-- minions summon at least once per fight they act in, hence the gate.
local function cadence(log)
    local t = log.activeSeconds or 0
    if t <= 0 then return nil end
    if (log.summonCount or 0) < (log.fights or 1) then return nil end
    return (log.hits or 0) / (t / 60)
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
        local cad = cadence(log)
        -- summons/unit-time are OBSERVED-IN-FIGHT accounting: a permanent
        -- raised before the pull shows "-", not a false zero
        local sumS = (log.summonCount or 0) > 0 and tostring(log.summonCount) or "-"
        local timeS = (log.activeSeconds or 0) > 0 and (math.floor(log.activeSeconds) .. "s") or "-"
        say(string.format("  %s: %s summons, %s unit-time, %d hits (%s hits/unit-min), miss %s, dmg %s (raw)",
            prettyId(id), sumS, timeS, log.hits,
            cad and string.format("%.1f", cad) or "-", missPct(log), fmtN(log.damage)))
        local bd = missBreakdown(log)
        if bd then say("     avoided as: " .. bd) end
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
    say("  (crit awaits driver support - Mancer does not track crits yet; miss rates live as of 0.9.553)")
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
        local function cadS(l)
            local c = l and cadence(l)
            return c and string.format("%.1f", c) or "-"
        end
        local function sumS(l)
            return (l and (l.summonCount or 0) > 0) and tostring(l.summonCount) or "-"
        end
        local function timeS(l)
            return (l and (l.activeSeconds or 0) > 0) and (math.floor(l.activeSeconds) .. "s") or "-"
        end
        say(string.format("  %s: summons %s vs %s | unit-time %s vs %s | hits/unit-min %s vs %s | miss %s vs %s | dmg(raw) %s vs %s",
            prettyId(id),
            sumS(la), sumS(lb), timeS(la), timeS(lb),
            cadS(la), cadS(lb),
            la and missPct(la) or "-", lb and missPct(lb) or "-",
            la and fmtN(la.damage) or "-", lb and fmtN(lb.damage) or "-"))
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
        db.history = db.history or {}
        db.minimap = db.minimap or { angle = 210 }
        rebuildSeen()
        if NS.OnDbReady then pcall(NS.OnDbReady) end  -- minimap paints its state
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

-- ---------------------------------------------------------------- profile ops
-- Shared by the slash alias AND the window (the window is the interface;
-- typed commands are the power-user alias).
local function profileNew(name)
    if not name or name == "" then return false, "name required" end
    if name:find("%s") then return false, "no spaces in profile names (slash addressing)" end
    if getProfile(name) then return false, "profile '" .. name .. "' already exists" end
    harvest()  -- pending fights belong to the OLD profile
    db.profiles[name] = {
        name = name, snapshot = captureState(),
        folds = 0, log = {}, drift = {},
        driver = driverVersion(),
    }
    db.active = name
    say("profile '" .. name .. "' created and LIVE - " .. stateLine(db.profiles[name].snapshot))
    return true
end

local function profileUse(name)
    if not getProfile(name) then return false, "no such profile: " .. tostring(name) end
    harvest()  -- flush to the old profile before switching
    db.active = name
    say("profile '" .. name .. "' is LIVE.")
    return true
end

local function profileDelete(name)
    if not getProfile(name) then return false, "no such profile: " .. tostring(name) end
    db.profiles[name] = nil
    if db.active == name then db.active = nil end
    say("profile '" .. name .. "' deleted.")
    return true
end

local function profileResetLog(name)
    local p = getProfile(name)
    if not p then return false, "no such profile: " .. tostring(name) end
    p.log, p.folds, p.drift = {}, 0, {}
    say("log reset for '" .. name .. "' (capture kept; already-folded ring fights stay folded - fresh start from now).")
    return true
end

local function profileOff()
    -- recording off: pending ring fights flush to the outgoing profile first
    if db.active then harvest() end
    db.active = nil
    say("recording OFF - fights will wait in the driver ring until a profile is live.")
    return true
end

local function profileRename(old, new)
    local p = getProfile(old)
    if not p then return false, "no such profile: " .. tostring(old) end
    if not new or new == "" then return false, "new name required" end
    if new:find("%s") then return false, "no spaces in profile names (slash addressing)" end
    if getProfile(new) then return false, "profile '" .. new .. "' already exists" end
    db.profiles[new] = p
    db.profiles[old] = nil
    p.name = new
    if db.active == old then db.active = new end
    say("profile '" .. old .. "' renamed to '" .. new .. "'.")
    return true
end

-- the UI's data door (db is nil until ADDON_LOADED)
NS.GetDb = function() return db end
NS.getProfile = getProfile
NS.harvest = harvest
NS.profileNew = profileNew
NS.profileUse = profileUse
NS.profileDelete = profileDelete
NS.profileResetLog = profileResetLog
NS.profileRename = profileRename
NS.profileOff = profileOff
NS.driverDb = driverDb
NS.driverVersion = driverVersion
NS.stateLine = stateLine
NS.fmtN = fmtN
NS.prettyId = prettyId
NS.missPct = missPct
NS.missBreakdown = missBreakdown
NS.cadence = cadence
NS.SAMPLE_FLOOR = SAMPLE_FLOOR
NS.say = say

-- ---------------------------------------------------------------- slash
local HandleSlash

SLASH_MANCERLEDGER1 = "/mledger"
SlashCmdList["MANCERLEDGER"] = function(msg)
    chatEcho = true  -- typed commands get chat answers; UI clicks go to history
    local ok, err = pcall(HandleSlash, msg)
    chatEcho = false
    if not ok then chat("error: " .. tostring(err)) end
end

function HandleSlash(msg)
    local cmd, arg, arg2 = msg:match("^(%S*)%s*(%S*)%s*(%S*)")
    cmd = cmd:lower()
    if cmd == "new" and arg ~= "" then
        local ok, err = profileNew(arg)
        if not ok then say(err .. (err:find("exists") and " - /mledger use " .. arg or "")) end
    elseif cmd == "use" and arg ~= "" then
        local ok, err = profileUse(arg)
        if not ok then say(err) end
    elseif (cmd == "show" or cmd == "ui" or cmd == "") and NS.ui then
        NS.ui.Toggle()
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
    elseif cmd == "off" then
        profileOff()
    elseif cmd == "rename" and arg ~= "" and arg2 ~= "" then
        local ok, err = profileRename(arg, arg2)
        if not ok then say(err) end
    elseif cmd == "resetlog" and arg ~= "" then
        local ok, err = profileResetLog(arg)
        if not ok then say(err) end
    elseif cmd == "delete" and arg ~= "" then
        if arg2 ~= "sure" then
            say("this deletes profile '" .. arg .. "' and its log - /mledger delete " .. arg .. " sure")
            return
        end
        local ok, err = profileDelete(arg)
        if not ok then say(err) end
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
        say("/mledger (window) | new <name> | use <name> | off | rename <old> <new> | list | stats [name] | compare <a> <b> | resetlog <name> | delete <name> sure | harvest | status")
    end
end
