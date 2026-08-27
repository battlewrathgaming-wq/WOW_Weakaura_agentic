# VERIFICATION PASS — five governing docs read whole against their code

_Analyst, 2026-08-27. The first pass under RI-86 ☐2, run as a multi-agent split at Battlewrath's
direction. **Five of the twelve governing docs. Zero stampable.**_

## What this pass was, and what a reader may rest on

**The stamp rule, taken from RI-86 ☐2:** `VERIFIED` means *"I read this document whole against the
code it names, on that date."* Battlewrath chose that over a scoped stamp.

⚠⚠ **EVIDENCE STATUS, STATED RATHER THAN BLURRED — this is the first thing to read.** Each document
was read by a sub-agent under a brief that forbade verdicts, fixes and design opinions, and required
a `file:line` for every claim. **The Analyst then spot-checked a chosen-to-be-refutable sample at
source: 13 of 13 held.** Everything else below carries the reporting agent's evidence and **has NOT
been independently checked by this seat.** ⟶ A line marked ★ is confirmed. A line unmarked is a
work list entry, not an established fact.

★ **Why an agent read can be rested on at all, and where it cannot.** Two agents agreeing share a
prior; an agent plus a human read is the informative case. The calibration doc was read
independently by both, and the sample checks since have not produced a single false divergence.
**That is evidence from a sample, never proof across ~85 findings.**

## ★★★ THE PASS'S OWN FINDING — the docs and the build drift in BOTH directions

Neither can be used as the record of the other, and that is worth more than any single divergence.

**DIRECTION 1 — docs frozen at "NOT BUILT" while the build moved past them.**

    the once|every trigger control   declared unbuilt in THREE governing docs
                                     (data_model:41 · ui_acceptance:308 · and manager's
                                     contract comment) ★ SHIPPED: `panes_decl.lua:176`
                                     declares it, `options.lua:315` bodies it,
                                     `Routes.TRIGGERS` / `SetTrigger` / `TriggerOf` exist
    BUCKET "is not built"            in TWO governing docs (data_model:403 · sense:227),
                                     both saying "TODAY NOTHING RESOLVES"
                                     ★ `Bucket.Build` is `bucket.lua:128`, 643 lines, in the .toc
    the band's ceiling               "DELIBERATELY ABSENT… building 10 would turn a hypothesis
                                     into a bound" (data_model:380)
                                     ★ `routes.lua:1279` ships `BAND_STEPS = { 2.5, 5, 7.5, 10 }`
    A12.5f                           "THIS ROW IS A BUILD ITEM" (manager:518)
                                     shipped at `manager.lua:591`, asserted in the smoke

**DIRECTION 2 — docs asserting guards that do not exist.**

    the per-file-zero SetPoint guard ★ "per-file zero" appears in THREE governing docs
                                     (DRIVER_BASIS · ui_acceptance · ui_scope) and in **ZERO**
                                     files under `addons/tools/`. A10.3j calls it
                                     *"a guard already in place."*

⟶ **One cause behind Direction 1: acceptance docs are written AHEAD of the build and never re-read
after it lands.** Which is exactly what `check_freshness` was built to catch, and why VERIFIED
rather than age is the field that matters.

## ⚠⚠ THE FINDING THAT DOES NOT WAIT — free text on a record

★ **CONFIRMED AT SOURCE.** `driver_data_model.md` row 5 states:

> *"**IDENTIFIERS AND NUMBERS ONLY. No free text anywhere on a record**, `arg` included — it is an
> ID reference. **Nothing to escape, no reserved character to defend.**" (RI-18)*

`routes.lua:1872` ships `note` and `say` as `{ type = "string", source = "user", max = ARG_MAX }` —
**user-typed free text, stored verbatim, up to 255 characters.** `bucket.lua:349` carries it
through. `contract.lua:139` still says `arg` is *"AN ID REFERENCE, never free text"*, so the code
contradicts the model and the contract together.

☐ **What is NOT measured, and must not be assumed:** whether that text reaches an export path. The
FACT is established; the CONSEQUENCE — whether *"nothing to escape, no reserved character to
defend"* is merely wrong on paper or wrong in a way that ships — is the next read, not a conclusion
of this one.

## Per document

