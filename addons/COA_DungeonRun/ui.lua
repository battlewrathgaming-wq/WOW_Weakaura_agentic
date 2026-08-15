-- COA_DungeonRun ui.lua - THE CONTROL REGISTRY, THE VERB, AND THE PLAN STEPPER (§97).
--
-- ---------------------------------------------------------------------------
-- ★★★ WHY A REGISTRY AND NOT GLOBAL FRAME NAMES. `/click` is the only thing that
-- needs a global, and it is the weakest driver available: it can press a button and
-- cannot touch a dropdown. Battlewrath: *"I'm fine with whatever is most
-- repeatable."*
--
-- A registry gives what naming cannot:
--
--   no `_G` growth      32 frames would have landed in the global table
--   OUR names           `object.role`, not `COA_DungeonRunObjectRole` - stable
--                       regardless of what any frame is called, readable in a diff
--   selects work        an entry is { frame, set, read }, so a dropdown is
--                       addressable exactly like a button
--   the gap is VISIBLE  a control that was never registered is absent from
--                       `/dr ui list`, rather than discovered when a test line
--                       silently does nothing
--
-- ★★★ AND EVERY DESIGN CHOICE BELOW IS MEASURED, NOT ASSUMED (2026-08-15, live):
--
--   `Click()` dispatches OnClick SYNCHRONOUSLY   -> a line can press and assert
--   `Click()` FIRES ON A HIDDEN FRAME            -> ⚠ NO "open the pane first"
--                                                   ordering. The commonest
--                                                   fragility in UI scripting does
--                                                   not exist here
--   `GetChecked()` returns 1 / nil               -> truthiness, never `== true`
--   the chat box holds 255 letters               -> `FrameXML/ChatFrame.xml:21`
--   ONE screenshot survives per SECOND           -> the name has one-second
--                                                   resolution, so a faster shot
--                                                   yields NO extra file, silently
--
-- ⚠ THE LAST ONE IS WHY THE STEPPER SPACES SHOTS AND THE REPO COUNTS THEM. Four
-- requests produced three files and the client reported nothing wrong at any point.
-- Spacing is a hope; counting is the check.
--
-- ★★ AND WHAT THIS SIDE CANNOT DO, because it is a tagged fact: ADDON LUA CANNOT
-- READ FILES FROM DISK. So the client can never verify a screenshot landed - it
-- records *requested a shot at T labelled L* and the join happens repo-side. That is
-- not a compromise, it is what each side can actually observe.
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local UI = {}
NS.UI = UI

local Store

-- key -> { frame, set, read, kind }
local controls = {}
local order = {}          -- registration order, so `list` reads stably
local misses = {}         -- keys whose frame did not exist yet

-- ★★★ EXACTLY ONE GLOBAL, AND IT IS A DELIBERATE EXCEPTION TO THIS FILE'S OWN RULE.
-- The registry exists so 32 frames do NOT land in `_G`. But `COA_DevDump` is a
-- separate addon and our widgets are deliberately unnamed, so without a bridge it
-- cannot reach a single one of them - and the geometry probe's whole job is reading
-- their real rects back to check the offline model.
--
-- ⚠ INTROSPECTION ONLY. `Keys` and `Get` go over; `Click` and `Set` do NOT. A probe
-- needs to LOOK at the pane, and a global that can also drive it is a much larger
-- thing to have left lying in `_G` than the one we were avoiding.
function UI.Init()
    Store = NS.Store
    _G.COA_DungeonRunUIProbe = { Keys = UI.Keys, Get = UI.Get, Misses = UI.Misses }
end

