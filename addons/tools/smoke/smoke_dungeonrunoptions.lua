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
-- ⚠ THE DECLARATION FIRST. `options.lua` BUILDS its lanes from `panes_decl.lua` rather than
-- listing them, so without this every lane comes back empty and the assertions below grade
-- an absence. Same shape as the .toc ordering, for the same reason.
ours("panes_decl.lua")
ours("options.lua")

-- ⚠ `options.lua` reads `Map.ArtSize` and NOTHING else from the map. Stubbing the whole
-- of map.lua here would make this smoke depend on the map's own load chain; giving it
-- the one function it consumes keeps the dependency the size it actually is.
-- ⚠ `options.lua` reads THREE things from the map now, not one: `ArtSize` for the floor,
-- and `Selected` / `LoadedId` for the SUBJECT the node lane authors. AL-60: the subject IS
-- the selection, so a stub without it gives every control nil to read and a lane that
-- validates while authoring nothing.
local SEL = { p = nil, route = nil }
NS.Map = {
    ArtSize = function() return 1002, 668 end,
    Selected = function() return SEL.p end,
    LoadedId = function(kind) return kind == "route" and SEL.route or nil end,
}
local Options = NS.Options
-- ⚠ NAMED HERE because the node lane authors through them: the fold reads and writes
-- real route state, so the smoke needs the same modules the pane does.
local Routes, Store = NS.Routes, NS.Store
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
-- fault, and each now reaches its own row. Same lesson as DR_Process_18's pairing, which
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

-- =====================================================================
-- ★★★ A10.2a's THREE SURVIVORS - the fold, graded on what it AUTHORS
-- =====================================================================
-- ⚠ The Registry validating the table proves the SHAPE is legal AceConfig and nothing
-- more. A lane whose every `get` returns nil validates perfectly.
-- =====================================================================
-- ★★★ THE PANE IS BUILT FROM THE DECLARATION, not merely described by it
-- =====================================================================
-- His shape, 2026-08-26: *"a flat template desk side of what content lives on each table of
-- content."* ⚠ A template the builder IGNORES is the second copy that drifts - the `layout`
-- skill's own rule - so the test is not *"do both say the same"* but *"does changing the
-- declaration change the pane"*.
local Panes = assert(NS.Panes, "panes_decl.lua did not publish Panes")

