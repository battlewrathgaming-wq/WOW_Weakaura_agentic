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
- **A10.2 PRECONDITION (RI-16 drained, Battlewrath 2026-08-18: YES)** — the RUNTIME LOOKUP
  (A5.1 · A5.2) exists BEFORE the first fold lands: ONE lookup function over ONE constant table
  on the UI side, `code → user`; a miss passes through the code term (A5.1). `ROLE_TEXT` and
  `SENSE_TEXT` (object.lua) retire INTO it — no private per-file word tables remain. The smoke's
  A5.1/A5.2 rows go from UNCOVERED to filled. Not a deviation from A10.2a (which orders the folds
  among themselves). Provenance — generating the constant from `driver_adaptor_table.md` — is a
  tooling item that FOLLOWS; the fold does not wait on it; until then A5.3's 1:1 check is the
  drift guard. Mutation: a folded label typed as a literal in `options.lua` → A5.3 reds it.
- **A10.2a (corrected 2026-08-18, from the bench's §362 aside)** Order: `object.sense` ·
  `object.ordinal` · `object.note` FIRST — the three the checker cannot see today AND the three
  that SURVIVE into the node editor. **The rest of the object pane (`role / shape / action /
  outcome / unseen`) is NOT folded — it is REPLACED by A10.3's controls**, the old pane live
  until then (A10.2d). Then promoter, then run options. Two jobs, not one: A10.2 folds what
  survives; A10.3 builds the model's shape.
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
- **A10.3a (RI-15 drained 2026-08-18; RI-17 scrubbed)** Per object (beacon childless / child):
  **SENSE — the LOCATION and the behaviour whilst in its R** (select from the SENSE REGISTRY:
  reach here · … only senses that EXIST are offered, each entry carrying what it takes from the
  author; number: reach; range+tick: band up / down; NO boss entry; NO state entry — falling /
  in-combat are GATES, a row condition if ever) → **WHAT I DO** (a STACK of rows — the sense-word on
  each row says WHEN ON / SEEN / WHEN OFF, there is no second column; a row =
  ONE DECLARATION `<sense>:<action>:<arg>` (RI-17 grammar): SENSE-WORD [When on (= while in, on
  me) · Seen (touched me) · When off (pressure off — left the R) — the floor words, model §3b] · ACTION FUNCTION [boss · note · supertracker · say · open list — NOT set / ratchet
  (A2.9: tabs have no sequence, a stage tab would fire on arrival); the author states the
  OUTCOME; engaged NOT offered; a condition is never a field] · ARG [by the action: boss → the
  name picker · note → text]; **fields depend on the action word**; rows are self-completing,
  none triggers another; the row is stored and exported WHOLE) → **NEXT** (in the CHARACTER group
  beside the ORDINAL: dropdown **Next step** (default — the constant; offered ONLY when a greater
  ordinal exists) · **Next stage** (the default for the last step and for a childless beacon) ·
  **Set stage N** (+ its field); fires when ALL tabs are good — A2.7/A2.9; a boss node defaults to Set
  stage = this beacon's next; identity intrinsic · character mutable · behaviour = the actions
  together) → **TRIGGER** (dropdown: One time |
  Every time — the IF SEEN control, labelled *Trigger* so it no longer collides with the sense-word
  *Seen*; Battlewrath 2026-08-18). The stage ratchet reads **Next stage** with its +N field, the
  ordinal's **Next step** — labels with a field, never a control named ratchet. Top to bottom in
  that order.
- **A10.3b** The note field labelled **"Route instructions"** with its ghost text, ≤ ~200,
  under WHAT I DO.
- **A10.3c** The parent's surface (scene manager): the child roster as a REGENERATED per-object
  group (name · ordinal · opacity per row; reorder; up/down; delete guarded for child 1 as
  A2.5) — the WA `__meta` idiom.
- **A10.3d (RI-17)** Conditional visibility EXERCISED by the smoke: set a row's ACTION word to
  `boss` → the name-picker ARG appears on that row; set it to `note` → a text field, the picker
  hides; nothing errors on either. The SENSE dropdown offers no boss value (mutation: add one → the structural
  check fails).
- **A10.3e (RI-23 drained, Battlewrath 2026-08-19)** ★★ **THE NUMERIC DOORS ARE SELECTIONS, AND THE
  ABSENCE IS A TICK BESIDE THE PICKER — NEVER A VALUE IN THE LIST.** His words: *"It gives the offer
  to not be staged. Most likely a tick rather than in the drop down. With some surrounding text as
  why. Same with the child. As seeing 0 in the drop down is offering a self defeating choice."*
  - **THE PICKERS.** `stageBox` and `setBox` read one table — the beacon stage picker offers
    *next whole · the used set* (**whole numbers only**, RI-23, his best working model — see the row below); the
    `Set(N)` picker offers **the used set only**, because a jump target must be a stage that
    EXISTS while a put target is one that does not (§385h). The child `ordBox` is the same
    shape and DOES offer *next decimal*, because ordinals are the author’s choice.
    ~~the stage picker offers next whole · next decimal · the used set~~ [⚠ CORRECTED 2026-08-19:
    written before the whole-only ruling landed in this same row, and left contradicting it.] `radBox / upBox / downBox` are the pre-config menu (§381c, RI-22).
    ★ **The value the picker yields stays a NUMBER** — stage is sorted, compared, incremented and
    typed into an address (`routes.lua:1541 · 1550 · 1529 · 657`), so only the INPUT is a
    selection; the store, the wire and the address are unchanged (Analyst read §3, RI-23).
  - **THE TICK.** Beside the stage picker and beside the ordinal picker, a tick that means *not
    staged* / *not in the ordinal*, with **surrounding text saying why it exists** — the offer is
    the author's form of a state the model already rules: `child.ordinal = nil` *"out of the line,
    on purpose"* (`routes.lua:566`, §311 — still listened to) and the stageless recovery beacon.
    ⚠ **The label and the explanatory text are the naming pass's — no identifier invented here.**
  - **WHY NOT IN THE LIST (his reason, recorded because it generalises):** *"seeing 0 in the drop
    down is offering a self defeating choice."* ★ A list of stage numbers is a list of places in an
    order; `0` is not one of those, it is the statement that this node has no place in the order.
    **Two different acts do not belong in one control.**
  - **THE PROJECTION IS UNCHANGED (§385c):** ticked → `nil` in the STORE → `0` on the LINE. The tick
    is the authoring face of the same fact, and the reader still gets a value rather than an absence.
  - ⚠ **PRECONDITION for the stage half:** `AddBeacon` forces a stage today (`routes.lua:345`,
    *"the stageless RECOVERY beacon has no path in through here either. Owed, no impact yet"*).
    The tick has nowhere to land until that gap closes; the ORDINAL half needs nothing — the store
    already accepts it.
  - **THE SELECTOR'S SCOPE (RI-23, Battlewrath 2026-08-19):** *"We don't derive value from the stage
    table. Just what their store is... This is just an input selector. What stage means and step
    means is in the broader context."* ★ It SHOWS the numbers in use and what sits on each, read from
    the store; it OFFERS next whole · next decimal · the used set; it **derives, resolves, warns and
    validates nothing**, and it never explains what a stage or a step means. ★★ **The value space is
    NON-EXCLUSIVE and that is architectural** — *"1.1 can't be exclusive, if it is, every BID and CID
    needs its own table, which is exponential"* — so ONE selector serves every level (a beacon
    picking a stage, a child picking an ordinal) instead of a private numbering per node.
    ⚠ Co-tenancy is therefore ORDINARY and shown, never flagged: *"within a BID, Child 1 and 2 are
    both on 1.1"* is §90 tell-and-trust at the ordinal level, already shipped
    (`routes.lua:613 · 614 · 628`). **Test:** two children on one ordinal → both appear on that
    row, nothing is refused and nothing is coloured as an error.
  - **WHOLE-NUMBER BEACONS, AUTHOR'S CHOICE FOR CHILDREN (RI-23; Battlewrath’s best working model, 2026-08-19):**
    *"Whole only I think."* A beacon's stage picker offers **whole numbers only** (`1 · 2 · 3 · 4`);
    a child's ordinal picker offers whole numbers **or** ~~`x.xx`~~ **`x.x` — ONE decimal
    place, nine slots per whole (Battlewrath, 2026-08-20)**: *"x.xx is so the choice as
    granular. But maybe too much. .9 might be enough. We're not making a real time combat
    guide. Weak auras and DBM own that."* ★ **It is a SCOPE argument, and it settles the
    reachability problem as a side effect**: the picker offers one above the current in the
    whole or in the decimal, and at one decimal place **every legal value is reachable by
    selection** — no typing, nothing legal-but-unofferable. Under `x.xx` the author could
    reach nine of ninety-nine. — *"I just want to give the author
    choice."* ⚠ ~~The whole-only half needs no guard~~ [CORRECTED 2026-08-19: it needs exactly this
    picker to BE the guard - `AddBeacon`’s stage argument, `SetStage` and the promoter’s
    non-numeric box all accept a fraction today]. The MINT cannot make one: `NextStage`
    (`routes.lua:304`) mints by
    `while used[n] do n = n + 1` and cannot produce anything else. ⚠ **And it is load-bearing, not
    cosmetic** — `Routes.Outcome`'s `+ 1` (`:1529`) and `Routes.Gaps`' integer loop (`:1507`) are
    each correct only while no beacon sits between `n` and `n+1`.
  - **EXPOSE; NEVER CORRECT, NEVER NAG (same ruling):** *"we don't auto-update. We just expose to
    the user they have either a gap or a same. We don't want to baby sit someone working out the
    logical flow of things. That's nagging. We can offer assertions so the choice / guard is
    flattened. Or expose it with help text."* ★ The bench's standing manners already say *nothing
    that nags — the note is PULLED, never pushed*; this is that posture applied to the EDITOR and an
    author rather than to the driver and a player.
    - **the only two forms allowed:** an ASSERTION that flattens the choice (the offer encodes the
      rule, so a wrong pick is not available — which is what the picker already is) · HELP TEXT
      where the state sits.
    - ⚠ **NOT allowed:** a warning, an error colour, a modal, a correction, or any renumber. A gap
      and a same are ORDINARY authoring states (§90, S4 tell-and-trust, `routes.lua:613 · 628`).
    - ⚠ **NOTHING AUTO-UPDATES at either level** — §385e's automatic rebalance is WITHDRAWN.
      Inserting a beacon between 1 and 2 costs the author a renumber they perform themselves, and
      nothing offers to do it; the names index carries their handle across it (§374).
    - **Test:** a route with stages 1 · 2 · 4 shows the gap at 3 and offers 5 — and does not colour,
      warn, or renumber. **mutation:** make the pane renumber or flag on a gap → this row fails.
  - **TESTS.** The stage picker's option list contains no `0` and no empty entry · ticking the stage
    tick leaves `StageOf` nil, ticking the ordinal tick leaves `OrdinalOf` nil, both reached BY
    CLICKS with no typing (A10.7's bar) · the state round-trips through a reload · the `Set(N)`
    picker offers only stages in use.
  - **mutations** put a `0` entry in either picker's list → the option-list assertion fails ·
    remove the tick from the pane → the by-clicks test for the nil state fails on its own message
    (a ruled authoring state made unreachable is the failure this row exists for) · make the
    ordinal picker store an index instead of the number → `OrdinalOf` stops returning what
    `ChildAt` parses and the address test fails.
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
       default; add a WHAT I DO row `When on:Supertrack:here`; Trigger: One time
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
**2026-08-19 — Opus 5 (Analyst) on RI-23.** NEW **A10.3e**: the numeric doors become selections and
the not-staged / not-in-the-ordinal offer is a TICK beside the picker with text saying why, never a
`0` in the list (Battlewrath, 2026-08-19). The value a picker yields stays a NUMBER — only the input
is a selection. ⚠ Its stage half has a PRECONDITION on disk: `AddBeacon` forces a stage
(`routes.lua:345`).

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
