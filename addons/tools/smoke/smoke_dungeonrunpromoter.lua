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
-- ⚠⚠ RETIRED §335 WITH THE RULE IT DEFENDED. This asserted `the id is name-n, for
-- legibility` - which A8.4 removes: the key baked in a label `Rename` could change, and
-- could hold the COLON that `RID:BID:CID` uses as its separator.
-- ★ A guard that defends a retired rule is worse than no guard: it goes red ON THE FIX
-- and reads as the fix being wrong. It retires in the same commit, never after.
assert(type(id) == "number",
       "THE ROUTE ID IS NOT OPAQUE: it is the counter alone (A8.4). A key carrying the "
       .. "name is a key that goes stale on rename and can contain the address separator")

-- Renaming moves a LABEL and no handle, because id and name were separated at
-- creation - exactly as a run's are.
Routes.Rename(id, "SFK speed v2")
assert(Routes.Get(id).name == "SFK speed v2" and Routes.Get(id), "rename keeps the handle")
-- ★ STRONGER SINCE A8.4: the handle was always stable, but it USED TO CARRY the old
-- name inside it. Now renaming to something with a COLON in it - the address separator -
-- leaves the address untouched, which is the whole of A8.4's criterion (M4).
Routes.Rename(id, "SFK: fast-3")
assert(Routes.Get(id) and type(id) == "number",
       "A COLON IN A ROUTE NAME REACHED THE ADDRESS: the name is free text and the rid "
       .. "is a number - `RID:BID:CID` parses because no segment can contain the "
       .. "separator")
Routes.Rename(id, "SFK speed v2")

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

Routes.DeleteBeacon(id, b.id)
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
    -- ⚠ §87: MODELLED, because the catch-all __index above was swallowing it as a
    -- no-op that looks like it worked - the trap harness.lua names for exactly this.
    -- The client CHAINS a hook after any existing handler rather than replacing it.
    function o:HookScript(k, fn)
        local prev = self[k]
        self[k] = function(...)
            if prev then prev(...) end
            return fn(...)
        end
    end
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
-- ★★ THE GETTER, AND ITS ABSENCE WAS A HOLE (§374). `promoter.lua:650` and
-- `editor.lua:682` register dropdown reads as
--     read = function() return UIDropDownMenu_GetText and UIDropDownMenu_GetText(dd) end
-- ⚠ With the getter unstubbed that `and` is FALSE, so both reads answered nil and
-- any assertion about what a dropdown DISPLAYS was vacuous. Two registered controls
-- the harness could never answer for - §322's family, and it is how the route
-- selector could print a mint id for a whole arc without a red.
function UIDropDownMenu_GetText(dd) return dd and dd._text end
StaticPopupDialogs = {}
function StaticPopup_Show() end

