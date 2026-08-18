# DRIVER — THE BASIS. Read this first; it says what governs NOW.

_Kept tiny on purpose. If a document is not listed under GOVERNING it does not direct the build.
When a ruling moves, this file moves; the older text stays as history with a banner. Updated
2026-08-17._

## GOVERNING — build against these, in this order

1. `driver_use_case_target.md`      what the product IS; §9 the two products + the sorting rule
2. `driver_scoping.md`               the fifteen decisions + §R — RULED
3. `driver_programmatic_model.md`    the authoring form: objects, tabs = triggers, senses,
                                     floor words WHILE IN / SEEN, naming law §3b, adaptor
                                     requirement, ORDER §5, boss beacon §2c
4. `driver_bench_proposition.md`     the bench's own plan — **read §19 (OUTSTANDING) and §15
                                     (the tension index) first; §0–§14 are its reasoning and
                                     read as history-grade** (1,789 lines; the banner says so)
5. `driver_authoring_acceptance.md`  item 1 + item 2's first proof + adaptor: **A1–A9** (build
                                     to these; each row names its mutation; REVIEW LOG at the
                                     foot = the current PASS / MOVED / RED state)
6. `driver_walk_acceptance.md`       the consumer's rule: W1–W7 (W1–W6 done; W7.1's golden
                                     exists since §298; W7 awaits a Lua consumer)
7. `driver_user_journey.md`          the reader's lines + the CAPTURE MILESTONES at the foot
8. `operations/ROUTER.md`            client FACTS — always wins over any addon or doc
9. `driver_ui_scope.md`              the OVERHAUL's frame (not absolute): §0 his scope · §3 the
                                     fork → A′ · §6 his answers · §8 the acceptance shape
                                     ★ EVIDENCE FOR §3 NOW EXISTS — `audit/UI_findings_ace_XML.md`
                                     (bench, §351): A′ DEMONSTRATED (`PerformLayout` runs under
                                     lua51 on both revisions); Ace3 r960/r1403 in `dependencies/`;
                                     every API name either asks for is attested on this fork; the
                                     client's own 1209 frame templates are READ from the MPQ, not
                                     modelled. ⚠ Q1–Q5 at its foot are the bench's open asks.
10. `driver_ui_acceptance.md`        the UI REWORK's test brief — A10.1 primary frame renders
                                     under the harness · A10.2 folding hand-placed controls ·
                                     A10.3 node editor's three items · A10.4 tell never lock ·
                                     A10.5 test drive remote · A10.7 Battlewrath's clicks-only
                                     pre-live checklist (the gate to live testing)

## BATTLEWRATH'S POSITIONS SINCE THE PROPOSITION — best working model, dated (not yet in older text)
_One status for his input: the best working model until an insufficiency forces change. Older
files say "RULED"; read that as this. (2026-08-17/18)_
- no refusal anywhere: `listen(UNIT_DIED, name)` — no name, nothing arms; editor TELLS
- the boss beacon's tabs (model §2c) are the DRIVER's implementation, not the author's surface;
  the author has ONE question per intent — "boss killed: ⟨name⟩ → advance", "boss engaged:
  ⟨name⟩ → say the note"; the name is the sense's parameter, the picker is not a term
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
  steps. The pane is exactly THREE: **SENSE** (the kind: reach here + distance · boss engaged /
  killed ⟨name⟩ · falling · in combat) · **WHAT I DO** as DURING | WHEN OFF (update note · set
  supertracker · advance · set stage) · **IF SEEN** (once | every). No firing field — G15 IS the
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

- **UI SCOPE (2026-08-18) → `driver_ui_scope.md` (governing #9, not absolute).** Fork **A′:
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
  entries — sense · ordinal · note first, then the rest of object.lua (ui_scope §6c; A10.x).** Evidence: `audit/ui_self.md` · `ui_wa_grammar.md` · `ui_research.md`
  · `ui_drawio_model.md`.

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

## NEXT FOR THE BENCH — standing order (2026-08-18; nothing in it waits on a ruling)
    1  A9.1  the pane-registration audit (pre-§322 pane greens are UNVERIFIED)
    2  A8.4  RID opaque + the migration's own criterion (colon in a route name breaks the address)
    3  A5.3  the adaptor checker in `check_interface.py`, with its first red (`ratchet` ·
             `on-ramp` · `satellite`) and the two rows that contradict the model (`wire` ≠
             "trip wire"; the three boss rows → two senses each carrying a name)
    4  A8.1  `Routes.StageOf` (four lines)
    4b A2.6  STEPS replace goTo — retire goTo + Heads/BrokenLinks/Cycles + `activate` +
             `onRamp` (RI-7/8) absolutely, one commit; steps
             self-lure by ordinal (A2.5/A2.6); stored goTo on old routes told and dropped
    5  G1    ✓ LANDED §346 — route note plane (own table), keyed `RID:BID:CID`, pane box
             labelled "Route instructions" with its ghost. A4.1/A4.2/A4.3 closed, 7
             mutations bite. ⚠ ONE HALF OF A4.2's TEST IS NOT ASSERTED: *"export → route
             notes travel, personal notes do not"* — **there is no export function yet**.
             What stands in for it is the STRUCTURE (two tables, asserted), which is what
             RI-10 chose it for. The travel assert is owed the day export exists.
    6  A6    TEST DRIVE inside Dungeon Run — RI-3 drained (A6.1); first proof = advance on just
             a boss kill
    done: the ledger §5.9–5.11 banner (RI-4) · the `satellite` string — both §326. ★ The
          string now says what it DOES ("no order - listens whenever this beacon does") and
          needs no term at all, which is the naming law working rather than a swap.

## THE INBOX — `Reconcile_inbox.md` (a CHANNEL, never a governing document)
Questions the bench cannot settle alone go there with options + an IMPACT block; the designer
DRAINS them (rules · reconciles the records · checks impact) and each leaves to §DRAINED with
where it landed. **An item in the inbox is an OPEN QUESTION, not a ruling** — nothing there
directs the build until it has drained into a governing file above. **OPEN: none.** RI-1..14
drained 2026-08-18 (outcomes in the positions list above; RI-11..14 the latest — canvas red,
placement deferred to the overhaul, A4.2 partial, label already ruled, call-layer composition).
Next item takes RI-15.

## QUEUED — a full folder audit (Battlewrath, 2026-08-17; not now, while the bench builds)
Every file not part of the ACTIVE heading gets reduced to two kinds of text — **basis** (ruled or
true now, dated) and **reference** (evidence, why, history) — and anything that READS like a
decision or a truth but is not one is stripped. Method: blind agents, one per file, classifying
paragraph by paragraph; output = smaller files, never more. Why: an agent has no temporal memory —
every file reads as "now" unless the folder says otherwise; this file and the banners are the
prosthetic until the audit makes it structural.

## THE ONE RULE FOR AN AGENT OPENING THIS FOLDER
Open the GOVERNING list top-down. If a governing doc and a history doc disagree, the governing
doc wins without discussion. If two governing docs disagree, the LOWER number wins and the
disagreement is reported, not resolved by the builder. **And "RULED (Battlewrath)" anywhere in
this folder means "his best working model at that date" — held until an insufficiency shows,
never re-litigated on preference, never treated as law.**
