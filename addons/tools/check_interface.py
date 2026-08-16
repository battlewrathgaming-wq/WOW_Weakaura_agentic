"""check_interface.py - reconcile the surface files against the source (§120).

★★★ WHY. The surface files are the AUTHORITY, and an authority nobody checks becomes a
story. Meanwhile the code moves: insert one line in `object.lua` and every `forms
object.lua:432` below it is pointing at the wrong thing, silently.

★★ HIS FRAMING, AND IT IS NOT A COMPLIANCE TOOL:

    *"Curation of input is still needed. But so it's not justification. It's fact that
    there will be lag during active development. But so we can reconcile and shake out
    what proved false rather than keep building on them."*

⚠ SO LAG IS EXPECTED, NOT A FAILURE. This does not grade. It reports where the file and
the source have drifted apart so a human can decide which one is wrong - and the whole
point is to catch a claim that has quietly become false BEFORE something is built on it.

★ WHAT IT CAN CHECK, and it is deliberately only the mechanical part:

    the source file named in the header exists
    the global named in the header appears in it
    the declared SIZE matches the SetWidth/SetHeight in that file
    every `forms <file> · <phrase>` still names exactly ONE place in that file
    every top-level pane in the addon has a surface file

⚠ WHAT IT CANNOT: whether `does`, `refuses` or `how` are still true. Those are curation,
and pretending a tool could check them is the justification he warned about.

Usage:
    py addons\\tools\\check_interface.py
    py addons\\tools\\check_interface.py --quiet     only drift, nothing when clean
"""
import io
import re
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

HERE = Path(__file__).resolve().parent
ADDONS = HERE.parent
SURFACES = ADDONS / "planning" / "interface"
ADDON = ADDONS / "COA_DungeonRun"

# _`object.lua` · `COA_DungeonRunObject` · **240 × 600** · ...
# ⚠ The Map controls' header names a LINE too (`map.lua:1848`) because that pane is not
# the first frame in its file; the `(?::\d+)?` allows it without demanding it.
HEADER = re.compile(r"_`([\w.]+)(?::\d+)?`\s*·\s*`(\w+)`\s*·\s*\*\*(.+?)\*\*")
SIZE = re.compile(r"(\d+)\s*×\s*(\d+)")

# ★★★ PHRASES, NOT LINE NUMBERS. A citation was `forms object.lua:432` for about four
# hours, and this checker found 27 of the 29 already rotten - object.lua's all +1 from a
# comment that grew, promoter.lua's all -1 from a `local` that was removed.
#
# ⚠⚠ AND THE PRECEDENT WAS ALREADY ON THIS BENCH. Earlier the same day a line-number
# citation REPAIRER was built, was wrong twice, and was deleted - the fix then was to
# change the format to phrases. I wrote line numbers anyway. ★ A phrase survives an
# insert; a line number is wrong the moment anyone breathes on the file above it.
FORMS = re.compile(r"forms\s+([\w.]+)\s*·\s*`([^`]+)`")
# every top-level pane in the addon
PANE = re.compile(r'CreateFrame\("Frame",\s*"(\w+)",\s*UIParent\)')


def body_of(lines):
    """Joined once, so a heredoc cannot break the newline literal again."""
    return chr(10).join(lines)


def lua(name):
    p = ADDON / name
    if not p.exists():
        return None
    return io.open(p, encoding="utf-8", newline="").read().split("\n")


