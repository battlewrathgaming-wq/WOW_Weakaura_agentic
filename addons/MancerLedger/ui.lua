-- MancerLedger ui.lua - v0.6 THE CALM WINDOW (Battlewrath: "The data is
-- complex. The UI should be calm.")
--
-- Wireframe: fixed chrome, laid out ONCE - refresh touches texts and content
-- rows only, never re-anchors controls.
--
--   [ title bar .......................................... X ]
--   Profile  [ dropdown v ]                :: status (right)
--   ---------------------------------------------------------
--   [name.....] [New] [Rename]   [Set Live] [Rec Off]   [Reset] [Delete]
--   ---------------------------------------------------------
--   [Stats] [Compare] [History]                    [Harvest]
--   ( A: [dropdown v]  B: [dropdown v]   - compare view only )
--   +-------------------- content inset ---------------------+
--   |  lockout banner (when latched)                         |
--   |  rows                                                  |
--   +--------------------------------------------------------+
--
-- One selector: the dropdown picks the WORKING profile (stats + manage ops
-- target it). LIVE is a state shown in the status line, granted by Set Live.

local ADDON, NS = ...

local WIDTH = 560
local ROW_H = 14
local LABEL_W = 120
local MAX_COLS = 7

local GOLD = { 1, 0.82, 0.15 }
local WHITE = { 1, 1, 1 }
local PURPLE = { 0.85, 0.75, 1 }
local GREY = { 0.65, 0.65, 0.65 }
local AMBER = { 1.0, 0.72, 0.2 }

-- ---------------------------------------------------------------- metrics
local function cells(log)
    local c = {}
    c.fights = log.fights or 0
    c.summons = (log.summonCount or 0) > 0 and log.summonCount or nil
    c.time = (log.activeSeconds or 0) > 0 and log.activeSeconds or nil
    c.hits = log.hits or 0
    c.attempts = (log.hits or 0) + (log.misses or 0)
    c.cad = NS.cadence(log)
    c.miss = c.attempts >= NS.SAMPLE_FLOOR and ((log.misses or 0) / c.attempts * 100) or nil
    c.dmg = log.damage or 0
    return c
end

-- column definitions: each knows its label, width, value text, delta text.
-- Pages are just column SETS over the same cells (the same data set, split by
-- comparability class - Battlewrath).
local function dInt(x, y)
    if x == nil or y == nil then return "-" end
    return string.format("%+d", y - x)
end
local COL = {
    fights = { "Fights", 40,
        function(c) return tostring(c.fights) end,
        function(a, b) return dInt(a.fights, b.fights) end },
    summons = { "Sum", 50,
        function(c) return c.summons and tostring(c.summons) or "-" end,
        function(a, b) return dInt(a.summons, b.summons) end },
    time = { "Time", 46,
        function(c) return c.time and (math.floor(c.time) .. "s") or "-" end,
        function(a, b)
            if a.time == nil or b.time == nil then return "-" end
            return string.format("%+ds", b.time - a.time)
        end },
    hits = { "Hits", 44,
        function(c) return tostring(c.hits) end,
        function(a, b) return dInt(a.hits, b.hits) end },
    attempts = { "Attempts", 54,
        function(c) return tostring(c.attempts) end,
        function(a, b) return dInt(a.attempts, b.attempts) end },
    cad = { "Cad/m", 46,
        function(c) return c.cad and string.format("%.1f", c.cad) or "-" end,
        function(a, b)
            if a.cad == nil or b.cad == nil then return "-" end
            return string.format("%+.1f", b.cad - a.cad)
        end },
    miss = { "Miss%", 44,
        function(c) return c.miss and string.format("%.0f%%", c.miss) or "-" end,
        function(a, b)
            if a.miss == nil or b.miss == nil then return "-" end
            return string.format("%+.0fpp", b.miss - a.miss)
        end },
    dmg = { "Dmg (raw)", 62,
        function(c) return NS.fmtN(c.dmg) end,
        function(a, b)
            if a.dmg == nil or b.dmg == nil then return "-" end
            return (b.dmg >= a.dmg and "+" or "-") .. NS.fmtN(math.abs(b.dmg - a.dmg))
        end },
}

local COLS_FULL = { COL.fights, COL.summons, COL.time, COL.hits, COL.cad, COL.miss, COL.dmg }
local COLS_RATES = { COL.attempts, COL.cad, COL.miss }
local COLS_VOLUME = { COL.fights, COL.summons, COL.time, COL.hits, COL.dmg }

local currentCols = COLS_FULL

local function fmtCells(c)
    local out = {}
    for i, col in ipairs(currentCols) do out[i] = col[3](c) end
    return out
end

local function fmtDelta(a, b)
    local out = {}
    for i, col in ipairs(currentCols) do out[i] = col[4](a, b) end
    return out
end

-- ---------------------------------------------------------------- window
local win = CreateFrame("Frame", "MancerLedgerWindow", UIParent)
win:SetWidth(WIDTH)
win:SetHeight(240)
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
table.insert(UISpecialFrames, "MancerLedgerWindow")

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

local function divider(yOff)
    local t = win:CreateTexture(nil, "ARTWORK")
    t:SetHeight(1)
    t:SetPoint("TOPLEFT", win, "TOPLEFT", 10, yOff)
    t:SetPoint("TOPRIGHT", win, "TOPRIGHT", -10, yOff)
    t:SetTexture(0.35, 0.32, 0.42, 0.7)
    return t
end

-- ---------------------------------------------------------------- state
local selectedProfile = nil
local view = "stats"
local compA, compB = nil, nil
local deleteArmed = nil
local refresh  -- fwd

local function sortedProfileNames(db)
    local names = {}
    for n in pairs(db.profiles) do names[#names + 1] = n end
    table.sort(names)
    return names
end

-- ---------------------------------------------------------------- row 1: profile
local profLabel = win:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
profLabel:SetPoint("TOPLEFT", win, "TOPLEFT", 12, -30)
profLabel:SetText("Profile")

-- dropdown factory (native template = the calm, familiar look)
local function makeDropdown(name, width, onSelect, textFor)
    local dd = CreateFrame("Frame", name, win, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(dd, width)
    UIDropDownMenu_Initialize(dd, function()
        local db = NS.GetDb()
        if not db then return end
        for _, n in ipairs(sortedProfileNames(db)) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = textFor and textFor(n, db) or n
            info.func = function() onSelect(n) end
            info.checked = nil
            UIDropDownMenu_AddButton(info)
        end
    end)
    return dd
end

local profDD = makeDropdown("MancerLedgerProfileDD", 130, function(n)
    selectedProfile = n
    deleteArmed = nil
    refresh()
end, function(n, db)
    return (db.active == n) and (n .. " |cff66ff66(live)|r") or n
end)
profDD:SetPoint("LEFT", profLabel, "RIGHT", -6, -2)

local statusText = win:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
statusText:SetPoint("TOPRIGHT", win, "TOPRIGHT", -14, -34)
statusText:SetJustifyH("RIGHT")

divider(-56)

-- ---------------------------------------------------------------- row 2: manage
local nameBox = CreateFrame("EditBox", "MancerLedgerNameBox", win, "InputBoxTemplate")
nameBox:SetWidth(96)
nameBox:SetHeight(18)
nameBox:SetAutoFocus(false)
nameBox:SetMaxLetters(24)
nameBox:SetPoint("TOPLEFT", win, "TOPLEFT", 20, -64)

local function makeButton(text, w)
    local b = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
    b:SetWidth(w or 64)
    b:SetHeight(18)
    b:SetText(text)
    return b
end

local newBtn = makeButton("New", 46)
newBtn:SetPoint("LEFT", nameBox, "RIGHT", 4, 0)
local renameBtn = makeButton("Rename", 60)
renameBtn:SetPoint("LEFT", newBtn, "RIGHT", 2, 0)

local useBtn = makeButton("Set Live", 62)
useBtn:SetPoint("LEFT", renameBtn, "RIGHT", 14, 0)
local offBtn = makeButton("Rec Off", 58)
offBtn:SetPoint("LEFT", useBtn, "RIGHT", 2, 0)

local resetBtn = makeButton("Reset", 50)
resetBtn:SetPoint("LEFT", offBtn, "RIGHT", 14, 0)
local deleteBtn = makeButton("Delete", 56)
deleteBtn:SetPoint("LEFT", resetBtn, "RIGHT", 2, 0)

divider(-88)

-- ---------------------------------------------------------------- row 3: views
local statsBtn = makeButton("Stats", 52)
statsBtn:SetPoint("TOPLEFT", win, "TOPLEFT", 12, -94)
local compareBtn = makeButton("Compare", 68)
compareBtn:SetPoint("LEFT", statsBtn, "RIGHT", 2, 0)
local historyBtn = makeButton("History", 58)
historyBtn:SetPoint("LEFT", compareBtn, "RIGHT", 2, 0)
local harvestBtn = makeButton("Harvest", 60)
harvestBtn:SetPoint("TOPRIGHT", win, "TOPRIGHT", -12, -94)

-- compare sub-row (shown only in compare view)
local aLabel = win:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
aLabel:SetPoint("TOPLEFT", win, "TOPLEFT", 14, -122)
aLabel:SetText("A")
local ddA = makeDropdown("MancerLedgerCompareA", 120, function(n) compA = n refresh() end)
ddA:SetPoint("LEFT", aLabel, "RIGHT", -8, -2)
local bLabel = win:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
bLabel:SetPoint("LEFT", aLabel, "RIGHT", 165, 0)
bLabel:SetText("B")
local ddB = makeDropdown("MancerLedgerCompareB", 120, function(n) compB = n refresh() end)
ddB:SetPoint("LEFT", bLabel, "RIGHT", -8, -2)

-- page 1 / page 2 of the same data set, split by comparability class
local comparePage = "rates"
local ratesBtn = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
ratesBtn:SetWidth(52)
ratesBtn:SetHeight(18)
ratesBtn:SetText("Rates")
ratesBtn:SetPoint("TOPRIGHT", win, "TOPRIGHT", -70, -122)
local volumeBtn = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
volumeBtn:SetWidth(58)
volumeBtn:SetHeight(18)
volumeBtn:SetText("Volume")
volumeBtn:SetPoint("LEFT", ratesBtn, "RIGHT", 2, 0)

-- ---------------------------------------------------------------- content inset
local inset = CreateFrame("Frame", nil, win)
inset:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
inset:SetBackdropColor(0.02, 0.02, 0.04, 0.9)
inset:SetBackdropBorderColor(0.3, 0.28, 0.38, 0.9)
inset:SetPoint("TOPLEFT", win, "TOPLEFT", 8, -118)   -- moves down in compare view
inset:SetPoint("TOPRIGHT", win, "TOPRIGHT", -8, -118)
inset:SetHeight(60)

local rows, rowPool = {}, {}
local function applyColLayout(r)
    -- reposition only when the active column SET changed (page/view switch),
    -- never per refresh - the calm rule holds
    if r.appliedCols == currentCols then return end
    r.appliedCols = currentCols
    local x = LABEL_W
    for i = 1, MAX_COLS do
        local fs = r.cols[i]
        local col = currentCols[i]
        if col then
            fs:ClearAllPoints()
            fs:SetPoint("LEFT", r, "LEFT", x, 0)
            fs:SetWidth(col[2])
            x = x + col[2] + 4
        end
    end
end

local function acquireContentRow()
    local r = table.remove(rowPool)
    if not r then
        r = CreateFrame("Frame", nil, inset)
        r:SetWidth(WIDTH - 32)
        r:SetHeight(ROW_H)
        r.label = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        r.label:SetPoint("LEFT", r, "LEFT", 0, 0)
        r.label:SetJustifyH("LEFT")
        r.label:SetWidth(LABEL_W)
        r.label:SetHeight(ROW_H)  -- clip, never wrap
        r.cols = {}
        for i = 1, MAX_COLS do
            local fs = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            fs:SetJustifyH("RIGHT")
            fs:SetHeight(ROW_H)
            r.cols[i] = fs
        end
        r.wide = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        r.wide:SetPoint("LEFT", r, "LEFT", 0, 0)
        r.wide:SetJustifyH("LEFT")
        r.wide:SetWidth(WIDTH - 40)
        r.wide:SetHeight(ROW_H)
        r.wide:Hide()
    end
    applyColLayout(r)
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
        if currentCols[i] then
            fs:Show()
            fs:SetText(texts and texts[i] or "")
            fs:SetTextColor(color[1], color[2], color[3])
        else
            fs:Hide()
        end
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

-- ---------------------------------------------------------------- renderers
-- rows anchor inside the inset; y is relative to inset top
local function placeRow(r, y)
    r:SetPoint("TOPLEFT", inset, "TOPLEFT", 8, y)
end

local function headerTexts()
    local t = {}
    for i, col in ipairs(currentCols) do t[i] = col[1] end
    return t
end

local function renderStats(db, y)
    local p = selectedProfile and db.profiles[selectedProfile]
        or (db.active and db.profiles[db.active])
    if not p then
        local r = acquireContentRow()
        placeRow(r, y)
        writeWideRow(r, "No profile yet - type a name and click New.", GREY)
        return y - ROW_H
    end
    local cap = acquireContentRow()
    placeRow(cap, y)
    writeWideRow(cap, p.name .. "  -  " .. NS.stateLine(p.snapshot), GOLD)
    y = y - ROW_H - 3

    local head = acquireContentRow()
    placeRow(head, y)
    writeRow(head, "Type", headerTexts(), GREY)
    y = y - ROW_H

    local ids = {}
    for id in pairs(p.log) do ids[#ids + 1] = id end
    table.sort(ids)
    for _, id in ipairs(ids) do
        local r = acquireContentRow()
        placeRow(r, y)
        writeRow(r, NS.prettyId(id), fmtCells(cells(p.log[id])), WHITE)
        y = y - ROW_H
    end
    if #ids == 0 then
        local r = acquireContentRow()
        placeRow(r, y)
        writeWideRow(r, "(log empty - fights fold on leaving combat)", GREY)
        y = y - ROW_H
    end
    return y
end

local function renderCompare(db, y)
    local pa = compA and db.profiles[compA]
    local pb = compB and db.profiles[compB]
    if not pa or not pb then
        local r = acquireContentRow()
        placeRow(r, y)
        writeWideRow(r, "Pick profiles A and B above.", GREY)
        return y - ROW_H
    end

    local capA = acquireContentRow()
    placeRow(capA, y)
    writeWideRow(capA, "A  " .. pa.name .. "  -  " .. NS.stateLine(pa.snapshot), WHITE)
    y = y - ROW_H
    local capB = acquireContentRow()
    placeRow(capB, y)
    writeWideRow(capB, "B  " .. pb.name .. "  -  " .. NS.stateLine(pb.snapshot), WHITE)
    y = y - ROW_H - 3

    local head = acquireContentRow()
    placeRow(head, y)
    writeRow(head, "", headerTexts(), GREY)
    y = y - ROW_H

    local seen, ids = {}, {}
    for id in pairs(pa.log) do seen[id] = true ids[#ids + 1] = id end
    for id in pairs(pb.log) do if not seen[id] then ids[#ids + 1] = id end end
    table.sort(ids)

    for _, id in ipairs(ids) do
        local th = acquireContentRow()
        placeRow(th, y)
        writeWideRow(th, NS.prettyId(id), PURPLE)
        y = y - ROW_H

        local la, lb = pa.log[id], pb.log[id]
        local ca = la and cells(la) or nil
        local cb = lb and cells(lb) or nil

        local rA = acquireContentRow()
        placeRow(rA, y)
        writeRow(rA, "  " .. pa.name, ca and fmtCells(ca) or nil, WHITE)
        y = y - ROW_H
        local rD = acquireContentRow()
        placeRow(rD, y)
        writeRow(rD, "  \226\150\179 delta", (ca and cb) and fmtDelta(ca, cb) or nil, GOLD)
        y = y - ROW_H
        local rB = acquireContentRow()
        placeRow(rB, y)
        writeRow(rB, "  " .. pb.name, cb and fmtCells(cb) or nil, WHITE)
        y = y - ROW_H - 2
    end

    -- the best-use note, quiet, at the foot of the page
    y = y - 2
    local note = acquireContentRow()
    placeRow(note, y)
    if comparePage == "rates" then
        writeWideRow(note, "Rates hold up across ordinary play - fight length doesn't skew them.", GREY)
    else
        writeWideRow(note, "Volumes read best from controlled tests: same target, same army, similar fight lengths.", GREY)
    end
    y = y - ROW_H
    return y
end

local function renderHistory(db, y)
    local hist = db.history or {}
    if #hist == 0 then
        local r = acquireContentRow()
        placeRow(r, y)
        writeWideRow(r, "(no events yet - folds, profile changes and warnings land here)", GREY)
        return y - ROW_H
    end
    for i = 1, math.min(#hist, 22) do
        local h = hist[i]
        local r = acquireContentRow()
        placeRow(r, y)
        writeWideRow(r, "|cff888888" .. (h.t or "?") .. "|r  " .. (h.msg or ""),
            i == 1 and GOLD or WHITE)
        y = y - ROW_H
    end
    if #hist > 22 then
        local r = acquireContentRow()
        placeRow(r, y)
        writeWideRow(r, "(" .. (#hist - 22) .. " older kept, cap 50)", GREY)
        y = y - ROW_H
    end
    return y
end

-- ---------------------------------------------------------------- refresh
refresh = function()
    local db = NS.GetDb()
    if not db then return end
    releaseContentRows()

    if selectedProfile and not db.profiles[selectedProfile] then selectedProfile = nil end
    if not selectedProfile then selectedProfile = db.active end
    if compA and not db.profiles[compA] then compA = nil end
    if compB and not db.profiles[compB] then compB = nil end
    if not compA then compA = db.active end

    -- texts only; no re-anchoring
    UIDropDownMenu_SetText(profDD, selectedProfile or "select...")
    UIDropDownMenu_SetText(ddA, compA or "pick A")
    UIDropDownMenu_SetText(ddB, compB or "pick B")

    local lock = NS.locked and NS.locked()
    if lock then
        statusText:SetText("|cffffb833\226\151\143 LOCKED|r - driver shape not understood")
    elseif db.active then
        local p = db.profiles[db.active]
        statusText:SetText("|cff66ff66\226\151\143 Recording:|r " .. db.active
            .. " |cff888888(" .. (p and p.folds or 0) .. " fights)|r")
    else
        statusText:SetText("|cffff6666\226\151\143 Not recording|r")
    end

    deleteBtn:SetText(deleteArmed and "Sure?" or "Delete")

    -- view tab emphasis: the active one is disabled (can't re-click) = quiet
    statsBtn:Enable() compareBtn:Enable() historyBtn:Enable()
    if view == "stats" then statsBtn:Disable()
    elseif view == "compare" then compareBtn:Disable()
    else historyBtn:Disable() end

    -- compare pickers + page buttons only exist in compare view; the active
    -- column SET follows the view/page
    local contentTop = -118
    if view == "compare" then
        aLabel:Show() ddA:Show() bLabel:Show() ddB:Show()
        ratesBtn:Show() volumeBtn:Show()
        ratesBtn:Enable() volumeBtn:Enable()
        if comparePage == "rates" then ratesBtn:Disable() else volumeBtn:Disable() end
        currentCols = (comparePage == "rates") and COLS_RATES or COLS_VOLUME
        contentTop = -146
    else
        aLabel:Hide() ddA:Hide() bLabel:Hide() ddB:Hide()
        ratesBtn:Hide() volumeBtn:Hide()
        currentCols = COLS_FULL
    end
    inset:ClearAllPoints()
    inset:SetPoint("TOPLEFT", win, "TOPLEFT", 8, contentTop)
    inset:SetPoint("TOPRIGHT", win, "TOPRIGHT", -8, contentTop)

    local y = -6
    if lock then
        local r = acquireContentRow()
        placeRow(r, y)
        writeWideRow(r, "FOLDS LOCKED (" .. (lock.at or "?") .. "): " .. (lock.reason or "?"), AMBER)
        y = y - ROW_H
        local r2 = acquireContentRow()
        placeRow(r2, y)
        writeWideRow(r2, "driver " .. (lock.driver or "?") .. " - waiting for an update. Harvest = retry.", GREY)
        y = y - ROW_H - 3
    end

    if view == "stats" then
        y = renderStats(db, y)
    elseif view == "compare" then
        y = renderCompare(db, y)
    else
        y = renderHistory(db, y)
    end

    local contentH = -y + 8
    inset:SetHeight(contentH)
    win:SetHeight(-contentTop + contentH + 12)
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
    if not selectedProfile then NS.say("select a profile first") refresh() return end
    NS.profileResetLog(selectedProfile)
    refresh()
end)
deleteBtn:SetScript("OnClick", function()
    if not selectedProfile then NS.say("select a profile first") refresh() return end
    if deleteArmed == selectedProfile then
        NS.profileDelete(selectedProfile)
        deleteArmed = nil
        selectedProfile = nil
        repaintToken()
    else
        deleteArmed = selectedProfile
    end
    refresh()
end)
harvestBtn:SetScript("OnClick", function()
    local n = NS.harvest(true)
    if n == 0 then NS.say("nothing new to fold.") end
    repaintToken()
    refresh()
end)
statsBtn:SetScript("OnClick", function() view = "stats" refresh() end)
compareBtn:SetScript("OnClick", function() view = "compare" refresh() end)
historyBtn:SetScript("OnClick", function() view = "history" refresh() end)
ratesBtn:SetScript("OnClick", function() comparePage = "rates" refresh() end)
volumeBtn:SetScript("OnClick", function() comparePage = "volume" refresh() end)
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

function NS.ui.SelectProfile(name)  -- programmatic selection (and testable)
    selectedProfile = name
    refresh()
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
