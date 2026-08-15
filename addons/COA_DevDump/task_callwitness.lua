-- task_callwitness.lua - THE CALL WITNESS.
--
-- Spec + acceptance criteria: addons/planning/callwitness_design.md (AC1-AC13).
-- Built because the driver addon does not report its own call rates or
-- per-function time, so every function-level claim so far has been a source
-- read. This wraps its functions IN PLACE - the addon calls its own method
-- names and our counter runs inside its own call path. Nothing on disk
-- changes; wrappers lift off at stop.
--
--   /coadump st callwitness [outlierMs]   start (default outlier 5ms)
--   ...run the arm...
--   /coadump sp                           stop -> unwrap + one envelope
--
-- AC11: wrappers allocate NOTHING on hot paths. We are testing a
-- garbage-collection hypothesis; the instrument must not manufacture the
-- effect it measures. Two flavours only:
--   count : increments a counter, TAIL-CALLS the original (zero alloc, no timing)
--   void  : times a function that returns nothing (zero alloc, full timing)
-- Value-returning functions are count-only by design - capturing returns
-- would need a table per call, which is exactly the confound.
--
-- AC13: our OWN capture functions are wrapped on the same footing and land in
-- the same table. The accumulator and outlier writer stay unwrapped (no
-- self-recursion) or the witness measures its own measuring.

local ADDON, D = ...

local DEFAULT_OUTLIER_MS = 5
local MAX_BUCKETS = 20000     -- flat rows (fn x second) - AC9 bounds
local MAX_OUTLIERS = 6000
local PROBE_CALLS = 2000      -- AC7a: no-op probe sample size

-- ---------------------------------------------------------------- targets
-- Resolved at RUNTIME against candidate paths. A method that does not resolve
-- is REPORTED as missing, never silently skipped (guards renames across builds).
local TARGETS = {
    { paths = { "Mancer.MinionHpHudModule", "Mancer.MinionHpHud" }, label = "HpHud", methods = {
        { "OnUpdate", "void" }, { "Refresh", "void" },
        { "SyncNameplateSupport", "void" }, { "UpdateCloakDriver", "void" },
        { "ScanAndApplyNamesOnly", "void" }, { "ReassertNamesOnly", "void" },
        { "ApplyNameplateVisualHide", "void" }, { "ClearNameplateVisualHide", "void" },
        { "ApplyNamesOnlyToFrame", "void" }, { "ApplyNamesOnlyToUnit", "void" },
        { "BoostNameplates", "void" }, { "RestoreNameplates", "void" },
        { "EnsureFrames", "void" }, { "ApplyLayout", "void" },
        { "CollectFramesForUnit", "count" }, { "ShouldNamesOnlyUnit", "count" },
        { "IsOwnedGuardianUnit", "count" }, { "FrameHasClassColoredHealth", "count" },
    } },
    { paths = { "Mancer.MinionSheetModule", "Mancer.MinionSheet" }, label = "Sheet", methods = {
        { "Refresh", "void" }, { "SyncNameplateSupport", "void" },
        { "BoostNameplates", "void" }, { "RestoreNameplates", "void" },
    } },
    { paths = { "Mancer.NecromancerAdvisor", "Mancer.Advisor" }, label = "Advisor", methods = {
        { "OnUpdate", "void" }, { "Poll", "void" }, { "Refresh", "void" },
        { "ScanUnits", "void" }, { "SyncSpellCooldowns", "void" },
    } },
    { paths = { "Mancer.RegenTracker" }, label = "Regen", methods = {
        { "OnUpdate", "void" }, { "SyncValues", "void" }, { "ApplyConfig", "void" },
    } },
    { paths = { "Mancer.FloatingText" }, label = "FloatText", methods = {
        { "OnUpdate", "void" }, { "Refresh", "void" }, { "UpdateRateText", "void" },
    } },
    { paths = { "Mancer.MinionDpsModule" }, label = "Dps", methods = {
        { "ProcessCleuEvent", "void" }, { "OnCombatEnd", "void" },
    } },
}

-- ---------------------------------------------------------------- state
local payload, frames
local legend, calls, usTot, usMax   -- per index
local wrapped                       -- [i] = { tbl, key, orig, wrapper }
local outlierUs, startMs, secIndex
local nowMs                         -- timer fn

-- flat output arrays (AC: representation - integers, no tables per row)
local bSec, bFn, bCalls, bUs, bMax
local oMs, oFn, oUs
local cMs, cFps, cPlates, cDrvCpu, cSelfCpu

local droppedBuckets, droppedOutliers = 0, 0

