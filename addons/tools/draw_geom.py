r"""draw_geom.py - turn a geom record into a picture of the panes.

★★★ WHY THIS EXISTS (Battlewrath, 2026-08-16):

    "You're giving me code examples and declarations as if I have the context of
    position, meaning, what it looks like. It's like giving me a API function as if
    it's self-describing."

    "That's what that is for. To extrapolate the data into a read surface on
    something I can form opinion and context on."

A key is a handle for whoever just read the file. `editor.width` carries position,
wording and purpose for me and NOTHING for a reader - so a question built on one asks
him to do my reading before he can answer it. The measurement already holds every
control's rect and its live text; it just had nothing with eyes reading it.

★ NOTHING HERE IS INVENTED. Every rectangle is a position the client reported and
every string is what that control was displaying at capture. The only choices this
file makes are colour and what to leave out - and what it leaves out, it says.

⚠ WHAT IT LEAVES OUT, STATED ON THE SHEET: unregistered Textures. They are template
art - backdrops, dropdown pieces, check-button frames - and drawing them would paper
over every control beneath. The count is printed so the omission is never silent.

Usage colours come from the surface files, so the picture answers "what does this DO"
and not only "where is it". A control the inventory has never heard of draws GREY, and
that is worth seeing: grey means nobody wrote it down.

    py addons/tools/draw_geom.py [record.json] [-o out.svg]
"""

import glob
import io
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE.replace("\\", "/")))
SURFACES = os.path.join(ROOT, "addons", "planning", "interface")

# ★ Colour by USAGE, because that is the question a picture should answer second -
# where is it, then what does it do.
USAGE_FILL = {
    "action":               ("#3f5d80", "#8fb6e8"),
    "arm":                  ("#7a4b23", "#ffc178"),
    "selection · tick":     ("#3d5f4a", "#8fd8a8"),
    "selection · dropdown": ("#4a4470", "#b0a6ee"),
    "selection · range":    ("#4a4470", "#b0a6ee"),
    "input · free":         ("#5c4a2e", "#e8cf9a"),
    "input · identifying":  ("#5c4a2e", "#e8cf9a"),
    "readout":              ("#2e3a44", "#9ec6d8"),
    "label":                ("#33343a", "#b9b6ac"),
    "icon":                 ("#3a3340", "#c9a6d8"),
}
UNKNOWN = ("#3a3a3a", "#8a8a8a")

ROW = re.compile(r"^([a-z_]+\.[\w.<>|]+)\s+(?:zone|kind)[^\n]*?usage ([^\n]+?)(?:\s{2,}forms|\s*$)",
                 re.M)
COLOUR = re.compile(r"\|c[fF][fF]([0-9a-fA-F]{6})")


def usages():
    """key -> usage, read from the surface files. The inventory IS the vocabulary."""
    out = {}
    for p in sorted(glob.glob(os.path.join(SURFACES, "*.md"))):
        for k, u in ROW.findall(io.open(p, encoding="utf-8", newline="").read()):
            out[k] = u.strip()
    return out


def plain(t):
    """WoW colour codes out, so the text reads. The first colour is kept as a hint."""
    if not t:
        return "", None
    m = COLOUR.search(t)
    return re.sub(r"\|c[fF][fF][0-9a-fA-F]{6}|\|r", "", t), ("#" + m.group(1)) if m else None


