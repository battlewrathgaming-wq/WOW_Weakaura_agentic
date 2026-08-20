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

    sensing   =  the Lua rule produces the RULED OUTCOMES at the ruled radii and the ruled
                 cadence, and the branches the corpus cannot reach are graded on synthetics
                 (W7.2) · it reads a FLAT LIST and nothing else (installable without the editor
                 — proven by loading it without the store) · it answers by ADDRESS · it costs
                 nothing when nothing is armed

⚠⚠ **THIS BAR READ "BYTE-EQUAL to the desk on the same fixtures (W7.1)" UNTIL 2026-08-20.**
RI-33 moved byte-equality to the DESK's own calibration. The bar is the DRIVER's and must not
import the desk's; that import is what fused the two for three weeks.

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

## A11.2 · THE RULE — point + band + gate, and SMALLER than the desk’s
- **A11.2a — POINT + BAND + GATE.** ⚠⚠ **NARROWED 2026-08-20 (RI-33).** Was *"point +
  segment + band, ported from `walk.py`… graded by W7.1 (byte-equal to the desk)"*.

      the gate    same mapID, tested FIRST — two maps' coordinates are unrelated, so a small
                  dx/dy across a boundary is a coincidence, not a proximity
      the point   is the sample inside `R` of the node's `POS`, 2D xy, squared distances
      the band    is applied at the NODE's z, UPWARD ONLY (data model 12a) — never at an
                  interpolated z, because there is no segment to interpolate along

  ★ **WHY IT IS SUFFICIENT, and this is arithmetic rather than a preference.** The approach
  throttle is already at `POLL_MIN` = 0.2 s from 11 yd out (asklist H0-a), so a point test at
  R = 5 sees **7.1 samples through the centre at run speed**, 3.6 mounted, 1.7 at the 30 yd/s
  ceiling. ⟶ **The THROTTLER closed the tick problem; the segment test only ever closed the
  GRAZING residual.** Segment was carried into the driver as the desk's inheritance, not
  because the driver's own numbers asked for it.

  ⚠ **AND WHAT IT GIVES UP, named so nobody rediscovers it as a surprise.** Transits that clip
  the RIM. Closed form `1 − √(1 − (s/2R)²)` at R = 5, uniform lateral offset, at POLL_MIN:

      walk 2.5 yd/s  0.13%      run 7.0  0.98%      run p99 8.44  1.43%
      mounted 14     4.0%       ceiling 30  20%

  ★ A node the player is ROUTED TO is not a grazing transit, and mounted is rare-by-construction
  in a dungeon — so the operative number is ~1%. **If a grazing miss is ever observed in play,
  this is the row that predicted it and the segment test is the known remedy.**
      grades  Rule.Evaluate · Rule.PointFire · Rule.Gate
  TEST: W7.2's synthetics (mapID straddle W1.3 · non-finite · the clamp W1.9 · the gap bound
  W1.10), plus outcome grading at the ruled radii and cadence.
  MUTATION: make the band two-sided (`dz >= -band`) → the walkway fixture fires from underneath,
  which is the case the band exists for · test geometry before the mapID gate → W1.3's straddle
  fixture fires on a coincidence.
- ~~**A11.2b (S5)** The FIRST sample after arming uses POINT — there is no previous sample to
  segment from.~~ ⚠⚠ **RETIRED 2026-08-20 — VACUOUS UNDER A11.2a.** Every sample uses point,
  so "the first one does too" grades nothing. ★ **Headstone kept, per the A2.12 pattern:** a
  vacuous row reads identically to a passing one in a green suite (Dev, 2026-08-20), so the
  deletion has to be visible or the next reader re-derives it.
- **A11.2c (S6) — A STATIONARY PLAYER IS STILL EVALUATED AND STILL FIRES.** ⚠ REWRITTEN
  2026-08-20: was *"a degenerate segment (prev == cur) falls back to POINT; no division by zero,
  no NaN"* — vacuous under A11.2a, since there is no segment to degenerate and no division at
  all. ★ **The surviving claim is real and worth grading:** standing still inside a node's
  radius is the ordinary case (a boss room, a chest), and the rule must not require motion.
      grades  Rule.Evaluate
  TEST: feed the same in-region sample twice → both fire, same verdict, no state consulted.
- **A11.2d (S3)** A target in another mapID never fires however close the numbers are, and the
  gate is tested BEFORE any geometry. ⚠ 2026-08-20 the clause *"a segment straddling a mapID
  change is discarded, never bridged"* is struck — desk-side (W1.3 still grades it there).
      grades  Rule.Gate
