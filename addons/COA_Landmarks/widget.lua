-- COA_Landmarks widget.lua - the stateful widget (AC-10 .. AC-16).
--
--   Landmark name                     <- click to rename (AC-4b). The ALIAS only;
--   Zone                 [Map]           the id never changes (AC-47).
--   [repin] [clear]
--   [make marker]
--
-- Name and zone only. NO coordinates and NO distance readout (L16, L18) - the
-- beacon renders its own inside its range, and beyond that the map is the
-- instrument.

local ADDON, NS = ...
local Store = NS.Store

local Widget = {}
NS.Widget = Widget

local heldId          -- AC-11/AC-15: SESSION state. Never persisted (AC-52).
local f

-- ---------------------------------------------------------------------

local function btn(parent, text, w, onClick)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetWidth(w); b:SetHeight(20)
    b:SetText(text)
    b:SetScript("OnClick", onClick)
    return b
end

function Widget:Init()
    if f then return end

    f = CreateFrame("Frame", "COA_LandmarksWidget", UIParent)
    f:SetWidth(200); f:SetHeight(104)
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 },
    })

    -- AC-16: movable, and the position persists per character.
    f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, _, x, y = self:GetPoint()
        Store.SetUI("point", p); Store.SetUI("x", x); Store.SetUI("y", y)
    end)

    local ui = Store.GetUI()
    f:SetPoint(ui.point or "CENTER", UIParent, ui.point or "CENTER", ui.x or 0, ui.y or 0)

    -- line 1: the alias. Click to rename (AC-4b).
    f.name = CreateFrame("Button", nil, f)
    f.name:SetPoint("TOPLEFT", 12, -12); f.name:SetWidth(176); f.name:SetHeight(16)
    f.name.text = f.name:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.name.text:SetPoint("LEFT"); f.name.text:SetJustifyH("LEFT")
    f.name:SetScript("OnClick", function() Widget:BeginRename() end)
    f.name:SetScript("OnEnter", function(self)
        if not heldId then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Click to rename", 1, 1, 1)
        GameTooltip:Show()
    end)
    f.name:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- the rename box. NOT shown at capture (AC-4a) - only when explicitly asked,
    -- where taking keyboard focus is what the user just requested.
    -- NAMED: InputBoxTemplate's middle texture anchors to $parentLeft/$parentRight
    -- by name, so a nameless box loses it (see editor.lua).
    f.rename = CreateFrame("EditBox", "COA_LandmarksWidgetRename", f, "InputBoxTemplate")
    f.rename:SetPoint("TOPLEFT", 16, -10); f.rename:SetWidth(170); f.rename:SetHeight(18)
    f.rename:SetAutoFocus(false)
    f.rename:Hide()
    f.rename:SetScript("OnEscapePressed", function(self) self:Hide(); self:ClearFocus(); Widget:Refresh() end)
    f.rename:SetScript("OnEnterPressed", function(self)
        local v = self:GetText()
        if heldId and v and v ~= "" then Store.Set(heldId, "alias", v) end
        self:Hide(); self:ClearFocus()
        Widget:Refresh()
        if NS.Pins then NS.Pins:Refresh() end
    end)

    -- line 2: the zone, at whatever resolution is still useful (AC-41).
    f.zone = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.zone:SetPoint("TOPLEFT", 12, -32); f.zone:SetJustifyH("LEFT")

    -- AC-14: shown ONLY when the beacon cannot guide. Behavioural, not
    -- instructional (L18) - it opens the map rather than telling you to.
    f.map = btn(f, "Map", 40, function()
        if not heldId then return end
        local lm = Store.Get(heldId)
        if not lm then return end
        ShowUIPanel(WorldMapFrame)
        -- Best effort: this client's map-by-id surface is not guaranteed. If it
        -- is not there, the map still opens - which is the handoff (L16).
        -- ★ FACT: SetMapByID is NOT guaranteed present on this client - pcall it and let the
        --   map simply open (L16's handoff) rather than assuming the by-id surface exists.
        pcall(function() SetMapByID(lm.mapID) end)
    end)
    f.map:SetPoint("TOPRIGHT", -12, -28)
    f.map:SetHeight(16)
    f.map:GetFontString():SetTextColor(1, 0.3, 0.3)   -- red: the beacon is unavailable
    f.map:Hide()

    -- AC-12: repin is ALWAYS a user act. Nothing re-pins automatically (L13).
    f.repin = btn(f, "repin", 84, function()
        if not heldId then return end
        local ok, err = NS.Beacon.Pin(heldId)
        if not ok then NS.Print("could not pin - " .. tostring(err)) end
        Widget:Refresh()
    end)
    f.repin:SetPoint("TOPLEFT", 12, -52)

    -- AC-13: the same release arrival performs.
    f.clear = btn(f, "clear", 84, function()
        NS.Beacon.Clear(); Widget:Refresh()
    end)
    f.clear:SetPoint("TOPLEFT", 102, -52)

    -- AC-8: one of the three capture affordances.
    f.make = btn(f, "make marker", 174, function() NS.CaptureHere() end)
    f.make:SetPoint("TOPLEFT", 12, -76)

    if Store.GetUI().shown then f:Show() else f:Hide() end
    self:Refresh()
end

-- ---------------------------------------------------------------------

function Widget:BeginRename()
    if not heldId then return end
    local lm = Store.Get(heldId); if not lm then return end
    f.rename:SetText(lm.alias or "")
    f.rename:Show(); f.rename:SetFocus(); f.rename:HighlightText()
end

-- AC-9a / AC-11: what you hold. Survives the beacon being lost, which is what
-- makes one-click repin the answer to contention rather than priority-fighting.
function Widget:Hold(id)
    heldId = id
    self:Refresh()
end

function Widget:Held() return heldId end

-- AC-41: show the resolution that is STILL USEFUL. "Winterspring" is useless
-- once you are standing in Winterspring; "Everlook" is what you then need.
local function zoneLine(lm)
    local zone, sub = GetRealZoneText(), GetSubZoneText()
    if lm.zone ~= zone then return lm.zone end
    if lm.subZone and lm.subZone ~= "" then return lm.subZone end
    return lm.zone
end

function Widget:Refresh()
    if not f then return end
    local lm = heldId and Store.Get(heldId) or nil

    if not lm then
        f.name.text:SetText("|cff888888no landmark held|r")
        f.zone:SetText("")
        f.map:Hide()
        f.repin:Disable(); f.clear:Disable()
        return
    end

    f.name.text:SetText(lm.alias or "?")
    f.zone:SetText(zoneLine(lm))
    f.repin:Enable(); f.clear:Enable()

    if NS.Beacon.CannotGuide(heldId) then f.map:Show() else f.map:Hide() end
end

function Widget:Show()
    if not f then return end
    f:Show(); Store.SetUI("shown", true); self:Refresh()
end

function Widget:Hide()
    if not f then return end
    f:Hide(); Store.SetUI("shown", false)
end

-- AC-16: minimap left-click spawns it in its LAST KNOWN STATE - position, and
-- the landmark it was holding.
function Widget:Toggle()
    if not f then return end
    if f:IsShown() then self:Hide() else self:Show() end
end

return Widget
