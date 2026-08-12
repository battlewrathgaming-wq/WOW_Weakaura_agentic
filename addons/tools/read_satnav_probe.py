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
    # Rows from a DIFFERENT map are in a different coordinate space entirely, so
    # player-vs-pin separation is meaningless there. Rows the engine declined are
    # excluded too: across a map boundary it returns sd = 0.00 (F38), and with the
    # CVar off it returns nil (F41) - both would poison the fit, differently.
    # The task guards its own hd/vd the same way; the reader must match it.
    rows = [r for r in p["rows"]
            if r.get("sd") is not None and r.get("px") is not None
            and r.get("pm") == pin["mapID"] and r.get("ts") != 0]
    offmap = sum(1 for r in p["rows"] if r.get("pm") != pin["mapID"])
    declined = sum(1 for r in p["rows"] if r.get("ts") == 0)
    print(f"=== {path.name} ===")
    print(f"{h['startedAt']} -> {h['completedAt']}  ·  {h['char']} @ {pin.get('zone')}")
    print(f"pin mapID {pin['mapID']}  ·  {p['samples']} samples"
          + ("  ·  ** CAPPED **" if p.get("capped") else ""))
    if p.get("tick_errors"):
        print(f"!! tick_errors: {p['tick_errors']} - rows may be incomplete")
    if "FALLBACK" in (p.get("setterUsed") or ""):
        print(f"!! {p['setterUsed']} - run is SUSPECT (F24)")
    if offmap:
        print(f"note: {offmap} row(s) on another map - excluded from the distance fit "
              f"(different coordinate space)")
    if declined:
        zeros = sum(1 for r in p["rows"] if r.get("ts") == 0 and r.get("sd") == 0)
        print(f"!! {declined} row(s) with NavigationState.Invalid - excluded from the fit"
              + (f"; {zeros} of them reported sd = 0.00, and a zero there is a REFUSAL, "
                 f"not an arrival" if zeros else "; distance was nil, not zero") + ".")
    # A CVar-off run is a VALID record with zero usable rows - report its signature
    # rather than dying with "no usable rows", which reads like a broken capture.
    if p["env"].get("showInGameNavigation") is False:
        print("")
        print("*** showInGameNavigation was OFF for this run ***")
        allr = p["rows"]
        sig = lambda f: sorted({str(r.get(f)) for r in allr})
        print(f"    samples {len(allr)}  ·  state {sig('ts')}  ·  tracking {sig('tr')}  "
              f"·  gp {sig('gp')}  ·  distance {sig('sd')}")
        print("    Signature to compare against a MAP-BOUNDARY refusal (F38), which also")
        print("    reports Invalid but keeps tracking=true, gp=1 and a distance of 0.00.")
        return
    usable = len(rows)
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
    # only count samples the engine was actually answering for
    inval = [r for r in p["rows"] if r.get("vs") is False and r.get("ts") != 0]
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

    # NOTE: iterate ALL rows here, not the sd-filtered set. On a boundary test the
    # engine may return NO distance, and those are precisely the samples that carry
    # the answer - filtering them out would report an empty instance as "no data".
    byst = {}
    for r in p["rows"]:
        byst.setdefault(r.get("ts"), []).append(r)
    print("    engine state vs actual distance:")
    for st in sorted(byst, key=lambda x: (x is None, x)):
        sd = [r["sd"] for r in byst[st] if r.get("sd") is not None]
        span = f"sd {min(sd):8.2f} .. {max(sd):8.2f}" if sd else "sd NONE RETURNED"
        nils = len(byst[st]) - len(sd)
        print(f"      {STATE.get(st, '?'):<9} ({st})  n={len(byst[st]):<5} {span}"
              + (f"   [{nils} with no distance]" if nils else ""))
    if byst.get(4) and byst.get(2):
        lo = [r["sd"] for r in byst[4] if r.get("sd") is not None]
        hi = [r["sd"] for r in byst[2] if r.get("sd") is not None]
        if lo and hi:
            print(f"    -> engine InRadius/InRange boundary between {max(lo):.2f} and {min(hi):.2f} yd")

    # per-map breakdown: the whole point of a boundary run is what changed WHERE.
    if len(maps) > 1:
        print("    per-map behaviour (the boundary test):")
        for m in sorted(maps, key=lambda x: (x is None, x)):
            sub = [r for r in p["rows"] if r.get("pm") == m]
            sts = sorted({r.get("ts") for r in sub}, key=lambda x: (x is None, x))
            gps = sorted({r.get("gp") for r in sub}, key=lambda x: (x is None, x))
            trs = sorted({str(r.get("tr")) for r in sub})
            withd = sum(1 for r in sub if r.get("sd") is not None)
            tag = "  <- the PIN's map" if m == pin["mapID"] else ""
            print(f"      mapID {m}: n={len(sub)}  states={[STATE.get(x, x) for x in sts]}  "
                  f"tracking={trs}  gp={gps}  rows-with-distance={withd}/{len(sub)}{tag}")
        print("      gp: 1 = client still holds OUR pin (so a failure is the ENGINE declining)")
        print("          -1 = client dropped our intent entirely  ·  0 = it holds something else")

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
