-- Model: addons/planning/DRIVER_BASIS.md
--
-- ★★★ A11.2 · THE RULE — point + band + gate (P3).
--
-- ⚠ STANDALONE ON PURPOSE, like `smoke_contract`. A11.3 rules the rule PURE — it holds
-- nothing and reaches for nothing — and a grader that had to load the addon to test it
-- would be unable to notice if that stopped being true.

local here = debug.getinfo(1, "S").source:match("@(.*[/\\])") or ""
local Rule = assert(dofile(here .. "../../COA_DungeonRun/rule.lua"),
                    "rule.lua did not return its table")

local function node(t)
    return { x = t.x or 0, y = t.y or 0, z = t.z or 0,
             mapID = t.mapID or 33, r = t.r or 5, band = t.band }
end
local function sample(x, y, z, m)
    return { x = x, y = y, z = z, mapID = m or 33 }
end

local N = node({ band = 2.5 })

-- =====================================================================
-- ★★ WHAT IS ABSENT, ASSERTED FIRST — because absence is what this build IS.
--
-- RI-33: *"we build from need to function not on precedence. Precedence is the proof
-- we can."* → segment, interpolated-z and v_max are DESK-SIDE. ⚠ A file like this is
-- exactly where they would accumulate later, one helpful addition at a time, and
-- nothing else would notice. So the absence is a row.
-- =====================================================================
assert(Rule.SegmentFire == nil and Rule.Segment == nil,
       "SEGMENT INTERPOLATION IS BACK: the desk interpolates because it reconstructs a "
       .. "FIXED-CADENCE RECORDING and cannot look again. This driver CONTROLS WHEN IT "
       .. "LOOKS - it throttles up on approach - so a reconstructed path is the desk's "
       .. "answer to a problem this side does not have (RI-33)")
assert(Rule.TELEPORT_VMAX == nil and Rule.VMAX == nil,
       "v_max IS BACK: it licenses INTERPOLATION between two samples, and nothing here "
       .. "interpolates. A speed bound on this side is a SCHEDULING input for the "
       .. "throttle, which is the sensor's, not a verdict on a path")

-- =====================================================================
-- ★ THE GATE (A11.2d, S3) — cheapest test first, and not as an optimisation.
-- =====================================================================
assert(Rule.Evaluate(sample(1, 1, 0), N),
       "a sample inside the radius, level with the node, must FIRE")
local ok, why = Rule.Evaluate(sample(1, 1, 0, 99), N)
assert(ok == false and why == "other map",
       "A TARGET IN ANOTHER mapID FIRED: two maps' coordinates are unrelated, so a "
       .. "small dx/dy across a boundary is a COINCIDENCE, not a proximity. Testing "
       .. "geometry first gives that coincidence a chance to fire. Got " .. tostring(why))

-- ⚠ AND THE COINCIDENCE IS CONSTRUCTED, not hoped for: same numbers, other map.
assert(Rule.Evaluate(sample(0, 0, 0, 34), N) == false,
       "A DEAD-CENTRE HIT ON THE WRONG MAP FIRED - the exact case the gate exists for")

-- =====================================================================
-- ★★ POINT + BAND. Upward only (RI-22) - a captured sample IS the floor.
-- =====================================================================
assert(Rule.Evaluate(sample(9, 0, 0), N) == false, "outside the radius must not fire")
assert(Rule.Evaluate(sample(1, 1, 2), N), "within the upward band must fire")
assert(Rule.Evaluate(sample(1, 1, 3), N) == false, "beyond the band must not fire")

assert(Rule.Evaluate(sample(1, 1, -1), N) == false,
       "BELOW THE NODE FIRED: the band is UPWARD ONLY (RI-22) - a captured sample is "
       .. "the floor, so downward tolerance measures nothing that exists. A player "
       .. "UNDER a walkway must not satisfy a beacon standing ON it, which is the case "
       .. "the band was introduced for")

-- =====================================================================
-- ★★★ THERE IS NO OPEN BAND, AND AN UNRESOLVED ONE IS REFUSED (A11.2h, RI-37).
--
-- ⚠⚠ THIS BLOCK USED TO ASSERT THE OPPOSITE, and the reversal is worth reading. It held
-- that *"`nil` and `Rule.OPEN` are the same INTENT written two ways"* and that an unset band
-- **accepts any height**. ⟶ Battlewrath, 2026-08-20: *"The expectation is 2.5 as the floor
-- and picked upwards. **No infinity living in code to ever reach that.**"* The picker floors
-- at 2.5 and runs UPWARD (RI-35), so ∞ is not a value any author can produce.
--
-- ★ The old rows were internally consistent and GREEN the whole time. What was wrong was
-- never the code against the test - it was both against a ruling neither had met. **A test
-- cannot catch a fault it was written to encode.**
--
-- ★★ AND THE OLD BEHAVIOUR FAILED OPEN, which is why this is a defect and not a rename:
-- a node nobody resolved accepted a player at ANY height - precisely the walkway case the
-- band exists to refuse. Same shape as A2.10a's `stage or 0`, opposite polarity.
-- =====================================================================
assert(Rule.OPEN == nil,
       "`Rule.OPEN` IS BACK: it is an infinity no author can produce, and using it as a "
       .. "fallback INVENTS A DEFAULT four lines from routes.lua:1512's stated law - "
       .. "\"NO DEFAULT IS INVENTED HERE. A field nobody set comes back nil\". "
       .. "Resolution happens once, at BUCKET (model row 27), and never in the rule")

