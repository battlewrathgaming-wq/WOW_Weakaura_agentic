--[[
harness_regiontype.lua - sibling to harness.lua, same technique, extended
to cover RegionTypes/*.lua instead of SubRegionTypes/*.lua.

Built 2026-07-06, for the "text" region type specifically: before
building anything against RegionTypes/Text.lua's `default` table (a
transient combat-text-style alert, requested by Battlewrath - "first
emulate around the text element" - for tracking Life Force stack gains),
extract its real default() table mechanically instead of hand-
transcribing from a source read, same reasoning as the original harness's
own README (the class_accent_tick_end/threshold_value bug this whole
tool family exists because of).

Kept as a SEPARATE file from harness.lua rather than extending it in
place - harness.lua only stubs WeakAuras.RegisterSubRegionType (a
different call than Private.RegisterRegionType, which is what
RegionTypes/*.lua files actually call), and that tool already has a
proven, working track record on SubRegionTypes specifically. Isolating
this new, less-tested RegisterRegionType capture in its own file means
a mistake here can't affect the existing, trusted subRegion-verification
workflow.

Scope, same permissive philosophy as harness.lua: only reach and call
the file's `default` table/function correctly - not attempt to emulate
`create`/`modify`'s actual runtime behavior (real frame creation, actual
game API calls). RegionTypes' `default` is consistently a plain table
(not a parentType-branching function like some SubRegionTypes' subtext
default) in every RegionTypes/*.lua file read so far this pass - if that
assumption is ever wrong for some other RegionType, this script's
call-vs-table branch (mirrored from harness.lua) will still catch it.

Usage:
  lua5.1 harness_regiontype.lua <path-to-RegionTypes-file.lua>

Prints one JSON object to stdout, keyed by region type name.
]]

local function autoviv()
  local t = {}
  local mt = {}
  mt.__index = function(tbl, k)
    local v = autoviv()
    rawset(tbl, k, v)
    return v
  end
  mt.__call = function(self, ...)
    return self
  end
  return setmetatable(t, mt)
end

-- Captures every Private.RegisterRegionType(name, create, modify, default,
-- properties, validate) call made while the target file is loaded.
local captured = {}

local PrivateStub = autoviv()
-- autoviv's __call metamethod would normally swallow this call silently
-- (returning itself, capturing nothing) - override just this one field
-- with a real function so the call is actually observed, while every
-- other Private.* access still falls through to the permissive autoviv
-- default.
rawset(PrivateStub, "RegisterRegionType", function(name, create, modify, default, properties, validate, ...)
  captured[#captured + 1] = { name = name, default_fn = default }
end)
-- Text.lua also calls Private.regionPrototype.AddProperties(...) at load
-- time (module-level, before create/modify are even invoked) - autoviv's
-- __call handles this fine as a no-op, nothing extra needed.

local WeakAurasStub = {
  IsLibsOK = function() return true end,
  L = setmetatable({}, { __index = function(_, k) return k end }),
}
setmetatable(WeakAurasStub, { __index = function() return autoviv() end })

_G.LibStub = function(...) return autoviv() end
_G.CreateFrame = function(...) return autoviv() end
_G.GetScreenWidth = function() return 1920 end
_G.GetScreenHeight = function() return 1080 end

setmetatable(_G, {
  __index = function(_, k)
    return autoviv()
  end,
})

local path = arg[1]
if not path then
  io.stderr:write("usage: lua5.1 harness_regiontype.lua <path-to-source-file.lua>\n")
  os.exit(1)
end

_G.WeakAuras = WeakAurasStub

local chunk, err = loadfile(path)
if not chunk then
  io.stderr:write("failed to load " .. path .. ": " .. tostring(err) .. "\n")
  os.exit(1)
end

local ok, runErr = pcall(chunk, "WeakAuras", PrivateStub)
if not ok then
  io.stderr:write("failed to execute " .. path .. ": " .. tostring(runErr) .. "\n")
  os.exit(1)
end

local function isArray(t)
  local n = 0
  for _ in pairs(t) do n = n + 1 end
  for i = 1, n do
    if t[i] == nil then return false end
  end
  return n > 0
end

local function jsonEncode(v)
  local t = type(v)
  if t == "nil" then
    return "null"
  elseif t == "boolean" then
    return v and "true" or "false"
  elseif t == "number" then
    return tostring(v)
  elseif t == "string" then
    return string.format("%q", v)
  elseif t == "table" then
    if isArray(v) then
      local parts = {}
      for i, item in ipairs(v) do
        parts[i] = jsonEncode(item)
      end
      return "[" .. table.concat(parts, ",") .. "]"
    else
      local parts = {}
      local keys = {}
      for k in pairs(v) do keys[#keys + 1] = k end
      table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
      for _, k in ipairs(keys) do
        parts[#parts + 1] = string.format("%q", tostring(k)) .. ":" .. jsonEncode(v[k])
      end
      return "{" .. table.concat(parts, ",") .. "}"
    end
  else
    return "null"
  end
end

local out = {}
for _, entry in ipairs(captured) do
  if type(entry.default_fn) == "table" then
    out[entry.name] = entry.default_fn
  else
    -- Same call-and-compare approach as harness.lua, in case some
    -- RegionType's default does turn out to be a function.
    local okNone, resNone = pcall(entry.default_fn)
    if okNone and type(resNone) == "table" then
      out[entry.name] = resNone
    else
      out[entry.name] = { ["_error"] = "default_fn is not a plain table and calling it with no args failed" }
    end
  end
end

print(jsonEncode(out))
