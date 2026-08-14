-- Offline smoke for COA_DungeonRun routes.lua + promoter.lua - §61's MINT.
--
-- What can be SILENTLY wrong here, and each one produces something that still
-- looks like a working promoter:
--
--   Inherit    copies a field it should not -> a beacon asserting facts about a
--              capture it no longer references, and nothing on screen says so
--   stage      derived from the node instead of the sequence -> route order that
--              looks right on the first route and collapses on the second
--   the mint   writes back to the run -> §29 broken, invisibly, at the one place
--              the whole architecture rests on
--   notes      folded into the route -> they export with it, which is a PRIVACY
--              fault dressed as a convenience
--
-- The pane itself is thin; the parts asserted here are the ones with teeth.

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
Routes.Init()

for _, leaked in ipairs({"PLACE", "tbl", "composeId", "notes", "creating", "refresh"}) do
    assert(_G[leaked] == nil, "LEAKED GLOBAL: " .. leaked)
end

-- =====================================================================
-- ★★ WHAT CARRIES OVER. The one rule: PLACE carries, EVENT does not.
--
-- A beacon is a statement about a SPOT. Copying `t`, `n` or `killedBy` would make
-- it assert things that were true of one capture and are not true of the place -
-- and since §61 DROPPED the back-reference, nothing downstream could ever tell
-- that those fields came from somewhere else.
-- =====================================================================
local node = {
    x = 100.5, y = 200.5, z = 12.25, mapID = 33,
    mapX = 0.42, mapY = 0.66, mapC = 2, mapZ = 5, floor = 6,
    -- everything below is a fact about the CAPTURE, not about the place
    t = 1786600000, gt = 55.5, kind = "start", n = 3, combat = true,
    dead = true, killedBy = { "Fenrus" }, ghost = true,
    zone = "Shadowfang Keep", subZone = "",
}

local got = Routes.Inherit(node)
-- ★ §25.2 rides in this loop: `z` is INHERITED AND NEVER COMPUTED. It is the field
-- with a teaching job - a beacon dragged later keeps the height it was born at, so
-- one floating at the wrong height is the design saying something rather than a bug.
for _, k in ipairs({ "x", "y", "z", "mapX", "mapY", "mapC", "mapZ", "mapID", "floor" }) do
    assert(got[k] == node[k], "PLACE MUST CARRY: " .. k)
end
for _, k in ipairs({ "t", "gt", "kind", "n", "combat", "dead", "killedBy", "ghost",
                     "zone", "subZone" }) do
    assert(got[k] == nil, "EVENT MUST NOT CARRY: " .. k .. " reached the beacon")
end

assert(Routes.Inherit(nil) == nil, "no node, nothing to inherit")

-- The pre-flight readout, which is what makes the borrow VISIBLE before commit.
assert(Routes.InheritSummary(nil):find("no node"), "it says when there is nothing")
local sum = Routes.InheritSummary(node)
assert(sum:find("12.3") and sum:find("floor 6"),
       "INHERITANCE INVISIBLE: the readout must show z and floor, got " .. sum)
assert(Routes.InheritSummary({ x = 1 }):find("cannot be placed"),
       "a node with no fraction is unplaceable and must SAY so")

-- =====================================================================
-- Routes - the family
-- =====================================================================
local id = Routes.Create("SFK speed", 33)
assert(id and Routes.Get(id), "created and gettable")
assert(Routes.Get(id).mapID == 33,
       "★ §60: a route is valid for a MAPID. Not a difficulty - one route holds "
       .. "from mythic to mythic+5")
assert(Routes.Get(id).name == "SFK speed", "the name is stored as typed")
assert(id:find("SFK speed", 1, true), "the id is name-n, for legibility")

-- Renaming moves a LABEL and no handle, because id and name were separated at
-- creation - exactly as a run's are.
Routes.Rename(id, "SFK speed v2")
assert(Routes.Get(id).name == "SFK speed v2" and Routes.Get(id), "rename keeps the handle")

-- The SAME name deliberately: uniqueness must come from the counter alone, exactly
-- as a run's does. Two routes with one name is the ordinary case (v1 and a tweak).
local id2 = Routes.Create("SFK speed", 33)
assert(id2 ~= id, "IDS COLLIDE: two routes may share a name; the counter makes them unique")

-- ★ The counter is SHARED with runs, so a route and a run can never collide on a
-- handle even though they live in different tables.
local runId = Store.Open("a run")
assert(runId ~= id and runId ~= id2, "run and route handles are drawn from one counter")

-- =====================================================================
-- ★★ THE MINT - and the assertion the whole architecture rests on
-- =====================================================================
local b = Routes.AddBeacon(id, node)
assert(b, "a beacon was minted")
assert(b.kind == "beacon", "it knows what it is")
assert(b.mapX == 0.42 and b.z == 12.25, "carrying the node's PLACE")

