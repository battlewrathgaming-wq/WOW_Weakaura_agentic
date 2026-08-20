-- Model: addons/planning/DRIVER_BASIS.md · construction is `driver_data_model.md` §A5b
--
-- ★★★ THE PIPELINE — `Bucket.Build` → `Bucket.Stage` → `Sensor.Arm`, end to end.
--
-- Battlewrath, 2026-08-20: *"Make the pipeline where you can. **Leave the threads splayed for
-- a design stage.**"*
--
-- ⚠⚠ SO THIS FILE JOINS WHAT IS BUILT AND FILLS NOTHING THAT IS OWED. Every open thread
-- below is left NAMED and REACHABLE rather than defaulted quietly — a default is a decision
-- taken by whoever wrote it, and these are the designer's. `smoke_driver` asserts each one
-- is still open, so filling one has to be deliberate.
--
--     ✅ BUILT      construction (rows 23-27) · the hand-out · the pure rule · the sensor
--     ⚠ SPLAYED    who raises a stage advance (RI-38) · completion (G8) · action binding
--                  (row 25's seam) · the run's own lifecycle
--
-- ★ WHAT MAKES THE PIPELINE RUNNABLE WITHOUT THE DESIGNATOR is that a run's STARTING stage
-- is not in question — it is the route's first — while what ADVANCES it is. ⟶ The thread is
-- not cut, it is pinned at one end.
--
-- ⚠⚠ AND THIS HEADER FIRST SAID SOMETHING ELSE: *"V1 IS STAGELESS (A11.5a) … the current
-- stage is a CONSTANT."* `A11.5a` does say *"V1 has no stage"* — but `Routes.AddBeacon` MINTS
-- one for every beacon, so a pin at 0 would have handed out ONLY the recovery beacon on every
-- real authored route. ★ The doc and the code disagree; the bench REPORTS that (RI-39) and
-- `Bucket.FirstStage` derives the pin from the bucket so it is right under either reading.

local NS = select(2, ...)
NS = NS or _G.COA_DungeonRun_NS or {}
if select(2, ...) == nil then _G.COA_DungeonRun_NS = NS end

local Driver = {}
NS.Driver = Driver

local state = nil

-- ⚠ A SEAM THE DRIVER OWNS, because the sensor must not reach for the client itself. The
-- sensor is graded offline against fixtures; a direct `GetCurrentPlayerPosition` in it would
-- make that impossible. ★ `Store.Point()` is the shipped own-position read and already
-- returns WORLD `x, y, z, mapID` — which is exactly the sample shape A11.1a rules
-- (*"WORLD, never MAP xy"*). Nothing is adapted or renamed.
function Driver.Sample()
    local Store = NS.Store
    return Store and Store.Point and Store.Point() or nil
end

-- =====================================================================
-- ★★ START — the whole chain, and it refuses exactly where BUCKET refuses.
--
-- ⚠ Row 24: BUCKET may fail and should fail LOUDLY. This function's only job on the failure
-- path is to NOT SWALLOW the reason — it returns it unchanged, because a driver that turns
-- *"route R1 is for map 33, not 99"* into `false` has undone the row.
-- =====================================================================
function Driver.Start(mapID, rid)
    local Bucket, Sensor = NS.Bucket, NS.Sensor
    if not Bucket or not Sensor then return nil, "the driver is not loaded" end
    Driver.Stop()

    local bucket, why = Bucket.Build(mapID, rid)
    if not bucket then return nil, why end

    -- ★★ THE DESIGNATOR, PINNED AT THE BUCKET'S FIRST STAGE. **This is the line RI-38 is
    -- about**: what replaces the pin is a load-condition layer with one input, and the layer
    -- is unowned. The pin answers only *where a run starts*, which is the beginning.
    --
    -- ⚠⚠ IT IS DERIVED, NOT CHOSEN, and that is deliberate: `A11.5a` says *"V1 has no
    -- stage"* while `Routes.AddBeacon` MINTS one for every beacon. The bench must not resolve
    -- that (*"don't mutate code from doc disagreement"*), so `Bucket.FirstStage` reads what is
    -- actually in the bucket and is right under either reading — all of a stageless route,
    -- or stage 1 plus stage 0 of a staged one.
    -- ★ A first cut pinned at `Bucket.ALWAYS` on the strength of *"stageless V1"* and would
    -- have handed out ONLY the recovery beacon on every real authored route. The walk caught
    -- it; no unit smoke could have, because each builds its own node shape.
    state = { bucket = bucket, stage = Bucket.FirstStage(bucket), mapID = mapID, rid = rid }

    Sensor.Sample = Driver.Sample
    Sensor.Arm(Bucket.Stage(bucket, state.stage))
    return true, nil
end

function Driver.Stop()
    local Sensor = NS.Sensor
    if Sensor then
        Sensor.Disarm()
        -- ⚠ THE SEAM IS CLEARED TOO, not just the arming. S9's criterion is "nothing armed,
        -- nothing RUNNING" — leaving a live sampler bound to a disarmed sensor is the same
        -- half-state as a persistent OnUpdate that checks a flag.
        Sensor.Sample = nil
    end
    state = nil
end

function Driver.Running() return state ~= nil end

-- =====================================================================
-- ★★★ DESIGNATE — the SECOND SEQUENCE (rows 23, 26). Built, and deliberately UNCALLED.
--
-- ⚠⚠ THIS IS A SPLAYED THREAD, NOT HALF-FORMED CODE, and the difference is worth stating
-- because the two look alike. The SWAP is fully specified — row 23 (*"hand the current
-- stage's bucket, WITH stage 0"*) and row 26 (*"a stage advance SWAPS buckets; it does not
-- rebuild"*). What is unowned is the RAISER: what decides an advance has happened.
--
-- ★ RI-38, and the prior art agrees: WeakAuras separates these absolutely — a dedicated
-- `loadFrame` decides who is loaded, and the hot path only indexes what it produced. **The
-- sensor cannot be the raiser without a loop**, because its own output would change its own
-- input; row 26 forbids that in those words.
--
-- ⚠ AND AN ADVANCE NEEDS A COMPLETION TO RAISE IT, which is not the sensor's today (G8).
-- So nothing calls this, and `smoke_driver` asserts nothing does.
-- =====================================================================
function Driver.Designate(stage)
    local Bucket, Sensor = NS.Bucket, NS.Sensor
    if not state or not Bucket or not Sensor then return nil end
    state.stage = stage
    -- ⚠ Row 26: AFTER a poll returns, never inside one. `Arm` replaces the armed set
    -- wholesale, so calling this from inside `Poll` would mutate the list being walked.
    Sensor.Arm(Bucket.Stage(state.bucket, stage))
    return stage
end

-- ★ WHAT THE DRIVER CAN HONESTLY REPORT TODAY. ⚠ Deliberately thin: A11.5 is the READOUT
-- and it is not built, so this reports STRUCTURE (what was loaded, what is armed) and makes
-- no claim about progress — there is no completion to have progressed through.
function Driver.Status()
    if not state then return nil end
    local Sensor = NS.Sensor
    return {
        mapID = state.mapID, rid = state.rid,
        stage = state.stage,
        loaded = state.bucket.count,
        armed = Sensor and Sensor.Armed() and #Sensor.Armed().nodes or 0,
    }
end

return Driver
