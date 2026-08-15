-- Offline smoke for frames.lua - THE RESOLVER, ASSERTED AGAINST HAND ARITHMETIC.
--
-- ★★★ WHY THIS ONE IS DIFFERENT FROM EVERY OTHER SMOKE ON THE BENCH. Every other
-- smoke tests an addon against our model of the client. This tests THE MODEL ITSELF,
-- and it has to be the harshest file here for one reason: a resolver that is wrong
-- does not fail, it ANSWERS - with a plausible number that no screenshot will
-- contradict until the pane is already built on it.
--
-- ⚠ So every expected value below is computed BY HAND in the comment beside it. Not
-- one is copied from a run. A test whose expectation came out of the thing it tests
-- proves only that the code is deterministic.
--
-- The pane is 280x400 with its TOPLEFT at the origin, so: left 0, right 280,
-- top 0, bottom -400. ⚠ y increases UPWARD, which is the sign error this file
-- exists to make impossible.

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\tools\smoke\]]
local F = assert(loadfile(ROOT .. "frames.lua"))()

local function close(a, b, what)
    assert(a and b and math.abs(a - b) < 0.001,
           ("%s: expected %s, got %s"):format(what, tostring(b), tostring(a)))
end

local function newPane()
    F.Reset()
    local pane = F.New("pane")
    F.SetRoot(pane, 280, 400, 0, 0)
    return pane
end

-- =====================================================================
-- ★★ THE ROOT. One frame in any tree is TOLD where it is; everything else is
-- derived from it. Get this wrong and every rect is wrong by the same offset,
-- which is the hardest kind of error to see.
-- =====================================================================
local pane = newPane()
local r = F.Rect(pane)
close(r.left, 0, "root left")
close(r.right, 280, "root right")
close(r.top, 0, "root top")
close(r.bottom, -400, "root bottom - y DECREASES downward")

-- =====================================================================
-- ★★★ ONE ANCHOR PLUS A SIZE - the form `layout.lua` actually emits.
--
--   pane TOPLEFT = (0, 0);  offset (18, -100)  ->  anchor at (18, -100)
--   my point is TOPLEFT, so that anchor IS my top-left corner
--   left 18, right 18+100 = 118, top -100, bottom -100-20 = -120
-- =====================================================================
local a = F.New("a", pane)
a:SetPoint("TOPLEFT", 18, -100)
a:SetSize(100, 20)
r = F.Rect(a)
close(r.left, 18, "one-anchor left")
close(r.right, 118, "one-anchor right")
close(r.top, -100, "one-anchor top")
close(r.bottom, -120, "one-anchor bottom")

-- ★★ ALL THREE ARGUMENT FORMS MUST AGREE. `SetPoint` is positional and overloaded,
-- and a mis-parse here would silently anchor to the wrong point on the wrong frame.
-- ⚠ THIS IS THE ASSERTION MOST LIKELY TO CATCH A REAL DEFECT IN THE PARSE.
local forms = {}
for i, set in ipairs({
    function(f) f:SetPoint("TOPLEFT", 18, -100) end,
    function(f) f:SetPoint("TOPLEFT", pane, 18, -100) end,
    function(f) f:SetPoint("TOPLEFT", pane, "TOPLEFT", 18, -100) end,
}) do
    local f = F.New("form" .. i, pane)
    set(f); f:SetSize(100, 20)
    forms[i] = F.Rect(f)
end
for i = 2, 3 do
    close(forms[i].left, forms[1].left, "SetPoint form " .. i .. " left")
    close(forms[i].top, forms[1].top, "SetPoint form " .. i .. " top")
end

-- ★ CENTER, because every fraction other than 0 is only exercised here.
--   pane CENTER = (0 + 0.5*280, 0 - 0.5*400) = (140, -200)
--   my CENTER sits there, so left = 140 - 50 = 90, top = -200 + 10 = -190
local c = F.New("c", pane)
c:SetPoint("CENTER", pane, "CENTER", 0, 0)
c:SetSize(100, 20)
r = F.Rect(c)
close(r.left, 90, "CENTER left")
close(r.right, 190, "CENTER right")
close(r.top, -190, "CENTER top")
close(r.bottom, -210, "CENTER bottom")

-- =====================================================================
-- ★★ TWO OPPOSING ANCHORS DEFINE THE SIZE - Ascension's own `AddonPanelTemplate`
-- uses exactly this (TOPLEFT + BOTTOMRIGHT with no Size element).
--
--   TOPLEFT     -> (0,0)     + (10, -10)  = (10, -10)
--   BOTTOMRIGHT -> (280,-400)+ (-10, 10)  = (270, -390)
--   w = (270-10)/(1-0) = 260      h = (-10 - -390)/(1-0) = 380
-- =====================================================================
local box = F.New("box", pane)
box:SetPoint("TOPLEFT", pane, "TOPLEFT", 10, -10)
box:SetPoint("BOTTOMRIGHT", pane, "BOTTOMRIGHT", -10, 10)
r = F.Rect(box)
close(r.w, 260, "two-anchor derived width")
close(r.h, 380, "two-anchor derived height")
close(r.left, 10, "two-anchor left")
close(r.bottom, -390, "two-anchor bottom")

