# UI, FOR THE BENCH — the one door, organised by what you are DOING

_UI specialist, 2026-08-24, at Battlewrath's ask: *"Any doc work to do there? Make it accessible for
Addon creator in their work flow?"*_

★★★ **THIS PAGE IS AN INDEX AND NOTHING ELSE.** Every number and rule below lives somewhere else and
that somewhere is authoritative — *"a HOME is an INDEX, never a second copy; if this page and one of
them disagree, the document is right and this page has drifted"* (AL-26). ⟶ **If you find yourself
reading a value HERE and using it, stop and open the file named beside it.**

## ★★★ THIS IS A DOORWAY, NOT A MANDATE — his ruling, 2026-08-24
> *"I'd make a door way into the content. But not harden the registry into a mandate. You can keep
> improving what is expressable. Dev can impliment and find the edges / limits of the registration.
> You can inspect and make it better and consume it as a kind/form/composition."*
> — Battlewrath, 2026-08-24

    A DOORWAY      the creator can REACH it. Not a gate they must pass.
    NOT A MANDATE  the registry OFFERS; it does not require. A pane that ignores it is not in breach.
    THE LOOP       this seat improves what is EXPRESSABLE
                   -> Dev implements and finds the EDGES / LIMITS of the registration
                   -> this seat INSPECTS those limits, makes it better, and consumes what was built
                      as KIND / FORM / COMPOSITION

★★★ **The registry grows from USE, not from authority.** A mandate would freeze it at whatever this
seat could imagine before anything was built; a doorway lets the limits be FOUND, which is the only
way the expressible set gets bigger. ⟶ It is `AP-13`'s own test turned on the registry itself: a
feedback loop, not a rule that makes success a compliance question.

### ★★ AND THE THREE WORDS ARE THE VOCABULARY — kind · form · composition
    KIND          what a control IS                  edit · dropdown · slider · check
                  ⚠ THE CLIENT'S. Not negotiable, because it is reality.
    FORM          how WE shape its behaviour         commit boundary · response slot · focus on commit
                  Ours. Settled where measured, and always improvable.
    COMPOSITION   units that travel together         input + response · slider + value box
                  Ours, and the layer Dev will find the edges of first.

⟶ **A MEASURED FACT and a SETTLED FORM are not the same standing**, and a door that marks them alike
misleads. A dropdown's art IS asked + 50 — that is the client, and disagreeing with it is being wrong.
That a free-hand field answers in a reserved slot is OURS — available, improvable, and no one is in
breach for doing otherwise.

⟶ So read the tables below as an OFFER with its basis attached. **Where a row is a measured fact it
says so, and disagreeing with it is being wrong about the client. Where it is our FORM, it is
available and improvable — and if you hit its edge, that edge is the most useful thing you can hand
back.**

---

⚠⚠ **AND: MOST OF IT IS NOT RULED.** Rows marked **SETTLED** are measured facts or Battlewrath's rulings; **OPEN** ones are proposals with
an owner named. ★ Neither is a requirement — see the doorway ruling above — but the difference tells
you whether anyone has thought about it yet, which the file names cannot.

---

## ⟶ "I am placing a control on a pane"

| you want | the answer | state | where it lives |
|---|---|---|---|
| a text field that must say it landed | the input **unit**: field + reserved response slot; commit on **Enter**, and **commit CLEARS FOCUS** | OPEN (spec) | `ui_panespec_borrows_spec.md` §4–§5 |
| a multi-line field | the **ACCEPT button is REQUIRED** — Enter makes a newline and cannot commit | **SETTLED** (source) | `concepts/input-commit.md` |
| a dropdown | the **selection IS the commit**; **no response slot** — it cannot be ambiguous | **SETTLED** (his ruling) | `concepts/input-commit.md` |
| a slider | `OnValueChanged` → the USER · **`OnMouseUp` → the RECORD**. Binding the first is what *"weird stalling if it updates per entry"* IS | **SETTLED** (source) | `concepts/input-commit.md` |
| a checkbox | the toggle is the commit; no response slot | **SETTLED** | `concepts/input-commit.md` |
| anything that acts | **no action ends in silence** — but where the result is already visible, that IS the answer | **SETTLED** (his) | `concepts/input-commit.md` |

