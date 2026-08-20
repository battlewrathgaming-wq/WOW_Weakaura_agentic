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

**RI-19 DRAINED (Opus 5 Analyst, 2026-08-19) — WITHDRAWN, never true.** ⚠ Stamped per RI-29:
the withdrawal was in the text and not in the STAMP, so the file's own convention
(`grep "RI-N DRAINED"`) still read it as an open question. **A record-keeping gap, not a
decision** — and exactly the kind that makes a "no hanging items" claim measurably false.

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

**RI-22 DRAINED (Battlewrath 2026-08-20 - his best working model, not a ruling; records
reconciled by Opus 5 Analyst) - THE BAND IS UPWARDS ONLY.**

    the shape     ONE upward value. Not a pair, not a symmetric list, not named pairs -
                  the option-shape question dissolves because there is no downward half.
    the default   2.5 yards.
    the placement ADVANCED. "More of a advances option than every day setting, so bottom
                  of the list."
    the store     THE NUMBER. "Store the number. The choice is a look up."

* HIS REASON, and it is corroborated rather than taken: "our data points are captured from the
floor level." ROUTER 280 has a unit's z as its BASE POINT (emulator source), so a sample IS the
floor and downward tolerance measures nothing. And 2.5 up covers the measured jump apex of
~1.64 (ROUTER, four flat jumps read between IsFalling's edges).

! VERIFIED, AND BOTH OF US HAD IT WRONG FIRST. He recalled the tests as "up 2.5, not +/-";
measured, W3.2's candidate row passes BAND_CANDIDATE as BOTH up and down (walk.py:1360) and
W1.7's fixtures say "band +-2". I claimed the change "moves every w5 golden"; measured, the
goldens are produced with bands OPEN and say so in their own header - "Bands are OPEN here. The
band is a SEPARATE criterion (W3.2)". -> What actually moves is W1.7's fixtures and W3.2's sweep.
The rule already takes band_up and band_down separately, so up-only is band_down = 0, not a
signature change.

-> UNBLOCKS the reach and band pickers (A10.3e). Records: A1.3's raw-nil wording, W1.7, W3.2,
setReach's third argument.


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

**RI-24 DRAINED (Battlewrath 2026-08-20 - his best working model, not a ruling; records
reconciled by Opus 5 Analyst) - THE FIELD IS NOT SPECULATIVE, IT IS WRONGLY SOURCED.**

> "Nothing scraped about the character should leave into export. That's for the user to disclose
> what characters they play. Who, When, Author notes? (Like Weak Auras. Doesn't disclose the
> character / account who authored.)"

** THE QUESTION WAS THE WRONG ONE and his answer replaces it. This item asked keep-or-drop.
`route.author` is minted as `UnitName("player")` (routes.lua:121) - that IS scraped character
data, and shipping it in an export is disclosure the author never made. -> The disposition is
neither: the field is REPLACED by user-supplied metadata.

    OUT   author = UnitName("player")     scraped, and travels
    IN    who / when / author notes       the author types them, or leaves them empty

* It lands on a law already on file - RI-4's "the origin on someone else's data does not travel"
- and on the bench's own manners: read-only on data that is not ours.

! WIDER REACH, named not acted on: `runs[].character` is the same shape on the capture side. A
run is EVIDENCE and never travels (store.lua, 61), so it is not a leak today - but it is the same
field minted the same way, and whoever builds export should meet this sentence before they meet
that one.

_★ **BENCH UPDATE 2026-08-20 (§392, §400) — two of this item's three parts have landed, and
only D-2 is still a ruling.**_

    D-1  `fireOn` RETIRE          ✓ BUILT §392 (A2.12). Setter removed whole with a
                                  headstone; a stored value dropped and TOLD through
                                  `DropRetired`, on every load. Five mutations bite.
    the `store.lua` HEADER        ✓ FIXED §400. This item's own finding - the `Shape:`
                                  block said `schemaVersion = 1` (it is 2), keyed `runs`
                                  by NAME (keyed by id since A8.4), and named none of
                                  `routes` · `routeNotes` · `notes` · `ui`, all four of
                                  which that file creates. ⚠ REMOVED rather than
                                  corrected: correcting it would have rebuilt the thing
                                  that rots. It now POINTS at the curated fact and the
                                  emitted evidence, and keeps only the composite shapes
                                  (`<point>` · `<marker>` · `<leg>`) the emitter cannot
                                  say. **The only safe mirror is no mirror.**
    D-2  `author` / `madeAt`      ⚠ STILL OPEN - Battlewrath's word, unchanged.

_Filed 2026-08-19 by **Opus 5 — Analyst**, at Battlewrath's ask: **"We need a heading fixed-ish on
our data model before we over build selections. We need an inventory of what is stored and how. And
then flatten that into a going forward fact. I'd rather re-write now and sort our debt, than
tangle."**_

**THE TWO ARTEFACTS:**

    addons/tools/emit_store_inventory.py       the machine
    addons/planning/history/store_inventory.md   EMITTED evidence - never hand-edit, re-run it
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

**RI-26 DRAINED (Battlewrath 2026-08-20 - his best working model, not a ruling; records
reconciled by Opus 5 Analyst) - A SERIALIZED STRING, TWO-STAGE LOAD.**

    the transport   AceSerializer (shipped, Ace3/wotlk-r960) -> LibDeflate compress ->
                    LibDeflate:EncodeForPrint, behind a VERSION PREFIX.
    the load        TWO STAGES. 1) decode and PRESENT - map, route name, bosses - and ask
                    "save this as a route?" (the WeakAuras shape). 2) on accept it becomes a
                    saved route, written to SavedVariables on reload or logout.
    the surface     a MULTI-LINE EDIT BOX, never chat. ROUTER:123 - the chat edit box is
                    capped at 255 letters and a route is ~2 KB.

* WHAT THE CHOICE COST, corrected before he took it: the Analyst said it needed TWO libraries we
do not ship. LibDeflate is on this machine TWICE - vendored in TidyPlates_ThreatPlates and in the
WeakAuras copy under export/ - and it bundles the encoders, so it is ONE library, and WeakAuras
uses it ON THIS FORK. The cost claim was asserted without looking.

** AND THE PREVIEW IS FREE. Stage 1 needs map, route and node NAMES plus the run-derived boss
names - which are exactly the two side tables A2.6 already defines and the driver never opens.
Nothing extra is carried to make the preview work.

** A4.17 IS OVERTURNED BY THIS, and by nothing else: a version prefix ships from the FIRST string.
The deferral held while a reader could look at what they got. Under an opaque blob a decode
failure and "this is from a newer version" are the same event, and WeakAuras carries `!WA:2!` here
for that reason.

! THE TENSION HE NAMED, DEFERRED ON PURPOSE (Battlewrath, 2026-08-20): "there is a tension with no
chat use... this is for people meeting for a session. So there is no external source in that
moment. So we'd need a batch share protocol between users via a hidden channel when they share.
But that's deferred. No chat user facing route is fine."
-> SEEDED as S12 rather than designed. * And the transport already accommodates it: LibDeflate
ships EncodeForPrint AND EncodeForWoWAddonChannel, so the session-sync path is an ENCODER SWAP
plus chunking, not a format change. ! The per-message size cap on this client is NOT RECORDED in
ROUTER - a client fact to measure the day it is built, not to assume now.


_Filed 2026-08-19 by **Opus 5 — Analyst**, after a sub-agent coverage audit found that the model's
own **"★ THE NEXT THING TO DECIDE"** (`driver_data_model.md` §B, G5) had **no item in this channel**
— so the decision the heading says comes next had no route to the person who makes it. ★ That is
the finding, not the question; the question below has been open since `history/data_model_findings.md`
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

**RI-27 DRAINED (Battlewrath 2026-08-20 - his best working model, not a ruling; records
reconciled by Opus 5 Analyst) - TWO AXES, HELD APART.**

    retry while incomplete    the DEFAULT BEHAVIOUR. Completion ends it. NOT a control.
                              "the ratchet tells the instruction to stop listening, so whilst
                              active, they can repeat try the stage/step until the action tabs
                              are complete."
    run again after complete  TRIGGER. Default NO; opted into per node.

** Holding them apart is what settles it, and conflating them is what made this item circle for
an afternoon.** Both of his cases are STAGELESS and want opposite answers - a recovery beacon must
not re-set once consumed (no), a "get back on course" marker should speak whenever you are there
(yes) - which is only expressible because the second axis exists and is authored.

* **His frequency read, recorded as shape rather than as a rule:** *"We might want to repeatably
force a note when in a area that clears it's own note. But generally a dungeon is sequential.
Course correct is a catch all."* -> the opt-in is the exception; sequential is the common case,
which is why the default is NO.

! **Still not built, and no code term is chosen** (driver_adaptor_table.md:147). Nothing waits on
this - it is drained so the DISTINCTION survives, not because a build step needed it.


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

