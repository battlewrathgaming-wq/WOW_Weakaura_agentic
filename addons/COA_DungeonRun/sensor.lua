-- Model: addons/planning/DRIVER_BASIS.md
--
-- ★★★ THE SENSOR (P5, A11.3 / A11.4 / A11.7c) — where state lives, so the rule has none.
--
-- A11.3, Battlewrath: *"the stateful sensor. It keeps a running inventory of the resolved
-- position(Parameters), and checks against its tab set for completion."*
--
--     THE RULE     point + band + gate. Same list, same samples, same answer. No memory.
--     THE SENSOR   the ARMED OBJECT. Holds the resolved inventory, the in-set, and — at
--                  V2 — the per-tab completion ledger. Calls the rule.
--
-- ⚠⚠ THE SENSOR IS INSIDE THE DRIVER, not in "the caller" — A11.3 corrects that phrasing
-- explicitly, because "the caller" names no owner at all.

local NS = select(2, ...)
NS = NS or _G.COA_DungeonRun_NS or {}
if select(2, ...) == nil then _G.COA_DungeonRun_NS = NS end

local Rule = NS.Rule or dofile((debug.getinfo(1, "S").source:match("@(.*[/\\])") or "")
                               .. "rule.lua")

local Sensor = {}
NS.Sensor = Sensor

-- ★★ THE THROTTLE'S CONSTANTS, both settled by RI-34 on 2026-08-20 and both load-bearing.
--
-- ⚠⚠ NEITHER IS A COST SETTING. Under segment they were: a coarse poll cost phantoms, a
-- fine one cost battery. Under point + band + gate (A11.2a) there is no chord to catch a
-- pass the samples missed, so **a poll that is too slow MISSES THE BEACON**. Same numbers,
-- new job — which is why RI-34 re-derived them rather than re-citing them.
--
-- POLL_MIN 0.1   the floor. At the ruled minimum R = 5 (10 across) and the corpus maximum
--                56.9 yd/s, the floor must be < 2R/v = 0.176 s. ★ 0.2 FAILS by 1.14x; 0.1
--                gives 1.76x. And the speed that defeats 0.1 at R=5 is 100.0 yd/s exactly —
--                `TELEPORT_VMAX`, which the desk calibrated as "not travel".
-- POLL_MAX 1.0   the base ingest rate (A11.2f). ⚠ NOT COA_Landmarks' 2.0 — that is a
--                neighbour's constant for a different job, and inheriting it is the fault
--                MAX_CLOSING_SPEED already demonstrated.
-- MAX_CLOSING_SPEED 100   ⚠ was 30, INHERITED from COA_Landmarks where the fastest thing is
--                a ~29 yd/s flying mount. A dungeon has no flying mounts and does have
--                charges: the corpus holds 56.9. ★ 100 is `TELEPORT_VMAX` — beyond it the
--                displacement is not travel, so nothing slower can outrun the schedule.
Sensor.POLL_MIN = 0.1
Sensor.POLL_MAX = 1.0
Sensor.MAX_CLOSING_SPEED = 100

-- ⚠ A SEAM, not a convenience. The sensor must create a frame to hold an OnUpdate, and a
-- smoke has to be able to watch it arrive and leave (A11.4a). Defaulting to the client's
-- own `CreateFrame` keeps the shipped path untouched.
Sensor.CreateFrame = function(...)
    return _G.CreateFrame and _G.CreateFrame(...) or nil
end

-- ⚠⚠ OWED: A11.3d's TWO SETS. *"There are 2 layers. The sensor doesn't carry both. The sensor
-- checks against the current bucket / pre-load items"* (Battlewrath, 2026-08-20) — which A11.3d
-- already rules: a GATED set (nodes at the current stage/step) and an ALWAYS-OPEN set (stage 0,
-- ordinalless children), the second *"built once at ingest and never re-tested against the
-- gate"*. Its test is `advance the stage → the gated set changes and the always-open does not`.
-- ★ This holds ONE flat list. Under a stageless V1 every node's stage reads 0 → always-open, so
-- the flat list is BEHAVIOURALLY right today and STRUCTURALLY missing the split.
-- ⟶ NOT BUILT: there is no stage to advance, so the test cannot be written and the split would
-- have no consumer. *Existing is not a reason to ship* cuts both ways. Recorded here rather than
-- discovered late — RI-36 carries it.
local armed = nil        -- the armed object, or nil. ⚠ nil IS the disarmed state.
local frame = nil

