# -*- coding: utf-8 -*-
r"""emit_divergence.py - the GOVERNING SET against the SHIPPED CODE, both directions.

    py addons/tools/emit_divergence.py              the register
    py addons/tools/emit_divergence.py --doc X      one governing document
    py addons/tools/emit_divergence.py --quiet      counts only

★★★ WHY THIS EXISTS. `emit_built_state.py` reads the FIVE acceptance briefs. The governing set
is THIRTEEN documents (`DRIVER_BASIS.md`), and the other eight - the data model, the programmatic
model, the scoping, the user journey, ROUTER - are read by NO tool at all. ⟶ A function the data
model names and the code does not have has been invisible to every check we own.

⚠⚠ THIS ANSWERS A NAMING QUESTION AND NOTHING MORE, and that limit is the whole reason it is
safe. §497 measured `emit_built_state`'s STRANDED bucket **47% WRONG** because a name search was
answering a question about USE - aliased calls were invisible to it. So:

    IT CAN SAY      does the governing set MENTION this identifier
                    does the code DEFINE this identifier
    IT CANNOT SAY   is it CALLED · is it REACHABLE · is it CORRECT · is it NEEDED

★ Both of those are naming questions, and a name search answers naming questions exactly.
[[a-name-is-not-a-use]] is not violated by asking whether a name appears; it is violated by
concluding USE from the answer. **Nothing below concludes use.**

⚠ AND IT RAISES NO ALARM. Every row is a DIVERGENCE, which is a fact about two records
disagreeing - not a defect, not a severity, not a ranking. Where a divergence is expected (a
doc written ahead of the build is the normal state of this project) it is still printed, because
the register's value is completeness rather than a shortlist.

    DOC AHEAD    the governing set names it; the code does not define it.
                 ⟶ ROUTES TO DESIGN when the doc is a model/scoping doc (is it still intended?),
                   or TO THE CREATOR when it is a build item already agreed.
    CODE AHEAD   the code defines it; no governing document names it.
                 ⟶ ROUTES TO THE CREATOR (does it want a governing home?) - and a great many
                   are ordinary internals that never will, which is why this side is INFORMATIONAL.
"""

import io
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from check_retired import MARKED, WINDOW          # noqa: E402  the ONE definition of a headstone

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
REPO = os.path.dirname(ROOT)
SOURCE = os.path.join(ROOT, "COA_DungeonRun")

# ⚠ A MIRROR OF `check_targets.py`'s mirror of `DRIVER_BASIS.md`. Three copies is two too many
# and it is recorded rather than hidden: the authority is DRIVER_BASIS, `check_targets` fails on
# drift against it, and this list is read FROM check_targets at run time so it cannot drift
# separately. ★ One hand-kept list, not three.
def governing():
    src = io.open(os.path.join(HERE, "check_targets.py"), encoding="utf-8").read()
    # ⚠⚠ ANCHOR ON THE CLOSING PAREN AT COLUMN 0, not the first ")" - the first run of this
    # tool read EIGHT of the thirteen because a comment inside the tuple says "(2026-08-18)"
    # and the naive split stopped there. ★ A scope that silently excluded five governing
    # documents, in the tool written to find exactly that. Recorded, not tidied away.
    block = re.search(r"GOVERNING = \((.*?)\n\)", src, re.S).group(1)
    out = []
    for m in re.finditer(r'"([^"]+\.md)"', block):
        p = os.path.join(REPO, m.group(1))
        if os.path.exists(p):
            out.append((m.group(1), p))
    return out


# `Ns.Fn` — the shape this codebase uses for every public function.
NAMED = re.compile(r"\b([A-Z][A-Za-z0-9]*)\.([A-Z][A-Za-z0-9_]*)\b")
# ⚠⚠ A DEFINITION IS ANY ASSIGNMENT, NOT ONLY `= function`. The first run reported
# `Bucket.BAND_DEFAULT`, `Bucket.Resolve` and `Routes.ROW_ARG_RULE` as "the doc names it, the
# code lacks it" — all three are DEFINED, as a number, a deliberate `nil` seam and a table.
# ★ A tool that only recognises one shape of definition reports the other shapes as absent.
DEFINED = re.compile(r"^\s*(?:function\s+([A-Z]\w*)\.([A-Za-z_]\w*)\s*\(|"
                     r"([A-Z]\w*)\.([A-Za-z_]\w*)\s*=)", re.M)

