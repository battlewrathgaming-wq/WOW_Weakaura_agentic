-- COA_DungeonRun editor.lua - the COMPANION pane.
--
-- Spec: addons/planning/dungeonrun_poc.md §34, §36.
--
-- ---------------------------------------------------------------------------
-- ★ WHY A SEPARATE FRAME, in his words: "isolates the bug fixing / edits."
--
-- Not screen space and not tidiness - BUILD HYGIENE. A bug in here cannot break
-- the map, and either can be worked on without touching the other. Same
-- discipline as store.lua owning the DB alone and the smokes testing modules
-- separately: separation for diagnosability.
--
-- ★ THE DEPENDENCY RUNS ONE WAY, and now in two forms - so state it exactly:
--
--     selection   map -> here    the map OWNS it and fires one optional callback
--     loading     here -> map    we call Map.Show(id), a public entry point
--
-- Both are this file depending on the map's API. The map holds NO reference to
-- this one and does not know whether anything is listening - asserted directly in
-- the smoke, because that is the isolation the companion exists for. (The single
-- exception is the map's Curate button, which is guarded and does nothing but
-- open us.)
-- ---------------------------------------------------------------------------
--
-- ★ WHAT THIS PANE IS FOR (Battlewrath, 2026-08-13) - three surfaces, three
-- questions:
--
--     map         what IS this?          the picture, and point facts on hover
--     curation    what am I LOOKING at?  trimming, filtering, replay selection,
--                                        isolation - configuring presentation
--     promotion   what does this BECOME? §29's lanes, offsets, z-inheritance
--                                        (a SEPARATE pane, not built)
--
-- ★ AND IT SETTLES DR-9. "A point is written as captured; we never clean, merge or
-- dedupe" was in apparent tension with an editor that trims. It is not, under this
-- split: **CURATION EDITS THE VIEW, NEVER THE CAPTURE.** A trimmed wipe is hidden,
-- not deleted; an isolated pull is a filter, not a subset written back. Promotion
-- is the only thing that produces durable objects, and §29 already says it COPIES.
-- Two panes, two verbs, and neither can damage the record.
--
-- Consequence worth stating: curation state is PER-VIEW. It does not belong in the
-- record at all.
--
-- THIS SLICE is the loader only. The readout that used to live here moved to the
-- map's tooltip, where the facts belong. The four controls are designed but not
-- built - and the pane SAYS that rather than looking broken while it is empty.

local ADDON, NS = ...

local Editor = {}
NS.Editor = Editor

local Map, Store
local f, title, dd, hint, filters
local commentBox, delBtn, renameBtn
local bar, envFill, winFill, envL, envR, widthText, playBtn, skipText, peekBtn, latchBtn
local trackBtn
local playing, peekHeld, peekLatched

local NO_RUN = "- no run -"

local BAR_W = 244             -- the time bar's track, in pixels
local GRAB_PX = 16            -- the handles' invisible grab area (the visual is 4)

-- mm:ss. The unit pair is min/sec because that is the scale runs live at -
-- RFC_Run3_Messy spans 800 seconds.
local function clock(sec)
    sec = math.max(0, math.floor(sec or 0))
    return ("%d:%02d"):format(math.floor(sec / 60), sec % 60)
end

-- Seconds -> pixels on the track, and back. Pure enough to reason about, and the
-- only place the two coordinate systems meet.
local function toPx(sec, span)
    if not span or span <= 0 then return 0 end
    return math.max(0, math.min(BAR_W, (sec / span) * BAR_W))
end
local function toSec(px, span)
    if not span or span <= 0 then return 0 end
    return math.max(0, math.min(span, (px / BAR_W) * span))
end

-- ★ §43's FILTERING, and the four it will grow into. Each row is an art key the
-- map can hide - a VIEW filter, never a change to the record.
--
-- DR-35 is what makes the first one necessary rather than nice: sampling in combat
-- fills the gap the third draw exposed, and in-pull movement is genuinely messy.
-- Battlewrath: *"combat movement is very messy when in-pull."* The truthful view
-- needs a way to be quietened, not a decision at capture time about what to keep.
local FILTERS = {
    { key = "combatleg", label = "combat legs" },
    { key = "leg",       label = "travel legs" },
}

