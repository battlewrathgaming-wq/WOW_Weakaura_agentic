# -*- coding: utf-8 -*-
r"""check_targets.py - every addon source names the document it is BUILT AGAINST,
and that document is not a record.

    py addons/tools/check_targets.py

★★★ WHY THIS EXISTS, and it is a specific failure rather than a principle.

2026-08-18: I built G2 across three sections against `driver_programmatic_model.md` -
the DRIVER's model - when the governing document is `dungeonrun_model.md`, the addon's
heading. Battlewrath: *"Building code against the wrong target."*

⚠⚠ FOUR POINTERS ALREADY SAID SO and I read past every one: the bench shelf I tend
myself, `operations/Addons_load.md`, `operations/ROUTER.md`, and line 3 of the very
file I was editing. **So a fifth pointer was never the answer.** Pointers only answer
the question you arrive with, and I arrived with the docket's question.

★★★ TWO THINGS FIX IT, AND NEITHER IS A DOCUMENT.

  1  THE TAG RIDES IN THE PATH. A grep prints `path:line:text` for every hit, so the
     path is the ONLY carrier that reaches you when you arrive at a file sideways -
     which is how it happened. `ARCHIVE__dungeonrun_poc.md` says what it is on every
     line of every search result, before you have read a word of the content.
     ⚠ A banner at the top only reaches someone who opened the file deliberately.

  2  THIS CHECK FAILS. A `-- Model:` line is prose in a comment; nothing verified the
     old `-- Spec:` lines and all six had gone stale, pointing at the archive whose own
     first line says *"Start with the model."* An unverified citation rots exactly like
     a mutation anchor - still sitting there, still looking like coverage.

What it asserts, per addon source file:

    NAMED       a `-- Model:` (or legacy `-- Spec:`) line in the first 12 lines
    REAL        the path it names exists on disk
    NOT A RECORD  the path does not carry a RECORD_PREFIXES tag

★ It does NOT check that the citation is the RIGHT document - nothing mechanical can.
It checks that one was declared, resolves, and is not something we already marked as
not-a-target. The judgement stays with the author; the rot does not.
"""
import io
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__)).replace("\\", "/")
ROOT = os.path.dirname(os.path.dirname(HERE))
ADDONS = ROOT + "/addons"

# ★★★ AN ALLOWLIST, NOT A BLOCKLIST (Battlewrath, §317). The first cut tagged the ONE
# self-declared archive and let everything else through, which meant every untagged
# document read as a target - and I designed export against 2026-08-12 material the
# same afternoon, from a pointer INSIDE the archive.
#
# ⚠ "One tagged file is not a tag scheme." Tagging cannot keep up, because the default
# is wrong: a new document is a target until someone marks it. Inverted, the default is
# right - a document is basis until someone puts it on this list.
#
# His ruling, and it is narrower than I assumed:
#   "Programatic model and your own proposal are the only target files. Everything else
#    is how we got here. Even the code in the client / my addon."
#
# ★ So the existing code is HISTORY, not specification. Where routes.lua and the model
# disagree, the model wins and the code moves. I had been citing code comments as
# competing authorities (T16), which is backwards.
TARGETS = (
    "addons/planning/driver_programmatic_model.md",   # the editor's authoring form
    "addons/planning/driver_bench_proposition.md",    # this bench's proposal
)

# Kept for the one file that says so itself, and because a citation naming a record is
# a louder fault than one naming mere basis.
RECORD_PREFIXES = ("ARCHIVE__", "SUPERSEDED__")

CITE = re.compile(r"^--\s*(?:Model|Spec):\s*([^\s,;]+\.md)")
HEAD = 12

# Addons that ship. Probe/dev addons are excluded by name rather than by pattern, so
# adding one is a deliberate edit here.
SKIP_DIRS = {"COA_DevDump"}

# ★★ TWO TIERS, AND THE SPLIT IS THE POINT. ENFORCED fails the build; everything else
# is REPORTED and counted. A check that goes red on twenty-four files nobody is going to
# fix today is a check people learn to run past - the same rot it was written against
# (§272 moved the interface scoreboard out of the drift channel for exactly this).
#
# ⚠ The others are not exempt because they matter less. They are unenforced because I
# have not READ their governing documents, and stamping a target I have not read is the
# fault this file exists to stop, committed by machine and at scale.
#
# Promoting an addon is ONE WORD here, after someone reads its heading and backfills.
ENFORCED = {"COA_DungeonRun"}


def sources():
    for d in sorted(os.listdir(ADDONS)):
        p = ADDONS + "/" + d
        if not d.startswith("COA_") or d in SKIP_DIRS or not os.path.isdir(p):
            continue
        for f in sorted(os.listdir(p)):
            if f.endswith(".lua"):
                yield d, f, p + "/" + f


def main():
    rows, bad = [], 0
    for addon, name, path in sources():
        head = io.open(path, encoding="utf-8", errors="replace").readlines()[:HEAD]
        cite = None
        for line in head:
            m = CITE.match(line.strip())
            if m:
                cite = m.group(1)
                break

        live = addon in ENFORCED

        if cite is None:
            rows.append((addon, name, "-",
                         "<-- NO TARGET DECLARED" if live else "unenforced"))
            bad += live
            continue

        base = os.path.basename(cite)
        if any(base.startswith(t) for t in RECORD_PREFIXES):
            rows.append((addon, name, base, "<-- NAMES A RECORD, NOT A TARGET"))
            bad += 1                      # ⚠ always fatal - it is a WRONG target, not a
            continue                      #   missing one, and it is wrong in any addon
        if not os.path.exists(ROOT + "/" + cite):
            rows.append((addon, name, base, "<-- NO SUCH FILE"))
            bad += 1
        elif cite.replace("\\", "/") not in TARGETS:
            # ⚠ NOT a record, and still not a target. This is the case that let the
            # third repeat happen: a real, current, useful document that nobody had
            # said was basis, so it read as something to build against.
            rows.append((addon, name, base, "<-- NOT A TARGET (basis, or unlisted)"))
            bad += live
        else:
            rows.append((addon, name, base, "ok" if live else "ok (unenforced)"))

    print("")
    print("   TARGETS - what each addon source says it is built against")
    print("   " + "-" * 68)
    last = None
    for addon, name, base, verdict in rows:
        if addon != last:
            print("   %s" % addon)
            last = addon
        print("     %-22s %-34s %s" % (name, base[:34], verdict))

    quiet = len([r for r in rows if r[3] == "unenforced"])
    print("")
    print("   ENFORCED: %s" % ", ".join(sorted(ENFORCED)))
    if quiet:
        print("   %d source(s) in other addons declare no target - REPORTED, not failed."
              % quiet)
        print("   ⚠ Unenforced because nobody has read their heading yet, not because")
        print("     they are exempt. Promoting one is a single word in ENFORCED.")
    print("")
    if bad:
        print("   %d of %d FAILED. A source with no target, or one naming a record,"
              % (bad, len(rows)))
        print("   is a file the next person builds against the wrong thing from.")
    else:
        print("   %d of %d declare a TARGET from the allowlist."
              % (len(rows), len(rows)))
        print("")
        print("   ★ The targets, and there are two:")
        for t in TARGETS:
            print("     %s" % t)
        print("   Everything else is how we got here - cite it, never build against it.")
    print("")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
