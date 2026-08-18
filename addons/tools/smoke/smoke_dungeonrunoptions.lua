-- Offline smoke for COA_DungeonRun options.lua - THE ONE FRAME (A10.1).
--
-- ★★ IT BUILDS THE REAL THING. The shipped lite Ace3 under `addons/COA_DungeonRun/Libs`,
-- the client's own frame templates, the client's own FrameXML code - all under lua51.
-- Nothing here is a model of Ace; it IS Ace, running.
--
-- Run: .tools/lua51/lua5.1.exe addons/tools/smoke/smoke_dungeonrunoptions.lua

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\]]
local ADDON = ROOT .. [[addons\COA_DungeonRun\]]
local LIBS = ADDON .. [[Libs\]]

local F = assert(loadfile(ROOT .. [[addons\tools\smoke\frames.lua]]))()

-- ★ Record what the harness is asked for and does not model, exactly as the Ace probe
-- does - a frame that renders because every unknown answered `function() end` is not a
-- frame that rendered.
local GLOBAL_MISS = {}
setmetatable(_G, { __index = function(_, k)
    if type(k) == "string" then GLOBAL_MISS[k] = (GLOBAL_MISS[k] or 0) + 1 end
    return nil
end })

local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }
UIParent = F.New("UIParent")
F.SetRoot(UIParent, 1024, 768, 0, 0)
function CreateFrame(_, name, parent, template)
    return F.New(name, parent or UIParent, template)
end
function GetTime() return 100.0 end
function geterrorhandler() return function(e) error(e, 0) end end
function wipe(t) for k in pairs(t) do t[k] = nil end return t end
table.wipe = wipe
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
C_Timer = { After = function(_, fn) if fn then fn() end end,
            NewTicker = function() return { Cancel = function() end } end }
GameFontHighlight = F.New("GameFontHighlight")
GameFontHighlightSmall = F.New("GameFontHighlightSmall")

local FX = assert(loadfile(ROOT .. [[addons\tools\smoke\framexml.lua]]))()
FX.MakeFrame = function(n) return F.New(n) end
local FXSTATS = FX.Load()

-- ---- the SHIPPED lite Ace3, in the .toc's own order.
local function load(path)
    local chunk = assert(loadfile(path), "cannot load " .. path)
    assert(pcall(chunk, "COA_DungeonRun", {}))
