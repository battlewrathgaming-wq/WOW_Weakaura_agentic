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
THE CONVENTION - two tags, and they are DECLARED, never inferred.

    -- RULING: <one line>      a decision and its reasoning. Usually his.
    -- FACT:   <one line>      measured behaviour of the client or our data.

Both go on their own line inside the comment block that already explains them; the
body stays where it is. Everything below the tag line, until the comment block ends,
is the note.

★ INFERENCE WAS TRIED AND MEASURED, AND IT DOES NOT WORK. The ★/⚠ markers are
recency, not weight - 346 single-star lines, and `map.lua` carries 101 marked lines
with no ★★★ while a file written that afternoon had seven. Quoted text is no better:
118 quoted comment lines, only 8 overlapping a marker, and the quote catches ordinary
prose as readily as a ruling.

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

TAG = re.compile(r'^\s*--\s*(RULING|FACT):\s*(.+?)\s*$')
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
        kind, head = m.group(1), m.group(2)
        if not seen_code:
            scope = "(file)"
        else:
            # Walk to the end of this comment block, then see what it precedes.
            j = i + 1
            while j < len(lines) and COMMENT.match(lines[j]):
                j += 1
            scope = scope_of(lines, j)
        out.append({"kind": kind, "head": head, "file": rel,
                    "line": i + 1, "scope": scope})
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
              "| What | Governs | Where |", "|---|---|---|"]
        if not rows:
            L.append("| — | — | — |")
        for n in sorted(rows, key=lambda r: (r["file"], r["line"])):
            L.append("| %s | `%s` | `%s:%d` |" % (n["head"], n["scope"], n["file"], n["line"]))
        L.append("")
    L += ["---", "",
          "## The convention", "",
          "```lua",
          "-- RULING: <one line>      a decision and its reasoning",
          "-- FACT:   <one line>      measured behaviour of the client or our data",
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
