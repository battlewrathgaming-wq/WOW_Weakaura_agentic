# Driver — RECONCILIATION (independent audit, collated)

_Analyst, 2026-08-17. Three auditors ran BLIND — no access to the analysis thread or to each
other — each with one lens, each writing its own report unedited:_

    audit/audit_A_prior_work.md       A · what the project ALREADY held vs what the arc did
    audit/audit_B_model_delta.md      B · the model, section by section, vs the arc (78 rows)
    audit/audit_C_evidence_bounds.md  C · every proof/PASS/ruling: does it reproduce; bounds

_This file collates: §1 where auditors AGREE (cross-confirmed) · §2 what only one saw · §3 what
the Analyst adds and OWNS · §4 the DELTA LIST for model scoping · §5 mechanical fixes. Findings
are cited to the reports (A2#3 = report A, section A2, row 3). Nothing here is a ruling._

---

## 0. The shape of the result

    B1 verdicts (78 model rows):  STANDS 37 · SHRINKS 3 · ANSWERED-BY-DATA 7 ·
                                  CONTRADICTED 11 · OPEN 4 · UNTOUCHED 16
    C1 claims (58):               reproduce 34 · partial 10 · no 1 (posture §3, self-retracted)
                                  · not runnable 13
    A2 re-derived 18 · A3 overlooked 12 · A4 contradictions 16 · A5 vocabulary drift 22 terms
    C3 bounds: 3 crossed-then-withdrawn (all in result "rfc_combat", text still standing) ·
               9 approaches · 0 uncorrected crossings in the tool path

Read: the arc's EVIDENCE is sound (34/58 reproduce, the rest are unrunnable observations or
counts that moved as the corpus grew); the arc's DESIGN re-derived and renamed a lot of prior
work; and eleven model sections are contradicted — most by material the Analyst wrote.

---

## 1. CROSS-CONFIRMED — two or three auditors, independently

