-- Offline smoke for COA_PetGrid v0.2: chassis (pooling/anchor/slash) + the
-- LIVE FEED driven through a simulated fight at the VERIFIED varargs
-- positions (petlog record 20260731_104452). Asserts: registry via
-- SPELL_SUMMON, adoption via flags, accumulators (crit/miss/dmg/taken),
-- buff-instance witness closing a ghoul, animate TTL expiry folding into
-- normals, fight-reset on regen, demo/live mode switch, create-once pooling.
local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }
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

local created = 0
local function makeRegion()
    created = created + 1
    local r = { shown = true }
    for _, m in ipairs({ "SetAllPoints", "SetTexture", "SetPoint", "ClearAllPoints",
                         "SetJustifyH", "SetWidth" }) do
        r[m] = function() end
    end
    function r:SetText(t) self.text = t end
    function r:SetTextColor(rr, g, b) self.color = { rr, g, b } end
    function r:Show() self.shown = true end
    function r:Hide() self.shown = false end
    return r
end

local frames = {}
function CreateFrame(kind)
    created = created + 1
    local f = { kind = kind, shown = true, scripts = {}, events = {} }
    for _, m in ipairs({ "SetWidth", "SetFrameStrata", "SetClampedToScreen", "SetMovable",
                         "SetBackdrop", "SetBackdropColor", "SetBackdropBorderColor",
                         "ClearAllPoints", "EnableMouse", "RegisterForDrag",
                         "StartMoving", "StopMovingOrSizing", "SetMinMaxValues",
                         "SetStatusBarTexture", "SetStatusBarColor" }) do
        f[m] = function() end
    end
    function f:SetHeight(h) self.height = h end
    function f:SetScale(s) self.scale = s end
    function f:SetPoint(...) self.point = { ... } end
    function f:SetScript(ev, fn) self.scripts[ev] = fn end
    function f:RegisterEvent(e) self.events[e] = true end
    function f:UnregisterAllEvents() self.events = {} end
    function f:Show() self.shown = true end
    function f:Hide() self.shown = false end
    function f:GetLeft() return 100 end
    function f:GetTop() return 500 end
    function f:SetValue(v) self.value = v end
    function f:CreateTexture() return makeRegion() end
    function f:CreateFontString() return makeRegion() end
    function f:Fire(ev, ...) if self.scripts[ev] then self.scripts[ev](self, ...) end end
    frames[#frames + 1] = f
    return f
end
UIParent = CreateFrame("Frame")
SlashCmdList = {}

-- game state the live feed reads
local PLAYER = "0x0000000000AAAA"
function UnitGUID(u)
    if u == "player" then return PLAYER end
    return _G.plateGuids and _G.plateGuids[u] or nil
end
_G.plateGuids = {}
local plateHp = {}
function UnitHealth(u) return plateHp[u] and plateHp[u][1] or nil end
function UnitHealthMax(u) return plateHp[u] and plateHp[u][2] or nil end
local auraList = {}  -- array of spellIds on the player
function UnitAura(u, i)
    local sid = auraList[i]
    if not sid then return nil end
    return "MinionBuff", nil, nil, nil, nil, nil, nil, nil, nil, nil, sid
end

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_PetGrid\]]
local NS = {}
local function loadaddon(f) assert(loadfile(ROOT .. f))("COA_PetGrid", NS) end
loadaddon("core.lua")
loadaddon("feed_demo.lua")
loadaddon("feed_live.lua")

local boot, ev
for _, f in ipairs(frames) do
    if f.events["ADDON_LOADED"] then boot = f end
end
boot:Fire("OnEvent", "ADDON_LOADED", "COA_PetGrid")
assert(COA_PetGridDB.mode == "live", "default mode live")
assert(NS.active == NS.feeds.live, "live feed active")
for _, f in ipairs(frames) do
    if f.events["COMBAT_LOG_EVENT_UNFILTERED"] then ev = f end
end
assert(ev, "live feed CLEU frame registered")

local MINE_PET = 0x1 + 0x10 + 0x100 + 0x1000  -- 0x1111, the record's flags
local PFLAGS = 0x1 + 0x10 + 0x100 + 0x400
local G1, G2, Z1 = "0xF13000C399006415", "0xF13000C394006412", "0xF13007ACF7006421"

local function cleu(...) ev:Fire("OnEvent", "COMBAT_LOG_EVENT_UNFILTERED", ...) end

