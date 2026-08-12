-- COA_Landmarks minimap.lua - the minimap BUTTON (AC-8, AC-16).
--
--   left-click   spawn the widget in its LAST KNOWN STATE
--   right-click  capture here - a zone-subzone-unique-int grab (AC-4)
--
-- This is a minimap BUTTON, not a minimap PIN. Law 15 puts the minimap out of
-- scope as a display surface: no pins, no blips, no rotation handling. A button
-- riding the edge is a control, not a readout, and adds nothing to the noise
-- the law was written about.

local ADDON, NS = ...
local Store = NS.Store

local Minimap_ = {}
NS.Minimap = Minimap_

local b

local function place(angle)
    local r = 80
    b:SetPoint("CENTER", Minimap, "CENTER",
        r * cos(angle), r * sin(angle))
end

function Minimap_:Init()
    if b then return end

    b = CreateFrame("Button", "COA_LandmarksMinimapButton", Minimap)
    b:SetWidth(31); b:SetHeight(31)
    b:SetFrameStrata("MEDIUM")
    b:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:RegisterForDrag("LeftButton")
    b:SetMovable(true)

    local icon = b:CreateTexture(nil, "BACKGROUND")
    icon:SetWidth(20); icon:SetHeight(20)
    icon:SetPoint("CENTER", 0, 1)
    -- The same symbol the map pins use, so the button and the pins speak with
    -- one voice (L10: context sets the default).
    -- Same explicit path as the pins (see pins.lua setIcon) - texture plus
    -- tex-coords, no dependency on SetAtlas or a constant we cannot verify.
    local info = _G.AtlasInfo and AtlasInfo[Store.DEFAULT_ICON]
    if info then
        icon:SetTexture(info[1])
        icon:SetTexCoord(info[4], info[5], info[6], info[7])
    end

    local border = b:CreateTexture(nil, "OVERLAY")
    border:SetWidth(53); border:SetHeight(53)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetPoint("TOPLEFT")

    place(Store.GetUI().mmAngle or 200)

    b:SetScript("OnDragStart", function(self) self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local s = UIParent:GetEffectiveScale()
        local angle = math.deg(math.atan2(cy / s - my, cx / s - mx))
        Store.SetUI("mmAngle", angle)
        place(angle)
    end) end)
    b:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)

    b:SetScript("OnClick", function(_, button)
        if button == "RightButton" then
            NS.CaptureHere()                 -- AC-8
        else
            NS.Widget:Toggle()               -- AC-16
        end
    end)

    b:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Landmarks", 1, 0.82, 0)
        GameTooltip:AddLine("Left-click: show or hide the widget", 1, 1, 1)
        GameTooltip:AddLine("Right-click: mark where you are standing", 1, 1, 1)
        local n = #Store.Visible()
        GameTooltip:AddLine(("%d landmark(s) on this character"):format(n), 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

return Minimap_
