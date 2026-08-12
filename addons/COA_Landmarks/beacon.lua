-- COA_Landmarks beacon.lua - the SLOT DISCIPLINE.
--
-- The engine has exactly ONE supertrack slot and the client's ladder ranks
-- Position ABOVE Quest (F24). Nothing in the client's flow clears our position,
-- so PASSIVITY DOES NOT MAKE US LOSE GRACEFULLY - it makes us win permanently
-- and silently block the player's quest arrow. We therefore YIELD actively.
--
--   occupy on an explicit pin  ->  release on arrival  ->  NEVER reclaim
--
-- Two criteria here fail SILENTLY in the field. They are the reason this file
-- has a smoke test of its own:
--
--   AC-24  arrival requires GetTargetState() ~= Invalid AND distance <= tier.
--          Across a map boundary the engine returns Invalid with sd = 0.00 -
--          NOT nil - while still reporting IsSuperTrackingAnything() == true.
--          ZERO SATISFIES EVERY TIER, so distance alone fires "arrived" the
--          instant a player zones into any instance. (F38, measured.)
--   AC-26  that guard must judge a SUSTAINED state, not a single frame. A
--          loading screen produces a momentary Invalid. (pfQuest debounces its
--          arrow the same way, for the same reason.)

local ADDON, NS = ...
local Store = NS.Store

local Beacon = {}
NS.Beacon = Beacon

-- AC-14b: 1500 and 727 are the CLIENT'S Lua-side convention in SuperTracker.lua,
-- NOT engine limits - F32/F35 measured the engine still returning InRange and a
-- true distance at 3,742 yd. A fork update can move these; they are named so
-- that when it does, this is the one place to change.
local CLIENT_BEACON_CUTOFF = 1500

local ARRIVAL_HOLD   = 1.00   -- AC-26: how long the arrival condition must hold

-- ★ AC-29 REVISED (Battlewrath, 2026-08-12): pace on DISTANCE, not on movement.
--
-- The old shape was a two-tier throttle - 0.05s while moving, 1s standing still.
-- His challenge: "where is the benefit to the polling cadence as stands?" There
-- is none. Two facts kill it:
--   * AC-26 requires the arrival condition to hold a FULL SECOND before we act,
--     so 20 samples per debounce window discards 19 of them.
--   * A late arrival costs NOTHING. Arriving is silent (L12) and the engine
--     already fades its own beacon at InRadius (F21), so noticing a second late
--     is invisible. We were paying 20Hz for precision on an event with no
--     deadline.
--
-- The engine hands us YARDS for free (F28), so we can pace on how soon arrival
-- is even POSSIBLE: at distance D and tier T, no sooner than (D-T)/speed.
--
-- MAX_CLOSING_SPEED is the one assumption here, and it is deliberately generous:
-- ~29 yd/s is a 310% flying mount, so 30 leaves headroom. Being WRONG about it
-- only ever makes an arrival LATE, never missed - the next poll still sees a
-- distance inside the tier, because you stopped there. That is why the ceiling
-- can be loose and the floor tight.
local MAX_CLOSING_SPEED = 30    -- yards/second, generous
local POLL_MIN          = 0.20  -- 5 samples per debounce window: ample
local POLL_MAX          = 2.00  -- worst case: arrival noticed 2s late, invisibly

-- AC-52: all of this is SESSION state and is never persisted.
local pinnedId, pinnedLM = nil, nil
local arrivalSince, acc, tick = nil, 0, nil
local nextIn = POLL_MIN     -- seconds until the next check; set from distance

-- FORWARD DECLARATION. Beacon.Pin installs this handler but is defined ABOVE it,
-- and this line is what keeps that working WITHOUT leaking a global.
--
-- The original was `local function onUpdate` declared after Pin: Pin's reference
-- resolved to a nil GLOBAL, and SetScript("OnUpdate", nil) is perfectly legal -
-- so the beacon simply never polled, silently. The smoke caught it immediately.
--
-- Dropping this line would still WORK, because `function onUpdate` would then
-- define a global that Pin finds at call time - and that is the trap: it leaks
-- `onUpdate` into _G where any addon can clobber it. Asserted in the smoke.
local onUpdate

