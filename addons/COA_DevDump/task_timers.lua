-- COA_DevDump task_timers.lua - DOES `C_Timer` KEEP TIME?
--
-- ---------------------------------------------------------------------------
-- ★★★ THE QUESTION. `COA_DungeonRun` samples position from an `OnUpdate`
-- accumulator at 1 Hz. Moving it to a `C_Timer` bounce was decided on ONE
-- argument that holds - jobs on a single clock are SEQUENCED, so two samplers
-- cannot land in the same frame - and one that does not:
--
--   Battlewrath: *"The 'doesn't race' isn't proven. If C_Timer can defer under load."*
--
-- ⚠ `operations/ROUTER.md` records that `C_Timer` EXISTS and works. It says
-- nothing about DELIVERY.
--
-- ---------------------------------------------------------------------------
-- ★★★ WHY BOTH AT ONCE, AND WHY A CODED SCHEDULE
--
-- His design, and both halves of it are load-bearing:
--
--   *"Our test is just on the two timers. Situation isn't needed. Normal place.
--    GT on them both. Even at the same time."*
--
-- ★ SAME FRAMES, SAME LOAD, SAME SECOND - so any difference between the two
-- sequences IS the mechanism. A before/after across two runs compares two
-- SITUATIONS and calls the difference a finding.
--
--   *"A pattern... 1,1,1,3,3,1,1,1,3,3,3,5,10,5,3,3,3,1,1,1,3,3,1,1,1.
--    If it's just 1 sec all the way through, we don't know which 1 is landing
--    in response to which call."*
--
-- ★★★ A CONSTANT INTERVAL IS UNREADABLE. Every tick looks like every other, so
-- a 2-second gap could be a defer, a drop, or two fires that merged - and
-- nothing in the record separates them. A varying schedule gives each tick a
-- DISTINCTIVE expected delta: the pattern is a barcode, and damage to it says
-- WHERE.
--
-- ---------------------------------------------------------------------------
-- ⚠⚠ BOTH RUN RAW. NOTHING IS NORMALISED TO MAKE THE COMPARISON FAIR.
--
-- ★ I first wrote the accumulator as `acc = acc - want`, calling `capture.lua`'s
-- `acc = 0` a bias to exclude. It is not a bias, it is a POLICY - and it is the
-- one his prediction rests on:
--
--   *"I see the frame driven one to see the biggest time-delays measurable as
--    response. As it doesn't try to maintain. It distorts purely as the time does."*
--
-- ⚠ `acc = 0` DISCARDS THE REMAINDER, so no debt is carried: it never bursts,
-- and it never catches up. Its lateness IS a readout of what the frame loop did.
-- `acc = acc - want` carries the debt and would have made the control behave like
-- the thing it is meant to be compared against.
--
-- ★★★ HIS RULE, AND IT IS THE WHOLE METHOD: *"I wouldn't fit the detection. We
-- want to see how both perform raw."* So the accumulator is EXACTLY what
-- capture.lua runs today, and C_Timer is exactly what it is. What we have,
-- against what we would move to - not two idealised mechanisms.
--
-- ---------------------------------------------------------------------------
-- THE OUTCOMES, NAMED BEFORE THE RUN (planning/timed_breakdown_scope.md §213)
--
--   HONOURED    observed tracks requested. 1s is 1s, 10s is 10s.
--   FLOORED     ★ his hypothesis - everything collapses to one interval
--               regardless of what was asked. The barcode returns flat.
--   QUANTISED   the same small POSITIVE error at every magnitude - rounded to a
--               frame boundary, about 11ms at 90fps.
--   DEFERRED    error grows with load, no fixed size. ⚠ A long gap FOLLOWED BY a
--               short one is a CATCH-UP BURST, the one outcome that argues
--               against the whole design.
--
-- ★★★ AND THE `OnUpdate` COLUMN SEPARATES THE CLIENT FROM THE CLOCK. If both
-- distort in the same second the frame loop was busy and neither is at fault.
-- Without the control every result is attributable to "the city was busy".
-- ---------------------------------------------------------------------------

local ADDON, D = ...
if not D or not D.RegisterTask then return end

-- His set, verbatim. 25 ticks, 62 seconds a pass.
local PATTERN = { 1, 1, 1, 3, 3, 1, 1, 1, 3, 3, 3, 5, 10, 5, 3, 3, 3, 1, 1, 1, 3, 3, 1, 1, 1 }

