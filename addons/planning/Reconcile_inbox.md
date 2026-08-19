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

_**Status lives on the ITEM, never in a header** (bench finding 2026-08-19: two conventions were
live — RI-1..8 inherited "drained" from the section, RI-9.. carried their own stamp — so a hand
header compensated and went stale within a day, on RI-18). **The one convention: an item is DRAINED
when its text begins `RI-N DRAINED (who, date)`; an item without that stamp is OPEN.** Derive,
don't read a list: `grep -n "RI-[0-9]* DRAINED" Reconcile_inbox.md` gives the drained; every other
`## RI-` heading is open; the next number is the highest present + 1. Sections are PLACEMENT only
(open items sit here, drained items move below) — the stamp is the truth if they ever disagree._

---

## RI-19 · THE GOLDEN WATCH — `walk.py check` cannot reach W1 or W5

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

## RI-20 · THE PEER AUDIT — three things our peers have that the working model does not

_Filed 2026-08-19 (§378) by the **Addons bench**. Banked at Battlewrath's ask: *"I'd bank them in
the inbox. Then we move onto the research so we have a picture to decide against."_ ⚠ **So these
are NOT ready to drain** — the second half of his sequence (industry prior art) is the picture
they are meant to be decided against, and it is not written yet. Filed now so the findings do not
live only in a commit message while that runs.

_Source: `audit/peer_data_stores.md` (§377), measured read-only from the installed client and from
`dependencies/Ace3`. Sequence: `driver_sense_acceptance.md` A11.1a — **"before that, we also model
the data stores of our PEERS through audit. And then look to PRIOR WORK that is industry
standard."** The line in A11.1a is the WORKING MODEL these are measured against, not the design._

### What the audit CORROBORATED (recorded, nothing to rule)

Reached independently by teams who never spoke to us:

    · gates in the KEY PATH, not tested per record            GatherMate2
    · IDs, never names, in the payload                        GatherMate2 · WeakAuras
    · a positional DELIMITED line for transfer                GatherMate2 - literally
      `string.format("%d:%s:%s:%d", zone, id, nodeType, nodeid)`, our shape
    · reader and DATA as separate addons                      four teams: GatherMate2 ·
      Details · Skada · WeakAuras

★ And the argument FOR banning free text from the line turned up as a worked example in source we
ship: **AceSerializer needed a VERSION BUMP to fix an escape collision** — byte 30 encoded to `~^`,
read as escape-plus-terminator (ticket 115, the comment is still in `dependencies/Ace3`). A
fifteen-year-old general-purpose serialiser, used by the whole field. A line with no free text
never enters that class.

### The three that need deciding

**P1 · NO VERSION ON OUR LINE.** WeakAuras prefixes `!WA:2!` and its own comment says *"N is
encode version"*; GatherMate's wire line has no version and no checksum. ⚠ Our line begins with
content (`MapID:RID:...`), so an old export and a new one are indistinguishable at read time.

    a  a version token FIRST, before any field
    b  no version - the format is frozen and a change is a new file kind
    c  version lives in a header/manifest beside the lines, not on each line

★ **And WA's distinction is worth taking whole regardless of which:** the ENCODING version and the
CONTENT version are different questions that rev at different rates. WA answers only the first on
the wire.

**Bench read (overturnable in a word): (a), plus the encode/content split said out loud.** The
reason is not symmetry with WA — it is that GatherMate is the peer that *never had to rev*, and we
already know ours will (eleven gaps are open in `driver_data_model_proposition.md` §5). ⚠ The
bench has no view on the token's SHAPE; that is the research half's to inform.

**P2 · NOTHING BOUNDS A COORDINATE.** GatherMate CLAMPS x,y at 0.9999 so a packed field's width is
guaranteed — refuse the overflow at the door rather than hope.

    a  bound POS/R/Band at input, with a stated range and a rejection
    b  no bound; the format is delimited so width never matters
    c  bound only if the representation (G5) turns out to be fixed-width or packed

