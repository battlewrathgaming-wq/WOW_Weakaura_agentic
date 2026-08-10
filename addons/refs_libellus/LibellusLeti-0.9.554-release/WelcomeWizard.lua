-- First-run welcome wizard: one page per feature group, with Settings options.
Mancer.WelcomeWizard = Mancer.WelcomeWizard or {}
local Wizard = Mancer.WelcomeWizard

-- Section pages that open HUD pieces in move/scale until Next locks them.
local EDIT_FOCUS = {
    bars = "bars",
    ticks = "ticks",
    combat = "combat",
    minions = "minions",
}

-- Each page maps to Settings toggles the player can pick.
local PAGES = {
    {
        id = "bars",
        labelKey = "WIZARD_OPT_BARS",
        labelFallback = "Arc bars",
        blurbKey = "WIZARD_BLURB_BARS",
        blurbFallback = "Those curved mana and health vines around your character. Tick one to try it on — you can drag and resize while you're here. Hit Next when it feels right.",
        options = {
            { key = "showManaBar", kind = "db", labelKey = "OPT_SHOW_MANA_BAR", labelFallback = "Show mana arc bar", default = false },
            { key = "showHealthBar", kind = "db", labelKey = "OPT_SHOW_HEALTH_BAR", labelFallback = "Show health arc bar", default = false },
            { key = "showRunicBar", kind = "db", labelKey = "OPT_SHOW_RUNIC_BAR", labelFallback = "Show runic power bar", default = false },
        },
    },
    {
        id = "ticks",
        labelKey = "WIZARD_OPT_TICKS",
        labelFallback = "Regen ticks",
        blurbKey = "WIZARD_BLURB_TICKS",
        blurbFallback = "Little floating numbers when you regen mana or health. Tick a box to see fake samples bounce around, and drag the anchor if you want them somewhere else.",
        options = {
            { key = "showMana", kind = "db", labelKey = "OPT_SHOW_MANA", labelFallback = "Show mana ticks", default = false },
            { key = "showHealth", kind = "db", labelKey = "OPT_SHOW_HEALTH", labelFallback = "Show health ticks", default = false },
            { key = "showRegenRate", kind = "db", labelKey = "OPT_SHOW_REGEN_RATE", labelFallback = "Show last mana tick label", default = false },
            { key = "regenOnly", kind = "db", labelKey = "OPT_REGEN_ONLY", labelFallback = "Regen-only filter", default = false },
        },
    },
    {
        id = "combat",
        labelKey = "WIZARD_OPT_COMBAT",
        labelFallback = "Combat helpers",
        blurbKey = "WIZARD_BLURB_COMBAT",
        blurbFallback = "Handy bits for a fight — procs, Animates, zombies, Life Force, and Undead stance nudges. Tick what you want, move things around, then Next when you're happy.",
        options = {
            { key = "showProcBar", kind = "db", labelKey = "OPT_SHOW_PROC_BAR", labelFallback = "Show proc bar", default = false },
            { key = "showAnimateBar", kind = "db", labelKey = "OPT_SHOW_ANIMATE_BAR", labelFallback = "Show Animate bar", default = false },
            { key = "showZombieCounter", kind = "db", labelKey = "OPT_SHOW_ZOMBIE", labelFallback = "Show zombie counter", default = false },
            { key = "showLifeForceText", kind = "db", labelKey = "OPT_SHOW_LIFE_FORCE", labelFallback = "Show Life Force count", default = false },
            { key = "stanceEnabled", kind = "necro", labelKey = "SETTINGS_TAB_STANCE", labelFallback = "Stance prompts", default = false },
        },
    },
    {
        id = "buffs",
        labelKey = "WIZARD_OPT_BUFFS",
        labelFallback = "Group buffs",
        blurbKey = "WIZARD_BLURB_BUFFS",
        blurbFallback = "In a group your buff bar gets messy fast. This stacks the same buff into one icon so you're not hunting through a wall of identical raises.",
        options = {
            { key = "consolidateBuffs", kind = "db", labelKey = "OPT_CONSOLIDATE_BUFFS", labelFallback = "Stack duplicate buffs", default = false },
        },
    },
    {
        id = "minions",
        labelKey = "WIZARD_OPT_MINIONS",
        labelFallback = "Minion HUD",
        blurbKey = "WIZARD_BLURB_MINIONS",
        blurbFallback = "Keep an eye on your army — live HP bars you can place where you like, plus a bit of DPS info on spell tooltips if you want it.",
        options = {
            { key = "showMinionHpList", kind = "db", labelKey = "OPT_SHOW_MINION_HP", labelFallback = "Show minion HP bars", default = false },
            { key = "tooltipEnabled", kind = "tooltip", labelKey = "OPT_MINION_TOOLTIPS", labelFallback = "Minion DPS spell tooltips", default = false },
        },
    },
    {
        id = "plates",
        labelKey = "WIZARD_OPT_PLATES",
        labelFallback = "Nameplates",
        blurbKey = "WIZARD_BLURB_PLATES",
        blurbFallback = "Prefer just names floating over heads? Or mute plates in busy capitals when FPS dips? Pick what helps.",
        options = {
            { key = "guardians", kind = "plate", labelKey = "PLATE_GUARDIANS", labelFallback = "Guardians (names only)", default = false },
            { key = "players", kind = "plate", labelKey = "PLATE_PLAYERS", labelFallback = "Players (names only)", default = false },
            { key = "npcs", kind = "plate", labelKey = "PLATE_NPCS", labelFallback = "NPCs (names only)", default = false },
            { key = "enemies", kind = "plate", labelKey = "PLATE_ENEMIES", labelFallback = "Enemies (names only)", default = false },
            { key = "disableNameplatesInCapitals", kind = "db", labelKey = "OPT_MUTE_PLATES_CAPITALS", labelFallback = "Mute nameplates in capital cities", default = false },
        },
    },
    {
        id = "minimap",
        labelKey = "WIZARD_OPT_MINIMAP",
        labelFallback = "Minimap button",
        blurbKey = "WIZARD_BLURB_MINIMAP",
        blurbFallback = "A little Leti button on the minimap so Hub and Setup are one click away. Handy if you don't want to remember /leti.",
        options = {
            { key = "showMinimapButton", kind = "minimap", labelKey = "OPT_SHOW_MINIMAP", labelFallback = "Show minimap button", default = false },
        },
    },
}