-- ★★★ A11.4b — RESOLVED ONCE, AT INGEST. The 1 Hz pass never performs a lookup.
--
-- ⚠⚠ THE ROW'S PREMISE MOVED UNDER IT. ✅ RULED 2026-08-20 (RI-35), so this is settled, not
-- reported. A11.4b reads *"`R` and `Band` reach the driver as INDEXES into its own config
-- table"* and scopes itself with *"whether the EDITOR stores an index or a number is RI-22's
-- open question and this does not answer it"*. ★ RI-22 then ANSWERED it: `driver_data_model`
-- 12a — **"the STORE holds the number, not the menu index"** — and `contract.lua` types both
-- `r` and `band` as numbers.
-- ⟶ Battlewrath, draining RI-35: *"Indexes is complete. User pick. R 5 the lowests. 2.5
-- above the lowest offered."* ★ **The menu is CLOSED and the user PICKS from it; the record
-- carries the value picked.** So there is no index to resolve, and no lookup to perform.
-- ⚠ That last clause parses as *"2.5-and-above is the lowest offered"* — **2.5 IS the band's
-- floor**, matching R's floor of 5. The bench read it as "2.5 sits above some lower offer"
-- and was corrected; the gloss is here because the verbatim quote misparses the same way.
--
-- ⚠⚠ AND A11.4b DOES NOT LAND ON THIS SIDE AT ALL. Battlewrath, 2026-08-20: *"'read a table
-- per value' is on the picker side. The sensor its self will have absolute values by the
-- time it reaches it. Defined in the BID:CID or BID for that POS of the node."*
-- ⟶ `R` and `Band` are CHARACTERISTICS of the node, carried on its own record at `BID:CID`
-- (or `BID`) beside `POS` — `contract.lua`'s `CHARACTERISTIC`. The lookup already happened,
-- once, at authoring time. There is no table here to read per sample or per value.
--
-- ★★ SO THE SNAPSHOT'S WARRANT IS A11.3, NOT A11.4b. The sensor *"keeps a running inventory
-- of the RESOLVED position(Parameters)"* — a snapshot in his own words. ⚠ §425 justified this
-- copy with A11.4b's per-sample-lookup rule instead, re-aiming a PICKER-side requirement at
-- the node record to keep it alive on this side. The copy is right; the reason was borrowed.
--
-- ⚠⚠ AND THE FAILURE §427 SUBSTITUTED IS ALSO IMPOSSIBLE. Battlewrath, 2026-08-20: *"in both
-- cases (Editor and router), this is impossible. It's a flight list. Not dynamic."* ⟶ The
-- armed list is FIXED for the run; no live path edits a node mid-pull. So "a snapshot stops
-- an authoring edit moving a beacon" guards nothing either. ★ That was the bench's THIRD
-- reason for one copy in three commits — each true-sounding, each reached for after the code
-- existed. His law: *the burden is on the bench artefact; existing is not a reason to ship.*
--
-- ★★★ THE ONE REASON THAT SURVIVES IS ORDINARY, and it is about `r2`. The rule takes a
-- PRE-SQUARED radius, so the square has to be computed once per node rather than per sample.
-- The only two homes for it are a copy the sensor owns, or the AUTHOR'S OWN RECORD — and
-- writing a derived field back onto the store's data is the fault we refuse everywhere else.
-- ⟶ So the copy exists to hold `r2` without mutating the author's node, and the flight-list
-- property is something it EXPRESSES structurally rather than something it defends.
local function snapshot(node)
    return {
        x = node.x, y = node.y, z = node.z, mapID = node.mapID,
        r = node.r, band = node.band,
        -- ★ r2 is pre-squared HERE, once, for the same reason the rule takes `r2`: a
        -- multiply per node per sample is a cost bought for nothing.
        r2 = (type(node.r) == "number" and node.r > 0) and (node.r * node.r) or nil,
        address = node.address,
    }
end

