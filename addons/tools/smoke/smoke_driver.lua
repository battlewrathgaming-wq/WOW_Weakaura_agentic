-- Model: addons/planning/DRIVER_BASIS.md
--
-- ★★★ THE PIPELINE, WALKED END TO END — store → BUCKET → STAGE → SENSOR → a verdict.
--
-- ⚠⚠ THIS IS A USER-STORY WALK, NOT A UNIT SMOKE, and that is the point: `smoke_bucket`,
-- `smoke_sensor` and `smoke_rule` each prove a PART against its own fixtures, and all three
-- can be green while the parts do not JOIN. Every one of them builds its own node shape.
-- ★ This file builds ONE route in the store's shape and lets it fall all the way through.
--
-- ★★ AND HALF OF IT ASSERTS WHAT IS STILL OPEN. Battlewrath, 2026-08-20: *"Make the pipeline
-- where you can. Leave the threads splayed for a design stage."* ⟶ A splayed thread that
-- nothing guards gets tied off by the next person who needs it tied, quietly and by default.

local here = debug.getinfo(1, "S").source:match("@(.*[/\\])") or ""
local Rule = assert(dofile(here .. "../../COA_DungeonRun/rule.lua"))

local Routes
Routes = {
    _r = nil,
    Get = function(id) return Routes._r and Routes._r.id == id and Routes._r or nil end,
    ChildrenOf = function(b) return b.children or {} end,
    -- ★ MIRRORS THE SHIPPED CLAUSE (A2.6): a beacon with no children stands as its
    -- own. ⚠ A stub that disagrees with the client is what hid a defect for four
    -- commits (§457) - so this is derived from the stub's OWN `children`, never a
    -- constant that could drift from the fixture beside it.
    StandsAlone = function(b) return b ~= nil and #(b.children or {}) == 0 end,
    ReachOf = function(x) return x.radius, x.bandUp end,
    RowsOf = function(c) return c.rows or {} end,
}
-- ⚠ THE SHIPPED LISTS, not a permissive stub. A stub looser than the real thing hid a
-- real defect for four commits (§457): BUCKET was gating on the DISPLAY vocabulary, and
-- this stub happened to accept the two words the fixtures used.
local Vocab = assert(dofile(here .. "_vocab.lua"))
Routes.SENSE_WORDS, Routes.ROW_ACTIONS, Routes.ROW_ARG =
    Vocab.SENSE_WORDS, Vocab.ROW_ACTIONS, Vocab.ROW_ARG
Routes.ROW_ARG_RULE, Routes.ARG_MAX = Vocab.ROW_ARG_RULE, Vocab.ARG_MAX

-- ★ THE PLAYER, MOVED BY THE TEST. `Store.Point` is the shipped own-position read and the
-- driver binds the sensor to it — so standing in for the client here is standing in for
-- exactly one function, which is what makes the seam worth having.
local player = { x = 500, y = 500, z = 0, mapID = 33 }
local Store = { Point = function() return { x = player.x, y = player.y, z = player.z,
                                            mapID = player.mapID } end }

local stub = { scripts = {}, made = 0 }
function stub:SetScript(k, fn) self.scripts[k] = fn end

_G.COA_DungeonRun_NS = { Rule = Rule, Routes = Routes, Store = Store }
local NS = _G.COA_DungeonRun_NS
NS.Sensor = assert(dofile(here .. "../../COA_DungeonRun/sensor.lua"))
NS.Bucket = assert(dofile(here .. "../../COA_DungeonRun/bucket.lua"))
local Driver = assert(dofile(here .. "../../COA_DungeonRun/driver.lua"),
                      "driver.lua did not return its table")
NS.Sensor.CreateFrame = function() stub.made = stub.made + 1 return stub end

