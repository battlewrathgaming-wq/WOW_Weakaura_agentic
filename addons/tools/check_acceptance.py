# -*- coding: utf-8 -*-
r"""check_acceptance.py - a row's STATUS against the code it says it grades.

    py addons/tools/check_acceptance.py            the contradictions
    py addons/tools/check_acceptance.py --all      every row it could read
    py addons/tools/check_acceptance.py --doc X    one brief

★★★ WHY THIS EXISTS - the failure it watches happened TWICE IN TWO DAYS.

    §467  the docs said things were BUILT that were not   - found by a four-agent sweep
    §504  the docs said things were UNBUILT that were     - found by a new tool

Two directions, two one-off investigations, **zero standing signal** (RI-72). The root is one
line: a row's status - `OWED` · `LANDED` · `NOT BUILT` - is WORDS IN A SENTENCE, so nothing
derives them and nothing can contradict them.

★ The project already solved this one layer up. `check_inbox.py` derives an item's status from its
stamp and refuses when what the item says about itself and what the convention reads disagree.
**The inbox cannot lie about its state. The acceptance briefs could, and did, twice.**

⚠⚠ IT READS THE DIALECT THAT EXISTS; IT DOES NOT IMPOSE ONE. Measured before it was written: of
169 rows, **131 carry no status word at all** and the other 38 use **nine** spellings. Normalising
169 rows would be a sweep, and a sweep is the churn this project refuses. ⟶ So the synonyms below
COLLAPSE into a closed set, an unstated row is reported as UNSTATED rather than failed, and a row
earns its status the day someone touches it - exactly how `grades` coverage is earned.

⚠⚠⚠ AND THE ONE THING IT MUST NEVER CLAIM. A function EXISTING does not mean a criterion is MET
([[a-name-is-not-a-use]]; §497 measured that confusion at 47% wrong). ⟶ This tool never says a row
is satisfied. It says **the row's own words and the code disagree, and a person decides which is
stale** - which is the same honest scope `emit_divergence` holds.

    IT CAN SAY      the row claims OWED and every function it grades is DEFINED
                    the row claims BUILT and something it grades is ABSENT
                    the row claims RETIRED and nothing near it records a retirement
    IT CANNOT SAY   whether the criterion passes · whether the code is correct · which side is right
"""

import io
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
PLANNING = os.path.join(ROOT, "planning")
SOURCE = os.path.join(ROOT, "COA_DungeonRun")

sys.path.insert(0, HERE)
from check_retired import MARKED, WINDOW        # noqa: E402  ONE definition of a headstone

BRIEFS = ("driver_manager_acceptance.md", "driver_authoring_acceptance.md",
          "driver_ui_acceptance.md", "driver_sense_acceptance.md",
          "driver_walk_acceptance.md")

# ★ THE COLLAPSE. Nine spellings, four meanings - read, never replaced.
STATUS = (
    ("OWED",     ("OWED", "NOT BUILT", "UNBUILT", "DOES NOT EXIST", "NO DOOR")),
    ("RETIRED",  ("RETIRED", "SUPERSEDED", "STRUCK", "WITHDRAWN")),
    ("BUILT",    ("BUILT", "LANDED", "SHIPPED", "CLOSED")),
    ("ADVISORY", ("ADVISORY", "WRITTEN AHEAD")),
)
# ⚠ RETIRED is tested BEFORE BUILT on purpose: "RETIRED - it was BUILT at §392" must read as
# retired. Ordering a collapse by specificity is the same lesson mutation testing keeps giving -
# an assertion behind one that fires first never runs.

STRUCK = re.compile(r"~~.*?~~|\*\"[^\"]*\"\*", re.S)

ROW = re.compile(r"^- \*\*(A[0-9][0-9.a-z]*)")
GRADES = re.compile(r"^\s+grades\s+(.+)$", re.M)
IDENT = re.compile(r"\b([A-Z][A-Za-z0-9]*)\.([A-Za-z_]\w+)\b")
DEFINED = re.compile(r"^\s*(?:function\s+([A-Z]\w*)\.([A-Za-z_]\w*)\s*\(|"
                     r"([A-Z]\w*)\.([A-Za-z_]\w*)\s*=)", re.M)


def defined():
    out = set()
    for f in sorted(os.listdir(SOURCE)):
        if not f.endswith(".lua"):
            continue
        body = io.open(os.path.join(SOURCE, f), encoding="utf-8", errors="replace").read()
        for m in DEFINED.finditer(body):
            ns, fn = (m.group(1), m.group(2)) if m.group(1) else (m.group(3), m.group(4))
            out.add("%s.%s" % (ns, fn))
    return out


# ⚠⚠ TWO DEFECTS FOUND BY RUNNING THIS AGAINST THE REAL CORPUS, kept because each would have
# put a false row in the report:
#
#  1  SUBSTRING, NOT WORD.  `OWED` matched inside **`NARROWED`** — A11.2a reads *"NARROWED
#     2026-08-20"* and was reported as owed. ★ A substring search answering a WORD question is
#     [[a-name-is-not-a-use]]'s cousin, and it is the second time this week the same shape has
#     cost a false finding.
#  2  IT READ WHAT THE ROW QUOTES.  A12.4e carries `~~A12.4b records that Trigger is not built~~`
#     — struck text, quoted to record that it is no longer true — and the tool read *"not built"*
#     as the row's own claim. ★ Same failure as `emit_divergence`'s headstones, one layer in:
#     **a row's status is what it CLAIMS, never what it QUOTES.**


