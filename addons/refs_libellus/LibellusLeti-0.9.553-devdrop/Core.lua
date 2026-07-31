Mancer = Mancer or {}
Mancer.Options = Mancer.Options or {}

-- User-facing rebrand (0.9.406). Internal namespace `Mancer` kept for compatibility.
-- SavedVariables: LibellusLetiDB (0.9.440+). MancerDB is an alias to the same table.
Mancer.ADDON_FOLDER = "LibellusLeti"
Mancer.DISPLAY_NAME = "Libellus Leti"
-- Compact tooltip/chat tag (full window titles use DISPLAY_NAME).
Mancer.SHORT_NAME = "Libellus Leti"

-- Embedded so /reload always picks up bumps. Ascension can cache GetAddOnMetadata
-- across reload, which left the Hub title stuck on an older ## Version.
local EMBEDDED_VERSION = "0.9.553"

-- Prefer embedded version; fall back to toc metadata when present.
function Mancer.GetVersion()
    if EMBEDDED_VERSION and EMBEDDED_VERSION ~= "" then
        Mancer.VERSION = EMBEDDED_VERSION
        return EMBEDDED_VERSION
    end
    if GetAddOnMetadata then
        local version = GetAddOnMetadata(Mancer.ADDON_FOLDER or "LibellusLeti", "Version")
        if version and version ~= "" then
            Mancer.VERSION = version
            return version
        end
    end
    return Mancer.VERSION or "?"
end

Mancer.VERSION = Mancer.GetVersion()

-- Where Undead stance prompts may show.
-- Uses IsInInstance() instanceType: none→world, party→dungeon, raid→raid,
-- arena→arena, pvp→battleground.
local SHOW_WHERE_IDS = { "all", "world", "raid", "dungeon", "arena", "battleground" }
local SHOW_WHERE_LABEL_KEYS = {
    all = "WHERE_ALL",
    world = "WHERE_WORLD",
    raid = "WHERE_RAID",
    dungeon = "WHERE_DUNGEON",
    arena = "WHERE_ARENA",
    battleground = "WHERE_BATTLEGROUND",
}

local SHOW_WHERE_PLACES = { "world", "raid", "dungeon", "arena", "battleground" }

-- Nameplates: hide bars, keep name text (Ascension NamePlateDriver templates).
local PLATE_NAMES_ONLY_IDS = { "all", "guardians", "players", "npcs", "enemies" }
local PLATE_NAMES_ONLY_KEYS = { "guardians", "players", "npcs", "enemies" }
local PLATE_NAMES_ONLY_LABEL_KEYS = {
    all = "PLATE_ALL",
    guardians = "PLATE_GUARDIANS",
    players = "PLATE_PLAYERS",
    npcs = "PLATE_NPCS",
    enemies = "PLATE_ENEMIES",
}

local function DefaultShowWherePlaces()
    return {
        world = true,
        raid = true,
        dungeon = true,
        arena = true,
        battleground = true,
    }
end

local function NormalizeShowWherePlaces(places)
    local out = DefaultShowWherePlaces()
    if type(places) ~= "table" then
        return out
    end
    for _, id in ipairs(SHOW_WHERE_PLACES) do
        out[id] = places[id] and true or false
    end
    return out
end

local function PlacesFromLegacyShowWhere(id)
    if id == "world" then
        return { world = true, raid = false, dungeon = false, arena = false, battleground = false }
    end
    if id == "raid" then
        return { world = false, raid = true, dungeon = false, arena = false, battleground = false }
    end
    if id == "dungeon" then
        return { world = false, raid = false, dungeon = true, arena = false, battleground = false }
    end
    if id == "arena" then
        return { world = false, raid = false, dungeon = false, arena = true, battleground = false }
    end
    if id == "battleground" then
        return { world = false, raid = false, dungeon = false, arena = false, battleground = true }
    end
    return DefaultShowWherePlaces()
end

local function PlacesAllEnabled(places)
    if type(places) ~= "table" then
        return false
    end
    for _, id in ipairs(SHOW_WHERE_PLACES) do
        if not places[id] then
            return false
        end
    end
    return true
end

function Mancer.GetShowWhereOptions()
    local L = Mancer.L or {}
    local options = {}
    for _, id in ipairs(SHOW_WHERE_IDS) do
        local key = SHOW_WHERE_LABEL_KEYS[id]
        table.insert(options, {
            id = id,
            label = (key and L[key]) or id,
        })
    end
    return options
end

function Mancer.GetShowWherePlaces()
    MancerDB = MancerDB or {}
    if type(MancerDB.showWherePlaces) ~= "table" then
        MancerDB.showWherePlaces = PlacesFromLegacyShowWhere(MancerDB.showWhere)
    end
    MancerDB.showWherePlaces = NormalizeShowWherePlaces(MancerDB.showWherePlaces)
    return MancerDB.showWherePlaces
end

function Mancer.IsShowWhereAll()
    return PlacesAllEnabled(Mancer.GetShowWherePlaces())
end

-- Back-compat: single id summary ("all", or one place if only that is on).
function Mancer.GetShowWhere()
    local places = Mancer.GetShowWherePlaces()
    if PlacesAllEnabled(places) then
        return "all"
    end
    local only = nil
    for _, id in ipairs(SHOW_WHERE_PLACES) do
        if places[id] then
            if only then
                return "custom"
            end
            only = id
        end
    end
    return only or "all"
end

function Mancer.GetShowWhereLabel(id)
    id = id or Mancer.GetShowWhere()
    local options = Mancer.GetShowWhereOptions()
    for _, opt in ipairs(options) do
        if opt.id == id then
            return opt.label
        end
    end
    if id == "custom" then
        local places = Mancer.GetShowWherePlaces()
        local parts = {}
        for _, placeId in ipairs(SHOW_WHERE_PLACES) do
            if places[placeId] then
                for _, opt in ipairs(options) do
                    if opt.id == placeId then
                        table.insert(parts, opt.label)
                        break
                    end
                end
            end
        end
        if #parts > 0 then
            return table.concat(parts, ", ")
        end
    end
    local L = Mancer.L
    return (L and L["WHERE_ALL"]) or "All"
end

function Mancer.SetShowWherePlace(id, enabled)
    MancerDB = MancerDB or {}
    local places = Mancer.GetShowWherePlaces()
    enabled = not not enabled

    if id == "all" then
        -- Tick All → everything on. Untick All → clear all places.
        for _, placeId in ipairs(SHOW_WHERE_PLACES) do
            places[placeId] = enabled
        end
    elseif id == "world" or id == "raid" or id == "dungeon"
        or id == "arena" or id == "battleground" then
        places[id] = enabled
    else
        return
    end

    MancerDB.showWherePlaces = places
    -- Keep legacy string in sync for older readers.
    MancerDB.showWhere = Mancer.GetShowWhere()
    if Mancer.Refresh then
        Mancer:Refresh()
    end
end

-- Back-compat exclusive setter (single place or all).
function Mancer.SetShowWhere(id)
    if id == "all" then
        Mancer.SetShowWherePlace("all", true)
        return
    end
    if id == "world" or id == "raid" or id == "dungeon"
        or id == "arena" or id == "battleground" then
        MancerDB = MancerDB or {}
        MancerDB.showWherePlaces = PlacesFromLegacyShowWhere(id)
        MancerDB.showWhere = id
        if Mancer.Refresh then
            Mancer:Refresh()
        end
        return
    end
    Mancer.SetShowWherePlace("all", true)
end

local function NormalizePlateNamesOnlyTargets(targets)
    local out = {}
    if type(targets) ~= "table" then
        targets = nil
    end
    for _, id in ipairs(PLATE_NAMES_ONLY_KEYS) do
        out[id] = targets and targets[id] and true or false
    end
    return out
end

function Mancer.GetPlateNamesOnlyTargets()
    MancerDB = MancerDB or {}
    local targets = NormalizePlateNamesOnlyTargets(MancerDB.nameplateNamesOnlyTargets)
    MancerDB.nameplateNamesOnlyTargets = targets
    return targets
end

function Mancer.IsPlateNamesOnlyAllOn()
    local t = Mancer.GetPlateNamesOnlyTargets()
    return t.guardians and t.players and t.npcs and t.enemies
end

function Mancer.GetPlateNamesOnlyOptions()
    local L = Mancer.L
    local out = {}
    for _, id in ipairs(PLATE_NAMES_ONLY_IDS) do
        local key = PLATE_NAMES_ONLY_LABEL_KEYS[id]
        out[#out + 1] = {
            id = id,
            label = (L and key and L[key]) or id,
        }
    end
    return out
end

function Mancer.SetPlateNamesOnlyTarget(id, enabled)
    MancerDB = MancerDB or {}
    local targets = Mancer.GetPlateNamesOnlyTargets()
    enabled = not not enabled

    if id == "all" then
        for _, key in ipairs(PLATE_NAMES_ONLY_KEYS) do
            targets[key] = enabled
        end
    elseif id == "guardians" or id == "players" or id == "npcs" or id == "enemies" then
        targets[id] = enabled
    else
        return
    end

    MancerDB.nameplateNamesOnlyTargets = targets
    -- Legacy mirror: any names-only mode counts as "hide visuals" for old readers.
    MancerDB.hideMinionHpNameplateVisuals = Mancer.IsPlateNamesOnlyEnabled()
    if Mancer.Refresh then
        Mancer:Refresh()
    end
end

function Mancer.IsPlateNamesOnlyEnabled()
    local t = Mancer.GetPlateNamesOnlyTargets()
    return t.guardians or t.players or t.npcs or t.enemies
end

-----------------------------------------------------------------------
-- Capital cities: mute nameplates for FPS (Orgrimmar, Stormwind, …).
-- Uses locale-independent map file names when possible, plus zone text.
-----------------------------------------------------------------------

-- Blizzard mapFileName keys (often misspelled: Ogrimmar, Darnassis).
local CAPITAL_MAP_FILES = {
    ogrimmar = true,
    orgrimmar = true,
    stormwind = true,
    ironforge = true,
    darnassis = true,
    darnassus = true,
    thunderbluff = true,
    undercity = true,
    silvermooncity = true,
    theexodar = true,
    shattrathcity = true,
    dalaran = true,
}

-- GetRealZoneText / GetZoneText fallbacks (enUS + common variants).
local CAPITAL_ZONE_NAMES = {
    ["orgrimmar"] = true,
    ["stormwind city"] = true,
    ["stormwind"] = true,
    ["ironforge"] = true,
    ["darnassus"] = true,
    ["thunder bluff"] = true,
    ["undercity"] = true,
    ["silvermoon city"] = true,
    ["the exodar"] = true,
    ["shattrath city"] = true,
    ["dalaran"] = true,
}

local CAPITAL_MUTE_CVARS = {
    "nameplateShowFriends",
    "nameplateShowEnemies",
    "nameplateShowFriendlyGuardians",
    "nameplateShowFriendlyPets",
    "nameplateShowFriendlyTotems",
    "nameplateShowEnemyGuardians",
    "nameplateShowEnemyPets",
    "nameplateShowEnemyTotems",
    "nameplateShowAll",
}

local function NormalizeMapFileKey(mapFile)
    if type(mapFile) ~= "string" or mapFile == "" then
        return nil
    end
    return mapFile:lower():gsub("[^%w]", "")
end

function Mancer.IsInCapitalCity()
    -- Prefer map file (locale-independent). Avoid stomping an open world map.
    local mapOpen = WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown()
    if not mapOpen and SetMapToCurrentZone then
        pcall(SetMapToCurrentZone)
    end
    if GetMapInfo then
        local mapFile = GetMapInfo()
        local key = NormalizeMapFileKey(mapFile)
        if key and CAPITAL_MAP_FILES[key] then
            return true, mapFile
        end
    end

    local zone = (GetRealZoneText and GetRealZoneText()) or (GetZoneText and GetZoneText())
    if type(zone) == "string" and zone ~= "" then
        local zkey = zone:lower()
        if CAPITAL_ZONE_NAMES[zkey] then
            return true, zone
        end
    end
    return false, zone
end

local function SheetWantsNameplates()
    local sheet = Mancer.MinionSheetModule
    if sheet and sheet.nameplateCvarBackup then
        return true
    end
    if sheet and sheet.frame and sheet.frame.IsShown and sheet.frame:IsShown() then
        return true
    end
    return false
end

