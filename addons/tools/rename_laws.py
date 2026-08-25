# -*- coding: utf-8 -*-
r"""rename_laws.py - give every DungeonRun law a unique name, and PROVE nothing was orphaned.

    py addons/tools/rename_laws.py              DRY RUN - what changes, what is REFUSED, and why
    py addons/tools/rename_laws.py --apply      write it
    py addons/tools/rename_laws.py --verify     after applying: any bare L-N left that should not be

★★★ WHY IT IS A TOOL. Battlewrath, 2026-08-25: *"Let's make laws unique. By addon, then primary
concern as one word."* — and on the cost AL-61 had weighed: *"Cost isn't a concern when we can't
discuss the same thing."* ⟶ 600 citation sites is exactly the size a machine pays and a hand pass
does not, and **a rename that misses citations MANUFACTURES the ambiguity it was ordered to remove.**

⚠⚠⚠ THE DEFECT THIS FILE WAS REBUILT AROUND, and it would have been SILENT. The first version swept
`\bL(\d+)\b` repo-wide against ONE map. But **`driver_sensor_brief.md` defines its own `L1..L8`
using the identical token** - so `L4` in that file is the SENSOR's fourth law, and the sweep would
have rewritten it to `DR_Boundary_4`, relabelling a sensor law as a macro law across 11 citations
**with nothing to notice.** ⟶ Found by asking how each series is actually CITED instead of assuming
one form. ★ THE TOKEN IS NOT THE LAW; THE TOKEN PLUS ITS FILE IS.

★★ SO THE RULE IS SCOPED, NEVER GLOBAL:

    inside driver_sensor_brief.md    every bare L-N is DR_Sensor_N          (its own series)
    inside concepts/pane-build.md    every bare `law N` is DR_Pane_N        (its own, prose-cited)
    inside concepts/type-or-feature  every bare `law N`/`N` is DR_TypeOrFeature_N
    everywhere else                  bare L-N resolves through the §5 CONCERN map
    a QUALIFIED cross-cite           `sensor brief L3` -> DR_Sensor_3, and the like

⚠ AND WHAT IT REFUSES, out loud. A bare `law N` in a file that does NOT own a series is AMBIGUOUS
BY CONSTRUCTION - three different "law 4"s exist. **Rewriting it would be guessing which series a
sentence meant**, so it is listed for a human read and left untouched. ★ The refusal count is
printed beside the rewrite count so the tool's silence is never mistaken for coverage.

⚠⚠ AND THE LIMITATION THAT BIT ON THE FIRST APPLY, kept because it will bite again. The scope
rule is PER FILE, and a file can contain a sentence ABOUT ANOTHER PRODUCT'S series. §5 carried
*"`landmark_design.md` has its own L-series — its L17/L18 are different laws"*, and the sweep
rewrote those two into DungeonRun names **inside the sentence explaining they are not ours.**
⟶ Repaired by hand the same run. ★ THE TOKEN'S MEANING DEPENDS ON THE SENTENCE, NOT ONLY THE FILE,
and no regex reads a sentence. **The check is a grep after applying:** `DR_` near `landmark` or
`satnav`. Two hits, one real.

⚠ SCOPE: THE DUNGEON RUN SERIES ONLY. `landmark_design.md` and `satnav_ledger.md` carry their own
L-series and are other benches' documents - cross-bench reference is allowed, writing their docs is
not. This removes DR from the collision; LM-vs-SN stays theirs.

★ THE NUMBER IS KEPT. `L3` -> `DR_UI_3`, never `DR_UI_1`. Renumbering reads tidier and breaks the
one property that makes this reversible and checkable: **600 citations map 1:1 by their number.**

⚠ THE FILE COMPONENT IS NOT USED, and that is measured rather than preferred. His option was
`(Addon)(Concern)(N)(File)`. Every concern below belongs to exactly ONE file, so File would restate
what Concern already says - `DR_Sensor_1_sensor`. ⟶ Adding it is a one-line change to `NAME` the day
a concern spans two files, which is the day it starts carrying information.
"""

