-- Offline smoke for task_cleu: drives three arms against stubs and asserts the
-- things that would silently ruin a live measurement.
--
--   * `none` must NOT be registered - if it is, the baseline arm is not a baseline
--   * `count` must be the cheap shape, `masked` must actually filter
--   * the per-second sampler must record allocation, not just counts
--   * ★ the comparability check must REFUSE a comparison across unequal errands,
--     because a harness that always produces a figure is worse than one that says
--     "these were not the same run"

local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }
date = os.date
local now = 100.0
function GetTime() return now end
function GetAddOnMetadata() return "2.2.0" end
function UnitName() return "Gravekeeper" end
function UnitClass() return "Necromancer", "NECROMANCER" end
function GetRealmName() return "Vol'jin" end
function GetRealZoneText() return "Shadowfang Keep" end
function GetSubZoneText() return "" end
function LoggingCombat() return nil end
function CombatLogGetRetentionTime() return 300 end
function debugprofilestop() now = now + 0.0001; return now * 1000 end

-- The allocation number the task reads. Driven by the test so a delta can be
-- asserted rather than hoped for.
local KB = 1000
collectgarbage = function(what) if what == "count" then return KB end end

COMBATLOG_OBJECT_REACTION_HOSTILE = 0x00000040
bit = { band = function(a, b)
    local r, m = 0, 1
    while a > 0 and b > 0 do
        if a % 2 == 1 and b % 2 == 1 then r = r + m end
        a, b, m = math.floor(a / 2), math.floor(b / 2), m * 2
    end
    return r
end }

local frames = {}
function CreateFrame()
    local f = { scripts = {}, events = {} }
    function f:SetScript(ev, fn) self.scripts[ev] = fn end
    function f:RegisterEvent(e) self.events[e] = true end
    function f:UnregisterEvent(e) self.events[e] = nil end
    function f:Fire(ev, ...) if self.scripts[ev] then self.scripts[ev](self, ...) end end
    frames[#frames + 1] = f
    return f
end
SlashCmdList = {}

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_DevDump\]]
local ns = {}
local function loadaddon(f) assert(loadfile(ROOT .. f))("COA_DevDump", ns) end
loadaddon("core.lua")
loadaddon("task_cleu.lua")

local slash = SlashCmdList["COADEVDUMP"]

-- ★ The in-session command path core gained for this. Without it a session can
-- only be started and stopped, and the arms would need a /reload between them -
-- which is exactly the client-state drift the arms exist to avoid.
slash("mark count")
local said = false
for _, m in ipairs(chat) do if m:find("No session open", 1, true) then said = true end end
assert(said, "mark with no session says so rather than doing nothing")

