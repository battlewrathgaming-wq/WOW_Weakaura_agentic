-- Offline smoke for COA_Landmarks: store.lua + beacon.lua under stubs.
--
-- AC-45 requires AC-24 and AC-26 to be asserted DIRECTLY, because they are the
-- two that fail SILENTLY in the field:
--   AC-24  a map-boundary refusal reports Invalid with sd = 0.00, and zero
--          satisfies every tier - so distance alone fires "arrived" the instant
--          a player zones into any instance.
--   AC-26  that guard must judge a SUSTAINED state, not a single frame.
--
-- AC-53.3 requires asserting the STORED SHAPE, not just behaviour - a test that
-- only checks "the widget shows the right name" passes while the file rots.

local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }
local now = 1000.0
function GetTime() return now end
function GetAddOnMetadata() return "0.1.0" end
function UnitName() return "Gravekeeper" end

-- world state the test drives
local P = { x = 100, y = 200, z = 30, mapID = 1, zone = "Winterspring", sub = "Everlook" }
local S = { state = 2, dist = 40, tracked = nil }

function GetCurrentPlayerPosition() return P.x, P.y, P.z, P.mapID end
function GetRealZoneText() return P.zone end
function GetSubZoneText() return P.sub end
function GetPlayerMapPosition() return 0.42, 0.61 end
function GetCurrentMapContinent() return 1 end
function GetCurrentMapZone() return 17 end
function SetMapToCurrentZone() end
WorldMapFrame = { IsShown = function() return false end }

SUPER_TRACKED_POSITION = nil
C_SuperTrack = {
    GetSuperTrackedPosition = function() return 0.5, 0.5, S.dist end,
    GetTargetState = function() return S.state end,
    SetSuperTrackedPosition = function() error("AC-17: the direct C_ setter must not be used") end,
}
SuperTrackerUtil = {
    SetSuperTrackedPosition = function(x, y, z, m)
        SUPER_TRACKED_POSITION = { x = x, y = y, z = z, mapID = m }
    end,
    ClearSuperTrackedPosition = function() SUPER_TRACKED_POSITION = nil end,
}

local frames = {}
function CreateFrame()
    local f = { scripts = {} }
    function f:SetScript(e, fn) self.scripts[e] = fn end
    function f:RegisterEvent() end
    function f:Fire(e, ...) if self.scripts[e] then self.scripts[e](self, ...) end end
    frames[#frames + 1] = f
    return f
end
function hooksecurefunc() end
function SelectQuestLogEntry() end

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_Landmarks\]]
local NS = {}
local function load(f) assert(loadfile(ROOT .. f))("COA_Landmarks", NS) end
load("store.lua")
load("beacon.lua")
local Store, Beacon = NS.Store, NS.Beacon

-- =====================================================================
-- STORED SHAPE (AC-53.3)
-- =====================================================================
assert(Store.Load(), "fresh load")
assert(COA_LandmarksDB.schemaVersion == 1, "AC-48: schemaVersion stamped")
assert(COA_LandmarksDB.nextId == 1, "AC-51: counter starts at 1")

local id, lm = Store.Create()
assert(id == "Winterspring-Everlook-1", "AC-47 id shape, got " .. tostring(id))
assert(lm.alias == "Everlook 1", "AC-4 alias shape, got " .. tostring(lm.alias))
assert(lm.owner == "Gravekeeper", "AC-46: character-owned by default")
assert(lm.tier == "interact", "AC-40 default tier: match the game")
assert(lm.mapC == 1 and lm.mapZ == 17, "the fraction carries the map it belongs to")
assert(COA_LandmarksDB.landmarks[id], "AC-47: keyed BY ID, so the file reads at a glance")
for _, v in pairs(lm) do assert(type(v) ~= "function", "AC-49: data only, no functions") end

-- AC-2: position is never rewritten; AC-47: the id is not editable
assert(not Store.Set(id, "x", 999), "AC-2: position must not be editable")
assert(not Store.Set(id, "id", "nope"), "AC-47: id must not be editable")
assert(Store.Set(id, "alias", "Bank alt"), "alias is editable")
assert(Store.Get(id).alias == "Bank alt" and Store.Get(id).x == 100, "rename left position alone")

-- AC-46: owner is ONE field with two forms - promotion is a field write
Store.SetOwner(id, true)
assert(Store.Get(id).owner == "global", "AC-46: promote")
Store.SetOwner(id, false)
assert(Store.Get(id).owner == "Gravekeeper", "AC-46: demote to the current character")

-- AC-51: nextId never rewinds across a delete
P.sub = "Frostsaber Rock"
local id2 = Store.Create()
assert(COA_LandmarksDB.nextId == 3, "counter advanced")
assert(Store.Delete(id2), "delete")
assert(COA_LandmarksDB.nextId == 3, "AC-51: counter must NOT rewind after a delete")
local id3 = Store.Create()
assert(id3 ~= id2, "AC-51: a deleted id is never handed out again")
Store.Delete(id3)
P.sub = "Everlook"