import io
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PLANNING = os.path.join(ROOT, "addons", "planning")

# ★ THE CONCERN MAP for the §5 macro series - the only judgement here, and it is DATA.
CONCERN = {
    "UI":       [3, 21, 22],
    "Content":  [1, 2, 5, 10, 11, 15, 17, 20],
    "Runtime":  [7, 8, 9, 12, 16],
    "Boundary": [4, 6],
    "Process":  [13, 14, 18, 19],
}
MACRO = {n: "DR_%s_%d" % (c, n) for c, ns in CONCERN.items() for n in ns}

# files that OWN a series: inside them, a bare law number means THEIR law
OWNS = {
    "driver_sensor_brief.md":       ("DR_Sensor_%d", re.compile(r"\bL([0-9]{1,2})\b")),
    "concepts/pane-build.md":       ("DR_Pane_%d", re.compile(r"\blaw\s+([0-9]{1,2})\b", re.I)),
    "concepts/type-or-feature.md":  ("DR_TypeOrFeature_%d",
                                     re.compile(r"\blaw\s+([0-9]{1,2})\b", re.I)),
}
# qualified cross-citations, rewritten because the qualifier says which series
QUALIFIED = [
    (re.compile(r"\bsensor[- ]brief\s+L([0-9]{1,2})\b", re.I), "DR_Sensor_%d"),
    (re.compile(r"`?pane-build`?\s+law\s+([0-9]{1,2})\b", re.I), "DR_Pane_%d"),
]

KEEP = re.compile(r"^(driver_|dungeonrun_|ARCHITECT_|ANALYST_|Reconcile_inbox|UI_|DRIVER_BASIS)")
SKIPDIR = {"history", "archive", "__pycache__"}
BARE_L = re.compile(r"\bL([0-9]{1,2})\b")
# ⚠ THE DEFINITION LINE. `pane-build` and `type-or-feature` DECLARE their laws as a bare number in
# a list - `    4  PLACEMENT WITHIN IS THE LIBRARY'S`. Renaming only the citations would leave the
# law itself still called `4`, which is half a rename and therefore worse than none: a reader would
# meet `DR_Pane_4` in one file and `4` in its home. ★ Found by reading the two files' actual form
# rather than assuming every series declares with an `L`.
DEF_BARE = re.compile(r"^(\s{2,8})([0-9]{1,2})(\s\s+)(?=[A-Z])", re.M)
BARE_LAW = re.compile(r"(?<!\w)law\s+([0-9]{1,2})\b", re.I)
# a line that NAMES another product's series - its bare tokens are theirs, not orphans
OTHER = re.compile(r"landmark|satnav|other product|its own L-series", re.I)


def targets():
    for base, dirs, fs in os.walk(PLANNING):
        dirs[:] = [d for d in dirs if d not in SKIPDIR]
        for f in sorted(fs):
            if not f.endswith(".md"):
                continue
            rel = os.path.relpath(os.path.join(base, f), PLANNING).replace("\\", "/")
            if KEEP.match(f) or rel.startswith("concepts/") or rel.startswith("interface/"):
                yield os.path.join(base, f), rel


