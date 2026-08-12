-- Offline smoke for COA_DungeonRun: store.lua + capture.lua under stubs.
--
-- The two criteria that fail SILENTLY in the field, and so are asserted
-- directly rather than inferred from behaviour:
--
--   DR-1  PLAYER_REGEN_ENABLED/DISABLED are EDGES. The state must be re-read
--         from UnitAffectingCombat("player") - the events also fire when
--         lockdown lifts for reasons that are not a pull. A build that trusts
--         the edge writes phantom markers, and the record looks plausible.
--   DR-3  the travel sampler must be gated on OUT-OF-COMBAT and IN-INSTANCE.
--         Ungated it silently doubles the record and fills it with the
--         open world, which reads as data rather than as a bug.
--
-- And DR-13: without the dead/ghost flags a WIPE AND A CLEAN FINISH ARE
-- IDENTICAL in the record. That is a fault you cannot find later, because the
-- field was never collected.

local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }

-- world state the test drives
local W = {
    x = 100, y = 200, z = 30, mapID = 389,
    zone = "Ragefire Chasm", sub = "The Molten Span",
    combat = false, instance = false, ghost = false, dead = false,
    clock = 1700000000, gt = 500.0,
}

function time() return W.clock end
function GetTime() return W.gt end
function UnitName() return "Gravekeeper" end
function UnitAffectingCombat() return W.combat end
function UnitIsGhost() return W.ghost end
function UnitIsDeadOrGhost() return W.dead or W.ghost end
function IsInInstance() return W.instance, "party" end
function GetCurrentPlayerPosition() return W.x, W.y, W.z, W.mapID end
function GetRealZoneText() return W.zone end
function GetSubZoneText() return W.sub end
function GetPlayerMapPosition() return 0.42, 0.61 end
function GetCurrentMapContinent() return 1 end
function GetCurrentMapZone() return 17 end
function SetMapToCurrentZone() end
WorldMapFrame = { IsShown = function() return false end }

function CreateFrame()
    local f = { scripts = {}, events = {} }
    function f:SetScript(e, fn) self.scripts[e] = fn end
    function f:GetScript(e) return self.scripts[e] end
    function f:RegisterEvent(e) self.events[e] = true end
    function f:Fire(e, ...) if self.scripts[e] then self.scripts[e](self, ...) end end
    return f
end

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_DungeonRun\]]
local NS = {}
local function load(f) assert(loadfile(ROOT .. f))("COA_DungeonRun", NS) end
load("store.lua")
load("capture.lua")
local Store, Capture = NS.Store, NS.Capture

-- No globals leaked. `onUpdate` is the live case: Capture.Arm installs it but
-- it is DEFINED BELOW the installer, so it must be forward-declared as a local.
-- Drop that line and the addon still works - by silently defining a global.
-- This exact bug shipped once in COA_Landmarks and passed its first mutation
-- test because of it.
for _, leaked in ipairs({"onUpdate", "inInstance", "onCombatStart", "onCombatEnd",
                         "onEnteringWorld", "mapFraction", "composeId", "db"}) do
    assert(_G[leaked] == nil, "LEAKED GLOBAL: " .. leaked)
end

local frame = Capture.Init()
local function step(dt)
    W.gt = W.gt + dt
    frame:Fire("OnUpdate", dt)
end
local function tick(seconds)     -- one sampler-sized step
    step(seconds or 1.0)
end

-- =====================================================================
-- STORED SHAPE + schema
-- =====================================================================
assert(Store.Load(), "fresh load")
assert(COA_DungeonRunDB.schemaVersion == 1, "DR-21: schemaVersion stamped")
assert(COA_DungeonRunDB.nextId == 1, "counter starts at 1")

-- =====================================================================
-- DR-7: the OUTSIDE entrance, captured at arm time because we are outdoors
-- =====================================================================
W.instance = false
local id = assert(Capture.Arm("Ragefire clockwise"), "arm should succeed")
assert(id == "Ragefire clockwise-1", "run id shape, got " .. tostring(id))
local run = Store.Get(id)
assert(run.outside ~= nil, "DR-7: armed outdoors, so the outside point is captured")
assert(run.arrival == nil, "DR-7: arrival is not faked from the outdoor point")
assert(run.character == "Gravekeeper", "the run records who ran it")

-- DR-4: BOTH clocks on every point, and this is the irreversible one - a run
-- captured without wall-clock time can never be joined to the disk combat log.
assert(run.outside.t == 1700000000, "DR-4: wall-clock time() stamped")
assert(run.outside.gt ~= nil, "DR-4: monotonic GetTime() stamped")
assert(run.outside.mapC == 1 and run.outside.mapZ == 17,
       "the map fraction carries the map it belongs to")

-- Arming twice is refused rather than silently opening a second run.
assert(Capture.Arm("second") == nil, "arming while armed is refused")