**RI-29 DRAINED (Opus 5 Analyst, 2026-08-20) - THE SET IS EMPTY. DEVELOPMENT IS OPEN.**

His claim was "no hanging items that need reconciling" and the bench measured it false. It was.
It is now true: with RI-26 landed, this item is the last heading in the file and it is this one.

* THE BENCH WAS RIGHT TO FILE IT rather than accept the claim - the file said otherwise and a
status asserted against a countable fact is checkable. ! And it corrected itself mid-write when
RI-19 changed under it, which is why the count it reported was five and not six.

-> Derive, never read a list: grep "RI-[0-9]* DRAINED" gives the drained; every other ## RI-
heading is open. That convention is what made this item answerable at all.

_⚠ **BENCH UPDATE 2026-08-20 — THE BASIS OF THIS ITEM HAS MOVED, and it is recorded rather
than quietly dropped.** The measurement in it (*"0 stamps anywhere in the file"*) is no longer
true: RI-19 · RI-30 · RI-32 now carry stamps, and RI-19's was exactly what this item asked
for — a record-keeping gap, not a decision. ★ **So the disagreement it reported between the
record and the instruction is closed by events**, and the four instruction lines below are
moot as written._

_★ What the item was FOR still stands and is worth keeping in the drain: the file's own
convention is the only status, and a claim about state is measurable against it. **Ready to
stamp; nothing waits on it.**_

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

## RI-30 · TWO NEW DOCUMENTS DISAGREE ON THE ROW — measured, one line

**RI-30 DRAINED (Opus 5 Analyst, 2026-08-20) — the bench was right and the line is fixed.**
`driver_stored_state.md` §2 now reads `ROW  sense · action · arg`, with the measurement and the
reason recorded beside it. ★ It wanted a CORRECTION, not a ruling — and the bench filed rather
than edited because the file is the Analyst’s, which is the right call and is why it was caught.

_Filed 2026-08-19 (§389) by the **Addons bench**, from orientation on the Analyst's landing.
⚠ **Not a ruling ask.** It is a factual disagreement between two documents that landed in the same
pass, measured against source. Reported rather than edited, because writing another bench's
document is not this bench's to do._

### The disagreement

    driver_data_model.md:31-38   Trigger MOVED TO THE NODE. "the shipped row is
                                 { sense, action, arg } with no trigger field (routes.lua:1057)"
    driver_stored_state.md:48    ROW    sense · action · trigger · arg

