# -*- coding: utf-8 -*-
r"""check_cites.py - every `file.lua:N` citation in the planning docs, RESOLVED.

    py addons/tools/check_cites.py            the drifted ones
    py addons/tools/check_cites.py --all      every citation, resolved or not
    py addons/tools/check_cites.py --doc X    one document

★★★ WHY THIS EXISTS - a measured rate, not a hunch.

A staleness audit (2026-08-21) resolved ~55 hand-written `file.lua:N` citations across the six
governing/acceptance docs and found **~31 of them pointing at the wrong line - 56%.** Not typos:
`routes.lua` grew by ~120 lines in a fortnight and every citation past the insertion point slid.

⚠⚠ THE FAULT IS THE FORMAT, NOT THE THIRTY-ONE. A line number is a pointer that NOTHING
maintains - it is correct at the instant it is typed and decays silently from then on. And these
docs are what every agent reads at boot, so a drifted cite does not merely fail to help: it sends
a reader to a line that says something ELSE, confidently.

    ROTS      routes.lua:1529          a number nothing owns
    HOLDS     routes.lua Routes.Outcome    a symbol the file itself carries
    HOLDS     "no default is invented here"  a unique sentence, greppable

★ So this tool does two jobs, and the second matters more:
    1  RESOLVE what exists today, so the drifted set is a fact rather than a claim
    2  make the rot LOUD, so the next citation is written in a form that cannot rot

⚠ IT CANNOT JUDGE MEANING. It reports that a cited line exists and shows what is there; whether
that line still supports the sentence citing it is a READ, and the tool says so rather than
pretending. What it CAN do without judgement is catch the two hard failures - a line past the end
of the file, and a file that does not exist - and surface the rest for a human pass.

⚠ NOT A GATE ON ITS OWN. Exit 1 only on the hard failures. Drift needs a person, because the fix
is sometimes "re-aim the number" and sometimes "the claim died with the line".
"""

import io
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
PLANNING = os.path.join(ROOT, "planning")
# ⚠⚠ THIS TOOL'S FIRST RUN HAD THE EXACT FAULT IT EXISTS TO CATCH, and it is kept in the
# record rather than quietly fixed. `SOURCE` was `COA_DungeonRun` alone, so 74 citations came
# back "NO SUCH FILE" — every one of them a `mark_audit.md` or `satnav_prior_art.md` cite
# pointing at ANOTHER addon in this same repo. ★ A scope that excluded what would refute it,
# in the resolver written because scopes rot. ⟶ It now resolves a basename across EVERY addon
# folder, and says AMBIGUOUS rather than guessing when two addons carry the same filename.
SOURCE = ROOT

# ⚠ The planning docs only. `audit/` and `history/` cite THIRD-PARTY sources (WeakAuras,
# AceDB) which are not in this tree, and a finished audit is a frozen record - re-aiming its
# citations would edit a snapshot. Stated because an unexplained exclusion is the scope fault
# this project keeps finding.
SKIP_DIRS = ("audit", "history")

CITE = re.compile(r"\b([a-z_][a-z0-9_]*\.lua):(\d+)(?:\s*-\s*(\d+))?")


def docs():
    out = []
    for name in sorted(os.listdir(PLANNING)):
        if name.endswith(".md") and os.path.isfile(os.path.join(PLANNING, name)):
            out.append(name)
    return out


def find_lua(basename, cache={}):
    """Every path in this repo carrying that filename. 0 = absent, >1 = AMBIGUOUS."""
    if not cache:
        for dirpath, dirnames, filenames in os.walk(SOURCE):
            dirnames[:] = [d for d in dirnames
                           if d not in ("__pycache__", ".git") and d not in SKIP_DIRS]
            for f in filenames:
                if f.endswith(".lua"):
                    cache.setdefault(f, []).append(os.path.join(dirpath, f))
    return cache.get(basename, [])


def lines_of(path, cache={}):
    if path not in cache:
        try:
            cache[path] = io.open(path, encoding="utf-8", errors="replace").read().split("\n")
        except IOError:
            cache[path] = None
    return cache[path]


def main():
    argv = sys.argv[1:]
    show_all = "--all" in argv
    only = None
    if "--doc" in argv:
        only = argv[argv.index("--doc") + 1]

    missing_file, past_end, resolved, ambiguous = [], [], [], []

    for name in docs():
        if only and only not in name:
            continue
        doc = os.path.join(PLANNING, name)
        text = io.open(doc, encoding="utf-8", errors="replace").read().split("\n")
        for i, line in enumerate(text, 1):
            for m in CITE.finditer(line):
                lua, n = m.group(1), int(m.group(2))
                where = "%s:%d" % (name, i)
                hits = find_lua(lua)
                if not hits:
                    missing_file.append((where, m.group(0)))
                    continue
                pick = hits[0]
                if len(hits) > 1:
                    # ⚠ TOLD, THEN RESOLVED — not guessed silently. Six addons carry `core.lua`,
                    # so the citation under-specifies; but these docs are about COA_DungeonRun,
                    # so preferring it resolves the line while the count still records that the
                    # FORM left it open. ★ Ambiguity reported AND the read attempted beats
                    # either one alone: refusing helps nobody, guessing quietly is the fault.
                    ambiguous.append((where, m.group(0), len(hits)))
                    dr = [h for h in hits if "COA_DungeonRun" in h]
                    if not dr:
                        continue
                    pick = dr[0]
                body = lines_of(pick)
                if body is None:
                    missing_file.append((where, m.group(0)))
                    continue
                if n > len(body):
                    past_end.append((where, m.group(0), len(body)))
                    continue
                resolved.append((where, m.group(0), body[n - 1].strip()[:96]))

    print("")
    print("   CITATIONS - every `file.lua:N` in addons/planning/*.md, resolved")
    print("   " + "-" * 66)

    if show_all:
        for where, cite, what in resolved:
            print("   %-46s %s" % (cite, where))
            print("        -> %s" % (what or "(blank line)"))
        print("")

    bad = 0
    for where, cite in missing_file:
        print("   [!] NO SUCH FILE   %-28s cited at %s" % (cite, where))
        bad += 1
    for where, cite, n in past_end:
        print("   [!] PAST END       %-28s cited at %s (file has %d lines)"
              % (cite, where, n))
        bad += 1

    blank = [r for r in resolved if not r[2]]
    if blank and not show_all:
        print("")
        print("   ~ %d citation(s) resolve to a BLANK line - almost always drift:" % len(blank))
        for where, cite, _ in blank[:12]:
            print("       %-28s at %s" % (cite, where))

    print("")
    if ambiguous:
        print("")
        print("   ~ %d citation(s) name a FILE THIS REPO HAS MORE THAN ONE OF - the citation"
              % len(ambiguous))
        print("     does not say which addon. Resolved against COA_DungeonRun and COUNTED")
        print("     here, because under-specifying is the same format fault as drifting:")
        for where, cite, k in ambiguous[:10]:
            print("       %-28s at %-32s (%d files)" % (cite, where, k))

    print("   resolved %d   no-such-file %d   past-end %d   blank-target %d   ambiguous %d"
          % (len(resolved), len(missing_file), len(past_end), len(blank), len(ambiguous)))
    print("")
    print("   ⚠ RESOLVING IS NOT AGREEING. This tool proves the line EXISTS and shows what")
    print("     is on it; whether it still supports the sentence citing it is a READ.")
    print("   ★ The durable fix is the FORM, not the number: cite a SYMBOL")
    print("     (`routes.lua Routes.Outcome`) or a unique quoted sentence. Both survive")
    print("     an insertion; a line number never does.")
    print("")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
