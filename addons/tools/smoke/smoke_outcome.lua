-- Model: addons/planning/DRIVER_BASIS.md
--
-- ★★★ P4 · OUTCOME GRADING — the driver graded on OUTCOMES at the ruled radii and the
-- ruled cadence (W7 rescoped 2026-08-20, RI-33).
--
-- ⚠⚠ NOT byte-equality. W7.1 says it plainly: *"This no longer grades the shipped driver —
-- the driver has no segment to be equal about."* So there is no desk answer to match; the
-- grade is what the rule DOES to a real path, measured against properties that must hold
-- whatever the implementation.
--
-- ★ AND TWO OF W7.2's FOUR NAMED BRANCHES CANNOT BE GRADED HERE, because they no longer
-- exist in the driver — the same sentence above is why:
--
--     mapID straddle   ✓ graded (smoke_rule, and again below on a real path)
--     non-finite       ✓ graded (smoke_rule; NaN and inf as separate fixtures)
--     the CLAMP W1.9   ✗ `t = clamp(fe/ee, 0, 1)` — there is no `t` without a segment
--     the GAP BOUND    ✗ its fixture is "two samples 40 yd apart must NOT BRIDGE", and
--       W1.10            BRIDGING is what a segment does. Point-only never bridges.
--
-- ⚠ REPORTED, not resolved: W7.2's list still names all four. W7.1's sentence settles the
-- substance and the row has not caught up — the same shape as A11.2a before §418.

local here = debug.getinfo(1, "S").source:match("@(.*[/\\])") or ""
local Rule = assert(dofile(here .. "../../COA_DungeonRun/rule.lua"), "rule.lua missing")
local S = assert(dofile(here .. "fixtures_samples.lua"), "fixtures_samples.lua missing")

local rfc = assert(S["rfc_combat-20"], "the rfc_combat samples are missing")
local sfk = assert(S["SFK_live-12"], "the SFK_live samples are missing")

-- ★ DECIMATE TO A CADENCE, exactly as the throttle would. ⚠ A SUBSET, never a resample -
-- interpolating would invent positions the player was never at, and the whole question is
-- whether a REAL position was inside a radius.
local function atCadence(rows, every)
    local out, last = {}, nil
    for _, r in ipairs(rows) do
        if not last or r.gt - last >= every - 1e-9 then
            out[#out + 1] = r
            last = r.gt
        end
    end
    return out
end

-- ★ THE OUTCOME COLUMNS ARE W7.3's: hit · skips. ⚠ `stage` is NOT a result (bench posture
-- §7), so nothing here reports one.
local function grade(rows, node)
    local hit, seen = 0, 0
    for _, s in ipairs(rows) do
        seen = seen + 1
        if Rule.Evaluate(s, node) then hit = hit + 1 end
    end
    return hit, seen
end

local function nodeAt(s, r, band)
    return { x = s.x, y = s.y, z = s.z, mapID = s.mapID, r = r, band = band }
end

-- ★★★ A BAND THAT DOES NOT CONSTRAIN, DERIVED FROM THE CORPUS ITSELF.
--
-- ⚠ These rows grade the RADIUS, the GATE and the CADENCE. They need the band out of the
-- way, and until A11.2h they said `Rule.OPEN` — `math.huge`. ⟶ That sentinel is GONE from
-- the code (Battlewrath: *"No infinity living in code to ever reach that"*), and a smoke has
-- no business reintroducing one it can no longer be handed.
-- ★ So the fixture computes it: **taller than the greatest rise this path actually contains,
-- plus a yard.** That is a real number, it is honest about what it is doing, and it moves with
-- the data instead of asserting a constant nobody measured.
local function unconstraining(rows)
    local lo, hi = rows[1].z, rows[1].z
    for _, s in ipairs(rows) do
        if s.z < lo then lo = s.z end
        if s.z > hi then hi = s.z end
    end
    return (hi - lo) + 1
end
local RFC_OPEN = unconstraining(rfc)
local SFK_OPEN = unconstraining(sfk)
assert(RFC_OPEN > 1 and SFK_OPEN > 1,
       "the unconstraining band collapsed to its +1 floor - a corpus path with no z "
       .. "variation at all would make every band row below vacuous")

