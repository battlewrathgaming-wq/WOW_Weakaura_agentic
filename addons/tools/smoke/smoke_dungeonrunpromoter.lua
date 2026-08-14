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
-- ★ Battlewrath: *"Starting a route is like starting a run. Just enter the name.
-- Collection follows."* It is OPENED, not minted from something.
assert(Routes.Count(id) == 0,
       "A NEW ROUTE STARTS EMPTY - collection follows, it is not seeded")
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
-- ★★ OFFERED ONLY FOR THE MAP THAT IS LOADED - a FILTER, not §36's sort.
--
-- §36 says LOCATION sorts and never picks, because where your body happens to be is
-- not a choice about what to work on. The loaded map IS that choice. Offering
-- another dungeon's route is not helpfulness - it is offering to draw beacons onto
-- art they were never placed against, and placed by fraction they would look like
-- a plausible route rather than like an error.
-- =====================================================================
Routes.Create("elsewhere", 999)
local list = Routes.List(33)
assert(#list == 2, "only this map's routes, got " .. #list)
for _, e in ipairs(list) do
    assert(not e.name:find("elsewhere"),
           "WRONG MAP OFFERED: a route for another dungeon must not be listed")
end
assert(#Routes.List(999) == 1, "and the other map offers its own")
assert(#Routes.List(nil) == 0,
       "NO MAP, NO OFFER: nothing loaded means the authoring surface has nothing "
       .. "to work on, and it says so rather than listing everything")

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

-- =====================================================================
-- ★★ THE PANE, DRIVEN END TO END - and this is the block that was missing.
--
-- Everything above tests routes.lua, which was correct. The LIVE fault was one
-- line in promoter.lua: it never registered for the selection, so refresh() ran
-- once at Init with nothing selected and both buttons latched DISABLED forever.
-- Battlewrath saw it as "the wiring into record creation isn't active" and "note
-- is greyed regardless of state" - two symptoms, one missing line.
--
-- ★ §63 ADDED MANY-LISTENER SUPPORT TO map.lua FOR THIS PANE AND THEN DID NOT USE
-- IT. The smoke asserted the map could SERVE two listeners and never that the
-- promoter WAS one - a guard whose failure case the fixtures could not reach,
-- which is not a safe guard, it is an untested one. Same law that has now caught
-- this class five times.
-- =====================================================================
COA_DungeonRunDB = nil
Store.locked = nil
assert(Store.Load(), "back to a fresh db for the pane")

-- Frame stub: the methods the pane actually uses are real, anything else no-ops so
-- a failure says something about the code rather than about chrome. Enable/Disable
-- are REAL and recorded, because "is the button pressable" is the entire question.
-- The cursor and the canvas's screen box, so the drag arithmetic has real inputs
-- rather than a mocked result. GetLeft/GetTop/GetEffectiveScale are what map.lua
-- reads live, which is how zoom and UI scale come free.
cursorX, cursorY = 0, 0
function GetCursorPosition() return cursorX, cursorY end
-- Settable so the "geometry unreadable" path is REACHABLE. A guard whose failure
-- case the fixtures cannot reach is untested, not safe.
canvasScale = 1

local H = dofile([[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\tools\smoke\harness.lua]])

local function stub()
    local o = {}
    local mt = { __index = function(_, k)
        if type(k) == "string" and k:sub(1, 1) == "_" then return nil end
        return function() end
    end }
    function o:SetScript(k, fn) self[k] = fn end
    function o:Show() self._shown = true end
    function o:Hide() self._shown = false end
    function o:IsShown() return self._shown end
    function o:SetText(t) self._text = t end
    function o:GetText() return self._text end
    function o:Enable() self._on = true end
    function o:Disable() self._on = false end
    function o:IsEnabled() return self._on end
    function o:CreateTexture() return stub() end
    function o:CreateFontString() return stub() end
    function o:GetFrameLevel() return self._level or 1 end
    function o:SetFrameLevel(n) self._level = n end
    function o:SetChecked(v) self._checked = v and true or false end
    function o:GetChecked() return self._checked end
    function o:SetTexture(t) self._tex = t; self._coord = nil end
    function o:SetTexCoord(...) self._coord = { ... } end
    function o:GetPoint() return "CENTER", nil, "CENTER", 0, 0 end
    function o:GetEffectiveScale() return canvasScale end
    function o:GetLeft() return 0 end
    function o:GetTop() return 668 end
    -- ★ CLIENT FIDELITY LAST, so it overrides the plain setters above.
    H.Fidelity(o)
    return setmetatable(o, mt)
end

local made = {}
function CreateFrame(kind, name, parent, tmpl)
    local o = stub()
    o._name, o._tmpl = name, tmpl
    made[#made + 1] = o
    return o
end

-- The dropdown API, reduced to what the pane calls. `AddButton` RECORDS, so the
-- menu's contents can be asserted - §61 put `+ create new` in the list rather than
-- beside it, and that is only true if it is actually in the list.
local MENU = {}
function UIDropDownMenu_CreateInfo() return {} end
function UIDropDownMenu_AddButton(info) MENU[#MENU + 1] = info end
function UIDropDownMenu_Initialize(dd, fn) dd._init = fn end
function UIDropDownMenu_SetWidth() end
function UIDropDownMenu_JustifyText() end
function UIDropDownMenu_SetText(dd, t) dd._text = t end
StaticPopupDialogs = {}
function StaticPopup_Show() end

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
end
-- ★ What is ACTUALLY ON SCREEN. Map.Painted is a QUERY over the loaded slots and
-- answers the same whether or not anything repainted - so asserting against it
-- proves the record, never the picture. The dots are the picture.
--
-- ★ rawget, because the stub answers ANY non-underscore key with a no-op function -
-- so `o.point` is truthy on every frame ever made and the count silently becomes
-- "how many frames exist". The map smoke documents the same trap; it cost a wrong
-- green here before the assertion caught itself.
local function drawn()
    local n = 0
    for _, o in ipairs(made) do
        if rawget(o, "point") and o._shown then n = n + 1 end
    end
    return n
end

local noteBtn, createBtn = find("Personal note"), find("Create beacon")
assert(noteBtn and createBtn, "both mint buttons exist")

-- ★ Nothing selected: both refuse, and that is a fact about the DATA (nothing to
-- copy from) rather than a rule.
assert(noteBtn:IsEnabled() == false, "no node, no note")
assert(createBtn:IsEnabled() == false, "no node, no beacon")

-- ★★ THE ONE THAT FAILED LIVE. Selecting a node must reach this pane - which only
-- happens if it REGISTERED. Nothing else here can produce the effect.
local runId = Store.Open("SFK")
Store.AddLeg(runId, { x = 1, y = 2, z = 9.5, mapID = 33, mapX = 0.3, mapY = 0.4, floor = 6,
                      t = 1786600000, gt = 10 })
Map.Show(runId)
Map.Select(Store.Get(runId).legs[1])
assert(noteBtn:IsEnabled() == true,
       "NOT REGISTERED FOR SELECTION: the pane never heard the click, so every "
       .. "control latches disabled and the whole surface looks dead")

-- A personal note needs NO route, which is why it sits above the divider (§61).
assert(Map.LoadedId("route") == nil, "no route is loaded")
assert(createBtn:IsEnabled() == false, "and a beacon still has nowhere to go")
local beforeNote = drawn()
noteBtn:OnClick()
assert(Routes.NoteCount(33) == 1, "THE NOTE WAS NOT RECORDED")
assert(drawn() == beforeNote + 1,
       "MINTED BUT NOT DRAWN: you must SEE what you just made, not take it on faith")

-- ★ THE MENU. §61: `+ create new` is an ENTRY, so the mode is a SELECTION rather
-- than something inferred from how you typed. `- no route -` is a real entry for
-- the same reason unloading must be as reachable as loading (§36).
MENU = {}
made[1]._init = made[1]._init      -- keep the stub honest about what we call
NS.Map = Map
-- By NAME, not "the last one with an _init": §74's driver has a dropdown too, and
-- "the last one" silently became a different pane's control the moment one existed.
local dd
for _, o in ipairs(made) do if o._name == "COA_DungeonRunRouteLoad" then dd = o end end
assert(dd and rawget(dd, "_init"), "the promoter's dropdown was initialised")
dd._init()
assert(MENU[1].text == "+ create new", "CREATE IS NOT AN ENTRY: it must lead the list")
assert(MENU[2].text == "- no route -", "and unloading is a real entry too")

-- ★★ STARTING A ROUTE IS LIKE STARTING A RUN - name it, and collection follows.
-- §63 minted the route as a SIDE EFFECT of placing the first beacon, which
-- compounded two choices into one act and made a selected node a precondition for
-- having a route at all. Battlewrath, on the first deploy.
MENU[1].func()                                   -- `+ create new`
local nameBox
for _, o in ipairs(made) do
    if o._name == "COA_DungeonRunRouteName" then nameBox = o end
end
assert(nameBox, "the name box exists")

Map.Select(nil)
Promoter.Refresh()
assert(createBtn:GetText() == "Create route",
       "THE VERB MUST FOLLOW THE MODE, got " .. tostring(createBtn:GetText()))
assert(createBtn:IsEnabled() == true,
       "A ROUTE NEEDS NO NODE: with nothing selected it must still be startable")

-- ★ But it DOES need a map. A route belongs to a dungeon, so with nothing loaded
-- there is nothing to create it for - a fact about the data, like every other
-- refusal on this pane.
Map.Show(nil)
Promoter.Refresh()
assert(createBtn:IsEnabled() == false,
       "NO MAP, NO ROUTE: with nothing loaded there is no dungeon to create it for")
Map.Show(runId)
Promoter.Refresh()

nameBox:SetText("SFK speed")
createBtn:OnClick()
local rid = Map.LoadedId("route")
assert(rid, "ROUTE NOT STARTED: creating one must leave it loaded")
assert(Routes.Count(rid) == 0, "AND IT STARTS EMPTY - collection follows")
assert(createBtn:GetText() == "Create beacon", "and the verb flips back")
assert(createBtn:IsEnabled() == false, "which needs a node again")

-- Now collect one.
Map.Select(Store.Get(runId).legs[1])
assert(createBtn:IsEnabled() == true, "with a node and a route, minting is available")
local beforeBeacon = drawn()
createBtn:OnClick()
assert(Routes.Count(rid) == 1, "THE BEACON WAS NOT RECORDED")
assert(drawn() == beforeBeacon + 1,
       "MINT DID NOT WIRE: the new beacon must be on the map, not just in the table")
assert(Routes.Get(rid).beacons[1].stage == 1, "and it is stage 1")
assert(Routes.Get(rid).beacons[1].z == 9.5, "carrying the node's z, inherited (§25.2)")

-- ★ And it is ON THE MAP, both layers at once - which is what §62's second slot
-- was for and the only proof the two halves are actually joined.
assert(drawn() == 3, "run leg + beacon + personal note all draw, got " .. drawn())

-- =====================================================================
-- ★★ §68: THE DRAG, END TO END - grab a beacon, move it, and check what changed
-- AND what did not.
-- =====================================================================
local beacon = Routes.Get(rid).beacons[1]
local originX, originY, originZ = beacon.mapX, beacon.mapY, beacon.z
local originWX, originWY = beacon.x, beacon.y
local originStage = beacon.stage

local dot
for _, o in ipairs(made) do
    if rawget(o, "point") == beacon then dot = o end
end
assert(dot, "the beacon has a dot on the map")

-- ★★ §69: THE ARM IS THE OBJECT, NOT A MODE. §68 shipped every promoted object
-- grabbable all the time, so any press near one risked moving it.
assert(Map.BeginDrag(dot) == false,
       "UNARMED OBJECT MOVED: promoted is not the same as ASKED to be moved")
assert(Map.Dragging() == nil, "and nothing is in flight")

-- Right-click routes to the editor, which is where the chip lives.
local heardEdit
Map.AddOnEdit(function(p) heardEdit = p end)
dot.OnClick(dot, "RightButton")
assert(heardEdit == beacon,
       "EDIT NOT FIRED: right click must route to the editor - testing OpenEditor "
       .. "directly would prove the function and not the gesture")
assert(Map.OpenEditor(beacon) == true, "and the entry point answers too")
assert(Map.Selected() == beacon, "and opening it selects the thing being edited")
assert(Map.OpenEditor(Store.Get(runId).legs[1]) == false,
       "CAPTURE HAS AN EDITOR: a leg is evidence, there is nothing to edit")

-- ★★ §71: THE CHIP LIVES WITH THE OBJECT, not on the creation pane. §69 put it on
-- the promoter and said the fields would follow, which made the spawner double as
-- an editor - the conflation he ruled out.
local chip
for _, o in ipairs(made) do
    if o._name == "COA_DungeonRunObjectMove" then chip = o end
end
assert(chip, "CHIP NOT ON THE OBJECT PANE: edit controls belong with the object")
for _, o in ipairs(made) do
    assert(o._name ~= "COA_DungeonRunMoveChip",
           "THE PROMOTER STILL EDITS: it mints and hands off, it does not hold "
           .. "an object's controls")
end
Object.Refresh()
assert(chip:IsShown(), "CHIP HIDDEN: it must appear for the object being edited")
assert(chip:GetChecked() == false, "and it starts locked")

-- The chip arms THIS object.
chip:SetChecked(true)
chip.OnClick(chip)
assert(Map.MoveArmed() == beacon, "CHIP DID NOT ARM")

-- ★ Arming is exclusive by construction: one object, so arming another disarms
-- the first without anything having to remember to.
local other = Routes.AddBeacon(rid, Store.Get(runId).legs[1])
Map.SetMoveArmed(other)
assert(Map.MoveArmed() == other, "the other is armed")
Map.SetMoveArmed(beacon)
assert(Map.MoveArmed() == beacon, "ARM IS NOT EXCLUSIVE: two objects cannot be armed")
Routes.DeleteBeacon(rid, other.stage)
Map.Load("route", rid)
Map.SetMoveArmed(beacon)

local announced = 0
Map.AddOnSelect(function() announced = announced + 1 end)
assert(Map.BeginDrag(dot) == true, "a beacon can be grabbed")
assert(Map.Dragging() == beacon, "and it is what is in flight")
assert(announced == 0,
       "REPOINTED MID-GRAB: a grab announced a selection, which means it repainted "
       .. "- and paint() hides every dot and re-points them from the pool")

-- ★★ NOTHING MAY REPAINT DURING A GRAB. BeginDrag used to select the point, which
-- repaints - and paint() hides every dot and re-points them from the pool, so the
-- frame you grabbed stops being the thing you grabbed. The client's drag then has
-- nothing to stop on: the object stays glued to the cursor. Caught live.
assert(rawget(dot, "point") == beacon,
       "REPOINTED MID-GRAB: the dot you grabbed must still hold the object you "
       .. "grabbed, or the drop has nothing to land on")
assert(dot._shown ~= false, "and it must still be shown")

-- ★ A CLICK DROPS IT. OnDragStop is the client's own end-of-gesture and stays;
-- this is the answer to a press that never became one, and to a drag the UI
-- interrupted - which is what stranded it on the cursor.
local canvasFrame
for _, o in ipairs(made) do
    if rawget(o, "OnMouseDown") then canvasFrame = o end
end
assert(canvasFrame, "THE CANVAS TAKES NO CLICK: there is no way to drop by clicking")
canvasFrame.OnMouseDown()
assert(Map.Dragging() == nil, "CLICK DID NOT DROP: the object stays on the cursor")
assert(beacon.atX,
       "THE PLACEMENT WAS NOT WRITTEN: a click-drop must commit like any other")
-- ★ And the canvas goes back to click-through. Left listening, it would swallow
-- every press on empty map for the rest of the session.
assert(rawget(canvasFrame, "OnMouseDown") == nil,
       "THE CANVAS TAKES NO CLICK - after a drop it must stop listening, or it eats "
       .. "every press on the map from here on")

-- Re-grabbed for the assertions below, which walk the drop itself. Cleared
-- DIRECTLY, not through Unplace: routing a fixture through the function another
-- guard owns makes this test fail for that guard's reason. Second time tonight.
beacon.atX, beacon.atY, beacon.atWorldX, beacon.atWorldY = nil, nil, nil, nil
Map.BeginDrag(dot)

-- ★★ A DRAG MOVES PIXELS; THE DROP WRITES THE RECORD. Running Place on every
-- frame turned one gesture into sixty writes a second to a saved-variables object,
-- each with its own calibration lookup. It also meant an interrupted drag left the
-- record half-committed wherever the cursor happened to be.
--
-- The stub's canvas sits at left 0, top 668 with scale 1, so this is the middle.
cursorX, cursorY = 501, 334
-- The map frame by name rather than a new accessor: exposing internals so a test
-- can reach them makes the addon's API a record of what we struggled to test.
local mapFrame
for _, o in ipairs(made) do if o._name == "COA_DungeonRunMap" then mapFrame = o end end
assert(mapFrame and rawget(mapFrame, "OnUpdate"),
       "THE DRAG INSTALLED NO OnUpdate: nothing would follow the cursor")
mapFrame.OnUpdate()                          -- one frame of the drag
assert(beacon.atX == nil,
       "WRITTEN MID-DRAG: the record must not move until the drop - an interrupted "
       .. "gesture has to leave it exactly as it was")

Map.EndDrag()
assert(Map.Dragging() == nil, "the drag ends")

assert(beacon.atX and beacon.atY, "THE PLACEMENT WAS NOT WRITTEN")
assert(math.abs(beacon.atX - 0.5) < 0.01, "and it is where the cursor was, got " .. beacon.atX)

-- ★★ THE ORIGIN SURVIVES. Overwriting it would destroy the note case - a note
-- dragged off the route is placed for its RADIUS, and the original is the only
-- record of where the thing actually happened.
assert(beacon.mapX == originX and beacon.mapY == originY,
       "ORIGIN OVERWRITTEN: keep original, add new - the source projection walk "
       .. "has nothing to walk to otherwise")
assert(beacon.x == originWX and beacon.y == originWY, "and its world origin too")

-- ★ z IS NOT TOUCHED (§25.2, §67.1). It is what lets a beacon sit on top of a wall;
-- recompute it and the beacon drops to the floor that wall belongs to, which is
-- precisely not where you need to be standing.
assert(beacon.z == originZ, "Z WAS RECOMPUTED: it is inherited, never computed")

-- ★ And the SEQUENCE is not touched. Order is authored (§56); moving a beacon in
-- space must never re-sort the route.
assert(beacon.stage == originStage, "STAGE MOVED: position is not sequence")

-- ★ The world pair resolves through §65's calibration when it can, and is ABSENT
-- when it cannot - never guessed. This fixture's run has no spread, so it declines,
-- which is the case worth asserting: an uncalibrated map is not a reason to invent
-- a world position.
assert(beacon.atWorldX == nil,
       "GUESSED A WORLD POSITION: with no calibration the pair must be absent")

-- ★ The same chip press LOCKS it - his design, one control swapping between move
-- and place. Locked, the object is exactly as immovable as it was before arming.
Map.SetMoveArmed(nil)
assert(Map.BeginDrag(dot) == false,
       "LOCK DID NOT HOLD: the second chip press must make it immovable again")

-- ★ NO VALID FRACTION, NO WRITE. If the geometry cannot be read the drop must
-- leave the record alone rather than commit whatever fell out of the arithmetic -
-- a zero scale is a divide, not a position.
-- Cleared directly rather than through Unplace: this test is about the WRITE
-- guard, and routing it through the function another guard owns makes one test
-- fail for the other's reason.
beacon.atX, beacon.atY, beacon.atWorldX, beacon.atWorldY = nil, nil, nil, nil
Map.SetMoveArmed(beacon)          -- or BeginDrag refuses and this passes for free
canvasScale = 0
Map.BeginDrag(dot)
Map.EndDrag()
canvasScale = 1
assert(beacon.atX == nil,
       "WROTE WITHOUT A POSITION: an unreadable canvas must commit nothing")

-- A capture point cannot be grabbed at all.
local legDot
for _, o in ipairs(made) do
    local pt = rawget(o, "point")
    if pt and pt.kind == nil and pt.mapX then legDot = o end
end
if legDot then
    assert(Map.BeginDrag(legDot) == false,
           "CAPTURE IS DRAGGABLE: a leg is evidence and no gesture may move it")
    assert(Map.Dragging() == nil, "and nothing is in flight")
end

-- Putting it back is a DELETION, not an inverse - the origin was never overwritten.
--
-- Placed again first: the no-position test above left the beacon clear, and a guard
-- run against a beacon with nothing to unplace cannot reach its own failure case.
-- Re-armed: the lock test above disarmed it, and a drag needs the arm.
cursorX, cursorY = 600, 200
Map.SetMoveArmed(beacon)
Map.BeginDrag(dot)
Map.EndDrag()
assert(beacon.atX, "placed, so there is something to undo")

Routes.Unplace(beacon)
assert(beacon.atX == nil and beacon.atWorldX == nil,
       "UNPLACE DID NOT RESTORE: the placement fields must all clear")
local px, py, placed = Routes.PositionOf(beacon)
assert(px == originX and py == originY and placed == false,
       "UNPLACE DID NOT RESTORE: the origin was there the whole time")

-- =====================================================================
-- ★★ §71: THE OBJECT'S OWN PANE - self-contained editing.
-- =====================================================================
-- It holds no object of its own: the map's selection IS the subject, so it can
-- never describe something the map is not showing.
Map.Select(nil)
Object.Refresh()
local objName
for _, o in ipairs(made) do
    if o._name == "COA_DungeonRunObjectName" then objName = o end
end
assert(objName, "the name field exists")
assert(objName._shown == false,
       "PANE KEPT ITS OWN SUBJECT: with nothing selected there is nothing to edit")

-- A capture point is not editable, so the pane refuses it the same way.
Map.Select(Store.Get(runId).legs[1])
Object.Refresh()
assert(objName._shown == false,
       "CAPTURE IS EDITABLE: a leg is evidence - DR-9 - and has no edit surface")

-- ★ Naming is IN-FIELD here, not a popup. The object already exists, so this edits
-- a value rather than confirming an act - which is why runs and routes, whose
-- renames ARE acts on a whole record, still use the client's confirm.
Map.Select(beacon)
Object.Refresh()
assert(objName._shown, "a beacon can be named")
objName:SetText("los pull")
objName.OnEnterPressed(objName)
assert(Routes.NameOf(beacon) == "los pull",
       "NAME NOT COMMITTED: got " .. tostring(Routes.NameOf(beacon)))

-- =====================================================================
-- ★★ §83 - THE STAGE BOX IGNORES PROGRAMMATIC SETS
--
-- The client passes userInput=false for a SetText and true when a human typed
-- (measured, api run 5). §81 defended refresh->SetText->refresh by COMPARING before
-- writing; the flag replaces that with a gate, so refresh's own writes announce
-- themselves and stop at the door.
--
-- ⚠ HONEST ABOUT WHAT THIS BUYS: it is CORRECTNESS OF INTENT, not a bug fix. Under
-- the measured change-only model the old loop terminated on its own after one bounce,
-- so nothing was broken. What it removes is refresh running twice per selection for
-- no reason, and a handler that cannot tell a user from itself.
-- =====================================================================
local stageBox
for _, o in ipairs(made) do
    if o._name == "COA_DungeonRunObjectStage" then stageBox = o end
end
assert(stageBox, "the stage field exists")
local onText = rawget(stageBox, "OnTextChanged")
assert(type(onText) == "function", "and it has a handler")

-- A programmatic set must NOT provoke the refresh that would overwrite it.
stageBox:SetText("junk")
assert(stageBox._text == "junk",
       "A PROGRAMMATIC SET TRIGGERED A REFRESH: the gate is missing, so the pane "
       .. "rewrote the box from its own write - got " .. tostring(stageBox._text))

-- A user edit must.
onText(stageBox, true)
assert(stageBox._text ~= "junk",
       "A USER EDIT DID NOT REFRESH: the gate is rejecting real typing too, which "
       .. "makes the field dead rather than merely quiet")

-- ★ ONE SETTER, TWO FIELDS. A beacon carries `name`, a note carries `text` -
-- different questions - but naming is one gesture and the pane must not have to
-- know which it is holding.
local aNote = Routes.AddNote(33, Store.Get(runId).legs[1])
assert(Routes.SetName(aNote, "buff here") == "buff here", "a note takes a name too")
assert(aNote.text == "buff here" and aNote.name == nil,
       "WRONG FIELD: a note's name is its text, and a beacon's is its name")
assert(Routes.NameOf(aNote) == "buff here", "and reading it is one call")

-- ★ A note is deleted BY IDENTITY. A plane has no stage numbers, and an index
-- would be wrong the moment anything else removed one first.
-- Deletes the LAST note, not the first: an index-based delete removes whatever sits
-- at position 1 and would pass if the target happened to be there. The target has
-- to be somewhere an index cannot reach by luck.
local second = Routes.AddNote(33, Store.Get(runId).legs[1])
Routes.SetName(second, "the one to remove")
local before = Routes.NoteCount(33)
assert(Routes.DeleteNote(33, second), "the note was removed")
assert(Routes.NoteCount(33) == before - 1, "one fewer")
for _, n in ipairs(Routes.GetNotes(33).notes) do
    assert(n ~= second,
           "DELETED THE WRONG NOTE: identity, not index - the target survived")
    assert(Routes.NameOf(n) ~= "the one to remove", "and only the target")
end
assert(Routes.NameOf(aNote) == "buff here",
       "DELETED THE WRONG NOTE: identity, not index - the first note is untouched")

-- ★ MY CALL, flagged in §63: minting from an already-promoted object is refused.
-- Not promotion but duplication, from a position someone may already have dragged.
Map.Select(Routes.Get(rid).beacons[1])
Promoter.Refresh()
assert(createBtn:IsEnabled() == false,
       "PROMOTED A PROMOTION: a beacon is not a node to copy from")
assert(noteBtn:IsEnabled() == false, "and neither is it a note's source")

-- =====================================================================
-- ★★ §74: THE DRIVER'S GEOMETRY. Pure, so it is assertable without a player - and
-- it is the one piece where being wrong is INVISIBLE in game: a beacon that fires
-- from the wrong height feels exactly like a beacon that fired.
--
-- The numbers are §73's real measurements, not invented ones:
--   the cross-walk pair   3.12 yd planar, 9.71 yd vertical
--   interact baseline     5 yd (COA_Landmarks store.lua:45)
--   height default        ±2.5 yd
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
-- §79 - THE OUTCOME OF SATISFACTION
--
-- *"All the same mechanism. So what building the check point is, is building the
-- outcome of satisfaction to be dynamic operable."* One expression, one parameter:
-- index = max(index, outcome), outcome = self+1 by default or a number you typed.
-- =====================================================================
local oid = select(1, Routes.Create("outcomes", 33))
local leg = Store.Get(runId).legs[1]
local b1 = Routes.AddBeacon(oid, leg)
local b2 = Routes.AddBeacon(oid, leg)
local b3 = Routes.AddBeacon(oid, leg)
assert(b1.stage == 1 and b3.stage == 3,
       ("STAGES ARE NOT SEQUENTIAL: three mints must give 1,2,3 - got %s,%s,%s")
       :format(tostring(b1.stage), tostring(b2.stage), tostring(b3.stage)))

-- ★ THE DEFAULT STORES NOTHING. A route of ordinary beacons carries no field at
-- all, so nothing has to be migrated and a stale stored "self+1" cannot exist.
assert(Routes.OutcomeOf(b1) == nil, "THE DEFAULT WAS STORED: it must stay nil")
assert(Routes.Outcome(b1) == 2, "and RESOLVE to self+1, got " .. tostring(Routes.Outcome(b1)))

Routes.SetOutcome(b2, 7)
assert(Routes.OutcomeOf(b2) == 7, "a checkpoint stores the literal it was given")
assert(Routes.Outcome(b2) == 7, "and resolves to it rather than to self+1")
assert(Routes.Outcome(b1) == 2, "and its neighbour is untouched")

-- ⚠ 4.1 IS AN ORDINARY STAGE. Insertion sub-divides rather than renumbering, which
-- is the whole reason a literal number stays true - so the field must take one.
Routes.SetOutcome(b3, 4.1)
assert(Routes.Outcome(b3) == 4.1, "a fractional stage must survive, got "
       .. tostring(Routes.Outcome(b3)))
Routes.SetOutcome(b3, nil)
assert(Routes.OutcomeOf(b3) == nil, "clearing returns it to the default")
assert(Routes.Outcome(b3) == 4, "and the default resolves again")

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
-- stage number until §79, reading the wrong beacon after a single delete.
Routes.DeleteBeacon(oid, 2)
local order = Routes.StageOrder(oid)
assert(#order == 2 and order[1].stage == 1 and order[2].stage == 3,
       "a delete leaves a GAP in the numbering, it does not renumber")
-- ⚠ Hoisted, not inlined as `BeaconAt(...).stage`: when the lookup breaks it returns
-- NIL, and indexing that throws before the assertion can say what went wrong. The
-- mutation came back "bit, but not on its own message" for exactly that reason.
local across = Routes.BeaconAt(oid, 2)
assert(across and across.stage == 3,
       "BEACON LOOKUP IS POSITIONAL: index 2 must find stage 3 across the gap, got "
       .. tostring(across and across.stage))
local exact = Routes.BeaconAt(oid, 1)
assert(exact and exact.stage == 1, "and an exact match still matches")
assert(Routes.BeaconAt(oid, 4) == nil, "past the last stage there is nothing left")

-- =====================================================================
-- §80 - THE STAGE AT MINT
--
-- *"It holds what it would be as ghost text, to a round number. And the user can
-- input their own. Then the next mint walks the gap."*
-- =====================================================================
local gid = select(1, Routes.Create("gaps", 33))
for _ = 1, 4 do Routes.AddBeacon(gid, leg) end
assert(Routes.NextStage(gid) == 5,
       "THE NEXT STAGE IS NOT FREE: four beacons occupy 1-4, so the next is 5, got "
       .. tostring(Routes.NextStage(gid)))

-- ★ Typed beats the ghost. Asserted BEFORE the gap tests: minting at 9 is what
-- CREATES the gap, so if the explicit value is ignored the gap never exists and the
-- failure surfaces as "no gap" rather than as "the field did nothing".
local nine = Routes.AddBeacon(gid, leg, 9)
assert(nine and nine.stage == 9,
       "AN EXPLICIT STAGE WAS IGNORED: minted at " .. tostring(nine and nine.stage))

-- ★ THE DEFAULT WALKS THE GAP - lowest free round number, NOT highest + 1. His
-- worked example: 1,2,3,4,9 picks up on 5, skips 9 for 10, continues.
assert(Routes.NextStage(gid) == 5,
       "A GAP IS NOT REFILLED: with 1,2,3,4,9 the next mint must pick up on 5, got "
       .. tostring(Routes.NextStage(gid)))
for _ = 5, 8 do Routes.AddBeacon(gid, leg) end          -- fills 5,6,7,8
assert(Routes.NextStage(gid) == 10,
       "A TAKEN STAGE IS NOT SKIPPED: 9 is used, so the next must be 10, got "
       .. tostring(Routes.NextStage(gid)))

-- ★ A gap left by a DELETE refills itself, which is the same rule doing a second job.
Routes.DeleteBeacon(gid, 3)
assert(Routes.NextStage(gid) == 3, "a deleted stage frees its number")

-- ⚠ FRACTIONS ARE ONLY EVER TYPED, never generated: *"the user can always follow up
-- the next mint as 4.2 for their 4.1, but that's them doing something specific."*
local frac = Routes.AddBeacon(gid, leg, 4.1)
assert(frac.stage == 4.1, "an explicit fractional stage is taken as given")
assert(Routes.NextStage(gid) % 1 == 0,
       "THE DEFAULT WENT FRACTIONAL: it must stay a round number, got "
       .. tostring(Routes.NextStage(gid)))

-- ⚠ A DUPLICATE IS ALLOWED, not refused - it shows as two adjacent rows in the
-- running order, and refusing it would be grading the author's work.
local dup = Routes.AddBeacon(gid, leg, 1)
assert(dup and dup.stage == 1, "a duplicate stage is the author's business")

-- =====================================================================
-- §82 - THE HARNESS MODELS THE CLIENT, and the guard that makes it safe
--
-- *"Is it worth having a check list of conditions to watch of how the client
-- performs?"* - answered by encoding the conditions instead of listing them.
-- =====================================================================
-- ★ The real EditBox:SetText FIRES OnTextChanged. The stub did not, which is how
-- §81's freeze reached a commit: the smoke drove refresh() directly and never went
-- through a script handler at all.
-- ⚠ CORRECTED BY MEASUREMENT (api run 5). This block used to assert that SetText
-- fires on an UNCHANGED value - the premise §81's comparison guard rested on. The
-- client does not: OnTextChanged is CHANGE-ONLY (and deferred, and coalesced).
local fired, lastArg = 0, "(unset)"
local probe = CreateFrame("EditBox", nil, nil, "InputBoxTemplate")
probe:SetScript("OnTextChanged", function(_, a) fired = fired + 1; lastArg = a end)
probe:SetText("hello")
assert(fired == 1, "SetText MUST FIRE OnTextChanged on a change - the client does")
probe:SetText("hello")
assert(fired == 1,
       "SETTING THE SAME VALUE MUST NOT FIRE: measured change-only on this fork, and "
       .. "modelling it as unconditional is what made §81's 'freeze' look real")
probe:SetText("world")
assert(fired == 2, "and a real change fires again")

-- ★★★ THE userInput FLAG. The client passes FALSE for a programmatic SetText and
-- true when a human typed - which is the structural fix for every refresh loop, and
-- nothing used it until §83.
assert(lastArg == false,
       "A PROGRAMMATIC SetText MUST REPORT userInput=false, got " .. tostring(lastArg)
       .. " - a truthy value here would let every refresh write masquerade as typing")

-- Show/Hide fire on a TRANSITION only - a pane that refreshes from OnShow is
-- ordinary, and a Show() inside that refresh is §81's loop shape again.
local shown, hidden = 0, 0
local pf = CreateFrame("Frame")
pf:SetScript("OnShow", function() shown = shown + 1 end)
pf:SetScript("OnHide", function() hidden = hidden + 1 end)
pf:Show(); pf:Show()
assert(shown == 1, "OnShow fires on the transition, not on every Show")
pf:Hide(); pf:Hide()
assert(hidden == 1, "and OnHide likewise")

-- ★★ THE DEPTH GUARD - the necessary partner to firing events at all. Without it a
-- re-entrant handler HANGS the suite, which is worse than no test: it reports
-- nothing, blocks the run, and reads as an environment fault rather than a bug.
-- ⚠ THE HANDLER MUST ALTERNATE. It used to write a CONSTANT, which re-entered only
-- because the old model fired on unchanged values; under the measured change-only
-- model that terminates after two and proves nothing. A handler that "corrects" the
-- text to a DIFFERENT value is both genuinely re-entrant and a realistic shape.
local loopy = CreateFrame("EditBox")
loopy:SetScript("OnTextChanged", function(self)
    self:SetText(self:GetText() == "a" and "b" or "a")
end)
local ok, err = pcall(function() loopy:SetText("go") end)
assert(not ok, "A RUNAWAY HANDLER MUST FAIL, not hang the suite")
assert(tostring(err):find("RE%-ENTRANCY"),
       "and it must NAME re-entrancy, got " .. tostring(err))
-- ⚠ The counter must come back to zero on its own. If tripping the guard left it
-- skewed, the second runaway of a session would be missed - a guard that works once
-- is a guard that lies afterwards.
assert(H.Depth() == 0,
       "THE DEPTH COUNTER DID NOT UNWIND: it reads " .. tostring(H.Depth())
       .. ", so the next runaway would be mis-counted")
local ok2 = pcall(function() loopy:SetText("again") end)
assert(not ok2, "and it must still bite the SECOND time")

-- =====================================================================
-- §81 - STAGE EDITABLE AFTER THE MINT, the MATCH count, and the GAPS line
-- =====================================================================
-- ★ §56 said stage was "inherited as a default and EDITABLE" from the beginning.
local eb = Routes.AddBeacon(gid, leg, 30)
assert(Routes.SetStage(eb, 30.5) == 30.5, "a stage can be edited after the mint")
assert(eb.stage == 30.5, "and the edit lands on the object")
assert(Routes.SetStage(eb, "not a number") == 30.5,
       "AN UNPARSEABLE EDIT MUST KEEP WHAT WAS THERE, not zero the stage")

-- ★ THE MATCH COUNT - *"a small Match count for that slot."* How many OTHER beacons
-- already sit on this number. It never refuses one; it stops a collision being
-- invisible at the moment you would create it.
assert(Routes.StageMatches(gid, 1) >= 2,
       "stage 1 is doubled in this fixture, so it must report a match")
local first = Routes.BeaconAt(gid, 1)
assert(Routes.StageMatches(gid, 1, first) == Routes.StageMatches(gid, 1) - 1,
       "A BEACON MUST NOT MATCH ITSELF: the field would always read as a collision")
assert(Routes.StageMatches(gid, 999) == 0, "an unused number is free")
assert(Routes.StageMatches(gid, "nonsense") == 0, "and an unparseable one is not a match")

-- ★ THE GAPS LINE - free numbers INSIDE the span. Everything above the highest stage
-- is not a gap, it is simply the next number, and the ghost already offers that.
local hid = select(1, Routes.Create("holes", 33))
for _, n in ipairs({ 1, 2, 5, 9 }) do Routes.AddBeacon(hid, leg, n) end
local holes = Routes.Gaps(hid)
-- ⚠ The BOUND is asserted before the contents, and it has to be: both the bound
-- mutation and the skip-used mutation change the list, and without a check that only
-- the bound can fail they both reported "GAPS ARE WRONG".
for _, g in ipairs(holes) do
    assert(g <= 9,
           "A GAP ABOVE THE TOP STAGE IS NOT A GAP - it is simply the next number, got "
           .. tostring(g))
end
assert(table.concat(holes, ",") == "3,4,6,7,8",
       "GAPS ARE WRONG: got " .. table.concat(holes, ","))
assert(#Routes.Gaps(hid, 3) == 3, "and the limit is honoured for a light readout")
local none = select(1, Routes.Create("solid", 33))
for _ = 1, 3 do Routes.AddBeacon(none, leg) end
assert(#Routes.Gaps(none) == 0,
       "A CONTIGUOUS ROUTE HAS NO GAPS: anything above the top is the NEXT number")

-- ★★ THE ORDER SELF-ORGANISES BY VALUE - *"1 2 3 4 4.1 4.2 4.3 5 is still a ranked
-- order"*. Minted out of order on purpose: what the table draws is what the driver
-- walks, and there is no second ordering to disagree with it.
local sid = select(1, Routes.Create("sorting", 33))
for _, n in ipairs({ 5, 1, 4.2, 4, 4.1 }) do
    Routes.AddBeacon(sid, leg).stage = n
end
local got = {}
for _, b in ipairs(Routes.StageOrder(sid)) do got[#got + 1] = ("%g"):format(b.stage) end
assert(table.concat(got, " ") == "1 4 4.1 4.2 5",
       "ORDER IS NOT SORTED BY VALUE: got " .. table.concat(got, " "))

print("smoke_dungeonrunpromoter: OK")
