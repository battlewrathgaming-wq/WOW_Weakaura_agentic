-- COA_DungeonRun walk.lua - THE TEST DRIVER (§85).
--
-- ---------------------------------------------------------------------------
-- ★★★ WHY IT EXISTS, and it is not convenience. Battlewrath, 2026-08-15, setting
-- the order of work:
--
--     "The driver and the audit and export come last. First is the data structure
--      to express what we need. Then how that carries and gets read is a separate
--      question and better scoped. So now is the children and their behaviors. And
--      a light weight testing driver for proof / experimenting."
--
-- ★★★ IT IS THE CONTROL FOR A FORMAT THAT DOES NOT EXIST YET. This reads the
-- AUTHORED data directly - `Routes`, in the editor, with full access. The real
-- driver will later read a flattened list produced by the auditor. When the two
-- disagree, THE FLATTEN LOST SOMETHING - and that is a test you cannot build
-- afterwards without it being shaped by the format it is supposed to check.
--
-- ★★ §74 made the same move one level down: a prototype consumer, so the
-- behaviours declare themselves. This is that again, with the A/B as the payoff.
--
-- ⚠ WHAT IT DELIBERATELY IS NOT. His: *"Can drop a lot of the catchments, tracking
-- and recovery, and is more about state read out."* So: no ledger, no recovery, no
-- HUD, no super-tracker. It walks a route and SAYS WHAT IT SEES. Everything it
-- leaves out is a thing the real driver owns, and leaving it out is what keeps this
-- from quietly becoming that driver.
--
-- ★ RUNS IN EDITING, NEVER FROM THE DRIVER - his line, and it is the boundary. A
-- consumer that needs the editor loaded is a test instrument by construction; it
-- cannot be shipped as the thing it is testing.
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local Walk = {}
NS.Walk = Walk

local Routes, Driver

local active                 -- the route id being walked, nil when stopped
local index                  -- where the walk thinks we are
local seen                   -- [stage] = true. §84's ledger, in miniature
local fired                  -- [child] = true, so a detector reports once per visit
local lastLine               -- by-exception: only say something when it CHANGES

-- ★★ ONE DEFAULT REACH, and it is stated rather than scattered. A child authored
-- with no radius is not an error - §84's create-then-edit means it exists before its
-- values do - so the walk needs a number to test against and says which one it used.
local DEF_RADIUS, DEF_UP, DEF_DOWN = 8, 6, 2

function Walk.Init()
    Routes, Driver = NS.Routes, NS.Driver
end

-- ★ PURE, and that is what makes the whole instrument testable without a player.
-- Everything below it either feeds this or reports what it said.
function Walk.Hits(child, px, py, pz)
    if not child or not Driver then return false end
    local wx, wy = Routes.WorldOf(child)
    if not wx then return false end
    return Driver.Reached(px, py, pz, wx, wy, child.z,
                          child.radius or DEF_RADIUS,
                          child.bandUp or DEF_UP,
                          child.bandDown or DEF_DOWN)
end

-- ★★★ THE ACCEPTANCE RULE, and it is the ONE place the model is evaluated:
--
--     complete   index = max(index, outcome)      the ratchet, §79 untouched
--     set        index = N                        no max, and only `if unseen`
--
-- ⚠ Returns the NEW index and WHY, never just the number. A driver that moves the
-- index without saying which child moved it is exactly the thing this is built to
-- catch, and "it advanced" is the least useful possible readout.
function Walk.Apply(b, child)
    if not b or not child then return index, nil end
    -- ★★ §94: `child == b` IS THE ANCHOR ACTING AS ITS OWN SATISFIER, which is §83's
    -- composing rule written as code rather than as a comment. A bare beacon has no
    -- `role` field and never will - the role is what a CHILD carries.
    if child.role == "complete" or child == b then
        local to = Routes.Outcome(b) or ((b.stage or 0) + 1)
        if to > (index or 0) then
            index = to
            -- ⚠ THE LEDGER RECORDS THE STAGE THAT WAS COMPLETED, not the index we
            -- came from. The first cut marked `was`, which is a different number
            -- whenever an outcome jumps - and it made `if unseen` consult a stage
            -- nobody had been to.
            seen[b.stage] = true
            return index, "complete"
        end
        -- ★ The ratchet holding is INFORMATION, not silence: re-crossing a satisfied
        -- stage is the ordinary recovery path, and seeing it reported is how you
        -- know the ratchet is why nothing happened.
        return index, "ratcheted"
    end
    if child.role == "set" then
        if Routes.ChildIfUnseen(child) and seen[child.setStage] then
            return index, "unseen-blocked"
        end
        if child.setStage then
            index = child.setStage
            -- ★ A set marks its TARGET seen. That is what closes the loop with the
            -- clause above: the second pass through the same location finds the
            -- stage already in the ledger and does nothing.
            seen[child.setStage] = true
            return index, "set"
        end
    end
    return index, nil
