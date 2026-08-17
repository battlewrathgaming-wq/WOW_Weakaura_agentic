# The WALK — BUILD RESULT (addons bench → analysis lane)

_2026-08-17. Against `driver_walk_acceptance.md` W0–W7. **W2, W3 and W4 PASS — all twelve
goldens reproduced.** W1/W5 are next; W6 is in-client and Battlewrath's hands._

**Run it yourself:**

    py addons/tools/walk.py check          all three, PASS/FAIL against the goldens
    py addons/tools/walk.py w2 | w3 | w4   one readout, numbers only
    py addons/tools/walk.py --run <frag>   another capture

Fixture: `addons/landing/corpus/20260817_025542__test1-16__legs.jsonl`, and the tool prints
its provenance on every run — raw clone path and sha256 — so a number here traces to bytes.

⚠ **The goldens live in `walk.py` as transcribed DATA, not read from your file.** Deliberate:
an auto-read would let the target move to meet the build. If W2–W4 change, that constant is
edited by hand and on purpose.

---

## Result

    W2  rows_both 1739 · sd_pos 1564 · sd_zero 175 (contiguous at start) · sd_zero_od_pos 0
        |sd-od|  mean 3.36e-06 · median 2.49e-06 · p99 1.27e-05 · max 1.89e-05
        sd range 0.0349 .. 264.4309
        od == 3D Euclid to pin within 1.14e-13   ·   2D off by up to 29.41 yd
        cross-floor rows 1467 · max 1.89e-05 · dz -69.9216 .. 5.2
        W2.2 divergence at eps=1: 0 rows flagged

    W3  samples 1738 · moving 1470 · p10 6.96 · p50 7.00 · p90 7.58 · p99 8.44 · max 9.02

    W4  every   kept    p50    p90    p99    max
        1.0s    349    0.01   0.75   1.61   2.41
        2.0s    175    0.19   2.37   4.15   5.01
        4.0s     88    1.31   6.32   9.58  11.43

---

## Two mismatches on the first pass, both diagnosed rather than tuned

**M1 — `W2.dz_max` gave +10.76 against your +5.2. Mine, a reading error.**
Your line states dz inside the cross-floor sentence; I computed it over all rows. **The number
was right for a question nobody asked.** Scoped to the cross-floor set it is −69.9216 .. 5.2.
No change needed on your side.

**M2 — W4 was low on eleven of twelve numbers, and the cause is a wording gap in W4.**

⚠ **Your text says "distance from each true point to the nearest segment of the decimated
path", which reads as GLOBALLY nearest. The implementation must be the TEMPORALLY BRACKETING
segment — the one spanning that point in time.** Bracketing reproduces all twelve numbers;
global reproduces none.

What was ruled out first, so this is not a guess:

    decimation      greedy-from-last-kept, greedy+endpoint, and fixed stride all give
                    IDENTICAL results -> it was never the path
    percentiles     `max` was wrong at 2s and 4s, and max is convention-free
                    -> it was never the percentile rule

★ **And bracketing is the better measure, which is why this is a wording fix rather than a
disagreement.** The decimated path *at that time* is where you would think the player was. The
globally nearest segment can be a different part of the route — a corridor they come back
through later — which **flatters** the reconstruction by measuring against a place they were
not at that moment.

**→ ASK: amend W4's wording to say bracketing.** The number is right; the sentence would send
the next implementer to the wrong measure, and it sent this one.

---

## What this settles, and what it does not

★ **W3 and W4 are now shipping constants rather than ledger entries**: design speed **7.0 yd/s**
(p50; the 30 yd/s ceiling stays inert), and **capture at 1 Hz — 2.41 yd max reconstruction
error, where 2 s is 5.01 and is not good enough.**

⚠ **W2.2's second half is NOT yet exercised.** You specify that the divergence detector must
flag every row where own distance > ε on the satnav boundary run
(`records/20260812_113949_493__satnav.json`, 57 in-dungeon rows at ts=0/sd=0). The walk reads
the run corpus, and that file is a satnav probe record with a different schema. **Reported
absent rather than claimed** — it needs either a reader for that shape or the 57 rows reduced
into corpus form. Say which you would rather have.

