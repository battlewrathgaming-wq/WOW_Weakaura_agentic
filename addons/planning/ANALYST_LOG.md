# ANALYST_LOG — what was settled, in one line each: IS · IS NOT · why · where

_Opened 2026-08-21 at Battlewrath's ask: **"Then a log to extract the IS / IS NOT and reasoning /
outcome."** The sibling of `ARCHITECT_LOG.md`, one level down: that log carries the ARCHITECT's
outcomes on the macro model; this one carries what the Addon creator and the Analyst settled
between them, and what Battlewrath ruled when an item reached him._

★ **THE FORM IS HIS AND PREDATES THIS FILE** (2026-08-19): **question · outcome · NOT statement ·
IS statement · cite.** ⚠⚠ **The NOT line is the point.** An outcome recorded only as what we chose
leaves the rejected shape free to drift back in; naming it once is what stops that. Every row below
was written in that form inside the inbox — this file is where they now live, because **a
conversation and its conclusions should not share a page.**

    THE INBOX   `Reconcile_inbox.md` — the CONVERSATION. Open items, options, measurements,
                marked reads. Each seat takes from it and inputs as needed.
    THIS LOG    the CONCLUSIONS. An item leaves the inbox and arrives here.

⚠ **THIS LOG DIRECTS NOTHING.** The CITE column names the record that governs; where a cite and a
row here disagree, **the cite wins**. It is an index of settled things, not a second copy of them.

⚠ **Derive status, never read it:** `py addons/tools/check_inbox.py`.

---

# 2026-08-21 — THE UI REFRAME AND THE DRIVER'S SETTLEMENTS

