-- Offline smoke for COA_DungeonRun map.lua - display stage one.
--
-- The frame code is thin on purpose; the parts that can be SILENTLY wrong are the
-- selection and the arithmetic, and those are pure functions here so they can be
-- asserted without a UI:
--
--   Map.RunsFor    picks the wrong runs -> an empty map on a dungeon you recorded
--   Map.PointsOn   picks the wrong floor -> a trail drawn on the wrong level
--   Map.Offset     flips an axis -> a mirrored route that still looks like a route
--   Map.TilePath   builds the wrong path -> a blank canvas with no error
--
-- Every one of those produces something that LOOKS like a working display.

local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }

local W = { mapID = 33, floor = 6, here = "ShadowfangKeep" }
function UnitName() return "Gravekeeper" end
function GetCurrentPlayerPosition() return 1, 2, 3, W.mapID end
function GetCurrentMapDungeonLevel() return W.floor end
function GetMapInfo() return W.here, 668, 768 end
function GetRealZoneText() return "Shadowfang Keep" end
function GetSubZoneText() return "" end
function time() return 1786600000 end
function GetTime() return 100.0 end
UIParent = {}

-- Frame stub: the methods map.lua actually uses are real, anything else no-ops so
-- the test fails on LOGIC rather than on chrome. Textures record what was set,
-- which is how we prove paint() ran at all.
local function stub()
    local o = { _points = {}, _shown = false }
    -- Underscore keys are DATA (nil when unset); everything else is a no-op
    -- method. Without that split, `self._textures or {}` gets a function back and
    -- the stub fails in a way that says nothing about the code under test.
    local mt = { __index = function(_, k)
        if type(k) == "string" and k:sub(1, 1) == "_" then return nil end
        return function() end
    end }
    function o:SetWidth() end
    function o:SetHeight() end
    function o:SetPoint(...) self._points[#self._points + 1] = { ... } end
    function o:ClearAllPoints() self._points = {} end
    function o:SetScript(k, fn) self[k] = fn end
    function o:Show() self._shown = true end
    function o:Hide() self._shown = false end
    function o:IsShown() return self._shown end
    -- Real frames always return a number here; the no-op fallback would give nil
    -- and the failure would look like a bug in styleDot rather than in the stub.
    function o:GetFrameLevel() return self._level or 1 end
    function o:SetFrameLevel(n) self._level = n end
    function o:SetText(t) self._text = t end
    function o:GetText() return self._text end
    function o:SetTexture(t) self._tex = t end
    function o:SetTexCoord(...) self._coord = { ... } end
    function o:CreateTexture() local t = stub(); self._textures = self._textures or {}
        self._textures[#self._textures + 1] = t; return t end
    function o:CreateFontString() return stub() end
    return setmetatable(o, mt)
end
function CreateFrame() return stub() end

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_DungeonRun\]]
local NS = {}
NS.Say = function(m) DEFAULT_CHAT_FRAME:AddMessage(m) end
local function load(f) assert(loadfile(ROOT .. f))("COA_DungeonRun", NS) end
load("store.lua")
load("map.lua")
local Store, Map = NS.Store, NS.Map

for _, leaked in ipairs({"paint", "context", "step", "ensureDots", "clearDots",
                         "TILE_COLS", "DOT_PX", "ART_W"}) do
    assert(_G[leaked] == nil, "LEAKED GLOBAL: " .. leaked)
end

-- =====================================================================
-- Map.TilePath - M7: the floor is a SUFFIX, and only when > 0
-- =====================================================================
assert(Map.TilePath("Ragefire", 0, 1) == "Interface\\WorldMap\\Ragefire\\Ragefire1",
       "floor 0 -> no suffix, got " .. tostring(Map.TilePath("Ragefire", 0, 1)))
assert(Map.TilePath("ShadowfangKeep", 6, 12)
       == "Interface\\WorldMap\\ShadowfangKeep\\ShadowfangKeep6_12",
       "floor 6 -> the <file><floor>_ form, got " .. tostring(Map.TilePath("ShadowfangKeep", 6, 12)))
assert(Map.TilePath(nil, 1, 1) == nil, "no tile art -> no path (a pre-DR-34 run)")
assert(Map.TilePath("", 1, 1) == nil, "empty tile art is the same as none")

