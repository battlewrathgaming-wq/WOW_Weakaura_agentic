-- Model: addons/planning/DRIVER_BASIS.md
--
-- ★★★ THE RULE (P3, A11.2) — POINT + BAND + GATE, and nothing else.
--
-- RI-33 drained 2026-08-20, Battlewrath: **"we build from need to function not on
-- precedence. Precedence is the proof we can. Not the implementation the addon
-- needs."** → *"A11.2a narrows to point + band + gate; segment, interpolated-z and
-- v_max are desk-side."*
--
-- ⚠⚠ SO WHAT IS ABSENT HERE IS ABSENT ON PURPOSE, and this is the file that would
-- otherwise accumulate it. `walk.py` interpolates because it reconstructs a
-- FIXED-CADENCE RECORDING and cannot go back and look again. **This driver controls
-- when it looks** — it throttles up on approach — so segment interpolation is the
-- desk's answer to a problem this side does not have. No `segment_fire`, no
-- interpolated z, no `v_max`.
--
-- ⚠ RECORDS GAP, REPORTED NOT RESOLVED: `driver_sense_acceptance.md` A11.2a still
-- reads *"Point + segment + band … graded by W7.1 (byte-equal to the desk)"* — the
-- drain declared the narrowing and the ROW has not caught up. This file builds only
-- what BOTH texts agree on (point + band + gate); segment is not built, per the
-- drain. **The bench did not choose between them.**
--
-- ★ PURITY (A11.3): the rule holds NOTHING. No previous sample, no armed set, no
-- ledger — those belong to the sensor. Every function here is a pure function of its
-- arguments, which is what makes the same call gradeable from a fixture and from a
-- live poll without either knowing about the other.
--
-- ★ SQUARED DISTANCES THROUGHOUT, inherited from the desk's H4 costing: a sqrt would
-- be a per-tick cost bought for nothing when every comparison is against a constant
-- we can pre-square.

local NS = select(2, ...)
NS = NS or _G.COA_DungeonRun_NS or {}
if select(2, ...) == nil then _G.COA_DungeonRun_NS = NS end

local Rule = {}
NS.Rule = Rule

-- ★ BAND OPEN by default (advisory R-b): a scene spanning two floors must not be
-- vetoed on the other floor. ⚠ `math.huge` is Lua's infinity and compares correctly
-- against any finite dz — it is NOT the same as a very large number, and A11.2e's
-- rejection below must not mistake it for one it should refuse.
Rule.OPEN = math.huge

-- ⚠⚠ A11.2e — NON-FINITE IS REJECTED, AND IN LUA THAT IS TWO TESTS.
--
--   type(v) ~= "number"   a string, a table, nil - anything that is not a number
--   v ~= v                 NaN, which is the ONLY value not equal to itself
--
-- ★ The second is not a stylistic alternative to the first: `type(0/0) == "number"`
-- is TRUE, so a type test alone passes NaN straight through. And a NaN reaching the
-- radius test does not throw — `NaN > r2` is FALSE, so the early-out is SKIPPED and
-- the sample silently proceeds. That is the shape the desk's own note calls out
-- (`walk.py:470`): a bad value that fails no test and produces no error.
--
-- ⚠ `inf` is a separate fixture from NaN (W7.2) because it behaves differently:
-- `inf > r2` is TRUE, so infinity is REJECTED BY THE RADIUS TEST rather than by this
-- one. Both are refused; only one is refused here, and knowing which matters when a
-- row goes red.
local function finite(v)
    return type(v) == "number" and v == v and v ~= math.huge and v ~= -math.huge
end

function Rule.Usable(p)
    return p ~= nil and finite(p.x) and finite(p.y) and finite(p.z)
end

-- ★★★ THE GATE — the cheapest test first, and it is not an optimisation.
--
-- A11.2d (S3): **a target in another mapID never fires however close the numbers
-- are.** Two maps' coordinates are unrelated, so a small dx/dy across a map boundary
-- is a coincidence rather than a proximity. ⚠ Testing geometry first would give that
-- coincidence a chance to fire before anything noticed the map.
function Rule.Gate(sampleMapID, nodeMapID)
    return sampleMapID ~= nil and sampleMapID == nodeMapID
end

-- ★★ POINT + BAND. The whole rule for one sample against one node.
--
-- `r2` is the radius PRE-SQUARED by the caller; `bandUp` is the upward tolerance and
-- may be `Rule.OPEN`. ⚠ There is no downward half — RI-22 made the band UPWARD ONLY
-- because a captured sample IS the floor (ROUTER 280: a unit's z is its BASE POINT),
-- so downward tolerance measures nothing that exists.
--
-- ⚠ dz is signed and the test is one-sided: BELOW the node is out. A player under a
-- walkway must not satisfy a beacon standing on it, which is the case the band was
-- introduced for.
function Rule.PointFire(p, node, r2, bandUp)
    local dx = p.x - node.x
    local dy = p.y - node.y
    if dx * dx + dy * dy > r2 then return false end
    local dz = p.z - node.z
    return dz >= 0 and dz <= (bandUp or Rule.OPEN)
end

-- ★★★ ONE EVALUATION PER NODE PER SAMPLE (A11.2g), and it is CORRECTNESS not economy.
--
-- RI-16: a child COMPLETES when ALL its action tabs have completed — which requires
-- every tab to agree about the SAME in/out transition. ⚠ Four independent evaluations
-- of one node's geometry are four places that can disagree, and a fixture where two
-- rows straddle the boundary would show them disagreeing.
--
-- ★ The two-record split (RI-25) is what makes the shared evaluation the only
-- expressible shape: under one line per tab, each carrying its own copy of POS,
-- testing per ROW is the natural implementation and the bug is the default.
--
-- Returns: fired (boolean), why (string) — the `why` so a readout can say what
-- happened rather than only that something did (the capability law).
function Rule.Evaluate(sample, node)
    if not Rule.Usable(sample) then return false, "sample not usable" end
    if not Rule.Usable(node) then return false, "node not usable" end
    if not Rule.Gate(sample.mapID, node.mapID) then return false, "other map" end

    local r = node.r
    if not finite(r) or r <= 0 then return false, "no radius" end

    -- ⚠⚠ `Rule.OPEN` IS `math.huge`, and `finite()` REFUSES math.huge - so a node
    -- whose band is set EXPLICITLY open was refused by this check. Found by
    -- mutation (§416): the fixture used `band = nil` and never entered the path.
    -- ★ nil and OPEN are the same INTENT expressed two ways, and a rule that
    -- accepts one and refuses the other punishes being explicit.
    local band = node.band
    if band ~= nil and band ~= Rule.OPEN and not finite(band) then
        return false, "band not usable"
    end

    if Rule.PointFire(sample, node, r * r, band) then return true, "point" end
    return false, "outside"
end

return Rule