- **A11.2e (S10)** Non-finite input is REJECTED, and in Lua that is two tests — `type(v) ~=
  "number"` AND `v ~= v` — with NaN and inf as SEPARATE fixtures (W7.2). Rejected = the sample
  is dropped. ⚠ 2026-08-20 the tail *"and the previous sample is NOT updated (so the next sample
  takes the point path)"* is struck: under A11.2a **the rule keeps no previous POSITION at all**,
  so there is nothing to leave un-updated. The sensor's memory is the in-set (A11.3), not a point.
      grades  Rule.Usable
  ⚠ **`Rule.OPEN` is `math.huge` and `finite()` refuses it** — an explicitly-open band was
  rejected by this very check until mutation found it (§416). nil and OPEN are one intent in two
  spellings; a rule that accepts one and refuses the other punishes being explicit.
- **A11.2f — the cadence (Q2).** 1 Hz is the BASE ingest rate; the approach throttle takes it
  down to a `POLL_MIN` floor of **0.2 s** as the player closes (`nextIn = max(POLL_MIN,
  min(POLL_MAX, slack))`, asklist H0-a).

  ⚠⚠ **ITS REASON WAS REPLACED 2026-08-20, not its answer (Dev's finding, and it was on nobody's
  list).** The row used to read *"1 Hz, because the golden is at 1 Hz and W7.1's byte-equality may
  REQUIRE it"* — and byte-equality moved to the desk in RI-33, so the row was standing on a
  retired criterion while the throttle conversation had the driver at a 0.2 s floor. ★ **The
  answer survives on its own feet:** W4.1's capture constant is 1 Hz and going coarser loses
  fixtures, while going finer when nothing is near costs battery for nothing. The throttle, not
  the base rate, is what buys accuracy on approach — which is exactly what A11.2a leans on.
  ★ Recorded, not ruled — Battlewrath's word if it changes.
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
  ⚠ **HALF-GRADEABLE TODAY (Dev, 2026-08-20) — the halves named so the green stays honest:**

      NOW     the rule is NODE-SHAPED. `Rule.Evaluate(sample, node)` takes a node and there is
              no per-row entry point, so per-row evaluation is not expressible.
                  grades  Rule.Evaluate
      WAITS   the SHARING — that four rows read ONE verdict — belongs to the sensor (A11.3),
              which is not built. **The count assertion cannot run until it is**, and until
              then this row is half-proved and says so.
- **mutations** ⚠ 2026-08-20 the first two were rewritten; both graded machinery that moved to
  the desk. ~~feed the same fixtures at 2 Hz → W7.1's byte-equality FAILS~~ and ~~veto at an
  endpoint's z instead of the interpolated z → W1.7's walkway fixture~~ → **make the band
  two-sided → the walkway fixture fires from underneath** · **run at POLL_MAX with no throttle
  → the grazing fixtures at R = 5 start missing, which is the proof the throttle is
  load-bearing for A11.2a** · test geometry before the mapID gate → W1.3 fails · remove the
  `v ~= v` test → the NaN fixture passes through and the row bites on its own message.

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

    THE RULE      point + band + gate (A11.2a). Same list, same samples, same answer. No memory.
    THE SENSOR    the armed object. Holds the resolved parameter inventory (A11.4b), the
                  in-set, and - at V2 - the per-tab completion ledger. Calls the rule.

- **A11.3a** The RULE answers the same given the same list and the same samples, in any order of
  targets, with no memory between calls beyond what its CALLER — the sensor — passes in (the
  previous sample; for `while` mode, the in-set). Test: shuffle the target list → identical output;
  call twice with the same inputs → identical. ⚠ The test is run against the rule directly, not
  through the sensor, which is what makes it meaningful.
- **A11.3b** Every report names the target by its ADDRESS (`RID:BID:CID`), never by index into
  the list. Test: shuffle the list → the same addresses report; an index would move.
