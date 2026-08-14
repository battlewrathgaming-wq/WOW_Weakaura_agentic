-- COA_DungeonRun promoter.lua - THE THIRD SURFACE.
--
-- Spec: addons/planning/dungeonrun_poc.md §29, §56, §60, §61, §62.
--
-- ---------------------------------------------------------------------------
-- ★ THREE SURFACES, THREE QUESTIONS (Battlewrath, 2026-08-13):
--
--     map         what IS this?          the picture, and point facts on hover
--     curation    what am I LOOKING at?  trimming, filtering, replay, isolation
--     promotion   what does this BECOME? <- this file
--
-- Its own frame for the same build-hygiene reason the curator has one (§34): a bug
-- in here cannot break either of the others, and the dependency runs ONE WAY - we
-- call the map's public API, the map holds no reference to us.
--
-- ★ THE ORDER IS BUTTON PRESSES, NOT A SEQUENCE (Battlewrath, 2026-08-14).
--
-- The open button lives at the bottom of curation, so the layout suggests
-- map -> curation -> promotion. It SUGGESTS. Nothing here checks how you arrived,
-- refuses to open, or requires a loaded run: the map accepts load conditions and
-- does not care which order they came in. His words: *"without opening and loading
-- curation/run, the edit palette of promotion has little meaning"* - that is a
-- statement about VALUE, not a gate, and worst case the walk is *"like opening a
-- briefcase."* A macro hook can skip it for power users precisely because nothing
-- in the chain is load-bearing.
--
-- ★ CREATE THEN EDIT - the house pattern's third appearance. The beacon exists the
-- moment you press the button, carrying only what it inherited (§29 COPIES); cue,
-- note, radii and icon are edited in-field afterwards. Capture then promote · pin
-- then meaning · mint then author. THE MECHANICAL PART IS IMMEDIATE AND THE MEANING
-- WAITS - which is also why none of the three needs a dialog.
--
-- THIS SLICE IS THE MINT. The in-field editors (name · cue · note · stage ·
-- radius listen · radius close · icon pick) and the Manage half (list, renumber,
-- drag, delete, pre-flight walk) are designed in §61 and NOT BUILT - and the pane
-- says so rather than looking broken while it is empty.
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local Promoter = {}
NS.Promoter = Promoter

local Map, Store, Routes
local f, dd, nameBox, nameLabel, renameBtn, noteBtn, createBtn, inherit, hint, countText

local NO_ROUTE = "- no route -"
local NEW_ROUTE = "+ create new"

-- Which mode the NAME control is in. Not inferred from what you typed - the
-- dropdown declared it (§61), which is the whole reason `+ create new` is an entry
-- in the list rather than a separate button beside it.
local creating

-- ★ PROMOTION IS FROM A CAPTURED NODE. A beacon or a personal note is already a
-- promoted object, so minting from one is not promotion - it is duplication, and it
-- would quietly produce beacons whose position came from a thing someone had
-- already dragged. Refused as a fact about the data (that is not a node), the same
-- shape as §61's other two refusals rather than a new rule.
--
-- ⚠ MY call, not his: §61 says "no creation from nothing" and does not name this
-- case. Cheap to reverse - delete the function and its one caller.
local function isPromoted(p) return p and (p.kind == "beacon" or p.kind == "note") end

local function selectedNode()
    local p = Map.Selected and Map.Selected() or nil
    return (not isPromoted(p)) and p or nil
end

-- What is ACTUALLY selected, promoted or not - so the pane can say WHY it refused
-- instead of behaving as though nothing were selected at all.
local function rawSelected() return Map.Selected and Map.Selected() or nil end

local function hereMapID()
    local _, _, _, mapID = GetCurrentPlayerPosition()
    return mapID
end

-- ★ Every control reads from the MAP and the STORE, never from what we last
-- clicked. Same discipline as the curation pane: a control that disagrees with the
-- picture is worse than no control.
local function refresh()
    if not f then return end

    local id = Map.LoadedId("route")
    if dd then
        UIDropDownMenu_SetText(dd, creating and NEW_ROUTE or (id or NO_ROUTE))
    end

    -- §61: the name field stops being dual-purpose. Text entry when creating,
    -- because you must type something; a LABEL with a Rename button when a route is
    -- selected. The field never has to distinguish modes on its own.
    local route = id and Routes.Get(id)
    if creating then
        nameBox:Show(); nameLabel:Hide(); renameBtn:Hide()
    else
        nameBox:Hide(); nameLabel:Show(); renameBtn:Show()
        nameLabel:SetText(route and ((route.name ~= "" and route.name) or id) or "")
        if route then renameBtn:Enable() else renameBtn:Disable() end
    end

    local node = selectedNode()
    inherit:SetText(Routes.InheritSummary(node))

    -- ★ WHAT IT REFUSES, and both refusals are facts about the DATA rather than
    -- rules: no selected node means there is nothing to copy from (go and run it),
    -- and no route means there is nowhere to put it. Neither is a judgement.
    local placeable = node and node.mapX ~= nil
    if placeable and (creating or route) then createBtn:Enable() else createBtn:Disable() end
    if placeable then noteBtn:Enable() else noteBtn:Disable() end

    local n = id and Routes.Count(id) or 0
    local notes = Routes.NoteCount(hereMapID())
    countText:SetText(("%d beacon%s  ·  %d personal note%s here"):format(
        n, n == 1 and "" or "s", notes, notes == 1 and "" or "s"))

    if isPromoted(rawSelected()) then
        hint:SetText("|cffff8080that is already a promoted object|r")
    elseif not node then
        hint:SetText("select a point on the map")
    elseif not placeable then
        hint:SetText("|cffff8080that point has no map position|r")
    elseif creating then
        hint:SetText("name the route, then create")
    elseif not route then
        hint:SetText("pick a route, or |cffffd100+ create new|r")
    else
        hint:SetText("|cff808080cue, note, radii and icon are edited after minting|r")
    end
