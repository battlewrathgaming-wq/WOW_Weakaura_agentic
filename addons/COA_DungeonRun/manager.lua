-- COA_DungeonRun manager.lua - THE ONE STATEFUL OWNER OF AN ACTIVE ROUTE.
--
-- Model: addons/planning/DRIVER_BASIS.md   READ FIRST. It names what governs NOW, in
--        precedence order, and it MOVES when a ruling moves - so this line never
--        goes stale. Lower number wins; a disagreement is reported, not resolved here.
-- Graded by: addons/planning/driver_manager_acceptance.md  A12.1 - A12.9
-- Record: Reconcile_inbox.md RI-42, the architect's instruction that created this file.
--
-- ---------------------------------------------------------------------------
-- ★★★ WHAT THIS OWNS, from RI-42 verbatim:
--
--     the offer for this map and the one selection · current stage · current step · the
--     completion LEDGER · firing Next · the bucket swap · the three tracker writes ·
--     arming/disarming listeners · the stage line · the terminal state · the one saved
--     slot (selected RID, never progress).
--
-- ★★★ AND WHAT IT NEVER DOES, same source:
--
--     never polls · never evaluates geometry · never interprets on the hot path · never
--     mutates the armed list mid-poll · never holds two active routes.
--
-- ⚠ THE LAST ONE IS STRUCTURAL HERE, not a rule anybody has to remember: there is ONE
-- upvalue, `active`, and `Select` tears the old one down BEFORE it builds (A12.1a).
--
-- ---------------------------------------------------------------------------
-- ★★ THE TWO HALVES OF THE BLINDNESS LAW, which is why the manager exists at all:
--
--     IN     the manager writes a LIST, never a RULE          (his words, 2026-08-21)
--     OUT    the sensor reports an ADDRESS, never a MEANING
--
-- ⟶ Every MEANING in the run - this address is a park, that one is a lure, this tab is
-- done - lives in this file, because the sensor cannot know any of it without ceasing
-- to be blind.
--
-- ---------------------------------------------------------------------------
-- ⚠⚠ WHAT IS SPLAYED, AND WHY - `driver.lua`'s house style: an open thread is left
-- NAMED and REACHABLE rather than defaulted quietly, because a default is a decision
-- taken by whoever wrote it and these are not the bench's to take.
--
--     ⬜ AUTHORED `Next`      Model row 12 rules `Next` ONE field, `(Type, arg)` -
--                             Step · Stage · Set(N). **`routes.lua` has no such field.**
--                             It stores `role` (start/update/complete/set) + `setStage`.
--                             The mapping between the two vocabularies is stated nowhere,
--                             so this file implements only the path that needs no `Next`
--                             (below) and REPORTS the rest. See RI-49.
--     ⬜ `Trigger`            A12.4b: not built, no code term chosen. The slot is declared
--                             so the shape does not move when it lands.
--     ⬜ THE ACTION BODIES    A12.2c's binder. `Manager.Bind` is the door; nothing here
--                             invents what `note`, `say`, `boss` or `supertrack` DO.
--     ⬜ THE TRACKER          `Manager.Tracker` is a seam for the same reason
--                             `Sensor.Sample` is one: a direct client call here would make
--                             this file ungradable offline, and the bench PROVES on
--                             synthetic rows (`driver_architecture.md` §7).
--
-- ★ WHAT MAKES IT RUNNABLE ANYWAY: A12.5a and A12.5b fully specify the path that has no
-- authored `Next` - a node completes, the STEP goes to the next positive ordinal; the
-- ordinals RUN DRY, the STAGE goes to the next stage PRESENT. That is a whole run.
-- ---------------------------------------------------------------------------

local NS = select(2, ...)
NS = NS or _G.COA_DungeonRun_NS or {}
if select(2, ...) == nil then _G.COA_DungeonRun_NS = NS end

local Manager = {}
NS.Manager = Manager

-- ★ THE ONE ACTIVE ROUTE. Never a list, never two - A12.1a is enforced by there being
-- nowhere to put a second.
local active = nil

-- ⚠ A SEAM, not an omission (A12.2c, and the same shape as `Sensor.Sample`). The manager
-- OWNS the tracker writes; what a write DOES is the client's. Expected shape:
--     Manager.Tracker = { Point = function(node) end, Park = function() end }
Manager.Tracker = nil