_Written 2026-08-21 from the items' own drain stamps, not from memory. ⚠ **The log was
20 items behind** — the invariant *"either a full entry in the inbox or a row here, never both"* was
violated the whole day it was written. ★ These are the eight that a cold reader needs first, because
they are the reframe the next build steps stand on._

    RI-52  Q  a stage whose children ALL lack an ordinal arms and never advances — does
              BUILD owe a refusal, the stage-level twin of A12.2g?
           O  NO. **The bench's premise was wrong and no guard is owed.** Battlewrath:
              *"It can complete. And it will still carry a N or Set."* A step-0 child
              completes on its own trigger like any other — *"updating notes is enough
              … in a 1 tab case / 1 row, that is that node satisfied"*. The STAGE not
              advancing is RI-49's missing `Next`, not a missing refusal.
           ✗  a greedy node NOT completing is not the fault · BUILD does NOT owe a
              refusal here · *"the stage did not advance"* is NOT *"nothing completes"*
              · a guard against an unbuilt feature is NOT a guard, it is a guard AGAINST
              the feature
           ✓  the node completes and the ledger marks it whole (already built) · the
              stage's exit is an authored `Next`, owed at RI-49 · **`Next` needs a
              NO-OUTCOME value** so a greedy node's completion does not compete with the
              ordinal — EXPRESSIBLE, because *"I have not said"* and *"nothing follows,
              on purpose"* are different facts
           →  RI-49 · A12.5b · model row 12 · `manager.lua` NodeDone

    RI-33  Q  which does the driver need — the desk's machinery, or less?
           O  LESS. Build from need, not from precedence.
           ✗  segment · interpolated-z · `v_max` are NOT the driver's · W7.1 byte-equality is NOT
              its grade · precedence is NOT a reason to ship
           ✓  point + band + gate, and what is ABSENT is absent on purpose · the desk keeps its own
              machinery · the driver is graded on OUTCOMES at the ruled radii and cadence
           →  A11.2a · `rule.lua` · W7 (rescoped)

    RI-34  Q  can we poll below 0.2, and does the floor alone make it safe?
           O  0.1 — and NO, the floor alone changes nothing.
           ✗  0.2 is NOT a limit (it was a DEBOUNCE budget from COA_Landmarks; `OnUpdate` fires per
              frame) · the floor does NOT fix the approach · `MAX_CLOSING_SPEED` 30 is NOT ours
           ✓  POLL_MIN 0.10 owns the CROSSING · MAX_CLOSING_SPEED 100 (= `TELEPORT_VMAX`) owns the
              APPROACH · both move together or neither does anything · R, the floor and the ceiling
              are ONE relationship: `R_min = v_ceiling x POLL_MIN / 2 = 5`
           →  A11.2f · A11.2a · `sensor.lua` · A10.3e-R

    RI-36  Q  the model is not specific enough on CONSTRUCTION — how does a store become runnable?
           O  TWO PHASES, named by what they do: BUCKET, then STAGE.
           ✗  "pre-load" is NOT a term any more · the sensor is NOT the designator · construction is
              NOT the sensor's
           ✓  BUCKET once per run, MAY fail and should fail LOUDLY · STAGE per advance, MAY NOT fail
              · **if STAGE can fail, BUCKET did not do its job** · the bucket IS the stage; steps are
              the bare rows; a childless stage is an item of one
           →  model §A5b rows 23-27 · `bucket.lua`

    RI-37  Q  an open band has no wire spelling — which of three?
           O  RETIRED — the premise was wrong. There is no open band.
           ✗  `Rule.OPEN` is NOT a data state (it was the pure rule's fallback, since deleted) ·
              the picker does NOT go below 2.5
           ✓  the menu is CLOSED and floors at 2.5 · a store `band` of nil means the AUTHOR DID NOT
              PICK (RI-2), not "open" · the conversion is PER FIELD: stage/step -> 0, band -> 2.5
           →  model row 27 · A11.2h · `rule.lua`

    RI-38  Q  who DESIGNATES the current bucket?
           O  the ROUTE MANAGER — the one stateful owner.
           ✗  NOT the sensor (its own output would change its input mid-poll) · NOT `Bucket.Stage`,
              which hands out any stage asked for
           ✓  the manager owns `currentStage` with the completion ledger · the sensor RAISES, the
              manager PERFORMS the swap, after a poll returns · `FirstStage`, not 0
           →  A12.1a · A12.5a · A12.6a · §4b

    RI-40/41  Q  a stage-0 sequence, and two beacons sharing one step cursor?
           O  DISSOLVED BY THE STRUCTURE, not ruled on.
           ✗  `left`/`right` pairing is NOT expressed in authoring — it was a construction of the
              implementation · `[stage][step]` is NOT the shape · `Stage:Step` is NOT composed at
              runtime (row 11 forbids storing properties in a key)
           ✓  one bucket PER STAGE holding BARE ROWS · stage says WHICH BUCKET, step says WHICH ITEM
              · several items may hold Step:0 — always-eligible is a VALUE, not a slot
           →  model §A5b row 23 · RI-41's drain

    RI-44  Q  the development line items — when, and does any chain run first?
           O  BOTH CHAINS, the defect today, the engine on synthetics — with ONE sequence note over
              the pacing.
           ✗  the reader's screen does NOT come first · A/B client testing is NOT how we prove ·
              Dungeon Routes does NOT prove what Run already proved
           ✓  **Dungeon Run to RICHNESS first** · the bench proves on SYNTHETIC rows · Dungeon Routes
              EARNS everything Run proves · Chain 1 leads, Chain 2 to proof depth, Chain 3 waits
           →  `driver_architecture.md` §7 · RI-44's chains

    RI-46  Q  the object pane needs 714 on a 600 ceiling — fold, grow, or both at once?
           ⚠⚠ **THE QUESTION'S PREMISE WAS FALSE WHEN ASKED (staleness sweep, 2026-08-21).**
              714 was an ESTIMATE; §446 MEASURED 535 and §449's three landings brought it to
              **575, under the 600 ceiling.** There was no ceiling problem. ★ The OUTCOME below
              survives on Battlewrath's own reason (*"not leaving interfaces all over the users
              UI"*) — **the ruling was right and the argument for it was not.**
           O  NONE OF THE THREE. DOCK / UNDOCK moves from a later job to a NOW job.
           ✗  the pane does NOT have to hold everything · 600 is NOT the side panel's budget · no
              zone defaults folded to make room
           ✓  the bolt-on has the MAP SURFACE'S vertical extent · sized to FIT THE LARGEST CONTENT ·
              a group has ONE declaration and TWO arrangements · the way back is carried by the pane
              that left, plus a dock-all strip
           →  `driver_ui_scope.md` D-C · A10.9a-h
           ⚠ SCOPED 2026-08-24 (AL-50, via RI-76): **this row is about the UNIFIED PANE'S GROUPS and
              does not generalise.** The remote's two tabs are MODES of one widget — same texture,
              FIXED, no undock and no return band. ⟶ The dock-all strip and the way-back grammar
              above are the pane's, not every tabbed surface's. ★ A named exception, because a
              reassurance that quietly stops applying is worse than one never made.

    RI-51  Q  AL-17 made four bench items — what is the sequence, and does the seeded row
                 that makes them safe exist?
           O  B4 · B0 · B1 · B2 · B3, and B1 BEFORE L1.4. ⚠ B0 was not one of the four.
           ✗  B1 alone does NOT close the hazard (`AddBeacon`/`mint` write no sense, action or
              rows, so a node only PLACED has nothing to migrate) · §462's probe was a FRESH
              beacon, not a stale one · a load-time repair does NOT reach a node minted the same
              session · `ROW_ARG_TYPE` may NOT key on the LABEL (`note` and `say` both say
              `"content"`; §4b types them differently) · B3 is NOT all three of RI-50's rows
           ✓  B0 is a VALIDATE-AGAINST-A-DECLARATION at a door, not an assignment at the mint
              (WA: `Private.validate` in `PreAdd`, one declaration seeding · filling · repairing)
              · the arg type keys on the ACTION, as `ROW_ARG` does · B1 precedes L1.4 or two
              authored truths run live · B2 guards the impossible case once B0 exists
           →  `Reconcile_inbox.md` RI-51 · `ARCHITECT_INBOX.md` AI-6 · AL-17 · §4b

    RI-51b Q  where does the term for "nothing to wait for" live, and what does the author see?
           O  ✅ THE FACING WORD IS RULED (Battlewrath): **"Select a sense type"** — a PROMPT,
              not a state name. Internal expression is ours. ⚠ THE REST IS FILED, NOT SETTLED.
           ✗  the term is NOT a verb — a no-op in `ROW_ACTIONS` is a timing property in a verb's
              clothes, the fault `set`/`ratchet` were struck for · the facing word is NOT the
              code word · "not set" does NOT name the behaviour, only the author's absence ·
              WA's shape does NOT transfer whole (its default trigger evaluates FALSE forever;
              ours must COMPLETE, or the run stalls where WA's aura merely never shows)
           ✓  the sense position is where WHEN lives, and `routes.lua:1304` already rules the row
              answers *"at which edge"* — a terminator is that question with NO EDGE · the code
              word names the dumb action, the adaptor carries the facing one (⚠ measured:
              `adaptor.lua` carries NO sense word at all, so the code word is what the author
              reads today) · a waypoint and an unconfigured node are the SAME DATA on purpose
           ⬜ OPEN, AI-6: the fourth sense word is a §4b edit (three → four, "closed set") and
              the seed's ACTION value (S1 the pair is the unit · S2 a no-op verb). **Logged as a
              DIRECTION with its boundary named, not as a settled term.**
           →  `ARCHITECT_INBOX.md` AI-6 · RI-51 F1 third pass · `routes.lua:1304,1306,1320`

    RI-49  Q  `Next(Type, arg)` and `role` + `setStage` — two vocabularies for one thing?
           O  **`Next` IS A STORE FIELD THE STORE OWES** (architect, via AI-9 → AL-21).
              `role`/`setStage` is the **OLD PANE'S SPELLING**, live until A10.3 replaces the
              pane, then MIGRATED into `Next` and the ordinal by the store hook.
           ✗  the manager does NOT read `role` (`NodeDone` reads `lone` and `step`, nothing
              else) · BUCKET does NOT convert role → nextType — there is no conversion ·
              `role` is NOT dead and must NOT follow `goTo`/`fireOn` (both RETIRED, named here
              only as the precedent) into removal · it is NOT
              a separate concern that stays either
           ✓  `contract.lua` DECLARED `nextType`/`nextArg` all along — **the declaration was
              ahead of the store** · the mapping is deterministic: complete → Stage · set+N →
              Set(N) · start/update → POSITIONS (ordinal 1 / no ordinal) · one store field, one
              door, one `NodeDone` branch · `Set N` makes §4b's recovery escapement authorable
           ★  **THE ANALYST'S CHECK STOPPED A REMOVAL AND THE ARCHITECT KEPT THE CORRECTION:**
              I measured that `role` IS read (`AcceptanceOf` → `object.lua`) one step before
              proposing it be retired — and their answer was sharper than mine:
              **"the reason it is read is the reason it is temporary."** My reading B said
              *separate concern*; theirs said *same concern, old spelling*. **Both true, in
              sequence** — B describes the code, theirs describes where the field belongs.
           ⚠  AND THE PROCESS CORRECTION THAT PRODUCED IT (Battlewrath): *"The system is not to
              refer a question with a better question."* I had the measurement that separated
              four readings and was going to file the four, better-described. **Measurement
              that decides must be reported as a decision.**
           →  `ARCHITECT_LOG.md` AL-21 · AI-9 · §4b (corrected in place) · A12.5c/d/e ·
              A12.2h and A13.4 (both RETIRED by the addendum)

    RI-49b Q  what does an ABSENT `Next` mean, and does it need a word?
           O  **ABSENT IS AN OUTCOME; which one is DERIVED from position** (§479's landing,
              TAKEN as the rule by AL-21's addendum).
           ✗  NOT a fourth word · NOT a degenerate `Set` (a Set with no arg is half-stated and
              the guard refuses it) · a ZERO node's absent Next is NOT `Stage` — which is what
              retires AL-18's *"tray-0 incomplete until authored"*
           ✓  ordinalled → **Step** (dry → next stage present) · zero node (stage-0 beacon or
              step-0 child) → **NOTHING FOLLOWS** · explicit → the instruction either way · the
              MANAGER emits the derived decision, so the absence is auditable at the right layer
           ★  **IT REPLACES A GUARD WITH A DISTINCTION:** an unauthored tray-0 beacon is an
              **UPDATER**; a **RECOVERY** beacon is one given `Set N`. Two node kinds where the
              retired row saw one error.
           ⚠  **STILL OPEN, and it is the fall-out's #2** (Battlewrath): *"every node must auto
              to do nothing, where most nodes are expected to advance."* MEASURED: `mint` writes
              no ordinal and `NextOrdinal` has no production caller, so **every child placed
              today is a zero node** — and the architect's own mapping says `start` = ordinal 1,
              which **nothing mints**. The derivation is right; the population it lands on is not.
           →  §4b THE SEED (corrected in place) · A12.5d · RI-49's fall-out

---

# 2026-08-22 — WHAT THE ARCHITECT'S DAY CHANGED IN ACCEPTANCE

_★ These are NOT drained inbox items and they are NOT a second copy of `ARCHITECT_LOG.md`, which
carries the rulings and their reasoning. **This section carries only what each ruling CHANGED IN A
ROW** — which is the Analyst's half and lives nowhere else. Read the AL entry for why; read this
for what moved._

    AL-26  ⟶ DR_Process_18 load-bearing ⟹ sourceable.
           ROWS: the R_FLOOR pairing is the BENCH's one assertion, not a doc change. **Three
           CONCEPT HOMES written** — `trigger` · `arg` · `r-and-band`, to `concepts/next.md`'s
           shape. ★ A home POINTS; an index that restates is the second copy that drifts.

    AL-23  ⟶ Trigger is TWO latches, per tab AND per node.
    AL-35    ROWS: **A12.4b and A10.3k both said "a NODE field, not a row field" and were WRONG** —
           that was §4b's wording before AL-23. Corrected. **A10.3l NEW** (the offered default is
           shown; flipping is one click — the derived read STRUCK). **A10.3m NEW, owed** (the
           node-level control has no door).

    AL-32  ⟶ the floor SET {preceding, current, next}, derived at build, permissive.
           ROWS: **A11.2i NEW**, four fixtures. ★ The doorway flap the item was filed for is
           **inside the set by construction** — dissolved, not handled. And *permissive* is the
           load-bearing word: a membership test that cannot create a silent stall.

    AL-33  ⟶ DR_Content_20, a vocabulary retires the way a field does: one source, STAMPED not deleted.
           ROWS: **A5.6 NEW.** Its mutation is the state `Routes.ACTIONS` was actually in — delete
           the entry instead of stamping it and the checker goes green while a second list still
           offers the word.

    AL-30  ⟶ the ACTOR is opt-in; `say` is CONSTRUCTED; no free text meets an executable path.
    AL-31    ROWS: **A12.10a–d NEW, one set.** ⚠ And RI-50's owed rows were written INTO it rather
           than beside it: **AL-31 superseded RI-50's framing (*"the arg is raw text"*) before its
           rows were ever written**, so grading them separately would have preserved a dead framing
           in two of four.
           ⬜ A12.10b is WRITTEN AHEAD and says so — the code still carries `say` as a user string.

    DRILL3 ⟶ #0 tested against the governing set and the code; section B handed here.
           ROWS: B1 **A12.7a would have FAILED CORRECT CODE** (`Set(1)` at stage 3 → it tested
           "the run is at 1"; AL-23 rules `max`, so a correct build stays at 3). B1b A12.5c
           tightened. B2 above. B4 `supertrack` stamped in three docs. B9 band up/down struck.
           ★★ **AND THE ROW'S PROSE NEEDED THE SAME FIX AS ITS TEST:** *"steps the run to N
           wherever the reader is"* → **forward to N, or leaves it.** A recovery beacon can carry
           a lost reader ON; it can never send one BACK.

    ⚠⚠ **TWO GATES WERE RED AND BOTH WERE THE ANALYST'S.** `emit_built_state` REFUSED because
    A12.4e's `grades` line cited `Routes.TRIGGERS`, a TABLE — **drill 3 handed that to the bench
    and it was not theirs.** `check_inbox` failed on RI-57 drained without a row.
    ★ A `grades` line names a FUNCTION a criterion can be RUN against; a vocabulary is what that
    function READS. ⟶ The same distinction that makes coverage meaningful is the one that broke it.

---

    RI-57  Q  should the sense rule gain a FLOOR test, given the node most likely to need it is
              the doorway — where the label flaps 20% A→B→A in the corpus?
           O  **YES, as a SET test** (architect via AI-13 → AL-32, on Battlewrath's refinement):
              `{preceding, current, next}`, DERIVED AT BUILD, riding the characteristic record.
           ✗  NOT a single-floor equality test · NOT sticky state in the rule — it stays PURE ·
              NOT a runtime patch (the bench's four options all patched at runtime) · zero nodes
              (step 0 · stage 0) do NOT floor-gate at all
           ✓  a positioned node listens on the three-floor set, derived where `ledTo` and
              `trigger` already resolve · the runtime test is MEMBERSHIP on two or three integers
              · PERMISSIVE — a sample with no floor falls through; only a missing mapID refuses ·
              `floor` joins the bucket's whitelist
           ★  **THE DOORWAY QUESTION DISSOLVES RATHER THAN BEING ANSWERED** — a flap between
              adjacent floors is inside the set BY CONSTRUCTION. And the zero-node wrinkle the
              bench named resolves by STRUCTURE, not luck: since zero nodes never gate, **the
              floor-gated set IS the led-to set.**
              ⟶ His refinement is what turned it into a build-time answer: *"the sequence to
              reaching that location will most likely be a 2-pattern match across waypoints."*
              **A set removes at BUILD what four options were patching at runtime.**
           ⚠  **Honestly bounded, and the architect said so:** no overlapping-area false fire has
              been observed — this buys correctness *not yet needed*, at one carried field. And
              **the at-speed flap rate is UNMEASURED** (DR_Process_19: a measurement, the bench's, when a
              fast transition is in the corpus).
           →  `ARCHITECT_LOG.md` AL-32 · §4b THE FLOOR SET · ⬜ **A11.2 row + fixtures are the
              Analyst's** (the flap fixture passes · a floor outside the set refuses · nil falls
              through · zero nodes never gate)

    AI-6   Q  does the seed need a FOURTH sense-word for "nothing to wait for", and what is the
              seeded row's ACTION?
           O  ❌ NO to the word (AL-18). The seed is **`When on` with NO ACTION** — arrival IS the
              behaviour of a placed node. A row's ACTION is OPTIONAL. The closed set of three stands.
           ✗  there is NO node with nothing to wait for — a lure, a recovery beacon, a skip's
              landing all wait for the player · `whenOn` was NOT missing (`sensor.lua:46`: *"was
              out, is in"* — arrival, shipped) · a no-op does NOT enter `ROW_ACTIONS` · a HIDDEN
              escapement (timeout / auto-skip) is NOT wanted — a false advance that hides stalls
           ✓  every armed row carries its OWN escapement, and the seed's is ARRIVAL (Battlewrath's
              frame) · a row with no action completes the instant its sense fires · an ADDED row
              starts UNSET, is incomplete and told, and is never armed · a tray-0 seed is
              incomplete until its `Next` is authored · Every-time completes on its FIRST fire
           ★  **THE ASKER'S FAULT, LOGGED BECAUSE IT IS MINE.** I argued from the VOCABULARY —
              *"at which edge"* has a degenerate answer — and never asked WHICH NODE has no edge.
              None does. **A closed set gaining a member for a case with no instance:**
              [[dont-extend-past-the-evidence]] in its stated shape, and
              [[show-the-instance-not-the-category]] is the check I had on the shelf and skipped.
              ⟶ The half that survived: *self-termination is about WHEN* was accepted — the answer
              to "when" for a placed node is **when the player gets there**, a word we already had.
           →  `ARCHITECT_LOG.md` AL-18 · §4b THE SEED · A13.1–A13.5 · A12.2g/h · A12.4d/e/f ·
              A12.5a (amended) · ⚠ A13.3 is the Analyst's own finding, not AL-18's

✅ **THE TEN OWED ROWS ARE BELOW, WRITTEN 2026-08-21 FROM EACH ITEM'S OWN DRAIN TEXT — read,
not recalled.** ⚠ They were held back deliberately for a day: a wrong IS / IS NOT line in an INDEX
is worse than a missing one, because the index is what people read instead of the item.

---

# 2026-08-26 — THREE ITEMS THAT ANNOUNCED THEIR OWN COMPLETION, VERIFIED AGAINST SOURCE

_★ Each heading claimed it was finished. RI-55 sat open two days after its own resolution and its
own words were *"a row that describes its own resolution while still flagged OWED is the shape a
reader trusts and should not."* ⟶ So each was checked against the SOURCE, not the heading — and one
of the three was not finished at all._

    RI-83  Q  `check_interface` could not tell "no sizes declared" from "all sizes agree".
           O  **CLOSED AND PROVEN CLOSED** — `sizes: 5 declared size(s) parsed and compared`, and
              the mutation that found it now BITES. Found by mutation, not by reading.
           ✗  the first landing did NOT close it. `hosted: N surface(s)` is true and answers a
              NEIGHBOURING question — how many surfaces correctly have no size, read from the
              HEADER. Breaking `SIZE` still changed nothing. ⟶ **A denominator has to be the count
              of the thing the broken guard produces.**
           ✓  the Addon creator's ruling is the durable half: **report the denominator, not a
              floor** — a floor needs a number nobody measured and goes stale; a denominator is
              derived at run time and cannot. Same law as the receipt's `can-go-red` column.
           ★  and the PARKED MUTATION was the acceptance test. Kept `[known SILENT, recorded]`
              rather than deleted, it bit the moment the denominator existed. Nobody had to
              remember what the fix was for.
           →  `check_interface.py` · `mutate_checkers.py` · history/…drained_2026-08-27.md

    RI-79  Q  the LAW PASS in his form — primitive · relates to · does not relate · lesson.
           O  **COMPLETE** (the architect's word, 2026-08-26), and verified on disk before draining.
           ✗  NOT 22 boundary essays. The measurement came BEFORE the drafting and reshaped it:
              **of 22 laws, ONE had been fought over** — `DR_UI_21` with five boundary/strike lines,
              `DR_Content_15` with one that is a RECOVERY rather than a wrong reach, **zero for the
              other twenty**. ⟶ Twenty entries read *"none yet"*, which was RI-79's own rule.
           ✓  four folds, each checked rather than taken: the primitives table in §5 · `DR_UI_21`
              compressed with its clauses at §4d · the pass record at `audit/law_pass_2026-08-25.md`
              · `AL-61`. ★ The one structural change proposed was taken — **`DR_Process_14`'s
              primitive turned on `DR_UI_21` itself**: a brief cites, it does not restate.
           →  `driver_architecture.md` §5 · §4d · AL-61 · §558

    ⚠⚠ ONE OF ITS OUTCOMES HAS SINCE BEEN OVERTURNED, and a reader needs it beside the rest. AL-61's
      fold (3) settled the L-number collision by CONVENTION and declined a rename on cost.
      **Battlewrath overruled it on that cost the next day** — *"cost isn't a concern when we can't
      discuss the same thing"* — and the rename landed at AL-62/§542. ⟶ **Fold (3) is superseded;
      folds (1), (2) and (4) stand.**

    ★★ AND THE PASS PROVED ITSELF LATER BY WHAT IT ADMITTED. It closed by naming what it had NOT
      done — *it did not verify that each law's cited home still says what the law says.* RI-80 took
      that up and **22 of 22 homes resolved and carried their law**, `DR_UI_21`'s moved clauses found
      exactly where AL-61 put them. ⟶ **A pass that names its own open edge is one somebody can
      finish.**

    RI-72  Q  any workflow or tooling issue around maintaining the middle of *what is true* and
              *what should be*? (his ask, 2026-08-22)
           O  **ANSWERED, and the answers shipped.** Drained; its burn-down moves to RI-54's queue.
           ✗  ⚠ the STATUS TOKEN was **not** the missing piece — my own first answer. With zero
              graded symbols absent, `BUILT` cannot fire and `OWED` fires on everything: **one
              input read in two directions, a coin rather than a check.**
           ✓  the root is that a row's status is PROSE, so nothing derives it and nothing can
              contradict it. ⟶ `check_acceptance.py` derives it and refuses on contradiction; the
              COUNTERPART that can genuinely disagree is **the code citing the row by id** (`--queue`);
              and the honest ceiling — *"UNSTATED IS NOT A FAILURE"* — prints every run, because the
              number measuring the tool's blindness has to stay on screen.
           →  `check_acceptance.py` · RI-54's queue · history/…drained_2026-08-26.md · §557

    ★★ AND ITS OWN BURN-DOWN WAS OPTIMISTIC, measured today. Step 2 listed twelve rows as *"near-zero
      cost — the identifier is already sitting in the prose."* ⟶ **Never twelve:** 5 graded, **2 were
      later declared UNINSTRUMENTABLE** (`A11.4b` · `A11.6b`) and were never candidates, and `A9.5`
      is a desk comparator rather than a driver function. **Four remain**, and they are in RI-54 now
      — **one home per fact**, since two items tracking one backlog is the second copy this project
      refuses.

    ⚠ THE SIGNAL IT RESTED ON IS THE ONE MEASURED UNRELIABLE TODAY — *a name in a row's prose*. And a
      function CALLED in a smoke is no better: `Manager.Stop` is called four times and asserted
      **zero**. ⟶ **Read for the assert, never the call.**

    ★ Its standing answers keep their own homes: the bench needs **no directed Analyst-to-bench
      inbox** (a directed channel invites `how`, and `how` is theirs), and the address the bench
      actually lacks is a **`grades` line** — guidance-proof by construction, because you cannot
      smuggle a solution into a function name.
    ⟶ And the fault it called *"mine alone, not tooling"* — three shell-heredoc manglings — is now
      **mechanically prevented rather than remembered**: the PreToolUse hook refuses shell-authored
      Python, and it has fired correctly on this seat since.

    RI-50  Q  acceptance owed for three arg-safety rows; the guard is the bench's.
           O  **BOTH HALVES ALREADY DELIVERED.** No action.
           ✗  NOT open. Each row exists and names RI-50 as its source: **A12.2j** (type and cap
              read from a declaration, built §473) · **A12.10c** (*"the arg is a COMPARAND: never
              a pattern"*) · **A12.10d** (the closed verb, `loadstring`/`__index` refused by name).
           ✓  and the bench's half shipped: `bucket.lua:381` enforces `type(row.arg) ~= rule.type`,
              `:395` the cap, and `ROW_ARG_RULE` declares `{ type, source, max }` per action.
              ⟶ The item's §464 table — *"`arg = { evil = true }` BUILT"* — is **five days stale**;
              that route is refused today.
           →  `driver_manager_acceptance.md` A12.2j · A12.10c/d · `bucket.lua:381,395` · §553

    ★★ ROW 2 HOLDS BY ABSENCE, and that is worth saying precisely rather than counting as enforced.
      Measured across `rule.lua`, `sensor.lua`, `manager.lua`: **no pattern function touches an arg
      anywhere** — the tier's only `:match(` is a file-path parse in a loader. ⟶ The property is
      TRUE **because nothing does the dangerous thing, not because something stops it.** A12.10c is
      the row that would notice if that changed, which is why the item called it *"the one that
      would be missed."*

    ⚠ A12.10c and A12.10d carry NO mutation, and that is LEFT ALONE deliberately. `bucket.lua` sits
      outside the harness's file map, and his ruling of 2026-08-26 is not to extend testing into
      that tier until it can be properly simulated. ⟶ **Named, not built.** A coverage gap recorded
      beats coverage added against a simulation we do not have.

    RI-56  Q  the R bounds want a model home; and the band's ceiling — is anything owed?
           O  part 1 CLOSED in the model; part 2 owed nothing and still does not.
           ✗  part 2 is NOT an open build. The word was *"undefined"* and the `10` arrived hedged
              with the reason it might be wrong — **building it would turn a hypothesis into a
              bound that later reads as decided.**
           ✓  `driver_data_model.md` now carries `R_FLOOR` (DERIVED), `R_CEILING` (⚠ **his
              judgement, NO derivation** — recorded as ruled, not measured) and `R_STEPS` (the
              picker's OFFER, whose ENDS are the bounds). All three verified shipped first.
           →  `driver_data_model.md` · `routes.lua:1184,1203,1204` · §550

    ★ A THIRD CASE JOINED THE PER-FIELD CONVERSION BLOCK, AND IT IS NOT A CONVERSION. `stage/step`
      go `nil → 0`, `band` goes `nil → 2.5`, and **`radius` is REFUSED BY NAME** — once the mint
      carries the floor, a nil radius can only mean pre-default data. **Three fields, three answers
      to the same absence**, which is why the block says *"BUCKET converts by field."*
    ⟶ And what a reader most needs from it: **A10.3e-R enforced the floor AT THE PICKER; his word
      moved it to THE MINT.** A node is drivable the moment it exists, not when someone opens a pane.

    ★★ THE BENCH CORRECTED ITSELF INSIDE THIS ITEM, BY MEASURING. It first proposed settling the
      band ceiling from the corpus — group points by the client's `floor` label, read the gap
      between groups. The mechanism works and **the conclusion does not, because `floor` does not
      mean height** (his: *"a cat walk above the entry"*). Withdrawn after 24 corpus files and 8
      (map, floor) groups. ⟶ **A filed read corrected by its own filer, with the data shown** — the
      shape worth keeping.

    RI-59  Q  should the migration CARRY `x.sense` for data already on disk, or is it lost?
           O  **CARRY IT** — and the question's own framing was the thing to correct.
           ✗  NOT a question about data already on disk. `routes.lua:273`: *"until L1.4 moves the
              pane onto rows, a pane edit still writes a flat field."* ⟶ **The pane writes
              `child.sense` TODAY**, and `migrateNode` fires on exactly those nodes.
           ✓  so *"accepted as lost"* would accept **a growing set, not a fixed one** — every node
              authored between now and L1.4. HELM has Chain 1 STOPPED at L1.2, so the window is
              open and not closing soon. **That is the difference between a bounded historical gap
              and a leak.**
           →  `routes.lua:326,330` · history/…drained_2026-08-26.md · §548

    ★★★ A SECOND FINDING THE ITEM DID NOT NAME — the migration writes a THIRD value.
      `SENSE_DEFAULT` is `reachHere` and `Routes.Sense(x)` resolves an unset CHILD to it, while
      `migrateNode` hardcodes `whenOn`. ⚠ **But that is not a defect on its own, and saying so
      matters:** `SENSE_DEFAULT` answers *what does an unset child do*, and a migrated ROW's
      `whenOn` is **AL-18's seed ruling** — the seed row is `When on` with no action. **Two
      different questions, two right answers.** ⟶ The fault is only that the migration uses the ROW
      answer for a field the AUTHOR had already answered.

    ⚠⚠ AND A BOUNDARY THIS NEARLY CROSSED, made explicit because it is thin. **RI-72 already ruled
      that `how` is the bench's** — *"a directed channel invites `how`… the Analyst would fill it,
      too."* I filed RI-81 to them carrying **the literal line**, which is that fault with the
      address changed. Corrected: the item they read now carries **the criterion and the reason**,
      and nothing else. ⟶ The line stays HERE, because this is the ANALYSIS RECORD and the analysis
      genuinely reached it; removing it would make the record less true. ★ **The split is DIRECTED
      versus RECORDED** — what I hand a seat is a criterion; what I keep of my own reasoning may be
      as specific as the reasoning got.

    ⟶ THE BUILD IS NAMED, NOT MADE: `{ sense = x.sense or "whenOn", … }` at both row sites. **The
      `whenOn` fallback STAYS** — changing it would alter behaviour for nodes whose author never
      picked a sense, which is a different question and not the one asked. Criterion writes itself:
      *a child authored `whenOff`, migrated, has a row whose sense is `whenOff`; a child with no
      authored sense still migrates to `whenOn`.*

    ⚠⚠⚠ **CORRECTED SAME DAY (Battlewrath): I OVERSTATED THE URGENCY, and the correction is exact.**
      *"'On migration' is an over state. No beacon / child could be fully authored right now."*
      ⟶ **There is no author losing a sense today**, because the surface cannot author a node
      end-to-end — RI-65/RI-66 have the boss listener unbuilt and the test drive faking it with a
      button. ★ I took a true fact (`routes.lua:273`: the pane still writes flat fields) and
      extended it into *"a growing set"* and *"every day converts more authored senses into
      unrecoverable ones."* **The measurement proved the WRITE PATH exists; I claimed AUTHORS were
      using it.** [[dont-extend-past-the-evidence]], and the third time this week the same shape.

    ⟶ THE ANSWER IS UNCHANGED AND THE REASON IS BETTER. `migrateNode` returns early once a node has
      rows, so **a node that migrates with `whenOn` can never be repaired by re-running it** — the
      field is orphaned permanently at that moment. ⟶ So the line lands **BEFORE authoring
      completes, not because it already has**: fix it while the window is still shut, because the
      one-shot makes every loss after that point unrecoverable. **Not urgent. Ordered.**

    RI-47  Q  `bucket.lua` gated authored words on the DISPLAY table (`Adaptor.Has`).
           O  FIXED, and verified in the shipped source.
           ✗  NOT a question and NOT still open. `bucket.lua:86` now reads
              `Routes.SENSE_WORDS or Routes.ROW_ACTIONS`.
           ✓  the distinction is the durable part: **`ROW_ACTIONS` answers "may an author write
              this?"; `Adaptor.Word` answers "what does a human see?"** — and A5.1 passes a miss
              through, so **a display table can never be a gate.**
           →  `bucket.lua:86` · history/…drained_2026-08-26.md · §547

    RI-48  Q  L2.4's arg half — the heading said NO QUESTION LEFT, the body said the third part
              needed someone's word.
           O  no contradiction. The filer answered it himself, by precedent.
           ✗  NOT outstanding: `Routes.ROW_ARG.supertrack = nil` already carries it, and an arg on
              `supertrack` can only arrive from a hand-edited SavedVariables or an importer.
           ✓  ★ his line, and it is this seat's rule written by the other side of the bench:
              **"an answer from the repo is not a question for Battlewrath."**
           →  history/…drained_2026-08-26.md · §547

    RI-53  Q  his own: *"should we build a defaults store… one pane of glass?"*
           O  **ANSWERED — and the build is NAMED BACK, not made.**
           ✗  ⚠ NOT a defaults store as it looks. Of 14 module constants only **TWO** are defaults;
              8 are caps/floors and 4 are identity. **A store built from what LOOKS like defaults
              would have had two members** — the scattering he could see is not defaults at all.
           ✓  `contract.lua` is ALREADY the pane of glass: every field with its type, optional-ness,
              ZERO MEANING and a `why`, and **already the one place reconciling STORE form against
              RECORD form per field.** ⟶ `seed =` on the entries that have one. No new module, no
              new file, no new convention. Field-level seeds go in; the SEED ROW (a whole RECORD)
              stays at its door and POINTS.
           →  `contract.lua` · history/…drained_2026-08-26.md · §547

    ⚠⚠ AND RI-53 WAS NOT EXECUTED, which the drain says out loud. Measured today: **`seed =` appears
      nowhere** — not in `contract.lua`, not in any register. The reasoning is finished and lives
      here; **the build is the bench's**, because `contract.lua` ships and a doc conclusion is not a
      licence to edit shipped code. ★ Same shape as RI-75's second half and RI-78's code half:
      **drain the analysis, name the build.**

    ★★ THE PATTERN ACROSS THE THREE: two headings were honest and one was optimistic — RI-53 read
      as settled and its recommendation had never landed. ⟶ **An item that announces its own
      completion is a claim, and the check is the source.** Open count 13 → 10.

---

# 2026-08-25 — THE ARC CLOSES: the rename, the pass's open check, and one premise of mine that was wrong

    RI-80  Q  two cleanups and one assurance — "any clean up work for reconcile? Or assurance?"
           O  all three done; **the rename-and-pass arc has no open edge left.**
           ✗  the assurance is NOT "the cites exist" — that is the cheap half and it was already
              implied. The question was whether each home still SAYS what the law says.
           ✓  **22 of 22 laws walked. Every cited home resolves; every home read carries its law.**
              `DR_UI_21`'s clauses ARE in §4d where AL-61 moved them, stamped and pointing back —
              which was the highest-risk item, being one day old.
           →  `driver_ui_acceptance.md` · `interface/map.md` · §5's homes · §544

    ★★★ AND THE MECHANICAL HALF NEARLY REPORTED TEN FALSE DRIFTS. My resolver flagged 10 of 22, and
      **every one was the resolver, not the record**: `§3a`/`§4b`/`§4d` are `###` subsections and it
      read only `##`; `A11.3`/`A11.4`/`A11.9` are FAMILIES whose members exist; `RI-4`/`RI-15` sit
      in `history/` under an indented heading. ⟶ **A resolver that is too strict manufactures drift
      exactly as a sweep that is too loose manufactures collisions** — the same fault, opposite
      sign, and this week produced one of each.
    ⚠ THE HONEST EDGE, named rather than counted as covered: `DR_Content_1..14` cite files and
      use-case sections rather than a `home:`; their cites RESOLVE and were spot-read, not walked
      line by line. Smaller than the sentence the law pass closed with, and still an edge.
    ⟶ CLEANUP 1: `args.run` → `args.curate` at exactly the two sites predicted. ★ The other two
      lanes were always right, so the drift was ONE WORD OF THREE — **the kind that reads as fine.**

    RI-78  Q  the register half of the map's right-click retirement.
           O  three sites in `interface/map.md`, DR_Content_20's form, with the LIGHT version RESERVED.
           ✗  NOT a retirement of right-click OWNERSHIP, and NOT of right-click PANNING in
              `map_controls.md` — a different gesture that merely shares a button. Said out loud
              because **a stamp invites over-reading.**
           ✓  `right-click → Object pane spawn` · retired 2026-08-25 · AL-59. §69's other two
              gestures stand: hover reads, left click selects and pins.
           →  `interface/map.md` · §544

    ★ The code's own note says best why it went WHOLE: *"`RightButtonUp` is no longer REGISTERED,
      rather than registered and ignored: **a gesture that fires a handler which does nothing is not
      retired, it is hidden.**"*

    RI-77  Q  `check_sheet.py` exits 2 — keep the inexpressible capture and skip it, or drop it?
           O  **SPENT. Neither.** The UI seat fixed the tool and the question dissolved.
           ✗  ⚠⚠ **MY PREMISE WAS WRONG.** I wrote *"the cause is capture data, not the tool."*
              It was the tool: `derive_quantum` tested with an ABSOLUTE tolerance, so a
              configuration with larger widths failed on SIZE ALONE. Relative now (UL-17); config
              12 reads `275/275 on the grid`.
           ✓  what the item got right, and they kept it: *"a checker that exits 2 every run is a
              checker whose red carries no information."* The inert-guard shape from the other side.
           →  history/…drained_2026-08-25.md · UL-17 · §544

    ★★★ THE LESSON IS EXACT AND IT IS MINE. I stash-tested and proved *"exit 2 predates my edit"* —
      TRUE — then wrote *"the cause is capture data."* **The measurement proved NOT-MY-EDIT and I
      extended it into A CAUSE.** [[dont-extend-past-the-evidence]], on a day I carried that memory
      in the band. ⟶ The honest filing was one clause shorter: *exit 2, pre-existing, cause unknown.*
    ★ And their finding was bigger than mine would have been: **the same absolute-tolerance fault in
      three tools that week.** A wrong diagnosis that is FILED still bought the right investigation.

---

# 2026-08-24 — TWO FROM THE UI SEAT, AND BOTH ANSWERS WERE SMALLER THAN THE ASK

    RI-70  Q  mutation coverage has rotted — 13 anchors match nothing (14 on re-measure).
           O  **15 measured; now 1, and that one is parked.** 329/350 biting -> **343/350**.
           ✗  NOT obsolete guards, and nothing was retired. ⚠ A rot count reads like dead
              coverage; **the guards were ALIVE and the ANCHORS had moved.**
           ✓  14 re-anchored + 1 `expect` corrected. The mint's `tonumber(stage)` became `want`;
              the outcome's old line now lives in the COMMENT above the live one (which is why an
              exact match found 0x); `NextOrdinal` grew a byte-identical `while used[n] do n = n +
              1 end`, making three anchors AMBIGUOUS rather than missing; and **RI-22's retirement
              of `bandDown`** left five anchors naming the three-value era.
           →  `addons/tools/mutations/dungeonrun.json` · §536

    ★★★ A DEAD ANCHOR HID A SECOND FAULT UNDERNEATH IT. *"ReachOf invents no default while R2 is
      unruled"* re-anchored cleanly and then reported `~~ WRONG`: the mutation writes `x.bandUp or
      2.5` — it defaults the **BAND** — while its `expect` named the **RADIUS** assertion, which a
      band-defaulting mutation can never trip. ⟶ **It could not have bitten on its own message even
      when the anchor was alive.** The harness's `~~ WRONG` verdict is what surfaced it, which is
      the verdict's whole reason for existing.

    ⚠ RESIDUE NAMED, NOT SWEPT: **5 are `[PENDING the Actions profile pass, §365]`** and were left
      deliberately — `adaptor.lua` records `bossEngaged` STRUCK (RI-15), and **retiring what the
      bench parked is not clearing rot**. **2 are `~~ WRONG`** from assertion ORDERING inside the
      smokes, not anchors; `mutate.py`'s legend names the fix (*"Order the precise assertion
      FIRST"*) and it is a test-file edit.
    ⚠ NO SHIPPED LUA CHANGED — only the spec. The harness verifies its own restore and `git status`
      agrees. ★ Every narrowing reaches for BRACKETING CODE, never a comment — `mutate.py`'s own
      ruling, and the one whose breach produced this rot.

    RI-55  Q  three acceptance rows read OWED while the code reads BUILT.
           O  **ALREADY SATISFIED on 2026-08-22. No change needed.**
           ✗  NOT a live divergence: A12.2b/f/g each carry `✅ BUILT (verified 2026-08-22)` with the
              refusal string quoted, and `check_acceptance` reports **contradictions 0**.
           ✓  they were cleared incidentally, the same day the checker was built to find them —
              and the ITEM stayed open for two days afterwards.
           →  `driver_manager_acceptance.md` · §536

    ★★ THE ITEM BECAME THE SHAPE IT NAMED. Its own words: *"a row that describes its own resolution
      while still flagged OWED is the shape a reader trusts and should not."* ⟶ **An inbox item
      that describes its own resolution while still flagged OPEN is that shape one layer up.**
      Work that resolves an item incidentally does not close it, and neither side noticed.

    RI-76  Q  the architect's three record corrections, his word already given — no question.
           O  DONE — at **FIVE sites, not the one named.**
           ✗  NOT a ruling to make. AL-49/AL-50 are logged and AL-50 carries Battlewrath's word
              (*"That all tracks. Confirmed."*); this was the records catching up.
           ✓  the test drive's home is **the REMOTE's second tab** (Run capture · Test drive) —
              corrected in `interface/drive.md` ×3 and `interface/remote.md` ×2, old readings kept
              as dated headstones. `remote.md` gains the two tabs as an **☐, never a built claim**.
              AL-13's grammar needed no interface site at all; the record that needed it was **my
              own log row** for RI-49, now scoped so the pane's way-back grammar is not generalised.
           →  `interface/drive.md` · `interface/remote.md` · history/…drained_2026-08-24.md · §535

    ⚠ `UI_LOG.md:119` still carries AL-47's original derivation and was LEFT ALONE deliberately —
      it is the UI seat's log, `UI_LOG.md:42` already carries the correction above it, and a log is
      a history. Cross-bench reference is allowed; writing their record is not.

    RI-75  Q  two ☐ that predate this week — reconcile `Layout.H`, and a duplicate specimen list.
           O  one CLOSED, one NAMED BACK.
           ✗  `Layout.H` vs the measured heights is **NOT a number question**, and answering it as
              one manufactures a 120% error on the edit box that does not exist.
           ✓  THREE populations, each correct where it lives — `Layout.H` = the CLIENT's template
              declaration · `object.lua` = what our hand-built pane actually sizes · the measured
              set = what an ACEGUI widget becomes. **The discriminator is now written where the ☐
              was: ask which widget stack the surface is built on.** No shipping code changes.
           →  `dungeonrun_interface_inventory.md` · §535

    ★ `check` shows all three at once — template 26, our chip 20, AceGUI 24: **three right answers
      to three different questions** ([[a-name-is-not-a-use]]). ⚠ And it implies NO migration:
      **AL-46 scopes the Ace3 default to the PLUMBING** and says outright it *"does NOT extend to
      the layout/offline domain."* I started to reason the other way and the ruling stopped it.

    ⟶ The duplicate specimen list in `COA_DevDump/sheet_decl.lua` is a code deletion in a shipped
      file. **The dev manages the tree**, and a doc disagreement is not a licence to cut code — so
      it is named back with the item's own reasoning intact.

    ★★★ THE PATTERN IN ALL THREE ITEMS TODAY: **a correction filed against one site had more sites,
      every time.** RI-73 named 1 of 2; RI-76 named 1 of 5. ⟶ **The grep the filer suggests is the
      floor, not the answer** — and it is free to widen it before touching anything.

    ⟶ FILED BACK: **RI-77** — `check_sheet.py` exits **2** on the tracked tree, on configuration 12
      (`3620x2036 @ 1.0`, *"no common grid"*), while the other eleven agree to ~1e-7. Proven
      pre-existing by stashing my edit and re-running. ⚠ Its own message is the cost: *"nothing
      below would mean anything."* **A checker that is red every run has a red that carries no
      information** — the inert-guard shape from the other side.

    RI-73  Q  `ui_overhaul_scope.md` says *"575px in a 330px pane"*; panes are written width-first
              everywhere else here, so `330px pane` reads as a WIDTH. Fix?
           O  YES — and at **TWO sites, not the one the item named.**
           ✗  NOT a disagreement between documents. There is none: 330 is the height the wireframe
              measured against, and `object.lua` has shipped 600 since §104.
           ✓  both now read *"in a pane 330px TALL"* with the supersession named. ★ The item found
              `:71`; `:362` carries the identical sentence inside the paragraph that settles §101.
              **A misreading found once has a second home more often than not**, and the grep is free.
           →  `ui_overhaul_scope.md` · history/Reconcile_inbox_drained_2026-08-24.md · §534

    ⚠ THE ITEM'S OWN FRAMING IS THE PART TO KEEP: *"nothing is wrong, and that is exactly why it
      bites."* ⟶ **Two documents that agree can still cost a false claim**, because the cost is in
      what a sentence AFFORDS a cold reader, not in whether it is true. It cost the UI seat a
      published retraction (UL-9).

    RI-74  Q  do the three measured TEXT formulae get lines in `Constants, sourced`?
           O  YES — but **TWO lines, not three.**
           ✗  NOT an Analyst taste call. `check_sheet.py:276` already states the pattern: it
              *"REFUSES rather than defaulting"* because *"a fallback would be the copy this
              function exists to abolish."* ⟶ The record decided it; this was an APPLY.
           ✗  And NOT three new constants. **`q = 3 × aspect / (10 × uiScale)` was already
              registered** as `TEXT_GRID_COLUMNS = 2560`: `768 / 2560 = 0.3 = 3/10`, exactly.
              Checked against the tool's own measurements, not the algebra alone —
              `1920x1200 @ 0.64` measures `0.7500000761`, and `3 × 1.6 / 6.4 = 0.75`.
           ✓  it landed as a THIRD LINE ON THE EXISTING ENTRY (the OFFLINE form, written because
              offline there is no `GetScreenWidth()` to divide by). **Two expressions of one
              constant in ONE place is a home; in two places it is the second copy.**
              NEW and genuinely new: `q_v = 8 / (15 × uiScale)` and `advance = round(size/q_v)×q_v`.
           →  `dungeonrun_interface_inventory.md` → Constants, sourced · §534

    ★★ AND THE 16:10 ROW IS WHY BOTH QUANTA EXIST. The WIDTH quantum tracks the **screen's own**
      aspect — at 1920×1200 nominal 16:9 would predict `0.8333`, and it measures `0.75`. `q_v` uses
      the NOMINAL 16:9. ⟶ **That difference is the whole reason there are two**, and it is what the
      0.0123% gap measures: one mechanism seen at two aspects, never two mechanisms.

    ⚠ The per-font `k`/`c` table stays EMITTED and cited, never copied — the item said so and it is
      right. **A formula is a sourced CLAIM a reader can check; the table is an ARTEFACT.** That is
      the same line this section already drew, and it is why `check_sheet` was re-run afterwards: an
      edit inside a machine-read section has to prove the machine still reads it.

---

# 2026-08-23 — THE FALSE LOCKOUT, AND WHAT A SKILL'S FIRST RUN FOUND

    BOOT   Q  the `boot` skill's first real run printed **"LOCKED OUT - addons holds it, not
              analyst. Until then: repo-read-only. Do not commit."** Was this seat in breach?
           O  **NO — this seat IS addons.** Battlewrath, 2026-08-23: *"Addon Creator, Opus 5
              Analyst, Design Architect are the current addon residents."* Three seats, ONE
              bench, ONE trunk lock between them.
           ✗  NOT a close-out failure and NOT an unreleased hold. ⚠ I reported it as one — took
              a true thing (the tool printed LOCKED OUT) and extended it into an organisational
              diagnosis it does not support. [[dont-extend-past-the-evidence]], same day I
              carried that memory in the band.
           ✓  `boot.py` compared STRINGS: `mine("addons", "analyst")` is False because one is
              not a substring of the other. It had no concept of a seat belonging to a bench —
              so it told **two of the four seats not to commit, on every single boot.**
           →  `operations/boot.py` SEATS map · §530

    ⚠⚠ WHY A FALSE STOP IS WORSE THAN A SILENT GUARD. This bench has recorded seven guards that
      printed green while checking nothing. This is the other failure and it is more expensive:

          OBEYED    legitimate work halts. Two seats read "repo-read-only" and stop.
          IGNORED   the seat is trained to discount the guard — and then it cannot be trusted
                    on the day the lockout is REAL, which is the only day it matters.

      ★ An inert guard fails to EARN trust. A false stop SPENDS it.

    ⟶ THE FIX, and the shape of it. A declared `SEATS` map resolves both the holder and the lane
      to a BENCH before comparing; unmapped names resolve to themselves, which is the old
      behaviour untouched. The output now separates *yours* from **YOUR BENCH holds it, taken as
      <holder>** — because a bench-mate's hold is not a lockout but IS a coordination fact, and
      collapsing them would hide that someone else on the bench has motion in flight.
      ⚠ ONLY WHAT WAS STATED IS MAPPED. `class-identity` / `suno` look like the same relation and
      are deliberately NOT assumed: **a guessed org chart is a guessed lockout.**

    ★★ AND THE REGRESSION THAT MATTERED MORE THAN THE FIX: a repair that unlocks EVERYONE is the
      worse bug. Verified per lane — `aura`, `macros`, `class_design`, `suno` still lock out —
      and mutation-tested three ways (empty the map · stop resolving · collapse the bench-mate
      case into *yours*). **All three bite.**

    ⟶ ALSO: the wrong model was written down. The ALIASES comment read *"the two DungeonRun seats
      that are NOT the addons bench"* — which is **why** `mine()` was never taught about them.
      Corrected in place. ★ The defect was not in the code first; it was in a sentence.

    ⟶ AND `mutate_checkers.py` could only reach its OWN directory, found the moment it was
      pointed at a checker in `operations/`. A harness titled "the CHECKER desk" that sees one
      desk is this session's scope fault one layer in. A tool name with a `/` is now
      repo-relative. 11 mutations, 0 unexplained.

    ★ WHAT THE OTHER SKILL FOUND, first query: `grades_candidates.py` — *"which acceptance rows
      COULD carry a `grades` line, and what the evidence for each would be."* **I did not know it
      existed**, after a full session on the adjacent question of which rows can carry a STATUS.

---

# 2026-08-22 — THE INSTRUMENT: WHY THE STATUS WORD WAS NEVER THE MISSING PIECE

_★ Not a drained inbox item — RI-72 stays open on its burn-down. This is the one SUB-QUESTION that
closed, and it closed against my own filed position, so it is recorded where a cold reader meets it._

    RI-72  Q  should the 58 graded-but-unstated acceptance rows each be given a status word?
           O  NO. **The token was never the missing piece — the COUNTERPART is.**
           ✗  NOT a sweep, and NOT "derive it carefully instead of cheaply". ⚠ My own filed
              position said *don't derive the token from existence*; that was too weak. **ZERO
              graded symbols are absent from the shipped code**, so existence is the ONLY signal on
              the far side: `BUILT` (19 rows) has an arm that CANNOT FIRE ON ANY ROW, `OWED` (5)
              fires instantly on anything. One input read in two directions — **a coin, not a
              check.** Only `RETIRED` compares two independent things, a headstone being a doc fact.
           ✓  the code CITES THE ROW BY ID, and a human wrote that citation at build time — so it
              is independent of whether any symbol exists. **43 graded rows state nothing while the
              code already names them**; each is settled by reading ONE citation. A worklist with a
              source, drained on touch, never a verdict and never a failure.
           →  `check_acceptance.py --queue` · Reconcile_inbox RI-72 · §525/§526

    ⟶ THE WORKED INSTANCE that proves the counterpart is real: **`A8.4`'s head still reads *"LIVE
      DEFECT: `composeId` bakes the route NAME into the key"* while FIFTEEN sites in `routes.lua`,
      `store.lua` and `promoter.lua` say the opposite** — among them *"`composeId` IS GONE, not
      parked"* and `Routes.MigrateRIDs`, the migration the row asks for. ★ **Six checkers on this
      desk and not one could see it**, because every one compares a doc to whether a SYMBOL exists.
      ⚠ THE SITES ARE NOT COPIED HERE ON PURPOSE — `--queue` emits them, and a hand-copied line
      number is the citation rot `check_cites.py` exists to name. **The doc cites the TOOL.**

    ⟶ FIRST ROW DRAINED, SAME DAY. **`A8.4` was stale and is now BUILT §335.** The struck text is
      kept, not deleted. ★ VERIFIED BY RUNNING, because a citation says the bench THOUGHT ABOUT the
      row there and never that it is satisfied: `smoke_dungeonrunroutes.lua` carries A8.4's M1-M7
      against proposition §23's criterion - including M4, *a colon in the name round-trips*, which
      is the exact defect the row went on calling live - and `smoke_dungeonrunpromoter.lua` asserts
      the id is the counter alone. **Both green.** ⟶ Queue 43 -> 42, `checked` 22 -> 23.

    ⟶ AND THE HARNESS LANDED: **`addons/tools/mutate_checkers.py`** plus its self-test. It breaks a
      declared guard, runs the tool, and asks the only question that matters about a guard - **if I
      break it, does anything notice?** Per-tool part is DATA; the signature is the tool's whole
      output, so there is no comparator to get wrong. ⚠ A rotted anchor FAILS rather than skips,
      and the restore is verified byte-for-byte, because it rewrites real checkers on disk.
      ★ IT CAUGHT A FAULT IN ITSELF ON ITS FIRST RUN: the `-R` mutation read SILENT because
      `check_acceptance`'s DEFAULT output prints only the queue's COUNT. **A signature taken from
      the default output is a scope that excludes the evidence** - [[the-scope-protected-the-claim]]
      inside the instrument built to find it. Fixed by declaring each tool's LOUDEST flags.
      ⟶ 8 mutations across three checkers: 7 bite, 1 recorded as knowingly unreached.

    ⚠⚠⚠ AND THE FAULT THAT NAMING IT COST, recorded because it is the worse of the two today.
      **I wrote the new harness straight over `addons/tools/mutate.py`, which already existed** — a
      342-MUTATION suite for the LUA SMOKES, many sessions old, carrying six bad tests, one live
      bug and its own ruling (*a mutation anchor is CODE, never PROSE*). I used `Write` on a path I
      had never read. ⟶ Restored from `HEAD~1`; mine is now `mutate_checkers.py`, and each header
      points at the other. ★ **A new tool's NAME is a claim about what already exists**, and that
      claim was checkable in one command before I wrote a line — the same shape as
      [[the-basis-includes-the-other-benches]]: the answer was already in this repo.
      ⚠ It is also the second time in one day I built while the evidence sat one lookup away.

    ⚠ TWO THINGS THIS DOES NOT SAY. (1) That a row stating BUILT with no citation is stale — all
      four such rows landed the same day, so uncited most likely means YOUNG. Only the PRESENCE
      direction has a proven instance. (2) That a citation settles the row. It says the bench
      thought about it there; which side is stale is still a person's read.

    ⚠⚠ AND A FAULT IN THE METHOD, MINE. I filed my position to `Reconcile_inbox.md` before spawning
      two agents, to make its independence provable in git — which made it **discoverable**, and both
      quoted it back. ⟶ **True about timing, false about content.** A prior read goes to the
      scratchpad and lands after. ★ [[subagents-are-a-second-read-not-extra-hands]] assumed the
      second read would be blind; on a shared repo that has to be arranged, not assumed.

---

# 2026-08-19 / 20 — THE OLDER SET, caught up

_★ These predate or barely overlap this Analyst's tenure. **Three of them record a fault of the
Analyst's own** (RI-19, RI-22, RI-26) and are kept in that shape on purpose._

    RI-39  Q  is A11.5a's *"V1 has no stage"* about the READOUT only, or about the data?
           O  NEITHER, quite — his wording is finer than the question. **The DATA has stage.**
              What V1 lacks is a **LOCAL, READABLE EXPRESSION** of it. *(Battlewrath: "it has
              stage in the editor. Just no local, readable expression.")*
           ✗  V1 routes are NOT stageless · `AddBeacon` minting a stage is NOT the fault · the
              row is NOT a claim about the store
           ✓  every authored route carries stages 1..N · V1 REPORTS the IN set by address and the
              per-target first-hit index · `stage` is not a RESULT at either level
           ★  **IT NAMES WHERE STAGE DOES BECOME READABLE:** the reader's NOTE PANE (A10.8a,
              *"stage / step · the note"*). ⟶ Two surfaces, one of them V1's — the row read as a
              claim about DATA because it was written before the reader's surface had a home.
              ⚠ §435's walk stopped the literal reading becoming code: pinning at stage 0 handed
              out only the recovery beacon. `Bucket.FirstStage` was DERIVED, not chosen, and
              survives unchanged.
           →  A11.5a (reworded) · A12.3a · `Bucket.FirstStage`

    RI-45  Q  does A10.2b MEAN Ace's option table, or NAME a property? — and can A10.3i close
              E-0's author side alone?
           O  **(b), the bench's read — and the ambiguity was MINE.** And **NO** on the second:
              A10.3i depends on A10.3g/h.
           ✗  A10.2b does NOT mandate Ace's option table · `Spec` is NOT superseded · the
              `check_interface` 1:1 join does NOT move · do NOT route two independent dropdowns
              through `SetRow` · do NOT invent a half-authored-row policy to close E-0 early
           ✓  A10.2b names the PROPERTY — *declared, not hand-placed, with a get/set per control*
              · `panespec.lua`'s `Spec` satisfies it, is BUILT and is checked 1:1 · which renderer
              the pane uses is the BENCH'S (mechanism is gears) · **a tab is added AS A UNIT, so a
              row is complete when it exists** · the container is already vendored
           ★  **the bench was right to REFUSE to invent the policy**, and the item also caught a
              false comment on `Spec.Build` that would have misled the sizing.
           →  A10.2b (reworded) · A10.3i (dependency stated)

    RI-19  Q  `walk.py check` cannot reach W1 or W5 — is the golden watch blind?
           O  ❌ WITHDRAWN. **Never true.** Fixed at `5725b7d` §376, an ancestor of HEAD before
              the session that filed it began.
           ✗  `check` does NOT miss bodies (it prints `BODIES: W1 PASS · W5 PASS`, one exit code
              for all five) · A9.5's note was NOT current · the source read did NOT show a defect
           ✓  A11.7a's rewording is the right criterion — one command over every body, one exit
              code, hooked to landing — and it is **SATISFIED, not red**
           ★  **THE MECHANISM, which outlives the item.** `main()` builds its aggregate at
              `walk.py:1777-1783` — **inside the very range I read and reported on** — and I ran
              the tool through `tail -6`, which cut the `BODIES` line that would have refuted me.
              I inherited a stale claim and then read source looking for a defect I already
              believed in. **Confirmation, described as measurement.**
              ⟶ [[the-scope-protected-the-claim]] with a second scope: the OUTPUT was trimmed too.
           →  A11.7a · `walk.py:1754,1777-1783` · ⚠ the coverage sub-agent inherited this as its
              O8; that report is history and is NOT corrected in place

    RI-22  Q  does BAND become option bands, and does the reach door need a guard?
           O  **THE BAND IS UPWARDS ONLY** (Battlewrath, best working model).
           ✗  NOT a pair, NOT symmetric, NOT named pairs — **the option-shape question dissolves
              because there is no downward half.** ⚠ `bandDown` / band-as-a-pair is RETIRED by
              this ruling; it appears below only as the shape being named · downward tolerance measures NOTHING (ROUTER
              280: a unit's z IS the base point, so a sample is the floor) · the W5 goldens do
              NOT move — they are produced with bands OPEN and say so in their own header
           ✓  ONE upward value · default **2.5** · placed ADVANCED (*"more of an advanced option
              than every day setting"*) · the store holds **THE NUMBER**; the choice is a lookup
              · up-only is `band_down = 0` — **not a signature change**, the rule already takes
              the two separately. ⚠ The pair form is RETIRED; it is named here, not used.
           ★  **BOTH OF US HAD IT WRONG FIRST.** He recalled the tests as "up 2.5, not ±";
              measured, W3.2's candidate passes BOTH ways (`walk.py:1360`) and W1.7's fixtures
              say ±2. I claimed the change moved every W5 golden; it moves W1.7 and W3.2 only.
           →  A1.3's raw-nil wording · W1.7 · W3.2 · `setReach`'s third argument · A10.3e

    RI-24  Q  two store fields have no consumer — keep them or drop them?
           O  ⚠ **THE QUESTION WAS THE WRONG ONE.** The field is not speculative, it is **wrongly
              sourced**, and the disposition is neither keep nor drop: it is REPLACED.
           ✗  `route.author` is NOT speculative · **nothing scraped about the character may leave
              into export** (Battlewrath) — that is disclosure the author never made
           ✓  OUT: `author = UnitName("player")` (`routes.lua:121`), scraped AND travelling ·
              IN: **who / when / author notes**, typed by the author or left empty · WA's
              precedent — it does not disclose the authoring character or account
           ⚠  WIDER REACH, named not acted on: `runs[].character` is the same field minted the
              same way. A run is EVIDENCE and never travels (`store.lua:61`), so it is not a leak
              today — **whoever builds export meets this sentence before they meet that one.**
           →  RI-4's law (the origin on someone else's data does not travel)

    RI-26  Q  G5 — what is the export/import REPRESENTATION?
           O  **A SERIALIZED STRING, TWO-STAGE LOAD.**
           ✗  NOT chat (ROUTER:123 — the chat edit box caps at 255 letters; a route is ~2 KB) ·
              NOT two libraries we do not ship · A4.17's version-prefix deferral does NOT survive
           ✓  AceSerializer → LibDeflate compress → `EncodeForPrint`, behind a **VERSION PREFIX
              from the first string** · decode and PRESENT (map, route name, bosses) then accept —
              the WeakAuras shape · a MULTI-LINE edit box · **the preview is FREE**: it needs only
              the two side tables A2.6 already defines and the driver never opens
           ★  **THE COST CLAIM WAS ASSERTED WITHOUT LOOKING** — mine. LibDeflate is on this
              machine TWICE and bundles the encoders, so it is ONE library, and WA uses it on this
              fork. ⟶ A4.17 is overturned by this and by nothing else: under an opaque blob, a
              decode failure and *"this is from a newer version"* are the same event.
           →  A4.17 (overturned) · G5 · A2.6's side tables

    RI-27  Q  `Trigger` — what is it, and what is its default?
           O  **TWO AXES, HELD APART.**
           ✗  *retry while incomplete* is NOT a control — it is the DEFAULT BEHAVIOUR, ended by
              completion · the two axes are NOT one thing, **and conflating them is what made this
              item circle for an afternoon**
           ✓  retry-while-incomplete = the default · **run-again-after-complete = TRIGGER, default
              NO, opted into per node** · both his cases are STAGELESS and want opposite answers
              (a recovery beacon must not re-set once consumed; a course-correct marker should
              speak whenever you are there) — only expressible because the second axis is authored
              · the opt-in is the exception; sequential is the common case
           ⚠  **Still not built and no code term chosen** (`driver_adaptor_table.md:147`). Drained
              so the DISTINCTION survives, not because a build step needed it.
           →  A12.4b · A12.4e (written ahead, AL-18)

    RI-29  Q  *"no hanging items that need reconciling"* against the file — which is true?
           O  **THE SET IS EMPTY. Development is open.** It was false when claimed; it is true now.
           ✗  a status is NOT read from a list · the bench was NOT wrong to file rather than
              accept the claim — **a status asserted against a countable fact is checkable**
           ✓  **derive, never read:** `grep "RI-[0-9]* DRAINED"` gives the drained; every other
              `## RI-` heading is open. That convention is what made the item answerable at all.
           ★  it corrected ITSELF mid-write when RI-19 changed under it, which is why its count
              was five and not six. ⚠ Its own measurement (*"0 stamps anywhere in the file"*) is
              now false — **closed by events**, and recorded rather than quietly dropped.
           →  the file's stamp convention · `check_inbox.py`

    RI-30  Q  two documents that landed in the same pass disagree on the ROW's fields.
           O  **THE BENCH WAS RIGHT; one line fixed.**
           ✗  `trigger` is NOT a row field — a grep for a stored trigger across the addon returns
              **NO HITS**, on a row or on a node
           ✓  `driver_stored_state.md` §2 reads `ROW  sense · action · arg`, matching the shipped
              row at `routes.lua:1057` · it wanted a CORRECTION, not a ruling
           ★  **the bench FILED rather than edited, because the file is the Analyst's.** That is
              the right call and it is why the disagreement was caught instead of absorbed.
           →  `driver_data_model.md:31-38` · `driver_stored_state.md` §2 · `routes.lua:1057`

    RI-31  Q  do the remaining five audits follow the first three into `history/`?
           O  **THE FIVE FOLLOW THE THREE** (Battlewrath).
           ✗  the question the bench ASKED — do they mislead? — was not the deciding one
           ✓  his condition was **a test and it was run, not judged**: is it cited from a governing
              or basis document, and is what it is cited FOR carried where it is cited? All five
              passed both halves · 1,393 lines moved, every `audit/` pointer re-aimed, no stale
              pointer outside `history/`
           ★  **HIS REASON IS SHARPER THAN THE QUESTION.** He answered on DUPLICATION: a finished
              audit restating a settled conclusion is another text an agent reads as CURRENT, and
              it can drift from the one that governs. **Source of truth and pointers.**
           →  `history/` · DRIVER_BASIS's audit sections

    RI-32  Q  A2.10a is silent on a stageless node that carries a stored outcome.
           O  **AS BUILT, PLUS THE TELLING.**
           ✗  NO refusal — §81 forbids validation on authoring, so (c)'s refusing half is out ·
              the value is NOT lost · **a builder does not fill a criterion's silence with a
              string**
           ✓  the strict read stands (`Outcome` answers nil for a stageless node) · the editor
              SAYS SO when the value is stored · the message must be ACCURATE — **stored and
              DORMANT, not lost**, because giving the node a stage revives it
           ★  **THE BENCH FOUND THE ANSWER AND COULD NOT TAKE IT**, and that was the right
              boundary to hold: the row was silent, and inventing a message is not the builder's.
           →  A2.10a · §81

    RI-35  Q  A11.4b says `R` and `band` arrive as INDEXES; RI-22 said they are NUMBERS.
           O  *"Indexes is complete. User pick. R 5 the lowest. 2.5 above the lowest offered."*
              ⟶ **the menu is CLOSED, the user PICKS, the store holds the NUMBER.**
           ✗  the index is NOT a live lookup the driver performs · R does NOT go below 5 · the
              band does NOT go below 2.5
           ✓  R's offered list floors at 5 · band's list ALSO floors at 2.5 and runs UPWARD —
              **2.5 is the minimum and the default at once** · A11.4b's index framing is finished
           ★  **MOST OF IT WAS ALREADY ON DISK and the bench read one of two files.** `R = 5` was
              ruled in RI-34 the same day, and 12a already said *"the choice is a LOOKUP"*. ⟶ What
              is genuinely NEW is the word **"complete"**: the offered set is CLOSED, which is what
              makes an index well-defined at all. Under either reading `sensor.lua` is unchanged.
           →  A11.4b (headstone) · #3 §A3b 12a · A10.3e

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

## RI-58..71 · the §501 gap list, reconciled 2026-08-23

_Ten of fourteen. ⚠ **RI-59 · 65 · 66 · 70 stay OPEN** — re-measured and still true,
and the governing set did not take them up. One of the ten is a WITHDRAWAL._

    RI-58   Q  the pane's action door offers a RETIRED vocabulary and `SetRow` has no caller,
              so nothing in the client can author note/say/boss
           O  TAKEN UP and gone further. `driver_architecture.md` carries it as ◐ DIVERGENT and
              SEQUENCED; `ARCHITECT_LOG` ruled the vocabulary half - the pane reads the LIVE
              set, a sweeper reports an offered retired word, `Routes.ACTIONS` goes.
           ✗  the fix is NOT a bigger dropdown · `Routes.ACTIONS` is NOT kept beside the live
              list
           ✓  the pane reads the live set · a sweeper reports a retired offer · the rows wire
              LAST, after the Ace interface and the settled homes

    RI-60   Q  the arg has no door at all, and its two origins (picked-from-run vs
              typed-and-capped) differ
           O  HOUSED. `concepts/arg.md` is the concept home; the picked/typed split is carried
              there rather than in an acceptance row.
           ✗  a single arg field is NOT enough · a picked value is NOT capped
           ✓  the arg follows the ACTION word · boss is picked and uncapped · note/say are
              typed and capped at 255

    RI-61   Q  `SetRow` takes an INDEX and every tier below the pane is list-shaped; the pane
              models one row
           O  TAKEN UP. Carried in `driver_architecture.md`'s pane row and sized against
              A10.3c's regenerated per-object group.
           ✗  a second dropdown is NOT the shape
           ✓  a ROSTER, the same idiom as the child roster one level up

    RI-62   Q  AL-23's latch is in the store and resolved in the bucket, and no control sets it
           O  HOUSED. `concepts/trigger.md`, with the manager brief carrying the two-latch
              rule.
           ✗  one control does NOT author it - it is per-TAB and per-NODE
           ✓  `once` is the safe default that ships today · `every` is what AL-23 was ruled FOR

    RI-63   Q  AL-19's LED TO tick is *ON by default, ticking it off is the author's choice* -
              and nothing writes `node.ledTo`
           O  TAKEN UP in `ARCHITECT_LOG` and the architecture doc.
           ✗  the default does NOT store anything - §79
           ✓  only an author's OFF is written · the position rule stays DERIVED, never stored

    RI-64   Q  §495 built `R_STEPS` and `Routes.StepR` and the pane still offers a bare text
              box
           O  HOUSED. `concepts/r-and-band.md`, with the ladder in the authoring brief.
           ✗  the rungs are NOT a constraint on the field
           ✓  the ladder is the picker's OFFER · only the two bounds are enforced · the box
              stays typeable

    RI-67   Q  `Routes.SetChildIcon` has no caller in any pane
           O  TAKEN UP in the authoring brief.
           ✗  it is NOT urgent, and filing it was to stop it being rediscovered as a defect
           ✓  the wiring pass decides DELIBERATELY whether the icon is authored or derived

    RI-68   Q  `Routes.Place` / `Unplace` have no caller at all - the map drag is unwired
           O  ❌ WITHDRAWN. The premise was false. `map.lua:1845` calls `R.Place(...)` through
              `local R = NS.Routes`, shipped §68.1 on 2026-08-14.
           ✗  the drag is NOT unwired · a literal `Module.fn(` grep is NOT a use check
           ✓  the finding came from an alias-blind hand scan, the same fault
              `emit_built_state.py` had been fixed for days earlier — see
              [[a-name-is-not-a-use]]

    RI-69   Q  `SetNext` has no door and AL-21 says leave it until A10.3 - filed so a wiring
              pass does not wire it by mistake
           O  READ, and the deferral stands. `concepts/next.md` is the home.
           ✗  `SetNext` must NOT get a door in the wiring pass
           ✓  AL-21 defers role → Next until A10.3 replaces the pane

    RI-71   Q  `SuperTrackerUtil` is guarded by a `_G` test and a `pcall`, so an absent global
              is silent - and its presence on this fork was never verified
           O  TAKEN UP in `driver_walk_acceptance.md`.
           ✗  our own CALLS to it are NOT evidence the client defines it
           ✓  the guard stays · one live probe settles presence · a silent arrow is
              indistinguishable from an unticked LED TO
