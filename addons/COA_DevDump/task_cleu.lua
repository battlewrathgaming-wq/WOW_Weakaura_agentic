-- task_cleu.lua - what does a CLEU listener actually COST on this fork?
--
-- The "no CLEU listener" rule in COA_DungeonRun is a COST CLAIM, and cost claims
-- are testable. `addons/planning/cleu_on_this_fork.md` settled the SHAPE (push with
-- a lean mask, because the retained buffer is empty when read and the filter API is
-- a live shared singleton). It did not settle the COST, and nothing can except a
-- measurement in a real pull.
--
-- ---------------------------------------------------------------------------
-- ★ IT MEASURES ALLOCATION, NOT TIME - and that is the whole design decision.
--
-- AscensionLogsCompanion, fork-native and profiled here, removed mouseover boss
-- detection because it "added baseline allocation pressure (UnitName + lower) for
-- ~zero detection benefit... a meaningful contributor to mid-fight GC pressure
-- reported by Nace's ZG report 7976."
--
-- So on THIS client the cost is GC pressure, not call count. `debugprofilestop`
-- measures the wrong thing, and worse: timing a handler that does almost nothing
-- measures mostly the timer. Two debugprofilestop calls per event would dominate
-- the very body under test - the observer eating what it observes.
--
-- So there is NO per-event timing here. `collectgarbage("count")` is sampled once
-- a second, which matches the diagnosis and costs one call per second. The timer is
-- ★★ FACT: debugprofilestop can SILENTLY NOT ADVANCE - a 0ms observer cost means
--   distrust the reading, not "it was free". ⚠ Not a contradiction of
--   GuardianPlates/Core.lua:2319 ("genuine, callable anywhere"): that is
--   AVAILABILITY, confirmed from Wowpedia; this is RESOLUTION, from an observed
--   run. Invariant 8 - secondary sources for concepts, the installed client for
--   facts - so where they touch, the observation governs.
-- calibrated ONCE at start and reported, because this bench already knows it can
-- silently not advance (addons/README.md: "observer cost printing 0ms =>
-- debugprofilestop not advancing, distrust").
-- ---------------------------------------------------------------------------
--
-- ★ THREE ARMS, SWITCHED IN-SESSION so client state does not differ between them
-- (memory pressure, other addons' warm-up). One envelope, three segments:
--
--   none    no handler registered at all - the client's own baseline
--   count   registered, increments a counter. The cost of BEING CALLED
--   masked  registered, subevent compare + a hostile-flag test on hits.
--           The realistic shape of what DungeonRun would actually run
--
--   /coadump st cleu           open the session (starts on arm `none`)
--   /coadump mark count        switch arm - do the SAME segment again
--   /coadump mark masked       switch arm - and again
--   /coadump sp                stop; /reload lands it
--
-- His control: "I can pull from the start of SFK to the boss. Kill them all.
-- Repeat." Fixed mob set is the dominant term in event volume, so run-to-run
-- variance should be small next to the difference between arms.
--
-- ★ AND IT INVALIDATES ITS OWN COMPARISON. If the segments do not match on pull
-- count and duration, they were not the same errand and the numbers must not be
-- read as a trend. A harness that can say "this data is not comparable" is worth
-- more than one that always produces a figure.

local ADDON, D = ...

local ARMS = { none = true, count = true, masked = true }
local SAMPLE_EVERY = 1.0
local MAX_ROWS = 3600            -- an hour of seconds; capped is REPORTED

-- Cached at file scope: a global lookup per event is exactly the kind of cost
-- this task exists to measure, so the measurer must not add its own.
local band = (_G.bit and bit.band) or (_G.bit32 and bit32.band)
local TARGET = "UNIT_DIED"
local HOSTILE = _G.COMBATLOG_OBJECT_REACTION_HOSTILE

local frame, payload, arm, seg, rows, t0, acc, capped
local lines, hits, pulls
local kbLast, kbRises, kbDrops, lineLast, rates

-- ---------------------------------------------------------------------
-- The handlers. Deliberately the LEANEST form of each, because measuring a
-- careless handler would answer a question nobody asked.
-- ---------------------------------------------------------------------

-- The cost of being called and nothing else.
local function onCount()
    lines = lines + 1
end

-- The realistic shape: unpack the subevent, compare, return. Only a survivor
-- pays for anything more - `select(8, ...)` for destFlags, then one band.
local function onMasked(...)
    local _, sub = ...
    lines = lines + 1
    if sub == TARGET then
        local dstFlags = select(8, ...)
        if dstFlags and band and HOSTILE and band(dstFlags, HOSTILE) ~= 0 then
            hits = hits + 1
        end
    end
end

local function applyArm(which)
    if not frame then return end
    frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    if which == "count" then
        frame.cleu = onCount
        frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    elseif which == "masked" then
        frame.cleu = onMasked
        frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        frame.cleu = nil          -- `none`: not registered, so not called at all
    end
end

-- ---------------------------------------------------------------------
-- Segments
-- ---------------------------------------------------------------------

-- ★★ THE FIRST RUN'S METRIC WAS BROKEN, AND THIS IS THE FIX.
--
-- `collectgarbage("count")` is heap IN USE, not total allocated. A GC cycle inside
-- a segment therefore makes `kbEnd - kbStart` NEGATIVE regardless of what was
-- allocated - the first live record reported `count = -13248kb`, which is not a
-- number about our handler at all.
--
-- What allocation actually looks like from this vantage is the SUM OF THE RISES
-- between samples: each second the heap grew, it grew because something allocated.
-- The drops are collections and are counted separately rather than subtracted,
-- because a collection tells you the GC ran, not that memory was un-allocated.
--
-- kbStart/kbEnd are kept as raw witnesses, but they are no longer the headline.
local function closeSegment()
    if not seg then return end
    seg.endedAt = date("%Y-%m-%d %H:%M:%S")
    seg.seconds = math.floor((GetTime() - seg.t0) * 10) / 10
    seg.lines, seg.hits, seg.pulls = lines, hits, pulls
    seg.kbEnd = math.floor(collectgarbage("count"))
    seg.kbRaw = seg.kbEnd - seg.kbStart      -- kept, and NOT the metric
    seg.kbAllocated = kbRises                -- ★ the metric: sum of rises
    seg.gcDrops = kbDrops
    seg.kbPerSecond = seg.seconds > 0
        and math.floor(kbRises / seg.seconds * 10) / 10 or 0
    -- Per-second line rate, sorted here so the summary can take percentiles from
    -- it. Rate is what survives an uncomparable run: it does not need the errands
    -- to match, only the arm to have been live.
    seg.rates = rates
    payload.segments[#payload.segments + 1] = seg
    seg = nil
end

local function openSegment(which)
    lines, hits, pulls = 0, 0, 0
    kbRises, kbDrops, lineLast, rates = 0, 0, 0, {}
    kbLast = math.floor(collectgarbage("count"))
    seg = {
        arm = which,
        startedAt = date("%Y-%m-%d %H:%M:%S"),
        t0 = GetTime(),
        kbStart = kbLast,
    }
    applyArm(which)
end

-- ---------------------------------------------------------------------
-- The per-second sampler. One collectgarbage("count") and one row - the same
-- cadence COA_DungeonRun's own travel sampler already runs at.
-- ---------------------------------------------------------------------

local function onUpdate(_, elapsed)
    acc = acc + elapsed
    if acc < SAMPLE_EVERY then return end
    acc = 0
    if capped or not seg then return end
    if #rows >= MAX_ROWS then
        capped = true
        return
    end
    local kb = math.floor(collectgarbage("count"))
    if kbLast then
        local d = kb - kbLast
        if d > 0 then kbRises = kbRises + d
        elseif d < 0 then kbDrops = kbDrops + 1 end
    end
    kbLast = kb

    local perSec = lines - lineLast
    lineLast = lines
    rates[#rates + 1] = perSec

    rows[#rows + 1] = {
        t = math.floor((GetTime() - t0) * 10) / 10,
        a = seg.arm,
        n = lines,          -- cumulative within the segment
        d = perSec,         -- ★ lines THIS second - what the rate is read from
        h = hits,
        p = pulls,
        kb = kb,
    }
end

local function onEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local fn = self.cleu
        if fn then fn(...) end
    elseif event == "PLAYER_REGEN_DISABLED" then
        pulls = pulls + 1
    end
end

-- ★ Is debugprofilestop even advancing? Reported, never assumed - the README's
-- standing warning. Not used for per-event timing; this is a health check on the
-- instrument itself so a future arm can trust or distrust it.
local function calibrateTimer()
    if not _G.debugprofilestop then return { available = false } end
    local a = debugprofilestop()
    for _ = 1, 10000 do debugprofilestop() end
    local b = debugprofilestop()
    return {
        available = true,
        advanced = b > a,
        msPer10kCalls = math.floor((b - a) * 1000) / 1000,
    }
end

D.RegisterTask{
    name = "cleu",
    mode = "session",
    help = "cleu - what a CLEU listener COSTS here: 3 arms (none/count/masked), per-second lines + allocation (st cleu, mark <arm>, sp)",

    start = function(args)
        payload = D.Begin("cleu", args)
        rows, acc, capped, t0 = {}, 0, false, GetTime()
        payload.segments = {}
        payload.rows = rows

        payload.env = {
            hasBitBand = band ~= nil,
            hostileMask = HOSTILE,
            targetSubevent = TARGET,
            sampleEvery = SAMPLE_EVERY,
            timer = calibrateTimer(),
            -- The study's own numbers, carried so the record is self-describing:
            -- the retained buffer read 0 in combat WITH logging on, which is why
            -- this measures the push path and not a buffer walk.
            retainedBufferSeconds = _G.CombatLogGetRetentionTime and CombatLogGetRetentionTime() or nil,
            loggingCombat = _G.LoggingCombat and LoggingCombat() and true or false,
        }

        frame = CreateFrame("Frame")
        frame:RegisterEvent("PLAYER_REGEN_DISABLED")
        frame:SetScript("OnEvent", onEvent)
        frame:SetScript("OnUpdate", onUpdate)

        arm = "none"
        openSegment(arm)
        D.Print("cleu: arm |cffffd100none|r. Run the segment, then /coadump mark count, then masked.")
    end,

    -- Core's `mark` verb. The text IS the arm.
    mark = function(text)
        local which = (text or ""):match("^%s*(%S*)"):lower()
        if not ARMS[which] then
            D.Print("cleu: arm must be none | count | masked (got '" .. tostring(which) .. "')")
            return
        end
        closeSegment()
        arm = which
        openSegment(which)
        D.Print("cleu: arm |cffffd100" .. which .. "|r - run the SAME segment again.")
    end,

    stop = function()
        closeSegment()
        if frame then
            frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            frame:UnregisterEvent("PLAYER_REGEN_DISABLED")
            frame:SetScript("OnUpdate", nil)
            frame:SetScript("OnEvent", nil)
            frame.cleu = nil
        end

        payload.samples = #rows
        payload.capped = capped

        -- ★ THE COMPARABILITY CHECK. Descriptive only - it reports whether the
        -- segments were the same errand, and REFUSES the comparison when they were
        -- not. It draws no conclusion about cost; that happens in the repo.
        local byArm, armList = {}, {}
        for _, s in ipairs(payload.segments) do
            local a = byArm[s.arm]
            if not a then
                a = { arm = s.arm, segments = 0, seconds = 0, lines = 0, hits = 0,
                      pulls = 0, kbAllocated = 0, gcDrops = 0, rates = {} }
                byArm[s.arm] = a
                armList[#armList + 1] = a
            end
            a.segments = a.segments + 1
            a.seconds = a.seconds + (s.seconds or 0)
            a.lines = a.lines + (s.lines or 0)
            a.hits = a.hits + (s.hits or 0)
            a.pulls = a.pulls + (s.pulls or 0)
            a.kbAllocated = a.kbAllocated + (s.kbAllocated or 0)
            a.gcDrops = a.gcDrops + (s.gcDrops or 0)
            for _, r in ipairs(s.rates or {}) do a.rates[#a.rates + 1] = r end
        end

        -- ★ RATE IS WHAT SURVIVES AN UNCOMPARABLE RUN. The first live record was
        -- voided on pull counts, and the per-second rates still answered the
        -- question - they do not need the errands to match, only the arm to have
        -- been live. So they are computed HERE rather than left for a repo-side
        -- script to rediscover.
        for _, a in ipairs(armList) do
            table.sort(a.rates)
            local n = #a.rates
            if n > 0 then
                a.linesPerSecMedian = a.rates[math.floor(n / 2) + 1]
                a.linesPerSecP90 = a.rates[math.max(1, math.floor(n * 0.9))]
                a.linesPerSecPeak = a.rates[n]
            end
            a.kbPerSecond = a.seconds > 0
                and math.floor(a.kbAllocated / a.seconds * 10) / 10 or 0
            a.rates = nil        -- the per-second detail lives in `rows`
        end

        -- Pull count is the comparability key, because it is the one thing that is
        -- the SAME errand by construction and is captured on every arm - `none`
        -- has no line count at all, so lines cannot be the key.
        local pMin, pMax, sMin, sMax
        for _, a in ipairs(armList) do
            if not pMin or a.pulls < pMin then pMin = a.pulls end
            if not pMax or a.pulls > pMax then pMax = a.pulls end
            if not sMin or a.seconds < sMin then sMin = a.seconds end
            if not sMax or a.seconds > sMax then sMax = a.seconds end
        end
        local comparable, why = true, nil
        if #armList < 2 then
            comparable, why = false, "fewer than two arms were run"
        elseif pMin ~= pMax then
            comparable, why = false,
                ("pull counts differ across arms (%d..%d) - not the same errand"):format(pMin, pMax)
        elseif sMax > 0 and (sMax - sMin) / sMax > 0.25 then
            comparable, why = false,
                ("segment durations differ by more than 25%% (%.1fs..%.1fs)"):format(sMin, sMax)
        end

        payload.summary = {
            byArm = armList,
            comparable = comparable,
            notComparableBecause = why,
        }

        -- The summary reports RATES, because totals across unequal segments are
        -- the thing that misleads. kb/s next to lines/s makes the two arms
        -- comparable at a glance even when the segments were not.
        local parts = {}
        for _, a in ipairs(armList) do
            parts[#parts + 1] = ("%s %s/s peak%s %skb/s"):format(
                a.arm, tostring(a.linesPerSecMedian or 0),
                tostring(a.linesPerSecPeak or 0), tostring(a.kbPerSecond))
        end
        local m = byArm.masked
        D.Commit(("cleu: %d sample(s), %d segment(s)%s | %s | mask %s/%s hit | %s")
            :format(payload.samples, #payload.segments, capped and " [CAPPED]" or "",
                    table.concat(parts, " · "),
                    m and m.hits or "-", m and m.lines or "-",
                    comparable and "comparable" or ("NOT COMPARABLE: " .. tostring(why))))
    end,
}
