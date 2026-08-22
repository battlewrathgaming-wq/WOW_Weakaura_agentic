# -*- coding: utf-8 -*-
r"""mutate.py - break each guard on this desk and watch it BITE.

    py addons/tools/mutate.py                  every declared mutation
    py addons/tools/mutate.py --tool X         one tool
    py addons/tools/mutate.py --diff           show what changed when a mutation bit

★★★ WHY THIS EXISTS. [[mutation-tests-find-weak-tests]] - the yield is BAD TESTS, not bad code, and
this bench has now put SIX guards into service that printed green while checking nothing:

    §457 · §458 · §465 · §472 · §511   five went inert after the thing they watched moved
    §525                               one was proposed DELIBERATELY, and measurement stopped it

⟶ A checker is code like any other, and nobody was checking the checkers. The question this answers
is the only one that matters about a guard: **if I break it, does anything notice?**

★ THE SIGNATURE IS THE WHOLE OUTPUT. A mutation BIT if stdout or the exit code changed at all; it
was SILENT if the tool printed byte-identical text with a broken guard. ⟶ No per-tool comparator to
write, and therefore no per-tool comparator to get wrong - the only per-tool part is DATA, below.

⚠⚠ A MISSING ANCHOR IS A FAILURE, NEVER A SKIP. When a tool is edited its mutations rot, and a
harness that quietly skips a rotted mutation is the exact inert-guard shape it exists to catch. It
reports and exits non-zero. ★ The one rule this file must never break is its own.

⚠⚠⚠ IT EDITS REAL TOOLS ON DISK. Every write is inside `try/finally`, the original bytes are held
in memory, and the restore is VERIFIED byte-for-byte before it reports. If a restore ever fails it
says so first and loudest, because a mutated checker left on disk is worse than no checker.

⚠ WHAT A `SILENT` RESULT MEANS - and it is not always a defect. A guard can be UNREACHED rather
than wrong: `check_acceptance`'s CITE boundaries are kept although nothing in this corpus reaches
them, because the substring-for-word fault they guard already cost that file a false finding.
⟶ SILENT is a fact to RECORD in the tool, never a number to make go away.
"""

import io
import os
import re
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))

# =====================================================================================
# THE DECLARATION - the only per-tool part. (tool, label, find, replace)
#
# ★ WRITE THE MUTATION A REAL AUTHOR WOULD MAKE: drop a boundary, widen a scope, delete a
#   clause of a condition. A mutation nobody would ever type proves nothing about the guard.
# ⚠ ONE GUARD PER ENTRY. Breaking two at once cannot tell you which one bit.
# =====================================================================================
MUTATIONS = (
 ("check_acceptance.py", "ROW loses the -R tail (the hyphen truncation)",
  'ROW = re.compile(r"^- \\*\\*(A[0-9][0-9.a-z]*(?:-[A-Z])?)")',
  'ROW = re.compile(r"^- \\*\\*(A[0-9][0-9.a-z]*)")'),

 ("check_acceptance.py", "CITE loses the -R tail (citations mis-attributed)",
  r'CITE = re.compile(r"\bA[0-9]+\.[0-9]+[a-z]?(?:-[A-Z])?\b")',
  r'CITE = re.compile(r"\bA[0-9]+\.[0-9]+[a-z]?\b")'),

 ("check_acceptance.py", "CITE_DIRS drops the smokes (scope narrowed)",
  'CITE_DIRS = (SOURCE, os.path.join(ROOT, "tools", "smoke"))',
  'CITE_DIRS = (SOURCE,)'),

 ("check_acceptance.py", "the queue stops excluding STATED rows",
  "if status_of(head) or not GRADES.search(body) or rid not in cites:",
  "if not GRADES.search(body) or rid not in cites:"),

 ("check_acceptance.py", "the queue stops requiring a `grades` line",
  "if status_of(head) or not GRADES.search(body) or rid not in cites:",
  "if status_of(head) or rid not in cites:"),

 # ⚠ KNOWN SILENT, KEPT ON PURPOSE - see the header. `[0-9]+` is greedy and `[a-z]?` optional, so
 # `A12.1` cannot match inside `A12.10b` with or without the boundaries. The guard is UNREACHED by
 # this corpus, not wrong, and the fault it guards already cost that file a false finding.
 ("check_acceptance.py", "CITE loses its word boundaries  [known SILENT, recorded]",
  r'CITE = re.compile(r"\bA[0-9]+\.[0-9]+[a-z]?(?:-[A-Z])?\b")',
  r'CITE = re.compile(r"A[0-9]+\.[0-9]+[a-z]?(?:-[A-Z])?")'),

 # ★ A SECOND TOOL, so that "reusable" is DEMONSTRATED rather than claimed. The mechanism above
 #   knows nothing about either file.
 ("check_inbox.py", "the drain stamp stops requiring the word DRAINED",
  r'STAMP = re.compile(r"RI-\d+ DRAINED")',
  r'STAMP = re.compile(r"RI-\d+")'),

 ("check_retired.py", "the headstone WINDOW widens from 3 lines to 60",
  "WINDOW = 3",
  "WINDOW = 60"),
)