-- ---------------------------------------------------------------- timer
local function makeTimer()
    if type(debugprofilestop) == "function" then
        local ok = pcall(debugprofilestop)
        if ok then return debugprofilestop, "debugprofilestop" end
    end
    return function() return GetTime() * 1000 end, "GetTime(ms)"
end

-- ---------------------------------------------------------------- wrappers
-- AC11: neither flavour allocates. `count` tail-calls; `void` discards returns.
local function wrapCount(i, fn)
    return function(...)
        calls[i] = calls[i] + 1
        return fn(...)
    end
end

local function wrapVoid(i, fn)
    return function(...)
        local t0 = nowMs()
        fn(...)
        local us = (nowMs() - t0) * 1000
        calls[i] = calls[i] + 1
        usTot[i] = usTot[i] + us
        if us > usMax[i] then usMax[i] = us end
        if us >= outlierUs and #oMs < MAX_OUTLIERS then
            local n = #oMs + 1
            oMs[n] = math.floor(nowMs() - startMs)
            oFn[n] = i
            oUs[n] = math.floor(us)
        elseif us >= outlierUs then
            droppedOutliers = droppedOutliers + 1
        end
    end
end

local function resolvePath(path)
    local obj = _G
    for part in path:gmatch("[^%.]+") do
        if type(obj) ~= "table" then return nil end
        obj = obj[part]
        if obj == nil then return nil end
    end
    return obj
end

local function addTarget(label, name, mode, tbl, key, fn)
    local i = #legend + 1
    legend[i] = label .. ":" .. name
    calls[i], usTot[i], usMax[i] = 0, 0, 0
    local w = (mode == "void") and wrapVoid(i, fn) or wrapCount(i, fn)
    tbl[key] = w
    wrapped[i] = { tbl = tbl, key = key, orig = fn, wrapper = w }
    return i
end

-- ---------------------------------------------------------------- self (AC13)
-- Our own capture work, wrapped by the SAME mechanism into the SAME table.
-- The accumulator/outlier writer above is deliberately NOT wrapped.
local Self = {}

function Self:ContextTick()
    local n = #cMs + 1
    cMs[n] = math.floor(nowMs() - startMs)
    cFps[n] = math.floor((GetFramerate and GetFramerate() or 0) * 10)  -- fps x10, integer
    local plates = 0
    for i = 1, 40 do
        if UnitExists("nameplate" .. i) then plates = plates + 1 end
    end
    cPlates[n] = plates
    pcall(UpdateAddOnCPUUsage)
    local ok, v = pcall(GetAddOnCPUUsage, payload.driverAddon or "LibellusLeti")
    cDrvCpu[n] = math.floor((ok and v or 0) * 1000)   -- us
    local ok2, v2 = pcall(GetAddOnCPUUsage, "COA_DevDump")
    cSelfCpu[n] = math.floor((ok2 and v2 or 0) * 1000)
end

function Self:FlushBuckets()
    secIndex = secIndex + 1
    for i = 1, #legend do
        if calls[i] > 0 then
            if #bSec < MAX_BUCKETS then
                local n = #bSec + 1
                bSec[n] = secIndex
                bFn[n] = i
                bCalls[n] = calls[i]
                bUs[n] = math.floor(usTot[i])
                bMax[n] = math.floor(usMax[i])
            else
                droppedBuckets = droppedBuckets + 1
            end
            calls[i], usTot[i], usMax[i] = 0, 0, 0
        end
    end
end

-- ---------------------------------------------------------------- environment
local NAMEPLATE_CVARS = {
    "nameplateShowEnemies", "nameplateShowEnemyPets", "nameplateShowEnemyGuardians",
    "nameplateShowEnemyTotems", "nameplateShowFriends", "nameplateShowFriendlyPets",
    "nameplateShowFriendlyGuardians", "nameplateShowFriendlyTotems", "nameplateShowPersonal",
}

local DRIVER_SETTINGS = {
    "disableNameplatesInCapitals", "hideMinionHpNameplateVisuals", "showMinionHpList",
    "showHealthBar", "showZombieCounter", "showManaBar", "showProcBar", "showAnimateBar",
    "showRegenRate", "showRunicBar", "consolidateBuffs",
}

