r"""read_sketch.py - read a dragged board and normalise the mouse out of it.

★★★ WHY (Battlewrath, 2026-08-16): *"These aren't absolutes. Geometry tool should help
normalize out human - using a mouse inaccuracies to same forms."*

A sketch is INTENT expressed through a mouse. Dragging two controls to "the same left
edge" lands them at 16 and 17; dragging a button "next to" another leaves a 5px gap
where every other pair in the addon uses 6. ⚠ Reading those numbers literally ships the
tremor: it turns a hand movement into a constant, and then the constant is defended.

★ SO THE TOOL LOOKS FOR THE FORM, NOT THE NUMBER. Values that cluster inside the
tolerance were meant to be one value. A gap near a house constant was meant to be that
constant. Everything it changes, it SAYS - a normaliser that silently rounds is worse
than a literal reading, because the literal one at least matches what he dragged.

⚠ IT NORMALISES, IT DOES NOT DESIGN. If two edges are 20 apart they stay 20 apart; the
tool has no opinion about whether that is right. Only near-misses collapse, because only
a near-miss is evidence of an intended sameness.

    py addons/tools/read_sketch.py [board.json] [--against <measured.json>] [--tol 3]
"""

import argparse
import collections
import glob
import io
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__)).replace("\\", "/")
ROOT = os.path.dirname(os.path.dirname(HERE))
BOARDS = HERE + "/PaneBoard/workspace/pane-board"

# ⚠ OURS, read from layout.lua rather than typed here - a normaliser that invents its
# own spacing constants is the drift it exists to prevent.
def house_gaps():
    t = io.open(ROOT + "/addons/COA_DungeonRun/layout.lua", encoding="utf-8").read()
    out = {}
    for name in ("GAP", "ROW_GAP", "ZONE_GAP"):
        for line in t.splitlines():
            s = line.strip()
            if s.startswith("local %s" % name) or s.startswith("%s," % name) or \
                    s.startswith("Layout.%s" % name):
                for tok in s.replace("=", " ").replace(",", " ").split():
                    if tok.isdigit():
                        out[name] = int(tok)
                        break
            if name in out:
                break
    return out


def cluster(values, tol):
    """Group near-equal values. The representative is the most common member, so a
    line three controls agree on wins over the one that drifted."""
    groups, out = [], {}
    for v in sorted(values):
        if groups and v - groups[-1][-1] <= tol:
            groups[-1].append(v)
        else:
            groups.append([v])
    for g in groups:
        rep = collections.Counter(g).most_common(1)[0][0]
        for v in g:
            out[v] = rep
    return out


