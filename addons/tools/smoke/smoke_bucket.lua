-- Model: addons/planning/DRIVER_BASIS.md · construction is `driver_data_model.md` §A5b
--
-- ★★★ BUCKET (rows 23-27) — and the row that shapes every assertion here is 24:
-- **BUCKET MAY FAIL, AND SHOULD FAIL LOUDLY. STAGE MAY NOT FAIL.**
--
-- ⚠ So most of this file is failure rows, each checking that the reason NAMES what was
-- missing. A constructor that returns an empty list on a bad route passes a "does not
-- crash" test and hands the driver silence at the moment it can least afford one.

local here = debug.getinfo(1, "S").source:match("@(.*[/\\])") or ""
local Rule = assert(dofile(here .. "../../COA_DungeonRun/rule.lua"))

-- ⚠ A STUB STORE, because BUCKET's job is the LAYOUT and the REFUSALS, not `routes.lua`.
-- Its accessors mirror the shipped ones by name and arity so a signature change over there
-- fails here rather than being absorbed.
-- ⚠ Declared BEFORE the table so the closures below capture it as an upvalue. In a single
-- `local Routes = { Get = function() ... Routes ... end }` the name is not yet in scope
-- inside the function, and `Routes` resolves to a nil GLOBAL at call time.
local Routes
Routes = {
    _r = nil,
    Get = function(id) return Routes._r and Routes._r.id == id and Routes._r or nil end,
    ChildrenOf = function(b) return b.children or {} end,
    ReachOf = function(x) return x.radius, x.bandUp end,
    RowsOf = function(c) return c.rows or {} end,
}
-- ⚠⚠ THE STUB MIRRORS THE SHIPPED LISTS, and a stub that did not is what HID a defect
-- for four commits (§457). It read `Has = function(c) return c == "arrive" or c == "boss" end`
-- - **more permissive than the real adaptor**, which carries no word for `boss` at all - so
-- BUCKET's check against the wrong table looked fine here and would have refused three of the
-- four authorable actions in the client.
-- ★ `frames.lua`'s own law, one file over: *a model that disagrees with the client is worse
-- than no model.* ⟶ These are the SHIPPED values from `routes.lua`, copied verbatim.
local Vocab = assert(dofile(here .. "_vocab.lua"))
Routes.SENSE_WORDS = Vocab.SENSE_WORDS
Routes.ROW_ACTIONS = Vocab.ROW_ACTIONS
Routes.ROW_ARG = Vocab.ROW_ARG
Routes.ROW_ARG_RULE = Vocab.ROW_ARG_RULE
Routes.ARG_MAX = Vocab.ARG_MAX
Routes.IsPosition, Routes.LedTo = Vocab.IsPosition, Vocab.LedTo
-- ★★ THE STUB FALLS THROUGH TO THE SHIPPED VOCABULARY for anything it does not
-- define itself. ⚠ The explicit entries above still WIN - `Get`, `List`, `RowsOf`
-- and friends must be the stub's - but a pure-vocabulary helper the stub never
-- thought about (§486: `TriggerOf`) resolves instead of silently reading nil and
-- turning a guard off.
setmetatable(Routes, { __index = Vocab })
-- ★★★ THE REAL CONTRACT, because `bucket.lua` READS ITS SEED from it (RI-81, 2026-08-26).
-- ⚠ Without this the module resolves `NS.Contract` to nil and takes its load-order
-- fallback - the SAME number - so the band assertion below would pass while proving
-- nothing about where the value came from.
local CNS = { }
assert(loadfile(here .. "../../COA_DungeonRun/contract.lua"))("COA_DungeonRun", CNS)
local Contract = assert(CNS.Contract, "contract.lua did not publish Contract")

_G.COA_DungeonRun_NS = { Rule = Rule, Routes = Routes, Contract = Contract }
local Bucket = assert(dofile(here .. "../../COA_DungeonRun/bucket.lua"),
                      "bucket.lua did not return its table")

-- ★★ THE SEED IS THE CONTRACT'S, and this is the assertion the fallback would hide.
assert(Contract.Seed("characteristic", "band") == 2.5,
       "THE CONTRACT DOES NOT CARRY THE BAND SEED: the value an author gets by choosing "
       .. "nothing lives beside the field's type and its why, or it lives in two places")
assert(Bucket.BAND_DEFAULT == Contract.Seed("characteristic", "band"),
       "BUCKET IS HOLDING ITS OWN COPY OF THE BAND DEFAULT: one home, or the two drift "
       .. "and the one nobody edits wins")
assert(Contract.Seed("behaviour", "trigger") == "once",
       "the row latch's seed is `once` (AL-23) - absent is once")
assert(Contract.Seed("characteristic", "trigger") == nil,
       "AND THE NODE LATCH HAS NO SEED: its control is not built and no code term is "
       .. "chosen, so a value here would be the declaration inventing one")
assert(Contract.Seed("characteristic", "r") == nil,
       "AND THE RADIUS IS NOT SEEDED HERE: `Routes.R_FLOOR` is a BOUND with its own owner "
       .. "and clamping elsewhere - copying it would be the second copy this removes")

local function child(t)
    return { id = t.id or "c1", x = t.x or 0, y = t.y or 0, z = t.z or 0,
             mapID = t.mapID, ordinal = t.ordinal, radius = t.radius or 5,
             bandUp = t.bandUp, rows = t.rows or { { sense = "whenOn", action = "boss", arg = "Ragnaros" } } }
end
local function route(beacons)
    Routes._r = { id = "R1", mapID = 33, beacons = beacons }
    return "R1"
end
-- ★ A BEACON CARRIES PLACE, REACH AND ROWS OF ITS OWN. ⚠ The first cut gave it only an
-- id, a stage and children - which is what let §433 treat a childless one as unsampleable.
-- A2.5: when the last child is deleted its tabs RETURN to the parent; A1.1: `ReachOf` is a
-- pure accessor of x's OWN fields, and `SetBeaconReach` exists for exactly this.
local function beacon(t)
    return { id = t.id or "b1", stage = t.stage, children = t.children,
             kind = "beacon",
             x = t.x or 0, y = t.y or 0, z = t.z or 0, mapID = t.mapID,
             radius = t.radius or 5, bandUp = t.bandUp,
             rows = t.rows or { { sense = "whenOn", action = "boss", arg = "Ragnaros" } } }
end

local function fails(mapID, rid, want, label)
    local b, why = Bucket.Build(mapID, rid)
    assert(b == nil, label .. ": BUCKET RETURNED A BUCKET where it must refuse")
    assert(type(why) == "string" and why:find(want, 1, true),
           label .. ": the refusal must NAME what was missing. Row 24 - a stage advance "
           .. "happens mid-run and mid-combat, so a reason that does not say WHAT is a "
           .. "failure BUCKET pushed downstream. wanted '" .. want .. "', got: "
           .. tostring(why))
end

