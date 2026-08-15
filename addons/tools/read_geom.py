"""read_geom.py - turn the geometry run into constants, norms, and a drift check.

★★★ WHAT THIS CLOSES. `frames.lua` resolves the whole object pane offline and refuses
to invent the one thing it cannot know - a FontString's extent, which is text x font.
This reads the client's answer back and turns each unknown into a constant.

★★ AND IT READS WIDER THAN THE ASK, on his instruction: *"capture broader than the
ask. That exposes trends and norms."* Four sections come back:

    FONTS       per-character norms, so any future string is PREDICTED not measured
    TEMPLATES   what the client BUILDS vs what the XML declares
    NORMS       the client's own shipped panels, measured - the check on whether
                their panels really do the 6 / 8 / 12 their XML declares
    OURS        every registered control's real rect

⚠ THE APPARATUS IS READ FIRST AND NOTHING ELSE IS BELIEVED WITHOUT IT. `/coadump r
api` run 1 filed four disagreements about the client that were all false, because the
experiments never ran. A zero and a measurement that did not happen are identical in
a file, so `apparatus = "dead"` short-circuits this whole report.

★ It also writes the client's own rects back out in the SAME `PaneRects` format the
offline resolver emits, so `pane_audit.py --draw` can draw the REAL pane and the Lua
checks can run on measured rects instead of predicted ones - one implementation of
the overlap arithmetic, not two.

Usage:
    py addons\\tools\\read_geom.py
"""
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
sys.path.insert(0, str(REPO / "Weak Auras"))
from lua_table import parse_file, LuaParseError    # noqa: E402 - reused, not re-derived

CLIENT = Path(r"F:\games\Ascension_wow\resources\ascension-live")
SV = CLIENT / "WTF" / "Account" / "BATTLEWRATH" / "SavedVariables" / "COA_DevDump.lua"
OUT = REPO / "addons" / "staging" / "client_rects.lua"

# ★ The strings the pane actually draws. Their measured widths become constants; the
# per-character norm covers everything else.
OURS_STRINGS = ("identity", "detect", "action", "stage", "on-ramp", "children")


def _n(v):
    try:
        return float(v)
    except (TypeError, ValueError):
        return None


def _list(block):
    """Lua arrays parse as 1-keyed dicts; give back a list either way."""
    if isinstance(block, dict):
        return [block[k] for k in sorted(block, key=lambda x: int(x))]
    return block or []


