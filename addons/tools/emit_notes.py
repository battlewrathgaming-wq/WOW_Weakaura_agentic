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
    py addons\\tools\\emit_notes.py --reach     # does the SHELF carry the silent ones?
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
TAG = re.compile(r'^\s*--\s*([★]*)\s*(RULING|FACT|OPEN):\s*(.+?)\s*$')
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
        # ★★ CONSEQUENCE, read off a `[SILENT]` prefix in the headline. His axis, and
        # it is sharper than kind: what matters is WHAT HAPPENS IF YOU IGNORE IT.
        #
        #   SILENT  it looks like it worked. You will NEVER learn this from the
        #           symptom, so it has to be reachable BEFORE you need it.
        #   (other) the client tells you - it throws, hangs, or renders nothing.
        #           Expensive once, then learned.
        #
        # ★★★ 31 of 42 facts here are SILENT. That is the finding: almost everything
        # this bench has paid to learn is a failure that does not announce itself.
        # ★★★ AND `[CULTURE]` IS THE OTHER END OF THE SAME AXIS. Battlewrath, on
        # "a plugin owns no machinery; loading it declares interest":
        #
        #     "This is about culture. How we decide to be respectful on someone's
        #     machine. Nothing that will ever manifest in code rejection or be
        #     'bad code'."
        #
        # ★★ SILENT and CULTURE are the two classes that most need writing down, for
        # OPPOSITE reasons. Silent, because the failure HIDES. Culture, because there
        # IS no failure - no test goes red, no client breaks. It just quietly becomes
        # an addon that takes more than it was given.
        mark = ""
        for m in ("[SILENT]", "[CULTURE]"):
            if head.startswith(m):
                mark = m.strip("[]")
                head = head[len(m):].strip()
        out.append({"kind": kind, "head": head, "file": rel, "line": i + 1,
                    "scope": scope, "weight": len(stars),
                    "silent": mark == "SILENT", "mark": mark})
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
    opens = [n for n in found if n["kind"] == "OPEN"]
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
         f"**{len(rulings)} ruling(s) · {len(facts)} fact(s) · {len(opens)} open.**", "",
         "★★★ **`SILENT` is the column that matters.** Battlewrath: *\"some are taste and "
         "preference. Some are things that will make the written code fail silently / loudly / "
         "throw error.\"* A fact that **throws** teaches itself the first time you hit it. A fact "
         "that fails **silently** produces something that looks like it worked — you will never "
         "learn it from the symptom, so it has to be reachable BEFORE you need it.", "",
         f"⚠ **{sum(1 for n in facts if n['silent'])} of {len(facts)} facts here are SILENT.** "
         "That is the finding, not a detail: almost everything this bench has paid to learn is a "
         "failure that does not announce itself.", "",
         "★★★ **And `CULTURE` is the far end of the same axis.** *\"This is about culture. How we "
         "decide to be respectful on someone's machine. Nothing that will ever manifest in code "
         "rejection or be 'bad code'.\"* **SILENT and CULTURE are the two classes that most need "
         "writing down, for opposite reasons** — silent because the failure HIDES, culture because "
         "there IS no failure. No test goes red. It just quietly becomes an addon that takes more "
         "than it was given.", ""]
    for title, rows, blurb in (
            ("RULINGS", rulings,
             "Decisions and their reasoning. Mostly his. **`CULTURE` = manners on someone else's "
             "machine** — baseline-off, no borrowed clocks, nothing that nags, nothing that judges, "
             "read-only on data that is not ours. ⚠ **Breaking one is never bad code and never "
             "fails a test.** Writing it down is the only protection it has."),
            ("FACTS", facts, "Measured behaviour of the client or our own data."),
            ("OPEN", opens,
             "**Not settled.** Each says what would settle it. ⚠ An open question dressed in real "
             "figures reads as a finding — which is how a trap gets quoted forward past its "
             "evidence. RULING and FACT both mean SETTLED; this is the third status, and it exists "
             "because a block can be well-researched and still not be an answer.")):
        L += [f"## {title}", "", f"_{blurb}_", "",
              "| Fails | Wt | What | Governs | Where |", "|---|---|---|---|---|"]
        if not rows:
            L.append("| — | — | — | — | — |")
        # SILENT first, then weight. The class you cannot learn by doing leads.
        for n in sorted(rows, key=lambda r: (not r["mark"], -r["weight"],
                                             r["file"], r["line"])):
            L.append("| %s | %s | %s | `%s` | `%s:%d` |" % (
                ("**" + n["mark"] + "**") if n["mark"] else "—",
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


# ---------------------------------------------------------------------------
# ★★★ REACHABILITY - does the SHELF carry what the notes learned?
#
# The index makes a note findable by grep. The shelf is where you look BEFORE you
# know what to grep for - "I am about to do X, what is in play". Those are different
# jobs, and only the second one catches a lesson you did not know existed.
#
# ★★ So the question this answers is his: *"then we'll challenge how intent carries
# them, so we can fall back on their use / insights rather than rederiving."* A SILENT
# fact that no shelf section reaches is one we WILL pay for twice - the index will not
# save you, because you have to already suspect it to search for it.
#
# ⚠ REACHABLE = A SEARCHER FINDS IT. Not "a section is thematically about it" - that
# is a judgement, and a judgement I make about my own document is worth nothing. The
# key is the API NAME in the headline: if `GetCursorPosition` appears on the shelf, a
# reader reaching for it lands on the row. If it does not, they do not.
#
# ★ It reports three buckets and rules on none of them (§: emit, don't interpret).
# UNKEYED notes carry no identifier at all - the CULTURE rulings, mostly - and no
# token test can speak to those, so they are handed over rather than guessed at.
KEY = re.compile(r'`([^`]+)`|\b([A-Z]\w*[A-Z]\w*|[A-Z]\w+\.\w+|C_\w+)\b')
# ⚠ THE HOUSE STYLE SHOUTS, and the first run of this mistook shouting for naming:
# `FAILS`, `SAME`, `LABEL`, `PULLED` were all read as API names and reported as gaps,
# which would have sent me editing the shelf to satisfy the tool. An ALL-CAPS word is
# EMPHASIS here; an ALL-CAPS word WITH UNDERSCORES is an event name and a real key.
SHOUT = re.compile(r'^[A-Z]+$')
KEY_STOP = {"CoA"}


def shelf_reach(found, shelf_text):
    """Which SILENT/CULTURE notes are reachable from the shelf, by name."""
    out = []
    for n in found:
        if not n["mark"]:
            continue
        keys = []
        for a, b in KEY.findall(n["head"]):
            k = (a or b).strip()
            if len(k) > 2 and k not in KEY_STOP and not k.isdigit()                     and not SHOUT.match(k):
                keys.append(k)
        keys = list(dict.fromkeys(keys))
        # ★★ AND A CITATION IS ALSO A KEY. `file.lua:59` on the shelf is the
        # explicit way to claim a note that carries no API name at all - most of
        # the manners are like that ("the driver INFORMS, it never grades"). It
        # is the same idea as apply_tags' anchor: the pointer IS the proof, so a
        # row can only claim a note that actually exists at that line.
        cite = "%s:%d" % (n["file"], n["line"])
        hit = [k for k in keys if k in shelf_text]
        if cite in shelf_text:
            hit.append(cite)
            keys.append(cite)
        out.append((n, keys, hit))
    return out


def report_reach(found, shelf):
    rows = shelf_reach(found, io.open(shelf, encoding="utf-8").read())
    buckets = {"REACHED": [], "UNREACHED": [], "UNKEYED": []}
    for n, keys, hit in rows:
        buckets["REACHED" if hit else ("UNKEYED" if not keys else "UNREACHED")].append(
            (n, keys, hit))
    for b in ("UNREACHED", "UNKEYED", "REACHED"):
        if not buckets[b]:
            continue
        print("\n%s (%d)" % (b, len(buckets[b])))
        for n, keys, hit in buckets[b]:
            print("  [%-7s] %-34s %s" % (n["mark"], n["file"] + ":" + str(n["line"]),
                                         n["head"][:64]))
            if b != "REACHED":
                print("            keys: %s" % (", ".join(keys) or "(none)"))
    print("\n%d marked note(s): %d reached, %d UNREACHED, %d unkeyed" % (
        len(rows), len(buckets["REACHED"]), len(buckets["UNREACHED"]),
        len(buckets["UNKEYED"])))
    return 1 if buckets["UNREACHED"] else 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true",
                    help="report whether the emitted index is stale; write nothing")
    ap.add_argument("--reach", action="store_true",
                    help="is every SILENT/CULTURE note reachable from the intent shelf?")
    a = ap.parse_args()

    if a.reach:
        return report_reach(collect(), ADDONS / "maps" / "intent.md")

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
    print("wrote %s - %d ruling(s), %d fact(s), %d open" % (
        OUT, sum(1 for n in found if n["kind"] == "RULING"),
        sum(1 for n in found if n["kind"] == "FACT"),
        sum(1 for n in found if n["kind"] == "OPEN")))
    return 0


if __name__ == "__main__":
    sys.exit(main())
