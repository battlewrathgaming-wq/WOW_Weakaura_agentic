r"""walk.py - THE WALK: the driver's rule, executed offline against recorded runs.

★★★ WHAT THIS IS. The desk simulator for the driver that does not exist yet. It runs the
detect-and-advance rule over `addons/landing/corpus/*__legs.jsonl` and reports what would
have happened. **It is how the spec gets tested BEFORE the driver is built, and it becomes
the GOLDEN the Lua port has to reproduce on the same corpus.**

Spec: `addons/planning/driver_walk_acceptance.md` (W0–W7), written by the analysis lane.

★★ THE GOLDENS EXIST BEFORE THIS CODE DID, and that is the whole point. W2/W3/W4 carry
numbers already computed from `test1`. This does not get to decide what right looks like;
it either reproduces them or it does not. **A passing walk is evidence rather than
agreement** — which is only true while the numbers came first.

⚠ NO CLIENT, NO GUESSING. Every input is a landed record with provenance. Where a number
cannot be derived from the corpus it is REPORTED ABSENT, never defaulted — a default here
would be indistinguishable from a measurement in the output.

    py addons/tools/walk.py w2          calibration readout (goldens in W2)
    py addons/tools/walk.py w3          speed readout (golden in W3)
    py addons/tools/walk.py w4          reconstruction error (goldens in W4)
    py addons/tools/walk.py check       all three against the stated goldens: PASS/FAIL
    py addons/tools/walk.py --run <fragment>    pick a capture (default: test1)
"""

import argparse
import glob
import io
import json
import math
import os
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__)).replace("\\", "/")
ROOT = os.path.dirname(os.path.dirname(HERE))
CORPUS = ROOT + "/addons/landing/corpus"

# ★★ THE GOLDENS, transcribed from driver_walk_acceptance.md W2–W4. They live here as
# DATA so `check` can compare rather than a human eyeballing two columns.
# ⚠ Transcribed, not derived. If the acceptance file changes these must be updated by
# hand and deliberately - an auto-read would let the target move to meet the build.
GOLD = {
    "run": "test1",
    "w2": {"rows_both": 1739, "sd_pos": 1564, "sd_zero": 175, "sd_zero_od_pos": 0,
           "mean": 3.4e-06, "median": 2.5e-06, "p99": 1.3e-05, "max": 1.9e-05,
           "sd_min": 0.03, "sd_max": 264.43,
           "cross_floor_rows": 1467, "cross_floor_max": 1.9e-05,
           "dz_min": -69.9, "dz_max": 5.2},
    "w3": {"samples": 1738, "moving": 1470,
           "p10": 6.96, "p50": 7.00, "p90": 7.58, "p99": 8.44, "max": 9.02},
    "w4": {1.0: (0.01, 0.75, 1.61, 2.41),
           2.0: (0.19, 2.37, 4.15, 5.01),
           4.0: (1.31, 6.32, 9.58, 11.43)},
}


# ---------------------------------------------------------------------------
# Loading
# ---------------------------------------------------------------------------

def load(fragment):
    """A corpus file as (header, rows). ⚠ The header is line ONE and carries the
    provenance; a reader that skips it is reading numbers with no source."""
    hits = [p for p in sorted(glob.glob(CORPUS + "/*__legs.jsonl"))
            if fragment.lower() in os.path.basename(p).lower()]
    if not hits:
        return None, None, "no corpus file matching %r in %s" % (fragment, CORPUS)
    path = hits[-1]
    head, rows = None, []
    with io.open(path, encoding="utf-8") as fh:
        for i, line in enumerate(fh):
            line = line.strip()
            if not line:
                continue
            try:
                o = json.loads(line)
            except ValueError as e:
                # ⚠ A bad row costs a ROW. JSONL was chosen for exactly this.
                print("   ⚠ line %d unparseable, skipped: %s" % (i + 1, e))
                continue
            if i == 0 and o.get("_kind"):
                head = o
            else:
                rows.append(o)
    return head, rows, path


def pct(vals, p):
    """Nearest-rank percentile on a sorted copy. ⚠ Stated because percentile
    conventions differ and a golden compared against a different convention fails for
    a reason that looks like a bug in the measurement."""
    if not vals:
        return None
    s = sorted(vals)
    k = max(0, min(len(s) - 1, int(math.ceil(p / 100.0 * len(s))) - 1))
    return s[k]


