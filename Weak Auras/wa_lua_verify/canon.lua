--[[
canon.lua - WA's own acceptor, headless. Replicates WeakAuras.PreAdd(data) (WeakAuras.lua:2927), running
WA's REAL validate + Modernize + region/subregion defaults under Lua 5.1 stubs (extract.lua lineage,
GAP_BRIDGE insight #5). This is the P11 completer: provide a minimal aura, WA fills the rest from its own
data_stub + region default, and (by data_stub's design) it reimport-diffs clean.

  lua5.1 canon.lua <input.lua>    input = a Lua-literal aura table (`return {...}`); output = completed table as JSON

Acceptor order, from PreAdd (current-version aura skips the legacy oldDataStub fills):
  Modernize(data) -> validate(data, region.default) -> regionValidate(data) -> validate(data, data_stub)
  -> per-subRegion validate(sr, subType.default)

GRADE (P3): stub-degraded. WeakAuras.lua aborts mid-load (arith-on-stub, ~line 1046), so Private.* helpers
defined after that point resolve to no-op stubs; Modernize steps that depend on them silently skip. For a
current-version minimal aura Modernize should be ~no-op, but the TRUE reimport-clean gate is the LIVE client
(hand the import string to a human, reimport + re-export + diff), not this fast proxy.
]]

-- ---------------------------------------------------------------- stub env (extract.lua lineage)
local AV_MT
local function newstub() return setmetatable({}, AV_MT) end
AV_MT = {
  __index = function(t, k) local v = newstub(); rawset(t, k, v); return v end,
  __call = function(s, ...) return s end,
  __concat = function(a, b)
    if type(a) == "string" then return a end
    if type(b) == "string" then return b end
    return ""
  end,
  __add = newstub, __sub = newstub, __mul = newstub, __div = newstub,
  __mod = newstub, __pow = newstub, __unm = newstub,
  __lt = function() return false end, __le = function() return false end, __tostring = function() return "" end,
}
local function autoviv() return newstub() end

local function CopyTable(t)
  if type(t) ~= "table" then return t end
  local r = {}
  for k, v in pairs(t) do r[k] = (type(v) == "table") and CopyTable(v) or v end
  return setmetatable(r, AV_MT)
end

-- real Mixin copies each source's fields into dest (Types.lua's timeFormatter:Init(), options builders rely on it)
local function MixinStub(dest, ...)
  if type(dest) ~= "table" then return dest end
  for i = 1, select("#", ...) do
    local s = select(i, ...)
    if type(s) == "table" then for k, v in pairs(s) do dest[k] = v end end
  end
  return setmetatable(dest, AV_MT)
end
_G.Mixin = MixinStub

