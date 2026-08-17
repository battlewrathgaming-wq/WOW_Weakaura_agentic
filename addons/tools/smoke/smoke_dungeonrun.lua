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
    combat = false, instance = false, ghost = false, dead = false, bosses = {},
    inst = { name = "Ragefire Chasm", di = 2, dn = "Heroic" }, floor = 3,
    art = "Ragefire",
    clock = 1700000000, gt = 500.0,
}

function time() return W.clock end
function GetTime() return W.gt end
function UnitName(u) if u and W.bosses[u] then return W.bosses[u] end return "Gravekeeper" end
function UnitAffectingCombat() return W.combat end
function UnitIsGhost() return W.ghost end
function UnitIsDeadOrGhost() return W.dead or W.ghost end
function IsInInstance() return W.instance, "party" end
function GetCurrentPlayerPosition() return W.x, W.y, W.z, W.mapID end
function GetRealZoneText() return W.zone end
function GetSubZoneText() return W.sub end
function GetPlayerMapPosition() return 0.42, 0.61 end
-- EIGHT returns on this fork, not the documented seven: the 8th is the mapID.
function GetInstanceInfo() return W.inst.name, "party", W.inst.di, W.inst.dn, 5, 0, false, 389 end
-- The client's own resolver for a difficulty label (GlobalFunctions.lua:262).
function GetDifficultyInfo(i) return ({ [1] = "Normal", [2] = "Heroic" })[i] end
-- boss tokens: UnitExists returns 1 (a 3.3.5-ism), NOT true - live-verified
function UnitExists(u) return W.bosses[u] and 1 or nil end
AscensionUI = nil   -- the driver; tests install and remove it deliberately
function GetCurrentMapContinent() return 1 end
function GetCurrentMapZone() return 17 end
function GetCurrentMapDungeonLevel() return W.floor end
function GetMapInfo() return W.art, 668, 768 end
function SetMapToCurrentZone() end
WorldMapFrame = { IsShown = function() return false end }

