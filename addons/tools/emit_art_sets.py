# -*- coding: utf-8 -*-
r"""emit_art_sets.py - find the BORDER SETS: art authored as a nine-slice, by its NAME.

    py addons\tools\emit_art_sets.py                     every set, ranked by completeness
    py addons\tools\emit_art_sets.py --complete          only full nine-slices
    py addons\tools\emit_art_sets.py --free --warm       only unclaimed, warm sets
    py addons\tools\emit_art_sets.py --sheet store-goldborder    the command to look at one

★★★ WHY, and it is a correction of my own better idea. `emit_art_inventory.py` classifies every
entry by colour and by whether it may be stretched. Ranked by saturation x coverage it surfaces
BARS AND FILLS - saturated, full-coverage, and not frames at all - and the one genuinely complete
gold border on this client never appeared in the top thirty. The theme filter helps less than it
looks, because WoW's palette IS warm: 1411 of 3336 entries fall in the band.

★★ WHAT FOUND IT WAS THE NAME. Nine-slice art is AUTHORED as a set - one stem carrying
`-Top` / `-Bottom` / `-Left` / `-Right` and four corners. A stem holding those IS a border by
construction, and no pixel statistic says that as directly. ⟶ This is a name analysis, so it is
instant: no BLP is decoded unless you ask for the sheet.

⚠⚠ THE BUG THIS TOOL EXISTS TO NOT REPEAT. A first pass matched the LAST hyphen token as the
part, so `store-goldborder-bottom-left` parsed as stem `store-goldborder-bottom` + part `left`.
Every corner scattered into its own phantom stem, the real set looked like four edges with no
corners, and the answer - a complete nine-slice - was reported as incomplete. ★ So parts are
matched LONGEST FIRST, and the compound spellings come before the simple ones.

⚠ Naming varies and the variants are declared below rather than assumed: `topleft`, `top-left`,
`top_left`, `tl`. A set whose author used a spelling not in that list is INVISIBLE here, which
makes every count a FLOOR rather than a total. Said out loud on every run.

⚠ It reports SHAPE, never suitability. A complete set can still be ugly, wrong-coloured or
already meaningful elsewhere; the `claimed` and `warm` columns are there to inform that judgement,
which is Battlewrath's.
"""
import argparse
import json
import re
import sys
from collections import defaultdict
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

REPO = Path(__file__).resolve().parents[2]
ATLASINFO = (REPO / "Outputs" / "client_interface" / "patch-B" / "Interface"
             / "SharedXML" / "AtlasInfo.lua")
INVENTORY = REPO / "addons" / "staging" / "atlas" / "art_inventory.json"
CENSUS = REPO / "addons" / "maps" / "atlas" / "atlas.census.json"
OUT = REPO / "addons" / "staging" / "atlas"

_NAME = re.compile(r'\["([^"]+)"\]\s*=\s*\{\s*"([^"]+)"')

# ★★ LONGEST FIRST. The order of this list is load-bearing: a compound spelling must be tried
# before the simple one it contains, or `-bottom-left` is eaten as `-left`.
PARTS = [
    ("TL", r"(?:top[-_ ]?left|upper[-_ ]?left|tl)"),
    ("TR", r"(?:top[-_ ]?right|upper[-_ ]?right|tr)"),
    ("BL", r"(?:bottom[-_ ]?left|lower[-_ ]?left|bl)"),
    ("BR", r"(?:bottom[-_ ]?right|lower[-_ ]?right|br)"),
    ("T",  r"(?:top|upper)"),
    ("B",  r"(?:bottom|lower)"),
    ("L",  r"(?:left)"),
    ("R",  r"(?:right)"),
    ("MID", r"(?:middle|mid|centre|center|horiz(?:ontal)?|vert(?:ical)?)"),
    ("END", r"(?:endcap|cap|end)"),
]
_PART_RE = [(k, re.compile(r"^(?P<stem>.+?)[-_](?P<part>" + p + r")$", re.I)) for k, p in PARTS]

CORNERS, EDGES = {"TL", "TR", "BL", "BR"}, {"T", "B", "L", "R"}


def split_part(name):
    """Longest-first. Returns (stem, canonical part) or (None, None)."""
    for canon, rx in _PART_RE:
        m = rx.match(name)
        if m:
            return m.group("stem"), canon
    return None, None


def verdict(parts):
    have = set(parts)
    c, e = len(have & CORNERS), len(have & EDGES)
    if c == 4 and e == 4:
        return "9slice"
    if c >= 2 and e >= 2:
        return "9slice-part"
    if e == 4:
        return "edges-4"
    if {"L", "MID", "R"} <= have:
        return "3slice-h"
    if {"T", "MID", "B"} <= have:
        return "3slice-v"
    if c + e >= 3:
        return "partial"
    return None


