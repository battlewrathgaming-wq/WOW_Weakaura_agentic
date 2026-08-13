-- COA_DungeonRun widget.lua - the capture widget. Deliberately small.
--
-- Battlewrath: "we need a widget that is all about capture." Three things and
-- nothing else: name the run, arm it, watch the count move so you can see it is
-- working. Everything about READING a run happens offline, against the records.
--
-- ---------------------------------------------------------------------------
-- CARRIED LESSON (COA_Landmarks, cost a live bug to find):
-- InputBoxTemplate's $parentMiddle texture anchors relativeTo="$parentLeft" and
-- "$parentRight" BY NAME. A nameless EditBox therefore loses its middle section
-- and renders as two floating end-caps. THE EDIT BOX MUST BE NAMED.
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local Widget = {}
NS.Widget = Widget

local Store, Capture
local f, nameBox, armBtn, countText

local function refresh()
    if not f then return end
    local id = Capture.RunId()
    if id then
        local pulls, legs = Store.Counts(id)
        countText:SetText(("recording  |  %d pull%s  |  %d leg%s")
            :format(pulls, pulls == 1 and "" or "s", legs, legs == 1 and "" or "s"))
        armBtn:SetText("Stop")
        nameBox:EnableMouse(false)
        nameBox:ClearFocus()
    else
        countText:SetText("not recording")
        armBtn:SetText("Arm")
        nameBox:EnableMouse(true)
    end
end
Widget.Refresh = refresh

local function toggleArm()
    if Capture.RunId() then
        local id = Capture.Stop()
        NS.Say(("stopped |cffffd100%s|r"):format(tostring(id)))
    else
        local id, err = Capture.Arm(nameBox:GetText())
        if id then
            NS.Say(("recording |cffffd100%s|r"):format(id))
        else
            NS.Say("could not start: " .. tostring(err))
        end
    end
    refresh()
end

function Widget.Init()
    Store, Capture = NS.Store, NS.Capture

    f = CreateFrame("Frame", "COA_DungeonRunFrame", UIParent)
    f:SetWidth(240); f:SetHeight(96)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
    f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })

    -- The drag pair is balanced: OnDragStart installs nothing persistent, and
    -- StopMovingOrSizing ends it. An unthrottled drag handler is CORRECT - a
    -- throttled one stutters (the addon census flags it; the README calibrates
    -- why that flag is fine).
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, _, x, y = self:GetPoint()
        Store.SetUI("pos", { p = p, x = x, y = y })
    end)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 16, -14)
    title:SetText("Dungeon run")

    -- NAMED - see the carried lesson at the top of this file.
    nameBox = CreateFrame("EditBox", "COA_DungeonRunNameBox", f, "InputBoxTemplate")
    nameBox:SetWidth(190); nameBox:SetHeight(20)
    nameBox:SetPoint("TOPLEFT", 22, -34)
    nameBox:SetAutoFocus(false)
    nameBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    nameBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

    countText = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    countText:SetPoint("BOTTOMLEFT", 18, 18)

    armBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    armBtn:SetWidth(64); armBtn:SetHeight(22)
    armBtn:SetPoint("BOTTOMRIGHT", -14, 14)
    armBtn:SetScript("OnClick", toggleArm)

    -- §20.1: the widget is the ANCHOR for the display, not a second surface.
    local mapBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    mapBtn:SetWidth(52); mapBtn:SetHeight(22)
    mapBtn:SetPoint("BOTTOMRIGHT", -72, 14)
    mapBtn:SetText("Map")
    mapBtn:SetScript("OnClick", function() NS.Map.Toggle() end)

    local ui = Store.GetUI()
    if ui.pos then
        f:ClearAllPoints()
        f:SetPoint(ui.pos.p, UIParent, ui.pos.p, ui.pos.x, ui.pos.y)
    end
    if ui.shown == false then f:Hide() end

    refresh()
    return f
end

function Widget.Toggle()
    if not f then return end
    if f:IsShown() then f:Hide() else f:Show(); refresh() end
    Store.SetUI("shown", f:IsShown() and true or false)
end
