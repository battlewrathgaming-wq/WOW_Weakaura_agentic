-- COA_DungeonRun routes.lua - THE PROMOTED OBJECTS.
--
-- Model: addons/planning/DRIVER_BASIS.md   READ FIRST. It names what governs NOW, in
--        precedence order, and it MOVES when a ruling moves - so this line never
--        goes stale. Lower number wins; a disagreement is reported, not resolved here.
-- Record: addons/planning/ARCHIVE__dungeonrun_poc.md §29, §56, §60, §61, §62
--         how it was argued. A RECORD, never a target.
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
-- ★★★ THE BEACON'S ID (§227). Monotonic per route, never reused - the same mint as
-- `nextChildId` and for the same reason, which the address sheets state as a law:
-- a handle must be upstream of everything the user can change.
--
-- ⚠ IT IS A SEPARATE COUNTER FROM THE CHILDREN'S, deliberately. `What am I?` is
-- intrinsic and always available, so TYPE + ID is the full designation and a beacon 1
-- can never be confused with a child 1. Sharing one counter would have bought nothing
-- and forced a migration.
--
-- ★ Battlewrath's scope: *"unique is in the sense of a route."* Nothing references
-- across a route boundary, so route-wide is exactly enough and no more.
local function nextBeaconId(r)
    r.nextBeaconId = (r.nextBeaconId or 0) + 1
    return r.nextBeaconId
end

function Routes.AddBeacon(id, node, stage)
    local r = Routes.Get(id)
    if not r or not node then return nil end
    local b = Routes.Inherit(node)
    if not b or not b.mapX then return nil end     -- unplaceable; refuse rather than store a ghost
    b.kind  = "beacon"
    b.id    = nextBeaconId(r)
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

-- ★★★ BY ID, NOT BY STAGE (§227). This matched on `b.stage` until the address sheets
-- were run against it, and `routes.lua` DELIBERATELY PERMITS DUPLICATE STAGES - so two
-- beacons at stage 4 meant deleting the second removed the FIRST, and the pane went on
-- showing the one you picked.
--
-- ⚠ Nothing was broken day to day, because stages are normally distinct. It was a
-- fault waiting on a duplicate, which is worse than a live one: the trigger is a state
-- the design invites.
--
-- ★ `stage` is a CHARACTERISTIC - the user can retype it - so it could never have been
-- the handle. An ID that is not unique is not an ID.
function Routes.DeleteBeacon(id, beaconId)
    local r = Routes.Get(id)
    if not r or not beaconId then return nil end
    for i, b in ipairs(r.beacons) do
        if b.id == beaconId then
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
-- ---------------------------------------------------------------------
-- ★★★ THE CHILD ORDINAL (A2, §312) - an ADDRESS, and an OPTIONAL gate
-- ---------------------------------------------------------------------
--
-- ★★ WHAT IT IS FOR, and the use case is the whole justification (Battlewrath,
-- 2026-08-18): *"A jump to jump to jump. Where multiple R and H might mesh
-- together."* Three platforms in a chain, each with a radius and a height band.
-- Stacked or close, those volumes OVERLAP - falling toward 3 you are inside 1's -
-- and the 2.5 yd band cannot separate them, because the platforms genuinely ARE
-- within a band of each other.
--
-- ⚠⚠ SO THIS IS THE CASE THE FLIGHT LIST DOES NOT COVER. The model's rule is *"the
-- author expresses sequence as DISTANCE, and we never need an execution-order
-- rule"* - true right up until distance stops discriminating. The ordinal is what
-- an author reaches for when geometry has run out, which is exactly why it is an
-- OFFER and never a default.
--
-- ★★★ THE GATE, RULED (Battlewrath, §311): *"The child ordinal (Not stage) gates
-- children who are IN a ordinal, to their ordinal. But children who are NOT in the
-- ordinal are still listened to."*
--
--     child WITH an ordinal      gated - waits its turn
--     child WITHOUT one          always live while its beacon is current
--
-- ★ Which leaves ENTER-FROM-ANY intact (`routes.lua`, the goTo block above): the
-- un-ordinaled children stay live, so you can still enter at any state. Opting in
-- to an ordinal is the author accepting sequence where they need it. Two kinds -
-- exactly the two `driver_programmatic_model.md` §1b already lists:
--     Child · NON-ORDINAL   satellite / funnel sensor - ANY ORDER
--     Child · ORDINAL       a chain step - previous satisfied -> this one listens
--
-- ⚠ IT IS NOT A STAGE (model: "A CHILD HAS NO STAGE, BECAUSE IT HAS A PARENT").
-- A stage would be a COPY of the parent's. This is the child's own position within
-- ONE beacon, and it means nothing outside it.

-- Sparse and OPTIONAL. `nil` takes the child OUT of the line - a satellite - and
-- that is a legitimate authoring state, not an unset field waiting to be filled.
-- Fractions are ordinary (3.1 between 3 and 4), which is what makes insertion cost
-- no renumbering.
function Routes.SetChildOrdinal(b, child, n)
    if not child then return nil end
    if n == nil or n == "" then
        child.ordinal = nil                      -- out of the line, on purpose
        return nil
    end
    local v = tonumber(n)
    if not v then return child.ordinal end       -- unparseable: keep what was there
    child.ordinal = v
    return child.ordinal
