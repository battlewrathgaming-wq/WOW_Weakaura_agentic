-- COA_PetGrid core.lua - v0.2.0 the CHASSIS + feed manager.
--
-- Pass 2 proved this chassis live (pooling/no-flicker, drag+lock+scale SV,
-- top-left grow-down pin, the 3-state HP cycle). Pass 3 splits data from
-- display: core owns the frames and the writer tick; a FEED owns the data.
-- Feeds register in NS.feeds and implement { start(), stop(), update(dt),
-- slash(cmd, arg) -> handled }. db.mode picks the feed ("live" | "demo").
--
--   /petgrid            controls list
--   /petgrid lock|unlock  drag handle off/on (locked = click-through)
--   /petgrid scale <x>  0.5 - 2.0
--   /petgrid reset      re-center + defaults
--   /petgrid demo       toggle demo feed <-> live feed
--   (feed commands: /petgrid stats | resetstats - handled by the live feed)

local ADDON, NS = ...

-- layout constants (rebalanced after the live clipping report - the right
-- stat block starts at WIDTH-8-3*STAT_SP; name+bar must end short of it)
local ROW_H, WIDTH = 14, 240
local NAME_W, BAR_W, STAT_W, STAT_SP = 70, 50, 32, 34

-- topX/topY = the TOP-LEFT corner in UIParent space (scale-corrected). The
-- container is pinned by its top edge so row growth only ever extends DOWN
-- (Battlewrath: growing up feels chaotic / not anchored). nil = first run,
-- centered once then converted.
local defaults = { topX = nil, topY = nil, scale = 1.0, locked = false, mode = "live" }

local db  -- COA_PetGridDB after ADDON_LOADED

-- ---------------------------------------------------------------- container
local root = CreateFrame("Frame", "COA_PetGridFrame", UIParent)
root:SetWidth(WIDTH)
root:SetHeight(40)
root:SetFrameStrata("LOW")
root:SetClampedToScreen(true)
root:SetMovable(true)
root:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
root:SetBackdropColor(0, 0, 0, 0.55)
root:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.9)
root:Hide()
NS.root = root

local grip = CreateFrame("Frame", nil, root)  -- drag handle, visible when unlocked
grip:SetPoint("TOPLEFT", root, "TOPLEFT", 0, 0)
grip:SetPoint("TOPRIGHT", root, "TOPRIGHT", 0, 0)
grip:SetHeight(12)
grip:EnableMouse(true)
grip:RegisterForDrag("LeftButton")
local gripTex = grip:CreateTexture(nil, "BACKGROUND")
gripTex:SetAllPoints(grip)
gripTex:SetTexture(0.3, 0.5, 0.3, 0.5)
local title = grip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
title:SetPoint("CENTER", grip, "CENTER", 0, 0)
title:SetText("PetGrid (drag - /petgrid lock)")

local function saveTopAnchor()
    -- ★★ FACT: [SILENT] GetLeft/GetTop return values in the FRAME's scale space, not UIParent's
    --   ⚠ Otherwise a saved position drifts every time the user rescales. Same family
    --   as the GetCursorPosition scale rule.
    -- GetLeft/GetTop are in the frame's scale space; multiply out to UIParent
    -- space so the stored corner survives scale changes
    db.topX = root:GetLeft() * db.scale
    db.topY = root:GetTop() * db.scale
end

local function pinTopLeft()
    root:ClearAllPoints()
    root:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", db.topX / db.scale, db.topY / db.scale)
end

grip:SetScript("OnDragStart", function() root:StartMoving() end)
grip:SetScript("OnDragStop", function()
    root:StopMovingOrSizing()
    saveTopAnchor()
    pinTopLeft()  -- re-pin immediately by the top-left so growth stays downward
end)

-- ★★ FACT: at ADDON_LOADED a frame has NO rect yet - GetLeft() returns nil
--   ⚠ Any anchor migration must defer to the first laid-out frame.
-- One-shot converter: at ADDON_LOADED the frame has NO rect yet (GetLeft()
-- = nil), so a legacy/center anchor can't be converted there - it must wait
-- for the first laid-out frame. Un-hooks itself the moment it succeeds.
local pinner = CreateFrame("Frame")
pinner:Hide()
pinner:SetScript("OnUpdate", function(self)
    if not root:GetLeft() then return end
    saveTopAnchor()
    db.point, db.x, db.y = nil, nil, nil
    pinTopLeft()
    self:Hide()
end)

local function applyChrome()
    root:SetScale(db.scale)
    if db.topX then
        pinTopLeft()
    else
        -- first run (or legacy SV): place once wherever it was, then let the
        -- pinner convert to the top-left pin on the first real layout pass
        root:ClearAllPoints()
        root:SetPoint(db.point or "CENTER", UIParent, db.point or "CENTER", db.x or 0, db.y or 0)
        pinner:Show()
    end
    if db.locked then grip:Hide() else grip:Show() end
