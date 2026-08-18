# -*- coding: utf-8 -*-
r"""match_api_terms.py - take a list of API names and ask three corpora whether this
fork has ever been seen using them.

    py addons\tools\match_api_terms.py addons\staging\ace_api_wotlk-r960.txt

★★★ WHY THIS EXISTS. I asserted twice in one session that a client API was absent -
`C_Timer` and `SetDesaturation` - and both are REAL here. The first is recorded in
`operations/ROUTER.md:75` with the reason a name search would agree with me:

    "It enumerates as an EMPTY table in the 51,855-global census, so a name search
     finds nothing while it works perfectly - a name search proving absence proves
     nothing."

⚠⚠ SO THIS TOOL REPORTS MATCHES AND NEVER PROVES ABSENCE, and it says so on the
output. A NO MATCH is a question to take to the client, not a finding.

★ THE THREE CORPORA ARE NOT EQUAL EVIDENCE, so they are never summed:

    ROUTER      the client FACTS file (governing #8). A row here is a MEASURED fact
                about this fork and outranks every other column.
    OURS        our own addons. Code WE wrote and ran here - the strongest corpus
                evidence, because we know it shipped and worked.
    ADDON       third-party addon code on this client. Independent evidence that the
                field calls it here.
    VENDORED    third-party LIBRARY code (libs/, Libs/, Ace3, AceGUI-3.0 ...). ⚠ Kept
                SEPARATE because it is circular for this question: Bartender4's own
                copy of AceGUI calling a method tells us what AceGUI calls, which is
                what we already knew. It counts only as "shipped alongside something
                that works", which is weak and must not read as strong.

⚠ AND A CALL SITE IS NOT A SUCCESS. ROUTER makes the same point about `UnitPosition`:
"a pcall call site is evidence of an ATTEMPT, not of existence". A name can be called
by fifty addons and silently do nothing. This measures REACH, not outcome.
"""

import io
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CLIENT = r"F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns"
ROUTER = os.path.join(REPO, "operations", "ROUTER.md")
OURS = os.path.join(REPO, "addons")

# ⚠ A path is VENDORED if any segment names a library folder. Checked on segments, not
# as a substring - "libs" inside a filename is not a library directory.
VENDOR_SEG = {"libs", "lib", "libraries", "ace3", "external", "embeds"}
VENDOR_PREFIX = ("ace", "callbackhandler", "libstub", "lib-", "lib_")


def is_vendored(relpath):
    for seg in relpath.replace("\\", "/").split("/")[:-1]:
        low = seg.lower()
        if low in VENDOR_SEG or low.startswith(VENDOR_PREFIX):
            return True
    return False


def read(path):
    try:
        return io.open(path, encoding="utf-8", errors="replace").read()
    except OSError:
        return ""


# ⚠⚠ TWO FAULTS IN THIS TOOL'S FIRST RUN, both found by checking its own output rather
# than by it failing. Both inflated OURS - the column a reader would trust most.
#
#   1. `addons/refs_recount/`, `addons/refs_threat/` are THIRD-PARTY REFERENCE COPIES
#      living inside our own tree, and they carry their own AceGUI. Counting them as
#      "ours" is the exact circularity the docstring above rejects for the client
#      corpus - applied to one side only.
#   2. `addons/landing/raw/*census*.lua` is not code at all. It is a CAPTURE OF THE
#      CLIENT'S GLOBAL TABLE, and matching a name in it means something quite
#      different and rather stronger: the name was PRESENT IN `_G` when we looked.
#      ★ It gets its own column, and it applies to GLOBALS ONLY - a frame method
#      never appears in `_G`, so a census hit on one would be a coincidence.
CENSUS_RE = re.compile(r"census", re.I)
OURS_SKIP_SEG = {"landing", "staging", "dependencies"}


def classify_ours(rel):
    segs = rel.replace("\\", "/").split("/")[:-1]
    if any(s.lower() in OURS_SKIP_SEG for s in segs):
        return "skip"
    if any(s.lower().startswith("refs_") for s in segs) or is_vendored(rel):
        return "vendored"
    return "ours"


def corpus(root, split_vendor):
    """-> list of (relpath, text, vendored)"""
    out = []
    for dp, _, fns in os.walk(root):
        for f in fns:
            if not f.endswith(".lua"):
                continue
            full = os.path.join(dp, f)
            rel = os.path.relpath(full, root)
            out.append((rel, read(full), split_vendor and is_vendored(rel)))
    return out


