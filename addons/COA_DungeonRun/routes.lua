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

-- ★★★ RULING: PLACE carries, EVENT does not - a beacon is a statement about a SPOT
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
-- ★★★ FACT: [SILENT] stage is a LABEL, not an array index - DeleteBeacon leaves gaps, and 4.1 is ordinary
-- ★ §56: THE SEQUENCE INTEGER RIDES FREE. `stage` is the order the route is run
-- in, assigned as the next number at mint. It is not derived from the node, from
-- time, or from position - it is the author's sequence and nothing else knows it.
-- ★★ §80: THE DEFAULT IS THE LOWEST FREE ROUND NUMBER, not the highest plus one.
--
--   *"The next mint walks the gap. If it's 1,2,3,4,9 it picks up on 5, skips 9 for
--   10, continues."*
--
-- So a gap left by a delete refills itself, and a route the author numbered sparsely
-- on purpose is stepped over rather than collided with. ★ ROUND NUMBERS ONLY - a
-- fraction is never generated, only ever typed: *"the user can always follow up the
-- next mint as 4.2 for their 4.1, but that's them doing something specific."*
function Routes.NextStage(id)
    local r = Routes.Get(id)
    if not r then return 1 end
    local used = {}
    for _, b in ipairs(r.beacons) do used[b.stage or 0] = true end
    local n = 1
    while used[n] do n = n + 1 end
    return n
end

