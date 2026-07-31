-- Offline smoke for MancerLedger: fake MancerDB ring + paper doll, driven
-- through: no-profile deferral, profile create/fold, fingerprint dedup,
-- fold-before-switch, drift detection (bad shape skipped loudly, extra field
-- noted), compare/stats/status, seen-cap FIFO.
local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }
local function lastSaid(pat)
    for i = #chat, 1, -1 do
        if chat[i]:find(pat, 1, true) then return chat[i] end
    end
    return nil
end

date = os.date
function UnitLevel() return 60 end
function UnitStat(u, i) return ({ 50, 40, 230, 180, 90 })[i] end
function GetSpellBonusDamage(school) return 326 end
function UnitAttackPower() return 100, 49, 0 end
function GetSpellCritChance() return 12.4 end
DRIVER_V = "0.9.434"
function GetAddOnMetadata(name)
    if name == "LibellusLeti" then return DRIVER_V end
    if name == "MancerLedger" then return "0.5.0" end
    return nil
end
function UnitAffectingCombat() return false end

local function makeRegion()
    local r = { shown = true }
    for _, m in ipairs({ "SetAllPoints", "SetTexture", "SetPoint", "ClearAllPoints",
                         "SetJustifyH", "SetWidth", "SetHeight", "SetVertexColor" }) do
        r[m] = function() end
    end
    function r:SetText(t) self.text = t end
    function r:SetTextColor(rr, g, b) self.color = { rr, g, b } end
    function r:Show() self.shown = true end
    function r:Hide() self.shown = false end
    return r
end

_G.ddInfos = {}
function UIDropDownMenu_SetWidth() end
function UIDropDownMenu_Initialize(dd, fn) dd.initFn = fn end
function UIDropDownMenu_CreateInfo() return {} end
function UIDropDownMenu_AddButton(info) table.insert(_G.ddInfos, info) end
function UIDropDownMenu_SetText(dd, t) dd.ddText = t end

local frames = {}
function CreateFrame(kind, name)
    local f = { scripts = {}, events = {}, width = 10, shown = true }
    if name then _G[name] = f end
    for _, m in ipairs({ "SetFrameStrata", "SetClampedToScreen", "SetMovable", "SetBackdrop",
                         "SetBackdropColor", "SetBackdropBorderColor", "ClearAllPoints",
                         "EnableMouse", "RegisterForDrag", "StartMoving", "StopMovingOrSizing",
                         "SetAutoFocus", "SetMaxLetters", "ClearFocus", "SetJustifyH",
                         "RegisterForClicks", "SetFrameLevel" }) do
        f[m] = function() end
    end
    function f:SetScript(ev, fn) self.scripts[ev] = fn end
    function f:GetScript(ev) return self.scripts[ev] end
    function f:RegisterEvent(e) self.events[e] = true end
    function f:UnregisterAllEvents() self.events = {} end
    function f:SetWidth(w) self.width = w end
    function f:GetWidth() return self.width end
    function f:SetHeight(h) self.height = h end
    function f:SetPoint(...) self.point = { ... } end
    function f:GetPoint() return self.point and unpack(self.point) or nil end
    function f:Show() self.shown = true end
    function f:Hide() self.shown = false end
    function f:IsShown() return self.shown end
    function f:SetText(t) self.btnText = t end
    function f:GetText() return self.btnText or "" end
    function f:Enable() self.enabled = true end
    function f:Disable() self.enabled = false end
    function f:CreateTexture() return makeRegion() end
    function f:CreateFontString()
        local r = makeRegion()
        _G.allFontStrings[#_G.allFontStrings + 1] = r
        return r
    end
    function f:Fire(ev, ...) if self.scripts[ev] then self.scripts[ev](self, ...) end end
    frames[#frames + 1] = f
    return f
end
SlashCmdList = {}
UIParent = CreateFrame("Frame")
UISpecialFrames = {}
InterfaceOptions_AddCategory = function() end
_G.allFontStrings = {}

-- the driver's ring: two clean fights + one shape-broken one
local function bucket(dmg, hits, act, sum, spells, extra)
    local b = { damage = dmg, hits = hits, activeSeconds = act, summonCount = sum, spells = spells or {} }
    if extra then for k, v in pairs(extra) do b[k] = v end end
    return b
end
MancerDB = { minionDps = { fights = {
    -- index 1 = newest (driver inserts at 1); harvest folds oldest-first.
    -- 0.9.553 shape: misses + missTypes at bucket and spell grain; plus one
    -- UNKNOWN number and one UNKNOWN table the fold must note, not eat.
    { startedAt = 200, endedAt = 260, minions = {
        ghoul = bucket(5000, 60, 180, 3, { ["id:1"] = { label = "Melee", spellId = 1, damage = 4000, hits = 50,
                                                        misses = 3, missTypes = { DODGE = 2, PARRY = 1 } },
                                           ["id:9"] = { label = "Plague", spellId = 9, damage = 1000, hits = 10 } },
                       { misses = 4, missTypes = { DODGE = 2, PARRY = 1, RESIST = 1 },
                         glances = 2, weird = { x = 1 } }),
        abomination = bucket(9000, 40, 60, 1),
    } },
    { startedAt = 100, endedAt = 150, minions = {
        ghoul = bucket(3000, 30, 120, 2, { ["id:1"] = { label = "Melee", spellId = 1, damage = 3000, hits = 30 } },
                       { misses = 2, missTypes = { DODGE = 2 } }),
    } },
} } }

Minimap = CreateFrame("Frame")
function Minimap:GetCenter() return 200, 200 end
function Minimap:GetEffectiveScale() return 1 end
function GetCursorPosition() return 100, 100 end
MouseIsOver = function() return false end
GameTooltip = { SetOwner = function() end, AddLine = function() end,
                Show = function() end, Hide = function() end }

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\MancerLedger\]]
local NS = {}
assert(loadfile(ROOT .. "core.lua"))("MancerLedger", NS)
assert(loadfile(ROOT .. "ui.lua"))("MancerLedger", NS)
assert(loadfile(ROOT .. "minimap.lua"))("MancerLedger", NS)

