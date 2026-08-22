-- Model: addons/planning/DRIVER_BASIS.md · ruled by ARCHITECT_LOG.md AL-25
--
-- ★★★ THE DEBUG LOG is an ACCEPTANCE MECHANISM, so its own grading matters more than most:
-- it is what a client-only seam is accepted BY. A record that quietly drops, double-counts
-- or swallows an error would make every acceptance built on it worthless.

local here = debug.getinfo(1, "S").source:match("@(.*[/\\])") or ""
_G.COA_DungeonRun_NS = {}
local Log = assert(dofile(here .. "../../COA_DungeonRun/debuglog.lua"),
                   "debuglog.lua did not return its table")

-- =====================================================================
-- ★★ A NAMED RUN — AL-25's acceptance shape is *"verified by the log of run ⟨name⟩"*
-- =====================================================================
assert(not Log.Running(), "nothing is running before a start")
Log.Start("wrong-way pass", 100)
assert(Log.Running() and Log.Name() == "wrong-way pass",
       "AN UNNAMED RECORD CANNOT BE CITED, and a record nobody can cite is not acceptance")

-- =====================================================================
-- ★★★ BUCKETS, NOT A LINE PER TICK — *"sensor as buckets instead of per second"*
-- =====================================================================
for i = 1, 500 do Log.Count("poll.evaluated") end
Log.Note("manager.arm", "stage 1 step 1")
Log.Note("manager.next", "derived: step")

local rep = Log.Report()
assert(rep.counts["poll.evaluated"] == 500,
       "THE BUCKET LOST COUNTS: a kind is COUNTED on every occurrence - that is what makes "
       .. "it safe to call from the noisy path")
