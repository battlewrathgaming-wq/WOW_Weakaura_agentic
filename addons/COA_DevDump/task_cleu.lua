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

local function closeSegment()
    if not seg then return end
    seg.endedAt = date("%Y-%m-%d %H:%M:%S")
    seg.seconds = math.floor((GetTime() - seg.t0) * 10) / 10
    seg.lines, seg.hits, seg.pulls = lines, hits, pulls
    seg.kbEnd = math.floor(collectgarbage("count"))
    seg.kbDelta = seg.kbEnd - seg.kbStart
    payload.segments[#payload.segments + 1] = seg
    seg = nil
end

local function openSegment(which)
    lines, hits, pulls = 0, 0, 0
    seg = {
        arm = which,
        startedAt = date("%Y-%m-%d %H:%M:%S"),
        t0 = GetTime(),
        kbStart = math.floor(collectgarbage("count")),
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
    rows[#rows + 1] = {
        t = math.floor((GetTime() - t0) * 10) / 10,
        a = seg.arm,
        n = lines,
        h = hits,
        p = pulls,
        kb = math.floor(collectgarbage("count")),
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
                a = { arm = s.arm, segments = 0, seconds = 0, lines = 0, hits = 0, pulls = 0, kbDelta = 0 }
                byArm[s.arm] = a
                armList[#armList + 1] = a
            end
            a.segments = a.segments + 1
            a.seconds = a.seconds + (s.seconds or 0)
            a.lines = a.lines + (s.lines or 0)
            a.hits = a.hits + (s.hits or 0)
            a.pulls = a.pulls + (s.pulls or 0)
            a.kbDelta = a.kbDelta + (s.kbDelta or 0)
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

        local c, m = byArm.count, byArm.masked
        D.Commit(("cleu: %d sample(s), %d segment(s)%s | count=%s lines / %skb | masked=%s lines, %s hit(s) / %skb | %s")
            :format(payload.samples, #payload.segments, capped and " [CAPPED]" or "",
                    c and c.lines or "-", c and c.kbDelta or "-",
                    m and m.lines or "-", m and m.hits or "-", m and m.kbDelta or "-",
                    comparable and "comparable" or ("NOT COMPARABLE: " .. tostring(why))))
    end,
}
