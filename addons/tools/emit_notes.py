"""emit_notes.py - an INDEX of the rulings and facts living in the code.

★★ WHY (Battlewrath, 2026-08-15). A ruling of his about not engraining custom
internal clocks had lived in `COA_GuardianPlates/Core.lua` since v3.5.5. I wrote the
opposite into the intent shelf and never saw it, because I never opened that file.

His diagnosis of what makes such a note WORK:

    "It gives us basis to use that for other similar event handling..." was living in
    code. Or next to code. So living with code is information we can capture about
    that code block without knowing to go find it.

★★★ SO THE NOTE NEVER MOVES. Proximity is the property that works - you are already
in the block it governs, and you did not have to know it existed. An inventory that
RELOCATED these would destroy exactly the thing that makes them valuable.

⚠ But proximity only works when you are in the file. From outside it, a perfectly
written note is invisible - which is the failure this fixes. So this emits a POINTER,
never a copy: grep it for "timer" and it hands you the file and line.

---------------------------------------------------------------------------
THE CONVENTION - WEIGHT and KIND, orthogonal, and they compose.

    -- ★★ RULING: <one line>   a decision and its reasoning. Usually his.
    -- FACT: <one line>         measured behaviour of the client or our data.

Either may stand alone. The tag goes on its own line inside the comment block that
already explains it; the body stays where it is.

★★ BOTH, at his direction, declining the auditor's "replace the stars":

    "You landed on stars naturally. It's a convention you formed when there is a lot
    of moving elements. So both. Star rating, then a light prefix of what it even
    pertains to."

The star says WHERE TO SLOW DOWN while scanning a long file. The prefix says WHAT
KIND of thing it is, and is what this index reads. They answer different questions,
so replacing one with the other loses something.

★ WHAT INFERENCE CANNOT DO IS SUPPLY THE KIND, and that was measured: 118 quoted
comment lines with only 8 overlapping a marker, the quote catching ordinary prose as
readily as a ruling, and the most valuable note found carrying no mark at all. So the
KIND is declared. The WEIGHT stays a judgement, and the star census below makes its
calibration visible instead of leaving it to feel.

★★ AND THE TAG IS THE PRUNING DECISION. A block earns one only when it is SETTLED.
That is what makes this an inventory rather than a second log of uncertainties -
"pruned to be settling", in his words - and it is why retrofitting all 538 marked
lines would defeat the purpose.

Usage:
    py addons\\tools\\emit_notes.py
    py addons\\tools\\emit_notes.py --check     # stale? write nothing
"""
import argparse
import io
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ADDONS = HERE.parent
OUT = ADDONS / "maps" / "notes.md"

sys.path.insert(0, str(ADDONS))
from deploy import MANIFEST                      # noqa: E402 - the one authority

# ★★ WEIGHT AND KIND ARE ORTHOGONAL, and they compose: `-- ★★ RULING: ...`
#
# Battlewrath, 2026-08-15, declining the auditor's "replace the stars": *"You landed
# on stars naturally. It's a convention you formed when there is a lot of moving
# elements. So both. Star rating, then a light prefix of what it even pertains to."*
#
# ★ The stars answer a question the prefixes do not - WHERE TO SLOW DOWN while
# scanning a 2,000-line file. The audit's finding was never that stars are the wrong
# idea; it was that they are UNCALIBRATED and anti-correlated with value. That is a
# calibration problem, and calibration is what the star census below addresses.
TAG = re.compile(r'^\s*--\s*([★]*)\s*(RULING|FACT):\s*(.+?)\s*$')
STAR = re.compile(r'[★⚠]+')
COMMENT = re.compile(r'^\s*--')
# The scope: what the note is ATTACHED to. `function X(` / `local function X(` /
# `X.Y = function(`, whichever comes first after the block.
FUNC = re.compile(r'^\s*(?:local\s+)?function\s+([\w.:]+)\s*\(|^\s*([\w.]+)\s*=\s*function\s*\(')


# Module boilerplate. A note sitting above `local ADDON, NS = ...` is a FILE header
# note, not a note about the preamble - reporting the preamble as its scope was true
# and useless, which is its own kind of wrong.
PREAMBLE = re.compile(r'^\s*local\s+ADDON\s*,\s*NS\s*=|^\s*local\s+\w+\s*=\s*\{\s*\}\s*$'
                      r'|^\s*NS\.\w+\s*=\s*\w+\s*$|^\s*local\s+[\w,\s]+$')