end
load(LIBS .. [[LibStub\LibStub.lua]])
load(LIBS .. [[CallbackHandler-1.0\CallbackHandler-1.0.lua]])
load(LIBS .. [[AceGUI-3.0\AceGUI-3.0.lua]])
local wf = io.popen('dir /b "' .. LIBS .. 'AceGUI-3.0\\widgets\\*.lua" 2>nul')
local widgets = {}
if wf then
    for line in wf:lines() do widgets[#widgets + 1] = line end
    wf:close()
end
table.sort(widgets)
for _, w in ipairs(widgets) do load(LIBS .. [[AceGUI-3.0\widgets\]] .. w) end
load(LIBS .. [[AceConfig-3.0\AceConfigRegistry-3.0\AceConfigRegistry-3.0.lua]])
load(LIBS .. [[AceConfig-3.0\AceConfigDialog-3.0\AceConfigDialog-3.0.lua]])

-- ---- the addon's own files.
local NS = {}
NS.Say = function(m) DEFAULT_CHAT_FRAME:AddMessage(m) end
local function ours(f) assert(loadfile(ADDON .. f))("COA_DungeonRun", NS) end
ours("store.lua")
ours("routes.lua")
ours("options.lua")

-- ⚠ `options.lua` reads `Map.ArtSize` and NOTHING else from the map. Stubbing the whole
-- of map.lua here would make this smoke depend on the map's own load chain; giving it
-- the one function it consumes keeps the dependency the size it actually is.
NS.Map = { ArtSize = function() return 1002, 668 end }
local Options = NS.Options
assert(Options, "options.lua did not publish Options")
Options.Init()

-- =====================================================================
-- ★ A10.1a - THREE LANES AT THE ROOT, AND NOTHING ELSE BESIDE THEM
-- =====================================================================
local lanes, others = Options.Lanes()
assert(#lanes == 3,
       ("THE ROOT DOES NOT HOLD THREE LANES: it holds %d (%s). Run, promoter and node "
        .. "editor ARE the pipeline top-down; a fourth would be a decision nobody made "
        .. "and a second would mean a lane was folded away rather than emptied")
       :format(#lanes, table.concat(lanes, ", ")))
assert(#others == 0,
       ("SOMETHING SITS AT THE ROOT BESIDE THE LANES: %s. A control at the root belongs "
        .. "to no lane, so it appears on every tab - which is how a flat table starts")
       :format(table.concat(others, ", ")))

-- ★★ AND THEY ARE SUBTREES (R1). A lane must own an `args` of its own, because that is
-- the whole of what makes pop-out a container swap rather than a rebuild.
for _, lane in ipairs(lanes) do
    local node = Options.Table().args[lane]
    assert(type(node.args) == "table",
           ("LANE `%s` IS NOT A SUBTREE: it must carry its own `args`, or the same group "
            .. "cannot be handed to a second container and pop-out becomes a rebuild")
           :format(lane))
end

-- =====================================================================
-- ★★★ THE MAP IS THE FLOOR (Battlewrath, 2026-08-18)
--
-- *"The map sizing stays a constant and defines the parent container size. Can already
-- be greater than, can never be lesser than, the map frame."*
--
-- ⚠ This is an ACCURACY rule wearing a layout hat. `map.lua:46` records that the
-- coordinate space (1002x668) and the tile art (1024x768) are two different sizes and
-- that confusing them still RENDERS - wrong by +2.2% across and +15% down, worst
-- furthest from the origin, caught by eye and by nothing mechanical. `Map.FractionAt`
-- divides by the coordinate space, so a container that RESIZES the canvas puts that
-- silent error back. This is the mechanical catch that was missing.
-- =====================================================================
local mw, mh = Options.MapFloor()
assert(mw == 1002 + 32 and mh == 668 + 54,
       ("THE MAP FLOOR IS NOT THE MAP'S OWN SIZE: got %sx%s. It is DERIVED from "
        .. "Map.ArtSize plus the map's chrome, never typed - so it cannot drift from "
        .. "the number it protects"):format(tostring(mw), tostring(mh)))

local fw, fh = Options.FrameSize()
local ok, why = Options.Fits(fw, fh)
assert(ok, ("THE ONE FRAME DOES NOT FIT ITS OWN MAP: %s"):format(tostring(why)))

-- ⚠ AND SMALLER IS REFUSED IN BOTH DIMENSIONS SEPARATELY. A frame wide enough and one
-- pixel short is a different fault from a narrow one, and a guard that folds them into
-- one boolean cannot say which happened.
local narrow, whyN = Options.Fits(mw - 1, mh)
assert(not narrow and whyN:find("NARROW"),
       "A CONTAINER NARROWER THAN THE MAP WAS ACCEPTED: the map defines the floor")
local short, whyS = Options.Fits(mw, mh - 1)
assert(not short and whyS:find("SHORT"),
       "A CONTAINER SHORTER THAN THE MAP WAS ACCEPTED: the map defines the floor")

-- ★ AND THE FLOOR IS NOT A CONSTANT IN THIS FILE. Move the map's coordinate space and
-- the floor moves with it; that is what "derived, never typed" has to mean to be worth
-- saying. ⚠ Restored immediately - a fixture that leaves the world changed is a fixture
-- the next assertion is lying about.
local realArtSize = NS.Map.ArtSize
NS.Map.ArtSize = function() return 2000, 1000 end
local bw, bh = Options.MapFloor()
assert(bw == 2032 and bh == 1054,
       "THE FLOOR IGNORED A CHANGE IN THE COORDINATE SPACE: it is derived from "
       .. "Map.ArtSize, so it must follow it")
NS.Map.ArtSize = realArtSize

-- ⚠ NO SIZE, NO FLOOR - and it says so rather than guessing one. A floor invented while
-- the real one is unknown is the silent scale error with extra steps.
NS.Map.ArtSize = function() return nil, nil end
local none = Options.MapFloor()
assert(none == nil, "A FLOOR WAS INVENTED WHILE THE MAP HAD PUBLISHED NO SIZE")
local okNo, whyNo = Options.Fits(9999, 9999)
assert(not okNo and whyNo:find("published no size"),
       "Fits() PASSED WITHOUT A FLOOR TO CHECK AGAINST")
NS.Map.ArtSize = realArtSize

-- =====================================================================
-- ★ A10.1c - IT RENDERS. Registry validates and the Dialog builds the frame.
-- =====================================================================
local Reg = LibStub("AceConfigRegistry-3.0", true)
local Dlg = LibStub("AceConfigDialog-3.0", true)
assert(Reg and Dlg, "the shipped Ace copy did not publish Registry and Dialog")
assert(Options.registered, "Options.Init did not register the table")

local vok, verr = pcall(Reg.ValidateOptionsTable, Reg, Options.Table(), "COA_DungeonRun")
assert(vok, ("THE OPTION TABLE DOES NOT VALIDATE: %s"):format(tostring(verr)))

-- ★ The build is a FUNCTION because A10.1c's sweep runs it twice. Anything captured
-- outside it would survive the F.Reset between runs and make the diff meaningless.
local function buildFrame()
    Dlg.OpenFrames["COA_DungeonRun"] = nil     -- a fresh frame, not the cached one
    return Dlg:Open("COA_DungeonRun")
end

local dok, derr = pcall(buildFrame)
assert(dok, ("THE FRAME DID NOT BUILD: %s")
       :format(tostring(derr):gsub("[\r\n].*", "")))

-- =====================================================================
-- ★★ A10.1c - THE GEOMETRY, over a NESTED tree
--
-- ⚠ REPORTED, NOT ASSERTED, and the distinction is the same one `check_rects` makes:
-- this measures what an unfinished skeleton produced, so a finding here is NEWS. The
-- assertions below are about the CHECKER's reach - that it walked a tree at all, and
-- that it can still say what it cannot speak for. A10.1c goes green when the lanes
-- carry controls, not while they are empty by design.
-- =====================================================================
local overlaps = F.OverlapsTree(UIParent)
local clipped = F.Containment(UIParent)
print(("  geometry: %d sibling overlap(s), %d clipped"):format(#overlaps, #clipped))
for i = 1, math.min(#overlaps, 5) do
    local h = overlaps[i]
    print(("    overlap in %-28s %s over %s by %.0f x %.0f")
          :format(tostring(h.parent), tostring(h.a), tostring(h.b), h.x, h.y))
end
for i = 1, math.min(#clipped, 5) do
    local c = clipped[i]
    print(("    clipped  %-30s outside %s by %.0f x %.0f")
          :format(tostring(c.child), tostring(c.parent), c.x, c.y))
end

-- ★ THE CHECKER WALKED A TREE, and that is assertable even while the frame is a
-- skeleton. ⚠ A tree walk that found ONE parent is a flat check wearing a new name -
-- which is exactly the failure U2 was raised about, and it would report zero overlaps
-- for the most comforting of reasons.
local parents = 0
local function countParents(f, seen)
    seen = seen or {}
    if seen[f] then return end
    seen[f] = true
    local kids = F.Children(f)
    if #kids > 0 then parents = parents + 1 end
    for _, k in ipairs(kids) do countParents(k, seen) end
end
countParents(UIParent)
assert(parents >= 5,
       ("THE TREE WALK FOUND ONLY %d PARENT(S): Ace nests frame -> TabGroup -> group -> "
        .. "widget -> template regions, so a single-level result means the walk is flat "
        .. "and 'zero overlaps' is being reported about one list")
       :format(parents))

-- =====================================================================
-- ★★★ A10.1c - THE TEXT-METRIC SWEEP: "N verified · M unverifiable", BY NAME
--
-- The one thing the harness cannot read from the client is a font's rendered width.
-- ⚠ So instead of claiming a number, it measures WHICH RECTS DEPEND ON ONE: build,
-- change the metric, build again. A rect that moved is unverifiable; a rect that did
-- not is verified offline whatever the real font does.
-- =====================================================================
local verified, unverifiable = F.MetricSweep(buildFrame)
print(("  text metrics: %d verified · %d unverifiable")
      :format(#verified, #unverifiable))
for i = 1, math.min(#unverifiable, 8) do
    print("    ? " .. unverifiable[i])
end
if #unverifiable > 8 then
    print(("    ... and %d more"):format(#unverifiable - 8))
end

assert(#verified + #unverifiable > 0,
       "THE SWEEP COMPARED NOTHING: it builds the frame twice and diffs the rects, so "
       .. "an empty result means the build produced no named rects either time")

-- ⚠ AND THE SWEEP CAN ACTUALLY SEE A MOVE. A sweep that reports everything verified
-- because its two metrics happen to agree is the comfortable answer and a worthless
-- one - so a deliberately different metric must move at least one rect.
-- ★★ AND THE LIST THAT ACTUALLY ANSWERS A10.1c. The before/after diff above reports
-- what MOVES on re-layout; it cannot report what was BAKED, because the client's own
-- TabResize sets an explicit width on the first pass and nothing re-derives after that.
-- ⚠ A rect frozen from a guess is not verified - it is a guess that stopped moving.
local consumers = F.MetricConsumers()
print(("  metric consumers: %d rect(s) sized from a TEXT MEASUREMENT"):format(#consumers))
for i = 1, math.min(#consumers, 8) do print("    ! " .. consumers[i]) end

assert(#consumers > 0,
       "NOTHING CONSUMED A TEXT METRIC: the frame carries tab labels, and Blizzard's own "
       .. "PanelTemplates_TabResize reads tabText:GetWidth() - so a zero here means the "
       .. "harness is not reaching text at all and every 'verified' rect is untested")

-- ★ The frame must survive being rebuilt - the sweep does it twice and A10.2's folds
-- will do it per pane. A builder that only works once is a builder that works never.
assert(pcall(buildFrame), "THE FRAME DID NOT REBUILD after the sweep")

print("smoke_dungeonrunoptions: OK - 3 lanes, floor derived from the coordinate space, "
      .. "Registry validated, Dialog built the frame")
FX.Report(FXSTATS, os.getenv("FXVERBOSE") == "1")
