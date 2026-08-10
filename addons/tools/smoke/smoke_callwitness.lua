-- Offline smoke for task_callwitness: stands up a FAKE driver addon shaped
-- like Mancer, drives it, and asserts the acceptance criteria from
-- addons/planning/callwitness_design.md.
local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }
date = os.date

local now = 1000.0
function GetTime() return now end
local profileMs = 0
function debugprofilestop() return profileMs end
function GetFramerate() return 91.5 end
function GetRealZoneText() return "Orgrimmar" end
function GetSubZoneText() return "The Drag" end
function GetAddOnMetadata(n, k) return n == "LibellusLeti" and "0.9.563" or "2.2.0" end
function UpdateAddOnCPUUsage() end
local cpu = { LibellusLeti = 0, COA_DevDump = 0 }
function GetAddOnCPUUsage(n) return cpu[n] or 0 end
function GetAddOnMemoryUsage(n) return 0 end
function UnitName() return "Gravekeeper" end
function UnitClass() return "Necromancer", "NECROMANCER" end
function GetRealmName() return "Vol'jin" end
function GetNetStats() return 0, 0, 30, 40 end

local plateCount = 12
function UnitExists(u)
    local n = tonumber(u:match("^nameplate(%d+)$"))
    return n ~= nil and n <= plateCount
end

local cvars = { nameplateShowFriends = "1", nameplateShowEnemies = "1",
    nameplateShowFriendlyPets = "1", nameplateShowFriendlyGuardians = "1",
    nameplateShowFriendlyTotems = "1", nameplateShowEnemyPets = "1",
    nameplateShowEnemyGuardians = "1", nameplateShowEnemyTotems = "1",
    nameplateShowPersonal = "0", scriptProfile = "1" }
function GetCVar(k) return cvars[k] end

MancerDB = { disableNameplatesInCapitals = false, showMinionHpList = false,
             hideMinionHpNameplateVisuals = nil,   -- absent => default ON
             nameplateNamesOnlyTargets = { players = false, guardians = true } }

-- ---- the fake driver, shaped like the real module layout ----
local hud = {}
local scanCount, reassertCount = 0, 0
function hud:ScanAndApplyNamesOnly()
    scanCount = scanCount + 1
    profileMs = profileMs + (scanCount % 8 == 0 and 42 or 3)   -- periodic heavy call
end
function hud:ReassertNamesOnly() reassertCount = reassertCount + 1 profileMs = profileMs + 0.4 end
function hud:Refresh() profileMs = profileMs + 1 end
function hud:SyncNameplateSupport() profileMs = profileMs + 0.5 end
function hud:UpdateCloakDriver() profileMs = profileMs + 0.2 end
function hud:CollectFramesForUnit(unit) profileMs = profileMs + 0.05 return { unit } end
function hud:ShouldNamesOnlyUnit(unit) return true end
Mancer = { MinionHpHudModule = hud, RegenTracker = { OnUpdate = function() end } }

local frames = {}
function CreateFrame()
    local f = { scripts = {} }
    function f:SetScript(e, fn) self.scripts[e] = fn end
    function f:RegisterEvent() end
    function f:UnregisterAllEvents() end
    function f:Fire(e, ...) if self.scripts[e] then self.scripts[e](self, ...) end end
    frames[#frames + 1] = f
    return f
end
SlashCmdList = {}

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_DevDump\]]
local ns = {}
local function load(f) assert(loadfile(ROOT .. f))("COA_DevDump", ns) end
load("core.lua")
load("task_callwitness.lua")

