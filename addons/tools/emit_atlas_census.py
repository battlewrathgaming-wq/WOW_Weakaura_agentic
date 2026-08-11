"""emit_atlas_census.py - classify the client's named UI art by CLAIM OF USE.

The fact basis for any addon that needs an icon. Answers, mechanically:
  * what named atlas art exists (name -> texture, size, tex-coords)
  * which entries the CLIENT'S OWN CODE already uses, and where
  * which are UNCLAIMED, and therefore free for us to give a meaning to

WHY (the law it serves): icons carry language. Reusing art that already means
something in this client both mis-states our signal and corrupts theirs - a
player seeing crossed swords could no longer tell a hardcore death from a route
pull-point. The bar is not "no client art", it is "no art that already OWNS a
meaning here". This tool draws that line from evidence instead of guesswork.
See addons/planning/satnav_ledger.md law 10 + F17-F19.

Emitted once, read by every project. The alternative is each arc re-deriving the
same answer by eye, differently.

INPUT  : the extracted client UI tree (Outputs/client_interface/<archive>/)
         - run addons/tools/extract_interface.py first
OUTPUT : addons/maps/atlas/  (atlas.census.json + atlas.routes.md + free.md)

Usage:
    py addons\\tools\\emit_atlas_census.py
    py addons\\tools\\emit_atlas_census.py --search waypoint
    py addons\\tools\\emit_atlas_census.py --search flag --free-only
"""
import argparse
import json
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
UI = ROOT / "Outputs" / "client_interface" / "patch-B" / "Interface"
OUT = ROOT / "addons" / "maps" / "atlas"

REGISTRY = "SharedXML/AtlasInfo.lua"
# AtlasInfo entry: ["name"] = { "texture", w, h, l, r, t, b, flipH, flipV }
# NOTE w/h are NOT always integers - CoA's own custom atlases (CoAResource/*)
# use fractional sizes like 179.2, 69.3. An integer-only pattern silently drops
# them, i.e. drops exactly the fork's bespoke art. Learned the hard way.
# Atlas NAMES are not restricted to word characters - 96 of them begin with "!"
# (a sort prefix: "!Char-Inner-Left"). Enumerating allowed characters silently
# dropped those too. Accept anything that is not a quote, so ENTRY and CANDIDATE
# agree on what a name is BY CONSTRUCTION and the guard can only fire on a real
# format change.
NAME = r'[^\'"]+'
# Sizes are not always literals either: CoA's own atlases use Lua ARITHMETIC
# ("85*0.24", "(151+151)/512"). Capture the raw token up to the next comma and
# evaluate it. Third format variant found, and all three were the fork's custom
# art - Blizzard's entries are plain integers, CoA's are not.
ENTRY = re.compile(
    r'\[\s*[\'"](' + NAME + r')[\'"]\s*\]\s*=\s*\{\s*'
    r'[\'"]([^\'"]+)[\'"]\s*,\s*([^,]+?)\s*,\s*([^,]+?)\s*,',
    re.M,
)
SAFE_ARITH = re.compile(r'^[\d\s.*/+()\-]+$')
# Every line that LOOKS like an entry, for the completeness self-check below.
# Compared as a SET of names, not a line count: the registry genuinely repeats 18
# keys (Lua last-wins, so the earlier definition is dead art). Counting lines made
# the guard cry drift over duplicates it should merely report.
CANDIDATE = re.compile(r'^\s*\[\s*[\'"](' + NAME + r')[\'"]\s*\]\s*=\s*\{', re.M)


def _num(s):
    """Literal or simple Lua arithmetic -> number. Whitelisted characters only,
    so nothing but digits and operators ever reaches eval."""
    s = s.strip()
    if not SAFE_ARITH.match(s):
        raise ValueError(f"unrecognised size token {s!r}")
    f = float(eval(s, {"__builtins__": {}}, {}))  # noqa: S307 - whitelisted above
    return int(f) if f.is_integer() else round(f, 2)


def load_registry(path: Path):
    """Parse the registry, and REFUSE to return a silently-partial result."""
    src = path.read_text(encoding="utf-8", errors="replace")
    out = {}
    for m in ENTRY.finditer(src):
        try:
            w, h = _num(m.group(3)), _num(m.group(4))
        except ValueError:
            continue  # unparseable size -> drop, and let the guard below shout
        out[m.group(1)] = {
            "texture": m.group(2).replace("\\\\", "\\"),
            "w": w,
            "h": h,
        }
    # completeness guard: every entry-shaped NAME must have parsed.
    # A shortfall means the entry format has drifted and we are dropping art.
    found = CANDIDATE.findall(src)
    missed = sorted(set(found) - set(out))
    if missed:
        raise SystemExit(
            f"PARSE INCOMPLETE: {len(set(found))} entry-shaped names but {len(missed)} "
            f"did not parse. The AtlasInfo format has drifted - fix ENTRY before trusting "
            f"any output. First few: {', '.join(missed[:5])}\n"
            f"(This guard exists because an integer-only size pattern once silently dropped "
            f"105 CoAResource atlases.)")
    dupes = len(found) - len(set(found))
    return out, dupes


