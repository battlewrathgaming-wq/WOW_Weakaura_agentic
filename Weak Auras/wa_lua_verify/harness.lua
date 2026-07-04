--[[
harness.lua - runs REAL WeakAuras addon source files (SubRegionTypes/*.lua)
under a real Lua 5.1 interpreter (matching WoW 3.3.5a's actual Lua version,
not a newer/bundled one) to extract their genuine default() tables, rather
than hand-transcribing them from a source read.

Built 2026-07-06, directly motivated by a real bug this project shipped:
the class_accent_tick_end/threshold_value subtick fragments were missing 3
fields present in SubRegionTypes/Tick.lua's own default() table
(progressSources, automatic_length, tick_texture), discovered only after
Battlewrath live-tested it in-game and the placement came out wrong. This
harness exists so that gap is caught here, before a live test, not after.

Usage:
  lua5.1 harness.lua <path-to-source-file.lua>

Prints one JSON object to stdout, keyed by "<subRegionType>" for
parentType-independent defaults, or "<subRegionType>:<parentType>" for
subRegionTypes whose default() branches on parentType (e.g. subtext's
default(parentType) gives a different anchor_point for "icon" vs
"aurabar" parents - both are captured separately since the difference is
real and meaningful, not something to average away).

Scope, deliberately: this covers WeakAuras' own default()-table
functions for SubRegionTypes only, since those are the pure-data
functions responsible for the class of bug above. It does NOT attempt to
emulate WeakAuras' full runtime (frame creation, actual game API calls
like UnitCastingInfo) - that would require mocking the entire WoW client
API, which is a different and much larger undertaking not attempted
here. RegionTypes/trigger prototypes (Prototypes.lua) are plain static
tables, not functions that compute defaults - those are already fully
readable directly from source without needing execution.
]]

-- Minimal auto-vivifying table: any missing key access returns another
-- auto-vivifying table (and any call on it is a no-op returning itself),
-- so a source file's references to fields of Private/L/WeakAuras that
-- this harness doesn't know about ahead of time don't error out. This is
-- deliberately permissive - we only care about the file's default()
-- function actually being reachable and callable, not about full
-- correctness of every helper it might reference in unrelated code paths.
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

-- Captures every WeakAuras.RegisterSubRegionType(...) call made while the
-- target file is loaded. A single file can register more than one type
-- (Background.lua registers both subbackground and subforeground).
local captured = {}

local WeakAurasStub = {
  IsLibsOK = function() return true end,
  L = setmetatable({}, { __index = function(_, k) return k end }),
  RegisterSubRegionType = function(name, display, supports, create, modify,
                                    onAcquire, onRelease, default, properties,
                                    getProperties, ...)
    captured[#captured + 1] = { name = name, default_fn = default }
  end,
}
setmetatable(WeakAurasStub, { __index = function() return autoviv() end })

local PrivateStub = autoviv()

-- Minimal LibStub stub - SubText.lua calls LibStub("LibSharedMedia-3.0");
-- we don't need real media lookups for a default() table, just something
-- that won't error.
_G.LibStub = function(...) return autoviv() end
_G.CreateFrame = function(...) return autoviv() end
_G.GetScreenWidth = function() return 1920 end
_G.GetScreenHeight = function() return 1080 end

-- Catch-all for any other real WoW client API a source file references at
-- load time (e.g. Model.lua's CreateObjectPool) that this harness hasn't
-- explicitly stubbed. Same permissive philosophy as Private/WeakAuras
-- above: we only need the file to load and its default() function to be
-- reachable, not for unrelated game-API calls to behave correctly.
setmetatable(_G, {
  __index = function(_, k)
    return autoviv()
  end,
})

local path = arg[1]
if not path then
  io.stderr:write("usage: lua5.1 harness.lua <path-to-source-file.lua>\n")
  os.exit(1)
end

-- WeakAuras needs to be a real global - some source files reference
-- WeakAuras.* directly (not just via the Private upvalue passed in as
-- the chunk's second vararg).
_G.WeakAuras = WeakAurasStub

local chunk, err = loadfile(path)
if not chunk then
  io.stderr:write("failed to load " .. path .. ": " .. tostring(err) .. "\n")
  os.exit(1)
end

-- Addon files are loaded by WoW as chunk(addonName, sharedTable) - the
-- file itself does `local AddonName = ...` / `local Private = select(2, ...)`.
local ok, runErr = pcall(chunk, "WeakAuras", PrivateStub)
if not ok then
  io.stderr:write("failed to execute " .. path .. ": " .. tostring(runErr) .. "\n")
  os.exit(1)
end

-- ---------------------------------------------------------------------
-- Tiny JSON serializer - sufficient for the plain data (numbers, strings,
-- booleans, nested tables/arrays) these default() tables actually return.
-- Not a general-purpose JSON library; deliberately scoped to this need.
-- ---------------------------------------------------------------------
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
    return "null" -- functions, userdata, etc. - not expected in a default() table
  end
end

-- Some default() functions take an optional parentType argument and
-- branch on it (e.g. subtext's anchor_point differs for "icon" vs
-- "aurabar" parents) - calling with no argument does NOT error in Lua
-- (parentType is just nil, silently taking whichever branch checks fail
-- first), so an argless call succeeding is not proof the function is
-- parentType-independent. Always try all three call shapes and compare;
-- only collapse to a single plain-named entry if every shape that
-- succeeded actually agrees.
local function tablesEqual(a, b)
  if a == b then return true end
  if type(a) ~= "table" or type(b) ~= "table" then return false end
  for k, v in pairs(a) do
    if not tablesEqual(v, b[k]) then return false end
  end
  for k in pairs(b) do
    if a[k] == nil then return false end
  end
  return true
end

local out = {}
for _, entry in ipairs(captured) do
  -- Some registrations pass "default" as a plain literal table, not a
  -- function (e.g. Background.lua's subbackground/subforeground both
  -- register with default = {}) - use it directly rather than trying to
  -- call it. (No goto/continue in Lua 5.1, so the call-based path below
  -- is nested inside the else branch instead.)
  if type(entry.default_fn) == "table" then
    out[entry.name] = entry.default_fn
  else
    local variants = {}
    local okNone, resNone = pcall(entry.default_fn)
    if okNone and type(resNone) == "table" then variants["none"] = resNone end
    local okA, resA = pcall(entry.default_fn, "aurabar")
    if okA and type(resA) == "table" then variants["aurabar"] = resA end
    local okI, resI = pcall(entry.default_fn, "icon")
    if okI and type(resI) == "table" then variants["icon"] = resI end

    local distinct = {}
    for label, tbl in pairs(variants) do
      local matched = false
      for _, d in ipairs(distinct) do
        if tablesEqual(d.tbl, tbl) then
          d.labels[#d.labels + 1] = label
          matched = true
          break
        end
      end
      if not matched then
        distinct[#distinct + 1] = { tbl = tbl, labels = { label } }
      end
    end

    if #distinct == 1 then
      out[entry.name] = distinct[1].tbl
    else
      for _, d in ipairs(distinct) do
        -- prefer the most specific/meaningful label ("aurabar"/"icon" over "none")
        local label = d.labels[1]
        for _, l in ipairs(d.labels) do
          if l ~= "none" then label = l end
        end
        out[entry.name .. ":" .. label] = d.tbl
      end
    end
  end
end

print(jsonEncode(out))