-- AC-54: tags stored AS TYPED; splitting happens on read only
Store.Set(id, "tags", "  Vendor , alt ,, winterspring ")
assert(Store.Get(id).tags == "  Vendor , alt ,, winterspring ", "AC-54: never cleaned up")
local t = Store.SplitTags(Store.Get(id).tags)
assert(#t == 3 and t[1] == "Vendor" and t[3] == "winterspring", "split+trim on READ")
-- AC-54a: autocomplete mirrors what was typed; it offers, it does not correct
local sugg = Store.SuggestTags("ven")
assert(#sugg == 1 and sugg[1] == "Vendor", "AC-54a: offered exactly as typed")

-- AC-54a REGRESSION (Battlewrath, live): "recommends what you type as you type,
-- not what is stored already only". Because tags save on EVERY keystroke, the
-- half-word in the box is already stored - so the record being EDITED must be
-- excluded, or the suggestion is the user's own typing handed straight back.
assert(#Store.SuggestTags("ven", id) == 0,
       "AC-54a FAILED: suggested a tag from the record being edited")
P.sub = "Ironforge Gate"
local other = Store.Create()
Store.Set(other, "tags", "vendor")
assert(#Store.SuggestTags("ven", id) == 1,
       "a tag from ANOTHER landmark must still suggest")
assert(#Store.SuggestTags("vendor", other) == 0,
       "never offer back exactly what is already typed")
Store.Delete(other)
P.sub = "Everlook"

-- AC-48: refuse a version we do not know, and CHANGE NOTHING
COA_LandmarksDB.schemaVersion = 99
Store.locked = nil
local ok, err = Store.Load()
assert(not ok and err:find("99"), "AC-48: refuses a future schema")
assert(not Store.Create(), "AC-48: locked store creates nothing")
assert(not Store.Delete(id), "AC-48: locked store deletes nothing")
assert(COA_LandmarksDB.landmarks[id], "AC-48: the user's data is untouched")
COA_LandmarksDB.schemaVersion = 1
Store.locked = nil
assert(Store.Load(), "reload after fixing the version")

-- =====================================================================
-- BEACON - the two that fail silently
-- =====================================================================
Beacon.Init()
local tick = frames[#frames]
local function step(dt) now = now + (dt or 1.0); P.x = P.x + 0.001; tick:Fire("OnUpdate", dt or 1.0) end

assert(Beacon.Pin(id), "AC-17: pinned via the Util wrapper (the C_ stub errors)")
assert(SUPER_TRACKED_POSITION, "the client's global was set")

-- ---- AC-24: a REFUSAL reports Invalid with distance 0.00 ----
-- Zero satisfies every tier. Without the state half of the guard, this is where
-- a naive build fires "arrived" on zoning into an instance.
S.state, S.dist = 0, 0.00
for _ = 1, 5 do step(1.0) end
assert(Beacon.PinnedId() == id,
       "AC-24 FAILED: Invalid + sd=0.00 was treated as an arrival")
assert(SUPER_TRACKED_POSITION, "AC-28: on a refusal we do NOTHING - the slot is not cleared")

-- ---- AC-25: cannot arrive at a landmark on another map ----
S.state, S.dist = 2, 0.5
P.mapID = 389
for _ = 1, 5 do step(1.0) end
assert(Beacon.PinnedId() == id, "AC-25 FAILED: arrived while on a different map")
P.mapID = 1

-- ---- AC-26: the guard must judge a SUSTAINED state ----
-- One frame of a valid-looking arrival is not an arrival.
S.state, S.dist = 2, 1.0
step(0.10)
assert(Beacon.PinnedId() == id,
       "AC-26 FAILED: a single frame was enough to fire arrival")

-- ---- and a real arrival, once it has held ----
step(1.0)
step(1.0)
assert(Beacon.PinnedId() == nil, "arrival should fire once the condition is sustained")
assert(not SUPER_TRACKED_POSITION, "AC-27: arrival wipes the beacon")
assert(#chat == 0, "L12 / AC-27: arriving is SILENT - nothing was printed")

-- ---- AC-19: we never re-assert ----
assert(Beacon.Pin(id), "re-pin as a user act")
SUPER_TRACKED_POSITION = nil                 -- something else took the slot
for _ = 1, 5 do step(1.0) end
assert(Beacon.PinnedId() == nil, "we let go")
assert(not SUPER_TRACKED_POSITION, "AC-19 FAILED: we took the slot back on our own")

-- ---- AC-14: cannot guide, two triggers ----
Beacon.Pin(id)
P.mapID = 389
assert(Beacon.CannotGuide(id), "AC-14 trigger 1: map mismatch")
P.mapID = 1
S.dist = 3000
assert(Beacon.CannotGuide(id), "AC-14 trigger 2: beyond the client's 1500 cut")
S.dist = 40
assert(not Beacon.CannotGuide(id), "in range and on-map: the beacon can guide")

print("smoke_landmarks OK - stored shape, AC-24, AC-25, AC-26, AC-27, AC-19, AC-14 all asserted")