-- =====================================================================
-- ★★★ THE FLOOR IS A CORRECTNESS SETTING — RI-34, demonstrated on a real path.
--
-- A beacon placed ON a sample the player really occupied MUST be hit. ⚠ Under point-only
-- there is no chord to catch a pass the samples missed, so if the cadence is too coarse the
-- beacon is simply missed — which is why RI-34 moved the floor to 0.1 and why this is a
-- correctness row rather than a cost one.
-- =====================================================================
local target = rfc[900]
assert(target, "the fixture must be long enough to place a mid-path beacon")

for _, R in ipairs({ 5, 8, 20, 50 }) do
    local hit = grade(rfc, nodeAt(target, R, RFC_OPEN))
    assert(hit >= 1,
           ("A BEACON ON A REAL SAMPLE WAS MISSED at R=%d: the player stood exactly there, "
            .. "so no cadence and no radius can excuse it. Point-only has no chord to fall "
            .. "back on"):format(R))
end

-- ★★ AND A BIGGER RADIUS NEVER CATCHES LESS. Monotonicity is weak as a guard on its own -
-- a broken rule that fires MORE also passes it - but it is the one property a radius must
-- have, and it fails loudly on an inverted comparison.
local last = -1
for _, R in ipairs({ 2, 5, 8, 20, 50 }) do
    local hit = grade(rfc, nodeAt(target, R, RFC_OPEN))
    assert(hit >= last,
           ("A LARGER RADIUS CAUGHT FEWER SAMPLES at R=%d: %d after %d"):format(R, hit, last))
    last = hit
end

-- =====================================================================
-- ⚠⚠ THE mapID GATE, ON A REAL PATH — and this is the branch that only real data reaches.
--
-- The two runs are on DIFFERENT maps (rfc 389, SFK 33). Placing a node from one run and
-- feeding it the other run's samples is the straddle W7.2 names, with real coordinates
-- rather than constructed ones.
-- =====================================================================
assert(rfc[1].mapID ~= sfk[1].mapID,
       "the fixture assumes two runs on DIFFERENT maps and they are the same - the "
       .. "straddle row below would be vacuous")

-- ⚠⚠ THE COINCIDENCE IS CONSTRUCTED, and it has to be. A first cut placed an rfc
-- node against SFK samples and the mutation removing the GATE SURVIVED - the two runs'
-- real coordinates are far apart, so the RADIUS refused it and the gate was never
-- reached. ★ The row passed for the wrong reason, exactly like §416's zero-radius row.
-- ⟶ So the node takes an SFK sample's OWN coordinates and only its mapID is changed:
-- geometry now says HIT on every count, and the only thing that can refuse it is the gate.
local decoy = nodeAt(sfk[500], 50, SFK_OPEN)
decoy.mapID = rfc[1].mapID
assert(grade(sfk, nodeAt(sfk[500], 50, SFK_OPEN)) >= 1,
       "the decoy's own map must FIRE, or the cross-map row proves nothing")
assert(grade(sfk, decoy) == 0,
       "THE GATE WAS SKIPPED ON A REAL PATH: this node sits on the player's own recorded "
       .. "position and differs ONLY in mapID. Geometry says hit on every sample; the gate "
       .. "is the one thing that can refuse it")

local crossHit = grade(sfk, nodeAt(rfc[900], 50, SFK_OPEN))
assert(crossHit == 0,
       ("A NODE FROM ANOTHER MAP FIRED %d TIME(S) ON A REAL PATH: two maps' coordinates "
        .. "are unrelated, so proximity between them is a COINCIDENCE. R=50 is used "
        .. "deliberately - the biggest ruled radius, so nothing is passing by being small")
       :format(crossHit))

