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

- **A11.2i — THE FLOOR SET, DERIVED AT BUILD AND PERMISSIVE AT RUNTIME** (AL-32, on Battlewrath's
  refinement; RI-57 drained to it).
      IS      a positioned node carries `{preceding, current, next}` — DERIVED AT BUILD from the
              sequence, in the same place `ledTo` and `trigger` resolve — and the runtime test is
              **membership on two or three integers**.
      IS NOT  **NOT a single-floor equality test** — that is the shape that flaps ·
              **NOT sticky state in the rule**, which stays PURE · **NOT a runtime patch**: the
              bench's four options all patched at runtime and his set removes the problem at
              BUILD · and a zero node (step 0 · stage 0) does **NOT floor-gate at all**.
      ★★ PERMISSIVE IS THE LOAD-BEARING WORD. A sample carrying no floor **falls through**; only a
      missing mapID refuses. ⟶ **A membership test that cannot create a silent stall** — which is
      what makes it safe to add to a rule everything else depends on.
      grades  Rule.Evaluate · Bucket.Build (the derivation and the whitelist)
      ORDER   ← `floor` joining the bucket's whitelist. Nothing else.
  TEST, four fixtures, and the first is the one the item was filed for:
    · THE FLAP — a doorway node, sample floors A → B → A at running speed → **inside the set every
      time**, no transition lost. ★ The 20% flap the corpus measured is dissolved BY CONSTRUCTION,
      not handled.
    · a floor OUTSIDE the set → refuses.
    · a sample with `floor = nil` → falls through and the rest of the rule decides.
    · a zero node with any floor → never gates.
  MUTATION: make the test EQUALITY on `current` → the flap fixture loses one transition in five and
  the doorway stops being reachable at speed.
  MUTATION: make it REFUSE on a nil floor → every sample from a client that does not report one
  stalls silently, which is the failure permissiveness exists to prevent.
  ⚠ **BOUNDED, and the architect said so:** no overlapping-area false fire has been observed — this
  buys correctness **not yet needed**, at one carried field. ⬜ And **the at-speed flap rate is
  UNMEASURED** (DR_Process_19: a measurement, the bench's, once a fast transition is in the corpus).

- **A11.2a — POINT + BAND + GATE.** ⚠⚠ **NARROWED 2026-08-20 (RI-33).** Was *"point +
  segment + band, ported from `walk.py`… graded by W7.1 (byte-equal to the desk)"*.

      the gate    same mapID, tested FIRST — two maps' coordinates are unrelated, so a small
                  dx/dy across a boundary is a coincidence, not a proximity
      the point   is the sample inside `R` of the node's `POS`, 2D xy, squared distances
      the band    is applied at the NODE's z, UPWARD ONLY (data model 12a) — never at an
                  interpolated z, because there is no segment to interpolate along

  ★ **WHY IT IS SUFFICIENT — arithmetic, and it has TWO PRECONDITIONS that are part of the
  claim.** ⚠⚠ CORRECTED 2026-08-20 (RI-34): this paragraph first argued sufficiency from *"7.1
  samples through the centre at run speed"* and capped its cost at a *"30 yd/s ceiling"*. **Run
  speed is the MEDIAN, and 30 is not the corpus ceiling — 56.9 yd/s is.** At 56.9 the failure is
  not a rim-clip; it is a whole beacon skipped. Sufficiency is REAL but CONDITIONAL:

      P1  MAX_CLOSING_SPEED = 100 (settled RI-34; was 30, inherited from COA_Landmarks) —
          without it a poll far out schedules a wait long enough to carry the player clean
          past the beacon, and no floor value can see that
      P2  POLL_MIN · v < 2R at the ruled minimum R = 5 — satisfied by 0.1 s (1.76× margin
          at 56.9), NOT by 0.2 s

  ⟶ **With both, a transit through the centre of an R = 5 beacon is always sampled** and the
  throttler has closed the tick problem; the segment test only ever closed the GRAZING residual.
  Segment was carried into the driver as the desk's inheritance, not because the driver's own
  numbers asked for it. ⚠ **Fail either precondition and the narrowing is unsafe, not merely
  less accurate** — which is why they are stated here and not left in the cadence row.

  ⚠ **AND WHAT IT GIVES UP, with both preconditions met.** Transits that clip the RIM. Closed
  form `1 − √(1 − (s/2R)²)` at R = 5, uniform lateral offset, at the 0.1 s floor:

      walk 2.5 yd/s  0.03%      run 7.0  0.25%      run p99 8.44  0.36%
      mounted 14     0.98%      corpus max 56.9  17.8%

  ★ A node the player is ROUTED TO is not a grazing transit, and the 56.9 figure is a charge
  ability, not traversal — so the operative number is well under 1%. **If a grazing miss is ever
  observed in play, this is the row that predicted it and the segment test is the known remedy.**
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
- **A11.2d (S3) — and its LAW is DR_Content_15.** ★ **`driver_architecture.md` §5 DR_Content_15 (AL-9, from C4): THE
  MapID IS THE HIGHEST IDENTITY OF LOCATION.** Battlewrath's zone-change ruling — *a zone is
  collected by the run and pointing into it is still true* — was stranded as struck text inside §6
  with no owning doc and would have vanished when §6 drained. **A11.2a/d is its home; this row is
  the citation.** ⟶ A loading screen is the mapID gate per sample, and nothing below zone level
  changes what a beacon means.
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
      grades  Rule.Usable
  TEST: NaN and inf as SEPARATE fixtures -> both DROPPED, via both tests (`type(v) ~= "number"`
  and `v ~= v`); an explicitly-open band (`math.huge`) is ACCEPTED, identical to nil.
  MUTATION: keep only the `type` test -> the NaN fixture passes through; refuse `math.huge` ->
  the explicit-open case is dropped and the row bites (the fault §416 found).
  ⟶ SILENT OTHERWISE: a NaN coordinate poisons the geometry and every node reads out of range —
  or an explicit open band is refused while nil is honoured, punishing the author for being explicit.

- **A11.2h — WHO RESOLVES THE BAND. ✅ ANSWERED AND BUILT 2026-08-20 (§432).**
  *(Filed the same day at Battlewrath's instruction: "Push it as an acceptance item and why.
  Don't mutate code from doc disagreement." ★ The separation worked exactly as intended — the
  item was filed against live code, the code stayed untouched, and the ruling arrived before
  anything moved.)*

  **THE RULING (Battlewrath, 2026-08-20):** *"The expectation is 2.5 as the floor and picked
  upwards. **No infinity living in code to ever reach that.**"*

      ✅  `Rule.OPEN` is DELETED. Not "unused" - gone, and `smoke_rule` asserts its absence.
      ✅  `Rule.Evaluate` REFUSES a nil band, reason `"no band"`. It does not default one.
      ✅  a NEGATIVE band is refused, not clamped - upward-only means a negative band is a
          field that means nothing, and clamping would invent the author's intent
      ✅  a ZERO band is LEGAL to the rule: the 2.5 floor is the OFFERING's to enforce
          (RI-34), and a second enforcement point is a second answer that can disagree
      ⟶  resolution stays where row 27 put it - once, at BUCKET. ⚠ BUCKET is not built
          (`driver_sensor_brief` G1), so TODAY NOTHING RESOLVES and every unresolved node is
          simply refused. That is the conservative direction and it is loud.

  ★★★ **AND THE OLD TEST WAS GREEN THE WHOLE TIME.** `smoke_rule` asserted the OPPOSITE —
  *"`nil` and `Rule.OPEN` are the same INTENT written two ways"* — and the code agreed with it
  perfectly. **What was wrong was never the code against the test; it was both against a ruling
  neither had met.** ⚠ A test cannot catch a fault it was written to encode, which is why this
  needed a reading of the RULINGS rather than another mutation pass.

  MUTATION 8/8, each on its own message, across two smokes: the infinity returning · `Rule.OPEN`
  re-exported · nil silently defaulting to 2.5 · negative clamped · zero refused · the band
  unchecked · the band two-sided · the refusal reason renamed.

  <details><summary>THE ITEM AS FILED — kept whole</summary>

      `rule.lua:93`        `return dz >= 0 and dz <= (bandUp or Rule.OPEN)`   → nil means ∞
      model row 27         BUCKET resolves nil → **2.5**, once, at the door

  ⟶ **Both cannot be the resolution point, and today only one of them exists in code.**

  ★★ **WHY THIS IS AN ACCEPTANCE QUESTION AND NOT A TIDY-UP.** Three rulings already on disk
  point the same way, none of them mine:

      · **`routes.lua:1512` states the law four lines from the setter** — *"NO DEFAULT IS
        INVENTED HERE. A field nobody set comes back nil."* `bandUp or Rule.OPEN` invents one.
      · **RI-2 ruled the split** — raw nil from the store, *"the consumer resolves"*. The rule
        is not the consumer; it is the thing the consumer calls.
      · **RI-35 closed the menu** — the picker floors at **2.5 and runs UPWARD**, so ∞ is not
        a value any author can produce. A fallback lands the node on a behaviour nobody authored.

  ⚠⚠ **AND IT IS `stage or 0` IN A NEW COAT.** A2.10a's defect was a missing value silently
  converted at a read site and then used — *"the `or 0` WAS the bug"*. This has the same shape
  and the opposite polarity: **it fails OPEN.** A node whose band never got resolved accepts a
  player at ANY height, which is precisely the walkway case the band exists to refuse.

  ★ **WHAT MUST BE TRUE (the requirement; the mechanism is the bench's):** exactly one place
  resolves an unset band, and the rule is not it. Whether the rule then REFUSES a nil band, or
  is simply never handed one, is a design choice — ⚠ but *"never handed one"* has to be provable
  rather than assumed, or it is the unreachable-but-permissive branch that mutation already
  removed from `NextIn` once.

      grades  Rule.PointFire · Rule.Evaluate

  </details>
  TEST: a node whose stored band is nil → the value the rule receives is 2.5, and the rule is
  never called with nil.
  MUTATION: hand the rule a nil band directly → it must not silently admit a player 40 yd above
  the node. ⚠ Under the current line that mutation CANNOT BITE, which is the tell.

  ⚠ **NOTHING IS BLOCKED.** No flight list is built, so nothing calls the rule with a stored
  band at all. ★ Same window as RI-37 and the BUCKET boundary: **free to settle now, and it is
  the resolution POINT that is expensive to retrofit, not the value.**

- **A11.2f — the cadence (Q2).** 1 Hz is the BASE ingest rate; the approach throttle takes it
  down to a `POLL_MIN` floor of **0.1 s** as the player closes (`nextIn = max(POLL_MIN,
  min(POLL_MAX, slack))`, `slack = (dist − R)/MAX_CLOSING_SPEED`, asklist H0-a).

  ★★★ **WHY 0.2 WAS NEVER A LIMIT — the part that was worked out and never written down.**
  `OnUpdate` fires per frame, so the REAL floor is the frame interval, ~0.017 s at 60 fps. ⟶
  **0.2 is a CHOSEN value**, and `landmark_design.md` says what chose it: *"5 samples per
  debounce window"* — **a debounce budget, not a sampling constraint.** ⚠ Nothing about the
  client ever required it, so nothing had to be overcome to change it.

  ⚠⚠ **AND 0.2 IS EXACTLY WHERE IT FAILS.** Not approximately: to not step over a 10-yard disc
  at 50.6 yd/s you need better than **0.198 s**. ★ **Radius cannot fix this** — a bigger disc
  does not make a sample land inside, it only makes the miss less likely. **Cadence is the only
  lever that addresses the actual failure.**

  ⚠⚠ **THE FLOOR MOVED 0.2 → 0.1 ON 2026-08-20 (RI-34, Battlewrath; arithmetic confirmed).**
  Under point + band + gate there is no chord to catch a pass the samples missed, so the floor's
  whole job is that **the player cannot cross a beacon's DIAMETER between two samples.** At the
  ruled minimum R = 5 (10 across) and the corpus maximum 56.9 yd/s, FLOOR must be `< 2R/v` =
  0.176 s. **0.2 fails; 0.1 carries 1.76× margin.**

  ⚠⚠ **AND `MAX_CLOSING_SPEED = 30` MUST MOVE WITH IT — the floor alone fixes nothing.** The
  two constants own DIFFERENT failures: the floor owns the CROSSING, the closing speed owns the
  APPROACH (a poll at 60 yd schedules 1.833 s, and 56.9 yd/s covers 104 yd in that time). ★
  Measured over every approach distance, fixing either alone leaves R = 5 skippable.

  ✅ **SETTLED (Battlewrath, 2026-08-20): `MAX_CLOSING_SPEED = 100`** — `TELEPORT_VMAX`, the
  fastest thing the project is OBLIGED to treat as travel. ⚠ **Not set from the corpus maximum**
  (56.9): a value chosen from what we have SEEN is a bet on the fastest ability that will ever
  exist, and 60 loses it — measured, MCS = 60 is unsafe at 100 yd/s. ★ It reads as a DISTANCE:
  **"poll at the floor from 15 yd out"** (`R + POLL_MIN × MCS`), which is the form a human can
  judge. Cost: a 60 yd run-in at 7 yd/s is 37 polls over 7.9 s ≈ 4.7/s.
  ⚠ Untested: the per-call cost of `GetCurrentPlayerPosition()` at that rate. Macro-testable.

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

⟶ **THE SENSOR'S MAP IS `driver_sensor_brief.md`** (Analyst, 2026-08-20; rules nothing, cites
these rows). What is BUILT, two declared seams, and nine gaps in the order they bite. ⚠ Where it
and a row here disagree, **the row wins.**

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
    THE SENSOR    the armed object. Holds the resolved parameter inventory (A11.3 - ⚠ was
                  cited to A11.4b until §427; see that row's headstone), the in-set, and
                  - at V2 - the per-tab completion ledger. Calls the rule.
      grades  Rule.Evaluate
  TEST: a node with four behaviour rows fed ONE sample -> the rule is entered ONCE and all four
  rows read one verdict.
  MUTATION: evaluate per row -> the entry-count assert fails, and a fixture where two rows
  straddle the boundary shows them disagreeing.
  ⟶ SILENT OTHERWISE: two tabs of one node disagree about the same in/out transition, so the
  child's all-tabs completion never resolves.

- **A11.3a** The RULE answers the same given the same list and the same samples, in any order of
  targets, with no memory between calls beyond what its CALLER — the sensor — passes in (the
  previous sample; for `while` mode, the in-set). Test: shuffle the target list → identical output;
  call twice with the same inputs → identical. ⚠ The test is run against the rule directly, not
  through the sensor, which is what makes it meaningful.
      grades  Rule.Evaluate
  TEST: called DIRECTLY, not through the sensor — shuffle the target list -> identical output;
  call twice with the same inputs -> identical output, with no memory beyond what the caller passes.
  MUTATION: give the rule memory of its own between calls -> the double-call test diverges.
  ⟶ SILENT OTHERWISE: the rule accumulates state and the same sample answers differently on the
  second pass, which reads as a flaky node rather than a bug.

- **A11.3b** Every report names the target by its ADDRESS (`RID:BID:CID`), never by index into
  the list. Test: shuffle the list → the same addresses report; an index would move.
      grades  Sensor.Poll · Rule.Evaluate
  TEST: shuffle the target list -> the same ADDRESSES report; every report names `RID:BID:CID`,
  never an index into the list.
  MUTATION: report an index -> the shuffle test fails because the index moved.
  ⟶ SILENT OTHERWISE: a re-ordered list makes the driver fire the wrong node's tabs, and BOTH
  indices are valid so nothing errors.

- **A11.3c (RI-25) — THE SENSOR MUST BE RESETTABLE AND ITS STATE READABLE.** ⚠ **REASON
  REPLACED 2026-08-20; the requirement did not move.** It read *"or W7.1 cannot be run … a byte
  comparison is against an unknown starting point"* — byte-equality went to the desk under
  RI-33. ★ **The requirement stands on its own:** outcome grading compares run against run, so a
  sensor that cannot reach a KNOWN state on demand makes run 2 incomparable to run 1, and every
  outcome after the first is measured from wherever the last one happened to stop.
  **Test:** arm → feed a fixture → read the state · reset → feed the same fixture → identical
  state and output.
  **mutation:** carry any value across a reset → the second run diverges and the row bites.
      grades  Sensor.Reset · Sensor.State
  TEST: arm -> feed a fixture -> read the state; reset -> feed the same fixture -> identical state
  and identical output.
  MUTATION: carry any value across a reset -> the second run diverges and the row bites.
  ⟶ SILENT OTHERWISE: every outcome after the first is measured from wherever the last run
  happened to stop, so run-to-run comparison quietly means nothing.

- **A11.3e (AL-2, 2026-08-21) — THE RETURN CONTRACT: CHANGED NODES, BY ADDRESS, WITH THE
  TRANSITION WORD.** ⚠⚠ **NEW ROW, and it existed nowhere until now** — the only statement of what
  `Poll` returns lived in `driver_sensor_brief.md` (which rules nothing) and in A12.4a (the manager's
  side of the same contract). A11.x is the sensor's own brief and carried no row for it.
      the SENSOR returns, AFTER the poll, the nodes whose verdict CHANGED — by ADDRESS — each
      with its transition word: **When on · Seen · When off**
  ★ Why it is the sensor's and not the caller's: the words are TRANSITIONS, so computing them needs
  the PREVIOUS verdict, and A11.3 puts state on the sensor's side of the line.
  ✅ **BUILT (staleness sweep, 2026-08-21) — AND THIS ROW WAS THE LARGEST STALE CLAIM IN THE SET.**
  `Sensor.Arm` allocates **four** sets, not one — `{ nodes, inSet, wasIn, everIn }` — and `Poll`
  swaps them (`armed.wasIn, armed.inSet = armed.inSet, {}`), so the previous verdict survives.
  `Poll` returns `changed`, whose entries are `{ address, word, node }`, emitting `WHEN_ON`,
  `SEEN` and `WHEN_OFF`. And `snapshot()` carries `rows = node.rows`. ⟶ **Every clause of the
  NOT-BUILT paragraph is now false**, including the one about `rows`.
  ~~NOT BUILT. `sensor.lua:120` allocates ONE `inSet` and `:189` overwrites it in place, so no
  previous verdict survives; `Poll` returns the currently-inside snapshots with no word. And
  `snapshot()` drops `rows` — the armed object has no tabs to attach a word to.~~
  ⚠⚠ **WHAT THIS MOVES, and it is not cosmetic: DR_Content_2.3 was Chain 2's *"BLOCKS ALL DISPATCH"* item.**
  The bench reported Chain 2 complete at §466 and the acceptance never caught up — so the doc a
  cold reader consults still said the sense vocabulary was uncomputable. ★ **A stale blocker is
  worse than a stale fact: it stops work that is already unblocked.**
      grades  Sensor.Poll
  TEST: a node entered then left across three samples → When on once, When off once, nothing between.
  MUTATION: return the whole in-set → every tab re-fires every sample and the count assertion bites.

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
      grades  Bucket.Build · Sensor.Arm
  TEST: advance the stage -> the GATED set (nodes at the current stage/step) changes and the
  ALWAYS-OPEN set (stage 0, and ordinalless children within their stage) does NOT.
  MUTATION: rebuild the always-open bucket against the gate on advance -> it changes with the
  stage and the row bites.
  ⟶ SILENT OTHERWISE: the recovery bucket is re-gated on an advance, so a lost reader's stage-0
  beacon stops listening exactly when it is needed.

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
  message. ~~⚠ This is the driver's side only; whether the EDITOR stores an index or a number is
  RI-22's open question and this does not answer it.~~
  - ⚠⚠ **AND ITS LANE WAS CORRECTED TOO — §427, marked here 2026-08-21.** Two corrections were
    owed on this row and only the PREMISE one landed. **A11.4b IS THE PICKER'S ROW, NOT THE
    DRIVER'S.** `sensor.lua:82-91` says it against the code: *"A11.4b DOES NOT LAND ON THIS SIDE AT
    ALL … **THE SNAPSHOT'S WARRANT IS A11.3, NOT A11.4b**"* — and the same file records why the
    distinction matters: re-aiming a pointer at this row would have justified the sensor's copy
    with a per-sample-lookup rule that no longer describes anything.
    ★ **WHAT SURVIVES IS THE REQUIREMENT, NOT ITS WARRANT:** resolve once, never per sample. That
    is A11.3's (the sensor owns its snapshot) and `bucket.lua`'s (every id resolved at build,
    model row 25). ⟶ **Cite those, not this.**
    ⚠ Found by `emit_built_state.py --candidates` on 2026-08-21: the row NAMES `Sensor.Arm`, and
    a citation added without reading it would have asserted the join §427 exists to deny. **The
    shortlist earned its keep by producing a rejection.**
  - ⚠⚠ **PREMISE SUPERSEDED 2026-08-20 (RI-35). THERE ARE NO INDEXES.** RI-22 answered the very
    question this row flagged: **the store holds the NUMBER, not the menu index** (`#3` §A3b 12a,
    and `contract.lua` types both `r` and `band` as `"number"`). Battlewrath, draining RI-35:
    *"Indexes is complete. User pick. R 5 the lowests. 2.5 above the lowest offered."* ★ The menu
    is CLOSED and the user PICKS from it; what the record carries is the value picked.
  - ✅✅ **AND THE REQUIREMENT IS THE PICKER'S, NOT THE DRIVER'S.** Battlewrath, 2026-08-20:
    *"'read a table per value' is on the picker side. The sensor its self will have absolute
    values by the time it reaches it. Defined in the BID:CID or BID for that POS of the node."*
    ⟶ **`R` and `Band` are CHARACTERISTICS of the node**, carried on its own record at
    `BID:CID` (or `BID`) alongside `POS` — `contract.lua`'s `CHARACTERISTIC`, both typed
    `"number"`. By the time anything reaches the sensor the lookup has already happened, once,
    at authoring time. ⚠ **So this row does not land on the driver at all**, and the test it
    asks for cannot be written on this side.
  - ⚠ **THE BENCH IMPORTED IT ANYWAY.** §425 read *"nothing may read a table per sample"* as a
    live driver requirement, re-aimed it at the node record, and justified `Sensor.Arm`'s
    snapshot with it. ★ **The snapshot is right; the reason given for it was borrowed from
    another lane.** Its actual warrant is A11.3 — the sensor *"keeps a running inventory of the
    RESOLVED position(Parameters)"* — which is a snapshot in his own words, and needs no help
    from A11.4b. `smoke_sensor`'s `M3` grades that inventory and is re-labelled to say so.
  - ★★★ **AND THIS ROW IS THE CASE STUDY.** It named its dependency, in its own text, at the
    point of use — which is how a row is *supposed* to be written. **It went stale anyway, because
    nothing reads flags.** A dependency recorded in prose is a note to whoever happens to be
    looking at that line; it is not a link anything can traverse when the depended-on item drains.
    Third instance this week of a note that became false without being touched.
      kind  RULING — ITS PREMISE EXPIRED. RI-22/RI-35 rule that the store holds the NUMBER and the
      menu is a closed picker; there are no indexes arriving at the driver, and the row says so itself:
      *"this row does not land on the driver at all, and the test it asks for cannot be written on
      this side."*
      ⟶ DECLARED UNINSTRUMENTABLE. What it shapes: resolve-once-never-per-sample belongs to the
      PICKER, and `Sensor.Arm`'s snapshot is cited to A11.3 and model row 25, never here.
      ⚠ THE TWO PASSES SPLIT HERE — one wrote a test for the DEAD premise. That is the failure this
      task was told to avoid, and it is why a second read is not the same as a second opinion.

- **mutation** leave the handler set on disarm → A11.4a fails on its own message.

## A11.5 · THE READOUT — what V1 can honestly report (S8, CORRECTED)
- **A11.5a — ⚠⚠ REWORDED 2026-08-21 (RI-39, Battlewrath): *"It has stage in the editor. Just no
  local, readable expression."*** The old wording, *"V1 has no stage"*, was read LITERALLY once
  — by the bench that wrote the driver (§435) — and a row its own intended reader takes the
  wrong way is defective however it was meant. **V1 HAS NO READABLE EXPRESSION OF STAGE; the
  DATA has stages 1..N.** ★ Where it becomes readable is the READER'S NOTE PANE (A10.8a), which
  is Chain 3 and not this leg.
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
      kind  RULING — it accepts the driver's current home (its own file in `COA_DungeonRun`, structured
      so a move costs a `.toc` line) and rules the split into Dungeon Routes a SHIPPING decision that is
      Battlewrath's.
      ⟶ DECLARED UNINSTRUMENTABLE (both passes agreed). It shapes A11.6a, which is the row that grades.

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
  TEST: perturb a w5 golden by one byte -> the AGGREGATE returns non-zero; run the aggregate with
  W1 deliberately broken -> it also returns non-zero.
  MUTATION: add a body of criteria and leave it OUTSIDE the aggregate -> the row reds, because a
  body watched only by someone remembering to run it is not watched.
  ⟶ SILENT OTHERWISE: a golden moves in a body no aggregate covers, and the landing hook stays
  green while the calibration has drifted.
  ⚠ No `grades` line: the place is `walk.py check`'s aggregate, not addon Lua.

- **A11.7b — V1's FIRST green.** ⚠⚠ **REWRITTEN 2026-08-20, and this was the sharpest of the
  stale rows because it is the RELEASE GATE.** It read *"V1's FIRST green is W7.1's byte-equality
  (per-target half, A11.5a)"* — a gate that RI-33 had already moved to the desk, so V1's
  shipping condition was pointing at a criterion the driver is no longer graded by. ⟶ **V1's
  first green is W7.2's synthetics plus outcome grading at the ruled radii and cadence**, per
  target by address (A11.5a) — still not a hand-written assertion about a number someone chose.
- **A11.7c — what arms it in V1 (Q5), bench read ACCEPTED:** a function call, exercised by the
  smoke (`arm(list) / disarm()`); A10.5's remote wires to it later. No slash line.
      kind  RULING — it settles Q5 by fixing V1's arming surface as a plain function call
      (`arm(list)` / `disarm()`) exercised by the smoke, with no slash line and the remote wired later.
      ⟶ DECLARED UNINSTRUMENTABLE: slash-only arming would break the smoke, which is LOUD.
      ⚠ THE TWO PASSES SPLIT HERE — one called it a criterion. The loudness test decided it.

- **mutation** ship the port with the w5 goldens unwatched → A11.7a is RED regardless of W7.2.

## A11.9 · THE SUPERTRACKER'S ESCAPEMENT — the park is the default, not a feature

_Battlewrath, 2026-08-20, his best working model: **"If the instruction doesn't set a new marker in
the action tabs, then the super tracker escapement is to a parked location. And then any death
events if we build that fire when that's the case."**_

★★ **This makes the terminal release automatic rather than remembered.** `ROUTER` already rules it
a REQUIREMENT and not manners — a finished route left set *"points indefinitely at a spent target,
silently, looking live"* — and the honest weakness of a requirement is that it depends on somebody
calling `Clear()` at the right moment. **An escapement does not depend on anybody.**

- **A11.9a** THE TRACKER ALWAYS HAS A DEFINED TARGET.
  ⚠⚠ **AND TRAY-0 NEVER WRITES IT — added 2026-08-21 (AL-6, one day after this row).** Battlewrath:
  **RECOVERY NEVER USES THE SUPERTRACKER.** A stage-0 beacon's tabs may not set the arrow; the entry
  lure is the STAGE SLOT's. ★ The reason is the reader's: recovery is OBSERVED AND CORRECTED, not
  steered — an arrow pointing at a recovery beacon would steer someone who is already lost toward a
  node that is not where the run is. ⟶ A12.3c carries the manager's half; this is the escapement's.
  ⚠⚠ **SUPERSEDED 2026-08-22 (AL-19 · DRILL 3 · B4): the guard is not owed — THE WORD IS.**
  ~~`object.lua` offers `supertrack` on ANY child, and the authoring guard is owed with the
  pickers.~~ `supertrack` is RETIRED as an action and is the node's **LED TO tick**, a
  characteristic. ⟶ There is nothing left to guard on the action side; what is owed is the pane
  ceasing to offer a retired word (RI-58), which DR_Content_20 makes mechanically detectable rather than a
  guard someone remembers to write. A node's action tabs may set one
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
    RI-33 moved that to the desk) → P5 ingest at 1 Hz with the approach throttle to the
    **0.1 s** floor and `MAX_CLOSING_SPEED = 100` (⚠ was `0.2 s` here until §424 — RI-34
    settled BOTH constants and this line carried the old one for a landing), armed/disarmed
    with no persistent OnUpdate (A11.4, A11.7c) → P6 the readout by address
    (A11.5). A11.6a's isolated smoke sits beside P3, not after P6 — it is cheapest when the file
    is small.

