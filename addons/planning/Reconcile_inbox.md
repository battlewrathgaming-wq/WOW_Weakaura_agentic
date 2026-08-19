# Reconcile_inbox — the relay for questions that need a ruling

★★★ **THE FILE HAS THREE PARTS SINCE 2026-08-19, and only the first directs anything.**

    # OPEN            items still waiting on a ruling. THESE are the live ones.
    # THE SETTLED SET  every drained item flattened to five lines - question · outcome ·
                      NOT statement · IS statement · cite. An INDEX, not an authority.
    history/Reconciliation_inbox_drained.md
                      the full prose of everything drained. ⚠ Read for WHY, never for WHAT.

_Battlewrath, 2026-08-19: **"Too many competing thoughts / statements degrade the utility of the
planning files. It's where we settle what is true."** ★ **The NOT statement is why the footer
exists** — an outcome recorded only as what was chosen leaves the rejected shape free to drift
back; naming it once is what stops that. Nothing was deleted: the split was verified line-by-line._

_Standing channel, opened 2026-08-18 (§325) at Battlewrath's ask. **The bench files items here;
the designer DRAINS them** — rules, reconciles the records against the outcome, and tests the
change against its impact. Kept short on purpose: an inbox that grows is one nobody empties._

## How it works

    THE BENCH FILES     a question it cannot settle alone, with everything needed to settle it -
                        options, costs, what is already built on an assumption, and the bench's
                        own read MARKED AS THE BENCH'S so it can be overturned in one word.
    ★ A TIE BREAK      is a DIFFERENT SHAPE (Battlewrath, §342): "tie break with instruction
                        instead of deliberation." When two governing docs disagree the rule has
                        ALREADY decided which wins - weighing them again is the builder doing
                        the thing the rule forbids. So it states the tie and lists INSTRUCTION
                        LINES to pick from. No bench read.
    THE DESIGNER DRAINS rules it · reconciles every record the ruling touches · checks the
                        IMPACT list below the item and says which parts actually moved.
    THE ITEM LEAVES     to §DRAINED at the foot with a one-line outcome and where it landed.
                        Removed entirely once the records carry it.

⚠ **An item is not a discussion.** If it needs a conversation it belongs in chat first and arrives
here as a question with options. **A row with no options is not ready to be drained.**

★ **Every item carries an IMPACT block**, because *"test against impact"* is the drain's second
half: a ruling that changes nothing on disk and a ruling that invalidates a shipped guard are
different events and should not look the same in an inbox.

⚠ **This file is a CHANNEL, not a governing document.** It directs nothing; it holds questions
until they are answered. `DRIVER_BASIS.md` is the authority and should carry a pointer to this so
nobody mistakes an open question here for a ruling.

---

# OPEN

_**Status lives on the ITEM, never in a header** (bench finding 2026-08-19: two conventions were
live — RI-1..8 inherited "drained" from the section, RI-9.. carried their own stamp — so a hand
header compensated and went stale within a day, on RI-18). **The one convention: an item is DRAINED
when its text begins `RI-N DRAINED (who, date)`; an item without that stamp is OPEN.** Derive,
don't read a list: `grep -n "RI-[0-9]* DRAINED" Reconcile_inbox.md` gives the drained; every other
`## RI-` heading is open; the next number is the highest present + 1. Sections are PLACEMENT only
(open items sit here, drained items move below) — the stamp is the truth if they ever disagree._

---

## RI-19 · THE GOLDEN WATCH — `walk.py check` cannot reach W1 or W5

**RI-19 WITHDRAWN — IT WAS NEVER TRUE (Opus 5 Analyst, 2026-08-19).** ⚠⚠ The defect this item
reported had already been fixed at **`5725b7d` §376 — *"RI-19 (a) - `walk.py check` now covers
every body, one exit code"*** — a commit that was an ancestor of HEAD before this session
started. `walk.py check` prints `BODIES: W1 PASS · W5 PASS` and returns one exit code for all
five bodies.

⚠ **How it was got wrong, stated exactly, because the mechanism matters more than the item.**
`main()` begins at `walk.py:1754` and builds its aggregate at **`:1777-1783`** — inside the very
range I read (`1752-1872`) and reported on. I also ran the tool and piped it through `tail -6`,
which cut off the `BODIES` line that would have contradicted me. ★ **I inherited the claim from
the sense proposition's stale A9.5 note, then read the source looking for the mechanism of a
defect I already believed in.** Confirmation, described as measurement.

★ **What survives:** A11.7a's REWORDING is still the right criterion — one command over every
body, one exit code, hooked to landing — and it is now SATISFIED rather than red. The row is
updated. ⚠ The coverage sub-agent inherited this false claim as its O8; that report is history
and is not corrected in place.


_Filed 2026-08-19 by **Opus 5 — Design/acceptance setter**. ⚠ This item is mostly MEASURED FACT.
The acceptance rewording under it is mine and TAKEN, not asked; one build-shape choice is the
bench's and carries options. A9.5 named this blocker; what follows is its exact shape._

### What was measured (2026-08-19, read-only, on the tree as it stands)

    py addons/tools/walk.py check     PASS - every W2/W3/W4 golden reproduced
    py addons/tools/walk.py w1        PASS - all ten criteria
    py addons/tools/walk.py w5        W5.4 PASS · W5.6 all three goldens SAME

