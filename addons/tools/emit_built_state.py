r"""emit_built_state.py - WHICH PUBLIC FUNCTIONS ARE REACHABLE, AND WHICH ARE STRANDED.

★★★ THE SIBLING OF `emit_store_inventory.py`, one level up. That tool answers *written
here, read there* for FIELDS. This one answers it for FUNCTIONS - and a public module
function with no caller outside its own file is the STRANDED bucket of
`addons/planning/driver_built_state.md`.

    py addons/tools/emit_built_state.py            markdown to stdout
    py addons/tools/emit_built_state.py --out P    write it to P
    py addons/tools/emit_built_state.py --check    apparatus only, exit 1 on fail

★★ IT PROVES ITS APPARATUS IN BOTH DIRECTIONS, which is the half that is usually skipped.
A detector that finds nothing and a codebase with nothing to find look identical in a
file, so `--check` asserts BOTH that functions known to be reachable come back reachable
AND that functions known to be stranded come back stranded. **A claim of absence must
prove its detector first** - the same rule the api probe was rebuilt around after run 1
reported four disagreements that were all "my experiment never ran".

⚠⚠ WHAT IT CANNOT KNOW:
  - COMMENTS ARE STRIPPED FIRST, and this repo's comments name functions constantly. Without
    that, every function looks reachable and the tool is worse than useless.
  - Reachable is not the same as USED. A caller inside dead code still counts as a caller.
  - It says nothing about GRADED. A criterion does not cite the function it grades today,
    so the UNGUARDED bucket cannot be emitted - see the fact file's own note.
  - Dispatch through a table (`handlers[k](...)`) is invisible to it.
"""

import argparse
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "COA_DungeonRun")
SMOKE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "smoke")
TOOLS = os.path.dirname(os.path.abspath(__file__))

# Module tables the addon exposes on NS. A definition on anything else is a local helper
# and is not part of the public surface this tool reports on.
MODULES = ("Routes", "Store", "Map", "Object", "UI", "Editor", "Promoter", "Capture",
           "Core", "Adaptor", "Layout", "Widget", "Options", "Spec", "Panespec",
           "Calibrate", "Rule", "Contract", "Sensor", "Bucket", "NS", "F")

# ★★ `Rule` ADDED 2026-08-20 - and the way it was missing is the point. `rule.lua` (P3,
# §416) defined a whole new namespace and this hand-kept list simply did not mention it, so
# every function in the driver's rule was invisible: not stranded, not test-only, ABSENT. The
# only reason it surfaced is that a `grades` citation named one and the ghost check refused.
#
# ⚠⚠ A SILENT ALLOWLIST IS THE SAME FAULT THE WHOLE TOOL EXISTS TO CATCH - a scope that
# excludes what would contradict it. `UNLISTED` below makes the hole LOUD: a product .lua that
# defines a namespace nobody listed is now a refusal, not a quiet under-count.
#
# ⟶ `Sensor` ADDED 2026-08-20 (P5, §425), AND THE GUARD IS WHY. `sensor.lua` landed the same
# day and `UNLISTED` refused to emit before anything else noticed - no ghost citation needed
# this time, no acceptance row involved. ★ The Rule case surfaced by luck; this one surfaced
# because the previous case's fix was made LOUD rather than merely applied.

DEF = re.compile(r"^function\s+([A-Z]\w*)\.([A-Za-z_]\w*)\s*\(", re.M)

# ★★★ THE JOIN BETWEEN A CRITERION AND THE CODE IT GRADES.
# An acceptance row may carry ONE indented line naming the functions it grades:
#
#       grades  Routes.StageOf · Routes.ParentOf
#
# ⚠ Deliberately an EXPLICIT MARKER rather than "any backticked name in the row" - these
# documents mention functions in prose constantly, so an implicit rule would call every
# row graded and the tool would be worse than nothing. A row with no `grades` line is
# UNMAPPED, and the coverage count is the honest measure of how much of the acceptance
# can be joined to code at all.
ACCEPTANCE = ("driver_authoring_acceptance.md", "driver_walk_acceptance.md",
              "driver_ui_acceptance.md", "driver_sense_acceptance.md")
ROW = re.compile(r"\*\*((?:A|W)\d+\.\d+[a-z]?)\b")
GRADES = re.compile(r"^\s+grades\s+(.+?)\s*$", re.M)
FN = re.compile(r"([A-Z]\w*\.[A-Za-z_]\w*)")

