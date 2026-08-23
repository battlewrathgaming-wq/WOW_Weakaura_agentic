# -*- coding: utf-8 -*-
r"""emit_atlas_sheet.py - RENDER the client's named UI art, so a person can look at it.

    py addons\tools\emit_atlas_sheet.py Objective-Header challenges-timerbg
    py addons\tools\emit_atlas_sheet.py --atlas ChallengeModeHud
    py addons\tools\emit_atlas_sheet.py --atlas bonusobjectives --free
    py addons\tools\emit_atlas_sheet.py --atlas QuestFrame --limit 30 --out dressing

★★★ WHY. `addons/maps/atlas/` already says WHAT art exists and which entries the client's own
code claims - 4503 named entries, 3144 free. It cannot tell you whether a thing looks any good,
and neither could anyone reading it: the census is a JSON of names and numbers. Battlewrath,
2026-08-23: *"there is a big gap so far in display quality between our addons and what the
community produces… nice to start building the capability and agent ability in this area."*
⟶ This turns a name into a PICTURE. It does not produce quality; it removes the blindfold, and
the taste that follows is his.

★★ IT RENDERS BY NAME, NEVER BY COORDS, and that is the point rather than a convenience. A
hand-cut TexCoord is correct the instant it is typed and rots silently when a patch moves the
atlas - it then points at the WRONG ART with nothing to notice. The name is what the client
maintains. Same fault `check_cites.py` exists for, one level over. `layout.lua`'s `SkinDivider`
already reads `AtlasInfo[name]` this way.

★ WHAT IS FREE, PER HIS RULING (2026-08-23): *"boarder framing is free use. On a map the icons
have meanings. And that's our curation. But the presentation of our addon we fully own."*
⟶ `satnav_ledger` law 10 - *no art that already OWNS a meaning here* - governs SIGNAL: an icon on
a map speaks a shared language and reusing it corrupts both sides. It does NOT govern PRESENTATION:
a border, a header, a backdrop. The `claimed` column is still printed on every row, because knowing
the client uses a piece is worth having either way - it is now information, not a veto.

⚠⚠ BLIZZARD'S ART, AND IT IS NEVER COMMITTED. Output goes to `addons/staging/atlas/`, which is
gitignored. It is a build product we can always re-make, exactly as `read_templates.py` argues for
FrameXML - not content we carry.

⚠ READ-ONLY on the client: archives are opened for reading and nothing is written under F:\games.
"""
import argparse
import io
import json
import re
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

try:
    import mpyq
    from PIL import Image, ImageDraw, ImageFont
except ImportError as e:  # pragma: no cover - environment fault, not a finding
    print(f"emit_atlas_sheet: missing dependency ({e}). mpyq and Pillow are required.")
    sys.exit(2)

REPO = Path(__file__).resolve().parents[2]
CENSUS = REPO / "addons" / "maps" / "atlas" / "atlas.census.json"
ATLASINFO = (REPO / "Outputs" / "client_interface" / "patch-B" / "Interface"
             / "SharedXML" / "AtlasInfo.lua")
OUT_ROOT = REPO / "addons" / "staging" / "atlas"
DATA = Path(r"F:\games\Ascension_wow\resources\ascension-live\Data")
FONT_ARCHIVE = DATA / "enUS" / "locale-enUS.MPQ"

# ⚠ THE CLIENT'S OWN LOAD ORDER, later wins. A texture present in two archives is the LATER
# one at run time, so reading the earlier would render art the player never sees.
CHAIN = ["common.MPQ", "common-2.MPQ", "expansion.MPQ", "lichking.MPQ",
         "patch.MPQ", "patch-2.MPQ", "patch-3.MPQ", "patch-4.MPQ", "patch-5.MPQ",
         "patch-A.MPQ", "patch-B.MPQ"]

# ★ Dark, because WoW UI art is overwhelmingly light gold on transparent and would VANISH on
# white. This is nearer to what it sits on in game; it is a viewing choice and is stated so
# nobody reads the background as part of the art.
BG = (26, 26, 28, 255)
LABEL_W, PAD, GAP = 300, 12, 10

_COORDS = re.compile(
    r'\["([^"]+)"\]\s*=\s*\{\s*"([^"]+)"\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*,'
    r'\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)')


