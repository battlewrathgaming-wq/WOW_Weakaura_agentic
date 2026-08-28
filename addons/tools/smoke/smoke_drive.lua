-- Offline smoke for COA_DungeonRun drive.lua - THE TEST DRIVE REMOTE (A10.5).
--
-- ★★★ WHY THIS ONE MATTERS MORE THAN A PANE SMOKE USUALLY DOES. Every other consumer of
-- the manager tier is a test file. This pane is the ONLY thing in the shipped addon that
-- arms it, so anything wrong here is wrong on the client with nothing else to catch it.
--
-- What can be SILENTLY wrong, and each produces a pane that still looks like it works:
--
--   the seams     `Sensor.Sample` or `Sensor.OnChange` left unset -> the pane arms, the
--                 readout draws, the sensor samples nothing or drops every transition,
--                 and the run simply never advances. NO ERROR AT ANY POINT.
--   Unwire        a seam left installed after Stop -> a live sampler on a disarmed
--                 sensor, which is the half-state S9 exists to forbid
--   the bindings  bound at load instead of on arm -> three undecided words acquire
--                 shipped semantics by accident, and every later consumer inherits them
--   the readout   `stage` alone -> A10.5's own mutation, and the diagnostic can no
--                 longer answer the only question it is for
--   the boss FIFO newest-first -> the button's effect depends on arrival order in a way
--                 nobody can see on the pane
--
-- ⚠ AND THE GEOMETRY IS ASSERTED, not eyeballed. §144 shipped a SIX PIXEL OVERLAP between
-- two buttons on the remote and it was found by a human looking at a screenshot.

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\]]
local ADDON = ROOT .. [[addons\COA_DungeonRun\]]
local SMOKE = ROOT .. [[addons\tools\smoke\]]

local F = assert(loadfile(SMOKE .. [[frames.lua]]))()

local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }
local function said(pat)
    for _, m in ipairs(chat) do if m:find(pat, 1, true) then return m end end
    return nil
end

UIParent = F.New("UIParent")
F.SetRoot(UIParent, 1024, 768, 0, 0)
function CreateFrame(_, name, parent, template)
    return F.New(name, parent or UIParent, template)
end