end

function Routes.OrdinalOf(child) return child and child.ordinal or nil end

-- ★★ THE ORDER IS A VIEW, NOT A STORED SORT - the same call this file already makes
-- for parentage (*"COMPUTED, never stored"*). `b.children` keeps INSERTION order, so
-- the record of what was minted when survives, and the ordinal is a lens over it.
-- ⚠ A stored sort would also make every ordinal edit a write to the child LIST, and
-- a list rewritten on an attribute edit is where ordering bugs live.
--
-- ★ Satellites sort AFTER the line, in insertion order. They are outside the
-- sequence by definition, so putting them first would read as ordinal 0.
-- ⚠ STABLE by decoration: `table.sort` is not stable in Lua, and A2.3 permits two
-- children on one ordinal - without the index tiebreak they would swap between calls
-- and the pane would appear to shuffle on its own.
function Routes.ChildrenOf(b)
    if not b or not b.children then return {} end
    local out = {}
    for i, c in ipairs(b.children) do out[i] = { c = c, i = i } end
    table.sort(out, function(x, y)
        local a, z = x.c.ordinal, y.c.ordinal
        if a and z then
            if a ~= z then return a < z end
        elseif a or z then
            return a ~= nil                      -- the line first, satellites after
        end
        return x.i < y.i                         -- insertion order breaks every tie
    end)
    for i, e in ipairs(out) do out[i] = e.c end
    return out
end

-- ⚠ THE STORED ORDER, when you need the record rather than the view. `DeleteChild`
-- and `mint` work on `b.children` directly and must keep doing so.
function Routes.ChildrenAsMinted(b)
    if not b then return {} end
    return b.children or {}
end

-- How many OTHER children already sit on this ordinal. ★ The same shape as
-- `RoleMatches` and `StageMatches`: it REPORTS a collision and never prevents one
-- (§90, S4 tell-and-trust). Two children on one ordinal is authorable - they simply
-- gate together.
function Routes.OrdinalMatches(b, n, except)
    local v = tonumber(n)
    if not v then return 0 end
    local hits = 0
    for _, c in ipairs(Routes.ChildrenAsMinted(b)) do
        if c ~= except and c.ordinal == v then hits = hits + 1 end
    end
    return hits
end

-- ★★ THE ADDRESS - `4.1:3`, beacon stage before the colon, child ordinal after
-- (C10). Returns the child AND how many matched, because uniqueness here is
-- REPORTED, not enforced: two beacons may share a stage (`StageMatches` says so and
-- refuses nothing), so a path can be ambiguous and the caller is told rather than
-- lied to.
function Routes.ChildAt(id, path)
    local r = Routes.Get(id)
    if not r or type(path) ~= "string" then return nil, 0 end
    local sTxt, oTxt = path:match("^%s*([%d%.]+)%s*:%s*([%d%.]+)%s*$")
    local stage, ord = tonumber(sTxt), tonumber(oTxt)
    if not stage or not ord then return nil, 0 end
    local found, hits = nil, 0
    for _, b in ipairs(r.beacons or {}) do
        if b.stage == stage then
            for _, c in ipairs(Routes.ChildrenAsMinted(b)) do
                if c.ordinal == ord then
                    hits = hits + 1
                    found = found or c
                end
            end
        end
    end
    return found, hits
end

-- The other direction. nil when the child is a satellite - it HAS no path, which is
-- different from having one nobody has written yet.
function Routes.PathOf(id, child)
    if not child or child.ordinal == nil then return nil end
    local b = Routes.ParentOf(id, child)
    if not b or not b.stage then return nil end
    return ("%g:%g"):format(b.stage, child.ordinal)
end

-- ★★★ THE GATE. Stateless by construction: `satisfied` is a set the CALLER owns,
-- keyed by the child table. This file stores no runtime state and never has - the
-- driver will hold what it has satisfied, and ask this the shape of the question.
--
-- ⚠ WRITTEN AGAINST THE IMMEDIATE PREDECESSOR, which is what the model says
-- literally (*"previous satisfied -> this one listens"*). With the gate in force
-- that is equivalent to "every lower one satisfied", because nothing can satisfy
-- out of order - and stating it as the model does keeps one sentence, not two.
function Routes.ListensNow(b, child, satisfied)
    if not child then return false end
    if child.ordinal == nil then return true end     -- a satellite is always live
    satisfied = satisfied or {}
    local prev = nil
    for _, c in ipairs(Routes.ChildrenAsMinted(b)) do
        if c ~= child and c.ordinal ~= nil and c.ordinal < child.ordinal then
            if prev == nil or c.ordinal > prev.ordinal then prev = c end
        end
    end
    if prev == nil then return true end              -- first in the line
    return satisfied[prev] and true or false
