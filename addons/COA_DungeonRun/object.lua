-- COA_DungeonRun object.lua - THE OBJECT'S OWN EDIT PANE.
--
-- Model: addons/planning/DRIVER_BASIS.md   READ FIRST. It names what governs NOW, in
--        precedence order, and it MOVES when a ruling moves - so this line never
--        goes stale. Lower number wins; a disagreement is reported, not resolved here.
-- Record: addons/planning/ARCHIVE__dungeonrun_poc.md §69, §71
--         how it was argued. A RECORD, never a target.
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

local f, title, nameBox, factLine, moveChip, delBtn, hint, idLine
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
-- ⚠ A2.6: `targetDD` and `rampChip` are GONE - the target picker and the on-ramp
-- chip existed only to name ANOTHER node. See routes.lua's A2.6 headstone.
local actionDD, kidLabel, answersLine
local ordLabel, ordBox, ordMatch, pathText
local senseDD, bossDD, bossTell
local noteLabel, noteBox, noteGhost
local kidRows, kidRowsMore
-- ⚠ A FIXED POOL, and the cap is TOLD rather than silent. A beacon may hold more
-- children than rows; truncating quietly would read as "that is all of them" to
-- the one person who most needs to know otherwise.
local KID_ROWS = 6
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
-- ★ The author's words for the senses, §3b: SELF-DESCRIBING, never technical.
-- ⚠ `reachHere` is the DEFAULT and is offered as a way BACK to it - picking it
-- clears rather than stores (routes.lua), so the menu reads as a choice while the
-- object stays empty. Same move as the outcome dropdown's `advance`.
-- ★★ SENSE_TEXT and ROLE_TEXT RETIRED HERE (A10.2 PRECONDITION, RI-16). They were two
-- private word tables in one file - exactly the scattered shape the adaptor exists to
-- replace, and the reason a fold that typed its own labels would have been the same
-- mistake at greater scale. Every user word now comes from `NS.Adaptor.Word`.
--
-- ⚠ `bossEngaged` / `bossKilled` did NOT move across: boss stopped being a sense
-- (RI-15) and the action word is `boss` (RI-17), whose wording lands with A10.3's row
-- model. They are gone rather than relocated.



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

-- ★★ §95: THE THREE ANSWERS, IN ONE LINE. His definition: a beacon is an on-ramp
-- (come to me), a note (give this to the player) and a ratchet (done when found) -
-- and with children it offloads each one INDEPENDENTLY, which is the stairs case.
--
-- ⚠ The nothing-ratchets line is computed HERE, from the beacon in front of the
-- author, rather than borrowed from a consumer. §112 removed `walk.lua`, and this
-- reads Routes directly - it never depended on the walk, only its comment did.
-- Reported, never refused: the beacon may be deliberately informational.
-- ★★ G2 (§299): ONE SETTER, DISPATCHED ON KIND. The three reach boxes serve a child
-- and a beacon both, and every writer of them - the OnTextChanged handlers and the
-- interface registry's `set` callbacks - goes through here. Written as an `if`
-- rather than `p.kind == "beacon" and A or B`: both sides are functions today, so
-- the idiom would work, and it would stop working silently the day one is nil.
local function setReach(p, radius, up, down)
    if not p then return nil end
    if p.kind == "beacon" then return Routes.SetBeaconReach(p, radius, up, down) end
    return Routes.SetChildReach(p, radius, up, down)
end

local function answersFor(b)
    if not b then return "" end
    -- ⚠ A2.6: the ON-RAMP third of this sentence is gone. The entry needs no flag -
    -- the stage lure, then CHILD 1 (the lure, the note), then whatever the author laid
    -- out. Position expresses the intent; there was nothing here a reader could act on
    -- that the layout does not already say.
    local acc = Routes.AcceptanceOf(b)
    local function nameOf(c)
        if not c or c == b then return nil end
        return (c.name ~= "" and c.name) or "a child"
    end
    local accTxt
    if not acc then
        accTxt = "|cffff8080nothing ratchets|r"
    elseif acc == b then
        -- ★ G2 (§299, A1.2): a childless beacon ratchets on ITSELF, and now that it can
        -- carry its own reach the honest question is "found from how far?". With a radius
        -- it is runnable on its own. Without one, "ratchets when found" was a promise the
        -- route could not keep - there was no circle to be found within.
        -- ⚠ Told, never refused (S4). The author may be mid-placement.
        -- ⚠ A1.1 (§349): `ReachOf(acc)`, not `ReachOf(b)`. ReachOf no longer resolves
        -- a beacon, so the acceptance question is asked HERE - and `acc` is already
        -- `AcceptanceOf(b)`, computed above. In this branch acc == b, so the answer is
        -- identical; it is written as `acc` because that is what the question IS.
        accTxt = Routes.ReachOf(acc) and "ratchets when found"
                 or "|cffff8080ratchets when found - but no radius|r"
    else
        accTxt = ('ratchet → "%s"'):format(nameOf(acc))
    end
    return ("|cff808080%s|r"):format(accTxt)
