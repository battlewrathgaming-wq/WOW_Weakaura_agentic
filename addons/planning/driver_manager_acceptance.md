# ROUTE MANAGER — acceptance (A12.x) — the test brief for the one stateful owner

_Analyst (Opus 5), 2026-08-21, written against `driver_architecture.md` §4b **as accepted the same
day** (architect's proposal; Battlewrath: *"Yes. That matches."*), and at `ARCHITECT_LOG.md` AL-8's
instruction. **This brief does not restate §4b — it grades it.** Where a row and §4b disagree, §4b is
the spec and this file has drifted; where a row and a MECHANICS doc disagree, the mechanics doc wins
(`driver_architecture.md` §7)._

✅ **SUPERSEDED 2026-08-21 — THE MANAGER IS BUILT.** `manager.lua` landed at §461 (L2.6) with
**16 `Manager.*` functions**, and it is in the `.toc`. ⟶ The paragraph below was true when written
and became false the same week; it is struck rather than deleted, because a preamble is the FIRST
thing a reader meets and "it changed" is the useful part.

~~**NOTHING HERE IS BUILT.** `driver_architecture.md` §3b marks the ROUTE MANAGER as a new part;
`driver.lua` holds `state` and a `Designate` nothing calls. So every row below is a criterion
waiting for its code, and no row carries a `grades` line for a manager function — inventing one
would name an identifier that does not exist.~~

⚠⚠ **WHAT IS NOW OWED, AND IT IS THE ANALYST'S:** the rows below still cite `Bucket.*` / `Sensor.*`
only, so **the manager's own 16 functions are graded by nothing.** ★ That is a real coverage hole,
not a formatting one — `A12.1a`, `A12.5a`, `A12.6a` and `A12.9a` all describe behaviour that now HAS
an identifier to name. ⬜ Named here rather than filled in one pass, because a `grades` line is a
claim about which function answers a criterion and each needs reading.

★ **HOW IT WAS FOUND, because the mechanism matters more than the paragraph.** A staleness sweep
(2026-08-21) that resolved every build-status claim in the acceptance docs against the code.
The same day, `emit_built_state.py`'s `UNLISTED` guard refused to emit because `Manager` was not in
its `MODULES` list — **the same file, the same omission, caught by a machine and by a sweep on the
same afternoon.** ⟶ The guard caught it because forgetting REFUSES; this paragraph survived a day
because nothing reads a preamble for truth.

★ Each row names its MUTATION. A green without its mutation is UNMUTATED. The Analyst tests under
lua51 on landing.

⚠⚠ **AND THE ENGINE IS PROVEN, NOT DEPLOYED (THE BUILD PRINCIPLE, AL-12, architecture §7).**
Battlewrath: *"The bench can synthetic as it needs to prove rather than A/B client testing."*
⟶ **Chain 2 is built only as far as PROVING needs.** Every row below is gradeable on SYNTHETIC
rows — none of them requires an authored route, a client session, or the author's chain to have
landed. ★ That is a property to preserve deliberately when writing the next row: **if a criterion
cannot be met on synthetics, it is a criterion for a later leg**, and saying so beats a row that
quietly needs a deployment to go green.

---

## A12.1 · ONE OWNER, ONE ACTIVE ROUTE (§4b 0)

- **A12.1a** The manager is the ONLY holder of an Active Route's state: the offer for this map and
  the one selection · `currentStage` · `currentStep` · the completion ledger · the bucket · the
  tracker writes · the listeners · the terminal state. ⚠ **Never two active routes.**
  TEST: select a second route while one is active → the first is torn down before the second builds,
  and at no point do two buckets exist.
  MUTATION: allow the second to build first → the test sees two live buckets and bites.

- **A12.1b** ⚠ **THE MANAGER NEVER POLLS, NEVER EVALUATES GEOMETRY, NEVER INTERPRETS ON THE HOT
  PATH, NEVER MUTATES THE ARMED LIST MID-POLL.** *(RI-42; model row 26.)*
  TEST: the manager's surface contains no distance arithmetic and no `OnUpdate`.
  MUTATION: give it one → `A11.4a`'s "nothing armed, nothing running" and this row both bite.

- **A12.1c — THE OFFER (§4b 0), which this brief claimed to grade and did not.** ⚠⚠ **ADDED
  2026-08-21 (AI-2 audit B11).** A12 says it grades §4b's ten steps; **step 0 had no row.**
      the manager offers the routes for THIS MapID, and the human picks ONE
  ★ Both halves have code to grade already: `Routes.List(mapID)` (`routes.lua:335-341`) is the
  shipped map filter the editor uses, and `bucket.lua:87-90` refuses a route whose `mapID` is not
  the one asked for — so the offer and the build agree on the map by two independent paths.
      grades  Routes.List · Bucket.Build
  TEST: two routes on map A and one on map B → the offer holds exactly the two; picking the B route
  by id refuses at build, named.
  MUTATION: offer every route regardless of map → the count assertion bites before the build does.
  ⚠ §4c 3's *"all routes"* listing is a SEPARATE surface — an entry may be OFFERABLE without being
  ARMABLE (a route for another map). Not graded here; owed to A10.8 when the reader's list lands.

## A12.2 · BUILD — one anchor per stage, and it has TWO guards (AL-8)

- **A12.2a** BUILD reads the saved route WHOLE, once, and **refuses LOUDLY with a named reason**,
  and then this is the Active Route. ⚠⚠ **CORRECTED 2026-08-21 (AI-2 audit B10): this row read "or
  the route is not offered", which CONFLATES THE OFFER WITH THE BUILD.** §4b puts OFFER at step 0
  and BUILD at step 1 — **a build refusal cannot un-offer a route that was already offered by
  map.** What a refusal does is prevent it BECOMING the Active Route, which is a different
  sentence and the one §4b actually says. Model row 24: *bucket may fail and should fail loudly; stage may not.*
      grades  Bucket.Build
  TEST: a route with an unusable ordinal → refused, and the reason names the child and the beacon.
  MUTATION: return an empty bucket instead of refusing → the manager arms nothing and says nothing.

- **A12.2b ⚠⚠ OWED — THE DUPLICATE-STAGE REFUSAL. The manager MAY assume one beacon per stage, and
  this is what makes that safe.** *(AL-8, resolving AI-1.)* The guarantee has two sides and the
  runtime side is the load-bearing one:

      AUTHOR-TIME   the picker (A10.3e) — slots, no shift, no renumber, duplicates cannot be
                    authored. ⚠ STATUS ✗, and until it lands three doors still accept a second:
                    `promoter.lua:530` free-text stageBox · `routes.lua:432` AddBeacon ·
                    `routes.lua:1483` SetStage. Tell-and-trust holds here — a swap, never a refusal.
      RUNTIME       `Bucket.Build` REFUSES a second anchor at one stage, by name:
                    *"two beacons at stage N — re-slot in the editor"*. **Never tolerance, never a
                    shared cursor.** ⟶ The manager never meets a duplicate whether or not the
                    pickers have landed, and an imported pre-slot route meets the same refusal.

  ★ **MEASURED, so the exposure is not guessed:** across 12 scraped stores, 6 carry stages and
  **none carries a duplicate** — every one is `[1, 2, 3]`. The case is real in the TYPE and empty in
  the DATA. *(Analyst, 2026-08-21; cited in AL-8.)*
      grades  Bucket.Build
  TEST: two beacons at stage 1 → `Bucket.Build` returns nil and the named reason.
  MUTATION: accept the second → RI-41's measured lockstep returns, and this row bites on it.
  ✅ **SEQUENCED 2026-08-21 (AL-9, deciding F2): THE REFUSAL COMES BEFORE THE MANAGER.** D3 (one
  named line in `Bucket.Build`) is built BEFORE D6 (the manager) — *"the window is closed at the cost
  of one refusal before the part that relies on it exists"*. ⟶ **This row's OWED status is therefore
  a BUILD-ORDER edge, not an open question**, and the manager's acceptance may assume the guarantee
  because the guard lands first.
  ⚠ **BENCH'S TO BUILD** — one line in an existing refusal list. The Analyst grades it; it is not
  the Analyst's to write.

- **A12.2c** Every action word is BOUND to its callable at build; nothing authored is interpreted on
  the hot path. *(Model row 25.)* ⚠ `Bucket.Resolve` is the declared hook and the runtime holds no
  binder yet — `smoke_bucket` asserts it stays nil, which is correct until the binder lands.
  TEST: an unknown action word → refused at build, named.
  MUTATION: resolve it at dispatch instead → the refusal never fires and row 25 is unmet.

### ⟶ A12.2d–f · THE ISOLATION DEMONSTRATION — the condition RI-23 stands on

_Written 2026-08-21 at `ARCHITECT_LOG.md` **AL-10**'s instruction. ★ Battlewrath let the
IDENTITY/BEHAVIOUR split stand — the behaviour record carries the ADDRESS only, stage and step ride
the characteristic record once per node — **ON CONDITION THAT THE SEQUENCE IS PROPERLY DEMONSTRATED**,
and then *"the instruction set becomes the MANIFEST"*. ⚠ His reason is the one that makes these rows
load-bearing rather than ceremonial: **SavedVariables load WHOLESALE**, so isolation cannot come from
loading less — *"it must come from BUILDING FROM ONE RID ONLY, keyed by address."* These three rows
ARE the demonstration; without them R2 is unsatisfied and RI-23's repetition question reopens._

- **A12.2d — ONE RID IN, NOTHING ELSE OUT.** Two routes on one map with lookalike records: the
  bucket built for RID A contains **no record of RID B**, by address.
  ★ **Satisfied by construction today** — `Bucket.Build` calls `Routes.Get(rid)` and reads ONE
  route; there is no path by which a second route's node enters. **The row exists to PROVE it, not
  to ask for it**, because "isolated by construction" is exactly the claim a wholesale-loaded store
  makes people doubt.
      grades  Bucket.Build
  TEST: two routes on one mapID whose beacons carry the same stages, ordinals and positions → build
  A, and assert every entry's address begins `mapID:A`.
  MUTATION: build from the route TABLE rather than the RID → B's records appear and the address
  assertion bites on the first one.

- **A12.2e — THE COMPOSED GATE EQUALS THE PREFIX.** For every behaviour row, the gate the bucket
  composes equals the prefix its characteristic record carries — **the same manifest a combined line
  would have produced, so nothing is lost by not repeating.**
  ⚠ **PARTLY TRUE TODAY, and the difference is worth stating rather than smoothing.** The gate is on
  the NODE (`stage`, `step`, `address` at `bucket.lua:227-244`) and rows are NESTED under it
  (`rows[i] = { sense, action, arg }`, `:221`). That is EQUIVALENT — every row is reachable only
  through its node, so it inherits exactly one prefix — but it is not literally *"composed per row"*.
  ⟶ Either shape satisfies the demonstration; **the row grades the EQUALITY, not the layout.**
      grades  Bucket.Build
  TEST: for each row in a built bucket, the prefix reachable from it equals its characteristic
  record's `mapID:rid:bid:cid` + `stage` + `step`. Assert on every row of a multi-node route.
  MUTATION: let one node's `step` differ from the value its rows resolve under → the equality fails
  and names the row.

- **A12.2f ⚠⚠ OWED — NO SILENT ORPHAN.** A record whose address resolves to no characteristic is
  **REFUSED at build, named** — never carried, never dropped quietly.
  ✅ **BUILT (staleness sweep, 2026-08-21).** `bucket.lua` is headed *"★★★ A12.2f · NO SILENT ORPHAN"*
  and refuses with *"%s, row %d: address %s:%s resolves to no characteristic"*. ⚠ **The row's own
  suggested grep now hits — which is the useful part: the check it told you to run is the check
  that proves it stale.** ~~NOT BUILT: `Bucket.Build` has no orphan check.~~ Its fourteen named refusals cover unusable ordinals, missing radius, unplaceable
  nodes and unknown vocabulary — not an address with nothing behind it.
  ★ Why it belongs to the demonstration: the manifest's whole claim is *"what can be true right
  now"*. A behaviour row whose node does not exist is a row that can never be true, and carrying it
  silently is precisely the confusion between lookalike tables the isolation exists to prevent.
      grades  Bucket.Build
  TEST: plant a behaviour row whose `cid` names no child → build REFUSES and the reason names the
  address.
  MUTATION: skip it silently → the built count is short by one and nothing says why.
  ⚠ **BENCH'S TO BUILD** — one more named refusal, same list as D3.

- **A12.2g ⚠ OWED — THE EMPTY NODE IS REFUSED, BY NAME (bench item B2).** A node carrying no
  behaviour record is REFUSED at build: it could never complete and would arm, point and stall in
  silence. *(AL-17; §4b.)*
      grades  Bucket.Build
  TEST: a node with zero rows → build REFUSES and the reason names the node.
  MUTATION: build it → the built count is RIGHT and the run never advances; nothing says why. ★ That
  is the whole argument for the refusal — the failure is invisible to every other row here.
  ⚠⚠ **SEQUENCE, MEASURED: this row cannot be graded before A13.1.** Every route authored to date
  carries zero rows (§462's probe), so A12.2g alone refuses the whole corpus. **A13.1 first.**

- **A12.2h ⚠ OWED — A TRAY-0 NODE WITHOUT AN AUTHORED `Next` IS REFUSED AT BUILD.** The authoring
  half is A13.4; this is the build half, and both exist because a default `Next` from stage 0 lands
  on stage 1. *(§4b, AL-18.)*
      grades  Bucket.Build
  TEST: a stage-0 node whose `Next` is the default → build REFUSES, naming the missing `Set(N)`.
  MUTATION: allow it → a reader who walks past recovery is reset to stage 1, and the run looks like
  it restarted rather than like it failed.

## A12.3 · ARM (§4b 2)

- **A12.3a** `currentStage` = the LOWEST POSITIVE stage present; `currentStep` = its lowest positive
  ordinal. ⚠ Stage 0 is *always eligible*, **not "the first stage"** — a recovery beacon is not where
  a run begins. *(RI-39; §435's walk found this by failing.)*
      grades  Bucket.FirstStage · Bucket.FirstStep
  TEST: a route with stages 1..3 and a stage-0 beacon → arms stage 1, plus bucket 0.
  MUTATION: pin the start at 0 → only the recovery beacon arms and the route does not run.

- **A12.3b** The sensor is armed with **the current stage's bucket AND bucket 0**, together.
      grades  Sensor.Arm · Bucket.Stage
  TEST: advance the stage → the gated set changes and bucket 0's members do not. *(A11.3d.)*
  MUTATION: arm the stage alone → recovery stops working after the run moves on.

- **A12.3c** The manager writes the stage's ENTRY LURE to the tracker on arming. ⚠ **Tray-0 items
  never write the arrow** — recovery is observed and corrected, not steered. *(AL-6.)*
  TEST: arm a stage whose bucket 0 holds a beacon → the tracker carries the stage's lure, not the
  recovery beacon's.
  MUTATION: let bucket 0 write → the arrow points at recovery from the first sample.

## A12.4 · DISPATCH (§4b 3–4)

- **A12.4a** The sensor returns, AFTER the poll, the nodes that CHANGED, by address, with the
  transition word — When on · Seen · When off. The manager runs only the tabs whose sense-word
  matches. **Each tab is self-completing; none waits for another.** *(§4; RI-42.)*
  TEST: a node entered and left across three samples → When on fires once, When off fires once.
  MUTATION: return the whole in-set instead of the changed set → tabs re-fire every sample.

- **A12.4b** `Trigger` says once or every time. ⚠ **NOT BUILT and no code term is chosen** — the
  slot is declared so the shape does not move when it lands. *(`driver_adaptor_table.md:147`.)*

- **A12.4c — LISTENERS DISARM ON `When off`, not only on ADVANCE.** ⚠⚠ **ADDED 2026-08-21 (B11).**
  A12.6b grades disarm at the stage swap; §4b step 4's own parenthesis — *"(disarmed on When off)"* —
  was ungraded, and it is the more frequent case: a reader leaves a node's reach mid-stage and its
  CLEU listener must go with it.
      grades  Sensor.Poll
  TEST: enter a node whose tab arms a listener, leave it → the listener is gone before the next poll.
  MUTATION: disarm only on advance → a boss killed anywhere later in the stage still completes that
  tab, and the test bites on the stale listener.

- **A12.4d — A ROW WITH NO ACTION COMPLETES THE INSTANT ITS SENSE FIRES.** ⚠⚠ **ADDED 2026-08-21
  (AL-18, and the FRAME forced it):** Battlewrath — *"the waiting is the manager with a row that has
  no escapement when no instruction is set."* ⟶ **Every armed row carries its own escapement; the
  seed's is ARRIVAL.** Without this line the seed has none in the ledger's own terms (A12.5a: *"a tab
  completes when its action finishes"* — there is no action to finish).
      grades  the manager's ledger · Manager dispatch
  TEST: the seed row fires on arrival → the tab completes in the SAME pass, and the node completes
  if it is the only row.
  MUTATION: wait for an action → every placed-but-unconfigured node stalls, which is precisely the
  fault the seed exists to prevent.

- **A12.4e — `Every time` COUNTS COMPLETE ON ITS FIRST FIRE.** Later fires re-run the ACTION and
  never touch the ledger — else *"every time"* would be a row that never completes. ⚠ **WRITTEN
  AHEAD:** A12.4b records that `Trigger` is not built and no code term is chosen; the shape is
  declared so it does not move when it lands. *(§4b, AL-18.)*
      grades  the ledger · Trigger (unbuilt)
  TEST: an Every-time row fired three times → the ledger records ONE completion; the action ran
  three times.
  MUTATION: complete on every fire → a node that has already completed can UN-complete, and the
  ledger is rewritten behind the advance.

- **A12.4f — NO HIDDEN ESCAPEMENT. THE NEGATIVE ROW.** ⚠⚠ Battlewrath asked directly — *"does the
  structure need a hidden escapement — an else, move on?"* — and the answer is **NO**: a timeout or
  an automatic skip is an advance the author never stated, **a false advance by construction**, and
  it would make every stall invisible instead of told. Every escapement is visible and authored:
  **per tab** (arrival · the touch · leaving · the kill · note/say/supertrack on firing) · **per
  stage** (told or dry) · **per route** (the tray's recovery beacons, `Set N`) · **per reader** (the
  remote's correct-when-lost — the human "else, move on", on screen).
      grades  the manager's advance sites, structurally
  TEST: enumerate every path by which the manager advances → each one is reached from a COMPLETION,
  and there are exactly four kinds.
  MUTATION: add a timed advance → the enumeration finds a fifth path, and a run advances past a node
  the player never reached.
  ★ **This row's value is that it forbids a fix somebody will reach for** when a stall is reported.
  The stall is the SYMPTOM of an unauthored escapement; hiding it loses the only signal there is.

## A12.5 · COMPLETE — the ledger is the manager's (§4b 5)

- **A12.5a** A tab completes when its action finishes; a NODE completes when ALL its tabs have; then
  its `Next` fires — Step → the next positive ordinal · **Stage → THE NEXT STAGE PRESENT IN THE
  ROUTE** · Set(N) → N. *(RI-16's all-tabs rule, one level up.)*
  ⚠⚠ **CORRECTED 2026-08-21 (AL-9, from the AI-2 audit).** §4b step 5 said *"Stage → +1"*, and +1 is
  a DEFECT: L3 permits an exposed gap, so stages 1, 2, 5 are legal and `+1` arms stage 3, which
  `Bucket.Stage` resolves to **bucket 0 alone — the run stalls with only recovery armed.** The
  architect's wording now stands in §4b and here.
  ★ **AND THIS ROW'S OWN FAULT IS RECORDED RATHER THAN QUIETLY FIXED:** it first read *"the next
  positive stage"* — the Analyst PARAPHRASED §4b into correctness instead of reporting that §4b was
  wrong, against this brief's own preamble (*"where a row and §4b disagree, §4b is the spec"*). The
  audit caught it. **A silent correction is a disagreement nobody gets to rule on.**
  TEST: a node with two tabs, one completing → `Next` does not fire until the second does.
  MUTATION: fire on the first → the test bites, and a stage advances mid-node.
  ✅ **AMENDED 2026-08-21 (AL-18):** *"a tab completes when its action finishes"* is now the case
  where there IS one. **A row with no action completes the instant its sense fires** — A12.4d, which
  is where that half is graded. ⚠ Recorded here rather than rewritten silently, because this row's
  own history is a paraphrase that hid a disagreement.

- **A12.5b** A STAGE completes when TOLD (Stage / Set) **or when the ordinal RUNS DRY**. A childless
  beacon is the limit case — an item of one. *(§4; `AcceptanceOf`.)*
  TEST: a stage whose last ordinal completes with no `Next` → the stage completes.
  MUTATION: require a `Next` → a route authored without one never advances.

## A12.6 · ADVANCE — after the poll, never inside it (§4b 6)

★★ **L16 (AL-11, Battlewrath): WHERE CARE GOES.** *"The sensor and action patch is the hot one. The
stage steps has travel time between."* ⟶ **The hot path is sensor → action**; a stage or step change
has seconds of walking on either side, so **the swap is a REBUILD BY EVICTION and is never
optimised.** Cost follows cadence: dispatch must follow the transition on the same 0.1 s tick, while
a rebuild between stages is free in effect and simplest in fact. ⚠ **So no row below may grade the
swap for speed** — grading it for CORRECTNESS and for happening after the poll is the whole job.

- **A12.6a** The swap happens AFTER the poll returns. ⚠ **The sensor's result changes the sensor's
  input, so the armed list must not be mutated mid-poll.** *(Model row 26.)*
      grades  Sensor.Arm
  TEST: a node completing mid-poll whose `Next` is Stage → the remaining nodes in that poll are
  evaluated against the OLD armed list; the swap lands after.
  MUTATION: swap inside the loop → the same sample sees two different armed sets.

- **A12.6b** An advance disarms the old stage's listeners, arms the new bucket with bucket 0, writes
  the new entry lure, and says ONE short line.
  TEST: advance with a CLEU listener armed → it is disarmed before the new stage arms.
  MUTATION: leave it armed → a boss on stage 1 still completes a tab on stage 2.

## A12.7 · RECOVER — no special path (§4b 7)

- **A12.7a** Bucket 0 is armed on every pass BY CONSTRUCTION. A stage-0 beacon's `Next = Set(N)`
  steps the run to N wherever the reader is. ★ There is no recovery MODE.
  TEST: walk into a stage-0 beacon at stage 3 whose Next is Set(1) → the run is at 1.
  MUTATION: add a recovery mode flag → this row bites on the flag's existence.

## A12.8 · END (§4b 8)

- **A12.8a** The last stage completes, or the human stops → terminal: disarm everything, **tracker to
  the PARK**, the route stays SELECTED but not armed. *(A11.9's escapement.)*
  TEST: complete the last stage → nothing armed, the tracker reads the park, the selection survives.
  MUTATION: leave the last stage's marker set → A11.9a bites on the spent target.

## A12.9 · RELOAD — one slot, and progress is never in it (§4b 9)

- **A12.9a** ONE saved slot: the selected RID or none, **overwritten, never appended**. ⚠ **Progress
  is NEVER saved** — the cursor is the sensor's. After a reload the route is selected and not armed;
  arming again lands the reader by recovery (A12.7). *(R5: zero garbage by construction.)*
  TEST: select, reload, select another, reload → the store holds ONE slot.
  MUTATION: append → the store grows per session and this row bites on the count.
  MUTATION: save `currentStage` → the test for "not armed after reload" still passes, so add a
  second: **read the store after a reload and assert no stage is in it.**

---

## WHAT IS OUT — so nothing is graded that was never asked

    the SENSOR's throttle and rule          A11.x — the manager never polls
    the geometry                            A11.2a
    the ACTION's handling                   we generate the input contract, never the consumer's
                                            handling of it
    the READER's two panes                  A10.5's reader-side counterpart, owed
    the SYNC channel                        named for later, not built (AL-6)

## REVIEW LOG

**2026-08-21 — Opus 5 (Analyst). OPENED**, at AL-8's instruction, against §4b as accepted. ⚠ Written
before any of it is built, which is deliberate — *acceptance before code*. **A12.2b is the row AL-8
landed**: the manager may assume one anchor per stage because `Bucket.Build` refuses a second, and
the picker (A10.3e ✗) is the author-side half rather than the guarantee. ★ The Analyst's AI-1 read
was that the window stayed open until A10.3e; **the architect closed it at load instead**, which is
better — the guard already exists in the part that has one.