function Mancer.IsCapitalNameplateMuteActive()
    return Mancer._capitalPlateMuteActive == true
end

local function SnapshotCapitalPlateCvars()
    local backup = {}
    if not GetCVar then
        return backup
    end
    for i = 1, #CAPITAL_MUTE_CVARS do
        local key = CAPITAL_MUTE_CVARS[i]
        local ok, val = pcall(GetCVar, key)
        if ok and val ~= nil then
            backup[key] = val
        end
    end
    return backup
end

local function ApplyCapitalPlateMuteValues()
    if not SetCVar then
        return
    end
    for i = 1, #CAPITAL_MUTE_CVARS do
        local key = CAPITAL_MUTE_CVARS[i]
        local ok, cur = pcall(GetCVar, key)
        if ok and cur ~= nil then
            pcall(SetCVar, key, "0")
        end
    end
end

local function RestoreCapitalPlateCvars(backup)
    if type(backup) ~= "table" or not SetCVar then
        return
    end
    for key, val in pairs(backup) do
        pcall(SetCVar, key, val)
    end
end

--- Mute plates in capitals for FPS. Yields to Minion Sheet (needs tokens).
--- Backup is SavedVariables so /reload in a city can still restore on leave.
function Mancer.UpdateCapitalNameplateMute()
    MancerDB = MancerDB or {}
    local settingOn = MancerDB.disableNameplatesInCapitals ~= false
    local inCapital = Mancer.IsInCapitalCity()
    local sheetOpen = SheetWantsNameplates()
    local wantMute = settingOn and inCapital and not sheetOpen

    if wantMute then
        if not Mancer._capitalPlateMuteActive then
            local backup = MancerDB.capitalNameplateCvarBackup
            if type(backup) ~= "table" or not next(backup) then
                -- Drop Minion HP boost first so we snapshot the user's real prefs.
                local hud = Mancer.MinionHpHud
                if hud and hud.nameplateCvarBackup and hud.RestoreNameplates then
                    hud:RestoreNameplates()
                end
                backup = SnapshotCapitalPlateCvars()
                MancerDB.capitalNameplateCvarBackup = backup
            end
            ApplyCapitalPlateMuteValues()
            Mancer._capitalPlateMuteActive = true
        else
            -- Re-assert mute (another system may have flipped Friends on).
            ApplyCapitalPlateMuteValues()
        end
        return true
    end

    -- Sheet open in a capital: suspend mute but keep the SavedVariables backup.
    if settingOn and inCapital and sheetOpen then
        Mancer._capitalPlateMuteActive = false
        return false
    end

    -- Left capital or setting off — restore pre-mute prefs.
    if type(MancerDB.capitalNameplateCvarBackup) == "table" and next(MancerDB.capitalNameplateCvarBackup) then
        RestoreCapitalPlateCvars(MancerDB.capitalNameplateCvarBackup)
        MancerDB.capitalNameplateCvarBackup = nil
        Mancer._capitalPlateMuteActive = false
        local hud = Mancer.MinionHpHud
        if hud and hud.SyncNameplateSupport then
            hud:SyncNameplateSupport(true)
        end
    else
        Mancer._capitalPlateMuteActive = false
    end
    return false
end

function Mancer.SetDisableNameplatesInCapitals(enabled)
    MancerDB = MancerDB or {}
    MancerDB.disableNameplatesInCapitals = not not enabled
    Mancer.UpdateCapitalNameplateMute()
    if Mancer.Refresh then
        Mancer:Refresh()
    end
end

-----------------------------------------------------------------------
-- Minion Sheet temporarily forces friendly plates on for unit tokens.
-- Memory backup dies on /reload — persist prefs so login can restore.
-----------------------------------------------------------------------

local NAMEPLATE_BOOST_KEYS = {
    "nameplateShowFriends",
    "nameplateShowFriendlyGuardians",
    "nameplateShowFriendlyPets",
}

function Mancer.PersistNameplateCvarBackup(backup)
    MancerDB = MancerDB or {}
    if type(backup) ~= "table" or not next(backup) then
        return
    end
    local copy = {}
    for key, val in pairs(backup) do
        copy[key] = val
    end
    MancerDB.nameplateCvarBackup = copy
end

function Mancer.ClearPersistedNameplateCvarBackup()
    if MancerDB then
        MancerDB.nameplateCvarBackup = nil
    end
end

--- Apply SavedVariables plate prefs left behind by a Leti boost (reload / crash).
function Mancer.RestorePersistedNameplateCvarBackup()
    local backup = MancerDB and MancerDB.nameplateCvarBackup
    if type(backup) ~= "table" or not next(backup) then
        if MancerDB then
            MancerDB.nameplateCvarBackup = nil
        end
        return false
    end
    if not SetCVar then
        return false
    end
    local needsRestore = false
    for _, key in ipairs(NAMEPLATE_BOOST_KEYS) do
        local val = backup[key]
        if val ~= nil and tostring(val) ~= "1" then
            needsRestore = true
            break
        end
    end
    if needsRestore then
        for key, val in pairs(backup) do
            pcall(SetCVar, key, val)
        end
    end
    MancerDB.nameplateCvarBackup = nil
    return needsRestore
end

function Mancer.GetInstanceKind()
    if not IsInInstance then
        return "world"
    end
    local inInstance, instanceType = IsInInstance()
    if not inInstance or not instanceType or instanceType == "" or instanceType == "none" then
        return "world"
    end
    if instanceType == "raid" then
        return "raid"
    end
    if instanceType == "party" then
        return "dungeon"
    end
    if instanceType == "arena" then
        return "arena"
    end
    if instanceType == "pvp" then
        return "battleground"
    end
    return instanceType
end

-- Stance prompt allowed here? Move-mode / Display preview always allowed.
function Mancer.IsStancePromptAllowed()
    if Mancer.FloatingText and Mancer.FloatingText.moveMode then
        return true
    end
    if Mancer.Options and Mancer.Options.window and Mancer.Options.window:IsShown() then
        return true
    end
    local places = Mancer.GetShowWherePlaces()
    if PlacesAllEnabled(places) then
        return true
    end
    local kind = Mancer.GetInstanceKind()
    if kind == "world" then
        return places.world and true or false
    end
    if kind == "raid" then
        return places.raid and true or false
    end
    if kind == "dungeon" then
        return places.dungeon and true or false
    end
    if kind == "arena" then
        return places.arena and true or false
    end
    if kind == "battleground" then
        return places.battleground and true or false
    end
    return false
end

-- Back-compat alias (older calls).
function Mancer.IsHudContextAllowed()
    return Mancer.IsStancePromptAllowed()
end

function Mancer.Print(msg)
    local text = tostring(msg)
    -- Hub report capture: collect lines only — do not spam chat.
    if Mancer.reportSink then
        table.insert(Mancer.reportSink, text)
        return
    end
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cff66ccff" .. (Mancer.DISPLAY_NAME or "Libellus Leti") .. "|r: " .. text)
    end
end

function Mancer.Trim(msg)
    return (msg or ""):match("^%s*(.-)%s*$") or ""
end

local ADDON_FOLDER = Mancer.ADDON_FOLDER or "LibellusLeti"
local ADDON_ROOT = "Interface\\AddOns\\" .. ADDON_FOLDER .. "\\"
local MANCER_AURA = ADDON_ROOT .. "PlayerBarTextures\\Auras\\"
local WEAKAURAS_AURA = "Interface\\Addons\\WeakAuras\\PowerAurasMedia\\Auras\\"

Mancer.BAR_TEXTURES = {
    { name = "Runed Text", path = MANCER_AURA .. "Aura1", splitHalf = true },
    { name = "Runed Text On Ring", path = MANCER_AURA .. "Aura2", splitHalf = true },
    { name = "Power Waves", path = MANCER_AURA .. "Aura3", splitHalf = true },
    { name = "Majesty", path = MANCER_AURA .. "Aura4", splitHalf = true },
    { name = "Runed Ends", path = MANCER_AURA .. "Aura5", splitHalf = true },
    { name = "Extra Majesty", path = MANCER_AURA .. "Aura6", splitHalf = true },
    { name = "Triangular Highlights", path = MANCER_AURA .. "Aura7", splitHalf = true },
    { name = "Oblong Highlights", path = MANCER_AURA .. "Aura11", splitHalf = true },
    { name = "Thin Crescents", path = MANCER_AURA .. "Aura16", splitHalf = true },
    { name = "Crescent Highlights", path = MANCER_AURA .. "Aura17", splitHalf = true },
    { name = "Dense Runed Text", path = MANCER_AURA .. "Aura18", splitHalf = true },
    { name = "Runed Spiked Ring", path = MANCER_AURA .. "Aura23", splitHalf = true },
    { name = "Smoke", path = MANCER_AURA .. "Aura24", splitHalf = true },
    { name = "Flourished Text", path = MANCER_AURA .. "Aura28", splitHalf = true },
    { name = "Droplet Highlights", path = MANCER_AURA .. "Aura33", splitHalf = true },
}

-- Fixed texture for the optional Runic Power crescent (not cycled with Bar texture).
Mancer.RUNIC_BAR_TEXTURE = MANCER_AURA .. "Aura16"

function Mancer.GetBarTextureName(path)
    path = Mancer.NormalizeBarTexturePath(path)
    for _, entry in ipairs(Mancer.BAR_TEXTURES) do
        if entry.path == path then
            return entry.name
        end
    end
    return "Runed Text"
end

function Mancer.GetBarTexturePath(path)
    if path and path ~= "" then
        return path
    end
    return Mancer.BAR_TEXTURES[1].path
end

function Mancer.NormalizeBarTexturePath(path)
    if type(path) ~= "string" or path == "" then
        return Mancer.BAR_TEXTURES[1].path
    end

    path = path:gsub("/", "\\")
        :gsub("\\AddOns\\", "\\Addons\\")
        :gsub("\\CombatText\\", "\\" .. ADDON_FOLDER .. "\\")
        :gsub("\\RunePulse\\", "\\" .. ADDON_FOLDER .. "\\")
        :gsub("\\WeakAuras\\PowerAurasMedia\\Auras\\", "\\" .. ADDON_FOLDER .. "\\PlayerBarTextures\\Auras\\")
        :gsub("\\Addons\\WeakAuras\\PowerAurasMedia\\Auras\\", "\\" .. ADDON_FOLDER .. "\\PlayerBarTextures\\Auras\\")
        :gsub("\\" .. ADDON_FOLDER .. "\\PowerAurasMedia\\Auras\\", "\\" .. ADDON_FOLDER .. "\\PlayerBarTextures\\Auras\\")
        :gsub("\\Mancer\\PowerAurasMedia\\Auras\\", "\\" .. ADDON_FOLDER .. "\\PlayerBarTextures\\Auras\\")
        :gsub("\\Mancer\\Media\\Auras\\", "\\" .. ADDON_FOLDER .. "\\PlayerBarTextures\\Auras\\")
        :gsub("\\LibellusLeti\\Media\\Auras\\", "\\" .. ADDON_FOLDER .. "\\PlayerBarTextures\\Auras\\")

    if path:find("VineStem", 1, true) or path:find("Aura124", 1, true) then
        return MANCER_AURA .. "Aura1"
    end

    local flatAura = path:match("\\Mancer\\Media\\(Aura%d+)$")
        or path:match("\\LibellusLeti\\Media\\(Aura%d+)$")
        or path:match("\\PowerAurasMedia\\Auras\\(Aura%d+)$")
    if flatAura then
        path = MANCER_AURA .. flatAura
    end

    for _, entry in ipairs(Mancer.BAR_TEXTURES) do
        if entry.path == path then
            return path
        end
    end

    local base = path:match("[^\\]+$")
    if base and base:match("^Aura%d+$") then
        return MANCER_AURA .. base
    end

    return path
end

function Mancer.GetBarTextureMeta(path)
    path = Mancer.NormalizeBarTexturePath(path)
    for _, entry in ipairs(Mancer.BAR_TEXTURES) do
        if entry.path == path then
            return entry
        end
    end

    local base = path:match("[^\\]+$")
    if base == "Aura124" or base == "VineStem" then
        return Mancer.BAR_TEXTURES[1]
    end
    if base then
        for _, entry in ipairs(Mancer.BAR_TEXTURES) do
            if entry.path:match("[^\\]+$") == base then
                return entry
            end
        end
    end

    return Mancer.BAR_TEXTURES[1]