ASSIGN = re.compile(r'^\s*(?:local\s+)?([\w.]+)\s*=')
CALL = re.compile(r'^\s*([\w.:]+)\s*[:(]')


def scope_of(lines, i):
    """What this note governs: the next definition after it, or `(file)` when it sits
    in the header. ⚠ Emitted, never typed - a hand-kept scope goes stale the moment a
    function moves, which is exactly the rot this exists to avoid."""
    for j in range(i, min(i + 60, len(lines))):
        s = lines[j].strip()
        if not s or s.startswith("--") or s.startswith("]]"):
            continue
        m = FUNC.match(lines[j])
        if m:
            return m.group(1) or m.group(2)
        if PREAMBLE.match(lines[j]):
            continue                      # boilerplate is never a useful scope
        m = ASSIGN.match(lines[j]) or CALL.match(lines[j])
        if m:
            return m.group(1)
        return s[:40].rstrip(" ={(,")
    return "(file)"


def notes_in(path, rel):
    lines = io.open(path, encoding="utf-8", errors="replace").read().split("\n")
    out, seen_code = [], False
    for i, line in enumerate(lines):
        s = line.strip()
        m = TAG.match(line)
        if not m:
            # ★ A note in the FILE HEADER governs the FILE, and that is a POSITIONAL
            # fact — nothing has been declared yet — not something a lookahead can
            # infer. Guessing from the first symbol below it attributed a file-wide
            # ruling to whichever local happened to be declared first, which is
            # confidently wrong rather than merely unhelpful.
            if s and not s.startswith("--"):
                seen_code = True
            continue
        stars, kind, head = m.group(1), m.group(2), m.group(3)
        if not seen_code:
            scope = "(file)"
        else:
            # Walk to the end of this comment block, then see what it precedes.
            j = i + 1
            while j < len(lines) and COMMENT.match(lines[j]):
                j += 1
            scope = scope_of(lines, j)
        out.append({"kind": kind, "head": head, "file": rel,
                    "line": i + 1, "scope": scope, "weight": len(stars)})
    return out


def collect():
    found = []
    for name in MANIFEST:
        folder = ADDONS / name
        if not folder.is_dir():
            continue
        for lua in sorted(folder.glob("*.lua")):
            found += notes_in(lua, f"{name}/{lua.name}")
    for extra in sorted((ADDONS / "tools" / "smoke").glob("*.lua")):
        found += notes_in(extra, f"tools/smoke/{extra.name}")
    return found


def star_census():
    """Marked comment lines per file, whether tagged or not.

    ★★ THE CALIBRATION HALF. An audit found the stars ANTI-CORRELATED with value:
    307 marks all inside two addons, while four others carried zero between them and
    roughly 160 rulings. Nobody could see that, because inflation is invisible from
    inside one file.

    ⚠ This reports rather than rules. A budget ("max N per file") would be a number
    someone argues with; a distribution is a fact you look at. If one file has 71 ★
    and another has none, that is the finding, and it needs no threshold to be
    obvious."""
    rows = []
    for name in list(MANIFEST) + ["tools/smoke"]:
        folder = ADDONS / name
        if not folder.is_dir():
            continue
        for lua in sorted(folder.glob("*.lua")):
            c = {1: 0, 2: 0, 3: 0, "warn": 0}
            for line in io.open(lua, encoding="utf-8", errors="replace"):
                s = line.strip()
                if not s.startswith("--"):
                    continue
                if "★★★" in s:
                    c[3] += 1
                elif "★★" in s:
                    c[2] += 1
                elif "★" in s:
                    c[1] += 1
                elif "⚠" in s:
                    c["warn"] += 1
            if sum(c.values()):
                rows.append((f"{name}/{lua.name}", c))
    rows.sort(key=lambda r: -sum(r[1].values()))
    return rows