-- ---------------------------------------------------------------------
-- Ownership
-- ---------------------------------------------------------------------

-- Does the client still hold OUR position? Same discrimination the probe's `gp`
-- made: the client keeps SUPER_TRACKED_POSITION until something else takes the
-- slot or the CVar goes off (F41, measured - it nils it).
function Beacon.OwnsSlot()
    if not pinnedLM then return false end
    local g = _G.SUPER_TRACKED_POSITION
    if type(g) ~= "table" then return false end
    return g.x == pinnedLM.x and g.y == pinnedLM.y and g.mapID == pinnedLM.mapID
end

function Beacon.PinnedId()
    return pinnedId
end

-- ---------------------------------------------------------------------
-- Pin / clear
-- ---------------------------------------------------------------------

-- AC-12: ALWAYS a user act. Nothing in this file calls Pin() on its own.
function Beacon.Pin(id)
    local lm = Store.Get(id)
    if not lm then return false, "no such landmark" end

    -- AC-17: the Util wrapper, NOT C_SuperTrack.SetSuperTrackedPosition. The
    -- direct call skips the priority ladder: it appears to work and is then
    -- silently overwritten by the next re-evaluation (corrects F4).
    if not _G.SuperTrackerUtil then return false, "SuperTrackerUtil missing on this client" end

    -- AC-18: we keep our OWN copy. The client nils its global whenever
    -- showInGameNavigation goes off (F41), so its global is not our storage.
    pinnedId, pinnedLM = id, lm
    arrivalSince, acc, nextIn = nil, 0, POLL_MIN

    -- ★ The poll EXISTS ONLY WHILE WE HOLD A PIN. Not a micro-optimisation -
    -- it is the design: scrapbook use is episodic and errand-driven (§9, L17),
    -- so a permanently-installed poll contradicts the product's own model as
    -- well as its frame budget. Idle cost is now exactly zero.
    if tick then tick:SetScript("OnUpdate", onUpdate) end

    SuperTrackerUtil.SetSuperTrackedPosition(lm.x, lm.y, lm.z, lm.mapID)
    return true
end

-- AC-13 / AC-27: the same release arrival performs. Silent (L12).
function Beacon.Clear()
    pinnedId, pinnedLM, arrivalSince = nil, nil, nil
    if tick then tick:SetScript("OnUpdate", nil) end   -- back to zero idle cost
    if _G.SuperTrackerUtil then SuperTrackerUtil.ClearSuperTrackedPosition() end
end

-- ---------------------------------------------------------------------
-- AC-14: can the beacon guide the player to this landmark right now?
-- Two triggers, one handoff. Trigger 2 is TEMPORARY and self-resolving.
-- ---------------------------------------------------------------------

function Beacon.CannotGuide(id)
    local lm = Store.Get(id)
    if not lm then return false end

    local _, _, _, mapID = GetCurrentPlayerPosition()
    if mapID and lm.mapID ~= mapID then
        return true, "map"          -- the engine REFUSES (F38). repin will do nothing.
    end

    -- Only meaningful while we are the ones being tracked.
    if pinnedId == id and _G.C_SuperTrack then
        local _, _, dist = C_SuperTrack.GetSuperTrackedPosition()
        if dist and dist > CLIENT_BEACON_CUTOFF then
            return true, "range"    -- the CLIENT'S cut. Lights up by itself on approach.
        end
    end
    return false
end

-- ---------------------------------------------------------------------
-- Arrival poll. AC-30: distance is read for arrival and for AC-14 only.
-- It is NEVER displayed (L16) - the beacon renders its own inside its range.
-- ---------------------------------------------------------------------