end

function Mancer.UsesSplitBarTexture(path)
    local entry = Mancer.GetBarTextureMeta(path)
    return entry and entry.splitHalf == true
end

function Mancer.GetBarTextureLoadPaths(metaPath)
    metaPath = Mancer.NormalizeBarTexturePath(metaPath)
    local base = metaPath:match("[^\\]+$") or "Aura1"
    local paths = {}

    local function add(path)
        for _, existing in ipairs(paths) do
            if existing == path then
                return
            end
        end
        paths[#paths + 1] = path
    end

    add(MANCER_AURA .. base)
    add(MANCER_AURA .. base .. ".tga")
    add(ADDON_ROOT .. "PlayerBarTextures\\Auras\\" .. base)
    add(ADDON_ROOT .. "PlayerBarTextures\\Auras\\" .. base .. ".tga")
    add(ADDON_ROOT .. "PowerAurasMedia\\Auras\\" .. base)
    add(ADDON_ROOT .. "Media\\Auras\\" .. base)
    add(ADDON_ROOT .. "Media\\Auras\\" .. base .. ".tga")
    add(ADDON_ROOT .. "Media\\" .. base)
    add(WEAKAURAS_AURA .. base)
    add("Interface\\AddOns\\WeakAuras\\PowerAurasMedia\\Auras\\" .. base)

    return paths
end

local DEFAULTS = {
    showMana = true,
    showHealth = true,
    showManaBar = true,
    showHealthBar = true,
    showRunicBar = true,
    showAnimateBar = true,
    showProcBar = true,
    consolidateBuffs = false,
    showZombieCounter = true,
    showMinionHpList = false,
    hideMinionHpNameplateVisuals = true,
    -- Busy capitals (Orgrimmar, Stormwind, …): mute plate CVars for FPS.
    disableNameplatesInCapitals = true,
    -- Hide plate bars / keep name text (Ascension NamePlateDriver). Default: own guardians only.
    nameplateNamesOnlyTargets = {
        guardians = true,
        players = false,
        npcs = false,
        enemies = false,
    },
    minionHpListOffset = { x = 90, y = 20 },
    minionHpBarTextureIndex = 1,
    showRegenRate = true,
    showWhere = "all",
    showWherePlaces = {
        world = true,
        raid = true,
        dungeon = true,
        arena = true,
        battleground = true,
    },
    regenOnly = false,
    fontSize = 22,
    fontFile = "Fonts\\FRIZQT__.TTF",
    anchorX = 0,
    anchorY = 80,
    arcRadius = 65,
    scale = 1.25,
    manaColor = { 0.35, 0.65, 1.0 },
    healthColor = { 0.35, 0.95, 0.45 },
    runicColor = { 0.45, 0.85, 1.0 },
    rateColor = { 0.85, 0.85, 0.85 },
    barTexture = MANCER_AURA .. "Aura1",
    barTransform = {
        unified = { scale = 1.0, width = 1.0, height = 1.0, offsetX = 0, offsetY = 0 },
        mana = { width = 1.0, height = 1.0, offsetX = 0, offsetY = 0 },
        health = { width = 1.0, height = 1.0, offsetX = 0, offsetY = 0 },
    },
    advisorTextOffset = { x = 0, y = 28 },
    animateBarOffset = { x = 0, y = -40 },
    zombieCounterOffset = { x = 56, y = -40 },
    procBarOffset = { x = -56, y = -40 },
    moveHelpOffset = { x = 0, y = -160 },
    animateIconScale = 0.75,
    zombieIconScale = 0.85,
    procIconScale = 0.8,
    advisorTextScale = 1.0,
    locale = "enUS",
    arcBarAlpha = 1.0,
    animateBarAlpha = 1.0,
    zombieCounterAlpha = 1.0,
    procBarAlpha = 1.0,
    minionHpListAlpha = 1.0,
    necromancer = {
        enabled = true,
        stanceEnabled = true,
        emptyMinionPrompt = "No minions",
        alertColor = { 0.25, 0.95, 0.75 },
        minionMax = {
            autoLifeForce = true,
        },
    },
    minimap = {
        hide = false,
        angle = 220,
    },
    talentOverlay = {
        show = false,
        mode = "next", -- "next" = yellow box only; "full" = remaining path + arrows
    },
}

local function CopyDefaults(source, defaults)
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            if type(source[key]) ~= "table" then
                source[key] = {}
            end
            CopyDefaults(source[key], value)
        elseif source[key] == nil then
            source[key] = value
        end
    end
end

local function TableHasKeys(t)
    return type(t) == "table" and next(t) ~= nil
end

-- Prefer the richest legacy profile so upgrades keep settings.
local function PickLegacySavedTable()
    if TableHasKeys(MancerDB) then
        return MancerDB
    end
    -- Accidental TOC "Libellus Leti" (space) may have created this global.
    local spaced = rawget(_G, "Libellus Leti")
    if TableHasKeys(spaced) then
        return spaced
    end
    if TableHasKeys(RunePulseDB) then
        return RunePulseDB
    end
    if TableHasKeys(CombatTextDB) then
        return CombatTextDB
    end
    if type(MancerDB) == "table" then
        return MancerDB
    end
    if type(spaced) == "table" then
        return spaced
    end
    if type(RunePulseDB) == "table" then
        return RunePulseDB
    end
    if type(CombatTextDB) == "table" then
        return CombatTextDB
    end
    return nil
end

local function MigrateSavedVariables()
    -- Canonical SV is LibellusLetiDB. TOC still lists MancerDB so WoW loads
    -- existing WTF profiles on upgrade; both names then share one table.
    if type(LibellusLetiDB) ~= "table" or not next(LibellusLetiDB) then
        local legacy = PickLegacySavedTable()
        if legacy then
            LibellusLetiDB = legacy
        else
            LibellusLetiDB = LibellusLetiDB or {}
        end
    end
    LibellusLetiDB = LibellusLetiDB or {}

    -- Code still uses MancerDB; alias so one table is read/written/saved.
    MancerDB = LibellusLetiDB
    Mancer.DB = LibellusLetiDB

    if type(MancerDB.barTexture) == "string" then
        MancerDB.barTexture = Mancer.NormalizeBarTexturePath(MancerDB.barTexture)
    end

    -- Old purple advisor text → Life Force teal (matches LF orb).
    local necro = MancerDB.necromancer
    if type(necro) == "table" and type(necro.alertColor) == "table" then
        local r, g, b = necro.alertColor[1], necro.alertColor[2], necro.alertColor[3]
        if r and g and b
            and math.abs(r - 0.85) < 0.02
            and math.abs(g - 0.35) < 0.02
            and math.abs(b - 1.0) < 0.02 then
            necro.alertColor = { 0.25, 0.95, 0.75 }
        end
    end

    -- Minimap button is on by default (re-enable once for older saved profiles).
    MancerDB.minimap = MancerDB.minimap or {}
    if not MancerDB.minimapDefaultOn_v183 then
        MancerDB.minimap.hide = false
        MancerDB.minimapDefaultOn_v183 = true
    end
    if MancerDB.minimap.hide == nil then
        MancerDB.minimap.hide = false
    end

    -- Drop saved fonts that are not in the Ascension/3.3.5 set.
    if Mancer.ResolveFontFile then
        MancerDB.fontFile = Mancer.ResolveFontFile(MancerDB.fontFile)
    end

    -- Advisor T-scale was often left at 2.0 while visuals were font-capped; reset once.
    if not MancerDB.advisorScaleHeight_v282 then
        MancerDB.advisorTextScale = 1.0
        MancerDB.advisorScaleHeight_v282 = true
    end

    -- Roll back the temporary default of 5 → 1.25 (pre-"make it 5" size).
    if not MancerDB.hudScaleDefault_v446 then
        local s = tonumber(MancerDB.scale)
        if s ~= nil and math.abs(s - 5.0) < 0.001 then
            MancerDB.scale = 1.25
        end
        MancerDB.hudScaleDefault_v446 = true
    end

    -- Scale-5 era + B-handle mousewheel left barTransform mangled; reset once.
    if not MancerDB.hudBarTransform_v453 then
        if MancerDB.hudScaleDefault_v434 or MancerDB.hudScaleDefault_v446 then
            MancerDB.barTransform = {
                unified = { scale = 1.0, width = 1.0, height = 1.0, offsetX = 0, offsetY = 0 },
                mana = { width = 1.0, height = 1.0, offsetX = 0, offsetY = 0 },
                health = { width = 1.0, height = 1.0, offsetX = 0, offsetY = 0 },
            }
        end
        local s = tonumber(MancerDB.scale)
        if s ~= nil then
            if math.abs(s - 5.0) < 0.001 then
                MancerDB.scale = 1.25
            elseif s > 2.0 then
                MancerDB.scale = 2.0
            end
        end
        MancerDB.hudBarTransform_v453 = true
    end

    -- Where: migrate exclusive string → multi-select places table.
    if type(MancerDB.showWherePlaces) ~= "table" then
        MancerDB.showWherePlaces = PlacesFromLegacyShowWhere(MancerDB.showWhere)
    else
        local places = MancerDB.showWherePlaces
        places.world = not not places.world
        places.raid = not not places.raid
        places.dungeon = not not places.dungeon
        -- New keys: preserve old "All = everywhere" (world+raid+dungeon) by
        -- enabling arena/BG when those keys were never saved yet.
        local legacyAll = places.world and places.raid and places.dungeon
        if places.arena == nil then
            places.arena = legacyAll and true or false
        else
            places.arena = not not places.arena
        end
        if places.battleground == nil then
            places.battleground = legacyAll and true or false
        else
            places.battleground = not not places.battleground
        end
        MancerDB.showWherePlaces = NormalizeShowWherePlaces(places)
    end
    MancerDB.showWhere = Mancer.GetShowWhere()

    -- Nameplates names-only: migrate old single "Hide friendly plates" toggle.
    if type(MancerDB.nameplateNamesOnlyTargets) ~= "table" then
        if MancerDB.hideMinionHpNameplateVisuals == false then
            MancerDB.nameplateNamesOnlyTargets = {
                guardians = false,
                players = false,
                npcs = false,
                enemies = false,
            }
        else
            MancerDB.nameplateNamesOnlyTargets = {
                guardians = true,
                players = false,
                npcs = false,
                enemies = false,
            }
        end
    else
        MancerDB.nameplateNamesOnlyTargets = NormalizePlateNamesOnlyTargets(MancerDB.nameplateNamesOnlyTargets)
    end
    MancerDB.hideMinionHpNameplateVisuals = Mancer.IsPlateNamesOnlyEnabled()

    if MancerDB.disableNameplatesInCapitals == nil then
        MancerDB.disableNameplatesInCapitals = true
    end
end

function Mancer:GetConfig()
    return MancerDB
end

function Mancer:Refresh()
    if Mancer.UpdateCapitalNameplateMute then
        Mancer.UpdateCapitalNameplateMute()
    end
    if self.FloatingText then
        self.FloatingText:ApplyConfig()
    end
    if self.RegenTracker then
        self.RegenTracker:ApplyConfig()
    end
    if self.NecromancerAdvisor then
        self.NecromancerAdvisor:ApplyConfig()
    end
    if self.MinionHpHud then
        self.MinionHpHud:ApplyConfig()
    end
    if Mancer.BuffConsolidateModule and Mancer.BuffConsolidateModule.ApplyConsolidation then
        Mancer.BuffConsolidateModule:ApplyConsolidation()
    end
end

function Mancer.OpenHub()
    if Mancer.Hub and Mancer.Hub.Open then
        Mancer.Hub:Open()
    elseif Mancer.Options then
        Mancer.Options:Open()
    end
end

function Mancer.Notify(msg)
    if Mancer.Hub and Mancer.Hub.SetStatus then
        Mancer.Hub:SetStatus(msg)
    elseif Mancer.Print then
        Mancer.Print(msg)
    end
end

local function HandleSlashCommand(msg)
    msg = tostring(msg or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local lower = msg:lower()
    if lower == "stance" or lower == "stances" or lower == "coa" then
        if Mancer.NecromancerAdvisor and Mancer.NecromancerAdvisor.PrintStanceDebug then
            Mancer.NecromancerAdvisor:PrintStanceDebug()
        else
            print("|cff7fd4ff" .. (Mancer.DISPLAY_NAME or "Libellus Leti") .. "|r stance debug not loaded yet — try after login.")
        end
        return
    end

    if lower == "plates" or lower == "nameplates" or lower == "plateclass" then
        local hud = Mancer.MinionHpHudModule
        if hud and hud.PrintPlateClassifyDebug then
            hud:PrintPlateClassifyDebug()
        else
            print("|cff7fd4ff" .. (Mancer.DISPLAY_NAME or "Libellus Leti") .. "|r plate debug not loaded — /reload.")
        end
        return
    end

    if lower == "capital" or lower == "city" or lower == "capitals" then
        local inCap, label = Mancer.IsInCapitalCity and Mancer.IsInCapitalCity()
        local mute = Mancer.IsCapitalNameplateMuteActive and Mancer.IsCapitalNameplateMuteActive()
        local setting = MancerDB and MancerDB.disableNameplatesInCapitals ~= false
        print("|cff7fd4ff" .. (Mancer.DISPLAY_NAME or "Libellus Leti") .. "|r capital plates: zone="
            .. tostring(label or "?")
            .. " inCapital=" .. (inCap and "yes" or "no")
            .. " setting=" .. (setting and "on" or "off")
            .. " muted=" .. (mute and "yes" or "no"))
        return
    end

    if lower == "dpsmiss" or lower == "miss" or lower == "misses" then
        if Mancer.MinionDpsModule and Mancer.MinionDpsModule.PrintMissDebug then
            Mancer.MinionDpsModule:PrintMissDebug()
        else
            print("|cff7fd4ff" .. (Mancer.DISPLAY_NAME or "Libellus Leti") .. "|r miss debug not loaded — /reload.")
        end
        return
    end

    if lower == "inspecttree" or lower == "itree" or lower == "inspect" or lower == "inspect build" then
        if Mancer.InspectTreeModule and Mancer.InspectTreeModule.ShowForUnit then
            Mancer.InspectTreeModule:ShowForUnit()
        else
            print("|cff7fd4ff" .. (Mancer.DISPLAY_NAME or "Libellus Leti") .. "|r inspect tree not loaded — /reload or restart client.")
        end
        return
    end

    if lower:match("^layout%s") or lower:match("^layout$") then
        local LayoutExport = Mancer.LayoutExport
        if not LayoutExport then
            print("|cff7fd4ff" .. (Mancer.DISPLAY_NAME or "Libellus Leti") .. "|r layout export not loaded yet.")
            return
        end
        local sub = lower:match("^layout%s+(%S+)%s*(.*)$") or (lower == "layout" and "panel" or nil)
        local rest = msg:match("^layout%s+%S+%s*(.*)$") or msg:match("^layout%s+(.*)$") or ""
        if not sub or sub == "panel" or sub == "share" then
            LayoutExport:ShowSharePanel()
            return
        end
        if sub == "export" then
            local full = rest:lower():match("full") ~= nil
            local code = LayoutExport:ExportCopyString(full)
            if LayoutExport:CopyToClipboard(code) then
                Mancer.Print((full and "!Leti:2!" or "!Leti:1!") .. " layout copied (" .. #code .. " chars).")
            else
                Mancer.Print(code)
                Mancer.Print("Select the string above and Ctrl+C to copy.")
            end
            return
        end
        if sub == "import" then
            local payload = rest
            if payload == "" then
                Mancer.Print("Usage: /leti layout import !Leti:2!...")
                return
            end
            local ok, err = LayoutExport:ImportString(payload)
            if ok then
                Mancer.Print("Layout imported.")
            else
                Mancer.Print(err or "Layout import failed.")
            end
            return
        end
        Mancer.Print("Layout: /leti layout share | export [full] | import <code>")
        return
    end

    Mancer.OpenHub()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and (arg1 == "LibellusLeti" or arg1 == "Mancer") then
        MigrateSavedVariables()
        CopyDefaults(MancerDB, DEFAULTS)
        -- Undo Minion Sheet plate boost that survived /reload (CVars persist, memory does not).
        if Mancer.RestorePersistedNameplateCvarBackup then
            Mancer.RestorePersistedNameplateCvarBackup()
        end
        if Mancer.LocaleModule and Mancer.LocaleModule.Apply then
            Mancer.LocaleModule.Apply()
            if Mancer.LocaleModule.GetRegisteredIds then
                local ids = Mancer.LocaleModule.GetRegisteredIds()
                if #ids < 4 and Mancer.Print then
                    Mancer.Print(
                        "Language packs loaded: "
                            .. table.concat(ids, ", ")
                            .. " (expected enUS, deDE, frFR, ruRU)"
                    )
                end
            end
        end
        return
    end

    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        if Mancer.Refresh then
            Mancer:Refresh()
        end
        return
    end

    if event == "PLAYER_LOGIN" then
        local function safeInit(name, fn)
            local ok, err = pcall(fn)
            if not ok and Mancer.Hub then
                Mancer.Hub:Notify("Failed to load " .. name .. ": " .. tostring(err))
            end
            return ok
        end

        safeInit("FloatingText", function()
            if not Mancer.FloatingText then
                Mancer.FloatingText = Mancer.FloatingTextModule:New()
            end
        end)

        safeInit("MinionHpHud", function()
            if Mancer.MinionHpHudModule and not Mancer.MinionHpHud then
                Mancer.MinionHpHud = Mancer.MinionHpHudModule:New()
            end
        end)

        if Mancer.ArcBarsModule then
            safeInit("ArcBars", function()
                if not Mancer.ArcBars then
                    Mancer.ArcBars = Mancer.ArcBarsModule:New()
                end
            end)
        end

        safeInit("RegenTracker", function()
            if not Mancer.RegenTracker then
                Mancer.RegenTracker = Mancer.RegenTrackerModule:New()
            end
        end)

        safeInit("MinionDps", function()
            if Mancer.MinionDpsModule then
                Mancer.MinionDpsModule:Init()
            end
        end)

        safeInit("MinionTooltip", function()
            if Mancer.MinionTooltipModule then
                Mancer.MinionTooltipModule:Init()
            end
        end)

        safeInit("NecromancerAdvisor", function()
            if Mancer.NecromancerAdvisorModule and not Mancer.NecromancerAdvisor then
                Mancer.NecromancerAdvisor = Mancer.NecromancerAdvisorModule:New()
            end
        end)

        safeInit("BuffConsolidate", function()
            if Mancer.BuffConsolidateModule then
                Mancer.BuffConsolidateModule:Init()
            end
        end)

        safeInit("MinimapButton", function()
            if Mancer.MinimapButtonModule then
                Mancer.MinimapButtonModule:Init()
            end
        end)

        safeInit("TalentOverlay", function()
            if Mancer.TalentOverlayModule then
                Mancer.TalentOverlayModule:Init()
            end
        end)

        safeInit("InspectTree", function()
            if Mancer.InspectTreeModule then
                Mancer.InspectTreeModule:Init()
            end
        end)

        safeInit("Hub", function()
            if Mancer.Hub then
                Mancer.Hub:DetachCoASectionRail()
                Mancer.Hub:Create()
                Mancer.Hub:HookCoATalentFrame()
            end
        end)

        Mancer.Options:Initialize()
        Mancer:Refresh()
        Mancer.Print(string.format((Mancer.L and Mancer.L["LOADED"]) or "v%s loaded. Type /leti to open.", Mancer.GetVersion()))
    end
end)

-- Options panel (kept in Core.lua so it always loads with the addon)
local Options = Mancer.Options

-- Game fonts (always present) + bundled Media\\Fonts (addon paths).
-- Later Blizzard names (2002, PVPFont, etc.) are not on Ascension 3.3.5.
local ADDON_FONT = ADDON_ROOT .. "Media\\Fonts\\"
Mancer.FONTS = {
    { name = "Friz Quadrata", path = "Fonts\\FRIZQT__.TTF" },
    { name = "Arial Narrow", path = "Fonts\\ARIALN.TTF" },
    { name = "Skurri", path = "Fonts\\skurri.ttf" },
    { name = "Morpheus", path = "Fonts\\MORPHEUS.TTF" },
    { name = "PT Sans Narrow", path = ADDON_FONT .. "PTSansNarrow-Regular.ttf" },
    { name = "PT Sans Narrow Bold", path = ADDON_FONT .. "PTSansNarrow-Bold.ttf" },
    { name = "Fira Sans Heavy", path = ADDON_FONT .. "FiraSans-Heavy.ttf" },
    { name = "Fira Condensed Heavy", path = ADDON_FONT .. "FiraSansCondensed-Heavy.ttf" },
    { name = "Fira Mono", path = ADDON_FONT .. "FiraMono-Medium.ttf" },
    { name = "Oswald", path = ADDON_FONT .. "Oswald-Regular.ttf" },
    { name = "Forced Square", path = ADDON_FONT .. "ForcedSquare.ttf" },
    { name = "Accidental Presidency", path = ADDON_FONT .. "AccidentalPresidency.ttf" },
    { name = "TrashHand", path = ADDON_FONT .. "TrashHand.ttf" },
}

local DEFAULT_FONT_PATH = "Fonts\\FRIZQT__.TTF"

local function FontPathKnown(path)
    if not path then
        return false
    end
    for _, font in ipairs(Mancer.FONTS) do
        if font.path == path then
            return true
        end
    end
    return false
end

local function GetFontName(path)
    for _, font in ipairs(Mancer.FONTS) do
        if font.path == path then
            return font.name
        end
    end
    return "Friz Quadrata"
end

function Mancer.ResolveFontFile(path)
    if FontPathKnown(path) then
        return path
    end
    return DEFAULT_FONT_PATH
end

local OPTION_TIPS = {
    showMana = {
        title = "Show mana ticks",
        lines = {
            "Shows floating text when you gain mana (regen ticks, potions, etc.).",
            "Appears near your arc / combat text anchors.",
        },
    },
    showHealth = {
        title = "Show health ticks",
        lines = {
            "Shows floating text when you gain health (regen, heals, bandages, etc.).",
            "Appears near your arc / combat text anchors.",
        },
    },
    showRegenRate = {
        title = "Show last mana tick label",
        lines = {
            "Shows a small HUD label with the size of your last mana tick",
            "(for example “Last mana tick: +42”).",
            "Useful while calibrating regen; turn off if you want a cleaner HUD.",
        },
    },
    regenOnly = {
        title = "Regen-only filter",
        lines = {
            "Only show floating mana/health ticks from natural regeneration.",
            "Hides ticks from potions, bandages, spells, and other burst gains.",
            "Leave off if you want every heal and mana gain to appear.",
        },
    },
    showManaBar = {
        title = "Show mana arc bar",
        lines = {
            "Shows the curved mana resource arc around your character.",
            "Uses your chosen bar texture from the options below.",
        },
    },
    showHealthBar = {
        title = "Show health arc bar",
        lines = {
            "Shows the curved health resource arc around your character.",
            "Uses your chosen bar texture from the options below.",
        },
    },
    showRunicBar = {
        title = "Show runic power bar",
        lines = {
            "Duplicate of the mana crescent, shifted left, filled by Runic Power.",
            "Uses the same Bar texture as mana/health.",
            "Only appears when you have a Runic Power pool.",
        },
    },
    showAnimateBar = {
        title = "Show Animate bar",
        lines = {
            "Shows the Animate readiness strip (A handle) with cooldown timers.",
            "Icons auto-update from Animates you have taken in your Character Advancement talent tree.",
            "Ready Animates pulse; while out, the timer is seconds until they despawn; on cooldown icons stay dim.",
            "Left-click an icon to cast that Animate (secure click — never auto-casts).",
            "Spell binding updates out of combat; clicks still work in combat once bound.",
        },
    },
    showProcBar = {
        title = "Show proc bar",
        lines = {
            "Shows a proc/trigger strip (P handle) for Diabolical and Bone King.",
            "Each icon tracks remaining duration (center) and stacks (corner).",
            "Drag P in move mode; mousewheel scales the icons.",
        },
    },
    consolidateBuffs = {
        title = "Stack duplicate buffs",
        lines = {
            "On the default buff bar, merges auras that share the same spell ID into one icon.",
            "Covers every Raise (ghouls, fiends, aboms, skeletons, …) and any other true duplicates.",
            "Uses Ascension’s consolidate pattern (reparent off-strip), not hide/reflow.",
            "Off by default.",
        },
    },
    showZombieCounter = {
        title = "Show zombie counter",
        lines = {
            "Shows a Harvest Plague zombie icon with how many are currently alive.",
            "Requires Unrelenting Army. Drag the Z handle in move mode; mousewheel scales it.",
            "Minion DPS reports also list how many zombies spawned each fight.",
        },
    },
    showMinionHpList = {
        title = "Show minion HP bars",
        lines = {
            "Shows green→red HP bars for permanent guardians (ghoul, skeletons, rogue, fiend, abom).",
            "Turns on friendly nameplates (Friends + Pets + Guardians) so minion tokens exist; restores your previous plate settings when unticked.",
            "Drag H in Layout move mode to reposition.",
            "Use Nameplates (names only) to strip plate bars on guardians while keeping their names.",
        },
    },
    minionHpBarTexture = {
        title = "Minion Texture",
        lines = {
            "Cycles XPerl status-bar skins for minion HP fills (greyscale tinted green→red).",
        },
    },
    hideMinionHpNameplateVisuals = {
        title = "Nameplates (names only)",
        lines = {
            "Hides health/power/cast bars on Ascension nameplates but keeps the floating name text.",
            "Pick Guardians / Players / NPCs / Enemies (or All).",
            "Does not force plates on — use V / Interface options to enable plates; this only strips bars.",
        },
    },
    nameplateNamesOnly_all = {
        title = "Nameplates: All",
        lines = {
            "Names-only on every nameplate type (guardians, players, NPCs, enemies).",
        },
    },
    nameplateNamesOnly_guardians = {
        title = "Nameplates: Guardians",
        lines = {
            "Names-only on your guardians/pets (bars hidden, name text kept).",
        },
    },
    nameplateNamesOnly_players = {
        title = "Nameplates: Players",
        lines = {
            "Names-only on friendly player nameplates.",
        },
    },
    nameplateNamesOnly_npcs = {
        title = "Nameplates: NPCs",
        lines = {
            "Names-only on friendly NPC nameplates.",
        },
    },
    nameplateNamesOnly_enemies = {
        title = "Nameplates: Enemies",
        lines = {
            "Names-only on enemy nameplates.",
        },
    },
    disableNameplatesInCapitals = {
        title = "Mute plates in capitals",
        lines = {
            "Temporarily turns nameplates off in capital cities (Orgrimmar, Stormwind, Undercity, Dalaran, …) to save FPS.",
            "Restores your previous plate settings when you leave.",
            "Pauses while the Minion Sheet is open (sheet needs plate tokens).",
        },
    },
    showWhere = {
        title = "Where",
        lines = {
            "Controls where Undead stance prompts appear.",
            "Tick any mix of Open world, Raids, Dungeons, Arena, and Battlegrounds.",
            "All checks every place; unticking one clears All.",
        },
    },
    showWhere_all = {
        title = "All",
        lines = {
            "Tick to enable stance prompts everywhere.",
            "Untick to clear Open world, Raids, Dungeons, Arena, and Battlegrounds.",
        },
    },
    showWhere_world = {
        title = "Open world",
        lines = {
            "Show stance prompts in open world.",
            "Can be combined with Raids, Dungeons, Arena, and Battlegrounds.",
        },
    },
    showWhere_raid = {
        title = "Raids",
        lines = {
            "Show stance prompts in raids.",
            "Can be combined with Open world, Dungeons, Arena, and Battlegrounds.",
        },
    },
    showWhere_dungeon = {
        title = "Dungeons",
        lines = {
            "Show stance prompts in dungeons.",
            "Can be combined with Open world, Raids, Arena, and Battlegrounds.",
        },
    },
    showWhere_arena = {
        title = "Arena",
        lines = {
            "Show stance prompts in arenas.",
            "Can be combined with Open world, Raids, Dungeons, and Battlegrounds.",
        },
    },
    showWhere_battleground = {
        title = "Battlegrounds",
        lines = {
            "Show stance prompts in battlegrounds.",
            "Can be combined with Open world, Raids, Dungeons, and Arena.",
        },
    },
    showMinimapButton = {
        title = "Show minimap button",
        lines = {
            "Shows the Libellus Leti button on the minimap.",
            "Right-click the button for Hub / Settings / Language / Hide shortcuts.",
        },
    },
    minionDpsTooltips = {
        title = "Minion DPS spell tooltips",
        lines = {
            "Adds estimated minion DPS notes to relevant spell tooltips.",
            "Turn off if you want the default Ascension tooltip text only.",
        },
    },
}

local function ShowOptionTip(owner, tip)
    if not tip or not GameTooltip then
        return
    end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    local accent = Mancer.UI and Mancer.UI.Colors and Mancer.UI.Colors.accent
    if accent then
        GameTooltip:AddLine(tip.title, accent[1], accent[2], accent[3])
    else
        GameTooltip:AddLine(tip.title, 0.25, 0.95, 0.75)
    end
    for _, line in ipairs(tip.lines or {}) do
        GameTooltip:AddLine(line, 0.9, 0.9, 0.9, true)
    end
    GameTooltip:Show()
end

local function AttachOptionTip(frame, dbKey)
    local tip = OPTION_TIPS[dbKey]
    if not frame or not tip then
        return
    end
    frame:EnableMouse(true)
    frame:SetScript("OnEnter", function(self)
        ShowOptionTip(self, tip)
    end)
    frame:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
end

local function CreateSectionLabel(parent, text, anchorTo, yOffset, sectionWidth)
    local section
    if Mancer.UI and Mancer.UI.CreateSection then
        section = Mancer.UI.CreateSection(parent, text, anchorTo, yOffset or -16)
    else
        local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        label:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, yOffset or -16)
        label:SetText(text)
        section = label
    end
    if section and section.SetWidth and sectionWidth then
        section:SetWidth(sectionWidth)
    end
    return section
end

local function CheckboxIsOn(cb)
    if not cb or not cb.GetChecked then
        return false
    end
    local v = cb:GetChecked()
    return v == 1 or v == true
end

local function CreateCheckboxRow(parent, label, anchorTo, yGap, dbKey, rowWidth)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(rowWidth or 240, 24)
    row:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, yGap)

    local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    cb:SetSize(24, 24)
    cb:SetPoint("LEFT", row, "LEFT", 0, 0)

    local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", cb, "RIGHT", 6, 0)
    text:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    text:SetJustifyH("LEFT")
    text:SetText(label)
    if Mancer.UI and Mancer.UI.StyleTitle then
        Mancer.UI.StyleTitle(text)
    end

    -- Invisible hit area over the label (FontStrings do not receive mouse).
    local hit = CreateFrame("Button", nil, row)
    hit:SetPoint("LEFT", text, "LEFT", -2, 0)
    hit:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    hit:SetHeight(20)
    hit:SetFrameLevel((row:GetFrameLevel() or 1) + 2)
    hit:RegisterForClicks("AnyUp")
    hit:SetScript("OnClick", function()
        cb:Click()
    end)

    AttachOptionTip(cb, dbKey)
    AttachOptionTip(hit, dbKey)

    if dbKey then
        cb:SetScript("OnClick", function(self)
            MancerDB[dbKey] = CheckboxIsOn(self)
            Mancer:Refresh()
        end)
    end

    row.checkbox = cb
    row.hit = hit
    return row
