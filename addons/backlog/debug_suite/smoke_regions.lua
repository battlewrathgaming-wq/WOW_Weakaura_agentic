-- Smoke regions lifted from addons/tools/smoke/smoke_dungeonrunpromoter.lua at ac41961.
-- ⚠ NOT RUNNABLE. Fixtures above and below each region were left behind;
-- these are the assertions and their immediate context, kept so the rules
-- they encode can be rebuilt against whatever drives next.


-- ===== original lines 313-327 =====
load("map.lua")
load("promoter.lua")
load("object.lua")
load("driver.lua")
local Map, Promoter, Object, Driver = NS.Map, NS.Promoter, NS.Object, NS.Driver
Map.Init()
Promoter.Init()
-- ★ §71: the object's own pane. Loaded here rather than in a smoke of its own
-- because it needs the same fixture - runs, a route, an initialised map - and
-- duplicating that would give two fixtures to keep in step instead of one.
Object.Init()
Driver.Init()

local function find(text)
    for _, o in ipairs(made) do if o._text == text then return o end end

-- ===== original lines 754-767 =====
-- =====================================================================
local R, B = 5.0, 2.5

assert(Driver.Reached(0, 0, 100, 0, 0, 100, R, B), "standing on it")
assert(Driver.Reached(0, 0, 100, 3, 0, 100, R, B), "within the interact radius")
assert(not Driver.Reached(0, 0, 100, 6, 0, 100, R, B), "and outside it")

-- ★★ THE CASE HE BUILT. Standing on the floor: 3.12 yd from the walkway beacon on
-- the map, 9.71 yd below it. A planar-only test fires; the height check is the only
-- thing that stops it.
assert(not Driver.Reached(-218.39, 2141.45, 80.91,
                          -217.48, 2144.43, 90.62, R, B),
       "WALKWAY FIRED FROM THE FLOOR: 3.12 yd planar is inside any useful radius - "
       .. "nothing but z separates them (§73)")

-- ===== original lines 775-817 =====
-- change, so the test is a PAIR - one that must fire and one that must not, at the
-- same magnitude.
local UP, DOWN = 12, 2
assert(Driver.Reached(-218.39, 2141.45, 90.62,
                      -217.48, 2144.43, 80.91, R, UP, DOWN),
       "THE LEDGE DID NOT FIRE: standing 9.71 yd ABOVE the beacon is inside a 12 yd "
       .. "up-band, which is what selecting a walkway means")
assert(not Driver.Reached(-218.39, 2141.45, 80.91,
                          -217.48, 2144.43, 90.62, R, UP, DOWN),
       "THE FLOOR FIRED THROUGH AN ASYMMETRIC BAND: 9.71 yd BELOW must be judged "
       .. "against `down`, not against `up`")

-- ★ ONE BAND IS STILL SYMMETRIC. Every existing caller passes one value, so the old
-- meaning has to survive untouched or §73's cases quietly change under them.
assert(Driver.Reached(0, 0, 5, 0, 0, 0, 10, 6),
       "one band no longer reaches UP")
assert(Driver.Reached(0, 0, -5, 0, 0, 0, 10, 6),
       "ONE BAND STOPPED BEING SYMMETRIC: `down` must default to `band`, or every "
       .. "existing caller silently changed shape")
assert(Driver.Reached(-217.48, 2144.43, 90.62,
                      -217.48, 2144.43, 90.62, R, B), "and on the walkway it fires")

-- ★ A jump must not lose you the stage: the arc keeps you inside the band, and the
-- driver scans per FRAME rather than at the capture's 1 Hz (§73's correction).
assert(Driver.Reached(0, 0, 101.9, 0, 0, 100, R, B),
       "JUMP DROPPED THE STAGE: ~1.9 yd is a jump, not a different surface")

-- ★ §73's `None` is a SPHERE, not an infinite cylinder - the planar test still
-- bounds it, and the walkway is caught only because it is within 5 yd in the plane.
assert(Driver.Reached(-218.39, 2141.45, 80.91,
                      -217.48, 2144.43, 90.62, R, nil),
       "with NO height requirement the same pair fires - which is why the option is "
       .. "named apart rather than being the default")

