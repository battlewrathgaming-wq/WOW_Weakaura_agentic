-- COA_DungeonRun object.lua - THE OBJECT'S OWN EDIT PANE.
--
-- Spec: addons/planning/dungeonrun_poc.md §69, §71.
--
-- ---------------------------------------------------------------------------
-- ★★ ALL EDIT OPTIONS OF AN OBJECT LIVE HERE (Battlewrath, 2026-08-14):
--
--   *"All edit options of an object live within its edit mode interface. So where
--   its values and information is defined, self contained. Instead of promotion
--   being both a spawning and editing tool. It sets the route, lets you spawn
--   within it (or personal notes out of the route capture). And then a beacon has
--   its own break down of behaviour."*
--
-- §69 got this wrong: right-click opened the PROMOTER and the in-field editors were
-- to "land in that space". That made the creation pane double as an editor, which
-- he saw before he named it - *"the note is treating the promote window like it's
-- information"*. It was, because it had been made to.
--
--     promoter        sets the route · spawns beacons into it · spawns notes
--     this pane       everything ABOUT one object, self-contained
--
-- ★ SO THE PROMOTER MINTS AND HANDS OFF. It keeps no edit controls, and the move
-- chip lives here, with the object it arms.
--
-- ---------------------------------------------------------------------------
-- ★ THE DATA OBJECT MOSTLY EXISTS ALREADY - his own note, and it is right. A
-- beacon carries the inherited place (x,y,z · mapX,mapY · floor · mapID), `kind`,
-- `stage`, `name`, and §68's placement pair. Nothing new is needed for identity.
--
-- ⚠ WHAT DOES NOT EXIST IS BEHAVIOUR, and it is deliberately not invented here.
-- *"Behaviour to be defined. Things like how the marker behaves. (Listen range for
-- notes, vs listen range to display super tracker.) Z height match requirement...
-- And so on. All to be defined."* So the pane SAYS the space is empty rather than
-- filling it with a guess - the same choice the map makes when it has no art.
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local Object = {}
NS.Object = Object

local Map, Store, Routes
local f, title, nameBox, factLine, moveChip, delBtn, hint

-- Only ever the map's selection. This pane holds no object of its own, so it can
-- never describe something the map is not showing - the fault §63 shipped when two
-- surfaces each remembered what they were looking at.
local function subject()
    local p = Map.Selected and Map.Selected() or nil
    if p and (p.kind == "beacon" or p.kind == "note") then return p end
    return nil
end

local function refresh()
    if not f then return end
    local p = subject()
    if not p then
        title:SetText("nothing to edit")
        nameBox:Hide(); factLine:SetText(""); moveChip:Hide(); delBtn:Disable()
        hint:SetText("right-click a beacon or a note on the map")
        return
    end

    local label = Map.Describe(p)
    title:SetText(label)
    nameBox:Show()
    nameBox:SetText(p.name or p.text or "")
    delBtn:Enable()

    -- The facts it cannot edit, so the pane says what this object IS without
    -- duplicating the map's readout - stage and height are the two a route author
    -- acts on, and z is the one §67.1 makes load-bearing.
    local _, _, placed = Routes.PositionOf(p)
    factLine:SetText(("%s%s  ·  z %s%s"):format(
        p.stage and ("stage " .. p.stage) or "personal note",
        placed and "  ·  |cffffd100moved|r" or "",
        p.z and ("%.1f"):format(p.z) or "-",
        p.atWorldX and "" or (placed and "  ·  |cffff8080no world position|r" or "")))

    -- ★ CHECKED means ARMED, and it reads from the MAP so an arm cleared by
    -- unloading shows here rather than leaving a chip depressed over an object that
    -- can no longer be grabbed.
    moveChip:Show()
    moveChip:SetChecked(Map.MoveArmed() == p)

    hint:SetText(moveChip:GetChecked()
        and "drag it on the map - click to drop"
        or "|cff808080behaviour fields are not defined yet (§71)|r")
end
Object.Refresh = refresh

-- ★ Renaming is IN-FIELD, not a popup. §61's create-then-edit: the object already
-- exists, so this is editing a value rather than confirming an act - and the run
-- and route renames use a popup precisely because those are acts on a whole record.
local function commitName()
    local p = subject()
    if not p then return end
    Routes.SetName(p, nameBox:GetText())
    refresh()