-- ★★ §29: PROMOTION COPIES. If the mint touched the node, curation's "edits the
-- view, never the capture" would be broken at the one point that matters, and
-- nothing on screen would say so.
assert(node.kind == "start" and node.n == 3, "THE NODE IS UNTOUCHED - §29 COPIES")
assert(b ~= node, "and the beacon is a different table, not an alias")
node.mapX = 0.99
assert(b.mapX == 0.42, "★ NOT A REFERENCE: editing the node cannot move the beacon")
node.mapX = 0.42

-- ★ §56: THE SEQUENCE INTEGER RIDES FREE. Order is the author's, assigned at mint -
-- never derived from the node, from time, or from position.
assert(b.stage == 1,
       "STAGE IS THE ROUTE'S: the first beacon is stage 1, not the node's pull index")
local b2 = Routes.AddBeacon(id, node)
assert(b2.stage == 2, "STAGE MUST COUNT: the sequence is the route's, not the node's")
assert(Routes.AddBeacon(id2, node).stage == 1,
       "STAGE IS PER ROUTE: a second route starts at 1, or numbering leaks between them")
assert(Routes.Count(id) == 2 and Routes.Count(id2) == 1, "counted per route")

-- Refusals, and both are facts about the DATA rather than rules.
assert(Routes.AddBeacon(id, nil) == nil, "no node, no beacon")
assert(Routes.AddBeacon("nope", node) == nil, "no route, no beacon")
assert(Routes.AddBeacon(id, { x = 1, y = 2 }) == nil,
       "UNPLACEABLE STORED: a node with no map fraction must be refused, not kept as a ghost")
assert(Routes.Count(id) == 2, "and a refusal changes nothing")

Routes.DeleteBeacon(id, 1)
assert(Routes.Count(id) == 1, "a beacon can be removed")
assert(Routes.Get(id).beacons[1].stage == 2,
       "★ and the survivors KEEP their numbers - renumbering would shift the gate "
       .. "keys under any route in flight (§61's open question, answered by not moving)")

-- =====================================================================
-- ★★ PERSONAL NOTES ARE A SEPARATE PLANE (§60), and this is a PRIVACY property
-- =====================================================================
assert(Routes.GetNotes(33) == nil,
       "★ READING MUST NOT CREATE: the map asks constantly, and a plane minted by "
       .. "looking would put an empty table in the save file for every map opened")

local n1 = Routes.AddNote(33, node)
assert(n1 and n1.kind == "note", "a note was minted")
assert(n1.mapX == 0.42, "carrying the same PLACE")
assert(n1.text == "", "★ CREATE THEN EDIT: minted empty, the meaning waits")
assert(Routes.NoteCount(33) == 1 and Routes.NoteCount(34) == 0, "one plane per dungeon")

-- ★★ The one that matters: a note must NEVER be inside a route. It is yours, it
-- needs no route to exist, and if it travelled with an export you would be
-- publishing your own annotations without being asked.
for _, bb in ipairs(Routes.Get(id).beacons) do
    assert(bb.kind ~= "note", "A NOTE REACHED A ROUTE: personal notes must not export")
end
assert(Routes.Get(id).notes == nil, "and a route has no note list at all")
assert(COA_DungeonRunDB.notes and COA_DungeonRunDB.routes,
       "the two live in separate tables")
assert(COA_DungeonRunDB.runs[runId], "and runs are a third, untouched by either")

-- A note needs no route: the plane took one with none loaded, which is the whole
-- reason the button sits ABOVE the divider (§61).
assert(Routes.AddNote(33, node), "notes never needed a route")

-- =====================================================================
-- §36's ordering, third surface, same shape - location SORTS, never picks
-- =====================================================================
Routes.Create("elsewhere", 999)
local list = Routes.List(33)
assert(#list == 3, "every route is offered")
assert(list[1].here and list[2].here,
       "LOCATION MUST SORT: this dungeon's routes come first")
assert(not list[#list].here, "and the other dungeon's route falls to the end")
local anywhere = Routes.List(nil)
assert(#anywhere == 3, "and standing nowhere still lists them all")
for _, e in ipairs(anywhere) do
    assert(not e.here, "with nothing marked local, because nothing is")
end

-- =====================================================================
-- ★ DR-21: a schema we do not know locks the ROUTES too, not just the runs.
-- Without this the refusal is half-applied and the newer file gets written to.
-- =====================================================================
COA_DungeonRunDB = { schemaVersion = 99, runs = {}, routes = {} }
Store.locked = nil
assert(not Store.Load(), "a future schema refuses")
assert(Store.RouteTable() == nil, "ROUTES ESCAPED THE LOCK: DR-21 must cover them")
assert(Store.NoteTable() == nil, "and so must the note planes")
assert(Routes.Create("x", 1) == nil, "so nothing can be minted into a locked db")
assert(Routes.AddNote(1, node) == nil, "nor a note")

print("smoke_dungeonrunpromoter: OK")
