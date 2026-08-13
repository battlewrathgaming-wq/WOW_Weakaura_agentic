-- COA_DungeonRun editor.lua - the COMPANION pane.
--
-- Spec: addons/planning/dungeonrun_poc.md §34.
--
-- ---------------------------------------------------------------------------
-- ★ WHY A SEPARATE FRAME, in his words: "isolates the bug fixing / edits."
--
-- Not screen space and not tidiness - BUILD HYGIENE. A bug in here cannot break
-- the map, and either can be worked on without touching the other. Same
-- discipline as store.lua owning the DB alone and the smokes testing modules
-- separately: separation for diagnosability.
--
-- It also means this pane can be rebuilt or thrown away without risking the
-- surface that is now proven working (§27, §32).
--
-- ★ THE COUPLING IS ONE-WAY. Map owns selection and fires a callback; it holds no
-- reference to this file and does not know whether anything is listening. This
-- file reads Map, never the reverse.
-- ---------------------------------------------------------------------------
--
-- THIS SLICE: the frame, the selection readout, and nothing else.
-- NOT here yet: the load selector (next, and it goes at the TOP of this pane -
-- §34's correction), promotion into lanes (§29), notes, or any editing at all.
-- The pane is an INSPECTOR first; authoring lands on top of it.

local ADDON, NS = ...

local Editor = {}
NS.Editor = Editor

local Map, Store
local f, title, kindText, rows, hint

local MAX_ROWS = 10          -- Describe never returns more; the surplus would be silent

local function refresh()
    if not f then return end
    local point = Map.Selected()
    local label, list = Map.Describe(point)

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
    elseif not point then
        hint:SetText("click a point on the map")
    else
        hint:SetText("")
    end
end
Editor.Refresh = refresh

function Editor.Init()
    Map, Store = NS.Map, NS.Store

    f = CreateFrame("Frame", "COA_DungeonRunEditor", UIParent)
    f:SetWidth(260); f:SetHeight(300)
    f:SetPoint("CENTER", UIParent, "CENTER", 560, 0)
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

    kindText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    kindText:SetPoint("TOPLEFT", 18, -40)

    rows = {}
    for i = 1, MAX_ROWS do
        local k = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        k:SetPoint("TOPLEFT", 18, -60 - (i - 1) * 15)
        k:SetWidth(70); k:SetJustifyH("LEFT")
        local v = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        v:SetPoint("TOPLEFT", 92, -60 - (i - 1) * 15)
        v:SetWidth(150); v:SetJustifyH("LEFT")
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
