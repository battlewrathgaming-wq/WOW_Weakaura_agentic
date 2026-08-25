# CONCEPT HOME · `row` — what shares a line, and what earns one

_A HOME is an INDEX, never a second copy (AL-26, Battlewrath 2026-08-22: "a home is better than a
run-time cost — it's greppable and inspectable"). It says what the concept IS in a few lines, its
closed list, and POINTS at every place that rules or grades it. The pointed-at documents stay
authoritative; if this page and one of them disagree, the document is right and this page has
drifted. Opened 2026-08-23 by the UI specialist, out of the object-pane reorganisation test._

## WHAT IT IS
A pane is a column of **rows**. A row is as tall as its tallest cell (§101) and carries one or
more controls. Two questions decide a pane's height, and only one of them is arithmetic:

    WHAT SHARES A ROW   pairing — two controls on one line instead of two
    WHAT EARNS A ROW    permanence — whether a control holds its line when it has nothing to say

★ Chrome is the number everyone counts and rarely the one that decides. `object.md` records that
**195 of a child's 575 is chrome** — five zones × 39 for the divider-and-header shape — and the
reorganisation test cut that to **100** with a gold hairline and still came out **99px taller**,
because it gave 14 controls a row each. ⟶ **Pairing dominates chrome.** The furniture is the
visible cost and the row policy is the real one.

## THE CLOSED LIST — how a row is formed

    PAIRED BY RELATION   a control and the thing that answers it (a field and its match; an edit
                         and its check) — declared, and the same in every state
    PAIRED BY FIT        two controls that happen to sum under the column width — ⚠⚠ NEVER
    ALONE                a control wide enough to need the column, or with nothing declared beside it
    CONDITIONAL          a TELL: it takes a row only while it has something to say

> ★★★ **pair by declared relation, never by fit — a fit rule gives a control DIFFERENT NEIGHBOURS
> in different states**, and the object-pane test put `object.delete`, an irreversible button,
> beside `object.ordinal`, a text field, the moment `object.ordinal.match` fell silent. Nothing in
> the declaration said those two belong together; only the arithmetic did.

⚠ That fault is invisible in the emitter and obvious in the render. It is the clearest case this
bench has for the board: prose describing the rule reads fine, and the picture shows a delete
button that has drifted next to somewhere you type.

## ★★★ AND THE ROW LIST IS A TABLE OF CONTENTS — `pane-build` law 10, 2026-08-25
> *"editing the UI is a table of contents rather than trying to justify the UI."*
> — Battlewrath, 2026-08-25

This page names two decisions a pane makes about rows. **Law 10 names what the DOCUMENT recording
them is allowed to contain**: which controls, in what order, and what each is for. ⟶ **Where a
line is arguing for a placement, the placement is in the wrong hands.**

★ The two decisions on this page SURVIVE that, and are the clearest example of what law 10 keeps:
*what shares a row* and *what earns a row* are *declared relations* — meaning, not arithmetic, and
no library can hold them. What law 10 removes is the defence of an x and a width.

★★ THE EVIDENCE is `interface/remote.md` at §665. Its children block carried paragraphs defending
`-82 w50`, a 2px gap *"four off the house GAP of 6"*, and §144's SIX PIXEL OVERLAP shipped live.
The replacement is five lines and three fractions. Full statement and its ✗/✓ in
`concepts/pane-build.md`, law 10.

## ★★★ THE TEST — DID THE SUBJECT CHANGE, OR DID THE SPACE?
Battlewrath, 2026-08-25, settling what this page's *pair by declared relation* is actually
protecting. **Content that reshapes is not the fault. Content that reshapes for no reason the
reader made is.**

    THE SUBJECT CHANGED    the reader NAMED something and it brought its own form.
                           ✓ Correct, and often REQUIRED.
    THE SPACE CHANGED      nothing was chosen; an arithmetic gap closed and a control
                           acquired a neighbour. ✗ The fault this page exists for.

> *"On Weak aura. Trigger one. Then you set what that trigger is. So aura or combat log, and then
> that shapes the content below it. Because each content is specific to what that trigger type
> is."* — Battlewrath, 2026-08-25

★ **Nothing there is predicted.** You picked `aura`, so the fields below are aura fields. The
reader is looking at their own choice read back, not learning a system's habits. ⟶ That is why it
costs nothing, while `object.delete` sliding up beside a text field because `object.ordinal.match`
fell silent costs everything: **same subject, different arrangement, and no choice to trace it to.**

### ★★ AND FOR THE OBJECT PANE, THE SUBJECT IS THE SELECTION
His words, 2026-08-25: *"For the object. The subject is the selection. So a beacon (or child) or a
node on the map from Run. Like a segment starter or a leg position."*

    beacon · child · note · a node from a Run  — a segment starter, a leg position

★★★ **AND THIS IS ALREADY TRUE IN THE SOURCE**, which is the strongest form a ruling gets here:
`interface/object.md:63` records the pane *"reads `Map.Selected()` — the subject, never stored"*,
`object.lua` shapes itself on `p.kind` throughout, and `object.lua:577-582` holds four heights
**by subject** (113 · 169 · 415 · 575). ⟶ The pane was already subject-shaped; what had never
been written down is that **the subject IS the selection**, and that everything below it is that
subject's form rather than a common form being filtered.

### What this settles, and what it does not
✓ A mode or tab swap rebuilding its content is the RIGHT kind - `pane-build` law 2 is this test
  applied to a whole pane, and law 2 requires the teardown for exactly this reason
✓ A selection swap rebuilding the object pane is the same act at the pane's own level
✓ `pane-build` law 10's *table of contents* is what makes it legible: a contents page per subject
  says which controls that subject has, and none of them argues for a position
✗ NOT a licence for Flow to pair by fit. A layout closing a gap is the SPACE changing, and the
  ⚠⚠ NEVER above stands unaltered
✗ NOT a claim that we have this fault today. The remote has ONE conditional control, last and
  full width; the object pane is the surface where it was measured and it has not folded yet
✗ NOT the same question as *is pair-by-relation expressible in AceGUI*. That is still open and
  still unexamined - but it is a MECHANISM question, not a rule question, and it does not need
  answering before a surface folds. `type-or-feature.md` decides whether a custom layout would be
  a TYPE or one pane's feature.

★ THE NODE EDITOR MEETS THIS FIRST. Its trigger/action surface is the WeakAuras shape landing on
our side: the SENSE is the subject, and what it offers below is that sense's form. Pairs with
AI-20/L21's PER SELECTION - an offered default fixed to the WORD picked, *"MEANING, never
SUBJECT"* - which is the same rule one layer down, in values rather than in rows.

## THE TELL — a conditional readout belongs to its control, not to the column
Five of the object pane's eight readouts react to the control above them:

    object.boss.tell        no name — it will not listen
    object.match            another child already claims this role
    object.stagematch       a WARNING, not a readout
    object.ordinal.match    how many others sit here
    object.note.ghost       the ghost line, a separate FontString

Each holds a permanent line for something it only sometimes says. Measured across the object
pane: **86px of permanent height for five conditional lines.** A tell that appears when it speaks
makes the pane bigger exactly when you want the room.

⚠ **NOT a new rule.** `object.md` already records heights-per-subject — a pane whose height
depends on what it is showing is in this design's vocabulary already. This applies it one level
down, from pane to row.

⚠⚠ **AND IT HAS A REAL COST, which is why it is not a recommendation here.** A pane that resizes
while you type **moves controls under the cursor** — the cousin of the *"weird stalling if it
updates per entry"* complaint. Reserving the line and filling it later costs the 86px and moves
nothing. That trade is the Addon creator's to make; this page records both sides, not a verdict.

## WHERE IT IS RULED AND GRADED
    addons/planning/interface/object.md        the subject: zones, heights, the 195-of-575 line,
                                               heights-per-subject, and the three orphans
                                               (object.ordinal · object.note · object.sense) that
                                               no panespec zone manages
    addons/planning/concepts/art-and-rect.md   why a dropdown asks 154 to draw 204 — a row's
                                               width budget is in ART, never in rect
    addons/planning/concepts/pane-build.md     law 10 (the register is a table of contents) and
                                               law 4 (the frame is ours, the content is Ace's) —
                                               together they are why a row list stopped carrying
                                               coordinates at §665
    addons/COA_DungeonRun/widget.lua           the first surface built this way: relative widths
                                               spelling a declared pairing inside `Flow`
    addons/planning/UI_LOG.md  UL-8            the test, its three findings, and the numbers
    addons/tools/PaneBoard/workspace/pane-board/agent-proposals/
        objectpane-2026-08-23-resting.json     24 panes · 588px · tells collapsed
        objectpane-2026-08-23-telling.json     29 panes · 674px · all five speaking

## ⚠⚠ CORRECTED 2026-08-23, FROM SOURCE — the height question was already answered
`object.lua:577-582` holds the pane at a fixed `240 x 600` and records why: *"the wireframe measured
what each subject actually needs — child 575, beacon 415, note 169 — against a pane held at 330."*
And `ui_overhaul_scope.md` had already ruled the conclusion this page reaches the long way round:
**"that is an arrangement decision, not an arithmetic one"** and **"which is exactly what tabs
answer."** ⟶ The pairing-vs-chrome finding below stands on its own measurements; the HEIGHT CONTEST
that produced it was re-running a settled question. Read the scope doc before spending another row
budget here.

## WHAT THIS PAGE DOES NOT CLAIM
It is not a layout spec and does not replace `panespec.lua`. It names two decisions a pane makes
about rows and records what each one measured on one pane. **One pane** — the object pane, for a
child, the fullest subject. Whether pairing-by-relation is expressible in the current panespec is
open and unexamined here.
