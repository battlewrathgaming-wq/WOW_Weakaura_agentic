-- COA_DungeonRun widget.lua - the capture widget. Deliberately small.
--
-- Model: addons/planning/DRIVER_BASIS.md   READ FIRST. It names what governs NOW, in
--        precedence order, and it MOVES when a ruling moves - so this line never
--        goes stale. Lower number wins; a disagreement is reported, not resolved here.
-- Battlewrath: "we need a widget that is all about capture." Three things and
-- nothing else: name the run, arm it, watch the count move so you can see it is
-- working. Everything about READING a run happens offline, against the records.
--
-- ---------------------------------------------------------------------------
-- CARRIED LESSON (COA_Landmarks, cost a live bug to find):
-- InputBoxTemplate's $parentMiddle texture anchors relativeTo="$parentLeft" and
-- "$parentRight" BY NAME. A nameless EditBox therefore loses its middle section
-- and renders as two floating end-caps. THE EDIT BOX MUST BE NAMED.
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local Widget = {}
NS.Widget = Widget

local Store, Capture
local f, nameBox, armBtn, countText, pinBtn

local function refresh()
    if not f then return end
    local id = Capture.RunId()
    if id then
        local pulls, legs, pins = Store.Counts(id)
        -- Pins only appear once there is one. A permanent "0 pin(s)" is clutter on
        -- a surface whose whole job is to be small.
        countText:SetText(("recording  |  %d pull%s  |  %d leg%s%s")
            :format(pulls, pulls == 1 and "" or "s", legs, legs == 1 and "" or "s",
                    pins > 0 and ("  |  %d pin%s"):format(pins, pins == 1 and "" or "s") or ""))
        armBtn:SetText("Stop")
        nameBox:EnableMouse(false)
        nameBox:ClearFocus()
        -- ★ DISABLED, NOT HIDDEN, when unarmed. Disabled says "this exists and
        -- needs a run"; hidden says nothing at all.
        pinBtn:Enable()
    else
        countText:SetText("not recording")
        armBtn:SetText("Arm")
        nameBox:EnableMouse(true)
        pinBtn:Disable()
    end
end
Widget.Refresh = refresh

local function toggleArm()
    if Capture.RunId() then
        local id = Capture.Stop()
        NS.Say(("stopped |cffffd100%s|r"):format(tostring(id)))
    else
        local id, err = Capture.Arm(nameBox:GetText())
        if id then
            NS.Say(("recording |cffffd100%s|r"):format(id))
        else
            NS.Say("could not start: " .. tostring(err))
        end
    end
    refresh()
end