local function Loc(key, fallback)
    if Mancer.Loc then
        return Mancer.Loc(key, fallback)
    end
    return fallback or key
end

local function EnsureDB()
    MancerDB = MancerDB or {}
    MancerDB.necromancer = MancerDB.necromancer or {}
    MancerDB.minimap = MancerDB.minimap or {}
    MancerDB.minionDps = MancerDB.minionDps or {}
    MancerDB.nameplateNamesOnlyTargets = MancerDB.nameplateNamesOnlyTargets or {}
    return MancerDB
end

local function ApplyOption(opt, enabled)
    local db = EnsureDB()
    local on = enabled and true or false
    if opt.kind == "db" then
        db[opt.key] = on
    elseif opt.kind == "necro" then
        db.necromancer[opt.key] = on
    elseif opt.kind == "tooltip" then
        db.minionDps.tooltipEnabled = on
        if Mancer.MinionTooltipModule and Mancer.MinionTooltipModule.SetEnabled then
            Mancer.MinionTooltipModule:SetEnabled(on)
        end
    elseif opt.kind == "plate" then
        db.nameplateNamesOnlyTargets[opt.key] = on
        local anyPlate = db.nameplateNamesOnlyTargets.guardians
            or db.nameplateNamesOnlyTargets.players
            or db.nameplateNamesOnlyTargets.npcs
            or db.nameplateNamesOnlyTargets.enemies
        db.hideMinionHpNameplateVisuals = anyPlate and true or false
    elseif opt.kind == "minimap" then
        db.minimap.hide = not on
        if Mancer.MinimapButtonModule and Mancer.MinimapButtonModule.SetHidden then
            Mancer.MinimapButtonModule:SetHidden(not on)
        end
    end
end

local function ReadOption(opt)
    local db = EnsureDB()
    if opt.kind == "db" then
        return db[opt.key] and true or false
    elseif opt.kind == "necro" then
        return db.necromancer[opt.key] and true or false
    elseif opt.kind == "tooltip" then
        return db.minionDps.tooltipEnabled and true or false
    elseif opt.kind == "plate" then
        return db.nameplateNamesOnlyTargets[opt.key] and true or false
    elseif opt.kind == "minimap" then
        return not db.minimap.hide
    end
    return false