⚠ **We cannot copy their packing and the reason should be recorded so nobody tries:** GatherMate's
x,y are NORMALISED map fractions (0..1) with a known bound; ours are WORLD coordinates — unbounded,
signed, needing more precision. **The architecture transfers; the packing does not.**

**Bench read: (a), and it is nearly free.** It is the same door as the reserved-character
rejection Battlewrath already ruled (*"nice-ness breaks down when you can break the reader"*) —
applied to a number instead of a character. ⚠ But it wants a stated RANGE, and the bench does not
know what a legitimate world coordinate's bounds are on this client. **That is a measurable fact,
not an opinion — the bench can go and get it if wanted.**

**P3 · NON-FINITE: REJECT, OR REPRESENT?** `driver_sense_acceptance.md` A11.2e has the DRIVER
reject NaN and Inf. AceSerializer REPRESENTS them (`serNaN` · `serInf` · `serNegInf`).

    a  the FORMAT rejects too - a non-finite never reaches a line
    b  the format REPRESENTS, the driver rejects on read
    c  A11.2e is the whole answer; the format inherits it and nothing more is said

⚠ **Both peers are right for their own job**, which is why this is a real question and not a
correction: a driver has nothing useful to do with a NaN position, and a serialiser must
round-trip whatever it was handed. **The gap is that our answer is stated for the DRIVER and not
for the FORMAT** — and export/import are the pair that meet a hand-edited file.

**Bench read: (a).** If the format cannot express it, the driver's rejection is a belt over
braces rather than the only guard. ⚠ Weakly held — (b) is what every general serialiser chose, and
the research half may say why.

    IMPACT
      on disk now      NONE. Nothing is built against any of the three; the line is a working
                       model in A11.1a and a proposal in driver_data_model_proposition.md
      shipped guards   NONE break. ⚠ And none would CATCH any of these either - there is no
                       export writer and no import reader on disk yet, which is why this is
                       cheap NOW and expensive after A11.1's contract file freezes
      criteria         A11.1a's line (a version token changes its field list) · A11.2e (P3) ·
                       a new row for the coordinate bound if P2 goes (a)
      does nothing to  the sense rule · W1-W7 · the adaptor · the UI leg · the note tables ·
                       the reader/data split, which the audit CONFIRMED rather than questioned

★ **Relation to RI-18.** These are three MORE gaps beside that item's six, from a different
source: RI-18's came from reasoning about our own shape, these from measuring other people's. ⚠ No
overlap and no conflict — P1/P2/P3 touch fields RI-18 never raised.

⚠ **NOT READY TO DRAIN** until the prior-art half lands. Filed to bank, not to ask.


---

