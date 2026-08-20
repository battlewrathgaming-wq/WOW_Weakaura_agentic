# The WALK — acceptance criteria (analysis lane → addons bench)

_2026-08-17. **The addons bench builds; this lane tests the build against these criteria.**
The walk is the desk simulator that executes the driver's detect-and-advance rule offline
against recorded runs. It is how the spec gets tested BEFORE the driver exists, and it becomes
the GOLDEN the Lua port must reproduce on the same corpus. Every criterion below is checkable
by me independently — where I already hold the expected number, it is stated._

Fixtures: `addons/landing/corpus/*__legs.jsonl` (+ `*__markers.jsonl`), commit `0e38b61`.
Primary: `20260817_025542__test1-16__legs.jsonl` (0.2 s, 7 floors, sd/od pairs).

---

## W0. Shape — what the walk IS

    inputs    a run (legs rows) · a route (ordered beacons: xyz, R, bandUp, bandDown, mode)
              · constants (POLL_MIN/MAX, MAX_CLOSING_SPEED, K, hysteresis margin)
    rule      ⚠⚠ THE DESK'S RULE. Until 2026-08-20 this line read *"the driver's rule
              EXACTLY as the consumer will run it"* — RI-33 separated them: the driver is
              point + band + gate (A11.2a) and does NOT segment. What follows is the desk's:
              throttler cadence · segment test for `once` / point test for `while` · mapID
              gate · segments across a mapID change DISCARDED · no hold · K-forward listen ·
              one-way ratchet · boss-set as authoritative set
    outputs   per beacon: first-hit sample index + gt, hits, misses; per run: stage timeline
              (stage, gt, cause), false advances, skipped stages; per R sweep: transit fraction
              (segment vs point). Plus the calibration readout (W2) and the speed readout (W3).
    fence     EDITOR-tier logic written on the DEV DESK first (Python), then ported. The port
              must reproduce the desk verdicts on the same fixtures (W7).

Routes for testing come from two sources: **pseudo-beacons** (marker kill positions, ordered
by first-visit time) and **hand routes** (a beacon list authored for a fixture). No dataset →
no beacon; the walk refuses an xyz that is not a sample (seed-once law, advisory §12).

## W1. Detection rule — structural criteria

- **W1.1** Segment test implemented as asklist H4 (2D point-to-segment on xy, band applied
  at the interpolated z of the closest point). Compare SQUARED distances; no sqrt.
