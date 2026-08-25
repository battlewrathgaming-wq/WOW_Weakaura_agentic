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

## ⚠⚠ RAISED, NOT RESOLVED — ACEGUI'S `Flow` PAIRS BY FIT, WHICH THIS PAGE FORBIDS
Recorded by the **Addon creator**, 2026-08-25, on folding the remote onto AceGUI (§665). It is a
disagreement between a live rule and a live build, so it is FILED rather than fixed either way.

    THIS PAGE       PAIRED BY FIT — ⚠⚠ NEVER. A fit rule gives a control DIFFERENT
                    NEIGHBOURS in different states.
    ACEGUI `Flow`   places controls left to right and wraps when the next one does not
                    fit. That IS pairing by fit, as the layout's whole mechanism.

★ THE OBJECT-PANE FAULT THIS RULE WAS WRITTEN FOR IS REACHABLE UNDER `Flow`. `object.delete`, an
irreversible button, landed beside `object.ordinal`, a text field, the moment `object.ordinal.match`
fell silent — and a Flow layout with a CONDITIONAL child does exactly that, because the row it
wraps at moves when a sibling stops taking width.

★★ THE REMOTE DOES NOT HIT IT, and the reason is the point: its footer trio is pinned by
**relative width** — `options 0.32 · map 0.30 · arm 0.36`, summing under 1 — so the three share a
line because they were DECLARED to, not because they happened to fit. Relative widths are how a
declared pairing is spelled inside `Flow`. ⚠ But that is a discipline the builder applies, not
something the layout enforces: full-width children above and below it are what keep the trio from
acquiring a neighbour, and nothing checks that.

☐ **THE OPEN QUESTION, and it is not mine to answer alone:** is *pair by declared relation*
expressible in AceGUI at all, or does it need a layout of our own? This page already records that
*"whether pairing-by-relation is expressible in the current panespec is open and unexamined"* —
⟶ the same question now has a second, larger subject, and the five hand-placed surfaces meet it
the moment they fold. `type-or-feature.md` is the test that decides whether a custom layout is a
TYPE or one pane's feature.
⚠ **No code moved on account of this.** A doc disagreement is filed as an acceptance item, never
resolved by mutating the thing it disagrees with.

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