-- ⚠ THE BINDER'S DOOR (A12.2c · L2.4). A word with no callable is REFUSED at arm time and
-- NAMED - "no silent orphan" one level up from A12.2f. Nothing is bound here.
local actions = {}

local function say(msg)
    if NS.Say then NS.Say(msg) end
end

-- ---------------------------------------------------------------------
-- THE BINDER
-- ---------------------------------------------------------------------

-- ★★ A CALLABLE RECEIVES A CONTEXT AND SAYS WHETHER THE TAB IS DONE.
--
--     fn(ctx) -> true          the tab completed now
--     fn(ctx) -> false / nil   the tab is PENDING; something else completes it later
--
-- ⚠ THE PENDING CASE IS NOT SPECULATIVE - A12.4c is written on it: *"a reader leaves a
-- node's reach mid-stage and its CLEU listener must go with it"*. A `boss` tab arms a
-- listener and finishes when the boss dies, which is not when the tab RAN.
-- ★ `ctx.complete()` is how the later thing says so.
--
-- ⟶ MARKED AS THE BENCH'S SHAPE, and cheap to push back on: if design wants the callable
-- to return a status word instead of a boolean, it is a two-line change and the tests
-- move with it.
function Manager.Bind(word, fn)
    if type(word) ~= "string" then return nil, "a binding needs a word" end
    if fn ~= nil and type(fn) ~= "function" then return nil, "a binding needs a function" end
    actions[word] = fn
    return word
end

function Manager.Bound(word) return actions[word] end

-- ⚠ FOR THE HARNESS AND FOR A RELOAD, not for the run. Clearing bindings mid-run would
-- leave armed tabs with nothing to call, which is exactly the silent orphan A12.2f names.
function Manager.ClearBindings()
    if active then return nil, "a route is active" end
    actions = {}
    return true
end

-- ---------------------------------------------------------------------
-- A12.1c · THE OFFER (§4b step 0)
-- ---------------------------------------------------------------------

-- ★ The offer and the build agree on the map by TWO INDEPENDENT PATHS - `Routes.List`
-- filters, and `Bucket.Build` refuses a route whose mapID is not the one asked for. This
-- function is the first of the two and adds nothing to it.
function Manager.Offer(mapID)
    local Routes = NS.Routes
    if not Routes or not Routes.List then return {} end
    return Routes.List(mapID) or {}
end

-- ---------------------------------------------------------------------
-- STATE, READ-ONLY TO EVERYONE ELSE
-- ---------------------------------------------------------------------

function Manager.Running() return active ~= nil end
function Manager.Stage() return active and active.stage or nil end
function Manager.Step() return active and active.step or nil end
function Manager.Bucket() return active and active.bucket or nil end

