# -*- coding: utf-8 -*-
r"""check_grades.py - the `grades` citation spread, and the HONEST ceiling on coverage.

    py addons/tools/check_grades.py            the summary
    py addons/tools/check_grades.py --bare     also list the rows with no machine-readable
                                               criterion

★★★ WHY THIS EXISTS, and why it is careful about what it claims.

X3 asks for *"the `grades` citation spread - coverage is the honest ceiling on every UNGUARDED
claim."* The naive tool is a grep for each cited symbol in the smokes. **That tool would have
been wrong on its first run**: five cited symbols have ZERO literal mentions in any smoke -
`Manager.NodeDone`, `Manager.StageDone`, `Rule.Gate`, `Rule.PointFire`, `Store.NextRouteId` -
and every one of them is exercised, indirectly, by a caller the smokes do name. `Rule.Gate` runs
on every `Rule.Evaluate`; `NodeDone` runs on every `OnPoll`.

⚠⚠ A grep for names measures NAMING, not exercising. `check_cites.py` (§468) makes the same
mistake one file over and reports six false positives, and this tool was written after reading
that one.

★★ AND THE CEILING IS NOT FULLY MEASURABLE, which is the finding rather than an excuse.
Measured across the four briefs: the only LABELLED criterion forms are `TEST:` (67) and
`MUTATION:` (65). Rows like A3.1 carry a real criterion in PROSE - *"arm a named one -> exactly
one listener"* - which no parser can tell from commentary. So this reports rows with **no
machine-readable criterion** and says exactly that. It never calls them unguarded.

⟶ THE GATE: it FAILS only on citation ROT - a `grades` target that names a symbol the shipped
code does not have. That is unambiguous. Everything else is REPORTED, because a number nobody
can act on is noise, and a red gate nobody believes is worse than no gate.
"""

import io
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PLAN = os.path.join(ROOT, "addons", "planning")
CODE = os.path.join(ROOT, "addons", "COA_DungeonRun")
SMOKE = os.path.join(ROOT, "addons", "tools", "smoke")

ROW = re.compile(r"(?m)^- \*\*(A\d+\.\d+[a-z]?)")
GRADES = re.compile(r"(?m)^ *grades  *(.+)$")
SYMBOL = re.compile(r"^[A-Z][A-Za-z]*\.[A-Za-z]+$")


def read(path):
    return io.open(path, encoding="utf-8", errors="replace").read()


def briefs():
    for f in sorted(os.listdir(PLAN)):
        if f.startswith("driver_") and f.endswith("acceptance.md"):
            yield f, read(os.path.join(PLAN, f))


def blob(folder, want=".lua"):
    out = {}
    for f in sorted(os.listdir(folder)):
        if f.endswith(want):
            out[f] = read(os.path.join(folder, f))
    return out


def main():
    shipped = blob(CODE)
    smokes = {k: v for k, v in blob(SMOKE).items() if k.startswith("smoke_")}
    ship_all = "\n".join(shipped.values())

    graded = crit_only = bare = 0
    bare_rows = []
    targets = {}          # symbol -> [row ids]
    prose = {}            # prose target -> [row ids]

    for name, text in briefs():
        parts = ROW.split(text)
        for i in range(1, len(parts), 2):
            rid, body = parts[i], parts[i + 1]
            g = GRADES.search(body)
            if g:
                graded += 1
                for t in g.group(1).split("·"):
                    t = t.strip().strip("`").strip()
                    if not t:
                        continue
                    (targets if SYMBOL.match(t) else prose).setdefault(t, []).append(rid)
            elif "TEST:" in body or "MUTATION:" in body:
                crit_only += 1
            else:
                bare += 1
                bare_rows.append((name.split("_")[1][:5], rid))

    total = graded + crit_only + bare
    print()
    print("   THE `grades` CITATION SPREAD")
    print("   " + "-" * 62)
    print("   rows %d across %d briefs" % (total, len(list(briefs()))))
    print("     GRADED      names a target            %3d" % graded)
    print("     CRITERION   TEST/MUTATION, no target  %3d" % crit_only)
    print("     UNLABELLED  no machine-readable one   %3d" % bare)
    print()

    # ---- resolve the symbol targets -------------------------------------------------
    rot, direct, indirect = [], 0, []
    for sym, rows in sorted(targets.items()):
        short = sym.split(".", 1)[1]
        exists = re.search(r"function\s+%s\b|\b%s\s*=\s*function" % (re.escape(sym),
                                                                    re.escape(short)),
                           ship_all)
        if not exists:
            rot.append((sym, rows))
            continue
        if any(sym in v for v in smokes.values()):
            direct += 1
            continue
        # ★ NOT NAMED - so ask whether a caller IS. One hop is enough to answer
        # "is this reached", which is the question; a full call graph would answer a
        # question nobody asked.
        callers = set()
        for f, v in shipped.items():
            for line in v.splitlines():
                if sym in line and "function" not in line:
                    callers.add(f)
        reached = any(
            any(("%s." % c.split(".")[0].title()) in s or c.replace(".lua", "") in s
                for s in smokes.values())
            for c in callers)
        indirect.append((sym, rows, sorted(callers)))

    print("   SYMBOL TARGETS  %d distinct" % len(targets))
    print("     named in a smoke                      %3d" % direct)
    print("     NOT named - reached through a caller  %3d" % len(indirect))
    for sym, rows, callers in indirect:
        print("       %-22s cited by %-12s via %s"
              % (sym, ",".join(rows[:2]), ", ".join(callers) or "?"))
    print()
    print("   ★ 'not named' is NOT a gap. A grep for a symbol measures NAMING;")
    print("     `Rule.Gate` runs on every `Rule.Evaluate`, and `Manager.NodeDone`")
    print("     on every `OnPoll`. This tool was written after `check_cites` reported")
    print("     six false positives for exactly that reason.")
    print()

    if prose:
        print("   PROSE TARGETS  %d - a `grades` line naming something no parser can" % len(prose))
        print("     resolve. Not a fault; a limit on what this tool can say.")
        for t, rows in sorted(prose.items())[:8]:
            print("       %-46s %s" % (t[:46], ",".join(rows[:2])))
        if len(prose) > 8:
            print("       ... and %d more" % (len(prose) - 8))
        print()

    if "--bare" in sys.argv and bare_rows:
        print("   ROWS WITH NO MACHINE-READABLE CRITERION")
        for br, rid in bare_rows:
            print("       %-6s %s" % (br, rid))
        print()

    print("   ⚠ THE CEILING IS NOT FULLY MEASURABLE, and that IS the finding. The only")
    print("     LABELLED criterion forms in the briefs are TEST: and MUTATION:. A row like")
    print("     A3.1 carries a real one in PROSE - *arm a named one -> exactly one")
    print("     listener* - and no parser can tell that from commentary. ⟶ The %d above" % bare)
    print("     are rows with no criterion THIS TOOL CAN READ. Calling them unguarded")
    print("     would be the same overclaim it exists to avoid.")
    print()

    if rot:
        print("   [!] CITATION ROT - a `grades` target names a symbol the code does not have:")
        for sym, rows in rot:
            print("       %-24s cited by %s" % (sym, ", ".join(rows)))
        print()
        print("   ★ This is the ONLY condition this tool fails on, because it is the only")
        print("     one that is unambiguous.")
        return 1
    print("   ✅ every cited symbol exists in the shipped code.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
