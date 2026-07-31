-- MinionHpHud.lua
-- Movable text list of permanent guardian Current/Max HP near the player HUD.
-- Ascension: friendly nameplates are the master switch for pet plates to appear.
-- Optional "names only" mode hides StatusBars/textures on selected plate types
-- (guardians / players / NPCs / enemies) while keeping the name FontString.

local MinionHpHud = {}
Mancer.MinionHpHudModule = MinionHpHud

local REFRESH_INTERVAL = 0.5
local MAX_ROWS = 12
local BAR_WIDTH = 152
local BAR_HEIGHT = 20
local ROW_GAP = 3
local ROW_HEIGHT = BAR_HEIGHT + ROW_GAP
local HANDLE_SIZE = 18
local LABEL_WIDTH = 52
-- HP color: full = green, at/below 30% = red, smooth lerp between.
local HP_RED_PCT = 0.30
-- Keep a row briefly if its unit token blips (nameplate recycle).
local STALE_ROW_SEC = 2.5
-- Don't thrash SetAlpha / CVar checks every HP tick.
local NAMEPLATE_SYNC_INTERVAL = 1.25
-- Names-only: Ascension re-Shows bars on camera move. Reassert lightly; full rescan rarely.
local CLOAK_REASSERT_INTERVAL = 0.30
local CLOAK_SCAN_INTERVAL = 0.50

local PERMANENT_ORDER = {
    "skeletal_warrior_lesser",
    "skeletal_warrior_greater",
    "skeletal_rogue",
    "skeletal_mage",
    "ghoul",
    "crypt_fiend",
    "abomination",
    "decaying_colossus",
}

local PERMANENT_SET = {}
for i, id in ipairs(PERMANENT_ORDER) do
    PERMANENT_SET[id] = i
end

-- Ascension: Friends is the master switch for pet plates. Enable Friends + Pets
-- (+ Guardians). Never force nameplateShowAll off — that kills Ascension plates.
local NAMEPLATE_CVARS = {
    "nameplateShowFriends",
    "nameplateShowFriendlyGuardians",
    "nameplateShowFriendlyPets",
}

local NAMEPLATE_ENABLE = {
    nameplateShowFriends = "1",
    nameplateShowFriendlyGuardians = "1",
    nameplateShowFriendlyPets = "1",
}

local SHORT_LABEL = {
    skeletal_warrior_lesser = "L. Skel",
    skeletal_warrior_greater = "G. Skel",
    skeletal_rogue = "Rogue",
    skeletal_mage = "Mage",
    ghoul = "Ghoul",
    crypt_fiend = "Fiend",
    abomination = "Abom",
    decaying_colossus = "Colossus",
}

local function GuidsMatch(a, b)
    if not a or not b then
        return false
    end
    if a == b then
        return true
    end
    local Advisor = Mancer.NecromancerAdvisor or Mancer.NecromancerAdvisorModule
    if Advisor and Advisor.GuidsMatch then
        return Advisor:GuidsMatch(a, b)
    end
    return tostring(a):lower() == tostring(b):lower()
end

-- Shared with Minion Sheet (Bone Ward / temp HP max staleness).
function Mancer.Util.ReadUnitHealth(unit)
    local health = tonumber(UnitHealth and UnitHealth(unit)) or 0
    local healthMax = tonumber(UnitHealthMax and UnitHealthMax(unit)) or 0
    local guid = UnitGUID and UnitGUID(unit)

    if guid and UnitHealthMax then
        local function consider(token)
            if not token or not UnitName or not UnitName(token) then
                return
            end
            if not GuidsMatch(UnitGUID(token), guid) then
                return
            end
            local maxHp = tonumber(UnitHealthMax(token)) or 0
            if maxHp > healthMax then
                healthMax = maxHp
            end
            local cur = tonumber(UnitHealth and UnitHealth(token)) or 0
            if cur > health then
                health = cur
            end
        end

        for _, token in ipairs({ "target", "mouseover", "focus", "pet" }) do
            consider(token)
        end
        for i = 1, 40 do
            consider("nameplate" .. i)
        end
    end

    if healthMax < 1 and health > 0 then
        healthMax = health
    elseif health > healthMax then
        healthMax = health
    end

    return health, healthMax
end

local function FeatureEnabled()
    return MancerDB and MancerDB.showMinionHpList == true
end

local function HideVisualsEnabled()
    if Mancer.IsPlateNamesOnlyEnabled then
        return Mancer.IsPlateNamesOnlyEnabled()
    end
    return MancerDB and MancerDB.hideMinionHpNameplateVisuals ~= false
end

local function GetAdvisor()
    return Mancer.NecromancerAdvisor or Mancer.NecromancerAdvisorModule
end

local function SheetHasNameplateBoost()
    local sheet = Mancer.MinionSheetModule
    return sheet and sheet.nameplateCvarBackup ~= nil
end

--- Names-only styles whatever plates are already visible — never forces CVars on.
--- Paused while Minion Sheet is open: stripping bars interferes with Ascension
--- nameplate→unit binding (sheet would stick on "waiting for unit").
local function ShouldApplyNamesOnly()
    if not HideVisualsEnabled() then
        return false
    end
    local sheet = Mancer.MinionSheetModule
    if sheet and sheet.nameplateCvarBackup then
        return false
    end
    if sheet and sheet.frame and sheet.frame.IsShown and sheet.frame:IsShown() then
        return false
    end
    return true
end

local function BackupIsForcedOn(backup)
    if not backup then
        return false
    end
    for key, enable in pairs(NAMEPLATE_ENABLE) do
        if backup[key] == nil or tostring(backup[key]) ~= tostring(enable) then
            return false
        end
    end
    return true
end

local function FormatHp(n)
    n = math.floor(tonumber(n) or 0)
    if n >= 1000000 then
        return string.format("%.1fm", n / 1000000)
    end
    if n >= 10000 then
        return string.format("%.1fk", n / 1000)
    end
    return tostring(n)
end

-- pct 1.0 → green; pct ≤ 0.30 → red; smooth fade between.
local function HpBarColor(pct)
    pct = tonumber(pct) or 0
    if pct < 0 then
        pct = 0
    elseif pct > 1 then
        pct = 1
    end
    if pct <= HP_RED_PCT then
        return 0.95, 0.18, 0.12
    end
    local t = (pct - HP_RED_PCT) / (1 - HP_RED_PCT)
    -- lerp red → green
    local r = 0.95 + (0.28 - 0.95) * t
    local g = 0.18 + (0.88 - 0.18) * t
    local b = 0.12 + (0.28 - 0.12) * t
    return r, g, b
end

-- Minion HP bar skins in LibellusLeti/MinionBarTextures (no .blp suffix for SetTexture).
local ADDON_FOLDER = (Mancer and Mancer.ADDON_FOLDER) or "LibellusLeti"
local MINION_BAR_DIR = "Interface\\AddOns\\" .. ADDON_FOLDER .. "\\MinionBarTextures\\"
local MINION_BAR_TEXTURES = {
    MINION_BAR_DIR .. "abstract",
    MINION_BAR_DIR .. "Leaves",
    MINION_BAR_DIR .. "Runes",
    MINION_BAR_DIR .. "static",
}
local MINION_BAR_NAMES = {
    "Abstract",
    "Leaves",
    "Runes",
    "Static",
}
local HP_BAR_FILL_FALLBACK = "Interface\\Buttons\\WHITE8X8"

local function NormalizeMinionHpBarIndex(idx)
    idx = tonumber(idx) or 1
    if idx < 1 then
        idx = 1
    elseif idx > #MINION_BAR_TEXTURES then
        idx = #MINION_BAR_TEXTURES
    end
    return idx
end

local function GetMinionHpBarTexture()
    local idx = NormalizeMinionHpBarIndex(MancerDB and MancerDB.minionHpBarTextureIndex)
    return MINION_BAR_TEXTURES[idx] or MINION_BAR_TEXTURES[1]
end

function MinionHpHud:GetBarTextureName()
    local idx = NormalizeMinionHpBarIndex(MancerDB and MancerDB.minionHpBarTextureIndex)
    return MINION_BAR_NAMES[idx] or MINION_BAR_NAMES[1]
end

