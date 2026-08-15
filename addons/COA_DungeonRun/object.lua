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
-- ---------------------------------------------------------------------
-- ★★★ §87: ONE TEST SURFACE, ASKED RATHER THAN ANNOUNCED
-- ---------------------------------------------------------------------
--
-- Battlewrath, 2026-08-15, on the two spawners: *"neither report their failure
-- mode... I say a test as it responds to what you click, rather than over reporting.
-- And we can feed other tests into it."*
--
-- ★★ THE FAILURE MODE IT WAS BUILT FOR IS SILENT. `child here` gives the child the
-- BEACON's height, and dragging it afterwards does not change that - so a child
-- dragged onto a walkway still tests its band against the floor it was born on. It
-- renders, it sits where you put it, and it answers about the wrong storey.
--
-- ★★★ ONE SURFACE, MANY CONTRIBUTORS - a REGISTRY, never a line per control. Adding
-- a test is one registration rather than a new widget, which is what makes *"we can
-- feed other tests into it"* true rather than aspirational.
--
-- ⚠ AND IT IS ASKED, NEVER BROADCAST. Every caveat printed permanently is a caveat
-- people learn to read past - the same anti-nag manner as the note being PULLED on
-- hover. You touch a control, it tells you what that control will do.
--
-- ★★★ §87.1: IT EMITS ON THE ACT, IT DOES NOT CATCH BEFORE IT. My first cut fired
-- on HOVER, reasoning that a warning has to arrive before the button does something.
-- Battlewrath: *"Rather than catch, emit. They're clicking the button, so that can
-- emit the look-up and return to the comment box."*
--
-- ★★ WHICH IS THIS BENCH'S OWN LAW - EMIT, DON'T INTERPRET. A hover warns with a
-- PREDICTION; a click reports what actually happened, with the value it actually
-- used. One is a guess about the future written in the present tense.
--
-- ★★★ AND IT GIVES THE RULE FOR CHOOSING: WARN BEFORE ONLY WHEN THE ACT IS
-- IRREVERSIBLE; EMIT AFTER FOR EVERYTHING ELSE. Minting a child is one delete from
-- undone, so a warning buys little - and it can be missed entirely by someone who
-- never hovers, where an emission is produced BY the press and cannot be.
--
-- ★ X/Y IS DELIBERATELY NOT REPORTED. His: out of bounds is the only way to get it
-- wrong, and the map shows you that by drawing the thing off the art.
-- ---------------------------------------------------------------------
local tests = {}
NS.Tests = NS.Tests or {}

function NS.Tests.Register(key, fn) tests[key] = fn end

-- ⚠ Returns nil for an unknown key rather than erroring: a control naming a test
-- nobody registered should go quiet, not take the pane down.
-- ⚠ `result` is what the act PRODUCED, and it is what makes this an emission rather
-- than a forecast: the test can report the value the new object actually carries
-- instead of the one it was going to.
function NS.Tests.Run(key, subject, result)
    local fn = tests[key]
    if not fn then return nil end
    local ok, line = pcall(fn, subject, result)
    return ok and line or nil
end

local f, title, nameBox, factLine, moveChip, delBtn, hint
local testLine, emit
-- ★★★ §92: THE CHILD'S TICK TREE. His preference sets where the effort goes: *"the
-- single beacon use, for me, is less desirable, than setting a child and having the
-- beacon simply as the theatre."* So the CHILD's pane is the primary authoring
-- surface and the beacon's stays thin.
--
-- ★★ DROPDOWNS, NOT ROWS OF TICKS, and it is the flattening rule doing double duty:
-- a four-option choice collapses to one line, and it is the client's own idiom
-- (already used for the outcome). At 240 wide a tree of radio rows does not fit.
--
-- ★ A DETERMINED OPTION IS NOT SHOWN. Picking `radius` does not then ask you to tick
-- "one point"; the set-target box appears only for `set`, and the target picker only
-- for an action that uses one. §49 - absent rather than disabled - which is the
-- authoring-pane rule, the inverse of the HUD's.
local roleDD, roleMatch, setBox, shapeDD, radBox, upBox, downBox, unseenChip
local actionDD, targetDD, kidLabel
local hereBtn, pickBtn, kidText
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

