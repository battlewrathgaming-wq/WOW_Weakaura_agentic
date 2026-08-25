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
-- ⚠ THE LOADER MOVED TO `ace_stack.lua` and this block now CALLS it. It was inlined here
-- until the remote folded onto AceGUI and a second smoke needed the identical sequence -
-- and the widget list is read from DISK, so two copies would agree today and diverge the
-- first time a widget file is added and only one of them is looked at.
local ACE = assert(loadfile(ROOT .. [[addons\tools\smoke\ace_stack.lua]]))()
ACE.Load(LIBS)

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

-- ⚠⚠ THE COUNT IS ASSERTED FIRST, AND THE ORDER IS LOAD-BEARING. The name loop
-- below tests every lane, so a REMOVED lane trips it before the count is ever
-- reached - and `mutate.py`'s *remove a lane* row then bit on the wrong message.
-- ★ Count first, names second: a removal is a COUNT fault and a rename is a NAME
-- fault, and each now reaches its own row. Same lesson as L18's pairing, which
-- had to be reordered for exactly this reason.

assert(#lanes == 3,
       ("THE ROOT DOES NOT HOLD THREE LANES: it holds %d (%s). Run, promoter and node "
        .. "editor ARE the pipeline top-down; a fourth would be a decision nobody made "
        .. "and a second would mean a lane was folded away rather than emptied")
       :format(#lanes, table.concat(lanes, ", ")))

-- ★★★ THE KEYS ARE NAMED, NOT MERELY COUNTED - added 2026-08-25 with AL-56's rename.
--
-- ⚠⚠ A COUNT IS WHAT LET THE WRONG KEY SURVIVE. `args.run` held CURATION while AL-49
-- gave *"Run capture"* to the REMOTE - one word on both sides of the authoring/running
-- split - and every assertion here passed the whole time, because three lanes named
-- anything at all is still three lanes.
--
-- ★ AND THE KEYS ARE THE HALF WORTH PINNING: acceptance rows CITE them (A10.1a), so a
-- rename must be deliberate and reconciled rather than quiet. The DISPLAY names are taste
-- and are deliberately not asserted - they may move without the record moving.
local WANT = { "curate", "node", "promote" }
for i, key in ipairs(WANT) do
    assert(lanes[i] == key,
           ("LANE %d IS `%s`, EXPECTED `%s`. The lane keys are cited by A10.1a and by the "
            .. "acceptance rows; renaming one is a change the governing set has to ride. "
            .. "★ Counting three lanes cannot catch this - it is what let `run` hold "
            .. "curation while AL-49 gave that word to the remote."):format(
                i, tostring(lanes[i]), key))
end

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
local parents = F.ParentCount(UIParent)
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
-- =====================================================================
-- ★★★ A10.1c's SECOND HALF - ONE BLIND-SPOT LIST, and the join ASSERTED.
--
-- The row: *"every stubbed Blizzard function is REPORTED by name in the same
-- unverifiable list"* (bench U6, (c) accepted: **a stubbed function is a blind spot
-- of the same class as a text metric**).
--
-- ⚠ Both halves already EXISTED and were reported in two different places - the
-- sweep here, the stubs in `FX.Report` at the foot. Two lists is not "the same
-- list", and nothing tied them, so a stub added later would have been printed in a
-- report nobody diffed while this list stayed reassuringly short.
-- =====================================================================
local blind = {}
local function blindly(kind, name, why)
    blind[#blind + 1] = { kind = kind, name = name, why = why }
end

for _, n in ipairs(unverifiable) do
    blindly("rect-moved", n, "its rect moved when the text metric changed")
end
for _, n in ipairs(consumers) do
    blindly("rect-baked", n, "sized from a text measurement and then frozen")
end
for _, s in ipairs(FX.Stubs()) do
    blindly("stub", s[1], s[2])
end
for _, m in ipairs(FX.StillMissing(FXSTATS)) do
    blindly("absent", m, "a FrameXML file that would provide it did not run")
end

table.sort(blind, function(a, b)
    if a.kind ~= b.kind then return a.kind < b.kind end
    return a.name < b.name
end)

print(("  BLIND SPOTS: %d verified · %d unverifiable, by name and by kind")
      :format(#verified, #blind))
-- ⚠ A FEW OF EACH KIND, never the first N. The first cut printed 12 entries in
-- alphabetical order, which put every `absent` at the top and hid the stubs and the
-- rects completely - a list written to make blind spots VISIBLE, burying three of its
-- four kinds behind the noisiest one.
local order, shown = { "rect-moved", "rect-baked", "stub", "absent" }, {}
for _, b in ipairs(blind) do shown[b.kind] = (shown[b.kind] or 0) + 1 end
for _, kind in ipairs(order) do
    local n = shown[kind] or 0
    if n > 0 then
        print(("    %-11s %d"):format(kind, n))
        local left = 3
        for _, b in ipairs(blind) do
            if b.kind == kind and left > 0 then
                print(("      %-30s %s"):format(b.name, b.why))
                left = left - 1
            end
        end
        if n > 3 then print(("      ... and %d more %s"):format(n - 3, kind)) end
    end
end

-- ⚠ THE JOIN IS THE CRITERION, so it is asserted rather than printed and trusted.
-- Every stub must be IN the list, by name - not merely counted somewhere else.
local inList = {}
for _, b in ipairs(blind) do inList[b.name] = b.kind end
for _, s in ipairs(FX.Stubs()) do
    assert(inList[s[1]] == "stub",
           "A STUBBED FUNCTION IS MISSING FROM THE BLIND-SPOT LIST: `" .. s[1]
           .. "` is stubbed, and A10.1c requires it reported BY NAME in the SAME list "
           .. "as the text metrics - a stub is a blind spot of the same class. Being "
           .. "printed in a separate report at the foot is what this row rejects")
end

-- ★ AND THE LIST MUST CARRY ALL FOUR KINDS' COUNTS HONESTLY. A join that silently
-- dropped a source would leave the list shorter and look BETTER, which is the
-- direction a wrong answer always fails in here.
local seen = {}
for _, b in ipairs(blind) do seen[b.kind] = (seen[b.kind] or 0) + 1 end
assert((seen.stub or 0) == #FX.Stubs(),
       "THE STUB COUNT DOES NOT MATCH: the list holds " .. tostring(seen.stub or 0)
       .. " of " .. #FX.Stubs() .. " stubs. A shorter blind-spot list reads as better "
       .. "coverage, so this can only ever fail in the flattering direction")
assert((seen["rect-baked"] or 0) == #consumers,
       "THE BAKED-RECT COUNT DOES NOT MATCH: a rect frozen from a guess is not "
       .. "verified, it is a guess that stopped moving")

-- ★ The frame must survive being rebuilt - the sweep does it twice and A10.2's folds
-- will do it per pane. A builder that only works once is a builder that works never.
assert(pcall(buildFrame), "THE FRAME DID NOT REBUILD after the sweep")

-- =====================================================================
-- ★★★ THE ONE FRAME, AND THE MAP KEEPS EVERYTHING THE ACCURACY DEPENDS ON
--
-- Battlewrath: *"The map and the side unified options are planned to be one frame"*, and
-- *"the map sizing stays a constant and defines the parent container size."*
--
-- ⚠ The hazard is not that seating LOOKS wrong - it is that seating the map into a
-- container that lays out its children would RESIZE the canvas, and a resized canvas
-- still draws. It draws a trail that follows corridors and is wrong everywhere, by
-- +2.2% across and +15% down (map.lua:46). Nothing reports it. So the assertions below
-- are about what did NOT change.
-- =====================================================================
local win = Options.BuildFrame()
assert(win, "THE ONE FRAME DID NOT BUILD")
assert(Options.mapSeat and Options.paneSeat,
       "THE FRAME HAS NO SEATS: the map and the lanes are one frame, so both seats "
       .. "exist before either is filled")

local sw, sh = Options.mapSeat.frame:GetWidth(), Options.mapSeat.frame:GetHeight()
local okSeat, whySeat = Options.Fits(sw, sh)
assert(okSeat, ("THE MAP SEAT IS SMALLER THAN THE MAP: %s"):format(tostring(whySeat)))

-- ★ A stand-in map frame with the map's own numbers, so the re-parent is exercised on
-- something the size of the real thing.
local fakeMap = F.New("COA_DungeonRunMap")
fakeMap:SetWidth(mw); fakeMap:SetHeight(mh)
fakeMap._scale = 2.5                      -- as if the author had zoomed

-- ⚠⚠ THE SEAT IS DELIBERATELY BIGGER THAN THE MAP, and the first fixture was not.
-- With a seat exactly the map's size, "resize the map to its seat" changes nothing and
-- the guard cannot fail - the mutation came back `!! SILENT`. ★ A seat LARGER than the
-- map is also the real case (Battlewrath: "can already be greater than"), and it is the
-- only shape in which a layout engine stretching the canvas is visible at all.
-- ★ BOTH the widget's frame AND its CONTENT, because `SeatMap` parents into
-- `content or frame` - enlarging only the outer one leaves the number the code actually
-- reads unchanged, which is how the second attempt at this mutation stayed SILENT too.
Options.mapSeat.frame:SetWidth(mw + 200)
Options.mapSeat.frame:SetHeight(mh + 120)
if Options.mapSeat.content then
    Options.mapSeat.content:SetWidth(mw + 200)
    Options.mapSeat.content:SetHeight(mh + 120)
end

local seated, whySeat2 = Options.SeatMap(fakeMap)
assert(seated, ("THE MAP WAS NOT SEATED: %s"):format(tostring(whySeat2)))

-- ⚠⚠ THE THREE THINGS THAT MUST NOT HAVE MOVED.
assert(fakeMap:GetWidth() == mw and fakeMap:GetHeight() == mh,
       ("SEATING RESIZED THE MAP: %sx%s, was %gx%g. A container that sizes the canvas "
        .. "puts back the silent scale error - the map keeps its own size and the SEAT "
        .. "is what accommodates it")
       :format(tostring(fakeMap:GetWidth()), tostring(fakeMap:GetHeight()), mw, mh))
assert(fakeMap._scale == 2.5,
       "SEATING TOUCHED THE MAP'S SCALE: zoom is canvas:SetScale and it is the author's, "
       .. "not the container's")
local aw, ah = NS.Map.ArtSize()
assert(aw == 1002 and ah == 668,
       ("SEATING MOVED THE COORDINATE SPACE: %sx%s. Map.FractionAt divides by it, so it "
        .. "is not a display size and nothing about a container may change it")
       :format(tostring(aw), tostring(ah)))

-- ★ And it went where it was told.
assert(fakeMap:GetParent() == (Options.mapSeat.content or Options.mapSeat.frame),
       "THE MAP WAS NOT RE-PARENTED INTO ITS SEAT")

-- ⚠ A SEAT TOO SMALL IS REFUSED, not squeezed into. This is the guard doing the work
-- the comment above only describes.
local realSeat = Options.mapSeat
local tiny = F.New("tinySeat"); tiny:SetWidth(mw - 1); tiny:SetHeight(mh)
Options.mapSeat = { frame = tiny, content = realSeat.content }
local refused, whyRef = Options.SeatMap(fakeMap)
assert(not refused and tostring(whyRef):find("NARROW"),
       "A MAP WAS SEATED INTO A CONTAINER NARROWER THAN ITSELF")
Options.mapSeat = realSeat

print("smoke_dungeonrunoptions: OK - 3 lanes, floor derived from the coordinate space, "
      .. "Registry validated, Dialog built the frame")
FX.Report(FXSTATS, os.getenv("FXVERBOSE") == "1")
