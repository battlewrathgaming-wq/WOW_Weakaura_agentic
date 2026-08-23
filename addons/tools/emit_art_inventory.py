# -*- coding: utf-8 -*-
r"""emit_art_inventory.py - classify every named atlas entry by THEME and SCALING CONTRACT.

    py addons\tools\emit_art_inventory.py                    sweep everything, write the inventory
    py addons\tools\emit_art_inventory.py --theme            only the gold / brown / bronze band
    py addons\tools\emit_art_inventory.py --contract wide    only art that survives a width stretch
    py addons\tools\emit_art_inventory.py --top 40 --sheet   render the shortlist to a PNG

★★★ WHY. `emit_atlas_census.py` says what exists and who claims it; `emit_atlas_sheet.py` lets a
person LOOK at it. Neither can sift 4503 entries down to the ones worth looking at. Battlewrath,
2026-08-23: *"The theme I have for the addons is mythical gold, browns and bronze."* A theme is a
selection criterion, and a criterion over 4503 items is machine work.

★★ THE MACHINE MEASURES; THE SELECTION IS HIS. [[pipeline-emits-class-knowledge-curates]]. Nothing
here decides that a piece is good - it decides that a piece is WARM, and that stretching it in a
given axis will or will not smear it. Those are facts about pixels. Whether the result belongs in
our UI is taste, it is his, and no column in this file expresses it.

★★★ THE SCALING CONTRACT IS COMPUTED FROM THE RULE THE PICTURES TAUGHT (§563):

    art survives stretching along the axis it is ALREADY UNIFORM IN

A divider is a repeated line across its width, so its COLUMNS are near-identical and it stretches
wide safely. A fade is uniform across its width for the same reason. A corner ornament is uniform
in neither axis, so it cannot be stretched at all. ⟶ Uniformity is measurable: compare every
column to the mean column, and every row to the mean row. The rule came from looking at four
pieces; this applies it to all of them.

⚠ WHAT IT CANNOT SAY, and the honest ceiling. It does not know a BORDER from a BACKGROUND, or a
frame from a fill - only how uniform the pixels are and what colour they average to. A `fixed`
verdict means "do not stretch this", never "this is a corner piece". Naming a shape from a
statistic would be the invention this bench keeps paying for.

⚠⚠ BLIZZARD'S ART. Output goes to `addons/staging/atlas/`, gitignored - a build product we can
always re-make. ⚠ READ-ONLY on the client.
"""
import argparse
import colorsys
import io
import json
import math
import re
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

try:
    import mpyq
    from PIL import Image
except ImportError as e:  # pragma: no cover
    print(f"emit_art_inventory: missing dependency ({e}).")
    sys.exit(2)

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "addons" / "tools"))

CENSUS = REPO / "addons" / "maps" / "atlas" / "atlas.census.json"
ATLASINFO = (REPO / "Outputs" / "client_interface" / "patch-B" / "Interface"
             / "SharedXML" / "AtlasInfo.lua")
OUT = REPO / "addons" / "staging" / "atlas"
DATA = Path(r"F:\games\Ascension_wow\resources\ascension-live\Data")

CHAIN = ["common.MPQ", "common-2.MPQ", "expansion.MPQ", "lichking.MPQ",
         "patch.MPQ", "patch-2.MPQ", "patch-3.MPQ", "patch-A.MPQ", "patch-B.MPQ"]

# ★ His words, turned into a hue window and nothing more. Gold, bronze and warm brown all sit
# in the same arc of the wheel; they differ in value and saturation, not in hue. ⚠ The window
# is a SELECTION AID and is stated so it can be argued with - it is not a definition of the
# theme, which is his.
THEME_HUE = (18.0, 58.0)   # degrees; 18 = warm brown, 58 = pale gold
THEME_MIN_SAT = 0.12       # below this it is grey and the hue is noise

# ⚠ A pixel below this alpha contributes nothing on screen, so it must not vote on the colour.
ALPHA_FLOOR = 32
METRIC_PX = 32             # metrics run on a downsample; 4503 entries at full size is waste

_COORDS = re.compile(
    r'\["([^"]+)"\]\s*=\s*\{\s*"([^"]+)"\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*,'
    r'\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)')


