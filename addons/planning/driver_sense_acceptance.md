# V1 DRIVER — SENSE acceptance (A11.x) — the test brief the bench builds towards

_Analyst, 2026-08-18, against the bench's `driver_sense_proposition.md` (§371). Battlewrath: "first
is a sense check — that we can perform sensing, as that's the pre-condition to killing the boss."
**V1 = given a flat list of targets and the player's position, say which targets the player is
IN.** Nothing else. Governed by `DRIVER_BASIS.md`; the RULE's own acceptance already exists as
`driver_walk_acceptance.md` W1 (structural, all PASS on the desk) and W7 (port fidelity) — this
brief does not restate those rows, it points at them and adds what V1 needs beyond them. Each row
names its mutation; a green without its mutation is UNMUTATED. The Analyst tests under lua51 on
landing._

---

## THE BAR — "we can perform sensing" defined so it can be tested

    sensing   =  the Lua rule is BYTE-EQUAL to the desk on the same fixtures (W7.1) · it reads a
                 FLAT LIST and nothing else (installable without the editor — proven by loading
                 it without the store) · it answers by ADDRESS · it costs nothing when nothing is
                 armed · the branches the corpus cannot reach are graded anyway (W7.2)

## A11.1 · THE ROW SHAPE — a declared CONTRACT, not a convention
- **A11.1a** The flat row is declared in ONE file both sides cite (producer = the flattener when
  it exists; consumer = the driver): the LINE below (the bench's field list — id · mapID · world x,y,z · r · band · ordinal — is
  the same content in the ordered form). The contract file states which coordinate space
  (WORLD, never MAP xy — `map.lua:46`'s two sizes) and that `ordinal` may be nil (its absence is
  V2's recovery signal). Bench read on Q1 ACCEPTED: **build to the shape; the flattener arrives
  with a consumer to satisfy** — V1 is graded against a HAND-WRITTEN fixture list in that shape.

    THE LINE (Battlewrath, 2026-08-18 — best working model; one line kind, gates first).
    **SEQUENCE (Battlewrath to the bench, 2026-08-18): "I'll have DESIGN pick it up. And before that, we also model the data stores of our PEERS through audit. And then look to PRIOR WORK that is industry standard — information storage and transfer with a read instruction set isn't a unique issue."** So the line below is the WORKING MODEL the audits are measured against, not the design.

        MapID:RID:Stage:Step:BID:CID:POS:R:Band:Next:N : Sense:action:trigger:arg
        └────────── node (character) — gates first, identity, place, what-happens-when-done ──────────┘ └────── tab ──────┘

      · one line PER TAB; a node with four tabs writes its node fields four times — node fields
        are READ FROM THE NODE'S FIRST LINE, a later line that differs is TOLD at ingest
      · sub-fields by comma (POS = x,y,z WORLD; Band = up,down); an EMPTY slot means absent
        (Step blank = update type; Stage blank = the stageless recovery beacon once §366 lands;
        N blank for Next = Step / Stage) — positional, every field holds its slot
      · `arg` is LAST — and it is an ID REFERENCE, NOT free text (Battlewrath, same day, with the
        bench: "even the Arg can be IDs, so it knows which to present to the user"). ★ NO FREE TEXT
        ANYWHERE ON THE LINE: identifiers and numbers only — so there is nothing to escape and no
        reserved character to defend on the line; the reject-at-input rule ("nice-ness breaks down
        when you can break the reader") applies to the TABLE writers. `trigger` = One time | Every time
      · TWO SIDE TABLES the driver never opens (RI-18): NAMES — MapID · RID:Name · RID:BID:Name ·
        RID:BID:CID:Name; NOTES — RID:BID:CID:NoteID : content (the one free field, LAST after its
        key). "We accept TABLES where they keep the line read light; COMPOSING where that is the
        correct solution." `Stage:Step` are COMPOSED at export from the live tree (properties, never
        on a stored key — A8.1's law at the export boundary); the export is a PROJECTION of the
        editor's store, deliberately not 1:1
      · `Next:N` is ONE field in TWO positions, SAID so in the format; the writer emits the N slot
        empty for Step / Stage rather than omitting it (RI-18 Q3)
      · RECONSTRUCTION (his): where the node fields match, the tab falls out — "same match and
        populate": import groups lines by the node prefix and populates the tabs; it never
        depends on line ORDER, only on the match (findings §2 import guarantee)
      · ingest asserts the order and builds the index (mapID → stage → ordinal buckets, the
        no-step bucket always read); the 1 Hz pass walks the bucket, never the lines
      This closes the findings' O1 (positional line) · O2 (order asserted at ingest, not depended
      on at runtime) · O3 (one line per tab, address repeated).
- **A11.1c (RI-18; checkable, currently unasserted)** NO FREE TEXT ON THE LINE: a smoke holds that
  no line token is anything but a number or an identifier, and goes red the day a label is put back
  into a payload. This is the isolation property made checkable rather than asserted.
- **A11.1b** The driver reads ONLY that shape: no `ChildrenOf / ParentOf / AcceptanceOf / StageOf`,
  no `Store.*`, no `Routes.*` — the same law that forbids a child holding a reference
  (`routes.lua:509`) forbids the driver reaching for one.
- **mutations** feed a row in MAP xy → the fixture's known-world target does not fire (the
  +15% error is the tell) · reference `Routes.` from the driver file → a grep on the file fails
  · drop `ordinal` from the contract → the contract check fails (a field added later is a format
  change).

