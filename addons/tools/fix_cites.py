"""fix_cites.py - repair the intent shelf's drifted `Addon/file.lua:N` citations.

★★★ WHY IT REFUSES MORE THAN IT REPAIRS, and the reason is a defect it shipped once.

The first version repaired by NEAREST TAG AT OR BELOW the cited line, on the
reasoning that insertions only push a note down. That is true and it is not enough:
when a pass inserts MANY tags above a citation, the nearest tag below is somebody
else's note, and the repair re-points the citation at a fact it never meant.

⚠ IT DID EXACTLY THAT - five of six citations in one run, silently, in a file whose
whole job is being trustworthy. `map.lua:1684` (wheel-zoom defaults off) landed on
"NO ARGUMENT = NO RUN"; `:808` (a wrong art key still renders) landed on "ONE PLACE
draws everything". Every one of them was a real tag, at a plausible line, saying
something else entirely.

★★ THE PRINTOUT IS WHAT SAVED IT. Every rewrite is printed against the HEADLINE it
lands on, and reading those six lines is what caught it - which is the argument for
printing what a tool did rather than how many things it did.

★★★ SO THE RULE IS NOW: REPAIR ONLY WHAT IS UNAMBIGUOUS.

    exactly ONE tag within +WINDOW lines   ->  repair, and print the headline
    none, or more than one                 ->  REFUSE, name it, and hand over

⚠ A refusal is not a failure here. The dangling citation stays dangling and the
guard in emit_notes keeps reporting it, which is a loud, correct state. A wrong
repair is a quiet, incorrect one - and the second is much worse, because nothing
downstream ever looks at it again.

★ The deeper fix is that a citation should not be a line number at all, and this
file is the standing evidence for it. Until the shelf carries a stable anchor
instead, this repairs the trivial drift and refuses the rest.

    py addons/tools/fix_cites.py
    py addons/tools/fix_cites.py --dry
"""
import argparse
import io
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import emit_notes as E                              # noqa: E402 - path set above

SHELF = os.path.join(os.path.dirname(HERE), "maps", "intent.md")

# ⚠ TIGHT ON PURPOSE. A citation drifts by the number of comment lines inserted
# above it, which for an ordinary edit is a handful. A big window is what lets a
# stranger's tag look like the answer.
WINDOW = 12


def main():
    ap = argparse.ArgumentParser()
    # ⚠⚠ REPORTING IS THE DEFAULT, AND IT WAS NOT ALWAYS. This repaired by position
    # and was WRONG TWICE, silently, in the one file whose whole value is being
    # trustworthy: once outside its guard (five citations repointed at other notes)
    # and once INSIDE it, where a 12-line window found exactly one candidate, passed
    # the uniqueness test, and still landed on the wrong note.
    #
    # ★★ UNIQUENESS INSIDE A WINDOW IS NOT CORRECTNESS - it only means nothing else
    # happened to be nearby. So the repair is made by matching the HEADLINE, which is
    # the only thing that actually identifies a note, and this reports.
    #
    # ★ The real fix is that a citation should not be a LINE NUMBER at all. Two
    # incidents is the evidence for it.
    ap.add_argument("--write", action="store_true",
                    help="actually rewrite. ⚠ wrong twice - prefer repairing by headline")
    ap.add_argument("--dry", action="store_true",
                    help="deprecated - reporting is the default now")
    a = ap.parse_args()

    found = E.collect()
    shelf = io.open(SHELF, encoding="utf-8", newline="").read()
    bad = E.dangling(found, shelf)
    if not bad:
        print("no dangling citations")
        return 0

    fixed, refused = 0, []
    for f, ln, _near in bad:
        cands = [n for n in found if n["file"] == f and ln <= n["line"] <= ln + WINDOW]
        if len(cands) != 1:
            refused.append((f, ln, "%d candidate(s) within +%d" % (len(cands), WINDOW)))
            continue
        n = cands[0]
        print("  %s:%d -> :%d   %s" % (f, ln, n["line"], n["head"][:64]))
        shelf = shelf.replace("`%s:%d`" % (f, ln), "`%s:%d`" % (f, n["line"]))
        fixed += 1

    if refused:
        print("\n⚠ REFUSED - repair these by HEADLINE, not by position:")
        for f, ln, why in refused:
            print("    %s:%d   %s" % (f, ln, why))
        print("    (find the note's current line with: py addons/tools/emit_notes.py)")

    if fixed and a.write:
        io.open(SHELF, "w", encoding="utf-8", newline="").write(shelf)
    print("\n%d would repair%s, %d refused"
          % (fixed, "" if a.write else " (REPORT ONLY - repair by headline)", len(refused)))
    return 1 if refused else 0


if __name__ == "__main__":
    sys.exit(main())
