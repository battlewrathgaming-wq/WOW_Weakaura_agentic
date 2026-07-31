-- Offline smoke for task_petlog: stubbed canonical CLEU + a simulated fight.
local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }
date = os.date
bit = { band = function(a, b)
    local r, m = 0, 1
    while a > 0 and b > 0 do
        if a % 2 == 1 and b % 2 == 1 then r = r + m end
        a = math.floor(a / 2) b = math.floor(b / 2) m = m * 2
    end
    return r
end }
local now = 1000.0
function GetTime() return now end
function GetAddOnMetadata() return "2.2.0" end
function UnitName(u) return u == "player" and "Gravekeeper" or "Ghoul" end
function UnitClass() return "Necromancer", "NECROMANCER" end
function GetRealmName() return "Vol'jin" end
function UnitStat(u, i) return 500, 500, 0, 0 end
function UnitAttackPower(u) return (u == "player") and 100, 10, 0 or 900, 0, 0 end
function GetSpellBonusDamage(school) return 1234 end
function UnitHealth() return 527 end
function UnitHealthMax() return 527 end
function UnitLevel() return 60 end
function UnitDamage() return 80, 120 end
function UnitAttackSpeed() return 2.0 end
function UnitArmor() return 0, 3000 end
local plateGuids = {}
function UnitGUID(u)
    if u == "player" then return "0x0000000000AAAA" end
    return plateGuids[u]
end
local auraRows = { { "Master of Ghouls", 2, 999001 } }
function UnitAura(u, i)
    local r = auraRows[i]
    if not r then return nil end
    return r[1], "rank", "icon", r[2], nil, nil, nil, nil, nil, nil, r[3]
end

local cleuNow = nil
function CombatLogGetCurrentEventInfo() return unpack(cleuNow) end

local frames = {}
function CreateFrame()
    local f = { scripts = {} }
    function f:SetScript(ev, fn) self.scripts[ev] = fn end
    function f:RegisterEvent() end
    function f:UnregisterAllEvents() end
    function f:Fire(ev, ...) if self.scripts[ev] then self.scripts[ev](self, ...) end end
    frames[#frames + 1] = f
    return f
end
SlashCmdList = {}

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_DevDump\]]
local ns = {}
local function loadaddon(f) assert(loadfile(ROOT .. f))("COA_DevDump", ns) end
loadaddon("core.lua")
loadaddon("task_petlog.lua")

SlashCmdList["COADEVDUMP"]("st petlog")
local ev, tick = frames[#frames - 1], frames[#frames]

local MINE_GUARDIAN = 0x1 + 0x2000  -- affiliation mine + guardian
local PLAYER_FLAGS = 0x1 + 0x100 + 0x10 + 0x400
local G1, G2 = "0xF13000C779000001", "0xF13000C394000002"

local function fire(t)
    cleuNow = t
    ev:Fire("OnEvent", "COMBAT_LOG_EVENT_UNFILTERED", "raw-vararg-shadow")
end

-- summons (sourceGUID = player at canonical position 4; dest = pet at position 8)
fire({ now, "SPELL_SUMMON", false, "0x0000000000AAAA", "Gravekeeper", PLAYER_FLAGS, nil, G1, "Ghoul", MINE_GUARDIAN, nil, 500970, "Raise: Lesser", 32 })
fire({ now, "SPELL_SUMMON", false, "0x0000000000AAAA", "Gravekeeper", PLAYER_FLAGS, nil, G2, "Abomination", MINE_GUARDIAN, nil, 504859, "Raise: Abom", 32 })

-- pet swing damage w/ crit at canonical-ish suffix; miss with missType
fire({ now, "SWING_DAMAGE", false, G1, "Ghoul", MINE_GUARDIAN, nil, "0xF13000AAAA0009", "Target Dummy", 0x10a48, nil, 150, 0, 1, nil, nil, nil, true })
fire({ now, "SWING_MISSED", false, G1, "Ghoul", MINE_GUARDIAN, nil, "0xF13000AAAA0009", "Target Dummy", 0x10a48, nil, "DODGE" })
fire({ now, "SPELL_DAMAGE", false, G2, "Abomination", MINE_GUARDIAN, nil, "0xF13000AAAA0009", "Target Dummy", 0x10a48, nil, 92147, "Cleave", 1, 300, 0, 1, 0, 0, 0 })

-- an UNRELATED event must be filtered out
fire({ now, "SPELL_DAMAGE", false, "0xDEAD", "SomeoneElse", 0x548, nil, "0xBEEF", "Other", 0x10a48, nil, 1, "X", 1, 5 })

-- plate window opens for G1 -> snapshot tick
plateGuids["nameplate3"] = G1
now = now + 2.1
tick:Fire("OnUpdate", 2.1)

-- G1 dies
fire({ now, "UNIT_DIED", false, nil, nil, nil, nil, G1, "Ghoul", MINE_GUARDIAN })

SlashCmdList["COADEVDUMP"]("sp")

local p = COA_DevDumpDB.payload
assert(COA_DevDumpDB.header.task == "petlog" and COA_DevDumpDB.header.status == "complete", "envelope")
assert(p.canonApi == true, "canon api stamped")
assert(#p.events == 6, "kept 6 rows (2 summon + 3 combat + 1 died), filtered the stranger: got " .. #p.events)
assert(p.events[1].mode == "canon", "canonical read mode stamped")
assert(p.registry_final[G1] and p.registry_final[G1].summoned and p.registry_final[G1].died, "G1 full lifecycle")
assert(p.registry_final[G2] and not p.registry_final[G2].died, "G2 alive")
assert(#p.registry_events == 3, "registry event trail")
assert(#p.snapshots == 1, "one snapshot tick")
local s = p.snapshots[1]
assert(s.pets[1].guid == G1 and s.pets[1].dmgMin == 80 and s.pets[1].ap, "pet stat pair captured")
assert(s.ownerAP and s.ownerStamina and s.ownerSP_shadow == 1234, "owner side of the lab pair")
assert(s.auras[1][1] == "Master of Ghouls" and s.auras[1][2] == 2, "aura-stack witness feed")
assert((p.handler_errors or 0) == 0, "no handler errors")
assert(chat[#chat]:find("6 events, 1 snapshots, 2 registered pets, canonApi=true"), "summary: " .. chat[#chat])
print("PETLOG SMOKE PASS - " .. chat[#chat])