★ **The goldens have NOT drifted.** `w5_SFK_live` · `w5_SFK_Run4` · `w5_rfc_combat` all read SAME.
The reference the Lua port will be graded against is intact today. This item is not about their
contents.

### The finding — one notch wider than "the goldens are unwatched"

`main()` (`addons/tools/walk.py:1752`) gates by MODE. `w32`, `w5` and `w1` each return early;
`check` then falls through to `w2` / `w3` / `w4` and nothing else. So:

1. **The three w5 goldens are unwatched BY CONSTRUCTION**, not by neglect. `w5_6` already does the
   right thing — absent → WRITE and say so, present → COMPARE, `--regold` the only way to move one,
   named so it appears in the shell history of whoever moved it. It is a working watch that the
   only routine command cannot reach. ⚠ The docstring is honest (`check` = "all three", meaning
   W2/W3/W4); the gap is between the acceptance rows and the aggregate, not inside the tool.

2. ★★ **AND W1 IS OUTSIDE THE AGGREGATE TOO — this half has not been named anywhere.** W1 is the
   RULE's own ten structural criteria, and `driver_sense_acceptance.md` A11.2 grades the port
   against exactly those: **W1.3** the mapID straddle · **W1.7** the walkway band at the
   interpolated z · **W1.9** the clamp · **W1.10** the gap bound. A11.2's own mutations are written
   as "→ W1.3 fails", "→ W1.7's walkway fixture fires where it must not". So the port's fidelity
   rows point at criteria the routine check does not exercise.

⚠ **The failure mode is the one this project keeps finding:** a green that means less than it
looks like. `walk.py check` PASS reads as "the desk is sound" and covers three of five bodies of
criteria. Same class as §322's dead registrations and A4.2's tests that pass in either world.

### The one thing that is the bench's to choose

Where "watched" is made operational. All three are cheap; none is a new instrument.

    a  `check` ABSORBS w1 and w5 - one command, one exit code, non-zero if any body fails
       ⚠ changes what `check` has meant since it was written; its docstring line moves too
    b  a NEW `all` mode; `check` keeps its current W2/W3/W4 meaning
       ⚠ two aggregate words, and the wrong one is the one already in every doc and runsheet
    c  modes untouched; the LANDING HOOK runs all three commands
       ⚠ the contract lives in the hook, not the tool - invisible to anyone running by hand

**Opus 5's read (marked as mine, overturnable in a word): (a).** The reason is not tidiness — it is
that the failure being guarded against is *someone runs the documented command and believes it*.
(b) leaves the believed word covering three fifths; (c) leaves it covering three fifths for every
hand-run. ★ And the tell that (a) is right: A11.7a's own mutation — perturb a w5 golden by one byte
→ the check reds — **passes at the `w5_6` layer and fails at the aggregate layer today.** Under (a)
the mutation and the command finally describe the same event.

    IMPACT
      on disk now      addons/tools/walk.py main() mode gate + its module docstring line 22
                       ("check  all three against the stated goldens") - the word "three" moves
      shipped guards   NONE break. All five bodies pass RIGHT NOW (measured above), so this is a
                       coverage change with no expected red - ⚠ which is exactly why it is easy
                       to defer and exactly why it will not announce itself later
      criteria         A11.7a REWORDED (below) · A11.2's mutation rows gain a runner that
                       actually executes them
      does nothing to  the goldens' contents · W7.1 byte-equality · the row shape (A11.1) ·
                       the isolated load (A11.6a) · anything in the UI leg

### The rewording I am taking as acceptance setter (not a ruling request)

**A11.7a**, from *"the three `w5_*.golden.txt` files are WATCHED — `walk.py check` (or a sibling)
runs them on every landing"* to:

