-- COA_DungeonRun adaptor.lua - ONE lookup, `code → user` (A5.1 · A5.2).
--
-- Model: addons/planning/DRIVER_BASIS.md   READ FIRST. It names what governs NOW, in
--        precedence order, and it MOVES when a ruling moves - so this line never
--        goes stale. Lower number wins; a disagreement is reported, not resolved here.
--
-- ---------------------------------------------------------------------------
-- ★★★ ONE LOOKUP, AND IT LANDS BEFORE THE FIRST FOLD (A10.2 PRECONDITION).
--
-- RI-16 (Battlewrath, 2026-08-18): *"the RUNTIME LOOKUP lands BEFORE the first fold - one
-- lookup function over one CONSTANT table on the UI side, pass-through on a miss;
-- ROLE_TEXT + SENSE_TEXT retire into it."*
--
-- ⚠ The alternative was folding first and typing each label into `options.lua` - typing
-- the very strings the adaptor exists to own. Two copies of a word are two answers to
-- "what does the author call this", and nothing notices when they stop agreeing. That is
-- the same shape as the map's two sizes (`map.lua:46`) and the pane's two canvases
-- (A9.6): a duplicate that renders correctly right up until it does not.
--
-- ---------------------------------------------------------------------------
-- ★★ PASS-THROUGH IS THE LAW, NOT A FALLBACK (A5.1).
--
-- Battlewrath, 2026-08-18: pass-through is NOT a silent failure - the term is SHOWN under
-- its code name when the adaptor has not resolved it (a version mismatch, say), *"so what
-- the instruction was calling for is still EXPRESSED to the author."*
--
--     the AUTHOR   sees a legible code word - degraded, never absent, never an error
--     the BENCH    sees it counted by `check_interface`'s adaptor check (A5.3)
--
-- ★ Two audiences, two behaviours, one event (§295). A lookup that errored on a miss
-- would move a bench problem onto the author's screen.
--
-- ---------------------------------------------------------------------------
-- ⚠⚠ THIS TABLE IS A COPY, AND THE COPY IS TEMPORARY BY RULING.
--
-- `driver_adaptor_table.md` is the authority. RI-16 (c): generating this constant from it
-- is *"a tooling item that FOLLOWS - the fold does not wait on it; until then A5.3's 1:1
-- check is the drift guard."* ★ So what stops this file going stale is not care, it is
-- `check_interface.py`. That is the only reason a hand-kept copy is acceptable at all.

local ADDON, NS = ...

local Adaptor = {}
NS.Adaptor = Adaptor