assert(not Driver.Reached(nil, 0, 0, 0, 0, 0, R, B), "no player position, no hit")
-- ★ A beacon with no world position cannot be satisfied. Dropping this guard is a
-- HARD ERROR rather than a wrong answer - arithmetic on a nil, inside a per-frame
-- scan - so the mutation for it expects the crash. That is the good failure: there
-- is no wrong ANSWER here to catch, only a dead driver.
assert(not Driver.Reached(0, 0, 0, nil, nil, nil, R, B),
       "an unplaceable stage must be refused, not thrown on")

-- =====================================================================

-- ===== original lines 852-862 =====
-- ★★ THE RATCHET. It is IN the expression, not beside it, so nothing anywhere can
-- walk the index backwards - which is what makes checkpoints safe to scatter
-- through a route without reasoning about traversal order.
assert(Driver.Promote(3, 4) == 4, "a forward outcome moves the index")
assert(Driver.Promote(9, 4) == 9,
       "THE RATCHET IS MISSING: re-crossing a checkpoint dragged progress BACKWARDS")
assert(Driver.Promote(4, 4) == 4, "and an equal one is inert rather than an error")
assert(Driver.Promote(3, nil) == 3, "no outcome, no movement")

-- ★ STAGE IS A LABEL, NOT AN ARRAY POSITION. DeleteBeacon matches on b.stage and
-- leaves a GAP, so {1,3} is an ordinary route - and the driver indexed the table by

-- ===== original lines 1151-1159 =====
-- ★★★ §85: THE CHILD'S PROPERTIES, and the walk that reads them
-- =====================================================================

load("walk.lua")
local Walk = NS.Walk
Walk.Init()

local pid = Routes.Create("props", 33)
local pb = Routes.AddBeacon(pid, node)

-- ===== original lines 1263-1300 =====
Routes.SetChildReach(acc, 10, 6, 2)
acc.x, acc.y, acc.z = 100, 200, 50

assert(Walk.Hits(acc, 100, 200, 50), "the walk sees a child it is standing on")
assert(not Walk.Hits(acc, 140, 200, 50), "and not one 40 yd away")
assert(not Walk.Hits(acc, 100, 200, 40),
       "THE WALK IGNORED THE BAND: 10 yd below a 2 yd down-band must not fire")

