-- Offline smoke for task_unitstate: drives the three manoeuvres against stubs and
-- asserts the probe captures what each question needs, and that the SELF-ARGUMENTS
-- actually fire when the stubs are made to lie.
--
--   1) the z datum        stand-then-swim on one spot
--   2) the height         ankles / hips / head, with the breath timer as the trigger
--   3) the jump apex      a window with IsFalling edges and a z peak inside them
--
-- ★ AND THE POINT OF THE TASK IS TESTED DIRECTLY: a state that contradicts itself
-- must be RECORDED as a disagreement. So the stubs are deliberately made to lie -
-- swimming at run speed, indoors AND outdoors - and the smoke asserts the checks
-- catch it. A probe whose cross-checks cannot fail is not a cross-check.
--
-- ⚠ Plus the two things that would silently ruin a live run: the widget's EditBox
-- must be NAMED (InputBoxTemplate anchors by name), and the OnUpdate must be
-- cleared on stop (zero persistent OnUpdate - ROUTER's culture list).
local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }
date = os.date
local now = 100.0
function GetTime() return now end
function GetAddOnMetadata() return "2.2.0" end
function GetRealmName() return "Vol'jin" end
function GetRealZoneText() return "Durotar" end
function GetSubZoneText() return "" end
function GetPlayerFacing() return 1.57 end
function GetMapInfo() return "Durotar" end
function GetCurrentMapAreaID() return 14 end
function GetCurrentMapDungeonLevel() return 0 end
function GetCurrentMapZone() return 1 end
function GetCurrentMapContinent() return 1 end
function UnitLevel() return 80 end
function UnitFactionGroup() return "Horde" end
function UnitClass() return "Necromancer", "NECROMANCER" end
function UnitName() return "Gravereaper" end
function UnitRace() return "Forsaken", "Scourge" end
function UnitSex() return 3 end
function UnitHealth() return 100 end
function UnitHealthMax() return 100 end

-- the mutable world the manoeuvres drive
local W = {
    x = 10, y = 20, z = 5.0, m = 1,
    speed = 0,
    -- ⚠ 1 not true, deliberately: this fork returns 1 where retail returns true and
    -- the probe must record the TYPE rather than coerce it
    swimming = nil, falling = nil, mounted = nil,
    indoors = nil, outdoors = 1,
    breath = nil,
}
function GetCurrentPlayerPosition() return W.x, W.y, W.z, W.m end
function GetPlayerMapPosition() return 0.55, 0.42 end
function GetUnitSpeed() return W.speed end
function IsSwimming() return W.swimming end
function IsFalling() return W.falling end
function IsFlying() return nil end
function IsMounted() return W.mounted end
function IsStealthed() return nil end
function IsIndoors() return W.indoors end
function IsOutdoors() return W.outdoors end
function IsResting() return nil end
function UnitOnTaxi() return nil end
function UnitInVehicle() return nil end
function UnitAffectingCombat() return nil end
function UnitIsDeadOrGhost() return nil end
function GetMirrorTimerInfo()
    if not W.breath then return nil end
    return "BREATH", 60000, 60000, -1, 0, "Breath"
end
function GetMirrorTimerProgress() return W.breath end
-- ★ UnitPosition deliberately ABSENT, which is the state the census claims and the
-- probe must record as such rather than crash on.
UnitPosition = nil

local named, ticker = {}, nil
function CreateFrame(kind, name, parent, template)
    local f = { scripts = {}, kind = kind, name = name, template = template,
                children = {} }
    if name then named[name] = f end
    function f:SetScript(ev, fn) self.scripts[ev] = fn; if ev == "OnUpdate" then ticker = fn end end
    function f:GetScript(ev) return self.scripts[ev] end
    function f:Fire(ev, ...) if self.scripts[ev] then self.scripts[ev](self, ...) end end
    local noop = function() end
    for _, m in ipairs({ "SetWidth", "SetHeight", "SetPoint", "SetBackdrop", "SetMovable",
                         "EnableMouse", "RegisterForDrag", "Show", "Hide", "SetText",
                         "SetAutoFocus", "SetJustifyH", "StartMoving",
                         "StopMovingOrSizing" }) do
        f[m] = noop
    end
    f.SetText = function(self, t) self.text = t end
    f.GetText = function(self) return self.text end
    f.CreateFontString = function()
        local fs = { SetPoint = noop, SetWidth = noop, SetJustifyH = noop }
        fs.SetText = function(s, t) s.text = t end
        return fs
    end
    return f
end
UIParent = CreateFrame("Frame", "UIParent")
SlashCmdList = {}

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_DevDump\]]
local ns = {}
local function loadaddon(f)
    local chunk, err = loadfile(ROOT .. f)
    assert(chunk, "load " .. f .. ": " .. tostring(err))
    chunk("COA_DevDump", ns)
end
loadaddon("core.lua")
loadaddon("task_unitstate.lua")

local T = ns.tasks and ns.tasks.unitstate
assert(T, "unitstate task did not register")
assert(T.mode == "session", "unitstate must be a session task")

T.start("")
local pay = COA_DevDumpDB.payload
assert(pay, "no payload after start")

-- ⚠ the widget contract: a NAMED EditBox, or InputBoxTemplate renders as two
-- floating end-caps. This has cost a live bug twice in this repo.
assert(named["COADevDumpUnitStateLabel"], "the label EditBox must be NAMED")
assert(named["COADevDumpUnitStateLabel"].template == "InputBoxTemplate",
       "label box should use InputBoxTemplate")