slash("st cleu")
local f = frames[#frames]

-- ★ ARM `none` IS NOT REGISTERED. If it were, the baseline arm would be measuring
-- a listener, and every later comparison would be against the wrong zero.
assert(not f.events["COMBAT_LOG_EVENT_UNFILTERED"],
       "BASELINE POLLUTED: arm `none` must not register the combat log event")
assert(f.events["PLAYER_REGEN_DISABLED"],
       "pulls are counted on EVERY arm - they are the comparability key")

-- A pull and some seconds on the baseline.
local function fire(n, sub, dstFlags)
    for _ = 1, (n or 1) do
        f:Fire("OnEvent", "COMBAT_LOG_EVENT_UNFILTERED",
               1, sub or "SPELL_DAMAGE", "src", "Src", 0, "dst", "Dst", dstFlags or 0)
    end
end
local function second(kb)
    now = now + 1
    if kb then KB = kb end
    f:Fire("OnUpdate", 1.0)
end

f:Fire("OnEvent", "PLAYER_REGEN_DISABLED")
fire(50)                       -- not registered: these must not be counted
second(1010); second(1020)

local p = COA_DevDumpDB.payload
assert(p.rows[1].n == 0,
       "UNREGISTERED ARM COUNTED: `none` saw " .. p.rows[1].n .. " line(s)")
assert(p.rows[1].kb == 1010, "the sampler records ALLOCATION, got " .. tostring(p.rows[1].kb))
assert(p.rows[1].a == "none", "and which arm the row belongs to")

-- ---------------------------------------------------------------------
-- arm `count` - the cost of being called, nothing else
-- ---------------------------------------------------------------------
slash("mark count")
assert(f.events["COMBAT_LOG_EVENT_UNFILTERED"], "arm `count` registers")
f:Fire("OnEvent", "PLAYER_REGEN_DISABLED")
fire(40, "SPELL_DAMAGE")
fire(2, "UNIT_DIED", 0x40)
second(1100); second(1200)

-- ---------------------------------------------------------------------
-- arm `masked` - and the mask must actually bite
-- ---------------------------------------------------------------------
slash("mark masked")
f:Fire("OnEvent", "PLAYER_REGEN_DISABLED")
-- ★ HOSTILE DAMAGE, not damage with no flags. The first version used dstFlags 0
-- here and the harness reported the SUBEVENT test as SILENT: with every damage
-- line unflagged, the flag test alone gave the same answer, so the fixture could
-- not reach the subevent guard's failure. It is also what a real pull looks like -
-- almost every damage line targets something hostile.
fire(40, "SPELL_DAMAGE", 0x40)      -- hostile, but the WRONG subevent: no hit
fire(3, "UNIT_DIED", 0x40)          -- hostile death: a hit
fire(2, "UNIT_DIED", 0x10)          -- friendly death: NOT a hit
second(1300); second(1400)

slash("sp")

local sum = COA_DevDumpDB.payload.summary
local byArm = {}
for _, a in ipairs(sum.byArm) do byArm[a.arm] = a end

assert(byArm.none.lines == 0, "the baseline saw nothing")
assert(byArm.count.lines == 42, "count saw every line, got " .. byArm.count.lines)
assert(byArm.count.hits == 0, "count does no filtering at all - that is the point of it")

assert(byArm.masked.lines == 45, "masked still sees every line, got " .. byArm.masked.lines)
assert(byArm.masked.hits == 3,
       "MASK LEAKED: only a HOSTILE UNIT_DIED survives - hostile damage must fail "
       .. "the SUBEVENT test, a friendly death must fail the FLAG test. Got "
       .. byArm.masked.hits)

-- Allocation is a DELTA per segment, not an absolute - an absolute would just be
-- whatever the client happened to be holding.
assert(byArm.count.kbDelta > 0, "allocation is recorded as a delta over the segment")

-- ★ COMPARABLE: one pull per arm, similar durations.
assert(sum.comparable, "equal pull counts and durations -> comparable, got: "
       .. tostring(sum.notComparableBecause))

-- ---------------------------------------------------------------------
-- ★ AND IT REFUSES AN UNEQUAL COMPARISON. Two arms, different pull counts.
-- ---------------------------------------------------------------------
chat = {}
slash("st cleu")
local g = frames[#frames]
g:Fire("OnEvent", "PLAYER_REGEN_DISABLED")
now = now + 1; g:Fire("OnUpdate", 1.0)
slash("mark count")
g:Fire("OnEvent", "PLAYER_REGEN_DISABLED")
g:Fire("OnEvent", "PLAYER_REGEN_DISABLED")      -- two pulls: a different errand
now = now + 1; g:Fire("OnUpdate", 1.0)
slash("sp")

local s2 = COA_DevDumpDB.payload.summary
assert(not s2.comparable,
       "UNEQUAL ERRANDS COMPARED: differing pull counts must void the comparison")
assert(s2.notComparableBecause:find("pull counts differ", 1, true),
       "and it must say WHY, got " .. tostring(s2.notComparableBecause))
local shouted = false
for _, m in ipairs(chat) do if m:find("NOT COMPARABLE", 1, true) then shouted = true end end
assert(shouted, "the summary line must SAY it, not leave it in the payload to be found")

-- A single arm cannot be compared with anything either.
slash("st cleu")
local h = frames[#frames]
now = now + 1; h:Fire("OnUpdate", 1.0)
slash("sp")
assert(not COA_DevDumpDB.payload.summary.comparable,
       "one arm is not a comparison")

-- The timer health check is REPORTED rather than trusted - this bench has seen
-- debugprofilestop silently not advance.
assert(COA_DevDumpDB.payload.env.timer.available, "the timer is reported")
assert(COA_DevDumpDB.payload.env.timer.advanced ~= nil, "and whether it ADVANCES")

print("smoke_cleu: OK")
