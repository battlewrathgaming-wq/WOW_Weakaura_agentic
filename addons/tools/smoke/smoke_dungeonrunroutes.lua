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
local r, up, down = Routes.SetChildReach(child, 8, 2.5, 2.5)
assert(r == 8 and up == 2.5 and down == 2.5, "SetChildReach did not store what it was given")
assert(child.radius == 8, "reach did not land on the child")

-- A1.2's ground: a childless beacon is its OWN acceptance today, and that is the
-- half that already works. What it has no way to carry is a REACH.
assert(Routes.AcceptanceOf(lone) == lone, "a childless beacon should satisfy itself")
assert(Routes.AcceptanceOf(parent) == nil, "a beacon with an unflagged child accepts nothing")

-- =====================================================================
-- ★ A1 - G2, reach on a childless beacon. FILLED §299.
-- =====================================================================

-- A1.1  the store, and the read that composes rather than re-decides.
assert(type(Routes.SetBeaconReach) == "function", "SetBeaconReach missing")
assert(type(Routes.ReachOf) == "function", "ReachOf missing")

local br, bu, bd = Routes.SetBeaconReach(lone, 12, 2.5, 2.5)
assert(br == 12 and bu == 2.5 and bd == 2.5, "SetBeaconReach did not store what it was given")

-- Handed a BEACON it resolves through AcceptanceOf; handed a point it reads that point.
local r1 = Routes.ReachOf(lone)
assert(r1 == 12, "ReachOf on a childless beacon should be the beacon's own radius")
assert(Routes.ReachOf(child) == 8, "ReachOf on a child should be the child's")

-- ...so a flagged child WINS over its parent's, because AcceptanceOf picks the child.
Routes.SetChildRole(parent, child, "complete")
assert(Routes.AcceptanceOf(parent) == child, "a `complete` child should be the acceptance")
Routes.SetBeaconReach(parent, 99)
assert(Routes.ReachOf(parent) == 8,
       "the acceptance CHILD's reach must win over the beacon's - ReachOf must not re-decide")

-- ⚠ AND THE THIRD STATE SURVIVES: children present, none flagged, nothing accepts.
-- ReachOf must return nothing rather than falling back to the beacon's 99 - that
-- fallback would quietly make a half-authored stage runnable.
local half = assert(Routes.AddBeacon(routeId, node, 3), "AddBeacon returned nil")
local halfKid = assert(Routes.AddChildFromNode(routeId, half, node), "AddChild returned nil")
Routes.SetBeaconReach(half, 77)
assert(Routes.AcceptanceOf(half) == nil, "an unflagged child means nothing accepts")
assert(Routes.ReachOf(half) == nil,
       "ReachOf must NOT fall back to the beacon when the author offloaded and did not finish")

-- A1.2  the childless beacon is runnable: it accepts itself AND has a reach.
assert(Routes.AcceptanceOf(lone) == lone and Routes.ReachOf(lone) ~= nil,
       "a childless beacon with a radius must be RUNNABLE")

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
local _, lu, ld = Routes.ReachOf(lone)
assert(lu == 2.5 and ld == 2.5, "the band must come back as stored")

-- ⚠ NO DEFAULT IS INVENTED. R2 is unruled; a beacon nobody gave a band comes back
-- nil, not 2.5. When R2 rules a default this assertion is the one that changes, and
-- it changes in ONE place.
local bare = assert(Routes.AddBeacon(routeId, node, 4), "AddBeacon returned nil")
local nr, nu, nd = Routes.ReachOf(bare)
assert(nr == nil and nu == nil and nd == nil,
       "an unset reach must be nil - a returned default is indistinguishable from a typed one")

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

-- ⚠⚠ A2.4 IS NOT COVERED AND ITS ROW STAYS OPEN. It asks for TWO DOORS to one field:
-- the child's own pane (built, §312) and the PARENT'S management surface - reorder a
-- chain, insert 3.1, take a satellite out of the line, from the beacon's pane
-- (`driver_programmatic_model.md` §1). That surface does not exist, so there is no
-- second door to assert writes the same field.
-- ★ The row was briefly flipped to covered while building this block. It was not
-- asserted anywhere - a green with no evidence behind it, which is the exact thing
-- the roster was written to make impossible. Put back.


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