end

local function CreateButton(parent, width, height, text, anchorTo, x, y)
    -- Native red/gold UIPanel buttons (same family as Hub / Minion Sheet arrows).
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(width, height)
    btn:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", x, y)
    btn:SetText(text)
    return btn
end

function Options:GetBarTextureIndex()
    local path = Mancer.NormalizeBarTexturePath(MancerDB.barTexture or Mancer.BAR_TEXTURES[1].path)
    for i, entry in ipairs(Mancer.BAR_TEXTURES) do
        if entry.path == path then
            return i
        end
    end
    return 1
end

function Options:CycleBarTexture(delta)
    local index = self:GetBarTextureIndex() + delta
    if index > #Mancer.BAR_TEXTURES then
        index = 1
    elseif index < 1 then
        index = #Mancer.BAR_TEXTURES
    end

    MancerDB.barTexture = Mancer.BAR_TEXTURES[index].path
    if self.barValueText then
        self.barValueText:SetText(Mancer.BAR_TEXTURES[index].name)
    end
    if Mancer.ArcBars then
        Mancer.ArcBars:ApplyConfig()
    else
        Mancer:Refresh()
    end
end

function Options:CycleMinionHpBarTexture(delta)
    if not Mancer.MinionHpHud or not Mancer.MinionHpHud.CycleBarTexture then
        return
    end
    local name = Mancer.MinionHpHud:CycleBarTexture(delta)
    if self.minionHpBarValueText then
        self.minionHpBarValueText:SetText(name or "?")
    end
