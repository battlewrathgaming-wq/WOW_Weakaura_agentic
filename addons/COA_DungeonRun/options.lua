-- COA_DungeonRun options.lua - THE ONE FRAME, declared as an Ace option table (A10.1).
--
-- Model: addons/planning/DRIVER_BASIS.md   READ FIRST. It names what governs NOW, in
--        precedence order, and it MOVES when a ruling moves - so this line never
--        goes stale. Lower number wins; a disagreement is reported, not resolved here.
--
-- ---------------------------------------------------------------------------
-- ★★★ SUBTREES KEYED BY LANE, NEVER ONE FLAT TABLE (A10.1a).
--
-- Battlewrath's diagram shows the three lanes twice: docked in the unified input pane,
-- and again as three knocked-out columns. They are THE SAME THREE GROUPS IN TWO
-- CONTAINERS - so the same subtree goes to `AceConfigDialog:Open(app, container)` with a
-- different container, and pop-out costs a container rather than a rebuild.
--
-- ★★ AND POP-OUT IS LOAD-BEARING, not deferred chrome. Battlewrath: *"the pop outs
-- solving exposing everything into their own frames/panes."* It is what lets one frame
-- hold the map AND the options without crowding - anything that needs its own space
-- leaves. Which is exactly why the subtree shape is settled before the first control
-- lands, not after.
--
-- ---------------------------------------------------------------------------
-- ★★★ THE MAP IS THE FLOOR, AND THIS IS AN ACCURACY RULE WEARING A LAYOUT HAT.
--
-- Battlewrath, 2026-08-18: *"The map sizing stays a constant and defines the parent
-- container size. Can already be greater than, can never be lesser than, the map frame."*
--
-- ⚠⚠ WHY IT MATTERS MORE THAN IT LOOKS. `map.lua:46` records a [SILENT] fact: the
-- COORDINATE SPACE (`ART_W, ART_H` = 1002x668, the stock `WorldMapDetailFrame`) and the
-- TILE ART (4x3x256 = 1024x768) are two different sizes, and confusing them still
-- renders - just wrong, by +2.2% across and +15% DOWN, worst furthest from the origin.
-- It was caught by eye on the first art-bearing draw, by nothing mechanical.
--
-- ★ `Map.FractionAt` divides by ART_W/ART_H. So the coordinate space is not a display
-- size and must never become one. A container that RESIZES the canvas re-introduces the
-- silent error; a container that SCALES it uniformly (`canvas:SetScale`, which is what
-- zoom already uses) does not.
--
-- ★★ HENCE THE INVARIANT THIS FILE EXISTS TO KEEP:
--
--     the frame's map region is >= the map frame, always, and the coordinate space
--     is not a number this file is allowed to know
--
-- The floor is READ from `Map.ArtSize()` rather than typed, so it cannot drift from the
-- thing it is protecting. ⚠ And the map canvas is never an AceGUI-MANAGED child: it is
-- parented into a container's content with its own size and its own scale, because a
-- layout engine sizing its children is precisely the mechanism that would break this.

local ADDON, NS = ...

local Options = {}
NS.Options = Options

local Map, Store

-- ★ THE MAP'S OWN CHROME, from map.lua's Init. Read here rather than re-typed; if the
-- map's frame grows, the floor grows with it and nothing here has to be remembered.
local MAP_MARGIN, MAP_STRIP, MAP_FOOT = 16, 40, 14

-- The unified input pane column. ⚠ A DISPLAY number and nothing more - no coordinate
-- meaning, so it is allowed to be typed.
local PANE_W = 240
local GAP = 8

-- ---------------------------------------------------------------------
-- THE FLOOR
-- ---------------------------------------------------------------------

-- The map frame's size, derived from the COORDINATE SPACE plus the map's own chrome.
-- ⚠ Returns nil rather than a guess when the map has not published its size - a floor
-- invented while the real one is unknown is the silent error with extra steps.
function Options.MapFloor()
    if not Map or not Map.ArtSize then return nil end
    local w, h = Map.ArtSize()
    if not w or not h then return nil end
    return w + MAP_MARGIN * 2, h + MAP_STRIP + MAP_FOOT
end

-- ★★ THE ONE FRAME'S SIZE. Map floor + the pane column. It may be larger; it may never
-- be smaller, and `Options.Fits` is the assertion form of that sentence.
function Options.FrameSize()
    local mw, mh = Options.MapFloor()
    if not mw then return nil end
    return mw + GAP + PANE_W, mh