-- =====================================================================
-- Map.Offset - mapY runs DOWNWARD, so y is negated
-- =====================================================================
local x, y = Map.Offset({ mapX = 0.25, mapY = 0.75 }, 1024, 768)
assert(x == 256, "mapX scales across the width, got " .. tostring(x))
assert(y == -576, "AXIS FLIPPED: mapY must be NEGATED from TOPLEFT, got " .. tostring(y))
assert(Map.Offset({ mapX = 0, mapY = 0 }, 1024, 768) == 0, "fraction 0 is the top-left corner")
assert(Map.Offset({ x = 1, y = 2 }, 1024, 768) == nil,
       "a point with no fraction is not placeable and must return nil, not 0")

-- =====================================================================
-- ★ THE TWO SIZES. Conflating them is a SILENT scale error: the trail still
-- follows corridors, and is wrong everywhere - worst furthest from the origin.
--
-- WorldMapFrame.xml:528  WorldMapDetailFrame  1002 x 668  <- the coordinate space
-- WorldMapFrame.xml:541  WorldMapDetailTile   256 x 256, 4x3 = 1024 x 768 (art)
--
-- Caught by eye on the first art-bearing draw, not by any test - which is why
-- there is now a test.
-- =====================================================================
local aw, ah = Map.ArtSize()
assert(aw == 1002 and ah == 668,
       ("SCALE: fractions map across the DETAIL FRAME 1002x668, got %sx%s"):format(aw, ah))
local gw, gh = Map.TileGrid()
assert(gw == 1024 and gh == 768, "the ART grid is 4x3 tiles of 256")
assert(gw ~= aw and gh ~= ah,
       "the two sizes are DIFFERENT - if they ever match, one of them is wrong")

-- =====================================================================
-- ★ MARKER ART. Getting this wrong is SILENT: every wrong answer still renders
-- a legible marker in the right PLACE, and only someone reading the route can
-- tell it lied about what happened there.
-- =====================================================================
assert(Map.ArtKey({ kind = "start" }) == "start", "a pull start")
assert(Map.ArtKey({ kind = "end" }) == "done", "combat ended and we walked away")
assert(Map.ArtKey({ kind = "end", dead = true }) == "dead",
       "TERMINAL STOP: dead is checked FIRST - it is the more specific claim")
assert(Map.ArtKey({}) == "leg", "no kind -> a travel sample")
assert(Map.ArtKey(nil) == "leg", "no point -> a travel sample, not an error")
assert(Map.ArtKey({ kind = "start", dead = true }) == "start",
       "dead only qualifies an END - a start is a start")

-- The four crops must be DISTINCT, or two states render identically and the
-- display lies quietly.
local seen = {}
for _, k in ipairs({ "leg", "start", "end-alive", "end-dead" }) do
    local pt = ({ leg = {}, start = { kind = "start" },
                  ["end-alive"] = { kind = "end" },
                  ["end-dead"] = { kind = "end", dead = true } })[k]
    local l, r, t, b, dw, dh = Map.ArtForPoint(pt)
    local sig = table.concat({ l, r, t, b }, ",")
    assert(not seen[sig], "DUPLICATE ART: " .. k .. " shares a crop with " .. tostring(seen[sig]))
    seen[sig] = k
    assert(dw > 0 and dh > 0, k .. " has a draw size")
end

-- A marker reads LARGER than a sample: a leg is a sample, a marker is an event.
local _, _, _, _, legW = Map.ArtForPoint({})
local _, _, _, _, markW = Map.ArtForPoint({ kind = "start" })
assert(markW > legW, "an EVENT must read larger than a SAMPLE, got " .. markW .. " vs " .. legW)

-- ★ Aspect ratio preserved. The swords cell is 37x35; drawing it square squashes
-- the glyph into something that reads as a different icon.
local _, _, _, _, sw, sh = Map.ArtForPoint({ kind = "start" })
assert(math.abs(sw / sh - 37 / 35) < 0.001,
       ("SQUASHED: 37x35 must keep its ratio, got %sx%s"):format(sw, sh))
local _, _, _, _, dw2, dh2 = Map.ArtForPoint({})
assert(math.abs(dw2 - dh2) < 0.001, "a 32x32 cell stays square")

-- =====================================================================
-- Store fixtures
-- =====================================================================
assert(Store.Load())
local sfk = select(2, Store.Open("sfk"))
sfk.instance = { mapID = 33 }
sfk.mapFile = "ShadowfangKeep"
sfk.legs = {
    { mapX = 0.1, mapY = 0.1, floor = 6 },
    { mapX = 0.2, mapY = 0.2, floor = 6 },
    { mapX = 0.3, mapY = 0.3, floor = 5 },
    { x = 1, y = 1, floor = 6 },                 -- captured with the map open: no fraction
}
sfk.markers = { { mapX = 0.4, mapY = 0.4, floor = 6, kind = "start" } }

