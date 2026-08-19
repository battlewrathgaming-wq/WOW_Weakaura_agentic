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

# ★★★ THE ALLOWLIST IS `DRIVER_BASIS.md`'s GOVERNING LIST (§320).
#
# §317 ruled two target files and I hard-coded them here. **The Analyst then built
# `DRIVER_BASIS.md` at Battlewrath's ask, to solve this**, and it is better than my
# version on two counts:
#
#   1  PRECEDENCE. "If two governing docs disagree, the LOWER number wins and the
#      disagreement is REPORTED, not resolved by the builder." I had a flat pair and
#      no rule for a conflict between them.
#   2  WIDTH. Eight documents, not two - the use-case target and the scoping rulings
#      sit ABOVE the model, and acceptance and the walk sit below it. My two were the
#      middle of a stack.
#
# ⚠ SO THIS LIST IS A MIRROR, NOT AN AUTHORITY. `DRIVER_BASIS.md` is the authority and
# it says so itself: *"When a ruling moves, this file moves."* If the two disagree the
# BASIS wins and this array is stale - which is what CHECK_MIRROR below asserts, so the
# staleness cannot be silent.
GOVERNING = (
    "addons/planning/driver_use_case_target.md",
    "addons/planning/driver_scoping.md",
    "addons/planning/driver_programmatic_model.md",
    "addons/planning/driver_bench_proposition.md",
    "addons/planning/driver_authoring_acceptance.md",
    "addons/planning/driver_walk_acceptance.md",
    "addons/planning/driver_user_journey.md",
    "operations/ROUTER.md",
    # ★ 9 and 10, the UI rework's pair (2026-08-18). ⚠ THE MIRROR CHECK CAUGHT BOTH
    # ADDITIONS BEFORE A HUMAN DID - two runs, two ALLOWLIST DRIFT lines naming the exact
    # files. That is the check doing the one job it was written for: the basis moves, and
    # this array is told rather than discovered later by a build against the wrong target.
    "addons/planning/driver_ui_scope.md",
    "addons/planning/driver_ui_acceptance.md",
    # ★ 11, the V1 sense driver's test brief (2026-08-18). ⚠ THE MIRROR CAUGHT IT
    # AGAIN, third time - the Analyst added a governing doc and this array was told by
    # a red rather than by someone remembering. That is the whole job.
    "addons/planning/driver_sense_acceptance.md",
)

BASIS = "addons/planning/DRIVER_BASIS.md"

# ★ A source cites the BASIS, not a governing doc. One line that never goes stale: the
# basis routes to whatever governs today, in order. Naming a governing doc directly is
# accepted - it is not wrong - but it pins a file that the basis may re-rank.
TARGETS = (BASIS,) + GOVERNING

# Kept: a citation naming a self-declared record is a louder fault than naming basis.
RECORD_PREFIXES = ("ARCHIVE__", "SUPERSEDED__")


def check_mirror():
    """⚠ The array above must still match DRIVER_BASIS.md's GOVERNING section.

    A hard-coded mirror of a document is a thing that rots - the same failure as the
    `-- Spec:` lines this file was written about. So it is asserted rather than trusted.
    """
    try:
        text = io.open(ROOT + "/" + BASIS, encoding="utf-8", errors="replace").read()
    except OSError:
        return ["DRIVER_BASIS.md is MISSING - the allowlist has no authority behind it"]
    body = text.split("## GOVERNING", 1)[-1].split("## RULED", 1)[0]
    missing = [g for g in GOVERNING if os.path.basename(g) not in body]
    extra = []
    for line in body.splitlines():
        m = re.match(r"^\s*\d+\.\s+`([^`]+)`", line)
        if m and not any(m.group(1) in g for g in GOVERNING):
            extra.append(m.group(1))
    out = []
    for g in missing:
        out.append("in this file but NOT in DRIVER_BASIS: " + os.path.basename(g))
    for e in extra:
        out.append("in DRIVER_BASIS but NOT in this file: " + e)
    return out


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


# ★★ VENDORED CODE IS EXEMPT AND COUNTED (A10.1b, bench U5). ⚠ It was already exempt by
# ACCIDENT — `sources()` walks top level only, so `COA_GuardianPlates/Libs/LibStub` was
# never scanned and nobody had decided it should not be. Dungeon Run now ships 18 Ace3
# files under `Libs/`, which turns an accidental exemption into a rule waiting to be
# broken by the first person who adds recursion. ★ So it is stated, and the NUMBER is
# printed: an exemption nobody can see is the same shape as a silent pass.
def vendored_count():
    n = 0
    for d in sorted(os.listdir(ADDONS)):
        libs = os.path.join(ADDONS, d, "Libs")
        if os.path.isdir(libs):
            for _, _, fns in os.walk(libs):
                n += sum(1 for f in fns if f.endswith(".lua"))
    return n


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
    # ★ The mirror first: if the array has drifted from DRIVER_BASIS, every verdict
    # above was graded against a stale list and should be read that way.
    drift = check_mirror()
    for d in drift:
        print("   [!] ALLOWLIST DRIFT - %s" % d)
        bad += 1
    if drift:
        print("       DRIVER_BASIS.md is the authority; this array is a mirror of it.")
        print("")
    print("   ENFORCED: %s" % ", ".join(sorted(ENFORCED)))
    print("   %d vendored file(s) under Libs/ EXEMPT - DECLARED (A10.1b), never"
          % vendored_count())
    print("     skipped by an accident of a non-recursive walk.")
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
        print("   ★ GOVERNING, in precedence order (DRIVER_BASIS.md):")
        for i, t in enumerate(GOVERNING, 1):
            print("     %d  %s" % (i, t))
        print("   ⚠ Lower number wins. A disagreement between two is REPORTED,")
        print("     never resolved by the builder. Everything else is how we got here.")
    print("")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