# DRAINED — every item below carries its own `RI-N DRAINED (who, date)` stamp; the records named in it hold the ruling

    RI-1  DRAINED (Battlewrath, 2026-08-18) — THIRD WAY — referenced in the store, owned in the pane. §91 survives; sharing a note
          across children is a later re-point. → acceptance A4.2 names the world; G1 unblocked.
    RI-2  DRAINED (Battlewrath, 2026-08-18) — THE SPLIT — `ReachOf` raw (nil = author set nothing); consumer resolves ±2.5. UI: a
          slider the author TICKS to change, with light text ("changes the height of
          detection"); the SAME control shape for the two radii — radius:listen (come here) and
          radius:sense (found). → acceptance A1.3 reworded; model §3 defaults carry the UI note.
    RI-3  DRAINED (Battlewrath, 2026-08-18) — "walk" has meant two things and they separate: the author IN THE WORLD hitting their
          waypoints = TEST DRIVE → its own suite entry INSIDE Dungeon Run (option b), an
          extension of the editor's play pacer; an ASSURANCE piece (offline replay, the py walk,
          per-node fitment) = the test/debug/diagnostic suite. → acceptance A6.1 home = test
          drive; W-tests stay the diagnostic side. `/dr walk` is not revived.
    RI-4  DRAINED (Battlewrath, 2026-08-18) — BEST WORKING MODEL (his "unsure exactly"): a node carries created-from (origin data
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
          flat form. (2)/(3) `sense` = the KIND (reach here + distance · ~~boss engaged/killed ⟨name⟩
          · falling · in combat~~ [⚠ SUPERSEDED (RI-15 settled, 2026-08-18) · ⚠ SCRUBBED (RI-17, 2026-08-18): boss is the action word; states are gates]); there is NO firing field — time lives in WHAT I DO as an
          open/close pair, DURING (whilst on) | WHEN OFF, plus IF SEEN (once | every) as its own
          control; G15 (`while`) IS that pairing. Advance / set are ACTIONS in what-I-do, per tab;
          no separate "what happens next"; a beacon-level next exists only for a childless beacon
          (with children the beacon is not in play — its FIRST CHILD acts as the beacon: lure +
          note; last delete; tabs return to the parent; completion SHED to any child; taste: the
          parent is the biggest node, children are the discrete placeable ones). Position is the
          NODE's, not on the pane. → model §1 (beacon), §2 head; acceptance A2.5 (new); A1.1's
          pure-accessor change UNBLOCKED; `sense`'s shipped VALUES and the A3 block STAND (RI-15:
          the values, not the field — boss moved off `sense` to the what-I-do row's condition).

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

    RI-7  DRAINED (Battlewrath, 2026-08-18): `activate` GONE with goTo — it stored another
          node's identity (outward pointing on the mechanical test); the ordinal sub-ratchet is
          the hand-off. Model §2 box struck; scoping §117 superseded by steps (BASIS). If a
          satellite ever must jump the chain: `set step N` (a number). No code deleted.
    RI-8  DRAINED (Battlewrath, 2026-08-18): `onRamp` GONE in the same commit — a second
          mechanism for one fact. Entry = childless beacon → the beacon; with children → the
          FIRST CHILD (acts as the beacon; the lure; can be step 1); then whatever the author
          laid out fires (ordinal 1 sensed / a satellite first). Co-location for the rare
          separate-lure case. Custody comment, chip, 3 interface rows, 2 functions removed.
          **His framing of what survives: UPDATERS and ORDINAL — and both beacons and children
          have both now** (a beacon: ordinal on the stage line, or a non-ordinal updater =
          recovery/boss; a child: ordinal = step, or non-ordinal = satellite/updater).
    RI-9  DRAINED (Battlewrath, 2026-08-18): **BUILD IT — I-2. S8 REVERSED by him as a
          reversal, dated:** notes are IN v1. S8 gets the supersession note; A4 proceeds as
          written (RI-1: referenced in store, owned in pane); G1 stays in the standing order
          (before the test drive); model §5's G1 correction is itself corrected back.

    RI-10 DRAINED (Battlewrath, 2026-08-18): SEPARATE SHELF — the route note plane, its own
          table under the personal one (§60); export takes it whole, never the personal plane
          (structural, no tag). WORDS: "personal note" / "route note" — "reader" rejected (a
          reader is anyone reading either, author or consumer). LABEL the author sees: "Route
          instructions" (one adaptor row: term `route note` → label "Route instructions";
          "note" reads as a dev-note slot on first read); "Personal note" stays; ghost text
          "Instructions for the player running the route". PERSONAL NOTES SCOPED (model §4b): a player using
          both addons; per-place, role/class-specific experience; shown in a DESIGNATED SLOT
          beside the route note during runs, by position; may push the tracker by explicit act,
          the route overwrites; how routes become lessons learned; off the authoring path; never
          travel. → acceptance A4.2 reworded (the Analyst's wrong-shelf owned); model §4b;
          target §4 two slots. **G1 UNBLOCKED.**

    RI-11 DRAINED (Battlewrath, 2026-08-18): (d) NOW — the check_rects canvas is a RED, not an
          option (acceptance A9.6). a/b/c DEFERRED TO THE OVERHAUL: "argumentation over UI
          placement is out of place when we know it needs an overhaul." Until then the checker
          NAMES the three hand-placed controls as unverified (never counts them clean).
    RI-12 DRAINED (Battlewrath, 2026-08-18): (b) — A4.2 reads "closed except the travel half";
          the two-tables assert stays as the structural guard; the travel assert lives in A8.5
          when export lands. The roster's covered count tells the truth.
    RI-13 DRAINED (Battlewrath, 2026-08-18): NOT OPEN — RI-10 already ruled the label "Personal
          note"; the OWED adaptor row is implementation of a drained ruling. Relabel when the
          personal-note pane work happens; ghost text "Your note — stays with you, never
          travels." No reversal.
    RI-15 DRAINED (Battlewrath, 2026-08-18) — NEITHER option; the class dissolved rather than
          got a better name. **SENSE is the LOCATION and the behaviour whilst in its R** (on me
          · touched me) [⚠ SCRUBBED (RI-17, 2026-08-18): I had written "here · falling · in combat · alive · mounted —
          only what the client reports about the player" — a generalisation; state predicates are
          GATES in the wider logic, not senses]. **Boss
          is NOT a sense** — "while (duration) is the arming to listen to CLEU, and boss is the
          CLEU". **WHAT I DO = "when the player is here": a STACK of rows, each an ACTION
          (give note · advance · set stage · set supertracker · /say · open list) with an
          optional CONDITION (on boss ⟨name⟩ ~~engaged |~~ killed; default immediately)** [interim; RI-17 grammar], the
          whole stack scoped by the sense — "what you do only has meaning when you're in the
          location to do it." Boss child reads: sense here (during) → advance, on boss ⟨name⟩
          killed; listener armed only while the sense holds; a wipe re-arms, nothing advances
          on leaving. → model §2 (reframed-again block) + §3 defaults; A3 heading + A3.2 + NEW
          A3.5 (armed only while sense on) + migration by the A8.4 hook; adaptor boss rows =
          the row's condition; A10.3a/A10.3d; A10.2a corrected (fold the three that survive,
          the rest REPLACED by A10.3). IMPACT moved: `Routes.SENSES` boss pair → the row's
          condition (settable SENSE list is empty until a state sense lands; the registry
          carries family + what it carries; only detectable senses present); SenseOf/
          SetChildSense/ArmsWith re-seated; object.lua's sense dropdown + SENSE_TEXT (RI-16's
          lookup); smoke A3 block reads the new field, same values. (b) OUT — falling waits on
          capture. RI-5's closing clause now reads "the shipped VALUES stand".
          SETTLED (same day, three turns on; interim wording — RI-17's grammar is the form): a row = CONDITION + ACTION + optional INLINE
          STAGE END, every row SELF-COMPLETING (no "then" between rows; the stage tail is the
          only tail and it completes via the entry lure — stale arrow closed); the author's
          condition is KILLED only (engaged = driver witness at most); a kill row DEFAULTS to
          set stage = this beacon's next, ABSOLUTE from the node's own stage (recovery; S6's
          "Boss killed → set:stage(N)"), advance +N beside it; fields depend on the choice.
          → model §2 second block · A3.2 rewritten (+ two mutations) · adaptor `bossEngaged`
          struck · A10.3a. "step" = the ordinal child ("a minor stage, a small gear");
          actions are not steps; the no-ordinal UPDATE type child stays, same as a beacon.

    RI-17 DRAINED (Battlewrath, 2026-08-18) — his four points stand (sense = LOCATION + behaviour
          whilst in R · WHAT I DO states an OUTCOME · the driver holds implementations, the export
          carries a DECLARATION · falling / in-combat / encounter are what a function is CONSTRUCTED
          OF, never a term). The Analyst's generalisation ("falling · in combat · alive · mounted" as
          senses) SCRUBBED across nine files, RI-17-marked. The open piece answered by THE GRAMMAR
          he took from the bench: a row IS one declaration `<sense>:<action>:<arg>` —
          `When on:boss:Gul'dan` · `Seen:Note:<content>` · `When off:…` — stored WHOLE, exported whole, read
          whole ((a), by construction); no separate condition field — the action function carries
          its own condition and completion; fields on the pane follow the action word; the boss
          function's completion with no N = set stage to this beacon's next (recovery). ⚠ OPEN,
          not invented: ~~a sense-word for WHEN OFF~~ ANSWERED same day — WHEN OFF is the third
          sense-word (When on · Seen · When off; "for pressure off we need to define what that
          action is") · where an explicit
          N rides. → model §2 (grammar block) · A3.2 (+ two mutations) · adaptor `boss` row ·
          A10.3a. IMPACT moved: `child.sense`+`child.boss` → one row triple; SetChildSense/
          SetChildBoss → one setter; ArmsWith reads the row; A8.4 hook migrates; smoke A3 block
          reads the triple, same values.

    RI-18 DRAINED (Battlewrath, 2026-08-18/19) — THE DATA MODEL. Settled in conversation with the
          bench and carried into the records: the line is IDENTIFIERS AND NUMBERS ONLY (arg = an
          ID ref); NAMES in an address-keyed index · NOTES as `NoteID : content`, side tables the
          driver never opens; `Stage:Step` COMPOSED at export; reject the reserved character at
          any input; "tables where they keep the line read light, composing where that is the
          correct solution"; the export a PROJECTION of the store; an import is a SIBLING route,
          never a successor. Q1 A8.6 REWORDED (exported form = a projection; criterion unchanged)
          · Q2 (b) reconcile-and-tell · Q3 Next:N one field two positions, said · Q4 fixed
          positions · Q5 order asserted at ingest, never depended on by the pass · Q6 YES —
          "in-line is an ID pointer; the free-hand text is derived from a lookup table; that
          keeps the instruction line predictable and repeatable": route notes stored
          `NoteID → content` in the EDITOR too; A4.2 reworded, its "which world" mutation
          ANSWERED (referenced); migration via A8.4's hook. SEQUENCE recorded: DESIGN picks the
          data model up AFTER a peer data-store audit and prior-art review. → A11.1a/A11.1c ·
          A8.6 · A4.2 · adaptor `routeNote` · model §2 · basis. IMPACT moved: routes.lua
          SetRouteNote/noteKey · store.lua RouteNoteTable · smoke A4 block · the no-free-text
          smoke (new) · the NAMES table (new, with A8.4's migration walking it — G9).

    RI-16 DRAINED (Battlewrath, 2026-08-18) — (a) YES: the RUNTIME LOOKUP lands BEFORE the
          first fold — one lookup function over one CONSTANT table on the UI side (`code →
          user`), pass-through on a miss; ROLE_TEXT + SENSE_TEXT retire into it; A5.1/A5.2 smoke
          rows filled. Not a deviation (A10.2a orders folds among themselves — the brief's
          omission, Analyst's). (b) fails A5.3 outright. (c) provenance = a tooling item that
          FOLLOWS (generate the constant from driver_adaptor_table.md; A5.3's 1:1 check is the
          guard until then). → A10.2 PRECONDITION line; A5.1/A5.2 unchanged in wording.
          Same turn, on the row model: A CHILD COMPLETES WHEN ALL ITS ACTION TABS HAVE
          COMPLETED — a CONSTANT, no control (note fired + kill pending = not complete; the
          ordinal does not hand off). → model §2 · NEW A2.7.

    RI-14 DRAINED (Battlewrath, 2026-08-18): keep the HEADSTONE in routes.lua; the acceptance
          composition lives ONCE at the CALL LAYER, outside routes.lua, swept by the smoke
          (A1.2's invariant covers every site that goes through it). No source-text scanner.
          `<Noun>Of` accessors stay pure; a composer IN routes.lua would be the branch renamed.

_Items above leave entirely once every record named carries them._