# ★★★ SET COHERENCE - the guard that would have said it first.
#
# `store-goldborder` reported `9slice · 8 pieces · 7 warm` and composed into a gold frame with
# ONE red bar in it, because `store-goldborder-right`'s coords land on different art on this
# fork. The register and the atlas disagree for that entry, and nothing checked that they agree.
# ⟶ The evidence was already in the output and was read past: seven pieces at hue 23.7-41.9 and
# saturation 0.17-0.26, and one at hue 5.8, saturation 0.81.
#
# ★ A set is authored as ONE piece of art cut up. Its parts therefore agree about colour, and a
# part that does not agree is the cheapest possible signal that its entry points somewhere else.
# Two independent axes, because they fail independently: HUE (a different colour) and SATURATION
# (the same hue family, far more intense).
#
# ⚠⚠ THE LIMIT, AND IT IS STRUCTURAL: this finds the ODD ONE OUT. It compares each piece to the
# set's MEDIAN, so it assumes most of the set is right. A set where half the entries are wrong
# has a wrong median and reports nothing. ⟶ It answers "which piece disagrees with its
# siblings", never "is this set correct".
HUE_OUTLIER_DEG = 25.0     # store-goldborder-right sat 31.3 off; the next worst was 13.4
SAT_OUTLIER_RATIO = 2.5    # it ran 0.81 against a 0.20 median - a factor of four


def hue_gap(a, b):
    """Circular distance in degrees - 350 and 10 are 20 apart, not 340."""
    d = abs(a - b) % 360.0
    return min(d, 360.0 - d)