-- =====================================================================
-- ★★ THE ROUTE, in the STORE's shape — not in any smoke's private node shape.
-- =====================================================================
Routes._r = { id = "R1", mapID = 33, beacons = {
    { id = "b1", stage = 1, kind = "beacon", x = 0, y = 0, z = 0, radius = 5,
      children = {
        { id = "c1", ordinal = 1, x = 100, y = 0, z = 0, radius = 8,
          rows = { { sense = "whenOn", action = "boss", arg = "Ragnaros" } } },
        { id = "c2", x = 200, y = 0, z = 0, radius = 8, bandUp = 4,
          rows = { { sense = "whenOn", action = "boss", arg = "Ragnaros" } } },
        -- ★ STEP 2, and it is the node the whole step-gate row turns on: the player can
        -- WALK PAST IT while standing at step 1, which is the only way the fault shows.
        { id = "c3", ordinal = 2, x = 400, y = 0, z = 0, radius = 8,
          rows = { { sense = "whenOn", action = "boss", arg = "Ragnaros" } } },
    } },
    -- ★ THE CHILDLESS BEACON (A1.2) — its own place, its own reach, its own rows.
    { id = "solo", stage = nil, kind = "beacon", x = 300, y = 0, z = 0, radius = 6,
      children = {}, rows = { { sense = "whenOn", action = "boss", arg = "Ragnaros" } } },
} }

-- =====================================================================
-- ⚠ REFUSAL FIRST — the driver must not swallow BUCKET's reason (row 24).
-- =====================================================================
assert(Driver.Running() == false, "the driver was running before Start")
local ok, why = Driver.Start(99, "R1")
assert(ok == nil and type(why) == "string" and why:find("is for map 33", 1, true),
       "THE DRIVER SWALLOWED BUCKET'S REASON: row 24 makes the refusal LOUD and NAMED, and "
       .. "a Start that turns it into a bare false has undone the row on the way past. "
       .. "got: " .. tostring(why))
assert(Driver.Running() == false, "a refused Start left the driver running")
assert(stub.scripts.OnUpdate == nil,
       "A REFUSED START ARMED THE SENSOR: nothing may be armed on a route that would not "
       .. "build - that is the failure BUCKET exists to catch arriving anyway")

-- =====================================================================
-- ★★★ THE WALK — start, then move the player and read the verdict at each node.
-- =====================================================================
assert(Driver.Start(33, "R1"))
assert(Driver.Running(), "Start did not start")
assert(type(stub.scripts.OnUpdate) == "function", "Start armed nothing")

local s = Driver.Status()
assert(s.loaded == 4, "four nodes were authored, BUCKET loaded " .. tostring(s.loaded))
-- ★★★ A RUN STARTS AT THE ROUTE'S FIRST STAGE, and this row is the one that found the
-- fault. ⚠ The first cut pinned at `Bucket.ALWAYS` on a reading of *"stageless V1"* — which
-- would have handed out ONLY the recovery beacon on every real route, because
-- `Routes.AddBeacon` MINTS a stage for every beacon. ★ No unit smoke could see it: each
-- builds its own node shape, and only a walk over a route in the STORE's shape meets the
-- minted stage at all.
assert(s.stage == 1,
       "A RUN MUST START AT THE ROUTE'S FIRST STAGE, not at stage 0 - stage 0 is *always "
       .. "eligible* (row 10), which is a recovery beacon, not a starting line. got stage "
       .. tostring(s.stage))
-- ⚠ THE TWO PINS SIT TOGETHER, AND BEFORE ANYTHING ABOUT THE HAND-OUT'S CONTENTS.
-- Mutation pinned the STEP at the pass-through and was caught by *"stage 1's step 1 was not
-- handed out"* - true, and a description of the SYMPTOM rather than the pin. ★ Eighth
-- instance this week: the general row was simply EARLIER, which is all it takes.
assert(s.step == 1,
       "A RUN MUST START AT THE STAGE FIRST STEP, not at the pass-through. Step 0 is the "
       .. "PASS-THROUGH - always checked - which is not the same as being first in the "
       .. "sequence. got " .. tostring(s.step))
-- ⚠ NAMED BEFORE COUNTED, and mutation is why AGAIN: dropping stage 0 from the hand-out
-- breaks it at START, not only after an advance, so the count below answered for a fault it
-- does not name. ★ Seventh instance this week of specific-behind-general.
local function armedHas(addr)
    local a = NS.Sensor.Armed()
    for _, n in ipairs(a and a.nodes or {}) do
        if n.address == addr then return true end
    end
    return false
