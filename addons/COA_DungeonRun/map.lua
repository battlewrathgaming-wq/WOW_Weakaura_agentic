-- COA_DungeonRun map.lua - display STAGE ONE: one run, drawn on our own map frame.
--
-- Spec: addons/planning/dungeonrun_poc.md §17 §19-§21 §38-§40 §43 §48-§49.
-- NOT here: comparison/A:B, tinting, the colour picker, PROMOTION (§29 - its own pane),
-- and anything for the live "guide me now" case. Those are §20.3/20.4 and later.
--
-- ---------------------------------------------------------------------------
-- ★ THE PLACEMENT RULE (§17): THE ADDON NEVER LEARNS DUNGEONS.
--
-- A point is placed from what the CLIENT told us at capture time:
--     (mapX, mapY)  the client's own fraction, computed against the right floor
--     floor         DR-33
--     mapFile       DR-34, the tile art name
-- No bounding box, no DBC, no shipped table, no per-dungeon anything. The addon
-- stores what the client said and draws it back onto the client's own art, so it
-- can never be behind on a dungeon it has not seen.
--
-- (addons/maps/worldmap/ proves the fractions are exactly what the DBC boxes give -
-- zero residual on 706 points across two dungeons and eight floors - but that is
-- DESK-side verification. Nothing here reads it.)
--
-- ★ AND WE COMPOSE OUR OWN FRAME rather than touching WorldMapFrame. The map is
-- twelve tiled textures at a predictable path (M1), so rebuilding it costs a loop
-- and buys: no conflict with any addon that hooks the stock map, pan/zoom that the
-- stock map does not have at all, and the ability to show a dungeon you are not
-- standing in - which the stock UI cannot do (its START POSITION is locked to the
-- player, though the art is addressable from anywhere).
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local Map = {}
NS.Map = Map

local Store

-- ★ TWO DIFFERENT SIZES, AND CONFUSING THEM IS A SILENT SCALE ERROR.
--
-- The stock layout (WorldMapFrame.xml:528-548):
--     WorldMapDetailFrame   1002 x 668   <- the fraction 0..1 maps across THIS
--     WorldMapDetailTile    256 x 256, laid 4x3 = 1024 x 768  <- OVERHANGS it
--
-- The tile grid is power-of-two art with dead padding; the map's coordinate space
-- is the DETAIL FRAME. Placing across the tile grid instead stretches everything
-- by +2.2% horizontally and +15% VERTICALLY - which draws a trail that still
-- follows corridors and is wrong everywhere, worst furthest from the origin.
-- Caught by eye on the first art-bearing draw: "there is some displacement as a
-- constant across them."
local TILE_COLS, TILE_ROWS, TILE_PX = 4, 3, 256    -- the ART grid
local ART_W, ART_H = 1002, 668                     -- the COORDINATE space
local DOT_PX = 8                                   -- §19: 32 is the CELL size, not the draw size
local MARK_PX = 16                                 -- an EVENT reads larger than a SAMPLE

-- ★ THE MARKER SET (Battlewrath's picks, all verified `claimed: false` in the
-- atlas census, and all four on ONE texture - so the whole display is a single
-- texture load with four crops).
--
--   pin          racing                            a CHECKERED FLAG        (DR-36)
--   leg          artifactquest                     white ring, BLUE centre  (DR-35)
--   combat leg   playerenemy                       white ring, RED centre   (DR-35)
--   start        warfronts...horde-...barracks     crossed swords, RED
--   end (alive)  warfronts...alliance-...barracks  crossed swords, BLUE
--   end (dead)   islands-markedarea                a red CROSS
--
-- ★★ TWO ORTHOGONAL CHANNELS, and DR-35 is what made it worth doing.
--
--     COLOUR = combat state.   red in combat, blue out of it. Everywhere.
--     SHAPE  = what kind.      dot = sample, swords = event, cross = terminal.
--
-- The leg was YELLOW-centred, which made colour a third thing meaning "sample" -
-- redundantly with shape. Battlewrath: *"If we want to make legs blue to copy the
-- blue combat exit, then the conversation is red vs blue."* Taken, because with
-- both leg kinds drawn you can now read the route's COMBAT RHYTHM at a glance -
-- blue stretches are travel, red clumps are where the fighting happened - without
-- reading a single marker. That is exactly what the third draw could not tell you.
--
-- ★ THE PIN IS DELIBERATELY OFF BOTH AXES. It is a CATCH-ALL with no meaning
-- until promotion, so it must not borrow one from the display: the flag is
-- ACHROMATIC (brown pole, black-and-white check), so it claims no combat state,
-- and its FORM matches nothing else, so it cannot be read as a sample, an event or
-- a terminal. Battlewrath picked it over a magnifying glass and a lore object for
-- exactly that reason - both of those say *marked BECAUSE*; a flag says *marked*.
--
-- All six are 32x32 or 37x35 cells on ONE sheet, so the whole display is still a
-- single texture load with six crops.
--
-- His colour language: **red danger, blue safe.** Start is where it began, end is
-- where it was over - and a TERMINAL STOP is neither, so it gets its own mark
-- rather than a tint. That marker is the one carrying route MEANING (`killedBy`
-- hangs off it), so it should not read as a variation of "safe again".
--
-- `w`/`h` are the CELL sizes, and they are not all square: 37x35 for the swords.
-- Draw size preserves that ratio - a squashed glyph reads as a different icon.
local ATLAS = "Interface\\Minimap\\ObjectIconsAtlas"
-- ★ One word per art key, in one table, so the two places that need a name read
-- the same one. `beacon` and `note` are what §63 forgot, and their absence took
-- the tooltip down live on a personal note.
local LABEL = {
    leg = "travel sample", combatleg = "combat travel sample",
    start = "combat START", done = "combat end", dead = "TERMINAL STOP",
    pin = "PIN", beacon = "BEACON", note = "personal note", kill = "BEACON - kill",
}

local ART = {
    -- ★★ §61: PROMOTED OBJECTS SPEAK A DIFFERENT LANGUAGE. Capture points use
    -- colour = combat state, shape = kind. A beacon is not reporting a state - it is
    -- an INSTRUCTION - so its ICONOGRAPHY carries the meaning. Battlewrath: *"just
    -- iconography of the item. It has meaning."*
    --
    -- Each icon is a WORD in a curated vocabulary, not a picker over 3,144 entries,
    -- so adding one is a design act. Three so far, and the rectangles come from the
    -- client's own SharedXML/AtlasInfo.lua rather than from a probe:
    --
    --   note    chatballon     a speech balloon - a thing you said to yourself
    --   beacon  vignetteevent  the DEFAULT a beacon mints with: something happens here
    --   kill    vignettekill   his own pick, "brown with a silver cross"
    --
    -- ⚠ The word for *"stop, there's a jump, a thing, not just movement"* is still
    -- OPEN - his to choose, and one row when it lands.
    note      = { 0.375977, 0.407227, 0.903320, 0.934570, 32, 32, MARK_PX },
    beacon    = { 0.133789, 0.196289, 0.772461, 0.834961, 64, 64, MARK_PX },
    kill      = { 0.262695, 0.325195, 0.192383, 0.254883, 64, 64, MARK_PX },

    pin       = { 0.541992, 0.573242, 0.737305, 0.768555, 32, 32, MARK_PX },
    leg       = { 0.375977, 0.407227, 0.604492, 0.635742, 32, 32, DOT_PX  },
    combatleg = { 0.475586, 0.506836, 0.571289, 0.602539, 32, 32, DOT_PX  },
    start     = { 0.299805, 0.335938, 0.585938, 0.620117, 37, 35, MARK_PX },
    done      = { 0.605469, 0.641602, 0.293945, 0.328125, 37, 35, MARK_PX },
    dead      = { 0.541992, 0.573242, 0.438477, 0.469727, 32, 32, MARK_PX },
}

-- ★ THE PRECEDENCE LADDER, and it is NOT a display preference.
--
-- Battlewrath: *"combat enter and terminal always win over combat exit. Enter is
-- more deterministic - it's where the mobs and you meet. Exit is just where you
-- was."*
--
-- ENTER IS A FACT ABOUT THE ENCOUNTER; EXIT IS A FACT ABOUT YOU. Enter is where
-- the aggro line was crossed, which is geometry the DUNGEON owns - leash range,
-- patrol path, line of sight - so the next runner meets it in the same place.
-- Exit is wherever the last mob happened to fall: it moves with kiting, pull-backs,
-- a feared add, a wipe. It is also the marker most likely to be spurious in a messy
-- run, because a re-pull emits enter/exit/enter/exit and only the ENTERS stack
-- meaningfully.
--
-- Terminal sits above enter: it is the rarest and the only marker carrying a
-- payload (`killedBy`), so burying it would hide the one point that has something
-- to say.
--
-- ★ AND THIS IS TWO FIXES, NOT ONE. Frame level drives HIT TESTING as well as draw
-- order, so the same ladder decides which marker gets the CLICK in a cluster.
-- Before it, every marker sat at one level and ties fell to list order - which puts
-- the exit LAST, i.e. on top. In a 7 px re-pull cluster you would both draw and
-- click the least meaningful marker of the group.
--
-- ★ DR-35 puts the COMBAT leg at the bottom, below the travel leg. Same reasoning
-- one level down: the out-of-combat path is the route, in-pull movement is the
-- mess around it. Where they overlap, the deterministic one reads.
--
-- ★ DR-36 puts the PIN at the TOP, above the terminal stop. It is the only point
-- that exists because someone CHOSE it - burying a deliberate mark under an
-- automatic one inverts the reason for having it.
-- ★ §61 RULED THE TOP: promoted objects sit ABOVE the pin. The authored thing
-- outranks its raw material; the pin is the most deliberate CAPTURE, and everything
-- under it is emitted by play. Burying a product under its own source inverts the
-- ladder's logic - and since the ladder decides the CLICK too, a beacon you cannot
-- select because a leg sits on top of it is the same fault in a worse place.
--
-- ⚠ §61 named the pair *"beacon · personal note"* without ordering them against each
-- OTHER. Note above beacon is MY call, not his: a route may carry twenty beacons and
-- your notes are few and yours, so when they collide the one you can still reach
-- should be your own. One number to change if he reads it the other way.
local RANK = {
    -- ★ EVERY BEACON ICON RANKS AS A BEACON. `kill` is a WORD a beacon can wear
    -- (Map.ArtKey returns the icon), not a different kind of thing - and it had no
    -- rank at all until the completeness walk asked. An unranked key falls to list
    -- order, which is the exact fault the ladder exists to prevent, in the one place
    -- nobody would look. Every icon added to ART needs its row here; the walk is
    -- what will say so.
    note = 8, beacon = 7, kill = 7,
    pin = 6, dead = 5, start = 4, done = 3, leg = 2, combatleg = 1,
}

-- Exposed so the smoke can assert the two are not conflated again.
function Map.ArtSize() return ART_W, ART_H end
function Map.TileGrid() return TILE_COLS * TILE_PX, TILE_ROWS * TILE_PX end

local frame, canvas, viewport, tiles, dots, title, ref, floorText, prevBtn, nextBtn
local buildControls
local readout

