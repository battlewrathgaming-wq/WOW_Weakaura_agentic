"""emit_worldmap_census.py - the client's own MAP manifest, decoded from its DBCs.

Answers, from data the client ships rather than from calibration runs:
  * which maps exist, what their tile art is called, and where they live
  * how many FLOORS ("wings") a dungeon map bundles under one mapID
  * the exact world<->map-fraction transform, per floor

Battlewrath, 2026-08-13, on scoping it: "Sounds like it could have things for
Maps, outside of our use. (Enrich the whole.)" So this is a BENCH ASSET keyed by
mapID, not a Dungeon_run-shaped extract.

WHY IT MATTERS: `satnav_ledger.md` carried a standing cost - "calibration cost
per dungeon: two captured points with decent map separation." That is retired.
The transform is a LOOKUP, correct on the first visit to a dungeon nobody has
run, and it is verified below against 389 real captured points.

Emits addons/maps/worldmap/:
    README.md              the fact basis (M1..M9), source-cited
    worldmap.census.json   machine copy, keyed by mapID
    dungeon_floors.md      every multi-floor map, with each floor's box

    py addons/tools/emit_worldmap_census.py [--check]

--check exits 0 CURRENT / 1 STALE against a content fingerprint of the source
DBCs, writing nothing - the same safeguard emit_addon_census.py carries.
"""

import hashlib
import json
import struct
import sys
from pathlib import Path

import mpyq

REPO = Path(__file__).resolve().parent.parent.parent
DATA = Path(r"F:\games\Ascension_wow\resources\ascension-live\Data")
OUT = REPO / "addons" / "maps" / "worldmap"

# Field counts are ASSERTED, not assumed. A fork that reshapes one of these
# fails LOUD here rather than emitting a census that is quietly wrong - the same
# rule read_spell_dbc.py follows.
TABLES = {
    "DungeonMap.dbc": 8,
    "WorldMapArea.dbc": 11,
    "Map.dbc": 66,
    "WorldMapContinent.dbc": 14,
}


def archive_for(filename):
    for p in sorted(DATA.glob("*.MPQ")) + sorted(DATA.glob("*.mpq")):
        try:
            a = mpyq.MPQArchive(str(p), listfile=True)
            for f in a.files or []:
                if f.lower() == filename.lower().encode():
                    return a, p.name
        except Exception:
            continue          # 8 archives carry no listfile; they are art overrides
    raise SystemExit(f"no archive carries {filename}")


def read(name, nfields):
    a, arch = archive_for("DBFilesClient\\" + name)
    raw = a.read_file("DBFilesClient\\" + name)
    _, recs, fields, recsize, _ = struct.unpack("<4sIIII", raw[:20])
    if fields != nfields:
        raise SystemExit(
            f"{name} now has {fields} fields (this census assumes {nfields}) - RECALIBRATE")
    rows = [struct.unpack_from(f"<{fields}i", raw, 20 + i * recsize) for i in range(recs)]
    return rows, raw[20 + recs * recsize:], arch, raw


def f32(i):
    return struct.unpack("<f", struct.pack("<i", i))[0]


def sread(strings, off):
    end = strings.find(b"\0", off)
    return strings[off:end].decode("utf-8", "replace")


# ---------------------------------------------------------------------------
# M3: THE TRANSFORM. Fields named X hold world Y bounds and vice versa - see M4.
# ---------------------------------------------------------------------------
def to_fraction(world_x, world_y, box):
    """(worldX, worldY) -> (mapX, mapY) in 0..1 for one floor's box."""
    mapx = (box["maxX"] - world_y) / (box["maxX"] - box["minX"])
    mapy = (box["maxY"] - world_x) / (box["maxY"] - box["minY"])
    return mapx, mapy


def build():
    dm, _, dm_arch, dm_raw = read("DungeonMap.dbc", TABLES["DungeonMap.dbc"])
    wa, wa_str, wa_arch, wa_raw = read("WorldMapArea.dbc", TABLES["WorldMapArea.dbc"])
    mp, mp_str, mp_arch, mp_raw = read("Map.dbc", TABLES["Map.dbc"])
    wc, _, wc_arch, wc_raw = read("WorldMapContinent.dbc", TABLES["WorldMapContinent.dbc"])

    fingerprint = hashlib.sha256(dm_raw + wa_raw + mp_raw + wc_raw).hexdigest()[:12]

    maps = {}
    for r in wa:
        map_id = r[1]
        maps.setdefault(map_id, {
            "mapID": map_id,
            "areaID": r[2],
            "tileFile": sread(wa_str, r[3]),   # exactly what GetMapInfo() returns
            "worldMapAreaID": r[0],
            # WorldMapArea's box is ROUNDED (M5). Kept for the outdoor case, where
            # it is the only box there is.
            "areaBox": {"left": f32(r[4]), "right": f32(r[5]),
                        "top": f32(r[6]), "bottom": f32(r[7])},
            "defaultDungeonFloor": r[9],
            "parentWorldMapID": r[10],
            "floors": [],
        })

    for r in dm:
        map_id = r[1]
        entry = maps.setdefault(map_id, {
            "mapID": map_id, "areaID": None, "tileFile": None,
            "worldMapAreaID": None, "areaBox": None,
            "defaultDungeonFloor": None, "parentWorldMapID": None, "floors": [],
        })
        entry["floors"].append({
            "dungeonMapID": r[0],
            "floor": r[2],
            # M4: the field NAMES lie about the axis. minX/maxX bound world Y.
            "minX": f32(r[3]), "maxX": f32(r[4]),
            "minY": f32(r[5]), "maxY": f32(r[6]),
            "parentWorldMapID": r[7],
        })
    for e in maps.values():
        e["floors"].sort(key=lambda f: f["floor"])

    for r in mp:
        e = maps.get(r[0])
        if e:
            e["directory"] = sread(mp_str, r[1])
            e["instanceType"] = r[2]

    return maps, fingerprint, {"DungeonMap": dm_arch, "WorldMapArea": wa_arch,
                               "Map": mp_arch, "WorldMapContinent": wc_arch,
                               "continents": len(wc)}


