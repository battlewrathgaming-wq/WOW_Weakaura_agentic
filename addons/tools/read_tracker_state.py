"""read_tracker_state.py - what the supertracker's own state does, read off landed runs.

★ WHY THIS EXISTS AND WHY IT IS NOT IN `walk.py`. Every number in the 2026-08-17 tracker
findings came out of four throwaway scripts in a scratchpad - nothing anyone else could run,
and nothing that survives the session. That is invariant 7 exactly: *"a repeatable transform
is a build-once tool you trigger, never hand-improvised per run."* This is the tool.

⚠ It is DELIBERATELY SEPARATE FROM `walk.py`. `walk.py` is the driver's desk simulator and is
graded against `driver_walk_acceptance.md` W0-W7 - the main line. What is below is an
INSTRUMENT STUDY: it characterises the client's tracker, which Battlewrath ruled is not
load-bearing for detection (*"the trip wire is ours"*, 2026-08-17). Merging the two would put
a side-road inside the acceptance-tested tool and let it wear the main line's clothes, which
is the drift this study already had corrected once.

★ WHAT IT IS GOOD FOR, stated narrowly: `ts` is a VERIFIER. Both of its useful values are
reproducible from data we already hold (`ts == 0` from a mapID comparison, `ts == 4` from our
own distance), so nothing depends on it - its job is to disagree loudly if our arithmetic ever
drifts from the engine's.

★ IT READS THE CORPUS, which is the point of having one. ⚠ It did not, for one commit: the
emitter dropped `ts` through `reduce_run`, so the field this entire file is about was in the
raw record and absent from the reduced one, and every number here had to come from `staging/`.
§269 audited the whole view rather than patching that one field - `ts`, `mapX` and `mapY` were
all being dropped while varying, `zone` was nowhere, and three genuinely constant fields are
now NAMED as omitted instead of just missing. ★ A reduced view is only worth reading if what
it left out is on the record.

    py addons/tools/read_tracker_state.py              every section
    py addons/tools/read_tracker_state.py runs         per-run summary
    py addons/tools/read_tracker_state.py grid         the pin-in / pin-out 2x2
    py addons/tools/read_tracker_state.py edge         state transitions, --run test4
    py addons/tools/read_tracker_state.py threshold    the flip bracket, all runs
"""
import argparse
import glob
import io
import json
import math
import os
import sys
from collections import Counter

LANDING = "addons/landing"
DECLINED, TRACKING, INSIDE = 0, 2, 4


def records(match=None):
    """Reduced runs whose rows carry `ts`, oldest first.

    ⚠ A file with no `ts` is SKIPPED, not warned about - most landed runs predate the dev
    profile and never had a target state to record. An empty result is reported by the
    caller, which is the only place that can tell "nothing matched" from "nothing has it".
    """
    out = []
    for p in sorted(glob.glob(LANDING + "/corpus/*__legs.jsonl")):
        if match and match.lower() not in os.path.basename(p).lower():
            continue
        try:
            lines = [json.loads(x) for x in io.open(p, encoding="utf-8") if x.strip()]
        except Exception:
            continue
        if len(lines) < 2:
            continue
        head, rows = lines[0], lines[1:]
        if "ts" not in (head.get("fields") or []):
            continue
        pay = {"legs": rows, "name": head.get("run"), "zone": head.get("zone"),
               "testPin": head.get("testPin") or {},
               "testPinSet": head.get("testPinSet")}
        out.append((p, pay, head.get("_provenance") or {}))
    return out


def name(pay, path):
    return pay.get("name") or os.path.basename(path).split("__")[-1]


def d3(a, b):
    return math.sqrt(sum((a[k] - b[k]) ** 2 for k in "xyz"))


def speed_at(legs, i):
    """yd/s across the sample ENDING at i, from raw positions. None if undefined."""
    if i <= 0:
        return None
    a, b = legs[i - 1], legs[i]
    dt = b.get("gt", 0) - a.get("gt", 0)
    if not dt:
        return None
    return d3(a, b) / dt


# --------------------------------------------------------------------- runs

