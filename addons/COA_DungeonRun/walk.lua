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
    if child.role == "complete" then
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

-- Every child of every beacon on the route, with its anchor. ⚠ Flat on purpose: the
-- walk tests CHILDREN, and a beacon with none is a stage that cannot be satisfied -
-- which the readout has to be able to say rather than skip silently.
function Walk.Detectors(id)
    local out = {}
    for _, b in ipairs(Routes.StageOrder(id) or {}) do
        local kids = Routes.ChildrenOf(b)
        if #kids == 0 then
            out[#out + 1] = { beacon = b, child = nil }
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

-- ---------------------------------------------------------------------
-- The walk itself
-- ---------------------------------------------------------------------

-- ★★ TRANSIENT HANDLER - installed on start, cleared on stop. Zero persistent
-- OnUpdate is the bench standard and the census counts installs against clears.
local ticker

function Walk.Start(id)
    if not id or not Routes.Get(id) then return false, "no such route" end
    active, index, seen, fired, lastLine = id, 0, {}, {}, nil
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
    active, index, seen, fired, lastLine = nil, nil, nil, nil, nil
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
                if why then
                    -- ★ The ledger is written by Apply, which is the one place the
                    -- model is evaluated. The scan reports; it does not decide.
                    events[#events + 1] = {
                        stage = d.beacon.stage, role = c.role, why = why,
                        from = was, to = now,
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
        local line = ("|cff40c0ffwalk|r stage %s  %s -> %s  (%s%s)")
            :format(tostring(e.stage), tostring(e.from), tostring(e.to),
                    e.why, e.name and (" · " .. e.name) or "")
        -- By-exception: the same line twice in a row is not news.
        if line ~= lastLine then
            lastLine = line
            if NS.Say then NS.Say(line) end
        end
    end
end

return Walk
