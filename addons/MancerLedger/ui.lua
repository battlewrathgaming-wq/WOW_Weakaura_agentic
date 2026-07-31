-- MancerLedger ui.lua - v0.3.0 THE WINDOW: the interface AND the presentation
-- piece. Chat compare proved the data but failed as a medium (Battlewrath:
-- "useful but too constrained to be serviceable"). Every typed command
-- becomes a click; the compare view renders per-type ROW TRIPLETS with the
-- signed DELTA as the middle row.
--
-- Built against real SV data (baseline profile, 2026-07-31): permanent
-- minions carry NO unit-time/summons from the driver (Animate-only tracking)
-- -> those cells render "-", never 0 or a divide.
--
-- Pull model throughout: the window computes ONLY on Show/click/fold-refresh,
-- nothing per-frame. Pooled rows, create-once (the PetGrid chassis DNA).

local ADDON, NS = ...

local WIDTH = 560
local ROW_H = 14
local COLS = {  -- label, width (right-aligned data columns)
    { "Fights", 40 }, { "Summons", 50 }, { "Time", 46 }, { "Hits", 44 },
    { "Cad/m", 46 }, { "Miss%", 44 }, { "Dmg (raw)", 62 },
}
local LABEL_W = 120

local GOLD = { 1, 0.82, 0.15 }
local WHITE = { 1, 1, 1 }
local PURPLE = { 0.85, 0.75, 1 }
local GREY = { 0.65, 0.65, 0.65 }

-- ---------------------------------------------------------------- metrics
-- One place computes a type-log's display cells; compare deltas derive from
-- the same numbers so the two views can never disagree.
local function cells(log)
    local c = {}
    c.fights = log.fights or 0
    -- driver gap: permanents have no summon/unit-time accounting
    c.summons = (log.summonCount or 0) > 0 and log.summonCount or nil
    c.time = (log.activeSeconds or 0) > 0 and log.activeSeconds or nil
    c.hits = log.hits or 0
    c.cad = NS.cadence(log)  -- gated: summons must cover fights (scope-mix guard)
    local attempts = (log.hits or 0) + (log.misses or 0)
    c.miss = attempts >= NS.SAMPLE_FLOOR and ((log.misses or 0) / attempts * 100) or nil
    c.dmg = log.damage or 0
    return c
end

local function fmtCells(c)
    return {
        tostring(c.fights),
        c.summons and tostring(c.summons) or "-",
        c.time and (math.floor(c.time) .. "s") or "-",
        tostring(c.hits),
        c.cad and string.format("%.1f", c.cad) or "-",
        c.miss and string.format("%.0f%%", c.miss) or "-",
        NS.fmtN(c.dmg),
    }
end

local function fmtDelta(a, b)
    local function d(x, y, fmt, suffix)
        if x == nil or y == nil then return "-" end
        local v = y - x
        return string.format(fmt, v) .. (suffix or "")
    end
    return {
        d(a.fights, b.fights, "%+d"),
        d(a.summons, b.summons, "%+d"),
        d(a.time, b.time, "%+ds"),
        d(a.hits, b.hits, "%+d"),
        d(a.cad, b.cad, "%+.1f"),
        d(a.miss, b.miss, "%+.0f", "pp"),
        (a.dmg and b.dmg) and ((b.dmg >= a.dmg and "+" or "-") .. NS.fmtN(math.abs(b.dmg - a.dmg))) or "-",
    }
end

-- ---------------------------------------------------------------- window
local win = CreateFrame("Frame", "MancerLedgerWindow", UIParent)
win:SetWidth(WIDTH)
win:SetHeight(200)
win:SetFrameStrata("DIALOG")
win:SetMovable(true)
win:SetClampedToScreen(true)
win:EnableMouse(true)
win:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
win:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
win:SetBackdropBorderColor(0.5, 0.45, 0.6, 1)
win:Hide()
table.insert(UISpecialFrames, "MancerLedgerWindow")  -- ESC closes

local titleBar = CreateFrame("Frame", nil, win)
titleBar:SetPoint("TOPLEFT", win, "TOPLEFT", 0, 0)
titleBar:SetPoint("TOPRIGHT", win, "TOPRIGHT", 0, 0)
titleBar:SetHeight(22)
titleBar:EnableMouse(true)
titleBar:RegisterForDrag("LeftButton")
titleBar:SetScript("OnDragStart", function() win:StartMoving() end)
titleBar:SetScript("OnDragStop", function()
    win:StopMovingOrSizing()
    local point, _, rel, x, y = win:GetPoint(1)
    NS.GetDb().uiPos = { point = point, rel = rel, x = x, y = y }
end)
local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("LEFT", titleBar, "LEFT", 10, -2)
title:SetText("Mancer Ledger")