load("map.lua")
load("promoter.lua")
-- ⚠⚠ ui.lua LOADS FIRST HERE, AND THE .toc DOES THE OPPOSITE (corrected §330).
--
-- ⚠ MY §322 COMMENT SAID "because the .toc does". IT DOES NOT: the .toc lists
-- object.lua at 10 and ui.lua at 11. I read that file, wrote the opposite into this
-- comment, and the fix was right for a reason I had not stated.
--
-- ★★ THE REAL REASON, and it is one step removed from load order: `local R = NS.UI and
-- NS.UI.Register` sits INSIDE `Object.Init()`, not at chunk scope. So what decides
-- whether R is nil is WHEN Init IS CALLED. In the client, `core.lua` calls every Init
-- after ALL files have loaded, so NS.UI exists by then whatever the file order is.
-- **This smoke has no core.lua** - it calls Init immediately after loading - so it has
-- to compensate with load order. Moving `Object.Init()` below the old ui.lua load would
-- have worked equally well.
--
-- ⚠ Before the fix, R was nil and all ~29 of object's registrations were silent no-ops.
-- ★ check_interface could never have caught it, for two reasons and the second is the
-- worse: its regex matches the SOURCE TEXT of `R("object.role", ...)`, which is
-- byte-identical whether R is a function or nil; and it globs the ADDON folder and never
-- opens this file. It would have reported all 29 as registered in BOTH states - positive
-- evidence for a claim that was false in the harness. (A9.1's second criterion.)
-- ★ ADAPTOR BEFORE THE PANE (§368). `object.lua` now asks `NS.Adaptor.Word` for every
-- user word, so a load chain without it gives the pane a nil to index. ⚠ THE SAME
-- CLASS AS §322: this file's order is a HAND COPY of the .toc's, and a copy drifts the
-- moment the .toc gains a file. It cost a red here rather than a silent pane because
-- the emit is asserted - which is the argument for asserting emits.
load("adaptor.lua")
load("ui.lua")
load("object.lua")
local Map, Promoter, Object = NS.Map, NS.Promoter, NS.Object
-- ★★★ A9.1's SECOND CRITERION, HALF ONE: the precondition, asserted rather than
-- assumed. `Object.Init()` binds `local R = NS.UI and NS.UI.Register` ONCE. If NS.UI is
-- not there yet, R is nil and every registration below it is a silent no-op - which is
-- exactly what happened, undetected, until §322.
-- ⚠ This is the line that makes a future reorder fail HERE, with the reason attached,
-- instead of thirty tests later as a puzzling nil.
assert(type(NS.UI) == "table" and type(NS.UI.Register) == "function",
       "NS.UI.Register IS NOT LIVE BEFORE Object.Init(): every pane registration will be "
       .. "a silent no-op and the suite will still go green. Load ui.lua first, or call "
       .. "Object.Init() later - the client gets away with it because core.lua Inits "
       .. "everything after all files have loaded, and this harness has no core.lua")

Map.Init()
Promoter.Init()
Object.Init()

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

-- =====================================================================
-- ★★★ WHAT THE USER SEES vs WHAT THE SYSTEM USES (Battlewrath, 2026-08-18)
--
-- ⚠ THE REGRESSION THIS EXISTS FOR: before A8.4 a route's id WAS `name-N`, so a pane
-- printing the id printed the name for free. A8.4 made the RID OPAQUE and two display
-- sites kept printing the id - so the selector handed the author a mint number.
--
-- ★★ And nothing caught it, because nothing asserted what the control DISPLAYS. The
-- fixture makes name and id DIFFER on purpose: a route called "SFK speed" with an
-- integer id cannot pass this by accident the way `name-N` did.
-- =====================================================================
assert(tostring(rid) ~= "SFK speed",
       "THE FIXTURE CANNOT TELL THEM APART: this whole block is only a test while the "
       .. "id and the name are different things")

-- ⚠ `NS.UI` rather than the file's `UI` local, which is bound a thousand lines
-- below this. A smoke that reaches for a local declared later fails on the NAME,
-- not on the claim - and the claim is what a red should be about.
local shown = NS.UI.Read("promoter.route")
assert(shown == "SFK speed",
       ("THE SELECTOR SHOWS THE ID, NOT THE NAME: got %q. The name is what the author "
        .. "picked and navigates by; the RID is what the system keys on. Both are true "
        .. "and only one leads"):format(tostring(shown)))

-- ★ AND THE ID IS STILL FINDABLE - quiet, not hidden (§230's grammar). Removing it
-- would make the thing the system uses unfindable, which is how an author ends up
-- unable to say which of two same-named routes they are looking at.
local idShown = NS.UI.Read("promoter.id")
assert(idShown and idShown:find(tostring(rid), 1, true),
       ("THE ID IS NOT INSPECTABLE: got %q. A face without its meta is not simpler, it "
        .. "is a pane that cannot answer 'which one is this'"):format(tostring(idShown)))

-- ⚠ An id line with nothing to identify is furniture. §230's slot is learned by being
-- RELIABLE, and a stale id under an empty pane is worse than a blank one.
Map.Load("route", nil)
Promoter.Refresh()
assert(NS.UI.Read("promoter.id") == "",
       "THE ID LINE SURVIVED THE ROUTE BEING UNLOADED: it names a thing that is no "
       .. "longer on screen, which is §238's hazard in the identity slot")
Map.Load("route", rid)
Promoter.Refresh()

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
Routes.DeleteBeacon(rid, other.id)
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
-- =====================================================================
-- ★★★ A2.10 - THE STAGELESS NODE, graded before it can be authored.
--
-- ⚠ `AddBeacon` FORCES a stage today (S7), so the node is PLANTED rather than
-- minted - the same way A2.6's smoke plants a `goTo`. That is the point of the
-- row: the day the mint accepts one, nothing downstream has to be discovered.
-- =====================================================================
local sless = Routes.AddBeacon(oid, leg)
local slessStage = sless.stage
sless.stage = nil                      -- as a recovery beacon will arrive

-- ★★ A2.10a - THE ONE DEFECT. `b.outcome or ((b.stage or 0) + 1)` answered 1, which
-- would send the player back to the START of the route on a recovery beacon's
-- completion. `nil` is the "no promotion" contract Driver.Promote already reads.
assert(Routes.Outcome(sless) == nil,
       "A STAGELESS NODE PROMOTED THE INDEX: it is not in the sequence, so it "
       .. "cannot move the sequence. Answering (stage or 0)+1 sends the player to "
       .. "stage 1 - the START of the route - on a recovery beacon completing. "
       .. "Got " .. tostring(Routes.Outcome(sless)))

-- ⚠ and the run's index is UNMOVED, which is what the row actually promises.
-- Driver.Promote's rule inlined, because it lives in backlog/ and is not loaded here.
local function promote(current, outcome)
    if not outcome then return current end
    return math.max(current or 0, outcome)
end
-- ⚠ RESTATEMENT, NOT A GUARD. It is derived from the assertion directly above -
-- any value that fails here already failed there. ★ Kept because A2.10a's promise
-- is about THE RATCHET, and `Outcome() == nil` only shows that in one more step.
assert(promote(6, Routes.Outcome(sless)) == 6,
       "THE RATCHET MOVED. A2.10a is 'moves the ratchet NOT AT ALL' - at stage 6, "
       .. "completing a stageless node must leave the index at 6")

-- ⚠ AND IT OVERRIDES A STORED OUTCOME, unconditionally (RI-32 filed on this).
Routes.SetOutcome(sless, 9)
assert(Routes.Outcome(sless) == nil,
       "A STORED OUTCOME REVIVED THE PROMOTION: A2.10a is unconditional - a node "
       .. "outside the sequence cannot promote it, whatever was stored on it")
-- ★★ A2.10a's SECOND HALF (RI-32, drained): STORED, AND SAID. The strict read stands -
-- `Outcome` answers nil above - and the author is TOLD rather than left guessing.
local beforeTell = #chat
Routes.SetOutcome(sless, 9)
assert(#chat > beforeTell,
       "A DORMANT CHECKPOINT WAS STORED SILENTLY: `SetOutcome` is reachable from the "
       .. "pane for any beacon, so an author can put one on a stageless node where it "
       .. "will never fire. §81 forbids REFUSING - that would grade the author - so it "
       .. "must be TOLD, which is `DropRetired`'s shipped shape")

-- ⚠⚠ AND THE MESSAGE MUST BE ACCURATE, which is the half a bare "it was said" misses.
-- The value is STORED and DORMANT, not lost. "Ignored" or "cleared" would send the
-- author to re-enter something that is already there.
local told = chat[#chat] or ""
assert(told:find("STORED", 1, true) and told:find("DORMANT", 1, true),
       "THE MESSAGE DID NOT SAY WHAT HAPPENED: the value is stored and dormant, not "
       .. "lost, and the author needs to know it is still there. Said: " .. told)
assert(not told:find("ignor", 1, true) and not told:find("clear", 1, true),
       "THE MESSAGE SAID THE VALUE WAS LOST: it was not - the stageless guard merely "
       .. "suppresses it. Said: " .. told)

-- ★★★ AND THE CLAIM THE MESSAGE MAKES MUST BE TRUE. It promises the checkpoint takes
-- effect once the node has a stage; if that were false the tell would be a lie with a
-- friendly tone, which is worse than silence.
Routes.SetStage(sless, 3)
assert(Routes.Outcome(sless) == 9,
       "THE TELL LIED: it promises 'give the node a stage and it takes effect', so a "
       .. "stored 9 must become live the moment the node has one. Got "
       .. tostring(Routes.Outcome(sless)))
Routes.SetStage(sless, 0)
assert(sless.stage == nil and Routes.Outcome(sless) == nil,
       "and returning it to stageless must suppress the stored value again")

Routes.SetOutcome(sless, nil)

-- ★ A2.10b - THE EIGHT ARE A CONTRACT, not an observation. Each asserted so that
-- the day AddBeacon accepts a stageless node, none of this has to be rediscovered.
-- ★★ A GUARD, and the only mutation that reaches it comes through a STAGELESS node.
-- ⚠ This carried a "restatement, not a guard" label from §393 and THE LABEL WAS WRONG.
-- Two mutations of the mint were both caught earlier at :151/:154 - but BOTH of those
-- rows run on route `id`, which has no stageless beacon, and `NextStage` only ever sets
-- `used[0]` when one exists. `if used[0] then return 0 end` passes them and bites HERE.
-- ★ Two mutations missing a row is evidence about those two mutations, not about the
-- row. The method was sound; the SAMPLE was small, which is a different thing.
assert(Routes.NextStage(oid) ~= 0,
       "THE MINT PRODUCED THE RESERVED VALUE: stage 0 means ALWAYS ELIGIBLE, so a "
       .. "mint that can return it hands out a recovery beacon by accident")
assert(Routes.StageOrder(oid)[1] == sless,
       "A STAGELESS NODE DID NOT SORT FIRST: `(x.stage or 0)` puts it at the head, "
       .. "which is RI-18 Q5's 'no-stage first' falling out for free")
assert(Routes.StageMatches(oid, 1, nil) >= 1 and Routes.StageMatches(oid, 0) == 0,
       "A NIL STAGE COLLIDED: `b.stage == n` must never match a stageless node, "
       .. "least of all against the reserved 0")
local gaps = Routes.Gaps(oid)
for _, g in ipairs(gaps) do
    assert(g ~= 0, "GAPS REPORTED 0: the reserved value is not a hole to fill")
end
assert(Routes.StageOf(oid, sless) == nil,
       "StageOf INVENTED A STAGE for a node that has none")
assert(Routes.BeaconAt(oid, 1) ~= sless,
       "A STAGELESS NODE WAS RETURNED FOR AN ORDERED INDEX: it is not in the run, "
       .. "which is the whole point of it")

-- ★★ A2.10c - NO ADDRESS IS NOT A BUG, and the two agree so neither is a defect.
local skid = Routes.AddChildHere(oid, sless)
Routes.SetChildOrdinal(sless, skid, 1)
assert(Routes.PathOf(oid, skid) == nil,
       "PathOf INVENTED AN ADDRESS: a stageless node has no `stage:ordinal` path "
       .. "BY DESIGN - the driver finds it by RID:BID:CID. Do not 'fix' this")
local hit, n = Routes.ChildAt(oid, "0:1")
assert(hit == nil and n == 0,
       "ChildAt REACHED A STAGELESS NODE BY PATH: it must agree with PathOf, and "
       .. "the two agreeing is why neither is a defect")

-- ⚠ THE FIXTURE IS REMOVED, not restored. A planted beacon left behind changes the
-- route's beacon COUNT, and the rows below this one assert exactly that ("a delete
-- leaves a GAP in the numbering") - which is how this leak was found.
Routes.DeleteChild(sless, skid)
Routes.DeleteBeacon(oid, sless.id)
-- =====================================================================
-- ★★★ S7 - THE STAGELESS BEACON NOW HAS A PATH IN. A2.10 asserted what every
-- consumer does with one; this asserts it can be MADE. `AddBeacon` forced a
-- stage until §395 and its own comment said so ("no path in through here either").
-- =====================================================================

-- ★ 0 IS THE REQUEST, nil IS WHAT IS STORED (data model §A3.10).
local born = Routes.AddBeacon(oid, leg, 0)
assert(born ~= nil, "a stageless beacon must MINT, not be refused")
assert(born.stage == nil,
       "THE RECORD FORM WAS STORED: `0` is how a caller ASKS for stageless and "
       .. "`nil` is what the store holds. Got " .. tostring(born.stage))

-- ⚠⚠ AND THE TWO CONSEQUENCES, asserted here rather than trusted, because in Lua
-- `not 0` is FALSE - a stored zero is not stageless to anything that tests the
-- field, and both of these would come back silently.
assert(Routes.Outcome(born) == nil,
       "A2.10a's DEFECT RETURNED BY THE BACK DOOR: a stored 0 makes Outcome answer "
       .. "0+1 = 1, which sends the player to the START of the route. The store "
       .. "must hold nil, not the record form")
local bk = Routes.AddChildHere(oid, born)
Routes.SetChildOrdinal(born, bk, 1)
assert(Routes.PathOf(oid, bk) == nil,
       "A STAGELESS NODE WAS GIVEN AN ADDRESS: a stored 0 makes PathOf hand out "
       .. "\"0:1\", contradicting A2.10c - which says this node has no path BY DESIGN")
Routes.DeleteChild(born, bk)

-- ★ THE OTHER DOOR. A rule that holds at one entrance is not a rule.
local pair = Routes.AddBeacon(oid, leg)
assert(pair.stage ~= nil, "the ordinary mint still gives a stage")
Routes.SetStage(pair, 0)
assert(pair.stage == nil,
       "SetStage STORED THE RECORD FORM: the editor's door must translate 0 to nil "
       .. "exactly as the mint does, or the two doors disagree about one field")
assert(Routes.Outcome(pair) == nil,
       "and the same consequence follows from the editor's door")

-- ⚠ and an ordinary stage is UNAFFECTED - the translation is for 0 alone.
Routes.SetStage(pair, 4)
assert(pair.stage == 4 and Routes.Outcome(pair) == 5,
       "AN ORDINARY STAGE WAS CAUGHT BY THE ZERO PATH: only 0 means stageless")

Routes.DeleteBeacon(oid, born.id)
Routes.DeleteBeacon(oid, pair.id)


-- ★ STAGE IS A LABEL, NOT AN ARRAY POSITION. DeleteBeacon matches on b.stage and
-- leaves a GAP, so {1,3} is an ordinary route - and the driver indexed the table by
-- stage number until §79, reading the wrong beacon after a single delete.
Routes.DeleteBeacon(oid, b2.id)
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
-- ⚠ §227: the delete takes an ID now, so a test that knows only a STAGE has to look the
-- beacon up first - which is the whole point. Stage names a position, not an object.
local function atStage(routeId, n)
    for _, bb in ipairs(Routes.Get(routeId).beacons) do
        if bb.stage == n then return bb end
    end
end
Routes.DeleteBeacon(gid, atStage(gid, 3).id)
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
-- =====================================================================
-- ★★★ §227: TWO BEACONS AT ONE STAGE, AND THE DELETE TAKES THE RIGHT ONE
-- =====================================================================
--
-- The fault the address sheets found. `DeleteBeacon` matched on `b.stage`, and
-- duplicate stages are PERMITTED by design - so deleting the second of two stage-4
-- beacons removed the first, and the pane went on showing the one you picked.
--
-- ⚠ It never fired in ordinary use, because stages are normally distinct. That made it
-- worse, not better: the trigger was a state the design invites.
local twin = Routes.Create("twins", 44)
local tA = Routes.AddBeacon(twin, leg, 4)
local tB = Routes.AddBeacon(twin, leg, 4)
assert(tA.id and tB.id and tA.id ~= tB.id,
       "EVERY BEACON MINTS AN ID, and two on one stage must not share it")
assert(tA.stage == tB.stage, "the duplicate stage is the point of the test")

Routes.DeleteBeacon(twin, tB.id)
local left = Routes.Get(twin).beacons
assert(#left == 1 and left[1].id == tA.id,
       "WRONG BEACON DELETED: a duplicate stage must not let the delete take a sibling")

-- ★ And the ID is not the stage in disguise: retyping the stage moves nothing.
tA.stage = 9
assert(Routes.DeleteBeacon(twin, tA.id) == tA,
       "the handle survives an edit to the characteristic that used to BE the handle")
assert(Routes.DeleteBeacon(twin, 999) == nil, "an unknown id resolves to NOTHING, loudly")

-- =====================================================================
-- ★★★ §231: A CHILD WEARS A WORD, AND THE WORD IS VALIDATED
-- =====================================================================
do
    local ic = Routes.Create("icons", 55)
    local ib = Routes.AddBeacon(ic, leg)
    local kid = Routes.AddChildHere(ic, ib)
    assert(Routes.IconOf(kid) == nil, "a child mints with no word - the default crop")

    local word = Map.Palette()[1]
    assert(word, "the palette has at least one word to test with")
    assert(Routes.SetChildIcon(kid, word) == word, "a palette word is accepted")
    assert(Map.ArtKey(kid) == word, "and the map draws it")

    -- ⚠ VALIDATED AGAINST THE PALETTE, NOT ART. `beacon` is a real crop, and letting
    -- a child claim it would let it draw as something it is not.
    assert(Routes.SetChildIcon(kid, "beacon") == nil,
           "A STRUCTURAL CROP IS NOT A WORD: a child cannot claim to be a beacon")
    assert(Routes.SetChildIcon(kid, "notaword") == nil, "and an invented word clears")
    assert(Map.ArtKey(kid) == "child", "so it falls back to its own crop")

    -- ★ The icon is deaf to identity in both directions.
    Routes.SetChildIcon(kid, word)
    assert(Map.KindKey(kid) == "child", "THE WORD DOES NOT CHANGE WHAT IT IS")
    assert(Routes.SetChildIcon(nil, word) == nil, "and no child, no word")
end

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


-- =====================================================================
-- ★★★ §83: CHILDREN - the theatre gets its contents
-- =====================================================================

local cid = Routes.Create("children", 33)
local anchor = Routes.AddBeacon(cid, node)

-- ★ A CHILDLESS BEACON IS THE OLD BEACON. The whole composing argument rests on
-- this: children change what gets iterated, not whether there is a branch.
assert(Routes.ChildCount(anchor) == 0, "a fresh beacon has no children")
assert(#Routes.ChildrenOf(anchor) == 0, "and the list is EMPTY, never nil")

-- ★★ FROM THE ANCHOR: it takes the beacon's EFFECTIVE position, not its origin.
-- Moved first, so origin and effective genuinely differ - a test where they agree
-- would pass against either implementation and prove nothing.
Routes.Place(anchor, 0.7, 0.8, 33, 2)
local here = Routes.AddChildHere(cid, anchor)
assert(here, "a child mints from the anchor")
assert(here.mapX == 0.7 and here.mapY == 0.8,
       "THE CHILD TOOK THE ORIGIN, NOT THE PLACEMENT: a dragged anchor is where the "
       .. "author means, got " .. tostring(here.mapX))
assert(here.kind == "child", "and it knows what it is")
assert(here.stage == nil,
       "A CHILD CARRIES NO STAGE - the anchor holds it, and any child satisfying "
       .. "completes it")

-- ⚠ THE CHILD OWNS ITS COORDINATES. Moving the anchor afterwards must not drag the
-- child with it: a child is a place in the theatre, not an offset from the anchor.
Routes.Place(anchor, 0.1, 0.1, 33, 2)
assert(here.mapX == 0.7,
       "THE CHILD FOLLOWED ITS ANCHOR: it stored a relationship where it should have "
       .. "stored a position")

-- ★ FROM A NODE: the same PLACE borrow a beacon uses, so the map cannot tell them
-- apart when it draws them.
local kid2 = Routes.AddChildFromNode(cid, anchor, node)
assert(kid2 and kid2.mapX == node.mapX, "a child mints from a node")
assert(Routes.ChildCount(anchor) == 2, "and both are on the anchor")

-- ★★ DELETE IS BY IDENTITY. An index is stale the moment anything else goes.
-- ⚠ THE SECOND ONE, DELIBERATELY. Deleting the FIRST child cannot tell identity
-- from index - both implementations pass - and the first cut of this test did
-- exactly that. The mutation harness caught it as SILENT: `table.remove(list, 1)`
-- survived the suite. Delete index 2 and only the honest implementation lives.
assert(Routes.DeleteChild(anchor, kid2) == kid2, "the child deletes by identity")
assert(Routes.ChildCount(anchor) == 1, "and only that one")
assert(Routes.ChildrenOf(anchor)[1] == here, "the survivor is the OTHER one")
Routes.DeleteChild(anchor, here)
assert(anchor.children == nil,
       "AN EMPTY LIST IS NOT STORED - by-exception, the same rule as the UI store")

-- ★ THE PARENT IS FOUND, NEVER STORED. This is what keeps a child free of the
-- references the flattened driver list could not carry.
local kid3 = Routes.AddChildFromNode(cid, anchor, node)
assert(Routes.ParentOf(cid, kid3) == anchor, "the owner is recoverable by walking")
assert(Routes.ParentOf(cid, node) == nil, "and a non-child has no owner")

-- ★★★ CHILDREN DRAW. PointsOn enumerates them off their anchor rather than as a
-- list of their own, so they take the same floor gate without asking for it.
local drawn = {}
for _, p in ipairs(Map.PointsOn({ beacons = { anchor } }, anchor.floor, { "beacons" })) do
    drawn[#drawn + 1] = p
end
assert(#drawn == 2, "THE CHILD DID NOT DRAW: expected anchor + child, got " .. #drawn)
assert(drawn[2] == kid3, "and the child comes with its anchor")

-- ⚠ ONE LEVEL. A child's own `children` is never walked - nothing mints it, and a
-- recursive enumerator would quietly support a shape the driver cannot flatten.
kid3.children = { { mapX = 0.5, mapY = 0.5, kind = "child", floor = anchor.floor } }
local deep = Map.PointsOn({ beacons = { anchor } }, anchor.floor, { "beacons" })
assert(#deep == 2, "NESTING WAS WALKED: a grandchild drew, and nothing mints one")
kid3.children = nil

-- ★★ THE ART, and the ladder. A child ranks ABOVE its own anchor because
-- AddChildHere puts one exactly on top - ranked below, the first child you spawn
-- could never be clicked.
assert(Map.ArtKey(kid3) == "child", "a child draws as its own key")
assert(Map.Rank(kid3) > Map.Rank(anchor),
       "A CHILD MUST OUTRANK ITS ANCHOR or it is unreachable where it is minted")
local lbl, col, rank = Map.KeyFacts("child")
assert(lbl and col and rank, "and the readout can name it")

-- ★★★ ONE ARM, CARRYING WHAT IT IS FOR. Two slots could both be live; one cannot.
Map.SetMoveArmed(anchor)
assert(Map.MoveArmed() == anchor and Map.ArmedFor() == "move", "the move arm holds")
local picked
Map.SetPickArmed(function(p) picked = p end)
-- ⚠ THE SHARPER CLAIM GOES FIRST. `ArmedFor() == "pick"` is true of a correct
-- implementation AND of a broken one that kept a second slot - so when it led, it
-- stole the failure and the harness reported the right break with the wrong cause.
assert(Map.MoveArmed() == nil,
       "ARMING A PICK LEFT THE MOVE LIVE: two gestures armed at once is the state "
       .. "one slot exists to make impossible")
assert(Map.ArmedFor() == "pick", "arming a pick takes the arm")
local on = Map.PickArmed()
assert(on, "and the pick is readable")
Map.Disarm()
assert(Map.ArmedFor() == nil and Map.PickArmed() == nil, "disarm clears both readings")

-- ★ A child is DRAGGABLE - it is authored, and `draggable means promoted`.
assert(Map.Draggable(kid3), "a child drags")
assert(not Map.Draggable(node), "a captured node still does not")


-- =====================================================================
-- ★★★ §85: THE CHILD'S PROPERTIES, and the walk that reads them
-- =====================================================================


local pid = Routes.Create("props", 33)
local pb = Routes.AddBeacon(pid, node)
local c1 = Routes.AddChildFromNode(pid, pb, node)
local c2 = Routes.AddChildFromNode(pid, pb, node)

-- ★★★ §90: TWO STAGE-COMPLETES ARE LEGAL, AND THIS ASSERTION IS THE REVERSE OF WHAT
-- §85 CLAIMED. Under ANY-CHILD-SATISFIES two of them is not an ambiguity, it is the
-- set having two members - whichever fires first satisfies, and the outcome belongs
-- to the BEACON, so both produce the same index. ⚠ Silently clearing a sibling was the
-- tool editing the author's work, against §81's own answer to the same shape.
Routes.SetChildRole(pb, c1, "complete")
assert(c1.role == "complete", "a role is set")
Routes.SetChildRole(pb, c2, "complete")
assert(c2.role == "complete", "the second child takes it too")
assert(c1.role == "complete",
       "A SIBLING'S ROLE WAS CLEARED: two stage-completes are legal under "
       .. "any-child-satisfies, and refusing one is grading the author")
assert(Routes.RoleMatches(pb, "complete", c2) == 1,
       "and the COLLISION IS COUNTED instead - §81's match count, one level down")
assert(Routes.AcceptanceOf(pb) == c1 or Routes.AcceptanceOf(pb) == c2,
       "acceptance resolves to one of the flagged children")

-- =====================================================================
-- ★★★ §112: THE ANCHOR AS ITS OWN SATISFIER, asserted on ROUTES DIRECTLY.
--
-- ⚠⚠ These two rules were previously witnessed ONLY through the walk's unrunnable
-- report - a string. Removing `walk.lua` turned both of their mutations SILENT,
-- which is the worst state a guard can be in: it still looks like coverage.
--
-- ★ They never needed a consumer. `AcceptanceOf` answers on its own, and asking it
-- directly is a stronger test than reading a sentence a driver printed about it.
-- =====================================================================
local lone = Routes.AddBeacon(pid, node)
assert(Routes.AcceptanceOf(lone) == lone,
       "A CHILDLESS BEACON IS NOT ITS OWN SATISFIER: with nothing to offload to, "
       .. "the anchor answers for itself - §83's composing rule")

local offloaded = Routes.AddBeacon(pid, node)
Routes.AddChildFromNode(pid, offloaded, node)
assert(Routes.AcceptanceOf(offloaded) == nil,
       "AN ANCHOR WITH CHILDREN SATISFIED ITSELF: once the job is offloaded and no "
       .. "child is flagged, that is an unfinished route and must NOT resolve")


-- ★★ `set` IS THE ONE THAT STAYS EXCLUSIVE, and for a reason the others do not have:
-- two ASSIGNMENTS in one theatre have no defined result, not merely an unclear one.
local s1 = Routes.AddChildFromNode(pid, pb, node)
local s2 = Routes.AddChildFromNode(pid, pb, node)
Routes.SetChildRole(pb, s1, "set")
Routes.SetChildRole(pb, s2, "set")
assert(s1.role == nil and s2.role == "set",
       "TWO SET-STAGE CHILDREN ON ONE BEACON: two assignments firing in one theatre "
       .. "have NO defined order, which is ambiguity rather than a duplicate")
Routes.DeleteChild(pb, s1); Routes.DeleteChild(pb, s2)
Routes.SetChildRole(pb, c1, nil)

-- ⚠ A ROLE THAT IS NOT `set` CANNOT KEEP A SET TARGET. A stale number coming back
-- when the role is re-selected later is silent and wrong.
Routes.SetChildRole(pb, c1, "set")
Routes.SetChildStage(pb, c1, 9)
assert(c1.setStage == 9, "a set target is stored")
Routes.SetChildRole(pb, c1, "update")
assert(c1.setStage == nil,
       "A STALE SET TARGET SURVIVED: leaving the `set` role must drop the number")

-- ★ `ifUnseen` is stored BY EXCEPTION - only the false. An absent field and a true
-- field say the same thing, and only one of them can go stale.
assert(Routes.ChildIfUnseen(c1), "if-unseen defaults ON")
assert(c1.ifUnseen == nil, "and the default is not stored")
Routes.SetChildIfUnseen(c1, false)
assert(c1.ifUnseen == false and not Routes.ChildIfUnseen(c1), "the false IS stored")

-- ★★★ §91: THE ACTION IS AN ACT WITH A TARGET, and §85's exclusivity is gone with
-- `complete`'s. Several children carrying `supertrack` are not claimants fighting
-- over one slot - each SETS it at its own moment, which is the chain.
Routes.SetChildAction(pb, c1, "supertrack")
Routes.SetChildAction(pb, c2, "supertrack")
assert(c1.action == "supertrack" and c2.action == "supertrack",
       "A SUPERTRACK ACTION WAS CLEARED FROM A SIBLING: several children each set "
       .. "the tracker at their own moment, which is what makes a chain possible")

-- ⚠⚠ RETIRED §340 WITH THE MECHANISM THEY DEFENDED (A2.6). Everything below this
-- point used to assert the pointer and its three checks: a child points at another ·
-- self-reference refused · a deleted target resolves to nothing and the BROKEN LINK is
-- reported · custody heads · a cycle reported but not refused.
--
-- ★★ EVERY ONE OF THEM WAS A GUARD ON A STALE POINTER, which is what makes their
-- removal the proof rather than the collateral. "A deleted target resolves to nothing"
-- and "the tracker would bounce forever" are not edge cases the code handled well -
-- they are the failure class that existed BECAUSE one field held another node's
-- identity. Nothing holds one now, so there is nothing to assert.
--
-- ⚠ A guard defending a retired rule goes red ON THE FIX and reads as the fix being
-- wrong. They retire in the same commit, never after - the Analyst's ruling for A1.1's
-- "child must win", applied a second time.
--
-- ★ What REPLACES them is one assertion, and it is stronger than the six it replaces:
-- the mechanical test itself. If no field can hold another node's identity, the whole
-- family of stale-pointer bugs is unreachable rather than handled.
for _, gone in ipairs({ "SetChildGoTo", "GoToTarget", "Heads", "BrokenLinks",
                        "Cycles", "SetChildOnRamp", "OnRampOf" }) do
    assert(Routes[gone] == nil,
           ("`Routes.%s` IS BACK: A2.6 removed outward pointing ABSOLUTELY, not as a "
            .. "parking. A half-formed path invites building on it, and this one carried "
            .. "an entire class of stale-pointer bug"):format(gone))
end

-- ⚠⚠ RESTORED §340. This assertion was deleted with its NEIGHBOURS and its rule was
-- never retired - `mutate.py` reported the mutation SILENT, which is the loudest
-- verdict it has: the suite PASSED with the guard broken.
-- ★ And the claim is MORE true after A2.6, not less: distinct CIDs are the whole of
-- RI-6 (`RID:BID:CID`, unique because the RID is). I cut a live guard by accident
-- while cutting the dead ones around it - the inverse of the mistake this leg has
-- been making, and only a mutation could tell the two apart.
assert(c1.id and c2.id and c1.id ~= c2.id, "children carry distinct ids")

-- ⚠ AND NO NODE MAY HOLD ANOTHER NODE'S IDENTITY (proposition §24). This is the law
-- the removal obeys, asserted on the objects themselves rather than on the API - a
-- field could come back without a function to set it.
Routes.SetChildAction(pb, c1, "supertrack")
assert(c1.goTo == nil and c1.onRamp == nil,
       "A NODE CARRIES ANOTHER NODE'S IDENTITY: `supertrack` points at the node's OWN "
       .. "position now - there is no second place to name, and no field to name it in")
Routes.SetChildAction(pb, c1, nil)
Routes.SetChildAction(pb, c2, nil)

-- =====================================================================
-- ★★★ THE WALK - the control for a format that does not exist yet
-- =====================================================================

-- ⚠ Reach comes from the CHILD, and an unauthored child still has to be testable -
-- create-then-edit means it exists before its values do.
local wid = Routes.Create("walking", 33)
local wb = Routes.AddBeacon(wid, node)
wb.stage = 1
local acc = Routes.AddChildFromNode(wid, wb, node)
Routes.SetChildRole(wb, acc, "complete")
Routes.SetChildReach(acc, 10, 6, 2)
acc.x, acc.y, acc.z = 100, 200, 50


-- =====================================================================
-- ★★★ §87: THE TEST SURFACE - asked, never announced
-- =====================================================================

-- ★ The registry is pure and testable without a frame, which is the point of it
-- being a registry rather than a line of text per control.
local Tests = NS.Tests
assert(Tests, "the test registry is exposed on NS so anything can contribute")

-- ★★★ IT EMITS WHAT WAS MADE, not what will be. §87.1: the test is handed the
-- RESULT of the act, so it reports the value the new object actually carries -
-- a forecast can be wrong, a fact about the object on the map cannot.
local sample = { kind = "beacon", z = 90.62 }
local made = { kind = "child", z = 90.62 }
local here = Tests.Run("child-here", sample, made)
assert(here and here:find("90.6"),
       "THE TEST DID NOT CARRY THE VALUE: a sentence states the rule, a number lets "
       .. "the author check it - got " .. tostring(here))

-- ⚠ AND IT REPORTS THE CHILD'S z, NOT THE BEACON'S. They are equal for `child
-- here` and DIFFERENT for `child at node` - so a test reading the subject instead of
-- the result passes the first and lies on the second.
local elsewhere = { kind = "child", z = 12.5 }
local atNode = Tests.Run("child-at-node", sample, elsewhere)
assert(atNode and atNode:find("12.5"),
       "THE TEST READ THE SUBJECT, NOT THE RESULT: it must report the height the "
       .. "child actually took - got " .. tostring(atNode))

assert(Tests.Run("child-here", sample, nil) == nil,
       "and with nothing produced there is nothing to emit")

assert(Tests.Run("move-z", sample):find("90.6"),
       "the move test reports the z a drag will KEEP")

-- ⚠ A control naming a test nobody registered must go QUIET, not take the pane down.
assert(Tests.Run("no-such-test", sample) == nil, "an unknown key is silent")

-- ⚠ AND A THROWING TEST MUST NOT REACH THE PANE. A readout that can crash the
-- surface it is explaining is worse than no readout.
Tests.Register("boom", function() error("nope") end)
-- ⚠ THE CALL IS WRAPPED HERE TOO, and it has to be: without the registry's own
-- pcall the error propagates THROUGH the assert, so the suite dies on a raw lua
-- error and the message naming the fault never runs. A guard whose failure cannot
-- be phrased is one the mutation harness reports as WRONG rather than BITES.
local okRun, res = pcall(Tests.Run, "boom", sample)
assert(okRun, "A THROWING TEST ESCAPED: the registry must pcall it")
assert(res == nil, "and a failed test returns nothing to show")

-- ★ It answers for the SUBJECT it is handed, so a note or a child gets nothing from
-- a beacon-only test rather than a wrong answer.
assert(Tests.Run("child-here", { kind = "note" }) == nil,
       "a beacon-only test stays quiet on a note")

-- ★★ HookScript CHAINS. The pane hooks OnEnter on controls that already have one,
-- and a replace would silently drop the original behaviour.
local hs = stub()
local order = {}
hs:SetScript("OnEnter", function() order[#order + 1] = "first" end)
hs:HookScript("OnEnter", function() order[#order + 1] = "second" end)
hs.OnEnter()
assert(table.concat(order, ",") == "first,second",
       "HookScript REPLACED instead of chaining: the original handler was dropped")


-- =====================================================================
-- ★★★ §88: A SECOND CLICK CLOSES THE READING
-- =====================================================================

local one = Routes.AddBeacon(Routes.Create("clicking", 33), node)
assert(Map.ClickSelect(one) == one, "a click selects")
assert(Map.Selected() == one, "and the reading is pinned")
assert(Map.ClickSelect(one) == nil,
       "A SECOND CLICK DID NOT CLOSE IT: §69 left no way to put a reading down "
       .. "except selecting something else")
assert(Map.Selected() == nil, "and nothing is selected afterwards")

-- ⚠ THE TOGGLE IS THE GESTURE'S, NOT THE SELECTION'S. Minting a child selects it,
-- and a caller passing the same point twice means *this one*, not *enough*.
--
-- ★★ THIS ASSERTION IS NOT THE ONE THAT CATCHES IT, and that is worth knowing. Put
-- the toggle inside Map.Select and the suite dies EARLIER, on *"opening it selects
-- the thing being edited"* - because OpenEditor selects its subject, so right-
-- clicking an already-selected node would deselect it. That is a real flow and a
-- better witness than this one; this states the rule, that one shows the cost.
Map.Select(one)
Map.Select(one)
assert(Map.Selected() == one,
       "A PROGRAMMATIC RE-SELECT DESELECTED: the toggle leaked out of the gesture "
       .. "and into Map.Select, where a mint would silently undo itself")
Map.Select(nil)


-- =====================================================================
-- ★★★ §92: THE TICK TREE - the pane follows a CHILD, and rows appear by implication
-- =====================================================================

-- ★ The emits are pure and assertable without a frame; the rows themselves need the
-- pane, which the map smoke covers. What matters here is that a change REPORTS.
local role = NS.Tests.Run("child-role", nil, { role = "set" })
assert(role and role:find("set stage"),
       "A ROLE CHANGE DID NOT REPORT: the pane emits what the act did, in the words "
       .. "the author picked - got " .. tostring(role))
assert(NS.Tests.Run("child-role", nil, { role = nil }):find("nothing"),
       "and clearing a role says so rather than going blank")

local placed = { x = 1200, y = 1300 }
local tgt = NS.Tests.Run("child-target", nil, placed)
assert(tgt and tgt:find("1200"),
       "THE TARGET EMIT DID NOT CARRY THE POSITION: it is what the tracker will "
       .. "point at, and a name alone cannot be checked - got " .. tostring(tgt))

-- ⚠ A TARGET WITH NO WORLD POSITION IS SAID PLAINLY. An unplaceable child is a
-- legitimate authoring state (§68: the calibration may not resolve), and the tracker
-- simply cannot be sent there - which the author needs told at the moment they pick it.
local nowhere = NS.Tests.Run("child-target", nil, { kind = "child" })
assert(nowhere and nowhere:find("no world position"),
       "AN UNPLACEABLE TARGET LOOKED FINE: the tracker cannot be pointed at it")


-- =====================================================================
-- ⚠⚠ §93's ON-RAMP BLOCK IS GONE (A2.6 / RI-8, §340)
-- =====================================================================
--
-- It asserted: a childless beacon speaks for itself · an unflagged child does NOT
-- become the on-ramp, it is DECLARED not derived · the flagged child speaks for the
-- stage · and the flag is EXCLUSIVE, because two children speaking for one stage has
-- no answer.
--
-- ★ The last of those is the tell. An EXCLUSIVE flag is a rule invented to stop two
-- answers to a question that should only ever have had one - and RI-8 removed the
-- question instead: the stage lure, then CHILD 1 (the lure, the note), then whatever
-- the author laid out. ⚠ "NOT lowest ordinal", and child 1 is ordinarily ALSO step 1.
--
-- ★★ Which is the shape this bench keeps meeting: a rule enforcing uniqueness is
-- usually a second mechanism apologising for itself. §90 took exclusivity off
-- `complete` for the same reason; §340 takes the whole flag.

-- =====================================================================
-- ★★★ §94: A BEACON ON ITS OWN - all three answers, from itself
-- =====================================================================

-- His definition: "A on-ramp (come to me). A note option. A stage ratchet when
-- found. If it has children, it offloads that task to the one made."
local bid = Routes.Create("bare", 33)
local bare = Routes.AddBeacon(bid, node)
bare.stage = 1
bare.x, bare.y, bare.z = 2000, 2000, 60


-- =====================================================================
-- ★★★ §97: THE CONTROL REGISTRY AND THE PLAN STEPPER
-- =====================================================================

local UI = NS.UI    -- loaded up with object.lua now; see the note there
UI.Init()

-- ★ A registry entry is { frame, set, read } - which is why a SELECT is addressable
-- exactly like a button, and why `/click` was never enough.
local pressed, held = 0, nil
local fakeBtn = stub()
fakeBtn.Click = function() pressed = pressed + 1 end
UI.Register("t.btn", fakeBtn)
UI.Register("t.sel", stub(), { kind = "select",
    set = function(v) held = v end, read = function() return held end })

assert(UI.Click("t.btn") and pressed == 1, "a registered control is pressable by key")
assert(UI.Set("t.sel", "complete") and held == "complete",
       "A SELECT WAS NOT SETTABLE: an entry carries its own set, which is the whole "
       .. "reason this is a registry rather than /click")
assert(UI.Read("t.sel") == "complete", "and readable")

-- ⚠ AND A CONTROL WITH NO `set` MUST SAY SO. The first cut of this only ever set a
-- control that HAD one, so the not-settable branch was never reached and breaking it
-- passed the suite - reported SILENT by the harness. A plain button is the case.
local sok, serr = UI.Set("t.btn", "x")
assert(sok == nil and serr and serr:find("not settable"),
       "A SELECT WAS NOT SETTABLE: a control without a set must report it rather "
       .. "than claim success - a test line that silently did nothing reads as a pass")

-- ⚠⚠ §97.1: A REGISTRATION THAT GOT NIL NAMES ITSELF. The first live run reported
-- 15 controls where 16 were written - `promoter.create` was registered forty lines
-- above the button it names, so it received nil. The COUNT showed a gap; finding
-- WHICH meant reading the source, which is the work this is supposed to remove.
UI.Register("t.missing", nil)
local misses = UI.Misses()

-- ★★ SPLIT §330, because this one assertion was carrying two claims and only one of
-- them was on purpose. `UI.Misses()` returns the LIVE module-level table that EVERY
-- registrant appends to - object.lua included.
--
-- ⚠ Before §322, object contributed ZERO registration attempts, so `misses` was
-- guaranteed empty here and `#misses == 1` was VACUOUSLY TRUE. It could not have failed
-- for any reason involving object.lua. Now it is downstream of ~29 real registrations,
-- so it transitively asserts that OBJECT'S BLOCK HAS NO NIL FRAMES - a genuine §97.1
-- check that arrived by accident when the load order moved.
--
-- ★ Split so a failure NAMES WHICH ONE broke, rather than reading as the t.missing
-- test having gone wrong.
local strays = {}
for _, k in ipairs(misses) do
    if k ~= "t.missing" then strays[#strays + 1] = k end
end
assert(#strays == 0,
       ("A REGISTRATION GOT A NIL FRAME: %s. §97.1 - a control registered ABOVE the "
        .. "widget it names receives nil and returns nil. This assertion only became "
        .. "capable of catching that when the load order was fixed"):format(
           table.concat(strays, " ")))

assert(#misses == 1 and misses[1] == "t.missing",
       "A NIL FRAME REGISTERED SILENTLY: a count says something is missing, a name "
       .. "says what - and registration order is a standing hazard, not a one-off")
local listed = table.concat(UI.List(), " ")
assert(listed:find("NOT REGISTERED"),
       "and the miss appears in the list, where anyone would look for it")

-- ⚠ A MISSING CONTROL IS NAMED, not silently ignored. That is the difference
-- between a gap you can see in `/dr ui list` and a test line that does nothing.
local ok, err = UI.Click("t.nope")
assert(ok == nil and err and err:find("no such control"),
       "AN UNKNOWN KEY WAS SILENT: a test line that does nothing looks like a pass")

-- ⚠ And "cannot be read" is a DIFFERENT answer from "read as nil".
local v, e = UI.Read("t.btn")
assert(v == nil and e and e:find("not readable"),
       "not-readable and read-as-nil must not collapse into one answer")

-- ★★★ EVERY STEP RECORDS WHAT IT EXPECTED AND WHAT IT GOT - BOTH, EVEN WHEN THEY
-- MATCH. His: a step recording only "passed" cannot be re-examined when the run as a
-- whole turns out to be wrong.
UI.PlanClear()
UI.PlanAdd("set", "t.sel", "set")
UI.PlanAdd("read", "t.sel", nil, "set")
UI.PlanAdd("read", "t.sel", nil, "complete")      -- deliberately wrong
assert(UI.PlanSize() == 3, "three steps seeded")

local s1 = UI.Step(1)
assert(s1.actual == "set" and s1.ok, "a set records what it set")
local s2 = UI.Step(2)
assert(s2.actual == "set" and s2.expect == "set" and s2.ok,
       "A MATCHING STEP DID NOT RECORD ITS ACTUAL: both halves are kept, or the run "
       .. "cannot be re-examined")
local s3 = UI.Step(3)
assert(s3.ok == false and s3.actual == "set",
       "A WRONG STEP MUST KEEP WHAT IT ACTUALLY GOT, not just that it failed")

-- ★★ BY EXCEPTION: the summary names the failures and stays quiet about the rest.
local sum = UI.Summary()
assert(#sum.failed == 1, "one failure named, two matches unmentioned")
assert(sum.failed[1]:find("t.sel"), "and it names the control")

-- ⚠ A shot is RECORDED AS REQUESTED, never as landed - addon Lua cannot read files
-- from disk, so the client can only ever claim it asked.
UI.PlanClear()
UI.PlanAdd("shot", nil, nil, nil, "the child pane")
local sh = UI.Step(1)
assert(sh.actual == "requested",
       "THE CLIENT CLAIMED A SHOT LANDED: it cannot see the filesystem, so the only "
       .. "honest record is that it asked")
assert(UI.Summary().shotsRequested == 1, "and the count is of REQUESTS")


-- =====================================================================
-- ★★★ §99: ZONES - the orphan class made UNREPRESENTABLE
-- =====================================================================

load("layout.lua")
local Layout = NS.Layout

-- ★ A parent that can make textures and font strings, and remembers what it made.
local pane = stub()
pane.CreateTexture = function() return stub() end
pane.CreateFontString = function() return stub() end

local isChild = function(s) return s ~= "child" end

local detect = Layout.NewZone(pane, "detect",
    { header = "detect", hidden = isChild })
local roleDD, setBox = stub(), stub()
Layout.AddRow(detect, { { roleDD, 56 }, { setBox, 160 } })
Layout.AddRow(detect, { { stub(), 56 } },
    { hidden = function(s) return s ~= "child" end })

-- ★★★ THE WHOLE CLAIM: a zone that does not apply hides its DIVIDER, its HEADER and
-- its ROWS together, because they are one declaration. `behaviour` orphaned because
-- it was none of those things - a local at a fixed y that nothing could reach.
Layout.Apply({ detect }, "beacon", 18, -100, 204)
assert(detect.rule:IsShown() == false,
       "THE DIVIDER SURVIVED ITS ZONE: that is the orphan class, and it is the exact "
       .. "bug on screen - a rule with nothing beneath it")
assert(detect.label:IsShown() == false,
       "THE HEADER SURVIVED ITS ZONE: `behaviour` is this, and it survives EVERY pane "
       .. "state including the empty one")
assert(roleDD:IsShown() == false, "and the rows go with them")

-- ★ Present for the subject it applies to.
Layout.Apply({ detect }, "child", 18, -100, 204)
assert(detect.rule:IsShown() and detect.label:IsShown() and roleDD:IsShown(),
       "and a zone that DOES apply shows all three")

-- ⚠ A SKIPPED ROW LEAVES NO HOLE. The stack is computed from what is PRESENT, not
-- from what was planned - otherwise hiding a row leaves a gap that reads as a bug.
local z2 = Layout.NewZone(pane, "z2", { header = "h" })
local a, b = stub(), stub()
Layout.AddRow(z2, { { a, 0 } }, { hidden = function() return true end })
Layout.AddRow(z2, { { b, 0 } })
local endY = Layout.Apply({ z2 }, "child", 18, -100, 204)
local solo = Layout.NewZone(pane, "solo", { header = "h" })
Layout.AddRow(solo, { { stub(), 0 } })
local soloY = Layout.Apply({ solo }, "child", 18, -100, 204)
assert(endY == soloY,
       "A HIDDEN ROW LEFT A GAP: the stack must be computed from what is present, or "
       .. "hiding one row opens a hole that reads as a spacing bug")

-- ★ The height a pane needs is COMPUTED. A hand-sized pane grows a dead strip the
-- first time a zone is hidden and clips the first time one is added.
local tall = Layout.Height({ detect }, "child", 0)
local short = Layout.Height({ detect }, "beacon", 0)
assert(tall > short, "a pane sizes itself to what is actually shown")

-- =====================================================================
-- ★★★ §100: THE ZONE ENGINE'S OUTPUT, CHECKED AS ARITHMETIC RATHER THAN LOOKED AT
--
-- Everything above asserts the engine's LOGIC - what hides with what, that a skipped
-- row leaves no hole. ⚠ None of it can see a COLLISION or a CLIP, because the stub
-- discards the numbers. This runs the same engine on frames that KEEP them.
--
-- ★★ His: *"If their programming can construct the frames off-line. Then they have
-- the shape of how. And we have the client on access. So we don't have to keep going
-- back and forth."* This is that, at the smallest useful size: the overlap and the
-- overhang become a test rather than a screenshot.
-- =====================================================================

-- ⚠ IN ITS OWN FUNCTION, and the reason is a real Lua 5.1 limit rather than style:
-- a chunk may hold 200 active locals and this file was already near it. The first
-- cut failed to COMPILE with *"main function has more than 200 local variables"* -
-- which is the interpreter telling the truth about the client's own runtime.
-- ⚠ The leading `;` is required: without it Lua reads the previous line and this
-- `(` as one call expression - *"ambiguous syntax (function call x new statement)"*.
;(function()

local FR = assert(loadfile([[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\tools\smoke\frames.lua]]))()
FR.Reset()

-- ⚠⚠ THE PANE'S REAL SIZE, READ FROM `object.lua` AT RUN TIME - and the comment that
-- used to sit here is why it now has to be.
--
-- It said: *"read from object.lua:397 rather than assumed... the pane is 240x330"*.
-- It was true when written. §104 then grew the pane to 600 and this number stayed,
-- ★ so a claim of PROVENANCE outlived the fact it was about - which is worse than an
-- obviously typed constant, because the comment tells the next reader not to check.
-- Every "no overlaps" this block printed since §104 was computed on a canvas 270px
-- shorter than the pane, and a control below y=-330 could not be reported as outside.
--
-- ⚠ A LINE NUMBER IN A COMMENT IS A POINTER THAT CANNOT BE FOLLOWED BY ANYTHING BUT A
-- HUMAN. So it reads the source instead: the numbers cannot drift from what ships,
-- and if the call is ever reshaped this goes LOUD rather than silently stale.
local PANE_W, PANE_H
do
    local src = assert(io.open([[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_DungeonRun\object.lua]]))
    local text = src:read("*a"); src:close()
    PANE_W = tonumber(text:match("f:SetWidth%((%d+)%)"))
    PANE_H = tonumber(text:match("f:SetHeight%((%d+)%)"))
    assert(PANE_W and PANE_H,
           "THE PANE'S SIZE COULD NOT BE READ FROM object.lua: the geometry check has "
           .. "no canvas, and a canvas guessed is a check that reports confidently "
           .. "about a container we do not have (A9.6)")
end
local realPane = FR.New("pane")
FR.SetRoot(realPane, PANE_W, PANE_H, 0, 0)

local function cell(name, w, h)
    local f = FR.New(name, realPane)
    f:SetSize(w, h)
    return f
end

local ident = Layout.NewZone(realPane, "identity", { header = "identity" })
Layout.AddRow(ident, { { cell("identity.name", 150, 20), 0 } })

local det = Layout.NewZone(realPane, "detect",
    { header = "detect", hidden = function(s) return s ~= "child" end })
Layout.AddRow(det, { { cell("detect.role", 90, 20), 56 },
                     { cell("detect.set", 60, 20), 160 } })

local zones = { ident, det }
Layout.Apply(zones, "child", 18, -40, 204)

local rects, holes = FR.Resolve(FR.All())
assert(#holes == 0,
       "SOMETHING IN THE PANE COULD NOT BE PLACED AT ALL: " ..
       (holes[1] and (holes[1].name .. " - " .. holes[1].why) or ""))

-- ★★★ THE ORPHAN CLASS, AS ARITHMETIC. `behaviour` sat six pixels from an unrelated
-- dropdown and nothing we owned could say so - a human found it in a screenshot.
local hits = FR.Overlaps(rects)
assert(#hits == 0, "THE ZONE ENGINE PRODUCED AN OVERLAP: " ..
       (hits[1] and ("%s over %s by %.0fx%.0f"):format(hits[1].a, hits[1].b,
                                                       hits[1].x, hits[1].y) or ""))

-- ★★★ THE CLIP, AS ARITHMETIC.
local box = { left = 0, right = PANE_W, top = 0, bottom = -PANE_H }
local out = FR.Outside(rects, box)
assert(#out == 0, "THE ZONE ENGINE PUT SOMETHING OFF THE PANE: " ..
       (out[1] and (out[1].name .. " " .. out[1].over) or ""))

-- ⚠ AND THE CHECK MUST HAVE TEETH ON THIS ENGINE'S OWN OUTPUT, not only on
-- hand-built rectangles. A 300-wide rule at x=18 on a 280 pane runs 38 off the
-- edge, and that is the shape of the bug that shipped.
Layout.Apply(zones, "child", 18, -40, 300)
-- ⚠ THE AMOUNT IS COMPUTED, NOT TYPED. It was hardcoded to the overhang on a 280
-- pane and broke the moment the real 240 was read in - an expectation that has to be
-- edited whenever a constant moves is one that will eventually be edited to whatever
-- the code says.
local wide = FR.Outside(select(1, FR.Resolve(FR.All())), box)
local want = ("right by %d"):format(18 + 300 - PANE_W)
local named = false
for _, o in ipairs(wide) do if o.over:find(want) then named = true end end
assert(named,
       "AN OVERHANGING DIVIDER WENT UNREPORTED: if the check cannot catch it on the "
       .. "engine's REAL output then passing above proves nothing")
Layout.Apply(zones, "child", 18, -40, 204)

-- ★★★ AND THE ONE HOLE WE REFUSE TO FILL NAMES ITSELF. A header sized by its text
-- has no width offline; that list is precisely what one measuring run in the client
-- turns into constants, and it is generated rather than remembered.
local todo = FR.Unmeasured(select(1, FR.Resolve(FR.All())))
assert(#todo >= 2,
       "NO UNMEASURED ELEMENT WAS REPORTED: the two zone headers are FontStrings "
       .. "sized by their text, and a model that claims to know their width is the "
       .. "exact thing the 2010 renderer got wrong")
local seenName = {}
for _, t in ipairs(todo) do
    assert(t.need:find("width"), "an unmeasured element must say WHAT it needs")
    -- ⚠ AND EACH MUST BE DISTINGUISHABLE. The first run listed `pane.fs` twice,
    -- because nameless FontStrings all took the same fallback. A list that cannot
    -- say WHICH label is not a shopping list - it is a count.
    assert(not seenName[t.name],
           "TWO UNMEASURED ELEMENTS SHARE A NAME (" .. tostring(t.name) .. "): the "
           .. "client run has to know which one it is measuring")
    seenName[t.name] = true
end

-- =====================================================================
-- ★★★ §101: THE WIREFRAME ITSELF, CHECKED IN ALL FOUR SUBJECT STATES
--
-- ⚠ FOUR, not three. "Nothing selected" is the state the orphaned heading survived
-- into, and it is the one that gets forgotten because it is the boring one.
-- =====================================================================
load("panespec.lua")
local Spec = NS.PaneSpec

-- ⚠⚠ THE PANE'S HEIGHT IS DERIVED, NOT DECREED - and the first run proved why. Held
-- at 400 the beacon wireframe ran 68 pixels past the bottom, which is the same
-- clipped-control class as the play button, just on the other axis. ★ `Layout.Height`
-- already computes what a subject needs; the pane has to USE it.
--
-- ★★ But "derived" is not "unbounded". A ceiling is stated here so a pane that grows
-- past what a screen can hold fails loudly rather than scrolling off the bottom -
-- 600 leaves room on the shortest resolution this client supports.
-- =====================================================================
-- ★★★ A10.3f · FOLD IN / FOLD OUT — a zone collapses to its HEADER and back.
--
-- ⚠⚠ FOLDED IS NOT HIDDEN. `hidden` is a function of the SUBJECT and omits the zone
-- entirely; FOLDED is the author's toggle and **the header stays**, because a fold you
-- cannot see is a section you cannot get back. ★ Merging them would lose the only thing
-- that distinguishes "does not apply here" from "I closed this".
-- =====================================================================
do
    local FZ = Layout.NewZone(FR.New("foldpane"), "z", { header = "a header" })
    local a, b = FR.New("a"), FR.New("b")
    Layout.AddRow(FZ, { { a, 0, 20 } })
    Layout.AddRow(FZ, { { b, 0, 20 } })

    assert(Layout.IsFolded(FZ) == false, "a zone starts unfolded")
    local openH = Layout.Height({ FZ }, "child", 0)

    assert(Layout.SetFolded(FZ, true) == true, "SetFolded returns the state it set")
    assert(Layout.IsFolded(FZ), "SetFolded did not take")
    local shutH = Layout.Height({ FZ }, "child", 0)

    assert(shutH < openH,
           ("A FOLDED ZONE STILL TAKES ITS ROWS' HEIGHT: %d folded vs %d open. A fold that "
            .. "leaves the space is a fold nobody would use"):format(shutH, openH))
    -- ⚠⚠ SHOWN, not merely EXISTING. A first cut asserted `FZ.label and FZ.rule` and
    -- mutation walked straight through it: hiding the header does not DESTROY it, so the
    -- row was green while the fold behaved exactly like a hide. ★ The frame model tracks
    -- `IsShown`, so the visible thing can be asserted rather than the object.
    assert(FZ.label and FZ.label:IsShown() and FZ.rule and FZ.rule:IsShown(),
           "THE HEADER WAS HIDDEN BY FOLDING: it must stay ON SCREEN - that is what makes "
           .. "this a FOLD and not a HIDE, and it is the only handle left to unfold from")
    assert(FZ.rows[1].cells[1].frame:IsShown() == false,
           "A FOLDED ZONE'S ROWS ARE STILL SHOWN")

    -- ★★ AND UNFOLDING RESTORES EXACTLY, because nothing was rebuilt. A10.3f's mutation
    -- is *"rebuild the section on unfold from defaults → a set value is lost"*, so the row
    -- that matters is that the FRAMES are the same frames.
    local rowFrames = { FZ.rows[1].cells[1].frame, FZ.rows[2].cells[1].frame }
    Layout.SetFolded(FZ, false)
    assert(Layout.Height({ FZ }, "child", 0) == openH,
           "UNFOLDING DID NOT RESTORE THE ZONE's HEIGHT")
    assert(FZ.rows[1].cells[1].frame == rowFrames[1]
           and FZ.rows[2].cells[1].frame == rowFrames[2],
           "UNFOLDING REBUILT THE ROWS: A10.3f says *folding changes nothing about what is "
           .. "stored*, and a rebuilt section comes back from DEFAULTS - the author's value "
           .. "is gone and the pane looks fine")

    -- ⚠ A HEADERLESS ZONE CANNOT FOLD, and refusing is better than folding it: with
    -- nothing left on screen it would read as `hidden`, which is the one distinction here.
    local NZ = Layout.NewZone(FR.New("nohead"), "n", {})
    Layout.AddRow(NZ, { { FR.New("c"), 0, 20 } })
    assert(Layout.Foldable(NZ) == false,
           "A HEADERLESS ZONE REPORTED ITSELF FOLDABLE: with no header there is nothing "
           .. "left on screen to unfold FROM, so folding it is indistinguishable from "
           .. "`hidden` - the one distinction this mechanism exists to keep")
    local nOpen = Layout.Height({ NZ }, "child", 0)
    Layout.SetFolded(NZ, true)
    assert(Layout.Height({ NZ }, "child", 0) == nOpen,
           "A HEADERLESS ZONE FOLDED ANYWAY: it would vanish with no handle to bring it "
           .. "back, which is indistinguishable from `hidden` - the distinction this whole "
           .. "mechanism exists to keep")
end

-- ★★★ THE CEILING IS THE BOLT-ON COLUMN'S, NOT `object.lua`'s PANE (RI-46, A10.9f).
--
-- ⚠⚠ IT WAS 600 AND 600 WAS THE WRONG BUDGET. §444 measured the object group at 714 and
-- called it an overflow; RI-46 answered that the premise was wrong — *"the pane does NOT
-- have to hold everything · 600 is NOT the side panel's budget"*. A10.9f: the bolt-on
-- **has the MAP SURFACE'S vertical extent**, sized to fit the largest content.
--
-- ★ DERIVED, NOT TYPED, from the two files that own the numbers:
--
--     map.lua:61        ART_H                            668   the COORDINATE space
--     options.lua:57    MAP_STRIP + MAP_FOOT        40 + 14     the map's own chrome
--     options.lua:75    MapFloor() -> h + STRIP + FOOT   722   what the column runs beside
--
-- ⚠ A TYPED 722 WOULD ROT THE DAY EITHER MOVES, which is exactly how 600 became wrong
-- while nothing noticed. The arithmetic is repeated here rather than the answer.
local ART_H = 668                      -- map.lua:61
local MAP_STRIP, MAP_FOOT = 40, 14     -- options.lua:57
local MAX_PANE = ART_H + MAP_STRIP + MAP_FOOT
local heights = {}

for _, subject in ipairs(Spec.SUBJECTS) do
    FR.Reset()
    local p = FR.New("pane")
    FR.SetRoot(p, PANE_W, MAX_PANE, 0, 0)
    local zs = Spec.Build(Layout, p, function(key, kind, w, h)
        local fr = FR.New(key, p)
        -- ★ A text cell has a declared width here but its HEIGHT is still the
        -- client's business; giving it one would be the invented-font-metric again.
        if kind == "text" then fr:SetWidth(w) else fr:SetSize(w, h) end
        return fr
    end)
    local need = Layout.Height(zs, subject, Spec.top)
    heights[subject] = need
    -- ⚠ THE CEILING IS ASSERTED AT THE BOTTOM OF THIS LOOP, not here. Building on the
    -- template's control heights instead of our own makes the pane taller AND makes
    -- the controls the wrong size, so a ceiling check up front fires first and the
    -- size assertion it was meant to prove never runs. Precise assertion first.

    -- ★ Apply AFTER measuring, so what is checked is what a pane sized to `need`
    -- would actually draw.
    Layout.Apply(zs, subject, Spec.x, Spec.top, Spec.width)

    local rs = select(1, FR.Resolve(FR.All()))
    local ov = FR.Overlaps(rs)
    assert(#ov == 0, ("THE WIREFRAME OVERLAPS IN '%s': %s over %s by %.0fx%.0f")
        :format(subject, ov[1] and ov[1].a or "", ov[1] and ov[1].b or "",
                ov[1] and ov[1].x or 0, ov[1] and ov[1].y or 0))

    -- ⚠ THE CONTENT COLUMN, not the frame. A control inside the pane but past the
    -- column edge is the clipped-button class, and checking against the frame would
    -- miss it by the width of the margin.
    local col = { left = Spec.x, right = Spec.x + Spec.width, top = 0, bottom = -need }
    local off = FR.Outside(rs, col)
    assert(#off == 0, ("THE WIREFRAME RUNS OFF THE COLUMN IN '%s': %s %s")
        :format(subject, off[1] and off[1].name or "", off[1] and off[1].over or ""))

    -- ⚠⚠ AND THE CONTROLS MUST BE THE SIZE THIS PANE ACTUALLY MAKES THEM. Dropping
    -- `Spec.H` was SILENT through every check above - the pane grew on the template's
    -- numbers and still fitted, so a wireframe of a pane we do not have passed. ★ The
    -- mutation found a weak TEST, which is the usual yield.
    if subject == "child" then
        local byName = {}
        for _, r in ipairs(rs) do byName[r.name] = r end
        -- `object.lua:434` sizes the chip 20x20; the client's own checkbox is 26.
        assert(byName["object.move"] and byName["object.move"].h == 20,
               "THE MOVE CHIP IS NOT 20 TALL: object.lua sizes it itself, and checking "
               .. "it at the template's 26 checks a pane that does not exist")
        -- `object.lua:634` sets only the WIDTH, so the dropdown keeps the
        -- template's 32 - the tallest thing in the pane.
        assert(byName["object.role"] and byName["object.role"].h == 32,
               "THE DROPDOWN IS NOT 32 TALL: UIDropDownMenu_SetWidth sets the width "
               .. "only, so the template's height is what the row has to carry")
        FR.Emit([[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\staging\pane_rects.lua]],
                rs, {})
    end

    assert(need <= MAX_PANE, ("THE PANE FOR '%s' NEEDS %d, PAST THE %d CEILING")
        :format(subject, need, MAX_PANE))
end

-- ★★★ AND THE PANE MUST ACTUALLY CHANGE SIZE, or "derived" is a word rather than a
-- behaviour. A beacon shows children and no detect; a child shows detect and action
-- and no children; nothing selected shows one line. Three different heights, or one
-- of the zone predicates is not doing anything.
assert(heights.child ~= heights.beacon and heights.none < heights.child,
       ("THE PANE IS THE SAME HEIGHT FOR DIFFERENT SUBJECTS: none=%d note=%d "
        .. "beacon=%d child=%d - a zone that hides must take its space with it")
       :format(heights.none, heights.note, heights.beacon, heights.child))

-- ⚠ THE INVENTORY IS EMITTED BY THE WIREFRAME LOOP ABOVE, for the `child` state.
-- An earlier emit here overwrote it with the two-zone fixture and `pane_audit.py`
-- drew that instead - a stale artefact that looked exactly like a fresh one.

end)()

-- =====================================================================
-- ★★★ A2.4 — TWO DOORS, ONE FIELD. Proved on the REAL pane (§322).
--
-- This belongs here rather than in `smoke_dungeonrunroutes.lua` for one reason: the
-- claim is about two SURFACES agreeing, and that smoke has no pane. Asserting it there
-- would reduce to "one setter writes one field", which is true of any single function
-- and proves nothing about the doors.
--
-- ⚠ The model asks for the beacon-with-children to be the SCENE MANAGER - *"displays
-- and edits the ORDINAL of its children from that same surface… Each child is still
-- edited on its OWN pane"* (§1). Two doors is the design; one FIELD is the guarantee.
-- =====================================================================
local a24Route = Routes.Create("A2.4 two doors", 33)
local a24Beacon = Routes.AddBeacon(a24Route, node, 1)
local a24KidA = Routes.AddChildFromNode(a24Route, a24Beacon, node)
local a24KidB = Routes.AddChildFromNode(a24Route, a24Beacon, node)
Routes.SetChildOrdinal(a24Beacon, a24KidA, 1)
Routes.SetChildOrdinal(a24Beacon, a24KidB, 2)

-- DOOR ONE: the BEACON's pane. Select the parent and drive its roster.
Map.Select(a24Beacon)
Object.Refresh()
-- ★★★ A9.1's SECOND CRITERION, HALF TWO: THE REGISTRATION ACTUALLY EXECUTED.
--
-- ⚠⚠ `check_interface.py` counts registrations by REGEX OVER SOURCE and reports
-- 105 of 105. That count is byte-identical whether `R` is a function or nil, and it
-- never opens this file - so it supplied POSITIVE EVIDENCE for a claim that was false
-- in the harness. A static count of a dynamic act measures the wrong thing.
--
-- ★ This is the runtime half: ask the registry what it actually HOLDS. A source scan
-- cannot answer it and this cannot be fooled by one.
local liveKeys = UI.Keys and UI.Keys() or {}
local objectLive = 0
for _, k in ipairs(liveKeys) do
    if k:sub(1, 7) == "object." then objectLive = objectLive + 1 end
end
assert(objectLive >= 20,
       ("OBJECT REGISTERED %d CONTROLS AT RUNTIME: the source says ~29 and a static "
        .. "count cannot tell the difference. This is the check that could have caught "
        .. "§322 and did not exist"):format(objectLive))

assert(UI.Set("object.kid.ordinal.1", "5"),
       "the beacon's roster row must be settable - an unregistered control is one no "
       .. "smoke can drive, which is how `up` and `down` went untested for a version")
assert(a24KidA.ordinal == 5,
       "THE PARENT'S SURFACE DID NOT REACH THE CHILD'S FIELD: the roster row holds a "
       .. "reference to its child and calls Routes.SetChildOrdinal - if this fails the "
       .. "roster is drawing a number it does not own")

-- DOOR TWO: the CHILD's own pane. Select the child and drive its box.
Map.Select(a24KidA)
Object.Refresh()
assert(UI.Read("object.ordinal") == "5",
       "THE CHILD'S PANE DISAGREED WITH THE PARENT'S: it must READ the same field, not "
       .. "hold its own copy - that is the whole of 'one home'")
assert(UI.Set("object.ordinal", "7"))
assert(a24KidA.ordinal == 7, "and writing from the child's own door lands in the same spot")

-- ...and the parent sees it, because there is nowhere else for it to have gone.
--
-- ⚠⚠ AND THE ROW IS FOUND, NEVER ASSUMED. My first cut read row 1 and expected A's
-- value - which assumes INSERTION order three lines above the assertion that the
-- roster reads in ORDINAL order. A took 7, B holds 2, so B leads and row 1 is B.
-- ★ The mistake is worth keeping in view: an assertion that contradicts the property
-- it sits beside passes only while the fixture happens to agree with it.
Map.Select(a24Beacon)
Object.Refresh()
local rowOfA
for i, c in ipairs(Routes.ChildrenOf(a24Beacon)) do
    if c == a24KidA then rowOfA = i end
end
assert(rowOfA, "A must appear in its parent's roster at all")
assert(UI.Read(("object.kid.ordinal.%d"):format(rowOfA)) == "7",
       "THE PARENT DID NOT SEE THE CHILD'S EDIT: two doors that do not agree are two "
       .. "fields wearing one name, which is exactly what A2.4 forbids")

-- ★ AND THE ROSTER REORDERS UNDER THE AUTHOR. B (2) now leads A (7). A roster pinned
-- to mint order would let someone edit the wrong child while looking at the right
-- number - the roster and `ChildrenOf` must agree on what "row 1" means.
assert(Routes.ChildrenOf(a24Beacon)[1] == a24KidB and rowOfA == 2,
       "ChildrenOf must lead with the LOWER ordinal, and the roster must follow it")

-- ★ AND THE CAP IS TOLD. A beacon may hold more children than the pool has rows;
-- silence would read as "that is all of them" to the one person who needs otherwise.
for _ = 1, 8 do Routes.AddChildFromNode(a24Route, a24Beacon, node) end
Object.Refresh()
local more = UI.Read("object.kid.more")
assert(more and more:find("more not shown"),
       "AN OVERFLOWING ROSTER WENT SILENT: a truncated list that says nothing is a "
       .. "pane asserting a count it did not check")
-- =====================================================================
-- ★★ A4 / G1 - THE ROUTE NOTE'S PANE DOOR (§346).
--
-- The model smoke proves the store. This proves the only thing it cannot: that the
-- author's box is REGISTERED and reaches that store. §322 is the standing reason -
-- twenty registrations were silent no-ops and every model-side test still passed.
-- =====================================================================
-- ⚠ THE FIXTURE ROUTE HAS TO BE THE LOADED ONE. The pane resolves its route from
-- `Map.LoadedId("route")`, not from the subject - the A2.4 rows above never needed it
-- because an ordinal is reached through parent+child alone. A note is addressed
-- `RID:BID:CID`, so the R has to be real, and this smoke found that by going red.
local g1Was = Map.LoadedId("route")
Map.Load("route", a24Route)
assert(Map.LoadedId("route") == a24Route, "the fixture route must load before the pane "
       .. "can address a note in it")

local g1Kid = assert(Routes.AddChildFromNode(a24Route, a24Beacon, node), "AddChild nil")
Map.Select(g1Kid)
Object.Refresh()

-- ★ A4.3 first: NOTHING RENDERS for a child with no note. The ghost is not the note -
-- it is the field saying what it is for, and it must not read back as a value.
assert(UI.Read("object.note") == "",
       "AN UNSET NOTE READ AS TEXT: the ghost is a separate FontString precisely so the "
       .. "box returns nothing - placeholder text inside the box would be a hint the "
       .. "setter then stores as the author's note")
assert(UI.Read("object.note.ghost") ~= "",
       "THE GHOST WAS ABSENT ON AN EMPTY FIELD: an unlabelled empty box asks the author "
       .. "to guess who the note is for, which is the confusion RI-10 de-conflated")

assert(UI.Set("object.note", "bring the torch, LOS at the pillar"),
       "the note box must be settable - an unregistered control is one no smoke can "
       .. "drive, and it renders identically to a working one")
assert(Routes.RouteNoteOf(a24Route, a24Beacon, g1Kid) == "bring the torch, LOS at the pillar",
       "THE PANE DID NOT REACH THE STORE: the box is a door onto the route-note plane, "
       .. "not a field of its own")

Object.Refresh()
assert(UI.Read("object.note") == "bring the torch, LOS at the pillar",
       "and it reads back from the store on refresh")
assert(UI.Read("object.note.ghost") == "",
       "THE GHOST STAYED UP OVER A WRITTEN NOTE: it would print through the author's "
       .. "own words")

-- ⚠ AND THE PANE'S OWN DOOR CAPS. `SetMaxLetters` guards typing; the registry does not
-- pass through it, so the STORE has to - which is the assertion that keeps both doors
-- honest rather than trusting the widget.
UI.Set("object.note", string.rep("y", 400))
assert(#Routes.RouteNoteOf(a24Route, a24Beacon, g1Kid) == Routes.NOTE_MAX,
       "THE REGISTRY DOOR BYPASSED THE CAP: SetMaxLetters is the box's rule and the "
       .. "registry never touches the box")

-- ★ A BEACON HAS NO ROUTE NOTE. The note is keyed BY THE CHILD (§24) - so the field is
-- not merely empty on a beacon, it is not there.
Map.Select(a24Beacon)
Object.Refresh()
assert(UI.Read("object.note") == "",
       "A BEACON'S PANE SHOWED A CHILD'S NOTE: the field belongs to the child plane and "
       .. "a beacon has no address in it")

Routes.SetRouteNote(a24Route, a24Beacon, g1Kid, nil)
Routes.DeleteChild(a24Beacon, g1Kid)
Map.Load("route", g1Was)

Map.Select(nil)

print("smoke_dungeonrunpromoter: OK")