-- The stub grew for DR-36: widget.lua is loaded here now, so the surface it
-- touches has to exist. Anything not spelled out is a no-op, so a failure lands on
-- LOGIC rather than on chrome; underscore keys stay DATA (nil when unset).
local made = {}
function CreateFrame()
    local f = { scripts = {}, events = {} }
    setmetatable(f, { __index = function(_, k)
        if type(k) == "string" and k:sub(1, 1) == "_" then return nil end
        return function() end
    end })
    function f:SetScript(e, fn) self.scripts[e] = fn end
    function f:GetScript(e) return self.scripts[e] end
    function f:RegisterEvent(e) self.events[e] = true end
    function f:Fire(e, ...) if self.scripts[e] then self.scripts[e](self, ...) end end
    function f:Enable() self._enabled = true end
    function f:Disable() self._enabled = false end
    function f:IsEnabled() return self._enabled end
    function f:SetText(t) self._text = t end
    function f:GetText() return self._text end
    function f:Show() self._shown = true end
    function f:Hide() self._shown = false end
    function f:IsShown() return self._shown end
    function f:CreateFontString() return CreateFrame() end
    made[#made + 1] = f
    return f
end
UIParent = {}

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_DungeonRun\]]
local NS = {}
NS.Say = function(m) chat[#chat + 1] = m end
local function load(f) assert(loadfile(ROOT .. f))("COA_DungeonRun", NS) end
load("store.lua")
load("capture.lua")
load("widget.lua")
local Store, Capture, Widget = NS.Store, NS.Capture, NS.Widget

-- No globals leaked. `onUpdate` is the live case: Capture.Arm installs it but
-- it is DEFINED BELOW the installer, so it must be forward-declared as a local.
-- Drop that line and the addon still works - by silently defining a global.
-- This exact bug shipped once in COA_Landmarks and passed its first mutation
-- test because of it.
for _, leaked in ipairs({"onUpdate", "inInstance", "onCombatStart", "onCombatEnd",
                         "onEnteringWorld", "captureOrigin", "mapFraction",
                         "composeId", "db"}) do
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

-- ★ DR-33: the FLOOR. 42 of the 43 multi-floor dungeons stack their floors over
-- the same footprint, so this cannot be recovered from x/y afterwards - a run
-- captured without it is PERMANENTLY unplaceable on those maps.
assert(run.outside.floor == 3, "DR-33 FAILED: no dungeon floor captured on the point")

-- DR-4: BOTH clocks on every point, and this is the irreversible one - a run
-- captured without wall-clock time can never be joined to the disk combat log.
assert(run.outside.t == 1700000000, "DR-4: wall-clock time() stamped")
assert(run.outside.gt ~= nil, "DR-4: monotonic GetTime() stamped")
assert(run.outside.mapC == 1 and run.outside.mapZ == 17,
       "the map fraction carries the map it belongs to")

-- ★ The floor rides the SAME trust boundary as the fraction. GetCurrentMapDungeonLevel
-- reports what the MAP is showing, and that only equals the player's floor after
-- SetMapToCurrentZone - which we skip while the user has the map open. So when the
-- fraction is untrustworthy the floor is too, and BOTH go nil rather than one of
-- them landing a plausible wrong number.
local realGPMP = GetPlayerMapPosition
GetPlayerMapPosition = function() return 0, 0 end        -- map showing another zone
local pt = Store.Point()
assert(pt.mapX == nil, "no fraction when the map shows elsewhere")
assert(pt.floor == nil,
       "DR-33 FAILED: an UNTRUSTED floor was recorded - worse than none, it looks real")
assert(pt.x ~= nil, "world coords are unaffected - they are always the truth")
GetPlayerMapPosition = realGPMP

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
-- DR-3 / ★ DR-35: in-instance sampling, in combat AND out.
--
-- The original gate ("in combat the marker pair already covers it") held only for
-- SHORT pulls. Battlewrath, reading the third draw: "On short pulls the absence is
-- clarity. On long pulls / big packs, all routing gets lost." The picture showed
-- continuous dots down the corridors where he WALKED and bare floor between markers
-- in the rooms where he FOUGHT - and it degrades as the group gets BETTER, because
-- a chain-pulling run records almost no path at all.
--
-- Cost is unchanged: the tick already ran at 1/s and simply returned.
-- =====================================================================
tick()
assert(#run.legs == 1, "DR-3: out of combat inside an instance samples the path")
assert(run.legs[1].combat == nil, "an out-of-combat leg carries no combat flag")

W.combat = true
tick(); tick()
assert(#run.legs == 3,
       "DR-35 FAILED: in-combat samples must be RECORDED - the gap in the picture "
       .. "was every long pull, got " .. #run.legs)
local cleg = run.legs[#run.legs]
assert(cleg.combat == true,
       "TAGGED, or the display cannot tell in-pull movement from travel")
assert(cleg.n ~= nil,
       "and JOINED to its pull - the key curation needs to isolate one pull")
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
-- DR-30: instance identity, captured at arrival. Difficulty is route IDENTITY -
-- a normal and a heroic pass through the same dungeon are different routes.
-- =====================================================================
assert(run.instance, "DR-30 FAILED: no instance identity captured at arrival")
assert(run.instance.difficultyName == "Heroic" and run.instance.difficultyIndex == 2,
       "DR-30: difficulty recorded, per RaidProfiles.lua:540's signature")
assert(run.instance.name == "Ragefire Chasm" and run.instance.maxPlayers == 5, "and the rest of it")
assert(run.instance.mapID == 389,
       "DR-30: the 8th return (mapID) is kept as a cross-check on the per-point mapID")

-- ★ DR-34: the tile art, stored at capture. Without it a run can only be drawn
-- while standing in the dungeon, because GetMapInfo() answers only for where you
-- ARE - and editing a route should not require being in it.
assert(run.mapFile == "Ragefire", "DR-34 FAILED: no tile art recorded, so the run is in-zone only")
assert(run.mapW == 668 and run.mapH == 768, "DR-34: the art dimensions come free with it")

-- WRITE-ONCE, like the rest of the run identity: zoning again must not repoint a
-- recorded run at whatever map you have since walked into.
W.art = "WailingCaverns"
frame:Fire("OnEvent", "PLAYER_ENTERING_WORLD")
assert(run.mapFile == "Ragefire", "DR-34 FAILED: tile art is last-wins, not write-once")
W.art = "Ragefire"

-- =====================================================================
-- ★★ DEFER, DO NOT DROP. GetMapInfo() answers about the map being SHOWN, so with
-- the world map open on another zone it names that zone's tiles - and a wrong
-- mapFile is used ANYWHERE (Map.ArtFor returns a stored file unconditionally), so
-- the run would draw on the wrong dungeon's art forever.
--
-- §66 guarded that by refusing to write unless it could confirm we were looking at
-- ourselves. It FAILED CLOSED: a missing mapFile is write-once and permanent, which
-- is the pre-DR-34 state DR-34 exists to end. Caught live as a regression.
--
-- The retry is the whole fix - one nil check a second until the map is closed.
-- =====================================================================
Capture.Stop()                    -- the run above is still recording
WorldMapFrame.IsShown = function() return true end
local mapOpenId = assert(Capture.Arm("armed with the map open"), "armed")
local openRun = Store.Get(mapOpenId)
assert(openRun.mapFile == nil,
       "WROTE FROM THE WRONG MAP: with the world map open on another zone, "
       .. "GetMapInfo names that zone - and a wrong mapFile is permanent")

-- ...and the moment the map closes, the next tick lands it. Nothing is lost.
WorldMapFrame.IsShown = function() return false end
frame:Fire("OnUpdate", 2)
assert(openRun.mapFile == "Ragefire",
       "DROPPED INSTEAD OF DEFERRED: the retry must land the art as soon as the "
       .. "map closes, or the run is in-zone only forever")

-- ⚠ NOT ASSERTED: that the retry stops calling SetMapToCurrentZone once the art
-- has landed. It does - captureMapArt returns at the write-once check - but the
-- effect is INVISIBLE, because store.lua's mapFraction() already snaps the map on
-- every tick to trust the fraction. Counting snaps measures the sampler, not the
-- retry, and a test that cannot tell them apart is a test that will pass for the
-- wrong reason. The early return is a saved duplicate call, not a guarantee.
Capture.Stop()

-- ★ difficultyName comes back EMPTY on this fork, so it is resolved from the
-- INDEX via the client's own GetDifficultyInfo. Live-confirmed: the probe read
-- difficultyName "" and GetDifficultyInfo(1) "Normal" in the same breath.
W.inst = { name = "Ragefire Chasm", di = 2, dn = "" }
Capture.Stop()
local idD = assert(Capture.Arm("difficulty probe"))
local runD = Store.Get(idD)
assert(runD.instance.difficultyName == "Heroic",
       "DR-30 FAILED: an empty difficultyName was not resolved from the index, got "
       .. tostring(runD.instance.difficultyName))

-- A raw name, when the fork does provide one, WINS over the lookup - so if they
-- ever start populating it we follow theirs rather than a table that could drift.
W.inst = { name = "Ragefire Chasm", di = 2, dn = "Mythic" }
Capture.Stop()
local idE = assert(Capture.Arm("raw name wins"))
assert(Store.Get(idE).instance.difficultyName == "Mythic",
       "DR-30 FAILED: the lookup overrode a real name from the client")
Capture.Stop()

-- back to the run under test
W.inst = { name = "Ragefire Chasm", di = 2, dn = "Heroic" }
assert(Capture.Arm("resumed after difficulty") ~= nil, "re-arm")
id = Capture.RunId(); run = Store.Get(id)
frame:Fire("OnEvent", "PLAYER_ENTERING_WORLD")

-- WRITE-ONCE. PLAYER_ENTERING_WORLD fires again on every /reload, and a run that
-- silently re-stamps its identity mid-way would report the LAST zone-in rather
-- than the one it started in.
W.inst = { name = "Wailing Caverns", di = 1, dn = "Normal" }
frame:Fire("OnEvent", "PLAYER_ENTERING_WORLD")
assert(run.instance.name == "Ragefire Chasm" and run.instance.difficultyName == "Heroic",
       "DR-30 FAILED: instance identity is last-wins, not write-once")
W.inst = { name = "Ragefire Chasm", di = 2, dn = "Heroic" }

-- =====================================================================
-- DR-31: boss engagements - ROUTE IDENTITY, and we record ENGAGED only
-- =====================================================================
W.bosses = {}
frame:Fire("OnEvent", "INSTANCE_ENCOUNTER_ENGAGE_UNIT")
assert(run.bosses == nil, "no tokens live -> nothing recorded")

W.bosses = { boss1 = "Taragaman the Hungerer" }
frame:Fire("OnEvent", "INSTANCE_ENCOUNTER_ENGAGE_UNIT")
assert(run.bosses and #run.bosses == 1, "DR-31 FAILED: an engagement was not recorded")
assert(run.bosses[1].names[1] == "Taragaman the Hungerer", "the boss names itself")
assert(#run.bosses[1].names == 1, "the token set is SPARSE - boss2..5 absent is normal")

-- Every engagement, not a distinct set: a wipe-then-retry is TWO records, and the
-- distinct set is a one-line fold offline. "Better to be rich and find faults."
frame:Fire("OnEvent", "INSTANCE_ENCOUNTER_ENGAGE_UNIT")
assert(#run.bosses == 2, "DR-31 FAILED: engagements were deduped at capture time")
W.bosses = {}

-- =====================================================================
-- DR-32: the TERMINAL STOP's attribution, consumed from DeathRecap
-- =====================================================================
-- ★ The last entry is a SELF-HEAL, and it is the case a real record forced.
-- The recap folds SPELL_HEAL, so a heal lands with `attacker` set to the HEALER -
-- which put the player's own name into a killedBy list in RFC_Run3_Messy pull 12.
-- `attacker` means "the caster of this event", not "an enemy".
AscensionUI = { DeathRecap = { CurrentRecap = 2, Events = { {}, {
    { attacker = "Molten Elemental", damage = -68 },
    { attacker = "Ragefire Trogg",   damage = -505 },
    { attacker = "Molten Elemental", damage = -12022 },
    { attacker = "Gravekeeper",      damage = 1200, isPlayer = true },
} } } }

W.combat = true;  frame:Fire("OnEvent", "PLAYER_REGEN_DISABLED")
W.dead = true;    frame:Fire("OnEvent", "PLAYER_DEAD")
W.combat = false; frame:Fire("OnEvent", "PLAYER_REGEN_ENABLED")
local stop = run.markers[#run.markers]
assert(stop.dead == true, "it is a terminal stop")
assert(stop.killedBy, "DR-32 FAILED: no attackers attached to a terminal stop")
-- The PLAYER check comes FIRST so a missing filter names ITSELF. Behind the count
-- assertion it was unreachable - the count failed first and reported the wrong
-- cause, which is the same class as an assertion that never runs.
for _, who in ipairs(stop.killedBy) do
    assert(who ~= "Gravekeeper",
           "isPlayer FILTER FAILED: a self-heal put the PLAYER in killedBy - the same "
           .. "defect RFC_Run3_Messy pull 12 recorded live")
end
assert(#stop.killedBy == 2,
       "DR-32 FAILED: attackers not deduped to DISTINCT names, got " .. #stop.killedBy)
assert(stop.killedBy[1] == "Molten Elemental" and stop.killedBy[2] == "Ragefire Trogg",
       "distinct, in FIRST-SEEN order")
assert(stop.killedByUnavailable == nil, "no failure reason when it worked")

-- ★ DIED, THEN RESURRECTED BEFORE COMBAT DROPPED. Not a contrivance - that is a
-- battle rez, which is exactly what happens in a dungeon. Attribution must NOT
-- attach: we walked away from that pull, so it is not a terminal stop.
-- (The first version of this test set dead=false only for a LATER pull, by which
-- point the pending value had already been spent - so the guard's mutation went
-- SILENT. The mutation harness found the test, not the code.)
W.combat = true;  frame:Fire("OnEvent", "PLAYER_REGEN_DISABLED")
W.dead = true;    frame:Fire("OnEvent", "PLAYER_DEAD")
W.dead = false                                  -- battle rez
W.combat = false; frame:Fire("OnEvent", "PLAYER_REGEN_ENABLED")
local rezzed = run.markers[#run.markers]
assert(rezzed.dead == nil, "rezzed before combat dropped, so not a terminal stop")
assert(rezzed.killedBy == nil,
       "ATTRIBUTION LEAKED: a pull we survived carries a killedBy")

-- And an ordinary survived pull attaches nothing either.
W.combat = true;  frame:Fire("OnEvent", "PLAYER_REGEN_DISABLED")
W.combat = false; frame:Fire("OnEvent", "PLAYER_REGEN_ENABLED")
local alive = run.markers[#run.markers]
assert(alive.dead == nil and alive.killedBy == nil,
       "ATTRIBUTION LEAKED: a survived pull carries a killedBy")

-- Pending is RUN-scoped: a death near the end of one run must not ride onto the
-- next one's first terminal stop.
W.combat = true;  frame:Fire("OnEvent", "PLAYER_REGEN_DISABLED")
W.dead = true;    frame:Fire("OnEvent", "PLAYER_DEAD")
Capture.Stop()
local id2 = assert(Capture.Arm("second run"), "a second run arms")
local run2 = Store.Get(id2)
W.combat = false; frame:Fire("OnEvent", "PLAYER_REGEN_ENABLED")
if #run2.markers > 0 then
    assert(run2.markers[1].killedBy == nil,
           "RUN LEAK: attribution from the previous run rode into this one")
end
Capture.Stop()
assert(Capture.Arm("resumed") ~= nil, "re-arm for the remaining tests")
id = Capture.RunId(); run = Store.Get(id)
W.instance = true
frame:Fire("OnEvent", "PLAYER_ENTERING_WORLD")
W.dead = false

-- Driver drift fails LOUD, IN THE RECORD. A silent absence would read as
-- "nothing killed us".
AscensionUI = nil
W.combat = true;  frame:Fire("OnEvent", "PLAYER_REGEN_DISABLED")
W.dead = true;    frame:Fire("OnEvent", "PLAYER_DEAD")
W.combat = false; frame:Fire("OnEvent", "PLAYER_REGEN_ENABLED")
local drift = run.markers[#run.markers]
assert(drift.killedBy == nil, "no attribution when the driver is gone")
assert(drift.killedByUnavailable and drift.killedByUnavailable:find("absent"),
       "DRIFT SILENT: the record must say WHY attribution is missing")
W.dead = false

-- Shape drift on their side, not absence - same requirement.
AscensionUI = { DeathRecap = { CurrentRecap = 1, Events = "not a table" } }
W.combat = true;  frame:Fire("OnEvent", "PLAYER_REGEN_DISABLED")
W.dead = true;    frame:Fire("OnEvent", "PLAYER_DEAD")
W.combat = false; frame:Fire("OnEvent", "PLAYER_REGEN_ENABLED")
assert(run.markers[#run.markers].killedByUnavailable,
       "DRIFT SILENT: a changed Events shape must be recorded as a reason")
AscensionUI = nil
W.dead = false

-- =====================================================================
-- DR-6: record EVERY combat. No dedupe, even at an identical position.
-- =====================================================================
-- Counted RELATIVE to where we are, not against a literal. An absolute count here
-- breaks the moment a test is inserted above it - which it did, on the first run
-- after DR-30/31/32 landed. A brittle test is a test that gets edited rather than
-- believed.
local n0 = #run.markers
local p0 = Store.Counts(id)
for _ = 1, 2 do
    W.combat = true;  frame:Fire("OnEvent", "PLAYER_REGEN_DISABLED")
    W.combat = false; frame:Fire("OnEvent", "PLAYER_REGEN_ENABLED")
end
assert(#run.markers == n0 + 4,
       "DR-6 FAILED: something filtered or deduped at capture time")

-- =====================================================================
-- ★ §48's LIMITED MANAGEMENT. "The sample collected is its own source of truth
-- and not governed bar limited management." All RUN-level - nothing anywhere
-- removes a single point.
-- =====================================================================
local mid = Store.Open("mgmt")
local mrun = Store.Get(mid)

-- ★ Rename moves the LABEL and no HANDLE. That works only because id and name
-- were separated at capture: name as typed, id = name-n, uniqueness from n alone.
assert(Store.Rename(mid, "  renamed  ") == "renamed", "trimmed, and returned")
assert(mrun.name == "renamed", "the label moved")
assert(Store.Get(mid) == mrun,
       "HANDLE MOVED: renaming must not change the id - everything referencing the "
       .. "run would need rewiring, and the selector would lose it")
assert(Store.Rename(mid, 7) == nil, "a non-string is refused rather than coerced")
assert(Store.Rename("nope", "x") == nil, "and an unknown run is not created by renaming it")

-- The comment: 40 characters, his number. His own example is 32 of them.
assert(Store.COMMENT_MAX == 40, "the cap is 40")
local ex = "bad run but good pull around 178"
assert(#ex == 32, "his example fits with room, which is the point of the cap")
assert(Store.SetComment(mid, ex) == ex, "a descriptor lands as typed")
assert(Store.SetComment(mid, string.rep("x", 60)) == string.rep("x", 40),
       "CAPPED: a descriptor must not be able to grow into a log")
assert(Store.SetComment(mid, "   ") == nil,
       "blank clears it rather than storing whitespace")
assert(mrun.comment == nil, "and the key goes with it")

-- Delete takes the WHOLE RUN. It is the only destructive verb anywhere.
Store.Delete(mid)
assert(Store.Get(mid) == nil, "deleted as a unit")

local pulls, legs = Store.Counts(id)
assert(pulls == p0 + 2,
       ("Counts reports pulls by START markers, expected %d got %d"):format(p0 + 2, pulls))
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
-- ★ ARMED INSIDE THE DUNGEON - the case run 1 exposed.
--
-- Zoning in and THEN starting to record is the natural workflow, and the
-- original build captured no arrival and no difficulty for it: the zone-in
-- event had already fired before the run existed. Record RFC_run1_clean-1 had
-- 15 pulls, 99 legs and a boss engagement, with `instance = nil`.
--
-- No PLAYER_ENTERING_WORLD is fired here ON PURPOSE - that is the whole point.
-- =====================================================================
W.instance = true
W.inst = { name = "Wailing Caverns", di = 1, dn = "Normal" }
local id3 = assert(Capture.Arm("armed inside"), "arms while already in an instance")
local run3 = Store.Get(id3)
assert(run3.arrival ~= nil,
       "ARM-INSIDE FAILED: no arrival captured, so the run has no origin")
assert(run3.instance and run3.instance.difficultyName == "Normal",
       "ARM-INSIDE FAILED: no instance identity, so the run has no difficulty")
assert(run3.outside == nil, "armed inside, so there is no world-side entrance to fake")
Capture.Stop()

-- And armed OUTSIDE still takes the world-side point and no origin yet.
W.instance = false
local id4 = assert(Capture.Arm("armed outside"), "arms outdoors")
local run4 = Store.Get(id4)
assert(run4.outside ~= nil, "armed outdoors captures the world-side entrance")
assert(run4.arrival == nil and run4.instance == nil,
       "the in-instance origin is NOT faked from outside - different maps (F38)")
W.instance = true
frame:Fire("OnEvent", "PLAYER_ENTERING_WORLD")
assert(run4.arrival ~= nil and run4.instance ~= nil,
       "zoning in then lands the origin")
Capture.Stop()

-- =====================================================================
-- DR-21: refuse data we do not understand, rather than guessing at it
-- =====================================================================
COA_DungeonRunDB = { schemaVersion = 99, runs = {} }
Store.locked = nil
local ok, err = Store.Load()
assert(not ok and err:find("99"), "DR-21: a future schema is refused, loudly")
assert(Store.Open("x") == nil, "locked: mutators become no-ops")

-- =====================================================================
-- ★★ DR-36 - THE CUSTOM PIN: the capture for what the client emits NOTHING for.
--
-- A jump skip, a route-shape decision, a moment that matters for a reason the game
-- has no event for. The only alternative is inferring from a gap in the legs, which
-- is DERIVING (§14, already ruled out) - and worse here, because we would be
-- guessing at something the player KNEW at the time.
-- =====================================================================
-- The block above deliberately leaves the store LOCKED, so start clean.
Capture.Stop()
COA_DungeonRunDB, Store.locked = nil, nil
assert(Store.Load(), "fresh store for the pin tests")

-- ⚠ ASSERTED ON THE REASON, not just the nil. Store.AddMarker(nil, ...) also
-- returns nil, so `Pin() == nil` passes whether or not the guard exists - the
-- harness reported removing it as SILENT. The reason string is the only thing that
-- can tell the two apart.
local noRun, why = Capture.Pin()
assert(noRun == nil and why == "not recording",
       "a pin needs a run - there is nowhere to put it otherwise, got " .. tostring(why))

local pid = assert(Capture.Arm("pinrun"), "arm for the pin tests")
local prun = Store.Get(pid)
W.instance, W.combat = true, false

local pin = assert(Capture.Pin(), "armed -> a pin lands")
assert(pin.kind == "pin", "it is a marker of kind pin, got " .. tostring(pin.kind))
assert(pin.mapX and pin.t and pin.floor,
       "and it is a POINT like any other - position, clock and floor, so it inherits "
       .. "the whole display layer for nothing")
assert(pin.n == 0, "pinned before any pull -> joined to pull 0, got " .. tostring(pin.n))

-- ★ IT CARRIES NO MEANING. "It's capture. Then later promote gives it meaning."
-- Anything typed onto it here would put interpretation at the one place this addon
-- refuses it.
for _, k in ipairs({ "note", "text", "label", "reason", "dead", "killedBy" }) do
    assert(pin[k] == nil, "A PIN MEANS NOTHING YET: it must not carry " .. k)
end

-- Ungated beyond armed - refusing a capture needs a reason and there isn't one.
W.combat = true
frame:Fire("OnEvent", "PLAYER_REGEN_DISABLED")
local inFight = assert(Capture.Pin(), "in combat is not a refusal")
assert(inFight.n == 1, "and it joins the pull it happened in, got " .. tostring(inFight.n))
W.combat = false
frame:Fire("OnEvent", "PLAYER_REGEN_ENABLED")

-- Pins are NOT pulls. Conflating them would inflate the count the widget shows.
local pp, pl, pn = Store.Counts(pid)
assert(pp == 1, "a pin is not a pull, got " .. pp .. " pull(s)")
assert(pn == 2, "Counts reports pins, got " .. tostring(pn))

-- =====================================================================
-- ★ THE WIDGET'S PIN BUTTON - DISABLED, NOT HIDDEN, when unarmed.
-- Disabled says "this exists and needs a run"; hidden says nothing at all.
-- =====================================================================
local wf = Widget.Init()
assert(wf, "the widget returns its frame")
local pinBtn
for _, o in ipairs(made) do if o._text == "Pin here" then pinBtn = o end end
assert(pinBtn, "the widget offers a pin control at all")
assert(pinBtn._enabled ~= false, "armed -> enabled")

Capture.Stop()
Widget.Refresh()
assert(pinBtn._enabled == false,
       "UNARMED PIN: the button must go DISABLED, not stay live over a run that "
       .. "does not exist")

chat = {}
assert(Widget.Pin() == nil, "and pressing it then does nothing but say why")
local said = false
for _, m in ipairs(chat) do if m:find("could not pin", 1, true) then said = true end end
assert(said, "it must SAY why rather than swallowing the press")

-- =====================================================================
-- ★★★ §248: THE DEV CAPTURE PROFILE - and the PRODUCT PATH IS THE TEST THAT MATTERS
-- =====================================================================
--
-- Battlewrath: *"off the default arm path. As this is dev work not product work."*
-- So the first assertion is that an ordinary arm is untouched - if that ever fails,
-- a dev instrument has leaked into the thing we hand over.
do
    Capture.Stop()

    local idP = assert(Capture.Arm("an ordinary run"), "the product path still arms")
    assert(Capture.Profile() == nil, "PRODUCT PATH TOUCHED: an ordinary name must match no profile")
    assert(Capture.SampleEvery() == 1.0, "and it samples at the product rate")
    assert(Store.Probe() == nil, "and installs NO probe - the point stays what it was")
    Capture.Stop()

    -- ★ The profile, matched on the name.
    local idT = assert(Capture.Arm("test1"), "the dev profile arms")
    assert(Capture.Profile(), "test1 matches a profile")
    assert(Capture.SampleEvery() == 0.2, "H3: 0.2s sampling, not the product 1.0")
    assert(Store.Probe(), "H0-b: a probe is installed for the calibration pair")

    -- ⚠ CASE-INSENSITIVE, because a human types the name. `TEST1` arming the product
    -- path while `test1` arms the profile is the kind of difference nobody sees.
    Capture.Stop()
    assert(Capture.Arm("TEST1"), "armed")
    assert(Capture.Profile(), "the match is case-insensitive")

    -- ★★ AND STOP UNDOES ALL OF IT. A dev session that leaked into the next ordinary
    -- run would poison a product capture silently - the same reason `pendingKilledBy`
    -- is cleared here and nowhere else.
    Capture.Stop()
    assert(Store.Probe() == nil, "LEAK: the probe must not survive Stop")
    assert(Capture.SampleEvery() == 1.0, "LEAK: the sample rate must return to product")
    assert(Capture.Profile() == nil, "LEAK: the profile must not survive Stop")
end

-- ★★★ THE PROBE MERGES, AND CANNOT DAMAGE THE POINT.
do
    Capture.Stop()

    Store.SetProbe(function() return { sd = 42, ts = 2, x = -999 } end)
    local p = Store.Point()
    assert(p.sd == 42 and p.ts == 2, "probe fields land on the point")
    -- ⚠ THE KEY GUARD. A probe that returns `x` must not become the position. The
    -- point's own fields are written first and win; the probe only ever FILLS GAPS.
    assert(p.x ~= -999, "PROBE OVERWROTE A REAL FIELD - the record would lie about where you were")

    -- ⚠ A probe that ERRORS costs its fields and nothing else. A dev instrument that
    -- can take down a capture is worse than no instrument.
    Store.SetProbe(function() error("probe blew up") end)
    local q = Store.Point()
    assert(q and q.x, "a throwing probe must not cost the POINT")
    assert(q.sd == nil, "and it contributes nothing")

    -- ⚠ And a probe returning a non-table is ignored rather than indexed.
    Store.SetProbe(function() return "not a table" end)
    local r = Store.Point()
    assert(r and r.x, "a nonsense probe return is ignored")

    Store.SetProbe(nil)
    assert(Store.Point().sd == nil, "and clearing it removes the fields")
end

print("smoke_dungeonrun: OK")