end

-- ---------------------------------------------------------------------
-- ★★★ §91: THE ACTION AXIS - and the first thing this instrument PUSHES
-- ---------------------------------------------------------------------
--
-- Everything else the walk does is a read. Pointing the super tracker changes client
-- state, and `task_api.lua` holds a ★★★ CULTURE ruling that a probe is READ-ONLY -
-- so this is a line being crossed, and it is crossed deliberately rather than
-- quietly.
--
-- ★★ THE DISTINCTION THAT MAKES IT ALLOWED: that ruling is about a DIAGNOSTIC
-- pushing junk into someone's live client while they are not looking. This is a
-- navigation aid the author asked for by typing `/dr walk`, and leading them along
-- the route IS its function. A tool that refuses to do the thing it was invoked for
-- is not being polite.
--
-- ⚠ AND IT IS THE STOCK FORM, NOT THE OBVIOUS ONE. `SuperTrackerUtil.
-- SetSuperTrackedPosition(x, y, z, mapID)` - because AC-17 records that the
-- `C_SuperTrack.*` form LOOKS right, skips the priority ladder, and is silently
-- overwritten.
--
-- ★ `lastTarget` is exposed so the decision is assertable without the client: the
-- smoke checks WHERE it pointed, not whether the API existed.
local lastTarget

function Walk.LastTarget() return lastTarget end

function Walk.Act(b, child)
    if not child or child.action ~= "supertrack" then return nil end
    local target = Routes.GoToTarget(b, child)
    -- ⚠ A dangling target is a DEFINED state (§86): the hop stops redirecting rather
    -- than failing. Reported so the author can see the link they broke.
    if not target then
        return child.goTo and "target-gone" or "no-target"
    end
    local wx, wy = Routes.WorldOf(target)
    if not wx then return "target-unplaceable" end
    lastTarget = target
    if SuperTrackerUtil and SuperTrackerUtil.SetSuperTrackedPosition then
        pcall(SuperTrackerUtil.SetSuperTrackedPosition, wx, wy, target.z, target.mapID)
    end
    return "supertrack"
end

-- ★★★ §93: AN ADVANCE ASKS THE NEXT STAGE WHERE TO GO, and the answer may be
-- nothing. One call at every index change, so there is no branch for a stage that
-- gives no direction - that is an ANSWER rather than an absence.
--
-- ⚠ THE NEXT STAGE IS THE LOWEST AT OR ABOVE THE INDEX, not index+1. Stages are
-- LABELS, not array positions - 4.1 is ordinary and deleting leaves gaps - so
-- arithmetic on the number would skip a stage the author deliberately inserted.
function Walk.OnRamp(id, at)
    for _, b in ipairs(Routes.StageOrder(id or active) or {}) do
        if (b.stage or 0) >= (at or index or 0) then
            return Routes.OnRampOf(b), b
        end
    end
end

-- ★ Points the tracker at whatever the next stage says its way in is. Returns what
-- it did so the walk can SAY it rather than moving the arrow silently.
-- ★ `at` is optional and exists FOR THE TEST, which is a legitimate reason: the
-- live caller always means "wherever the index now is", and a test that cannot say
-- WHICH index it is asking about can only ever assert the first stage.
function Walk.PointAtOnRamp(id, at)
    local ramp = Walk.OnRamp(id, at)
    if not ramp then return "route-finished" end
    local wx, wy = Routes.WorldOf(ramp)
    if not wx then return "on-ramp-unplaceable" end
    lastTarget = ramp
    if SuperTrackerUtil and SuperTrackerUtil.SetSuperTrackedPosition then
        pcall(SuperTrackerUtil.SetSuperTrackedPosition, wx, wy, ramp.z, ramp.mapID)
    end
    return "on-ramp"
