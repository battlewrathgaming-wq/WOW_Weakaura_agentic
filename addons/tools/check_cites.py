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
pretending.

★★★ EXACTLY ONE THING IS FATAL, and the list SHRANK after §468 rather than grew:

    [!] EXIT 1   a line PAST THE END of a file this tool resolved WITHOUT GUESSING.
                 Unambiguous: the file is named, it is ours, the line is not there.
    ~   TOLD     everything else. A file not in this repo (external prior art, or a typo -
                 the tool cannot tell). A past-end on a basename it had to PICK between six
                 addons. Drift. Blanks. Ambiguity.

⚠⚠ WHY THE FATAL LIST SHRANK. As first written this exited 1 on "no such file", which made the
gate PERMANENTLY RED on correct documents - `satnav_prior_art.md` cites a third-party addon that
can never resolve here. ★ A checker that is always red trains its reader to ignore it, which is
the worst thing a checker can buy. **A gate must be capable of being green on correct input, or
it is not a gate - it is noise with an exit code.**

⚠ Drift itself still needs a person: the fix is sometimes "re-aim the number" and sometimes
"the claim died with the line".
"""

import io
import os
import re
import sys

# The epilogue prints star and warning glyphs, and a cp1252 console cannot encode them -
# so the tool COMPLETED its findings and then died printing its own footer, exit 1. A gate
# tool that passes on one console and crashes on another is worse than one that fails: the
# verdict was right and unreadable. Same one line its three siblings already carry.
sys.stdout.reconfigure(encoding="utf-8")

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

# ★★★ THE PREFIX IS PART OF THE CITATION, and dropping it was this tool's own fault -
# reported by the bench at §468 in the sharpest possible form: **"the inverse of its own
# stated complaint."** The epilogue below tells authors that under-specifying is a format
# fault; the matcher was meanwhile THROWING AWAY a complete specification.
# `mark_audit.md` cites `MancerLedger/core.lua:363` - fully qualified, 619 lines - and this
# tool resolved it against `COA_DungeonRun/core.lua` (294) and called it PAST END.
# ⟶ Group 1 is now the OPTIONAL addon folder. When a doc says which addon, that IS the answer.
CITE = re.compile(r"\b(?:([A-Za-z_][A-Za-z0-9_]*)/)?([a-z_][a-z0-9_]*\.lua):(\d+)(?:\s*-\s*(\d+))?")


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


def _same_addon(actual, cited):
    a, c = actual.lower(), cited.lower()
    return a == c or a.endswith(c) or c.endswith(a)


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
                folder, lua, n = m.group(1), m.group(2), int(m.group(3))
                where = "%s:%d" % (name, i)
                hits = find_lua(lua)
                if folder:
                    # ★ QUALIFIED. The doc said which addon; honour it, or say it is absent.
                    # NEVER fall back to an unqualified match — that is the §468 fault again.
                    #
                    # ⚠ THE MATCH IS BY SUFFIX, NOT EQUALITY, AND THE STRICT VERSION LASTED ONE RUN.
                    # Authors write the addon the way they say it: `DungeonRun/widget.lua` for
                    # `COA_DungeonRun/`, `COA_MancerLedger/core.lua` for `MancerLedger/`. Exact
                    # matching turned five CORRECT, fully-qualified citations into "not in this
                    # repo" — a stricter reading of the same mistake §468 reported, where the tool
                    # again knew better than the document. ★ Either name ending in the other is
                    # the loosest rule that admits a prefix convention and still refuses a
                    # different addon.
                    hits = [h for h in hits if _same_addon(
                        os.path.basename(os.path.dirname(h)), folder)]
                if not hits:
                    missing_file.append((where, m.group(0)))
                    continue
                pick = hits[0]
                guessed = False
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
                    pick, guessed = dr[0], True
                body = lines_of(pick)
                if body is None:
                    missing_file.append((where, m.group(0)))
                    continue
                if n > len(body):
                    # ⚠⚠ HARD ONLY WHEN NOTHING WAS GUESSED. If the basename was ambiguous and
                    # this tool PICKED the file, a past-end says more about the pick than about
                    # the document — and failing a correct doc is the §468 fault in a new coat.
                    past_end.append((where, m.group(0), len(body), guessed))
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

    # ⚠⚠ NOT FATAL, AND THE REASON IS THAT THIS TOOL CANNOT TELL THE TWO APART.
    # `satnav_prior_art.md` cites `route.lua:176` — a THIRD-PARTY addon read as prior art,
    # which can never resolve here. A typo looks identical. ★ Failing on it made the gate
    # PERMANENTLY red on correct documents (§468), which trains a reader to ignore the tool —
    # the worst outcome a checker can buy.
    for where, cite in missing_file:
        print("   ~   NOT IN THIS REPO %-26s cited at %s" % (cite, where))
    if missing_file:
        print("       ★ EXTERNAL PRIOR ART OR A TYPO — this tool cannot distinguish them.")
        print("         Qualify it (`Addon/file.lua:N`) and the answer stops being a guess.")

    for where, cite, n, guessed in past_end:
        if guessed:
            print("   ~   PAST END (GUESSED) %-22s cited at %s (the file THIS TOOL picked"
                  " has %d lines)" % (cite, where, n))
        else:
            print("   [!] PAST END       %-28s cited at %s (file has %d lines)"
                  % (cite, where, n))
            bad += 1
    if any(g for _, _, _, g in past_end):
        print("       ★ GUESSED ones are NOT failures: the basename was ambiguous and the pick")
        print("         may be the wrong file. That is a citation fault, not a line fault.")

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
