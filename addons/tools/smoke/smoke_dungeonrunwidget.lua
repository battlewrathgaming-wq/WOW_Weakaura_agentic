-- Offline smoke for COA_DungeonRun widget.lua - THE REMOTE'S TWO-MODE FOLD (AL-49/AL-50).
--
-- ★★ IT BUILDS THE REAL THING, on the same footing as `smoke_dungeonrunoptions.lua`: the
-- shipped lite Ace3, the client's frame templates, the client's FrameXML, under lua51.
--
-- ⚠⚠ WHY THIS SMOKE IS SEPARATE FROM `smoke_dungeonrun.lua`. That one runs on a thin
-- hand-written CreateFrame stub, which is right for capture/store logic and CANNOT host
-- AceGUI - the library asks a frame far more than that stub answers. When the remote's
-- controls became Ace widgets, its pin assertion there stopped reaching anything.
-- ★ THE LESSON, and it is the reason this file exists rather than a deleted assertion:
-- an offline probe run WITHOUT the libs present proved nothing and said it passed -
-- `LibStub` was absent, `gui()` returned nil, the strip was nil, and every guard skipped.
-- A harness that cannot reach the subject must FAIL, not pass quietly.
--
-- Run: .tools/lua51/lua5.1.exe addons/tools/smoke/smoke_dungeonrunwidget.lua

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\]]
local ADDON = ROOT .. [[addons\COA_DungeonRun\]]
local LIBS = ADDON .. [[Libs\]]
local SMOKE = ROOT .. [[addons\tools\smoke\]]

local F = assert(loadfile(SMOKE .. [[frames.lua]]))()

local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }
UIParent = F.New("UIParent")
F.SetRoot(UIParent, 1024, 768, 0, 0)
function CreateFrame(_, name, parent, template)
    return F.New(name, parent or UIParent, template)
end
function GetTime() return 100.0 end
function time() return 1700000000 end

-- ⚠ THE CLIENT'S OWN `PlaySound` CALLS `_PlaySound`, and AceGUI's Button calls PlaySound on
-- every click. Left unstubbed the door assertions die inside FrameXML with an error about
-- a global this addon never mentions - a harness gap wearing an addon bug's clothes.
function _PlaySound() end
function geterrorhandler() return function(e) error(e, 0) end end
function wipe(t) for k in pairs(t) do t[k] = nil end return t end
table.wipe = wipe
strmatch, strfind, strsub, strlower, strupper, strrep, strbyte, strchar =
    string.match, string.find, string.sub, string.lower, string.upper, string.rep,
    string.byte, string.char
format, gsub = string.format, string.gsub
tinsert, tremove, sort, getn = table.insert, table.remove, table.sort, table.getn
max, min, floor, ceil, abs, mod =
    math.max, math.min, math.floor, math.ceil, math.abs, math.fmod
