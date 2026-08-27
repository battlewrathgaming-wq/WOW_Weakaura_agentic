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
-- =====================================================================
-- ★★★ THE SUBJECT IS THE SELECTION (AL-60, his words 2026-08-25: *"For the object. The
-- subject is the selection. So a beacon (or child) or a node on the map from Run."*)
--
-- ⚠ READ, NEVER STORED. `interface/object.md:63` records the same rule for the pane this
-- replaces - *"reads `Map.Selected()` - the subject, never stored"* - and a cached subject
-- is a pane describing something the map has already stopped pointing at.
-- =====================================================================
local function subject()
    local Map = NS.Map
    local p = Map and Map.Selected and Map.Selected() or nil
    if p and (p.kind == "beacon" or p.kind == "note" or p.kind == "child") then
        return p
    end
    return nil
end

local function parentOf(p)
    local Map, Routes = NS.Map, NS.Routes
    if not p or p.kind ~= "child" or not Map or not Routes then return nil end
    return Routes.ParentOf(Map.LoadedId("route"), p)
end

-- ★★ EVERY LABEL RESOLVES THROUGH THE ONE LOOKUP (A5.1). A10.2's own mutation row is
-- *"type a folded label as a literal in `options.lua` → A5.3's 1:1 check reds it"*, so a
-- string typed here rather than asked for is the fault this fold exists to prevent.
-- ⚠ A MISS PASSES THROUGH THE CODE TERM, deliberately (A5.1): an unmapped word shows as
-- itself rather than as a blank, so a gap in the table is visible instead of silent.
local function word(code)
    local A = NS.Adaptor
    return (A and A.Word and A.Word(code)) or tostring(code)
end

-- =====================================================================
-- ★★★ THE BEHAVIOUR LIVES HERE; THE INVENTORY LIVES IN `panes_decl.lua`.
--
-- His shape, 2026-08-26: *"a flat template desk side of what content lives on each table of
-- content."* ⟶ WHICH controls and in WHAT order is data; what each one READS and WRITES is
-- code, and code is the one thing a declaration must not try to hold.
--
-- ⚠ KEYED BY THE DECLARATION'S OWN KEY. A body with no entry in the table is never built,
-- and an entry with no body here is a REFUSAL rather than a blank control - see `build`.
-- =====================================================================
local BODIES = {}

BODIES.sense = function()
    return {
        -- ⚠⚠ IT OFFERS EXACTLY ONE VALUE TODAY AND THAT IS THE RULING WORKING, not a stub.
        -- `Routes.SENSES` is EMPTY and its emptiness is RI-15/17's ruling - boss LEFT the
        -- sense list to become an ACTION word, and `falling` / `in combat` are GATES rather
        -- than senses. `reachHere` is the DEFAULT and was never in the list, because §79's
        -- rule is that the default stores nothing.
        -- ★ So the offer is built FROM the list: the day a state sense lands, this offers it
        -- with no edit here. The smoke proves that by GROWING the list, because with an
        -- empty one a pane that ignored it entirely would pass every count.
        values = function()
            local Routes = NS.Routes
            local out = {}
            if not Routes then return out end
            out[Routes.SENSE_DEFAULT] = word(Routes.SENSE_DEFAULT)
            for _, s in ipairs(Routes.SENSES) do out[s] = word(s) end
            return out
        end,
        get = function()
            local Routes, p = NS.Routes, subject()
            if not Routes or not p then return nil end
            -- ⚠ THE RESOLVED READING, not the raw one. R6's pair: `SenseOf` answers *was
            -- this authored* and `Sense` answers *what does this node do*. A picker shows
            -- what it DOES, or an unset node displays blank while behaving like `reachHere`.
            return Routes.Sense(p)
        end,
        set = function(_, v)
            local Routes, p = NS.Routes, subject()
            if not Routes or not p then return end
            Routes.SetChildSense(parentOf(p), p, v)
        end,
    }
end

BODIES.ordinal = function()
    return {
        -- ⚠ A STRING INPUT, NOT A RANGE. The ordinal takes decimals (a child inserted
        -- between 1 and 2 is 1.5) and CLEARING it is a meaning of its own - out of the line
        -- on purpose (`routes.lua:1017`) - and neither is expressible on a slider.
        get = function()
            local Routes, p = NS.Routes, subject()
            local n = Routes and p and Routes.OrdinalOf(p)
            return n and ("%g"):format(n) or ""
        end,
        set = function(_, v)
            local Routes, p = NS.Routes, subject()
            if not Routes or not p then return end
            -- ★ `tonumber` OF AN EMPTY STRING IS nil, which is exactly the opt-out
            -- `SetChildOrdinal` already takes. A branch here would be a second place that
            -- decides what empty means.
            Routes.SetChildOrdinal(parentOf(p), p, tonumber(v))
        end,
    }
end

BODIES.note = function()
    return {
        -- ⚠⚠ THE PANE DOES NOT CAP. `Routes.SetRouteNote` already does
        -- (`routes.lua:2535`), so capping here too would enforce one rule in two places -
        -- and a first cut DID, under a comment congratulating itself for asking for
        -- `NOTE_MAX` rather than typing 200. ★ Avoiding the LITERAL while duplicating the
        -- ENFORCEMENT is the same fault one layer up; the mutation caught it by staying
        -- silent when one of the two was broken.
        get = function()
            local Routes, Map, p = NS.Routes, NS.Map, subject()
            if not Routes or not Map or not p then return "" end
            -- ★ THE PAIR IS ASKED FOR, NEVER ASSEMBLED. `parentOf(p), p` here returned
            -- `nil, beacon` for a beacon and the note was silently lost.
            local id = Map.LoadedId("route")
            return Routes.RouteNoteOf(id, Routes.NoteAnchorOf(id, p)) or ""
        end,
        set = function(_, v)
            local Routes, Map, p = NS.Routes, NS.Map, subject()
            if not Routes or not Map or not p then return end
            local id = Map.LoadedId("route")
            local b, c = Routes.NoteAnchorOf(id, p)
            Routes.SetRouteNote(id, b, c, v)
        end,
    }
end

-- ★★★ ONE LANE, BUILT FROM ITS DECLARATION. Nothing below names a control; the table does.
-- ⚠ A DECLARED CONTROL WITH NO BODY IS REFUSED LOUDLY rather than rendered blank: a
-- control that draws and does nothing is the worst of the three states, because it looks
-- authored. `Options.Missing()` reports them and the smoke asserts the list is empty.
local MISSING = {}

local function buildLane(key)
    local Panes = NS.Panes
    local lane = Panes and Panes.lanes[key]
    if not lane then return nil end

    local args = {}
    for i, c in ipairs(lane.controls) do
        local body = BODIES[c.key] and BODIES[c.key]() or nil
        -- ⚠⚠ A KIND ACECONFIG CANNOT FORM IS NOT BUILT, and that is a DEFERRAL rather than
        -- a refusal. `DR_Pane_4`: content Ace cannot form EARNS its own frame - so the
        -- control waits for that decision instead of being handed to a Registry that would
        -- reject the WHOLE TABLE and take every other lane down with it.
        -- ★ `Panes.Unformable()` names them; nothing is silently dropped.
        if body and not Panes.ACE_KINDS[c.kind] then body = nil end
        if not body then
            MISSING[#MISSING + 1] = key .. "." .. tostring(c.key)
        else
            body.type = c.kind
            body.order = i               -- ★ THE ORDER IS THE LIST'S. Position in the
                                         -- declaration IS the arrangement (`DR_Pane_4`).
            body.name = function() return word(c.word) end
            body.desc = c.desc
            if c.multiline then body.multiline = true end
            -- ★★ DISABLED, NOT HIDDEN, when the subject does not suit. Disabled says *this
            -- exists and needs a subject*; hidden says nothing at all - the rule the
            -- remote's pin has carried since §128.
            body.disabled = function()
                local p = subject()
                return not Panes.Applies(c, p and p.kind or nil)
            end
            args[c.key] = body
        end
    end
    return args, lane
end

-- ⚠ READ AFTER `Options.Table()`. A declared control with no body is a build fault, and a
-- build fault nobody asks about is one nobody fixes.
function Options.Missing() return MISSING end

function Options.Table()
    return {
        type = "group",
        name = "Dungeon Run",
        childGroups = "tab",           -- ★ TABS AS LANES (D-B: "one surface, many jobs")
        args = {
            -- ★★ RENAMED 2026-08-25 (AL-56, from AI-31): `run` → `curate`. The key
            -- collided with the OTHER side of AL-49's split - *"Run capture"* is the
            -- REMOTE's first tab, on the RUNNING surface, while this lane holds CURATION
            -- on the AUTHORING surface. One word, two surfaces, opposite sides.
            -- ⚠ Verb form to match `promote`. Free while every lane is empty, which is
            -- exactly why it was done now and not after the first fold.
            --
            -- ⚠⚠ THE DISPLAY MOVED TOO, AND THAT HALF IS THE BENCH COMPLETING THE RULING
            -- RATHER THAN OBEYING IT. AL-56 ruled the KEY and observed only that displays
            -- may differ from keys. But a tab still LABELLED "run" beside a remote tab
            -- called "Run capture" is the collision a user actually reads - fixing the key
            -- alone would have mended the invisible half. ⟶ `curation`, matching AL-49's
            -- own naming (Curation · Promotion · Object). One line to revert if that
            -- over-reached.
            curate = {
                type = "group", name = "curation", order = 1,
                args = {},             -- A10.2a folds editor.lua's curation bar in LAST
            },
            promote = {
                type = "group", name = "promoter", order = 2,
                args = {},
            },
            -- ★★★ THE THREE LANES ARE BUILT FROM `panes_decl.lua`, not listed here.
            -- ⚠ The lane KEYS stay literal: `smoke_dungeonrunoptions` pins them by name and
            -- A10.1a's structural check is *three groups at the root and nothing beside
            -- them* - a root assembled from a loop could not be asserted against a shape
            -- nobody typed.
            node = {
                type = "group", name = "node editor", order = 3,
                -- ★★★ A10.2a's THREE SURVIVORS, folded 2026-08-26 (§687). Its order is
                -- *"`object.sense` · `object.ordinal` · `object.note` FIRST - the three the
                -- checker cannot see today AND the three that SURVIVE into the node
                -- editor"*, and the rest of the object pane is REPLACED by A10.3, never
                -- folded.
                --
                -- ⚠⚠ A10.2's OWN ROW SAYS THIS ORDER *"cannot be executed at the current
                -- height"*. That is STALE and rests on a ceiling RI-46 removed: the
                -- question's premise was measured false the day it was asked (714 was an
                -- estimate; the real cost was 575 under a 600 ceiling), and the drained
                -- outcome is *"the pane does NOT have to hold everything · 600 is NOT the
                -- side panel's budget · the bolt-on has the MAP SURFACE'S vertical
                -- extent"*. ⟶ `paneSeat:SetHeight(mh)` below already builds that. There is
                -- no height coupling left to be blocked by.
                -- ★★★ BUILT FROM `panes_decl.lua`, never listed here. The declaration
                -- says WHICH controls and in WHAT order; `BODIES` above says what each one
                -- reads and writes. ⚠ A list in both places is the second copy that
                -- drifts, and the `layout` skill states the rule this rests on: *"the
                -- builder must READ this table, not mirror it."*
                args = buildLane("node") or {},
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
-- ★★★ THE ONE FRAME - TWO SEATS (A10.1a)
-- ---------------------------------------------------------------------
--
-- Battlewrath: *"The map and the side unified options are planned to be one frame, with
-- the pop outs solving exposing everything into their own frames/panes."*
--
-- So: an AceGUI Frame holding a MAP SEAT and a PANE SEAT, side by side. The lanes are
-- opened INTO the pane seat, which is the same call pop-out will make with a different
-- container - `AceConfigDialog:Open(app, container)`.
--
-- ⚠⚠ THE MAP SEAT HAS NO LAYOUT, AND THAT IS THE WHOLE POINT. An AceGUI container lays
-- its children out, which means SIZING them. The map's canvas must never be sized by a
-- layout engine: `Map.FractionAt` divides by the COORDINATE SPACE (1002x668), and a
-- canvas resized to fit a container puts back the +2.2% / +15% silent error `map.lua:46`
-- was written about. ★ The seat RESERVES space; it does not arrange anything.
function Options.BuildFrame()
    local gui = LibStub and LibStub("AceGUI-3.0", true)
    local dlg = LibStub and LibStub("AceConfigDialog-3.0", true)
    if not gui or not dlg or not Options.registered then return nil end

    local mw, mh = Options.MapFloor()
    if not mw then return nil end          -- ⚠ no floor, no frame: see MapFloor
    local fw, fh = Options.FrameSize()

    local win = gui:Create("Frame")
    win:SetTitle("Dungeon Run")
    win:SetLayout("Flow")
    win:SetWidth(fw); win:SetHeight(fh)

    -- ★ THE MAP SEAT. Sized to the floor, laid out by nobody.
    local mapSeat = gui:Create("SimpleGroup")
    mapSeat:SetLayout(nil)
    mapSeat:SetWidth(mw); mapSeat:SetHeight(mh)
    win:AddChild(mapSeat)

    -- The pane seat: the lanes live here, and the same subtree goes to a floating
    -- container when a lane pops out.
    local paneSeat = gui:Create("SimpleGroup")
    paneSeat:SetLayout("Fill")
    paneSeat:SetWidth(PANE_W); paneSeat:SetHeight(mh)
    win:AddChild(paneSeat)

    dlg:Open(ADDON, paneSeat)

    Options.win, Options.mapSeat, Options.paneSeat = win, mapSeat, paneSeat
    return win
end

-- ★★ SEATING THE MAP - a re-parent and NOTHING ELSE.
--
-- ⚠ It does not resize the map, does not scale it, and does not clear its scale. The
-- only thing it is allowed to change is which frame the map hangs from. Everything the
-- accuracy depends on - the coordinate space, the canvas's own size, `canvas:SetScale`
-- for zoom - is left exactly as the map set it.
--
-- ★ AND IT REFUSES A SEAT THAT IS TOO SMALL, with the reason. Battlewrath's rule: the
-- container *"can already be greater than, can never be lesser than, the map frame."*
function Options.SeatMap(mapFrame)
    if not Options.mapSeat then return false, "no map seat - build the frame first" end
    if not mapFrame then return false, "no map frame to seat" end

    local seat = Options.mapSeat.content or Options.mapSeat.frame
    if not seat then return false, "the map seat has no content frame" end

    -- ⚠ THE SEAT'S SIZE IS ITS FRAME'S. An AceGUI widget has `SetWidth` but no
    -- `GetWidth` - the number lives on `widget.frame`. Asking the widget returns nil
    -- rather than erroring, which is a measurement that silently is not one.
    local sf = Options.mapSeat.frame
    local ok, why = Options.Fits(sf and sf:GetWidth(), sf and sf:GetHeight())
    if not ok then return false, why end

    mapFrame:SetParent(seat)
    mapFrame:ClearAllPoints()
    mapFrame:SetPoint("TOPLEFT", seat, "TOPLEFT", 0, 0)
    return true
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
    if Options.win and Options.win.frame and Options.win.frame:IsShown() then
        Options.win.frame:Hide()
    elseif Options.win and Options.win.frame then
        Options.win.frame:Show()
    else
        Options.BuildFrame()
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