end

function Wizard:RefreshAddon()
    if Mancer.Refresh then
        Mancer:Refresh()
    end
    if Mancer.Options and Mancer.Options.RefreshFromDB then
        Mancer.Options:RefreshFromDB()
    elseif Mancer.Options and Mancer.Options.Refresh then
        Mancer.Options:Refresh()
    elseif Mancer.Options and Mancer.Options.SyncFromDB then
        Mancer.Options:SyncFromDB()
    end
    if Mancer.UpdateNameplateNamesOnlyTargets then
        Mancer.UpdateNameplateNamesOnlyTargets()
    end
    if Mancer.MinimapButtonModule and Mancer.MinimapButtonModule.ApplyVisibility then
        Mancer.MinimapButtonModule:ApplyVisibility()
    end
    if Mancer.Hub and Mancer.Hub.SyncControls then
        Mancer.Hub:SyncControls()
    end
end

function Wizard:SnapshotSettings()
    self._snapshot = {}
    for i = 1, #PAGES do
        local page = PAGES[i]
        for j = 1, #page.options do
            local opt = page.options[j]
            local id = page.id .. ":" .. opt.key
            self._snapshot[id] = ReadOption(opt)
        end
    end
end

function Wizard:RestoreSnapshot()
    if type(self._snapshot) ~= "table" then
        return
    end
    for i = 1, #PAGES do
        local page = PAGES[i]
        for j = 1, #page.options do
            local opt = page.options[j]
            local id = page.id .. ":" .. opt.key
            local value = self._snapshot[id]
            if value ~= nil then
                ApplyOption(opt, value)
            end
        end
    end
    self:RefreshAddon()
end

function Wizard:PreviewOption(opt, enabled)
    ApplyOption(opt, enabled)
    self:RefreshAddon()
    self:SyncSectionPreview()
end

function Wizard:StopTickPreview()
    if self._tickPreview then
        self._tickPreview:SetScript("OnUpdate", nil)
        self._tickPreview = nil
    end
end

function Wizard:StartTickPreview()
    self:StopTickPreview()
    local f = CreateFrame("Frame")
    self._tickPreview = f
    f.elapsed = 1.5 -- fire immediately on first update
    f:SetScript("OnUpdate", function(frame, elapsed)
        frame.elapsed = (frame.elapsed or 0) + (elapsed or 0)
        if frame.elapsed < 1.25 then
            return
        end
        frame.elapsed = 0
        local bag = Wizard.picks and Wizard.picks.ticks
        local ft = Mancer.FloatingText
        if not bag or not ft or not ft.ShowTick then
            return
        end
        local mana = math.random(18, 52)
        local health = math.random(12, 38)
        if bag.showMana then
            ft:ShowTick("+" .. mana .. " mana", (MancerDB and MancerDB.manaColor) or { 0.2, 0.55, 1 }, "mana")
        end
        if bag.showHealth then
            ft:ShowTick("+" .. health .. " health", (MancerDB and MancerDB.healthColor) or { 0.2, 0.9, 0.3 }, "health")
        end
        if bag.showRegenRate and ft.UpdateRateText then
            ft:UpdateRateText(mana)
        end
    end)
end

function Wizard:PageHasMovePreview(page)
    if not page or not EDIT_FOCUS[page.id] then
        return false
    end
    local bag = self.picks and self.picks[page.id]
    if type(bag) ~= "table" then
        return false
    end
    for i = 1, #page.options do
        local opt = page.options[i]
        -- Tooltip-only picks don't need move handles.
        if opt and opt.key ~= "tooltipEnabled" and opt.key ~= "regenOnly" and bag[opt.key] then
            return true
        end
    end
    return false
end

function Wizard:LockSectionPreview()
    self:StopTickPreview()
    if Mancer.FloatingText and Mancer.FloatingText.SetWizardFocus then
        Mancer.FloatingText:SetWizardFocus(nil)
    elseif Mancer.FloatingText and Mancer.FloatingText.SetMoveMode then
        Mancer.FloatingText:SetMoveMode(false)
    end
