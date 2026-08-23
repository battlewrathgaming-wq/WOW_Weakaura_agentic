# -*- coding: utf-8 -*-
r"""_boot_selftest.py - the SEAT/BENCH relation in boot.py, asserted row by row.

    py operations/_boot_selftest.py

★★★ WHY A TABLE AND NOT A RUN. `py operations/boot.py --lane X` only ever exercises the ONE row
that the live `HELM.md` holder happens to select. Every other relation - the reversals, the other
benches, the historical holder spellings - is unexercised, so a map can be wrong for months and
every boot still looks right.

⚠⚠ AND THE FAILURE IT GUARDS IS THE EXPENSIVE ONE. Before the map existed (2026-08-23) boot told
the analyst and architect seats **"LOCKED OUT - repo-read-only. Do not commit."** on every run,
because `mine()` compared strings and `"analyst"` is not a substring of `"addons"`.

    OBEYED    legitimate work halts - two of the four seats read "do not commit"
    IGNORED   the seat is trained to discount the guard, and then it cannot be trusted on the
              day the lockout is REAL, which is the only day it matters

★ An inert guard fails to EARN trust; a false stop SPENDS it. ⟶ Which is why the repair's own
regression is the row that matters most here: **a fix that unlocks EVERYONE is the worse bug**, so
the other benches are asserted to still lock out, not merely assumed to.

★★ THIS FILE IS ALSO WHERE THE ORG CHART IS WRITTEN DOWN. A seat added or moved is a row here,
with the reason in its own line. ⚠ Only what Battlewrath has STATED belongs in the map - an
unmapped name resolves to itself, which is the old behaviour. **A guessed org chart is a guessed
lockout.**
"""

import os
import sys

sys.stdout.reconfigure(encoding="utf-8")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import boot  # noqa: E402  - path set above

# (holder, lane, is it MY bench's, is it MY OWN seat's, why this row is here)
CASES = (
    # ── the addons bench: three seats, one trunk (Battlewrath, 2026-08-23)
    ("addons", "analyst", True, False, "the false lockout the map was built for"),
    ("addons", "architect", True, False, "the other addons seat"),
    ("addons", "addons", True, True, "the holder booting as itself"),
    ("analyst", "addons", True, False, "REVERSED - a seat holds it, the bench boots"),
    ("analyst", "architect", True, False, "two non-bench seats on one bench"),

    # ── class_identity and suno are one bench; ALIASES already routes both to one lane file
    ("class_identity", "suno", True, False, "the pair confirmed 2026-08-23"),
    ("suno", "class-identity", True, False, "reversed, and the hyphen spelling"),

    # ── ★ THE REGRESSION ROWS. A repair that unlocks everyone is the worse bug.
    ("addons", "aura", False, False, "★ another bench must STILL lock out"),
    ("addons", "macros", False, False, "★ likewise"),
    ("addons", "class_identity", False, False, "★ the new pair is not addons"),
    ("aura", "analyst", False, False, "★ reversed lockout"),
    ("released", "analyst", False, False, "RELEASED is never anyone's"),

    # ── the loose match is deliberate and predates the map; historical holders read like this
    ("addons bench", "analyst", True, False, "historical holder spelling"),
    ("AURA", "aura", True, True, "historical uppercase spelling"),
)


def main():
    bad = []
    print("")
    print("   THE SEAT/BENCH RELATION - every row, not just the one HELM.md selects")
    print("   " + "-" * 74)
    for holder, lane, want_mine, want_seat, why in CASES:
        got_m = boot.mine(holder, lane)
        got_s = boot.same_seat(holder, lane) if got_m else False
        ok = (got_m, got_s) == (want_mine, want_seat)
        if not ok:
            bad.append((holder, lane, want_mine, want_seat, got_m, got_s))
        print("   %-4s holder=%-15s lane=%-15s bench=%-5s seat=%-5s  %s"
              % ("ok" if ok else "FAIL", holder, lane, got_m, got_s, why))

    print("")
    print("   bench_of: %s" % ", ".join(
        "%s->%s" % (n, boot.bench_of(n))
        for n in ("analyst", "architect", "suno", "class-identity", "aura", "unmapped_name")))
    print("")
    for holder, lane, wm, ws, gm, gs in bad:
        print("   [!] holder=%s lane=%s  wanted bench=%s seat=%s, got bench=%s seat=%s"
              % (holder, lane, wm, ws, gm, gs))
    print("   %d row%s%s" % (len(CASES), "" if len(CASES) == 1 else "s",
                             ", all hold" if not bad else ", %d FAILING" % len(bad)))
    if bad:
        print("   ⚠ A ROW HERE IS THE ORG CHART. If the relation genuinely changed, change the")
        print("     row and say who stated it - never delete it to make this green.")
    print("")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