def sec_runs(rows):
    print("PER-RUN SUMMARY")
    print("  %-8s %6s %6s  %-22s %-24s" % ("run", "rows", "map", "target state ts", "pin"))
    for p, pay, _ in rows:
        legs, pin = pay["legs"], (pay.get("testPin") or {})
        maps = Counter(r.get("mapID") for r in legs)
        m = maps.most_common(1)[0][0]
        ts = Counter(r.get("ts") for r in legs)
        where = "IN " if pin.get("mapID") == m else "OUT"
        print("  %-8s %6d %6s  %-22s map %s %s"
              % (name(pay, p), len(legs), m,
                 " ".join("%s:%d" % kv for kv in sorted(ts.items())),
                 pin.get("mapID"), where))

    print()
    print("  %-8s %-24s %-24s %s" % ("run", "sd (engine)", "od (ours)", "|sd-od| max"))
    for p, pay, _ in rows:
        legs = pay["legs"]
        sd = [r["sd"] for r in legs if r.get("sd") is not None]
        od = [r["od"] for r in legs if r.get("od") is not None]
        if not sd or not od:
            print("  %-8s (absent)" % name(pay, p))
            continue
        dif = max(abs(r["sd"] - r["od"]) for r in legs
                  if r.get("sd") is not None and r.get("od") is not None)
        print("  %-8s %9.2f .. %-11.2f %9.2f .. %-11.2f %.3g"
              % (name(pay, p), min(sd), max(sd), min(od), max(od), dif))
    print()
    print("  ★ Where sd and od agree to ~1e-5 the pin is live. Where sd is pinned at 0.00")
    print("    while od is large, the engine has DECLINED - and that gap is the whole signal.")


# --------------------------------------------------------------------- grid

def sec_grid(rows):
    print("THE 2x2 - does ts == 0 track the PIN or the DUNGEON?")
    cells = {}
    for p, pay, _ in rows:
        legs, pin = pay["legs"], (pay.get("testPin") or {})
        m = Counter(r.get("mapID") for r in legs).most_common(1)[0][0]
        inside = pin.get("mapID") == m
        cells.setdefault((m, inside), []).append(
            "%s ts{%s}" % (name(pay, p),
                           ",".join(str(k) for k in sorted({r.get("ts") for r in legs}))))
    maps = sorted({m for m, _ in cells})
    print("      %-14s %-34s %s" % ("", "pin INSIDE", "pin OUTSIDE"))
    for m in maps:
        print("      map %-10s %-34s %s"
              % (m, " · ".join(cells.get((m, True), ["-"])),
                 " · ".join(cells.get((m, False), ["-"]))))
    print()
    print("  ⚠ One dungeon with only ONE of the two columns filled cannot attribute a")
    print("    difference - the map and the pin move together. A row needs both cells.")


# --------------------------------------------------------------------- edge

def sec_edge(rows):
    print("STATE TRANSITIONS - threshold, or latency?")
    print("  A flip distance that RISES with speed is the state lagging. One that is flat")
    print("  across a wide speed range is a distance threshold, and needs no debounce.")
    any_flip = False
    for p, pay, _ in rows:
        legs = pay["legs"]
        flips = []
        for i in range(1, len(legs)):
            a, b = legs[i - 1], legs[i]
            if a.get("ts") == b.get("ts"):
                continue
            flips.append((i, a["ts"], b["ts"], a["sd"], b["sd"], speed_at(legs, i),
                          "IN " if b["sd"] < a["sd"] else "OUT"))
        if not flips:
            continue
        any_flip = True
        print()
        print("  %s - %d transition(s)" % (name(pay, p), len(flips)))
        print("    %-6s %-9s %9s %9s %8s  %s"
              % ("row", "flip", "sd before", "sd after", "speed", "dir"))
        for i, t0, t1, s0, s1, v, d in flips:
            print("    %-6d %d->%-6d %9.2f %9.2f %8s  %s"
                  % (i, t0, t1, s0, s1, "%.2f" % v if v else "-", d))
        for lbl, want in (("INWARD ", "IN "), ("OUTWARD", "OUT")):
            fs = [f for f in flips if f[6] == want]
            if not fs:
                continue
            lo = min(min(f[3], f[4]) for f in fs)
            hi = max(max(f[3], f[4]) for f in fs)
            print("    %s n=%d  bracketed %.2f .. %.2f yd  (width %.2f)"
                  % (lbl, len(fs), lo, hi, hi - lo))
    if not any_flip:
        print("  none - no run in this set changes target state.")
        print("  ⚠ A run that starts AT the pin and walks away only ever crosses outbound.")