def read_coords():
    if not ATLASINFO.is_file():
        print(f"emit_art_inventory: no AtlasInfo at {ATLASINFO}")
        sys.exit(2)
    out = {}
    for m in _COORDS.finditer(ATLASINFO.read_text(encoding="utf-8", errors="replace")):
        name, tex, w, h, l, r, t, b = m.groups()
        # ⚠ Lua string literal: separators are escaped in the source. Taken raw, every
        # lookup misses and the sweep reports the whole client as missing art (§562).
        out[name] = (tex.replace("\\\\", "\\"), float(w), float(h),
                     float(l), float(r), float(t), float(b))
    return out


class Archives:
    def __init__(self):
        self.opened, self._cache = [], {}
        for name in CHAIN:
            p = DATA / name
            if p.is_file():
                try:
                    self.opened.append((name, mpyq.MPQArchive(str(p))))
                except Exception:
                    pass

    def texture(self, path):
        key = path.lower()
        if key in self._cache:
            return self._cache[key]
        want = (path + ".blp").lower().encode("latin-1")
        blob = None
        for _name, arc in reversed(self.opened):     # later archives win
            files = arc.files
            if not files:
                continue
            for f in files:
                if f.lower() == want:
                    blob = arc.read_file(f)
                    break
            if blob:
                break
        img = None
        if blob:
            try:
                img = Image.open(io.BytesIO(blob))
                img.load()
                img = img.convert("RGBA")
            except Exception:
                img = None
        self._cache[key] = img
        return img


def measure(crop):
    """Colour and per-axis uniformity. Returns None if nothing visible is in it."""
    small = crop.resize((min(METRIC_PX, max(crop.size[0], 1)),
                         min(METRIC_PX, max(crop.size[1], 1))), Image.BILINEAR)
    px = list(small.convert("RGBA").getdata())
    w, h = small.size
    vis = [(r, g, b) for r, g, b, a in px if a >= ALPHA_FLOOR]
    coverage = len(vis) / max(len(px), 1)
    if not vis:
        return None

    # circular mean of hue, weighted by saturation - a grey pixel's hue is noise and
    # must not drag the average.
    sx = sy = sat_sum = val_sum = wsum = 0.0
    for r, g, b in vis:
        hh, ss, vv = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
        sat_sum += ss
        val_sum += vv
        if ss >= THEME_MIN_SAT:
            ang = hh * 2 * math.pi
            sx += math.cos(ang) * ss
            sy += math.sin(ang) * ss
            wsum += ss
    hue = (math.degrees(math.atan2(sy, sx)) % 360.0) if wsum > 0 else None
    sat, val = sat_sum / len(vis), val_sum / len(vis)

    # ★ UNIFORMITY, which is the scaling contract. Compare every column to the mean column
    # and every row to the mean row; a low mean difference means the axis repeats itself.
    rows = [[px[y * w + x] for x in range(w)] for y in range(h)]

    def spread(vectors):
        n = len(vectors)
        if n < 2:
            return 0.0
        length = len(vectors[0])
        mean = [sum(v[i][c] for v in vectors) / n for i in range(length) for c in range(4)]
        total = 0.0
        for v in vectors:
            for i in range(length):
                for c in range(4):
                    total += abs(v[i][c] - mean[i * 4 + c])
        return total / (n * length * 4 * 255.0)

    cols = [[rows[y][x] for y in range(h)] for x in range(w)]

    # ★★★ THE MIDDLE AND THE CAPS ARE DIFFERENT QUESTIONS, and a single uniformity number
    # cannot ask both. Measured, not reasoned: a first cut scored `challenges-timerbg` at
    # uH 0.89 -> "safe to stretch wide" while the rendered picture plainly smeared its corner
    # filigree, and scored `ChallengeMode-RankLineDivider` at uH 0.68 -> "fixed" while the
    # picture showed it stretching wide perfectly well.
    #
    # ⟶ Both errors have ONE cause: the interesting art has CAPS. A whole-width average is
    # dominated by the long uniform middle and blind to the few columns at each end - and the
    # ends are exactly the part that breaks. ⟶ So ask twice: is the MIDDLE uniform (may it be
    # stretched at all), and do the CAPS differ from it (must they be pinned rather than
    # stretched). That pair IS the nine-slice question, which is the one window dressing needs.
    def split(vectors):
        n = len(vectors)
        k = max(1, round(n * 0.15))
        return vectors[:k], vectors[k:n - k] or vectors, vectors[n - k:]

    def cap_delta(caps, middle):
        """How far the end vectors sit from the middle's average. 0 = no caps at all."""
        if not caps or not middle:
            return 0.0
        length = len(middle[0])
        mid = [sum(v[i][c] for v in middle) / len(middle)
               for i in range(length) for c in range(4)]
        total = 0.0
        for v in caps:
            for i in range(length):
                for c in range(4):
                    total += abs(v[i][c] - mid[i * 4 + c])
        return min(1.0, total / (len(caps) * length * 4 * 255.0) * 4)

    lc, mc, rc = split(cols)
    lr, mr, rr = split(rows)
    return {"coverage": round(coverage, 3),
            "hue": round(hue, 1) if hue is not None else None,
            "sat": round(sat, 3), "val": round(val, 3),
            "uniformH": round(max(0.0, 1.0 - spread(cols) * 4), 3),
            "uniformV": round(max(0.0, 1.0 - spread(rows) * 4), 3),
            "midUniformH": round(max(0.0, 1.0 - spread(mc) * 4), 3),
            "midUniformV": round(max(0.0, 1.0 - spread(mr) * 4), 3),
            "capsH": round(cap_delta(lc + rc, mc), 3),
            "capsV": round(cap_delta(lr + rr, mr), 3)}


