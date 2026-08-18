-- ★ THE MEASUREMENT, not an argument: branch AceGUI into our own frame stubs and run
-- it. What it TOUCHES comes back from F.Unmodelled() for free - the harness already
-- records every unknown method as it hands back a no-op. What it CANNOT survive comes
-- back as an error, one per file, because nothing here stops on the first one.
--
--   lua5.1 ace_emulate.lua <path-to-Ace3-dist>
--
-- ⚠ It reports. It asserts nothing. A red here is news about the stub surface, which
-- is the number driver_ui_scope §3's A' rests on and has never been measured.

local DIST = assert(arg[1], "give me an Ace3 distribution root")
local HARNESS = arg[2] or [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\tools\smoke\frames.lua]]
local F = assert(loadfile(HARNESS))()

local function firstline(e) return (tostring(e):gsub("[\r\n].*", "")) end

-- ★★★ DISCOVER THE GLOBAL SURFACE, DO NOT GUESS IT. I hand-fed this list twice and was
-- wrong both times - `C_Timer` and `SetDesaturation` are both REAL on this fork
-- (ROUTER.md:75; the client corpus). A guess that happens to make the probe run is
-- indistinguishable from a fact, which is the whole reason this records instead.
local GLOBAL_MISS = {}
setmetatable(_G, { __index = function(_, k)
    if type(k) == "string" then GLOBAL_MISS[k] = (GLOBAL_MISS[k] or 0) + 1 end
    return nil
end })

-- ---- the client-side globals AceGUI reaches for before it reaches for a frame.
UIParent = F.New("UIParent")
F.SetRoot(UIParent, 1024, 768, 0, 0)
function CreateFrame(_, name, parent, template)
    return F.New(name, parent or UIParent, template)
end
function GetTime() return 100.0 end
function geterrorhandler() return function(e) error(e, 0) end end
function wipe(t) for k in pairs(t) do t[k] = nil end return t end
table.wipe = wipe

-- ⚠ THE WOW GLOBAL ALIASES. The client publishes string/table/math under bare names and
-- the whole field uses them. These are not stubs - they are the real functions under the
-- client's names, so modelling them costs nothing and hides nothing.
strmatch, strfind, strsub, strlower, strupper, strrep, strbyte, strchar =
    string.match, string.find, string.sub, string.lower, string.upper, string.rep,
    string.byte, string.char
format, gsub = string.format, string.gsub
tinsert, tremove, sort, getn = table.insert, table.remove, table.sort, table.getn
max, min, floor, ceil, abs, mod =
    math.max, math.min, math.floor, math.ceil, math.abs, math.fmod