-- =====================================================================
-- ★★ THE VOCABULARY GATE, FIRST — because every fixture below writes `boss`, so a
-- broken gate stops the HAPPY LAYOUT and reports a whole shape instead of a word.
-- =====================================================================
-- ★★★ EVERY AUTHORABLE WORD MUST BUILD — and the two rows above would never have caught
-- §457, because they only prove that a word NOBODY MAY WRITE is refused. That stayed true
-- the whole time BUCKET was gating on `Adaptor.Has`, the DISPLAY lookup (A5.1), which carries
-- a word for `supertrack` alone. ⟶ **Three of the four authorable actions were refused at
-- build, and all three senses**, and every refusal row here was green.
--
-- ⚠ The general shape: **a gate is graded by what it LETS THROUGH, not only by what it
-- stops.** A refusal-only suite passes a gate that refuses everything.
--
-- ★ So this walks the SHIPPED lists themselves rather than a copy — a word added to
-- `routes.lua` and forgotten in BUCKET fails HERE, on its own name.
for _, action in ipairs(Routes.ROW_ACTIONS) do
    -- ★ THE ARG COMES FROM `ROW_ARG` TOO. A hardcoded `arg = "x"` would cover today's
    -- four words and go stale the moment a fifth takes a different field; this covers
    -- whatever `routes.lua` says the action needs, on the day it says it.
    local arg = Routes.ROW_ARG[action] and ("a " .. Routes.ROW_ARG[action]) or nil
    route({ beacon({ stage = 1, children = {
        child({ rows = { { sense = "whenOn", action = action, arg = arg } } }) } }) })
    local b, why = Bucket.Build(33, "R1")
    assert(b, "AN AUTHORABLE ACTION WOULD NOT BUILD: `" .. action .. "` is in "
              .. "`Routes.ROW_ACTIONS`, the list `SetRow` admits it by, so a route carrying "
              .. "it must reach the driver. got: " .. tostring(why))
    assert(b.count == 1, "`" .. action .. "` built but dropped its node")
end

for _, sense in ipairs(Routes.SENSE_WORDS) do
    route({ beacon({ stage = 1, children = {
        child({ rows = { { sense = sense, action = "boss", arg = "Ragnaros" } } }) } }) })
    local b, why = Bucket.Build(33, "R1")
    assert(b, "AN AUTHORABLE SENSE WOULD NOT BUILD: `" .. sense .. "` is one of the three "
              .. "transition words the SENSOR itself reports (A11.3e), so a row sensing on "
              .. "it must reach the driver. got: " .. tostring(why))
    assert(b.count == 1, "`" .. sense .. "` built but dropped its node")
end

-- =====================================================================
-- ★★ THE HAPPY LAYOUT — one bucket per stage, bare rows, and row 27's conversions.
-- =====================================================================
local rid = route({
    beacon({ id = "b1", stage = 1, children = {
        child({ id = "c1", ordinal = 1, x = 10 }),
        child({ id = "c2" }),                       -- ordinalless: the no-step bucket
    } }),
    -- ⚠ CHILDLESS, per RI-40: stage 0 is self-completing only. This fixture used to give
    -- it a child, and mutation showed the cost - two different SLICE faults were both caught
    -- by this block's node COUNT, because the block was exercising the slice without meaning
    -- to. ★ A fixture carrying an illegal shape tests the refusal of that shape, not the
    -- thing the block is named for.
    beacon({ id = "b0", stage = nil, children = {} }),
})

-- ⚠⚠ THERE IS NO SECOND LEVEL ANY MORE (model row 23, corrected): a bucket IS a stage and
-- its entries are BARE ROWS, with `step` a FIELD used to filter and order. ★ So "the rows of
-- stage S carrying step T" is a SCAN, and this helper is what the old `bucket[S][T]` lookup
-- became. ⚠ It still returns nil rather than an empty table when the stage is absent, because
-- a missing stage and a stage with no matching rows are different facts.
local function slot(stage, step)
    if not stage then return nil end
    local out = {}
    for _, row in ipairs(stage) do
        if (row.step or 0) == step then out[#out + 1] = row end
    end
    return out
end

-- ⚠ A MESSAGE OF ITS OWN. This fixture now carries a CHILDLESS beacon (RI-40 made that
-- the only legal stage-0 shape), so a build refusing one fails HERE first - and a bare
-- `assert(Build(...))` would report the callee's string with no row behind it.
local bk, bkwhy = Bucket.Build(33, rid)
assert(bk,
       "THE HAPPY LAYOUT WOULD NOT BUILD: it holds a childless stage-0 beacon, which "
       .. "A1.2 makes RUNNABLE and RI-40 makes the ONLY legal stage-0 shape. got: "
       .. tostring(bkwhy))
-- ⚠ THE BOUNCE ROW BEFORE THE COUNT ROW - ninth instance of specific-behind-general
-- this week. A slice that reached a STAGED beacon showed up here as "expected 3 nodes,
-- got 2", which names a count and not the slice.
assert(bk.bounced == 0,
       "THE HAPPY LAYOUT BOUNCED SOMETHING: every shape in this fixture is legal, so a "
       .. "non-zero bounce means the slice is reaching further than stage 0 - it is "
       .. "STAGE 0's slice, not step 0's and not every beacon's")
assert(bk.count == 3, "expected 3 nodes, got " .. tostring(bk.count))
assert(bk.stages[1] and #slot(bk.stages[1], 1) == 1,
       "the ordinalled child must be a row of bucket 1 carrying step 1")
-- ⚠⚠ THE STAGE-0 ROW COMES FIRST, and mutation is why. Written after the no-step COUNT
-- row below, a stage that converted to 1 instead of 0 put its child in stage 1's no-step
-- slot - so the COUNT row fired, reporting the wrong fault. ★ A count is a general
-- assertion; it answers for every way the number can be wrong. **Fifth instance this week.**

-- ⚠⚠ THE STAGE KEY AND THE STEP KEY ARE ASSERTED SEPARATELY, because `stages[0][0]` grades
-- TWO conversions through one index. ★ Mutation broke the STEP conversion and this row fired
-- saying *"nil STAGE did not become 0"* — the stage had converted perfectly. A row that can
-- report the wrong cause is worse than one that stays silent: it sends the reader to the
-- half that was working.
assert(bk.stages[Bucket.ALWAYS],
       "THE STORE'S nil STAGE DID NOT BECOME 0: row 10 rules `nil` the STORE form and `0` "
       .. "the RECORD form, and row 27 makes BUCKET the only place that converts")
local always = slot(bk.stages[Bucket.ALWAYS], Bucket.ALWAYS)
assert(always and #always == 1,
       "THE STAGELESS BEACON'S CHILD IS NOT IN ITS NO-STEP SLOT: its stage converted to 0 "
       .. "correctly, so this is the STEP conversion - an ordinalless child is the no-step "
       .. "bucket for its stage (A11.1a, A11.3d)")
local noStep = slot(bk.stages[1], Bucket.ALWAYS)
assert(noStep and #noStep == 1,
       "AN ORDINALLESS CHILD DID NOT REACH THE NO-STEP BUCKET: A11.3d keeps *ordinalless "
       .. "children within their stage* always open, and A11.1a says the no-step bucket "
       .. "is always read")

-- ★★★ ROW 27's BAND CONVERSION, AND THIS IS THE JOIN — the row that proves BUCKET and the
-- RULE are one system rather than two files that agree in prose.
--
-- ⚠ A11.2h deleted `Rule.OPEN` and made `Rule.Evaluate` REFUSE a nil band. ⟶ If BUCKET did
-- not supply 2.5, every authored node that skipped the advanced picker would fire NOWHERE,
-- and nothing in either file alone could notice: `rule.lua`'s smoke would still be green
-- refusing nils, and a BUCKET smoke checking only the number would be green producing them.
-- ⚠ AND ITS MUTATION IS RULE-SIDE, NOT BUCKET-SIDE. Anything that stops BUCKET writing
-- 2.5 is caught by the VALUE row immediately below, which names that fault exactly. ★ The
-- JOIN row fires when the RULE stops accepting what BUCKET correctly produces - so it is
-- graded from `rule.lua`'s mutation set, and it is the only row in either file that can see
-- the two drifting apart. Recorded here so nobody reads it as redundant with the value row.
local unpicked = slot(bk.stages[1], 1)[1]
assert(unpicked.band == Bucket.BAND_DEFAULT,
       "an unpicked band must become 2.5, the picker's floor and default at once (RI-35)")
assert(Rule.Evaluate({ x = unpicked.x, y = unpicked.y, z = unpicked.z, mapID = 33 },
                     unpicked),
       "A BUCKETED NODE WAS REFUSED BY THE RULE: this sample sits EXACTLY on the node, so "
       .. "only the band check can refuse it. ⚠ The rule refuses a nil band since A11.2h, "
       .. "and BUCKET is the one place row 27 allows the conversion - if it stops doing it, "
       .. "every node whose author skipped the advanced picker fires nowhere")

-- ★ AND AN AUTHORED BAND IS NOT OVERWRITTEN BY THE DEFAULT.
Routes._r.beacons[1].children[1].bandUp = 7
local bk2 = assert(Bucket.Build(33, rid))
assert(slot(bk2.stages[1], 1)[1].band == 7,
       "BUCKET OVERWROTE AN AUTHORED BAND with its default - the default is for ABSENCE")
Routes._r.beacons[1].children[1].bandUp = nil

-- =====================================================================
-- ⚠⚠ ROW 24 — EVERY REFUSAL IS LOUD AND NAMES ITS CAUSE.
-- =====================================================================
fails(33, "nope", "no such route", "an unknown rid")
fails(nil, rid, "no mapID", "a missing map")
fails(33, nil, "no route id", "a missing rid")
fails(99, rid, "is for map 33", "a route belonging to another map")

route({})
fails(33, "R1", "no beacons", "an empty route")

-- ★★★ A CHILDLESS BEACON IS RUNNABLE (A1.2) - AND §433 REFUSED ONE.
--
-- ⚠⚠ This block used to read . That was a
-- DEFECT shipped as a refusal: A1.2 is a governing row - **"A childless beacon is
-- RUNNABLE"** - and A2.5 says the store's half, that a beacon whose last child is deleted
-- gets its tabs BACK and *"behaves as its own single child"*. A2.6: an ordinal child is
-- *"the same object as a childless beacon"*.
-- ★  already encoded it: *"the anchor is its own satisfier when it has
-- no children."* The bench built against  because that is the accessor it knew.
-- ⟶ Battlewrath found it by asking: *"or sense the childless beacon (A bucket with one
-- item)"* - which is exactly the shape asserted here.
route({ beacon({ id = "solo", stage = 3, children = {} }) })
local lone, lonewhy = Bucket.Build(33, "R1")
assert(lone,
       "A CHILDLESS BEACON WAS REFUSED BY BUCKET: A1.2 is a governing row - *a childless "
       .. "beacon is RUNNABLE* - and A2.5 says its tabs RETURN to it when the last child "
       .. "goes. §433 shipped this refusal and it was a defect. got: " .. tostring(lonewhy))
