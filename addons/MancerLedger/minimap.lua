-- MancerLedger minimap.lua - the FLIGHT RECORDER token (Battlewrath's design).
-- The button IS the ambient recording state:
--   RED    = recording off (no live profile - fights wait in the driver ring)
--   GREEN  = recording (a profile is live and folding)
--   BLUE   = blink on a fold event (~2s), then back to state color
-- Left-click: toggle the ledger window (the primary UI).
-- Right-click: the quick popout - profiles to make live + Recording Off.
-- Draggable around the minimap ring; angle persists in SV.

local ADDON, NS = ...

local RADIUS = 80
local FLASH_SECS = 2.0

local COLOR_OFF = { 0.95, 0.35, 0.35 }
local COLOR_ON = { 0.4, 0.95, 0.45 }
local COLOR_FOLD = { 0.35, 0.6, 1.0 }
local COLOR_LOCK = { 1.0, 0.72, 0.2 }  -- amber: wants to record, shape not understood

local btn = CreateFrame("Button", "MancerLedgerMinimapButton", Minimap)
btn:SetWidth(31)
btn:SetHeight(31)
btn:SetFrameStrata("MEDIUM")
btn:SetFrameLevel(8)
btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
btn:RegisterForDrag("LeftButton")
btn:SetMovable(true)

local overlay = btn:CreateTexture(nil, "OVERLAY")
overlay:SetWidth(53)
overlay:SetHeight(53)
overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
overlay:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)

local icon = btn:CreateTexture(nil, "BACKGROUND")
icon:SetWidth(20)
icon:SetHeight(20)
icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")  -- the ledger
icon:SetPoint("CENTER", btn, "CENTER", 0, 1)

local flashing = nil  -- seconds remaining

local function stateColor()
    local db = NS.GetDb()
    if NS.locked and NS.locked() then return COLOR_LOCK end  -- lock outranks all
    if flashing then return COLOR_FOLD end
    if db and db.active then return COLOR_ON end
    return COLOR_OFF
end

local function paint()
    local c = stateColor()
    icon:SetVertexColor(c[1], c[2], c[3])
end

-- fold blink: only runs its OnUpdate while a flash is live
local flasher = CreateFrame("Frame")
flasher:Hide()
flasher:SetScript("OnUpdate", function(self, dt)
    flashing = (flashing or 0) - dt
    if flashing <= 0 then
        flashing = nil
        self:Hide()
    end
    paint()
end)

NS.onFold = function()
    flashing = FLASH_SECS
    flasher:Show()
    paint()
end
NS.OnDbReady = paint
NS.onLock = paint  -- lock/unlock repaints the token immediately

-- ---------------------------------------------------------------- position
local function place()
    local db = NS.GetDb()
    local angle = math.rad((db and db.minimap and db.minimap.angle) or 210)
    btn:ClearAllPoints()
    btn:SetPoint("CENTER", Minimap, "CENTER",
        RADIUS * math.cos(angle), RADIUS * math.sin(angle))
end

local function dragTick()
    local mx, my = Minimap:GetCenter()
    local scale = Minimap:GetEffectiveScale()
    local cx, cy = GetCursorPosition()
    cx, cy = cx / scale, cy / scale
    local angle = math.deg(math.atan2(cy - my, cx - mx))
    local db = NS.GetDb()
    if db then
        db.minimap = db.minimap or {}
        db.minimap.angle = angle
    end
    place()
end

btn:SetScript("OnDragStart", function(self)
    self.dragging = true
    self:SetScript("OnUpdate", dragTick)
end)
btn:SetScript("OnDragStop", function(self)
    self.dragging = nil
    self:SetScript("OnUpdate", nil)
end)

-- ---------------------------------------------------------------- popout
-- the flight-recorder quick menu: profiles -> make live; Recording Off
local pop = CreateFrame("Frame", "MancerLedgerMinimapPopout", UIParent)
pop:SetFrameStrata("TOOLTIP")
pop:SetWidth(140)
pop:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 10,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
pop:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
pop:Hide()