def main():
    if not SV.exists():
        print("no SavedVariables at %s" % SV)
        return 2
    try:
        tree = parse_file(str(SV))
    except LuaParseError as e:
        print("could not parse the saved variables: %s" % e)
        return 2

    db = tree.get("COA_DevDumpDB") or {}
    head, p = db.get("header") or {}, db.get("payload") or {}
    if head.get("task") != "geom":
        print("the mailbox holds '%s', not 'geom' - run `/coadump r geom` then /reload"
              % head.get("task"))
        return 1
    if head.get("status") != "complete":
        print("the geom envelope is '%s', not complete" % head.get("status"))
        return 1

    print("geom run %s  ·  %s  ·  scale %s  ·  %s"
          % (head.get("runId"), head.get("startedAt"), p.get("scale"),
             p.get("resolution") or "resolution unknown"))

    # =================================================================
    # ⚠⚠ THE APPARATUS, BEFORE ANYTHING ELSE
    # =================================================================
    ctl = p.get("control") or {}
    if p.get("apparatus") != "live":
        print("\n⚠⚠ APPARATUS DEAD - a known string measured %s. Nothing below was "
              "recorded, and that is correct: a page of zeros reads exactly like a "
              "page of measurements." % ctl.get("shownWidth"))
        return 1

    hidden = ctl.get("hiddenMeasures")
    print("\n=== the apparatus ===")
    print("  shown  'MMMMMMMMMM' = %s" % ctl.get("shownWidth"))
    print("  hidden 'MMMMMMMMMM' = %s" % ctl.get("hiddenWidth"))
    # ★★★ A QUESTION WE HAD NOT ASKED, answered. `Click()` fires on hidden frames -
    # measured - which is suggestive and is NOT this question.
    print("  ⇒ a never-shown frame %s measure" % ("DOES" if hidden else "does NOT"))
    if hidden and not ctl.get("hiddenAgreesWithShown"):
        print("  ⚠ but it disagrees with the shown one - the number is not the same fact")

    # =================================================================
    # ★★ FONTS: the norm, and the exact strings
    # =================================================================
    fonts = p.get("fonts") or {}
    print("\n=== fonts (%d) - per-character norm, then our own strings ===" % len(fonts))
    print("  %-24s %6s %6s %6s   %s" % ("font", "size", "perM", "perI", "line"))
    for name in sorted(fonts):
        f = fonts[name]
        if f.get("error"):
            print("  %-24s ⚠ %s" % (name, f["error"]))
            continue
        print("  %-24s %6s %6s %6s   %s"
              % (name, f.get("size"), _fmt(f.get("perM")), _fmt(f.get("perI")),
                 f.get("height")))

    small = fonts.get("GameFontNormalSmall") or {}
    strings = small.get("strings") or {}
    if strings:
        print("\n  GameFontNormalSmall - the zone headers, exactly:")
        for s in OURS_STRINGS:
            if s in strings:
                print("    %-12s %s px" % (s, strings[s]))

    # =================================================================
    # ★★ TEMPLATES: built vs declared
    # =================================================================
    t = p.get("templates") or {}
    print("\n=== control templates (%d) ===" % len(t))
    for name in sorted(t):
        row = t[name]
        line = "  %-38s %sx%s" % (name, _fmt(row.get("declaredW")), _fmt(row.get("declaredH")))
        after = row.get("afterSetWidth96")
        if after:
            # ★★★ THE ONE WE REFUSED TO ASSERT FROM MEMORY. `object.lua` calls
            # SetWidth(96); the template adds textures either side, and how much
            # wider it ends up is a measurement, never a recollection.
            line += ("   after SetWidth(96): %s wide  ⇒ the template adds %s"
                     % (_fmt(after.get("getWidth")),
                        _fmt((_n(after.get("getWidth")) or 0) - 96)))
        print(line)
    for name in _list(p.get("templatesMissing")):
        print("  %-38s ⚠ not on this fork" % name)

    # =================================================================
    # ★★★ NORMS: what the client's own panels actually measure
    # =================================================================
    ref = p.get("reference") or {}
    print("\n=== the client's own panels (%d) - spacing as BUILT ===" % len(ref))
    for name in sorted(ref):
        parts = [x for x in _list((ref[name] or {}).get("parts")) if _n(x.get("h"))]
        if not parts:
            print("  %-34s (no measurable parts)" % name)
            continue
        # ⚠ Sorted by TOP edge, so the gaps read down the panel the way a person does.
        parts.sort(key=lambda e: -(_n(e.get("bottom")) + _n(e.get("h"))))
        gaps = []
        for a, b in zip(parts, parts[1:]):
            gap = _n(a.get("bottom")) - (_n(b.get("bottom")) + _n(b.get("h")))
            if gap is not None and 0 <= gap < 80:
                gaps.append(round(gap))
        print("  %-34s %d part(s)   gaps: %s"
              % (name, len(parts), _common(gaps) or "none in range"))
    for name in _list(p.get("referenceMissing")):
        print("  %-34s ⚠ not loaded at run time" % name)

    # =================================================================
    # ★★★ OURS: the real pane, and the file the Lua checks can read
    # =================================================================
    ours = _list(p.get("ours"))
    missing = _list(p.get("oursMissing"))
    print("\n=== our own controls (%d measured, %d missing) ===" % (len(ours), len(missing)))

    # ⚠⚠ ONE FRAME OF REFERENCE PER PANE, and the first cut got this wrong. It
    # converted EVERY control into `object.pane`, so the promoter's four controls -
    # which live in a different frame 970px away - came back as "outside the pane by
    # 1010". Arithmetic that is correct and about nothing. ★ Worse than noise: it
    # would have HIDDEN a real promoter finding under four fake ones.
    panes = {}
    for r in ours:
        key = r.get("key") or ""
        if key.endswith(".pane") and _n(r.get("h")):
            panes[key.split(".", 1)[0]] = r
    if not panes:
        print("  ⚠ no `*.pane` was measured, so nothing can be put in a pane's frame "
              "of reference. Were the panes ever created this session?")
        for m in missing:
            print("  ⚠ %s" % m)
        return 0

    grouped = {}
    orphans = []
    for r in ours:
        key = r.get("key") or ""
        owner = key.split(".", 1)[0]
        pane = panes.get(owner)
        if not pane or r is pane or not _n(r.get("h")) or not _n(r.get("w")):
            if pane is None and key:
                orphans.append(key)
            continue
        ptop = _n(pane.get("bottom")) + _n(pane.get("h"))
        # ⚠ Converted to its OWN pane's frame - x from that pane's left, y NEGATIVE
        # from its top - because that is the vocabulary `layout.lua` speaks.
        grouped.setdefault(owner, []).append({
            "name": key, "shown": r.get("shown"),
            "left": _n(r.get("left")) - _n(pane.get("left")),
            "top": (_n(r.get("bottom")) + _n(r.get("h"))) - ptop,
            "w": _n(r.get("w")), "h": _n(r.get("h")),
        })

    for owner in sorted(grouped):
        pane, rows = panes[owner], grouped[owner]
        print("\n  [%s] %sx%s" % (owner, _fmt(pane.get("w")), _fmt(pane.get("h"))))
        rows.sort(key=lambda e: -e["top"])
        for e in rows:
            print("    %-22s x=%6.0f y=%7.0f  %4.0fx%-4.0f %s"
                  % (e["name"], e["left"], e["top"], e["w"], e["h"],
                     "" if e["shown"] else "(hidden)"))
    for key in orphans:
        print("  ⚠ %s has no matching `*.pane` - not placed in any frame" % key)

    _emit(grouped, panes)
    print("\n  wrote %s" % OUT)
    print("  ★ run the Lua checks on the CLIENT's own numbers - same arithmetic "
          "the\n    offline pass uses, no second implementation:")
    print("      .tools\\lua51\\lua5.1.exe addons\\tools\\smoke\\check_rects.lua")

    for m in missing:
        print("  ⚠ %s" % m)
    return 0