-- =====================================================================
-- ★★ NO FALSE ADVANCES (W7.3's third column). A node far from every sample must never
-- fire, at any ruled radius.
-- =====================================================================
local far = nodeAt(rfc[900], 50, RFC_OPEN)
far.x = far.x + 5000
assert(grade(rfc, far) == 0,
       "A NODE 5000 YD AWAY FIRED: that is a false advance, and it is the failure a "
       .. "runner cannot diagnose - the route simply moves on without them")

-- =====================================================================
-- ★★★ THE BAND IS UPWARD ONLY, on a real path (RI-22).
-- ⚠ A node placed BELOW the player's own samples must never fire, however close in xy.
-- =====================================================================
-- ★★ ONE-SIDEDNESS, and it needs a SMALL offset the wrong way. ⚠ A first cut used a
-- node 10 yd BELOW the path - dz = +10, which the band refuses on MAGNITUDE - so the
-- mutation making the band two-sided SURVIVED. The row tested the band's SIZE and was
-- named for its DIRECTION.
-- ⟶ A node 1 yd ABOVE the path gives dz = -1: inside a two-sided 2.5 band, outside a
-- one-sided one. Nothing but the direction test can refuse it.
-- ⚠⚠ AND IT MUST SIT ABOVE **EVERY IN-RADIUS SAMPLE**, not above `target`. A real path
-- varies in z, so a node one yard over ONE sample is still BELOW others - and those give
-- a legitimate positive dz and fire. The first cut did exactly that and went red on the
-- unmutated tree, which is the fixture being wrong rather than the rule.
local justAbove = nodeAt(target, 50, 2.5)
local topZ = -math.huge
for _, s in ipairs(rfc) do
    local dx, dy = s.x - target.x, s.y - target.y
    if dx * dx + dy * dy <= 50 * 50 and s.z > topZ then topZ = s.z end
end
justAbove.z = topZ + 1
assert(grade(rfc, justAbove) == 0,
       "A NODE 1 YD ABOVE THE PATH FIRED: dz is NEGATIVE and well inside 2.5, so only "
       .. "the band's ONE-SIDEDNESS can refuse it. RI-22 made the band upward only "
       .. "because a captured sample IS the floor - a player BELOW a beacon is not at it")

local below = nodeAt(target, 50, 2.5)
below.z = below.z - 10
assert(grade(rfc, below) == 0,
       "A NODE 10 YD BELOW THE PATH FIRED: dz is +10 and the band is 2.5, so this row "
       .. "grades the band's MAGNITUDE rather than its direction - kept for that, and "
       .. "labelled so it is not mistaken for the one-sidedness row above")

local above = nodeAt(target, 50, 2.5)
above.z = above.z + 10
assert(grade(rfc, above) == 0,
       "A NODE 10 YD ABOVE THE PATH FIRED THROUGH A 2.5 BAND: the band bounds how far "
       .. "ABOVE the node a sample may be, and 10 is not within 2.5")

-- =====================================================================
-- ★ THE READOUT, printed rather than asserted - the numbers a person reads.
-- =====================================================================
-- ⚠⚠ AND THE LIMIT OF THIS TABLE, STATED SO IT IS NOT READ PAST. The FASTEST
-- captured run has a median dt of 0.203 s - measured on these very fixtures - so
-- **NO CORPUS RUN SAMPLES AT 0.1**, and the "0.1" row below is the source data
-- unthinned rather than a finer cadence. ★ RI-34's floor rests on ARITHMETIC
-- (`FLOOR < 2R/v`), and captured data can only show the 0.2-versus-1 Hz contrast.
-- ⚠ A row that cannot demonstrate the thing it is named after has to SAY so; the
-- alternative is a table that looks like evidence for a number it never tested.
local fastest = math.huge
for i = 2, #rfc do fastest = math.min(fastest, rfc[i].gt - rfc[i-1].gt) end
assert(fastest > 0.1,
       "THE CORPUS NOW SAMPLES AT OR BELOW 0.1 - this row's caveat is stale and the "
       .. "0.1 floor became demonstrable from real data. Re-read it")

print("  outcome grading - a beacon on a real sample, by radius and cadence:")
print(("    %-8s %-9s %-7s %s"):format("cadence", "samples", "R", "hits"))
print("    ⚠ 0.1 is the SOURCE data (median dt 0.203) - not a finer cadence")
for _, every in ipairs({ 0.1, 0.2, 1.0 }) do
    local rows = atCadence(rfc, every)
    for _, R in ipairs({ 5, 20 }) do
        local hit, seen = grade(rows, nodeAt(target, R, unconstraining(rows)))
        print(("    %-8.1f %-9d %-7d %d"):format(every, seen, R, hit))
    end
end

print("smoke_outcome: OK - outcomes at the ruled radii; clamp and gap-bound NOT graded "
      .. "(no segment to clamp or bridge)")
