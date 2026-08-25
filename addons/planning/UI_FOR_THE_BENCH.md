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

## ★★★ HOW TO READ EVERY NUMBER ON THIS PAGE — his distinction, 2026-08-24
> *"We'll allow for the largest content needed in the unified surface. But a distinction: Your
> measure is against the panes today. Where an overhaul with these new methods of display lets the
> pane show differently. We now have collapse and tabs. And soon scroll when we address that."*

    THE RULING        the unified surface allows for the LARGEST CONTENT NEEDED
    THE DISTINCTION   a measurement is of the pane AS IT IS. It is not a constraint on the pane
                      AS IT WILL BE, because the overhaul changes what a pane needs to show at once.

⟶ **This corrects a reading this seat published the same day.** I measured Curation and Promotion at
320 (content 284) against Object at 240 (content 204) and concluded *"someone loses 80"*. **That
holds only if the panes keep today's arrangement**, and the whole point of the overhaul is that they
do not. ⚠ `ui_overhaul_scope.md` says it in its own words — *"the port IS a redesign"* and *"tabs are
a partition, and you cannot partition content you have not got"*.

### THE THREE DEVICES THAT CHANGE WHAT A PANE NEEDS
    COLLAPSE   MEASURED - `UL-14`: the object pane is 744 open, 328 one-open, 120 shut.
               A section costs 24px closed.
    TABS       MEASURED - `UL-13`: a strip is 37px; three tabs fit one row at 240.
    SCROLL     ⚠ NOT MEASURED, AND NOT BUILT. `prior_art_ace_field_2026-08-21.md` §6a:
               we ship 13 of the 17 widget types AceConfigDialog constructs, and
               **`ScrollFrame` is missing and load-bearing** - every AceGUI-direct addon uses
               one for a pane taller than its frame.

★ **So two of the three are numbers and the third is a hole**, and the hole is the one that most
changes a height budget. Until `ScrollFrame` exists, any statement about what fits is a statement
about a pane that cannot scroll.

⚠⚠ **AND THE BOUNDARY OF THE INSTRUMENT, stated plainly:** the sheet measures what IS. It cannot
measure what a rearranged pane WILL need, because that arrangement does not exist to measure. ⟶ A
number here answers *does this fit today*; it never answers *must the design be this way*.

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

## ⚠⚠ A PANE THAT CAN SCROLL HAS **TWO WIDTHS** — `UL-21`, 2026-08-24
Every content width on this page (`object` 204, `curation` 284) is a **no-bar** width. A scrollbar
appears the moment content reaches `viewport + 2` and **takes 20 off the usable width**
(`AceGUIContainer-ScrollFrame.lua` :102, :114, :117).

    content just UNDER the viewport   ⟶ no bar   ⟶ the width on this page
    content just OVER  the viewport   ⟶ a bar    ⟶ that width MINUS 20

⚠ **And the narrower one wraps taller**: measured over sheet five's model, **about one text cell in
seven gains a line** at 204→184 and 244→224. ⟶ So content that was only just too tall gets *taller*
when the bar appears. Budget the **minus-20** width for anything that might scroll.
★ Check it yourself: `py addons/tools/check_sheet.py --scroll`.

## ⟶ "I need the SETTLED BEHAVIOUR of a control kind"
_Capability, not implementation. Each answer comes from a rule already ruled, and none of them names
a pane or a field._

| the question | the settled answer | from |
|---|---|---|
| a control whose KIND is swapped by another's value — what happens to a value already typed? | **it is KEPT**, and restored if the kind swaps back; where it cannot be represented it is **pending, never lost** | UL-6 · UL-18 |
| a picker fed from data, and the data is EMPTY | **present, disabled, carrying its reason** — absent is silence, and disabled-without-a-reason is silence in a grey tint | UL-18 |
| a stepper over presets — cycle or hold at the ends? | **HOLD**, except where the sequence is cyclic *in meaning*; wrapping a bounded quantity is a silent jump to the opposite extreme | UL-18 |
| a quantity a 2D map cannot express (a vertical band) | **a READOUT, not a drawn ring** — do not draw what you cannot mean | UL-18 |
| does this thing belong in the registry at all? | **two citable instances**, ours or the field; a refusal counts against; disagreement beats agreement | `concepts/type-or-feature.md` |

## ⟶ "I am building a pane" — read this BEFORE the layout table below

