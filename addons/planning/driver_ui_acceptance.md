# Dungeon Run — UI REWORK acceptance (A10.x) — the test brief the bench builds towards

_Analyst, 2026-08-18. Battlewrath: "I'd prefer to get the UI something reasonable before I live
test (menu / command fatigue)." So the bar is ONE sentence — **the author's whole flow is doable
by CLICKS ALONE, in a frame that renders under the harness first** — and every row below is a
piece of that sentence. Governed by `driver_ui_scope.md` (fork A′ · tabs as lanes · primary frame
first, panes one at a time · dock/undock later). Each row names its mutation; a green without its
mutation is UNMUTATED. The Analyst tests under the harness on landing; Battlewrath live-tests
only after A10.7's checklist is green offline._

---

## THE BAR — "reasonable" defined so it can be tested

    reasonable   =  no slash command in the author's flow · every step reachable by click ·
                    the pane says what it does in the author's words · nothing hand-placed the
                    checker cannot see · the frame renders offline before it renders live

## A10.1 · THE PRIMARY FRAME renders — under the harness first
- **A10.1a ✅ BUILT (drained from the citation queue 2026-08-24 — PROVEN BY MUTATION, not by reading)** One frame: COMMAND STRIP (map context · open chips · close map) · MAP SURFACE ·
  MAP CONTROL (pan · zoom) · the UNIFIED INPUT PANE as an Ace **TabGroup** with three lanes —
  **run · promoter · node editor** — one page live at a time. Empty lanes acceptable at first
  render. **The option table is SUBTREES KEYED BY LANE (`args.curate / args.promote / args.node`,
  each with its own `args`) — never one flat table** (bench R1, accepted: the diagram's three
  lanes and three UNDOCKED columns are the same three groups in two containers; subtree keeps
  DOCK/UNDOCK a container swap later, flat makes it a rebuild — ⚠ RENAMED 2026-08-21, this row
  read *knock-out* until then). Test: AceConfigRegistry validates;
  a structural check asserts three top-level groups and nothing at the root beside them.
      ⚠ `run` → `curate` 2026-08-25 (AL-56, from AI-31; RI-80.1). The code renamed it —
      `options.lua:119` cites the ruling in place and `:133` is the key — and this row was NAMED as
      riding that rename and did not. ★ The other two lanes were always right: `promote` and `node`
      match the code, so the drift was ONE word of three, which is the kind that reads as fine.
      grades  Options.Table · Options.Lanes
  TEST: register the frame's option table -> AceConfigRegistry validates, and a structural check finds
  exactly THREE top-level groups keyed `args.curate` / `args.promote` / `args.node`, each with its own
  `args`, and nothing at the root beside them.
  MUTATION: flatten the three lanes into one root `args` -> the three-groups check reports one;
  remove a lane -> it reports two.
  ⟶ SILENT OTHERWISE: the table drifts flat, dock/undock silently becomes a REBUILD rather than a
  container swap, and nothing fails until that job starts.
      FOUR mutations, all BITE (`options.lua`, `smoke_dungeonrunoptions`): *THE ROOT DOES NOT
      HOLD THREE LANES* · *SOMETHING SITS AT THE ROOT BESIDE THE LANES* · *SEATING RESIZED THE
      MAP* · *A MAP WAS SEATED INTO A CONTAINER NARROWER THAN ITSELF*.
      ★ The last two are the silent-scale faults the row exists to prevent.


- **A10.1b** Built from Ace3 **r960** shipped in Dungeon Run under `addons/COA_DungeonRun/Libs/`
  (the convention GuardianPlates already uses; LibStub) — Registry + Dialog + AceGUI core WHOLE;
  **widget files: TabGroup · SimpleGroup · InlineGroup · Label · Heading · Button · EditBox ·
  CheckBox · Dropdown (+ Dropdown-Items) · Slider · and WINDOW** (bench U1, accepted: one file
  now keeps DOCK/UNDOCK cheap later). r960 is MEASURED, not merely revision-matched: modern-
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
- **A10.2 ✅ BUILT (drained from the citation queue 2026-08-24 — PROVEN BY MUTATION, not by reading) PRECONDITION (RI-16 drained, Battlewrath 2026-08-18: YES)** — the RUNTIME LOOKUP
  (A5.1 · A5.2) exists BEFORE the first fold lands: ONE lookup function over ONE constant table
  on the UI side, `code → user`; a miss passes through the code term (A5.1). `ROLE_TEXT` and
  `SENSE_TEXT` (object.lua) retire INTO it — no private per-file word tables remain. The smoke's
  A5.1/A5.2 rows go from UNCOVERED to filled. Not a deviation from A10.2a (which orders the folds
  among themselves). Provenance — generating the constant from `driver_adaptor_table.md` — is a
  tooling item that FOLLOWS; the fold does not wait on it; until then A5.3's 1:1 check is the
  drift guard. Mutation: a folded label typed as a literal in `options.lua` → A5.3 reds it.
⚠⚠⚠ **A10.2a's TWO HALVES SHARE A HEIGHT BUDGET, AND THE ROW DID NOT SAY SO — added 2026-08-21
(RI-46, measured by BUILDING it).** *"A10.2 folds what survives; A10.3 builds the model's shape"*
reads as two independent jobs in a stated order. **They share 600 pixels**, which is `object.lua`'s
real pane height and not a test constant.

    ~~THE PANE FOR 'child' NEEDS 714, PAST THE 600 CEILING~~
    THE PANE FOR 'child' NEEDS 575, AND THE CEILING IS 600 — IT FITS

⚠⚠ **714 IS DEAD AND WAS SUPERSEDED TWICE (staleness sweep, 2026-08-21).**
`planning/interface/object.md` — the probe's own record — now reads **child = 575**, against
`object.lua`'s real 600 ceiling.

    714    RI-46's original figure, an ESTIMATE
    535    §446, MEASURED by the probe
    ~649   §449's PREDICTION for "once A10.2a's three land"
    575    what A10.2a's three actually cost, MEASURED

⟶ **575 < 600. The child pane fits, and the ceiling problem does not exist.** ★ Three of the four
numbers were superseded by the next one and every doc kept the first.

⟶ Folding the three ADDS ~114px of declaration while the replacement that would REMOVE
`role / shape / reach / action / outcome / unseen` has not happened — and **A10.2d forbids taking
them out first** (*nothing is torn down to start*). **So the order as written cannot be executed at
the current height**, and that is a coupling in this row rather than a fault in the bench's build.

⚠ **THE CHOICE IS BATTLEWRATH'S AND IS OPEN (RI-46):** default some zones folded (the bench's
read — the mechanism landed §444) · grow the pane · or fold-and-replace as one step. ★ **The
first is taste** — a pane that opens mostly closed is a different product from one that opens
showing its work — and taste is the one thing the bench does not own.

