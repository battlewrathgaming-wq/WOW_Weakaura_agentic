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
    every cell panespec.lua builds matches the width and height the file declares
    every declared control has a registration, and every registration a declaration

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


SPEC = ADDON / "panespec.lua"

# { "object.name",   0, "edit", 170 }   /   { "object.fact", 0, "text" }
CELL = re.compile(r'\{\s*"([\w.]+)"\s*,\s*(\w+)\s*,\s*"(\w+)"\s*(?:,\s*(\w+)\s*)?\}')
CONST = re.compile(r"^local (\w+)\s*=\s*(\d+)", re.M)
TABLE = re.compile(r"(\w+)\.([HW])\s*=\s*\{([^}]*)\}")
PAIR = re.compile(r"(\w+)\s*=\s*(\d+)")

# numbers w 170 · h 20      /      numbers field 154 · art 204 · h 32
DOC_W = re.compile(r"numbers\s+(?:w|field)\s+(\d+)")
DOC_H = re.compile(r"\bh\s+(\d+)")


def spec_numbers():
    """Every cell panespec.lua declares, resolved to (width, height).

    ★ Resolved the same way `Spec.Build` resolves it - explicit 4th field, then
    `Spec.W[kind]`, then the column remainder for text - so the comparison is against
    what the pane will actually be built at, not against the literal in the table.
    """
    if not SPEC.exists():
        return {}
    text = io.open(SPEC, encoding="utf-8", newline="").read()
    consts = {k: int(v) for k, v in CONST.findall(text)}
    tables = {}
    for owner, kind, body in TABLE.findall(text):
        tables.setdefault(kind, {}).update(
            {k: int(v) for k, v in PAIR.findall(body)})

    # ⚠ Layout.H is the CLIENT's default and Spec.H is ours; ours wins, exactly as
    # Spec.Build does it. Getting that order wrong would compare against a pane we
    # do not have - which is the fault the §101 mutation caught.
    layout = ADDON / "layout.lua"
    client_h = {}
    if layout.exists():
        lt = io.open(layout, encoding="utf-8", newline="").read()
        for owner, kind, body in TABLE.findall(lt):
            if kind == "H":
                client_h.update({k: int(v) for k, v in PAIR.findall(body)})
    pad = 0
    m = re.search(r"Layout\.DROPDOWN_PAD\s*=\s*(\d+)", ADDON.joinpath("layout.lua")
                  .read_text(encoding="utf-8") if layout.exists() else "")
    if m:
        pad = int(m.group(1))

    width = consts.get("width") or 204
    m = re.search(r"Spec\.x,\s*Spec\.top,\s*Spec\.width\s*=\s*[-\d]+,\s*[-\d]+,\s*(\d+)", text)
    if m:
        width = int(m.group(1))

    out = {}
    for key, x, kind, w in CELL.findall(text):
        xv = consts.get(x, None)
        if xv is None:
            try:
                xv = int(x)
            except ValueError:
                xv = 0
        if w:
            wv = consts.get(w, None)
            if wv is None:
                try:
                    wv = int(w)
                except ValueError:
                    wv = None
        else:
            wv = tables.get("W", {}).get(kind)
            if wv is None and kind == "text":
                wv = width - xv
        hv = tables.get("H", {}).get(kind) or client_h.get(kind)
        out[key] = (wv, hv, kind, pad)
    return out


def check_spec(drift):
    """panespec.lua against the surface file that declares it.

    ★★★ DIRECTION MATTERS. The surface file is the AUTHORITY and the spec is code
    complying with it, so a difference is read as *the spec has drifted*, never as
    *the doc is out of date*. The positional values are exactly the class that churns
    during active development - which is why they get a check rather than a promise.
    """
    spec = spec_numbers()
    if not spec:
        return
    path = SURFACES / "object.md"
    if not path.exists():
        drift.append(("(spec)", "spec", "panespec.lua declares cells but object.md is missing"))
        return
    text = io.open(path, encoding="utf-8", newline="").read()

    # each child block starts at its key and runs to the next key or a blank line
    for key, (wv, hv, kind, pad) in sorted(spec.items()):
        i = text.find(key + " ")
        if i < 0:
            drift.append(("object", "spec", "`%s` is in panespec.lua and NOT in the file" % key))
            continue
        chunk = text[i:i + 400]
        dw = DOC_W.search(chunk)
        dh = DOC_H.search(chunk)
        if dw and wv is not None and int(dw.group(1)) != wv:
            drift.append(("object", "spec", "`%s` — file says w %s, panespec builds %d"
                          % (key, dw.group(1), wv)))
        if dh and hv is not None and int(dh.group(1)) != hv:
            drift.append(("object", "spec", "`%s` — file says h %s, panespec builds %d"
                          % (key, dh.group(1), hv)))


# object.name        zone identity  row 2 ...   /   map.title   kind readout ...
DECLARED = re.compile(r"^([a-z_]+\.[\w.<>|]+)\s+(?:zone|kind)\s", re.M)
# ⚠⚠ THIS LINE CAME OUT OF A BASH HEREDOC AS a literal BACKSPACE where a word-boundary
# escape was meant. The regex matched nothing, the tool reported 0 of 73 registered,
# and that read as a FINDING rather than a bug. ★ Fourth escape casualty of the day
# and the worst: the other three were syntax errors, which announce themselves.
# R("object.role", roleDD, ...)   /   UI.Register("x", ...)
REGISTERED = re.compile(r'(?:\bR|UI\.Register)\(\s*"([\w.]+)"')


def check_registry(drift):
    """Every declared control has a registration, and every registration a declaration.

    ★★★ BOTH DIRECTIONS. A registration with no entry is as much a gap as an entry with
    no registration - the first means the code can be driven by something the docs do
    not describe, the second means the geometry probe cannot see it at all.

    ⚠ A key containing `<` is a PATTERN, not a literal - `editor.kind.<key>` stands for
    one control per FILTERS entry. Matched by prefix, because the count is a runtime
    fact and this is a static read.
    """
    declared = set()
    for path in SURFACES.glob("*.md"):
        declared |= set(DECLARED.findall(
            io.open(path, encoding="utf-8", newline="").read()))

    registered = set()
    for p in ADDON.glob("*.lua"):
        registered |= set(REGISTERED.findall(
            io.open(p, encoding="utf-8", newline="").read()))

    patterns = {k for k in declared if "<" in k}
    literals = declared - patterns

    missing = sorted(literals - registered)
    for key in missing:
        drift.append(("(registry)", "unnamed", "`%s` is declared and NOT registered" % key))

    for key in sorted(registered - literals):
        if any(key.startswith(p.split("<")[0]) for p in patterns):
            continue
        drift.append(("(registry)", "undeclared",
                      "`%s` is registered and in NO surface file" % key))

    # ★ The scoreboard, printed even when there is nothing else to say - "naming the
    # controls" is a long job and a number that moves is what makes it finishable.
    if literals:
        drift.append(("(registry)", "score",
                      "%d of %d declared controls are registered (%d to go, %d patterns)"
                      % (len(literals) - len(missing), len(literals),
                         len(missing), len(patterns))))


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
    check_spec(drift)
    check_registry(drift)
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
