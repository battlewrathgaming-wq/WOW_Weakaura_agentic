-- COA_DungeonRun debuglog.lua - THE RECORD OF A NAMED TEST RUN.
--
-- Model: addons/planning/DRIVER_BASIS.md   READ FIRST. It names what governs NOW, in
--        precedence order, and it MOVES when a ruling moves.
-- Ruled by: ARCHITECT_LOG.md AL-25 (Battlewrath, 2026-08-22)
--
-- ---------------------------------------------------------------------------
-- ★★★ WHY THIS EXISTS, and it is an ACCEPTANCE MECHANISM rather than a debug aid.
--
-- AI-11 asked how a CLIENT-ONLY seam is accepted when §7 says the bench proves on
-- synthetic rows. The tracker adapter cannot be proven offline: what it does is call the
-- client. His answer was a method, not a yes:
--
-- > *"An in-game debug log, its own module — **so the project isn't built as a test
-- > suite** — that logs and captures background behaviour as it runs. I test a route, it
-- > captures what differed, when not noisy — **sensor as buckets instead of per second,
-- > but shows its throttle**."*
--
-- ⟶ **A client-only seam is accepted by THE LOG OF A NAMED TEST RUN** showing the adapter
-- did what the manager decided. The smoke proves everything up to the door; this proves
-- the door. A record, not a look.
--
-- ---------------------------------------------------------------------------
-- ★★ BUCKETS, NOT A LINE PER TICK - and the reason is the same one A11.5 gives for the
-- readout: **never diagnostics in flight.** A poll runs at up to 10 Hz; a line each would
-- bury the one thing that differed under ten thousand that did not.
--
-- ⟶ So a KIND is counted, and only what CHANGED is written. The throttle is REPORTED as a
-- rate rather than evidenced by volume - *"shows its throttle"* - because the cadence is a
-- fact about the run and not a thing to reconstruct from timestamps.
--
-- ⚠ NO `OnUpdate`. This module never schedules; it is CALLED. `0 persistent OnUpdate` is
-- the addon's standing property and a logger is the classic way to lose it.
-- ---------------------------------------------------------------------------

local NS = select(2, ...)
NS = NS or _G.COA_DungeonRun_NS or {}
if select(2, ...) == nil then _G.COA_DungeonRun_NS = NS end

local DebugLog = {}
NS.DebugLog = DebugLog

-- ★ CAPS, DECLARED. A log that grows without bound is a second problem, and his own rule
-- for note text applies to a record too: it *"keeps the notes from being documentaries"*.
DebugLog.MAX_LINES = 400
DebugLog.MAX_ERRORS = 20

local run = nil          -- the ONE active run; never a list

-- ---------------------------------------------------------------------
-- THE RUN
-- ---------------------------------------------------------------------

function DebugLog.Running() return run ~= nil end
function DebugLog.Name() return run and run.name or nil end

-- ★★ A NAMED RUN, because AL-25's acceptance shape is *"verified by the log of run ⟨name⟩,
-- by Battlewrath, date"*. An unnamed record cannot be cited, and a record nobody can cite
-- is not acceptance.
-- ⚠⚠ IT RETURNS THE RECORD IT DISPLACED, and mutation is why. `run` is ONE upvalue,
-- so a second `Start` overwrites the first either way - which made *"close the previous
-- run"* correct hygiene that nothing could observe, and a line nothing can grade is a line
-- nobody is testing. ★ Handing the displaced record back makes the closing REAL: a caller
-- who starts a new run gets the old one instead of losing it.
function DebugLog.Start(name, now)
    local displaced = run and DebugLog.Stop(now) or nil
    run = {
        name = tostring(name or "unnamed"),
        started = now,
        lines = {},
        counts = {},        -- kind -> how many times it happened
        errors = {},        -- message -> { n = count, first = the first traceback }
        errorOrder = {},
        dropped = 0,
        polls = 0,
        firstPoll = nil,
        lastPoll = nil,
    }
    DebugLog.ArmErrors()
    return run.name, displaced
end

function DebugLog.Stop(now)
    if not run then return nil end
    DebugLog.DisarmErrors()
    run.stopped = now
    local done = run
    run = nil
    return done
end

-- ---------------------------------------------------------------------
-- WHAT IT RECORDS
-- ---------------------------------------------------------------------

