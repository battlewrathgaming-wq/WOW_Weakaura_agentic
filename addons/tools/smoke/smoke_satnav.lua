-- Offline smoke for task_satnav: drives the three manoeuvres against stubs and
-- asserts the probe captures what each question needs.
--   A) vertical offset is preserved as hd/vd next to sd
--   B) a screen-invalid sample that STILL carries a distance is counted
--   C) a second mapID appears in the record
-- Plus the two things that would silently ruin a live run: the F24 setter path,
-- and handing the supertrack slot back on stop (law 13).
local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }
date = os.date
local now = 100.0
function GetTime() return now end
function GetAddOnMetadata() return "2.2.0" end
function UnitName() return "Gravekeeper" end
function UnitClass() return "Necromancer", "NECROMANCER" end
function GetRealmName() return "Vol'jin" end
function GetRealZoneText() return "Orgrimmar" end
function GetSubZoneText() return "Valley of Strength" end
function GetPlayerFacing() return 1.57 end

-- mutable world state the manoeuvres drive
local P = { x = 0, y = 0, z = 0, m = 1 }
local S = { x = 400, y = 300, d = 0.4, state = 4, tracking = true, valid = true }

function GetCurrentPlayerPosition() return P.x, P.y, P.z, P.m end

SUPER_TRACKED_POSITION = nil
local cleared = 0
C_SuperTrack = {
    GetSuperTrackedPosition = function() return S.x, S.y, S.d end,
    GetTargetState = function() return S.state end,
    IsSuperTrackingAnything = function() return S.tracking end,
    SetSuperTrackedPosition = function() error("direct C_ setter must not be used - F24") end,
    ClearSuperTracker = function() end,
}
SuperTrackerUtil = {
    SetSuperTrackedPosition = function(x, y, z, m)
        SUPER_TRACKED_POSITION = { x = x, y = y, z = z, mapID = m }
    end,
    ClearSuperTrackedPosition = function() SUPER_TRACKED_POSITION = nil; cleared = cleared + 1 end,
    HasValidScreenPosition = function() return S.valid end,
}
SuperTracker = { distance = 0.4 }
C_CVar = { GetBool = function() return true end }

local frames = {}
function CreateFrame()
    local f = { scripts = {} }
    function f:SetScript(ev, fn) self.scripts[ev] = fn end
    function f:Fire(ev, ...) if self.scripts[ev] then self.scripts[ev](self, ...) end end
    frames[#frames + 1] = f
    return f
end
SlashCmdList = {}

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_DevDump\]]
local ns = {}
local function loadaddon(f) assert(loadfile(ROOT .. f))("COA_DevDump", ns) end
loadaddon("core.lua")
loadaddon("task_satnav.lua")

SlashCmdList["COADEVDUMP"]("st satnav")
local tick = frames[#frames]
local function step() now = now + 1; tick:Fire("OnUpdate", 1.0) end

-- pin was taken and the CORRECT setter used (the stub errors on the wrong one)
local p = COA_DevDumpDB.payload
assert(p.pin and p.pin.mapID == 1, "pin captured")
assert(p.setterUsed:find("SuperTrackerUtil"), "F24 setter path: " .. tostring(p.setterUsed))
assert(SUPER_TRACKED_POSITION, "client global set")

-- (A) upstairs: horizontally close, 20 yards up
P.x, P.z = 1, 20
S.d = 20.02
step()

-- (B) back on the pin, camera spun away: screen invalid, distance still returned
P.x, P.z = 0, 0
S.valid, S.x, S.y, S.d = false, 0, 0, 0.4
step(); step()

-- (C) next zone: engine declines, tracking drops
P.m, S.state, S.tracking = 2, 0, false
S.valid = true
step()

SlashCmdList["COADEVDUMP"]("sp")

local s = COA_DevDumpDB.payload.summary
assert(COA_DevDumpDB.header.task == "satnav", "envelope task")
assert(COA_DevDumpDB.header.status == "complete", "committed")
assert(#COA_DevDumpDB.payload.rows == 5, "rows: " .. #COA_DevDumpDB.payload.rows)

-- (A) the vertical probe found the upstairs sample and kept both truths
local v = s.verticalProbeRow
assert(v and math.abs(v.vd - 20) < 0.01, "vertical probe vd: " .. tostring(v and v.vd))
assert(math.abs(v.hd - 1) < 0.01, "vertical probe hd: " .. tostring(v.hd))
assert(v.sd == 20.02, "vertical probe kept sd")

-- (B) screen-invalid samples counted, AND the ones that kept a distance counted
assert(s.samplesScreenInvalid == 2, "screen-invalid: " .. s.samplesScreenInvalid)
assert(s.samplesScreenInvalidWithDistance == 2,
       "invalid-but-distanced: " .. s.samplesScreenInvalidWithDistance)

-- (C) both zones present, and the declining state was recorded
assert(s.mapIDsSeen["1"] and s.mapIDsSeen["2"], "both mapIDs seen")
assert(s.targetStatesSeen["0"] == 1, "Invalid state recorded")

-- law 13: the slot was handed back
assert(cleared == 1, "supertrack cleared on stop, got " .. cleared)
assert(not SUPER_TRACKED_POSITION, "client global released")

-- no silent truncation, no swallowed tick errors
assert(COA_DevDumpDB.payload.capped == false, "not capped")
assert(COA_DevDumpDB.payload.tick_errors == nil, "tick errors: "
       .. tostring(COA_DevDumpDB.payload.tick_errors))

print("smoke_satnav OK - " .. #COA_DevDumpDB.payload.rows .. " rows; "
      .. chat[#chat])
