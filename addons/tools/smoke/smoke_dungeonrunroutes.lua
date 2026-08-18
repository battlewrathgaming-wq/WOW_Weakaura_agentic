-- Offline smoke for COA_DungeonRun routes.lua - the AUTHORING surface (A1-A6).
--
-- ★★★ THIS FILE IS DELIBERATELY EMPTY OF THE ASSERTIONS IT EXISTS FOR, and stood up
-- BEFORE the code it will test (acceptance A7.1, proposition §10 step 2).
--
-- The reason, stated so nobody deletes the emptiness as an oversight: a smoke written
-- AFTER the code is written TO THE CODE. It asks "does it do what it does", finds that
-- it does, and reports green. A smoke written FIRST is written to the CRITERION - the
-- file is here, the slots are named, and each hole lands into somewhere that is already
-- asking it a question in words that came from the acceptance rather than the build.
--
-- ⚠⚠ SO A GREEN FROM THIS FILE IS NOT COVERAGE, AND IT SAYS SO OUT LOUD. The closing
-- line prints how many criteria are still UNCOVERED. Reading "OK" here and concluding
-- the authoring surface is tested is exactly the failure the roster exists to prevent -
-- an empty test suite passes perfectly.
--
-- What IS asserted today: the load chain stands up, and the anchors the holes attach to
-- behave as they behave now. A1.1 says the work is ADDITIVE - no existing signature
-- changes - so those baselines must survive every hole. If one goes red when G2 lands,
-- the change was not additive, and that is worth a red.
--
-- Run: .tools/lua51/lua5.1.exe addons/tools/smoke/smoke_dungeonrunroutes.lua

local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }

local W = { mapID = 33, floor = 6 }
function UnitName() return "Gravekeeper" end
function GetCurrentPlayerPosition() return 1, 2, 3, W.mapID end
function GetCurrentMapDungeonLevel() return W.floor end
function GetMapInfo() return "ShadowfangKeep", 668, 768 end
function GetRealZoneText() return "Shadowfang Keep" end
function GetSubZoneText() return "" end
function time() return 1786600000 end
function GetTime() return 100.0 end
UIParent = {}

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_DungeonRun\]]
local NS = {}
NS.Say = function(m) DEFAULT_CHAT_FRAME:AddMessage(m) end
local function load(f) assert(loadfile(ROOT .. f))("COA_DungeonRun", NS) end
load("store.lua")
load("routes.lua")
local Store, Routes = NS.Store, NS.Routes

COA_DungeonRunDB = nil
assert(Store.Load(), "fresh db")
assert(Routes, "routes.lua did not publish Routes")
Routes.Init()

for _, leaked in ipairs({ "PLACE", "tbl", "composeId", "mint", "nextBeaconId", "notes" }) do
    assert(_G[leaked] == nil, "LEAKED GLOBAL: " .. leaked)
end

-- =====================================================================
-- A SUBJECT. Every slot below needs something to be about, so the route is
-- built here once: one beacon with a child, one beacon WITHOUT.
--
-- ⚠ The childless beacon is not decoration. It is A1's whole case - the thing
-- that is currently unrunnable and is meant to stop being.
-- =====================================================================
local node = {
    x = 100.5, y = 200.5, z = 12.25, mapID = 33,
    mapX = 0.42, mapY = 0.66, mapC = 2, mapZ = 5, floor = 6,
}
local routeId = assert(Routes.Create("A7.1 subject", 33), "Create returned nil")

local parent = assert(Routes.AddBeacon(routeId, node, 1), "AddBeacon returned nil")
local child = assert(Routes.AddChildFromNode(routeId, parent, node), "AddChild returned nil")

local lone = assert(Routes.AddBeacon(routeId, node, 2), "AddBeacon (childless) returned nil")