end
assert(armedHas("33:R1:solo"),
       "STAGE 0 WAS NOT IN THE FIRST HAND-OUT: row 23 - *hand the current stage's bucket, "
       .. "WITH stage 0*. The recovery beacon must be reachable from the moment the run "
       .. "starts, not only after an advance")
assert(armedHas("33:R1:b1:c1"), "STAGE 1's STEP 1 WAS NOT HANDED OUT")
assert(armedHas("33:R1:b1:c2"),
       "THE PASS-THROUGH WAS NOT HANDED OUT: c2 has no ordinal, so *its ordinal is not "
       .. "constructed* and it is checked at every step")

-- ★★★ AND STEP 2 IS BOUNCED AT STEP 1. This is the row the whole gate exists for.
-- Battlewrath: *"if it's checking every step in a ordinal, it can complete every ordinal.
-- Which is counter to what the ordinal gating is. **It's a position in a sequence.**"*
assert(not armedHas("33:R1:b1:c3"),
       "A FUTURE STEP WAS ARMED AT STEP 1: with step 2 in the hand-out a player who walks "
       .. "past it COMPLETES it, and the ordinal stops being a position in a sequence. "
       .. "⚠ §435 handed out every step of the current stage and no fixture reached one out "
       .. "of order, so nothing could see it")

assert(s.armed == 3,
       "STAGE 1 AT STEP 1 HANDS OUT step 1, the pass-through, and stage 0's lone beacon - "
       .. "NOT step 2. got " .. tostring(s.armed))

-- ★★★ THE WALK GOES THROUGH THE FRAME'S OnUpdate, not through `Poll` by hand.
--
-- ⚠⚠ It did not at first: it called `Sensor.Poll(Driver.Sample())` directly, and mutation
-- proved the cost - deleting `Sensor.Sample = Driver.Sample` from `Start` SURVIVED, because
-- nothing in the walk ever read that binding. ★ **The walk bypassed the one seam it exists
-- to prove.** A user-story walk that reaches past the runtime path is a unit test with
-- extra steps.
-- ⟶ Now it drives the real handler: accumulator → `Sensor.Sample()` → `Poll` → `NextIn`.
-- The elapsed is `POLL_MAX` so the accumulator always fires on the first tick.
assert(NS.Sensor.Sample == Driver.Sample,
       "START DID NOT BIND THE SAMPLER: the sensor must not reach for the client itself - "
       .. "it is graded offline - so the driver hands it the own-position read")

local lastFired
local function tick()
    lastFired = nil
    local realPoll = NS.Sensor.Poll
    NS.Sensor.Poll = function(s) lastFired = realPoll(s) return lastFired end
    stub.scripts.OnUpdate(stub, NS.Sensor.POLL_MAX)
    NS.Sensor.Poll = realPoll
    return lastFired or {}
end

local function walkTo(x, y, z)
    -- ⚠ OUT, THEN IN. Under the transition contract a sample at the same place as the last
    -- one reports NOTHING, so a probe that did not leave first would grade silence.
    player.x, player.y, player.z = 90000, 90000, 0
    tick()
    player.x, player.y, player.z = x, y, z or 0
    return tick()
end