## A11.2 · THE RULE — the desk's, inherited whole
- **A11.2a** Point + segment + band, ported from `walk.py` (`point_fire` / `segment_fire`); the
  band applied at the INTERPOLATED z of the closest point, never at an endpoint. Graded by
  **W7.1** (byte-equal to the desk on the same fixture rows at the same cadence) and **W7.2**
  (the synthetic branches: mapID straddle W1.3 · non-finite · the clamp W1.9 · the gap bound
  W1.10). Bench read on Q3 ACCEPTED: **BOTH point and segment** — a V1 that only points cannot be
  compared byte-for-byte to the desk (W1.5: segment ≥ point on every fixture).
- **A11.2b (S5)** The FIRST sample after arming uses POINT — there is no previous sample to
  segment from. Test: arm, feed one in-region sample → it fires; the segment path is not entered.
- **A11.2c (S6)** A stationary player (degenerate segment, prev == cur) falls back to POINT; no
  division by zero, no NaN produced.
- **A11.2d (S3)** A target in another mapID never fires however close the numbers are; a
  segment straddling a mapID change is discarded, never bridged (W1.3).
- **A11.2e (S10)** Non-finite input is REJECTED, and in Lua that is two tests — `type(v) ~=
  "number"` AND `v ~= v` — with NaN and inf as SEPARATE fixtures (W7.2). Rejected = the sample
  is dropped and the previous sample is NOT updated (so the next sample takes the point path).
- **A11.2f — the cadence (Q2), bench read ACCEPTED as the working model:** 1 Hz, because the
  golden is at 1 Hz and W7.1's byte-equality may REQUIRE it; a faster driver is a different
  experiment (W4.1's constant: capture at 1 Hz, do not go coarser). Recorded, not ruled —
  Battlewrath's word if it changes.
- **mutations** feed the same fixtures at 2 Hz → W7.1's byte-equality FAILS (which is the proof
  the cadence is load-bearing) · veto at an endpoint's z instead of the interpolated z → W1.7's
  walkway fixture fires where it must not · bridge the straddle → W1.3 fails · remove the `v ~= v`
  test → the NaN fixture passes through and the row bites on its own message.

## A11.3 · PURITY — the driver holds no route state (S7) and answers by ADDRESS (S2)
- **A11.3a** Given the same list and the same samples it answers the same, in any order of
  targets, with no memory between calls beyond what the CALLER passes in (the previous sample;
  for `while` mode, the in-set — W1.8's hysteresis is state the caller owns and hands back).
  Test: shuffle the target list → identical output; call twice with the same inputs → identical.
- **A11.3b** Every report names the target by its ADDRESS (`RID:BID:CID`), never by index into
  the list. Test: shuffle the list → the same addresses report; an index would move.
- **mutations** keep a module-level "last sample" → the double-call test diverges · report an
  index → the shuffle test fails.

## A11.4 · COST — nothing armed, nothing running (S9)
- **A11.4a** No persistent `OnUpdate`: the accumulator exists ONLY while armed (`capture.lua`'s
  own discipline — "the handler exists ONLY while recording"). Disarm → the frame's OnUpdate is
  nil. Test under the harness: arm → handler set; disarm → handler nil; two-way, every time.
- **mutation** leave the handler set on disarm → A11.4a fails on its own message.

## A11.5 · THE READOUT — what V1 can honestly report (S8, CORRECTED)
- **A11.5a** ⚠ The proposition's S8 imports STAGE semantics into a stageless V1: `skip` and
  `false_advances` are stage-level results (W7.3's columns exist because a stage can be advanced
  wrongly). V1 has no stage, so V1's readout is: **per sample, the set of addresses the player is
  IN; per target, its FIRST-HIT sample index** — the per-target half of W7.1's byte-equality. The
  stage timeline (W5.3) and W7.3's `hit · skip · false_advances` are graded at V2, when a stage
  exists. `stage` is not a result at either level.
- **A11.5b** The readout SHAPE is what the test-drive remote (A10.5) will display later; V1
  reports in it, it does not build the surface.
- **mutations** report `stage` → fails · report by index → A11.3b fails · claim `skip` at V1 →
  UNMUTATED (there is no stage to skip).

## A11.6 · ISOLATION — installable WITHOUT the editor, PROVEN not asserted (Q4 + findings §O4)
- **A11.6a** The driver's smoke loads the driver file(s) and the contract fixture list ONLY — no
  `store.lua`, no `routes.lua`, no `promoter.lua`, no `COA_DungeonRunDB` global — and V1's rows
  pass in that environment. ★ This is the capability test the findings file says has never been
  demonstrated ("no consumer has ever read ONE route without the store that holds all of them");
  it costs one smoke and proves the whole of routes.lua:509's law for the consumer side.
- **A11.6b — where the driver lives (Q4):** the bench's read (its own file in `COA_DungeonRun`
  now, structured so that moving it later costs a `.toc` line) is ACCEPTED as the WORKING
  posture; **the SPLIT into Dungeon Routes is a SHIPPING decision — Battlewrath's**, and A11.6a
  is what makes it a `.toc` move rather than a rewrite when he takes it.
