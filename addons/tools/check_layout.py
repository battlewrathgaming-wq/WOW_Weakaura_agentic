# -*- coding: utf-8 -*-
r"""check_layout - contradict a DECLARED pane layout before anything is built from it.

★★★ WHY THIS EXISTS, and it is not "we lacked a checker" - we had THREE.
  `smoke/frames.lua`     F.Overlaps · F.Outside · F.Containment · F.OverlapsTree - uncalled
  `layout_audit.py`      overlaps() · outside() · from_frames() - on THIS desk, since 2026-08-15
  `task_sheet.lua`       the same predicate hand-retyped inside the range block
⟶ **The failure was never capability. It was REACH.** Five boards were placed on the UI test sheet
by hand across three turns, the frame was grown and shrunk twice, and none of the three was asked.

⚠⚠ AND THIS FILE WROTE A FOURTH COPY BEFORE THE TOOL INDEX CAUGHT IT. The `tools` skill exists for
exactly that and says *"use before creating any tool or checker"*; it was not run. `layout_audit`
even documents the sign fact this file's first `rect()` got wrong: *"f['y'] is already negative
going down"*. ⟶ **So the geometry below is IMPORTED, not written.** What is left here is the part
that was genuinely missing: reading a DECLARATION rather than a built pane, grouping by page, and
reporting the SIZE of a collision rather than only its name.

⚠⚠ So this is a tool for the CREATION moment, not the review moment - Battlewrath, 2026-08-25:
*"I'd wrap it into a single tool you use in the creation process. Callable in skills so you see
it."* It is fronted by the `layout` skill, whose description is pushed into every session, because
a flag on another tool is a flag you have to remember exists.

★ WHAT IT DOES NOT DO, deliberately:
  - it does NOT argue a size. `UL-16`: a measurement is of TODAY and never a constraint on the
    design. A machine that picks a pane size promotes a fits-today number into a rule.
  - it does NOT lay out. AceGUI publishes Flow/List/Fill/Table; ours would be a coat.
It declares nothing and decides nothing. **It contradicts a declaration, or it stays quiet.**

USAGE
    py addons/tools/check_layout.py                 the UI test sheet's `pane` kind
    py addons/tools/check_layout.py --json FILE     any layout in the same shape
    py addons/tools/check_layout.py --quiet         exit code only (0 clean, 1 findings)

THE SHAPE
    sheet  { w, h }
    title  { x, y }                       optional
    strip  { x, y, w, h, gap, n }         optional - a row of n boxes
    page   { x, y, w, h }                 the box every board must sit inside
    boards [ { page, name, x, y, w, h } ] y is NEGATIVE-DOWN, as SetPoint takes it
    arms   [ { board, name, x, y, w, h } ] what sits INSIDE a board, relative to it
"""
import argparse
import json
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

REPO = Path(__file__).resolve().parents[2]
# ⚠ The codec-proven Lua parser lives on the Weak Auras desk, not this one. Reached the same
# way `check_sheet.py:58` reaches it - one parser, not a second one written here.
sys.path.insert(0, str(REPO / "Weak Auras"))
DECL = REPO / "addons" / "COA_DevDump" / "sheet_decl.lua"


# ★ IMPORTED, not written. `layout_audit` is this desk's own, copied from the aura bench on
# 2026-08-15, and its pipeline takes exactly the shape a `pane` board already has:
#   from_frames({name,x,y,width,height})  ->  build_inventory  ->  {left,right,top,bottom}
from layout_audit import from_frames, build_inventory  # noqa: E402


def boxes(items):
    """`pane`-shaped boards -> rects, through the existing module. No geometry of our own.

    ⚠ `from_frames` returns (inventory, unknown); a board with no width or height is NOT
    MEASURABLE and is named rather than defaulted to zero - a zero-sized box overlaps nothing
    and would read as a clean layout.
    """
    inv, unknown = from_frames(items)
    return build_inventory(inv), unknown


