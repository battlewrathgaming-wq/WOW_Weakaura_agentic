# Dungeon Run — AUTHORING acceptance (item 1 + item 2's first proof + the adaptor)

_Analyst, 2026-08-17, on the bench's proposition (`history/driver_bench_proposition.md`). Target §9 said
"the editor's own criteria (not yet written) gate Dungeon Run" — these are they, for the docket's
items 1–3. Written BEFORE the code, from the proposition's smoke plan (§8) and the model, so the
smoke is written to the criterion. **Every assertion must be shown to BITE** (mutation named per
row); a green that has not been mutated is not evidence. The Analyst tests each on landing._

Where R1/R2/R3 are unruled, the criterion is written to hold either way.

---

## A1 · G2 — reach on a childless beacon
- ★ **A1.1 LANDED §349** — pure accessor; a beacon's own reach is readable while a flagged
  child's still answers the acceptance question at the call site. 6 mutations bite; the
  MASKING mutation retired rather than reworded.
- **A1.1 (MOVED 2026-08-18, on the bench's T13 — accepted):** `Routes.SetBeaconReach(b, radius,
  up, down)` stores; **`Routes.ReachOf(x)` is a PURE ACCESSOR of x's OWN fields** (R5: a
  `<Noun>Of` reads its noun). The acceptance question composes at the call site —
  `ReachOf(AcceptanceOf(b))`. Why it moved: as first written, a beacon's own reach was stored,
  DISPLAYED, and masked by a flagged child's — "the author types 99, the box shows 99, the
  resolver returns the child's 8" — and two steps on one position have two OWNERS (`BID`,
  `BID:CID`), both of which must be readable or the flatten cannot emit the beacon's step and
  the route cannot be shared. Additive; no existing signature changes.
      grades  Routes.ReachOf
- **A1.2** A childless beacon is RUNNABLE: `AcceptanceOf(b)` returns the beacon AND
  `ReachOf(AcceptanceOf(b))` returns a reach for it — unaffected by the A1.1 move (for a
  childless beacon `AcceptanceOf(b) == b`). `/dr walk`'s unrunnable-stages report no longer
  lists a childless beacon that has a radius.
- ★ **A1.2 TIGHTENED §348.** The criterion's COMPOSED form is now the one asserted, and
  *"unaffected by the A1.1 move"* is a swept invariant rather than prose: `ReachOf(x)`
  and `ReachOf(AcceptanceOf(x))` are asserted EQUAL across all four fixture shapes. While
  they agree, A1.1 is a branch removal; the day they do not, it is a behaviour change.
      grades  Routes.AcceptanceOf · Routes.ReachOf
- **A1.3 (RI-2 DRAINED 2026-08-18 — the SPLIT):** Height untouched: the beacon's `z` is still the
  read's (`routes.lua:29-31`); band is a tolerance over it. **`ReachOf` is the RAW read — `nil`
  means the author set nothing; the CONSUMER resolves ±2.5 when nil** (R6's raw/resolved, as
  `OutcomeOf`/`Outcome` already do). Nothing shipped changes; P1 stands. Pane: a slider the
  author TICKS to change, with light text ("changes the height of detection"); the same control
  shape for radius:listen and radius:sense. Test: unset → `ReachOf` nil AND the resolved band
  reads 2.5; typed 2.5 → `ReachOf` 2.5 (distinguishable from unset at the read).
- **A1.4 (RI-14 drained 2026-08-18) — the composition lives ONCE, at the CALL LAYER.** The
  acceptance-then-reach question (`ReachOf(AcceptanceOf(b))`) is composed in one helper OUTSIDE
  `routes.lua` (consumer/pane side), which every call site uses and the smoke sweeps (A1.2's
  invariant: nil acceptance reads nil, never falls through to the beacon). `routes.lua` keeps
  the headstone comment and NO composer — a composer there would be the resolving branch
  renamed. No source-text scanner for the `AcceptanceOf( … or` spelling; the sweep is the
  guard. mutation: write `AcceptanceOf(b) or b` at the helper → the nil-acceptance sweep bites.
- **mutation** delete the beacon's own-field read in `ReachOf` → A1.2 fails on its own message
  (childless case); the child case still passes; **the old "child's reach must WIN over the
  beacon's" mutation is RETIRED** — it asserted the masking as correct.

## A2 · the child ordinal (`4.1:3`, `4.1:3.1`)
- **A2.1** A stored, sparse ordinal on the child; `ChildrenOf(b)` returns children in ordinal
  order; inserting `3.1` renumbers NOTHING (every other ordinal byte-identical before/after).
- **A2.2** `4.1:3` resolves to exactly one child; `4.1:3.1` to another; the full path is unique
  route-wide.
      grades  Routes.ChildAt · Routes.PathOf
- ~~**A2.3** Two children on one ordinal is TOLD (pane + `/dr walk` report), never refused (S4).~~
  **SUPERSEDED by A2.10 (R7, 2026-08-21): two children on one ordinal CANNOT BE AUTHORED — the
  picker swaps. The tell survives only for ROUTES IMPORTED from before the slot (told at load).**
- **A2.10 (R7 — SLOTS, Battlewrath 2026-08-21)** A route is a tray: stage slots 1..N hold ONE beacon
  each (0 = the open tray, any number); step slots 1..M under a beacon hold ONE child each. The
  picker offers what is CURRENT plus **+1** (next whole for a beacon, next decimal for a child), or
  **select a current occupant → the two SWAP**. No other act: no shift, no renumber, no arbitrary
  empty position; a delete leaves an exposed gap. Test: beacon at 1, pick +1 → 2; pick occupied 2 →
  beacons 1 and 2 exchange, both told; child under 2 picks +1 → 2.1; no state exists with two
  occupants on one slot (`Routes.OrdinalMatches` / the stage set assert ZERO duplicates after any
  act). Mutation: allow a second occupant → the zero-duplicates assert fails; shift on insert →
  RI-23's never-renumber assert fails; offer an empty position beyond +1 → the picker test fails.
  **Runtime side (AL-8, 2026-08-21): the BUCKET refuses a duplicate stage at load with a named
  reason ("two beacons at stage N — re-slot in the editor") — so the Route Manager never meets one
  whether or not the pickers have landed; routes from before the slot meet the same refusal.**
  Mutation: feed a store with two beacons at one stage → `Bucket.Build` returns nil + that reason.
      grades  Routes.OrdinalMatches
- **A2.4** The parent's management surface and the child's own pane write the SAME field (one
  home, two doors — model §1). _Proof lives in `smoke_dungeonrunpromoter.lua`, not the routes
  smoke — deliberate and accepted: the claim is that two SURFACES agree, and the routes smoke has
  no pane. The routes smoke carries a pointer._
- **A2.5 (RI-5 drained 2026-08-18) — the first child acts as the beacon, and it round-trips.**
  When a beacon gains children, its lure + note (the tabs it held) move to child 1; STAGE
  COMPLETE (`set:` / `advance`) is SHED — an any-child choice the author places; the parent
  holds it only by default when childless. Child 1 is the LAST DELETE: with siblings present it
  cannot be removed (TOLD, S4); removed as the last child, its tabs RETURN to the parent, which
  is childless again and behaves as its own single child. Position is the node's (map), never
  on the behaviour pane. **THE ENTRY ORDER (Battlewrath, 2026-08-18; replaces `onRamp` — RI-8):**
  childless → the beacon; with children → the FIRST CHILD (first created) is the entry — lure
  and note; then whatever the author laid out fires — ordinal 1 when sensed, and/or a satellite
  if it triggers first; the author chooses by making a child a step or a satellite. No flag, no
  further precedence.
      grades  Routes.DeleteChild
- **A2.6 (2026-08-18) — STEPS replace `goTo`.** An ordinal child is a STEP: the same object as
  a childless beacon — default lure (come here / arrow / note), sense reach-here, what-I-do
  advance to the next step; it points at ITSELF; order is the ordinal alone. `goTo` and its
  checks (`Heads / BrokenLinks / Cycles`) are RETIRED: removed absolutely, not parked (a half-
  formed path invites building on it); any stored `goTo` on an existing route is TOLD at load
  and dropped, never silently honoured. Satellites unchanged. Test: a beacon with steps 1..3 —
  the arrow points at step 1; satisfying it → step 2 listens and the arrow moves to step 2
  (its own lure), and so on; step 3's advance completes the beacon unless completion was
  placed elsewhere.
      grades  Routes.DropRetired
- **A2.7 (Battlewrath, 2026-08-18) — a step COMPLETES when ALL its action tabs have completed;
  this is a CONSTANT, not a control.** No all/any on a child (RI-5: the selector, if it survives,
  is the childless beacon's only). Battlewrath's case: child 1 with tab 1 *give the note*
  (immediately) and tab 2 *on boss killed → set stage*: stepping on fires the note and completes
  TAB 1 — the CHILD is not complete; the ordinal does NOT hand off; tab 2 stays armed while the
  sense holds (A3.5); the kill completes tab 2 → the child, and the stage end does the rest. A
  wipe: tab 1 stays done (Trigger: One time — the IF SEEN control's label, 2026-08-18), tab 2
  re-arms on re-entry. **Confirmed (same day, then
  refined): the NODE's constant on completion is the STEP only — set / ratchet the ordinal.
  The constant lives in the child's CHARACTER (mutable: the ORDINAL input) — not in its IDENTITY
  (intrinsic: the id) and not as a WHAT I DO row (BEHAVIOUR: the actions together).
  ~~Stage changes are never the node's constant; they are AUTHORED on a tab~~ [→ NEXT (Battlewrath, 2026-08-18): a stage change is NOT a tab — it is the node's characteristic NEXT, fired when all tabs are good] — see A2.9. "Two tabs means both must satisfy."** ~~PRECEDENCE … WINS over the child's own
  step ratchet~~ [DISSOLVED by A2.9: Next is ONE field; nothing races]. Test: after the note fires
  and before the kill, `ChildrenOf` still reports child 1 current and step 2 not listening.
- **A2.9 (Battlewrath, 2026-08-18) — NEXT: a stage change is NOT a tab; it is the node's
  CHARACTERISTIC, fired when all tabs are good.** Tabs have no sequence — every tab fires on its
  sense — so `When on:set stage 2` beside `When on:boss:Bob` would move the stage on ARRIVAL,
  mid-fight. Therefore `set` / `ratchet` are NOT action words. The node carries **NEXT — what I do
  when my tabs are complete: Step (default, the constant) · Stage · Set(N)** — one field, one
  value; a boss node's Next defaults to Set(this beacon's next) (recovery, from the node's OWN
  stage). **The OFFER depends on what is next (Battlewrath, same day): a child WITH a greater
  ordinal offers Step (default) · Stage · Set(N); a child with NO greater ordinal (the last step)
  offers Stage (default) · Set(N) — there is no next step to offer; a CHILDLESS beacon offers
  Stage (default) · Set(N).** This is A2.8's "ordinal runs dry" made concrete: the last step's Next
  = Stage completes the stage; its word can stay **Complete** ("move to me, then it moves on";
  "Reached" the alternative — Battlewrath, same day). Test: the last step's dropdown has no "Next step"; adding a step
  after it re-offers Step. Test: child with tabs [boss:Bob · note] and Next=Set(2): arrival fires the note, the
  stage does NOT move; the kill completes the boss tab → all good → Next fires → stage 2. Driver
  at stage 1, boss node at stage 5 with Next=Set(6) → lands on 6, not 2. Mutations: offer `set`
  as an action word → fails; fire Next with one tab still open → fails; make the default relative
  to the driver's stage → the 1/5 test lands on 2 and fails.
- **A2.8 (Battlewrath, 2026-08-18) — the STAGE never waits for all its children.** Five children,
  two with no ordinal (update type), three in the ordinal: the stage completes when it is TOLD
  (a node's NEXT = Stage / Set(N) fires — A2.9) OR when the
  ORDINAL RUNS DRY (the last step completes → the beacon's completion default). Update-type
  children never gate completion; an unfired step is only a gate while a later step has not
  been reached (the ratchet, S6). Test: three steps done, two satellites never fired → the stage
  completes; a stage action on step 2 → completes there, steps 3 and the satellites moot.
  Mutation: make completion count all five → A2.8 fails. **The childless beacon is the LIMIT case
  of the same rule (Battlewrath): an ordinal of zero runs dry at the beacon's own completion —
  its self-complete IS "told or dry" with nothing to wait for. One rule, both shapes.**
- **mutation** make insertion renumber → A2.1's stability assert fails; give two children one
  ordinal → A2.3 shows the tell and nothing errors; delete child 1 with siblings present →
  A2.5 must TELL and not remove; delete it as the last child → the parent regains its tabs
  and the completion default; leave a `goTo` code path callable → A2.6's grep must find it
  (retired means gone); feed a route carrying `goTo` → told and dropped, not honoured.

## A3 · G10 — the boss CONDITION + name picker
_**RI-15 DRAINED (Battlewrath, 2026-08-18): boss is NOT a sense.** SENSE is the LOCATION and the
behaviour whilst in its R (on me · touched me) [⚠ SCRUBBED (RI-17, 2026-08-18): not "here · falling · in combat" —
state predicates are GATES, not senses]; the boss pair is ~~the CONDITION on a WHAT I DO row~~ the
ACTION word `boss` on a WHAT I DO row (RI-17: `When on:boss:⟨name⟩`), and the row's stack is scoped
by the sense being on. **The rows below keep their VALUES, their picker rule and their no-refusal
law; the FIELD moves** from the child's `sense` to the row (one declaration; identifier the
bench's). Where a row says "sense" of the boss pair read "the row's action word + arg". One criterion added: **A3.5** the listener is armed only WHILE the child's sense
holds — a named kill while the player is not here advances nothing; re-entry re-arms. Test: emit a
kill with the sense off → no advance; sense on → advance. Stored routes carrying the boss pair in
`sense` are MIGRATED by the schema hook (A8.4's `Store.fromSchema`), told and never silently
dropped._
- **A3.1 (WORDING MOVED 2026-08-18):** the axis is **`sense`**, not `kind` — `kind` is the
  structural discriminator (beacon / child / note) and `SetName`/`NameOf` branch on it (the
  empty smoke caught a `kind="boss"` falling onto the beacon-naming path before a line of the
  feature existed); B1 closed on `sense` from the model's own defaults table. Substance
  unchanged and shipped: a child `sense` with `bossEngaged` / `bossKilled` [⚠ SUPERSEDED (RI-15 settled, 2026-08-18): the FIELD
  is the what-I-do row's CONDITION, value `bossKilled` + the picked name; `bossEngaged` is not an
  authorable value; stored `sense` boss values migrate via A8.4's hook]; its picker is fed
  ONLY from the run's `r.bosses` (`store.lua:364`), folded to the distinct set; the author
  cannot type a name; the setter refuses anything not on the offer.
- **A3.2 (settled 2026-08-18; RI-17 grammar)** The boss row IS the declaration `When on:boss:⟨name⟩`
  — sense-word · the BOSS action function · the name picked (model §2, RI-15/17); stored WHOLE as
  one triple, exported whole, read whole; no separate condition field ~~ONE condition offered on a
  WHAT I DO row: *on boss killed ⟨name⟩*~~ (the function carries its own condition — the kill). *Engaged* is NOT offered — a driver-side arming witness at
  most (§2c). No boss entry in the SENSE list. ~~**A kill row DEFAULTS to a stage action, absolute
  — set stage to this beacon's NEXT from the node's OWN stage (recovery); advance +N beside it.**~~
  [→ NEXT (Battlewrath, 2026-08-18): a stage change is NOT a tab — it is the node's characteristic NEXT, fired when all tabs are good] — the boss TAB completes on the kill; the boss NODE's Next defaults to Set(this beacon's
  next), A2.9. Test moved to A2.9 (driver at 1, node at 5 → 6, not 2). A row = ONE
  declaration `<sense>:<action>:<arg>` (RI-17); rows never satisfy rows. Mutation: store the
  triple as two fields → the whole-read assert fails; export a row missing its arg → told, not
  exported (A3.3's law: `When on:boss:` with no name arms nothing).
      grades  Routes.SetRow · Routes.RowsOf
- **A3.3** NO refusal needed (Battlewrath, 2026-08-17): the driver's arming call takes the name
  as its argument — `listen(UNIT_DIED, name)` — so a boss child with NO name has nothing to pass
  and NOTHING ARMS. The unfiltered listener cannot be expressed because the arming function has
  no unfiltered form (same law as position: fixed mechanism, instruction supplies the parameter;
  WA's firehose guard by construction). Editor TELLS ("no name — it will not listen"); `/dr walk`
  marks the stage unrunnable; S4 tell-and-trust intact. Test: a nameless boss child arms nothing
  and is told; a named one arms exactly one dest-name listener.
      grades  Routes.ArmsWith · Routes.RowIncomplete
- **A3.4** Nothing about a set, a count, or a grouping is stored or shown (capture.lua:234 bound).
      grades  Routes.SetChildBoss · Store.BossNames
- **mutation** emit a nameless boss child → nothing arms and the tell shows (A3.3); offer a typed
  name → A3.1 rejects the path; arm a named one → exactly one listener, for that dest name.
  A3.5: kill with the sense OFF → nothing advances; put a boss value back in the SENSE list →
  A3.2 fails. Offer `engaged` on the pane → A3.2 fails. Make the kill default RELATIVE (driver's
  stage +1) → the stage-1/stage-5 test lands on 2 and fails.

## A4 · G1 — the reader note (R1 ANSWERED by RI-1, 2026-08-18: referenced, route note plane)
- **A4.1** A note resolves to EXACTLY ONE string for a child at runtime, ≤ ~200 chars (target §4).
- **A4.2 (RI-1 + RI-10 DRAINED 2026-08-18):** referenced in the STORE, owned in the PANE — and the
  store is **the ROUTE NOTE PLANE, its own table under the personal one** (§60's phrase; NOT
  `Store.NoteTable`, which is the PERSONAL plane and never travels — my earlier wording named
  the wrong shelf). ~~Keyed by the child's address (`RID:BID:CID`)~~ **RI-18 Q6 DRAINED (Battlewrath,
  2026-08-19): the route plane stores `NoteID → content`; the child's row carries the NoteID as an
  ID POINTER — "in-line is an ID pointer; the free-hand text is derived from a lookup table; that
  keeps the instruction line predictable and repeatable." Sharing = two rows on one NoteID (RI-1's
  "later re-point", free). Stored routes keyed by address MIGRATE through A8.4's hook, told.**
  The pane shows a note field on
  the child LABELLED **"Route instructions"** (one adaptor row: term `route note` → label
  "Route instructions"; "Personal note" for the other kind) with ghost text "Instructions for
  the player running the route"; saving creates/updates the route-
  plane entry for that child; re-pointing to share one note across children is a later action.
  Export takes the route plane WHOLE and never the personal one — structural, no tag to check.
  §91's reasoning survives; the author never meets a note object. **G1 LANDED (§346).**
  Test: two children with independently typed notes → two NoteIDs, two entries; edit one → only
  one changes; two children on ONE NoteID, edit once → BOTH read the new string — the test that
  tells the REFERENCED world from the owned one (the A4 mutation below is now answered: referenced). _**Status (RI-12 drained): CLOSED EXCEPT THE TRAVEL HALF** — export does not
  exist yet, so "route notes travel, personal notes do not" is guarded STRUCTURALLY today
  (`Store.RouteNoteTable() ~= Store.NoteTable()`, two tables) and the behavioural assert
  (mutation: route the export through the personal plane → the travel assert must fail) is
  OWED to A8.5's round-trip test when export lands. The roster counts A4.2 as partial._
      grades  Routes.SetRouteNote · Routes.RouteNoteOf · Store.RouteNoteTable
- **A4.3** The note is a CHOICE option: a child with no note has none, and nothing renders.
- ★ **A4.1–A4.3 CLOSED §346.** ⚠ Except the export half of A4.2's test, which has no
  surface to run against — export does not exist. The two-table STRUCTURE is asserted in
  its place (`Store.RouteNoteTable() ~= Store.NoteTable()`), and that is the thing RI-10
  ruled would make the travel rule hold without a filter. **The travel assert is OWED.**
- **mutation** two children pointing at one referenced note, edit once → both read the new
  string (referenced) / only one changes (owned) — the test names which world it is in.
  **ANSWERED 2026-08-19: REFERENCED (NoteID).** Mutation now: key the note by address again → the
  shared-NoteID test shows two strings and fails; put note TEXT on the line → A11.1c reds.

## A5 · the adaptor (`code : user`)
- **A5.1** Panes render user words through ONE lookup function; a miss PASSES THROUGH the code
  term (§295). **Pass-through is NOT a silent failure (Battlewrath, 2026-08-18):** the term at
  the question:answer layer is SHOWN under its code name when the adaptor has not resolved it —
  a version mismatch, for example — so what the instruction was calling for is still EXPRESSED
  to the author. The pane degrades to legible, never to blank; the checker (A5.3) is what makes
  the miss loud at the bench. Test: remove a row → the pane shows the code name; the checker
  reports the row.
- **A5.2** Every value in `ROLES / SHAPES / ACTIONS` (and every new kind/sense/next as it lands)
  resolves or passes through — the pane never errors on a missing row.
      grades  Adaptor.Word · Adaptor.Has
- **A5.3** `check_interface.py` gains a third check: every user-visible string in a pane
  resolves through the table; every code term reaching a pane has a row. Loud at the bench,
  silent for the author.
- **A5.4** Rows are filed AS TERMS LAND (§9): a term reaches a pane → it gets a row or is filed
  under an existing one; `emit_adaptor_table.py` is a drift check on the confirmed state, run
  AFTER, never a term planner.
- **A5.5** The user column reads against the naming law (model §3b) — one column, human-read.
- **mutation** remove a row → the pane still renders (pass-through) AND the checker reports it.

## A6 · item 2's first proof — a stage advance on JUST a boss kill
- **A6.1 (RI-3 DRAINED 2026-08-18):** home = **TEST DRIVE — its own suite entry INSIDE Dungeon Run**
  (the author in the world hitting their waypoints), built as an extension of `editor.lua`'s
  play pacer; NOT a mode of `/dr walk` (removed §112, not revived). The offline replay / py walk /
  per-node fitment is the ASSURANCE side and lives in the test/debug/diagnostic suite (the
  W-tests). Against a landed capture carrying boss names + engage timestamps + `UNIT_DIED`: a
  boss child's what-I-do row (condition: *on boss ⟨name⟩ killed*) satisfies WHILE THE SENSE
  HOLDS (A3.5) → the boss tab completes → the node's Next fires (default Set(this beacon's next), A2.9) → the
  stage moves. No new capture. [⚠ SUPERSEDED (RI-15 settled, 2026-08-18) — was: "*boss killed* sense → the beacon's next".]
- **A6.2 (⚠ SUPERSEDED (RI-15 settled, 2026-08-18))** ~~The two witnesses both required: engage seen for that name AND `UNIT_DIED`~~
  — the arming witness is the PLAYER'S SENSE holding (A3.5); the kill alone satisfies. Engage is
  at most a driver-side arm (model §2c), never a required author witness. Test: kill with the
  sense on and NO engage token seen → advances; kill with the sense off → does not.
- **A6.3** The pin trace (C-4) is recorded per set/arrive/clear before "point here" is replayed;
  until then A6.1 grades the ADVANCE, not the pointing.
- **A6.4** Readout carries `hit · skip · false_advances`, never `stage` alone (W7.3).
- **mutation** emit the kill with the sense OFF → A6.2 must NOT advance (was: drop the engage
  witness — retired with it); feed a name not in the run → nothing arms.

## A7 · smoke hygiene
- **A7.1** `smoke_dungeonrunroutes.lua` stands up EMPTY on the existing load chain BEFORE any
  hole lands (proposition §10 step 2), so every assertion has somewhere to go.
- **A7.2** Each A-row's mutation is recorded next to its green — a green without its mutation
  is reported as UNMUTATED, not as PASS.

## A8 · new rows from the bench's §19c (things built or ruled with no criterion) — 2026-08-18
- **A8.1 `Routes.StageOf(node)`** — the model asks for it by name: a beacon's own stage; a
  child's parent's stage; one predicate, computed, never stale. Does not exist. Four lines in
  the house shape (`<Noun>Of`). mutation: give a child its own stale `stage` field → `StageOf`
  must still return the parent's.
      grades  Routes.StageOf
- **A8.2 no setter without a door** — `SetChildIcon` / `IconOf` exist and nothing calls them.
  Either a door lands or the pair is removed; a setter with no caller reads as finished to the
  next reader. (Same law as `fireOn`, E4 G6.) Test: grep — every `Set*` in `routes.lua` has a
  caller in `object.lua`/`promoter.lua`, or is listed as intentionally door-less with a why.
- **A8.3 the addressed store (§17)** — DESIGNED, NOT BUILT: `At / AddressOf / GetAt / SetAt`,
  `SetAt` dispatching to the owning setter. **Graded BEFORE it is built (bench asked; agreed):**
  criteria — `AddressOf` is total over beacons and children and unique route-wide; `SetAt`
  never pokes a field (mutation: make it write directly → the owning setter's guard must be
  the thing that bites); `GetAt(AddressOf(x)) == x`.
- **A8.4 the address `RID:BID:CID`** — RULED as the shape; **LIVE DEFECT**: `composeId(name, n)`
  bakes the route NAME into the key, `Rename` does not touch it, and a colon in a route name
  makes the address unparseable. Criterion: RID is OPAQUE (not the name); a route named
  `"SFK: fast-3"` round-trips `RID:BID:CID`. This is the first migration the addon needs — write
  the migration's own criterion (old keys → opaque RID, nothing lost) before it runs.
  _(RI-6 drained 2026-08-18: the migration is RID ONLY — CIDs stay route-scoped as shipped; no
  renumbering. A driver reading two beacons on one stage degrades deterministically and STATES
  which lure wins — a told collision, never a lock.)_
      grades  Routes.MigrateRIDs · Store.NextRouteId
- **A8.5 export trims to what import will mint** — best working model (RI-4 drained 2026-08-18).
  Criterion: export carries the identity table + current XYZ + enough to re-create, and DROPS
  the origin/mint data (placement pair, id counters); **on import ONLY THE RID is re-minted —
  every `BID:CID` is preserved byte-for-byte** (unique within the RID; no waterfall); metadata
  outside identity/place (notes, radii, bands, names) survives; the import landing becomes the
  new origin. Test: `import(export(route))` → new RID, identical `BID:CID` set, identical
  properties, no duplicate mint. The ledger's round-trip law is compared against this MINT
  CONTRACT, not stored bytes; ledger §5.9–5.11 get a banner (bench).
- **A8.6 the flat form is the EXPORTED form — a PROJECTION of the store (REWORDED 2026-08-18, RI-18
  Q1; was "the flat form IS the stored form")** — Battlewrath: *"the data store on the editor isn't
  1:1 to what gets exported"*; *"we accept tables where they keep the line read light, and
  composing where that is the correct solution."* The CRITERION under it is unchanged: A8.3's +
  "panes are views, never a second copy of a value" (A2.4's shape, generalised); the export drops
  only what is DERIVABLE (Stage:Step composed) or NOT the consumer's (the capture corpus). Export is
  EDITOR-SIDE always (composing needs the live tree — proposal G11).
- **A8.7 model surface with no code — tracked, not graded:** tabs (~~each node carrying G2/G10
  fields directly is a MIGRATION when tabs land — §16d~~ [⚠ SUPERSEDED 2026-08-19: `POS · R ·
  Band` STAY on the node — #3 §A1.1 / §A5.21. No migration is owed; this row tracked a move
  that is now ruled not to happen]) · the all/any selector (childless beacon
  ONLY, if ever — never on a child, A2.7 is the constant) · `while` (G15)
  · ~~state senses~~ state GATES (`falling` needed by the skip as a row CONDITION, not a sense —
  RI-17; capture does not record it) · `scene entered`.
  Listed so the unbuilt surface is seen whole; graded when scheduled.

## A9 · the bench's own debt, as criteria (from §19e)
- **A9.1 the pane-registration audit — RED until done.** `smoke_dungeonrunpromoter` loaded
  `ui.lua` below `object.lua`, so `NS.UI.Register` was nil and every pane registration was a
  silent no-op; fixed §322. **Every pane assertion written before §322 is UNVERIFIED** until
  re-run in the fixed order and its mutation shown to bite. Criterion: a list of pre-§322 pane
  assertions, each re-run, PASS/FAIL, mutation biting. And a criterion-shaped gap:
  `check_interface` counts registrations STATICALLY (105/105) — a static count of a dynamic
  act; the check must also confirm the registration EXECUTED (a runtime roster, or the smoke
  asserting `NS.UI.Register` is live before object loads).
- **A9.2 twelve rotted mutation anchors** — ★ RE-MEASURED 2026-08-18 (§357, bench, at the
  pre-push verify): **294/306 bite.** Still exactly **twelve**, still **every one in `map`** —
  ten `?? ANCHOR found 0x` and two `~~ WRONG`, confirmed by resolving all 306 `find` strings
  against their files. The totals moved (293 → 306, 281 → 294) because the suite GREW by
  thirteen this cycle, not because anything rotted further.
  ⚠ Two anchors DID rot mid-cycle and were re-aimed rather than deleted, both broken by an
  edit of ours: `CreateFontString`'s fallback-name anchor, and `an unset field is rawget`,
  which went **`!! SILENT`** — its guard broken and the suite still passing — because the
  catch-all split (§356) made a lowercase key answer nil either way, so the mutation could no
  longer reach the fault. ★ The yield was a weak TEST, surfacing the moment the code around it
  got more correct.
  Criterion: 306/306, each anchor naming the LINE THAT DOES THE WORK, never prose.
- **A9.3 A5.3's checker — first red exists.** Three terms reach a pane with no user word:
  `ratchet` (`object.lua:197`), `on-ramp` (the answers line), `satellite` (§312's readout —
  §3b names it explicitly as a FAIL). Criterion: the third check in `check_interface.py` lands
  and reports these three; the strings are re-worded under the naming pass (S3) — `satellite`
  can be fixed NOW ("always listening" reads without the word).
- **A9.4 the roster cap of six** — TOLD when exceeded, never silent (verified). Whether it
  should scroll is a decision waiting; not a red.
- **A9.6 (RI-11, 2026-08-18; REWORDED §351 on the bench's Q4) — the offline geometry checker
  measures the pane that SHIPS.** Three sites were wrong, all now guarded: (1) the smoke's canvas
  is READ from `object.lua` at run time and asserts LOUDLY if it cannot (was a typed 240×330
  under a comment claiming "read from source" — a provenance claim that outlived its fact);
  (2) stale in-client rect captures are DELETED, never compared ("no client rects yet" until a
  fresh `/coadump r geom` — Battlewrath's run, never the bench's); (3) TEMPLATED controls take
  their template's size from the client's own XML (`read_templates.py` → staging, regenerated;
  54 in `object.lua` were measured as SIZELESS boxes before) and the frame model reports any
  template it cannot resolve. Hand-placed controls outside `panespec` (`object.sense` ·
  `object.ordinal` · `object.note`) are NAMED as unverified until the overhaul (RI-11) — never
  counted clean. Plus the TEXT-METRICS SWEEP (findings §6): run `PerformLayout` with a stubbed
  `GetStringWidth`, perturb, re-run — every rect that moves is in the blind spot BY NAME; the
  checker reports "N verified · M unverifiable" rather than a clean pane. mutations: shrink the
  canvas → red on a control now outside; remove a template from staging → the frame model must
  report it, not size to nothing; perturb the string-width stub → the moved rects appear in the
  unverifiable list.
- **A9.5 W7's golden rots while it waits** — the write-once comparator compares on every
  `walk w5` run; criterion: it is RUN on each landing (add to the smoke roster or the check),
  so rot is seen, not discovered.

---

## A2.11 · THE ORDINAL MINT AND GAP — ADVISORY, because nothing equivalent exists

_Opus 5 (Analyst), 2026-08-20. **Advisory: the SHAPE is proposed, not measured** — there is no
`NextOrdinal` and no ordinal gap function anywhere (`grep` returns nothing), so this row describes
what should exist rather than what does. ⚠ The bench owns the code term the day it lands; no
identifier is invented here beyond the two names used for discussion._

**WHY IT IS NEEDED NOW.** A10.3e makes every numeric door a selection, and the child ordinal picker
must offer *next whole · next decimal · the used set*. **The stage side already has both halves** —
`NextStage` (`:304`) and `Gaps` (`:1507`). The child side has neither, so the picker cannot be
built. `OrdinalMatches` (`:616`) counts collisions and mints nothing.

- **A2.11a** SCOPE IS THE PARENT, not the route. Ordinals are per-beacon: `OrdinalMatches` already
  walks `ChildrenAsMinted(b)` and `ChildAt` resolves `stage:ordinal` within one beacon.
  **A mint that walked the route would collide across beacons that legitimately share
  ordinal 1.**   ADVISORY. TEST: two beacons, each with a child at ordinal 1 -> the
  mint offers 2 for both, and neither sees the other.

      grades  Routes.NextOrdinal
- **A2.11b** THE MINT WALKS WHOLE NUMBERS from 1, exactly as `NextStage` does — lowest free whole
  ordinal among that beacon's children. ⚠ Children with NO ordinal (the update type,
  `child.ordinal = nil`, "out of the line, on purpose" `:566`) are SKIPPED, not counted
  as 0.   ADVISORY. TEST: children at 1, 3, and one with none -> the mint offers 2.

      grades  Routes.NextOrdinal
- **A2.11c** ⚠⚠ THE GAP FUNCTION IS NOT A MIRROR OF `Gaps`, and this is the row worth reading.
  Beacon stages are WHOLE ONLY (#3 §A3.9), so an integer gap list is complete for them.
      grades  Routes.OrdinalGaps
  **Child ordinals are the author's choice — `1.1 · 1.2` is legal** (#3 §A3.9,
  `routes.lua:559`). So "what is a gap" has to be said rather than inherited:

                ordinals 1 · 2 · 4        -> a gap at 3          (a missing WHOLE number)
                ordinals 1 · 1.5 · 2      -> NO gap              (1.5 is insertion, not a hole)

  **A gap is a missing WHOLE number between 1 and the highest whole ordinal in use.**
  Decimals are insertion and never create or fill a gap.   ADVISORY, and it is a design
  call rather than a measurement — it follows from *"then the gaps stand out"* being
  about legibility, and a decimal between two wholes is not a hole in anything.
  TEST: the two cases above, asserted by name.

    ⚠ NOT SETTLED HERE, and it does not block the mint: whether the picker's *next decimal* offer
    walks tenths or hundredths. ✓ **ANSWERED 2026-08-20: ONE decimal place** (A10.3e). The offer
    is one above the current, whole or decimal, and at `x.x` every legal value is selectable.
    ⚠⚠ **AND THE CONSEQUENCE MUST BE CARRIED, because a previous turn rejected it by name.**
    §385e refused a hard authoring wall — *"an authoring limit the author discovers by hitting
    it"* — and its answer was a builder that REBALANCES. ★ RI-23 then withdrew auto-updating
    entirely (*"we don't auto-update"*). ⟶ So `x.x` **does** put a wall at nine sub-steps per
    whole ordinal, with nothing offering to renumber. **His scope argument is what makes that
    acceptable** — ten ordered children on one beacon is not the product's case — and it is
    recorded rather than left for someone to rediscover §385e and reopen it.

## A2.12 · RETIRING `fireOn` — ADVISORY, and it follows the A2.6 pattern exactly

_Opus 5 (Analyst), 2026-08-20. Battlewrath, 2026-08-19: **"I'd say die."** The field is STRANDED —
`Routes.SetChildFireOn` (`routes.lua:1351`) has no caller in the addon, no smoke, and no interface
row — and it serves a ruling that was withdrawn (RI-5: *"there is NO firing field"*)._

**THE PRECEDENT IS ON DISK AND SHOULD BE COPIED, NOT REDESIGNED.** `Routes.DropRetired`
(`routes.lua:181`) already does this for `goTo` and `onRamp`: it runs on EVERY load, not only a
migration, *"because a `goTo` can arrive from a hand-edited SavedVariables or an import written
against an older build, and neither of those bumps a schema version."*

- **A2.12a** THE SETTER AND THE READER GO WHOLE. `SetChildFireOn` is removed, not parked — the
  standing rule that half-formed code invites building on it, and this field already
  survived one clean-out.   TEST: a grep for `fireOn` in `addons/COA_DungeonRun/`
  returns only the DropRetired drop site.

- **A2.12b** A STORED `fireOn` IS DROPPED AND TOLD, on every load, through `DropRetired` — the
  same function, the same sentence shape, one more field in its condition.
      grades  Routes.DropRetired
  TEST: plant `child.fireOn = "start"`, load -> the field is gone and the count is
  said. MUTATION: drop it silently -> the row bites on the missing message, not on
  the missing drop. ★ The message is the criterion; a silent drop is the failure
  A2.6's own text names as the worse of the two.

- **A2.12c** ⚠ THE TRAP IT WAS NOT BUILT FOR — recorded so the removal does not take the wrong
  thing with it. `fireOn` is NOT `ifUnseen` and NOT Trigger. `ifUnseen` is a separate
  field, gated on `role == "set"`, and it dies with `role` when `Next(Type,arg)` lands
  — **a different removal, in a different commit, with completion owning
  set-idempotence.** Doing them together is what made RI-27 circle.

    ⚠ ORDER: A2.12 has no dependency and can land any time. It does NOT wait on `Next`.

## A2.10 · THE STAGELESS NODE — designed ahead of the build, from measurement

⚠⚠ **AND THE BUCKET REFUSES A DUPLICATE STAGE AT LOAD** (AL-8, 2026-08-21, resolving AI-1).
★ The slot picker is the AUTHOR-TIME half of one-beacon-per-stage and `Bucket.Build`'s named
refusal is the RUNTIME half — *"two beacons at stage N — re-slot in the editor"*. **The manager
never meets a duplicate whether or not A10.3e has landed**, and an imported pre-slot route meets
the same refusal. ⚠ Tell-and-trust is unchanged HERE: the picker swaps, it does not refuse.
⟶ Graded by `driver_manager_acceptance.md` A12.2b; the refusal itself is the bench's line.

_Opus 5 (Analyst), 2026-08-20. **Written so S7 has full runway**: `AddBeacon` forces a stage today
(`routes.lua:345-347`, *"the stageless RECOVERY beacon has no path in through here either"*), and it
is the precondition for A10.3e's stage tick. ★ Every consumer of `b.stage` was read against a NIL
stage before this row was written; eight already behave correctly and one does not._

    MEASURED — what each consumer does when `b.stage` is nil
    NextStage      :304    marks used[0]; walks from 1, so it can NEVER mint 0        ✓ correct
    StageOrder     :1536   `(x.stage or 0)` sorts a stageless node FIRST              ✓ correct,
                           and it is RI-18 Q5's "no-stage first" falling out for free
    StageMatches   :1493   `b.stage == n` - nil never collides with anything          ✓ correct
    Gaps           :1507   `b.stage or 0`; does not raise `top`, reports no gap       ✓ correct
    StageOf        :786    returns nil for a stageless beacon                         ✓ correct
    PathOf         :656    `if not b.stage then return nil end` - NO ADDRESS          ✓ correct
                           ⟶ a stageless node has no `stage:ordinal` path, by design
    ChildAt        :631    matches on `b.stage == stage`; unreachable by a typed path ✓ consistent
                           with PathOf - the two agree, which is why neither is a defect
    BeaconAt       :1548   `(b.stage or 0) >= index` - returned only when index <= 0  ✓ correct:
                           a stageless node is NOT in the ordered run, which is the point
    ⚠⚠ Outcome     :1527   `b.outcome or ((b.stage or 0) + 1)`  ->  **1**

### ⚠⚠ THE ONE DEFECT, and it is the trap again

**A stageless node that completes would promote the run's index to 1** — sending the player back to
the start of the route. ★ It is the same shape as the `set stage N` trap `ifUnseen` was built for:
**an absolute promotion applied by a node that is not in the sequence.**

- **A2.10a** A STAGELESS NODE DOES NOT PROMOTE THE INDEX. `Outcome` answers "no promotion"
  for a node with no stage — not 1, and not the current index either.
  ⚠⚠ **CORRECTED 2026-08-20 after the bench built it:** this row said *"moves the ratchet NOT
  AT ALL"*, and **there is no product-side ratchet to move** — `Driver.Promote` lives in
  `addons/backlog/debug_suite/driver.lua` and the smoke has to inline it. ★ So what is
  GRADABLE today is `Outcome(stageless) == nil`; the ratchet half is OWED to the driver's
  arrival and must not be read as covered before then. **A criterion that names a behaviour
  nothing can execute reports coverage that does not exist** — the same fault as a false
  `grades` join, one level up. `Outcome` must answer "no promotion" for a node with no
  stage - not 1, and not the current index either.
      grades  Routes.Outcome
  TEST: a stageless beacon, completed, with the run at stage 6 -> the index is still 6.
  MUTATION: return `(b.stage or 0) + 1` -> the test reports the index at 1 on its own
  message. ★ Bites today, before the feature exists.
  ⚠⚠ **AND IT IS TOLD, NOT SILENTLY IGNORED (RI-32, drained 2026-08-20).** `SetOutcome` is
  reachable from the pane for ANY beacon, so an author can store a checkpoint on a stageless
  node. **The strict read stands — `Outcome` still answers nil — and the editor SAYS SO when the
  value is stored.** ★ Derived from a ruling already on file rather than invented — ⚠⚠ **BUT §81 IS NARROWED AS OF
  2026-08-21 (AI-2 audit): TWO of its three examples are now FALSE, both in this same file.**
  ~~duplicate stages~~ cannot be authored (A2.10 / AL-4) and the bucket refuses a second anchor
  at load (AL-8); ~~fractions~~ are a named refusal (§A3 row 9, `bucket.lua:64-66`). **What
  survives is OUT-OF-ORDER**, still legal and still told. ★ Tell-and-trust is unchanged: the
  picker SWAPS, it does not refuse. — §81 forbids
  validation on authoring (*"duplicate stages, out-of-order and fractions are all legal, the
  author is TOLD"*), and `DropRetired` is the shipped shape — a value that will not be honoured
  is dropped **and said**. ⚠ NOT a refusal: refusing would be grading the author, which §81
  forbids; the telling half is the part of the bench's (c) that fits.
  ★ **The message must be accurate: the value is STORED and DORMANT, not lost.** Give the node a
  stage and the stored outcome becomes live, because the stageless guard is what suppresses it.
  ⚠ The wording is the naming pass's; this row fixes what it must CONVEY, not the string.
  TEST: `SetOutcome` on a stageless node → the value is stored, `Outcome` answers nil, the author
  is told; then give the node a stage → `Outcome` answers the stored value.
  MUTATION: store it silently → the row bites on the missing message.

- **A2.10b** THE EIGHT ABOVE ARE A CONTRACT, not an observation. Each is asserted so that the day
  `AddBeacon` accepts a stageless node, nothing downstream has to be discovered.
      grades  Routes.NextStage · Routes.StageOrder · Routes.StageMatches · Routes.Gaps
  TEST: mint a stageless node, then assert each of the eight rows above.
  MUTATION: make `NextStage` able to return 0 -> the mint collides with the reserved
  value and the row bites.

- **A2.10c** NO ADDRESS IS NOT A BUG. `PathOf` and `ChildAt` agree that a stageless node has no
  `stage:ordinal` path. ⚠ So anything that reaches nodes BY PATH cannot reach it, and
  the driver must find it by ADDRESS (`RID:BID:CID`) - which is what governing #3 §A1.2
  already rules. **Recorded so nobody "fixes" PathOf.**

⚠ **What this row does NOT settle:** how an author CREATES one. That is A10.3e's tick, and the tick
waits on this row rather than the other way round — `AddBeacon` must accept it first.

### ANALYST REVIEW OF THE BUILD — 2026-08-20, at the bench's ask

_They asked for two things and explicitly asked me NOT to re-check whether the mutations bite,
because the harness proves that and re-reading it is the confirmation-shaped work that produced
RI-19. Held to. ★ 31 citations across 19 rows were checked mechanically first: **every cited
function exists in source** — including `NextOrdinal` and `OrdinalGaps`, which they built._

**1 · THE `promote()` LABEL IS CORRECT — and A2.10a over-promises, which is mine to fix.**
Their label stands: `promote(6, Outcome(sless)) == 6` is derived from `Outcome(sless) == nil`
directly above it, and it exercises a helper **defined inside the smoke**, so it cannot fail unless
the test's own arithmetic is wrong. ⚠⚠ **But that is the smaller half.** `Driver.Promote` exists
only in `addons/backlog/debug_suite/driver.lua` — **there is no product-side ratchet consumer at
all.** So A2.10a's promise, *"moves the ratchet NOT AT ALL"*, names a behaviour nothing in the
product can be graded against. ⟶ **A2.10a is corrected below**: what is gradable today is
`Outcome(stageless) == nil`; the ratchet half is owed to the driver's arrival and says so.

**2 · ⚠⚠ THE `NextStage(oid) ~= 0` LABEL IS WRONG — that one IS a guard, and it is the only one.**
Their reasoning was mutation-verified and the method was right: two attempts to break `NextStage`
were both caught earlier, at `smoke_dungeonrunpromoter:151` and `:154`. ★ **But both of those rows
run on route `id`, which has NO STAGELESS NODE** — `b.stage == 1` and `b2.stage == 2` on a freshly
minted route. `NextStage` walks `used[b.stage or 0]`, so `used[0]` is only ever set when a stageless
node exists.

    a mutation the earlier rows CANNOT reach:   `if used[0] then return 0 end`
      :151 / :154  PASS  - route `id` has no stageless beacon, so used[0] is never set
      :941         BITES - route `oid` does, which is the whole reason that row is there

⟶ **The assertion guards the interaction between a stageless node and the mint, and nothing else
reaches it.** ⚠ Two mutations not catching it is evidence about those two mutations, not about the
assertion — the space of mutations is not exhausted by the ones tried. **Recommend the label is
removed and the row counts as coverage.** ★ The method was sound; the sample was small, which is a
different thing and worth separating.


## REVIEW LOG
**2026-08-20 — Addons bench, §425. BUILT: P5, the SENSOR — `sensor.lua` + `smoke_sensor.lua`.
Arm/disarm with no persistent OnUpdate, parameters snapshot at ingest, the approach throttle
on RI-34's pair. FILED: RI-35.**

    SMOKES 24/24 by exit code · MUTATIONS 13/13 each on its OWN message ·
    check_targets · walk W1/W5 + all W2/W3/W4 goldens · interface 106/106 ·
    check_inbox (12 items, 1 open) · check_harness 8 · check_escapes 62 ·
    both emitters' apparatus OK

### ★★★ THE ROW WHOSE PREMISE EXPIRED — filed as RI-35 rather than fixed

A11.4b reads *"`R` and `Band` reach the driver as INDEXES into its own config table"* and
carries its own scope line: *"whether the EDITOR stores an index or a number is RI-22's open
question and this does not answer it."* ★ **RI-22 then answered it** — `driver_data_model.md`
12a, *"the STORE holds the number, not the menu index"* — and `contract.lua` types both as
numbers. ⟶ 3 beats 11, so the build took the number and **the disagreement went to the inbox**
per `DRIVER_BASIS`.

⚠ **Third instance this week of a note that became false without being touched**, and the
first where the doc had *explicitly flagged its own dependency*. The flag did not help,
because nothing reads flags. *A grep finds moved words; it cannot find moved load.*

★ **What survived is the requirement, not the mechanism.** A11.4b's test — break the config
table, the pass still runs — is **vacuous** with numbers, which would have been a green row
proving nothing. The requirement *nothing may read a table per sample* still bites: with
numbers on the record the re-readable thing is **the node itself**, so `Arm` snapshots and the
smoke arms, then moves the node and inflates its radius.

### ★★ MUTATION FOUND DEAD CODE THAT READ AS LOAD-BEARING

`NextIn` had `if nearest < 0 then return POLL_MIN end` — "already inside". ⟶ **Removing it
changed nothing:** negative `nearest` gives negative `slack`, which the general floor clamp two
lines down already catches. ⚠ The worst kind of dead code, because the next reader adds a case
to it. Deleted, with the finding recorded in its place.

### ★★ AND ONE ROW WAS READING ITS OWN CONSTRUCTION

`assert(stub.made == 0)` was labelled *"no frame at load"*. Mutation put a `CreateFrame` at the
top of `sensor.lua` and it **SURVIVED** — the smoke installs its stub AFTER `dofile`, so a
load-time call reaches the real default and this file can never see it. ⟶ Replaced with what
IS reachable (**arm creates the frame, and creates ONE** — this client's `CreateFrame` has no
inverse, so a frame per arm leaks all session) and the row now **states its own limit**.

### ⟶ AND THE INTERIOR THROTTLE ROW HARD-CODED A CONSTANT

`55 yd -> 0.5 s` encodes `MAX_CLOSING_SPEED = 100` inside a row named for the FORMULA, so
changing the constant would fire *"the arithmetic is wrong"* instead of the constant's own row.
★ Specific-behind-general **with the general row wearing the specific one's name**. It now
derives its expectation from the constants.

### THE APPARATUS CAUGHT `Sensor` BEFORE ANYTHING ELSE DID

`emit_built_state` refused to emit: *"product file(s) define UNLISTED namespaces … Sensor"*.
⚠ When `Rule` was missing from that list in §416 it surfaced only because a `grades` citation
happened to name one of its functions. ★ **This time no luck was involved** — the previous
case's fix was made LOUD rather than merely applied, and the loud version is what fired.

**2026-08-20 — Addons bench, §422-§424. BUILT: `check_inbox.py`, P4's outcome grading. Plus
RI-34's staleness sweep, CLASSIFIED rather than swept.**

    SMOKES 23/23 by exit code · check_targets 34/34 · walk W1 PASS · W5 PASS ·
    interface 106/106 · check_inbox 0 · both emitters' apparatus OK

### ★★★ THE LAW, STATED PROPERLY (Battlewrath, 2026-08-20)

> *"When having no equal is discussed. It is that it can't be shipped from Corpus to Lua just
> because it exists. It has to demonstrate why it is needed in the driver."*

⚠ **This bench had been arguing it MECHANICALLY** — *"there is no segment, so the clamp branch
cannot exist"* — and that is the weaker form. It implies that if segment DID exist the branches
would automatically apply. ★ His is RI-33's own sentence: **the burden is on the bench
artefact; existing is not a reason to ship.** A thing crossing from desk to driver owes a
demonstration of NEED, and "it is in `walk.py`" is not one.

⟶ **And it lands on what this bench shipped the same day.** `emit_samples.py` brings corpus
paths into Lua, so it owes that demonstration. It has one, and it is an instance rather than an
argument: **the one-sidedness row failed because a REAL path varies in z.** A synthetic
straight path holds z constant and would have passed the broken fixture. The corpus earned its
place by finding a fixture fault a synthetic could not produce.

⚠ **Recorded honestly: the tool was built first and the justification arrived after.** The need
was real; the discipline was retrospective. The test is cheap to run BEFORE — *what does this
let the driver do that it could not?* — and it was not run.

### RI-34's STALENESS SWEEP — ten hits, TWO stale

⚠ **Classified, not replaced.** A sweep that rewrote every occurrence would have destroyed
seven correct ones and one deliberate headstone:

    audit_A:29 · audit_C:46      COA_LANDMARKS' OWN shipped values - a neighbour's file
    asklist:61                   already carries "⚠⚠ BOTH SUPERSEDED"
    asklist:115                  narrates the old state, concludes "⟶ Floor → 0.1"
    s9:106                       already has its SUPERSEDED note appended
    sense:205 · authoring:561/585  PAST TENSE - the log recording what was found then.
                                 ★ Rewriting history is the fault the headstone pattern exists
                                 to avoid.
    ⟶ sense:415                  P5's build-order line. LIVE SPEC, and wrong. FIXED.
    ⟶ audit_B:141                "Shipping constants" - reads as OURS. FIXED.

### ★★ AND audit_B'S LINE IS THE FINDING, not the fix

It recorded **`MAX_CLOSING_SPEED 30 (exceeded 50.6 in pulls; INERT)`**. ⟶ **The evidence for
RI-34 was already on disk, already measured, and marked harmless.** And it WAS harmless: under
segment, over-running the divisor costs a late arrival notice. Under point + band + gate the
same over-run is a **missed beacon**.

⚠ Nothing in that line's text changed when the rule narrowed — *a grep finds moved words, it
cannot find moved load* — so the note was true when written and became false without being
touched. ★ **Third instance of that lesson, and the first where the stale note had already
done the measurement.**

**2026-08-20 — Addons bench, §414-§416. BUILT: A11.9b (the park), P3 (the rule).** And below,
FOR THE TIGHTENING PASS, every row the build had to navigate rather than follow.

    SMOKES 22/22 by exit code · check_targets 34/34 · walk W1 PASS · W5 PASS ·
    interface 106/106 · both emitters' apparatus OK

### ⚠ ROWS THE BUILD NAVIGATED — all five DISPOSITIONED 2026-08-20 (Opus 5, Analyst)

    1  A11.2a says segment          FIXED — rewritten to point + band + gate, with the
                                    arithmetic for sufficiency and the ~1% cost named
    2  A11.2f's reason is spent     FIXED — answer kept, reason replaced, 0.2 s floor stated.
                                    ★ Your call to put this first was right: it was the only
                                    one where a LIVE row rested on a retired criterion
    3  A11.2b / A11.2c vacuous      FIXED — A11.2b retired with a headstone (A2.12's pattern);
                                    A11.2c rewritten to its surviving claim
    4  A11.2g half-gradeable        MARKED — the row now names its NOW half (node-shaped,
                                    graded against `Rule.Evaluate`) and its WAITS half (the
                                    sharing needs the sensor). Not a defect; an honest green
    5  A11.9a needs a driver        ACCEPTED as reported — unchanged, and correct to report

★★ **AND THE GREP FOUND FIVE MORE THAT NEITHER OF US REACHED**, the largest being **A11.7b —
V1's RELEASE GATE**, which was still *"W7.1's byte-equality"*. Also THE BAR (sensing was DEFINED
as byte-equality), A11.3c's whole justification, two unfalsifiable mutations, and the P4 step.
⟶ **A retirement is not done until its identifier has been grepped.** Detail in the sense
brief's review log; my own false log entry is named there first.

**1 · A11.2a says segment; RI-33's drain says point + band + gate.** The drain states *"A11.2a
narrows to point + band + gate; segment, interpolated-z and v_max are desk-side"* — and the ROW
still reads *"Point + segment + band … graded by W7.1 (byte-equal to the desk)"*. ★ §416 built
only what BOTH agree on and did not build segment. **Reported, not resolved.**

**2 · ★★ A11.2f's REASON has gone, and this one is not on anybody's list.** The row picks 1 Hz
*"because the golden is at 1 Hz and W7.1's byte-equality may REQUIRE it"*. ⚠ Byte-equality moved
to the desk in RI-33's drain — **so the stated justification for the cadence no longer holds**,
while the throttle conversation has the driver sampling at a 0.2 s floor with a granular ramp on
approach. The row's ANSWER may still be right; its REASON is spent, and a row justified by a
retired criterion is the shape that gets rediscovered later as a surprise.

**3 · A11.2b and A11.2c are about segment.** "The FIRST sample after arming uses POINT — the
segment path is not entered" and "a degenerate segment falls back to POINT" both describe a
fallback FROM something that no longer exists. ⚠ Not wrong — vacuous, which reads identically in
a green suite.

**4 · A11.2g is half-gradeable today.** The SHARING is the sensor's (A11.3) and the sensor is not
built; what §416 could hold is that the rule is NODE-SHAPED, so per-row evaluation is not the
natural implementation. **The row's own test needs the sensor's smoke to exist.**

**5 · A11.9a needs a driver.** *"Complete a node whose tabs set no marker → the tracker reads the
park"* cannot run until something completes a node. §414 built the park's GEOMETRY and said so.

### ★★ WHAT MUTATION FOUND, since it is the part with no other home

**A REAL DEFECT in `rule.lua`** ⚠ **CLOSED BY REMOVAL 2026-08-21, not by repair — `Rule.OPEN` no longer exists (`rule.lua:39`; `smoke_rule` pins it nil) and `Evaluate` now REFUSES a nil band. Kept as a mutation-findings record; it is not an open defect:** `finite()` refuses `math.huge` and `Rule.OPEN` **is**
`math.huge`, so a node with its band set EXPLICITLY open was refused while one leaving it `nil`
was accepted. ⚠ The fixture used `nil` and never entered the path. **A rule that punishes being
explicit is a trap for whoever writes the exporter.**

**AND THREE WEAK ROWS OF MINE**, each fixed rather than propped:

    W6   SURVIVED TWICE and taught what the guard is FOR. A NaN band is refused by the
         COMPARISON alone, so the NaN row proved nothing about the check. The real case is a
         NON-NUMBER band - `dz <= "5"` THROWS in Lua 5.1 - so without the guard a mangled
         import CRASHES the driver mid-poll rather than refusing a node.
    W1   the specific NaN row sat BELOW the sweep, so the sweep caught every mutation first.
         ⚠ Specific before general - the third time this session.
    W5   passed for the WRONG REASON: off-centre, `dist2 > 0` refuses a zero radius by
         GEOMETRY and the guard is never reached. Tested AT the node now.
    W10  its first cut was `Rule.prev = nil`, which assigns NOTHING in Lua. **A no-op mutation
         "survives" without ever running and tells you nothing about the test.**

⚠ And §414 withdrew an assertion of mine outright: *"a route stretched in y must clear as one
stretched in x"* implied the park's axis choice had a failure mode. Forcing always-x SURVIVED —
parking beyond an extreme clears the standoff whatever the perpendicular spread is. **The
function's own comment already said the axis cannot buy more room; the assertion argued with it.**

**2026-08-20 — Addons bench, §399-§400.** Built what RI-32's drain requires, took a label
correction, and closed RI-24's bench-side half.

    SMOKES 20/20 by exit code · check_targets 32/32 · walk W1 PASS · W5 PASS ·
    both emitters' apparatus OK

**§399 · A2.10a's TELLING.** `SetOutcome` on a stageless node stores the value AND says so —
derived from §81 (no validation on authoring) and `DropRetired` (a value that will not be
honoured is dropped **and said**), never invented. ★ The guard people would skip is the third
one: **the claim the message makes is asserted TRUE** — store 9, give the node a stage, 9 goes
live; return it to stageless, suppressed again. A tell that promised that falsely would be a
lie with a friendly tone, which is worse than silence. ⚠ The wording is provisional and marked
as the naming pass's.

**⚠⚠ AND A LABEL OF MINE WAS OVERTURNED, correctly.** §393 marked `NextStage(oid) ~= 0` a
restatement because two mutations were caught earlier at :151/:154. The review's counter:
**both of those rows run on a route with no stageless node**, and `NextStage` only sets
`used[0]` when one exists. ★ Verified here before acting — `if used[0] then return 0 end`
passes them and bites the A2.10b row on its own message. Label removed, row counts as
coverage. ⟶ **Two mutations missing a row is evidence about those two mutations, not about the
row.** The method was sound and the SAMPLE was small; separating those is the lesson.

**§400 · `store.lua`'s HEADER STOPPED DESCRIBING THE STORE** (RI-24's own finding). It claimed
`schemaVersion = 1`, keyed `runs` by name, and named none of the four tables the same file
creates. ⚠ REMOVED rather than corrected — correcting it rebuilds the thing that rots. It now
points at `driver_stored_state.md` and the emitted inventory and keeps only the composite
shapes the emitter cannot say.

⚠ **THE r\'\'\'…\'\'\' DEFECT REACHED THREE FILES** before it was named: a review-log entry and
both §393 smoke labels went in with literal `\uXXXX` escapes. All fixed; `grep -c` is now part
of the landing rather than an afterthought, because the write reports success either way.

**⚠ BLOCKED, unchanged:** RI-22 · RI-24 (D-2 only) · RI-26 · RI-27 · RI-31. RI-29 is ready to
stamp — its basis moved.

**2026-08-19 — Addons bench, §394-§397. THE UNBLOCKED LIST IS EMPTY.** All five items the
previous entry named as unblocked are done: `fireOn` retired (§392) · the stageless path (§395)
· the ordinal mint + gap (§394) · P4's remaining half (§397) · the `grades` citations (§396).

    SMOKES           20/20 by exit code
    check_targets    32/32
    walk.py check    W1 PASS · W5 PASS
    emitters         both apparatus checks OK
    COVERAGE         7 -> 17 rows carry a `grades` line (13%), each verified twice

**★★ WHAT THE TOOLS CAUGHT THAT I DID NOT.** Three defects this session were found by apparatus
rather than by reading, and all three were mine:

    · `emit_built_state.py` REFUSED TO EMIT after §392, because its `MUST_STRAND` entry named
      `Routes.SetChildFireOn` and A2.12 had just deleted it. ★ Re-anchored to `Adaptor.Codes`
      rather than removed - a stranding detector with no proof it can say NO reports everything
      as reachable and looks healthy doing it. Its paired check was GENERALISED for the same
      reason: as written it could never fire again, so it would have read as a passing guard.
    · `grades_candidates.py` CONTAMINATED THE EVIDENCE it was written to support - real function
      names in its docstring made the emitter count the tool as a CALLER of them. **A tool that
      describes the corpus must not appear in it.**
    · and it printed a rival COVERAGE number (19 vs the emitter's 17) while claiming in its own
      docstring that the two could not drift. Removed: one authority, and it is the emitter.

**★★★ AND MUTATION KEEPS FINDING THE TESTS, NOT THE CODE** — five rows this session could not
fail, each labelled in place rather than left looking like coverage: A2.12's field-survived row
(masked by the count assert until M5 was written to reach it) · A2.10's `NextStage` row and its
`promote()` row (both restatements) · A2.11a (satisfied by the SIGNATURE - `NextOrdinal(b)` has
no handle to the route, so the first "surviving" mutation was a no-op) · and P4's join, which
needed count asserts because a dropped source makes the blind-spot list SHORTER and therefore
better-looking.

**⚠ BLOCKED FROM HERE, and both are Battlewrath's.** Sense **P2** on **G5** (RI-26); the band and
radius pickers on **RI-22**. ⚠ **A10.3e is now PARTLY blocked rather than open**: its stage and
`Set(N)` halves are fully specified, but `radBox / upBox / downBox` in the same row wait on
RI-22, and A2.11's own note leaves the ordinal picker's *next decimal* offer (tenths or
hundredths) unsettled. Splitting one acceptance row across two landings is a call this bench did
not take alone.

**FILED, awaiting a drain:** RI-22 · RI-24 · RI-26 · RI-27 · RI-29 · RI-31 · RI-32.

**2026-08-19 — Addons bench, §392-§393. BUILT: A2.12 whole, A2.10 whole.** Verified by running,
not reading; every number below is from a command in this session.

    SMOKES           20/20 by EXIT CODE. ⚠ Not by last line - `smoke_dungeonrunoptions` and
                     `smoke_dungeonrunroutes` both end on a line that is not "OK" and both
                     exit 0. Reading `tail -1` reports them as failures.
    check_targets    32/32
    walk.py check    W1 PASS · W5 PASS
    MUTATIONS        9 written for the two rows; 7 bite on their own message.

**A2.12 · `fireOn` RETIRED** (§392). Setter removed whole with a headstone; a stored value dropped
and TOLD through `DropRetired`, on every load. ★ **The judgement worth recording:** it counts and
says SEPARATELY from A2.6's pointer drop. Folding it in was shorter and would have announced a
"retired POINTER" for a field that never pointed - the criterion is the MESSAGE, so the message
has to be true. The smoke asserts it says "firing" and not "pointer".

**A2.10 · THE STAGELESS NODE** (§393). `Routes.Outcome` answered **1** for a node with no stage -
a recovery beacon completing would have sent the player to the START of the route. ★ Fixed with
`nil`, which needed no consumer change: `Driver.Promote` already reads *"if not outcome then
return current end"*. The eight consumers are now asserted as a contract; A2.10c asserts PathOf
and ChildAt AGREE there is no path, with *"do not 'fix' this"* in the message.

### ★★ WHAT MUTATION SAID ABOUT THE GUARDS - the part with no other home

_A green suite says nothing about whether its rows can fail. These were found by trying._

    A2.12   M1 aimed at "the field survived" and proved the row ABOVE it (the count assert
            fires first). ★ M5 was written to reach it - increment the counter, never clear
            the field - and it is the only shape that does. Row is now a guard.
    A2.10   ⚠⚠ TWO ROWS ARE RESTATEMENTS, NOT GUARDS, and are LABELLED as such in the smoke:
            · `NextStage(oid) ~= 0` - two different mutations of the mint were both caught far
              earlier at :151/:154. Never-returns-0 is a CONSEQUENCE of counting from 1.
            · `promote(6, Outcome(sless)) == 6` - derived from the assertion above it.
            ★ Both KEPT (they put the reasoning where a reader of A2.10 looks) and both marked,
            because a row no mutation can reach is documentation.

⚠ **A FIXTURE LEAK was caught by a test written months ago** - the planted stageless beacon was
left in the route and *"a delete leaves a GAP in the numbering"* failed on the changed count.
Fixed by DELETING the fixture. ★ The argument for asserting counts, made by the counts.

⚠ **TOOLING FACT, cost two false starts:** `routes.lua` and the two smokes have MIXED line
endings (882 newlines in `smoke_dungeonrunroutes`, only 155 CRLF). A detect-one-style whole-text
replace silently matches NOTHING on such a file and reads as an anchor miss. Edits are now
line-wise, taking each line's ending from its neighbour.

**FILED, not built:** RI-32 - A2.10a is unconditional, so a stored `b.outcome` on a stageless
node is now silently ignored, and `SetOutcome` is reachable from the pane for any beacon. ⚠ The
bench did not build the store-ignore-and-SAY variant that §81 would favour, because A2.10a does
not mention telling and inventing the message is not the builder's.

⚑ **THE LOG'S OWN UNBLOCKED LIST MOVED:** item 1 (`fireOn`) is DONE; item 2 (S7) has its whole
consumer contract asserted and only the MINT is still owed. Item 3 (the ordinal mint + gap) is
next.

**2026-08-19 — Opus 5 (Analyst), MEASURED not read.** ⚠ The entry below this one is dated to
`5ea7d37` and lists **A9.1 · A9.3 · A8.4 as RED**. All three landed (§330 · §370 · §334-5). **The
log was the stale thing, not the build** — and a stale review log is the worst kind, because it is
the one place a reader goes to ask "where are we".

    SMOKES            5/5 PASS   routes · promoter · dungeonrun · map · options
    MUTATIONS       319/324 bite on their own message
    NON-BITERS        5, and ALL FIVE carry the same marker: [PENDING the Actions profile
                      pass, §365] - A3.1 ×2 · A3 default · A3.3 anchor · A3 clear-the-sense.
                      ★ Deliberately marked, not rot. They are the SAME problem as the
                      divergent row grammar: they assert the per-field sense shape that
                      `object.lua` still writes and the row grammar replaces.
    check_targets    32/32
    walk.py          W1 PASS · W5 PASS · W2/W3/W4 goldens reproduced
    emitters         both apparatus checks green (store inventory · built state)

**★ WHAT THIS MEANS FOR THE RED LIST.** There is no RED left from the previous entry. What replaces
it is not a failure list but a STATE list, and it lives in `driver_built_state.md`:

    OWED        the stageless beacon (S7) · notes by NoteID · Next as one field
    UNGUARDED   whole-number stages · the reach boxes (both accept values the rule forbids)
    DIVERGENT   the row grammar - `object.lua` writes the superseded per-field shape while
                `SetRow` / `RowsOf` sit TEST-ONLY. ⚠ This is what the five marked mutations
                are waiting on, so the two close together or neither does.

**★★ DEV CAN CONTINUE, and the unblocked work is not small.** Nothing below waits on a ruling:

    1  RETIRE `fireOn`          a removal, already ruled (RI-5); stranded with no caller
    2  `AddBeacon`'s stageless path (S7)   the design is settled - nil in the store, 0 on the
                                record - and it is the PRECONDITION for A10.3e's stage tick
    3  the ordinal mint + gap function (S5)   `NextStage` and `Gaps` exist for stages and have
                                no ordinal equivalent; the child picker cannot be built without
                                them
    4  P4's remaining half      text metrics / stub reporting, as A10.1c reads
    5  spread the `grades` citations   mechanical, verifiable, and it raises the 4% coverage
                                that currently caps what any of this can prove

⚠ **BLOCKED, and both are Battlewrath's:** sense **P2** (the row shape as a declared contract) waits
on **G5**, the representation — the model calls it the next decision and RI-26 carries the options.
The band and radius pickers wait on **RI-22**. ★ Neither blocks items 1-5.

_How I tested: ran every smoke under `.tools/lua51`, ran `mutate.py dungeonrun` whole and read the
non-biters by name, ran `check_targets`, `walk.py check`, and both emitters' apparatus. ⚠ Read whole,
not tailed._


**2026-08-18 — Analyst on the bench's §19 (at `5ea7d37`).** Verified by running, not reading:
`smoke_dungeonrunroutes` 11/18 covered (A1.1–A1.3, A2.1–A2.4, A3.1–A3.4, A7.1); uncovered
A4.x (R1), A5.1–A5.2 (function not built), A6.x (R3) — as reported. `smoke_dungeonrunpromoter`
OK. `mutate.py dungeonrun` **281/293 bite**; the 12 non-biters are §19e's, all pre-existing,
none in the new rows; **all 21 new mutations bite on their own message.**
    PASS       A1.2 · A1.3 (nil until R2) · A2.1 · A2.2 · A2.3 · A2.4 · A3.1 (as `sense`) ·
               A3.2 · A3.3 · A3.4 · A7.1
               [⚠ dated to `5ea7d37`: A3.1/A3.2 were REWRITTEN later the same day (RI-15/17 —
               the field is the row's action word + arg) and A3.5 ADDED; those greens are
               against the OLD text and re-run when the field moves]
    MOVED      A1.1 (T13 accepted — pure accessor; masking mutation retired) · A3.1 wording
    RED        A9.1 (pre-§322 pane greens UNVERIFIED) · A9.3 (three terms, `satellite` a
               §3b fail) · A8.4 (colon in a route name breaks the address — live defect)
    NEW        A8.1–A8.7 · A9.x
    STILL R1/R2/R3 — Battlewrath's; Analyst positions unchanged. [ANSWERED same day: RI-1 · RI-2 · RI-3.] A8.5's satnav-laws question
               added to his list.
Failures above are observations; the bench owns the fixes. Next on landing: A9.1's audit list,
then A8.4's migration criterion, then A5.3's checker with its first red.

**2026-08-18, addendum (Battlewrath on the adaptor table) — two rows contradict the record:**
    `shape → wire : "trip wire"`   WRONG user word — `wire` is GEOMETRY (a line of small radii);
                                   "trip" is a FIRING word (seen / crossed). Two independent
                                   axes (model §2). The row contradicts a resolution already on
                                   file; not a naming-pass question.
    `bossEngaged / bossKilled /    THREE rows for ONE author question. The author picks
     boss (picker)`                "boss killed: ⟨name⟩ → advance" or "boss engaged: ⟨name⟩ →
                                   say the note"; the name is the sense's PARAMETER, the picker
                                   is not a term, and arming/witnesses/listener are the driver's
                                   (model §2c corrected). A3.1/A3.2 read accordingly: two senses,
                                   each carrying a name — not a sense plus a separate name step.
                                   ⚠ SUPERSEDED (RI-15 settled, 2026-08-18): boss is NOT a sense and ENGAGED is not
                                   offered — ONE condition on a what-I-do row, killed only.

_How I test: run each smoke on landing; apply the named mutation myself; report PASS / FAIL /
UNMUTATED with the observed message. Failures return as observations. R1/R2/R3 change which
branch of A3.3 / A1.3 / A6.1 applies, not whether the row exists._