-- ★★★ A KIND IS COUNTED; A LINE IS ONLY WRITTEN FOR WHAT DIFFERED.
--
-- ⚠ `Count` is the bucket - call it on every occurrence, including the noisy ones. `Note`
-- is the line, and it is for a DECISION: the manager's derived Next, an arm, an advance,
-- a tracker write. **AL-21 already required the manager to emit its derived decisions for
-- auditability; this is that record's home.**
function DebugLog.Count(kind)
    if not run or not kind then return end
    run.counts[kind] = (run.counts[kind] or 0) + 1
end

function DebugLog.Note(kind, text)
    if not run then return end
    DebugLog.Count(kind)
    -- ⚠ THE CAP DROPS AND SAYS SO. A silent truncation reads as *"nothing else happened"*,
    -- which is the one thing a record must never imply.
    if #run.lines >= DebugLog.MAX_LINES then
        run.dropped = run.dropped + 1
        return
    end
    run.lines[#run.lines + 1] = { kind = kind, text = tostring(text or "") }
end

-- ★ THE THROTTLE, REPORTED RATHER THAN EVIDENCED. His words: *"sensor as buckets instead
-- of per second, but shows its throttle."* ⟶ Count the polls and keep the span; the rate
-- is arithmetic at read time, and no line is written per poll.
function DebugLog.Poll(now)
    if not run then return end
    run.polls = run.polls + 1
    run.firstPoll = run.firstPoll or now
    run.lastPoll = now
end

-- ---------------------------------------------------------------------
-- LUA ERRORS - captured AS A SAMPLE
-- ---------------------------------------------------------------------

-- ★★★ HIS ADDITION (2026-08-22): *"Also capture the lua error logs as a sample."*
--
-- ⚠⚠ IT CHAINS, IT NEVER SWALLOWS. `geterrorhandler()` is saved and CALLED after we
-- record, so the client's own reporting is untouched - a logger that eats errors is worse
-- than no logger, because the tester stops seeing what the game would have told them.
--
-- ★ A SAMPLE, not a transcript. One entry per DISTINCT message with a count, capped: a
-- single broken OnUpdate can raise thousands of identical errors in a pull, and a record
-- that fills with one repeated line has lost the other nineteen.
--
-- ⚠ `seterrorhandler` / `geterrorhandler` are CONFIRMED on this client by the scraped
-- census (`addons/landing/raw/*__census.lua`) - not recalled, and not assumed from
-- retail.
local previous = nil

function DebugLog.Record(err)
    if not run or not err then return end
    local msg = tostring(err)
    local hit = run.errors[msg]
    if hit then
        hit.n = hit.n + 1
        return
    end
    if #run.errorOrder >= DebugLog.MAX_ERRORS then
        run.dropped = run.dropped + 1
        return
    end
    run.errors[msg] = { n = 1 }
    run.errorOrder[#run.errorOrder + 1] = msg
    DebugLog.Count("error")
end

function DebugLog.ArmErrors()
    if previous or not _G.geterrorhandler or not _G.seterrorhandler then return end
    previous = _G.geterrorhandler()
    _G.seterrorhandler(function(err)
        DebugLog.Record(err)
        -- ⚠ ALWAYS ONWARD. Even if OUR recording threw, the client's handler runs.
        if previous then return previous(err) end
    end)
end

function DebugLog.DisarmErrors()
    -- ★ RESTORED, so the module is not sitting in the client's error path between runs.
    -- ⚠ It restores the handler it SAVED rather than clearing to nil - clearing would take
    -- the client's own handler away with ours.
    if previous and _G.seterrorhandler then _G.seterrorhandler(previous) end
    previous = nil
end

-- ---------------------------------------------------------------------
-- THE UI BASIS - what the interface IS, not what it was declared to be
-- ---------------------------------------------------------------------

-- ★★★ HIS ASK (2026-08-22): *"add in a frame read also, so you can get a basis of how
-- the UI is today. Should be capture once per deployed UI."*
--
-- ★★ IT READS THE BUILT THING, WHICH IS THE WHOLE POINT. `panespec.lua` DECLARES the
-- pane and `check_interface.py` grades the declaration; neither can say what the client
-- actually built. §322's lesson is the standing proof: the pane smoke loaded `ui.lua`
-- AFTER `object.lua`, **20+ registrations silently did nothing**, and every pane assertion
-- before it had passed against dead wiring. A read of the LIVE tree is what that costs to
-- catch.
--
-- ⚠⚠ THIS IS THE BASIS, NOT THE MEASUREMENT. `COA_DevDump/task_geom.lua` already does
-- the deep one - fonts x calibration, stock template rects, the client's own panels walked
-- for norms - on his instruction to *"capture broader than the ask"*. ⟶ Nothing here
-- re-derives any of that. This answers one question: **what does our tree look like right
-- now**, so a later change has something to differ FROM.
--
-- ★ ONCE PER DEPLOYED UI, and the key is the UI's OWN SHAPE rather than a version
-- string. A `## Version` does not move on every deploy, so keying on it would miss exactly
-- the case this exists for - the UI changed and nobody bumped anything. ⟶ The signature
-- is built from the tree itself: if the interface really changed, the key changes.
--
-- ⚠ PURE. It takes frames and returns a table; it never persists and never touches the
-- store, which is what keeps it gradeable offline against fakes. The CALLER decides where
-- a basis lives and whether it has seen this one before.

local function rect(f)
    -- ⚠ EVERY METHOD HERE IS ONE THE SHIPPED ADDON ALREADY CALLS in the client -
    -- `IsShown` x30, `GetName`, `GetObjectType`, `GetChildren`, `GetRect`. The scraped
    -- census lists GLOBALS and cannot confirm a widget method, so the proof that these
    -- exist on this fork is that our own panes use them.
    if not f or type(f.GetRect) ~= "function" then return nil end
    local ok, l, b, w, h = pcall(f.GetRect, f)
    if not ok or not l then return nil end
    -- ★ ROUNDED. A rect carries float noise that differs run to run on the same
    -- unchanged UI, and a basis that never matches itself is a basis nobody can diff.
    return { math.floor(l + 0.5), math.floor(b + 0.5),
             math.floor((w or 0) + 0.5), math.floor((h or 0) + 0.5) }
end

local function walk(f, depth, out, sig)
    if not f or depth > 6 then return end
    local name = (type(f.GetName) == "function") and f:GetName() or nil
    local kind = (type(f.GetObjectType) == "function") and f:GetObjectType() or "?"
    local shown = (type(f.IsShown) == "function") and (f:IsShown() and true or false) or nil
    local r = rect(f)
    out[#out + 1] = { name = name, kind = kind, shown = shown, rect = r, depth = depth }
    -- ★ THE SIGNATURE TAKES SHAPE AND SIZE, NOT POSITION. A pane the author dragged is
    -- the same UI; a pane that grew a control is not.
    sig[#sig + 1] = ("%s/%s/%d"):format(tostring(name or "?"), kind,
                                        r and (r[3] * 1000 + r[4]) or 0)
    if type(f.GetChildren) == "function" then
        local kids = { pcall(f.GetChildren, f) }
        if kids[1] then
            for i = 2, #kids do walk(kids[i], depth + 1, out, sig) end
        end
    end
end

-- ★ RETURNS the basis and its KEY. ⚠ `seen` is the caller's record of keys already
-- captured; passing one makes this a no-op when the UI has not changed, which is *"once
-- per deployed UI"* without anyone tracking deploys.
function DebugLog.ReadFrames(roots, seen)
    local out, sig = {}, {}
    for _, f in ipairs(roots or {}) do walk(f, 0, out, sig) end

    -- ⚠ A CHEAP, ORDER-DEPENDENT DIGEST. It is not cryptographic and does not need to
    -- be: it answers *"is this the same tree as last time"*, and the tree is walked in a
    -- fixed order, so order-dependence is a property rather than a flaw.
    local h = 5381
    local joined = table.concat(sig, "|")
    for i = 1, #joined do
        h = (h * 33 + joined:byte(i)) % 4294967296
    end
    local key = ("%d:%d"):format(#out, h)

    if seen and seen[key] then return nil, key end
    return { key = key, frames = out, n = #out }, key
end

-- ---------------------------------------------------------------------
-- THE REPORT - what a named run is cited BY
-- ---------------------------------------------------------------------

-- ⚠ IT RETURNS DATA, NEVER PRINTS. Who shows it - chat, a pane, a dump - is the caller's,
-- and the fence that keeps this module gradeable offline is that it touches no frame.
function DebugLog.Report(of)
    local r = of or run
    if not r then return nil end
    local secs = (r.lastPoll and r.firstPoll) and (r.lastPoll - r.firstPoll) or 0
    return {
        name = r.name,
        polls = r.polls,
        -- ★ THE THROTTLE AS A RATE. 0 when a run polled once or never - reported as 0
        -- rather than as nil, because a missing number reads as *"not measured"* and this
        -- one IS measured.
        rate = (secs > 0) and (r.polls / secs) or 0,
        span = secs,
        counts = r.counts,
        lines = r.lines,
        errors = r.errorOrder,
        errorCounts = r.errors,
        dropped = r.dropped,
    }
end

return DebugLog
