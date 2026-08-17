"""emit_chain_route.py - a landed run's beacons -> a Lua route the client can walk.

★★★ WHY THIS EXISTS RATHER THAN TYPED COORDINATES. W6 needs the client to walk a real
sequence with clears and sets, and the sequence has to come from data we already hold:
Battlewrath, 2026-08-17 - *"we have the data. Pick a dungeon. Pick a run. Load a sequence
of the X,Y,Z. Walk through them with clears and sets."*

⚠ An addon cannot read files, so the route has to arrive as Lua. That makes this a
build-once gear rather than a transcription job - the alternative is me copying twelve
floats by hand into a source file, which is the exact shape that put a stale point count
into three documents.

★ SEED-ONCE HOLDS BY CONSTRUCTION. Every beacon here IS a landed sample - a position the
player provably occupied - so nothing is invented. `kind` is carried through so the route
says what it was built from, and a route of `pin` markers is an AUTHORED one where a route
of `end` markers is a capture artefact. Neither carries a combat meaning here; they are
positions in visit order (acceptance W5, as corrected by H15).

    py addons/tools/emit_chain_route.py rfc_combat            the six authored pins
    py addons/tools/emit_chain_route.py rfc_combat --kind end  combat-end positions
    py addons/tools/emit_chain_route.py SFK_live  --kind all   everything, in time order
"""
import argparse
import glob
import io
import json
import os
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

HERE = os.path.dirname(os.path.abspath(__file__)).replace("\\", "/")
ROOT = os.path.dirname(os.path.dirname(HERE))
CORPUS = ROOT + "/addons/landing/corpus"
OUT = ROOT + "/addons/COA_DevDump/route_chain.lua"


def load_markers(fragment):
    hits = [p for p in sorted(glob.glob(CORPUS + "/*__markers.jsonl"))
            if fragment.lower() in os.path.basename(p).lower()]
    if not hits:
        return None, None, []
    path = hits[-1]
    head, rows = None, []
    with io.open(path, encoding="utf-8") as fh:
        for i, line in enumerate(fh):
            line = line.strip()
            if not line:
                continue
            o = json.loads(line)
            if i == 0 and o.get("_kind"):
                head = o
            else:
                rows.append(o)
    return head, path, rows


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("fragment", help="corpus fixture name fragment, e.g. rfc_combat")
    ap.add_argument("--kind", default="pin",
                    help="marker kind to use as beacons: pin (default) / start / end / all")
    ap.add_argument("--out", default=OUT)
    a = ap.parse_args()

    head, path, rows = load_markers(a.fragment)
    if head is None:
        print("no markers file matching %r in %s" % (a.fragment, CORPUS))
        return 2

    picked = [m for m in rows
              if (a.kind == "all" or m.get("kind") == a.kind)
              and m.get("x") is not None]
    picked.sort(key=lambda m: m.get("t") or 0)

    if not picked:
        # ⚠ NAMED, not silent. An empty route would install cleanly and do nothing.
        kinds = sorted({m.get("kind") for m in rows})
        print("no %r markers in %s - it has: %s"
              % (a.kind, os.path.basename(path), ", ".join(str(k) for k in kinds)))
        return 1

    maps = {m.get("mapID") for m in picked}
    if len(maps) > 1:
        # ⚠ A route spanning two maps is not walkable - the coordinates are in
        # different spaces. Refuse rather than emit something that looks fine.
        print("REFUSED: beacons span %d mapIDs %s - different coordinate spaces"
              % (len(maps), sorted(maps)))
        return 1

    prov = head.get("_provenance") or {}
    lines = [
        "-- route_chain.lua - GENERATED, DO NOT EDIT BY HAND.",
        "--",
        "-- ★ Emitted by addons/tools/emit_chain_route.py from a landed capture. Every",
        "-- beacon below IS a sample the player provably occupied, so the seed-once law",
        "-- holds by construction and nothing here is invented.",
        "--",
        "--   source   %s" % os.path.basename(path),
        "--   run      %s   zone %s" % (head.get("run"), head.get("zone")),
        "--   kind     %s   (%d beacons, ordered by marker time)" % (a.kind, len(picked)),
        "--   sha      %s" % (prov.get("sha256") or "?")[:16],
        "--",
        "-- ⚠ Re-emit rather than edit. A hand-touched route stops being traceable to the",
        "-- capture it came from, which is the whole reason it is generated.",
        "",
        "local ADDON, D = ...",
        "",
        "D.routeChain = {",
        "    source = %s," % json_str(os.path.basename(path)),
        "    run = %s," % json_str(head.get("run")),
        "    zone = %s," % json_str(head.get("zone")),
        "    kind = %s," % json_str(a.kind),
        "    mapID = %s," % list(maps)[0],
        "    sha = %s," % json_str((prov.get("sha256") or "")[:16]),
        "    beacons = {",
    ]
    for i, m in enumerate(picked, 1):
        lines.append("        { x = %.4f, y = %.4f, z = %.4f, mapID = %s, kind = %s, n = %d },"
                     % (m["x"], m["y"], m["z"], m.get("mapID"),
                        json_str(m.get("kind")), i))
    lines += ["    },", "}", ""]

    io.open(a.out, "w", encoding="utf-8", newline="\n").write("\n".join(lines))
    print("   %s  ->  %d beacons, mapID %s, kind %s"
          % (head.get("run"), len(picked), list(maps)[0], a.kind))
    print("   %s" % a.out)
    print("   provenance %s  sha %s"
          % (os.path.basename(path), (prov.get("sha256") or "?")[:12]))
    print()
    print("   ⚠ add route_chain.lua to COA_DevDump.toc BEFORE task_chain.lua, and")
    print("     restart the client - a .toc change is not a /reload.")
    return 0


def json_str(v):
    return json.dumps(v if v is not None else "")


if __name__ == "__main__":
    sys.exit(main())
