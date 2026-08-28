# CODE AND INTENT REVIEW — five governing docs, claim by claim

_Analyst, 2026-08-27. **What agrees, what does not, and who decides each disagreement.**_

★ **WHAT THIS IS FOR** (Battlewrath, 2026-08-27): *"It's good to know what we've built to then
examine it. As 'Tell me what the code does' is broad."* ⟶ This review is bounded where that question
is not: **every line checked is a claim somebody already wrote down**, so it has an edge. And it is
**the readable half of the smoke detectors** — the half that can say a criterion is wrong, which no
detector can say about itself.

## The numbers, which are the output — not the list

    document                          claims   agreed   disagreed
    driver_walk_acceptance.md             84       65          19
    driver_data_model.md                 ~70       52          18
    driver_sense_acceptance.md            47       28          19
    driver_manager_acceptance.md         ~65       50          15
    driver_ui_acceptance.md               58       44          14
    ----------------------------------------------------------------
                                        ~324      239          85   ·  74% agreement

⚠ **THE DENOMINATOR IS INDICATIVE, NOT MEASURED, and it must not be quoted as if it were.** The
counts are the reading agents' own, and *"a claim"* is not defined identically across five reads.
⟶ **What the number is good for is a floor under the finding:** 85 disagreements out of ~324 checked
is a different statement from 85 out of 85, and the first version of this record printed only the 85.
**A review that prints only disagreement cannot tell "the basis is drifted" from "we only looked at
the drifted parts"** — RI-83's denominator lesson, one level up. ☐ If this number is to be tracked
across passes, *claim* has to be pinned first.

## Evidence status — two different things, and they must not be read as one

    the disagreements   found by sub-agents under a facts-only brief (no verdicts, no fixes, a
                        `file:line` per claim, absence claims must state how they searched).
                        ★ The Analyst spot-checked a chosen-to-be-refutable sample at source:
                        **13 of 13 held**, including two absence claims. Everything unmarked
                        below is the agent's evidence, NOT independently checked by this seat.
    the CLASSES         ★★ the Analyst's judgement, and the only part of this file that is.
                        Each says WHO DECIDES, and getting it wrong is the expensive error.

## ★★★ THE FOUR ARBITERS — the class is what makes a disagreement actionable

    FACT       the doc describes a STATE of the build          ⟶ THE CODE DECIDES, always.
               ("not built", "no caller", "16 functions")         Nothing to rule; the doc is
                                                                  behind. Edit or retire it.
    INTENT     the doc states a REQUIREMENT the code does       ⟶ THE DOC DECIDES - it is the
               not meet                                            requirement, the code owes it.
                                                                  ⚠ Whether it is still WANTED
                                                                  is the Designer's, not mine.
    RULED      both assert, and a later dated ruling already    ⟶ THE RULING DECIDES. Not a
               settled it                                          conflict - a doc that never
                                                                  heard. Carry the pointer.
    YOURS      the doc and a PASSING TEST specify different     ⟶ NOBODY HERE DECIDES. A spec
               behaviour                                           and a test that disagree is an
                                                                  unresolved design question in a
                                                                  doc bug's costume.
    CITATION   the pointer no longer resolves to the thing      ⟶ MECHANICAL. No judgement, no
               it names                                            arbiter. Re-aim it.

### ⚠⚠ THE DANGEROUS REPAIR, and it is the one that looks like progress

**Updating a doc to match the code always reads as tidy reconciliation.** If the disagreement was
INTENT, that edit **deletes the only record that the code is wrong.** ⟶ The class must be decided by
READING, never assumed, and the tell is one question: **does this line describe what IS, or what
SHOULD BE?** They look identical on the page and have opposite arbiters.

★ Which sets who may repair. **FACT and CITATION a seat may fix alone.** **INTENT and YOURS must not
be repaired by the seat that found them** — including this one: resolving a requirement against
evidence I gathered is the fork this project keeps away from.

---

# THE DISAGREEMENTS, BY WHO DECIDES

## ⟶ YOURS — 1 item, and it is the only one that blocks

⚠ **RE-CLASSED 2026-08-27, and the correction is instructive.** This section first held TWO. The
second — `driver_sense_acceptance` A11.2e — is **RULED, not YOURS**: its successor ruling A11.2h
sits *in the same document*, so nobody needs to decide, someone needs to carry it forward. ⟶ Filed
to the architect as **AI-43**. ★ The tell for the class was there all along: **a disagreement is
only YOURS when no ruling exists** — and looking for the ruling is part of classing it, not a step
after.