SlashCmdList["COADEVDUMP"]("st callwitness 5")
local tick = frames[#frames]

-- the wrappers must be INSTALLED (the addon now calls ours)
assert(hud.ScanAndApplyNamesOnly ~= nil, "method present")
local installed = hud.ScanAndApplyNamesOnly

-- drive: 20 "seconds", each with 2 scans + 3 reasserts + a refresh
for sec = 1, 20 do
    for _ = 1, 2 do hud:ScanAndApplyNamesOnly() end
    for _ = 1, 3 do hud:ReassertNamesOnly() end
    hud:Refresh()
    hud:SyncNameplateSupport()
    for i = 1, 40 do hud:CollectFramesForUnit("nameplate" .. i) end
    now = now + 1.0
    cpu.LibellusLeti = cpu.LibellusLeti + 24
    cpu.COA_DevDump = cpu.COA_DevDump + 0.1
    tick:Fire("OnUpdate", 1.0)
end

SlashCmdList["COADEVDUMP"]("sp")
local p = COA_DevDumpDB.payload

-- ============ acceptance criteria ============
local function fnIndex(name)
    for i, n in ipairs(p.legend) do if n == name then return i end end
end

-- AC1: per-function attribution exists and names the heavy one
local scanI = fnIndex("HpHud:ScanAndApplyNamesOnly")
assert(scanI, "AC1: scan function in legend")
local perFn = {}
for k = 1, #p.buckets.fn do
    local i = p.buckets.fn[k]
    perFn[i] = (perFn[i] or 0) + p.buckets.us[k]
end
local topI, topUs = nil, -1
for i, us in pairs(perFn) do if us > topUs then topI, topUs = i, us end end
assert(topI == scanI, "AC1: heaviest fn is the scan, got " .. tostring(p.legend[topI]))

-- AC3: calls and cost are independent series
local calls40 = 0
for k = 1, #p.buckets.fn do
    if p.buckets.fn[k] == scanI then calls40 = calls40 + p.buckets.calls[k] end
end
assert(calls40 == 40, "AC3: 40 scan calls recorded, got " .. calls40)

-- AC4: one-slow-call vs many-fast is decidable (max present + outliers logged)
local sawBigMax = false
for k = 1, #p.buckets.fn do
    if p.buckets.fn[k] == scanI and p.buckets.maxUs[k] > 40000 then sawBigMax = true end
end
assert(sawBigMax, "AC4: max-us captures the heavy call")
assert(#p.outliers.ms > 0, "AC4: outliers logged")
local anyScanOutlier = false
for k = 1, #p.outliers.fn do if p.outliers.fn[k] == scanI then anyScanOutlier = true end end
assert(anyScanOutlier, "AC4: the heavy scan appears in the outlier log with a timestamp")

-- AC5: plate population on the same timeline
assert(#p.context.plates == 20 and p.context.plates[1] == 12, "AC5: plate count sampled")

-- AC6: arm-defining state at start AND end
assert(p.envStart and p.envEnd, "AC6: env captured both ends")
assert(p.envStart.cvars.nameplateShowFriends == "1", "AC6: cvars")
assert(p.envStart.settings.disableNameplatesInCapitals == false, "AC6: mute setting")
assert(p.envStart.zone == "Orgrimmar", "AC6: zone")
assert(p.envStart.plateCount == 12, "AC6: plate count in env")
-- AC6, the trap this driver sets: ABSENT means the feature is ON. A nil would
-- serialise away and read as "not captured". Must be an explicit sentinel.
assert(p.envStart.settings.hideMinionHpNameplateVisuals == "ABSENT(default-on)",
    "AC6: absent-means-on recorded explicitly, got "
    .. tostring(p.envStart.settings.hideMinionHpNameplateVisuals))

-- AC7: observer cost measured three ways (probe present + extrapolation)
assert(p.probe and p.probe.calls == 2000, "AC7a: probe ran")
assert(p.probe.overheadUsPerCall ~= nil, "AC7a: per-call overhead measured")
assert(p.totals.estOverheadUs ~= nil, "AC7b: overhead x calls present")

-- AC8: cross-check columns present
assert(#p.context.driverCpuUs == 20 and #p.context.selfCpuUs == 20, "AC8: engine CPU both sides")

-- AC9: bounds honest
assert(p.bounds and p.bounds.truncated == false, "AC9: truncation flag present and false")

-- AC10: clean removal
assert(p.unwrap.restored == p.unwrap.total, "AC10: all wrappers removed")
assert(hud.ScanAndApplyNamesOnly ~= installed, "AC10: original restored on the table")
scanCount = 0
hud:ScanAndApplyNamesOnly()
assert(scanCount == 1, "AC10: unwrapped function still works")

-- AC12: build identified by content (structural fingerprint), not just label
assert(p.structuralFingerprint and p.structuralFnCount > 0, "AC12: structural fingerprint")
assert(p.driverVersion == "0.9.563", "AC12: label recorded too (but not trusted alone)")

-- AC13: the witness witnesses itself, in the SAME table
assert(fnIndex("Witness:ContextTick"), "AC13: our ContextTick in the same legend")
assert(fnIndex("Witness:FlushBuckets"), "AC13: our FlushBuckets in the same legend")
local wI = fnIndex("Witness:ContextTick")
local selfCalls = 0
for k = 1, #p.buckets.fn do
    if p.buckets.fn[k] == wI then selfCalls = selfCalls + p.buckets.calls[k] end
end
assert(selfCalls > 0, "AC13: our own function actually measured")

-- missing targets reported, not silently skipped
assert(type(p.missingTargets) == "table" and #p.missingTargets > 0,
    "unresolved methods are REPORTED")

print(("CALLWITNESS SMOKE PASS - %d fn wrapped, %d calls, top=%s, %d outliers, unwrap %d/%d, overhead %.2fus/call")
    :format(#p.legend, p.totals.calls, p.legend[topI], #p.outliers.ms,
            p.unwrap.restored, p.unwrap.total, p.probe.overheadUsPerCall))
