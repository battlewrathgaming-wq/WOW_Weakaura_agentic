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

local NO_RUN = "- no run -"

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

    if not Map.LoadedId() then
        hint:SetText("pick a run above")
    else
        hint:SetText("trimming, replay and isolation land here")
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

function Editor.Init()
    Map, Store = NS.Map, NS.Store

    f = CreateFrame("Frame", "COA_DungeonRunEditor", UIParent)
    f:SetWidth(280); f:SetHeight(190)
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

    local show = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    show:SetPoint("TOPLEFT", 18, -68)
    show:SetText("show")

    filters = {}
    for i, spec in ipairs(FILTERS) do
        local name = "COA_DungeonRunFilter" .. spec.key
        local cb = CreateFrame("CheckButton", name, f, "UICheckButtonTemplate")
        cb:SetWidth(22); cb:SetHeight(22)
        cb:SetPoint("TOPLEFT", 16, -84 - (i - 1) * 24)
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

    hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", 18, -84 - #FILTERS * 24)
    hint:SetWidth(244); hint:SetJustifyH("LEFT")

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetWidth(60); closeBtn:SetHeight(20)
    closeBtn:SetPoint("BOTTOMRIGHT", -14, 14)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() Editor.Toggle() end)

    -- One-way: we ask Map to tell us. Map never looks for us.
    Map.SetOnSelect(refresh)

    local ui = Store.GetUI()
    if ui.editorPos then
        f:ClearAllPoints()
        f:SetPoint(ui.editorPos.p, UIParent, ui.editorPos.p, ui.editorPos.x, ui.editorPos.y)
    end

    refresh()
    return f
end

function Editor.Toggle()
    if not f then return end
    if f:IsShown() then f:Hide() else f:Show(); refresh() end
end
