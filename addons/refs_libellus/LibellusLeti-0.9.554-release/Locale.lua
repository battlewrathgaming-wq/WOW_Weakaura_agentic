-- Locale core: user-selected language (default English), with enUS fallback.
-- Locales load before Core.lua in the toc — bootstrap the namespace here.
Mancer = Mancer or {}
Mancer.LocaleModule = Mancer.LocaleModule or {}
local Locale = Mancer.LocaleModule

local DEFAULT_ID = "enUS"
local catalogs = {}

-- Labels are ASCII-safe for Ascension/3.3.5 font + file encoding quirks.
-- Catalog files (deDE/frFR/ruRU) still hold full translated UI strings.
Locale.CHOICES = {
    { id = "enUS", nativeName = "English" },
    { id = "deDE", nativeName = "Deutsch" },
    { id = "frFR", nativeName = "Francais" },
    { id = "ruRU", nativeName = "Russkiy" },
}

function Locale.Register(id, strings)
    if type(id) ~= "string" or type(strings) ~= "table" then
        return
    end
    catalogs[id] = strings
end

function Locale.IsSupported(id)
    return type(id) == "string" and catalogs[id] ~= nil
end

function Locale.GetRegisteredIds()
    local ids = {}
    for id in pairs(catalogs) do
        ids[#ids + 1] = id
    end
    table.sort(ids)
    return ids
end

function Locale.GetId()
    MancerDB = MancerDB or {}
    local id = MancerDB.locale
    if not Locale.IsSupported(id) then
        id = DEFAULT_ID
        MancerDB.locale = id
    end
    return id
end

local function RebuildL()
    local id = Locale.GetId()
    local active = catalogs[id] or catalogs[DEFAULT_ID] or {}
    local fallback = catalogs[DEFAULT_ID] or {}
    Mancer.L = setmetatable({}, {
        __index = function(_, key)
            local value = active[key]
            if value ~= nil then
                return value
            end
            value = fallback[key]
            if value ~= nil then
                return value
            end
            return key
        end,
    })
end

function Locale.Apply()
    RebuildL()
end

function Locale.SetId(id)
    if not Locale.IsSupported(id) then
        return false
    end
    MancerDB = MancerDB or {}
    local prev = MancerDB.locale
    MancerDB.locale = id
    RebuildL()
    if prev ~= id and Locale.OnChanged then
        Locale.OnChanged(id)
    end
    return true
end

function Locale.GetChoices()
    -- Always return a fresh list of all known UI languages (not filtered by catalog).
    local out = {}
    for i = 1, #Locale.CHOICES do
        local c = Locale.CHOICES[i]
        out[i] = {
            id = c.id,
            nativeName = c.nativeName,
            registered = Locale.IsSupported(c.id),
        }
    end
    return out
end

-- Safe lookup before locales finish loading.
Mancer.L = Mancer.L or setmetatable({}, {
    __index = function(_, key)
        return key
    end,
})

function Mancer.Loc(key, fallback)
    local L = Mancer.L
    local value = L and L[key]
    -- Stub / missing keys return the key itself — treat that as a miss.
    if value == nil or value == key then
        return fallback or key
    end
    return value
end