# ★ BOTH POLARITIES. Reachable ones prove the detector fires; stranded ones prove it can
# still say NO. Each was read from source by hand on 2026-08-19.
MUST_REACH = {
    "Routes.Get": "read all over the addon",
    "Store.Point": "capture mints every sample through it",
    "Routes.ChildrenOf": "the pane and the map both walk children",
}
# ★ TEST-ONLY is its own state and the first run of this tool is what proved it: `SetRow`
# and `BeaconAt` have NO production caller and ARE reached by smokes. A function the tests
# reach and the product does not is GRADED BUT NOT WIRED - a different thing from stranded,
# and the distinction only exists because the apparatus refused a wrong answer.
MUST_TEST_ONLY = {
    "Routes.SetRow": "the row grammar; smoke reaches it, no pane does",
    "Routes.BeaconAt": "the driver that would call it does not exist",
}
# ⚠⚠ RE-ANCHORED 2026-08-19 (§396). This held `Routes.SetChildFireOn` and A2.12 (§392)
# REMOVED that function - so the apparatus refused to emit, which is exactly its job.
# ★ The fix is a LIVE replacement rather than deleting the entry: without one, the tool
# has no proof it can still say NO, and a stranding detector that cannot say NO reports
# everything as reachable and looks healthy doing it.
# ★ `Adaptor.Codes` verified by hand 2026-08-19: defined at adaptor.lua:110 and named
# NOWHERE else in the addon or the smokes.
MUST_STRAND = {
    "Adaptor.Codes": "defined at adaptor.lua:110; nothing outside that file names it",
}


def strip_comments(text):
    """Drop `--` line comments. Crude, and deliberately so: it can only ever cost a
    false CALLER (a code line mistaken for a comment), never a false STRANDING."""
    out = []
    for line in text.split("\n"):
        i = line.find("--")
        out.append(line if i < 0 else line[:i])
    return "\n".join(out)


def sources():
    """(label, path, text) for every file that could define or call."""
    out = []
    for d, tag, ext in ((SRC, "", ".lua"), (SMOKE, "smoke/", ".lua"), (TOOLS, "tools/", ".py")):
        if not os.path.isdir(d):
            continue
        for f in sorted(os.listdir(d)):
            # ⚠ THIS FILE NAMES FUNCTIONS IN ITS OWN APPARATUS LIST. Counting itself as a
            # caller made three known-stranded functions look reached on the first run.
            if f == os.path.basename(__file__):
                continue
            if f.endswith(ext):
                p = os.path.join(d, f)
                raw = io.open(p, encoding="utf-8", errors="replace").read()
                out.append((tag + f, p, strip_comments(raw)))
    return out


def criteria():
    """-> graded {function: [rows]}, rows_total, rows_with_a_grades_line."""
    graded, total, mapped = {}, 0, 0
    plan = os.path.join(ROOT, "planning")
    for name in ACCEPTANCE:
        p = os.path.join(plan, name)
        if not os.path.isfile(p):
            continue
        text = io.open(p, encoding="utf-8", errors="replace").read()
        # split into row blocks: a row owns everything until the next row id
        marks = [(m.start(), m.group(1)) for m in ROW.finditer(text)]
        seen = set()
        for i, (pos, rid) in enumerate(marks):
            if rid in seen:
                continue                      # a row's id may be cited again later on
            seen.add(rid)
            total += 1
            end = marks[i + 1][0] if i + 1 < len(marks) else len(text)
            block = text[pos:end]
            g = GRADES.search(block)
            if not g:
                continue
            fns = FN.findall(g.group(1))
            if not fns:
                continue
            mapped += 1
            for fn in fns:
                graded.setdefault(fn, []).append(rid)
    return graded, total, mapped