assert(named["COADevDumpUnitStateGet"], "GET POS button must be NAMED")
assert(named["COADevDumpUnitStatePanel"], "the panel frame must be NAMED")

-- declared-API pre-flight is recorded, including the absences
assert(pay.declared, "no declared table")
assert(pay.declared["GetCurrentPlayerPosition"] == "function", "position getter missing")
assert(pay.declared["UnitPosition"] == "nil",
       "UnitPosition absence must be RECORDED, not skipped")

-- ---------------------------------------------------------------- manoeuvre 2
-- ankles -> hips -> head, the breath timer marking the third
local get = named["COADevDumpUnitStateGet"]
W.z = 5.0
get:Fire("OnClick")
W.z, W.swimming = 4.1, nil
get:Fire("OnClick")
W.z, W.swimming, W.breath = 3.1, 1, 0.9      -- head under: breath running
get:Fire("OnClick")
assert(#pay.marks == 3, "expected 3 marks, got " .. #pay.marks)
local h = pay.marks[1].pz - pay.marks[3].pz
assert(math.abs(h - 1.9) < 1e-6, "height difference should be 1.9, got " .. tostring(h))
assert(pay.marks[3].mirror.value == 60000, "breath timer not captured on the head mark")

-- ★ the TYPE is preserved, not coerced. This fork returns 1, not true.
assert(pay.marks[3].isSwimming.v == 1, "swimming value should be the raw 1")
assert(pay.marks[3].isSwimming.t == "number", "and its TYPE must be recorded as number")
assert(pay.marks[1].isSwimming.v == nil, "not swimming should be nil, not false")

-- identity is on the row, so the height has something to be labelled with
assert(pay.marks[1].race == "Scourge", "race token missing")
assert(pay.marks[1].sex == 3, "sex missing")

-- ---------------------------------------------- the self-arguments must FIRE
-- swimming at RUN speed is a contradiction and must be recorded as one
W.swimming, W.speed = 1, 7.0
get:Fire("OnClick")
local m = pay.marks[#pay.marks]
local found = false
for _, c in ipairs(m.checks) do
    if c.check == "IsSwimming agrees with speed" then
        assert(c.agree == false, "swimming at 7.0 yd/s must DISAGREE")
        found = true
    end
end
assert(found, "the swim/speed cross-check did not run at all")

-- indoors AND outdoors at once is impossible and must be caught
W.indoors, W.outdoors = 1, 1
get:Fire("OnClick")
m = pay.marks[#pay.marks]
found = false
for _, c in ipairs(m.checks) do
    if c.check == "IsIndoors xor IsOutdoors" then
        assert(c.agree == false, "indoors AND outdoors must DISAGREE")
        found = true
    end
end
assert(found, "the indoors/outdoors cross-check did not run")
W.indoors, W.outdoors, W.speed, W.swimming = nil, 1, 0, nil

-- an absent UnitPosition must read as COULD-NOT-RUN, never as agreement
get:Fire("OnClick")
m = pay.marks[#pay.marks]
found = false
for _, c in ipairs(m.checks) do
    if c.check == "UnitPosition exists" then
        assert(c.agree == nil, "an absent API must be nil (could-not-run), not false")
        found = true
    end
end
assert(found, "absence of UnitPosition was not recorded as a check")

-- ---------------------------------------------------------------- manoeuvre 3
-- the jump window: IsFalling edges with a z peak between them
local jump = named["COADevDumpUnitStateJump"]
jump:Fire("OnClick")
assert(#pay.windows == 1, "window not recorded")
assert(ticker, "no OnUpdate was installed - the sampler would never run")
local arc = { 5.0, 5.9, 6.6, 6.9, 6.6, 5.9, 5.0 }
for i, z in ipairs(arc) do
    W.z = z
    W.falling = (i > 3) and 1 or nil
    now = now + 0.2
    ticker(nil, 0.2)
end
assert(#pay.rows == #arc, "expected " .. #arc .. " window rows, got " .. #pay.rows)
local peak = 0
for _, r in ipairs(pay.rows) do if r.z > peak then peak = r.z end end
assert(math.abs(peak - 6.9) < 1e-6, "the apex must be in the window rows")
local fell = 0
for _, r in ipairs(pay.rows) do if r.f then fell = fell + 1 end end
assert(fell == 4, "IsFalling must be captured per row; got " .. fell)

-- the window must CLOSE on its own rather than sampling forever
now = now + 999
ticker(nil, 0.2)
local before = #pay.rows
now = now + 1
ticker(nil, 0.2)
assert(#pay.rows == before, "sampling continued past the window")

-- ---------------------------------------------------------------- stop
T.stop()
local h2 = COA_DevDumpDB.header
assert(h2.status == "complete", "envelope not closed")
assert(pay.summary.checksDisagreed >= 2, "the deliberate lies were not counted")
assert(pay.summary.checksCouldNotRun >= 1, "could-not-run was not counted separately")
-- ⚠ zero persistent OnUpdate: the frame must be released on stop
assert(named["COADevDumpUnitStatePanel"], "panel vanished")
local cleared = true
for _, f in pairs(named) do
    if f.scripts and f.scripts["OnUpdate"] ~= nil then cleared = false end
end
assert(cleared, "OnUpdate was NOT cleared on stop - a persistent frame was left behind")

print("smoke_unitstate: OK - widget named, types preserved, 3 self-arguments fired, "
      .. "jump window bounded, OnUpdate released")