- **A11.3c (RI-25) — THE SENSOR MUST BE RESETTABLE AND ITS STATE READABLE.** ⚠ **REASON
  REPLACED 2026-08-20; the requirement did not move.** It read *"or W7.1 cannot be run … a byte
  comparison is against an unknown starting point"* — byte-equality went to the desk under
  RI-33. ★ **The requirement stands on its own:** outcome grading compares run against run, so a
  sensor that cannot reach a KNOWN state on demand makes run 2 incomparable to run 1, and every
  outcome after the first is measured from wherever the last one happened to stop.
  **Test:** arm → feed a fixture → read the state · reset → feed the same fixture → identical
  state and output.
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
  double-call test diverges] · report an index → the shuffle test fails · grade the sensor's
  outcomes without resetting it between runs → A11.3c fails.

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
  IN; per target, its FIRST-HIT sample index** — ⚠ 2026-08-20 this read *"the per-target half of
  W7.1's byte-equality"*; under the rescope it is the per-target half of the OUTCOME grading. The
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
- **A11.7b — V1's FIRST green.** ⚠⚠ **REWRITTEN 2026-08-20, and this was the sharpest of the
  stale rows because it is the RELEASE GATE.** It read *"V1's FIRST green is W7.1's byte-equality
  (per-target half, A11.5a)"* — a gate that RI-33 had already moved to the desk, so V1's
  shipping condition was pointing at a criterion the driver is no longer graded by. ⟶ **V1's
  first green is W7.2's synthetics plus outcome grading at the ruled radii and cadence**, per
  target by address (A11.5a) — still not a hand-written assertion about a number someone chose.
- **A11.7c — what arms it in V1 (Q5), bench read ACCEPTED:** a function call, exercised by the
  smoke (`arm(list) / disarm()`); A10.5's remote wires to it later. No slash line.
- **mutation** ship the port with the w5 goldens unwatched → A11.7a is RED regardless of W7.2.

## A11.9 · THE SUPERTRACKER'S ESCAPEMENT — the park is the default, not a feature

_Battlewrath, 2026-08-20, his best working model: **"If the instruction doesn't set a new marker in
the action tabs, then the super tracker escapement is to a parked location. And then any death
events if we build that fire when that's the case."**_

★★ **This makes the terminal release automatic rather than remembered.** `ROUTER` already rules it
a REQUIREMENT and not manners — a finished route left set *"points indefinitely at a spent target,
silently, looking live"* — and the honest weakness of a requirement is that it depends on somebody
calling `Clear()` at the right moment. **An escapement does not depend on anybody.**

- **A11.9a** THE TRACKER ALWAYS HAS A DEFINED TARGET. A node's action tabs may set one
  (`supertrack`); **when none does, the escapement writes the PARK.** There is no state in which
  the tracker holds a spent target and no state in which it holds nothing.
      grades  Routes.RowsOf
  TEST: complete a node whose tabs set no marker → the tracker reads the park, not the node.
  MUTATION: leave the previous target set → the row bites on the stale address.

- **A11.9b** THE PARK IS HORIZONTAL, ~1600 yd, SAME mapID. **Measured 2026-08-20**: it returns a
  live computing distance (1600 → 1583.31 while walking) and draws no arrow. ⚠ **NEVER vertical** —
  overhead at 1600, twenty yards of movement moves the reading by 0.125 yd, which is
  indistinguishable from a frozen value. Client facts and both traps are in `operations/ROUTER.md`.
  TEST: after a park, the read moves as the player moves along the park's axis.

- **A11.9c** ⚠ NO CONTEST, and it is why this is cheap. `SetSuperTrackedPosition` alone re-points —
  *"the pin only cares about being set"* — and the chain test measured the overwrite landing inside
  one tick, 4.02 → 63.96 yd with no stale pointer. **So the next stage's marker simply writes over
  the park.** No release, no handover, no ordering rule.

- **A11.9d** ★ AND IT LEAVES A VERIFIER BEHIND. A parked reference gives a continuous cross-check
  that our own distance arithmetic still agrees with the engine (§253 measured them equal to
  1.9e-5 over 1,739 pairs). ⚠ It is a witness, not a detector — 1 Hz is enough, and it must never
  be read on the fine poll, which exists for the closeness calc alone.

⚠ **DEATH EVENTS ARE NOT THIS ROW.** His *"any death events if we build that"* is the death-location
pointer, still LATER and off by default (scoping S15). **What A11.9 fixes is the state it would
return to** — a death pointer that fires and then clears has somewhere defined to go.

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
    P3 ★ THE RULE IN LUA (A11.2) — built §416 as `rule.lua`; point + band + gate, and what is
    ABSENT is the build. → P4 W7.2 synthetics + outcome grading (⚠ NOT W7.1 byte-equality —
    RI-33 moved that to the desk) → P5 ingest at 1 Hz with the approach throttle to a 0.2 s
    floor, armed/disarmed with no persistent OnUpdate (A11.4, A11.7c) → P6 the readout by address
    (A11.5). A11.6a's isolated smoke sits beside P3, not after P6 — it is cheapest when the file
    is small.