**1 · `driver_manager_acceptance:460` contradicts a passing smoke.** ★ CONFIRMED. The TEST says
*"Set(3) from stage 2 lands on 3, whether or not 3 exists"*. `manager.lua:649` stops the run
instead, and `smoke_manager.lua:504` **asserts the run stops.** ⟶ **Following the doc breaks a
passing test.** One of the two is the product; nothing here says which.

★★ **That one item, plus A11.2e now under RULED, is the review's whole argument for existing.** Both
are rows that would INSTRUCT a builder wrongly rather than merely describe the build wrongly — one
against a passing smoke, one against its own successor. ⟶ **A detector with a stale criterion
detects the wrong thing flawlessly**, and nothing mechanical on this bench can notice.

## ⟶ INTENT — the code owes the doc. ~14 items; the Designer confirms each is still wanted

**★ 1 · No free text on a record — CONFIRMED, and RULED 2026-08-28 (AI-47 → AL-75).** ⟶ **The store
follows the model:** row 5 and `contract.lua:137` stand, `ROW_ARG_RULE` is the drift. ★ **This class
was right and the finding's own headline in RI-89 was not** — it called the doc FALSE while this
entry called the code owing. **A requirement the code does not meet is UNMET, never false**, and the
distinction is the entire reason this file sorts by arbiter. ⟶ Corrected in RI-90's neighbour, struck
rather than deleted.
`driver_data_model` row 5: *"IDENTIFIERS AND NUMBERS ONLY… **Nothing to escape, no reserved
character to defend.**"* `routes.lua:1872` ships `note` and `say` as `{ type = "string", source =
"user", max = ARG_MAX }` — user-typed, verbatim, 255 chars. `contract.lua:139` still says `arg` is
never free text. ☐ **The fact is established; whether that text reaches an export path is NOT
measured** — the difference between wrong on paper and wrong in a way that ships.

**★ 2 · The per-file-zero `SetPoint` guard — CONFIRMED absent.** Named in **three** governing docs
(`DRIVER_BASIS` · `ui_acceptance` · `ui_scope`), present in **zero** files under `addons/tools/`,
and A10.3j calls it *"a guard already in place."*

**3 · A criterion graded by walking zero rows.** `walk.py:883` grades *"a `while` region contributes
nothing to progress"* as `transits(slow and [], b, R)["seg_hits"] == 0`. `slow` is non-empty, so
`slow and []` is `[]` — **it cannot fail.** ★ CONFIRMED.

**4 · The rest, one line each.** A11.2i's floor set `{preceding, current, next}` implemented nowhere
· W3.2(ii)'s jump term required to emit p50/p99/max, `walk.py:1633` prints fixed prose · the three
RFC fixtures loaded and printed but never reaching `ok` · the live-side gap bound (`> 2× POLL_MAX`)
absent from the addon · the seed-once refusal ("the walk refuses an xyz that is not a sample")
never implemented · A11.3a/b's shuffle test with no shuffle anywhere · A11.5a's per-target
first-hit index produced by nothing · two W2 table rows computed and printed but in no comparison
list · "on every fixture" covering two of three · A10.1b's `Libs/` exemption claimed for three
checkers and reported by one, while `check_interface` uses the non-recursive glob the row forbids.

## ⟶ RULED — a later dated ruling already settled it. ~8 items, pointer only

★ **The band's ceiling.** `driver_data_model:380` — *"DELIBERATELY ABSENT… building 10 would turn a
hypothesis into a bound"*. `routes.lua:1279` ships `BAND_STEPS = { 2.5, 5, 7.5, 10 }` under a
ruling dated 2026-08-27 giving its reason. ⟶ The doc predates the ruling.

★ **The trigger's home.** Declared a NODE field *"not a row field"* in `data_model` and
`contract.lua:117`; AL-23 put it back on the row, and `contract.lua:133`, `bucket.lua:438` and
`manager.lua:470` all carry the per-row value. Same doc, both halves.

★ **A11.2e — the row demanding what its own successor deleted.** It requires an explicitly-open
band (`math.huge`) be ACCEPTED, *"identical to nil"*, and its MUTATION says refusing it should bite.
`rule.lua:75` refuses it, `smoke_rule.lua:86` asserts `Rule.OPEN == nil`, and **A11.2h in the same
document** is the ruling that deleted it. ⟶ Acting on the row's mutation text would re-introduce
deleted code. **AI-43** asks the architect to carry the ruling into the row.

**Also:** W7.2's clamp and gap-bound branches, which RI-33 removed from the port (`rule.lua:14`
states it, `smoke_rule.lua:31` asserts it) · A12.4b's *"the adaptor carries none"* against
`adaptor.lua:125` · A10.2a's *"the lane holds ONLY those three"*, which `smoke_dungeonrunoptions:683`
records as **the test being wrong, not the code**.

## ⟶ FACT — the doc is simply behind. ~38 items, no judgement needed

**The dominant class, and one cause behind it: acceptance docs are written AHEAD of the build and
never re-read after it lands.**

    "BUCKET is not built, so TODAY NOTHING RESOLVES"     in TWO governing docs. `Bucket.Build`
                                                        is `bucket.lua:128`, 643 lines, in the .toc
    "the once|every control is NOT BUILT"                in THREE. `panes_decl.lua:176` declares
                                                        it, `options.lua:315` bodies it
    "A12.5f — THIS ROW IS A BUILD ITEM"                  `manager.lua:591`, asserted in the smoke
    "no mint and no gap function for ordinals"           `Routes.NextOrdinal` :1053, `OrdinalGaps`
                                                        :1079
    "a ruling with no enforcement"                       `bucket.lua:117` enforces it
    "RowsOf is TEST-ONLY"                                production caller at `bucket.lua:304`
    "currently unasserted"                               `smoke_contract.lua:62` asserts it
    counts                                               16 Manager functions → 18 · fourteen
                                                        refusals → 17 · six interface files → 7
    the shipped pickers                                  swap, not-staged tick, used-set offer —
                                                        described in A10.3e, none shipped
    a checklist instructing a retired word               `When on:Supertrack:here`, which
                                                        `routes.lua:1963` discards
    "kill" markers, four times                           only "pin" / "start" / "end" exist

⟶ **A large fraction of these are not stale — they are FINISHED.** A row saying *"THIS ROW IS A
BUILD ITEM"* about a thing that shipped and is asserted in a smoke is a closed item nobody closed.
☐ **Whether a shipped acceptance brief is repaired or RETIRED is a ruling this review cannot make,
and it would take most of this class off the board without anyone editing a line.**

## ⟶ CITATION — ~23 pointers that no longer resolve. Mechanical, no arbiter

Concentrated in `driver_data_model` (~14) and `driver_ui_acceptance` (9 of 14 checked). Examples:
`NextStage :304 → :576` · `AddBeacon :347 → :615` · `SetStage :1483 → :2469` · `R_FLOOR :1184 →
:1236` · `Routes.List :335-341 → :504` · `Routes.Outcome :1529 → :2523`.

★★ **AND IT IS NOT ONLY IN THE DOCS.** `child.ordinal = nil` is cited as `routes.lua:566` by the
doc, as `:1017` by `options.lua:228`, and as `:566` by `routes.lua:1051` — **three numbers on disk
for one line, none of them right** (`:974`). `bucket.lua:138` and `rule.lua:47` each carry a stale
cite copied from a doc. ⟶ A citation is a claim, and this bench has been copying wrong ones between
code and docs in both directions.

---

## The ceiling of this review

    read            5 of 12 governing docs
    not read        driver_architecture · driver_authoring_acceptance · driver_scoping ·
                    driver_programmatic_model · driver_ui_scope · operations/ROUTER.md
    unreadable      driver_use_case_target · driver_user_journey name NO code. "Read against the
                    code it names" cannot be performed; their review is a different act — does
                    this still describe the product — and it is not this seat's alone.
    not executed    no smoke, mutation or checker was RUN by the reading agents. "A guard does
                    not exist" means no code implements it, never that it was run and failed.
    not measured    the export path for the free-text finding
    not verified    85 disagreements found, 13 spot-checked. The other 72 carry evidence and
                    have not been independently confirmed by this seat.

⟶ **AND THE PASS DID NOT PRODUCE A SINGLE STAMP, which is the expected shape rather than a
shortfall.** A doc that reconciles yields a stamp and nothing else; a doc that does not yields
findings. **The stamp is what you get when there is nothing to say.**
