# WHAT IS BUILT — the going-forward fact

_Opus 5 (Analyst), 2026-08-19, at Battlewrath's ask. The sibling of `driver_stored_state.md`:
that file says **what is stored**, this one says **what is built** — and, more usefully, which
rulings the code has not reached._

**★ WHY IT EXISTS, in his words:** *"I have temporal memory. Agents don't... everything in it is
true and current unless declared otherwise."* ⚠ A governing document reads as DESCRIPTION when much
of it is PRESCRIPTION. A blind sub-agent asked to reconstruct the data model from code could not
find `Next`, could not find a path to a stageless beacon, and found notes keyed by address where
the model says `NoteID` — three rulings the code has not reached, and nothing marked them.

**★ The evidence under this file is `history/built_state.md`, EMITTED by
`addons/tools/emit_built_state.py`. Never hand-correct it — re-run it.** This file is the curated
half: which bucket, and what closes it.

---

## THE BUCKETS — each one is a different ACTION, which is the only reason to have buckets

    LANDED      in code · reachable from the product · graded · matches the current ruling
                → nothing owed

    OWED        ruled · not in code
                → build it

    UNGUARDED   in code · reachable · nothing grades it
                → write the criterion

    TEST-ONLY   a smoke reaches it · no production path does
                → wire it, or say why it waits

                ⚠⚠ **AND THE BURDEN IS ON THE ARTEFACT (Battlewrath, 2026-08-20):**
                *"Anything on the bench has to prove it's needed in live code. But we
                build from need to function not on precedence. Precedence is the proof
                we can. Not the implementation the addon needs."*
                ★ So TEST-ONLY is not a queue of things to wire — **existing is not a
                reason to ship.** Each row answers *what NEED does this serve in the
                product*, and "it works and it is proven" is not an answer.

    STRANDED    nothing outside its own file names it, not even a smoke
                → door it or remove it

    DIVERGENT   in code · reachable · and it does the SUPERSEDED thing
                → the sharpest, because it looks finished

⚠ **Classify by the most severe that applies.** DIVERGENT > STRANDED > TEST-ONLY > UNGUARDED.
`SetChildFireOn` is both stranded and serving a retired ruling; it files as DIVERGENT.

★★ **TEST-ONLY was not in the first bucket set — the tool's first run produced it.** I had asserted
that `Routes.SetRow` has *"ZERO callers outside `routes.lua`"*; the apparatus refused that and named
`smoke_dungeonrunroutes.lua`. **My grep had covered the addon and not the smokes** — the identical
scope hole `emit_store_inventory.py` had already found and fixed for fields, repeated a day later
for functions. ⟶ *graded but not wired* is a real state, and it reads as finished to anyone opening
the file.

---

## THE COUNT, as emitted 2026-08-20

    286  public functions on the product's own surface (helpers defined in smoke/ excluded)
     31  STRANDED    nothing names them, not even a smoke
     76  TEST-ONLY   a smoke proves the behaviour; no shipped path arrives

    COVERAGE   132 acceptance rows · 23 carry a `grades` line · 17%
    ★ That 17% is the honest ceiling on everything above, and it is printed in the emit so
      nobody reads the UNGUARDED list as a backlog. Most of it is UNMAPPED, not ungraded.
      (Was 4% on 2026-08-19; citations are spreading, which is what makes the UNGUARDED
      list slowly become a real backlog rather than a shrug.)

### ⚠⚠ THE TOOL WAS WRONG A THIRD TIME, and this one hid an entire FILE

★★ **NINE FUNCTIONS WERE INVISIBLE — not stranded, not test-only, ABSENT.** `MODULES` is a
hand-kept allowlist of namespaces, and three product namespaces were never added to it:
**`Rule` (`rule.lua`, the whole P3 driver rule), `Contract` (`contract.lua`, the row contract
A11.1a declares), and `NS` (`core.lua`)**. Every function in them was skipped before any bucket
was computed, so the 2026-08-19 count of 276 was not a measurement of the product.

⚠ **It surfaced only by accident**: a `grades` citation named `Rule.Evaluate`, and the ghost
check — which exists to catch a criterion citing a function that does not exist — refused to
emit. Had nobody cited `rule.lua`, the whole file would still be missing and the emit would
still have said `apparatus OK`.

