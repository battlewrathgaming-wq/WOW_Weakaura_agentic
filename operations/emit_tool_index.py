# -*- coding: utf-8 -*-
r"""emit_tool_index.py - every tool on every bench, read off its own docstring.

    py operations/emit_tool_index.py                 every desk
    py operations/emit_tool_index.py addons/tools    one desk
    py operations/emit_tool_index.py --find cite     only tools whose line matches
    py operations/emit_tool_index.py --gaps          only the ones that cannot describe themselves

★★★ WHY, AND WHY IT PRINTS RATHER THAN WRITES. 2026-08-22: I built a tool onto a path that already
held one - a 342-mutation Lua harness, overwritten by a Python one - because I never asked what was
there. The desk had grown to 57 tools in `addons/tools` alone and ~150 across the repo, with **no
index anywhere**.

⚠⚠ THE OBVIOUS FIX IS THE WRONG ONE. A hand-written `TOOLS.md` is a second copy of a fact the
tools already state, and this repo's own log warns about exactly that shape: *"a home POINTS; an
index that restates is the second copy that drifts."* ⟶ So there is **no file to maintain**. This
reads the docstrings and prints; the answer cannot be stale because it is never stored.

★ IT COST NOTHING TO SOURCE, because the convention was already universal without anyone enforcing
it: measured at 57 of 57 tools in `addons/tools` carrying a module docstring, 49 of them with an
invocation line, all in the same house form `name.py - what it does`. **The registry existed as
data for months; it was only never assembled.**

⚠ WHAT IT CANNOT DO, and the honest ceiling. It reports what a tool SAYS about itself, never what
it does - a stale first line indexes staleness ([[a-name-is-not-a-use]], one level up). `--gaps`
prints the tools that describe nothing, which is the same honest-ceiling move `check_acceptance`
makes with its unstated count: **the number that measures the instrument's blindness stays on
screen.**

⚠ AND IT DOES NOT REPLACE THE GUARD. Discovery is PULLED - it works only when someone chooses to
look. The hook `.claude/hooks/no-write-over.js` is the PUSHED half, and it is the one that would
have caught the fault above. Neither substitutes for the other.
"""

import ast
import io
import os
import sys

sys.stdout.reconfigure(encoding="utf-8")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# ⚠ DESKS ARE DISCOVERED, NOT LISTED. A hard-coded list is one more thing to keep in step with a
# repo that grows a bench every few weeks - and it would go stale the same way the missing index
# did. A directory holding this many tools IS a desk.
MIN_TOOLS = 3
SKIP = {".git", "__pycache__", ".tools", "node_modules", ".claude", "Outputs", "archive",
        "history", "staging", "backlog"}


def desks():
    out = {}
    for base, dirs, files in os.walk(ROOT):
        dirs[:] = sorted(d for d in dirs if d not in SKIP and not d.startswith("."))
        py = sorted(f for f in files if f.endswith(".py"))
        if len(py) >= MIN_TOOLS:
            out[os.path.relpath(base, ROOT).replace("\\", "/")] = py
    return out


def describe(path):
    """(first line, invocation) as the tool states them - never inferred."""
    try:
        src = io.open(path, encoding="utf-8", errors="replace").read()
        doc = ast.get_docstring(ast.parse(src))
    except (SyntaxError, ValueError):
        return None, None
    if not doc:
        return None, None
    lines = [l.rstrip() for l in doc.strip().split("\n")]
    first = lines[0]
    # ★ The house form is `name.py - what it does`. Drop the restated name; keep the sentence.
    for sep in (" - ", " — "):
        if sep in first:
            head, rest = first.split(sep, 1)
            if head.strip().endswith(".py"):
                first = rest.strip()
                break
    call = next((l.strip() for l in lines[1:8] if l.strip().startswith("py ")), None)
    return first, call


def main():
    argv = [a for a in sys.argv[1:] if not a.startswith("--")]
    find = None
    if "--find" in sys.argv:
        i = sys.argv.index("--find")
        find = sys.argv[i + 1].lower() if i + 1 < len(sys.argv) else None
        argv = [a for a in argv if a != sys.argv[i + 1]]
    gaps_only = "--gaps" in sys.argv

    found = desks()
    only = argv[0].replace("\\", "/").rstrip("/") if argv else None
    if only and only not in found:
        print("\n   no desk at %s. Known desks:\n     %s\n"
              % (only, "\n     ".join(sorted(found))))
        return 2

    print("")
    print("   THE TOOL DESKS - what each tool says about itself, read at run time")
    print("   " + "-" * 74)

    shown, mute, total = 0, [], 0
    for desk in sorted(found):
        if only and desk != only:
            continue
        rows = []
        for f in found[desk]:
            total += 1
            first, call = describe(os.path.join(ROOT, desk, f))
            if not first:
                mute.append("%s/%s" % (desk, f))
                continue
            if find and find not in (first + " " + f).lower():
                continue
            rows.append((f, first, call))
        if gaps_only or not rows:
            continue
        print("")
        print("   %s  (%d)" % (desk, len(found[desk])))
        for f, first, call in rows:
            shown += 1
            print("     %-30s %s" % (f, first[:78]))
            if call and call.replace("\\", "/") != "py %s/%s" % (desk, f):
                print("     %-30s   %s" % ("", call[:76]))

    print("")
    if mute and (gaps_only or not find):
        print("   ⚠ %d tool%s describe%s nothing - a docstring is how a tool enters this index:"
              % (len(mute), "" if len(mute) == 1 else "s", "s" if len(mute) == 1 else ""))
        for m in mute:
            print("       %s" % m)
        print("")
    print("   %d tool%s across %d desk%s%s%s"
          % (total, "" if total == 1 else "s", len(found), "" if len(found) == 1 else "s",
             ", %d shown" % shown if find or only else "",
             ", %d mute" % len(mute) if mute else ""))
    print("   ⚠ THIS REPORTS WHAT A TOOL SAYS, NEVER WHAT IT DOES. A stale first line indexes")
    print("     staleness. ⟶ And discovery is PULLED: the guard that fires whether or not anyone")
    print("     looked is `.claude/hooks/no-write-over.js`.")
    print("")
    return 0


if __name__ == "__main__":
    sys.exit(main())