end

local function refresh()
    if not f then return end
    local p = subject()
    if not p then
        title:SetText("nothing to edit")
        nameBox:Hide(); factLine:SetText(""); moveChip:Hide(); delBtn:Disable()
        idLine:SetText("")
        stageLabel:Hide(); stageBox:Hide(); matchText:Hide()
        outcomeLabel:Hide(); outcomeDD:Hide(); outcomeBox:Hide()
        -- ⚠ §92's rows too. A pane that clears half of itself leaves the other half
        -- describing an object that is no longer selected, which reads as current.
        if answersLine then answersLine:Hide() end
        if kidLabel then
            kidLabel:Hide(); roleDD:Hide(); roleMatch:Hide(); setBox:Hide()
            ordLabel:Hide(); ordBox:Hide(); ordMatch:Hide(); pathText:Hide()
            -- ★ CLEARED, NOT JUST HIDDEN. A hidden box keeps its text, and
            -- `UI.Read` goes to the widget rather than to what is on screen - so a
            -- beacon's pane would report the last CHILD's note, which is this file's
            -- own §238 hazard: *"describing an object that is no longer selected,
            -- which reads as current"*. The route-note smoke caught it by going red.
            noteLabel:Hide(); noteBox:Hide(); noteGhost:Hide(); noteBox:SetText("")
            senseDD:Hide(); bossDD:Hide(); bossTell:Hide()
            shapeDD:Hide(); radBox:Hide(); upBox:Hide(); downBox:Hide()
            unseenChip:Hide(); actionDD:Hide()
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
    -- ⚠ EMPTY, not hidden, when there is no id. A personal note has none, and a slot
    -- that DISAPPEARS is a slot the eye stops trusting to be there.
    idLine:SetText(p.id and ("#%d"):format(p.id) or "")

    local _, _, placed = Routes.PositionOf(p)
    factLine:SetText(("%s%s  ·  z %s%s"):format(
        -- ⚠ The ID was inlined here for one commit (§229) and moved out in §230: this
        -- text is variable-length, so the id slid left and right with the word in front
        -- of it. A grammar needs a FIXED slot - see `idLine`.
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

        -- ★★★ A2.4's SECOND DOOR (§322). Model §1: the beacon with children is the
        -- SCENE MANAGER - it *"displays and edits the ORDINAL of its children from
        -- that same surface (reorder a chain, insert 3.1, take a satellite out of
        -- the ordinal line)"*, while each child is still edited on its own pane.
        --
        -- ★★ TWO DOORS, ONE FIELD, and the field has ONE HOME. Both surfaces call
        -- `Routes.SetChildOrdinal` - there is no second setter and no copy held
        -- here. ⚠ That makes it one field by CONSTRUCTION of there being one
        -- writer, which is weaker than §17's addressed store would make it and is
        -- what §17 exists to replace. Recorded rather than pretended about.
        local kids = Routes.ChildrenOf(p)
        for i, row in ipairs(kidRows) do
            local c = kids[i]
            if c then
                row.label:Show(); row.box:Show()
                row.label:SetText((c.name ~= "" and c.name) or ("child %d"):format(i))
                -- ⚠ never overwrite what someone is mid-way through typing
                if not row.box:HasFocus() then
                    row.box:SetText(c.ordinal and ("%g"):format(c.ordinal) or "")
                end
                row.child = c
            else
                row.label:Hide(); row.box:Hide(); row.child = nil
            end
        end
        -- ★ The overflow is SAID. Silence here would be the pane asserting a count.
        kidRowsMore:Show()
        kidRowsMore:SetText(#kids > KID_ROWS
            and ("|cffff8080%d more not shown|r"):format(#kids - KID_ROWS) or "")
        answersLine:Show(); answersLine:SetText(answersFor(p))
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
        answersLine:Hide()
        for _, row in ipairs(kidRows or {}) do
            row.label:Hide(); row.box:Hide(); row.child = nil
        end
        if kidRowsMore then kidRowsMore:Hide() end
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

        -- ★★ A2 (§312): THE CHILD'S ORDINAL - its position within THIS beacon, and
        -- nothing outside it. Blank is a real answer: no ordinal means a satellite,
        -- live whenever the beacon is current, which is what keeps enter-from-any
        -- working. So the box is empty rather than showing a 0 nobody chose.
        ordLabel:Show(); ordBox:Show(); ordMatch:Show(); pathText:Show()

        -- ★★ G1 (§346): ROUTE INSTRUCTIONS. ⚠ The label is not "note" - RI-10:
        -- *"note reads as a dev-note slot on first read"*. This is what the AUTHOR
        -- writes for the person RUNNING the route, and the word has to say so.
        noteLabel:Show(); noteBox:Show()
        local note = Routes.RouteNoteOf(Map.LoadedId("route"), b, p)
        if not noteBox:HasFocus() then noteBox:SetText(note or "") end
        -- ★ A4.3: no note is a REAL state and nothing renders for it. The ghost is
        -- shown INSTEAD of an empty box so the field says what it is for rather than
        -- sitting blank - and it hides the moment there is anything to read.
        if note or noteBox:HasFocus() then noteGhost:Hide() else noteGhost:Show() end

        -- ★★ G10 (§321): STAGE ONE of sense → when true → next. The default reads
        -- as a real choice rather than a blank, because `reach here` IS what an
        -- unset node does - its position is intrinsic and its reach is configured.
        senseDD:Show()
        UIDropDownMenu_SetText(senseDD, NS.Adaptor.Word(Routes.Sense(p)))

        -- ⚠ The picker EXISTS ONLY for a boss sense (§49: absent rather than
        -- disabled), and it is a PICKER - there is no typing path to a name.
        local sense = Routes.SenseOf(p)
        if sense == "bossEngaged" or sense == "bossKilled" then
            bossDD:Show(); bossTell:Show()
            local picked = Routes.BossOf(p)
            UIDropDownMenu_SetText(bossDD, picked or "pick a boss")
            -- ★★★ A3.3 TOLD, NEVER REFUSED. The driver's arming call takes the
            -- name as its argument, so an unnamed boss child arms nothing at all.
            -- The editor says exactly that, and stops nobody.
            bossTell:SetText(picked and ""
                or "|cffff8080no name - it will not listen|r")
        else
            bossDD:Hide(); bossTell:Hide()
        end
        if not ordBox:HasFocus() then
            ordBox:SetText(p.ordinal and ("%g"):format(p.ordinal) or "")
        end
        -- ★ REPORTS, never refuses (§90) - the same shape as the role and stage
        -- counts beside it. Two children on one ordinal gate together, which is
        -- authorable; it is only worth knowing you did it.
        local odup = b and Routes.OrdinalMatches(b, p.ordinal, p) or 0
        ordMatch:SetText((p.ordinal and odup > 0)
            and ("|cffff8080%d other|r"):format(odup) or "")
        -- The full address, read back rather than typed - C10's `4.1:3`.
        local path = b and Routes.PathOf(Map.LoadedId("route"), p) or nil
        pathText:SetText(path and ("|cff808080%s|r"):format(path)
            -- ⚠ A9.3 (§326). This said "satellite - always listening", and §3b names
            -- `satellite` EXPLICITLY in its fail list. It is our word for the SHAPE
            -- (a child outside the ordinal line); the author only needs to know what
            -- it DOES, which is listen whenever the beacon is current. Said that way
            -- it needs no term at all - which is the naming law working rather than
            -- a word being swapped for a nicer one.
            or "|cff606060no order - listens whenever this beacon does|r")

        -- ⚠ `nothing` is not a code term - it is the ABSENCE of a role, so it is the
        -- one string here the adaptor has no row for and should not.
        UIDropDownMenu_SetText(roleDD, p.role and NS.Adaptor.Word(p.role) or "nothing")
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
        -- ⚠⚠ A2.6: THE TARGET PICKER IS GONE, and the string it rendered was the
        -- defect surfacing to a person: "target is gone" IS a stale pointer, shown to
        -- an author who could do nothing about it but re-pick. `supertrack` now points
        -- at the node's OWN position - the only place it can name - so there is no
        -- second choice to offer and no broken link to report.
    else
        kidLabel:Hide(); roleDD:Hide(); roleMatch:Hide(); setBox:Hide()
        ordLabel:Hide(); ordBox:Hide(); ordMatch:Hide(); pathText:Hide()
        noteLabel:Hide(); noteBox:Hide(); noteGhost:Hide(); noteBox:SetText("")
        senseDD:Hide(); bossDD:Hide(); bossTell:Hide()
        unseenChip:Hide(); actionDD:Hide()

        -- ★★★ G2 (§299, A1): THE SAME THREE BOXES SERVE THE BEACON. A beacon that
        -- ratchets on itself is asked exactly one question - *how close is close* -
        -- and until now the pane had no way to answer it, so the author had to hang
        -- a child off the beacon purely to hold a number. Same widgets, same y, one
        -- setter dispatched on `kind`: a second trio would be a second place for the
        -- band to drift, and §85's asymmetry only survives being written once.
        --
        -- ⚠ `shape` stays CHILD-ONLY. A trip wire is a thing you author deliberately
        -- on a child; a beacon's reach is a radius, and offering the choice here
        -- would be a decision added rather than removed (the bench's first rule).
        if p.kind == "beacon" then
            shapeDD:Hide()
            radBox:Show(); upBox:Show(); downBox:Show()
            if not radBox:HasFocus() then
                radBox:SetText(p.radius and ("%g"):format(p.radius) or "")
            end
            if not upBox:HasFocus() then
                upBox:SetText(p.bandUp and ("%g"):format(p.bandUp) or "")
            end
            if not downBox:HasFocus() then
                downBox:SetText(p.bandDown and ("%g"):format(p.bandDown) or "")
            end
        else
            shapeDD:Hide(); radBox:Hide(); upBox:Hide(); downBox:Hide()
        end
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
                -- ★ BY ID (§227). It passed `p.stage` and stage is a characteristic -
                -- duplicates are permitted, so the delete could take a sibling.
                Routes.DeleteBeacon(Map.LoadedId("route"), p.id)
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
    -- ★★ 600 TALL, NOT 330 (§104). The wireframe measured what each subject actually
    -- needs - child 575, beacon 415, note 169 - against a pane held at 330. Same
    -- ruling as the promoter's width: *"make the pane bigger. It already takes over
    -- the UI. No point fighting that."* ⚠ The alternative was cutting zones to fit a
    -- number nobody had measured, which is how the magic offsets got here.
    f:SetWidth(240); f:SetHeight(600)     -- §83 children, §87 test line, §92 tick tree
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

    -- ★ A2's row sits ABOVE the detect block, with identity rather than behaviour -
    -- which is where the model puts it: an ordinal is part of the child's IDENTITY
    -- (`4.1:3`, C10), not something it does when satisfied.
    -- ★★ THE CHILD ROSTER, on the BEACON's pane. It is management ACROSS the set:
    -- one line per child, its ordinal editable in place, so reordering a chain is
    -- reading one column instead of opening each child in turn.
    kidRows = {}
    for i = 1, KID_ROWS do
        local row = {}
        row.label = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        row.label:SetPoint("TOPLEFT", 18, -276 - (i - 1) * 22)
        row.label:SetWidth(130); row.label:SetJustifyH("LEFT")
        row.box = CreateFrame("EditBox", "COA_DungeonRunObjectKidOrd" .. i, f,
                              "InputBoxTemplate")
        row.box:SetWidth(38); row.box:SetHeight(20)
        row.box:SetPoint("TOPLEFT", 160, -272 - (i - 1) * 22)
        row.box:SetAutoFocus(false); row.box:SetMaxLetters(5)
        -- ★ THE SAME SETTER THE CHILD'S OWN PANE CALLS. A row holds a reference to
        -- its child and nothing else - no ordinal of its own to fall out of step.
        row.box:SetScript("OnTextChanged", function(_, userInput)
            if not userInput or not row.child then return end
            Routes.SetChildOrdinal(subject(), row.child, row.box:GetText())
        end)
        kidRows[i] = row
    end
    kidRowsMore = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    kidRowsMore:SetPoint("TOPLEFT", 18, -276 - KID_ROWS * 22)

    -- ★★ G1: the route note. Its own row, LAST, because it is not a detection or an
    -- action - it is what the runner READS when they get here.
    --
    -- ⚠ -290, NOT -252. My first cut put the label at -252, which is `hint`'s own
    -- fixed point. A child's hint is usually the empty string, so the two would have
    -- overlapped ONLY while armed-for-pick or mid-drag - a collision that renders
    -- correctly nearly always and garbles at the two moments an author is busiest.
    -- ★ The pane is 600 tall and the child column ends at -276 (kid rows, beacon-only),
    -- so there is clear room below; nothing here needed to be traded for it.
    noteLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    noteLabel:SetPoint("TOPLEFT", 18, -290)
    noteLabel:SetText("Route instructions")

    noteBox = CreateFrame("EditBox", "COA_DungeonRunObjectNote", f, "InputBoxTemplate")
    noteBox:SetWidth(196); noteBox:SetHeight(20)
    noteBox:SetPoint("TOPLEFT", 22, -308)
    noteBox:SetAutoFocus(false)
    -- ⚠ The cap is on BOTH doors. `Routes.NOTE_MAX` guards the store because the
    -- interface registry can write without ever touching this box.
    noteBox:SetMaxLetters(Routes.NOTE_MAX)
    noteBox:SetScript("OnTextChanged", function(_, userInput)
        if not userInput then return end
        local p = subject()
        if p then
            Routes.SetRouteNote(Map.LoadedId("route"), parentOf(p), p, noteBox:GetText())
        end
    end)

    -- ★ The GHOST says what the field is for, in the author's words (RI-10). It is a
    -- SEPARATE FontString rather than placeholder text in the box - placeholder text
    -- is a string the box would then return as its value, and the setter would store
    -- the hint as a note.
    noteGhost = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    noteGhost:SetPoint("TOPLEFT", 26, -312)
    noteGhost:SetText("Instructions for the player running the route")

    ordLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ordLabel:SetPoint("TOPLEFT", 18, -86)
    ordLabel:SetText("order")

    ordBox = CreateFrame("EditBox", "COA_DungeonRunObjectOrd", f, "InputBoxTemplate")
    ordBox:SetWidth(38); ordBox:SetHeight(20)
    ordBox:SetPoint("TOPLEFT", 60, -82)
    ordBox:SetAutoFocus(false); ordBox:SetMaxLetters(5)
    ordBox:SetScript("OnTextChanged", function(_, userInput)
        if not userInput then return end
        local p = subject()
        if p then Routes.SetChildOrdinal(parentOf(p), p, ordBox:GetText()) end
    end)

    ordMatch = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ordMatch:SetPoint("TOPLEFT", 104, -86)

    pathText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    pathText:SetPoint("TOPLEFT", 150, -86)

    -- ★★ THE SENSE, at the head of the detect block - it is stage one, and the two
    -- rows under it (what happens, what next) only mean anything once it is chosen.
    senseDD = CreateFrame("Frame", "COA_DungeonRunObjectSense", f,
                          "UIDropDownMenuTemplate")
    senseDD:SetPoint("TOPLEFT", 56, -104)
    UIDropDownMenu_SetWidth(senseDD, 96)
    UIDropDownMenu_JustifyText(senseDD, "LEFT")
    UIDropDownMenu_Initialize(senseDD, function()
        local p = subject()
        -- ⚠ The default leads, because it is what most children are and the list
        -- reads as a departure from it rather than a set of equals.
        local keys = { Routes.SENSE_DEFAULT }
        for _, s in ipairs(Routes.SENSES) do keys[#keys + 1] = s end
        for _, key in ipairs(keys) do
            local e = UIDropDownMenu_CreateInfo()
            e.text, e.notCheckable = NS.Adaptor.Word(key), 1
            e.func = function()
                if not p then return end
                Routes.SetChildSense(parentOf(p), p, key)
                refresh()
            end
            UIDropDownMenu_AddButton(e)
        end
    end)

    -- ★★★ FED ONLY FROM THE RUN (A3.1). The menu is built from Store.BossNames of
    -- the LOADED run, and `SetChildBoss` is handed that same list as the offer - so
    -- a name that was never engaged cannot be stored even if something else calls it.
    -- ⚠ Empty is a real state and says so: a run with no boss engagements offers
    -- nothing, which is information, not a failure.
    bossDD = CreateFrame("Frame", "COA_DungeonRunObjectBoss", f,
                         "UIDropDownMenuTemplate")
    bossDD:SetPoint("TOPLEFT", 56, -128)
    UIDropDownMenu_SetWidth(bossDD, 128)
    UIDropDownMenu_JustifyText(bossDD, "LEFT")
    UIDropDownMenu_Initialize(bossDD, function()
        local p = subject()
        local names = Store.BossNames and Store.BossNames(Map.LoadedId("run")) or {}
        if #names == 0 then
            local e = UIDropDownMenu_CreateInfo()
            e.text, e.notCheckable, e.disabled = "no boss engaged in this run", 1, 1
            UIDropDownMenu_AddButton(e)
            return
        end
        for _, n in ipairs(names) do
            local e = UIDropDownMenu_CreateInfo()
            e.text, e.notCheckable = n, 1
            e.func = function()
                if not p then return end
                Routes.SetChildBoss(parentOf(p), p, n, names)
                refresh()
            end
            UIDropDownMenu_AddButton(e)
        end
    end)

    bossTell = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    bossTell:SetPoint("TOPLEFT", 56, -148)

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
                    nil, function(p, v) setReach(p, v) end)
    upBox = numBox("COA_DungeonRunObjectUp", 120,
                   nil, function(p, v) setReach(p, nil, v) end)
    downBox = numBox("COA_DungeonRunObjectDown", 184,
                     nil, function(p, v) setReach(p, nil, nil, v) end)

    unseenChip = CreateFrame("CheckButton", "COA_DungeonRunObjectUnseen", f,
                             "UICheckButtonTemplate")
    unseenChip:SetWidth(20); unseenChip:SetHeight(20)
    unseenChip:SetPoint("TOPLEFT", 16, -178)
    -- ⚠ §95: LABELLED. UICheckButtonTemplate makes a `$parentText` and I never set
    -- it, so both chips shipped as bare boxes - a control whose meaning lives only in
    -- the head of whoever added it.
    local ut = _G and _G["COA_DungeonRunObjectUnseenText"]
    if ut then ut:SetText("only if unseen") end
    unseenChip:SetScript("OnClick", function(self)
        local p = subject()
        if p then Routes.SetChildIfUnseen(p, self:GetChecked() and true or false) end
        refresh()
    end)

    -- ⚠⚠ A2.6: THE ON-RAMP CHIP IS GONE. §93 called it *"the only row here that is
    -- about IDENTITY rather than behaviour: which child speaks for this stage"* - and
    -- that is exactly why it went. The entry needs no flag: the stage lure, then CHILD
    -- 1 (the lure, the note), then whatever the author laid out. ★ An exclusive flag
    -- naming a different entry is a second way to say what child-1 and the layout
    -- already say - and POSITION EXPRESSES THE INTENT.

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

    -- ⚠⚠ A2.6: THE TARGET PICKER IS GONE, and its own justification names the
    -- thing that retired it: *"we select other children if we're selecting go
    -- there"*. Selecting another child IS holding another node's identity.
    -- ★ The capability survives as STEPS - one beacon, several waypoints, order
    -- by ordinal - so the author still never has to fragment one theatre into
    -- three beacons. What went is the pointer, not the expressiveness.


    -- ★★★ §95: WHAT THIS BEACON ANSWERS. §94 gave a beacon three answers and the
    -- pane showed none of them - you could not tell by looking whether it was its own
    -- on-ramp, whether anything ratcheted, or whether a child had taken the job.
    --
    -- ★ Derived every refresh, never stored: the editor's product is the picture, so
    -- a picture that can go stale is a defective product (§86).
    answersLine = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    answersLine:SetPoint("TOPLEFT", 18, -96)
    answersLine:SetWidth(204); answersLine:SetJustifyH("LEFT")


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

    -- ★★★ THE IDENTITY FOOTNOTE — A GRAMMAR, NOT A LABEL (§230).
    --
    -- *"A grammar of its own identity: the face carries a footnote. Small text, grey on
    -- black. But it's ID. Fixed location and inspectable, but not loud."*
    --
    -- ★★ THE FIXED POSITION IS WHAT BUYS THE QUIET. Prominence is one way to make a
    -- thing findable; a slot the eye has LEARNED is the other, and it costs no visual
    -- weight at all. So this is never moved, never restyled, and never competes.
    --
    -- ★ BOTTOMRIGHT rather than a computed offset: this pane changes height by subject
    -- (113 · 169 · 415 · 575), and anchoring to the bottom tracks all four for free.
    idLine = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    idLine:SetPoint("BOTTOMRIGHT", -14, 10)

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

    -- ★★★ EVERY DECLARED CONTROL, REGISTERED (§131) - and the block sits at the END
    -- of the build on purpose. §97.1 lost `promoter.create` to a registration written
    -- forty lines above the button it named; the file-order hazard is structural, so
    -- the answer is structural: ONE block, LAST, where everything above it exists.
    --
    -- ⚠ `set` only where the handler it mirrors was read. A setter that calls SetText
    -- on a box whose OnTextChanged guards on `userInput` commits NOTHING - a control
    -- that lies is worse than one that declines.
    local R = NS.UI and NS.UI.Register
    if R then
        R("object.pane", f, { kind = "frame",
            set = function(v) if v == "close" then f:Hide() else f:Show() end end,
            read = function() return f:IsShown() and true or false end })

        -- ★ The keys are OURS and short. `object.role` survives a frame being
        -- renamed, reads in a diff, and fits a 255-character line with room left.
        R("object.id", idLine, { kind = "readout",
            read = function() return idLine:GetText() end })
        R("object.fact", factLine, { kind = "readout",
            read = function() return factLine:GetText() end })
        R("object.name", nameBox, { kind = "edit",
            set = function(v) nameBox:SetText(v); commitName() end,
            read = function() return nameBox:GetText() end })
        R("object.move", moveChip, { kind = "check",
            read = function() return moveChip:GetChecked() and true or false end })
        R("object.delete", delBtn)
        R("object.here", hereBtn)
        R("object.pick", pickBtn)
        -- ⚠ SET WITHOUT A COMMIT. This mirrors what was here before and is carried
        -- FORWARD KNOWINGLY: SetText fires OnTextChanged with userInput false, so
        -- the stage lands in the box and not in the route. ☐ raised on the surface.
        R("object.stage", stageBox, { kind = "edit",
            set = function(v) stageBox:SetText(v) end,
            read = function() return stageBox:GetText() end })
        R("object.stagematch", matchText, { kind = "readout",
            read = function() return matchText:GetText() end })
        R("object.unseen", unseenChip, { kind = "check",
            read = function() return unseenChip:GetChecked() and true or false end })
        R("object.answers", answersLine, { kind = "readout",
            read = function() return answersLine:GetText() end })
        R("object.kids", kidText, { kind = "readout",
            read = function() return kidText:GetText() end })
        R("object.match", roleMatch, { kind = "readout",
            read = function() return roleMatch:GetText() end })

        -- ★★ THE BAND IS THREE BOXES, NOT ONE (§85), and the inventory declared one.
        -- Found by registering rather than by reading: `up` and `down` had no key at
        -- all, so nothing could reach the asymmetric half that does the real work.
        -- ⚠ These setters MIRROR the OnTextChanged handler exactly - SetText alone
        -- would not commit, so each writes the box AND makes the Routes call.
        -- ★ A2 (§312). Registered because every other edit box is, and because the
        -- registry is how a test reaches a control - an unregistered box is one no
        -- smoke can drive, which is how `up` and `down` came to have no key at all.
        -- ★ G10 (§321). A dropdown is addressable exactly like a button - `set` goes
        -- straight to the Routes call the menu entry would have made.
        -- ★★ A2.4 (§322): THE ROSTER IS REGISTERED, all six. An unregistered control
        -- is one no smoke can drive - which is exactly how `up` and `down` came to
        -- have no key at all and the asymmetric half of the band went untested.
        -- ⚠ The `set` MIRRORS the OnTextChanged handler and calls the SAME setter the
        -- child's own pane calls. Two doors, one field, one writer.
        for i, row in ipairs(kidRows) do
            R(("object.kid.ordinal.%d"):format(i), row.box, { kind = "edit",
                set = function(v)
                    row.box:SetText(v)
                    if row.child then
                        Routes.SetChildOrdinal(subject(), row.child, v)
                    end
                    refresh()
                end,
                read = function() return row.box:GetText() end })
        end
        R("object.kid.more", kidRowsMore, { kind = "readout",
            read = function() return kidRowsMore:GetText() end })

        -- ★ G1. The `set` MIRRORS the OnTextChanged handler and goes through the
        -- same setter - which is also why `Routes.NOTE_MAX` guards the store: this
        -- door does not pass the box's SetMaxLetters.
        R("object.note", noteBox, { kind = "edit",
            set = function(v)
                local p = subject()
                noteBox:SetText(v)
                if p then
                    Routes.SetRouteNote(Map.LoadedId("route"), parentOf(p), p, v)
                end
                refresh()
            end,
            read = function() return noteBox:GetText() end })
        R("object.note.ghost", noteGhost, { kind = "readout",
            read = function() return noteGhost:IsShown() and noteGhost:GetText() or "" end })

        R("object.sense", senseDD, { kind = "dropdown",
            set = function(v)
                local p = subject()
                if p then Routes.SetChildSense(parentOf(p), p, v) end
                refresh()
            end,
            read = function() return Routes.SenseOf(subject()) end })
        -- ⚠ The boss picker's `set` passes the OFFER as well as the value, so the
        -- registry path carries the same guard the menu does. A test surface that
        -- could write a name the run never engaged would be a hole in A3.1 dressed
        -- as a convenience.
        R("object.boss", bossDD, { kind = "dropdown",
            set = function(v)
                local p = subject()
                local names = Store.BossNames and Store.BossNames(Map.LoadedId("run")) or {}
                if p then Routes.SetChildBoss(parentOf(p), p, v, names) end
                refresh()
            end,
            read = function() return Routes.BossOf(subject()) end })
        R("object.boss.tell", bossTell, { kind = "readout",
            read = function() return bossTell:GetText() end })

        R("object.ordinal", ordBox, { kind = "edit",
            set = function(v)
                local p = subject()
                ordBox:SetText(v)
                if p then Routes.SetChildOrdinal(parentOf(p), p, v) end
                refresh()
            end,
            read = function() return ordBox:GetText() end })
        R("object.ordinal.match", ordMatch, { kind = "readout",
            read = function() return ordMatch:GetText() end })
        R("object.path", pathText, { kind = "readout",
            read = function() return pathText:GetText() end })

        R("object.reach", radBox, { kind = "edit",
            set = function(v)
                local p = subject()
                radBox:SetText(v)
                if p then setReach(p, v) end
                refresh()
            end,
            read = function() return radBox:GetText() end })
        R("object.reach.up", upBox, { kind = "edit",
            set = function(v)
                local p = subject()
                upBox:SetText(v)
                if p then setReach(p, nil, v) end
                refresh()
            end,
            read = function() return upBox:GetText() end })
        R("object.reach.down", downBox, { kind = "edit",
            set = function(v)
                local p = subject()
                downBox:SetText(v)
                if p then setReach(p, nil, nil, v) end
                refresh()
            end,
            read = function() return downBox:GetText() end })

        -- ★★ A DROPDOWN IS ADDRESSABLE THE SAME WAY A BUTTON IS, which is the whole
        -- reason this is a registry and not `/click`: `set` goes straight to the
        -- Routes call the menu entry would have made.
        R("object.role", roleDD, { kind = "dropdown",
            set = function(v)
                local p = subject()
                if p then Routes.SetChildRole(parentOf(p), p, v ~= "" and v or nil) end
                refresh()
            end,
            read = function() local p = subject() return p and p.role end })
        R("object.action", actionDD, { kind = "dropdown",
            set = function(v)
                local p = subject()
                if p then Routes.SetChildAction(parentOf(p), p, v ~= "" and v or nil) end
                refresh()
            end,
            read = function() local p = subject() return p and p.action end })
        R("object.shape", shapeDD, { kind = "dropdown",
            set = function(v)
                local p = subject()
                if p then Routes.SetChildShape(p, v ~= "" and v or nil) end
                refresh()
            end,
            read = function() local p = subject() return p and p.shape end })
        R("object.outcome", outcomeDD, { kind = "dropdown",
            set = function(v)
                local p = subject()
                if p then
                    Routes.SetOutcome(p, v == OUTCOME_STAGE and Routes.Outcome(p) or nil)
                end
                refresh()
            end,
            read = function() local p = subject() return p and Routes.Outcome(p) end })

        -- ★★ THREE THAT WERE IN THE CODE AND IN NO ROW (§131) - `setBox`, `outcomeBox`
        -- and the two footer lines. The ☐ on the surface said "justify or cut"; they
        -- are justified, so they are named. ⚠ A control with no key is not a small
        -- omission: it is invisible to the walk, unreachable by a typed line, and
        -- absent from the count that is supposed to tell us the pane is whole.
        R("object.childstage", setBox, { kind = "edit",
            set = function(v)
                local p = subject()
                setBox:SetText(v)
                if p then Routes.SetChildStage(parentOf(p), p, setBox:GetText()) end
                refresh()
            end,
            read = function() return setBox:GetText() end })
        R("object.outcome.n", outcomeBox, { kind = "edit",
            set = function(v)
                local p = subject()
                outcomeBox:SetText(v)
                if p then Routes.SetOutcome(p, outcomeBox:GetText()) end
                refresh()
            end,
            read = function() return outcomeBox:GetText() end })
        R("object.test", testLine, { kind = "readout",
            read = function() return testLine:GetText() end })
        R("object.hint", hint, { kind = "readout",
            read = function() return hint:GetText() end })
        R("object.close", closeBtn)
        -- ★★ §134: THE PANE TITLE, and here it is not decoration - it names the
        -- SUBJECT ("child - in a beacon"), so it is the one line that says what the
        -- rest of the pane is describing.
        R("object.title", title, { kind = "readout",
            read = function() return title:GetText() end })
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
    return ("role is now %s"):format(child.role and NS.Adaptor.Word(child.role)
                                     or "nothing")
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
