-- Model: addons/planning/DRIVER_BASIS.md · graded by driver_manager_acceptance.md A12
--
-- ★★★ THE ROUTE MANAGER, on SYNTHETIC ROWS - which is the method, not a shortcut.
-- `driver_architecture.md` §7 (his word, AL-12): *the bench PROVES on synthetic rows,
-- not A/B in the client.* So every client-facing edge here is a SEAM with a double
-- behind it, and the doubles record what was asked of them.

local here = debug.getinfo(1, "S").source:match("@(.*[/\\])") or ""
local Rule = assert(dofile(here .. "../../COA_DungeonRun/rule.lua"))
local Sensor = assert(dofile(here .. "../../COA_DungeonRun/sensor.lua"))

-- ⚠⚠ THE SHIPPED VOCABULARY, READ NOT COPIED (§458). A stub looser than the client is
-- what hid §457 for four commits, and a stub fixed by COPYING drifted the next day.
local Vocab = assert(dofile(here .. "_vocab.lua"))

local chat = {}
local Routes
Routes = {
    _r = nil, _list = {},
    Get = function(id) return Routes._r and Routes._r.id == id and Routes._r or nil end,
    List = function(mapID)
        local out = {}
        for _, r in ipairs(Routes._list) do if r.mapID == mapID then out[#out + 1] = r end end
        return out
    end,
    ChildrenOf = function(b) return b.children or {} end,
    ReachOf = function(x) return x.radius, x.bandUp end,
    RowsOf = function(c) return c.rows or {} end,
    SENSE_WORDS = Vocab.SENSE_WORDS,
    ROW_ACTIONS = Vocab.ROW_ACTIONS,
    ROW_ARG = Vocab.ROW_ARG,
    ROW_ARG_RULE = Vocab.ROW_ARG_RULE,
    ARG_MAX = Vocab.ARG_MAX,
    IsPosition = Vocab.IsPosition,
    LedTo = Vocab.LedTo,
}

-- ★ THE ONE SAVED SLOT, mirrored by name and arity so a signature change over in
-- `store.lua` fails HERE rather than being absorbed (A12.9a).
-- ⚠⚠ IT MODELS A SLOT, NOT A WRITE COUNTER, and mutation is why. The first cut counted
-- writes, so `G13` - terminal CLEARING the selection - was caught by the count row three
-- blocks earlier and the row that exists to say *"the selection survived"* never ran.
-- ★ A12.9a's claim is about the STORE'S SHAPE: one slot, overwritten, never appended. A
-- second write of the same value violates nothing, so counting writes graded a property
-- the row never asserted - and answered for the one it did.
local Store = { _slots = {} }
function Store.SetSelectedRoute(rid) Store._slots.selected = rid end
function Store.SelectedRoute() return Store._slots.selected end
local function slotCount()
    local n = 0
    for _ in pairs(Store._slots) do n = n + 1 end
    return n
end

-- ★★ THE STUB FALLS THROUGH TO THE SHIPPED VOCABULARY for anything it does not
-- define itself. ⚠ The explicit entries above still WIN - `Get`, `List`, `RowsOf`
-- and friends must be the stub's - but a pure-vocabulary helper the stub never
-- thought about (§486: `TriggerOf`) resolves instead of silently reading nil and
-- turning a guard off.
setmetatable(Routes, { __index = Vocab })
local NS = { Rule = Rule, Sensor = Sensor, Routes = Routes, Store = Store }
NS.Say = function(msg) chat[#chat + 1] = msg end
_G.COA_DungeonRun_NS = NS

local Bucket = assert(dofile(here .. "../../COA_DungeonRun/bucket.lua"))
NS.Bucket = Bucket
local Manager = assert(dofile(here .. "../../COA_DungeonRun/manager.lua"),
                       "manager.lua did not return its table")

-- ---------------------------------------------------------------------
-- FIXTURES
-- ---------------------------------------------------------------------
local function row(sense, action, arg) return { sense = sense, action = action, arg = arg } end
-- ⚠⚠ THESE COPY WHAT THEY ARE GIVEN AND FILL DEFAULTS - they do NOT list fields.
--
-- ★ THIRD INSTANCE IN ONE DAY of a hand-listed copy losing a field in silence:
-- `_vocab.lua` (a table nobody exported), `sensor.lua`'s `snapshot` (`lone` and `ledTo`),
-- and then THIS - a fixture written as `child({ nextType = "set" })` had its `nextType`
-- dropped by the builder, so the assertion failed against code that was correct.
-- ⟶ A hand-kept list of things to carry is itself the thing that gets forgotten.
local function child(t)
    local c = {}
    for k, v in pairs(t) do c[k] = v end
    c.x, c.y, c.z = t.x or 0, t.y or 0, t.z or 0
    c.radius = t.radius or 5
    c.rows = t.rows or { row("whenOn", "note", "here") }
    return c
end
local function beacon(t)
    local b = {}
    for k, v in pairs(t) do b[k] = v end
    b.id, b.kind = t.id or "b1", "beacon"
    b.x, b.y, b.z = t.x or 0, t.y or 0, t.z or 0
    b.radius = t.radius or 5
    b.rows = t.rows or { row("whenOn", "note", "here") }
    return b
end
local function route(id, mapID, beacons)
    local r = { id = id, mapID = mapID, beacons = beacons }
    Routes._r = r
    Routes._list = { r }
    return r
end

-- ★ THE TRACKER DOUBLE - and it RECORDS, because A12.3c's whole claim is about WHICH
-- node the arrow got, not that a write happened.
local track = { pointed = {}, parked = 0 }
Manager.Tracker = {
    Point = function(node) track.pointed[#track.pointed + 1] = node.address end,
    Park = function() track.parked = track.parked + 1 end,
}

local ran = {}
local function bindAll(mode)
    Manager.ClearBindings()
    for _, w in ipairs(Vocab.ROW_ACTIONS) do
        Manager.Bind(w, function(ctx)
            ran[#ran + 1] = ctx.address .. "|" .. ctx.word .. "|" .. w
            if mode == "pending" and w == "boss" then
                -- A12.4c's case: the tab arms something and finishes later.
                return false
            end
            return true
        end)
    end
end

-- =====================================================================
-- ★★ A12.1c · THE OFFER — the routes for THIS MapID and no others
-- =====================================================================
local rA = { id = "RA", mapID = 33, beacons = {} }
local rB = { id = "RB", mapID = 33, beacons = {} }
local rC = { id = "RC", mapID = 99, beacons = {} }
Routes._list = { rA, rB, rC }
local offer = Manager.Offer(33)
assert(#offer == 2,
       "THE OFFER CROSSED MAPS: §4b step 0 offers the routes for THIS MapID and the human "
       .. "picks one. Offering every route puts an unarmable entry in front of the reader "
       .. "(A12.1c). got " .. tostring(#offer))
assert(offer[1].id == "RA" and offer[2].id == "RB", "the offer must hold exactly A and B")

-- =====================================================================
-- ★★★ A12.3a/b · ARM — the lowest POSITIVE stage, plus bucket 0
-- =====================================================================
route("R1", 33, {
    beacon({ id = "b1", stage = 1, children = {
        child({ id = "c1", ordinal = 1, x = 10 }),
        child({ id = "c2", ordinal = 2, x = 20 }),
    } }),
    beacon({ id = "b2", stage = 2, children = {
        child({ id = "d1", ordinal = 1, x = 30 }),
    } }),
    -- ⚠ CHILDLESS, per RI-40: stage 0 is self-completing only.
    beacon({ id = "b0", stage = nil, children = {} }),
})
bindAll()

local ok, why = Manager.Select(33, "R1")
assert(ok, "THE ROUTE WOULD NOT ARM: " .. tostring(why))

-- ⚠ THE STAGE ROW BEFORE ANY COUNT ROW. A start pinned at 0 shows up in a count as
-- "1 node armed", which names a number and not the pin (A12.3a's mutation, and §435's
-- walk found this exact fault by failing).
assert(Manager.Stage() == 1,
       "THE RUN STARTED AT THE WRONG STAGE: A12.3a - `currentStage` is the LOWEST POSITIVE "
       .. "stage present. Stage 0 is ALWAYS ELIGIBLE, not first: a recovery beacon is not "
       .. "where a run begins. got " .. tostring(Manager.Stage()))
assert(Manager.Step() == 1, "the first step is the lowest positive ordinal, got "
       .. tostring(Manager.Step()))

local armed = Sensor.Armed()
assert(armed, "the sensor must be armed after a select")
local sawStage0, sawStage1 = false, false
for _, n in ipairs(armed.nodes) do
    if n.stage == 0 then sawStage0 = true end
    if n.stage == 1 then sawStage1 = true end
end
assert(sawStage0,
       "BUCKET 0 WAS NOT ARMED: A12.3b arms the current stage AND bucket 0 TOGETHER, and "
       .. "A12.7a makes that true BY CONSTRUCTION - there is no recovery MODE, so a pass "
       .. "that leaves bucket 0 out stops recovery working the moment the run moves on")
assert(sawStage1, "the current stage's own nodes must be armed")

-- ★★ A12.3c · THE LURE IS THE STAGE'S, AND TRAY-0 NEVER WRITES THE ARROW (AL-6).
assert(#track.pointed == 1, "exactly one lure per arming, got " .. tostring(#track.pointed))
assert(track.pointed[1]:find("b1", 1, true),
       "THE ARROW POINTED AT RECOVERY: tray-0 items NEVER write the arrow - recovery is "
       .. "observed and corrected, not steered. Pointed at: " .. track.pointed[1])

-- =====================================================================
-- ★★★ A12.1a · NEVER TWO ACTIVE ROUTES — the teardown happens FIRST
-- =====================================================================
local beforeSlots = slotCount()
local bucketDuring
local realBuild = Bucket.Build
Bucket.Build = function(...)
    -- ⚠ OBSERVED AT THE MOMENT OF THE SECOND BUILD, which is the only moment the row is
    -- about: "at no point do two buckets exist". Asserting afterwards would pass even if
    -- both had been live for an instant.
    bucketDuring = Manager.Bucket()
    return realBuild(...)
end
route("R2", 33, { beacon({ id = "z1", stage = 1, children = { child({ id = "y1", ordinal = 1 }) } }) })
Routes._list = { Routes._r }
assert(Manager.Select(33, "R2"), "the second route must arm")
Bucket.Build = realBuild
assert(bucketDuring == nil,
       "TWO BUCKETS EXISTED AT ONCE: A12.1a - the first is torn down BEFORE the second "
       .. "builds. A manager holding two is a manager that can dispatch into the one the "
       .. "reader did not pick")
-- ★ A12.9a - ONE SLOT, OVERWRITTEN, NEVER APPENDED. A second selection must reuse the
-- same key rather than growing the store per session.
assert(slotCount() == 1 and beforeSlots <= 1,
       "THE STORE GREW A SECOND SLOT: A12.9a - one saved slot, OVERWRITTEN, never "
       .. "appended. A store that grows per session is the mutation this row names. got "
       .. tostring(slotCount()))
assert(Manager.Selected() == "R2", "the store must hold the new selection")

-- =====================================================================
-- ★★★ A12.4a · DISPATCH — only the tabs whose SENSE WORD matches
-- =====================================================================
route("R3", 33, {
    beacon({ id = "b1", stage = 1, rows = {}, children = {
        child({ id = "c1", ordinal = 1, x = 10,
                rows = { row("whenOn", "note", "here"), row("whenOff", "say", "bye") } }),
        child({ id = "c2", ordinal = 2, x = 500 }),
    } }),
})
bindAll()
ran = {}
assert(Manager.Select(33, "R3"))

local c1 = nil
for _, n in ipairs(Sensor.Armed().nodes) do
    if n.address:find("c1", 1, true) then c1 = n end
end
assert(c1, "the fixture's c1 must be armed")

-- ⚠ THE WORD IS WHAT SELECTS THE TAB, so a `whenOn` change must NOT run the `whenOff` tab.
Manager.OnPoll({ { address = c1.address, word = Sensor.WHEN_ON, node = c1 } })
assert(#ran == 1,
       "THE WRONG TABS RAN: A12.4a runs ONLY the tabs whose sense-word matches the "
       .. "transition. This node carries a `whenOn` tab and a `whenOff` tab and exactly "
       .. "one word arrived. ran: " .. table.concat(ran, ", "))
assert(ran[1]:find("note", 1, true), "the matching tab is the note one")

-- ★★ A NODE COMPLETES WHEN **ALL** ITS TABS HAVE (A12.5a, RI-16 one level up), so the
-- step must NOT have moved on one of two.
assert(Manager.Step() == 1,
       "A STAGE ADVANCED MID-NODE: `Next` does not fire until EVERY tab of the node is "
       .. "complete - one tab of two ran here")

Manager.OnPoll({ { address = c1.address, word = Sensor.WHEN_OFF, node = c1 } })
assert(Manager.Step() == 2,
       "THE NODE COMPLETED AND THE STEP DID NOT MOVE: both tabs are done, so A12.5a's "
       .. "`Step` fires to the next positive ordinal. got " .. tostring(Manager.Step()))

-- ⚠⚠ THIS BLOCK RUNS BEFORE A12.6a, AND MUTATION PUT IT HERE. That block's
-- pass-through node is ALSO a zero node, so any zero-node fault damages it first and
-- gets reported as *"the advance must still HAPPEN"* - true, and naming the swap
-- rather than the derivation. ★ This block brings its own fixtures, so nothing but
-- habit was keeping it later.

-- ⚠⚠ A12.6a RUNS BEFORE EVERY BLOCK THAT COMPLETES A NODE, and mutation put it
-- here: a swap-inside-the-loop fault damages the FIRST completing fixture and gets
-- reported as whatever that fixture was about. It brings its own route.

-- ⚠⚠ THE ORDER OF THE NEXT THREE BLOCKS IS SET BY MUTATION, not by narrative:
--     Next  →  A12.6a  →  the latch
-- Every one of them uses a ZERO NODE, so whichever runs first answers for the
-- others' faults. ★ Next is first because it defines what a zero node MEANS;
-- A12.6a next because its fixture completes one; the latch last because it is the
-- only one whose subject is what happens AFTER completion.

-- =====================================================================
-- ★★★ AN AUTHORED `Next` IS THE INSTRUCTION (AL-21), AND ABSENT IS DERIVED (§479)
-- =====================================================================
local function nextRoute(id, kid)
    route(id, 33, {
        beacon({ id = "b1", stage = 1, rows = {}, children = { kid } }),
        beacon({ id = "b2", stage = 2, rows = {}, children = {
            child({ id = "d1", ordinal = 1, x = 300 }) } }),
        beacon({ id = "b7", stage = 7, rows = {}, children = {
            child({ id = "e1", ordinal = 1, x = 700 }) } }),
    })
    Manager.ClearBindings()
    Manager.Bind("note", function() return true end)
    assert(Manager.Select(33, id), "the fixture must arm")
    for _, n in ipairs(Sensor.Armed().nodes) do
        if n.address:find("c1", 1, true) then return n end
    end
end

-- ★★ `set N` ON A **ZERO NODE** - the case that makes §4b's recovery escapement work.
-- ⚠ A zero node advances NOTHING by default; an instruction is the only way it moves the
-- run, which is Battlewrath's *"unless that is its instruction"* made testable.
local zero = nextRoute("N1", child({ id = "c1", x = 10, nextType = "set", nextArg = 7 }))
assert(zero.step == 0, "the fixture's node must be a ZERO node")
Manager.OnPoll({ { address = zero.address, word = Sensor.WHEN_ON, node = zero } })
assert(Manager.Stage() == 7,
       "A ZERO NODE'S `set N` DID NOT STEP THE RUN: an authored Next OUTRANKS the derived "
       .. "default, and without it a recovery beacon can never send the reader anywhere - "
       .. "§4b's escapement would have no mechanism. got " .. tostring(Manager.Stage()))

-- ★★ AND THE SAME NODE WITH **NO** `Next` MOVES NOTHING - the derived default, and the
-- row that stops `set` looking like it works when the branch is simply always taken.
local quiet = nextRoute("N2", child({ id = "c1", x = 10 }))
Manager.OnPoll({ { address = quiet.address, word = Sensor.WHEN_ON, node = quiet } })
assert(Manager.Stage() == 1,
       "A ZERO NODE WITH NO INSTRUCTION MOVED THE RUN: absent is NOT `stage` - that is what "
       .. "retires A12.2h. An unauthored tray-0 beacon is an UPDATER; a RECOVERY beacon is "
       .. "one GIVEN `set N`")

-- ★★★ A12.7a · A STAGE-0 BEACON'S `Set(N)` STEPS THE RUN **WHEREVER THE READER IS**
--
-- ⚠⚠ THIS IS THE ROW'S OWN TEST, VERBATIM - *"walk into a stage-0 beacon at stage 3
-- whose Next is Set(1) → the run is at 1"* - and it had NEVER BEEN WRITTEN. Measured
-- §484: the escapement could not fire ONCE, because `NodeDone` returned early on
-- `node.stage ~= active.stage` and a recovery beacon's stage is 0 by definition.
-- ★ The row existed the whole time. The GRADING did not, which is the only reason a
-- whole mechanism sat unreachable.
route("N5", 33, {
    beacon({ id = "b1", stage = 1, rows = {}, children = {
        child({ id = "c1", ordinal = 1, x = 10 }) } }),
    beacon({ id = "b2", stage = 2, rows = {}, children = {
        child({ id = "d1", ordinal = 1, x = 300 }) } }),
    -- THE RECOVERY BEACON: stage 0, childless, carrying the escapement (RI-40 - a
    -- stage-0 beacon is self-completing only, so childless is its ONLY legal shape).
    beacon({ id = "rec", stage = nil, x = 900, rows = { row("whenOn", "note", "here") },
             nextType = "set", nextArg = 2, children = {} }),
})
Manager.ClearBindings()
Manager.Bind("note", function() return true end)
assert(Manager.Select(33, "N5"), "the escapement fixture must arm")
assert(Manager.Stage() == 1, "the run starts at the lowest positive stage")

local recNode
for _, n in ipairs(Sensor.Armed().nodes) do
    if n.address:find("rec", 1, true) then recNode = n end
end
assert(recNode and recNode.stage == 0, "the recovery beacon must be armed, in bucket 0")

Manager.OnPoll({ { address = recNode.address, word = Sensor.WHEN_ON, node = recNode } })
assert(Manager.Stage() == 2,
       "THE ESCAPEMENT DID NOT FIRE: A12.7a - a stage-0 beacon's `Set(N)` steps the run to "
       .. "N WHEREVER THE READER IS, and there is no recovery MODE. A guard that requires "
       .. "a completing node to be in the CURRENT stage makes this unreachable by "
       .. "definition, because a recovery beacon's stage is 0. got "
       .. tostring(Manager.Stage()))

-- ⚠ AND A BUCKET-0 NODE WITH NO INSTRUCTION STILL MOVES NOTHING - the row that stops
-- "always eligible to complete" from becoming "always advances".
route("N6", 33, {
    beacon({ id = "b1", stage = 1, rows = {}, children = {
        child({ id = "c1", ordinal = 1, x = 10 }) } }),
    beacon({ id = "b2", stage = 2, rows = {}, children = {
        child({ id = "d1", ordinal = 1, x = 300 }) } }),
    beacon({ id = "rec", stage = nil, x = 900, rows = { row("whenOn", "note", "here") }, children = {} }),
})
Manager.ClearBindings()
Manager.Bind("note", function() return true end)
assert(Manager.Select(33, "N6"))
local quietRec
for _, n in ipairs(Sensor.Armed().nodes) do
    if n.address:find("rec", 1, true) then quietRec = n end
end
Manager.OnPoll({ { address = quietRec.address, word = Sensor.WHEN_ON, node = quietRec } })
assert(Manager.Stage() == 1,
       "AN UNAUTHORED TRAY-0 BEACON MOVED THE RUN: it is an UPDATER (AL-21's addendum) - a "
       .. "RECOVERY beacon is one GIVEN `set N`. Absent is nothing follows, at stage 0 too")

-- ★★ `stage` SKIPS TO THE NEXT STAGE **PRESENT**, never +1 - the gap is 2 then 7 here.
local told = nextRoute("N3", child({ id = "c1", x = 10, nextType = "stage" }))
Manager.OnPoll({ { address = told.address, word = Sensor.WHEN_ON, node = told } })
assert(Manager.Stage() == 2,
       "`stage` DID NOT ADVANCE TO THE NEXT STAGE PRESENT (AL-9's correction). got "
       .. tostring(Manager.Stage()))

-- ⚠⚠ `set` TO A STAGE THIS ROUTE DOES NOT HAVE IS REFUSED, NOT ARMED. A route TRAVELS,
-- so a stage the author named may simply not be here - and arming one that resolves to
-- bucket 0 alone is the STALL `+1` was corrected for.
local lost = nextRoute("N4", child({ id = "c1", x = 10, nextType = "set", nextArg = 99 }))
Manager.OnPoll({ { address = lost.address, word = Sensor.WHEN_ON, node = lost } })
assert(not Manager.Running(),
       "`set` TO AN ABSENT STAGE ARMED ANYWAY: N is not trusted to exist. Arming a stage "
       .. "that is not in this route leaves bucket 0 alone and the run stalls silently - "
       .. "the exact failure AL-9 corrected `+1` for")

-- =====================================================================
-- ★★★ A12.6a · THE SWAP HAPPENS **AFTER** THE POLL, NEVER INSIDE IT
--
-- ⚠⚠ THIS BLOCK EXISTS BECAUSE A MUTATION SURVIVED. Advancing inside the dispatch loop
-- passed every row above it, for the plainest reason: **no fixture polled more than one
-- change**, so "inside" and "after" the loop were the same instant. ★ A guard whose
-- failure case the fixtures cannot reach is untested, not safe.
--
-- ★★ Model row 26 states the harm exactly: *the sensor's result changes the sensor's
-- input*, so a swap mid-loop means **one sample sees two different armed sets**. ⟶ The
-- way to see that is from INSIDE a callable, which runs during dispatch: the second
-- change's action asks the sensor what is armed, and it must be the SAME table the poll
-- began with.
-- =====================================================================
route("R7", 33, {
    beacon({ id = "b1", stage = 1, rows = {}, children = {
        child({ id = "c1", ordinal = 1, x = 10 }),
        child({ id = "c2", ordinal = 2, x = 20 }),
        -- ⚠ ORDINALLESS: the pass-through WITHIN the stage, armed alongside step 1, so a
        -- real poll can carry both of these at once.
        child({ id = "cx", x = 30 }),
    } }),
})
Manager.ClearBindings()
local sawArmed = nil
Manager.Bind("note", function(ctx)
    if ctx.address:find("cx", 1, true) then sawArmed = Sensor.Armed() end
    return true
end)
assert(Manager.Select(33, "R7"))
local n1, nx
for _, n in ipairs(Sensor.Armed().nodes) do
    if n.address:find("c1", 1, true) then n1 = n end
    if n.address:find("cx", 1, true) then nx = n end
end
local armedAtPollStart = Sensor.Armed()

-- ⚠ THE COMPLETING NODE COMES FIRST in the changed list, so a mid-loop swap lands
-- BEFORE the second change is dispatched. Ordered the other way this fixture proves
-- nothing.
Manager.OnPoll({
    { address = n1.address, word = Sensor.WHEN_ON, node = n1 },
    { address = nx.address, word = Sensor.WHEN_ON, node = nx },
})
assert(sawArmed ~= nil, "the second change's action must have run at all")
assert(sawArmed == armedAtPollStart,
       "THE ARMED LIST CHANGED MID-POLL: A12.6a and model row 26 - the sensor's result "
       .. "changes the sensor's input, so the remaining nodes in a poll are evaluated "
       .. "against the OLD armed list and the swap lands after. One sample must not see "
       .. "two different armed sets")
assert(Manager.Step() == 2,
       "and the advance must still HAPPEN, after the poll rather than never")

-- =====================================================================
-- ★★★ AL-23 · THE LATCH — his two cases, and they pull in opposite directions
--
-- > *"It's a latch. So it has to complete before it is released and can be re-armed. … A
-- > boss room isn't one chance to kill it or our system breaks. At the same time we don't
-- > want to spam LoS every time you run over it."*
--
-- ★ ONE MECHANISM, BOTH CASES: the latch closes on COMPLETION, so a LoS note that
-- completes is held and does not spam; a boss row that never completes on a wipe never
-- latched, so it re-arms with nothing to reset.
-- =====================================================================
local function latchRoute(id, kid)
    route(id, 33, {
        beacon({ id = "b1", stage = 1, rows = {}, children = { kid,
            child({ id = "c9", ordinal = 9, x = 900 }) } }),
        beacon({ id = "b2", stage = 2, rows = {}, children = {
            child({ id = "d1", ordinal = 1, x = 300 }) } }),
    })
    -- ⚠ STOP FIRST: `ClearBindings` DECLINES while a route is active, and this fixture
    -- relied on that silent decline to inherit the previous block's bindings. Reordering
    -- the blocks exposed it - a test that depends on a call QUIETLY FAILING is a test
    -- whose setup nobody wrote.
    Manager.Stop()
    Manager.ClearBindings()
    bindAll()
    assert(Manager.Select(33, id), "the latch fixture must arm")
    for _, n in ipairs(Sensor.Armed().nodes) do
        if n.address:find("c1", 1, true) then return n end
    end
end

-- ★★ THE LoS CASE — `say` on a step-0 node, latched, and it must NOT spam.
local says = 0
local los = latchRoute("T1", child({ id = "c1", x = 10,
    rows = { row("whenOn", "say", "LoS!") } }))
Manager.Bind("say", function() says = says + 1; return true end)
Manager.OnPoll({ { address = los.address, word = Sensor.WHEN_ON, node = los } })
Manager.OnPoll({ { address = los.address, word = Sensor.WHEN_OFF, node = los } })
Manager.OnPoll({ { address = los.address, word = Sensor.WHEN_ON, node = los } })
assert(says == 1,
       "THE LATCH DID NOT HOLD: a `once` row completes, LATCHES, and is SPENT until the "
       .. "node re-arms - *we don't want to spam LoS every time you run over it*. Fired "
       .. tostring(says) .. " times across two qualifications")

-- ★★ AND THE NODE'S OWN LATCH: a `once` node that has COMPLETED LEAVES the offered
-- list. ⚠ Nothing above can see this - the row hold already stops it firing - so without
-- this row the filter could be deleted and every test would stay green.
-- ★ It is the half that matters at runtime: an unfiltered list is what let a completed
-- recovery beacon re-step the run on every walk-through (§484).
local stillOffered = false
for _, n in ipairs(Sensor.Armed().nodes) do
    if n.address == los.address then stillOffered = true end
end
assert(not stillOffered,
       "A SPENT NODE STAYED IN THE OFFERED LIST: `once` means the manager sends it to the "
       .. "sensor to be completed and then stops re-stating it - *repeat is a function of "
       .. "the manager to re-state or not*. Leaving it offered is what makes a completed "
       .. "escapement fire again on every re-entry")

-- ★★★ THE BOSS CASE — the row RAN and never COMPLETED (a wipe), so it never latched
-- and must fire again. ⚠ This is the row that stops the LoS fix breaking boss rooms:
-- *"a boss room isn't one chance to kill it or our system breaks."*
local arms = 0
local boss = latchRoute("T2", child({ id = "c1", x = 10,
    rows = { row("whenOn", "boss", "Ragnaros") } }))
Manager.Bind("boss", function() arms = arms + 1; return false end)   -- armed, not complete
Manager.OnPoll({ { address = boss.address, word = Sensor.WHEN_ON, node = boss } })
Manager.OnPoll({ { address = boss.address, word = Sensor.WHEN_OFF, node = boss } })
Manager.OnPoll({ { address = boss.address, word = Sensor.WHEN_ON, node = boss } })
assert(arms == 2,
       "A ROW THAT NEVER COMPLETED WAS TREATED AS SPENT: the latch closes on COMPLETION, "
       .. "not on FIRING. A boss row arms a listener and finishes when the boss dies - on "
       .. "a wipe it never latched, so it re-arms on re-entry with nothing to reset. "
       .. "armed " .. tostring(arms) .. " times")

-- ★★ `every` ON A ROW — released when the SENSE DROPS, so it fires per QUALIFICATION.
-- ⚠ NEVER per poll: two `whenOn` reports with no drop between them fire ONCE.
local notes = 0
local ev = latchRoute("T3", child({ id = "c1", x = 10,
    rows = { { sense = "whenOn", action = "note", arg = "here", trigger = "every" } } }))
Manager.Bind("note", function() notes = notes + 1; return true end)
Manager.OnPoll({ { address = ev.address, word = Sensor.WHEN_ON, node = ev } })
Manager.OnPoll({ { address = ev.address, word = Sensor.WHEN_OFF, node = ev } })
Manager.OnPoll({ { address = ev.address, word = Sensor.WHEN_ON, node = ev } })
assert(notes == 2,
       "AN `every` ROW DID NOT RE-FIRE: its latch is released when the SENSE DROPS, which "
       .. "is what makes *every time* mean every QUALIFICATION. got " .. tostring(notes))

-- =====================================================================
-- ★★ A12.5b · THE ORDINAL RUNS DRY, SO THE STAGE COMPLETES
-- ★★★ A12.5a (AL-9) · AND IT GOES TO THE NEXT STAGE **PRESENT**, never +1
-- =====================================================================
route("R4", 33, {
    beacon({ id = "b1", stage = 1, rows = {}, children = { child({ id = "c1", ordinal = 1 }) } }),
    -- ⚠ THE GAP IS THE POINT. L3 permits an exposed gap, so 1 then 5 is legal, and `+1`
    -- would arm stage 2 - which `Bucket.Stage` resolves to bucket 0 alone.
    beacon({ id = "b5", stage = 5, rows = {}, children = { child({ id = "e1", ordinal = 1 }) } }),
})
bindAll()
assert(Manager.Select(33, "R4"))
local only = Sensor.Armed().nodes[1]
for _, n in ipairs(Sensor.Armed().nodes) do if n.stage == 1 then only = n end end
Manager.OnPoll({ { address = only.address, word = Sensor.WHEN_ON, node = only } })

-- ★★ THE DRY-RUN ROW COMES FIRST, and it is a separate claim from the +1 one. A12.5b:
-- a stage completes when the ordinal RUNS DRY, with no `Next` needed - *"a route authored
-- without one never advances"* is that row's mutation. ⚠ Folded into the stage-number
-- assertion below, an advance that never HAPPENED reported *"the advance used +1"*, which
-- sends the reader to arithmetic that was never reached.
assert(Manager.Stage() ~= 1,
       "THE ORDINAL RAN DRY AND THE STAGE DID NOT COMPLETE: A12.5b - a stage completes "
       .. "when TOLD or when the ordinal RUNS DRY. Requiring a `Next` means a route "
       .. "authored without one never advances at all")

-- ⚠ THE STAGE ROW FIRST: `+1` lands on stage 2, and a step assertion would report
-- "step 1" for both the right answer and the wrong one.
assert(Manager.Stage() == 5,
       "THE ADVANCE USED `+1` INSTEAD OF THE NEXT STAGE PRESENT: AL-9 corrected §4b on "
       .. "exactly this - L3 permits an exposed gap, so `+1` from 1 arms stage 2, which "
       .. "resolves to BUCKET 0 ALONE and the run stalls with only recovery armed. got "
       .. tostring(Manager.Stage()))

-- =====================================================================
-- ★★ A12.8a · TERMINAL — park, and the SELECTION SURVIVES
-- =====================================================================
local parkedBefore = track.parked
local last = Sensor.Armed().nodes[1]
for _, n in ipairs(Sensor.Armed().nodes) do if n.stage == 5 then last = n end end
Manager.OnPoll({ { address = last.address, word = Sensor.WHEN_ON, node = last } })

assert(not Manager.Running(),
       "THE LAST STAGE COMPLETED AND THE RUN IS STILL ACTIVE (A12.8a)")
assert(not Sensor.IsArmed(),
       "NOTHING MAY REMAIN ARMED AT TERMINAL: A11.4a's `nothing armed, nothing running`")
assert(track.parked == parkedBefore + 1,
       "THE TRACKER WAS NOT PARKED: A11.9's escapement - a spent target left set is the "
       .. "mutation this row names")
assert(Manager.Selected() == "R4",
       "THE SELECTION DID NOT SURVIVE: A12.8a - the route stays SELECTED but not armed, "
       .. "which is what makes arming again a re-arm rather than a re-pick")

-- =====================================================================
-- ★★ A12.4c · LISTENERS DISARM ON `When off`, not only on advance
-- =====================================================================
route("R5", 33, {
    beacon({ id = "b1", stage = 1, rows = {}, children = {
        child({ id = "c1", ordinal = 1, rows = { row("whenOn", "boss", "Ragnaros") } }),
        child({ id = "c2", ordinal = 2 }),
    } }),
})
bindAll("pending")
assert(Manager.Select(33, "R5"))
local bossNode
for _, n in ipairs(Sensor.Armed().nodes) do
    if n.address:find("c1", 1, true) then bossNode = n end
end
Manager.OnPoll({ { address = bossNode.address, word = Sensor.WHEN_ON, node = bossNode } })
assert(Manager.Step() == 1,
       "A PENDING TAB COMPLETED ITSELF: a `boss` tab arms a listener and finishes when the "
       .. "boss dies, which is not when the tab RAN (A12.4c)")

-- =====================================================================
-- ★★★ A12.4d · A NO-ACTION TAB COMPLETES ON ITS SENSE (AL-18)
--
-- ⚠⚠ BOTH ROWS HERE ARE LIVE BREAKS THAT MEASUREMENT FOUND, not hypotheticals. When
-- the action became optional, this file stayed green and the manager was broken twice:
-- `actions[nil]` is nil, so the ARM gate read an actionless row as an unbound word and
-- refused the whole route, and dispatch skipped the row so it never completed.
-- ★ The seed AL-18 puts on every node is exactly this row - so both faults would have
-- met every route, on the first arm and then forever.
-- =====================================================================
route("R8", 33, {
    beacon({ id = "b1", stage = 1, rows = {}, children = {
        child({ id = "c1", ordinal = 1, x = 10, rows = { { sense = "whenOn" } } }),
        child({ id = "c2", ordinal = 2, x = 20 }),
    } }),
})
Manager.ClearBindings()
Manager.Bind("note", function() return true end)

local armedOk, armedWhy = Manager.Select(33, "R8")
assert(armedOk,
       "AN ARRIVAL ROW MADE THE ROUTE UNARMABLE: a row naming no action wants no callable, "
       .. "so the arm-time bind check must skip it. `actions[nil]` is nil, which reads as "
       .. "an unbound word unless the nil action is tested for. got: " .. tostring(armedWhy))

local arrNode
for _, n in ipairs(Sensor.Armed().nodes) do
    if n.address:find("c1", 1, true) then arrNode = n end
end
Manager.OnPoll({ { address = arrNode.address, word = Sensor.WHEN_ON, node = arrNode } })
assert(Manager.Step() == 2,
       "AN ARRIVAL ROW NEVER COMPLETED: A12.4d - `When on` with no action means REACHED, "
       .. "so the transition arriving IS the whole of the tab and there is nothing to wait "
       .. "for. A tab that never completes holds its node forever, and the run arms, points "
       .. "the arrow and never advances - the same silent stall A12.2g refuses at build, "
       .. "reappearing at dispatch")

-- =====================================================================
-- ★★ A12.2c · A WORD WITH NO CALLABLE IS REFUSED AT ARM, AND NAMED
-- =====================================================================
Manager.Stop()
Manager.ClearBindings()
Manager.Bind("note", function() return true end)
route("R6", 33, {
    beacon({ id = "b1", stage = 1, rows = {}, children = {
        child({ id = "c1", ordinal = 1, rows = { row("whenOn", "say", "hello") } }) } }),
})
local no, noWhy = Manager.Select(33, "R6")
assert(no == nil,
       "AN UNBOUND ACTION ARMED ANYWAY: checking at DISPATCH instead would discover it "
       .. "mid-run and mid-combat, one tab at a time")
assert(tostring(noWhy):find("no callable", 1, true) and tostring(noWhy):find("say", 1, true),
       "THE REFUSAL DID NOT NAME THE WORD: a reason that does not say WHICH action is "
       .. "missing is a failure pushed downstream. got: " .. tostring(noWhy))
assert(not Manager.Running(),
       "A FAILED ARM LEFT A ROUTE ACTIVE: the reader asked for a different route and did "
       .. "not get it - a half-selected state is the thing A12.1a exists to prevent")

-- =====================================================================
-- ★★★ A12.1b · THE SURFACE ITSELF — no polling, no geometry
-- =====================================================================
-- ⚠ ASSERTED AS ABSENT SYMBOLS AND AS SOURCE, because the two prove different things:
-- a missing DOOR is what a caller could reach for, and the source is where an `OnUpdate`
-- or a distance sum would actually be written.
for _, door in ipairs({ "Poll", "OnUpdate", "Evaluate", "NextIn", "Sample" }) do
    assert(Manager[door] == nil,
           "THE MANAGER GREW A HOT-PATH DOOR (`" .. door .. "`): A12.1b - it never polls, "
           .. "never evaluates geometry, never interprets on the hot path. Row 26's "
           .. "reason is concrete: the sensor's result changes the sensor's input")
end
local src = io.open(here .. "../../COA_DungeonRun/manager.lua"):read("*a")
assert(not src:find("math%.sqrt") and not src:find("OnUpdate"),
       "THE MANAGER GREW GEOMETRY OR A TICKER: distance lives in `rule.lua` and the tick "
       .. "in `sensor.lua`, and a second copy of either is a second answer")

print("smoke_manager: OK - one active route, armed at the lowest positive stage with "
      .. "bucket 0; only matching tabs run; the node completes whole; the advance goes to "
      .. "the stage PRESENT; terminal parks and the selection survives")