| # | finding | A | B | C |
|---|---|---|---|---|
| 1 | **The walk's reference implementation moved.** Model: the walk is IN-GAME (`editor.lua` play pacer), offline = a SECOND evaluator that must agree. Arc: `walk.py` on the desk is the golden, Lua is the port (W0/W7). | A3#1, A4#2, A5 | 4c/4f contradicted; B4 | — |
| 2 | **Stateless driver vs stateful consumer.** Model: flight-list steps self-contained, "driver stateless, no lookups". Arc: previous position (segment test), spent-set, `requires`, hysteresis state, `E[i]/I[i]` lookups. | A4#4 | 19b SHRINKS | — |
| 3 | **Runs stay home vs datasets travel.** Model: "runs never need to travel". Advisory §12: dataset as its own export/import economy. (Partially corrected in-thread — seed once, carry forever — but §12's first paragraph still says the dataset travels.) | A3#4, A4#8 | contradicted; B4#10 | — |
| 4 | **Anchor position is a LABEL vs theater arm-zone centre.** Model: "nothing downstream may consume it". Advisory §3/§13: theater xyz + R = the arm zone. | A4#3 | contradicted | — |
| 5 | **Free drag vs re-seat only.** Model + `routes.lua Place()`: drag to any point, "where you move it afterwards is yours". Advisory §12: re-seat onto another read only. | A4#7 | contradicted | — |
| 6 | **Where does the driver live** — three answers: separate addon (model), seventh surface in DungeonRun (scope), "addon 2 / consumer" (advisory §11), "in COA_DungeonRun" (asklist §K). | A4#12 | B4#7 | — |
| 7 | **What arms CLEU** — advisory §2 (position gate) vs §11 (engage event) — same document, unamended. | — | contradicted ×2; B4#11 | — |
| 8 | **`rfc_combat` result text stands as written** though H15 withdrew its criteria: "R must cover the excursion", two-kinds-of-beacon, the 76 % envelope, per-pin scores. | — | B4 (via H14/H15) | C3 §5.1/§5.5, C5#7 |
| 9 | **Acceptance W3.2 text stale** — still "admits the p99 jump" after the ±2.5 tolerance ruling. | — | B4#13 | C3 §5.4 |
| 10 | **Vocabulary drift** — nearly every arc term renames a model/code term (on-ramp→lure, complete→completor, `ifUnseen`→`mode:once`, `goTo`→`activate`, flight list→instruction set, in-game walk→`walk.py`). Code speaks the PRIOR vocabulary. | A5 (22 rows) | B3 (new-material list is largely renamed material) | — |
| 11 | **Build order** — scope: overhaul FIRST, driver second. Asklist §K: driver first, overhaul fourth. | A3#8, A4#13 | — | — |
| 12 | **W6/W3.2 stale tables inside the same files** ("NOT STARTED" above "DONE"; W6.1 both PASS and "ten seconds to confirm"). | — | B4#20 | C5#8, #9 |

---

## 2. SINGLE-AUDITOR — seen by one lens only (not weaker; just not cross-checked)

**From A (prior work read at code level):**
- **18 re-derivations**, six rated as costing time or diverging: "nobody had looked" at
  `SUPER_TRACKED_POSITION` when `Beacon.OwnsSlot()` already reads it (A2#2 — the pin-and-hold
  rationale was built on a gap that did not exist); compile-time graph checks re-specified
  over `requires` when `Heads/BrokenLinks/Cycles` already exist over `goTo` (A2#13); height
  candidates proposed and withdrawn against `routes.lua:29-31` (A2#5); W6 built large against
  a shipping release (A2#11); Position-outranks-Quest re-established (A2#4).
- **12 overlooked**: `SUPER_TRACKING_CHANGED` (an event for target change — the heartbeat was
  designed without it, A3#5); the CVar-off loss mode (A3#6); `Beacon.OwnsSlot` (A3#7); the
  model's sanitise-at-import and `|c|T|H` rendering hole (A3#2); LibDeflate already known
  (A3#3); the `goTo`/`fireOn`/`ifUnseen` fields (A3#9); model readout-box rulings (A3#10).
- **Contradictions only A saw**: K-forward jumping = the model's named CLIP-THROUGH failure
  that the three registers exist to prevent (A4#6); note actions re-introduced vs §91 removal
  (A4#10); an ordering primitive added vs "we never need an execution-order rule" (A4#11);
  W6 says the driver "reuses" Landmarks arrival while §9 specifies a different close (A4#14);
  "single ownership" vs the code's non-exclusive `complete` (A4#15).

**From B (model section by section):**
- **16 model sections UNTOUCHED** by the arc — announce, readout-box editor subsections, the
  rendering hole, capture arming, two lanes, curation, all visibility/icon rulings, sheets/
  face/grammar, control vocabulary, compactness. (These are not gaps; they are the model's
  authoring/UI body, which the arc did not enter.)
- **26 items of new material with no home in the model** (B3) — the detection rule, once/
  while, requires, activate, close, three-tier fence, package format, entity table, the
  shipping constants, the tracker-state characterisation. Scoping must decide which enter
  the model and under which name (see §1#10).
- **21 arc-internal disagreements** (B4) — most self-corrected in-thread; the ones NOT yet
  reflected in text: §1#7, #8, #9, #12 above; advisory §3 "4.1/4.2" vs §13 "never 3.1/3.2"
  (B4#8); §13's first table still shows `A pointer C2` after `activate` replaced it (B4#9);
  asklist §K G1 phrases release as a driver step while C-1 says authored (B4#15); ledger says
  mounted speed unmeasured while the result records 17.5 yd/s (B4#19).

**From C (evidence run, bounds read strictly):**
- **The straddle branch WAS reachable from a landed file.** `20260812_113949_493__satnav__legs.jsonl`
  has mapIDs {1, 389} with xyz on every row (C5#3). The "mapID constant within all 12 landed
  runs → synthetic by necessity" claim (posture §12, result W1.2/W1.3, walk.py text) is false
  for one file, or the count is 9 not 12. The synthetic fixtures still stand; the "by
  necessity" does not.
- **W5's tool does not emit what W5 specifies**: no per-beacon first-proximity time, no
  timeline rows to a file — the byte-equal golden W7.1 names does not exist yet (C4, C5#13).
- **W3.2 tool contradicts itself** — jump labelled UNMEASURED and MEASURED in the same run (C5#2).
- **Numbers that moved as the corpus grew** and are now stale in the docs: FIT worst 0.000203
  → 0.000220; 5.5 bracket rows 4,952/6,809 → 8,742 over 9 runs; "1e-5 over 1,758" is 5.4e-5
  mean on the Barrens run; rfc_combat gap seconds 92.7 not reproducible under a stated window
  definition (C4).
- **Provenance is not re-hashable on a fresh clone** — 23 of 24 corpus headers point at
  gitignored raw clones; only test1's is force-tracked (C5#5).
- **Bounds**: 3 crossings, all withdrawn in H15 and fenced in walk.py, all still standing as
  text in the result (C3); `COA_DevDump/route_chain.lua` is a tracked generated per-dungeon
  route inside a dev-probe addon (C3 §5.3 — approaches; not in the product path).
- **Assertion-only claims** (C2): `C_Timer.After` ≡ OnUpdate (brief §2, no reader); all chat
  rulings (by construction); the op-count claims (~9/~30); A-3(ii) marker = player position
  (asserted from code reading, not measured).

---

## 3. WHAT THE ANALYST ADDS — and owns

Attribution first. Of the eleven CONTRADICTED model rows and the sixteen A4 conflicts, the
majority originate in material the Analyst wrote (advisory §2/§3/§4/§9/§11/§12/§13; acceptance
W0/W7): the theater arm-zone, K-forward, `requires`, note actions, the dataset economy,
re-seat-only, the stateful consumer, the desk-as-golden, "two addons". These were offered as
design ADVISORY and several were later softened to "configs, not rulings" in-thread — but the
texts read as rulings, and B/A read them that way. That is the fault my own memory names:
extending a refinement into a law. The reports measure it.

Three things the audits surface that are DECISIONS, not hygiene — they belong to scoping:

**D-1 · One register of state, or point-only detection.** The model's stateless step form
cannot express a segment test (it needs the previous sample). Either the model admits one
register (previous valid position) or detection is point-only and W1.6's grazing miss is
accepted. This is not resolvable by wording; it is a choice between the model's "stateless"
and the arc's proven rule. (Cross-confirmed §1#2.)

**D-2 · Which walk is the reference.** The model rules the in-game walk primary and offline
a second evaluator; the arc built the desk first and made it the golden. Both cannot be the
reference. (§1#1.) Note the arc's reason (a consumer did not exist, so the desk was the only
place to prove the rule) is now spent — the rule is proven; the question is what W7 grades
against once the Lua exists.

**D-3 · Vocabulary.** The code and model speak `on-ramp · complete · ifUnseen · goTo · flight
list · the walk`; the arc speaks `lure · completor · mode:once · activate · instruction set ·
walk.py`. One set has to be the model's. (§1#10.) Analyst's position, labelled: the code's
words are prior and shipping; the arc's renames should be mapped back unless a rename carries
a real distinction (activate ≠ goTo only if listening-conferred is new; `while` has no prior
term and is new).

> **RULED (Battlewrath, 2026-08-17), on the three decisions:**
> **D-1 → WeakAuras is the model.** A stateful conditional machine is acceptable — but
> NON-INVASIVE, with ARM CONDITIONS gating what is active (WA's load/trigger posture). The
> operating rules: *do what is cheap frequently; do what is expensive when needed; take the
> direct path to the information; API > CLEU, but not a limit.* So the model's "driver
> stateless" SHRINKS to "state confined to what is armed"; one register (previous position)
> for the segment test is inside that.
> **D-2 → the desk walk is the GOLDEN for this dev cycle; the CLIENT ultimately proves whether
> the work was useful.** Both, in sequence: W7 grades the port against `walk.py` now; the
> in-game walk / real use is the final arbiter. Not a contradiction — a phase.
> **D-3 → two things are in play, and they have names:**
>     DUNGEON RUN    the sample collection + the route EDITOR   (COA_DungeonRun)
>     DUNGEON ROUTE  the CONSUMER + the SENSOR the player has at runtime
> This resolves §1#6 (driver placement): a separate consumer, as the model said. On
> vocabulary: the two products carry two languages by construction — the editor speaks the
> model's authoring terms (source language), the consumer speaks the flattened runtime terms
> (what it compiles to) — drift matters WITHIN one, not across them. Term-by-term mapping is
> scoping work, not ruled here.

And three findings I'd rank above the rest for consequence:
- **§2/C: the straddle file exists** — a claim of "unreachable from the corpus" was wrong; the
  right response is to add that file as a W1.3 real-data fixture, not to defend the count.
- **§2/A: `SUPER_TRACKING_CHANGED` + `Beacon.OwnsSlot`** — the heartbeat (H5) was designed
  without the event and the shipping ownership check. Divergence still works; the design
  should have started from those.
- **§1#6 + §1#11: driver placement and build order** are the two prior rulings the gap
  analysis (§K) quietly overrode. Scoping decides; §K should not.

---

## 4. DELTA LIST for model scoping — model § → status → decision needed?

_From B1 (78 rows) consolidated with A4/A3. Rows the arc did not touch are omitted; see B2._

| model area (B1 ids) | status | what scoping decides |
|---|---|---|
| Capture is the only spawn; drag afterwards is yours (3b) | CONTRADICTED by re-seat-only | free drag (model+code) vs re-seat (arc) |
| Run = surface read; legs → segment-against-reach (4e/4g) | SHRINKS / ANSWERED — arc proved it with fixtures | none; cite the arc from the model |
| THE WALK in-game; offline second evaluator (4c/4f) | CONTRADICTED by desk-golden | **D-2** |
| We inform, never act (5a) | STANDS | none |
| Readout box: one sender, sanitise at import, rendering hole (6x) | UNTOUCHED / A3#2, A4#9 | whether satellites' shared note slots respect one-sender |
| Beacon is a THEATRE; anchor = label (10a/10c) | CONTRADICTED by arm-zone | keep label-only, or admit the arm-zone config |
| Children vocabulary detect/condition/instruct (10c) | CONTRADICTED by entity table + activate | **D-3**; and whether `while` enters |
| Stage ordinal, fractions, no validation (11) | STANDS; A4 "compile-time DAG refusal" vs "no authoring refusal" | tell-and-trust vs compile-time refuse |
| Beacon points to SELF; entry always points (14a–d) | ANSWERED-BY-DATA (W6) / STANDS; A2#6 re-derived | none — cite; keep the model's date |
| Three registers set/ratchet/maxSeen; clip-through (16a–c) | CONTRADICTED by K-forward (A4#6); v1 ratchet-only per scope | whether K-forward is a v1 config, or maxSeen returns |
| Far-stage policy OPEN (18a) | OPEN; W5.2 emits K=all vs K=3 | ruling can wait for a real route |
| Player index correction (18c) | ANSWERED — manual seek (user recovery) | none |
| Flight list; steps self-contained; driver stateless (19a–c) | SHRINKS (19b) | **D-1** |
| Sequence as DISTANCE, no execution-order rule (19c) | CONTRADICTED by `requires`/activation chains (A4#11) | whether an ordering primitive exists, and under which name (`goTo` chain?) |
| Deliberately absent: runner is a separate addon (26b) | CONTRADICTED ×3 placements | **§1#6** |
| Hopes: bosses = set:stage; unit:death (28c/28d) | STANDS; arm-on-engage refines | fold the engage+CLEU two-phase into the model, in the model's words |
| MVP order: overhaul first (scope) | CONTRADICTED by §K | **§1#11** |
| Note actions removed §91 (scope/code) | CONTRADICTED by advisory §5/§13 | out of v1 regardless; decide for v2 |

Model areas ANSWERED-BY-DATA with nothing to decide (cite the arc): terminal release · 1 Hz
adequacy · cross-run walk numbers · band ±2.5 · far-stage numbers exist · wrong-vs-right
advance is measurable offline · engine 3D distance in-dungeon across floors · declined state
detected · overwrite instantaneous · `ts` a verifier only · design speed 7.0.

---

## 5. MECHANICAL FIXES (no decisions; owner in brackets)

- walk.py W1 summary "eight" → ten [bench] · w5/w32 jump MEASURED/UNMEASURED labels [bench]
- walk.py w5: emit per-beacon first-proximity time + timeline rows to a file (W7.1's golden) [bench]
- walk.py / posture §12 / result W1.2-3: correct the "12 landed runs mapID-constant" claim; add
  `113949` as a W1.3 real-data fixture [bench]
- result: mark posture-§3-style retractions IN the rfc_combat section (H15 withdrawals) and
  the stale "at §285" acceptance table [bench]
- acceptance: W3.2 wording → tolerance (±2.5, no p99-jump admission) [Analyst] · W0 "simulator"
  → state-machine harness [Analyst] · W6 stale halves [Analyst]
- advisory: §2 vs §11 CLEU gating · §3 "4.1/4.2" · §13 first table `pointer C2` · §12 first
  paragraph "dataset travels" · §3 arm-zone marked as config not ruling [Analyst]
- asklist: §I mounted speed 17.5 · §K G1 release wording → authored (C-1) · §K build order and
  driver placement flagged as scoping decisions, not stated [Analyst]
- corpus: force-track the raw clones behind the corpus shas, or state that headers are
  re-hashable only with the raw present [bench] · refresh doc numbers that moved (C4) [bench]
- brief: amend §2 "never compute your own" to record R-a, so the brief and Landmarks'
  `beacon.lua:181` comment stop stating opposite rules [Analyst; comment = bench]

_None of the above is applied here. The reports are the record; this file is the map._
