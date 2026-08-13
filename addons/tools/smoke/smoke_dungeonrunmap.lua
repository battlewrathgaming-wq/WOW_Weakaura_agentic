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
    -- ★ The real SetTexture RESETS TexCoord (§19's trap, which has already cost us
    -- once). A stub that keeps the crop would let the smoke pass on code that
    -- re-crops only at Init - i.e. it would test the stub, not the addon.
    function o:SetTexture(t) self._tex = t; self._coord = nil end
    function o:SetTexCoord(...) self._coord = { ... } end
    function o:CreateTexture() local t = stub(); self._textures = self._textures or {}
        self._textures[#self._textures + 1] = t; return t end
    function o:CreateFontString() return stub() end
    return setmetatable(o, mt)
end
-- Every frame is recorded, so the smoke can reach what paint() did to the DOTS and
-- the TILES. Both are file-locals in map.lua and neither has a pure accessor - and
-- both carry a failure that is invisible from the outside (a marker buried under
-- 300 legs; art that silently un-crops itself).
local made = {}
function CreateFrame() local o = stub(); made[#made + 1] = o; return o end

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

-- =====================================================================
-- ★ THE PRECEDENCE LADDER. Not a display preference - it decides both what is
-- drawn on top AND what takes the CLICK, because frame level drives hit testing.
--
-- Battlewrath: "combat enter and terminal always win over combat exit. Enter is
-- more deterministic - it's where the mobs and you meet. Exit is just where you
-- was." Before the ladder every marker sat at one level and ties fell to list
-- order, which puts the EXIT last, i.e. on top: in a re-pull cluster you would
-- both draw and click the least meaningful marker of the group.
-- =====================================================================
assert(Map.Rank({ kind = "end", dead = true }) > Map.Rank({ kind = "start" }),
       "a TERMINAL STOP outranks a pull start - it is the only marker carrying a payload")
assert(Map.Rank({ kind = "start" }) > Map.Rank({ kind = "end" }),
       "ENTER OVER EXIT: enter is a fact about the ENCOUNTER, exit is a fact about you")
assert(Map.Rank({ kind = "end" }) > Map.Rank({}),
       "any marker outranks a travel sample")
-- Every art key must have a rank, or a point silently draws at level nil.
for _, pt in ipairs({ {}, { kind = "start" }, { kind = "end" },
                      { kind = "end", dead = true } }) do
    assert(type(Map.Rank(pt)) == "number", "every art key needs a rank")
end

-- =====================================================================
-- ★ Map.TileRect - the art cropped back to the COORDINATE SPACE.
--
-- The tiles are 1024x768 and the space is 1002x668, so the grid overhangs by 22
-- right and 100 bottom. That overhang is power-of-two padding which the stock
-- detail frame clips; cropping it buys the frame back and makes the canvas equal
-- what you see. The invariant is the one that matters: the cropped widths must
-- SUM to the coordinate space, not to the tile grid.
-- =====================================================================
local sumW, sumH = 0, 0
for c = 0, 3 do local _, _, w = Map.TileRect(1 + c); sumW = sumW + w end
for r = 0, 2 do local _, _, _, h = Map.TileRect(1 + r * 4); sumH = sumH + h end
assert(sumW == aw, ("cropped columns must sum to %d, got %d"):format(aw, sumW))
assert(sumH == ah, ("cropped rows must sum to %d, got %d"):format(ah, sumH))

local _, _, w1, h1, u1, v1 = Map.TileRect(1)
assert(w1 == 256 and h1 == 256 and u1 == 1 and v1 == 1, "an interior tile is not cropped")
local x4, y4, w4, _, u4 = Map.TileRect(4)
assert(x4 == 768 and y4 == 0, "tile 4 is the last COLUMN of the first row")
assert(w4 == 234 and math.abs(u4 - 234 / 256) < 1e-9,
       "the last column is cropped to the coordinate space, got " .. w4)
local _, y9, _, h9, _, v9 = Map.TileRect(9)
assert(y9 == 512, "tile 9 is the first column of the last ROW")
assert(h9 == 156 and math.abs(v9 - 156 / 256) < 1e-9,
       "the last row is cropped, got " .. h9)

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

-- ★ Map.FillTooltip - the readout's new home. "Map information should live on the
-- map. As the curator suite is going to pack a lot of content itself."
-- An empty tooltip is the map answering "what is this?" with SILENCE, and nothing
-- else on screen would catch it.
local tip = { head = {}, kv = {} }
function tip:AddLine(t) self.head[#self.head + 1] = t end
function tip:AddDoubleLine(k, v) self.kv[#self.kv + 1] = { k, v } end

assert(Map.FillTooltip(tip, { kind = "end", dead = true, n = 7, floor = 2,
                              zone = "Ragefire Chasm", subZone = "", t = 1786595378,
                              killedBy = { "Molten Elemental" } }),
       "a real point fills the tooltip")
assert(tip.head[1] == "TERMINAL STOP", "the label leads, got " .. tostring(tip.head[1]))
local tipHas = {}
for _, kv in ipairs(tip.kv) do tipHas[kv[1]] = kv[2] end
assert(tipHas["killed by"] == "Molten Elemental",
       "EVERY Describe row must reach the tooltip - it is the only readout now")
assert(tipHas["pull"] == "7" and tipHas["floor"] == "2", "and the rest of them")
assert(Map.FillTooltip(tip, nil) == false, "hovering nothing must not draw an empty tooltip")
assert(Map.FillTooltip(nil, { kind = "start" }) == false, "no tooltip -> nothing to fill")

local _, r2 = Map.Describe({ killedByUnavailable = "AscensionUI.DeathRecap absent" })
local seen2 = false
for _, kv in ipairs(r2) do if kv[1] == "attribution" then seen2 = true end end
assert(seen2, "a drift REASON must surface - a silent absence reads as 'nothing killed us'")

-- =====================================================================
-- ★ §36 - LOCATION SORTS THE LIST; IT NEVER CHOOSES THE VIEW.
-- =====================================================================
local list = Map.RunList(33)
assert(#list == 3, "every run is offered, wherever you stand - got " .. #list)
assert(list[1].name == "sfk" and list[1].here,
       "the runs for the dungeon you are STANDING IN come first")
assert(list[2].name == "rfc" and not list[2].here, "then the rest, alphabetical")
assert(list[3].name == "stub" and not list[3].here, "...and 'stub' sorts after 'rfc'")

-- Out of any instance there is no "here" group at all - the whole list is
-- alphabetical, which is exactly what he asked for.
local anywhere = Map.RunList(nil)
assert(anywhere[1].name == "rfc" and anywhere[2].name == "sfk",
       "no location -> pure alphabetical, got " .. anywhere[1].name)
for _, e in ipairs(anywhere) do
    assert(not e.here, "NOTHING is 'here' when you are nowhere")
end

-- =====================================================================
-- Map.SeedFloor - which floor a freshly loaded run opens on
-- =====================================================================
assert(Map.SeedFloor(sfk, 33, 6) == 6, "in its own dungeon, the floor you stand on")
assert(Map.SeedFloor(sfk, 389, 0) == 6,
       "LOADED FROM ELSEWHERE: the RUN's floor, not the one you happen to be on - "
       .. "otherwise editing from a city opens every run on floor 0")
assert(Map.SeedFloor(nil, nil, nil) == 0, "no run and nowhere -> the single-floor default")

-- =====================================================================
-- ★ Map.Caption - the strip's reference pair. The map name was nowhere on screen
-- before, and the art was the only evidence of which dungeon you were looking at -
-- which is exactly the path that can lie (a pre-DR-34 run borrows local art).
-- =====================================================================
local capName, capDetail = Map.Caption(nil, "Ragefire", 0)
assert(capName == "no run loaded", "no run says so, got " .. capName)
assert(capDetail:find("Ragefire", 1, true), "and still names the art it IS showing")
assert(capDetail:find("Curate", 1, true), "with somewhere to go, got " .. capDetail)

capName, capDetail = Map.Caption(sfk, "ShadowfangKeep", 3)
assert(capName == "sfk", "the loaded run's name")
assert(capDetail:find("ShadowfangKeep", 1, true),
       "MAP NAME MISSING: the borrow must be visible, not merely plausible")
assert(capDetail:find("3 points", 1, true), "and the point count, got " .. capDetail)

capName, capDetail = Map.Caption(sfk, nil, 3)
assert(capDetail:find("no map art", 1, true),
       "a run with no art and no fallback is a KNOWN limit and must SAY so")

-- =====================================================================
-- ★ SHOW - and the AUTO-PICK IS RETIRED (§36).
--
-- The old code took ids[#ids] and called it "most recent". It is ALPHABETICAL:
-- on the live set it opened RFC_run1_clean every time - the oldest run, from
-- before floor and mapFile existed. Wrong answer, delivered confidently.
-- =====================================================================
W.mapID, W.floor = 33, 6
Map.Show()
assert(mapFrame:IsShown(), "the map opens on the art of where you stand")
assert(Map.LoadedId() == nil,
       "AUTO-PICK: no run may load without being chosen, got " .. tostring(Map.LoadedId()))

-- An unrecorded map is not an error either: art follows you, run data does not.
W.mapID = 999
Map.Show()
assert(mapFrame:IsShown() and Map.LoadedId() == nil,
       "an unrecorded map still opens - there is art to look at")
W.mapID = 33

-- Loading a run, from the selector
local sfkId = ids[1]
Map.Select(target)
assert(Map.Selected() == target, "a point is selected going in")
local before = heard
Map.Show(sfkId)
assert(Map.LoadedId() == sfkId, "the chosen run is what loads")
assert(Map.Selected() == nil,
       "STALE POINT: a point from the previous run cannot survive a load - it would "
       .. "sit in the pane describing evidence that is no longer on screen")
assert(heard == before + 1 and lastHeard == nil,
       "and the clear must NOTIFY, or the pane keeps showing it")

-- ★ THE LADDER, AS PAINTED. Map.Rank being right is worth nothing if paint() does
-- not use it: the dots are frames, and their LEVEL is what buries a marker under
-- the travel samples - and what decides which one takes the click.
local marker, leg = nil, nil
for _, o in ipairs(made) do
    if o.point and o._level then
        if o.point.kind then marker = o else leg = o end
    end
end
assert(marker and leg, "the fixture must draw both a marker and a leg on this floor")
assert(marker._level > leg._level,
       ("BURIED: a marker must paint ABOVE a travel sample, got %d vs %d")
       :format(marker._level, leg._level))

-- ★ SELECTING WHILE A RUN IS LOADED - the case every earlier fixture missed.
--
-- Map.Select is defined ABOVE paint and calls it, and the call sits behind
-- `if shownRunId`. Every Select in the old fixtures ran with NO run loaded, so the
-- branch was never taken and a forward-reference bug shipped: "attempt to call
-- global 'paint'", live, on the first click of a dot. A guard whose failure case
-- the fixtures cannot REACH is untested, not safe.
--
-- Asserted on the LEVEL rather than on not-erroring, so it also proves the repaint
-- actually happened - without it the 1.6x highlight never appears and the pane's
-- readout is the only evidence of what you clicked.
local function dotFor(pt)
    for _, o in ipairs(made) do if o.point == pt then return o end end
end
local mk = sfk.markers[1]
local levelBefore = dotFor(mk)._level
Map.Select(mk)
assert(Map.Selected() == mk, "selecting a point while a run is loaded")
assert(dotFor(mk)._level > levelBefore,
       ("NO REPAINT: selection must redraw - got level %s, was %s")
       :format(tostring(dotFor(mk)._level), tostring(levelBefore)))
Map.Select(nil)

-- ★ THE TOOLTIP IS WIRED. FillTooltip being correct is worth nothing if no dot
-- ever calls it - and a pin with no OnEnter looks identical to one whose tooltip
-- is empty.
GameTooltip = { head = {}, kv = {}, _shown = false }
function GameTooltip:SetOwner() self.head, self.kv = {}, {} end
function GameTooltip:AddLine(t) self.head[#self.head + 1] = t end
function GameTooltip:AddDoubleLine(k, v) self.kv[#self.kv + 1] = { k, v } end
function GameTooltip:Show() self._shown = true end
function GameTooltip:Hide() self._shown = false end

local hovered = dotFor(mk)
-- ★ rawget, NOT hovered.OnEnter. The stub's __index hands back a no-op function
-- for any unset method, so `hovered.OnEnter` is truthy whether or not the script
-- was ever registered - the assertion would be VACUOUS. Caught by the harness:
-- deleting the handler bit on the next line's message instead of this one.
assert(rawget(hovered, "OnEnter"), "NO TOOLTIP HANDLER: the map cannot say what a point is")
hovered.OnEnter(hovered)
assert(GameTooltip._shown, "hovering shows it")
assert(GameTooltip.head[1] == "combat START",
       "and it carries the point's own label, got " .. tostring(GameTooltip.head[1]))
hovered.OnLeave(hovered)
assert(not GameTooltip._shown, "STICKY TOOLTIP: leaving must hide it")

-- ★ THE CROP, AS PAINTED. §19's trap: SetTexture RESETS TexCoord, so a crop
-- applied once at Init is silently undone by the first repaint - and the art
-- quietly goes back to overhanging the coordinate space.
local canvasStub
for _, o in ipairs(made) do
    if o._textures and #o._textures == 12 then canvasStub = o end
end
assert(canvasStub, "the canvas lays 12 tiles")
local c4 = canvasStub._textures[4]._coord
assert(c4 and math.abs(c4[2] - 234 / 256) < 1e-9,
       "TEXCOORD RESET: the crop must be re-applied after every SetTexture")

-- ★ WHICH ART WE RESOLVED TO. The one step that can put a real route onto the
-- wrong dungeon's tiles.
assert(Map.ShownArt() == "ShadowfangKeep", "a run with stored art draws on it")
Map.Show()
assert(Map.ShownArt() == "ShadowfangKeep", "with no run, the art still follows YOU")
Map.Show(rids[1])          -- the pre-DR-34 Ragefire run, opened from Shadowfang
assert(Map.ShownArt() == nil,
       "WRONG-MAP ART: a run with no stored art, opened away from its own dungeon, "
       .. "must draw on NOTHING - falling through to the local art would render "
       .. "Ragefire's route on Shadowfang's tiles and look entirely plausible")
Map.Show(sfkId)

-- Toggling a window is not a decision to discard the run you chose.
Map.Toggle(); assert(not mapFrame:IsShown(), "toggle hides")
Map.Toggle()
assert(mapFrame:IsShown() and Map.LoadedId() == sfkId, "reopening KEEPS what you loaded")

-- A bad id refuses out loud and changes nothing. Silently unloading the good run
-- would read as the addon losing data.
chat = {}
Map.Show("no-such-run-99")
assert(Map.LoadedId() == sfkId, "a bad id must not unload the run you had")
local said = false
for _, m in ipairs(chat) do if m:find("no run named", 1, true) then said = true end end
assert(said, "and it must say so")

-- Unloading is as reachable as loading
Map.Show(nil)
assert(Map.LoadedId() == nil, "'- no run -' has to actually clear it")

-- =====================================================================
-- ★ THE SELECTOR MENU (editor.lua). Loaded here because its shape is real logic -
-- the grouping, the always-present unload entry, and the empty case - and none of
-- it is reachable from map.lua's pure functions.
-- =====================================================================
local menu, ddInit, ddText = {}, nil, nil
local shared = {}
function UIDropDownMenu_CreateInfo()
    for k in pairs(shared) do shared[k] = nil end
    return shared
end
function UIDropDownMenu_Initialize(_, fn) ddInit = fn end
function UIDropDownMenu_AddButton(info)
    -- COPIED, not referenced: CreateInfo hands back one shared table and wipes it.
    menu[#menu + 1] = { text = info.text, isTitle = info.isTitle, func = info.func }
end
function UIDropDownMenu_SetWidth() end
function UIDropDownMenu_JustifyText() end
function UIDropDownMenu_SetText(_, t) ddText = t end

load("editor.lua")
local Editor = NS.Editor
assert(Editor.Init(), "the companion returns its frame")
assert(ddInit, "the menu must be built on OPEN, not once at init - runs appear later")

W.mapID = 33
ddInit()
assert(menu[1].text == "- no run -" and menu[1].func,
       "UNLOADING must be as reachable as loading, got " .. tostring(menu[1].text))

local titles, order = {}, {}
for i = 2, #menu do
    if menu[i].isTitle then titles[#titles + 1] = menu[i].text
    else order[#order + 1] = menu[i].text end
end
assert(titles[1] == "in this dungeon" and titles[2] == "other dungeons",
       "the grouping is DRAWN, not left for the user to infer")
assert(#order == 3, "every run is listed, got " .. #order)
assert(order[1] == sfkId, "the run for where you stand is first, got " .. order[1])

-- Selecting from the menu loads through the map's public entry point.
menu[2 + 1].func()          -- skip the "in this dungeon" title
assert(Map.LoadedId() == sfkId, "the menu entry must actually load the run")
assert(ddText == sfkId, "and the selector must show what the MAP has, got " .. tostring(ddText))

-- The empty case says so rather than presenting a menu with one dead entry.
local realIds = Store.Ids()
for _, id in ipairs(realIds) do Store.Delete(id) end
menu = {}
ddInit()
assert(menu[1].text == "- no run -", "the unload entry survives an empty set")
assert(menu[2] and menu[2].isTitle and menu[2].text == "no runs recorded",
       "an empty list must SAY it is empty")

print("smoke_dungeonrunmap: OK")