-- ★ THE LANE IS NON-EMPTY FIRST. The growth proof below was catching an empty lane too,
-- on a message about repeated keys - so a build that read NOTHING reported as a counting
-- fault. Each fault reaches its own row now.
do
    local built = 0
    for _ in pairs(Options.Table().args.node.args) do built = built + 1 end
    assert(built == #Panes.lanes.node.controls,
           ("THE PANE DID NOT BUILD THE DECLARATION: %d control(s) declared, %d built. "
            .. "`options.lua` names no control of its own, so an empty lane means the "
            .. "builder is not reading the table"):format(#Panes.lanes.node.controls, built))
end

assert(#Options.Missing() == 0,
       "A DECLARED CONTROL HAS NO BODY: " .. table.concat(Options.Missing(), ", ")
       .. " - a control that draws and does nothing is worse than one that is absent, "
       .. "because it looks authored")

do
    -- ⚠⚠ AND THE REFUSAL NEEDS A FIXTURE TO BE REACHABLE. Every declared control has a
    -- body today, so the `else` branch that records a miss is never taken and breaking it
    -- changed nothing - the mutation said so by staying silent.
    -- ★ So declare one nothing implements, and look.
    local lane = Panes.lanes.node
    lane.controls[#lane.controls + 1] = { key = "notImplemented", kind = "input", word = "x" }
    local probe = Options.Table().args.node
    lane.controls[#lane.controls] = nil

    assert(probe.args.notImplemented == nil,
           "A DECLARED CONTROL WITH NO BODY WAS DRAWN ANYWAY: it would render and do "
           .. "nothing, which is worse than absent because it looks authored")
    local named = false
    for _, m in ipairs(Options.Missing()) do
        if m == "node.notImplemented" then named = true end
    end
    assert(named,
           "AND IT MUST BE NAMED: a control silently dropped from the pane is a build fault "
           .. "nobody can ask about. Missing() reports: "
           .. (table.concat(Options.Missing(), ", ")))
    for i = #Options.Missing(), 1, -1 do Options.Missing()[i] = nil end
end

-- ★★★ A KIND ACECONFIG CANNOT FORM IS A QUESTION, NOT AN ERROR (`DR_Pane_4`).
-- His note, 2026-08-26: *"things like segments and stuff will factor into their own display
-- types."* A segment readout is not a `select` or an `input` - and `type-or-feature.md`
-- decides whether it is a TYPE or one pane's feature. This branch only makes the moment
-- visible rather than letting the Registry reject the whole table at build time.
assert(#Panes.Unformable() == 0,
       "SOMETHING IS DECLARED THAT ACE CANNOT DRAW: " .. table.concat(Panes.Unformable(), ", ")
       .. " - not a defect, but it must be ANSWERED before it ships")

do
    -- ⚠⚠ TWO THINGS THIS FIXTURE HAD TO LEARN, and each was a silent pass.
    --   1. THE KEY MUST HAVE A BODY, or the kind is never reached: a first cut declared
    --      `segments`, which has no entry in `BODIES`, so it was dropped for being
    --      unimplemented and breaking the kind check changed nothing.
    --   2. AND APPENDING A DUPLICATE DOES NOT OVERRIDE. The loop builds in declaration
    --      order, so the VALID `ordinal` at index 2 landed first and the unformable copy
    --      at index 4 only added a `Missing` row - the assertion then fired on a clean
    --      tree, which is the fixture failing rather than the code.
    -- ⟶ So the existing control's KIND is changed in place and put back.
    local lane = Panes.lanes.node
    local ord
    for _, c in ipairs(lane.controls) do if c.key == "ordinal" then ord = c end end
    assert(ord, "the fixture needs the declared ordinal to borrow")
    local was = ord.kind
    ord.kind = "segmentReadout"
    local probe = Options.Table().args.node
    local named = Panes.Unformable()
    ord.kind = was

    assert(probe.args.ordinal == nil,
           "AN UNFORMABLE KIND WAS HANDED TO ACECONFIG: the Registry rejects the WHOLE "
           .. "table on an unknown type, so one undecided control would take every other "
           .. "lane down with it")
    assert(#named == 1 and named[1]:find("segmentReadout", 1, true),
           "AND IT MUST BE NAMED: a control deferred for want of a decision reads exactly "
           .. "like one nobody declared. got " .. table.concat(named, ", "))
    for i = #Options.Missing(), 1, -1 do Options.Missing()[i] = nil end
end

do
    -- ★★ THE PROOF: append to the DECLARATION and the PANE grows. Nothing in `options.lua`
    -- names these controls, so if this fails the list is being held in two places.
    local lane = Panes.lanes.node
    lane.controls[#lane.controls + 1] =
        { key = "sense", kind = "select", word = "sense", subjects = "any" }
    local grown = Options.Table().args.node
    lane.controls[#lane.controls] = nil

    local gn = 0
    for _ in pairs(grown.args) do gn = gn + 1 end
    assert(gn == 3, "a repeated key overwrites rather than doubling, got " .. gn)
    assert(grown.args.sense.order == 4,
           "THE PANE IS NOT READING THE DECLARATION: a control appended to `panes_decl` must "
           .. "arrive in the pane at its declared position. `options.lua` names no control, "
           .. "so a stale order here means the list lives in two places. got "
           .. tostring(grown.args.sense.order))
end

-- ⚠ AND THE ORDER IS THE LIST'S POSITION, which is what `DR_Pane_4` leaves us: placement
-- within is the library's, the ARRANGEMENT is ours, and a declaration's order IS that.
for i, c in ipairs(Panes.lanes.node.controls) do
    assert(Options.Table().args.node.args[c.key].order == i,
           "control `" .. c.key .. "` must take order " .. i .. " from its position")
end

-- ★ THE EMPTY LANES CARRY A REASON. An empty lane with a `blocked` line is a named gap;
-- an empty lane without one is a lane nobody has looked at, and they read identically in a
-- pane. `trace-what-we-know`: name where the data stops.
for _, k in ipairs({ "curate", "promote" }) do
    local lane = Panes.lanes[k]
    assert(#lane.controls == 0, "`" .. k .. "` has no ruled control list yet")
    assert(type(lane.blocked) == "string" and #lane.blocked > 0,
           "AN EMPTY LANE WITHOUT A REASON: `" .. k .. "` must say what it is waiting on, or "
           .. "it is indistinguishable from a lane nobody has considered")
end

local node = Options.Table().args.node
local NODE_ARGS = { "sense", "ordinal", "note" }
for _, k in ipairs(NODE_ARGS) do
    assert(node.args[k], "THE NODE LANE IS MISSING `" .. k .. "`: A10.2a orders sense · "
           .. "ordinal · note FIRST - the three the checker cannot see today and the three "
           .. "that SURVIVE into the node editor")
end
local n = 0
for _ in pairs(node.args) do n = n + 1 end
assert(n == 3, "and ONLY those three - the rest of the object pane is REPLACED by A10.3, "
       .. "never folded. got " .. n)

-- ★★ WITH NO SELECTION, EVERY CONTROL IS DISABLED rather than absent. Disabled says
-- *this exists and needs a subject*; hidden says nothing at all - the same rule the
-- remote's pin has carried since §128.
SEL.p, SEL.route = nil, nil
for _, k in ipairs(NODE_ARGS) do
    -- ⚠ THE FUNCTION'S EXISTENCE IS PART OF THE ASSERTION. Calling it straight made a
    -- REMOVED `disabled` an index error rather than this message, so the mutation proved
    -- the file parses instead of proving the guard.
    local d = node.args[k].disabled
    assert(type(d) == "function" and d(),
           "`" .. k .. "` must be DISABLED with no selection - disabled says *this exists "
           .. "and needs a subject*; absent says nothing at all")
end

-- ★★★ NOW A REAL SUBJECT, minted through the shipped doors.
--
-- ⚠ THE STORE IS BOOTED HERE, and it had never needed to be: until the fold this smoke
-- only ever asked `options.lua` for its SHAPE, and a shape needs no data. The moment a
-- lane AUTHORS, the pane's dependencies become the harness's - the same step
-- `smoke_drive` and `smoke_bucket` both needed this week.
-- ★ MINTED THROUGH THE SHIPPED DOORS, never hand-assembled: §492's lesson is that a route
-- authored through the real API used to build with ZERO ROWS and stall in silence, and a
-- hand-built fixture cannot find that class of fault because it writes what the doors
-- forgot to.
COA_DungeonRunDB = nil
assert(Store.Load(), "the store loads fresh")
Routes.Init()

local rid = assert(Routes.Create("Lane test", 33))
local b = assert(Routes.AddBeacon(rid, { mapX = 0.3, mapY = 0.4, x = 1, y = 2, z = 0,
                                         mapID = 33, floor = 1, radius = 8 }, 1))
local child = assert(Routes.AddChildHere(rid, b))
SEL.p, SEL.route = child, rid

-- THE SENSE. ⚠ ONE VALUE TODAY AND THAT IS THE RULING, not a stub: `Routes.SENSES` is
-- EMPTY by RI-15/17, and `reachHere` is the DEFAULT that stores nothing (§79).
local vals = node.args.sense.values()
local nv = 0
for _ in pairs(vals) do nv = nv + 1 end
assert(nv == #Routes.SENSES + 1 and vals[Routes.SENSE_DEFAULT],
       "the offer is the settable list plus the default. offered " .. nv
       .. " for a list of " .. #Routes.SENSES)

-- ★★★ AND THE LIST IS EMPTY TODAY, SO THE ASSERTION ABOVE CANNOT SEE THE FAULT.
-- `Routes.SENSES` holds nothing (RI-15/17's ruling), so a pane that IGNORED the list and
-- offered only the default would satisfy every count above. The mutation said so by
-- staying silent. ⟶ Put something in the list and look.
-- ⚠ THIS IS THE WHOLE POINT OF THE CONTROL: *"the day a state sense lands, this offers
-- it with no edit here."* An untested claim about a future is just a comment.
do
    Routes.SENSES[#Routes.SENSES + 1] = "inCombat"
    local grown = node.args.sense.values()
    local gn = 0
    for _ in pairs(grown) do gn = gn + 1 end
    Routes.SENSES[#Routes.SENSES] = nil
    assert(gn == 2 and grown["inCombat"],
           "THE SENSE OFFER IS NOT BUILT FROM `Routes.SENSES`: a sense added to the "
           .. "settable list must appear in the pane with no edit to the pane. offered "
           .. gn .. " with one in the list")
end
assert(node.args.sense.get() == Routes.SENSE_DEFAULT,
       "AN UNSET NODE READS AS WHAT IT DOES, not as blank - R6's pair, and a picker shows "
       .. "the RESOLVED sense or an unset node displays empty while behaving like reachHere")

-- THE ORDINAL. ⚠ EMPTY IS AN AUTHORED STATE - out of the line on purpose - not a blank.
Routes.SetChildOrdinal(b, child, 2.5)
assert(node.args.ordinal.get() == "2.5", "a decimal ordinal round-trips, got "
       .. tostring(node.args.ordinal.get()))
node.args.ordinal.set(nil, "")
assert(Routes.OrdinalOf(child) == nil,
       "CLEARING THE BOX MUST TAKE THE CHILD OUT OF THE LINE: empty is the opt-out and "
       .. "`tonumber(\"\")` is already nil, so nothing here needs a branch that could "
       .. "decide differently")
node.args.ordinal.set(nil, "3")
assert(Routes.OrdinalOf(child) == 3, "and a number goes back in")

-- THE NOTE. ⚠ The cap is ASKED FOR, never typed here.
node.args.note.set(nil, string.rep("x", Routes.NOTE_MAX + 50))
local got = node.args.note.get()
assert(#got == Routes.NOTE_MAX,
       "THE NOTE IS NOT CAPPED AT `Routes.NOTE_MAX`: A4.1 caps the one free text on this "
       .. "surface, and a 200 typed into the pane is the second copy that drifts the day "
       .. "the cap moves. got " .. #got)

-- ★★ AND NO LABEL IS A LITERAL. A10.2's own mutation row: *"type a folded label as a
-- literal in `options.lua` → A5.3's 1:1 check reds it."* Every name resolves through the
-- ONE lookup, and a MISS passes through the code term rather than blanking (A5.1).
for _, k in ipairs(NODE_ARGS) do
    assert(type(node.args[k].name) == "function",
           "`" .. k .. "`'s name must RESOLVE through the adaptor, not be typed - a literal "
           .. "here is a second private word table with one entry")
end

-- ★★ SUBJECTS ARE THE DECLARATION'S TOO, and `Applies` is the ONE place that reads them.
-- ⚠ `ordinal` names `child` only, so a BEACON selection must disable it - a beacon has no
-- place in a line, and an enabled box over a field that cannot exist is a control lying.
assert(Panes.Applies({ subjects = "any" }, "beacon"), "`any` covers every selection")
assert(not Panes.Applies({ subjects = "any" }, nil), "but `any` still needs A selection")
assert(Panes.Applies({ subjects = { "child" } }, "child"), "a named subject matches")
assert(not Panes.Applies({ subjects = { "child" } }, "beacon"), "and excludes the rest")
assert(Panes.Applies({}, nil),
       "NO `subjects` KEY IS NOT `any`: a control that does not depend on a selection must "
       .. "never be disabled for want of one")

SEL.p = { kind = "beacon" }
assert(node.args.ordinal.disabled(),
       "THE ORDINAL MUST DISABLE ON A BEACON: `panes_decl` names `child` only, and a beacon "
       .. "has no place in a line - an enabled box over a field that cannot exist is a "
       .. "control lying about what it can do")
assert(not node.args.sense.disabled(), "while the sense applies to any selection")
SEL.p = child

print("smoke_dungeonrunoptions: OK - 3 lanes, the node lane authors sense · ordinal · "
      .. "note, floor derived from the coordinate space, Registry validated, Dialog built "
      .. "the frame")
FX.Report(FXSTATS, os.getenv("FXVERBOSE") == "1")