## W2.2b — the satnav rows reduced, and the second half PASSES

Your choice taken (H10): reduced into corpus form by the same emitter, not a second reader.
`addons/landing/corpus/*__satnav__legs.jsonl`, four probe runs, same provenance line.

    in-dungeon rows (mapID 389)   57
    engine sd                     0 on all 57
    own distance                  4733.0 .. 4736.8 yd
    divergence flags at eps=1     57 of 57      PASS

⚠⚠ **TWO FIELDS CANNOT BE PRODUCED FROM A SATNAV RECORD AND ARE NAMED, NOT BLANKED:**
`gt` (the probe never recorded GetTime) and `floor` (its `f` is FACING in radians). The header
carries `absentFields` for exactly this — **a blank column and a column nobody could fill look
identical downstream**, and a walk would read an unfilled floor as *no floor change* rather than
*no floor data*. `t` is reconstructed as `startedAt + elapsed` and labelled `tSource`.

★★ **And one thing worth your eye, because it nearly broke the test.** The probe DECLINES to
compute `hd`/`vd` across a map boundary — correctly; a distance to a pin in another coordinate
space is not a distance. My first reduction carried that decline forward, so `od` was absent on
exactly the 57 rows W2.2 exists to test and the detector had nothing to disagree with.

★ `od` is now computed from **raw positions**, and the reasoning is worth stating because it
generalises to the live detector: **it does not need the distance to be MEANINGFUL, only
COMPUTABLE.** It is not asserting *"you are 4,733 yards away"* — it is asserting **these two
sources disagree**, and the disagreement with the engine's `0.00` is the entire signal. The
probe's own `hd`/`vd` are kept alongside as `probe_hd`/`probe_vd`, so a reader can see that it
declined rather than infer it from a gap.

⚠ My own slip, recorded because it is the trap this emitter exists to prevent: I checked the
first result with `r.get('od', 0)`, which turned an ABSENT field into a zero and reported that
the detector found nothing. **Absent, not defaulted — including in the check.**

---

# J1 — W1, THE DETECTION RULE. **PASS, all eight criteria.**

    py addons/tools/walk.py w1

★ **Order was deliberate: the two criteria with ANALYTIC targets ran first**, because
everything after them rests on the primitive they prove. A corpus sweep run first would look
like evidence while grading its own homework — your closed form is the only target in W1 that
could not drift to meet my build, so it went first.

## W1.6 — your closed form reproduced

    closed form   point misses iff o > √(R² − (s/2)²) = 4.950758      R=5, s=1.4
    empirical     4.950714        bisected to 5e-04
    |difference|  4.34e-05

    segment misses at o ≤ R      0 of 501 offsets          PASS
    segment at o = R + 0.5       silent                    PASS (it never enters)

⚠ **The fixture is built at WORST-CASE PHASE and that is load-bearing.** Your form describes
the beacon's foot-of-perpendicular landing exactly midway between two samples. Put a sample
*on* the foot and the point test succeeds for every `o ≤ R` — **the fixture would then agree
with the formula for the wrong reason, and keep agreeing with a broken implementation.**
Samples are placed at odd multiples of `s/2` so `x = 0` is always a midpoint.

## W1.7 — band veto, including the case an endpoint test gets wrong

    level transit 10 yd above, band ±2                        silent   PASS
    ...same transit, band OPEN                                fire     PASS
    level transit 1 yd above, band ±2                         fire     PASS
    segment whose CLOSEST point is out of band                silent   PASS
    segment whose ENDPOINTS are out but closest point IS in   fire     PASS

★★ The last two are why H4 applies the band at the **interpolated** z. An endpoint test fails
both, and **fails them in opposite directions** — one false negative, one false positive.

## W1.2 / W1.3 — ⚠ SYNTHETIC BY NECESSITY, and this is worth your eye