-- AC6: arm-defining state, start AND end
local function snapshotEnv()
    local e = { cvars = {}, settings = {}, }
    for _, k in ipairs(NAMEPLATE_CVARS) do
        local ok, v = pcall(GetCVar, k)
        e.cvars[k] = ok and v or "ERR"
    end
    local db = _G.MancerDB or _G.LibellusLetiDB
    if type(db) == "table" then
        -- ABSENT is a MEANINGFUL VALUE in this driver: several options are
        -- opt-out-by-absence (`hideMinionHpNameplateVisuals ~= false`,
        -- `disableNameplatesInCapitals ~= false`), so an unwritten key means
        -- the feature is ON. A nil would serialise away and be
        -- indistinguishable from "not captured" - record the sentinel.
        for _, k in ipairs(DRIVER_SETTINGS) do
            local v = db[k]
            if v == nil then v = "ABSENT(default-on)" end
            e.settings[k] = v
        end
        if type(db.nameplateNamesOnlyTargets) == "table" then
            local t = {}
            for k2, v2 in pairs(db.nameplateNamesOnlyTargets) do t[k2] = v2 end
            e.settings["nameplateNamesOnlyTargets"] = t
        else
            e.settings["nameplateNamesOnlyTargets"] = "ABSENT(default-on)"
        end
    else
        e.settings = "NO DRIVER DB FOUND"
    end
    pcall(function() e.zone = GetRealZoneText() end)
    pcall(function() e.subzone = GetSubZoneText() end)
    pcall(function()
        e.capitalMuteActive = _G.Mancer and _G.Mancer.IsCapitalNameplateMuteActive
            and _G.Mancer.IsCapitalNameplateMuteActive() or false
    end)
    local plates = 0
    for i = 1, 40 do if UnitExists("nameplate" .. i) then plates = plates + 1 end end
    e.plateCount = plates
    return e
end

