> ⚠ **BENCH CLAIMS AT THEIR DATE — HISTORY. Read `DRIVER_BASIS.md` first.** Attacked in
> `driver_reconciliation.md`; §3 retracted; some rows superseded. Not a build reference.

# DRIVER — CURRENT POSTURE, written to be attacked

_Addons bench → analysis lane, 2026-08-17, at `dbb63e7`. **Every live claim in falsifiable
form.** Not a summary and not an argument: each entry states the claim at its narrowest true
size, what it rests on, **the specific observation that would kill it**, and who has actually
checked it._

> Battlewrath, on why this exists: *"Agreement is nice. Having your posture challenged and
> still confirmed is better."*

## ⚠ How to attack this efficiently

★ **The `CHECKED BY` line is the map.** Anything reading *bench only* has never been outside my
own head. Start there — not at the claims I have the most evidence for.

⚠ **And the ranking below is by CONSEQUENCE, not confidence.** A weak claim nothing rests on is
cheaper to leave standing than a strong claim the port will be built on.

---

# TIER 1 — if these are wrong, built work is wrong

## 1. The segment test implements H4 correctly

    CLAIM       point-to-segment on xy, band at the interpolated z, squared distances,
                no sqrt — reproduces the analysis lane's closed form
    BASIS       empirical boundary 4.950714 vs closed form 4.950758; |diff| 4.34e-05.
                Segment never misses at o ≤ R over 501 offsets; silent at o = R + 0.5
    KILLS IT    a transit geometry where segment fires and no path within R exists,
                or where a real transit within R produces silence
    CHECKED BY  analyst (independent run, §H12) + bench
    ⚠ CAVEAT    the fixture is built at WORST-CASE PHASE. If that construction is wrong,
                the agreement is coincidental and would survive a broken implementation

## 2. W1 is the golden and the port must reproduce it, including `usable()`

    CLAIM       detection validity = position unusable (nil or non-finite), never ts/sd
    BASIS       ruled by the analysis lane; implemented and exercised on NaN / inf / nil
    KILLS IT    a landed row that is legitimately detectable but fails `usable()`
    CHECKED BY  analyst (definition) + bench (implementation)
    ⚠ THE PORT  Lua has two tests where Python has one — `type(v) ~= "number"` and
                `v ~= v`. If W7 grades only the first, the NaN branch ships unproven

## 3. ⚠⚠ **CORRECTED BY ME, AN HOUR AFTER I WROTE IT** — the segment advantage does *not* vanish by R=5

    I WROTE     "the advantage is entirely at small R and vanishes by R=5"
    IT IS NOT   that is an SFK property. Three RFC fixtures had never been run:

        RFC_run1 (30)   R=2 +10   R=3 +5   R=5 +5   R=8 +4   R=12 0
        RFC_Run2 (28)   R=2  +8   R=3 +8   R=5 +3   R=8  0
        RFC_Run3 (26)   R=2  +2   R=3 +4   R=5  0
        SFK_live (21)   R=2  +1   R=3  0
        SFK_Run4 (58)   R=2  +4   R=3 +1   R=5  0

    SO          the advantage persists past R=5 in two of three RFC fixtures, and RFC's
                point-test detection is far worse throughout (15 of 30 at R=2)
    KILLS IT    nothing — this IS the correction. What remains open is WHY RFC is harder
    CHECKED BY  bench only, self-challenged. Never independently run

★★ **The generalisation was the error, not the measurement.** Two SFK fixtures agreed and I
stated a property of the dungeon as a property of the rule. ⚠ **W5's whole readout inherits
this** — every W5 number is SFK, and the acceptance named those fixtures, so the gap was
specified rather than chosen. It is still a gap.

## 4. Monotonicity — segment never detects fewer than point

    CLAIM       W1.5 holds on every fixture and every R
    BASIS       0 violations across FIVE fixtures, two dungeons, 5 radii (was 2 fixtures)
    KILLS IT    one (fixture, R) pair where point > segment. A single case is a bug
    CHECKED BY  bench; the SFK half by the analyst
    ★ NOTE      this is the one claim the RFC run STRENGTHENED

---

# TIER 2 — if these are wrong, a criterion changes