**`mapID` is CONSTANT within every one of the 12 landed runs** (a dungeon is one instance), so
**no fixture we hold can reach the straddle guard at all.** A corpus-only test would have gone
green without ever executing the branch — the fixture could not fail. Seven synthetic cases,
all PASS: a same-map segment bridges a 40 yd gap and fires; a mapID change discards it and
stays silent; the straddle is *counted*, not hidden; a first sample falls back to point; an
unusable sample is counted and **breaks the chain rather than being bridged over**.

★ That last one: bridging across a hole would invent a straight path through data we do not
have.

**→ ASK: W1.2 says "previous sample absent, another mapID, or invalid" and does not define
invalid.** My reading: the **position** is unusable — missing x/y/z or mapID. It cannot mean
the tracker's state, since R-a puts detection on our own positions and consulting `ts` would
reintroduce the exact `0.00`-on-Invalid channel H0-b removed. Flagged rather than quietly
chosen; say if you meant something wider.

## W1.4 — no hold

One in-region sample fires: `point_hits=1`, `first=1`. ⚠ This is where a debounce would hide a
real transit — the arrival hold belongs to the consumer's arrival test, never to detection.

## W1.5 — monotonicity. **0 violations.**

    fixture                    R      beacons   point   segment   seg−pt
    SFK_live  (1102 rows)      2.0         21      20        21       +1
                               3.0         21      21        21        0
                            5/8/12         21      21        21        0
    SFK_Run4  (698 rows)       2.0         58      54        58       +4
                               3.0         58      57        58       +1
                            5/8/12         58      58        58        0

★★ **The advantage is entirely at small R and vanishes by R=5** — which is W1.6's closed form
showing up in real data rather than a synthetic. At R=2 with a 1 Hz capture the point test
loses four of 58 beacons; the segment test loses none.

## W1.8 — `while` semantics

    a slow pass enters once and exits once                     PASS
    ★ a transit too fast to SAMPLE inside does not flash       PASS
    ⚠ dithering across R does not flicker (hysteresis holds)   PASS
    a `while` region contributes nothing to progress           PASS

★★ The fast case is the whole reason `while` is POINT where `once` is SEGMENT: the segment
test would correctly report that the path passed through, and **that is not what an ambient
note is for.**

---

⚠ **W1.1 is not separately gradeable** — it *is* the implementation W1.6 and W1.7 prove. The op
sequence mirrors H4 including the order of the early-outs, since W7 will hold the Lua port to
the cost as well as the verdict: `point_fire` ~9 ops, `segment_fire` ~30 + 1 div, **no sqrt
anywhere**. The synthetic fixtures are functions in `walk.py` beside the tool, per J1.

---

# J2 — W5, THE TRANSIT METRIC. Emitted, no recommendation.

    py addons/tools/walk.py w5

## W5.1 — transit fraction, point vs segment

    SFK_live (21)    R=2   point 20  95%   segment 21 100%
                     R=3+  point 21 100%   segment 21 100%
    SFK_Run4 (58)    R=2   point 54  93%   segment 58 100%
                     R=3   point 57  98%   segment 58 100%
                     R=5+  point 58 100%   segment 58 100%

W1.5 holds throughout. The segment advantage is entirely at small R, as in W1.5.

## W5.2 — false advances, K=all and K=3. Both emitted.

    SFK_live   R    K=all adv  false    K=3 adv  false
               2         18      2         18      2
               3         19      2         19      2
               5          7      4         19      3
               8          8      3         20      2
              12          9      2         20      0
    SFK_Run4   2         18      4         56      1
               3         13      5         56      1
               5         14      6         54      4
               8         13      8         54      6
              12         17     10         54      6

⚠ **`K=all` collapses the advance count as R grows** — 58 beacons, 13 advances at R=8. With no
forward bound any beacon the player is near early wins, and everything before it becomes a skip.
No recommendation per W5.2; the shape is the readout.

★ A beacon never visited counts as a false advance, deliberately — advancing past a stage the
player never reached is the same fault as advancing early, and treating `None` as "no
constraint" would hide the case the metric exists for.

## W5.3 — stage timeline · W5.4 — self-replay **PASS**

    SFK_live   stage 21 of 21 at R=5      SFK_Run4   stage 58 of 58 at R=5

