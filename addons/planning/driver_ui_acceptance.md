# Dungeon Run — UI REWORK acceptance (A10.x) — the test brief the bench builds towards

_Analyst, 2026-08-18. Battlewrath: "I'd prefer to get the UI something reasonable before I live
test (menu / command fatigue)." So the bar is ONE sentence — **the author's whole flow is doable
by CLICKS ALONE, in a frame that renders under the harness first** — and every row below is a
piece of that sentence. Governed by `driver_ui_scope.md` (fork A′ · tabs as lanes · primary frame
first, panes one at a time · knock-out later). Each row names its mutation; a green without its
mutation is UNMUTATED. The Analyst tests under the harness on landing; Battlewrath live-tests
only after A10.7's checklist is green offline._

---

## THE BAR — "reasonable" defined so it can be tested

    reasonable   =  no slash command in the author's flow · every step reachable by click ·
                    the pane says what it does in the author's words · nothing hand-placed the
                    checker cannot see · the frame renders offline before it renders live

## A10.1 · THE PRIMARY FRAME renders — under the harness first
- **A10.1a** One frame: COMMAND STRIP (map context · open chips · close map) · MAP SURFACE ·
  MAP CONTROL (pan · zoom) · the UNIFIED INPUT PANE as an Ace **TabGroup** with three lanes —
  **run · promoter · node editor** — one page live at a time. Empty lanes acceptable at first
  render. **The option table is SUBTREES KEYED BY LANE (`args.run / args.promote / args.node`,
  each with its own `args`) — never one flat table** (bench R1, accepted: the diagram's three
  lanes and three knocked-out columns are the same three groups in two containers; subtree keeps
  knock-out a container swap later, flat makes it a rebuild). Test: AceConfigRegistry validates;
  a structural check asserts three top-level groups and nothing at the root beside them.
- **A10.1b** Built from Ace3 **r960** shipped in Dungeon Run under `addons/COA_DungeonRun/Libs/`
  (the convention GuardianPlates already uses; LibStub) — Registry + Dialog + AceGUI core WHOLE;
  **widget files: TabGroup · SimpleGroup · InlineGroup · Label · Heading · Button · EditBox ·
  CheckBox · Dropdown (+ Dropdown-Items) · Slider · and WINDOW** (bench U1, accepted: one file
  now keeps knock-out cheap later). r960 is MEASURED, not merely revision-matched: modern-
  r1403's AceConfigDialog fails to load here (line 589). Dungeon Routes ships none.
  **`Libs/` is an EXPLICIT, REPORTED exemption** in `check_targets` / `check_interface` / the
  adaptor checks (bench U5): vendored code is exempt AND counted ("N vendored files exempt"),
  never silently skipped by a non-recursive listdir.
- **A10.1c** Renders under `lua51` in the harness (`PerformLayout` runs); `check_rects` reads the
  resulting rects on the CORRECT canvas (A9.6). **"Zero overlaps" is defined (bench U2, (a)
  accepted): SIBLINGS ONLY, recursively — compare within each parent, walk down; PLUS a
  CONTAINMENT assert — every child rect within its parent's rect (a clipped widget is a fault);
  leaves at template size.** Nothing off-frame. The text-metrics sweep reports "N verified · M
  unverifiable" by name. **FrameXML Lua the harness needs (`UIPanelTemplates.lua` etc.) is
  LOADED WHOLE from the archive, falling back to stubs only where a file will not run — and
  every stubbed Blizzard function is REPORTED by name in the same unverifiable list** (bench
  U6, (c) accepted: a stubbed function is a blind spot of the same class as a text metric).
- **A10.1d** Opening the frame needs no typed command the author must already know: one door
  (the existing map door / remote button) — a slash alias may exist, it is not the surface.
- **mutations** remove a lane → the checker reports two, not three · shrink the canvas → red on
  a control now outside · perturb the string-width stub → the moved rects appear in the
  unverifiable list · load without the Ace copy → a LOUD failure naming the missing lib.

## A10.2 · FOLDING — hand-placed controls become Ace-readable, one pane at a time
- **A10.2a** Order: `object.sense` · `object.ordinal` · `object.note` FIRST (the three the checker
  cannot see today), then the rest of `object.lua`, then promoter, then run options.
- **A10.2b** Each folded control is an option-table entry (`type · name · order · hidden ·
  values · get/set`); its label resolves through the ADAPTOR (A5.x); pass-through shows the code
  term, never blank.
- **A10.2c** Per pane, when its fold is complete: **PER-FILE ZERO — the folded pane's file contains
  NO literal `SetPoint` at all** (bench U3, (b) accepted: cannot rot, needs no comment anchor);
  during transition an ALLOWLIST names the files not yet folded and SHRINKS to empty, its count
  reported (c). The interface file (`interface/*.md`) still reconciles 1:1 (`check_interface`).
- **A10.2d** The old hand-built pane keeps working until its fold lands (both, not or); nothing
  is torn down to start.
