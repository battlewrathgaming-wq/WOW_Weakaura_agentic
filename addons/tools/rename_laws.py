# -*- coding: utf-8 -*-
r"""rename_laws.py - give every DungeonRun law a unique name, and PROVE nothing was orphaned.

    py addons/tools/rename_laws.py              DRY RUN - what would change, and what would not
    py addons/tools/rename_laws.py --apply      write it
    py addons/tools/rename_laws.py --verify     after applying: is any bare L-N left?

★★★ WHY IT IS A TOOL. Battlewrath, 2026-08-25: *"Let's make laws unique. By addon, then primary
concern as one word. DR_UI, DR_Content. And so on, then number."* ⟶ AL-61 had declined a rename the
day before, and its reason was a COST: *"renaming ours would break the citations for a fault
qualification fixes."* **That cost is real - 600 citation sites across 64 files - and it is exactly
the kind a machine pays and a hand pass does not.** A rename that misses citations MANUFACTURES the
ambiguity it was ordered to remove.

★★ THE NUMBER IS KEPT. `L3` becomes `DR_UI_3`, never `DR_UI_1`. Renumbering inside each concern
would read tidier and would break the one property that makes this reversible and checkable: **600
existing citations map 1:1 by their number.** Sparse sequences inside a concern are cosmetic; a
lost citation trail is not.

⚠ SCOPE: THE DUNGEON RUN SERIES ONLY. `landmark_design.md` and `satnav_ledger.md` carry their own
L-series and are other benches' documents - **cross-bench reference is allowed, writing their docs
is not.** ⟶ So this removes DR from the collision and leaves LM-vs-SN to them. That is progress
rather than a half-measure: DR is the series that actually bit (§540, `row.md` vs three different
"law 4"s).

⚠⚠ WHAT IT WILL NOT TOUCH, and each is deliberate:
  · files under `history/` and `archive/` - a superseded record says what it said
  · the OTHER products' documents, by the lane rule above
  · a bare number inside a QUOTED sentence of someone's words is still rewritten, because a
    citation is a POINTER and a pointer that no longer resolves is worse than a tidy quote.
    ⟶ Reported per file so the reviewer sees where that happened.
"""

import io
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PLANNING = os.path.join(ROOT, "addons", "planning")

# ★ THE CONCERN MAP - the only judgement in this file, and it is DATA so it can be argued with.
#   Five concerns, every one holding at least two laws. Coarse on purpose: his examples were
#   `DR_UI` and `DR_Content`, and a nine-way split with singletons is a taxonomy, not a name.
CONCERN = {
    "UI":       [3, 21, 22],              # what the author sees and touches
    "Content":  [1, 2, 5, 10, 11, 15, 17, 20],   # what a route IS and what it carries
    "Runtime":  [7, 8, 9, 12, 16],        # what happens while it runs
    "Boundary": [4, 6],                   # who may depend on whom
    "Process":  [13, 14, 18, 19],         # how we work
}
NAME = {n: "DR_%s_%d" % (c, n) for c, ns in CONCERN.items() for n in ns}

# the DungeonRun document set - the same scope the law pass used
KEEP = re.compile(r"^(driver_|dungeonrun_|ARCHITECT_|ANALYST_|Reconcile_inbox|UI_LOG|DRIVER_BASIS)")
SKIPDIR = {"history", "archive", "__pycache__"}
# ⚠ `\bL(\d+)\b` only. `law 4` in prose is NOT rewritten - it is ambiguous by construction and
#   rewriting it would be guessing which series a sentence meant. Reported instead.
CITE = re.compile(r"\bL([0-9]{1,2})\b")
PROSE = re.compile(r"\blaw\s+([0-9]{1,2})\b", re.I)


def files():
    for base, dirs, fs in os.walk(PLANNING):
        dirs[:] = [d for d in dirs if d not in SKIPDIR]
        for f in sorted(fs):
            if f.endswith(".md") and (KEEP.match(f) or "concepts" in base):
                yield os.path.join(base, f)


def main():
    argv = sys.argv[1:]
    apply_it, verify = "--apply" in argv, "--verify" in argv

    print("")
    print("   RENAME THE DUNGEON RUN LAWS - unique by addon + concern, number kept")
    print("   " + "-" * 70)
    for c in sorted(CONCERN):
        print("   DR_%-9s %s" % (c, " ".join("L%d" % n for n in sorted(CONCERN[c]))))
    missing = sorted(set(range(1, 23)) - set(NAME))
    if missing:
        print("   [!] UNMAPPED: %s - refusing to run" % missing)
        return 2
    print("   " + "-" * 70)

    changed = hits = prose = 0
    for p in files():
        body = io.open(p, encoding="utf-8", errors="replace").read()
        n_c = len([m for m in CITE.finditer(body) if 1 <= int(m.group(1)) <= 22])
        n_p = len(PROSE.findall(body))
        if not n_c and not n_p:
            continue
        rel = os.path.relpath(p, PLANNING).replace("\\", "/")
        if verify:
            if n_c:
                print("   [!] %-46s %3d bare L-N still present" % (rel, n_c))
            continue
        hits += n_c
        prose += n_p
        if n_c:
            changed += 1
        print("   %-46s %3d cite%s%s" % (rel, n_c, " " if n_c == 1 else "s",
                                         "   (+%d prose 'law N', left alone)" % n_p if n_p else ""))
        if apply_it and n_c:
            out = CITE.sub(lambda m: NAME.get(int(m.group(1)), m.group(0))
                           if 1 <= int(m.group(1)) <= 22 else m.group(0), body)
            io.open(p, "w", encoding="utf-8", newline="\n").write(out)

    print("   " + "-" * 70)
    if verify:
        print("   ⚠ VERIFY: any line above is an ORPHAN - a citation the sweep did not reach.")
        print("     Silence here is the only clean result.")
        return 0
    print("   %d citation(s) in %d file(s)%s" % (hits, changed,
          "   ·  %d prose \"law N\" left alone" % prose if prose else ""))
    print("")
    print("   ⚠ PROSE `law N` IS NOT REWRITTEN. It is ambiguous by construction - three different")
    print("     \"law 4\"s exist (this series · `concepts/pane-build.md` · `satnav_ledger.md`) - and")
    print("     rewriting it would be GUESSING which series a sentence meant. ⟶ Those are a READ,")
    print("     listed above so nobody mistakes the silence for coverage.")
    if not apply_it:
        print("")
        print("   DRY RUN. Nothing written. `--apply` to write, then `--verify`.")
    print("")
    return 0


if __name__ == "__main__":
    sys.exit(main())
