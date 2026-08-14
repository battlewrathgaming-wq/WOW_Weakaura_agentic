-- COA_DungeonRun routes.lua - THE PROMOTED OBJECTS.
--
-- Spec: addons/planning/dungeonrun_poc.md §29, §56, §60, §61, §62.
--
-- ---------------------------------------------------------------------------
-- ★ THE SECOND DATA FORM, and it is independent of the first.
--
-- A run is EVIDENCE: what happened, as captured, never edited (DR-9). A route is
-- an AUTHORED OBJECT: what someone decided the dungeon should be run as. §29 says
-- promotion COPIES - so once a beacon exists it owes its origin nothing, and the
-- §25.2 back-reference is DROPPED (§61): a beacon is expected to drift from the
-- node it came from as methods improve, there is nothing to authenticate, and a
-- route is DATA rather than code - a plot table - so a bad one is a quality
-- problem, not a trust one.
--
-- The consequence is the good kind: an exported route needs nothing from the run
-- it was born from, because it never referenced it.
--
-- ★ WHAT CARRIES OVER, AND WHAT DOES NOT. The one rule, stated once:
--
--     PLACE carries.      x,y,z · mapX,mapY,mapZ · floor · mapID
--     EVENT does not.     t,gt · kind · n · combat · dead · killedBy · ghost
--
-- A beacon is a statement about a SPOT. When that pull happened, what it was, and
-- who killed you there are facts about a capture - true of the run, not of the
-- place - and copying them would make the beacon assert things it cannot know for
-- the next person to stand there. §60: origin is gated, POSITION IS NOT.
--
-- `z` in particular is INHERITED AND NEVER COMPUTED (§25.2). It is a teacher: drag
-- a beacon across the map later and it keeps the height it was born at, so a
-- beacon floating at the wrong height is the design telling you something.
--
-- ★ DR-20 STILL HOLDS. store.lua owns COA_DungeonRunDB and hands us our sub-tables
-- through Store.RouteTable/NoteTable; this file owns the SHAPE of what lives under
-- those keys. So there is still exactly one module that touches the global, and
-- DR-21's schema refusal covers routes for free rather than needing a second copy.
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local Routes = {}
NS.Routes = Routes

local Store

function Routes.Init() Store = NS.Store end

-- ★ PLACE, and nothing else. Written as an explicit whitelist rather than a copy
-- with deletions: a field added to capture tomorrow must be a DECISION to carry,
-- not something that arrives by default. The failure mode of the other direction
-- is silent - the beacon simply starts asserting a new fact nobody chose.
local PLACE = { "x", "y", "z", "mapX", "mapY", "mapC", "mapZ", "mapID", "floor" }

function Routes.Inherit(node)
    if not node then return nil end
    local out = {}
    for _, k in ipairs(PLACE) do out[k] = node[k] end
    return out
end

-- What the promoter SHOWS before you commit - the same move as the map strip
-- naming the tile file. A borrow shown rather than assumed, and it pre-empts the
-- z question by letting you watch z arrive from the node.
function Routes.InheritSummary(node)
    if not node then return "no node selected" end
    local p = Routes.Inherit(node)
    if not p.mapX then return "the selected node has no map position - it cannot be placed" end
    return ("x %.2f  y %.2f  z %s  ·  floor %s"):format(
        p.mapX, p.mapY,
        p.z and ("%.1f"):format(p.z) or "-",
        tostring(p.floor or 0))
end

-- ---------------------------------------------------------------------
-- Routes (the family)
-- ---------------------------------------------------------------------
--
-- ★ §60: A ROUTE IS VALID FOR A MAPID, NOT A DIFFICULTY. His ruling - "a route may
-- hold useful from mythic to mythic +5" - so the object says which DUNGEON it is
-- for and says nothing about how hard it was when authored. Difficulty is run
-- identity (DR-30); it is not route identity.

local function tbl() return Store and Store.RouteTable() or nil end

local function composeId(name, n)
    local base = (name and name:match("^%s*(.-)%s*$")) or ""
    if base == "" then base = "route" end
    return ("%s-%d"):format(base, n)
end

-- Same id/name separation as a run (Store.Open): the name is stored AS TYPED and
-- uniqueness comes from the counter alone, so renaming moves a label and no handle.
function Routes.Create(name, mapID)
    local t = tbl()
    if not t then return nil end
    local n = (Store.NextRouteId and Store.NextRouteId()) or 1
    local id = composeId(name, n)
    t[id] = {
        name    = name or "",
        mapID   = mapID,
        author  = UnitName("player"),
        madeAt  = time(),
        beacons = {},
    }
    return id, t[id]
end

function Routes.Get(id)
    local t = tbl()
    return (t and id) and t[id] or nil
end

