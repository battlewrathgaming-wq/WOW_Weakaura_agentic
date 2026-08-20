# V1 DRIVER — SENSE acceptance (A11.x) — the test brief the bench builds towards

_Analyst, 2026-08-18, against the bench's `history/driver_sense_proposition.md` (§371). Battlewrath: "first
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

        MapID:RID:Stage:Step:BID:CID:POS:R:Band:Next:N : Sense:action:arg
        └────────── node (character) — gates first, identity, place, what-happens-when-done ──────────┘ └────── tab ──────┘


⚠⚠ **SUPERSEDED AS A RECORD SHAPE (RI-25 / governing #12 §A1, 2026-08-19). The line above is
HISTORY — it is the working model the peer audit and the prior-art review were measured against,
and it is kept for that reason only.** The settled shape is **TWO RECORD KINDS**, both keyed by the
address — a CHARACTERISTIC record per node and N BEHAVIOUR records — in `driver_data_model.md` §A1.

⚠ **THIS BRIEF NO LONGER STATES THE RECORD SHAPE; IT CITES IT.** An acceptance brief that restates
what a governing document settles is a second copy that can disagree with the first — the same
fault `routes.lua:112` names for the RID. ★ And the disagreement was not hypothetical: the
tie-break rule (*lower number wins*) would have handed a builder this retired line over #12's two
records, because this file is #11.

~~· one line PER TAB; a node with four tabs writes its node fields four times — node fields are
READ FROM THE NODE'S FIRST LINE, a later line that differs is TOLD at ingest~~ [⚠ RETIRED with the
combined line: under two record kinds a node's fields appear ONCE, so there is nothing to
reconcile and nothing to tell — #12 §A1.4, which retires RI-18 Q2 / proposition G3 outright.]

★ **What A11.1a still governs, and it is unchanged by the split:** the contract is declared in ONE
file both sides cite · the coordinate space is WORLD, never MAP xy (`map.lua:46`) · `ordinal` may be
absent · **no free text anywhere** — identifiers and numbers only, `arg` an ID reference · the two
side tables the driver never opens · `Stage:Step` composed at export · `Next` one field · V1 is
graded against a HAND-WRITTEN fixture list in the settled shape.
      · sub-fields by comma (POS = x,y,z WORLD; Band = up,down); an EMPTY slot means absent
        (~~Step blank = update type; Stage blank = the stageless recovery beacon once §366 lands~~
        [⚠ SUPERSEDED (§385c / RI-23, 2026-08-19): **Step and Stage carry `0`, never blank** —
        *"stage 0 / step 0 is permission to read it"*; `nil` in the STORE, `0` on the LINE, one
        meaning: no gate, always eligible. An empty slot is ambiguous — missing, absent and
        truncated look alike — and is not used for these two]; N blank for Next = Step / Stage)
        — positional, every field holds its slot
      · `arg` is LAST — and it is an ID REFERENCE, NOT free text (Battlewrath, same day, with the
        bench: "even the Arg can be IDs, so it knows which to present to the user"). ★ NO FREE TEXT
        ANYWHERE ON THE LINE: identifiers and numbers only — so there is nothing to escape and no
        reserved character to defend on the line; the reject-at-input rule ("nice-ness breaks down
        when you can break the reader") applies to the TABLE writers. `Trigger` is a NODE field (2026-08-19), not a row field
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
- **A11.2g (RI-25, Battlewrath 2026-08-19) — ONE EVALUATION PER NODE, SHARED BY ITS ROWS.** The
  geometry test runs against the NODE's `POS · R · Band` once per sample, and every behaviour row of
  that node reads the same result. ⚠ **This is correctness, not economy.** RI-16 ruled that a child
  COMPLETES when ALL its action tabs have completed, which requires every tab to agree about the
  same in/out transition; four independent evaluations of one node's geometry are four places that
  can disagree. ★ The two-record split (RI-25) makes the shared evaluation the only expressible
  shape — under one line per tab, each carrying its own copy of `POS`, testing per ROW is the
  natural implementation. **Test:** a node with four rows, fed one sample → the rule is entered
  ONCE and four rows see one verdict. **mutation:** evaluate per row → the count assertion fails,
  and a fixture where two rows straddle the boundary shows them disagreeing.
- **mutations** feed the same fixtures at 2 Hz → W7.1's byte-equality FAILS (which is the proof
  the cadence is load-bearing) · veto at an endpoint's z instead of the interpolated z → W1.7's
  walkway fixture fires where it must not · bridge the straddle → W1.3 fails · remove the `v ~= v`
  test → the NaN fixture passes through and the row bites on its own message.

## A11.3 · PURITY IS THE RULE'S, NOT THE DRIVER'S — and the SENSOR is where state lives

⚠⚠ **REWORDED 2026-08-19 (RI-25, Battlewrath).** ~~PURITY — the driver holds no route state (S7)~~.
The heading said *the driver* and meant *the rule*. His position, dated:

> *"I think it's a part of the driver. The part that completes the function calls and such.
> Basically the stateful sensor. It keeps a running inventory of the resolved position(Parameters),
> and checks against its tab set for completion. Ticking each off as they're met. And keeps open the
> items out of stage, or out of step (for its stage.)"*

★★ **TWO LAYERS, and the split is what keeps both properties.** The RULE stays a pure function and
every purity test below still applies to it unchanged. The SENSOR owns state, and it is INSIDE the
driver rather than in a caller — ⚠ which corrects the Analyst's read of one turn earlier that put it
in "the caller", a phrase that named no owner at all.

    THE RULE      point + segment + band. Same list, same samples, same answer. No memory.
    THE SENSOR    the armed object. Holds the resolved parameter inventory (A11.4b), the
                  in-set, and - at V2 - the per-tab completion ledger. Calls the rule.

- **A11.3a** The RULE answers the same given the same list and the same samples, in any order of
  targets, with no memory between calls beyond what its CALLER — the sensor — passes in (the
  previous sample; for `while` mode, the in-set). Test: shuffle the target list → identical output;
  call twice with the same inputs → identical. ⚠ The test is run against the rule directly, not
  through the sensor, which is what makes it meaningful.
- **A11.3b** Every report names the target by its ADDRESS (`RID:BID:CID`), never by index into
  the list. Test: shuffle the list → the same addresses report; an index would move.
- **A11.3c (RI-25, 2026-08-19) — THE SENSOR MUST BE RESETTABLE AND ITS STATE READABLE, or W7.1
  cannot be run.** ★ `walk.py` is a pure pass; the goldens were produced by one. A stateful sensor
  graded against them must reach a KNOWN state on demand and expose what it holds, or a byte
  comparison is against an unknown starting point and proves nothing. **Test:** arm → feed a fixture
  → read the state · reset → feed the same fixture → byte-identical state and output.
  **mutation:** carry any value across a reset → the second run diverges and the row bites.
- **A11.3d (RI-25, 2026-08-19) — THE SENSOR HOLDS TWO SETS, and the second one is recovery.**
  His words: *"keeps open the items out of stage, or out of step (for its stage)"* — the GATED set
  (nodes at the current stage / step) and the ALWAYS-OPEN set (stage 0, and ordinalless children
  within their stage — §311). ★ This is RI-18 Q5's sort order doing the work it was promoted for:
  the always-open bucket is built once at ingest and is never re-tested against the gate.
  **Test:** advance the stage → the gated set changes and the always-open set does not.
- **mutations** ~~keep a module-level "last sample" → the double-call test diverges~~
  [⚠ RESCOPED 2026-08-19: under A11.3’s two layers the SENSOR holding the last sample is
  CORRECT - the mutation now reads: give THE RULE memory of its own between calls → the
  double-call test diverges] · report an index → the shuffle test fails · grade W7.1 through
  the sensor without resetting it → A11.3c fails.

## A11.4 · COST — nothing armed, nothing running (S9)
- **A11.4a** No persistent `OnUpdate`: the accumulator exists ONLY while armed (`capture.lua`'s
  own discipline — "the handler exists ONLY while recording"). Disarm → the frame's OnUpdate is
  nil. Test under the harness: arm → handler set; disarm → handler nil; two-way, every time.
- **A11.4b (RI-25, Battlewrath 2026-08-19) — CONFIG INDEXES RESOLVE AT INGEST, NEVER PER SAMPLE.**
  `R` and `Band` reach the driver as INDEXES into its own config table (§381c pre-config menu, §382
  config class: *"the driver ALREADY HAS THESE"*), and the geometry test needs NUMBERS — his
  collection reads *"a R of 10 and a height of 2.5 yards"*. ★ The resolution happens once, when the
  records are ingested into the buckets, so the 1 Hz pass never performs a table lookup. **Test:**
  arm, then break the config table → the pass still runs on the values it resolved (proving nothing
  reads the table per sample). **mutation:** resolve inside the pass → the test fails on its own
  message. ⚠ This is the driver's side only; whether the EDITOR stores an index or a number is
  RI-22's open question and this does not answer it.
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
  — and returns NON-ZERO if any of them moves. That command is hooked to landing. ✓ **SATISFIED — and the RED
  clause below was a FALSE FINDING, withdrawn 2026-08-19.** `walk.py check` already covered every
  body at `5725b7d` §376, an ancestor of HEAD before the stand-in ever ran it: `main()` builds its
  aggregate at `walk.py:1777-1783` and prints `BODIES: W1 PASS · W5 PASS`. ~~measured 2026-08-19:
  W1 and W5 are UNREACHABLE from `walk.py check`~~ — that was not measured, it was inherited from
  the sense proposition's stale A9.5 note and then confirmed against a source read that had the
  contradicting lines inside its own window. ⚠ **The row STAYS as the criterion**: it goes red the
  day a body is added and left outside the aggregate. Was: "the w5 goldens are WATCHED — `walk.py check` (or a sibling)
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

★★ **AND `completion` HAS AN OWNER, so the deferral is a pointer rather than a silence
(RI-25, Battlewrath 2026-08-19).** `driver_authoring_acceptance.md` A2.7 specifies the rule in full
— all tabs must complete, per tab, with a wipe leaving tab 1 done and tab 2 re-arming — and never
says where that state lives. ⚠ It cannot be recomputed from the current sample: it survives leaving
the region and returning, and it interacts with Trigger. ★ **It belongs to the SENSOR, inside the
driver** (A11.3): *"the part that completes the function calls and such... checks against its tab
set for completion, ticking each off as they're met."*
~~The CALLER holds it, as it does the previous sample and the in-set.~~ ⚠ SUPERSEDED the same day —
the Analyst's "caller" named no owner; the sensor is an owner.
⟶ **V1 ships the sensor holding the resolved parameter inventory and the in-set; V2 adds the
per-tab ledger to the same object.** Nothing goes into a record either way.

## THE BENCH'S BUILD ORDER P1–P6 — accepted as proposed
    P1 ✓ SATISFIED — `walk.py check` already covers every body and returns one exit code
       (`5725b7d` §376). A11.7a's RED clause was a false finding, withdrawn 2026-08-19.
    P2 ★ THE LIVE STEP, UNBLOCKED 2026-08-20 — the row SHAPE as a declared contract + fixture
       list (A11.1). ⚠ Its input is the transport, settled in RI-26 and carried by
       `driver_data_model.md` rows 17a–17c: AceSerializer → LibDeflate → EncodeForPrint behind a
       version prefix, decoded in two stages, pasted into a multi-line box and never chat.
    P3 the rule in Lua (A11.2) → P4 W7.1 byte-equality + W7.2 synthetics → P5 ingest at
    1 Hz, armed/disarmed with no persistent OnUpdate (A11.4, A11.7c) → P6 the readout by address
    (A11.5). A11.6a's isolated smoke sits beside P3, not after P6 — it is cheapest when the file
    is small.

---

## REVIEW LOG
**2026-08-19c — Opus 5 (Analyst), RI-25.** ⚠ **A11.3 REWORDED**: purity is the RULE’s, not
the driver’s. Battlewrath: the state belongs to a STATEFUL SENSOR inside the driver. NEW A11.3c
(resettable and readable, or W7.1 cannot be run against a pure desk) and A11.3d (two sets: gated
and always-open). A11.8’s owner corrected from "the caller" — which named no owner — to the
sensor. My own read of one turn earlier is struck in place.

**2026-08-19b — Opus 5 (Analyst), RI-25 continued.** A11.8 now names WHERE completion state
lives when V2 builds it — the CALLER, per A11.3a’s existing pattern. Battlewrath found that A2.7
specifies the all-tabs rule without a home for its state, and an unnamed home is where a store
gets invented. No V1 row changed.

**2026-08-19 — Opus 5 (Analyst) on RI-25.** NEW **A11.2g** (one geometry evaluation per NODE
per sample, shared by its rows — what RI-16’s all-tabs-complete rule needs to be true) and
**A11.4b** (config indexes resolve once at ingest, never inside the 1 Hz pass). Both follow from
Battlewrath’s read order: gate → who → the details as one collection → the behaviours.

**2026-08-18 — Analyst on the bench's `history/driver_sense_proposition.md` (§371).** Q1–Q3, Q5 and the
P1–P6 order accepted as the bench read them; Q4 accepted as working posture with the SPLIT left
as Battlewrath's shipping decision. ONE CORRECTION: S8's readout (`hit · skip · false_advances`)
is stage-level — V1 reports the per-sample IN set and per-target first-hit index; W7.3's columns
are V2's (A11.5a). ONE ADDITION the proposition implied but did not name as a test: the isolated
load (A11.6a) — the findings file's unproven capability, provable in one smoke. The proposition
may leave once its behaviours are the rows above.

_How I test: `walk.py check` + the w5 watch, then the Lua smoke under lua51 against the same
fixture rows, byte-compare the emitted per-target first-hit indices to the desk, apply each named
mutation; report PASS / FAIL / UNMUTATED with the observed message._