-- ★ One place that turns a stored role into the word the author picked, so the
-- dropdown's label and its menu cannot drift apart.
local ROLE_TEXT = {
    complete = "stage complete", set = "set stage",
    start = "start of stage", update = "updater",
}

-- Only ever the map's selection. This pane holds no object of its own, so it can
-- never describe something the map is not showing - the fault §63 shipped when two
-- surfaces each remembered what they were looking at.
-- ★ The child's anchor, FOUND not stored (§83). The pane holds a child; every
-- Routes call about competition or targets needs the beacon that owns it.
local function parentOf(p)
    if not p or p.kind ~= "child" then return nil end
    return Routes.ParentOf(Map.LoadedId("route"), p)
end

local function subject()
    local p = Map.Selected and Map.Selected() or nil
    if p and (p.kind == "beacon" or p.kind == "note" or p.kind == "child") then
        return p
    end
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
        -- ⚠ §92's rows too. A pane that clears half of itself leaves the other half
        -- describing an object that is no longer selected, which reads as current.
        if kidLabel then
            kidLabel:Hide(); roleDD:Hide(); roleMatch:Hide(); setBox:Hide()
            shapeDD:Hide(); radBox:Hide(); upBox:Hide(); downBox:Hide()
            unseenChip:Hide(); actionDD:Hide(); targetDD:Hide()
            hereBtn:Hide(); pickBtn:Hide(); kidText:Hide()
        end
        hint:SetText("right-click a beacon, a child or a note on the map")
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
        (p.kind == "child" and "child") or (p.stage and "beacon") or "personal note",
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

        -- ★★ §83: TWO SPAWNERS, NOT ONE WITH AN OPTION. The bench's first design
        -- rule is REDUCE DECISION LOAD - two buttons is one act, you press the one
        -- you mean. A spawner plus a source option is two acts for the same intent,
        -- and the option is a mode you can leave set wrong.
        --
        -- ★ They live on the BEACON's pane, which is what makes a child inherit the
        -- group by construction rather than by being told. His: *"It's per beacon so
        -- it directly inherits that group identity."*
        hereBtn:Show(); pickBtn:Show(); kidText:Show()
        local kids = Routes.ChildCount(p)
        kidText:SetText(kids > 0
            and ("|cff808080%d child%s|r"):format(kids, kids == 1 and "" or "ren")
            or "|cff606060no children|r")

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
        -- ★ A child cannot spawn a child (§83: one level, deliberately) and a note
        -- spawns nothing. Absent rather than disabled - §49, availability follows
        -- visibility.
        hereBtn:Hide(); pickBtn:Hide(); kidText:Hide()
    end

    -- ---------------------------------------------------------------------
    -- ★★★ §92: THE CHILD'S TICK TREE. Every row here is ABSENT for anything that is
    -- not a child, and each sub-row is absent unless the choice above it implies it.
    -- ---------------------------------------------------------------------
    if p.kind == "child" then
        local b = parentOf(p)
        kidLabel:Show(); roleDD:Show(); roleMatch:Show()
        shapeDD:Show(); radBox:Show(); upBox:Show(); downBox:Show()
        actionDD:Show()

        UIDropDownMenu_SetText(roleDD, ROLE_TEXT[p.role] or "nothing")
        -- ★ The count REPORTS a collision and never prevents it (§90). Blank when
        -- there is nothing to say, rather than a reassuring zero.
        local dup = b and Routes.RoleMatches(b, p.role, p) or 0
        roleMatch:SetText((p.role and dup > 0)
            and ("|cffff8080%d other|r"):format(dup) or "")

        -- ⚠ The target only exists for `set`, and if-unseen only means something
        -- there too - it is what makes a set idempotent.
        if p.role == "set" then
            setBox:Show(); unseenChip:Show()
            if not setBox:HasFocus() then
                setBox:SetText(p.setStage and ("%g"):format(p.setStage) or "")
            end
            unseenChip:SetChecked(Routes.ChildIfUnseen(p))
        else
            setBox:Hide(); unseenChip:Hide()
        end

        UIDropDownMenu_SetText(shapeDD, p.shape == "wire" and "trip wire" or "radius")
        if not radBox:HasFocus() then radBox:SetText(p.radius and ("%g"):format(p.radius) or "") end
        if not upBox:HasFocus() then upBox:SetText(p.bandUp and ("%g"):format(p.bandUp) or "") end
        if not downBox:HasFocus() then downBox:SetText(p.bandDown and ("%g"):format(p.bandDown) or "") end

        UIDropDownMenu_SetText(actionDD, p.action == "supertrack"
            and "point the tracker" or "nothing")
        -- ⚠ The target picker exists only for an action that USES a target. And a
        -- BROKEN link is said plainly rather than shown as an empty box: the hop
        -- closing is a defined state (§86), not a mistake to hide.
        if p.action == "supertrack" then
            targetDD:Show()
            local tgt = b and Routes.GoToTarget(b, p)
            UIDropDownMenu_SetText(targetDD,
                tgt and ((tgt.name ~= "" and tgt.name) or "a child")
                or (p.goTo and "|cffff8080target is gone|r" or "nothing (closes)"))
        else
            targetDD:Hide()
        end
    else
        kidLabel:Hide(); roleDD:Hide(); roleMatch:Hide(); setBox:Hide()
        shapeDD:Hide(); radBox:Hide(); upBox:Hide(); downBox:Hide()
        unseenChip:Hide(); actionDD:Hide(); targetDD:Hide()
    end

    hint:SetText((Map.ArmedFor() == "pick" and "click a node on the map to place the child")
        or moveChip:GetChecked()
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
            elseif p.kind == "child" then
                -- ⚠ The parent is FOUND, never stored. §83 keeps children free of
                -- references so the flattened driver list can carry them as values,
                -- and that cost is exactly one walk - here, in the editor, on a
                -- gesture a human made.
                local id = Map.LoadedId("route")
                Routes.DeleteChild(Routes.ParentOf(id, p), p)
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
    f:SetWidth(240); f:SetHeight(330)     -- §83 children, §87 test line, §92 tick tree
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
    -- ⚠ Emitted on ARM rather than on drop: the height a drag will keep is the thing
    -- worth knowing while you still have the object in hand.
    moveChip:HookScript("OnClick", function(self)
        emit(self:GetChecked() and "move-z" or "", subject())
    end)
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
        -- ⚠ The dialog names what it is about to delete, and a child that announced
        -- itself as a beacon would be asking for consent to the wrong act.
        if p then
            StaticPopup_Show("COA_DR_OBJECT_DELETE",
                (p.kind == "note" and "note") or (p.kind == "child" and "child") or "beacon")
        end
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
    -- ★★★ RULING: gate on `userInput`, do not COMPARE before writing - the flag makes the
    --   refresh->SetText->refresh loop STRUCTURALLY IMPOSSIBLE instead of defended against,
    --   because a programmatic write announces itself and stops at the guard. ★ A guard
    --   REPLACED, never one added: two guards for one hazard is the shape that rots.
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

    -- ---------------------------------------------------------------------
    -- ★★★ §83: THE CHILDREN ROW - two spawners, and no option between them
    -- ---------------------------------------------------------------------
    --
    -- Battlewrath: *"I think a beacon would have two child spawner buttons. Or a
    -- spawner with a option."* Taken as two, on the bench's own first design rule:
    -- REDUCE DECISION LOAD. Two buttons is ONE act - you press the one you mean. A
    -- spawner plus a source option is two acts for the same intent, and the option
    -- is a mode that can sit set wrong between uses.
    --
    -- ★ Both mint through the same Routes call, so the difference between them is
    -- WHERE THE POSITION COMES FROM and nothing else.
    kidText = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    kidText:SetPoint("TOPLEFT", 18, -184)

    -- ★ FROM THE ANCHOR ITSELF. Immediate: there is nothing to ask, so nothing is
    -- asked. Create-then-edit - the child exists on the press carrying only what it
    -- inherited, and its meaning is typed afterwards on its own pane.
    hereBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    hereBtn:SetWidth(100); hereBtn:SetHeight(20)
    hereBtn:SetPoint("TOPLEFT", 18, -202)
    hereBtn:SetText("child here")
    hereBtn:SetScript("OnClick", function()
        local p = subject()
        if not p or p.kind ~= "beacon" then return end
        local c = Routes.AddChildHere(Map.LoadedId("route"), p)
        if not c then return end
        emit("child-here", p, c)
        Map.Repaint()
        -- ★ SELECT WHAT YOU JUST MADE. The pane follows the map's selection, so
        -- selecting the child IS opening its editor - one rule, not a second path.
        Map.Select(c)
        refresh()
    end)

    -- ★★ FROM A NODE YOU PICK, and the pick is ARMED rather than modal. His:
    -- *"From select node position. (Which then prompts / requires a user to click a
    -- node to select the position minting)"*
    --
    -- ⚠ It arms the MAP's one arm, so arming a pick disarms a move by construction -
    -- there is no state where both are live and no rule about which wins.
    pickBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    pickBtn:SetWidth(100); pickBtn:SetHeight(20)
    pickBtn:SetPoint("TOPLEFT", 122, -202)
    pickBtn:SetText("child at node")
    pickBtn:SetScript("OnClick", function()
        local p = subject()
        if not p or p.kind ~= "beacon" then return end
        -- The anchor is captured HERE, at the moment of arming. ⚠ Reading the
        -- selection again inside the callback would mint onto whatever the author
        -- happened to select in between, which is a different beacon and a silent
        -- wrong answer.
        Map.SetPickArmed(function(node)
            local c = Routes.AddChildFromNode(Map.LoadedId("route"), p, node)
            if c then
                emit("child-at-node", p, c)
                Map.Repaint()
                Map.Select(c)
            end
            refresh()
        end)
        refresh()
        -- ★ The ARM is an act too, and the only one here with nothing to report yet -
        -- so it says what it is waiting for rather than what it produced.
        emit("pick-armed", p)
    end)

    -- ---------------------------------------------------------------------
    -- §92: the child rows. Hidden unless a CHILD is selected.
    -- ---------------------------------------------------------------------
    kidLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    kidLabel:SetPoint("TOPLEFT", 18, -110)
    kidLabel:SetText("detect")

    roleDD = CreateFrame("Frame", "COA_DungeonRunObjectRole", f, "UIDropDownMenuTemplate")
    roleDD:SetPoint("TOPLEFT", 56, -104)
    UIDropDownMenu_SetWidth(roleDD, 96)
    UIDropDownMenu_JustifyText(roleDD, "LEFT")
    UIDropDownMenu_Initialize(roleDD, function()
        local p = subject()
        -- ★ `nothing` is a real choice, not the absence of one: a child that only
        -- carries an action and never touches the index is ordinary.
        for _, e in ipairs({
            { key = nil,         text = "nothing" },
            { key = "complete",  text = "stage complete" },
            { key = "set",       text = "set stage" },
            { key = "start",     text = "start of stage" },
            { key = "update",    text = "updater" },
        }) do
            local b = UIDropDownMenu_CreateInfo()
            b.text, b.notCheckable = e.text, 1
            b.func = function()
                if not p then return end
                Routes.SetChildRole(parentOf(p), p, e.key)
                emit("child-role", p, p)
                refresh()
            end
            UIDropDownMenu_AddButton(b)
        end
    end)

    -- ★ THE MATCH COUNT, §81's answer one level down: report the collision, never
    -- refuse it. §90 took the refusal out; this is what replaced it.
    roleMatch = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    roleMatch:SetPoint("TOPLEFT", 160, -110)

    setBox = CreateFrame("EditBox", "COA_DungeonRunObjectSetN", f, "InputBoxTemplate")
    setBox:SetWidth(40); setBox:SetHeight(20)
    setBox:SetPoint("TOPLEFT", 200, -106)
    setBox:SetAutoFocus(false); setBox:SetMaxLetters(6)
    setBox:SetScript("OnTextChanged", function(_, userInput)
        if not userInput then return end
        local p = subject()
        if p then Routes.SetChildStage(parentOf(p), p, setBox:GetText()) end
    end)

    shapeDD = CreateFrame("Frame", "COA_DungeonRunObjectShape", f, "UIDropDownMenuTemplate")
    shapeDD:SetPoint("TOPLEFT", 56, -130)
    UIDropDownMenu_SetWidth(shapeDD, 96)
    UIDropDownMenu_JustifyText(shapeDD, "LEFT")
    UIDropDownMenu_Initialize(shapeDD, function()
        local p = subject()
        for _, e in ipairs({ { key = "radius", text = "radius" },
                             { key = "wire",   text = "trip wire" } }) do
            local b = UIDropDownMenu_CreateInfo()
            b.text, b.notCheckable = e.text, 1
            b.func = function()
                if not p then return end
                Routes.SetChildShape(p, e.key)
                refresh()
            end
            UIDropDownMenu_AddButton(b)
        end
    end)

    -- ★★ THREE NUMBERS, AND THE BAND IS ASYMMETRIC (§85). `up` is the half that
    -- matters: a child on a walkway wants reach for the player standing ON it and
    -- almost none downward, or it fires for everyone underneath.
    local function numBox(name, x, get, set)
        local e = CreateFrame("EditBox", name, f, "InputBoxTemplate")
        e:SetWidth(38); e:SetHeight(20)
        e:SetPoint("TOPLEFT", x, -156)
        e:SetAutoFocus(false); e:SetMaxLetters(5)
        e:SetScript("OnTextChanged", function(_, userInput)
            if not userInput then return end
            local p = subject()
            if p then set(p, e:GetText()) end
        end)
        return e
    end
    radBox = numBox("COA_DungeonRunObjectRad", 56,
                    nil, function(p, v) Routes.SetChildReach(p, v) end)
    upBox = numBox("COA_DungeonRunObjectUp", 120,
                   nil, function(p, v) Routes.SetChildReach(p, nil, v) end)
    downBox = numBox("COA_DungeonRunObjectDown", 184,
                     nil, function(p, v) Routes.SetChildReach(p, nil, nil, v) end)

    unseenChip = CreateFrame("CheckButton", "COA_DungeonRunObjectUnseen", f,
                             "UICheckButtonTemplate")
    unseenChip:SetWidth(20); unseenChip:SetHeight(20)
    unseenChip:SetPoint("TOPLEFT", 16, -178)
    unseenChip:SetScript("OnClick", function(self)
        local p = subject()
        if p then Routes.SetChildIfUnseen(p, self:GetChecked() and true or false) end
        refresh()
    end)

    actionDD = CreateFrame("Frame", "COA_DungeonRunObjectAction", f, "UIDropDownMenuTemplate")
    actionDD:SetPoint("TOPLEFT", 56, -200)
    UIDropDownMenu_SetWidth(actionDD, 96)
    UIDropDownMenu_JustifyText(actionDD, "LEFT")
    UIDropDownMenu_Initialize(actionDD, function()
        local p = subject()
        for _, e in ipairs({ { key = nil,           text = "nothing" },
                             { key = "supertrack",  text = "point the tracker" } }) do
            local b = UIDropDownMenu_CreateInfo()
            b.text, b.notCheckable = e.text, 1
            b.func = function()
                if not p then return end
                Routes.SetChildAction(parentOf(p), p, e.key)
                refresh()
            end
            UIDropDownMenu_AddButton(b)
        end
    end)

    -- ★★★ THE TARGET IS PICKED FROM THIS BEACON'S OTHER CHILDREN, and that is the
    -- justification for the whole mechanism in his words: *"we select other children
    -- if we're selecting go there, because that's the only location we can author
    -- past the data set."* A captured node is only ever somewhere you walked.
    targetDD = CreateFrame("Frame", "COA_DungeonRunObjectTarget", f, "UIDropDownMenuTemplate")
    targetDD:SetPoint("TOPLEFT", 56, -226)
    UIDropDownMenu_SetWidth(targetDD, 96)
    UIDropDownMenu_JustifyText(targetDD, "LEFT")
    UIDropDownMenu_Initialize(targetDD, function()
        local p = subject()
        local b = parentOf(p)
        local none = UIDropDownMenu_CreateInfo()
        none.text, none.notCheckable = "nothing (closes)", 1
        none.func = function()
            if b and p then Routes.SetChildGoTo(b, p, nil) end
            refresh()
        end
        UIDropDownMenu_AddButton(none)
        for i, c in ipairs(Routes.ChildrenOf(b)) do
            -- ⚠ Itself is not offered: a cycle of one can only pin the tracker where
            -- you already are, and Routes refuses it anyway. Offering it would be a
            -- control that does nothing.
            if c ~= p then
                local e = UIDropDownMenu_CreateInfo()
                e.text = (c.name ~= "" and c.name) or ("child %d"):format(i)
                e.notCheckable = 1
                e.func = function()
                    if b and p then Routes.SetChildGoTo(b, p, c.id) end
                    emit("child-target", p, c)
                    refresh()
                end
                UIDropDownMenu_AddButton(e)
            end
        end
    end)

    -- ★ THE TEST SURFACE. One line, blank until something is asked of it.
    testLine = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    testLine:SetPoint("TOPLEFT", 18, -226)
    testLine:SetWidth(204); testLine:SetJustifyH("LEFT")

    -- ★ A control announces WHICH test it answers to; it does not know what the test
    -- says. That is what lets a test be replaced or added without touching the
    -- widget that triggers it.
    --
    -- ⚠ CLEARED BY REFRESH, NOT BY A TIMER. The line stands until the next act or
    -- the next selection replaces it - a readout that expires on a clock is one you
    -- can look up at and find gone.
    emit = function(key, subject, result)
        if testLine then testLine:SetText(NS.Tests.Run(key, subject, result) or "") end
    end

    hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", 18, -252)
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