function Sensor.Arm(list)
    if type(list) ~= "table" then return nil end
    armed = { nodes = {}, inSet = {} }
    for i, node in ipairs(list) do
        armed.nodes[i] = snapshot(node)
    end

    -- ⚠ A11.4a — THE HANDLER EXISTS ONLY WHILE ARMED. `capture.lua`'s own discipline:
    -- "the handler exists ONLY while recording". A persistent OnUpdate that checks a flag
    -- is still running every frame, and "nothing armed, nothing running" (S9) is the
    -- criterion rather than "nothing armed, nothing happening".
    frame = frame or Sensor.CreateFrame("Frame")
    if frame and frame.SetScript then
        frame:SetScript("OnUpdate", Sensor.OnUpdate)
    end
    return armed
end

function Sensor.Disarm()
    armed = nil
    if frame and frame.SetScript then
        frame:SetScript("OnUpdate", nil)
    end
    return nil
end

function Sensor.IsArmed() return armed ~= nil end
function Sensor.Armed() return armed end

-- ★ THE APPROACH THROTTLE (A11.2f, asklist H0-a). `slack` is how long the player would need
-- to reach the nearest node's edge at the fastest displacement we will admit to.
--
-- ⚠ IT NEVER DIVIDES BY A MEASURED SPEED. `ROUTER` (2026-08-20): `GetUnitSpeed` reports the
-- MOVEMENT-STATE rate — 7 running, 14 mounted — while the corpus holds legitimate
-- displacement at 56.9. **A schedule derived from the reading alone under-polls in exactly
-- the cases it exists for.** The constant is a SAFETY bound and its errors are asymmetric:
-- too high costs extra samples, too low costs a beacon.
function Sensor.NextIn(sample)
    if not armed or not Rule.Usable(sample) then return Sensor.POLL_MAX end
    local nearest
    for _, n in ipairs(armed.nodes) do
        if n.r2 and Rule.Gate(sample.mapID, n.mapID) then
            local dx, dy = sample.x - n.x, sample.y - n.y
            local d = math.sqrt(dx * dx + dy * dy) - n.r
            if not nearest or d < nearest then nearest = d end
        end
    end
    -- ⚠ Nothing armed ON THIS MAP is not the same as nothing armed: the player may be
    -- walking to the instance. Poll at the base rate rather than not at all.
    if not nearest then return Sensor.POLL_MAX end
    -- ⚠ NO `if nearest < 0 then return POLL_MIN` HERE, and its absence is deliberate.
    -- ★ Mutation removed that branch and NOTHING FAILED: a negative `nearest` gives a
    -- negative `slack`, which the floor clamp two lines down already catches. It was dead
    -- code that READ as load-bearing - the worst kind, because the next reader adds a case
    -- to it. The inside-the-radius row below still grades the behaviour; it just grades the
    -- clamp that actually performs it.
    local slack = nearest / Sensor.MAX_CLOSING_SPEED
    if slack < Sensor.POLL_MIN then return Sensor.POLL_MIN end
    if slack > Sensor.POLL_MAX then return Sensor.POLL_MAX end
    return slack
end

-- ★★ ONE EVALUATION PER NODE PER SAMPLE (A11.2g), shared by that node's rows. Returns the
-- list of nodes that fired, so a caller reads ONE verdict per node rather than asking again
-- per tab — four independent evaluations are four places that can disagree.
function Sensor.Poll(sample)
    if not armed then return nil end
    local fired = {}
    for _, n in ipairs(armed.nodes) do
        if n.r2 then
            local hit = Rule.Evaluate(sample, n)
            armed.inSet[n] = hit or nil
            if hit then fired[#fired + 1] = n end
        end
    end
    return fired
end

-- ⚠ The accumulator, kept OUT of `Poll` so the throttle is testable without a frame.
local since = 0
local nextIn = 0
function Sensor.OnUpdate(_, elapsed)
    if not armed then return end
    since = since + (elapsed or 0)
    if since < nextIn then return end
    since = 0
    local sample = Sensor.Sample and Sensor.Sample()
    if not sample then nextIn = Sensor.POLL_MAX return end
    Sensor.Poll(sample)
    nextIn = Sensor.NextIn(sample)
end

return Sensor