### Measured (2026-08-19, read-only)

    routes.lua:1057   rows[index] = { sense = sense, action = action, arg = arg }
    grep for a STORED trigger across addons/COA_DungeonRun/*.lua   ->  NO HITS
                      (no `.trigger`, no `trigger =`, on a row or on a node)

⟶ **`driver_data_model.md` is right and `driver_stored_state.md:48` is wrong.** ★ And the second
measurement is the stronger one: **`Trigger` is not stored anywhere at all**, which is consistent
with the model's own note that *"the control is NOT BUILT"* (`driver_adaptor_table.md:147`).

### Why it is worth a line rather than a silent fix

★ **A1.1 moved Trigger OFF the row deliberately**, and its own note says two sources already
disagreed with it having been there — costing *"an afternoon reconciling this slot against a field
that was never it."* ⚠ **A builder reading `driver_stored_state.md` §2 would put it straight back**,
because that file's whole job is to say what the store holds, and §2 is the table they would copy.

⚠ **And it is the one row in §2 that is not measurable from the emitter** — the emitted inventory
reports fields that are WRITTEN, and a field never written cannot appear in it. So the emit-and-
compare loop that keeps the rest of that file honest **cannot catch this one**, which is the reason
it is filed rather than left to the next re-emit.

    IMPACT
      on disk now      one line in driver_stored_state.md §2. Nothing in code.
      shipped guards   none. ⚠ And none would catch it - no smoke asserts the row's FIELD SET,
                       only its values (`smoke_dungeonrunroutes`), so a fourth key would pass.
      criteria         none move. A1.1 already rules the placement; this is the fact table
                       catching up to it.
      does nothing to  the sense rule · the record shapes · RI-27's remaining half (may a node
                       run again once complete) - that is the LIVE question about Trigger and
                       this item does not touch it

★ **No options and no bench read**, because there is no choice here — a measurement disagrees with
a sentence. The only judgement is whose hand corrects it.

---

## RI-31 · AUDIT SCOPE — do the remaining five follow the three into `history/`?

**RI-31 DRAINED (Battlewrath 2026-08-20) - THE FIVE FOLLOW THE THREE.**

> "If you feel their ready to leave because the planning holds what is useful, they can leave."
> "Move them. Their more examples of the same text to infer seperately. Source of truth and pointers."

* HIS CONDITION WAS A TEST AND IT WAS RUN, not judged. For each of the five: is it cited from a
governing or basis document, and is what it is cited FOR carried where it is cited?

    peer_data_stores       -> driver_data_model.md C, and the basis PEER AUDIT section
    prior_art_formats      -> C, seeds S1 / S2, and the basis PRIOR ART section
    prior_art_execution    -> C (D10-D14), and the basis EXECUTOR PRIOR ART section
    data_model_findings    -> A11.6a (isolation unproven), and the basis BENCH FINDINGS section
    UI_findings_ace_XML    -> driver_ui_scope.md 3b (A-prime DEMONSTRATED), A9.6 / A10.1

All five passed both halves. 1,393 lines moved; every audit/ pointer re-aimed; a sweep for stale
pointers outside history/ returns none.

** HIS REASON IS SHARPER THAN THE ONE THIS ITEM ASKED WITH. The bench asked whether they MISLEAD.
He answered on duplication instead: a finished audit restating a settled conclusion is another
text an agent reads as CURRENT, and it can drift from the one that governs. Source of truth and
pointers.

! AND WHAT THE MOVE DOES NOT DO, measured and reported before he said go: the basis keeps FOUR
summary sections for these audits, 54 lines, on the reading path. Moving 1,393 lines out of audit/
does not shorten what a builder reads - it removes four more places to infer from. The bench's
classification (none of the five carries a one-direction-solid warning) was CORRECT and was simply
not the criterion that decided it.


_Filed 2026-08-19 (§390) by the **Addons bench**. ⚠ Filed rather than asked in chat, per
Battlewrath 2026-08-19: **"Put it into the inbox if it needs my input. I'm specifically making a
barrier so chat sprawl doesn't enter into intent."**_

### What was done, and the criterion used

§388 moved three audits to `history/` on his instruction (*"Audits that can be misleading should be
in history"*). ★ The criterion the bench applied was **each file's own header — does it say a
reading of it can be wrong?** Three answered yes and each is solid in ONE direction only:

    history/built_state.md            "a function with callers may still have no criterion"
    history/store_inventory.md        "a field WITH reads can still be dead"
    history/doc_comprehension_test.md "a CLEAN at one layer says NOTHING about the layer below"

### The question

**Five audits stayed in `audit/`, and the bench chose that rather than being told it.**

    peer_data_stores.md      MEASURED, read-only, on the installed client
    prior_art_formats.md     SOURCED from published specs
    prior_art_execution.md   SOURCED from published specs
    data_model_findings.md   the five shaping iterations; "it directs nothing"
    UI_findings_ace_XML.md   F1-F9, measured under the harness

★ **None carries a one-direction-solid warning** — they report what was measured or what a spec
says, and a wrong reading of them is a misreading rather than an artefact of the method. ⚠ **But
that is the BENCH's classification of his rule, applied to the bench's own files**, which is
exactly the shape that should not be self-certified.

    a  THE FIVE STAY. The rule is about METHOD - an instrument whose positive readings cannot
       be trusted - and measured/sourced findings are not instruments.
       ⚠ `audit/` then holds only findings, which makes the folder mean one thing.

    b  ALL AUDITS LIVE IN `history/`. The folder itself is the signal: anything not a
       governing document or a stated FACT is history, whatever its method.
       ⚠ `driver_data_model.md` §C cites the first four as the evidence for its
       compared-and-not-selected list - that citation moves with them, 4 pointers.

    c  A SPLIT ON AGE, not method: the three superseded by driver_data_model.md go; the two
       still cited stay. ⚠ The bench reads this as the weakest - it makes the folder's
       meaning depend on something invisible from inside it.

**Bench read (marked as the bench's, overturnable in a word): (a)** — because `audit/` and
`history/` would then differ by a property a reader can check from the file itself, which is the
only kind of filing rule that survives someone new. ⚠ Held weakly: (b) is simpler to state and
simpler to obey, and simplicity has beaten checkability on this project before.

    IMPACT
      on disk now      (a) nothing · (b) 5 file moves + 4 pointer rewrites in
                       driver_data_model.md §C, all mechanical and verifiable by grep
      shipped guards   none, under any option
      criteria         none. ⚠ `check_targets` does not read audits, so nothing goes red
                       either way - which is why this needs saying rather than failing
      does nothing to  any record, any rule, any code

---

## RI-32 · A STAGELESS NODE WITH A STORED OUTCOME — A2.10a is silent, and I built the strict read

**RI-32 DRAINED (Battlewrath 2026-08-20, records reconciled by Opus 5 Analyst) — (a) AS
BUILT, PLUS THE TELLING.** ★ The bench found the answer itself and could not take it:
*"(c)-without-the-refusal — store it, ignore it, and SAY so — is the shape that matches
§81 best, and the bench did not build it because A2.10a does not mention telling and
inventing a message is not the builder's to do."* **That was the right boundary to hold**
— the row was silent and a builder should not fill a criterion's silence with a string.

⟶ **A2.10a now carries it:** the strict read stands (`Outcome` answers nil), the editor
SAYS SO when the value is stored, and the message must be accurate — **stored and
DORMANT, not lost**, because giving the node a stage revives it. ⚠ No refusal: §81
forbids validation on authoring, so (c)'s refusing half is out and its telling half is in.
⚠ The wording is the naming pass's; the row fixes what it must convey.

_Filed 2026-08-19 (§393) by the **Addons bench** while building A2.10a. ⚠ Filed rather than
asked in chat, per the barrier._

### What the row says, and the gap

**A2.10a:** *"A STAGELESS NODE DOES NOT PROMOTE THE INDEX. Completing it runs its tabs and moves
the ratchet NOT AT ALL. `Outcome` must answer 'no promotion' for a node with no stage - not 1,
and not the current index either."*

★ **Unconditional, so that is what was built:** `Outcome` returns `nil` for a stageless node
before it looks at `b.outcome`. ⚠ **But `SetOutcome` is reachable from the pane for any beacon**,
so an author CAN store a checkpoint on a stageless node - and the build now ignores it silently.

### The question

    a  UNCONDITIONAL nil, as built. A node outside the sequence cannot promote the
       sequence, whatever is stored on it.
       ⚠ silently ignores something the author typed
    b  HONOUR a stored `b.outcome`. An explicit checkpoint is an author instruction and
       beats a default; only the DEFAULT (`self + 1`) is meaningless without a stage.
       ⚠ re-opens the trap A2.10a closed, by a different door - the node is still not
       in the sequence, and now it moves the index to a literal
    c  REFUSE `SetOutcome` ON A STAGELESS NODE, and TELL. The value never exists, so
       nothing is ignored and nothing is honoured.
       ⚠ refusing is GRADING the author, which §81's ruling forbids on authoring
       ("NO validation on authoring - duplicate stages, out-of-order and fractions are
       all legal, the author is TOLD"). ★ The telling half fits that ruling; the
       refusing half does not.

**Bench read (marked as the bench's, overturnable in a word): (a) as built, and it is what the
row says.** ⚠ But (c)-without-the-refusal - **store it, ignore it, and SAY so** - is the shape
that matches §81 best, and the bench did not build it because A2.10a does not mention telling and
inventing a message is not the builder's to do.

    IMPACT
      on disk now      routes.lua Outcome (built, (a)) · one smoke row asserting the override
      shipped guards   the row is GREEN under (a) and RED under (b) - it is asserted, so a
                       ruling for (b) is a one-line change to both, not a hunt
      criteria         A2.10a gains a sentence either way; §81's authoring ruling is the
                       thing (c) argues with
      does nothing to  the eight-consumer contract · A2.10c · the stage 0 rules · anything
                       outside `Routes.Outcome`
---

## RI-33 · WHAT THE DRIVER NEEDS vs WHAT THE BENCH BUILT TO PROVE IT

**RI-33 DRAINED (Battlewrath 2026-08-20 - his best working model, not a ruling; records
reconciled by Opus 5 Analyst) - BUILD FROM NEED, NOT FROM PRECEDENCE.**

> "Anything on the bench has to prove it's needed in live code. But we build from need to function
> not on precedence. Precedence is the proof we can. Not the implementation the addon needs."

*** THE ITEM ASKED WHICH OF THREE. HIS ANSWER IS THE PRINCIPLE UNDER ALL THREE, and it selects
(b) as a consequence rather than as a preference. `walk.py` is PROOF WE CAN detect. W7.1's
byte-equality turned that proof into a specification, and this sentence separates them again.

    THE DESK      proves the rule is reproducible. It reconstructs a FIXED-CADENCE RECORDING
                  and must interpolate. Segment interpolation, interpolated-z, v_max are its
                  answers to ITS problem.
    THE DRIVER    matches POS against constraints and calls functions. It CONTROLS WHEN IT
                  LOOKS, so it throttles up on approach instead of reconstructing a path.
    THE BURDEN    is on the bench artefact. Existing is not a reason to ship.

* AND THE MEASUREMENTS TAKEN AFTER THIS ITEM WAS FILED ALL POINT THE SAME WAY - none of them
was sought to support it:
    GetUnitSpeed is dynamic and reports yards/second (ROUTER, measured 2026-08-20) -> the
      driver has a real closing-speed input and does not need to infer motion from geometry
    the parked standoff returns a live distance, 1600 -> 1583.31 (ROUTER, measured) -> the
      driver gets a continuous verifier without any desk machinery
    the export contract holds 17 fields and NONE is desk machinery (RI-33's own measurement)
      -> the thing the driver reads never carried it in the first place

-> W7.1 MOVES. It stays as the DESK's calibration - byte-equality between the desk and any
reimplementation OF THE DESK - and stops being the driver's shipping requirement. The driver is
graded on OUTCOMES at the ruled radii and the ruled cadence; W7.2's synthetics become that
surface. A11.2a narrows to point + band + gate; segment, interpolated-z and v_max are desk-side.

! UNBLOCKS P3, the Lua port, which is what this item said it blocked. And it avoids the cost the
item named: porting machinery under (a) and then deleting it under (b).


_Filed 2026-08-20 (§408) by the **Addons bench** at Battlewrath's ask: **"I'd roll this whole
conversation into a inbox item. Then design can spec what the driver needs vs what we build to
prove it on the bench that we can."** Evidence: `audit/s9_teleport_guard.md` (§406, §407) and the
measurements below._

### ★★★ HIS OBSERVATION, WHICH IS THE ITEM

> *"Part of our tooling to prove we can is being snuck into the addon as a requirement, simply
> because it exists."*

**It is true, and the mechanism is nameable.** `driver_walk_acceptance.md` **W7.1 requires the Lua
port to be BYTE-EQUAL to the desk.** That single criterion converts every decision inside
`walk.py` — segment interpolation, the interpolated-z band, `TELEPORT_VMAX`, the teleport door,
S9 — into a **shipping requirement**, not because the driver needs them but because the desk has
them. ⚠ **The proving instrument became the specification by transitivity, and nobody decided
that.** It is not a mistake anyone made; it is what byte-equality means when the reference was
built to answer a different question.

⚠ **And the bench walked into it.** §406 and §407 audited S9 as a product question through two
rounds. The measurements are sound; the prior question — *does this belong in the addon at all* —
was never asked until Battlewrath asked it.

### THE MEASUREMENTS (all read-only; `walk.py` restored from a scratchpad copy, never regolded)

**1 · S9 is real.** `transits` (`walk.py:569-575`) falls back on THREE conditions — a hole, a
mapID change, a TELEPORT (`d3/Δgt > v_max`). The three `broken` recomputations (`:1047 :1159
:1276`) fall back on TWO. The teleport door is absent from all three, and those produce the w5
goldens that W7.1 grades against.

**2 · Adding the guard moves NO golden** — and that is because the goldens are BLIND to it, not
because the rules agree. The four qualifying samples are in `RFC_Run2_Messy-2` and
`RFC_Run3_Messy-5`; the goldens cover `SFK_live`, `SFK_Run4`, `rfc_combat`. Overlap: **none**.

**3 · The four are release-to-graveyard after a wipe** — three sit within ~3 s of a recorded
death, at ~1.0 s cadence, so `gap_bound` does not catch them. ⚠ The fourth is 55.8 s from any
death and is left UNATTRIBUTED rather than tidied into the story.

**4 · The cadence claim this bench made DIED.** §406 argued a denser sample would push false
teleports up. Measured, legitimate movement only:

        0.2 s runs   5 runs   fastest 50.6 yd/s   margin to v_max 2.0x
        1 Hz  runs   7 runs   fastest 56.9 yd/s   margin to v_max 1.8x

★ Flat across cadence, and the 1 Hz figure is HIGHER — the opposite of the prediction. The
premise assumed a burst shorter than the sampling window; the real bursts last about a second and
dominate both. **A granular throttle between 0.2 s and 1 Hz is free of this concern.**

**5 · ★★ AND AT THE RULED MENU, THE MACHINERY HAS ALMOST NO WORK.** Battlewrath, this
conversation: *"a drop down option. Min 5 yards. Probably up to 50. Steps between."* At the
measured 0.2 s floor, top legitimate speed covers **10.12 yd per sample**:

        R          skippable by a CENTRAL pass?   a graze is missable only outside
        5          YES, by 0.12 yd               (any)
        8          no                             77% of the disc
        10         no                             86%
        20         no                             97%
        50         no                             99%

⟶ **`segment_fire` has work only at R = 5, only at charge speed, and only for a graze.** Position
is ABSOLUTE — Battlewrath: *"the player position is absolute. It is as fresh and accurate as the
rate we sample it."* — so both endpoints are simply true, and interpolation is not reconstructing
a noisy signal. **It is compensating for not sampling fast enough**, and 0.2 s was measured as
fast enough to catch a player in R.

### WHAT V_MAX DOES, stated once so the spec does not have to re-derive it

    mapID change   are these the same coordinate space?      frame validity
    gap_bound      did I look often enough to interpolate?   temporal density
    v_max          is this displacement achievable?           spatial plausibility

★ Three orthogonal questions; `v_max` is the only one that asks whether two positions are
MUTUALLY REACHABLE, which is why the corpse-run case (287 yd in 1.0 s) passes `gap_bound` and
fails only it. ⟶ **`v_max` is the upper wall of the window where segment interpolation is valid;
the sample rate is the lower wall.** Between 50 and 100 yd/s at R = 5 is the entire regime where
`segment_fire` both matters and can be trusted.

### The question for design

**What does the DRIVER need, and what did the BENCH build to prove it could be done?** They have
not been separated, and W7.1 is what keeps them fused.

    a  BYTE-EQUALITY STANDS. The port reproduces the desk whole, and S9 is settled first so
       the two agree on which rule is being reproduced.
       ⚠ Ships segment interpolation, the interpolated-z band and v_max into a product whose
       ruled radii give them ~no work.
    b  THE DRIVER IS GRADED ON OUTCOMES. Does it fire where it should, at the RULED radii and
       the RULED cadence - the desk stays the calibration instrument it was built to be.
       ⚠ W7.1 is rewritten, and W7.2's synthetics become the grading surface instead.
    c  A SPLIT: byte-equality for the RULE's core (point + radius + band), outcome-grading for
       the parts the ruled parameters make unreachable.
       ⚠ Someone must draw the line, and a line drawn wrong is worse than either whole answer.

**⚠ NO BENCH READ on which.** This is a scope decision about what the product IS, not a build
shape, and the bench is the party whose work is on both sides of it. ★ The bench reads offered
are only the measurable ones above.

    IMPACT
      on disk now      NOTHING. No code changes on any option; walk.py is untouched and the
                       goldens are as they were.
      shipped guards   none break under any option. ⚠ And under (a) NOTHING GRADES S9 either
                       way until a fixture covering a teleport pair exists - the corpus
                       already holds two such runs, so no capture is needed.
      criteria         W7.1 is the row that moves under (b) or (c) · A11.2's port rows inherit
                       whichever is chosen · S9's disposition follows rather than leads
      does nothing to  the contract and fixtures (§405) · the rule's core (point + radius +
                       band) · anything already built for A1-A5
      ⚠ blocks         P3, the Lua port. Building it under (a) and then moving to (b) means
                       porting machinery twice, and the second port is the one that deletes.

### ★★★ HIS READ (Battlewrath, 2026-08-20) — THE SPLIT, and it is a clean one

> *"There is use on V_max. But it's on the editor side. Simulating a data route and seeing what
> triggered. As that's our process. But the driver only needs to be able to match POS against
> restraints and then call functions. And the failure is not detecting them in a R as a player
> behaviour of speed. IE. If they teleport over a R, between our samples. And that's why we
> throttle up on approach. (Up as in greater cadence.)"*

    EDITOR / DESK   v_max, segment interpolation, the interpolated-z band. The PROCESS is
                    simulating an authored route against captured data to see what triggered.
    DRIVER          match POS against constraints; call functions. Nothing more.
    THE FAILURE     NOT "speed as a player behaviour" - it is MISSING a beacon because the
                    player crossed R between two samples.
    THE ANSWER      throttle UP on approach - greater cadence - not a reconstructed path.

★★ **Why the split is structural rather than a preference:** the desk reconstructs from a
FIXED-CADENCE RECORDING and has no choice but to interpolate; **the driver controls when it
looks.** Interpolation is the desk's answer to a problem the driver does not have.

⟶ And it re-frames the failure this bench had been analysing. §406-§407 chased a FALSE FIRE
(a fictional path sweeping beacons the player never neared). His failure is the opposite and it
is the one that matters in-game: **a MISS.** A false fire is an editor-side artefact of replaying
a recording; a miss is a player standing in the right place while nothing happens.

### ⚠ ONE CONSEQUENCE, marked as the bench's inference and not part of his position

To throttle up ON APPROACH the driver must know it is approaching — and it knows distance only
from the last sample. To decide how long it may wait before looking again it needs an assumption
about how fast that distance can close. **That is a maximum-speed bound.**

    desk     v_max VALIDATES a path      "was that displacement travel?"     backward-looking
    driver   a speed bound SCHEDULES     "how soon could they reach R?"      forward-looking

⟶ roughly `next_interval = clamp(distance_to_nearest_R / V_assumed, floor 0.2, ceiling)`.

★ **Same constant, opposite direction, and a different KIND of number.** The desk's is a
plausibility threshold and being wrong means a wrong verdict. The driver's is a SAFETY bound and
the errors are asymmetric: too high costs extra samples (cheap), too low means a miss (the
failure he named). ⚠ So they should not share a value just because they share a name.

⚠ **The bench has not seen the throttle plan** and this may already be in it. Recorded so the
spec does not have to re-derive it, not as a proposal.

### WHERE THAT LEAVES THE OPTIONS ABOVE

His read is **(b) or (c)** — the driver graded on outcomes, with the desk kept as the instrument
it was built to be. ⚠ It does not by itself say which, because (c)'s line — *byte-equality for the
rule's core, outcome-grading for the rest* — still has to be drawn, and **the core he names
(match POS against constraints) is narrower than `walk.py`'s core**: no segment, no interpolated
z. ★ That is the thing for design to spec.

⚠ **S9 becomes an EDITOR question under this read**, not a driver one. The teleport guard's
absence from the three `broken` recomputations still affects what the simulation reports to an
author — which is `walk.py`'s job and still worth settling — but it stops blocking P3.

### ★★ TWO REDUNDANCY IDEAS (Battlewrath, 2026-08-20), checked against ROUTER

> *"When an instruction isn't using the supertracker, we position it off-map... so we have a
> constant yard reading. Just a thought for redundancy. Also there might be an API for current
> speed."*
>
> *"Nothing 'owns' the super tracker. It accepts last over write. So our owning it is just
> setting it to a parked position after something has consumed the super tracker. First
> position, boot it 1.6k out of reach of every node (Min/Max, pick the lowest or highest
> diff.)"*

#### 1 · THE PARKED PIN — the design works; the word "off-map" is what does not

⚠⚠ **"Off-map" in the literal sense is already measured and it fails silently.** `ROUTER:107`:
across a MAP boundary the tracker returns *"state Invalid with distance `0.00` — NOT nil"* while
`IsSuperTrackingAnything()` still reports true, and **1,386 consecutive confident zeros** were
recorded walking RFC holding an SFK pin, against our own arithmetic reading 1,946–2,217 yd.
★ ROUTER's own note: **zero satisfies every radius test.** A cross-map park is a false-positive
generator, not redundancy.

★★★ **But PARKING FAR AWAY ON THE SAME mapID is a different thing and it works.** `ROUTER:99`,
measured: the limits are **range and map change, never zone crossing** — past ~1500 yd *"the
CLIENT stops drawing the beacon while the ENGINE keeps returning true distance"*, measured to
3,742 yd, *"so our readout is uncapped"*.

⟹ **1.6k out is exactly the right number**: beyond the draw range, so nothing is shown to the
player, and inside the engine's live reading. ★ And the enabler is already on file — **mapID is
the CONTINENT** (`ROUTER:99`: *"mapID is the continent, and 1,291 yd of travel never changed
it"*), so a park point 1.6k from every node is trivially the SAME mapID and never reaches the
Invalid case at all.

★ **And the ownership framing was the bench's error, corrected here.** `ROUTER:85`: *"THE PIN IS
A SLOT YOU WRITE TO — A NEW SET NEEDS NO RELEASE... the pin only cares about being set."* Nothing
owns it; last write wins. The only durable property is that **nothing in the client's flow clears
it** (`ROUTER:84`), which is what makes a parked value persist — the mechanism, not a hazard.

    THE PARK POINT   1.6k beyond the extreme of the node set - his "Min/Max, pick the lowest
                     or highest diff", i.e. take the bounding box and go out on whichever
                     axis gives the most clearance
    WHAT IT BUYS     a CONSTANT, ENGINE-COMPUTED distance to a known fixed point. The engine's
                     figure is 3D yards at mean error 1e-5 over 1,758 samples (ROUTER:107),
                     so it is an INDEPENDENT check on our own arithmetic - which is redundancy
                     in the real sense: a second instrument, not a second copy of the first.
    ⚠⚠ THE 'COST' THE BENCH RAISED HERE WAS ALREADY RULED, and re-raising it was the
                     error. `driver_use_case_target.md` §1, Battlewrath verbatim: **"No
                     'give back' mechanism: if anything else sets the tracker meanwhile it
                     wins, by our logic (REINFORCEMENT, NEVER ARBITRATION) and by
                     construction (last write)."** And `driver_scoping.md:175` carries
                     **set supertracker** as a ruled ACTION among the fifteen. ★ So the pin
                     is a product SURFACE, not an incursion, and there is no contest to lose:
                     we write, anything else that writes wins, we write again next stage.
                     ⚠ The bench inherited `COA_Landmarks`' occupy/release contract - which
                     is precisely what ROUTER:84's own sentence warns against, *"a product
                     difference to make DELIBERATELY, not to inherit"* - while quoting that
                     sentence. Scoping closed 2026-08-17; this was settled before the item.
    ★ AND IT STRENGTHENS THE PARK rather than qualifying it. Under reinforcement-never-
                     arbitration a parked pin is just another write, and §1's DEATH LOCATION
                     POINTER is already the same mechanism - on death write the reader's own
                     position, on alive write the route's lure again. A parked reference is
                     that shape with a FIXED target.

#### 2 · `GetUnitSpeed` — it EXISTS, and it is UNMEASURED IN MOTION

    attested   census × 3 (`GetUnitSpeed = "function"`), and `task_unitstate.lua` already
               calls it - `speed = try(GetUnitSpeed, "player")` at :110 and :426
    recorded   every sample in `20260817_161324_797__unitstate.lua` reads **speed = 0**

⚠ **So it exists and returns a number; whether it returns a USEFUL number in motion is
unmeasured** — the probe sampled standing still. ★ That is a cheap gap: the call site already
exists, it needs samples taken while moving.

★★ **And it bears directly on the throttle.** The scheduling bound above is an ASSUMPTION about
how fast the player could close a distance. A true speed reading replaces the assumption with a
measurement — which removes a tunable from the driver rather than adding one to get wrong.
⚠ `task_unitstate`'s own design note is the reason to trust it if it reads: the probe is built so
*"the fields ARGUE WITH EACH OTHER, so a wrong reading has somewhere to show up"* — `IsSwimming`
against `GetUnitSpeed` against `IsFalling`.

⚠ Both are RECORDED, not proposed. The park point is a product decision about the player's quest
arrow; the speed probe is a measurement nobody has taken.

### ★★★ THE DISPOSITION FRAME (Battlewrath, 2026-08-20) — and where it already lands

> *"Test what is being built. And if it is a editor or a driver question. If it's a driver it
> shapes what needs exporting, which I think was the first ask. If it's a editor need, it lives
> in the files we ship as a part of that function. Still not user facing."*

★★ **It COMPOSES with a discriminator already ruled rather than competing with it.**
`driver_data_model.md` §A2.8 splits on **who DEFINES a value** — config we control never goes on
the wire, run-derived must. His splits on **who CONSUMES the capability**. Two axes, three
outcomes:

    driver-consumed + run-derived    →  TRAVELS in the export
    driver-consumed + config          →  ships in the addon, not on the wire
    editor-only                       →  ships in the addon, NEVER crosses the wire at all

⚠ **And "still not user facing" is the property that makes the third row safe**: an editor-only
capability is shipped code with no authoring surface, so it cannot leak into the author's model
of what a route IS. That is the same law as the two side tables the driver never opens.

### ★★ MEASURED: THE EXPORT SHAPE DOES NOT MOVE UNDER EITHER ANSWER

Every field in `contract.lua` (§405) classified against **his** definition of the driver — *match
POS against constraints, then call functions*:

    gate         4     mapID · rid · stage · step
    address      2     bid · cid
    constraint   5     posX · posY · posZ · r · band
    what-next    3     nextType · nextArg · trigger
    call         3     sense · action · arg
    UNCLASSIFIED 0

★★★ **No desk machinery is in the contract** — no segment state, no interpolated z, no `v_max`,
nothing that exists to reconstruct a fixed-cadence recording. The contract was written from
§A1's record shape, and it turns out to contain exactly his five roles and nothing else.

⟶ **So the export is already scoped to the driver's needs, and the first ask is answered.**
Whichever way editor-vs-driver falls, `contract.lua` and `fixtures_route.lua` stand unchanged.

### ⟶ WHAT IS ACTUALLY BLOCKED, narrowed

    NOT blocked   the export shape (§405) · the contract · the fixtures · what needs exporting,
                  which was the first ask
    BLOCKED       the RULE's port to Lua (P3 / A11.2) - and only the parts whose SHAPE depends
                  on the answer: whether the driver reproduces `walk.py` whole (segment,
                  interpolated z, v_max) or implements the five roles above and is graded on
                  outcomes at the ruled radii and cadence.

★ **So the question to test is narrower than it looked at the top of this item**: not *"what does
the driver need"* in general — the contract answers that — but **"which of `walk.py`'s machinery
is a REQUIREMENT of the driver, and which is the desk's answer to a problem the driver does not
have (a fixed-cadence recording it cannot re-sample)."**

⚠ Bench read on that framing only, not on the answer: the five roles are what the RECORD carries,
and the record was derived from §A1 before this conversation started. That is corroboration by
independent route rather than a bench opinion.

---

## RI-36 · WHO APPLIES THE PREFIX BOUNCE — `Arm`, or the caller that builds the flight list?

**Filed by the Addons bench, 2026-08-20 (§429). ⚠ A DESIGN FORK WITH V2 CONSEQUENCES**, not a
blocker: P5 is built and green either way.

### THE INSTANCE, on screen

`rule.lua` gates on **mapID only**, and that is correct — A11.2a says *"the gate: same mapID,
tested FIRST"*, and a sample carries no `RID`, `Stage` or `Step` to test against:

    function Rule.Gate(sampleMapID, nodeMapID)
        return sampleMapID ~= nil and sampleMapID == nodeMapID
    end

`sensor.lua`'s `Arm(list)` takes **whatever list it is handed** and applies no prefix bounce.
⟶ So today the four-part gate is applied by nobody, because nothing yet builds the list.

### THE FORK

    A   THE CALLER GATES.  The flight list is built pre-gated and `Arm` receives only admitted
        records. ★ Fits *"It's a flight list. Not dynamic."* exactly — fixed once armed.
        ⚠ But `Stage` ADVANCES during a run. Under A the driver must RE-ARM at each stage
        change, which is a lifecycle event nothing has specified.

    B   THE SENSOR GATES PER POLL.  The whole route is armed once and `Poll` bounces on the
        prefix before the geometry. ⚠ Survives a stage advance with no re-arm — but it makes
        the armed set a superset of the live set, so "armed" and "eligible" stop being the
        same thing, and the in-set has to say which it holds.

★ **V1 does not choose between them.** Stageless means every node continues, so A and B are
indistinguishable until stages land. ⚠ **Which is exactly why it is worth answering now rather
than at the moment the difference first bites** — by then there is a built lifecycle to unpick.

### WHAT THE BENCH IS NOT DOING

Not building either. ⚠ The gate has no live consumer yet (nothing constructs a flight list), and
*the burden is on the bench artefact — existing is not a reason to ship.* ★ Recorded now because
the RULING arrived now, and the model row (§A1.4a) that carries it should not have to guess at
its own consumer.

## RI-35 ✅ DRAINED 2026-08-20 · A11.4b SAYS `R` AND `BAND` ARRIVE AS INDEXES. RI-22 SAID THEY ARE NUMBERS.

**RI-35 DRAINED (Battlewrath, 2026-08-20), verbatim:**

> *"Yes. Indexes is complete. User pick. R 5 the lowests. 2.5 above the lowest offered."*

    O  YES - snapshot at arm is the intended reading. THE MENU IS CLOSED; the user PICKS
       from it; the store holds the NUMBER (12a stands unchanged).
    ✗  the index is NOT a live lookup the driver performs · R does NOT go below 5 · the band
       does NOT go below 2.5
    ✓  R's offered list floors at 5 · **band's list ALSO floors at 2.5 and runs UPWARD** -
       2.5 is the minimum and the default at once · A11.4b's index framing is finished
    →  A11.4b (headstone) · #3 §A3b 12a · A10.3e

### ★★ AND MOST OF IT WAS ALREADY ON DISK - the bench filed a question half-answered

⚠ **`R = 5` was already ruled**, in RI-34: *"R = 5 IS THE FLOOR IN THE PICKER DROPDOWN"*
(`Reconcile_inbox.md:1508`, Battlewrath, same day). And 12a already said *"the choice is a
LOOKUP"* - which is the menu. ★ So RI-35 asked about a mechanism whose two halves were
recorded in two different files, and the bench read one of them.

⟶ **What is genuinely NEW is the word "complete": the offered set is CLOSED.** That is what
makes an index well-defined at all, and it is why both readings of the ruling converge - a
closed menu the user picks from, whose chosen VALUE is what the store keeps. ★ Under either
reading `sensor.lua` is unchanged: it receives numbers and snapshots them.

### ⟶ WHAT THIS SETTLES FOR THE DRIVER: nothing moves, and that is the useful outcome

`sensor.lua` already takes numbers off the record and snapshots them at arm. **The ruling
confirms the built shape rather than redirecting it.**

⚠⚠ **AND THE LANE WAS CORRECTED THE SAME DAY.** Battlewrath: **"read a table per value" is on
the picker side. The sensor its self will have absolute values by the time it reaches it.
Defined in the BID:CID or BID for that POS of the node.*★ So A11.4b's requirement does not
relocate INTO the driver — it was never the driver's. `R` and `Band` are CHARACTERISTICS of the
node, carried at `BID:CID` beside `POS`; the lookup happened once, at authoring time.
⟶ The bench had re-aimed the requirement at the node record to keep it alive on this side.
**The snapshot it justified is right; the justification was borrowed from another lane.** Its
warrant is A11.3's *"running inventory of the RESOLVED position(Parameters)"* — a snapshot in
his own words. ★ Same fault-shape as the band misparse above: **taking a true sentence and
finding it a home on the side I happened to be building.** ⚠ And it does NOT hand the driver a
validator: the author's door is a dropdown, so R ≥ 5 is enforced by the OFFERING, not by a
guard - the Analyst's contrary claim was already struck in RI-34 as a scope fault (reading
`setReach`'s bare `tonumber` and concluding the minimum was unenforced everywhere).

### ⚠⚠ THE BENCH READ THE BAND RULING BACKWARDS - corrected by Battlewrath, same day

The ruling reads *"2.5 above the lowest offered"*, and the bench took it as **"2.5 sits above
some lower offer"** — concluding the band list extended BELOW 2.5, and filing the unnamed
floor as owed to A10.3e. ❌ **Wrong. It parses as "2.5 [and] above [is] the lowest offered":
2.5 IS the band's floor, and the list runs UPWARD from it.**

✅ **So nothing is owed, and the two pickers have the same shape:** an offered list with a
ruled minimum — **R floors at 5, band floors at 2.5** — enforced by the OFFERING rather than
by a guard in the driver.

★ And the correct reading is the one that agrees with everything already on disk: 12a makes
2.5 the DEFAULT, RI-22 made the band **upward only** because *"our data points are captured
from the floor level"*, and 2.5 covers the measured jump apex of ~1.64. ⚠ **A floor below 2.5
would have been the one value in the design that pointed downward** — the bench built a gap
out of a misparse and did not check it against a single one of those.

### ★★★ THE LESSON THIS ITEM ACTUALLY CARRIES - a doc that flagged its own dependency

A11.4b wrote *"whether the EDITOR stores an index or a number is RI-22's open question and
this does not answer it."* ★ **That is a correctly-written row.** It named its dependency, in
its own text, at the point of use. ⚠ **And it still went stale, because nothing reads flags.**
A dependency recorded in prose is a note to a human who happens to be looking at that line -
it is not a link anything can traverse when the depended-on item drains.

⟶ **Third instance this week of a note that became false without being touched** (RI-34's
`MAX_CLOSING_SPEED` line, §424's stale floors, this). *A grep finds moved words; it cannot
find moved load.* ★ The candidate countermeasure - **when an RI drains, sweep for rows that
NAME it** - is mechanical and cheap, and is banked as a tooling seed rather than built on the
strength of one item.

---

### ⬇ THE ITEM AS FILED, kept whole - A11.4b SAYS `R` AND `BAND` ARRIVE AS INDEXES. RI-22 SAID THEY ARE NUMBERS.

**Filed by the Addons bench, 2026-08-20 (§425, building P5). ⚠ REPORTED, NOT RESOLVED** —
`DRIVER_BASIS.md`: *"if two governing docs disagree, the LOWER number wins and the
disagreement is REPORTED, not resolved by the builder."*

### THE TWO TEXTS

    #3   driver_data_model.md 12a      "the STORE holds the number, not the menu index"
         contract.lua (§405)           `r` and `band` are both typed "number"
    #11  driver_sense_acceptance.md    A11.4b: "`R` and `Band` reach the driver as INDEXES
         A11.4b                        into its own config table"

⟶ **3 < 11, so the build took the number.** `sensor.lua` snapshots the node's values at arm.

### ★★ AND A11.4b DISCLAIMED ITS OWN PREMISE — the disagreement is a TIMING artefact

A11.4b carries this scope line verbatim:

> *"⚠ This is the driver's side only; whether the EDITOR stores an index or a number is
> RI-22's open question and this does not answer it."*

★ **RI-22 then answered it.** The row was written correctly, against an open question, and
was left standing when the question closed. ⚠ **Nothing in A11.4b's text changed when RI-22
drained** — the same shape as RI-34's `MAX_CLOSING_SPEED` note: *a grep finds moved words, it
cannot find moved load.* **Third instance this week, and the first where the doc had
explicitly flagged its own dependency.** The flag did not help, because nothing reads flags.

### ⟶ WHAT THE BENCH BUILT, so the ruling knows what it is amending

A11.4b's TEST was *"arm, then break the config table; the pass still runs on the values it
resolved."* With numbers there is no config table to break, so that test is **vacuous** —
which would have been a green row proving nothing.

★ **The REQUIREMENT survives its mechanism: nothing may read a table per sample.** With
numbers on the record, the thing that can still be re-read is **the node record itself**, and
holding a live reference to it is the same per-sample lookup wearing another shape — worse,
because the parameters can then change *underneath a run*. So `Sensor.Arm` **snapshots**, and
`smoke_sensor` arms on a node, then moves it and inflates its radius; a reference follows and
a snapshot does not. Mutation confirms the row bites (`M3`).

### THE QUESTION FOR DESIGN

1. **Is "snapshot at arm" the intended reading of A11.4b now that indexes are gone?** The
   bench believes yes and has built it, but the row no longer says what it tests.
2. **Should A11.4b be re-worded, or headstoned and replaced?** ⚠ The bench will not rewrite
   an acceptance row's text — that is the fault the reconcile machine exists to prevent.
3. ★ **Is there a class of A11 rows with the same dependency?** A11.4b is the one P5 walked
   into. A row that names an open RI is a row whose premise can expire silently, and the
   bench has no way to find the others except by building into them one at a time.

## RI-34 ✅ DRAINED 2026-08-20 · THE POLL FLOOR MOVES TO 0.1 — and the divisor with it

**RI-34 DRAINED (Opus 5 Analyst, 2026-08-20).** ⚠ Stamp added §422 per the file's own
convention - the heading's tick and the body's "CONFIRMED AND EXTENDED" are both invisible
to `grep "RI-[0-9]* DRAINED"`, which is what this file tells every reader to run. The
outcome below is unchanged; only its READABILITY to the convention is.

**RI-34 CONFIRMED AND EXTENDED 2026-08-20 (Opus 5, Analyst). ✅ THE FLOOR IS 0.1, AND IT IS
NECESSARY BUT NOT SUFFICIENT — `MAX_CLOSING_SPEED` IS THE OTHER HALF AND IT BINDS HARDER.**

★ **The arithmetic confirms rather than proposes, exactly as filed**, and it survives the more
conservative figure: the bench used 50.6 yd/s (the 0.2 s runs); the corpus also holds **56.9
yd/s** (the 1 Hz runs, inbox §RI-33 §4). The conclusion holds under 56.9, so the answer is not
sensitive to which figure is picked. FLOOR must be `< 2R/v` = **0.176 s** at 56.9 — 0.1 gives
1.76× margin; **0.2 fails by a factor of 1.14.**

### ★★★ HOW IT WAS CAUGHT — and it was not caught by the doc pass

Battlewrath, 2026-08-20: **"What flagged this is that we landed on 0.1 needed for 5 R on a
point. They reported the spec as 0.2."** ⟶ A live conclusion collided with a written spec.

⚠⚠ **AND THE SPEC THEY READ BACK WAS MINE, FROM AN HOUR EARLIER.** A11.2f had no floor in it
at all before the catch-up pass — the number lived in the asklist, and I PROMOTED it into the
acceptance brief as spec while fixing the row's reason. ★ The bench's finding said *"the row's
ANSWER may still be right; its REASON is spent"*, and **I audited the reason and never audited
the answer.** I inherited the scope of the report — the same fault, one level up, as A11.2f
inheriting `30` from COA_Landmarks without re-checking its premise.

★★ **BOTH NUMBERS WERE IN ADJACENT ROWS OF THE SAME EDIT AND I NEVER MULTIPLIED THEM.** A11.2a:
R = 5, samples through the centre. A11.2f: a 0.2 s floor. `5 × 2 < 50.6 × 0.2` was sitting there.

⚠⚠ **THE LIMIT THIS EXPOSES IN THE RETIREMENT-GREP DISCIPLINE (RI-33's lesson, filed the same
day): A GREP FINDS MOVED WORDS. IT CANNOT FIND MOVED LOAD.** Nothing in A11.2f's text changed
when the rule narrowed, so no search could surface it — and yet the narrowing is exactly what
broke it. Under segment the floor was a COST setting (finer = more phantoms, coarser = fewer);
under point-only it became a CORRECTNESS setting (coarser = missed beacons). **Same number, new
job, no textual trace of the change.**

⟶ **SO THE DISCIPLINE GAINS A SECOND HALF.** When a rule narrows, the grep is not enough:
**re-derive the CONSTANTS the rule now leans on, rather than re-citing them.** Ask what each
constant is now load-bearing FOR, not whether it still reads correctly.

★ And the general form, which is why this is worth the space: **consistency checking finds rows
that disagree with a moved premise; it cannot find a row that is consistent and wrong.** Only
working the mechanism does — which is what "5 R on a point" was.

### ⚠⚠ BUT THE FLOOR ALONE CHANGES NOTHING, AND THIS IS THE FINDING

The filing says the two constants *"multiply rather than substitute"*. ★ Measured, it is
stronger than that: **against a fast approach the floor does not move the failure by a single
yard.** Simulating the ruled schedule `nextIn = max(FLOOR, (dist−R)/MAX_CLOSING_SPEED)` over
every approach distance to R = 5:

    FLOOR   MAX_CLOSING   does any approach skip R=5 entirely?
    0.20        30        SKIPPABLE at 50.6 and 56.9 yd/s
    0.20        57        SKIPPABLE at 50.6 and 56.9      ← floor fixed, still broken
    0.10        30        SKIPPABLE at 50.6 and 56.9      ← constant fixed, still broken
    0.10        57        ✅ safe at every measured speed  ← the only safe cell

★★ **The two failures are DIFFERENT and each constant owns one:**

    the APPROACH   a poll far out schedules a long wait. At 60 yd the schedule is
                   (60−5)/30 = 1.833 s, and 56.9 yd/s covers 104 yd in that time — the
                   player is 44 yd PAST the beacon before the next sample. ⚠ The floor is
                   a MINIMUM and this failure is in the MAXIMUM, so the floor cannot see it.
                   ⟶ Fixed only by MAX_CLOSING_SPEED ≥ the fastest real closing speed. The
                   proof is exact: with `MCS ≥ v`, travel `v(d−R)/MCS ≤ (d−R)`, so the next
                   sample lands no nearer than R — the approach can never overshoot.
    the CROSSING   once a sample lands at the boundary, the player must not cross the
                   DIAMETER before the next one. ⟶ Fixed only by the floor: `v·FLOOR < 2R`.

⟶ **ONE DECISION, NOT TWO: both constants move together, or neither does anything.**

    POLL_MIN            0.20  →  **0.10**              his word, confirmed by the arithmetic
    MAX_CLOSING_SPEED     30  →  **100** (= TELEPORT_VMAX)  ✅ settled - see below

⚠⚠ **MY "≥ 57, 60 SUGGESTED" WAS WRONG — WITHDRAWN 2026-08-20, same day.** Battlewrath:
*"I can tell you how fast a reaper charge is. Not what we will ever see."* ★ He is right that
any value set from the CORPUS MAXIMUM is a bet on the fastest ability that will ever exist on
this fork, and 60 loses that bet cheaply: **measured, MCS = 60 is unsafe at 100 yd/s** — a speed
the desk itself classifies as travel.

★★★ **WHAT THE CONSTANT ACTUALLY BUYS, which is the question he asked: PERMISSION TO SLEEP.**
It is a CPU dial and has no other job. Larger = shorter sleeps = more polls = safer. So it
should not be set from what we have SEEN; it should be set from **the fastest thing we are
OBLIGED to treat as movement** — and the project already ruled that number.

    minimum MCS safe to TELEPORT_VMAX (100 yd/s)      95      measured
    ⟶ MAX_CLOSING_SPEED = TELEPORT_VMAX = 100                 above it, with margin

    cost at 100, a 60 yd run-in at 7 yd/s     37 polls over 7.9 s  =  4.7 polls/s
                                              the 0.1 s floor applies from 15 yd out

⟶ **The throttle's speed assumption and the desk's travel ceiling become ONE constant, and they
should be: both answer "what is the fastest thing we must treat as movement?"** Above it, the
desk already says not-travel; below it, the schedule is now provably safe at every speed.

★ **AND NO DYNAMISM IS NEEDED** (his other option). `GetUnitSpeed` is dynamic and measured
(`ROUTER`), but reading it would only save polls in the region where polls are already cheap,
and it cannot predict a charge that has not started yet. **Build from need: the fixed value is
safe to the ruled ceiling, so the dynamic version buys nothing.**

⚠ **THE UNTESTED HALF, named rather than assumed:** 4.7 polls/s is cheap in ARITHMETIC — the
rule is a handful of ops per armed node. What is NOT measured is the cost of
`GetCurrentPlayerPosition()` at that rate. ★ Macro-testable in minutes, exactly as `GetUnitSpeed`
was. If it is expensive, the dial moves down and the safe ceiling moves with it.

★ **Nothing is blocked either way** — no shipped constant carries it, `rule.lua` takes no
cadence, and the throttle belongs to the sensor, which is not built.

### ★★ AND THE PROVENANCE OF `30` EXPLAINS ITSELF ONCE YOU LOOK

`landmark_design.md`'s constants table: **`MAX_CLOSING_SPEED` 30 yd/s — *"~29 is a 310% flying
mount, so this has headroom"*.** ⟶ The number was chosen for **COA_Landmarks**, in the open
world, where the fastest closer is a flying mount. The driver inherited it whole.

⚠ **A dungeon has no flying mounts, and it does have charge abilities.** So the constant is not
wrong — it is *correct for the addon it was chosen for and wrong for the one that inherited it*,
which is the SAME inheritance fault as segment (RI-33): a decision carried across a boundary
without its premise being re-checked on the other side. ★ It also confirms `ROUTER`'s existing
ruling from the other direction — *"tolerable there (a late arrival notice) and not for a driver
(a missed beacon)"* — by naming WHY the two differ: **different worst cases, not different
tolerances.**

⚠ **`landmark_design.md` IS NOT STALE AND MUST NOT BE "FIXED".** Its 30 and its 0.20 are that
product's own, correct for it. ★ It is the clearest case yet of why a retirement grep yields a
WORK LIST and not a defect list.

### ★★★ HIS REFRAME, AND IT IS THE RIGHT ONE — SLEEP IS A DISTANCE QUESTION

Battlewrath, 2026-08-20: **"Permission to sleep is distance. Not speed. (Though ability to close
distance to the point within the sample rate is the failure.) At 0.1 time into the point is
quicker than any unit moves in the game."**

★★ **Verified, and it relocates the guarantee.** At the 0.1 s floor and R = 5, skipping a beacon
needs `2R/T` = **100 yd/s — which the desk already calls not-travel.** ⟶ So **the FLOOR is the
safety guarantee, and `MAX_CLOSING_SPEED` is not a safety parameter at all.** It only decides
**when we are allowed to stop polling at the floor** — an optimisation, exactly as he says.

⚠ Re-read against this, the failure my simulation found was never a floor failure: at MCS = 30
the player was 60 yd out, slept 1.833 s and covered 104 yd. **The floor never applied, because
sleeping is what happens when you are far away.** The bug was sleeping too long, not sampling
too coarsely.

★ **AND THE HANDOFF IS EXACT, which is why `MCS ≥ v` is self-correcting rather than lucky.**
A charge from his 35 yd range, MCS = 100:

    v = 7.0 yd/s    30 samples, ends 4.59 yd    INSIDE
    v = 30.0        7 samples,  ends 3.20 yd    INSIDE
    v = 56.9        3 samples,  ends 4.88 yd    INSIDE
    v = 100.0       1 sample,   ends 5.00 yd    INSIDE - exactly on the boundary

⟶ The proportional zone always hands off AT the boundary, never past it. **So the constant is
better stated as the distance it produces: `MCS = 100` ⟺ "poll at the floor from 15 yd out."**
★ Same arithmetic, and the number a human sets becomes YARDS, which can be judged, instead of a
speed ceiling for abilities that do not exist yet, which cannot.

### ⚠⚠⚠ AND THE CONSEQUENCE HE DID NOT ASK FOR: R's MINIMUM IS NOW LOAD-BEARING

His claim holds **at R = 5.** It does not hold below it — the floor's guarantee is `2R/T`, so:

    R = 5    10 across    skippable only above 100 yd/s   = TELEPORT_VMAX, safe
    R = 2     4 across    skippable above  40 yd/s        ⚠ ORDINARY CHARGE SPEED

★★★ **And the three numbers are ONE relationship, any two fixing the third:**

        R_min  =  v_ceiling × POLL_MIN / 2  =  100 × 0.1 / 2  =  5

⟶ **R = 5 is not a convention. It is exactly what the floor implies.** Nobody derived it that
way; it arrived as a taste value and turns out to be the arithmetic one.

✅ **AND IT IS ALREADY HELD: R = 5 IS THE FLOOR IN THE PICKER DROPDOWN** (Battlewrath,
2026-08-20). ⚠ The Analyst filed it as an owed guard on the strength of `setReach`
(`routes.lua:1471`) being a bare `tonumber` — **reading the SETTER and claiming the MINIMUM was
unenforced, without checking the door the author actually uses.** Struck. ★ The same scope fault
that produced the "SetRow has zero callers" and "MigrateRIDs is test-only" corrections: a claim
about everywhere, made from one place.

⟶ **So nothing is owed here. What the derivation adds is only the WHY:** 5 was picked as a
sensible smallest radius and turns out to be exactly `v_ceiling × POLL_MIN / 2`. ★ Worth keeping
because it ties the picker's floor to the poll floor — **if either moves, the other must.**

### ✅ ON THE TELEPORT COINCIDENCE — true, and more fragile than it reads

The filing says the skip speed at a 0.1 floor is 100.0 yd/s, *"which is `TELEPORT_VMAX` exactly
… by two independent routes."* ★ Verified: `TELEPORT_VMAX = 100.0` (`walk.py:490`), and the
derivations really are independent — one is geometry (`2R/T` = 10/0.1), one is the desk's
judgement about what counts as travel.

⚠ **But it holds at R = 5 and moves with R.** At R = 6 the skip speed is 120 and they part. So
it is a pleasing property of the ruled MINIMUM radius, **not a structural meeting** — worth
noting so nobody later cites it as the reason the floor is principled.

### ✅ THE EVIDENCE-INVERSION READ IS ACCEPTED, and it corrects something of mine

The bench is right that `audit_C`'s *"0.2 s SILENT / 1 Hz DETECTED"* was measured **with segment
in the rule**, that a phantom needs a chord to sweep, and that under point-only a coarse cadence
can only under-detect. ⟶ **The direction of that comparison inverts, and the w5 two-rates and
cut-corner blocks want re-running under point-only.** Their current output is sound for the rule
they measured and misleading for the one that ships.

★★ **AND IT LANDS ON A11.2a, WHICH I WROTE AN HOUR EARLIER.** That row argued point-only was
sufficient from *"7.1 samples through the centre at run speed"* and topped its cost table at a
*"30 yd/s ceiling"*. ⚠ **Run speed is the MEDIAN and 30 is not the corpus ceiling — 56.9 is.**
At 56.9 the failure is not the 20% rim-clip the row named; it is a **whole beacon skipped**. I
graded the median and called it sufficiency. ⟶ A11.2a now states both constants as
PRECONDITIONS rather than as background, so the narrowing cannot be read as unconditional.

_Filed 2026-08-20 (§419) by the **Addons bench** at Battlewrath's ask: **"Can you land those in
the inbox so we have something the state against. And it moves to 0.1 I believe to bring the 5
yard min (10 across) into tolerance."** ⚠ Filed as the STATE, not as a question - the value is
his and the arithmetic below confirms it rather than proposing it._

### ★★★ HIS REASONING, MEASURED — and it closes on a number worth seeing

Under **point + band + gate** (A11.2a, narrowed 2026-08-20) there is no chord to catch a pass
the samples missed. So the floor's whole job is: **the player must not be able to cross a
beacon's DIAMETER between two samples.** With the ruled minimum radius of 5 (10 across) and the
fastest legitimate movement measured at **50.6 yd/s** (RI-33 §4):

    floor     travel/sample     R=5 (10 across)               speed needed to skip R=5
    0.20 s    10.12 yd          SKIPPABLE by 0.12 yd          50.0 yd/s
    0.10 s     5.06 yd          covered, 4.94 yd of margin   100.0 yd/s

⚠ **At 0.2 s the floor is already defeated** — 50.0 yd/s is what it takes, and 50.6 is what the
corpus holds. The margin is NEGATIVE by 0.6 yd/s.

★★★ **And at 0.1 s the number that defeats it is 100.0 yd/s — which is `TELEPORT_VMAX` exactly.**
The desk set that threshold as *"a real charge must survive, and only an instantaneous
relocation must not"*. ⟶ **So at a 0.1 s floor, the only thing that can skip an R=5 beacon is
something the desk already classifies as not-travel.** The floor and the teleport threshold meet,
by two independent routes.

### ⚠⚠ AND THE EVIDENCE FOR THE OLD FLOOR ARGUES FOR A TRADE-OFF THAT NO LONGER EXISTS

`audit_C_evidence_bounds.md` records **cut-corner: 0.2 s SILENT / 1 Hz DETECTED** and two-rates
**0.2 s 12/18/18/18 vs 1 Hz 13/16/16/18** — finer sampling apparently detecting LESS. ★ Read
correctly, 0.2 s is RIGHT there: the fixture is a 90° turn with the beacon INSIDE the corner, and
the desk's own line is *"the COARSER path detects MORE, because a cut corner is a PHANTOM HIT."*
1 Hz's extra detections are transits that never happened.

⚠ **But all of it was measured WITH SEGMENT IN THE RULE.** A phantom needs a chord to sweep;
`first_visits` interpolates between samples. Under point + band + gate there is no chord, so a
coarse cadence can no longer over-detect — **it can only under-detect.**

⟶ **The direction of the whole comparison inverts.** Under the old rule coarse was dangerous
because it INVENTED hits; under the new one coarse is dangerous because it MISSES them, and finer
is strictly better with no phantom cost. ★ **The evidence for the cadence was gathered against a
rule that has since been narrowed**, which is why it reads as arguing against the move.

★ If the floor lands at 0.1, `walk.py w5`'s two-rates and cut-corner blocks are worth re-running
under point-only — their current output is sound for the rule they measured and misleading for
the one that ships.

### THE STATE — every site that carries the number

    driver_sense_acceptance.md    A11.2f          ★ THE LIVE ROW - "POLL_MIN floor of 0.2 s"
    driver_analysis_asklist.md    :59-62          the formula and all four constants
                                  :298 :391       prose that reasons FROM 0.2
    audit/audit_A_prior_work.md   :29             COA_Landmarks' shipped values
    audit/audit_B_model_delta.md  :141            the shipping-constants line
    audit/audit_C_evidence_bounds.md :20 :46      the throttler constants
                                  :51 :72 :73     the two-rates and cut-corner evidence rows
    audit/s9_teleport_guard.md    :106-108        "the 0.2 s floor stands on its own footing"

⚠ **`MAX_CLOSING_SPEED = 30` TRAVELS WITH IT** in three of those, and it is the same shape of
error one level along: the corpus measured legitimate closing at **56.9 yd/s**, so a schedule
dividing by 30 under-polls whenever the player is faster than the constant admits. `ROUTER`
already rules it *"tolerable there (a late arrival notice) and not for a driver (a missed
beacon)"* — and a floor of 0.1 does not fix it, because the two multiply rather than substitute.

    IMPACT
      on disk now      NOTHING in code - no shipped constant carries the floor yet. `rule.lua`
                       is pure and takes no cadence; the throttle belongs to the sensor, which
                       is not built. ★ Which is why moving it now is free and moving it after
                       the sensor is not.
      shipped guards   none break. ⚠ And none would CATCH a wrong floor either - nothing polls
                       yet, so the number is currently prose in SEVEN files - and prose is the only
                       thing that can carry a constant nothing executes.
      criteria         A11.2f is the row that moves · the two-rates and cut-corner evidence
                       rows want re-running under point-only · A11.9d's witness cadence
                       ("1 Hz is enough, never on the fine poll") is unaffected
      does nothing to  the rule · the contract · the fixtures · the park

---

# THE SETTLED SET — the MIGRATED items, flattened

⚠ **NOT "every drained item" — corrected 2026-08-20.** ★ The invariant, verified by complement:
**an item is EITHER a full entry above OR a row here, never both.** A drained item keeps its
prose in this file until that prose moves to `history/Reconciliation_inbox_drained.md`, and it
gains a row here at that moment. ⟶ 22 rows below; RI-19 · 22 · 24 · 26 · 27 · 29 · 30 · 31 ·
32 · 33 · 34 are drained ABOVE and await migration. **Nothing is unaccounted for — but do not
read this index as the whole set.**

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
