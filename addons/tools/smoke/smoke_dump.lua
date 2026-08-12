-- Offline smoke for COA_DevDump task_dump.lua.
--
-- The failure modes here are all the SAME KIND: a record that looks complete
-- when it is not. That is worse than no record, because a bound gets read as a
-- fact about the game. So every cap, cycle and non-serialisable value must
-- leave a mark in payload.notes, and nothing may be silently dropped.

local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }
local function said(pat)
    for _, m in ipairs(chat) do if m:find(pat, 1, true) then return true end end
    return false
end

function UnitName() return "Gravekeeper" end
function UnitClass() return "Necromancer", "NECROMANCER" end
function GetRealmName() return "Area 52" end
function date(fmt) return "20260813_120000" end
COA_DevDumpDB = nil

-- Minimal stand-in for the v2 envelope spine, matching core.lua's contract.
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

assert(loadfile([[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_DevDump\task_dump.lua]]))("COA_DevDump", D)
local dump = assert(D.tasks.dump, "the task registered itself").run

for _, leaked in ipairs({"scalar", "keyFor", "serialise", "MAX_DEPTH", "MAX_KEYS"}) do
    assert(_G[leaked] == nil, "LEAKED GLOBAL: " .. leaked)
end

-- =====================================================================
-- The vocabulary is the client's: an EXPRESSION, evaluated like /dump
-- =====================================================================
Fixture = { alpha = 1, beta = "two", flag = true }
dump("Fixture")
assert(COA_DevDumpDB.header.status == "complete", "a plain table lands")
local p = COA_DevDumpDB.payload
assert(p.expression == "Fixture", "the expression is recorded with the value")
assert(p.values[1].alpha == 1 and p.values[1].beta == "two" and p.values[1].flag == true,
       "scalars land as themselves")
assert(p.truncated == false, "nothing was capped, and it says so")

-- Function calls, exactly as /dump takes them - and MULTIPLE returns.
function TwoThings() return 7, "seven" end
dump("TwoThings()")
p = COA_DevDumpDB.payload
assert(p.returnCount == 2, "all return values captured, got " .. tostring(p.returnCount))
assert(p.values[1] == 7 and p.values[2] == "seven", "multiple returns land in order")

-- A dotted path into a nested table - the DeathRecap case.
Nested = { DeathRecap = { CurrentRecap = 3, Events = { [3] = { { damage = 4000, healthPercent = 0.12 } } } } }
dump("Nested.DeathRecap")
p = COA_DevDumpDB.payload
assert(p.values[1].CurrentRecap == 3, "dotted paths resolve")
assert(p.values[1].Events[3][1].healthPercent == 0.12, "nested structure survives intact")

-- =====================================================================
-- NOTHING IS DROPPED. A missing key implies the field was not there.
-- =====================================================================
Mixed = { n = 1, fn = function() end, str = "s" }
dump("Mixed")
p = COA_DevDumpDB.payload
assert(p.values[1].fn == "<function>",
       "a function is TAGGED, not dropped - the key must survive")
assert(p.values[1].n == 1 and p.values[1].str == "s", "its siblings are unaffected")

-- =====================================================================
-- NO SILENT CAPS - every bound leaves a note at the point it bit
-- =====================================================================
Cyclic = { name = "root" }
Cyclic.self = Cyclic
dump("Cyclic")
p = COA_DevDumpDB.payload
assert(p.values[1].self == "<cycle>", "a cycle is caught rather than walked forever")
assert(p.truncated == true and #p.notes > 0, "and it is NOTED, not swallowed")
assert(p.notes[1]:find("cycle"), "the note names the reason, got: " .. tostring(p.notes[1]))

Deep = {}
local cur = Deep
for i = 1, 12 do cur.down = {}; cur = cur.down end
cur.bottom = "reached"
dump("Deep")
p = COA_DevDumpDB.payload
local found = false
for _, n in ipairs(p.notes) do if n:find("depth cap") then found = true end end
assert(found, "DEPTH CAP FAILED: the walk was truncated with no note")

Wide = {}
for i = 1, 250 do Wide["k" .. i] = i end
dump("Wide")
p = COA_DevDumpDB.payload
found = false
for _, n in ipairs(p.notes) do if n:find("width cap") and n:find("MORE KEYS EXIST") then found = true end end
assert(found, "WIDTH CAP FAILED: keys were dropped with no note saying more exist")

-- Sibling tables that SHARE a reference are not a cycle. Marking them as one
-- would silently hollow out real data - the seen-set is a PATH, not a registry.
local shared = { v = 1 }
Siblings = { a = shared, b = shared }
dump("Siblings")
p = COA_DevDumpDB.payload
assert(p.values[1].a.v == 1 and p.values[1].b.v == 1,
       "SHARED-REFERENCE FAILED: a sibling was mistaken for a cycle and hollowed out")

-- Keys that cannot round-trip through the SV writer are tagged, and reported.
NonString = { [true] = "bool key", real = "kept" }
dump("NonString")
p = COA_DevDumpDB.payload
assert(p.values[1].real == "kept", "the normal keys are unaffected")
found = false
for _, n in ipairs(p.notes) do if n:find("non%-string key") then found = true end end
assert(found, "a non-string key was dropped without a note")

-- =====================================================================
-- Failure lands NOTHING. A record of our own syntax error would read as
-- evidence about the game.
-- =====================================================================
COA_DevDumpDB = nil
chat = {}
dump("this is not ((valid lua")
assert(COA_DevDumpDB == nil, "a compile failure must not open an envelope")
assert(said("cannot compile"), "and it must say so loudly")

COA_DevDumpDB = nil
chat = {}
dump("error('boom')")
assert(COA_DevDumpDB == nil, "a runtime error must not open an envelope")
assert(said("error while evaluating"), "and it must say so loudly")

chat = {}
dump("")
assert(said("Usage:"), "no expression prints usage")

print("smoke_dump: OK")