end

function Wizard:SyncSectionPreview()
    local page = PAGES[self.pageIndex]
    if not page then
        self:LockSectionPreview()
        return
    end

    self:StopTickPreview()

    local focus = EDIT_FOCUS[page.id]
    if not focus or not self:PageHasMovePreview(page) then
        self:LockSectionPreview()
        return
    end

    if Mancer.FloatingText and Mancer.FloatingText.SetWizardFocus then
        Mancer.FloatingText:SetWizardFocus(focus)
    end

    if page.id == "ticks" then
        self:StartTickPreview()
    end
end

-- Clean silver rim (no atlas nine-slice — corners join cleanly).
local function ApplyWizardSilverRim(frame)
    if not frame or frame.mancerWizardRim then
        return
    end
    local rim = CreateFrame("Frame", nil, frame)
    rim:SetAllPoints(frame)
    rim:SetFrameLevel((frame:GetFrameLevel() or 1) + 20)
    frame.mancerWizardRim = rim

    local WHITE = "Interface\\Buttons\\WHITE8X8"
    local outer = { 0.12, 0.13, 0.15, 1 }
    local silver = { 0.72, 0.75, 0.80, 1 }
    local highlight = { 0.90, 0.92, 0.95, 0.85 }

    local function Strip(layer, r, g, b, a, point, ...)
        local t = rim:CreateTexture(nil, layer or "OVERLAY")
        t:SetTexture(WHITE)
        t:SetVertexColor(r, g, b, a or 1)
        t:SetPoint(point, frame, point, ...)
        return t
    end

    -- Outer dark edge (2px)
    local o = 2
    local topO = Strip("OVERLAY", outer[1], outer[2], outer[3], 1, "TOPLEFT", 0, 0)
    topO:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    topO:SetHeight(o)
    local botO = Strip("OVERLAY", outer[1], outer[2], outer[3], 1, "BOTTOMLEFT", 0, 0)
    botO:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    botO:SetHeight(o)
    local leftO = Strip("OVERLAY", outer[1], outer[2], outer[3], 1, "TOPLEFT", 0, -o)
    leftO:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, o)
    leftO:SetWidth(o)
    local rightO = Strip("OVERLAY", outer[1], outer[2], outer[3], 1, "TOPRIGHT", 0, -o)
    rightO:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, o)
    rightO:SetWidth(o)

    -- Silver edge (1px inset)
    local s = 1
    local topS = Strip("OVERLAY", silver[1], silver[2], silver[3], 1, "TOPLEFT", o, -o)
    topS:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -o, -o)
    topS:SetHeight(s)
    local botS = Strip("OVERLAY", silver[1], silver[2], silver[3], 1, "BOTTOMLEFT", o, o)
    botS:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -o, o)
    botS:SetHeight(s)
    local leftS = Strip("OVERLAY", silver[1], silver[2], silver[3], 1, "TOPLEFT", o, -(o + s))
    leftS:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", o, o + s)
    leftS:SetWidth(s)
    local rightS = Strip("OVERLAY", silver[1], silver[2], silver[3], 1, "TOPRIGHT", -o, -(o + s))
    rightS:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -o, o + s)
    rightS:SetWidth(s)

    -- Soft inner highlight on top edge
    local hi = Strip("OVERLAY", highlight[1], highlight[2], highlight[3], highlight[4], "TOPLEFT", o + s, -(o + s))
    hi:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -(o + s), -(o + s))
    hi:SetHeight(1)
end

local function CreateCheckRow(parent, text, y)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(460, 22)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)

    local check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    check:SetPoint("LEFT", row, "LEFT", 0, 0)
    check:SetChecked(false)

    local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("LEFT", check, "RIGHT", 4, 0)
    label:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    label:SetJustifyH("LEFT")
    label:SetText(text or "")

    row.check = check
    row.label = label
    return row
end

local function MakeButton(parent, text, width, height)
    local ui = Mancer.UI
    if ui and ui.CreateButton then
        return ui.CreateButton(parent, text, width, height)
    end
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(width or 120, height or 24)
    btn:SetText(text or "")
    return btn
end

local function MakeRedButton(parent, text, width, height)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(width or 160, height or 28)
    btn:SetText(text or "")
    return btn