local function arrivalConditionMet()
    if not pinnedLM or not _G.C_SuperTrack then return false end

    -- AC-24, half one: the STATE. A refusal reports Invalid with sd = 0.00,
    -- and zero passes every tier - so distance alone is not a test.
    local state = C_SuperTrack.GetTargetState()
    if state == nil or state == 0 then return false end   -- 0 = NavigationState.Invalid

    -- AC-25: you cannot have arrived at a landmark on another map.
    local _, _, _, mapID = GetCurrentPlayerPosition()
    if mapID ~= pinnedLM.mapID then return false end

    -- AC-23: the engine's own distance, in yards, and 3D (F28: mean error
    -- 0.00001 yd over 1,758 samples). We compute no distance ourselves, and we
    -- do NOT use NavigationState.InRadius - that is the engine's own radius,
    -- unsettable, and cannot carry a per-landmark tier (F31).
    local _, _, dist = C_SuperTrack.GetSuperTrackedPosition()
    if not dist then return false end

    return dist <= Store.TierYards(pinnedLM.tier)
end

local function poll(elapsed)
    if not pinnedId then return end

    -- AC-19: if something else took the slot, we do NOT take it back. Ever.
    -- The widget keeps holding the landmark so `repin` is one click (AC-11).
    if not Beacon.OwnsSlot() then
        pinnedId, pinnedLM, arrivalSince = nil, nil, nil
        if tick then tick:SetScript("OnUpdate", nil) end
        return
    end

    -- Pace the NEXT check from the distance we can see now. Cheap: this is the
    -- same read arrivalConditionMet() makes, and it costs one division.
    local _, _, dist = C_SuperTrack.GetSuperTrackedPosition()
    if dist and pinnedLM then
        local slack = (dist - Store.TierYards(pinnedLM.tier)) / MAX_CLOSING_SPEED
        nextIn = math.max(POLL_MIN, math.min(POLL_MAX, slack))
    else
        nextIn = POLL_MIN
    end

    if arrivalConditionMet() then
        -- AC-26: judge a SUSTAINED state. A single frame during a loading
        -- screen is not an arrival.
        arrivalSince = arrivalSince or GetTime()
        if GetTime() - arrivalSince >= ARRIVAL_HOLD then
            Beacon.Clear()                    -- AC-27: wipe, silently (L12)
            if NS.Widget then NS.Widget:Refresh() end
        end
    else
        arrivalSince = nil
    end
end

-- AC-29: the interval is set by the LAST KNOWN distance - how soon arrival could
-- even happen. Nothing else is read per frame; `nextIn` is just a number.
--
-- ★ The interval check comes FIRST, before any API call. The original read
-- GetCurrentPlayerPosition() every frame and threw the result away 59 times a
-- second: the throttle was real but sat AFTER the work it was throttling. The
-- addon census reported "throttle? yes" and was right about the wrong thing -
-- it can see that a throttle exists, not where it sits.
function onUpdate(_, elapsed)                   -- assigns the forward-declared local
    acc = acc + elapsed
    if acc < nextIn then return end             -- a float compare, nothing more
    acc = 0
    poll(elapsed)
end

-- ---------------------------------------------------------------------
-- AC-20: we YIELD, and yielding IS the same-level mechanism (not a workaround).
-- ---------------------------------------------------------------------

function Beacon.Init()
    -- Created here, but left WITHOUT a script: the frame costs nothing while
    -- idle, and creating it up front means no allocation mid-errand.
    tick = CreateFrame("Frame")

    -- The client hooks this same function for the same purpose. We are entering
    -- where the quest system enters; we simply step OUT of the ladder so it
    -- resolves to Quest instead of blocking it forever.
    --
    -- AC-21: this also fires on QUEST_TURNED_IN (UpdateSelectedQuest calls it
    -- unconditionally). We ACCEPT that drop - turn-in is quest-flow activity,
    -- and the widget still holds the landmark, so repin is one click.
    -- AC-15: at login we are never pinned, so the login path is harmless.
    if _G.hooksecurefunc and _G.SelectQuestLogEntry then
        hooksecurefunc("SelectQuestLogEntry", function()
            if pinnedId then
                Beacon.Clear()
                if NS.Widget then NS.Widget:Refresh() end
            end
        end)
    end
end

return Beacon