-- A run armed and stopped with nothing captured: no instance, no points, so no
-- mapID anywhere on it. Realistic (arm at the door, change your mind) and it is
-- the ONLY fixture that can catch a nil-vs-nil match - without it, `RunsFor(nil)`
-- returns empty for the wrong reason and the guard tests as dead code.
local stub = select(2, Store.Open("stub"))

local rfc = select(2, Store.Open("rfc"))
rfc.instance = nil                                -- pre-DR-30: no instance block
rfc.legs = { { mapX = 0.5, mapY = 0.5, mapID = 389 } }   -- pre-DR-33: no floor

-- =====================================================================
-- Map.PointsOn - the floor filter
-- =====================================================================
local on6 = Map.PointsOn(sfk, 6)
assert(#on6 == 3, "floor 6 = 2 legs + 1 marker, got " .. #on6)
local on5 = Map.PointsOn(sfk, 5)
assert(#on5 == 1, "WRONG FLOOR: floor 5 has exactly one point, got " .. #on5)
for _, p in ipairs(on6) do
    assert(p.mapX, "a point with no fraction was included - it cannot be placed")
end

-- A pre-DR-33 run has no floor at all. Those points match whatever floor is shown,
-- because on a single-floor map there is nothing to be ambiguous about.
assert(#Map.PointsOn(rfc, 0) == 1, "a floorless legacy point still draws")
assert(#Map.PointsOn(rfc, 3) == 1, "and it is not floor-filtered away")
assert(#Map.PointsOn(nil, 1) == 0, "no run -> no points, not an error")

-- =====================================================================
-- Map.RunsFor - identity, and the FALLBACK for runs with no instance block
-- =====================================================================
local mapFrame = Map.Init()
assert(mapFrame, "Init returns its frame")
assert(not mapFrame:IsShown(), "the map starts HIDDEN - it is opened deliberately")

-- Asserted on the run's NAME, not its generated id. An id embeds the creation
-- ORDER, so inserting a fixture above renumbers every expectation below - which
-- it just did. A test that has to be renumbered gets edited rather than believed.
local function nameOf(id) return (Store.Get(id) or {}).name end

local ids = Map.RunsFor(33)
assert(#ids == 1 and nameOf(ids[1]) == "sfk",
       "matched on instance.mapID, got " .. table.concat(ids, ","))
local rids = Map.RunsFor(389)
assert(#rids == 1 and nameOf(rids[1]) == "rfc",
       "FALLBACK FAILED: a run with no instance block must match on its POINTS' mapID")
assert(#Map.RunsFor(999) == 0, "an unrecorded map matches nothing")
assert(#Map.RunsFor(nil) == 0,
       "NIL MATCH: a nil mapID must match NOTHING - an empty run has a nil mapID too, "
       .. "so without the guard it would appear on every map")
for _, id in ipairs(Map.RunsFor(33)) do
    assert(nameOf(id) ~= "stub", "an empty run must not be offered for a real map")
end

-- =====================================================================
-- ★ Map.ArtFor - the IN-ZONE FALLBACK, and the identity guard on it
--
-- The first live draw produced correct dots on an EMPTY canvas: all three
-- exemplars predate DR-34, so they carry no mapFile. §22 promised those runs
-- would still draw IN ZONE, and stage one did not implement it.
-- =====================================================================
-- The fixture carries stored art, so it must be CLEARED to reach the fallback at
-- all. (The first version of this block did not, so every assertion passed
-- through the stored-art branch and the mutation harness reported the fallback's
-- removal as SILENT - the test could not tell the two paths apart.)
local stored = sfk.mapFile
sfk.mapFile = nil
assert(Map.ArtFor(sfk, 33, "ShadowfangKeep") == "ShadowfangKeep",
       "FALLBACK MISSING: no stored art + standing on that map -> ask the client")

sfk.mapFile = "StoredName"
assert(Map.ArtFor(sfk, 33, "SomewhereElse") == "StoredName",
       "STORED ART WINS: a DR-34 run must not be overridden by where you happen to stand")
sfk.mapFile = nil

-- ★ THE GUARD. Without it, opening a pre-DR-34 Shadowfang run while standing in
-- Ragefire draws Shadowfang's route onto RAGEFIRE'S ART - a picture that looks
-- entirely plausible and is completely wrong.
assert(Map.ArtFor(sfk, 389, "Ragefire") == nil,
       "WRONG-MAP ART: the fallback must be guarded on identity, not just presence")
assert(Map.ArtFor(sfk, nil, "Ragefire") == nil, "no current map -> no fallback")
assert(Map.ArtFor(sfk, 33, nil) == nil, "no client answer -> no art, not a guess")
assert(Map.ArtFor(nil, 33, "ShadowfangKeep") == nil, "no run -> no art")

-- Map.MapIDOf - instance first, then the run's own points
assert(Map.MapIDOf(sfk) == 33, "instance.mapID when present")
assert(Map.MapIDOf(rfc) == 389, "otherwise the mapID the points carry")
assert(Map.MapIDOf(stub) == nil, "an empty run has no map at all")
sfk.mapFile = stored

-- =====================================================================
-- ★ SELECTION - §34's ONE coupling point, and the isolation that justifies it
-- =====================================================================
-- A COUNTER, not a list: appending nil to a table is a no-op, so a list-based spy
-- cannot observe the clear-selection call at all - and clearing is exactly the
-- case that would leave a stale point on the pane.
local heard, lastHeard = 0, nil
local function spy(pt) heard = heard + 1; lastHeard = pt end
Map.SetOnSelect(spy)

local target = sfk.markers[1]
assert(Map.Select(target) == target, "Select returns what it selected")
assert(Map.Selected() == target, "and Selected reports it")
assert(heard == 1 and lastHeard == target,
       "CALLBACK NOT FIRED: the companion has no other way to know")

assert(Map.Select(nil) == nil, "selecting nothing is legal - it is how you clear")
assert(Map.Selected() == nil, "and it clears")
assert(heard == 2 and lastHeard == nil,
       "clearing must NOTIFY too, or the pane keeps showing a stale point")

-- ★ Map must hold NO reference to the editor. The callback is the whole contract:
-- with none registered, selecting still works. A map that needed the companion
-- would defeat the isolation the companion exists for.
Map.SetOnSelect(nil)
assert(Map.Select(target) == target, "selection works with NOTHING listening")
Map.SetOnSelect(spy)

-- =====================================================================
-- ★ Map.Describe - the pane's ENTIRE readout, so a wrong answer here mislabels
-- captured evidence and nothing else would catch it.
-- =====================================================================
local lbl, list = Map.Describe(nil)
assert(lbl == "nothing selected" and #list == 0, "no point -> no rows, not an error")

lbl = Map.Describe({ kind = "start", n = 3, x = 1, y = 2, z = 3 })
assert(lbl == "combat START", "a start says so, got " .. lbl)
assert(Map.Describe({ kind = "end", n = 3 }) == "combat end", "an end we walked away from")
assert(Map.Describe({ kind = "end", dead = true }) == "TERMINAL STOP",
       "a death is NOT 'combat end' - it is the one carrying route meaning")
assert(Map.Describe({}) == "travel sample", "a leg is a sample")

local _, r = Map.Describe({ kind = "end", dead = true, n = 7, x = 1, y = 2, z = 3,
                            mapX = 0.5, mapY = 0.25, floor = 2, zone = "Ragefire Chasm",
                            subZone = "", t = 1786595378,
                            killedBy = { "Molten Elemental", "Ragefire Trogg" } })
local got = {}
for _, kv in ipairs(r) do got[kv[1]] = kv[2] end
assert(got["pull"] == "7", "the pull index")
assert(got["floor"] == "2", "the floor")
assert(got["killed by"] == "Molten Elemental, Ragefire Trogg",
       "KILLED BY MISSING: it is the only route MEANING a marker carries")
assert(got["zone"] == "Ragefire Chasm", "subZone is empty, so the zone is shown")
assert(got["t"] == "1786595378", "the wall clock, DR-4")

local _, r2 = Map.Describe({ killedByUnavailable = "AscensionUI.DeathRecap absent" })
local seen2 = false
for _, kv in ipairs(r2) do if kv[1] == "attribution" then seen2 = true end end
assert(seen2, "a drift REASON must surface - a silent absence reads as 'nothing killed us'")

-- =====================================================================
-- Show: location seeds the view, and paint() actually ran
-- =====================================================================
W.mapID, W.floor = 33, 6
Map.Show()
assert(mapFrame:IsShown(), "SHOW FAILED: a recorded map must open the frame")

-- An unrecorded map says so rather than showing an empty frame
chat = {}
W.mapID = 999
Map.Show()
local said = false
for _, m in ipairs(chat) do if m:find("no run recorded", 1, true) then said = true end end
assert(said, "an unrecorded map must SAY so, not present a blank map")

print("smoke_dungeonrunmap: OK")