- **mutations** leave one declared control hand-placed → A10.2c's grep finds it · remove an
  adaptor row → the control still renders (code term) and the checker reports the row.

## A10.3 · THE NODE EDITOR lane — the model's three items, as controls, in data-flow order
- **A10.3a** Per object (beacon childless / child): **SENSE** (select: reach here · boss engaged
  ⟨name⟩ · boss killed ⟨name⟩ · …; number: reach; range+tick: band up / down; boss-name select
  HIDDEN unless a boss sense) → **WHAT I DO** (two rows, DURING | WHEN OFF: update note · set
  supertracker · advance · set stage N) → **IF SEEN** (toggle: once | every). Top to bottom in
  that order.
- **A10.3b** The note field labelled **"Route instructions"** with its ghost text, ≤ ~200,
  under WHAT I DO.
- **A10.3c** The parent's surface (scene manager): the child roster as a REGENERATED per-object
  group (name · ordinal · opacity per row; reorder; up/down; delete guarded for child 1 as
  A2.5) — the WA `__meta` idiom.
- **A10.3d** Conditional visibility EXERCISED by the smoke: choose a boss sense → the name picker
  appears; choose reach → it hides; nothing errors on either.
- **mutations** swap SENSE and WHAT I DO order → A10.3a fails · make the picker always visible →
  A10.3d fails · delete child 1 with siblings → told, not removed.

## A10.4 · TELL, NEVER LOCK — editing posture
- **A10.4a** No modal, no "click me" mid-edit: collisions (two beacons on a stage, two children
  on an ordinal, no boss name) are TOLD inline (red text / chip) and the author keeps typing.
- **A10.4b** `StaticPopup` only for record acts the model already rules for it (delete a route).
- **mutation** make a stage collision raise a modal → A10.4a fails.

## A10.5 · THE TEST DRIVE REMOTE — a control you can see
- **A10.5a** A visible remote in Dungeon Run: select route · arm · go / stop · a readout with
  `hit · skip · false_advances` (never `stage` alone). No slash line required to reach it.
- **A10.5b** Its first proof (A6.1) runs from it: advance on just a boss kill against a landed
  capture.
- **mutation** hide the readout → A10.5a fails; expose `stage` alone → fails.

## A10.6 · WHAT IS OUT (so nothing is graded that was never asked)
    knock-out (dock/undock) · visual style · the personal-note pane · export/import doors ·
    the consumer's slots · the map's rendering internals · naming-pass words beyond what the
    adaptor already carries

## A10.7 · BATTLEWRATH'S PRE-LIVE CHECKLIST — clicks only, no typing (the gate to live testing)
_Green offline first (harness render + checker), then he does this in the client by clicks._
    1  open the map from its door — no slash line
    2  load a run in the RUN lane (dropdown / list)
    3  play / scrub it — EXISTING playback (editor.lua's envelope / play / skip) reached by click
       from the RUN lane; not new work (bench R2)
    4  right-click a run node → promote node lite → a beacon exists
    5  select the beacon in the NODE EDITOR lane; set SENSE reach here + a reach; leave band at
       default; add a WHAT I DO: point the tracker; IF SEEN once
    6  add a child; give it an ordinal; give it a Route instructions note; see it in the roster
    7  create a stage collision on purpose → see the tell; nothing pops
    8  open the TEST DRIVE remote; select the route; arm; go; see hit / skip / false_advances
       move; stop
    Every step by click. If any step needs a typed command he must already know, the row that
    owns that step is RED. **MIXED STATE IS FINE** (bench U4, (a) accepted — A10.2d already
    permits it and the brief exists to start live testing sooner): the checklist may run with
    some panes folded and others still hand-built; the REVIEW LOG records WHICH panes were folded
    when it ran, so a green is dated to a state.

---

## REVIEW LOG
**2026-08-18 — Analyst on the bench's `driver_ui_proposition.md` (b87b559).** Accepted and folded
into the rows above: R1 subtrees keyed by lane (A10.1a) · R2 step 3 = existing playback from a
new door (A10.7) · R3 old pane live during fold (A10.2d) · U1 ship Window + the named widget
subset (A10.1b) · U2 overlaps = siblings recursively + containment (A10.1c) · U3 per-file zero
SetPoint with a shrinking allowlist (A10.2c) · U4 mixed state fine, dated in this log (A10.7)
· U5 `Libs/` explicit reported exemption (A10.1b) · U6 FrameXML Lua loaded whole, stubs reported
by name (A10.1c). Build order P1–P6 accepted as proposed (P3 before P5; P4 before P5 — the blind
spot named before folds inherit it). A9.6's row was reworded §351 (their §5 note is answered).
The proposition may leave.

_How I test: harness render + `check_rects` + the smokes on landing; apply each named mutation;
report PASS / FAIL / UNMUTATED with the observed message. Battlewrath's checklist (A10.7) is the
only live step, and it runs only after A10.1–A10.5 are green offline._