def main():
    argv = sys.argv[1:]
    apply_it, verify = "--apply" in argv, "--verify" in argv

    print("")
    print("   RENAME THE DUNGEON RUN LAWS - unique by addon + concern; the number is kept")
    print("   " + "-" * 72)
    for c in sorted(CONCERN):
        print("   DR_%-13s %s" % (c, " ".join("L%d" % n for n in sorted(CONCERN[c]))))
    for f, (fmt, _) in sorted(OWNS.items()):
        print("   %-17s %s   (its own series, scoped to that file)"
              % (fmt.replace("_%d", ""), f))
    if sorted(MACRO) != list(range(1, 23)):
        print("   [!] the macro map is not 1..22 - refusing"); return 2
    print("   " + "-" * 72)

    rewrote = refused = 0
    rows, refusals = [], []
    for path, rel in targets():
        body = io.open(path, encoding="utf-8", errors="replace").read()
        out, n_rw, n_rf = body, 0, 0

        for pat, fmt in QUALIFIED:
            out, k = pat.subn(lambda m: fmt % int(m.group(1)), out)
            n_rw += k

        own = OWNS.get(rel)
        if own:
            fmt, pat = own
            out, k = pat.subn(lambda m: fmt % int(m.group(1))
                              if 1 <= int(m.group(1)) <= 22 else m.group(0), out)
            n_rw += k
            # and the DECLARATION itself, so the law's home carries its own name
            if rel != "driver_sensor_brief.md":       # that one already declares with `L`
                out, k = DEF_BARE.subn(
                    lambda m: "%s%s%s" % (m.group(1), fmt % int(m.group(2)), "  ")
                    if 1 <= int(m.group(2)) <= 22 else m.group(0), out)
                n_rw += k
        else:
            def macro(m):
                v = int(m.group(1))
                return MACRO.get(v, m.group(0)) if 1 <= v <= 22 else m.group(0)
            out, k = BARE_L.subn(macro, out)
            n_rw += k
            # ⚠ bare `law N` here is AMBIGUOUS - three series answer to it. Refuse, list it.
            for m in BARE_LAW.finditer(out):
                n_rf += 1
                refusals.append((rel, m.group(0)))

        if verify:
            # ⚠⚠ A DELIBERATE CROSS-PRODUCT REFERENCE IS NOT AN ORPHAN. §5 names
            # `landmark_design.md`'s L17/L18 precisely to say they are NOT ours, and an
            # earlier run rewrote them - so the repair restored bare tokens ON PURPOSE.
            # ★ A verify that reports known-good as a failure teaches the reader to scroll
            # past it, which is the false-stop shape: an inert guard fails to EARN trust,
            # a false stop SPENDS it. ⟶ So a line that NAMES another product is exempt,
            # and the exemption is counted out loud rather than hidden.
            left, exempt = [], 0
            for line in body.split("\n"):
                hits = [m.group(0) for m in BARE_L.finditer(line) if 1 <= int(m.group(1)) <= 22]
                if not hits:
                    continue
                if OTHER.search(line):
                    exempt += len(hits)
                else:
                    left.extend(hits)
            if left and not own:
                print("   [!] %-44s %3d bare L-N SURVIVED" % (rel, len(left)))
            elif exempt:
                print("   ok  %-44s %3d cross-product reference(s), exempt" % (rel, exempt))
            continue
        if n_rw or n_rf:
            rows.append((rel, n_rw, n_rf))
            rewrote += n_rw
            refused += n_rf
        if apply_it and out != body:
            io.open(path, "w", encoding="utf-8", newline="\n").write(out)

    if verify:
        print("   ⚠ any line above is an ORPHAN. Silence is the only clean result.")
        print("")
        return 0

    for rel, a, b in sorted(rows, key=lambda r: -r[1]):
        print("   %-46s %3d rewritten%s" % (rel, a, "   %3d REFUSED" % b if b else ""))
    print("   " + "-" * 72)
    print("   %d rewritten  ·  %d REFUSED as ambiguous" % (rewrote, refused))
    if refusals:
        print("")
        print("   ⚠⚠ REFUSED - a bare `law N` in a file that owns no series. Three different")
        print("      \"law 4\"s exist; rewriting these would be GUESSING which one was meant.")
        seen = {}
        for rel, txt in refusals:
            seen.setdefault(rel, []).append(txt)
        for rel in sorted(seen, key=lambda r: -len(seen[r])):
            print("      %-44s %2d   e.g. %s" % (rel, len(seen[rel]), seen[rel][0]))
        print("      ⟶ These are a READ, not a sweep.")
    if not apply_it:
        print("")
        print("   DRY RUN. Nothing written. `--apply`, then `--verify`.")
    print("")
    return 0


if __name__ == "__main__":
    sys.exit(main())
