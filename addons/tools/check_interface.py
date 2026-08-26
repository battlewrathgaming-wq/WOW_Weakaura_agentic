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

# _`drive.lua` · **a MODE of `COA_DungeonRunFrame`**, not a frame · no size of its own_
#
# ★★★ A HOSTED SURFACE - the third kind, and it arrived with the first fold (drive, §680).
# It has a FILE and no global and no size, because the frame belongs to its HOST. Matching
# it explicitly is what stops a folded register reading as a malformed one.
# ⚠ The host's global is still checked, just against the addon folder rather than this
# file: a mode naming a frame nothing builds is exactly the drift this tool is for.
HOSTED = re.compile(r"_`([\w.]+)`\s*·\s*\*\*a MODE of `(\w+)`\*\*")

# Printed in the summary. ⚠ NOT kept silent: see the module docstring - a skipped
# comparison that nobody is told about is a green that means two different things.
HOSTED_SURFACES = []

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

    # ★ HOSTED FIRST. Its header cannot match HEADER, and the reason must not be reported
    # as a missing header - a different SHAPE and a malformed document are not the same
    # finding, and only one of them is someone's mistake.
    h = HOSTED.search(text)
    if h:
        src, host = h.group(1), h.group(2)
        if lua(src) is None:
            drift.append((stem, "source", "names `%s`, which does not exist" % src))
            return
        # The host's frame must actually be built somewhere. Checked across the folder
        # rather than in `src`, because the whole point is that it is NOT here.
        built = any(host in body_of(lua(f.name) or []) for f in ADDON.glob("*.lua"))
        if not built:
            drift.append((stem, "host", "is a mode of `%s`, which no file builds" % host))
        HOSTED_SURFACES.append(stem)
        check_citations(text, stem, drift)
        return

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

    check_citations(text, stem, drift)


def check_citations(text, stem, drift):
    """Every citation names exactly ONE place in its file.

    ⚠ Zero and MORE THAN ONE are both faults, and the second is the quieter: an
    ambiguous phrase points at whichever site the reader happens to find first.
    ★ Lifted out of `check_surface` when the hosted kind arrived, so a folded register
    gets the same citation check as a framed one rather than a second copy of it.
    """
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
    #
    # ⚠⚠ THE KEY IS FOUND AT THE START OF A LINE, NOT ANYWHERE IN THE TEXT (§449).
    # A bare `text.find(key + " ")` matched the FIRST textual occurrence, and these files
    # mention other controls in PROSE constantly. ★ `object.sense` appears inside
    # `object.note`'s block - in the very sentence recording that neither had a panespec
    # zone - so the check read NOTE's numbers and reported `object.sense` as 196 x 20
    # against a dropdown that is 154 x 32. The tool was comparing two different controls.
    #
    # ⚠ It was LATENT until `panespec` began declaring `object.sense` (A10.2a's first
    # fold): a key the spec does not declare is never looked up. **A dormant search bug
    # wakes up when the thing it searches for starts existing.**
    # ★ Third instance this session of a search finding the WORD and not the thing:
    # `smoke_chain`'s `od` (another addon's), `Spec` vs `Panespec` (the wrong export
    # name), and this. The tell is the same each time - the match was not anchored to
    # what makes it a DECLARATION.
    for key, (wv, hv, kind, pad) in sorted(spec.items()):
        m = re.search(r"^" + re.escape(key) + r"\s+(?:zone|kind)\s", text, re.M)
        i = m.start() if m else -1
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