end

-- ---------------------------------------------------------------- row pool
-- One row frame kind; sections compose it (Raise: the bar is HP; Animate:
-- the same bar is the TTL window). Created once, acquired/released forever.
local pool, live = {}, {}

local function newRow()
    local r = CreateFrame("Frame", nil, root)
    r:SetWidth(WIDTH - 8)
    r:SetHeight(ROW_H)

    r.name = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    r.name:SetPoint("LEFT", r, "LEFT", 2, 0)
    r.name:SetJustifyH("LEFT")
    r.name:SetWidth(NAME_W)

    r.hp = CreateFrame("StatusBar", nil, r)
    r.hp:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    r.hp:SetPoint("LEFT", r.name, "RIGHT", 2, 0)
    r.hp:SetWidth(BAR_W)
    r.hp:SetHeight(ROW_H - 5)
    r.hp:SetMinMaxValues(0, 1)
    r.hpBg = r.hp:CreateTexture(nil, "BACKGROUND")
    r.hpBg:SetAllPoints(r.hp)
    r.hpBg:SetTexture(0.15, 0.15, 0.15, 0.8)
    -- absolute state rides ON the bar (fraction = fill, % or seconds = text;
    -- both grey together on stale)
    r.hpText = r.hp:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    r.hpText:SetPoint("CENTER", r.hp, "CENTER", 0, 0)

    r.stats = {}
    for i = 1, 3 do
        local fs = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fs:SetPoint("RIGHT", r, "RIGHT", -2 - (3 - i) * STAT_SP, 0)
        fs:SetJustifyH("RIGHT")
        fs:SetWidth(STAT_W)
        r.stats[i] = fs
    end
    return r
end

