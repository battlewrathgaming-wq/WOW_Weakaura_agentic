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

**Next on this bench:** W1 (detection rule) and W5 (transit metric), where the criteria are
structural and the numbers are mine to produce. Then W6 in-client, which is Battlewrath's trip
and carries F-ii's evidence plus H5's two facts.
