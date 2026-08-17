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


def transits(rows, beacon, R, band_up=OPEN, band_down=OPEN):
    """Walk `rows` past one beacon. Returns the rule's verdict plus WHY.

    Implements W1.2 (point fallback), W1.3 (mapID straddle DISCARDED, never bridged)
    and W1.4 (no hold - one in-region sample fires) in the one place they interact,
    because they are the same decision seen from three sides: what do I have to test
    against, and is it legitimate to bridge to it.
    """
    r2 = R * R
    first_pt = first_sg = None
    n_pt = n_sg = 0
    fell_back = straddled = skipped = 0
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
        else:
            hit = segment_fire(prev[0], p, beacon, r2, band_up, band_down)
        if hit:
            n_sg += 1
            if first_sg is None:
                first_sg = i
        prev = (p, r["mapID"])
    return {"point_hits": n_pt, "seg_hits": n_sg,
            "first_point": first_pt, "first_seg": first_sg,
            "fell_back": fell_back, "straddled": straddled, "unusable": skipped}


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
            ("same mapID - segment bridges the gap and FIRES", same["seg_hits"] > 0, True),
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


def w1_5(fixtures, radii=(2.0, 3.0, 5.0, 8.0, 12.0)):
    """W1.5 - segment >= point on every fixture and every R. A violation is a bug."""
    print("W1.5  monotonicity: segment must never detect FEWER transits than point")
    print()
    print("  %-34s %6s %s" % ("fixture", "R", "  beacons  point  segment  seg-pt"))
    worst, bad = 0, 0
    for label, rows, beacons in fixtures:
        for R in radii:
            pt = sg = 0
            for b in beacons:
                t = transits(rows, b, R)
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
    results.append(("W1.2/W1.3", w1_23()))
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
                    choices=("w1", "w2", "w3", "w4", "check"))
    ap.add_argument("--run", default="test1")
    a = ap.parse_args()

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
