# -*- coding: utf-8 -*-
r"""grades_candidates.py - which acceptance rows COULD carry a `grades` line, and what
the evidence for each would be.

    py addons/tools/grades_candidates.py

★★★ WHY THIS EXISTS RATHER THAN A HAND PASS.

`emit_built_state.py` joins a criterion to the code it grades through ONE explicit line:

        grades  <Module>.<Fn> · <Module>.<Fn>

⚠⚠ PLACEHOLDERS ON PURPOSE. This docstring first used two REAL function names, and
`emit_built_state.py` scans `tools/` for callers - so the emitted built state gained this
file as a CALLER of both. **A tool that describes the corpus must not appear in it.**

Most acceptance rows carry no such line, so most of the acceptance cannot be joined to
code at all.
Spreading them is the unblocked work - but ⚠ **a WRONG citation is worse than none**: it
claims a criterion guards a function nobody tested, which is precisely the "green that
means less than it looks like" this project keeps finding.

★ So this tool does the MECHANICAL half only and refuses the judgement half. For each row
without a `grades` line it prints:

    the row's own text mentions        every `Module.Fn` named in the row, backticked or not
    the SMOKE that cites the row       any smoke file whose text names the row id
    what that smoke CALLS nearby       `Module.Fn(` calls within the cited block

⚠ **It proposes nothing.** A name appearing in a row's prose is not evidence the row grades
it - these documents discuss functions constantly, which is the exact reason the marker is
explicit. The author reads the row, reads the smoke block, and decides.

⚠ IT PRINTS NO COVERAGE NUMBER, deliberately. An earlier version did, and it disagreed
with the emitter's (19 against 17 - this file double-counts a row id that appears twice)
while its own docstring claimed the two could not drift. **One authority for that number,
and it is `emit_built_state.py`.**
"""
import io
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PLAN = os.path.join(ROOT, "planning")
SMOKE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "smoke")

ACCEPTANCE = ("driver_authoring_acceptance.md", "driver_walk_acceptance.md",
              "driver_ui_acceptance.md", "driver_sense_acceptance.md")

ROW = re.compile(r"\*\*((?:A|W)\d+\.\d+[a-z]?)\b")
GRADES = re.compile(r"^\s+grades\s+", re.M)
FN = re.compile(r"([A-Z]\w*\.[A-Za-z_]\w*)")
CALL = re.compile(r"([A-Z]\w*\.[A-Za-z_]\w*)\s*\(")


def rows(path):
    """-> [(row_id, text)] split at each row marker, in file order."""
    raw = io.open(path, encoding="utf-8", errors="replace").read()
    marks = [(m.start(), m.group(1)) for m in ROW.finditer(raw)]
    out = []
    for i, (pos, rid) in enumerate(marks):
        end = marks[i + 1][0] if i + 1 < len(marks) else len(raw)
        out.append((rid, raw[pos:end]))
    return out


def smoke_text():
    out = {}
    for f in sorted(os.listdir(SMOKE)):
        if f.endswith(".lua"):
            out[f] = io.open(os.path.join(SMOKE, f), encoding="utf-8",
                             errors="replace").read()
    return out


def main():
    smokes = smoke_text()
    total = mapped = 0
    print("")
    print("   GRADES CANDIDATES - the mechanical half only; the judgement is the author's")
    print("   " + "-" * 70)
    for name in ACCEPTANCE:
        path = os.path.join(PLAN, name)
        if not os.path.exists(path):
            continue
        printed = False
        for rid, text in rows(path):
            total += 1
            if GRADES.search(text):
                mapped += 1
                continue
            named = sorted(set(FN.findall(text)))
            cites = []
            for fn, body in smokes.items():
                if rid in body:
                    # the calls in the 40 lines after the row's first mention
                    i = body.index(rid)
                    near = body[i:i + 2500]
                    cites.append((fn, sorted(set(CALL.findall(near)))))
            if not named and not cites:
                continue
            if not printed:
                print("")
                print("   %s" % name)
                printed = True
            print("     %-8s row names: %s" % (rid, " · ".join(named[:6]) or "-"))
            for fn, calls in cites:
                print("              %-32s calls: %s"
                      % (fn, " · ".join(calls[:6]) or "-"))
    print("")
    print("   %d row(s) listed above have no `grades` line and something to judge."
          % (total - mapped))
    print("   ⚠ FOR THE COVERAGE NUMBER run `emit_built_state.py` - it is the authority,")
    print("     and this tool deliberately does not print a rival one.")
    print("   ⚠ A name in a row's prose is NOT evidence. Read the row, read the smoke")
    print("     block, then add the line - or leave the row UNMAPPED, which is honest.")
    print("")
    return 0


if __name__ == "__main__":
    sys.exit(main())