end

local GOLD = { 1.0, 0.82, 0.0, 1 }

local function StyleGold(fs)
    if fs then
        fs:SetTextColor(GOLD[1], GOLD[2], GOLD[3], GOLD[4])
    end
end

-- Explicit width is required for wrap on 3.3.5/Ascension; dual TOP anchors
-- often truncate with an ellipsis instead of wrapping to the next line.
local function EnableTextWrap(fs, width)
    if not fs then
        return
    end
    fs:SetWidth(width or 480)
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    if fs.SetWordWrap then
        fs:SetWordWrap(true)
    end
    if fs.SetNonSpaceWrap then
        fs:SetNonSpaceWrap(true)
    end
    if fs.SetMaxLines then
        pcall(function()
            fs:SetMaxLines(0)
        end)
    end
end

local function SetWrappedText(fs, text, width)
    if not fs then
        return
    end
    EnableTextWrap(fs, width)
    fs:SetText(text or "")
end

local function WizardContentWidth()
    local frame = Wizard.frame
    if frame and frame.GetWidth then
        local w = frame:GetWidth()
        if w and w > 80 then
            return w - 40
        end
    end
    return 480
end

local function SetChromeTitle(frame, text)
    if frame.wizardChromeTitle then
        frame.wizardChromeTitle:SetText(text or "")
        StyleGold(frame.wizardChromeTitle)
    end
end

function Wizard:InitPicks()
    self.picks = {}
    for i = 1, #PAGES do
        local page = PAGES[i]
        local bag = {}
        for j = 1, #page.options do
            local opt = page.options[j]
            bag[opt.key] = opt.default and true or false
        end
        self.picks[page.id] = bag
    end
end

function Wizard:SaveCurrentPagePicks()
    local page = PAGES[self.pageIndex]
    if not page or not self.optionRows then
        return
    end
    local bag = self.picks[page.id] or {}
    for i = 1, #self.optionRows do
        local row = self.optionRows[i]
        local opt = page.options[i]
        if row and opt and row.check then
            bag[opt.key] = row.check:GetChecked() and true or false
        end
    end
    self.picks[page.id] = bag
end

