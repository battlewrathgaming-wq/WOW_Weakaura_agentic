# ROUTE MANAGER — acceptance (A12.x) — the test brief for the one stateful owner

_Analyst (Opus 5), 2026-08-21, written against `driver_architecture.md` §4b **as accepted the same
day** (architect's proposal; Battlewrath: *"Yes. That matches."*), and at `ARCHITECT_LOG.md` AL-8's
instruction. **This brief does not restate §4b — it grades it.** Where a row and §4b disagree, §4b is
the spec and this file has drifted; where a row and a MECHANICS doc disagree, the mechanics doc wins
(`driver_architecture.md` §7)._

✅ **SUPERSEDED 2026-08-21 — THE MANAGER IS BUILT.** `manager.lua` landed at §461 (DR_Content_2.6) with
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

## ★★★ TWO THINGS EVERY ROW BELOW OWES, ADDED 2026-08-21 AT BATTLEWRATH'S ASK

_*"Anything to correct on acceptance with explicit order guidance and is / is not?"* — there was.
Three built items had no criterion at all, order guidance was per-row and scattered, and **`IS NOT`
appeared nowhere in this file.**_

    IS NOT   ⚠⚠ **THE POINT IS THE REJECTED SHAPE, NOT THE DEFECT.** A `MUTATION` names a way the
             code could be WRONG; an `IS NOT` names a design that was CONSIDERED AND REFUSED.
             ★ The log's own preamble says why: *"an outcome recorded only as what we chose leaves
             the rejected shape free to drift back in."* ⟶ Measured this week: three of RI-49's
             four readings were refuted, A12.2h and A13.4 were retired, and `Set`-with-no-arg was
             refused twice. **Without an IS NOT line every one of those is re-proposable.**
    ORDER    what must land BEFORE this row can be GRADED. ⚠ Absent = nothing; say so rather than
             leave it blank, because a blank reads as "not thought about".
             ★★ AND THE WORD *GRADED* IS THE WHOLE LINE (Battlewrath asked, 2026-08-22, whether
             acceptance mixes grading and order): **ORDER-OF-GRADING belongs in a row;
             ORDER-OF-BUILDING does not.**
               BELONGS      *"A12.2g cannot be graded before A13.1"* — a property of the
                            CRITERION. Run it early and every route in the corpus refuses, so
                            the row must say when its test becomes meaningful.
               DOES NOT     *"B1 precedes DR_Content_1.4"* — a fact about the PRODUCT's build sequence.
                            That is **RI-54**'s, and duplicating it here is the second copy
                            that drifts.
             ⟶ His read that the mixing might itself be useful is right for the first kind and
             only the first: a criterion that cannot yet run and does not say so buys a false red.

⚠ **NOT A BIG-BANG, AND HERE IS EXACTLY WHO CARRIES IT TODAY** — because a convention claimed
more widely than it holds is the fault this file's preamble was already corrected for:

    CARRY IT   A12.2i · A12.2j · A12.5c · A12.5d · A12.5e   (and, in the sibling files,
               A13.6 and A10.3k)
    DO NOT     every other row in this file. **They gain it on touch, not in a sweep.**

★ The set is small on purpose: these are the rows whose rejected shapes were refuted THIS WEEK and
are therefore the ones still warm enough to drift back. ★ Claiming the whole file carries a convention it does not would be the exact fault this
file's own preamble was corrected for.

### THE EDGES THIS FILE DEPENDS ON, in one place

    A12.2b  ← nothing            F2/AL-9: the duplicate refusal lands BEFORE the manager
    A12.2g  ← A13.1              the seed first, or the empty-node refusal refuses the corpus
    A12.2j  ← A12.2i             the vocabulary check before the arg check: an unknown ACTION has
                                 no declaration to read a type from
    A12.5c  ← the store field    `nextType`/`nextArg` must exist before the three types are gradeable
    A12.5e  ← A10.3              `role` is LIVE until the replacement pane lands (AL-21)
    A12.5e  → DropRetired        **migrate before you retire** — the sweep runs AFTER this reads
    A12.4b  ← A10.3k             the picker is what makes a non-default `Trigger` authorable

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

- **A12.2b ✅ BUILT (verified 2026-08-22 by `check_acceptance`: `bucket.lua` refuses *"two
  beacons at stage %s"*) — THE DUPLICATE-STAGE REFUSAL.**
  ~~⚠⚠ OWED.~~ THE DUPLICATE-STAGE REFUSAL. The manager MAY assume one beacon per stage, and
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

- **A12.2f ✅ BUILT (verified 2026-08-22: `bucket.lua` refuses *"address … resolves to no
  characteristic"*) — NO SILENT ORPHAN.**
  ~~⚠⚠ OWED.~~ A record whose address resolves to no characteristic is REFUSED at build, named. A record whose address resolves to no characteristic is
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
  ⚠⚠ **A HALF-CORRECTION THAT STOOD FOR A DAY:** the BODY of this row was corrected at §467 and
  its HEAD was left stating the old status. `check_acceptance` caught it — **and then caught this
  note too**, because the first draft explained the fix INSIDE the head and the tool read the
  explanation as the claim. ⟶ **The head states the status; prose about it goes here.** A status
  line that can be diluted by commentary is not derivable, which is the whole point of having one.
  TEST: plant a behaviour row whose `cid` names no child → build REFUSES and the reason names the
  address.
  MUTATION: skip it silently → the built count is short by one and nothing says why.
  ⚠ **BENCH'S TO BUILD** — one more named refusal, same list as D3.

- **A12.2g ✅ BUILT §472 (verified 2026-08-22: `bucket.lua` refuses *"no behaviour"*) — THE
  EMPTY NODE IS REFUSED, BY NAME (bench item B2).**
  ~~⚠ OWED.~~ A node carrying no
  behaviour record is REFUSED at build: it could never complete and would arm, point and stall in
  silence. *(AL-17; §4b.)*
      grades  Bucket.Build
  TEST: a node with zero rows → build REFUSES and the reason names the node.
  MUTATION: build it → the built count is RIGHT and the run never advances; nothing says why. ★ That
  is the whole argument for the refusal — the failure is invisible to every other row here.
  ⚠⚠ **SEQUENCE, MEASURED: this row cannot be graded before A13.1.** Every route authored to date
  carries zero rows (§462's probe), so A12.2g alone refuses the whole corpus. **A13.1 first.**

- **A12.2h ❌ RETIRED 2026-08-21 (AL-21's addendum; §4b corrected in place) — THE REFUSAL WAS
  BUILT ON A DEFAULT THAT NO LONGER EXISTS.** ⟶ **A ZERO node — stage-0 beacon or step-0 child —
  takes `nothing follows`, never `Stage`.** So the reset this row was written to prevent cannot
  happen, and refusing the node would refuse one that behaves correctly.
  ~~A TRAY-0 NODE WITHOUT AN AUTHORED `Next` IS REFUSED AT BUILD. TEST: a stage-0 node whose `Next`
  is the default → build REFUSES, naming the missing `Set(N)`.~~
  ★★ **AND THE ROW'S REPLACEMENT IS A DISTINCTION, NOT A GUARD** (§4b): an unauthored tray-0 beacon
  is an **UPDATER** — fires, re-fires, moves nothing, no arrow at it — and a **RECOVERY** beacon is
  one the author gave `Set N`. **Two node kinds where this row saw one error.**
  ⚠ The lifecycle is worth keeping: the row was written this morning from AL-18, was open for eight
  hours, and retired without ever being built. ★ **The acceptance moved faster than the code, which
  is the order that costs nothing.**

- **A12.2i — THE CLOSED LIST IS CONSULTED *BEFORE* THE RESOLVER, NEVER INSTEAD OF IT** (bench
  item B4, built §470; AL-17's security boundary).
      IS      `known()` tests the word against `SENSE_WORDS` / `ROW_ACTIONS` FIRST; only a word
              already on the published list reaches `Bucket.Resolve`.
      IS NOT  **NOT `if Bucket.Resolve then return Bucket.Resolve(...)` as the first line** — the
              shape that shipped, which let an installed resolver ADMIT a word the addon never
              published. ⚠ And it is NOT *"the resolver always says yes"*: a resolver returning
              nil is a refusal like any other, so the list bounds what may be ASKED, not what
              must be granted.
      grades  Bucket.Build · `known()`
      ORDER   nothing. Independent of B0/B1/B2 — it was sequenced first for that reason.
  TEST: install a resolver that maps every word to a callable, then build a route naming a verb
  NOT on `ROW_ACTIONS` → refused, naming the word.
  MUTATION: restore the early return → the hostile word builds, and the closed list stops being
  the security boundary [[travelling-data-names-never-supplies]] says it is.

- **A12.2j — THE ARG'S TYPE AND CAP ARE READ FROM A DECLARATION, KEYED ON THE ACTION** (bench item
  B3, built §473).
      IS      `Routes.ROW_ARG_RULE[action]` gives `{ type, source, max? }` and the guard READS it.
              `supertrack` is ABSENT from it because it takes nothing.
      IS NOT  ⚠⚠ **NOT keyed on the LABEL.** `ROW_ARG` says `note = "content"` and `say =
              "content"` — **one label, and §4b types them differently** — so a label-keyed table
              cannot hold the declaration it exists to carry, and a label is a PANE concern DR_Content_1.2
              may rename out from under the type. ★ Refuted by measurement, not preference.
              AND NOT a second copy of the type in the guard: *a copy drifts, a read cannot*.
      grades  Bucket.Build
      ORDER   ← A12.2i. An unknown action has no declaration to read a type from, so the
              vocabulary check must run first.
  TEST: `arg = { evil = true }` on a `note` row → refused, naming the field and the expected type;
  a string longer than `ARG_MAX` → refused, naming the cap.
  MUTATION: hard-code `type(arg) == "string"` in the guard instead of reading the rule → the day
  `note` becomes a NoteID (§4b already declares it) the guard passes a wrong type and says nothing.
  ★ `source` carries the trust split the same table already encodes — `boss` is *run*-sourced and
  picked (A3.1), `note`/`say` are *user*-sourced and capped.

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

- **A12.4b** `Trigger` says once or every time. ✅ **RULED 2026-08-21 (Battlewrath): BUILD IT
  — *"make it an exception by selection, not by many states of the same UI."*** The authoring half
  is A10.3k; this is the runtime half.

      ⚠⚠ **CORRECTED 2026-08-22 (DRILL 3 · B2) — TRIGGER IS **TWO** LATCHES, NOT A NODE
      FIELD.** This row and A10.3k both said *a node field, not a row field*, which was §4b's
      wording before AL-23 landed. **AL-23 rules two, each with the authored choice Once | Every
      time:**
          PER TAB          `contract.lua` carries `trigger` on the **BEHAVIOUR** record —
                           *"once | every, the ROW's latch; absent is once"*. Once = spent until
                           the node re-arms; Every = released when the sense drops.
          PER STEP/STAGE   the node's own latch — Once leaves the offered list on completion.
      ★ **His reason is the case, not the symmetry:** *"A boss room isn't one chance to kill it or
      our system breaks. At the same time we don't want to spam LoS every time you run over it."*
      ⟶ **Two different repeat questions, so two latches.**
      DEFAULT     **One time**, both of them. RI-27, his best working model: *run again after
                  complete — default NO, opted in.*
      THE OPT-IN  **Every time** re-runs the ACTION on every qualifying transition, and
                  **never touches the ledger after the first** (A12.4e).
      ✅ CHOSEN   **`Routes.TRIGGERS = { "once", "every" }`**, stored on `x.trigger`, and the
                  setter refuses anything else. ⟶ The row said *"the code term is the bench's"*;
                  the bench took it. ~~⚠ OWED: the stored id.~~ (Caught by the divergence sweep,
                  2026-08-22 — **the acceptance was behind the code, not ahead of it.**)
                  ★ **An adaptor row is owed WITH it, not after** — A13.5's lesson measured on
                  the sense words: the adaptor carries none, A5.1 passes a miss through, so
                  **whatever the code term is, it is what the author reads.**
      grades  the ledger · the node's trigger
  TEST: two nodes, identical but for `Trigger` → the One-time node's action runs once across three
  entries; the Every-time node's runs three times, and BOTH ledgers show one completion.
  MUTATION: let Every time re-complete → a node that already completed can un-complete, and the
  advance is rewritten behind the manager (A12.4e's mutation, reached from the authored side).

  ★★ **WHY THIS WAS WORTH RULING RATHER THAN DERIVING.** RI-27 held two STAGELESS cases that want
  OPPOSITE answers — *"a recovery beacon must not re-set once consumed (no), a 'get back on course'
  marker should speak whenever you are there (yes)"*. ⟶ **Two nodes of the same shape and the same
  position, needing different behaviour.** No derivation from position can separate them, which is
  exactly why `Next` may be derived and this may not.

- **A12.4c ✅ BUILT (drained from the citation queue 2026-08-24 — PROVEN BY MUTATION, not by reading) — LISTENERS DISARM ON `When off`, not only on ADVANCE.** ⚠⚠ **ADDED 2026-08-21 (B11).**
  A12.6b grades disarm at the stage swap; §4b step 4's own parenthesis — *"(disarmed on When off)"* —
  was ungraded, and it is the more frequent case: a reader leaves a node's reach mid-stage and its
  CLEU listener must go with it.
      grades  Sensor.Poll
  TEST: enter a node whose tab arms a listener, leave it → the listener is gone before the next poll.
  MUTATION: disarm only on advance → a boss killed anywhere later in the stage still completes that
  tab, and the test bites on the stale listener.
      ONE mutation and it BITES (`drive.lua`, `smoke_drive`): *THE BOSS TAB DID NOT PARK* — a
      `boss` callable returns FALSE, so the tab finishes when the boss DIES, not when it ran.
      ⚠ One guard; recorded as one.


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
  never touch the ledger — else *"every time"* would be a row that never completes.
  ✅ **NO LONGER WRITTEN AHEAD (2026-08-22):** ~~A12.4b records that `Trigger` is not built and
  no code term is chosen.~~ The vocabulary landed — `once | every` — so this row grades a word
  that exists. *(§4b, AL-18.)*
      grades  the ledger · Routes.SetTrigger · Routes.TriggerOf
      ⚠ **CORRECTED 2026-08-22 — this cited `Routes.TRIGGERS`, which is a TABLE**, and
      `emit_built_state` REFUSED TO EMIT rather than under-count. ★ DRILL 3 handed the bad cite to
      the bench; **it was the Analyst's**, written the day before. ⟶ A `grades` line names a
      FUNCTION the criterion can be run against; a vocabulary is what that function reads.
      ★★ And `TriggerOf` is the row worth grading twice: *"RESOLVED, never read raw — an absent
      field and an authored `once` are the same answer and cannot disagree."* Same shape as
      `SENSE_DEFAULT` (§79, the default stores nothing) — **the default is offerable without
      being stored.**
  TEST: an Every-time row fired three times → the ledger records ONE completion; the action ran
  three times.
  MUTATION: complete on every fire → a node that has already completed can UN-complete, and the
  ledger is rewritten behind the advance.

- **A12.4f — NO HIDDEN ESCAPEMENT. THE NEGATIVE ROW.** ⚠⚠ Battlewrath asked directly — *"does the
  structure need a hidden escapement — an else, move on?"* — and the answer is **NO**: a timeout or
  an automatic skip is an advance the author never stated, **a false advance by construction**, and
  it would make every stall invisible instead of told. Every escapement is visible and authored:
  **per tab** (arrival · the touch · leaving · the kill · note/say on firing) · **per
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
  a DEFECT: DR_UI_3 permits an exposed gap, so stages 1, 2, 5 are legal and `+1` arms stage 3, which
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

- **A12.5c — `Next`'s THREE AUTHORED TYPES, EACH FIRING EXACTLY ITS OWN THING** (AL-21).
  ✅ **THE FIELD HAS LANDED (2026-08-22):** `Routes.NEXT_TYPES = { "step", "stage", "set" }`
  with a setter that refuses anything else, writing `child.nextType`.
  ~~⚠ NEW FIELD: `nextType`/`nextArg` join the store~~ — they have. `contract.lua` declared them
  all along, which is why the gap was invisible until a tool read both records at once.
      Step      → the next positive ordinal in this stage's bucket
      Stage     → **the next stage PRESENT IN THE ROUTE**, never `+1` (A12.5a's correction)
      Set(N)    → N, absolute. ★ This is what makes §4b's recovery escapement AUTHORABLE at all.
      IS NOT  ⚠⚠ **THE THREE REFUTED READINGS, NAMED SO THEY CANNOT RETURN** (RI-49 → AL-21):
              NOT `role` under another name — the manager reads `lone` and `step`, **never
              `role`** · NOT something BUCKET converts from `role` — there is no `nextType` in
              `bucket.lua` and no conversion · NOT satisfied by `complete`/`set` staying as they
              are — those are the OLD PANE'S SPELLING and MIGRATE (A12.5e).
              ★ Each was refuted by a MEASUREMENT, not a preference, which is why naming them
              costs nothing and omitting them would have cost the next reader the same day's work.
      grades  Manager.NodeDone · Bucket.Build (carrying the field onto the entry)
      ORDER   ← the store field. `nextType`/`nextArg` must exist before any of this is gradeable;
              `contract.lua` has DECLARED them all along, which is why the gap was invisible.
  TEST: three nodes, one per type, on a route with stages 1 · 2 · 5 → Step lands on the next
  ordinal; Stage lands on **5** from stage 2; **Set(3) from stage 2 lands on 3**, whether or not
  3 exists as a neighbour.
  ⚠ **TIGHTENED 2026-08-22 (AL-23):** the Set clause read *"lands on 3"* unqualified, which is
  true only from BELOW. `Set(N)` is `max(current, N)`, so from stage 5 it lands on 5 — **the
  from-above case is A12.7a's and is graded there**, not left implied here.
  MUTATION: implement Stage as `+1` → the stage-2 node arms bucket 3, which resolves to **bucket 0
  alone and the run stalls with only recovery armed** — A12.5a's exact recorded defect, reached
  from the authored side this time.

- **A12.5d — AN ABSENT `Next` IS AN OUTCOME, AND WHICH ONE IS DERIVED FROM POSITION** (AL-21's
  addendum, taking §479's landing as the rule).
      ORDINALLED node   absent → **Step** (dry → the next stage present)
      ZERO node         absent → **NOTHING FOLLOWS**. A stage-0 beacon or a step-0 child.
      EXPLICIT          the instruction, either way.
  ★ Nothing is stored for the absent case — the default is a function of the node, like `StageOf`,
  `IsPosition` and `LedTo`. **No fourth word, and no degenerate `Set`** (a `Set` with no arg is a
  half-stated Set the guard already refuses).
      IS NOT  **NOT a fourth word** and **NOT a degenerate `Set`** — a `Set` with no arg is a
              half-stated Set the guard already refuses, and it would hang a MOVEMENT type on a
              node whose whole point is that it moves nothing. ⚠ And an absent `Next` is **NOT
              "the author has not decided"** treated as an error: absence IS an outcome.
              ⚠⚠ NOR is a zero node's default `Stage` — **that reading was AL-18's and is
              RETIRED** (it took A12.2h and A13.4 with it).
      grades  Manager.NodeDone
      ORDER   nothing. It grades a derivation, not a field.
  TEST: a step-0 child with no `Next` completes on arrival → the ordinal does not move and the run
  does not advance; give the same node `Set(2)` → it advances to 2.
  MUTATION: give the zero node the ordinalled default → an unauthored tray-0 beacon sends a reader
  who walks past it back to stage 1, and the run reads as if it restarted rather than failed.
  ⬜ **OWED TO THE UI, not graded here:** the `Next` picker must OFFER *nothing follows* as an
  entry whose selection stores nothing — `SetChildSense`'s shipped shape (§79, *"the default stores
  nothing"*). ★ That is how *"no fourth word"* and *"you can never select back into it"* are both
  satisfied: **offerable without being stored.**

- **A12.5e — `role` MIGRATES INTO `Next` AND THE ORDINAL, ONCE, TOLD** (AL-21). ⚠⚠ `role` is **not
  a separate concern that stays** — it is the OLD PANE's spelling of what the model expresses
  through `Next` and the ordinal, and A10.2a already lists it among the controls A10.3 replaces.
      complete            →  Next = Stage
      set + setStage      →  Next = Set(N)
      start / update      →  POSITIONS: ordinal 1 / no ordinal
  ★ It stays LIVE until the replacement pane lands — `AcceptanceOf` reads it — **and the reason it
  is read is the reason it is temporary.**
      IS NOT  ⚠ **NOT a rename, and NOT a field that stays.** The Analyst's own filed reading
              said *"editor-side, and they stay"* — **corrected by AL-21**: `role` is the OLD
              PANE'S SPELLING of the same fact, live only because `AcceptanceOf` reads it, and
              **the reason it is read is the reason it is temporary.**
              AND NOT a removal today — the Analyst measured `role` IS read one step before
              proposing it follow the retired outward-pointing fields, which is what stopped it.
      grades  the store's migration hook (with `MigrateRows`, B1's neighbour)
      ORDER   ← A10.3 (the replacement pane). → `DropRetired`. Both edges are hard.
  TEST: a route authored under the old pane loads once → every `role` becomes its `Next`/ordinal
  and is TOLD; `role` is gone from the record afterwards.
  MUTATION: leave `role` beside `Next` → **two fields for one fact, which can disagree** — the
  second-copy law, and the same fault `MigrateRows` exists to prevent on the row side.
  ⚠ ORDER, and it is the rule B1 already carries: **migrate before you retire.** `DropRetired`
  sweeping `role` must run AFTER this reads it.

- **A12.5f — A STAGE WHOSE ITEMS ARE ALL STEP 0 NEEDS A COMPLETION PATH, AND THE SHIPPED ONE
  DOES NOT REACH IT.** ⚠ **THIS ROW IS A BUILD ITEM, NOT A DEFECT REPORT** (Battlewrath, 2026-08-21:
  *"what can't be done is the material for development, not caution"*).
      IS      `Manager.StageDone` has exactly TWO call sites, both inside `NodeDone`: `node.lone`,
              and the ordinal running dry — and the second is only reached past `(node.step or 0)
              <= 0`. ⟶ A beacon WITH children that all sit at step 0 reaches neither.
      IS NOT  **NOT a trap, and NOT a claim the shipped pane is broken.** The ordinal IS authorable
              today — `Routes.SetChildOrdinal` is the one setter, `object.lua` wires it at two
              sites, and `object.ordinal` is declared and registered 1:1. ★ An author can see the
              blank box and the duplicate count beside it. **This is a DEFAULT that has not been
              chosen yet, not a state anyone is stuck in.**
              AND NOT the `lone` case — *an item of one* is covered and works (§476 fixed it).
      grades  Manager.NodeDone · Manager.StageDone
      ORDER   nothing blocks it. ⚠ It gets CHEAPER after the ordinal default lands (below), and
              stays correct either way — which is why it is worth doing first.

  ### ⟶ THE WORK, and the Analyst's pick

      (b) ★ RECOMMENDED — **a beacon whose items are ALL step 0 completes when ALL of them do.**
          The `lone` rule generalised: A12.5b already calls a childless beacon *"the limit case —
          an item of one"*. ⟶ **An item SET is the same rule with n > 1**, and it makes the run
          correct no matter how the route was authored.
      (a) COMPANION, authoring-side — **placement MINTS an ordinal.** `Routes.NextOrdinal` exists
          with no production caller; wiring it makes the all-step-0 state rare rather than
          default. ⚠ It does NOT replace (b): an author may still clear every ordinal on purpose.
      (c) NOT SUFFICIENT ALONE — tell it at authoring. The pane already counts ordinal
          duplicates; counting *"no ordinal anywhere on this beacon"* is a small addition, and it
          informs rather than fixes.

  TEST: a beacon with two children, both ordinalless, both completing → **the stage completes**,
  once, after the second.
  MUTATION: complete the stage on the FIRST child → a beacon of satellites advances before its
  set is done, which is A12.5a's all-tabs rule broken one level up.
  ⚠ SECOND MUTATION: revert to the shipped guard → the stage never completes and the run holds
  with no message. ★ That is the state this row exists to remove, and it is what the row grades.

## A12.6 · ADVANCE — after the poll, never inside it (§4b 6)

★★ **DR_Runtime_16 (AL-11, Battlewrath): WHERE CARE GOES.** *"The sensor and action patch is the hot one. The
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
  ⚠⚠ **CORRECTED 2026-08-22 (DRILL 3 · B1) — THIS ROW WOULD HAVE FAILED CORRECT CODE.**
  It read *"Set(1) at stage 3 → the run is at 1"*. **AL-23 rules `Set(N)` as `max(current, N)`** —
  the ratchet's rule applied to recovery — so a correct implementation stays at 3 and this test
  would have called it a defect.
  ★ **And the row's own prose needed the same correction:** *"steps the run to N wherever the
  reader is"* is now *"steps the run FORWARD to N, or leaves it where it is"*. ⟶ **A recovery
  beacon can carry a lost reader ON; it can never send one BACK.** That is a real narrowing of
  what recovery means and it is the ratchet being consistent, not an oversight.
      grades  Manager.SetStage
  TEST: a stage-0 beacon met at stage 3 whose `Next` is Set(5) → the run is at **5**; the same beacon
  with Set(1) at stage 3 → the run **stays at 3**. ★ The second half is the one that distinguishes
  `max` from assignment.
  ⟶ SILENT OTHERWISE: a recovery beacon quietly un-progresses a reader mid-run, and the route reads
  as if it restarted rather than as if it failed.
  ⚠ FORMAT CORRECTED 2026-08-22: this row's test was written as *"TEST, both halves"* — prose, not a
  `TEST:` line — by me, four commits after the convention it breaks. **The newest work is not
  automatically the conforming work.**
  MUTATION: implement Set as assignment → the second case sends a reader who walks past recovery
  back to stage 1 mid-run, and the route reads as if it restarted.
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

---

## A12.10 · THE ACTOR — the one owner of OUTPUT, and the last place free text could have leaked

_NEW 2026-08-22, from AL-30 / AL-31 and RI-50's two owed rows. ★ **These four are ONE SET**: they
are the security acceptance, and they are written together because RI-50's framing (*"the arg is raw
text"*) was **superseded by AL-31 before its rows were ever written** — `say` is no longer free text
at all. ⚠ Grading them separately would have preserved the dead framing in two of the four._

⚠⚠ **AND A BOUNDARY STATED ONCE, FOR ALL FOUR:** [[provide-vs-handle-boundary]] rules that we
generate the INPUT CONTRACT and never a third party's HANDLING. **A12.10c grades OUR consumer**
(Dungeon Routes is ours), not anyone else's — what we publish to a stranger is the contract, and
what a stranger does with it is theirs.

- **A12.10a — THE ACTOR IS OPT-IN, AND THE DEFAULT IS OFF** (AL-31, Battlewrath: *"Actor is opt in
  on the user's config"*).
      IS      a travelling route can make a reader's character SPEAK. That capability is off until
              the READER turns it on, in their own config — never the route's, never a default.
      IS NOT  **NOT opt-out**, and not a per-route permission: a route may not carry its own
              consent. ⚠ And NOT a prompt at dispatch — a decision asked mid-run is a decision
              answered by whoever is in a hurry.
      grades  the actor's config read
      ORDER   nothing.
  TEST: a fresh install runs a route whose row says `say` → nothing is spoken and the run continues.
  MUTATION: default it on → a stranger's route speaks on a reader's character before that reader
  has agreed to anything, which is the whole reason the module is opt-in.

- **A12.10b — `say`'s ARG IS CONSTRUCTED FROM THREE CLOSED SOURCES, NEVER TYPED** (AL-31).
      IS      **CHANNEL** (/p · /s · /raid · /shout) · **TERM** from the coordination list
              (*"LoS pull" · "Focus X" · "Danger: Curse X"*) · **STAND-IN** picked from the run.
              Three identifiers, like every other arg.
      IS NOT  **NOT a string the author types.** ⚠ `say → a string` is STRUCK from `ROW_ARG`
              (AL-31) — the code still carries `say = { type = "string", source = "user" }`, so
              this row is **written ahead of the change it grades** and says so.
      ★★ THE REASON IS THE BOUND, not the mechanism: a constructed line limits what a stranger's
      route can make a reader's character say **to what the coordination vocabulary allows**, with
      the names bounded by the reader's own run.
      grades  Bucket.Build · the term list and stand-in picker (declarations, the bench's)
      ORDER   ← `say` leaving `ROW_ARG` as a user string.
  TEST: a route carrying a typed `say` arg → REFUSED at build, naming the field. A term outside the
  coordination list → REFUSED, naming the term.
  MUTATION: accept a typed string → the one place free text could reach an executable path is open
  again, and every other row in this section is decoration.

- **A12.10c — THE ARG IS A COMPARAND: NEVER A PATTERN, NEVER FORMATTED INTO SOURCE** (RI-50 row 2).
      IS      our consumer COMPARES the arg. WA's precedent is stronger than "raw text" and is the
              shape to copy: user text becomes **LOOKUP TABLES checked by equality**
              (`ParseNameCheck`, a hand-written scanner where `string.find` would have been
              shorter).
      IS NOT  ⚠⚠ **NOT merely "it is a string".** A string is still hostile handed to `string.find`
              as a PATTERN — `%` and `[` are enough. **This is the row that would be missed**, and
              RI-50 said so when it was filed: a type check does not give it and no build-time
              guard can.
      grades  the consumer's arg use sites
      ORDER   nothing. ⚠ It grades HANDLING, so it can only ever grade OURS (see the note above).
  TEST: an arg of `%d+` used against a name → matched literally, zero times, not as a pattern.
  MUTATION: pass the arg to `string.find` without `plain=true` → the test bites on the pattern
  matching something it should not.

- **A12.10d — THE CLOSED VERB, AS A STANDING REGRESSION** (RI-50 row 3).
      IS      a route naming `loadstring`, `__index` or any word not on the published list is
              REFUSED AT BUILD, BY NAME. It passes today (§464) and **nothing proves it stays true**
              — which is what a standing regression is for.
      IS NOT  **NOT a one-off measurement.** ⚠ §464 measured it once; a row that is only ever run
              once grades the day it was written.
      grades  Bucket.Build · `known()`
      ORDER   ← A12.2i (the closed list before the resolver). This row is that guarantee, watched.
  TEST: build a route naming `loadstring` → refused, naming the word. Repeat with `__index`.
  MUTATION: reinstate the resolver-first order → both build, and **every guarantee in this section
  rests on that one line** (A12.2i's own mutation, reached from the hostile side).

