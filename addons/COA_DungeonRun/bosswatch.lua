-- COA_DungeonRun bosswatch.lua - the boss-death listener (RI-66, A6.2).
--
-- Model: addons/planning/DRIVER_BASIS.md   READ FIRST. It names what governs NOW, in
--        precedence order, and it MOVES when a ruling moves - so this line never
--        goes stale. Lower number wins; a disagreement is reported, not resolved here.
--
-- ---------------------------------------------------------------------------
-- ★★★ WHAT IT IS, and what it deliberately is NOT.
--
-- It answers ONE question about the client: **did a unit with this name just die?** It
-- says nothing about what that should mean. A consumer arms a name, gets told, and decides
-- for itself - which is `provide-vs-handle`: we generate the input contract, never the
-- consumer's handling.
--
-- ⚠ SO IT IS NOT THE MANAGER'S. `manager.lua` states plainly that *"nothing here invents
-- what `note`, `say` or `boss` DO"*, and a CLEU listener inside it would make this file's
-- reading of a kill the addon's de-facto answer for a word that is still a contract.
-- ★ It is the same seam `sensor.lua` occupies for position: a module that reads the
-- client and publishes a fact, wired by whoever consumes it.
--
-- ⚠ AND IT IS NOT `capture.lua`'s CODE REUSED - RI-66 left that open and it is now
-- measured, not guessed. `capture.lua:281` reads **boss TOKENS** (`boss1`..`boss5` via
-- `UnitExists`), which answers *is a boss engaged*. A token cannot answer *did it die*:
-- the token is gone the moment the unit is. Two different questions, two different client
-- surfaces, and reusing one for the other would have been a plausible wrong.
--
-- ---------------------------------------------------------------------------
-- ★★★ THE ARGUMENT SHAPE IS A CLIENT FACT AND IT IS NOT OURS TO GUESS.
-- `operations/ROUTER.md`: *"CLEU on 3.3.5 is the classic VARARGS tuple - 1 ts · 2 subevent
-- · 3-5 src (GUID, name, flags) · 6-8 dst · 9+ suffix. `CombatLogGetCurrentEventInfo` is
-- FURNITURE on this fork."*
-- ⟶ So the destination NAME is the 7th vararg, read by position, and the retained-buffer
-- API that the fork DECLARES is not used - `cleu_on_this_fork.md` measured it **empty when
-- read, in five samples across four conditions.**
--
-- ★★ AND THE MASK IS LEAN BY DECISION, not by taste (`cleu_on_this_fork.md`, measured
-- 2026-08-13 on his own control segment): unpack the subevent, compare, return, and
-- **allocate nothing in the hot path**. A masked arm measured at or BELOW the no-listener
-- arm on both runs, so cost is not the argument for staying off the event - but the
-- cheapest listener is still the one that is not registered, which is why this one
-- registers only while a name is armed and unregisters when the last one goes.
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local BossWatch = {}
NS.BossWatch = BossWatch

-- name -> { fn, fn, ... }. A LIST per name, because two tabs may wait on the same boss
-- and dropping one of them would be a silent half-advance.
local armed = {}
local count = 0
local frame

-- ★ THE SEAM FOR THE HARNESS, and it is the same shape `Sensor.Sample` uses. Offline
-- there is no combat log, so a test drives the fact in rather than the event.
-- ⚠ It is a SEAM, not a stub: nothing here supplies it, so a harness that forgets to
-- drive it proves nothing rather than proving a fiction.
function BossWatch.Died(name)
    if type(name) ~= "string" or name == "" then return 0 end
    local list = armed[name]
    if not list then return 0 end

    -- ⚠⚠ TAKEN OFF THE LIST BEFORE THE CALLBACKS RUN. A body may arm another name, or
    -- disarm this one, and a list being walked while it is edited is the fault that reads
    -- as *"it fired twice"* long after the code that did it has moved on.
    armed[name] = nil
    count = count - 1
    if count <= 0 then BossWatch.Stop() end

    local n = 0
    for _, fn in ipairs(list) do
        n = n + 1
        fn(name)
    end
    return n
end

-- ⚠ THE HANDLER READS BY POSITION AND RETURNS EARLY. Everything before the first compare
-- is two locals and no table; `UNIT_DIED` is a small fraction of the traffic and every
-- other subevent must cost nothing to reject.
local function onEvent(_, event, ...)
    if event ~= "COMBAT_LOG_EVENT_UNFILTERED" then return end
    local sub = select(2, ...)
    if sub ~= "UNIT_DIED" then return end
    local destName = select(7, ...)
    if destName then BossWatch.Died(destName) end
end

function BossWatch.Start()
    if frame then return frame end
    if not CreateFrame then return nil end
    frame = CreateFrame("Frame", "COA_DungeonRunBossWatch")
    frame:SetScript("OnEvent", onEvent)
    frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    return frame
end

function BossWatch.Stop()
    if not frame then return end
    -- ★ UNREGISTERED, NOT HIDDEN. A hidden frame with a live registration still costs the
    -- call per event, which is the whole thing the lean-mask decision was measuring.
    frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

-- ★★ ARM IS BY NAME AND THE NAME IS THE AUTHOR'S ARG. A6.2: *the kill alone satisfies* -
-- the arming witness is the player's SENSE holding, not an engage token, and engage is at
-- most a driver-side arm and never a required author witness.
-- ⟶ So nothing here waits for an engage, and nothing here checks one.
function BossWatch.Arm(name, fn)
    -- ⚠ TWO LINES, NOT ONE, AND THE SPLIT IS DELIBERATE. A TYPE refusal and an EMPTY-name
    -- refusal are different faults, and one guard covering both cannot be broken a fault at
    -- a time - breaking it made the first refusal a table-index error and the mutation
    -- proved only that the file parses.
    if type(name) ~= "string" or type(fn) ~= "function" then return nil end
    if name == "" then return nil end
    if not armed[name] then armed[name] = {}; count = count + 1 end
    local list = armed[name]
    list[#list + 1] = fn
    BossWatch.Start()
    return name
end

-- ★★★ DISARM IS THE HALF A12.4c IS ABOUT, and it is the frequent case rather than the
-- rare one: *"a reader leaves a node's reach mid-stage and its CLEU listener must go with
-- it."* Disarming only on ADVANCE leaves a boss killed anywhere later in the stage
-- completing a tab nobody is standing in.
function BossWatch.Disarm(name)
    if name == nil then
        armed, count = {}, 0
        BossWatch.Stop()
        return true
    end
    if not armed[name] then return false end
    armed[name] = nil
    count = count - 1
    if count <= 0 then BossWatch.Stop() end
    return true
end

function BossWatch.Armed(name)
    if name == nil then return count end
    return armed[name] ~= nil
end

-- ⚠ READ FOR TESTS AND FOR THE READOUT, never for a decision. A consumer that branches on
-- this is re-deriving what `Arm` already told it.
function BossWatch.Names()
    local out = {}
    for name in pairs(armed) do out[#out + 1] = name end
    table.sort(out)
    return out
end

function BossWatch.Listening() return frame ~= nil and count > 0 end
