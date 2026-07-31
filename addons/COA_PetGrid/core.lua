-- COA_PetGrid core.lua - v0.1.0 CHASSIS STUB (pass 2 of the pet parser build).
--
-- This pass proves the five stability concerns from the scope doc in isolation:
--   1. create-once + row POOLING (rows acquire/release, never recreated)
--   2. position persistence (anchor in SV, drag + lock)
--   3. update discipline (ticker writes to existing regions only, no re-layout)
--   4. scale + visibility
--   5. no lockdown needed (display-only frames)
-- The DATA IS FAKE (a demo ticker). The real grid replaces the feed, keeps the
-- chassis. Also proves the HP 3-state display visually: one demo row cycles
-- LIVE -> STALE (grey at last-known) -> GONE (row collapses) -> back.
--
--   /petgrid            controls list
--   /petgrid lock|unlock  drag handle off/on (locked = click-through)
--   /petgrid scale <x>  0.5 - 2.0
--   /petgrid reset      re-center + defaults
--   /petgrid demo       toggle the fake feed

local ADDON = ...

-- layout constants (v0.1.1: rebalanced after live clipping report - the right
-- stat block starts at WIDTH-8-3*STAT_W_SP; name+bar must end short of it)
local ROW_H, WIDTH = 14, 240
local NAME_W, BAR_W, STAT_W, STAT_SP = 70, 50, 32, 34
local defaults = { point = "CENTER", x = 0, y = 0, scale = 1.0, locked = false, demo = true }

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

local grip = CreateFrame("Frame", nil, root)  -- drag handle, visible when unlocked
grip:SetPoint("TOPLEFT", root, "TOPLEFT", 0, 0)
grip:SetPoint("TOPRIGHT", root, "TOPRIGHT", 0, 0)
grip:SetHeight(12)
grip:EnableMouse(true)
grip:RegisterForDrag("LeftButton")
grip:SetScript("OnDragStart", function() root:StartMoving() end)
grip:SetScript("OnDragStop", function()
    root:StopMovingOrSizing()
    local point, _, _, x, y = root:GetPoint(1)
    db.point, db.x, db.y = point, x, y
end)
local gripTex = grip:CreateTexture(nil, "BACKGROUND")
gripTex:SetAllPoints(grip)
gripTex:SetTexture(0.3, 0.5, 0.3, 0.5)
local title = grip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
title:SetPoint("CENTER", grip, "CENTER", 0, 0)
title:SetText("PetGrid (drag - /petgrid lock)")

local function applyChrome()
    root:SetScale(db.scale)
    root:ClearAllPoints()
    root:SetPoint(db.point, UIParent, db.point, db.x, db.y)
    if db.locked then grip:Hide() else grip:Show() end
end

-- ---------------------------------------------------------------- row pool
-- One row frame kind; sections compose it (Raise shows the HP bar, Animate
-- hides it and leads with count). Created once, acquired/released forever.
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
    -- absolute last-known HP rides ON the bar (fraction = bar, total = text;
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
-- name column, an HP label over the bar slot, column labels over the stat slots
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
local function layout(raiseRows, familyRows)
    releaseRows()
    releaseHeaders()
    local y = -14  -- below the grip line

    local function place(el, indent)
        el:ClearAllPoints()
        el:SetPoint("TOPLEFT", root, "TOPLEFT", 4 + (indent or 0), y)
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
        local h = acquireHeader("Animate", "", "#", "Crit", "Miss")
        place(h); y = y - 13
        for _, data in ipairs(familyRows) do
            local r = acquireRow()
            r.hp:Hide()
            place(r); y = y - ROW_H
            r.data = data
        end
    end
    root:SetHeight(-y + 6)
end

-- write pass: contents only, no anchors touched (concern 3 made visible)
local function writeRows()
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
        else -- family
            r.name:SetText(d.name)
            r.name:SetTextColor(0.85, 0.75, 1)
            r.stats[1]:SetText("x" .. d.count)
            r.stats[2]:SetText(d.crit)
            r.stats[3]:SetText(d.miss)
        end
    end
end

-- ---------------------------------------------------------------- demo feed
-- Fake data shaped like the real thing: Raise rows LF-desc, one row cycling
-- LIVE->STALE->GONE->back; a family count that breathes. Every visual state
-- the real grid needs, exercised on a timer.
local demoRaise = {
    { kind = "raise", name = "Abomination", lf = 3, hpFrac = 1.0, hpMax = 12400, dmg = "1.2k", crit = "14%", miss = "5%", state = "live" },
    { kind = "raise", name = "Banshee",     lf = 2, hpFrac = 0.8, hpMax = 6100,  dmg = "640",  crit = "9%",  miss = "3%", state = "live" },
    { kind = "raise", name = "Ghoul",       lf = 1, hpFrac = 0.6, hpMax = 4900,  dmg = "410",  crit = "16%", miss = "6%", state = "live" },
}
local demoFamily = {
    { kind = "family", name = "Zombies", count = 6, crit = "11%", miss = "4%" },
    { kind = "family", name = "Archers", count = 3, crit = "13%", miss = "2%" },
}

local demoClock, demoPhase, lastRaiseN = 0, 0, -1
local function demoTick(dt)
    demoClock = demoClock + dt
    if demoClock < 0.5 then return end
    demoClock = 0
    demoPhase = demoPhase + 1

    -- HP jiggle (write-only churn: flicker test)
    for _, d in ipairs(demoRaise) do
        if d.state == "live" then
            d.hpFrac = d.hpFrac - 0.07
            if d.hpFrac < 0.15 then d.hpFrac = 1.0 end
        end
    end
    demoFamily[1].count = 4 + math.fmod(demoPhase, 5)

    -- the Ghoul cycles the 3-state machine every ~12s: live -> stale -> gone -> live
    local ghoul = demoRaise[3]
    local step = math.fmod(demoPhase, 24)
    local wantGone = (step >= 16 and step < 20)
    ghoul.state = (step >= 8 and step < 16) and "stale" or "live"

    local raiseSet = {}
    for _, d in ipairs(demoRaise) do
        if not (d == ghoul and wantGone) then raiseSet[#raiseSet + 1] = d end
    end
    -- re-layout ONLY on set change (gone-edge), same-set ticks are pure writes
    if #raiseSet ~= lastRaiseN then
        lastRaiseN = #raiseSet
        layout(raiseSet, demoFamily)
    end
    writeRows()
end

local ticker = CreateFrame("Frame")
ticker:Hide()
ticker:SetScript("OnUpdate", function(_, dt) demoTick(dt) end)

local function setDemo(on)
    db.demo = on
    if on then
        layout(demoRaise, demoFamily)
        writeRows()
        root:Show()
        ticker:Show()
    else
        ticker:Hide()
        releaseRows()
        releaseHeaders()
        root:Hide()
    end
end

-- ---------------------------------------------------------------- boot + slash
local boot = CreateFrame("Frame")
boot:RegisterEvent("ADDON_LOADED")
boot:SetScript("OnEvent", function(_, _, name)
    if name ~= ADDON then return end
    boot:UnregisterAllEvents()
    COA_PetGridDB = COA_PetGridDB or {}
    db = COA_PetGridDB
    for k, v in pairs(defaults) do
        if db[k] == nil then db[k] = v end
    end
    applyChrome()
    if db.demo then setDemo(true) end
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
        applyChrome()
        setDemo(db.demo)
    elseif cmd == "demo" then
        setDemo(not db.demo)
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff88ff88PetGrid|r stub: /petgrid lock | unlock | scale <0.5-2> | reset | demo")
    end
end
