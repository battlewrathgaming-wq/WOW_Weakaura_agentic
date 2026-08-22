-- COA_DungeonRun drive.lua - THE TEST DRIVE REMOTE (A10.5).
--
-- Model: addons/planning/DRIVER_BASIS.md   READ FIRST. It names what governs NOW, in
--        precedence order, and it MOVES when a ruling moves - so this line never
--        goes stale. Lower number wins; a disagreement is reported, not resolved here.
-- Surface: addons/planning/interface/drive.md
--
-- ---------------------------------------------------------------------------
-- ★★★ WHY IT EXISTS, in his words (D-E, 2026-08-18):
--
--     *"Dungeon Run has a TEST DRIVE REMOTE - mainly so I stop being asked to do things by
--     commands / dispatcher. A control you can see, not a slash line you must already
--     know."*
--
-- And again on 2026-08-22, deciding where the manager's doors go: *"A test drive widget,
-- which is already in scope. Then for now add the buttons there. No command use (Testing
-- churn.)"*
--
-- ⚠⚠ SO THE ABSENCE OF A SLASH COMMAND IS THE FEATURE, not an omission. A10.5a states it
-- as acceptance - *"no slash line required to reach it"* - and `/dr drive` is the OTHER
-- consumer (the L1 prototype `driver.lua`), left exactly where it is.
--
-- ---------------------------------------------------------------------------
-- ★★ THIS IS THE AUTHOR'S DIAGNOSTICS, NOT THE READER'S DISPLAY (AL-6).
--
-- A reader in flight sees none of this. The readout here exists to answer *why did the
-- run not advance*, which is a question only the person authoring the route asks.
--
-- ★ ITS EVENTUAL HOME IS THE PRIMARY FRAME'S G3 TAB (D-E: *"G3 IS the test drive's suite
-- entry inside Dungeon Run"*), which is not built. ⟶ *"for now"*: a hand-built pane
-- beside it, which is the approach D-6b already rules - *"hand-built panes live beside it
-- until their turn"*.
--
-- ☐ THE DOOR IS PLACED, NOT DESIGNED. It is a button on the recorder remote's own top
--    row, in the empty space right of the title - chosen because it is the only place on
--    that pane that costs NONE of the numbers he dragged onto the board in §145. When G3
--    lands, the door moves there and this one goes. Filed for his board, not decided here.
--
-- ---------------------------------------------------------------------------
-- ★★★ THE BINDINGS ARE THIS PANE'S, AND THAT IS THE POINT OF THE BOUNDARY.
--
-- `manager.lua` says it plainly: *"nothing here invents what `note`, `say` or `boss` DO"*.
-- The manager PROVIDES the contract (`Manager.Bind`); a consumer HANDLES it. This pane is
-- a consumer - the test harness one - so the bodies below are the harness's handling and
-- carry no authority over what a shipped reader's addon would do with the same words.
--
-- ⚠ WHICH IS WHY THEY BIND ON ARM AND NOT AT `Init`. Bound at load, these would be the
-- addon's de-facto semantics for three words that are still undecided, and every later
-- consumer would inherit them by accident.
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local Drive = {}
NS.Drive = Drive

local f, routeText, stateText, armBtn, bossBtn, logBtn, prevBtn, nextBtn

-- ★ THE OFFERED ROUTES AND WHERE WE ARE IN THEM. Held here rather than in the store: a
-- cursor into a list is not a preference, and the list is rebuilt every time the pane
-- opens because routes are minted while it is closed.
local offer, at = {}, 1

-- ★★★ WHY THE ROUTE WILL NOT GO - held, not printed and forgotten.
--
-- ⚠⚠ THE FIRST DEPLOY IS THE ARGUMENT FOR THIS FIELD. `beacon 1 has no radius` went to
-- chat, the readout said *"not armed"*, and the pane whose entire job is answering *why
-- did it not go* was the one surface that did not carry the answer. ⟶ Chat scrolls;
-- a diagnostic holds.
--
-- ★ TWO ORIGINS, ONE SLOT: a build REFUSED at arm, and a build checked AHEAD of one.
-- Both are `Bucket.Build` saying the same thing about the same route, so a second field
-- would be two names for one fact.
local refusal = nil

