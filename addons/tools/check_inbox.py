# -*- coding: utf-8 -*-
r"""check_inbox.py - the reconcile inbox's own convention, ENFORCED rather than stated.

    py addons/tools/check_inbox.py

★★★ WHY THIS EXISTS, and it is a specific failure that happened THREE TIMES.

`Reconcile_inbox.md` states one convention for status, and it is a good one:

    "an item is DRAINED when its text begins `RI-N DRAINED (who, date)`; an item
     without that stamp is OPEN. Derive, don't read a list."

⚠ The convention is only as good as the stamp being written in the form the grep looks
for, and three times it was not:

    RI-19   the withdrawal was in the TEXT and not in the stamp    -> read as OPEN
    RI-29   filed BECAUSE of that, and the count in it was wrong within a day
    RI-34   the heading reads `## RI-34 ✅ DRAINED 2026-08-20 · ...` and the body opens
            `**RI-34 CONFIRMED AND EXTENDED**`. Neither matches `RI-34 DRAINED`, so the
            derive-grep returns ZERO hits and the item reports OPEN

★★ **Three corrections is a convention problem, not a discipline problem.** The standing
answer on this bench is *prefer a check that FAILS over a line that informs* - the same
reasoning that produced `check_targets.py` after the fourth pointer went unread.

★ WHAT IT ASSERTS, and the second row is the whole point:

    STAMPED      an item whose status can be DERIVED, exactly as the convention says
    NOT MIXED    ⚠ an item that READS drained but carries no stamp the grep can see -
                 a heading with a tick, a body saying "drained"/"withdrawn"/"settled".
                 **This is the failure; the first row alone would pass every time,
                 because an unstamped item just looks open.**
    NUMBERED     no duplicate `RI-N`, and the next number is the highest + 1

⚠ IT DOES NOT JUDGE WHETHER AN ITEM *SHOULD* BE DRAINED. That is the designer's, and a
tool that guessed would be worse than the gap it closes. It only holds that what an item
SAYS about itself and what the convention can READ agree.
"""
import io
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
INBOX = os.path.join(ROOT, "planning", "Reconcile_inbox.md")

HEAD = re.compile(r"^##\s+(RI-(\d+))\b(.*)$")

# ★ THE CONVENTION'S OWN FORM, and it is deliberately the SAME regex the file tells a
# reader to type. ⚠ If this drifts from the documented grep the tool starts enforcing a
# private rule, which is the fault it exists to catch, one level up.
STAMP = re.compile(r"RI-\d+ DRAINED")

# Words that mean "this item is finished" in a heading or an opening line. ⚠ Kept SHORT
# and literal: a long list would start matching prose ABOUT draining rather than a claim
# TO be drained, and a false positive here costs a real read.
CLAIMS = ("DRAINED", "WITHDRAWN", "SETTLED", "CONFIRMED AND EXTENDED", "✅")


def strip_details(text):
    """Blank out every <details>...</details> block, keeping LINE COUNT intact.

    ★★ A drained item keeps its WORKING whole, wrapped in <details>, and that working
    carries the item's original `## RI-N` heading. Counting it is a DUPLICATE report on a
    file that is correctly formed - the tool inventing work.
    ⚠ `check_retired` already rules this exact class: "any `<details>` block (the working,
    kept whole)" is a RECORD, not an assertion. ⟶ Two tools disagreeing about what a
    <details> block IS would cost more than either rule is worth, so they agree here.
    ★ Line count is preserved so nothing downstream has to care that this ran.
    """
    out, depth = [], 0
    for line in text.splitlines():
        low = line.lower()
        opened = "<details" in low
        if depth > 0 or opened:
            out.append("")
        else:
            out.append(line)
        depth += low.count("<details")
        depth -= low.count("</details>")
        if depth < 0:
            depth = 0
    return "\n".join(out)


def items(text):
    """-> [(rid, num, heading_rest, body)] in file order."""
    lines = strip_details(text).splitlines()
    marks = [(i, m) for i, m in
             ((i, HEAD.match(l)) for i, l in enumerate(lines)) if m]
    out = []
    for k, (i, m) in enumerate(marks):
        end = marks[k + 1][0] if k + 1 < len(marks) else len(lines)
        out.append((m.group(1), int(m.group(2)), m.group(3),
                    "\n".join(lines[i:end])))
    return out


def main():
    if not os.path.exists(INBOX):
        sys.stderr.write("  the inbox is MISSING: %s\n" % INBOX)
        return 1
    text = io.open(INBOX, encoding="utf-8", errors="replace").read()
    rows = items(text)

    bad, seen, drained, open_ = [], {}, [], []
    for rid, num, head, body in rows:
        if rid in seen:
            bad.append("DUPLICATE  %s appears more than once" % rid)
        seen[rid] = True

        stamped = STAMP.search(body) is not None
        # the first four lines are where a claim would sit - the heading and the
        # opening statement. Further down is prose ABOUT the item, not its status.
        top = "\n".join(body.splitlines()[:4]).upper()
        claims = any(c.upper() in top for c in CLAIMS)

        if stamped:
            drained.append(rid)
        else:
            open_.append(rid)
            if claims:
                bad.append(
                    "MIXED      %s reads DRAINED but carries no `%s DRAINED` stamp - "
                    "the derive-grep reports it OPEN" % (rid, rid))

    print("")
    print("   RECONCILE INBOX - the file's own convention, enforced")
    print("   " + "-" * 62)
    print("   items %d   drained %d   open %d" % (len(rows), len(drained), len(open_)))
    if open_:
        print("   OPEN: %s" % " · ".join(open_))
    nums = sorted(n for _, n, _, _ in rows)
    if nums:
        print("   next number: RI-%d" % (nums[-1] + 1))
    print("")
    for b in bad:
        print("   [!] %s" % b)
    if bad:
        print("")
        print("   ⚠ The convention is `RI-N DRAINED (who, date)` at the START of the")
        print("     item's text. A tick in the heading or a synonym in the body is")
        print("     invisible to `grep \"RI-[0-9]* DRAINED\"`, which is what the file")
        print("     tells every reader to run - so the item reports OPEN to everyone")
        print("     who follows the instructions.")
        print("")
        return 1

    print("   ★ every item's status is DERIVABLE - what each says about itself and what")
    print("     the convention can read agree.")
    print("")
    return 0


if __name__ == "__main__":
    sys.exit(main())