assert(#Routes.ChildrenOf(parent) == 1, "the parent should have exactly one child")
assert(#Routes.ChildrenOf(lone) == 0, "the lone beacon should have none")

-- =====================================================================
-- BASELINE - what is true TODAY at each attachment point.
--
-- These are not the criteria. They are the ground the criteria are cut into, and
-- they are asserted so that a hole landing NON-additively shows up as a red here
-- rather than as a surprise three files away.
-- =====================================================================

-- A1's ground: reach lives on the CHILD and only on the child.
assert(type(Routes.SetChildReach) == "function", "SetChildReach missing")
local r, up, down = Routes.SetChildReach(child, 8, 2.5, 2.5)
assert(r == 8 and up == 2.5 and down == 2.5, "SetChildReach did not store what it was given")
assert(child.radius == 8, "reach did not land on the child")

-- A1.2's ground: a childless beacon is its OWN acceptance today, and that is the
-- half that already works. What it has no way to carry is a REACH.
assert(Routes.AcceptanceOf(lone) == lone, "a childless beacon should satisfy itself")
assert(Routes.AcceptanceOf(parent) == nil, "a beacon with an unflagged child accepts nothing")

-- A2's ground: children are ordered by their position in the list, with no ordinal
-- field of their own. THIS IS THE THING A2 CHANGES, and it is recorded rather than
-- asserted, because a red here would mean the ordinal landed - which is the goal.
local hasOrdinal = child.ordinal ~= nil

-- A3's ground, and ★★ THE FIRST THING THIS EMPTY FILE FOUND (2026-08-18, §299).
--
-- A3.1 proposes *"a child `kind` (a new axis beside `role`) with `boss`"*. **`kind` is
-- ALREADY TAKEN, and by the structural discriminator** - `beacon` (routes.lua:224),
-- `child` (:429), `note` (:1129). It is not a spare field: `SetName`/`NameOf` (:314,
-- :320) BRANCH on it to decide whether they are writing `text` or `name`. Writing
-- `boss` over `child` would silently move a boss child onto the beacon-naming path.
--
-- ⚠ Reported, not renamed - A3 is the Analyst's row and the term is theirs to rule.
-- The constraint is what this file can supply: the new axis needs a word that is not
-- `kind`, `role`, `shape`, `action`, `icon`, `outcome` or `stage`. This assertion
-- pins the collision so it cannot be re-discovered by a bug.
assert(type(Routes.SetChildRole) == "function", "SetChildRole missing")
assert(child.kind == "child", "`kind` is the STRUCTURAL discriminator - see above")
assert(parent.kind == "beacon", "`kind` is the STRUCTURAL discriminator - see above")

-- A5's ground: the three code vocabularies the adaptor will render.
for _, name in ipairs({ "ROLES", "SHAPES", "ACTIONS" }) do
    assert(type(Routes[name]) == "table" and #Routes[name] > 0,
           "Routes." .. name .. " is missing or empty - the adaptor has nothing to key on")
end

-- =====================================================================
-- ★★ THE ROSTER. One row per acceptance criterion this file will carry.
-- A row goes `false` the day its assertion lands above, and the count falls.
-- =====================================================================
local SLOTS = {
    { "A1.1", "SetBeaconReach stores; ReachOf returns child-else-beacon", true },
    { "A1.2", "a childless beacon with a radius is RUNNABLE", true },
    { "A1.3", "the beacon's z is still the read's; band is a tolerance over it", true },
    { "A2.1", "sparse child ordinal; insertion renumbers NOTHING", not hasOrdinal },
    { "A2.2", "4.1:3 resolves to exactly one child, route-wide unique", true },
    { "A2.3", "two children on one ordinal is TOLD, never refused", true },
    { "A2.4", "parent surface and child pane write the SAME field", true },
    { "A3.1", "boss axis (NOT `kind` - taken, see above); picker fed ONLY from r.bosses", true },
    { "A3.2", "two senses: boss engaged / boss killed", true },
    { "A3.3", "a nameless boss child arms NOTHING and is told", true },
    { "A3.4", "no set, count or grouping is stored or shown", true },
    { "A4.1", "a note resolves to exactly ONE string at runtime", true },
    { "A4.2", "referenced-or-owned, whichever R1 rules", true },
    { "A4.3", "a child with no note renders nothing", true },
    { "A5.1", "a missing adaptor row PASSES THROUGH the code term", true },
    { "A5.2", "every ROLES/SHAPES/ACTIONS value resolves or passes through", true },
    { "A6.1", "a boss kill alone moves the stage", true },
    { "A6.2", "both witnesses required; either alone does not advance", true },
}

local open = 0
for _, s in ipairs(SLOTS) do
    if s[3] then open = open + 1 end
end

print("smoke_dungeonrunroutes: load chain OK, baselines OK")
print(("  %d of %d criteria UNCOVERED - this file is a place for them, not a test of them")
      :format(open, #SLOTS))
for _, s in ipairs(SLOTS) do
    if s[3] then print(("    [ ] %-5s %s"):format(s[1], s[2])) end
end
if open == 0 then
    print("  ★ every slot filled - delete this roster and let the assertions speak")
end