# ---------------------------------------------------------------- threshold

def sec_threshold(rows):
    print("THE FLIP THRESHOLD - bracketed against EVERY row")
    print("  T lies in (max sd where ts==4, min sd where ts==2]. One contradicting row")
    print("  collapses it, which is what makes it a finding rather than a fit.")
    print()
    lo, hi, tot, used = 0.0, float("inf"), 0, 0
    print("  %-8s %6s   %-22s %s" % ("run", "rows", "max sd @ ts=4", "min sd @ ts=2"))
    for p, pay, _ in rows:
        legs = pay["legs"]
        tot += len(legs)
        a = [r["sd"] for r in legs if r.get("ts") == INSIDE]
        b = [r["sd"] for r in legs if r.get("ts") == TRACKING]
        print("  %-8s %6d   %-22s %s"
              % (name(pay, p), len(legs),
                 "%.4f  (n=%d)" % (max(a), len(a)) if a else "-  (none)",
                 "%.4f  (n=%d)" % (min(b), len(b)) if b else "-  (none)"))
        if a:
            lo = max(lo, max(a))
        if b:
            hi = min(hi, min(b))
        used += 1
    if hi == float("inf") or not used:
        print("\n  no bracket - this set has no run with both states.")
        return
    print()
    print("  %d rows across %d run(s)" % (tot, used))
    print("  THRESHOLD T in (%.4f, %.4f]   width %.4f yd" % (lo, hi, hi - lo))
    for cand in (5.0, 5.5, 6.0):
        print("     %.1f yd  ->  %s" % (cand, "INSIDE" if lo < cand <= hi else "excluded"))

    T = (lo + hi) / 2.0
    bad = sum(1 for _, pay, _ in rows for r in pay["legs"]
              if r.get("ts") != DECLINED
              and ((r["sd"] <= T) != (r.get("ts") == INSIDE)))
    print()
    print("  rule  sd <= %.4f  <=>  ts == 4       contradicting rows: %d" % (T, bad))
    print("  (declined rows excluded - a cross-map distance is not a distance)")
    print()
    print("  ⚠⚠ THE BOUNDS. Measured against pins WE SET, never a real quest POI, so a")
    print("     per-POI radius is unexcluded rather than ruled out. And sd is 3D, so this")
    print("     close a 2D threshold fits the same data. The client acts on NONE of it.")


SECTIONS = {"runs": sec_runs, "grid": sec_grid, "edge": sec_edge,
            "threshold": sec_threshold}


def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("section", nargs="?", default="all", choices=["all"] + list(SECTIONS))
    ap.add_argument("--run", default=None, help="substring; default every run carrying ts")
    a = ap.parse_args()

    rows = records(a.run)
    if not rows:
        print("No reduced run carries `ts` in %s/corpus." % LANDING)
        print("⚠ Two different causes, and they look the same from here:")
        print("   - the runs predate the dev profile (most do - `ts` starts with §248)")
        print("   - or the corpus is stale: re-run `py addons/tools/emit_run_corpus.py`")
        return 2

    print("SOURCE  landing/corpus/*__legs.jsonl   (reduced view; sha is of the flush)")
    for p, pay, prov in rows:
        print("        %-8s %-22s %-46s sha %s"
              % (name(pay, p), pay.get("zone") or "?", os.path.basename(p),
                 (prov.get("sha256") or "?")[:12]))
    print()

    for key in (SECTIONS if a.section == "all" else [a.section]):
        SECTIONS[key](rows)
        print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
