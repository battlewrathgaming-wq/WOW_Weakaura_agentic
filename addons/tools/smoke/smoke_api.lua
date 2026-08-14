-- Offline smoke for COA_DevDump task_api.lua.
--
-- ---------------------------------------------------------------------------
-- ⚠⚠ READ THIS BEFORE ADDING TO IT. THIS SMOKE CANNOT TEST THE TASK'S FINDINGS,
-- ONLY ITS PLUMBING - and the reason is the whole point of the task existing.
--
-- task_api measures whether the CLIENT behaves the way `harness.lua` models it. Run
-- offline it measures our stubs instead, and since §82 taught the stubs to match the
-- harness, every behaviour would "agree" by construction. That is not a passing
-- test; it is a mirror.
--
-- ★ SO ASSERTING `agrees == true` HERE WOULD BE ACTIVELY HARMFUL: it would go green
-- forever, look like coverage, and tell us nothing about the client - the exact
-- shape of failure §77's ticks and §77.2's toggle both had.
--
-- What is asserted: the task registers, the envelope is filled, the shapes are
-- right, a missing global is RECORDED rather than skipped, and the verdict counts
-- match the rows they summarise. Plumbing only, and deliberately so.
-- ---------------------------------------------------------------------------

local breakReadback = false
local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }

function UnitName() return "Gravekeeper" end
function UnitClass() return "Necromancer", "NECROMANCER" end
function GetRealmName() return "Area 52" end
function date(fmt) return "20260814_120000" end
function GetRealZoneText() return "Shadowfang Keep" end
function GetSubZoneText() return "" end
function GetCurrentPlayerPosition() return 1, 2, 3, 33 end
function GetCurrentMapDungeonLevel() return 6 end
function IsInInstance() return true, "party" end
function GetTime() return 100.0 end
function GetLocale() return "enUS" end
-- ⚠ ONE FIXTURE THAT THROWS, and it is here for a reason: without it no call row is
-- ever a FAILURE, so the assertion about carrying error text could not be reached
-- and its mutation came back SILENT. A fixture that cannot reach a guard's failure
-- case is the single most common weak test this bench produces.
function GetDifficultyInfo(i)
    if type(i) ~= "number" then
        error("bad argument #1 to 'GetDifficultyInfo' (number expected)", 2)
    end
    return "Normal", i
end
UIParent = {}
COA_DevDumpDB = nil

-- ★★ THE OPAQUE-TABLE FIXTURE, shaped like the real phenomenon. `C_Timer` on this
-- client is a table that `pairs` sees as EMPTY while `C_Timer.After` works - which is
-- how a name search over 51,855 globals said "absent" about something in daily use.
-- Reproduced with __index, or every assertion about it below is unreachable.
C_Timer = setmetatable({}, { __index = function(_, k)
    if k == "After" then return function() end end
    return nil
end })
-- ...and an ORDINARY table beside it, so "counted the members" and "hardcoded zero"
-- are distinguishable. With only the opaque one they read identically.
C_CVar = { GetCVar = function() end, GetCVarBool = function() end,
           GetCVarDefault = function() end }

-- A frame stub with just enough to survive the experiments. It does NOT fire
-- scripts: this smoke must not accidentally become a second model of the client.
local function stub()
    local o = { _shown = false }
    local mt = { __index = function(_, k)
        if type(k) == "string" and k:sub(1, 1) == "_" then return nil end
        return function() end
    end }
    function o:SetScript(k, fn) self[k] = fn end
    function o:Show() self._shown = true end
    function o:Hide() self._shown = false end
    function o:IsShown() return self._shown end
    function o:SetText(t) self._text = t end
    -- ★ breakReadback is the DEAD-PATH FIXTURE. v5 gave every text experiment a
    -- box-level control (does SetText read back?), which this stub CAN satisfy - so
    -- two controls legitimately fire offline and the run is no longer dead by
    -- default. Breaking readback is how the dead path stays reachable and testable.
    function o:GetText() if breakReadback then return nil end return self._text end
    function o:SetChecked(v) self._checked = v and true or false end
    function o:GetChecked() return self._checked end
    function o:SetTexture(t) self._tex = t; self._coord = nil end
    function o:SetTexCoord(...) self._coord = { ... } end
    function o:GetTexCoord() return unpack(self._coord or { 0, 1, 0, 1 }) end
    function o:CreateTexture() return stub() end
    function o:CreateFontString() return stub() end
    return setmetatable(o, mt)
