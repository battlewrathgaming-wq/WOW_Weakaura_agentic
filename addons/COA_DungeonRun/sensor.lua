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

local armed = nil        -- the armed object, or nil. ⚠ nil IS the disarmed state.
local frame = nil

-- ★★★ A11.4b — RESOLVED ONCE, AT INGEST. The 1 Hz pass never performs a lookup.
--
-- ⚠⚠ THE ROW'S PREMISE MOVED UNDER IT, and this is reported rather than resolved.
-- A11.4b reads *"`R` and `Band` reach the driver as INDEXES into its own config table"* and
-- scopes itself with *"whether the EDITOR stores an index or a number is RI-22's open
-- question and this does not answer it"*. ★ RI-22 then ANSWERED it: `driver_data_model.md`
-- 12a — **"the STORE holds the number, not the menu index"** — and `contract.lua` types both
-- `r` and `band` as numbers. So there is no index to resolve.
--
-- ★ WHAT SURVIVES IS THE REQUIREMENT, not the mechanism: **nothing may read a table per
-- sample.** With numbers on the record that means SNAPSHOTTING the node at arm time rather
-- than holding a reference into the route store and re-reading it every tick. A held
-- reference is the same per-sample lookup wearing a different shape, and it is worse —
-- the values can change underneath a run.
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