## 5. ⚠ The two-rates bound is NOT symmetric

    CLAIM       the walk is pessimistic on misses AND optimistic on corner-cutting
    BASIS       test1, same legs same route, 0.2 s vs 1 Hz:
                  R=2/R=3   1 Hz detects FEWER (18→16)   — your note, confirmed
                  R=1       1 Hz detects MORE  (12→13)   — your note does not cover it
    MECHANISM   MY READING, UNPROVEN: decimation changes the POLYLINE. A segment between
                samples 7 yd apart cuts corners, through space the player never occupied
    KILLS IT    a synthetic with a beacon placed inside a known cut corner that does NOT
                fire on the decimated path. That settles it in one fixture
    CHECKED BY  bench only
    ⚠ WHY IT MATTERS  a small-R beacon AUTHORED against a 1 Hz capture could be validated
                by a path artefact rather than by a place the player went

## 6. Detection is not progression

    CLAIM       all 21 SFK_live beacons are detectable at R=5; the ordered ratchet
                converts 19. The gap is the ordering constraint, not the rule
    BASIS       W5.1 vs W5.2 on the same fixture and radius
    KILLS IT    showing the two missing advances are a ratchet bug rather than
                out-of-order arrival — i.e. the beacons WERE reached in order
    CHECKED BY  bench only

## 7. ⚠ `stage` is not a result

    CLAIM       the ratchet's stage index is inflated by skips and cannot be read as
                coverage; `hit` is the honest column
    BASIS       K=all, SFK_Run4 route walked by SFK_live legs: reached 58 of 58 with
                14 hits and 44 skips
    KILLS IT    nothing that I can see — but I shipped `stage` as the headline first and
                it showed 100% everywhere, so the failure mode is real and mine
    CHECKED BY  bench only

---

# TIER 3 — the instrument study. Nothing is built on these.

## 8. The tracker's target state

    CLAIM       ts 0 = declined (cross-map pin) · 2 = tracking · 4 = within 5.5 yd
    BASIS       (5.4603, 5.5172], 6,809 rows, 8 runs, TWO instruments (satnav probes
                outdoors 2026-08-12; dev captures in two dungeons 2026-08-17),
                0 rows contradicting `sd ≤ 5.5 ⟺ ts == 4`. No hysteresis, no latency
    KILLS IT    one row with ts == 4 above 5.5172 or ts == 2 below 5.4603
    CHECKED BY  bench only
    ⚠ BOUNDED   every pin measured was one WE set. A real quest POI has never been
                walked, so a per-POI radius is unexcluded, not ruled out. And `sd` is 3D,
                so this close a 2D threshold fits the same data
    ★ STATUS    a VERIFIER, not a mechanism. Both states are reproducible from data we
                already hold, so nothing depends on it

## 9. The client acts on none of it

    CLAIM       ts == 4 is not a satisfaction signal — the game does nothing at 5.5 yd
    BASIS       the pin survived four round trips in and out; ts returned to 2 each time
                with a valid growing sd. Had the game retired the pin, crossing twice
                would have been impossible
    KILLS IT    any client-side effect at the boundary — an event, a UI change, a clear
    CHECKED BY  bench + Battlewrath (observed in game)

---

# TIER 4 — the view and the pipeline

## 10. ~~The corpus view is complete, by a rule I invented~~ → **RESTATED (A-5)**

⚠ **The attack was aimed at a rule I had DESCRIBED but never written.** I wrote §10 as
though *"constant within a run → header, varies → row"* were evaluated at emit time. It is
not. `CORE`, `CARRIED` and `OMITTED` are module constants and `zone` is always a header key
— **placement is fixed by kind and no field can move between files.** The constant/varies
rule was the *audit* that decided those tuples once, in §269. My wording, not the code, was
the fault, and A-5 read the wording correctly.

★ **But the attack left a real hole and it is now closed as they asked — a verifier, not a
mechanism.** Those tuples were decided on twelve runs; nothing stopped the thirteenth from
varying a field called constant, and the emitter would have carried on omitting it in
silence. `variance_warnings()` now runs at emit and shouts into both the console and the
artifact header.

    CLAIM       field placement is FIXED; the variance rule runs as a CHECK
    BASIS       CORE/CARRIED/OMITTED are module constants — verified, not asserted
    KILLS IT    a field that varies and is still omitted, or a header key that is not
                constant within its run. Both now shout rather than pass.
    CHECKED BY  bench; A-5 is the ruling it implements