local function refresh()
    if not f then return end

    -- Track what the MAP actually has loaded rather than what we last clicked.
    -- The two can only diverge through another entry point, and a selector that
    -- quietly disagrees with the picture is worse than no selector.
    if dd then UIDropDownMenu_SetText(dd, Map.LoadedId() or NO_RUN) end

    -- The boxes read from the MAP, for the same reason the selector does: a
    -- control that disagrees with the picture is worse than no control.
    for _, cb in ipairs(filters or {}) do
        cb:SetChecked(not Map.Hidden(cb.filterKey))
    end

    local id = Map.LoadedId()
    local run = id and Store.Get(id)

    -- §48's limited management is only meaningful with a run loaded.
    commentBox:SetText((run and run.comment) or "")
    if run then commentBox:Enable() else commentBox:Disable() end

    -- The bar draws the ENVELOPE as the filled track and the WINDOW as the bright
    -- band inside it - the two quantities are different lengths on screen, which is
    -- the cheapest way to stop them being confused for one another.
    local span = Map.Span()
    local lo, hi = Map.Envelope()
    local pos, width = Map.Window()
    if span and span > 0 then
        bar:Show()
        local x1, x2 = toPx(lo, span), toPx(hi, span)
        envFill:ClearAllPoints()
        envFill:SetPoint("LEFT", bar, "LEFT", x1, 0)
        envFill:SetWidth(math.max(1, x2 - x1))
        -- ★ Never let the two sit on the same pixel: one would hide the other and
        -- whichever is on top takes every press. Purely a DRAW nudge - the envelope
        -- itself is untouched, so the numbers stay honest.
        local hx1, hx2 = Map.SeparateHandles(x1, x2, BAR_W)
        envL:ClearAllPoints(); envL:SetPoint("CENTER", bar, "LEFT", hx1, 0)
        envR:ClearAllPoints(); envR:SetPoint("CENTER", bar, "LEFT", hx2, 0)

        local w1, w2 = toPx(pos, span), toPx(pos + width, span)
        winFill:ClearAllPoints()
        winFill:SetPoint("LEFT", bar, "LEFT", w1, 0)
        winFill:SetWidth(math.max(2, w2 - w1))
        widthText:SetText(("window %s  of  %s - %s"):format(clock(width), clock(lo), clock(hi)))
        skipText:SetText(("skip %ss"):format(Map.SkipStep()))
    else
        bar:Hide()
        widthText:SetText("")
        skipText:SetText("")
    end

    -- ★ The peek button reads from the MAP too, so a latch left on is visible
    -- rather than something you are silently sitting inside.
    latchBtn:SetChecked(peekLatched)
    -- Reads from the MAP, like every other control here: paging floors by hand
    -- turns tracking off, and the box has to show that rather than lie about it.
    trackBtn:SetChecked(Map.TrackingFloor())
    playBtn:SetText(playing and "Pause" or "Play")

    if not id then
        hint:SetText("pick a run above")
    elseif Map.Peeking() then
        hint:SetText("|cffffd100peeking|r - the whole run, ticks still applied")
    else
        hint:SetText("")
    end
end
Editor.Refresh = refresh