-- ⚠⚠ AND EACH AXIS IS DECIDED SEPARATELY. TOPLEFT + BOTTOMLEFT pins the HEIGHT and
-- says NOTHING about the width - both points share x-fraction 0. Assuming a pair is
-- always a full box would invent a width of zero here and every check downstream
-- would then quietly pass.
local tall = F.New("tall", pane)
tall:SetPoint("TOPLEFT", pane, "TOPLEFT", 0, -10)
tall:SetPoint("BOTTOMLEFT", pane, "BOTTOMLEFT", 0, 10)
r = F.Rect(tall)
close(r.h, 380, "same-axis pair still fixes the height")
assert(r.unknownW,
       "A PAIR OF ANCHORS ON ONE AXIS INVENTED A WIDTH: TOPLEFT+BOTTOMLEFT share "
       .. "x, so the width is genuinely unknown and must say so")

-- =====================================================================
-- ★★★ THE FONT BOUNDARY - THE HOLE WE REFUSE TO FILL.
--
-- A FontString sized by its text has no width offline. WoW UI Designer approximated
-- it and conceded the result was *"not exactly like WoWs"*. We have the client on
-- access, so the honest answer is UNKNOWN plus a name - and that name is what the
-- one measuring run in the client will consume.
-- =====================================================================
local fs = pane:CreateFontString("header")
fs:SetPoint("TOPLEFT", 18, -40)
fs:SetText("detect")
r = F.Rect(fs)
assert(r.unknownW and r.unknownH,
       "A TEXT-SIZED FONTSTRING WAS GIVEN A SIZE: nothing offline can know it, and "
       .. "inventing one is the exact failure the 2010 renderer shipped")
close(r.anchorX, 18, "but the ANCHOR is still known")
close(r.anchorY, -40, "and it is enough to order rows top to bottom")

-- =====================================================================
-- ★★★ AN EDGE CAN BE KNOWN WHILE THE SIZE IS NOT - AND THIS IS A LIVE DEFECT THE
-- MUTATION FOUND, not a hypothetical.
--
-- ⚠ The first cut did arithmetic on the unsized label's nil width and CRASHED. That
-- is not an exotic input: anchoring a control to a label is the ordinary WoW idiom,
-- and it is exactly what Ascension's own `AddonPanelTemplate` does - `Value`
-- anchored to `$parentHeader`'s BOTTOMLEFT.
--
-- ★ The label is anchored by its TOPLEFT at (18, -40), so its LEFT EDGE and its TOP
-- EDGE are known exactly - whatever the text measures. A control on that left edge
-- must resolve.
-- =====================================================================
local beside = F.New("beside", pane)
beside:SetPoint("TOPLEFT", fs, "TOPLEFT", 0, 0)
beside:SetSize(60, 20)
r = F.Rect(beside)
assert(r, "ANCHORING TO AN UNSIZED LABEL'S KNOWN EDGE FAILED: its left edge is a "
       .. "fact, and refusing here would make the resolver useless on the commonest "
       .. "layout in the client")
close(r.left, 18, "control on the label's left edge")
close(r.top, -40, "control on the label's top edge")

-- ⚠⚠ BUT ITS BOTTOM IS GENUINELY UNKNOWABLE - that needs the text height, which is
-- the one measurement only the client can give. It must REFUSE AND NAME ITSELF, not
-- guess: this is the shopping list for the calibration run writing itself.
local under = F.New("under", pane)
under:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", 0, -6)
under:SetSize(60, 20)
got, why = F.Rect(under)
assert(got == nil and why:find("no known y"),
       "A CONTROL UNDER AN UNMEASURED LABEL WAS GIVEN A POSITION: the label's height "
       .. "is exactly what no offline model can know")
assert(why:find("header"),
       "THE REFUSAL DID NOT NAME THE LABEL: the name is the whole value of the "
       .. "refusal, because it is what the client run has to measure")

-- =====================================================================
-- ★★ EVERY FAILURE RETURNS A REASON, NOT A ZERO. A rect of 0,0 is
-- indistinguishable from a frame legitimately at the origin.
-- =====================================================================
local lost = F.New("lost", pane)
local got, why = F.Rect(lost)
assert(got == nil and why:find("unanchored"),
       "AN UNANCHORED FRAME RESOLVED: it must say so, because 0,0 is a real position")

local n1, n2 = F.New("n1", pane), F.New("n2", pane)
n1:SetPoint("TOPLEFT", n2, "BOTTOMLEFT", 0, 0)
n2:SetPoint("TOPLEFT", n1, "BOTTOMLEFT", 0, 0)
got, why = F.Rect(n1)
assert(got == nil and why:find("cycle"),
       "AN ANCHOR CYCLE RECURSED OR ANSWERED: in the client this is a silent layout "
       .. "failure, so it must be named here")