### `driver_walk_acceptance.md` — 19 divergences, 5 confirmed
Detail in **RI-88**. ★ The one that matters: `walk.py:883` grades *"a `while` region contributes
nothing to progress"* as `transits(slow and [], b, R)["seg_hits"] == 0`. `slow` is non-empty, so
`slow and []` is `[]` — **the criterion is graded by walking zero rows and cannot fail.**

### `driver_data_model.md` — 18 divergences + ~14 stale citations, 2 confirmed
★ free text on a record (above) · ★ the band ceiling (above) · the trigger back on the row
(`contract.lua:133`, `bucket.lua:438`) against the doc's "MOVED TO THE NODE" · "BUCKET is not built"
· "no mint and no gap function for ordinals" against `Routes.NextOrdinal` (`routes.lua:1053`) and
`OrdinalGaps` (`:1079`) · the fractional-stage rule called "a ruling with no enforcement" while
`bucket.lua:117` enforces it · `RowsOf` called TEST-ONLY with a production caller at `bucket.lua:304`
· the store-inventory field lists short by two receivers.

### `driver_sense_acceptance.md` — 19 divergences, 1 confirmed
★ "BUCKET is not built… TODAY NOTHING RESOLVES" · A11.2e requires `math.huge` be ACCEPTED as an
open band while `rule.lua:75` refuses it and `smoke_rule.lua:86` asserts `Rule.OPEN == nil` — **the
row as written is its own successor ruling reversed, and acting on its MUTATION text would
re-introduce deleted code** · A11.2i's floor set implemented nowhere · A11.1b's "no `Routes.*` from
the driver" against nine such calls in `bucket.lua` · "currently unasserted" for a criterion
`smoke_contract.lua:62` asserts.

### `driver_manager_acceptance.md` — 15 divergences
**The sharpest is not staleness.** `driver_manager_acceptance:460` TEST says *"Set(3) from stage 2
lands on 3, whether or not 3 exists"*; ★ `manager.lua:649` stops the run instead, and ★
`smoke_manager.lua:504` **asserts the opposite of the doc**. ⟶ A builder following that TEST would
break a passing test. Also: A12.5f as an unbuilt build item · two `grades` lines naming functions
that do not implement their criterion (`Sensor.Poll` for listener disarm, `Sensor.Arm` for poll
ordering — both live in `manager.lua`) · "16 `Manager.*` functions" against 18 · "fourteen named
refusals" against 17.

### `driver_ui_acceptance.md` — 14 divergences + 9 of 14 line citations stale
★ the per-file-zero guard (above) · ★ A10.3m "⬜ OWED — THE NODE-LEVEL LATCH HAS NO CONTROL" ·
a pre-live checklist step instructing `When on:Supertrack:here`, an action word `routes.lua:1963`
discards and `routes.lua:303` migrates away · a checklist step naming a readout struck elsewhere in
the same document · the stage/ordinal pickers described with swap, a not-staged tick and a used-set
offer, none of which are shipped · the `Libs/` exemption claimed for three checkers and reported by
one, while `check_interface` uses the non-recursive glob the row forbids.

★★ **AND CITATION ROT IS NOT ONLY IN THE DOCS.** `routes.lua:566` is cited for `child.ordinal = nil`
by the doc, by `options.lua:228`, by `options.lua:262` (as `:1017`) and by `routes.lua:1051` (as
`:566`) — **three different numbers on disk for one line, none of them right** (`:974`).

## The ceiling of this pass

    read          5 of 12 governing docs
    not read      driver_architecture · driver_authoring_acceptance · driver_scoping ·
                  driver_programmatic_model · driver_ui_scope · and ROUTER.md (operations/)
    unreadable    driver_use_case_target · driver_user_journey name NO code. "Read against the
                  code it names" cannot be performed on them; their verification is a different
                  act — does this still describe the product — and it is not this seat's alone.
    not executed  no smoke, mutation or checker was RUN by the reading agents. "A guard does not
                  exist" here means no code implements it, never that it was run and failed.
    not measured  the export path for the free-text finding

⟶ **AND THE NUMBER THAT MATTERS FOR PLANNING: five docs read, five work lists, zero stamps.** RI-88
said the 45 come down at one-per-read-**plus-repair** rather than one-per-read. That held at n=1;
it has now held at n=5.