local W = { mapID = 33 }
function GetCurrentPlayerPosition() return 1, 2, 3, W.mapID end
function GetCurrentMapDungeonLevel() return 6 end
function GetMapInfo() return "ShadowfangKeep", 668, 768 end
function GetRealZoneText() return "Shadowfang Keep" end
function GetSubZoneText() return "" end
function UnitName() return "Gravekeeper" end
function time() return 1786600000 end
local CLOCK = 100.0
function GetTime() return CLOCK end
function geterrorhandler() return function(e) error(e, 0) end end
function wipe(t) for k in pairs(t) do t[k] = nil end return t end
GameFontNormal = F.New("GameFontNormal")
GameFontHighlight = F.New("GameFontHighlight")
GameFontHighlightSmall = F.New("GameFontHighlightSmall")
GameFontDisableSmall = F.New("GameFontDisableSmall")
function _PlaySound() end
function strtrim(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end
function hooksecurefunc(a, b, c)
    local t, k, post = a, b, c
    if type(a) == "string" then t, k, post = _G, a, b end
    local orig = t[k]
    t[k] = function(...) local r = orig and orig(...); post(...); return r end
end
table.wipe = wipe
strmatch, strfind, strsub, strlower, strupper, strrep, strbyte, strchar =
    string.match, string.find, string.sub, string.lower, string.upper, string.rep,
    string.byte, string.char
format, gsub = string.format, string.gsub
tinsert, tremove, sort, getn = table.insert, table.remove, table.sort, table.getn
max, min, floor, ceil, abs, mod =
    math.max, math.min, math.floor, math.ceil, math.abs, math.fmod
C_Timer = { After = function(_, fn) if fn then fn() end end,
            NewTicker = function() return { Cancel = function() end } end }

-- ★★★ THE ACE STACK, BECAUSE THE SUBJECT FOLDED ONTO IT (2026-08-26). The test drive is
-- the remote's second MODE now, so `Drive.Init` MOUNTS instead of building a pane and
-- every control is an AceGUI widget.
-- ⚠ WITHOUT THIS, `Drive.Init()` RETURNS NIL AND EVERY PANE ASSERTION BELOW GRADES A
-- FUNCTION THAT RETURNED ON ITS FIRST LINE - the exact shape this bench has now hit twice
-- (`smoke_dungeonrun`'s pin scan, and an offline probe run with no LibStub present).
-- ★ This file already used `frames.lua`, the real frame model, so it could host AceGUI all
-- along and simply never loaded it.
local FX = assert(loadfile(SMOKE .. [[framexml.lua]]))()
FX.MakeFrame = function(n) return F.New(n) end
FX.Load()
local ACE = assert(loadfile(SMOKE .. [[ace_stack.lua]]))()
ACE.Load(ADDON .. [[Libs\]])
assert(LibStub and LibStub("AceGUI-3.0", true),
       "ACEGUI IS NOT LOADED: the drive mode cannot mount, and every assertion about its "
       .. "controls would pass by testing a nil-guard")

local NS = {}
NS.Say = function(m) DEFAULT_CHAT_FRAME:AddMessage(m) end
local function load(f) assert(loadfile(ADDON .. f))("COA_DungeonRun", NS) end
load("contract.lua"); load("rule.lua"); load("sensor.lua"); load("bucket.lua")
-- ⚠ THE WATCHER IS A DEPENDENCY OF THE BOSS HALF, not a neighbour. Without it
-- `NS.BossWatch` is nil, the `boss` binding takes its no-name branch, and every assertion
-- below about the boss half grades the FALLBACK - passing for the wrong reason.
load("bosswatch.lua")
load("driver.lua"); load("store.lua"); load("routes.lua"); load("manager.lua")
-- ⚠ `widget.lua` IS A DEPENDENCY NOW, not a neighbour. It owns `Widget.Mount`, and drive
-- without it is a mode with nowhere to mount.
-- ⚠ `capture.lua` COMES WITH `widget.lua`, and that is a real dependency rather than a
-- harness convenience: the remote's run mode calls `Capture.RunId()` in its refresh, so a
-- remote built without it errors on its first draw. Loading the module is the honest fix;
-- adding a nil-guard for a module the addon always ships would be guarding the harness.
load("debuglog.lua"); load("capture.lua"); load("widget.lua"); load("drive.lua")
local Store, Routes, Manager, Sensor, Drive, Log =
    NS.Store, NS.Routes, NS.Manager, NS.Sensor, NS.Drive, NS.DebugLog

COA_DungeonRunDB = nil
assert(Store.Load(), "fresh db")
Routes.Init()

for _, leaked in ipairs({ "offer", "at", "waiting", "refresh", "readout", "bind",
                          "mapNow", "f", "armBtn", "bossBtn", "logBtn" }) do
    assert(_G[leaked] == nil, "LEAKED GLOBAL: " .. leaked)
end

-- =====================================================================
-- A ROUTE WITH ONE OF EACH ACTION, so the arm gate has all three words to want.
-- =====================================================================
-- ★★★ MINTED THROUGH THE SHIPPED DOORS, not hand-assembled. §492's lesson is that a
-- route authored through the real API used to build with ZERO ROWS and stall in silence;
-- a fixture built by hand cannot find that class of fault, because it hand-writes the
-- thing the doors forgot to make.
local rid = assert(Routes.Create("Drive test", W.mapID))
local function beacon(stage, action, arg)
    local b = assert(Routes.AddBeacon(rid, {
        mapX = 0.3 + stage / 100, mapY = 0.4, x = 100 + stage * 10, y = 200, z = 0,
        mapID = W.mapID, floor = 6, radius = 8 }, stage))
    local child = assert(Routes.AddChildHere(rid, b))
    Routes.SetChildOrdinal(b, child, 1)
    -- ★★★ TOUCHED NOTHING. A10.3e-R's test is *mint a child, touch nothing → its
    -- radius is 5 and the route builds*, so setting a reach here would grade the SETTER
    -- and leave the MINT's default - the half ruled 2026-08-22 - ungraded.
    -- ⚠ THIS LINE USED TO SET IT, with a comment calling the refusal *the gate working*.
    -- It was. It was also the bench watching a route authored through shipped doors come
    -- out undrivable and filing it as correct behaviour - which is exactly what the first
    -- test drive then hit.
    assert(select(1, Routes.ReachOf(child)) == Routes.R_FLOOR,
           "A MINTED CHILD MUST CARRY THE STANDING R (A10.3e-R). got "
           .. tostring(select(1, Routes.ReachOf(child))))
    assert(Routes.SetRow(b, child, 1, Routes.SENSE_WORDS[1] or "whenOn", action, arg))
    return b, child
end
local b1, c1 = beacon(1, "note", "pull the left patrol first")
local b2, c2 = beacon(2, "boss", "Baron Silverlaine")

-- ★★★ TWO KEY SPACES, AND THEY ARE NOT INTERCHANGEABLE. `Routes.PathOf` returns
-- **`stage:ordinal`** - the POSITION - while the sensor keys on the IDENTITY address
-- `mapID:rid:bid:cid`. ⚠ A first cut matched one against the other and PASSED on the
-- first beacon by coincidence (`1:1` occurs inside `33:1:1:1`), then failed on the second.
-- ⟶ A1.2 forbids a second key-space precisely so these never quietly stand in for each
-- other; a test that conflates them is the same fault one tier up.
local function addressOf(b, child)
    return ("%s:%s:%s:%s"):format(W.mapID, rid, b.id, child.id)
end
local function nodeAt(list, addr)
    for _, n in ipairs(list) do if n.address == addr then return n end end
    return nil
end
local a1 = addressOf(b1, c1)
local a2 = addressOf(b2, c2)

-- =====================================================================
-- ★★★ THE BINDINGS ARE NOT PRESENT UNTIL SOMETHING ARMS.
--
-- ⚠ THIS IS THE BOUNDARY ASSERTION, not a lifecycle detail. `manager.lua` states that
-- nothing in it invents what these words DO; if this pane bound them at load, the addon
-- would ship a de-facto meaning for three undecided words and every later consumer would
-- inherit it without ever choosing it.
-- =====================================================================
-- ⚠ THE REMOTE IS BUILT FIRST. It owns the frame, the strip and the page; `Drive.Init`
-- registers a mode INTO it and cannot run before it exists.
assert(NS.Widget.Init(), "the remote builds")
assert(Drive.Init() == "drive", "and drive mounts itself as its second mode")
assert(Manager.Bound("note") == nil and Manager.Bound("boss") == nil,
       "THE HARNESS BOUND THE ACTION WORDS AT LOAD: `note`, `say` and `boss` have no "
       .. "ruled bodies yet, and a pane that binds them at Init makes its own guess the "
       .. "addon's shipped answer")

-- ⚠⚠ AND THE PANE IS OPENED, because it is CLOSED by default and `refresh` returns
-- early on a hidden pane - so a smoke that never opens it grades every button's state
-- against a function that returned on its second line. ★ An author using this pane has
-- it open; that is the state worth testing.
-- =====================================================================
-- ★★★ THE BOSS HALF IS WIRED TO THE REAL LISTENER (RI-66, 2026-08-26)
-- =====================================================================
-- ★ Asserted where the binding is, not where the button is: the pane's job is to CONSUME
-- the watcher's fact, and the fact itself is graded in `smoke_bosswatch.lua`.
assert(NS.BossWatch, "the watcher is loaded, so the binding can reach it")

-- ⚠⚠ AND THE MODE IS ENTERED, because `refresh` returns early when its widgets are not
-- the live ones - so a smoke that never picks the tab grades every button's state against
-- a function that returned on its second line. ★ An author using the test drive is looking
-- at it; that is the state worth testing.
-- ☆ `Toggle` now SELECTS rather than shows, and the assertion reads the same because
-- `Drive.Shown` was re-pointed at the live mode - which is what every caller meant by it.
Drive.Toggle()
assert(Drive.Shown(), "the tab selects the drive mode")
Drive.Reoffer()

-- ★ AND THE SEAMS ARE CLEAR TOO. A sampler installed at Init would be a live client read
-- bound to a sensor nobody armed.
assert(Sensor.Sample == nil and Sensor.OnChange == nil,
       "A SEAM WAS INSTALLED AT Init: nothing is armed, so nothing may be wired")

-- =====================================================================
-- THE OFFER, AND THE CURSOR INTO IT
-- =====================================================================
local rid2 = assert(Routes.Create("Second route", W.mapID))
Drive.Reoffer()
assert(#Drive.Offered() == 2,
       "THE PANE OFFERS THE WRONG SET: `Manager.Offer` is `Routes.List` for THIS map and "
       .. "this pane adds nothing to it. got " .. #Drive.Offered())

-- ⚠ A ROUTE ON ANOTHER MAP IS NOT ON THE LIST. The offer and the build agree on the map
-- by two independent paths and this is the first of them.
Routes.Create("Elsewhere", 99)
Drive.Reoffer()
assert(#Drive.Offered() == 2,
       "A ROUTE FROM ANOTHER MAP WAS OFFERED: arming it would then fail at `Bucket.Build` "
       .. "with a message about a map the author never chose")

-- ★ THE CURSOR WRAPS, in both directions. An author cycling past the end of two routes
-- should land on the first, not stick.
local first = Drive.At()
Drive.Cycle(1); Drive.Cycle(1)
assert(Drive.At() == first, "THE CURSOR DID NOT WRAP: two steps through two routes is a "
       .. "full turn. got " .. tostring(Drive.At()))
Drive.Cycle(-1)
assert(Drive.At() ~= first, "the cursor steps backwards too")
Drive.Cycle(1)

-- =====================================================================
-- ★★★ THE FIRST DEPLOY'S ACTUAL FAILURE - a beacon with no R (2026-08-22)
--
-- Battlewrath, testing: *"beacon 1 R is not defined. Did not spawn a super tracker. Did
-- not poll. And arm didn't latch to live state."* ⟶ ONE cause, three consequences: the
-- build refused, so nothing armed, so nothing polled and no arrow was written.
--
-- ⚠⚠ AND THE PANE DID NOT SAY SO. The reason went to chat and the readout said *"not
-- armed"* - on the one surface whose job is answering *why did it not go*.
-- =====================================================================
local bare = assert(Routes.Create("No reach", W.mapID))
-- ★★★ PRE-DEFAULT DATA, AND THAT IS NOW THE ONLY THING A NIL RADIUS CAN MEAN.
--
-- ⚠ THIS FIXTURE USED TO NEED NO HELP: a minted beacon carried no radius, which is
-- exactly the state his first test drive hit. A10.3e-R now mints the standing R, so the
-- radius is CLEARED here on purpose - and clearing it is not a contrivance, it is what a
-- route saved before the default shipped looks like on disk. ★ The refusal exists for
-- precisely that data, which is why it must keep being graded.
local bareB = assert(Routes.AddBeacon(bare, { mapX = 0.5, mapY = 0.5, x = 500, y = 500,
                                              z = 0, mapID = W.mapID, floor = 6 }, 1))
bareB.radius = nil

Drive.Reoffer()
while Drive.AtId() ~= bare do Drive.Cycle(1) end
assert(Drive.Refusal(), "the check ahead asked `Bucket.Build` and got a reason")
assert(Drive.Refusal():find("radius", 1, true),
       "IT NAMES WHAT IS MISSING, not that something is: row 24 wants the refusal to say "
       .. "which node and which field. got " .. tostring(Drive.Refusal()))
assert(Drive.Readout():find("radius", 1, true),
       "THE READOUT DOES NOT CARRY THE REFUSAL. `not armed` is the symptom; the author "
       .. "needs the cause, and chat has scrolled by the time they look")
assert(Drive.RouteText():find("✗", 1, true),
       "THE LIST DOES NOT MARK AN UNDRIVABLE ROUTE: without it, finding out costs a press "
       .. "and a read of chat for every route on the map")

-- ⚠ AND PRESSING ARM ON IT CHANGES NOTHING BUT THE MESSAGE. The button must not go
-- live on a route that did not arm - that is the *didn't latch to live* half, and it is
-- the correct behaviour rather than the bug it looked like.
chat = {}
Drive.ToggleArm()
assert(not Manager.Running(), "a route that cannot build does not arm")
assert(Drive.Refusal(), "and the reason survives the press")
assert(said("radius"), "chat carries it too, in sequence with everything else")

-- ★★ THE REASON CLEARS WHEN THE THING IT IS ABOUT CHANGES, and not on a timer.
-- ⚠ CYCLED TO THE ROUTE WE KNOW BUILDS, not just one step on: the first cut stepped
-- once and landed on `Second route`, which has NO BEACONS and refuses for its own
-- perfectly good reason - so the row would have graded "cleared" against a value that
-- was correctly still set. ★ That a routeless route now marks itself is the feature
-- working, and it is why the step had to be to a NAMED good one.
while Drive.AtId() ~= rid do Drive.Cycle(1) end
assert(Drive.Refusal() == nil,
       "MOVING THE CURSOR TO A ROUTE THAT BUILDS LEFT THE OLD REFUSAL STANDING: the "
       .. "readout would then explain a route the author is no longer looking at")
assert(not Drive.RouteText():find("✗", 1, true), "and the mark goes with it")

-- =====================================================================
-- ★★ ARM - AND THE TWO SEAMS THE MANAGER DELIBERATELY LEAVES EMPTY
-- =====================================================================
while Drive.AtId() ~= rid do Drive.Cycle(1) end
Drive.ToggleArm()
assert(Manager.Running(), "THE ROUTE DID NOT ARM: " .. tostring(said("|r") or "(silent)"))

-- ★★★ THE FAILURE WITH NO SYMPTOM. Without the sampler the sensor polls nothing; without
-- `OnChange` it computes every transition and drops them. Either way the pane arms, the
-- readout draws, and the run never advances - with no error anywhere.
-- ★★★ ONE WRITER PER FIELD (AL-72, §741) — the door OBSERVES, it does not install.
--
-- ⚠⚠ This door used to set `Sensor.OnChange` itself, wrapping `Manager.OnPoll` and a redraw.
-- §735 gave the manager its own installer and the pair became TWO WRITERS, last one winning -
-- which cost a mutation row its bite. AL-72 ruled the seam one level higher.
assert(Sensor.OnChange == Manager.OnPoll,
       "THE DOOR IS STILL INSTALLING THE SENSOR'S FIELD: AL-72 gives `Sensor.OnChange` to the "
       .. "MANAGER and puts the door downstream on the callback bus. Two writers on one field "
       .. "is last-one-wins, and it already cost a mutation row its bite")
assert(type(Manager.RegisterCallback) == "function",
       "THE MANAGER HAS NO CALLBACK BUS: AL-72 has the door observe the manager, which "
       .. "re-emits on `CallbackHandler` - USED, not rebuilt (AL-46's Ace posture)")

assert(Sensor.Sample == NS.Driver.Sample,
       "THE SAMPLER SEAM IS EMPTY: `manager.lua` does not install one on purpose (it "
       .. "would make the file ungradable offline), so the DOOR must - and an armed "
       .. "sensor with no sampler reads nothing forever, silently")
assert(type(Sensor.OnChange) == "function",
       "THE TRANSITIONS HAVE NO CONSUMER: `Sensor.Poll` returns the changed list and "
       .. "`Sensor.OnUpdate` hands it to `Sensor.OnChange`. Unset, every transition the "
       .. "sensor computes is discarded and the run cannot advance")

-- ★ NOW the words are bound, and only now.
assert(Manager.Bound("note") and Manager.Bound("say") and Manager.Bound("boss"),
       "arming binds all three words - the arm gate refuses a route whose rows name one "
       .. "that has no callable")

-- =====================================================================
-- ★★★ THE READOUT IS THE IN SET BY ADDRESS - A10.5's own mutation is `stage` alone
-- =====================================================================
local armed = assert(Sensor.Armed(), "the re-armed sensor holds the new list")
local n1 = nodeAt(armed.nodes, a1)
assert(n1, "the first beacon's child is armed")

-- ★★★ THE WHOLE WIRE, SAMPLE TO DISPATCH - driven from `Sensor.OnUpdate`, which is
-- the client's actual edge.
--
-- ⚠⚠ ASSERTING THE SEAM IS INSTALLED IS NOT ASSERTING THE SENSOR CALLS IT, and that
-- distinction is the whole reason this row exists: `Sensor.Poll` RETURNED the changed list
-- all along and `OnUpdate` dropped it on the floor. Every seam check above would have
-- passed against that code. ⟶ Only running the frame handler finds it.
chat = {}
local sampled = 0
local realSample = Sensor.Sample
Sensor.Sample = function() sampled = sampled + 1; return
    { x = 110, y = 200, z = 0, mapID = W.mapID } end
Sensor.OnUpdate(nil, 10)
assert(sampled > 0, "the frame handler asked the sampler for a position")
assert(said("note") or said("pull the left patrol"),
       "THE TRANSITION NEVER REACHED THE MANAGER. `Sensor.OnUpdate` computes the changed "
       .. "list and must hand it to `Sensor.OnChange` - without that line the sensor runs "
       .. "at full rate, finds every transition, and DISCARDS them: armed, sampling, and "
       .. "unable to advance anything, with no error at any point. Said: "
       .. tostring(#chat) .. " line(s)")
Sensor.Sample = realSample

-- ⚠ AND THE RUN IS RE-ARMED FROM SCRATCH, because the row above ADVANCED it - the note
-- fired, the ordinal ran dry and the stage moved. ★ That is the row succeeding, and a
-- later block asserting against stage 1 would be asserting against a run this one used up.
Drive.ToggleArm(); Drive.ToggleArm()
assert(Manager.Stage() == 1, "re-armed at the first stage")

-- Walk the player into it through the SENSOR, not by poking the manager - the point is
-- that the whole wire carries, sample to dispatch.
Sensor.Poll({ x = 100 + 10, y = 200, z = 0, mapID = W.mapID })
local text = Drive.Readout()
assert(text:find(n1.address, 1, true),
       "THE READOUT DOES NOT NAME THE ADDRESS THE PLAYER IS IN. A10.5a: *the set of "
       .. "addresses the player is IN per sample*, and its mutation is *expose `stage` "
       .. "alone -> fails*. A stage number says the run moved; it cannot say why it did "
       .. "not. got: " .. text)
assert(text:find("stage", 1, true) and text:find("step", 1, true),
       "the readout carries stage and step as WELL as the in set, not instead of it")

-- ★ THE ROUTE LINE SHOWS THE NAME, NOT THE RID. An author picked the route by name and
-- a pane that shows `1` has made them look it up.
assert(Drive.RouteText():find("Drive test", 1, true),
       "THE PANE SHOWS THE ROUTE ID INSTEAD OF ITS NAME. got " .. Drive.RouteText())

-- =====================================================================
-- ★★ THE PENDING BOSS TAB, AND THE BUTTON THAT PLAYS THE KILL
-- =====================================================================
Manager.SetStage(2)
armed = Sensor.Armed()
local n2 = nodeAt(armed.nodes, a2)
assert(n2, "stage 2 armed its beacon's child")

Manager.OnPoll({ { address = n2.address, word = Sensor.WHEN_ON, node = n2 } })
assert(Drive.Waiting() == 1,
       "THE BOSS TAB DID NOT PARK: a `boss` callable returns FALSE - A12.4c, the tab is "
       .. "done when the boss dies, not when it ran - so the ctx must be held for the "
       .. "thing that completes it later. got " .. Drive.Waiting())
assert(Drive.Readout():find("waiting", 1, true),
       "AND THE PANE SAYS SO. A run stalled on a pending tab looks identical to one "
       .. "stalled on a bug unless the readout names what it is waiting on")

-- ★★★ A6.2 - THE KILL ALONE SATISFIES, AND IT ARRIVES FROM THE CLIENT.
-- *"emit the named `UNIT_DIED` with the child's sense HOLDING and no engage token ever
-- seen -> the boss tab completes."* ⚠ The arming witness is the player's SENSE holding
-- (A3.5); engage is at most a driver-side arm and NEVER a required author witness - so
-- nothing below sees an engage, deliberately.
-- ⟶ This is the half `Drive.BossDown()` could never prove: pressing a button tests the
-- override, not the listener.
local watchName = n2.node and n2.node.arg
assert(NS.BossWatch.Armed() >= 1,
       "THE PARKED TAB ARMED NO LISTENER: parking without arming is the old fake with a "
       .. "new file beside it - the tab would wait forever for a button")

NS.BossWatch.Died(NS.BossWatch.Names()[1])
assert(Drive.Waiting() == 0,
       "THE KILL DID NOT COMPLETE THE TAB: A6.2 rules the kill alone satisfies while the "
       .. "sense holds, and this one arrived the way the client sends it")
assert(NS.BossWatch.Armed() == 0,
       "and the listener went with the row - a boss killed again later must not complete "
       .. "a tab nobody is standing in (A12.4c)")

-- ⚠ OLDEST FIRST, and it is measured rather than asserted about one item. Two rooms both
-- reached is a real shape, and completing the newest makes the button's effect depend on
-- arrival order in a way nobody can see on the pane.
-- ★ TWO ROOMS, TWO NODES. ⚠ NOT the same node twice: its row's `once` latch is spent
-- the moment the first kill completed it, so a second poll of `n2` parks nothing - which
-- is the latch working, and would have made this row assert about the wrong thing.
local function room(tag)
    return { address = n2.address .. "#" .. tag,
             rows = { { sense = Sensor.WHEN_ON, action = "boss", arg = "Boss " .. tag } } }
end
local roomA, roomB = room("A"), room("B")
Manager.OnPoll({ { address = roomA.address, word = Sensor.WHEN_ON, node = roomA } })
Manager.OnPoll({ { address = roomB.address, word = Sensor.WHEN_ON, node = roomB } })

-- ★★ TWO PARKED ROWS, TWO ARMED NAMES - and this is where the BUTTON's own disarm is
-- graded. After a real kill the watch has already dropped the name; after a BUTTON press
-- nothing has, so an override would otherwise leave a listener armed for a finished row.
-- ⚠ And it must take the RIGHT one: completing by name is why two parked bosses cannot
-- cross-complete, which would advance a stage the reader is not standing in - the silent
-- failure A6.2 names in its own ⟶ line.
assert(NS.BossWatch.Armed() == 2, "both rooms armed their own name")
assert(Drive.Waiting() == 2,
       "TWO ROOMS BOTH REACHED IS A REAL SHAPE and both tabs must park. got "
       .. Drive.Waiting())

chat = {}
Drive.BossDown()
assert(Drive.Waiting() == 1, "one kill completes exactly one tab")
assert(said("kill"), "and the pane says which one died")

-- ⚠⚠ OLDEST FIRST, MEASURED. Completing the NEWEST makes the button's effect depend
-- on arrival order in a way nobody can see on the pane - two identical *Boss down*
-- presses would close the rooms in the reverse of the order they were entered.
assert(said("Boss A") and not said("Boss B"),
       "THE NEWEST TAB WAS COMPLETED FIRST. Room A was entered first, so the first "
       .. "*Boss down* must close A - otherwise two identical presses close the rooms in "
       .. "the reverse of the order they were reached, and nothing on the pane says so")

-- ★★ AND THE BUTTON TOOK ITS OWN LISTENER WITH IT, leaving the OTHER room's armed. This
-- is the case that leaks: after a real kill the watch has already dropped the name, so
-- only an override can leave one armed for a row that is finished.
assert(NS.BossWatch.Armed() == 1,
       "THE OVERRIDE LEFT A LISTENER BEHIND: pressing *Boss down* completed room A, so "
       .. "A's listener must go with it - one armed name should remain, for room B. got "
       .. NS.BossWatch.Armed())
assert(NS.BossWatch.Armed("Boss B") == true, "and the one left is the room still open")

chat = {}
Drive.BossDown()
assert(said("Boss B") and Drive.Waiting() == 0, "and the second press closes B")

-- =====================================================================
-- ★★ STOP CLEARS BOTH SEAMS. S9: *nothing armed, nothing RUNNING*.
-- =====================================================================

-- ⚠⚠ ONE TAB LEFT PARKED ON PURPOSE, and mutation is why. The FIFO row above drains
-- `waiting` to zero, so the *a pending tab does not survive the stop* assertion below had
-- NOTHING TO CLEAR - break the line it grades and the suite still passed. ★ A fixture that
-- cannot reach a guard's failure case is the commonest yield of a mutation run.
Manager.OnPoll({ { address = roomA.address .. "!", word = Sensor.WHEN_ON,
                   node = room("C") } })
assert(Drive.Waiting() == 1, "a tab is parked going into the stop")

Drive.ToggleArm()
assert(not Manager.Running(), "the second press stops it")
assert(Sensor.Sample == nil and Sensor.OnChange == nil,
       "A SEAM SURVIVED THE STOP: a live sampler bound to a disarmed sensor is the same "
       .. "half-state as a persistent OnUpdate that checks a flag, and it is the one S9 "
       .. "names")

-- ★★★ AND THE CLEU LISTENER IS THE THIRD SEAM, added with it (RI-66, 2026-08-26). A run
-- that stopped with names still armed leaves a boss killed afterwards completing a tab in
-- a route nobody is driving - which then reads as the route having run ahead, the silent
-- failure A6.2 names. ⚠ It is the seam most likely to be forgotten, because unlike the
-- other two it lives in another file.
assert(NS.BossWatch.Armed() == 0,
       "A CLEU LISTENER SURVIVED THE STOP: " .. NS.BossWatch.Armed() .. " name(s) still "
       .. "armed against a run that is over")
assert(NS.BossWatch.Listening() == false, "and nothing is listening")
assert(Drive.Waiting() == 0,
       "A PENDING BOSS TAB SURVIVED THE STOP: its ctx closes over a bucket that no "
       .. "longer exists, and the button would complete a tab in a torn-down run")

-- =====================================================================
-- THE DEBUG LOG BUTTON
-- =====================================================================
chat = {}
Drive.ToggleLog()
assert(Log.Running(), "the log button starts a run")
assert(Log.Name():find("@", 1, true),
       "THE NAME IS DERIVED FROM ROUTE AND MAP: AL-25 accepts a client-only seam on THE "
       .. "LOG OF A NAMED TEST RUN, and a run named `test` cannot be cited. got "
       .. tostring(Log.Name()))

Log.Count("dispatch.note"); Log.Count("dispatch.note")
Log.Poll(CLOCK); CLOCK = CLOCK + 4; Log.Poll(CLOCK)
chat = {}
Drive.ToggleLog()
assert(not Log.Running(), "the second press stops it")
assert(said("poll"), "THE REPORT WAS NOT SHOWN: `DebugLog.Report` RETURNS DATA AND NEVER "
       .. "PRINTS - *who shows it is the caller's* - so a caller that forgets to shape it "
       .. "stops the log and shows nothing at all")
assert(said("dispatch.note"),
       "THE BUCKETS WERE NOT SHOWN: the counts are the noisy path's whole record")

-- ⚠ AND STOPPING A LOG THAT IS NOT RUNNING SAYS SO rather than erroring on a nil report.
chat = {}
Drive.ToggleLog(); Drive.ToggleLog()
assert(not Log.Running(), "back to stopped")

-- =====================================================================
-- ★★ THE GEOMETRY, ASSERTED. §144 shipped a six pixel overlap found by eye.
-- =====================================================================
local overlaps = F.OverlapsTree(UIParent)
for _, o in ipairs(overlaps) do
    assert(not (tostring(o.a or ""):find("Drive") or tostring(o.b or ""):find("Drive")),
           "TWO CONTROLS ON THE TEST DRIVE PANE OVERLAP. Two identical 3-slice buttons do "
           .. "not read as an overlap - they read as ONE button with a missing end cap, "
           .. "which is exactly how §144 shipped: " .. tostring(o.a) .. " / " .. tostring(o.b))
end
local clipped = F.Containment(UIParent)
for _, c in ipairs(clipped) do
    assert(not tostring(c.name or ""):find("Drive"),
           "A CONTROL HANGS OUTSIDE THE TEST DRIVE PANE: " .. tostring(c.name))
end

print("smoke_drive: OK - the seams, the bindings, the in-set readout, the boss FIFO, "
      .. "the log report and the geometry")