local payload, frame, running
local ticks, t0
local accIdx, acc, accLast, accPass  -- the OnUpdate walker
local timIdx, timLast               -- the C_Timer walker
local generation                    -- ⚠ see stop()

local function total()
    local n = 0
    for i = 1, #PATTERN do n = n + PATTERN[i] end
    return n
end

-- One row per fire, from either mechanism. `error` is the whole finding.
local function record(which, idx, pass, requested, now, last)
    ticks[#ticks + 1] = {
        m = which,
        i = idx,
        pass = pass,
        req = requested,
        gt = now,
        d = last and (now - last) or nil,
        err = last and ((now - last) - requested) or nil,
    }
end

-- ---------------------------------------------------------------------
-- A: the OnUpdate accumulator - the control, and what capture.lua uses
-- ---------------------------------------------------------------------
local function onUpdate(_, elapsed)
    if not running then return end
    acc = acc + elapsed
    local want = PATTERN[accIdx]
    if acc < want then return end
    -- ⚠ ZERO, do not subtract. See the header - this is capture.lua's real
    -- behaviour, and NOT carrying the debt is the property being measured.
    acc = 0
    local now = GetTime()
    record("onupdate", accIdx, accPass, want, now, accLast)
    accLast = now
    accIdx = accIdx + 1
    -- ⚠ The pass counter is its OWN variable. Deriving it from a WRAPPING index
    -- returns 1 forever, which would have made every pass look like the first -
    -- and pass-1-against-pass-4 is the whole reason for running more than once.
    if accIdx > #PATTERN then accIdx, accPass = 1, accPass + 1 end
end

-- ---------------------------------------------------------------------
-- B: the C_Timer bounce - self-rescheduling, one entry at a time
-- ---------------------------------------------------------------------
local timerPass, timerCount
local function bounce(gen)
    -- ⚠ An `After` CANNOT BE CANCELLED, so a stale chain from a previous session
    -- would keep writing into the next one's payload. The generation token is the
    -- only thing that stops it: a callback from an old run simply returns.
    if not running or gen ~= generation then return end
    local now = GetTime()
    local want = PATTERN[timIdx]
    record("ctimer", timIdx, timerPass, want, now, timLast)
    timLast = now
    timerCount = timerCount + 1
    timIdx = timIdx + 1
    if timIdx > #PATTERN then timIdx, timerPass = 1, timerPass + 1 end
    C_Timer.After(PATTERN[timIdx], function() bounce(gen) end)
end

D.RegisterTask{
    name = "timers",
    mode = "session",
    help = "timers - does C_Timer keep time? OnUpdate vs C_Timer on ONE coded schedule, both at once (st timers, sp)",

    start = function(args)
        if not C_Timer or not C_Timer.After then
            D.Print("|cffff5555timers: C_Timer.After is absent|r - which is itself the answer.")
            return
        end

        payload = D.Begin("timers", args)
        ticks, t0 = {}, GetTime()
        generation = (generation or 0) + 1

        payload.pattern = PATTERN
        payload.passSeconds = total()
        payload.ticks = ticks
        payload.env = {
            -- ★ The record says what was measured, so a reader never has to guess.
            accumulatorZeroes = true,     -- acc = 0, exactly as capture.lua does
            normalised = false,           -- nothing fitted on either side
            startedAt = t0,
            framerate = GetFramerate and GetFramerate() or nil,
        }

        accIdx, acc, accLast, accPass = 1, 0, nil, 1
        timIdx, timLast, timerPass, timerCount = 1, nil, 1, 0

        frame = frame or CreateFrame("Frame")
        frame:SetScript("OnUpdate", onUpdate)
        running = true

        local gen = generation
        C_Timer.After(PATTERN[1], function() bounce(gen) end)

        D.Print(("timers: running. %d ticks, %ds a pass - a few passes is a few minutes. |cffffd100/coadump sp|r when done.")
            :format(#PATTERN, total()))
    end,

    stop = function()
        running = false
        generation = generation + 1      -- orphans any in-flight After
        if frame then frame:SetScript("OnUpdate", nil) end

        local a, c = 0, 0
        for i = 1, #ticks do
            if ticks[i].m == "onupdate" then a = a + 1 else c = c + 1 end
        end
        payload.counts = { onupdate = a, ctimer = c }
        payload.ranFor = GetTime() - t0

        D.Print(("timers: %d onupdate, %d ctimer, %.0fs. Pull it."):format(a, c, payload.ranFor))
    end,
}