KNOWN_SILENT = ("[known SILENT",)

# ⚠⚠ RUN EACH TOOL AT ITS LOUDEST. Found by this harness ON ITS OWN FIRST RUN: the `-R` mutation
# read SILENT, because `check_acceptance`'s DEFAULT output prints only the queue's COUNT, and
# collapsing two rows onto one id does not change a count. The rows themselves are behind `--queue`.
# ⟶ A signature taken from the default output is a SCOPE THAT EXCLUDES THE EVIDENCE, which is the
# fault this desk keeps finding ([[the-scope-protected-the-claim]]) - here inside the instrument
# built to find it. ★ So a tool that hides detail behind a flag must be DECLARED with that flag.
LOUDEST = {
    "check_acceptance.py": ["--all", "--queue"],
}


def run(tool):
    r = subprocess.run([sys.executable, os.path.join(HERE, tool)] + LOUDEST.get(tool, []),
                       capture_output=True, text=True, encoding="utf-8", errors="replace",
                       cwd=os.path.dirname(os.path.dirname(HERE)))
    return r.stdout, r.returncode


def main():
    argv = sys.argv[1:]
    only = argv[argv.index("--tool") + 1] if "--tool" in argv else None
    show_diff = "--diff" in argv

    todo = [m for m in MUTATIONS if not only or only in m[0]]
    tools = sorted(set(m[0] for m in todo))

    print("")
    print("   MUTATION - break each guard, and see whether anything NOTICES")
    print("   " + "-" * 68)

    base, good = {}, {}
    for t in tools:
        path = os.path.join(HERE, t)
        if not os.path.isfile(path):
            print("   [!] no such tool: %s" % t)
            return 2
        good[t] = io.open(path, encoding="utf-8").read()
        base[t] = run(t)
        print("   baseline  %-24s exit %d, %d lines%s"
              % (t, base[t][1], len(base[t][0].split("\n")),
                 "  (" + " ".join(LOUDEST[t]) + ")" if t in LOUDEST else ""))
    print("")

    silent, rotted, current = [], [], None
    try:
        for tool, label, find, repl in todo:
            if current != tool:
                current, _ = tool, print("   %s" % tool)
            path = os.path.join(HERE, tool)
            n = good[tool].count(find)
            if n != 1:
                # ⚠ THE ANCHOR ROTTED. Never a skip - see the header.
                rotted.append((tool, label, n))
                print("       %-58s ⚠ ANCHOR x%d - NOT TESTED" % (label, n))
                continue
            io.open(path, "w", encoding="utf-8", newline="\n").write(
                good[tool].replace(find, repl, 1))
            out, code = run(tool)
            io.open(path, "w", encoding="utf-8", newline="\n").write(good[tool])

            bit = (out, code) != base[tool]
            known = any(k in label for k in KNOWN_SILENT)
            mark = "BIT " if bit else ("SILENT (recorded)" if known else "⚠ SILENT")
            print("       %-58s %s" % (label, mark))
            if bit and show_diff:
                a, b = base[tool][0].split("\n"), out.split("\n")
                for x, y in zip(a, b):
                    if x != y:
                        print("           - %s" % x.strip()[:76])
                        print("           + %s" % y.strip()[:76])
                        break
            if not bit and not known:
                silent.append((tool, label))
    finally:
        # ⚠⚠ VERIFIED RESTORE. Loudest thing this file can say.
        broke = [t for t in tools
                 if io.open(os.path.join(HERE, t), encoding="utf-8").read() != good[t]]
        for t in broke:
            io.open(os.path.join(HERE, t), "w", encoding="utf-8", newline="\n").write(good[t])
        again = [t for t in tools
                 if io.open(os.path.join(HERE, t), encoding="utf-8").read() != good[t]]
        if again:
            print("")
            print("   [!!!] RESTORE FAILED - THESE TOOLS ARE MUTATED ON DISK: %s" % ", ".join(again))
            print("         `git checkout -- addons/tools/` before running anything else.")
            return 3

    print("")
    print("   %d mutation%s  ·  %d silent and unexplained  ·  %d anchor%s rotted"
          % (len(todo), "" if len(todo) == 1 else "s", len(silent),
             len(rotted), "" if len(rotted) == 1 else "s"))
    for t, l in silent:
        print("   [!] %s: breaking `%s` changed NOTHING." % (t, l))
    for t, l, n in rotted:
        print("   [!] %s: `%s` matched %d times - the tool moved and the mutation did not."
              % (t, l, n))
    if silent:
        print("")
        print("   ⚠ A SILENT MUTATION IS NOT AUTOMATICALLY A BUG. The guard may be UNREACHED by")
        print("     this corpus rather than wrong. ⟶ Decide which, then RECORD it in the tool and")
        print("     mark the entry `[known SILENT]` here. Deleting it to clear the count is the")
        print("     one move that turns a real finding into a lie.")
    print("")
    return 1 if (silent or rotted) else 0


if __name__ == "__main__":
    sys.exit(main())