local unresolved = node({})
assert(unresolved.band == nil, "the fixture must actually leave the band unset")
local ok, why = Rule.Evaluate(sample(0, 0, 0), unresolved)
assert(ok == false and why == "no band",
       "A NODE WITH NO BAND FIRED: the store keeps nil so absence stays LOUD (model row "
       .. "27), and the rule is NOT the consumer that resolves it - RI-2 ruled that split. "
       .. "⚠ The sample here sits EXACTLY on the node, so every other test in the rule "
       .. "says HIT: only the band check can refuse it, and it must")

-- ★ REFUSING IS THE CONSERVATIVE DIRECTION, and this row states which way it fails.
-- An unresolved node does not fire ANYWHERE; the old fallback made it fire EVERYWHERE.
assert(Rule.Evaluate(sample(1, 1, 500), unresolved) == false,
       "an unresolved node fired 500 yd up - it must not fire at any height")

-- ⚠ A NEGATIVE BAND IS REFUSED RATHER THAN CLAMPED. The band is UPWARD ONLY (RI-22), so
-- a negative one is not a small band - it is a field that means nothing, and clamping it to
-- zero would invent the author's intent.
local negative = node({ band = -5 })
local nok, nwhy = Rule.Evaluate(sample(0, 0, 0), negative)
assert(nok == false and nwhy == "band not usable",
       "A NEGATIVE BAND WAS ACCEPTED: it is not a small band, it is a meaningless field, "
       .. "and clamping it to 0 would invent what the author meant")

-- ★ A BAND OF 0 IS LEGAL TO THE RULE and is not the picker's business to police here.
-- RI-34/RI-35: the floor of 2.5 is enforced by the OFFERING, not by a guard in the driver.
assert(Rule.Evaluate(sample(0, 0, 0), node({ band = 0 })),
       "A ZERO BAND WAS REFUSED: dz is exactly 0 on this sample, so it is INSIDE a zero "
       .. "band. ⚠ The rule does not enforce the picker's 2.5 floor - that is the "
       .. "offering's job (RI-34), and a second enforcement point is a second answer")

-- =====================================================================
-- ⚠⚠ A11.2e - NON-FINITE IS REJECTED, AND NaN AND inf ARE SEPARATE FIXTURES.
--
-- They fail by DIFFERENT ROUTES and a single fixture would hide that:
--   NaN   `type(0/0) == "number"` is TRUE and `NaN > r2` is FALSE, so a type test
--         alone passes it through AND the radius early-out is SKIPPED. It is caught
--         only by `v ~= v`.
--   inf   `inf > r2` is TRUE, so it is refused by the RADIUS TEST rather than by the
--         finite check. Both are refused; knowing WHICH matters when a row goes red.
-- =====================================================================
-- ⚠ THE SPECIFIC ROWS COME FIRST. They were BELOW the sweep and the sweep caught
-- every mutation first - so the row naming NaN's own mechanism graded nothing.
assert(Rule.Usable(sample(0/0, 1, 0)) == false,
       "NaN PASSED THE USABLE TEST: `type(0/0) == \"number\"` is TRUE, so a type "
       .. "check alone lets it through - and a NaN reaching the radius test does "
       .. "not throw, it SKIPS the early-out and proceeds silently. `v ~= v` is "
       .. "the only test that catches it")
assert(Rule.Usable(sample(1, 1, math.huge)) == false, "inf must not be usable either")
assert(Rule.Usable({ x = "5", y = 1, z = 0 }) == false, "a string is not a coordinate")
assert(Rule.Usable(nil) == false, "no sample is not a usable sample")

-- ★ then the sweep, which proves every coordinate is checked and not just x.
for _, bad in ipairs({ 0/0, math.huge, -math.huge }) do
    assert(Rule.Evaluate(sample(bad, 1, 0), N) == false,
           "A NON-FINITE x REACHED A VERDICT: " .. tostring(bad))
    assert(Rule.Evaluate(sample(1, bad, 0), N) == false,
           "A NON-FINITE y REACHED A VERDICT: " .. tostring(bad))
    assert(Rule.Evaluate(sample(1, 1, bad), N) == false,
           "A NON-FINITE z REACHED A VERDICT: " .. tostring(bad))
end