## ⟶ "I am laying out a pane"

| you want | the answer | state | where |
|---|---|---|---|
| how wide is a dropdown really | its **ART is asked + 50**. Ask 154 to fill a 204 column | **SETTLED** (measured) | `concepts/art-and-rect.md` |
| what shares a row | **pair by declared RELATION, never by fit** — a fit rule gives different neighbours in different states | **SETTLED** (measured) | `concepts/row.md` |
| a tab strip | 3 tabs fit **one row at 240**; a strip is **37px**, two rows 57. `Face·Children·What they are doing` needs **two rows at 240** | **SETTLED** (measured) | `UI_LOG.md` UL-13 |
| sub-tabs | they work; at 240 the inner needs 2 rows and **both strips cost 94 of 220** | **SETTLED** (measured) | `UI_LOG.md` UL-13 |
| **a third row** | **OUT OF SCOPE** — his ruling. Two rows in one group is fine; a third is not | **SETTLED** (his) | `UI_LOG.md` UL-13 |
| collapsing sections | shut costs **24px each**; the object pane is **744 open in a 600 frame** and **328 one-open** | **SETTLED** (measured) | `UI_LOG.md` UL-14 |
| widths as units, not pixels | `Spec.UNIT` + multiples, `x` derived by flow | OPEN (spec) | `ui_panespec_borrows_spec.md` §1 |

## ⟶ "I need a number"

    text width          per-glyph, from the client's own fonts     addons/tools/smoke/text_metric_data.lua
                        ⚠ MACHINE-EMITTED. Never hand-edit; re-run emit_text_metric.py
    the width quantum   q   = 3 * (screenW/screenH) / (10 * uiScale)      UL-11 · 11 configs, 4 resolutions
    the line advance    q_v = 3 * (16/9)          / (10 * uiScale)        UL-10 · one resolution ⚠
    a line's height     advance = round(size / q_v) * q_v                 UL-10 · 11 of 11 fonts
    control heights     Spec.H, and the measured template heights          dungeonrun_interface_inventory.md
    ⚠ `Layout.H` is NOT reconciled against the measured heights - RI-75

## ⟶ "I want to check what I built"

    py addons\\tools\\check_sheet.py              the model against the client, every kind
                              --wrap              where the client breaks a line
                              --tabs              does a strip wrap, and what it costs
                              --collapse          what a section weighs open and shut
                              --controls --art --behaviour --constants
    py addons\\tools\\emit_text_metric.py         re-emit the width model from the client fonts
    py addons\\tools\\check_interface.py          panes against their registers
    in-game:  /coadump r sheet   then  /reload    then the watcher lands it

★ The sheet is the **calibration standard**, and the rule is directional: **calibrate on the sheet,
check your panes with the calibrated model — never the reverse.**

## ⟶ "I am about to invent something"

☐ Owed, with owners, so you do not re-derive them:

    the UNIT REGISTRY - settled units you SELECT rather than re-derive   AI-26 (architect)
    our OWN custom controls, classified kind/form/composition           ui_custom_controls_inventory.md
    the RANGE control - shapes, faults, and a proposal                   ui_range_control_design.md
    the three borrows into panespec - width unit · validate · notify     AL-46, spec is written
    the response slot: top-edge vs same-band                             his to rule (spec §4)
    is a dockable group a LANE or a SURFACE                              AL-47 · AI-24, ruled
    Layout.H vs the measured heights                                     RI-75 (Analyst)
    task_geom's duplicate specimen list                                  RI-75 (Analyst)

⚠⚠ **AND THE ONE THAT COSTS THE MOST WHEN MISSED:** the fork ships its own Ace under
`Interface\\LibraryXML` at minor **infinity**, so **no addon's copy can ever win LibStub** and the
r33 in `Libs/` is NOT what runs. Anything you read in `COA_DungeonRun/Libs/AceGUI-3.0` may not be the
code executing. — `UI_LOG.md` UL-13, `audit/prior_art_ace_field_2026-08-21.md` addendum.

## What this page is NOT
Not a spec, not a ruling, and not a summary you may quote. It is a door: it tells you which room the
answer is in and whether anyone has settled it yet.