# ⚠ STATED EXCLUSIONS, because an unexplained one is the scope fault this project keeps finding.
#   · WoW/Lua API and libraries are not ours to govern.
#   · A doc naming `Foo.md` or `Section.A` is prose, not an identifier.
NOT_OURS = ("C_", "Blizzard", "Lib", "Ace", "WeakAuras", "GameTooltip", "Unit",
            "String", "Table", "Math", "Get", "Set", "Is", "Has")

# ★★ NAMED BY OUR DOCS AND NOT OURS TO DEFINE — a THIRD bucket rather than a silent exclusion.
# `SuperTrackerUtil` is the CLIENT's; `Beacon` is COA_Landmarks'; `AscensionUI` is the fork's;
# `Private` is WeakAuras'. ⚠ Excluding them quietly would hide a real class of dependency —
# RI-71 exists because `SuperTrackerUtil` is ASSUMED and never verified on this fork. ⟶ So they
# are printed, as VERIFICATION items rather than build items.
EXTERNAL = ("SuperTrackerUtil", "AscensionUI", "Beacon", "Private", "Landmarks")


# ★★★ THE SECOND AXIS, AND IT IS THE ONE THAT PAYS. The identifier axis above came back CLEAN —
# every apparent divergence resolved to a headstone or an external dependency. That is worth
# knowing and it is not where the drift is. ⟶ The drift is in CLOSED LISTS: `ROW_ACTIONS`,
# `SENSE_WORDS`, `ROLES`, `ROW_ARG` — the vocabularies a route may name. RI-58 and RI-59 are both
# this shape: a pane gating on `{supertrack}` when the ruled list is `{boss, note, say}`, and a
# migration hardcoding `whenOn` when three sense words are ruled.
#
# ⚠ A list is DECLARED in exactly one place and QUOTED in many. This compares the declaration
# against every quotation, which is a text question about text — the same honest scope as above.
LIST = re.compile(r"^\s*(?:local\s+)?([A-Z]\w*)\.([A-Z][A-Z0-9_]{2,})\s*=\s*\{([^}]*)\}",
                  re.M)
WORD = re.compile(r'"([a-zA-Z][\w ]*)"')


def vocabularies():
    """Every closed list the product DECLARES, as {name: [members]}."""
    out = {}
    for f in sorted(os.listdir(SOURCE)):
        if not f.endswith(".lua"):
            continue
        body = io.open(os.path.join(SOURCE, f), encoding="utf-8", errors="replace").read()
        for m in LIST.finditer(body):
            key = "%s.%s" % (m.group(1), m.group(2))
            members = WORD.findall(m.group(3))
            if members:
                out[key] = (members, f)
    return out


def ours(ns):
    if ns in ("NS", "F"):
        return False
    return not any(ns.startswith(p) for p in NOT_OURS) or ns in ("UI",)