★ **AND THE BENCH REVERTED ITS DECLARATION RATHER THAN LAND A RED SMOKE**, which is the right
call and worth naming: *"a red suite stops being information the second it is normal."*
      grades  Adaptor.Word · Adaptor.Has
  TEST: after the first fold, `ROLE_TEXT` and `SENSE_TEXT` no longer exist in `object.lua`, every
  folded label resolves through the ONE lookup, a miss passes through the code term, and no private
  per-file word table remains.
  MUTATION: type a folded label as a literal in `options.lua` -> A5.3's 1:1 check reds it; keep a
  private per-file word table -> the no-private-tables assert bites.
  ⟶ SILENT OTHERWISE: a second private word table drifts out of step with the adaptor and one pane
  shows an old word forever.
      ONE mutation and it BITES. ⚠ A single guard is thinner evidence than three — recorded as
      such rather than levelled up.


- **A10.2a (corrected 2026-08-18, from the bench's §362 aside)** Order: `object.sense` ·
  `object.ordinal` · `object.note` FIRST — the three the checker cannot see today AND the three
  that SURVIVE into the node editor. **The rest of the object pane (`role / shape / action /
  outcome / unseen`) is NOT folded — it is REPLACED by A10.3's controls**
  ✅★ **AND THAT ORDERING NOW HAS A MECHANICAL REASON RATHER THAN A STATED ONE (AL-14, 2026-08-21).**
  The record/surface join was measured: of `interface/object.md`'s **37 controls**, 9 are
  stored-and-surfaced, 4 are stored-not-surfaced, **5 are SURFACED-NOT-STORED** — `role · shape ·
  match · unseen · answers` — and 14 in total carry no record field.
  ⟶ **The controls this row says are REPLACED are the ones that are NOT IN THE RECORD.** A
  control with no field has nothing to fold TO. ★ The ordering was written from taste in
  2026-08-18 and the measurement arrived at it independently three days later — which is the
  strongest corroboration this project gets., the old pane live
  until then (A10.2d). Then promoter, then run options. Two jobs, not one: A10.2 folds what
  survives; A10.3 builds the model's shape.
- **A10.2b — ⚠⚠ ANSWERED 2026-08-21 (RI-45, the bench's question; reading **(b)**, and the
  ambiguity was the Analyst's).** Each folded control is **DECLARED, NOT HAND-PLACED, with a
  get/set per control** — that is the PROPERTY this row names.
  ★ **IT DOES NOT NAME ACE'S OPTION TABLE.** The original wrote Ace's field list word for word
  (`type · name · order · hidden · values · get/set`) and so read as a mandate for that library's
  shape. **`panespec.lua`'s `Spec` — zones / subjects / cells — satisfies the property**, is
  BUILT, and is checked 1:1 by `check_interface`.
  ⟶ **Which renderer the pane uses is the BENCH's** (mechanism is gears; intelligence is in the
  design). ⚠ And the burden runs the other way: `Spec` is built and checked, so an Ace options
  table would have to show why it is NEEDED — *existing is not a reason to ship*, and neither is
  a field list matching Ace's wording.
  ~~Each folded control is an option-table entry (`type · name · order · hidden ·
  values · get/set`);~~ its label resolves through the ADAPTOR (A5.x); pass-through shows the code
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
  author; number: reach; range+tick: ~~band up / down~~ **band, UPWARD ONLY**; NO boss entry;
  NO state entry — falling /
  ⚠ **CORRECTED 2026-08-22 (DRILL 3 · B9): `bandDown` was RETIRED at RI-22** — one upward value,
  not a pair, because a captured sample IS the floor (ROUTER 280) and downward tolerance measures
  nothing. The pair form is named here only as the retired shape.
  ⟶ falling /
  in-combat are GATES, a row condition if ever) → **WHAT I DO** (a STACK of rows — the sense-word on
  each row says WHEN ON / SEEN / WHEN OFF, there is no second column; a row =
  ONE DECLARATION `<sense>:<action>:<arg>` (RI-17 grammar): SENSE-WORD [When on (= while in, on
  me) · Seen (touched me) · When off (pressure off — left the R) — the floor words, model §3b] · ACTION FUNCTION [**boss · note · say** — the live set;
  ~~supertracker~~ ⚠ `supertrack` RETIRED as an action 2026-08-22 (AL-19 · DR_Content_20): it is the node's **LED TO tick**, a characteristic. Named here as the retired term, never offered. · NOT set / ratchet
  ⚠⚠ **AND THE LIST SHOULD NOT BE HERE AT ALL (DR_Content_20 · DR_Process_18, 2026-08-22).** A row that ENUMERATES a
  vocabulary is a second copy of it, and this one went stale exactly that way. **The source is
  `Routes.ROW_ACTIONS`**; the words above are illustrative of the SHAPE and are not the offer.
  ⟶ When DR_Content_20's single source lands, this bracket points at it and stops listing.
  (A2.9: tabs have no sequence, a stage tab would fire on arrival); the author states the
  OUTCOME; engaged NOT offered; a condition is never a field] · ARG [by the action: boss → the
  name picker · note → text]; **fields depend on the action word**; rows are self-completing,
  none triggers another; the row is stored and exported WHOLE) → **NEXT** (in the CHARACTER group
  beside the ORDINAL: dropdown **Next step** (default — the constant; offered ONLY when a greater
  ordinal exists) · **Next stage** (the default for the last step and for a childless beacon) ·
  **Set stage N** (+ its field); fires when ALL tabs are good — A2.7/A2.9; a boss node defaults to Set
  stage = this beacon's next; identity intrinsic · character mutable · behaviour = the actions
  together) → **TRIGGER** ✅ **IN THIS PASS, WITH THE NODE'S OTHER FIELDS, NEVER SEPARATELY**
  (AL-14, 2026-08-21). ★ It is a NODE field (`contract.lua:87-90`); its USER LABEL is already ruled
  (*Trigger*: One time · Every time, adaptor row); its **CODE TERM is the bench's the day it
  lands** — the adaptor row reserves it and the Analyst invents nothing.
  (dropdown: One time |
  Every time — the IF SEEN control, labelled *Trigger* so it no longer collides with the sense-word
  ⚠⚠ **WHAT THE TWO LABELS MEAN, 2026-08-20 (RI-27):** the axis is **run again AFTER
  COMPLETING**, not fire-once-per-entry. *One time* = a completed node does not run again;
  *Every time* = it does. ★ Retrying while INCOMPLETE is the default behaviour and is not
  this control — completion ends it, and the ratchet bounds it for anything in the
  sequence. **Default is One time**; the course-corrector opts into Every time.
  ⚠ Read as per-entry, this control looks like it would stop a boss tab re-arming when the
  player steps out of the circle mid-fight. It does not, and that reading is what the
  distinction above exists to prevent.
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
      grades  Routes.SetRow
  TEST: set a row's ACTION word to `boss` -> the name-picker ARG appears on that row; set it to `note`
  -> a text field appears and the picker hides; neither errors, and the SENSE dropdown offers no boss value.
  MUTATION: add a boss value to the SENSE list -> the structural check fails.
  ⟶ SILENT OTHERWISE: the picker stays visible on a note row and the author fills an arg that nothing
  will ever read.

- **A10.3e-R ✅ BUILT (drained from the citation queue 2026-08-24 — PROVEN BY MUTATION, not by reading) — THE STANDING R IS 5, DEFAULTED AND ENFORCED AT THE PICKER** (Battlewrath,
  2026-08-21): *"A default 5 yards R is expected. Enforced at the picker. We can have that the
  standing R. Reason: We have a resolution concern. poll at 0.1 at R5 is already our floor before
  failure."*

      the PICKER offers 5 as its DEFAULT and its FLOOR — the same shape as the band's 2.5,
      which is minimum and default at once (RI-35)

  ★★★ **AND THE REASON IS ARITHMETIC ALREADY ON RECORD, not a preference.** `R_min =
  v_ceiling × POLL_MIN / 2 = 100 × 0.1 / 2 = **5**`. At R = 5 the diameter is 10 yd and the
  fastest thing the project calls travel (`TELEPORT_VMAX` 100) covers exactly that in one 0.1 s
  step. ⟶ **Below R = 5 the poll floor stops guaranteeing a sample inside the node.** R, the poll
  floor and the travel ceiling are ONE relationship; move any and the others move (DR_Sensor_3).

  ⚠⚠ **AND R IS NOT THE BAND — the asymmetry is deliberate, so nobody "fixes" it later:**

      BAND   nil means *the author did not pick* → the consumer RESOLVES 2.5 (RI-2, model row 27,
             `bucket.lua:198`). A tolerance has a safe default.
      R      nil means *this node has no reach* → `Bucket.Build` **REFUSES**, named
             (`bucket.lua:179-181`). **There is no safe default for how big a thing is**, and a
             node that cannot be sensed is not a node the run can use.

  ⟶ So the picker DEFAULTS it and the bucket still REFUSES nil — because once the picker ships,
  a nil radius can only mean pre-picker data, which is exactly what a refusal should say.
      grades  Bucket.Build
  TEST: mint a child, touch nothing → its radius is 5 and the route builds.
  MUTATION: let the picker offer below 5 → pick 2, and the grazing fixtures at the 0.1 floor start
  missing — which is the resolution concern made testable rather than asserted.
      grades  Routes.R_FLOOR · Routes.StepR · Routes.AddBeacon
  TEST: mint a beacon through the shipped door -> its radius is `R_FLOOR` (5) without the author
  touching it; drive the picker below 5 -> it clamps to 5 and never offers less.
  MUTATION: mint with no radius -> `Bucket.Build` must still REFUSE nil (A10.3e-R is explicit that
  the default does not retire the refusal: once the default ships, a nil radius can only mean
  pre-default data, which is exactly what a refusal should say).
  ⟶ SILENT OTHERWISE: a node smaller than the poll floor can be crossed BETWEEN samples, so it
  simply never fires and nothing reports a miss.
  ⚠ CORRECTED ON LANDING: the bulk pass matched `A10.3e-R` as `A10.3e` (the id regex stopped at the
  hyphen) and gave this row the PICKER's test. Two rows, one block — caught by reading the landing
  report rather than by any check.
      TWO mutations, both BITE: *A MINTED BEACON MUST CARRY THE STANDING R*
      (`smoke_dungeonrunroutes`) and *A MINTED CHILD MUST CARRY THE STANDING R* (`smoke_drive`).
      ★ Both halves of the row are covered — the beacon AND the child.


- **A10.3l — THE OFFERED DEFAULT IS SHOWN, AND FLIPPING IT IS ONE CLICK** (AL-35, Battlewrath:
  *"I'd lean in authored. They have different use cases."*).
      IS      each ACTION WORD carries an OFFERED DEFAULT for its tab's latch — **boss → Every
              time** (you can safely wipe and retry) · **say → Once** (in a wipe it is the last
              instruction carried to the group, the play fresh in memory) · note → the bench
              proposes. The control shows that default **already selected**, and changing it is
              one click.
      IS NOT  ⚠⚠ **NOT DERIVED FROM THE ACTION.** The architect's read — the node latch computed
              from the tabs, never surfaced — is **STRUCK**. His reason is the row:
              *"that hides the setters, which is not programmatic."*
              ⟶ A hidden derivation is one **the author cannot see or overturn**; an offered
              default is the same convenience **with the setter in view.** The WA idiom.
      ★★ AND IT SATISFIES THE #1 RULE WITHOUT REMOVING A CONTROL. `plays-by-flattening-decisions`
      says *encode the rule, never add a choice* — and here the rule is encoded **in the DEFAULT**
      rather than by deleting the picker. **The decision load falls; the control stays.**
      grades  the tab's trigger control · the per-action default declaration (the bench's)
      ORDER   ← A10.3k (the picker must exist before a default can be shown in it).
  TEST: add a `boss` tab → its latch reads **Every time** without the author touching it; add a
  `say` tab → **Once**; flip either → one click, and the stored value is the flipped one.
  MUTATION: derive the latch from the action word instead of defaulting it → flipping becomes
  impossible, and the row bites on the control having no effect.
  MUTATION: default every tab to Once regardless of action → the boss case regresses to *one
  chance to kill it*, which is the case AL-23 was ruled from.

