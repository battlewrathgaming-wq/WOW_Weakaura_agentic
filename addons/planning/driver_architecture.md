# DUNGEON RUN / DUNGEON ROUTES — THE ARCHITECTURE. How the addon works in principle, and the inventory

_Design architect (Fable), 2026-08-21, at Battlewrath's ask: "help me design the addon at the macro
level — an inventory list and how the addon works in principle — so that this is expressed in the
governing files; then the Analyst's role is to reconcile implementation against the model." A first
pass, for review in conversation. **This document carries PRINCIPLE and INVENTORY. It cites the
mechanics docs for detail and never restates them** (a restated ruling is a second copy that can
disagree — `DRIVER_BASIS.md`'s own law). Where the record is silent the line is in §6, not in §3._

---

## 0 · THE SEATS — what each seat OWES (duties, not self-labels)

_(AI-2 audit, corrected 2026-08-21): a thread knows its role from the human, never from a file — `operations/PROTOCOL.md` §1,
with the origin case of a thread that mis-read its own file-borne label. This table is what each seat
OWES and may be CITED by a thread that already knows which it is. ✓ `boot.py` carries `analyst` and `architect` lanes since 2026-08-22 (each seat's lane file is its own
LOG under addons/planning) — every seat runs the mandated boot as itself._

| seat | held by | role line | holds | does not |
|---|---|---|---|---|
| **Addon creator** | the addons bench | `Addons.` (its own) | the FILES: code, smokes, checkers, interface files; files questions to the inbox with options + impact + its own read marked | rule; resolve a disagreement between governing docs (it REPORTS) |
| **Analyst** | Opus 5 (daily driver) | `Analyst.` | reconciles IMPLEMENTATION against the model and the governing docs; writes and grades acceptance; tests landings by RUNNING; files marked reads; reconciles records after a drain | build; invent identifiers, positions, heights, names; land a proposal as a ruling |
| **Design architect** | Fable (invoked at leg boundaries, not per turn) | `Architect.` | THIS document and the macro model: the inventory, the principle of operation, the gap list before a leg is built; the grading audit after a leg lands; a second marked read on any item Battlewrath wants compared | daily reconciliation; touching the tree between boundaries |
| **Designer** | Battlewrath | — | the product: every input is the *best working model, dated*; drains the inbox; decides taste, product direction, shipping | programming ("you guys are the programmers") |

Rules of the seats: thread ↔ role is 1:1 (`operations/PROTOCOL.md` §1); on an item both agents read,
each files its read marked and *before* seeing the other's — where they differ the spec is thin;
the record is the handoff between seats, never the chat; `Build!` gates project actions.

**Two channels to the architect (2026-08-21):** `ARCHITECT_INBOX.md` — the Creator's and the
Analyst's questions TO the architect (how to resolve · what is expected · permission where *what is*
conflicts with *what should be*), a funnel kept as pure input; `ARCHITECT_LOG.md` — the outcomes with
reasoning, newest first, each naming the doc that now carries the ruling. `Reconcile_inbox.md` stays
the bench's channel to Battlewrath.

---

## 1 · THE PRODUCT IN ONE BREATH

_Two terms, kept apart (R3, Battlewrath 2026-08-21): a **RUN** is the Run side's human-initiated
collection — a reference capture of a route, or a map of the whole dungeon as positional basis, mobs
and bosses seen, special markers. An **ACTIVE ROUTE** is an authored, imported, live route on the
Routes side — ingested ahead of entering or at the point of engaging; human-selected, shared, armed,
then driven. A run is never a route; a route is never a run._

One author runs a dungeon once, with the addon recording where they went and which bosses died;
they promote points of that run into a ROUTE — places with a reach, an order, a note, and what to
do there — and hand the route to others as text. Each reader's own addon then senses *where the
reader is* and, place by place, says the note, points the arrow, and advances the stage when the
stage's conditions are met — a boss, a pull, a transition, a skip (R1). Nothing is pushed between players; every reader's driver is its own sensor on the same
instructions. **The driver's product is behaviour; the editor's product is comprehension**
(`core.lua:7`).

Two products, one line between them (`driver_use_case_target.md` §9):

    DUNGEON RUN     the PRODUCER — capture · editor · promoter · exporter · test drive
    DUNGEON ROUTES  the CONSUMER — ingest · bucket · rule · sensor · driver · listener · tracker · readout

