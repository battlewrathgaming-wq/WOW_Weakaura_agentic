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

-- ⚠ FORWARD-DECLARED because `armCurrent` filters the offered list by the node's latch and
-- sits ABOVE these definitions. ★ A Lua local is lexical: without this the filter reads a
-- nil GLOBAL and the list is never filtered - which fails loudly here, but is the same
-- class of silent-nil the `has()` scope note in `routes.lua` records.
local nodeLatched, held

-- ★★★ THE OFFERED LIST, IN ONE PLACE. Arming and re-stating both take it from here,
-- because two bodies for *"what is the sensor watching"* is two answers.
local function offered()
    local Bucket = NS.Bucket
    local list = {}
    for _, node in ipairs(Bucket.Stage(active.bucket, active.stage, active.step)) do
        -- ★ `once` leaves once it has COMPLETED; `every` is maintained (AL-23).
        if node.trigger == "every" or not nodeLatched(node) then
            list[#list + 1] = node
        end
    end
    return list
end

-- ★ BUCKET's own name for the pass-through stage, not a bare `0` here. ⚠ Read lazily
-- because `bucket.lua` may load after this file; a copied literal is the drift this week
-- cost three commits to.
local function Bucket_ALWAYS_get()
    return (NS.Bucket and NS.Bucket.ALWAYS) or 0
end

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

-- ★★★ THE MANAGER EMITS ITS **DERIVED** DECISIONS (AL-21, housed by AL-25).
--
-- AL-21 required the derived answer to be recorded for auditability - that is what let
-- §479 argue an ABSENCE is auditable without the author storing a word: *"the manager
-- emits the derived decision in its own record."* AL-25 gave that record a home.
--
-- ⚠ A `note` is for a DECISION - what this manager CHOSE and why it was open to choose.
-- The noisy path uses `count`, so a 10 Hz poll cannot bury the one line that differed.
--
-- ⚠⚠ IT NEVER REQUIRES THE LOG. `NS.DebugLog` is absent unless a run is being recorded,
-- and the manager must behave identically either way - a run that is watched must not run
-- differently from one that is not.
local function note(kind, text)
    local L = NS.DebugLog
    if L and L.Note then L.Note(kind, text) end
end

local function count(kind)
    local L = NS.DebugLog
    if L and L.Count then L.Count(kind) end
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

    -- ★★★ THE OFFERED LIST IS THE MANAGER'S, AND THE NODE'S LATCH DECIDES WHAT STAYS
    -- IN IT (AL-22/AL-23). Battlewrath: *"the manager will send it to the sensor once, to
    -- be complete, or maintain it in the list."*
    --
    -- ★ THIS IS WHY NOTHING IS STORED ON THE SENSOR. *"Repeat is a function of the manager
    -- to re-state or not"* - so `spent` is a MEANING and it lives here, and the sensor goes
    -- on evaluating whatever list it is handed. The blindness law, one tier down.
    --
    -- ⚠ `once` DROPS ONLY AFTER THE NODE HAS COMPLETED. Dropping it earlier would unarm a
    -- node the reader has not finished with; dropping it never is what made a completed
    -- recovery beacon re-step the run on every walk-through (§484).
    local list = offered()
    local why = unbound(list)
    if why then return nil, why end

    Sensor.Arm(list)
    note("arm", ("stage %s step %s, %d node(s) offered")
        :format(tostring(active.stage), tostring(active.step), #list))

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
                note("tracker.lure", node.address)
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
    note("tracker.park", tostring(reason or "terminal"))
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
        done = {},        -- address -> { [rowIndex] = true }  the LATCHES, first only
        hold = {},        -- "address:i" -> true                 the HELD set (AL-23)
        fired = {},       -- address -> true    `Next` is a latch too: once per arming
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

-- ★★★ THE LEDGER IS A SET OF **PER-ROW LATCHES** (AL-23), not a done-flag.
--
-- > *"It's a latch. So it has to complete before it is released and can be re-armed."*
--
--     LATCHED    the row completed at least once THIS ARMING. `active.done` keeps the
--                FIRST latch and never un-latches - A12.4e's *"never touches the ledger
--                after the first"*.
--     HELD       the row is latched AND its sense has not dropped since. A `once` row
--                stays held until the node re-arms; an `every` row is released the moment
--                its sense drops, and may fire again on the next qualification.
--
-- ★ NODE COMPLETION = **every row latched at least once** - so an `every` row re-firing
-- can never un-complete a node, and the advance cannot be rewritten behind the manager.
function nodeLatched(node)
    local done = active and active.done[node.address]
    if not done then return false end
    local rows = node.rows or {}
    if #rows == 0 then return false end
    for i = 1, #rows do
        if not done[i] then return false end
    end
    return true
end

-- ★ ONE NAME FOR THE FACT, kept because A12.5a speaks of a node COMPLETING while
-- AL-23 speaks of every row being LATCHED. They are the same test, and a second body
-- would let them drift apart.
local function nodeComplete(node) return nodeLatched(node) end

-- ★ IS THIS ROW HELD? A held row does not fire. ⚠ Distinct from LATCHED: latched is a
-- permanent fact about the arming (it drives completion); held is releasable.
function held(node, i)
    return active and active.hold[node.address .. ":" .. i] or false
end

-- ★ A tab's own completion door, handed to the callable so a LATER event can close it.
local function completer(node, i)
    return function()
        if not active then return end
        local done = active.done[node.address]
        if not done then done = {}; active.done[node.address] = done end
        done[i] = true
        -- ★★ THE LATCH CLOSES ON COMPLETION, not on firing. ⚠ That is the whole of the
        -- boss case: a boss row RAN, armed its listener and never completed on a wipe, so
        -- it never latched and never became held - it re-arms on re-entry with nothing to
        -- reset.
        active.hold[node.address .. ":" .. i] = true
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
            -- ★★ A HELD ROW DOES NOT FIRE. ⚠ This is the LoS case in his own words -
            -- *"we don't want to spam LoS every time you run over it"* - and it is the
            -- latch rather than a counter that makes *"every time"* mean every
            -- QUALIFICATION instead of every poll.
            if row.sense == ch.word and not held(node, i) then
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
                    count("dispatch." .. tostring(row.action))
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
        -- ★★★ THE RELEASE (AL-23). An `every` row's latch opens when its SENSE DROPS,
        -- which is what gives the boss its second chance: *"a boss room isn't one chance to
        -- kill it or our system breaks."* ⚠ A `once` row is NOT released here - it stays
        -- spent until the node itself re-arms.
        -- ★ And the row never UN-LATCHES in the ledger; release only clears the HOLD, so
        -- node completion is permanent for the arming.
        -- ⚠⚠ THE RELEASE IS *"THE THING THAT QUALIFIED IT STOPPED HOLDING"*, which is
        -- NOT *"its own word arrived again"*. The first cut tested `row.sense == ch.word`
        -- and a `whenOn` row was therefore never released - it waited for a `whenOn` drop,
        -- which is not a thing. ★ A row qualified by `whenOn` is released by `whenOff`;
        -- one qualified by `whenOff` is released by `whenOn`. **Any transition that is not
        -- the row's own is the end of its qualification.**
        -- ⚠ A `seen` row is swept by this too and it costs nothing: `seen` is emitted once
        -- ever (it is a HISTORY, not a transition), so there is no second qualification to
        -- release it into.
        if node then
            for i, row in ipairs(node.rows or {}) do
                if row.trigger == "every" and row.sense ~= ch.word then
                    active.hold[node.address .. ":" .. i] = nil
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

    -- ★★★ AND A SPENT `once` NODE LEAVES THE OFFERED LIST **ON COMPLETION** - his words,
    -- not at some later re-arm. ⚠ Most completions advance and `Rearm` re-states anyway;
    -- this is for the ones that DO NOT - a step-0 or bucket-0 `once` node whose Next is
    -- nothing follows. Without it such a node stays watched forever, and only the row hold
    -- keeps it quiet - a second mechanism doing the first one's job.
    --
    -- ⚠⚠ AFTER THE LOOP, NEVER INSIDE IT (A12.6a, model row 26): re-stating mid-poll
    -- would change the sensor's input while its result was still being read.
    -- ★ It ARMS ONLY - no `disarmAll` - because a pending CLEU listener on an unrelated
    -- node has nothing to do with this node being spent, and tearing it down would lose a
    -- boss kill the reader is still working on.
    if active and #completed > 0 then
        local spent = false
        for _, node in ipairs(completed) do
            if node.trigger ~= "every" then spent = true end
        end
        if spent then NS.Sensor.Arm(offered()) end
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
    -- ★★★ A BUCKET-0 NODE IS ALWAYS ELIGIBLE, INCLUDING TO COMPLETE (A12.7a).
    --
    -- ⚠⚠ THIS READ `if node.stage ~= active.stage then return nil end` AND THAT MADE THE
    -- ESCAPEMENT UNREACHABLE: a recovery beacon's stage is 0 and the active stage is
    -- positive, so the guard returned before its `Next` was ever looked at. ⟶ **A12.7a's
    -- whole mechanism - *"a stage-0 beacon's `Next = Set(N)` steps the run to N wherever
    -- the reader is"* - could not fire once.** Measured, §484: two walk-throughs, the note
    -- shown twice, the stage never moved.
    --
    -- ★ A12.7a's OWN TEST would have caught it - *"walk into a stage-0 beacon at stage 3
    -- whose Next is Set(1) → the run is at 1"* - and it was never written. The row existed;
    -- the grading did not.
    --
    -- ⚠ A bucket-0 node with NO `Next` still moves nothing: the derivation below sends it
    -- through `lone and stage > 0` (false at stage 0) and then `step <= 0`, so it returns
    -- nil. **Nothing follows stays nothing follows** - only an authored instruction fires.
    if node.stage ~= active.stage and (node.stage or 0) ~= Bucket_ALWAYS_get() then
        return nil
    end

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
    -- ★★★ AN AUTHORED `Next` IS THE INSTRUCTION AND OUTRANKS THE DERIVED DEFAULT
    -- (AL-21, closing RI-49). ★ Read FIRST, because *"unless that is its instruction"* is
    -- exactly what an authored one says: a ZERO node carrying `set` steps the run wherever
    -- the author sent it, which is how §4b's recovery escapement works at all.
    local nt = node.nextType
    if nt == "stage" then
        return Manager.StageDone()
    elseif nt == "set" then
        return Manager.SetStage(node.nextArg)
    elseif nt == "step" then
        -- ⚠ EXPLICIT `step` ON A ZERO NODE IS STILL A NO-OP, deliberately: it has no
        -- position to advance FROM. The author asked the ordinal to move and there is no
        -- ordinal - answered by doing nothing rather than by guessing a step.
        if (node.step or 0) <= 0 then return nil end
        return Manager.StepOn(node)
    end

    if nt then note("next.authored", ("%s -> %s"):format(node.address, nt)) end

    -- ---- NO AUTHORED `Next`: THE DERIVED DEFAULT (§479, taken by AL-21's addendum) ----
    --
    -- ★★ A ZERO NODE'S ABSENT `Next` IS **NOTHING FOLLOWS**, and it is NOT `stage` - which
    -- is what retires A12.2h's *"tray-0 incomplete until authored"*. ⟶ An unauthored
    -- tray-0 beacon is an **UPDATER**; a **RECOVERY** beacon is one given `set N`. Two node
    -- kinds where the retired row saw one error.
    --
    -- ⚠ `lone` is checked with a POSITIVE stage for exactly that reason: a childless
    -- beacon at a real stage is *"an item of one"* and completing it completes the stage,
    -- while a stage-0 beacon is a zero node and completes nothing by itself.
    if node.lone and (node.stage or 0) > 0 then return Manager.StageDone() end

    -- ★★★ A12.5f · AN ITEM **SET** — the `lone` rule generalised from n = 1 to n > 1.
    --
    -- A12.5b already calls a childless beacon *"the limit case - an item of one"*. ⟶ A
    -- beacon whose items are ALL step 0 is the same rule with more of them: **the stage
    -- completes when ALL of them do.**
    --
    -- ⚠⚠ WITHOUT THIS THE STAGE HAS NO COMPLETION PATH AT ALL. `StageDone` had exactly two
    -- ways in - `node.lone`, and the ordinal running dry - and the second is only reached
    -- past `step > 0`. A beacon WITH children that all sit at step 0 reached neither, and
    -- the run armed and sat there (measured, RI-52).
    --
    -- ★ IT IS A DEFAULT NOBODY HAD CHOSEN, not a trap: the ordinal is authorable today and
    -- §480's mint ratchets one onto every placed child, so this state is now RARE. But an
    -- author may still clear every ordinal on purpose, and then this is the rule that makes
    -- the route run. **Correct however it was authored** is why the Analyst put it first.
    --
    -- ⚠ `NextStep(.., 0)` returning nil is how *"this stage holds no position"* is asked -
    -- the same scan `FirstStep` uses, so there is no second definition of what an ordinal is.
    -- ★★ THE LINE §479 EXISTS FOR: an ABSENT `Next` is an OUTCOME, and this is where it
    -- becomes auditable without the author having stored a word.
    note("next.derived", ("%s -> %s"):format(node.address,
        (node.step or 0) > 0 and "step" or (node.lone and "stage" or "nothing follows")))

    if (node.step or 0) <= 0 then
        local Bucket = NS.Bucket
        -- ⚠⚠ NO SCOPE TEST AND NO ORDINAL TEST HERE - **both were written, both were
        -- dead, and one argument kills them both.** If the active stage's siblings are
        -- all latched then that stage has ALREADY advanced, so:
        --   · a stage with an unfinished ordinal has an unlatched sibling → the loop stops
        --   · a bucket-0 node passing through meets the same loop, and if it ever passed,
        --     the stage it would complete is one that completed already
        --
        -- ★ A SAME-POLL RACE WAS HYPOTHESISED AND MEASURED NOT TO EXIST: after the first
        -- `StageDone` the active stage CHANGES, so every later node in that poll bails on
        -- the stage check at the top of this function. ⟶ The sibling loop is the whole
        -- rule; two guards that read as intent changed no outcome, and a guard nothing can
        -- kill is one nothing is testing.
        if true then
            local slot = active.bucket.stages[active.stage] or {}
            for _, sib in ipairs(slot) do
                if not nodeLatched(sib) then return nil end
            end
            return Manager.StageDone()
        end
        return nil
    end
    return Manager.StepOn(node)
end

-- ★ `Set(N)` · the run steps to stage N wherever the reader is (A12.7a - there is no
-- recovery MODE, only a node that says where to go).
--
-- ⚠⚠ N IS NOT TRUSTED TO EXIST. A route TRAVELS by design, so a stage the author named
-- may simply not be in the route the reader loaded - and arming a stage that resolves to
-- bucket 0 alone is the STALL `+1` was corrected for (AL-9). Refused loudly.
function Manager.SetStage(n)
    if not active then return nil end
    local Bucket = NS.Bucket
    if type(n) ~= "number" or not active.bucket.stages[n] then
        Manager.Stop(("DungeonRun: cannot set stage %s - it is not in this route")
            :format(tostring(n)))
        return nil
    end
    -- ★★★ `Set(N)` = **max(current, N)** - IT NEVER REGRESSES (AL-23, his "yes").
    -- ★ The ratchet's law (S6, *"can't regress"*) applied to recovery: a reader who has
    -- reached stage 5 and walks back through a `Set 2` beacon is LOST, not un-progressed.
    -- ⚠ Sending them to 2 would re-arm work they finished and re-fire its actions - the
    -- route would undo itself behind them.
    local to = (active.stage and n < active.stage) and active.stage or n
    if to ~= n then
        say(("DungeonRun: stage %d already passed - holding at %d"):format(n, to))
    end
    active.stage = to
    active.step = Bucket.FirstStep(active.bucket, to)
    return Manager.Rearm(("DungeonRun: stage %d"):format(to))
end

-- ★ THE ORDINAL ADVANCE, split out so the AUTHORED and DERIVED paths share one body.
-- ⚠ Two bodies for one rule is the fault AL-21 named in `bucket.lua` re-implementing
-- `AcceptanceOf`; it is not worth introducing here to save a call.
function Manager.StepOn(node)
    if not active then return nil end
    local Bucket = NS.Bucket
    local nextStep = Bucket.NextStep(active.bucket, active.stage, node.step)
    if nextStep then
        active.step = nextStep
        return Manager.Rearm(("DungeonRun: step %d"):format(nextStep))
    end
    -- ★★ A12.5b · THE ORDINAL RAN DRY, SO THE STAGE COMPLETES. Requiring a `Next` here
    -- is the defect this row's mutation names - a route authored without one would never
    -- advance.
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