local popBtns = {}
local function popEntry(i)
    local b = popBtns[i]
    if not b then
        b = CreateFrame("Button", nil, pop)
        b:SetHeight(16)
        b:SetWidth(128)
        b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        b.text:SetPoint("LEFT", b, "LEFT", 4, 0)
        b.text:SetJustifyH("LEFT")
        local hl = b:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints(b)
        hl:SetTexture(0.4, 0.4, 0.6, 0.35)
        popBtns[i] = b
    end
    b:Show()
    return b
end

local function hidePopout()
    pop:Hide()
end

local function showPopout()
    local db = NS.GetDb()
    if not db then return end
    for _, b in ipairs(popBtns) do b:Hide() end

    local names = {}
    for n in pairs(db.profiles) do names[#names + 1] = n end
    table.sort(names)

    local i, y = 0, -6
    for _, n in ipairs(names) do
        i = i + 1
        local b = popEntry(i)
        local live = (db.active == n)
        b.text:SetText((live and "|cff66ff66> |r" or "  ") .. n)
        b:SetPoint("TOPLEFT", pop, "TOPLEFT", 4, y)
        b:SetScript("OnClick", function()
            NS.profileUse(n)
            paint()
            hidePopout()
            if NS.ui then NS.ui.RefreshIfShown() end
        end)
        y = y - 16
    end

    i = i + 1
    local off = popEntry(i)
    off.text:SetText("|cffff6666Recording Off|r")
    off:SetPoint("TOPLEFT", pop, "TOPLEFT", 4, y)
    off:SetScript("OnClick", function()
        NS.profileOff()
        paint()
        hidePopout()
        if NS.ui then NS.ui.RefreshIfShown() end
    end)
    y = y - 16

    if #names == 0 then
        i = i + 1
        local none = popEntry(i)
        none.text:SetText("|cff888888(no profiles - open the ledger)|r")
        none:SetPoint("TOPLEFT", pop, "TOPLEFT", 4, y)
        none:SetScript("OnClick", function()
            hidePopout()
            if NS.ui then NS.ui.Show() end
        end)
        y = y - 16
    end

    pop:SetHeight(-y + 8)
    pop:ClearAllPoints()
    pop:SetPoint("TOPRIGHT", btn, "BOTTOMLEFT", 0, 0)
    pop:Show()
end

-- popout auto-hides shortly after the mouse leaves it
local popHide = CreateFrame("Frame")
popHide:Hide()
local popIdle = 0
popHide:SetScript("OnUpdate", function(self, dt)
    if MouseIsOver and (MouseIsOver(pop) or MouseIsOver(btn)) then
        popIdle = 0
        return
    end
    popIdle = popIdle + dt
    if popIdle > 0.8 then
        hidePopout()
        popIdle = 0
        self:Hide()
    end
end)

btn:SetScript("OnClick", function(_, mouseButton)
    if mouseButton == "RightButton" then
        if pop:IsShown() then
            hidePopout()
        else
            showPopout()
            popIdle = 0
            popHide:Show()
        end
    else
        hidePopout()
        if NS.ui then NS.ui.Toggle() end
    end
end)

btn:SetScript("OnEnter", function(self)
    local db = NS.GetDb()
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("Mancer Ledger")
    local lock = NS.locked and NS.locked()
    if lock then
        GameTooltip:AddLine("|cffffb833FOLDS LOCKED|r - driver shape not understood", 1, 1, 1)
        GameTooltip:AddLine(tostring(lock.reason), 0.8, 0.8, 0.8)
    end
    if db and db.active then
        local p = db.profiles[db.active]
        GameTooltip:AddLine("|cff66ff66Recording|r -> " .. db.active
            .. " (" .. (p and p.folds or 0) .. " fights)", 1, 1, 1)
    else
        GameTooltip:AddLine("|cffff6666Not recording|r - right-click to pick a profile", 1, 1, 1)
    end
    GameTooltip:AddLine("Left-click: ledger window", 0.7, 0.7, 0.7)
    GameTooltip:AddLine("Right-click: quick profile select", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)
btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

place()
paint()
NS.minimapPaint = paint  -- window ops repaint the token after Use/Off/New