function Wizard:ApplyAllPicks()
    local enabledSections = {}
    for i = 1, #PAGES do
        local page = PAGES[i]
        local bag = self.picks[page.id] or {}
        local anyOn = false
        for j = 1, #page.options do
            local opt = page.options[j]
            local on = bag[opt.key] and true or false
            ApplyOption(opt, on)
            if on then
                anyOn = true
            end
        end
        if anyOn then
            enabledSections[#enabledSections + 1] = page
        end
    end
    return enabledSections
end

function Wizard:EnsureFrame()
    if self.frame then
        return self.frame
    end

    local ui = Mancer.UI
    local welcomeTitle = Loc("WIZARD_WELCOME_TITLE", "Welcome to Libellus Leti")

    local frame = CreateFrame("Frame", "MancerWelcomeWizard", UIParent)
    frame:SetSize(520, 520)
    -- Offset so character-centered HUD stays reachable for drag/scale.
    frame:SetPoint("CENTER", UIParent, "CENTER", 300, 40)
    frame:SetFrameStrata("DIALOG")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    frame:SetScript("OnHide", function()
        Wizard:LockSectionPreview()
    end)

    local bg = ui and ui.DISPLAY_BG or {}
    if ui and ui.SkinFrame then
        ui.SkinFrame(frame, {
            nativeChrome = false,
            titleBar = true,
            titleBarHeight = 28,
            artAtlas = bg.atlas,
            artPath = bg.path,
            artCoords = bg.left and { bg.left, bg.right, bg.top, bg.bottom } or nil,
            artScrub = 0.58,
            artInset = bg.artInset or 2,
            artTopInset = bg.artTopInset or 24,
        })
    end
    ApplyWizardSilverRim(frame)
    if ui and ui.CreateNativeCloseButton then
        ui.CreateNativeCloseButton(frame)
    elseif ui and ui.CreateCloseButton then
        ui.CreateCloseButton(frame)
    end

    local chromeTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    chromeTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -8)
    chromeTitle:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -36, -8)
    chromeTitle:SetJustifyH("LEFT")
    chromeTitle:SetText(welcomeTitle)
    StyleGold(chromeTitle)
    frame.wizardChromeTitle = chromeTitle

    local panel = CreateFrame("Frame", nil, frame)
    panel:SetPoint("TOPLEFT", 20, -44)
    panel:SetPoint("BOTTOMRIGHT", -20, 20)

    if UISpecialFrames then
        tinsert(UISpecialFrames, "MancerWelcomeWizard")
    end

    self.frame = frame
    self.panel = panel

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
    title:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0)
    title:SetJustifyH("LEFT")
    title:SetText(welcomeTitle)
    StyleGold(title)
    self.titleText = title

    local step = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    step:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, -2)
    step:SetJustifyH("RIGHT")
    if ui and ui.StyleMuted then
        ui.StyleMuted(step)
    end
    self.stepText = step

    local body = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
    body:SetJustifyH("LEFT")
    body:SetSpacing(3)
    EnableTextWrap(body, 480)
    if ui and ui.StyleMuted then
        ui.StyleMuted(body)
    end
    self.bodyText = body

    -- Warn
    local warnSkip = MakeRedButton(panel, Loc("WIZARD_SKIP_QUIZ", "Skip for now"), 170, 28)
    warnSkip:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 0, 0)
    warnSkip:SetScript("OnClick", function()
        Wizard:Skip()
    end)
    self.warnSkipBtn = warnSkip

    local warnContinue = MakeRedButton(panel, Loc("WIZARD_CONTINUE", "Continue setup"), 170, 28)
    warnContinue:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
    warnContinue:SetScript("OnClick", function()
        Wizard:ShowQuiz()
    end)
    self.warnContinueBtn = warnContinue

    -- Quiz / section page
    local quizHost = CreateFrame("Frame", nil, panel)
    quizHost:SetPoint("TOPLEFT", body, "BOTTOMLEFT", 0, -14)
    quizHost:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, -14)
    quizHost:SetHeight(300)
    self.quizHost = quizHost

    self.optionRows = {}
    for i = 1, 8 do
        local row = CreateCheckRow(quizHost, "", -(i - 1) * 26)
        row:Hide()
        self.optionRows[i] = row
    end

    local backBtn = MakeRedButton(panel, Loc("WIZARD_BACK", "Back"), 110, 28)
    backBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 0, 0)
    backBtn:SetScript("OnClick", function()
        Wizard:GoPrev()
    end)
    self.backBtn = backBtn

    local skipAllBtn = MakeRedButton(panel, Loc("WIZARD_SKIP_QUIZ", "Skip for now"), 130, 28)
    skipAllBtn:SetPoint("BOTTOM", panel, "BOTTOM", 0, 0)
    skipAllBtn:SetScript("OnClick", function()
        Wizard:Skip()
    end)
    self.skipAllBtn = skipAllBtn

    local nextBtn = MakeRedButton(panel, Loc("WIZARD_NEXT", "Next"), 110, 28)
    nextBtn:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
    nextBtn:SetScript("OnClick", function()
        Wizard:GoNext()
    end)
    self.nextBtn = nextBtn

    -- Summary
    local summary = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    summary:SetPoint("TOPLEFT", body, "BOTTOMLEFT", 0, -8)
    summary:SetJustifyH("LEFT")
    summary:SetSpacing(3)
    EnableTextWrap(summary, 480)
    if ui and ui.StyleMuted then
        ui.StyleMuted(summary)
    end
    self.summaryText = summary

    local openSetup = MakeButton(panel, Loc("WIZARD_OPEN_SETUP", "Open Setup"), 120, 26)
    openSetup:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 0, 0)
    openSetup:SetScript("OnClick", function()
        Wizard:Hide()
        if Mancer.Hub and Mancer.Hub.OpenDisplaySettings then
            Mancer.Hub:OpenDisplaySettings()
        elseif Mancer.Options and Mancer.Options.Open then
            Mancer.Options:Open()
        end
    end)
    self.openSetupBtn = openSetup

    local doneBtn = MakeButton(panel, Loc("WIZARD_DONE", "Done"), 100, 26)
    doneBtn:SetPoint("LEFT", openSetup, "RIGHT", 10, 0)
    doneBtn:SetScript("OnClick", function()
        Wizard:Hide()
    end)
    self.doneBtn = doneBtn

    return frame