function strtrim(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end
function hooksecurefunc(a, b, c)
    local t, k, post = a, b, c
    if type(a) == "string" then t, k, post = _G, a, b end
    local orig = t[k]
    t[k] = function(...) local r = orig and orig(...); post(...); return r end
end
C_Timer = { After = function(_, fn) if fn then fn() end end,
            NewTicker = function() return { Cancel = function() end } end }
GameFontHighlight = F.New("GameFontHighlight")
GameFontHighlightSmall = F.New("GameFontHighlightSmall")

-- The world the capture layer reads. Held minimal: this smoke's subject is the FOLD,
-- and capture's own behaviour is asserted where it belongs, in `smoke_dungeonrun.lua`.
local WORLD = { x = 100, y = 200, z = 30, mapID = 389, combat = false, instance = true }
function UnitName() return "Gravekeeper" end
function UnitAffectingCombat() return WORLD.combat end
function UnitIsGhost() return false end
function UnitIsDeadOrGhost() return false end
function UnitExists() return nil end
function IsInInstance() return WORLD.instance, "party" end
function GetCurrentPlayerPosition() return WORLD.x, WORLD.y, WORLD.z, WORLD.mapID end
function GetRealZoneText() return "Ragefire Chasm" end
function GetSubZoneText() return "The Molten Span" end
function GetPlayerMapPosition() return 0.42, 0.61 end
function GetInstanceInfo() return "Ragefire Chasm", "party", 2, "Heroic", 5, 0, false, 389 end
function GetDifficultyInfo(i) return ({ [1] = "Normal", [2] = "Heroic" })[i] end
function GetCurrentMapContinent() return 1 end
function GetCurrentMapZone() return 17 end
function GetCurrentMapDungeonLevel() return 3 end
function GetMapInfo() return "Ragefire", 668, 768 end
function SetMapToCurrentZone() end
WorldMapFrame = { IsShown = function() return false end }
AscensionUI = nil

local FX = assert(loadfile(SMOKE .. [[framexml.lua]]))()
FX.MakeFrame = function(n) return F.New(n) end
FX.Load()

local ACE = assert(loadfile(SMOKE .. [[ace_stack.lua]]))()
ACE.Load(LIBS)

-- ★★★ THE HARNESS PROVES ITSELF BEFORE IT PROVES ANYTHING ELSE. If AceGUI is not really
-- here, every assertion below passes for the wrong reason - the widget's own `gui()` guard
-- would return nil and it would build no strip, no host and no controls, silently.
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
assert(AceGUI, "ACEGUI IS NOT LOADED: every assertion in this file would then be testing "
       .. "the widget's nil-guard rather than its content, and would PASS")
assert(AceGUI:Create("TabGroup"), "the TabGroup widget type is not registered")

local NS = {}
NS.Say = function(m) DEFAULT_CHAT_FRAME:AddMessage(m) end
local function ours(f) assert(loadfile(ADDON .. f))("COA_DungeonRun", NS) end
ours("store.lua")
ours("routes.lua")
ours("capture.lua")
ours("widget.lua")

-- The doors the Run mode offers. Recorded rather than stubbed silently, so the button
-- assertions can prove the door OPENS rather than merely existing.
local opened = {}
NS.Options = { Toggle = function() opened.options = (opened.options or 0) + 1 end }
NS.Map = { Toggle = function() opened.map = (opened.map or 0) + 1 end }

local Store, Capture, Widget = NS.Store, NS.Capture, NS.Widget
assert(Store.Load(), "the store loads fresh")
Capture.Init()

local f = Widget.Init()
assert(f, "the remote returns its frame")

-- =====================================================================
-- ★ THE FRAME IS OURS, THE CONTENT IS ACE'S (his, 2026-08-25; `pane-build` law 4)
-- =====================================================================
assert(f:GetWidth() == 240, "the remote is 240 wide, got " .. tostring(f:GetWidth()))

-- ⚠ THE HEIGHT MUST HOLD WHAT IS IN IT. 124 was the hand-placed layout's number and the
-- strip alone is 37 - a frame left at 124 renders content outside its own backdrop, which
-- is exactly the fault a human found on a screenshot at §144 and nothing caught.
-- ★★ AND IT IS SIZED TO THE TALLER MODE, not resized per tab. `DR_Pane_2`: the pane keeps
-- its identity, its position and its SIZE across a swap. A remote that grew and shrank as
-- tabs were picked would move every control under the cursor for a reason nobody chose.
assert(f:GetHeight() == 197,
       ("THE REMOTE CANNOT HOLD ITS OWN CONTENT: %d tall, and 8 pad + 37 strip + 4 + 140 "
        .. "page + 8 pad needs 197"):format(f:GetHeight()))

-- =====================================================================
-- ★★ THE STRIP IS THE TITLE (his, 2026-08-25: "The strip is self descriptive")
-- =====================================================================
assert(Widget.CurrentMode() == "run",
       "the remote opens on capture, got " .. tostring(Widget.CurrentMode()))

-- ⚠ ASSERTED ON THE REGISTRY, NOT ON A LOCAL. `remote.title` was RETIRED with the heading;
-- a smoke still reading it would be asserting a key nothing publishes.
local reg = NS.UI and NS.UI.Registry and NS.UI.Registry()
if reg then
    assert(reg["remote.title"] == nil,
           "remote.title is RETIRED - the strip says what the heading said")
end

-- =====================================================================
-- ★★★ THE MODE'S CONTROLS ARE ACEGUI WIDGETS, and none of them carries an x or a y
-- =====================================================================
local W = Widget.W
assert(W, "the remote publishes its live mode's widgets")
for _, k in ipairs({ "pin", "name", "count", "options", "map", "arm" }) do
    assert(W[k], "THE RUN MODE IS MISSING `" .. k .. "`: his allocation names capture's "
           .. "controls, the run name field, its arm, and the door to the map")
    assert(W[k].frame, k .. " is not an AceGUI widget - law 4 gives the content to Ace")
end

-- ★ DISABLED, NOT HIDDEN, when unarmed. Disabled says "this exists and needs a run";
-- hidden says nothing at all. Carried across the fold unchanged, which is the point:
-- the rule is about MEANING and survived the library change.
Capture.Stop()
Widget.Refresh()
assert(W.pin.disabled == true,
       "UNARMED PIN: the button must go DISABLED, not stay live over a run that does "
       .. "not exist")

chat = {}
assert(Widget.Pin() == nil, "and pressing it then does nothing but say why")
local said = false
for _, m in ipairs(chat) do if m:find("could not pin", 1, true) then said = true end end
assert(said, "it must SAY why rather than swallowing the press")

W.name:SetText("harness run")
Capture.Arm("harness run")
Widget.Refresh()
assert(W.pin.disabled == false, "ARMED PIN: a live run re-enables it")
assert(W.name.disabled == true,
       "THE NAME LOCKS AT CAPTURE: renaming mid-run would leave the record disagreeing "
       .. "with what the operator saw when they armed it")

-- =====================================================================
-- ★★★ THE SWITCH IS A TEARDOWN, NOT A TOGGLE (`pane-build` law 2)
-- =====================================================================
-- ⚠ THE BUILDER KEEPS THE HOST. Without a handle on the container, this file cannot
-- COUNT what is in it - and a teardown that does not happen is invisible from `W` alone.
local BUILT, HOST = 0, nil
assert(Widget.Mount("harness", "Harness", function(h)
    BUILT = BUILT + 1
    HOST = h
    local g = LibStub("AceGUI-3.0")
    local lbl = g:Create("Label")
    lbl:SetText("harness mode")
    Widget.W.probe = lbl
    h:AddChild(lbl)
end) == "harness", "a mode can be mounted from outside the remote")

assert(Widget.Mode("harness") == "harness", "and entered")
assert(BUILT == 1, "entering a mode BUILDS it, got " .. BUILT .. " build(s)")

-- ★★★ THE TEARDOWN IS COUNTED, NOT INFERRED. `pane-build` law 2 is about what is IN the
-- container, and `W` cannot see that: `W` is reset by a different line. ⟶ Without
-- `ReleaseChildren` the run mode's seven controls are still here beneath the harness label,
-- rendering, holding the space law 8 says belongs to the CURRENT content.
assert(HOST and HOST.children, "the host is an AceGUI container and reports its children")
assert(#HOST.children == 1,
       ("THE OUTGOING MODE WAS NOT TORN DOWN: the host holds %d children and the harness "
        .. "mode built exactly ONE. The rest are the run mode's, still rendering under it")
       :format(#HOST.children))

-- ⚠ THE REFS GO WITH THE WIDGETS. A stale `W` is the exact state the teardown removes,
-- arriving through the back door - and it reads as correct until something writes to a
-- released widget that another mode is now using from the pool.
assert(Widget.W.pin == nil,
       "THE OUTGOING MODE'S REFS MUST GO: `W` names the LIVE mode's controls, and a pin "
       .. "reference surviving into the harness mode is a handle on a POOLED widget")
assert(Widget.W.probe, "and the incoming mode's refs are there")

-- ★ A refresh arriving while capture is not on screen must find nothing to write to
-- rather than reaching for a released widget.
Widget.Refresh()

assert(Widget.Mode("run") == "run", "and back")
assert(Widget.W.pin, "re-entry REBUILDS rather than restoring - the controls are here again")
assert(Widget.W.probe == nil, "and the harness mode's are not")
assert(#HOST.children > 1,
       "and the run mode's controls are the ones in the host now, got "
       .. #HOST.children)

-- ⚠ RE-ENTERING THE LIVE MODE IS A NO-OP. `TabGroup:SelectTab` fires `OnGroupSelected`
-- synchronously, so `Restrip` re-enters `Mode` with the key already live; without the
-- guard that tears down content mid-build.
-- ⚠⚠ ASSERTED ON THE BUILD COUNT, NOT ON A WIDGET HANDLE. A first cut compared
-- `Widget.W.pin` before and after and PASSED with the guard removed: AceGUI POOLS, so the
-- rebuild released the button and `Create("Button")` handed the very same object straight
-- back. ⟶ The pool makes handle identity say nothing about whether a rebuild happened.
local wasBuilt = BUILT
Widget.Mode("harness")
assert(BUILT == wasBuilt + 1, "entering the harness mode builds it")
Widget.Mode("harness")
assert(BUILT == wasBuilt + 1,
       ("RE-ENTRY LOOP: selecting the tab already selected must not rebuild - `SelectTab` "
        .. "fires `OnGroupSelected` synchronously, so `Restrip` re-enters `Mode` with the "
        .. "live key and would tear down content mid-build. Built %d time(s), expected 1")
       :format(BUILT - wasBuilt))
Widget.Mode("run")

-- =====================================================================
-- ★ THE DOORS OPEN. A button that exists and does nothing is worse than no button.
-- =====================================================================
Widget.W.options.frame:GetScript("OnClick")(Widget.W.options.frame)
Widget.W.map.frame:GetScript("OnClick")(Widget.W.map.frame)
assert(opened.options == 1, "the options door opens the unified pane")
assert(opened.map == 1, "the map door opens the map")

-- =====================================================================
-- ★★★ THE SECOND MODE - the test drive is a TAB now, not a door (AL-49/AL-50)
-- =====================================================================
-- ☆ The run mode's temporary `drive` BUTTON is gone, and its absence is ASSERTED rather
-- than assumed: a door left beside the tab that replaced it is two ways into one room, and
-- the one nobody maintains is the one that rots.
assert(Widget.W.drive == nil,
       "THE TEMPORARY DOOR MUST GO WITH THE FOLD: the tab is the way in now, and a button "
       .. "beside it is a second door to one room")

ours("drive.lua")
local Drive = NS.Drive
assert(Drive.Init() == "drive", "drive MOUNTS itself rather than building a pane")

-- ⚠ IT MOUNTS, IT DOES NOT ENTER. Mounting is a registration; the author picks the tab.
assert(Widget.CurrentMode() == "run", "mounting a mode does not steal the live one")

assert(Widget.Mode("drive") == "drive", "and the tab enters it")
local DRIVE_CONTROLS = { "prev", "route", "next", "arm", "boss", "log", "state" }
for _, k in ipairs(DRIVE_CONTROLS) do
    assert(Widget.W[k], "THE DRIVE MODE IS MISSING `" .. k .. "`: the cursor, its arm, the "
           .. "boss latch, the log and the readout are what the mode IS")
    assert(Widget.W[k].frame, k .. " is not an AceGUI widget")
end

-- ★ NO FRAME OF ITS OWN. The whole point of the fold: `COA_DungeonRunDrive` is retired,
-- and a stray global frame would be the old pane still built beside the new tab - invisible
-- to a smoke that only checked the tab was there.
assert(_G.COA_DungeonRunDrive == nil,
       "THE DRIVE PANE IS RETIRED: a second frame beside the remote is exactly what the "
       .. "fold removed")

-- ★★ THE CLOSE BUTTON WENT WITH THE PANE. A mode is left by picking the other tab; a
-- Close inside a tab would shut the whole remote, which is not what the word said.
assert(Widget.W.close == nil, "a tab has no Close of its own")

-- Leaving and re-entering rebuilds, same as any mode - `DR_Pane_2` applies here too.
Widget.Mode("run")
assert(Widget.W.pin, "the run mode is back")
assert(Widget.W.route == nil, "and the drive mode's refs went with it")
Widget.Mode("drive")
assert(Widget.W.route, "and the drive mode rebuilds on re-entry")

-- ★ `Drive.Shown` NOW MEANS *is drive the live mode*, which is what every caller asked.
-- ⚠ The old answer could be TRUE for a drive pane sitting open behind the remote; the new
-- one cannot, because the strip has exactly one tab selected.
assert(Drive.Shown() == true, "Drive.Shown reads the live mode")
Widget.Mode("run")
assert(Drive.Shown() == false, "and is false when another mode is up")

-- ⚠ A POLL ARRIVING WHILE ANOTHER MODE IS UP MUST FIND NOTHING TO WRITE TO. This is the
-- guard that replaced `if not f:IsShown()`, and it is a CORRECTNESS guard now rather than
-- only a cheapness one: drive's widgets are back in the pool and another mode may hold them.
-- ⚠ WRAPPED, so the guard has a MESSAGE rather than a raw Lua error. A crash is a failure
-- either way, but a mutation row cannot bite on its own message against
-- "attempt to index field 'route'" - and a guard with no message of its own is one nobody
-- can tell apart from the next crash in the same file.
-- ★★★ AND THE OBSERVABLE IS THE WHOLE MODE, NOT ONE CONTROL. A stale write does not error
-- - `SetText` on a released widget succeeds. It lands on whatever holds that widget NOW,
-- because `ReleaseChildren` POOLS and `Create` hands the same objects straight back.
-- ⚠ A first cut watched `pin` alone and stayed SILENT: the corruption is real and landed
-- on a different control, because which pooled object each `Create` receives is not
-- something the caller chooses. ⟶ Snapshot every text in the live mode and compare the
-- lot. Nothing legitimately writes to them here, so ANY difference is the stale write.
local snap = {}
for k, w in pairs(Widget.W) do
    local t = w.text or w.label
    snap[k] = t and t:GetText() or false
end
Drive.Reoffer()
local pollOk, pollErr = pcall(Drive.Refresh)
for k, was in pairs(snap) do
    local w = Widget.W[k]
    local t = w and (w.text or w.label)
    local now = t and t:GetText() or false
    assert(now == was,
           ("A STALE MODE WROTE INTO A POOLED WIDGET: the run mode's `%s` read `%s` and "
            .. "now reads `%s` - the drive mode writing through a `W` it captured before "
            .. "the swap"):format(k, tostring(was), tostring(now)))
end
assert(pollOk, "A POLL WHILE ANOTHER MODE IS UP MUST BE A NO-OP: refresh reached for a "
       .. "widget AceGUI has already returned to its pool - " .. tostring(pollErr))

-- ☆ Toggle is KEPT and now selects, because every existing caller and smoke uses that shape.
Drive.Toggle()
assert(Widget.CurrentMode() == "drive", "Toggle selects the drive tab")
Drive.Toggle()
assert(Widget.CurrentMode() == "run", "and toggles back rather than closing anything")

-- ★★★ THE REMEMBERED MODE SURVIVES A LATE MOUNT. `core.lua` runs `Widget.Init` before
-- `Drive.Init`, so an author who left the remote on `drive` returns to a mode whose builder
-- does not exist yet. The MOUNT is where that becomes possible, so it is where it happens.
Widget.Mode("drive")
assert(Store.GetUI().remoteMode == "drive", "the live mode is remembered")

-- ⚠⚠ AND THE LATE MOUNT IS EXERCISED, not merely described. A first cut asserted only that
-- `Widget.Mode` writes `remoteMode` - a different guard, already covered - so breaking the
-- late-mount branch changed nothing and the row read SILENT.
-- ★ THE FIXTURE: sit on `run` while the store remembers `drive`, then MOUNT drive again.
-- Re-mounting is the same call `core.lua` makes when `drive.lua` loads after `widget.lua`,
-- and it is the only moment at which the remembered mode becomes reachable.
Widget.Mode("run")
Store.SetUI("remoteMode", "drive")
assert(Widget.CurrentMode() == "run", "the fixture starts on the other mode")
-- ★ `Drive.Init()` IS the mount, so re-running it is the real path rather than a stand-in
-- builder that would prove the branch fires and not that it fires for the right thing.
assert(Drive.Init() == "drive", "the mount is drive's own Init")
assert(Widget.CurrentMode() == "drive",
       "A LATE MOUNT MUST HONOUR THE REMEMBERED MODE: `core.lua` builds the remote BEFORE "
       .. "drive.lua loads, so an author who left it on the test drive returns to a mode "
       .. "whose builder did not exist yet - and the mount is the moment that changes")

print("smoke_dungeonrunwidget: OK")
