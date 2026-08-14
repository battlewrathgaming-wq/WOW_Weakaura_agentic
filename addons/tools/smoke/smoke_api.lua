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
local disagree, threw, missing = 0, 0, 0
for _, b in ipairs(p.behaviours) do if not b.agrees then disagree = disagree + 1 end end
for _, c in ipairs(p.calls) do
    if c.err == "NOT PRESENT IN _G" then missing = missing + 1
    elseif not c.ok then threw = threw + 1 end
end
assert(p.verdict.disagree == disagree and p.verdict.threw == threw
       and p.verdict.missing == missing,
       ("VERDICT DISAGREES WITH THE ROWS: said %d/%d/%d, rows say %d/%d/%d")
       :format(p.verdict.disagree, p.verdict.threw, p.verdict.missing,
               disagree, threw, missing))

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
