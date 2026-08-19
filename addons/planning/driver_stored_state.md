# WHAT IS STORED — the going-forward fact

_Opus 5 (Analyst), 2026-08-19, at Battlewrath's ask: **"We need a heading fixed-ish on our data
model before we over build selections. We need an inventory of what is stored and how. And then
flatten that into a going forward fact. I'd rather re-write now and sort our debt, than tangle."**_

**★ Its sibling is `driver_built_state.md` — what is BUILT.** This file says what is STORED.

**★ This file is the FACT. The evidence under it is `history/store_inventory.md`, which is EMITTED
by `addons/tools/emit_store_inventory.py` and must never be hand-corrected** — re-run it. This file
is the curated half: the shapes, the laws they already obey, and the debt named with a disposition.

⚠ **It describes the STORE, not the export.** The line, the side tables and the projection are
`driver_data_model.md` (**governing #3**) — the records, what may appear in them, and the
export. Those describe what LEAVES; this describes what IS.

---

## 1 · THE ROOT — one global, one owner

    COA_DungeonRunDB = {
      schemaVersion   2          store.lua:52 - refuses a version above it, migrates below (A8.4)
      nextId          n          ONE monotonic counter shared by runs AND routes, so a handle
                                 can never collide across the two tables (store.lua:485)
      runs       [id] captured EVIDENCE      name · character · armedAt · closedAt · mapFile ·
                                             mapW/mapH · outside · arrival · markers[] · legs[] ·
                                             bosses[] · testPinSet
      routes     [RID] AUTHORED routes       name · mapID · author · madeAt · beacons[]
      routeNotes      the ROUTE note plane   travels with an export
      notes           the PERSONAL note plane  never travels, structurally
      ui              session-only UI state, per character
    }

**★ DR-20: `store.lua` is the only module that touches the global.** `routes.lua` mutates the
route tables it is handed; every other module goes through the API. A rewrite replaces one file.

⚠⚠ **AND `store.lua`'s OWN HEADER IS FOUR TABLES BEHIND.** Its `Shape:` block documents `runs`,
`markers` and `legs`, and does not mention `routes`, `routeNotes`, `notes` or `ui` — all four of
which the same file creates. ★ That is the entire argument for the inventory being EMITTED: **the
one authoritative description of the store had silently stopped being one.**

## 2 · THE RECORDS, as measured

    ROUTE      keyed by RID       name · mapID · author · madeAt · beacons[]
    BEACON     b.id = BID         kind="beacon" · stage · name · children[] · place (inherited)
    CHILD      c.id = CID         place (minted from the parent) · ordinal · role · setStage ·
                                  ifUnseen · rows[]
    ROW                           sense · action · arg
                                  ⚠ CORRECTED 2026-08-19 (RI-30, bench-measured): `trigger`
                                  was listed here and is NOT STORED ANYWHERE - `rows[index] =
                                  { sense, action, arg }` (`routes.lua:1057`), and a grep for a
                                  stored trigger across the addon returns nothing. The control
                                  is NOT BUILT (`driver_adaptor_table.md:147`). ★ This is the
                                  table a builder would copy, which is why the bench filed it
                                  rather than leaving it.
    POINT      the place shape    x,y,z · mapID · mapX,mapY,mapC,mapZ · floor · zone,subZone ·
                                  t,gt        (store.lua Point; DR-4 both clocks, DR-33 floor)

**★ THE STORE IS NODE-MAJOR.** Position, reach, band and stage hang off the NODE; rows hang off
the node as a list. This is the shape RI-23 settled the line against — *the node is the unit that
must stand alone* — so the store and the format now agree instead of the line disagreeing with
what is underneath it.

## 3 · THE LAWS THE STORE ALREADY OBEYS — carry these forward, they are not up for redesign

1. **IDENTITY LIVES IN THE KEY AND IS NEVER COPIED INTO THE RECORD.** The RID is the table key and
   is deliberately not also a field: *"a second copy is a thing that can disagree with the first"*
   (`routes.lua:112`, M3). ★ The same law one layer out is `StageOf` — computed, never stored.
2. **PROPERTIES ARE NEVER PART OF A KEY.** Stage and ordinal move when an author restages, so a
   note keyed by them would re-key on every reorder. `Stage:Step` is COMPOSED at export.
3. **TWO NOTE PLANES ARE TWO TABLES, NOT ONE TABLE WITH TWO KEY SHAPES.** *"Then export is a
   FILTER, and a filter is the thing that gets missed"* (`store.lua:471`). A personal note leaking
   into a shared route is made **unreachable** rather than guarded against.
4. **A RUN IS EVIDENCE, A ROUTE IS AUTHORED, A PERSONAL NOTE IS YOURS** (§61) — separate objects,
   separate keys, so a route exports without dragging a capture.
5. **REFUSE RATHER THAN STORE A GHOST.** `AddBeacon` refuses a node with no place
   (`routes.lua:341`), and `Load` refuses a schema above its own.
6. **NO NODE HOLDS ANOTHER NODE'S IDENTITY** (proposition §24). §61 dropped the run
   back-reference; §91 refused `b.complete = <child>`; A2.6 removed `goTo` / `onRamp` outright.

## 4 · THE DEBT, named with a disposition

_From `history/store_inventory.md`: 80 fields written by the two owning modules; 11 have no reader
outside the file that writes them. Nine of those eleven are tool artefacts — locals (`out`,
`stuck`, `satisfied`), a view constructor (`c`, `i` from `routes.lua:591`), vocabulary constants
(`say`, `supertrack`) and correct encapsulation (`routeNotes`, read only through store's own API).
**Two are real.**_

**D-1 · `fireOn` — A RETIRED MECHANISM WITH A LIVE SETTER.** `Routes.SetChildFireOn`
(`routes.lua:1351`) stores `child.fireOn` as `start | update | complete`. **It has no caller
anywhere** — not a pane, not a smoke, not an interface doc. ⚠ And RI-5 ruled the field out:
*"There is NO firing field — G15 IS the during/when-off pairing."*
★ **Disposition: RETIRE, the way A2.6 retired `goTo` and `onRamp`** — removed whole, with
`DropRetired` telling and dropping a stored value on load, not parked. *Half-formed code invites
building on it*, and this one already survived one clean-out.

**D-2 · `author` and `madeAt` — STORED ON EVERY ROUTE, READ BY NOBODY.** Minted at
`routes.lua:121-122` (`UnitName("player")`, `time()`). ⚠ **This is not obviously dead** — RI-4's
export ruling turns on provenance (*"the import landing becomes the new origin"*, *"the origin on
someone else's data does not travel"*), and route-level authorship is exactly the material that
ruling will want. ★ **Disposition: Battlewrath's word.** Either they are the provenance the export
ruling needs, in which case they gain a consumer and a criterion — or they are speculative and go.
**A stored field with no consumer and no named future is the thing this pass exists to find.**

## 5 · WHAT THIS FACT DOES NOT SETTLE

The store is described; the FORMAT is not. Still open and tracked elsewhere: the representation
(proposition G5) · ~~row order as contract (G6)~~ [✓ CLOSED — §A4.15 rules it part of the format,
asserted at ingest and never depended on by the pass. ⚠ Struck one turn after G1 beside it,
which is the same fault twice in one sentence: I fixed the instance I was shown and did not
re-read its neighbours] · ~~the export projection’s wording against A8.6 (G1)~~ [✓ CLOSED — `driver_data_model.md`
§A4.13 rules the export a PROJECTION and A8.6 was reworded to match; this line contradicted
its own companion heading document and is struck] ·
the `Set(N)` / ordinal pickers' missing mint and gap functions (RI-23) · `AddBeacon`'s stageless
precondition. ⚠ **Nothing above should be read as answering any of those.**

---

_How to keep this true: `py addons/tools/emit_store_inventory.py --check` proves the extractor,
then `--out addons/planning/history/store_inventory.md` re-emits the evidence. **If this file and the
emitted one disagree, the emitted one is right.**_