-- ★★ FACT: addon Lua CANNOT read files from disk - so a build can only be identified
--   by a runtime STRUCTURAL fingerprint. File hashes are an offline step.
-- AC12: identify the build by CONTENT, not label. We cannot read files from
-- Lua, so the runtime anchor is a STRUCTURAL fingerprint (sorted method names
-- across resolved modules, hashed). File hashes are computed offline by the
-- analysis step against the installed folder.
local function structuralFingerprint(resolved)
    local names = {}
    for _, r in ipairs(resolved) do
        local obj = r.obj
        for k, v in pairs(obj) do
            if type(v) == "function" then names[#names + 1] = r.label .. "." .. k end
        end
    end
    table.sort(names)
    local h = 5381
    for i = 1, #names do
        local s = names[i]
        for j = 1, #s do
            h = (h * 33 + s:byte(j)) % 4294967296
        end
    end
    return h, #names
end

-- ---------------------------------------------------------------- task
D.RegisterTask{
    name = "callwitness",
    mode = "session",
    help = "callwitness [outlierMs] - wrap driver + own functions, log calls/time per second + outliers (spec: addons/planning/callwitness_design.md)",
    start = function(args)
        local outlierMs = tonumber((args or ""):match("%S+")) or DEFAULT_OUTLIER_MS
        payload = D.Begin("callwitness", args)
        payload.driverAddon = "LibellusLeti"
        payload.spec = "addons/planning/callwitness_design.md"

        nowMs = select(1, makeTimer())
        payload.timerSource = select(2, makeTimer())
        startMs, secIndex = nowMs(), 0
        outlierUs = outlierMs * 1000
        payload.outlierMs = outlierMs

        legend, calls, usTot, usMax, wrapped = {}, {}, {}, {}, {}
        bSec, bFn, bCalls, bUs, bMax = {}, {}, {}, {}, {}
        oMs, oFn, oUs = {}, {}, {}
        cMs, cFps, cPlates, cDrvCpu, cSelfCpu = {}, {}, {}, {}, {}
        droppedBuckets, droppedOutliers = 0, 0

        payload.scriptProfile = GetCVar and GetCVar("scriptProfile") or "?"
        pcall(function()
            payload.driverVersion = GetAddOnMetadata("LibellusLeti", "Version")
        end)

        -- resolve + wrap the driver (AC: report misses, never skip silently)
        local resolved, missing = {}, {}
        for _, t in ipairs(TARGETS) do
            local obj, usedPath
            for _, p in ipairs(t.paths) do
                local o = resolvePath(p)
                if type(o) == "table" then obj, usedPath = o, p break end
            end
            if not obj then
                missing[#missing + 1] = t.label .. " (no path: " .. table.concat(t.paths, "|") .. ")"
            else
                resolved[#resolved + 1] = { label = t.label, path = usedPath, obj = obj }
                for _, m in ipairs(t.methods) do
                    local fn = obj[m[1]]
                    if type(fn) == "function" then
                        addTarget(t.label, m[1], m[2], obj, m[1], fn)
                    else
                        missing[#missing + 1] = t.label .. ":" .. m[1]
                    end
                end
            end
        end
        payload.resolvedModules = {}
        for _, r in ipairs(resolved) do payload.resolvedModules[r.label] = r.path end
        payload.missingTargets = missing
        local fp, fnCount = structuralFingerprint(resolved)
        payload.structuralFingerprint = fp
        payload.structuralFnCount = fnCount

        -- AC13: wrap OUR OWN capture functions on the same footing
        addTarget("Witness", "ContextTick", "void", Self, "ContextTick", Self.ContextTick)
        addTarget("Witness", "FlushBuckets", "void", Self, "FlushBuckets", Self.FlushBuckets)

        -- AC7a: per-call wrapper cost, measured not assumed
        local function noop() end
        local probeIdx = addTarget("Witness", "Probe", "void", { }, "noop", noop)
        local probeW = wrapped[probeIdx].wrapper
        local t0 = nowMs()
        for _ = 1, PROBE_CALLS do noop() end
        local rawMs = nowMs() - t0
        t0 = nowMs()
        for _ = 1, PROBE_CALLS do probeW() end
        local wrapMs = nowMs() - t0
        payload.probe = {
            calls = PROBE_CALLS,
            rawUsPerCall = (rawMs * 1000) / PROBE_CALLS,
            wrappedUsPerCall = (wrapMs * 1000) / PROBE_CALLS,
            overheadUsPerCall = ((wrapMs - rawMs) * 1000) / PROBE_CALLS,
        }
        calls[probeIdx], usTot[probeIdx], usMax[probeIdx] = 0, 0, 0
        oMs, oFn, oUs = {}, {}, {}   -- discard probe outliers

        payload.envStart = snapshotEnv()

        local tick = CreateFrame("Frame")
        local acc = 0
        tick:SetScript("OnUpdate", function(_, dt)
            acc = acc + dt
            if acc < 1.0 then return end
            acc = 0
            local ok = pcall(function()
                Self:ContextTick()
                Self:FlushBuckets()
            end)
            if not ok then payload.tickErrors = (payload.tickErrors or 0) + 1 end
        end)
        frames = { tick = tick }

        D.Print(("callwitness: %d functions wrapped (%d unresolved), outlier %dms, wrapper cost %.2fus/call")
            :format(#legend, #missing, outlierMs, payload.probe.overheadUsPerCall))
    end,
    stop = function()
        if frames and frames.tick then frames.tick:SetScript("OnUpdate", nil) end
        Self:FlushBuckets()
        payload.envEnd = snapshotEnv()

        -- AC10: restore ONLY where our wrapper is still in place
        local restored, foreign = 0, 0
        for i = 1, #wrapped do
            local w = wrapped[i]
            if w.tbl[w.key] == w.wrapper then
                w.tbl[w.key] = w.orig
                restored = restored + 1
            else
                foreign = foreign + 1
            end
        end
        payload.unwrap = { restored = restored, replacedByOther = foreign, total = #wrapped }

        payload.legend = legend
        payload.buckets = { sec = bSec, fn = bFn, calls = bCalls, us = bUs, maxUs = bMax }
        payload.outliers = { ms = oMs, fn = oFn, us = oUs }
        payload.context = { ms = cMs, fpsX10 = cFps, plates = cPlates,
                            driverCpuUs = cDrvCpu, selfCpuUs = cSelfCpu }
        payload.bounds = { maxBuckets = MAX_BUCKETS, maxOutliers = MAX_OUTLIERS,
                           droppedBuckets = droppedBuckets, droppedOutliers = droppedOutliers,
                           truncated = (droppedBuckets > 0 or droppedOutliers > 0) }
        payload.durationSec = (nowMs() - startMs) / 1000

        local totalCalls, totalUs = 0, 0
        for i = 1, #bCalls do totalCalls = totalCalls + bCalls[i] totalUs = totalUs + bUs[i] end
        payload.totals = { calls = totalCalls, us = totalUs,
                           estOverheadUs = totalCalls * (payload.probe.overheadUsPerCall or 0) }

        D.Commit(("callwitness: %d fn, %d calls, %.0fms measured, %.0fms est. observer cost, %d buckets, %d outliers, unwrap %d/%d%s")
            :format(#legend, totalCalls, totalUs / 1000,
                    payload.totals.estOverheadUs / 1000, #bSec, #oMs,
                    restored, #wrapped,
                    payload.bounds.truncated and ", TRUNCATED" or ""))
    end,
}
