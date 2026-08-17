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
                    choices=("w2", "w3", "w4", "check"))
    ap.add_argument("--run", default="test1")
    a = ap.parse_args()

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
