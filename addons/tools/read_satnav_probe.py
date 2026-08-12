"""read_satnav_probe.py - read a landed task_satnav record and answer its questions.

The probe emits; this decides. Every verdict below is arithmetic over captured
ground truth (player position vs pin) compared against what the engine reported
(`sd`) - no inference, no thresholds of taste.

  A) is `distance` 3D or 2D      -> fit sd against 2D and 3D separation
  B) does distance survive off-screen -> count screen-invalid rows that kept sd
  C) what happens across maps / at range -> mapIDs, states, and the distance
                                            at which the engine changes its mind

Also reports, because the first run surfaced them and they are worth watching:
the engine's own InRadius boundary, whether the client held our position for the
whole run (`gp`/`tr`), and the observed screen-coordinate range.

Usage:
    py addons\\tools\\read_satnav_probe.py                      # newest satnav record
    py addons\\tools\\read_satnav_probe.py <path-to-record.json>
"""
import glob
import json
import math
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RECORDS = ROOT / "addons" / "landing" / "records"

STATE = {0: "Invalid", 1: "Occluded", 2: "InRange", 3: "Disabled", 4: "InRadius"}


def newest():
    hits = sorted(glob.glob(str(RECORDS / "*__satnav.json")))
    if not hits:
        sys.exit(f"no satnav records in {RECORDS}")
    return Path(hits[-1])


def main():
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else newest()
    d = json.loads(path.read_text(encoding="utf-8"))
    h, p = d["header"], d["payload"]
    if p.get("abort"):
        sys.exit(f"record aborted: {p['abort']}")

    pin = p["pin"]
    rows = [r for r in p["rows"] if r.get("sd") is not None and r.get("px") is not None]
    print(f"=== {path.name} ===")
    print(f"{h['startedAt']} -> {h['completedAt']}  ·  {h['char']} @ {pin.get('zone')}")
    print(f"pin mapID {pin['mapID']}  ·  {p['samples']} samples"
          + ("  ·  ** CAPPED **" if p.get("capped") else ""))
    if p.get("tick_errors"):
        print(f"!! tick_errors: {p['tick_errors']} - rows may be incomplete")
    if "FALLBACK" in (p.get("setterUsed") or ""):
        print(f"!! {p['setterUsed']} - run is SUSPECT (F24)")
    usable = len(rows)
    if usable != p["samples"]:
        print(f"note: {p['samples'] - usable} row(s) lacked sd or position and are excluded")
    if not rows:
        sys.exit("no usable rows")

    # -- A: 3D or 2D -------------------------------------------------------
    e2 = e3 = w2 = w3 = 0.0
    for r in rows:
        dx, dy, dz = r["px"] - pin["x"], r["py"] - pin["y"], r["pz"] - pin["z"]
        a2 = abs(r["sd"] - math.hypot(dx, dy))
        a3 = abs(r["sd"] - math.sqrt(dx * dx + dy * dy + dz * dz))
        e2 += a2; e3 += a3
        w2 = max(w2, a2); w3 = max(w3, a3)
    n = len(rows)
    verdict = "3D" if e3 < e2 else "2D"
    print(f"\n(A) IS `distance` 3D OR 2D  ->  **{verdict}**")
    print(f"    vs 2D (x,y)    mean err {e2/n:.6f}   worst {w2:.6f}")
    print(f"    vs 3D (x,y,z)  mean err {e3/n:.6f}   worst {w3:.6f}")
    print(f"    law 14's 5yd `Interact with` tier is "
          + ("SAFE - vertical separation is counted." if verdict == "3D"
             else "UNSAFE as specified - a floor above reads as arrived."))

    # -- B: off-screen survival -------------------------------------------
    inval = [r for r in p["rows"] if r.get("vs") is False]
    kept = sum(1 for r in inval if r.get("sd") is not None)
    nil_d = sum(1 for r in p["rows"] if r.get("sd") is None)
    print(f"\n(B) DOES DISTANCE SURVIVE OFF-SCREEN  ->  "
          + ("**YES**" if inval and kept == len(inval) else
             "**NO**" if inval else "NOT EXERCISED (no screen-invalid samples)"))
    print(f"    screen-invalid rows {len(inval)}   of which kept a distance {kept}")
    print(f"    rows with no distance at all: {nil_d}")
    if inval and kept == len(inval):
        print("    arrival polling (law 14) is safe regardless of camera facing.")

    # -- C: maps, states, range -------------------------------------------
    maps = {}
    for r in p["rows"]:
        maps[r.get("pm")] = maps.get(r.get("pm"), 0) + 1
    print(f"\n(C) MAPS AND RANGE")
    print(f"    mapIDs seen: " + ", ".join(f"{k} ({v} samples)" for k, v in sorted(
        maps.items(), key=lambda kv: (kv[0] is None, kv[0]))))
    if len(maps) == 1:
        print("    only one mapID - no map boundary was crossed in this run.")

    byst = {}
    for r in rows:
        byst.setdefault(r.get("ts"), []).append(r)
    print("    engine state vs actual distance:")
    for s in sorted(byst, key=lambda x: (x is None, x)):
        sd = [r["sd"] for r in byst[s]]
        print(f"      {STATE.get(s, '?'):<9} ({s})  n={len(sd):<5} sd {min(sd):8.2f} .. {max(sd):8.2f}")
    if 4 in byst and 2 in byst:
        print(f"    -> engine InRadius/InRange boundary between "
              f"{max(r['sd'] for r in byst[4]):.2f} and {min(r['sd'] for r in byst[2]):.2f} yd")

    # -- held-intent + screen coords --------------------------------------
    gp = sorted({r.get("gp") for r in p["rows"]}, key=lambda x: (x is None, x))
    tr = sorted({str(r.get("tr")) for r in p["rows"]})
    print(f"\n    client held our position (gp): {gp}   [1=ours 0=other -1=gone]")
    print(f"    still tracking (tr): {tr}")
    sx = [r["sx"] for r in rows if r.get("sx") is not None]
    sy = [r["sy"] for r in rows if r.get("sy") is not None]
    if sx:
        print(f"    screen coords: sx {min(sx):.3f}..{max(sx):.3f}  sy {min(sy):.3f}..{max(sy):.3f}"
              "   (fractions; outside 0..1 = off screen)")
    print(f"    max distance reached: {max(r['sd'] for r in rows):.2f} yd")


if __name__ == "__main__":
    main()