function MinionHpHud:CycleBarTexture(delta)
    MancerDB = MancerDB or {}
    local idx = NormalizeMinionHpBarIndex(MancerDB.minionHpBarTextureIndex)
    idx = idx + (tonumber(delta) or 1)
    if idx > #MINION_BAR_TEXTURES then
        idx = 1
    elseif idx < 1 then
        idx = #MINION_BAR_TEXTURES
    end
    MancerDB.minionHpBarTextureIndex = idx
    self:ApplyBarTextures()
    self:Refresh(true)
    return self:GetBarTextureName()
end

function MinionHpHud:IsPermanentMinionId(minionId)
    return PERMANENT_SET[minionId] ~= nil
end

function MinionHpHud:BoostNameplates()
    if Mancer.IsCapitalNameplateMuteActive and Mancer.IsCapitalNameplateMuteActive() then
        return
    end
    if not SetCVar then
        return
    end
    -- Contaminated backup (all "1") from nesting under Sheet — drop it.
    if BackupIsForcedOn(self.nameplateCvarBackup) then
        self.nameplateCvarBackup = nil
    end
    -- Already boosted — only touch CVars that drifted.
    if self.nameplateCvarBackup then
        for key, enable in pairs(NAMEPLATE_ENABLE) do
            local ok, cur = pcall(GetCVar, key)
            if ok and cur ~= nil and tostring(cur) ~= tostring(enable) then
                pcall(SetCVar, key, enable)
            end
        end
        return
    end
    local backup = {}
    local changed = false
    for i = 1, #NAMEPLATE_CVARS do
        local key = NAMEPLATE_CVARS[i]
        local ok, val = pcall(GetCVar, key)
        if ok and val ~= nil then
            backup[key] = val
            local enable = NAMEPLATE_ENABLE[key]
            if enable ~= nil and tostring(val) ~= tostring(enable) then
                changed = true
                pcall(SetCVar, key, enable)
            end
        end
    end
    -- Only keep a backup when we flipped something off→on. If plates were already
    -- on (e.g. Sheet boost), do not snapshot "1" as the user's preference.
    if changed and next(backup) then
        self.nameplateCvarBackup = backup
        if Mancer.PersistNameplateCvarBackup then
            Mancer.PersistNameplateCvarBackup(backup)
        end
    end
end

function MinionHpHud:RestoreNameplates()
    if not self.nameplateCvarBackup or not SetCVar then
        self.nameplateCvarBackup = nil
        return
    end
    -- Never "restore" forced-on values (re-enables plates after Sheet close).
    if BackupIsForcedOn(self.nameplateCvarBackup) then
        self.nameplateCvarBackup = nil
        if Mancer.ClearPersistedNameplateCvarBackup then
            Mancer.ClearPersistedNameplateCvarBackup()
        end
        return
    end
    for key, val in pairs(self.nameplateCvarBackup) do
        pcall(SetCVar, key, val)
    end
    self.nameplateCvarBackup = nil
    if Mancer.ClearPersistedNameplateCvarBackup then
        Mancer.ClearPersistedNameplateCvarBackup()
    end
end

