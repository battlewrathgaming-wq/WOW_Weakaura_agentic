# DRIVER — THE BASIS. Read this first; it says what governs NOW.

_Kept tiny on purpose. If a document is not listed under GOVERNING it does not direct the build.
When a ruling moves, this file moves; the older text stays as history with a banner. Updated
2026-08-17._

## GOVERNING — build against these, in this order

1. `driver_use_case_target.md`      what the product IS; §9 the two products + the sorting rule
2. `driver_scoping.md`               the fifteen decisions + §R — RULED
3. `driver_data_model.md`            ★★★ **THE ENTRY POINT for anything about the stored or
                                     exported form** (Battlewrath, 2026-08-19: *"the model is the
                                     best entry point. It answers why and gives implementation
                                     something to challenge."*). §A the 22 selected rows · §B what
                                     is open, with who moves next · §C compared and NOT selected,
                                     so the comparison is never re-run · §D seeds · §E still to
                                     detail. ⚠ It defers to the authoring form (now #4) on what a
                                     TERM MEANS. ★ MOVED from #12 to #3 on 2026-08-19: appending
                                     it had put a SUPERSEDING document BELOW the documents it
                                     supersedes, so the tie-break handed a builder the stale text.
                                     ⚠ The Analyst had justified appending as protecting "citations
                                     across thirteen files"; measured, there were fourteen, in three
                                     files, all rewritten in one pass. The cost was asserted, never
                                     counted.
4. `driver_programmatic_model.md`    the authoring form: objects · SENSE = location + behaviour
                                     whilst in R (When on · Seen · When off) · WHAT I DO
                                     = rows, each ONE declaration `<sense>:<action>:<arg>` (RI-17
                                     grammar; "condition + inline end" was interim) · floor words
                                     WHILE IN / SEEN · naming law §3b · adaptor requirement · ORDER
                                     §5 · §2c = the DRIVER's boss machinery, not the author's
                                     surface (RI-15 settled 2026-08-18)
5. `driver_authoring_acceptance.md`  item 1 + item 2's first proof + adaptor: **A1–A9** (build
                                     to these; each row names its mutation; REVIEW LOG at the
                                     foot = the current PASS / MOVED / RED state)
6. `driver_walk_acceptance.md`       ⚠ the DESK's rule: W1–W7 (W1–W6 done; W7 RESCOPED
                                     2026-08-20 — it grades a reimplementation OF THE DESK,
                                     not the driver, which is graded on outcomes)
7. `driver_user_journey.md`          the reader's lines + the CAPTURE MILESTONES at the foot
8. `operations/ROUTER.md`            client FACTS — always wins over any addon or doc
9. `driver_ui_scope.md`              the OVERHAUL's frame (not absolute): §0 his scope · §3 the
                                     fork → A′ · §6 his answers · §8 the acceptance shape
                                     ★ EVIDENCE FOR §3 NOW EXISTS — `history/UI_findings_ace_XML.md`
                                     (bench, §351): A′ DEMONSTRATED (`PerformLayout` runs under
                                     lua51 on both revisions); Ace3 r960/r1403 in `dependencies/`;
                                     every API name either asks for is attested on this fork; the
                                     client's own 1209 frame templates are READ from the MPQ, not
                                     modelled. ⚠ Q1–Q5 at its foot are the bench's open asks.
    ✓ THE BENCH's `driver_ui_proposition.md` (§353) was REVIEWED and FOLDED INTO #11 by the
      Analyst (2026-08-18): R1–R3 accepted as criteria; U1–U6 answered in the rows (Window ships ·
      overlaps = siblings recursively + containment · per-file zero SetPoint with a shrinking
      allowlist · mixed state fine, dated in the review log · `Libs/` explicit reported exemption ·
      FrameXML Lua loaded whole, stubs reported by name); build order P1–P6 accepted. ✓ READ
      AND THE PROPOSITION HAS LEFT (§354) — deleted, its 13 items verified present in #11 by
      grep before removal rather than on trust. ⚠ Two of #11’s rows are the ANALYST'S OWN
      additions, not the bench's: a CONTAINMENT assert on top of siblings-recursive (a clipped
      widget is a fault — the exact class `frames.lua` was written for and my U2 did not ask
      for), and A10.1a's structural check that the root holds three groups and nothing else.
10. `driver_ui_acceptance.md`        the UI REWORK's test brief — A10.1 primary frame renders
                                     under the harness · A10.2 folding hand-placed controls ·
                                     A10.3 node editor's three items · A10.4 tell never lock ·
                                     A10.5 test drive remote · A10.7 Battlewrath's clicks-only
                                     pre-live checklist (the gate to live testing)