assert(lone.count == 1, "a childless beacon must produce ONE node, got " .. lone.count)
local soloSlot = slot(lone.stages[3], Bucket.ALWAYS)
assert(soloSlot and #soloSlot == 1,
       "A CHILDLESS BEACON DID NOT REACH ITS BUCKET: A1.2 makes it RUNNABLE and it has no "
       .. "ordinal, so it is the no-step bucket for its own stage - a bucket with one item")
-- ⚠⚠ THE ROW TESTS THE ABSENCE OF A CID, not the presence of the beacon id. ★ Checking
-- for "solo" SURVIVED a mutation that swapped the lone node for a fabricated child — the
-- beacon id is in the address either way, so the row proved nothing about the half it names.
-- `contract.lua:63` makes `cid` optional, and a childless beacon has no child to name.
assert(soloSlot[1].address == "33:R1:solo",
       "A CHILDLESS BEACON'S NODE INVENTED A CID: `cid` is optional (contract.lua:63) and "
       .. "there is no child here. An address states the whole ancestry (row 2, *ownership "
       .. "IS the address*), so a repeated segment claims a child that does not exist. got: "
       .. tostring(soloSlot[1].address))
assert(Rule.Evaluate({ x = 0, y = 0, z = 0, mapID = 33 }, soloSlot[1]),
       "THE LONE BEACON NODE WAS REFUSED BY THE RULE: it carries its own position and its "
       .. "own reach (A1.1: ReachOf is a pure accessor of x's OWN fields)")

route({ beacon({ stage = 1.5, children = { child({}) } }) })
fails(33, "R1", "fractional stage", "a fractional stage")

route({ beacon({ stage = 1, children = { child({ radius = 0 }) } }) })
fails(33, "R1", "no radius", "a child with no radius")

route({ beacon({ stage = 1, children = { child({ bandUp = -3 }) } }) })
fails(33, "R1", "negative or unusable band", "a negative band")

route({ beacon({ stage = 1, children = { child({ x = "here" }) } }) })
fails(33, "R1", "unplaceable", "a child with no usable position")

route({ beacon({ stage = 1, children = { child({ ordinal = -2 }) } }) })
fails(33, "R1", "unusable ordinal", "a negative ordinal")

route({ beacon({ stage = 1, children = {
    child({ rows = { { sense = "whenOn", action = "detonate" } } }) } }) })
fails(33, "R1", "unknown action", "an action the vocabulary never carried")

route({ beacon({ stage = 1, children = {
    child({ rows = { { sense = "whenever", action = "boss", arg = "Ragnaros" } } }) } }) })
fails(33, "R1", "unknown sense", "a sense the vocabulary never carried")

-- ★★★ AN INCOMPLETE ROW IS A NO-OP AND MUST NOT REACH THE DRIVER (A3.3 · row 24).
-- `Routes.ROW_ARG` is the one place that knows which actions take an arg, so the refusal
-- names THE FIELD - `no name` reads very differently mid-run from `incomplete row`.
-- ⚠ Measured before it was written (§458): all three of these BUILT.
route({ beacon({ stage = 1, children = {
    child({ rows = { { sense = "whenOn", action = "boss" } } }) } }) })
fails(33, "R1", "the action boss has no name", "a boss row with no name")

-- ★ THE BLANK STRING IS MISSING, NOT PRESENT, and `SetRow`'s `RowIncomplete` is the
-- precedent - it refuses `""` exactly as it refuses nil. ⚠ A gate written as
-- `if row.arg == nil` passes this fixture and ships an empty supertrack label.
route({ beacon({ stage = 1, children = {
    child({ rows = { { sense = "whenOn", action = "boss", arg = "" } } }) } }) })
fails(33, "R1", "the action boss has no name", "a boss row with a blank name")

-- ★ A SECOND ACTION, A DIFFERENT FIELD - so a gate hardcoded to `name` fails here.
route({ beacon({ stage = 1, children = {
    child({ rows = { { sense = "whenOn", action = "say" } } }) } }) })
fails(33, "R1", "the action say has no content", "a say row with no content")

-- ★★★ A12.2b · ONE ANCHOR PER STAGE, and it is the RUNTIME half of a guarantee whose
-- author-time half (the picker, A10.3e) does not exist. Three doors still accept a second,
-- and TELL-AND-TRUST holds at those doors - so the refusal lives HERE, and the manager never
-- meets a duplicate whether or not the pickers have landed.
-- ⚠ A12.2b's own mutation: *"accept the second → RI-41's measured lockstep returns"*.
route({ beacon({ id = "left", stage = 1, children = { child({ id = "l1", ordinal = 1 }) } }),
        beacon({ id = "right", stage = 1, children = { child({ id = "r1", ordinal = 1 }) } }) })
fails(33, "R1", "two beacons at stage 1", "a second anchor at one stage")