end

function Options:GetFontIndex()
    local path = Mancer.ResolveFontFile(MancerDB.fontFile)
    for i, font in ipairs(Mancer.FONTS) do
        if font.path == path then
            return i
        end
    end
    return 1
end

function Options:CycleFont(delta)
    local index = self:GetFontIndex() + delta
    if index > #Mancer.FONTS then
        index = 1
    elseif index < 1 then
        index = #Mancer.FONTS
    end

    MancerDB.fontFile = Mancer.FONTS[index].path
    if self.fontValueText then
        self.fontValueText:SetText(Mancer.FONTS[index].name)
    end
    Mancer:Refresh()
    if Mancer.FloatingText then
        Mancer.FloatingText:ShowTick("+12 mana", MancerDB.manaColor, "mana")
    end
end

function Options:ChangeFontSize(delta)
    local size = (MancerDB.fontSize or 22) + delta
    size = math.max(12, math.min(48, size))
    MancerDB.fontSize = size
    if self.sizeValueText then
        self.sizeValueText:SetText(tostring(size))
    end
    Mancer:Refresh()
    if Mancer.FloatingText then
        Mancer.FloatingText:ShowTick("+" .. size .. " mana", MancerDB.manaColor, "mana")
    end
end

function Options:UpdateMoveButton()
    if not self.moveBtn then
        return
    end

    local inMoveMode = Mancer.FloatingText and Mancer.FloatingText.moveMode
    local L = Mancer.L or {}
    if inMoveMode then
        self.moveBtn:SetText(L["BTN_HIDE"] or "Hide")
    else
        self.moveBtn:SetText(L["BTN_SHOW"] or "Show")
    end
end

function Options:ResetBarLayout()
    MancerDB.barTransform = {
        unified = { scale = 1.0, width = 1.0, height = 1.0, offsetX = 0, offsetY = 0 },
        mana = { width = 1.0, height = 1.0, offsetX = 0, offsetY = 0 },
        health = { width = 1.0, height = 1.0, offsetX = 0, offsetY = 0 },
    }
    MancerDB.advisorTextOffset = { x = 0, y = 28 }
    MancerDB.animateBarOffset = { x = 0, y = -40 }
    MancerDB.zombieCounterOffset = { x = 56, y = -40 }
    MancerDB.procBarOffset = { x = -56, y = -40 }
    MancerDB.animateIconScale = 0.75
    MancerDB.zombieIconScale = 0.85
    MancerDB.procIconScale = 0.8
    MancerDB.advisorTextScale = 1.0
    MancerDB.minionHpListOffset = { x = 90, y = 20 }
    MancerDB.arcBarAlpha = 1.0
    MancerDB.animateBarAlpha = 1.0
    MancerDB.zombieCounterAlpha = 1.0
    MancerDB.procBarAlpha = 1.0
    MancerDB.minionHpListAlpha = 1.0
    if Mancer.FloatingText then
        Mancer.FloatingText:SetMoveMode(false)
    end
    Mancer:Refresh()
end

function Options:ToggleMoveMode()
    if not Mancer.FloatingText then
        return
    end

    Mancer.FloatingText:SetMoveMode(not Mancer.FloatingText.moveMode)
    self:UpdateMoveButton()
end