11. `driver_sense_acceptance.md`     the V1 DRIVER — SENSE test brief (A11.x, 2026-08-18) against
                                     the bench's `history/driver_sense_proposition.md`: the flat row as a
                                     declared CONTRACT · the rule inherited whole (W1/W7) · purity
                                     by address · no persistent OnUpdate · the readout CORRECTED
                                     to what a stageless V1 can report · ISOLATION proven by an
                                     isolated smoke · w5 goldens watched FIRST · Q1–Q5 reads (Q4's
                                     split = Battlewrath's shipping decision). ⚠ `check_targets`
                                     will report ALLOWLIST DRIFT until the bench mirrors this line
                                     — that is the check working, not a fault.## BATTLEWRATH'S POSITIONS SINCE THE PROPOSITION — best working model, dated (not yet in older text)
_One status for his input: the best working model until an insufficiency forces change. Older
files say "RULED"; read that as this. (2026-08-17/18)_
- no refusal anywhere: `listen(UNIT_DIED, name)` — no name, nothing arms; editor TELLS
- the boss beacon's tabs (model §2c) are the DRIVER's implementation, not the author's surface;
  the author has ONE question per intent — "boss killed: ⟨name⟩ → advance" (~~"boss engaged:
  ⟨name⟩ → say the note"~~ ⚠ SUPERSEDED (RI-15 settled, 2026-08-18): engaged is not offered); the name is the ARG (RI-17; was "the condition's"
  parameter (RI-15), the picker is not a term
- the instruction is the author's ANSWER; the driver calls its own functions on it; not every
  function needs a label — a question is the end product of how a function would answer; the
  adaptor carries the QUESTION LAYER only (model §3b)
- pass-through is NOT silent failure: an unresolved question:answer term SHOWS its code name so
  what was called for is still expressed; the checker makes the miss loud (acceptance A5.1)
- `wire` is GEOMETRY (a line of small radii); "trip" is a FIRING word — two axes, never one row
- the push token arrives at the DRIVER; background processes serve awake instructions, two-way
- B1 closed: the child axis is `sense`, not `kind`. A1.1: `ReachOf` is a pure accessor
  — ✓ **LANDED §349.** One production call site (`object.lua`'s ratchet tell, now
  `ReachOf(acc)`); the masking mutation RETIRED with the branch it asserted as correct
- **RI-1..4 DRAINED (2026-08-18)** — see `Reconcile_inbox.md §DRAINED` for the one-liners:
  note = referenced-in-store / owned-in-pane · band/radii = raw `nil` + consumer resolves ±2.5,
  tick-to-change sliders · TEST DRIVE = its own suite entry inside Dungeon Run (`/dr walk` is
  gone, not revived; assurance = the diagnostic suite) · export-trims governs as best working
  model: **on import ONLY THE RID is re-minted — `BID:CID` are unique within the RID and carry
  unchanged**; place carries as current; metadata outside identity/place SURVIVES; the origin
  on someone else's data does not travel; ledger's round trip compares against the MINT CONTRACT.
  Records touched: acceptance A1.3 / A4.2 / A6.1; model §3; the ledger §5.9–5.11 want a banner
  (bench). Nothing remains with Battlewrath from the proposition round.

- **RI-5 DRAINED (2026-08-18):** the two thresholds are ACTIONS at distances = TWO TABS → two
  steps. The pane is exactly THREE: **SENSE** (the kind: reach here + distance · ~~boss engaged /
  killed ⟨name⟩~~ [⚠ SUPERSEDED (RI-15 settled, 2026-08-18): boss is not a sense — see the RI-15 bullets below] · ~~falling · in combat~~ [⚠ SCRUBBED (RI-17, 2026-08-18)]) · **WHAT I DO** ~~as DURING | WHEN OFF (update note · set
  supertracker · advance · set stage)~~ [→ RI-17: rows `<When on|Seen|When off>:<boss|note|set|ratchet|supertrack|say…>:<arg>`] · **IF SEEN** (once | every). No firing field — G15 IS the
  during/when-off pairing. No "what happens next"; no beacon-level next over children. **The
  FIRST CHILD acts as the beacon** (lure + note; last delete; tabs return to the parent;
  completion shed to any child; taste — parent biggest, children the discrete placeable ones).
  Position is the node's, not the pane's. → model §1/§2, acceptance A2.5. `sense`'s shipped
  values and the A3 block STAND; A1.1's pure accessor is UNBLOCKED.

- **RI-6 DRAINED (2026-08-18): the CID counter stays ROUTE-SCOPED (a), as shipped** — one global
  press stamps the running count; per-BID would look up, count history, then mint (more
  referencing, more misfires). `RID:BID:CID`; only RID re-mints on import; no CID migration
  (A8.4 = RID only). Stage/ordinal are properties, never identity. **Two beacons on one stage is
  an authoring COLLISION — TOLD (red "match N"), NEVER LOCKED; no modal, no click-me mid-edit;
  the driver degrades deterministically and STATES which lure wins (bench).**
- **STEPS replace goTo (2026-08-18, best working model):** an ordinal child is a STEP — the same
  object as a childless beacon (default lure: come here / arrow / note; sense reach-here;
  what-I-do advance to the next step); it points at ITSELF; order is the ORDINAL ALONE (sub-
  ratchet); satellites unchanged. `goTo` + `Heads/BrokenLinks/Cycles` RETIRE (they split
  pointing from sensing with no default and contradicted only-lures); `activate` was goTo
  renamed (history). A2's "ordinaled child WAITS for its predecessor" mutation IS the mechanism
  and already bites. → model §1b; bench: retire goTo in `routes.lua`/`object.lua` under a
  criterion (acceptance A2.6).

- **RI-7 / RI-8 / RI-9 DRAINED (2026-08-18):** `activate` and `onRamp` GONE with goTo in A2.6's
  commit (outward pointing / a second mechanism for one fact). Entry = childless → the beacon;
  with children → the FIRST CHILD (acts as the beacon; the lure; can be step 1); then whatever
  the author laid out fires (ordinal 1 sensed / a satellite first); co-location for the rare
  separate-lure case. **What survives, his words: UPDATERS and ORDINAL — and both beacons and
  children have both.** **Notes are IN v1** — S8 reversed by him as a reversal; G1 stays in the
  order (RI-1's shape); A4 as written.

- **RI-10 DRAINED (2026-08-18): TWO NOTE KINDS, TWO SHELVES.** The ROUTE note lives on its own
  plane under the personal one (§60); export takes it whole and never the personal plane —
  structural. Words: **"personal note" / "route note"** ("reader" rejected: a reader is anyone
  reading either). The author-facing LABEL is **"Route instructions"** (one adaptor row: `route note` → "Route
  instructions"; "note" reads as a dev-note slot on first read); "Personal note" stays; ghost
  text *"Instructions for the player running the route"*. PERSONAL NOTES SCOPED (model §4b): a player using both addons;
  per-place, role/class experience ("healer: DoT here"); shown in a DESIGNATED SLOT beside the
  route note during runs, by position; may push the tracker by explicit act, the route overwrites;
  how routes become lessons learned; off the authoring path; never travel. **G1 UNBLOCKED** —
  acceptance A4.2 reworded (the Analyst's earlier wording had named the personal shelf).

- **RI-11..14 DRAINED (2026-08-18):** the `check_rects` canvas is a RED (A9.6: 240×330 vs a
  600-tall pane) — fix now; **UI placement arguments are DEFERRED TO THE OVERHAUL** ("out of
  place when we know it needs an overhaul"); until then the checker NAMES hand-placed controls
  as unverified · A4.2 = "closed except the travel half" (structural two-tables guard now;
  behavioural assert owed to A8.5 when export lands) · "Personal note" label was already ruled
  in RI-10 — implementation, no reversal · the acceptance composition lives ONCE at the CALL
  LAYER outside `routes.lua`, swept by the smoke; headstone stays; no source-text scanner (A1.4).

- **UI SCOPE (2026-08-18) → `driver_ui_scope.md` (governing #10, not absolute).** Fork **A′:
  adopt Ace3 (own copy, proven 3.3.5 fork) AND branch it into the Lua emulation** so `check_rects`
  reads its rects — "we struggle to build interfaces; taste gets lost in the argumentation."
  **TABS** ("lanes; one surface, many jobs"). Knock-out later. **"The spec is the pane" = the
  overhaul's first acceptance row** (learn on the go). "Grade" in the route manager = the
  reader's SELF-ASSESSMENT + comments after their own run (never the route). Route remote: G3 =
  the test drive's suite entry inside Dungeon Run; the reader's select+arm remote is Dungeon
  Routes' — **YES**: Dungeon Run gets a TEST DRIVE REMOTE ("so I stop being asked to do things by
  commands / dispatcher"). **APPROACH: both, not or — the PRIMARY FRAME first (Ace container + tab lanes), then panes
  brought in ONE AT A TIME as needed; hand-built panes live beside it until their turn; lower
  risk. "The spec is the pane" is true per pane as it lands.** **FIRST TWO STEPS: (1) render the primary frame with the TAB design (Ace TabGroup, three
  lanes: run · promoter · node editor); (2) fold the hand-placed items into Ace-readable option
  entries — sense · ordinal · note first, ~~then the rest of object.lua~~ [A10.2a CORRECTED same day: the
  rest is REPLACED by A10.3] (ui_scope §6c; A10.x).** Evidence: `audit/ui_self.md` · `ui_wa_grammar.md` · `ui_research.md`
  · `ui_drawio_model.md`.
- **RI-15 DRAINED (2026-08-18): SENSE is the LOCATION + the behaviour whilst in its R (on me ·
  touched me) — [⚠ SCRUBBED (RI-17, 2026-08-18): not "the player's states" — falling / in-combat are GATES, not senses];
  boss is NOT a sense** — "while
  (duration) is the arming to listen to CLEU, and boss is the CLEU." WHAT I DO = "when the player
  is here": a STACK of rows, each an action (give note · advance · set stage · set supertracker
  · /say · open list) ~~with an optional condition (on boss ⟨name⟩ killed~~ [→ RI-17 grammar: the boss row is `When on:boss:⟨name⟩`; no condition field] (engaged NOT offered,
  settled the same day); the stack is
  scoped by the sense — "what you do only has meaning when you're in the location to do it."
  Boss child = sense here (during) → advance, on boss ⟨name⟩ killed; armed only while the sense
  holds. Landed: model §2/§3 · A3 (+A3.5) · adaptor boss rows · A10.3a/d · A10.2a corrected.
  **SETTLED same day:** a row = condition + action + optional INLINE stage end (interim wording —
  the RI-17 grammar below is the form: one declaration `<sense>:<action>:<arg>`), every row
  SELF-COMPLETING (no "then" between rows); author's condition = KILLED only (engaged not
  offered); ~~a kill row DEFAULTS to set stage = this beacon's next~~ → the boss NODE's NEXT defaults
  to Set(this beacon's next), ABSOLUTE from the node's own stage (recovery) — A2.9; fields depend on the choice. → model §2 · A3.2 ·
  adaptor · A10.3a. "step" = the ordinal child (a minor stage); actions are not steps; the
  no-ordinal UPDATE type child stays, same as a beacon (resolved same day).
- **RI-17 DRAINED (2026-08-18) — THE DECLARATION GRAMMAR: a WHAT I DO row IS one declaration
  `<sense>:<action>:<arg>`** — `When on:boss:Gul'dan` (on me · the boss function · the name) ·
  `Seen:Note:<content>` (touched me · the note function · the text). The author states the
  OUTCOME; the driver holds the function; falling / in-combat / encounter are what a function is
  constructed of, never a term; no separate condition field; stored/exported/read WHOLE. Sense =
  the LOCATION + behaviour whilst in R (the Analyst's state-list generalisation scrubbed).
  **WHEN OFF is the third sense-word (same day): When on · Seen · When off** — his four tabs on one
  child: When on:Note · When on:Boss:⟨name⟩ · When off:Note (different) · When off:Supertrack:⟨waypoint⟩
  ("the first waypoint was satisfied the moment they stood in the lure R" — the arrow moves on as
  they leave). Where N rides: ANSWERED — the node's NEXT, on the character line (A2.9).
- **NEXT (2026-08-18) — the logic hole and its fix:** tabs have no sequence, all fire on sense, so
  a `set stage` TAB fires on arrival mid-fight. **A stage change is NOT a tab — it is the node's
  characteristic NEXT (what I do when my tabs are complete): Step (default, the constant) · Stage ·
  Set(N)**, fired when ALL tabs are good; `set`/`ratchet` are not action words; a boss node's Next
  defaults to Set(this beacon's next). The offer follows what exists: with a greater ordinal → Step
  (default) · Stage · Set; the LAST step and a childless beacon → Stage (default) · Set. The PRECEDENCE bullet is DISSOLVED (Next is one field —
  nothing races); "where N rides" ANSWERED: on the child's CHARACTER line (ordinal · Next), never a
  row; the SN:CN export proposal WITHDRAWN. → model §2 · NEW A2.9 · A3.2 · A10.3a. The constant
  still lives in CHARACTER (identity intrinsic · character mutable · behaviour = the actions). **And the STAGE never waits for all its children: it completes
  when TOLD (an authored stage action) or when the ORDINAL RUNS DRY; update-type (no-ordinal)
  children never gate it (A2.8).**
- **RI-16 DRAINED (2026-08-18): YES — the runtime lookup lands before the first fold** (one
  function, one constant table on the UI side, pass-through; ROLE_TEXT + SENSE_TEXT retire into
  it). Provenance follows as tooling. **And: a child COMPLETES when ALL its action tabs have
  completed — a constant, no control** (note fired + kill pending = not complete). → A10.2
  precondition · A2.7 · model §2.
- **A10.2a CORRECTED (2026-08-18)**: fold the three that SURVIVE (sense · ordinal · note); the
  rest of the object pane is REPLACED by A10.3, not folded — two jobs, not one.
- **RI-23 (2026-08-19): THE ABSENCE IS A TICK, NOT A LIST ENTRY.** Every numeric door in the editor
  becomes a SELECTION (stage · `Set(N)` · ordinal from the stage table; radius/band from the
  pre-config menu) — and the offer *not staged* / *not in the ordinal* is a **tick beside the picker,
  with text saying why**, never a `0` in the list: *"seeing 0 in the drop down is offering a self
  defeating choice."* ★ The value a picker yields STAYS A NUMBER — stage is sorted, compared,
  incremented and typed into an address (`routes.lua:1541 · 1550 · 1529 · 657`), so only the INPUT
  is a selection; it is **not** in §382's config class. Three faces, one fact: **tick (author) ·
  `nil` (store) · `0` (line)**. → NEW A10.3e · A11.1a superseded in place. ⚠ PRECONDITION:
  `AddBeacon` still forces a stage (`routes.lua:345`).
- **RI-23 (2026-08-19): WHOLE-NUMBER BEACONS · NOTHING AUTO-UPDATES · EXPOSE, NEVER NAG.**
  *"Whole only I think. And we don't auto-update. We just expose to the user they have either a gap
  or a same... That's nagging. We can offer assertions so the choice / guard is flattened. Or expose
  it with help text."* Beacon stages are **whole numbers only**; child ordinals are the author's
  choice (`1.1 · 1.2` or `1 · 2 · 3`). ★ Already enforced by the mint — `NextStage` walks
  `while used[n] do n = n + 1` — and **load-bearing**: `Routes.Outcome`'s `+ 1` and `Routes.Gaps`'
  integer loop are each correct only while nothing sits between `n` and `n+1`. **The editor EXPOSES
  a gap or a same and never renumbers, corrects or warns**; the two sanctioned forms are an
  assertion that flattens the choice and help text. §385e's automatic REBALANCE is WITHDRAWN at both
  levels. ★ This is the manners rule *nothing that nags* applied to the editor rather than the
  driver. → A10.3e · RI-23. ⚠ Retires two Analyst findings (Outcome's `+ 1`, Gaps' integer loop):
  both measured the consequence of breaking an invariant that is now ruled to hold.

## HISTORY — read for WHY, never for WHAT to build (moved to `history/` 2026-08-18)
- `history/driver_design_advisory.md`   the arc's design as challenged; many sections superseded
                                by scoping / model (arm-zone, K-forward, `requires`, two
                                artifacts, re-seat-only, `mode: once|while`, `4.1 = child`)
- `history/driver_analysis_brief.md`    the opening brief; §2 "never compute your own"
                                OVERRULED (R-a); bounds §5 / stops §6 still hold
- `history/driver_walk_result.md` · `history/driver_posture.md`   bench results/claims at their
                                dates; some text marked withdrawn inside; posture §3 retracted

## BASIS-GRADE REFERENCE — evidence you reason FROM (stays at top level)
- `driver_analysis_asklist.md`  the reasoning space §A–§K + ledger; findings stand, DESIGNS in
                                §H are superseded where the model says otherwise (banner)
- `driver_reconciliation.md` · `driver_neighbours.md` · `driver_expressions.md` · `audit/*`
                                the audits — evidence, not instructions
- runsheets / procedures        a third kind: still runnable or not; not moved, not history

## NEXT FOR THE BENCH — standing order (rewritten 2026-08-18 after §362; the UI leg is the order now)
    ✓ done, one line each (the HELM carries the story): A9.1 audit §330 · A8.4 RID + migration
      §334–5 · A5.3 checker §336 · A8.1 StageOf §329 · A2.6 goTo/activate/onRamp REMOVED §340 ·
      G1 route note plane §346 (the export-travel half of A4.2 owed the day export exists) ·
      the ledger banner + `satellite` string §326.
    ★★ TWO LEGS RUN NOW, and this list carried only one until 2026-08-20.
    THE SENSE LEG (#12, `driver_sense_acceptance.md`'s own P1–P6):
    P1 ✓ satisfied — `walk.py check` covers every body, one exit code (§376)
    P2 ★ LIVE and UNBLOCKED — the row shape as a declared contract. Its input is the
       transport, settled RI-26 2026-08-20 (data model rows 17a–17c).
    P3 ★ UNBLOCKED 2026-08-20 (RI-33) — the rule in Lua, and it is SMALLER than it was:
       point + band + gate. Segment interpolation, interpolated-z and `v_max` are
       DESK-SIDE. ⚠ Build from need, not from precedence.
    P4 ⚠ NO LONGER BYTE-EQUALITY. W7 was rescoped the same day: byte-equality grades a
       reimplementation OF THE DESK; the DRIVER is graded on OUTCOMES at the ruled radii
       and cadence, and W7.2's synthetics are that surface.
    P5–P6 ingest at 1 Hz with the approach throttle · the readout by address

    THE UI LEG (#11, build order P1–P6 as accepted):
    P1 ✓ §354  client FrameXML Lua runs in the harness
    P2 ✓ §355  the lite Ace3 ships under Libs/; TabGroup is the seam
    P3 ✓ §358–§361  the one frame: three lanes · door beside remote.map · map seated · nested
                    geometry check + metric sweep · 305/317 mutations
    P4    text-metrics / stub reporting as A10.1c reads (partly in P3's sweep — the bench
          reports which half remains)
    P5    FOLDS — UNBLOCKED (RI-16 drained). FIRST the runtime lookup (A10.2 precondition; A5.1/
          A5.2 filled), THEN sense · ordinal · note (the sense dropdown = the player-only registry). Order per A10.2a as
          corrected on drain: the three that SURVIVE (sense · ordinal · note); the rest of the
          object pane is REPLACED by A10.3, not folded
    P6    A10.3 node editor · A10.4 tell · A10.5 test drive remote (A6.1 runs from it)
    then  A10.7 — Battlewrath's clicks-only checklist, offline green first, then live
    ★ DRILL 2 (Analyst, 2026-08-18, at Battlewrath's ask — "one last round trip for internal
      conflicts"): a reader found 11 conflict pairs (incl. 11 DOUBLE-DATED — both sides 2026-08-18),
      21 unmarked stale lines and 10 dangling pointers; 47 fixes landed across 9 files. The worst
      class was mine: a supersession written in ONE file while the same sentence stood unmarked in
      another (A10.3d marked in ui_scope, not in the brief); and the floor words spelled two ways
      (WHILE IN vs WHEN ON) — now THREE words everywhere: When on · Seen · When off. LEFT FLAGGED,
      not fixed → BOTH WORDED BY BATTLEWRATH the same turn: `ratchet` = the explanation ("can't
      regress") behind the labels **Next stage** (+N field) / **Next step** — a label with a field,
      never a control (A9.3's red closes on the adaptor row); and the IF SEEN control is labelled
      **Trigger** (dropdown: One time · Every time), so **Seen** is only the sense-word.
    ★ DRILL (Analyst, 2026-08-18, at Battlewrath's ask — "we flipped a lot"): a reader swept
      every governing file for text contradicting the settled shape (sense = the player · boss =
      the ACTION word `boss` (was "the row's condition" — RI-17), killed only · rows self-completing · kill default = recovery · ALL is
      a constant · node's constant = the step). 34 supersessions landed across 9 files (model ×12
      · basis ×4 · authoring ×5 · ui_scope ×2 · journey ×3 · adaptor ×4 · scoping · expressions ·
      reconciliation ×2), each dated "RI-15 settled" so grep finds them. ⚠ TWO FILES ARE THE
      BENCH'S and were NOT touched — apply the same banner or let A10.3 replace them:
        interface/object.md :199 "stage one of sense → when true → next" · :203 "ABSENT unless
        the sense is a boss sense" · :208 role · :245/:257 outcome (shipped shape; A10.3 replaces)
        driver_bench_proposition.md §19a A3.1 (1593–1606 "only the field's NAME differs") ·
        §19c 1685–1689 (all/any "offered from v1") · §15 T1/T4/T6 (823–862)
      "step" RESOLVED (Battlewrath, same day): step = the ORDINAL child, "a minor stage, a small
      gear"; actions are not steps (the row's word is the naming pass's — his own: "action tab").
      A child without an ordinal stays allowed as the UPDATE type (satellite), same as a beacon.

## THE DATA MODEL — `history/driver_data_model_proposition.md` + **RI-18 DRAINED 2026-08-19** (§375)

★★★ **THE HEADING IS SET — `driver_data_model.md` is GOVERNING #3 (2026-08-19).** Read it first
for anything about the stored or exported form; everything below this paragraph is how the
selection was reached, not what it is. Its §A carries the 22 selected rows, §B what is still open
**with who moves next** (G5 the representation is the next decision and now blocks two things),
§C what was **compared and NOT selected** — so the comparison is never re-run — and §D/§E the
seeds and the model still to detail.

⚠ **The proposition below (`history/driver_data_model_proposition.md`) governs nothing and never did.** It
is the bench's proposal and the place the eleven gaps were first named; the heading supersedes its
§1–§4 and carries its surviving gaps forward by name.
✓ **RI-20 · RI-21 · RI-23 · RI-25 are DRAINED into the heading** (2026-08-19). Still open in the
inbox: **RI-19** (the bench's aggregate command), **RI-22** (band's option shape, and whether the
STORE holds an index or a number), **RI-24** (`author` / `madeAt`).

**WHAT IS STORED, NOW: `driver_stored_state.md` (Analyst, 2026-08-19) — the going-forward FACT**
about the editor's own store: the root and its seven tables, the records as measured, the six laws
the store already obeys, and the debt with a disposition. Evidence under it is
`history/store_inventory.md`, **EMITTED** by `addons/tools/emit_store_inventory.py` — re-run it,
never hand-correct it. ⚠ It describes what IS; the proposition below describes what LEAVES.
★★ **AND ITS SIBLING: `driver_built_state.md` — WHAT IS BUILT (2026-08-19).** The same shape
one level up: six buckets by the ACTION each implies — landed · owed · unguarded · test-only ·
stranded · divergent — over the rulings the code has and has not reached. Evidence is
`history/built_state.md`, **EMITTED** by `addons/tools/emit_built_state.py`, whose apparatus
check proves itself in BOTH directions. ⚠ It exists because a governing document reads as
DESCRIPTION when much of it is PRESCRIPTION, and nothing marked which was which.

⚠⚠ It found that `store.lua`'s own `Shape:` header is FOUR TABLES behind what the same file
creates — which is why the inventory is a machine. Open: RI-24 (`author` / `madeAt` disposition).
The bench's data model proposal, and the reconcile item that needs the rulings. **Settled by
Battlewrath in conversation:** the line carries IDENTIFIERS AND NUMBERS ONLY (every human string
is an ID ref, *"even the Arg can be IDs"*) · names live in an address-keyed index the driver never
opens · notes ship as `NoteID : content` · `Stage:Step` are COMPOSED at export (*"deterministic at
read time, and without them you don't know when to show the note"*) · reject the reserved
character at ANY input (*"nice-ness breaks down when you can break the reader"*) · **"we accept
TABLES where they keep the line read light, and COMPOSING where that is the correct solution"** ·
an export and its origin become TWO ROUTES at import, never two versions (RI-4 re-mints).
★ **ELEVEN GAPS named** in its §5 — the point of the exercise. ⚠ Two need no ruling and are simply
true: there is NO UPDATE PATH by construction, and EXPORT MUST BE EDITOR-SIDE ALWAYS.
⚠⚠ **RI-18 asks six**, the sharpest being A8.6's *"the flat form IS the stored form"* against an
export that is a PROJECTION, and that G1's shipped note storage already differs from the model
while A4.2 passes under both.
✓ **Analyst read filed under RI-18 (2026-08-18):** A8.6 REWORDED to his words (exported form = a
projection; criterion unchanged) · Q2 (b) · Q3 one field two positions, said · Q4 fixed positions ·
Q5 asserted at ingest · Q6 NoteID in the editor store = HIS WORD (my read yes; it gives A4.2 the
test that tells referenced from owned). A11.1a/A11.1c, model §2 and the LINE bullet now carry the
no-free-text line, the two side tables, composed Stage:Step, and HIS SEQUENCE: design picks the
data model up AFTER a peer data-store audit and prior-art review. **Q6 ANSWERED YES (2026-08-19):
"in-line is an ID pointer; the free-hand text is derived from a lookup table; that keeps the
instruction line predictable and repeatable" — route notes stored `NoteID → content` in the editor
too; A4.2 reworded and its which-world mutation answered (referenced). RI-18 DRAINED; inbox OPEN:
RI-19 (the bench's word).**

## PEER AUDIT — `history/peer_data_stores.md` (§377, measured, rules nothing)
The first half of Battlewrath's sequence in A11.1a (*"model the data stores of our PEERS through
audit, then look to PRIOR WORK"*). ★ CORROBORATED independently: gates in the KEY PATH · ids never
names · a positional delimited line · reader and DATA as separate addons (four teams).
★★ THREE THINGS THEY HAVE AND WE DO NOT: a VERSION first on the wire (WeakAuras `!WA:2!`, and it
versions the ENCODING - content is a separate question) · a CLAMP that guarantees field width
(GatherMate pins x,y at 0.9999) · an explicit NON-FINITE policy (AceSerializer REPRESENTS NaN/Inf
where A11.2e REJECTS them - stated for the driver, not for the format).
★★★ And the argument FOR banning free text from the line is in AceSerializer's own history: byte
30 encoded to `~^` and was read as escape-plus-terminator, fixed by a VERSION BUMP (ticket 115).
A fifteen-year-old general serialiser needed a rev for an escape collision; a line with no free
text never enters that class. ⚠ Prior art beyond this client is NOT yet surveyed.

## EXECUTOR PRIOR ART — `history/prior_art_execution.md` (§384, sourced, rules nothing)
Hands-off systems where the plan is INERT and the runtime holds the capabilities — our shape from
the outside. ★★★ **MAVLink's mission item is our line field for field** (seq ~ CID · command ~
action · param1-4 ~ arg · x,y,z ~ POS · autocontinue ~ Next), in a safety-critical protocol with
two decades of use; three of its fields have no counterpart in ours and each is a question, not a
lack (frame · current · mission_type). ⚠ **AND IT CORRECTS §379**: a positional record with a
FIXED-WIDTH GENERIC payload IS skippable without tags — "a positional format must carry a version"
is too strong, it cannot skip a VARIABLE-WIDTH unknown. ★★ P3 gains a third answer: MAVLink gives
NaN a JOB (`NaN` = "no change"), neither rejecting nor merely representing it. ★★ G-code's modal
state and polyline's delta encoding buy compactness with the SAME currency — sequential dependence
— so **always-listen recovery prices both, and prices them out**. ★ ASL's version is OPTIONAL with
a stated default, which is how a shipped format retrofits one for free. ★ Home Assistant ships
§374's face/meta split (`alias` + `id`) and says in its own docs that the id exists so the name can
change. ⚠ Sourced from docs, not measured — one rung weaker than §377.

## PRIOR ART — `history/prior_art_formats.md` (§379, sourced, rules nothing)
The second half of the sequence, and it REFRAMES the version question. ★★★ "Does the line need a
version?" is THREE jobs: IDENTIFY (PNG's signature · CBOR tag 55799, deliberately no semantics) ·
VERSION (WeakAuras `!WA:2!` · GPX) · EVOLVE (Protocol Buffers, which has NO version marker at all
because a tag is `(field_number << 3) | wire_type` and unknown fields are SKIPPABLE). ★★ The rule:
**a POSITIONAL format cannot skip an unknown field, so it must carry a version; a tag-length-value
format need not.** Ours is positional.
★ P2's method: the RANGE is stated first and the width is DERIVED (polyline: ±180° at 5dp → 32-bit
signed). ⚠ Our bound is unmeasured. ★★ P3: JSON rejects non-finites AND says nothing about writer
behaviour, so four incompatible answers exist in the wild - **the failure is AMBIGUITY, not the
choice** (CBOR agrees from the other side). ⚠ Unlooked-for: PNG's signature catches NEWLINE
TRANSLATION, and our string gets pasted through chat. Confirmed sideways: GPX schema-enforces row
order (RI-18 Q5); DWARF references its name tables BY INDEX from a header (RI-18's names index).

## BENCH FINDINGS — `history/data_model_findings.md` (§372, records, rules nothing)
The shaping of the driver's input, five iterations with the reason each one moved, and the
conclusion that inverts the premise: **cost is not our limit — ISOLATION is unproven.** Measured:
every reader of route data goes through `Routes.Get(id)` → `Store.RouteTable()` → `d.routes`, the
whole table. ★ **No consumer has ever read ONE route without the store that holds all of them**,
so the driver would be the first to demonstrate the capability — a capability test, not an
optimisation. Also carries: WeakAuras measured from the installed fork (one frame; the gate is an
INDEX built at load, `loaded_events[event][id]`, with a second level on CLEU's subevent — add a
level at load, never a test at runtime); the three consumers of the flat form and their three
DIFFERENT guarantees (export decides order · driver may depend on it · import must not); and the
bench's own error on `Next`, which DRIVER_BASIS:181 had already ruled is ONE field.

## THE BENCH'S OPEN PROPOSAL — `history/driver_sense_proposition.md` (§371, governs nothing)
✓ **REVIEWED AND FOLDED into #12 `driver_sense_acceptance.md` (Analyst, 2026-08-18)** — S1–S10 are
rows; Q1/Q2/Q3/Q5 + P1–P6 accepted as the bench read them; Q4 accepted as working posture, the
SPLIT left as Battlewrath's shipping decision; ONE correction (S8's readout is stage-level — V1
reports the per-sample IN set and per-target first-hit; W7.3's columns are V2's); ONE addition
(A11.6a the isolated load — the findings file's unproven capability, provable in one smoke).
The proposition may leave once its behaviours are the rows.
**V1 DRIVER — SENSE**, written at Battlewrath's ask so acceptance can be authored against it:
*"first is a sense check — that we can perform sensing, as that's the pre-condition to killing
the boss."* V1 = **given a flat list of targets and a position, say which the player is in** —
no stage, step, lock-out, recovery, boss, CLEU or arming. Ten behaviours (S1–S10), what it is
NOT, what V2 needs (stages/steps as the LOCK-OUT; always-listen for ordinalless nodes, which is
`ListensNow`'s first line and the recovery mechanic), the reference that already exists (⚠
2026-08-20: W7.2's synthetic branches — W7.1's byte-equality moved to the DESK under RI-33;
Lua NaN needs two tests), and five open
questions. ⚠ It carries A9.5 as a blocker rather than a note: the w5 goldens are UNWATCHED, and
a golden nobody runs is the reference the port would be graded against.

## THE INBOX — `Reconcile_inbox.md` (a CHANNEL, never a governing document)

★★ **THE INBOX WAS SPLIT 2026-08-19 (Battlewrath's direction) and now has three parts:**
**`# OPEN`** — the live items, and the only part that waits on anything · **`# THE SETTLED SET`** —
every drained item flattened to *question · outcome · **NOT** statement · **IS** statement · cite*,
an index rather than an authority · **`history/Reconciliation_inbox_drained.md`** — the full prose,
read for WHY and never for WHAT. ⚠ Nothing was deleted; the split was verified line-by-line.
★ **The NOT statement is the point:** an outcome recorded only as what was chosen leaves the
rejected shape free to drift back in. **OPEN right now: RI-19 (bench) · RI-22 · RI-24.**
Questions the bench cannot settle alone go there with options + an IMPACT block; the designer
DRAINS them (rules · reconciles the records · checks impact) and each leaves to §DRAINED with
where it landed. **An item in the inbox is an OPEN QUESTION, not a ruling** — nothing there
directs the build until it has drained into a governing file above. **Open items: DERIVE from the item stamps (rule below), never from this sentence.** RI-17 (§363, Battlewrath in
conversation right after RI-15 drained): SENSE is the LOCATION and the BEHAVIOUR whilst in its
R — not "any player state"; WHAT I DO states an OUTCOME, never a mechanism (*"they don't build
how that is performed"*); the DRIVER holds the implementations and the export carries a
DECLARATION — *"it just needs to be told `While:Boss:Bossname`"*, which is `routes.lua:20`'s
*"a route is DATA rather than code"* made concrete. ⚠ FALLING and IN-COMBAT are neither senses
nor instruction sets — they are GATES, living in the wider logic that needs one. ✓ **The example
list WAS the Analyst's generalisation and is SCRUBBED (RI-17-marked) in model §2 (+ the STATE box,
§2b), A3's heading, A8.7, A10.3a, ui_scope, the journey banner, this file and the inbox** — nothing
seeds a registry with a state sense. Open piece: the declaration stored WHOLE as one field (bench
read (a)) — ✓ ANSWERED BY THE GRAMMAR he took: a row IS one declaration `<sense>:<action>:<arg>`
(`When on:boss:Gul'dan` · `Seen:Note:<content>` · `When off:Supertrack:<waypoint>`), stored and exported WHOLE; no condition field —
the action function carries its own condition/completion; falling / in-combat / encounter are what a
function is CONSTRUCTED OF. → model §2 grammar block · A3.2 · adaptor · A10.3a. RI-17 DRAINED.
✓ **THE LINE (Battlewrath, 2026-08-18, working model):** `MapID:RID:Stage:Step:BID:CID:POS:R:Band:Next:N :
Sense:action:trigger:arg` — one line kind, one per TAB, gates first, arg last AND AN ID REF (no free text
on the line; names + notes in side tables the driver never opens; Stage:Step composed at export; the
export a projection — RI-18); node fields read from the first line (a differing later line told);
empty slot = absent; import reconstructs by matching the node prefix ("same match and populate"),
never by order. Closes the findings' O1/O2/O3. Landed in `driver_sense_acceptance.md` A11.1a and
model §2. **SEQUENCE (Battlewrath to the bench, 2026-08-18): "I'll have DESIGN pick it up. And before that, we also model the data stores of our PEERS through audit. And then look to PRIOR WORK that is industry standard — information storage and transfer with a read instruction set isn't a unique issue."** So the line below is the WORKING MODEL the audits are measured against, not the design. (Earlier the same day: N never rides on a row line (SN:CN WITHDRAWN); it
is the node's NEXT on the child's CHARACTER line (ordinal · Next) beside the row lines
`BID:CID:<sense>:<action>:<arg>`. Still named, not decided: the delimiter inside a free-text arg
(escape / arg last) · the exact character-line form. (model §2)
RI-15 and RI-16 DRAINED 2026-08-18 (positions list above; inbox
§DRAINED for impact). **THE FOLD (P5) IS UNBLOCKED** — precondition: the runtime lookup first.

    RI-15  ✓ DRAINED — boss is not a sense; sense = location + behaviour in R (RI-17); boss = the
           ACTION word on a
           what-I-do row (positions list above; inbox §DRAINED for the impact moved).
    RI-16  ✓ DRAINED — YES, runtime lookup (one function, one constant table, pass-through)
           lands BEFORE the first fold; ROLE_TEXT + SENSE_TEXT retire into it; not a deviation.
           Provenance (generate from the markdown table) follows as tooling.

**Status is DERIVED from the inbox's item stamps, never listed here** (2026-08-19, bench finding: a
hand status header went stale within a day): `grep -n "RI-[0-9]* DRAINED" Reconcile_inbox.md` = the
drained; every other `## RI-` heading is open; next number = highest + 1. Outcomes of drained items
are in the positions list above.

## QUEUED — a full folder audit (Battlewrath, 2026-08-17; not now, while the bench builds)
Every file not part of the ACTIVE heading gets reduced to two kinds of text — **basis** (ruled or
true now, dated) and **reference** (evidence, why, history) — and anything that READS like a
decision or a truth but is not one is stripped. Method: blind agents, one per file, classifying
paragraph by paragraph; output = smaller files, never more. Why: an agent has no temporal memory —
every file reads as "now" unless the folder says otherwise; this file and the banners are the
prosthetic until the audit makes it structural.


## ★★★ WHY THIS FOLDER IS SHAPED THIS WAY (Battlewrath, 2026-08-19) — read this before adding to it

> *"I have temporal memory. Agents don't. They flash with an information set and then everything in
> it is true and current unless declared otherwise. So this file structure is hygienic, where
> history is the sprawl. Otherwise everything circles and conflicts and most our dev time is paying
> debt of low coherence."*

★★ **That is the whole reason for the demotion discipline, and it is a statement about the READER,
not about tidiness.** A person reading this folder carries the arc: they know a sentence was true in
August and got overtaken in September. **An agent has no such axis.** It arrives with a set of text
and every line in it is simultaneously present-tense and equally authoritative unless something in
the text says otherwise. So an un-struck sentence is not a stale note — **to the reader it is a
current instruction competing with the one that replaced it.**

⟶ **The two spaces exist for that one reason:**

    THE PLANNING SPACE   HYGIENIC. Everything in it can be grepped and taken as TRUE. If a line
                         cannot survive that test it is struck in place or it leaves.
    history/             THE SPRAWL. Every superseded shape, argued in full, banner-first.
                         Read for WHY. It is not a lesser space - it is where the reasoning
                         is allowed to be long, precisely so the other one can be short.

⚠ **The cost he names is measurable and was measured the same day.** A sub-agent audit of this
folder returned seven contradictions; two were written that morning, in two files by one author,
who fixed one instance and left its neighbour in the same sentence. `driver_bench_proposition.md`
carried a superseded ruling in a section its OWN head marked as live. The governing list carried
one document twice. ★ **None of that is carelessness — it is what happens when a superseded
sentence costs nothing to leave**, and every one of them would have been paid for later by a
builder arguing from the junior text. *"Most our dev time is paying debt of low coherence."*

★ **The practical rule that falls out, and it is cheaper than it sounds:** when a ruling moves,
the old sentence gets a dated strike beside the new one **in every file that carried it** — and
when a whole document is overtaken, it goes to `history/` with a banner rather than staying to be
read. **A supersession written in one file while the same sentence stands in another is the worst
case**, because now both are present-tense and one of them is wrong.

## THE ONE RULE FOR AN AGENT OPENING THIS FOLDER
Open the GOVERNING list top-down. If a governing doc and a history doc disagree, the governing
doc wins without discussion. If two governing docs disagree, the LOWER number wins and the
disagreement is reported, not resolved by the builder.

★★★ **AND THE RULE THAT STOPS THAT DISAGREEMENT ARISING (Battlewrath, 2026-08-19): AN
ACCEPTANCE BRIEF CITES THE MODEL; IT NEVER RESTATES IT.** A brief that repeats what a model
settles is a second copy that can disagree with the first — the same fault `routes.lua:112`
names for the RID, one layer up. ⚠ It is not hypothetical: A11.1a restated the record shape,
RI-25 moved it, the restatement was left behind, and the tie-break would have handed a builder
the retired form. ★ **The model answers WHY and is therefore challengeable; a restated
conclusion is not** — which is his reason for it: *"the model is the best entry point. It
answers why and gives implementation something to challenge."* **Where a brief needs the
shape, it names the row and moves on.** **And "RULED (Battlewrath)" anywhere in
this folder means "his best working model at that date" — held until an insufficiency shows,
never re-litigated on preference, never treated as law.**
