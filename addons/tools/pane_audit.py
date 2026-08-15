"""pane_audit.py - the pane's stack, as an inventory rather than a guess (§100).

★★★ WHY. The smoke asserts BY EXCEPTION - silent when the pane is clean, which is
right for a guard and useless when I actually need to look at the stack. Guessing at
it is exactly how the magic y-offsets got into `object.lua` in the first place.

★★ IT READS WHAT THE OFFLINE RESOLVER LEFT. `frames.lua` runs the real `layout.lua`
against frames that KEEP their geometry and writes the rects to
`addons/staging/pane_rects.lua`. ⚠ Same Lua-table format as SavedVariables and the
same parser - there is no second format anyone has to keep in step.

★ AND THE GAP MATH IS THE AURA BENCH'S, not a rewrite. `layout_audit.py` was copied
here for this exact job and had never been called; the row/gap/span report is its.

⚠ WHAT IT CANNOT TELL YOU is listed last and on purpose: every element whose size
nobody set. Those are FontStrings measured from their text, and no offline model can
know them. The list is the input to ONE measuring run in the client - which is the
whole point of the split.

Usage:
    py addons\\tools\\pane_audit.py
"""
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")   # the report uses · and ⚠; cp1252 mangles both

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(REPO / "Weak Auras"))

import layout_audit as audit                       # noqa: E402 - path set above
from lua_table import parse_file, LuaParseError     # noqa: E402 - reused, not re-derived

RECTS = REPO / "addons" / "staging" / "pane_rects.lua"


def _rows(tree):
    """The emitted table, whatever order the keys parsed in."""
    root = tree.get("PaneRects") or {}
    out = {}
    for key in ("rects", "holes"):
        block = root.get(key) or {}
        if isinstance(block, dict):
            block = [block[k] for k in sorted(block, key=lambda x: int(x))]
        out[key] = block
    return out["rects"], out["holes"]


def _num(r, k):
    v = r.get(k)
    return float(v) if v is not None else None


def main():
    if not RECTS.exists():
        print("no rects at %s\n"
              "  run the smoke first - it writes them:\n"
              "    .tools\\lua51\\lua5.1.exe addons\\tools\\smoke\\smoke_dungeonrunpromoter.lua"
              % RECTS)
        return 2
    try:
        tree = parse_file(str(RECTS))
    except LuaParseError as e:
        print("could not parse the rects: %s" % e)
        return 2

    rects, holes = _rows(tree)

    # ★ layout_audit thinks in CENTRES because the aura bench's elements are placed
    # that way; frames are placed by their EDGES. Converting here keeps their module
    # untouched rather than teaching it a second convention.
    children, unmeasured, box = [], [], None
    for r in rects:
        # ⚠ THE CONTAINER IS NOT A ROW. Left in, it produced a -164 "gap" between the
        # last control and the frame it sits inside - arithmetic that is correct and
        # meaningless, which is the worst kind of number in a report.
        if r.get("root"):
            box = r
            continue
        left, right = _num(r, "left"), _num(r, "right")
        top, bottom = _num(r, "top"), _num(r, "bottom")
        if None in (left, right, top, bottom):
            need = ("width+height" if r.get("unknownW") and r.get("unknownH")
                    else "width" if r.get("unknownW") else "height")
            unmeasured.append((r.get("name"), need, _num(r, "anchorX"), _num(r, "anchorY")))
            continue
        children.append({
            "id": r.get("name"), "width": right - left, "height": top - bottom,
            "xOffset": (left + right) / 2.0, "yOffset": (top + bottom) / 2.0,
        })

    if box:
        print("container %s  %.0fx%.0f" % (box.get("name"), _num(box, "w"), _num(box, "h")))
    print("=== %d placed  ·  %d unmeasured  ·  %d unplaceable ===\n"
          % (len(children), len(unmeasured), len(holes)))

    if children:
        # ⚠⚠ THE `FLAG (>10%)` COLUMN IS THE AURA BENCH'S RULE AND DOES NOT TRANSFER.
        # It reads a gap against the SMALLER neighbouring element, which is right for
        # a HUD of same-sized icons and meaningless against a 1-pixel divider - every
        # rule-to-row gap flags at 2600%. ★ Reported rather than suppressed: the
        # NUMBERS are sound and only the verdict belongs to another bench, and a
        # quietly deleted column is how a tool starts lying.
        print("⚠ the FLAG column is the aura bench's HUD compactness rule; against a "
              "1px\n  divider it is not a verdict. Read the gaps, not the flags.\n")
        audit.print_report(audit.build_report(children))

    # ★★★ THE SHOPPING LIST. Not a shortfall - it is the deliverable that makes the
    # offline pass and the live pass one loop: measure these once, and they stop
    # being unknown.
    if unmeasured:
        print("\n=== measure these IN THE CLIENT (text-sized, unknowable offline) ===")
        for name, need, ax, ay in unmeasured:
            at = "" if ax is None else "  anchored at (%.0f, %.0f)" % (ax, ay or 0)
            print("  %-28s needs %s%s" % (name, need, at))

    # ⚠ BY EXCEPTION below here.
    if holes:
        print("\n⚠ could not be placed at all:")
        for h in holes:
            print("    %s - %s" % (h.get("name"), h.get("why")))

    return 1 if holes else 0


if __name__ == "__main__":
    sys.exit(main())