def _fmt(v):
    n = _n(v)
    return "-" if n is None else ("%g" % round(n, 2))


def _common(gaps):
    """The gap values that actually repeat - the NORM, not the average."""
    if not gaps:
        return ""
    counts = {}
    for g in gaps:
        counts[g] = counts.get(g, 0) + 1
    top = sorted(counts.items(), key=lambda kv: (-kv[1], kv[0]))[:4]
    return "  ".join("%dpx x%d" % (g, n) for g, n in top)


def _emit(grouped, panes):
    """The client's rects, ONE BLOCK PER PANE, in the resolver's own format."""
    OUT.parent.mkdir(parents=True, exist_ok=True)
    with open(OUT, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("-- written by read_geom.py from a live /coadump r geom run.\n")
        fh.write("-- ONE BLOCK PER PANE: a control is only ever compared against its\n")
        fh.write("-- own frame's siblings, never across panes.\n")
        fh.write("PaneRects = { [\"panes\"] = {\n")
        for owner in sorted(grouped):
            pane, rows = panes[owner], grouped[owner]
            fh.write("\t[\"%s\"] = {\n\t\t[\"rects\"] = {\n" % owner)
            fh.write("\t\t\t[1] = {\n\t\t\t\t[\"name\"] = \"%s.pane\",\n" % owner)
            fh.write("\t\t\t\t[\"shown\"] = true,\n\t\t\t\t[\"root\"] = true,\n")
            fh.write("\t\t\t\t[\"left\"] = 0.00,\n\t\t\t\t[\"top\"] = 0.00,\n")
            fh.write("\t\t\t\t[\"w\"] = %.2f,\n\t\t\t\t[\"h\"] = %.2f,\n"
                     % (_n(pane.get("w")), _n(pane.get("h"))))
            fh.write("\t\t\t\t[\"right\"] = %.2f,\n\t\t\t\t[\"bottom\"] = %.2f,\n\t\t\t},\n"
                     % (_n(pane.get("w")), -_n(pane.get("h"))))
            for i, e in enumerate(rows, 2):
                fh.write("\t\t\t[%d] = {\n" % i)
                fh.write("\t\t\t\t[\"name\"] = \"%s\",\n" % e["name"])
                fh.write("\t\t\t\t[\"shown\"] = %s,\n" % ("true" if e["shown"] else "false"))
                fh.write("\t\t\t\t[\"left\"] = %.2f,\n\t\t\t\t[\"right\"] = %.2f,\n"
                         % (e["left"], e["left"] + e["w"]))
                fh.write("\t\t\t\t[\"top\"] = %.2f,\n\t\t\t\t[\"bottom\"] = %.2f,\n"
                         % (e["top"], e["top"] - e["h"]))
                fh.write("\t\t\t\t[\"w\"] = %.2f,\n\t\t\t\t[\"h\"] = %.2f,\n\t\t\t},\n"
                         % (e["w"], e["h"]))
            fh.write("\t\t},\n\t},\n")
        fh.write("} }\n")


if __name__ == "__main__":
    sys.exit(main())