def collect():
    files = sources()
    defs = {}                                   # "Routes.Get" -> defining label
    for label, _, text in files:
        # ⚠ ONLY THE PRODUCT'S OWN SURFACE. A helper defined in `smoke/` and used only by
        # smokes is correct by construction, and reporting it as stranded or test-only is
        # noise that buries the real rows - seven `F.*` and several others on the first emit.
        if not label.endswith(".lua") or label.startswith("smoke/"):
            continue
        for mod, name in DEF.findall(text):
            if mod in MODULES:
                defs.setdefault("%s.%s" % (mod, name), label)

    prod = {k: set() for k in defs}
    test = {k: set() for k in defs}
    for label, _, text in files:
        for k in defs:
            if label == defs[k]:
                continue                        # its own file is not an external caller
            mod, name = k.split(".", 1)
            # `Routes.Get(` after aliasing, or `NS.Routes.Get(`, or passed by reference
            if re.search(r"(?<![\w.])(?:NS\.)?%s\.%s\b" % (mod, name), text):
                (test if label.startswith("smoke/") else prod)[k].add(label)

    # ★★★ TRANSITIVE REACHABILITY WITHIN A FILE, and the tool was WRONG without it.
    # `Routes.Init` is called from `core.lua`; `Init` then calls `Routes.MigrateRIDs` and
    # `Routes.DropRetired` at `routes.lua:55-56`. Both are production code that runs on every
    # load — and the first version of this tool reported them TEST-ONLY, because a call from
    # a function's own file was excluded as "not external". ⚠ Excluding the defining file is
    # right for finding a stranded SURFACE and wrong for deciding what actually runs.
    bodies = {}
    for label, _, text in files:
        if not label.endswith(".lua") or label.startswith("smoke/"):
            continue
        marks = [(m.start(), "%s.%s" % (m.group(1), m.group(2)))
                 for m in DEF.finditer(text) if m.group(1) in MODULES]
        for i, (pos, key) in enumerate(marks):
            end = marks[i + 1][0] if i + 1 < len(marks) else len(text)
            bodies.setdefault(key, text[pos:end])

    changed = True
    while changed:                              # to a fixpoint; the graph is tiny
        changed = False
        for caller in [k for k in defs if prod[k]]:
            body = bodies.get(caller, "")
            for k in defs:
                if prod[k] or k == caller:
                    continue
                mod, name = k.split(".", 1)
                if re.search(r"(?<![\w.])(?:NS\.)?%s\.%s\b" % (mod, name), body):
                    prod[k].add("%s (via %s)" % (defs[k], caller))
                    changed = True
    return defs, prod, test


def check(defs, prod, test):
    bad = []
    for k, why in MUST_REACH.items():
        if k not in defs:
            bad.append("MISSING  %-26s (%s)" % (k, why))
        elif not prod[k]:
            bad.append("SHOULD REACH but has no production caller  %-14s (%s)" % (k, why))
    for k, why in MUST_TEST_ONLY.items():
        if k not in defs:
            bad.append("MISSING  %-26s (%s)" % (k, why))
        elif prod[k]:
            bad.append("SHOULD BE TEST-ONLY but production calls it  %-10s -> %s"
                       % (k, ", ".join(sorted(prod[k]))))
        elif not test[k]:
            bad.append("SHOULD BE TEST-ONLY but no smoke reaches it  %-10s (%s)" % (k, why))
    for k, why in MUST_STRAND.items():
        if k not in defs:
            bad.append("MISSING  %-26s (%s)" % (k, why))
        elif prod[k] or test[k]:
            bad.append("SHOULD STRAND but reached  %-14s -> %s"
                       % (k, ", ".join(sorted(prod[k] | test[k]))))
    # ★ THE JOIN NEEDS ITS OWN POLARITY CHECK. A `grades` parser that silently matches
    # nothing looks exactly like an acceptance set that cites nothing.
    graded, total, mapped = criteria()
    if total == 0:
        bad.append("no acceptance rows parsed at all - the row regex is broken")
    if "Routes.StageOf" not in graded:
        bad.append("GRADES parser found nothing for Routes.StageOf (A8.1 carries the line)")
    # ⚠ The old form of this check named `Routes.SetChildFireOn`, which §392 deleted -
    # so it could never fire again and read as a passing guard while testing nothing.
    # ★ Replaced with the general rule it was a single instance of: a criterion must not
    # cite a function that does not exist, whatever its name.
    # ★ THE HOLE THE `Rule` MISS CAME THROUGH: a product file defining an unlisted namespace.
    unlisted = set()
    for label, _, text in sources():
        if not label.endswith(".lua") or label.startswith("smoke/"):
            continue
        for mod, _name in DEF.findall(text):
            if mod not in MODULES:
                unlisted.add("%s (%s)" % (mod, label))
    if unlisted:
        bad.append("product file(s) define UNLISTED namespaces, so their functions are "
                   "invisible to every bucket: %s - add them to MODULES"
                   % ", ".join(sorted(unlisted)))

    ghosts = sorted(f for f in graded if f not in defs)
    if ghosts:
        bad.append("a criterion cites %d function(s) that DO NOT EXIST: %s"
                   % (len(ghosts), ", ".join(ghosts[:5])))

    for b in bad:
        sys.stderr.write("  APPARATUS  %s\n" % b)
    return not bad