def check_registry(drift, notes):
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

    # ★★★ THE SCOREBOARD GOES IN `notes`, NOT IN `drift`, AND THAT IS THE §272 FIX.
    #
    # ⚠⚠ It used to be appended to `drift` - so `if not drift: return 0` was UNREACHABLE
    # the moment any surface declared a control, and this check could never exit 0. It
    # reported "1 point(s) of drift" while saying "98 of 98 registered, 0 to go": the job
    # COMPLETE and the tool with no way to say so.
    #
    # ★ Two faults in one line, and the second is worse. A status rode in the findings
    # channel (invariant 6 inverted - agreement is supposed to be silent), and it INFLATED
    # THE COUNT, so "1 point of drift" meant zero. A check that always fails is one people
    # learn to ignore, and then it cannot tell them when something real breaks - the same
    # way the boot check decayed. An instrument stops being believed before it stops
    # being run.
    #
    # ★ The scoreboard itself was right to exist: "naming the controls" is a long job and
    # a number that moves is what makes it finishable. It just is not a finding.
    if literals:
        notes.append("registry: %d of %d declared controls registered (%d to go, %d patterns)"
                     % (len(literals) - len(missing), len(literals),
                        len(missing), len(patterns)))


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


ADAPTOR = ADDONS / "planning" / "driver_adaptor_table.md"

# ★★★ §3b's FAIL LIST, VERBATIM. "Once · latch · edge · level · hysteresis · activate ·
# trip · satellite · completor fail - those are ours in the code, never the author's in
# the pane."
#
# ⚠ TRANSCRIBED, NOT INTERPRETED. Every word here is in the law by name. `ratchet` and
# `on-ramp` are the same FAMILY and are NOT in it, so they are reported by the adaptor
# table's own second list rather than failed on here - the checker enforces what is
# WRITTEN and reports what is JUDGED, and it must not blur the two.
BANNED = ("once", "latch", "edge", "level", "hysteresis",
          "activate", "trip", "satellite", "completor")

# Where an author-facing string is built.
#
# ⚠⚠ SCANNED PER LINE, AND THE FIRST CUT WAS NOT. `\([^,]*,?\s*"..."` let `[^,]*` run
# ACROSS NEWLINES, so it paired a `SetText(` on one line with a quote thirty lines below
# and reported five §3b breaches that were all COMMENT TEXT - including the comment
# explaining the `satellite` fix. ★ A checker whose first output is five false positives
# teaches people to skim it, which is the failure it exists to prevent.
SPEAKS = re.compile(r'(?:SetText|UIDropDownMenu_SetText)\([^"\n]*"([^"\n]{2,})"')
IS_COMMENT = re.compile(r"^\s*--")


def adaptor_rows():
    """The `code` column, from the tables' first cell."""
    if not ADAPTOR.is_file():
        return None
    text = io.open(ADAPTOR, encoding="utf-8", errors="replace").read()
    out = set()
    for line in text.splitlines():
        if not line.startswith("|"):
            continue
        cell = line.split("|")[1].strip().strip("~").strip()
        for tok in re.findall(r"`([^`]+)`", cell):
            out.add(tok.strip())
            out.add(tok.split("\u2192")[-1].strip())
    return out