def render(found):
    rulings = [n for n in found if n["kind"] == "RULING"]
    facts = [n for n in found if n["kind"] == "FACT"]
    L = ["# Notes in the code — rulings and measured facts", "",
         "_Emitted by `addons/tools/emit_notes.py`. **Never hand-edited.**_", "",
         "★★ **The notes live WITH THE CODE and this does not move them.** Proximity is what makes "
         "them work — you are already in the block one governs, and you did not have to know it "
         "existed. This is a **pointer** so they are also findable from outside the file, which is "
         "the failure it was built for: a ruling about timers sat in `COA_GuardianPlates` for a "
         "month while the intent shelf claimed the opposite.", "",
         "★ **The tag is the pruning decision.** A block earns `RULING:` or `FACT:` only when it is "
         "**settled** — that is what keeps this an inventory rather than a second log of "
         "uncertainties.", "",
         f"**{len(rulings)} ruling(s) · {len(facts)} fact(s).**", ""]
    for title, rows, blurb in (
            ("RULINGS", rulings, "Decisions and their reasoning. Mostly his."),
            ("FACTS", facts, "Measured behaviour of the client or our own data.")):
        L += [f"## {title}", "", f"_{blurb}_", "",
              "| Wt | What | Governs | Where |", "|---|---|---|---|"]
        if not rows:
            L.append("| — | — | — | — |")
        for n in sorted(rows, key=lambda r: (-r["weight"], r["file"], r["line"])):
            L.append("| %s | %s | `%s` | `%s:%d` |" % (
                "★" * n["weight"] if n["weight"] else "—",
                n["head"], n["scope"], n["file"], n["line"]))
        L.append("")
    # ★★ THE STAR CENSUS — calibration made visible rather than ruled.
    cen = star_census()
    L += ["---", "", "## Star census — where the emphasis actually sits", "",
          "★★ **Weight and kind are orthogonal and they compose:** `-- ★★ RULING: …`. The star says "
          "**where to slow down** while scanning a long file; the prefix says **what kind of thing** "
          "it is. An audit recommended replacing the stars — that was the wrong call, because they "
          "answer a question the prefixes do not.", "",
          "⚠ **But the audit's real finding stands: they were anti-correlated with value** — 307 "
          "marks all inside two addons, while four others carried zero between them and roughly 160 "
          "rulings. Inflation is invisible from inside one file, so it is printed here.", "",
          "| ★ | means |", "|---|---|",
          "| ★★★ | **miss this and you break something.** Rare by construction |",
          "| ★★ | **this is WHY it is like this** — the reasoning a change has to respect |",
          "| ★ | worth noticing while passing |",
          "| ⚠ | a trap, a limit, or a thing that is not what it looks like |", "",
          "| File | ★ | ★★ | ★★★ | ⚠ |", "|---|---|---|---|---|"]
    for f, c in cen:
        L.append("| `%s` | %d | %d | %d | %d |" % (f, c[1], c[2], c[3], c["warn"]))
    tot = {k: sum(c[k] for _, c in cen) for k in (1, 2, 3, "warn")}
    L += ["| **TOTAL** | **%d** | **%d** | **%d** | **%d** |" % (
              tot[1], tot[2], tot[3], tot["warn"]), "",
          "⚠ **A file with hundreds of marks and no ★★★, beside one written in an afternoon with "
          "several, is not a ranking — it is a record of who was excited when.** That is the shape "
          "to watch for here.", "",
          "---", "",
          "## The convention", "",
          "```lua",
          "-- ★★ RULING: <one line>   weight, then kind. Either may stand alone.",
          "-- FACT: <one line>        measured behaviour of the client or our data",
          "```", "",
          "On its own line inside the comment block that already explains it. The body stays in "
          "the file; this carries only the headline, what it governs, and where.", "",
          "⚠ **`Governs` is emitted, never typed** — a hand-kept scope goes stale the moment a "
          "function moves, which is the rot this exists to avoid."]
    return "\n".join(L) + "\n"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true",
                    help="report whether the emitted index is stale; write nothing")
    a = ap.parse_args()

    text = render(collect())
    if a.check:
        current = OUT.read_text(encoding="utf-8") if OUT.exists() else ""
        if current == text:
            print("notes index is CURRENT")
            return 0
        print("notes index is STALE - re-run: py addons/tools/emit_notes.py")
        return 1

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(text, encoding="utf-8")
    found = collect()
    print("wrote %s - %d ruling(s), %d fact(s)" % (
        OUT, sum(1 for n in found if n["kind"] == "RULING"),
        sum(1 for n in found if n["kind"] == "FACT")))
    return 0


if __name__ == "__main__":
    sys.exit(main())