end

function Wizard:SetMode(mode)
    self.mode = mode
    local warn = mode == "warn"
    local quiz = mode == "quiz"
    local summary = mode == "summary"

    if self.warnSkipBtn then
        if warn then
            self.warnSkipBtn:Show()
            self.warnContinueBtn:Show()
        else
            self.warnSkipBtn:Hide()
            self.warnContinueBtn:Hide()
        end
    end
    if self.quizHost then
        if quiz then
            self.quizHost:Show()
            self.backBtn:Show()
            self.nextBtn:Show()
            self.skipAllBtn:Show()
            if self.stepText then
                self.stepText:Show()
            end
        else
            self.quizHost:Hide()
            self.backBtn:Hide()
            self.nextBtn:Hide()
            self.skipAllBtn:Hide()
            if self.stepText then
                self.stepText:Hide()
            end
        end
    end
    if self.summaryText then
        if summary then
            self.summaryText:Show()
            self.openSetupBtn:Show()
            self.doneBtn:Show()
        else
            self.summaryText:Hide()
            self.openSetupBtn:Hide()
            self.doneBtn:Hide()
        end
    end
end

function Wizard:ShowSectionPage()
    local page = PAGES[self.pageIndex]
    if not page then
        return
    end
    SetChromeTitle(self.frame, Loc("WIZARD_WELCOME_TITLE", "Welcome to Libellus Leti"))
    self.titleText:SetText(Loc(page.labelKey, page.labelFallback))
    StyleGold(self.titleText)
    SetWrappedText(self.bodyText, Loc(page.blurbKey, page.blurbFallback), WizardContentWidth())
    if self.stepText then
        self.stepText:SetText(string.format(
            Loc("WIZARD_STEP", "%d / %d"),
            self.pageIndex,
            #PAGES
        ))
    end

    local bag = self.picks[page.id] or {}
    for i = 1, #self.optionRows do
        local row = self.optionRows[i]
        local opt = page.options[i]
        if opt then
            row:Show()
            row.label:SetText(Loc(opt.labelKey, opt.labelFallback))
            local checked = bag[opt.key]
            if checked == nil then
                checked = opt.default and true or false
            end
            row.check:SetChecked(checked and true or false)
            row.check.wizardOpt = opt
            row.check.wizardPageId = page.id
            row.check:SetScript("OnClick", function(btn)
                local on = btn:GetChecked() and true or false
                local pageId = btn.wizardPageId
                local option = btn.wizardOpt
                if pageId and option and Wizard.picks and Wizard.picks[pageId] then
                    Wizard.picks[pageId][option.key] = on
                end
                -- Live preview: turn the setting on/off immediately so you can see it.
                Wizard:PreviewOption(option, on)
            end)
        else
            row:Hide()
            row.check:SetScript("OnClick", nil)
            row.check.wizardOpt = nil
        end
    end

    if self.backBtn then
        if self.pageIndex <= 1 then
            self.backBtn:Disable()
        else
            self.backBtn:Enable()
        end
    end
    if self.nextBtn then
        if self.pageIndex >= #PAGES then
            self.nextBtn:SetText(Loc("WIZARD_FINISH", "Finish"))
        else
            self.nextBtn:SetText(Loc("WIZARD_NEXT", "Next"))
        end
    end

    self:SetMode("quiz")
    self.frame:Show()
    self:SyncSectionPreview()
end

function Wizard:GoPrev()
    self:SaveCurrentPagePicks()
    self:LockSectionPreview()
    if self.pageIndex > 1 then
        self.pageIndex = self.pageIndex - 1
        self:ShowSectionPage()
    end
end

function Wizard:GoNext()
    self:SaveCurrentPagePicks()
    self:LockSectionPreview()
    if self.pageIndex < #PAGES then
        self.pageIndex = self.pageIndex + 1
        self:ShowSectionPage()
        return
    end
    local enabled = self:ApplyAllPicks()
    self._snapshot = nil
    if Mancer.MarkWelcomeWizardDone then
        Mancer.MarkWelcomeWizardDone()
    end
    self:RefreshAddon()
    self:ShowSummary(enabled)
end