-- ★ §36's list, built fresh on every open of the menu.
--
-- Runs for the dungeon you are STANDING IN come first, then everything else
-- alphabetically - and the grouping is drawn as titles rather than left implicit,
-- so the ordering is visible instead of something the user has to infer.
--
-- Location SORTS it. Nothing here picks for you: "- no run -" is a real entry,
-- because unloading has to be as reachable as loading.
local function initDropdown()
    local _, _, _, hereMapID = GetCurrentPlayerPosition()
    local list = Map.RunList(hereMapID)

    local info = UIDropDownMenu_CreateInfo()
    info.text = NO_RUN
    info.notCheckable = 1
    info.func = function() Map.Show(nil); refresh() end
    UIDropDownMenu_AddButton(info)

    if #list == 0 then
        local h = UIDropDownMenu_CreateInfo()
        h.text = "no runs recorded"; h.isTitle = 1; h.notCheckable = 1
        UIDropDownMenu_AddButton(h)
        return
    end

    local group
    for _, e in ipairs(list) do
        local g = e.here and "in this dungeon" or "other dungeons"
        if g ~= group then
            group = g
            local h = UIDropDownMenu_CreateInfo()
            h.text = g; h.isTitle = 1; h.notCheckable = 1
            UIDropDownMenu_AddButton(h)
        end
        local b = UIDropDownMenu_CreateInfo()
        -- The ID, not the name: it is unique, and it is the same handle /dr list
        -- and /dr delete use. Two runs may share a name.
        b.text = e.id
        b.notCheckable = 1
        b.func = function() Map.Show(e.id); refresh() end
        UIDropDownMenu_AddButton(b)
    end
end

-- ★ StaticPopup rather than custom dialogs: it is the client's own confirm path,
-- so it looks and behaves like everything else the user already knows. Same reason
-- the whole addon avoids bespoke widgets - custom code locks users out.
--
-- Delete is CONFIRMED and names what it is deleting. It is the only destructive
-- verb in the pane and it takes a whole run.
local function installPopups()
    StaticPopupDialogs["COA_DR_RENAME"] = {
        text = "Rename run:", button1 = ACCEPT or "Accept", button2 = CANCEL or "Cancel",
        hasEditBox = 1, maxLetters = 60,
        OnShow = function(self)
            local box = self.editBox or _G["StaticPopup1EditBox"]
            local run = Store.Get(Map.LoadedId())
            if box and run then box:SetText(run.name or "") end
        end,
        OnAccept = function(self)
            local box = self.editBox or _G["StaticPopup1EditBox"]
            local id = Map.LoadedId()
            if id and box then Store.Rename(id, box:GetText()) end
            Map.Show(id)
            Editor.Refresh()
        end,
        timeout = 0, whileDead = 1, hideOnEscape = 1,
    }
    StaticPopupDialogs["COA_DR_DELETE"] = {
        text = "Delete the run %s?\n\nThis removes the whole capture. It cannot be undone.",
        button1 = DELETE or "Delete", button2 = CANCEL or "Cancel",
        OnAccept = function()
            local id = Map.LoadedId()
            if id then Store.Delete(id) end
            Map.Show(nil)
            Editor.Refresh()
        end,
        timeout = 0, whileDead = 1, hideOnEscape = 1, showAlert = 1,
    }
end