-- A3.1  the axis exists, is declared, and is checked.
assert(type(Routes.SENSES) == "table" and #Routes.SENSES > 0, "SENSES must be published")
assert(Routes.SetChildSense(bossBeacon, bossKid, "bossKilled") == "bossKilled",
       "a listed sense must store")
assert(Routes.SetChildSense(bossBeacon, bossKid, "whenIFeelLikeIt") == "bossKilled",
       "an UNLISTED sense must be refused and the old value kept - a typo cannot reach "
       .. "the store, which is what DECLARED means (§305)")

-- ⚠ `reachHere` is not a settable value: setting it CLEARS, it does not store.
Routes.SetChildSense(bossBeacon, bossKid, "reachHere")
assert(bossKid.sense == nil,
       "choosing the default must CLEAR, never store - a field whose only meaning is "
       .. "'I did not choose' is the thing §79 avoided")
Routes.SetChildSense(bossBeacon, bossKid, "bossKilled")

-- A3.1  the name is PICKED from the run's own record, never typed.
local offered = Store.BossNames(runId)
assert(#offered > 0, "the fixture run must carry boss names, or A3.1 tests nothing")
assert(Routes.SetChildBoss(bossBeacon, bossKid, "Taragaman the Typo", offered) == nil,
       "A NAME NOT ON OFFER WAS ACCEPTED: the offer is the whole guard - 'picked, never "
       .. "typed' is a property of the data path, not of the pane being careful")
assert(Routes.SetChildBoss(bossBeacon, bossKid, offered[1], offered) == offered[1],
       "a name from the run's own record must store")

-- ⚠ AND THE FOLD IS DISTINCT. DR-31 records EVERY firing on purpose - a boss engaged
-- twice is two records - so the picker must not offer the same name twice.
local dupes = 0
for i = 2, #offered do
    if offered[i] == offered[i - 1] then dupes = dupes + 1 end
end
assert(dupes == 0, "Store.BossNames must fold to the DISTINCT set - DR-31 stores every "
       .. "firing deliberately and the fold is what makes that safe to offer")

-- A3.2  two senses, and both are on the axis.
local hasEngaged, hasKilled = false, false
for _, s in ipairs(Routes.SENSES) do
    if s == "bossEngaged" then hasEngaged = true end
    if s == "bossKilled" then hasKilled = true end
end
assert(hasEngaged and hasKilled, "the model offers TWO senses on a boss child (§2c): the "
       .. "engage ARMS and the kill SATISFIES - one without the other is half the door")

-- ★★★ A3.3  NO REFUSAL ANYWHERE - the signature is the guard.
Routes.SetChildBoss(bossBeacon, bossKid, nil)
assert(bossKid.sense == "bossKilled", "clearing the NAME must not clear the SENSE")
assert(Routes.ArmsWith(bossKid) == nil,
       "A NAMELESS BOSS CHILD OFFERED SOMETHING TO ARM WITH: the driver's call takes the "
       .. "name as its argument, so with no name there is nothing to pass and NOTHING "
       .. "ARMS. The unfiltered listener is not refused - it cannot be expressed")
Routes.SetChildBoss(bossBeacon, bossKid, offered[1], offered)
assert(Routes.ArmsWith(bossKid) == offered[1],
       "and a NAMED one arms with exactly that one dest name")

-- ⚠ and a child that is not a boss child arms with nothing at all, whatever it carries.
local plainKid = assert(Routes.AddChildFromNode(routeId, bossBeacon, node), "AddChild nil")
plainKid.boss = "Jergosh the Invoker"          -- a stray field, however it got there
assert(Routes.ArmsWith(plainKid) == nil,
       "A NON-BOSS CHILD ARMED A LISTENER: the SENSE decides whether anything arms, not "
       .. "the presence of a name - otherwise a stale field becomes a live listener")

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
local SLOTS = {
    { "A1.1", "SetBeaconReach stores; ReachOf returns child-else-beacon", false },
    { "A1.2", "a childless beacon with a radius is RUNNABLE", false },
    { "A1.3", "the beacon's z is still the read's; band is a tolerance over it", false },
    { "A2.1", "sparse child ordinal; insertion renumbers NOTHING", false },
    { "A2.2", "4.1:3 resolves to exactly one child, route-wide unique", false },
    { "A2.3", "two children on one ordinal is TOLD, never refused", false },
    { "A2.4", "parent surface and child pane write the SAME field - ONE DOOR BUILT", true },
    { "A3.1", "boss axis (NOT `kind` - taken, see above); picker fed ONLY from r.bosses", false },
    { "A3.2", "two senses: boss engaged / boss killed", false },
    { "A3.3", "a nameless boss child arms NOTHING and is told", false },
    { "A3.4", "no set, count or grouping is stored or shown", false },
    { "A4.1", "a note resolves to exactly ONE string at runtime", true },
    { "A4.2", "referenced-or-owned, whichever R1 rules", true },
    { "A4.3", "a child with no note renders nothing", true },
    { "A5.1", "a missing adaptor row PASSES THROUGH the code term", true },
    { "A5.2", "every ROLES/SHAPES/ACTIONS value resolves or passes through", true },
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