def check_surface(path, drift):
    text = io.open(path, encoding="utf-8", newline="").read()
    stem = path.stem

    m = HEADER.search(text)
    if not m:
        drift.append((stem, "header", "no `file` · `global` · **size** header to check against"))
        return
    src, glob_name, size_txt = m.group(1), m.group(2), m.group(3)

    lines = lua(src)
    if lines is None:
        drift.append((stem, "source", "names `%s`, which does not exist" % src))
        return

    body = "\n".join(lines)
    if glob_name not in body:
        drift.append((stem, "global", "names `%s`, which is not in %s" % (glob_name, src)))

    # --- the declared size against the code's own SetWidth/SetHeight --------
    # ⚠ A pane whose size is a RULE (the Map) says so; there is no pair to compare.
    sz = SIZE.search(size_txt)
    if sz:
        want = (int(sz.group(1)), int(sz.group(2)))
        got = re.search(r"f:SetWidth\((\d+)\);\s*f:SetHeight\((\d+)\)", body) \
            or re.search(r"\w+:SetWidth\((\d+)\);\s*\w+:SetHeight\((\d+)\)", body)
        if not got:
            drift.append((stem, "size", "declares %d × %d; no literal SetWidth/SetHeight pair "
                                        "found in %s to compare" % (want[0], want[1], src)))
        elif (int(got.group(1)), int(got.group(2))) != want:
            drift.append((stem, "size", "declares %d × %d; %s builds %s × %s"
                          % (want[0], want[1], src, got.group(1), got.group(2))))

    # --- every citation names exactly ONE place in its file ----------------
    # ⚠ Zero and MORE THAN ONE are both faults, and the second is the quieter: an
    # ambiguous phrase points at whichever site the reader happens to find first.
    for cited_src, phrase in FORMS.findall(text):
        cl = lua(cited_src)
        if cl is None:
            drift.append((stem, "cite", "`%s` - no such file as %s" % (phrase, cited_src)))
            continue
        hits = body_of(cl).count(phrase)
        if hits == 0:
            drift.append((stem, "cite", "%s · `%s` - GONE from the source"
                          % (cited_src, phrase)))
        elif hits > 1:
            drift.append((stem, "cite", "%s · `%s` - names %d places, so it names none"
                          % (cited_src, phrase, hits)))


INDEX = ADDONS / "planning" / "dungeonrun_interface_inventory.md"


def not_surfaces():
    """Frames DECLARED as machinery in the index's "Not surfaces" table.

    ★ Read rather than hardcoded: an exemption is a claim, and claims live on disk
    where they can be argued with. A list inside the tool is a list nobody sees.
    """
    if not INDEX.exists():
        return set()
    text = io.open(INDEX, encoding="utf-8", newline="").read()
    if "## Not surfaces" not in text:
        return set()
    # ⚠ Split on a horizontal RULE, not on any "---". The first cut used the latter
    # and stopped at the table's own |---|---| separator, so the block was the two
    # lines ABOVE the rows it was meant to read - and the exemption silently did
    # nothing while looking like it worked.
    block = re.split(r"^---\s*$", text.split("## Not surfaces", 1)[1],
                     maxsplit=1, flags=re.M)[0]
    return set(re.findall(r"\| `(\w+)` \|", block))


def check_coverage(drift):
    """Every top-level pane in the addon has a surface file, or is declared machinery."""
    described = not_surfaces()
    for path in SURFACES.glob("*.md"):
        m = HEADER.search(io.open(path, encoding="utf-8", newline="").read())
        if m:
            described.add(m.group(2))

    for p in sorted(ADDON.glob("*.lua")):
        body = io.open(p, encoding="utf-8", newline="").read()
        for name in PANE.findall(body):
            if name not in described:
                drift.append(("(coverage)", "pane",
                              "`%s` in %s has NO surface file" % (name, p.name)))


def main():
    quiet = "--quiet" in sys.argv
    if not SURFACES.is_dir():
        print("no surface folder at %s" % SURFACES)
        return 2

    drift = []
    files = sorted(SURFACES.glob("*.md"))
    for path in files:
        check_surface(path, drift)
    check_coverage(drift)

    if not drift:
        if not quiet:
            print("interface: %d surface(s) reconcile with the source" % len(files))
        return 0

    # ★★ REPORTED AS DRIFT, NEVER AS FAILURE. Lag during active development is a fact,
    # not a fault - and the file is as likely to be right as the code.
    print("interface: %d point(s) of drift across %d surface(s)" % (len(drift), len(files)))
    print("⚠ Neither side is assumed correct. Reconcile, do not obey.\n")
    last = None
    for stem, kind, what in drift:
        if stem != last:
            print("  %s" % stem)
            last = stem
        print("    [%-8s] %s" % (kind, what))
    return 1


if __name__ == "__main__":
    sys.exit(main())