⟶ **FIXED 2026-08-20 in two parts, and the second is the one that matters.** The three names
were added; then a new `UNLISTED` guard was added so that **a product `.lua` defining a
namespace nobody listed is now a REFUSAL, not a quiet under-count.** ★ It found `Contract` and
`NS` immediately — the two nobody was looking for. ⚠ *A silent allowlist is the same fault this
tool exists to catch: a scope that excludes what would contradict it.*

⚠ **76 test-only is not a defect on its own.** `routes.lua` is the model layer and the panes reach
a subset by design. It is a list to read WITH the rulings, not a queue.

★ **One row in it is worth naming now.** `Routes.StageOf` — A8.1, built to the model's request,
graded by a smoke — has **no production caller**. It is correct, proven, and nothing in the shipped
addon asks it anything, for the same reason `Routes.BeaconAt` does not: the driver that would call
them is not built.

### ⚠⚠ THE TOOL WAS WRONG TWICE BEFORE IT WAS RIGHT, and both corrections are facts about us

1. **TEST-ONLY did not exist as a bucket.** I asserted `Routes.SetRow` had *"ZERO callers outside
   `routes.lua`"*; the apparatus named `smoke_dungeonrunroutes.lua`. My grep had covered the addon
   and not the smokes — **the identical scope hole `emit_store_inventory.py` had already found and
   fixed for fields**, repeated a day later for functions.
2. **It reported `MigrateRIDs` and `DropRetired` as TEST-ONLY, and they run on every load.** Both
   are called by `Routes.Init` (`routes.lua:55-56`), which `core.lua:248` calls on `ADDON_LOADED`.
   ⚠ Excluding a function's own file is right for finding a stranded SURFACE and **wrong for
   deciding what actually runs**; the tool now follows calls within a file from any wired entry
   point, to a fixpoint. That single fix moved 11 functions out of STRANDED and 29 out of TEST-ONLY.

★★ **Neither was caught by reading the emit. Both were caught by checking a row that looked wrong
against the source** — which is the only reason the second one did not become a filed defect
against working code.

## SEEDED ITEMS — verified 2026-08-19, not exhaustive

**OWED**
- the stageless recovery beacon — `AddBeacon` forces a stage (`routes.lua:345-347`); named as a
  precondition of A10.3e's tick
- notes stored by `NoteID` — the store keys the TEXT by address (`routes.lua:1576-1597`)
- `Next` as one field `(Type, arg)` — the code has three mechanisms instead: `b.outcome`
  (`:1527`), `c.role == "set"` (`:1117`), `c.setStage` (`:1135`), and nothing reconciles them
  ⚠ **`ifUnseen` DIES WITH THIS WORK** (Battlewrath, 2026-08-19: *"I'd say die"*).
  `Routes.SetChildIfUnseen` / `ChildIfUnseen` are gated on `role == "set"`
  (`object.lua:466`) and go when the role does. ★ **Completion owns set-idempotence** —
  *"Set has already proven to need to fire once as a part of node completion"* — so the
  guard is replaced, not removed. ⚠ THE TRAP IT WAS BUILT FOR, kept because the code will
  not survive to say it: **a `set stage N` is ABSOLUTE, so re-crossing its node drags the
  run backwards** (`routes.lua:1143`). Order: this removal FOLLOWS `Next` landing.

**UNGUARDED**
- whole-number beacon stages — `SetStage` is a bare `tonumber` and accepts `0.5`, `-5`, `1e400`
  (`routes.lua:1483-1489`); `AddBeacon`'s stage argument passes anything through
- reach and band — `setReach` accepts `1e400` → `Inf`, which is truthy and survives its `or` guard
  (`routes.lua:1210`)

**DIVERGENT**
- the row grammar. `object.lua` calls `SetChildSense` / `SetChildRole` / `SetChildAction` — the
  shape the docs mark superseded — while `SetRow` / `RowsOf`, which the export and the driver are
  specified against, are TEST-ONLY. `adaptor.lua:67-70` says so about itself: *"the old pane is
  LIVE until then."*