-- ⚠ THE PENDING BOSS TABS, OLDEST FIRST. A `boss` callable returns FALSE - the tab is not
-- done when it RAN, it is done when the boss dies - so the ctx is parked here and the
-- button below is what plays the part of the kill.
local waiting = {}

local function mapNow()
    -- ⚠ THE SAME READ `/dr drive` USES (`core.lua`), and no adaptation of it. Two paths to
    -- one fact that disagree is worse than one path that is wrong.
    return select(4, GetCurrentPlayerPosition())
end

-- =====================================================================
-- THE HARNESS'S ACTION BODIES - see the boundary note at the top
-- =====================================================================

local function bind()
    local Manager = NS.Manager
    if not Manager or not Manager.Bind then return nil, "the manager is not loaded" end

    -- ★ A NOTE IS THE ROUTE TALKING TO THE READER. Printing it is the whole of it here;
    -- where it should LAND (a banner? the objective tracker?) is a display decision this
    -- pane has no standing to make.
    Manager.Bind("note", function(ctx)
        NS.Say(("|cffffd100note|r %s"):format(tostring(ctx.arg or "")))
        return true
    end)

    -- ⚠⚠ IT PRINTS; IT DOES NOT `SendChatMessage`. A test drive that actually says things
    -- in a public channel makes every rehearsal visible to a party, and an author testing
    -- a route would learn to stop testing it. ⟶ The harness shows WHAT would be said.
    Manager.Bind("say", function(ctx)
        NS.Say(("|cff80ff80/say|r %s   |cff808080(printed, not sent)|r")
            :format(tostring(ctx.arg or "")))
        return true
    end)

    -- ★★★ THE PENDING CASE, AND IT IS THE ONE WORTH HAVING A BUTTON FOR. A12.4c: a `boss`
    -- tab arms a listener and finishes when the boss dies, which is not when the tab ran.
    -- ⟶ Returning false parks it; `Drive.BossDown` is the kill.
    -- ⚠ NO CLEU LISTENER HERE ON PURPOSE. A10.5b's proof is *"advance on just a boss kill
    -- against a landed capture"* - the listener is the thing being specified, and a
    -- harness that guesses at it would prove the guess.
    Manager.Bind("boss", function(ctx)
        waiting[#waiting + 1] = ctx
        NS.Say(("|cffff8080boss|r %s - waiting. Press |cffffd100Boss down|r.")
            :format(tostring(ctx.arg or "?")))
        return false
    end)

    return true
end

-- =====================================================================
-- THE READOUT (A10.5a) - the IN SET BY ADDRESS, never `stage` alone
-- =====================================================================

-- ⚠⚠ `stage` ALONE IS THE FAILING ANSWER, and A10.5's own mutation says so: *"expose
-- `stage` alone → fails"*. A stage number tells you the run moved; it does not tell you
-- which addresses the player is standing in, which is the only thing that explains why it
-- did NOT move.
local function readout()
    local Manager, Sensor = NS.Manager, NS.Sensor
    if not Manager or not Manager.Running() then
        -- ★ THE REASON OUTLIVES THE PRESS. It is cleared when the cursor moves or the
        -- list is rebuilt - i.e. when the thing it is about changes - and NOT on a timer:
        -- a diagnostic that expires while you are reading it is worse than none.
        if refusal then
            return ("|cffff8080will not arm|r\n%s"):format(tostring(refusal))
        end
        return "not armed"
    end

    -- ⚠ `Sensor.InSet`, NOT `Sensor.State`. `State` returns COUNTS by design - it
    -- refuses to hand out the tables so a caller cannot mutate the sensor through the
    -- reader - and a count cannot answer *which addresses*. `InSet` returns a sorted COPY.
    local inSet = (Sensor and Sensor.InSet and Sensor.InSet()) or {}

    -- ★ `step` MAY BE ABSENT AND THAT IS A STATE, NOT A BLANK. A stage whose ordinals ran
    -- dry reads `-`, which is different from one that never had any.
    return ("stage %s  step %s\nin: %s%s"):format(
        tostring(Manager.Stage() or "-"),
        tostring(Manager.Step() or "-"),
        #inSet > 0 and table.concat(inSet, ", ") or "|cff808080(nothing)|r",
        #waiting > 0 and ("\nwaiting on %d boss tab(s)"):format(#waiting) or "")
end

-- ---------------------------------------------------------------------
-- READ-ONLY, TO THE HARNESS AND TO A LOOK-BACK
-- ---------------------------------------------------------------------

-- ★ A COPY of the offered list, never the list. Handing out the table would let a
-- caller reorder the cursor's own index space from outside it.
function Drive.Offered()
    local out = {}
    for i, entry in ipairs(offer) do out[i] = entry end
    return out
end

-- ⚠ AN ENTRY, NOT A RID. `Routes.List` offers `{ id, name }` - the NAME is what an
-- author picked the route by and the ID is what everything downstream is keyed on, so a
-- pane that kept only one of them would either show a rid or arm a name.
function Drive.At() return offer[at] end
function Drive.AtId() return offer[at] and offer[at].id or nil end
function Drive.Shown() return f and f:IsShown() and true or false end

-- ⚠ THE REASON, READABLE. A row asserting on `refusal` rather than on the READOUT would
-- pass on a pane that held the answer and never showed it.
function Drive.Refusal() return refusal end

-- ⚠ WHAT THE PANE SAYS, not what it knows. A route line asserted against `offer[at].name`
-- would pass on a pane that printed the rid.
function Drive.RouteText() return routeText and routeText:GetText() or "" end
function Drive.Waiting() return #waiting end

-- ⚠ THE READOUT AS TEXT, which is what makes A10.5a gradable. The row is about what
-- the pane SAYS - *"the set of addresses the player is IN"* - and a test that read
-- `Sensor.InSet` instead would pass on a pane that showed `stage` alone.
function Drive.Readout() return readout() end

-- ⚠ `Drive.Selected` WAS HERE AND IS GONE (2026-08-22). It wrapped `Manager.Selected`
-- for a smoke row that ended up using `Drive.AtId` instead, so it shipped with no caller
-- at all - found by `emit_built_state.py` on the doc-catch-up pass, in the same STRANDED
-- bucket as the genuinely doorless writers. ★ Removed rather than parked: a reader that
-- exists and answers is an invitation to build on it, and this one duplicated a door the
-- manager already publishes.

local function refresh()
    if not f then return end
    -- ⚠ A HIDDEN PANE DOES NOT REDRAW. `Sensor.OnChange` fires at the poll rate, and
    -- this pane is CLOSED by default - so without this line an author who never opens it
    -- still pays a SetText per poll for a readout nobody is looking at. ★ `Toggle` calls
    -- `Reoffer` on the way open, so what it shows is current the moment it is shown.
    if not f:IsShown() then return end
    local Manager, Log = NS.Manager, NS.DebugLog

    local running = Manager and Manager.Running()
    -- ★ THE LIST SAYS WHETHER IT WILL GO, so *press and read chat* becomes *look*.
    routeText:SetText(offer[at]
        and ("%d/%d  |cffffd100%s|r%s"):format(at, #offer, tostring(offer[at].name),
                                               refusal and "  |cffff8080✗|r" or "")
        or "|cff808080no route on this map|r")
    armBtn:SetText(running and "Stop" or "Arm")
    stateText:SetText(readout())

    -- ★ DISABLED, NOT HIDDEN, like the recorder remote's pin. Disabled says *this exists
    -- and needs a run*; hidden says nothing at all.
    if #waiting > 0 then bossBtn:Enable() else bossBtn:Disable() end
    if offer[at] then armBtn:Enable() else armBtn:Disable() end
    if prevBtn then
        if #offer > 1 then prevBtn:Enable(); nextBtn:Enable()
        else prevBtn:Disable(); nextBtn:Disable() end
    end

    logBtn:SetText(Log and Log.Running() and "Stop log" or "Log")
end
Drive.Refresh = refresh

-- =====================================================================
-- THE BUTTONS
-- =====================================================================

-- ★★ THE SAME QUESTION THE ARM ASKS, ASKED EARLY. `Bucket.Build` is the authority on
-- whether a route can run and there is no cheaper oracle - so this calls it rather than
-- re-deriving a second opinion that could disagree with the one that matters.
--
-- ⚠ ON A CLICK, NEVER ON A POLL. It runs when the cursor moves or the list is rebuilt;
-- `refresh` fires at the sensor's rate and must not build a bucket per sample.
-- ⚠⚠ AND IT BUILDS NOTHING THAT SURVIVES: the bucket is discarded. Keeping it would be
-- a second bucket alive beside the manager's, which A12.1a exists to forbid.
local function checkAhead()
    local Bucket = NS.Bucket
    local rid = Drive.AtId()
    if not Bucket or not rid then refusal = nil return end
    local built, why = Bucket.Build(mapNow(), rid)
    refusal = (not built) and why or nil
end

function Drive.Reoffer()
    local Manager = NS.Manager
    offer = (Manager and Manager.Offer and Manager.Offer(mapNow())) or {}
    -- ⚠ THE SELECTION SURVIVES A REOFFER when it is still on the list. Landing back on
    -- entry 1 after every open would make the cursor useless on a map with several routes.
    local want = Manager and Manager.Selected and Manager.Selected()
    at = 1
    for i, entry in ipairs(offer) do if entry.id == want then at = i end end
    checkAhead()
    refresh()
    return offer
end

function Drive.Cycle(by)
    if #offer == 0 then return end
    at = ((at - 1 + by) % #offer) + 1
    checkAhead()
    refresh()
end

function Drive.ToggleArm()
    local Manager = NS.Manager
    if not Manager then return end

    if Manager.Running() then
        Manager.Stop("DungeonRun: test drive stopped")
        Drive.Unwire()
        refresh()
        return
    end

    local rid = Drive.AtId()
    if not rid then return end

    local ok, why = bind()
    if not ok then NS.Say("|cffff8080" .. tostring(why) .. "|r") return end

    -- ★★ THE TWO CLIENT SEAMS, INSTALLED BEFORE THE ARM AND CLEARED AFTER THE STOP. The
    -- manager arms the sensor itself but supplies neither the sampler nor the consumer for
    -- what the sensor produces - both are deliberately absent from a file that must stay
    -- gradable offline. ⟶ Wiring them is the DOOR's job, which is this pane.
    Drive.Wire()

    local armed, armWhy = Manager.Select(mapNow(), rid)
    if not armed then
        Drive.Unwire()
        -- ⚠ HELD **AND** SAID. The pane keeps it so it can be read after the fact; chat
        -- gets it so an author watching the log sees it in sequence with everything else.
        refusal = armWhy
        NS.Say("|cffff8080" .. tostring(armWhy) .. "|r")
    else
        refusal = nil
        NS.Say(("test drive |cffffd100%s|r - stage %s")
            :format(tostring(rid), tostring(Manager.Stage())))
    end
    refresh()
end

function Drive.Wire()
    local Sensor, Manager = NS.Sensor, NS.Manager
    if not Sensor then return end
    Sensor.Sample = NS.Driver and NS.Driver.Sample or nil
    Sensor.OnChange = function(changed)
        if Manager and Manager.OnPoll then Manager.OnPoll(changed) end
        refresh()
    end
end

-- ⚠ BOTH SEAMS CLEARED, not just the arming - S9's criterion is *"nothing armed, nothing
-- RUNNING"*, and a live sampler bound to a disarmed sensor is the same half-state as a
-- persistent OnUpdate that checks a flag.
function Drive.Unwire()
    local Sensor = NS.Sensor
    if not Sensor then return end
    Sensor.Sample = nil
    Sensor.OnChange = nil
    waiting = {}
end

-- ★ OLDEST FIRST. Two boss tabs pending is a real shape - two rooms both reached - and
-- completing the newest would make the button's effect depend on arrival order in a way
-- nobody could see on the pane.
function Drive.BossDown()
    local ctx = table.remove(waiting, 1)
    if not ctx then return end
    NS.Say(("|cffffd100kill|r %s"):format(tostring(ctx.arg or "?")))
    if ctx.complete then ctx.complete() end
    refresh()
end

function Drive.ToggleLog()
    local Log = NS.DebugLog
    if not Log then NS.Say("|cffff8080the debug log is not loaded|r") return end

    if Log.Running() then
        local stopped = Log.Stop(GetTime and GetTime() or 0)
        -- ⚠ THE NAME COMES OFF THE STOPPED RUN, not off `Log.Name()`. `Stop` clears the
        -- module's run and hands it back, so the getter is nil by the line after.
        local rep = Log.Report(stopped)
        if not rep then NS.Say("|cffff8080no log was running|r") return end

        -- ★★ AL-25: a client-only seam is accepted by THE LOG OF A NAMED TEST RUN. ⚠
        -- `Report` RETURNS DATA AND NEVER PRINTS - *"who shows it is the caller's"* - so
        -- the shaping into lines is here, which is where the chat frame is.
        NS.Say(("log |cffffd100%s|r - %d poll(s) over %.1fs (%.1f/s)%s")
            :format(tostring(rep.name), rep.polls or 0, rep.span or 0, rep.rate or 0,
                    rep.dropped and rep.dropped > 0
                        and ("  |cffff8080%d line(s) dropped|r"):format(rep.dropped) or ""))
        -- ★ BUCKETS, SORTED. The counts are the noisy path's whole record and an
        -- unordered dump of them reshuffles every time it is printed.
        local kinds = {}
        for kind in pairs(rep.counts or {}) do kinds[#kinds + 1] = kind end
        table.sort(kinds)
        for _, kind in ipairs(kinds) do
            NS.Say(("  %s |cffffd100%d|r"):format(kind, rep.counts[kind]))
        end
        -- ⚠⚠ THE ERRORS ARE NOT A FOOTNOTE. A test drive whose log captured a Lua error
        -- and printed it below a wall of counts has hidden the one line that matters.
        for _, err in ipairs(rep.errors or {}) do
            NS.Say(("|cffff8080error x%d|r %s")
                :format((rep.errorCounts or {})[err] or 1, tostring(err)))
        end
    else
        -- ⚠ THE NAME IS DERIVED, NOT TYPED. A name box here would be a fourth control for
        -- a string nobody cites by hand; the route and the stage are what a reader of the
        -- log needs to know it is the right one.
        local Manager = NS.Manager
        local name = ("%s@%s"):format(tostring(Drive.AtId() or "none"), tostring(mapNow()))
        local started, displaced = Log.Start(name, GetTime and GetTime() or 0)
        NS.Say(("log |cffffd100%s|r started%s"):format(tostring(started),
            displaced and (" - displaced |cff808080" .. tostring(displaced) .. "|r") or ""))
        if Manager and Manager.Running() then refresh() end
    end
    refresh()
end

-- =====================================================================
-- THE PANE
-- =====================================================================

function Drive.Init()
    local Store = NS.Store

    f = CreateFrame("Frame", "COA_DungeonRunDrive", UIParent)
    f:SetWidth(280); f:SetHeight(206)
    f:SetPoint("CENTER", UIParent, "CENTER", 300, 120)
    f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, _, x, y = self:GetPoint()
        Store.SetUI("drivePos", { p = p, x = x, y = y })
    end)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 18, -10)
    title:SetText("Test drive")

    -- ★ THE ROUTE CURSOR. A dropdown would be the reader's control; this pane has one
    -- author, one map's worth of routes, and two arrows cost no menu to open.
    prevBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    prevBtn:SetWidth(24); prevBtn:SetHeight(20)
    prevBtn:SetPoint("TOPLEFT", 18, -34)
    prevBtn:SetText("<")
    prevBtn:SetScript("OnClick", function() Drive.Cycle(-1) end)

    nextBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    nextBtn:SetWidth(24); nextBtn:SetHeight(20)
    nextBtn:SetPoint("TOPRIGHT", -18, -34)
    nextBtn:SetText(">")
    nextBtn:SetScript("OnClick", function() Drive.Cycle(1) end)

    routeText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    routeText:SetPoint("TOPLEFT", 46, -38)
    routeText:SetWidth(188)

    armBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    armBtn:SetWidth(118); armBtn:SetHeight(22)
    armBtn:SetPoint("TOPLEFT", 18, -60)
    armBtn:SetScript("OnClick", Drive.ToggleArm)

    bossBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    bossBtn:SetWidth(118); bossBtn:SetHeight(22)
    bossBtn:SetPoint("TOPRIGHT", -18, -60)
    bossBtn:SetText("Boss down")
    bossBtn:SetScript("OnClick", Drive.BossDown)

    logBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    logBtn:SetWidth(118); logBtn:SetHeight(22)
    logBtn:SetPoint("TOPLEFT", 18, -86)
    logBtn:SetScript("OnClick", Drive.ToggleLog)

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetWidth(118); closeBtn:SetHeight(22)
    closeBtn:SetPoint("TOPRIGHT", -18, -86)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() Drive.Toggle() end)

    -- ★ ANCHORED BY ITS TOP and given a width, so a long in-set wraps DOWN into the pane
    -- rather than out through its border. A FontString's height comes from its text.
    stateText = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    stateText:SetPoint("TOPLEFT", 18, -118)
    stateText:SetWidth(244)
    stateText:SetJustifyH("LEFT")
    stateText:SetJustifyV("TOP")

    local ui = Store.GetUI()
    if ui.drivePos then
        f:ClearAllPoints()
        f:SetPoint(ui.drivePos.p, UIParent, ui.drivePos.p, ui.drivePos.x, ui.drivePos.y)
    end
    -- ⚠ CLOSED BY DEFAULT. It is the author's diagnostics; a pane that opens itself on
    -- every login is a pane that has to be closed on every login.
    if ui.driveShown ~= true then f:Hide() end

    -- ★★★ EVERY DECLARED CONTROL, REGISTERED (§131) - and the block sits at the END of the
    -- build, where everything above it exists. §97.1 lost a control to a registration
    -- written forty lines above the button it named.
    local R = NS.UI and NS.UI.Register
    if R then
        R("drive.pane", f, { kind = "frame",
            set = function(v) if v == "close" then f:Hide() else f:Show() end end,
            read = function() return f:IsShown() and true or false end })
        R("drive.title", title, { kind = "readout",
            read = function() return title:GetText() end })
        R("drive.prev", prevBtn)
        R("drive.next", nextBtn)
        R("drive.route", routeText, { kind = "readout",
            read = function() return routeText:GetText() end })
        R("drive.arm", armBtn)
        R("drive.boss", bossBtn)
        R("drive.log", logBtn)
        R("drive.close", closeBtn)
        R("drive.state", stateText, { kind = "readout",
            read = function() return stateText:GetText() end })
    end

    Drive.Reoffer()
    return f
end

function Drive.Toggle()
    if not f then return end
    if f:IsShown() then
        f:Hide()
    else
        f:Show()
        -- ⚠ RE-OFFER ON OPEN. Routes are minted while this pane is closed, and a cursor
        -- into a stale list points at a route that may no longer be on this map.
        Drive.Reoffer()
    end
    NS.Store.SetUI("driveShown", f:IsShown() and true or false)
end

return Drive