⚠ **But `stage` is a weak number and I nearly shipped it as the headline.** It is inflated by
skips: with `K=all` the ratchet reaches the end having detected almost nothing. Every table now
carries `hit` beside it. **My first W5.5 and two-rates readouts both showed 100% and
demonstrated nothing** — a readout that cannot move is not evidence, and it read as success.

★★ **And the structural result underneath: detection ≠ progression.** All 21 SFK_live beacons
are detectable at R=5, and the ordered ratchet converts **19** into stage advances. The gap is
the ordering constraint, not the rule.

## W5.5 — cross-fixture, numbers only

    legs from     route from      R   reached   hit   skip
    SFK_live      SFK_Run4      5.0        58    14     44
    SFK_live      SFK_Run4     12.0        58    16     42
    SFK_Run4      SFK_live      5.0        21    18      3
    SFK_Run4      SFK_live     12.0        21    10     11

⚠ `boss-set` as a cause is **ABSENT, not zero** — no marker in either fixture carries a boss
identity, so the branch has nothing to fire on. Reported rather than left as an empty column.

---

# ⚠⚠ ONE FINDING THAT CONTRADICTS W5's TWO-RATES NOTE

Your note says the walk's miss counts *"bound the live driver from the PESSIMISTIC side."*
Measured on test1 (0.2 s, the one fixture where replay cadence == live cadence), same legs,
same route, decimated:

    cadence   rows    R=1   R=2   R=3   R=5      of 21
    0.2 s     1739     12    18    18    18
    1 Hz       348     13    16    16    18

R=2/R=3 lose two beacons to 1 Hz and converge by R=5 — that is your note, confirmed.
**⚠ But at R=1 the COARSER path detects MORE: 13 against 12.**

**My reading, offered as a candidate mechanism and not as a finding:** decimation does not only
drop samples, it **changes the polyline**. A straight segment between samples 7 yd apart cuts
corners — passing through space the player never occupied. Where a beacon sits inside a cut
corner, the walk reports a transit that never happened.

★★ If that is right, the bound is **one-directional, not symmetric**: the walk is pessimistic
on misses and can be **optimistic on corner-cutting**, and the two do not cancel. It would also
mean a small-R beacon authored against a 1 Hz capture can be validated by a path artefact.

**→ ASK: does this change W5's note, and is it worth a criterion of its own?** I have the
number and a plausible mechanism; I have not proved the mechanism, and proving it wants a
synthetic (a beacon placed inside a known cut corner) rather than more corpus.

---

**Docket:** J1 ✓ · J2 ✓ · J3 ✓ (1,386/1,386) · J4 ✓ (§269) · J6 ✓ (§272). **J5 is
Battlewrath's trip.**

---

# `rfc_combat` — the first fixture that is 0.2 s AND has combat

_2026-08-17. Ragefire Chasm, Reaper (`Gravereaper`), fought through. 1,933 legs · 26 markers
(10 start · 10 end · **6 authored design pins**) · pin held at the deep end · `sd` 415 → 36._

    py addons/tools/read_tracker_state.py runs --run rfc_combat

## ★★★ THE HEADLINE: DETECTION HAPPENS IN THE COMBAT GAPS

Battlewrath, and it reframes W5: *"pulls can be protracted motion pulling in many mobs. But
that's not where the detectors will be. It's more the gaps of combat where that pull is
complete and you need to accelerate them onto the next target/boss."*

    the gaps are 24% of the run      92.7 s of 393.8 s, in 9 windows
    window length                    1.2 – 13.6 s
    window distance                  0 – 78 yd
    pace INSIDE a gap                p50 6.97 · p90 7.43 · p99 11.02 · max 42.29
    pace everywhere else             p50 1.46 · p90 7.33 · p99 14.12 · max 50.59

★ **That is the driver's entire operating envelope and nothing in W5 models it.** A route walked
against the whole record grades the driver on 76% of a run where it has no work to do.

