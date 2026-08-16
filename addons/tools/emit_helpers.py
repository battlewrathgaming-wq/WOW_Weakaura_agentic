r"""emit_helpers.py - THE STANDING SURFACE: what needs Battlewrath's hands.

★★★ WHY (Battlewrath, 2026-08-16): *"Can we add a list view to bench. Of the different
helper inputs? So I can see from bench what I need to independently complete a task."*
And, when I tried to fold it into the mailbox: *"Mailbox is a consumable review. I want a
standing surface to see what helper notes we have so I'm not feeling my way through
inputs."*

★★ THE MAILBOX IS CONSUMABLE; THIS IS STANDING. An inbox empties as you read it, which
is right for a handover and useless as a reference - the item you need to remember is
the one you already opened. This file answers a question that never stops being asked:
*what is waiting on ME?*

★★★ IT IS THE BENCH'S OWN CONSTRAINT MADE VISIBLE. `bench.md`: *"Battlewrath is the
hands for the live half."* Every one of these exists because I cannot reach the client.
So this is not a to-do list - it is the boundary of what I can do, printed.

⚠ THE SIGNAL IS DECLARED, NEVER INFERRED. `operations/Addons_load.md` records that
inference over the ★/⚠ markers was tried and MEASURED and does not work - 538 marked
lines encoding recency rather than weight. So a helper input is a line I deliberately
wrote as one, and nothing here guesses.

    ☛ GAME    <text>      needs the client OPEN - a capture, a look, a test
    ☛ CLOSED  <text>      needs the client CLOSED - a deploy, a wipe
    ☛ RULING  <text>      needs your eye on something that is already lookable

★★ GROUPED BY YOUR CONTEXT, NOT BY MINE. The grouping is the whole point: you batch by
where you are - in the game, out of it, or at the bench - rather than reading a flat
list and sorting it yourself every time. ⚠ A file/section is shown so you can find the
thing, never so you have to go read it first.

    py addons/tools/emit_helpers.py           the standing list
    py addons/tools/emit_helpers.py --quiet   nothing when there is nothing
"""

import argparse
import io
import os
import re
import sys

# ⚠ The bench terminal is a Windows console and defaults to cp1252, which cannot encode
# the markers these notes are written with. Same line `check_interface.py` carries, and
# for the same reason: the tool must not die on the punctuation of its own input.
sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__)).replace("\\", "/")
ROOT = os.path.dirname(os.path.dirname(HERE))

# ★ WHERE IT LOOKS. The planning surfaces, the model, the scopes and the lane ledger -
# every place a helper input could honestly be written. ⚠ NOT the code: a marker in a
# .lua would be read by the game, and a comment nobody emits is the stored-field-isn't-
# live fault. Docs only, and the doc is where the reasoning already lives.
ROOTS = [
    "addons/planning",
    "operations",
]

MARK = "☛"
KINDS = [
    ("GAME",   "IN GAME", "client OPEN - captures, looks, tests"),
    ("CLOSED", "GAME CLOSED", "deploys, wipes, installs"),
    ("RULING", "YOUR EYE", "already lookable, waiting on a call"),
]

ROW = re.compile("^\\s*" + MARK + "\\s*(GAME|CLOSED|RULING)\\b[:\\s]*(.*)$")


def files():
    out = []
    for r in ROOTS:
        base = os.path.join(ROOT, r)
        for dirpath, dirnames, names in os.walk(base):
            dirnames[:] = [d for d in dirnames if d not in ("archive", "devlog")]
            for n in sorted(names):
                if n.endswith(".md"):
                    out.append(os.path.join(dirpath, n))
    return out


def scan():
    """Returns {kind: [(text, where, line)]}.

    ★ A continuation line is indented EXACTLY TWO SPACES past the marker's own indent,
    so a note can carry its reason without repeating itself.

    ⚠ "Merely indented" was the first cut and it was wrong: these notes live INSIDE the
    surface files, where a control's `numbers` line sits 20 columns in - so the first
    Promotion note ate the row beneath it. **A note that absorbs its neighbours reports
    something nobody wrote.** The rule is exact, not relative."""
    found = dict((k, []) for k, _, _ in KINDS)
    for path in files():
        rel = os.path.relpath(path, ROOT).replace("\\", "/")
        try:
            lines = io.open(path, encoding="utf-8").read().split("\n")
        except Exception:
            continue
        i = 0
        while i < len(lines):
            m = ROW.match(lines[i].rstrip())
            if not m:
                i += 1
                continue
            kind, text = m.group(1), m.group(2).strip()
            base = len(lines[i]) - len(lines[i].lstrip())
            want = " " * (base + 2)
            n = i + 1
            i += 1
            while i < len(lines):
                nxt = lines[i].rstrip()
                ind = len(nxt) - len(nxt.lstrip())
                if nxt.strip() and ind == len(want) and not ROW.match(nxt):
                    text += " " + nxt.strip()
                    i += 1
                else:
                    break
            found[kind].append((text, rel, n))
    return found


def main():
    ap = argparse.ArgumentParser(description="what needs Battlewrath's hands")
    ap.add_argument("--quiet", action="store_true",
                    help="print nothing when nothing is waiting")
    a = ap.parse_args()

    found = scan()
    total = sum(len(v) for v in found.values())

    if not total:
        if not a.quiet:
            print("")
            print("   Nothing is waiting on you.")
            print("")
        return 0

    print("")
    print("   WHAT NEEDS YOUR HANDS  -  %d item(s)" % total)
    print("   " + "-" * 62)
    for key, title, hint in KINDS:
        rows = found[key]
        if not rows:
            continue
        print("")
        print("   %s   (%s)" % (title, hint))
        for text, rel, n in rows:
            print("")
            print("     - " + text)
            print("       %s:%d" % (rel, n))
    print("")
    # ⚠ NOT an exit code. This reports a boundary, it does not fail - a bench key that
    # returns non-zero because you have not been in the game yet would be nonsense.
    return 0


if __name__ == "__main__":
    sys.exit(main())