def check_adaptor(drift, notes):
    """A5.3 - two directions, and they REPORT DIFFERENTLY on purpose.

    ★ §295 ruled PASS-THROUGH: a question-layer term with no row renders as the CODE
    NAME, so what the instruction called for is still expressed. **A missing row is
    legal for the author** - it degrades to legible, never to blank. So it is a NOTE.

    ⚠ A §3b BANNED WORD reaching a pane is not legal in either direction. That is
    DRIFT, and it is the half nobody can be trusted to remember at the moment of typing
    a string - three such terms reached panes in one week, two of them from this bench.
    """
    rows = adaptor_rows()
    if rows is None:
        drift.append(("(adaptor)", "missing",
                      "no `driver_adaptor_table.md` to check against"))
        return

    src = body_of(lua("routes.lua") or [])
    missing = []
    for name, body in re.findall(r"^Routes\.([A-Z]+)\s*=\s*\{([^}]*)\}", src, re.M):
        for val in re.findall(r'"([^"]+)"', body):
            if val not in rows:
                missing.append("%s -> %s" % (name, val))

    for stem in ("object.lua", "promoter.lua", "editor.lua", "map.lua"):
        for line in (lua(stem) or []):
            if IS_COMMENT.match(line):
                continue                      # a comment is not said to anybody
            for said in SPEAKS.findall(line):
                low = said.lower()
                for word in BANNED:
                    if re.search(r"\b" + word, low):
                        drift.append(("(adaptor)", "3b",
                                      "%s says %r - `%s` is on the naming law's FAIL "
                                      "list" % (stem, said[:46], word)))

    if missing:
        notes.append("adaptor: %d vocabulary value(s) with no row - PASS THROUGH, "
                     "legible to the author, listed for the bench: %s"
                     % (len(missing), " \u00b7 ".join(sorted(missing)[:6])))
    else:
        notes.append("adaptor: every published vocabulary value has a row")

    # ★★ A9.3 - the OWED list, read out of the table's own second section.
    #
    # ⚠ These are terms the bench has JUDGED to be §3b's family without their being in
    # the law by name - `ratchet` is one of the three stage registers, `on-ramp` is ours.
    # The checker cannot fail on a judgement, and it must not pretend the judgement is
    # the law. So it READS THE TABLE'S OWN LIST and says how many are outstanding.
    #
    # ★ Which makes the list self-emptying: strike a row when its string is fixed and
    # this number falls. `satellite` came off it that way in §326.
    owed = []
    if ADAPTOR.is_file():
        text = io.open(ADAPTOR, encoding="utf-8", errors="replace").read()
        tail = text.split("NO user word", 1)[-1]
        for line in tail.splitlines():
            if not line.startswith("|"):
                continue
            cell = line.split("|")[1].strip()
            if cell.startswith("~~") or cell in ("code", "---", ":---"):
                continue                       # struck = fixed; the header is not a term
            for tok in re.findall(r"`([^`]+)`", cell):
                owed.append(tok)
    if owed:
        notes.append("adaptor: %d term(s) reach a pane with NO user word, judged \u00a73b's "
                     "family but not in the law by name - %s"
                     % (len(owed), " \u00b7 ".join(owed)))


def main():
    quiet = "--quiet" in sys.argv
    if not SURFACES.is_dir():
        print("no surface folder at %s" % SURFACES)
        return 2

    drift, notes = [], []
    files = sorted(SURFACES.glob("*.md"))
    for path in files:
        check_surface(path, drift)
    check_spec(drift)
    check_registry(drift, notes)
    check_adaptor(drift, notes)
    check_coverage(drift)

    # ★★ SAY HOW MANY SURFACES HAD NO SIZE TO COMPARE. RI-83 found this tool could not
    # tell *"no sizes declared"* from *"all sizes agree"*; the hosted kind adds a second
    # way to compare nothing, so the count goes on screen rather than into the silence.
    # ⚠ A NOTE, never a finding - a hosted surface having no size of its own is CORRECT.
    if HOSTED_SURFACES:
        notes.append("hosted: %d surface(s) are a MODE of another's frame, so NO size was "
                     "compared for them - %s"
                     % (len(HOSTED_SURFACES), " · ".join(sorted(HOSTED_SURFACES))))

    if not drift:
        if not quiet:
            print("interface: %d surface(s) reconcile with the source" % len(files))
            # ★ Still printed when clean - that was always the scoreboard's job, and it
            # is why it must not be a finding: a progress number is most useful exactly
            # when there is nothing wrong.
            for n in notes:
                print("  %s" % n)
        return 0

    # ★★ REPORTED AS DRIFT, NEVER AS FAILURE. Lag during active development is a fact,
    # not a fault - and the file is as likely to be right as the code.
    print("interface: %d point(s) of drift across %d surface(s)" % (len(drift), len(files)))
    print("⚠ Neither side is assumed correct. Reconcile, do not obey.\n")
    for n in notes:
        print("  %s" % n)
    if notes:
        print("")
    last = None
    for stem, kind, what in drift:
        if stem != last:
            print("  %s" % stem)
            last = stem
        print("    [%-8s] %s" % (kind, what))
    return 1


if __name__ == "__main__":
    sys.exit(main())