-- ---------------------------------------------------------------------
-- ★★ §76: ZOOM, because half of §75's vocabulary is DRAWING.
--
-- At Shadowfang floor 6's 0.198 yd/px a 5-yard radius is ~25 px, which is drawable.
-- On Ahn'Qiraj at 2.77 yd/px it is under TWO PIXELS - and you cannot place a choke
-- line across a doorway at that scale. The tools §75 describes are unusable on the
-- coarse half of the client's maps without this.
--
-- ★ A ScrollFrame viewport with the canvas as its scroll child. 3.3.5 has no
-- SetClipsChildren, and this is the pattern the client's own UI uses (FriendsFrame,
-- GossipFrame, MailFrame). Zoom is canvas:SetScale, which is UNIFORM - so the
-- aspect ratio cannot be broken, there is no axis to stretch independently.
--
-- ★ MARKERS SCALE WITH THE MAP (his call). A marker represents a footprint, so at
-- 3x it should cover 3x the ground - and SetScale gives that for free, with no
-- counter-scaling anywhere.
-- ---------------------------------------------------------------------
local ZOOM_MIN, ZOOM_MAX = 1.0, 4.0
local zoom, panX, panY = 1.0, 0, 0

-- ★★ §77.1: STAGES, NOT INCREMENTS. Battlewrath, correcting my misread:
--
--   *"The norm use of that is - rather than working through steps closer. Take me to
--   pre-defined stages. So, zoom to 125, zoom to 150, zoom to 200%. Rather than
--   zooming in increments."*
--
-- These are DESTINATIONS. Pressing the button puts the map AT one of them; it is
-- not a preference that changes what some other button does. I built the meta-
-- control first - a decision about a decision - and it asked the author to think
-- about step granularity before deciding where they wanted to be.
--
-- ★ 100% is in the list and it is MY call, easily removed: without it the cycle
-- cannot return you to the whole map and Reset becomes mandatory rather than a
-- convenience. It is also a pre-defined stage in its own right - the one you start
-- on.
local ZOOM_STAGES = { 1.0, 1.25, 1.5, 2.0 }

-- The fine step for zoom -/+, which is now a fixed 25% rather than something the
-- toggle selects. The two controls do different jobs: stages TRAVEL, the pair
-- ADJUSTS between them.
local ZOOM_STEP = 1.25

-- A quarter of the view per press: four presses crosses the window at any zoom,
-- which keeps the arrows feeling the same however far in you are.
local PAN_FRACTION = 0.25

-- ★★ ZOOM ANCHORS ON THE VIEW CENTRE, NOT THE CURSOR - and his reason is better
-- than the usual one. Zoom-to-cursor is right when the cursor is only a pointer;
-- here it is also a PEN. Anchoring to it would make the two jobs fight: you line up
-- a choke, scroll to see it better, and the map walks out from under the line you
-- were placing.
--
-- Pure: given the old and new zoom, what scroll keeps the centre still?
function Map.ZoomAnchor(oldZ, newZ, sx, sy, viewW, viewH)
    if not oldZ or oldZ <= 0 or not newZ then return sx, sy end
    local cx, cy = sx + viewW / 2, sy + viewH / 2      -- centre, in old scaled space
    local k = newZ / oldZ
    return cx * k - viewW / 2, cy * k - viewH / 2
end

-- Clamped so the map cannot be lost off the edge of its own window. At zoom 1 the
-- content is smaller than the viewport, so there is nowhere to go and both are 0.
function Map.PanClamp(sx, sy, z, viewW, viewH)
    local maxX = math.max(0, ART_W * z - viewW)
    local maxY = math.max(0, ART_H * z - viewH)
    return math.max(0, math.min(maxX, sx or 0)), math.max(0, math.min(maxY, sy or 0))
end

-- ★ FORWARD DECLARED, for the same reason `paint` is: Map.Select is defined above
-- it and calls it, so without this the name resolves as a GLOBAL at call time and
-- is nil. That one shipped live once (§50) because no fixture selected a point with
-- a run loaded. The fixtures do now, and this was caught before it left the desk.
local fillReadout
local shownFloor, shownArt

-- ---------------------------------------------------------------------
-- ★★ §61: THE MAP HOLDS LAYERS, NOT A RUN.
--
-- Promotion needs a run's nodes and a route's beacons ON SCREEN TOGETHER - you
-- author the route by looking at the evidence it came from - so the map cannot
-- have one slot. Two named slots, declared as data, because the difference
-- between them is not behaviour but four facts:
--
--   key     which slot, and how the selector addresses it
--   timed   is this source ON THE RUN'S TIMELINE (§48)?
--   art     may this source decide which dungeon art we draw?
--   lists   which of its lists carry drawable points
--
-- ★ `timed` is the one that matters. A run's envelope is a coordinate in ONE
-- captured span, so it resets when the RUN changes - and must NOT when the route
-- does, or loading a route silently throws away the window you trimmed. That does
-- not read as a bug; it reads as the map forgetting.
--
-- A third slot costs a row in this table. That is the whole point of it being a
-- table - it is not a prediction that there will be one.
-- ---------------------------------------------------------------------
local RUN_LISTS = { "legs", "markers" }

local LAYERS = {
    { key = "run",   timed = true,  art = true,  lists = RUN_LISTS },
    { key = "route", timed = false, art = false, lists = { "beacons" } },
    -- ★ §60's SECOND PLANE, and it cost one row - which is what the table was for.
    -- Personal notes are YOURS: they need no route, never travel with one, and are
    -- keyed by mapID because there is one plane per dungeon and nothing to choose.
    { key = "notes", timed = false, art = false, lists = { "notes" } },
}

local loaded = {}                 -- layer key -> loaded id
local layerOff = {}               -- layer key -> true when the WHOLE layer is off

local function layerDef(key)
    for _, L in ipairs(LAYERS) do
        if L.key == key then return L end
    end
end

-- ★ Each slot resolves through its OWN store. The route side reads NS.Routes,
-- which is the real integration point the promoter will provide - not a seam. Until
-- it exists the slot resolves to nil, which is indistinguishable from empty, so the
-- map ships with the second slot inert rather than broken.
local function resolve(key, id)
    if not id then return nil end
    if key == "run" then return Store and Store.Get(id) or nil end
    if key == "route" then
        local R = NS.Routes
        return (R and R.Get and R.Get(id)) or nil
    end
    if key == "notes" then
        local R = NS.Routes
        return (R and R.GetNotes and R.GetNotes(id)) or nil
    end
    return nil
end

local function currentRun() return resolve("run", loaded.run) end

-- ★★ WHICH DUNGEON IS BEING AUTHORED. Battlewrath, 2026-08-14:
--
--   *"on the run-side, yes, the content of the note is local to where you are. But
--   this is all on the authoring side. And that should all be driven from what is
--   loaded on the map."*
--
-- ★ That is a LAYER distinction and I had it wrong: location-driven is right for
-- the in-route consumer, where the player IS the cursor. On the authoring side the
-- surfaces are driven by LOAD STATE.
--
-- ★★ AND THE RUN IS THE SOLE AUTHORITY. It briefly fell back to the loaded ROUTE
-- so §62's route-only view could answer - which Battlewrath spotted as CIRCULAR:
--
--   *"If the map in play decides which routes can be selected, then routes can't be
--   a fallback. As they'll never be able to show, as they can't be selected without
--   a mapID in play."*
--
-- Exactly. A route is SELECTED AGAINST the map in play, so it cannot also be what
-- establishes it. The only way to reach that fallback was the back door - load a
-- run, load a route, unload the run - which is authority derived from a state the
-- UI cannot legitimately produce.
--
-- No player fallback either, on purpose: §22 edits a route from a city, so where
-- your body is says nothing about what you are working on, and falling back to it
-- would file work under the wrong dungeon while looking perfectly normal.
--
-- The mapID comes from the run's own CAPTURED DATA (Map.MapIDOf: the DR-30 instance
-- identity, else the mapID its points carry) - never from asking the client at
-- display time.
local function authoringMapID()
    local run = currentRun()
    return run and Map.MapIDOf(run) or nil
end

-- Exposed because the promoter must ask the MAP which dungeon it is authoring -
-- asking the client would give it the player's, which is the bug above.
function Map.AuthoringMapID() return authoringMapID() end

-- Is this point held by ANY loaded layer? Identity, not position - two points can
-- share a spot. Deliberately reads the raw lists rather than what is VISIBLE: a
-- point hidden by a tick filter or a time window is still loaded, and unselecting
-- it because you scrubbed past it would fight the user.
local function stillLoaded(p)
    if not p then return false end
    for _, L in ipairs(LAYERS) do
        local src = resolve(L.key, loaded[L.key])
        if src then
            for _, name in ipairs(L.lists) do
                for _, q in ipairs(src[name] or {}) do
                    if q == p then return true end
                end
            end
        end
    end
    return false
end

-- ★ FORWARD DECLARED. Map.Select is defined ABOVE paint and calls it, so without
-- this the name resolves as a GLOBAL at call time and is nil - "attempt to call
-- global 'paint'", live, on the first click of a dot with a run loaded.
--
-- It survived the smoke because every Select in the fixtures ran while no run was
-- loaded, and the call sits behind `if loaded.run`. A guard whose failure case the
-- fixtures cannot REACH is untested, not safe - the same law that has now caught
-- four of these. Same fix as capture.lua's captureOrigin.
local paint
local selected
local onSelect = {}               -- §34's coupling point; see Map.AddOnSelect
local hidden = {}                 -- §43's view filter; art key -> true

-- §48's TIME state. All of it is per-view and NONE of it is ever written: filter
-- views do not persist, and the envelope cannot - it is min/max of one specific
-- run's timeline, not a preference that could travel. Battlewrath: "it can't. Runs
-- are different so its min-max is different."
--
-- Relative seconds from the run's first sample, so the UI never juggles wall
-- clocks. Absolute `t` is converted once, at the filter.
local envFull                     -- the run's whole span, in seconds
local envLo, envHi                -- the ENVELOPE: where the window may go
local winPos, winWidth            -- the WINDOW: what is on screen
local peeking                     -- §48's peek; held OR latched, one state
local tracking                    -- follow the route's floor while scrubbing

-- ---------------------------------------------------------------------
-- PURE SELECTION + PLACEMENT. Deliberately free of frames so the smoke can
-- assert the arithmetic and the filtering without a UI at all - the parts that
-- can be wrong silently are the parts that must be testable.
-- ---------------------------------------------------------------------