The sorting rule: the consumer reads it at runtime → Routes; an author touches it, or it produces
what the consumer reads → Run; a fact about the client → `operations/ROUTER.md`. Acceptance is per
product; a green on one is not a green on the other. Today all consumer files ship inside
`COA_DungeonRun`; the split is a shipping decision (Battlewrath's) that A11.6a keeps to a `.toc`
move.

---

## 2 · THE LINE — what crosses, what never does (`driver_data_model.md` is the authority)

**Crosses, as a PROJECTION of the editor's store (never a copy of it):**

    every record opens with the PREFIX     MapID:RID:BID:CID : Stage : Step      (R2: gates, then payload)
      of which THE GATE (the bounce)       MapID:RID : Stage : Step  — four parts, tested before any geometry
      and THE ADDRESS (identity)           BID:CID                   — admitted, never tested  (AI-2 audit, corrected 2026-08-21)
    CHARACTERISTIC record, one per node    the stable details — POS · R · Band · Next(Type,arg) · Trigger (the NODE's latch) ·
                                           LED TO (AL-19) · the FLOOR SET (AL-32) (drill 3, 2026-08-22): the contract and the data model are
                                           BEHIND on the last two — the bench declares them (bucket.lua writes `ledTo` onto a node with no declared home)
    BEHAVIOUR records, N per node          one per action tab — Sense · action · arg · Trigger (the ROW's latch, AL-23; contract.lua:103)  (drill 3, 2026-08-22)
    ★ F1 RESOLVED (Battlewrath, 2026-08-21, AL-10): the BEHAVIOUR record carries the ADDRESS only;
      stage and step ride the CHARACTERISTIC record once per node; the bucket composes the gate per
      row at build — RI-23 (node fields appear once) stands. CONDITION: the sequence is DEMONSTRATED
      (two lookalike routes on one map → RID A's bucket holds no record of RID B; the composed gate
      equals the node's prefix; an orphan address is refused at build). Then THE INSTRUCTION SET IS
      THE MANIFEST — the built list of what can be true right now, for ONE route on ONE map; saved
      variables load wholesale, so isolation is built from one RID, never loaded.
    ★ THE TICK LIST IS NOT EXPORTED — it is BUILT: at load the bucket lays each stage out as an ordered
      list of gate entries pointing at resolved nodes with their tabs bound to callables. A view never
      travels (a view that travels is a copy that can disagree). R2's tension resolves here: the per-ID
      tables ARE the records; the ordered gate list IS the bucket. (Flight-controller review kept as a
      check, not a decision.)
    NAMES side table                        MapID · RID:Name · RID:BID:Name · RID:BID:CID:Name
    NOTES side table                        RID:BID:CID:NoteID : content
    the transport                           serialise → compress → print-encode, behind a VERSION prefix,
                                            through a multi-line box (never chat)

Identifiers and numbers only on a record — `arg` included; every human string is an ID into a side
table the driver never opens. `Stage:Step` are COMPOSED at export (properties, never a stored key).
`Stage 0 / Step 0` on the line means *always eligible* (nil in the store, 0 on the line — one
meaning). Only the RID re-mints on import: an export and its origin become TWO routes, never two
versions; there is no update path by construction.

**Never crosses:** the capture corpus (4 MB of someone else's samples against 2 KB of route) · the
editor's store · the side tables at runtime · free text · the personal note plane · anything
scraped about the character · anyone's PROGRESS (the cursor is the ROUTE MANAGER's — §3b/§4b — never the record's; (AI-2 audit, corrected 2026-08-21)) ·
other players' positions.

---

## 3 · THE INVENTORY — every part, one line; what it owns and what it must never know

⚠ (drill 3, 2026-08-22): THE STATUS COLUMN IS RETIRED — §7's rule (build state only as a pointer to the checker). Every ✓/◐/✗
below is struck through where it was found wrong on 2026-08-22 (the manager, the ledger, the escapement, the test
drive and the debug log had all SHIPPED while the cells said ✗) and is not to be read as state; run
`py addons/tools/emit_built_state.py` — ⚠ which today REFUSES on one bad cite (`driver_manager_acceptance.md:355`
names `Routes.TRIGGERS`, a table the collector cannot see) — the bench/Analyst fix that cite or the collector first.
A cell says what a part OWNS and must never do; the mechanics live at the cited home.

### 3a · DUNGEON RUN — the producer

| part | status | owns | must never | where / ruled |
|---|---|---|---|---|
| **Capture** | ✓ | the run in progress; an OnUpdate handler *only while recording* | infer state from the event that woke it; clean or merge a point; store a set/count of bosses | `capture.lua` · A3.4 |
| **Store** | ✓ | the SavedVariables global — the ONLY module that touches it | keep `0` where `nil` is meant (absence stays loud) | `store.lua` DR-20 · model row 27 |
| **Routes** (the promoted objects) | ✓ | the shape under the store's route keys; the mints (CID, stage); the RID migration | back-reference the run (promotion COPIES); compute a height (inherited, never computed) | `routes.lua` · A2.x · A8.4 |
| **Promoter** (the mint) | ◐ | its own frame; CREATE-then-edit — a beacon exists the moment you press | gate on arrival order; a dialog | `promoter.lua` · §61 manage half unbuilt |
| **Editor / curation** | ✓ | the VIEW: trim, filter, replay | edit the capture | `editor.lua:46` |
| **Map** | ✓ | selection, arming, layers, the picture | hand out MAP xy where WORLD is meant — the real boundary is `Routes.Place` → `Calibrate.ToWorld` (grep it; the line moved (drill 3, 2026-08-22); the world pair left ABSENT when uncalibrated); `map.lua`'s `TILE_COLS/TILE_ROWS/TILE_PX` (the ART grid) beside `ART_W/ART_H` (the COORDINATE space) are two MAP-space sizes, a different trap (AI-2 audit, corrected 2026-08-21) | `map.lua` · `routes.lua` `Routes.Place` |
| **Node editor** (object pane) — measured AI-4 (the numbers live in AL-14, not here (drill 3, 2026-08-22)): most of its controls carry no record field (`role · shape · match · unseen · answers` among them); position is map-side by design | ◐ DIVERGENT | a view onto one beacon/child | — ⚠ writes ZERO rows: it never calls `Routes.SetRow` (three flat setters instead); the bucket reads rows only, so a node authored today arms with NO behaviour. KNOWN and SEQUENCED (Battlewrath: Ace interface → WA-coded grammar → settled homes → the rows wire) (AI-2 audit, corrected 2026-08-21) | `object.lua` · replaced by A10.3, not folded |
| **Adaptor** (`code → user`) | ✓ | one constant table, one lookup, pass-through on a miss | error on a miss; carry more than the question layer | `adaptor.lua` · A5 |
| **Primary frame** (the map + its controls = ONE surface; a bolted-on panel of tabs, one per DOCKED group; dock/undock NOW — AL-13) | ◐ | the frame; the panel; dock state per group (account-wide UI preference, never a route's); one declaration per group in TWO arrangements (docked column · undocked window) | one flat option table; a hidden `Libs/` exemption; two declarations for one group; a one-way undock — RETURN is two paths in one language: the COLLAPSED STRIP (dock all, the bolt-on's own texture grammar) and a PER-TAB return band on each undocked window; a drawer by illusion (Battlewrath, AL-13) | `options.lua` · A10.1 · A10.9 |
| **Route-note plane** | ◐ | the notes that TRAVEL | touch the personal plane | A4.2 · owed: `NoteID → content` re-key |
| **Personal-note plane** (author side) | ✓ the PLANE (`store.lua:489` NoteTable · `routes.lua` NotePlane/AddNote/DeleteNote (line cite dropped (drill 3, 2026-08-22) — grep the names) · drawn as a map layer `promoter.lua:389`) · ✗ only the PER-ROLE dimension and the dedicated pane (out, A10.6) (AI-2 audit, corrected 2026-08-21) | per-place notes that never travel | travel; sit on the authoring path | RI-10 · A10.6 |
| **Pickers** (stage / ordinal doors) | ✗ | a tick beside the picker for "none" | offer `0` in a dropdown | A10.3e |
| **Trigger control** (One time · Every time) | ✗ | — | reuse the word *Seen* | adaptor row; basis |
| **Flattener / exporter** | ✗ | the projection, in ONE pass over a finished tree, editor-side always | be consumer-side; be 1:1 with the store; carry scraped provenance | model rows 13–17d |
| **Test-drive remote** | ~~✗~~ (`drive.lua` shipped: Offered · Cycle · ToggleArm · Wire · BossDown · Readout; binds note/say/boss to PRINTING bodies — AL-30's twin) (drill 3, 2026-08-22) | select · arm · go/stop · readout, by clicks | expose `stage` alone; need a slash line | A10.5 · A6.1 |
| **UI harness / layout / spec / widget** | ✓ | the control registry and the clickable plan runner | count registrations statically as proof | `ui.lua` · A9.1 |
| **Calibrate** | ✓ | map ↔ world fit per map | — | `calibrate.lua` |
| **Core / slash** | ✓ | init order, the command list (`/dr drive` wired) | be the surface (a slash line is never the surface) | `core.lua` · A10.1d |

### 3b · DUNGEON ROUTES — the consumer

| part | status | owns | must never | where / ruled |
|---|---|---|---|---|
| **ROUTE MANAGER** — the one stateful owner of an Active Route (proposed by the architect, accepted by Battlewrath 2026-08-21) | ~~✗~~ (`manager.lua` shipped §461+: Offer · Select · Stop · OnPoll · NodeDone · SetStage · StepOn · StageDone · Rearm · Bind) (drill 3, 2026-08-22) | the offer for this map and the ONE selection · current stage · current step · the completion LEDGER · firing Next · the bucket swap · the three tracker writes (entry lure · supertrack tab · the park) · arming/disarming listeners · the stage line · the terminal state · the one saved slot (selected RID, never progress) | poll; evaluate geometry; interpret anything on the hot path; mutate the armed list mid-poll; hold two active routes; save progress | §4b · data model runtime tier (bench to shape) |
| **Contract** (the record tier, declared once) | ✓ | field order, optionality, `WORLD`, the version — the ONE file both sides cite | declare behaviour; read a store; carry a `text` type | `contract.lua` · A11.1a |
| **Import door / transport decode** | ✗ | decode → PRESENT (map · name · bosses) → "save as a route?" | use the chat box; keep the origin's RID | model rows 15–17c |
| **Bucket** (construction) | ✓ ⚠ | the run-time layout: one bucket PER STAGE, its entries that stage's rows; bucket 0 always read; the `nil→0` / `nil→2.5` conversion, per field, once, here only | fail quietly; let STAGE fail; step-gate inside stage 0; admit a `BID:CID` under stage 0; interpret an authored id on the hot path | `bucket.lua` · model rows 23–27 · ⚠ §6 G16 |
| **Rule** | ✓ | NOTHING — a pure function: sample + node → verdict | hold memory; test geometry before the mapID gate; apply the band downward; have an OPEN band | `rule.lua` · A11.2/A11.3 |
| **Sensor** | ✓ (AI-7, re-measured 2026-08-21) | the armed sets (`{nodes, inSet, wasIn, everIn}`), swapped per poll; `Poll` returns the CHANGED set by address with the transition word (WHEN_ON · SEEN · WHEN_OFF); `snapshot()` carries `rows`; the accumulator; the OnUpdate only while armed. ⚠ BUILD STATE IS NOT KEPT HERE — `py addons/tools/emit_built_state.py` derives it; this cell says what the part OWNS | reach for the client itself (samples arrive through a seam); leave a handler set on disarm; divide the schedule by a measured speed | `sensor.lua` · A11.4 |
| **Driver** (the pipeline) | ◐ | `state = {bucket, stage, step, mapID, rid}`; Start/Stop; Designate (built, uncalled) | swallow a bucket's refusal; mutate the armed list mid-poll; resolve a doc/code disagreement in code | `driver.lua` · model row 26 |
| ~~Designator / raiser~~ → folded INTO the Route Manager (the designator is the manager; the raiser is its ledger firing Next) | — | — | — | RI-38 · §4b |
| **THE ACTOR** — one owner for OUTPUT (Battlewrath's proposal, AI-18 → AL-30/31). **OPT-IN in the user's config**; `say` is CONSTRUCTED (channel · term · picked stand-in), never typed | ✗ (no `actor.lua`; its verbs live in the test drive's printing bindings; the single emit door `say()` in manager.lua EXISTS — its A10.8c comment is owed, AL-27) (drill 3, 2026-08-22) | what every verb DOES on the reader's client — chat (`say`: a CHANNEL chosen from /p /s /raid /shout, AL-31), the note pane, a raid marker (`mark`, by NAME resolved to a unit token through a nameplate index — GuardianPlates' shape; reachable only for what has a plate on screen); the binder's shipped occupant; the emit seam of AL-27; REPORTS when it cannot act (no plate · no permission) to the debug log, never a silent no-op; the security boundary as a module — a route NAMES a verb from the closed list the actor publishes, the actor owns what it does and whether it is permitted | let the route supply what a verb does; take a typed NAME for `mark` (picked from the run, like `boss`); send the party anything in rehearsal (the test drive's twin PRINTS) | §4b 4 · AL-30 · Dungeon Routes ships the real one, Dungeon Run the test-drive twin; the boundary is the published list + arg types |
| **Action binder** | ◐ (drill 3, 2026-08-22) | `Manager.Bind / Bound / ClearBindings` exist and the test drive uses them; the WORD is validated against the closed list at build, an UNBOUND word refuses at ARM, and the callable is looked up at DISPATCH — `Bucket.Resolve` stays nil (it was never the binding step) | interpret anything authored on the hot path | model row 25 · `Bucket.Resolve` |
| **CLEU listener / boss function** | ✗ | `listen(UNIT_DIED, name)` — the name is the arg | have an unfiltered form; be armed while the sense does not hold | A3.3 · A3.5 |
| **Completion ledger** | ~~✗~~ (shipped in `manager.lua`: `done`, `nodeLatched`, `held`, `completer`) (drill 3, 2026-08-22) | all-tabs-complete per node; a wipe leaves tab 1 done, tab 2 re-arming — OWNED BY THE ROUTE MANAGER (2026-08-21; earlier "the sensor's" is superseded — the sensor keeps in-sets, the manager keeps completion) | be "the caller's"; be the sensor's | A2.7 · A11.3 · §4b |
| **Tracker escapement** | ~~✗~~ (shipped thin, AL-25's shape: `core.lua` `NS.Tracker = {Point, Park}` with the `_G` test + pcall; the manager's lure and park call it) (drill 3, 2026-08-22) | the arrow always has a defined target: a tab's, or the PARK (horizontal, same map) | hold a spent target; hold nothing; contest (the next marker overwrites) | A11.9 |
| **Readout** | ✗ (only the IN half exists, by node table — no first-hit, no address (AI-2 audit, corrected 2026-08-21)) | per sample the IN set by address; per target its first hit | report `stage` as a result; report by index; claim `skip` at V1 | A11.5 |
| **Personal-note slot** (reader side) | ✗ | a designated slot beside the route note | travel; win over the route | RI-10 |

### 3c · Neither product

| part | owns | where |
|---|---|---|
| **The debug log** (in-game, its own module — AL-25) | captures background behaviour during a NAMED test run: the manager's decisions, the sensor as BUCKETS (transitions · throttle state), never a line per second; what DIFFERED is the evidence; off the reader's screen. The acceptance record for every client-only seam (tracker adapter · note surface · chat line). Precedent: COA_DevDump's chain test | `COA_DungeonRun/` (own module, not a test suite) |
| **The desk** (`walk.py`) | the reference the spec was tested against before the driver existed; W1–W5 goldens, one exit code | `addons/tools/walk.py` · W7 rescoped: the driver is graded on OUTCOMES, the desk on byte-equality |
| **COA_Landmarks** (the proving ground) | the supertracker slot discipline and the prior throttler — prior art, not a dependency; its constants did NOT transfer cleanly | `COA_Landmarks/beacon.lua` · `COA_DungeonRun/sensor.lua:36-42` |

---

## 4 · THE PRINCIPLE OF OPERATION — one lifecycle, end to end

    AUTHOR SIDE                                              CONSUMER SIDE
    1 run        capture records edges and legs              9  import   decode · present · "save?" · RID re-mints
    2 look       map + editor show and trim the VIEW         10 bucket   read the store WHOLE, keep this map, pick the RID,
    3 promote    a run node becomes a beacon (COPY)                      one bucket per stage + bucket 0; resolve every id;
    4 author     reach · ordinal · note · tabs · Next                    refuse LOUDLY with a named reason
    5 tabs       N behaviour rows: <sense>:<action>:<arg>    11 arm      hand the current stage's bucket, WITH bucket 0, to the sensor
    6 Next       what I do when my tabs are complete         12 pass     poll at 1 Hz base, 0.1 s on approach; walk the bucket, never records
    7 export     project the tree: 2 record kinds + 2 tables 13 fire     ONE geometry evaluation per node per sample, shared by its rows
                 compose Stage:Step; version; one pass       14 complete all tabs good → the node's NEXT
    8 tell       the tank says "I have a route"; paste       15 advance  SWAP buckets, after a poll returns, never inside one
                                                             16 tell     the arrow (or the park) and one short line
                                                             17 readout  the IN set by address; first hits
    ↺ test drive: the author runs their own route from a visible remote (A10.5 / A6.1) — the loop closes on the author side

**Authoring is a TRAY (R7, 2026-08-21):** stage slots 1..N per route hold one beacon each (0 = the
open tray); step slots per stage hold one child each; the picker shows what is current plus +1 (next
whole for a beacon, next decimal for a child) or swaps with a chosen occupant — no shift, no renumber,
no duplicates by construction — ⚠ BY DESIGN; ENFORCED BY NEITHER END TODAY: the pickers are ✗ (A10.3e) and the bucket's duplicate-stage refusal is OWED (D3) (AI-2 audit, corrected 2026-08-21) (model §1 SLOTS · A2.10). **A stage is a beacon; a beacon with children
becomes a stage with steps** — the stage is one intent (into the room · the jump · the boss), the
steps are how it guides you through it (R8).

The **objects** (`driver_programmatic_model.md` §1): a BEACON (a stage's anchor; childless = a node
of one) and its CHILDREN; a child with an ordinal is a STEP ("a minor stage, a small gear"), a child
without one is an UPDATE type — ⚠ the two zeros differ (AI-2 audit, corrected 2026-08-21): STAGE 0 = always eligible, on every pass; STEP 0 = the pass-through WITHIN its stage, live only while that stage is current (`bucket.lua:326`). Three layers per object: **identity** intrinsic (the
minted `RID:BID:CID`) · **character** mutable (ordinal · alias · appearance · place · Next ·
Trigger) · **behaviour** the tabs together.

The **sense** is the location and the behaviour whilst in its reach — `When on` · `Seen` ·
`When off` — never a player state, never the boss. A **tab** states an outcome, `<sense>:<action>:<arg>`;
the driver holds the function; every tab fires on its sense, none waits for another. **Next** is
the node's: Step (default) · Stage · Set(N), fired when all tabs are good — which is why a stage
change can never be a tab (it would fire on arrival, mid-fight).

The **prefix bounce** is an index built at load, never a test at runtime (⚠ it is NOT `Rule.Gate` — the rule's mapID gate is a per-node, per-sample runtime test; two gates, different operands, the model's own warning against merging them — (AI-2 audit, corrected 2026-08-21)): stage and step admit on `0` or an
exact match and bounce otherwise, evaluated before any geometry; bucket 0 (no stage) is read on
every pass, which is how recovery costs nothing. The **stage** completes when TOLD (a Next of type Stage or Set — never Step, (AI-2 audit, corrected 2026-08-21)) or when
the ordinal RUNS DRY; a childless beacon is the limit case.

### 4b · HOW AN ACTIVE ROUTE IS ORCHESTRATED — the Route Manager's order of effects (accepted 2026-08-21)

    **THE CONSUMER SEAM (AI-46 → AL-72, 2026-08-28): `Sensor.OnChange` has ONE installer — the MANAGER.**
    A door or pane that wants transitions OBSERVES THE MANAGER (it re-emits what it receives, the callback
    bus already ruled USE); nothing else writes the sensor's consumer field. Two installers, last-wins, is
    two owners for one widget at the callback level, and it measurably blinded a mutation row (§735/§736).
    **THE MANAGER IS CLOCKLESS — and its TEMPO is the sensor's, REPORTED (his intent, the seam that
    satisfies it):** Battlewrath 2026-08-28: *"throttling on the manager too. That scales with the sensor
    … arrival is getting close, the manager wakes up and stays highly active during being in R."* Ruled
    shape: `NextIn` already computes how-near ONCE; the sensor's report CARRIES its current interval, and
    every in-R activity the manager schedules hangs off the transitions and that reported cadence — never
    off a second timer (A12.1b stands; the smoke that scans for a ticker keeps biting). No periodic in-R
    work exists on the books today; the first that arrives hangs off the reported cadence, never a clock
    of its own.
    ⟶ **THE FLOOR HOLDS AT 0.1 (Battlewrath, 2026-08-28): "We can hold it at 0.1, to get the system
    moving. Then later consider timing once on a location."** The in-R question is BANKED, not open: the
    arrival argument for the floor is spent once inside R (what remains is departure, which tolerates a
    slower rate), so a gentler in-R floor is the named correctness-safe lever — gated on ONE measurement
    (`Driver.Cost`, in-client, during a real pull, sensor at floor). No number, no machinery (DR_Runtime_16).
    ⟶ **THE TWO RAILS — MANAGER ONLY (Battlewrath, 2026-08-28, AI-46's second ruling → AL-74): "Land the 2
    tracks effecting the manager only. If we ever build a slow down for the sensor, it will be sensor
    isolated."** The SENSOR is untouched — today's algorithm, always at full rate; because of that, the
    threshold the manager reads is always FRESH, which dissolves the recursion a sensor-side rail would
    have had (a clamped sensor delaying the very reading that un-clamps it). The rails govern the
    MANAGER'S OWN SCHEDULING: **rail one (hot)** — entered on a THRESHOLD from the sensor, always wins on
    threshold pass; the manager's in-R work (arming CLEU · dispatches · completion) rides the sensor's
    transitions as before, and while parked on a kill the CLEU listener carries the hot path (a kill is an
    outcome REPORT — event, not poll). **Rail two (slow)** — the manager's first use of `C_Timer.After`,
    left RELUCTANTLY (hysteresis down, instant up). ⚠ `C_Timer` is PROVEN on this fork — ROUTER: a genuine
    Ascension global, in use since GuardianPlates, frame-driven on the same clock as an OnUpdate
    accumulator, error ~half a frame constant; it reschedules from now so cadence drifts ~+1% compounding
    — fine for a slow rail, never for absolute time. A12.1b is UNTOUCHED: the manager still never polls
    geometry — rail two schedules the manager's own bookkeeping, not evaluation. Any future sensor
    slow-down is SENSOR-ISOLATED, designed inside the sensor's own arithmetic, never coupled to these
    rails.

     0  OFFER     map known → routes for THIS MapID offered → the human picks ONE (one active route at a time)
     1  BUILD     the manager reads the saved route WHOLE once → Bucket.Build → one bucket per stage + bucket 0,
                  every id resolved, every action WORD validated against the closed list (binding is checked at ARM —
                  an unbound word refuses — and the callable is looked up at DISPATCH, (drill 3, 2026-08-22)); refuse LOUDLY, or this is the Active Route
     2  ARM       currentStage = lowest positive stage; currentStep = its lowest positive ordinal;
                  Sensor.Arm(that bucket + bucket 0); the manager writes the stage's ENTRY LURE to the tracker
     3  PASS      the sensor polls (its throttle, its rule) and returns — AFTER the poll — the nodes that changed,
                  by address, with the transition word: When on · Seen · When off
     4  DISPATCH  for each returned node the manager runs the tabs whose sense-word matches: note → show ·
                  [AL-30: every verb is performed by THE ACTOR — the manager names an ACT and never knows the surface] ~~supertrack → write the arrow~~ [AL-19: not a verb — the LED TO tick, read by the manager at entry] · say → a CONSTRUCTED line on the author's chosen CHANNEL (/p /s /raid /shout · a term · a picked stand-in — AL-31 supersedes AL-30's "/say"; the manager itself never emits to chat, §4c 6) · mark → a raid marker on a name picked from the run (AL-30) · boss → arm the CLEU listener for that name
                  (disarmed on When off). Each tab is self-completing; Trigger says once or every time
     5  COMPLETE  the LEDGER (the manager's): a tab completes when its action finishes; a node completes when ALL
                  its tabs have → its NEXT fires: Step → currentStep = next positive ordinal · Stage → the NEXT STAGE PRESENT in the route (⚠ not +1: an exposed gap — stages 1,2,5 — is legal under DR_UI_3, and +1 would arm a stage that resolves to bucket 0 alone and STALL the run; (AI-2 audit, corrected 2026-08-21), architect's correction, Battlewrath may overturn) ·
                  Set(N) → max(current, N), never regressing (AL-23; manager.lua clamps and tells). A stage completes when TOLD (Stage / Set) or when the ordinal RUNS DRY
     6  ADVANCE   after the poll returns: disarm the old stage's listeners · Sensor.Arm(new bucket + bucket 0) ·
                  write the new stage's entry lure · one short line to the reader
     7  RECOVER   bucket 0 is armed on every pass by construction; a stage-0 beacon's Next = Set(N) → step 6 from
                  wherever the reader is. No special path
     8  END       the last stage completes, or the human stops → terminal: disarm everything, tracker to the PARK,
                  the route stays SELECTED but not armed
     9  RELOAD    ONE saved slot — the selected RID or none — overwritten, never appended (nothing sprawls).
                  Progress is never saved (the cursor is the MANAGER's — §3b; corrected (drill 3, 2026-08-22)); after a reload the route is selected, not
                  armed; arming again lands the reader by recovery (7) WHERE the route carries a stage-0 beacon, else at the first stage present (AI-2 audit, corrected 2026-08-21). Zero garbage by construction (R5's concern)

    The INSTRUCTION SET is the manager's TICK LIST (Battlewrath): built at 1 from the records, never exported.

    TRIGGER — RULED (Battlewrath, 2026-08-22, AL-22): a NODE field, the author's choice, **Once | Every time**,
    and it means what the MANAGER does with the offered list: ONCE → the node is sent to the sensor once,
    completes, and LEAVES the offered list; EVERY TIME → the manager MAINTAINS it in the list after
    completion, so its actions re-state on every re-qualification. Completion itself is ONCE per arming
    (the ledger, never saved; a re-arm is a fresh ledger). His example is the spec: *stage 0 · When on ·
    say "LoS!" · every time · Next: none.* The sensor stays blind — "spent" is the manager's meaning.
    Ordinalled nodes need no rule: completing one swaps the bucket and it leaves by construction.
    ⚠ Architect's rule beside it, standing until he overturns: a completed node's NEXT fires once per
    arming whatever its Trigger (the consequence is gated by the ledger; re-statement is the action's).
    ★ THE LATCH (Battlewrath, 2026-08-22, AL-23): *"It's a latch. It has to complete before it is released
    and can be re-armed. Each action needs its own latch — a boss room isn't one chance to kill it, and we
    don't want to spam LoS every time you run over it."* ⚠ CORRECTED the same turn — release on the sense
    alone would repeat LoS on every run-past while the node is still in the current list (wipe three times,
    hear it three times). ⚠ AND CORRECTED AGAIN by him ("that flattened my meaning — CHOICE, per tab, on its
    latch type"): TWO LATCHES, EACH WITH THE SAME AUTHORED CHOICE, Once | Every time —
    **PER TAB (the action's Trigger):** Once → fires once, then stays latched for the life of its node's
    arming (spent until the node is re-armed); Every time → released when the sense drops, re-fires on
    the next entry. The author picks per tab: LoS on a wipe-prone boss → Once; a wrong-way note → Every time.
    **PER STEP/STAGE (the node's Trigger, one level up):** Once → the node leaves the offered list on
    completion; Every time → the manager maintains it and its tabs re-arm per their own latch.
    A row latches when it COMPLETES (fires). The boss row gets its second chance because it NEVER
    LATCHES on a wipe — latching is on completion (the kill), not on arrival; the wipe drops the sense, the
    listener disarms, re-entry re-arms (A3.5). NEXT is a latch one level up: fires once per arming, released only by a fresh
    arming. **`Set(N)` NEVER REGRESSES — max(current, N)**, the ratchet's own rule applied to recovery
    (his "yes"). Node completion = every row latched at least once; the ledger records first latches and
    is never cleared within an arming.

    THE POSED TAB — what BUCKET emits per behaviour record, DEFINED (AL-17, 2026-08-21; at Battlewrath's
    direction "better is getting it defined upstream so we're not designing by flight"):

        posed tab = { sense · action · arg · trigger }   on a node entry that carries the address and the composed gate
                                                          (the code's shape, (drill 3, 2026-08-22): bucket.lua emits the row; `fn` is NOT on it —
                                                          the word is validated at build, bound-ness checked at arm, the callable looked up at dispatch)
          address   BID:CID — identity, admitted never tested
          gate      (stage, step) COMPOSED at build from the node's characteristic record (AL-10)
          sense     one of the three sense-words — a closed set; anything else REFUSED at build by name
          action    the WORD, validated at build against the closed list the addon publishes (ROW_ACTIONS); its
                    CALLABLE is the consuming addon's, registered through Manager.Bind — an unbound word refuses at
                    ARM, the callable is looked up at DISPATCH ((drill 3, 2026-08-22); "resolved at build" was the architect's drift). ★ SECURITY (Battlewrath): a route may NAME a verb from that closed
                    list; it may never supply, select or influence what the verb does. The resolver
                    binds only words already on the list — it is consulted AFTER the closed-vocabulary
                    check, never instead of it (the bypass the bench found is closed by definition)
          arg       a VALUE, not a reference — typed per action by the declaration the action carries
                    (ROW_ARG): boss → a NAME picked from the run · note → a NoteID · say → CONSTRUCTED (a channel from
                    /p /s /raid /shout · a TERM from the closed coordination list "LoS pull" · "Focus X" ·
                    "Danger: Curse X" · the stand-in X PICKED from the run) · mark → a name picked from the run.
                    ★ NO FREE TEXT reaches any executable path (Battlewrath, AL-31); the only free text is the
                    user's own NOTES, data that is only ever displayed.
                    BUCKET refuses an arg that is not the declared type, naming it; the guard READS the
                    declaration, it is never a second copy of it
        NOT on the tab: Next (the NODE's) · completion (the manager's ledger, never the record's) · anything
        resolved from a side table (display-time only). TRIGGER IS ON BOTH (drill 3, 2026-08-22): the row's latch on the tab
        (contract.lua:103) and the node's latch on the characteristic record (AL-23).

      · the flat author fields (`child.sense / action / boss`) are the OLDER shape and are MIGRATED ONCE
        into rows by the store's migration hook, told — never converted at build. `child.rows` IS the
        instruction set; the pane moves onto it at L1.4. So L1.2/L1.4 is a MIGRATION, not a build.
      · THE SEED (AL-18, 2026-08-21): a node is PLACED before its behaviour is decided, so placing it
        materialises ONE row — `When on` with NO action — which means REACHED: the player arriving at
        the place IS the behaviour, and an action is what ELSE happens there. A stage is "get you into the
        room" (R8); arrival is what it waits for. So there is NO fourth sense-word — the seed's edge is a
        real one (arrival), and "nothing to wait for" describes no node we have. A row's ACTION is
        OPTIONAL; the arg guard runs only when an action is present. A row the author ADDS starts with its
        sense UNSET — the facing prompt "Select a sense type" (Battlewrath) — and is INCOMPLETE, told,
        until picked; the seed row is never unset. The closed set of three sense-words stands.
        ★ THE FRAME (Battlewrath, same day): "the waiting is the MANAGER with a row that has no ESCAPEMENT
        when no instruction is set." So the rule is the manager's: every row it arms carries its own
        escapement — the seed's is ARRIVAL; a row with no instruction has none and is never armed
        (incomplete, told at authoring; refused at build). A stall is a row the manager is holding with
        no way out, and the record forbids arming one.
        ⟶ TWO SENTENCES THE FRAME FORCED (checked against it, 2026-08-21): (1) **a row with no action
        completes the instant its sense fires** — the ledger's "a tab completes when its action finishes"
        has no action to finish here, and without this line the seed has no escapement in the ledger's
        terms; (2) **a TRAY-0 node's seed is INCOMPLETE until its Next is authored** — the default Next
        (Stage → the next stage present) from stage 0 is stage 1, which would reset a reader who walks
        past an unauthored recovery beacon ~~— so it is told and refused until authored~~ **CORRECTED
        (RI-49's no-outcome landing, 2026-08-21): `Next` ABSENT IS NO OUTCOME, and the default an absence
        takes is DERIVED from the node's position, never stored — an ORDINALLED child's absent Next =
        Step (dry → next stage); a ZERO node's (stage 0 beacon · step 0 child) absent Next = NOTHING
        FOLLOWS; an explicit Stage / Set is the instruction either way. So a tray-0 beacon with nothing
        authored is an UPDATER (fires, re-fires on re-entry, moves nothing, no arrow at it); a RECOVERY
        beacon is one the author gave Set N. No fourth word; no degenerate Set (a Set with no arg is a
        half-stated Set the guard refuses). The manager emits the derived decision in its own record,
        so the absence is auditable at the right layer. Battlewrath's example: step 0 · When on · note
        "Wrong way, turn back" — runs exactly so against the built code (§479).**
        And the one shape the derivation cannot express is not a hole (AL-24): an ORDINALLED node cannot
        complete without advancing, because completing a position in a sequence IS the hand-off; a node
        that should complete without moving the sequence is not in the sequence — give it no ordinal.
        ★ `supertrack` IS NOT A BEHAVIOUR (AL-19, Battlewrath 2026-08-21): "the super tracker is what gets the
        player TO the sense site — if it is an option it lives in the character, not behaviour." It leaves
        the closed action list (the list SHRINKS — the safe direction for the security boundary) and becomes
        the node's **LED TO** tick: ON by default; ticking it off is the author's choice; TRAY-0 nodes are
        UNTICKED and never surface the choice (recovery never lures, AL-6). The manager reads the tick when it
        writes the entry lure (§4b 2). The "lure them back on When off" argument dissolves: returning a
        reader to a place is the remote's RE-PIN, under the user's control — the route never re-lures.
        Migration: a stored `supertrack` row becomes the tick, not a row; the node takes the arrival seed.
        The closed list is boss · note · say · mark (AL-30) · open — PRESCRIPTION (drill 3, 2026-08-22): `ROW_ACTIONS` carries
        boss · note · say today and the old pane still OFFERS `Routes.ACTIONS = { supertrack }` (RI-58 — DR_Content_20's first
        instance). A tick per NODE; no route-level default
        (nothing asked for one, and the tray-0 rule is the only inheritance there is).
        ⟶ NO HIDDEN ESCAPEMENT (Battlewrath asked "an else, move on?", 2026-08-21): a timeout or an
        automatic skip is an advance the author did not state — a FALSE ADVANCE by construction, and it
        would make every stall invisible instead of told. Every escapement is visible and authored: per
        tab (arrival · the touch · leaving · the kill · note/say/mark complete on firing) · per
        stage (told or dry) · per route (the tray's recovery beacons, `Set N`) · per reader (the remote's
        correct-when-lost — the human "else, move on", on screen). And one sentence this exposed: **a row
        with Trigger = Every time counts complete on its FIRST fire; later fires re-run the action and
        never touch the ledger** — else "every time" would be a row that never completes.
      · a node with NO rows is REFUSED at build, by name ("no behaviour — nothing to run"): it could never
        complete and would arm, point, and stall in silence. Defaults (the childless beacon's lure) are
        MATERIALISED at authoring time as real rows — "absolute values, resolved at authoring time; the
        driver is handed them" — so a runnable node always carries at least one.

    PRIOR ART, MEASURED (audit/prior_art_isolation_2026-08-21.md — WeakAuras 5.21.2 and AceDB-3.0 on the
    installed client): the shape above is the field's. A shared WHOLESALE store isolated by a COMPUTED
    subset is normal (WeakAurasSaved holds every character's auras; a character is isolated by the load
    predicate, not a split file) · eligibility is an INDEX rebuilt on a state change by EVICTION, never
    diffed, never tested per frame · the active selection is a POINTER to a whole table, destroyed on
    switch, and consumers REBUILD (five of six) · the selection persists as ONE KEY · identity by unique
    key, collisions REGENERATE · zero footprint when unarmed. ⚠ The one counter-example: WA's trigger
    frame never UNREGISTERS — disarm un-indexes but leaves the listener; DISARM here must unregister.

THE FLOOR SET (AI-13 → AL-32, on Battlewrath's refinement, 2026-08-22): a positioned node listens on a SET of
floors, `{preceding, current, next}` — weighted to preceding and current, the pair a reader arrives through —
DERIVED at build from the sequence (the bucket knows the order) and riding the characteristic record, never
stored by the author; the runtime test is set membership on two or three integers, and it is PERMISSIVE (a
sample with no floor falls through; `Rule.Gate` refuses only a missing mapID). A doorway flap (A → B → A,
adjacent floors) is inside the set by construction, so it stops being a failure mode. Zero nodes (step 0 ·
stage 0) have no predecessor and do not floor-gate — the same set that is LED TO is the set that is
floor-gated, which is structure, not luck. Honest cost: no overlapping-area false fire has ever been
observed; this buys correctness not yet needed, at one carried field and a membership test.

The **runtime** is a pure rule plus a stateful sensor, orchestrated by the manager.

### 4c′ · THE SURFACE BASIS, AND THE NO-RUN CONDITION (Battlewrath, 2026-08-22, AL-36)

A RUN is the only surface the game gives: no geometry is exposed, waypoints are samples, what is true on XY is
not true on Z in a layered dungeon, and *kill X* is bound in all three axes. Meaning is assigned FROM run
data, so the load order is run → route (the promoter needs a run) → beacon (needs a route and a run to select
from) → behaviour (needs a beacon). **A route is bound to a MapID, never to a run** — every run on the map is
content for it. **The no-run condition** (cleared data · a wiped store, which takes runs and routes together ·
an IMPORT, the expected case): **position is locked, behaviour is editable**; pickers draw on the route's own
names; a new name is told. **The map** gets its own known-map picker; run and route always win over it.
**Boundary:** this is the CUSTOM MAP construct in Dungeon Run. Dungeon Routes may use the NATIVE map to
conform to player behaviour — lite terms, full construction avoided for addon-conflict safety — with its
content already reduced to actionables.

### 4d · THE AUTHORING SURFACE — derived from the record and the authoring need, not from today's pane (AL-14)

**FROM DR_UI_21, ITS HOME (moved by AI-35 → AL-61; §5's entry points here):**
⟶ **THE AUTHORING ORDER, FORCED** (Battlewrath, 2026-08-24, AL-48): the ACTION carries the latch offer, so
the offer can only show its natural state BELOW the word that fixes it — action first, latch with it, sense
below. The wire order (`sense:action:arg`) is untouched; this orders the SURFACE.
⟶ **THE BOUNDARY** (AI-33 → AL-58): DR_UI_21 governs a CONTROL'S MEANING, never a pane's SUBJECT — a pane that
rebuilds because the user LOADED ANOTHER THING is the honest response (a route's fields shown for a run
would be the defect); the fault is a control whose meaning shifts because of what sits BESIDE it.
Data-driven rebuilds (Record/Export by loaded type · the roster · dock/undock) are pane-build law-2
rebuilds, not violations.

Battlewrath's frame: *what we have today · what we store as functions · what we need to surface to the
author — "a pass to answer the last two, to get to the first."* The record (`contract.lua`) and the
model give the surface; today's 37 controls do not.

    PER NODE (beacon or child), in the three layers the model names — one universal pane, fold in / out:
      IDENTITY      the address (shown, never edited) · the NAME (a side-table value, never on a record)
      CHARACTER     STAGE picker (beacon; +1 or swap) · STEP picker (child; +1 decimal or swap) · a tick
                    for "none" (tray 0) · PLACE — on the MAP, never here · REACH · BAND (up only) ·
                    NEXT (Next step · Next stage · Set stage N — the offer follows what exists) ·
                    [NEXT's store field EXISTS — `Routes.SetNext` landed §480, 2026-08-22; this line read
                    "declared, not yet written" until 2026-08-27 (AI-41 → AL-66), and the stale bound had
                    propagated into `panes_decl` as a reason NOT to build. `role`/`setStage` is the replaced
                    spelling, migrated at A10.3 — AL-21] ·
                    TRIGGER (One time · Every time — the code term IS chosen, `once | every`, `Routes.TRIGGERS`;
                    the CONTROL is owed (drill 3, 2026-08-22)). ★ CLASSIFIED A CHARACTERISTIC, node-wide
                    (Battlewrath 2026-08-28, AL-78): "how many times a beacon/child can be repeated
                    through completion is a node wide assignment"; its OFFERED DEFAULT is **Once**, keyed
                    to Seen — the player has gotten there, the node completes, the tracker parks. Authored
                    per AL-35 as ever; only the default is stated here · **LED TO**
                    (a tick, on by default; hidden and off on tray 0 — AL-19) · alias / appearance (the roster's)
      BEHAVIOUR     ⟶ **THE BASE (AI-48 → AL-76, 2026-08-28, from his two-senses comment): the node's own
                    arrival is NAMED, UNNUMBERED, UNAUTHORED — the seed row (When on, no action), rendered
                    as the strip's [Base behaviour]. It is not a member of the numbered set; it is the
                    set's precondition — tabs number 1..N after it, and both zeros keep their meanings
                    (stage 0 unplaced · step 0 passive). What the base DOES: on reach, the tracker goes to
                    the PARK (A11.9's existing semantics — the reached node is spent, DR_Content_12; the
                    next marker overwrites on advance, arming its supertrack). No new mechanism: `Tracker
                    → park` gains a second caller (arrival) beside Stop. ⚠ REFINED same day (AL-77, his
                    construction statement): the BASE is UNIVERSAL at promotion — every node minted into a
                    route carries "A player is stood on me"; the TRACKER CARRIAGE is the ORDINAL'S from
                    construction (hand-off when a stage/step is met by the last ordinal); and **0 is outside
                    the ramp STRUCTURALLY — no picker targets 0, Next offers 1 or match-following — so the
                    ordinal-0 gate AL-76 called owed is NOT owed: nothing can point the tracker at a 0.**
                    The shipped `stage > 0` gate stands as belt-and-braces. ⟶ AND ZEROS SHARE THE
                    ONE PARK SYSTEM (AL-78): a 0 was never supertracked, but its base MAY park the tracker
                    on arrival — one mechanism, never two. The EXPECTED authoring shape — a 0's Next
                    pointing at the lowest unseen step/stage, so completion re-targets instead of resting —
                    is AUTHORING CONSTRUCTION through the picker, the author's choice, never a system rule. ⚠
                    VOCABULARY HAZARD, named: the ADDRESS-meaning "park" (`manager.lua:31`, a park vs a
                    lure) is a different concept sharing the word — rename is the bench's option.**
                    ACTION TABS, added by choice — "Action 1 · add action · Action 2" — each one row:
                    SENSE-WORD (When on · Seen · When off) · ACTION (boss · note · say · open list —
                    `supertrack` left the CLOSED list, AL-19; `mark` joined it, AL-30 — ROW_ACTIONS today is boss · note ·
                    say, and the old pane's offered list is RI-58's) · ARG (an ID: the boss name picked from the run · the
                    NoteID · say's constructed triple · mark's picked name)
                    ★ every field an author can set here is a record field or a side-table value;
                    a control with no record field does not belong on the surface (AI-4's 14)

    A handful of fields to author + one owed control + position on the map. That is the whole surface.

    THE SAME SURFACE SORTED PER SUBJECT (AI-40 → AL-65, 2026-08-26 — A10.3's control list, ASSEMBLED from
    the rulings above, nothing chosen new; the subject IS the selection, AL-60):
      BEACON      identity (address shown · NAME side-table) · STAGE picker (+1/swap) · "no order" tick ·
                  REACH · BAND (up only) · NEXT (offer: Next stage default · Set N — follows what exists) ·
                  node TRIGGER (owed control, `once|every`) · LED TO tick (default on; hidden+off tray 0;
                  the characteristic was store-real and declared nowhere until §715 — AI-41's case 2,
                  the inverse of the NEXT case) ·
                  alias/appearance (roster's) · ACTION TABS as ruled (seed = When on, no action; add by
                  choice; per tab: SENSE-WORD · ACTION boss|note|say|mark · its ARG · TRIGGER with the
                  per-action offered default). Surface order per DR_UI_21: action first, latch with it,
                  sense below.
      CHILD       the same three layers, differing only where the model differs: STEP picker (+1 decimal /
                  swap) in place of stage · NEXT offer led by Next step while an ordinal exists, else
                  Stage (default) · Set N · the Seen sense is typical, not special.
      NOTE        its TEXT — the one free text on the surface, ≤200 (A4.1), stored by NoteID in the NOTES
                  side table, rendered by the measured cell (AL-45); nothing else is RULED for this
                  subject — ⚠ a note control beyond the text is a GAP, one yes/no to Battlewrath when hit,
                  never derived.
      RUN-NODE    READ-ONLY FACTS + the one PROMOTE act (facts placed, never judgements — the run's data
                  is never edited here). ⚠ Everything richer — candidates pre-marked, draft routes, obvious
                  defaults filled — is AP-6, BANKED OFF-BASIS: not buildable under A10.3, and building it
                  in would drain a proposal by accident.
      Standing constraints that bound all four: a control with no record field or side-table value does not
      belong (AI-4's 14) · an empty node is refused at build · ⚠ CORRECTED (AI-41 → AL-66): NEXT's store field
      EXISTS (`Routes.SetNext`, §480) — AL-65 restated an already-satisfied bound four days after it was
      met; the rule the bound expressed (a control lands WITH its field, never ahead) stands.

    THE AUTHOR'S VOCABULARY, DECIDED (AL-29, 2026-08-22 — AI-15 asked which of the runtime's thirteen terms
    an author CHOOSES, which are DERIVED, and which never surface; asked before the wiring pass bakes the
    runtime's spec into the pane by default):

      CHOSEN, per node      STAGE slot (+1 or swap) · STEP slot (+1 decimal or swap) or the "no order" tick ·
                            LED TO (a tick, default on) · NEXT (from the offer, the default shown) · REACH ·
                            BAND (a slider with its default; ⚠ the ceiling framing RETIRED by Battlewrath,
                            2026-08-27: *"I don't think it needs to be data sourced as in measurement.
                            We'll be there all day trying to find every dungeon's height bands … any more
                            and we're reading through floors, which is why the system exists to protect
                            against."* The ceiling is a JUDGEMENT — the same kind of chosen constant as
                            `R_CEILING` (`concepts/r-and-band.md`): `BAND_STEPS = { 2.5, 5, 7.5, 10 }`,
                            first rung = the seed — AI-41 → AL-66)
      CHOSEN, per tab       SENSE-WORD (the seed's is When on; an added tab prompts) · ACTION · its ARG ·
                            TRIGGER (Once | Every time)
      DERIVED, never shown  step 0 (it is the tick) · lone (a childless beacon IS the node) · led-to on tray 0 ·
                            "nothing follows" (absent Next on a zero node) · stage:step composition · the
                            address · the bucket · the manifest · every latch's state
      ✓ RULED (Battlewrath, 2026-08-22, AL-35): BOTH latches are AUTHORED — "they have different use cases."
                            The architect's derived read is STRUCK. Per tab, each action word carries an OFFERED
                            DEFAULT the author can flip, WeakAuras-like — boss → Every time (you can safely wipe
                            and retry; Once would be unwanted) · say → Once (no speaking on every run-past; on a
                            wipe the last instruction is already in the group's memory) — because deriving from
                            the action would HIDE THE SETTER, which is not programmatic. The node-level control
                            stays, owed.
      So an author meets the per-node and per-tab choices above, all with defaults; the rest of the terms are
      the runtime's and the pane never names them (counts removed (drill 3, 2026-08-22) — count by reading). "The spec is the pane" reads THIS list, not the runtime's.

### 4e · THE FRAME'S IDIOMS — measured from the client's own map-with-panel (audit/prior_art_worldmap_2026-08-21.md)

Battlewrath: *"the default game has a version of this — the map vs the map with quests on display."*
The 3.3.5 `WorldMapFrame` is the shape, measured from the fork's shipping FrameXML. What transfers:
an invisible RULER frame every piece of chrome anchors to (layout stops caring about resolution) · the
panel bolted to the map's edge by ONE anchor set at creation and never re-anchored — hiding is not
re-anchoring · ONE number that is both the mode and the scale · panel presence DERIVED from content,
with only the user's chosen axis persisted · position for an undocked window kept in a 1×1 PROXY
frame so the real frame reparents freely · selection as an ID re-resolved after a rebuild, one shared
highlight · the two modes differing by a TEXTURE SET, not a rebuild (the collapsed strip in the panel's
own textures — one language). Two things NOT to take, measured in the same file: ~30 hand-listed
Show/Hide calls repeated in four transition functions (the thing A10.9's derived visibility replaces
with one `ApplyMode` over a per-mode table), and one widget's visibility owned by two files.

### 4f · THE FIELD'S IDIOMS — a census of every launcher addon (audit/prior_art_ace_field_2026-08-21.md)

230 addons: 22 embed Ace3, ~37 write option tables, **only 9 drive AceGUI widgets directly** — everyone else
lets AceConfigDialog draw, or builds raw frames. What transfers, measured: **tabs as DATA** (`childGroups`,
66 uses in 22 addons — tab-in-tab is a shape users already read) · **TSM is the one addon that built our
thing**: one frame, a strip of tabs, `ReleaseChildren` + a per-tab BUILD callback, a declarative page table
with ONE layout pass per container, `relativeWidth` not `SetPoint`, auto-height from `LayoutFinished` + a
chrome constant, a SERIALISABLE selection path (the per-tab return band's mechanism), a theme registry
with semantic accessors (the WA-like tone without forking widgets) · **fold-in/out** = hide + announce a
layout change, state keyed by section id (AdiBags), or an accordion whose ROW owns its height and the host
only accumulates (LibellusLeti — the best local model of computed padding) · **"add another"** =
`args[key] = group` + `NotifyChange`, very common · **dock/undock is NOT a convention** — two addons do it,
both raw frames: reparent + RESTORE THE SUPPRESSED CHROME + a sentinel flag (the return band is that chrome)
· **two-level visibility** — a master toggle that keeps per-item state (Skada) is the collapsed strip that
restores all · position = a four-field status table anchored TOP-from-BOTTOM (LibWindow is rare). ⚠ Two
facts for the build: the live AceGUI will be **41**, served by AI_VoiceOver (our r960 is the FLOOR, not the
copy that runs); and our widget set lacks **ScrollFrame**, which every tall pane and AceConfigDialog's own
root need. And our four hand-placed `SetPoint` sites sit in the same list as SignalFire's eleven.
**Ruled (Battlewrath, 2026-08-21): UI STATE LIVES IN AceDB** — fold · selection · dock · geometry — the
client-wide convention (every other Ace3 embedder carries it); *"we're still learning how to use Ace"*, so
we take the field's shape. The field's own split guides the namespaces: selection → profile, fold → char,
geometry → profile (§4f's census). Dock state stays account-wide per AL-13 — AceDB's `global` section.

### 4c · THE READER'S FIRST RUN — the consumer surface, settled moment by moment (R10, Battlewrath 2026-08-21)

    1 RECEIVE   Two channels, kept apart. (a) The raw string is the COMMUNITY channel — Discord, personal
                notepads; the addon is a PERSONAL INVENTORY of routes, and the Receive box (multi-line,
                one Read button, on the reader's remote) is how a string enters it. (b) In-game, "I have a
                route" is a SYNC concern — a machine channel: join when sharing, leave when not, or join on
                "in instance" so the party can see who has the addon; sharing stays HUMAN comms, never
                auto-assigned; later, an opt-in "Sync with tank" (the tank holds the routing role; this is
                mainly their tool). (b) is NAMED, not built.
    2 SEE       decode → present enough to WANT to consume it (map · route name · who/when · stage count ·
                bosses by name) → it lands in the user's ROUTE INVENTORY. A failure is one line in the same box.
    3 SAVE      the RID re-mints; the route appears in the OFFER when its map is current, under "all routes" otherwise.
    4 SELECT·ARM  SETTLED (Battlewrath, same day — and it supersedes his own earlier "one surface"):
                THE NOTE AND THE CONTROLS ARE SEPARATE. Two panes, placed separately so steering does not
                own the reader's UI:
                  THE NOTE PANE    information + direction — stage / step · the note. If all is going well
                                   this is ALL the reader has on screen; closeness is the supertracker's.
                  THE REMOTE       steering — select · Arm ↔ Stop · the stage / step for CORRECTING WHEN
                                   LOST, with a COLLAPSE button that turns it into a media-player-like
                                   corrector (small, out of the way). "Flight" and "steering" placed apart.
    5 FIRST ARROW  = STAGE 1: it loads and LURES; all ordinal items self-complete. RECOVERY NEVER USES THE
                SUPERTRACKER — the reader observes and corrects; tray-0 items never write the arrow.
                ~~Not expressed in code today~~ [AL-19 / (drill 3, 2026-08-22): the LED TO tick is expressed and READ —
                `Routes.LedTo`, `Routes.IsPosition`, read by the manager before the lure; only its SETTER is
                owed, RI-63]; tray 0 is exempt by construction.
                Names for a human: the NAMES table ships; the READOUT (a view) resolves names at display
                time; the driver never opens it.
    6 A STAGE COMPLETES  the manager EMITS — NEVER IN CHAT. The reader has ONE FIXED DISPLAY: stage / step ·
                the note. Closeness is shown by the supertracker and nothing else. NO DIAGNOSTICS IN-FLIGHT:
                the hit / first-hit readout is the TEST DRIVE's (author side), not the reader's.
    7 OWN NOTE  not in the pipeline — no personal-note import exists. Maybe a global table Dungeon Run holds,
                read by its own manager. TBD; RETIRED for this heading.
    8 END       last stage done or Stop → terminal: disarm, tracker to the park, "Route complete"; Stop reverts
                to Arm. A RE-RUN means leaving the dungeon and coming back in.
 The throttle is correctness, not cost: under
point + band + gate a poll that is too slow *misses the beacon*. Nothing armed = nothing running.

---

## 5 · THE MACRO LAWS — the ones that shape everything below them (homes cited; ~110 more live there)

    ≡ THE PRIMITIVES — the principle behind each law is what GENERALISES; check it FIRST (Battlewrath,
      2026-08-25: "it's the principle behind the law that generalises"; drafted by the Analyst against the
      record, folded AI-35 → AL-61, full pass with instances: `audit/law_pass_2026-08-25.md`). A reach the
      primitive does not cover stops here — the clauses below are a history of arguments, and twenty laws
      have had none.

    ⚠⚠ NAMES, NOT NUMBERS (Battlewrath, 2026-08-25: *"Let's make laws unique. By addon, then primary
      concern as one word"* · *"cost isn't a concern when we can't discuss the same thing"*). Every
      DungeonRun law now carries its addon and its concern — `DR_UI_3` · `DR_Content_1` · `DR_Pane_4` ·
      `DR_Sensor_3`. **This SUPERSEDES AL-61's fold (3)**, which kept bare `L-N` and asked cross-product
      citations to qualify; that convention was correct about the cost and was overruled on the cost.
      ⟶ Swept by `addons/tools/rename_laws.py` (286 rewrites, `--verify` clean).
      ★ A bare `L-N` surviving in these docs now belongs to ANOTHER PRODUCT — `landmark_design.md` and
      `satnav_ledger.md` carry their own series, and their L17/L18 are different laws from ours.
      ⚠ A bare `law N` in prose is UNSWEPT and ambiguous by construction (17 left, listed by the tool);
      those are a read, not a sweep.
      DR_Content_1  a record's worth is that it is NOT a judgement — interpretation can be redone; an observation not taken is gone
      DR_Content_2  an authored value has a PROVENANCE the author can point at
      DR_UI_3  the user is the decider; the system makes state VISIBLE, never prevents it
      DR_Boundary_4  a consumer must not depend on its producer
      DR_Content_5  what TRAVELS is a projection, never the live object
      DR_Boundary_6  no shared mutable state between participants
      DR_Runtime_7  pay for selectivity ONCE, at load — never per sample
      DR_Runtime_8  a loop must not observe its own mutations
      DR_Runtime_9  separate what DECIDES from what REMEMBERS
      DR_Content_10 a condition is a PLACE plus a HAPPENING; lacking either, it is a different kind of thing
      DR_Content_11 identity is OPAQUE and STABLE; everything a user can change is a property
      DR_Runtime_12 a single-slot resource is never left EMPTY; the successor overwrites
      DR_Process_13 precedence is declared IN ADVANCE, so a disagreement is REPORTED, never adjudicated by its finder
      DR_Process_14 one home per fact — a copy is drift with a delay
      DR_Content_15 take the COARSEST identity that still answers the question
      DR_Runtime_16 optimise only where the time actually goes; elsewhere prefer the proven shape
      DR_Content_17 a thing belongs where its meaning is COMPLETE, not where it is convenient
      DR_Process_18 if something can be WRONG, it must be FINDABLE
      DR_Process_19 a question with a physical answer belongs to MEASUREMENT, not taste
      DR_Content_20 removal is a STAMPED EVENT, never an absence — absence cannot be told from oversight
      DR_UI_21 PREDICTABILITY — a system users KNOW rather than react to; an offer is a function of ONE input the user just chose
      DR_UI_22 the cost is the INTERACTION, not the layout — no amount of layout taste pays off a swap

    DR_Content_1  EMIT, DON'T INTERPRET — capture holds what happened, never what it meant; capture is the only
        spawn; everything downstream inherits, nothing derives                         capture.lua · use-case §6
    DR_Content_2  NEVER INVENT a position, a height, a boss name — from reads and the run's record only; the
        sample OFFERS, the author DECIDES                                              use-case §3, §6
    DR_UI_3  TELL, NEVER LOCK — collisions told inline; expose a gap, never renumber or warn; refusals name
        what was missing; pass-through shows the code word                            A10.4 · RI-23 · A5.1
    DR_Boundary_4  THE FLAT LIST, NEVER THE CORPUS OR THE STORE — the driver is installable without the editor,
        PROVEN by an isolated load                                                    routes.lua:509 · A11.6a
    DR_Content_5  THE EXPORT IS A PROJECTION — identifiers and numbers; tables where they keep the line light;
        composing where that is the correct solution; editor-side, one pass, versioned    data model rows 5–17
    DR_Boundary_6  ONE AUTHOR, MANY READERS — every reader's driver is its own sensor; nothing pushed; progress
        never travels                                                                 use-case §2
    DR_Runtime_7  THE GATE IS AN INDEX AT LOAD — bounce on the prefix first; 0 = always eligible; bucket may fail
        loudly, stage may not                                                         data model rows 4a, 10, 23–27
    DR_Runtime_8  ONE PASS PER SAMPLE, ONE EVALUATION PER NODE — advance swaps buckets after a poll, never
        inside one; nothing authored is interpreted on the hot path                   rows 19–26
    DR_Runtime_9  A PURE RULE, A STATEFUL SENSOR — the rule holds nothing; the sensor is inside the driver and owns
        the in-sets; THE MANAGER owns the cursor (corrected (drill 3, 2026-08-22)); nothing armed, nothing running   A11.3 · A11.4
    DR_Content_10 SENSE = LOCATION + BEHAVIOUR IN R; boss is an action word; a tab is self-completing; Next is
        the node's and is one field; all tabs must satisfy; told-or-dry                 RI-15/17 · A2.7–A2.9
    DR_Content_11 IDENTITY IS THE ADDRESS; stage and ordinal are properties; only the RID re-mints; no update path  RI-4/6 · A8.4
    DR_Runtime_12 THE TRACKER ALWAYS HAS A TARGET, never a spent one — the PARK; the next marker overwrites     A11.9
    DR_Process_13 THE LOWER-NUMBERED GOVERNING DOC WINS; a disagreement is REPORTED, never resolved by the
        builder; "ruled" = his best working model, dated                               DRIVER_BASIS one rule
    DR_Process_14 A BRIEF CITES THE MODEL, NEVER RESTATES IT; a record carries the NAME, the driver owns the FUNCTION  basis · row 4a
    DR_UI_22 USED TOGETHER, ONE SURFACE — A TAB MAY ONLY SEPARATE THINGS USED APART (Battlewrath 2026-08-25,
        AI-31 → AL-59): things used continuously together must share a surface; putting one behind a tab
        makes the user swap away from the thing they are working on and back — "whack a mole until you get
        what you want." The test is the INTERACTION, not the widget kind: steering the map while authoring
        on it → one surface (A10.9); capturing vs authoring → different whens, different surfaces (AL-49).
        No amount of layout taste fixes an interaction cost. ⟶ DOCK/UNDOCK IS THE AFFORDANCE this law
        leaves room for (his gloss, same day): when two tabbed things are wanted at once — Promoter and
        Object in view, Object undocked to the side — undocking is the escape; **the DEFAULT is tab
        swapping.** An affordance, never the norm                       home: §4d surface · AL-49's whens
    DR_UI_21 PER SELECTION — AN OFFER IS A FUNCTION OF THE PICKED WORD, NEVER OF CONTEXT (Battlewrath 2026-08-23,
        AI-20 → AL-48): every default, ghost value, pre-selection or enablement is fixed by the word the
        author picked and is identical every time it is picked — no offer reads the node, the siblings, the
        stage or history; a tab is scoped to itself. Enforcement structural (`Routes.OfferedTrigger(action)`
        admits no context argument; a smoke asserts a second changes nothing); the author may always
        override — the law fixes what is OFFERED, never what is CHOSEN. Its authoring-order CONSEQUENCE and
        its MEANING/SUBJECT BOUNDARY live at the home — moved there by AI-35 after the entry grew a clause
        per wrong reach (DR_Process_14 applied to this entry itself)      home: §4d surface (the order · the boundary) · §4b latch · AL-48/58
    DR_Content_20 A VOCABULARY IS RETIRED THE WAY A FIELD IS (AI-16 → AL-33): ONE source of truth per OFFERED list, with
        retirement STAMPED on the entry (term · retired-on · by which ruling), never an entry deleted from one
        list and left in another; the pane reads the live set; `DropRetired`'s sweeper has a sibling that
        reports an offered retired word. Half-formed vocabulary invites authoring on it   home: §3a adaptor · the checkers
    DR_Process_19 A HEDGED ANSWER WITH A PHYSICAL REASON IS A SPEC FOR A MEASUREMENT (AI-14 → AL-28): when Battlewrath
        answers "maybe N — because ⟨a physical fact⟩", the fact is the measurement's spec and the bench
        measures; asking him again is asking the wrong lane. Taste is for what a surface SAYS; whether two
        edges line up is arithmetic a checker holds                              home: §7 · the checkers
    DR_Process_18 LOAD-BEARING ⟹ SOURCEABLE (Battlewrath, 2026-08-22, AL-26): "inventiveness is useful in the macro /
        prose, but when something is load bearing it earns being sourceable" — greppable, inspectable. A derived
        constant stays a LITERAL with its pairing ASSERTED at test time (never a runtime expression, never a
        bare comment); a concept gets a HOME — an index page that points, never restates (`concepts/`)   home: §7
    DR_Content_17 A CAPABILITY SITS IN THE LAYER WHERE IT HAS MEANING (Battlewrath, 2026-08-21, "the general rule") —
        behaviour is what happens when the player is HERE; anything that has its meaning before the sense
        (getting them here) or after it (where the route goes next) is CHARACTER, never a row. `set`/`ratchet`
        (too early → Next) and `supertrack` (too late → "led to") both fell to it        home: §4b · §4d · AL-19
    DR_Runtime_16 THE HOT PATH IS SENSOR → ACTION; A STAGE OR STEP CHANGE HAS TRAVEL TIME ON EITHER SIDE — so the
        swap is a REBUILD BY EVICTION (the field's shape, prior art §5) and is never optimised; care and
        budget go to the sensor → action patch. "We reference what is proven; we don't invent a handling
        where it buys us little." (Battlewrath, 2026-08-21)                       home: §4b · A11.4 · the manager's acceptance
    DR_Content_15 THE MAPID IS THE HIGHEST IDENTITY OF LOCATION — the tracker and the gate care for nothing finer; a zone
        a dungeon expresses is collected by the run and pointing into it stays true (Battlewrath 2026-08-21,
        G4; landed here and in ARCHITECT_LOG AL-9 so it is not stranded in struck text — (AI-2 audit, corrected 2026-08-21))  home: A11.2a (Analyst cites)

---

## 6 · THE GAPS — what a builder would still have to INVENT (for Battlewrath's word, one at a time)

_The "bucket = one stage, its items = its steps" class: self-evident, unwritten. Each line is a gap and
where the record goes silent. No answers here; answers go to the governing doc that owns the part._

**Consumer — the run itself**
- ~~G1~~ CLOSED 2026-08-21 → the ROUTE MANAGER (§4b 2, 5, 6). Was: **Who designates the current sequence.** `Bucket.Stage` hands out any stage asked for; nothing holds `currentStage`; `Driver.Designate` is built and deliberately uncalled. (RI-38 OPEN)
- ~~G2~~ CLOSED → the manager's LEDGER firing Next (§4b 5). Was: **The raiser.** An advance needs a COMPLETION to raise it; completion is nobody's today (the ledger is V2). Who calls Designate, on what.
- ~~G3a~~ CLOSED → an ACTIVE ROUTE runs from ARM to END, with a named terminal state (§4b 2, 8); "run" is the Run side's word (R3). **G3b OPEN** (AI-2 audit, corrected 2026-08-21): what the author's test drive (`/dr drive`) is in relation to an Active Route — the same manager, or a second one. Was: **What a RUN is, as an object.** What starts one, what ends one, whether a finished route has a terminal state, what `/dr drive` means twice.
- **G4 Reload — SHAPED, not decided** (§4b 9: one selected-RID slot, no progress saved, re-arm lands by recovery); ~~zone change~~ CLOSED (Battlewrath: the tracker cares about the highest identity of location, the MapID; a zone, if a dungeon expresses one, is collected by the run and pointing into it is still true); loading screen = the mapID gate per sample. Was: Driver and sensor state are plain locals; nothing says whether a run survives a `/reload`, or what the run does when the mapID changes under it (the neighbour addon records the client fact: across a boundary, zero satisfies every radius test).
- ~~G5~~ CLOSED → one active route at a time; right map → offer the right routes → load one (R6, §4b 0). Was: **Multiple routes per dungeon.** `Routes.List(mapID)` returns many; `Bucket.Build` takes one. How a reader holding several chooses; whether more than one may be armed.
- **G6 CLOSED BY DESIGN, OPEN IN BUILD** (AI-2 audit, corrected 2026-08-21): R7 → cannot be authored once the pickers land (A10.3e ✗) and the bucket refuses a duplicate at load (AL-8 — BUILT (AI-7, re-measured 2026-08-21): the bucket's refusal list now carries *"two beacons at stage N (A and B) — re-slot in the editor"*; the runtime side is closed, the author-side pickers still ✗). F2's sequencing held. Was: **Two beacons at one stage.** Measured to share one step cursor (RI-41).
- ~~G7~~ CLOSED by R8 → *a stage IS a beacon; a beacon with children becomes a stage with steps*; Step = the child's position in its stage's sequence, restarting each stage (model §1). Was: **What Step is scoped to.**
- **G8 V1 "has no stage" but the editor mints one for every beacon.** Filed, not resolved (RI-39 OPEN). Either the statement or `AddBeacon` is wrong; the bench will not change shipped authoring behaviour from a doc reading.

**Consumer — the reader's surface**
- ~~G9~~ CLOSED → two panes: the NOTE PANE (stage / step · note — information and direction) and the REMOTE (select · Arm ↔ Stop · correct-when-lost, collapsible to a media-player-like corrector) (§4c 4). V1 arms by a function call; the reader's select-and-arm surface belongs to Routes and no row describes it.
- ~~G10~~ CLOSED → the Receive box on the reader's remote for the community string; an in-game SYNC channel named for later (§4c 1). Was: **The import door's home.** Transport and the multi-line box are settled; which addon owns the paste box, where it lives, and what a decode failure shows.
- ~~G11~~ CLOSED → the NAMES table ships; the READOUT view resolves at display time; the driver never opens it (§4c 5). Was: **Who resolves NAMES for a human.** The driver reports addresses; the editor has the index; a bare consumer readout either ships with the NAMES table or shows addresses. (data model seed S3)
- ~~G12~~ CLOSED → one FIXED display: stage / step · the note; never chat; no in-flight diagnostics (§4c 6). Was: What "stage complete" DISPLAYS at the moment it happens — the word Complete/Reached is a dropdown label, not a reader's line.
- ~~G13~~ CLOSED → three writes, all the manager's: the entry lure on arm/advance · a supertrack tab on dispatch · the PARK on end (§4b). Was: How the arrow is set and released — the escapement is ruled (park, overwrite, horizontal); who calls `SetSuperTrackedPosition`, on what event, is not.
- **G14 RETIRED for this heading** (no personal-note import exists; maybe a global table Dungeon Run holds — TBD). Was: The personal-note slot on the reader side — scoped (RI-10), no consumer row, no store, no surface.

**Consumer — the machinery**
- **G15 The runtime tier has no declaration** (bucket, items, armed snapshot) and **the sensor has no contract** (what arm/disarm/reset take and return). Bench's, owed.
- ~~G16~~ CLOSED (drill 3, 2026-08-22) — the model (now committed, #3 row 23) and `bucket.lua` both carry ONE level, bare rows; only `driver_sensor_brief.md` (reference-grade) still says `[stage][step]` — a one-line bench item. Was: **LIVE DISAGREEMENT: bucket shape.** The model (uncommitted) now rules ONE level — the bucket is the stage, entries are bare rows, `step` a field never a key; `bucket.lua` and the sensor brief still describe `[stage][step]`. The record moved ahead of the code; reported, not resolved.
- **G17 The action binder's shape** — row 25 wants a callable per action word; the runtime holds none; `Bucket.Resolve` is a hook asserted nil.
- ~~G18~~ CLOSED, BUILT (AI-7, re-measured 2026-08-21): the sensor keeps the previous in-set and returns the transition word (AL-2 / RI-42) — built (§4b's L2.3; `Sensor.Arm` four sets, `Poll` returns `changed`). Dispatch is not blocked. Was: The sense words are transitions, and the sensor keeps no previous verdict — `Poll` overwrites the in-set; `Seen`/`When off` cannot be computed from what is kept.
- ~~G19a~~ CLOSED → re-arm IS the bucket swap after the poll (§4b 6). **G19b OPEN** (AI-2 audit, corrected 2026-08-21): the in-set's semantics once armed ≠ eligible (the two-set split — ⚠ (AI-7, re-measured 2026-08-21): the cited header note is gone from `sensor.lua`; the gap itself stands unadjudicated, cite the sensor brief G5 only). ★ RULE, from this fault: a multi-part gap is struck only when EVERY part has its citation. Was: Re-arm on a stage advance; the in-set's semantics once armed ≠ eligible — "may not be needed at all, but nothing has said so."
- **G20 `ARRIVAL_HOLD = 1.00 s`** — in the asklist's constant block, not in the code; decided by nobody.
- ~~G21~~ CLOSED → the sensor's, in `sensor.lua`; COA_Landmarks is prior art only. Was: Throttle ownership — the constants live in `sensor.lua`; the basis points at COA_Landmarks, a different mechanism. Whether they are one thing.
- **G22 Transfer corruption has no detector** — a newline-translating round trip parses into a WRONG route rather than failing; whether it earns a byte is undecided.
- **G23 The coordinate bound's rejection half** — a value that decodes cleanly and is still out of range. Battlewrath's.

**Producer — SHIPPING CONSTRAINTS ON RUN (Battlewrath, 2026-08-22, AL-38; community engagement is broadening the need)**
- **G29 RUNTIME IMPACT of the capture suite — a MEASUREMENT owed, re-measured per sensor.** Capture is the cheap
  shape (an OnUpdate only while recording, 1 Hz); the suite's LISTENERS are the cost, CLEU first — the rule is the
  manager's reused: register on record-start, unregister on stop, index at load, never a test per event. The
  debug log gains one column: frame-time with capture on vs off, per sensor. "We flag that a run loads
  performance" becomes "we flag the MEASURED figure."
- **G30 STORAGE — ~500 KB a run today, almost all samples.** ⚠ REORDERED (Battlewrath, 2026-08-22, AL-42): **the
  FILTER is at the EMIT** — first emit what is useful (what was parsed against and is worth surviving); PRUNING the
  raw record is a SECOND STEP, separate, later, the user's — never a product. The store split that makes this
  free (raw per character · parsed-against in global) is AP-9/AP-11, held in the proposals bank. The three
  moves below are read in that order — retention and compaction are step two: (1) RETENTION,
  no loss — N runs per map, oldest pruned at logout; (2) COMPACTION that keeps the motion shape — the industry
  standard, GPS track simplification (Ramer–Douglas–Peucker), tolerance ≤ what the driver can sense (the band
  2.5 yd · the reach floor 5), so nothing a route could be authored against is lost; (3) NEVER prune the meaning
  — markers, boss and mob deaths, pins, floor swaps. **ORDER (his): BUCKET BEFORE CLEARING** — simplify the
  path → fold every event into the SEGMENT it happened on (a mob death becomes a fact of that stretch) → only
  then clear the raw samples. ⚠ Capture's own law (never clean, merge or dedupe a point) means compaction is
  NEVER capture's and never silent: the raw run is the truth, and compaction is the USER's explicit act on a
  run, TOLD ("12,000 samples → 900, shape kept within 2.5 yd"). Routes never back-reference a run, so pruning
  or compacting can never break one — the reason for that rule, cashed here. Measurement owed: the compaction
  ratio at the band tolerance on the existing corpus (the desk can run it today).
- **G31 COMMUNITY INPUT (2026-08-22, `addons/Materials/Addons_Dungeon_run_Community/`, two files; AL-39) — the
  broadening, banked, nothing decided.** CAPTURE SUITE asks, each a sensor that G29/G30 must cost: BOONS (fixed
  locations, random buff among ~15-20; capturable by the tooltip prefix "Mythical Boon:" → a run marker → an
  authored "pick up buff" beacon) · TRASH % (the client's own % window; map increments against unit deaths by
  time signature — simultaneous deaths stay AMBIGUOUS, emitted not resolved) · mythic champions (count as a
  boss) · trash danger tiers · interrupt-critical spells · target-held time + max HP · health dips · mob
  abilities (the tank's minimum: the layout, % per mob, abilities) · death recap · health at segment end.
  **THE CAPTURE METHOD (Battlewrath, same day):** listeners are scoped by CADENCE, not by session — combat
  start REGISTERS the unit-died listener (name + the % reading per death event), combat end UNREGISTERS it
  (the two-way edge, G29's rule); the BOON needs no listener — whichever API surfaces the buff is read on the
  1 Hz sample, the position is the sample's ("close enough by time"), and the CUSTOM MARKER is what makes it
  stand out. Much of the register/unregister may already exist in capture.lua's own discipline.
  AUTHORING asks touching the CLOSED LIST (a word later, not now): "Kill until % = N" — a completion on a
  THRESHOLD, not a place → a verb (`percent`, arg = N) and the list grows by one; shopping-list notes —
  untracked, already expressible. ROUTE CHARACTERISATION — the OFFER gains filters: KEY LEVEL · AFFIX · the
  capturer's CLASS; and SPLIT KEYS (Scholomance upper/lower · WC · BRD · SFK · Strat) — two halves under one
  map: a route's scope may need more than MapID → **G32**. CONFIRMATIONS: the boss list per dungeon is FIXED
  (ZF 6 of 8-9; WC 4 of 4) so routes stand — no nearest-route finder; pooled samples → profiles = "many runs
  per map" (ruled); a route MINI-MAP was REJECTED by the community as overload — the two-pane reader and the
  native-map lean confirmed from the user's side ("this will be the one we'll use while running").
- **G32 A ROUTE'S SCOPE under split keys** — one MapID, two halves (upper/lower); the offer, the picker's
  run sources and the route's identity may need a half beside the MapID. Battlewrath's, with the community.
- ~~G27~~ CLOSED (Battlewrath, 2026-08-22, AL-36): the picker's source is **every run on the MapID ∪ the route's own
  NAMES table**; with no run on the map — the EXPECTED case for import — **position is LOCKED, behaviour is
  EDITABLE**, and a new name is TOLD ("no run for this map"), never typed. The map gets its own KNOWN-MAP picker
  (maps known from routes and runs); RUN AND ROUTE ALWAYS WIN over it. All of this is the CUSTOM MAP construct
  in Dungeon Run; Dungeon Routes may use the NATIVE map in lite terms (addon-conflict safety), its content
  already reduced to actionables. Was: What feeds the boss / mark picker on a route with NO RUN LOADED.
- **G28 (from RI-67/68) The node's ICON / appearance and the map's PLACE / UNPLACE drag** are not in this
  inventory — appearance appears once, as the roster's; nothing rules the drag. Bench to name the parts.
- **G24 The action TABS do not exist at the author's end.** Export, driver and model are specified against N rows per node; the shipped pane writes one. The biggest unbuilt step on the producer side and the one every consumer test assumes.
- **G25 The side tables' exact key forms and placement; what provenance survives an import** (blocked until export's travel half exists).
- ~~G26~~ CLOSED → the word is RETIRED (R11): ingest → bucket → arm. Was: Pre-load — Battlewrath's term, nowhere on disk; retired as a label (BUCKET/STAGE) but never answered as a question.

---

## 6b · THE HEADING NOW — THE PROOF (Battlewrath, 2026-08-22, AL-40)

*"We need to prove that the instruction / table of a Route is enough to drive the manager, and that the
manager can meaningfully use the sensor to determine and schedule."* Four claims, each with a home:

    1  THE RECORDS ARE ENOUGH TO BUILD A BUCKET     hand-written records in the contract's shape, no store, no
                                                   editor — the isolation demonstration (A12.2d–f)
    2  THE BUCKET ALONE DRIVES THE MANAGER          offer → build → arm → dispatch → complete → advance → end
                                                   on synthetic samples (A12.1–A12.9), now with the two latches,
                                                   Next's three types + no-outcome, Set clamped, the seed, the
                                                   empty-node refusal
    3  THE SENSOR'S SCHEDULE IS MEANINGFUL          the approach throttle · the changed set with its transition
                                                   word · the floor set as permissive membership · W7.2's synthetic
                                                   branches · and the testable heart of "meaningful": a node walked
                                                   through at running speed is never missed at the poll floor
                                                   (the R-floor pairing, DR_Process_18's assertion)
    4  THE EVIDENCE IN THE CLIENT                   a named test run on a real route through the test drive, recorded
                                                   by the DEBUG LOG (arm · the arrow · each dispatch · each completion
                                                   · the advance), against what DevDump's chain test proved (AL-25)

    The author-side row wiring (E-0) is NOT on this path — the proof runs on records, as AL-12 intends.
    FIRST: `emit_built_state.py` must run (one bad cite) so the greens are DERIVED, not read.
    The Analyst grades; the bench builds only what a claim needs; the architect audits at the end.

## 7 · HOW THIS DOCUMENT IS USED

_PROPOSALS (AL-41): `ARCHITECT_PROPOSALS.md` holds feature enrichment reasoned with Battlewrath but kept OFF this
factual basis until we are stable enough to drain it; it governs nothing and is cited by nothing that builds._

_Concept HOMES (AL-26): `addons/planning/concepts/<concept>.md` — one short page per load-bearing concept: what it
IS, its closed list, and a POINTER to every document that rules or grades it. An index, never a copy; the
pointed-at documents stay authoritative. Template and first page: `concepts/next.md`. The owed three (`trigger` ·
`arg` · `r-and-band`) all exist as of 2026-08-28. Checkable: a home names every document the vocabulary appears in._

_Client-only seams (AL-25, Battlewrath 2026-08-22): a piece whose whole job is to call the game is built
THIN (no branching; the shipped guard + pcall), the smoke proves everything up to the door, and its
acceptance is THE DEBUG LOG of a named test run — a record, never a bare look — measured against what has
worked before (COA_DevDump's chain test)._

_**THE ACE3 POSTURE (Battlewrath, 2026-08-24, AI-23/AL-46): for the PLUMBING — comm, serialisation, DB,
lifecycle, events, timers, hooks, console — the default is USE ACE; a hand-rolled module owes its reason in
writing, adopted ON TOUCH, never as a migration sprint. The default does not extend to the layout/offline
domain (the frame model, panespec, the coordinate space, the driver, the route contract) — that is the
product, not custom code owing a justification. Verdicts, reasons and the era gate (the shipped fork copy is
the fact authority; the git is secondary): `audit/ace3_gap_2026-08-24.md`. His why: "Our ability to code is
not limited. Knowing what form the code needs to take to operate in WoW has just been handed to us whole
sale."**_

_Standing rule from AI-7 (2026-08-21): **this document asserts build state only as a pointer to the
checker that derives it** (`py addons/tools/emit_built_state.py`); it carries no counts of anything that
can be counted by reading. A status cell says what a part OWNS; whether it is built is measured._

**THE BUILD PRINCIPLE (Battlewrath, 2026-08-21, AL-12): Dungeon Run to RICHNESS first; the bench PROVES
with synthetic rows rather than A/B client testing; Dungeon Routes EARNS everything Dungeon Run proves.**
Not that Run cannot test drive — it is that deciding how to present information assumes the information
is structured enough to reach it. So the author's chain leads, the engine is built only as far as proving
needs, and the reader's screen waits on structure (RI-44).

_Two rules added from the AI-2 audit (2026-08-21): **CLOSED means BUILT; "closed by design, open in
build" is the mark for a ruled-but-unbuilt gap** — a closure that means designed reads as shipped.
**A multi-part gap is struck only when every part has its citation**; strike the answered part and
re-list the rest under a letter (G19a/G19b)._

- Battlewrath reviews §1–§5 in conversation and corrects; §6 is drained one gap at a time, each answer
  landing in the doc that owns the part (never here — here it becomes one line in §3 or §4 citing it).
- The Analyst reconciles implementation against §3 (ownership and must-nevers) and §4 (the principle)
  as it does against any governing doc; a part that does what §3 says it must never do is a finding.
- The Architect re-runs the gap drill before each leg and the grading audit after it; §3's status
  column is re-measured then, never hand-kept between.
- Governing position: registered in `DRIVER_BASIS.md` as **#0 — the macro model**; it carries no
  mechanics, so where it seems to disagree with a lower doc the mechanics doc is right and THIS file
  has drifted — report it.

---

## 8 · REVIEW BANK — Battlewrath's items on this document, iterated one at a time

_All eleven are resolved; their outcomes and reasoning are `ARCHITECT_LOG.md` AL-1..AL-7. This bank
stays as the index of what he raised on the first pass; new review items go to the inbox/log pair._

_Banked as raised (2026-08-21), in his words where he gave them. Status moves **banked → discussed →
landed in ⟨doc⟩**. IMPACT is a second pass, filled after the item lands, never before._

| # | item (his words / the gap it touches) | status | lands in | impact |
|---|---|---|---|---|
| R1 | §1: *"advances the stage when the boss dies"* → **advances when the stage's conditions are met; some stages are pulls or transitions / skips** | landed | §1 | — |
| R2 | §2 record shape is STALE: **`MapID:RID:BID:CID:stage:step` are the gates, then the payload function call; the stable details (`POS · R · Band · Next · Trigger`) ship as TABLES in the export.** ⚠ OPEN, not invented: a per-ID table could carry its tabs already laid out for bucket consumption, leaving the instruction set an ordered per-line gate list — **review WeakAuras and the flight-controller repo for how it is handled in the wild** before choosing | discussed → landed: the per-ID tables ARE the records, the ordered gate list IS the bucket; function + arg ID ride the behaviour record once per tab; the tick list is built, never exported (2026-08-21) | §2 · data model (bench to mirror) | — |
| R3 | TERMS: a **RUN** (Run side) = human-initiated collection — a reference capture of a route, or a map of the whole dungeon as positional basis, mobs and bosses seen, special markers. An authored, imported, live route = an **ACTIVE ROUTE** — ingested ahead of entering or at the point of engaging; human-selected, shared, armed, then driven. Unique terms, no overlap | landed | §1 (use-case target to mirror) | — |
| R4 | G1 + G2: **a central ROUTE MANAGER that holds the current stage and calls the active bucket and the stage-0 bucket (catch-all / recovery)**; the raiser probably lives there | landed — the ROUTE MANAGER, §3b + §4b; G1/G2/G3/G5/G13/G18/G19/G21 closed on it | §3b · §4b · data model runtime tier (bench) | — |
| R5 | G4 reload: **would mean writing active / not-active to saved variables to survive sessions — with no pruning on saved variables that sprawls to garbage.** shaped (§4b 9: one slot, no progress) — not decided | §4b · §6 G4 | — |
| R6 | G5: **one active route at a time — right map → offer the right routes → load one** | landed | §4b 0 | — |
| R7 | G6 — **DIRECTION CHANGE**: tighten what can be authored and how conflict is resolved AT AUTHOR TIME — **slots per stage, slots per route**; swapping one stage for another on a fixed slot beats soft prompts in the wild; flattens a class of let-it-live-in-the-wild concerns | landed — the picker shows current, +1 (next whole / next decimal), or select a current → SWAP; no shift, no renumber; G6 closed | model §1 SLOTS · A2.10 · A10.3e · §4 | — |
| R8 | G7 (what Step is scoped to) — **to break down** | landed — "a stage is a beacon; a beacon with children becomes a stage with steps"; Step = position in its stage's sequence; G7 closed | model §1 · §4 · contract (bench mirrors into contract.lua) | — |
| R9 | G8: not a gap in the HOW — **route selection and display already exist (the Promote pane selects and runs); what is missing is the READ EXPRESSION of it; the same door serves both ends of the lane** | banked | §6 · A10.5 | — |
| R10 | **Consumer items (G9–G23) do not open into questions he can answer — DISCUSSION needed**: run as a worked instance, a reader's first run from paste to first arrow (G9–G13 in one sitting; G14 behind it); machinery gaps (G15, G17–G21) are build-shape → bench + Analyst, the record the arbiter; G16 resolves by record ↔ code catching up | discussed → landed as §4c (all eight moments settled in his words — 4 = note pane + collapsible remote, superseding "one surface"); G9/G10/G11/G12 closed, G14 retired | §4c · §6 · A10.5 / A11.5 / A11.9 (Analyst to reconcile) | — |
| R11 (landed) | **"Pre-load" was his term and is RETIRED — accurate, self-describing names are preferred.** The mechanism is three verbs, each a part: *ingest* (decode and save) → *bucket* (lay out per stage, resolve, refuse loudly) → *arm* (hand the current bucket + bucket 0 to the sensor). Rule for every term here: if a word needs a gloss, the gloss is the name | banked | §4 · §6 G26 | — |
