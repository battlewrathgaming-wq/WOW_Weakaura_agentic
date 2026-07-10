--[[
extract.lua - dump WeakAuras' own lever declarations to JSON, by loading the
real, unmodified source under Lua 5.1 in a permissive stub environment. Extends
the autoviv technique from wa_lua_verify/harness.lua + harness_regiontype.lua.

  lua5.1 extract.lua prototypes <Prototypes.lua>        -> { load=<load_prototype>, triggers=<event_prototypes> }
  lua5.1 extract.lua region     <RegionTypes/X.lua>     -> { <name> = { default=..., properties=... } }
  lua5.1 extract.lua subregion  <SubRegionTypes/X.lua>  -> { <name> = { default*=..., properties=... } }

We only reach the declarative data (args / default / properties). create/modify
runtime (real frames, game API) stays stubbed.
]]

-- Shared permissive-stub metatable: any field access, call, concat or arithmetic
-- yields something inert, so loading a file full of WA internals never crashes.
local AV_MT
local function newstub() return setmetatable({}, AV_MT) end
AV_MT = {
  __index = function(tbl, k) local v = newstub(); rawset(tbl, k, v); return v end,
  __call = function(self, ...) return self end,
  __concat = function(a, b)
    if type(a) == "string" then return a end
    if type(b) == "string" then return b end
    return ""
  end,
  __add = newstub, __sub = newstub, __mul = newstub, __div = newstub,
  __mod = newstub, __pow = newstub, __unm = newstub,
  __lt = function() return false end, __le = function() return false end,
  __tostring = function() return "" end,
}
local function autoviv() return newstub() end

-- Real deep copy, with the autoviv metatable attached to outputs - so a
-- RegionType's GetProperties (which does CopyTable(properties) then indexes
-- shared props like progressSource that our no-op AddProperties never added)
-- gets an inert stub for the missing key instead of erroring on nil.
local function CopyTable(t)
  if type(t) ~= "table" then return t end
  local r = {}
  for k, v in pairs(t) do r[k] = (type(v) == "table") and CopyTable(v) or v end
  return setmetatable(r, AV_MT)
end

local captured = {}