-- ★ A control declares its own verbs. `set` and `read` are optional: a plain button
-- has neither, a tick has both, a dropdown has `set` and usually `read`.
-- ⚠⚠ A MISSED REGISTRATION NAMES ITSELF (§97.1). The first live `/dr ui list`
-- reported 15 controls where 16 were written - `promoter.create` was registered FORTY
-- LINES BEFORE the button it names is created, so it received nil and returned nil.
--
-- ★★ The registry did what it was built for: the gap was VISIBLE rather than silent.
-- But visible as a COUNT is not the same as visible as a NAME - finding which one
-- meant reading the source, which is the work the registry exists to remove. So a
-- miss is recorded and `list` reports it.
--
-- ★ Registration order is a real hazard here and not a one-off: a pane builds its
-- widgets down the file, and any registration block sits at ONE point in that order.
function UI.Register(key, frame, opts)
    if not key then return nil end
    if not frame then
        misses[#misses + 1] = key
        return nil
    end
    opts = opts or {}
    if not controls[key] then order[#order + 1] = key end
    controls[key] = { frame = frame, set = opts.set, read = opts.read,
                      kind = opts.kind or "button" }
    return key
end

function UI.Get(key) return controls[key] end

-- ★ The raw keys, in registration order. `List` formats for a human; a tool needs
-- the keys themselves, and having it parse the formatted line back would be a
-- second format nobody declared.
function UI.Keys()
    local out = {}
    for i, k in ipairs(order) do out[i] = k end
    return out
end

function UI.Misses() return misses end

function UI.List()
    local out = {}
    for _, k in ipairs(order) do
        local c = controls[k]
        out[#out + 1] = ("%s (%s%s%s)"):format(k, c.kind,
            c.set and " set" or "", c.read and " read" or "")
    end
    for _, k in ipairs(misses) do
        out[#out + 1] = ("|cffff8080%s - NOT REGISTERED (frame did not exist)|r"):format(k)
    end
    return out
end

-- ⚠ NO SHOWN CHECK, and that is deliberate rather than lax: Click was MEASURED to
-- fire on a hidden frame, so requiring the pane open would add an ordering
-- constraint the client does not have.
function UI.Click(key)
    local c = controls[key]
    if not c then return nil, "no such control: " .. tostring(key) end
    if not c.frame.Click then return nil, "not clickable: " .. key end
    c.frame:Click()
    return true
end

function UI.Set(key, value)
    local c = controls[key]
    if not c then return nil, "no such control: " .. tostring(key) end
    if not c.set then return nil, "not settable: " .. key end
    c.set(value)
    return true
end

-- ★ Returns the value AND whether the control could be read at all, so "nil because
-- it is empty" and "nil because nothing can read it" are different answers.
function UI.Read(key)
    local c = controls[key]
    if not c then return nil, "no such control: " .. tostring(key) end
    if not c.read then return nil, "not readable: " .. key end
    return c.read(), nil
end

-- ---------------------------------------------------------------------
-- ★★★ THE PLAN - a table of steps, each recording what it EXPECTED and what it
-- ACTUALLY GOT, both, always.
-- ---------------------------------------------------------------------
--
-- ⚠ BOTH, EVEN WHEN THEY MATCH. His: a step that only records "passed" is a step
-- you cannot re-examine when the run as a whole turns out to be wrong - and the run
-- being wrong for a reason no single step noticed is the case this exists for.
--
-- ★ Steps are seeded by TYPED LINES, several short ones rather than one long one,
-- because the chat box holds 255 letters and that is sourced rather than recalled.

local plan = {}
local running, cursor, lastShot = false, 0, 0
local runId

-- ★★ SPACING IS THE ONLY THING THIS SIDE CAN DO about the one-per-second floor. It
-- cannot see the file, so it cannot wait for the file - it waits for the CLOCK and
-- lets the repo count what actually landed.
local SHOT_GAP = 1.05

function UI.PlanClear()
    plan, running, cursor, runId = {}, false, 0, nil
    return true
end

function UI.PlanAdd(verb, key, value, expect, label)
    plan[#plan + 1] = {
        verb = verb, key = key, value = value,
        expect = expect, label = label,
        -- ⚠ `actual` and `ok` stay nil until the step RUNS. A pre-filled result is
        -- indistinguishable from a real one once it is in the record.
    }
    return #plan
end

function UI.PlanSize() return #plan end
function UI.Plan() return plan end
function UI.RunId() return runId end

-- ★★ ONE STEP, AND IT ALWAYS RECORDS. Even a step that could not run at all writes
-- what it tried and why it could not - a gap in the record is the one thing that
-- cannot be read back.
function UI.Step(i)
    local s = plan[i]
    if not s then return nil end
    local ok, actual, err

    if s.verb == "click" then
        ok, err = UI.Click(s.key)
        actual = ok and "clicked" or err
    elseif s.verb == "set" then
        ok, err = UI.Set(s.key, s.value)
        actual = ok and tostring(s.value) or err
    elseif s.verb == "read" then
        actual, err = UI.Read(s.key)
        ok = err == nil
        if not ok then actual = err end
    elseif s.verb == "shot" then
        -- ⚠ The client cannot confirm this landed. It records the REQUEST and the
        -- label; the repo counts files against labels.
        --
        -- ★★★ §97.2: AND IT RECORDS THE CLOCK, so the join is KEYED rather than
        -- POSITIONAL. The first round-trip matched labels to files by COUNTING - two
        -- labels, two files - which works until a shot is dropped, and then every
        -- label after it silently points at the wrong image. The one-per-second
        -- finding says dropping is exactly what happens when spacing fails.
        --
        -- ⚠ IT IS THE REQUEST TIME, NOT THE CAPTURE TIME. The client names the file
        -- when the frame ends, so a request landing on a second boundary can produce
        -- a name one second later. The repo matches within a ±1s window and says
        -- which it found - a tolerance stated up front rather than a mystery when a
        -- name does not match.
        s.shotAt = date and date("%m%d%y_%H%M%S") or nil
        if Screenshot then Screenshot() end
        lastShot = GetTime and GetTime() or 0
        ok, actual = true, "requested"
    elseif s.verb == "wait" then
        ok, actual = true, "waited"
    else
        ok, actual = false, "unknown verb: " .. tostring(s.verb)
    end

    s.actual = actual
    -- ★ An expectation is OPTIONAL. A step with none is still recorded, and `ok`
    -- then means only "the verb ran" rather than "the result was right".
    if s.expect ~= nil then
        s.ok = (tostring(actual) == tostring(s.expect))
    else
        s.ok = ok and true or false
    end
    return s
end

-- ★★ THE STEPPER IS A TRANSIENT HANDLER - installed on run, cleared at the end.
-- Zero persistent OnUpdate is the bench standard and the census counts installs
-- against clears.
local ticker

function UI.RunPlan()
    if #plan == 0 then return nil, "the plan is empty" end
    running, cursor = true, 0
    runId = (date and date("%Y%m%d_%H%M%S")) or tostring(GetTime and GetTime() or 0)
    for _, s in ipairs(plan) do s.actual, s.ok = nil, nil end

    if not ticker then
        ticker = CreateFrame("Frame", "COA_DungeonRunUIStepper", UIParent)
        ticker:Hide()
    end
    ticker:SetScript("OnUpdate", function() UI.Tick() end)
    ticker:Show()
    return true
end

function UI.Tick()
    if not running then return end
    local nxt = plan[cursor + 1]
    if not nxt then return UI.Finish() end

    -- ⚠ A SHOT WAITS FOR THE CLOCK, and nothing else does. Every other verb runs
    -- immediately, because Click was measured synchronous - so a plan is only as
    -- slow as the shots in it.
    if nxt.verb == "shot" or nxt.verb == "wait" then
        local now = GetTime and GetTime() or 0
        if now - lastShot < SHOT_GAP then return end
    end

    cursor = cursor + 1
    UI.Step(cursor)
end

function UI.Finish()
    running = false
    if ticker then
        ticker:SetScript("OnUpdate", nil)
        ticker:Hide()
    end
    -- ★ The record goes through Store, because DR-20 says exactly one module
    -- touches the saved-variables global and this is not it.
    if Store and Store.SetUIRun then Store.SetUIRun(runId, plan) end
    return UI.Summary()
end

function UI.Running() return running end

-- ★★ BY EXCEPTION. Silence when every step matched; a named list when they did not.
-- ⚠ And it reports the SHOT COUNT as a claim, not a fact - the repo is what can
-- count files, and saying so here stops the number reading as verified.
function UI.Summary()
    local bad, shots = {}, 0
    for i, s in ipairs(plan) do
        if s.verb == "shot" then shots = shots + 1 end
        if s.ok == false then
            bad[#bad + 1] = ("%d %s %s -> %s"):format(
                i, s.verb, tostring(s.key or s.label or ""), tostring(s.actual))
        end
    end
    return {
        runId = runId, steps = #plan, failed = bad, shotsRequested = shots,
    }
end

return UI
