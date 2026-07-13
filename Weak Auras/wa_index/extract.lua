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

-- Mixin(dest, ...): real WA copies mixin methods onto dest; a plain local table
-- like Types.lua's `timeFormatter = {}` then calls dest:Init(). Our no-op left
-- dest without the method (nil-call error), so give dest the autoviv metatable -
-- then dest:AnyMethod() resolves to an inert stub instead of erroring.
local function MixinStub(dest, ...)
  if type(dest) ~= "table" then return dest end
  -- real Mixin copies each source's fields into dest; options builders merge sub-tables this
  -- way (e.g. GetGenericTriggerOptions Mixins in GetCustomTriggerOptions). A no-op dropped them.
  for i = 1, select("#", ...) do
    local src = select(i, ...)
    if type(src) == "table" then for k, v in pairs(src) do dest[k] = v end end
  end
  return setmetatable(dest, AV_MT)
end
_G.Mixin = MixinStub

local WeakAurasStub = {
  IsLibsOK = function() return true end,
  L = setmetatable({}, { __index = function(_, k) return k end }),
  normalWidth = 1, doubleWidth = 2, halfWidth = 0.5, newFeatureString = "",
  CopyTable = CopyTable, Mixin = MixinStub,
  -- signature: (name, display, supports, create, modify, onAcquire, onRelease,
  --             default, addDefaultsForNewAura, properties)  [confirmed Glow.lua:468]
  -- `display` (2nd arg) is WA's own UI label for the subregion (e.g. L["Glow"]).
  RegisterSubRegionType = function(name, display, supports, create, modify,
                                    onAcquire, onRelease, default, addDefaults, properties, ...)
    captured[#captured + 1] = { kind = "subregion", name = name, display = display,
      default = default, properties = properties }
  end,
  -- Trigger systems (e.g. the Aura/aura2 system in BuffTrigger2) register here; capture the
  -- system table so we can call its Add() and read the defaults it seeds onto a trigger.
  RegisterTriggerSystem = function(types, system)
    captured[#captured + 1] = { kind = "triggersystem", types = types, system = system }
  end,
  -- A trigger system's OPTIONS builder registers here (WeakAurasOptions/BuffTrigger2.lua:1420
  -- RegisterTriggerSystemOptions({"aura2"}, GetBuffTriggerOptions)). Capture the builder so the
  -- triggeroptions mode can CALL it and let the SOURCE self-report its full option surface.
  RegisterTriggerSystemOptions = function(types, getOptions)
    captured[#captured + 1] = { kind = "triggeroptions", types = types, getOptions = getOptions }
  end,
}
setmetatable(WeakAurasStub, { __index = function() return autoviv() end })

_G.CopyTable = CopyTable
_G.LibStub = function(major, silent) if silent then return nil end return autoviv() end
_G.CreateFrame = function(...) return autoviv() end
_G.GetScreenWidth = function() return 1920 end
_G.GetScreenHeight = function() return 1080 end

-- string.format tolerance: WA derives some *_for_ui value-domains with
-- ("%.3d - %s"):format(id, WOW_GLOBAL_STRING), and our stubs resolve those WoW
-- string constants to tables. Coerce table/nil args so the derivation doesn't
-- abort the load. Our own jsonEncode passes only valid numeric/string args, so
-- it's unaffected.
local _rawformat = string.format
string.format = function(fmt, ...)
  local n = select("#", ...)
  local a = { ... }
  for i = 1, n do if type(a[i]) == "table" then a[i] = "" end end
  local ok, r = pcall(_rawformat, fmt, unpack(a, 1, n))
  return ok and r or tostring(fmt)
end
_G.WeakAuras = WeakAurasStub
setmetatable(_G, { __index = function(_, k) return autoviv() end })

-- WeakAurasOptions addon: region UI labels register via
-- OptionsPrivate.Private.RegisterRegionOptions(name, create, icon, displayName, ...)
local OptionsPrivateStub = autoviv()
local _optPriv = autoviv()
rawset(_optPriv, "RegisterRegionOptions", function(name, create, icon, displayName, ...)
  captured[#captured + 1] = { kind = "regionoption", name = name, create = create, display = displayName }
end)
-- Seed value-domain names as string MARKERS so an options builder's
-- `values = OptionsPrivate.Private.anim_types` yields the domain NAME "anim_types"
-- (a reference we can resolve against value_domains.json) rather than a table copy.
for _, dom in ipairs({
  "anim_types", "anim_ease_types", "anim_start_preset_types", "anim_main_preset_types",
  "anim_finish_preset_types", "duration_types", "duration_types_no_choice",
  "anim_translate_types", "anim_scale_types", "anim_rotate_types",
  "anim_alpha_types", "anim_color_types",
  -- ALL trigger + display option-dropdown domains - COMPREHENSIVE, scanned from every options builder
  -- (`values = Private.<X>` -> the domain name, resolvable in domains.json). Runtime-computed ones
  -- (class_types / spec_types_all / IconSources / GetReputations / ExecEnv) stay dangling = honest gaps.
  "grow_types", "align_types", "rotated_align_types", "group_sort_types", "group_hybrid_sort_types",
  "group_hybrid_position_types", "grid_types", "circular_group_constant_factor_types",
  "operator_types", "string_operator_types", "debuff_types", "debuff_class_types", "hostility_types",
  "include_pets_types", "raid_role_types", "role_types", "tooltip_count", "check_types", "custom_trigger_types",
  "bufftrigger_2_per_unit_mode", "bufftrigger_2_preferred_match_types", "bufftrigger_2_progress_behavior_types",
  "eventend_types", "subevent_prefix_types", "subevent_suffix_types",
  "blend_types", "font_flags", "gradient_orientations", "icon_side_types", "rotated_icon_side_types",
  "justify_types", "orientation_types", "orientation_with_circle_types", "slant_mode",
  "spark_hide_types", "spark_rotation_types", "text_automatic_width", "text_check_types", "text_word_wrap",
}) do rawset(_optPriv, dom, dom) end
rawset(OptionsPrivateStub, "Private", _optPriv)

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
local _optmode = (mode == "regionoptions" or mode == "animoptions" or mode == "triggeroptions" or mode == "regionoptionsurface" or mode == "regioncoupling")
local addonName = _optmode and "WeakAurasOptions" or "WeakAuras"
local secondArg = _optmode and OptionsPrivateStub or PrivateStub
local ok, runErr = pcall(chunk, addonName, secondArg)
-- types mode only needs the value-domain literals, all assigned early in
-- Types.lua; later runtime code may error under stubs, but PrivateStub already
-- holds the enums, so a partial load is fine. Other modes need the full load.
if not ok and mode ~= "types" then
  io.stderr:write("exec failed: " .. tostring(runErr) .. "\n"); os.exit(1)
end

-- Options files don't register at load - they push a deferred closure into
-- OptionsPrivate.registerRegions that WA invokes later. Run them so the
-- RegisterRegionOptions call (and its displayName) actually fires.
if mode == "regionoptions" then
  local rr = rawget(OptionsPrivateStub, "registerRegions")
  if type(rr) == "table" then
    for _, fn in ipairs(rr) do if type(fn) == "function" then pcall(fn) end end
  end
end

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
      if type(e.display) == "string" then entry.display = e.display end
      local props = resolve_properties(e.properties, e.getProperties)
      if props then entry.properties = props end
      result[e.name] = entry
    end
  end
elseif mode == "regionoptions" then
  for _, e in ipairs(captured) do
    if e.kind == "regionoption" and type(e.display) == "string" then
      result[e.name] = e.display
    end
  end
elseif mode == "animoptions" then
  -- call the options builder with a stub data; capture the returned args (the
  -- animation field schema: field name -> {type, name(display), values(domain)}).
  local fn = OptionsPrivateStub.GetAnimationOptions
  if type(fn) == "function" then
    local ok2, opts = pcall(fn, autoviv())
    if ok2 and type(opts) == "table" and type(opts.args) == "table" then
      result = opts.args
    end
  end
elseif mode == "triggeroptions" then
  -- The SOURCE self-reports its option surface: a trigger system registers its options builder
  -- (aura2 -> GetBuffTriggerOptions); call it with a probe aura and keep EVERY declared key
  -- (incl. conditionally-hidden). hidden=function is recorded as `conditional` = the tier-1
  -- mutual-exclusivity WA itself encodes. No field list defined by us - the builder emits it.
  for _, e in ipairs(captured) do
    if e.kind == "triggeroptions" and type(e.getOptions) == "function" then
      local ptype = arg[3] or "aura2"                     -- which trigger type to probe (arg 3)
      local ptrig = { type = ptype }
      if ptype == "aura2" then ptrig.unit = "player"; ptrig.debuffType = "HELPFUL"
      elseif ptype == "custom" then ptrig.custom_type = "event" end
      local probe = setmetatable({ triggers = { [1] = { trigger = ptrig } } }, AV_MT)
      local ok2, opts = pcall(e.getOptions, probe, 1)
      if ok2 and type(opts) == "table" then
        for _, group in pairs(opts) do          -- unwrap the "trigger.N.aura_options" group -> flat options
          if type(group) == "table" then
            for key, o in pairs(group) do
              if type(o) == "table" then
                local nm = rawget(o, "name")
                if type(nm) == "function" then local okn, r = pcall(nm); nm = okn and r or nil end
                local rec = { type = rawget(o, "type"), name = (type(nm) == "string") and nm or nil,
                              order = rawget(o, "order") }
                local vv = rawget(o, "values")
                if type(vv) == "function" then local okv, r = pcall(vv)
                  if okv and (type(r) == "string" or (type(r) == "table" and getmetatable(r) == nil)) then rec.values = r end
                elseif type(vv) == "string" then rec.values = vv end
                local hd = rawget(o, "hidden")
                rec.conditional = (type(hd) == "function") or (hd == true) or nil
                result[tostring(key)] = rec
              end
            end
          end
        end
      end
    end
  end
elseif mode == "regionoptionsurface" then
  -- A REGION self-reports its OWN options surface (parallel to triggeroptions, for the group blind spot):
  -- RegisterRegionOptions(name, create, ...) -> we captured `create`; call create(id, data) with a probe
  -- and keep every declared lever (type/name/values/order). create returns {<region>=levers, position=levers};
  -- the unwrap flattens both. arg[3] = region name (e.g. dynamicgroup). Options files may defer registration
  -- into OptionsPrivate.registerRegions - fire those first.
  local rr = rawget(OptionsPrivateStub, "registerRegions")
  if type(rr) == "table" then
    for _, fn in ipairs(rr) do if type(fn) == "function" then pcall(fn) end end
  end
  local target = arg[3] or "dynamicgroup"
  for _, e in ipairs(captured) do
    if e.kind == "regionoption" and e.name == target and type(e.create) == "function" then
      local probe = setmetatable({ regionType = target, id = target }, AV_MT)
      local ok2, opts = pcall(e.create, target, probe)
      if ok2 and type(opts) == "table" then
        for _, group in pairs(opts) do          -- unwrap {dynamicgroup=levers, position=levers} -> flat levers
          if type(group) == "table" then
            for key, o in pairs(group) do
              if type(o) == "table" then
                local nm = rawget(o, "name")
                if type(nm) == "function" then local okn, r = pcall(nm); nm = okn and r or nil end
                local rec = { type = rawget(o, "type"), name = (type(nm) == "string") and nm or nil,
                              order = rawget(o, "order") }
                local vv = rawget(o, "values")
                if type(vv) == "function" then local okv, r = pcall(vv)
                  if okv and (type(r) == "string" or (type(r) == "table" and getmetatable(r) == nil)) then rec.values = r end
                elseif type(vv) == "string" then rec.values = vv end
                local hd = rawget(o, "hidden")
                rec.conditional = (type(hd) == "function") or (hd == true) or nil
                for _, b in ipairs({ "min", "max", "step", "softMin", "softMax", "bigStep" }) do
                  local bv = rawget(o, b)                 -- numeric bounds = a range lever's value-domain
                  if type(bv) == "number" then rec[b] = bv end
                end
                result[tostring(key)] = rec
              end
            end
          end
        end
      end
    end
  end
elseif mode == "regioncoupling" then
  -- The grow/gridType -> selfPoint COUPLING. The options `set` closures DERIVE selfPoint (selfPoints[grow](data) /
  -- gridSelfPoints[gridType]); the region reads data.selfPoint DIRECTLY and never re-derives it, so an authored grow
  -- without its paired selfPoint renders wrong. Generate the pairing table by RUNNING WA's own set logic - the set
  -- closure captures selfPoints/gridSelfPoints as UPVALUES (the real tables), so we enumerate inputs but the OUTPUTS
  -- are genuinely WA's. Enum INPUTS are SOURCED (passed in from domains.json by the caller - grow_types /
  -- align_types / grid_types keys), never hardcoded here, so they cannot drift from Types.lua. arg[3] = region;
  -- arg[4..6] = comma-joined grows (minus GRID, handled via by_gridtype) / aligns / gridtypes.
  local function _split(s) local t = {}; if s then for x in string.gmatch(s, "[^,]+") do t[#t + 1] = x end end; return t end
  local GROWS = _split(arg[4])
  local ALIGNS = _split(arg[5])
  local GRIDTYPES = _split(arg[6])
  local rr = rawget(OptionsPrivateStub, "registerRegions")
  if type(rr) == "table" then for _, fn in ipairs(rr) do if type(fn) == "function" then pcall(fn) end end end
  local target = arg[3] or "dynamicgroup"
  for _, e in ipairs(captured) do
    if e.kind == "regionoption" and e.name == target and type(e.create) == "function" then
      local probe = setmetatable({ regionType = target, id = target }, AV_MT)
      local ok2, opts = pcall(e.create, target, probe)
      if ok2 and type(opts) == "table" then
        local grow_set
        for _, group in pairs(opts) do
          if type(group) == "table" then
            local gl = rawget(group, "grow")
            if type(gl) == "table" and type(rawget(gl, "set")) == "function" then grow_set = rawget(gl, "set") end
          end
        end
        if type(grow_set) == "function" then
          local by_grow = {}
          for _, g in ipairs(GROWS) do
            by_grow[g] = {}
            for _, a in ipairs(ALIGNS) do
              rawset(probe, "align", a); rawset(probe, "selfPoint", nil)
              pcall(grow_set, nil, g)                              -- set assigns selfPoint BEFORE its side-effect calls
              by_grow[g][a] = rawget(probe, "selfPoint")
            end
          end
          local by_grid = {}
          for _, gt in ipairs(GRIDTYPES) do
            rawset(probe, "gridType", gt); rawset(probe, "selfPoint", nil)
            pcall(grow_set, nil, "GRID")
            by_grid[gt] = rawget(probe, "selfPoint")
          end
          result = { by_grow_align = by_grow, by_gridtype = by_grid }
        end
      end
    end
  end
elseif mode == "regionprototype" then
  -- shared levers every region inherits: call AddProperties(props, defaults) with
  -- empty tables and capture what it fills in (the alpha/position/anchor levers +
  -- shared default fields our per-region no-op stub couldn't add).
  local rp = rawget(PrivateStub, "regionPrototype")
  local props, defaults = {}, {}
  if type(rp) == "table" then
    local ap = rp.AddProperties
    if type(ap) == "function" then pcall(ap, props, defaults) end
  end
  result.shared_properties = props
  result.shared_defaults = defaults
elseif mode == "types" then
  -- Types.lua sets value-domains as `Private.X = {...}` literals. A real literal
  -- has NO metatable; an autoviv stub (from an incidental __index during load)
  -- carries AV_MT - so getmetatable==nil cleanly separates the real enums.
  for k, v in pairs(PrivateStub) do
    if type(v) == "table" and getmetatable(v) == nil then
      result[k] = v
    end
  end
elseif mode == "seed_defaults" then
  -- The FUNCTION-DRIVEN defaults the arg-scan misses: run each event_prototype's
  -- `init` on an EMPTY trigger and capture the scalar fields it writes back
  -- (`trigger.X = trigger.X or <default>` mutates the table). WA's own code produces
  -- them; we just read the result. Keyed by prototype `name` (WA's display) + the table key.
  local protos = rawget(PrivateStub, "event_prototypes")
  if type(protos) == "table" then
    for key, proto in pairs(protos) do
      if type(proto) == "table" then
        local initfn = rawget(proto, "init")
        if type(initfn) == "function" then
          local trig = {}
          pcall(initfn, trig)
          local seeds = {}
          for k, v in pairs(trig) do
            local t = type(v)
            if t == "string" or t == "number" or t == "boolean" then seeds[k] = v end
          end
          if next(seeds) then
            local nm = rawget(proto, "name")
            result[tostring(key)] = { name = (type(nm) == "string") and nm or nil, seeds = seeds }
          end
        end
      end
    end
  end
elseif mode == "aura_seed_defaults" then
  -- The Aura (aura2) trigger seeds its defaults in the trigger-SYSTEM Add(data) (BuffTrigger2:
  -- `trigger.unit = trigger.unit or "player"`, debuffType or "HELPFUL"), not in an event_prototype.
  -- Call Add on a probe aura2 trigger and capture the scalars it writes back. Add's later scan-func
  -- code may error under stubs, but the seeds run first, so pcall keeps what completed.
  local system
  for _, e in ipairs(captured) do
    if e.kind == "triggersystem" and type(e.types) == "table" then
      for _, ty in ipairs(e.types) do if ty == "aura2" then system = e.system end end
    end
  end
  if type(system) == "table" and type(rawget(system, "Add")) == "function" then
    local trig = { type = "aura2" }
    pcall(rawget(system, "Add"), { id = "extract_probe", triggers = { { trigger = trig } } })
    local seeds = {}
    for k, v in pairs(trig) do
      local t = type(v)
      if k ~= "type" and (t == "string" or t == "number" or t == "boolean") then seeds[k] = v end
    end
    result = { aura2 = { name = "Aura", seeds = seeds } }
  end
else
  io.stderr:write("unknown mode: " .. mode .. "\n"); os.exit(1)
end

print(jsonEncode(result))