local PrivateStub = autoviv()
rawset(PrivateStub, "RegisterRegionType", function(name, create, modify, default, getProperties, validate, ...)
  captured[#captured + 1] = { kind = "region", name = name, default = default, getProperties = getProperties }
end)

local WeakAurasStub = {
  IsLibsOK = function() return true end,
  L = setmetatable({}, { __index = function(_, k) return k end }),
  normalWidth = 1, doubleWidth = 2, halfWidth = 0.5, newFeatureString = "",
  CopyTable = CopyTable,
  -- signature: (name, display, supports, create, modify, onAcquire, onRelease,
  --             default, addDefaultsForNewAura, properties)  [confirmed Glow.lua:468]
  RegisterSubRegionType = function(name, display, supports, create, modify,
                                    onAcquire, onRelease, default, addDefaults, properties, ...)
    captured[#captured + 1] = { kind = "subregion", name = name,
      default = default, properties = properties }
  end,
}
setmetatable(WeakAurasStub, { __index = function() return autoviv() end })

_G.CopyTable = CopyTable
_G.LibStub = function(major, silent) if silent then return nil end return autoviv() end
_G.CreateFrame = function(...) return autoviv() end
_G.GetScreenWidth = function() return 1920 end
_G.GetScreenHeight = function() return 1080 end
_G.WeakAuras = WeakAurasStub
setmetatable(_G, { __index = function(_, k) return autoviv() end })

-- ---------------------------------------------------------------- JSON encode
local function isArray(t)
  local n = 0
  for _ in pairs(t) do n = n + 1 end
  -- rawget: t[i] on an autoviv-metatable table would CREATE the key and both
  -- pollute the table and falsely report an array. next()/pairs stay raw.
  for i = 1, n do if rawget(t, i) == nil then return false end end
  return n > 0
end

local _esc = { ['"'] = '\\"', ['\\'] = '\\\\', ['\n'] = '\\n', ['\r'] = '\\r',
               ['\t'] = '\\t', ['\b'] = '\\b', ['\f'] = '\\f' }
local function jsonString(s)
  return '"' .. (s:gsub('[%z\1-\31\\"]', function(c)
    return _esc[c] or string.format('\\u%04x', string.byte(c))
  end)) .. '"'
end

local seen = {}
local function jsonEncode(v)
  local ty = type(v)
  if ty == "nil" then return "null"
  elseif ty == "boolean" then return v and "true" or "false"
  elseif ty == "number" then
    if v ~= v or v == math.huge or v == -math.huge then return "null" end
    return string.format("%.14g", v)
  elseif ty == "string" then return jsonString(v)
  elseif ty == "function" then return "\"<function>\""
  elseif ty == "table" then
    if seen[v] then return "\"<cycle>\"" end
    seen[v] = true
    local out
    if isArray(v) then
      local parts = {}
      for i, item in ipairs(v) do parts[i] = jsonEncode(item) end
      out = "[" .. table.concat(parts, ",") .. "]"
    else
      local keys = {}
      for k in pairs(v) do keys[#keys + 1] = k end
      table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
      local parts = {}
      for _, k in ipairs(keys) do
        parts[#parts + 1] = jsonString(tostring(k)) .. ":" .. jsonEncode(v[k])
      end
      out = "{" .. table.concat(parts, ",") .. "}"
    end
    seen[v] = nil
    return out
  else
    return "null"
  end
end

-- ---------------------------------------------------------------- helpers
local function resolve_properties(props, getProps)
  if type(props) == "table" then return props end
  if type(getProps) == "function" then
    local ok, r = pcall(getProps, {})
    if ok and type(r) == "table" then return r end
  end
  return nil
end

local function default_variants(default)
  if type(default) == "table" then return { default = default } end
  if type(default) ~= "function" then return {} end
  local out = {}
  local okN, rN = pcall(default);            if okN and type(rN) == "table" then out.default_none = rN end
  local okA, rA = pcall(default, "aurabar"); if okA and type(rA) == "table" then out.default_aurabar = rA end
  local okI, rI = pcall(default, "icon");    if okI and type(rI) == "table" then out.default_icon = rI end
  return out
end

-- ---------------------------------------------------------------- run
local mode, path = arg[1], arg[2]
if not mode or not path then
  io.stderr:write("usage: lua5.1 extract.lua <prototypes|region|subregion> <file.lua>\n"); os.exit(1)
end

local chunk, err = loadfile(path)
if not chunk then io.stderr:write("load failed: " .. tostring(err) .. "\n"); os.exit(1) end
local ok, runErr = pcall(chunk, "WeakAuras", PrivateStub)
if not ok then io.stderr:write("exec failed: " .. tostring(runErr) .. "\n"); os.exit(1) end

local result = {}
if mode == "prototypes" then
  result.load = (type(PrivateStub.load_prototype) == "table") and PrivateStub.load_prototype or nil
  result.triggers = (type(PrivateStub.event_prototypes) == "table") and PrivateStub.event_prototypes or nil
elseif mode == "region" then
  for _, e in ipairs(captured) do
    if e.kind == "region" then
      local entry = {}
      if type(e.default) == "table" then entry.default = e.default end
      local props = resolve_properties(nil, e.getProperties)
      if props then entry.properties = props end
      result[e.name] = entry
    end
  end
elseif mode == "subregion" then
  for _, e in ipairs(captured) do
    if e.kind == "subregion" then
      local entry = default_variants(e.default)
      local props = resolve_properties(e.properties, e.getProperties)
      if props then entry.properties = props end
      result[e.name] = entry
    end
  end
else
  io.stderr:write("unknown mode: " .. mode .. "\n"); os.exit(1)
end

print(jsonEncode(result))
