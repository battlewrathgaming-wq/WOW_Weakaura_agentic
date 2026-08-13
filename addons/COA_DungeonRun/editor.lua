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
-- THIS SLICE adds §36's LOAD SELECTOR, at the top - his ordering, deliberately:
-- "it's why I pushed that order, instead of putting it on the map and then taking
-- it out and putting it into the editing suite."
--
-- NOT here yet: promotion into lanes (§29), notes, or any editing of a point. The
-- pane is an INSPECTOR plus a loader; authoring lands on top of it.

local ADDON, NS = ...

local Editor = {}
NS.Editor = Editor

local Map, Store
local f, title, dd, kindText, rows, hint

local MAX_ROWS = 10          -- Describe never returns more; the surplus would be silent
local NO_RUN = "- no run -"

local function refresh()
    if not f then return end
    local point = Map.Selected()
    local label, list = Map.Describe(point)

    -- Track what the MAP actually has loaded rather than what we last clicked.
    -- The two can only diverge through another entry point, and a selector that
    -- quietly disagrees with the picture is worse than no selector.
    if dd then UIDropDownMenu_SetText(dd, Map.LoadedId() or NO_RUN) end

    kindText:SetText(label)
    for i = 1, MAX_ROWS do
        local r = rows[i]
        local entry = list[i]
        if entry then
            r.k:SetText(entry[1])
            r.v:SetText(entry[2])
            r.k:Show(); r.v:Show()
        else
            r.k:Hide(); r.v:Hide()
        end
    end
    -- ★ Say when the readout is TRUNCATED rather than showing a short list that
    -- looks complete - the same rule task_dump holds about silent caps.
    if #list > MAX_ROWS then
        hint:SetText(("... +%d more field(s) than this pane shows"):format(#list - MAX_ROWS))
    elseif not Map.LoadedId() then
        hint:SetText("pick a run above")
    elseif not point then
        hint:SetText("click a point on the map")
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

function Editor.Init()
    Map, Store = NS.Map, NS.Store

    f = CreateFrame("Frame", "COA_DungeonRunEditor", UIParent)
    f:SetWidth(280); f:SetHeight(330)
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

    kindText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    kindText:SetPoint("TOPLEFT", 18, -76)

    rows = {}
    for i = 1, MAX_ROWS do
        local k = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        k:SetPoint("TOPLEFT", 18, -98 - (i - 1) * 15)
        k:SetWidth(70); k:SetJustifyH("LEFT")
        local v = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        v:SetPoint("TOPLEFT", 92, -98 - (i - 1) * 15)
        v:SetWidth(170); v:SetJustifyH("LEFT")
        rows[i] = { k = k, v = v }
    end

    hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("BOTTOMLEFT", 18, 18)

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