def coherence(parts, inv):
    """Pieces that disagree with their siblings about colour. [] when it cannot tell."""
    vals = []
    for part, name in parts.items():
        r = inv.get(name)
        if r and r.get("hue") is not None:
            vals.append((part, name, r["hue"], r.get("sat") or 0.0))
    if len(vals) < 4:
        return []          # ⚠ too few to have a median worth trusting - silent, not guessed
    hues = sorted(v[2] for v in vals)
    sats = sorted(v[3] for v in vals)
    mid_h, mid_s = hues[len(hues) // 2], sats[len(sats) // 2]
    out = []
    for part, name, h, s in vals:
        why = []
        gap = hue_gap(h, mid_h)
        if gap > HUE_OUTLIER_DEG:
            why.append(f"hue {h:.1f} is {gap:.0f} off the set median {mid_h:.1f}")
        if mid_s > 0.01 and s / mid_s > SAT_OUTLIER_RATIO:
            why.append(f"saturation {s:.2f} is {s / mid_s:.1f}x the median {mid_s:.2f}")
        if why:
            # ⚠⚠ THE SIZE RIDES WITH THE FLAG, because it is what makes it weighable.
            # Measured on the second run: `GeneralFrame-InsetFrame-TopLeft` fired at 8x8 - a
            # corner nub whose hue is averaged over a handful of pixels, on ONE axis, with no
            # saturation signal. `store-goldborder-right` fired at 21x32 on BOTH axes and was
            # confirmed by eye. Same word "flagged", very different confidence.
            # ★ Reported rather than suppressed: a threshold on size would silently hide a
            # small piece that really is wrong, and this check exists because a real signal
            # was read past once already.
            r = inv.get(name) or {}
            w, hgt = r.get("w"), r.get("h")
            axes = len(why)
            small = " - small art, noisy hue" if (w or 99) * (hgt or 99) < 400 else ""
            out.append((part, name,
                        f"{'; '.join(why)}   [{w}x{hgt}, "
                        f"{axes} {'axes' if axes > 1 else 'axis'}{small}]"))
    return out


def main():
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument("--complete", action="store_true", help="only full nine-slices")
    ap.add_argument("--free", action="store_true", help="only sets with no claimed piece")
    ap.add_argument("--warm", action="store_true", help="only sets where most pieces are warm")
    ap.add_argument("--sheet", help="print the emit_atlas_sheet command for this stem")
    args = ap.parse_args()

    if not ATLASINFO.is_file():
        print(f"emit_art_sets: no AtlasInfo at {ATLASINFO}")
        print("             py addons\\tools\\extract_interface.py patch-B.MPQ")
        sys.exit(2)
    names = [m.group(1) for m in _NAME.finditer(
        ATLASINFO.read_text(encoding="utf-8", errors="replace"))]

    # ★ Enrichment is OPTIONAL. The set analysis is pure naming, so it works with no sweep;
    # colour and contract only appear if `emit_art_inventory.py` has been run.
    inv = {}
    if INVENTORY.is_file():
        inv = {r["name"]: r for r in json.load(open(INVENTORY, encoding="utf-8"))["entries"]}
    claims = {}
    if CENSUS.is_file():
        claims = json.load(open(CENSUS, encoding="utf-8"))["atlases"]

    sets = defaultdict(dict)
    for n in names:
        stem, part = split_part(n)
        if stem:
            sets[stem][part] = n

    rows = []
    for stem, parts in sets.items():
        v = verdict(parts)
        if not v:
            continue
        members = list(parts.values())
        warm = sum(1 for m in members if (inv.get(m) or {}).get("onTheme"))
        known = sum(1 for m in members if m in inv)
        claimed = sum(1 for m in members if (claims.get(m) or {}).get("claimed"))
        rows.append({"stem": stem, "verdict": v, "parts": parts, "n": len(members),
                     "warm": warm, "known": known, "claimed": claimed,
                     "incoherent": coherence(parts, inv)})

    sel = rows
    if args.complete:
        sel = [r for r in sel if r["verdict"] == "9slice"]
    if args.free:
        sel = [r for r in sel if r["claimed"] == 0]
    if args.warm:
        sel = [r for r in sel if r["known"] and r["warm"] >= r["known"] * 0.5]

    order = {"9slice": 0, "9slice-part": 1, "edges-4": 2, "3slice-h": 3, "3slice-v": 4,
             "partial": 5}
    sel.sort(key=lambda r: (order[r["verdict"]], -r["warm"], r["stem"]))

    print(f"{len(names)} named entries · {len(rows)} set(s) recognised"
          f" · {len(sel)} after filters")
    if not inv:
        print("⚠ no art_inventory.json - warm/contract columns are blank."
              " Run emit_art_inventory.py to fill them.")
    counts = defaultdict(int)
    for r in rows:
        counts[r["verdict"]] += 1
    print("shapes:  " + " · ".join(f"{k} {counts[k]}" for k in sorted(counts)))

    print(f"\n{'stem':<46}{'shape':<13}{'n':>3}{'warm':>6}{'claimed':>9}   parts")
    for r in sel[:50]:
        print(f"{r['stem'][:45]:<46}{r['verdict']:<13}{r['n']:>3}{r['warm']:>6}"
              f"{r['claimed']:>9}   {','.join(sorted(r['parts']))}")
    if len(sel) > 50:
        print(f"  ⚠ {len(sel) - 50} more - the printed list is truncated, not the data")

    # ★ PRINTED BY DEFAULT, never behind a flag. A guard you have to ask for is a guard
    # nobody runs, and this one exists because its evidence sat unread in this tool's own output.
    bad = [r for r in sel if r.get("incoherent")]
    if inv:
        if bad:
            print(f"\n⚠⚠ {len(bad)} set(s) contain a piece that DISAGREES WITH ITS SIBLINGS "
                  f"about colour.")
            print("   A set is one piece of art cut up, so its parts agree; a part that does not")
            print("   is the cheapest signal that its entry points at DIFFERENT ART on this fork.")
            for r in bad:
                print(f"\n   {r['stem']}  ({r['verdict']}, {r['n']} pieces)")
                for part, name, why in r["incoherent"]:
                    print(f"     {part:<4} {name:<40} {why}")
            print("\n   ⚠ Verify by eye before trusting either reading:")
            print("     py addons\\tools\\emit_atlas_sheet.py <name> --out check")
        else:
            print(f"\n   set coherence: no piece disagrees with its siblings"
                  f" (hue > {HUE_OUTLIER_DEG:.0f}deg or sat > {SAT_OUTLIER_RATIO}x the median)")
        print("   ⚠ It finds the ODD ONE OUT: it compares to the set's MEDIAN, so a set where")
        print("     most entries are wrong has a wrong median and reports nothing.")

    OUT.mkdir(parents=True, exist_ok=True)
    out = OUT / "art_sets.json"
    json.dump({"named": len(names), "sets": len(rows),
               "variantsMatched": [k for k, _ in PARTS], "rows": sel},
              open(out, "w", encoding="utf-8"), indent=1)
    print(f"\nwrote {out.relative_to(REPO).as_posix()}")

    if args.sheet:
        hit = next((r for r in rows if r["stem"].lower() == args.sheet.lower()), None)
        if not hit:
            print(f"\n⚠ no set named {args.sheet!r} - stems are printed above")
        else:
            names_ = " ".join(hit["parts"][k] for k in sorted(hit["parts"]))
            print(f"\nlook at it:\n  py addons\\tools\\emit_atlas_sheet.py {names_}"
                  f" --out {hit['stem']}")

    # ⚠⚠ THE FLOOR, said every run rather than buried in the docstring.
    print(f"\n⚠ every count here is a FLOOR. Only these spellings are recognised: "
          f"{', '.join(k for k, _ in PARTS)}.")
    print("  A set whose author spelled a part differently is invisible to this tool, and a")
    print("  set with no naming convention at all cannot be found by name at any spelling.")


if __name__ == "__main__":
    main()