# ⚠ Thresholds, not truths. Stated as constants so they can be moved on evidence rather than
# tuned in someone's head - and the two captures that forced the caps split are the evidence
# any future move has to keep explaining.
UNIFORM_BAR = 0.80   # above this, an axis repeats itself and may be stretched
CAPS_BAR = 0.12      # above this, the ends are their own thing and must be PINNED


def contract(m):
    """The scaling verdict. ⚠ Says what may be STRETCHED, never what the art IS.

    ★ `-3` means three-slice: the middle stretches, the two ends do not. `9slice` means both
    axes are that shape - the only class that can become a frame at an arbitrary size.
    """
    hw = m["midUniformH"] >= UNIFORM_BAR
    hv = m["midUniformV"] >= UNIFORM_BAR
    ch, cv = m["capsH"] >= CAPS_BAR, m["capsV"] >= CAPS_BAR
    if hw and hv:
        return "9slice" if (ch and cv) else "both"
    if hw:
        return "wide-3" if ch else "wide"
    if hv:
        return "tall-3" if cv else "tall"
    return "fixed"


def on_theme(m):
    if m["hue"] is None or m["sat"] < THEME_MIN_SAT:
        return False
    return THEME_HUE[0] <= m["hue"] <= THEME_HUE[1]


def main():
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument("--theme", action="store_true", help="only the gold/brown/bronze band")
    ap.add_argument("--contract", choices=["wide", "tall", "both", "fixed"])
    ap.add_argument("--free", action="store_true", help="only entries the client does not claim")
    ap.add_argument("--atlas", help="only textures whose path matches this substring")
    ap.add_argument("--top", type=int, default=0, help="cap the shortlist")
    ap.add_argument("--sheet", action="store_true",
                    help="also print the emit_atlas_sheet command for the shortlist")
    args = ap.parse_args()

    coords = read_coords()
    census = json.load(open(CENSUS, encoding="utf-8"))["atlases"] if CENSUS.is_file() else {}
    arcs = Archives()
    print(f"sweeping {len(coords)} named entries…")

    rows, undecodable = [], []
    for i, (name, (tex, w, h, l, r, t, b)) in enumerate(sorted(coords.items())):
        if args.atlas and args.atlas.lower() not in tex.lower():
            continue
        img = arcs.texture(tex)
        if img is None:
            undecodable.append(name)
            continue
        W, H = img.size
        # ⚠⚠ SOME ENTRIES ARE MIRRORED, and the register says so by REVERSING the coords -
        # `AtlasInfo[name] = {texture,w,h,l,r,t,b,fH,fV}` and a flipped entry arrives with
        # right < left (or bottom < top). Pillow refuses such a box outright, which is how
        # the first sweep died. ★ Normalise the rectangle and RECORD the flip: a mirrored
        # piece is a real fact about the art, and dropping those entries would have quietly
        # excluded a whole class from the inventory.
        x0, x1 = sorted((round(l * W), round(r * W)))
        y0, y1 = sorted((round(t * H), round(b * H)))
        flipped_h, flipped_v = r < l, b < t
        crop = img.crop((x0, y0, x1, y1))
        if flipped_h:
            crop = crop.transpose(Image.FLIP_LEFT_RIGHT)
        if flipped_v:
            crop = crop.transpose(Image.FLIP_TOP_BOTTOM)
        if crop.size[0] < 2 or crop.size[1] < 2:
            undecodable.append(name)
            continue
        m = measure(crop)
        if not m:
            undecodable.append(name)
            continue
        m.update({"name": name, "texture": tex, "w": int(w), "h": int(h),
                  "flippedH": flipped_h, "flippedV": flipped_v,
                  "claimed": bool((census.get(name) or {}).get("claimed")),
                  "contract": contract(m), "onTheme": on_theme(m)})
        rows.append(m)
        if (i + 1) % 500 == 0:
            print(f"  … {i + 1}")

    OUT.mkdir(parents=True, exist_ok=True)
    full = OUT / "art_inventory.json"
    json.dump({"total": len(rows), "undecodable": len(undecodable),
               "themeHue": THEME_HUE, "uniformBar": UNIFORM_BAR,
               "entries": rows}, open(full, "w", encoding="utf-8"), indent=1)

    sel = rows
    if args.theme:
        sel = [r for r in sel if r["onTheme"]]
    if args.contract:
        sel = [r for r in sel if r["contract"] == args.contract]
    if args.free:
        sel = [r for r in sel if not r["claimed"]]
    # ★ Ranked by saturation x coverage: a piece that is strongly coloured AND actually fills
    # its rect is a stronger candidate than a faint wisp. A RANKING, not a judgement.
    sel.sort(key=lambda r: -(r["sat"] * r["coverage"]))
    if args.top:
        sel = sel[:args.top]

    print(f"\nswept {len(rows)} · {len(undecodable)} undecodable (named in the json)")
    by_c = {}
    for r in rows:
        by_c[r["contract"]] = by_c.get(r["contract"], 0) + 1
    print("contract:  " + " · ".join(f"{k} {v}" for k, v in sorted(by_c.items())))
    print(f"on theme:  {sum(1 for r in rows if r['onTheme'])}"
          f"  (hue {THEME_HUE[0]}-{THEME_HUE[1]}°, sat ≥ {THEME_MIN_SAT})")
    print(f"\nshortlist: {len(sel)}")
    print(f"{'name':<40}{'w':>5}{'h':>5}{'hue':>7}{'sat':>6}{'cov':>6}"
          f"{'mUH':>6}{'mUV':>6}{'capH':>6}{'capV':>6}  {'contract':<9}{'claim':<8}")
    for r in sel[:40]:
        print(f"{r['name'][:39]:<40}{r['w']:>5}{r['h']:>5}"
              f"{(r['hue'] if r['hue'] is not None else -1):>7.1f}{r['sat']:>6.2f}"
              f"{r['coverage']:>6.2f}{r['midUniformH']:>6.2f}{r['midUniformV']:>6.2f}"
              f"{r['capsH']:>6.2f}{r['capsV']:>6.2f}  "
              f"{r['contract']:<9}{'CLAIMED' if r['claimed'] else 'free':<8}")
    if len(sel) > 40:
        print(f"  ⚠ {len(sel) - 40} more in the json - printed list truncated, not the data")

    print(f"\nwrote {full.relative_to(REPO).as_posix()}")
    if args.sheet and sel:
        names = " ".join(r["name"] for r in sel[:24])
        print("\nlook at the shortlist:")
        print(f"  py addons\\tools\\emit_atlas_sheet.py {names} --stress --out shortlist")
    print("  ⚠ Blizzard art. staging/ is gitignored; the metrics are derived, the art is not kept.")


if __name__ == "__main__":
    main()