def emit(defs, prod, test):
    out = []
    w = out.append
    graded, rows_total, rows_mapped = criteria()
    stranded = sorted(k for k in defs if not prod[k] and not test[k])
    testonly = sorted(k for k in defs if not prod[k] and test[k])
    wired = sorted(k for k in defs if prod[k])
    landed = [k for k in wired if k in graded]
    unguarded = [k for k in wired if k not in graded]

    w("# BUILT STATE - emitted, do not hand-edit")
    w("")
    w("_Generated by `addons/tools/emit_built_state.py`. Re-run it rather than correcting it._")
    w("")
    w("⚠ **Reachable is not USED, and reached is not GRADED.** A caller inside dead code still")
    w("counts, and a function with callers may still have no criterion. ★ **The solid claims here")
    w("are STRANDED and TEST-ONLY** — both are statements about what does NOT name a function, and")
    w("absence is the only thing a text search can prove.")
    w("")
    w("## STRANDED — nothing outside its own file names it, not even a smoke (%d)" % len(stranded))
    w("")
    w("| function | defined in |")
    w("|---|---|")
    for k in stranded:
        w("| `%s` | %s |" % (k, defs[k]))
    w("")
    w("## TEST-ONLY — a smoke reaches it, the product does not (%d)" % len(testonly))
    w("")
    w("⚠ **Graded but not wired.** The behaviour is proven and no shipped path arrives at it — which")
    w("reads as finished to anyone opening the file, and is the state this tool exists to surface.")
    w("")
    w("| function | defined in | proven by |")
    w("|---|---|---|")
    for k in testonly:
        w("| `%s` | %s | %s |" % (k, defs[k], " · ".join(sorted(test[k]))))
    w("")
    w("## LANDED — wired, and a criterion names it (%d)" % len(landed))
    w("")
    w("| function | defined in | graded by |")
    w("|---|---|---|")
    for k in sorted(landed):
        w("| `%s` | %s | %s |" % (k, defs[k], " · ".join(graded[k])))
    w("")
    w("## UNGUARDED — wired, and NO criterion names it (%d)" % len(unguarded))
    w("")
    w("⚠ **Read this against the coverage line below, not on its own.** Most of these are unguarded")
    w("because the acceptance rows do not yet carry a `grades` line, not because nothing tests them.")
    w("The number falls as the citation convention spreads, and what is LEFT when it stops falling")
    w("is the real list.")
    w("")
    w("| function | defined in | called from |")
    w("|---|---|---|")
    for k in sorted(unguarded):
        cells = " · ".join(sorted(prod[k])) + ("  *(+smoke)*" if test[k] else "")
        w("| `%s` | %s | %s |" % (k, defs[k], cells))
    w("")
    w("---")
    w("")
    w("## COVERAGE — how much of the acceptance can be joined to code at all")
    w("")
    w("    acceptance rows found          %3d" % rows_total)
    w("    rows carrying a `grades` line  %3d   (%.0f%%)"
      % (rows_mapped, (100.0 * rows_mapped / rows_total) if rows_total else 0))
    w("    functions named by a criterion %3d" % len(graded))
    w("")
    w("★ A row with no `grades` line is UNMAPPED, not ungraded — the tool cannot tell which, and")
    w("says so rather than guessing. **This percentage is the honest ceiling on everything above.**")
    w("")
    w("_%d public functions across %d files._" % (len(defs), len(sources())))
    return "\n".join(out) + "\n"


def main():
    ap = argparse.ArgumentParser(description="which public functions are reachable")
    ap.add_argument("--out")
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()

    defs, prod, test = collect()
    if not check(defs, prod, test):
        sys.stderr.write("\n  ⚠ APPARATUS FAILED - refusing to emit a list that may be wrong.\n")
        return 1
    if a.check:
        n = sum(1 for k in defs if not prod[k] and not test[k])
        t = sum(1 for k in defs if not prod[k] and test[k])
        sys.stdout.write("apparatus OK - %d public functions, %d stranded, %d test-only\n"
                         % (len(defs), n, t))
        return 0

    text = emit(defs, prod, test)
    if a.out:
        io.open(a.out, "w", encoding="utf-8", newline="\n").write(text)
        sys.stdout.write("wrote %s\n" % a.out)
    else:
        sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