end

local function installPopups()
    StaticPopupDialogs["COA_DR_OBJECT_DELETE"] = {
        text = "Delete this %s?\n\nThe run it came from is untouched.",
        button1 = DELETE or "Delete", button2 = CANCEL or "Cancel",
        OnAccept = function()
            local p = subject()
            if not p then return end
            -- ★ The origin is a VALUE on the object (§68), so deleting a promoted
            -- thing cannot reach back into the capture. Worth saying in the dialog:
            -- the one fear a delete button earns is that it takes the evidence too.
            if p.kind == "note" then
                Routes.DeleteNote(Map.AuthoringMapID(), p)
            else
                Routes.DeleteBeacon(Map.LoadedId("route"), p.stage)
            end
            Map.Select(nil)
            Map.SetMoveArmed(nil)
            Map.Repaint()
            refresh()
        end,
        timeout = 0, whileDead = 1, hideOnEscape = 1, showAlert = 1,
    }
end

function Object.Init()
    Map, Store, Routes = NS.Map, NS.Store, NS.Routes

    f = CreateFrame("Frame", "COA_DungeonRunObject", UIParent)
    f:SetWidth(240); f:SetHeight(190)
    f:SetPoint("CENTER", UIParent, "CENTER", 560, 220)
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local pt, _, _, x, y = self:GetPoint()
        Store.SetUI("objectPos", { p = pt, x = x, y = y })
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

    nameBox = CreateFrame("EditBox", "COA_DungeonRunObjectName", f, "InputBoxTemplate")
    nameBox:SetWidth(192); nameBox:SetHeight(20)
    nameBox:SetPoint("TOPLEFT", 22, -38)
    nameBox:SetAutoFocus(false)
    nameBox:SetMaxLetters(40)
    nameBox:SetScript("OnEnterPressed", function(self) commitName(); self:ClearFocus() end)
    nameBox:SetScript("OnEscapePressed", function(self) self:ClearFocus(); refresh() end)

    factLine = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    factLine:SetPoint("TOPLEFT", 18, -66)
    factLine:SetWidth(204); factLine:SetJustifyH("LEFT")

    -- The chip, moved here from the promoter where §69 put it. One control, two
    -- states: pressed arms this object for dragging, pressed again locks it.
    moveChip = CreateFrame("CheckButton", "COA_DungeonRunObjectMove", f, "UICheckButtonTemplate")
    moveChip:SetWidth(20); moveChip:SetHeight(20)
    moveChip:SetPoint("TOPLEFT", 16, -84)
    local chipTxt = _G and _G["COA_DungeonRunObjectMoveText"]
    if chipTxt then chipTxt:SetText("move") end
    moveChip:SetScript("OnClick", function(self)
        Map.SetMoveArmed(self:GetChecked() and subject() or nil)
        refresh()
    end)

    delBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    delBtn:SetWidth(70); delBtn:SetHeight(20)
    delBtn:SetPoint("TOPLEFT", 150, -84)
    delBtn:SetText("Delete")
    delBtn:SetScript("OnClick", function()
        local p = subject()
        if p then StaticPopup_Show("COA_DR_OBJECT_DELETE", p.kind == "note" and "note" or "beacon") end
    end)

    local behaviour = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    behaviour:SetPoint("TOPLEFT", 18, -114)
    behaviour:SetText("behaviour")

    hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", 18, -130)
    hint:SetWidth(204); hint:SetJustifyH("LEFT")

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetWidth(60); closeBtn:SetHeight(20)
    closeBtn:SetPoint("BOTTOMRIGHT", -14, 14)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    installPopups()

    -- One-way, as ever: the map fires and knows nothing about who listens.
    Map.AddOnSelect(refresh)
    Map.AddOnEdit(function()
        if not f:IsShown() then f:Show() end
        refresh()
    end)

    local ui = Store.GetUI()
    if ui.objectPos then
        f:ClearAllPoints()
        f:SetPoint(ui.objectPos.p, UIParent, ui.objectPos.p, ui.objectPos.x, ui.objectPos.y)
    end

    refresh()
    return f
end

function Object.Toggle()
    if not f then return end
    if f:IsShown() then f:Hide() else f:Show(); refresh() end
end

function Object.IsShown() return f and f:IsShown() and true or false end