def read(board_path, measured_path, tol):
    board = json.load(io.open(board_path, encoding="utf-8"))
    base = {}
    if measured_path and os.path.isfile(measured_path):
        for p in json.load(io.open(measured_path, encoding="utf-8"))["panes"]:
            base[p["id"]] = p["grid"]

    gaps = house_gaps()
    panes = [p for p in board["panes"] if p.get("importance") != "backing"]
    vw = board["viewport"]["width"]
    vh = board["viewport"]["height"]

    lefts = cluster([p["grid"]["x"] for p in panes], tol)
    rights = cluster([p["grid"]["x"] + p["grid"]["w"] for p in panes], tol)
    widths = cluster([p["grid"]["w"] for p in panes], tol)
    tops = cluster([p["grid"]["y"] for p in panes], tol)

    notes, rows = [], []
    for p in sorted(panes, key=lambda p: (p["grid"]["y"], p["grid"]["x"])):
        g = dict(p["grid"])
        was = dict(g)

        # ★ WIDTH FIRST, then the left edge, then the right edge - in that order,
        # because a width change moves the right edge and re-deciding it afterwards
        # would silently undo the width the sketch asked for.
        if widths[g["w"]] != g["w"]:
            notes.append("%s width %d -> %d (agrees with %d other control(s))"
                         % (p["label"], g["w"], widths[g["w"]],
                            sum(1 for q in panes if q["grid"]["w"] == widths[g["w"]])))
            g["w"] = widths[g["w"]]
        if lefts[was["x"]] != was["x"]:
            notes.append("%s left %d -> %d (shared edge)" % (p["label"], was["x"], lefts[was["x"]]))
            g["x"] = lefts[was["x"]]
        r = was["x"] + was["w"]
        if rights[r] != r and lefts[was["x"]] == was["x"]:
            notes.append("%s right %d -> %d (shared edge)" % (p["label"], r, rights[r]))
            g["w"] = rights[r] - g["x"]
        if tops[was["y"]] != was["y"]:
            notes.append("%s top %d -> %d (shared line)" % (p["label"], was["y"], tops[was["y"]]))
            g["y"] = tops[was["y"]]
        rows.append((p, g, was))

    # ---- gaps, once the edges have settled ---------------------------------
    #
    # ★★★ A SHARED EDGE OUTRANKS A GAP, AND THAT RULE HAD TO BE LEARNED. The first cut
    # closed every gap by nudging the RIGHT-HAND control - which on the Remote pushed
    # `arm` off the 224 line it shared with `pin` and `name` to buy 1px of gap. It
    # solved the smaller problem by breaking the larger one.
    #
    # ⚠ An edge two or more controls sit on is LOAD-BEARING: it is the alignment the
    # eye reads down the pane. A gap is a local relationship between two neighbours. So
    # when a gap needs a pixel, it comes out of whichever side is not holding a line.
    # ⚠⚠ COUNTED OVER CONTROLS, NOT OVER THE CLUSTER DICT. The first version counted
    # `rights.values()` - and that dict is keyed by VALUE, so three controls agreeing
    # EXACTLY on 224 collapse into one entry and the edge never looked shared. The test
    # was inverted in the worst way: it recognised an edge only when the controls
    # DISAGREED enough to make separate keys, which is the one case it should not fire.
    edge_use = collections.Counter()
    for p in panes:
        edge_use[lefts[p["grid"]["x"]]] += 1
        edge_use[rights[p["grid"]["x"] + p["grid"]["w"]]] += 1
    shared = {v for v, n in edge_use.items() if n >= 2}

    by_row = collections.defaultdict(list)
    for p, g, _ in rows:
        by_row[g["y"]].append((p, g))
    for y, group in sorted(by_row.items()):
        group.sort(key=lambda t: t[1]["x"])
        for (pa, ga), (pb, gb) in zip(group, group[1:]):
            gap = gb["x"] - (ga["x"] + ga["w"])
            if gap <= 0:
                notes.append("⚠ %s and %s OVERLAP by %d px - left alone, that is a "
                             "decision not a tremor" % (pa["label"], pb["label"], -gap))
                continue
            for name, want in sorted(gaps.items(), key=lambda kv: kv[1]):
                if gap == want or abs(gap - want) > tol:
                    continue
                move = want - gap
                b_holds = (gb["x"] + gb["w"]) in shared
                a_holds = ga["x"] in shared
                if b_holds and not a_holds:
                    ga["x"] -= move
                    who = "%s %s %d" % (pa["label"],
                                        "left" if move > 0 else "right", abs(move))
                else:
                    gb["x"] += move
                    who = "%s %s %d" % (pb["label"],
                                        "right" if move > 0 else "left", abs(move))
                notes.append("%s -> %s gap %d -> %d (Layout.%s) - %s%s"
                             % (pa["label"], pb["label"], gap, want, name, who,
                                "; the other side holds a shared edge"
                                if (b_holds != a_holds) else ""))
                break

    print("")
    print("  %s   %s   viewport %dx%d   tolerance %dpx"
          % (board.get("title"), board.get("status"), vw, vh, tol))
    print("  house gaps: %s" % ", ".join("%s %d" % kv for kv in sorted(gaps.items())))
    print("")
    print("  %-14s %-16s %-16s %-16s" % ("control", "measured", "you dragged", "normalised"))
    for p, g, was in rows:
        b = base.get(p["id"])
        f = lambda d: "%d,%d %dx%d" % (d["x"], d["y"], d["w"], d["h"])
        flag = "" if g == was else "  <- moved"
        print("  %-14s %-16s %-16s %-16s%s"
              % (p["label"], f(b) if b else "(new)", f(was), f(g), flag))
    print("")
    if notes:
        print("  NORMALISED - every change, stated:")
        for n in notes:
            print("    %s" % n)
    else:
        print("  Nothing to normalise: every edge, width and gap already agrees.")
    print("")

    # ---- and the numbers a SetPoint actually wants --------------------------
    print("  anchors (both forms - pick whichever the source already uses):")
    print("  %-14s %-22s %-22s" % ("control", "TOPLEFT", "BOTTOMRIGHT"))
    for p, g, _ in rows:
        print("  %-14s (%d, %d)  w %d%s(-%d, %d)"
              % (p["label"], g["x"], -g["y"], g["w"], " " * max(1, 12 - len(str(g["w"]))),
                 vw - (g["x"] + g["w"]), vh - (g["y"] + g["h"])))
    print("")
    return rows


def main():
    ap = argparse.ArgumentParser(add_help=False)
    ap.add_argument("board", nargs="?", default=BOARDS + "/current-board.json")
    ap.add_argument("--against", default="")
    ap.add_argument("--tol", type=int, default=3)
    a = ap.parse_args()
    against = a.against
    if not against:
        title = json.load(io.open(a.board, encoding="utf-8")).get("id", "")
        guess = glob.glob(BOARDS + "/agent-proposals/%s.json" % title)
        against = guess[0] if guess else ""
    read(a.board, against, a.tol)


if __name__ == "__main__":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    main()