-- ---------------------------------------------------------------------
-- THE TABLE - `code → user`, flat, one namespace
-- ---------------------------------------------------------------------
--
-- ⚠ FLAT, NOT NESTED BY FIELD. `role → complete` and `outcome → stage` read as two-level
-- in the document because that is how a reader GROUPS them; the values are distinct
-- across the whole vocabulary, so a second level would be structure with no fact under
-- it. If two fields ever want one code word to mean different things, THAT is the day
-- this grows a level - a real disagreement rather than a shape chosen in advance.
local WORD = {
    -- the question layer
    sense       = "detect",
    reachHere   = "reach here",
    ordinal     = "order",
    routeNote   = "Route instructions",

    -- geometry
    radius      = "radius",
    bandUp      = "up",

    -- ⚠ THE SHIPPED CODE SHAPE, NOT THE AUTHOR'S MODEL. A10.2a: `role / action / outcome`
    -- are what the OLD pane shows, and A10.3 REPLACES them rather than folding them. They
    -- are here because the old pane is LIVE until then (A10.2d) and must keep speaking
    -- the author's words while it is - not because they survive.
    complete    = "stage complete",
    set         = "set stage",
    start       = "start of stage",
    update      = "updater",          -- ⚠ close to technical; flagged for the naming pass
    supertrack  = "point the tracker",
    advance     = "advance (+1)",
    -- ★★★ THE PROPER WORD, AND IT IS THE SAME WORD IN BOTH PLACES (Battlewrath, 2026-08-27):
    -- *"abstracting a different term would be ritual, when stage / step and set to = Stage,
    -- step is the proper language to discuss the system in human relatable terms."*
    --
    -- ⚠⚠ THE BENCH HAD THIS DOWN AS AN OPEN QUESTION AND IT WAS ALREADY ANSWERED. §711
    -- banked his identity-vs-instruction character note as *evidence the adaptor must grow a
    -- level* - two fields wanting one code word. ⟶ It is the opposite: a node IS at stage 3
    -- and a Next GOES TO stage 5, and both sentences use the word STAGE because that is what
    -- the thing is called. One word, one meaning, no second level.
    --
    -- ★ So this was "go to stage" and is now the noun. Under a control labelled `next` the
    -- entry reads *next: stage*; as the STAGE picker's own label it reads *stage*. The
    -- direction lives in the control, not in the word.
    --
    -- ✗ THE OLD PANE IS UNAFFECTED, and not by luck: `object.lua:368`, `:716` and `:975`
    -- TYPE these strings as literals rather than asking the adaptor. (That is its own
    -- two-copies fault, and A10.3 retires those controls whole - not repaired here.)
    stage       = "stage",

    -- ★★★ `Next`'s THIRD TYPE, AND THE ONLY ONE THAT HAD NO WORD (§710).
    --
    -- Battlewrath, 2026-08-27, asked whether Next needed its own vocabulary: *"they can
    -- match here. A different term would be ritual. The Step and Stage is consistent through
    -- the system to mean the same thing without code terms flattening intuition."*
    --
    -- ⟶ SO NO NEW WORDS WERE MINTED. `stage` and `set` above already read correctly as Next
    -- values - *go to stage*, *set stage* - because they mean in Next exactly what they mean
    -- everywhere else. Only `step` was absent, and it takes the same voice as its sibling.
    --
    -- ★★ AND THE FLAT TABLE DOES NOT GROW A LEVEL. Its own rule at the head of this file:
    -- *"if two fields ever want one code word to mean different things, THAT is the day this
    -- grows a level - a real disagreement rather than a shape chosen in advance."* His ruling
    -- is that there is no such disagreement, so there is no level to add.
    --
    -- ⚠ IT IS OWED **WITH** THE CODE TERM (A13.5): `Routes.NEXT_TYPES` has carried `step`
    -- since §480 and A5.1 PASSES A MISS THROUGH - so until this line, a Next picker would
    -- have put the raw word `step` on the author's screen.
    -- ★ THE NOUN, for the reason above: a child IS at step 2 and a Next GOES TO the next
    -- step. Same word, and the control says which sentence it is in.
    step        = "step",

    -- ★ AND THE TWO CONTROLS' OWN LABELS, owed by the same rule. `next` stays `next` for
    -- his reason exactly - §4d and A2.9 both call it NEXT, and renaming it for the pane
    -- alone would be the ritual he ruled against.
    next        = "next",
    nextArg     = "stage number",

    -- ★ THE NODE-LEVEL LATCH'S LABEL. Its VALUES have had words since §486 (`once`/`every`
    -- below); the CONTROL had none, which is the same half-owed shape `next` was in.
    trigger     = "repeats",

    -- ★ THE WAYPOINT TICK (AL-19). Battlewrath, 2026-08-27: *"if we point to it or not ...
    -- that's how a user knows where to go to complete the activity there."*
    -- ⚠ NOT "supertrack" - that was the ACTION word AL-19 RETIRED, and reusing it would put
    -- the retired verb back on the author's screen doing a different job.
    ledTo       = "point the way here",

    -- ★★★ THE LATCH'S TWO WORDS (AL-22/AL-23). The DISPLAY words were already ruled -
    -- `contract.lua` carries them - and only the stored id was the bench's; these are it.
    --
    -- ⚠⚠ OWED **WITH** THE CODE TERM, NOT AFTER IT (A13.5, measured on the sense words):
    -- the adaptor carried no word for `whenOn`/`seen`/`whenOff` either, and A5.1 PASSES A
    -- MISS THROUGH - so **whatever the code term is, it is what the author reads.**
    -- ★ §486 shipped `once`/`every` without these two lines, which would have put a
    -- programmer's word on the author's screen. Same fault as §457's, one layer out.
    once        = "One time",
    every       = "Every time",

    -- ⚠ DELIBERATELY ABSENT, each for a ruling rather than an oversight:
    --   bossEngaged  STRUCK (RI-15). An *engaged* witness is a step in HOW, and the author
    --                states OUTCOMES - so it is not authorable and needs no word.
    --   bossKilled   gone as a value: the ACTION WORD is `boss`, one function carrying its
    --                own condition and completion (RI-17). Its wording lands with A10.3's
    --                row model; inventing one now would pre-empt the profile pass.
    --   wire         OPEN in the table - must name a SHAPE, and §3b fails `trip`.
    --   ratchet      OWED (A9.3): reaches a pane with no user word.
}

-- ---------------------------------------------------------------------
-- THE LOOKUP - the only one
-- ---------------------------------------------------------------------

-- ★ A5.1. The user's word, or the code term unchanged.
-- ⚠ A non-string passes through AS ITSELF rather than being coerced: `tostring(nil)`
-- would print "nil" on a pane as though it were a word, which is a caller bug wearing a
-- label.
function Adaptor.Word(code)
    if type(code) ~= "string" or code == "" then return code end
    return WORD[code] or code
end

-- ★ Did the vocabulary actually carry it? The pane never needs this - it is for the SMOKE
-- and the bench, so "passed through" and "resolved to the same string" can be told apart.
-- A word that happens to equal its code is not a miss.
function Adaptor.Has(code)
    return type(code) == "string" and WORD[code] ~= nil
end

-- Every code term the vocabulary carries, sorted.
function Adaptor.Codes()
    local out = {}
    for k in pairs(WORD) do out[#out + 1] = k end
    table.sort(out)
    return out
end
