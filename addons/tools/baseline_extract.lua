-- baseline_extract.lua - run the client's own APIDocumentation files (stock
-- 3.3.5 declarations, Author: Blizzard) under lua5.1 with a stub collector,
-- and print the declared surface as JSON. The wa_index move: run the
-- authority's source, never re-type it.
--
--   lua5.1 baseline_extract.lua <Documentation dir> > baseline.json
--
-- Only identifier-like fields are emitted (system/namespace/function/event/
-- table names) - the census needs the NAME surface for subtraction, not the
-- full arg/return schemas (those stay readable in the source files).

APIDocumentation = {}
local systems = {}
function APIDocumentation:AddDocumentationTable(t)
    systems[#systems + 1] = t
end

local dir = arg[1]
assert(dir, "usage: lua5.1 baseline_extract.lua <Documentation dir>")

-- enumerate *.lua via dir (no lfs in stock lua5.1 on Windows)
local files = {}
local p = io.popen('dir /b "' .. dir .. '\\*.lua"')
for line in p:lines() do
    files[#files + 1] = line
end
p:close()
table.sort(files)

for _, f in ipairs(files) do
    dofile(dir .. "\\" .. f)
end

local function jstr(s)
    return '"' .. tostring(s):gsub('["\\]', '\\%0'):gsub('\n', '\\n') .. '"'
end

local function names(list, field)
    local out = {}
    for _, entry in ipairs(list or {}) do
        local v = entry[field or "Name"]
        if v then out[#out + 1] = jstr(v) end
    end
    return "[" .. table.concat(out, ",") .. "]"
end

local chunks = {}
for _, s in ipairs(systems) do
    chunks[#chunks + 1] = string.format(
        '{"system":%s,"namespace":%s,"functions":%s,"events":%s,"tables":%s}',
        jstr(s.Name or "?"),
        s.Namespace and jstr(s.Namespace) or "null",
        names(s.Functions),
        names(s.Events, "LiteralName"),
        names(s.Tables))
end

io.write('{"source":"APIDocumentation (in-client, Author: Blizzard, stock 3.3.5 declarations)",')
io.write('"systems":[' .. table.concat(chunks, ",") .. "]}\n")