function Options:SyncControls()
    if not self.window or not MancerDB then
        return
    end

    self.rowMana.checkbox:SetChecked(MancerDB.showMana and 1 or nil)
    self.rowHealth.checkbox:SetChecked(MancerDB.showHealth and 1 or nil)
    self.rowRate.checkbox:SetChecked(MancerDB.showRegenRate and 1 or nil)
    self.rowRegenOnly.checkbox:SetChecked(MancerDB.regenOnly and 1 or nil)
    self.rowManaBar.checkbox:SetChecked(MancerDB.showManaBar and 1 or nil)
    self.rowHealthBar.checkbox:SetChecked(MancerDB.showHealthBar and 1 or nil)
    if self.rowRunicBar then
        self.rowRunicBar.checkbox:SetChecked(MancerDB.showRunicBar ~= false and 1 or nil)
    end
    if self.rowAnimateBar then
        self.rowAnimateBar.checkbox:SetChecked(MancerDB.showAnimateBar ~= false and 1 or nil)
    end
    if self.rowProcBar then
        self.rowProcBar.checkbox:SetChecked(MancerDB.showProcBar ~= false and 1 or nil)
    end
    if self.rowConsolidateBuffs then
        self.rowConsolidateBuffs.checkbox:SetChecked(MancerDB.consolidateBuffs == true and 1 or nil)
    end
    if self.rowZombieCounter then
        self.rowZombieCounter.checkbox:SetChecked(MancerDB.showZombieCounter ~= false and 1 or nil)
    end
    if self.rowMinionHpList then
        self.rowMinionHpList.checkbox:SetChecked(MancerDB.showMinionHpList == true and 1 or nil)
    end
    if self.plateNamesOnlyRows then
        local targets = Mancer.GetPlateNamesOnlyTargets and Mancer.GetPlateNamesOnlyTargets() or {}
        local allOn = Mancer.IsPlateNamesOnlyAllOn and Mancer.IsPlateNamesOnlyAllOn()
        for id, row in pairs(self.plateNamesOnlyRows) do
            if row.checkbox then
                local on = (id == "all") and allOn or targets[id]
                row.checkbox:SetChecked(on and 1 or nil)
            end
        end
    end
    if self.rowMuteCapitalPlates and self.rowMuteCapitalPlates.checkbox then
        self.rowMuteCapitalPlates.checkbox:SetChecked(MancerDB.disableNameplatesInCapitals ~= false and 1 or nil)
    end

    if self.rowMinimap then
        local hidden = MancerDB.minimap and MancerDB.minimap.hide
        self.rowMinimap.checkbox:SetChecked(not hidden and 1 or nil)
    end
    if self.rowTooltip then
        MancerDB.minionDps = MancerDB.minionDps or {}
        local enabled = MancerDB.minionDps.tooltipEnabled ~= false
        self.rowTooltip.checkbox:SetChecked(enabled and 1 or nil)
    end

    if self.barValueText then
        self.barValueText:SetText(Mancer.GetBarTextureName(MancerDB.barTexture))
    end
    if self.minionHpBarValueText and Mancer.MinionHpHud and Mancer.MinionHpHud.GetBarTextureName then
        self.minionHpBarValueText:SetText(Mancer.MinionHpHud:GetBarTextureName())
    end

    if self.fontValueText then
        self.fontValueText:SetText(GetFontName(Mancer.ResolveFontFile(MancerDB.fontFile)))
    end
    if self.sizeValueText then
        self.sizeValueText:SetText(tostring(MancerDB.fontSize or 22))
    end

    if self.whereRows then
        local places = Mancer.GetShowWherePlaces and Mancer.GetShowWherePlaces() or DefaultShowWherePlaces()
        local allOn = PlacesAllEnabled(places)
        for id, row in pairs(self.whereRows) do
            if row.checkbox then
                local on = (id == "all") and allOn or places[id]
                row.checkbox:SetChecked(on and 1 or nil)
            end
        end
    end

    self:UpdateMoveButton()
end

local function ClearFrameChildren(frame)
    if not frame then
        return
    end
    local regions = { frame:GetRegions() }
    for i = 1, #regions do
        local region = regions[i]
        if region then
            region:Hide()
            if region.ClearAllPoints then
                region:ClearAllPoints()
            end
            if region.SetText then
                region:SetText("")
            end
        end
    end
    local children = { frame:GetChildren() }
    for i = 1, #children do
        local child = children[i]
        if child then
            ClearFrameChildren(child)
            child:Hide()
            child:EnableMouse(false)
            child:ClearAllPoints()
            child:SetParent(nil)
        end
    end
end

function Options:SelectSettingsTab(tabId)
    if not self.tabPages then
        return
    end
    if not self.tabPages[tabId] then
        tabId = "stance"
    end
    self.settingsTab = tabId
    MancerDB = MancerDB or {}
    MancerDB.settingsTab = tabId

    for id, page in pairs(self.tabPages) do
        if id == tabId then
            page:Show()
        else
            page:Hide()
        end
    end

    for id, btn in pairs(self.tabButtons or {}) do
        local selected = id == tabId
        if selected then
            btn:Disable()
            btn:SetButtonState("DISABLED", true)
        else
            btn:Enable()
            btn:SetButtonState("NORMAL")
        end
    end

    if tabId == "share" and Mancer.LayoutExport and Mancer.LayoutExport.RefreshShareExport then
        Mancer.LayoutExport:RefreshShareExport()
    end
end

