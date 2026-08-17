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
    rule      the driver's rule EXACTLY as the consumer will run it (advisory §6, asklist H4):
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

## W3. Speed readout — golden from test1

Consecutive-sample 3D speed, dt in (0.1, 0.5), same mapID, moving = > 0.5 yd/s:

    samples 1738 · moving 1470 · p10 6.96 · p50 7.00 · p90 7.58 · p99 8.44 · max 9.02 yd/s

- **W3.1** Reproduced to 0.01. Design speed = 7.0 yd/s (mounting is rare by construction —
  Battlewrath; the 30 yd/s ceiling stays as an inert constant).

## W4. Q4 readout — golden from test1

True 0.2 s path vs decimated polyline; error = distance from each true point to the nearest
segment of the decimated path, 2D xy (p50 / p90 / p99 / max, yd):

    1.0 s    0.01 / 0.75 / 1.61 / 2.41
    2.0 s    0.19 / 2.37 / 4.15 / 5.01
    4.0 s    1.31 / 6.32 / 9.58 / 11.43

- **W4.1** Reproduced to 0.01. Constant that ships: capture at 1 Hz; do not go coarser.

## W5. Transit metric — the walk proper (numbers to be produced, criteria structural)

Route = marker positions of a fixture (SFK_live: 21, SFK_Run4: 58) as pseudo-beacons,
ordered by first-visit time; sweep R ∈ {2, 3, 5, 8, 12}; band open.

- **W5.1** Per R, report transit fraction under point and under segment; W1.5 holds.
- **W5.2** Under K = all, report false advances (a later beacon firing before an earlier
  one's first visit); under K = 3, report again. Emit both — no recommendation.
- **W5.3** Stage timeline emitted per run: (stage, gt, cause ∈ hit|skip|boss-set).
- **W5.4** Replaying the run that GENERATED the markers must reach the last stage (a run
  passes through its own kill positions by construction). If it does not at R = 5, the walk
  or the marker positions are wrong — that is the first thing to look at.
- **W5.5** Cross-fixture: SFK_Run4's route walked by SFK_live's legs, and vice-versa —
  numbers emitted, no grade.

## W6. Live CHAIN probe (bench, in-client, minutes) — the one thing the desk cannot prove

Set A → walk → release → set B → walk. Criteria:
- **W6.1** After release-then-set, the tracker renders and tracks B (state valid, sd
  matches own distance to B within ε).
- **W6.2** The switch is recorded in a capture row (a `pin` change visible in the record),
  so the walk can replay it.
- **W6.3** Note what happens to the player's own quest tracker across the sequence — this
  is F-ii's evidence, recorded, not ruled here.

## W7. Port fidelity (when the Lua consumer exists)

- **W7.1** The Lua rule, fed the same fixture rows at the same cadence, produces the same
  stage timeline (W5.3) and the same per-beacon first-hit indices as the desk walk.
  Byte-equal on the emitted timeline. This is the golden; the desk is the reference.

---

## How I test

For each W-item: run the build on the named fixture, compare against the stated value or
structural property, record PASS / FAIL with the observed number. Failures come back with
the observation, never a fix — the bench owns the build. Goldens in W2–W4 were computed
independently in this lane (scripts retained; can be handed over on request).
