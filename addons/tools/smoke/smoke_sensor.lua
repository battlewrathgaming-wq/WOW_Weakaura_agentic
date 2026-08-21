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
    -- ★★ THE BAND DEFAULTS TO 2.5 HERE BECAUSE THE SENSOR IS HANDED POST-BUCKET NODES.
    -- ⚠ A11.2h removed `Rule.OPEN`, so `Rule.Evaluate` now REFUSES a node with no band —
    -- and this helper was leaving it nil, which made every fixture an unresolved node. ★ The
    -- fix is the fixture, not the rule: model row 27 resolves `nil → 2.5` at BUCKET, so by
    -- the time anything reaches the sensor a band is present. **2.5 is the picker's floor
    -- and default at once** (RI-35) — the same value BUCKET would supply.
    -- ⟶ A test that wants an UNRESOLVED node must say `band = false` and expect a refusal;
    -- that row lives in `smoke_rule`, where the refusal itself is graded.
    -- ★ AND `rows` DEFAULTS FOR THE SAME REASON THE BAND DOES: a post-BUCKET node always
    -- carries its behaviour rows, and A11.3e needs tabs for a transition word to be matched
    -- against. ⚠ A fixture with no rows is not a node the sensor can ever be handed.
    return { x = t.x or 0, y = t.y or 0, z = t.z or 0,
             mapID = t.mapID or 33, r = t.r or 5, band = t.band or 2.5,
             address = t.address,
             rows = t.rows or { { sense = "whenOn", action = "boss" } } }
end
local function sample(x, y, z, m)
    return { x = x, y = y, z = z, mapID = m or 33 }
end

-- ★ A11.3e: `Poll` returns CHANGE RECORDS - `{ address, word, node }` - not the in-set.
-- These read them the way the manager will: by WORD.
local function words(changes, want)
    local n = 0
    for _, c in ipairs(changes or {}) do if c.word == want then n = n + 1 end end
    return n
end
local function firstWord(changes)
    return changes and changes[1] and changes[1].word or nil
end

-- =====================================================================
-- ★★ ABSENT FIRST — the split A11.3 draws, asserted rather than assumed.
-- =====================================================================
assert(Sensor.PointFire == nil and Sensor.Gate == nil and Sensor.Evaluate == nil,
       "THE SENSOR GREW ITS OWN GEOMETRY: A11.3 splits the pure RULE from the stateful "
       .. "SENSOR precisely so the rule can be graded from a fixture. A second copy of "
       .. "the test here is a second answer that can disagree with the first")

-- ★★★ AND NO DOOR FOR THE MANAGER TO WRITE THROUGH (RI-42, §454).
--
-- Battlewrath: *"The manager swaps out the SELECTION rather than telling the sensor what to
-- bounce."* ⟶ **ONE LEVER, ONE DIRECTION** — the manager writes a LIST, never a RULE, and
-- `Arm` is that list. A stage advance, a step advance, a node completing and a narrowing for
-- cost are all the SAME act: hand over a different selection.
--
-- ⚠⚠ A `Bounce` / `Exclude` / `Complete` door would put completion in TWO places: `A12.1a`
-- makes the ledger the manager's and RI-42 says *"the sensor's is superseded"* in those words.
-- ★ An absence is only a design until something can notice it changing, so it is a row.
-- ★★★ AND NO TRACKER WRITE, for the same reason one level along (§456).
--
-- Battlewrath: *"The sensor is blind to what it's reading. So it lives with the manager."*
-- ⟶ The sensor reports TRANSITIONS BY ADDRESS and cannot know that an address is a park, a
-- lure, a recovery beacon or a boss. **Each of those is a MEANING**, and A12.1a puts all
-- three tracker writes - entry lure, supertrack tab, the park - with the manager.
-- ⚠ A sensor that could write the arrow would first have to learn what it was looking at,
-- and that is the moment it stops being blind.
assert(Sensor.Park == nil and Sensor.SuperTrack == nil and Sensor.Lure == nil
       and Sensor.Track == nil,
       "THE SENSOR GREW A TRACKER WRITE: it reports transitions BY ADDRESS and an address "
       .. "is not a MEANING. ⚠ To point an arrow it would have to know what it is looking "
       .. "at - park, lure, recovery, boss - and A12.1a puts all three tracker writes with "
       .. "the manager. The sensor is blind to what it is reading, deliberately")