function strtrim(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end

function hooksecurefunc(a, b, c)
    local t, k, post = a, b, c
    if type(a) == "string" then t, k, post = _G, a, b end
    local orig = t[k]
    t[k] = function(...) local r = orig and orig(...); post(...); return r end
end

-- ★ C_Timer IS A REAL ASCENSION GLOBAL - operations/ROUTER.md, in use since
-- COA_GuardianPlates v3.5.5. It is stubbed here because the HARNESS lacks it, never
-- because the client does. ⚠ ROUTER also records why a name search would say
-- otherwise: it enumerates as an EMPTY table in the 51,855-global census.
C_Timer = { After = function(_, fn) if fn then fn() end end,
            NewTicker = function() return { Cancel = function() end } end }

GameFontHighlight = F.New("GameFontHighlight")
GameFontHighlightSmall = F.New("GameFontHighlightSmall")

-- ★★★ P1: THE CLIENT'S OWN FRAMEXML LUA, before any Ace file is touched. A10.1c
-- rules it loaded WHOLE from the archive, stubs only where a file will not run, and every
-- stubbed function REPORTED by name in the same unverifiable list as the text metrics.
local FX = assert(loadfile([[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\tools\smoke\framexml.lua]]))()
local FXSTATS = FX.Load()

local function tryload(path, label)
    local chunk, err = loadfile(path)
    if not chunk then return false, "PARSE: " .. firstline(err) end
    local ok, err2 = pcall(chunk, label, {})
    if not ok then return false, "RUN: " .. firstline(err2) end
    return true
end

-- ---- LibStub first; everything else asks for it by name.
local base = DIST .. [[\]]
local order = {
    { base .. [[LibStub\LibStub.lua]], "LibStub" },
    { base .. [[CallbackHandler-1.0\CallbackHandler-1.0.lua]], "CallbackHandler-1.0" },
    { base .. [[AceGUI-3.0\AceGUI-3.0.lua]], "AceGUI-3.0" },
    -- ★ A10.1b names these two by name. AceGUI draws; the Registry VALIDATES an option
    -- table and the Dialog turns it into widgets - which is the half the rework actually
    -- authors against, and the half nothing had loaded until now.
    { base .. [[AceConfig-3.0\AceConfigRegistry-3.0\AceConfigRegistry-3.0.lua]],
      "AceConfigRegistry-3.0" },
    { base .. [[AceConfig-3.0\AceConfigDialog-3.0\AceConfigDialog-3.0.lua]],
      "AceConfigDialog-3.0" },
}

local failed, loaded = {}, 0
for _, e in ipairs(order) do
    local ok, why = tryload(e[1], e[2])
    if ok then loaded = loaded + 1 else failed[#failed + 1] = { e[2], why } end
end

-- ---- then every widget, each on its own, so one casualty does not hide the rest.
local widgets, wf = {}, io.popen('dir /b "' .. base .. 'AceGUI-3.0\\widgets\\*.lua" 2>nul')
if wf then
    for line in wf:lines() do widgets[#widgets + 1] = line end
    wf:close()
end
table.sort(widgets)

local wok, wbad = 0, {}
for _, w in ipairs(widgets) do
    local ok, why = tryload(base .. [[AceGUI-3.0\widgets\]] .. w, "AceGUI-3.0")
    if ok then wok = wok + 1 else wbad[#wbad + 1] = { w, why } end
end

print(("[%s]"):format(DIST:match("[^\\]+$") or DIST))
print(("  core   %d/%d loaded"):format(loaded, #order))
for _, f in ipairs(failed) do print(("    x %-22s %s"):format(f[1], f[2])) end
print(("  widget %d/%d loaded"):format(wok, #widgets))
for _, f in ipairs(wbad) do print(("    x %-30s %s"):format(f[1], f[2])) end

-- ★★★ AND NOW THE HALF THAT ACTUALLY MATTERS. Loading only registers constructors;
-- nothing touches a frame method until a widget is CREATED and LAID OUT.
-- driver_ui_scope §3's A' rests on PerformLayout running under lua51 - so run it.
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
local KINDS = { "SimpleGroup", "InlineGroup", "TabGroup", "Label", "Button",
                "EditBox", "CheckBox", "Dropdown", "Slider", "Heading" }
local built, buildfail = {}, {}
if AceGUI then
    for _, kind in ipairs(KINDS) do
        local ok, w = pcall(AceGUI.Create, AceGUI, kind)
        if ok and w then built[#built + 1] = kind
        else buildfail[#buildfail + 1] = { kind, firstline(w) } end
    end
end
print(("  widgets CREATED %d/%d"):format(#built, #KINDS))
for _, b in ipairs(buildfail) do print(("    x %-14s %s"):format(b[1], b[2])) end

-- ⚠ and a real layout pass: a container with children, told to lay itself out.
local laid, layerr
if AceGUI then
    laid, layerr = pcall(function()
        local g = AceGUI:Create("SimpleGroup")
        g:SetLayout("Flow")
        for _, k in ipairs({ "Label", "Button", "EditBox" }) do
            local child = AceGUI:Create(k)
            if child then g:AddChild(child) end
        end
        g:SetWidth(300); g:SetHeight(200)
        g:DoLayout()
    end)
end
print(("  PerformLayout: %s"):format(laid and "RAN" or ("FAILED - " .. firstline(layerr))))

-- ★★★ AND THE REAL REHEARSAL: a Dungeon-Run-shaped option table, validated by the
-- Registry and built by the Dialog. This is A10.1's frame in miniature - a TabGroup with
-- three lanes, and the node editor's three items in data-flow order (A10.3a).
local Reg = LibStub and LibStub("AceConfigRegistry-3.0", true)
local Dlg = LibStub and LibStub("AceConfigDialog-3.0", true)
local OPTS = {
    type = "group", name = "Dungeon Run", childGroups = "tab",
    args = {
        run = { type = "group", name = "run", order = 1, args = {
            load = { type = "select", name = "load run", order = 1,
                     values = { r1 = "a run" }, get = function() end, set = function() end },
        } },
        promoter = { type = "group", name = "promoter", order = 2, args = {
            note = { type = "description", name = "readout", order = 1 },
        } },
        node = { type = "group", name = "node editor", order = 3, args = {
            sense = { type = "select", name = "detect", order = 1,
                      values = { reachHere = "reach here", bossKilled = "boss killed" },
                      get = function() end, set = function() end },
            reach = { type = "input", name = "reach", order = 2,
                      get = function() end, set = function() end },
            boss  = { type = "select", name = "boss", order = 3, values = {},
                      hidden = function() return true end,
                      get = function() end, set = function() end },
            doing = { type = "multiselect", name = "what I do", order = 4,
                      values = { supertrack = "point the tracker", advance = "advance (+1)" },
                      get = function() end, set = function() end },
            seen  = { type = "toggle", name = "if seen", order = 5,
                      get = function() end, set = function() end },
            note  = { type = "input", name = "Route instructions", order = 6, multiline = false,
                      get = function() end, set = function() end },
        } },
    },
}
local vok, verr = false, nil
if Reg then
    vok, verr = pcall(Reg.RegisterOptionsTable, Reg, "COA_DungeonRun", OPTS)
    if vok then vok, verr = pcall(Reg.ValidateOptionsTable, Reg, OPTS, "COA_DungeonRun") end
end
print(("  option table VALIDATED: %s"):format(vok and "yes" or ("no - " .. firstline(verr))))

local dok, derr = false, nil
if Dlg and vok then
    dok, derr = pcall(function()
        local f = Dlg:Open("COA_DungeonRun")
        return f
    end)
end
print(("  Dialog:Open (builds the frame): %s")
      :format(dok and "RAN" or ("no - " .. firstline(derr))))

-- ★ AND THE POINT OF THE EXERCISE: what it asked our stubs for that we do not model.
local un = F.Unmodelled()
table.sort(un)
local holes, state = F.TemplateHoles()
print(("  templates: %s, %d unresolved"):format(state, #holes))
for _, h in ipairs(holes) do print("    ? " .. h) end
print(("  stub surface: %d method(s) answered by the catch-all"):format(#un))
local line = "    "
for i, m in ipairs(un) do
    line = line .. m .. (i < #un and ", " or "")
    if #line > 84 then print(line); line = "    " end
end
if line ~= "    " then print(line) end

-- ---- EMIT for the term matcher. Routine run -> staging (gitignored).
local tag = DIST:match("[^\\]+$") or "ace"
local out = io.open([[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\staging\ace_api_]]
                    .. tag .. ".txt", "w")
if out then
    out:write("# kind\tname\n")
    for _, m in ipairs(un) do out:write("method\t" .. m .. "\n") end
    local gm = {}
    for k in pairs(GLOBAL_MISS) do gm[#gm + 1] = k end
    table.sort(gm)
    for _, g in ipairs(gm) do out:write("global\t" .. g .. "\n") end
    out:close()
    print(("  emitted %d method(s) + %d unresolved global(s) -> staging/ace_api_%s.txt")
          :format(#un, #gm, tag))
end