def read_coords():
    """name -> (texture, w, h, l, r, t, b), straight from the client's own register.

    ⚠ The census JSON carries texture/w/h/claimed but NOT the tex-coords, so the coords come
    from `AtlasInfo.lua` itself. Two sources, both the client's; neither is transcribed here.
    """
    if not ATLASINFO.is_file():
        print(f"emit_atlas_sheet: no AtlasInfo at {ATLASINFO}")
        print("             extract it first:  py addons\\tools\\extract_interface.py patch-B.MPQ")
        sys.exit(2)
    out = {}
    for m in _COORDS.finditer(ATLASINFO.read_text(encoding="utf-8", errors="replace")):
        name, tex, w, h, l, r, t, b = m.groups()
        # ⚠⚠ THE PATH IS A LUA STRING LITERAL, so its separators are ESCAPED in the source:
        # `"Interface\\QuestFrame\\ObjectiveTracker"`. Taken raw, the lookup key carries `\\`
        # where the archive holds `\`, every texture reports MISSING, and the sheet reads as
        # "this fork does not have that art" - a confident, wrong answer.
        # ★ Same family as `check_escapes.py`'s dropped backslash, arriving from the other side:
        # there a separator vanished, here one is doubled. Both make a path that resolves to
        # nothing while looking entirely reasonable.
        tex = tex.replace("\\\\", "\\")
        out[name] = (tex, float(w), float(h), float(l), float(r), float(t), float(b))
    return out


def read_census():
    if not CENSUS.is_file():
        print(f"emit_atlas_sheet: no census at {CENSUS} - run emit_atlas_census.py")
        sys.exit(2)
    return json.load(open(CENSUS, encoding="utf-8"))["atlases"]


class Archives:
    """The MPQ chain, opened once. Later archives win, so the walk is back-to-front."""

    def __init__(self):
        self.opened = []
        for name in CHAIN:
            p = DATA / name
            if not p.is_file():
                continue
            try:
                self.opened.append((name, mpyq.MPQArchive(str(p))))
            except Exception as e:
                print(f"  ⚠ {name} unreadable ({type(e).__name__}) - skipped")
        self._cache = {}

    def texture(self, path):
        """Decode `Interface\\X\\Y` to an image, or None. Cached: one atlas serves many names."""
        key = path.lower()
        if key in self._cache:
            return self._cache[key]
        want = (path + ".blp").lower().encode("latin-1")
        blob = None
        for name, arc in reversed(self.opened):
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
            except Exception as e:
                print(f"  ⚠ {path}: BLP would not decode ({type(e).__name__})")
                img = None
        self._cache[key] = img
        return img


def client_font(size):
    """The client's own face, labelling the client's own art. Falls back rather than failing."""
    try:
        arc = mpyq.MPQArchive(str(FONT_ARCHIVE))
        blob = arc.read_file(b"Fonts\\FRIZQT__.TTF")
        if blob:
            return ImageFont.truetype(io.BytesIO(blob), size)
    except Exception:
        pass
    return ImageFont.load_default()