- **mutation** make the driver read `Store.RouteTable()` → A11.6a's isolated load fails LOUDLY
  (nil global), not silently.

## A11.7 · THE GOLDEN FIRST — and the blocker
- **A11.7a (A9.5 · REWORDED 2026-08-19 per RI-19 — the stand-in's wording, reviewed and applied by
  the Analyst)** ONE COMMAND runs every body of desk criteria — W1 (the rule's ten structural
  criteria) · W2/W3/W4 (the calibration goldens) · W5 (including W5.6's three golden comparisons)
  — and returns NON-ZERO if any of them moves. That command is hooked to landing. ⚠ The row is RED
  while any body sits outside the aggregate, whatever the bodies report individually — measured
  2026-08-19: all five PASS one by one; W1 and W5 are UNREACHABLE from `walk.py check` (its mode
  gate falls through to W2/W3/W4 only; the docstring's "all three" is honest and the gap is between
  the rows and the aggregate). Was: "the w5 goldens are WATCHED — `walk.py check` (or a sibling)
  runs them" — readable as satisfied by someone remembering to run `w5`, which is the thing the
  row forbids. Test: perturb a w5 golden by one byte → the AGGREGATE reds; run the aggregate with
  W1 deliberately broken → it reds. Which command carries it is the BENCH's choice (RI-19 a/b/c;
  Analyst and stand-in both read (a): `check` absorbs W1 + W5, because the command people believe
  must cover what the rows cite).
- **A11.7b** V1's FIRST green is W7.1's byte-equality (per-target half, A11.5a), not a hand-
  written assertion about a number someone chose.
- **A11.7c — what arms it in V1 (Q5), bench read ACCEPTED:** a function call, exercised by the
  smoke (`arm(list) / disarm()`); A10.5's remote wires to it later. No slash line.
- **mutation** ship the port with the w5 goldens unwatched → A11.7a is RED regardless of W7.1.

## A11.8 · WHAT IS OUT (so nothing is graded that was never asked)
    stages · steps · the ordinal lock-out · recovery · the boss function · CLEU · arming by
    anything but the function call · completion · Next · the remote's chrome · the flattener
    itself (Dungeon Run's list, target §K) · the stageless-beacon gap (§366 — no impact until V2)

## THE BENCH'S BUILD ORDER P1–P6 — accepted as proposed
    P1 watch the w5 goldens (A11.7a) → P2 the row SHAPE as a declared contract + fixture list
    (A11.1) → P3 the rule in Lua (A11.2) → P4 W7.1 byte-equality + W7.2 synthetics → P5 ingest at
    1 Hz, armed/disarmed with no persistent OnUpdate (A11.4, A11.7c) → P6 the readout by address
    (A11.5). A11.6a's isolated smoke sits beside P3, not after P6 — it is cheapest when the file
    is small.

---

## REVIEW LOG
**2026-08-18 — Analyst on the bench's `driver_sense_proposition.md` (§371).** Q1–Q3, Q5 and the
P1–P6 order accepted as the bench read them; Q4 accepted as working posture with the SPLIT left
as Battlewrath's shipping decision. ONE CORRECTION: S8's readout (`hit · skip · false_advances`)
is stage-level — V1 reports the per-sample IN set and per-target first-hit index; W7.3's columns
are V2's (A11.5a). ONE ADDITION the proposition implied but did not name as a test: the isolated
load (A11.6a) — the findings file's unproven capability, provable in one smoke. The proposition
may leave once its behaviours are the rows above.

_How I test: `walk.py check` + the w5 watch, then the Lua smoke under lua51 against the same
fixture rows, byte-compare the emitted per-target first-hit indices to the desk, apply each named
mutation; report PASS / FAIL / UNMUTATED with the observed message._