def esc(t):
    return (t.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"))


def draw(rec, out_path):
    payload = json.load(io.open(rec, encoding="utf-8"))["payload"]
    rows = payload["ours"]
    use = usages()

    # ⚠ THE CANVAS IS THE MEASURED EXTENT, not a claimed screen size. The record
    # carries a resolution and a scale, and deriving UIParent from them is a second
    # assumption on top of a number I did not measure. What was open is what is drawn.
    xs = [r["left"] for r in rows if r.get("left") is not None]
    rs = [r["left"] + r["w"] for r in rows if r.get("left") is not None and r.get("w")]
    bs = [r["bottom"] for r in rows if r.get("bottom") is not None]
    ts = [r["bottom"] + r["h"] for r in rows if r.get("bottom") is not None and r.get("h")]
    PAD, HEAD = 30, 96
    x0, x1, y0, y1 = min(xs) - PAD, max(rs) + PAD, min(bs) - PAD, max(ts) + PAD
    W, H = x1 - x0, (y1 - y0) + HEAD

    def sx(v):
        return v - x0

    def sy(top):
        """WoW measures from the bottom up; SVG from the top down."""
        return (y1 - top) + HEAD

    o = []
    o.append('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %.0f %.0f" '
             'width="%.0f" height="%.0f" font-family="Segoe UI, Verdana, sans-serif">'
             % (W, H, W, H))
    o.append('<rect width="100%%" height="100%%" fill="#14161a"/>')

    panes = [r for r in rows if r.get("isPane")]
    kids = [r for r in rows if not r.get("isPane")]
    skipped = [r for r in kids
               if r.get("isRegion") and not r.get("registered")
               and r.get("objectType") == "Texture"]

    # ---- the header, which is also the caveat sheet -----------------------
    src = os.path.basename(rec)
    o.append('<text x="24" y="34" fill="#e8e6e0" font-size="19" font-weight="600">'
             'The six surfaces, as the client measured them</text>')
    o.append('<text x="24" y="56" fill="#8a8f98" font-size="12">%s  ·  %d panes  ·  '
             '%d controls drawn  ·  every rectangle is a reported position, every string is '
             'what that control was displaying</text>'
             % (esc(src), len(panes), len(kids) - len(skipped)))
    o.append('<text x="24" y="74" fill="#c98b6b" font-size="12">'
             'NOT DRAWN: %d unregistered Textures — template art (backdrops, dropdown pieces, '
             'check frames). They would cover everything beneath them.</text>' % len(skipped))

    # ---- legend ------------------------------------------------------------
    lx = 24
    for name in ["action", "arm", "selection · tick", "selection · dropdown",
                 "input · identifying", "readout", "label"]:
        f, s = USAGE_FILL[name]
        o.append('<rect x="%d" y="%d" width="11" height="11" fill="%s" stroke="%s"/>' % (lx, 82, f, s))
        o.append('<text x="%d" y="%d" fill="#8a8f98" font-size="11">%s</text>'
                 % (lx + 16, 91, esc(name)))
        lx += 30 + len(name) * 6
    f, s = UNKNOWN
    o.append('<rect x="%d" y="%d" width="11" height="11" fill="%s" stroke="%s"/>' % (lx, 82, f, s))
    o.append('<text x="%d" y="%d" fill="#8a8f98" font-size="11">not in the inventory</text>'
             % (lx + 16, 91))

    # ---- the panes ---------------------------------------------------------
    for pane in sorted(panes, key=lambda r: -(r.get("w") or 0)):
        px, py = sx(pane["left"]), sy(pane["bottom"] + pane["h"])
        o.append('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="6" fill="#1e2228" '
                 'stroke="#4a5260" stroke-width="1.5"/>'
                 % (px, py, pane["w"], pane["h"]))
        o.append('<text x="%.1f" y="%.1f" fill="#6f7684" font-size="11">%s   %.0f × %.0f</text>'
                 % (px + 2, py - 5, esc(pane["key"]), pane["w"], pane["h"]))

        owner = pane["key"].split(".")[0]
        for r in kids:
            if r["key"].split(".")[0] != owner or r in skipped:
                continue
            if r.get("left") is None:
                continue                      # unanchored: nothing to draw, §133
            key = r["key"]
            fill, stroke = USAGE_FILL.get(use.get(key), UNKNOWN)
            x, y = sx(r["left"]), sy(r["bottom"] + (r.get("h") or 0))
            w, h = r.get("w") or 1, r.get("h") or 1
            txt, hint = plain(r.get("text"))

            if r.get("isRegion"):
                # ★ A FontString IS its text. Drawing a box round it would say
                # "widget" where the truth is "these words, here".
                size = 11 if h > 11 else 10
                o.append('<text x="%.1f" y="%.1f" fill="%s" font-size="%d" '
                         'font-family="Verdana, sans-serif">%s</text>'
                         % (x, y + h - 1, hint or stroke, size, esc(txt or "")))
                if not txt:
                    # ⚠ An empty readout measures 1x1. Say it is there and empty
                    # rather than draw nothing, which reads as absent.
                    o.append('<rect x="%.1f" y="%.1f" width="14" height="2" fill="#3a3f47"/>'
                             % (x, y))
                    o.append('<text x="%.1f" y="%.1f" fill="#4e545e" font-size="8">%s '
                             '(empty)</text>' % (x + 17, y + 3, esc(key)))
            else:
                o.append('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="2" '
                         'fill="%s" stroke="%s" stroke-width="1"/>' % (x, y, w, h, fill, stroke))
                short = key.split(".", 1)[1] if "." in key else key
                if w >= 34:
                    o.append('<text x="%.1f" y="%.1f" fill="%s" font-size="8.5" '
                             'text-anchor="middle">%s</text>'
                             % (x + w / 2, y + h / 2 + 3, stroke, esc(short[:int(w / 5)])))
                else:
                    o.append('<text x="%.1f" y="%.1f" fill="%s" font-size="7.5">%s</text>'
                             % (x + w + 3, y + h / 2 + 3, stroke, esc(short)))

    o.append("</svg>")
    io.open(out_path, "w", encoding="utf-8", newline="").write("\n".join(o))
    return len(panes), len(kids) - len(skipped), len(skipped)


def main():
    args = [a for a in sys.argv[1:] if a != "-o"]
    rec = args[0] if args and args[0].endswith(".json") else sorted(
        glob.glob(os.path.join(ROOT, "addons", "landing", "records", "*__geom.json")))[-1]
    out = args[1] if len(args) > 1 else os.path.join(
        ROOT, "addons", "staging", os.path.basename(rec).replace(".json", ".svg"))
    d = os.path.dirname(out)
    if d and not os.path.isdir(d):
        os.makedirs(d)
    p, c, s = draw(rec, out)
    print("drew %d panes, %d controls (%d template textures left out)" % (p, c, s))
    print(out)


if __name__ == "__main__":
    main()
