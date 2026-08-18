# Reconcile_inbox — the relay for questions that need a ruling

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

_**RI-9 filed 2026-08-18** — a TIE BREAK, and the first item written to a new shape
(Battlewrath): **"tie break with instruction instead of deliberation."** ★ A precedence tie is
already decided by the rule; what is missing is what to DO about the losing side. So the item
states the tie and offers INSTRUCTION LINES — no bench read, no options weighed. ⚠ That is a
different shape from RI-1..8, which were design questions and correctly carried options.

A STATUS block follows it: things that are TRUE now and want an eye, so nobody reconstructs
them from the thread._

## RI-9 · TIE BREAK — `driver_scoping` S8 (#2) says notes are v2; acceptance A4 (#5) says build G1

⚠ **A TIE-BREAK ITEM, not a design question.** Battlewrath: *"tie break with instruction instead
of deliberation."* So this states the tie and the instructions that would break it. **No bench
read, no options weighed** — the precedence rule already decided which side wins; what is missing
is what to DO about the losing side.

### The tie, in four lines from the governing stack

    #1  driver_use_case_target §4    "The arrow … and a note. The pointer is for TRAVEL,
                                      notes are for ACTION."
    #2  driver_scoping S8            "Note actions — OUT OF V1 REGARDLESS; decide for v2."
                                      DECISION (v2): Agreed.        ← Battlewrath's own line
    #3  driver_programmatic_model §2 "say a note (≤ ~200)" sits in the WHAT-HAPPENS box
    #5  driver_authoring_acceptance  A4 · G1 — "G1 UNBLOCKED", with a test

**Lower number wins**, so #2 stands and G1 is v2. ⚠ **RI-1 reconciled into #5**, and a ruling
written into #5 does not overturn a decision at #2 — which is what the precedence rule exists for.

### ⚠ It may not be a conflict at all, and that decides which instruction applies

S8's wording is narrow: it rules out note **ACTIONS** — a child *doing* something with a note.
RI-1 answered a **STORAGE** question — owned or referenced. Those may be different things.

    reads as STORAGE   where the string lives; `Store.NoteTable`; the pane field
    reads as ACTION    "say a note" in the model's what-happens box · A4.1's *"resolves to
                       exactly one string AT RUNTIME"* · the answers line's note slot

### INSTRUCTIONS — pick one line

    I-1  "S8 stands. G1 is v2."              A4 is marked v2; G1 leaves the standing order;
                                             the bench takes the test drive (A6) next.
    I-2  "S8 is superseded. Build G1 whole." S8 gets the note saying what superseded it and
                                             when; A4 proceeds as written.
    I-3  "Split it: storage in v1, actions   A4 splits — the store + pane field land now; the
          in v2."                            what-happens entry and the runtime resolve wait.
                                             ⚠ Then A4.1's wording moves, because "resolves at
                                             runtime" is the half being deferred.

⚠ **Whichever line comes back, ONE record has to change** — either S8 or A4. They cannot both
stand as written, and the bench will not pick which.

### IMPACT

    nothing shipped   G1 has no code. This is the last item in the standing order before the
                      test drive, so the cost of getting it wrong is a build, not a rework.
    the order         under I-1 the bench goes straight to A6; under I-2 or I-3 G1 comes first.
    A4's mutation     "two children pointing at one referenced note" only exists under I-2/I-3.

---

## ★ STATUS — what the project needs inspected (2026-08-18, bench)

_Not questions. Things that are TRUE now and want an eye on them, listed so nobody has to
reconstruct them from the thread._

### Standing red, unscheduled

    A9.2   12 rotted mutation anchors. 286/298 bite; the 12 are all in older map/art specs.
           Ten `?? ANCHOR found 0x`, two `~~ WRONG`. ⚠ mutate.py's own header calls this the
           bad failure mode: they sit in the file LOOKING LIKE COVERAGE. A chip exists.
    A8.2   `SetChildIcon` / `IconOf` still have NO CALLER in any pane. A setter with no door
           reads as a finished feature to whoever finds it next.
    A9.3   one term left on the adaptor's owed list: `ratchet` (`object.lua`). ★ Down from
           three - `satellite` was reworded, `on-ramp` went with its feature.
    A9.5   W7's golden compares on every `walk w5` run, and nothing schedules the port. It
           will say so if it rots, but only if someone runs it.