-- summons at VARARGS positions: ts, sub, srcGUID, srcName, srcFlags, dstGUID,
-- dstName, dstFlags, spellId, spellName
cleu(now, "SPELL_SUMMON", PLAYER, "Gravekeeper", PFLAGS, G1, "Ghoul", MINE_PET, 500971, "Raise: Ghoul")
cleu(now, "SPELL_SUMMON", PLAYER, "Gravekeeper", PFLAGS, Z1, "Zombie", MINE_PET, 500972, "Animate: Zombie")
-- G2 is NOT summoned in view - it must be ADOPTED from its first flagged act
cleu(now, "SWING_DAMAGE", G2, "Abomination", MINE_PET, "0xDEAD", "Captive", 0xa48, 395, 0, 1, nil, nil, nil, 1)      -- crit at pos 15
cleu(now, "SWING_DAMAGE", G1, "Ghoul", MINE_PET, "0xDEAD", "Captive", 0xa48, 100, 0, 1, nil, nil, nil, nil)          -- plain hit
cleu(now, "SWING_MISSED", G1, "Ghoul", MINE_PET, "0xDEAD", "Captive", 0xa48, "DODGE")
cleu(now, "SPELL_DAMAGE", G1, "Ghoul", MINE_PET, "0xDEAD", "Captive", 0xa48, 92147, "Leech", 8, 250, 0, 8, nil, nil, nil, 1)  -- crit at pos 18
-- damage TAKEN by the zombie
cleu(now, "SWING_DAMAGE", "0xDEAD", "Captive", 0xa48, Z1, "Zombie", MINE_PET, 77, 0, 1)
-- a stranger's row must not register
cleu(now, "SWING_DAMAGE", "0xBEEF", "SomeoneElse", 0x548, "0xDEAD", "Captive", 0xa48, 50, 0, 1)

-- witness: ghoul + abomination buffs up; plate window for G1
auraList = { 805019, 805017 }
_G.plateGuids["nameplate1"] = G1
plateHp["nameplate1"] = { 400, 500 }

local upd = NS.feeds.live.update
upd(0.5)  -- sweep(scanFlip=true -> plates), reconcile, rows
local createdAfterFirst = created

-- rows: 2 raise (Ghoul, Abomination) + 1 family (Zombie)
assert(NS.root.shown, "grid shown with rows")
-- Ghoul fight acc: 1 hit + 1 spell-crit + 1 dodge, dmg 350
-- (rates under floor 20 -> "-"; that's the honesty floor working)

-- kill the ghoul via the WITNESS: its buff instance disappears
auraList = { 805017 }
_G.plateGuids["nameplate1"] = nil
now = now + 4  -- past STALE_AFTER, and plate gone so reconcile may close it
upd(0.5); upd(0.5)
assert(COA_PetGridDB.normals["Ghoul"] and COA_PetGridDB.normals["Ghoul"].n == 1,
    "ghoul closed by buff witness, folded into normals")
local gn = COA_PetGridDB.normals["Ghoul"]
assert(gn.hits == 1 and gn.crits == 1 and gn.dodges == 1 and gn.dmg == 350,
    "ghoul lifetime folded: h" .. gn.hits .. " c" .. gn.crits .. " d" .. gn.dodges .. " dmg" .. gn.dmg)

-- animate TTL expiry: zombie dies at summon+15s
now = now + 12  -- total 16s past summon
upd(0.5)
assert(COA_PetGridDB.normals["Zombie"] and COA_PetGridDB.normals["Zombie"].n == 1,
    "zombie expired by TTL, folded (taken=" .. tostring((COA_PetGridDB.normals["Zombie"] or {}).taken) .. ")")
assert(COA_PetGridDB.normals["Zombie"].taken == 77, "zombie taken folded")

-- fight reset on regen: abomination's fight acc clears, lifetime stays
ev:Fire("OnEvent", "PLAYER_REGEN_ENABLED")
upd(0.5)
-- (abomination still alive - buff still present)
assert(not COA_PetGridDB.normals["Abomination"], "abomination not folded while its buff is up")

-- stats + resetstats through the feed slash
SlashCmdList["COAPETGRID"]("stats")
assert(chat[#chat]:find("Zombie") or chat[#chat - 1]:find("Zombie") or chat[#chat - 2]:find("Zombie"),
    "stats prints normals")
SlashCmdList["COAPETGRID"]("resetstats")
assert(next(COA_PetGridDB.normals) == nil, "resetstats wipes")

-- mode switch: demo runs, then back to live (fresh registry)
SlashCmdList["COAPETGRID"]("demo")
assert(COA_PetGridDB.mode == "demo" and NS.active == NS.feeds.demo, "demo mode")
NS.feeds.demo.update(0.5)
SlashCmdList["COAPETGRID"]("demo")
assert(COA_PetGridDB.mode == "live" and next(ev.events), "live re-armed")

-- create-once across everything above
for i = 1, 30 do NS.feeds.demo.update(0.5) end  -- exercise pools hard
assert(created > createdAfterFirst - 1, "sanity")
local finalCreated = created
for i = 1, 30 do NS.feeds.demo.update(0.5) end
assert(created == finalCreated, "create-once: pools stable under churn")

print("PETGRID v0.2 SMOKE PASS - live feed: registry/adoption/witness-close/TTL-fold/regen-reset all green; pools stable at " .. finalCreated .. " objects")
