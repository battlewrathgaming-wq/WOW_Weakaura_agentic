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
OWES and may be CITED by a thread that already knows which it is. ⚠ Operational side-finding, for
Battlewrath: `boot.py`'s lanes carry no `analyst` and no `architect` — two of four seats cannot run
the mandated boot as their own role._

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
    CHARACTERISTIC record, one per node    the stable details — POS · R · Band · Next(Type,arg) · Trigger
    BEHAVIOUR records, N per node          one per action tab — Sense · action · arg  (function + arg ID live HERE, once per tab)
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

Status as of 2026-08-21: ✓ built · ◐ partly · ✗ not built. Citations are the part's own header or
its ruling; the mechanics live there.

### 3a · DUNGEON RUN — the producer

| part | status | owns | must never | where / ruled |
|---|---|---|---|---|
| **Capture** | ✓ | the run in progress; an OnUpdate handler *only while recording* | infer state from the event that woke it; clean or merge a point; store a set/count of bosses | `capture.lua` · A3.4 |
| **Store** | ✓ | the SavedVariables global — the ONLY module that touches it | keep `0` where `nil` is meant (absence stays loud) | `store.lua` DR-20 · model row 27 |
| **Routes** (the promoted objects) | ✓ | the shape under the store's route keys; the mints (CID, stage); the RID migration | back-reference the run (promotion COPIES); compute a height (inherited, never computed) | `routes.lua` · A2.x · A8.4 |
| **Promoter** (the mint) | ◐ | its own frame; CREATE-then-edit — a beacon exists the moment you press | gate on arrival order; a dialog | `promoter.lua` · §61 manage half unbuilt |
| **Editor / curation** | ✓ | the VIEW: trim, filter, replay | edit the capture | `editor.lua:46` |
| **Map** | ✓ | selection, arming, layers, the picture | hand out MAP xy where WORLD is meant — the real boundary is `routes.lua:484-492` (`Routes.Place` → `Calibrate.ToWorld`; the world pair left ABSENT when uncalibrated); `map.lua:45-59` is two MAP-space sizes, a different trap (AI-2 audit, corrected 2026-08-21) | `map.lua` · `routes.lua:484` |
| **Node editor** (object pane) — measured AI-4: of its 37 controls, 9 carry a record field, 14 carry NONE (`role · shape · match · unseen · answers` among them), `trigger` is stored with no control; position is map-side by design | ◐ DIVERGENT | a view onto one beacon/child | — ⚠ writes ZERO rows: it never calls `Routes.SetRow` (three flat setters instead); the bucket reads rows only, so a node authored today arms with NO behaviour. KNOWN and SEQUENCED (Battlewrath: Ace interface → WA-coded grammar → settled homes → the rows wire) (AI-2 audit, corrected 2026-08-21) | `object.lua` · replaced by A10.3, not folded |
| **Adaptor** (`code → user`) | ✓ | one constant table, one lookup, pass-through on a miss | error on a miss; carry more than the question layer | `adaptor.lua` · A5 |
| **Primary frame** (the map + its controls = ONE surface; a bolted-on panel of tabs, one per DOCKED group; dock/undock NOW — AL-13) | ◐ | the frame; the panel; dock state per group (account-wide UI preference, never a route's); one declaration per group in TWO arrangements (docked column · undocked window) | one flat option table; a hidden `Libs/` exemption; two declarations for one group; a one-way undock — RETURN is two paths in one language: the COLLAPSED STRIP (dock all, the bolt-on's own texture grammar) and a PER-TAB return band on each undocked window; a drawer by illusion (Battlewrath, AL-13) | `options.lua` · A10.1 · A10.9 |
| **Route-note plane** | ◐ | the notes that TRAVEL | touch the personal plane | A4.2 · owed: `NoteID → content` re-key |
| **Personal-note plane** (author side) | ✓ the PLANE (`store.lua:489` NoteTable · `routes.lua:1934-1962` NotePlane/AddNote/DeleteNote · drawn as a map layer `promoter.lua:389`) · ✗ only the PER-ROLE dimension and the dedicated pane (out, A10.6) (AI-2 audit, corrected 2026-08-21) | per-place notes that never travel | travel; sit on the authoring path | RI-10 · A10.6 |
| **Pickers** (stage / ordinal doors) | ✗ | a tick beside the picker for "none" | offer `0` in a dropdown | A10.3e |
| **Trigger control** (One time · Every time) | ✗ | — | reuse the word *Seen* | adaptor row; basis |
| **Flattener / exporter** | ✗ | the projection, in ONE pass over a finished tree, editor-side always | be consumer-side; be 1:1 with the store; carry scraped provenance | model rows 13–17d |
| **Test-drive remote** | ✗ | select · arm · go/stop · readout, by clicks | expose `stage` alone; need a slash line | A10.5 · A6.1 |
| **UI harness / layout / spec / widget** | ✓ | the control registry and the clickable plan runner | count registrations statically as proof | `ui.lua` · A9.1 |
| **Calibrate** | ✓ | map ↔ world fit per map | — | `calibrate.lua` |
| **Core / slash** | ✓ | init order, the command list (`/dr drive` wired) | be the surface (a slash line is never the surface) | `core.lua` · A10.1d |

