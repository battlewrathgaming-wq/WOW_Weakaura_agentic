-- Offline smoke for COA_DungeonRun calibrate.lua - fraction -> world.
--
-- This module's failure mode is the worst kind available to us: it returns SIX
-- NUMBERS, and wrong ones look exactly like right ones. A beacon converted through
-- a bad fit sits at a plausible world position, inside the dungeon, and only a
-- listen radius firing in the wrong corridor would ever say so.
--
-- So the tests are about REFUSAL as much as about arithmetic:
--
--   Fit          wrong coefficients   -> every conversion silently displaced
--   spread       fits anyway          -> a corridor run defines the whole map
--   build        drops samples        -> a thin fit that still reports healthy
--   ToWorld      returns on decline   -> the hole stops being loud
--
-- The desk-side proof that the transform is real lives in
-- addons/tools/verify_calibration.py, against landed captures. This asserts that
-- the code does what that proof assumes.

local W = { mapID = 33 }
function UnitName() return "Gravekeeper" end
function GetCurrentPlayerPosition() return 1, 2, 3, W.mapID end
function GetCurrentMapDungeonLevel() return 6 end
function GetRealZoneText() return "Shadowfang Keep" end
function GetSubZoneText() return "" end
function time() return 1786600000 end
function GetTime() return 100.0 end
function GetPlayerMapPosition() return 0.5, 0.5 end
DEFAULT_CHAT_FRAME = { AddMessage = function() end }

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_DungeonRun\]]
local NS = {}
NS.Say = function() end
local function load(f) assert(loadfile(ROOT .. f))("COA_DungeonRun", NS) end
load("store.lua")
load("map.lua")
load("calibrate.lua")
local Store, Map, Cal = NS.Store, NS.Map, NS.Calibrate

COA_DungeonRunDB = nil
assert(Store.Load(), "fresh db")
Cal.Init()

for _, leaked in ipairs({ "solve3", "spread", "build", "harvest", "cache",
                          "MIN_SPREAD", "MIN_AREA" }) do
    assert(_G[leaked] == nil, "LEAKED GLOBAL: " .. leaked)
end

-- =====================================================================
-- ★★ THE FIT. Coefficients taken from Shadowfang floor 6's real DBC box
-- (addons/maps/worldmap/): the world axes are SWAPPED and NEGATED relative to the
-- fraction, which is exactly why the fit is full affine and not two scales.
--
-- If this were fitted as `x = f(mapX)` and `y = g(mapY)` it would produce a
-- confident, well-conditioned, completely wrong answer.
-- =====================================================================
local TRUE = { a1 = 0, b1 = -152.43, c1 = 2256.20,      -- x depends on mapY only
               a2 = -101.62, b2 = 0, c2 = -91.60 }      -- y depends on mapX only

local function world(mx, my)
    return TRUE.a1 * mx + TRUE.b1 * my + TRUE.c1,
           TRUE.a2 * mx + TRUE.b2 * my + TRUE.c2
end

local function sample(mx, my)
    local x, y = world(mx, my)
    return { mapX = mx, mapY = my, x = x, y = y, floor = 6 }
end

