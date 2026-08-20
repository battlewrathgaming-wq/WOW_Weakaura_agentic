# -*- coding: utf-8 -*-
"""RETIRED-TERM SWEEP - nothing live may rest on something we retired.

★★★ WHY IT EXISTS (Battlewrath, 2026-08-20): **"Dev shouldn't have to reason what is true."**

⚠⚠ THE FAULT IT CATCHES is not a wrong word. It is a LIVE CLAIM standing on a RETIRED premise -
which reads exactly like a correct claim, because nothing about it changed. Met four times in one
day: W7.1's byte-equality left ~10 dependents standing (including the RELEASE GATE),
`MAX_CLOSING_SPEED = 30` was inherited from a neighbour, `POLL_MIN = 0.2` was promoted INTO the
spec hours after being shown to fail, and `Rule.OPEN` was read as a data state.

★ THE RULE IT ENFORCES: a retirement is not done until its identifier has been grepped and every
hit is either UPDATED or MARKED as surviving. This performs the grep so nobody has to remember.
⚠ It yields a WORK LIST, not a defect list - a marked hit is a CORRECT hit.

⚠⚠ AND WHAT IT DELIBERATELY DOES NOT READ, because all three are RECORDS rather than assertions:
`history/` and `audit/` (what was true then) · `Reconcile_inbox.md` (a drained item DISCUSSES the
thing it retired - that is what a drain IS) · any `<details>` block (the working, kept whole).

Usage:  py addons/tools/check_retired.py            # report
        py addons/tools/check_retired.py --check    # exit 1 if anything is unmarked
"""
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PLAN = os.path.join(ROOT, "planning")
SRC = os.path.join(ROOT, "COA_DungeonRun")

# A hit is ALREADY MARKED if any line in its window carries one of these.
#
# ⚠⚠ THE MARKER IS RARELY ON THE HIT LINE. A headstone is a PARAGRAPH - the strike sits on one
# line and the quoted old text on the next three. Checking only the hit line reported forty
# correct headstones as findings. ★ So the WINDOW is the unit, not the line.
#
# ★ And the quotation forms matter as much as the strike words: a correction quotes the sentence
# it replaces, so the retired words appear verbatim INSIDE the thing that retires them.
MARKED = re.compile(
    "~~|SUPERSEDED|RETIRED|STRUCK|DISSOLVED|WITHDRAWN|CORRECTED|OVERTURNED|AMENDED"
    "|NARROWED|REFUSED|RESCOPED|REPLACED|headstone|no longer|used to|not built"
    "|desk-side|moved to the desk|is absent|absent on purpose"
    "|it read|this read|still reads|it was|Was:|first argued|had read|previously"
    "|RI-33|RI-34|RI-35|RI-36|RI-37|A2.12|A2.6|does not exist"
    # A DROP SITE IS THE RETIREMENT BEING PERFORMED. `DropRetired` naming a dead field, and
    # the headstone above it, are the STRONGEST evidence it is retired - and the first run
    # reported all eight of them as findings.
    "|DropRetired|DROPPED|is dropped|dropped and|clear that lived here|gone with the field",
    re.I)

WINDOW = 3

# (label, regex, what replaced it, scope)   scope: docs | code | both
RETIRED = [
    ("byte-equality as the DRIVER's grade", r"\bW7\.1\b|byte-equal",
     "W7.2 synthetics + outcome grading (RI-33)", "docs"),
    ("segment in the DRIVER's rule", r"segment_fire|segment test|point \+ segment",
     "point + band + gate (A11.2a)", "both"),
    ("interpolated z / v_max driver-side", r"interpolated[- ]z|\bv_max\b",
     "desk-side only (RI-33)", "code"),
    ("POLL_MIN 0.2", r"POLL_MIN[^\n]{0,24}0\.2(?!\d)|0\.20 s floor|floor of 0\.2(?!\d)",
     "0.1 (RI-34)", "both"),
    ("MAX_CLOSING_SPEED 30", r"MAX_CLOSING_SPEED[^\n]{0,20}\b30\b",
     "100 = TELEPORT_VMAX (RI-34)", "both"),
    ("POLL_MAX 2.0", r"POLL_MAX[^\n]{0,20}2\.0",
     "1.0 - Landmarks' 2.0 is a neighbour's constant (SS425)", "both"),
    ("ARRIVAL_HOLD", r"ARRIVAL_HOLD",
     "NEVER BUILT and no disposition - sensor brief G7", "both"),
    ("fireOn", r"fireOn", "the SENSE WORD on each row (A2.12)", "code"),
    ("ifUnseen", r"ifUnseen", "completion owns set-idempotence; dies with Next", "code"),
    ("the old row setters", r"SetChildSense|SetChildRole|SetChildAction",
     "SetRow / RowsOf", "code"),
    ("goTo", r"\bgoTo\b", "A2.6 retired it", "both"),
    ("bandDown / band as a pair", r"bandDown|band_down|band pair",
     "UPWARD ONLY, one value (RI-22)", "both"),
    ("an OPEN band as a data state", r"open band|band.{0,14}infinit|infinit.{0,14}band",
     "the picker floors at 2.5; OPEN is the rule's own fallback (RI-37)", "both"),
    ("pre-load", r"pre-load|preload", "BUCKET and STAGE (model rows 23-27)", "both"),
]