local ev
for _, f in ipairs(frames) do
    if f.events["ADDON_LOADED"] then ev = f end
end
assert(ev, "core event frame found")
ev:Fire("OnEvent", "ADDON_LOADED", "MancerLedger")
assert(MancerLedgerDB and MancerLedgerDB.profiles, "SV seeded")

-- harvest with NO profile: defers loudly, folds nothing
ev:Fire("OnEvent", "PLAYER_REGEN_ENABLED")
ev:Fire("OnUpdate", 2.0)
assert(lastSaid("NO ACTIVE PROFILE"), "no-profile deferral said")
assert(#MancerLedgerDB.seen == 0, "nothing folded without a profile")

-- create a profile -> fold both fights
SlashCmdList["MANCERLEDGER"]("new stamBuild")
assert(MancerLedgerDB.active == "stamBuild", "profile live")
assert(lastSaid("stam 230"), "capture in the create line")
SlashCmdList["MANCERLEDGER"]("harvest")
local p = MancerLedgerDB.profiles.stamBuild
assert(p.folds == 2, "two fights folded, got " .. p.folds)
assert(p.log.ghoul.damage == 8000 and p.log.ghoul.hits == 90, "ghoul summed across fights")
assert(p.log.ghoul.summonCount == 5 and p.log.ghoul.activeSeconds == 300, "ghoul counters")
assert(p.log.ghoul.misses == 6, "misses folded, got " .. tostring(p.log.ghoul.misses))
assert(p.log.ghoul.missTypes.DODGE == 4 and p.log.ghoul.missTypes.PARRY == 1
    and p.log.ghoul.missTypes.RESIST == 1, "missTypes summed across fights")
assert(p.log.abomination.fights == 1, "abomination in one fight")
assert(p.log.ghoul.spells["id:1"].hits == 80, "melee sub-bucket merged")
assert(p.log.ghoul.spells["id:1"].misses == 3 and p.log.ghoul.spells["id:1"].missTypes.DODGE == 2,
    "per-spell miss detail folded")
assert(p.drift.glances and p.drift.weird, "unknown number AND table fields NOTED as drift")
assert(not p.drift.misses and not p.drift.missTypes, "known 0.9.553 fields are folded, not drift")
assert(lastSaid("don't fold yet"), "drift said loudly")

-- dedup: second harvest folds nothing
SlashCmdList["MANCERLEDGER"]("harvest")
assert(p.folds == 2, "fingerprint dedup held")
assert(lastSaid("nothing new"), "dedup reported")

-- a clean fight + a SHAPE-BROKEN fight: clean (older) folds, breakage LATCHES
table.insert(MancerDB.minionDps.fights, 1,
    { startedAt = 300, endedAt = 330, minions = { ghoul = bucket(1000, 10, 30, 1) } })
table.insert(MancerDB.minionDps.fights, 1,
    { startedAt = 400, endedAt = 420, minions = { ghoul = { damage = "corrupt", hits = 5 } } })
SlashCmdList["MANCERLEDGER"]("harvest")
assert(p.folds == 3, "older clean fight folded before the breakage, folds=" .. p.folds)
assert(p.log.ghoul.damage == 9000, "sum includes third fight")
assert(MancerLedgerDB.lockout, "shape breakage LATCHED the lockout")
assert(lastSaid("FOLDS LOCKED"), "lock said (slash context)")

-- latched: clean newer fights do NOT fold while locked (auto path)
table.insert(MancerDB.minionDps.fights, 1,
    { startedAt = 450, endedAt = 470, minions = { ghoul = bucket(500, 5, 15, 1) } })
NS.harvest()
assert(p.folds == 3, "latch holds against auto harvest")

-- driver update -> auto-retry attempts; corrupt still present -> re-locks w/ NEW stamp
DRIVER_V = "0.9.600"
NS.harvest()
assert(MancerLedgerDB.lockout and MancerLedgerDB.lockout.driver:find("0.9.600", 1, true),
    "version change triggered a retry; re-locked with the new driver stamped")
assert(p.folds == 3, "still latched (breakage persists)")

-- the broken fight leaves the ring (aged out / driver fixed) -> manual retry unlocks + folds
for i, f in ipairs(MancerDB.minionDps.fights) do
    if f.startedAt == 400 then table.remove(MancerDB.minionDps.fights, i) break end
end
SlashCmdList["MANCERLEDGER"]("harvest")
assert(not MancerLedgerDB.lockout, "manual retry cleared the latch")
assert(p.folds == 4, "queued clean fight folded after unlock, folds=" .. p.folds)

-- fold-before-switch: pending fight goes to the OLD profile
table.insert(MancerDB.minionDps.fights, 1,
    { startedAt = 500, endedAt = 540, minions = { ghoul = bucket(2000, 20, 60, 1) } })
SlashCmdList["MANCERLEDGER"]("new intBuild")
assert(MancerLedgerDB.profiles.stamBuild.folds == 5, "pending fight folded to OLD profile on switch")
assert(MancerLedgerDB.profiles.intBuild.folds == 0, "new profile starts clean")
assert(MancerLedgerDB.active == "intBuild", "new profile live")

-- new fight folds to the NEW profile
table.insert(MancerDB.minionDps.fights, 1,
    { startedAt = 600, endedAt = 660, minions = { abomination = bucket(4000, 15, 50, 1) } })
ev:Fire("OnEvent", "PLAYER_REGEN_ENABLED")
ev:Fire("OnUpdate", 2.0)
assert(MancerLedgerDB.profiles.intBuild.folds == 1, "regen-delayed harvest folded to live profile")

-- surfaces don't error
SlashCmdList["MANCERLEDGER"]("stats intBuild")
assert(lastSaid("crit awaits driver support"), "honesty line present")
SlashCmdList["MANCERLEDGER"]("stats stamBuild")
assert(lastSaid("avoided as"), "miss breakdown line renders")
SlashCmdList["MANCERLEDGER"]("compare stamBuild intBuild")
assert(lastSaid("Ghoul"), "compare emits per-type lines")
SlashCmdList["MANCERLEDGER"]("list")
SlashCmdList["MANCERLEDGER"]("status")
assert(lastSaid("ring: 6 fight"), "status reads the ring: " .. tostring(lastSaid("ring:")))

-- rename: fixes typos in permanent keys (the 'geaed' finding)
SlashCmdList["MANCERLEDGER"]("rename stamBuild stamFixed")
assert(MancerLedgerDB.profiles.stamFixed and not MancerLedgerDB.profiles.stamBuild,
    "rename moved the key")
assert(MancerLedgerDB.profiles.stamFixed.name == "stamFixed", "inner name follows")
SlashCmdList["MANCERLEDGER"]("rename stamFixed stamBuild")  -- back for later asserts
-- space rejection (UI-created names must stay slash-addressable)
local ok = NS.profileNew("bad name")
assert(not ok, "spaces rejected")
-- lastDriver stamped on fold (bumped by the version-change retry above)
assert(MancerLedgerDB.profiles.stamBuild.lastDriver == "LibellusLeti 0.9.600",
    "lastDriver stamped: " .. tostring(MancerLedgerDB.profiles.stamBuild.lastDriver))
-- drift stores the version, not just true
assert(MancerLedgerDB.profiles.stamBuild.drift.glances == "LibellusLeti 0.9.434",
    "drift carries the driver version")

-- delete guard + delete
SlashCmdList["MANCERLEDGER"]("delete stamBuild")
assert(MancerLedgerDB.profiles.stamBuild, "delete requires 'sure'")
SlashCmdList["MANCERLEDGER"]("delete stamBuild sure")
assert(not MancerLedgerDB.profiles.stamBuild, "delete with sure")

-- ============================================================ THE WINDOW
-- fixture profiles with known numbers -> assert rendered delta texts
local db = MancerLedgerDB
db.profiles.naked = {
    name = "naked", folds = 3, drift = {},
    snapshot = { at = "2026-07-31 16:00", level = 60, stam = 100, int = 90,
                 spirit = 80, shadowSP = 50, ap = 60, spellCrit = 5 },
    log = {
        ghoul = { fights = 2, summonCount = 4, activeSeconds = 120, hits = 100,
                  misses = 25, damage = 5000, missTypes = { MISS = 25 }, spells = {} },
        -- a PERMANENT type: driver gives no summons/unit-time -> cells must dash
        crypt_fiend = { fights = 2, summonCount = 0, activeSeconds = 0, hits = 50,
                        misses = 0, damage = 9000, missTypes = {}, spells = {} },
        -- the scope-mix trap: permanent re-raised ONCE mid-fight (1 summon, 4
        -- fights, sliver window) - cadence must be GATED to "-", never 174.9
        skeletal_warrior_greater = { fights = 4, summonCount = 1, activeSeconds = 68,
                                     hits = 400, misses = 40, damage = 11000,
                                     missTypes = { MISS = 40 }, spells = {} },
    },
}
db.profiles.geared = {
    name = "geared", folds = 3, drift = {},
    snapshot = { at = "2026-07-31 16:20", level = 60, stam = 234, int = 202,
                 spirit = 131, shadowSP = 218, ap = 149, spellCrit = 8.4 },
    log = {
        ghoul = { fights = 2, summonCount = 6, activeSeconds = 180, hits = 240,
                  misses = 10, damage = 20000, missTypes = { MISS = 10 }, spells = {} },
    },
}
db.active = "naked"

local function findButton(text)
    for _, f in ipairs(frames) do
        if f.btnText == text and f.scripts.OnClick then return f end
    end
    return nil
end
local function anyFsText(pat)
    for _, r in ipairs(_G.allFontStrings) do
        if r.text and tostring(r.text):find(pat, 1, true) then return r.text end
    end
    return nil
end

NS.ui.Show()
-- stats view renders: permanent gap shows dashes (no 0-division, no fake zeros)
assert(anyFsText("Crypt Fiend"), "stats renders the permanent type")
assert(anyFsText("Skeletal Warrior Greater"), "trap type renders")
-- the gate: 400 hits / 68s sliver would be 352.9/min - must NOT appear anywhere
assert(not anyFsText("352.9"), "scope-mix cadence gated to dash")
-- chat surface honors the same gate + observed-only accounting
SlashCmdList["MANCERLEDGER"]("stats naked")
assert(lastSaid("Skeletal Warrior Greater: 1 summons, 68s unit-time, 400 hits (- hits/unit-min)"),
    "chat stats gates cadence: " .. tostring(lastSaid("Skeletal Warrior Greater")))
SlashCmdList["MANCERLEDGER"]("compare naked geared")
assert(lastSaid("Crypt Fiend: summons - vs -"), "chat compare dashes unobserved summons")

-- switch to compare, pick A/B through the dropdown builders
local compareBtn = findButton("Compare")
assert(compareBtn, "compare button found")
compareBtn:Fire("OnClick")
local function ddPick(ddName, profileName)
    local dd = _G[ddName]
    assert(dd and dd.initFn, "dropdown " .. ddName .. " wired")
    _G.ddInfos = {}
    dd.initFn()
    for _, info in ipairs(_G.ddInfos) do
        if tostring(info.text):find(profileName, 1, true) then
            info.func()
            return
        end
    end
    error("profile " .. profileName .. " not in " .. ddName)
end
ddPick("MancerLedgerCompareA", "naked")
ddPick("MancerLedgerCompareB", "geared")
assert(_G.MancerLedgerCompareA.ddText == "naked" and _G.MancerLedgerCompareB.ddText == "geared",
    "dropdown selections took: " .. tostring(_G.MancerLedgerCompareA.ddText))
-- the profile dropdown builder marks the live profile
_G.ddInfos = {}
_G.MancerLedgerProfileDD.initFn()
local liveMarked = false
for _, info in ipairs(_G.ddInfos) do
    if tostring(info.text):find("(live)", 1, true) then liveMarked = true end
end
assert(liveMarked, "live profile marked in the selector")

-- PAGE 1 (rates, default): attempts 125->250 = +125, cad +30.0, miss -16pp
assert(anyFsText("+125"), "attempts delta on the rates page")
assert(anyFsText("+30.0"), "cadence delta rendered")
assert(anyFsText("-16pp"), "miss delta in percentage points rendered")
assert(anyFsText("fight length doesn't skew"), "rates best-use note present")
assert(not anyFsText("+15k"), "volume columns absent from the rates page")
-- PAGE 2 (volume): hits +140, dmg +15k, controlled-conditions note
local volBtn = findButton("Volume")
assert(volBtn, "volume page button found")
volBtn:Fire("OnClick")
assert(anyFsText("+140"), "hits delta on the volume page")
assert(anyFsText("+15k"), "damage delta rendered (raw-labeled column)")
assert(anyFsText("controlled tests"), "volume best-use note present")
-- back to rates for good measure; one-sided type renders either page
findButton("Rates"):Fire("OnClick")
assert(anyFsText("Crypt Fiend"), "one-sided type present in compare")

-- window ops: new-profile via the button path
local nameBox
for _, f in ipairs(frames) do if f.scripts.OnEnterPressed then nameBox = f end end
assert(nameBox, "name box found")
nameBox.btnText = "third"
local newBtn = findButton("New")
newBtn:Fire("OnClick")
assert(db.profiles.third and db.active == "third", "window New created + activated")

-- two-click delete arms then executes (selection via the programmatic hook)
NS.ui.Show()  -- reset arm state
NS.ui.SelectProfile("third")
local delBtn = findButton("Delete")
delBtn:Fire("OnClick")
assert(db.profiles.third, "first delete click only arms")
local sureBtn = findButton("Sure?")
assert(sureBtn, "delete armed shows Sure?")
sureBtn:Fire("OnClick")
assert(not db.profiles.third, "second click deletes")

-- ============================================================ v0.4: HISTORY + TOKEN
local db4 = MancerLedgerDB
-- history collected everything (chat routing is echo-only now)
assert(db4.history and #db4.history > 0, "history ring populated")
local foundFold = false
for _, h in ipairs(db4.history) do
    if h.msg:find("folded into", 1, true) then foundFold = true break end
end
assert(foundFold, "fold events land in history")
-- UI-path ops are history-only (no chat): count chat lines, run a UI op, recount
local chatBefore = #chat
NS.profileNew("quietprofile")
assert(#chat == chatBefore, "UI-path say() does not chat")
assert(db4.history[1].msg:find("quietprofile", 1, true), "but lands in history")
-- slash path still echoes to chat
SlashCmdList["MANCERLEDGER"]("use quietprofile")
assert(#chat > chatBefore, "slash path echoes to chat")

-- recording off: flush-then-off, token state source goes nil
SlashCmdList["MANCERLEDGER"]("off")
assert(db4.active == nil, "recording off")

-- the token: onFold hook installed by minimap.lua, runs clean
assert(NS.onFold and NS.minimapPaint, "minimap hooks installed")
NS.onFold(1)
NS.minimapPaint()

-- popout: right-click builds it; the Recording Off entry exists and works
local mmBtn
for _, f in ipairs(frames) do
    if f.scripts.OnEnter and f.scripts.OnDragStart and f.scripts.OnClick then mmBtn = f end
end
assert(mmBtn, "minimap button found")
db4.active = "quietprofile"  -- make a live one so popout has content
mmBtn:Fire("OnClick", "RightButton")
local offEntry
for _, f in ipairs(frames) do
    if f.text and f.text.text and tostring(f.text.text):find("Recording Off", 1, true) then offEntry = f end
end
assert(offEntry, "popout Recording Off entry rendered")
offEntry:Fire("OnClick")
assert(db4.active == nil, "popout off works")

-- window History view renders
NS.ui.Show()
local histBtn
for _, f in ipairs(frames) do
    if f.btnText == "History" then histBtn = f end
end
assert(histBtn, "History view button found")
histBtn:Fire("OnClick")
assert(anyFsText("Recording OFF") or anyFsText("recording OFF"), "history view shows events")

print("MLEDGER SMOKE PASS - chat lanes + window + v0.4 (history routing, flight-recorder token, popout, History view) all green")