---

## REVIEW LOG
**2026-08-20c — Opus 5 (Analyst). RI-34: BOTH THROTTLE CONSTANTS SETTLED.**

    POLL_MIN           0.20 → 0.10      MAX_CLOSING_SPEED   30 → 100 (= TELEPORT_VMAX)

★★ **A11.2f** carries the floor and, new, **why 0.2 was never a limit**: `OnUpdate` fires per
frame so the real floor is ~0.017 s, and 0.2 was a DEBOUNCE budget borrowed from COA_Landmarks
(*"5 samples per debounce window"*) — never a sampling constraint. **And 0.2 is exactly where it
fails**: a 10 yd disc at 50.6 yd/s needs better than 0.198 s. ⚠ Radius cannot fix it; a bigger
disc only makes the miss less likely. **Cadence is the only lever.**
★ **A11.2a P1** takes `MAX_CLOSING_SPEED = 100`. Not the corpus maximum — a value set from what
we have SEEN is a bet on the fastest ability that will ever exist, and 60 loses it (unsafe at
100 yd/s). 100 is the fastest thing the project is OBLIGED to call travel. It reads as a
DISTANCE: *"poll at the floor from 15 yd out"*.
★ Battlewrath's reframe, and it is the right one: **permission to sleep is DISTANCE, not speed.**
The floor is the guarantee; the divisor only decides when the floor applies.
⚠ Corrected in the same pass: my *"≥ 57, 60 suggested"* — **withdrawn, it was wrong.** And an
"owed guard on R's minimum" I filed from reading `setReach` alone — **struck; the picker already
holds R = 5**, and I had claimed everywhere from one place.
⚠ **NOT changed, deliberately:** `asklist:407`'s 0.2 is the CAPTURE rate (producer-side) and
does not move with the driver's floor; `walk.py`'s `cadence=0.2` fixtures are the teleport
pair's own spacing (gt 100.0 → 100.2) and grade `TELEPORT_VMAX`, unaffected; **COA_Landmarks
keeps 0.20 / 30 and is correct to.**
⚠ **STILL OWED (RI-34, bench):** `w5`'s two-rates and cut-corner blocks want re-running under
point-only — measured with segment in the rule, their direction inverts without it.

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