assert(#rep.lines == 2,
       "A LINE WAS WRITTEN FOR A COUNTED EVENT: 500 evaluations produced 2 lines, because "
       .. "a line is for a DECISION and a count is for everything else. A line per poll at "
       .. "10 Hz buries the one thing that differed under ten thousand that did not. got "
       .. tostring(#rep.lines))

-- =====================================================================
-- ★★ THE THROTTLE IS REPORTED, NOT EVIDENCED — *"but shows its throttle"*
-- =====================================================================
Log.Poll(100); Log.Poll(101); Log.Poll(102); Log.Poll(103); Log.Poll(104)
rep = Log.Report()
assert(rep.polls == 5 and rep.span == 4,
       "the poll span must be the first-to-last reach, got " .. tostring(rep.span))
assert(math.abs(rep.rate - 1.25) < 0.001,
       "THE THROTTLE WAS NOT REPORTED AS A RATE: the cadence is a FACT about the run, not "
       .. "something to reconstruct from timestamps nobody wrote. got " .. tostring(rep.rate))
assert(#rep.lines == 2,
       "POLLING WROTE A LINE: `Poll` counts and spans; it must never write, or the "
       .. "bucket discipline is lost at the one call site that runs at 10 Hz")

-- =====================================================================
-- ★★★ LUA ERRORS — a SAMPLE, and it must NEVER SWALLOW (his ask, 2026-08-22)
-- =====================================================================
local passedOn = {}
_G.geterrorhandler = function() return function(e) passedOn[#passedOn + 1] = e end end
_G.seterrorhandler = function(fn) _G.__handler = fn end

Log.Stop(200)
Log.Start("errors", 300)
assert(type(_G.__handler) == "function", "arming a run installs a handler")

_G.__handler("attempt to index a nil value")
_G.__handler("attempt to index a nil value")
_G.__handler("bad argument #1")

rep = Log.Report()
assert(#rep.errors == 2,
       "THE SAMPLE IS PER DISTINCT MESSAGE: one broken OnUpdate raises thousands of "
       .. "identical errors in a pull, and a record that fills with one repeated line has "
       .. "lost the other nineteen. got " .. tostring(#rep.errors))
assert(rep.errorCounts["attempt to index a nil value"].n == 2,
       "and the repeat is COUNTED, not discarded - *how often* is half of what an error says")

-- ⚠⚠ THE ROW THAT MATTERS MOST HERE.
assert(#passedOn == 3,
       "THE LOGGER SWALLOWED AN ERROR: `geterrorhandler()` is saved and CALLED after we "
       .. "record. A logger that eats errors is worse than no logger, because the tester "
       .. "stops seeing what the GAME would have told them - and this module exists to be "
       .. "believed. passed on " .. tostring(#passedOn) .. " of 3")

-- ★ AND IT LEAVES THE CLIENT'S PATH ON STOP - restoring what it SAVED, not clearing to
-- nil, which would take the client's own handler away with ours.
local mine = _G.__handler
Log.Stop(400)
assert(_G.__handler ~= mine and type(_G.__handler) == "function",
       "THE HANDLER WAS NOT RESTORED: between runs this module must not sit in the "
       .. "client's error path at all")

-- =====================================================================
-- ★★ THE CAPS DROP AND SAY SO — a silent truncation reads as *nothing else happened*
-- =====================================================================
Log.Start("capped", 500)
for i = 1, Log.MAX_LINES + 25 do Log.Note("noise", "line " .. i) end
rep = Log.Report()
assert(#rep.lines == Log.MAX_LINES, "the cap holds, got " .. tostring(#rep.lines))
assert(rep.dropped == 25,
       "A TRUNCATION WAS SILENT: a record that stops writing without saying so implies "
       .. "*nothing else happened*, which is the one thing a record must never imply. "
       .. "dropped " .. tostring(rep.dropped))
assert(rep.counts["noise"] == Log.MAX_LINES + 25,
       "and the COUNT keeps going past the line cap - the bucket is what survives volume")

-- =====================================================================
-- ★ ONE RUN, AND NO SCHEDULER — the two fences this module could lose
-- =====================================================================
local name2, displaced = Log.Start("second", 600)
assert(name2 == "second", "the new run is named")
assert(displaced and displaced.name == "capped",
       "STARTING A SECOND RUN MUST CLOSE THE FIRST **AND HAND IT BACK**: two live "
       .. "records would each be missing what the other saw and neither could be "
       .. "cited - and a displaced record that is simply DROPPED takes its "
       .. "evidence with it")
assert(displaced.stopped == 600,
       "the displaced run is stopped at the moment it was displaced")
Log.Stop(700)
assert(Log.Report() == nil, "a stopped run reports nothing; the caller holds what Stop gave")

-- ⚠⚠ COMMENTS STRIPPED FIRST. The raw grep matched THIS MODULE'S OWN COMMENT saying
-- *no OnUpdate* - a source scan that reads prose as code, which is the same fault
-- `check_spec` had matching a key inside a sentence. ★ A check on CODE must look at code.
local src = io.open("addons/COA_DungeonRun/debuglog.lua"):read("*a")
src = src:gsub("%-%-[^\10\13]*", "")
assert(not src:find("OnUpdate") and not src:find("C_Timer"),
       "THE LOGGER GREW A SCHEDULER: `0 persistent OnUpdate` is this addon's standing "
       .. "property and a logger is the classic way to lose it. This module is CALLED, "
       .. "never ticking")

-- =====================================================================
-- ★★★ THE UI BASIS — *"a basis of how the UI is today"*, once per deployed UI
--
-- ★ Graded against FAKES, which is what keeping `ReadFrames` pure buys: it takes frames
-- and returns a table, so the client is never needed to prove the walk, the signature or
-- the once-per-deploy rule.
-- =====================================================================
local function fake(name, kind, w, h, kids)
    local f
    f = {
        GetName = function() return name end,
        GetObjectType = function() return kind end,
        IsShown = function() return true end,
        GetRect = function() return 10, 20, w, h end,
        GetChildren = function() return unpack(kids or {}) end,
    }
    return f
end

local pane = fake("Pane", "Frame", 600, 400, {
    fake("Pane.Ordinal", "EditBox", 60, 20),
    fake("Pane.Sense", "Button", 96, 22),
})
local basis, key = Log.ReadFrames({ pane })
assert(basis and basis.n == 3,
       "THE WALK MISSED CHILDREN: the basis is the BUILT tree - `panespec.lua` declares "
       .. "the pane and `check_interface` grades the declaration, and neither can say what "
       .. "the client actually built. got " .. tostring(basis and basis.n))
assert(basis.frames[1].name == "Pane" and basis.frames[2].depth == 1,
       "the tree keeps its shape, parent before child")
assert(basis.frames[2].rect[3] == 60 and basis.frames[2].rect[4] == 20,
       "and each frame carries the rect the CLIENT gave it, not the one we asked for")

-- ★★ ONCE PER DEPLOYED UI: the same tree returns nothing the second time.
local seen = { [key] = true }
local again, sameKey = Log.ReadFrames({ pane }, seen)
assert(again == nil and sameKey == key,
       "THE BASIS RE-CAPTURED AN UNCHANGED UI: *once per deployed UI* - and the key still "
       .. "comes back so a caller can tell 'already have this' from 'nothing to read'")

-- ★★★ AND THE KEY IS THE UI'S OWN SHAPE, NOT A VERSION STRING. A `## Version` does not
-- move on every deploy, so keying on it would miss exactly the case this exists for.
local grown = fake("Pane", "Frame", 600, 400, {
    fake("Pane.Ordinal", "EditBox", 60, 20),
    fake("Pane.Sense", "Button", 96, 22),
    fake("Pane.Trigger", "Button", 96, 22),
})
local third = Log.ReadFrames({ grown }, seen)
assert(third ~= nil,
       "A CHANGED UI WAS TREATED AS SEEN: the pane grew a control and the key did not "
       .. "move. Keying on anything but the tree itself misses the deploy that changed "
       .. "the UI without changing a version")

-- ⚠ AND A MOVED PANE IS THE SAME UI. The signature takes SHAPE and SIZE, never
-- position - an author who dragged the window has not changed the interface.
local moved = fake("Pane", "Frame", 600, 400, {
    fake("Pane.Ordinal", "EditBox", 60, 20),
    fake("Pane.Sense", "Button", 96, 22),
})
moved.GetRect = function() return 900, 800, 600, 400 end
local _, movedKey = Log.ReadFrames({ moved })
assert(movedKey == key,
       "MOVING THE PANE COUNTED AS A NEW UI: the signature is SHAPE and SIZE, not "
       .. "position. Otherwise every drag would ask for a fresh basis and the record "
       .. "would fill with copies of one interface")

-- ⚠ A frame with no `GetRect` (a region, a stub) is recorded rather than skipped -
-- **its ABSENCE of geometry is a fact about the UI too.**
local bare = { GetName = function() return "Bare" end,
               GetObjectType = function() return "Texture" end }
local b2 = Log.ReadFrames({ bare })
assert(b2.n == 1 and b2.frames[1].rect == nil,
       "A FRAME WITHOUT GEOMETRY WAS DROPPED: it is still part of the tree, and a basis "
       .. "that silently omits what it could not measure is a basis that lies by omission")

print("smoke_debuglog: OK - a named run; buckets not lines; the throttle reported; errors "
      .. "sampled, counted and PASSED ON; caps that say what they dropped")