def overlaps(rs):
    """Pairs sharing a PIXEL, WITH the size of the collision in both axes.

    ⚠ `layout_audit.overlaps` reports pairs only - correct for its job, and not enough here:
    an 88 x 96 collision and a 1 x 1 collision need different responses, and a name cannot
    tell you which you have. Same predicate, more of the answer.
    ⚠ A shared EDGE is not an overlap - abutting is legal and flagging it would make the tool
    noise on every well-packed layout.
    """
    hits = []
    for i in range(len(rs)):
        for j in range(i + 1, len(rs)):
            a, b = rs[i], rs[j]
            if (a["left"] < b["right"] and b["left"] < a["right"]
                    and a["bottom"] < b["top"] and b["bottom"] < a["top"]):
                hits.append((a["id"], b["id"],
                             min(a["right"], b["right"]) - max(a["left"], b["left"]),
                             min(a["top"], b["top"]) - max(a["bottom"], b["bottom"])))
    return hits


def outside(rs, box):
    """Which side each box leaves its container by, and how far.

    ⚠ `layout_audit.outside` returns names against a width/height; this needs a BOX (a page
    is offset inside its sheet) and the DIRECTION, because "it overhangs" does not tell you
    whether to move it or shrink it.
    """
    bad = []
    for r in rs:
        over = []
        if r["left"] < box["left"]:
            over.append(f"left by {box['left'] - r['left']:.0f}")
        if r["right"] > box["right"]:
            over.append(f"right by {r['right'] - box['right']:.0f}")
        if r["top"] > box["top"]:
            over.append(f"top by {r['top'] - box['top']:.0f}")
        if r["bottom"] < box["bottom"]:
            over.append(f"bottom by {box['bottom'] - r['bottom']:.0f}")
        if over:
            bad.append((r["id"], ", ".join(over)))
    return bad


def read_pane_from_lua():
    """Read the `pane` kind out of sheet_decl.lua with the codec-proven parser, not a regex."""
    from lua_table import parse_file, LuaParseError  # noqa: E402
    try:
        decl = parse_file(str(DECL)).get("COA_UI_SHEET")
    except LuaParseError as e:
        print(f"check_layout: {DECL.name} did not parse - {e}")
        return None
    if not decl or "pane" not in decl:
        print(f"check_layout: {DECL.name} declares no `pane` kind")
        return None
    return decl["pane"]