function Widget.Init()
    Store, Capture = NS.Store, NS.Capture

    f = CreateFrame("Frame", "COA_DungeonRunFrame", UIParent)
    f:SetWidth(240); f:SetHeight(124)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
    f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })

    -- The drag pair is balanced: OnDragStart installs nothing persistent, and
    -- StopMovingOrSizing ends it. An unthrottled drag handler is CORRECT - a
    -- throttled one stutters (the addon census flags it; the README calibrates
    -- why that flag is fine).
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, _, x, y = self:GetPoint()
        Store.SetUI("pos", { p = p, x = x, y = y })
    end)

    -- §145: -8, dragged. The board put the title on the pane's own top margin
    -- rather than floating it a row down.
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 16, -8)
    title:SetText("Dungeon run")

    -- ★★ DR-36: THE PIN, above the name controls and full width.
    --
    -- It sits at the TOP because during a run the name box is disabled and this is
    -- the only live control on the surface - and it is wide because the whole point
    -- is that it has to be cheap IN PLAY. A pin dropped in the moment carries the
    -- right position, floor and second; asking afterwards is reconstruction, which
    -- is the thing this addon exists to avoid.
    --
    -- No dialog on purpose. The meaning waits for promotion, so there is nothing to
    -- ask at the time (Battlewrath: "it's capture. Then later promote gives it
    -- meaning."). The button is how you FIND it; /dr pin is how you use it mid-pull.
    -- ★★★ §145: 16 → 224, AND SO IS EVERYTHING ELSE IN THIS PANE. His note on the
    -- board: *"Size wise, this makes it clear name and pin are not sharing verticle
    -- lines."* They were not - pin ran 20→220 and the name box 22→212, so no two edges
    -- agreed and neither agreed with the title at 16. One 16px margin now, on both
    -- sides, for every full-width control.
    pinBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    pinBtn:SetWidth(208); pinBtn:SetHeight(22)
    pinBtn:SetPoint("TOPLEFT", 16, -34)
    pinBtn:SetText("Pin here")
    pinBtn:SetScript("OnClick", function() Widget.Pin() end)

    -- NAMED - see the carried lesson at the top of this file.
    nameBox = CreateFrame("EditBox", "COA_DungeonRunNameBox", f, "InputBoxTemplate")
    nameBox:SetWidth(208); nameBox:SetHeight(20)
    nameBox:SetPoint("TOPLEFT", 16, -58)
    -- ⚠ THE FRAME IS ON 16; THE SUNKEN FIELD MAY NOT BE. `InputBoxTemplate` insets its
    -- visible box inside the frame, which is the same field-vs-art split as the
    -- dropdown one control over (§103). The probe has never measured that inset, so if
    -- this reads a few pixels off the button above it, that is why - and it is one
    -- capture to settle rather than a number to nudge.
    nameBox:SetAutoFocus(false)
    nameBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    nameBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

    -- ★ ANCHORED BY ITS TOP, not its bottom (§145). He aligned this line's TOP with
    -- the button row at 88; a FontString's height comes from its text, so a BOTTOMLEFT
    -- anchor would make that alignment drift the moment the string changes.
    countText = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    countText:SetPoint("TOPLEFT", 16, -88)

    armBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    armBtn:SetWidth(64); armBtn:SetHeight(22)
    -- -16, so this button's right edge lands on the same 224 as pin and the name box.
    armBtn:SetPoint("BOTTOMRIGHT", -16, 14)
    armBtn:SetScript("OnClick", toggleArm)

    -- §20.1: the widget is the ANCHOR for the display, not a second surface.
    --
    -- ⚠⚠ IT USED TO BE -72 AND IT OVERLAPPED (§144). At -72 this button's right edge
    -- landed at 240-72 = 168 while `armBtn` started at 162 - a SIX PIXEL OVERLAP,
    -- shipped and live. Battlewrath confirmed it in game once the board drew it:
    -- *"Red on red was less obvious, but I see it now."* Two identical 3-slice buttons
    -- do not look overlapped, they look like one button with a missing end cap.
    --
    -- ★★★ AND THIS IS WHY THE PICTURE EXISTS. The overlap was in the arithmetic the
    -- whole time; nobody read it, because reading it meant holding two SetPoint calls
    -- and a width in your head at once. Drawn at real size, it is just visible.
    --
    -- ⚠ -82 AND 50 WIDE ARE HIS, FROM THE BOARD - not the -84 I derived from
    -- Layout.GAP. Right edge 158 against arm's 160 is a TWO pixel gap, and the
    -- normaliser left it alone deliberately: 2 is four off the house 6, outside the
    -- tolerance, so it reads as a decision rather than a tremor. If it was a drag in
    -- progress, -86 with width 50 is the 6px version.
    -- ★ A10.1d's DOOR. Beside the map's, because the two open the halves of one
    -- frame and an author should not have to learn where the other half lives.
    local optBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    optBtn:SetWidth(58); optBtn:SetHeight(22)
    optBtn:SetPoint("BOTTOMRIGHT", -136, 14)
    optBtn:SetText("Options")
    optBtn:SetScript("OnClick", function() NS.Options.Toggle() end)

    local mapBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    mapBtn:SetWidth(50); mapBtn:SetHeight(22)
    mapBtn:SetPoint("BOTTOMRIGHT", -82, 14)
    mapBtn:SetText("Map")
    mapBtn:SetScript("OnClick", function() NS.Map.Toggle() end)

    local ui = Store.GetUI()
    if ui.pos then
        f:ClearAllPoints()
        f:SetPoint(ui.pos.p, UIParent, ui.pos.p, ui.pos.x, ui.pos.y)
    end
    if ui.shown == false then f:Hide() end


    -- ★★★ THE PANE ITSELF IS A CONTROL (§128). Registering it does two things: a test
    -- line can open and close the surface it is testing, and `task_geom` can find this
    -- pane to WALK it - the walker locates panes by their `*.pane` key and then
    -- enumerates every child, registered or not.
    -- ⚠ Registered here, after the frame exists. §97.1's miss was a registration block
    -- sitting above the widget it named.
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
        R("remote.pane", f, { kind = "frame",
            set = function(v) if v == "close" then f:Hide() else f:Show() end end,
            read = function() return f:IsShown() and true or false end })
        R("remote.title", title, { kind = "readout",
            read = function() return title:GetText() end })
        R("remote.pin", pinBtn)
        -- ⚠ READ ONLY. SetText on this box fires OnTextChanged with userInput false,
        -- and Capture.Arm reads GetText at the moment of arming - so a `set` would
        -- appear to work and arm the previous name. The name is typed, not driven.
        R("remote.name", nameBox, { kind = "edit",
            read = function() return nameBox:GetText() end })
        R("remote.count", countText, { kind = "readout",
            read = function() return countText:GetText() end })
        R("remote.arm", armBtn)
        R("remote.map", mapBtn)
        R("remote.options", optBtn)
    end

    refresh()
    return f
end

-- One entry point for both the button and /dr pin, so the two cannot drift.
function Widget.Pin()
    local pt, err = Capture.Pin()
    NS.Say(pt and "|cffffd100pinned|r - meaning comes later, in curation."
              or ("could not pin: " .. tostring(err)))
    refresh()
    return pt
end

function Widget.Toggle()
    if not f then return end
    if f:IsShown() then f:Hide() else f:Show(); refresh() end
    Store.SetUI("shown", f:IsShown() and true or false)
end