function Routes.Rename(id, name)
    local r = Routes.Get(id)
    if not r or type(name) ~= "string" then return nil end
    r.name = name:match("^%s*(.-)%s*$")
    return r.name
end

function Routes.Delete(id)
    local t = tbl()
    if t and id then t[id] = nil end
end

function Routes.Ids()
    local out = {}
    for id in pairs(tbl() or {}) do out[#out + 1] = id end
    table.sort(out)
    return out
end

-- ★★ ROUTES ARE OFFERED ONLY FOR THE MAP THAT IS LOADED. Battlewrath, 2026-08-14:
-- *"Routes, on creation, are on that map that's loaded. And are offered to load
-- only for the map that is loaded."*
--
-- ★ THIS IS A FILTER, NOT §36'S SORT, and the difference is which fact is doing the
-- work. §36 says LOCATION sorts and never picks - because where your body happens
-- to be is not a choice you made about what to work on. The loaded map IS that
-- choice. So offering a route for another dungeon is not helpfulness, it is
-- offering to draw beacons onto art they were never placed against - which, being
-- placed by fraction, would look like a plausible route rather than like an error.
--
-- Nothing loaded means no map, which means nothing to offer. The authoring surface
-- has nothing to work on, and says so instead of listing everything.
function Routes.List(mapID)
    local out = {}
    if not mapID then return out end
    for _, id in ipairs(Routes.Ids()) do
        local r = Routes.Get(id)
        if r and r.mapID == mapID then
            out[#out + 1] = { id = id, name = (r.name ~= "" and r.name) or id }
        end
    end
    table.sort(out, function(a, b)
        if a.name == b.name then return a.id < b.id end
        return a.name < b.name
    end)
    return out
end

-- ---------------------------------------------------------------------
-- Beacons
-- ---------------------------------------------------------------------
--
-- ★ CREATE THEN EDIT - the house pattern's third appearance (§61). Capture then
-- promote · pin then meaning · mint then author. The beacon exists the moment you
-- press the button, carrying only what it INHERITED; cue, note, radii and icon are
-- edited in-field afterwards. The mechanical part is immediate and the meaning
-- waits, which is also why none of the three needs a dialog.
--
-- ★ §56: THE SEQUENCE INTEGER RIDES FREE. `stage` is the order the route is run
-- in, assigned as the next number at mint. It is not derived from the node, from
-- time, or from position - it is the author's sequence and nothing else knows it.
function Routes.AddBeacon(id, node)
    local r = Routes.Get(id)
    if not r or not node then return nil end
    local b = Routes.Inherit(node)
    if not b or not b.mapX then return nil end     -- unplaceable; refuse rather than store a ghost
    b.kind  = "beacon"
    b.stage = #r.beacons + 1
    b.name  = ""
    r.beacons[#r.beacons + 1] = b
    return b
end

function Routes.DeleteBeacon(id, stage)
    local r = Routes.Get(id)
    if not r then return nil end
    for i, b in ipairs(r.beacons) do
        if b.stage == stage then
            table.remove(r.beacons, i)
            return b
        end
    end
end

function Routes.Count(id)
    local r = Routes.Get(id)
    return r and #r.beacons or 0
end

-- ---------------------------------------------------------------------
-- Personal notes - A SEPARATE PLANE (§60)
-- ---------------------------------------------------------------------
--
-- ★ NOT PART OF A ROUTE, and that is the whole point of them. §60: "personal notes
-- will have their own note plane, with the route note plane under it." They are
-- YOURS - so they never travel with an exported route, they need no route to
-- exist, and the promoter offers them ABOVE the divider because the route selector
-- does not gate them (§61).
--
-- Keyed by mapID rather than by an id you pick, because there is one plane per
-- dungeon and nothing to choose between.
local function notes() return Store and Store.NoteTable() or nil end

function Routes.NotePlane(mapID)
    local t = notes()
    if not t or not mapID then return nil end
    t[mapID] = t[mapID] or { mapID = mapID, notes = {} }
    return t[mapID]
end

-- Read-only: does NOT create the plane. The map asks this constantly and a plane
-- minted by looking at it would put empty tables in the save file for every
-- dungeon you ever opened the map in.
function Routes.GetNotes(mapID)
    local t = notes()
    return (t and mapID) and t[mapID] or nil
end

function Routes.AddNote(mapID, node)
    local plane = Routes.NotePlane(mapID)
    if not plane or not node then return nil end
    local p = Routes.Inherit(node)
    if not p or not p.mapX then return nil end
    p.kind = "note"
    p.text = ""
    plane.notes[#plane.notes + 1] = p
    return p
end

function Routes.NoteCount(mapID)
    local plane = Routes.GetNotes(mapID)
    return plane and #plane.notes or 0
end
