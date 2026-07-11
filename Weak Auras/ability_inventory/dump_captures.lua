-- dump_captures.lua - export COA_DevDumpDB.trainer + .spellbook from the game
-- SavedVariables (Lua) to JSON, so the Python consolidator can read them.
--   lua5.1 dump_captures.lua
local SV  = [[F:/games/Ascension_wow/resources/ascension-live/WTF/Account/BATTLEWRATH/SavedVariables/COA_DevDump.lua]]
local OUT = [[F:/Projects_games/World of Warcraft - Conquest of Azeroth/Weak Auras/ability_inventory/out/captures.json]]

local function esc(s)
  return (s:gsub('[%z\1-\31\\"]', function(c)
    local m = { ['"'] = '\\"', ['\\'] = '\\\\', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t' }
    return m[c] or string.format('\\u%04x', c:byte())
  end))
end

local function enc(v)
  local t = type(v)
  if t == 'nil' then return 'null'
  elseif t == 'boolean' then return tostring(v)
  elseif t == 'number' then return tostring(v)
  elseif t == 'string' then return '"' .. esc(v) .. '"'
  elseif t == 'table' then
    local n, isArr = 0, true
    for k in pairs(v) do n = n + 1; if type(k) ~= 'number' then isArr = false end end
    if isArr and n > 0 then
      local parts = {}
      for i = 1, #v do parts[i] = enc(v[i]) end
      return '[' .. table.concat(parts, ',') .. ']'
    else
      local parts = {}
      for k, val in pairs(v) do parts[#parts + 1] = '"' .. esc(tostring(k)) .. '":' .. enc(val) end
      return '{' .. table.concat(parts, ',') .. '}'
    end
  end
  return 'null'
end

dofile(SV)
local data = {
  trainer = (COA_DevDumpDB and COA_DevDumpDB.trainer) or {},
  spellbook = (COA_DevDumpDB and COA_DevDumpDB.spellbook) or {},
}
local f = assert(io.open(OUT, "w"))
f:write(enc(data))
f:close()
print("wrote " .. OUT)