---

## REVIEW LOG
**2026-08-20b — Opus 5 (Analyst). THE CATCH-UP PASS, and it starts with my own bad entry.**

⚠⚠ **THE ENTRY BELOW SAID "A11.2a NARROWS (RI-33)" AND I NEVER TOUCHED THE ROW.** I wrote the
log in the same motion as the decision, so it recorded an INTENTION as an accomplishment — and
the review log is precisely what a returning agent reads to learn what moved, so it would have
told them A11.2a was handled and they would not have looked. ★ **The fix is a rule about when
the entry is written: FROM THE DIFF, never from the decision.** If the row did not change, the
log does not get to say it did. Dev found it; I had signed and dated it.

★★ **AND THE PASS THAT FOUND THE REST WAS MECHANICAL.** Retiring W7.1 without grepping its own
name left ~10 live dependents. A careful human read (Dev's) found 2. ⟶ **A retirement is not
done until its identifier has been grepped and every hit is either updated or marked as
surviving.** ⚠ The grep yields a WORK LIST, not a defect list — several hits survived correctly.
★ Note the project already knew this: **A2.12 retired `fireOn` with a headstone, a drop-and-tell
and a grep test.** W7's rescope got none of that. The discipline existed and was not run.

WHAT ACTUALLY CHANGED, from the diff:
  · **THE BAR** — "sensing" was DEFINED as byte-equality to the desk. Now: ruled outcomes at the
    ruled radii and cadence, plus W7.2's synthetics.
  · **A11.2a REWRITTEN** — point + band + gate, with the arithmetic that makes it sufficient
    (7.1 samples through centre at run speed) and the cost named (~1% grazing rim-clip at R = 5).
    Three real `grades` citations against `rule.lua`.
  · **A11.2b RETIRED** with a headstone — vacuous. **A11.2c REWRITTEN** to its surviving claim
    (a stationary player still fires). **A11.2d** loses its straddle clause. **A11.2e** loses the
    prev-position tail — the rule keeps no previous position now.
  · **A11.2f's REASON replaced**, answer kept, with the 0.2 s throttle floor stated. Dev's find,
    and the only one where a live row rested on a retired criterion.
  · **A11.2g** split into the half gradeable now and the half waiting on the sensor.
  · **A11.7b REWRITTEN — the RELEASE GATE.** V1's first green was W7.1's byte-equality. Neither
    Dev's list nor mine reached it; the grep did.
  · **A11.3c's reason replaced**, requirement unchanged. **A11.5a** reframed. **Two mutations
    rewritten** — both graded machinery that had moved to the desk, so both were unfalsifiable.
  · **THE BUILD ORDER** — P4 was W7.1 byte-equality.
  · Outside this file: data model row 18 amended · **S9 DISSOLVED for free** (the desk's `v_max`
    golden inconsistency stops being a driver blocker once the port need not be byte-equal) · E1's
    reason · `DRIVER_BASIS` index + V1 summary · the walk brief's header and W7.1's own row.

★ **Citation coverage moves up, not down:** six new `grades` lines, all verified against
`^function` in `rule.lua` (`Rule.Evaluate` · `Rule.PointFire` · `Rule.Gate` · `Rule.Usable`).

⚠ **NOT DONE, and named rather than left:** A11.2g's count assertion and A11.9a both need the
SENSOR, which is not built — they are half-proved and now say so in the row.

**2026-08-20 — Opus 5 (Analyst).** ⚠ SEE ABOVE: this entry's A11.2a claim was false when written.
Four changes
  · **A11.9 NEW** — the supertracker escapement. If no action tab sets a marker, the
    tracker writes the PARK. Makes the terminal release automatic instead of remembered,
    and leaves a verifier behind. Client facts measured live and landed in `ROUTER`.
  · **A11.2a NARROWS (RI-33)** — the driver's rule is point + band + gate. Segment
    interpolation, interpolated-z and `v_max` are DESK-side. *"Precedence is the proof
    we can. Not the implementation the addon needs."*
  · **W7 rescoped** — byte-equality grades a reimplementation of the desk, not the
    driver. ⚠ A11.3c's justification still holds under the new scope: a stateful sensor
    graded against a pure reference must still reach a known state on demand.
  · **A11.1a superseded in place** — the single combined line is history; the record
    shape is `driver_data_model.md` §A1, and this brief CITES rather than restates it.
  ⚠ The transport (rows 17a–17c) is P2's input and is settled; P3 is unblocked.

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
