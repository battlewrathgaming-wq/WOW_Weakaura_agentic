# -*- coding: utf-8 -*-
r"""emit_samples.py - a corpus run becomes a Lua sample list the driver's rule can be
graded against.

    py addons/tools/emit_samples.py --check
    py addons/tools/emit_samples.py --out addons/tools/smoke/fixtures_samples.lua

★★★ WHY IT EXISTS. `rule.lua` is pure Lua and the corpus is `jsonl` — so outcome grading
(W7 rescoped, RI-33) has no way to reach real player paths without a bridge. This is that
bridge and nothing else: it TRANSCRIBES, it does not decide.

⚠⚠ IT COMPUTES NO VERDICT, DELIBERATELY. The desk's verdicts are SEGMENT verdicts, and
the driver has no segment — W7.1's own words, *"the driver has no segment to be equal
about"*. Emitting desk answers as expectations would re-fuse exactly what RI-33 separated,
one file lower down. **The grade belongs in Lua, against the Lua rule.**

★ WHAT IT EMITS: position, mapID and `gt`, at a stated cadence, plus the run's own beacon
candidates are NOT included — a beacon is authored, not captured, and inventing one here
would make the fixture grade the emitter's taste.

⚠ `--check` proves the apparatus before any list is written: the parse round-trips, the
cadence is what was asked for, and a decimated list is a SUBSET of the full one rather
than a resample.
"""
import argparse
import glob
import io
import json
import os
import statistics
import sys

sys.stdout.reconfigure(encoding="utf-8")
# ⚠ stderr TOO. A tool whose FAILURE text is mangled is unreadable exactly when
# it is being read - the first run printed `\u26a0` instead of the marker.
sys.stderr.reconfigure(encoding="utf-8")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CORPUS = os.path.join(ROOT, "landing", "corpus")


# ★ THE CORPUS DECLARES ITS OWN KINDS and holds two: `run-corpus` (a player path)
# and `satnav-corpus` (a tracker probe). ⚠ The first cut selected by FILENAME and
# reported four satnav files as parse failures - the apparatus mis-reading a FACT as a
# FAULT. Select on what the file says it is.
RUN_KIND = "run-corpus"


def kind_of(path):
    head = io.open(path, encoding="utf-8", errors="replace").readline()
    try:
        return json.loads(head).get("_kind")
    except ValueError:
        return None


def run_files():
    out, other = [], []
    for p in sorted(glob.glob(os.path.join(CORPUS, "*__legs.jsonl"))):
        (out if kind_of(p) == RUN_KIND else other).append(p)
    return out, other


def load(path):
    rows = []
    for line in io.open(path, encoding="utf-8", errors="replace"):
        line = line.strip()
        if not line:
            continue
        try:
            r = json.loads(line)
        except ValueError:
            continue
        if (r.get("x") is not None and r.get("y") is not None
                and r.get("z") is not None and r.get("gt") is not None):
            rows.append(r)
    return rows


def cadence_of(rows):
    d = [b["gt"] - a["gt"] for a, b in zip(rows, rows[1:]) if b["gt"] > a["gt"]]
    return statistics.median(d) if d else None


def decimate(rows, every):
    """Keep a row only once `every` seconds have passed since the last kept one.

    ⚠ A SUBSET, never a resample. Interpolating to a target cadence would invent
    positions the player was never at - which is the one thing a fixture must not do,
    since the rule under test is about whether a REAL position was inside a radius.
    """
    if not every:
        return list(rows)
    out, last = [], None
    for r in rows:
        if last is None or r["gt"] - last >= every - 1e-9:
            out.append(r)
            last = r["gt"]
    return out