**STRANDED (the one that is also divergent)**
- `Routes.SetChildFireOn` — retire whole. ⚠ **Challenged 2026-08-19: "is it not the Trigger?"
  It is not**, and the one-line disposition was too thin to answer that, which is why it was asked.
  Measured:

        fireOn    start | update | complete   `routes.lua:1351` - WHEN the action fires,
                  separate from when the child DETECTS. An axis from the older model.
        ifUnseen  boolean, default TRUE       `routes.lua:1147` - "walk through a location you
                  have already done and nothing happens". ⚠⚠ ~~THIS is Trigger~~ **STRUCK
                  2026-08-19: it is NOT.** `ifUnseen` is gated on `role == "set"`
                  (`object.lua:466`), says so in its own comment, and its only consumer tests
                  the role first. **Trigger is NOT BUILT and has no code term chosen**
                  (`driver_adaptor_table.md:147`). ★ The join was the Analyst's invention and
                  cost an afternoon - RI-27 carries it.

  ⟶ `fireOn`'s job did not move to Trigger — **it was absorbed by the SENSE-WORD on each row**
  (When on · Seen · When off). That is what RI-5 meant by *"there is NO firing field — G15 IS the
  during/when-off pairing."* The retire stands, and now it says what replaced it.

**A GAP THE CHALLENGE FOUND — `Trigger` is joined to `ifUnseen` NOWHERE**
- The model's BEHAVIOUR record carries a `Trigger` field; the store writes `ifUnseen`; **no
  document says they are the same thing.** `driver_expressions.md` calls `ifUnseen` *"a repeat
  guard"* and `dungeonrun_model.md:1018` the same — both predate the label. The label **Trigger
  (One time · Every time)** was set 2026-08-18 and never joined to the field it writes.
- ⚠ `driver_adaptor_table.md` exists to hold exactly this `code : user` pair and has **no row for
  it** — and A5.3 would not catch that, because a vocabulary value with no row is a NOTE by design
  (pass-through is legal, §295). **The one check that could see it is the one ruled not to fail on
  it.** → an adaptor row is owed: `ifUnseen` → *Trigger*.

**LANDED**
- `Routes.DropRetired` (A2.6) and `Routes.MigrateRIDs` (A8.4) — wired through `Routes.Init`,
  each named by a criterion
- `Routes.SetRouteNote` · `Routes.RouteNoteOf` · `Store.RouteNoteTable` (A4.2)
- `Routes.DeleteChild` (A2.5) · `Store.NextRouteId` (A8.4)
- the two note planes as two tables — export cannot become a filter (`store.lua:455-476`)
⚠ ~~`Routes.StageOf`~~ is NOT landed: it is graded and has no production caller, so it files
  as TEST-ONLY. Corrected the same day — this file contradicted its own count block above.

---

## THE MACHINE'S REACH — and the ceiling that is left

✓ ~~GRADED is not mechanical today~~ **BUILT 2026-08-19.** An acceptance row may carry one
indented line naming what it grades:

        grades  Routes.StageOf · Routes.ParentOf

⚠ **An explicit marker, deliberately — not "any backticked name in the row."** These documents
name functions in prose constantly, so an implicit rule would report every row as graded and the
tool would be worse than nothing.

⟶ **Four of the six buckets are now emitted** (landed · unguarded · test-only · stranded). OWED
and DIVERGENT stay hand-kept, because both need a human to say which ruling a piece of code is
serving — no search can.

⚠⚠ **THE CEILING IS NOW COVERAGE, and the emit prints it: 23 of 132 rows, 17%** (2026-08-20; was 5 of 115). A row with no
`grades` line is UNMAPPED, not ungraded, and the tool refuses to guess which. ★ So the UNGUARDED
list is not a backlog yet — **it becomes one as the citations spread, and what is left when the
number stops falling is the real list.** Twenty-three rows carry a citation today (2026-08-20); every one was verified
against `^function` in source before it was written.

⚠ **And two blind spots the tool states about itself:** dispatch through a table is invisible to it,
and a caller inside dead code still counts as a caller. Reachable is not used.

---

_How to keep this true: `py addons/tools/emit_built_state.py --check` proves the apparatus in BOTH
directions — that known-reachable functions come back reachable AND known-stranded ones come back
stranded — then `--out addons/planning/history/built_state.md` re-emits. **If this file and the
emitted one disagree, the emitted one is right.**_