- **W1.2** Point fallback when the previous sample is absent, another mapID, or invalid.
  _**`invalid` defined (2026-08-17, on the bench's J1 ask):** the sample's POSITION is
  unusable — any of `x, y, z, mapID` nil or non-finite (the position API returned nothing
  usable: loading screen, transition frame). Never `ts`, never `sd` — tracker state in
  detection would re-open the `0.00`-on-Invalid channel R-a closed. An invalid sample is
  COUNTED, never silently dropped, and BREAKS the chain: the next valid sample gets the point
  test, no segment is bridged over the hole (bridging would invent a path through data we do
  not have)._
- **W1.3** A segment whose endpoints straddle a mapID change is discarded, never bridged.
- **W1.4** No hold: a transit with exactly one in-region sample fires.
- **W1.5** Segment ≥ point on every fixture and every R: the segment test never detects
  fewer transits than the point test. (Monotonicity — a violation is a bug.)
- **W1.6** On a synthetic straight transit at offset `o` from centre, step `s`: point test
  misses iff `o > √(R² − (s/2)²)`; segment test never misses. Closed form from H0-a; the
  build must reproduce it on a synthetic fixture (I supply: R=5, s=1.4, offsets 0..5).
- **W1.7** Band veto: a synthetic transit passing within R in xy but with dz outside
  [−bandDown, +bandUp] does NOT fire. Band OPEN fires. (The walkway-above case.)
- **W1.8** `while` mode: enters at R, exits at R + margin, re-arms; a `while` region never
  counts toward progress; a transit too fast to sample inside a `while` region does not
  flash.
- **W1.9 (added 2026-08-17, asklist A-1) — the CLAMP branch.** W1.6's worst-case-phase fixture
  puts every foot of perpendicular at t = 0.5; the clamp (t < 0 / t > 1 → distance to an
  endpoint) is never executed there, and an UNCLAMPED (infinite-line) implementation passes
  W1.5/W1.6/W1.7. Fixture: a beacon COLLINEAR with a segment, beyond its end by more than R
  → silent; beyond its end by less than R → fires (via the endpoint); plus a PHASE SWEEP of
  the foot along t ∈ (0, 1) proving the segment claim at all phases, not one.
- **W1.10 (added 2026-08-17, asklist A-2) — a GAP BOUND on chain continuity.** `usable()` is
  necessary, not sufficient: two valid same-map samples far apart in time or space are a
  HOLE, not a step. A segment is discarded (point test on the next sample) when `dt` exceeds
  the cadence bound (offline: > 2× the capture interval; live: > 2× POLL_MAX). **The `dt` bound
  is THE criterion — it detects missing samples, the actual fault.** The length test survives
  only as a TELEPORT detector at a deliberately absurd `v_max ≥ 100 yd/s` (amended 2026-08-17,
  asklist H14: Scythe Rush is real traversal at ~50 yd/s over two ticks; a `v_max` that keeps
  it constrains nothing at 1 Hz; a loading-screen relocation is instantaneous, not fast). The
  existing "40 yd same-map segment bridges and FIRES" fixture flips: it must NOT bridge.
  **Real-data fixtures for this branch: the three pre-regime RFC runs** (43 / 69 / 125 s combat
  holes) — each hole must break the chain, and W5.4 on them must FAIL for that reason.
  Bridging a hole invents a straight path through data we do not have — the same principle
  as W1.2, arriving by time instead of by nil.

## W2. Calibration readout — goldens from test1 (must reproduce)

From the sd/od pairs (rows with sd > 0):

    rows with both sd,od      1739      sd>0 rows            1564
    sd==0 rows                175       all contiguous at start, od==0 on all (AT the pin)
    sd==0 ∧ od>0              0
    |sd−od|  mean 3.4e-06 · median 2.5e-06 · p99 1.3e-05 · max 1.9e-05   (yd)
    sd range                  0.03 .. 264.43 yd
    od == 3D Euclid to testPin to 1e-13 (2D is off by up to 29 yd)   → engine distance is 3D
    cross-floor rows (floor ≠ pin floor 6) with sd>0: 1467; |sd−od| max 1.9e-05; dz −69.9..+5.2

- **W2.1** The build's calibration readout matches the table above to the stated precision.
- **W2.2** The divergence detector (H5): flags a row iff |sd − od| > ε (ε = 1 yd). On test1
  it flags 0 rows. On the satnav boundary run (`records/20260812_113949_493__satnav.json`,
  57 in-dungeon rows at ts=0/sd=0) it flags every row where own distance > ε.
  _Second half: the satnav file is a probe record with a different schema (bench, result M-abs).
  **Analyst's choice: REDUCE the 57 rows into corpus form** (`t, gt, x, y, z, mapID, floor,
  sd, od`) as their own reduced file, same emitter, same provenance line — one reader, one
  economy, and the form any future declined-state walk lands in. Not a second reader._

## W3. Speed readout — golden from test1

Consecutive-sample 3D speed, dt in (0.1, 0.5), same mapID, moving = > 0.5 yd/s:

    samples 1738 · moving 1470 · p10 6.96 · p50 7.00 · p90 7.58 · p99 8.44 · max 9.02 yd/s

- **W3.1** Reproduced to 0.01. Design speed = 7.0 yd/s (mounting is rare by construction —
  Battlewrath; the 30 yd/s ceiling stays as an inert constant).
- **W3.2 (added 2026-08-17, asklist H15) — the DEFAULT TIGHT BAND, sourced.** The band's tight
  default is "player height + jump affordance", and it should come from the corpus, not a
  guess. Measure over all regime fixtures: (i) dz jitter of a player walking a level surface
  (the noise floor a band must tolerate); (ii) the max upward dz excursion of a JUMP over its
  arc (jump affordance → `bandUp` default); (iii) the max downward dz over a drop that is
  still the same floor (→ `bandDown` default). Emit p50/p99/max for each; the shipped default
  = a value that admits the p99 jump and rejects the smallest floor separation seen in the
  Height_map fixtures. Ships as two constants (`bandUp`, `bandDown` defaults) with their
  derivation. A "different height" is still never invented — the band only says how far off
  a SAMPLED height still counts.

## W4. Q4 readout — golden from test1

True 0.2 s path vs decimated polyline; error = distance from each true point to the
**TEMPORALLY BRACKETING** segment of the decimated path — the segment spanning that point's
moment in time, NOT the globally nearest segment — 2D xy (p50 / p90 / p99 / max, yd).
_(Wording corrected 2026-08-17 on the bench's M2: "nearest" read as global and sent the first
implementer to the wrong measure. Bracketing is the better measure — the globally nearest
segment can be a corridor the player returns through later, which flatters the reconstruction.
The goldens were always bracketing; the sentence now says so.)_

    1.0 s    0.01 / 0.75 / 1.61 / 2.41
    2.0 s    0.19 / 2.37 / 4.15 / 5.01
    4.0 s    1.31 / 6.32 / 9.58 / 11.43

- **W4.1** Reproduced to 0.01. Constant that ships: capture at 1 Hz; do not go coarser.

## W5. Transit metric — the walk proper (numbers to be produced, criteria structural)

**Fixtures (ruled 2026-08-17, asklist H14):** SFK_live, SFK_Run4, **rfc_combat** (0.2 s + combat
+ six authored pins). The three pre-regime RFC runs RETIRE from W5 (their holes bracket the
kills) and MOVE to W1.10 as its real-data fixtures.

**Route source — CORRECTED (Battlewrath's challenge, 2026-08-17, asklist H15): a test route
is ANY ordered set of SAMPLED positions.** Kills, combat-end positions, authored pins — all
are just positions in visit order inside the acceptance; **none carries a combat meaning
here.** The driver is graded on whether it REACTS to placements correctly (detect within R,
band-shaped H, ratchet, timeline), never on whether the placements were sensible — that is the
author's, and what combat "looks like" is dungeon knowledge we do not hold. The earlier
three-source framing (kills = geometry / combat-ends = lures-in-the-operating-envelope /
authored = the real kind) is WITHDRAWN as a criterion structure — it was a step toward
modelling combat. Combat-shaped observations (gaps, lure/destination, boss `while` extents,
combat footprint) are AUTHOR-SIDE READOUTS at most, outside W5.
  Beacons **ordered by marker time, with each beacon's FIRST-PROXIMITY time emitted beside
  it** (A-3); sweep R ∈ {2, 3, 5, 8, 12}. Band: OPEN and the DEFAULT TIGHT band (W3.2) both.
  On rfc_combat the `boss-set` cause is TESTABLE (boss names + engagement timestamps in the
  record) — W5.3 exercises it there as a RATCHET mechanism (authoritative set), not as a
  combat model.
**Before the numbers, pin three fixture semantics per run (A-3):** (i) cadence throughout
(do combat legs thin the samples?); (ii) is a marker the PLAYER's position at kill time or the
MOB's — W5.4's premise holds only for the former; (iii) marker time vs nearest legs sample —
a CLEU-timed marker can sit up to half a stride from its nearest sample, so a small-R
point-test miss on the generating run may be a timing artefact, not the rule.

⚠ **Two rates — a SYMMETRIC bound (rewritten 2026-08-17, asklist A-4; the earlier "pessimistic
side" wording was wrong).** The walk replays a capture at 1 Hz (7 yd stride); the LIVE driver
ticks at 0.2 s inside 11 yd (1.4 yd stride). A decimated polyline deviates from the true path
by up to W4's reconstruction error `e` (2.41 yd max at 1 Hz) **in EITHER direction** — it
bulges (a miss the live driver would not have) AND it cuts corners (a phantom hit through
space the player never occupied; the bench's R=1 12→13 shows it). Correct reading: a beacon
within `R − e` of the true path is detected by both; a beacon in the annulus `R ± e` is
uncertain either way. State this on every W5 readout. test1 (0.2 s) is the fixture where walk
cadence == live cadence: replay at 0.2 s and decimated to 1 s, same route, and ALSO run the
bench's kill fixture — a beacon placed inside a known cut corner that fires only on the
decimated path.

- **W5.1** Per R, report transit fraction under point and under segment; W1.5 holds.
- **W5.2** Under K = all, report false advances (a later beacon firing before an earlier
  one's first visit); under K = 3, report again. Emit both — no recommendation.
- **W5.3** Stage timeline emitted per run: (stage, gt, cause ∈ hit|skip|boss-set).
- **W5.4** Replaying the run that GENERATED the markers must reach the last stage (a run
  passes through its own kill positions by construction). If it does not at R = 5, the walk
  or the marker positions are wrong — that is the first thing to look at.
  _**CONDITIONAL (H14, ruling 3):** "by construction" holds iff a marker is the PLAYER's position
  at kill time, not the mob's — Bench to state which from the marker code. On regime fixtures
  (max gap ≤ 0.23 s) W5.4 holds through combat or gap; on the retired RFC trio it must FAIL
  under W1.10 because the kill sat inside a hole — that failure IS the W1.10 test._
- **W5.5** Cross-fixture: SFK_Run4's route walked by SFK_live's legs, and vice-versa —
  numbers emitted, no grade.

## W6. Live pin handling — **REDUCED 2026-08-17 (§288). Most of it was already answered.**

_Was: "set A → walk → release → set B → walk", a chain probe. ⚠ That framing imported a
**handover** the client does not have. Battlewrath: **"the pin only cares about being set"** —
it is a slot you write to, not a lock to negotiate. What survives is smaller and sharper._

### The two cases, and only one of them needs a release

    stage met, a NEXT stage exists    SET the next pin. The overwrite IS the handover.
    stage met, NO next pointer        RELEASE — or the arrow points indefinitely at a
                                      spent target, silently.

⚠⚠ **Release is a REQUIREMENT, not a courtesy, and the reason is F24:** the marker never
releases itself and *nothing in the client's flow clears it*, so in the terminal case **we
are the only actor that can**. Leaving it set hands the player a stale instruction that
looks live. ★ Our own captures are the evidence for that persistence — the pin survived
every round trip across test2/3/4 and `ts` returned to `2` each time, holding for 1,386
samples without decaying. The same property that makes it useful during a run makes it
harmful after one.

### ★★ ALREADY SHIPPED — the driver reuses this rather than inventing it

`COA_Landmarks/beacon.lua` performs release-on-arrival in production, in-range-triggered:

    if arrivalConditionMet() then ... if sustained >= ARRIVAL_HOLD then Beacon.Clear()

and `Beacon.Clear()` drops the internal state, kills its `OnUpdate` (back to zero idle
cost) and calls `SuperTrackerUtil.ClearSuperTrackedPosition()`.

★ **So the driver's only genuine difference from Landmarks is that it RE-PINS after
releasing**, where Landmarks never reclaims (AC-19). Same machinery, one extra step — and
that difference is F-ii's product decision, not a technical obstacle.

### ★★★ W6 — **DONE 2026-08-17 (§290). One 193-second run closed all of it.**

`records/20260817_170747_470__chain.json` — `rfc_combat`'s **six authored pins**, walked with
`/coadump st chain`, the route generated from the landed capture (sha `f9092b22ff1a`).

    6 set · 6 clear · 6 arrive · 0 skip · 955 rows · finished

- **W6.1 PASS — the overwrite is instantaneous, six times.** `set` follows `clear` inside one
  tick and the next engine distance reads the NEW beacon: `4.02 → 63.96` yd. No lag, no stale
  pointer. ★ Confirms there is no handover to negotiate.
- **W6.2 PASS — every switch is in the record.** Each `set` / `arrive` / `clear` is an event
  row carrying position, our own `od`, the engine's `sd` and `ts` at that instant. **This is
  the first record we hold where the pin changes**, so the walk can replay multi-stage
  pointing.
- **★★ THE RELEASE QUESTION — ANSWERED, and it was the only genuinely unproven part.**
  `GetTargetState` reads **0 at every clear**. That is the client confirming the *view* is
  gone, not merely the state changing. A route ending armed would have left a ghost arrow
  that looked live.
- **★★★ AND THE CALIBRATION PAIR SURVIVES A MOVING TARGET:** worst `|sd − od|` = **1.99e-05
  across 955 rows and six pins**. That figure had only ever been measured against one pin held
  for a whole capture; `od` tracks whatever the pin currently is, with no drift at the switch.

⚠ **One thing for any arrival threshold:** every arrival landed at **4.02–4.75 yd against a
5.0 trigger**, never closer — at 0.2 s and walking pace the last yard is crossed between
samples. **A 5 yd trigger fires at ~4.0–4.8**, which is W1.6's closed form appearing in live
data rather than a fixture.

_W6.3 (the player's own quest arrow) remains an observation for F-ii, not a gate._

### What was left, before it was done

- **W6.1 — overwrite.** Does setting a second pin without clearing take? Near-certain: the
  run sheet's own steps 2→4 are an overwrite and the records carry the second pin. Ten
  seconds to confirm; no dungeon, no route, no walk.
- **W6.2 — ⚠ THE REAL GAP, AND IT IS OURS.** `capture.lua` writes `testPin` **once at arm**.
  A driver re-pointing per stage would leave **no trace of what it pointed at when**, so the
  walk could never replay a multi-stage run's pointing. This is a capture change, not a
  trip.
- **W6.3 — the player's own quest tracker** across a release-then-set. One glance, recorded
  as F-ii's evidence. ⚠ Not a gate: F24 already establishes we win the slot and nothing
  hands it back, so this informs the manners decision rather than blocking anything.

**STRUCK:** the two-race `z` confirmation (§288). The emulator establishes position `z` is
the base point, the water marks corroborate it, and if it were model-referenced the race
table gives the spread directly — so the answer changes no code either way.

## W7. Port fidelity (when the Lua consumer exists)

- ⚠⚠ **W7 RESCOPED 2026-08-20 (RI-33). BYTE-EQUALITY IS THE DESK'S CALIBRATION, NOT THE
  DRIVER'S SHIPPING REQUIREMENT.** Battlewrath: *"we build from need to function not on
  precedence. Precedence is the proof we can. Not the implementation the addon needs."*
  ★ W7.1 held the desk and the driver FUSED — every decision inside `walk.py` became a
  shipping requirement by transitivity, and nobody decided that. ⟶ **W7.1 now grades a
  reimplementation OF THE DESK against the desk.** The DRIVER is graded on OUTCOMES at the
  ruled radii and the ruled cadence, and W7.2's synthetics are that surface.
  ⚠ The desk reconstructs a fixed-cadence recording and must interpolate; the driver
  controls when it looks. **Interpolation is the desk's answer to a problem the driver
  does not have.**

- **W7.1 — THE DESK'S CALIBRATION (rescoped 2026-08-20).** A reimplementation OF THE DESK,
  fed the same fixture rows at the same cadence, produces the same stage timeline (W5.3) and
  the same per-beacon first-hit indices, byte-equal on the emitted timeline. ⚠ **This no
  longer grades the shipped driver** — the driver has no segment to be equal about. It stays
  because the desk's reproducibility is worth holding; it is not on V1's path.
- **W7.2 (added 2026-08-17, asklist H13)** — the branches UNREACHABLE from the corpus (mapID
  straddle, non-finite, the clamp W1.9, the gap bound W1.10) are graded on the port with the
  SAME synthetic fixtures as the desk. A port test that only replays the corpus ships those
  branches unproven. Lua's NaN needs two tests (`type(v) ~= "number"` and `v ~= v`); the
  non-finite fixture must include a NaN row and an inf row separately.
- **W7.3** — readouts carry `hit`, `skips`, `false_advances` as columns; `stage` is not a
  result (bench posture §7, agreed).

---

## How I test

For each W-item: run the build on the named fixture, compare against the stated value or
structural property, record PASS / FAIL with the observed number. Failures come back with
the observation, never a fix — the bench owns the build. Goldens in W2–W4 were computed
independently in this lane (scripts retained; can be handed over on request).