end

-- Every child of every beacon on the route, with its anchor. ⚠ Flat on purpose: the
-- walk tests CHILDREN, and a beacon with none is a stage that cannot be satisfied -
-- which the readout has to be able to say rather than skip silently.
function Walk.Detectors(id)
    local out = {}
    for _, b in ipairs(Routes.StageOrder(id) or {}) do
        local kids = Routes.ChildrenOf(b)
        if #kids == 0 then
            -- ★★ §94: THE ANCHOR IS ITS OWN DETECTOR. It was listed with `child = nil`
            -- and the scan skipped it, so a bare beacon never fired - §83's "or the
            -- anchor when it has none" existed as prose and not as behaviour.
            out[#out + 1] = { beacon = b, child = b }
        else
            for _, c in ipairs(kids) do
                out[#out + 1] = { beacon = b, child = c }
            end
        end
    end
    return out
end

-- ★★ THE READOUT, and it is the whole product. One line, built from what the walk
-- can actually see - not a claim about what will happen live.
function Walk.State(id)
    id = id or active
    if not id then return "walk: not running" end
    local total, withAccept = 0, 0
    for _, b in ipairs(Routes.StageOrder(id) or {}) do
        total = total + 1
        if Routes.AcceptanceOf(b) then withAccept = withAccept + 1 end
    end
    return ("walk: stage %s  ·  %d/%d stages have acceptance  ·  %d seen")
        :format(tostring(index or 0), withAccept, total, Walk.SeenCount())
end

function Walk.SeenCount()
    local n = 0
    for _ in pairs(seen or {}) do n = n + 1 end
    return n
end

-- ⚠ THE STAGES THE DRIVER COULD NEVER ADVANCE PAST. This is the auditor's first job
-- arriving early: a beacon with no stage-complete child is a legitimate authoring
-- state (purely informational) and an unrunnable STAGE. Reported, never refused -
-- refusing would be grading the author's work.
-- ⚠ §94: A BARE BEACON IS NOT UNRUNNABLE - it ratchets when found. What this reports
-- is a beacon that HAS children and none carrying `stage complete`: the author
-- offloaded the job and did not finish it, which is the case worth saying.
function Walk.Unrunnable(id)
    local out = {}
    for _, b in ipairs(Routes.StageOrder(id or active) or {}) do
        if not Routes.AcceptanceOf(b) then out[#out + 1] = b.stage end
    end
    return out
end

-- ★★ §90: STAGES WITH MORE THAN ONE ACCEPTANCE. Legal - any of them satisfies - and
-- worth saying, because a second stage-complete is usually a leftover rather than a
-- choice. ⚠ Reported, never refused: the count is the whole intervention, exactly as
-- §81's match count is for a duplicate stage.
function Walk.MultipleAcceptance(id)
    local out = {}
    for _, b in ipairs(Routes.StageOrder(id or active) or {}) do
        local n = Routes.RoleMatches(b, "complete")
        if n > 1 then out[#out + 1] = { stage = b.stage, count = n } end
    end
    return out
end

-- ★ Where the walk currently is, and what it is waiting for. The second half is the
-- part a route author actually needs: "stage 4" says nothing about why you are stuck.
function Walk.Waiting(id)
    for _, b in ipairs(Routes.StageOrder(id or active) or {}) do
        if (b.stage or 0) >= (index or 0) then
            local c = Routes.AcceptanceOf(b)
            if c then
                return b, c, (c.name ~= "" and c.name) or "unnamed child"
            end
            return b, nil, "no acceptance on this stage"
        end
    end
end

-- ★★★ §95: ONE START-AND-REPORT, because there are now TWO ways in - the slash
-- surface and the promoter's play. Two copies of the same three lines is §63's fault
-- exactly: two things that must agree, with nothing to notice when they stop.
--
-- ★ It RETURNS the lines rather than printing them, so the caller decides where they
-- go and the whole thing stays testable without a chat frame.
function Walk.StartLines(id)
    local out = {}
    local ok, err = Walk.Start(id)
    if not ok then return nil, err end
    out[#out + 1] = Walk.State(id)
    -- ⚠ Both of these are said ONCE, at the start, because that is when the author
    -- can still act on them - and never again, because repeating would be nagging
    -- about a decision they may have made deliberately.
    local bad = Walk.Unrunnable(id)
    if #bad > 0 then
        out[#out + 1] = ("|cffff8080no acceptance on stage(s):|r %s")
            :format(table.concat(bad, ", "))
    end
    for _, m in ipairs(Walk.MultipleAcceptance(id)) do
        out[#out + 1] = ("|cffffd100stage %s has %d stage-complete children|r - "
                         .. "any of them satisfies"):format(tostring(m.stage), m.count)
    end
    return out
end

-- ---------------------------------------------------------------------
-- The walk itself
-- ---------------------------------------------------------------------

-- ★★ TRANSIENT HANDLER - installed on start, cleared on stop. Zero persistent
-- OnUpdate is the bench standard and the census counts installs against clears.
local ticker

function Walk.Start(id)
    if not id or not Routes.Get(id) then return false, "no such route" end
    active, index, seen, fired, lastLine, lastTarget = id, 0, {}, {}, nil, nil
    if not ticker then
        ticker = CreateFrame("Frame", "COA_DungeonRunWalk", UIParent)
        ticker:Hide()
    end
    ticker:SetScript("OnUpdate", function() Walk.Tick() end)
    ticker:Show()
    return true
end

function Walk.Stop()
    if ticker then
        ticker:SetScript("OnUpdate", nil)
        ticker:Hide()
    end
    active, index, seen, fired, lastLine, lastTarget = nil, nil, nil, nil, nil, nil
    return true
end

function Walk.IsRunning() return active and true or false end
function Walk.Index() return index end
function Walk.Seen() return seen end

-- ★★★ ONE SCAN, AND IT REPORTS BY EXCEPTION. `fired` makes a detector speak ONCE
-- per visit rather than every frame it is inside a radius - which is the difference
-- between an instrument and a firehose, and it is the same reason `lastLine` exists.
--
-- ⚠ `fired` is cleared when you LEAVE the radius, not when the stage advances. A
-- detector you walk out of and back into is a second visit and says so; one you sit
-- inside is one event. Anything else either spams or goes quiet at the wrong moment.
function Walk.Scan(px, py, pz)
    if not active then return end
    local events = {}
    for _, d in ipairs(Walk.Detectors(active)) do
        local c = d.child
        if c then
            local inside = Walk.Hits(c, px, py, pz)
            if inside and not fired[c] then
                fired[c] = true
                local was = index
                local now, why = Walk.Apply(d.beacon, c)
                -- ★ The two axes fire independently, which is what lets ONE child
                -- both complete the stage and move the tracker.
                local acted = Walk.Act(d.beacon, c)
                -- ★★ THE ADVANCE ITSELF DIRECTS, and it runs AFTER the child's own
                -- action so an explicit `goTo` on the satisfying child wins. The
                -- author pointing somewhere specific beats the default.
                local ramped
                if (why == "complete" or why == "set") and not acted then
                    ramped = Walk.PointAtOnRamp(active)
                end
                if why or acted or ramped then
                    -- ★ The ledger is written by Apply, which is the one place the
                    -- model is evaluated. The scan reports; it does not decide.
                    events[#events + 1] = {
                        stage = d.beacon.stage, role = c.role, why = why,
                        from = was, to = now, acted = acted or ramped,
                        name = (c.name ~= "" and c.name) or nil,
                    }
                end
            elseif not inside then
                fired[c] = nil
            end
        end
    end
    return events
end

function Walk.Tick()
    if not active then return end
    local px, py, pz = GetCurrentPlayerPosition()
    if not px then return end
    local events = Walk.Scan(px, py, pz)
    for _, e in ipairs(events or {}) do
        local line = ("|cff40c0ffwalk|r stage %s  %s -> %s  (%s%s%s)")
            :format(tostring(e.stage), tostring(e.from), tostring(e.to),
                    e.why or "-", e.acted and (" · " .. e.acted) or "",
                    e.name and (" · " .. e.name) or "")
        -- By-exception: the same line twice in a row is not news.
        if line ~= lastLine then
            lastLine = line
            if NS.Say then NS.Say(line) end
        end
    end
end

return Walk
