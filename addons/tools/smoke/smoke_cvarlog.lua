-- Offline smoke for task_cvarlog: stubbed GetCVar flips values mid-session;
-- assert baseline + change rows + backup snapshots + bounds.
local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }
date = os.date
local now = 50.0
function GetTime() return now end
function GetAddOnMetadata() return "2.2.0" end
function UnitName() return "Gravekeeper" end
function UnitClass() return "Necromancer", "NECROMANCER" end
function GetRealmName() return "Vol'jin" end

local cvars = {
    nameplateShowFriends = "0", nameplateShowFriendlyPets = "1",
    nameplateShowFriendlyGuardians = "1", nameplateShowFriendlyTotems = "0",
    nameplateShowEnemies = "1", nameplateShowEnemyPets = "0",
    nameplateShowEnemyGuardians = "0", nameplateShowEnemyTotems = "0",
    nameplateShowPersonal = "0",
}
function GetCVar(k) return cvars[k] end

Mancer = { MinionHpHudModule = { nameplateCvarBackup = { nameplateShowFriends = "0" } },
           MinionSheetModule = {} }
MancerDB = { nameplateCvarBackup = { nameplateShowFriends = "0" },
             minionDps = { fights = {} } }

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
loadaddon("task_cvarlog.lua")

SlashCmdList["COADEVDUMP"]("st cvarlog")
local tick = frames[#frames]

-- no changes yet
now = now + 1; tick:Fire("OnUpdate", 1.0)

-- the repro moment: Mancer's restore replays a stale zero + plates vanish
cvars.nameplateShowFriendlyPets = "0"
cvars.nameplateShowFriendlyGuardians = "0"
Mancer.MinionHpHudModule.nameplateCvarBackup = nil  -- restore consumed it
now = now + 1; tick:Fire("OnUpdate", 1.0)

SlashCmdList["COADEVDUMP"]("sp")

local p = COA_DevDumpDB.payload
assert(COA_DevDumpDB.header.task == "cvarlog", "envelope")
assert(p.baseline.values.nameplateShowFriends == "0", "baseline captured")
assert(p.baseline.backups.hpHud and p.baseline.backups.hpHud.nameplateShowFriends == "0",
    "in-memory backup snapshotted at baseline")
assert(p.baseline.backups["MancerDB.nameplateCvarBackup"], "persisted backup swept from MancerDB")
assert(#p.changes == 2, "two flips recorded, got " .. #p.changes)
local keys = {}
for _, c in ipairs(p.changes) do
    keys[c.key] = true
    assert(c.from == "1" and c.to == "0", "flip direction recorded")
    assert(c.backups, "backup snapshot rides each change")
end
assert(keys.nameplateShowFriendlyPets and keys.nameplateShowFriendlyGuardians, "the right keys")
assert(p.final.values.nameplateShowFriendlyPets == "0", "final state captured")
assert((p.tick_errors or 0) == 0, "no tick errors")
print("CVARLOG SMOKE PASS - " .. chat[#chat])