### Ruled with no code, and no criterion for the code

    A8.3   the addressed store (`At / AddressOf / GetAt / SetAt`) — DESIGNED, and the Analyst
           agreed to GRADE IT BEFORE IT IS BUILT. No criterion written yet.
    A8.5   export trims to what import will mint — ruled RI-4, no code.
    A8.6   the flat form is the stored form — ruled, no code. ⚠ It corrects §0b, which is in
           a GOVERNING file (#4) and still argues the other form at its head.

### The model is ahead of the code, deliberately — but the gap is now large

    A8.7   measured by grep across routes.lua + object.lua:
             tabs                     0   model §2: "EACH TAB IS A TRIGGER"
             all|any combination      0   "offered from v1"
             `once | while`           0   G15 — and RI-5 says there is NO firing field,
                                          so this may already be answered rather than owed
             STATE senses             0   in combat · falling/landed · alive/dead · mounted
             `scene entered`          0
           ⚠ `falling` is the one the SKIP needs (model §2b) and CAPTURE DOES NOT RECORD IT.
           That is a capture-spec item nothing currently owns.

### Wording that will not survive contact

    A2.5   RI-5 said its wording "tightens to the order above" (stage lure → child 1 → what
           the author laid out). Not yet done.
    A7.2   is in the acceptance and NOT in the smoke's roster. The roster reads 7 of 18
           uncovered and does not know A7.2 exists.
    `wire` the adaptor row is OPEN — must name a SHAPE, never a firing. §3b fails `trip`.
    `updater` in `ROLE_TEXT`, flagged as close to technical, unchanged pending the naming pass.
    S3     the naming pass has NOT run, so every `user` word in the adaptor is provisional.

### Bench hygiene

    20 commits unpushed. Tree clean, full gate green: 19 smokes · check_targets ·
    check_interface (4 checks, 103/103) · check_landing · check_harness · check_escapes ·
    walk check.

---

_**RI-7 and RI-8 filed 2026-08-18**, both out of A2.6's cut and both asking the SAME question
in Battlewrath's words: *"a step of removing 'A beacon/child can point outwards'"* — so the
test is **does it point outwards**, not *does it resemble `goTo`*. ⚠ Each names the RECORD IT
WOULD CORRECT, because the answers exist and it is the documents that are behind. RI-1..6
drained below. Next item takes RI-9._

### ★★★ THE TEST IS MECHANICAL, and the bench measured it (§338)

Battlewrath, on why outward pointing goes:

> *"The point outwards creates a lot of issues for making sure there isn't a stale pointer. So
> the model is only a stage / step start can announce itself in the stage change instructions. As
> those are dependable for sensing. So there is no dependence and their self completing."*

★ **So the test is not a judgement about resemblance. It is one question with a checkable answer:
DOES THIS FIELD STORE ANOTHER NODE'S IDENTITY?** Every field a node carries, measured:

    goTo        `child.goTo = targetId`     ★ THE ONLY ONE. routes.lua:1175
    onRamp      `child.onRamp = true`       a BOOLEAN. A self-flag - it names no one
    ordinal     a number                    its own position
    sense       a vocabulary value          its own kind
    role        a vocabulary value          its own
    action      a vocabulary value          its own
    setStage    a number                    a stage, not a node
    outcome     a number                    a stage, not a node
    boss        a NAME string               ⚠ COPIED from the run, not a reference to it.
                                            §61 dropped the run back-reference, so this is
                                            a value the driver hands to `listen()`. It
                                            cannot dangle because there is nothing to
                                            dangle from - PLACE carries, EVENT does not,
                                            one level up.

★★ **ONE FIELD CREATES THE ENTIRE STALE-POINTER SURFACE, and three functions exist to police
it.** `BrokenLinks` is literally `c.goTo and not GoToTarget(b, c)` — it has no other purpose.
`Cycles` walks `while c and c.goTo`. `Heads` computes chain heads from the same links. **Remove
the one field and all three stop being able to ask a question**, which is why the model says they
*"go with it"* rather than becoming redundant.

⚠ And the author-facing cost was already shipping: `object.lua:462` renders **"target is gone"**.
That string is the stale pointer reaching a person.

### ★ What replaces it, in his words: announcement, not reference

> *"a stage / step start can announce itself in the stage change instructions. As those are
> dependable for sensing. So there is no dependence and their self completing."*

    BEFORE   A holds B's id. B moves or dies. A is stale, and something must NOTICE -
             hence three checks, a red pane string, and an auditor that resolves links
             at export (routes.lua:795).
    AFTER    a step ANNOUNCES ITSELF at the stage change. Nothing holds anyone's id, so
             nothing can be stale, so nothing needs checking. **Self-completing.**

★★★ **And it settles RI-8 on evidence rather than on my read.** `onRamp` stores `true` — it
cannot go stale, because it names no one. Under the mechanical test it is not outward pointing,
and the (a) reading holds. ⚠ Its *comment* still quotes the custody language and that is stale
either way.

★★ **It also strengthens RI-4 downstream.** §21a worried that a re-mint would have to rewrite
every instruction's owner field, and a missed one would point at the wrong node silently. **If no
field holds another node's identity, that failure mode does not exist to worry about** — which is
part of why *"only the RID re-mints"* is safe rather than merely convenient.

---

## RI-7 · Does `activate` retire with `goTo`? *(gates A2.6's cut)*

**Why it is asked.** A2.6 retires `goTo` — *"removed absolutely, not parked"*. Battlewrath's
framing when I cited the terms: *"They are foundationally different and a step of removing 'A
beacon/child can point outwards'."* ★ So the test for anything else is **does it point outwards**,
not *does it resemble `goTo`*.

**⚠ The record says both things, in ONE governing file.**

    model §1b:66-79    "the advisory's `activate` was goTo IN A NEW WORD (history)"
    model §2:144       "│  activate <child> (hand the arrow on)  · nothing (stay)  │"
                       - still in the WHAT-HAPPENS-NEXT box
    model §2:111       "advance / set stage / activate / return-to-maxSeen happen ONCE,
                       at the beacon"
    model §3b:225      `activate` is on the naming law's FAIL list - ours, never the
                       author's - which is a statement about the WORD, not the feature
    scoping §117       "Child→child = activate; deaf until told to listen" - RULED, and
                       scoping is GOVERNING #2, ABOVE the model at #3

★ **`activate` is not implemented.** `Routes.ACTIONS = { "supertrack" }` and nothing in any
`.lua` mentions it. So this is a record question, not a deletion.

    (a) IT RETIRES with goTo   §1b is the newer statement and says so outright. Then
                               model §2's box and §2:111 are STALE and want correcting,
                               and scoping §117's "child→child = activate" needs a note
                               saying what replaced it (the ordinal sub-ratchet).
    (b) IT SURVIVES            "hand the arrow on" is a different act from goTo's "point
                               at B while sensing at A" - it hands OFF at satisfaction
                               rather than splitting the two. ⚠ But under steps, step n
                               satisfied → step n+1 listens ALREADY, by ordinal. So what
                               would `activate` add that the sub-ratchet does not?
    (c) IT IS THE SUB-RATCHET  renamed. Same behaviour, and `activate` is the word §3b
                               fails - so the feature stays and the term goes.

**The bench's read: (a) or (c), and they differ only in wording.** ★ Under steps, order is *"the
ORDINAL ALONE"* and *"no edge to draw"* — an explicit hand-off is a second way to say what the
ordinal already says, which is the thing §91 refused for `goTo` at the beacon level.

**RECORD TO CORRECT ON THE DRAIN**

    model §2:144       the WHAT-HAPPENS-NEXT box - strike `activate <child>` or say what
                       it means under steps
    model §2:111       the same word in prose
    scoping §117       "Child→child = activate" - GOVERNING #2, so it outranks the model.
                       ⚠ If it stands, (a) cannot be right and §1b is the stale one.
    §3b:225            unaffected either way - a FAIL word is a fail word

**The ANALYST's read (2026-08-18) — marked as the Analyst's**

    (a) = (c): RETIRE. Beyond "no code" and "the sub-ratchet already hands off": under the
    bench's own mechanical test `activate <child>` STORES ANOTHER NODE'S IDENTITY — it IS
    outward pointing, goTo's species, not a resemblance. The record contradiction is the
    Analyst's: model §2's box kept it when the "next" drop-down was withdrawn (STRUCK now,
    same day); scoping §117 "child→child = activate" was the Analyst summarising the advisory
    as configs — steps supersede it; it wants the NOTE, not a re-ruling (BASIS carries steps).
    ★ One door to leave marked before the box is struck: if a SATELLITE ever needs to jump
    the chain (funnel → step 3), the action is `set step N` — a NUMBER, like `set stage N`,
    passes the test. Not activate, not v1; noted so no one rebuilds an id-holder to get it.

**IMPACT**

    nothing shipped     `activate` has no code. This deletes no line.
    A2.6's CUT          ⚠ blocked only in the sense that I will not delete the target
                        dropdown while a governing file still offers "activate <child>"
                        as a next - the two would leave a pane control with a documented
                        purpose and no mechanism.
    the adaptor         no row either way; it never reached a pane.

---

## RI-8 · Is `onRamp` "pointing outwards", or is it a nomination? *(same cut)*

**Why it is asked.** Same test. `onRamp` lets a beacon's CHILD be declared the entry point for the
stage — one node saying *another* node is where you arrive.

    routes.lua:1246   SetChildOnRamp - EXCLUSIVE, clears the flag from siblings
    routes.lua:1264   OnRampOf(b) - the flagged child, else the BEACON ITSELF
    object.lua        `rampChip`, and the answers line reads "on-ramp X · Y"
    interface/object.md:39, :247, :250   declared, with "come find me"
    scoping §148      "on-ramp/acceptance → the beacon itself when childless"

★ **The bench's read: NOT outward pointing, and the code already shows why.** `OnRampOf` resolves
to a NODE, and that node is then used for ITS OWN position — nobody is pointed at a place they are
not. A childless beacon returns itself. **It nominates which of several selves is the entry**,
where `goTo` said *sense here, point THERE*.

⚠ **But two things make it worth asking rather than assuming:**

    the word           `on-ramp` is on A9.3's owed list already - ours, not the author's
    the CUSTODY prose  routes.lua's on-ramp block quotes *"it's a custody argument of who
                       points at who"* - which is the GRAPH language `goTo` came from.
                       ★ If custody is what is being removed, the comment is stale even
                       if the feature survives.

**Under steps it may also be redundant:** step 1 IS the entry (*"Step 1 = the first child (acts as
the beacon)"*, §1b). If the first ordinal always speaks for the stage, an exclusive flag naming a
different child is a second mechanism for the same fact — the exact shape §91 refused.

    (a) SURVIVES, unchanged   it nominates, it does not point. The word gets a user term
                              at the naming pass.
    (b) SURVIVES, RESTATED    the feature stays, the CUSTODY comment goes with `goTo`.
    (c) RETIRES               step 1 is the on-ramp by construction; an explicit flag is
                              a second way to say it. ⚠ Then `rampChip`, its registry
                              entry and three interface rows go too.

**RECORD TO CORRECT ON THE DRAIN**

    routes.lua on-ramp block   the "custody argument of who points at who" quotation, if
                               custody is retired with goTo
    interface/object.md:39     ":247, :250 - the declared rows, if (c)
    scoping §148               unaffected under (a)/(b); wants a note under (c)

**The ANALYST's read (2026-08-18) — marked as the Analyst's**

    (c) RETIRE, in A2.6's commit. The bench is right that a boolean names no one — but under
    steps `onRamp` is a SECOND MECHANISM FOR ONE FACT, the shape the record refused for goTo.
    **THE ORDER (Battlewrath, correcting the Analyst's first cut, which had it inverted):**
        1  childless beacon        → the BEACON is the entry
        2  with children           → the FIRST CHILD (first created; "acts as the beacon") is
                                     the entry — the lure, the note. NOT "lowest ordinal."
        3  then whatever the author laid out FIRES: ordinal 1 when it is sensed, and/or a
                                     SATELLITE (an update child) if it triggers first — all
                                     down to the author's choice of step vs satellite. No
                                     precedence rule beyond that; no flag.
    An exclusive flag naming a different entry is a second way to say what child-1 + the
    author's layout already say. The custody comment goes regardless.
    ★ **CHILD 1 IS THE LURE, AND CHILD 1 CAN BE STEP 1 (Battlewrath, correcting his own slip):**
    the entry and step 1 are ordinarily the SAME NODE — the lure child carries ordinal 1. Co-
    location is only for the rarer case where an author keeps the lure separate from step 1
    and wants them to fire together: put them on the same spot. "Find the next break" is the
    stage-level lure's ordinary job. Position expresses the intent; no edge, no flag, no
    `activate` (RI-7 confirmed from this side too). Cost: three interface
    rows, a chip, two Routes functions — a REMOVAL, not a parking (A2.6's law). A2.5's wording
    tightens to the order above.

**IMPACT**

    if (a)/(b)   nothing shipped moves. A2.6's cut proceeds around it.
    if (c)       three interface rows, one registry entry, one chip and two Routes
                 functions come out - and the answers line loses a third of its sentence.
    A2.6's CUT   ⚠ NOT blocked. `goTo` can go either way; this only decides whether the
                 same commit takes `onRamp` with it.

---

# DRAINED (2026-08-18, Battlewrath; records reconciled by the Analyst)

    RI-1  THIRD WAY — referenced in the store, owned in the pane. §91 survives; sharing a note
          across children is a later re-point. → acceptance A4.2 names the world; G1 unblocked.
    RI-2  THE SPLIT — `ReachOf` raw (nil = author set nothing); consumer resolves ±2.5. UI: a
          slider the author TICKS to change, with light text ("changes the height of
          detection"); the SAME control shape for the two radii — radius:listen (come here) and
          radius:sense (found). → acceptance A1.3 reworded; model §3 defaults carry the UI note.
    RI-3  "walk" has meant two things and they separate: the author IN THE WORLD hitting their
          waypoints = TEST DRIVE → its own suite entry INSIDE Dungeon Run (option b), an
          extension of the editor's play pacer; an ASSURANCE piece (offline replay, the py walk,
          per-node fitment) = the test/debug/diagnostic suite. → acceptance A6.1 home = test
          drive; W-tests stay the diagnostic side. `/dr walk` is not revived.
    RI-4  BEST WORKING MODEL (his "unsure exactly"): a node carries created-from (origin data
          point) and current; origin is METADATA once not current. On import to another
          author's editor, **ONLY THE RID IS RE-MINTED** — past the RID everything is unique to
          it, so `BID:CID` carries unchanged (no full waterfall). Place carries as current;
          metadata OUTSIDE identity/place (notes, radii, bands, names) SURVIVES; the origin-on-
          someone-else's-data does NOT travel — the import landing becomes the new origin. So
          export-trims governs, the ledger's round-trip law compares against the MINT CONTRACT
          (identity · place · properties), one-door and zero-trust untouched. → DRIVER_BASIS
          positions; ledger §5.9–5.11 want a banner (bench); addressed store / RID may proceed.

    RI-5  DRAINED (Battlewrath, 2026-08-18) — the two thresholds are ACTIONS at distances, not
          sense types. (1) one anchor, two (action, distance) pairs = TWO TABS -> two steps in the
          flat form. (2)/(3) `sense` = the KIND (reach here + distance · boss engaged/killed ⟨name⟩
          · falling · in combat); there is NO firing field — time lives in WHAT I DO as an
          open/close pair, DURING (whilst on) | WHEN OFF, plus IF SEEN (once | every) as its own
          control; G15 (`while`) IS that pairing. Advance / set are ACTIONS in what-I-do, per tab;
          no separate "what happens next"; a beacon-level next exists only for a childless beacon
          (with children the beacon is not in play — its FIRST CHILD acts as the beacon: lure +
          note; last delete; tabs return to the parent; completion SHED to any child; taste: the
          parent is the biggest node, children are the discrete placeable ones). Position is the
          NODE's, not on the pane. → model §1 (beacon), §2 head; acceptance A2.5 (new); A1.1's
          pure-accessor change UNBLOCKED; `sense`'s shipped value set and the A3 block STAND.

    RI-6  DRAINED (Battlewrath, 2026-08-18) — (a) the CID counter stays ROUTE-SCOPED, as the
          code ships. His reason: fewer MISFIRES and less REFERENCING — one global press that
          takes the beacon ID and stamps its running count; (b) would have to look up the
          beacon, count its history, then mint. Identity = `RID:BID:CID`; the full path is
          unique because RID is; only RID re-mints on import (RI-4). No migration for CIDs;
          A8.4 covers the RID alone. Stage/ordinal are properties, never identity; merged-by-
          stage beacons split cleanly because children are referenced through their parent.
          Two beacons on one stage is an authoring collision — TOLD (red "match N"), NEVER
          locked; the driver degrades deterministically and states it (bench). → BASIS
          positions; acceptance A8.4 note; nothing else moves.

_Items above leave entirely once every record named carries them._
