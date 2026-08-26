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

-- ★★★ NO FRAME OF ITS OWN ANY MORE. The test drive is the remote's SECOND MODE
-- (AL-49/AL-50, folded 2026-08-26): *"two modes of one widget, not two panes sharing a
-- frame."* This file owns WHAT the mode contains and nothing about where it sits.
-- ⟶ `W` is the live widgets, handed over by `Widget.Mode` on every entry; it is EMPTY
-- whenever another mode is showing, which is what every guard below tests.
local W = {}

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
-- ⚠ SHOWN NOW MEANS *is the drive mode the LIVE one*, which is what every caller
-- actually asked. A drive pane could be open behind the recorder remote; a drive MODE
-- cannot - the strip has exactly one tab selected.
function Drive.Shown()
    local Widget = NS.Widget
    return (Widget and Widget.CurrentMode() == "drive") and true or false
end

-- ⚠ THE REASON, READABLE. A row asserting on `refusal` rather than on the READOUT would
-- pass on a pane that held the answer and never showed it.
function Drive.Refusal() return refusal end

-- ⚠ WHAT THE SURFACE SAYS, not what it knows. A route line asserted against
-- `offer[at].name` would pass on a mode that printed the rid.
-- ⚠⚠ AND IT READS THE FONTSTRING, because an AceGUI Label HAS NO `GetText`. It publishes
-- `SetText` and keeps the string on `self.label`; calling `GetText` on the widget returns
-- nil and errors, which is what the smoke found the moment drive folded. ⟶ Reading the
-- fontstring keeps the assertion pointed at what is DRAWN rather than at what we last set.
function Drive.RouteText()
    local lbl = W.route and W.route.label
    return (lbl and lbl:GetText()) or ""
end
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

