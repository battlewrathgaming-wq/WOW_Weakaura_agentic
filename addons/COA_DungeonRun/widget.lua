-- COA_DungeonRun widget.lua - the capture widget. Deliberately small.
--
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

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 16, -14)
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
    pinBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    pinBtn:SetWidth(200); pinBtn:SetHeight(22)
    pinBtn:SetPoint("TOPLEFT", 20, -34)
    pinBtn:SetText("Pin here")
    pinBtn:SetScript("OnClick", function() Widget.Pin() end)

    -- NAMED - see the carried lesson at the top of this file.
    nameBox = CreateFrame("EditBox", "COA_DungeonRunNameBox", f, "InputBoxTemplate")
    nameBox:SetWidth(190); nameBox:SetHeight(20)
    nameBox:SetPoint("TOPLEFT", 22, -62)
    nameBox:SetAutoFocus(false)
    nameBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    nameBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

    countText = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    countText:SetPoint("BOTTOMLEFT", 18, 18)

    armBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    armBtn:SetWidth(64); armBtn:SetHeight(22)
    armBtn:SetPoint("BOTTOMRIGHT", -14, 14)
    armBtn:SetScript("OnClick", toggleArm)

    -- §20.1: the widget is the ANCHOR for the display, not a second surface.
    --
    -- ⚠⚠ -84, NOT -72 (§144). At -72 this button's right edge landed at 240-72 = 168
    -- and `armBtn` starts at 240-14-64 = 162 - a SIX PIXEL OVERLAP, shipped and live.
    -- Battlewrath confirmed it in game once the board drew it: *"Red on red was less
    -- obvious, but I see it now."*
    --
    -- ★ THE NEW NUMBER IS DERIVED, NOT CHOSEN. 162 - Layout.GAP(6) = 156 is this
    -- button's right edge, so the anchor is -(240 - 156) = -84 and the pair now
    -- carries the same gap as every other adjacent pair in the addon.
    --
    -- ★★★ AND THIS IS WHY THE PICTURE EXISTS. The overlap was in the arithmetic all
    -- along; nobody read it, because reading it meant holding two SetPoint calls and a
    -- width in your head at once. Drawn at real size, it is just visible.
    local mapBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    mapBtn:SetWidth(52); mapBtn:SetHeight(22)
    mapBtn:SetPoint("BOTTOMRIGHT", -84, 14)
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