# ⚠⚠ EXCLUSIONS, STATED RATHER THAN SILENT - a quiet scope is the fault this tool exists for.
#
# `Reconcile_inbox.md`        a WORKING SET. A drained item DISCUSSES what it retired; that is
#                             what a drain IS.
# `driver_analysis_asklist`   dated Q&A correspondence that declares its own supersession in its
#                             header: *"DESIGN proposals in SSH are superseded wherever
#                             driver_programmatic_model.md says otherwise; the ledger SSI is
#                             history as of its date."* ★ It is a record with the clause built in.
SKIP_FILES = ("Reconcile_inbox.md", "driver_analysis_asklist.md")

# ★★ PER-TERM HOMES. A term is not stale in the document that OWNS it.
#   `driver_walk_acceptance.md` is GOVERNING #6, "the DESK's rule" - segment, the interpolated
#   z, `v_max`, `bandDown` and byte-equality are its SUBJECT MATTER. RI-33 moved them OFF the
#   driver; it did not retire them from the desk. Sweeping the desk's brief for the desk's own
#   vocabulary reports the specification as though it were drift.
HOME = {
    "byte-equality as the DRIVER's grade": ("driver_walk_acceptance.md",),
    "segment in the DRIVER's rule": ("driver_walk_acceptance.md",),
    "interpolated z / v_max driver-side": ("driver_walk_acceptance.md",),
    "bandDown / band as a pair": ("driver_walk_acceptance.md",),
    "an OPEN band as a data state": ("driver_walk_acceptance.md",),
}


def _safe(s):
    """This console is cp1252; the docs are UTF-8 and full of arrows and stars."""
    return s.encode("ascii", "replace").decode("ascii")


def files(scope):
    out = []
    if scope in ("docs", "both"):
        for f in sorted(os.listdir(PLAN)):
            p = os.path.join(PLAN, f)
            if (os.path.isfile(p) and f.endswith(".md")
                    and not f.startswith("ARCHIVE__") and f not in SKIP_FILES):
                out.append((os.path.join("planning", f), p))
    if scope in ("code", "both") and os.path.isdir(SRC):
        for f in sorted(os.listdir(SRC)):
            if f.endswith(".lua"):
                out.append((os.path.join("COA_DungeonRun", f), os.path.join(SRC, f)))
    return out


def hidden_lines(lines):
    """Indices inside a <details> block - the working, kept whole under a drained item."""
    out, depth = set(), 0
    for i, l in enumerate(lines):
        if "<details" in l:
            depth += 1
        if depth:
            out.add(i)
        if "</details>" in l:
            depth = max(0, depth - 1)
    return out


def main():
    strict = "--check" in sys.argv
    findings, marked_n, scanned = [], 0, set()

    for label, pat, replaced, scope in RETIRED:
        rx = re.compile(pat)
        homes = HOME.get(label, ())
        for rel, path in files(scope):
            if any(rel.endswith(h) for h in homes):
                continue
            scanned.add(rel)
            try:
                lines = io.open(path, encoding="utf-8", errors="replace").read().split("\n")
            except IOError:
                continue
            hidden = hidden_lines(lines)
            for i, line in enumerate(lines):
                if i in hidden or not rx.search(line):
                    continue
                lo, hi = max(0, i - WINDOW), min(len(lines), i + WINDOW + 1)
                if any(MARKED.search(lines[j]) for j in range(lo, hi)):
                    marked_n += 1
                    continue
                findings.append((label, replaced, rel, i + 1, line.strip()[:92]))

    print("")
    print("   RETIRED-TERM SWEEP - a live claim may not rest on a retired premise")
    print("   %d terms  %d files  %d hits carry a supersession marker"
          % (len(RETIRED), len(scanned), marked_n))
    print("")
    if not findings:
        print("   OK - nothing live rests on a retired premise.")
    else:
        cur = None
        for label, replaced, rel, n, line in findings:
            if label != cur:
                cur = label
                print("   [!] %s" % _safe(label))
                print("       now: %s" % _safe(replaced))
            print("       %s:%d" % (_safe(rel), n))
            print("           %s" % _safe(line))
        print("")
        print("   %d UNMARKED hit(s) - each is either UPDATED or MARKED as surviving."
              % len(findings))
        print("   * A marked hit is a CORRECT hit. This is a work list, not a defect list.")
    print("")
    return 1 if (findings and strict) else 0


if __name__ == "__main__":
    sys.exit(main())