⚠ The single 42.29 inside a gap is at t=211.6, and Taragaman engages at t=211.4 — a gap-closer
fired **into** the boss as the gap closes. One sample of 267. **The driver never sees the tail.**

## ★★★ THE LURE / DESTINATION SPLIT IS IN THE DATA, SIX FOR SIX

Six pins were placed as a designer would place them — *"leading a player to the mobs, or pointing
them past the mobs as the target; not inside of the mobs, that's visual noise when they need to
be focusing on the fight."*

    pin   where              what follows (net/path, 20 s)     20 s baseline 0.68
     2    in break 3         travel 0.73
     3    in break 4         travel 0.87
     5    in break 9         travel 0.79
     1    in combat          mixed  0.58
     4    in combat          CLUSTER 0.27 — Taragaman, 61% stationary
     6    in combat          hold   0.40 — 0.7 s before Jergosh engages

★★ **The three pins in gaps are exactly the three followed by travel.** No overlap. So an
authored route carries **at least two kinds of beacon**, distinguished by where they sit relative
to combat — and a route built from combat markers has only one kind in it.

⚠ **→ This is the challenge to W5's pseudo-beacon model, now with a mechanism rather than a
distance.** The six pins also sit 5–49 yd from the nearest combat marker, so the positions differ
too; but the functional split is the part that matters.

★ A third element Battlewrath names and I have **not** isolated: a **skip** — a pin, then a C
motion around a pillar to detour past mobs, then a lead into combat. Reported as absent from my
analysis rather than claimed: my 20 s window and net/path measure do not separate a C from a
wander, and finding it needs a curvature measure I have not built.

## ★★ `while` RADII, MEASURED — 18 and 30 yd, and not one number

From **boss engagement** to combat end (not combat start — the bracket includes the approach and
over-reports by 2–3×):

    Taragaman the Hungerer   38.7 s   r50  5.0   r90  8.1   r99  9.2   rMAX 17.4   dz 1.2
    Jergosh the Invoker      35.2 s   r50 14.8   r90 29.0   r99 29.3   rMAX 29.4   dz 0.9

★ Two shapes, not one: Taragaman is a tight fight (99% inside 9.2) **with a single excursion to
17.4**; Jergosh is a genuinely wide arena occupied evenly. **So R must cover the excursion, not
the median** — `r99` would have given Taragaman 10 yd and dropped the fight.

★★ Both flat (dz ≈ 1), so a boss `while` is a true 2D region and its band can be tight.

⚠⚠ **This was only measurable because of `bosses` — a captured field with no consumer until
now.** §17 recorded that a boss NAME is available and a grouping is not, and stopped there. The
name plus its engagement timestamp is the only thing that separates the fight from the approach.

## ⚠⚠ W4's 1 Hz RECONSTRUCTION CONSTANT IS DOUBLED BY COMBAT

Deviation of the true path from the straight line across one 1 Hz stride:

    this run (with combat)   p50 0.12   p90 0.95   p99 1.81   MAX 4.95 yd
    W4 on test1 (cleared)                                     MAX 2.41 yd

★ **And it splits along the same line as everything else here:** the worst deviation *inside a
gap* is **2.22 yd**, so W4's figure holds where the driver works. The 4.95 is inside a pull.
**W4's number is right for the driver and wrong for authoring**, if a route is authored against a
1 Hz capture that includes fighting.

## Two constants and a test

- **⚠ `MAX_CLOSING_SPEED = 30` is exceeded** — peak 50.59 yd/s, 14 samples over. It has a
  measurement now (the asklist flags it as *"one number exists and it is NOT a measurement"*).
  ★ But it is exceeded only inside pulls, so **the constant is wrong and it does not matter** —
  worth stating precisely rather than as an alarm.
- **⚠ A-2's LENGTH-based teleport test stays weak.** The tail is `Scythe Rush`, a **2-tick charge**
  — ~20 yd over 0.4 s, confirmed as real traversal both by the tick structure (never a single
  tick) and by `Input/reaper_talents.json`: *"**Rush towards** an enemy."* `v_max` would need ≥51
  to keep it, which permits 51 yd at 1 Hz and constrains nothing. **The `dt` half is the one that
  works** — it detects missing samples, which is the actual fault.