-- =====================================================================
-- DR-3: the sampler is GATED. Outside an instance it must not record.
-- =====================================================================
tick(); tick()
assert(#run.legs == 0, "DR-3 FAILED: sampled a leg while OUTSIDE an instance")

-- =====================================================================
-- DR-7: arrival lands on entering the instance, and is WRITE-ONCE
-- =====================================================================
W.instance = true
W.zone, W.sub = "Ragefire Chasm", "The Slag Pit"
frame:Fire("OnEvent", "PLAYER_ENTERING_WORLD")
assert(run.arrival ~= nil, "DR-7: arrival captured on entering the instance")
local firstArrival = run.arrival
W.x = 999
frame:Fire("OnEvent", "PLAYER_ENTERING_WORLD")
assert(run.arrival == firstArrival, "DR-7: arrival is write-once, not last-wins")
W.x = 100

-- =====================================================================
-- DR-3: in-instance, OUT of combat -> a leg. In combat -> nothing.
-- =====================================================================
tick()
assert(#run.legs == 1, "DR-3: out of combat inside an instance samples the path")

W.combat = true
tick(); tick()
assert(#run.legs == 1, "DR-3 FAILED: sampled a leg while IN COMBAT")
W.combat = false

-- The throttle: a step below SAMPLE_EVERY must not sample. The step has to
-- EXCEED the interval or this asserts nothing - it would pass because the code
-- never looked, not because the throttle held. (COA_Landmarks AC-26 went
-- vacuous exactly this way when its poll floor moved.)
local before = #run.legs
step(0.4)
assert(#run.legs == before, "DR-3 FAILED: sampled below the throttle interval")
step(0.7)   -- 0.4 + 0.7 crosses 1.0
assert(#run.legs == before + 1, "DR-3: the accumulator carries across steps")

-- =====================================================================
-- DR-1: THE EDGE IS NOT THE STATE. This is the silent one.
-- =====================================================================
W.combat = false
frame:Fire("OnEvent", "PLAYER_REGEN_DISABLED")
assert(#run.markers == 0,
       "DR-1 FAILED: a regen edge was trusted without re-reading UnitAffectingCombat")

W.combat = true
W.x, W.y = 150, 250
frame:Fire("OnEvent", "PLAYER_REGEN_DISABLED")
assert(#run.markers == 1, "DR-1: a confirmed combat start writes a marker")
assert(run.markers[1].kind == "start" and run.markers[1].n == 1, "marker is pull 1 start")
assert(run.markers[1].x == 150, "the marker is where the pull BEGAN")

-- =====================================================================
-- DR-13: combat end carries dead/alive, and the pair is what bounds a pull
-- =====================================================================
W.x, W.y = 180, 250          -- the fight drifted 30 yards
W.combat, W.dead = false, false
frame:Fire("OnEvent", "PLAYER_REGEN_ENABLED")
assert(#run.markers == 2, "combat end writes the closing marker")
local e = run.markers[2]
assert(e.kind == "end" and e.n == 1, "the end marker belongs to pull 1")
assert(e.x == 180, "start->end drift is preserved, and the delta is the finding")
assert(e.dead == nil, "DR-13: a clean finish carries NO dead flag")

-- A wipe. Without this field it would be indistinguishable from the above.
W.combat, W.dead = true, false
frame:Fire("OnEvent", "PLAYER_REGEN_DISABLED")
W.combat, W.dead = false, true
frame:Fire("OnEvent", "PLAYER_REGEN_ENABLED")
local wipe = run.markers[#run.markers]
assert(wipe.kind == "end" and wipe.dead == true,
       "DR-13 FAILED: a wipe is not distinguishable from a clean finish")

-- The corpse run: sampled, and FLAGGED, so replay can filter it later rather
-- than drawing a bizarre excursion with nothing to explain it.
W.ghost = true
tick()
assert(run.legs[#run.legs].ghost == true, "DR-13: corpse-run legs carry the ghost flag")
W.ghost, W.dead = false, false

-- =====================================================================
-- DR-6: record EVERY combat. No dedupe, even at an identical position.
-- =====================================================================
local n0 = #run.markers
for _ = 1, 2 do
    W.combat = true;  frame:Fire("OnEvent", "PLAYER_REGEN_DISABLED")
    W.combat = false; frame:Fire("OnEvent", "PLAYER_REGEN_ENABLED")
end
assert(#run.markers == n0 + 4,
       "DR-6 FAILED: something filtered or deduped at capture time")

local pulls, legs = Store.Counts(id)
assert(pulls == 4, "Counts reports pulls by START markers, got " .. tostring(pulls))
assert(legs == #run.legs, "Counts reports legs")

-- =====================================================================
-- Lifecycle: the OnUpdate exists ONLY while recording (zero persistent)
-- =====================================================================
assert(frame:GetScript("OnUpdate") ~= nil, "armed: the sampler is installed")
local closed = Capture.Stop()
assert(closed == id, "Stop returns the run it closed")
assert(frame:GetScript("OnUpdate") == nil,
       "LIFECYCLE FAILED: the sampler outlived the run - a persistent OnUpdate")
assert(Store.Get(id).closedAt ~= nil, "the run is stamped closed")
assert(Capture.RunId() == nil, "disarmed")

-- Disarmed, events are inert.
local m = #run.markers
W.combat = true; frame:Fire("OnEvent", "PLAYER_REGEN_DISABLED")
assert(#run.markers == m, "disarmed: combat writes nothing")
W.combat = false

-- =====================================================================
-- DR-21: refuse data we do not understand, rather than guessing at it
-- =====================================================================
COA_DungeonRunDB = { schemaVersion = 99, runs = {} }
Store.locked = nil
local ok, err = Store.Load()
assert(not ok and err:find("99"), "DR-21: a future schema is refused, loudly")
assert(Store.Open("x") == nil, "locked: mutators become no-ops")

print("smoke_dungeonrun: OK")
