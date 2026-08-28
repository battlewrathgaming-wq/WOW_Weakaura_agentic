-- Offline smoke for COA_DungeonRun routes.lua - the AUTHORING surface (A1-A6).
--
-- ★★★ THIS FILE IS DELIBERATELY EMPTY OF THE ASSERTIONS IT EXISTS FOR, and stood up
-- BEFORE the code it will test (acceptance A7.1, proposition §10 step 2).
--
-- The reason, stated so nobody deletes the emptiness as an oversight: a smoke written
-- AFTER the code is written TO THE CODE. It asks "does it do what it does", finds that
-- it does, and reports green. A smoke written FIRST is written to the CRITERION - the
-- file is here, the slots are named, and each hole lands into somewhere that is already
-- asking it a question in words that came from the acceptance rather than the build.
--
-- ⚠⚠ SO A GREEN FROM THIS FILE IS NOT COVERAGE, AND IT SAYS SO OUT LOUD. The closing
-- line prints how many criteria are still UNCOVERED. Reading "OK" here and concluding
-- the authoring surface is tested is exactly the failure the roster exists to prevent -
-- an empty test suite passes perfectly.
--
-- What IS asserted today: the load chain stands up, and the anchors the holes attach to
-- behave as they behave now. A1.1 says the work is ADDITIVE - no existing signature
-- changes - so those baselines must survive every hole. If one goes red when G2 lands,
-- the change was not additive, and that is worth a red.
--
-- Run: .tools/lua51/lua5.1.exe addons/tools/smoke/smoke_dungeonrunroutes.lua

local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }

local W = { mapID = 33, floor = 6 }
function UnitName() return "Gravekeeper" end
function GetCurrentPlayerPosition() return 1, 2, 3, W.mapID end
function GetCurrentMapDungeonLevel() return W.floor end
function GetMapInfo() return "ShadowfangKeep", 668, 768 end
function GetRealZoneText() return "Shadowfang Keep" end
function GetSubZoneText() return "" end
function time() return 1786600000 end
function GetTime() return 100.0 end
UIParent = {}

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_DungeonRun\]]
local NS = {}
NS.Say = function(m) DEFAULT_CHAT_FRAME:AddMessage(m) end
local function load(f) assert(loadfile(ROOT .. f))("COA_DungeonRun", NS) end
load("store.lua")
load("routes.lua")
-- ★ A5's subject. It is UI-side (RI-16: "on the UI side") and depends on nothing, which
-- is why the model's own smoke can load it without dragging a pane in behind it.
load("adaptor.lua")
local Store, Routes = NS.Store, NS.Routes

COA_DungeonRunDB = nil
assert(Store.Load(), "fresh db")
assert(Routes, "routes.lua did not publish Routes")
Routes.Init()

for _, leaked in ipairs({ "PLACE", "tbl", "composeId", "mint", "nextBeaconId", "notes" }) do
    assert(_G[leaked] == nil, "LEAKED GLOBAL: " .. leaked)
end


-- ⚠⚠ THIS BLOCK RUNS FIRST, AND MUTATION PUT IT HERE. `RowsOf` is the read door
-- for every other function in this file, so a seed fault damages the FIRST test
-- that touches a node and gets reported by whatever that test was about - once as
-- *'never typed is a property of the data path'*, which names nothing about seeding.
-- ★ It needs no fixture (both tables below are local), so there is no reason for
-- it to run anywhere but first.
-- =====================================================================
-- ★★★ THE ORDINAL RATCHETS AT THE MINT, AND THE AUTHOR SELECTS OUT
--
-- Battlewrath, 2026-08-21: *"setting the baseline to ratchet and then select out."*
-- ⚠ `NextOrdinal` had NO CALLER, so every child ever placed was a ZERO node - and the
-- architect's mapping says `start` = ordinal 1, which nothing minted.
-- =====================================================================
local ratchetRid = select(1, Routes.Create("ratchet", 33))
local ratchetR = Routes.Get(ratchetRid)
ratchetR.beacons = { { id = "rb", kind = "beacon", stage = 1, mapX = 0.5, mapY = 0.5,
                       x = 0, y = 0, z = 0, mapID = 33, children = {} } }
local rb = ratchetR.beacons[1]
local k1 = assert(Routes.AddChildHere(ratchetRid, rb), "the first child must mint")
local k2 = assert(Routes.AddChildHere(ratchetRid, rb), "the second child must mint")

assert(k1.ordinal == 1,
       "THE FIRST PLACED CHILD HAS NO ORDINAL: the baseline RATCHETS - a placed child is a "
       .. "POSITION unless its author says otherwise. Without this every child is a zero "
       .. "node, nothing advances by step, and no authored route has a sequence at all. "
       .. "got " .. tostring(k1.ordinal))
assert(k2.ordinal == 2,
       "THE RATCHET DID NOT ADVANCE: the second child takes the NEXT ordinal, which is what "
       .. "makes a placement order a sequence. got " .. tostring(k2.ordinal))

-- ★★ AND SELECTING OUT IS A CHOICE, not the default. The zero node still exists - it is
-- reached by clearing the ordinal, which is the other half of his rule.
-- ★★ AND  IS THE OPT-OUT AT THE DOOR, STORED AS ABSENCE - the data model's §A3.10
-- rule (*0 is the RECORD form, nil the STORE form*), which  has applied to
-- STAGES since S7 and this door did not apply to ORDINALS.
-- ⚠ A stored zero is not harmless: **0 is TRUE in Lua**, so every 
-- would read it as *has an ordinal* while it behaves as a zero node at build.
-- ★★ AND `0` IS THE OPT-OUT AT THE DOOR, STORED AS ABSENCE (Battlewrath, 2026-08-21:
-- *"with 0 being the opt out"*). The data model's §A3.10 rule - `0` is the RECORD
-- form, `nil` the STORE form - which `AddBeacon` has applied to STAGES since S7 and
-- this door never applied to ORDINALS.
-- ⚠ A stored zero is not harmless: **`0` is TRUE in Lua**, so every `if child.ordinal`
-- reads it as *has an ordinal* while it behaves as a zero node at build.
Routes.SetChildOrdinal(rb, k2, 0)
assert(k2.ordinal == nil,
       "A STORED ZERO SURVIVED THE DOOR: 0 is the OPT-OUT and nil is what is stored - two "
       .. "forms of one fact must never both exist. A stored 0 reads TRUE to `if child.ordinal` and behaves as a zero node at build, which is the "
       .. "§A3.10 exists to prevent")

Routes.SetChildOrdinal(rb, k2, 2)
assert(k2.ordinal == 2, "a real ordinal still stores")
Routes.SetChildOrdinal(rb, k2, nil)
assert(k2.ordinal == nil,
       "AN AUTHOR CANNOT SELECT OUT: the greedy/detector node is reached by CLEARING the "
       .. "ordinal, and a ratchet with no exit would make every node a position")

-- =====================================================================
-- ★★★ `Next(Type, arg)` · THE DOOR (AL-21)
-- =====================================================================
assert(Routes.SetNext(k1, "stage") == "stage", "a bare type stores")
assert(k1.nextArg == nil, "and `stage` carries no arg")
assert(Routes.SetNext(k1, "set", 4) == "set" and k1.nextArg == 4, "`set` carries its N")

-- ⚠⚠ A `set` WITH NO N IS HALF-STATED and is REFUSED, not stored. ★ The whole reason
-- §479 rejected "Set with no action" as the no-outcome value: it would make
-- started-and-unfinished indistinguishable from nothing-follows.
assert(Routes.SetNext(k1, "set") == "set" and k1.nextArg == 4,
       "A HALF-STATED `set` WAS STORED: `set` is the only type that takes an N, so it is "
       .. "the only one that can be incomplete - and storing one would collapse the "
       .. "distinction between an author mid-edit and an author who means nothing follows")

assert(Routes.SetNext(k1, "interpretiveDance") == "set",
       "AN UNKNOWN TYPE WAS STORED: `NEXT_TYPES` is closed, and the row travels")

-- ★ CLEARING TAKES THE ARG WITH IT - *"we capture what is currently true"*, the same rule
-- A13.3 applies to a row's action and its arg.
Routes.SetNext(k1, nil)
assert(k1.nextType == nil and k1.nextArg == nil,
       "THE ARG OUTLIVED THE TYPE THAT OWNED IT: clearing returns the node to its DERIVED "
       .. "default and stores nothing (§79)")

-- =====================================================================
-- ★★★ A13.6's ORDER · `MigrateRIDs` → `MigrateRows` → `DropRetired`, LOAD-BEARING BOTH WAYS
--
-- ⚠⚠ THE ROW CALLS IT LOAD-BEARING AND NOTHING GRADED IT. Both edges are real:
--   · MigrateRows BEFORE DropRetired - the sweep would otherwise delete the flat fields on
--     the same load that would have converted them. **Migrate before you retire.**
--   · MigrateRIDs FIRST - the rows are keyed by route and a half-migrated key set would be
--     walked twice under two names.
-- ★ Asserted on the SOURCE of `Routes.Init`, because the property is an ORDER and no
-- runtime observation distinguishes it once every hook has run.
local initSrc = io.open("addons/COA_DungeonRun/routes.lua"):read("*a")

-- ⚠⚠ POSITIONS IN THE SOURCE, not a captured function body. A `match` anchored on the
-- function's closing `end` failed against a perfectly correct `Init` - the repo carries
-- MIXED line endings and the pattern was one shape of them. ★ The property is an ORDER,
-- and three `find` calls answer it with nothing to get wrong.
local at = initSrc:find("function Routes%.Init%(%)")
assert(at, "Routes.Init must be findable to grade its order")