function Wizard:ShowWarn()
    self:EnsureFrame()
    self:LockSectionPreview()
    local welcome = Loc("WIZARD_WELCOME_TITLE", "Welcome to Libellus Leti")
    SetChromeTitle(self.frame, welcome)
    self.titleText:SetText(welcome)
    StyleGold(self.titleText)
    SetWrappedText(self.bodyText, Loc(
        "WIZARD_WARN_BODY",
        "Looks like this character already has Leti set up.\n\nYou can still walk through and pick what to turn on — just know it may change what you have now.\nOr skip and leave everything as-is."
    ), WizardContentWidth())
    self:SetMode("warn")
    self.frame:Show()
end

function Wizard:ShowQuiz()
    self:EnsureFrame()
    self:SnapshotSettings()
    self:InitPicks()
    self.pageIndex = 1
    self:ShowSectionPage()
end

function Wizard:ShowSummary(enabled)
    self:EnsureFrame()
    self:LockSectionPreview()
    SetChromeTitle(self.frame, Loc("WIZARD_WELCOME_TITLE", "Welcome to Libellus Leti"))
    self.titleText:SetText(Loc("WIZARD_SUMMARY_TITLE", "You're good to go"))
    StyleGold(self.titleText)
    local lines = {}
    if not enabled or #enabled == 0 then
        lines[#lines + 1] = Loc(
            "WIZARD_SUMMARY_NONE",
            "Nothing got turned on — that's fine. Pop into Setup when you're ready, or run /leti welcome again."
        )
    else
        lines[#lines + 1] = Loc("WIZARD_SUMMARY_INTRO", "Here's what you turned on:")
        lines[#lines + 1] = ""
        for i = 1, #enabled do
            local page = enabled[i]
            lines[#lines + 1] = "· " .. Loc(page.labelKey, page.labelFallback)
            lines[#lines + 1] = "  " .. Loc(page.blurbKey, page.blurbFallback)
            lines[#lines + 1] = ""
        end
        lines[#lines + 1] = Loc("WIZARD_SUMMARY_TIP", "Change your mind later anytime in Setup.")
    end
    SetWrappedText(self.bodyText, "", WizardContentWidth())
    SetWrappedText(self.summaryText, table.concat(lines, "\n"), WizardContentWidth())
    self:SetMode("summary")
    self.frame:Show()
end

function Wizard:Skip()
    -- Undo any live previews from ticking options during the wizard.
    self:LockSectionPreview()
    self:RestoreSnapshot()
    self._snapshot = nil
    if Mancer.MarkWelcomeWizardDone then
        Mancer.MarkWelcomeWizardDone()
    end
    self:Hide()
    if Mancer.Print then
        Mancer.Print(Loc(
            "WIZARD_SKIPPED",
            "Left your settings alone. Run /leti welcome anytime if you want another pass."
        ))
    end
end

function Wizard:Hide()
    self:LockSectionPreview()
    if self.frame then
        self.frame:Hide()
    end
end

function Wizard:Open(force)
    self:EnsureFrame()
    if force then
        if Mancer.HasCustomizedSettings and Mancer.HasCustomizedSettings() then
            self:ShowWarn()
        else
            self:ShowQuiz()
        end
        return
    end
    self:TryShow()
end

function Wizard:TryShow()
    if Mancer.IsWelcomeWizardDone and Mancer.IsWelcomeWizardDone() then
        return
    end
    if self.frame and self.frame:IsShown() then
        return
    end
    if self._shownThisSession then
        return
    end
    self._shownThisSession = true

    local waiter = self._deferFrame
    if not waiter then
        waiter = CreateFrame("Frame")
        self._deferFrame = waiter
    end
    waiter.elapsed = 0
    waiter:SetScript("OnUpdate", function(frame, elapsed)
        frame.elapsed = (frame.elapsed or 0) + (elapsed or 0)
        if frame.elapsed < 0.15 then
            return
        end
        frame:SetScript("OnUpdate", nil)
        if Mancer.IsWelcomeWizardDone and Mancer.IsWelcomeWizardDone() then
            return
        end
        if Mancer.HasCustomizedSettings and Mancer.HasCustomizedSettings() then
            Wizard:ShowWarn()
        else
            Wizard:ShowQuiz()
        end
    end)
end