def status_of(head):
    up = STRUCK.sub(" ", head).upper()
    for name, words in STATUS:
        for w in words:
            if re.search(r"\b" + re.escape(w) + r"\b", up):
                return name
    return None


def rows(name):
    path = os.path.join(PLANNING, name)
    lines = io.open(path, encoding="utf-8", errors="replace").read().split("\n")
    idx = [(i, m.group(1)) for i, l in enumerate(lines) for m in [ROW.match(l)] if m]
    for k, (i, rid) in enumerate(idx):
        end = idx[k + 1][0] if k + 1 < len(idx) else min(i + 45, len(lines))
        # ⚠⚠ A ROW ENDS AT THE NEXT TOP-LEVEL BULLET, not at the next A-ROW. These briefs carry
        # FAMILY BULLETS that belong to a group rather than to one row - `- **mutation**` under A3
        # (naming A3.1/A3.2/A3.3/A3.5) and `- ★ **A4.1-A4.3 CLOSED §346**` under A4. Reading to the
        # next A-heading swallowed them into the row above.
        # ★ FOUND TWICE, both times by consequence rather than by inspection: once by a calibration
        # read that two sub-agents had missed, and once when this checker reported A4.3 as OWED
        # because a NEIGHBOUR's note said `export does not exist`. **A parser that mis-attributes
        # text invents a status the row never claimed.**
        for j in range(i + 1, end):
            if lines[j].startswith("- "):
                end = j
                break
        body = "\n".join(lines[i:end])
        # ⚠⚠ STRIP THE STRUCK TEXT FROM THE **BODY** BEFORE TAKING THE HEAD. Taking three
        # raw lines first CUT A STRIKETHROUGH THAT SPANNED THEM, so the `~~` never closed
        # inside the window and the suppression could not fire - A12.4e survived the first
        # fix as a false positive because of it. ★ Order of operations, and it is the same
        # lesson mutation testing keeps giving: an assertion behind one that fires first
        # never runs.
        yield rid, i + 1, "\n".join(STRUCK.sub(" ", body).split("\n")[:3]), body, lines


def main():
    argv = sys.argv[1:]
    show_all = "--all" in argv
    only = argv[argv.index("--doc") + 1] if "--doc" in argv else None

    have = defined()

    # how many rows cite each function - a shared one makes an existence test weak
    cited = {}
    for name in BRIEFS:
        for _, _, _, body, _ in rows(name):
            g = GRADES.search(body)
            if not g:
                continue
            for a, b in IDENT.findall(g.group(1)):
                k = "%s.%s" % (a, b)
                cited[k] = cited.get(k, 0) + 1

    bad, unstated, unjoinable, checked = [], 0, 0, 0

    print("")
    print("   ACCEPTANCE - each row's stated STATUS against the code it grades")
    print("   " + "-" * 66)

    for name in BRIEFS:
        if only and only not in name:
            continue
        for rid, ln, head, body, lines in rows(name):
            st = status_of(head)
            g = GRADES.search(body)
            names = set("%s.%s" % (a, b) for a, b in IDENT.findall(g.group(1))) if g else set()
            where = "%s:%d %s" % (name.replace("driver_", "").replace("_acceptance.md", ""), ln, rid)

            if st is None:
                unstated += 1
                continue
            if st == "RETIRED":
                lo = max(0, ln - 1 - WINDOW)
                if not any(MARKED.search(l) for l in lines[lo:ln + WINDOW]):
                    bad.append("%-34s says RETIRED and nothing near it records a retirement"
                               % where)
                checked += 1
                continue
            if not names:
                unjoinable += 1
                continue

            checked += 1
            absent = sorted(n for n in names if n not in have)
            if st == "OWED" and not absent:
                # ⚠ HOW STRONG THE SIGNAL IS DEPENDS ON HOW SPECIFIC THE FUNCTION IS. Three of the
                # first five findings graded `Bucket.Build`, which has existed all along - its
                # existence says nothing about whether ONE refusal inside it is written. ⟶ The
                # count is printed so the reader can weigh it rather than take it.
                shared = max(cited.get(n, 0) for n in names)
                weak = "  (weak: %s is graded by %d rows)" % (
                    ", ".join(n for n in names if cited.get(n, 0) == shared), shared) \
                    if shared > 2 else ""
                bad.append("%-34s says OWED - and every function it grades EXISTS (%s)%s"
                           % (where, ", ".join(sorted(names)), weak))
            if st == "BUILT" and absent:
                bad.append("%-34s says BUILT - and it grades %s, which is NOT DEFINED"
                           % (where, ", ".join(absent)))
            if show_all:
                print("       %-34s %-8s %s" % (where, st, ", ".join(sorted(names)) or "-"))

    print("")
    for b in bad:
        print("   [!] %s" % b)
    if bad:
        print("")
        print("   ⚠ A CONTRADICTION IS NOT A VERDICT. The row's words and the code disagree;")
        print("     WHICH ONE IS STALE IS A READ. A function existing does not mean a criterion")
        print("     is met - that confusion measured 47% wrong at §497.")

    print("")
    print("   checked %d   contradictions %d   no status stated %d   stated but unjoinable %d"
          % (checked, len(bad), unstated, unjoinable))
    print("")
    print("   ★ UNSTATED IS NOT A FAILURE. 131 of 169 rows carried no status word when this was")
    print("     written; a row earns one on TOUCH, never in a sweep. **That count is the honest")
    print("     ceiling on this tool, exactly as `grades` coverage is the ceiling on the emitter.**")
    print("")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
