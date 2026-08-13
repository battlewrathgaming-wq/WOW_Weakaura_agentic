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

-- FORWARD DECLARATION. Capture.Arm calls this but it is defined in the events
-- section below, and without this line the call resolves to a nil global -
-- exactly the silent scoping failure that shipped once in COA_Landmarks.
local captureOrigin

local pendingKilledBy, pendingWhy   -- set at PLAYER_DEAD, spent at combat end

local MAX_BOSS = 5   -- Boss1..5TargetFrame; the token set is SPARSE, gaps are normal

-- ---------------------------------------------------------------------
-- DR-32: the TERMINAL STOP's attribution, consumed from the client's own
-- DeathRecap. ONE field - `attacker`. See DRIVER_CONTRACT.md for why the rest of
-- that table (damage, school, healthPercent, crit) is deliberately NOT read:
-- it is damage analysis, which is a lane combat parsers already serve well.
--
-- Returns (names, nil) or (nil, reason). The REASON matters: a silent absence
-- would read as "nothing killed us", so the caller records it.
-- ---------------------------------------------------------------------
local function recapAttackers()
    local R = AscensionUI and AscensionUI.DeathRecap
    if type(R) ~= "table" then return nil, "AscensionUI.DeathRecap absent" end

    local id = R.CurrentRecap
    local buf = type(R.Events) == "table" and id and R.Events[id]
    if type(buf) ~= "table" then return nil, "recap buffer absent or not a table" end

    local seen, out = {}, {}
    for _, e in ipairs(buf) do
        local a = type(e) == "table" and e.attacker or nil
        if type(a) == "string" and not seen[a] then
            seen[a] = true
            out[#out + 1] = a          -- first-seen order; dedupe is offline's job
        end
    end
    if #out == 0 then return nil, "recap buffer held no named attacker" end
    return out, nil
end

-- ---------------------------------------------------------------------
-- DR-31: which bosses this route ENGAGED. Route identity - a run that kills two
-- of the bosses is a different route from one that kills four.
--
-- Live-verified 2026-08-13 (record 20260813_014009_176): `boss1` exists and is
-- NAMED mid-fight in a vanilla dungeon on this fork. Note UnitExists returns 1,
-- not true - a 3.3.5-ism, so never compare against `true`.
-- ---------------------------------------------------------------------
local function engagedBosses()
    local out = {}
    for i = 1, MAX_BOSS do
        local unit = "boss" .. i
        if UnitExists(unit) then
            local n = UnitName(unit)
            if type(n) == "string" and n ~= "" then out[#out + 1] = n end
        end
    end
    return out
end

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

    if inInstance() then
        -- Armed INSIDE: here IS the origin, and the zone-in event is long gone.
        captureOrigin()
    else
        -- Armed OUTSIDE: this is the world-side entrance. The in-instance origin
        -- lands on zone-in. F38 - they are different maps and cannot be one record.
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
    -- Run-scoped: a death captured near the end of one run must not ride onto the
    -- first terminal stop of the NEXT. This is the ONLY clear besides spending it
    -- at combat end - a second one elsewhere would mask this one from testing.
    pendingKilledBy, pendingWhy = nil, nil
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
    -- Attribution rides ONLY on a terminal stop. If we walked away alive there is
    -- nothing to attribute, and attaching a stale attacker list would be a lie.
    local by, why
    if dead then by, why = pendingKilledBy, pendingWhy end
    Store.AddMarker(runId, Store.Point(), "end", pulls, dead, by, why)
    pendingKilledBy, pendingWhy = nil, nil
end

-- PLAYER_DEAD is the ONLY moment the recap is readable: CurrentRecap rolls on
-- PLAYER_UNGHOST and PLAYER_ENTERING_WORLD, so a later read finds an empty
-- buffer. Combat may not drop for several seconds, so we hold it until the end
-- marker is written.
local function onPlayerDead()
    if not runId then return end
    pendingKilledBy, pendingWhy = recapAttackers()
end

-- DR-31. One rare event, not continuous logging - the cost objection that rules
-- out a CLEU listener does not apply here.
local function onEncounterEngage()
    if not runId then return end
    local names = engagedBosses()
    if #names > 0 then Store.AddBoss(runId, names, pulls) end
end

-- DR-7 arrival + DR-30 instance identity. Both are write-once in the store, so
-- this is safe to call from either path.
--
-- ★ IT MUST BE CALLABLE FROM ARM, and run 1 is why. The original only ran on
-- PLAYER_ENTERING_WORLD, which meant a run armed INSIDE the dungeon - the natural
-- thing to do, since you zone in and then start recording - captured NO arrival
-- and NO difficulty. Record RFC_run1_clean-1: 15 pulls, 99 legs, boss engagement,
-- and `instance = nil`. The event had already fired before the run existed.
function captureOrigin()
    if not runId or not inInstance() then return end
    Store.SetArrival(runId, Store.Point())     -- write-once

    -- DR-30: difficulty is route IDENTITY. Signature per RaidProfiles.lua:540.
    if GetInstanceInfo then
        local name, iType, diffIndex, diffName, maxPlayers = GetInstanceInfo()
        Store.SetInstance(runId, {
            name = name, type = iType,
            difficultyIndex = diffIndex, difficultyName = diffName,
            maxPlayers = maxPlayers,
        })
    end
end

-- PLAYER_ENTERING_WORLD also fires on login and on every /reload, so the guards
-- above (armed, and actually inside) carry the whole weight.
local function onEnteringWorld()
    captureOrigin()
end

function Capture.Init()
    Store = NS.Store
    frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    frame:RegisterEvent("PLAYER_DEAD")
    frame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
    frame:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_REGEN_DISABLED" then
            onCombatStart()
        elseif event == "PLAYER_REGEN_ENABLED" then
            onCombatEnd()
        elseif event == "PLAYER_DEAD" then
            onPlayerDead()
        elseif event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
            onEncounterEngage()
        else
            onEnteringWorld()
        end
    end)
    -- No OnUpdate here on purpose: it is installed by Arm and cleared by Stop.
    return frame
end
