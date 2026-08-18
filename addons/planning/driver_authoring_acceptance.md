# Dungeon Run — AUTHORING acceptance (item 1 + item 2's first proof + the adaptor)

_Analyst, 2026-08-17, on the bench's proposition (`driver_bench_proposition.md`). Target §9 said
"the editor's own criteria (not yet written) gate Dungeon Run" — these are they, for the docket's
items 1–3. Written BEFORE the code, from the proposition's smoke plan (§8) and the model, so the
smoke is written to the criterion. **Every assertion must be shown to BITE** (mutation named per
row); a green that has not been mutated is not evidence. The Analyst tests each on landing._

Where R1/R2/R3 are unruled, the criterion is written to hold either way.

---

## A1 · G2 — reach on a childless beacon
- **A1.1 (MOVED 2026-08-18, on the bench's T13 — accepted):** `Routes.SetBeaconReach(b, radius,
  up, down)` stores; **`Routes.ReachOf(x)` is a PURE ACCESSOR of x's OWN fields** (R5: a
  `<Noun>Of` reads its noun). The acceptance question composes at the call site —
  `ReachOf(AcceptanceOf(b))`. Why it moved: as first written, a beacon's own reach was stored,
  DISPLAYED, and masked by a flagged child's — "the author types 99, the box shows 99, the
  resolver returns the child's 8" — and two steps on one position have two OWNERS (`BID`,
  `BID:CID`), both of which must be readable or the flatten cannot emit the beacon's step and
  the route cannot be shared. Additive; no existing signature changes.
- **A1.2** A childless beacon is RUNNABLE: `AcceptanceOf(b)` returns the beacon AND
  `ReachOf(AcceptanceOf(b))` returns a reach for it — unaffected by the A1.1 move (for a
  childless beacon `AcceptanceOf(b) == b`). `/dr walk`'s unrunnable-stages report no longer
  lists a childless beacon that has a radius.
- **A1.3 (RI-2 DRAINED 2026-08-18 — the SPLIT):** Height untouched: the beacon's `z` is still the
  read's (`routes.lua:29-31`); band is a tolerance over it. **`ReachOf` is the RAW read — `nil`
  means the author set nothing; the CONSUMER resolves ±2.5 when nil** (R6's raw/resolved, as
  `OutcomeOf`/`Outcome` already do). Nothing shipped changes; P1 stands. Pane: a slider the
  author TICKS to change, with light text ("changes the height of detection"); the same control
  shape for radius:listen and radius:sense. Test: unset → `ReachOf` nil AND the resolved band
  reads 2.5; typed 2.5 → `ReachOf` 2.5 (distinguishable from unset at the read).
- **mutation** delete the beacon's own-field read in `ReachOf` → A1.2 fails on its own message
  (childless case); the child case still passes; **the old "child's reach must WIN over the
  beacon's" mutation is RETIRED** — it asserted the masking as correct.

## A2 · the child ordinal (`4.1:3`, `4.1:3.1`)
- **A2.1** A stored, sparse ordinal on the child; `ChildrenOf(b)` returns children in ordinal
  order; inserting `3.1` renumbers NOTHING (every other ordinal byte-identical before/after).
- **A2.2** `4.1:3` resolves to exactly one child; `4.1:3.1` to another; the full path is unique
  route-wide.
- **A2.3** Two children on one ordinal is TOLD (pane + `/dr walk` report), never refused (S4).
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
- **A2.6 (2026-08-18) — STEPS replace `goTo`.** An ordinal child is a STEP: the same object as
  a childless beacon — default lure (come here / arrow / note), sense reach-here, what-I-do
  advance to the next step; it points at ITSELF; order is the ordinal alone. `goTo` and its
  checks (`Heads / BrokenLinks / Cycles`) are RETIRED: removed absolutely, not parked (a half-
  formed path invites building on it); any stored `goTo` on an existing route is TOLD at load
  and dropped, never silently honoured. Satellites unchanged. Test: a beacon with steps 1..3 —
  the arrow points at step 1; satisfying it → step 2 listens and the arrow moves to step 2
  (its own lure), and so on; step 3's advance completes the beacon unless completion was
  placed elsewhere.
- **mutation** make insertion renumber → A2.1's stability assert fails; give two children one
  ordinal → A2.3 shows the tell and nothing errors; delete child 1 with siblings present →
  A2.5 must TELL and not remove; delete it as the last child → the parent regains its tabs
  and the completion default; leave a `goTo` code path callable → A2.6's grep must find it
  (retired means gone); feed a route carrying `goTo` → told and dropped, not honoured.

## A3 · G10 — the boss child SENSE + name picker
- **A3.1 (WORDING MOVED 2026-08-18):** the axis is **`sense`**, not `kind` — `kind` is the
  structural discriminator (beacon / child / note) and `SetName`/`NameOf` branch on it (the
  empty smoke caught a `kind="boss"` falling onto the beacon-naming path before a line of the
  feature existed); B1 closed on `sense` from the model's own defaults table. Substance
  unchanged and shipped: a child `sense` with `bossEngaged` / `bossKilled`; its picker is fed
  ONLY from the run's `r.bosses` (`store.lua:364`), folded to the distinct set; the author
  cannot type a name; the setter refuses anything not on the offer.
- **A3.2** Two senses offered on it: *boss engaged* · *boss killed* (model §2).
- **A3.3** NO refusal needed (Battlewrath, 2026-08-17): the driver's arming call takes the name
  as its argument — `listen(UNIT_DIED, name)` — so a boss child with NO name has nothing to pass
  and NOTHING ARMS. The unfiltered listener cannot be expressed because the arming function has
  no unfiltered form (same law as position: fixed mechanism, instruction supplies the parameter;
  WA's firehose guard by construction). Editor TELLS ("no name — it will not listen"); `/dr walk`
  marks the stage unrunnable; S4 tell-and-trust intact. Test: a nameless boss child arms nothing
  and is told; a named one arms exactly one dest-name listener.
- **A3.4** Nothing about a set, a count, or a grouping is stored or shown (capture.lua:234 bound).
- **mutation** emit a nameless boss child → nothing arms and the tell shows (A3.3); offer a typed
  name → A3.1 rejects the path; arm a named one → exactly one listener, for that dest name.

## A4 · G1 — the reader note (written to hold under either R1 answer)
- **A4.1** A note resolves to EXACTLY ONE string for a child at runtime, ≤ ~200 chars (target §4).
- **A4.2 (RI-1 + RI-10 DRAINED 2026-08-18):** referenced in the STORE, owned in the PANE — and the
  store is **the ROUTE NOTE PLANE, its own table under the personal one** (§60's phrase; NOT
  `Store.NoteTable`, which is the PERSONAL plane and never travels — my earlier wording named
  the wrong shelf). Keyed by the child's address (`RID:BID:CID`). The pane shows a note field on
  the child LABELLED **"Route instructions"** (one adaptor row: term `route note` → label
  "Route instructions"; "Personal note" for the other kind) with ghost text "Instructions for
  the player running the route"; saving creates/updates the route-
  plane entry for that child; re-pointing to share one note across children is a later action.
  Export takes the route plane WHOLE and never the personal one — structural, no tag to check.
  §91's reasoning survives; the author never meets a note object. **G1 UNBLOCKED.**
  Test: two children with independently typed notes → two route-plane entries; edit one → only
  one changes; export → route notes travel, personal notes on the same map do not (mutation:
  route the export through the personal plane → the travel assert must fail).
- **A4.3** The note is a CHOICE option: a child with no note has none, and nothing renders.
- ★ **A4.1–A4.3 CLOSED §346.** ⚠ Except the export half of A4.2's test, which has no
  surface to run against — export does not exist. The two-table STRUCTURE is asserted in
  its place (`Store.RouteNoteTable() ~= Store.NoteTable()`), and that is the thing RI-10
  ruled would make the travel rule hold without a filter. **The travel assert is OWED.**
- **mutation** two children pointing at one referenced note, edit once → both read the new
  string (referenced) / only one changes (owned) — the test names which world it is in.

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
  boss child's *boss killed* sense satisfies → the beacon's next (`advance` or `set:stage`)
  fires → the stage moves. No new capture.
- **A6.2** The two witnesses both required: engage seen for that name AND `UNIT_DIED` on that
  name; either alone does not advance (advisory §11).
- **A6.3** The pin trace (C-4) is recorded per set/arrive/clear before "point here" is replayed;
  until then A6.1 grades the ADVANCE, not the pointing.
- **A6.4** Readout carries `hit · skip · false_advances`, never `stage` alone (W7.3).
- **mutation** drop the `UNIT_DIED` witness → A6.2 must NOT advance; feed a name not in the
  run → nothing arms.

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
- **A8.5 export trims to what import will mint** — best working model (RI-4 drained 2026-08-18).
  Criterion: export carries the identity table + current XYZ + enough to re-create, and DROPS
  the origin/mint data (placement pair, id counters); **on import ONLY THE RID is re-minted —
  every `BID:CID` is preserved byte-for-byte** (unique within the RID; no waterfall); metadata
  outside identity/place (notes, radii, bands, names) survives; the import landing becomes the
  new origin. Test: `import(export(route))` → new RID, identical `BID:CID` set, identical
  properties, no duplicate mint. The ledger's round-trip law is compared against this MINT
  CONTRACT, not stored bytes; ledger §5.9–5.11 get a banner (bench).
- **A8.6 the flat form is the stored form** — RULED (corrects the proposition's §0b, which
  named the wrong one). No criterion yet; the criterion is A8.3's + "panes are views over the
  flat list" — a pane never holds a second copy of a value (A2.4's shape, generalised).
- **A8.7 model surface with no code — tracked, not graded:** tabs (each node carrying G2/G10
  fields directly is a MIGRATION when tabs land — §16d) · the all/any selector · `while` (G15)
  · state senses (`falling` needed by the skip; capture does not record it) · `scene entered`.
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
- **A9.2 twelve rotted mutation anchors** — 281/293 bite (verified by the Analyst 2026-08-18:
  ten `?? ANCHOR found 0x`, two `~~ WRONG`). All twelve in older map/art specs, none in the
  new rows. Criterion: 293/293, each anchor naming the LINE THAT DOES THE WORK, never prose.
- **A9.3 A5.3's checker — first red exists.** Three terms reach a pane with no user word:
  `ratchet` (`object.lua:197`), `on-ramp` (the answers line), `satellite` (§312's readout —
  §3b names it explicitly as a FAIL). Criterion: the third check in `check_interface.py` lands
  and reports these three; the strings are re-worded under the naming pass (S3) — `satellite`
  can be fixed NOW ("always listening" reads without the word).
- **A9.4 the roster cap of six** — TOLD when exceeded, never silent (verified). Whether it
  should scroll is a decision waiting; not a red.
- **A9.5 W7's golden rots while it waits** — the write-once comparator compares on every
  `walk w5` run; criterion: it is RUN on each landing (add to the smoke roster or the check),
  so rot is seen, not discovered.

---

## REVIEW LOG

**2026-08-18 — Analyst on the bench's §19 (at `5ea7d37`).** Verified by running, not reading:
`smoke_dungeonrunroutes` 11/18 covered (A1.1–A1.3, A2.1–A2.4, A3.1–A3.4, A7.1); uncovered
A4.x (R1), A5.1–A5.2 (function not built), A6.x (R3) — as reported. `smoke_dungeonrunpromoter`
OK. `mutate.py dungeonrun` **281/293 bite**; the 12 non-biters are §19e's, all pre-existing,
none in the new rows; **all 21 new mutations bite on their own message.**
    PASS       A1.2 · A1.3 (nil until R2) · A2.1 · A2.2 · A2.3 · A2.4 · A3.1 (as `sense`) ·
               A3.2 · A3.3 · A3.4 · A7.1
    MOVED      A1.1 (T13 accepted — pure accessor; masking mutation retired) · A3.1 wording
    RED        A9.1 (pre-§322 pane greens UNVERIFIED) · A9.3 (three terms, `satellite` a
               §3b fail) · A8.4 (colon in a route name breaks the address — live defect)
    NEW        A8.1–A8.7 · A9.x
    STILL R1/R2/R3 — Battlewrath's; Analyst positions unchanged. A8.5's satnav-laws question
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

_How I test: run each smoke on landing; apply the named mutation myself; report PASS / FAIL /
UNMUTATED with the observed message. Failures return as observations. R1/R2/R3 change which
branch of A3.3 / A1.3 / A6.1 applies, not whether the row exists._