**`concepts/pane-build.md`** — nine laws in two halves, and the line between them is a **DRAW**.

    CONSTRUCTION   answerable OFFLINE, before anything runs
      1 width flows DOWN, never up        2 a content swap is a TEARDOWN, not a mutation
      3 the layout is a DECLARATION, READ 4 placement within is the library's (Flow/List/Fill/Table)
      5 never argue a size from a measurement
    RENDERING      only answerable in-client
      6 a rect is unresolved until drawn - report DEFERRED, never 0
      7 geometry is on a quantum grid - compare with tolerance, NEVER `==`
      8 a scrolling pane has TWO widths      9 two natures, and a run must serve both

⚠ **Three of the four rendering laws return a plausible WRONG rather than an error** — a zero, a
FALSE and an empty pane all look like results. That is why they are written down.

### ★★★ AND YOU ALREADY DO LAW 1 CORRECTLY — it is your code, not ours
`COA_DungeonRun/options.lua:188-193`:

    paneSeat:SetLayout("Fill")
    paneSeat:SetWidth(PANE_W); paneSeat:SetHeight(mh)
    dlg:Open(ADDON, paneSeat)

⟶ That is **WeakAuras' own structure** (`OptionsFrames/OptionsFrame.lua:1197-1231` + `Fill` at
`AceGUI-3.0.lua:665-674`): a fixed width above, `Fill` pushing it down, the dialog building inside.
★ **So the outer pane width on the lanes is already stable**, and the scrollbar's ±20 moves only the
inner column. **Start from this, not from a rebuild.** — `UL-30`

⚠ **What nobody has answered, and it is yours:** `object.lua` builds RAW `CreateFrame` children with
hand-typed widths (`:582` 240, `:605` 192, `:614` 204), not AceGUI children. **Does that subtree sit
inside the `paneSeat`'s `Fill` guarantee, or beside it?** It decides whether law 1 reaches the object
pane at all, and this seat will not guess at your structure.

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

    py addons\\tools\\check_layout.py            ★ OVERLAP · OVERHANG · CONTAINMENT, offline,
                                                before a client ever runs. Exit 1 = findings.
                                                ⟶ Fronted by the `layout` SKILL, and STANDING
                                                PRACTICE on sheet work. Run it the moment you
                                                type an x, a y or a SetPoint offset - not at
                                                review, when the wrong pane is already on screen.
    py addons\\tools\\check_sheet.py              the model against the client, every kind
                              --wrap              where the client breaks a line
                              --tabs              does a strip wrap, and what it costs
                              --collapse          what a section weighs open and shut
                              --range             the player's walk, offline
                              --scroll            what a scrollbar costs, and the CLIFF
                              --controls --art --behaviour --constants
    py addons\\tools\\emit_text_metric.py         re-emit the width model from the client fonts
    py addons\\tools\\check_interface.py          panes against their registers
    in-game:  ⚠ A RUN MEASURES ONE PAGE - a full sweep is three commands, not one
              /coadump r sheet1    specimens - text · wrap · controls · art
              /coadump r sheet2    devices   - tabs · collapse · range · scroll
              /coadump r sheet3    prototypes
              then /reload; the watcher lands it. `sheet` alone is page 1.

★ The sheet is the **calibration standard**, and the rule is directional: **calibrate on the sheet,
check your panes with the calibrated model — never the reverse.**

## ⟶ "I am about to invent something"

☐ Owed, with owners, so you do not re-derive them:

    the UNIT REGISTRY - settled units you SELECT rather than re-derive   AI-26 (architect)
    our OWN custom controls, classified kind/form/composition           ui_custom_controls_inventory.md
    the RANGE control - shapes, faults, and a proposal                   ui_range_control_design.md
    the three borrows into panespec - width unit · validate · notify     AL-46, spec is written
    the response slot: top-edge vs same-band                             his to rule (spec §4)
    ⛔ THE GUTTER, A or B - do NOT implement either yet                   HIS CALL, UNMADE
       A flips the inner width by 20 when a bar appears (upstream's behaviour); B reserves
       it always. ⚠ B's price is measured and it is HEIGHT, not width: a permanent extra
       text line on content that never scrolls. UL-22 posed it · UL-29 costed it · UL-30
       showed the Fill architecture makes it smaller than it looked. Prototype on sheet3.
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