-- ★★★ THE RATCHET IS UNTOUCHED (§79). `complete` promotes; re-crossing is inert and
-- SAYS SO rather than going quiet - that is the ordinary recovery path.
assert(Walk.Start(wid), "the walk starts")
local ev = Walk.Scan(100, 200, 50)
assert(#ev == 1 and ev[1].why == "complete", "the acceptance fired")
assert(Walk.Index() == 2, "and the index advanced to stage+1")
local again = Walk.Scan(100, 200, 50)
assert(#again == 0, "STANDING STILL RE-FIRED: a detector speaks once per visit")
Walk.Scan(400, 400, 50)                       -- leave the radius
local revisit = Walk.Scan(100, 200, 50)
assert(#revisit == 1 and revisit[1].why == "ratcheted",
       "A RE-CROSS WAS SILENT: the ratchet holding is information, not nothing")
assert(Walk.Index() == 2, "and the index did not move")

-- ★★★ SET ASSIGNS, AND `if unseen` MAKES IT IDEMPOTENT.
local sb = Routes.AddBeacon(wid, node)
sb.stage = 5
local setter = Routes.AddChildFromNode(wid, sb, node)
Routes.SetChildRole(sb, setter, "set")
Routes.SetChildStage(sb, setter, 5)
Routes.SetChildReach(setter, 10, 6, 2)
setter.x, setter.y, setter.z = 300, 300, 50
local s1 = Walk.Scan(300, 300, 50)
assert(#s1 == 1 and s1[1].why == "set" and Walk.Index() == 5,
       "SET DID NOT ASSIGN: it is index = N, with no max")
Walk.Scan(700, 700, 50)
local s2 = Walk.Scan(300, 300, 50)
assert(#s2 == 1 and s2[1].why == "unseen-blocked",
       "A SEEN SET FIRED AGAIN: `if unseen` is what makes it idempotent, the way "
       .. "max does for complete")

-- ===== original lines 1311-1321 =====
Routes.SetChildIfUnseen(back, false)          -- deliberately sharp: fire every time
Routes.SetChildReach(back, 10, 6, 2)
back.x, back.y, back.z = 500, 500, 50
assert(Walk.Index() == 5, "we are ahead before the backward set")
local bev = Walk.Scan(500, 500, 50)
assert(#bev == 1 and bev[1].why == "set" and Walk.Index() == 3,
       "SET DID NOT ASSIGN: it is index = N with NO max, and going backwards is the "
       .. "case it exists for - got " .. tostring(Walk.Index()))

-- ★★★ AND A COMPLETED STAGE MUST BLOCK A SET THAT TARGETS IT. This is the only
-- assertion that reads the ledger write on the COMPLETE path - the earlier

-- ===== original lines 1328-1334 =====
Routes.SetChildStage(cb, toDone, 1)           -- stage 1 was COMPLETED at the top
Routes.SetChildReach(toDone, 10, 6, 2)
toDone.x, toDone.y, toDone.z = 900, 900, 50
local dev = Walk.Scan(900, 900, 50)
assert(#dev == 1 and dev[1].why == "unseen-blocked",
       "A SEEN SET FIRED AGAIN: completing stage 1 must put 1 in the ledger, or "
       .. "`if unseen` consults a stage nobody recorded")

-- ===== original lines 1350-1363 =====
-- fallback and stage 7 comes back (3,5,7,11); make it unconditional and the report
-- empties entirely. One number, two opposite faults - which is why it is worth
-- printing what it GOT rather than just failing.
local bad = Walk.Unrunnable(wid)
table.sort(bad)
assert(#bad == 3 and bad[1] == 3 and bad[2] == 5 and bad[3] == 11,
       "AN UNRUNNABLE STAGE WENT UNREPORTED: refusing it would be grading the "
       .. "author, but staying silent hides a route that cannot finish - got "
       .. table.concat(bad, ","))
Walk.Stop()
assert(not Walk.IsRunning(), "and the walk stops")


-- =====================================================================

-- ===== original lines 1455-1461 =====
-- ★★★ §91: THE WALK POINTS THE TRACKER, and ONE child can do both axes at once.
-- ⚠ The §85 block stopped the walk, so this restarts it: a stopped walk returns
-- nothing from Scan, which is correct and would otherwise read as a dead action.
assert(Walk.Start(wid), "the walk restarts for the action tests")
local tb = Routes.AddBeacon(wid, node)
tb.stage = 20
local hop1 = Routes.AddChildFromNode(wid, tb, node)

-- ===== original lines 1468-1487 =====
-- the same child also completes the stage: two axes, no coordination
Routes.SetChildRole(tb, hop1, "complete")

local tev = Walk.Scan(1200, 1200, 50)
assert(#tev == 1, "one event for one child")
assert(tev[1].acted == "supertrack",
       "THE ACTION DID NOT FIRE: detect and action are independent axes on one child")
assert(Walk.LastTarget() == hop2,
       "THE TRACKER WENT TO THE WRONG PLACE: the action points at its goTo TARGET, "
       .. "not at the child that fired")
assert(tev[1].why == "complete",
       "and the same child still satisfied the stage - that is the composition")

-- ⚠ A DANGLING TARGET IS A DEFINED STATE, reported rather than failed.
Routes.DeleteChild(tb, hop2)
Walk.Scan(9000, 9000, 50)
local dev = Walk.Scan(1200, 1200, 50)
assert(dev[1] and dev[1].acted == "target-gone",
       "A BROKEN LINK WAS SILENT: the hop stops redirecting, and that is worth saying")


-- ===== original lines 1548-1582 =====
-- OR ABOVE the index, never index+1: stages are labels, so 4.1 is ordinary and
-- arithmetic would skip an insertion the author made on purpose.
r2.stage = 4.1
local ramp, owner = Walk.OnRamp(rid, 2)
assert(ramp == way and owner == r2,
       "THE ADVANCE DID ARITHMETIC ON A LABEL: 4.1 is the next stage above 2, and "
       .. "index+1 would have skipped it")

-- ★ It points, and SAYS it pointed - an arrow that moves silently is the thing this
-- instrument exists not to do.
assert(Walk.Start(rid), "walk the on-ramp route")

-- ★ At the start the next stage is 1, which has no children - so it speaks for
-- itself, and the fallback is exercised by the ordinary path rather than in theory.
assert(Walk.PointAtOnRamp(rid, 0) == "on-ramp", "the advance directs")
assert(Walk.LastTarget() == r1, "a childless stage points at the beacon")

-- ★★ And past stage 1 it points at the FLAGGED CHILD's own position, not at its
-- anchor: move to X is move to ME.
assert(Walk.PointAtOnRamp(rid, 2) == "on-ramp", "the next stage directs too")
assert(Walk.LastTarget() == way,
       "THE TRACKER WENT TO THE ANCHOR: the on-ramp carries its OWN position, which "
       .. "is the whole reason it is declared rather than derived")

-- ⚠ AND NOTHING IS A REAL ANSWER. Past the last stage there is nowhere to point,
-- which is a state to report rather than a branch to guard.
assert(Walk.PointAtOnRamp(rid, 999) == "route-finished",
       "IT WENT QUIET PAST THE LAST STAGE: nothing is an ANSWER, not an absence - "
       .. "which is what keeps this a mechanism rather than a policy")
local past = Walk.OnRamp(rid, 999)
assert(past == nil, "past the last stage the route has nothing to say")
Walk.Stop()


-- =====================================================================

-- ===== original lines 1594-1646 =====
assert(Routes.AcceptanceOf(bare) == bare,
       "A BARE BEACON HAD NO ACCEPTANCE: §83 says the satisfier set is the children "
       .. "OR THE ANCHOR when it has none, and only half of that was built")
assert(#Walk.Unrunnable(bid) == 0,
       "A BARE BEACON WAS CALLED UNRUNNABLE: it ratchets when found, so reporting it "
       .. "was the report being wrong rather than the route")

-- ★★ AND IT ACTUALLY FIRES. The detector list gave it `child = nil` and the scan
-- skipped it, so §83's rule existed as prose and never as behaviour.
assert(Walk.Start(bid), "walk the bare route")
local bev = Walk.Scan(2000, 2000, 60)
assert(#bev == 1 and bev[1].why == "complete",
       "THE BARE BEACON NEVER FIRED: the anchor is its own detector when it has no "
       .. "children")
assert(Walk.Index() == 2, "and the stage ratcheted to stage+1")

-- ⚠ OFFLOADING IS PER-QUESTION. Give it a child that is only the ON-RAMP, and the
-- beacon keeps the ratchet - which is the stairs case: the way in is the top of the
-- lift, the ratchet is somewhere else entirely.
local lift = Routes.AddChildFromNode(bid, bare, node)
Routes.SetChildOnRamp(bare, lift, true)
assert(Routes.OnRampOf(bare) == lift, "the on-ramp offloads")
assert(Routes.AcceptanceOf(bare) == nil,
       "ONCE IT HAS CHILDREN THE ANCHOR STOPS BEING ITS OWN SATISFIER: the author "
       .. "offloaded the job, and not finishing it is exactly what the report names")
assert(#Walk.Unrunnable(bid) == 1, "and now it IS reported")
Walk.Stop()


-- =====================================================================
-- ★★★ §95: ONE START-AND-REPORT, for two ways in
-- =====================================================================

-- ★ The slash surface and the promoter's play both start a walk. Two copies of the
-- same three lines is §63's fault - two things that must agree with nothing to notice
-- when they stop - so the report lives in Walk and RETURNS its lines.
local lines = Walk.StartLines(wid)
assert(lines and #lines >= 1, "the report comes back as lines, not as chat")
assert(lines[1]:find("walk:"), "and it opens with the state")

-- ⚠ The unrunnable stages ride in the SAME report, so the button and the slash
-- cannot say different things about the same route.
local said = table.concat(lines, " | ")
assert(said:find("no acceptance on stage"),
       "THE REPORT LOST THE UNRUNNABLE STAGES: one call is the whole point - two "
       .. "copies would be two things that must agree")
Walk.Stop()

-- ⚠ A bad id fails with a REASON rather than a nil nobody can act on.
local none, err = Walk.StartLines("no-such-route")
assert(none == nil and err, "a route that does not exist says why")


