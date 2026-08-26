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
local f

-- ★★★ THE REMOTE IS TWO MODES OF ONE WIDGET (AL-49 · AL-50), never two panes sharing a
-- frame. His split, 2026-08-25: both modes are the same *when* - **I am playing the game**.
-- Curation, which is the STORED run data, is the other surface and is not here.
-- ⚠ AL-50: FIXED tabs, no undock, no return band - a NAMED exception to AL-13's dock/undock
-- grammar, which is SCOPED to the unified pane's groups.
--
-- ★★ AND THE DIVISION OF LABOUR IS HIS, 2026-08-25: *"We define the frame. And where the
-- content is within Ace's form, it controls the content."* ⟶ `f` is ours - a movable,
-- backdropped window, which is the client's job. **Everything inside it is AceGUI's**:
-- the strip, the container, and every control. `pane-build` law 4.
local STRIP_H = 37          -- MEASURED: check_sheet --tabs, specimen `remote`, ONE row at 240
local strip                 -- the AceGUI TabGroup - the strip IS the title (his, 2026-08-25)
local host                  -- ONE AceGUI container; both modes build into it
local mode                  -- the live mode key
local builders, order = {}, {}
local W = {}                -- the LIVE mode's widgets, rebuilt on every entry

-- ⚠ RESOLVED ON EACH CALL, never captured at load. `widget.lua` loads before the Libs are
-- guaranteed present, and a nil taken at load time is a pane that never builds and never
-- says why.
local function gui() return LibStub and LibStub("AceGUI-3.0", true) end

-- ⚠ GUARDED ON THE LIVE WIDGETS, not on `f`. The mode's content is RELEASED on every
-- switch (law 2), so a refresh arriving while the capture mode is not on screen has nothing
-- to write to - and reaching for a released widget is the stale-state fault the law exists
-- to prevent, arriving through the back door.
local function refresh()
    if not f or mode ~= "run" or not W.count then return end
    local id = Capture.RunId()
    if id then
        local pulls, legs, pins = Store.Counts(id)
        -- Pins only appear once there is one. A permanent "0 pin(s)" is clutter on
        -- a surface whose whole job is to be small.
        W.count:SetText(("recording  |  %d pull%s  |  %d leg%s%s")
            :format(pulls, pulls == 1 and "" or "s", legs, legs == 1 and "" or "s",
                    pins > 0 and ("  |  %d pin%s"):format(pins, pins == 1 and "" or "s") or ""))
        W.arm:SetText("Stop")
        W.name:SetDisabled(true)
        -- ★ DISABLED, NOT HIDDEN, when unarmed. Disabled says "this exists and
        -- needs a run"; hidden says nothing at all.
        W.pin:SetDisabled(false)
    else
        W.count:SetText("not recording")
        W.arm:SetText("Arm")
        W.name:SetDisabled(false)
        W.pin:SetDisabled(true)
    end
end
Widget.Refresh = refresh

local function toggleArm()
    if Capture.RunId() then
        local id = Capture.Stop()
        NS.Say(("stopped |cffffd100%s|r"):format(tostring(id)))
    else
        local id, err = Capture.Arm(W.name and W.name:GetText() or "")
        if id then
            NS.Say(("recording |cffffd100%s|r"):format(id))
        else
            NS.Say("could not start: " .. tostring(err))
        end
    end
    refresh()
end

