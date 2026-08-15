-- COA_DungeonRun object.lua - THE OBJECT'S OWN EDIT PANE.
--
-- Spec: addons/planning/dungeonrun_poc.md §69, §71.
--
-- ---------------------------------------------------------------------------
-- ★★ RULING: all edit options of an object live in ITS OWN pane, not the creation surface
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
-- ⚠ THE BEHAVIOUR SPACE WAS DELIBERATELY EMPTY until §78 defined the model -
-- *"Behaviour to be defined. Things like how the marker behaves... All to be
-- defined."* It stayed empty rather than being filled with a guess, and §75/§78
-- pressed the model out in discussion instead.
--
-- ★ §79 FILLS THE FIRST FIELD ONLY: the OUTCOME OF SATISFACTION. It is the whole of
-- what a checkpoint is - *"a check point is a cheap beacon"* - and everything else
-- §78 names (draw/place/print children, exits, satisfier flags) is still absent and
-- still deliberately so.
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local Object = {}
NS.Object = Object

local Map, Store, Routes
local f, title, nameBox, factLine, moveChip, delBtn, hint
local outcomeDD, outcomeBox, outcomeLabel
local stageBox, stageLabel, matchText

-- ★★ §79: THE FIRST BEHAVIOUR FIELD, and it is the ONLY thing a checkpoint is.
--
--   *"All the same mechanism. So what building the check point is, is building the
--   outcome of satisfaction to be dynamic operable."*
--
-- Two choices, because there are only two: advance, or go to a stage you type. The
-- default stores NOTHING - `outcome` stays nil - so a route full of ordinary beacons
-- carries no field at all and nothing has to be migrated.
local OUTCOME_ADVANCE, OUTCOME_STAGE = "advance", "stage"

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
        stageLabel:Hide(); stageBox:Hide(); matchText:Hide()
        outcomeLabel:Hide(); outcomeDD:Hide(); outcomeBox:Hide()
        hint:SetText("right-click a beacon or a note on the map")
        return
    end

    local label = Map.Describe(p)
    title:SetText(label)
    nameBox:Show()
    nameBox:SetText(p.name or p.text or "")
    delBtn:Enable()

    -- The facts it cannot edit. ⚠ STAGE LEFT THIS LINE IN §81 - it is a field now,
    -- not a fact, and leaving it here would have shown it twice with only one of them
    -- editable. §56 always said it was *"inherited as a default and editable"*.
    local _, _, placed = Routes.PositionOf(p)
    factLine:SetText(("%s%s  ·  z %s%s"):format(
        p.stage and "beacon" or "personal note",
        placed and "  ·  |cffffd100moved|r" or "",
        p.z and ("%.1f"):format(p.z) or "-",
        p.atWorldX and "" or (placed and "  ·  |cffff8080no world position|r" or "")))

    -- ★ CHECKED means ARMED, and it reads from the MAP so an arm cleared by
    -- unloading shows here rather than leaving a chip depressed over an object that
    -- can no longer be grabbed.
    moveChip:Show()
    moveChip:SetChecked(Map.MoveArmed() == p)

    -- ★ The outcome row belongs to BEACONS. A personal note has no stage, so it has
    -- no index to promote and the row is absent rather than disabled - §49's rule
    -- that availability follows visibility, applied to a field.
    if p.kind == "beacon" then
        -- ★ §81's stage field, and the MATCH COUNT beside it. His: *"a small Match
        -- count for that slot."* It reports how many OTHER beacons already sit on
        -- this number - it never refuses one, it just stops a collision being
        -- invisible at the moment you would create it.
        stageLabel:Show(); stageBox:Show(); matchText:Show()
        -- ★ The comparison guard that used to live here is GONE (§83). The handler
        -- ignores programmatic sets now, so writing unconditionally cannot re-enter.
        -- HasFocus still matters for a different reason: never overwrite what someone
        -- is in the middle of typing.
        if not stageBox:HasFocus() then
            stageBox:SetText(("%g"):format(p.stage or 0))
        end
        local dup = Routes.StageMatches(Map.LoadedId("route"), stageBox:GetText(), p)
        matchText:SetText(dup > 0
            and ("|cffff8080match %d|r"):format(dup)
            or "|cff808080free|r")

        local custom = Routes.OutcomeOf(p)
        outcomeLabel:Show(); outcomeDD:Show()
        UIDropDownMenu_SetText(outcomeDD, custom and "go to stage" or "advance (+1)")
        if custom then
            outcomeBox:Show()
            if not outcomeBox:HasFocus() then outcomeBox:SetText(("%g"):format(custom)) end
        else
            outcomeBox:Hide()
        end
    else
        stageLabel:Hide(); stageBox:Hide(); matchText:Hide()
        outcomeLabel:Hide(); outcomeDD:Hide(); outcomeBox:Hide()
    end

    hint:SetText(moveChip:GetChecked()
        and "drag it on the map - click to drop"
        or (p.kind == "beacon"
            and ("|cff808080satisfying this promotes the index to %g|r")
                :format(Routes.Outcome(p) or 0)
            or ""))
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
    f:SetWidth(240); f:SetHeight(238)
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

    -- ★★ §81: STAGE IS A FIELD, NOT A FACT. It was listed under "what this pane
    -- cannot edit" until §80 found that made 4.1 unreachable - the sub-division that
    -- lets insertion renumber nothing could be typed at the mint and never fixed
    -- afterwards. §56 had it right from the start: inherited as a default, EDITABLE.
    stageLabel = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    stageLabel:SetPoint("TOPLEFT", 18, -110)
    stageLabel:SetText("stage")

    stageBox = CreateFrame("EditBox", "COA_DungeonRunObjectStage", f, "InputBoxTemplate")
    stageBox:SetWidth(44); stageBox:SetHeight(20)
    stageBox:SetPoint("TOPLEFT", 70, -106)
    stageBox:SetAutoFocus(false)
    stageBox:SetMaxLetters(6)
    -- ⚠ NOT SetNumeric - 4.1 is the reason this field exists at all.
    --
    -- ★★★ GATED ON userInput, and this replaces a guard rather than adding one.
    --
    -- The client passes `userInput` as the second argument: TRUE when a human typed,
    -- FALSE for a programmatic SetText. Measured on this fork by `/coadump r api`
    -- run 5 - `arg#2=false` - and never used here until now.
    --
    -- §81 defended the refresh->SetText->refresh loop by COMPARING before writing.
    -- That comparison is gone: the flag makes the loop structurally impossible
    -- instead of defended against, because refresh's own writes announce themselves
    -- as programmatic and stop here.
    --
    -- ⚠ AND THE LOOP IT GUARDED WAS NEVER WHAT I SAID IT WAS. §81 called it unbounded
    -- and said it would FREEZE the client; run 5 measured OnTextChanged as DEFERRED,
    -- COALESCED and CHANGE-ONLY, so the worst case was ever a one-frame bounce.
    -- Knowing that is what made this refactor safe to try at all.
    stageBox:SetScript("OnTextChanged", function(_, userInput)
        if not userInput then return end
        refresh()
    end)
    stageBox:SetScript("OnEnterPressed", function(self)
        local p = subject()
        if p then
            Routes.SetStage(p, self:GetText())
            -- The running order re-sorts off the value alone, so the map and the
            -- promoter both follow with nothing to keep in step.
            Map.Repaint()
        end
        self:ClearFocus(); refresh()
    end)
    stageBox:SetScript("OnEscapePressed", function(self) self:ClearFocus(); refresh() end)

    matchText = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    matchText:SetPoint("TOPLEFT", 124, -110)

    local behaviour = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    behaviour:SetPoint("TOPLEFT", 18, -136)
    behaviour:SetText("behaviour")

    outcomeLabel = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    outcomeLabel:SetPoint("TOPLEFT", 18, -156)
    outcomeLabel:SetText("on success")

    outcomeDD = CreateFrame("Frame", "COA_DungeonRunObjectOutcome", f, "UIDropDownMenuTemplate")
    outcomeDD:SetPoint("TOPLEFT", 70, -150)
    UIDropDownMenu_SetWidth(outcomeDD, 92)
    UIDropDownMenu_JustifyText(outcomeDD, "LEFT")
    UIDropDownMenu_Initialize(outcomeDD, function()
        local p = subject()
        for _, e in ipairs({
            { key = OUTCOME_ADVANCE, text = "advance (+1)" },
            { key = OUTCOME_STAGE,   text = "go to stage" },
        }) do
            local b = UIDropDownMenu_CreateInfo()
            b.text, b.notCheckable = e.text, 1
            b.func = function()
                if not p then return end
                -- Switching TO custom seeds the box with the default, so the field
                -- opens on the number it already had rather than on nothing.
                Routes.SetOutcome(p, e.key == OUTCOME_STAGE and Routes.Outcome(p) or nil)
                refresh()
            end
            UIDropDownMenu_AddButton(b)
        end
    end)

    outcomeBox = CreateFrame("EditBox", "COA_DungeonRunObjectOutcomeN", f, "InputBoxTemplate")
    outcomeBox:SetWidth(44); outcomeBox:SetHeight(20)
    outcomeBox:SetPoint("TOPLEFT", 176, -156)
    outcomeBox:SetAutoFocus(false)
    outcomeBox:SetMaxLetters(6)
    -- ⚠ NOT numeric-only: 4.1 is an ordinary stage, and SetNumeric would refuse the
    -- decimal that makes insertion non-destructive in the first place.
    outcomeBox:SetScript("OnEnterPressed", function(self)
        local p = subject()
        if p then Routes.SetOutcome(p, self:GetText()) end
        self:ClearFocus(); refresh()
    end)
    outcomeBox:SetScript("OnEscapePressed", function(self) self:ClearFocus(); refresh() end)

    hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", 18, -180)
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