end
function CreateFrame() return stub() end

local D = { VERSION = "test", tasks = {} }
function D.Print(m) DEFAULT_CHAT_FRAME:AddMessage(m) end
function D.RegisterTask(t) D.tasks[t.name] = t end
function D.Begin(task, args)
    COA_DevDumpDB = { header = { task = task, args = args, status = "open" }, payload = {} }
    return COA_DevDumpDB.payload
end
function D.Commit(summary)
    COA_DevDumpDB.header.status = "complete"
    COA_DevDumpDB.header.summary = summary
    D.Print(summary)
end

-- ⚠ The real D.Cycle paces across FRAMES via OnUpdate. There are no frames here, so
-- this runs the steps back to back: it models the SEQUENCE the task's plumbing
-- depends on - step until done, then onDone - and deliberately does NOT model the
-- passage of time. ★ No assertion below may rest on a frame having elapsed, because
-- none has; that is what the live run is for.
-- ⚠ The cap is a RUNAWAY BACKSTOP, not a frame budget. It was 100, and when the
-- experiments went to a 180-frame window it silently truncated every plan before its
-- verdict step - the stub's own safety limit quietly shortening the test. Caught by
-- the "THE PLANS DID NOT RUN" assertion, which is exactly what that assertion is for.
function D.Cycle(step, perFrame, onDone)
    local i = 0
    repeat
        i = i + 1
        local ok, done = pcall(step, i)
    until (not ok) or done or i > 5000
    if onDone then onDone(i, false) end
end

assert(loadfile([[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_DevDump\task_api.lua]]))("COA_DevDump", D)
local api = assert(D.tasks.api, "the task registered itself").run

for _, leaked in ipairs({ "PULL", "INPUTS", "behaviours", "matrix", "describe" }) do
    assert(_G[leaked] == nil, "LEAKED GLOBAL: " .. leaked)
end

-- =====================================================================
-- The run fills the envelope
-- =====================================================================
api("")
local p = COA_DevDumpDB.payload
assert(COA_DevDumpDB.header.status == "complete", "the envelope was committed")
assert(p.where and p.where.zone == "Shadowfang Keep",
       "WHERE IS MISSING: half these calls are zone-dependent, so a sheet without a "
       .. "location cannot be read later")
assert(p.where.mapID == 33, "and it records the internal mapID, not the area id")