local grid = {}
for i = 0, 4 do
    for j = 0, 4 do
        grid[#grid + 1] = sample(0.1 + i * 0.2, 0.1 + j * 0.2)
    end
end

local fit = assert(Cal.Fit(grid),
       "FIT IS WRONG: a well-spread grid must produce coefficients at all")
assert(fit.n == 25, "every sample counted, got " .. tostring(fit.n))

-- ★★ THE AXIS SWAP, asserted BEFORE the residual and deliberately so. On exactly
-- affine data a bad pairing also blows up the residual, so residual-first would
-- report "the fit is wrong" for every cause alike. Coefficients first says WHICH
-- way it is wrong - and this is the one the four-parameter form gets backwards.
assert(math.abs(fit.a1) < 1e-6 and math.abs(fit.b1 + 152.43) < 1e-4,
       "AXES NOT RECOVERED: x must come from mapY - the full affine form is why")
assert(math.abs(fit.b2) < 1e-6 and math.abs(fit.a2 + 101.62) < 1e-4,
       "AXES NOT RECOVERED: and y from mapX")

assert(fit.worst < 1e-6,
       ("FIT IS WRONG: worst residual %s yards on data that is exactly affine")
       :format(tostring(fit.worst)))
assert(fit.rms < 1e-6, "FIT IS WRONG: and the rms with it")

-- ★ The recovered transform must reproduce a point it never saw. Checking the
-- residual alone would pass on a fit that memorised its inputs.
local ex, ey = Cal.Apply(fit, 0.37, 0.81)
local tx, ty = world(0.37, 0.81)
assert(math.abs(ex - tx) < 1e-6 and math.abs(ey - ty) < 1e-6,
       "PREDICTION FAILED on a point outside the sample set")

-- =====================================================================
-- ★★ CONDITIONING - it must REFUSE, and say which way it is blind.
--
-- Least squares always returns numbers. On degenerate input those numbers are
-- confident and wrong, and nothing downstream could detect it - so the guard has
-- to sit in front of the arithmetic, not behind it.
-- =====================================================================
local function declines(samples, want)
    local f, why = Cal.Fit(samples)
    assert(f == nil, "MUST DECLINE: " .. want)
    assert(why and why:find(want, 1, true),
           ("wrong reason: wanted %q, got %q"):format(want, tostring(why)))
end

declines({ sample(0.1, 0.1), sample(0.9, 0.9) }, "3 is the minimum")

-- A corridor: real movement, but only along one axis. This is the case a per-run
-- fit would have hit constantly and the pooled fit exists to survive.
local corridor = {}
for i = 1, 40 do corridor[#corridor + 1] = sample(0.5, 0.05 + i * 0.02) end
declines(corridor, "no spread across the map's width")

local corridor2 = {}
for i = 1, 40 do corridor2[#corridor2 + 1] = sample(0.05 + i * 0.02, 0.5) end
declines(corridor2, "no spread down the map's height")

-- A diagonal walk: spread on BOTH axes and still undetermined, because one
-- direction never varies independently. Neither spread test alone catches it.
local diag = {}
for i = 1, 40 do
    local t = 0.05 + i * 0.02
    diag[#diag + 1] = sample(t, t)
end
declines(diag, "collinear")

-- =====================================================================
-- The cache - keyed by mapID, walked per floor, built from the RUNS
-- =====================================================================
local function addRun(name, mapID, floor, n, mapFile)
    local id, run = Store.Open(name)
    run.instance = { mapID = mapID }
    run.mapFile = mapFile
    for i = 0, n - 1 do
        local mx = 0.15 + (i % 5) * 0.17
        local my = 0.15 + math.floor(i / 5) * 0.17
        local x, y = world(mx, my)
        run.legs[#run.legs + 1] =
            { mapX = mx, mapY = my, x = x, y = y, floor = floor, t = 1000 + i }
    end
    return id
end

addRun("sfk one", 33, 6, 25, "ShadowfangKeep")
local f6 = assert(Cal.Floor(33, 6), "floor 6 calibrates from one good run")
assert(f6.n == 25, "from its 25 paired points, got " .. tostring(f6.n))

local wx, wy = Cal.ToWorld(33, 6, 0.42, 0.66)
local rx, ry = world(0.42, 0.66)
assert(wx and math.abs(wx - rx) < 1e-6 and math.abs(wy - ry) < 1e-6,
       "ToWorld must go through the fit")

-- ★★ THE RUNS ARE THE SAMPLES, and a SECOND run must be pooled in. This is the
-- whole design: a thin run borrows the calibration a fat one established. Proven
-- at the desk across real captures (verify_calibration.py: 20 cross-run cases,
-- worst 0.0002 yd) - asserted here as CODE that actually pools.
Cal.Clear()
addRun("sfk two", 33, 6, 25, "ShadowfangKeep")
local pooled = assert(Cal.Floor(33, 6), "still calibrates")
assert(pooled.n == 50,
       ("RUNS NOT POOLED: %s samples from two runs of 25"):format(tostring(pooled.n)))

-- ★ Floors are SEPARATE. They stack over the same footprint but each has its own
-- box, so one fit for the dungeon would be right on whichever floor dominated the
-- sample and quietly wrong on the rest.
Cal.Clear()
addRun("sfk upper", 33, 3, 25, "ShadowfangKeep")
assert(Cal.Floor(33, 3), "FLOORS MERGED: floor 3 must calibrate on its own samples")
assert(Cal.Floor(33, 3).n == 25,
       "FLOORS MERGED: floor 3 must not inherit floor 6's samples, got "
       .. tostring(Cal.Floor(33, 3).n))
assert(Cal.Floor(33, 6).n == 50, "and floor 6 keeps its own")

-- ★ A point with no fraction teaches nothing. store.lua stores nil when the world
-- map is open (it will not fight the user's view), so these arrive in real runs -
-- and counting them as samples would report a fit fatter than its evidence.
Cal.Clear()
local halfId, half = Store.Open("half blind")
half.instance = { mapID = 77 }
for i = 1, 25 do
    local mx, my = 0.15 + (i % 5) * 0.17, 0.15 + math.floor(i / 5) * 0.17
    local x, y = world(mx, my)
    half.legs[#half.legs + 1] = { mapX = mx, mapY = my, x = x, y = y, floor = 0 }
    half.legs[#half.legs + 1] = { x = x, y = y, floor = 0 }        -- map was open
end
assert(Cal.Floor(77, 0).n == 25,
       "UNPAIRED POINTS COUNTED: a point with no fraction is not a sample, got "
       .. tostring(Cal.Floor(77, 0).n))
-- ★ Worth stating which class this guard is in: letting an unpaired point through
-- is a HARD ERROR, not a silent wrong - the fit does arithmetic on a nil the moment
-- it tries. That is the good case, and the mutation for it expects the crash rather
-- than an assertion, because there is no wrong ANSWER to catch.

-- =====================================================================
-- ★ A DUNGEON NOBODY HAS RUN IS ABSENT, NOT WRONG - which is the whole reason
-- §17 tolerates this. It never learns a dungeon; it reports what the data can say.
-- =====================================================================
local none, why = Cal.ToWorld(9999, 0, 0.5, 0.5)
assert(none == nil, "an unseen dungeon must not produce coordinates")
assert(why, "and it must say WHY, or the hole is silent: " .. tostring(why))

Cal.Clear()
local thinId, thin = Store.Open("thin")
thin.instance = { mapID = 88 }
thin.legs = { { mapX = 0.5, mapY = 0.5, x = 1, y = 2, floor = 0 } }
local nope, why2 = Cal.ToWorld(88, 0, 0.5, 0.5)
assert(nope == nil, "DECLINE MUST REACH THE CALLER: one sample is not a plane")
assert(why2:find("minimum"), "carrying the reason up, got " .. tostring(why2))

-- The report is what a readout would draw: per floor, what the data can tell us.
local rows, name, runs = Cal.Report(33)
assert(name == "ShadowfangKeep", "NAME NOT RESOLVED: an inspected cache must say "
       .. "which dungeon, got " .. tostring(name))
assert(runs >= 3, "and how many runs fed it, got " .. tostring(runs))
assert(#rows >= 2, "one row per floor seen")
for _, r in ipairs(rows) do
    assert(r.ok, "every floor here calibrates")
    assert(r.worst and r.worst < 1e-6, "and reports its own error")
end

print("smoke_dungeonruncalibrate: OK")