def source_files(ui: Path, exclude: str):
    for p in sorted(ui.rglob("*")):
        if p.suffix.lower() in (".lua", ".xml") and exclude not in p.as_posix():
            yield p


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--search", help="only report names containing this substring")
    ap.add_argument("--free-only", action="store_true", help="only report unclaimed entries")
    ap.add_argument("--ui", default=str(UI), help="extracted Interface/ root")
    a = ap.parse_args()

    ui = Path(a.ui)
    reg_path = ui / REGISTRY
    if not reg_path.exists():
        sys.exit(f"no atlas registry at {reg_path} - run extract_interface.py first")

    atlases, dupes = load_registry(reg_path)
    if not atlases:
        sys.exit("registry parsed to ZERO entries - the AtlasInfo format has changed, "
                 "RECALIBRATE before trusting any output")
    print(f"registry: {len(atlases)} named atlas entries")
    if dupes:
        print(f"note: {dupes} duplicate key definitions in the registry - Lua takes the "
              f"LAST, so those earlier definitions are dead art")

    # Build one blob per file so a claim can be attributed to its claimant.
    files = list(source_files(ui, REGISTRY))
    print(f"scanning {len(files)} client source files for claims...")
    blobs = []
    for p in files:
        try:
            blobs.append((p.relative_to(ui).as_posix(),
                          p.read_text(encoding="utf-8", errors="replace")))
        except OSError:
            continue

    claims = defaultdict(list)
    for rel, text in blobs:
        for name in atlases:
            if name in text:
                claims[name].append(rel)

    for name, data in atlases.items():
        data["claimedBy"] = sorted(set(claims.get(name, [])))
        data["claimed"] = bool(data["claimedBy"])

    free = [n for n, d in atlases.items() if not d["claimed"]]
    print(f"claimed: {len(atlases) - len(free)}   FREE: {len(free)}")

    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "atlas.census.json").write_text(
        json.dumps({"source": REGISTRY, "total": len(atlases),
                    "free": len(free), "atlases": atlases}, indent=1),
        encoding="utf-8")

    # grouped by texture sheet - the useful browse order when hunting a look
    by_sheet = defaultdict(list)
    for n, d in atlases.items():
        by_sheet[d["texture"]].append(n)
    lines = ["# Atlas census - named UI art classified by CLAIM OF USE", "",
             f"_{len(atlases)} entries from `{REGISTRY}`, cross-referenced against "
             f"{len(files)} client source files. **CLAIMED** = the client's own code already "
             "uses it, so it owns a meaning here and must not be reused. **free** = unclaimed; "
             "safe to give a meaning to. Emitted by `addons/tools/emit_atlas_census.py`._", ""]
    for sheet in sorted(by_sheet):
        lines.append(f"## {sheet}")
        for n in sorted(by_sheet[sheet]):
            d = atlases[n]
            if d["claimed"]:
                lines.append(f"- `{n}` {d['w']}x{d['h']} — **CLAIMED** by "
                             + ", ".join(d["claimedBy"][:3])
                             + (" …" if len(d["claimedBy"]) > 3 else ""))
            else:
                lines.append(f"- `{n}` {d['w']}x{d['h']} — free")
        lines.append("")
    (OUT / "atlas.routes.md").write_text("\n".join(lines), encoding="utf-8")

    (OUT / "free.md").write_text(
        "# Unclaimed atlas art (safe to give a meaning to)\n\n"
        f"_{len(free)} of {len(atlases)} entries are referenced nowhere in the client's own "
        "source. Emitted by `addons/tools/emit_atlas_census.py`._\n\n"
        + "\n".join(f"- `{n}` {atlases[n]['w']}x{atlases[n]['h']} — {atlases[n]['texture']}"
                    for n in sorted(free)),
        encoding="utf-8")

    print(f"wrote {OUT}")

    if a.search:
        q = a.search.lower()
        print(f"\n=== matches for '{a.search}' ===")
        for n in sorted(atlases):
            if q not in n.lower():
                continue
            d = atlases[n]
            if a.free_only and d["claimed"]:
                continue
            status = ("CLAIMED by " + ", ".join(d["claimedBy"][:2])) if d["claimed"] else "free"
            print(f"  {n:<52} {d['w']:>3}x{d['h']:<3} {status}")


if __name__ == "__main__":
    main()
