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
    function o:GetText() return self._text end
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
function D.Cycle(step, perFrame, onDone)
    local i = 0
    repeat
        i = i + 1
        local ok, done = pcall(step, i)
    until (not ok) or done or i > 100
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
assert(#p.behaviours >= 5, "every modelled behaviour is probed, got " .. #p.behaviours)
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
-- Offline the stubs implement neither Click(), GetTexture() nor real visibility, so
-- EVERY control fails and the run must call itself dead. Asserting that is what
-- proves the catch-all is wired rather than decorative.
-- ⚠ live BEFORE dead, and it matters: `dead` is DERIVED from `live`, so a broken
-- live counter fails both - and whichever assertion runs first is the message we
-- would read. The derived one must come second or it steals the cause's message.
assert(p.verdict.live == 0,
       "NO CONTROL CAN FIRE OFFLINE, so a non-zero live count means the counter is "
       .. "not reading b.control at all - got " .. tostring(p.verdict.live))
assert(p.verdict.dead,
       "THE STUBS CANNOT DRIVE THESE EXPERIMENTS, so an offline run must report the "
       .. "apparatus DEAD. Reporting otherwise means the controls are not being read.")

-- ⚠ NOT TESTABLE HERE, and recorded rather than faked: the `live > 0` path and the
-- transition from dead to alive need a client. Making this stub drive Click() and
-- GetTexture() would turn the smoke into a second model of the client - the exact
-- thing task_api exists to check - so those paths are proven by a LIVE RUN or not at
-- all. No mutation is filed for them because none could bite.

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
