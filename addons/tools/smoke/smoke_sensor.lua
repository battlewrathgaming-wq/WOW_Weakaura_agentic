-- Model: addons/planning/DRIVER_BASIS.md
--
-- ★★★ A11.4 / A11.7c · THE SENSOR — arm(list) / disarm(), the approach throttle, and the
-- resolved inventory (P5).
--
-- ⚠ STANDALONE, for `smoke_rule`'s reason inverted. The rule is graded standalone so it
-- cannot quietly start reaching for the addon. The SENSOR is graded standalone so the frame
-- it creates is OURS — a stub whose OnUpdate we can watch arrive and leave. Loaded into the
-- suite's shared FrameXML stub, "no persistent OnUpdate" would be a claim about a table we
-- do not own.

local here = debug.getinfo(1, "S").source:match("@(.*[/\\])") or ""
local Rule = assert(dofile(here .. "../../COA_DungeonRun/rule.lua"))
_G.COA_DungeonRun_NS = { Rule = Rule }
local Sensor = assert(dofile(here .. "../../COA_DungeonRun/sensor.lua"),
                      "sensor.lua did not return its table")

-- ★ THE STUB IS THE INSTRUMENT. It records what was set, so `nil` is observable rather
-- than merely un-crashing.
local stub = { scripts = {}, made = 0 }
function stub:SetScript(k, fn) self.scripts[k] = fn end
Sensor.CreateFrame = function() stub.made = stub.made + 1 return stub end

local function node(t)
    return { x = t.x or 0, y = t.y or 0, z = t.z or 0,
             mapID = t.mapID or 33, r = t.r or 5, band = t.band,
             address = t.address }
end
local function sample(x, y, z, m)
    return { x = x, y = y, z = z, mapID = m or 33 }
end

-- =====================================================================
-- ★★ ABSENT FIRST — the split A11.3 draws, asserted rather than assumed.
-- =====================================================================
assert(Sensor.PointFire == nil and Sensor.Gate == nil and Sensor.Evaluate == nil,
       "THE SENSOR GREW ITS OWN GEOMETRY: A11.3 splits the pure RULE from the stateful "
       .. "SENSOR precisely so the rule can be graded from a fixture. A second copy of "
       .. "the test here is a second answer that can disagree with the first")
assert(stub.scripts.OnUpdate == nil,
       "AN OnUpdate WAS INSTALLED BEFORE ANYTHING WAS ARMED")
-- ⚠⚠ AND THIS ROW STATES ITS OWN LIMIT. A first cut also asserted `stub.made == 0` and
-- called it 'no frame at load'. ★ Mutation put a `CreateFrame` at the top of `sensor.lua`
-- and the row SURVIVED - the stub is installed AFTER `dofile`, so a load-time call reaches
-- the real default and this file can never see it. The assert was reading its own
-- construction, not the sensor.
-- ⟶ What IS reachable is that ARM creates the frame, and creates ONE. A load-time
-- `CreateFrame` against the client global is `check_interface`'s and the addon-level
-- smoke's ground, not this standalone's.

-- =====================================================================
-- ★★★ ARM / DISARM (A11.4a, A11.7c) — 'nothing armed, nothing RUNNING'.
--
-- ⚠ The criterion is not 'nothing happening'. A permanent OnUpdate that returns early on
-- a flag is still called every frame, and it passes every test written as 'nothing
-- happened'. So the row reads the HANDLER, not the effect.
-- =====================================================================
local N = node({ band = 2.5, address = "33:1:1" })
assert(Sensor.IsArmed() == false, "armed before Arm was called")
assert(Sensor.Poll(sample(0, 0, 0)) == nil,
       "A DISARMED SENSOR EVALUATED: arming is the whole of its lifecycle, so polling "
       .. "outside it means the lifecycle is decorative")

Sensor.Arm({ N })
assert(Sensor.IsArmed(), "Arm did not arm")
assert(type(stub.scripts.OnUpdate) == "function",
       "ARMING INSTALLED NO OnUpdate: the sensor cannot sample on its own schedule")

