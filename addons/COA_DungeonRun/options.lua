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

-- ★★★ THE STAGE PICKER — self-aware, pool-aware, and 0-free.
BODIES.stage = function()
    return {
        values = function()
            local Routes, Map, out = NS.Routes, NS.Map, {}
            local p = subject()
            if not Routes or not Map or not p then return out end
            local id = Map.LoadedId("route")
            -- ★ THE POOL - every stage this route HAS, so a beacon can be moved beside any
            -- of them, and its OWN is in the list because it is one of them (*"self aware of
            -- their own ordinal"*).
            for _, s in ipairs(Routes.StagesPresent(id)) do out[s] = tostring(s) end
            -- ★★ PLUS THE NEXT LANE. *"Stage 4 - declaring the steps are over and the next
            -- beacon or first child of a beacon picks up stage step 4."* ⚠ `NextStage`
            -- searches from 1, so it can never answer 0.
            local nxt = Routes.NextStage(id)
            if nxt then out[nxt] = tostring(nxt) end
            return out
        end,
        get = function()
            local Routes, p = NS.Routes, subject()
            if not Routes or not p then return nil end
            -- ⚠ RAW. A stage-0 beacon has `stage = nil` and shows BLANK - which is honest:
            -- 0 is not on the offer, so there is no entry that could be selected to say it.
            return p.stage
        end,
        set = function(_, v)
            local Routes, p = NS.Routes, subject()
            if not Routes or not p then return end
            Routes.SetStage(p, tonumber(v))
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

-- ★★★ NEXT — WHAT HAPPENS WHEN THIS NODE COMPLETES (A2.9 · AL-21 · §4d).
--
-- ★★ THE OFFER FOLLOWS WHAT EXISTS, which is the whole reason this is a function:
--     BEACON            go to stage · set stage.        A beacon has no step to go to.
--     CHILD, ordinalled go to step · go to stage · set stage.
--     CHILD, no ordinal go to stage · set stage.        Its step does not exist either -
--                       clearing the ordinal takes it OUT of the line (A2, `routes.lua:1017`).
--
-- ✗ AND *NOTHING FOLLOWS* IS NOT ON IT. §4d lists it under **DERIVED, never shown**; an
-- absent Next IS the outcome, derived from position (A12.5d). AL-21: *no fourth word*.
-- ⟶ The author returns to it by CLEARING the picker, not by selecting an entry - which is
-- §79's shipped shape, *the default stores nothing*, the same one `SetChildSense` uses.
BODIES.next = function()
    return {
        values = function()
            local Routes, out = NS.Routes, {}
            local p = subject()
            if not Routes or not p then return out end
            -- ⚠ BUILT FROM `NEXT_TYPES`, NEVER FROM A LIST HERE. A literal list would be the
            -- second copy that drifts, and §457/§458 are two consecutive commits where a
            -- copied vocabulary did exactly that.
            for _, t in ipairs(Routes.NEXT_TYPES) do
                -- ★ `step` ONLY WHERE A STEP EXISTS TO GO TO.
                local skip = (t == "step") and (p.kind ~= "child" or not Routes.OrdinalOf(p))
                if not skip then out[t] = word(t) end
            end
            return out
        end,
        get = function()
            local Routes, p = NS.Routes, subject()
            if not Routes or not p then return nil end
            return (Routes.NextOf(p))
        end,
        set = function(_, v)
            local Routes, p = NS.Routes, subject()
            if not Routes or not p then return end
            -- ⚠ THE ARG TRAVELS WITH THE TYPE. `SetNext` refuses a `set` with no number and
            -- drops the arg for the other two - *we capture what is currently true* (A13.3).
            local _, arg = Routes.NextOf(p)
            Routes.SetNext(p, v, arg)
        end,
    }
end

-- ★★ SET N's NUMBER. ⚠ ALWAYS SHOWN, deliberately: a control that appears only when
-- another holds a given value is UI-2's CONDITIONAL FIELD and that registry is the UI seat's.
-- ⟶ The half-stated case is guarded by the STORE - `SetNext` refuses `set` without a number -
-- rather than by the pane hiding the box, which is the guard that cannot be bypassed.
BODIES.nextArg = function()
    return {
        get = function()
            local Routes, p = NS.Routes, subject()
            if not Routes or not p then return "" end
            local _, arg = Routes.NextOf(p)
            return arg and ("%g"):format(arg) or ""
        end,
        set = function(_, v)
            local Routes, p = NS.Routes, subject()
            if not Routes or not p then return end
            local nt = Routes.NextOf(p)
            -- ⚠ A NUMBER OR NOTHING. `tonumber` on a typed string is the whole validation the
            -- pane owes; `SetNext` decides whether it is ACCEPTABLE, and refuses if not.
            Routes.SetNext(p, nt, tonumber(v))
        end,
    }
end

-- ★★★ THE NODE-LEVEL LATCH (AL-22/AL-23 · AL-35 · §4d's one owed control).
BODIES.trigger = function()
    return {
        values = function()
            local Routes, out = NS.Routes, {}
            if not Routes then return out end
            -- ⚠ FROM `TRIGGERS`, never a list here. Two words is exactly the size at which a
            -- literal looks harmless, and §457/§458 are two consecutive commits where a copied
            -- vocabulary of that size drifted from the shipped one.
            for _, t in ipairs(Routes.TRIGGERS) do out[t] = word(t) end
            return out
        end,
        get = function()
            local Routes, p = NS.Routes, subject()
            if not Routes or not p then return nil end
            -- ★ THE RESOLVED READING. `TriggerOf` answers what the runtime will DO, so an
            -- unset node shows `once` rather than blank - the same R6 pair the sense uses,
            -- and the reason a picker never displays a state the runtime does not hold.
            return Routes.TriggerOf(p)
        end,
        set = function(_, v)
            local Routes, p = NS.Routes, subject()
            if not Routes or not p then return end
            -- ⚠ `SetTrigger` stores NOTHING for `once` (§79, the default stores nothing), so
            -- selecting it CLEARS rather than writes. The pane does not need to know that.
            Routes.SetTrigger(p, v)
        end,
    }
end

-- ★★★ REACH · THE R — *"the R in which detection is true when within (single point
-- location XY)"* (Battlewrath, 2026-08-27). The plane distance, and nothing else.
--
-- ✗✗ NOT A SLIDER, AND THE STORE IS WHY. §4d describes BAND as *"a slider with its default;
-- the ceiling is a MEASUREMENT the author never sees"*. Two things stopped that here:
--
--   1  NO SUCH MEASUREMENT IS ON DISK. `contract.lua:83` gives `band` a seed of 2.5 and no
--      ceiling; nothing in `driver_architecture`, `driver_data_model` or the asklist records
--      one. A slider needs a maximum, and inventing it is the one thing a declaration must
--      not do. ☐ RAISED, not guessed.
--   2  A SLIDER CANNOT SAY WHAT THE STORE DELIBERATELY ACCEPTS. `setReach`'s own comment:
--      *"clamped rather than refused ... a number outside the range is an author saying
--      BIGGER THAN THAT, and answering with the bound says so."* A slider makes that
--      sentence unsayable - it removes an expression the store was built to answer.
--
-- ★ So both are text, which is also the shipped object pane's shape (`panespec.lua:138`,
-- `object.reach` + `object.reach.up`, two edits on one row). A10.3 replaces those controls
-- with these; nothing rules a change of KIND, so none is made.
BODIES.reach = function()
    return {
        -- ★★★ THE LADDER IS THE OFFER. His steer: *"a limited set that lets them build
        -- without hassle"* - so the author picks a rung rather than typing a number and
        -- discovering afterwards that the store moved it.
        -- ⚠ READ FROM `R_STEPS`, never listed here. The ladder's ends ARE `R_FLOOR` and
        -- `R_CEILING` (`routes.lua:1225`), and a second copy here could drift from all three.
        values = function()
            local Routes, out = NS.Routes, {}
            if not Routes then return out end
            for _, r in ipairs(Routes.R_STEPS) do out[r] = ("%g"):format(r) end
            return out
        end,
        get = function()
            local Routes, p = NS.Routes, subject()
            if not Routes or not p then return nil end
            -- ⚠ THE RAW VALUE, not a formatted one: a `select` matches its KEY, and a route
            -- authored before the ladder existed may hold a number that is not a rung. Such a
            -- node shows BLANK rather than snapping to a rung it never had - the pane reports
            -- what is stored and lets the author choose, which is A4.3's shape for `note`.
            return (Routes.ReachOf(p))
        end,
        set = function(_, v)
            local Routes, p = NS.Routes, subject()
            if not Routes or not p then return end
            -- ⚠ THE PANE DOES NOT CLAMP. `setReach` holds the floor and the ceiling in ONE
            -- place (`routes.lua:2077-2081`), and a second clamp here would be the same
            -- two-bodies fault the note control was corrected for at §684.
            local _, up = Routes.ReachOf(p)
            if p.kind == "beacon" then Routes.SetBeaconReach(p, tonumber(v), up)
            else Routes.SetChildReach(p, tonumber(v), up) end
        end,
    }
end

-- ★★ THE BAND — *"where Z / height is its own criteria"*. ⚠ UPWARD ONLY and ONE VALUE
-- (RI-22): a captured sample IS the floor, so a downward tolerance would measure nothing.
BODIES.band = function()
    return {
        -- ★ THE CLOSED MENU (RI-35), read from `BAND_STEPS` and never listed here.
        values = function()
            local Routes, out = NS.Routes, {}
            if not Routes then return out end
            for _, b in ipairs(Routes.BAND_STEPS) do out[b] = ("%g"):format(b) end
            return out
        end,
        get = function()
            local Routes, p = NS.Routes, subject()
            if not Routes or not p then return nil end
            -- ⚠ RAW, for the same reason R is: a route authored before the ladder may hold a
            -- band that is no rung, and it shows BLANK rather than snapping to one it never
            -- had. The store keeps the NUMBER; the menu is only how it is chosen.
            local _, up = Routes.ReachOf(p)
            return up
        end,
        set = function(_, v)
            local Routes, p = NS.Routes, subject()
            if not Routes or not p then return end
            -- ⚠ THE RADIUS TRAVELS WITH IT. `setReach` takes both and reads a nil as
            -- *unchanged*, so passing the current R back is what keeps this control from
            -- editing the other one by omission.
            local r = Routes.ReachOf(p)
            if p.kind == "beacon" then Routes.SetBeaconReach(p, r, tonumber(v))
            else Routes.SetChildReach(p, r, tonumber(v)) end
        end,
    }
end

-- ★★★ THE WAYPOINT TICK (AL-19) — the FIRST TOUCH that tells a reader where to go.
BODIES.ledTo = function()
    return {
        get = function()
            local Routes, p = NS.Routes, subject()
            if not Routes or not p then return true end
            -- ⚠ THE AUTHOR'S CHOICE, NOT THE RUN-TIME ANSWER. `Routes.LedTo` gates on
            -- `IsPosition` FIRST and would report `false` for a tray-0 node - so reading it
            -- here would show an UNTICKED box the author never unticked, and ticking it back
            -- on would store nothing and change nothing. ★ The position rule hides the
            -- control (below); this reports only what was chosen.
            return p.ledTo ~= false
        end,
        set = function(_, v)
            local Routes, p = NS.Routes, subject()
            if not Routes or not p then return end
            Routes.SetLedTo(p, v and true or false)
        end,
        -- ★★ HIDDEN WHERE THE CONCEPT DOES NOT APPLY — §4d: *"hidden+off tray 0"*.
        --
        -- ⚠⚠ AND THIS IS THE ONE CONTROL THAT IS HIDDEN RATHER THAN DISABLED. The lane's
        -- rule is *disabled, not hidden* (§128) - because a control that does not suit the
        -- SUBJECT still exists and wants a selection. This is different: a stage-0 node or an
        -- ordinalless child is not a POSITION, so nothing is ever led to it whatever the tick
        -- says. Disabled would say *"you cannot set this here"*; the truth is *"there is
        -- nothing here to set"*. ★ `IsPosition` is asked, never re-derived - one rule, one body.
        hidden = function()
            local Routes, p = NS.Routes, subject()
            if not Routes or not p then return false end
            local id = NS.Map and NS.Map.LoadedId("route")
            return not Routes.IsPosition(Routes.StageOf(id, p),
                                         Routes.OrdinalOf(p),
                                         Routes.StandsAlone(p))
        end,
    }
end

-- ★★ THE REFRESH DOOR. ⚠ Adding a tab changes the TABLE's shape, not a value in it, so a
-- `set` alone will not redraw - `AceConfigRegistry:NotifyChange` is what re-reads the options
-- function. ★ It is safe when the registry is absent (offline, and the smokes): the table is
-- still correct, only nothing is on screen to tell.
function Options.Refresh()
    local reg = LibStub and LibStub("AceConfigRegistry-3.0", true)
    if reg and Options.registered then reg:NotifyChange(ADDON) end
end

-- ★★★ ONE TAB — FOUR FIELDS, IN DR_UI_21's ORDER (§4d states it for this surface):
-- **action first, the latch with it, the sense below.**
--
-- ★ CHOOSING THE ACTION APPLIES ITS OFFERED SENSE AND TRIGGER (his ruling, §743) - *"select
-- boss, it sets sense to while on and the trigger type to every time ... then they can be
-- overridden from there."* ⚠ OFFERED, never derived: AL-35 struck the derived reading because
-- it *"would HIDE THE SETTER, which is not programmatic."*
-- ★★ WHICH VERBS HAVE A POOL TODAY. ⚠ A function rather than a table, because the answer
-- differs per SUBJECT for `boss` - the offer is the run's own names, not a constant.
-- ☐ `note` (a NoteID) and `say`'s SUBJECT slot are absent BY GATE, not by oversight: AL-75
-- names both, and a verb with no source pool keeps its text box until one lands.
local function argPool(action)
    local Routes = NS.Routes
    if not Routes or not action then return nil end
    if action == "say" then return Routes.SAY_TERMS end
    return nil
end

local function tabGroup(p, index, row, shown)
    local Routes = NS.Routes

    local function live() return Routes.RowsOf(p)[index] or {} end
    local function write(sense, action, arg)
        Routes.SetRow(nil, p, index, sense, action, arg)
    end

    return {
        type = "group", inline = true, order = 10 + shown,
        -- ★ THE INDEX IS COMPOSED, NEVER STORED - the tab's number is its POSITION, and
        -- storing it would be a second copy of where it already is.
        name = ("%s %d"):format(word("action"), shown),
        args = {
            action = {
                type = "select", order = 1,
                name = function() return word("action") end,
                values = function()
                    local out = {}
                    for _, a in ipairs(Routes.ROW_ACTIONS) do out[a] = word(a) end
                    return out
                end,
                get = function() return live().action end,
                set = function(_, v)
                    local r = live()
                    -- ★★ THE OFFER LANDS WITH THE CHOICE. ⚠ Only where the author has not already
                    -- chosen: re-applying on every set would undo an override the moment the
                    -- action was re-picked, which is the setter hiding itself again.
                    local sense = r.sense or Routes.OfferedSense(v) or "whenOn"
                    write(sense, v, r.arg)
                    if r.trigger == nil then
                        Routes.SetTrigger(live(), Routes.OfferedTrigger(v))
                    end
                    Options.Refresh()
                end,
            },
            trigger = {
                type = "select", order = 2,
                name = function() return word("trigger") end,
                values = function()
                    local out = {}
                    for _, t in ipairs(Routes.TRIGGERS) do out[t] = word(t) end
                    return out
                end,
                get = function() return Routes.TriggerOf(live()) end,
                set = function(_, v) Routes.SetTrigger(live(), v) end,
            },
            -- ★★★ THE ARG PICKS WHERE A POOL EXISTS (AL-75, §747) - *"the store follows the
            -- model; the arg is an ID everywhere."*
            --
            -- ⚠⚠ IT IS **TWO CONTROLS**, and that is not a compromise. AL-75's shapes arrive at
            -- different times: `say`'s CALL pool is published NOW, `note`'s NoteID waits on a
            -- side table that does not exist, and `say`'s SUBJECT waits on capture segment
            -- enrichment. ⟶ A verb whose pool exists gets a SELECT; one whose pool does not is
            -- still typed, and the day its source lands it moves without this file changing
            -- shape again.
            --
            -- ✗ NOT ONE CONTROL THAT GUESSES. A select with an empty list is a picker that
            -- cannot be used; an input for a published pool is the free text the ruling closed.
            argPick = {
                type = "select", order = 3,
                name = function() return word(Routes.ROW_ARG[live().action] or "") end,
                hidden = function() return argPool(live().action) == nil end,
                values = function()
                    local out = {}
                    for _, t in ipairs(argPool(live().action) or {}) do out[t] = t end
                    return out
                end,
                get = function() return live().arg end,
                set = function(_, v)
                    local r = live()
                    -- ★ THE OFFER IS PASSED, so the store REFUSES anything off it - the guard
                    -- AL-75 generalised off `boss` (`routes.lua`, §747).
                    Routes.SetRow(nil, p, index, r.sense, r.action, v, argPool(r.action))
                end,
            },
            arg = {
                type = "input", order = 3,
                -- ✗ NO FIXED LABEL. `ROW_ARG` names it per action - `boss -> name`,
                -- `note -> content` - which the model doc rules: *"fields on the pane depend
                -- on the action word."* A fixed word would name one and lie about the rest.
                name = function() return word(Routes.ROW_ARG[live().action] or "") end,
                -- ★ HIDDEN WHERE THE ACTION TAKES NOTHING, and now also where it PICKS.
                -- `ROW_ARG[action] == nil` means the verb has no argument at all; a pool means
                -- the picker above owns it. An empty box for a value that cannot exist - or
                -- that must be chosen - is a control lying about what it does.
                hidden = function()
                    local a = live().action
                    return Routes.ROW_ARG[a] == nil or argPool(a) ~= nil
                end,
                get = function() return tostring(live().arg or "") end,
                set = function(_, v)
                    local r = live()
                    write(r.sense, r.action, v ~= "" and v or nil)
                end,
            },
            sense = {
                type = "select", order = 4,
                name = function() return word("sense") end,
                values = function()
                    local out = {}
                    for _, s in ipairs(Routes.SENSE_WORDS) do out[s] = word(s) end
                    return out
                end,
                get = function() return live().sense end,
                set = function(_, v)
                    local r = live()
                    write(v, r.action, r.arg)
                end,
            },
        },
    }
end

-- ★★★ THE ACTION TAB STRIP (§744) — his shape, in his words.
--
--     *"[Base behaviour] [Add action]. Add action removes the base text, moves the button to
--      the foot of each action tab."*
--     *"Action 1, add action, action 2."*
--
-- ★★ AND THE BASE BEHAVIOUR IS NOT A NEW RULE - it is what the code already does, written
-- down for the author. His statement of it: *"auto complete the 'player here' check. Moves the
-- tracker to the park position, if no tab argument, follow next."*
--     `manager.lua:614`   a row with NO ACTION completes the moment its sense fires
--     A11.9               with no action tab setting a marker, the tracker writes the PARK
--     AL-21               the node's `Next` does the advancing, never a tab
--
-- ⚠ SO THE STRIP IS A READOUT OF A FACT, NOT A SETTING. A node with no action already behaves
-- this way; the text exists because nothing on screen said so.
local function tabStrip()
    local Routes, out = NS.Routes, {}
    local p = subject()
    if not Routes or not p then return out end

    local rows = Routes.RowsOf(p)
    local authored = 0
    for _, row in ipairs(rows) do
        if row.action ~= nil then authored = authored + 1 end
    end

    -- ★ THE BASE TEXT, ONLY WHILE NOTHING IS AUTHORED. His: *"add action removes the base
    -- text."* ⚠ It is a `description`, not a control - it stores nothing and answers nothing.
    if authored == 0 then
        out.base = {
            type = "description", order = 1,
            name = "This node completes when the reader arrives, parks the tracker, and "
                .. "follows its Next. An action tab is what ELSE has to happen first.",
        }
    end

    -- ★★ ONE TAB PER AUTHORED ROW. ⚠ A row with no action is NOT a tab - it is the seed
    -- (A13.1), and the base text above is its description.
    local shown = 0
    for i, row in ipairs(rows) do
        if row.action ~= nil then
            shown = shown + 1
            out["tab" .. i] = tabGroup(p, i, row, shown)
        end
    end

    -- ★ `add action` AT THE FOOT, always last. His: *"moves the button to the foot."*
    out.add = {
        type = "execute", order = 900,
        name = function() return word("addAction") end,
        func = function()
            local Routes2 = NS.Routes
            local q = subject()
            if not Routes2 or not q then return end
            -- ⚠ THE SEED IS REUSED BEFORE A ROW IS APPENDED. `RowsOf` always returns at least
            -- one row (A13.1's seed: `When on`, no action), so the FIRST `add action` gives that
            -- row an action rather than leaving an actionless row stranded beside a new one.
            local rs = Routes2.RowsOf(q)
            local target = #rs + 1
            for i, r in ipairs(rs) do
                if r.action == nil then target = i break end
            end
            -- ☐ THE NEW TAB PROMPTS. §4d: *"the seed's is When on; an added tab prompts."* An
            -- action is not chosen here - the row is written with the seed's sense and no
            -- action, and the picker asks. Choosing one applies its OFFERED sense and trigger.
            Routes2.SetRow(nil, q, target, rs[target] and rs[target].sense or "whenOn", nil, nil)
            Options.Refresh()
        end,
    }
    return out
end

BODIES.tabs = function()
    return { args = tabStrip() }
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
    -- ★★★ THE FUNCTION, NOT ITS RESULT (§744). `AceConfigRegistry` takes *"table or function
    -- reference"* (`AceConfigRegistry-3.0.lua:316`), and a static table cannot grow a tab: the
    -- strip's entry count is a function of the SUBJECT's rows, read fresh each time the pane is
    -- opened or refreshed. ⚠ This passed `Options.Table()` and would have frozen the strip at
    -- whatever the selection held when the addon loaded.
    reg:RegisterOptionsTable(ADDON, Options.Table)
    Options.registered = true
end