local closeBtn = CreateFrame("Button", nil, win, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", win, "TOPRIGHT", -1, -1)

-- ---------------------------------------------------------------- widgets
local function makeButton(parent, text, w)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetWidth(w or 70)
    b:SetHeight(18)
    b:SetText(text)
    return b
end

-- profiles strip
local profilesLabel = win:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
profilesLabel:SetPoint("TOPLEFT", win, "TOPLEFT", 10, -26)
profilesLabel:SetText("Profiles")

local profileBtns = {}       -- pooled selectable profile buttons
local selectedProfile = nil  -- UI selection (not the LIVE marker)

local nameBox = CreateFrame("EditBox", "MancerLedgerNameBox", win, "InputBoxTemplate")
nameBox:SetWidth(100)
nameBox:SetHeight(18)
nameBox:SetAutoFocus(false)
nameBox:SetMaxLetters(24)

local newBtn = makeButton(win, "New", 50)
local renameBtn = makeButton(win, "Rename", 62)
local useBtn = makeButton(win, "Set Live", 64)
local offBtn = makeButton(win, "Rec Off", 60)
local resetBtn = makeButton(win, "Reset", 52)
local deleteBtn = makeButton(win, "Delete", 56)

local statsBtn = makeButton(win, "Stats", 52)
local compareBtn = makeButton(win, "Compare", 70)
local historyBtn = makeButton(win, "History", 60)
local harvestBtn = makeButton(win, "Harvest", 62)
local pickA = makeButton(win, "A: -", 116)
local pickB = makeButton(win, "B: -", 116)

local view = "stats"        -- "stats" | "compare" | "history"
local compA, compB = nil, nil
local deleteArmed = nil     -- two-click delete

-- content rows pool: label + N column fontstrings
local rows, rowPool = {}, {}
local function acquireContentRow()
    local r = table.remove(rowPool)
    if not r then
        r = CreateFrame("Frame", nil, win)
        r:SetWidth(WIDTH - 20)
        r:SetHeight(ROW_H)
        r.label = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        r.label:SetPoint("LEFT", r, "LEFT", 0, 0)
        r.label:SetJustifyH("LEFT")
        r.label:SetWidth(LABEL_W)
        r.cols = {}
        local x = LABEL_W
        for i, col in ipairs(COLS) do
            local fs = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            fs:SetPoint("LEFT", r, "LEFT", x, 0)
            fs:SetJustifyH("RIGHT")
            fs:SetWidth(col[2])
            r.cols[i] = fs
            x = x + col[2] + 4
        end
        -- full-width text line (the history view); hidden in table views
        r.wide = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        r.wide:SetPoint("LEFT", r, "LEFT", 0, 0)
        r.wide:SetJustifyH("LEFT")
        r.wide:SetWidth(WIDTH - 28)
        r.wide:Hide()
    end
    r:Show()
    rows[#rows + 1] = r
    return r
end
local function releaseContentRows()
    for i = #rows, 1, -1 do
        rows[i]:Hide()
        rows[i]:ClearAllPoints()
        rowPool[#rowPool + 1] = rows[i]
        rows[i] = nil
    end
end

local function writeRow(r, label, texts, color)
    color = color or WHITE
    r.wide:Hide()
    r.label:Show()
    r.label:SetText(label)
    r.label:SetTextColor(color[1], color[2], color[3])
    for i, fs in ipairs(r.cols) do
        fs:Show()
        fs:SetText(texts and texts[i] or "")
        fs:SetTextColor(color[1], color[2], color[3])
    end
end

local function writeWideRow(r, text, color)
    color = color or WHITE
    r.label:Hide()
    for _, fs in ipairs(r.cols) do fs:Hide() end
    r.wide:Show()
    r.wide:SetText(text)
    r.wide:SetTextColor(color[1], color[2], color[3])
end

-- ---------------------------------------------------------------- render
local refresh  -- fwd

local function sortedProfileNames(db)
    local names = {}
    for n in pairs(db.profiles) do names[#names + 1] = n end
    table.sort(names)
    return names
end

local function cycle(names, current)
    if #names == 0 then return nil end
    for i, n in ipairs(names) do
        if n == current then return names[i % #names + 1] end
    end
    return names[1]
end

local function sortedTypes(log)
    local t = {}
    for id in pairs(log) do t[#t + 1] = id end
    table.sort(t)
    return t
end

local function renderProfilesStrip(db, yTop)
    -- pooled profile buttons laid horizontally, wrap if needed
    for _, b in ipairs(profileBtns) do b:Hide() end
    local names = sortedProfileNames(db)
    local x, y, i = 70, yTop, 0
    for _, n in ipairs(names) do
        i = i + 1
        local b = profileBtns[i]
        if not b then
            b = makeButton(win, "", 10)
            b:SetScript("OnClick", function(self)
                selectedProfile = self.profileName
                deleteArmed = nil
                refresh()
            end)
            profileBtns[i] = b
        end
        b.profileName = n
        local p = db.profiles[n]
        local marker = (db.active == n) and "|cff66ff66LIVE|r " or ""
        local sel = (selectedProfile == n) and "> " or ""
        local label = sel .. marker .. n .. " (" .. p.folds .. ")"
        b:SetText(label)
        b:SetWidth(math.min(180, 30 + #label * 6))
        if x + b:GetWidth() > WIDTH - 12 then
            x = 70
            y = y - 20
        end
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", win, "TOPLEFT", x, y)
        b:Show()
        x = x + b:GetWidth() + 4
    end
    return y - 22
end

local function renderStats(db, y)
    local p = selectedProfile and db.profiles[selectedProfile]
        or (db.active and db.profiles[db.active])
    if not p then
        local r = acquireContentRow()
        r:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
        writeRow(r, "No profile - name one and click New.", nil, GREY)
        return y - ROW_H
    end
    local cap = acquireContentRow()
    cap:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
    writeRow(cap, p.name .. "  -  " .. NS.stateLine(p.snapshot), nil, GOLD)
    y = y - ROW_H - 2

    local head = acquireContentRow()
    head:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
    local headTexts = {}
    for i, col in ipairs(COLS) do headTexts[i] = col[1] end
    writeRow(head, "Type", headTexts, GREY)
    y = y - ROW_H

    for _, id in ipairs(sortedTypes(p.log)) do
        local r = acquireContentRow()
        r:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
        writeRow(r, NS.prettyId(id), fmtCells(cells(p.log[id])), WHITE)
        y = y - ROW_H
    end
    if not next(p.log) then
        local r = acquireContentRow()
        r:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
        writeRow(r, "(log empty - fights fold on leaving combat)", nil, GREY)
        y = y - ROW_H
    end
    return y
end

local function renderCompare(db, y)
    local pa = compA and db.profiles[compA]
    local pb = compB and db.profiles[compB]
    if not pa or not pb then
        local r = acquireContentRow()
        r:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
        writeRow(r, "Pick two profiles with the A / B buttons.", nil, GREY)
        return y - ROW_H
    end

    local capA = acquireContentRow()
    capA:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
    writeRow(capA, "A: " .. pa.name .. "  -  " .. NS.stateLine(pa.snapshot), nil, WHITE)
    y = y - ROW_H
    local capB = acquireContentRow()
    capB:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
    writeRow(capB, "B: " .. pb.name .. "  -  " .. NS.stateLine(pb.snapshot), nil, WHITE)
    y = y - ROW_H - 2

    local head = acquireContentRow()
    head:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
    local headTexts = {}
    for i, col in ipairs(COLS) do headTexts[i] = col[1] end
    writeRow(head, "", headTexts, GREY)
    y = y - ROW_H

    -- union of types, sorted
    local seen, ids = {}, {}
    for id in pairs(pa.log) do if not seen[id] then seen[id] = true ids[#ids + 1] = id end end
    for id in pairs(pb.log) do if not seen[id] then seen[id] = true ids[#ids + 1] = id end end
    table.sort(ids)

    for _, id in ipairs(ids) do
        local typeHead = acquireContentRow()
        typeHead:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
        writeRow(typeHead, NS.prettyId(id), nil, PURPLE)
        y = y - ROW_H

        local la, lb = pa.log[id], pb.log[id]
        local ca = la and cells(la) or nil
        local cb = lb and cells(lb) or nil

        local rA = acquireContentRow()
        rA:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
        writeRow(rA, "  " .. pa.name, ca and fmtCells(ca) or nil, WHITE)
        y = y - ROW_H

        local rD = acquireContentRow()
        rD:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
        writeRow(rD, "  \226\150\179 delta",
            (ca and cb) and fmtDelta(ca, cb) or nil, GOLD)
        y = y - ROW_H

        local rB = acquireContentRow()
        rB:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
        writeRow(rB, "  " .. pb.name, cb and fmtCells(cb) or nil, WHITE)
        y = y - ROW_H - 2
    end
    return y
end

local function renderHistory(db, y)
    local hist = db.history or {}
    if #hist == 0 then
        local r = acquireContentRow()
        r:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
        writeWideRow(r, "(no events yet - folds, profile changes and warnings land here)", GREY)
        return y - ROW_H
    end
    for i = 1, math.min(#hist, 22) do
        local h = hist[i]
        local r = acquireContentRow()
        r:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
        writeWideRow(r, "|cff888888" .. (h.t or "?") .. "|r  " .. (h.msg or ""),
            i == 1 and GOLD or WHITE)
        y = y - ROW_H
    end
    if #hist > 22 then
        local r = acquireContentRow()
        r:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
        writeWideRow(r, "(" .. (#hist - 22) .. " older kept, cap " .. 50 .. ")", GREY)
        y = y - ROW_H
    end
    return y
end

refresh = function()
    local db = NS.GetDb()
    if not db then return end
    releaseContentRows()

    -- default UI selections
    if selectedProfile and not db.profiles[selectedProfile] then selectedProfile = nil end
    if compA and not db.profiles[compA] then compA = nil end
    if compB and not db.profiles[compB] then compB = nil end
    if not compA then compA = db.active end

    local y = renderProfilesStrip(db, -26)

    -- manage strip: the name box feeds New (create) and Rename (selected)
    nameBox:ClearAllPoints()
    nameBox:SetPoint("TOPLEFT", win, "TOPLEFT", 18, y)
    local order = { newBtn, renameBtn, useBtn, offBtn, resetBtn, deleteBtn }
    local prev = nameBox
    for _, b in ipairs(order) do
        b:ClearAllPoints()
        b:SetPoint("LEFT", prev, "RIGHT", 4, 0)
        prev = b
    end
    y = y - 24

    -- view strip
    statsBtn:ClearAllPoints()
    statsBtn:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
    compareBtn:ClearAllPoints()
    compareBtn:SetPoint("LEFT", statsBtn, "RIGHT", 4, 0)
    historyBtn:ClearAllPoints()
    historyBtn:SetPoint("LEFT", compareBtn, "RIGHT", 4, 0)
    harvestBtn:ClearAllPoints()
    harvestBtn:SetPoint("LEFT", historyBtn, "RIGHT", 10, 0)
    pickA:ClearAllPoints()
    pickA:SetPoint("LEFT", harvestBtn, "RIGHT", 10, 0)
    pickB:ClearAllPoints()
    pickB:SetPoint("LEFT", pickA, "RIGHT", 4, 0)
    pickA:SetText("A: " .. (compA or "-"))
    pickB:SetText("B: " .. (compB or "-"))
    if view == "compare" then pickA:Show() pickB:Show() else pickA:Hide() pickB:Hide() end
    deleteBtn:SetText(deleteArmed and "Sure?" or "Delete")
    y = y - 26

    -- the lockout banner: pinned in clear view across EVERY view while latched
    local lock = NS.locked and NS.locked()
    if lock then
        local r = acquireContentRow()
        r:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
        writeWideRow(r, "FOLDS LOCKED (" .. (lock.at or "?") .. "): " .. (lock.reason or "?"),
            { 1.0, 0.72, 0.2 })
        y = y - ROW_H
        local r2 = acquireContentRow()
        r2:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y)
        writeWideRow(r2, "driver " .. (lock.driver or "?") .. " shape not understood - "
            .. "waiting for an update. Harvest = retry.", GREY)
        y = y - ROW_H - 3
    end

    if view == "stats" then
        y = renderStats(NS.GetDb(), y)
    elseif view == "compare" then
        y = renderCompare(NS.GetDb(), y)
    else
        y = renderHistory(NS.GetDb(), y)
    end

    win:SetHeight(-y + 14)
end

-- ---------------------------------------------------------------- wiring
local function repaintToken()
    if NS.minimapPaint then NS.minimapPaint() end
end

newBtn:SetScript("OnClick", function()
    local name = nameBox:GetText()
    local ok, err = NS.profileNew(name)
    if not ok then NS.say(err) refresh() return end
    nameBox:SetText("")
    nameBox:ClearFocus()
    selectedProfile = name
    repaintToken()
    refresh()
end)
renameBtn:SetScript("OnClick", function()
    if not selectedProfile then NS.say("select a profile first") refresh() return end
    local oldName, newName = selectedProfile, nameBox:GetText()
    local ok, err = NS.profileRename(oldName, newName)
    if not ok then NS.say(err) refresh() return end
    nameBox:SetText("")
    nameBox:ClearFocus()
    selectedProfile = newName
    if compA == oldName then compA = newName end
    if compB == oldName then compB = newName end
    refresh()
end)
useBtn:SetScript("OnClick", function()
    if not selectedProfile then NS.say("select a profile first") refresh() return end
    NS.profileUse(selectedProfile)
    repaintToken()
    refresh()
end)
offBtn:SetScript("OnClick", function()
    NS.profileOff()
    repaintToken()
    refresh()
end)
resetBtn:SetScript("OnClick", function()
    if not selectedProfile then NS.say("select a profile first") return end
    NS.profileResetLog(selectedProfile)
    refresh()
end)
deleteBtn:SetScript("OnClick", function()
    if not selectedProfile then NS.say("select a profile first") return end
    if deleteArmed == selectedProfile then
        NS.profileDelete(selectedProfile)
        deleteArmed = nil
        selectedProfile = nil
    else
        deleteArmed = selectedProfile  -- second click confirms
    end
    refresh()
end)
harvestBtn:SetScript("OnClick", function()
    local n = NS.harvest(true)  -- the button is the manual retry when locked
    if n == 0 then NS.say("nothing new to fold.") end
    repaintToken()
    refresh()
end)
statsBtn:SetScript("OnClick", function() view = "stats" refresh() end)
compareBtn:SetScript("OnClick", function() view = "compare" refresh() end)
historyBtn:SetScript("OnClick", function() view = "history" refresh() end)
pickA:SetScript("OnClick", function()
    compA = cycle(sortedProfileNames(NS.GetDb()), compA)
    refresh()
end)
pickB:SetScript("OnClick", function()
    compB = cycle(sortedProfileNames(NS.GetDb()), compB)
    refresh()
end)
nameBox:SetScript("OnEnterPressed", function() newBtn:GetScript("OnClick")() end)
nameBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

-- ---------------------------------------------------------------- surface
NS.ui = {}

function NS.ui.Show()
    local db = NS.GetDb()
    if db and db.uiPos then
        win:ClearAllPoints()
        win:SetPoint(db.uiPos.point or "CENTER", UIParent, db.uiPos.rel or db.uiPos.point or "CENTER",
            db.uiPos.x or 0, db.uiPos.y or 0)
    elseif not win:GetPoint(1) then
        win:SetPoint("CENTER", UIParent, "CENTER", 0, 60)
    end
    deleteArmed = nil
    win:Show()
    refresh()
end

function NS.ui.Toggle()
    if win:IsShown() then win:Hide() else NS.ui.Show() end
end

function NS.ui.RefreshIfShown()
    if win:IsShown() then refresh() end
end

-- ---------------------------------------------------------------- options panel
local panel = CreateFrame("Frame", "MancerLedgerOptions", UIParent)
panel.name = "MancerLedger"
local pt = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
pt:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16)
pt:SetText("Mancer Ledger")
local pd = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
pd:SetPoint("TOPLEFT", pt, "BOTTOMLEFT", 0, -8)
pd:SetWidth(380)
pd:SetJustifyH("LEFT")
pd:SetText("Long-term minion averages over Mancer's per-fight data. Profiles are " ..
    "opt-in: nothing folds until you create one. Reads Mancer's saved fights only - " ..
    "writes nothing outside its own ledger. Fights fold once (deduped by Mancer's own " ..
    "fingerprints), on leaving combat and at login.")
local openBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
openBtn:SetWidth(140)
openBtn:SetHeight(22)
openBtn:SetPoint("TOPLEFT", pd, "BOTTOMLEFT", 0, -12)
openBtn:SetText("Open the Ledger")
openBtn:SetScript("OnClick", function() NS.ui.Show() end)
local alias = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
alias:SetPoint("TOPLEFT", openBtn, "BOTTOMLEFT", 0, -10)
alias:SetText("Command alias: /mledger")
if InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panel)
end