def main():
    argv = sys.argv[1:]
    quiet = "--quiet" in argv
    only = argv[argv.index("--doc") + 1] if "--doc" in argv else None

    # ---- the code, as it stands
    defined, where = set(), {}
    for f in sorted(os.listdir(SOURCE)):
        if not f.endswith(".lua"):
            continue
        body = io.open(os.path.join(SOURCE, f), encoding="utf-8", errors="replace").read()
        for m in DEFINED.finditer(body):
            ns, fn = (m.group(1), m.group(2)) if m.group(1) else (m.group(3), m.group(4))
            defined.add("%s.%s" % (ns, fn))
            where.setdefault("%s.%s" % (ns, fn), f)

    # ---- the governing set, as it reads
    #
    # ★★★ A NAME INSIDE A HEADSTONE IS A QUOTATION, NOT A CLAIM — and this is the finding that
    # shaped the tool. The first run reported `Rule.OPEN` against FOUR governing documents and
    # `Routes.SetChildFireOn` against one. Both are RETIRED, and every mention is a record of
    # the retirement: `rule.lua` itself opens with *"THERE IS NO `Rule.OPEN`, AND ITS ABSENCE IS
    # THE POINT"*. ⟶ This project KEEPS headstones on purpose
    # ([[half-formed-code-invites-building-on-it]]), so a tool that cannot read one reports our
    # own discipline as drift.
    #
    # ★ The window and the marker vocabulary are READ FROM `check_retired.py` rather than
    # re-stated, so there is one definition of "this text records a retirement" and not two.
    named, quoted = {}, {}
    for rel, path in governing():
        if only and only not in rel:
            continue
        lines = io.open(path, encoding="utf-8", errors="replace").read().split("\n")
        for i, line in enumerate(lines):
            lo, hi = max(0, i - WINDOW), min(len(lines), i + WINDOW + 1)
            headstone = any(MARKED.search(lines[j]) for j in range(lo, hi))
            for m in NAMED.finditer(line):
                ns, fn = m.group(1), m.group(2)
                if not ours(ns):
                    continue
                key = "%s.%s" % (ns, fn)
                bucket = quoted if headstone else named
                bucket.setdefault(key, set()).add(os.path.basename(rel))
    # a name that appears ONLY inside headstones is a record, never a divergence
    for k in list(quoted):
        if k in named:
            del quoted[k]

    external = sorted(k for k in named if k.split(".")[0] in EXTERNAL)
    doc_ahead = sorted(k for k in named
                       if k not in defined and k.split(".")[0] not in EXTERNAL)
    code_ahead = sorted(k for k in defined if k not in named)

    print("")
    print("   DIVERGENCE — the governing set against the shipped code")
    print("   " + "-" * 66)
    print("   governing documents read   %d" % len(governing() if not only else [1]))
    print("   identifiers the code DEFINES   %d" % len(defined))
    print("   identifiers the docs NAME      %d" % len(named))
    print("")

    if not quiet:
        print("   ⟶ DOC AHEAD — named LIVE by a governing document, not defined in the code")
        print("     (the normal state of a doc written before its build; listed, not flagged)")
        print("")
        for k in doc_ahead:
            print("       %-34s %s" % (k, " · ".join(sorted(named[k]))))
        print("")
        print("   ⟶ NAMED BY OUR DOCS, NOT OURS TO DEFINE — verification items, not build items")
        print("")
        for k in external:
            print("       %-34s %s" % (k, " · ".join(sorted(named[k]))))
        print("")
        print("   ~ %d identifier(s) appear ONLY inside a headstone and are NOT divergences:"
              % len(quoted))
        for k in sorted(quoted):
            print("       %-34s %s" % (k, " · ".join(sorted(quoted[k]))))
        print("")
        # ⚠ PER NAMESPACE, NOT PER FUNCTION. Printed per function this side was 315 rows —
        # noise with an exit code, and nobody reads 315 rows. A NAMESPACE the governing set
        # never names is the finding; a helper inside a governed one is not.
        ns_named = set(k.split(".")[0] for k in named)
        ns_all = {}
        for k in code_ahead:
            ns_all.setdefault(k.split(".")[0], []).append(k)
        print("   ⟶ CODE AHEAD — by NAMESPACE, because per-function this side is 300+ rows")
        print("     (a namespace no governing document names has no governing home at all)")
        print("")
        for ns in sorted(ns_all):
            mark = " " if ns in ns_named else "★ UNGOVERNED"
            print("       %-14s %3d function(s) unnamed   %s" % (ns, len(ns_all[ns]), mark))
        print("")

    # ---- the vocabulary axis
    vocab = vocabularies()
    docs = {}
    for rel, path in governing():
        docs[os.path.basename(rel)] = io.open(path, encoding="utf-8",
                                              errors="replace").read()
    print("   ⟶ CLOSED LISTS — the declaration, and whether the governing set quotes it whole")
    print("")
    for key in sorted(vocab):
        members, f = vocab[key]
        short = key.split(".")[1]
        cites = [d for d, body in docs.items() if short in body]
        if not cites:
            print("       %-22s %-34s %s" % (key, ", ".join(members), "— no governing doc names it"))
            continue
        for d in sorted(cites):
            missing = [w for w in members if w not in docs[d]]
            extra = ""
            if missing:
                extra = "⟶ %s does NOT appear in %s" % (", ".join(missing), d)
            print("       %-22s %-26s %s" % (key if d == sorted(cites)[0] else "", d, extra))
    print("")

    print("   doc-ahead %d   external %d   headstoned %d   code-ahead %d"
          % (len(doc_ahead), len(external), len(quoted), len(code_ahead)))
    print("")
    print("   ⚠ A NAMING QUESTION ONLY. This says whether an identifier APPEARS on each side.")
    print("     It says nothing about whether anything is CALLED, reachable, correct or needed —")
    print("     which is the distinction §497 measured at 47% wrong when it was blurred.")
    print("")
    return 0


if __name__ == "__main__":
    sys.exit(main())
