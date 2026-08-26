# -*- coding: utf-8 -*-
r"""emit_push_receipt - leave a dated RECEIPT of the checker desk at every push.

★ WHY THIS EXISTS, and it is not what was first asked for. Dev asked for a reconcile ENGINE to
  track stale docs. The engine already exists - bench menu `[7] Reconcile` - and the measurement
  that killed the proposal is this: **[7] last changed 2026-08-16 and runs 2 of the 13 checkers,
  while NINE of the eleven it misses were born after that date.** The gap was never a missing
  tool. It was a missing regiment. ⟶ Battlewrath, 2026-08-26: *"If you feel we have the tools
  already just not the regiment... wire the receipt into the current git push that dev uses, so
  we have a log to reconcile when we do a pass there."*

★★ WHAT MAKES A RECEIPT A CHECK RATHER THAN A COIN. §526: drift is only detectable where TWO
  INDEPENDENT sources can disagree. A receipt's two sources are **the desk at push N and the desk
  at push N+1** - neither derived from the other, so a fingerprint that MOVED is a real question.
  That is the whole reconcilable signal here; the exit code is the smaller half.
  ⟶ Measured before building: all twelve reachable checkers are byte-deterministic across two
    consecutive runs, which is the property the fingerprint rests on. If one ever goes volatile
    its fingerprint churns every push and it must be fixed or dropped, not tolerated.

⚠⚠ THE HONEST CEILING, AND IT IS PRINTED IN EVERY RECEIPT. A green from a checker nobody has
  watched FAIL is unmeasured, not clean - seven inert guards were measured on this bench in one
  week, so a log of OKs reads as coverage when some of those bulbs have never been proven to
  light. ⟶ The PROVEN column is derived from the mutation suite at run time and no count is
  written down here, because a second copy of that list is the thing that drifts.
  ★ IT DRIFTED ANYWAY, and the correction is worth keeping: this docstring used to name THREE
  as the proven count while explaining in the next clause why it must not name one. The Analyst
  closed the gap the same day and every receipt has read 13 of 13 since. The column never moved;
  the sentence beside it did.

★ AND THE SIGNATURE IS TAKEN FROM THE LOUD OUTPUT. `mutate_checkers.LOUDEST` records that a
  signature read off a tool's default output is a SCOPE THAT EXCLUDES THE EVIDENCE. Same fault,
  same fix: this reads LOUDEST from that file and runs each tool the way it speaks fully.

This RECORDS. It never gates - see .githooks/pre-push, which always exits 0. Putting a stop on the
Addon Creator's push is not this seat's to install.
"""
import datetime
import hashlib
import io
import os
import re
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))
ADDONS = os.path.dirname(HERE)
REPO = os.path.dirname(ADDONS)
RECEIPTS = os.path.join(ADDONS, "planning", "audit", "push_receipts.md")
SUITE = os.path.join(HERE, "mutate_checkers.py")

# The desk is DISCOVERED, never listed - a listed desk is one more copy to keep current, and this
# tool exists because a listed desk (menu [7]'s six lines) went ten days stale.
DESK = sorted(f for f in os.listdir(HERE)
              if (f.startswith("check_") or f == "emit_divergence.py") and f.endswith(".py"))


def _suite_source():
    try:
        return io.open(SUITE, encoding="utf-8", errors="replace").read()
    except IOError:
        return ""


def proven_and_flags():
    """Which tools does the mutation suite BREAK, and how must each be run to speak fully?

    Both derived from `mutate_checkers.py` itself. A tool named in a mutation has been watched to
    fail on its own message; a tool absent from it has not, whatever its exit code says.
    """
    src = _suite_source()
    proven = set(re.findall(r'"((?:check|emit)_[a-z_]+\.py)"', src))
    flags = {}
    block = re.search(r"^LOUDEST\s*=\s*\{(.*?)^\}", src, re.M | re.S)
    if block:
        for name, args in re.findall(r'"([^"]+\.py)"\s*:\s*\[([^\]]*)\]', block.group(1)):
            flags[os.path.basename(name)] = re.findall(r'"([^"]+)"', args)
    return proven, flags


def run(tool, argv):
    r = subprocess.run([sys.executable, os.path.join(HERE, tool)] + argv,
                       capture_output=True, text=True, encoding="utf-8", errors="replace",
                       cwd=ADDONS)
    out = (r.stdout or "") + (r.stderr or "")
    return out, r.returncode