-- ---------------------------------------------------------------------
-- ★★ THE TESTS. Each answers for ONE control and carries the VALUE, not just the
-- rule - a sentence tells you what happens, a number lets you check it against
-- where you actually mean the thing to be.
-- ---------------------------------------------------------------------

local function zText(z)
    return z and ("%.1f"):format(z) or "|cffff8080none|r"
end

-- ★★ PAST TENSE, AND THE VALUE IT ACTUALLY TOOK. "will carry" is a forecast that can
-- be wrong; "carries" is a fact about the object now sitting on the map.
NS.Tests.Register("child-here", function(p, child)
    if not child then return nil end
    return ("child carries z %s, inherited from this beacon"):format(zText(child.z))
end)

NS.Tests.Register("child-at-node", function(p, child)
    if not child then return nil end
    return ("child carries z %s, from the node you picked"):format(zText(child.z))
end)

-- §92: what a role change did, in the same past tense as the spawners.
NS.Tests.Register("child-role", function(p, child)
    if not child then return nil end
    return ("role is now %s"):format(ROLE_TEXT[child.role] or "nothing")
end)

NS.Tests.Register("child-target", function(p, target)
    if not target then return nil end
    local wx, wy = Routes.WorldOf(target)
    return ("tracker will point at %s"):format(
        wx and ("%.0f, %.0f"):format(wx, wy) or "|cffff8080no world position|r")
end)

-- The one forecast left, because arming has produced nothing yet.
NS.Tests.Register("pick-armed", function(p)
    if not p then return nil end
    return "|cff808080pick a node - the child will take that node's z|r"
end)

-- ⚠ THE SAME HOLE ONE LEVEL UP, and it has been there since §68. `Place` writes the
-- map pair and the world pair; `z` is NOT among them, so a dragged object keeps the
-- height it was born at. A beacon dragged from a corridor onto a walkway is still
-- testing against the corridor.
NS.Tests.Register("move-z", function(p)
    if not p then return nil end
    return ("dragging keeps z %s - height does not move with the drag"):format(zText(p.z))
end)

function Object.Toggle()
    if not f then return end
    if f:IsShown() then f:Hide() else f:Show(); refresh() end
end

function Object.IsShown() return f and f:IsShown() and true or false end