-- ⚠⚠ GUARDED ON THE LIVE MODE, NOT ON THE WIDGET TABLE - and the difference is a real
-- defect the mutation suite found in the first cut of this fold.
--
-- `W` is an UPVALUE holding the table handed to our LAST build. `Widget.Mode` makes a NEW
-- table for the incoming mode; it does not empty the old one. ⟶ After a switch away,
-- `W.route` is still TRUTHY and still points at a widget AceGUI has returned to its POOL,
-- so `if not W.route then return end` passes and writes into a widget another mode may
-- now be using. Breaking that guard changed nothing in the suite, because it was never
-- what stopped it.
-- ★ THE RUN MODE CANNOT HAVE THIS FAULT - its `W` and the remote's are one upvalue,
-- reassigned together. The shape appears only for a mode mounted FROM ANOTHER FILE, which
-- is what folding drive created.
-- ⟶ So ask the authority. *Is drive the live mode* is one fact with one owner, and it
-- cannot go stale the way a captured table can.
local function refresh()
    local Widget = NS.Widget
    if not Widget or Widget.CurrentMode() ~= "drive" then return end
    if not W.route then return end
    local Manager, Log = NS.Manager, NS.DebugLog

    local running = Manager and Manager.Running()
    -- ★ THE LIST SAYS WHETHER IT WILL GO, so *press and read chat* becomes *look*.
    W.route:SetText(offer[at]
        and ("%d/%d  |cffffd100%s|r%s"):format(at, #offer, tostring(offer[at].name),
                                               refusal and "  |cffff8080✗|r" or "")
        or "|cff808080no route on this map|r")
    W.arm:SetText(running and "Stop" or "Arm")
    W.state:SetText(readout())

    -- ★ DISABLED, NOT HIDDEN, like the recorder remote's pin. Disabled says *this exists
    -- and needs a run*; hidden says nothing at all.
    W.boss:SetDisabled(#waiting == 0)
    W.arm:SetDisabled(offer[at] == nil)
    -- ★ ONE CURSOR, ONE CONDITION. Both arrows answer the same question, so they are
    -- set from one expression rather than two branches that can disagree.
    W.prev:SetDisabled(#offer <= 1)
    W.next:SetDisabled(#offer <= 1)

    W.log:SetText(Log and Log.Running() and "Stop log" or "Log")
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
    local Widget = NS.Widget
    if not Widget or not Widget.Mount then return nil end

    -- ★★★ MOUNTED, NOT BUILT. The remote owns the frame, the strip and the page; this
    -- registers WHAT the test-drive mode contains and in what order. Every x, y, width and
    -- height that used to live here is gone - placement within is the library's
    -- (`DR_Pane_4`), and the arrangement is what stayed ours.
    --
    -- ⚠ THE BUILDER RUNS ON EVERY ENTRY, not once. `DR_Pane_2`: a content swap is a
    -- teardown, so these widgets are made fresh each time the tab is picked and released
    -- when it is left. Nothing built here may be cached across a switch.
    return Widget.Mount("drive", "Test drive", function(h, w)
        local g = LibStub and LibStub("AceGUI-3.0", true)
        if not g then return end
        -- ★ THE REMOTE'S TABLE, HANDED IN - not one of ours. `refresh` below reads `W`, so
        -- pointing it at the remote's is what keeps ONE set of widgets rather than two
        -- views that agree until they do not.
        W = w

        -- ★ THE ROUTE CURSOR. A dropdown would be the reader's control; this mode has one
        -- author, one map's worth of routes, and two arrows cost no menu to open.
        -- ⚠ The three sit on one line by DECLARED relative width, never by fit - `row.md`
        -- rules PAIRED BY FIT ⚠⚠ NEVER, and AceGUI `Flow` pairs by fit as its mechanism.
        -- The widths are what make this pairing a declaration inside that layout.
        W.prev = g:Create("Button")
        W.prev:SetText("<")
        W.prev:SetRelativeWidth(0.16)
        W.prev:SetCallback("OnClick", function() Drive.Cycle(-1) end)
        h:AddChild(W.prev)

        W.route = g:Create("Label")
        W.route:SetRelativeWidth(0.66)
        h:AddChild(W.route)

        W.next = g:Create("Button")
        W.next:SetText(">")
        W.next:SetRelativeWidth(0.16)
        W.next:SetCallback("OnClick", function() Drive.Cycle(1) end)
        h:AddChild(W.next)

        W.arm = g:Create("Button")
        W.arm:SetRelativeWidth(0.49)
        W.arm:SetCallback("OnClick", Drive.ToggleArm)
        h:AddChild(W.arm)

        W.boss = g:Create("Button")
        W.boss:SetText("Boss down")
        W.boss:SetRelativeWidth(0.49)
        W.boss:SetCallback("OnClick", Drive.BossDown)
        h:AddChild(W.boss)

        W.log = g:Create("Button")
        W.log:SetFullWidth(true)
        W.log:SetCallback("OnClick", Drive.ToggleLog)
        h:AddChild(W.log)

        -- ☆ THE CLOSE BUTTON IS RETIRED WITH THE PANE. A mode is left by picking the other
        -- tab; a Close inside a tab would close the whole remote, which is not what it said.
        -- The remote's own frame keeps the one close there is.

        -- ★ A LONG IN-SET WRAPS DOWN rather than out through the border. The old
        -- FontString needed an explicit width and a JustifyV to do that; a full-width
        -- AceGUI Label does it because the container gives it the width.
        W.state = g:Create("Label")
        W.state:SetFullWidth(true)
        h:AddChild(W.state)

        -- ⚠ RE-OFFER ON ENTRY, and this is where the old `Toggle` did it. Routes are minted
        -- while another mode is up, and a cursor into a stale list points at a route that
        -- may no longer be on this map.
        Drive.Reoffer()
    end)
end

-- ★★ TOGGLE SELECTS A TAB NOW. It is kept, and kept as a TOGGLE, because it is the
-- shape every existing caller and every smoke already uses - `/dr` may alias it, and
-- A10.5a's *"no slash line required to reach it"* is satisfied by the tab, not by this.
-- ⚠ THE STORED `driveShown` KEY IS GONE. `Widget.Mode` writes `remoteMode`, which is the
-- same fact with one owner; two keys describing which surface is up is the second copy
-- that drifts, and they could disagree.
function Drive.Toggle()
    local Widget = NS.Widget
    if not Widget or not Widget.Mode then return nil end
    if Widget.CurrentMode() == "drive" then return Widget.Mode("run") end
    return Widget.Mode("drive")
end

return Drive
