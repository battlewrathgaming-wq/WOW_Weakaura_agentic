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

-- ★★★ RULING: capture is the ONLY spawn - everything downstream inherits, nothing derives
-- ★★★ RULING: we hold WHAT HAPPENED, never what the world is or what it meant
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
local captureMapArt

-- ★★★ FACT: [SILENT] a `local function` referenced ABOVE its declaration resolves to a NIL
--   GLOBAL - and SetScript("OnUpdate", nil) is LEGAL, so the handler silently
--   never runs. ⚠ Shipped live TWICE; recorded five times across two addons.
--   Dropping `local` to "fix" it leaks into _G instead.
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

    -- ★ `isPlayer` IS A FILTER, not decoration. The recap folds SPELL_HEAL as well
    -- as damage, so a heal lands in the buffer with `attacker` set to the HEALER -
    -- which in RFC_Run3_Messy put "Gravereaper", his own character, in a killedBy
    -- list. Read literally, `attacker` means "the caster of this event", not "an
    -- enemy", and without this guard killedBy means "who appeared in the last 14
    -- events" - which in a group would name your healer.
    --
    -- Excluding players is exactly his scope ruling: "when a friendly or their pet,
    -- or when the tank died, is product of a bad run. Not the model to build a
    -- route against." (The recap's own IsPlayer() is COMBATLOG_OBJECT_TYPE_PLAYER
    -- off casterFlags - see DRIVER_CONTRACT.md.)
    local seen, out = {}, {}
    for _, e in ipairs(buf) do
        local a = type(e) == "table" and e.attacker or nil
        if type(a) == "string" and not e.isPlayer and not seen[a] then
            seen[a] = true
            out[#out + 1] = a          -- first-seen order; dedupe is offline's job
        end
    end
    if #out == 0 then return nil, "recap buffer held no named attacker" end
    return out, nil
end

-- ---------------------------------------------------------------------
-- DR-31: which units carried a BOSS TAG during a pull. Route identity - a run that
-- engages two of them is a different route from one that engages four.
--
-- ★ NOT "bosses", AND NOT ENCOUNTERS. We hold unit names that had a boss token at
-- that moment. Whether two of those names belong to ONE fight is dungeon knowledge,
-- which §17 says we do not hold - so the field cannot be labelled as a boss count
-- or a boss list without asserting structure we never captured (§58).
--
-- It is the same shape as "what died in this pull", except the boss tags are what
-- flew out. That is all it is.
--
-- Live-verified 2026-08-13 (record 20260813_014009_176): `boss1` exists and is
-- ★★★ FACT: [SILENT] UnitExists returns 1, NOT true - never compare against `true`
--   The archetypal 3.3.5-ism. Same shape as IsInInstance.
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
-- ★ DR-35: WE NOW SAMPLE IN COMBAT TOO, and the reasoning above it was wrong.
--
-- "In combat the marker pair already covers it" holds only for SHORT pulls.
-- Battlewrath, 2026-08-13, reading the third draw: *"On short pulls the absence is
-- clarity. On long pulls / big packs, all routing gets lost."*
--
-- The picture showed it plainly: continuous dot chains down the corridors where
-- you WALKED, and bare floor between markers in the western rooms where you
-- FOUGHT. And it is worst exactly where a guide has most to say - where you pull
-- them back to, where you fight a pack from. It also degrades as the group gets
-- BETTER: a chain-pulling run records almost no path at all.
--
-- Cost is unchanged. The tick already ran at 1/s and simply RETURNED in combat;
-- now it writes. The gate that remains is the one that was always load-bearing:
--
--   IN AN INSTANCE - outside one there is no run to draw.
--
-- In-combat samples carry `combat = true` (the qualifier, exactly as `ghost` does)
-- and `n` = the pull they belong to. The pull index is free here - we are already
-- counting it - and it is the JOIN that lets curation isolate a single pull later.
--
-- The throttle sits BEFORE the work, not after. The addon census caught
-- COA_Landmarks calling GetCurrentPlayerPosition() 59 times a second and
-- throwing the result away - the throttle was real and sat in the wrong place.
-- ---------------------------------------------------------------------

-- ★★ DEFER, DO NOT DROP - and §66 got this exactly backwards.
--
-- GetMapInfo() answers about the map the WORLD MAP IS SHOWING, so with the map open
-- on another zone it names that zone's tiles. §66 guarded that by REFUSING to write
-- unless it could confirm we were looking at ourselves - and the confirmation
-- compared `GetCurrentMapAreaID() - 1` against the player's mapID, which is an
-- assumption about two id spaces that was never verified.
--
-- ★ IT FAILED CLOSED, AND THAT IS THE WORSE FAILURE. A missing mapFile is
-- write-once and permanent: the run is in-zone-only forever, which is exactly the
-- pre-DR-34 state DR-34 exists to end. Battlewrath caught it as a regression on the
-- first runs captured after it shipped.
--
-- ⚠ And it rested on a claim of mine that is FALSE. §66 said "Map.ArtFor's identity
-- guard catches the mismatch" - it does not. ArtFor returns a stored mapFile
-- UNCONDITIONALLY (map.lua:373); the identity check only governs the in-zone
-- FALLBACK. So a wrong stored file would draw this run's points on another
-- dungeon's tiles, anywhere, forever. The guard was defending something real; it
-- was the failure mode that was wrong.
--
-- So: write only when the world map is CLOSED - which we can prove, because we snap
-- it to the current zone ourselves and GetMapInfo is then definitionally about where
-- we stand - and RETRY every tick until it lands. The first moment the user closes
-- their map, the art is captured. No comparison, no assumption, and no run left
-- undisplayable because the map happened to be open at arm.
function captureMapArt()
    if not runId or not GetMapInfo then return false end
    if Store.Get(runId) and Store.Get(runId).mapFile then return true end   -- write-once
    if WorldMapFrame and WorldMapFrame:IsShown() then return false end      -- try again next tick
    if SetMapToCurrentZone then pcall(SetMapToCurrentZone) end
    local mapFile, mapW, mapH = GetMapInfo()
    if not mapFile or mapFile == "" then return false end
    local terrain = DungeonUsesTerrainMap and DungeonUsesTerrainMap() or nil
    return Store.SetMapArt(runId, mapFile, mapW, mapH, terrain) and true or false
end

function onUpdate(_, elapsed)
    acc = acc + elapsed
    if acc < SAMPLE_EVERY then return end      -- a float compare, nothing more
    acc = 0

    if not runId then return end
    if not inInstance() then return end

    -- DR-13: the ghost flag is one API read on a tick we are already running.
    -- A corpse run would otherwise draw as a bizarre excursion with nothing in
    -- the record to say why.
    -- ★ The retry. One nil check a second until the art lands, then never again.
    captureMapArt()

    local ghost = UnitIsGhost and UnitIsGhost("player") and true or false
    -- DR-1 again: read the STATE, do not infer it. The tick is not an event, so
    -- there is nothing here to infer from in the first place.
    local pull = UnitAffectingCombat("player") and pulls or nil
    Store.AddLeg(runId, Store.Point(), ghost, pull)
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
-- ★★ DR-36: THE CUSTOM PIN - the capture for what the client emits NOTHING for.
--
-- Everything else here is emitted by play: regen edges the client hands us, a
-- tick every second, a death recap. But a route's most useful beats emit nothing
-- at all - a jump skip, a route-shape decision, a moment that matters for a reason
-- the game has no event for. Battlewrath: *"asking them to infer through events
-- they didn't have input is asking them to guess."*
--
-- The only alternative would be inferring from a gap in the legs, which is
-- DERIVING - already ruled out (§14) - and worse here, because we would be
-- guessing at something the player KNEW at the time.
--
-- ★ So the pin makes the player an EVENT SOURCE rather than only the subject of
-- one. The bench thesis was *we can infer through observable, recordable events*;
-- this extends it: WHERE THE CLIENT EMITS NOTHING, THE PLAYER IS THE SENSOR.
--
-- ★ AND IT CARRIES NO MEANING. A pin is a point. Promotion is where it becomes
-- something - Battlewrath, correcting an earlier draft of this comment: *"it's
-- capture. Then later promote gives it meaning."* Calling it a claim, or typing it
-- at capture, would put interpretation at the one place this addon refuses it.
--
-- It is the CATCH-ALL: for what nothing else captures. Not the tactical marker -
-- that question has better-typed sources already and is promote's to answer.
--
-- Ungated beyond armed. Refusing a capture needs a reason and there isn't one.
-- ---------------------------------------------------------------------
function Capture.Pin()
    if not runId then return nil, "not recording" end
    -- `pulls` rides along because it is free and it JOINS the pin to the pull it
    -- happened in or after. Same field the markers carry; no new concept.
    return Store.AddMarker(runId, Store.Point(), "pin", pulls)
end

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

-- ★★★ FACT: [SILENT] AscensionUI.DeathRecap is readable ONLY at PLAYER_DEAD - CurrentRecap
--   rolls on PLAYER_UNGHOST and PLAYER_ENTERING_WORLD, so any later read finds an
--   empty buffer. ⚠ And it folds SPELL_HEAL as well as damage, so `attacker` can be
--   a HEALER unless filtered on isPlayer - it once put his own character in a
--   killedBy.
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

    -- ★ DR-34: the map's TILE FILE, stored at capture so the run can be displayed
    -- from ANYWHERE - editing a route should not require standing in the dungeon.
    --
    -- Tile art lives at Interface\WorldMap\<file>\<file>[<floor>_]<1..12>, and <file>
    -- comes from GetMapInfo(), which only answers for where you ARE or what the map
    -- is currently showing. Standing in Orgrimmar we could not name Shadowfang's
    -- tiles. Three ways out, and only one is consistent with the rest of this design:
    --   * SetMapByID(mapID) then read it - the API EXISTS (the client calls it), so
    --     this is a WE-DON'T, not a we-can't. It mutates the shared world map, which
    --     is the singleton we have stayed out of throughout, and the user would open
    --     their map to find it moved.
    --   * look it up in a shipped table - §17's forbidden per-dungeon data.
    --   * STORE WHAT THE CLIENT TOLD US, here, while we are standing in it.
    -- Same pattern as the fraction and the floor. GetMapInfo also returns the art's
    -- dimensions; they cost nothing and the display frame needs them.
    -- ⚠ THE TRUST BOUNDARY, and the account of it lives at the TOP OF THIS FILE.
    --
    -- GetMapInfo() and DungeonUsesTerrainMap() describe the map the WORLD MAP IS
    -- SHOWING, not the player - so arming with the map open on another zone would
    -- write that zone's tiles as this run's art, write-once and permanent. §70's
    -- answer is to DEFER and retry each tick until the map is closed, never to
    -- refuse; see the block above `captureMapArt`.
    --
    -- ★★ WHAT USED TO BE HERE WAS A FOSSIL, and it carried a ★★ while being false
    -- twice over: it claimed `Map.ArtFor`'s identity guard catches the mismatch
    -- (ArtFor returns a stored mapFile UNCONDITIONALLY - map.lua:457, first line),
    -- and it described a `GetCurrentMapAreaID()` comparison as the check when
    -- `captureMapArt` never calls it. **This same file refuted both 200 lines
    -- earlier** and the stale copy outranked the correction on emphasis.
    --
    -- ⚠ That is invariant 3 - *a stored field isn't a live field* - reappearing as a
    -- stored COMMENT that isn't a live one. Found by an audit, not by reading.
    captureMapArt()

    -- DR-30: difficulty is route IDENTITY.
    --
    -- ★ SIGNATURE CORRECTED FROM A LIVE PROBE (record 20260813_055307_481__dump).
    -- The client's own call sites unpack SEVEN returns at most
    -- (RaidProfiles.lua:540), but this fork returns EIGHT - the extra one is the
    -- mapID. It only surfaced because the probe put the call LAST so it would
    -- expand fully instead of being truncated to its first value.
    --
    -- ★ AND `difficultyName` COMES BACK EMPTY on this fork, on every instance we
    -- have measured. The INDEX is the fact; the label is not populated. The
    -- client's own resolver fills it: GetDifficultyInfo(index) -> "Normal"
    -- (GlobalFunctions.lua:262, live-confirmed). We prefer the raw value when it
    -- is there, so if the fork ever starts populating it we use theirs rather
    -- than a lookup that could drift from it.
    if GetInstanceInfo then
        local name, iType, diffIndex, diffName, maxPlayers, _, _, iMapID = GetInstanceInfo()
        if (diffName == nil or diffName == "") and GetDifficultyInfo and diffIndex then
            diffName = GetDifficultyInfo(diffIndex) or diffName
        end
        Store.SetInstance(runId, {
            name = name, type = iType,
            difficultyIndex = diffIndex, difficultyName = diffName,
            maxPlayers = maxPlayers,
            -- Redundant with the mapID on every point, and kept ON PURPOSE: two
            -- independent sources for the same fact make a disagreement visible
            -- instead of silent.
            mapID = iMapID,
        })
    end
end

-- ★★ FACT: [SILENT] PLAYER_ENTERING_WORLD also fires on LOGIN and on every /reload
--   - it is not an "entered the instance" event. ⚠ Hung on it alone, an arm handler
--   runs every reload and looks like it worked; the armed/inside guards carry it.
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