Sensor.Disarm()
assert(Sensor.IsArmed() == false, "Disarm left the sensor armed")
assert(stub.scripts.OnUpdate == nil,
       "DISARM LEFT THE OnUpdate INSTALLED: A11.4a - 'the accumulator exists ONLY while "
       .. "armed'. A handler that survives disarm runs on every frame of a session that "
       .. "never enters a dungeon")
-- ⚠ And the handler must be inert if it is somehow still reached, because the two failures
-- are independent: one leaks CPU, the other evaluates against a list that is gone.
assert(Sensor.OnUpdate(nil, 99) == nil and Sensor.Poll(sample(0, 0, 0)) == nil,
       "THE HANDLER STILL WORKED WHILE DISARMED")

-- ★ ONE FRAME, REUSED. A frame per arm is unreclaimable in this client - `CreateFrame` has
-- no inverse - so a run that arms per pull leaks for the session.
Sensor.Arm({ N }); Sensor.Disarm(); Sensor.Arm({ N }); Sensor.Disarm()
assert(stub.made == 1,
       "ARM CREATED " .. stub.made .. " FRAMES: a frame per arm never comes back - this "
       .. "client's CreateFrame has no inverse - so arming per pull leaks all session")

-- =====================================================================
-- ★★★ THE RESOLVED INVENTORY (A11.3) — the sensor *"keeps a running inventory of the
-- RESOLVED position(Parameters)"*, which is a snapshot in his own words.
--
-- ⚠⚠ THIS ROW WAS FIRST WRITTEN AGAINST A11.4b AND THAT WAS THE WRONG LANE. A11.4b's test is
-- 'arm, then break the config table'; RI-22 settled that the store holds NUMBERS, so there is
-- no table to break, and the bench re-aimed the requirement at the node record to keep it
-- alive here. ★ Battlewrath corrected it: *"'read a table per value' is on the PICKER side.
-- The sensor its self will have absolute values by the time it reaches it. Defined in the
-- BID:CID or BID for that POS of the node."*
-- ⟶ The row survives with a different warrant and a narrower claim: **the armed inventory
-- cannot change underneath a run.** Arm, then move the node and inflate its radius; a sensor
-- holding a reference follows an authoring edit mid-pull, a sensor holding a snapshot does
-- not. ⚠ That is NOT a per-sample cost argument, which is the picker's business.
-- =====================================================================
local live = node({ x = 0, y = 0, r = 5, band = 2.5 })
Sensor.Arm({ live })
local near = sample(3, 0, 0)
local far = sample(400, 0, 0)
assert(#Sensor.Poll(near) == 1 and #Sensor.Poll(far) == 0, "fixture wrong before mutation")

live.r = 100000
live.x = 400
assert(#Sensor.Poll(far) == 0,
       "THE SENSOR RE-READ THE NODE MID-RUN: it was armed on a node at the origin with "
       .. "r=5 and the record was then moved to the far sample with a huge radius. A held "
       .. "reference follows the edit; a snapshot does not. ⚠ A11.3's inventory is RESOLVED "
       .. "- an authoring edit must not move a beacon mid-pull")
assert(#Sensor.Poll(near) == 1,
       "THE SNAPSHOT WAS LOST: the resolved values must still fire on the sample they "
       .. "were armed for")
Sensor.Disarm()

-- =====================================================================
-- ★★★ THE APPROACH THROTTLE (A11.2f) — slack = (dist - R) / MAX_CLOSING_SPEED, clamped.
-- =====================================================================
Sensor.Arm({ node({ x = 0, y = 0, r = 5 }) })

assert(Sensor.NextIn(sample(2, 0, 0)) == Sensor.POLL_MIN,
       "A SAMPLE INSIDE THE RADIUS DID NOT GET THE FLOOR: the negative slack must clamp "
       .. "up, not divide into a negative interval")
assert(Sensor.NextIn(sample(5, 0, 0)) == Sensor.POLL_MIN,
       "A SAMPLE ON THE EDGE DID NOT GET THE FLOOR: slack is zero there")
assert(Sensor.NextIn(sample(100000, 0, 0)) == Sensor.POLL_MAX,
       "A SAMPLE 100000 YD AWAY DID NOT GET THE BASE RATE: without the ceiling the "
       .. "schedule walks off to minutes and the driver stops noticing the player at all")

-- ★ THE INTERIOR, and it must be the interior. ⚠ Both clamps pass on a `return POLL_MIN`
-- and on a `return POLL_MAX` respectively, so a row between them is the only one that
-- grades the ARITHMETIC.
-- ⚠⚠ AND IT DERIVES ITS EXPECTATION FROM THE CONSTANTS RATHER THAN HARD-CODING 0.5.
-- A first cut used `55 yd -> 0.5 s`, which encodes MAX_CLOSING_SPEED = 100 inside a row
-- named for the FORMULA. ★ Changing the constant would then fire "the arithmetic is
-- wrong" instead of the constant's own row below - the specific-behind-general fault,
-- with the general row wearing the specific one's name.
local want = (Sensor.POLL_MIN + Sensor.POLL_MAX) / 2       -- lands mid-band by construction
local d = 5 + want * Sensor.MAX_CLOSING_SPEED
local mid = Sensor.NextIn(sample(d, 0, 0))
assert(math.abs(mid - want) < 1e-9,
       "THE THROTTLE'S ARITHMETIC IS WRONG: " .. d .. " yd out from a 5 yd radius is "
       .. (d - 5) .. " yd of approach, which at MAX_CLOSING_SPEED = "
       .. Sensor.MAX_CLOSING_SPEED .. " is " .. want .. " s. Got " .. tostring(mid))
assert(mid > Sensor.POLL_MIN and mid < Sensor.POLL_MAX,
       "the interior row is not in the interior - it is grading a clamp")

-- ★★ THE THROTTLE NEVER DIVIDES BY A MEASURED SPEED. ROUTER (2026-08-20): GetUnitSpeed
-- reports the MOVEMENT-STATE rate (7 running, 14 mounted) while the corpus holds real
-- displacement at 56.9 - so a schedule taken from the reading under-polls in exactly the
-- case the throttle exists for. It is the cheap slow-poll WITNESS, never the divisor.
assert(Sensor.GetSpeed == nil and Sensor.UnitSpeed == nil,
       "THE THROTTLE GAINED A SPEED READING: the divisor is a SAFETY BOUND whose errors "
       .. "are asymmetric - too high costs samples, too low costs a beacon")

-- ★ THE GATE APPLIES TO THE SCHEDULE TOO. A node on another map is arbitrarily close in
-- raw coordinates, and a schedule that believed it would pin the floor for a whole run.
Sensor.Arm({ node({ x = 0, y = 0, r = 5, mapID = 999 }) })
assert(Sensor.NextIn(sample(1, 1, 0, 33)) == Sensor.POLL_MAX,
       "A NODE ON ANOTHER MAP DROVE THE SCHEDULE: its coordinates sit 1 yd away in a "
       .. "different space entirely. Without the gate here the sensor polls at the floor "
       .. "for the whole session on a coincidence")
assert(Sensor.NextIn(nil) == Sensor.POLL_MAX and Sensor.NextIn({ x = 0 }) == Sensor.POLL_MAX,
       "AN UNUSABLE SAMPLE DID NOT FALL BACK TO THE BASE RATE")

-- =====================================================================
-- ★★★ RI-34's DERIVATION, KEPT LIVE — the two constants own DIFFERENT failures and the
-- pair is what closes the hole. Fixing either alone leaves the beacon missable.
--
-- A player crossing a node at the fastest displacement we admit to covers
-- POLL_MIN x MAX_CLOSING_SPEED yards between samples. To be seen, that must fit inside
-- the diameter of the SMALLEST ruled radius. ★ At 0.1 x 100 = 10 and R_MIN = 5, it fits
-- EXACTLY - which is the RI-34 finding, not a coincidence to leave undocumented.
-- ⚠ 0.2 x 100 = 20 fails by 2x. 0.1 x 30 passes this row but under-schedules the
-- APPROACH, so both rows are needed.
-- =====================================================================
-- ★ R_MIN = 5 IS RULED, not derived here. It is the FLOOR OF THE PICKER DROPDOWN
-- (Battlewrath, RI-34) — and RI-35 closed the menu around it: *"User pick. R 5 the lowests."*
-- ⚠ So it is enforced by the OFFERING, not by a guard in the driver, and this row does not
-- imply one is owed. RI-34 already struck that claim as a scope fault — it read `setReach`'s
-- bare `tonumber` and concluded the minimum was unenforced everywhere, without checking the
-- door the author actually uses.
local R_MIN = 5
assert(Sensor.POLL_MIN * Sensor.MAX_CLOSING_SPEED <= 2 * R_MIN,
       "THE BEACON IS MISSABLE: at POLL_MIN=" .. Sensor.POLL_MIN .. " and "
       .. "MAX_CLOSING_SPEED=" .. Sensor.MAX_CLOSING_SPEED .. " a player crosses "
       .. (Sensor.POLL_MIN * Sensor.MAX_CLOSING_SPEED) .. " yd between samples, and the "
       .. "smallest ruled radius is only " .. (2 * R_MIN) .. " yd across. ⚠ Under segment "
       .. "a coarse poll cost PHANTOMS; under point + band + gate (A11.2a) there is no "
       .. "chord to catch a pass the samples missed, so it costs the BEACON")
-- ★ And the corpus maximum must fit too, with room. 56.9 yd/s is the fastest legitimate
-- displacement measured across twelve runs.
assert(Sensor.POLL_MIN * 56.9 < 2 * R_MIN,
       "THE FLOOR CANNOT SEE THE CORPUS MAXIMUM: 56.9 yd/s is measured, not bounded")
assert(Sensor.MAX_CLOSING_SPEED >= 56.9,
       "THE DIVISOR IS BELOW THE MEASURED MAXIMUM: MAX_CLOSING_SPEED was 30, INHERITED "
       .. "from COA_Landmarks where the fastest thing is a ~29 yd/s flying mount. A "
       .. "dungeon has no flying mounts and does have charges")
assert(Sensor.POLL_MAX ~= 2.0,
       "POLL_MAX IS COA_LANDMARKS' 2.0: A11.2f rules 1 Hz the BASE ingest rate, and "
       .. "inheriting a neighbour's constant is the fault MAX_CLOSING_SPEED already "
       .. "demonstrated once")

-- =====================================================================
-- ★ ONE EVALUATION PER NODE PER SAMPLE (A11.2g) — the sensor answers once and shares it.
-- =====================================================================
local calls = 0
local realEval = Rule.Evaluate
Rule.Evaluate = function(...) calls = calls + 1 return realEval(...) end
Sensor.Arm({ node({ x = 0, y = 0 }), node({ x = 1000, y = 0 }), node({ r = 0 }) })
calls = 0
local fired = Sensor.Poll(sample(0, 0, 0))
Rule.Evaluate = realEval
assert(calls == 2,
       "THE SENSOR EVALUATED " .. calls .. " TIMES FOR 3 NODES: two are usable and the "
       .. "third has no radius. ⚠ Re-asking per row is four places that can disagree "
       .. "about one node, which is what all-tabs-complete cannot survive")
assert(#fired == 1 and fired[1].address == nil,
       "the in-set is wrong: only the node at the origin should fire")
Sensor.Disarm()

print("smoke_sensor: OK - arm/disarm leaves no OnUpdate; parameters snapshot at ingest; "
      .. "throttle clamps and gates; RI-34's pair kept live")