assert(Sensor.Bounce == nil and Sensor.Exclude == nil and Sensor.Drop == nil
       and Sensor.Complete == nil and Sensor.Ledger == nil and Sensor.SetComplete == nil,
       "THE SENSOR GREW A DOOR FOR THE MANAGER TO WRITE THROUGH: the manager swaps out the "
       .. "SELECTION rather than telling the sensor what to bounce. ⚠ A sensor that knew "
       .. "what was complete would hold a SECOND COPY of the manager's ledger, and A12.1a "
       .. "makes that ledger the manager's alone. The channel already exists and it is `Arm`")
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

-- =====================================================================
-- ★★★ A11.3e · THE RETURN CONTRACT — CHANGED nodes, by ADDRESS, with the TRANSITION WORD.
--
-- ⚠⚠ ITS OWN TEST, verbatim: *a node entered then left across three samples → When on
-- once, When off once, nothing between.* ★ The row exists because the words are TRANSITIONS
-- (`whenOn` was out is in · `whenOff` was in is out · `seen` has been in at least once), and
-- the old `Poll` overwrote the in-set in place, **destroying the transition every poll**.
-- =====================================================================
do
    local N3 = node({ x = 0, y = 0, r = 5, band = 2.5, address = "33:R:b:c" })
    Sensor.Arm({ N3 })

    local inn = Sensor.Poll(sample(0, 0, 0))
    assert(words(inn, Sensor.WHEN_ON) == 1, "entering must report whenOn exactly once")
    assert(words(inn, Sensor.SEEN) == 1,
           "THE FIRST ENTRY DID NOT REPORT `seen`: it is a HISTORY, not a re-wording of "
           .. "whenOn, and it becomes true at that instant. A12.4a has the manager run "
           .. "*only the tabs whose sense-word MATCHES*, so a word never emitted is a tab "
           .. "that can never run")
    for _, c in ipairs(inn) do
        assert(c.address == "33:R:b:c",
               "A11.3b: every report names the target BY ADDRESS, never by index")
        assert(c.node and c.node.rows,
               "THE REPORT CARRIES NO ROWS: A11.3e names `snapshot()` dropping `rows` as "
               .. "half the same build step - a word is only useful to something that can "
               .. "match it against a TAB")
    end

    -- ⚠ STAYING PUT IS NOT A TRANSITION. This is the row A11.3e's mutation targets:
    -- *return the whole in-set → every tab re-fires every sample*.
    assert(#Sensor.Poll(sample(0, 0, 0)) == 0,
           "A SECOND SAMPLE INSIDE REPORTED AGAIN: nothing CHANGED, so nothing is returned "
           .. "- otherwise every tab re-fires on every poll")

    local out = Sensor.Poll(sample(500, 500, 0))
    assert(words(out, Sensor.WHEN_OFF) == 1, "leaving must report whenOff exactly once")
    assert(words(out, Sensor.SEEN) == 0, "leaving is not a `seen`")
    assert(#Sensor.Poll(sample(500, 500, 0)) == 0, "staying out is not a transition either")

    -- ★ AND `seen` DOES NOT FIRE TWICE. *Has been in at least once* survives leaving and
    -- coming back, so a re-entry is `whenOn` and nothing more.
    local back = Sensor.Poll(sample(0, 0, 0))
    assert(words(back, Sensor.WHEN_ON) == 1, "re-entering must report whenOn")
    assert(words(back, Sensor.SEEN) == 0,
           "`seen` FIRED TWICE: it is *has been in AT LEAST ONCE*, so it becomes true once "
           .. "and stays true - a second one would make it a synonym for whenOn")

    -- ★★ A11.3c · RESETTABLE, AND ITS STATE READABLE. Outcome grading compares run against
    -- run, so a sensor that cannot reach a KNOWN state makes run 2 incomparable to run 1.
    local st = Sensor.State()
    assert(st and st.armed == 1 and st.everIn == 1, "the state must be readable")
    Sensor.Reset()
    local clean = Sensor.State()
    assert(clean.inSet == 0 and clean.wasIn == 0 and clean.everIn == 0,
           "RESET CARRIED STATE ACROSS: every outcome after the first would be measured "
           .. "from wherever the last one stopped")
    assert(clean.armed == 1,
           "RESET DISARMED THE SENSOR: it returns the sensor to a known state, it does not "
           .. "throw away the list - re-arming is a different function")
    local again = Sensor.Poll(sample(0, 0, 0))
    assert(words(again, Sensor.WHEN_ON) == 1 and words(again, Sensor.SEEN) == 1,
           "AFTER A RESET THE SAME FIXTURE MUST GIVE THE SAME OUTPUT: that is what makes "
           .. "run 2 comparable to run 1")
    Sensor.Disarm()
end

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
-- ⚠⚠ AND THE FAILURE THAT REPLACED IT IS ALSO IMPOSSIBLE. Battlewrath: *"in both cases
-- (Editor and router), this is impossible. It's a flight list. Not dynamic."* ⟶ Nothing edits
-- a node mid-pull, so "a snapshot stops a beacon moving under a run" guards nothing either.
-- ★ That was three reasons for one copy in three commits, each reached for AFTER the code
-- existed. *The burden is on the bench artefact; existing is not a reason to ship.*
--
-- ★★★ SO THE ROW IS KEPT ON THE ONE WARRANT THAT IS NOT ABOUT A FAILURE: `r2`. The rule takes
-- a PRE-SQUARED radius, so the square is computed once per node instead of once per sample,
-- and it needs a home that is NOT the author's record — writing a derived field back onto the
-- store's own data is the fault we refuse everywhere else. ⟶ The copy exists to hold `r2`.
-- ⚠ The row therefore grades a STRUCTURAL LOCK, not a live defect: it states in code that the
-- armed list is a flight list, so a later change that makes it dynamic has to argue with a
-- test rather than pass one. Labelled that way so nobody reads it as a bug that was caught.
-- =====================================================================
local live = node({ x = 0, y = 0, r = 5, band = 2.5 })
Sensor.Arm({ live })
local near = sample(3, 0, 0)
local far = sample(400, 0, 0)
-- ⚠ TWO POLLS, because these are TRANSITIONS now: the first entry reports `whenOn`
-- AND `seen`, and the move away reports `whenOff`.
assert(words(Sensor.Poll(near), Sensor.WHEN_ON) == 1, "fixture wrong before mutation")
assert(words(Sensor.Poll(far), Sensor.WHEN_OFF) == 1, "leaving must report whenOff")

live.r = 100000
live.x = 400
assert(words(Sensor.Poll(far), Sensor.WHEN_ON) == 0,
       "THE SENSOR RE-READ THE NODE MID-RUN: it was armed on a node at the origin with "
       .. "r=5 and the record was then moved to the far sample with a huge radius. A held "
       .. "reference follows the edit; a snapshot does not. ⚠ NOT a bug that was caught - "
       .. "nothing can edit a node mid-pull today. This is the FLIGHT LIST stated in code, "
       .. "so making the armed set dynamic has to argue with a test rather than pass one")
assert(words(Sensor.Poll(near), Sensor.WHEN_ON) == 1,
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
assert(words(fired, Sensor.WHEN_ON) == 1,
       "the change set is wrong: only the node at the origin should report whenOn")
Sensor.Disarm()

print("smoke_sensor: OK - arm/disarm leaves no OnUpdate; parameters snapshot at ingest; "
      .. "throttle clamps and gates; RI-34's pair kept live")