- **★★ The regime change is confirmed and the three old RFC fixtures should RETIRE.** Max sample
  gap here is **0.23 s**; the pre-regime RFC runs had 43, 69 and 125 s holes, every one of them
  spanning a combat start. **→ ASK: does this run replace them in W5, or join them?** Replacing is
  my reading; it is your fixture set to rule on.

## What did NOT reproduce

⚠ My posture §3 said the segment advantage persists past R=5 in RFC. **Retracted entirely.** That
was measured on the pre-regime fixtures, where the segment test was bridging 125-second combat
holes rather than detecting better. It said nothing about the rule.

---

# WHERE THE TESTING IS UP TO — 2026-08-17, at `§285`

_Everything below is runnable. `walk.py` prints its fixture and sha on every mode._

## Acceptance state

    W1    PASS, all ten          incl. W1.9 (clamp) and W1.10 (gap bound)
    W2    PASS                   goldens reproduce
    W3    PASS                   design speed 7.0 yd/s
    W3.2  EMITTED                the band, sourced — no constant ruled here
    W4    PASS                   goldens reproduce
    W5    EMITTED + W5.4 PASS    ruled fixture set; boss-set accounting balances
    W6    NOT STARTED            the live chain probe — Battlewrath's trip
    W7    NOT APPLICABLE YET     no Lua consumer exists

    py addons/tools/walk.py w1 | w2 | w3 | w32 | w4 | w5 | check

## Docket, closed

    J1 W1 · J2 W5 · J3 W2.2b (1,386/1,386) · J4 ts through reduce_run · J6 check_interface
    A-1 clamp · A-2 gap bound · A-3 semantics pinned · A-4 cut-corner fixture reproduced
    A-5 variance rule → verifier · A-6 posture §11 restated

## Measured since the last hand-back

    jump apex        [1.6404, 1.7368] — zspeed 8.0 gives 1.6588, the only candidate
                     in range. 1.27 and 1.5 below the peak; OUR OWN §73 1.9 above
                     the bound and RETIRED
    character height ankles→hips 0.9645 yd standing → hip ~1.06, total ~1.9–2.1 yd
    z datum          corroborated as the BASE POINT — ankle-deep reads −0.11, hip-deep
                     −1.08; a model centre would have read ≈ +0.85
    UnitPosition     DOES NOT EXIST here — settled by asking, not by census
    mount            jump 1.5726 · top speed 17.50 yd/s (under MAX_CLOSING_SPEED's 30)

## ⚠⚠ ONE CORRECTION THAT CHANGES A DESIGN INPUT

**`bandUp` does not need to admit a jump, and I had that backwards for two commits.**
Battlewrath, §285: *"the height band up only exists to protect running over it from a second
floor. And the MAX doesn't need to be any height any character can ever reach. They always
land back onto the floor."*

★ A jump is **transient** — the player returns to the floor, so the beacon fires on landing
whatever the band does at the apex. I read a measurement as a constraint.

⚠ Which means **±2.5 is LOOSE, not comfortable.** `bandUp`'s floor is jitter (0.1886
measured); its ceiling is the smallest vertical separation between two real surfaces. §73
recorded distinct surfaces **1.30 yd apart** — stack two of those and ±2.5 conflates them.
The 9.71 walkway is the only stack we have measured, so **±2.5 is safe against what we hold
and not against what exists.** Emitted as an exposure, not a proposed number.

## ★★★ AND A SCOPE FENCE IS NOW IN `walk.py`

It drifted twice — once into modelling combat (H15), once into deriving physics. The fence
states the whole product question and lists what has already been pulled back, with the test
that decides a new measurement: **does the driver READ this at runtime, or does an author
read it once while placing a beacon? If neither, it is a model of the game and does not
belong.**

## Open

    W6            the live chain probe — in-client, Battlewrath's
    a two-race z  the base-point row's only residual — two characters of different
                  races on one spot. The emulator answers it; this would confirm
                  our fork-native getter
    16 commits    unpushed
