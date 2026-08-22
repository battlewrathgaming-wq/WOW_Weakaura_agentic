# -*- coding: utf-8 -*-
r"""_mutate_checkers_selftest.py - does `mutate_checkers.py` obey its OWN rules?

    py addons/tools/_mutate_checkers_selftest.py

★★★ WHY THIS EXISTS AND THE HARNESS ALONE IS NOT ENOUGH. `mutate_checkers.py` REWRITES
REAL CHECKERS ON DISK. Two of its promises are the dangerous ones, and neither is visible in a green run:

    A ROTTED ANCHOR FAILS      when a tool is edited its mutations stop matching. A harness that
                               skips those quietly reports "all bit" while testing fewer guards
                               every week - the inert-guard shape it was built to catch.
    THE RESTORE IS VERIFIED    if a run dies between the write and the restore, a MUTATED checker
                               is left on the desk printing green. That is worse than no checker.

⟶ Both are properties of the FAILURE path, so a passing run proves nothing about them. This file
drives each one on purpose. ★ Same reason `.claude/hooks/_selftest.js` exists next to the hook.

⚠ It deliberately breaks `mutate_checkers.py` (a bogus anchor) and restores it in a
`finally`, then hashes EVERY `.py` on the desk before and after to prove nothing was left mutated.
"""

import hashlib
import io
import os
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))
P = os.path.join(HERE, "mutate_checkers.py")
GOOD = io.open(P, encoding="utf-8").read()


def digest():
    return {f: hashlib.sha256(io.open(os.path.join(HERE, f), "rb").read()).hexdigest()[:12]
            for f in sorted(os.listdir(HERE)) if f.endswith(".py")}


def run(*args):
    r = subprocess.run([sys.executable, P] + list(args), capture_output=True, text=True,
                       encoding="utf-8", errors="replace")
    return r.stdout, r.returncode


def main():
    before, ok = digest(), []
    print("")
    print("   MUTATE SELF-TEST - the two promises that a green run cannot show")
    print("   " + "-" * 66)
    try:
        # 1 · A ROTTED ANCHOR IS REPORTED AND FAILS THE RUN
        bogus = ('MUTATIONS = (\n ("check_inbox.py", "a guard that no longer exists",\n'
                 '  "THIS_STRING_IS_NOT_IN_ANY_FILE", "x"),\n')
        io.open(P, "w", encoding="utf-8", newline="\n").write(
            GOOD.replace("MUTATIONS = (\n", bogus, 1))
        out, code = run()
        ok.append(("a rotted anchor is NAMED in the report",
                   "ANCHOR x0" in out and "the tool moved and the mutation did not" in out))
        ok.append(("a rotted anchor FAILS the run (never a skip)", code != 0))

        # 2 · --tool NARROWS, so a desk-wide harness stays usable on one file
        io.open(P, "w", encoding="utf-8", newline="\n").write(GOOD)
        out, _ = run("--tool", "check_inbox")
        ok.append(("--tool narrows to one file",
                   "check_acceptance" not in out and "1 mutation " in out))
    finally:
        io.open(P, "w", encoding="utf-8", newline="\n").write(GOOD)

    # 3 · NOTHING ON THE DESK MOVED. The promise that matters most.
    moved = [f for f in before if before[f] != digest().get(f)]
    ok.append(("every tool on the desk is byte-identical afterwards", not moved))

    for label, good in ok:
        print("   %-52s %s" % (label, "✅" if good else "⚠ FAILED"))
    bad = [l for l, g in ok if not g]
    if moved:
        print("")
        print("   [!!!] LEFT MUTATED ON DISK: %s" % ", ".join(moved))
        print("         `git checkout -- addons/tools/` before running anything else.")
    print("")
    print("   %d of %d held.%s" % (len(ok) - len(bad), len(ok),
                                   "" if not bad else "  ⚠ THE HARNESS IS NOT SAFE TO RUN."))
    print("")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