end
Promoter.Refresh = refresh

-- ★ §61: `+ create new` BELONGS IN THE DROPDOWN, as an entry rather than a button
-- beside it. That makes the mode a SELECTION instead of something inferred from how
-- you typed, and it is the pattern the run selector already set: `- no route -` is a
-- real entry too, because unloading must be as reachable as loading (§36).
local function initDropdown()
    local info = UIDropDownMenu_CreateInfo()
    info.text = NEW_ROUTE
    info.notCheckable = 1
    info.func = function()
        creating = true
        Map.Load("route", nil)
        nameBox:SetText("")
        refresh()
    end
    UIDropDownMenu_AddButton(info)

    local none = UIDropDownMenu_CreateInfo()
    none.text = NO_ROUTE
    none.notCheckable = 1
    none.func = function() creating = nil; Map.Load("route", nil); refresh() end
    UIDropDownMenu_AddButton(none)

    local list = Routes.List(hereMapID())
    if #list == 0 then
        local h = UIDropDownMenu_CreateInfo()
        h.text = "no routes yet"; h.isTitle = 1; h.notCheckable = 1
        UIDropDownMenu_AddButton(h)
        return
    end

    local group
    for _, e in ipairs(list) do
        local g = e.here and "this dungeon" or "other dungeons"
        if g ~= group then
            group = g
            local h = UIDropDownMenu_CreateInfo()
            h.text = g; h.isTitle = 1; h.notCheckable = 1
            UIDropDownMenu_AddButton(h)
        end
        local b = UIDropDownMenu_CreateInfo()
        b.text = e.id
        b.notCheckable = 1
        -- ★ Selection LOADS the route's beacons onto the map (§61), which is the
        -- whole reason §62 gave the map a second slot: you author against the
        -- evidence, so both have to be on screen at once.
        b.func = function() creating = nil; Map.Load("route", e.id); refresh() end
        UIDropDownMenu_AddButton(b)
    end
end

-- Renaming follows the RUN's method, his ruling: the client's own confirm, exactly
-- as a run is renamed. Costs nothing to build and nothing to learn.
local function installPopups()
    StaticPopupDialogs["COA_DR_ROUTE_RENAME"] = {
        text = "Rename route:", button1 = ACCEPT or "Accept", button2 = CANCEL or "Cancel",
        hasEditBox = 1, maxLetters = 60,
        OnShow = function(self)
            local box = self.editBox or _G["StaticPopup1EditBox"]
            local r = Routes.Get(Map.LoadedId("route"))
            if box and r then box:SetText(r.name or "") end
        end,
        OnAccept = function(self)
            local box = self.editBox or _G["StaticPopup1EditBox"]
            local id = Map.LoadedId("route")
            if id and box then Routes.Rename(id, box:GetText()) end
            Map.Load("route", id)
            Promoter.Refresh()
        end,
        timeout = 0, whileDead = 1, hideOnEscape = 1,
    }
end

-- ★ THE MINT. One function for both objects because they differ in exactly two
-- ways - where it goes, and whether it needs a route - and writing it twice would
-- let those two drift apart.
local function mintBeacon()
    local node = selectedNode()
    if not node then return end

    local id = Map.LoadedId("route")
    if creating then
        local name = nameBox:GetText()
        if not name or name:match("^%s*$") then
            NS.Say("name the route first")
            return
        end
        id = Routes.Create(name, hereMapID())
        creating = nil
    end
    if not id then return end

    local b = Routes.AddBeacon(id, node)
    if not b then NS.Say("that point cannot be placed - no map position") return end
    -- Load rather than repaint: it is the one entry point, and it puts the route on
    -- screen in the same state the selector would have.
    Map.Load("route", id)
    NS.Say(("beacon |cffffd100%d|r on |cffffd100%s|r"):format(b.stage, id))
    refresh()
end