-- We do NOT stub the Register*Type functions: WeakAuras.lua defines the REAL Private.RegisterRegionType /
-- WeakAuras.RegisterSubRegionType (before its mid-file abort), which store into Private.regionTypes /
-- Private.subRegionTypes as each type file loads. canon reads those after loading (WA's own registration).
local WA = {
  IsLibsOK = function() return true end,
  L = setmetatable({}, { __index = function(_, k) return k end }),
  normalWidth = 1, doubleWidth = 2, halfWidth = 0.5, newFeatureString = "",
  CopyTable = CopyTable, Mixin = MixinStub,
}
setmetatable(WA, { __index = function() return autoviv() end })
_G.WeakAuras = WA
_G.CopyTable = CopyTable
_G.LibStub = function(major, silent) if silent then return nil end return autoviv() end
_G.CreateFrame = function() return autoviv() end
_G.GetScreenWidth = function() return 1920 end
_G.GetScreenHeight = function() return 1080 end
local _fmt = string.format
string.format = function(fmt, ...)
  local n = select("#", ...)
  local a = { ... }
  for i = 1, n do if type(a[i]) == "table" then a[i] = "" end end
  local ok, r = pcall(_fmt, fmt, unpack(a, 1, n))
  return ok and r or tostring(fmt)
end
setmetatable(_G, { __index = function(_, k) return autoviv() end })

local Private = autoviv()

-- ---------------------------------------------------------------- load WA source into shared Private
local BASE = "F:/games/Ascension_wow/resources/ascension-live/Interface/AddOns/WeakAuras/"
local function load_wa(rel)
  local ch, e = loadfile(BASE .. rel)
  if not ch then io.stderr:write("canon: load-fail " .. rel .. ": " .. tostring(e) .. "\n"); return end
  pcall(ch, "WeakAuras", Private)   -- pcall: WeakAuras.lua aborts mid-file but defines validate before it
end
load_wa("Types.lua")                 -- Private.data_stub
load_wa("WeakAuras.lua")             -- Private.validate (defined ~L406, before the mid-file abort)
load_wa("Modernize.lua")             -- Private.Modernize
load_wa("RegionTypes/Icon.lua")      -- icon region default + validate
for _, f in ipairs({ "Background.lua", "Border.lua", "Glow.lua", "Model.lua",
                     "StopMotion.lua", "SubText.lua", "Texture.lua", "Tick.lua" }) do
  load_wa("SubRegionTypes/" .. f)
end

local validate = rawget(Private, "validate")
local data_stub = rawget(Private, "data_stub")
local Modernize = rawget(Private, "Modernize")
if type(validate) ~= "function" then io.stderr:write("canon: Private.validate missing\n"); os.exit(1) end
if type(data_stub) ~= "table" then io.stderr:write("canon: Private.data_stub missing\n"); os.exit(1) end

-- ---------------------------------------------------------------- input aura (Lua literal)
local inp = arg[1]
if not inp then io.stderr:write("usage: lua5.1 canon.lua <input.lua>\n"); os.exit(1) end
local chunk, err = loadfile(inp)
if not chunk then io.stderr:write("canon: bad input " .. tostring(err) .. "\n"); os.exit(1) end
local data = chunk()

-- ---------------------------------------------------------------- run PreAdd's acceptor (WeakAuras.lua:2927)
local regionTypes = rawget(Private, "regionTypes")
local subRegionTypes = rawget(Private, "subRegionTypes")
local CURRENT = (type(WA.InternalVersion) == "function") and tonumber(WA.InternalVersion()) or nil

-- Modernize only MIGRATES old auras; for a current-version aura every gate skips (a definitional no-op), so
-- skip it rather than run it stub-degraded. A freshly-authored aura declares the current internalVersion.
if type(Modernize) == "function" and (not data.internalVersion or (CURRENT and data.internalVersion < CURRENT)) then
  pcall(Modernize, data, nil)
end
local rtype = (type(regionTypes) == "table") and regionTypes[data.regionType] or nil
if type(rtype) == "table" then
  if type(rtype.default) == "table" then validate(data, rtype.default) end
  if type(rtype.validate) == "function" then pcall(rtype.validate, data) end
end
validate(data, data_stub)
if type(data.subRegions) == "table" and type(subRegionTypes) == "table" then
  for _, sr in ipairs(data.subRegions) do
    local st = subRegionTypes[sr.type]
    local d = st and st.default
    if type(d) == "function" then local ok, r = pcall(d, data.regionType); d = ok and r or nil end
    if type(d) == "table" then validate(sr, d) end
  end
end

-- ---------------------------------------------------------------- emit JSON
local function isArray(t)
  local n = 0
  for _ in pairs(t) do n = n + 1 end
  for i = 1, n do if rawget(t, i) == nil then return false end end
  return n > 0
end
local function jsonEncode(v)
  local t = type(v)
  if t == "nil" then return "null"
  elseif t == "boolean" then return v and "true" or "false"
  elseif t == "number" then return tostring(v)
  elseif t == "string" then return string.format("%q", v)
  elseif t == "table" then
    if isArray(v) then
      local parts = {}
      for i, item in ipairs(v) do parts[i] = jsonEncode(item) end
      return "[" .. table.concat(parts, ",") .. "]"
    else
      local keys = {}
      for k in pairs(v) do keys[#keys + 1] = k end
      table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
      local parts = {}
      for _, k in ipairs(keys) do
        parts[#parts + 1] = string.format("%q", tostring(k)) .. ":" .. jsonEncode(v[k])
      end
      return "{" .. table.concat(parts, ",") .. "}"
    end
  else return "null" end
end
print(jsonEncode(data))