-- ★★★ A MODE IS REGISTERED, NOT HARD-CODED. `drive.lua` owns the test-drive content and
-- mounts it here; the remote holds the shell and knows nothing about what either mode
-- contains. Same one-way seam the map uses for its listeners.
-- ⚠ THE STRIP IS BUILT FROM WHAT IS MOUNTED, so a mode that has not folded yet has no tab
-- rather than a DEAD one - and the old door keeps working until it does (A10.2d,
-- *"both, not or; nothing is torn down to start"*).
-- ⚠ `build` IS CALLED AS `build(host, W)`. The second argument is the live mode's widget
-- table, and filling it is how a control becomes reachable to `Widget.W` and to any guard
-- that reads the surface. A builder that keeps its own table builds a working mode nothing
-- can see.
function Widget.Mount(key, text, build)
    if type(key) ~= "string" or type(build) ~= "function" then return nil end
    if not builders[key] then order[#order + 1] = key end
    builders[key] = { text = text or key, build = build }
    Widget.Restrip()

    -- ⚠⚠ A MODE CAN MOUNT AFTER THE REMOTE HAS ALREADY OPENED, and the remembered one is
    -- exactly the case. `core.lua` runs `Widget.Init` before `Drive.Init`, so an author who
    -- left the remote on `drive` last session comes back to a `Widget.Mode("drive")` that
    -- returns nil - the builder does not exist yet - and the remote opens on `run` having
    -- silently dropped the preference.
    -- ⟶ THE MOUNT IS THE MOMENT IT BECOMES POSSIBLE, so it is where the preference is
    -- honoured. Not at Init, which cannot know what has yet to load.
    if mode ~= key and Store and Store.GetUI and Store.GetUI().remoteMode == key then
        Widget.Mode(key)
        Widget.Restrip()
    end
    return key
end

function Widget.Restrip()
    if not strip then return end
    local tabs = {}
    for i, k in ipairs(order) do tabs[i] = { text = builders[k].text, value = k } end
    strip:SetTabs(tabs)
    if mode and builders[mode] then strip:SelectTab(mode) end
end

-- ★★★ THE SWITCH IS A TEARDOWN, NOT A TOGGLE (`pane-build` law 2).
--
-- ⚠⚠ THE REASON IS LAW 8 AND THEY ARE ONE FACT (his, 2026-08-25): *"A pane that has an
-- always built in scroll bar must preserve that space and hide it. A display on that pane
-- only holds the scroll bar defined space whilst that is rendered content."* ⟶ The space a
-- pane reserves belongs to the content CURRENTLY RENDERED, so a swap is the moment it is
-- re-decided. Two prebuilt trees toggled by Show/Hide would carry law 8's number with no
-- moment at which to re-read it.
-- ★ The remote has no scroll region today, which is exactly why it is built the right way
-- NOW: the wrong shape is invisible until the first mode outgrows 165.
function Widget.Mode(key)
    if not key or not builders[key] or not host then return nil end
    -- ⚠ THE STRIP CALLS BACK INTO HERE. `TabGroup:SelectTab` FIRES `OnGroupSelected`
    -- synchronously, so `Restrip` re-entering with the key we are already on would tear down
    -- live content to rebuild the same thing. ⟶ Already-live is a no-op, not a rebuild.
    if key == mode and next(W) ~= nil then return key end
    host:ReleaseChildren()
    -- ⚠ THE REFS GO WITH THE WIDGETS. `W` names the LIVE mode's controls; leaving last
    -- mode's entries in it is exactly the stale state the release just removed.
    W = {}
    Widget.W = W
    mode = key
    -- ★★ THE TABLE IS HANDED OVER, never reached for. A mode mounted from another file
    -- (drive.lua) would otherwise fill ITS file's `W` and leave the remote's empty - which
    -- renders correctly and reports nothing, so only a harness ever sees it.
    builders[key].build(host, W)
    host:DoLayout()
    if Store and Store.SetUI then Store.SetUI("remoteMode", key) end
    return key
end

function Widget.CurrentMode() return mode end

function Widget.Init()
    Store, Capture = NS.Store, NS.Capture

    -- ★★ 240 × 197, AND THE HEIGHT IS THE SUM OF WHAT IS IN IT. 8 top pad + 37 strip
    -- (MEASURED, `check_sheet --tabs`, ONE row at 240) + 4 + 140 page + 8 bottom.
    --
    -- ★★★ THE PAGE IS SIZED TO THE TALLER MODE AND THE FRAME DOES NOT RESIZE PER TAB.
    -- `DR_Pane_2` says it in its own ✓ line: *the pane keeps its identity, its position
    -- and its SIZE across a swap.* ⟶ A remote that grew and shrank as you picked tabs
    -- would move every control under the cursor for a reason nobody chose - which is the
    -- SPACE changing rather than the SUBJECT (his test, 2026-08-25). 165 held the run mode
    -- alone; the test drive needs 140 of page, so 140 is the page.
    -- ⚠ THE DECLARATION IS THE CHECKABLE COPY (`DR_Pane_3`): these numbers are the ones
    -- `check_layout` passes green, and the machine is allowed to contradict them. It did:
    -- a first cut declared the strip as n=2 boxes of 240 and was told it had put 480 of
    -- strip in a 240 sheet. The fix was not 120 each - equal halves would be a number we
    -- INVENTED for boxes AceGUI measures from their text.
    f = CreateFrame("Frame", "COA_DungeonRunFrame", UIParent)
    f:SetWidth(240); f:SetHeight(197)
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

    -- ★★★ THE STRIP IS THE TITLE (Battlewrath, 2026-08-25: *"The strip is self
    -- descriptive."*). §145's *"Dungeon run"* heading is RETIRED - two tabs reading `Run`
    -- and `Test drive` say what the widget is AND what it is doing; a heading above them
    -- would be a third line saying less.
    --
    -- ⚠⚠ ACEGUI'S OWN TabGroup, not a hand-rolled row of buttons. AL-50 rules the remote's
    -- strip is the *"same texture grammar"* as the unified pane's, and the sheet MEASURED
    -- that widget - `AceGUIContainer-TabGroup`, which sizes each tab from its TEXT via
    -- `PanelTemplates_TabResize`. ⟶ Hand-rolling here would be a COAT over a published
    -- widget, and the 37/one-row fact would stop applying to what we drew.
    --
    -- ★ THE TAB WIDTHS ARE NOT OURS. They come from the text. We declare the ROW the strip
    -- occupies; the library divides it.
    if gui() then
        strip = gui():Create("TabGroup")
        strip.frame:SetParent(f)
        strip.frame:ClearAllPoints()
        strip.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -8)
        strip:SetWidth(240)
        strip:SetCallback("OnGroupSelected", function(_, _, key) Widget.Mode(key) end)
        strip.frame:Show()

        -- ★★ ONE HOST, RELEASED AND REFILLED - not one per mode kept alive.
        -- ⚠⚠ AND IT IS AN ACEGUI CONTAINER FOR A MECHANICAL REASON. `ReleaseChildren`
        -- POOLS: `AceGUI-3.0.lua:122-138` keeps `objPools[type]` and `newWidget` takes from
        -- the pool before constructing. **WoW frames are never collected**, so a raw-frame
        -- host rebuilt on every switch would LEAK a full set of frames each time. The pool
        -- is what makes law 2's *teardown then rebuild* affordable at all.
        host = gui():Create("SimpleGroup")
        host:SetLayout("Flow")
        host.frame:SetParent(f)
        host.frame:ClearAllPoints()
        host.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -49)
        host:SetWidth(224); host:SetHeight(140)
        host.frame:Show()
    end

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
    -- ★★★ THE RUN MODE - capture. His allocation, 2026-08-25: *"Run controls (Capturing)
    -- live on the Run tab, on the remote pane. Along with the door to the map, the run name
    -- field (at capture) and it's arm."*
    --
    -- ⚠ EVERY CONTROL IS AN ACEGUI WIDGET, and none of them carries an x or a y. Placement
    -- within is the library's (law 4); what is ours is which controls, in what order.
    Widget.Mount("run", "Run", function(h)
        local g = gui()

        W.pin = g:Create("Button")
        W.pin:SetText("Pin here")
        W.pin:SetFullWidth(true)
        W.pin:SetCallback("OnClick", function() Widget.Pin() end)
        h:AddChild(W.pin)

        -- ⚠ THE CARRIED LESSON IS THE LIBRARY'S PROBLEM NOW. `InputBoxTemplate`'s middle
        -- texture anchors to `$parentLeft`/`$parentRight` BY NAME, so a NAMELESS EditBox
        -- rendered as two floating end-caps (COA_Landmarks, a live bug). AceGUI names its
        -- own frames - which is one hand-placed hazard that stops being ours.
        W.name = g:Create("EditBox")
        W.name:SetLabel(nil)
        W.name:SetFullWidth(true)
        h:AddChild(W.name)

        W.count = g:Create("Label")
        W.count:SetFullWidth(true)
        h:AddChild(W.count)

        -- ★ THE FOOTER TRIO. §144 shipped a SIX PIXEL OVERLAP between two of these, live,
        -- found by a human looking at a screenshot. Relative widths cannot overlap.
        W.options = g:Create("Button")
        W.options:SetText("Options")
        W.options:SetRelativeWidth(0.32)
        W.options:SetCallback("OnClick", function() NS.Options.Toggle() end)
        h:AddChild(W.options)

        W.map = g:Create("Button")
        W.map:SetText("Map")
        W.map:SetRelativeWidth(0.30)
        W.map:SetCallback("OnClick", function() NS.Map.Toggle() end)
        h:AddChild(W.map)

        W.arm = g:Create("Button")
        W.arm:SetRelativeWidth(0.36)
        W.arm:SetCallback("OnClick", toggleArm)
        h:AddChild(W.arm)

        -- ☆ THE TEST-DRIVE DOOR IS GONE, 2026-08-26, and its own comment said when: *"it
        -- stays only until `drive.lua` mounts itself as the second MODE - then the tab is
        -- the door and this goes."* `drive.lua` mounts itself now. A10.2d asked for both
        -- until the fold landed, not for both forever.

        refresh()
    end)

    -- ★ THE CONTENT FIRST, THEN THE STRIP CATCHES UP. `Mode` builds and names the live
    -- key; `Restrip` then draws the tab as selected. Doing it the other way round would ask
    -- the strip to select a tab before anything had been built into the host.
    -- ⚠ THE FALLBACK IS NOT COSMETIC. A remembered mode whose file has not loaded yet
    -- returns nil here, and without the second call the remote would open with an EMPTY
    -- page and no mode live - a window with nothing in it and nothing saying why.
    if not Widget.Mode(Store.GetUI().remoteMode or "run") then Widget.Mode("run") end
    Widget.Restrip()

    local R = NS.UI and NS.UI.Register
    if R then
        R("remote.pane", f, { kind = "frame",
            set = function(v) if v == "close" then f:Hide() else f:Show() end end,
            read = function() return f:IsShown() and true or false end })
        -- ★★ THE STRIP REPLACED THE TITLE, so `remote.title` is RETIRED and the strip is
        -- registered in its place - it is what a reader now reads to know the surface.
        if strip then
            R("remote.strip", strip.frame, { kind = "readout",
                read = function() return mode end })
        end
        -- ⚠ THE MODE'S CONTROLS ARE NOT REGISTERED INDIVIDUALLY, and that is the honest
        -- shape now: they are RELEASED and rebuilt on every switch, so a registry holding a
        -- reference would be holding a pooled widget that has moved on. ⟶ The mode is the
        -- registered thing; what it contains is read through it.
        R("remote.mode", host and host.frame or f, { kind = "readout",
            read = function() return mode end })
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