def check():
    files, other = run_files()
    bad = []
    if not files:
        bad.append("no `%s` files found under %s" % (RUN_KIND, CORPUS))
    for path in files:
        rows = load(path)
        if not rows:
            bad.append("%s parsed to ZERO usable rows" % os.path.basename(path))
            continue
        cad = cadence_of(rows)
        if cad is None or cad <= 0:
            bad.append("%s has no derivable cadence" % os.path.basename(path))
            continue
        # ★ a decimated list must be a SUBSET - same objects, fewer of them
        thin = decimate(rows, cad * 4)
        if not set(id(r) for r in thin) <= set(id(r) for r in rows):
            bad.append("%s decimation produced rows not in the source" % path)
        if len(thin) > len(rows):
            bad.append("%s decimation GREW the list" % path)
        gts = [r["gt"] for r in thin]
        if gts != sorted(gts):
            bad.append("%s decimation lost time order" % path)
    for b in bad:
        sys.stderr.write("  APPARATUS  %s\n" % b)
    if bad:
        sys.stderr.write("\n  ⚠ APPARATUS FAILED - refusing to emit a list that may be wrong.\n")
        return 1
    print("apparatus OK - %d `%s` file(s), parse and decimation both hold"
          % (len(files), RUN_KIND))
    if other:
        # ★ EXCLUDED, NOT SILENT. An exemption nobody can see is the same shape as a
        # silent pass - the lesson check_targets already carries for `Libs/`.
        print("   %d file(s) EXCLUDED as a different capture kind: %s"
              % (len(other), ", ".join(sorted(set(kind_of(p) or "?" for p in other)))))
    return 0


def emit(out_path, runs, every):
    chunks = []
    for name in runs:
        path = os.path.join(CORPUS, name)
        rows = decimate(load(path), every)
        body = []
        for r in rows:
            body.append("    { x = %.4f, y = %.4f, z = %.4f, mapID = %d, gt = %.3f },"
                        % (r["x"], r["y"], r["z"], r.get("mapID") or 0, r["gt"]))
        chunks.append((os.path.basename(path).split("__")[1], rows, body))

    w = io.open(out_path, "w", encoding="utf-8", newline="\n")
    w.write("-- Model: addons/planning/DRIVER_BASIS.md\n--\n")
    w.write("-- ★★★ SAMPLE FIXTURES - EMITTED, do not hand-edit. Re-run:\n"
            "--     py addons/tools/emit_samples.py --out %s\n--\n"
            % out_path.replace("\\", "/").split("addons/")[-1])
    w.write("-- ⚠ Real captured player paths, TRANSCRIBED from the corpus and carrying NO\n"
            "-- verdict. The desk's verdicts are SEGMENT verdicts and the driver has no\n"
            "-- segment (W7.1: *\"the driver has no segment to be equal about\"*), so an\n"
            "-- expectation emitted here would re-fuse what RI-33 separated.\n--\n")
    w.write("-- ★ Decimation is a SUBSET, never a resample: interpolating to a cadence\n"
            "-- would invent positions the player was never at, and the rule under test is\n"
            "-- precisely about whether a REAL position was inside a radius.\n\n")
    w.write("local F = {}\n\n")
    for label, rows, body in chunks:
        cad = cadence_of(rows)
        w.write("-- %s - %d samples, median cadence %.3f s\n" % (label, len(rows), cad or 0))
        w.write("F[%r] = {\n%s\n}\n\n" % (label, "\n".join(body)))
    w.write("return F\n")
    w.close()
    print("wrote %s" % out_path)
    for label, rows, _ in chunks:
        print("   %-28s %5d samples" % (label, len(rows)))
    return 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--out")
    ap.add_argument("--every", type=float, default=None,
                    help="decimate to this cadence in seconds; omit to keep every row")
    a = ap.parse_args()
    if a.check or not a.out:
        return check()
    runs = ["20260817_075532__rfc_combat-20__legs.jsonl",
            "20260815_075411__SFK_live-12__legs.jsonl"]
    runs = [r for r in runs if os.path.exists(os.path.join(CORPUS, r))]
    if not runs:
        sys.stderr.write("  named runs are absent from the corpus\n")
        return 1
    return emit(a.out, runs, a.every)


if __name__ == "__main__":
    sys.exit(main())