- **A10.3m ⬜ OWED — THE NODE-LEVEL LATCH HAS NO CONTROL** (AL-35: *"the node-level control stays
  and is owed"*).
      IS      the second latch — per STEP/STAGE — is AUTHORED like the first, and needs its own
              control on the node (not the tab).
      IS NOT  **NOT the tab's control read twice**, and not derived from the tabs (A10.3l).
      grades  the node pane's latch control
      ORDER   ← A10.3k. ⚠ Independent of A10.3l — a tab default says nothing about the node.
  TEST: a node's latch is settable and stored independently of any tab's.
  MUTATION: bind the two latches to one control → the boss-Every / node-Once combination becomes
  unauthorable, and that combination is the ordinary case (retry the fight; the stage completes once).

- **A10.3k — `Trigger` IS A SELECTION, AND THE EXCEPTION IS AN OPTION IN IT** (Battlewrath,
  2026-08-21): *"I'd say build in the trigger case. Make it an exception by selection, not by
  many states of the same UI."*

      ⚠⚠ **CORRECTED 2026-08-22 (DRILL 3 · B2): TWO CONTROLS, NOT ONE.** This row said *a
                      NODE field, not a row field* — §4b's wording before AL-23. **AL-23 rules a
                      latch PER TAB (on the BEHAVIOUR record) and one PER STEP/STAGE**, each a
                      closed two-value list defaulting to Once.
      EACH CONTROL    a closed two-value list, defaulting to the common case. ★ The *"one picker,
                      not many states"* ruling holds per latch — it was never a claim that there
                      is only one latch.
      THE WORDS       **One time · Every time** — ★ ALREADY DECLARED, not invented here
                      (`contract.lua`'s `trigger` note). Only the stored id is unchosen, and
                      that is the bench's.
      NOT BY STATE    no tick-plus-mode, no pair of controls that combine, and **no derivation
                      from the node's shape.** The exception is PICKED.

  ★★★ **AND THIS DRAWS A BOUNDARY AGAINST THE `Next` LANDING OF THE SAME DAY, which is the whole
  reason the row is worth having.** RI-49 landed `Next`'s absence as **DERIVED from position** —
  and the obvious next move is to derive `Trigger` the same way, from the node's shape. **His
  ruling says no.**

      Next      DERIVED    a DEFAULT. Every node has one; the question is only which.
      Trigger   SELECTED   an EXCEPTION. Most nodes never want it, so someone must ask for it.

  ⟶ **A default may be inferred; an exception must be chosen.** ★ That is the distinction, and it
  is why one field computes from position and its neighbour does not.

  ⚠ **THE CONCRETE CONSEQUENCE, and it moves the bench's own worked example:** the wrong-way node
  (*"step 0, sense when on, act update note, 'Wrong way, turn back'"*) re-fires today only because
  nothing is built. Under this ruling it re-fires because **its author SELECTED `Every time`** —
  RI-27's *"course correct is a catch all"*, which named this node as the opt-in case a day before
  it was demonstrated.
      IS NOT  ⚠⚠ **NOT DERIVED FROM POSITION**, which is the obvious next move after `Next`
              landed as a derivation the same day — and Battlewrath's ruling says no.
              RI-27 is why it cannot be: a recovery beacon (*"must not re-set once consumed"*)
              and a course-correct marker (*"should speak whenever you are there"*) are **the
              same shape at the same position and want opposite answers.**
              AND NOT two controls that combine — no tick-plus-mode.
      grades  the node pane's trigger control · Routes (the setter, unnamed)
      ORDER   nothing blocks it. → A12.4b, which needs the picker before a non-default `Trigger`
              is authorable at all.
  TEST: the node pane offers `Trigger` as ONE picker with two options; a node authored without
  touching it reads as the common case; the wrong-way marker is expressed by SELECTING the other.
  MUTATION: express the exception as two controls that combine (a tick plus a mode) → **exactly
  one declared control writes `trigger`** fails on the second one existing at all, which is the
  fault rather than its effect. ★ `check_interface`'s 1:1 registry join is what makes that
  countable rather than eyeballed.

- **A10.3e (RI-23 drained, Battlewrath 2026-08-19)** ★★ **THE NUMERIC DOORS ARE SELECTIONS, AND THE
  ABSENCE IS A TICK BESIDE THE PICKER — NEVER A VALUE IN THE LIST.** His words: *"It gives the offer
  to not be staged. Most likely a tick rather than in the drop down. With some surrounding text as
  why. Same with the child. As seeing 0 in the drop down is offering a self defeating choice."*
  - **THE PICKERS (R7 refined, 2026-08-21: choosing a USED position SWAPS the two occupants — the
    picker is the act; positions are dense: +1 or swap, nothing else — A2.10).** `stageBox` and `setBox` read one table — the beacon stage picker offers
    *next whole · the used set (= swap targets)* (**whole numbers only**, RI-23, his best working model — see the row below); the
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
  - ~~⚠ **PRECONDITION for the stage half:** `AddBeacon` forces a stage today.~~
    ✅ **THE PRECONDITION IS GONE (staleness sweep, 2026-08-21) — S7 LANDED (§395).** `Routes.AddBeacon`
    takes `0` as THE STAGELESS REQUEST and stores `nil`. ⚠⚠ **AND THE DOC WAS NOT AT FAULT: THE SOURCE
    WAS.** `routes.lua:474-475` still carries *"⚠ ALWAYS A STAGE … the stageless RECOVERY beacon has no
    path in through here either. Owed, no impact yet"* — **and the comment block immediately BELOW it
    is S7 explaining the path that was added**, with the code six lines further down. ⟶ A superseded
    comment left sitting above its own replacement, quoted verbatim into **four** planning documents as
    a live blocker. ★ **The doc quoted faithfully; the source lied** — which is the one failure mode
    "the source is truth" cannot catch. **The dead comment is the bench's to remove.**
    The ORDINAL half needs nothing — the store
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
      grades  Routes.NextStage · Routes.Gaps · Routes.NextOrdinal · Routes.OrdinalGaps · Routes.StageOrder
  TEST: the beacon stage picker offers next-whole plus the used set and nothing else — no `0`, no
  decimals; the `Set(N)` picker offers the used set ONLY; the child ordinal picker also offers next
  decimal; ticking "not staged" stores `nil` and the line still projects `0`.
  MUTATION: put `0` in the stage dropdown instead of the tick -> the never-offers-zero assert bites;
  offer a decimal in the stage picker -> the whole-only assert bites; let `Set(N)` offer an unused
  stage -> the exists-target assert bites.
  ⟶ SILENT OTHERWISE: an author picks `0` meaning "not staged", the store takes a NUMBER where it
  needed nil, and the node arms in bucket 0 instead of being out of the order.

- **mutations** swap SENSE and WHAT I DO order → A10.3a fails · make the picker always visible →
  A10.3d fails · delete child 1 with siblings → told, not removed.

### ⟶ A10.3f–j · THE PANE'S SHAPE — tabs added by choice, and one pane that folds

_NEW 2026-08-21. ★ **Chain 1 LEADS under the build principle (§7, AL-12), and this was its largest
step with no acceptance at all** — nothing in this brief mentioned a tab strip, an add control, a
fold, or tab-in-tab. Battlewrath's definition of "WA coded", verbatim:_

> *"Coded in the generic sense. Not using their code. But the tabs, tone, ace computed padding. And
> the universal pane with fold in / fold out. Tab in tab displays. (Tab: Object options :
> Beacon/child : Tab 1 action tab 2 action (Building new tab as choice, rather than limited tabs.)"*
> — and the correction that followed: *"Trigger has meaning. So Action 1, add action, action 2."*

⚠ **THE IDIOM, GENERICALLY — NOT THEIR CODE.** Nothing is imported, copied or linked. What
transfers is the SHAPE; the vocabulary is ours (A10.3h).

- **A10.3f — ONE UNIVERSAL PANE, FOLD IN / FOLD OUT.** Not a pane per object kind. A section
  folds to its header and back, and folding changes nothing about what is stored.
  TEST: fold every section, reselect the object, unfold → every value is as it was.
  MUTATION: rebuild the section on unfold from defaults → a set value is lost and the test bites.

- **A10.3g — TAB IN TAB, and the nesting is the model's own shape:**

        Tab: Object options
          └ Beacon / child
              ├ Action 1
              └ Action 2

  ★ The outer tab is the OBJECT's; the inner strip is its BEHAVIOUR rows. **That is row 1 of the
  data model drawn as a surface** — one CHARACTERISTIC record per node, N BEHAVIOUR records under it.
  TEST: select a child with two rows → two inner tabs, and the outer tab's fields are the node's.
  MUTATION: put a node field (`R`, `Band`, `Next`) on an inner tab → it would be stored per row,
  which model row 4 forbids (*"NODE FIELDS APPEAR ONCE"*), and this row bites.

- **A10.3h ★★ TABS ARE ADDED BY CHOICE: `Action 1 · add action · Action 2`.** **Not a fixed set**,
  and **not the word "Trigger"** — `Trigger` is ours already and means something else: a NODE field,
  One time · Every time (`contract.lua:87-90`, *"a NODE field, not a row field"*).
  ⚠ **The shape transfers, the vocabulary does not** — the naming law catching a collision before
  the surface exists rather than after.
  TEST: add three actions, remove the second → the remaining two are Action 1 and Action 2, in order.
  MUTATION: cap the strip at a fixed count → the third add is refused and this row bites.

- **A10.3i — THE STRIP IS THE ROW ARRAY, AND `SetRow`'S INDEX IS THE TAB NUMBER.**
  ⚠⚠ **AND IT CANNOT CLOSE ALONE — IT DEPENDS ON A10.3g/h (RI-45, 2026-08-21).** `SetRow`
  *"writes the whole declaration or it writes nothing"* (RI-17): it needs a valid SENSE **and** a
  valid ACTION. ⚠ `object.lua` today offers them as **two independent dropdowns**, so routing each
  through `SetRow` would silently drop the author's first pick — against A10.4a (*TELL, never
  lock*).
  ★ **WITH THE STRIP THE QUESTION DOES NOT ARISE: a tab is added as a UNIT**, so a row is
  complete when it exists. ⟶ **E-0's author side closes with A10.3g/h, not before**, and nobody
  should invent a half-authored-row policy to close it early.
  ★ The container exists: `AceGUIContainer-TabGroup.lua` is vendored in the TOC (RI-45).
      grades  Routes.SetRow · Routes.RowsOf
  ★ **Corroboration, not invention:** `Routes.SetRow(b, child, index, sense, action, arg, offered)`
  already takes an index, and clearing a row (`sense == nil and action == nil`) already does
  `table.remove(rows, index)` — **add and remove map onto the setter that exists.** A fixed pane
  would never have needed the argument; the setter has been waiting for this surface.
  ⟶ This row is where the AUTHOR'S SIDE OF §E-0 CLOSES: `object.lua` stops calling the three flat
  setters and calls `SetRow`, which gains its first product caller (line item L1.4).
  TEST: author two actions → `RowsOf(child)` returns two rows in tab order; the bucket built from
  that route arms with two behaviour rows, not zero.
  MUTATION: keep writing `child.sense` alongside → both shapes exist on one object and the bucket
  still reads only `rows`; the test's count assertion catches the divergence.

- **A10.3j — THE STRIP OBEYS A10.2c: NO LITERAL `SetPoint` IN THE FOLDED FILE.** A dynamic tab
  count is exactly where hand-placed offsets creep back (`-276 - (i-1) * 22` is the current
  roster's shape). **Ace computes the padding; the strip declares its entries.**
  TEST: add a tab → nothing in the file computes a Y offset; `check_interface` still reconciles 1:1.
  MUTATION: place tab N at a computed offset → A10.2c's per-file zero reds before this row does,
  which is the right order for a guard already in place.

⚠ **NOT GRADED HERE, deliberately:** TONE, wording, and the art are the naming pass's. These rows
fix what the surface must DO and what it must never store.

## A10.4 · TELL, NEVER LOCK — editing posture
- **A10.4a** No modal, no "click me" mid-edit: collisions (two beacons on a stage, two children
  on an ordinal, no boss name) are TOLD inline (red text / chip) and the author keeps typing.
- **A10.4b** `StaticPopup` only for record acts the model already rules for it (delete a route).
      kind  RULING — it shapes A10.4a rather than gating: it names the ONE class of act (record acts
      the model already rules for it, e.g. delete a route) that is exempt from *tell, never lock*.
      ⟶ DECLARED UNINSTRUMENTABLE: **a wrongly-placed modal is the LOUDEST possible failure**, never a
      silent one, so the rule (*silently wrong + a place it lives*) does not reach it.
      ⚠ THE TWO PASSES SPLIT HERE — one called it a criterion. The loudness test decided it.

- **mutation** make a stage collision raise a modal → A10.4a fails.

## A10.5 · THE TEST DRIVE REMOTE — a control you can see
⚠⚠ **A10.5's READOUT COLUMNS ARE STALE TWICE OVER — corrected 2026-08-21 (AI-2 audit).**
`hit · skip · false_advances` were ruled STAGE-LEVEL and **V2-only** by A11.5a, and A11.5's own
REVIEW LOG recorded that correction — so this brief has been behind since 2026-08-19.
⟶ **V1's readout is: per sample the set of addresses the player is IN; per target its FIRST-HIT
sample index.** `stage` is not a result at either level. ★ A10.7 step 8 repeats the same three
columns and moves with this.

- **A10.5a** A visible remote in Dungeon Run: select route · arm · go / stop · **a readout of
  the IN SET BY ADDRESS per sample, and per target its FIRST-HIT sample index** (never `stage`
  alone). No slash line required to reach it. ⚠ ~~`hit · skip · false_advances`~~ — corrected
  2026-08-21; those are stage-level and V2-only (A11.5a).
  ★★ **AND THIS IS THE AUTHOR'S DIAGNOSTICS, NOT THE READER'S DISPLAY** (AL-6). A reader in
  flight sees no hit counts at all — see A10.8.
- **A10.5b** Its first proof (A6.1) runs from it: advance on just a boss kill against a landed
  capture.
  TEST: A6.1's proof driven from the VISIBLE REMOTE — select route, arm, replay a landed capture
  carrying the boss name and `UNIT_DIED` -> the stage advances on the kill alone, with no slash line used.
  MUTATION: prove the advance only through the smoke harness and leave the remote unwired -> the
  from-the-remote assert bites on the dead button.
  ⟶ SILENT OTHERWISE: the advance works in the harness while the author's actual door does nothing,
  and the wiring rots unnoticed because the smoke is still green.
  ⚠ No `grades` line: the door is `Drive.BossDown` in `drive.lua`, outside the addon's graded surface.
  ⚠ THE TWO PASSES SPLIT HERE — one called it a ruling. The silent failure above is why it is not.

- **mutation** hide the readout → A10.5a fails; expose `stage` alone → fails.

## A10.9 · THE FRAME'S STRUCTURE — one surface, a bolted-on panel, and visibility that is DERIVED

_NEW 2026-08-21. Battlewrath, giving the structure after producing the layout diagram:_

> *"Structurally. We can argue. Map and its controls are one surface. Bolted on is the side panel
> that shows its tabs, plus dynamically hides them when they are in another stand alone pane. And
> then when all tabs are in stand alone panes, then it hides itself. Maybe replaces with a strip
> that gives the illusion of collapsed."*

✅ **NO LONGER WRITTEN AHEAD — DOCK/UNDOCK IS NOW (Battlewrath, 2026-08-21, D-C overturned).**
~~Dock/undock is `driver_ui_scope.md` D-C: "later. Chrome, not data flow."~~
and A10.6 lists it under WHAT IS OUT. ⟶ **These rows do not bring that job forward.** Whether it moves from a LATER job to a NOW job
is RI-46's open question, and Battlewrath's. They exist so the shape is gradeable the day it
does move, and because two decisions were already taken to keep it cheap (A10.1a's subtrees, A10.1b's vendored WINDOW).

★★★ **THE INTENT, AND IT IS THE OPPOSITE OF WHAT A KNOCK-OUT FEATURE USUALLY MEANS**
(Battlewrath, 2026-08-21): *"Flatten it to one mechanism for now. The intent is so we are not
leaving interfaces all over the users UI. That is can be self containing or not."*

    SELF-CONTAINING IS THE DEFAULT AND THE POINT. Knock-out is the OPT-OUT, for an author who
    wants a piece placed — not an invitation to scatter panels across the screen.

⟶ **So the design goal is CONTAINMENT, and the feature is the escape hatch.** ⚠ That inverts how
the rows below should be read: a frame that ends up with six floating panels has not used the
feature well, it has lost the property the feature exists to protect.

✅ **ONE MECHANISM, FLATTENED 2026-08-21.** The Analyst had marked the map control's
*drag off* and a tab group's *undock* as possibly two mechanisms. **They are one:** dock /
undock (`driver_ui_scope.md:132`, *a CONTAINER behaviour*). Affordances may differ later; the
behaviour does not, and nothing below may assume two.

⚠⚠ **AND THE INTENT PUTS A10.9c UNDER TENSION — named, not resolved.** If the panel HIDES when the
last tab is UNDOCKED, and nothing stands in its place, **there is no way back** — and a frame
you cannot re-contain has permanently sprawled, which is the one outcome the intent forbids.
⟶ A10.9d's strip is one resolution and it is still his *"maybe"*. **What is now clear is that
SOMETHING must restore; which thing is his.**

★★★ **AND THE PROPERTY THAT MAKES IT SMALL: EVERY VISIBILITY HERE IS DERIVED, NOT CHOSEN.**

    a TAB is shown        iff its group is DOCKED
    the PANEL is shown    iff at least one tab remains
    the STRIP stands in   iff the panel is empty            ⚠ *"maybe"* — see A10.9d

⟶ **The whole structure adds ONE piece of user-facing state — docked / undocked, per group — and
everything else is a function of it.** No second toggle, no visibility a user can set into conflict
with the dock state, nothing to disagree with. ★ That is the flattening rule doing its work: *reduce
decision load, encode the rule, never add a choice*.

- **A10.9g — WHAT A GROUP IS, AND WHERE ITS DOCK STATE LIVES** (AL-13, blanks 1 and 3).

      A GROUP     = **one interface surface, MINUS the map.** The six `planning/interface/`
                  files are the only enumeration that exists and `check_interface` already
                  reconciles them 1:1. ★ Battlewrath's structure makes the map and its controls
                  ONE surface that never docks (A10.9a) ⟶ **four dockable groups: remote ·
                  curation · promotion · object.** A LANE IS A GROUP — A10.1a's three lanes were
                  the first three; the remote is the fourth.
                  ⚠ `Spec` declarations for the three undeclared groups are owed **AS EACH PANE
                  FOLDS**, one pane at a time (A10.2a's order) — not all at once.

      DOCK STATE  **ACCOUNT-WIDE, beside the other UI preferences.** One field. It is a
                  preference about the TOOL, not about a route — and RI-24's law decides it: a
                  route-scoped dock state would TRAVEL ON EXPORT, and nothing about the author's
                  own setup travels. ★ Held through **AceDB** (AL-16, Battlewrath: *"Sure. Go
                  for it. We're still learning how to use Ace."*).
      TEST: undock a group, `/reload` → it is still undocked; export the route → the export
      carries no dock state at all.
      MUTATION: store it on the route → the export grows a field and RI-24's law bites.

- **A10.9h — THE FRAME'S IDIOMS ARE MEASURED, NOT INVENTED** (AL-15, `driver_architecture.md`
  §4e, from the fork's own `WorldMapFrame`). ★ The client ships this exact shape — *the map vs
  the map with quests on display* — and nine of its idioms transfer. The ones these rows lean on:

      an invisible RULER frame every piece of chrome anchors to
      the panel bolted by ONE anchor set at creation and NEVER re-anchored — **hiding is not
        re-anchoring**, which is what makes A10.9c's derived visibility cheap
      presence DERIVED from content, persisting only the user's chosen axis
      an undocked window's position kept in a 1x1 PROXY frame, so the real frame reparents freely
      the two modes differing by a TEXTURE SET, not a rebuild — **one language** (A10.9d)

  ⚠⚠ **AND TWO THINGS MEASURED IN THE SAME FILE THAT WE DO NOT TAKE:** ~30 hand-listed
  `Show`/`Hide` calls repeated across four transition functions — **which is exactly what A10.9's
  derived visibility replaces with one pass over a per-mode table** — and one widget's visibility
  owned by two files. ★ Prior art is worth as much for the second list as the first.

- **A10.9i — ⚠⚠ DOCK / UNDOCK IS NOT A FIELD CONVENTION. WE ARE BUILDING IT, AND THE RECIPE IS
  MEASURED** (AL-16, `driver_architecture.md` §4f, from a census of 230 addons).

      OF 230 ADDONS   22 embed Ace3 · ~37 write option tables · only 9 drive AceGUI directly
      DOCK / UNDOCK   **TWO addons do it, BOTH with raw frames.** There is no idiom to buy.
      THEIR RECIPE    reparent · **RESTORE THE SUPPRESSED CHROME** · a sentinel flag

  ★★ **THE MIDDLE TERM IS THE ONE THAT BITES AND IT IS EASY TO MISS:** a docked group SUPPRESSES
  chrome it does not need — title, close, drag handle — because the column provides them. **Undock
  it without restoring that chrome and the window has no affordances at all**: it cannot be moved,
  closed, or identified. ⚠ And the per-tab return band (A10.9d) is chrome too, so it is part of what
  a restore must put back.
  TEST: undock a group → the window has a title, a way to move it, a way to close it, and its
  return band; dock it again → all four are suppressed and the column's own are used.
  MUTATION: reparent WITHOUT restoring chrome → the undocked window is unmovable and the row bites
  on the missing handle rather than on a screenshot.

  ★ **AND WHAT THE FIELD DOES GIVE US, cited so it is not re-derived:** tabs as DATA (`childGroups`,
  66 uses across 22 addons — tab-in-tab is a shape users already read) · a SERIALISABLE selection
  path, which is the per-tab return band's mechanism · `relativeWidth` not `SetPoint`, and
  auto-height from `LayoutFinished` — **which is A10.2c's per-file-zero and A10.9f's fit-the-largest
  measured in the field rather than asserted by us** · *"add another"* as `args[key] = group` +
  `NotifyChange`, very common — A10.3h's add-action is the ordinary shape · a master toggle keeping
  per-item state (Skada), which is the collapsed strip · an accordion whose ROW owns its height
  (LibellusLeti, named the best local model of computed padding).

- **A10.9a — THE MAP IS THE FRAME'S SUBJECT; ITS CONTROL IS A WIDGET WHOSE HOME IS THE MAP.**
  ⚠⚠ **CORRECTED 2026-08-21 — the Analyst's first wording overstated it.** It read *"they do not
  separate"* with a mutation that punished giving the control its own frame — **which is the
  INTENDED behaviour, graded as a defect.** Battlewrath, answering the question rather than the
  row: *"Locked in this case is a widget that lives on the map. But you have the ability to drag it
  off the map."*

      LOCKED means   its HOME is the map: anchored there, moving and closing with it
      IT DOES NOT    mean welded on. **The author may DRAG IT OFF.**

  ★ **So the surviving must-never is about the MAP, not its control: the map surface is not a pane
  among panes** — it is the thing the frame IS, and it cannot be UNDOCKED from itself. The control
  can leave; the subject cannot.
  TEST: the control is anchored to the map and travels with it until dragged off; after a drag it
  keeps its own position and the map keeps its.
  MUTATION: anchor the control to the SCREEN by default → it stops travelling with the map, and
  the "home" half of this row bites before any drag happens.
  ✅ **RULED THE SAME DAY: ONE MECHANISM.** *"Flatten it to one mechanism for now."* The drag-off
  and a tab group's knock-out are the SAME dock/undock behaviour; the affordance may differ, the
  behaviour may not. ★ The Analyst had this as a marked READ and it was taken — which is the read
  being cheap because it was labelled rather than asserted.

- **A10.9f — THE TWO FORMS ARE SIZED DIFFERENTLY, AND THAT IS THE POINT** (Battlewrath,
  2026-08-21): *"we can set the bolt on form to fit the largest content"* · *"when in the bolton
  form, it has a lot of vertical height to use, the undocked version can be more tailored"* ·
  *"we can have templates for what each undocked interface needs"*.

      DOCKED     ONE shared shape — a TALL, NARROW column running the map surface's height.
                 Sized to FIT THE LARGEST CONTENT, so every group fits the same column.
      UNDOCKED   PER-GROUP, from a TEMPLATE. Free of the column, so it takes the shape its
                 own content wants.

  ★★★ **AND RI-46's HEIGHT PROBLEM IS GONE ENTIRELY — NOT "MOST OF IT".** ⚠⚠ **THIS ROW WAS
  WRITTEN THE SAME DAY ON A NUMBER SUPERSEDED TWICE BEFORE IT.** It said *"most of it, not all"*,
  hedging against a 714 that stopped being true at §446. **Measured: child = 575 against a 600
  ceiling — it fits without the bolt-on at all.**
  ⟶ Two things follow and they point opposite ways, so both are stated:
      · the bolt-on's vertical extent is still the RIGHT shape and *"fit the largest content"*
        still rules the sizing — **nothing in the design changes**
      · but the HEIGHT is no longer a reason for any of it. **Dock/undock stands on
        Battlewrath's own reason** — *"the intent is so we are not leaving interfaces all over
        the users UI"* — and never needed mine.
      ⟶ So the sizing question becomes **which group is tallest**, and it is answered by
      measuring rather than by choosing. **Nothing here is taste.**

  ✅ **AND AL-13 BLANK 4 MAKES THE PARITY STRUCTURAL RATHER THAN GRADED: ONE DECLARATION, TWO
  ARRANGEMENTS.** Not one declaration plus a separate template — **the same `Spec` rendered two
  ways** (docked column · undocked window). ⟶ Same cells, same get/set, same adaptor labels **BY
  CONSTRUCTION**. *"Two declarations would be the second copy that can disagree."*

  ⚠⚠ **WHICH RETIRES THIS ROW'S OWN MUTATION, and the Analyst wrote it two hours before the
  ruling.** It read *"drop a control from the undocked template → the parity assertion bites"* —
  **under one declaration there is no undocked template to drop from, so the mutation cannot
  bite.** ★ That is the unfalsifiable-mutation shape this project keeps finding, arriving this
  time because a ruling landed after the row.
  ⟶ **The row now grades the STRUCTURE instead of the symptom:**
  TEST: dock and undock a group → the same controls are present and hold the same values, and
  ONE `Spec` entry is the source for both.
  MUTATION: introduce a second declaration for the undocked form → the single-source assertion
  bites on the second one existing at all, which is the fault rather than its effect.

- **A10.9b — THE SIDE PANEL IS BOLTED ON, AND ITS TABS ARE THE DOCKED GROUPS.** It is an
  attachment to the map surface, not a sibling of it. One tab per group that is currently docked.
  TEST: the panel is anchored to the map surface; moving the map moves it.
  MUTATION: anchor it to the screen → it detaches when the map moves and the row bites.

- **A10.9c — A TAB HIDES WHEN ITS GROUP IS KNOCKED OUT, AND THE PANEL HIDES WHEN NONE REMAIN.**
  Both are DERIVED from dock state and neither is a control.
  TEST: undock one group → its tab goes and the others stay; undock the last → the panel is
  gone, and nothing of it is left holding space.
  MUTATION: leave a disabled tab behind → the panel never empties and the second half never fires.
  MUTATION: hide the panel on the first undock → the remaining groups become unreachable, which
  is the failure this row's two halves exist to keep apart.

- **A10.9d — THE WAY BACK LIVES ON THE PANE THAT LEFT.** Battlewrath, 2026-08-21: *"A way back in
  would be collapsing a tab. Maybe 'Return to dock' button per that took the tab placement strip."*

✅ **RULED 2026-08-21 (AL-13 blank 2, Battlewrath) — TWO RETURN PATHS, ONE LANGUAGE.** His
  earlier *"maybe"* is now a ruling:

      THE STRIP        a different pane that reads as COLLAPSED, giving a **DOCK-ALL** restore
                       path, in the SAME TEXTURE GRAMMAR the bolt-on had. *"A drawer behaviour
                       in illusion is how I mean the collapse strip."*
      THE PER-TAB BAND on each undocked window, **occupying the same band space the tabs lived
                       on** — **DOCK THIS**. One language across both forms.

  ★★ **THE CONTAINER NEVER DISAPPEARS; NOTHING IS ONE-WAY.** ⚠ This supersedes the Analyst's
  read that no strip was needed — that read was sound about CONTAINMENT (the per-tab band alone
  restores) and wrong about the SURFACE: with every group undocked there would be nothing on
  screen carrying the frame's identity. **Restoration was never the only job the strip had.**

  ★★★ **AND THIS DISSOLVES A10.9c's TENSION RATHER THAN PATCHING IT.** The Analyst had the panel
  hiding-when-empty in conflict with the intent (*no way back = permanent sprawl*), and proposed a
  strip standing in for the hidden panel. ⟶ **His answer needs no strip: restoration does not
  depend on the panel existing at all, because the way home is carried by the thing that left.**
  ★ A10.9c stands unchanged — the panel may hide completely, leaving nothing holding space.
  ⚠ The strip (his earlier *"maybe"*) is therefore NOT NEEDED for containment. If it ever lands it
  is decoration, and it must not become the only way back.
  TEST: undock every group → the panel is gone; DOCK one floating pane → it returns and the
  panel returns carrying exactly that tab.
  MUTATION: make the return depend on the panel → with all groups out there is nothing to click,
  and the frame cannot be re-contained — which is the intent's failure, made testable.

- **A10.9e — ⚠⚠ A NAMING HAZARD, RAISED BEFORE IT DRIFTS.** *"Collapse"* now has TWO behaviours
  one layer apart:

      FOLD       A10.3f · a ZONE collapses to its header, INSIDE a pane, and stays put
      COLLAPSE   A10.9d · a knocked-out PANE collapses and RETURNS TO THE DOCK

  ★ This project has been bitten twice by one word carrying two behaviours — **the two GATES**
  (*"IT IS NOT `Rule.Gate` … written down here so the next reader does not merge them"*) and **the
  two ZEROS** (*"THE TWO ZEROS ARE DIFFERENT"*), both of which needed a warning written into the
  model after the merge had already happened once.
  ⟶ **Named here BEFORE either is built**, which is the cheap moment. ⚠ A code term for the
  second is the bench's the day it lands; the Analyst invents neither.

## A10.8 · THE READER'S SURFACE — two panes, and the steering never owns the screen

⚠⚠ **WRITTEN AHEAD — CHAIN 3 WAITS (THE BUILD PRINCIPLE, AL-12, architecture §7).**
Battlewrath: *"Push the editor to richness before worrying about export and Dungeon Routes…
deciding how we present information assumes the information is structured enough to reach them."*
⟶ **This section is a criterion waiting for its moment, not a queue item.** It exists now because
the ruling that shaped it is fresh (AL-6, AL-7) and a ruling with no gradeable home is the thing
this project keeps losing — **not** because the reader's screen is next. ★ Build it when the
information is structured enough to reach a reader; grade it against these rows when you do.

_NEW 2026-08-21 (AI-2 audit finding B4). ⚠⚠ **This was ruled on 2026-08-21 in `ARCHITECT_LOG.md`
AL-6 and AL-7 and existed in NO acceptance doc** — only in `driver_architecture.md` §4c, which
carries principle and grades nothing. A12's WHAT IS OUT called this counterpart "owed"; this is it._

★ **THE SPLIT IS THE RULING.** Battlewrath (AL-7): *"that lets the flight and the steering be placed
separately and not control so much of the user's UI. **If all is going well they just need
information and direction.**"* ⟶ It supersedes his own earlier "one surface" — **a flattening of the
screen, not a reversal.**

- **A10.8a — TWO PANES, SEPARATELY PLACED.**

      THE NOTE PANE   stage / step · the note. Information and direction. **All that shows when
                      things go well.**
      THE REMOTE      select · Arm ↔ Stop · correct-when-lost. **COLLAPSIBLE** to a
                      media-player-like corrector.

  ⚠ They are placed INDEPENDENTLY — the reader may put the note where they read and the remote
  where it does not cover the fight.
  TEST: collapse the remote → the note pane is unaffected, still shows stage / step and the note.
  MUTATION: bind them into one frame → the collapse takes the note with it and this row bites.

- **A10.8b — ONE FIXED DISPLAY, AND NO DIAGNOSTICS IN FLIGHT** (AL-6). The reader sees stage / step
  and the note. **Hit counts, first-hit indices and the IN set are the AUTHOR's test-drive readout
  (A10.5a), never the reader's.**
  ★ The reason is the reader's attention: a number that only a builder can act on is noise to
  someone in a fight.
  TEST: arm as a reader → no readout columns appear anywhere.
  MUTATION: show the IN set → this row bites, and A10.5's author/reader split loses its point.

- **A10.8c — THE MANAGER EMITS; IT IS NEVER IN CHAT** (AL-6). The stage line goes to the reader's
  own display. ⚠ Not `print`, not a channel, not a whisper. *(Data model 17c already rules the
  AUTHORING surface is a multi-line box and never chat; this is the same law on the reader's side.)*
  TEST: complete a stage → the line appears in the pane and nothing reaches any chat frame.
  MUTATION: `print` it → the test watches the chat frame and bites.

- **A10.8d — THE RECEIVE BOX LIVES ON THE REMOTE.** Multi-line + Read, per data model 17a–17c.
  ⚠ **An in-game SYNC channel is NAMED FOR LATER and NOT BUILT** (AL-6: join when sharing / on "in
  instance"; opt-in *"Sync with tank"*). Declared so the shape does not move when it lands.

- **A10.8e — TERMINAL AND RE-RUN.** The last stage completes → **"Route complete"**; the route stays
  SELECTED but not armed (A12.8a). **A re-run is LEAVE AND RE-ENTER the dungeon** — there is no
  restart button. ⚠ ★ That is a DESIGN choice, not an omission: re-arming mid-dungeon is what
  recovery is for, and a restart control would be a second way to do the thing recovery already does.
  TEST: complete the last stage → the words appear, nothing is armed, the selection survives.
  MUTATION: add a restart → two paths to one outcome, and the recovery path stops being exercised.

⚠ **NOT GRADED HERE, deliberately:** the note's WORDING and the pane's art are the naming pass's;
this section fixes what the surface must CONVEY and what it must never show.

## A10.6 · WHAT IS OUT (so nothing is graded that was never asked)
    dock / undock · visual style · the personal-note pane · export/import doors ·
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
is a selection. ~~⚠ Its stage half has a PRECONDITION on disk: `AddBeacon` forces a stage.~~
✅ **NOT ANY MORE (staleness sweep, 2026-08-21) — S7 landed; the blocker was a dead comment, not code.
See A10.3e's own note.**

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