local function mintNote()
    local node = selectedNode()
    local mapID = hereMapID()
    if not node or not mapID then return end
    local p = Routes.AddNote(mapID, node)
    if not p then NS.Say("that point cannot be placed - no map position") return end
    -- The note plane is loaded by mapID, so minting one also brings the plane up -
    -- otherwise you would create something you cannot see.
    Map.Load("notes", mapID)
    refresh()
end

function Promoter.Init()
    Map, Store, Routes = NS.Map, NS.Store, NS.Routes

    f = CreateFrame("Frame", "COA_DungeonRunPromoter", UIParent)
    f:SetWidth(280); f:SetHeight(250)
    f:SetPoint("CENTER", UIParent, "CENTER", 560, -220)
    -- Same strata as the curation pane: both annotate the map and neither may end
    -- up buried under it.
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, _, x, y = self:GetPoint()
        Store.SetUI("promoterPos", { p = p, x = x, y = y })
    end)
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    f:Hide()

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 18, -16)
    title:SetText("Promotion")

    -- ★ ABOVE THE DIVIDER: ALWAYS AVAILABLE (§61). The route selector sits below it
    -- because the selector only gates the second button - a personal note needs no
    -- route, and putting it above says so without a word of explanation.
    noteBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    noteBtn:SetWidth(110); noteBtn:SetHeight(20)
    noteBtn:SetPoint("TOPLEFT", 16, -38)
    noteBtn:SetText("Personal note")
    noteBtn:SetScript("OnClick", mintNote)

    local rule = f:CreateTexture(nil, "ARTWORK")
    rule:SetHeight(1); rule:SetWidth(244)
    rule:SetPoint("TOPLEFT", 18, -66)
    rule:SetTexture(0.4, 0.4, 0.4, 0.6)

    dd = CreateFrame("Frame", "COA_DungeonRunRouteLoad", f, "UIDropDownMenuTemplate")
    dd:SetPoint("TOPLEFT", 2, -74)
    UIDropDownMenu_Initialize(dd, initDropdown)
    UIDropDownMenu_SetWidth(dd, 200)
    UIDropDownMenu_JustifyText(dd, "LEFT")
    UIDropDownMenu_SetText(dd, NO_ROUTE)

    nameBox = CreateFrame("EditBox", "COA_DungeonRunRouteName", f, "InputBoxTemplate")
    nameBox:SetWidth(232); nameBox:SetHeight(20)
    nameBox:SetPoint("TOPLEFT", 22, -108)
    nameBox:SetAutoFocus(false)
    nameBox:SetMaxLetters(60)
    nameBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    nameBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    nameBox:Hide()

    nameLabel = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    nameLabel:SetPoint("TOPLEFT", 22, -112)
    nameLabel:SetWidth(160); nameLabel:SetJustifyH("LEFT")

    renameBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    renameBtn:SetWidth(70); renameBtn:SetHeight(20)
    renameBtn:SetPoint("TOPLEFT", 188, -108)
    renameBtn:SetText("Rename")
    renameBtn:SetScript("OnClick", function()
        local id = Map.LoadedId("route")
        if id then StaticPopup_Show("COA_DR_ROUTE_RENAME", id) end
    end)

    -- ★ "WHAT INFORMATION WILL CARRY OVER FROM THE NODE" - doing more work than it
    -- looks. It makes the INHERITANCE VISIBLE BEFORE COMMIT, the same move as the
    -- map strip naming its tile file: a borrow shown rather than assumed. And it
    -- pre-empts the z question - you SAW z come from the node, so a beacon later
    -- dragged to the wrong height reads as the design telling you something (§25.2's
    -- teacher) rather than as a bug.
    local carries = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    carries:SetPoint("TOPLEFT", 18, -140)
    carries:SetText("carries over from the node")

    inherit = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    inherit:SetPoint("TOPLEFT", 18, -156)
    inherit:SetWidth(244); inherit:SetJustifyH("LEFT")

    createBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    createBtn:SetWidth(110); createBtn:SetHeight(20)
    createBtn:SetPoint("TOPLEFT", 16, -178)
    createBtn:SetText("Create beacon")
    createBtn:SetScript("OnClick", mintBeacon)

    countText = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    countText:SetPoint("TOPLEFT", 136, -183)
    countText:SetWidth(130); countText:SetJustifyH("LEFT")

    hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", 18, -204)
    hint:SetWidth(244); hint:SetJustifyH("LEFT")

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetWidth(60); closeBtn:SetHeight(20)
    closeBtn:SetPoint("BOTTOMRIGHT", -14, 14)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() Promoter.Toggle() end)

    installPopups()

    local ui = Store.GetUI()
    if ui.promoterPos then
        f:ClearAllPoints()
        f:SetPoint(ui.promoterPos.p, UIParent, ui.promoterPos.p, ui.promoterPos.x, ui.promoterPos.y)
    end

    refresh()
    return f
end

function Promoter.Toggle()
    if not f then return end
    if f:IsShown() then f:Hide() else f:Show(); refresh() end
end

function Promoter.IsShown() return f and f:IsShown() and true or false end
