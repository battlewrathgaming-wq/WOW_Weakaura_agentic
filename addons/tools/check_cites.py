# -*- coding: utf-8 -*-
r"""check_cites.py - every `file.lua:N` citation in the planning docs, RESOLVED - ours AND the client's.

    py addons/tools/check_cites.py            the drifted ones
    py addons/tools/check_cites.py --all      every citation, resolved or not
    py addons/tools/check_cites.py --doc X    one document
    py addons/tools/check_cites.py --repo     OURS only - skip the client entirely

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

★★★ THE CLIENT HALF, ADDED 2026-08-26, AND IT WAS A BLIND SPOT RATHER THAN A GAP.

The matcher required `[a-z_][a-z0-9_]*\.lua` - lowercase-initial, underscores only. That admits
`routes.lua` and refuses `AceGUI-3.0.lua`, `TriggerTemplates.lua`, `Core.lua`. ⚠⚠ A refused
citation was not reported as unresolvable; it was **never counted at all**, so this tool printed
`resolved 8 / past-end 0` for a document whose four library citations it had not looked at.

    MEASURED before the fix:  491 citations SEEN
                              169 INVISIBLE, across 59 distinct files and six benches

★ 26% of the corpus, and precisely the half most likely to rot - the client is updated out of
band by someone who has never read these documents.

⚠⚠ AND THE CLIENT MULTIPLIES THE AMBIGUITY THIS TOOL ALREADY KNEW ABOUT. Six addons in THIS
repo carry `core.lua`; the client carries **22 copies of `AceConfigDialog-3.0.lua`** - and they
are not the same file. Ours is `MINOR = 49` and honours `dialogControl` on 3 option types;
`AI_VoiceOver` ships `MINOR = 78` and honours it on 10. ⟶ So for a client basename this tool
reports the COPY COUNT and **whether the copies agree about the cited line**, which is the only
honest answer when a name resolves 22 ways. (ROUTER carries the LibStub consequence.)

★★★ NOTHING IN THE CLIENT HALF IS FATAL, and that is deliberate. A past-end in a file we do not
own says the CLIENT moved, which is news the reader wants and not a defect in the document at
the moment it is read. The rule this tool already learned holds: **a gate must be capable of
being green on correct input, or it is not a gate - it is noise with an exit code.**
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
# ⚠⚠ THE BASENAME CLASS WAS THE BLIND SPOT (see the header). `[a-z_][a-z0-9_]*` refused every
# capitalised or hyphenated filename - which is every library and every client file - and
# refused them SILENTLY, before the denominator. Widened to admit `AceGUI-3.0.lua` and
# `TriggerTemplates.lua`. ★ Group numbering is unchanged: 1 folder, 2 basename, 3 line.
CITE = re.compile(
    r"\b(?:([A-Za-z_][A-Za-z0-9_]*)/)?([A-Za-z0-9_][A-Za-z0-9_.\-]*\.lua):(\d+)(?:\s*-\s*(\d+))?")

# ★ THE CLIENT, by the same hardcoded convention its sibling tools already use
# (`check_sheet.py`, `emit_ace_scope.py`, `emit_census.py`). ⚠ READ-ONLY, always.
CLIENT = r"F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns"


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


def find_client(basename, cache={}):
    """Every CLIENT path carrying that filename. ⚠ One walk, cached; the tree is large."""
    if not cache:
        cache["_"] = True
        for dirpath, dirnames, filenames in os.walk(CLIENT):
            dirnames[:] = [d for d in dirnames if d not in ("__pycache__", ".git")]
            for f in filenames:
                if f.endswith(".lua"):
                    cache.setdefault(f, []).append(os.path.join(dirpath, f))
    return cache.get(basename, [])


def client_verdict(basename, n):
    """★★★ THE HONEST ANSWER WHEN A NAME RESOLVES 22 WAYS: how many copies, and do they AGREE?

    ⚠ Picking one copy would be the §468 fault in a new coat - and worse here than in the
    repo, because the copies genuinely DIFFER (`AceConfigDialog-3.0.lua` is MINOR 49 in ours
    and MINOR 78 in AI_VoiceOver, with different content at every line).

    Returns (copies, holds, text) - `holds` is how many copies have a line `n` at all, and
    `text` is that line IF every copy agrees on it, else None.
    """
    hits = find_client(basename)
    if not hits:
        return 0, 0, None
    seen, holds = set(), 0
    for h in hits:
        body = lines_of(h)
        if body is None or n > len(body):
            continue
        holds += 1
        seen.add(body[n - 1].strip()[:96])
    return len(hits), holds, (seen.pop() if len(seen) == 1 else None)


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

    skip_client = "--repo" in argv
    missing_file, past_end, resolved, ambiguous = [], [], [], []
    # ★ THE CLIENT'S OWN BUCKET. Kept apart from `resolved` deliberately: a line in a file we
    # do not own is a weaker fact than a line in ours, and merging them would let the summary
    # claim a confidence the client half cannot support.
    client = []

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
                    # ★★★ NOT IN OUR REPO - so ASK THE CLIENT before calling it absent.
                    # ⚠ Before this branch existed, 169 citations died here silently: the
                    # matcher never even offered them, so they were not in this list either.
                    if not skip_client:
                        copies, holds, text = client_verdict(lua, n)
                        if copies:
                            client.append((where, m.group(0), copies, holds, text))
                            continue
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

    # ★★★ THE CLIENT HALF. Three verdicts, and the middle one is the whole point.
    if client:
        gone = [c for c in client if c[3] == 0]
        split = [c for c in client if c[3] and c[2] > 1 and c[4] is None]
        print("")
        print("   CLIENT FILES - %d citation(s) into code we do not own" % len(client))
        for where, cite, copies, holds, text in client:
            if holds == 0:
                print("   ~!  CLIENT MOVED   %-26s at %-30s (%d cop%s, none has that line)"
                      % (cite, where, copies, "y" if copies == 1 else "ies"))
            elif copies > 1 and text is None:
                print("   ~   COPIES DISAGREE %-25s at %-30s (%d copies, %d have the line,"
                      " and they do NOT say the same thing)" % (cite, where, copies, holds))
            elif copies > 1:
                print("   ok  %-40s at %-30s (%d copies, all agree)"
                      % (cite, where, copies))
            else:
                print("   ok  %-40s at %s" % (cite, where))
        if gone:
            print("       ~! THE CLIENT MOVED UNDER THE DOCUMENT. Not a fault at the time it")
            print("          was written, and not fatal - but the citation is now wrong.")
        if split:
            print("       ★★★ `COPIES DISAGREE` IS THE ONE TO ACT ON. The name resolves several")
            print("           ways and the copies differ, so the citation does not identify code.")
            print("           ⟶ Qualify it with the OWNING ADDON, and see ROUTER on LibStub:")
            print("             the copy that RUNS is the highest MINOR any enabled addon ships,")
            print("             which may be none of the ones you read.")

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
    if client:
        print("   client   %d   (moved %d   copies-disagree %d)   \u2014 none fatal, see the header"
              % (len(client),
                 len([c for c in client if c[3] == 0]),
                 len([c for c in client if c[3] and c[2] > 1 and c[4] is None])))
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