-- Which runs belong to this map?
--
-- ★ We match on the mapID the RUN's own points carry, which came from
-- GetCurrentPlayerPosition() at capture. Display reads it from the SAME call, so
-- capture and display cannot disagree about identity.
--
-- Deliberately NOT GetCurrentMapAreaID(): it is off by one from the internal id
-- (M8 - the client's own code subtracts it) AND it indexes WorldMapArea rows,
-- which is a different id space from the one our points carry. Two ways to be
-- wrong, for no gain.
-- Which map a run belongs to. `instance.mapID` is DR-30's 8th return; runs from
-- before it fall back to the mapID their own points carry.
function Map.MapIDOf(run)
    if not run then return nil end
    if run.instance and run.instance.mapID then return run.instance.mapID end
    local first = (run.markers and run.markers[1]) or (run.legs and run.legs[1]) or run.arrival
    return first and first.mapID or nil
end

function Map.RunsFor(mapID)
    local out = {}
    if not mapID then return out end
    for _, id in ipairs(Store.Ids()) do
        if Map.MapIDOf(Store.Get(id)) == mapID then out[#out + 1] = id end
    end
    return out
end

-- ★ The tile art for a run, with the IN-ZONE FALLBACK §22 promised.
--
-- DR-34 stores `mapFile` at capture, which is what makes a run drawable from
-- anywhere. Runs captured BEFORE it carry none - and the first draw showed the
-- consequence plainly: correct dots on an empty canvas. In zone we can still ask
-- the client, because GetMapInfo() answers for the map you are standing on.
--
-- ★ GUARDED ON IDENTITY, and that guard is the whole point: without it, opening a
-- pre-DR-34 Shadowfang run while standing in Ragefire would draw Shadowfang's
-- route onto RAGEFIRE'S ART - a picture that looks entirely plausible and is
-- completely wrong. Nothing else in the display can produce that failure.
function Map.ArtFor(run, hereMapID, hereFile)
    if run and run.mapFile and run.mapFile ~= "" then return run.mapFile end
    if run and hereFile and hereFile ~= "" and hereMapID
       and Map.MapIDOf(run) == hereMapID then
        return hereFile
    end
    return nil
end

-- Every point of a run that sits on one floor.
--
-- A run captured before DR-33 has no floor at all. Those are NOT discarded: a
-- single-floor dungeon has nothing to be ambiguous about, so a nil floor matches
-- whatever floor is being shown. On a multi-floor map such a run simply predates
-- the field, and drawing it on every floor would be a lie - so it is only ever
-- offered where there is one floor to be on (the caller decides that).
--
-- ★ WHICH LISTS is the layer's to declare (§61). A run keeps legs+markers, a route
-- keeps beacons; hard-coding the run's two here is what would make the second slot
-- silently paint nothing at all.
function Map.PointsOn(run, floor, lists)
    local out = {}
    if not run then return out end
    for _, name in ipairs(lists or RUN_LISTS) do
        local list = run[name] or {}
        for _, p in ipairs(list) do
            if p.mapX and (p.floor == floor or p.floor == nil) then
                out[#out + 1] = p
            end
        end
    end
    return out
end

-- ---------------------------------------------------------------------
-- ★ §48: TIME IS THE MAIN FILTER, and three quantities that must not be conflated.
--
--   ENVELOPE  min/max on the bar. Starts as the whole run; shrinks and grows.
--   WINDOW    how much is on screen at once, and where it sits in the envelope.
--   PEEK      momentarily ignores BOTH, to show the tick-filtered whole run.
--
-- Why time and not space or pull index (§48): a route is 1-dimensional in TIME
-- even when it is 3-dimensional in space. `t` is captured rather than derived;
-- pull index is discontinuous (it cannot express the walk from pull 6 to pull 7);
-- and time is what de-duplicates repeat traversals, without which the corridor you
-- ran six times draws six times as heavy and the route silently becomes a
-- frequency map. A route is a sequence; a heatmap is a census.
-- ---------------------------------------------------------------------

-- The run's own extent, in absolute wall seconds. Read from the same two lists
-- PointsOn walks, so the bar can never describe a span the map cannot draw.
function Map.TimeSpan(run)
    local lo, hi
    for _, list in ipairs({ (run or {}).legs or {}, (run or {}).markers or {} }) do
        for _, p in ipairs(list) do
            if p.t then
                if not lo or p.t < lo then lo = p.t end
                if not hi or p.t > hi then hi = p.t end
            end
        end
    end
    if not lo then return nil end
    return lo, hi
end

-- ★ ONE SECOND IS THE FLOOR, AND IT IS A FACT NOT A PREFERENCE. Points carry `t`
-- in whole seconds (`gt` is sub-second but meaningless across sessions), and
-- capture samples at 1/s anyway. Nothing finer can mean anything.
local MIN_WIDTH = 1

-- Pure. Clamps a window into an envelope, and it is pure because every wrong
-- answer here is a window that LOOKS reasonable - off the end of the run, or
-- narrower than a sample.
function Map.ClampWindow(pos, width, lo, hi)
    local span = math.max(hi - lo, 0)
    width = math.max(MIN_WIDTH, math.min(width or span, math.max(span, MIN_WIDTH)))
    pos = math.max(lo, math.min(pos or lo, math.max(lo, hi - width)))
    return pos, width
end

-- ★ SKIP IS DERIVED, not another decision to make: window / 10, floored at one
-- second. TEN PRESSES ALWAYS CROSSES WHATEVER YOU FRAMED - a pull or a
-- three-minute corpse run - and at the fine end one step is one sample. A curve
-- was considered and dropped: it trades a learnable invariant for tuning that
-- [-] time [+] already does explicitly.
function Map.SkipStep()
    return math.max(MIN_WIDTH, math.floor((winWidth or MIN_WIDTH) / 10))
end

function Map.Envelope() return envLo, envHi end
function Map.Window() return winPos, winWidth end
function Map.Peeking() return peeking and true or false end

local function repaintIfShown()
    if frame and frame:IsShown() then paint(shownFloor) end
end

-- Reset to the whole run. Called on every load, because the envelope is a
-- coordinate in ONE run's timeline and means nothing on the next.
function Map.ResetTime(run)
    local lo, hi = Map.TimeSpan(run)
    if not lo then
        envFull, envLo, envHi, winPos, winWidth = nil, nil, nil, nil, nil
        return
    end
    envFull = hi - lo
    envLo, envHi = 0, envFull
    winPos, winWidth = Map.ClampWindow(envLo, envFull, envLo, envHi)
end

function Map.Span() return envFull end

function Map.SetEnvelope(lo, hi)
    if not envFull then return end
    envLo = math.max(0, math.min(lo or 0, envFull))
    envHi = math.max(envLo + MIN_WIDTH, math.min(hi or envFull, envFull))
    winPos, winWidth = Map.ClampWindow(winPos, winWidth, envLo, envHi)
    repaintIfShown()
    return envLo, envHi
end

-- ★★ TRACK THE MOST RECENT NODE.
--
-- SFK_Run4 is why: **floor index is not route order** (1 → 2 → back to 1 → 7 → 3 → 4 → 5 → 6),
-- so scrubbing across a transition empties the map with nothing on screen to say
-- which floor the route went to. You end up hunting floors by hand to follow a
-- route the record already knows the order of.
--
-- Which floor: the LAST point at or before the window's end, across every floor.
-- "At or before" rather than "inside", so a window sitting in a quiet stretch
-- still shows where you ARE rather than going blank - the run has not left that
-- floor just because nothing was sampled in the last few seconds.
--
-- Pure, because a wrong answer here silently pages you to a floor the route was
-- not on, and the map would look entirely reasonable.
function Map.FloorAt(run, atRel)
    local t0 = Map.TimeSpan(run)
    if not t0 or not atRel then return nil end
    local bestT, bestFloor
    for _, list in ipairs({ (run or {}).legs or {}, (run or {}).markers or {} }) do
        for _, p in ipairs(list) do
            if p.t and p.floor and (p.t - t0) <= atRel and (not bestT or p.t > bestT) then
                bestT, bestFloor = p.t, p.floor
            end
        end
    end
    return bestFloor
end

-- Two handles on the same pixel hide each other, and whichever is on top takes
-- every press - so the DRAW is nudged apart while the envelope itself is untouched.
-- Pure: it is arithmetic that decides whether a control can be grabbed at all.
local MIN_SEP = 8

function Map.SeparateHandles(x1, x2, w)
    if x2 - x1 >= MIN_SEP then return x1, x2 end
    local mid = (x1 + x2) / 2
    local a, b = mid - MIN_SEP / 2, mid + MIN_SEP / 2
    if a < 0 then a, b = 0, MIN_SEP end
    if b > w then a, b = w - MIN_SEP, w end
    return a, b
end

-- Back to the whole run: envelope, window and position together. There was no way
-- back from a narrowed envelope except reloading the run, which also threw the
-- selection away. Deliberately leaves the TICK filters and the peek alone - it is
-- the time controls' reset, and it sits under them.
function Map.ResetView()
    Map.ResetTime(currentRun())
    repaintIfShown()
    return Map.Envelope()
end

function Map.TrackingFloor() return tracking and true or false end

function Map.SetTrackFloor(on)
    tracking = on and true or nil
    if tracking and winPos then Map.SetWindow(winPos, winWidth) end
    return Map.TrackingFloor()
end

function Map.SetWindow(pos, width)
    if not envLo then return end
    winPos, winWidth = Map.ClampWindow(pos, width, envLo, envHi)
    -- The floor follows the DATA, before the repaint - otherwise the first frame
    -- after a transition draws the old floor and corrects itself, which reads as a
    -- flicker rather than as tracking.
    if tracking then
        local f = Map.FloorAt(currentRun(), winPos + winWidth)
        if f then shownFloor = f end
    end
    repaintIfShown()
    return winPos, winWidth
end

-- §48: the peek releases ONE RUNG - back to the tick-filtered whole run, not the
-- whole ladder. It is momentary by default; the latch beside it exists because
-- hold-to-peek plus click-a-point is two gestures at once, and you must be able to
-- ACT inside the peeked view without editing the envelope to get there.
function Map.SetPeek(on)
    peeking = on and true or nil
    repaintIfShown()
    return Map.Peeking()
end

-- Is this point inside the window? `t0` is the run's first sample, passed in so
-- the caller reads the span once rather than per point.
function Map.InWindow(p, t0)
    if peeking or not winPos or not t0 then return true end
    if not p.t then return true end        -- unjudgeable: show it rather than lose it
    local rel = p.t - t0
    return rel >= winPos and rel <= winPos + winWidth
end

-- ★ What actually DRAWS - §48's ladder, in order, each rung only narrowing what
-- the one above handed it:
--
--   1  tick shows      which KINDS are in play        `hidden`
--   2  time filter     which SPAN of those            the window
--   3  time controls   WHERE within it you are        winPos
--
-- A lower rung can never reintroduce what an upper rung removed - play cannot jump
-- you to a combat leg you unticked - which is why the kind test comes first and the
-- peek only lifts the time rung.
--
-- Kept separate from PointsOn so the floor filter (a fact about the run) and the
-- view filters (choices about the view) never get confused for each other.
--
-- ★ `timed` defaults TRUE, so every existing caller keeps the run's behaviour and
-- only a layer that declares itself off the timeline escapes the window. An untimed
-- source is not a source whose points are all in range - it is one the question
-- does not apply to.
function Map.VisibleOn(run, floor, timed, lists)
    if timed == nil then timed = true end
    local out = {}
    local t0 = timed and Map.TimeSpan(run) or nil
    for _, p in ipairs(Map.PointsOn(run, floor, lists)) do
        if not hidden[Map.ArtKey(p)] and (not timed or Map.InWindow(p, t0)) then
            out[#out + 1] = p
        end
    end
    return out
end

-- ★ EVERYTHING THAT DRAWS, from every loaded layer, in layer order. The one place
-- that knows the map shows more than a run - paint() just draws what it hands back.
function Map.Painted(floor)
    local out = {}
    for _, L in ipairs(LAYERS) do
        if not layerOff[L.key] then
            local src = resolve(L.key, loaded[L.key])
            if src then
                for _, p in ipairs(Map.VisibleOn(src, floor, L.timed, L.lists)) do
                    out[#out + 1] = p
                end
            end
        end
    end
    return out
end

-- Hiding a LAYER is a different axis from the tick filters: a tick hides a KIND
-- wherever it came from, this hides a SOURCE whatever kinds it holds. No art-key
-- filter can express it - a route's beacons and a run's markers share kinds.
function Map.LayerShown(key) return not layerOff[key] end

function Map.SetLayerShown(key, on)
    layerOff[key] = (not on) or nil
    if frame and frame:IsShown() then paint(shownFloor) end
    return Map.LayerShown(key)
end

function Map.Layers()
    local out = {}
    for i, L in ipairs(LAYERS) do out[i] = L.key end
    return out
end

-- ---------------------------------------------------------------------
-- ★ §43: CURATION EDITS THE VIEW, NEVER THE CAPTURE.
--
-- Hiding an art key is a DISPLAY filter and nothing else. Nothing is removed from
-- the record, nothing is written back, and the state is deliberately NOT stored on
-- the run - curation state is per-view (§43), so it does not belong in the data at
-- all and never has to survive an import (ledger law 7).
--
-- The first control §43 named, and DR-35 is what makes it necessary: in-pull
-- movement is genuinely messy, so the truthful view needs a way to be quietened.
-- ---------------------------------------------------------------------

function Map.Hidden(key) return hidden[key] and true or false end

function Map.SetHidden(key, on)
    hidden[key] = on and true or nil
    if frame and frame:IsShown() then paint(shownFloor) end
    return Map.Hidden(key)
end

-- ★ Which art a point draws with. Pure, because getting it wrong is SILENT:
-- every wrong answer still renders a legible marker in the right place, and only
-- someone reading the route can tell it lied about what happened there.
--
-- A terminal stop is an END that is `dead` - checked FIRST, because it is the
-- more specific claim and the one that carries meaning.
function Map.ArtKey(point)
    if not point then return "leg" end
    -- DR-35: a sample taken during a pull. Checked before `kind` so a marker is
    -- never mistaken for one - markers carry `n` too, and only legs carry `combat`.
    if not point.kind then return point.combat and "combatleg" or "leg" end
    if point.kind == "end" then
        return point.dead and "dead" or "done"
    end
    if point.kind == "start" then return "start" end
    if point.kind == "pin" then return "pin" end
    -- ★ A BEACON DRAWS AS ITS ICON, which is the field the user picks. Falling back
    -- to the kind rather than to a fixed beacon crop is what makes the vocabulary a
    -- vocabulary: `icon` is the word, and an unauthored beacon simply has not been
    -- given one yet. An UNKNOWN icon falls back too, so a route authored on a later
    -- build with a word we do not have draws as a beacon instead of erroring.
    if point.kind == "beacon" then
        return (point.icon and ART[point.icon]) and point.icon or "beacon"
    end
    if point.kind == "note" then return "note" end
    return "leg"
end

-- Where a point sits in the ladder. Pure, and tested, because both the picture and
-- the click resolve through it.
function Map.Rank(point) return RANK[Map.ArtKey(point)] end

-- Returns left, right, top, bottom, drawW, drawH - the draw size preserving the
-- cell's aspect ratio, so a 37x35 glyph is never squashed square.
function Map.ArtForPoint(point)
    local a = ART[Map.ArtKey(point)]
    local px = a[7]
    local w, h = a[5], a[6]
    local dw, dh = px, px * (h / w)
    return a[1], a[2], a[3], a[4], dw, dh
end

-- ---------------------------------------------------------------------
-- ★ SELECTION - §34's single coupling point between the two frames.
--
-- Map OWNS it; the companion READS it. Map deliberately holds no reference to
-- the editor - it fires one optional callback and knows nothing about who
-- listens. That is the isolation the companion exists for (Battlewrath: "isolates
-- the bug fixing / edits"): a broken editor cannot break the map, because the map
-- does not know it is there.
-- ---------------------------------------------------------------------

-- ★ MANY LISTENERS, not one. §61 adds a third surface and both panes need the
-- selection - a single `onSelect` slot would silently let whichever initialised
-- last take it, and the other pane would simply never update. Nothing changes on
-- the map's side of the boundary: it still knows nothing about who listens.
-- ---------------------------------------------------------------------
-- ★★ THE MOVE ARM (§69). Battlewrath: *"move is a chip option to left click and
-- drag around until happy. Then lock it down with the same chip press."*
--
-- ★ IT IS AN OBJECT, NOT A MODE - his ruling: *"It is on that object. Only promoted
-- options. So the specific beacon, the specific note, based on its edit menu and
-- its chip click."* A global move-mode would let you grab a neighbour in a cluster
-- and never notice; arming one object means the only thing that can move is the
-- thing you opened the menu on.
--
-- §68 shipped every promoted object grabbable all the time, so any press near one
-- risked moving it. The arm makes movement DELIBERATE - the same shape as §48's
-- peek latch, where holding is the gesture and latching is the commitment.
local armed

function Map.SetMoveArmed(point)
    -- Arming is exclusive by construction: one object, so arming another disarms
    -- the first without anything having to remember to.
    armed = (point and Map.Draggable(point)) and point or nil
    return armed
end

function Map.MoveArmed() return armed end

-- ★ §34's boundary again, for the third gesture: the map OWNS the right-click and
-- fires; it knows nothing about who opens an editor, or whether anyone does.
local onEdit = {}

function Map.AddOnEdit(fn)
    if type(fn) == "function" then onEdit[#onEdit + 1] = fn end
    return #onEdit
end

function Map.ClearOnEdit() onEdit = {} end

function Map.OpenEditor(point)
    if not Map.Draggable(point) then return false end
    Map.Select(point)
    for _, fn in ipairs(onEdit) do fn(point) end
    return true
end

function Map.AddOnSelect(fn)
    if type(fn) == "function" then onSelect[#onSelect + 1] = fn end
    return #onSelect
end

-- Only the smoke uses this, and it earns its place there: the isolation claim is
-- "selection works with NOTHING listening", which cannot be asserted without a way
-- to get back to nothing.
function Map.ClearOnSelect() onSelect = {} end

local function fireSelect(point)
    for _, fn in ipairs(onSelect) do fn(point) end
end

function Map.Selected() return selected end

function Map.Select(point)
    selected = point
    -- The readout is filled by PAINT, not here. Its position depends on the floor
    -- being drawn and the offsets that draw resolves, so owning it in two places
    -- means two answers - and this one would be the stale one.
    
    -- Repaint whenever anything is on screen, not just a run: a route's beacons are
    -- selectable too, and gating on the RUN slot would leave the highlight stale on
    -- a route-only view.
    repaintIfShown()
    fireSelect(point)
    return selected
end

-- ★ What a point IS, in words. PURE, because it is the whole readout: a wrong
-- answer here mislabels captured evidence, and the pane has no other source.
-- Returns a label plus an ordered list of {field, value} for display.
function Map.Describe(point)
    if not point then return "nothing selected", {} end

    local key = Map.ArtKey(point)
    -- ★ One table, read here and by the readout, so the two cannot disagree about
    -- what a kind is called. No fallback: ArtKey only ever returns a key ART
    -- carries, and the completeness walk guarantees every one of those is named -
    -- so `or key` was a branch nothing could reach.
    local label = LABEL[key]

    local rows = {}
    local function add(k, v) if v ~= nil and v ~= "" then rows[#rows + 1] = { k, v } end end
    if point.n then add("pull", tostring(point.n)) end
    add("floor", point.floor and tostring(point.floor) or "-")
    add("world", ("%.1f, %.1f, %.1f"):format(point.x or 0, point.y or 0, point.z or 0))
    if point.mapX then add("map", ("%.4f, %.4f"):format(point.mapX, point.mapY)) end
    add("zone", point.subZone ~= "" and point.subZone or point.zone)
    -- Both clocks, because they answer different questions (DR-4).
    add("t", point.t and tostring(point.t) or nil)
    if point.killedBy then add("killed by", table.concat(point.killedBy, ", ")) end
    if point.killedByUnavailable then add("attribution", point.killedByUnavailable) end
    if point.ghost then add("ghost", "yes") end
    return label, rows
end

-- ★ THE MAP ANSWERS "WHAT IS THIS?" (Battlewrath, 2026-08-13)
--
-- *"Map information I think should live on the map. As the curator suite is going
-- to pack a lot of content itself."*
--
-- So the point readout is a TOOLTIP here rather than ten rows in the companion:
-- native pin idiom, zero screen space, works on all 434 points without the pane
-- ever growing. It frees the companion for what it is actually for - trimming,
-- filtering, replay selection, isolation.
--
-- HOVER READS, CLICK TARGETS. Worth having on its own: you can inspect the whole
-- route without changing what you are about to act on.
--
-- Map.Describe is unchanged - it was already the tested readout and it simply has
-- a different consumer now.
--
-- Colours follow the art's own language (red danger, blue safe); the LABEL does
-- the distinguishing between a start and a terminal stop, rather than a fourth
-- invented colour.
local TIP_COLOR = {
    -- ★★ §61: PROMOTED OBJECTS ARE OFF THE COMBAT AXIS ENTIRELY. Colour = combat
    -- state is a rule about CAPTURE; a beacon is an INSTRUCTION and reports no
    -- state, so it takes the authored gold this UI uses for a name the user chose.
    -- Missing these took the tooltip down on a personal note, live.
    beacon    = { 1.0, 0.82, 0.0 },
    note      = { 1.0, 0.82, 0.0 },
    kill      = { 1.0, 0.82, 0.0 },
    -- Off the colour axis on purpose: a pin asserts no combat state (DR-36).
    pin       = { 1.0, 1.0, 1.0 },
    leg       = { 0.5, 0.75, 1.0 },
    combatleg = { 1.0, 0.6, 0.5 },
    start     = { 1.0, 0.4, 0.3 },
    done      = { 0.4, 0.7, 1.0 },
    dead      = { 1.0, 0.2, 0.2 },
}

-- ★★ EVERY ART KEY, so a completeness check is possible at all. §63 added three
-- kinds to ART and to the ladder and missed LABEL and TIP_COLOR - and nothing could
-- have noticed, because there was no way to ask what the full set WAS.
function Map.ArtKeys()
    local out = {}
    for k in pairs(ART) do out[#out + 1] = k end
    table.sort(out)
    return out
end

-- What a key resolves to across the three tables that must all know it. Returns
-- nil for anything ART does not carry, so an invented key cannot look answered.
function Map.KeyFacts(key)
    if not ART[key] then return nil end
    return LABEL[key], TIP_COLOR[key], RANK[key]
end

-- Fills any tooltip-shaped object. Split out from the handler so it is testable
-- without a frame: an empty tooltip is the map answering "what is this?" with
-- silence, and nothing else would catch it.
function Map.FillTooltip(tip, point)
    if not tip or not point then return false end
    local label, rows = Map.Describe(point)
    -- Defaulted rather than trusted: a missing colour must never take the tooltip
    -- down again. The completeness walk is what stops one being missing at all.
    local c = TIP_COLOR[Map.ArtKey(point)] or { 1, 1, 1 }
    tip:AddLine(label, c[1], c[2], c[3])
    for _, kv in ipairs(rows) do
        tip:AddDoubleLine(kv[1], kv[2], 0.7, 0.7, 0.7, 1, 1, 1)
    end
    return true
end

-- Fraction -> pixel offset from the canvas TOPLEFT.
--
-- mapY runs DOWNWARD (fraction 0 is the top edge), which is why y is negated:
-- SetPoint from TOPLEFT takes a negative y to move down.
-- ★★ NEW ELSE ORIGINAL, and this is the ONLY place the rule is applied. Every
-- draw, every hit test and every readout flows through here, so a dragged object
-- moves everywhere at once and the origin stays exactly where it was recorded.
--
-- Read as a PAIR on purpose: a half-written placement falls back whole rather than
-- mixing one authored axis with one inherited one, which would put the object
-- somewhere neither of them says.
function Map.Offset(point, w, h)
    if not point then return nil end
    local mx, my
    if point.atX and point.atY then mx, my = point.atX, point.atY
    else mx, my = point.mapX, point.mapY end
    -- Both, or neither. A half-written pair reaching the arithmetic is a nil
    -- multiply inside paint's loop - one bad point taking the whole map down.
    if not mx or not my then return nil end
    return mx * w, -(my * h)
end

-- ★ THE INVERSE, and the only new arithmetic dragging needs.
--
-- Read from LIVE frame geometry rather than stored constants, so pan and zoom cost
-- nothing when they land - GetLeft and GetEffectiveScale are already in real screen
-- units and account for both.
--
-- ★ CLAMPED, because off the art is not a position. An unclamped fraction outside
-- 0..1 still stores and still draws (just off-canvas), which looks placed and is
-- not. Pure so the arithmetic can be asserted without a cursor.
function Map.FractionAt(cursorX, cursorY, scale, left, top)
    if not (cursorX and cursorY and scale and left and top) or scale <= 0 then
        return nil
    end
    local mx = (cursorX / scale - left) / ART_W
    local my = (top - cursorY / scale) / ART_H
    if mx < 0 then mx = 0 elseif mx > 1 then mx = 1 end
    if my < 0 then my = 0 elseif my > 1 then my = 1 end
    return mx, my
end

-- ★ DRAGGABLE MEANS PROMOTED. A node is CAPTURE - DR-9 and §43 forbid editing it,
-- and there is no gesture that should ever move one. Beacons and personal notes are
-- authored objects and moving them is the whole point.
function Map.Draggable(point)
    return (point and (point.kind == "beacon" or point.kind == "note")) and true or false
end

-- M7: the floor selects a SUFFIX, not a different file, and only when > 0.
--
-- ★★ AND A TERRAIN MAP SHIFTS IT BY ONE. WorldMapFrame.lua:463:
--
--     local dungeonLevel = GetCurrentMapDungeonLevel();
--     if (DungeonUsesTerrainMap()) then dungeonLevel = dungeonLevel - 1; end
--
-- We recorded that in maps/worldmap/README.md M7 and then did not consume it,
-- which is the stored-field-isn't-live failure exactly. On such a dungeon the
-- lowest level asks for `<file>1_i` where the client asks for `<file>i` - blank
-- tiles - and every level above loads THE WRONG FLOOR'S ART under the right
-- points. The second one looks like a working map.
--
-- Neither dungeon we have run is a terrain map, which is why nothing has broken.
-- The flag comes from the RUN (captured at arm), not from asking the client here:
-- DungeonUsesTerrainMap() describes the map being SHOWN, and §22 edits from a city.
-- Absent = today's behaviour, so every run captured before this is unchanged.
function Map.TilePath(mapFile, floor, i, terrain)
    if not mapFile or mapFile == "" then return nil end
    local level = floor or 0
    if terrain then level = level - 1 end
    local base = mapFile
    if level > 0 then base = mapFile .. level .. "_" end
    return ("Interface\\WorldMap\\%s\\%s%d"):format(mapFile, base, i)
end

-- ★ CROP THE ART BACK TO THE COORDINATE SPACE.
--
-- The tiles are 1024x768 and the coordinate space is 1002x668, so the grid
-- OVERHANGS by 22 px right and 100 px bottom. That overhang is power-of-two
-- padding: the stock map's detail frame is 1002x668 and clips it, so nothing we
-- hide here is ever drawn by the game's own map either.
--
-- Cropping buys the frame back - "bottom can be trimmed upwards" - and it also
-- removes a standing confusion, because after it the canvas IS what you see. The
-- two sizes stay separate in code (Map.ArtSize / Map.TileGrid, and the smoke
-- asserts they never converge); it is only the DRAWN region that now matches.
--
-- Returns x, y (offset from the canvas TOPLEFT), w, h (draw size) and u, v (the
-- texcoord right/bottom edges). nil when a tile is entirely padding.
function Map.TileRect(i)
    local col, row = (i - 1) % TILE_COLS, math.floor((i - 1) / TILE_COLS)
    local x, y = col * TILE_PX, row * TILE_PX
    local w = math.min(TILE_PX, ART_W - x)
    local h = math.min(TILE_PX, ART_H - y)
    if w <= 0 or h <= 0 then return nil end
    return x, y, w, h, w / TILE_PX, h / TILE_PX
end

-- ---------------------------------------------------------------------
-- ★ §36: LOCATION SORTS THE LIST; IT NEVER CHOOSES THE VIEW.
--
-- Battlewrath: *"It can load the map you're in. If you're in one. It can not
-- auto-load a run data set. It can offer runs of that dungeon first in the
-- selector, and then result to naming alphabetical when not in an instance."*
--
-- The auto-pick this replaces took `ids[#ids]` and called it "most recent" - it is
-- ALPHABETICAL, and on the live set it opened RFC_run1_clean every time: the oldest
-- run, from before floor and mapFile existed. Wrong answer, delivered confidently,
-- with nothing on screen to say so.
-- ---------------------------------------------------------------------

-- The ordered selector list: runs for where you STAND first, then everything else,
-- alphabetical by name within each group. Returns {id, name, here} entries.
function Map.RunList(hereMapID)
    local here, other = {}, {}
    for _, id in ipairs(Store.Ids()) do
        local run = Store.Get(id)
        local e = { id = id, name = (run and run.name ~= "" and run.name) or id,
                    here = hereMapID ~= nil and Map.MapIDOf(run) == hereMapID }
        table.insert(e.here and here or other, e)
    end
    local function byName(a, b)
        if a.name == b.name then return a.id < b.id end
        return a.name < b.name
    end
    table.sort(here, byName); table.sort(other, byName)
    for _, e in ipairs(other) do here[#here + 1] = e end
    return here
end

-- Which floor a freshly loaded run opens on.
--
-- Standing in its dungeon, the floor you are on is the right answer. Loading one
-- from elsewhere (§22: editing from a city), where you stand means nothing - so the
-- run's own arrival floor is, and 0 is the single-floor default.
function Map.SeedFloor(run, hereMapID, hereFloor)
    if run and hereMapID and Map.MapIDOf(run) == hereMapID and hereFloor then
        return hereFloor
    end
    if run and run.arrival and run.arrival.floor then return run.arrival.floor end
    for _, list in ipairs({ (run or {}).markers or {}, (run or {}).legs or {} }) do
        for _, p in ipairs(list) do
            if p.floor then return p.floor end
        end
    end
    return hereFloor or 0
end

-- ★ The strip's left-hand reference: WHAT is loaded, and WHAT IT IS DRAWN ON.
--
-- The map name was nowhere on screen before, and the art was the only evidence of
-- which dungeon you were looking at - which is exactly the path that can lie. A
-- pre-DR-34 run borrows the art of the zone you are standing in (guarded on
-- identity, but still borrowed), so naming the file makes the borrow VISIBLE
-- instead of merely plausible.
--
-- Returns name, detail - two strings, drawn at two weights.
function Map.Caption(run, mapFile, n, routeName)
    local place = (mapFile and mapFile ~= "") and mapFile or "no map art"
    if not run then
        -- ★ A route alone is a legitimate view (§61's none-option on the run slot).
        -- Saying "no run loaded" over beacons that are plainly on screen leaves the
        -- one thing that IS loaded unnamed.
        if routeName then
            return routeName, ("%s  |  %d point%s  |  no run loaded"):format(
                place, n, n == 1 and "" or "s")
        end
        return "no run loaded", place .. "  -  Curate to pick one"
    end
    if not (mapFile and mapFile ~= "") then
        place = "no map art (pre-DR-34 run, and not in its zone)"
    end
    local detail = ("%s  |  %d point%s"):format(place, n, n == 1 and "" or "s")
    if routeName then detail = detail .. ("  |  route: %s"):format(routeName) end
    return (run.name ~= "" and run.name) or "(unnamed)", detail
end

-- ---------------------------------------------------------------------
-- Frame
-- ---------------------------------------------------------------------

local function ensureDots(n)
    for i = #dots + 1, n do
        local d = CreateFrame("Button", nil, canvas)
        if Mixin and WorldMapPOIMixin then Mixin(d, WorldMapPOIMixin) end
        local t = d:CreateTexture(nil, "OVERLAY")
        t:SetAllPoints(d)
        -- §19 trap: SetTexture RESETS TexCoord. The texture is set ONCE here; the
        -- crop is set per point in paint(), which is after it in every path.
        t:SetTexture(ATLAS)
        d.tex = t
        -- ★ §69's three gestures on one object: hover reads, left click selects AND
        -- PINS the same reading, right click opens its editor.
        d:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        d:SetScript("OnClick", function(self, button)
            if button == "RightButton" then Map.OpenEditor(self.point)
            else Map.Select(self.point) end
        end)
        -- ★ The OnUpdate exists ONLY while a drag is in flight - installed on
        -- start, cleared on stop. Same discipline as the sampler and the envelope
        -- handles, and what keeps the census reporting zero persistent OnUpdate.
        d:RegisterForDrag("LeftButton")
        d:SetScript("OnDragStart", function(self) Map.BeginDrag(self) end)
        d:SetScript("OnDragStop", function() Map.EndDrag() end)
        d:SetScript("OnEnter", function(self)
            if not self.point then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            Map.FillTooltip(GameTooltip, self.point)
            GameTooltip:Show()
        end)
        d:SetScript("OnLeave", function() GameTooltip:Hide() end)
        dots[i] = d
    end
end

-- Markers draw ABOVE legs. A pull start sitting under 300 travel samples would be
-- invisible exactly where it matters most - and the pool is drawn in list order,
-- which puts legs last.
local function styleDot(d, point)
    local l, r, t, b, dw, dh = Map.ArtForPoint(point)
    -- The selected point draws larger. Without SOME feedback you cannot tell what
    -- you clicked, and the pane's readout would be the only evidence - which is
    -- exactly the kind of thing that reads as a bug when it is working.
    if point == selected then dw, dh = dw * 1.6, dh * 1.6 end
    d:SetWidth(dw); d:SetHeight(dh)
    d.tex:SetTexCoord(l, r, t, b)
    -- The ladder (RANK) decides both what is on top and what takes the click.
    -- Selection sits above all of it - you must be able to see what you picked.
    d:SetFrameLevel(canvas:GetFrameLevel() + (point == selected and 10 or Map.Rank(point)))
end

local function clearDots()
    for _, d in ipairs(dots) do d:Hide() end
end

-- Assigns the forward-declared local above; NOT `local function`, which would
-- shadow it and put the bug straight back.
function paint(floor)
    local run = currentRun()
    local _, _, _, hereMapID = GetCurrentPlayerPosition()
    local hereFile = GetMapInfo and GetMapInfo() or nil

    -- ★ Written as a branch, NOT as `run and Map.ArtFor(...) or hereFile`. That
    -- idiom would fall through to the local art whenever ArtFor REFUSED - which is
    -- precisely the wrong-map case its identity guard exists to stop. The no-run
    -- case is a different question (§36: art may follow you) and gets its own line.
    local mapFile
    if run then mapFile = Map.ArtFor(run, hereMapID, hereFile) else mapFile = hereFile end
    shownArt = mapFile          -- what we RESOLVED to, exposed so it can be asserted

    -- The run's own stored fact, never a live ask (see Map.TilePath). With no run
    -- loaded the art follows where you stand (§36) and the client is already drawing
    -- it correctly on its own map; we have nothing to inherit, so nil.
    local terrain = run and run.mapTerrain or nil
    for i = 1, TILE_COLS * TILE_ROWS do
        local path = Map.TilePath(mapFile, floor, i, terrain)
        tiles[i]:SetTexture(path)
        -- §19's trap again: SetTexture RESETS TexCoord, so the crop is re-applied
        -- after every set rather than once at Init.
        local _, _, _, _, u, v = Map.TileRect(i)
        if u then tiles[i]:SetTexCoord(0, u, 0, v) end
    end

    local pts = Map.Painted(floor)            -- §43/§61: every layer, minus what is hidden
    clearDots()
    ensureDots(#pts)
    for i, p in ipairs(pts) do
        local dx, dy = Map.Offset(p, ART_W, ART_H)
        local d = dots[i]
        d.point = p
        styleDot(d, p)
        d:ClearAllPoints()
        d:SetPoint("CENTER", canvas, "TOPLEFT", dx, dy)
        d:Show()
    end

    -- Say WHY the canvas is empty rather than presenting a blank one. A run with
    -- no art and no in-zone fallback is a KNOWN limitation (pre-DR-34), not a
    -- fault, and the readout should not leave that to be guessed at.
    local route = resolve("route", loaded.route)
    -- The panel is placed relative to the art, so a repaint has to re-place it:
    -- the floor may have changed under it, or the object may have been dragged.
    fillReadout(selected)

    local name, detail = Map.Caption(run, mapFile, #pts, route and route.name)
    title:SetText(name)
    ref:SetText(detail)
    floorText:SetText(("floor %s"):format(tostring(floor)))
end

-- ★ §20.2: LOCATION SEEDS THE VIEW. Read from the same calls capture used, so
-- the two cannot disagree. Not a constraint - a selected run overrides it (§22),
-- which is stage two's dropdown; stage one only needs the default.
local function context()
    local _, _, _, mapID = GetCurrentPlayerPosition()
    local floor = GetCurrentMapDungeonLevel and GetCurrentMapDungeonLevel() or nil
    return mapID, floor
end

-- Defaults to the RUN slot: every existing caller means the run, and §61 is not a
-- reason to make them all say so.
function Map.LoadedId(key) return loaded[key or "run"] end

-- ---------------------------------------------------------------------
-- ★★ THE STABLE READOUT (§69). *"Left click also shows the same as hover does, but
-- stably."*
--
-- ★ ONE CONTENT SOURCE, TWO PRESENTATIONS. Both render Map.Describe - the hover
-- into GameTooltip, the selection into these font strings. Giving the panel its own
-- copy of "what this point says" is the thing that would rot: the two would drift a
-- field at a time and nobody would notice which was right.
--
-- On the MAP rather than in a pane, per §49: *"map information I think should live
-- on the map. As the curator suite is going to pack a lot of content itself."*
local READOUT_ROWS = 8
local READOUT_W = 210
local READOUT_GAP = 12          -- clear of the marker, as ANCHOR_RIGHT sits

-- ★★ WHERE THE TOOLTIP WOULD HAVE BEEN. Battlewrath: *"Is it possible to show the
-- information in the same space as the tool-tip would populate. 2 different reading
-- zones is counter-intuitive."*
--
-- It was bottom-left, so the same content appeared in two places depending on
-- whether you hovered or clicked - and you had to know which question you had asked
-- to know where to look. One content source deserves one place.
--
-- Anchored to the CANVAS at the point's offset rather than to the dot frame: dots
-- are pooled and reused every repaint, so a panel anchored to one would follow
-- whatever object inherited that frame.
--
-- ★ Flips to the left near the right edge, which is the one thing the real tooltip
-- does for free and a hand-placed panel does not - without it the reading runs off
-- the art exactly when the point is somewhere interesting. Pure, so the flip can be
-- asserted without a frame.
function Map.ReadoutAnchor(dx, dy, panelW, artW)
    if not dx then return nil end
    local x = dx + READOUT_GAP
    if x + panelW > artW then x = dx - READOUT_GAP - panelW end
    -- No left clamp: it cannot be reached. The flip only fires past dx 780 on a
    -- 1002-wide canvas with a 210-wide panel, and 780 - 222 is still positive. A
    -- line nobody can test is worse than the case it imagines - if the panel ever
    -- grows past the canvas this needs rethinking, not defending.
    return x, dy
end

-- Assigns the forward-declared local above; NOT `local function`, which would
-- shadow it and put the bug straight back.
function fillReadout(point)
    if not readout then return end
    if not point then readout:Hide() return end
    local label, rows = Map.Describe(point)
    local c = TIP_COLOR[Map.ArtKey(point)] or { 1, 1, 1 }
    readout.title:SetText(label)
    readout.title:SetTextColor(c[1], c[2], c[3])
    for i = 1, READOUT_ROWS do
        local kv, r = rows[i], readout.rows[i]
        if kv then
            r.k:SetText(kv[1]); r.v:SetText(kv[2]); r.k:Show(); r.v:Show()
        else
            r.k:Hide(); r.v:Hide()
        end
    end
    -- Positioned where the hover would have put it. If the point is not on the
    -- shown floor there is nothing to sit beside, so the panel goes away rather
    -- than hovering over an empty canvas describing something you cannot see.
    local dx, dy = Map.Offset(point, ART_W, ART_H)
    if not dx or (point.floor and shownFloor and point.floor ~= shownFloor) then
        readout:Hide()
        return
    end
    -- ★ §76: the panel is UI, not map. His call - *"zoom shouldn't mean the content
    -- we can already see well gets malformed."* Anchored to the VIEWPORT in unscaled
    -- pixels, so only its POSITION follows the zoom, never its size.
    local ax, ay = Map.ReadoutAnchor(dx * zoom - panX, dy * zoom + panY, READOUT_W, ART_W)
    readout:ClearAllPoints()
    readout:SetPoint("TOPLEFT", viewport, "TOPLEFT", ax, ay)
    readout:Show()
end

-- Exposed so the pinned reading can be asserted against the hover's - the only way
-- to catch the two drifting apart.
function Map.Readout()
    if not readout or not readout:IsShown() then return nil end
    local out = { readout.title:GetText() }
    for i = 1, READOUT_ROWS do
        local r = readout.rows[i]
        if r.k:IsShown() then
            out[#out + 1] = (r.k:GetText() or "") .. "=" .. (r.v:GetText() or "")
        end
    end
    return out
end

-- The art paint() actually RESOLVED to. Exposed because the resolution is the one
-- step that can put a real route onto the wrong dungeon's tiles, and until now it
-- was only observable by looking at the screen.
function Map.ShownArt() return shownArt end

-- ★ NO ARGUMENT = NO RUN. §36, and it is the retirement of the auto-pick.
--
-- The map opens on the art of where you stand; run data loads only because someone
-- chose it in the selector. Opening a run for you looks like a convenience and is
-- a claim - the old code claimed "most recent" and delivered alphabetical.
function Map.Load(key, id)
    if not frame then return end
    -- An unknown layer is REFUSED, not quietly served by the first one. Falling
    -- through would run a route id through the run store and report "no run named
    -- r1" about a route that exists - a wrong answer dressed as a real one.
    local L = layerDef(key)
    if not L then return end
    local mapID, floor = context()

    local src = nil
    if id then
        src = resolve(key, id)
        if not src then
            NS.Say(("no %s named |cffffd100%s|r"):format(key, tostring(id)))
            return
        end
    end

    -- ★★ THE SELECTION IS CLEARED WHEN IT LEAVES, NOT WHENEVER SOMETHING LOADS.
    --
    -- The guarantee is that nothing is selected which is not on the map: a point
    -- from a run you just swapped away from would sit in the pane describing
    -- evidence no longer on screen. Clearing on EVERY load is the one-slot
    -- assumption again (§62's time reset was the same mistake), and with three slots
    -- it breaks the promoter's whole working gesture - select a node, load a route,
    -- mint - because the node is gone by the time you get there.
    --
    -- Caught live by Battlewrath on §63's first deploy: minting a personal note
    -- loaded the note plane, which dropped the very node it had just copied.
    loaded[key] = src and id or nil

    -- ★★ ONE MAP AT A TIME, and the RUN decides which. His words: *"it is the map
    -- selection. So that's driven by the run. Which does create a conflict."*
    --
    -- The conflict is real: a route authored for one dungeon, left loaded while you
    -- load a run from another, would draw its beacons onto the wrong art - placed by
    -- fraction, so they would look like a plausible route rather than like an error.
    -- Resolved by eviction rather than by a warning: a route that does not belong to
    -- the map now loaded cannot stay on it.
    if key == "run" and src then
        local m = Map.MapIDOf(src)
        local r = resolve("route", loaded.route)
        -- Evicted only when the two are KNOWN to differ. A route with no mapID is
        -- not a route we can say is wrong (§17: never invent a claim about the
        -- dungeon), and List already declines to offer it - so it is unoffered
        -- rather than unloadable.
        if r and m and r.mapID and r.mapID ~= m then loaded.route = nil end
    end

    -- ★ THE NOTE PLANE IS LOAD-DRIVEN LIKE EVERY OTHER LAYER. §63 shipped with the
    -- mint as the only thing that ever loaded it (notes vanished on reload), then
    -- with the PLAYER driving it (they never changed, because your body does not).
    -- Neither was the authoring model: what is loaded decides, and nothing loaded
    -- means nothing shown. Quieting them is SetLayerShown("notes", false) - a
    -- different question from loading them.
    loaded.notes = authoringMapID()

    if not stillLoaded(selected) then selected = nil end
    -- An arm on an object that is no longer on the map is a gesture waiting for
    -- something that cannot be grabbed - and it would silently re-arm if the same
    -- table came back.
    if not stillLoaded(armed) then armed = nil end

    -- ★★ THE ASYMMETRY §61 TURNS ON. Floor seeding and the time reset belong to the
    -- TIMED slot only. Doing them on every load would make loading a route discard
    -- the window you trimmed on the run - which looks like the map forgetting.
    if L.timed then
        shownFloor = src and Map.SeedFloor(src, mapID, floor) or (floor or 0)
        peeking = nil
        Map.ResetTime(src)
    end

    paint(shownFloor)
    -- Whatever the selection IS now - which may be unchanged. Announcing nil
    -- unconditionally would tell every pane to clear a point still on screen.
    fireSelect(selected)
    frame:Show()
    return loaded[key]
end

-- ★ NO ARGUMENT = NO RUN. §36, and it is the retirement of the auto-pick.
--
-- The map opens on the art of where you stand; run data loads only because someone
-- chose it in the selector. Opening a run for you looks like a convenience and is
-- a claim - the old code claimed "most recent" and delivered alphabetical.
function Map.Show(runId) return Map.Load("run", runId) end

-- Reopening keeps what you loaded. Toggling a window is not a decision to discard
-- the run you chose.
-- ---------------------------------------------------------------------
-- ★★ DRAGGING A PROMOTED OBJECT (§68)
--
-- No snapping, no wall detection, no "that is inside geometry" warning.
-- Battlewrath: *"I would leave that to the human eye. We don't need to
-- over-engineer what a map is. It paints walls. Put it past a wall and that's the
-- users doing - and radius still tracks and triggers on it. Pen and paper."*
--
-- The map is 0.1-2.8 yards per pixel across every dungeon floor in the client
-- (typically 0.2-0.7), so the eye is already working below the precision anyone
-- needs. There was nothing to engineer. Whether a placement is GOOD is the route
-- designer's call, exactly as curation never touches the assessment.
-- ---------------------------------------------------------------------

local dragging, dragX, dragY

-- ★★ A DRAG MOVES PIXELS; THE DROP WRITES THE RECORD.
--
-- This wrote through Routes.Place on every frame - so one gesture became sixty
-- writes a second to a saved-variables object, each with its own calibration
-- lookup. The gesture is ONE placement and should be one write.
--
-- Two things fall out beyond the cost. An interrupted drag (the frame hidden, a
-- reload mid-gesture) now leaves the record exactly as it was rather than
-- half-committed at wherever the cursor happened to be. And the object's stored
-- state stops being a moving target for anything reading it while you drag.
--
-- Nothing repaints here either: the full paint runs once on drop, because that is
-- when the ladder has to re-sort the moved object against whatever it landed on.
local function dragTo()
    if not dragging or not dragging.point then return end
    local cx, cy = GetCursorPosition()
    local mx, my = Map.FractionAt(cx, cy, canvas:GetEffectiveScale(),
                                  canvas:GetLeft(), canvas:GetTop())
    if not mx then return end
    dragX, dragY = mx, my
    dragging:ClearAllPoints()
    dragging:SetPoint("CENTER", canvas, "TOPLEFT", mx * ART_W, -(my * ART_H))
end

function Map.BeginDrag(dot)
    -- ★ ARMED, AND THIS EXACT OBJECT. There is no second Draggable check here: the
    -- arm can only ever hold a promoted object (SetMoveArmed refuses anything else),
    -- so `== armed` implies it. A guard whose failure case cannot be reached is not
    -- defence in depth, it is a line nobody can test.
    if not dot or not armed or dot.point ~= armed then return false end
    dragging, dragX, dragY = dot, nil, nil

    -- ★★ NOTHING MAY REPAINT DURING A GRAB. This called Map.Select here, which
    -- repaints - and paint() hides every dot and re-points them from the pool. The
    -- frame you grabbed stops being the thing you grabbed, so the client's drag has
    -- nothing coherent to stop on: OnDragStop never arrives, the OnUpdate keeps
    -- running, and the object stays glued to the cursor. Battlewrath, live: *"On
    -- move, it doesn't listen to a click event to drop the item."*
    --
    -- The select was redundant anyway: you right-clicked the object to open its
    -- editor and pressed its chip, so it is already the selection.
    frame:SetScript("OnUpdate", dragTo)

    -- ★ A CLICK DROPS IT, which is what he reached for. OnDragStop is the client's
    -- own end-of-gesture and stays; this is the answer to a press that never became
    -- one, and to a drag the UI interrupted. Installed with the grab and removed
    -- with it, so the canvas is otherwise as click-through as it was.
    canvas:EnableMouse(true)
    canvas:SetScript("OnMouseDown", function() Map.EndDrag() end)
    return true
end

function Map.EndDrag()
    if not dragging then return end
    dragTo()
    local point = dragging.point
    dragging = nil
    frame:SetScript("OnUpdate", nil)
    canvas:SetScript("OnMouseDown", nil)
    canvas:EnableMouse(false)

    -- The ONE write of the gesture. A drag that never moved (a click that the
    -- client reported as a drag) commits nothing rather than rewriting the same
    -- coordinates back over themselves.
    if dragX and point then
        local R = NS.Routes
        if R and R.Place then
            R.Place(point, dragX, dragY, Map.AuthoringMapID(), shownFloor)
        end
    end
    dragX, dragY = nil, nil
    -- A full repaint rather than leaving the moved dot where the drag left it: the
    -- ladder decides stacking, and a beacon dropped onto a cluster has to re-sort
    -- against it or it is drawn on top of things that outrank it.
    paint(shownFloor)
    fireSelect(selected)
end

function Map.Dragging() return dragging and dragging.point or nil end

-- ---------------------------------------------------------------------
-- ★★ §77: THE MAP CONTROLS WIDGET, his layout.
--
--        [zoom -]   up    [zoom +]
--             <-  Re-centre  ->
--   [x1.25]  down   [Reset]
--   [ ] enable mouse wheel zooming
--   [ ] enable right click panning
--
-- A D-pad, because panning is four directions and a grid says that without a word.
-- The zoom buttons flank it rather than sitting in their own row: they are the same
-- gesture family - move the view - and separating them would imply they were not.
-- ---------------------------------------------------------------------
local controls, stepBtn, wheelTick, panTick

-- ★ The button READS THE VIEW, not a stored index. It shows where you actually are,
-- so a wheel notch or a zoom -/+ nudge that lands off-stage says so honestly (137%)
-- rather than lying about a stage you left.
local function refreshControls()
    -- panTick is the LAST control built, so it standing in for "the widget is
    -- finished" keeps this safe to call from applyView during construction.
    if not panTick then return end
    stepBtn:SetText(("%d%%"):format(math.floor(Map.Zoom() * 100 + 0.5)))
    wheelTick:SetChecked(Map.WheelZoom())
    panTick:SetChecked(Map.RightPan())
end

function buildControls()
    controls = CreateFrame("Frame", "COA_DungeonRunMapControls", UIParent)
    controls:SetWidth(240); controls:SetHeight(168)
    controls:SetPoint("CENTER", UIParent, "CENTER", -420, -180)
    controls:SetFrameStrata("DIALOG")
    controls:SetToplevel(true)
    controls:SetMovable(true); controls:EnableMouse(true)
    controls:RegisterForDrag("LeftButton")
    controls:SetScript("OnDragStart", function(self) self:StartMoving() end)
    controls:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local pt, _, _, x, y = self:GetPoint()
        Store.SetUI("mapControlsPos", { p = pt, x = x, y = y })
    end)
    controls:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    controls:Hide()

    local t = controls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    t:SetPoint("TOPLEFT", 18, -16)
    t:SetText("Map controls")

    local function btn(label, w, x, y, fn)
        local b = CreateFrame("Button", nil, controls, "UIPanelButtonTemplate")
        b:SetWidth(w); b:SetHeight(20)
        b:SetPoint("TOPLEFT", x, y)
        b:SetText(label)
        b:SetScript("OnClick", function() fn(); refreshControls() end)
        return b
    end

    --        [zoom -]   up    [zoom +]
    btn("zoom -", 54, 16, -40, function() Map.StepZoom(-1) end)
    btn("up", 46, 96, -40, function() Map.PanStep(0, -1) end)
    btn("zoom +", 54, 166, -40, function() Map.StepZoom(1) end)
    --             <-  Re-centre  ->
    btn("<", 30, 40, -64, function() Map.PanStep(-1, 0) end)
    btn("Re-centre", 76, 82, -64, function() Map.Recenter() end)
    btn(">", 30, 174, -64, function() Map.PanStep(1, 0) end)
    --   [100%]  down   [Reset]     <- the stage cycler, reading the live zoom
    stepBtn = btn("100%", 54, 16, -88, function() Map.CycleZoomStage() end)
    btn("down", 46, 96, -88, function() Map.PanStep(0, 1) end)
    btn("Reset", 54, 166, -88, function() Map.ResetZoom() end)

    -- ★ Default OFF, both of them. The wheel belongs to the world camera and
    -- right-drag to camera-look; an addon that takes either on install has taken
    -- something nobody offered.
    wheelTick = CreateFrame("CheckButton", "COA_DungeonRunWheelZoom", controls,
                            "UICheckButtonTemplate")
    wheelTick:SetWidth(20); wheelTick:SetHeight(20)
    wheelTick:SetPoint("TOPLEFT", 16, -114)
    local wt = _G and _G["COA_DungeonRunWheelZoomText"]
    if wt then wt:SetText("enable mouse wheel zooming") end
    wheelTick:SetScript("OnClick", function(self) Map.SetWheelZoom(self:GetChecked()) end)

    panTick = CreateFrame("CheckButton", "COA_DungeonRunRightPan", controls,
                          "UICheckButtonTemplate")
    panTick:SetWidth(20); panTick:SetHeight(20)
    panTick:SetPoint("TOPLEFT", 16, -138)
    local pt2 = _G and _G["COA_DungeonRunRightPanText"]
    if pt2 then pt2:SetText("enable right click panning") end
    panTick:SetScript("OnClick", function(self) Map.SetRightPan(self:GetChecked()) end)

    local ui = Store.GetUI()
    if ui.mapControlsPos then
        controls:ClearAllPoints()
        controls:SetPoint(ui.mapControlsPos.p, UIParent, ui.mapControlsPos.p,
                          ui.mapControlsPos.x, ui.mapControlsPos.y)
    end
    refreshControls()
end

function Map.ToggleControls()
    if not controls then return end
    if controls:IsShown() then controls:Hide()
    else controls:Show(); refreshControls() end
end

function Map.ControlsShown() return controls and controls:IsShown() and true or false end

function Map.Toggle()
    if not frame then return end
    if frame:IsShown() then frame:Hide() else Map.Show(loaded.run) end
end

-- Floor paging works with no run loaded: the art is the point of it.
-- Paging by hand TURNS TRACKING OFF rather than fighting it. Otherwise the pager
-- appears broken the moment the window next moves: you press it, the floor changes,
-- and the next scrub silently puts it back.
local function step(delta)
    shownFloor = (shownFloor or 0) + delta
    if shownFloor < 0 then shownFloor = 0 end
    tracking = nil
    paint(shownFloor)
end

-- Exposed so the smoke can assert that tracking actually MOVED the view, and that
-- paging by hand turned it off. Both are invisible from outside otherwise.
-- ★ A pane that removes an object has to ask for a redraw, and must not have to
-- know that `paint` exists or which floor is showing. One call, no arguments, no
-- knowledge of the map's internals - the same shape as every other entry point.
-- ---------------------------------------------------------------------
-- ★ §76: THE ZOOM CONTROLS LIVE ON THE MAP, not in curation.
--
-- Curation owns WHICH DATA is in the picture - trimming, filtering, replay,
-- isolation. The map already owns HOW YOU LOOK at it: the floor pager is in the
-- command strip, not in the pane, and zoom is the same class of thing.
--
-- And it must be direct manipulation. You zoom WHILE DRAWING, with a line half
-- placed - reaching into a third window to change magnification breaks the gesture
-- you are in the middle of. Same reason §71 put the move chip with the object
-- rather than on the promoter: the control belongs to what it acts on.
--
-- View state, so it is never written (§43).
-- ---------------------------------------------------------------------

local function applyView()
    if not canvas then return end
    canvas:SetScale(zoom)
    panX, panY = Map.PanClamp(panX, panY, zoom, ART_W, ART_H)
    -- Scroll offsets are in the CHILD's own units, so the scaled pan divides back.
    viewport:SetHorizontalScroll(panX / zoom)
    viewport:SetVerticalScroll(panY / zoom)
    fillReadout(selected)
    -- ★ The stage button reads the LIVE zoom, so every route that changes it has to
    -- refresh the label - the wheel and zoom -/+ included, not just the button's own
    -- click. Hooked here because applyView is the one place all of them meet.
    refreshControls()
end

function Map.Zoom() return zoom end
function Map.Pan() return panX, panY end

function Map.SetZoom(z)
    if not z then return zoom end
    z = math.max(ZOOM_MIN, math.min(ZOOM_MAX, z))
    if z == zoom then return zoom end
    panX, panY = Map.ZoomAnchor(zoom, z, panX, panY, ART_W, ART_H)
    zoom = z
    applyView()
    return zoom
end

-- Multiplicative, so a notch feels the same at every magnification - additive steps
-- are coarse at 1x and imperceptible at 4x. OUT divides by the same number IN
-- multiplies by, so a click each way returns you exactly where you were.
function Map.StepZoom(delta)
    return Map.SetZoom((delta or 0) > 0 and zoom * ZOOM_STEP or zoom / ZOOM_STEP)
end

-- ★ THE NEXT STAGE ABOVE WHERE YOU ARE, wrapping at the top. Defined against the
-- CURRENT ZOOM rather than against a stored index, which is what makes it survive
-- zoom -/+ nudging you off a stage: from 137% the next stage is 150%, and no index
-- has to be kept in agreement with the view.
function Map.NextStage(z)
    z = z or zoom
    for _, s in ipairs(ZOOM_STAGES) do
        if s > z + 1e-9 then return s end
    end
    return ZOOM_STAGES[1]
end

-- The button's whole action: go there.
function Map.CycleZoomStage()
    return Map.SetZoom(Map.NextStage())
end

function Map.ZoomStages() return ZOOM_STAGES end

-- Back to the whole map. Zoom AND pan, because a reset that left you scrolled
-- somewhere would be a reset that did not reset.
function Map.ResetZoom()
    zoom, panX, panY = 1.0, 0, 0
    applyView()
    return zoom
end

-- ★ Pan by a fraction of the VIEW rather than a fixed pixel count, so the arrows
-- move the same proportion of what you can see at every magnification.
function Map.PanStep(dx, dy)
    return Map.SetPan(panX + (dx or 0) * ART_W * PAN_FRACTION,
                      panY + (dy or 0) * ART_H * PAN_FRACTION)
end

-- The middle of the art. At 1x there is nowhere to go and this is a no-op, which
-- is correct rather than a special case.
function Map.Recenter()
    return Map.SetPan((ART_W * zoom - ART_W) / 2, (ART_H * zoom - ART_H) / 2)
end

-- ---------------------------------------------------------------------
-- ★★ §77: THE TWO GESTURE TICKS ARE PREFERENCES, AND THEY PERSIST.
--
-- §43 says curation state is transient - but *"do I want the wheel to zoom"* is not
-- curation state, it is how someone likes their tools, and the addon already
-- persists frame positions on exactly that reasoning. Zoom and pan stay transient;
-- these do not.
--
-- ★ AND THEY DEFAULT OFF. The wheel belongs to the world camera and right-drag to
-- camera-look; taking either by installing an addon is taking something that was
-- not offered. Opt in, having been told what it costs.
-- ---------------------------------------------------------------------
function Map.WheelZoom() return Store and Store.GetUI().wheelZoom and true or false end
function Map.RightPan() return Store and Store.GetUI().rightPan and true or false end

function Map.SetWheelZoom(on)
    if Store then Store.SetUI("wheelZoom", on and true or nil) end
    if viewport then viewport:EnableMouseWheel(Map.WheelZoom()) end
    return Map.WheelZoom()
end

function Map.SetRightPan(on)
    if Store then Store.SetUI("rightPan", on and true or nil) end
    if viewport then
        viewport:EnableMouse(Map.RightPan())
        viewport:RegisterForDrag(Map.RightPan() and "RightButton" or nil)
    end
    return Map.RightPan()
end

function Map.SetPan(x, y)
    panX, panY = Map.PanClamp(x, y, zoom, ART_W, ART_H)
    applyView()
    return panX, panY
end

-- Pan is a drag like any other here: the OnUpdate exists only while it is in
-- flight, so the census keeps reporting zero persistent.
local panning
local function panTo()
    if not panning then return end
    local cx, cy = GetCursorPosition()
    local s = viewport:GetEffectiveScale()
    Map.SetPan(panning.x - (cx / s - panning.cx), panning.y + (cy / s - panning.cy))
end

function Map.BeginPan()
    local cx, cy = GetCursorPosition()
    local s = viewport:GetEffectiveScale()
    panning = { x = panX, y = panY, cx = cx / s, cy = cy / s }
    frame:SetScript("OnUpdate", panTo)
    return true
end

function Map.EndPan()
    if not panning then return end
    panTo()
    panning = nil
    frame:SetScript("OnUpdate", nil)
end

function Map.Panning() return panning and true or false end

function Map.Repaint()
    if frame and frame:IsShown() then paint(shownFloor) end
end

function Map.Floor() return shownFloor end
Map.StepFloor = step

-- ★ THE COMMAND STRIP (his layout). One header row, and the bottom bar is gone:
--
--   left    what is LOADED, and what it is drawn ON - the reference pair
--   middle  < floor · floor N · floor >
--   right   Curate
--
-- With the tile overhang cropped away the frame is now exactly the map plus this
-- strip: 100 px shorter and 22 px narrower than the version it replaces.
local MARGIN, STRIP, FOOT = 16, 40, 14

function Map.Init()
    Store = NS.Store
    tiles, dots = {}, {}

    frame = CreateFrame("Frame", "COA_DungeonRunMap", UIParent)
    frame:SetWidth(ART_W + MARGIN * 2); frame:SetHeight(ART_H + STRIP + FOOT)
    frame:SetPoint("CENTER")
    -- ★ HIGH, above the action bars. Battlewrath: *"when you're using it, you're
    -- not concerned with your hot bars."* Both frames used to inherit their strata
    -- and competed with whatever else sat at MEDIUM, which is what was bleeding
    -- through the pane. The companion sits a strata ABOVE this one - it annotates
    -- the map, so it must never end up buried under it.
    frame:SetFrameStrata("HIGH")
    frame:SetToplevel(true)
    frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    frame:Hide()

    -- LEFT: the loaded run, then the reference pair at a lighter weight.
    title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", MARGIN + 2, -16)
    ref = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    ref:SetPoint("LEFT", title, "RIGHT", 10, 0)
    ref:SetJustifyH("LEFT")

    -- The canvas IS the coordinate space (1002x668), and now so is the drawn art -
    -- each tile is cropped back to it by Map.TileRect, so the power-of-two padding
    -- the stock map clips is not paid for in frame size either.
    -- §76: the viewport CLIPS; the canvas is what moves and scales inside it.
    viewport = CreateFrame("ScrollFrame", "COA_DungeonRunViewport", frame)
    viewport:SetWidth(ART_W); viewport:SetHeight(ART_H)
    viewport:SetPoint("TOPLEFT", MARGIN, -STRIP)
    -- ★★ §77 ANSWERS §76's OPEN QUESTION, and the answer is A TICK.
    --
    -- §76 shipped the mechanism with NO bindings, on his instruction: *"I'd say stop
    -- at the controls. As there are things to consider - like how a user currently
    -- uses scroll for the world camera of their character."* The wheel belongs to the
    -- world camera and right-drag to camera-look; both are muscle memory a route
    -- author has while standing in a dungeon.
    --
    -- ★ The handlers are wired HERE but the frame is INERT until asked. Neither
    -- EnableMouseWheel nor EnableMouse is called at construction - Map.SetWheelZoom
    -- and Map.SetRightPan own that, they default OFF, and Init applies the stored
    -- preference. So the map you get by installing behaves exactly as §76 shipped it,
    -- and the gesture is something you TOOK rather than something taken from you.
    --
    -- Left-click is untouched either way: RegisterForDrag names RightButton alone, so
    -- the viewport never intercepts a press meant for a marker above it.
    viewport:SetScript("OnMouseWheel", function(_, delta) Map.StepZoom(delta) end)
    viewport:SetScript("OnDragStart", function() Map.BeginPan() end)
    viewport:SetScript("OnDragStop", function() Map.EndPan() end)

    canvas = CreateFrame("Frame", nil, viewport)
    canvas:SetWidth(ART_W); canvas:SetHeight(ART_H)
    viewport:SetScrollChild(canvas)
    for i = 1, TILE_COLS * TILE_ROWS do
        local t = canvas:CreateTexture(nil, "BACKGROUND")
        local x, y, w, h, u, v = Map.TileRect(i)
        if x then
            t:SetWidth(w); t:SetHeight(h)
            t:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, -y)
            t:SetTexCoord(0, u, 0, v)
        else
            t:Hide()
        end
        tiles[i] = t
    end

    -- RIGHT: opens the companion. The map does not otherwise know it exists (§34).
    -- §77: map controls, beside Curate. The map owns how you LOOK at it (§76), so
    -- its controls sit on it rather than in a pane.
    local ctlBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    ctlBtn:SetWidth(70); ctlBtn:SetHeight(20)
    ctlBtn:SetPoint("TOPRIGHT", -MARGIN - 64, -12)
    ctlBtn:SetText("Controls")
    ctlBtn:SetScript("OnClick", function() Map.ToggleControls() end)

    local editBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    editBtn:SetWidth(60); editBtn:SetHeight(20)
    editBtn:SetPoint("TOPRIGHT", -MARGIN, -12)
    editBtn:SetText("Curate")
    editBtn:SetScript("OnClick", function() if NS.Editor then NS.Editor.Toggle() end end)

    -- MIDDLE: floor paging, with the floor itself between its two controls.
    prevBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    prevBtn:SetWidth(52); prevBtn:SetHeight(20)
    prevBtn:SetPoint("TOP", frame, "TOP", -78, -12)
    prevBtn:SetText("< floor")
    prevBtn:SetScript("OnClick", function() step(-1) end)

    floorText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    floorText:SetPoint("TOP", frame, "TOP", 0, -17)

    nextBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    nextBtn:SetWidth(52); nextBtn:SetHeight(20)
    nextBtn:SetPoint("TOP", frame, "TOP", 78, -12)
    nextBtn:SetText("floor >")
    nextBtn:SetScript("OnClick", function() step(1) end)

    -- ★★ §69's PINNED READING, bottom-left ON THE MAP. Hover is transient by
    -- nature - you cannot hold a hover and act at the same time - so the selection
    -- keeps the same reading open while you work on the thing it describes.
    --
    -- Its own frame with a backdrop so it reads as a panel over the art rather than
    -- text scattered on it, and mouse DISABLED: it sits over the canvas and must
    -- never eat a click meant for a dot beneath it.
    readout = CreateFrame("Frame", nil, frame)
    readout:SetWidth(READOUT_W); readout:SetHeight(24 + READOUT_ROWS * 12)
    readout:EnableMouse(false)
    -- Above the dots, so the reading is never drawn under the markers it describes.
    readout:SetFrameLevel(20)
    readout:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    readout:Hide()

    readout.title = readout:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    readout.title:SetPoint("TOPLEFT", 8, -6)
    readout.rows = {}
    for i = 1, READOUT_ROWS do
        local k = readout:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        k:SetPoint("TOPLEFT", 8, -18 - (i - 1) * 12)
        local v = readout:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        v:SetPoint("TOPRIGHT", -8, -18 - (i - 1) * 12)
        readout.rows[i] = { k = k, v = v }
    end

    buildControls()
    Map.SetWheelZoom(Map.WheelZoom())     -- apply the stored preferences
    Map.SetRightPan(Map.RightPan())

    -- No OnUpdate anywhere: the display is redrawn on demand, never per frame.
    return frame
end