-- ★★ AND STAGE 0 IS EXEMT, which is the half a blanket check would break. RI-40: bucket 0
-- is the PASS-THROUGH and *"every recovery will be pooled in the same bucket as a catch
-- all"* - so many beacons there is the RULED shape, not a duplicate.
route({ beacon({ id = "r1", stage = nil, children = {} }),
        beacon({ id = "r2", stage = nil, children = {} }),
        beacon({ id = "s1", stage = 1, children = { child({ ordinal = 1 }) } }) })
local pooled, pwhy = Bucket.Build(33, "R1")
assert(pooled,
       "THE ANCHOR CHECK REACHED STAGE 0: many beacons pool there BY RULE (RI-40), and a "
       .. "guarantee about POSITIONS IN THE SEQUENCE does not apply to a bucket that is "
       .. "not a position. got: " .. tostring(pwhy))
assert(#pooled.stages[Bucket.ALWAYS] == 2, "both recovery beacons must reach bucket 0")

-- ★★★ A12.2f · NO SILENT ORPHAN. ⚠ Nothing WRITES a row `cid` today - a row lives under
-- its child, so the address is implicit - and an orphan arrives on IMPORT, which
-- reconstructs by matching the node prefix (A11.1a). ★ It belongs to RI-23's isolation
-- demonstration: the manifest claims *"what can be true right now"*, and a behaviour row
-- whose node does not exist can NEVER be true.
route({ beacon({ id = "b1", stage = 1, children = {
    child({ id = "c1", ordinal = 1,
            rows = { { sense = "whenOn", action = "boss", arg = "Ragnaros", cid = "ghost" } } }) } }) })
fails(33, "R1", "resolves to no characteristic", "a row addressing a child that is not there")

-- ⚠ AND A ROW NAMING ITS OWN CHILD IS FINE - the check must not refuse the ordinary case
-- it will meet once export starts writing addresses out.
route({ beacon({ id = "b1", stage = 1, children = {
    child({ id = "c1", ordinal = 1,
            rows = { { sense = "whenOn", action = "boss", arg = "Ragnaros", cid = "c1" } } }) } }) })
assert(Bucket.Build(33, "R1"),
       "A ROW NAMING ITS OWN CHILD WAS REFUSED: the orphan check is about an address with "
       .. "NOTHING BEHIND IT, not about the presence of an address")

-- ★★ AND A FRACTIONAL STAGE IS REFUSED HERE EVEN THOUGH ROW 9 SAYS NOTHING ENFORCES IT.
-- Row 9 records that the mint cannot produce one but THREE OTHER DOORS accept one, and that
-- *"the guard arrives with the pickers (A10.3e)"*. ⟶ BUCKET is downstream of all three, and
-- row 24 puts the failure here rather than mid-run. ⚠ This is not the picker's guard
-- arriving early - it is the constructor refusing to lay out what it cannot address.

-- =====================================================================
-- ★★★ STAGE MAY NOT FAIL (row 24). Garbage in, empty list out — never an error.
-- =====================================================================
route({
    beacon({ id = "b1", stage = 1, children = {
        child({ id = "c1", ordinal = 1 }), child({ id = "c2" }) } }),
    beacon({ id = "b2", stage = 2, children = { child({ id = "c4", ordinal = 1 }) } }),
    -- ⚠ CHILDLESS, because RI-40 locked stage 0 to self-completing beacons. This fixture
    -- used to give it a child `c3`, which is now the shape the slice bounces - and keeping it
    -- here would have made every row below quietly test the bounce instead of the hand-out.
    beacon({ id = "b0", stage = nil, children = {} }),
})
local big = assert(Bucket.Build(33, "R1"))

-- ⚠⚠ GRADED THROUGH `pcall`, AND IT HAS TO BE. A plain `assert(type(...) == "table")`
-- cannot see a CRASH - the call dies before the assert is reached, the smoke goes red on a
-- Lua error, and the row that claims to grade "STAGE may not fail" is blind to the only
-- failure that matters. ★ Mutation found it: removing the type guard produced *"attempt to
-- index local 'bucket'"* instead of this row's message.
local function stageSurvives(bucket, stage)
    local ok, res = pcall(Bucket.Stage, bucket, stage)
    return ok and type(res) == "table", res
end

for _, junk in ipairs({ 0, 1, "two", -1, 999 }) do
    for _, bad in ipairs({ "NIL", {}, "nonsense", 42 }) do
        local b = (bad ~= "NIL") and bad or nil
        assert(stageSurvives(b, junk),
               "STAGE FAILED ON A MISSING BUCKET: row 24 - a stage advance happens "
               .. "mid-run and mid-combat, raised by the sensor's own output. There is no "
               .. "good answer available at that moment, so it may not fail. ⚠ Every check "
               .. "belongs in Build; if STAGE can fail, BUCKET did not do its job")
    end
end
assert(#Bucket.Stage({}, 1) == 0 and #Bucket.Stage("nonsense", 1) == 0,
       "STAGE RETURNED NODES FROM A MALFORMED BUCKET")

-- ★ STAGE 0 IS ALWAYS IN THE HAND-OUT. Row 23: *"hand the current stage's bucket, WITH
-- stage 0"*. ⚠ The recovery beacon is the whole reason — it must be reachable at every
-- stage, and a hand-out that only carried the current one would strand it.
-- ⚠ THE CALLS NOW NAME A STEP. `Stage(bucket, stage)` alone means step 0 — the
-- pass-through only — which is a different question from *"what is armed at stage 1"*.
local s1 = Bucket.Stage(big, 1, 1)
local s2 = Bucket.Stage(big, 2, 1)

local function has(list, addr)
    for _, n in ipairs(list) do if n.address:find(addr, 1, true) then return true end end
    return false
end

-- ⚠⚠ THE NAMED ROWS COME FIRST, AND THE COUNTS COME LAST. Written the other way round
-- the count assertion answered for every one of them - mutation showed *"stage 1 must hand
-- out ... got 2"* for a dropped stage-0 AND *"got 5"* for a leak, two different faults
-- reported by one row that names neither. ★ Specific-behind-general, fourth instance.
assert(has(s1, ":b0") and has(s2, ":b0"),
       "THE STAGELESS BEACON WAS NOT HANDED OUT AT EVERY STAGE: stage 0 means ALWAYS "
       .. "ELIGIBLE (row 10), and a recovery beacon that is only reachable at the stage it "
       .. "was authored under is not a recovery beacon")
assert(has(s1, "c2"),
       "THE NO-STEP BUCKET WAS NOT HANDED OUT WITH ITS STAGE: A11.1a - *the no-step bucket "
       .. "always read*")
assert(not has(s2, "c1") and not has(s1, "c4"),
       "A NODE FROM ANOTHER STAGE WAS HANDED OUT: the gated set is *nodes at the current "
       .. "stage / step* (A11.3d), and a hand-out that leaks stages makes the bounce "
       .. "meaningless")

-- ★ THE COUNTS LAST - a backstop for anything the named rows above do not describe.
assert(#s1 == 3, "stage 1 at step 1 hands out c1, its no-step c2, and the stageless one, got " .. #s1)
assert(#s2 == 2, "stage 2 must hand out its one child plus the stageless one, got " .. #s2)

-- =====================================================================
-- ★★★ THE STEP IS GATED THE SAME WAY THE STAGE IS: **0 OR AN EXACT MATCH.**
--
-- Battlewrath, 2026-08-20, and the table is his:
--
--         Step:3
--         0 ← Check       *"their ordinal is not constructed"* — the pass-through
--         1 ← Bounce
--         2 ← Bounce
--         3 ← Check       the current position
--         4 ← Bounce
--
-- ⚠⚠ AND THE REASON IS CORRECTNESS, NOT COST: *"if it's checking every step in a ordinal,
-- it can complete every ordinal. Which is counter to what the ordinal gating is. **It's a
-- position in a sequence.**"* ⟶ With every step armed, a player who walks past step 3 while
-- standing at step 1 COMPLETES step 3.
-- ★ §435 handed out EVERY step of the current stage, and no fixture had a player reach a
-- step out of order — so nothing could see it. **The rule was built at one segment of a
-- four-segment bounce and the other three were assumed.**
-- =====================================================================
route({ beacon({ id = "bs", stage = 1, children = {
    child({ id = "s0" }),                       -- ordinalless: the pass-through
    child({ id = "s1", ordinal = 1 }),
    child({ id = "s2", ordinal = 2 }),
    child({ id = "s3", ordinal = 3 }),
    child({ id = "s4", ordinal = 4 }),
} }) })
local seq = assert(Bucket.Build(33, "R1"))
assert(seq.count == 5, "the sequence fixture must hold five nodes, got " .. seq.count)

local at3 = Bucket.Stage(seq, 1, 3)
assert(has(at3, ":s0"),
       "STEP 0 BOUNCED: an ordinalless child has no position in the sequence, so it is the "
       .. "PASS-THROUGH and is checked at every step (A11.3d, A11.1a)")
assert(has(at3, ":s3"),
       "THE CURRENT STEP BOUNCED: 3 is where the player is")
assert(not has(at3, ":s1") and not has(at3, ":s2"),
       "A STEP ALREADY PASSED WAS STILL ARMED: an ordinal is a POSITION IN A SEQUENCE, and "
       .. "re-arming a finished one lets it complete twice")
assert(not has(at3, ":s4"),
       "A FUTURE STEP WAS ARMED: this is the fault that matters. With step 4 armed at step "
       .. "3, a player who walks past it COMPLETES it - *if it is checking every step in an "
       .. "ordinal, it can complete every ordinal*, and the sequence stops being one")
assert(#at3 == 2, "step 3's hand-out is s0 and s3 only, got " .. #at3)

-- ★ AND THE SAME RULE AT EVERY POSITION, so the row is not a coincidence at 3.
for _, at in ipairs({ 1, 2, 4 }) do
    local got = Bucket.Stage(seq, 1, at)
    assert(#got == 2 and has(got, ":s0") and has(got, ":s" .. at),
           "the step gate must be 0-or-exact at EVERY position; it failed at " .. at)
end

-- ⚠ `FirstStep` IS THE LOWEST POSITIVE STEP, not 0. Step 0 is the pass-through - always
-- open - which is not the same as being first in the sequence.
assert(Bucket.FirstStep(seq, 1) == 1,
       "FirstStep must be the lowest POSITIVE ordinal, got " .. tostring(Bucket.FirstStep(seq, 1)))
route({ beacon({ id = "np", stage = 1, children = { child({ id = "only" }) } }) })
local nopos = assert(Bucket.Build(33, "R1"))
assert(Bucket.FirstStep(nopos, 1) == Bucket.ALWAYS,
       "a stage whose children have no ordinals starts at the pass-through")

-- ★ ROW 26 — THE SWAP RE-EVALUATES NOTHING. Both hand-outs come from tables formed at
-- BUCKET time, so the same node object is handed out at both stages rather than rebuilt.
local function find(list, addr)
    for _, n in ipairs(list) do if n.address:find(addr, 1, true) then return n end end
end
assert(find(s1, ":b0") == find(s2, ":b0"),
       "A STAGE ADVANCE REBUILT ITS NODES: row 26 says the swap is O(1) in buckets because "
       .. "all stage buckets are formed at BUCKET time. A rebuild puts work - and the "
       .. "chance of failure - exactly where row 24 forbids it")

-- =====================================================================
-- ★★★ BUCKET 0 IS SLICED: WHERE STAGE = 0, A `BID:CID` BOUNCES (RI-40, §439).
--
-- Battlewrath, 2026-08-20: *"beacon 0 are locked out of having children. Self completing
-- only. **A stage can still have 0 to solve for in a stage.**"* · *"it'd be sliced at Bucket
-- 0, so where Stage = 0 BID: if CID bounce."*
--
-- ⚠⚠ THESE ROWS WERE THE "MEASURED AND UNDER QUESTION" PIN, and they are rewritten HERE,
-- with the ruling, rather than having been quietly satisfied by one. ★ That is what the pin
-- was for: §437 measured that a recovery beacon's whole sequence armed at once and refused to
-- call it correct, so the behaviour could not drift while the question was open.
--
-- ★★ A BOUNCE, NOT A REFUSAL. The bench proposed refusing the BUILD (row 24) and that was
-- the worse answer — it breaks every existing route carrying one and raises a migration
-- question. A bounce is the gate doing its ordinary job, and the route still builds.
-- =====================================================================
route({
    beacon({ id = "st", stage = 1, children = {
        child({ id = "p1", ordinal = 1 }), child({ id = "p2", ordinal = 2 }) } }),
    beacon({ id = "rec", stage = nil, children = {
        child({ id = "r1", ordinal = 1 }), child({ id = "r2", ordinal = 2 }),
        child({ id = "r3", ordinal = 3 }) } }),
    beacon({ id = "rec2", stage = nil, children = { child({ id = "q1", ordinal = 1 }) } }),
})
local zero = assert(Bucket.Build(33, "R1"))

-- ⚠ THE EFFECT IS ASSERTED BEFORE THE COUNT, because `bounced` conflates two things:
-- WHETHER the slice happened and whether it was TOLD. ★ Mutation dropped the slice and
-- dropped the counter and both landed on the count row, which cannot tell them apart.
local atOne = Bucket.Stage(zero, 1, 1)
assert(not has(atOne, ":r1") and not has(atOne, ":r2") and not has(atOne, ":r3"),
       "A STAGE-0 SEQUENCE WAS ARMED: stage 0 is taken WHOLESALE, so its children would ALL "
       .. "be armed at once - the fault §436 fixed at stage level, alive inside stage 0. "
       .. "★ The slice removes the SHAPE rather than patching either rule")
assert(zero.bounced == 4,
       "THE BOUNCE WAS SILENT: `rec` has three children and `rec2` has one, and §90 S4 is "
       .. "TELL-and-trust - dropping four nodes without a number is the quiet kind of "
       .. "correct. got " .. tostring(zero.bounced))

-- ★★ AND THE BEACON ITSELF SURVIVES, addressed `BID:` with no `CID`. *"BID: if CID
-- bounce"* keeps the BID. ⚠ A first cut emptied the whole beacon and lost the recovery node
-- entirely - the literal reading and the useful one agree, and the bench had neither.
assert(has(atOne, ":rec") and has(atOne, ":rec2"),
       "THE RECOVERY BEACON WAS LOST WITH ITS CHILDREN: only the `CID` bounces. The beacon "
       .. "becomes the self-completing item A1.2 already describes")
assert(#zero.stages[Bucket.ALWAYS] == 2,
       "BUCKET 0 MUST HOLD ITS BIDs: with no children admitted, every stage-0 node is "
       .. "childless and carries step 0 - *within the 0 stage bucket, it'd just read through "
       .. "every BID*")
assert(#slot(zero.stages[Bucket.ALWAYS], 1) == 0,
       "A STEP-1 ROW REACHED BUCKET 0: nothing with a `CID` may reach stage 0 at all, so no "
       .. "row there can carry a positive ordinal")

-- ★★★ AND STEP 0 INSIDE A *STAGED* BEACON IS UNTOUCHED — the two zeros are different, and
-- this row is the one that keeps them apart. *"A stage can still have 0 to solve for in a
-- stage."*
route({ beacon({ id = "st", stage = 1, children = {
    child({ id = "s1", ordinal = 1 }), child({ id = "sp" }) } }) })
local staged = assert(Bucket.Build(33, "R1"))
assert(staged.bounced == 0,
       "A STAGED BEACON'S ORDINALLESS CHILD WAS BOUNCED: the slice is STAGE 0's, not step "
       .. "0's. got " .. tostring(staged.bounced))
assert(has(Bucket.Stage(staged, 1, 1), ":sp"),
       "THE PASS-THROUGH INSIDE A STAGE STOPPED BEING CHECKED: step 0 is unchanged by RI-40")

-- =====================================================================
-- ★★★ A12.2d · ONE RID IN, NOTHING ELSE OUT — the isolation demonstration
--
-- ★★ RI-23's REPETITION RULING STANDS ON THIS. His reason is what makes the row
-- load-bearing rather than ceremonial: **SavedVariables load WHOLESALE**, so isolation
-- cannot come from loading less - *"it must come from BUILDING FROM ONE RID ONLY, keyed
-- by address."*
--
-- ⚠ SATISFIED BY CONSTRUCTION TODAY - `Build` calls `Routes.Get(rid)` and reads ONE
-- route. **The row exists to PROVE it, not to ask for it**, because *isolated by
-- construction* is exactly the claim a wholesale-loaded store makes people doubt.
-- =====================================================================
local twinA = { id = "RA", mapID = 33, beacons = { beacon({ id = "b1", stage = 1, rows = {},
    children = { child({ id = "c1", ordinal = 1, x = 10 }) } }) } }
local twinB = { id = "RB", mapID = 33, beacons = { beacon({ id = "b1", stage = 1, rows = {},
    children = { child({ id = "c1", ordinal = 1, x = 999 }) } }) } }

-- ⚠⚠ LOOKALIKES IN EVERYTHING THE ADDRESS CARRIES - same map, stage, ordinal, ids - AND
-- DELIBERATELY DIFFERENT IN ONE THING THAT RIDES THE RECORD: the position.
--
-- ★★★ MUTATION FORCED THAT, and the lesson is sharper than the row. The first cut made
-- them identical and asserted the ADDRESS PREFIX - which **cannot witness origin**, because
-- the address is COMPOSED FROM THE `rid` PARAMETER, not read off the record. Swapping the
-- build to read RB's beacons still stamped every node `33:RA:...`, and the test passed.
-- ⟶ **A field that the builder STAMPS can never testify to where the data came from.**
-- Only a field that TRAVELS with the record can, so the twins differ in `x` and the
-- assertion below reads it.
local twins = { RA = twinA, RB = twinB }
local realGet = Routes.Get
Routes.Get = function(id) return twins[id] end

local bkA = assert(Bucket.Build(33, "RA"), "the twin fixture must build")
for _, st in pairs(bkA.stages) do
    for _, node in ipairs(st) do
        assert(node.address:find("^33:RA:"),
               "A SECOND ROUTE'S RECORD REACHED THIS BUCKET: RI-23's ruling stands on "
               .. "building from ONE RID ONLY, keyed by address - the store loads WHOLESALE, "
               .. "so isolation cannot come from loading less. Found: " .. node.address)
    end
end
assert(bkA.count == 1, "and exactly the one route's node, got " .. tostring(bkA.count))

-- ★★★ THE ROW THAT ACTUALLY WITNESSES IT. The address is stamped; the POSITION is
-- carried. A bucket holding B's coordinates under A's address is precisely the failure
-- RI-23's ruling stands against, and it is invisible to every address assertion.
local only
for _, st in pairs(bkA.stages) do for _, n in ipairs(st) do only = n end end
assert(only.x == 10,
       "THIS BUCKET CARRIES THE OTHER ROUTE'S RECORD: the twins are identical in everything "
       .. "the address holds and differ only in POSITION, so x=999 here means B's node was "
       .. "built under A's address. **SavedVariables load WHOLESALE** - isolation comes from "
       .. "building from ONE RID, and nothing downstream could tell. got x="
       .. tostring(only.x))

-- =====================================================================
-- ★★★ A12.2e · THE COMPOSED GATE EQUALS THE PREFIX
--
-- ★ The row grades the EQUALITY, not the layout: rows are NESTED under their node rather
-- than each carrying a composed prefix, and that is equivalent **because every row is
-- reachable only through its node** - so it inherits exactly one prefix. ⟶ What must hold
-- is that the prefix reachable FROM a row is the one its node carries: *the same manifest
-- a combined line would have produced, so nothing is lost by not repeating.*
-- =====================================================================
Routes.Get = realGet
route({
    beacon({ id = "b1", stage = 1, rows = {}, children = {
        child({ id = "c1", ordinal = 1, x = 10 }),
        child({ id = "c2", ordinal = 2, x = 20 }),
        child({ id = "cx", x = 30 }),
    } }),
    beacon({ id = "b5", stage = 5, rows = {}, children = {
        child({ id = "e1", ordinal = 1, x = 40 }) } }),
})
local gated = assert(Bucket.Build(33, "R1"), "the multi-node fixture must build")
local seen = 0
for stage, st in pairs(gated.stages) do
    for _, node in ipairs(st) do
        for i, r in ipairs(node.rows) do
            seen = seen + 1
            -- ⚠⚠ THE PREFIX IS READ BACK FROM THE ROW'S OWN REACH - node, stage, step -
            -- and compared to the node's record. A row that resolved under a different
            -- step than its node carries would be a manifest that disagrees with itself.
            assert(node.stage == stage,
                   "A NODE SITS UNDER A STAGE ITS RECORD DOES NOT CARRY: the bucket key IS "
                   .. "the stage address, so a node filed under one stage and stamped with "
                   .. "another makes the composed gate a lie. node "
                   .. node.address .. " stamped " .. tostring(node.stage)
                   .. ", filed under " .. tostring(stage))
            assert(type(node.step) == "number",
                   "A ROW RESOLVES UNDER NO STEP: `mapID:rid:stage:step` is the four-part "
                   .. "bounce, and a row whose step is absent cannot be gated at all - "
                   .. node.address .. " row " .. i)
        end
    end
end
assert(seen >= 4, "every row of a multi-node route must be checked, saw " .. tostring(seen))

-- =====================================================================
-- ★ THE FENCE — BUCKET does construction, not geometry and not scheduling.
-- =====================================================================
assert(Bucket.Evaluate == nil and Bucket.PointFire == nil and Bucket.NextIn == nil,
       "BUCKET GREW A HOT PATH: it runs ONCE PER RUN. Geometry is the rule's and the "
       .. "schedule is the sensor's, and a third copy here is a third answer")
-- ⚠ STILL NIL **AS SHIPPED** - the block below installs one deliberately and clears
-- it again. Nothing in the addon fills this; the manager will, when it binds (A12.2c).
assert(Bucket.Resolve == nil,
       "THE ACTION-BINDING SEAM IS FILLED: row 25 wants every action id resolved to the "
       .. "function the runtime holds, and the runtime holds NO functions - adaptor.lua is "
       .. "a vocabulary. ⚠ Filling this in here would be inventing the consumer's handling, "
       .. "which the fence puts outside this lane")

-- =====================================================================
-- ★★★ THE BAND LADDER'S FIRST RUNG **IS** THE DEFAULT (§714).
--
-- ⚠ `routes.lua` declares `BAND_STEPS` and deliberately does NOT read `Bucket.BAND_DEFAULT`
-- to state it: `bucket.lua` is not loaded at that point, and a load-order dependency taken to
-- state a constant buys a crash to avoid a test. ⟶ THIS is that test, and it is the same
-- shape as `smoke_dungeonrunroutes.lua:592`/`:595`, which pin R's ladder to its ends.
-- ⚠ IT LIVES HERE AND NOT BESIDE THOSE ROWS because the assertion pairs TWO FILES, and
-- this is the smoke that loads both. Put beside them it read well and did not run:
-- `attempt to index global 'Bucket' (a nil value)`.
--
-- ★ THE CEILING IS A JUDGEMENT, NOT A MEASUREMENT (Battlewrath, 2026-08-27): *"any more and
-- we're reading through floors, which is why the system exists to protect against."*
assert(Routes.BAND_STEPS[1] == Bucket.BAND_DEFAULT,
       ("THE BAND LADDER DOES NOT START AT THE DEFAULT: the first rung is %s and the default "
        .. "is %s. A ladder whose first rung is not the default offers an author a value the "
        .. "store would already have used, or hides the one it did - the same fault the R "
        .. "ladder's ends are pinned against")
       :format(tostring(Routes.BAND_STEPS[1]), tostring(Bucket.BAND_DEFAULT)))

-- ★★★ B3 · THE ARG IS THE SHAPE ITS ACTION DECLARES — TYPE, AND A CAP
--
-- ⚠ A route TRAVELS by design, so everything on it is untrusted input. The verb side is
-- closed; this is the value side, which measurement found wide open (§464).
-- =====================================================================
for _, bad in ipairs({ { evil = true }, 1234, true }) do
    route({ beacon({ stage = 1, rows = {}, children = {
        child({ ordinal = 1,
                rows = { { sense = "whenOn", action = "boss", arg = bad } } }) } }) })
    local b, why = Bucket.Build(33, "R1")
    assert(b == nil,
           "AN ARG OF THE WRONG TYPE BUILT: `ROW_ARG_RULE.boss.type` is `string` and a "
           .. "consumer promised a name would meet a " .. type(bad) .. ". A body doing "
           .. "`arg:sub()` breaks on it, and one that ITERATES a table argument is doing "
           .. "what the FILE said rather than what the addon said")
    assert(tostring(why):find("must be string", 1, true),
           "and the refusal names the shape it wanted, got: " .. tostring(why))
end

-- ★★ THE CAP, WHERE A PERSON TYPES IT. 255 is `FrameXML/ChatFrame.xml:21` - sourced,
-- not recalled - and Battlewrath's reason is design as much as limit: *"keeps the notes
-- from being documentaries."*
-- ⚠ READ FROM THE DECLARATION, not written as 255 here: a literal in the test is a COPY,
-- and a copy is what drifted twice in two days (§457/§458).
local cap = Routes.ROW_ARG_RULE.say.max
route({ beacon({ stage = 1, rows = {}, children = {
    child({ ordinal = 1, rows = { { sense = "whenOn", action = "say",
                                    arg = string.rep("x", cap) } } }) } }) })
assert(Bucket.Build(33, "R1"),
       "TEXT EXACTLY AT THE CAP WAS REFUSED: the limit is what the chat box HOLDS, so the "
       .. "boundary value is legal - an off-by-one here refuses a line the client accepts")

route({ beacon({ stage = 1, rows = {}, children = {
    child({ ordinal = 1, rows = { { sense = "whenOn", action = "say",
                                    arg = string.rep("x", cap + 1) } } }) } }) })
fails(33, "R1", "over the", "text one letter over the cap")

-- ★★★ AND A `source = "run"` ARG IS **NOT** CAPPED. This is the row that stops the cap
-- becoming "cap everything": a boss name was PICKED from what the game named (A3.1), so a
-- length limit could refuse a real boss. The declaration says which is which, and this
-- proves the guard reads that rather than applying one rule to every arg.
assert(Routes.ROW_ARG_RULE.boss.max == nil,
       "the declaration must leave a picked arg uncapped")
route({ beacon({ stage = 1, rows = {}, children = {
    child({ ordinal = 1, rows = { { sense = "whenOn", action = "boss",
                                    arg = string.rep("B", cap + 50) } } }) } }) })
assert(Bucket.Build(33, "R1"),
       "A PICKED ARG WAS CAPPED: `boss` comes from the RUN's own bosses, not from a "
       .. "keyboard, so its length is whatever the game named. Capping it would refuse a "
       .. "real boss - and the cap exists to keep TYPED notes short, which is a different "
       .. "problem with a different owner")

-- ★ AND AN ACTION THAT TAKES NOTHING DECLARES NO RULE, so neither guard reaches it.
-- ★★ AND `supertrack` IS NOT A VERB AT ALL ANY MORE (AL-19). It is the node's LED TO
-- tick: *"the super tracker is what gets the player TO the sense site."* A row form
-- could only fire on `whenOn` - pointing the arrow at the node the reader is already
-- standing in.
for _, w in ipairs(Routes.ROW_ACTIONS) do
    assert(w ~= "supertrack",
           "`supertrack` IS BACK IN THE CLOSED ACTION LIST: AL-19 moved it to the "
           .. "node's characteristic. Every entry in this list has to be something "
           .. "that HAPPENS WHEN THE READER IS HERE, and waypointing is what got "
           .. "them here")
end

-- =====================================================================
-- ★★★ A12.2g (B2) · A NODE WITH NO BEHAVIOUR ROWS IS REFUSED, BY NAME
--
-- ⚠⚠ It can never complete - the ledger waits for ALL a node's tabs and there are none -
-- so the run arms, points the arrow and never advances. Row 24: named at BUILD, not
-- discovered mid-run.
-- ★ UNREACHABLE THROUGH AUTHORING, deliberately: `RowsOf` seeds every node (A13.1). This
-- guard is for the files the addon did not write - a hand-edited SavedVariables or an
-- import - the same two sources every other sweep in `routes.lua` is written for.
-- ⚠ The stub `RowsOf` here does NOT seed, which is what lets this case be constructed at
-- all. That is the fixture doing its job, not a disagreement with the shipped door.
-- =====================================================================
route({ beacon({ stage = 1, rows = {}, children = {
    child({ ordinal = 1, rows = {} }) } }) })
fails(33, "R1", "no behaviour rows", "a node carrying no rows at all")

-- =====================================================================
-- ★★★ THE ARRIVAL ROW · sense with NO ACTION (AL-18 · A13.1)
--
-- `When on` with no action means REACHED. ⚠ The SENSE stays required and the asymmetry is
-- the rule: a row with no sense is nothing listening, which is not a row.
-- =====================================================================
route({ beacon({ stage = 1, rows = {}, children = {
    child({ ordinal = 1, rows = { { sense = "whenOn" } } }) } }) })
local arr, arrWhy = Bucket.Build(33, "R1")
assert(arr,
       "AN ARRIVAL ROW WOULD NOT BUILD: AL-18 makes a row's ACTION optional - arrival IS "
       .. "the behaviour of a placed node. This is the SEED every node carries, so a "
       .. "refusal here refuses every route. got: " .. tostring(arrWhy))
local arrNode
for _, e in ipairs(arr.stages[1]) do if e.step == 1 then arrNode = e end end
assert(arrNode and arrNode.rows[1] and arrNode.rows[1].sense == "whenOn",
       "the arrival row must reach the driver with its sense intact")
assert(arrNode.rows[1].action == nil,
       "AN ACTION WAS INVENTED FOR AN ACTIONLESS ROW: AL-18 keeps the closed capability "
       .. "list untouched - a no-op word would be a NAMEABLE verb, and the list is the "
       .. "security boundary (§464). Absence is not a capability")

-- ⚠ AND THE SENSE IS STILL REQUIRED - the row that stops "optional action" becoming
-- "optional everything".
route({ beacon({ stage = 1, rows = {}, children = {
    child({ rows = { { action = "note", arg = "x" } } }) } }) })
fails(33, "R1", "unknown sense", "a row with an action and NO sense")

-- =====================================================================
-- ★★★ A12.2j · THE TYPE IS *READ*, AND ONLY A NON-STRING RULE CAN PROVE IT
--
-- ⚠⚠ THIS ROW EXISTS BECAUSE THE MUTATION RAN SILENT. A12.2j names its own mutation -
-- *"hard-code `type(arg) == \"string\"` in the guard instead of reading the rule"* - and when
-- it was finally written (§705) the suite **passed with the guard broken**. Every entry in
-- the shipped `ROW_ARG_RULE` declares `type = "string"`, so the two guards are behaviourally
-- IDENTICAL against the shipped vocabulary. Fourteen assertions above test the type check and
-- not one of them could tell a READ from a RESTATEMENT.
--
-- ★ THE ACCEPTANCE SAW IT COMING and said so in the row: the copy fails *"the day `note`
-- becomes a NoteID"*. ⟶ A guard graded only by a future state is UNGRADED TODAY, so this
-- brings that day forward instead of waiting for it.
--
-- ⚠ THE SHIPPED VOCABULARY IS NOT EDITED. A stub that disagrees with the client is what hid
-- a defect for four commits (§457, the note at the head of this file). The synthetic word is
-- installed, proven, and REMOVED - so nothing below it reads a vocabulary the client lacks.
-- =====================================================================
do
    local savedActions, savedRule, savedArg = Routes.ROW_ACTIONS, {}, Routes.ROW_ARG.tally
    for k, v in pairs(Routes.ROW_ARG_RULE) do savedRule[k] = v end

    local acts = {}
    for i, w in ipairs(savedActions) do acts[i] = w end
    acts[#acts + 1] = "tally"
    Routes.ROW_ACTIONS = acts
    Routes.ROW_ARG_RULE.tally = { type = "number", source = "run" }
    Routes.ROW_ARG.tally = "count"

    -- ★★ THE BITING ROW. A guard that READS accepts 7 because the rule says `number`; a
    -- guard that restates `"string"` refuses it. This assertion is the ONLY thing in the
    -- suite that separates them.
    route({ beacon({ stage = 1, rows = {}, children = {
        child({ ordinal = 1,
                rows = { { sense = "whenOn", action = "tally", arg = 7 } } }) } }) })
    local built, why = Bucket.Build(33, "R1")
    assert(built,
           "A NUMBER ARG WAS REFUSED FOR AN ACTION WHOSE RULE DECLARES `number`: the guard is "
           .. "RESTATING a type instead of READING one. `ROW_ARG_RULE` exists so the pane, the "
           .. "guard and the driver read ONE declaration - a guard carrying its own copy is the "
           .. "shape that drifted twice in two days (§457/§458). Refused with: " .. tostring(why))

    -- ⚠ AND THE CONVERSE, or the row above is satisfied by a guard that checks NOTHING.
    -- ★ Without this, deleting the type check entirely would pass the assertion above.
    route({ beacon({ stage = 1, rows = {}, children = {
        child({ ordinal = 1,
                rows = { { sense = "whenOn", action = "tally", arg = "seven" } } }) } }) })
    local no, noWhy = Bucket.Build(33, "R1")
    assert(no == nil,
           "A STRING BUILT FOR AN ACTION DECLARED `number`: reading the declaration is only "
           .. "half of it - the value must still be HELD to what was read, or the rule is "
           .. "decoration")
    assert(tostring(noWhy):find("must be number", 1, true),
           "and the refusal names the type the DECLARATION asked for, got: " .. tostring(noWhy))

    Routes.ROW_ACTIONS = savedActions
    Routes.ROW_ARG_RULE.tally = nil
    Routes.ROW_ARG.tally = savedArg
    assert(Routes.ROW_ARG_RULE.tally == nil and #Routes.ROW_ACTIONS == #savedActions,
           "the synthetic word must not outlive its own test")
end

-- ★★★ B4 (AL-17) · THE RESOLVER IS REACHABLE **ONLY THROUGH** THE CLOSED LIST
--
-- ⚠⚠ The seam used to return INSTEAD of checking, so installing a resolver silently
-- retired the closed vocabulary. AL-17 closed it by definition: *"the resolver consulted
-- AFTER that check and never instead of it."*
-- ★ The row that matters is the SECOND one. A test that only proves a listed word reaches
-- the resolver passes either way - it is the UNLISTED word never arriving that is the
-- guarantee, and it is the half a happy-path test cannot see.
-- =====================================================================
local sawResolve = {}
Bucket.Resolve = function(kind, code)
    sawResolve[#sawResolve + 1] = kind .. ":" .. tostring(code)
    return code
end

route({ beacon({ stage = 1, rows = {}, children = {
    child({ rows = { { sense = "whenOn", action = "boss", arg = "Ragnaros" } } }) } }) })
assert(Bucket.Build(33, "R1"), "a listed word must still build with a resolver installed")
assert(#sawResolve > 0,
       "THE RESOLVER WAS NEVER CONSULTED: it is the consuming addon's say over what a "
       .. "published word RESOLVES TO, and a seam nothing reaches is not a seam")

sawResolve = {}
route({ beacon({ stage = 1, rows = {}, children = {
    child({ rows = { { sense = "whenOn", action = "loadstring", arg = "x" } } }) } }) })
local no, noWhy = Bucket.Build(33, "R1")
-- ⚠⚠ THIS ROW COMES FIRST AND MUTATION IS WHY. Put behind *"it must still be refused"*,
-- moving the resolver back in front of the list was reported as **a route that built** -
-- true, and the CONSEQUENCE rather than the cause. The reader is sent to the refusal list
-- instead of to the one line that decides who may reach the seam.
assert(#sawResolve == 0,
       "AN UNLISTED WORD REACHED THE RESOLVER: the ORDER IS THE GUARANTEE. A route is data "
       .. "that TRAVELS (`routes.lua:14` drops the run back-reference so it can), so it may "
       .. "NAME a verb from the list the consumer publishes and never choose the vocabulary "
       .. "itself. A resolver reachable with an unlisted word lets the FILE decide what is "
       .. "callable. Reached with: " .. table.concat(sawResolve, ", "))
assert(no == nil, "an unlisted word must still be refused with a resolver installed")
assert(tostring(noWhy):find("unknown action", 1, true),
       "and the refusal still names it, got: " .. tostring(noWhy))

-- ★★ AND A RESOLVER RETURNING **nil** IS A REFUSAL LIKE ANY OTHER (A12.2i's second
-- IS NOT). ⚠ The list bounds what may be ASKED, not what must be GRANTED - so a consumer
-- that publishes a word and then declines to bind it must still be able to say no.
-- ★ Without this row the seam could be read as *"the resolver always says yes"*, and the
-- happy-path row above passes either way.
Bucket.Resolve = function() return nil end
route({ beacon({ stage = 1, rows = {}, children = {
    child({ ordinal = 1,
            rows = { { sense = "whenOn", action = "boss", arg = "Ragnaros" } } }) } }) })
local declined, declinedWhy = Bucket.Build(33, "R1")
assert(declined == nil,
       "A RESOLVER'S REFUSAL WAS IGNORED: the closed list bounds what may be ASKED; the "
       .. "RESOLVER decides what is granted. A word on the list whose resolver returns nil "
       .. "has no callable, and building it would hand the driver a row nothing can run")
assert(tostring(declinedWhy):find("boss", 1, true),
       "and the refusal names the word, got: " .. tostring(declinedWhy))

Bucket.Resolve = nil

print("smoke_bucket: OK - one bucket per stage, bare rows; every authorable word builds; 15 refusals each naming its cause; "
      .. "STAGE cannot fail; the band conversion joins to the rule")