function Editor.Init()
    Map, Store = NS.Map, NS.Store

    f = CreateFrame("Frame", "COA_DungeonRunEditor", UIParent)
    f:SetWidth(280); f:SetHeight(366)
    f:SetPoint("CENTER", UIParent, "CENTER", 560, 0)
    -- ★ DIALOG - one strata ABOVE the map. The pane annotates the map, so it must
    -- never be buried under it; and both now sit above the action bars, which is
    -- what the inherited MEDIUM strata was letting bleed through.
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, _, x, y = self:GetPoint()
        Store.SetUI("editorPos", { p = p, x = x, y = y })
    end)
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    f:Hide()

    title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 18, -16)
    title:SetText("Curation")

    dd = CreateFrame("Frame", "COA_DungeonRunLoad", f, "UIDropDownMenuTemplate")
    dd:SetPoint("TOPLEFT", 2, -32)
    UIDropDownMenu_Initialize(dd, initDropdown)
    UIDropDownMenu_SetWidth(dd, 200)
    UIDropDownMenu_JustifyText(dd, "LEFT")
    UIDropDownMenu_SetText(dd, NO_RUN)

    -- ---------------------------------------------------------------
    -- ★ §48's LIMITED MANAGEMENT. Rename, comment, delete - all RUN-level.
    -- DELETE IS THE ONLY DESTRUCTIVE VERB IN THE PANE and it takes a whole run,
    -- deliberately: nothing anywhere removes a single point.
    -- ---------------------------------------------------------------
    renameBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    renameBtn:SetWidth(70); renameBtn:SetHeight(20)
    renameBtn:SetPoint("TOPLEFT", 16, -66)
    renameBtn:SetText("Rename")
    renameBtn:SetScript("OnClick", function()
        local id = Map.LoadedId()
        if id then StaticPopup_Show("COA_DR_RENAME", id) end
    end)

    delBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    delBtn:SetWidth(70); delBtn:SetHeight(20)
    delBtn:SetPoint("TOPLEFT", 92, -66)
    delBtn:SetText("Delete")
    delBtn:SetScript("OnClick", function()
        local id = Map.LoadedId()
        if id then StaticPopup_Show("COA_DR_DELETE", id) end
    end)

    -- 40 characters, enforced by the widget as well as by the store - a cap the
    -- user can SEE stop them is better than one that silently truncates on save.
    commentBox = CreateFrame("EditBox", "COA_DungeonRunComment", f, "InputBoxTemplate")
    commentBox:SetWidth(232); commentBox:SetHeight(20)
    commentBox:SetPoint("TOPLEFT", 22, -92)
    commentBox:SetAutoFocus(false)
    commentBox:SetMaxLetters(Store.COMMENT_MAX)
    commentBox:SetScript("OnEnterPressed", function(self)
        local id = Map.LoadedId()
        if id then Store.SetComment(id, self:GetText()) end
        self:ClearFocus()
    end)
    commentBox:SetScript("OnEscapePressed", function(self) self:ClearFocus(); refresh() end)

    local show = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    show:SetPoint("TOPLEFT", 18, -120)
    show:SetText("show")

    filters = {}
    for i, spec in ipairs(FILTERS) do
        local name = "COA_DungeonRunFilter" .. spec.key
        local cb = CreateFrame("CheckButton", name, f, "UICheckButtonTemplate")
        cb:SetWidth(22); cb:SetHeight(22)
        cb:SetPoint("TOPLEFT", 16, -136 - (i - 1) * 24)
        -- The template's label is $parentText. Built from the name we already
        -- hold rather than asking the frame for it back.
        local txt = _G and _G[name .. "Text"]
        if txt then txt:SetText(spec.label) end
        cb.filterKey = spec.key
        cb:SetScript("OnClick", function(self)
            -- CHECKED means SHOWN, so the box reads as the thing it does.
            Map.SetHidden(self.filterKey, not self:GetChecked())
        end)
        filters[i] = cb
    end

    -- ---------------------------------------------------------------
    -- ★ §48's TIME FILTER. Rung 2 and rung 3 of the ladder, and the bar draws
    -- BOTH quantities at once because they are different things: the ENVELOPE is
    -- the dim filled track (where the window may go) and the WINDOW is the bright
    -- band inside it (what is on screen).
    -- ---------------------------------------------------------------
    bar = CreateFrame("Frame", nil, f)
    bar:SetWidth(BAR_W); bar:SetHeight(12)
    bar:SetPoint("TOPLEFT", 18, -190)
    bar:EnableMouse(true)
    local track = bar:CreateTexture(nil, "BACKGROUND")
    track:SetAllPoints(bar)
    track:SetTexture(0.15, 0.15, 0.15, 0.8)

    envFill = bar:CreateTexture(nil, "ARTWORK")
    envFill:SetHeight(12); envFill:SetTexture(0.30, 0.35, 0.45, 0.9)
    envFill:SetPoint("LEFT", bar, "LEFT", 0, 0)

    winFill = bar:CreateTexture(nil, "OVERLAY")
    winFill:SetHeight(12); winFill:SetTexture(0.55, 0.80, 1.00, 0.9)
    winFill:SetPoint("LEFT", bar, "LEFT", 0, 0)

    -- Clicking the track moves the WINDOW there. The two envelope handles are
    -- separate draggable marks, so shrinking the envelope can never be mistaken for
    -- scrolling - they are the same gesture on different objects otherwise.
    bar:SetScript("OnMouseDown", function(self)
        local span = Map.Span()
        if not span then return end
        local x = (GetCursorPosition() / self:GetEffectiveScale()) - self:GetLeft()
        local _, width = Map.Window()
        Map.SetWindow(toSec(x, span) - (width or 0) / 2, width)
        refresh()
    end)

    -- ★★ THE HANDLES, REWORKED (his report: "when they're set right against the
    -- time scale in the envelope, they get stuck and stop responding").
    --
    -- Three causes, all of them in the input path rather than the arithmetic:
    --
    -- ★★ FACT: [SILENT] RegisterForDrag has a MOVEMENT THRESHOLD - a small precise nudge
    --   never starts a drag at all, and nothing reports the miss. ⚠ It reads as the handle
    --   IGNORING you. Press-to-grab (OnMouseDown + OnUpdate) has no threshold.
    --   1. RegisterForDrag has a MOVEMENT THRESHOLD. A small precise nudge - which
    --      is exactly what the handles are for, "more granular than the -/+" - never
    --      starts a drag at all. Press-to-grab has no threshold.
    --   2. The bar UNDERNEATH takes a click as "move the window". Miss the 8 px
    --      handle by a pixel and something else happens, which reads as the handle
    --      ignoring you rather than as a miss. Now the handles sit ABOVE the bar and
    --      swallow their own clicks.
    --   3. At the extremes half the handle hangs off the track, and two handles at
    --      the same second overlap EXACTLY - so one hides the other and whichever is
    --      on top takes every press.
    --
    -- So: a 16 px invisible grab area over a 4 px visual, a higher frame level, and
    -- a minimum pixel separation enforced at draw time.
    local function handle(which)
        local h = CreateFrame("Button", nil, f)
        h:SetWidth(GRAB_PX); h:SetHeight(20)
        h:SetFrameLevel(bar:GetFrameLevel() + 5)
        h:RegisterForClicks("LeftButtonDown", "LeftButtonUp")
        local t = h:CreateTexture(nil, "OVERLAY")
        t:SetWidth(4); t:SetHeight(18)
        t:SetPoint("CENTER", h, "CENTER", 0, 0)
        t:SetTexture(1, 0.82, 0, 1)
        -- ★ The drag ticker is INSTALLED ON DRAG START AND CLEARED ON STOP.
        --
        -- The first version left it registered permanently with a `if not dragging
        -- then return end` guard at the top - which reads as throttled and is not:
        -- it is a handler running every frame, forever, for two pixels of drag.
        -- `emit_addon_census.py` reported it as this addon's FIRST persistent
        -- OnUpdate and that is the whole reason the census exists. Same discipline
        -- as capture's sampler and the playback ticker.
        local function drag(self)
            local span = Map.Span()
            if not span then return end
            -- Clamped to the TRACK. Without it a cursor past either end maps to a
            -- second outside the run, the clamp in SetEnvelope pins it, and the
            -- handle sits still while you keep dragging - which is what "stuck at
            -- the ends" felt like.
            -- ⚠ `bar`'s scale, not `self`'s. The cursor is in SCREEN pixels and must
            -- be divided by the effective scale of the frame it is compared against -
            -- and this compares against `bar:GetLeft()`. The handle is a CHILD of the
            -- bar so the two scales match today, which made this correct by
            -- coincidence rather than by construction. Same class as the Landmarks
            -- minimap button, found in the same audit.
            local x = (GetCursorPosition() / bar:GetEffectiveScale()) - bar:GetLeft()
            x = math.max(0, math.min(BAR_W, x))
            local lo, hi = Map.Envelope()
            if which == "lo" then Map.SetEnvelope(toSec(x, span), hi)
            else Map.SetEnvelope(lo, toSec(x, span)) end
            refresh()
        end
        -- Press to grab, release to let go. No threshold, so a one-pixel nudge lands.
        -- Still installed-on-demand, so the census stays at zero persistent OnUpdate.
        h:SetScript("OnMouseDown", function(self) self:SetScript("OnUpdate", drag) end)
        h:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", nil) end)
        -- A grab that ends off the button would otherwise leave it stuck to the
        -- cursor - the exact "stops responding" this is fixing.
        h:SetScript("OnHide", function(self) self:SetScript("OnUpdate", nil) end)
        return h
    end
    envL, envR = handle("lo"), handle("hi")

    widthText = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    widthText:SetPoint("TOPLEFT", 18, -208)

    -- [-] time [+] : the WINDOW WIDTH. Halve and double rather than a fixed step,
    -- so the control spans a 13-minute run and a 5-second pull with the same
    -- number of presses.
    local function widthBtn(label, dx, factor)
        local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        b:SetWidth(22); b:SetHeight(20)
        b:SetPoint("TOPLEFT", dx, -226)
        b:SetText(label)
        b:SetScript("OnClick", function()
            local pos, width = Map.Window()
            if not width then return end
            Map.SetWindow(pos, width * factor)
            refresh()
        end)
        return b
    end
    widthBtn("-", 16, 0.5)
    widthBtn("+", 42, 2)

    local function stepBtn(label, dx, dir)
        local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        b:SetWidth(22); b:SetHeight(20)
        b:SetPoint("TOPLEFT", dx, -226)
        b:SetText(label)
        b:SetScript("OnClick", function()
            local pos, width = Map.Window()
            if not pos then return end
            Map.SetWindow(pos + dir * Map.SkipStep(), width)
            refresh()
        end)
        return b
    end
    stepBtn("<", 76, -1)
    stepBtn(">", 156, 1)

    playBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    playBtn:SetWidth(50); playBtn:SetHeight(20)
    playBtn:SetPoint("TOPLEFT", 102, -226)
    playBtn:SetText("Play")
    playBtn:SetScript("OnClick", function() Editor.TogglePlay() end)

    skipText = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    skipText:SetPoint("TOPLEFT", 184, -231)

    -- ---------------------------------------------------------------
    -- ★ §48's PEEK, and §49 is why the latch beside it exists.
    --
    -- Held is the default gesture. But hold-to-peek plus click-a-point is TWO
    -- GESTURES AT ONCE - Battlewrath: "purely peek would be a race or frustration"
    -- - and you must be able to ACT inside the peeked view without editing the
    -- envelope to get there. So a small latch holds it open.
    --
    -- Peeking is `held OR latched`: one state, two ways in, and the latch is
    -- visibly depressed so it is never something you are silently sitting inside.
    -- ---------------------------------------------------------------
    peekBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    peekBtn:SetWidth(60); peekBtn:SetHeight(20)
    peekBtn:SetPoint("TOPLEFT", 16, -252)
    peekBtn:SetText("Peek")
    peekBtn:SetScript("OnMouseDown", function() peekHeld = true; Editor.SyncPeek() end)
    peekBtn:SetScript("OnMouseUp", function() peekHeld = nil; Editor.SyncPeek() end)

    latchBtn = CreateFrame("CheckButton", "COA_DungeonRunPeekLatch", f, "UICheckButtonTemplate")
    latchBtn:SetWidth(20); latchBtn:SetHeight(20)
    latchBtn:SetPoint("TOPLEFT", 80, -252)
    latchBtn:SetScript("OnClick", function(self)
        peekLatched = self:GetChecked() and true or nil
        Editor.SyncPeek()
    end)

    -- ★ RESET, under the controls it resets. A narrowed envelope had no way back
    -- except reloading the run - which also threw the selection away. Time only:
    -- the tick filters are a separate rung and this must not reach across.
    local resetBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    resetBtn:SetWidth(60); resetBtn:SetHeight(20)
    resetBtn:SetPoint("TOPLEFT", 110, -252)
    resetBtn:SetText("Reset")
    resetBtn:SetScript("OnClick", function() Map.ResetView(); refresh() end)

    -- ★★ TRACK THE MOST RECENT NODE. SFK_Run4 is why: floor index is not route
    -- order, so scrubbing across a transition empties the map with nothing on
    -- screen to say where the route went.
    trackBtn = CreateFrame("CheckButton", "COA_DungeonRunTrack", f, "UICheckButtonTemplate")
    trackBtn:SetWidth(20); trackBtn:SetHeight(20)
    trackBtn:SetPoint("TOPLEFT", 16, -276)
    local trackTxt = _G and _G["COA_DungeonRunTrackText"]
    if trackTxt then trackTxt:SetText("track most recent node") end
    trackBtn:SetScript("OnClick", function(self)
        Map.SetTrackFloor(self:GetChecked())
        refresh()
    end)

    hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", 18, -302)
    hint:SetWidth(244); hint:SetJustifyH("LEFT")

    -- ★★ THE THIRD SURFACE OPENS FROM HERE, at the BOTTOM (Battlewrath, 2026-08-14):
    -- *"the open button lives on the bottom of curation. It natively suggests.
    -- Map -> Curation -> Promotion."*
    --
    -- The bottom because that is this pane's own reading order - selector, identity,
    -- filters, time - and promotion is what you do once you have sliced it down. At
    -- the top it would compete with the run selector and invite promoting before you
    -- had looked at anything.
    --
    -- ★ AND IT SUGGESTS RATHER THAN SEQUENCES. His correction, taken: *"the order is
    -- button presses. Nothing forced as in sequence. In reality the map doesn't
    -- care.. it just accepts load conditions."* So this opens a frame and asserts
    -- nothing - no state is passed, nothing is checked, and the promoter works just
    -- as well opened first.
    local promoteBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    promoteBtn:SetWidth(110); promoteBtn:SetHeight(20)
    promoteBtn:SetPoint("BOTTOMLEFT", 16, 14)
    promoteBtn:SetText("Promotion")
    promoteBtn:SetScript("OnClick", function()
        if NS.Promoter then NS.Promoter.Toggle() end
    end)

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetWidth(60); closeBtn:SetHeight(20)
    closeBtn:SetPoint("BOTTOMRIGHT", -14, 14)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() Editor.Toggle() end)

    installPopups()

    -- One-way: we ask Map to tell us. Map never looks for us.
    Map.AddOnSelect(refresh)

    local ui = Store.GetUI()
    if ui.editorPos then
        f:ClearAllPoints()
        f:SetPoint(ui.editorPos.p, UIParent, ui.editorPos.p, ui.editorPos.x, ui.editorPos.y)
    end

    refresh()
    return f