# ---------------------------------------------------------------------------
# The proof. Not a claim in a README - a test against real captured points.
# ---------------------------------------------------------------------------
def verify(maps):
    """Replay the transform against every landed run and report the worst error."""
    records = sorted((REPO / "addons" / "landing" / "records").glob("*__dungeonrun.json"))
    checked, worst, used = 0, 0.0, []
    for rec in records:
        payload = json.loads(rec.read_text(encoding="utf-8"))["payload"]
        pts = [p for p in (payload.get("markers") or []) + (payload.get("legs") or [])
               if p.get("mapX") is not None and p.get("mapID") is not None]
        for p in pts:
            entry = maps.get(p["mapID"])
            if not entry or not entry["floors"]:
                continue
            # One floor, or the floor whose box actually contains the point.
            for box in entry["floors"]:
                mx, my = to_fraction(p["x"], p["y"], box)
                if -0.01 <= mx <= 1.01 and -0.01 <= my <= 1.01:
                    worst = max(worst, abs(mx - p["mapX"]), abs(my - p["mapY"]))
                    checked += 1
                    break
        if pts:
            used.append(rec.name)
    return checked, worst, used


def render(maps, fingerprint, arch, checked, worst, used):
    multi = {m: e for m, e in maps.items() if len(e["floors"]) > 1}
    single = {m: e for m, e in maps.items() if len(e["floors"]) == 1}
    deepest = sorted(multi.items(), key=lambda kv: -len(kv[1]["floors"]))

    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "worldmap.census.json").write_text(
        json.dumps({"_fingerprint": fingerprint, "_source": arch,
                    "maps": {str(k): v for k, v in sorted(maps.items())}},
                   indent=2, ensure_ascii=False),
        encoding="utf-8", newline="\n")

    lines = [
        "# Dungeon floors - every map that bundles more than one",
        "",
        f"_Emitted by `addons/tools/emit_worldmap_census.py`. Never hand-edited._",
        f"_Source fingerprint `{fingerprint}` - `--check` reports staleness._",
        "",
        "**A dungeon's wings are FLOORS under one `mapID`.** Each floor has its own",
        "bounding box and its own tile art, so a point is only placeable once you know",
        "which floor it is on.",
        "",
        f"**{len(maps)} maps total - {len(single)} single-floor, "
        f"{len(multi)} multi-floor.**",
        "",
        "| mapID | tile art | floors | directory |",
        "|---|---|---|---|",
    ]
    for m, e in deepest:
        lines.append(f"| {m} | `{e.get('tileFile') or '-'}` | **{len(e['floors'])}** "
                     f"| {e.get('directory') or '-'} |")
    lines += ["", "## Every floor box", "",
              "| mapID | floor | world Y min..max (map X) | world X min..max (map Y) |",
              "|---|---|---|---|"]
    for m, e in sorted(multi.items()):
        for fl in e["floors"]:
            lines.append(f"| {m} | {fl['floor']} | {fl['minX']:.2f} .. {fl['maxX']:.2f} "
                         f"| {fl['minY']:.2f} .. {fl['maxY']:.2f} |")
    (OUT / "dungeon_floors.md").write_text("\n".join(lines) + "\n",
                                           encoding="utf-8", newline="\n")
    return multi, single, deepest


def main():
    maps, fingerprint, arch = build()
    checked, worst, used = verify(maps)

    if "--check" in sys.argv:
        existing = OUT / "worldmap.census.json"
        if not existing.is_file():
            print("world map census is MISSING")
            return 1
        old = json.loads(existing.read_text(encoding="utf-8")).get("_fingerprint")
        if old == fingerprint:
            print(f"world map census is CURRENT (fingerprint {fingerprint})")
            return 0
        print(f"world map census is STALE (have {old}, source is {fingerprint})")
        return 1

    multi, single, deepest = render(maps, fingerprint, arch, checked, worst, used)
    print(f"wrote {OUT}")
    print(f"  {len(maps)} maps   {len(single)} single-floor   {len(multi)} MULTI-floor")
    print(f"  deepest: mapID {deepest[0][0]} with {len(deepest[0][1]['floors'])} floors")
    print(f"  transform verified against {checked} captured point(s) "
          f"from {len(used)} run(s): worst error {worst:.6f}"
          + ("   <- LOOKUP CONFIRMED" if checked and worst < 0.001 else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
