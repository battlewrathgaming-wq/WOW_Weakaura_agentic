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

-- ⚠ NO DEFAULT IS INVENTED. R2 is unruled; a beacon nobody gave a band comes back
-- nil, not 2.5. When R2 rules a default this assertion is the one that changes, and
-- it changes in ONE place.
local bare = assert(Routes.AddBeacon(routeId, node, 4), "AddBeacon returned nil")
local nr, nu = Routes.ReachOf(bare)
assert(nr == nil and nu == nil,
       "an unset reach must be nil - a returned default is indistinguishable from a typed one")

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
stale.rows = { { sense = "whenOn", action = "supertrack", arg = "junk" } }
parent.rows = { { sense = "whenOn", action = "supertrack", arg = "junk" } }
local beforeArg = #chat
local droppedArg = Routes.DropRetired()

-- ⚠⚠ TWO ASSERTS, NOT ONE OVER BOTH - the band block one screen down learned this the
-- hard way: as a single combined assert, removing EITHER level gave the same count and
-- the same failure, so the beacon half had nothing proving it.
assert(stale.rows[1].arg == nil,
       "A STRAY ARG SURVIVED A LOAD ON A CHILD: `supertrack` takes no argument, and a "
       .. "field this build never writes must not be silently honoured (A2.12b)")
assert(parent.rows[1].arg == nil,
       "A STRAY ARG SURVIVED A LOAD ON A BEACON: A2.5 returns a child's tabs TO THE "
       .. "PARENT when the last child goes, so a beacon carries rows of its own - a "
       .. "child-only sweep is the half-retirement the band field already taught us about")

-- ★ THE REST OF THE ROW IS UNTOUCHED. Dropping the arg must not blank the sense or the
-- action: `SetRow`'s own precedent is that a rejected value *"must not blank the action
-- the author already chose"*, and a row silently emptied is worse than one carrying junk.
assert(stale.rows[1].action == "supertrack" and stale.rows[1].sense == "whenOn",
       "THE DROP TOOK THE WHOLE ROW: only the field the action does not have is retired")

assert(droppedArg >= 2, "both levels must be counted in the return, got "
       .. tostring(droppedArg))
local saidArg = chat[#chat] or ""
assert(saidArg:find("argument", 1, true),
       "THE DROP WAS SILENT: A2.12b's criterion is the MESSAGE, and an author who sees a "
       .. "field vanish with no word goes looking for a bug. Said: " .. saidArg)
assert(#chat > beforeArg, "a drop that says nothing is the mutation A2.12b bites on")

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
assert(Routes.RowsOf(bossKid)[1] == nil,
       "CLEARING SENSE AND ACTION MUST STILL REMOVE THE ROW: A13.3 narrows what deletes, "
       .. "it does not remove deletion")

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

-- ★★ THE CHILD LEVEL: a flat action becomes ONE `When on` row.
stale.action = "supertrack"
local beforeMig = #chat
-- ⚠ NO COUNT ASSERT HERE. `MigrateRows` returns a STORE-WIDE total, so a count row
-- answers for every node in the file and hides which one was missed - it caught the
-- child-level mutation and reported "one authored action, one row", which names a
-- number and not the level.
Routes.MigrateRows()
assert(#(stale.rows or {}) == 1,
       "the child's flat action must become exactly one row - a child-only or "
       .. "beacon-only pass is a half-migration")
assert(stale.rows[1].sense == "whenOn",
       "THE MIGRATED SENSE IS WRONG: the flat sense was always `reachHere` - ARRIVAL - "
       .. "because `Routes.SENSES` is EMPTY and nothing else could ever be stored. Arrival "
       .. "is `whenOn` in the row grammar. got " .. tostring(stale.rows[1].sense))
assert(stale.rows[1].action == "supertrack", "and the action carries across unchanged")
local said = chat[#chat] or ""
assert(#chat > beforeMig and said:find("rows", 1, true),
       "THE MIGRATION WAS SILENT: it rewrites the author's data on load, and A2.12b's "
       .. "criterion throughout this file is the MESSAGE. Said: " .. said)

-- ★★★ IDEMPOTENT, AND THE RULE THAT MAKES IT SO IS **ONCE ROWS EXIST, THE ROWS ARE
-- THE TRUTH**. ⚠ Without it the every-load call appends a duplicate row per load, and a
-- route would grow a tab every time the game started.
-- ★ THE NODE-SCOPED ROW IS THE ONE THAT NAMES THE FAULT: a duplicate row on THIS
-- node is what a non-idempotent pass produces, and the store-wide count only says
-- "something happened".
Routes.MigrateRows()
assert(#stale.rows == 1,
       "a second pass must convert nothing and must not append - `MigrateRows` runs on "
       .. "every load, so a route would grow a tab per game start. got "
       .. tostring(#stale.rows))

-- ⚠ AND A NODE THAT ALREADY HAS ROWS IS NOT TOUCHED even if a flat field reappears -
-- which it can, because the pane still writes one until L1.4. The flat write is IGNORED,
-- not merged: two authored truths is the fault AL-17 rejected converting-at-build over.
stale.action = "supertrack"
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
stale.rows, parent.rows = nil, nil
parent.boss = nil                      -- ⚠ or the beacon migrates too and the count is 3
stale.action, stale.boss = "supertrack", "Ragnaros"
Routes.MigrateRows()
assert(#stale.rows == 2 and stale.rows[1].action == "supertrack"
       and stale.rows[2].action == "boss",
       "THE ORDER MOVED: nothing downstream depends on it, but a migration that ordered "
       .. "differently per run would make two saved files disagree for no reason")

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