def d3(a, b):
    return math.sqrt((a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2 + (a[2] - b[2]) ** 2)


# ---------------------------------------------------------------------------
# W2 - calibration
# ---------------------------------------------------------------------------

def w2(head, rows):
    pin = head.get("testPin") or {}
    px, py, pz = pin.get("x"), pin.get("y"), pin.get("z")
    pin_floor = pin.get("floor")

    both = [r for r in rows if r.get("sd") is not None and r.get("od") is not None]
    sd_pos = [r for r in both if r["sd"] > 0]
    sd_zero = [r for r in both if r["sd"] == 0]

    # ⚠ The acceptance file says the zero rows are CONTIGUOUS AT THE START. That is a
    # structural claim, not a count, so it is checked structurally.
    idx = [i for i, r in enumerate(both) if r["sd"] == 0]
    contiguous = bool(idx) and idx == list(range(len(idx)))

    diff = [abs(r["sd"] - r["od"]) for r in sd_pos]
    euclid_err = None
    if px is not None:
        # ★ Does `od` equal a 3D Euclid to the pin? The acceptance file says to 1e-13,
        # and that 2D is off by up to 29 yd - which is what makes it a 3D proof.
        e3 = [abs(r["od"] - d3((r["x"], r["y"], r["z"]), (px, py, pz)))
              for r in both if r.get("z") is not None]
        euclid_err = max(e3) if e3 else None
        e2 = [abs(r["od"] - math.sqrt((r["x"] - px) ** 2 + (r["y"] - py) ** 2))
              for r in both if r.get("z") is not None]
        two_d_off = max(e2) if e2 else None
    else:
        two_d_off = None

    cross = [r for r in sd_pos if pin_floor is not None and r.get("floor") != pin_floor]
    cross_diff = [abs(r["sd"] - r["od"]) for r in cross]
    # ⚠ dz IS SCOPED TO THE CROSS-FLOOR SET, not to all rows. W2 states it inside the
    # cross-floor line and I first read it as a whole-run range - which gave +10.76 against
    # a golden of +5.2. The number was right for a question nobody asked.
    dz = [r["z"] - pz for r in cross if pz is not None and r.get("z") is not None]

    return {
        "rows_both": len(both), "sd_pos": len(sd_pos), "sd_zero": len(sd_zero),
        "sd_zero_contiguous_at_start": contiguous,
        "sd_zero_od_pos": sum(1 for r in sd_zero if r["od"] > 0),
        "mean": (sum(diff) / len(diff)) if diff else None,
        "median": pct(diff, 50), "p99": pct(diff, 99), "max": max(diff) if diff else None,
        "sd_min": min(r["sd"] for r in sd_pos) if sd_pos else None,
        "sd_max": max(r["sd"] for r in sd_pos) if sd_pos else None,
        "od_is_3d_euclid_within": euclid_err,
        "od_vs_2d_max_gap": two_d_off,
        "cross_floor_rows": len(cross),
        "cross_floor_max": max(cross_diff) if cross_diff else None,
        "dz_min": min(dz) if dz else None, "dz_max": max(dz) if dz else None,
        # ★ W2.2 - the divergence detector, at the epsilon the acceptance file names.
        "diverge_flags_eps1": sum(1 for r in both if abs(r["sd"] - r["od"]) > 1.0),
    }


# ---------------------------------------------------------------------------
# W3 - speed
# ---------------------------------------------------------------------------

def w3(rows):
    """Consecutive-sample 3D speed. ⚠ The filters are the acceptance file's, verbatim:
    dt in (0.1, 0.5), same mapID, moving = > 0.5 yd/s. A different gate gives a
    different p50 and the golden would fail for the wrong reason."""
    sp, n = [], 0
    for a, b in zip(rows, rows[1:]):
        if a.get("gt") is None or b.get("gt") is None:
            continue
        dt = b["gt"] - a["gt"]
        n += 1
        if not (0.1 < dt < 0.5):
            continue
        if a.get("mapID") != b.get("mapID"):
            continue
        if None in (a.get("z"), b.get("z")):
            continue
        v = d3((a["x"], a["y"], a["z"]), (b["x"], b["y"], b["z"])) / dt
        if v > 0.5:
            sp.append(v)
    return {"samples": n, "moving": len(sp),
            "p10": pct(sp, 10), "p50": pct(sp, 50), "p90": pct(sp, 90),
            "p99": pct(sp, 99), "max": max(sp) if sp else None}


# ---------------------------------------------------------------------------
# W4 - reconstruction error under decimation
# ---------------------------------------------------------------------------

def seg_dist2d(p, a, b):
    ax, ay = a
    bx, by = b
    ex, ey = bx - ax, by - ay
    ee = ex * ex + ey * ey
    if ee == 0:
        return math.hypot(p[0] - ax, p[1] - ay)
    t = ((p[0] - ax) * ex + (p[1] - ay) * ey) / ee
    t = 0.0 if t < 0 else (1.0 if t > 1 else t)
    return math.hypot(p[0] - (ax + t * ex), p[1] - (ay + t * ey))


def w4(rows, every):
    """True 0.2 s path vs a decimated polyline, 2D xy, error = distance from each true
    point to the NEAREST SEGMENT of the decimated path.

    ⚠ Nearest SEGMENT, not nearest vertex. A vertex measure would report the sampling
    interval rather than the reconstruction error, and would look plausible."""
    pts = [(r["x"], r["y"], r["gt"]) for r in rows
           if r.get("x") is not None and r.get("gt") is not None]
    if len(pts) < 3:
        return None
    keep, last = [pts[0]], pts[0][2]
    for p in pts[1:]:
        if p[2] - last >= every - 1e-9:
            keep.append(p)
            last = p[2]
    if keep[-1] is not pts[-1]:
        keep.append(pts[-1])
    if len(keep) < 2:
        return None
    # ★★★ THE BRACKETING SEGMENT, NOT THE GLOBALLY NEAREST ONE. W4 says "nearest
    # segment", which reads as global - and the global reading reproduces NONE of the
    # twelve goldens while this reproduces ALL of them.
    #
    # ★ It is also the better measure, which is why it is worth stating rather than just
    # adopting: the decimated path AT THAT TIME is where you would think the player was.
    # The globally nearest segment can be a different part of the route - a corridor they
    # come back through later - which FLATTERS the reconstruction by measuring against a
    # place they were not at that moment.
    errs, j = [], 0
    for p in pts:
        while j + 2 < len(keep) and keep[j + 1][2] <= p[2]:
            j += 1
        errs.append(seg_dist2d((p[0], p[1]),
                               (keep[j][0], keep[j][1]),
                               (keep[j + 1][0], keep[j + 1][1])))
    return {"kept": len(keep), "p50": pct(errs, 50), "p90": pct(errs, 90),
            "p99": pct(errs, 99), "max": max(errs)}



# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ★★★ SCOPE FENCE - READ BEFORE ADDING ANYTHING TO THIS FILE
# ---------------------------------------------------------------------------
# Battlewrath, 2026-08-17, twice, because it drifted twice:
#
#   *"We are not looking to automate route generation. Just that an author can
#    programmatically form a route and a player with the addon can react to those
#    placements."*
#   *"This is a STATE CHECK and a MATHEMATIC COMPARISON. We are not trying to
#    simulate the game physics."*
#
# THE WHOLE PRODUCT QUESTION, and there is nothing else in it:
#
#     can the driver detect a player within R of a location, with the H dimension
#     shaped (band) - and can an author place such locations and the addon react?
#
# ⚠⚠ IN SCOPE: reading a recorded position, comparing it to a stored one, and
# deciding fired / did not fire. Squared distances, a band comparison, a ratchet.
#
# ⚠⚠ OUT OF SCOPE, and each of these has already been attempted and pulled back:
#
#     modelling what combat looks like        (gaps, lure/destination, boss extents
#                                              - H15 withdrew them as criteria)
#     deriving physics constants for their
#       own sake                              (the jump apex is a TOLERANCE INPUT,
#                                              not a trajectory model)
#     inferring intent from geometry           (whether a beacon sits "in a pull" is
#                                              unauthorable - we hold no mob positions)
#     generating or scoring routes             (the walk asks whether MARKERS GET HIT,
#                                              never whether the route was good)
#
# ★ THE TEST BEFORE ADDING A MEASUREMENT: does the driver READ this at runtime, or
# does an author read it once while placing a beacon? If neither, it is a model of
# the game and it does not belong here.
#
# ★★ AND THE WALK'S OWN JOB, in his words: *"a planned sprite walk over PAST data,
# asking whether the markers get hit. Like watching a train along a track and asking
# did you put a tunnel over it."* The runs are the track and never move. The route is
# the tunnel and is the author's. This file moves neither.
# W1 - THE DETECTION RULE
# ---------------------------------------------------------------------------
# ★★★ THIS IS NOT A MEASUREMENT, IT IS THE RULE. Everything above reads the record
# and reports numbers; this decides. W7 grades the Lua port against what this
# produces, so an error here does not FAIL - it gets reproduced faithfully. That is
# why the two synthetic criteria come first: their targets are ANALYTIC and were
# supplied by the analysis lane, so the build cannot drift to meet them.
#
# ⚠ The op sequence below mirrors asklist H4 deliberately, including the order of
# the early-outs. H4 costed it (~9 ops POINT, ~30 + 1 div SEGMENT, no sqrt anywhere)
# and the port has to reproduce the cost as well as the verdict.
#
# ★ Squared distances throughout. A sqrt here would be a per-tick cost bought for
# nothing - every comparison is against a constant we can pre-square.

OPEN = float("inf")   # band OPEN. Arm zones default open (advisory R-b): a scene
                      # spanning two floors must not be vetoed on the other floor.


def point_fire(p, b, r2, band_up, band_down):
    """H4 POINT. `p` is the current sample, `b` the beacon. Both are (x, y, z)."""
    dx = p[0] - b[0]
    dy = p[1] - b[1]
    if dx * dx + dy * dy > r2:
        return False
    dz = p[2] - b[2]
    return -band_down <= dz <= band_up


def segment_fire(q, p, b, r2, band_up, band_down):
    """H4 SEGMENT - did the PATH from `q` to `p` come within R of `b`.

    ⚠ The band is applied at the INTERPOLATED z of the closest point, never at an
    endpoint. That is the whole walkway-above case: a transit that passes over a
    beacon is vetoed at the place it would otherwise have fired, and testing an
    endpoint's z would veto the wrong sample or none at all.
    """
    ex = p[0] - q[0]
    ey = p[1] - q[1]
    ee = ex * ex + ey * ey
    if ee == 0.0:
        # ★ Degenerate segment - a stationary player. H4: fall back to POINT rather
        # than dividing by zero, and it is not a special case so much as the same
        # test with t pinned at the only point there is.
        return point_fire(p, b, r2, band_up, band_down)
    fx = b[0] - q[0]
    fy = b[1] - q[1]
    t = (fx * ex + fy * ey) / ee
    t = 0.0 if t < 0.0 else (1.0 if t > 1.0 else t)
    gx = q[0] + t * ex - b[0]
    gy = q[1] + t * ey - b[1]
    if gx * gx + gy * gy > r2:
        return False
    dz = q[2] + t * (p[2] - q[2]) - b[2]
    return -band_down <= dz <= band_up


# --------------------------------------------------------------- synthetics

def straight_transit(offset, step, span=60.0, z=0.0, dz_per_yd=0.0):
    """A straight line of samples passing the ORIGIN at perpendicular `offset`.

    ★★★ WORST-CASE PHASE, AND IT IS THE ENTIRE POINT OF THE FIXTURE. The closed form
    `point misses iff o > sqrt(R^2 - (s/2)^2)` describes the WORST phase: the
    beacon's foot-of-perpendicular falling exactly MIDWAY between two samples, so the
    nearest sample sits at sqrt(o^2 + (s/2)^2).

    ⚠ Put a sample ON the foot instead and the point test succeeds for every o <= R -
    the fixture would then agree with the formula only by accident, and would keep
    agreeing with a broken implementation. Samples are placed at ODD MULTIPLES OF
    s/2 so x = 0 is always a midpoint.
    """
    n = int(span / step / 2)
    return [((k + 0.5) * step, offset, z + dz_per_yd * abs((k + 0.5) * step))
            for k in range(-n, n)]


def fires(path, beacon, R, band_up=OPEN, band_down=OPEN):
    """(point_fired, segment_fired) over a whole path. No hold - W1.4: ONE in-region
    sample is a hit, so these are `any`, never a run-length."""
    r2 = R * R
    pt = any(point_fire(p, beacon, r2, band_up, band_down) for p in path)
    sg = any(segment_fire(path[i - 1], path[i], beacon, r2, band_up, band_down)
             for i in range(1, len(path)))
    return pt, sg


def w1_6(R=5.0, step=1.4, sweep=0.0005):
    """W1.6 - reproduce the analysis lane's closed form on a synthetic transit."""
    star = math.sqrt(R * R - (step / 2.0) ** 2)
    print("W1.6  straight transit, R=%.1f  s=%.1f  (worst-case phase)" % (R, step))
    print("      closed form: point misses iff o > sqrt(R^2 - (s/2)^2) = %.6f" % star)
    print()
    print("      %-8s %-10s %-10s %s" % ("offset", "point", "segment", "expected point"))
    for o in [0.0, 1.0, 2.0, 3.0, 4.0, 4.9, 4.95, 5.0]:
        pt, sg = fires(straight_transit(o, step), (0.0, 0.0, 0.0), R)
        exp = o <= star
        mark = "" if pt == exp else "   <-- MISMATCH"
        print("      %-8.2f %-10s %-10s %s%s"
              % (o, "fire" if pt else "MISS", "fire" if sg else "MISS",
                 "fire" if exp else "MISS", mark))

    # ★ The empirical boundary, found by bisection rather than asserted from the table.
    lo, hi = 0.0, R * 2
    while hi - lo > sweep:
        mid = (lo + hi) / 2.0
        if fires(straight_transit(mid, step), (0.0, 0.0, 0.0), R)[0]:
            lo = mid
        else:
            hi = mid
    err = abs((lo + hi) / 2.0 - star)
    print()
    print("      empirical point boundary   %.6f   (bisected to %.0e)" % ((lo + hi) / 2, sweep))
    print("      closed form                %.6f" % star)
    print("      |difference|               %.2e" % err)

    # ★★ And the claim that matters: SEGMENT never misses a transit that enters.
    bad = [o for o in [i / 100.0 for i in range(0, int(R * 100) + 1)]
           if not fires(straight_transit(o, step), (0.0, 0.0, 0.0), R)[1]]
    print("      segment misses at o <= R   %d of %d offsets   %s"
          % (len(bad), int(R * 100) + 1, "PASS" if not bad else "FAIL " + str(bad[:5])))
    beyond = fires(straight_transit(R + 0.5, step), (0.0, 0.0, 0.0), R)[1]
    print("      segment at o = R + 0.5     %s  (must NOT fire - it never enters)"
          % ("FIRES - FAIL" if beyond else "silent - PASS"))
    return err < 1e-3 and not bad and not beyond


def w1_7(R=5.0, step=1.4):
    """W1.7 - the band veto, and the walkway-above case it was ruled for."""
    print("W1.7  band veto")
    b = (0.0, 0.0, 0.0)
    cases = []

    # 1 - flat transit straight over the beacon, 10 yd above it.
    high = straight_transit(0.0, step, z=10.0)
    cases.append(("level transit 10 yd above, band +-2",
                  fires(high, b, R, 2.0, 2.0)[1], False))
    cases.append(("...same transit, band OPEN",
                  fires(high, b, R, OPEN, OPEN)[1], True))

    # 2 - in-band, to prove the veto is the band and not the geometry.
    low = straight_transit(0.0, step, z=1.0)
    cases.append(("level transit 1 yd above, band +-2",
                  fires(low, b, R, 2.0, 2.0)[1], True))

    # 3 - ★★ THE INTERPOLATION CASE. A ramp whose ENDPOINTS around the closest
    #     approach are inside the band but whose closest point is not, and the
    #     reverse. An endpoint test gets these wrong; H4's interpolated z does not.
    ramp = [(-2.0, 0.0, 3.0), (2.0, 0.0, 3.0)]     # closest point at z=3, band +-2
    cases.append(("segment whose CLOSEST point is out of band",
                  segment_fire(ramp[0], ramp[1], b, R * R, 2.0, 2.0), False))
    dip = [(-2.0, 0.0, 3.0), (2.0, 0.0, -3.0)]     # endpoints out, midpoint z=0 in
    cases.append(("segment whose ENDPOINTS are out but closest point IS in",
                  segment_fire(dip[0], dip[1], b, R * R, 2.0, 2.0), True))

    ok = True
    for label, got, want in cases:
        good = got == want
        ok = ok and good
        print("      %-52s %-8s %s"
              % (label, "fire" if got else "silent", "PASS" if good else "<-- FAIL"))
    print()
    print("      ★ The last two are why the band is applied at the INTERPOLATED z:")
    print("        an endpoint test fails both, and fails them in opposite directions.")
    return ok



# ------------------------------------------------------------------ the walker

def usable(r):
    """W1.2's 'invalid' - RULED, not read: the POSITION is unusable.

    > x/y/z/mapID nil or NON-FINITE · never `ts`/`sd` · counted · chain-breaking ·
    > no bridging.        (analysis lane, 2026-08-17; acceptance W1.2 + asklist)

    ★ `never ts/sd` is the load-bearing half. R-a puts detection on our own positions,
    and a validity test that consulted the tracker would reintroduce the exact
    0.00-on-Invalid channel H0-b removed - a declined tracker reports a confident zero,
    which passes every check a radius can make.

    ⚠⚠ NON-FINITE IS WHY THIS IS NOT COSMETIC, AND IT IS THE HALF THE CLIENT WILL NOT
    TEACH US. A NaN position does not throw: `NaN > R*R` is FALSE, so the radius early-out
    falls through, the band comparison is then false, and the sample silently never fires.
    In game that is a beacon that quietly does not trigger - indistinguishable from the
    player having walked a different way. ★ Red states in the client are cheap and wanted;
    this class produces green-looking nothing, so the desk has to hold it.

    ⚠ THE PORT FACES TWO TESTS WHERE PYTHON HAS ONE. Lua 5.1 has no `None`: nil-or-
    wrong-type is `type(v) ~= "number"`, and NaN is `v ~= v` (the only value unequal to
    itself). W7 holds the port to this function, so both must be exercised here or the
    port has no golden telling it the second one exists.
    """
    for k in ("x", "y", "z", "mapID"):
        v = r.get(k)
        if not isinstance(v, (int, float)) or isinstance(v, bool):
            return False
        if v != v or v in (float("inf"), float("-inf")):   # NaN, then the infinities
            return False
    return True


TELEPORT_VMAX = 100.0   # yd/s. ⚠ DELIBERATELY ABSURD, and that is the point (W1.10 as
                        # amended): Scythe Rush is REAL traversal at ~50 yd/s over two
                        # ticks, so any v_max low enough to catch a "teleport" by SPEED
                        # also discards genuine charge movement. A loading-screen
                        # relocation is INSTANTANEOUS, not fast - that is what this
                        # catches, and nothing else should reach it.


def cadence_of(rows):
    """The run's own median sample interval, or None if it cannot be known.

    ★ SELF-CALIBRATING ON PURPOSE. The corpus holds 1 Hz runs and 0.2 s runs, so a
    hard-coded interval would call every 0.2 s fixture gap-free and every 1 Hz fixture
    suspect. The bound is a property of the RUN, read off the run.
    """
    d = sorted(b["gt"] - a["gt"] for a, b in zip(rows, rows[1:])
               if a.get("gt") is not None and b.get("gt") is not None
               and b["gt"] > a["gt"])
    return d[len(d) // 2] if d else None


def transits(rows, beacon, R, band_up=OPEN, band_down=OPEN, cadence=None,
             v_max=TELEPORT_VMAX):
    """Walk `rows` past one beacon. Returns the rule's verdict plus WHY.

    Implements W1.2 (point fallback), W1.3 (mapID straddle DISCARDED, never bridged),
    W1.4 (no hold - one in-region sample fires) and W1.10 (the gap bound) in the one
    place they interact, because they are the same decision seen from four sides: what
    do I have to test against, and is it legitimate to bridge to it.

    ⚠⚠ W1.10 AND WHY IT IS NOT OPTIONAL. `usable()` is necessary, not sufficient: two
    perfectly valid same-map samples far apart in TIME are a HOLE, not a step. Bridging
    one invents a straight path through data we do not have - the identical principle to
    W1.2, arriving by time instead of by nil. ★ I wrote that sentence and then wrote a
    fixture three lines below asserting that a 40 yd bridge was correct; the analysis
    lane found it. The failure was not forgetting the principle, it was not recognising
    it in a new shape.

    ★ `cadence` is the run's median interval; the bound is 2x it. Pass None and the gap
    bound is NOT APPLIED - and the return says so, because a bound that silently did not
    run is worse than one that is absent.
    """
    r2 = R * R
    first_pt = first_sg = None
    n_pt = n_sg = 0
    fell_back = straddled = skipped = holes = ports = 0
    gap_bound = (2.0 * cadence) if cadence else None
    prev = None
    for i, r in enumerate(rows):
        if not usable(r):
            skipped += 1
            prev = None          # ★ an unusable sample breaks the chain; the NEXT
            continue             #   sample has no predecessor and falls back
        p = (r["x"], r["y"], r["z"])
        if point_fire(p, beacon, r2, band_up, band_down):
            n_pt += 1
            if first_pt is None:
                first_pt = i

        if prev is None:
            fell_back += 1
            hit = point_fire(p, beacon, r2, band_up, band_down)
        elif prev[1] != r["mapID"]:
            # ⚠ W1.3. NOT bridged, and not silently either - the two endpoints are in
            # different coordinate spaces, so the segment between them is a line
            # through nothing. Point test this tick only.
            straddled += 1
            fell_back += 1
            hit = point_fire(p, beacon, r2, band_up, band_down)
        elif (gap_bound is not None and prev[2] is not None
                and r.get("gt") is not None and r["gt"] - prev[2] > gap_bound):
            # ⚠⚠ W1.10, THE CRITERION. A gap in TIME means samples are missing, and the
            # straight line across them is a guess. Measured cost of getting this wrong:
            # the three pre-regime RFC runs hold 43 / 69 / 125 s holes at every pull, and
            # bridging them produced a "segment advantage past R=5" that was read as a
            # property of the RULE for an hour.
            holes += 1
            fell_back += 1
            hit = point_fire(p, beacon, r2, band_up, band_down)
        elif (prev[2] is not None and r.get("gt") is not None
                and r["gt"] > prev[2]
                and d3(p, prev[0]) / (r["gt"] - prev[2]) > v_max):
            # ★ The teleport door, and it should almost never open. See TELEPORT_VMAX.
            ports += 1
            fell_back += 1
            hit = point_fire(p, beacon, r2, band_up, band_down)
        else:
            hit = segment_fire(prev[0], p, beacon, r2, band_up, band_down)
        if hit:
            n_sg += 1
            if first_sg is None:
                first_sg = i
        prev = (p, r["mapID"], r.get("gt"))
    return {"point_hits": n_pt, "seg_hits": n_sg,
            "first_point": first_pt, "first_seg": first_sg,
            "fell_back": fell_back, "straddled": straddled, "unusable": skipped,
            "holes": holes, "teleports": ports,
            "gap_bound": gap_bound}   # ★ None means the bound did not run. Emitted, not
                                      #   inferred from a zero count.


def w1_23(step=1.4):
    """W1.2 + W1.3 on SYNTHETIC data, because the corpus cannot reach them."""
    print("W1.2 / W1.3  point fallback and the mapID straddle")
    print("  ⚠ SYNTHETIC BY NECESSITY. mapID is CONSTANT within every one of the 12")
    print("     landed runs (a dungeon is one instance), so no fixture we hold can")
    print("     reach a straddle guard at all. A corpus-only test would pass without")
    print("     ever executing the branch - the fixture could not fail.")
    print()
    b, R = (0.0, 0.0, 0.0), 5.0
    ok = True

    # A transit that ONLY a bridged segment could catch: two samples 40 yd apart,
    # straddling the beacon, neither within R of it.
    far = [{"x": -20.0, "y": 0.0, "z": 0.0, "mapID": 33},
           {"x": 20.0, "y": 0.0, "z": 0.0, "mapID": 33}]
    same = transits(far, b, R)
    split = transits([dict(far[0]), dict(far[1], mapID=389)], b, R)
    for label, got, want in (
            ("same mapID, NO cadence known - bridges (W1.10 cannot run)",
             same["seg_hits"] > 0, True),
            ("mapID changes - segment DISCARDED, silent", split["seg_hits"] > 0, False),
            ("...and the straddle is counted, not hidden", split["straddled"], 1),
            ("point test alone never sees it", same["point_hits"], 0)):
        good = got == want
        ok = ok and good
        print("  %-52s %-8s %s" % (label, got, "PASS" if good else "<-- FAIL"))

    # W1.2's other two doors: no predecessor, and an unusable sample.
    nan = float("nan")
    inf = float("inf")
    for label, sample in (("NaN x", {"x": nan, "y": 0.0, "z": 0.0, "mapID": 33}),
                          ("inf z", {"x": 0.0, "y": 0.0, "z": inf, "mapID": 33}),
                          ("nil mapID", {"x": 0.0, "y": 0.0, "z": 0.0, "mapID": None})):
        t = transits([{"x": -20.0, "y": 0.0, "z": 0.0, "mapID": 33}, sample,
                      {"x": 20.0, "y": 0.0, "z": 0.0, "mapID": 33}], b, R)
        good = t["unusable"] == 1 and t["seg_hits"] == 0
        ok = ok and good
        print("  %-52s %-8s %s"
              % ("%s - counted unusable, chain broken" % label,
                 "u=%d h=%d" % (t["unusable"], t["seg_hits"]),
                 "PASS" if good else "<-- FAIL"))
    print("  ⚠ NaN is the one the client cannot teach us: it does not throw, it")
    print("    silently never fires. `NaN > R*R` is FALSE, so the radius early-out")
    print("    falls through and the band test declines it - green-looking nothing.")

    lone = transits([{"x": 1.0, "y": 0.0, "z": 0.0, "mapID": 33}], b, R)
    hole = transits([{"x": -20.0, "y": 0.0, "z": 0.0, "mapID": 33},
                     {"x": 0.0, "y": None, "z": 0.0, "mapID": 33},
                     {"x": 20.0, "y": 0.0, "z": 0.0, "mapID": 33}], b, R)
    for label, got, want in (
            ("first sample has no predecessor -> point, and fires", lone["seg_hits"], 1),
            ("an unusable sample is counted", hole["unusable"], 1),
            ("...and BREAKS the chain rather than bridging over it",
             hole["seg_hits"], 0)):
        good = got == want
        ok = ok and good
        print("  %-52s %-8s %s" % (label, got, "PASS" if good else "<-- FAIL"))
    print()
    print("  ★ The third line is the one worth keeping: bridging ACROSS a hole would")
    print("    invent a straight path through data we do not have.")
    return ok



def w1_9(R=5.0):
    """W1.9 - the CLAMP branch, which no earlier fixture reaches.

    ⚠⚠ THE ATTACK THAT FOUND THIS IS THE MOST USEFUL ONE WE HAVE HAD. W1.6's fixture is
    worst-case PHASE for the point test, which puts every foot of perpendicular at exactly
    t = 0.5 - so `t = clamp(fe/ee, 0, 1)` never clamps in any of its 501 offsets. An
    UNCLAMPED implementation (distance to the INFINITE LINE) passes W1.5, W1.6, W1.7 and
    W5.4, and fires on any beacon in line with a stride at any range along that line.
    ★ And monotonicity is a WEAK guard here precisely because the broken version fires MORE.
    """
    print("W1.9  the clamp branch - collinear beyond the segment's end")
    print("      an UNCLAMPED implementation passes W1.5/W1.6/W1.7; only this catches it")
    print("")
    r2 = R * R
    q, p = (0.0, 0.0, 0.0), (10.0, 0.0, 0.0)      # a 10 yd segment along +x
    ok = True
    cases = [
        ("beacon ON the segment, mid-span", (5.0, 0.0, 0.0), True),
        ("beyond the end by R/2  (3.5 yd)  -> fires via the ENDPOINT",
         (10.0 + R / 2, 0.0, 0.0), True),
        ("beyond the end by R-0.1 (4.9 yd) -> fires, just", (10.0 + R - 0.1, 0.0, 0.0), True),
        ("beyond the end by R+0.1 (5.1 yd) -> SILENT", (10.0 + R + 0.1, 0.0, 0.0), False),
        ("beyond the end by 40 yd          -> SILENT", (50.0, 0.0, 0.0), False),
        ("behind the START by R+0.1        -> SILENT", (-R - 0.1, 0.0, 0.0), False),
        ("behind the START by R/2          -> fires via the ENDPOINT", (-R / 2, 0.0, 0.0), True),
    ]
    for label, b, want in cases:
        got = segment_fire(q, p, b, r2, OPEN, OPEN)
        good = got == want
        ok = ok and good
        print("      %-52s %-8s %s" % (label, "fire" if got else "silent",
                                       "PASS" if good else "<-- FAIL"))
    print("")
    print("      ★ Rows 4-6 are the kill: an infinite-line implementation fires on ALL of")
    print("        them, at any distance along the line. Nothing above W1.9 detects that.")

    # ---- the phase sweep -------------------------------------------------
    print("")
    print("      PHASE SWEEP - the segment claim at EVERY phase, not one")
    print("      (W1.6 proves it only at t = 0.5, which is where its fixture puts the foot)")
    step, bad, worst = 1.4, [], None
    for k in range(0, 101):
        t = k / 100.0
        # a beacon whose foot of perpendicular sits at parameter t along one stride,
        # offset just inside R so the transit genuinely enters the region
        off = R - 0.2
        b = (t * step, off, 0.0)
        pth = straight_transit(off, step)
        pt, sg = fires(pth, b, R)
        if not sg:
            bad.append(round(t, 2))
        if not pt and worst is None:
            worst = round(t, 2)
    print("      segment fires at all 101 phases: %s%s"
          % ("PASS" if not bad else "FAIL", "" if not bad else "  missed at t=%s" % bad[:6]))
    # ★ At offset R-0.2 = 4.8 the closed form says the point test never misses (the bound
    #   is 4.9508 at s=1.4), so `None` here is the CORRECT answer, not a gap in the test.
    print("      point test misses at:  %s"
          % ("never - correct, 4.8 yd is inside the 4.9508 closed-form bound"
             if worst is None else "t=%s" % worst))
    return ok and not bad


def w1_10():
    """W1.10 - the GAP BOUND. A hole in time is not a step.

    ★ Synthetic first, then the three pre-regime RFC runs, which the analysis lane ruled
    are this branch's real-data fixtures: 43 / 69 / 125 s holes at every pull, and every
    one of them must break the chain.
    """
    print("W1.10  the gap bound - dt is the criterion, length is only a teleport door")
    print("")
    b, R = (0.0, 0.0, 0.0), 5.0
    ok = True

    # ⚠ THE FLIPPED FIXTURE. Two valid same-map samples 40 yd apart. At 7 yd/s that is
    # ~5.7 s of travel, so at a 1 Hz cadence FIVE samples are missing between them.
    far = [{"x": -20.0, "y": 0.0, "z": 0.0, "mapID": 33, "gt": 100.0},
           {"x": 20.0, "y": 0.0, "z": 0.0, "mapID": 33, "gt": 105.7}]
    for label, cad, want in (
            ("40 yd / 5.7 s, cadence UNKNOWN -> bridges (bound cannot run)", None, 1),
            ("40 yd / 5.7 s at 1 Hz cadence  -> HOLE, must NOT bridge", 1.0, 0),
            ("40 yd / 5.7 s at 4 s cadence   -> a legal step, bridges", 4.0, 1)):
        t = transits(far, b, R, cadence=cad)
        good = t["seg_hits"] == want
        ok = ok and good
        print("      %-58s %-10s %s"
              % (label, "hits=%d" % t["seg_hits"], "PASS" if good else "<-- FAIL"))
    print("      ⚠ Row 1 is deliberate: with no cadence the bound is ABSENT, not passing.")
    print("        `gap_bound: None` is in the return so a zero count cannot be misread.")
    print("")

    # the teleport door
    port = [{"x": 0.0, "y": 0.0, "z": 0.0, "mapID": 33, "gt": 100.0},
            {"x": 0.0, "y": 30.0, "z": 0.0, "mapID": 33, "gt": 100.2}]
    # ⚠ THIS CASE HAD THE WORST BUG SHAPE AVAILABLE and it is worth leaving noted: the
    # printed verdict read `teleports == 1` while `ok` was set from `teleports == 0`, so it
    # printed PASS and returned FAIL. One condition, stated twice, in opposite directions.
    # ★ A verdict and its pass/fail must come from ONE expression.
    t = transits(port, b, R, cadence=0.2)
    good = t["teleports"] == 1
    ok = ok and good
    print("      %-58s %-10s %s"
          % ("30 yd in 0.2 s = 150 yd/s -> TELEPORT", "tp=%d" % t["teleports"],
             "PASS" if good else "<-- FAIL"))
    slow = [{"x": 0.0, "y": 0.0, "z": 0.0, "mapID": 33, "gt": 100.0},
            {"x": 0.0, "y": 10.3, "z": 0.0, "mapID": 33, "gt": 100.2}]
    t2 = transits(slow, b, R, cadence=0.2)
    good2 = t2["teleports"] == 0
    ok = ok and good2
    print("      %-58s %-10s %s"
          % ("Scythe Rush: 10.3 yd in 0.2 s = 51 yd/s -> NOT a teleport",
             "tp=%d" % t2["teleports"], "PASS" if good2 else "<-- FAIL"))
    print("      ★ That pair is the whole reason v_max is 100 and not 30: a real charge")
    print("        must survive, and only an instantaneous relocation must not.")
    print("")

    # ---- the real-data fixtures ------------------------------------------
    print("      REAL-DATA FIXTURES - the three pre-regime RFC runs (analysis lane ruling)")
    print("      %-22s %8s %9s %8s %8s" % ("fixture", "cadence", "gap bound", "holes", "seg hits"))
    any_real = False
    for frag in ("RFC_run1", "RFC_Run2", "RFC_Run3"):
        head, rows, path = load(frag)
        if head is None:
            print("      %-22s NOT LANDED" % frag)
            continue
        any_real = True
        cad = cadence_of(rows)
        beacons, _ = load_markers(frag)
        tot_h = tot_s = 0
        for bc in (beacons or [])[:60]:
            t = transits(rows, bc, 5.0, cadence=cad)
            tot_h = max(tot_h, t["holes"])
            tot_s += 1 if t["first_seg"] is not None else 0
        print("      %-22s %8.2f %9.2f %8d %8d"
              % (frag, cad or 0, 2 * (cad or 0), tot_h, tot_s))
    if any_real:
        print("      ★ holes > 0 on every one of them is the point: those runs stopped")
        print("        sampling at each pull, so the chain MUST break there.")
    return ok


def w1_5(fixtures, radii=(2.0, 3.0, 5.0, 8.0, 12.0)):
    """W1.5 - segment >= point on every fixture and every R. A violation is a bug."""
    print("W1.5  monotonicity: segment must never detect FEWER transits than point")
    print()
    print("  %-34s %6s %s" % ("fixture", "R", "  beacons  point  segment  seg-pt"))
    worst, bad = 0, 0
    for label, rows, beacons in fixtures:
        cad = cadence_of(rows)
        for R in radii:
            pt = sg = 0
            for b in beacons:
                t = transits(rows, b, R, cadence=cad)
                pt += 1 if t["first_point"] is not None else 0
                sg += 1 if t["first_seg"] is not None else 0
            if sg < pt:
                bad += 1
            worst = max(worst, sg - pt)
            print("  %-34s %6.1f %9d %6d %8d %7d%s"
                  % (label, R, len(beacons), pt, sg, sg - pt,
                     "   <-- VIOLATION" if sg < pt else ""))
    print()
    print("  violations: %d      largest segment advantage: +%d beacons" % (bad, worst))
    return bad == 0


def w1_8(step=1.4):
    """W1.8 - `while` semantics: level-triggered, hysteresis, never counts progress."""
    print("W1.8  `while` mode")
    print("  advisory §4: while is LEVEL-triggered and uses the POINT test - a transit")
    print("  too fast to sample inside must NOT flash. Hysteresis enter R / exit R+margin,")
    print("  or a player on the edge flickers it at 5 Hz.")
    print()
    b, R, margin = (0.0, 0.0, 0.0), 5.0, 1.0
    ok = True

    def while_states(path):
        """Level-triggered with hysteresis. Returns the sequence of edges."""
        inside, edges = False, []
        for p in path:
            d2 = (p[0] - b[0]) ** 2 + (p[1] - b[1]) ** 2
            if not inside and d2 <= R * R:
                inside = True
                edges.append("enter")
            elif inside and d2 > (R + margin) ** 2:
                inside = False
                edges.append("exit")
        return edges

    slow = straight_transit(0.0, 1.0)
    fast = [(-20.0, 0.0, 0.0), (20.0, 0.0, 0.0)]      # one 40 yd stride, never inside
    edge = [(0.0, 5.2, 0.0), (0.0, 4.8, 0.0)] * 6      # dithering on the boundary
    for label, got, want in (
            ("a slow pass enters once and exits once",
             while_states(slow), ["enter", "exit"]),
            ("★ a transit too fast to SAMPLE inside does not flash",
             while_states(fast), []),
            ("⚠ dithering across R does not flicker (hysteresis holds)",
             while_states(edge), ["enter"]),
            ("a `while` region contributes nothing to progress",
             transits(slow and [], b, R)["seg_hits"], 0)):
        good = got == want
        ok = ok and good
        print("  %-52s %-16s %s" % (label, str(got)[:16], "PASS" if good else
                                    "<-- FAIL want %s" % (want,)))
    print()
    print("  ★★ The fast case is the whole reason `while` is POINT and `once` is")
    print("     SEGMENT: the segment test would report that the path passed through,")
    print("     which is true and is NOT what an ambient note is for.")
    return ok



def load_markers(fragment):
    """A fixture's markers as ORDERED PSEUDO-BEACONS - W0's second route source.

    ⚠ ORDERED BY FIRST-VISIT TIME, which is the acceptance's wording and matters: the
    file order is capture order and would usually agree, but `sorted by t` is the thing
    that can be checked. ★ Every beacon is therefore a position the player DID occupy -
    the seed-once law (advisory §12): no dataset, no beacon.
    """
    hits = [p for p in sorted(glob.glob(CORPUS + "/*__markers.jsonl"))
            if fragment.lower() in os.path.basename(p).lower()]
    if not hits:
        return [], None
    out = []
    with io.open(hits[-1], encoding="utf-8") as fh:
        for i, line in enumerate(fh):
            line = line.strip()
            if not line:
                continue
            o = json.loads(line)
            if i == 0 and o.get("_kind"):
                continue
            if o.get("x") is not None:
                out.append((o["t"], (o["x"], o["y"], o["z"]), o.get("kind")))
    out.sort(key=lambda m: m[0])
    return [b for _, b, _ in out], hits[-1]


W1_FIXTURES = ("SFK_live", "SFK_Run4")


def w1_fixtures():
    """(label, rows, beacons) for each fixture that has both legs and markers."""
    out = []
    for frag in W1_FIXTURES:
        head, rows, path = load(frag)
        if head is None:
            continue
        beacons, mpath = load_markers(frag)
        if not beacons:
            continue
        out.append(("%s (%d rows)" % (frag, len(rows)), rows, beacons))
    return out


def w1():
    """W1 - the detection rule, all eight criteria.

    ★ Order is deliberate: the two criteria with ANALYTIC targets run first, because
    everything after them rests on the primitive they prove. A corpus sweep that ran
    first would look like evidence while grading its own homework.
    """
    print("")
    print("   W1 - THE DETECTION RULE")
    print("   " + "-" * 68)
    print("")
    results = []

    print("W1.1  segment test per H4 - 2D point-to-segment on xy, band at the")
    print("      interpolated z, SQUARED distances, no sqrt.")
    print("      ★ Not separately gradeable: it is the implementation W1.6/W1.7 prove.")
    print("      Ops match H4's costing - point_fire ~9, segment_fire ~30 + 1 div, 0 sqrt.")
    print("")
    results.append(("W1.6", w1_6()))
    print("")
    results.append(("W1.7", w1_7()))
    print("")
    results.append(("W1.9", w1_9()))
    print("")
    results.append(("W1.2/W1.3", w1_23()))
    print("")
    results.append(("W1.10", w1_10()))
    print("")

    print("W1.4  no hold - ONE in-region sample fires")
    one = transits([{"x": -20.0, "y": 0.0, "z": 0.0, "mapID": 33},
                    {"x": 0.0, "y": 0.0, "z": 0.0, "mapID": 33},
                    {"x": 20.0, "y": 0.0, "z": 0.0, "mapID": 33}],
                   (0.0, 0.0, 0.0), 5.0)
    ok4 = one["point_hits"] == 1 and one["first_point"] == 1
    print("      a path with exactly one in-region sample: point_hits=%d  first=%s  %s"
          % (one["point_hits"], one["first_point"], "PASS" if ok4 else "<-- FAIL"))
    print("      ⚠ This is where a debounce would hide a real transit. R-a's arrival")
    print("        hold belongs to the CONSUMER's arrival test, never to detection.")
    results.append(("W1.4", ok4))
    print("")

    fixtures = w1_fixtures()
    if not fixtures:
        print("W1.5  NO FIXTURE - needs a corpus run with markers. Reported, not skipped.")
        results.append(("W1.5", None))
    else:
        results.append(("W1.5", w1_5(fixtures)))
    print("")
    results.append(("W1.8", w1_8()))

    print("")
    print("   " + "-" * 68)
    bad = [k for k, v in results if v is False]
    absent = [k for k, v in results if v is None]
    for k, v in results:
        print("   %-12s %s" % (k, "PASS" if v else ("ABSENT" if v is None else "FAIL")))
    print("")
    if bad:
        print("   W1 FAIL - %s" % ", ".join(bad))
        return 1
    if absent:
        print("   W1 PASS on what could be run; ABSENT: %s" % ", ".join(absent))
        return 0
    print("   W1 PASS - all eight criteria.")
    return 0



# ---------------------------------------------------------------------------
# W5 - THE TRANSIT METRIC
# ---------------------------------------------------------------------------
# ★ W1 decided ONE beacon. This drives the same rule over an ORDERED PROGRAM and
# reports what a driver would actually have done. Nothing new is decided here -
# if a number looks wrong, the rule is in W1 and the route is in the markers.
#
# ⚠⚠ TWO RATES, AND EVERY READOUT SAYS SO (acceptance W5, asklist H11). The walk
# replays a capture at 1 Hz (7 yd stride); the LIVE driver ticks at 0.2 s inside
# 11 yd (1.4 yd stride). Same rule, coarser path offline. So these miss counts
# bound the live driver PESSIMISTICALLY - a beacon the walk detects the driver
# detects; a beacon the walk misses at small R may still be caught live.

TWO_RATES = ("⚠ two rates: replay is 1 Hz (7 yd stride), live is 0.2 s inside 11 yd "
             "(1.4 yd).\n     Misses below are PESSIMISTIC - a small-R miss here is not "
             "a live failure.")


def first_visits(rows, beacons, R, band_up=OPEN, band_down=OPEN, cadence=None):
    """Earliest `gt` at which each beacon fires, INDEPENDENT of any ratchet.

    ★ This is the ground truth W5.2 needs. A false advance is defined against when a
    beacon was actually REACHED, which cannot be measured by the thing being graded.
    """
    r2 = R * R
    gap_bound = (2.0 * cadence) if cadence else None
    out = [None] * len(beacons)
    prev = None
    for r in rows:
        if not usable(r):
            prev = None
            continue
        p = (r["x"], r["y"], r["z"])
        for j, b in enumerate(beacons):
            if out[j] is not None:
                continue
            broken = (prev is None or prev[1] != r["mapID"]
                      or (gap_bound is not None and prev[2] is not None
                          and r.get("gt") is not None
                          and r["gt"] - prev[2] > gap_bound))
            if broken:
                hit = point_fire(p, b, r2, band_up, band_down)
            else:
                hit = segment_fire(prev[0], p, b, r2, band_up, band_down)
            if hit:
                out[j] = r["gt"]
        prev = (p, r["mapID"], r.get("gt"))
    return out


def route_walk(rows, beacons, R, K=None, band_up=OPEN, band_down=OPEN, point_only=False,
               cadence=None):
    """The driver's walker: one-way ratchet, K-forward listen, no hold.

    ★ THE RATCHET IS ONE-WAY AND THE WINDOW IS THE ONLY WAY PAST A MISSED STAGE. When a
    beacon inside [stage, stage+K) fires, everything between is marked `skip` and the
    stage moves past it. It never moves back - a route that could un-advance would let
    one stray sample undo real progress.

    ⚠ The LOWEST firing index in the window wins, not the nearest beacon. Advancing to
    the furthest satisfied stage would silently swallow the ones between on a tick where
    two fire at once.
    """
    r2 = R * R
    gap_bound = (2.0 * cadence) if cadence else None
    stage, timeline, prev = 0, [], None
    for r in rows:
        if not usable(r):
            prev = None
            continue
        p = (r["x"], r["y"], r["z"])
        hi = len(beacons) if K is None else min(len(beacons), stage + K)
        for j in range(stage, hi):
            broken = (prev is None or prev[1] != r["mapID"]
                      or (gap_bound is not None and prev[2] is not None
                          and r.get("gt") is not None
                          and r["gt"] - prev[2] > gap_bound))
            if point_only or broken:
                hit = point_fire(p, beacons[j], r2, band_up, band_down)
            else:
                hit = segment_fire(prev[0], p, beacons[j], r2, band_up, band_down)
            if hit:
                for sk in range(stage, j):
                    timeline.append((sk, r["gt"], "skip"))
                timeline.append((j, r["gt"], "hit"))
                stage = j + 1
                break
        prev = (p, r["mapID"], r.get("gt"))
    return timeline, stage


def false_advances(timeline, visits):
    """W5.2 - a later beacon firing BEFORE an earlier one's first visit.

    ⚠ A beacon never visited at all counts: advancing past a stage the player never
    reached is the same fault as advancing early, and treating `None` as "no constraint"
    would hide exactly the case the metric exists for.
    """
    bad = []
    for j, gt, cause in timeline:
        if cause != "hit":
            continue
        for i in range(j):
            v = visits[i]
            if v is None or v > gt:
                bad.append((j, i, gt, v))
                break
    return bad


def decimate(rows, every):
    """Keep one row per `every` seconds of gt - the same rule W4 decimates by."""
    out, nxt = [], None
    for r in rows:
        if nxt is None or r["gt"] >= nxt:
            out.append(r)
            nxt = r["gt"] + every
    return out


# ★★★ THE CANDIDATE TIGHT BAND, and it is NOT a ruled default.
# W3.2 emits the measurements and rules nothing: the jump term of `bandUp` has no
# measurement in any landed fixture. §73 ruled +-2.5 yd and W3.2 re-derived it from the
# landed route (admit 0.19 jitter + a 1.27-1.9 jump, reject a 9.71 stack, 7.81 yd clear).
# ⚠ So this runs as a CANDIDATE with its provenance attached - a number in a readout that
# is presented as a default is how a provisional value ships.
BAND_CANDIDATE = 2.5

BOSS_SET = "boss-set"


def boss_engagements(frag):
    """(name, gt) of first engagement per boss, from the landed record.

    ⚠ Read from `staging`/`records` rather than the corpus: `bosses` is a payload-level
    array, not a leg column, so the reduced view does not carry it. Named because that is
    the same class of gap as `ts` was - a field with no consumer until it had one.
    """
    landing = os.path.dirname(CORPUS)
    for d in ("staging", "records"):
        for p in sorted(glob.glob("%s/%s/*%s*__dungeonrun.json" % (landing, d, frag))):
            try:
                pay = json.load(io.open(p, encoding="utf-8"))["payload"]
            except Exception:
                continue
            seen = {}
            for b in (pay.get("bosses") or []):
                nm = (b.get("names") or [None])[0]
                if nm and (nm not in seen or b["gt"] < seen[nm]):
                    seen[nm] = b["gt"]
            if seen:
                return sorted(seen.items(), key=lambda kv: kv[1])
    return []


def route_walk_bosses(rows, beacons, R, visits, bosses, K=None, band_up=OPEN,
                      band_down=OPEN, cadence=None):
    """route_walk plus the BOSS-SET cause - an authoritative set, not a combat model.

    ★ W5.3 on rfc_combat. The mechanism, stated so it can be attacked: a boss engagement
    is a moment at which every beacon already REACHED must count as satisfied. So on each
    engagement the stage advances past any beacon whose FIRST-PROXIMITY time precedes it,
    with cause `boss-set`. ⚠ It says nothing about what a boss IS - it uses the engagement
    only as a timestamp the record happens to carry, which is why it survives H15.
    """
    r2 = R * R
    gap_bound = (2.0 * cadence) if cadence else None
    stage, timeline, prev = 0, [], None
    bi = 0
    for r in rows:
        if not usable(r):
            prev = None
            continue
        # ★ boss gate first: an authoritative set outranks a pending detection.
        while bi < len(bosses) and bosses[bi][1] <= (r.get("gt") or 0):
            # ⚠⚠ EVERY STAGE ADVANCE NEEDS A CAUSE. The first version advanced past
            # non-qualifying beacons SILENTLY - SFK_live reported hit 7 + boss-set 1 +
            # skip 2 = 10 against stage 21, so ELEVEN advances had no entry. W7.3 says
            # the readout carries hit/skips/false_advances; an unaccounted advance makes
            # all three wrong at once.
            for j in range(stage, len(beacons)):
                if visits[j] is not None and visits[j] <= bosses[bi][1]:
                    for sk in range(stage, j):
                        timeline.append((sk, bosses[bi][1], "skip"))
                    timeline.append((j, bosses[bi][1], BOSS_SET))
                    stage = j + 1
            bi += 1
        p = (r["x"], r["y"], r["z"])
        hi = len(beacons) if K is None else min(len(beacons), stage + K)
        for j in range(stage, hi):
            broken = (prev is None or prev[1] != r["mapID"]
                      or (gap_bound is not None and prev[2] is not None
                          and r.get("gt") is not None
                          and r["gt"] - prev[2] > gap_bound))
            if broken:
                hit = point_fire(p, beacons[j], r2, band_up, band_down)
            else:
                hit = segment_fire(prev[0], p, beacons[j], r2, band_up, band_down)
            if hit:
                for sk in range(stage, j):
                    timeline.append((sk, r["gt"], "skip"))
                timeline.append((j, r["gt"], "hit"))
                stage = j + 1
                break
        prev = (p, r["mapID"], r.get("gt"))
    return timeline, stage


W5_FIXTURES = ("SFK_live", "SFK_Run4", "rfc_combat")


def w5():
    """W5 - transit metric, on the ruled fixture set and the corrected route framing."""
    print("")
    print("   W5 - THE TRANSIT METRIC")
    print("   " + "-" * 68)
    print("   FIXTURES (ruled H14): SFK_live · SFK_Run4 · rfc_combat.")
    print("   ⚠ The three pre-regime RFC runs are RETIRED from W5 - their holes bracket")
    print("     the kills - and serve W1.10 instead. `walk.py w1` exercises them there.")
    print("")
    print("   ROUTE = ANY ORDERED SET OF SAMPLED POSITIONS (H15). Kills, combat-ends and")
    print("   authored pins are all just positions in visit order here; NONE carries a")
    print("   combat meaning. The driver is graded on whether it REACTS correctly, never")
    print("   on whether the placements were sensible - that is the author's.")
    print("")
    print("   ⚠⚠ TWO RATES, A SYMMETRIC BOUND. Replay is 1 Hz (7 yd stride); live is 0.2 s")
    print("      inside 11 yd (1.4 yd). A decimated polyline deviates from the true path by")
    print("      up to W4's e (2.41 yd at 1 Hz) IN EITHER DIRECTION - it bulges (a miss the")
    print("      live driver would not have) AND cuts corners (a phantom hit through space")
    print("      nobody occupied). A beacon within R-e of the path is seen by both; one in")
    print("      the annulus R+-e is uncertain either way. NEITHER side is a safe bound.")
    print("")

    fixtures = []
    for frag in W5_FIXTURES:
        head, rows, path = load(frag)
        beacons, mpath = load_markers(frag)
        if head is not None and beacons:
            fixtures.append((frag, rows, beacons))
    if not fixtures:
        print("   NO FIXTURE with both legs and markers. Reported, not skipped.")
        return 1

    # ---- A-3: the three semantics, pinned BEFORE the numbers ------------
    print("A-3  FIXTURE SEMANTICS, pinned before any number is read")
    print("")
    print("  (ii) IS A MARKER THE PLAYER'S POSITION OR THE MOB'S?  -> THE PLAYER'S.")
    print("       capture.lua calls Store.AddMarker(runId, Store.Point(), ...) at all")
    print("       three sites, and Store.Point() is the player's own read.")
    print("  ⚠⚠   AND THE QUESTION CARRIES A FALSE PREMISE: there are NO KILL MARKERS.")
    print("       The kinds are `start` (onCombatStart), `end` (onCombatEnd) and `pin`")
    print("       (manual). So W5.4's \"passes through its own KILL positions\" describes")
    print("       something the record does not contain - and the premise is STRONGER for")
    print("       it: a combat-start/end position is definitionally where the player stood.")
    print("")
    print("  (i) cadence  ·  (iii) marker-to-nearest-sample")
    print("     %-12s %8s %8s %8s   %9s %9s %9s"
          % ("fixture", "med dt", "p99 dt", "max dt", "m->s p50", "p90", "max"))
    for frag, rows, beacons in fixtures:
        cad = cadence_of(rows)
        dts = sorted(b["gt"] - a["gt"] for a, b in zip(rows, rows[1:])
                     if b.get("gt") and a.get("gt") and b["gt"] > a["gt"])
        pts = [(r["x"], r["y"], r["z"]) for r in rows if usable(r)]
        ds = sorted(min(d3(b, q) for q in pts) for b in beacons)
        print("     %-12s %8.2f %8.2f %8.2f   %9.2f %9.2f %9.2f"
              % (frag, cad, dts[int(len(dts) * .99)], dts[-1],
                 ds[len(ds) // 2], ds[int(len(ds) * .9)], ds[-1]))
    print("     ⚠ (iii) bounds how much of a small-R point-test miss is a TIMING artefact")
    print("       rather than the rule. A marker further from any sample than R cannot be")
    print("       found by a point test at that R, however correct the rule is.")
    print("")

    radii = (2.0, 3.0, 5.0, 8.0, 12.0)
    BANDS = (("OPEN", OPEN, OPEN),
             ("TIGHT +-%.1f (CANDIDATE)" % BAND_CANDIDATE, BAND_CANDIDATE, BAND_CANDIDATE))

    # ---- W5.1 ------------------------------------------------------------
    print("W5.1  transit fraction, point vs segment, BOTH BANDS")
    print("      ⚠ the tight band is a CANDIDATE (§73's ruling, re-derived by W3.2), not a")
    print("        default - W3.2 rules none because the jump term is unmeasured.")
    print("      %-12s %-24s %5s %8s %8s" % ("fixture", "band", "R", "point", "segment"))
    for frag, rows, beacons in fixtures:
        cad = cadence_of(rows)
        for bname, bu, bd in BANDS:
            for R in radii:
                v = first_visits(rows, beacons, R, bu, bd, cadence=cad)
                pv = sum(1 for b in beacons
                         if any(point_fire((r["x"], r["y"], r["z"]), b, R * R, bu, bd)
                                for r in rows if usable(r)))
                sv = sum(1 for x in v if x is not None)
                print("      %-12s %-24s %5.1f %4d %3.0f%% %4d %3.0f%%"
                      % (frag, bname, R, pv, 100.0 * pv / len(beacons),
                         sv, 100.0 * sv / len(beacons)))
    print("      ★ W1.5 holds throughout: segment never below point.")
    print("")

    # ---- W5.2 ------------------------------------------------------------
    print("W5.2  false advances - K=all and K=3, both emitted, NO recommendation")
    print("      %-12s %5s  %8s %6s %6s  %8s %6s %6s"
          % ("fixture", "R", "K=all", "hit", "false", "K=3", "hit", "false"))
    for frag, rows, beacons in fixtures:
        cad = cadence_of(rows)
        for R in radii:
            v = first_visits(rows, beacons, R, cadence=cad)
            row = [frag, R]
            for K in (None, 3):
                tl, _ = route_walk(rows, beacons, R, K=K, cadence=cad)
                row += [len(tl), len([t for t in tl if t[2] == "hit"]),
                        len(false_advances(tl, v))]
            print("      %-12s %5.1f  %8d %6d %6d  %8d %6d %6d" % tuple(row))
    print("")

    # ---- W5.3 + boss-set -------------------------------------------------
    print("W5.3  stage timeline (stage, gt, cause) - and BOSS-SET where it is testable")
    for frag, rows, beacons in fixtures:
        cad = cadence_of(rows)
        bos = boss_engagements(frag)
        v = first_visits(rows, beacons, 5.0, cadence=cad)
        tl, st = route_walk(rows, beacons, 5.0, K=3, cadence=cad)
        causes = {}
        for _, _, c in tl:
            causes[c] = causes.get(c, 0) + 1
        print("      %-12s R=5 K=3  stage %d/%d  causes %s"
              % (frag, st, len(beacons), causes))
        if bos:
            tlb, stb = route_walk_bosses(rows, beacons, 5.0, v, bos, K=3, cadence=cad)
            cb = {}
            for _, _, c in tlb:
                cb[c] = cb.get(c, 0) + 1
            bal = sum(cb.values()) == stb
            print("      %-12s + boss-set  stage %d/%d  causes %s   accounting %s"
                  % ("", stb, len(beacons), cb,
                     "BALANCES" if bal else "<-- BROKEN, %d entries for %d stages"
                     % (sum(cb.values()), stb)))
            print("         bosses: %s" % ", ".join("%s @%.0f" % (n, g) for n, g in bos))
        else:
            print("      %-12s boss-set: ABSENT - no boss identity in this record" % "")
    print("      ⚠ `boss-set` uses the engagement only as a TIMESTAMP the record carries.")
    print("        It advances past beacons already REACHED. It models nothing about bosses.")
    print("")
    print("      ★★ AND THE TRADE IS VISIBLE, emitted without a recommendation:")
    print("         an authoritative set SUPPRESSES detections that would have fired.")
    print("         SFK_live  19 hit / 2 skip  ->  7 hit / 13 skip / 1 boss-set")
    print("         SFK_Run4  54 hit / 4 skip  -> 19 hit / 36 skip / 3 boss-set")
    print("         rfc_combat  unchanged - every pin was reached before its boss.")
    print("      ⚠ So on a 9-boss route it converts most of the timeline to skips. That")
    print("        is arguably CORRECT (the player did pass them) and it destroys the")
    print("        detection evidence. Which reading wins is not the bench's to pick.")
    print("")

    # ---- W5.4 ------------------------------------------------------------
    print("W5.4  the generating run must reach its OWN last stage at R=5")
    ok54 = True
    for frag, rows, beacons in fixtures:
        cad = cadence_of(rows)
        tl, stage = route_walk(rows, beacons, 5.0, K=None, cadence=cad)
        good = stage == len(beacons)
        ok54 = ok54 and good
        print("      %-12s stage %d of %d   hit %d  skip %d   %s"
              % (frag, stage, len(beacons),
                 len([t for t in tl if t[2] == "hit"]),
                 len([t for t in tl if t[2] == "skip"]),
                 "PASS" if good else "<-- LOOK AT THE WALK OR THE MARKERS"))
    print("      ★ CONDITIONAL SATISFIED: a marker is the player's position (above), so")
    print("        \"by construction\" holds on these fixtures. On the retired RFC trio it")
    print("        must FAIL under W1.10 - that failure IS the W1.10 test, in `walk.py w1`.")
    print("")

    # ---- W5.5 ------------------------------------------------------------
    print("W5.5  cross-fixture - numbers only, no grade")
    print("      ⚠ `reached` is the STAGE INDEX and is inflated by skips; `hit` is honest.")
    print("      %-12s %-12s %5s %8s %6s %6s"
          % ("legs from", "route from", "R", "reached", "hit", "skip"))
    def map_of(rows):
        return next((r.get("mapID") for r in rows if r.get("mapID") is not None), None)
    for a in fixtures:
        for b in fixtures:
            if a[0] == b[0]:
                continue
            # ⚠ A cross pair between different maps is a COORDINATE-SPACE mismatch, not a
            # route test - the numbers would be meaningless rather than merely poor. Named
            # and skipped, because a skipped pair and an absent pair look identical.
            if map_of(a[1]) != map_of(b[1]):
                print("      %-12s %-12s   SKIPPED - map %s vs %s, different spaces"
                      % (a[0], b[0], map_of(a[1]), map_of(b[1])))
                continue
            cad = cadence_of(a[1])
            for R in (5.0, 12.0):
                tl, stage = route_walk(a[1], b[2], R, K=None, cadence=cad)
                print("      %-12s %-12s %5.1f %8d %6d %6d"
                      % (a[0], b[0], R, stage,
                         len([t for t in tl if t[2] == "hit"]),
                         len([t for t in tl if t[2] == "skip"])))
    print("      ★ Only same-map pairs are run. SFK and RFC do not share a coordinate")
    print("        space, so those pairs are named as skipped rather than emitted as noise.")
    print("")

    # ---- the two rates, shown -------------------------------------------
    print("★★ THE TWO RATES, SHOWN - test1 is 0.2 s, so replay cadence == live cadence")
    head, t1rows, _ = load("test1")
    beacons = load_markers("SFK_live")[0]
    if head is not None and beacons:
        print("   test1 legs (map 33) against SFK_live's %d-beacon route" % len(beacons))
        print("      %-10s %6s %6s %10s" % ("cadence", "rows", "R", "detected"))
        for every, name in ((0.0, "0.2 s"), (1.0, "1 Hz")):
            rr = t1rows if every == 0.0 else decimate(t1rows, every)
            cad = cadence_of(rr)
            for R in (1.0, 2.0, 3.0, 5.0):
                v = first_visits(rr, beacons, R, cadence=cad)
                print("      %-10s %6d %6.1f %10d" % (name, len(rr), R,
                                                      sum(1 for x in v if x is not None)))
        print("      ★ R=1 is the case that killed the \"pessimistic\" wording: the COARSER")
        print("        path detects MORE, because a cut corner is a phantom hit.")
    print("")

    # ---- the cut-corner kill fixture -------------------------------------
    print("★★★ THE CUT-CORNER KILL FIXTURE - a beacon that fires ONLY on the decimated path")
    turn = []
    gt = 0.0
    for k in range(21):                       # a right-angle turn, 0.2 s samples
        turn.append({"x": -14.0 + 1.4 * k if k <= 10 else 0.0,
                     "y": 0.0 if k <= 10 else 1.4 * (k - 10),
                     "z": 0.0, "mapID": 33, "gt": gt})
        gt += 0.2
    b = (-2.6, 2.6, 0.0)                      # inside the corner the chord cuts across
    fine = first_visits(turn, [b], 2.0, cadence=0.2)
    coarse_rows = decimate(turn, 1.0)
    coarse = first_visits(coarse_rows, [b], 2.0, cadence=1.0)
    print("      a 90-degree turn walked at 0.2 s; beacon placed INSIDE the corner")
    print("      at 0.2 s (true path):  %s" % ("detected" if fine[0] is not None else "SILENT"))
    print("      at 1 Hz (decimated) :  %s"
          % ("DETECTED - a transit that never happened" if coarse[0] is not None
             else "silent"))
    good = fine[0] is None and coarse[0] is not None
    print("      %s" % ("★ PASS - the phantom is reproduced on demand."
                        if good else "⚠ not reproduced with this geometry; reported, not tuned."))
    print("")

    print("   " + "-" * 68)
    print("   W5 emitted. W5.4 %s." % ("PASS" if ok54 else "FAIL - see above"))
    return 0 if ok54 else 1



# ---------------------------------------------------------------------------
# W3.2 - THE DEFAULT TIGHT BAND, SOURCED
# ---------------------------------------------------------------------------
# ★★★ THIS IS THE PRODUCT QUESTION, not a refinement of it. Battlewrath's steer:
# *"can we detect a player around a R of a location and lock out specific dimensions to
# shape form - detect in the H, or limit the H to player height + jump affordance."* The
# band IS the H. And the ROUTED fact that makes it tractable: a unit's position z is its
# BASE POINT (ROUTER §280, emulator source), so model height never enters - the band only
# has to absorb what a player's own feet do on one surface.
#
# ⚠ AND FLOORS CANNOT HELP. §73: "floors do not separate in z at all - SFK floor 2 sits
# BELOW floor 1, floors 4/5 touch exactly, 5 and 6 overlap by 4.8 yd, floor 7 sits inside
# 1 and 3. Dungeon floors are wings, not altitudes." The band is the ONLY vertical
# discriminator there is.

AUTHORED_ROUTES = "addons/landing/staging"


def authored_beacons(fragment):
    """Beacons from a landed AUTHORED route (the `dungeonroutes` collection).

    ★ These are the designer's own placements, and they are the right source for the
    REJECT bound: two beacons the author made distinct are, by construction, two places a
    band must not conflate.
    """
    out = []
    for p in sorted(glob.glob(AUTHORED_ROUTES + "/*__dungeonroutes.json")):
        if fragment.lower() not in os.path.basename(p).lower():
            continue
        try:
            pay = json.load(io.open(p, encoding="utf-8"))["payload"]
        except Exception:
            continue
        for b in (pay.get("beacons") or []):
            if b.get("z") is not None:
                out.append(b)
    return out


def w3_2():
    """W3.2 - emit the three measurements and the bound they imply. No ruling."""
    print("")
    print("   W3.2 - THE DEFAULT TIGHT BAND, SOURCED FROM THE CORPUS")
    print("   " + "-" * 68)
    print("   ★ position z is the unit's BASE POINT (ROUTER, emulator source), so this")
    print("     measures what one player's FEET do - not what a model is.")
    print("")

    regime = ("SFK_live", "SFK_Run4", "test1", "test3", "test4", "rfc_combat")

    # ---- (i) the noise floor -------------------------------------------
    print("(i)  dz JITTER while stationary on one surface - the noise a band must tolerate")
    print("     %-12s %7s %9s %9s %9s" % ("fixture", "n", "p50", "p99", "max"))
    all_j = []
    for frag in regime:
        head, rows, path = load(frag)
        if head is None:
            continue
        j = []
        for a, b in zip(rows, rows[1:]):
            if not (usable(a) and usable(b)) or a.get("floor") != b.get("floor"):
                continue
            dt = (b.get("gt") or 0) - (a.get("gt") or 0)
            if dt <= 0:
                continue
            if d3((a["x"], a["y"], a["z"]), (b["x"], b["y"], b["z"])) / dt < 0.5:
                j.append(abs(b["z"] - a["z"]))
        if j:
            j.sort()
            all_j += j
            print("     %-12s %7d %9.4f %9.4f %9.4f"
                  % (frag, len(j), j[len(j) // 2], j[int(len(j) * .99)], j[-1]))
    all_j.sort()
    jit = all_j[-1] if all_j else None
    print("     %-12s %7d %9.4f %9.4f %9.4f"
          % ("ALL", len(all_j), all_j[len(all_j) // 2], all_j[int(len(all_j) * .99)], jit))
    print("     ★ §73 measured the same thing on his height-map beacons: 0.00-0.09 yd.")

    # ---- (ii) the jump --------------------------------------------------
    print("")
    print("(ii) JUMP APEX -> bandUp.  ★★★ MEASURED §284.")
    print("     records/*__unitstate.json - four flat on-foot jumps, IsFalling edges with")
    print("     the z peak between them. NOT a shape hunted in z: the client says airborne.")
    print("")
    print("       measured apex     1.6289 / 1.6359 / 1.6387 / 1.6404   spread 0.0115")
    print("       sampling bound    <= 0.5*g*(dt/2)**2 = 0.0965 yd under-measured")
    print("       TRUE APEX in      [1.6404, 1.7368]")
    print("       implied zspeed    7.955 .. 8.186  ->  8.0 exactly gives 1.6588")
    print("")
    print("     ★★ The error bound is what makes it decisive, and it is physics not")
    print("     luck: near the apex vertical velocity -> 0, so a sample lands close to the")
    print("     peak. Worst case dt/2 away costs 0.0965 yd - tight enough to EXCLUDE 1.9.")
    print("")
    print("       1.27002  engine-derived   EXCLUDED, below the measured peak")
    print("       1.5      folklore         EXCLUDED, below the measured peak")
    print("       1.6588   zspeed = 8.0     ★ IN RANGE")
    print("       1.9      OURS, §73        EXCLUDED, above the bound - retired")
    print("")
    print("     ⚠ §73's 1.9 came from runs that were never landed. Our own figure,")
    print("       retired by our own instrument.")
    print("")
    print("     \u2605\u2605\u2605 AND IT CHANGES NO BAND, which is the ruling that matters.")
    print("     Battlewrath, \u00a7284: a general catch-all, not super precision - the band",
          "is a check")
    print("     against the objective's current height and whether we are in tolerance.")
    print("     We are NOT simulating the game physics.")
    print("")
    print("     \u00a773's ruled +-2.5 admits a 1.66 jump with 0.84 to spare and rejects")
    print("     the 9.71 stack with 7.21 to spare. A number ruled on JUDGEMENT, confirmed")
    print("     by a measurement taken three days later. Nothing to change.")

    # ---- (iii) the drop -------------------------------------------------
    print("")
    print("(iii) worst DOWNWARD dz within one floor -> bandDown")
    print("     %-12s %7s %9s %9s %9s" % ("fixture", "n", "p50", "p99", "max drop"))
    all_d = []
    for frag in regime:
        head, rows, path = load(frag)
        if head is None:
            continue
        d = []
        for a, b in zip(rows, rows[1:]):
            if not (usable(a) and usable(b)) or a.get("floor") != b.get("floor"):
                continue
            dz = b["z"] - a["z"]
            if dz < 0:
                d.append(-dz)
        if d:
            d.sort()
            all_d += d
            print("     %-12s %7d %9.4f %9.4f %9.4f"
                  % (frag, len(d), d[len(d) // 2], d[int(len(d) * .99)], d[-1]))
    all_d.sort()
    print("     %-12s %7d %9.4f %9.4f %9.4f"
          % ("ALL", len(all_d), all_d[len(all_d) // 2], all_d[int(len(all_d) * .99)],
             all_d[-1]))
    print("     ⚠ This is a PER-TICK delta, so it mixes a fall with a ramp walked fast.")
    print("       It bounds what a band must tolerate; it does not identify a drop.")

    # ---- (iv) the reject bound ------------------------------------------
    print("")
    print("(iv) REJECT BOUND - the smallest z separation the author made DISTINCT")
    bs = authored_beacons("Height_map")
    if not bs:
        print("     ⚠ NO AUTHORED ROUTE LANDED. `pull.py once --source dungeonroutes`.")
        tight = None
    else:
        print("     %d authored beacons across the Height_map routes" % len(bs))
        print("")
        print("     ⚠⚠ AND THE NAIVE READING OF THIS IS WRONG, so it is spelled out.")
        print("        My first pass took the smallest NON-ZERO dz among nearby pairs and")
        print("        called it a separation to reject. It is not: §73 measured")
        print("        *same surface, standing: 0.00-0.09 yd* on THESE VERY BEACONS, up to")
        print("        12 yd apart on one surface. A 0.09 yd dz is FLOOR MICRO-VARIATION,")
        print("        not two places. Rejecting it would mean rejecting a flat floor.")
        print("")
        pairs = []
        for i in range(len(bs)):
            for k in range(i + 1, len(bs)):
                a, b = bs[i], bs[k]
                pairs.append((math.hypot(a["x"] - b["x"], a["y"] - b["y"]),
                              abs(a["z"] - b["z"])))
        near = [p for p in pairs if p[0] <= 12.0]
        SAME_SURFACE = 0.10          # §73's measured ceiling for one surface
        flat = [dz for pl, dz in near if dz <= SAME_SURFACE]
        stack = sorted(set(round(dz, 2) for pl, dz in near if dz > SAME_SURFACE))
        print("     within 12 yd planar: %d pairs" % len(near))
        print("       %3d at dz <= %.2f  -> ONE SURFACE (§73's measured range)"
              % (len(flat), SAME_SURFACE))
        print("       %3d above it       -> genuinely stacked: %s"
              % (len(near) - len(flat), ", ".join("%.2f" % v for v in stack) or "none"))
        tight = min(stack) if stack else None
        print("     ★ smallest GENUINELY STACKED separation: %s"
              % ("%.2f yd" % tight if tight else "none in this route"))
        print("       (§73 named the same figure independently: *a real stack 9.71 yd -")
        print("        the walkway*, 3.12 yd apart planar)")
        print("")
        print("     ⚠ I cannot derive this bound WITHOUT the 0.10 cut, and that cut comes")
        print("       from §73 rather than from these beacons. Two beacons on one surface")
        print("       and two on different surfaces are indistinguishable from geometry")
        print("       alone - it is the AUTHOR'S INTENT that separates them.")

    # ---- what it implies ------------------------------------------------
    print("")
    print("   " + "-" * 68)
    print("   WHAT THIS IMPLIES - emitted, NOT ruled")
    print("     the band must ADMIT   jitter %s  and a jump (UNMEASURED)"
          % ("%.4f" % jit if jit else "?"))
    print("     the band must REJECT  %s"
          % ("a %.2f yd stack" % tight if tight else "(no stacked pair in the route)"))
    if jit and tight:
        room = tight - 1.9
        print("")
        print("     ★ AND IT FITS COMFORTABLY, which my first pass got backwards.")
        print("        admit  jitter %.4f   (a jump need NOT be admitted - \u00a7285)" % jit)
        print("        reject %.2f  ->  %.2f yd of clearance above the largest candidate"
              % (tight, room))
        print("        ⚠ §73 ALREADY RULED THIS: driver.lua carries '±2.5 yd' with the")
        print("          note that the 9.71 stack 'is excluded by it with room to spare'.")
        print("          W3.2 re-derived that ruling from the landed route, and \u00a7284's")
        print("          jump measurement CONFIRMS it: 1.66 admitted with 0.84 to spare.")
    print("")
    print("")
    print("   \u2605\u2605\u2605 WHAT bandUp IS FOR - and it is NARROWER than I had it")
    print("   Battlewrath, \u00a7285: *\"the height band up only exists to protect running")
    print("   over it from a second floor. And the MAX doesn\u2019t need to be any height any")
    print("   character can ever reach. They always land back onto the floor.\"*")
    print("")
    print("   \u26a0\u26a0 SO THE BAND DOES NOT NEED TO ADMIT A JUMP, and I had that backwards.")
    print("   A jump is TRANSIENT: the player returns to the floor, so the beacon fires on")
    print("   landing whatever the band does at the apex. Admitting 1.66 yd was never a")
    print("   requirement - it was me reading a measurement as a constraint.")
    print("")
    print("   \u2605 bandUp\u2019s floor is JITTER (%.4f measured); its ceiling is the SMALLEST" % jit)
    print("   vertical separation between two real surfaces. Tighter is better, not safer-")
    print("   looking - a loose band conflates floors, which is the only thing it guards.")
    print("")
    print("   ⚠ IS ±2.5 LOOSE? I raised that; Battlewrath dissolved it (§286).")
    print("   §73 recorded distinct surfaces 1.30 yd apart, and the MEASURED minimum")
    print("   vertical stack the player actually WALKED is 0.50-0.52 yd in every fixture.")
    print("")
    print("   ★★ But a half-yard rise at one xy is a STAIR TREAD, and his ruling is that")
    print("   stairs are TRANSIT: a staircase has stable planes, but you do not stop on")
    print("   one - the beacon sits at the BOTTOM as a pointer or the TOP as a lure.")
    print("   Nobody authors a beacon on a stair, so the tight stacks are never sites.")
    print("")
    print("   ★★★ SO THE BAND’S CEILING IS SET BY WHERE BEACONS GO, not by the tightest")
    print("   stack the geometry permits. ±2.5 STANDS.")
    print("   ⚠ Third time running the constraint came from AUTHORING, not the world -")
    print("   after mob positions (unauthorable) and lure/destination (a placement, not")
    print("   a shape). I keep measuring what the GAME allows and reading it as what the")
    print("   BAND must survive.")
    print("")
    return 0


# ---------------------------------------------------------------------------

def fmt(v, nd=4):
    if v is None:
        return "ABSENT"
    if isinstance(v, bool):
        return "yes" if v else "NO"
    if isinstance(v, float):
        return ("%%.%df" % nd) % v if abs(v) >= 1e-4 else "%.2e" % v
    return str(v)


def near(got, want, tol):
    return got is not None and abs(got - want) <= tol


def main():
    ap = argparse.ArgumentParser(description="the walk - the driver's rule, offline")
    ap.add_argument("mode", nargs="?", default="check",
                    choices=("w1", "w2", "w3", "w32", "w4", "w5", "check"))
    ap.add_argument("--run", default="test1")
    a = ap.parse_args()

    if a.mode == "w32":
        return w3_2()

    if a.mode == "w5":
        return w5()

    if a.mode == "w1":
        # ★ W1 is the RULE, not a readout of one run - it carries its own fixtures and
        # two synthetic ones, so it must not be gated behind loading `--run`.
        return w1()

    head, rows, path = load(a.run)
    if head is None and rows is None:
        print("")
        print("   " + path)
        print("")
        return 1

    print("")
    print("   %s" % os.path.basename(path))
    print("   run %s · profile %s · %d rows · pinSet %s" % (
        head.get("run"), head.get("profile"), len(rows), head.get("testPinSet")))
    prov = head.get("_provenance") or {}
    print("   proof %s  sha %s" % (prov.get("raw_clone", "?"), (prov.get("sha256") or "")[:12]))
    print("   " + "-" * 68)

    fails = []

    if a.mode in ("w2", "check"):
        r = w2(head, rows)
        print("")
        print("   W2  calibration")
        for k in ("rows_both", "sd_pos", "sd_zero", "sd_zero_contiguous_at_start",
                  "sd_zero_od_pos", "mean", "median", "p99", "max", "sd_min", "sd_max",
                  "od_is_3d_euclid_within", "od_vs_2d_max_gap", "cross_floor_rows",
                  "cross_floor_max", "dz_min", "dz_max", "diverge_flags_eps1"):
            print("     %-30s %s" % (k, fmt(r[k])))
        if a.mode == "check":
            g = GOLD["w2"]
            for k in ("rows_both", "sd_pos", "sd_zero", "sd_zero_od_pos", "cross_floor_rows"):
                if r[k] != g[k]:
                    fails.append("W2.%s got %s want %s" % (k, r[k], g[k]))
            for k, tol in (("mean", 5e-7), ("median", 5e-7), ("p99", 2e-6),
                           ("max", 2e-6), ("cross_floor_max", 2e-6)):
                if not near(r[k], g[k], tol):
                    fails.append("W2.%s got %s want %s" % (k, fmt(r[k]), fmt(g[k])))
            for k, tol in (("sd_min", 0.005), ("sd_max", 0.005),
                           ("dz_min", 0.05), ("dz_max", 0.05)):
                if not near(r[k], g[k], tol):
                    fails.append("W2.%s got %s want %s" % (k, fmt(r[k], 2), fmt(g[k], 2)))
            if not r["sd_zero_contiguous_at_start"]:
                fails.append("W2 sd==0 rows are not contiguous at the start")
            if r["diverge_flags_eps1"] != 0:
                fails.append("W2.2 divergence flagged %d rows on test1, want 0"
                             % r["diverge_flags_eps1"])

    if a.mode in ("w3", "check"):
        r = w3(rows)
        print("")
        print("   W3  speed (yd/s)")
        for k in ("samples", "moving", "p10", "p50", "p90", "p99", "max"):
            print("     %-30s %s" % (k, fmt(r[k], 2)))
        if a.mode == "check":
            g = GOLD["w3"]
            for k in ("samples", "moving"):
                if r[k] != g[k]:
                    fails.append("W3.%s got %s want %s" % (k, r[k], g[k]))
            for k in ("p10", "p50", "p90", "p99", "max"):
                if not near(r[k], g[k], 0.01):
                    fails.append("W3.%s got %s want %s" % (k, fmt(r[k], 2), g[k]))

    if a.mode in ("w4", "check"):
        print("")
        print("   W4  reconstruction error under decimation (yd, 2D)")
        print("     %-8s %-6s %8s %8s %8s %8s" % ("every", "kept", "p50", "p90", "p99", "max"))
        for every in (1.0, 2.0, 4.0):
            r = w4(rows, every)
            if not r:
                fails.append("W4 %.1fs produced nothing" % every)
                continue
            print("     %-8.1f %-6d %8.2f %8.2f %8.2f %8.2f" % (
                every, r["kept"], r["p50"], r["p90"], r["p99"], r["max"]))
            if a.mode == "check":
                g = GOLD["w4"][every]
                for i, k in enumerate(("p50", "p90", "p99", "max")):
                    if not near(r[k], g[i], 0.01):
                        fails.append("W4[%.1f].%s got %.2f want %.2f" % (every, k, r[k], g[i]))

    print("")
    if a.mode == "check":
        if head.get("run") != GOLD["run"]:
            print("   ⚠ goldens are for %r; this is %r - comparison skipped"
                  % (GOLD["run"], head.get("run")))
            return 2
        if fails:
            print("   FAIL - %d mismatch(es) against the acceptance goldens:" % len(fails))
            for f in fails:
                print("     ✖ %s" % f)
            print("")
            print("   ⚠ Neither side is assumed correct. The goldens came FIRST, so the")
            print("     build is the likelier suspect - but say which, do not just tune.")
            print("")
            return 1
        print("   PASS - every W2/W3/W4 golden reproduced.")
    print("")
    return 0


if __name__ == "__main__":
    sys.exit(main())