function Options:CreatePanel()
    local L = Mancer.L or {}
    local ui = Mancer.UI
    -- Rebuild when version changes so new stance rows (Arena / Battlegrounds) appear.
    local ver = Mancer.GetVersion and Mancer.GetVersion() or Mancer.VERSION
    if self.window and self.settingsUIVersion ~= ver then
        self.forceRebuildDisplay = true
    end
    local rebuilding = self.window and self.forceRebuildDisplay
    if self.window and not self.forceRebuildDisplay then
        return
    end
    self.forceRebuildDisplay = false
    self.settingsUIVersion = ver

    local settingsTitle = L["DISPLAY_TITLE"] or ((Mancer.DISPLAY_NAME or "Libellus Leti") .. " Settings")

    local window = self.window
    if not window then
        if ui and ui.CreateMovableChromeWindow then
            window, self.panel = ui.CreateMovableChromeWindow("MancerConfigFrame", {
                width = 580,
                height = 560,
                title = settingsTitle,
            })
            self.window = window
        else
            window = CreateFrame("Frame", "MancerConfigFrame", UIParent)
            window:SetSize(580, 560)
            window:SetPoint("CENTER")
            window:SetMovable(true)
            window:EnableMouse(true)
            window:RegisterForDrag("LeftButton")
            window:SetScript("OnDragStart", function(frame)
                frame:StartMoving()
            end)
            window:SetScript("OnDragStop", function(frame)
                frame:StopMovingOrSizing()
            end)
            window:SetFrameStrata("DIALOG")
            window:Hide()
            local panel = CreateFrame("Frame", nil, window)
            panel:SetPoint("TOPLEFT", 22, -68)
            panel:SetPoint("BOTTOMRIGHT", -22, 28)
            self.window = window
            self.panel = panel
            if UISpecialFrames then
                tinsert(UISpecialFrames, "MancerConfigFrame")
            end
        end
    elseif rebuilding and self.panel then
        ClearFrameChildren(self.panel)
        if window.SetSize then
            window:SetSize(580, 560)
        end
        if window.TitleText and window.TitleText.SetText then
            window.TitleText:SetText(settingsTitle)
        elseif window.titleText and window.titleText.SetText then
            window.titleText:SetText(settingsTitle)
        end
    end

    local panel = self.panel
    if not panel then
        return
    end

    local desc = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
    desc:SetWidth(520)
    desc:SetJustifyH("LEFT")
    desc:SetText(L["DISPLAY_DESC"] or "Stance prompts, HUD bars, nameplates, and appearance.")
    if ui and ui.StyleMuted then
        ui.StyleMuted(desc)
    end

    -- Fixed Layout strip at the bottom (shared across all tabs).
    local layoutFooter = CreateFrame("Frame", nil, panel)
    layoutFooter:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 0, 0)
    layoutFooter:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
    layoutFooter:SetHeight(64)

    local layoutHeader = CreateSectionLabel(layoutFooter, L["SECTION_LAYOUT"] or "Layout", layoutFooter, 0, 520)
    layoutHeader:ClearAllPoints()
    layoutHeader:SetPoint("TOPLEFT", layoutFooter, "TOPLEFT", 0, 0)

    self.moveBtn = CreateButton(layoutFooter, 120, 24, L["BTN_SHOW"] or "Show", layoutHeader, 0, -8)
    self.moveBtn:ClearAllPoints()
    self.moveBtn:SetPoint("TOPLEFT", layoutHeader, "BOTTOMLEFT", 0, -8)
    self.moveBtn:SetScript("OnClick", function()
        Options:ToggleMoveMode()
    end)

    local testBtn = CreateButton(layoutFooter, 120, 24, L["BTN_TEST_PREVIEW"] or "Test Preview", self.moveBtn, 0, 0)
    testBtn:ClearAllPoints()
    testBtn:SetPoint("LEFT", self.moveBtn, "RIGHT", 8, 0)
    testBtn:SetScript("OnClick", function()
        if Mancer.FloatingText then
            Mancer.FloatingText:ShowTick("+42 mana", MancerDB.manaColor, "mana")
            Mancer.FloatingText:ShowTick("+18 health", MancerDB.healthColor, "health")
            Mancer.FloatingText:UpdateRateText(42)
        end
    end)

    local resetBtn = CreateButton(layoutFooter, 100, 24, L["BTN_RESET_BARS"] or "Reset Bars", testBtn, 0, 0)
    resetBtn:ClearAllPoints()
    resetBtn:SetPoint("LEFT", testBtn, "RIGHT", 8, 0)
    resetBtn:SetScript("OnClick", function()
        Options:ResetBarLayout()
    end)
    -- Share lives on the Share tab only (no duplicate footer button).

    -- Tab strip under the description.
    local tabDefs = {
        { id = "stance", label = L["SETTINGS_TAB_STANCE"] or "Stance Prompts", width = 118 },
        { id = "display", label = L["SETTINGS_TAB_DISPLAY"] or "Display", width = 80 },
        { id = "nameplates", label = L["SETTINGS_TAB_NAMEPLATES"] or "Nameplates", width = 100 },
        { id = "appearance", label = L["SETTINGS_TAB_APPEARANCE"] or "Appearance", width = 100 },
        { id = "share", label = L["SETTINGS_TAB_SHARE"] or "Share", width = 72 },
    }

    local tabBar = CreateFrame("Frame", nil, panel)
    tabBar:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -10)
    tabBar:SetPoint("RIGHT", panel, "RIGHT", 0, 0)
    tabBar:SetHeight(26)

    self.tabButtons = {}
    local tabPrev = nil
    for _, def in ipairs(tabDefs) do
        local btn = CreateFrame("Button", nil, tabBar, "UIPanelButtonTemplate")
        btn:SetSize(def.width, 24)
        if tabPrev then
            btn:SetPoint("LEFT", tabPrev, "RIGHT", 4, 0)
        else
            btn:SetPoint("LEFT", tabBar, "LEFT", 0, 0)
        end
        btn:SetText(def.label)
        btn:SetScript("OnClick", function()
            Options:SelectSettingsTab(def.id)
        end)
        self.tabButtons[def.id] = btn
        tabPrev = btn
    end

    local contentHost = CreateFrame("Frame", nil, panel)
    contentHost:SetPoint("TOPLEFT", tabBar, "BOTTOMLEFT", 0, -10)
    contentHost:SetPoint("BOTTOMRIGHT", layoutFooter, "TOPRIGHT", 0, 8)

    local function MakePage(id)
        local page = CreateFrame("Frame", nil, contentHost)
        page:SetAllPoints(contentHost)
        page:Hide()
        return page
    end

    self.tabPages = {
        stance = MakePage("stance"),
        display = MakePage("display"),
        nameplates = MakePage("nameplates"),
        appearance = MakePage("appearance"),
        share = MakePage("share"),
    }

    if Mancer.LayoutExport then
        -- Force remount after Settings rebuild (old host widgets were cleared).
        Mancer.LayoutExport.shareHost = nil
        Mancer.LayoutExport.exportBox = nil
        Mancer.LayoutExport.sharePanel = nil
        if Mancer.LayoutExport.MountShareUI then
            Mancer.LayoutExport:MountShareUI(self.tabPages.share)
        end
    end

    -- Tab: Stance Prompts (where Undead stance reminders may show).
    do
        local page = self.tabPages.stance
        local tip = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        tip:SetPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
        tip:SetWidth(520)
        tip:SetJustifyH("LEFT")
        tip:SetText(L["SETTINGS_STANCE_TIP"] or "Choose where Undead stance prompts are allowed to appear.")
        if ui and ui.StyleMuted then
            ui.StyleMuted(tip)
        end

        self.whereRows = {}
        local whereAnchor = tip
        -- Prefer live list from GetShowWhereOptions (includes Arena / Battlegrounds).
        local whereOptions = Mancer.GetShowWhereOptions and Mancer.GetShowWhereOptions() or nil
        if type(whereOptions) ~= "table" or #whereOptions < 6 then
            whereOptions = {
                { id = "all", label = L["WHERE_ALL"] or "All" },
                { id = "world", label = L["WHERE_WORLD"] or "Open world" },
                { id = "raid", label = L["WHERE_RAID"] or "Raids" },
                { id = "dungeon", label = L["WHERE_DUNGEON"] or "Dungeons" },
                { id = "arena", label = L["WHERE_ARENA"] or "Arena" },
                { id = "battleground", label = L["WHERE_BATTLEGROUND"] or "Battlegrounds" },
            }
        end
        for i, opt in ipairs(whereOptions) do
            local tipKey = "showWhere_" .. opt.id
            local row = CreateCheckboxRow(page, opt.label, whereAnchor, i == 1 and -10 or -4, tipKey, 280)
            row:Show()
            local function applyWhereClick(checked)
                if Mancer.SetShowWherePlace then
                    Mancer.SetShowWherePlace(opt.id, checked)
                else
                    Mancer.SetShowWhere(opt.id)
                end
                Options:SyncControls()
            end
            row.checkbox:SetScript("OnClick", function(self)
                applyWhereClick(CheckboxIsOn(self))
            end)
            row.hit:SetScript("OnClick", function()
                local checked = not CheckboxIsOn(row.checkbox)
                row.checkbox:SetChecked(checked and 1 or nil)
                applyWhereClick(checked)
            end)
            AttachOptionTip(row.checkbox, tipKey)
            AttachOptionTip(row.hit, tipKey)
            self.whereRows[opt.id] = row
            whereAnchor = row
        end
    end

    -- Tab: Display (HUD toggles).
    do
        local page = self.tabPages.display
        local dispLeft = CreateFrame("Frame", nil, page)
        dispLeft:SetPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
        dispLeft:SetPoint("BOTTOM", page, "BOTTOM", 0, 0)
        dispLeft:SetWidth(250)

        local dispRight = CreateFrame("Frame", nil, page)
        dispRight:SetPoint("TOPLEFT", dispLeft, "TOPRIGHT", 16, 0)
        dispRight:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", 0, 0)

        local dispLeftTop = CreateFrame("Frame", nil, dispLeft)
        dispLeftTop:SetPoint("TOPLEFT", dispLeft, "TOPLEFT", 0, 0)
        dispLeftTop:SetSize(1, 1)
        local dispRightTop = CreateFrame("Frame", nil, dispRight)
        dispRightTop:SetPoint("TOPLEFT", dispRight, "TOPLEFT", 0, 0)
        dispRightTop:SetSize(1, 1)

        self.rowMana = CreateCheckboxRow(dispLeft, L["OPT_SHOW_MANA"] or "Show mana ticks", dispLeftTop, 0, "showMana", 248)
        self.rowHealth = CreateCheckboxRow(dispLeft, L["OPT_SHOW_HEALTH"] or "Show health ticks", self.rowMana, -2, "showHealth", 248)
        self.rowRate = CreateCheckboxRow(dispLeft, L["OPT_SHOW_REGEN_RATE"] or "Show last mana tick label", self.rowHealth, -2, "showRegenRate", 248)
        self.rowRegenOnly = CreateCheckboxRow(dispLeft, L["OPT_REGEN_ONLY"] or "Regen-only filter", self.rowRate, -2, "regenOnly", 248)
        self.rowManaBar = CreateCheckboxRow(dispLeft, L["OPT_SHOW_MANA_BAR"] or "Show mana arc bar", self.rowRegenOnly, -2, "showManaBar", 248)
        self.rowHealthBar = CreateCheckboxRow(dispLeft, L["OPT_SHOW_HEALTH_BAR"] or "Show health arc bar", self.rowManaBar, -2, "showHealthBar", 248)
        self.rowRunicBar = CreateCheckboxRow(dispLeft, L["OPT_SHOW_RUNIC_BAR"] or "Show runic power bar", self.rowHealthBar, -2, "showRunicBar", 248)
        self.rowAnimateBar = CreateCheckboxRow(dispLeft, L["OPT_SHOW_ANIMATE_BAR"] or "Show Animate bar", self.rowRunicBar, -2, "showAnimateBar", 248)

        self.rowConsolidateBuffs = CreateCheckboxRow(dispRight, L["OPT_CONSOLIDATE_BUFFS"] or "Stack duplicate buffs", dispRightTop, 0, "consolidateBuffs", 248)
        self.rowProcBar = CreateCheckboxRow(dispRight, L["OPT_SHOW_PROC_BAR"] or "Show proc bar", self.rowConsolidateBuffs, -2, "showProcBar", 248)
        self.rowZombieCounter = CreateCheckboxRow(dispRight, L["OPT_SHOW_ZOMBIE"] or "Show zombie counter", self.rowProcBar, -2, "showZombieCounter", 248)
        self.rowMinionHpList = CreateCheckboxRow(dispRight, L["OPT_SHOW_MINION_HP"] or "Show minion HP bars", self.rowZombieCounter, -2, "showMinionHpList", 248)
        self.rowMinimap = CreateCheckboxRow(dispRight, L["OPT_SHOW_MINIMAP"] or "Show minimap button", self.rowMinionHpList, -2, "showMinimapButton", 248)
        self.rowMinimap.checkbox:SetScript("OnClick", function(self)
            local show = CheckboxIsOn(self)
            if Mancer.MinimapButtonModule then
                Mancer.MinimapButtonModule:SetHidden(not show)
            else
                MancerDB.minimap = MancerDB.minimap or {}
                MancerDB.minimap.hide = not show
            end
        end)

        self.rowTooltip = CreateCheckboxRow(dispRight, L["OPT_MINION_TOOLTIPS"] or "Minion DPS spell tooltips", self.rowMinimap, -2, "minionDpsTooltips", 248)
        self.rowTooltip.checkbox:SetScript("OnClick", function(self)
            local enabled = CheckboxIsOn(self)
            if Mancer.MinionTooltipModule then
                Mancer.MinionTooltipModule:SetEnabled(enabled)
            else
                MancerDB.minionDps = MancerDB.minionDps or {}
                MancerDB.minionDps.tooltipEnabled = enabled
            end
        end)
    end

    -- Tab: Nameplates (names only).
    do
        local page = self.tabPages.nameplates
        local tip = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        tip:SetPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
        tip:SetWidth(520)
        tip:SetJustifyH("LEFT")
        tip:SetText(L["SETTINGS_NAMEPLATES_TIP"] or "Hide health/power/cast bars on Ascension nameplates but keep the floating name text.")
        if ui and ui.StyleMuted then
            ui.StyleMuted(tip)
        end

        self.plateNamesOnlyRows = {}
        local plateOptions = Mancer.GetPlateNamesOnlyOptions and Mancer.GetPlateNamesOnlyOptions() or {
            { id = "all", label = L["PLATE_ALL"] or "All" },
            { id = "guardians", label = L["PLATE_GUARDIANS"] or "Guardians" },
            { id = "players", label = L["PLATE_PLAYERS"] or "Players" },
            { id = "npcs", label = L["PLATE_NPCS"] or "NPCs" },
            { id = "enemies", label = L["PLATE_ENEMIES"] or "Enemies" },
        }
        local plateAnchor = tip
        for i, opt in ipairs(plateOptions) do
            local tipKey = "nameplateNamesOnly_" .. opt.id
            local row = CreateCheckboxRow(page, opt.label, plateAnchor, i == 1 and -10 or -2, tipKey, 260)
            local function applyPlateClick(checked)
                if Mancer.SetPlateNamesOnlyTarget then
                    Mancer.SetPlateNamesOnlyTarget(opt.id, checked)
                end
                Options:SyncControls()
            end
            row.checkbox:SetScript("OnClick", function(self)
                applyPlateClick(CheckboxIsOn(self))
            end)
            row.hit:SetScript("OnClick", function()
                local checked = not CheckboxIsOn(row.checkbox)
                row.checkbox:SetChecked(checked and 1 or nil)
                applyPlateClick(checked)
            end)
            AttachOptionTip(row.checkbox, tipKey)
            AttachOptionTip(row.hit, tipKey)
            self.plateNamesOnlyRows[opt.id] = row
            plateAnchor = row
        end

        local capitalRow = CreateCheckboxRow(
            page,
            L["OPT_MUTE_PLATES_CAPITALS"] or "Mute nameplates in capital cities",
            plateAnchor,
            -10,
            "disableNameplatesInCapitals",
            360
        )
        capitalRow.checkbox:SetScript("OnClick", function(self)
            local on = CheckboxIsOn(self)
            if Mancer.SetDisableNameplatesInCapitals then
                Mancer.SetDisableNameplatesInCapitals(on)
            else
                MancerDB.disableNameplatesInCapitals = on
                Mancer:Refresh()
            end
            Options:SyncControls()
        end)
        capitalRow.hit:SetScript("OnClick", function()
            local checked = not CheckboxIsOn(capitalRow.checkbox)
            capitalRow.checkbox:SetChecked(checked and 1 or nil)
            if Mancer.SetDisableNameplatesInCapitals then
                Mancer.SetDisableNameplatesInCapitals(checked)
            else
                MancerDB.disableNameplatesInCapitals = checked
                Mancer:Refresh()
            end
            Options:SyncControls()
        end)
        self.rowMuteCapitalPlates = capitalRow
    end

    -- Tab: Appearance (bar / minion textures + font).
    do
        local page = self.tabPages.appearance

        local barHeader = CreateSectionLabel(page, L["SECTION_BAR_TEXTURE"] or "Bar texture", page, 0, 250)
        barHeader:ClearAllPoints()
        barHeader:SetPoint("TOPLEFT", page, "TOPLEFT", 0, 0)

        local barPrev = CreateButton(page, 32, 22, "<", barHeader, 0, -6)
        barPrev:ClearAllPoints()
        barPrev:SetPoint("TOPLEFT", barHeader, "BOTTOMLEFT", 0, -6)
        local barNext = CreateButton(page, 32, 22, ">", barHeader, 36, -6)
        barNext:ClearAllPoints()
        barNext:SetPoint("LEFT", barPrev, "RIGHT", 4, 0)

        self.barValueText = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        self.barValueText:SetPoint("LEFT", barNext, "RIGHT", 8, 0)
        self.barValueText:SetWidth(200)
        self.barValueText:SetJustifyH("LEFT")
        self.barValueText:SetText("Runed Metal")

        barPrev:SetScript("OnClick", function()
            Options:CycleBarTexture(-1)
        end)
        barNext:SetScript("OnClick", function()
            Options:CycleBarTexture(1)
        end)

        local minionBarHeader = CreateSectionLabel(page, L["SECTION_MINION_HP_BAR"] or "Minion Texture", barPrev, -16, 250)
        minionBarHeader:ClearAllPoints()
        minionBarHeader:SetPoint("TOPLEFT", barPrev, "BOTTOMLEFT", 0, -16)

        local minionBarPrev = CreateButton(page, 32, 22, "<", minionBarHeader, 0, -6)
        minionBarPrev:ClearAllPoints()
        minionBarPrev:SetPoint("TOPLEFT", minionBarHeader, "BOTTOMLEFT", 0, -6)
        local minionBarNext = CreateButton(page, 32, 22, ">", minionBarHeader, 36, -6)
        minionBarNext:ClearAllPoints()
        minionBarNext:SetPoint("LEFT", minionBarPrev, "RIGHT", 4, 0)

        self.minionHpBarValueText = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        self.minionHpBarValueText:SetPoint("LEFT", minionBarNext, "RIGHT", 8, 0)
        self.minionHpBarValueText:SetWidth(200)
        self.minionHpBarValueText:SetJustifyH("LEFT")
        self.minionHpBarValueText:SetText("Abstract")

        minionBarPrev:SetScript("OnClick", function()
            Options:CycleMinionHpBarTexture(-1)
        end)
        minionBarNext:SetScript("OnClick", function()
            Options:CycleMinionHpBarTexture(1)
        end)

        local fontHeader = CreateSectionLabel(page, L["SECTION_FONT"] or "Font", minionBarPrev, -16, 250)
        fontHeader:ClearAllPoints()
        fontHeader:SetPoint("TOPLEFT", minionBarPrev, "BOTTOMLEFT", 0, -16)

        local fontPrev = CreateButton(page, 32, 22, "<", fontHeader, 0, -6)
        fontPrev:ClearAllPoints()
        fontPrev:SetPoint("TOPLEFT", fontHeader, "BOTTOMLEFT", 0, -6)
        local fontNext = CreateButton(page, 32, 22, ">", fontHeader, 36, -6)
        fontNext:ClearAllPoints()
        fontNext:SetPoint("LEFT", fontPrev, "RIGHT", 4, 0)

        self.fontValueText = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        self.fontValueText:SetPoint("LEFT", fontNext, "RIGHT", 8, 0)
        self.fontValueText:SetWidth(200)
        self.fontValueText:SetJustifyH("LEFT")
        self.fontValueText:SetText("Friz Quadrata")

        fontPrev:SetScript("OnClick", function()
            Options:CycleFont(-1)
        end)
        fontNext:SetScript("OnClick", function()
            Options:CycleFont(1)
        end)

        local sizeHeader = CreateSectionLabel(page, L["SECTION_FONT_SIZE"] or "Font size", fontPrev, -16, 250)
        sizeHeader:ClearAllPoints()
        sizeHeader:SetPoint("TOPLEFT", fontPrev, "BOTTOMLEFT", 0, -16)

        local sizeMinus = CreateButton(page, 32, 22, "-", sizeHeader, 0, -6)
        sizeMinus:ClearAllPoints()
        sizeMinus:SetPoint("TOPLEFT", sizeHeader, "BOTTOMLEFT", 0, -6)
        local sizePlus = CreateButton(page, 32, 22, "+", sizeHeader, 36, -6)
        sizePlus:ClearAllPoints()
        sizePlus:SetPoint("LEFT", sizeMinus, "RIGHT", 4, 0)

        self.sizeValueText = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        self.sizeValueText:SetPoint("LEFT", sizePlus, "RIGHT", 8, 0)
        self.sizeValueText:SetText("22")

        sizeMinus:SetScript("OnClick", function()
            Options:ChangeFontSize(-2)
        end)
        sizePlus:SetScript("OnClick", function()
            Options:ChangeFontSize(2)
        end)
    end

    local startTab = (MancerDB and MancerDB.settingsTab) or self.settingsTab or "stance"
    self:SelectSettingsTab(startTab)

    window:SetScript("OnShow", function()
        Options:SyncControls()
        Options:SelectSettingsTab(Options.settingsTab or (MancerDB and MancerDB.settingsTab) or "stance")
        if Mancer.Refresh then
            Mancer:Refresh()
        end
    end)
    window:SetScript("OnHide", function()
        if Mancer.Refresh then
            Mancer:Refresh()
        end
    end)