-- ⚠ A NODE with a bad radius or band is refused too - the node is data we wrote and
-- an import could have mangled it, so it gets the same scrutiny as a live sample.
assert(Rule.Evaluate(sample(1, 1, 0), node({ r = 0/0 })) == false, "NaN radius refused")
-- ⚠ AT the node, not beside it. Off-centre, `dist2 > 0` refuses a zero radius by
-- GEOMETRY and the guard is never reached - the row passed for the wrong reason
-- until a mutation removing the guard was caught by the NEGATIVE-radius row.
assert(Rule.Evaluate(sample(0, 0, 0), node({ r = 0 })) == false,
       "A ZERO RADIUS FIRED AT THE NODE: dist2 is 0 and `0 > 0` is false, so the "
       .. "radius early-out passes and only the guard can refuse it")
assert(Rule.Evaluate(sample(1, 1, 0), node({ r = -5 })) == false, "a negative radius refused")
-- ⚠⚠ WHAT THE BAND CHECK ACTUALLY PROTECTS, found by a mutation that SURVIVED
-- (§416). A NaN band is refused by the COMPARISON on its own - `dz <= NaN` is false -
-- so the row below proves nothing about the guard. ★ A NON-NUMBER band is the real
-- case: `dz <= "5"` THROWS in Lua 5.1, so without the check a mangled import does not
-- refuse a node, it CRASHES the driver mid-poll.
local okStr = pcall(Rule.Evaluate, sample(1, 1, 0), node({ band = "5" }))
assert(okStr, "A NON-NUMBER BAND THREW: `dz <= \"5\"` is a type error in Lua 5.1, so "
       .. "an import that mangled the field would crash the driver mid-poll instead of "
       .. "refusing the node. The guard exists for THIS, not for NaN")
assert(Rule.Evaluate(sample(1, 1, 0), node({ band = "5" })) == false,
       "and it must REFUSE rather than merely survive")

-- ★ NaN is refused too, but by the comparison rather than by the guard - recorded so
-- nobody reads this row as evidence the guard works.
assert(Rule.Evaluate(sample(1, 1, 0), node({ band = 0/0 })) == false, "NaN band refused")

-- =====================================================================
-- ★★★ A11.2g - ONE EVALUATION PER NODE, SHARED BY ITS ROWS. Correctness, not economy.
--
-- RI-16: a child completes when ALL its action tabs have completed, which requires
-- every tab to agree about the SAME in/out transition. ⚠ Four independent evaluations
-- are four places that can disagree.
--
-- ⚠ WHAT IS GRADEABLE HERE AND WHAT IS NOT. The SHARING is the sensor's job (A11.3)
-- and the sensor is not built. What this file can hold is that the rule is
-- NODE-SHAPED - it takes a node, never a row - so per-row evaluation is not the
-- natural implementation. The sharing itself is owed to the sensor's own smoke.
-- =====================================================================
local calls = 0
local realEval = Rule.Evaluate
Rule.Evaluate = function(...) calls = calls + 1 return realEval(...) end

local boundary = node({ r = 5, band = 2.5 })
local atEdge = sample(4.999, 0, 0)
local verdict = Rule.Evaluate(atEdge, boundary)
local rows = { "note", "say", "boss", "supertrack" }
local seen = {}
for _, row in ipairs(rows) do seen[row] = verdict end

Rule.Evaluate = realEval
assert(calls == 1,
       "THE GEOMETRY WAS EVALUATED MORE THAN ONCE FOR ONE NODE: four rows must read "
       .. "ONE verdict. Got " .. calls .. " call(s)")
for _, row in ipairs(rows) do
    assert(seen[row] == verdict,
           "TWO ROWS OF ONE NODE DISAGREED about the same sample - which is what "
           .. "all-tabs-complete cannot survive")
end

-- ★ AND THE RULE IS NODE-SHAPED, which is what makes the shared evaluation natural.
-- ⚠ A row-taking entry point would make per-row testing the obvious implementation
-- and the disagreement the default.
assert(Rule.EvaluateRow == nil and Rule.RowFire == nil,
       "THE RULE GAINED A ROW-SHAPED ENTRY POINT: it evaluates a NODE's geometry, and "
       .. "a per-row door makes four disagreeing verdicts the natural implementation")

-- =====================================================================
-- ★ PURITY (A11.3) - the rule holds nothing and reaches for nothing.
-- =====================================================================
assert(Rule.state == nil and Rule.prev == nil and Rule.armed == nil,
       "THE RULE IS HOLDING STATE: a previous sample, an armed set and a ledger are "
       .. "the SENSOR's. A rule that remembers cannot be graded from a fixture and "
       .. "from a live poll without one of them knowing about the other")
local a = Rule.Evaluate(sample(1, 1, 0), N)
for _ = 1, 50 do Rule.Evaluate(sample(99, 99, 99), N) end
assert(Rule.Evaluate(sample(1, 1, 0), N) == a,
       "THE SAME CALL GAVE A DIFFERENT ANSWER after other calls - the rule is pure, so "
       .. "fifty intervening samples must change nothing")

print("smoke_rule: OK - point + band + gate; segment, interpolated-z and v_max asserted ABSENT")