### 3b · DUNGEON ROUTES — the consumer

| part | status | owns | must never | where / ruled |
|---|---|---|---|---|
| **ROUTE MANAGER** — the one stateful owner of an Active Route (PROPOSED by the architect, ACCEPTED by Battlewrath 2026-08-21; unbuilt) | ✗ | the offer for this map and the ONE selection · current stage · current step · the completion LEDGER · firing Next · the bucket swap · the three tracker writes (entry lure · supertrack tab · the park) · arming/disarming listeners · the stage line · the terminal state · the one saved slot (selected RID, never progress) | poll; evaluate geometry; interpret anything on the hot path; mutate the armed list mid-poll; hold two active routes; save progress | §4b · data model runtime tier (bench to shape) |
| **Contract** (the record tier, declared once) | ✓ | field order, optionality, `WORLD`, the version — the ONE file both sides cite | declare behaviour; read a store; carry a `text` type | `contract.lua` · A11.1a |
| **Import door / transport decode** | ✗ | decode → PRESENT (map · name · bosses) → "save as a route?" | use the chat box; keep the origin's RID | model rows 15–17c |
| **Bucket** (construction) | ✓ ⚠ | the run-time layout: one bucket PER STAGE, its entries that stage's rows; bucket 0 always read; the `nil→0` / `nil→2.5` conversion, per field, once, here only | fail quietly; let STAGE fail; step-gate inside stage 0; admit a `BID:CID` under stage 0; interpret an authored id on the hot path | `bucket.lua` · model rows 23–27 · ⚠ §6 G16 |
| **Rule** | ✓ | NOTHING — a pure function: sample + node → verdict | hold memory; test geometry before the mapID gate; apply the band downward; have an OPEN band | `rule.lua` · A11.2/A11.3 |
| **Sensor** | ◐ | TODAY: one in-set (`sensor.lua:120`), `Poll` returns the currently-inside snapshots (not changed, not by address, `Rule.Evaluate`'s second return discarded), `snapshot()` DROPS `rows`; the accumulator; the OnUpdate only while armed. OWED (RI-42 / D2): the PREVIOUS in-set so When on · Seen · When off are computable, and changed nodes returned by address WITH the transition word, after the poll (AI-2 audit, corrected 2026-08-21) | reach for the client itself (samples arrive through a seam); leave a handler set on disarm; divide the schedule by a measured speed | `sensor.lua` · A11.4 |
| **Driver** (the pipeline) | ◐ | `state = {bucket, stage, step, mapID, rid}`; Start/Stop; Designate (built, uncalled) | swallow a bucket's refusal; mutate the armed list mid-poll; resolve a doc/code disagreement in code | `driver.lua` · model row 26 |
| ~~Designator / raiser~~ → folded INTO the Route Manager (the designator is the manager; the raiser is its ledger firing Next) | — | — | — | RI-38 · §4b |
| **Action binder** | ✗ | the callable behind each action word, resolved at bucket time | interpret anything authored on the hot path | model row 25 · `Bucket.Resolve` |
| **CLEU listener / boss function** | ✗ | `listen(UNIT_DIED, name)` — the name is the arg | have an unfiltered form; be armed while the sense does not hold | A3.3 · A3.5 |
| **Completion ledger** (V2) | ✗ | all-tabs-complete per node; a wipe leaves tab 1 done, tab 2 re-arming — OWNED BY THE ROUTE MANAGER (2026-08-21; earlier "the sensor's" is superseded — the sensor keeps in-sets, the manager keeps completion) | be "the caller's"; be the sensor's | A2.7 · A11.3 · §4b |
| **Tracker escapement** | ✗ | the arrow always has a defined target: a tab's, or the PARK (horizontal, same map) | hold a spent target; hold nothing; contest (the next marker overwrites) | A11.9 |
| **Readout** | ✗ (only the IN half exists, by node table — no first-hit, no address (AI-2 audit, corrected 2026-08-21)) | per sample the IN set by address; per target its first hit | report `stage` as a result; report by index; claim `skip` at V1 | A11.5 |
| **Personal-note slot** (reader side) | ✗ | a designated slot beside the route note | travel; win over the route | RI-10 |

### 3c · Neither product

| part | owns | where |
|---|---|---|
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

     0  OFFER     map known → routes for THIS MapID offered → the human picks ONE (one active route at a time)
     1  BUILD     the manager reads the saved route WHOLE once → Bucket.Build → one bucket per stage + bucket 0,
                  every id resolved, every action word BOUND to its callable; refuse LOUDLY, or this is the Active Route
     2  ARM       currentStage = lowest positive stage; currentStep = its lowest positive ordinal;
                  Sensor.Arm(that bucket + bucket 0); the manager writes the stage's ENTRY LURE to the tracker
     3  PASS      the sensor polls (its throttle, its rule) and returns — AFTER the poll — the nodes that changed,
                  by address, with the transition word: When on · Seen · When off
     4  DISPATCH  for each returned node the manager runs the tabs whose sense-word matches: note → show ·
                  supertrack → write the arrow · say → chat (the AUTHOR's channel to the party — the only thing that ever reaches chat; the manager itself never emits there, §4c 6) · boss → arm the CLEU listener for that name
                  (disarmed on When off). Each tab is self-completing; Trigger says once or every time
     5  COMPLETE  the LEDGER (the manager's): a tab completes when its action finishes; a node completes when ALL
                  its tabs have → its NEXT fires: Step → currentStep = next positive ordinal · Stage → the NEXT STAGE PRESENT in the route (⚠ not +1: an exposed gap — stages 1,2,5 — is legal under L3, and +1 would arm a stage that resolves to bucket 0 alone and STALL the run; (AI-2 audit, corrected 2026-08-21), architect's correction, Battlewrath may overturn) ·
                  Set(N) → N. A stage completes when TOLD (Stage / Set) or when the ordinal RUNS DRY
     6  ADVANCE   after the poll returns: disarm the old stage's listeners · Sensor.Arm(new bucket + bucket 0) ·
                  write the new stage's entry lure · one short line to the reader
     7  RECOVER   bucket 0 is armed on every pass by construction; a stage-0 beacon's Next = Set(N) → step 6 from
                  wherever the reader is. No special path
     8  END       the last stage completes, or the human stops → terminal: disarm everything, tracker to the PARK,
                  the route stays SELECTED but not armed
     9  RELOAD    ONE saved slot — the selected RID or none — overwritten, never appended (nothing sprawls).
                  Progress is never saved (the cursor is the sensor's); after a reload the route is selected, not
                  armed; arming again lands the reader by recovery (7) WHERE the route carries a stage-0 beacon, else at the first stage present (AI-2 audit, corrected 2026-08-21). Zero garbage by construction (R5's concern)

    The INSTRUCTION SET is the manager's TICK LIST (Battlewrath): built at 1 from the records, never exported.

    THE POSED TAB — what BUCKET emits per behaviour record, DEFINED (AL-17, 2026-08-21; at Battlewrath's
    direction "better is getting it defined upstream so we're not designing by flight"):

        posed tab = { address · gate · sense · fn · arg }        one per behaviour record, owned by the manifest
          address   BID:CID — identity, admitted never tested
          gate      (stage, step) COMPOSED at build from the node's characteristic record (AL-10)
          sense     one of the three sense-words — a closed set; anything else REFUSED at build by name
          fn        the CALLABLE the consuming addon registered for the action word — resolved at build
                    through the closed list the addon publishes (ROW_ACTIONS) and its own registry
                    (Manager.Bind). ★ SECURITY (Battlewrath): a route may NAME a verb from that closed
                    list; it may never supply, select or influence what the verb does. The resolver
                    binds only words already on the list — it is consulted AFTER the closed-vocabulary
                    check, never instead of it (the bypass the bench found is closed by definition)
          arg       a VALUE, not a reference — typed per action by the declaration the action carries
                    (ROW_ARG): boss → a string name · note → a NoteID · say → a string · supertrack → none.
                    BUCKET refuses an arg that is not the declared type, naming it; the guard READS the
                    declaration, it is never a second copy of it
        NOT on the tab: Next and Trigger (the NODE's, on the characteristic record) · completion (the
        manager's ledger, never the record's) · anything resolved from a side table (display-time only)

      · the flat author fields (`child.sense / action / boss`) are the OLDER shape and are MIGRATED ONCE
        into rows by the store's migration hook, told — never converted at build. `child.rows` IS the
        instruction set; the pane moves onto it at L1.4. So L1.2/L1.4 is a MIGRATION, not a build.
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

The **runtime** is a pure rule plus a stateful sensor, orchestrated by the manager.

### 4d · THE AUTHORING SURFACE — derived from the record and the authoring need, not from today's pane (AL-14)

Battlewrath's frame: *what we have today · what we store as functions · what we need to surface to the
author — "a pass to answer the last two, to get to the first."* The record (`contract.lua`) and the
model give the surface; today's 37 controls do not.

    PER NODE (beacon or child), in the three layers the model names — one universal pane, fold in / out:
      IDENTITY      the address (shown, never edited) · the NAME (a side-table value, never on a record)
      CHARACTER     STAGE picker (beacon; +1 or swap) · STEP picker (child; +1 decimal or swap) · a tick
                    for "none" (tray 0) · PLACE — on the MAP, never here · REACH · BAND (up only) ·
                    NEXT (Next step · Next stage · Set stage N — the offer follows what exists) ·
                    TRIGGER (One time · Every time — owed its control, code term the bench's) · alias /
                    appearance (the roster's)
      BEHAVIOUR     ACTION TABS, added by choice — "Action 1 · add action · Action 2" — each one row:
                    SENSE-WORD (When on · Seen · When off) · ACTION (boss · note · supertrack · say ·
                    open list) · ARG (an ID: the boss name picked from the run · the NoteID · …)
                    ★ every field an author can set here is a record field or a side-table value;
                    a control with no record field does not belong on the surface (AI-4's 14)

    NINE fields to author today + ONE owed control + position on the map. That is the whole surface.

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
                ⚠ Not expressed in code today: no way for a route item to say "supertracker or not" —
                the entry lure is the stage slot's by construction; tray 0 is exempt by construction.
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

    L1  EMIT, DON'T INTERPRET — capture holds what happened, never what it meant; capture is the only
        spawn; everything downstream inherits, nothing derives                         capture.lua · use-case §6
    L2  NEVER INVENT a position, a height, a boss name — from reads and the run's record only; the
        sample OFFERS, the author DECIDES                                              use-case §3, §6
    L3  TELL, NEVER LOCK — collisions told inline; expose a gap, never renumber or warn; refusals name
        what was missing; pass-through shows the code word                            A10.4 · RI-23 · A5.1
    L4  THE FLAT LIST, NEVER THE CORPUS OR THE STORE — the driver is installable without the editor,
        PROVEN by an isolated load                                                    routes.lua:509 · A11.6a
    L5  THE EXPORT IS A PROJECTION — identifiers and numbers; tables where they keep the line light;
        composing where that is the correct solution; editor-side, one pass, versioned    data model rows 5–17
    L6  ONE AUTHOR, MANY READERS — every reader's driver is its own sensor; nothing pushed; progress
        never travels                                                                 use-case §2
    L7  THE GATE IS AN INDEX AT LOAD — bounce on the prefix first; 0 = always eligible; bucket may fail
        loudly, stage may not                                                         data model rows 4a, 10, 23–27
    L8  ONE PASS PER SAMPLE, ONE EVALUATION PER NODE — advance swaps buckets after a poll, never
        inside one; nothing authored is interpreted on the hot path                   rows 19–26
    L9  A PURE RULE, A STATEFUL SENSOR — the rule holds nothing; the sensor is inside the driver and
        owns the cursor; nothing armed, nothing running                               A11.3 · A11.4
    L10 SENSE = LOCATION + BEHAVIOUR IN R; boss is an action word; a tab is self-completing; Next is
        the node's and is one field; all tabs must satisfy; told-or-dry                 RI-15/17 · A2.7–A2.9
    L11 IDENTITY IS THE ADDRESS; stage and ordinal are properties; only the RID re-mints; no update path  RI-4/6 · A8.4
    L12 THE TRACKER ALWAYS HAS A TARGET, never a spent one — the PARK; the next marker overwrites     A11.9
    L13 THE LOWER-NUMBERED GOVERNING DOC WINS; a disagreement is REPORTED, never resolved by the
        builder; "ruled" = his best working model, dated                               DRIVER_BASIS one rule
    L14 A BRIEF CITES THE MODEL, NEVER RESTATES IT; a record carries the NAME, the driver owns the FUNCTION  basis · row 4a
    L16 THE HOT PATH IS SENSOR → ACTION; A STAGE OR STEP CHANGE HAS TRAVEL TIME ON EITHER SIDE — so the
        swap is a REBUILD BY EVICTION (the field's shape, prior art §5) and is never optimised; care and
        budget go to the sensor → action patch. "We reference what is proven; we don't invent a handling
        where it buys us little." (Battlewrath, 2026-08-21)                       home: §4b · A11.4 · the manager's acceptance
    L15 THE MAPID IS THE HIGHEST IDENTITY OF LOCATION — the tracker and the gate care for nothing finer; a zone
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
- **G6 CLOSED BY DESIGN, OPEN IN BUILD** (AI-2 audit, corrected 2026-08-21): R7 → cannot be authored once the pickers land (A10.3e ✗) and the bucket refuses a duplicate at load (AL-8 — OWED, D3: fourteen named refusals today, none for this). Sequenced BEFORE the manager (F2, architect's call). Was: **Two beacons at one stage.** Measured to share one step cursor (RI-41).
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
- **G16 ⚠ LIVE DISAGREEMENT: bucket shape.** The model (uncommitted) now rules ONE level — the bucket is the stage, entries are bare rows, `step` a field never a key; `bucket.lua` and the sensor brief still describe `[stage][step]`. The record moved ahead of the code; reported, not resolved.
- **G17 The action binder's shape** — row 25 wants a callable per action word; the runtime holds none; `Bucket.Resolve` is a hook asserted nil.
- **G18 CLOSED BY DESIGN, OPEN IN BUILD** (AI-2 audit, corrected 2026-08-21): the sensor keeps the previous in-set and returns the transition word (AL-2 / RI-42) — ZERO code behind it today (D2); until it lands the sense vocabulary is unimplementable from what the sensor keeps. Was: The sense words are transitions, and the sensor keeps no previous verdict — `Poll` overwrites the in-set; `Seen`/`When off` cannot be computed from what is kept.
- ~~G19a~~ CLOSED → re-arm IS the bucket swap after the poll (§4b 6). **G19b OPEN** (AI-2 audit, corrected 2026-08-21): the in-set's semantics once armed ≠ eligible (the two-set split — `sensor.lua`'s header still calls it owed; sensor brief G5). ★ RULE, from this fault: a multi-part gap is struck only when EVERY part has its citation. Was: Re-arm on a stage advance; the in-set's semantics once armed ≠ eligible — "may not be needed at all, but nothing has said so."
- **G20 `ARRIVAL_HOLD = 1.00 s`** — in the asklist's constant block, not in the code; decided by nobody.
- ~~G21~~ CLOSED → the sensor's, in `sensor.lua`; COA_Landmarks is prior art only. Was: Throttle ownership — the constants live in `sensor.lua`; the basis points at COA_Landmarks, a different mechanism. Whether they are one thing.
- **G22 Transfer corruption has no detector** — a newline-translating round trip parses into a WRONG route rather than failing; whether it earns a byte is undecided.
- **G23 The coordinate bound's rejection half** — a value that decodes cleanly and is still out of range. Battlewrath's.

**Producer**
- **G24 The action TABS do not exist at the author's end.** Export, driver and model are specified against N rows per node; the shipped pane writes one. The biggest unbuilt step on the producer side and the one every consumer test assumes.
- **G25 The side tables' exact key forms and placement; what provenance survives an import** (blocked until export's travel half exists).
- ~~G26~~ CLOSED → the word is RETIRED (R11): ingest → bucket → arm. Was: Pre-load — Battlewrath's term, nowhere on disk; retired as a label (BUCKET/STAGE) but never answered as a question.

---

## 7 · HOW THIS DOCUMENT IS USED

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