def check(pane, quiet=False):
    findings = 0
    sheet = pane.get("sheet") or {}
    page = pane.get("page") or {}
    SW, SH = int(sheet.get("w", 0)), int(sheet.get("h", 0))

    if not quiet:
        print(f"layout       sheet {SW} x {SH}")

    # ---- the page box, and the furniture that shares the sheet with it
    sheet_box = boxes([{"name": "sheet", "x": 0, "y": 0, "width": SW, "height": SH}])[0][0]
    items = []
    if pane.get("page"):
        items.append({"name": "page", "x": int(page["x"]), "y": int(page["y"]),
                      "width": int(page["w"]), "height": int(page["h"])})
    strip = pane.get("strip")
    if strip:
        for i in range(int(strip.get("n", 1))):
            items.append({"name": f"strip[{i + 1}]",
                          "x": int(strip["x"]) + i * int(strip.get("gap", strip["w"])),
                          "y": int(strip["y"]),
                          "width": int(strip["w"]), "height": int(strip["h"])})
    furniture, unknown = boxes(items)
    for name in unknown:
        findings += 1
        print(f"  ⚠ UNSIZED   {name} has no width or height - NOT MEASURABLE, not zero")

    for a, b, ow, oh in overlaps(furniture):
        findings += 1
        print(f"  ⚠ OVERLAP   {a} x {b}   by {ow:.0f} x {oh:.0f}")
    for name, how in outside(furniture, sheet_box):
        findings += 1
        print(f"  ⚠ OUTSIDE   {name} leaves the sheet: {how}")

    # ---- boards, per page, inside the page box
    boards = pane.get("boards") or []
    pages = sorted({int(b["page"]) for b in boards})
    page_box = boxes([{"name": "page", "x": 0, "y": 0,
                       "width": int(page.get("w", 0)), "height": int(page.get("h", 0))}])[0][0]
    for pg in pages:
        rs, un = boxes([{"name": b["name"], "x": int(b["x"]), "y": int(b["y"]),
                         "width": int(b["w"]), "height": int(b["h"])}
                        for b in boards if int(b["page"]) == pg])
        for name in un:
            findings += 1
            print(f"  ⚠ UNSIZED   page {pg}:  {name} has no width or height")
        if not quiet:
            used_w = max((r["right"] for r in rs), default=0)
            used_h = max((-r["bottom"] for r in rs), default=0)
            print(f"  page {pg}      {len(rs)} board(s)"
                  f"   uses {used_w:.0f} x {used_h:.0f}"
                  f"   of {page_box['right']:.0f} x {-page_box['bottom']:.0f}")
        for a, b, ow, oh in overlaps(rs):
            findings += 1
            print(f"  ⚠ OVERLAP   page {pg}:  {a} x {b}   by {ow:.0f} x {oh:.0f}")
        for name, how in outside(rs, page_box):
            findings += 1
            print(f"  ⚠ OUTSIDE   page {pg}:  {name} leaves the page: {how}")

    # ---- arms, per board, inside the BOARD box (v14, 2026-08-26)
    #
    # ★★★ THIS CLOSES THIS TOOL'S OWN STATED BLIND SPOT, and it closes it because the
    # blind spot bit THREE TIMES IN TWO HOURS: the seated arm overflowed a 264 board; the
    # host board was declared and never built so two captures drew on UIParent; and the arms
    # overflowed again after that board moved pages. ⚠ The first was found by arithmetic,
    # the second by Battlewrath's eye, the third by reading a screenshot. None by a checker.
    #
    # ★ THE TOOL WAS NEVER AT FAULT - it said plainly that it had *"no view of a FontString
    # wider than the board it sits in"*. What changed is that the arms are DECLARED now, so
    # there is something to contradict. A hand-placed offset can only ever be reviewed.
    arms = pane.get("arms") or []
    by_board = {}
    for a in arms:
        by_board.setdefault(a["board"], []).append(a)

    board_by_name = {b["name"]: b for b in boards}
    for bname in sorted(by_board):
        parent = board_by_name.get(bname)
        if not parent:
            findings += 1
            print(f"  ⚠ NO BOARD   arms name `{bname}`, which is not a declared board")
            continue
        # ⚠ THE BOARD IS THE CONTAINMENT BOX, exactly as a page is for a board. Its own x/y
        # on the page are irrelevant here - an arm's coordinates are relative to it.
        parent_box = boxes([{"name": bname, "x": 0, "y": 0,
                             "width": int(parent["w"]),
                             "height": int(parent["h"])}])[0][0]
        rs, un = boxes([{"name": a["name"], "x": int(a["x"]), "y": int(a["y"]),
                         "width": int(a["w"]), "height": int(a["h"])}
                        for a in by_board[bname]])
        for name in un:
            findings += 1
            print(f"  ⚠ UNSIZED   {bname}:  arm {name} has no width or height")
        if not quiet:
            used_w = max((r["right"] for r in rs), default=0)
            used_h = max((-r["bottom"] for r in rs), default=0)
            print(f"  {bname:<12}{len(rs)} arm(s)"
                  f"   uses {used_w:.0f} x {used_h:.0f}"
                  f"   of {parent_box['right']:.0f} x {-parent_box['bottom']:.0f}")
        for a, b, ow, oh in overlaps(rs):
            findings += 1
            print(f"  ⚠ OVERLAP   {bname}:  {a} x {b}   by {ow:.0f} x {oh:.0f}")
        for name, how in outside(rs, parent_box):
            findings += 1
            print(f"  ⚠ OUTSIDE   {bname}:  arm {name} leaves the board: {how}")

    if findings == 0 and not quiet:
        # ⚠ Says what it CHECKED, not "ok". A clean bill that does not name its coverage is
        # indistinguishable from a checker that ran on nothing.
        print(f"  ✅ no overlap and no overhang across {len(boards)} board(s)"
              f" on {len(pages)} page(s), {len(arms)} arm(s)"
              f" + {len(furniture)} piece(s) of sheet furniture")
    return findings


def main():
    ap = argparse.ArgumentParser(description="contradict a declared pane layout")
    ap.add_argument("--json", help="read a layout from a JSON file instead of sheet_decl.lua")
    ap.add_argument("--quiet", action="store_true", help="findings only; exit 1 if any")
    args = ap.parse_args()

    pane = json.loads(Path(args.json).read_text(encoding="utf-8")) if args.json \
        else read_pane_from_lua()
    if not pane:
        return 2
    return 1 if check(pane, args.quiet) else 0


if __name__ == "__main__":
    sys.exit(main())