-- ⚠⚠ THE SEARCH IS BOUNDED TO `Init`'S BODY, and mutation is why. Unbounded, it ran to
-- the end of the file and found each hook's **DEFINITION** rather than its CALL - so
-- removing the call from `Init` still "found" `MigrateRIDs` (at its own `function` line,
-- which sits after `MigrateRows`'s call) and the row reported the wrong fault entirely.
-- ★ A search for a NAME finds the nearest occurrence, not the one you meant. Third time
-- this week that a name-search answered a question about USE.
local stop = initSrc:find("\nfunction ", at) or #initSrc
local body = initSrc:sub(at, stop)
local pRid = body:find("Routes.MigrateRIDs", 1, true)
local pRow = body:find("Routes.MigrateRows", 1, true)
local pDrop = body:find("Routes.DropRetired", 1, true)
assert(pRid and pRow and pDrop,
       "ALL THREE LOAD HOOKS MUST RUN FROM `Init` - a migration nobody calls is a migration "
       .. "that did not happen")
assert(pRid < pRow,
       "`MigrateRIDs` MUST RUN FIRST: the rows are keyed by route, and a half-migrated key "
       .. "set would be walked twice under two names")
assert(pRow < pDrop,
       "`MigrateRows` MUST RUN BEFORE `DropRetired`: the sweep would delete the flat fields "
       .. "on the SAME LOAD that would have converted them. **Migrate before you retire** - "
       .. "the same fault shape as refusing an empty node before the seed lands")

-- =====================================================================
-- ★★★ A13.1 (B0) · THE SEED — A PLACED NODE ALWAYS HAS ONE ROW
--
-- AL-18: arrival IS the behaviour of a placed node, and there is NO fourth sense word for
-- it. ★ The door is `RowsOf` because **a door has no "before"** - a write in the mint
-- leaves every other path, and every node made by an earlier build, unseeded.
-- =====================================================================
local fresh = { id = "seedkid", x = 1, y = 2, z = 3 }
local seeded = Routes.RowsOf(fresh)
assert(#seeded == 1,
       "A FRESH NODE WAS NOT SEEDED: A13.1 - a placed node always has one row. A node with "
       .. "none can never complete (`manager.lua`'s ledger waits for ALL tabs), so it arms, "
       .. "points the arrow and never advances. got " .. tostring(#seeded))
assert(seeded[1].sense == "whenOn",
       "THE SEED'S SENSE IS WRONG: arrival is `whenOn` - it was already arrival in shipped "
       .. "code (`sensor.lua:46`), which is why AL-18 refused a fourth sense word for it")
assert(seeded[1].action == nil,
       "THE SEED INVENTED AN ACTION: `When on` with NO action means REACHED. A no-op word "
       .. "would be a NAMEABLE verb and the closed list is the security boundary (§464) - "
       .. "absence is not a capability")

-- ★★ IT SEEDS ONCE, NOT PER READ. `RowsOf` is called from every door in this file, so a
-- seed that appended would grow a node's tabs on every glance at it.
Routes.RowsOf(fresh); Routes.RowsOf(fresh)
assert(#Routes.RowsOf(fresh) == 1,
       "THE SEED APPENDED ON A SECOND READ: `RowsOf` is the read door for `SetRow`, "
       .. "`RowIncomplete`, `ArmsWith` and the pane - a per-read seed would grow the node "
       .. "every time anything looked at it. got " .. tostring(#Routes.RowsOf(fresh)))

-- ⚠ AND IT DOES NOT OVERWRITE AUTHORED WORK.
local authored = { id = "k2", rows = { { sense = "whenOff", action = "say", arg = "bye" } } }
assert(#Routes.RowsOf(authored) == 1 and Routes.RowsOf(authored)[1].sense == "whenOff",
       "THE SEED OVERWROTE AN AUTHORED ROW: it fills an EMPTY node, and a node that "
       .. "carries rows is already answered")

-- =====================================================================
-- A SUBJECT. Every slot below needs something to be about, so the route is
-- built here once: one beacon with a child, one beacon WITHOUT.
--
-- ⚠ The childless beacon is not decoration. It is A1's whole case - the thing
-- that is currently unrunnable and is meant to stop being.
-- =====================================================================
local node = {
    x = 100.5, y = 200.5, z = 12.25, mapID = 33,
    mapX = 0.42, mapY = 0.66, mapC = 2, mapZ = 5, floor = 6,
}
local routeId = assert(Routes.Create("A7.1 subject", 33), "Create returned nil")

-- ★ A RUN, because A3.1's picker is fed from the RUN's record and nothing else.
-- ⚠ DR-31 stores EVERY firing on purpose - "a boss engaged twice (wipe, then re-pull)
-- is two records" - so the fixture repeats one deliberately. A picker tested only
-- against distinct input would never exercise the fold that makes it safe.
local runId = assert(Store.Open("A3 fixture run"), "Store.Open returned nil")
Store.AddBoss(runId, { "Taragaman the Hungerer" }, 1)
Store.AddBoss(runId, { "Jergosh the Invoker" }, 2)
Store.AddBoss(runId, { "Taragaman the Hungerer" }, 3)   -- a wipe, then a re-pull

local parent = assert(Routes.AddBeacon(routeId, node, 1), "AddBeacon returned nil")
local child = assert(Routes.AddChildFromNode(routeId, parent, node), "AddChild returned nil")

local lone = assert(Routes.AddBeacon(routeId, node, 2), "AddBeacon (childless) returned nil")

assert(#Routes.ChildrenOf(parent) == 1, "the parent should have exactly one child")
assert(#Routes.ChildrenOf(lone) == 0, "the lone beacon should have none")

-- =====================================================================
-- BASELINE - what is true TODAY at each attachment point.
--
-- These are not the criteria. They are the ground the criteria are cut into, and
-- they are asserted so that a hole landing NON-additively shows up as a red here
-- rather than as a surprise three files away.
-- =====================================================================

-- A1's ground: reach lives on the CHILD and only on the child.
assert(type(Routes.SetChildReach) == "function", "SetChildReach missing")
-- ⚠ RI-22 (§402): ONE BAND, UPWARD. A fourth argument is passed deliberately and must
-- be IGNORED - Lua accepts extra arguments silently, so an old call site that still
-- sends a downward value must not quietly resurrect the field.
local r, up, down = Routes.SetChildReach(child, 8, 2.5, 2.5)
assert(r == 8 and up == 2.5, "SetChildReach did not store what it was given")
assert(down == nil and child.bandDown == nil,
       "A DOWNWARD BAND SURVIVED: RI-22 retired it - a captured sample IS the floor "
       .. "(ROUTER 280: a unit's z is its BASE POINT), so downward tolerance measures "
       .. "nothing. An ignored 4th argument must not be stored or returned")

-- ★★ AND THE ARITY IS ASSERTED, because the change is source-compatible and therefore
-- silent: `local r, up, down = ReachOf(x)` still parses and reads nil. Nothing else
-- would notice a third value coming back.
assert(select("#", Routes.SetChildReach(child, 8, 2.5)) == 2,
       "THE REACH SETTER RETURNED A THIRD VALUE: the band is upwards only, and an "
       .. "arity that grows back is how a retired field returns unnoticed")
assert(child.radius == 8, "reach did not land on the child")

-- A1.2's ground: a childless beacon is its OWN acceptance today, and that is the
-- half that already works. What it has no way to carry is a REACH.
assert(Routes.AcceptanceOf(lone) == lone, "a childless beacon should satisfy itself")
assert(Routes.AcceptanceOf(parent) == nil, "a beacon with an unflagged child accepts nothing")

-- =====================================================================
-- ★ A8.1 - StageOf. The model asked for it by name and it did not exist.
-- =====================================================================
assert(type(Routes.StageOf) == "function", "StageOf missing - the model names it")
assert(Routes.StageOf(routeId, parent) == parent.stage,
       "a beacon's stage is its OWN")
assert(Routes.StageOf(routeId, child) == parent.stage,
       "a child's stage is its PARENT'S - one hop, computed, never stored")

-- ⚠ THE MUTATION'S CASE, asserted directly: a child carrying a STALE stage field must
-- not be believed. This is the whole reason the model wanted a function rather than a
-- field - a copy that nobody remembered to update on restage.
child.stage = 999
assert(Routes.StageOf(routeId, child) == parent.stage,
       "A STALE `stage` ON A CHILD WAS BELIEVED: StageOf computes, and a copy is exactly "
       .. "what it exists to make unreachable")
child.stage = nil

-- ⚠⚠ CORRECTED §330 (Battlewrath): *"I don't think restaging the parent must restage
-- the children. Their relationship is ID, not stage. And the child stage is unique by
-- the parent ID."*
--
-- ★ THE VALUE WAS RIGHT AND THE CLAIM WAS WRONG. I asserted "restaging the parent must
-- MOVE the child", which says the child is positioned BY the parent's stage number.
-- It is not. **A child is bound to its parent by IDENTITY** (`BID:CID`, C10), and a
-- child's own position is its ordinal, unique within that BID. Nothing about the child
-- moves when the parent restages - the child is where it always was, under the same
-- parent.
--
-- ★★ So `StageOf(child)` is not "the child's stage". It is **which stage the beacon I
-- belong to is on**, resolved through the identity link - and the answer changes
-- because THE PARENT moved, never because the child did.
local before = Routes.OrdinalOf(child)
Routes.SetStage(parent, 12)
assert(Routes.StageOf(routeId, child) == 12,
       "StageOf must report the parent's CURRENT stage - the link is identity, so the "
       .. "lookup is live rather than a value that had to be updated")
assert(Routes.OrdinalOf(child) == before and Routes.ParentOf(routeId, child) == parent,
       "THE CHILD MOVED WHEN THE PARENT RESTAGED: it must not. The relationship is ID, "
       .. "not stage - the child's ordinal is unique within the parent BID and a restage "
       .. "touches neither")
Routes.SetStage(parent, 1)

-- =====================================================================
-- ★ A1 - G2, reach on a childless beacon. FILLED §299.
-- =====================================================================

-- A1.1  the store, and the read that composes rather than re-decides.
assert(type(Routes.SetBeaconReach) == "function", "SetBeaconReach missing")
assert(type(Routes.ReachOf) == "function", "ReachOf missing")

local br, bu, bd = Routes.SetBeaconReach(lone, 12, 2.5, 2.5)
assert(br == 12 and bu == 2.5, "SetBeaconReach did not store what it was given")
assert(bd == nil and lone.bandDown == nil,
       "A BEACON KEPT A DOWNWARD BAND: RI-22 retired it at BOTH levels - a beacon "
       .. "carries a reach too (G2), so the retirement has to reach it as well")

-- ★ A PURE ACCESSOR (A1.1, §349): whatever it is handed, it reads THAT thing's fields.
local r1 = Routes.ReachOf(lone)
assert(r1 == 12, "ReachOf on a childless beacon should be the beacon's own radius")
assert(Routes.ReachOf(child) == 8, "ReachOf on a child should be the child's")

-- ...and the acceptance question is asked at the CALL SITE, never inside.
Routes.SetChildRole(parent, child, "complete")
assert(Routes.AcceptanceOf(parent) == child, "a `complete` child should be the acceptance")
Routes.SetBeaconReach(parent, 99)
assert(Routes.ReachOf(Routes.AcceptanceOf(parent)) == 8,
       "the acceptance CHILD's reach must be what the COMPOSED form returns - this is "
       .. "the answer the old resolving ReachOf gave, and A1.1 must not have moved it")

-- ★★★ AND THE MASKED FIELD IS NOW READABLE. THIS IS THE WHOLE OF A1.1.
--
-- Before the move the author typed 99, the box showed 99, and every reader got the
-- child's 8 - a stored, displayed, inert value that the old smoke asserted as CORRECT.
-- ⚠ It is not a display bug: two steps on one position are two instructions with
-- different OWNERS (`BID`, `BID:CID`), and a route carrying both cannot be shared
-- unless both are readable, because the far side reconstructs owner-per-instruction.
assert(Routes.ReachOf(parent) == 99,
       "A BEACON'S OWN REACH IS STILL MASKED: the bare accessor must hand back the "
       .. "beacon's OWN 99. If this returns the child's 8, ReachOf is still deciding "
       .. "and the beacon's step cannot be emitted at all")

-- ⚠ AND THE THIRD STATE SURVIVES: children present, none flagged, nothing accepts.
-- The COMPOSED form must return nothing rather than falling back to the beacon's 77 -
-- that fallback would quietly make a half-authored stage runnable.
local half = assert(Routes.AddBeacon(routeId, node, 3), "AddBeacon returned nil")
local halfKid = assert(Routes.AddChildFromNode(routeId, half, node), "AddChild returned nil")
Routes.SetBeaconReach(half, 77)
assert(Routes.AcceptanceOf(half) == nil, "an unflagged child means nothing accepts")
assert(Routes.ReachOf(Routes.AcceptanceOf(half)) == nil,
       "A HALF-AUTHORED STAGE READ AS RUNNABLE: acceptance is nil, so the composed "
       .. "form reads nil - ReachOf(nil) is nil, and a call site that wrote "
       .. "`ReachOf(AcceptanceOf(b) or b)` would put the old and/or trap right back")
assert(Routes.ReachOf(half) == 77,
       "and the half-authored beacon's OWN 77 is still readable - the author typed it, "
       .. "and nothing about an unfinished child makes it unreadable")

-- A1.2  the childless beacon is runnable.
--
-- ⚠⚠ THIS BLOCK WAS ONE COMPOUND ASSERT AND IT TESTED NOTHING NEW (tightened §348).
-- It read `AcceptanceOf(lone) == lone and ReachOf(lone) ~= nil` - both halves already
-- asserted above, joined by an `and` so a red could not say which one broke. And it
-- called `ReachOf(lone)`, the BARE form, while A1.2's criterion names the COMPOSED one:
-- *"`AcceptanceOf(b)` returns the beacon AND `ReachOf(AcceptanceOf(b))` returns a reach
-- for it."* The shape the criterion is written in was the one shape not being called.

-- ★ THE PREMISE, alone and first: acceptance is IDEMPOTENT on a childless beacon. This
-- is what lets the composed form be written at all - `ReachOf(AcceptanceOf(b))` feeds a
-- BEACON back into a function that resolves beacons, and it terminates only because
-- asking a childless beacon for its acceptance a second time returns the same beacon.
--
-- ⚠⚠ THIS LINE NAMES A PREMISE; IT DOES NOT GUARD ONE, and the mutation harness is how
-- that is known. Every mutation that breaks the second ask is caught FIRST by
-- `ReachOf on a childless beacon should be the beacon's own radius` above - because
-- ReachOf asks internally, so the property is already load-bearing three assertions
-- earlier. The mutation came back `~~ WRONG` and was PULLED rather than reworded to
-- match whatever fired.
-- ★ Kept anyway, and kept honest: the composed form below is unreadable without knowing
-- why feeding a beacon back in terminates. That is worth a line. Claiming it as coverage
-- would not be - which is the same crime as the compound assert this block replaced.
assert(Routes.AcceptanceOf(Routes.AcceptanceOf(lone)) == lone,
       "ACCEPTANCE IS NOT IDEMPOTENT ON A CHILDLESS BEACON: the composed call site "
       .. "A1.1 moves to feeds a beacon back in, so a second ask that answered "
       .. "differently would make the composition mean something else than the resolver")

-- ★★ AND THE COMPOSED FORM, in the criterion's own words. Narrowest claim first: the
-- radius is the BEACON'S OWN 12, not merely non-nil. `~= nil` was the old test and it
-- would have gone green on any number from anywhere.
local ar, au = Routes.ReachOf(Routes.AcceptanceOf(lone))
assert(ar == 12,
       ("A CHILDLESS BEACON'S COMPOSED REACH WAS NOT ITS OWN: `ReachOf(AcceptanceOf(b))` "
        .. "is the form A1.1 moves the call site to, and for a childless beacon it must "
        .. "return the beacon's own radius (got %s)"):format(tostring(ar)))
assert(au == 2.5,
       "THE COMPOSED FORM DROPPED THE BAND: it returns radius AND band or the caller "
       .. "silently loses the tolerance A1.3 stores")
assert(select("#", Routes.ReachOf(Routes.AcceptanceOf(lone))) == 2,
       "ReachOf RETURNED THE WRONG NUMBER OF VALUES: two since RI-22, and a third "
       .. "coming back is a retired field returning by the quietest door there is")

-- ★ AND IT IS RUNNABLE, which is the criterion's actual word - a reach exists for the
-- thing that accepts, and the thing that accepts is the beacon itself.
assert(Routes.AcceptanceOf(lone) == lone,
       "A CHILDLESS BEACON DID NOT ACCEPT ITSELF: there is nothing else it could be "
       .. "waiting for, and A1's whole case is that this stops being unrunnable")

-- ⚠ A1.2 also says the UNRUNNABLE REPORT must stop listing it. That report is no
-- longer a report: §112 removed `walk.lua`, and the tell now lives as one line in
-- `object.lua`'s pane (`answersFor`), which says "ratchets when found" for a beacon
-- with a reach and marks it in red without one.
--
-- ★ It is deliberately NOT asserted as a string here, on this repo's own precedent -
-- smoke_dungeonrunpromoter, on these very two rules: *"They never needed a consumer.
-- AcceptanceOf answers on its own, and asking it directly is a stronger test than
-- reading a sentence a driver printed about it."* The condition above IS what the
-- line renders. Asserting the sentence would test the wording and would go green on
-- a pane that computed the right answer and drew the wrong one - which is a real
-- fault, but it is the PANE's, and it belongs to the pane's own smoke.

-- A1.3  height untouched. The beacon's z is still the read's; the band is a
-- tolerance OVER it, never a replacement for it.
assert(lone.z == node.z, "setting a reach must not touch z (routes.lua:29-31)")
local _, lu = Routes.ReachOf(lone)
assert(lu == 2.5, "the band must come back as stored")

-- ★★★ R IS RULED AND THE BAND IS NOT - and that asymmetry is the whole assertion.
--
-- ⚠ THIS LINE MOVED 2026-08-22, exactly where its own note said it would: *"When R2
-- rules a default this assertion is the one that changes, and it changes in ONE place."*
-- A10.3e-R rules **R = 5 at the mint** (`R_min = v_ceiling × POLL_MIN / 2`); R2, the
-- BAND, is still unruled. ⟶ The radius half changes; the band half does not.
--
-- ★★ AND THE SURVIVING HALF IS THE POINT: `ReachOf` still INVENTS nothing. 5 comes
-- back because the MINT STORED it, not because the accessor supplied it - and the band
-- comes back nil because nobody stored one. A returned default would still be
-- indistinguishable from a typed value; there just is no returned default.
local bare = assert(Routes.AddBeacon(routeId, node, 4), "AddBeacon returned nil")
local nr, nu = Routes.ReachOf(bare)
assert(nr == Routes.R_FLOOR,
       "A MINTED BEACON MUST CARRY THE STANDING R. A10.3e-R's test is *mint a child, "
       .. "touch nothing → its radius is 5 and the route builds* - and a beacon needs it "
       .. "as much as a child, because a childless one IS the node and `Bucket.Build` "
       .. "refuses it by name without a reach. got " .. tostring(nr))
assert(nu == nil,
       "an unset BAND must still be nil - R2 is unruled, and a returned default is "
       .. "indistinguishable from a typed one")

-- ⚠⚠ AND THE ACCESSOR STILL INVENTS NOTHING. Clear the stored radius and it comes
-- back nil rather than the floor - which is what keeps `Bucket.Build`'s refusal
-- meaningful: after the default ships, a nil radius can ONLY mean pre-default data.
bare.radius = nil
assert(Routes.ReachOf(bare) == nil,
       "`ReachOf` RESOLVED A DEFAULT: the floor belongs to the MINT and to the picker, "
       .. "never to the reader - a reader that supplies it makes pre-default data "
       .. "indistinguishable from authored data, and the refusal stops meaning anything")

-- ★ AND THE PICKER'S FLOOR: below 5 is clamped UP, not refused. An author typing 3
-- means *small*, and answering with 5 is the useful reading.
--
-- ⚠⚠ ON ITS OWN BEACON, NOT ON `bare`. The first cut clamped `bare` and left it at 12,
-- and `bare` is the *no reach stored at all* row of A1.2's invariant table forty lines
-- below - so a demonstration silently rewrote the fixture a different assertion depends
-- on. ★ The table caught it, which is what a swept invariant is for.
local clamp = assert(Routes.AddBeacon(routeId, node, 5), "AddBeacon returned nil")
Routes.SetBeaconReach(clamp, 3, nil)
assert(Routes.ReachOf(clamp) == Routes.R_FLOOR,
       "A RADIUS UNDER THE FLOOR WAS STORED. Below R = 5 the poll floor stops "
       .. "guaranteeing a sample lands inside the node - R, the poll floor and the "
       .. "travel ceiling are ONE relationship. got " .. tostring(Routes.ReachOf(clamp)))
Routes.SetBeaconReach(clamp, 12, nil)
assert(Routes.ReachOf(clamp) == 12, "and above the floor is the author's, untouched")

-- ★★ AND THE CEILING (Battlewrath, 2026-08-22: *"maybe 300 yards"*).
Routes.SetBeaconReach(clamp, 5000, nil)
assert(Routes.ReachOf(clamp) == Routes.R_CEILING,
       "A RADIUS OVER THE CEILING WAS STORED: the bound is clamped at the same single "
       .. "dispatch as the floor. got " .. tostring(Routes.ReachOf(clamp)))

-- =====================================================================
-- ★★★ THE OFFERED TRIGGER DEFAULT PER ACTION (AL-35) - an OFFER, not a derivation
--
-- Battlewrath struck the architect's derived read: *"that hides the setters, which is not
-- programmatic. We can flip and offer, WeakAuras-like."* ⟶ The picker pre-selects; the
-- author flips in one click; the setter stays in view.
-- =====================================================================

-- ⚠ `has` is a LOCAL inside routes.lua and deliberately not exported - the smoke keeps
-- its own rather than the shipped file growing a door for a test.
local function has(list, v)
    for _, x in ipairs(list or {}) do if x == v then return true end end
    return false
end

-- ⚠⚠ EVERY ACTION WORD MUST CARRY AN OFFER. A word added to `ROW_ACTIONS` with no entry
-- here would silently take `once` from the reader's fallback - a default nobody chose,
-- arriving as if someone had. ★ This is the completeness loop §486 wanted and did not have:
-- the list drives the assertion, so a NEW word fails here rather than shipping quietly.
-- ★★★ THE SENSE IS OFFERED THE SAME WAY (Battlewrath, 2026-08-28) - and the loop is driven
-- by `ROW_ACTIONS` for the same reason: a NEW word fails here rather than shipping silent.
--
-- ⚠ THE TWO TABLES ARE NOT SYMMETRIC IN ONE RESPECT, deliberately. An unoffered TRIGGER falls
-- back to `once` - the STORE's own default - so a missing entry would impersonate a decision.
-- An unoffered SENSE falls back to NOTHING: `SetRow` refuses a row without one, so the picker
-- simply PROMPTS. ⟶ A missing sense offer is the weaker fault, and it is asserted anyway,
-- because *prompting* should be something the vocabulary CHOSE rather than a gap nobody noticed.
for _, action in ipairs(Routes.ROW_ACTIONS) do
    local s = Routes.OfferedSense(action)
    assert(s ~= nil,
           ("`%s` IS IN ROW_ACTIONS AND OFFERS NO SENSE. Selecting it would leave the sense "
            .. "picker prompting - a real state, but one the vocabulary must CHOOSE. Add it to "
            .. "`SENSE_OFFERED`, or say here why this verb prompts"):format(action))
    assert(has(Routes.SENSE_WORDS, s),
           ("`%s` offers the sense `%s`, which is not a shipped sense word"):format(action, s))
end

-- ★ AND THE PAIRING HE RULED, ASSERTED AS ITSELF. `boss` is the only `whenOn`: a boss is
-- fought WHILE you are there; the others happen on being SEEN and are done.
assert(Routes.OfferedSense("boss") == "whenOn",
       "`boss` MUST OFFER `When on`: it is fought while you are there, which is what separates "
       .. "it from every other verb in the list")
assert(Routes.OfferedSense("note") == "seen" and Routes.OfferedSense("say") == "seen",
       "`note` and `say` MUST OFFER `Seen`: they happen on being passed and are done - his "
       .. "words, and `driver_programmatic_model.md:187` writes the note example the same way "
       .. "(`Seen:Note:<content>`) months earlier")

for _, action in ipairs(Routes.ROW_ACTIONS) do
    local offered = Routes.TRIGGER_OFFERED[action]
    assert(offered ~= nil,
           ("`%s` IS IN ROW_ACTIONS AND HAS NO OFFERED TRIGGER. AL-35 rules that each "
            .. "action word carries one; without an entry the picker hands the author "
            .. "`once` and nothing says it was a fallback rather than a decision."):format(action))
    assert(has(Routes.TRIGGERS, offered),
           ("`%s` offers `%s`, which is not in TRIGGERS"):format(action, tostring(offered)))
end

-- ⚠ AND NOTHING MAY OFFER FOR A WORD THAT IS NOT AN ACTION - a stale entry outliving its
-- verb is how `Routes.ACTIONS` came to offer `supertrack` after A2.6 retired it (RI-58).
for action in pairs(Routes.TRIGGER_OFFERED) do
    assert(has(Routes.ROW_ACTIONS, action),
           ("`%s` HAS AN OFFERED TRIGGER AND IS NOT AN ACTION WORD. A retired verb keeping "
            .. "its offer is exactly how the object pane came to offer a word the ruled "
            .. "list had dropped."):format(action))
end

-- ★★ HIS TWO NAMED CASES, asserted as the values rather than as a shape.
assert(Routes.OfferedTrigger("boss") == "every",
       "A BOSS ROW MUST OFFER `every`: *you can safely wipe and retry* - AL-23's own reason "
       .. "for the word existing. Offering `once` there is the one value a boss room must "
       .. "not have.")
assert(Routes.OfferedTrigger("say") == "once",
       "A SAY ROW MUST OFFER `once`: no running across making the character speak, and in a "
       .. "wipe it is the last instruction the group carried.")

-- ⚠⚠⚠ THE ASYMMETRY, AND IT IS THE THING A PICKER WILL GET WRONG. `SetTrigger` stores
-- NOTHING for `once`, so **accepting the `boss` offer WRITES** while accepting `note`/`say`
-- writes nothing. ⟶ A picker that "leaves the default alone" gives every boss row `once`.
local trigNode = { kind = "child" }
assert(Routes.TriggerOf(trigNode) == "once",
       "an untouched node resolves to `once` - the STORE's default (§79: absent is once)")
Routes.SetTrigger(trigNode, Routes.OfferedTrigger("boss"))
assert(trigNode.trigger == "every" and Routes.TriggerOf(trigNode) == "every",
       "ACCEPTING THE BOSS OFFER MUST WRITE. The offer and the store's default differ, so "
       .. "a picker that only writes on a CHANGE would leave a boss row at `once` forever "
       .. "- and nothing downstream could tell that from an author who chose it.")
Routes.SetTrigger(trigNode, Routes.OfferedTrigger("say"))
assert(trigNode.trigger == nil,
       "and accepting `once` stores NOTHING - a record carries a trigger only where the "
       .. "author took the exception (§79), so an unauthored node's record stays empty")

-- ★★★ PER SELECTION - the offer is fixed to the WORD, never varied by the node
-- (Battlewrath, 2026-08-23: *"making a system that keeps changing makes a system users
-- react to rather than know. So I'd have it per selection."*).
--
-- ⚠⚠ THE SIGNATURE IS THE GUARD: `OfferedTrigger(action)` takes one argument and so
-- CANNOT see the node it is being asked about. ★ That is stronger than a rule, and this
-- row exists so the day someone gives it a second parameter - *"boss present, so the note
-- repeats"* - the property fails out loud rather than becoming a clever default nobody
-- can predict. His framing: a tab is scoped to itself like a WeakAuras trigger, so **a
-- note does not know it is on a node with a boss.**
local nodeWithBoss = { kind = "child", rows = {
    { sense = "whenOn", action = "boss", arg = "Baron" },
    { sense = "whenOn", action = "note", arg = "pull left" } } }
assert(Routes.OfferedTrigger("note", nodeWithBoss) == Routes.OfferedTrigger("note"),
       "THE OFFER READ THE NODE. It must depend on the SELECTED WORD alone - pick `say` "
       .. "and you get `once`, every time, on every node, forever. A context-varying "
       .. "default is not one decision fewer; it is one decision replaced by a thing the "
       .. "author has to watch.")

-- ★ AN UNKNOWN WORD ANSWERS THE STORE'S DEFAULT, never the exception. The completeness
-- loop above is what makes that fallback unreachable in practice.
assert(Routes.OfferedTrigger("nonsense") == "once",
       "an unknown action must not silently acquire `every`")

-- =====================================================================
-- ★★★ THE R LADDER - *"a 5, 15, 25, 50, 100, 150, 300 stepping"*
--
-- ⚠⚠ THE LADDER'S ENDS **ARE** THE BOUNDS, and this is the row that stops the three
-- constants drifting apart. A first rung under the floor would offer a value the setter
-- silently clamps - a control that lies - and a last rung under the ceiling would make
-- the top of the ladder unreachable by the thing built to reach it.
-- =====================================================================
-- =====================================================================
-- ★★★ THE STAGE POOL — what a picker must be aware of, and what it must never offer
--
-- Battlewrath, 2026-08-27: *"each stage should be self aware of their own ordinal ... one
-- single input next option that is context aware of the larger pool."* And the exclusion,
-- which is a DEFINITION rather than a filter: *"0 doesn't exist as selectable. That's a
-- characteristic claim on a node that is accidentally entered without direction."*
-- =====================================================================
do
    local sid = assert(Routes.Create("stage pool", 33), "Create returned nil")
    -- ⚠⚠ ADDED HIGH-THEN-LOW **ON PURPOSE**. `StagesPresent` walks `r.beacons` in
    -- insertion order, so a fixture that adds 3 before 5 is already ascending and
    -- `table.sort` becomes untestable - measured §717, the sort mutation ran SILENT against
    -- exactly that. ★ 5 before 3 is the cheapest arrangement that can tell them apart.
    assert(Routes.AddBeacon(sid, node, 5), "AddBeacon 5")
    assert(Routes.AddBeacon(sid, node, 3), "AddBeacon 3")
    -- ⚠⚠ TWO TRAY NODES, AND THE SECOND IS THE ONE THAT REACHES THE GUARD.
    -- `SetStage(b, 0)` writes **nil** (§385c - 0 in the store IS absence), so nothing inside
    -- this addon can produce `b.stage == 0`. Measured §717: the pool's `s > 0` mutation ran
    -- SILENT against a setter-made tray, because there was no 0 to exclude.
    -- ★ It is not dead code - **a route TRAVELS**. A literal 0 can arrive in a file from a
    -- machine that normalised differently, and the second node is that file.
    local tray = assert(Routes.AddBeacon(sid, node, 1), "AddBeacon tray")
    Routes.SetStage(tray, 0)
    assert(tray.stage == nil, "SetStage(0) writes nil - 0 in the store IS absence (§385c)")

    local imported = assert(Routes.AddBeacon(sid, node, 9), "AddBeacon imported")
    imported.stage = 0                            -- as it would arrive from another machine

    local pool = Routes.StagesPresent(sid)
    assert(#pool == 2 and pool[1] == 3 and pool[2] == 5,
           ("THE POOL IS NOT THE STAGES PRESENT: got %d entr(ies), first %s. It must be the "
            .. "stages this route HAS, sorted, so a beacon can be placed beside any of them")
           :format(#pool, tostring(pool[1])))

    -- ★★★ AND THE STAGE-0 BEACON IS NOT IN IT. ⚠ It EXISTS - `tray` is a real beacon on
    -- this route - and it is still absent, because 0 is what a node IS when nobody placed it.
    -- A picker offering 0 would let an author CHOOSE to be undirected, and the direction of
    -- such a node is the `next` arg or `set =`, never its stage slot.
    for _, s in ipairs(pool) do
        assert(s ~= 0,
               "THE POOL OFFERED 0: a node is stage 0 by NOT being placed - you cannot choose "
               .. "to be lost. Its direction comes from the Next arg or set =, and offering 0 "
               .. "here would make being undirected look like a placement")
    end

    -- ⚠ AND `NextStage` NEVER ANSWERS 0 EITHER - it searches from 1, so the *new lane* half
    -- of the offer cannot reintroduce what the pool excludes.
    assert(Routes.NextStage(sid) ~= 0 and Routes.NextStage(sid) > 0,
           "THE NEXT LANE WAS 0: the search starts at 1 - a new stage is never the tray")

end

assert(Routes.R_STEPS[1] == Routes.R_FLOOR,
       "THE LADDER'S FIRST RUNG IS NOT THE FLOOR: the picker would offer a value the "
       .. "setter clamps, which is a control that lies about what it did")
assert(Routes.R_STEPS[#Routes.R_STEPS] == Routes.R_CEILING,
       "THE LADDER'S LAST RUNG IS NOT THE CEILING: the top of the range would be "
       .. "unreachable through the one control built to reach it")

-- ⚠ STRICTLY ASCENDING. A repeated or out-of-order rung makes *the next step up*
-- ambiguous, and `StepR` would either stall or skip depending on which it met first.
for i = 2, #Routes.R_STEPS do
    assert(Routes.R_STEPS[i] > Routes.R_STEPS[i - 1],
           ("THE LADDER IS NOT ASCENDING at rung %d (%s after %s)"):format(
               i, tostring(Routes.R_STEPS[i]), tostring(Routes.R_STEPS[i - 1])))
end

-- ★ THE STEPPER WALKS IT, both ways.
assert(Routes.StepR(5, 1) == 15 and Routes.StepR(15, -1) == 5, "one rung, either way")

-- ⚠⚠ AND IT DOES NOT GO DEAD AT THE ENDS. Returning nil at the top would make a
-- stepper at 300 indistinguishable from a broken one - the button would stop answering
-- and nothing would say why.
assert(Routes.StepR(Routes.R_CEILING, 1) == Routes.R_CEILING,
       "THE STEPPER WENT DEAD AT THE TOP: a control that stops answering reads as broken")
assert(Routes.StepR(Routes.R_FLOOR, -1) == Routes.R_FLOOR,
       "and it holds at the bottom rather than going under the floor")

-- ★ A VALUE OFF THE LADDER STILL STEPS - the rungs are the picker's OFFER, not a
-- constraint on the field, so an author who typed 37 steps to 50 and not to nothing.
assert(Routes.StepR(37, 1) == 50 and Routes.StepR(37, -1) == 25,
       "AN OFF-LADDER VALUE COULD NOT STEP: R is a distance and the store keeps a "
       .. "number; nothing may assume it is one of seven values")

-- =====================================================================
-- ★★★ A1.2's INVARIANT, SWEPT - now the POST-CONDITION of the A1.1 move.
--
-- ⚠⚠ THIS TABLE IS THE PROOF THAT A1.1 CHANGED NO ANSWER, and it only means that
-- because the numbers in it were MEASURED BEFORE THE MOVE (§348, one commit earlier).
-- Read the other way round it is worthless: values copied out of the new code would
-- assert that the new code does what the new code does.
--
-- ★ Written §348 as `ReachOf(x) == ReachOf(AcceptanceOf(x))` - an equality that held
-- while ReachOf still resolved. A1.1 makes the two forms DIFFER on purpose (that is the
-- unmasking), so the invariant that survives the move is the composed COLUMN: whatever
-- the old resolving ReachOf(x) returned, `ReachOf(AcceptanceOf(x))` returns now.
--
-- ⚠ SWEPT, not sampled. `lone` alone would pass on a ReachOf that ignored its argument.
-- The four cover: childless-with-reach · flagged child (the MASKING case) · unflagged
-- child (acceptance is nil, so the composition feeds nil in) · no reach at all.
--
--     subject   composed (was, and still is)    bare accessor (NEW - was masked)
--     lone      12                              12    (acceptance is itself)
--     parent    8   the child's                 99    ★ the unmasked one
--     half      nil nothing accepts             77    the author's own, readable
--     bare      nil nothing stored              nil
for _, case in ipairs({
    { lone,   12,  12,  "a childless beacon with a reach" },
    { parent, 8,   99,  "a beacon whose acceptance is a flagged CHILD - the masking case" },
    { half,   nil, 77,  "a beacon with an unflagged child: acceptance is nil" },
    { bare,   nil, nil, "a beacon with no reach stored at all" },
}) do
    local x, composed, own, what = case[1], case[2], case[3], case[4]
    assert(Routes.ReachOf(Routes.AcceptanceOf(x)) == composed,
           ("THE COMPOSED FORM CHANGED ITS ANSWER ON %s: it must return %s, which is "
            .. "what the RESOLVING ReachOf returned before A1.1 moved it. A different "
            .. "value here means A1.1 was a behaviour change, not a branch removal")
           :format(what, tostring(composed)))
    assert(Routes.ReachOf(x) == own,
           ("THE BARE ACCESSOR IS NOT READING %s's OWN FIELDS: it must return %s. This "
            .. "is the half A1.1 exists for - before the move a beacon's own reach was "
            .. "unreadable whenever a flagged child stood in front of it")
           :format(what, tostring(own)))
end

-- =====================================================================
-- ★ A2 - the child ordinal. FILLED §312.
--
-- ★★ THE FIXTURE IS THE USE CASE, not a synthetic. Battlewrath's: *"A jump to jump
-- to jump. Where multiple R and H might mesh together."* Three platforms whose
-- radius+band volumes OVERLAP - each within 2 yd of the next in z, and within each
-- other's radius in x/y. Geometry cannot separate them. That is the whole reason
-- the gate exists, so it is the case the gate is proved on.
-- =====================================================================
local chain = assert(Routes.AddBeacon(routeId, node, 5), "AddBeacon returned nil")

-- three landings, meshed on purpose: R=6 each, 2 yd apart in z, 3 yd apart in x
local jump = {}
for i = 1, 3 do
    local p = Routes.AddChildFromNode(routeId, chain, node)
    assert(p, "AddChild returned nil")
    p.x, p.z = node.x + (i - 1) * 3, node.z + (i - 1) * 2
    Routes.SetChildReach(p, 6, 2.5, 2.5)
    Routes.SetChildOrdinal(chain, p, i)
    jump[i] = p
end

-- a satellite hung off the same beacon, deliberately NOT in the line
local sat = assert(Routes.AddChildFromNode(routeId, chain, node), "AddChild returned nil")
-- ★★ SELECTED OUT, DELIBERATELY (Battlewrath, 2026-08-21: *"setting the baseline to
-- ratchet and then select out"*). ⚠ A placed child now takes the NEXT ORDINAL at the mint,
-- so a satellite is no longer what you get by default - it is what an author CHOOSES by
-- clearing the ordinal. ★ This line is the select-out half of the rule, and the fixture
-- had been relying on the mint writing nothing.
Routes.SetChildOrdinal(chain, sat, nil)

-- ⚠ THE MESH IS REAL, and asserted rather than asserted-about: platform 1 and 2 are
-- inside each other's radius AND inside each other's band. If this ever stops being
-- true the fixture has stopped testing what it says it tests.
local dx = jump[2].x - jump[1].x
local dz = jump[2].z - jump[1].z
assert(dx * dx <= 6 * 6 and dz <= 2.5,
       "THE JUMP FIXTURE NO LONGER MESHES: the platforms must overlap in BOTH r and "
       .. "band, or the gate is being proved on a case geometry could have solved")

-- A2.1  sparse, and insertion renumbers NOTHING.
-- ⚠ FILTERED ON BOTH SIDES (§312). The first cut collected `before` UNFILTERED and
-- `after` filtered, so it compared a list containing the satellite's nil against one
-- that had dropped it. It passed only because the satellite happened to sort LAST -
-- a mutation that moved satellites to the front fired this assert instead of the one
-- written for it, which is how the weak test surfaced.
local before = {}
for _, c in ipairs(Routes.ChildrenOf(chain)) do
    if c.ordinal ~= nil then before[#before + 1] = c.ordinal end
end
local inserted = assert(Routes.AddChildFromNode(routeId, chain, node), "AddChild nil")
Routes.SetChildOrdinal(chain, inserted, 1.5)
local after = {}
for _, c in ipairs(Routes.ChildrenOf(chain)) do
    if c ~= inserted and c.ordinal ~= nil then after[#after + 1] = c.ordinal end
end
for i = 1, #after do
    assert(before[i] == after[i],
           ("INSERTING RENUMBERED THE LINE: %s became %s at %d - a sparse ordinal must "
            .. "cost nothing to insert into"):format(tostring(before[i]), tostring(after[i]), i))
end

-- ...and the view is IN ORDINAL ORDER, with the satellite after the line.
local seen = Routes.ChildrenOf(chain)
-- ⚠ THE SATELLITE FIRST, and the order of these two is load-bearing. The position
-- triple below checks by INDEX, so any sort change trips it - including a satellite
-- moving to the front, which then never reaches its own assertion. Asserted this way
-- round they are independent: a broken ordinal comparison leaves the satellite last
-- and the triple catches it; a satellite moved forward is caught here.
assert(seen[#seen] == sat, "a satellite has no ordinal, so it reads AFTER the line")
assert(seen[1] == jump[1] and seen[2] == inserted and seen[3] == jump[2],
       "ChildrenOf must read in ordinal order - 1, 1.5, 2")

-- ⚠ and the STORED order is untouched: the view is a lens, not a sort.
local minted = Routes.ChildrenAsMinted(chain)
assert(minted[#minted] == inserted,
       "ChildrenOf must not reorder STORAGE - b.children is the record of what was "
       .. "minted when, and the ordinal is a view over it")

-- A2.2  the path resolves to exactly one child, and says when it cannot.
local hit, n = Routes.ChildAt(routeId, "5:2")
assert(hit == jump[2] and n == 1, "5:2 must resolve to exactly one child")
assert(Routes.ChildAt(routeId, "5:1.5") == inserted, "5:1.5 resolves to the inserted one")
assert(Routes.PathOf(routeId, jump[3]) == "5:3", "and the path reads back")
assert(Routes.PathOf(routeId, sat) == nil,
       "a satellite HAS no path - which is different from having one nobody wrote")

-- A2.3  two on one ordinal is TOLD, never refused.
Routes.SetChildOrdinal(chain, inserted, 2)
assert(inserted.ordinal == 2, "the collision must be STORED, not rejected")
assert(Routes.OrdinalMatches(chain, 2, inserted) == 1,
       "and REPORTED - one other child already sits on 2")
Routes.SetChildOrdinal(chain, inserted, 1.5)

-- ★★★ THE GATE. Ordinaled children wait their turn; the satellite never does.
local done = {}
assert(Routes.ListensNow(chain, jump[1], done), "first in the line always listens")
assert(not Routes.ListensNow(chain, jump[2], done),
       "PLATFORM 2 LISTENED BEFORE 1 WAS SATISFIED - which is the entire fault the "
       .. "ordinal exists to prevent, because 2's volume overlaps 1's")
assert(Routes.ListensNow(chain, sat, done),
       "A SATELLITE WAS GATED: a child with no ordinal is live while its beacon is "
       .. "current - enter-from-any (routes.lua's goTo block) depends on it")

done[jump[1]] = true
assert(Routes.ListensNow(chain, inserted, done), "1.5 listens once 1 is satisfied")
assert(not Routes.ListensNow(chain, jump[2], done),
       "and 2 still does NOT - 1.5 is between them and has not been satisfied")
done[inserted] = true
assert(Routes.ListensNow(chain, jump[2], done), "now 2 listens")

-- ⚠ A child taken OUT of the line goes live immediately. Clearing an ordinal is an
-- authoring act with an effect, not a tidy-up.
Routes.SetChildOrdinal(chain, jump[3], nil)
assert(jump[3].ordinal == nil and Routes.ListensNow(chain, jump[3], {}),
       "clearing an ordinal must make the child a satellite, live at once")
Routes.SetChildOrdinal(chain, jump[3], 3)

-- ★ A2.4 IS COVERED, and NOT HERE (§322). It asks for TWO DOORS to one field, and
-- this file has no pane - asserting it here would reduce to "one setter writes one
-- field", which is true of any function and proves nothing about the doors.
-- The proof lives in `smoke_dungeonrunpromoter.lua`, which has the real pane and the
-- registry: set from the BEACON's roster, read from the CHILD's own box, and back.
-- ⚠ The row was briefly flipped to covered while building A2 and asserted nowhere.


-- =====================================================================
-- ★ A3 - G10, the boss sense and the picked name. FILLED §321.
--
-- ⚠ THE AXIS IS `sense` AND IT IS NOT NEW (T4). A3.1 asks for "a child `kind`" and
-- `kind` is the structural discriminator (T1); the model already names this axis and
-- §5 already says the default has no field. So G10 adds the SET case only.
-- =====================================================================
local bossBeacon = assert(Routes.AddBeacon(routeId, node, 9), "AddBeacon returned nil")
local bossKid = assert(Routes.AddChildFromNode(routeId, bossBeacon, node), "AddChild nil")

-- The default is what you get by choosing nothing, and it stores nothing.
assert(Routes.SenseOf(bossKid) == nil, "an unset sense must store NOTHING (§79's law)")
assert(Routes.Sense(bossKid) == "reachHere",
       "and RESOLVE to reach here - the node being a node")
assert(bossKid.sense == nil, "the default must not be written into the object")

-- =====================================================================
-- ★★★ RI-17's GRAMMAR: a row IS one declaration `<sense>:<action>:<arg>`
--
-- Battlewrath: *"The instructions that export do not carry each program instruction. The
-- driver has that built in. It just needs to be told `While:Boss:Bossname`."*
--
-- ⚠ So the assertions below are about ONE THING being stored, not about two fields
-- agreeing. The values did not change - `boss`, the picked name, the same picker law -
-- the SHAPE did.
-- =====================================================================

-- A3.1 / RI-15  the SETTABLE sense list is EMPTY, and that is the ruling.
assert(type(Routes.SENSES) == "table",
       "SENSES must still be published - empty is a state, absent is a break")
assert(#Routes.SENSES == 0,
       ("THE SETTABLE SENSE LIST IS NOT EMPTY (%d entries): boss LEFT it (RI-15 - it is "
        .. "an ACTION word now), and `falling` / `in combat` never belonged (RI-17 - they "
        .. "are GATES, what a function is CONSTRUCTED OF, never a term the author picks). "
        .. "Nothing has replaced them yet"):format(#Routes.SENSES))
assert(Routes.Sense(bossKid) == "reachHere",
       "and the DEFAULT still resolves with nothing settable - a node is still a node")

-- ★ THE THREE SENSE-WORDS, which are the row's first field and not the node's sense.
assert(#Routes.SENSE_WORDS == 3, "three sense-words: when on · seen · when off")

-- A3.2  the boss row IS the declaration `When on:boss:⟨name⟩`.
local offered = Store.BossNames(runId)
assert(#offered > 0, "the fixture run must carry boss names, or A3.1 tests nothing")

local row = Routes.SetRow(bossBeacon, bossKid, 1, "whenOn", "boss", offered[1], offered)
assert(row and row.sense == "whenOn" and row.action == "boss" and row.arg == offered[1],
       "a whole declaration must store as one row")

-- ★★ STORED WHOLE - A3.2's own mutation names this. The declaration lives in ONE place;
-- there is no `child.sense` + `child.boss` pair for the two halves to disagree across.
assert(bossKid.sense == nil and bossKid.boss == nil,
       "THE ROW WAS SPLIT BACK INTO FIELDS: `<sense>:<action>:<arg>` is stored whole, "
       .. "exported whole and read whole. Two fields set by two setters is the shape "
       .. "where half a declaration can ship")
assert(#Routes.RowsOf(bossKid) == 1, "one row, not one row per part")

-- A3.1's picker law SURVIVES THE RESHAPE: the name is picked, never typed.
assert(Routes.SetRow(bossBeacon, bossKid, 1, "whenOn", "boss",
                     "Taragaman the Typo", offered).arg == offered[1],
       "A NAME NOT ON OFFER WAS ACCEPTED: the offer is the whole guard - 'picked, never "
       .. "typed' is a property of the data path, not of the pane being careful")

-- ⚠ and a refusal must not blank what the author already chose.
assert(Routes.RowsOf(bossKid)[1].action == "boss",
       "A REFUSED ARG WIPED THE ACTION: the row survives a rejected name")

-- An unlisted sense-word or action is refused the same way.
assert(Routes.SetRow(bossBeacon, bossKid, 1, "whenever", "boss", offered[1], offered)
       .sense == "whenOn", "an UNLISTED sense-word must be refused, the row kept")
assert(Routes.SetRow(bossBeacon, bossKid, 1, "whenOn", "interpretiveDance", nil, offered)
       .action == "boss", "an UNLISTED action must be refused, the row kept")

-- ⚠ AND THE FOLD IS DISTINCT. DR-31 records EVERY firing on purpose - a boss engaged
-- twice is two records - so the picker must not offer the same name twice.
local dupes = 0
for i = 2, #offered do
    if offered[i] == offered[i - 1] then dupes = dupes + 1 end
end
assert(dupes == 0, "Store.BossNames must fold to the DISTINCT set - DR-31 stores every "
       .. "firing deliberately and the fold is what makes that safe to offer")

-- A3.2  `engaged` IS NOT AN AUTHORABLE VALUE (RI-15). It is a driver-side arming witness
-- at most, and the author states OUTCOMES - an *engaged* witness is a step in HOW.
for _, a in ipairs(Routes.ROW_ACTIONS) do
    assert(a ~= "bossEngaged" and a ~= "bossKilled",
           ("`%s` IS OFFERED AS AN ACTION: the action word is `boss` - one function that "
            .. "carries its own condition (the kill) and its own completion. Offering the "
            .. "pair asks the author to define one question as two"):format(a))
end

-- ★★★ A3.3  NO REFUSAL ANYWHERE - the signature is the guard.
Routes.SetRow(bossBeacon, bossKid, 1, "whenOn", "boss", nil, offered)
assert(Routes.ArmsWith(bossKid) == nil,
       "A NAMELESS BOSS ROW OFFERED SOMETHING TO ARM WITH: the driver's call takes the "
       .. "name as its argument, so with no name there is nothing to pass and NOTHING "
       .. "ARMS. The unfiltered listener is not refused - it cannot be expressed")

-- ⚠ AND IT IS TOLD, not silently shipped (A3.2's second mutation). A row whose action
-- takes an arg and has none is INCOMPLETE and must be visible as such.
assert(Routes.RowIncomplete(Routes.RowsOf(bossKid)[1]) == "name",
       "AN ARGLESS BOSS ROW READ AS COMPLETE: `When on:boss:` with no name arms nothing, "
       .. "so it is told rather than exported")

Routes.SetRow(bossBeacon, bossKid, 1, "whenOn", "boss", offered[1], offered)
assert(Routes.ArmsWith(bossKid) == offered[1],
       "and a NAMED one arms with exactly that one dest name")
assert(Routes.RowIncomplete(Routes.RowsOf(bossKid)[1]) == false,
       "and a named row is complete")

-- ⚠ a child with no boss row arms with nothing, whatever stray fields it carries.
local plainKid = assert(Routes.AddChildFromNode(routeId, bossBeacon, node), "AddChild nil")
plainKid.boss = "Jergosh the Invoker"          -- a stray field, however it got there
assert(Routes.ArmsWith(plainKid) == nil,
       "A NON-BOSS CHILD ARMED A LISTENER: the ROW decides whether anything arms, not "
       .. "the presence of a name - otherwise a stale field becomes a live listener. "
       .. "★ This is exactly what the one-declaration shape makes unreachable")

-- A3.4  nothing about a set, a count or a grouping is stored or shown.
assert(bossKid.bossCount == nil and bossKid.bossSet == nil and bossKid.bossTotal == nil,
       "no count, no set, no total - capture.lua:234's bound is that we hold unit names "
       .. "that had a boss token, and a denominator is CONTENT (§17)")
assert(type(Store.BossNames(runId)) == "table",
       "the offer is a list of NAMES and nothing else")

-- ⚠ Changing the sense back to the default takes the name with it. A name is only
-- meaningful to a boss sense, and a stale one is exactly what ArmsWith must never find.
Routes.SetChildSense(bossBeacon, bossKid, nil)
assert(bossKid.boss == nil,
       "clearing the SENSE must clear the NAME - a name outliving its sense is the stale "
       .. "field the plainKid case above proves is dangerous")
Routes.SetChildSense(bossBeacon, bossKid, "bossKilled")
Routes.SetChildBoss(bossBeacon, bossKid, offered[1], offered)

-- A3's ground, and ★★ THE FIRST THING THIS EMPTY FILE FOUND (2026-08-18, §299).
--
-- A3.1 proposes *"a child `kind` (a new axis beside `role`) with `boss`"*. **`kind` is
-- ALREADY TAKEN, and by the structural discriminator** - `beacon` (routes.lua:224),
-- `child` (:429), `note` (:1129). It is not a spare field: `SetName`/`NameOf` (:314,
-- :320) BRANCH on it to decide whether they are writing `text` or `name`. Writing
-- `boss` over `child` would silently move a boss child onto the beacon-naming path.
--
-- ⚠ Reported, not renamed - A3 is the Analyst's row and the term is theirs to rule.
-- The constraint is what this file can supply: the new axis needs a word that is not
-- `kind`, `role`, `shape`, `action`, `icon`, `outcome` or `stage`. This assertion
-- pins the collision so it cannot be re-discovered by a bug.
assert(type(Routes.SetChildRole) == "function", "SetChildRole missing")
assert(child.kind == "child", "`kind` is the STRUCTURAL discriminator - see above")
assert(parent.kind == "beacon", "`kind` is the STRUCTURAL discriminator - see above")

-- A5's ground: the three code vocabularies the adaptor will render.
for _, name in ipairs({ "ROLES", "SHAPES", "ACTIONS" }) do
    assert(type(Routes[name]) == "table" and #Routes[name] > 0,
           "Routes." .. name .. " is missing or empty - the adaptor has nothing to key on")
end

-- =====================================================================
-- ★★ THE ROSTER. One row per acceptance criterion this file will carry.
-- A row goes `false` the day its assertion lands above, and the count falls.
-- =====================================================================
-- ★ A4 - G1, the route note. FILLED §346.
--
-- ⚠ RI-10 ruled the SHELF: its own table under the personal one, and export takes it
-- whole and never the personal plane. So the first thing asserted is that they ARE two
-- tables - if that ever collapses, every other row here still passes.
-- =====================================================================
assert(type(Store.RouteNoteTable) == "function", "Store.RouteNoteTable missing")
assert(Store.RouteNoteTable() ~= Store.NoteTable(),
       "THE ROUTE NOTES AND THE PERSONAL NOTES SHARE A TABLE: §60 gave them separate "
       .. "planes and RI-10 made export STRUCTURAL - one table would make export a "
       .. "FILTER, and a filter is the thing that gets missed. A personal note leaking "
       .. "into a shared route is what two tables make unreachable")

-- A4.2  REFERENCED in the store, OWNED in the pane.
local noteKid = assert(Routes.AddChildFromNode(routeId, parent, node), "AddChild nil")
assert(Routes.SetRouteNote(routeId, parent, noteKid, "pull left, LOS the caster")
       == "pull left, LOS the caster", "a route note must store")
assert(Routes.RouteNoteOf(routeId, parent, noteKid) == "pull left, LOS the caster",
       "and read back")

-- ★★ THE CHILD HOLDS NOTHING - §24, and this is the assertion that keeps it true.
assert(noteKid.note == nil and noteKid.noteId == nil,
       "THE CHILD CARRIES A NOTE REFERENCE: the note is keyed BY the child, so the "
       .. "child holds no field and nothing can dangle. A reference here would need a "
       .. "`BrokenNotes` check, which is the family A2.6 just deleted")

-- ⚠ A4.2's OWN TEST, verbatim: two children, independently typed notes -> two entries;
-- edit one -> only one changes.
local noteKid2 = assert(Routes.AddChildFromNode(routeId, parent, node), "AddChild nil")
Routes.SetRouteNote(routeId, parent, noteKid2, "wait for the patrol")
assert(Routes.RouteNoteOf(routeId, parent, noteKid) == "pull left, LOS the caster"
       and Routes.RouteNoteOf(routeId, parent, noteKid2) == "wait for the patrol",
       "TWO CHILDREN SHARE ONE NOTE: independently typed notes are two entries - "
       .. "sharing is a LATER, separate re-point (RI-1), never the default")
Routes.SetRouteNote(routeId, parent, noteKid2, "wait for the second patrol")
assert(Routes.RouteNoteOf(routeId, parent, noteKid) == "pull left, LOS the caster",
       "EDITING ONE NOTE CHANGED ANOTHER: they are keyed apart by address")

-- ★★★ THE BEACON HALF — *"connected to a beacon OR a beacon's child"* (Battlewrath,
-- 2026-08-27). Every row above is the CHILD half, and the beacon half was UNSTORABLE:
-- `noteKey` required a child, so `SetRouteNote` returned nil and the typed note was
-- DISCARDED WITH NO ERROR — while `panes_decl` offered the box on a beacon anyway
-- (`subjects = "any"`).
--
-- ⚠⚠ AND A4.3 IS WHY NOTHING NOTICED. *No note is a real state, stored as absence* — so a
-- discarded note and a deliberately empty one read back IDENTICALLY. There is no failed
-- write to observe; the only way to catch it is to assert the round trip.
assert(Routes.SetRouteNote(routeId, parent, nil, "start here, buff up")
       == "start here, buff up",
       "A NOTE ON A BEACON WAS NOT STORED: the note hangs on a beacon OR a child, and the "
       .. "beacon half returned nil while the pane offered the box - so an author typed "
       .. "route instructions and they went nowhere, silently")
assert(Routes.RouteNoteOf(routeId, parent, nil) == "start here, buff up",
       "and reads back off the beacon")

-- ★★ IT IS A DIFFERENT ENTRY FROM ITS OWN CHILD'S. The beacon key is the child key with an
-- EMPTY child segment, so this is the row that proves the two cannot collide.
-- ⚠ Without it the beacon note could be written into the child's slot and every assertion
-- above would still pass.
assert(Routes.RouteNoteOf(routeId, parent, noteKid) == "pull left, LOS the caster",
       "THE BEACON NOTE OVERWROTE ITS CHILD'S: they are separate entries, keyed apart - a "
       .. "beacon standing in for its own child is A2.6's rule about POSITION, never about "
       .. "the note address")

-- ★ AND THE ANCHOR RESOLVER AGREES WITH THE KEY, or the pane and the store disagree about
-- where a note lives. ⚠ This is the join the four call sites now depend on.
do
    local ab, ac = Routes.NoteAnchorOf(routeId, parent)
    assert(ab == parent and ac == nil,
           "NoteAnchorOf sent a BEACON to the child slot - which is the exact shape that "
           .. "lost the note: `parentOf(p), p` returned `nil, beacon`")
    local cb, cc = Routes.NoteAnchorOf(routeId, noteKid)
    assert(cb ~= nil and cc == noteKid,
           "NoteAnchorOf lost the CHILD half: a child note hangs on (parent, child)")
end

-- ★★★ AND NOTHING ELSE CARRIES A NOTE — *"so far Beacons and Children of Beacons are the
-- only thing that exist that can be STATEFUL to deliver a note"* (Battlewrath, 2026-08-27).
-- ⚠ The personal map pin is `kind == "note"`, and RI-10 put the two note planes in separate
-- TABLES precisely so one could never become the other. A route note filed against a pin
-- would walk that separation back through the front door.
do
    for _, kind in ipairs({ "note", "runnode" }) do
        local nb, nc = Routes.NoteAnchorOf(routeId, { id = "X1", kind = kind })
        assert(nb == nil and nc == nil,
               ("A `%s` WAS GIVEN A ROUTE-NOTE ANCHOR: only a beacon or a beacon's child is "
                .. "stateful enough to carry one. `%s` here is the PERSONAL map pin — RI-10 "
                .. "gave it its own table so export stays STRUCTURAL rather than a filter")
               :format(kind, kind))
    end
end

-- ★★★ AND NOTHING ELSE CARRIES A NOTE — *"so far Beacons and Children of Beacons are the
-- only thing that exist that can be STATEFUL to deliver a note"* (Battlewrath, 2026-08-27).
-- ⚠ The personal map pin is `kind == "note"`, and RI-10 put the two note planes in separate
-- TABLES precisely so one could never become the other. A route note filed against a pin
-- would walk that separation back through the front door.
do
    for _, kind in ipairs({ "note", "runnode" }) do
        local nb, nc = Routes.NoteAnchorOf(routeId, { id = "X1", kind = kind })
        assert(nb == nil and nc == nil,
               ("A `%s` WAS GIVEN A ROUTE-NOTE ANCHOR: only a beacon or a beacon's child is "
                .. "stateful enough to carry one. `%s` here is the PERSONAL map pin — RI-10 "
                .. "gave it its own table so export stays STRUCTURAL rather than a filter")
               :format(kind, kind))
    end
end

Routes.SetRouteNote(routeId, parent, nil, nil)

-- A4.1  EXACTLY ONE string, ≤ ~200 chars. ★ "Exactly one" is by construction - a table
-- keyed by a unique address cannot hold two values at one key - so what is testable is
-- the CAP, on both doors.
local long = string.rep("x", 400)
Routes.SetRouteNote(routeId, parent, noteKid, long)
assert(#Routes.RouteNoteOf(routeId, parent, noteKid) == Routes.NOTE_MAX,
       ("A ROUTE NOTE EXCEEDED THE CAP: target §4 rules ≤ ~200. The store caps as well "
        .. "as the box, because the interface registry is a SECOND DOOR that never "
        .. "touches SetMaxLetters (got %d)")
       :format(#Routes.RouteNoteOf(routeId, parent, noteKid)))

-- A4.3  the note is a CHOICE. No note is a real state, stored as ABSENCE.
Routes.SetRouteNote(routeId, parent, noteKid, nil)
assert(Routes.RouteNoteOf(routeId, parent, noteKid) == nil,
       "CLEARING A NOTE LEFT SOMETHING BEHIND: no note is a REAL state and it is stored "
       .. "as absence - an empty string would be a note that says nothing, which is a "
       .. "different thing an author did not choose")

-- ⚠ AND THE KEY IS THE ID ADDRESS, NOT `4.1:3`. Stage and ordinal are PROPERTIES and
-- they move (RI-6); identity does not. A note keyed by the author-facing path would
-- follow the wrong child the first time anybody restaged.
Routes.SetRouteNote(routeId, parent, noteKid2, "keyed by identity")
local wasStage = parent.stage
Routes.SetStage(parent, 77)
Routes.SetChildOrdinal(parent, noteKid2, 9)
assert(Routes.RouteNoteOf(routeId, parent, noteKid2) == "keyed by identity",
       "THE NOTE FOLLOWED A PROPERTY: restaging the beacon and reordering the child "
       .. "must not move a note - it is keyed by RID:BID:CID, which is identity")
Routes.SetStage(parent, wasStage)
Routes.SetRouteNote(routeId, parent, noteKid2, nil)
Routes.DeleteChild(parent, noteKid)
Routes.DeleteChild(parent, noteKid2)

-- =====================================================================
-- ★ A2.6 - a stored `goTo` / `onRamp` is DROPPED at load, and SAID.
-- =====================================================================
local stale = Routes.AddChildFromNode(routeId, parent, node)
stale.goTo = 999                       -- as an older build would have left it
stale.onRamp = true
local before = #chat
assert(Routes.DropRetired() >= 1, "a stored retired pointer must be found")
assert(stale.goTo == nil and stale.onRamp == nil,
       "A RETIRED POINTER SURVIVED A LOAD: silently honouring it is the worse "
       .. "failure - the route would keep redirecting through a mechanism nothing "
       .. "else in the build knows about")
assert(#chat > before, "and it must be TOLD, never dropped quietly (S4)")

-- ⚠ idempotent: a second load finds nothing and says nothing.
local quiet = #chat
assert(Routes.DropRetired() == 0 and #chat == quiet,
       "A CLEAN LOAD ANNOUNCED SOMETHING: silence is the correct output when there "
       .. "is nothing to drop")
-- =====================================================================
-- ★ A2.12 - `fireOn` retired, and dropped through the SAME door as A2.6.
--
-- ⚠ Beside A2.6 rather than in a block of its own, because it is not a second
-- mechanism: RI-5 withdrew the firing field the way A2.6 withdrew pointing, and
-- `DropRetired` is one function with one more field in its condition.
-- =====================================================================

-- A2.12a - THE SETTER IS GONE, not parked. ⚠ Asserted as an ABSENT SYMBOL rather
-- than by grepping the source: a text scan proves what a file SAYS, and this proves
-- what the module OFFERS, which is the thing a caller could reach for.
assert(Routes.SetChildFireOn == nil,
       "A RETIRED SETTER IS STILL REACHABLE: `SetChildFireOn` serves a mechanism "
       .. "RI-5 withdrew (`there is NO firing field`), and a parked setter is a "
       .. "standing invitation to build on it - this field already survived one "
       .. "clean-out")

-- A2.12b - a stored value is DROPPED and TOLD, on every load.
-- ★★ RI-22 (§402): a stored `bandDown` is dropped and TOLD, at BOTH levels. A beacon
-- carries a reach too (G2, §299), so a child-only sweep would have left every beacon's
-- copy in place - a half-retirement, which is the shape that invites building on it.
-- =====================================================================
-- ★★★ 17d - NOTHING SCRAPED ABOUT THE CHARACTER TRAVELS (RI-24, §404).
-- =====================================================================
local _, freshRoute = Routes.Create("no scraping", 33)
assert(freshRoute ~= nil, "the fixture route must mint")
assert(freshRoute.author == nil and freshRoute.madeAt == nil,
       "THE MINT STILL SCRAPES: `author = UnitName(\"player\")` is character data the "
       .. "author never chose to disclose, and it would travel in an export. It is "
       .. "not speculative, it is WRONGLY SOURCED - who / when / author notes are the "
       .. "user's to type or leave empty")

-- ⚠ AND A STORED ONE IS DROPPED AND SAID. A route minted before this change is
-- already carrying it, and may already have been exported - so the sweep runs on
-- every load, like every other retired field.
freshRoute.author = "Gravekeeper"
freshRoute.madeAt = 1755000000
local beforeScrape = #chat
local droppedScrape = Routes.DropRetired()
assert(freshRoute.author == nil and freshRoute.madeAt == nil,
       "SCRAPED AUTHOR DATA SURVIVED A LOAD: DropRetired walks beacons and children, "
       .. "and this is the ROUTE level - a sweep that never visits it leaves the one "
       .. "field the whole item is about exactly where it was")
assert(droppedScrape >= 1, "the route-level drop must be counted in the return")
local saidScrape = chat[#chat] or ""
assert(saidScrape:find("disclose", 1, true) or saidScrape:find("character", 1, true),
       "THE MESSAGE DID NOT SAY WHAT WAS DROPPED: an author who never chose to "
       .. "disclose a character name should learn it was there. Said: " .. saidScrape)

-- =====================================================================
-- ★★★ AN ARG ON AN ACTION THAT TAKES NONE - dropped and TOLD, same door (§460).
--
-- ⚠ Not a new mechanism, so not a new block: `ROW_ARG` says `supertrack` takes nothing,
-- and its comment says *"`nil` means the action takes nothing, not that anything is
-- allowed"*. A stray one arrives the way `goTo` does - hand-edited SavedVariables or an
-- import written against another build - and neither bumps a schema version.
-- =====================================================================
-- ⚠⚠ ITS CASE EMPTIED, SO THIS ASSERTS THE DORMANCY RATHER THAN FAKING ONE (§476).
--
-- §460's sweep strips an arg from a KNOWN action that declares none. `supertrack` was the
-- only such action, and AL-19 moved it off the list entirely - so **no reachable case
-- remains**, and every remaining action takes an arg.
--
-- ★ THE GUARD STAYS because `ROW_ACTIONS` is an OPEN list and the first argless verb to
-- land restores its case. ⚠ But a guard nothing can reach is untested, not safe - so
-- instead of inventing a fake action the shipped vocabulary does not have (which is the
-- permissive-stub fault, §457), this asserts the PRECONDITION that makes it dormant. The
-- day an argless action lands, THIS row fails and tells the next person to restore the
-- case above it.
-- ★★ AND THE DAY ARRIVED, THEN LEFT AGAIN, INSIDE ONE SESSION (§743). `waypoint` joined
-- `ROW_ACTIONS` declaring no arg - this row fired, the real case was restored above it - and
-- the verb was then WITHDRAWN, because the behaviour it named already exists as NO ACTION
-- (`manager.lua:614`). ⟶ The precondition is back, which is what the restored case instructed
-- in its own words if the vocabulary lost its argless verb.
--
-- ★ BOTH TRANSITIONS ARE RECORDED HERE ON PURPOSE. This row has now been proven to fire in
-- ONE direction (a verb arriving) and to be correctly restored in the OTHER - which is more
-- than a dormant guard usually gets, and worth keeping in the file rather than in a commit.
local anyArgless = nil
for _, w in ipairs(Routes.ROW_ACTIONS) do
    if Routes.ROW_ARG[w] == nil then anyArgless = w end
end
assert(anyArgless == nil,
       "AN ARGLESS ACTION EXISTS AGAIN (`" .. tostring(anyArgless) .. "`), so `DropRetired`'s "
       .. "stray-arg sweep has a reachable case once more and is currently UNTESTED. "
       .. "Restore a fixture for it here rather than deleting this row")

-- ⚠⚠ THE STRIP ASSERTIONS THAT STOOD HERE ARE GONE, NOT COMMENTED OUT.
--
-- They read the arg back off a `supertrack` row and asserted it had been stripped. AL-19
-- retired that verb, no remaining action declares no arg, and **there is no value to
-- construct the case from** - the shipped vocabulary cannot express it.
--
-- ★ Faking one with an action the client does not have is exactly the permissive-stub
-- fault (§457), and parking dead assertions is the standing invitation to build on them.
-- ⟶ The dormancy assert above is what replaced them, and it EXPIRES LOUDLY: the first
-- argless action to land fails that row and sends the next person back here.
--
-- ⚠ The two rows below survive because their cases are still reachable, and they are the
-- ones that stop the sweep becoming *strip every arg*.

-- ★★ AN ARG THE ACTION *DOES* TAKE IS NOT TOUCHED - the row that stops this from being
-- "strip every arg", which would pass every assertion above.
stale.rows = { { sense = "whenOn", action = "boss", arg = "Ragnaros" } }
Routes.DropRetired()
assert(stale.rows[1].arg == "Ragnaros",
       "A LEGITIMATE ARG WAS STRIPPED: `ROW_ARG.boss` is `name`, so the boss row's name "
       .. "is the one field that MUST survive - A3.3 says a boss row without it arms "
       .. "nothing, so this drop would silently disarm every boss listener in the file")

-- ★★ AN UNKNOWN ACTION KEEPS ITS ARG, and that is deliberate rather than an oversight.
-- The ACTION is the foreign thing; stripping its arg would make the row LOOK authorable
-- while BUCKET still refuses it by name (§457). Half-retiring a row invites building on it.
stale.rows = { { sense = "whenOn", action = "interpretiveDance", arg = "vigorously" } }
Routes.DropRetired()
assert(stale.rows[1].arg == "vigorously",
       "AN UNKNOWN ACTION'S ARG WAS STRIPPED: the action is what this build does not "
       .. "know, and a row left with a familiar shape and a foreign verb is harder to "
       .. "diagnose than one left whole")
stale.rows = nil
parent.rows = nil

-- =====================================================================
-- ★★★ A13.3 · CLEARING THE ACTION KEEPS THE ROW AND CLEARS ITS ARG (§469)
--
-- ★ WA changes a trigger's TYPE and clears NOTHING (`CommonOptions.lua:2024`) - the old
-- prototype's args persist forever, unread. Battlewrath took the half that keeps the RECORD
-- and refused the half that keeps the KEYS: *"I wouldn't copy the no-pruning. As that's
-- bloat. We can capture what is currently true."*
-- =====================================================================
Routes.SetRow(bossBeacon, bossKid, 1, "whenOn", "boss", offered[1], offered)
local cleared = Routes.SetRow(bossBeacon, bossKid, 1, "whenOn", nil)

-- ⚠⚠ THE ROW-SURVIVES ASSERTION COMES FIRST. Deletion was the ONLY exit from `boss`
-- before this, and a deleted row drops the node to zero rows - which A12.2g refuses at
-- build. An author unpicking a choice must not break the route.
assert(cleared ~= nil and Routes.RowsOf(bossKid)[1] ~= nil,
       "CLEARING THE ACTION DELETED THE ROW: the row's identity is its SENSE and the "
       .. "action is a modifier on it. Deletion stays reserved for sense AND action both nil")
assert(cleared.sense == "whenOn",
       "THE SENSE DID NOT SURVIVE: a row is SLOTS IN FIXED POSITIONS - clearing the action "
       .. "empties slots 2 and 3 and leaves slot 1 holding")
assert(cleared.action == nil, "the action slot must be empty")
assert(cleared.arg == nil,
       "THE ARG OUTLIVED THE ACTION THAT OWNED IT: the record captures what is CURRENTLY "
       .. "TRUE, so the name goes with the verb - `SetChildSense` is the shipped precedent "
       .. "(*and the name goes with it*). Keeping it is WA's no-pruning, which is bloat")

-- ★ AND CLEARING BOTH STILL DELETES - the behaviour that was already there, unchanged.
Routes.SetRow(bossBeacon, bossKid, 1, "whenOn", "boss", offered[1], offered)
Routes.SetRow(bossBeacon, bossKid, 1, nil, nil)
-- ★★★ AND THE NODE COMES BACK AS AN ARRIVAL ROW, NOT AS NOTHING (A13.1).
-- ⚠ This row asserted `== nil` until B0 landed, and the change is the RULING rather than
-- an accommodation: **a placed node always has one row.** Deleting the last one returns it
-- to the arrival default, which is also what makes A12.2g unreachable through authoring -
-- there is no sequence of edits that leaves a node unable to complete.
local reseeded = Routes.RowsOf(bossKid)
assert(#reseeded == 1 and reseeded[1].sense == "whenOn" and reseeded[1].action == nil,
       "DELETING THE LAST ROW LEFT THE NODE EMPTY: A13.1 - a placed node always has one "
       .. "row, and `RowsOf` is the door that guarantees it. An empty node can never "
       .. "complete, so authoring must have no way to produce one")

-- =====================================================================
-- ★★★ B1 (AL-17) · THE FLAT FORM BECOMES ROWS — ONCE, BOTH LEVELS, AND TOLD
--
-- ⚠ `child.rows` IS the instruction set (A1.1). The pane writes `action` / `boss`, and
-- until this landed NOTHING converted - §462's probe built a node with ZERO rows, which
-- arms, points the arrow and never advances.
-- =====================================================================
-- ⚠ DRAIN FIRST. `MigrateRows` walks the WHOLE route table, so its RETURN is a
-- store-wide count and earlier fixtures in this file still carry flat fields. ★ The
-- first cut asserted the count straight away and read another block's data as this
-- block's - a scope fault, and the same family as measuring the wrong thing.
-- ⚠⚠ BOUNDED, AND MUTATION IS WHY. As `while ... > 0 do end` this never terminated
-- the moment idempotence broke - which is precisely what E3 mutates - so the mutation
-- HUNG the suite instead of failing it. ★ A test that hangs is worse than one that
-- fails: it reports nothing and it blocks the gate. Anything that loops on a value the
-- code under test produces needs a ceiling.
local drained = false
for _ = 1, 50 do
    if Routes.MigrateRows() == 0 then drained = true; break end
end
assert(drained,
       "THE MIGRATION NEVER SETTLED: 50 passes and it was still converting. `MigrateRows` "
       .. "runs on EVERY load, so a pass that is not idempotent grows the file forever - "
       .. "a route would gain a tab every time the game started")

stale.rows, parent.rows = nil, nil
stale.action, parent.action = nil, nil
stale.boss, parent.boss = nil, nil

-- ★ A NODE WITH NOTHING GETS NOTHING. The seed is the authoring DOOR's job (B0/A13.1),
-- not the migration's - a migration that also seeded would make "was anything authored
-- here" unanswerable forever after.
local beforeEmpty = #chat
assert(Routes.MigrateRows() == 0,
       "THE MIGRATION INVENTED A ROW: it converts what was AUTHORED. Seeding is the door's "
       .. "job (A13.1), and a migration that seeds destroys the difference between a node "
       .. "someone configured and one nobody touched")
assert(#chat == beforeEmpty, "and it says nothing when it did nothing")

-- ★★★ A FLAT `supertrack` BECOMES THE **TICK**, NOT A ROW (AL-19).
--
-- ⚠⚠ THIS BLOCK ASSERTED THE OPPOSITE UNTIL §476, and §471 shipped that reading:
-- `supertrack` migrated into a `When on:supertrack` row. AL-19 then ruled it is not a
-- verb at all - *"the super tracker is what gets the player TO the sense site"* - so the
-- conversion is a DROP, and the node takes the arrival seed like any other.
-- ★ The correction was NAMED AS A COST in AI-8 before the ruling landed, so it is a
-- planned edit rather than a discovery.
stale.rows = nil
stale.action = "supertrack"
local beforeMig = #chat
Routes.MigrateRows()
assert(stale.action == nil,
       "THE RETIRED VERB SURVIVED THE MIGRATION: `supertrack` is the node\'s LED TO tick "
       .. "now, and a stored flat one is the author having chosen it - which is the "
       .. "DEFAULT, so §79\'s rule applies and nothing is stored")
assert(#(stale.rows or {}) == 0,
       "A ROW WAS MINTED FOR A RETIRED VERB: waypointing is not something that HAPPENS "
       .. "WHEN THE READER IS HERE - a `whenOn:supertrack` row would point the arrow at "
       .. "the node they are already standing in")
assert(#Routes.RowsOf(stale) == 1 and Routes.RowsOf(stale)[1].action == nil,
       "and the node takes the ARRIVAL SEED through the one door that mints one (A13.1)")

-- ★★ AN ALREADY-MIGRATED ROW CONVERTS TOO. ⚠ Not hypothetical: §471 ran in this repo,
-- so a dev store can hold the intermediate `whenOn:supertrack` shape. A migration that
-- only took the FLAT field would strand exactly the files this bench made yesterday.
stale.rows = { { sense = "whenOn", action = "supertrack" } }
Routes.MigrateRows()
assert(#(stale.rows or {}) == 0,
       "AN ALREADY-MIGRATED `supertrack` ROW SURVIVED: both stored shapes have to convert, "
       .. "or the intermediate one is stranded forever")

-- ★★ THE CHILD LEVEL: a flat BOSS becomes ONE `When on` row.
stale.rows = nil
stale.boss = "Ragnaros"
Routes.MigrateRows()
assert(#(stale.rows or {}) == 1,
       "the child\'s flat boss must become exactly one row - a child-only or beacon-only "
       .. "pass is a half-migration")
assert(stale.rows[1].sense == "whenOn",
       "THE MIGRATED SENSE IS WRONG: the flat sense was always `reachHere` - ARRIVAL - "
       .. "because `Routes.SENSES` is EMPTY and nothing else could ever be stored. Arrival "
       .. "is `whenOn` in the row grammar. got " .. tostring(stale.rows[1].sense))
local said = chat[#chat] or ""
assert(#chat > beforeMig and said:find("action", 1, true),
       "THE MIGRATION WAS SILENT: it rewrites the author\'s data on load, and A2.12b\'s "
       .. "criterion throughout this file is the MESSAGE. Said: " .. said)

-- ★★★ IDEMPOTENT, AND THE RULE THAT MAKES IT SO IS **ONCE ROWS EXIST, THE ROWS ARE
-- THE TRUTH**. ⚠ Without it the every-load call appends a duplicate row per load, and a
-- route would grow a tab every time the game started.
Routes.MigrateRows()
assert(#stale.rows == 1,
       "a second pass must convert nothing and must not append - `MigrateRows` runs on "
       .. "every load, so a route would grow a tab per game start. got "
       .. tostring(#stale.rows))

-- ⚠ AND A NODE THAT ALREADY HAS ROWS IS NOT TOUCHED even if a flat field reappears -
-- which it can, because the pane still writes one until L1.4.
stale.boss = "Ragnaros"
Routes.MigrateRows()
assert(#stale.rows == 1,
       "A FLAT WRITE WAS MERGED INTO A NODE THAT ALREADY HAS ROWS: once rows exist, the "
       .. "ROWS ARE THE TRUTH. Merging would revive the two-authored-truths fault AL-17 "
       .. "rejected converting-at-build over")

-- ★★ THE BEACON LEVEL, asserted SEPARATELY. A2.5 returns a child's tabs TO THE PARENT
-- when the last child goes, so a beacon carries these fields too - and the `bandDown`
-- block below is the standing lesson that a combined assert lets a child-only pass hide.
parent.boss = "Ragnaros"
Routes.MigrateRows()
assert(#(parent.rows or {}) == 1,
       "A BEACON WAS NOT MIGRATED: a child-only pass is a half-migration, and the beacon "
       .. "keeps its flat field forever while the driver reads rows")
assert(parent.rows[1].action == "boss" and parent.rows[1].arg == "Ragnaros",
       "THE BOSS NAME DID NOT BECOME AN ARG: the flat `boss` field IS the arg of a `boss` "
       .. "row - `When on:boss:<name>` - and A3.3 says a boss row without its name arms "
       .. "nothing, so losing it here would migrate the node into silence")

-- ★ BOTH FIELDS ON ONE NODE BECOME TWO ROWS, in the stated order.
-- ⚠ ONE FIELD, ONE ROW - `supertrack` used to be the second and is the tick now, so
-- there is no longer a flat shape that produces two. The ORDER row it proved goes with
-- it rather than being kept alive on a fixture the vocabulary cannot make.
stale.rows, parent.rows = nil, nil
parent.boss, stale.action = nil, nil
stale.boss = "Ragnaros"
Routes.MigrateRows()
assert(#stale.rows == 1 and stale.rows[1].action == "boss",
       "ONE AUTHORED FIELD, ONE ROW. ⚠ This asserted an ORDER over two rows until §476 - "
       .. " was the other one, and AL-19 made it the tick. No flat shape "
       .. "produces two rows any more, so the order claim went with the fixture that "
       .. "could make it rather than being kept alive on an invented one")

stale.rows, parent.rows = nil, nil
stale.action, stale.boss = nil, nil
parent.boss = nil

stale.bandDown = 2
parent.bandDown = 2
local beforeBand = #chat
local droppedBand = Routes.DropRetired()
-- ⚠ TWO ASSERTS, NOT ONE OVER BOTH. As a single combined assert, removing EITHER
-- level gave the same count and the same failure - the beacon half, which exists
-- precisely because a child-only sweep would miss it, had nothing proving it.
assert(stale.bandDown == nil,
       "A CHILD KEPT ITS DOWNWARD BAND: a retired field can arrive from an older "
       .. "build or a hand-edited SavedVariables, and neither bumps a schema version")
assert(parent.bandDown == nil,
       "A BEACON KEPT ITS DOWNWARD BAND: a beacon carries a reach too (G2, §299), so "
       .. "a sweep that walks only children leaves every beacon's copy in place - a "
       .. "HALF-retirement, which is the shape that invites building on it again")

-- ⚠ THE COUNT GOES LAST, and that ordering is the point. It sat FIRST, so a mutation
-- removing EITHER level produced count 1 and was caught HERE - the two rows above
-- could not be reached by the mutations written for them. ★ A broad assertion placed
-- ahead of narrow ones answers for all of them and hides which is broken.
assert(droppedBand >= 2,
       "THE DROP COUNT IS SHORT: two stored downward bands were planted, one on a "
       .. "child and one on a beacon, and the return is the TOTAL of what was "
       .. "dropped. Got " .. tostring(droppedBand))
local saidBand = chat[#chat] or ""
assert(saidBand:find("UPWARDS", 1, true),
       "THE DROP MESSAGE DID NOT SAY WHAT CHANGED: an author who set a downward band "
       .. "needs to know the band is upwards only now, not merely that something went. "
       .. "Said: " .. saidBand)

stale.fireOn = "start"                 -- as an older build would have left it
local beforeFire = #chat
assert(Routes.DropRetired() >= 1, "a stored firing field must be found")
assert(stale.fireOn == nil,
       "A RETIRED FIRING FIELD SURVIVED A LOAD: it can arrive from a hand-edited "
       .. "SavedVariables or an older import, and neither bumps a schema version")
assert(#chat > beforeFire,
       "AND IT MUST BE TOLD. ★ The MESSAGE is the criterion, not the drop - an "
       .. "author whose stored control vanishes silently has no way to find out why")

-- ★★ AND THE MESSAGE MUST BE TRUE OF WHAT IT DROPPED. ⚠ This is the assertion the
-- build was written around: folding `fireOn` into A2.6's counter would have passed
-- every row above while announcing a "retired POINTER" for a field that never
-- pointed - sending the author to look for a redirect they never authored.
local saidFire = chat[#chat] or ""
assert(saidFire:find("firing", 1, true) and not saidFire:find("pointer", 1, true),
       "THE DROP MESSAGE NAMED THE WRONG MECHANISM: `fireOn` is not a pointer, and "
       .. "a message that misdescribes what it dropped is worse than none - it "
       .. "sends the author hunting for something they never wrote. Said: " .. saidFire)

-- ⚠ idempotent, same as A2.6: a second load finds nothing and says nothing.
local quietFire = #chat
assert(Routes.DropRetired() == 0 and #chat == quietFire,
       "A CLEAN LOAD ANNOUNCED SOMETHING after the firing field was already dropped")
Routes.DeleteChild(parent, stale)
-- =====================================================================
-- ★★★ A2.11 - THE ORDINAL MINT AND GAP, which had no equivalent at all.
-- =====================================================================

-- ⚠⚠ SATISFIED BY THE SIGNATURE, NOT BY THIS ROW - and mutation is how that was
-- found. `NextOrdinal(b)` receives a BEACON and has no handle to the route: `b.id`
-- is the BID and `Routes.Get` needs the RID, so it CANNOT walk siblings. An attempt
-- to mutate it into route scope survived the suite because the mutation was a no-op.
-- ★ A stronger guarantee than a test - but the row below is a DEMONSTRATION, not a
-- guard, and must not be read as one.
-- A2.11a - SCOPE IS THE PARENT. Two beacons legitimately share ordinal 1, and a
-- mint that walked the ROUTE would collide across them.
local pa = Routes.AddBeacon(routeId, node)
local pb = Routes.AddBeacon(routeId, node)
local ka = Routes.AddChildHere(routeId, pa)
local kb = Routes.AddChildHere(routeId, pb)
Routes.SetChildOrdinal(pa, ka, 1)
Routes.SetChildOrdinal(pb, kb, 1)
assert(Routes.NextOrdinal(pa) == 2 and Routes.NextOrdinal(pb) == 2,
       "THE MINT WALKED THE ROUTE, NOT THE PARENT: ordinals are per-beacon, so two "
       .. "beacons each holding a child at 1 must BOTH be offered 2 - neither sees "
       .. "the other. Got " .. tostring(Routes.NextOrdinal(pa)) .. "/"
       .. tostring(Routes.NextOrdinal(pb)))

-- A2.11b - WHOLE NUMBERS from 1, and an UN-ORDINALLED child is SKIPPED, not 0.
local k3 = Routes.AddChildHere(routeId, pa)
local kn = Routes.AddChildHere(routeId, pa)
Routes.SetChildOrdinal(pa, k3, 3)
Routes.SetChildOrdinal(pa, kn, nil)     -- out of the line, on purpose (:566)
assert(Routes.OrdinalOf(kn) == nil, "the fixture must actually have no ordinal")
assert(Routes.NextOrdinal(pa) == 2,
       "THE MINT MISCOUNTED: children at 1 and 3 with one un-ordinalled leave 2 as "
       .. "the lowest free whole. ⚠ An un-ordinalled child is the UPDATE type - it "
       .. "is not in the numbering and must not consume a number. Got "
       .. tostring(Routes.NextOrdinal(pa)))

-- ⚠ AND THE SKIP MUST BE REACHABLE. Above, 1 was taken anyway, so a mint that wrongly
-- counted the un-ordinalled child as 1 would still answer 2 and the row would pass.
-- ★ Here nothing holds 1, so nil consuming it changes the answer - which is the only
-- shape that proves the skip.
local kb2 = Routes.AddChildHere(routeId, pb)
Routes.SetChildOrdinal(pb, kb, 2)
Routes.SetChildOrdinal(pb, kb2, nil)
assert(Routes.NextOrdinal(pb) == 1,
       "AN UN-ORDINALLED CHILD CONSUMED A NUMBER: with one child at 2 and one out of "
       .. "the line, the lowest free whole is 1. ⚠ The update type is not in the "
       .. "numbering at all. Got " .. tostring(Routes.NextOrdinal(pb)))
Routes.SetChildOrdinal(pb, kb, 1)
Routes.DeleteChild(pb, kb2)

-- ★★ A2.11c - A GAP IS A MISSING WHOLE NUMBER. Both of the row's cases, by name.
local g = Routes.OrdinalGaps(pa)
assert(#g == 1 and g[1] == 2,
       "CASE ONE FAILED: ordinals 1 and 3 leave exactly one gap, at 2")

-- ⚠ and the case that makes this NOT a mirror of `Gaps`: insertion is not a hole.
Routes.SetChildOrdinal(pa, k3, 1.5)
local g2 = Routes.OrdinalGaps(pa)
assert(#g2 == 0,
       "CASE TWO FAILED: ordinals 1 and 1.5 have NO gap - 1.5 is INSERTION, not a "
       .. "hole. ★ A fraction never creates a gap and never fills one, and it does "
       .. "not raise the ceiling either. Got " .. tostring(#g2) .. " gap(s)")

-- ⚠ THE MIRROR WOULD HAVE PASSED BOTH CASES ABOVE. `Gaps` floors the top, and
-- flooring 1.5 gives 1, which is the same answer by ACCIDENT. This is the case that
-- separates them: 1 and 2.5 must report NOTHING, because no author left a hole at 2.
Routes.SetChildOrdinal(pa, k3, 2.5)
local g3 = Routes.OrdinalGaps(pa)
assert(#g3 == 0,
       "THE GAP FUNCTION IS A MIRROR OF `Gaps`: ordinals 1 and 2.5 must report NO "
       .. "gap. Flooring the top to 2 invents a hole at 2 that nobody left - which "
       .. "is the exact difference A2.11c was written to state. Got "
       .. tostring(g3[1]))

Routes.DeleteBeacon(routeId, pa.id)
Routes.DeleteBeacon(routeId, pb.id)

-- =====================================================================
-- ★★★ A8.4 — THE RID MIGRATION, against §23's criterion (M1–M7)
--
-- ⚠ The criterion was written BEFORE this code (proposition §23). These assertions
-- are its rows, not a description of what the migration turned out to do.
-- =====================================================================
local function oldDB(routes)
    COA_DungeonRunDB = { schemaVersion = 1, nextId = 9, runs = {}, routes = routes }
    Store.locked = nil
    Store.fromSchema = nil
    assert(Store.Load(), "an old db must LOAD - schemaVersion 1 is known, not refused")
    assert(Store.fromSchema == 1, "and Load must record that a migration is owed")
end

-- A route as the old shape stored it: the key carries the name AND the counter.
local legacy = {
    ["SFK speed-3"]  = { name = "SFK speed", mapID = 33, beacons = {},
                         nextBeaconId = 7, nextChildId = 4 },
    ["SFK: fast-5"]  = { name = "SFK: fast", mapID = 33, beacons = {} },
}
local keptA, keptB = legacy["SFK speed-3"], legacy["SFK: fast-5"]
oldDB(legacy)
local moved, already, stuck = Routes.MigrateRIDs()

-- ⚠⚠ ORDERED SO EACH MUTATION HAS A DISTINCT FIRST FAILURE (§335). The first cut led
-- with the COUNTS, which catch everything - a wrong parse, a lost field and a kept key
-- all show up as "moved 0" before reaching the assertion written for them. That is the
-- weak-test shape this bench keeps finding: assertions ordered behind one that fires
-- first. Narrowest claim first, counts LAST as the backstop.

-- M1  RECOVERED, NEVER INVENTED — the rid is parsed out of the old key's tail.
assert(Routes.Get(3) ~= nil and Routes.Get(5) ~= nil,
       "THE RID WAS NOT READ FROM THE OLD KEY: `SFK speed-3` must become 3 and "
       .. "`SFK: fast-5` must become 5 - the counter was already there, so the new "
       .. "identity is a READ and never a fresh number")

-- M2  NOTHING LOST — read THROUGH the new key, so a copy that carried a field list
-- rather than the table itself fails here. ★ The migration moves the REFERENCE, which is
-- what makes this hold for fields nobody thought to list.
assert(Routes.Get(3).nextBeaconId == 7 and Routes.Get(3).nextChildId == 4,
       "A CARRIED FIELD WENT MISSING: the migration moves the TABLE, so a field list is "
       .. "not what protects this - and a field list is what would have missed it")
assert(Routes.Get(3) == keptA and Routes.Get(5) == keptB,
       "and it is the SAME table, not a faithful copy - identity is the guarantee")

-- M3  ONE IDENTITY AFTERWARDS.
assert(Store.RouteTable()["SFK speed-3"] == nil,
       "the old key must be GONE - two identities is the half-formed shape (M3)")

-- ★ The counts LAST, as the backstop rather than the gate.
assert(moved == 2 and already == 0 and #stuck == 0,
       ("MIGRATION DID NOT MOVE WHAT IT SHOULD: moved %d, already %d, stuck %d")
       :format(moved, already, #stuck))

-- ★ M4  A COLON IN THE NAME ROUND-TRIPS. This is the live defect A8.4 names.
assert(Routes.Get(5).name == "SFK: fast",
       "the NAME keeps its colon - it is free text")
assert(type(select(1, next(Store.RouteTable()))) == "number",
       "A COLON IN A ROUTE NAME REACHED THE KEY: the address separator cannot appear "
       .. "in a segment, which is the whole reason the rid is opaque")

-- M2  NOTHING LOST — asserted as identity, not as a field list. ★ The migration moves
-- the REFERENCE, so this holds for every field including ones nobody listed.
assert(keptA.nextBeaconId == 7 and keptA.nextChildId == 4,
       "A CARRIED FIELD WENT MISSING: the migration moves the TABLE, so a field list "
       .. "is not what protects this - and a field list is what would have missed it")
assert(Routes.Get(3).name == "SFK speed" and Routes.Get(3).mapID == 33,
       "and the ordinary fields with it")

-- M7  the stamp, and ONLY on a clean run.
assert(COA_DungeonRunDB.schemaVersion == Store.SCHEMA,
       "a CLEAN migration must stamp the new schema")
assert(Store.fromSchema == nil, "and clear the owed flag")

-- M5  IDEMPOTENT — running it again moves nothing and says so.
local moved2, already2 = Routes.MigrateRIDs()
assert(moved2 == 0 and already2 == 2,
       ("A SECOND RUN MOVED SOMETHING: %d moved, %d already. A migration that is not "
        .. "safe to re-run is one nobody dares run"):format(moved2, already2))

-- ⚠ M1's REFUSAL HALF, and it is the one that matters most. A key with no readable
-- counter is REPORTED and LEFT — never given a fresh number, because a fresh number is
-- a new identity wearing an old route's name and nothing downstream could tell.
local orphan = { name = "hand edited", mapID = 33, beacons = {} }
oldDB({ ["no counter here"] = orphan, ["good-2"] = { name = "good", beacons = {} } })
local m3, _, stuck3 = Routes.MigrateRIDs()
assert(m3 == 1 and #stuck3 == 1 and stuck3[1] == "no counter here",
       "AN UNREADABLE KEY WAS NOT REPORTED: it must be named and left alone")
assert(Store.RouteTable()["no counter here"] == orphan,
       "and the route itself must be UNTOUCHED - left as it is, not dropped")
assert(COA_DungeonRunDB.schemaVersion == 1,
       "⚠ A PARTIAL MIGRATION MUST NOT STAMP: a db claiming a shape it does not have is "
       .. "worse than an unmigrated one, because the next load would not try again")

-- ⚠ And a collision cannot overwrite. Impossible from `composeId` (the counter is
-- monotonic) but reachable by hand-editing SavedVariables, where it would destroy a
-- route silently.
local a, b = { name = "a", beacons = {} }, { name = "b", beacons = {} }
oldDB({ ["a-1"] = a, ["b-1"] = b })
local m4, _, stuck4 = Routes.MigrateRIDs()
assert(m4 == 1 and #stuck4 == 1,
       "TWO KEYS PARSING TO ONE RID BOTH MOVED: the second must be refused, not "
       .. "written over the first")
assert(Routes.Get(1) ~= nil, "the first one lands")

COA_DungeonRunDB = nil
Store.locked = nil
Store.fromSchema = nil
assert(Store.Load(), "and the fixture db is put back for anything after this")

-- =====================================================================
-- =====================================================================
-- ★ A5 - THE ADAPTOR. FILLED §367, and it is A10.2's PRECONDITION rather than a
-- convenience: the fold cannot type its own labels if there is one place words live.
-- =====================================================================
local Adaptor = NS.Adaptor
assert(Adaptor, "adaptor.lua did not publish Adaptor")

-- A5.1  ONE lookup, and a miss PASSES THROUGH the code term.
assert(type(Adaptor.Word) == "function", "the ONE lookup must exist")
assert(Adaptor.Word("reachHere") == "reach here", "a listed term resolves")

-- ★★ THE PASS-THROUGH, and Battlewrath's reason for it (2026-08-18): pass-through is NOT
-- a silent failure - the term is shown under its CODE NAME when the adaptor has not
-- resolved it, *"so what the instruction was calling for is still EXPRESSED to the
-- author."* The pane degrades to LEGIBLE, never to blank and never to an error.
assert(Adaptor.Word("someTermFromAVersionWeDoNotHave")
       == "someTermFromAVersionWeDoNotHave",
       "A MISS DID NOT PASS THROUGH: the author must still see WHAT the instruction was "
       .. "calling for. Blank hides it; an error moves a bench problem onto their screen")
assert(Adaptor.Has("someTermFromAVersionWeDoNotHave") == false,
       "and the bench can tell a pass-through from a resolution - A5.3 is what makes the "
       .. "miss LOUD on our side (§295: two audiences, two behaviours, one event)")

-- ⚠ A non-string is not coerced. `tostring(nil)` would put the word "nil" on a pane as
-- though it were a label - a caller bug wearing a costume.
assert(Adaptor.Word(nil) == nil and Adaptor.Word(7) == 7,
       "a non-string must pass through AS ITSELF, never as its tostring")

-- A5.2  every published vocabulary value RESOLVES OR PASSES THROUGH - the pane never
-- errors on a missing row. ⚠ Walked over the LIVE lists, so a value added to routes.lua
-- tomorrow is covered by this assertion without anybody remembering to come back.
for _, list in ipairs({ Routes.ROLES, Routes.SHAPES, Routes.ACTIONS,
                        Routes.SENSES, Routes.SENSE_WORDS, Routes.ROW_ACTIONS }) do
    for _, v in ipairs(list) do
        local w = Adaptor.Word(v)
        assert(type(w) == "string" and w ~= "",
               ("A VOCABULARY VALUE RENDERED AS NOTHING: `%s`. Resolve or pass through - "
                .. "those are the only two outcomes, and an empty pane label is neither")
               :format(tostring(v)))
    end
end

-- ★ AND THE RETIREMENT IS REAL. RI-16: "ROLE_TEXT + SENSE_TEXT retire INTO it - no
-- private per-file word tables remain." A second table is a second answer to "what does
-- the author call this", and nothing notices when the two stop agreeing.
local paneSrc = assert(io.open(ROOT .. "object.lua")):read("*a")
assert(not paneSrc:match("local%s+SENSE_TEXT%s*=") and not paneSrc:match("local%s+ROLE_TEXT%s*="),
       "A PRIVATE WORD TABLE IS STILL DEFINED IN object.lua: the adaptor is ONE lookup, "
       .. "and a per-file copy is the scattered shape it exists to replace")

local SLOTS = {
    { "A1.1", "SetBeaconReach stores; ReachOf is a PURE ACCESSOR (T13, §349)", false },
    { "A1.2", "a childless beacon with a radius is RUNNABLE", false },
    { "A1.3", "the beacon's z is still the read's; band is a tolerance over it", false },
    { "A2.1", "sparse child ordinal; insertion renumbers NOTHING", false },
    { "A2.2", "4.1:3 resolves to exactly one child, route-wide unique", false },
    { "A2.3", "two children on one ordinal is TOLD, never refused", false },
    { "A2.4", "parent surface and child pane write the SAME field", false },
    { "A3.1", "boss axis (NOT `kind` - taken, see above); picker fed ONLY from r.bosses", false },
    { "A3.2", "two senses: boss engaged / boss killed", false },
    { "A3.3", "a nameless boss child arms NOTHING and is told", false },
    { "A3.4", "no set, count or grouping is stored or shown", false },
    { "A4.1", "a note resolves to exactly ONE string at runtime", false },
    { "A4.2", "R1 RULED (RI-1+RI-10): referenced in the store, owned in the pane", false },
    { "A4.3", "a child with no note renders nothing", false },
    { "A5.1", "a missing adaptor row PASSES THROUGH the code term", false },
    { "A5.2", "every ROLES/SHAPES/ACTIONS value resolves or passes through", false },
    { "A6.1", "a boss kill alone moves the stage", true },
    { "A6.2", "both witnesses required; either alone does not advance", true },
}

local open = 0
for _, s in ipairs(SLOTS) do
    if s[3] then open = open + 1 end
end

print("smoke_dungeonrunroutes: load chain OK, baselines OK")
print(("  %d of %d criteria UNCOVERED - this file is a place for them, not a test of them")
      :format(open, #SLOTS))
for _, s in ipairs(SLOTS) do
    if s[3] then print(("    [ ] %-5s %s"):format(s[1], s[2])) end
end
if open == 0 then
    print("  ★ every slot filled - delete this roster and let the assertions speak")
end
-- =====================================================================
-- ★★ A11.1 · THE FIXTURE VOCABULARY MUST NOT DRIFT FROM THE SOURCE.
--
-- `fixtures_route.lua` declares its own `sense` / `action` word lists rather than
-- importing them, because `smoke_contract` has to run with nothing loaded but the
-- contract and the fixtures - that standalone property IS A11.1b's point, and a
-- fixture list that imported `Routes` would hand the grader a dependency on the
-- thing being graded.
--
-- ⚠ But a private copy that silently diverges grades against a world that stopped
-- existing. So the copy is checked HERE, where `Routes` is loaded anyway.
-- =====================================================================
local FIX = assert(dofile("addons/tools/smoke/fixtures_route.lua"),
                   "fixtures_route.lua did not return its table")

for _, w in ipairs(Routes.SENSE_WORDS) do
    assert(FIX.vocabulary.sense[w],
           "THE FIXTURE SENSE VOCABULARY IS BEHIND THE SOURCE: `" .. w .. "` is a "
           .. "shipped sense word and the fixtures do not know it. A private copy "
           .. "that diverges grades against a world that stopped existing")
end
for w in pairs(FIX.vocabulary.sense) do
    local found = false
    for _, s in ipairs(Routes.SENSE_WORDS) do if s == w then found = true end end
    assert(found,
           "THE FIXTURE SENSE VOCABULARY IS AHEAD OF THE SOURCE: `" .. w .. "` is not "
           .. "a shipped sense word. ⚠ BOTH directions are checked - a fixture that "
           .. "invents a word passes every shape assertion and grades nothing real")
end

for _, w in ipairs(Routes.ROW_ACTIONS) do
    assert(FIX.vocabulary.action[w],
           "THE FIXTURE ACTION VOCABULARY IS BEHIND THE SOURCE: `" .. w .. "` ships "
           .. "and the fixtures do not know it")
end
for w in pairs(FIX.vocabulary.action) do
    local found = false
    for _, a in ipairs(Routes.ROW_ACTIONS) do if a == w then found = true end end
    assert(found,
           "THE FIXTURE ACTION VOCABULARY IS AHEAD OF THE SOURCE: `" .. w .. "` is "
           .. "not a shipped action word")
end
-- =====================================================================
-- ★★★ A11.9b - THE PARK POINT, the supertracker's escapement target.
--
-- ⚠ This grades the GEOMETRY only. A11.9a's escapement - "complete a node whose tabs
-- set no marker -> the tracker reads the park" - needs a driver to complete a node,
-- and the driver is P3. The park has to be right BEFORE the escapement can use it.
-- =====================================================================
local pid = select(1, Routes.Create("park", 33))
local pleg = node                      -- the file's own placed fixture
local pb1 = Routes.AddBeacon(pid, pleg)
local pb2 = Routes.AddBeacon(pid, pleg)
-- ⚠ Spread the two so the bounding box is not degenerate: a park computed from a
-- single point would pass a clearance test by accident rather than by rule.
pb1.x, pb1.y, pb1.z = 100, 200, 50
pb2.x, pb2.y, pb2.z = 340, 260, 55
local pkid = Routes.AddChildHere(pid, pb1)
pkid.x, pkid.y, pkid.z = 220, 500, 52

local px, py, pz, pmap = Routes.ParkFor(pid)
assert(px and py, "THE PARK DID NOT COMPUTE for a route with placed nodes")

-- ★ THE GUARANTEE, asserted rather than the choice of axis. Clearance is what the
-- escapement depends on; which side it parks is arbitrary and must stay arbitrary.
local clear = Routes.ParkClearance(pid)
assert(clear >= 1600 - 0.001,
       "THE PARK STANDS TOO CLOSE: every node must be at least the standoff away, or "
       .. "the escapement target is inside the route it is supposed to stand off "
       .. "from. Nearest node at " .. tostring(clear) .. " yd")

-- ⚠⚠ HORIZONTAL, NEVER VERTICAL - measured, not stylistic. Overhead at 1600, twenty
-- yards of walking moves the reading by 0.125 yd, indistinguishable from a frozen
-- value. An instrument that cannot show change looks exactly like a dead one.
assert(pz == pb1.z or pz == pb2.z or pz == pkid.z,
       "THE PARK INVENTED A HEIGHT: it is HORIZONTAL, so z comes from a real node's "
       .. "own plane. A vertical standoff is the silent-wrong shape ROUTER measured")
assert(px ~= pb1.x or py ~= pb1.y,
       "THE PARK LANDED ON A NODE")

-- ★ SAME mapID, and it must be - across a map boundary the tracker returns Invalid
-- with distance 0.00 rather than nil, and ZERO SATISFIES EVERY RADIUS TEST. A
-- cross-map park is a false-positive generator, not an escapement.
assert(pmap == pb1.mapID,
       "THE PARK CHANGED MAP: mapID is the CONTINENT (1,291 yd of travel never "
       .. "changed it), so 1600 yd out is trivially the same map - and a park that "
       .. "left it would read a confident 0.00 into every radius check")

-- ⚠ AND IT REFUSES RATHER THAN INVENTING. A route with nothing placed has no node
-- set to stand off from; a park computed from nothing is a coordinate we made up.
local eid = select(1, Routes.Create("nothing placed", 33))
assert(Routes.ParkFor(eid) == nil,
       "THE PARK WAS INVENTED FROM AN EMPTY ROUTE: with no placed node there is "
       .. "nothing to stand off from, and the same law that makes AddBeacon refuse a "
       .. "node with no mapX applies here")

-- ★ THE GUARANTEE HOLDS ON A DIFFERENT LAYOUT - a second shape, not a second rule.
--
-- ⚠⚠ THE AXIS CHOICE IS NOT GRADEABLE AND THIS ROW DOES NOT PRETEND TO GRADE IT.
-- It was first written as "the choice rule takes the wider spread, so a route
-- stretched in y must clear exactly as one stretched in x" - and a mutation forcing
-- ALWAYS-X SURVIVED. Parking beyond the x extreme clears the standoff whatever the y
-- spread is, because the perpendicular spread only ADDS distance. ★ The function's
-- own comment already said the axis cannot buy more room; the assertion contradicted
-- it by implying a failure mode that does not exist.
--
-- ⟶ So what this fixture buys is a DIFFERENT SHAPE reaching the same guarantee - a
-- long thin route rather than a squat one - and the axis branch remains a preference
-- with no observable consequence. **Recorded rather than asserted around.**
local qid = select(1, Routes.Create("park tall", 33))
local qb = Routes.AddBeacon(qid, pleg)
local qc = Routes.AddChildHere(qid, qb)
qb.x, qb.y, qb.z = 10, 10, 5
qc.x, qc.y, qc.z = 40, 900, 5          -- y spread 890 >> x spread 30
local qclear = Routes.ParkClearance(qid)
assert(qclear >= 1600 - 0.001,
       "THE STANDOFF FAILED ON A LONG THIN ROUTE: the guarantee is clearance from "
       .. "EVERY node, and a shape whose spread is nearly all in one axis must reach "
       .. "it as squarely as a compact one. Nearest node at " .. tostring(qclear))