local byName = F.New("byName", pane)
byName:SetPoint("TOPLEFT", "SomeGlobalFrame", "TOPLEFT", 0, 0)
got, why = F.Rect(byName)
assert(got == nil and why:find("NAME"),
       "A NAME-ANCHOR WAS SILENTLY TREATED AS THE PARENT: there is no global frame "
       .. "table offline and pretending otherwise fabricates a position")

-- =====================================================================
-- ★★★ THE TWO BUGS, AS ARITHMETIC.
-- =====================================================================

-- ★ FLUSH EDGES ARE NOT AN OVERLAP. Rows that stack touching are ordinary; flagging
-- them would make the check unusable on its first run and it would be turned off.
local flushA = { name = "flushA", shown = true, left = 0,  right = 100, top = 0, bottom = -20, w = 100, h = 20 }
local flushB = { name = "flushB", shown = true, left = 100, right = 200, top = 0, bottom = -20, w = 100, h = 20 }
assert(#F.Overlaps({ flushA, flushB }) == 0,
       "TOUCHING EDGES REPORTED AS AN OVERLAP: a check that cries wolf gets disabled")

-- ★★ A REAL OVERLAP, WITH ITS DEPTH. 90..190 against 0..100 shares x 90..100 = 10,
-- and both span y 0..-20, so 20 of vertical.
local overC = { name = "overC", shown = true, left = 90, right = 190, top = 0, bottom = -20, w = 100, h = 20 }
local hits = F.Overlaps({ flushA, overC })
assert(#hits == 1, "A REAL OVERLAP WENT UNREPORTED - this is the orphaned-label class")
close(hits[1].x, 10, "overlap width")
close(hits[1].y, 20, "overlap height")

-- ⚠ A HIDDEN FRAME CANNOT OVERLAP ANYTHING, and that is the design rather than an
-- oversight: it is why a zone hidden for this subject is silent, and why an orphan -
-- which nothing ever hides - is loud in every state it does not belong to.
local ghost = { name = "ghost", shown = false, left = 90, right = 190, top = 0, bottom = -20, w = 100, h = 20 }
assert(#F.Overlaps({ flushA, ghost }) == 0,
       "A HIDDEN FRAME WAS COLLIDED WITH: it is not on screen")

-- ⚠⚠ NEITHER IS THE CONTAINER, and this one bit for real. Marking the root so the
-- audit could keep it out of the row report made it eligible as a SIBLING, and every
-- child then "overlapped" the pane it lives inside - which would have made the check
-- unusable on its first real pane.
local container = { name = "pane", shown = true, root = true,
                    left = 0, right = 280, top = 0, bottom = -400, w = 280, h = 400 }
assert(#F.Overlaps({ container, flushA }) == 0,
       "A CHILD WAS REPORTED AS OVERLAPPING ITS OWN CONTAINER: a frame contains its "
       .. "children by definition, and that is what Outside measures")
assert(#F.Outside({ container }, { left = 0, right = 280, top = 0, bottom = -400 }) == 0,
       "THE CONTAINER WAS MEASURED AGAINST ITSELF")

-- ★★★ THE CLIPPED BUTTON - AND THE MEASUREMENT THAT KILLS MY OWN CLAIM.
--
-- ⚠⚠ I asserted twice that the play button clipped because x=208 plus a 52-wide
-- button ran off a 280-wide frame. 208 + 52 = 260, which is 20 INSIDE the edge.
-- This asserts the arithmetic in both directions so the wrong story cannot come
-- back: the real numbers must NOT flag, and a genuine overhang must.
local frame = { left = 0, right = 280, top = 0, bottom = -400 }
local play = { name = "promoter.play", shown = true, left = 208, right = 260, top = -20, bottom = -42, w = 52, h = 22 }
assert(#F.Outside({ play }, frame) == 0,
       "THE PLAY BUTTON'S OWN NUMBERS FLAGGED AS CLIPPED: 208+52=260 on a 280 frame "
       .. "is inside, and the cause of the visible clipping is STILL UNPROVEN")

local hangs = { name = "hangs", shown = true, left = 250, right = 302, top = -20, bottom = -42, w = 52, h = 22 }
local bad = F.Outside({ hangs }, frame)
assert(#bad == 1 and bad[1].over:find("right by 22"),
       "A GENUINE OVERHANG WENT UNREPORTED, or reported the wrong amount")

-- =====================================================================
-- ★ THE MODEL KNOWS WHAT IT DOES NOT MODEL. The `__index` no-op made three §77
-- assertions unfailable by answering every unknown call; it stays, but it now
-- records the name so the hole is loud rather than silent.
-- =====================================================================
local probe = F.New("probe", pane)
probe:SetAlpha(0.5)
local un = F.Unmodelled()
local sawIt = false
for _, k in ipairs(un) do if k == "SetAlpha" then sawIt = true end end
assert(sawIt,
       "AN UNMODELLED CALL WAS SWALLOWED SILENTLY: that trap is exactly what made "
       .. "three §77 assertions unfailable")

print("smoke_frames: OK")