def git(*a):
    try:
        r = subprocess.run(["git"] + list(a), capture_output=True, text=True,
                           encoding="utf-8", errors="replace", cwd=REPO)
        return (r.stdout or "").strip()
    except OSError:
        return ""


def main():
    proven, flags = proven_and_flags()
    head = git("rev-parse", "--short", "HEAD") or "?"
    subject = git("log", "-1", "--format=%s") or "?"
    ahead = git("rev-list", "--count", "@{u}..HEAD") or "?"
    who = git("config", "user.name") or "?"
    stamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")

    rows = []
    for tool in DESK:
        out, code = run(tool, flags.get(tool, []))
        fp = hashlib.sha1(out.encode("utf-8", "replace")).hexdigest()[:8]
        # ⚠ and ✗ are the two markers this bench uses uniformly across every tool, so counting them
        # is a severity scale that depends on NO tool's phrasing. A tail line would have been a
        # heuristic - measured 2026-08-26: most tails are prose caveats, not summaries.
        marks = out.count("⚠") + out.count("✗")
        rows.append((tool, code, fp, marks, tool in proven))

    w = max(len(t) for t, _, _, _, _ in rows)
    lines = []
    lines.append("## PUSH %s · HEAD `%s` · %s commit(s) ahead · %s" % (stamp, head, ahead, who))
    lines.append("")
    lines.append("_Last commit: %s_" % subject)
    lines.append("")
    lines.append("    %-*s  exit  fingerprint  marks  can-go-red" % (w, "checker"))
    for tool, code, fp, marks, ok in rows:
        lines.append("    %-*s  %4d  %-11s  %5d  %s"
                     % (w, tool, code, fp, marks, "proven" if ok else "—"))
    live = sum(1 for r in rows if r[4])
    lines.append("")
    if live == len(rows):
        lines.append("**%d of %d proven able to go red** - every checker on this desk has been "
                     "watched to fail on its own message. ⚠ A bite proves the GUARD, never that "
                     "the fact it guards is true." % (live, len(rows)))
    else:
        lines.append("⚠ **%d of %d proven able to go red** (mutation-covered). The other %d are greens "
                     "with no bulb proven behind them - read them as *unmeasured*, never as *clean*."
                     % (live, len(rows), len(rows) - live))
    lines.append("")
    lines.append("⟶ **To reconcile:** diff this block against the previous receipt. **A fingerprint that "
                 "MOVED is the question** - that checker's two sources stopped agreeing the way they did "
                 "last push. A fingerprint that held is not proof of health; it is proof of no change.")
    lines.append("")
    block = "\n".join(lines) + "\n"

    exists = os.path.exists(RECEIPTS)
    if not exists:
        os.makedirs(os.path.dirname(RECEIPTS), exist_ok=True)
    with io.open(RECEIPTS, "a", encoding="utf-8", newline="\n") as fh:
        if not exists:
            fh.write(HEADER)
        fh.write("\n---\n\n" + block)

    print("   receipt appended · %d checkers · %d proven · %s"
          % (len(rows), live, os.path.relpath(RECEIPTS, REPO).replace("\\", "/")))
    return 0


HEADER = u"""# push receipts — the checker desk, stamped at every push

_Emitted by `addons/tools/emit_push_receipt.py`, called from `.githooks/pre-push`. **Nothing here
gates a push.** Append-only; newest at the bottom._

**Why a receipt and not an engine (2026-08-26):** the reconcile engine already exists - bench menu
`[7]` - and it was measured **wired to 2 of the 13 checkers, unchanged since 2026-08-16, while nine
of the eleven it misses were born after that date.** The missing thing was the regiment, so this
leaves a log at the one act every seat performs.

**How to read it.** The reconcilable signal is the FINGERPRINT, diffed against the previous
receipt - two independent observations of the desk, at push N and push N+1. A moved fingerprint is
a question, never a verdict; lag is expected during active development.

⚠ **A `git push --dry-run` leaves a receipt too** — git tells the hook nothing about dry-run, so it
cannot be distinguished at write time. It does not need to be: a repeat carries the SAME `HEAD` and
the same fingerprints as the block above it, which is what a repeat looks like.

⚠ **`can-go-red` is the column that keeps this honest.** Only the checkers the mutation suite
actually breaks have been watched to fail on their own message. A green from an unproven checker
means *unmeasured*, not *clean*.
"""

if __name__ == "__main__":
    sys.exit(main())