local function acquireRow()
    local r = table.remove(pool) or newRow()
    r:Show()
    live[#live + 1] = r
    return r
end

local function releaseRows()
    for i = #live, 1, -1 do
        local r = live[i]
        r:Hide()
        r:ClearAllPoints()
        pool[#pool + 1] = r
        live[i] = nil
    end
end

-- section header pool (same discipline): a header ROW - section title at the
-- name column, a label over the bar slot, column labels over the stat slots
local hpool, hlive = {}, {}
local function newHeader()
    local h = CreateFrame("Frame", nil, root)
    h:SetWidth(WIDTH - 8)
    h:SetHeight(12)
    h.title = h:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    h.title:SetPoint("LEFT", h, "LEFT", 2, 0)
    h.title:SetJustifyH("LEFT")
    h.title:SetWidth(NAME_W)
    h.hpLbl = h:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    h.hpLbl:SetPoint("LEFT", h, "LEFT", 2 + NAME_W + 2, 0)
    h.hpLbl:SetJustifyH("CENTER")
    h.hpLbl:SetWidth(BAR_W)
    h.cols = {}
    for i = 1, 3 do
        local fs = h:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("RIGHT", h, "RIGHT", -2 - (3 - i) * STAT_SP, 0)
        fs:SetJustifyH("RIGHT")
        fs:SetWidth(STAT_W)
        h.cols[i] = fs
    end
    return h
end
local function acquireHeader(text, hpLbl, c1, c2, c3)
    local h = table.remove(hpool) or newHeader()
    h.title:SetText(text)
    h.hpLbl:SetText(hpLbl or "")
    h.cols[1]:SetText(c1 or "")
    h.cols[2]:SetText(c2 or "")
    h.cols[3]:SetText(c3 or "")
    h:Show()
    hlive[#hlive + 1] = h
    return h
end
local function releaseHeaders()
    for i = #hlive, 1, -1 do
        local h = hlive[i]
        h:Hide()
        h:ClearAllPoints()
        hpool[#hpool + 1] = h
        hlive[i] = nil
    end
end

-- ---------------------------------------------------------------- layout
-- Called only when the ROW SET changes (add/remove/reorder), never per tick.
-- Ticker writes touch region contents only.
function NS.layout(raiseRows, familyRows)
    releaseRows()
    releaseHeaders()
    local y = -14  -- below the grip line

    local function place(el)
        el:ClearAllPoints()
        el:SetPoint("TOPLEFT", root, "TOPLEFT", 4, y)
    end

    if #raiseRows > 0 then
        local h = acquireHeader("Raise", "HP", "Dmg", "Crit", "Miss")
        place(h); y = y - 13
        for _, data in ipairs(raiseRows) do
            local r = acquireRow()
            r.hp:Show()
            place(r); y = y - ROW_H
            r.data = data
        end
    end
    if #familyRows > 0 then
        local h = acquireHeader("Animate", "TTL", "#", "Crit", "Miss")
        place(h); y = y - 13
        for _, data in ipairs(familyRows) do
            local r = acquireRow()
            r.hp:Show()  -- same element, family semantics: the TTL window
            place(r); y = y - ROW_H
            r.data = data
        end
    end
    root:SetHeight(-y + 6)
end

-- write pass: contents only, no anchors touched
function NS.writeRows()
    for _, r in ipairs(live) do
        local d = r.data
        if d.kind == "raise" then
            r.name:SetText(d.name)
            if d.state == "stale" then
                r.name:SetTextColor(0.6, 0.6, 0.6)
                r.hp:SetStatusBarColor(0.45, 0.45, 0.45)
                r.hpText:SetTextColor(0.6, 0.6, 0.6)
            else
                r.name:SetTextColor(1, 1, 1)
                r.hp:SetStatusBarColor(0.1, 0.75, 0.2)
                r.hpText:SetTextColor(1, 1, 1)
            end
            r.hp:SetValue(d.hpFrac or 0)
            -- % on the read: the information is "healthy or not", not a value
            r.hpText:SetText(d.hpFrac and (math.floor(d.hpFrac * 100 + 0.5) .. "%") or "")
            r.stats[1]:SetText(d.dmg)
            r.stats[2]:SetText(d.crit)
            r.stats[3]:SetText(d.miss)
        else -- family: the bar slot is the TTL window - time until the count
             -- next drops (oldest living member's remaining TTL)
            r.name:SetText(d.name)
            r.name:SetTextColor(0.85, 0.75, 1)
            r.hp:SetStatusBarColor(0.75, 0.55, 0.15)
            r.hp:SetValue((d.ttl or 0) / (d.ttlMax or 1))
            r.hpText:SetTextColor(1, 1, 1)
            r.hpText:SetText(d.ttl and (math.ceil(d.ttl) .. "s") or "")
            r.stats[1]:SetText("x" .. d.count)
            r.stats[2]:SetText(d.crit)
            r.stats[3]:SetText(d.miss)
        end
    end
end

-- ---------------------------------------------------------------- feed slot
NS.feeds = {}
NS.active = nil

function NS.SetMode(mode)
    if not NS.feeds[mode] then mode = "live" end
    if NS.active and NS.active.stop then NS.active.stop() end
    db.mode = mode
    NS.active = NS.feeds[mode]
    if NS.active.start then NS.active.start() end
end

-- the writer tick: relaxed cadence by design - the value is in where the
-- averages settle over time, not per-frame fidelity (Battlewrath)
local ticker = CreateFrame("Frame")
local acc = 0
ticker:SetScript("OnUpdate", function(_, dt)
    acc = acc + dt
    if acc < 0.5 then return end
    local step = acc
    acc = 0
    if NS.active and NS.active.update then
        local ok = pcall(NS.active.update, step)
        if not ok then NS.tickErrors = (NS.tickErrors or 0) + 1 end
    end
end)

-- ---------------------------------------------------------------- boot + slash
local boot = CreateFrame("Frame")
boot:RegisterEvent("ADDON_LOADED")
boot:SetScript("OnEvent", function(_, _, name)
    if name ~= ADDON then return end
    boot:UnregisterAllEvents()
    COA_PetGridDB = COA_PetGridDB or {}
    db = COA_PetGridDB
    NS.db = db
    for k, v in pairs(defaults) do
        if db[k] == nil then db[k] = v end
    end
    db.normals = db.normals or {}
    if db.demo ~= nil then db.demo = nil end  -- legacy boolean, replaced by mode
    applyChrome()
    NS.SetMode(db.mode)
end)

SLASH_COAPETGRID1 = "/petgrid"
SlashCmdList["COAPETGRID"] = function(msg)
    local cmd, arg = msg:match("^(%S*)%s*(.*)$")
    cmd = cmd:lower()
    if cmd == "lock" then
        db.locked = true; applyChrome()
    elseif cmd == "unlock" then
        db.locked = false; applyChrome()
    elseif cmd == "scale" then
        local s = tonumber(arg)
        if s and s >= 0.5 and s <= 2.0 then db.scale = s; applyChrome() end
    elseif cmd == "reset" then
        for k, v in pairs(defaults) do db[k] = v end
        -- ★★ FACT: [SILENT] nil-valued defaults are INVISIBLE to `pairs()`
        --   ⚠ A "copy the defaults back" loop skips them entirely, so a reset silently keeps
        --   the old value. They have to be cleared BY NAME, which is what the line below does.
        db.topX, db.topY = nil, nil  -- nil defaults are invisible to pairs()
        applyChrome()
        NS.SetMode(db.mode)
    elseif cmd == "demo" then
        NS.SetMode(db.mode == "demo" and "live" or "demo")
    elseif NS.active and NS.active.slash and NS.active.slash(cmd, arg) then
        -- feed handled it
    else
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cff88ff88PetGrid|r: /petgrid lock | unlock | scale <0.5-2> | reset | demo | stats | resetstats")
    end
end