-- ★ §56 said stage is *"inherited as a default and EDITABLE"*. It was not - AddBeacon
-- assigned #beacons+1 and nothing could change it, so 4.1 could not exist and §79's
-- whole sub-division argument was unreachable in the UI. The mechanism accepted a
-- value nothing could produce; the same shape as §77's ticks.
--
-- ⚠ A DUPLICATE STAGE IS ALLOWED. It is visible in the running order (two rows with
-- the same number, adjacent) and refusing it would be grading the author's work. The
-- consequence is real and theirs: satisfying the first promotes past the second.
function Routes.AddBeacon(id, node, stage)
    local r = Routes.Get(id)
    if not r or not node then return nil end
    local b = Routes.Inherit(node)
    if not b or not b.mapX then return nil end     -- unplaceable; refuse rather than store a ghost
    b.kind  = "beacon"
    b.stage = tonumber(stage) or Routes.NextStage(id)
    b.name  = ""
    r.beacons[#r.beacons + 1] = b
    return b
end

-- ---------------------------------------------------------------------
-- ★★ PLACEMENT - the drag, and why the ORIGIN is kept rather than overwritten
-- ---------------------------------------------------------------------
--
-- Battlewrath, 2026-08-14: *"Keep original. A new field for both. And then the
-- marker spawner for the in-game beacon, and the source projection walk. New else,
-- Original."*
--
-- ★ THE ORIGIN BECOMES A VALUE, NOT A REFERENCE. The coordinates it came from ride
-- on the object itself, so *how we got here* survives export and works on someone
-- else's machine - which is exactly what a back-reference to the run could never do
-- (§61 dropped it; *"someone loading a route against their own data doesn't have the
-- original"*). Provenance without the link.
--
-- One object, two questions, one rule:
--
--     where do I spawn the marker      NEW, else ORIGINAL
--     where did this come from         ORIGINAL, always
--
-- ★ AND OVERWRITING WOULD DESTROY THE NOTE CASE. A note dragged off the route is
-- not a correction - it is placed for its RADIUS, where you will actually walk
-- through it. The original is where the thing happened; the new position is where
-- you want to be reminded. Overwrite it and the only record of which is which is
-- gone, and the source projection walk has nothing to walk to.
--
-- Rhymes with §43 one level up: curation edits the view and never the capture;
-- dragging edits the PLACEMENT and never the origin.

-- ★ `z` IS NOT TOUCHED. §25.2, and it is what lets a beacon sit on top of a wall -
-- compute it and the beacon drops to the floor that wall belongs to, which is
-- precisely not where you need to be standing (§67.1).
--
-- The world pair IS resolved, through §65's calibration, because §60's listen and
-- satisfied radii are DISTANCE checks and a fraction is not metric. His ruling:
-- *"Ideally, the drag would resolve, so a system that projects listen range is from
-- the new position. We always run against a run in view, so we have local
-- calibration."* On the authoring side a run is always loaded (§64), so the samples
-- are always there.
--
-- ★ And when they are not, the pair is left ABSENT rather than guessed. An
-- uncalibrated map is not a reason to invent a world position - it is a reason to
-- say we have not got one.
function Routes.Place(p, atX, atY, mapID, floor)
    if not p or not atX or not atY then return nil end
    p.atX, p.atY = atX, atY
    local C = NS.Calibrate
    local wx, wy
    if C and C.ToWorld then wx, wy = C.ToWorld(mapID, floor, atX, atY) end
    p.atWorldX, p.atWorldY = wx, wy
    return p
end

-- Back to where it came from. The origin was never overwritten, so this is a
-- deletion rather than an inverse - there is nothing to recompute.
function Routes.Unplace(p)
    if not p then return nil end
    p.atX, p.atY, p.atWorldX, p.atWorldY = nil, nil, nil, nil
    return p
end

-- ★ THE ONE RESOLUTION RULE, in one place: NEW else ORIGINAL. Read as a PAIR, so a
-- half-written placement falls back whole instead of mixing one authored axis with
-- one inherited one - which would put the object somewhere neither of them says.
function Routes.PositionOf(p)
    if not p then return nil end
    if p.atX and p.atY then return p.atX, p.atY, true end
    return p.mapX, p.mapY, false
end

function Routes.WorldOf(p)
    if not p then return nil end
    if p.atX and p.atY then return p.atWorldX, p.atWorldY end
    return p.x, p.y
end

-- ★ ONE NAME SETTER FOR BOTH OBJECTS. A beacon carries `name`, a personal note
-- carries `text` - different fields because they answer different questions (what
-- this beacon IS versus what you wrote to yourself) - but naming is one gesture and
-- the pane should not have to know which it is holding.
function Routes.SetName(p, name)
    if not p or type(name) ~= "string" then return nil end
    name = name:match("^%s*(.-)%s*$")
    if p.kind == "note" then p.text = name else p.name = name end
    return name
end

function Routes.NameOf(p)
    if not p then return nil end
    return (p.kind == "note") and p.text or p.name
end

-- Deleted BY IDENTITY, not by index: a note plane has no stage numbers, and an
-- index would be wrong the moment anything else removed one first.
function Routes.DeleteNote(mapID, p)
    local plane = Routes.GetNotes(mapID)
    if not plane or not p then return nil end
    for i, q in ipairs(plane.notes) do
        if q == p then return table.remove(plane.notes, i) end
    end
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
-- ★★★ §83: CHILDREN - the theatre gets its contents (Battlewrath, 2026-08-15)
-- ---------------------------------------------------------------------
--
-- §78 modelled it and nothing was built: *"I pick a location, but really I'm
-- interested in the theatre space... Then I inspect each data sample for what
-- children I need and where."* The anchor is a NAME FOR A PLACE; the interesting
-- things happen inside it.
--
-- ★★★ RULING: a child carries NO STAGE. The anchor holds the stage, and ANY CHILD
--   WITH THE STAGE-COMPLETE FLAG SATISFIES IT - so children share the anchor's slot
--   rather than having slots of their own. His: *"it is a check for the beacon, that
--   one of its children become satisfied, then the stage is complete."*
--
-- ★ THE MECHANIC IS NAMED, THE STATEMENT DID NOT MOVE (§84). §83 said "any child"
--   because children had no roles yet; once they do, the flagged ones are the
--   satisfier set. His: *"their in spirit the same statement, just the mechanic
--   named."* ⚠ Which is also why the SUBSET framing below still holds - conditional
--   arrived early and mild rather than as the rebuild it was priced as.
--
-- ★★ AND THAT COMPOSES RATHER THAN BRANCHING. The satisfier set is the children,
-- or the anchor itself when it has none - so a childless beacon behaves exactly as
-- it does today with no code path of its own. Same move as §79, where a checkpoint
-- turned out to be a beacon whose outcome you typed rather than a second mechanism.
--
-- ★★ CONDITIONAL IS A LATER SUBSET OF THE SAME SET, not a rebuild. "Which children
-- must flag" narrows it; ANY is the size-one case. His: *"that's a need we don't
-- have yet."* Nothing here forecloses it.
--
-- ⚠ VALUES ONLY, AND THAT IS THE DRIVER SPLIT SPEAKING. He ruled the driver must
-- be installable WITHOUT the editor, reading a flattened list that is *"a product
-- of the auditor, not needing to know how it is all coded in construction"*. A
-- child that held a reference - to its parent, to a sibling, to anything the editor
-- knows how to resolve - could not survive that flattening. So: position, name,
-- and nothing that points.
--
-- ★ Ownership is not a reference. Children hang off the beacon because they ARE the
-- beacon's contents; no child names another child, and no child is named by one.
-- That is his dumb-system ruling holding inside a group as well as between them.
-- ---------------------------------------------------------------------

-- Every child of a beacon, never nil - a caller should not have to ask whether the
-- list exists before counting it.
function Routes.ChildrenOf(b)
    if not b then return {} end
    return b.children or {}
end

function Routes.ChildCount(b)
    return #Routes.ChildrenOf(b)
end

-- ★★ ONE MINT, TWO SOURCES. Both spawners land here: the difference is only WHERE
-- the position came from, so there is one place that knows what a child IS.
local function mint(b, place)
    if not b or not place or not place.mapX then return nil end
    place.kind = "child"
    place.name = ""
    b.children = b.children or {}
    b.children[#b.children + 1] = place
    return place
end

-- ★ FROM A NODE, exactly as a beacon is minted from one - Routes.Inherit is the one
-- borrow, so a child and a beacon carry the same PLACE fields and the map cannot
-- tell them apart when it draws them.
function Routes.AddChildFromNode(b, node)
    if not b or not node then return nil end
    return mint(b, Routes.Inherit(node))
end

-- ★ FROM THE BEACON ITSELF. It takes the beacon's EFFECTIVE position (new else
-- original, via PositionOf) rather than its origin: if the author dragged the
-- beacon somewhere, that is where they mean.
--
-- ⚠ The child then owns those coordinates as its ORIGIN. Moving the beacon
-- afterwards does not move the child, and it must not - a child is a place in the
-- theatre, not an offset from the anchor. `new else original` only ever resolves
-- against a point's OWN pair.
function Routes.AddChildHere(b)
    if not b then return nil end
    local mx, my = Routes.PositionOf(b)
    if not mx then return nil end
    local wx, wy = Routes.WorldOf(b)
    return mint(b, { mapX = mx, mapY = my, x = wx, y = wy, z = b.z,
                     mapC = b.mapC, mapZ = b.mapZ, mapID = b.mapID, floor = b.floor })
end

-- ⚠ BY IDENTITY, not by index. An index is stale the moment anything else is
-- deleted, and the pane holds the child itself rather than a position in a list.
function Routes.DeleteChild(b, child)
    if not b or not child or not b.children then return nil end
    for i, c in ipairs(b.children) do
        if c == child then
            table.remove(b.children, i)
            if #b.children == 0 then b.children = nil end   -- by-exception: no empty lists stored
            return c
        end
    end
end

-- Which beacon owns this child. ⚠ COMPUTED, never stored - a stored parent link is
-- the reference the driver split forbids, and it would need maintaining on every
-- delete. The editor can afford the walk; the driver never asks.
function Routes.ParentOf(id, child)
    local r = Routes.Get(id)
    if not r or not child then return nil end
    for _, b in ipairs(r.beacons) do
        for _, c in ipairs(b.children or {}) do
            if c == child then return b end
        end
    end
end

-- ---------------------------------------------------------------------
-- ★★★ §85: THE CHILD'S PROPERTIES - two axes, competition inside each
-- ---------------------------------------------------------------------
--
-- §84 scoped it as a tick tree: *"a logic tree tick box selection. Where multiple
-- flags can be true, unless they compete."*
--
--   DETECT   when this fires      competes with its own type, radius and band
--   ACTION   what happens then    competes with its own content
--
-- ★★ A CHILD CARRIES BOTH, which is what makes the useful composition free: the
-- child that completes the stage and the child that clears the note can be THE SAME
-- CHILD, with no coordination between the axes.
--
-- ★★★ AND THE COMPETITION IS ENCODED, NEVER REMEMBERED. Setting a role clears that
-- role from the siblings; setting the waypoint clears theirs. Two stage-completes on
-- one beacon is not discouraged, it is UNREPRESENTABLE - the same argument as the
-- map's single arm, adapted to a group that has to flatten to values.
--
-- ⚠ WHY NOT A SLOT ON THE BEACON. `b.complete = <child>` is a REFERENCE, and §83
-- keeps children free of those so the flattened list can carry them as values. An
-- index rots on the first delete. A flag on the child plus clear-the-siblings is the
-- only form that survives both.
-- ---------------------------------------------------------------------

-- ★ THE ROLES. `complete` is the load-bearing one - §84 renamed it from `end`
-- because start/end read as two halves of one span and invited both to matter.
--   start     annotates arrival at the stage
--   update    annotates progress within it
--   complete  SATISFIES the anchor: index = max(index, outcome)
--   set       ASSIGNS: index = N, no max. The only thing that can move a player
--             BACKWARDS, which is why it is authored rather than inferred.
Routes.ROLES = { "start", "update", "complete", "set" }
Routes.SHAPES = { "radius", "wire" }
Routes.ACTIONS = { "note", "waypoint" }

local function has(list, v)
    for _, x in ipairs(list) do if x == v then return true end end
    return false
end

-- ⚠ EXCLUSIVE ACROSS SIBLINGS, and only for the roles that must be. `start`,
-- `update` and `complete` are one-per-beacon (§84); `set` is too, for the same
-- reason - two assignments firing in one theatre have no defined order.
function Routes.SetChildRole(b, child, role)
    if not b or not child then return nil end
    if role ~= nil and not has(Routes.ROLES, role) then return child.role end
    if role then
        for _, c in ipairs(Routes.ChildrenOf(b)) do
            if c ~= child and c.role == role then c.role = nil end
        end
    end
    child.role = role
    -- The set target only means anything for `set`. Cleared rather than kept, so a
    -- stale number cannot come back if the role is set again later.
    if role ~= "set" then child.setStage = nil end
    return child.role
end

-- What `set` assigns to. ⚠ Stored on the CHILD, not resolved like an outcome - this
-- is *you are at N*, where a checkpoint's outcome is *advance to N*. §84 flagged
-- that both type a number and mean different things.
function Routes.SetChildStage(b, child, n)
    if not child or child.role ~= "set" then return nil end
    local v = tonumber(n)
    if not v then return child.setStage end
    child.setStage = v
    return v
end

-- ★ `ifUnseen` is what makes `set` idempotent, the way `max` does for `complete`:
-- walk through a location you have already done and nothing happens. Default TRUE,
-- because the case it protects is the common one and the author should have to ask
-- for the sharp version.
function Routes.SetChildIfUnseen(child, on)
    if not child then return nil end
    -- ⚠ BY-EXCEPTION: only the FALSE is ever stored. The default is ON, so an absent
    -- field and a true field say the same thing - and only one of them can go stale.
    -- ⚠⚠ PLAIN IF, AND THE FIRST CUT HERE WAS THE BANNED IDIOM. I wrote
    -- `(on == false) and false or nil`, which evaluates to NIL whenever the
    -- condition is true - because the true-branch value is itself FALSE. That is
    -- the `cond and X or Y` trap this codebase has a ★★★ ruling against and bans in
    -- COA_GuardianPlates. Written into the very file that documents it, and caught
    -- by the smoke rather than by me.
    if on == false then child.ifUnseen = false else child.ifUnseen = nil end
    return Routes.ChildIfUnseen(child)
end

function Routes.ChildIfUnseen(child)
    return not (child and child.ifUnseen == false)
end

-- ★★ THE DETECT SHAPE. §84 ruled the BOX out - *"Radius does the same"* - so there
-- are two, and `wire` is a line of overlapping radii rather than a new geometry.
function Routes.SetChildShape(child, shape)
    if not child then return nil end
    if shape ~= nil and not has(Routes.SHAPES, shape) then return child.shape end
    child.shape = shape
    return child.shape
end

-- ⚠ THE BAND IS ASYMMETRIC (§85). `up` is the half that matters - a beacon on a
-- walkway wants reach for the player standing ON it and almost none downward, or it
-- fires for everyone underneath. Passing only `up` keeps the old symmetric meaning.
function Routes.SetChildReach(child, radius, up, down)
    if not child then return nil end
    child.radius = tonumber(radius) or child.radius
    child.bandUp = tonumber(up) or child.bandUp
    child.bandDown = tonumber(down) or child.bandDown
    return child.radius, child.bandUp, child.bandDown
end

-- ★★ THE ACTION AXIS, and only `waypoint` is exclusive. A NOTE is not: §84 found
-- that one child setting the note and another clearing it on completion is the
-- ordinary case, so *one note* counts SURFACES, not writers. A waypoint is a single
-- super-tracker slot, so two claimants have no answer.
function Routes.SetChildAction(b, child, action)
    if not b or not child then return nil end
    if action ~= nil and not has(Routes.ACTIONS, action) then return child.action end
    if action == "waypoint" then
        for _, c in ipairs(Routes.ChildrenOf(b)) do
            if c ~= child and c.action == "waypoint" then c.action = nil end
        end
    end
    child.action = action
    if action ~= "note" then child.note, child.noteClear = nil, nil end
    return child.action
end

-- ★ WHEN the action fires, which is independent of when the child DETECTS. A child
-- can detect `complete` and act on `start`, and that is not a contradiction - the
-- detect role says what it does to the index, the listen says when the action runs.
function Routes.SetChildFireOn(child, when)
    if not child then return nil end
    if when ~= nil and not has({ "start", "update", "complete" }, when) then
        return child.fireOn
    end
    child.fireOn = when
    return child.fireOn
end

-- ★★★ CLEARED AND EMPTY ARE NOT THE SAME VALUE. An author who has not typed the
-- content yet and one who wants the note WIPED are different states, and if both are
-- "" neither the pane nor the flatten can tell them apart. §84 took this from the
-- store's own rule: store nil to clear, never false.
--
--   note == nil          nothing authored yet
--   note == "text"       write this
--   noteClear == true    WIPE the surface, an explicit act
function Routes.SetChildNote(child, text)
    if not child then return nil end
    child.note = (type(text) == "string" and text ~= "") and text or nil
    if child.note then child.noteClear = nil end
    return child.note
end

function Routes.SetChildNoteClear(child, on)
    if not child then return nil end
    child.noteClear = on and true or nil
    if child.noteClear then child.note = nil end
    return child.noteClear
end

-- ★★ WHAT THE STAGE'S ACCEPTANCE IS, in one call. §84: *"the beacon is mainly
-- listening for whichever child carried Detect: Stage complete. That's the
-- acceptance criteria and when the stage number ratchets."*
--
-- ⚠ Returns nil when the beacon has none - which is a legitimate authoring state (a
-- purely informational beacon) and an UNRUNNABLE stage. The pane must not refuse it;
-- the flatten must report it. Author freely, publish honestly.
function Routes.AcceptanceOf(b)
    for _, c in ipairs(Routes.ChildrenOf(b)) do
        if c.role == "complete" then return c end
    end
end

function Routes.WaypointOf(b)
    for _, c in ipairs(Routes.ChildrenOf(b)) do
        if c.action == "waypoint" then return c end
    end
end

function Routes.ChildrenWithRole(b, role)
    local out = {}
    for _, c in ipairs(Routes.ChildrenOf(b)) do
        if c.role == role then out[#out + 1] = c end
    end
    return out
end

-- ---------------------------------------------------------------------
-- ★★ §78: THE OUTCOME OF SATISFACTION - the one place a checkpoint differs
-- ---------------------------------------------------------------------
--
-- Battlewrath: *"All the same mechanism. So what building the check point is, is
-- building the outcome of satisfaction to be dynamic operable."*
--
-- ONE expression, and the ratchet lives in it rather than beside it:
--
--     index = max(index, outcome)      outcome = self + 1   (default, stored as nil)
--                                              = N          (a checkpoint)
--
-- A checkpoint is not a kind of beacon. It is a beacon whose outcome you typed.
--
-- ★ THE DEFAULT STORES NOTHING, which is what keeps this dumb: only a checkpoint
-- writes a field, and what it writes is a VALUE. No beacon ever names another, so
-- there is never a second place to update. His ruling, and it is the reason the
-- literal beat binding to an identity:
--
--   *"If one beacon knows and depends on another beacon identity, that means any
--   replacement needs updating in 2 places. A stage number holds true, even if what
--   was 3 become 3, 3.1, 3.2 and then points back to 4."*
--
-- ⚠ AND `self + 1` IS ARITHMETIC, NOT "the next one in the list". Insert a 3.1 and
-- beacon 3 still promotes to 4, stepping over it. That is DELIBERATE - I proposed
-- resolving the successor instead and he refused it: *"We already have the fix for
-- that. Custom 3.1. Basically. Let the author do the mental work."* Inferring the
-- next stage would be the system deciding what the author meant.
function Routes.SetOutcome(b, n)
    if not b then return nil end
    -- nil clears back to the default rather than storing the computed number: a
    -- stored `self + 1` would go stale the moment the stage was renumbered.
    b.outcome = tonumber(n) or nil
    return b.outcome
end

function Routes.OutcomeOf(b) return b and b.outcome or nil end

-- ---------------------------------------------------------------------
-- ★★ §81: STAGE IS EDITABLE AFTER THE MINT - which is what §56 said all along.
-- ---------------------------------------------------------------------
--
-- ★★★ RULING: [CULTURE] NO validation on authoring - refusing would be GRADING the
--   author's work. Duplicate stages, out-of-order stages and fractions are all legal.
--   The author is TOLD what they are doing (match count, gaps line, running order)
--   and then trusted with it. ★ Explains several deliberate non-features.
-- ★ NO VALIDATION, DELIBERATELY. A duplicate is allowed, a stage below its
-- predecessor is allowed, a fraction is allowed. The author is told what they are
-- doing (the match count, the gaps line, the running order) and then trusted with
-- it - refusing would be grading the work, which is the one thing this addon has
-- consistently declined to do.
function Routes.SetStage(b, n)
    if not b then return nil end
    local v = tonumber(n)
    if not v then return b.stage end          -- unparseable: keep what was there
    b.stage = v
    return b.stage
end

-- How many OTHER beacons already sit on this number. `except` is the beacon being
-- edited, so a field showing its own stage never reports itself as a collision.
function Routes.StageMatches(id, stage, except)
    local r = Routes.Get(id)
    local n = tonumber(stage)
    if not r or not n then return 0 end
    local c = 0
    for _, b in ipairs(r.beacons) do
        if b ~= except and b.stage == n then c = c + 1 end
    end
    return c
end

-- ★ The free round numbers INSIDE the route's span - *"where the table has gaps"*.
-- Bounded by the highest stage in use, because everything above that is not a gap,
-- it is simply the next number and the ghost already offers it.
function Routes.Gaps(id, limit)
    local r = Routes.Get(id)
    if not r then return {} end
    local used, top = {}, 0
    for _, b in ipairs(r.beacons) do
        local s = b.stage or 0
        used[s] = true
        if s > top then top = s end
    end
    local out = {}
    for n = 1, math.floor(top) do
        if not used[n] then
            out[#out + 1] = n
            if limit and #out >= limit then break end
        end
    end
    return out
end

-- What satisfying this beacon promotes the index TO. Resolved, never stored.
function Routes.Outcome(b)
    if not b then return nil end
    return b.outcome or ((b.stage or 0) + 1)
end

-- ★ STAGE IS A LABEL, NOT AN ARRAY POSITION - DeleteBeacon has always matched on
-- `b.stage` and left a GAP behind it, so beacons {1,2,4} is an ordinary route. Any
-- consumer indexing the table by stage number reads the wrong beacon after a single
-- delete; the driver did exactly that until §79.
function Routes.StageOrder(id)
    local r = Routes.Get(id)
    if not r then return {} end
    local out = {}
    for _, b in ipairs(r.beacons) do out[#out + 1] = b end
    table.sort(out, function(x, y) return (x.stage or 0) < (y.stage or 0) end)
    return out
end

-- The beacon under test at a given index: the first one AT or ABOVE it. "At or
-- above" rather than "equal" is what lets an index land on 4 when the route jumps
-- from 3 to 7, and what makes a gap left by a delete cost nothing.
function Routes.BeaconAt(id, index)
    for _, b in ipairs(Routes.StageOrder(id)) do
        if (b.stage or 0) >= (index or 0) then return b end
    end
    return nil
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