end

-- ⚠ THE GUARD, not a comment about one. Any container asked to hold the map answers to
-- this, and it reports WHICH dimension failed rather than a bare false - a frame that is
-- wide enough and too short is a different fault from one that is too narrow.
function Options.Fits(w, h)
    local mw, mh = Options.MapFloor()
    if not mw then return false, "the map has published no size" end
    if not w or not h then return false, "the container has no size" end
    if w < mw then
        return false, ("too NARROW: %g < the map's %g"):format(w, mw)
    end
    if h < mh then
        return false, ("too SHORT: %g < the map's %g"):format(h, mh)
    end
    return true
end

-- ---------------------------------------------------------------------
-- THE OPTION TABLE - three lanes, and nothing at the root beside them (A10.1a)
-- ---------------------------------------------------------------------
--
-- ⚠ EMPTY LANES ARE THE POINT AT THIS STAGE. A10.1a: *"Empty lanes acceptable at first
-- render."* The folds (A10.2) fill them one pane at a time, in a stated order, while the
-- old hand-built panes keep working. Nothing here is a placeholder for a control that
-- will not arrive; each lane is the real home its fold lands in.
--
-- ★ Every user-visible string still goes through the adaptor (A5.x) when it carries a
-- code term. `run`, `promoter` and `node editor` are the author's own words already.
function Options.Table()
    return {
        type = "group",
        name = "Dungeon Run",
        childGroups = "tab",           -- ★ TABS AS LANES (D-B: "one surface, many jobs")
        args = {
            run = {
                type = "group", name = "run", order = 1,
                args = {},             -- A10.2a folds editor.lua's curation bar in LAST
            },
            promote = {
                type = "group", name = "promoter", order = 2,
                args = {},
            },
            node = {
                type = "group", name = "node editor", order = 3,
                args = {},             -- A10.2a folds sense · ordinal · note in FIRST
            },
        },
    }
end

-- ★ A10.1a's structural check, as a function rather than a claim: three groups at the
-- root and nothing else beside them. The pane's shape is a fact the smoke can ask for.
function Options.Lanes(tbl)
    tbl = tbl or Options.Table()
    local lanes, others = {}, {}
    for k, v in pairs(tbl.args or {}) do
        if type(v) == "table" and v.type == "group" then
            lanes[#lanes + 1] = k
        else
            others[#others + 1] = k
        end
    end
    table.sort(lanes); table.sort(others)
    return lanes, others
end

-- ---------------------------------------------------------------------
-- ★★ THE DOOR (A10.1d) - "no typed command the author must already know"
-- ---------------------------------------------------------------------
--
-- Battlewrath's reason for the whole rework: *"menu / command fatigue."* So the frame
-- is reached by a CONTROL, and `/dr` may alias it but is never the surface. It sits
-- beside `remote.map` on the capture widget, which is the door that already exists.
--
-- ⚠ TOLD, NEVER SILENT (S4). If the shipped Ace copy is missing there is no frame to
-- open, and a button that does nothing when clicked is worse than one that says why.
function Options.Toggle()
    local dlg = LibStub and LibStub("AceConfigDialog-3.0", true)
    if not dlg or not Options.registered then
        NS.Say("|cffff8080Dungeon Run: the options frame is not available - "
               .. "AceConfigDialog-3.0 did not load. Check Libs/ in the addon folder.|r")
        return
    end
    if dlg.OpenFrames and dlg.OpenFrames[ADDON] then
        dlg:Close(ADDON)
    else
        dlg:Open(ADDON)
    end
end

function Options.Init()
    Map, Store = NS.Map, NS.Store

    -- ⚠ TOLD, NEVER SILENT (S4). Without the shipped Ace copy this addon has no frame,
    -- and an editor that quietly has no options is worse than one that says so.
    local reg = LibStub and LibStub("AceConfigRegistry-3.0", true)
    if not reg then
        NS.Say("|cffff8080Dungeon Run: AceConfigRegistry-3.0 is missing - the options "
               .. "frame cannot be built. Check Libs/ in the addon folder.|r")
        return
    end
    reg:RegisterOptionsTable(ADDON, Options.Table())
    Options.registered = true
end