function MinionHpHud:CollectNamePlateFrames()
    local frames = {}
    local seen = {}

    local function add(frame)
        if frame and not seen[frame] then
            seen[frame] = true
            frames[#frames + 1] = frame
        end
    end

    for i = 1, 40 do
        add(_G["NamePlate" .. i])
        add(_G["NamePlate" .. i .. "UnitFrame"])
        add(_G["NamePlateDriverFramePoolFrameNamePlateUnitFrameTemplate" .. i])
    end

    if C_NamePlate and C_NamePlate.GetNamePlates then
        local ok, plates = pcall(C_NamePlate.GetNamePlates)
        if ok and type(plates) == "table" then
            for _, plate in ipairs(plates) do
                add(plate)
                if plate.UnitFrame then
                    add(plate.UnitFrame)
                end
            end
        end
    end

    if WorldFrame and WorldFrame.GetChildren then
        local children = { WorldFrame:GetChildren() }
        for i = 1, #children do
            local f = children[i]
            if f and f.GetName then
                local name = f:GetName()
                if name and tostring(name):find("NamePlate", 1, true) then
                    add(f)
                end
            end
        end
    end

    return frames
end

function MinionHpHud:IsOwnedGuardianUnit(unit)
    if not unit then
        return false
    end
    -- Need a readable plate (Ascension: UnitName often works while UnitExists is false).
    -- Do NOT bail on UnitCanAttack — Ascension often flags your own undead as attackable.
    if not ((UnitName and UnitName(unit)) or (UnitExists and UnitExists(unit))) then
        return false
    end
    local Advisor = GetAdvisor()
    if Advisor and Advisor.IsOwnedByPlayer then
        return Advisor:IsOwnedByPlayer(unit) and true or false
    end
    return false
end

-- Creature / pet / vehicle GUIDs (hex 0xF13… or retail-style Creature-…).
function MinionHpHud:GuidLooksLikeCreature(guid)
    if not guid then
        return false
    end
    local g = tostring(guid):lower()
    if g:find("^creature") or g:find("^vehicle") or g:find("^pet%-") or g:find("^pet:") then
        return true
    end
    if g:find("^0xf1") or g:find("^0x0000f1") then
        return true
    end
    -- Hex tail anywhere (CLEU Creature-0-…-0xF130…).
    local hex = g:match("0x(%x+)$") or g:match("0x(%x+)")
    if hex and (hex:find("^f1") or hex:find("^0000f1")) then
        return true
    end
    local Advisor = GetAdvisor()
    if Advisor and Advisor.ClassifyByGuid and Advisor:ClassifyByGuid(guid) then
        return true
    end
    return false
end

function MinionHpHud:GuidLooksLikePlayer(guid)
    if not guid then
        return false
    end
    local g = tostring(guid):lower()
    if g:find("^player") then
        return true
    end
    if self:GuidLooksLikeCreature(guid) then
        return false
    end
    local hex = g:match("0x(%x+)$") or (g:find("^0x") and g:match("^0x(%x+)$"))
    if hex and hex:find("^0") and not hex:find("^f1") and not hex:find("^0000f1") then
        return true
    end
    return false
end

local function ColorNearClass(r, g, b)
    if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then
        return false
    end
    local function near(c)
        if not c then
            return false
        end
        local cr, cg, cb = c.r, c.g, c.b
        if type(cr) ~= "number" then
            return false
        end
        return math.abs(cr - r) < 0.03
            and math.abs((cg or 0) - g) < 0.03
            and math.abs((cb or 0) - b) < 0.03
    end
    if CUSTOM_CLASS_COLORS then
        for _, c in pairs(CUSTOM_CLASS_COLORS) do
            if near(c) then
                return true
            end
        end
    end
    if RAID_CLASS_COLORS then
        for _, c in pairs(RAID_CLASS_COLORS) do
            if near(c) then
                return true
            end
        end
    end
    return false
end

-- Blizzard/Ascension player plates often use class-colored health bars.
function MinionHpHud:FrameHasClassColoredHealth(frame, depth)
    if not frame or (depth or 0) > 6 then
        return false
    end
    if frame.GetObjectType and frame:GetObjectType() == "StatusBar" and frame.GetStatusBarColor then
        local ok, r, g, b = pcall(frame.GetStatusBarColor, frame)
        if ok and ColorNearClass(r, g, b) then
            return true
        end
    end
    if frame.GetNumChildren then
        local n = frame:GetNumChildren() or 0
        for i = 1, n do
            local child = select(i, frame:GetChildren())
            if child and self:FrameHasClassColoredHealth(child, (depth or 0) + 1) then
                return true
            end
        end
    end
    return false
end

-- Ascension: UnitIsPlayer / UnitGUID often lie or are nil on nameplate tokens.
function MinionHpHud:PlateUnitIsPlayer(unit)
    if not unit then
        return false
    end
    if UnitIsPlayer and UnitIsPlayer(unit) then
        return true
    end

    local guid = UnitGUID and UnitGUID(unit)
    if guid then
        if self:GuidLooksLikePlayer(guid) then
            return true
        end
        if self:GuidLooksLikeCreature(guid) then
            return false
        end
    end

    -- Race + player-controlled, not a minion name, not a creature GUID.
    -- (Class-colored bar fallback is applied in ScanAndApplyNamesOnly — avoid
    -- CollectFramesForUnit here; it is too heavy inside ClassifyPlateUnit.)
    local name = UnitName and UnitName(unit)
    local Advisor = GetAdvisor()
    if Advisor and Advisor.ClassifyMinionName and name and name ~= "" then
        if Advisor:ClassifyMinionName(name) then
            return false
        end
    end

    local raceFile = UnitRace and select(2, UnitRace(unit))
    local classFile = UnitClass and select(2, UnitClass(unit))
    if type(raceFile) == "string" and raceFile ~= "" then
        if UnitPlayerControlled and UnitPlayerControlled(unit) then
            return true
        end
        -- No GUID (Ascension): race+class is almost always a player plate.
        if not guid and type(classFile) == "string" and classFile ~= "" then
            return true
        end
    end

    return false
end

-- guardians | players | npcs | enemies | nil
function MinionHpHud:ClassifyPlateUnit(unit)
    if not unit then
        return nil
    end
    if UnitIsUnit and UnitIsUnit(unit, "player") then
        return nil
    end
    if not ((UnitName and UnitName(unit)) or (UnitExists and UnitExists(unit))) then
        return nil
    end

    -- Own undead first (Ascension often flags them UnitCanAttack).
    if self:IsOwnedGuardianUnit(unit) then
        return "guardians"
    end
    if UnitIsUnit and UnitIsUnit(unit, "pet") then
        return "guardians"
    end

    -- Players before enemy checks. UnitIsPlayer alone misses many Ascension plates.
    if self:PlateUnitIsPlayer(unit) then
        return "players"
    end

    local isEnemy = (UnitCanAttack and UnitCanAttack("player", unit))
        or (UnitIsEnemy and UnitIsEnemy("player", unit))
    if isEnemy then
        return "enemies"
    end

    -- Friendly plates whose name matches a Raise/Animate minion (e.g. plain "Ghoul"
    -- without ownership subtitle) — still Guardians for names-only.
    local name = UnitName and UnitName(unit)
    local Advisor = GetAdvisor()
    if Advisor and Advisor.ClassifyMinionName and name and name ~= "" then
        local mid = Advisor:ClassifyMinionName(name)
        if mid and mid ~= "lesser_zombie" then
            return "guardians"
        end
    end

    return "npcs"
end

-- Debug: /leti plates — print how each visible plate is classified.
function MinionHpHud:PrintPlateClassifyDebug()
    local prefix = "|cff7fd4ff" .. (Mancer.DISPLAY_NAME or "Libellus Leti") .. "|r "
    local t = Mancer.GetPlateNamesOnlyTargets and Mancer.GetPlateNamesOnlyTargets() or {}
    print(prefix .. "nameplate classify (targets g="
        .. (t.guardians and "1" or "0")
        .. " p=" .. (t.players and "1" or "0")
        .. " n=" .. (t.npcs and "1" or "0")
        .. " e=" .. (t.enemies and "1" or "0") .. "):")
    local n = 0
    for i = 1, 40 do
        local unit = "nameplate" .. i
        local name = UnitName and UnitName(unit)
        if name and name ~= "" then
            n = n + 1
            local class = self:ClassifyPlateUnit(unit) or "?"
            local guid = UnitGUID and UnitGUID(unit)
            local guidShort = guid and tostring(guid):sub(1, 28) or "nil"
            local isP = (UnitIsPlayer and UnitIsPlayer(unit)) and "1" or "0"
            local atk = (UnitCanAttack and UnitCanAttack("player", unit)) and "1" or "0"
            local frames = self:CollectFramesForUnit(unit)
            local bars = 0
            for fi = 1, #frames do
                if FrameHasStatusBars(frames[fi]) then
                    bars = bars + 1
                end
            end
            local want = self:ShouldNamesOnlyUnit(unit) and "1" or "0"
            print(string.format(
                "  %s | %s | class=%s want=%s frames=%d bars=%d IsPlayer=%s atk=%s guid=%s",
                unit, name, class, want, #frames, bars, isP, atk, guidShort
            ))
        end
    end
    if n == 0 then
        print(prefix .. "no nameplate units with names (enable friendly plates / get closer).")
    end
end

function MinionHpHud:ShouldNamesOnlyUnit(unit)
    -- Minion Sheet needs intact guardian plates to bind unit tokens (Ascension).
    local sheet = Mancer.MinionSheetModule
    if sheet and sheet.nameplateCvarBackup then
        return false
    end
    if sheet and sheet.frame and sheet.frame.IsShown and sheet.frame:IsShown() then
        return false
    end
    local class = self:ClassifyPlateUnit(unit)
    if not class then
        return false
    end
    local t = Mancer.GetPlateNamesOnlyTargets and Mancer.GetPlateNamesOnlyTargets()
    if not t then
        return false
    end
    return t[class] and true or false
end

-- Any friendly plate (players, pets, NPCs) — used for visual hide while Friends are on.
function MinionHpHud:IsFriendlyPlateUnit(unit)
    if not unit then
        return false
    end
    if UnitIsUnit and UnitIsUnit(unit, "player") then
        return false
    end
    if not ((UnitName and UnitName(unit)) or (UnitExists and UnitExists(unit))) then
        return false
    end
    if UnitCanAttack and UnitCanAttack("player", unit) then
        return false
    end
    if UnitIsEnemy and UnitIsEnemy("player", unit) then
        return false
    end
    if UnitIsFriend then
        return UnitIsFriend("player", unit) and true or false
    end
    return true
end

local function FrameHasStatusBars(frame, depth)
    if not frame or (depth or 0) > 6 then
        return false
    end
    if frame.GetObjectType and frame:GetObjectType() == "StatusBar" then
        return true
    end
    if frame.GetNumChildren then
        local n = frame:GetNumChildren() or 0
        for i = 1, n do
            local child = select(i, frame:GetChildren())
            if child and FrameHasStatusBars(child, (depth or 0) + 1) then
                return true
            end
        end
    end
    return false
end

local function GuidsEqual(a, b)
    if not a or not b then
        return false
    end
    if a == b then
        return true
    end
    local ka = tostring(a):lower():match("0x(%x+)$") or tostring(a):lower()
    local kb = tostring(b):lower():match("0x(%x+)$") or tostring(b):lower()
    return ka == kb
end

--- Ascension: GetNamePlateForUnit returns an unnamed base; bars live on the pool UnitFrame.
--- Collect EVERY related frame — stripping only one sibling leaves bars visible on another,
--- and the next scan was restoring the "extra" frame (partial Players names-only).
function MinionHpHud:CollectFramesForUnit(unit)
    local list = {}
    local seen = {}
    local function add(frame)
        if frame and not seen[frame] then
            seen[frame] = true
            list[#list + 1] = frame
        end
    end

    if not unit then
        return list
    end

    local Advisor = GetAdvisor()
    add(Advisor and Advisor.GetNamePlateFrameForUnit and Advisor:GetNamePlateFrameForUnit(unit))
    if C_NamePlate and C_NamePlate.GetNamePlateForUnit then
        local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
        if ok then
            add(plate)
            if plate and plate.UnitFrame then
                add(plate.UnitFrame)
            end
        end
    end

    local idx = tostring(unit):match("^nameplate(%d+)$")
    if idx then
        local base = _G["NamePlate" .. idx]
        add(base)
        if base then
            add(base.UnitFrame)
            add(_G["NamePlate" .. idx .. "UnitFrame"])
            if base.GetNumChildren then
                local n = base:GetNumChildren() or 0
                for i = 1, n do
                    local child = select(i, base:GetChildren())
                    if child and FrameHasStatusBars(child) then
                        add(child)
                    end
                end
            end
        end
    end

    local wantGuid = UnitGUID and UnitGUID(unit)
    for i = 1, 40 do
        local f = _G["NamePlateDriverFramePoolFrameNamePlateUnitFrameTemplate" .. i]
        if f then
            local u = f.unit or f.displayedUnit or f.namePlateUnitToken
            if u == unit then
                add(f)
            elseif wantGuid and u and UnitGUID and GuidsEqual(UnitGUID(u), wantGuid) then
                add(f)
            end
        end
    end

    -- Center-proximity: Ascension often floats the UnitFrame next to an empty NamePlate base.
    local anchor = list[1] or (idx and _G["NamePlate" .. idx])
    local bx, by = anchor and anchor.GetCenter and anchor:GetCenter()
    if bx and by then
        for i = 1, 40 do
            local f = _G["NamePlateDriverFramePoolFrameNamePlateUnitFrameTemplate" .. i]
            if f and f.IsShown and f:IsShown() and FrameHasStatusBars(f) and f.GetCenter then
                local fx, fy = f:GetCenter()
                if fx and fy and math.abs(fx - bx) < 40 and math.abs(fy - by) < 40 then
                    add(f)
                end
            end
        end
    end

    return list
end

function MinionHpHud:GetPlateUnitFrame(unit)
    local frames = self:CollectFramesForUnit(unit)
    for i = 1, #frames do
        if FrameHasStatusBars(frames[i]) then
            return frames[i]
        end
    end
    return frames[1]
end

--- Names-only (rebuild from 0.9.472 working approach).
--- Hide StatusBars + textures + chrome frames; keep FontString name text.
--- Ascension re-Shows bars on camera move — cloak driver reasserts every frame.

local CHROME_NAME_HINTS = {
    "raidtarget", "raidicon", "castbar", "castframe", "levelframe", "leveltext",
    "classification", "threat", "aggro", "bossicon", "questicon", "elite",
    "healthbar", "powerbar", "secondarypower", "badge", "star", "rare",
}

local function RegionDebugName(region)
    local name = ""
    if region and region.GetName then
        local ok, n = pcall(region.GetName, region)
        if ok and type(n) == "string" then
            name = n
        end
    end
    if name == "" and region and region.GetDebugName then
        local ok, n = pcall(region.GetDebugName, region)
        if ok and type(n) == "string" then
            name = n
        end
    end
    if name == "" then
        return ""
    end
    local ok, lower = pcall(string.lower, name)
    if ok and type(lower) == "string" then
        return lower
    end
    return name
end

local function FrameLooksLikeChrome(frame)
    local name = RegionDebugName(frame)
    if name == "" then
        return false
    end
    for i = 1, #CHROME_NAME_HINTS do
        if name:find(CHROME_NAME_HINTS[i], 1, true) then
            return true
        end
    end
    return false
end

-- Strip |cAARRGGBB / |r so colored "60" still counts as a level.
local function StripUiEscapeCodes(text)
    if type(text) ~= "string" then
        return ""
    end
    local ok, out = pcall(function()
        local t = text:gsub("|c%x%x%x%x%x%x%x%x", "")
        t = t:gsub("|r", "")
        if strtrim then
            return strtrim(t)
        end
        return t:match("^%s*(.-)%s*$") or t
    end)
    if ok and type(out) == "string" then
        return out
    end
    return text
end

local function FontStringLooksLikeLevelOnly(region)
    if not region or not region.GetText then
        return false
    end
    -- Dedicated level widgets only (avoid GetDebugName paths that mention "framelevel").
    local debugName = RegionDebugName(region)
    if debugName ~= "" then
        if debugName:find("leveltext", 1, true)
            or debugName:find("levelframe", 1, true)
            or debugName == "level"
            or debugName:match("%.level$")
            or debugName:match("_level$") then
            return true
        end
    end
    local ok, text = pcall(region.GetText, region)
    if not ok or type(text) ~= "string" then
        return false
    end
    text = StripUiEscapeCodes(text)
    if text == "" then
        return false
    end
    -- Bare level, elite "+60", skull "??" / "?".
    if text:match("^%d%d?%d?$") then
        return true
    end
    if text:match("^%+%d%d?%d?$") then
        return true
    end
    if text == "?" or text == "??" then
        return true
    end
    return false
end

-- Mark + hide; restore uses the mark so we only re-show what we hid.
local function HideForNamesOnly(region)
    if not region then
        return
    end
    if region.mancerNO == nil then
        local shown = false
        local alpha = 1
        if region.IsShown then
            local ok, v = pcall(region.IsShown, region)
            shown = ok and v and true or false
        end
        if region.GetAlpha then
            local ok, v = pcall(region.GetAlpha, region)
            if ok and type(v) == "number" then
                alpha = v
            end
        end
        region.mancerNO = { shown = shown, alpha = alpha }
    elseif region.mancerNO.hidden then
        -- Already stripped — only act if Ascension re-Showed it.
        if region.IsShown then
            local ok, shown = pcall(region.IsShown, region)
            if not (ok and shown) then
                return
            end
        else
            return
        end
    end
    if region.Hide then
        pcall(region.Hide, region)
    end
    if region.SetAlpha then
        pcall(region.SetAlpha, region, 0)
    end
    region.mancerNO.hidden = true
end

local function RestoreFromNamesOnly(region)
    if not region then
        return
    end
    local saved = region.mancerNO
    if not saved then
        return
    end
    if region.SetAlpha then
        region:SetAlpha(saved.alpha or 1)
    end
    if saved.shown and region.Show then
        region:Show()
    elseif region.Hide then
        region:Hide()
    end
    region.mancerNO = nil
end

-- Cheap pass: only re-hide marked regions Ascension re-Showed (no full tree strip).
local function QuickRehideNamesOnly(frame, depth)
    if not frame or (depth or 0) > 6 then
        return
    end
    if frame.mancerNO then
        HideForNamesOnly(frame)
    end
    if frame.GetNumRegions then
        local n = frame:GetNumRegions() or 0
        for i = 1, n do
            local region = select(i, frame:GetRegions())
            if region and region.mancerNO then
                HideForNamesOnly(region)
            end
        end
    end
    if frame.GetNumChildren then
        local n = frame:GetNumChildren() or 0
        for i = 1, n do
            local child = select(i, frame:GetChildren())
            if child then
                QuickRehideNamesOnly(child, (depth or 0) + 1)
            end
        end
    end
end

--- Recursive strip — same idea as the working /run + 0.9.472, but walks nested children
--- so nested healthBars and the gold level/star chrome are caught.
local function StripNamesOnlyArt(frame, depth)
    if not frame or (depth or 0) > 12 then
        return
    end
    if frame.mancerSyntheticOwner or frame.mancerOwnerTag == frame then
        return
    end

    local ot = frame.GetObjectType and frame:GetObjectType() or ""

    if ot == "StatusBar" then
        HideForNamesOnly(frame)
        return
    end

    -- Gold level / star / cast / raid chrome frames (often not StatusBars).
    -- Frames only — Buttons can be protected on Ascension and abort the whole strip.
    if (depth or 0) > 0 and ot == "Frame" and FrameLooksLikeChrome(frame) then
        HideForNamesOnly(frame)
        return
    end

    -- Unnamed short wide frames (gold level/star strip under the name).
    if (depth or 0) > 0 and ot == "Frame" and frame.GetHeight and frame.GetWidth then
        local h = frame:GetHeight() or 0
        local w = frame:GetWidth() or 0
        if h >= 1.5 and h <= 28 and w >= 24 then
            local hasNameText = false
            if frame.GetNumRegions then
                local rn = frame:GetNumRegions() or 0
                for i = 1, rn do
                    local region = select(i, frame:GetRegions())
                    if region and region.GetObjectType and region:GetObjectType() == "FontString"
                        and not FontStringLooksLikeLevelOnly(region) then
                        local ok, text = pcall(region.GetText, region)
                        if ok and type(text) == "string" and text ~= "" then
                            hasNameText = true
                            break
                        end
                    end
                end
            end
            if not hasNameText then
                HideForNamesOnly(frame)
                return
            end
        end
    end

    if frame.GetNumRegions then
        local n = frame:GetNumRegions() or 0
        for i = 1, n do
            local region = select(i, frame:GetRegions())
            if region and region.GetObjectType then
                local ty = region:GetObjectType()
                if ty == "Texture" then
                    HideForNamesOnly(region)
                elseif ty == "FontString" and not region.mancerSyntheticOwner then
                    if FontStringLooksLikeLevelOnly(region) then
                        HideForNamesOnly(region)
                    else
                        if region.Show then
                            region:Show()
                        end
                        if region.SetAlpha then
                            region:SetAlpha(1)
                        end
                    end
                end
            end
        end
    end

    if frame.GetNumChildren then
        local n = frame:GetNumChildren() or 0
        for i = 1, n do
            local child = select(i, frame:GetChildren())
            if child and child ~= frame.mancerOwnerTag then
                StripNamesOnlyArt(child, (depth or 0) + 1)
            end
        end
    end
end

local function RestoreNamesOnlyArt(frame, depth)
    if not frame or (depth or 0) > 12 then
        return
    end
    RestoreFromNamesOnly(frame)
    if frame.GetNumRegions then
        local n = frame:GetNumRegions() or 0
        for i = 1, n do
            RestoreFromNamesOnly(select(i, frame:GetRegions()))
        end
    end
    if frame.GetNumChildren then
        local n = frame:GetNumChildren() or 0
        for i = 1, n do
            local child = select(i, frame:GetChildren())
            if child then
                RestoreNamesOnlyArt(child, (depth or 0) + 1)
            end
        end
    end
end

function MinionHpHud:ApplyNamesOnlyToFrame(frame, unit)
    if not frame then
        return
    end
    self.namesOnlyFrames = self.namesOnlyFrames or {}
    self.namesOnlyFrames[frame] = true
    frame.mancerNamesOnlyUnit = unit
    pcall(StripNamesOnlyArt, frame, 0)
end

function MinionHpHud:RestoreNamesOnlyFrame(frame)
    if not frame then
        return
    end
    RestoreNamesOnlyArt(frame, 0)
    frame.mancerNamesOnlyUnit = nil
end

function MinionHpHud:ApplyNamesOnlyToUnit(unit)
    if not unit or not self:ShouldNamesOnlyUnit(unit) then
        return
    end
    local uf = self:GetPlateUnitFrame(unit)
    if uf then
        self:ApplyNamesOnlyToFrame(uf, unit)
    end
end

function MinionHpHud:ReassertNamesOnly()
    local frames = self.namesOnlyFrames
    if not frames then
        return
    end
    for frame in pairs(frames) do
        if frame then
            pcall(QuickRehideNamesOnly, frame, 0)
        else
            frames[frame] = nil
        end
    end
end

function MinionHpHud:ScanAndApplyNamesOnly()
    local keep = {}

    local function mark(frame, unit)
        if not frame then
            return
        end
        self:ApplyNamesOnlyToFrame(frame, unit)
        keep[frame] = true
    end

    local function applyUnit(unit)
        if not unit then
            return
        end
        local want = self:ShouldNamesOnlyUnit(unit)
        if not want then
            local t = Mancer.GetPlateNamesOnlyTargets and Mancer.GetPlateNamesOnlyTargets()
            if t and t.players and not self:IsOwnedGuardianUnit(unit) then
                local frames = self:CollectFramesForUnit(unit)
                for i = 1, #frames do
                    if self:FrameHasClassColoredHealth(frames[i]) then
                        want = true
                        break
                    end
                end
            end
        end
        if not want then
            return
        end
        local frames = self:CollectFramesForUnit(unit)
        for i = 1, #frames do
            mark(frames[i], unit)
        end
    end

    for i = 1, 40 do
        applyUnit("nameplate" .. i)
    end

    if C_NamePlate and C_NamePlate.GetNamePlates then
        local ok, plates = pcall(C_NamePlate.GetNamePlates)
        if ok and type(plates) == "table" then
            for i = 1, #plates do
                local plate = plates[i]
                local unit = plate and (plate.namePlateUnitToken or plate.unit or plate.displayedUnit)
                if (not unit or unit == "") and plate and plate.UnitFrame then
                    local uf = plate.UnitFrame
                    unit = uf.unit or uf.displayedUnit or uf.namePlateUnitToken
                end
                if type(unit) == "string" and unit ~= "" then
                    applyUnit(unit)
                else
                    local t = Mancer.GetPlateNamesOnlyTargets and Mancer.GetPlateNamesOnlyTargets()
                    if t and t.players and plate and self:FrameHasClassColoredHealth(plate) then
                        mark(plate, nil)
                        if plate.UnitFrame then
                            mark(plate.UnitFrame, nil)
                        end
                    end
                end
            end
        end
    end

    -- Frame-first: catch pool / WorldFrame plates whose unit token we would otherwise miss.
    local allFrames = self:CollectNamePlateFrames()
    for i = 1, #allFrames do
        local f = allFrames[i]
        if f and f.IsShown and f:IsShown() then
            local unit = f.unit or f.displayedUnit or f.namePlateUnitToken
            if (not unit or unit == "") and f.GetName then
                local ok, n = pcall(f.GetName, f)
                if ok and type(n) == "string" then
                    local idx = n:match("NamePlate(%d+)")
                    if idx then
                        unit = "nameplate" .. idx
                    end
                end
            end
            if type(unit) == "string" and unit ~= "" then
                if self:ShouldNamesOnlyUnit(unit) then
                    mark(f, unit)
                end
            else
                local t = Mancer.GetPlateNamesOnlyTargets and Mancer.GetPlateNamesOnlyTargets()
                if t and t.players and self:FrameHasClassColoredHealth(f) then
                    mark(f, nil)
                end
            end
        end
    end

    -- Never restore a frame that still belongs to a names-only unit (sibling thrash bug).
    if self.namesOnlyFrames then
        for frame in pairs(self.namesOnlyFrames) do
            if not keep[frame] then
                local u = frame.mancerNamesOnlyUnit
                if u and self:ShouldNamesOnlyUnit(u) then
                    mark(frame, u)
                else
                    self:RestoreNamesOnlyFrame(frame)
                end
            end
        end
    end
    self.namesOnlyFrames = keep
end

function MinionHpHud:ApplyNameplateVisualHide()
    if not ShouldApplyNamesOnly() then
        self:ClearNameplateVisualHide()
        return
    end
    self:ScanAndApplyNamesOnly()
    self:UpdateCloakDriver()
end

function MinionHpHud:ClearNameplateVisualHide()
    if self.cloakDriver then
        self.cloakDriver:Hide()
    end
    if self.namesOnlyFrames then
        for frame in pairs(self.namesOnlyFrames) do
            self:RestoreNamesOnlyFrame(frame)
        end
        self.namesOnlyFrames = nil
    end
    if self.hiddenPlateFrames then
        for frame, alpha in pairs(self.hiddenPlateFrames) do
            if frame and frame.SetAlpha then
                pcall(frame.SetAlpha, frame, alpha or 1)
            end
        end
        self.hiddenPlateFrames = nil
    end
end

-- Always-on while names-only is active (Ascension re-shows bars on move/camera).
function MinionHpHud:EnsureCloakDriver()
    if self.cloakDriver then
        return
    end
    local driver = CreateFrame("Frame", "MancerMinionPlateCloakDriver")
    driver:Hide()
    driver.scanElapsed = 0
    driver.reassertElapsed = 0
    driver:SetScript("OnUpdate", function(f, elapsed)
        if not ShouldApplyNamesOnly() then
            f:Hide()
            return
        end
        elapsed = elapsed or 0
        f.reassertElapsed = (f.reassertElapsed or 0) + elapsed
        f.scanElapsed = (f.scanElapsed or 0) + elapsed
        -- Light re-hide (~3/sec) — not a full strip every frame.
        if f.reassertElapsed >= CLOAK_REASSERT_INTERVAL then
            f.reassertElapsed = 0
            self:ReassertNamesOnly()
        end
        -- Full plate discovery (~2/sec).
        if f.scanElapsed >= CLOAK_SCAN_INTERVAL then
            f.scanElapsed = 0
            self:ScanAndApplyNamesOnly()
        end
    end)
    self.cloakDriver = driver
end

function MinionHpHud:UpdateCloakDriver()
    self:EnsureCloakDriver()
    if ShouldApplyNamesOnly() then
        if not self.cloakDriver:IsShown() then
            self.cloakDriver:Show()
        end
    else
        self.cloakDriver:Hide()
    end
end

function MinionHpHud:SyncNameplateSupport(force)
    local now = GetTime and GetTime() or 0
    if not force and self._nextNameplateSync and now < self._nextNameplateSync then
        if ShouldApplyNamesOnly() then
            self:UpdateCloakDriver()
        end
        return
    end
    self._nextNameplateSync = now + NAMEPLATE_SYNC_INTERVAL

    if Mancer.IsCapitalNameplateMuteActive and Mancer.IsCapitalNameplateMuteActive() then
        -- Capitals own plate CVars for FPS; do not boost Friends over the mute.
        if self.nameplateCvarBackup then
            self.nameplateCvarBackup = nil
            if Mancer.ClearPersistedNameplateCvarBackup then
                Mancer.ClearPersistedNameplateCvarBackup()
            end
        end
    elseif SheetHasNameplateBoost() then
        -- Sheet owns CVars while open; do not nest HpHud backup or restore under it.
    elseif FeatureEnabled() then
        -- Minion HP bars need friendly plate tokens (Ascension pets/guardians).
        -- Turn Friends + Pets + Guardians on; restore prior CVars when the option is unticked.
        self:BoostNameplates()
    else
        self:RestoreNameplates()
    end

    if ShouldApplyNamesOnly() then
        self:ApplyNameplateVisualHide()
    else
        self:ClearNameplateVisualHide()
    end
end

function MinionHpHud:OnNamePlateUnitAdded(unit)
    if not unit or not ShouldApplyNamesOnly() then
        return
    end
    self:ApplyNamesOnlyToUnit(unit)
    self:UpdateCloakDriver()
end

function MinionHpHud:CollectHpRows()
    local rows = {}
    local Advisor = GetAdvisor()
    if not Advisor then
        return rows
    end

    -- Seeding every tick reshuffles tokens; throttle it with nameplate sync.
    local now = GetTime and GetTime() or 0
    if not self._nextSeed or now >= self._nextSeed then
        self._nextSeed = now + NAMEPLATE_SYNC_INTERVAL
        if Advisor.SeedSummonsFromVisibleUnits then
            Advisor:SeedSummonsFromVisibleUnits(false)
        end
    end

    local seenGuid = {}
    local liveByGuid = {}

    local function addRow(minionId, guid, unit, name)
        if not minionId or not PERMANENT_SET[minionId] then
            return
        end
        if not unit then
            return
        end
        local health, healthMax = Mancer.Util.ReadUnitHealth(unit)
        if not healthMax or healthMax < 1 then
            return
        end
        guid = guid or (UnitGUID and UnitGUID(unit))
        local key = guid and tostring(guid):lower() or nil
        if key then
            if seenGuid[key] then
                return
            end
            seenGuid[key] = true
        end
        local def = Advisor.MINION_TYPES and Advisor.MINION_TYPES[minionId]
        local row = {
            minionId = minionId,
            label = SHORT_LABEL[minionId] or (def and def.label) or minionId,
            guid = guid,
            unit = unit,
            name = name,
            health = health,
            healthMax = healthMax,
            order = PERMANENT_SET[minionId] or 99,
            seenAt = now,
        }
        if key then
            liveByGuid[key] = row
        else
            rows[#rows + 1] = row
        end
    end

    if Advisor.activeSummons then
        for guid, info in pairs(Advisor.activeSummons) do
            if info and PERMANENT_SET[info.minionId] then
                if not (info.expiresAt and info.expiresAt <= now) then
                    local unit = info.unit
                    if not (unit and UnitGUID and GuidsMatch(UnitGUID(unit), guid)) then
                        unit = Advisor.ResolveUnitTokenFromGuid and Advisor:ResolveUnitTokenFromGuid(guid)
                    end
                    if unit and Advisor.IsOwnedByPlayer and Advisor:IsOwnedByPlayer(unit) then
                        info.unit = unit
                        addRow(info.minionId, guid, unit, info.name)
                    end
                end
            end
        end
    end

    -- Visible owned plates not yet in activeSummons (hard ownership only —
    -- soft Ascension fill is done in SeedSummonsFromVisibleUnits with aura caps).
    local function considerUnit(unit)
        if not unit then
            return
        end
        local name = UnitName and UnitName(unit)
        if not name or name == "" then
            return
        end
        if Advisor.IsOwnedByPlayer and not Advisor:IsOwnedByPlayer(unit, name) then
            return
        end
        local guid = UnitGUID and UnitGUID(unit)
        local minionId = (Advisor.ClassifyByGuid and Advisor:ClassifyByGuid(guid))
            or (Advisor.ClassifyMinionName and Advisor:ClassifyMinionName(name))
        if not PERMANENT_SET[minionId] then
            return
        end
        addRow(minionId, guid, unit, name)
    end

    for _, unit in ipairs({ "target", "mouseover", "focus", "pet" }) do
        considerUnit(unit)
    end
    for i = 1, 40 do
        considerUnit("nameplate" .. i)
    end

    -- Sticky cache: keep last HP for a short grace so plate recycle doesn't pop rows.
    self._stickyRows = self._stickyRows or {}
    for key, row in pairs(liveByGuid) do
        self._stickyRows[key] = row
        rows[#rows + 1] = row
    end
    for key, prev in pairs(self._stickyRows) do
        if not liveByGuid[key] then
            local age = now - (prev.seenAt or 0)
            local expected = Advisor.GetExpectedOwnedCount and Advisor:GetExpectedOwnedCount(prev.minionId) or 1
            if expected < 1 then
                -- Aura says we don't have this type — drop other players' leftovers immediately.
                self._stickyRows[key] = nil
            elseif age <= STALE_ROW_SEC and PERMANENT_SET[prev.minionId] then
                rows[#rows + 1] = prev
            else
                self._stickyRows[key] = nil
            end
        end
    end

    table.sort(rows, function(a, b)
        if a.order ~= b.order then
            return a.order < b.order
        end
        local ga = tostring(a.guid or "")
        local gb = tostring(b.guid or "")
        return ga < gb
    end)

    return rows
end

function MinionHpHud:EnsureFrames()
    local needBars = not (self.rows and self.rows[1] and self.rows[1].bar)
    if self.frame and not needBars then
        self:EnsureAlphaSlider()
        return
    end

    local parent = (Mancer.FloatingText and Mancer.FloatingText.anchor) or UIParent
    if not self.frame then
        self.frame = CreateFrame("Frame", "MancerMinionHpHud", parent)
        self.frame:SetSize(HANDLE_SIZE + 4 + LABEL_WIDTH + BAR_WIDTH, ROW_HEIGHT * MAX_ROWS + 4)
        self.frame:SetFrameStrata("LOW")
        self.frame:SetFrameLevel((parent.GetFrameLevel and parent:GetFrameLevel() or 1) + 30)
        self.frame:EnableMouse(false)
        -- Default anchor so the list is never "unpointed" if ApplyLayout is deferred.
        self.frame:SetPoint("TOPLEFT", parent, "CENTER", 90, 20)
        self.frame:Hide()

        -- H handle on the HUD anchor (like A/Z/T), not on the list frame — so it stays
        -- visible in move mode even before rows resolve.
        local handleParent = (Mancer.FloatingText and Mancer.FloatingText.anchor) or self.frame
        self.handle = CreateFrame("Button", "MancerMinionHpHandle", handleParent)
        self.handle:SetSize(HANDLE_SIZE, HANDLE_SIZE)
        -- Above arc yellow handles / α sliders (those sit ~parent+20 and can cover H).
        self.handle:SetFrameLevel((handleParent.GetFrameLevel and handleParent:GetFrameLevel() or 1) + 80)
        self.handle:Hide()
        self.handle:EnableMouse(false)
        self.handle:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
        self.handle:RegisterForDrag("LeftButton")
        self.handle:SetScript("OnMouseDown", function()
            if self.moveMode then
                self.moving = true
                self._dragX, self._dragY = nil, nil
                local uiScale = UIParent:GetEffectiveScale()
                local cx, cy = GetCursorPosition()
                cx, cy = cx / uiScale, cy / uiScale
                -- Offset from cursor to list TOPLEFT (H sits above the list).
                local left, top = self.frame:GetLeft(), self.frame:GetTop()
                if left and top then
                    self.dragOffsetX = left - cx
                    self.dragOffsetY = top - cy
                else
                    local ax, ay = self.handle:GetCenter()
                    self.dragOffsetX = (ax or 0) - cx - (HANDLE_SIZE * 0.5)
                    self.dragOffsetY = (ay or 0) - cy - 4
                end
            end
        end)
        self.handle:SetScript("OnMouseUp", function()
            if self.moving then
                self.moving = false
                self:SaveOffsetFromHandle()
            end
        end)
        self.handle:SetScript("OnDragStart", function()
            -- Ascension sometimes prefers drag scripts on Buttons.
            if self.handle:GetScript("OnMouseDown") then
                self.handle:GetScript("OnMouseDown")(self.handle)
            end
        end)
        self.handle:SetScript("OnDragStop", function()
            if self.handle:GetScript("OnMouseUp") then
                self.handle:GetScript("OnMouseUp")(self.handle)
            end
        end)

        local bg = self.handle:CreateTexture(nil, "ARTWORK")
        bg:SetPoint("TOPLEFT", 1, -1)
        bg:SetPoint("BOTTOMRIGHT", -1, 1)
        bg:SetTexture("Interface\\Buttons\\WHITE8X8")
        bg:SetVertexColor(0.85, 0.55, 0.2, 0.9)
        self.handleBg = bg

        local mark = self.handle:CreateFontString(nil, "OVERLAY")
        if Mancer.Util and Mancer.Util.ApplyFont then
            Mancer.Util.ApplyFont(mark, 12)
        end
        mark:SetPoint("CENTER")
        mark:SetText("H")
        mark:SetTextColor(0, 0, 0, 1)
        self.handleMark = mark
        -- OnUpdate lives on ticker (below) — hiding this frame must not stop scanning.
    end

    self:EnsureAlphaSlider()

    -- Rebuild rows as status bars (migrates old text-only rows after /reload).
    if self.rows then
        for _, old in ipairs(self.rows) do
            if old and old.Hide then
                old:Hide()
            end
            if old and old.frame and old.frame.Hide then
                old.frame:Hide()
            end
        end
    end

    local tex = GetMinionHpBarTexture()
    self.rows = {}
    for i = 1, MAX_ROWS do
        local row = CreateFrame("Frame", nil, self.frame)
        row:SetSize(LABEL_WIDTH + BAR_WIDTH, BAR_HEIGHT)
        row:SetPoint("TOPLEFT", self.frame, "TOPLEFT", HANDLE_SIZE + 4, -(i - 1) * ROW_HEIGHT)
        row:Hide()

        local label = row:CreateFontString(nil, "OVERLAY")
        if Mancer.Util and Mancer.Util.ApplyFont then
            Mancer.Util.ApplyFont(label, 12)
        else
            label:SetFontObject(GameFontHighlightSmall)
        end
        label:SetJustifyH("LEFT")
        label:SetPoint("LEFT", row, "LEFT", 0, 0)
        label:SetWidth(LABEL_WIDTH - 2)
        label:SetTextColor(0.9, 0.92, 0.85, 1)

        -- Dark empty track behind the tinted XPerl fill.
        local track = row:CreateTexture(nil, "BACKGROUND")
        track:SetPoint("LEFT", row, "LEFT", LABEL_WIDTH, 0)
        track:SetSize(BAR_WIDTH, BAR_HEIGHT)
        track:SetTexture(HP_BAR_FILL_FALLBACK)
        track:SetVertexColor(0.08, 0.08, 0.08, 0.9)

        local bar = CreateFrame("StatusBar", nil, row)
        bar:SetPoint("LEFT", row, "LEFT", LABEL_WIDTH, 0)
        bar:SetSize(BAR_WIDTH, BAR_HEIGHT)
        bar:EnableMouse(false)
        bar:SetMinMaxValues(0, 1)
        bar:SetValue(1)
        -- Greyscale skins tint via SetStatusBarColor (green→red HP).
        bar:SetStatusBarTexture(tex)
        local fill = bar:GetStatusBarTexture()
        if fill then
            fill:SetTexture(tex)
            fill:SetHorizTile(false)
            fill:SetVertTile(false)
        end
        bar:SetStatusBarColor(0.28, 0.88, 0.28, 1)

        local value = bar:CreateFontString(nil, "OVERLAY")
        if Mancer.Util and Mancer.Util.ApplyFont then
            Mancer.Util.ApplyFont(value, 12)
        else
            value:SetFontObject(GameFontHighlightSmall)
        end
        value:SetPoint("CENTER", bar, "CENTER", 0, 0)
        value:SetTextColor(1, 1, 1, 0.95)
        value:SetShadowOffset(1, -1)

        self.rows[i] = {
            frame = row,
            label = label,
            track = track,
            bar = bar,
            value = value,
        }
    end
end

function MinionHpHud:ApplyBarTextures()
    if not self.rows then
        return
    end
    local tex = GetMinionHpBarTexture()
    for _, row in ipairs(self.rows) do
        if row.track then
            row.track:SetTexture(HP_BAR_FILL_FALLBACK)
            row.track:SetVertexColor(0.08, 0.08, 0.08, 0.9)
        end
        if row.bar then
            row.bar:SetStatusBarTexture(tex)
            local fill = row.bar:GetStatusBarTexture()
            if fill then
                fill:SetTexture(tex)
                fill:SetHorizTile(false)
                fill:SetVertTile(false)
            end
        end
    end
end

function MinionHpHud:EnsureTicker()
    if self.ticker then
        return
    end
    -- Always-running ticker: the list frame hides when no minions are up, and a
    -- hidden frame's OnUpdate stops — resummons would never refresh until Display opens.
    local ticker = CreateFrame("Frame", "MancerMinionHpTicker")
    ticker:SetScript("OnUpdate", function(_, elapsed)
        self:OnUpdate(elapsed)
    end)
    self.ticker = ticker
end

function MinionHpHud:RequestRefreshSoon()
    self.elapsed = REFRESH_INTERVAL
end

function MinionHpHud:SaveOffsetFromHandle()
    if not self.handle or not Mancer.FloatingText or not Mancer.FloatingText.anchor then
        return
    end
    -- Must save the same TOPLEFT↔CENTER offsets used while dragging.
    -- Using GetCenter here used to snap the bar by ~half the H-handle size on drop.
    local x, y = self._dragX, self._dragY
    if not x or not y then
        local parent = Mancer.FloatingText.anchor
        local hx, hy = self.handle:GetLeft(), self.handle:GetTop()
        local ax, ay = parent:GetCenter()
        if hx and hy and ax and ay then
            x = (hx - ax)
            y = (hy - ay)
        else
            return
        end
    end
    MancerDB.minionHpListOffset = {
        x = x,
        y = y,
    }
    self._layoutX, self._layoutY = x, y
    self._dragX, self._dragY = nil, nil
    -- Already at the drop point — skip ClearAllPoints/SetPoint snap.
end

function MinionHpHud:RaiseHandle()
    if not self.handle then
        return
    end
    local hudParent = (Mancer.FloatingText and Mancer.FloatingText.anchor) or UIParent
    -- Move-mode: own UIParent HIGH layer above arc α / yellow squares / help box.
    if self.moveMode then
        if self.handle:GetParent() ~= UIParent then
            self.handle:SetParent(UIParent)
        end
        self.handle:SetFrameStrata("HIGH")
        self.handle:SetFrameLevel(250)
        if self.handle.SetToplevel then
            self.handle:SetToplevel(true)
        end
    else
        if self.handle:GetParent() ~= hudParent then
            self.handle:SetParent(hudParent)
        end
        self.handle:SetFrameStrata((hudParent.GetFrameStrata and hudParent:GetFrameStrata()) or "LOW")
        self.handle:SetFrameLevel((hudParent.GetFrameLevel and hudParent:GetFrameLevel() or 1) + 80)
        if self.handle.SetToplevel then
            self.handle:SetToplevel(false)
        end
    end
    self.handle:EnableMouse(self.moveMode and FeatureEnabled())
end

function MinionHpHud:AnchorHandleToList()
    if not self.handle or not self.frame then
        return
    end
    -- SetPoint-only (MancerAnchor chain is ClearAllPoints-protected on Ascension).
    self.handle:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT", 0, 4)
end

function MinionHpHud:ApplyLayout(force)
    self:EnsureFrames()
    if self.moving and not force then
        return
    end

    local parent = (Mancer.FloatingText and Mancer.FloatingText.anchor) or UIParent
    if self.frame:GetParent() ~= parent then
        self.frame:SetParent(parent)
        self.frame:EnableMouse(false)
    end
    self:RaiseHandle()

    local off = MancerDB.minionHpListOffset or { x = 90, y = 20 }
    local x, y = off.x or 90, off.y or 20
    if not force
        and self._layoutParent == parent
        and self._layoutX == x
        and self._layoutY == y
    then
        self:AnchorHandleToList()
        return
    end
    self._layoutParent = parent
    self._layoutX = x
    self._layoutY = y

    pcall(function()
        self.frame:SetPoint("TOPLEFT", parent, "CENTER", x, y)
        self:AnchorHandleToList()
    end)
    self:LayoutAlphaSlider()
end

function MinionHpHud:EnsureAlphaSlider()
    if self.alphaSlider or not Mancer.UI or not Mancer.UI.CreateAlphaSlider then
        return
    end
    local parent = (Mancer.FloatingText and Mancer.FloatingText.anchor) or UIParent
    self.alphaSlider = Mancer.UI.CreateAlphaSlider(parent, {
        name = "MancerAlphaMinionHp",
        vertical = true,
        length = 72,
        dbKey = "minionHpListAlpha",
        apply = function(a)
            if Mancer.MinionHpHud then
                Mancer.MinionHpHud:ApplyAlpha(a)
            end
        end,
    })
    self:LayoutAlphaSlider()
end

function MinionHpHud:LayoutAlphaSlider()
    if not self.alphaSlider or not self.frame then
        return
    end
    local parent = (Mancer.FloatingText and Mancer.FloatingText.anchor) or UIParent
    if self.alphaSlider:GetParent() ~= parent then
        self.alphaSlider:SetParent(parent)
    end
    self.alphaSlider:SetPoint("LEFT", self.frame, "RIGHT", 4, 0)
    if self.alphaSlider.RefreshThumb then
        self.alphaSlider:RefreshThumb()
    end
end

function MinionHpHud:ApplyAlpha(alpha)
    alpha = tonumber(alpha)
    if not alpha and MancerDB then
        alpha = MancerDB.minionHpListAlpha
    end
    alpha = tonumber(alpha) or 1
    if alpha < 0.15 then
        alpha = 0.15
    elseif alpha > 1 then
        alpha = 1
    end
    if self.frame then
        self.frame:SetAlpha(alpha)
    end
    if self.alphaSlider and self.alphaSlider.RefreshThumb then
        self.alphaSlider:RefreshThumb()
    end
end

function MinionHpHud:UpdateAlphaSliderVisibility()
    self:EnsureAlphaSlider()
    if not self.alphaSlider then
        return
    end
    local show = self.moveMode and FeatureEnabled()
    if show then
        self:LayoutAlphaSlider()
        self.alphaSlider:Show()
        if self.alphaSlider.RefreshThumb then
            self.alphaSlider:RefreshThumb()
        end
    else
        self.alphaSlider.dragging = false
        self.alphaSlider:Hide()
    end
end

function MinionHpHud:SetMoveMode(enabled)
    self:EnsureFrames()
    self.moveMode = not not enabled
    self.moving = false
    self:ApplyLayout(true)
    if self.handle then
        local show = enabled and FeatureEnabled()
        self:RaiseHandle()
        self:AnchorHandleToList()
        self.handle:EnableMouse(show)
        if show then
            self.handle:Show()
            self.handle:Raise()
        else
            self.handle:Hide()
        end
    end
    -- Immediate refresh so preview rows + H appear without waiting for OnUpdate.
    self:Refresh(true)
    self:UpdateAlphaSliderVisibility()
end

function MinionHpHud:OnUpdate(elapsed)
    if self.moving and self.handle and Mancer.FloatingText and Mancer.FloatingText.anchor then
        -- Same pattern as A/Z/T: if mouse-up is lost (handle slid out from under cursor),
        -- stop when the button is no longer held.
        local stillDown = IsMouseButtonDown and IsMouseButtonDown("LeftButton")
        if not stillDown then
            self.moving = false
            self:SaveOffsetFromHandle()
        else
            local uiScale = UIParent:GetEffectiveScale()
            local cx, cy = GetCursorPosition()
            cx, cy = cx / uiScale, cy / uiScale
            local ax, ay = Mancer.FloatingText.anchor:GetCenter()
            if ax and ay then
                local x = (cx + (self.dragOffsetX or 0)) - ax
                local y = (cy + (self.dragOffsetY or 0)) - ay
                self._dragX, self._dragY = x, y
                -- Invalidate cached layout while dragging.
                self._layoutX, self._layoutY = nil, nil
                pcall(function()
                    self.frame:SetPoint("TOPLEFT", Mancer.FloatingText.anchor, "CENTER", x, y)
                    self:AnchorHandleToList()
                end)
            end
        end
    end

    self.elapsed = (self.elapsed or 0) + (elapsed or 0)
    if self.elapsed < REFRESH_INTERVAL then
        return
    end
    self.elapsed = 0
    self:Refresh()
end

function MinionHpHud:Refresh(forceSync)
    self:EnsureFrames()
    self:ApplyLayout()
    self:SyncNameplateSupport(forceSync)

    if not FeatureEnabled() then
        self.frame:Hide()
        if self.handle then
            self.handle:Hide()
        end
        self._lastRowText = nil
        return
    end

    local rows = self:CollectHpRows()
    -- Move mode always shows sample rows so H + list are findable even with no tokens yet.
    if self.moveMode and #rows == 0 then
        rows = {
            { label = "Ghoul", health = 21000, healthMax = 21000 },
            { label = "Abom", health = 28800, healthMax = 48000 },
            { label = "Fiend", health = 4500, healthMax = 18000 },
        }
    end

    if #rows == 0 then
        self.frame:Hide()
        if self.handle and self.moveMode then
            self.handle:Show()
        elseif self.handle then
            self.handle:Hide()
        end
        self._lastRowText = nil
        return
    end

    if not self.frame:IsShown() then
        self.frame:Show()
    end
    if self.moveMode and self.handle then
        if not self.handle:IsShown() then
            self.handle:Show()
        end
    elseif self.handle and self.handle:IsShown() then
        self.handle:Hide()
    end

    self._lastRowText = self._lastRowText or {}
    for i = 1, MAX_ROWS do
        local slot = self.rows[i]
        local row = rows[i]
        if row and slot and slot.bar then
            local pct = 0
            if row.healthMax and row.healthMax > 0 then
                pct = row.health / row.healthMax
            end
            if pct < 0 then
                pct = 0
            elseif pct > 1 then
                pct = 1
            end
            local text = string.format(
                "%s|%s/%s|%.3f",
                row.label or "",
                FormatHp(row.health),
                FormatHp(row.healthMax),
                pct
            )
            if self._lastRowText[i] ~= text then
                self._lastRowText[i] = text
                slot.label:SetText(row.label or "")
                slot.value:SetText(string.format("[%s/%s]", FormatHp(row.health), FormatHp(row.healthMax)))
                slot.bar:SetMinMaxValues(0, 1)
                slot.bar:SetValue(pct)
                local r, g, b = HpBarColor(pct)
                slot.bar:SetStatusBarColor(r, g, b, 1)
            end
            if not slot.frame:IsShown() then
                slot.frame:Show()
            end
        elseif slot and slot.frame then
            self._lastRowText[i] = nil
            if slot.frame:IsShown() then
                slot.frame:Hide()
            end
        end
    end

    local height = math.min(#rows, MAX_ROWS) * ROW_HEIGHT + 4
    local width = HANDLE_SIZE + 4 + LABEL_WIDTH + BAR_WIDTH
    if self._lastHeight ~= height or self._lastWidth ~= width then
        self._lastHeight = height
        self._lastWidth = width
        self.frame:SetHeight(height)
        self.frame:SetWidth(width)
    end
end

function MinionHpHud:ApplyConfig()
    self:EnsureFrames()
    self:EnsureTicker()
    self:ApplyBarTextures()
    self:ApplyLayout(true)
    self:ApplyAlpha()
    self:SyncNameplateSupport(true)
    self:Refresh(true)
    self:UpdateAlphaSliderVisibility()
end

function MinionHpHud:New()
    local self = setmetatable({}, { __index = MinionHpHud })
    self.elapsed = 0
    self.moveMode = false
    self:EnsureFrames()
    self:EnsureTicker()
    self:ApplyConfig()

    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGOUT")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    pcall(function()
        f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    end)
    pcall(function()
        f:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    end)
    f:SetScript("OnEvent", function(_, event, unit)
        if event == "PLAYER_LOGOUT" then
            self:ClearNameplateVisualHide()
            self:RestoreNameplates()
            if Mancer.RestorePersistedNameplateCvarBackup then
                Mancer.RestorePersistedNameplateCvarBackup()
            end
        elseif event == "PLAYER_ENTERING_WORLD" then
            if Mancer.RestorePersistedNameplateCvarBackup then
                Mancer.RestorePersistedNameplateCvarBackup()
            end
            self:ApplyConfig()
        elseif event == "NAME_PLATE_UNIT_ADDED" then
            self:OnNamePlateUnitAdded(unit)
            if FeatureEnabled() then
                self:RequestRefreshSoon()
                self:Refresh()
            end
        elseif event == "NAME_PLATE_UNIT_REMOVED" then
            if FeatureEnabled() then
                self:RequestRefreshSoon()
            end
        end
    end)
    self.eventFrame = f
    return self
end