end

function Options:Initialize()
    if self.window and not self.forceRebuildDisplay then
        return
    end

    local ok, err = pcall(function()
        self:CreatePanel()
    end)
    if not ok then
        if Mancer.Hub then
            Mancer.Hub:Notify("Failed to create options window: " .. tostring(err))
        end
    end
end

function Options:Open()
    if not self.window or self.forceRebuildDisplay then
        self:Initialize()
    end
    if not self.window then
        if Mancer.Hub then
            Mancer.Hub:Notify("Options window could not be loaded.")
        end
        return
    end
    self:SyncControls()
    self.window:Show()
end

function Options:DestroyLocalizedWindows()
    if self.window then
        self.window:Hide()
    end
    if self.langWindow then
        self.langWindow:Hide()
    end
    self.forceRebuildDisplay = true
    self.forceRebuildLanguage = true
end

function Options:SyncLanguageControls()
    if not self.langRows then
        return
    end
    local current = (Mancer.LocaleModule and Mancer.LocaleModule.GetId and Mancer.LocaleModule.GetId()) or "enUS"
    for id, row in pairs(self.langRows) do
        if row.checkbox then
            -- Exclusive radio: only the active locale is checked.
            local on = (id == current)
            row.checkbox:SetChecked(on and 1 or nil)
        end
        if row.labelText and row.choice then
            local name = row.choice.nativeName or row.choice.id
            local suffix = ""
            if Mancer.LocaleModule and Mancer.LocaleModule.IsSupported
                and not Mancer.LocaleModule.IsSupported(row.choice.id)
            then
                suffix = "  [missing]"
            end
            row.labelText:SetText(string.format("%s  (%s)%s", name, row.choice.id, suffix))
        end
    end
end

local function CreateLanguageCheckboxRow(parent, choice, anchorTo, yGap)
    local name = (choice and choice.nativeName) or (choice and choice.id) or "?"
    local id = (choice and choice.id) or "?"
    local label = string.format("%s  (%s)", name, id)

    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(400, 24)
    row:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, yGap or -2)
    row:EnableMouse(false)

    local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    cb:SetSize(24, 24)
    cb:SetPoint("LEFT", row, "LEFT", 0, 0)
    cb:EnableMouse(true)

    local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", cb, "RIGHT", 6, 0)
    text:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    text:SetJustifyH("LEFT")
    text:SetText(label)
    if Mancer.UI and Mancer.UI.StyleTitle then
        Mancer.UI.StyleTitle(text)
    end

    -- Full-row hit target (label + padding); checkbox stays clickable above it.
    local hit = CreateFrame("Button", nil, row)
    hit:SetAllPoints(row)
    hit:SetFrameLevel((cb:GetFrameLevel() or 1) - 1)
    hit:RegisterForClicks("LeftButtonUp")
    hit:EnableMouse(true)

    local function SelectThis()
        -- Radio: this row stays checked even if CheckButton toggled itself off.
        cb:SetChecked(1)
        if not (Mancer.LocaleModule and Mancer.LocaleModule.SetId) then
            return
        end
        local ok = Mancer.LocaleModule.SetId(id)
        if not ok then
            if Mancer.Print then
                Mancer.Print("Language pack not loaded: " .. tostring(id))
            end
            if Mancer.Options and Mancer.Options.SyncLanguageControls then
                Mancer.Options:SyncLanguageControls()
            end
            return
        end
        if Mancer.Options and Mancer.Options.SyncLanguageControls then
            Mancer.Options:SyncLanguageControls()
        end
    end

    cb:SetScript("OnClick", function()
        SelectThis()
    end)
    hit:SetScript("OnClick", function()
        SelectThis()
    end)

    row.checkbox = cb
    row.hit = hit
    row.labelText = text
    row.choice = choice
    row.localeId = id
    return row
end

function Options:CreateLanguagePanel()
    local L = Mancer.L or {}
    local ui = Mancer.UI
    local rebuilding = self.langWindow and self.forceRebuildLanguage

    if self.langWindow and not self.forceRebuildLanguage then
        return
    end
    self.forceRebuildLanguage = false

    local window = self.langWindow
    if not window then
        if ui and ui.CreateMovableChromeWindow then
            window, self.langPanel = ui.CreateMovableChromeWindow("MancerLanguageFrame", {
                width = 480,
                height = 360,
                title = L["LANGUAGE_TITLE"] or ((Mancer.DISPLAY_NAME or "Libellus Leti") .. " Language"),
            })
            self.langWindow = window
        else
            window = CreateFrame("Frame", "MancerLanguageFrame", UIParent)
            window:SetSize(480, 360)
            window:SetPoint("CENTER")
            window:SetMovable(true)
            window:EnableMouse(true)
            window:RegisterForDrag("LeftButton")
            window:SetScript("OnDragStart", function(frame)
                frame:StartMoving()
            end)
            window:SetScript("OnDragStop", function(frame)
                frame:StopMovingOrSizing()
            end)
            window:SetFrameStrata("DIALOG")
            window:Hide()
            local panel = CreateFrame("Frame", nil, window)
            panel:SetPoint("TOPLEFT", 22, -68)
            panel:SetPoint("BOTTOMRIGHT", -22, 28)
            self.langWindow = window
            self.langPanel = panel
            if UISpecialFrames then
                tinsert(UISpecialFrames, "MancerLanguageFrame")
            end
        end
    elseif rebuilding and self.langPanel then
        ClearFrameChildren(self.langPanel)
        if window.TitleText and window.TitleText.SetText then
            window.TitleText:SetText(L["LANGUAGE_TITLE"] or ((Mancer.DISPLAY_NAME or "Libellus Leti") .. " Language"))
        elseif window.titleText and window.titleText.SetText then
            window.titleText:SetText(L["LANGUAGE_TITLE"] or ((Mancer.DISPLAY_NAME or "Libellus Leti") .. " Language"))
        end
    end

    local panel = self.langPanel
    if not panel then
        return
    end

    local desc = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
    desc:SetWidth(420)
    desc:SetJustifyH("LEFT")
    desc:SetText(L["LANGUAGE_DESC"] or "Choose the language for Libellus Leti menus and options.")
    if ui and ui.StyleMuted then
        ui.StyleMuted(desc)
    end

    local section = CreateSectionLabel(panel, L["LANGUAGE_SECTION"] or "Language", desc, -14, 420)
    section:ClearAllPoints()
    section:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -14)

    self.langRows = {}
    local anchor = section
    local choices = nil
    if Mancer.LocaleModule and Mancer.LocaleModule.GetChoices then
        choices = Mancer.LocaleModule.GetChoices()
    end
    if type(choices) ~= "table" or #choices == 0 then
        choices = {
            { id = "enUS", nativeName = "English" },
            { id = "deDE", nativeName = "Deutsch" },
            { id = "frFR", nativeName = "Francais" },
            { id = "ruRU", nativeName = "Russkiy" },
        }
    end

    for i = 1, #choices do
        local choice = choices[i]
        local yGap = (i == 1) and -8 or -2
        local ok, row = pcall(CreateLanguageCheckboxRow, panel, choice, anchor, yGap)
        if ok and row then
            self.langRows[choice.id or ("row" .. i)] = row
            anchor = row
        elseif Mancer.Print then
            Mancer.Print("Language row failed: " .. tostring(choice and choice.id) .. " — " .. tostring(row))
        end
    end
end

function Options:OpenLanguage()
    if self.window and self.window:IsShown() then
        self.window:Hide()
    end
    if Mancer.Hub and Mancer.Hub.frame and Mancer.Hub.frame:IsShown() then
        Mancer.Hub.frame:Hide()
    end
    -- Always rebuild — a prior partial pcall left only English visible.
    self.forceRebuildLanguage = true
    local ok, err = pcall(function()
        self:CreateLanguagePanel()
    end)
    if not ok then
        if Mancer.Hub and Mancer.Hub.Notify then
            Mancer.Hub:Notify("Failed to create language window: " .. tostring(err))
        elseif Mancer.Print then
            Mancer.Print("Failed to create language window: " .. tostring(err))
        end
        return
    end
    if not self.langWindow then
        return
    end
    self:SyncLanguageControls()
    self.langWindow:Show()
end

if Mancer.LocaleModule then
    Mancer.LocaleModule.OnChanged = function()
        local reopenLanguage = Mancer.Options and Mancer.Options.langWindow and Mancer.Options.langWindow:IsShown()
        local reopenDisplay = Mancer.Options and Mancer.Options.window and Mancer.Options.window:IsShown()
        if Mancer.Options and Mancer.Options.DestroyLocalizedWindows then
            Mancer.Options:DestroyLocalizedWindows()
        end
        if Mancer.Hub and Mancer.Hub.RefreshLocalizedUI then
            pcall(function()
                Mancer.Hub:RefreshLocalizedUI()
            end)
        end
        if reopenLanguage and Mancer.Options then
            Mancer.Options:OpenLanguage()
        elseif reopenDisplay and Mancer.Options then
            Mancer.Options:Open()
        end
        local msg = (Mancer.L and Mancer.L["LANGUAGE_APPLIED"]) or "Language updated."
        if Mancer.Hub and Mancer.Hub.Notify then
            Mancer.Hub:Notify(msg)
        elseif Mancer.Print then
            Mancer.Print(msg)
        end
    end
end

SLASH_LIBELLUSLETI1 = "/leti"
SlashCmdList["LIBELLUSLETI"] = HandleSlashCommand
