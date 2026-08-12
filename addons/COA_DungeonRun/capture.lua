-- COA_DungeonRun capture.lua - the capture engine.
--
-- A dungeon route IS a sequence of pulls, so the pulls ARE the route. We do not
-- place markers by hand; we record where combat started and where it ended, and
-- sample the path between. See addons/planning/dungeonrun_poc.md.
--
-- ---------------------------------------------------------------------------
-- DR-1  EDGES FROM THE EVENTS, STATE FROM THE API.
--
-- PLAYER_REGEN_DISABLED / PLAYER_REGEN_ENABLED are the enter and exit markers -
-- two events, no filtering, none of CLEU's cost. Verified against the INSTALLED
-- WeakAuras fork rather than recalled (Battlewrath's challenge: "is that the
-- hook WeakAuras uses for combat start and end?"):
--
--   WeakAuras.lua:1700-1701  both events on loadFrame, the Display Load Handling
--                            frame - the thing that shows/hides auras in combat
--   WeakAuras.lua:1570       local inCombat = UnitAffectingCombat("player")
--                            recomputed on EVERY scan
--   Conditions.lua:693 / Prototypes.lua:990 / Profiling.lua:303 - same pair
--
-- The most load-sensitive addon on this client never infers combat state from
-- the event that woke it. Neither do we: PLAYER_REGEN_ENABLED also fires when
-- lockdown lifts for reasons that are not a pull ending.
--
-- This is COA_Landmarks AC-24 restated: DO NOT INFER THE STATE FROM THE EVENT
-- THAT WOKE YOU - go and read it.
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local Capture = {}
NS.Capture = Capture

local Store

local SAMPLE_EVERY = 1.0   -- DR-3: seconds between travel samples

local runId          -- nil = disarmed. The ONLY armed/disarmed flag.
local pulls  = 0
local acc    = 0
local frame                -- created once; the OnUpdate is installed/cleared

-- FORWARD DECLARATION. Capture.Arm installs this handler but it is defined
-- below, and this line is what keeps that working WITHOUT leaking a global.
-- Dropping it does not error: `function onUpdate` silently defines a global
-- that any addon could clobber, and the smoke asserts against exactly that.
local onUpdate

local function inInstance()
    if not IsInInstance then return false end
    local ok = IsInInstance()
    return ok and true or false
end

-- ---------------------------------------------------------------------
-- The travel sampler. DR-3.
--
-- Markers alone are a LIST OF EVENTS; markers plus legs are a CONTINUOUS
-- RECORD (Battlewrath: "that fills the dotted line between capture points a
-- consistent story"). Endpoints drawn on a map are straight lines between
-- pulls, which go through walls in any dungeon with a corridor.
--
-- Two gates, and both matter:
--   OUT OF COMBAT - in combat the marker pair already covers it, and sampling
--                   there would be paying for what we already have.
--   IN AN INSTANCE - outside one there is no run to draw.
--
-- The throttle sits BEFORE the work, not after. The addon census caught
-- COA_Landmarks calling GetCurrentPlayerPosition() 59 times a second and
-- throwing the result away - the throttle was real and sat in the wrong place.
-- ---------------------------------------------------------------------

function onUpdate(_, elapsed)
    acc = acc + elapsed
    if acc < SAMPLE_EVERY then return end      -- a float compare, nothing more
    acc = 0

    if not runId then return end
    if UnitAffectingCombat("player") then return end
    if not inInstance() then return end

    -- DR-13: the ghost flag is one API read on a tick we are already running.
    -- A corpse run would otherwise draw as a bizarre excursion with nothing in
    -- the record to say why.
    local ghost = UnitIsGhost and UnitIsGhost("player") and true or false
    Store.AddLeg(runId, Store.Point(), ghost)
end

-- ---------------------------------------------------------------------
-- Arm / disarm
-- ---------------------------------------------------------------------

-- DR-7: the OUTDOOR entrance point is captured at ARM time, if you are outside.
-- Deliberately not tracked continuously - that would be a poll for a single
-- value, and "free" means a read on something already in hand (DR-9's boundary).
-- It matches the actual workflow: name the run at the door, arm, walk in.
-- Arming inside leaves `outside` nil, which is recorded as nil rather than
-- faked - F38 says the two points are on different maps and cannot be one
-- record anyway.
function Capture.Arm(name)
    if runId then return nil, "already recording" end

    local id = Store.Open(name)
    if not id then return nil, "storage refused - see /dr status" end

    runId, pulls, acc = id, 0, 0

    if not inInstance() then
        Store.SetOutside(id, Store.Point())
    end

    if frame then frame:SetScript("OnUpdate", onUpdate) end
    return id
end

function Capture.Stop()
    if not runId then return nil end
    local id = runId
    Store.Close(id)
    runId, pulls, acc = nil, 0, 0
    -- The handler exists ONLY while recording: zero persistent OnUpdate, which
    -- is what emit_addon_census.py will report and what we hold others to.
    if frame then frame:SetScript("OnUpdate", nil) end
    return id
end

function Capture.RunId() return runId end
function Capture.Pulls() return pulls end

-- ---------------------------------------------------------------------
-- Events
-- ---------------------------------------------------------------------

local function onCombatStart()
    if not runId then return end
    -- DR-1: confirm the STATE. The edge woke us; it does not tell us the truth.
    if not UnitAffectingCombat("player") then return end
    pulls = pulls + 1
    Store.AddMarker(runId, Store.Point(), "start", pulls)
end

local function onCombatEnd()
    if not runId then return end
    -- DR-13: dead/alive is one API read on an event we already handle, and
    -- without it a WIPE AND A CLEAN FINISH ARE IDENTICAL in the record.
    local dead = UnitIsDeadOrGhost and UnitIsDeadOrGhost("player") and true or false
    Store.AddMarker(runId, Store.Point(), "end", pulls, dead)
end

-- DR-7: the in-instance arrival point - the route's origin. Guarded three ways
-- because PLAYER_ENTERING_WORLD also fires on login and on every /reload.
local function onEnteringWorld()
    if not runId then return end
    if not inInstance() then return end
    Store.SetArrival(runId, Store.Point())     -- Store.SetArrival is write-once
end

function Capture.Init()
    Store = NS.Store
    frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    frame:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_REGEN_DISABLED" then
            onCombatStart()
        elseif event == "PLAYER_REGEN_ENABLED" then
            onCombatEnd()
        else
            onEnteringWorld()
        end
    end)
    -- No OnUpdate here on purpose: it is installed by Arm and cleared by Stop.
    return frame
end