-- ★ Every behaviour row must carry all four columns. A row missing `claim` is a
-- measurement with nothing to measure against.
assert(#p.behaviours >= 8, "every modelled behaviour is probed, got " .. #p.behaviours)

-- ★★ THE MULTI-FRAME PLAN. An experiment may return one function PER FRAME, and a
-- step returning nil means "I acted, the answer comes later" - which is what makes a
-- DEFERRED or COALESCED client behaviour measurable at all. Offline D.Cycle runs the
-- steps back to back, so the sequencing is exercised even though no time passes.
local planned = 0
for _, b in ipairs(p.behaviours) do
    if b.deferred then planned = planned + 1 end
end
assert(planned >= 4,
       "THE PLANS DID NOT RUN: " .. planned .. " row(s) reported a deferred verdict, "
       .. "so the per-frame scheduler is not advancing them and every multi-frame "
       .. "experiment is silently reporting only its synchronous first pass")

-- ★ A step that returns nil must NOT overwrite the row. The two-frame discriminator
-- banks a count on frame 1 and answers on frame 2; if nil were treated as a verdict
-- the row would be wiped between them.
for _, b in ipairs(p.behaviours) do
    assert(b.observed and b.observed ~= "",
           "A NIL STEP OVERWROTE A ROW: '" .. tostring(b.name) .. "' has no observation")
end
for _, b in ipairs(p.behaviours) do
    assert(b.name and b.name ~= "", "a behaviour row names itself")
    assert(b.claim and b.claim ~= "",
           "A ROW WITHOUT A CLAIM IS UNREADABLE: " .. tostring(b.name))
    assert(b.observed and b.observed ~= "", "and carries what was measured")
    assert(type(b.agrees) == "boolean",
           "AGREES MUST BE A BOOLEAN: nil reads as 'no disagreement' and hides a fault")
    assert(type(b.control) == "boolean",
           "CONTROL MUST BE A BOOLEAN: it is what separates a real finding from a "
           .. "dead experiment, and nil would default to 'the apparatus was fine'")
    -- ★★ THE RULE THE FIRST LIVE RUN BOUGHT: a row whose apparatus did not
    -- demonstrably work may NEVER read as a disagreement about the client.
    assert(b.verdict == "agrees" or b.verdict == "DISAGREES" or b.verdict == "inconclusive",
           "UNKNOWN VERDICT: " .. tostring(b.verdict))
    if not b.control then
        assert(b.verdict == "inconclusive",
               "A DEAD EXPERIMENT REPORTED AS A FINDING: '" .. tostring(b.name)
               .. "' has no working control and says " .. tostring(b.verdict))
    end
end

-- ★★ A MISSING GLOBAL IS A FINDING, NOT A SKIP. Learning which of these exist on
-- THIS fork is half the reason to run it - a quietly skipped name looks identical to
-- one that passed.
local sawMissing, sawThrew, sawCalls = false, false, {}
for _, c in ipairs(p.calls) do
    assert(c.fn and c.fn ~= "", "a call row names its function")
    sawCalls[c.fn] = true
    if c.err == "NOT PRESENT IN _G" then sawMissing = true
    elseif not c.ok then sawThrew = true end
    if c.ok then
        assert(type(c.rets) == "number", "a successful call records its return ARITY")
    else
        assert(c.err and c.err ~= "",
               "A FAILED CALL MUST CARRY ITS ERROR: the handler text is the finding")
    end
end
assert(sawCalls.GetCurrentPlayerPosition, "the PULL list actually got walked")
assert(sawMissing,
       "MISSING GLOBALS ARE BEING SKIPPED: this fixture defines only some of PULL, so "
       .. "at least one must be recorded as absent rather than passed over")
-- ★★ THE FIXTURE MUST REACH THE ERROR PATH, asserted rather than assumed. Without
-- this the "carries its error" guard above sits behind a case no fixture produces -
-- and that is precisely how its mutation came back SILENT the first time.
assert(sawThrew,
       "THE FIXTURE CANNOT REACH THE ERROR PATH: no probed call threw, so every "
       .. "assertion about error text below is unreachable and proves nothing")

-- ★★ TABLES THE CENSUS CANNOT SEE. `C_Timer` enumerates as EMPTY in the 51,855-global
-- census and `C_Timer.After` works regardless - so a name search proving absence
-- proves nothing, and this block is what turns that from a wrong row in the intent
-- shelf into a measured one.
assert(p.opaque and #p.opaque > 0, "the opaque-table block was written")
local sawTimer = false
for _, o in ipairs(p.opaque) do
    assert(o.table and o.table ~= "", "an opaque row names its table")
    assert(o.kind and o.kind ~= "", "and records whether it is present at all")
    assert(type(o.enumerable) == "number",
           "ENUMERABLE MUST BE A NUMBER: 0 is the finding (present but blind to pairs) "
           .. "and nil would read the same as 'not checked'")
    assert(type(o.members) == "table", "and members is a table")
    if o.kind == "table" then
        assert(#o.members > 0,
               "A ROW WITHOUT DIRECT LOOKUPS MEASURES NOTHING: pairs is the thing that "
               .. "fails on these, so named members must be asked for one by one")
    end
    if o.table == "C_Timer" then
        sawTimer = true
        assert(o.enumerable == 0,
               "the fixture's C_Timer must be BLIND TO PAIRS, or it is not reproducing "
               .. "the phenomenon - got " .. tostring(o.enumerable))
        local found = table.concat(o.members, " ")
        assert(found:find("After=function", 1, true),
               "AND THE DIRECT LOOKUP MUST FIND IT: C_Timer.After exists and pairs "
               .. "cannot see it, which is the whole finding - got " .. found)
    elseif o.table == "C_CVar" then
        assert(o.enumerable == 3,
               "AN ORDINARY TABLE MUST COUNT: enumerable is a real count, not a "
               .. "constant - got " .. tostring(o.enumerable))
    end
end
assert(sawTimer,
       "C_Timer MUST BE PROBED: it is the case that proved a name search can lie, and "
       .. "the intent shelf carries a row that stays 'unknown' until this measures it")

-- The verdict has to agree with the rows it summarises, or the chat line lies.
local disagree, live, threw, missing = 0, 0, 0, 0
for _, b in ipairs(p.behaviours) do
    if b.verdict == "DISAGREES" then disagree = disagree + 1 end
    if b.control then live = live + 1 end
end
for _, c in ipairs(p.calls) do
    if c.err == "NOT PRESENT IN _G" then missing = missing + 1
    elseif not c.ok then threw = threw + 1 end
end
assert(p.verdict.disagree == disagree and p.verdict.threw == threw
       and p.verdict.missing == missing,
       ("VERDICT DISAGREES WITH THE ROWS: said %d/%d/%d, rows say %d/%d/%d")
       :format(p.verdict.disagree, p.verdict.threw, p.verdict.missing,
               disagree, threw, missing))
-- ★ The INCONCLUSIVE count is the one this fixture can actually check. Offline every
-- control legitimately fails, so `disagree` is always 0 whatever the code does - and
-- a cross-check on a number that cannot vary proves nothing.
local inconclusive = 0
for _, b in ipairs(p.behaviours) do
    if b.verdict == "inconclusive" then inconclusive = inconclusive + 1 end
end
assert(p.verdict.inconclusive == inconclusive,
       ("VERDICT DISAGREES WITH THE ROWS on inconclusive: said %s, rows say %d")
       :format(tostring(p.verdict.inconclusive), inconclusive))

-- ★★★ THE CATCH-ALL. `dead` is a property of the RUN: one experiment with a broken
-- control is a broken experiment, but ALL of them broken is a broken apparatus, and
-- those want different reactions from whoever reads the sheet. The first live run
-- presented five dead experiments as four confident findings about the client.
assert(type(p.verdict.dead) == "boolean", "the run says whether it measured anything")
-- ⚠ live BEFORE dead, and it matters: `dead` is DERIVED from `live`, so a broken
-- live counter fails both - and whichever assertion runs first is the message we
-- would read. The derived one must come second or it steals the cause's message.
assert(p.verdict.live == live,
       "THE LIVE COUNT DISAGREES WITH THE ROWS: said " .. tostring(p.verdict.live)
       .. ", rows say " .. live)
assert(p.verdict.dead == (p.verdict.live == 0),
       "THE DEAD FLAG DISAGREES WITH THE CONTROLS: dead=" .. tostring(p.verdict.dead)
       .. " with live=" .. tostring(p.verdict.live))

-- ★★ THE DEAD PATH, PROVEN WITH A FIXTURE BUILT FOR IT. v5's box-level control is
-- satisfiable offline, so the run is no longer dead by default - and a catch-all
-- that can never be seen firing is one nobody should trust. Break the readback so
-- EVERY control fails, and the run must say so.
breakReadback = true
api("")
local dp = COA_DevDumpDB.payload
breakReadback = false
assert(dp.verdict.live == 0,
       "WITH READBACK BROKEN NO CONTROL CAN FIRE, got live=" .. tostring(dp.verdict.live))
assert(dp.verdict.dead,
       "THE CATCH-ALL DID NOT FIRE: every control failed and the run still did not "
       .. "report the apparatus DEAD - which is exactly the state that produced four "
       .. "false findings in run 1")
assert(dp.verdict.disagree == 0,
       "A DEAD RUN REPORTED A DISAGREEMENT: with no working control, nothing measured "
       .. "may be presented as a finding about the client")
assert(tostring(COA_DevDumpDB.header.summary):find("APPARATUS DEAD", 1, true),
       "and the SUMMARY LINE must lead with it, or the reader never learns the run "
       .. "was worthless: " .. tostring(COA_DevDumpDB.header.summary))

-- ★★★ AND THE HARD LINE: READ-ONLY. Not one PUSH name may appear anywhere in the
-- task's source. Asserted against the FILE rather than the run, because a push
-- hidden behind a branch would never execute here and the run would look clean.
local src = assert(io.open(
    [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_DevDump\task_api.lua]]))
local text = src:read("*a"); src:close()
local body = text:gsub("%-%-[^\n]*", "")      -- strip comments; PUSH names are DISCUSSED there
for _, push in ipairs({ "SetCVar", "SetMapByID", "SetMapToCurrentZone", "ShowUIPanel",
                        "HideUIPanel", "PlaySound", "StaticPopup_Show",
                        "SuperTrackerUtil", "C_SuperTrack" }) do
    assert(not body:find(push, 1, true),
           "PUSH CALL IN A READ-ONLY PROBE: '" .. push .. "' would change the live client")
end

print("smoke_api: OK")