★★ **And it earned its keep on the first run: `floor` is absent from EVERY row of
`RFC_run1_clean` and `RFC_Run2_Messy`.** Those two predate its capture, so they cannot be
used for anything vertical — a hole I had not noticed while using `floor` in analysis.

⚠⚠ **It also forced a distinction that resolves an ambiguity I had flagged and left open:**

    UNCONDITIONAL absent   IT WAS NOT CAPTURED — every position has a floor. A defect.
    CONDITIONAL   absent   IT DID NOT HAPPEN — `combat` is only written while in combat.
                           Correct, not a defect. Named in the header as
                           `conditionalAbsent` so it cannot be read as a hole.

★ That is why `combat` is absent on both the pre-regime RFC runs *and* on `test1`: the
build never wrote it in one case, nothing happened in the other. Identical downstream,
opposite causes, and until now nothing separated them.

## 11. ~~`mapX`/`mapY` were dropped, so C1 was uncheckable~~ → **WRONG. RESTATED (A-6).**

⚠⚠ **My claim was false and they killed it on the condition I named.** I said C1's
transform *"could not be re-checked against the view that proved it"* — and named the kill
condition myself: *showing C1 was verified from somewhere else the whole time.* It was.
C1's proof lives in the worldmap emitter's own self-proof and in `verify_calibration.py`
over the raw records, so it was **re-proven on every emit** and never depended on the
corpus at all.

★ This is the entry I flagged as most wanting a second opinion, because it was a claim about
someone else's work made from my side alone. The mechanism worked exactly as intended: I
stated the kill condition, they met it, the claim dies.

**What survives, and it is narrower:**

    CLAIM       the corpus VIEW should carry mapX/mapY so the check is re-runnable from
                the LANDED RECORD rather than only from raw
    BASIS       both vary on all 12 runs and were in neither CORE nor CARRIED until §269
    NOT         a checkability failure — C1 was always checkable
    CHECKED BY  A-6, and it is their file to speak for

★ A view-completeness point, which is a real but much smaller thing than what I wrote.

## 12. ~~The straddle branch is unreachable from the corpus~~ — ★ KILLED, §298

    CLAIM       mapID is constant within all 12 landed runs, so W1.3 cannot be tested
                on any fixture we hold — it is synthetic by necessity
    BASIS       measured across every landed run
    KILLS IT    one landed run whose mapID changes mid-record
    CHECKED BY  bench only
    ★ CONSEQUENCE  the same is now true of the non-finite branch (0 of 9,667 rows)

    ★★★ KILLED, exactly as written, 2026-08-18 (§298)
        20260812_113949_493__satnav__legs.jsonl   mapIDs {1: 29, 389: 57}
                                                  ONE change, at row 29
                                                  full xyz on all 86 rows
        W1.3 now runs against it and the guard fires (straddles=1).

⚠ **The BASIS line is where it went wrong, and it is worth more than the claim.** *"Measured
across every landed run"* was true — I measured each run and found each one internally
consistent. But the question was per-ROW, and **a per-run summary cannot answer a per-row
question.** The measurement was real; it was aimed one level too coarse, and I did not notice
because it returned an answer.

★ So the CONSEQUENCE line inherits the same doubt: 0 of 9,667 rows non-finite is a per-row count
and stands on its own footing — but it is now the only leg this section has, and it has not been
tested by anything trying to kill it.

---

# Where I think I am weakest, ranked

1. **§3 / W5's SFK-only fixtures.** I generalised from two fixtures of one dungeon and was
   wrong within the hour. Every W5 number carries the same exposure and I have not re-run it.
2. **§5's corner-cutting mechanism.** I have the number and a story. The story is unproven and
   arrived fluently, which is my own recorded tell.
3. **§10's classification rule.** Invented by me, applied to 12 runs, never argued.
4. **§11.** A claim about the checkability of your work, made from my side alone.

⚠ **What I am NOT claiming:** that any of this is settled because it passed. W1 passed on my
implementation of a definition that was written afterwards; W5 passed on fixtures the
acceptance chose; the tracker bracket has never seen a pin we did not set.