-- ★ A11.3e: `Poll` returns CHANGE RECORDS now, so "what fired" is the set of `whenOn`
-- addresses. ⚠ `walkTo` teleports the player OUT first, so each probe is a real ARRIVAL
-- rather than a second sample at the same place - which under a transition contract
-- reports nothing at all, correctly.
local function firedAt(list)
    local out = {}
    for _, c in ipairs(list or {}) do
        if c.word == NS.Sensor.WHEN_ON then out[#out + 1] = c.address end
    end
    table.sort(out)
    return table.concat(out, ",")
end

assert(firedAt(walkTo(500, 500)) == "",
       "A NODE FIRED FROM 500 YARDS AWAY")
assert(firedAt(walkTo(100, 0)) == "33:R1:b1:c1",
       "THE FIRST STEP DID NOT FIRE WHERE THE AUTHOR PLACED IT: the player is standing on "
       .. "c1's exact position. got: " .. firedAt(walkTo(100, 0)))
assert(firedAt(walkTo(200, 0)) == "33:R1:b1:c2", "the second step did not fire")

-- ★★ THE CHILDLESS BEACON FIRES ON ITSELF, ADDRESSED `BID:` WITH NO CID.
-- Battlewrath, 2026-08-20: *"it'll terminate as `BID:` where a child is `BID:CID`."*
assert(firedAt(walkTo(300, 0)) == "33:R1:solo",
       "THE CHILDLESS BEACON DID NOT FIRE ON ITSELF, or it invented a CID: A1.2 makes it "
       .. "RUNNABLE and `cid` is optional (contract.lua:63). got: " .. firedAt(walkTo(300, 0)))

-- ★ THE BAND IS ONE-SIDED AND THE DEFAULT REACHED THE VERDICT. c1 never had a band
-- authored, so BUCKET supplied 2.5 (row 27) — the only reason it fires at all, since the
-- rule REFUSES a nil band (A11.2h). Below the node is out; 2 yd above is in; 9 is not.
assert(firedAt(walkTo(100, 0, 2)) == "33:R1:b1:c1", "2 yd above an unpicked band must fire")
assert(firedAt(walkTo(100, 0, 9)) == "",
       "9 YD ABOVE AN UNPICKED BAND FIRED: BUCKET's default is 2.5, not open")
assert(firedAt(walkTo(100, 0, -2)) == "",
       "BELOW THE NODE FIRED: the band is UPWARD ONLY (RI-22) - a captured sample IS the "
       .. "floor, so a player under a walkway is not at a beacon standing on it")
-- ★ AND c2's AUTHORED 4 SURVIVES THE PIPELINE, which is the row that proves the default is
-- for ABSENCE rather than a blanket.
assert(firedAt(walkTo(200, 0, 3)) == "33:R1:b1:c2", "an authored band of 4 must admit 3 yd")

-- ★★ WALKED, NOT JUST COUNTED: standing exactly on step 2 while at step 1 fires NOTHING.
-- ⚠ The armed-set row above proves the hand-out; this proves the CONSEQUENCE, which is the
-- thing that would have been wrong in the client.
assert(firedAt(walkTo(400, 0)) == "",
       "STEP 2 FIRED WHILE THE RUN WAS AT STEP 1: the player is standing exactly on it. "
       .. "An ordinal is a POSITION IN A SEQUENCE - reaching a later one early must not "
       .. "complete it")

-- ★ AND IT FIRES ONCE THE RUN IS THERE, so the row grades the GATE and not the geometry.
-- ⚠ THE SWAP'S EXISTENCE IS ASSERTED HERE, AT ITS FIRST USE, not in the splayed-thread
-- section below. Mutation deleted `Designate` and the walk CRASHED on this line - *attempt
-- to call field 'Designate' (a nil value)* - before the row that names it was ever reached.
-- ★ A test that crashes has not caught anything; it has gone red without saying why.
assert(type(Driver.Designate) == "function",
       "THE SWAP IS GONE: rows 23 and 26 rule it completely - hand out the stage WITH stage "
       .. "0, and swap rather than rebuild. It is the RAISER that is unowned, not this")
Driver.Designate(1, 2)
assert(Driver.Status().step == 2, "Designate did not take the step")
assert(firedAt(walkTo(400, 0)) == "33:R1:b1:c3",
       "STEP 2 DID NOT FIRE AT STEP 2: without this the row above would pass on a node that "
       .. "simply never fires, which proves nothing about the gate")
assert(firedAt(walkTo(100, 0)) == "",
       "STEP 1 STILL FIRED AT STEP 2: a step already passed must not be re-armed, or it can "
       .. "complete twice")
assert(firedAt(walkTo(200, 0)) == "33:R1:b1:c2",
       "THE PASS-THROUGH STOPPED BEING CHECKED after an advance: step 0 is checked at EVERY "
       .. "step, which is what *its ordinal is not constructed* means")
Driver.Designate(1, 1)

-- ★ THE THROTTLE IS LIVE ON REAL BUCKETED NODES, not just on fixtures.
player.x, player.y, player.z = 100, 0, 0
assert(NS.Sensor.NextIn(Driver.Sample()) == NS.Sensor.POLL_MIN,
       "standing on a node must poll at the floor")
player.x = 100000
assert(NS.Sensor.NextIn(Driver.Sample()) == NS.Sensor.POLL_MAX,
       "100000 yd out must poll at the base rate")

-- =====================================================================
-- ★★ STOP LEAVES NOTHING RUNNING (S9), INCLUDING THE SAMPLER SEAM.
-- =====================================================================
Driver.Stop()
assert(Driver.Running() == false and Driver.Status() == nil, "Stop did not stop")
assert(stub.scripts.OnUpdate == nil, "STOP LEFT THE OnUpdate INSTALLED")
assert(NS.Sensor.Sample == nil,
       "STOP LEFT THE SAMPLER BOUND: a live sampler on a disarmed sensor is the same half- "
       .. "state as a persistent OnUpdate that checks a flag. S9's criterion is 'nothing "
       .. "armed, nothing RUNNING'")

-- =====================================================================
-- ★★★ THE SPLAYED THREADS — asserted OPEN, so tying one off is deliberate.
--
-- ⚠⚠ THE WHOLE REASON THIS SECTION EXISTS: an open thread that nothing guards gets tied by
-- whoever next needs it tied, quietly, with a default nobody ruled. Each row below names
-- the item that owns the decision.
-- =====================================================================
assert(NS.Bucket.Resolve == nil,
       "THE ACTION-BINDING SEAM WAS FILLED: row 25 wants each action id resolved to *the "
       .. "function the runtime holds*, and the runtime holds NONE - adaptor.lua is a "
       .. "vocabulary. Binding one here would be inventing the consumer's HANDLING, which "
       .. "the fence puts outside this lane")

assert(Driver.Advance == nil and Driver.OnComplete == nil and Driver.Complete == nil,
       "THE DRIVER GREW A RAISER: what decides a stage has advanced is RI-38's open "
       .. "question, and an advance needs a COMPLETION to raise it - which is not the "
       .. "sensor's today (G8). ⚠ The sensor cannot be the raiser without a loop: its own "
       .. "output would change its own input, which model row 26 forbids in those words")

-- ★ DESIGNATE IS BUILT AND UNCALLED, and both halves are asserted. A thread pinned at one
-- end is not the same as a thread cut: the SWAP is fully ruled (rows 23, 26) and only its
-- RAISER is unowned, so the function exists and nothing reaches it.
-- ★ (the swap's EXISTENCE is asserted at its first use, above - a crash there would beat
-- any row written down here.)
assert(Driver.Start(33, "R1"))
local before = Driver.Status().stage
for _ = 1, 20 do walkTo(100, 0) end
assert(Driver.Status().stage == before,
       "THE STAGE MOVED ON ITS OWN: twenty polls fired a node twenty times and nothing may "
       .. "advance off that. Completion is not built (G8) and the raiser is unowned (RI-38)")

-- ★ AND WHEN IT IS CALLED BY HAND IT SWAPS, so the second sequence is proven runnable
-- without anything having been wired to raise it.
Driver.Designate(1)
assert(Driver.Status().stage == 1, "Designate did not take")
-- ⚠ THE NAMED ROW BEFORE THE COUNT, for the sixth time this week. A count answers for
-- every way the number can be wrong and names none of them.
assert(firedAt(walkTo(300, 0)) == "33:R1:solo",
       "THE STAGELESS BEACON STOPPED BEING REACHABLE AFTER AN ADVANCE: stage 0 is in EVERY "
       .. "hand-out (row 23), which is the whole point of a recovery beacon")
assert(Driver.Status().armed == 3,
       "stage 1's hand-out is its two children PLUS stage 0's lone beacon (row 23), got "
       .. tostring(Driver.Status().armed))
Driver.Stop()

print("smoke_driver: OK - store to verdict in one walk; refusals survive the join; "
      .. "the swap runs and nothing raises it")