def census_texts(root):
    out = []
    for dp, _, fns in os.walk(os.path.join(root, "landing")):
        for f in fns:
            if f.endswith(".lua") and CENSUS_RE.search(f):
                out.append(read(os.path.join(dp, f)))
    return out


def main():
    if len(sys.argv) < 2:
        print(__doc__.strip().splitlines()[2])
        return 2
    names, kinds = [], {}
    for line in io.open(sys.argv[1], encoding="utf-8"):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        kind, _, name = line.partition("\t")
        if name:
            names.append(name)
            kinds[name] = kind

    router = read(ROUTER)
    ours_all = corpus(OURS, False)
    ours = [(r, t, False) for r, t, _ in ours_all if classify_ours(r) == "ours"]
    ours_vend = [(r, t, True) for r, t, _ in ours_all if classify_ours(r) == "vendored"]
    census = census_texts(OURS)
    client = corpus(CLIENT, True)
    print("corpora: ROUTER %d bytes | census %d capture(s) | ours %d files "
          "(%d ref/vendored set aside) | client %d files (%d vendored)"
          % (len(router), len(census), len(ours), len(ours_vend), len(client),
             sum(1 for _, _, v in client if v)))

    # ⚠ WORD-BOUNDARY, not substring. `SetValue` must not match `SetValueStep`, which is
    # a DIFFERENT API and the reason the two appear separately here.
    # ★ ONE ALTERNATION, ONE PASS PER FILE. Per-name scanning was 48 passes over 1936
    # client files - 392 MB including multi-megabyte pfQuest data tables - and did not
    # finish in two minutes. Same answer, one read.
    scan = re.compile(r"(?<!\w)(%s)(?!\w)" % "|".join(re.escape(n) for n in names))

    def tally_corpus(files, want_vendored=None):
        hits = {}
        for _, text, vend in files:
            if want_vendored is not None and vend != want_vendored:
                continue
            for m in set(scan.findall(text)):
                hits[m] = hits.get(m, 0) + 1
        return hits

    router_hits = set(scan.findall(router))
    census_hits = set()
    for t in census:
        census_hits |= set(scan.findall(t))
    ours_hits = tally_corpus(ours)
    addon_hits = tally_corpus(client, want_vendored=False)
    vend_hits = tally_corpus(client, want_vendored=True)
    vend_hits_ours = tally_corpus(ours_vend)

    rows = []
    for n in names:
        in_router = n in router_hits
        # ★ GLOBALS ONLY. A frame method is not in `_G`, so a census hit on one would
        # be a coincidence rather than evidence, and must not read as a verdict.
        in_census = kinds[n] == "global" and n in census_hits
        n_ours = ours_hits.get(n, 0)
        n_addon = addon_hits.get(n, 0)
        n_vend = vend_hits.get(n, 0) + vend_hits_ours.get(n, 0)

        if in_router:
            verdict = "ROUTER"
        elif in_census:
            verdict = "CENSUS"
        elif n_ours:
            verdict = "OURS"
        elif n_addon:
            verdict = "ADDON"
        elif n_vend:
            verdict = "vendored-only"
        else:
            verdict = "NO MATCH"
        rows.append((verdict, kinds[n], n, in_router, in_census, n_ours, n_addon, n_vend))

    RANK = {"ROUTER": 0, "CENSUS": 1, "OURS": 2, "ADDON": 3,
            "vendored-only": 4, "NO MATCH": 5}
    rows.sort(key=lambda r: (RANK[r[0]], r[1], r[2]))

    print()
    print("  %-14s %-7s %-24s %6s %6s %6s %6s %6s"
          % ("verdict", "kind", "name", "ROUTER", "census", "ours", "addon", "vend"))
    for v, k, n, ir, ic, no, na, nv in rows:
        print("  %-14s %-7s %-24s %6s %6s %6d %6d %6d"
              % (v, k, n, "yes" if ir else "-", "yes" if ic else "-", no, na, nv))

    tally = {}
    for r in rows:
        tally[r[0]] = tally.get(r[0], 0) + 1
    print()
    print("  " + " · ".join("%s %d" % (k, tally[k])
                            for k in sorted(tally, key=lambda x: RANK[x])))
    print("  ⚠ NO MATCH is a QUESTION for the client, never a finding: a name search "
          "proving absence proves nothing (ROUTER:75).")
    print("  ⚠ A call site is REACH, not success - ROUTER's own `UnitPosition` row.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