def main():
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument("names", nargs="*", help="atlas entry names to render")
    ap.add_argument("--atlas", help="every named entry whose TEXTURE path matches this substring")
    ap.add_argument("--free", action="store_true", help="only entries the client does not claim")
    ap.add_argument("--limit", type=int, default=60, help="cap the sheet (default 60)")
    ap.add_argument("--stress", action="store_true",
                    help="also render each entry stretched in ONE axis at a time, so "
                         "distortion is seen rather than warned about")
    ap.add_argument("--stress-factor", type=int, default=2, dest="stress_factor",
                    help="how far to stretch (default 2)")
    ap.add_argument("--out", default="sheet", help="output stem under addons/staging/atlas/")
    args = ap.parse_args()

    coords, census = read_coords(), read_census()
    print(f"AtlasInfo: {len(coords)} entries with coords · census: {len(census)} entries")

    picked = []
    if args.names:
        for n in args.names:
            if n not in coords:
                print(f"  ⚠ NOT A NAMED ENTRY: {n}   (named, never silently skipped)")
            else:
                picked.append(n)
    if args.atlas:
        needle = args.atlas.lower()
        picked += [n for n, c in coords.items() if needle in c[0].lower()]
    if not picked:
        print("nothing selected - give names, or --atlas <substring>")
        sys.exit(2)

    seen, ordered = set(), []
    for n in picked:
        if n not in seen:
            seen.add(n)
            ordered.append(n)
    if args.free:
        before = len(ordered)
        ordered = [n for n in ordered if not (census.get(n) or {}).get("claimed")]
        print(f"--free: {before} -> {len(ordered)} (dropped the ones the client's code claims)")

    dropped = 0
    if len(ordered) > args.limit:
        # ⚠ SAID, never silent. A truncated sheet that does not say so reads as complete.
        dropped = len(ordered) - args.limit
        ordered = ordered[:args.limit]

    arcs = Archives()
    font = client_font(13)
    small = client_font(11)

    rows, missing = [], []
    for n in ordered:
        tex, w, h, l, r, t, b = coords[n]
        img = arcs.texture(tex)
        if img is None:
            missing.append(n)
            continue
        W, H = img.size
        crop = img.crop((round(l * W), round(t * H), round(r * W), round(b * H)))
        rows.append((n, crop, tex, w, h, (census.get(n) or {}).get("claimed")))

    if not rows:
        print("nothing could be rendered - no texture in the chain decoded")
        for n in missing:
            print(f"  MISSING TEXTURE  {n}  ({coords[n][0]})")
        sys.exit(2)

    art_w = max(c.size[0] for _n, c, *_ in rows)
    F = args.stress_factor if args.stress else None

    # ★★ COLUMNS: native, then the same art stretched in ONE axis at a time. Stretching
    # both at once hides which axis hurts, and for a bordered plate they hurt differently -
    # a corner filigree smeared sideways reads as a bad texture, smeared vertically as a
    # bad frame.
    cols = [art_w] if not F else [art_w, art_w * F, art_w]
    # ★ A row is as tall as its tallest cell - the sheet's own rule, applied to the sheet.
    heights = [max(c.size[1] * (F or 1), 30) for _n, c, *_ in rows]
    head = 26 if not F else 44
    total_h = sum(h + GAP for h in heights) + PAD * 2 + head
    total_w = LABEL_W + sum(cols) + PAD * 2 + GAP * (len(cols) - 1) + PAD

    sheet = Image.new("RGBA", (total_w, total_h), BG)
    d = ImageDraw.Draw(sheet)
    d.text((PAD, PAD), f"{len(rows)} named entr(ies)   ·   background is a VIEWING CHOICE,"
                       f" not part of the art", font=small, fill=(150, 150, 155, 255))

    xs = []
    x = LABEL_W + PAD
    for cw in cols:
        xs.append(x)
        x += cw + GAP

    if F:
        # ⚠⚠ THE RESAMPLE FILTER IS A VIEWING CHOICE AND IT CHANGES THE VERDICT. LANCZOS
        # would flatter the art and NEAREST would exaggerate the blockiness; BILINEAR is
        # nearest to what the GPU actually does to a stretched texture. Stated on the sheet
        # itself, because a filter that flatters is a lie told in a picture.
        d.text((PAD, PAD + 15),
               f"stretched {F}x per axis, BILINEAR - the filter the GPU is closest to."
               f"  ⚠ distortion here is REAL, not an artefact of this sheet",
               font=small, fill=(200, 160, 110, 255))
        for label, cx in zip(("native", f"{F}x WIDE", f"{F}x TALL"), xs):
            d.text((cx, PAD + 30), label, font=small, fill=(150, 150, 155, 255))

    y = PAD + head
    for (n, crop, tex, w, h, claimed), rh in zip(rows, heights):
        tag = "CLAIMED" if claimed else "free"
        colour = (220, 170, 90, 255) if claimed else (140, 200, 140, 255)
        d.text((PAD, y), n, font=font, fill=(235, 235, 235, 255))
        d.text((PAD, y + 15), f"{int(w)}x{int(h)}   {tag}", font=small, fill=colour)

        sheet.alpha_composite(crop, (xs[0], y))
        if F:
            cw, ch = crop.size
            wide = crop.resize((max(cw * F, 1), ch), Image.BILINEAR)
            tall = crop.resize((cw, max(ch * F, 1)), Image.BILINEAR)
            sheet.alpha_composite(wide, (xs[1], y))
            sheet.alpha_composite(tall, (xs[2], y))
        y += rh + GAP

    OUT_ROOT.mkdir(parents=True, exist_ok=True)
    out = OUT_ROOT / f"{args.out}.png"
    sheet.save(out)

    print(f"\nwrote {out.relative_to(REPO).as_posix()}   {total_w}x{total_h}")
    print(f"  {len(rows)} rendered"
          + (f" · {len(missing)} texture(s) not in the chain" if missing else "")
          + (f" · ⚠ {dropped} DROPPED by --limit {args.limit}" if dropped else ""))
    for n in missing:
        print(f"  MISSING TEXTURE  {n}  ({coords[n][0]})")
    print("  ⚠ Blizzard art. staging/ is gitignored and this is never committed.")


if __name__ == "__main__":
    main()
