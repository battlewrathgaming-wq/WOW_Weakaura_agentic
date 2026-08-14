"""verify_calibration.py - does the fraction->world fit actually hold?

calibrate.lua converts a map fraction into world coordinates by fitting an affine
transform from points we already captured. Two claims sit under that, and neither
is safe to assume:

  1. The relationship is LINEAR.        (maps/worldmap proved it against the DBC
                                         boxes - worst error 0.000000 - but that is
                                         a claim about the boxes, not about our fit)
  2. It is a CONSTANT OF THE MAP.       Every run of one dungeon must yield the same
                                         transform, or "the runs are the samples" is
                                         wrong and a pooled fit is worse than a
                                         per-run one.

Claim 2 is the one that per-run fitting could never test, and it is the one the
whole design now rests on. So: fit from ONE run, predict a DIFFERENT run's points
on the same map, and report the error in yards.

Reads the landed records - real captures with real capture noise, not synthetic
data. Emitted numbers only; nothing here is interpreted for you.

    py addons/tools/verify_calibration.py
"""

import io
import json
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

ROOT = Path(__file__).resolve().parents[2]
RECORDS = [ROOT / "addons" / "landing" / "records", ROOT / "addons" / "landing" / "staging"]

MIN_SAMPLES = 3


def solve3(a, b):
    m = [list(a[i]) + [b[i]] for i in range(3)]
    for col in range(3):
        piv = max(range(col, 3), key=lambda r: abs(m[r][col]))
        if abs(m[piv][col]) == 0:
            return None
        m[col], m[piv] = m[piv], m[col]
        for r in range(3):
            if r != col:
                f = m[r][col] / m[col][col]
                for c in range(col, 4):
                    m[r][c] -= f * m[col][c]
    return [m[i][3] / m[i][i] for i in range(3)]


def fit(samples):
    """The same normal equations calibrate.lua solves. Kept deliberately parallel."""
    if len(samples) < MIN_SAMPLES:
        return None
    a = [[0.0] * 3 for _ in range(3)]
    bx, by = [0.0] * 3, [0.0] * 3
    for s in samples:
        v = (s["mapX"], s["mapY"], 1.0)
        for i in range(3):
            for j in range(3):
                a[i][j] += v[i] * v[j]
            bx[i] += v[i] * s["x"]
            by[i] += v[i] * s["y"]
    px, py = solve3(a, bx), solve3(a, by)
    if not px or not py:
        return None
    return px + py


def apply(f, mx, my):
    return f[0] * mx + f[1] * my + f[2], f[3] * mx + f[4] * my + f[5]


def error(f, samples):
    worst, sq = 0.0, 0.0
    for s in samples:
        ex, ey = apply(f, s["mapX"], s["mapY"])
        d = ((ex - s["x"]) ** 2 + (ey - s["y"]) ** 2) ** 0.5
        sq += d * d
        worst = max(worst, d)
    return (sq / len(samples)) ** 0.5, worst


def map_id_of(run):
    inst = run.get("instance") or {}
    if inst.get("mapID"):
        return inst["mapID"]
    for lst in (run.get("markers") or [], run.get("legs") or []):
        for p in lst:
            if p.get("mapID"):
                return p["mapID"]
    return None


def load_runs():
    """Every run in every landed record, keyed by (mapID, floor) -> per-run samples."""
    out = {}
    for folder in RECORDS:
        if not folder.is_dir():
            continue
        for path in sorted(folder.glob("*__dungeonrun.json")):
            doc = json.load(io.open(path, encoding="utf-8"))
            # A landed record is one RUN under `payload`, keyed by the header's
            # `key` - not a table of runs. Read the shape the pipeline emits.
            run = doc.get("payload")
            if not isinstance(run, dict):
                continue
            rid = (doc.get("header") or {}).get("key") or path.stem
            for _ in (0,):
                mid = map_id_of(run)
                if not mid:
                    continue
                for lst in (run.get("legs") or [], run.get("markers") or []):
                    for p in lst:
                        if all(p.get(k) is not None for k in ("mapX", "mapY", "x", "y")):
                            key = (mid, p.get("floor") or 0)
                            out.setdefault(key, {}).setdefault(rid, []).append(p)
    return out


def main():
    data = load_runs()
    if not data:
        sys.exit("no landed records with paired points - nothing to verify")

    print("CALIBRATION VERIFICATION - fraction -> world, fitted from captures\n")
    cross_worst = 0.0
    cross_cases = 0

    for (mid, floor), per_run in sorted(data.items()):
        total = sum(len(v) for v in per_run.values())
        print(f"map {mid} floor {floor}   {len(per_run)} run(s), {total} paired point(s)")

        pooled = [p for v in per_run.values() for p in v]
        f = fit(pooled)
        if not f:
            print("    pooled fit: DECLINED (too few samples)\n")
            continue
        rms, worst = error(f, pooled)
        print(f"    pooled fit over all runs      rms {rms:.6f}   worst {worst:.6f} yd")

        # ★ THE CLAIM THAT MATTERS. Fit on one run, predict another. If the transform
        # is a constant of the MAP this is as good as the pooled fit; if it drifts per
        # run, the pooled fit is a lie and this is where it shows.
        ids = sorted(per_run)
        for src in ids:
            if len(per_run[src]) < MIN_SAMPLES:
                continue
            fsrc = fit(per_run[src])
            if not fsrc:
                continue
            for dst in ids:
                if dst == src or len(per_run[dst]) < 1:
                    continue
                r2, w2 = error(fsrc, per_run[dst])
                cross_worst = max(cross_worst, w2)
                cross_cases += 1
                print(f"    fit {src[:28]:<28} -> {dst[:28]:<28} rms {r2:.6f}  worst {w2:.6f} yd")
        print()

    print("-" * 72)
    if cross_cases:
        print(f"CROSS-RUN: {cross_cases} case(s), worst error {cross_worst:.6f} yards")
        print("  ★ This is the number that decides whether the transform is a constant")
        print("    of the MAP. Near zero = the runs really are interchangeable samples.")
    else:
        print("CROSS-RUN: no map has two runs with enough paired points - claim UNTESTED.")
        print("  The pooled numbers above say the fit is linear WITHIN what we have,")
        print("  and say nothing about whether it holds across runs.")


if __name__ == "__main__":
    main()