end


function Routes.ChildCount(b)
    return #Routes.ChildrenOf(b)
end

-- ★★★ §91: A CHILD CARRIES AN IMMUTABLE OPAQUE ID, and it is one of the eight
-- standing data laws in `COA_Landmarks/store.lua` rather than a new idea. Table
-- identity works in memory and means NOTHING in a file - so the moment one child
-- points at another, the link needs a name that survives an export.
--
-- ⚠ MONOTONIC PER ROUTE, never reused. Reusing a freed id makes a stale reference
-- resolve to the WRONG child instead of to nothing, which turns a loud break into a
-- silent one. The counter only ever goes up.
local function nextChildId(r)
    r.nextChildId = (r.nextChildId or 0) + 1
    return r.nextChildId
end

-- ★★ ONE MINT, TWO SOURCES. Both spawners land here: the difference is only WHERE
-- the position came from, so there is one place that knows what a child IS.
local function mint(r, b, place)
    if not r or not b or not place or not place.mapX then return nil end
    place.kind = "child"
    place.name = ""
    place.id = nextChildId(r)
    b.children = b.children or {}
    b.children[#b.children + 1] = place
    return place
end

-- ★ FROM A NODE, exactly as a beacon is minted from one - Routes.Inherit is the one
-- borrow, so a child and a beacon carry the same PLACE fields and the map cannot
-- tell them apart when it draws them.
function Routes.AddChildFromNode(id, b, node)
    local r = Routes.Get(id)
    if not r or not b or not node then return nil end
    return mint(r, b, Routes.Inherit(node))
end

-- ★ FROM THE BEACON ITSELF. It takes the beacon's EFFECTIVE position (new else
-- original, via PositionOf) rather than its origin: if the author dragged the
-- beacon somewhere, that is where they mean.
--
-- ⚠ The child then owns those coordinates as its ORIGIN. Moving the beacon
-- afterwards does not move the child, and it must not - a child is a place in the
-- theatre, not an offset from the anchor. `new else original` only ever resolves
-- against a point's OWN pair.
function Routes.AddChildHere(id, b)
    local r = Routes.Get(id)
    if not r or not b then return nil end
    local mx, my = Routes.PositionOf(b)
    if not mx then return nil end
    local wx, wy = Routes.WorldOf(b)
    return mint(r, b, { mapX = mx, mapY = my, x = wx, y = wy, z = b.z,
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

-- ★★★ A8.1 (§329) - THE FLAT CHECK AS A FUNCTION, NOT A FIELD. The model asks for
-- this by name: *"Take the flat check as a FUNCTION, not a field: `Routes.StageOf(node)`
-- - its own stage if a beacon, its parent's if a child. One predicate, computed, never
-- stale."*
--
-- ⚠⚠ AND IT IS WHY A CHILD HAS NO STAGE. A child's stage would be a COPY of its
-- parent's, and then every restage has to remember its children or they go stale in
-- silence. ★ The hop costs nothing here: the editor can afford the walk, and the driver
-- never asks - the same call this file already makes for parentage.
--
-- ⚠ A CHILD'S OWN `stage` FIELD IS IGNORED IF ONE EXISTS. That is deliberate: a stale
-- copy is exactly the thing this function is here to make unreachable, so reading it
-- would defeat the point of computing. `setStage` is a different field - what a `set`
-- role ASSIGNS - and is untouched.
function Routes.StageOf(id, node)
    if not node then return nil end
    if node.kind == "beacon" then return node.stage end
    local b = Routes.ParentOf(id, node)
    return b and b.stage or nil
end

-- ---------------------------------------------------------------------
-- ★★★ §86: WHY A CHILD POINTS AT ANOTHER - a rule is not a capability
-- ---------------------------------------------------------------------
--
-- Battlewrath, 2026-08-15, on what the point-to is FOR:
--
--     "The main reason for the point to is so one space doesn't need to be several
--      beacons because we made a rule, not a capability. Which is what put a lot of
--      tension on beacon v1."
--
-- ★★★ THE LAW: WHEN A RULE FORCES YOU TO FRAGMENT A THING, THE RULE IS A MISSING
-- CAPABILITY. If one theatre with three waypoints has to be authored as three
-- beacons, the author is encoding OUR limitation into THEIR data - and the route
-- then says something about the tool rather than about the dungeon.
--
-- ⚠ That was beacon v1's tension, and it is worth naming because it does not
-- announce itself: the model looked like it worked, and the cost showed up as
-- authoring friction that read like the author's problem.
--
-- ★★ THE SHAPE, and it is stateless. A child carries an optional `goTo`: reaching it
-- moves the waypoint THERE. No target, or a target that no longer resolves, and it
-- simply stops redirecting - which is a legitimate authoring state, not a fault.
--
-- ★★★ ENTER-FROM-ANY IS THE DESIGN. An ordinal chain would need to know which link
-- is ACTIVE - runtime state, and it assumes you walked in from the front. This needs
-- none: whatever range you are standing in says where to go next, so entering
-- anywhere works. His: *"only if you can enter at any state."*
--
-- ★ THE ORDER IS DERIVED, NEVER TYPED. His: *"it's a custody argument of who points
-- at who. One starts the pointing. One points at no one. And that forms the chain
-- and order."* ⚠ Walking custody yields a GRAPH, not a line - several heads are
-- legitimate (each is an entry point) and two children may converge on one target.
-- A display that draws 1 -> 2 -> 3 must not treat everything outside it as broken.
--
-- ⚠ THE IDENTITY COUPLING IS SAFE HERE AND WAS NOT AT THE BEACON LEVEL. There, a
-- missing target BREAKS THE SEQUENCE and needs fixing in two places. Here a missing
-- target degrades to "no redirect", which is already a defined state. The reference
-- is SOFT, and that is the whole difference.
--
-- ★★ AUTHOR WITH AN ID, FLATTEN TO COORDINATES. The editor keeps a live link so
-- moving a target updates every redirect naming it; the auditor resolves each `goTo`
-- into a position at export, and the driver never learns references exist. ⚠ Which
-- is the first evidence the flatten is a TRANSFORMATION, not a serialisation.
-- ---------------------------------------------------------------------

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
-- ⚠ §91: `waypoint` became `supertrack` because the name was the model. And `note` is
-- OUT for now, on his call: with ids, a note is likely a CONSUMER several children
-- reference rather than a string each one owns - *"you update one note. On route
-- export, the same note or a ref lookup is set into both."* Authoring it as a
-- per-child field today would be data to migrate the moment that lands.
Routes.ACTIONS = { "supertrack" }

local function has(list, v)
    for _, x in ipairs(list) do if x == v then return true end end
    return false
end

-- ★★★ §90: ONLY `set` IS EXCLUSIVE, AND THIS IS A RULING THAT CAME BACK DOWN.
--
-- §85 cleared the role from every sibling on the reasoning that *"there is one
-- super-tracker slot, so two claimants have no answer"*. ⚠ That was never true of
-- `complete`: §84 settled the semantics as ANY CHILD WITH THE FLAG SATISFIES, so two
-- of them is not an ambiguity, it is the set having two members. Whichever fires
-- first satisfies, and the outcome belongs to the BEACON - so both produce the same
-- index. The rule was preventing nothing and removing an authoring option.
--
-- ⚠⚠ AND THE WAY IT REMOVED IT WAS THE WORSE HALF: it SILENTLY CLEARED a sibling's
-- flag. §81 had already ruled on this exact shape one level up - a duplicate stage is
-- ALLOWED, shown with a match count, because *"refusing it would be grading the
-- author's work. The consequence is real and theirs."* I built the opposite here
-- without noticing it contradicted that.
--
-- ★★★ `set` STAYS EXCLUSIVE, and for a reason the others do not have: two
-- ASSIGNMENTS firing in one theatre have NO DEFINED RESULT, not merely an unclear
-- one. That is genuine ambiguity rather than a tolerated duplicate.
--
-- ★ HOW IT CAME DOWN, because the process is the point (Battlewrath, 2026-08-15):
-- *"We run on a idea. We get enough surface to describe it. Then we implement in
-- better form. Then we go in a circle until the stable thing comes out. And then it
-- is from those findings we can make more certain claims."* Certainty is an OUTPUT of
-- ---------------------------------------------------------------------
-- ★★★ THE SENSE (G10, §321) — stage one of `sense → when true → next`
-- ---------------------------------------------------------------------
--
-- ★★ IT IS NOT A NEW AXIS. `driver_programmatic_model.md` §3 carries `sense:` on every
-- default row - *"childless beacon — sense: reach here"*, *"boss child — sense: boss
-- engaged/killed"* - and §5 states the gap outright: *"G2 reach on a childless beacon
-- (THE DEFAULT SENSE HAS NO FIELD)"*. The model named this axis and knew it was
-- unstored. G10 gives it a field, and only for the case that departs from the default.
--
-- ⚠ SO THE DEFAULT STORES NOTHING, exactly as `outcome` does (§79): *"a route full of
-- ordinary beacons carries no field at all and nothing has to be migrated."* A node
-- with no `sense` means REACH HERE, which is the node being a node - its position is
-- intrinsic (model §1b makes it the listening filter) and its reach is configuration.
--
-- ★ `reachHere` is therefore NOT in SENSES. SENSES is the SETTABLE list; the default is
-- what you get by setting nothing. Offering it as a value would let an author store a
-- field whose only meaning is "I did not choose", which is the one thing §79 avoided.
Routes.SENSES = { "bossEngaged", "bossKilled" }
Routes.SENSE_DEFAULT = "reachHere"

-- ⚠ The list is DECLARED and CHECKED, not CLOSED (§305). A setter refusing an unknown
-- value guards a typo at a moment in time; the model's box is what the program can
-- OFFER and it grows - STATE senses (in combat · falling/landed · alive/dead · mounted)
-- and `scene entered` are in it, unbuilt. Adding one is a row here, never a refactor.
function Routes.SetChildSense(b, child, sense)
    if not child then return nil end
    if sense == nil or sense == Routes.SENSE_DEFAULT then
        child.sense = nil                    -- back to the default; nothing stored
        child.boss = nil                     -- ⚠ and the name goes with it - see below
        return nil
    end
    if not has(Routes.SENSES, sense) then return child.sense end
    child.sense = sense
    return child.sense
end

-- R6's pair (proposition §13b): the RAW reading and the RESOLVED one are different
-- questions from different callers - *was this authored* and *what does this node do*.
function Routes.SenseOf(child) return child and child.sense or nil end

function Routes.Sense(x)
    if not x then return nil end
    return x.sense or Routes.SENSE_DEFAULT
end

-- ★★ THE NAME IS PICKED, NEVER TYPED (A3.1). The offer comes from the run's own record
-- and the setter refuses anything not in it, so "picked" is a property of the data path
-- rather than of the pane being careful.
--
-- ⚠ AND IT IS PICKED AT AUTHORING, from the LOADED RUN - not looked up later. §61
-- DROPPED the route→run back-reference, so a route owes its origin nothing and cannot
-- ask it anything afterwards. The name is copied in at the moment of choosing, which is
-- the same law as PLACE carrying and EVENT not.
function Routes.SetChildBoss(b, child, name, offered)
    if not child then return nil end
    if name == nil or name == "" then
        child.boss = nil
        return nil
    end
    if offered and not has(offered, name) then return child.boss end   -- not on offer
    child.boss = name
    return child.boss
end

function Routes.BossOf(child) return child and child.boss or nil end

-- ★★★ A3.3 — THE SIGNATURE IS THE GUARD, so there is no refusal anywhere.
--
-- Battlewrath's ruling, recorded in DRIVER_BASIS: *"no refusal anywhere:
-- `listen(UNIT_DIED, name)` — no name, nothing arms; editor TELLS."* The driver's
-- arming call takes the name AS ITS ARGUMENT, so a boss child with no name has nothing
-- to pass and NOTHING ARMS. The unfiltered listener cannot be expressed, because the
-- arming function has no unfiltered form.
--
-- ★ This returns exactly what would be handed to that call, and `nil` when there is
-- nothing to hand it. It is the contract stated where it can be tested, months before
-- the driver that will make the call exists.
--
-- ⚠ It is NOT a validity check and must not become one. A nameless boss child is a
-- legitimate half-authored state (S4: told, never refused) - the editor says so, the
-- walk marks the stage unrunnable, and nobody is stopped.
function Routes.ArmsWith(child)
    if not child then return nil end
    local sense = Routes.SenseOf(child)
    if sense ~= "bossEngaged" and sense ~= "bossKilled" then return nil end
    return child.boss                        -- nil when unnamed: nothing to arm with
end

-- that loop. This claim was stamped at step two and did not survive step four.
function Routes.SetChildRole(b, child, role)
    if not b or not child then return nil end
    if role ~= nil and not has(Routes.ROLES, role) then return child.role end
    if role == "set" then
        for _, c in ipairs(Routes.ChildrenOf(b)) do
            if c ~= child and c.role == "set" then c.role = nil end
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
-- ★★★ THE CHILD'S ICON (§231) - the WORD it wears, and the only characteristic the
-- code must never read for meaning.
--
-- ★★ §225b: *"the icon is a result of the character, not the basis for it."* So this
-- writes a crop key and nothing else. The user builds a system out of the palette;
-- we attach no behaviour to the choice, and `Map.KindKey` cannot see it.
--
-- ⚠ VALIDATED AGAINST THE PALETTE, not against ART. ART carries the structural
-- crops too, and letting a child claim `beacon` would let it draw as something it
-- is not. An unknown word CLEARS rather than erroring - nil is the default crop.
function Routes.SetChildIcon(child, key)
    if not child then return nil end
    child.icon = nil
    if key then
        for _, w in ipairs(NS.Map and NS.Map.Palette() or {}) do
            if w == key then child.icon = key break end
        end
    end
    return child.icon
end

function Routes.IconOf(child) return child and child.icon or nil end

function Routes.SetChildShape(child, shape)
    if not child then return nil end
    if shape ~= nil and not has(Routes.SHAPES, shape) then return child.shape end
    child.shape = shape
    return child.shape
end

-- ⚠ THE BAND IS ASYMMETRIC (§85). `up` is the half that matters - a beacon on a
-- walkway wants reach for the player standing ON it and almost none downward, or it
-- fires for everyone underneath. Passing only `up` keeps the old symmetric meaning.
--
-- ★★★ G2 (§299, acceptance A1): A BEACON CAN CARRY A REACH TOO, and until now it
-- could not. A beacon with a radius and no children was UNRUNNABLE - it satisfied
-- itself (AcceptanceOf, below) and had no circle to be satisfied WITHIN, so the
-- simplest thing an author can want to express, *"come to this spot"*, needed a
-- child hung off it to say how close. The child stays the place for detail; the
-- beacon stops being unable to answer the only question it is ever asked.
--
-- ⚠ ONE BODY, TWO DOORS. A beacon and a child are the same shape here, so the store
-- is written once. Two copies of three lines is two places for the band to drift.
local function setReach(p, radius, up, down)
    if not p then return nil end
    p.radius = tonumber(radius) or p.radius
    p.bandUp = tonumber(up) or p.bandUp
    p.bandDown = tonumber(down) or p.bandDown
    return p.radius, p.bandUp, p.bandDown
end

function Routes.SetChildReach(child, radius, up, down)
    return setReach(child, radius, up, down)
end

function Routes.SetBeaconReach(b, radius, up, down)
    return setReach(b, radius, up, down)
end

-- ★★ ReachOf CARRIES NO SELECTION RULE OF ITS OWN, and that is the point of it.
--
-- Handed a BEACON, it resolves through `AcceptanceOf` - which already decides
-- child-when-flagged, beacon-when-childless, and nothing-when-the-author-offloaded-
-- and-did-not-finish. Handed anything else, it reads that point. So "the child's
-- when present, else the beacon's" (A1.1) is COMPOSED from the rule that already
-- exists rather than restated here. Two copies of a selection rule is two answers
-- to "which point is this stage about", and the unrunnable report depends on there
-- being one.
--
-- ⚠ NO DEFAULT IS INVENTED HERE. A field nobody set comes back `nil`, not 2.5.
-- R2 is unruled (a per-beacon band, or the +-2.5 default), and a default returned
-- from this function would be indistinguishable from a number an author typed -
-- the one confusion the whole corpus posture exists to prevent. When R2 rules a
-- default, it lands as an `or` on this line and it will be the only place it lives.
-- ⚠⚠ WRITTEN AS AN `if`, DELIBERATELY. The obvious one-liner is
--     local p = (x.kind == "beacon") and Routes.AcceptanceOf(x) or x
-- and it is WRONG in exactly the case that matters: `a and b or c` yields `c` when
-- `b` is nil, so a beacon whose children are all unflagged - AcceptanceOf nil, the
-- half-authored stage - would fall through to the beacon itself and hand back a
-- reach. A stage nobody finished would read as runnable. Caught by the smoke on the
-- first run (§299); left as three lines so it cannot come back as a tidy-up.
function Routes.ReachOf(x)
    if not x then return nil end
    local at = x
    if x.kind == "beacon" then at = Routes.AcceptanceOf(x) end
    if not at then return nil end
    return at.radius, at.bandUp, at.bandDown
end

-- ★★★ §91: THE ACTION IS AN ACT WITH A TARGET, NOT A PASSIVE CLAIM - and §85 had it
-- wrong. I modelled `waypoint` as *"I am the waypoint for this group"*, which is a
-- claim, and then made it EXCLUSIVE because one super-tracker slot cannot have two
-- owners. Battlewrath: *"Detect sits above action, so I think super tracker is the
-- action. The first detector would point action: super tracker at the pos of the
-- goto target, and then that would follow on the custody."*
--
-- ★★★ SO IT IS: *when I fire, set the tracker to THERE.* The `goTo` is not a second
-- mechanism beside the action - it IS the action's target. Which makes the chain fall
-- out of what already exists:
--
--     A  detect -> supertrack -> target B
--     B  detect -> supertrack -> target C
--     C  detect -> (none)              closes
--
-- ⚠ AND THE EXCLUSIVITY COMES DOWN, same as `complete`'s did in §90 and for the same
-- reason: several children carrying the action are not two claimants fighting over a
-- slot, they each SET it at their own moment. There is nothing to arbitrate, and the
-- rule as written forbade the main use case.
--
-- ★ His own note on why the passive form is awkward, kept because it is the argument
-- FOR this one: *"there is no real escape other than 2 radiuses on the same child. 1
-- for come find me, 2 for you found me."* An act needs no escape - the next child
-- moves the tracker and the last one leaves it.
function Routes.SetChildAction(b, child, action)
    if not b or not child then return nil end
    if action ~= nil and not has(Routes.ACTIONS, action) then return child.action end
    child.action = action
    -- ⚠ A target only means something for an action that USES one. Cleared rather
    -- than kept, so a stale link cannot come back if the action is set again later.
    if action ~= "supertrack" then child.goTo = nil end
    return child.action
end

-- ★★ OPEN: does a STAGE INCREASE always carry a direction? (Battlewrath, 2026-08-15)
--
-- Two scales, and they may not compete. What is built is WITHIN a theatre: A points
-- at B points at C. The other would be BETWEEN stages - *"stage increase = go to
-- waypoint, defined in the beacon"* - and is NOT expressible today, because nothing
-- points the tracker on a stage change; every redirect here is detector-driven.
--
-- ★ It would also give the two-radius idea somewhere to live: *"1 for come find me,
-- 2 for you found me"* is an outer reach and an inner arrival, which is a shape a
-- beacon wants and a child does not.
--
-- ★★ THE SHARPER FORM, and it is a question about how much the system decides FOR
-- the player rather than about a mechanism: *"Should a stage move always be a
-- direction to find what it leads to. (Generally, all stage increase points to the
-- on-ramp, be it a note or a supertracker.)"*
--
-- ⚠ AND OUR OWN MANNERS LEAN AGAINST THE OBVIOUS ANSWER. The note is PULLED on
-- hover, nothing announces itself on approach, the driver INFORMS and never grades -
-- while a tracker that redirects on every advance is a PUSH. Small and probably
-- welcome, but it sits against a rule held elsewhere, so it is worth deciding rather
-- than defaulting into.
--
-- ⚠ WHAT WOULD SETTLE IT IS DRIVING A ROUTE, NOT MORE DESIGN. His: *"I'm still
-- wrapping my head around it. Partly because we've not drove it yet. So I don't know
-- what feels right."* Recorded as OPEN rather than chosen, because a model picked at
-- the desk here would be picked without the only evidence that matters.

-- ★★ WHERE THE ACTION POINTS. Stored as the target's ID, never as the table or its
-- coordinates: the editor keeps a live link so moving the target updates every
-- redirect naming it, and the AUDITOR resolves it to a position at export so the
-- driver never learns references exist.
--
-- ⚠ A child may not point at ITSELF. That is a cycle of length one, and the only
-- thing it can do is pin the tracker where you already are.
function Routes.SetChildGoTo(b, child, targetId)
    if not b or not child then return nil end
    if targetId == nil then
        child.goTo = nil
        return nil
    end
    if targetId == child.id then return child.goTo end
    for _, c in ipairs(Routes.ChildrenOf(b)) do
        if c.id == targetId then
            child.goTo = targetId
            return targetId
        end
    end
    return child.goTo
end

-- ⚠ RESOLVED, NEVER STORED. A dangling target is a legitimate state - the child it
-- named was deleted, so the hop simply stops redirecting - and this returning nil is
-- how the walk and the auditor both find that out.
function Routes.GoToTarget(b, child)
    if not b or not child or not child.goTo then return nil end
    for _, c in ipairs(Routes.ChildrenOf(b)) do
        if c.id == child.goTo then return c end
    end
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

-- ⚠ §91: THE PER-CHILD NOTE SETTERS WERE REMOVED, not disabled. §85 built
-- `note`/`noteClear` as fields a child owns; his call is that with ids a note is
-- likely a CONSUMER several children reference - *"you update one note. On route
-- export, the same note or a ref lookup is set into both."*
--
-- ★★ SO THE CODE COMES OUT RATHER THAN WAITING. Dead code in a shape we have already
-- decided against is worse than absent code: the next author writes against it.
--
-- ★ The lesson it carried is NOT lost - CLEARED AND EMPTY ARE NOT THE SAME VALUE
-- lives in §84 and on the intent shelf beside the store's own rule (store nil to
-- clear, never false). It will apply to whatever the shared note turns out to be.

-- ---------------------------------------------------------------------
-- ★★★ §93: THE ON-RAMP - a THIRD AXIS, and it answers "move to me"
-- ---------------------------------------------------------------------
--
-- Battlewrath, 2026-08-15, giving the clean form of the beacon-level redirect:
--
--     "What makes it special is - it's a specific child selection. Unique, and
--      contains the marker position (itself), rather than the beacon always needing
--      to be where you want them to on-ramp... Then it has the same behaviours of
--      the other children so it can chain into them. But it's the starting point."
--
-- ★★★ IT IS A THIRD AXIS, NOT A DETECT ROLE. Detect asks WHEN, action asks WHAT
-- HAPPENS, and this asks WHICH CHILD SPEAKS FOR THIS STAGE. Orthogonal to both - so
-- the on-ramp child can also be the one that completes the stage and points the
-- tracker onward, which is the same composition as everything else here.
--
-- ★★ DECLARED, NOT DERIVED, and his reason is better than the one I proposed. I
-- suggested deriving it from custody - the child nothing points at. ⚠ That conflates
-- WHERE THE CHAIN STARTS with WHERE YOU WANT SOMEONE TO ARRIVE. Declaring it means
-- the on-ramp carries ITS OWN position, so the beacon stops having to sit where you
-- want people to enter - which is *a rule is not a capability* (§86) one level down.
--
-- ★★★ AND "MOVE TO X" IS "MOVE TO ME". The on-ramp needs no target of its own: the
-- driver points at the on-ramp's own position, and the on-ramp's `goTo` is for what
-- happens AFTER you arrive, exactly like any other child.
--
-- ★★ THE MECHANISM ALWAYS ANSWERS, and that is what keeps it from being a policy.
-- Every advance asks the same question and gets one of: move to X · a note · nothing.
-- ⚠ NOTHING IS A REAL ANSWER, not an absence - so there is no branch anywhere for
-- "this stage has no direction".
function Routes.SetChildOnRamp(b, child, on)
    if not b or not child then return nil end
    -- ⚠ EXCLUSIVE, the way `set` is and unlike the others: two children both claiming
    -- to speak for a stage has no answer, where two stage-completes plainly does.
    if on then
        for _, c in ipairs(Routes.ChildrenOf(b)) do
            if c ~= child then c.onRamp = nil end
        end
        child.onRamp = true
    else
        child.onRamp = nil
    end
    return child.onRamp
end

-- ★ The beacon is the fallback, so a theatre that needs no children still answers.
-- Same shape as the satisfier set (§83) and the outcome (§79): resolved, never
-- stored, and the simple case costs no authoring at all.
function Routes.OnRampOf(b)
    if not b then return nil end
    for _, c in ipairs(Routes.ChildrenOf(b)) do
        if c.onRamp then return c end
    end
    return b
end

-- ★★ WHAT THE STAGE'S ACCEPTANCE IS, in one call. §84: *"the beacon is mainly
-- listening for whichever child carried Detect: Stage complete. That's the
-- acceptance criteria and when the stage number ratchets."*
--
-- ⚠ Returns nil when the beacon has none - which is a legitimate authoring state (a
-- purely informational beacon) and an UNRUNNABLE stage. The pane must not refuse it;
-- the flatten must report it. Author freely, publish honestly.
-- ★★★ §94: A BEACON ON ITS OWN. Battlewrath, writing out what a bare beacon IS now
-- that the on-ramp exists:
--
--     "A on-ramp (come to me). A note option (give this to the player). A stage
--      ratchet when found. If it has children, it offloads that task to the one
--      made."
--
-- ★★ THREE ANSWERS, OFFLOADED INDEPENDENTLY - which is why the stairs case works: the
-- on-ramp is the top of the lift, the ratchet is a node in the combat area, and
-- neither has to be where the other is.
--
-- ⚠⚠ AND WRITING IT OUT FOUND A HOLE. §83 recorded *"the satisfier set is the
-- children, or the anchor when it has none"* and only half of that was built: this
-- returned nil for a childless beacon, so `/dr walk` reported every bare beacon as
-- UNRUNNABLE and the walk never tested one at all. `OnRampOf` had the fallback;
-- this did not. A ruling half-implemented reads exactly like a ruling honoured.
function Routes.AcceptanceOf(b)
    if not b then return nil end
    for _, c in ipairs(Routes.ChildrenOf(b)) do
        if c.role == "complete" then return c end
    end
    -- ★ The anchor is its own satisfier when it has no children. With children and
    -- none flagged, it is NOT - that is the author having offloaded the job and not
    -- finished, which is the case the unrunnable report was written for.
    if #Routes.ChildrenOf(b) == 0 then return b end
end

-- ★★ CUSTODY, DERIVED AND NEVER TYPED. His: *"it's a custody argument of who points
-- at who. One starts the pointing. One points at no one. And that forms the chain and
-- order."*
--
-- ⚠ IT IS A GRAPH, NOT A LINE. Several children with nothing pointing at them is
-- LEGITIMATE - each is an entry point, which is the design - and two children may
-- converge on one target. Anything drawing this as 1 -> 2 -> 3 must not treat what
-- falls outside as broken.
function Routes.Heads(b)
    local pointed = {}
    for _, c in ipairs(Routes.ChildrenOf(b)) do
        if c.goTo then pointed[c.goTo] = true end
    end
    local out = {}
    for _, c in ipairs(Routes.ChildrenOf(b)) do
        if c.action == "supertrack" and not pointed[c.id] then out[#out + 1] = c end
    end
    return out
end

-- ⚠ A TARGET THAT NO LONGER EXISTS. Reported, never repaired: the hop closing is a
-- defined state, and silently re-pointing it would be the tool authoring.
function Routes.BrokenLinks(b)
    local out = {}
    for _, c in ipairs(Routes.ChildrenOf(b)) do
        if c.goTo and not Routes.GoToTarget(b, c) then out[#out + 1] = c end
    end
    return out
end

-- ⚠ CUSTODY WITH NO END. Almost certainly a mistake - the tracker bounces forever -
-- and still not something to refuse. The author is told, the same way the gaps line
-- tells them.
function Routes.Cycles(b)
    local out = {}
    for _, start in ipairs(Routes.ChildrenOf(b)) do
        local seen, c = {}, start
        while c and c.goTo do
            if seen[c.id] then
                if c == start or seen[start.id] then out[#out + 1] = start end
                break
            end
            seen[c.id] = true
            c = Routes.GoToTarget(b, c)
        end
    end
    return out
end

-- ★★ THE COUNT THAT REPLACES THE REFUSAL, and it is §81's answer in the same words:
-- report the collision at the moment it is created, never prevent it. `except` is the
-- child being edited, so the pane can say "1 other" rather than counting itself.
function Routes.RoleMatches(b, role, except)
    local n = 0
    for _, c in ipairs(Routes.ChildrenOf(b)) do
        if c ~= except and c.role == role then n = n + 1 end
    end
    return n
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