> **A11.7a** ONE COMMAND runs every body of desk criteria — W1 (the rule's structure), W2/W3/W4
> (the calibration goldens) and W5 (including W5.6's three golden comparisons) — and returns
> non-zero if any of them moves. That command is hooked to landing. **Test:** perturb a w5 golden
> by one byte → the aggregate reds; run the aggregate with W1 deliberately broken → it reds.
> ⚠ The row is RED while any body sits outside the aggregate, whatever the bodies individually
> report. Measured 2026-08-19: all five pass individually; two are unreachable from `check`.

Rationale for the change of wording: the old row could be read as satisfied by *"someone runs
`walk.py w5` before a landing"*, and a golden watched by remembering to watch it is the thing the
row exists to forbid. ★ It also promotes P1 from a chore to a shaped task — the bench's own
accepted build order already puts it first, and it is now specified rather than asserted.

**Needs one word:** the (a)/(b)/(c) choice above — and it is the BENCH's word, not Battlewrath's,
unless the bench would rather it were ruled.

**Analyst (Fable) read, 2026-08-19:** measurements REPRODUCED by running (`check` PASS · `w1` PASS
all ten · `w5` W5.4 PASS, W5.6 all three SAME). The finding is right and one notch sharper than
A9.5 named it — W1 outside the aggregate is the half that A11.2's own mutations depend on. The
rewording is APPLIED to A11.7a (it was written here, not in the row — applied now, marked as the
stand-in's wording reviewed by the Analyst). (a) agreed: the command people believe must cover what
the rows cite; (b) splits the believed word, (c) hides the contract in a hook. The bench's word;
nothing waits on Battlewrath. ⚠ For the stand-in: print the role line (`Analyst.`) as the first
line of every response — Battlewrath's standing instruction for this seat — and when taking a
row's wording, LAND it in the row in the same turn, not only in the inbox; the inbox is a channel,
the row is the record.

---


---

## RI-22 · BAND becomes OPTION BANDS — and the reach door has no guard

_Filed 2026-08-19 (§383) by the **Addons bench** at Battlewrath's ask: **"I'll bring in reconcile,
but follow form. Option bands, but most likely won't be used. Just correction for when their
application needs some head room on detection."** Follows the P1/P2 landing in RI-20._

### ⚠ FIRST, A CORRECTION TO THE PREMISE — Band IS expressed in code

Battlewrath, same turn: *"Band has had no code expression yet for the addon. We hand wrote it in
our py golden tests."* ⚠ **Measured, and that is not the state on disk.** Band has a shipped
authoring path:

    object.lua:478-479   upBox / downBox - FREE-ENTRY EditBoxes, with HasFocus guards
    routes.lua:1210      setReach(p, radius, up, down)
    routes.lua:1269      Routes.ReachOf - the A1.1 pure accessor, returns all three
    adaptor.lua:64-65    bandUp -> "up" · bandDown -> "down"

★ **It is true that the RULE was written in `walk.py` first** (60 references) and that the golden
fixtures are hand-written — but the addon has both a store and an editor for it. **So this item is
a CHANGE TO SHIPPED UI, not a greenfield decision**, and the same applies to the pre-config radius
landed in §381c: `radBox` is the identical shape.

### ★★★ AND THE LOOK FOUND SOMETHING WORTH MORE THAN THE BAND ANSWER

`setReach` is `p.radius = tonumber(radius) or p.radius`, three times. Measured on our own
Lua 5.1.5 (`.tools/lua51`), 2026-08-19:

    tonumber("abc")    -> nil        the `or` keeps the OLD value. No feedback, no red.
    tonumber("")       -> nil        same
    tonumber("-5")     -> -5         a NEGATIVE radius, stored
    tonumber("1e400")  -> 1.#INF     ★★ and it PASSES the `or` guard - Inf is truthy

**⚠⚠ SO INFINITY ENTERS THE STORE TODAY, FROM A TYPO, THROUGH THE SHIPPED EDITOR.**
`driver_sense_acceptance.md` A11.2e says the DRIVER rejects NaN and Inf — and there is a producer
upstream manufacturing Inf, which nothing between them would notice.

★ **That makes RI-20 P2a and P3 LIVE INSTANCES rather than format questions**, and it changes what
they are asking. Not *"what should the format do with a non-finite"* but *"the editor has no door
guard, and the driver's rejection is the only thing standing there."* ⚠ A guard at the far end of
a pipe is not the same as a guard at its mouth: the value is already stored, already exported,
already shared before the driver ever sees it.

⚠ **The bench is NOT fixing this in this item.** It is recorded because it lives in the exact
function the Band change touches, and whoever takes that change should know the guard is missing
BEFORE they move the field rather than after.

### The change itself

Band moves from FREE ENTRY to an OPTION SET — the config class from §382, joining senses, actions
and the radius menu. Battlewrath's framing: *"most likely won't be used. Just correction for when
their application needs some head room on detection."*

★ **Which is a design fact worth carrying, not just a note:** Band is an EXCEPTION KNOB, not a
routine authoring field. The common case is "none". That argues for a default that costs nothing
to express and for the option list to be short and coarse rather than fine.

    a  ONE option list, symmetric - the author picks a band and it applies up and down
       ★ simplest; ⚠ loses the up/down asymmetry the store and the rule both already have
    b  TWO indices, up and down, from the SAME option list
       ★ keeps the existing shape exactly; costs one more slot on the line
    c  ONE index into a list of PAIRS (none · small · tall-up-only · ...)
       ★ one slot, and asymmetry survives as authored combinations
       ⚠ the list is a taste artifact - somebody has to choose the useful pairs

**Bench read (marked as the bench's, overturnable in a word): (b).** ⚠ Not because it is best in
the abstract — (c) is tempting and cheaper on the line — but because **`walk.py` and `ReachOf` and
the store and the editor all already carry up and down as independent values**, and (b) is the only
option that changes nothing but the input widget. (c) asks somebody to invent a pair list for a
field Battlewrath expects to be mostly unused, which is invention in a place the basis says not to
invent. ★ If the line's width ever matters, (c) remains available as a later projection — the
export can compose a pair index from two stored values, which is the same composing law as
`Stage:Step`.

    IMPACT
      on disk now      object.lua:478-479 (two EditBoxes -> a picker) · routes.lua:1210
                       setReach (accepts an index, or is fed one) · adaptor.lua:64-65 gains
                       the option words · the new option table itself, wherever config lives
      shipped guards   ⚠ A1.1's ReachOf is a PURE ACCESSOR and stays pure - it returns what
                       is stored and does not care where it came from. The smoke rows that
                       assert reach values keep passing IF the stored form stays numeric;
                       if the store holds an INDEX instead, every one of them moves.
                       ★ THAT IS THE REAL QUESTION UNDER (a)/(b)/(c) AND IT IS NOT ASKED
                       ABOVE: does the STORE hold the index, or the resolved number?
      criteria         A11.2's fidelity rows gain a bounded domain for band (a small win) ·
                       nothing in W1 moves - the RULE is unchanged, only the authoring
      does nothing to  the sense rule · the row grammar · the note tables · the UI leg's
                       Ace3 work · the reader/data split

### ⚠ THE QUESTION THE OPTIONS ABOVE DO NOT COVER

**Does the STORE hold the index, or the resolved number?** §382 settled what goes on the WIRE
(config-class values need not ship). It did not settle the store. Both work:

    STORE THE NUMBER   ReachOf and every smoke row are untouched; the picker resolves on the
                       way in. ⚠ And a config change later does NOT retro-apply to old routes.
    STORE THE INDEX    a config change moves every route that used it. ⚠ And ReachOf either
                       stops being pure or starts returning indices, which A1.1 forbids in
                       spirit if not in letter.

★ **The bench leans STORE THE NUMBER**, because A1.1's pure accessor is a shipped, tested
property and the other option trades it away for a retro-apply nobody has asked for. ⚠ Marked as a
lean, not a read — it is genuinely a design call about whether a config edit should reach backwards
into authored routes, and that is a taste question about authoring, not a structural one.

---


---

## RI-24 · THE STORE INVENTORY — two fields with no consumer, and one disposition owed

_Filed 2026-08-19 by **Opus 5 — Analyst**, at Battlewrath's ask: **"We need a heading fixed-ish on
our data model before we over build selections. We need an inventory of what is stored and how. And
then flatten that into a going forward fact. I'd rather re-write now and sort our debt, than
tangle."**_

**THE TWO ARTEFACTS:**

    addons/tools/emit_store_inventory.py       the machine
    addons/planning/audit/store_inventory.md   EMITTED evidence - never hand-edit, re-run it
    addons/planning/driver_stored_state.md     ★ THE GOING-FORWARD FACT: the root, the records,
                                               the six laws the store already obeys, the debt

### ⚠⚠ THE FINDING THAT JUSTIFIES EMITTING RATHER THAN WRITING

`store.lua`'s own header carries a `Shape:` block describing the saved-variables table. It
documents `runs`, `markers` and `legs` — and **does not mention `routes`, `routeNotes`, `notes` or
`ui`, all four of which the same file creates.** ★ The one authoritative description of the store
had stopped being one, silently. A hand-written inventory would have been the same thing again.

### ★ THE APPARATUS CORRECTED ITSELF THREE TIMES, and each correction is a fact about the store

    1  the extractor missed indexed writes, indented constructor pairs and single-line
       constructors      -> caught by --check BEFORE any list was emitted
    2  scanning only COA_DungeonRun/ called `bosses` and `names` dead - the SMOKES assert on
       both (smoke_dungeonrun:366-368).  ⚠ A debt list that cannot see the test suite marks
       tested fields as dead, which is the one way this tool could do real damage
    3  scanning only Lua called `testPinSet` dead - `walk.py` reads it off a landed run.
       ★ THE SAVED FILE IS A CONTRACT BETWEEN TWO LANGUAGES and the inventory has to see
       both ends of it

⟶ debt list 35 → 15 → 11, every cut from a measured hole rather than from judgement.

### The two that are real

**D-1 · `fireOn` — RETIRED BY RULING, STILL SHIPPED.** `Routes.SetChildFireOn` (`routes.lua:1351`)
stores `child.fireOn` as `start | update | complete`, and **has no caller anywhere** — no pane, no
smoke, no interface row. RI-5: *"There is NO firing field — G15 IS the during/when-off pairing."*
**Analyst read:** RETIRE whole, the way A2.6 retired `goTo` and `onRamp` — with `DropRetired`
telling and dropping a stored value on load. ⚠ It survived that clean-out once already, which is
the argument for removing rather than parking. **Bench work; no ruling needed unless you disagree.**

**D-2 · `author` and `madeAt` — stored on every route, read by nobody. NEEDS ONE WORD.**
Minted at `routes.lua:121-122` as `UnitName("player")` and `time()`.

    a  KEEP - they are the route-level provenance RI-4's export ruling turns on
       ("the import landing becomes the new origin"; "the origin on someone else's data
       does not travel"). ⟶ they gain a named consumer and a criterion when export lands.
    b  DROP - speculative fields with no consumer and no named future, minted on every
       route since the day routes existed.

**Analyst read (marked as mine): (a)** — the export ruling already needs the material, and a field
about to acquire a consumer is a different thing from a dead one. ⚠ But that is a guess about what
export will want, and the guess is exactly what this pass was run to stop; **it is your word.**

    IMPACT
      on disk now      routes.lua:1351 SetChildFireOn (D-1, a removal) · routes.lua:121-122
                       (D-2, two mint fields) · nothing else moves either way
      shipped guards   NONE break. ⚠ `fireOn` has no test, which is why it survived - a
                       removal wants a DropRetired-style mutation the way A2.6's did
      criteria         a new row if (a): what provenance survives an import, testable at
                       the same time as A8.5's export-travel half
      does nothing to  the line · the sense rule · W1-W7 · the pickers · the UI leg


## RI-26 · G5 — THE REPRESENTATION, and it now blocks a queued build step

_Filed 2026-08-19 by **Opus 5 — Analyst**, after a sub-agent coverage audit found that the model's
own **"★ THE NEXT THING TO DECIDE"** (`driver_data_model.md` §B, G5) had **no item in this channel**
— so the decision the heading says comes next had no route to the person who makes it. ★ That is
the finding, not the question; the question below has been open since `audit/data_model_findings.md`
O1._

**WHY IT IS URGENT NOW, measured.** The sense brief's build order **P2** is *"the row SHAPE as a
declared contract + fixture list"* (`driver_sense_acceptance.md`) — **P2 builds the artefact G5
decides the shape of.** P3 and P4's fixtures are then built on P2's output. A wrong start here does
not stay local.

### The question

**How is a record represented on the wire, and do behaviours NEST inside the node's record or sit
as SIBLING records?** These are one question because the answer to the first constrains the second.

    a  POSITIONAL TEXT, siblings.  One line per record, fields by position, delimiter-separated;
       behaviours are their own lines sharing the node's address.
       ★ GatherMate ships exactly this (`string.format("%d:%s:%s:%d", ...)`) - the only shape
         with a peer precedent in a live addon
       ★ "an empty slot means absent" is expressible, which the model already relies on
       ⚠ CANNOT skip a variable-width unknown - so it must carry a version if it ever grows
         (RI-20 P1, and D10's MAVLink correction: only a FIXED-width payload is skippable)

    b  KEYED / STRUCTURED.  Field names present; behaviours may nest as a list on the node.
       ★ field ORDER stops costing anything, and G6/Q5's ingest order assertion becomes belt
         over braces rather than the only guard
       ★ nesting is natural, so 1 read per node rather than 1 + N
       ⚠ heavier on the wire, and the wire is a string a person pastes into chat
       ⚠ ⚠ it makes the format SELF-DESCRIBING, which is the property that would let a stale
         reader silently accept a record it does not fully understand

    c  POSITIONAL, NESTED.  One line per node carrying its behaviours inline as a repeating group.
       ★ fewest records, and the node/tab relationship is visible in one line
       ⚠ a variable-length repeating group is EXACTLY the variable-width unknown (a) cannot
         skip - it takes (a)'s cost without (a)'s simplicity

**Analyst read (marked as mine, overturnable in a word): (a).** ⚠ Not because it is elegant — (b)
is more forgiving to write and to read. Because **(a) is the only one with a shipped peer
precedent**, because *empty means absent* is already load-bearing in the model (`§A3.10`, stage 0),
and because the read-count argument for (b) was measured away: reads are an INGEST cost paid once,
and the 1 Hz pass walks buckets, never records (`A11.1a`, `#3 §A5.19`). ⚠ **The honest cost of (a):
it is the option that will need a version token first**, and A17 currently says we need none — that
is true today because there is no installed base, and (a) is the choice most likely to change it.

    IMPACT
      on disk now      NONE - there is no exporter and no importer. ★ This is the last moment
                       it is free; P2 is the step that stops it being free.
      blocks           sense P2 (the contract file) -> P3, P4's fixtures. Nothing else.
      criteria         A11.1a's contract row · A11.1c (the no-free-text smoke, which is
                       written against a token stream and would need re-aiming under (b))
      does nothing to  the store (already node-major) · the sense rule · W1-W7 · the UI leg ·
                       the two side tables · the driver's read order

## RI-27 · TRIGGER — a node field, not built, and its default

_Filed 2026-08-19 by **Opus 5 — Analyst**. ⚠ **This item replaces four rewrites of itself and a
spawned RI-28, all of which reconciled an error of mine rather than a question of the project's.**
What that error was is at the foot, in four lines, because it is the only part of the churn worth
keeping._

### WHAT THE RECORD ALREADY SAYS

    the CONTROL   RI-5, 2026-08-18. The pane is exactly three - sense · what I do · IF SEEN
                  (once | every) as its own control. Time lives in the DURING | WHEN OFF
                  pairing, not here; G15 (`while`) IS that pairing.
    the WORD      driver_adaptor_table.md:147, 2026-08-18: "resolves the SEEN / IF SEEN
                  collision: Seen is the sense-word (touched me); the re-arm control is
                  labelled Trigger. Meaning unchanged (RI-5)." A naming fix, nothing more.
    ★★ NOT BUILT  the same row, verbatim: "the once | every control - NOT BUILT; code term the
                  bench's the day it lands (no identifier invented here)."

### HIS POSITION (2026-08-19, best working model)

**Trigger is on the NODE, not the action tabs.** *"That's still on the complete of all tabs. So I
think the trigger is on the node not the action tabs."*

★ **Two things in the record already agree, and neither is `ifUnseen`:** the shipped row is
`{ sense, action, arg }` with no trigger field (`routes.lua:1057`), and RI-17's grammar is three
parts, `<sense>:<action>:<arg>`. **Trigger was the only field on the BEHAVIOUR record the ruled
grammar never had.** → `driver_data_model.md` §A1.1 and A11.1a carry the move.

### ★★ THE MATCHED PAIR — why it must be authored and cannot be inferred

    a RECOVERY BEACON     stageless · ONCE        consumed; must not re-set your stage
    a COURSE CORRECTOR    stageless · EVERY TIME  "get back on course" - speaks whenever
                                                  you are there

**Both stageless, opposite answers.** So Trigger cannot be derived from the node's kind, its stage,
or its always-open status. ★ And it is a toolkit rather than a feature: a stageless node (§385c)
+ always-open (A11.3d) + Trigger every time + a note = course correction, with nothing built for it.

### THE OPEN QUESTION — the default, and it carries no risk

**Once, or every time?** His argument for every-time: *"Ratcheting already serves a lot"* — a staged
node completes and the index moves past it, so `once` duplicates the ratchet; the nodes that need
`once` are the ones outside it.

✓ **AND THE RISK I ATTACHED TO THIS IS VOID.** I claimed an every-time default would put `Set(N)`
nodes back in the re-set trap. Battlewrath: **"Set has already proven to need to fire once as a
part of node completion."** Completion owns set-idempotence — which is the same reason I gave for
retiring `ifUnseen` two paragraphs earlier in the item this replaces. **Both cannot be true and
completion is the one that is.** So the default is an ordinary authoring choice with nothing
dangerous behind it.

    IMPACT
      on disk now      NONE. The control is not built and has no code term.
      records          A10.3a's dropdown (order, default) · §A1.1's Trigger slot on the
                       CHARACTERISTIC record · the adaptor row, which already carries the label
      does nothing to  `ifUnseen` (see below) · the sense-word pairing · completion (A2.7) ·
                       the record split · W1-W7

### ⚠ NOT PART OF THIS ITEM — `ifUnseen`

**It dies with `role` when `Next(Type, arg)` lands** (Battlewrath: *"I'd say die"*), because
completion owns set-idempotence. **It is not Trigger renamed** — it is gated on `role == "set"`
in the pane (`object.lua:466`), says so in its own comment (`routes.lua:1143`), and its only
consumer tests the role first (`backlog/debug_suite/walk.lua:95`). ⟶ Carried with the `Next` work
in `driver_built_state.md`, not here. **Keeping the two joined is what made this item circle.**

### ⚠⚠ HOW THIS ITEM GOT LONG — four lines, kept as the lesson

1. The record never joined `Trigger` to `ifUnseen`. **I made that join**, then spent an afternoon
   reconciling it against documents that had been consistent the whole time.
2. I filed a gap that governing #4 had already closed (*"step-on / still-on is not a field"*) —
   the second time in one session, after RI-19.
3. I checked where `ifUnseen` is STORED and not where it is READ, which is the memory
   [[stored-field-isnt-live-check-consumption]] failing to fire on its own case.
4. Each of his refinements was written up as a position and superseded by his next sentence —
   the exact staleness-manufacture recorded in [[shaped-not-ruled]] that morning.

---

## RI-29 · "NO HANGING ITEMS" vs THE FILE — a status conflict, reported not resolved

_Filed 2026-08-19 (§387) by the **Addons bench** at Battlewrath's ask: **"Put it in reconcile.
Better it's challenged and clarified."** ⚠ **RI-28 is SKIPPED** — it was spawned and withdrawn by
the Analyst (named in RI-27's own text), so reusing the number would read as that item returning._

### The conflict, stated

> **Battlewrath, 2026-08-19: *"Development should be opened up again. No hanging items that need
> reconciling."***

⚠ **Measured against this file, by this file's own convention** (*"an item is DRAINED when its text
begins `RI-N DRAINED (who, date)`; an item without that stamp is OPEN"*):

    grep -c "RI-[0-9]* DRAINED"  ->  0 stamps anywhere in the file
    open headings                ->  RI-19 · RI-22 · RI-24 · RI-26 · RI-27

⚠⚠ **AND THE FILE CHANGED WHILE THIS ITEM WAS BEING WRITTEN**, which corrects one of its own five.
Recorded rather than quietly edited, because it changes the count:

    RI-19  carries **"RI-19 WITHDRAWN — IT WAS NEVER TRUE"** (Opus 5 Analyst, 2026-08-19) —
           the defect was already fixed at `5725b7d` §376, an ancestor of HEAD before the
           session began. ★ So it is NOT a hanging question; **it wants a STAMP, not a
           ruling**, and by the file's own convention (no `RI-N DRAINED` prefix) it still
           reads as OPEN to a grep. ⟶ **A record-keeping gap, not a decision.**

★ **So the genuinely open set is FOUR**: RI-22 (bench-side) · RI-24 · RI-26 · RI-27. ⚠ And one of
those four, RI-26, is the one that says it blocks a build step.

★ **The bench is not disputing the call — it cannot see what was settled in conversation.** It is
reporting that the record and the instruction disagree, which is the one thing this channel exists
to surface. ⚠ **And it has now been wrong once inside this very item**, which is the argument for
filing rather than asserting in chat.

### What was measured (read-only, 2026-08-19)

**Tree health is GOOD** against the Analyst's landing:

    20/20 smokes (exit codes, not last lines)   ·   targets 32/32   ·   walk W1 PASS · W5 PASS

**⚠ AND THE ANALYST'S LANDING IS UNCOMMITTED.** Fifteen paths in the working tree:

    retired    driver_bench_proposition.md · driver_data_model_proposition.md ·
               driver_sense_proposition.md  -> history/
    new        driver_data_model.md · driver_built_state.md · driver_stored_state.md ·
               audit/{built_state,store_inventory,doc_comprehension_test}.md ·
               tools/{emit_store_inventory,emit_built_state}.py ·
               history/Reconciliation_inbox_drained.md
    modified   DRIVER_BASIS.md · dungeonrun_model.md · driver_programmatic_model.md ·
               driver_{authoring,sense,ui}_acceptance.md · tools/check_targets.py

**⚠ RI-26 STATES IT BLOCKS A BUILD STEP**, in its own words: the sense brief's **P2** is *"the row
SHAPE as a declared contract + fixture list"*, **"P2 builds the artefact G5 decides the shape of"**,
and its IMPACT line reads *"blocks: sense P2 (the contract file) -> P3, P4's fixtures. Nothing
else."*

★ **That is why this is filed rather than asked-and-proceeded.** Building P2 with G5 open is the
shape of §317 — *"Building code against the wrong target"* — and the bench would rather raise it
than find it afterwards.

### ⚠ AND ONE THING ABOUT THE BENCH'S OWN BASIS

**The bench has not read the new documents.** `driver_data_model.md`, `driver_built_state.md`,
`driver_stored_state.md` and the three new audits landed while this bench was elsewhere. ★ Whatever
is instructed below, **the bench reads those before it builds** — stating it here so it is a step
rather than an assumption.

### Instruction lines (a status conflict, so no deliberation — §342)

    ⚑ RI-19 is a STAMP in every line below, not a choice - it is withdrawn, not open.

    a  ALL FOUR ARE SETTLED. Stamp RI-22/24/26/27 DRAINED; development opens on everything.

    b  THE ANALYST'S THREE ARE SETTLED (RI-24 · RI-26 · RI-27); RI-22 is BENCH-SIDE and never
       gated you. Stamp the three; the bench drains RI-22 itself and opens.

    c  RI-26 STANDS. Sense P2 waits on G5; development opens on everything else, and the
       bench is told what "everything else" is.

    d  "NO HANGING ITEMS" MEANT YOUR SIDE OF THE PASS. The items stand as filed; development
       opens on bench-side work only until each is drained in turn.

**⚠ No bench read on which of these is true** — it is a fact about intent, and the bench cannot
measure intent. ★ **A bench read on the MECHANICAL part only, and it holds under every option:**
**the Analyst's landing should be COMMITTED before any development starts.** Fifteen uncommitted
paths including three file renames is a body of work that a bad afternoon loses, and every option
above builds on top of it.

    IMPACT
      on disk now      NOTHING changes by filing this. The conflict is reported, not acted on.
      shipped guards   none. All gates pass right now, which is why this is a records question
                       rather than a repair - ⚠ and why it would be easy to proceed past.
      at risk          15 uncommitted paths, 3 of them renames, none recoverable from git
      blocks           only what RI-26 says it blocks - sense P2, and P3/P4's fixtures via it
      does nothing to  the sense rule · W1-W7 · the adaptor · the UI leg · any shipped addon

---

# THE SETTLED SET — every drained item, flattened

_Form (Battlewrath, 2026-08-19): **question · outcome · NOT statement · IS statement · cite.**
The prose these came from is `history/Reconciliation_inbox_drained.md`; nothing was deleted.
★ **The NOT line is the point.** An outcome recorded only as what we chose leaves the rejected
shape free to drift back in; naming it once is what stops that._

⚠ **This footer directs nothing.** It is a settled-set index — the CITE column names the record
that governs. Where a cite and this line disagree, the cite wins.

    RI-1   Q  is a child's note copied per child, or referenced?
           O  the THIRD WAY
           ✗  NOT copied per child · NOT on the personal plane
           ✓  referenced in the STORE, owned in the PANE; sharing is a later re-point
           →  A4.2 · model §5

    RI-2   Q  does ReachOf return a raw value or a resolved default?
           O  SPLIT them
           ✗  ReachOf does NOT resolve · nil is NOT an error
           ✓  raw (nil = the author set nothing); the consumer resolves ±2.5; the author ticks
           →  A1.3 · model §3

    RI-3   Q  "walk" has meant two things - which is which?
           O  they SEPARATE
           ✗  `/dr walk` is NOT revived
           ✓  TEST DRIVE = its own suite entry inside Dungeon Run; assurance = the diagnostic suite
           →  A6.1

    RI-4   Q  what re-mints when a route is imported?
           O  ONLY THE RID
           ✗  NOT a full waterfall · the origin on someone else's data does NOT travel
           ✓  BID:CID carry unchanged; place carries as current; metadata outside identity survives
           →  BASIS positions · A8.4 · ledger §5.9-5.11

    RI-5   Q  are the two distance thresholds two kinds of sense?
           O  NO - they are ACTIONS at distances
           ✗  there is NO firing field · NO beacon-level "next" over children
           ✓  two (action, distance) pairs = two tabs = two steps; the pane is SENSE · WHAT I DO ·
              TRIGGER; the FIRST CHILD acts as the beacon
           →  model §1/§2 · A2.5

    RI-6   Q  is the CID counter route-scoped or per-BID?
           O  ROUTE-SCOPED, as shipped
           ✗  stage and ordinal are NEVER identity · two beacons on one stage is NEVER locked
           ✓  `RID:BID:CID`; only the RID re-mints; a collision is TOLD and the driver states it
           →  BASIS positions · A8.4

    RI-7   Q  does `activate` survive goTo's removal?
           O  GONE with it
           ✗  no node stores another node's IDENTITY
           ✓  the ordinal sub-ratchet is the hand-off; a jump is `set step N` - a number
           →  model §2 · A2.6

    RI-8   Q  does `onRamp` survive?
           O  GONE in the same commit
           ✗  NOT a second mechanism for entry
           ✓  entry = the childless beacon, else the FIRST CHILD. What survives is UPDATERS and
              ORDINAL, and both beacons and children have both
           →  A2.6 · BASIS positions

    RI-9   Q  are notes v1 or v2 (S8 against G1)?
           O  BUILD IT - S8 reversed, as a reversal
           ✗  notes are NOT deferred
           ✓  notes are IN v1; G1 stays in the standing order
           →  scoping S8 note · model §5 · A4

    RI-10  Q  one note table with two key shapes, or two tables?
           O  A SEPARATE SHELF
           ✗  export is NEVER a filter · the personal plane NEVER travels
           ✓  two tables; the words are "route note" / "personal note"; the author's label is
              "Route instructions"
           →  A4.2 · model §4b · store.lua:471

    RI-11  Q  which UI placement option?
           O  (d) - fix the canvas now, defer the rest
           ✗  UI placement is NOT argued before the overhaul
           ✓  check_rects' canvas is a RED; hand-placed controls are NAMED unverified
           →  A9.6

    RI-12  Q  is A4.2 closed?
           O  (b) - closed except the travel half
           ✗  the travel assert is NOT written yet
           ✓  the two-tables structural guard stands; the behavioural assert lands with A8.5
           →  A4.2 · A8.5

    RI-13  Q  relabel the personal note?
           O  NOT OPEN - RI-10 already ruled it
           ✗  NOT a reversal
           ✓  implementation of a drained ruling; relabel when the pane work happens
           →  RI-10 · adaptor

    RI-14  Q  where does acceptance composition live?
           O  ONCE, at the CALL LAYER
           ✗  NOT inside routes.lua · NO source-text scanner
           ✓  the headstone stays; the smoke sweeps every call site
           →  A1.2 · A1.4

    RI-15  Q  is boss a sense, and what is the better taxonomy?
           O  NEITHER - the class dissolved rather than got a better name
           ✗  boss is NOT a sense · player-state predicates are NOT senses (scrubbed, RI-17)
           ✓  sense = the LOCATION and the behaviour whilst in its R; boss is the ACTION word;
              the author's condition is KILLED only
           →  model §2 · A3 · A3.5 · A10.3a

    RI-16  Q  does the runtime lookup land before the first fold?
           O  YES
           ✗  NOT a deviation from the fold order
           ✓  one function over one constant table, pass-through on a miss; ROLE_TEXT and
              SENSE_TEXT retire into it. Same turn: a child completes when ALL its tabs have
           →  A10.2 precondition · A2.7

    RI-17  Q  how is a WHAT-I-DO row expressed?
           O  THE DECLARATION GRAMMAR
           ✗  NO separate condition field · falling / in-combat / encounter are NEVER terms
           ✓  a row IS one declaration `<sense>:<action>:<arg>`, stored and exported whole; the
              third sense-word is "When off"
           →  model §2 · A3.2 · adaptor · A10.3a

    RI-18  Q  the data model's six questions
           O  ALL SIX SETTLED
           ✗  the export is NOT a copy of the store · NO free text on the line
           ✓  identifiers and numbers only; two side tables; Stage:Step composed at export;
              reconcile-and-tell on import; order asserted at ingest; notes by NoteID in the
              editor too
           →  #3 §A · A11.1a/c · A8.6 · A4.2

    RI-20  Q  a version token, a coordinate bound, a non-finite - what does the format do?
           O  P1 DE-PRIORITISED · P2b CLOSED · P2a CARRIED
           ✗  NO version token now · a derived bound CANNOT refuse a bad value
           ✓  no V1 and no installed base means no stale reader to protect; precision follows the
              configured minimum radius
           →  #3 A17 · #3 §B

    RI-21  Q  none - it was an inventory of what the field does
           O  ABSORBED
           ✗  nothing in it was PROPOSED
           ✓  the techniques weighed and not taken are #3 §C; D1 and D13 became seeds S1 and S2
           →  #3 §C · #3 §D

    RI-23  Q  what is the unit that must be independently readable - the node or the row?
           O  THE NODE
           ✗  a row is NEVER interpretable cold · nothing AUTO-UPDATES · NO `0` in a dropdown ·
              beacon stages are NEVER fractional
           ✓  a node record plus row records; stage 0 = always eligible; whole-number beacons and
              the author's choice for ordinals; the absence is a TICK; the selector shows the store
              and derives nothing
           →  #3 §A1/§A3 · A10.3e

    RI-25  Q  identity, characteristics and behaviours as separate records?
           O  YES - TWO record kinds
           ✗  NO ownership table · the driver as a whole is NOT pure
           ✓  the address IS the chain; a pure RULE plus a stateful SENSOR that holds the resolved
              parameters, the two gate sets, and later the completion ledger
           →  #3 §A1/§A5 · A11.3