end

-- One state, two ways in.
function Editor.SyncPeek()
    Map.SetPeek(peekHeld or peekLatched)
    refresh()
end

-- ★ PLAYBACK IS AUTO-SKIP, once a second, and that is not an arbitrary rate: it
-- makes Play obey the same invariant as the buttons. Ten steps crosses whatever
-- you framed, so ten seconds plays it - whether that is a pull or the whole run.
-- No speed control, because the window width already IS the speed control.
--
-- The OnUpdate exists ONLY while playing. Same discipline as capture's sampler,
-- and what keeps the census reporting zero persistent OnUpdate.
local acc = 0

local function tick(_, elapsed)
    acc = acc + elapsed
    if acc < 1.0 then return end
    acc = 0
    local pos, width = Map.Window()
    local _, hi = Map.Envelope()
    if not pos then Editor.StopPlay() return end
    if pos + width >= hi then Editor.StopPlay() return end   -- ran off the end
    Map.SetWindow(pos + Map.SkipStep(), width)
    refresh()
end

function Editor.StopPlay()
    playing = nil
    acc = 0
    if f then f:SetScript("OnUpdate", nil) end
    refresh()
end

function Editor.TogglePlay()
    if playing then Editor.StopPlay() return end
    if not Map.Window() then return end
    playing, acc = true, 0
    f:SetScript("OnUpdate", tick)
    refresh()
end

function Editor.Toggle()
    if not f then return end
    if f:IsShown() then
        -- Closing the pane must not leave a timer running behind it.
        Editor.StopPlay()
        f:Hide()
    else
        f:Show(); refresh()
    end
end