-- ⚠ THE SELECTION OUTLIVES THE ARMING (A12.8a: *"the route stays SELECTED but not
-- armed"*), so this reads the STORE and not `active`. A12.9a's one slot.
function Manager.Selected()
    local Store = NS.Store
    return Store and Store.SelectedRoute and Store.SelectedRoute() or nil
end

-- ★ THE LEDGER, READABLE. `capability makes inspection cheap` - a look-back at why a
-- stage did not advance is an audit rather than an investigation.
function Manager.Ledger()
    return active and active.done or nil
end

-- ---------------------------------------------------------------------
-- ARM · DISARM · TERMINAL
-- ---------------------------------------------------------------------

-- ⚠ EVERY WORD IN THE STAGE'S ROWS MUST HAVE A CALLABLE BEFORE ANYTHING ARMS. Checking
-- at DISPATCH instead would discover it mid-run, mid-combat, one tab at a time - which is
-- row 24's whole complaint about deferred failure, one tier up.
local function unbound(list)
    for _, node in ipairs(list) do
        for i, row in ipairs(node.rows or {}) do
            -- ★★★ A ROW MAY NAME NO ACTION (AL-18), and then there is no callable to
            -- want. ⚠ MEASURED, NOT ASSUMED: without this line an arrival row made the
            -- WHOLE ROUTE unarmable - `actions[nil]` is nil, so the gate below read it as
            -- an unbound word and refused. The seed row AL-18 puts on every node would
            -- have refused every route on the first arm.
            if row.action ~= nil and actions[row.action] == nil then
                return ("%s row %d: no callable is bound for `%s`")
                    :format(tostring(node.address), i, tostring(row.action))
            end
        end
    end
    return nil
end

-- ★★ A12.3b · THE CURRENT STAGE **AND BUCKET 0**, TOGETHER - and it is `Bucket.Stage`
-- that puts them together, so A12.7a's *"bucket 0 is armed on every pass BY
-- CONSTRUCTION"* is true here by having no other path.
local function armCurrent()
    local Sensor, Bucket = NS.Sensor, NS.Bucket
    if not active then return nil, "nothing is selected" end

    local list = Bucket.Stage(active.bucket, active.stage, active.step)
    local why = unbound(list)
    if why then return nil, why end

    Sensor.Arm(list)

    -- ★★★ A12.3c · THE ENTRY LURE IS THE STAGE'S, AND **TRAY-0 ITEMS NEVER WRITE THE
    -- ARROW** (AL-6): recovery is observed and corrected, not steered. ⚠ So this picks
    -- from the STAGE's own slice rather than from `list`, which carries bucket 0 too -
    -- pointing at a recovery beacon from the first sample is the mutation this row names.
    -- ★★★ AND THE NODE MUST BE **LED TO** (AL-19). Waypointing is the node's tick, not
    -- a verb: *"the super tracker is what gets the player TO the sense site."*
    -- ⚠ `node.ledTo` is computed at BUILD by `Routes.LedTo`, which already refuses a
    -- stage-0 node and an ordinalless child - *"these are PASSIVE DETECTORS rather than
    -- where we're pushing the players"* - so this reads one field instead of re-deriving
    -- a rule that lives in one place.
    if Manager.Tracker and Manager.Tracker.Point and active.stage > 0 then
        for _, node in ipairs(list) do
            if node.stage == active.stage and (node.step or 0) == active.step
               and node.ledTo then
                Manager.Tracker.Point(node)
                break
            end
        end
    end
    return true
end

-- ⚠ DISARM IS THE SENSOR'S LIST **AND** THE PENDING LISTENERS. A12.4c: a tab that armed
-- something and never completed leaves that thing armed, and *"a boss killed anywhere
-- later in the stage still completes that tab"* is the failure it describes.
local function disarmAll()
    local Sensor = NS.Sensor
    if Sensor and Sensor.Disarm then Sensor.Disarm() end
    if active then
        for _, drop in pairs(active.pending) do
            if type(drop) == "function" then pcall(drop) end
        end
        active.pending = {}
    end
end

-- ★★ A12.8a · TERMINAL. Disarm everything, tracker to the PARK, **the route stays
-- SELECTED**. ⚠ The selection is in the STORE, so it survives this by not being touched.
function Manager.Stop(reason)
    if not active then return false end
    disarmAll()
    if Manager.Tracker and Manager.Tracker.Park then Manager.Tracker.Park() end
    active = nil
    say(reason or "DungeonRun: route finished - the route is still selected")
    return true
end

-- ---------------------------------------------------------------------
-- A12.1a · SELECT — and the teardown happens FIRST
-- ---------------------------------------------------------------------

-- ⚠⚠ THE ORDER IS THE ROW. A12.1a's mutation is *"allow the second to build first"*, and
-- the test *"at no point do two buckets exist"*. ⟶ `Manager.Stop()` runs BEFORE
-- `Bucket.Build`, so a build that then FAILS leaves nothing active - which is the honest
-- outcome: the reader asked for a different route and did not get it.
function Manager.Select(mapID, rid)
    local Bucket, Store = NS.Bucket, NS.Store

    if active then Manager.Stop("DungeonRun: switching route") end

    local bucket, why = Bucket.Build(mapID, rid)
    if not bucket then return nil, why end

    -- ★ A12.9a · ONE SLOT, and it is written on SELECT rather than on arm: the selection
    -- is what survives a reload, and progress is never saved.
    if Store and Store.SetSelectedRoute then Store.SetSelectedRoute(rid) end

    active = {
        mapID = mapID,
        rid = rid,
        bucket = bucket,
        -- ★ A12.3a · the LOWEST POSITIVE stage, never 0. Derived from the bucket so it is
        -- right whichever way A11.5a is read (RI-39).
        stage = Bucket.FirstStage(bucket),
        step = nil,
        done = {},        -- address -> { [rowIndex] = true }
        pending = {},     -- address..":"..i -> a disarm function, for A12.4c
    }
    active.step = Bucket.FirstStep(bucket, active.stage)

    local ok, armWhy = armCurrent()
    if not ok then
        active = nil
        return nil, armWhy
    end
    say(("DungeonRun: route armed at stage %d, step %d")
        :format(active.stage, active.step))
    return true
end

-- ---------------------------------------------------------------------
-- A12.4 · DISPATCH — and A12.6a, which is why nothing advances inside the loop
-- ---------------------------------------------------------------------

local function nodeComplete(node)
    local done = active.done[node.address]
    if not done then return false end
    local rows = node.rows or {}
    if #rows == 0 then return false end
    for i = 1, #rows do
        if not done[i] then return false end
    end
    return true
end

-- ★ A tab's own completion door, handed to the callable so a LATER event can close it.
local function completer(node, i)
    return function()
        if not active then return end
        local done = active.done[node.address]
        if not done then done = {}; active.done[node.address] = done end
        done[i] = true
        active.pending[node.address .. ":" .. i] = nil
    end
end

-- ★★★ A12.4a · ONLY THE TABS WHOSE SENSE-WORD MATCHES, and the sensor has already done
-- the differencing - `changed` is the CHANGED set, not the in-set. ⚠ Its mutation is
-- *"return the whole in-set instead"*, and the symptom is tabs re-firing every sample.
--
-- ⚠⚠ A12.6a · **NOTHING IS SWAPPED INSIDE THIS LOOP.** Model row 26: the sensor's result
-- changes the sensor's input, so the armed list must not be mutated mid-poll, or one
-- sample sees two different armed sets. ⟶ Completions are COLLECTED and acted on after.
function Manager.OnPoll(changed)
    if not active or type(changed) ~= "table" then return nil end

    local completed = {}
    for _, ch in ipairs(changed) do
        local node = ch.node
        for i, row in ipairs(node and node.rows or {}) do
            if row.sense == ch.word then
                -- ★★★ A12.4d · A NO-ACTION TAB COMPLETES ON ITS SENSE. `When on` with no
                -- action means REACHED - arrival IS the behaviour - so the transition
                -- arriving IS the whole of the tab, and there is nothing to wait for.
                --
                -- ⚠⚠ WITHOUT THIS THE TAB NEVER COMPLETES AND THE STAGE STALLS IN
                -- SILENCE: `actions[nil]` is nil, so the branch below was skipped and the
                -- row sat unfinished forever, holding its node - and a node never
                -- completing is a run that arms, points the arrow and never advances.
                -- ★ The same failure class `A12.2g` refuses at build, reappearing at
                -- DISPATCH because the row was legal and the handling was not written.
                if row.action == nil then
                    completer(node, i)()
                end
                local fn = actions[row.action]
                if fn then
                    local finish = completer(node, i)
                    local ok, ret = pcall(fn, {
                        address = ch.address, node = node, row = row,
                        word = ch.word, arg = row.arg, complete = finish,
                    })
                    -- ⚠ A CALLABLE THAT ERRORS DOES NOT COMPLETE ITS TAB and does not take
                    -- the run down with it. `Say` rather than silence: a tab that never
                    -- completes stalls a stage, and that must be findable.
                    if not ok then
                        say(("DungeonRun: the `%s` action errored - its tab is not complete")
                            :format(tostring(row.action)))
                    elseif ret then
                        finish()
                    end
                end
            end
        end
        -- ★★ A12.4c · LISTENERS DISARM ON `When off`, not only on advance - the more
        -- frequent case by far, and §4b step 4's own parenthesis.
        if ch.word == (NS.Sensor and NS.Sensor.WHEN_OFF) then
            for key, drop in pairs(active.pending) do
                if key:sub(1, #ch.address + 1) == ch.address .. ":" then
                    if type(drop) == "function" then pcall(drop) end
                    active.pending[key] = nil
                end
            end
        end
        if node and nodeComplete(node) then completed[#completed + 1] = node end
    end

    -- ---- AFTER THE POLL (A12.6a) ------------------------------------------------
    for _, node in ipairs(completed) do
        Manager.NodeDone(node)
    end
    return completed
end

-- ---------------------------------------------------------------------
-- A12.5 · COMPLETE, and A12.6b · ADVANCE
-- ---------------------------------------------------------------------

-- ★★ A12.5a's `Next`, in the ONE form the store can express today: **Step**.
--
-- ⚠ A node at step 0 advances NOTHING. The ordinalless child is the pass-through WITHIN
-- its stage - always open, holding no position in the sequence - so completing it cannot
-- move a cursor it was never on. (His table: `0 <- Check`, and it is a check, not a step.)
--
-- ⬜ Stage and Set(N) are the SPLAYED half. They need an authored `Next`, and `routes.lua`
-- stores `role` + `setStage` instead. RI-49 asks for the mapping; nothing is guessed here.
function Manager.NodeDone(node)
    if not active or not node then return nil end
    if node.stage ~= active.stage then return nil end

    -- ★★★ AN ITEM OF ONE COMPLETES ITS **STAGE** — and this was a LIVE DEFECT.
    --
    -- ⚠⚠ MEASURED (§476): a childless beacon carries step 0, the guard below bailed on
    -- `step <= 0`, and **the run sat at that stage forever** - armed, arrow written, and
    -- unable to advance. A12.5b names the case exactly: *"a childless beacon is the limit
    -- case - an item of one."* Its ordinal cannot run dry because it never had one, so
    -- completing IT is the stage completing.
    --
    -- ★ The same distinction Battlewrath drew for the tick separates it from the OTHER
    -- step-0 node: *"these are passive detectors rather than where we're pushing the
    -- players."* An ordinalless CHILD advances nothing; a lone BEACON is the position.
    if node.lone then return Manager.StageDone() end

    if (node.step or 0) <= 0 then return nil end

    local Bucket = NS.Bucket
    local nextStep = Bucket.NextStep(active.bucket, active.stage, node.step)
    if nextStep then
        active.step = nextStep
        return Manager.Rearm(("DungeonRun: step %d"):format(nextStep))
    end

    -- ★★ A12.5b · THE ORDINAL RAN DRY, SO THE STAGE COMPLETES. ⚠ *"A route authored
    -- without a `Next` never advances"* is this row's mutation - running dry IS the
    -- completion, and requiring a `Next` is the defect.
    return Manager.StageDone()
end

-- ★★★ A12.5a as AL-9 corrected it: **THE NEXT STAGE PRESENT IN THE ROUTE**, never `+1`.
-- `+1` across an exposed gap (L3 permits 1, 2, 5) arms a stage that resolves to bucket 0
-- alone, and the run stalls with only recovery armed.
function Manager.StageDone()
    if not active then return nil end
    local Bucket = NS.Bucket
    local nextStage = Bucket.NextStage(active.bucket, active.stage)
    if not nextStage then
        -- A12.8a · the last stage completed.
        Manager.Stop("DungeonRun: route complete - the route is still selected")
        return nil
    end
    active.stage = nextStage
    active.step = Bucket.FirstStep(active.bucket, nextStage)
    return Manager.Rearm(("DungeonRun: stage %d"):format(nextStage))
end

-- ★★ A12.6b · AN ADVANCE DISARMS THE OLD LISTENERS, ARMS THE NEW BUCKET WITH BUCKET 0,
-- WRITES THE NEW LURE, AND SAYS **ONE SHORT LINE**.
--
-- ★ L16 (his): *"the sensor and action patch is the hot one. The stage steps has travel
-- time between."* ⟶ This is a REBUILD BY EVICTION and is deliberately not optimised -
-- there are seconds of walking on either side of it, and correctness is the whole job.
function Manager.Rearm(line)
    disarmAll()
    local ok, why = armCurrent()
    if not ok then
        Manager.Stop("DungeonRun: cannot arm - " .. tostring(why))
        return nil, why
    end
    say(line)
    return true
end

return Manager
