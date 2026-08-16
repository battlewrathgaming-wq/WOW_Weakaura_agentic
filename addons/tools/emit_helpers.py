r"""emit_helpers.py - THE COMMAND REFERENCE: every in-game helper, read off the source.

★★★ WHY (Battlewrath, 2026-08-16): *"Helpers, in-game, so /dr, produce a list. Each
addon has them… I don't have them in memory. And I have no reference surface other than
blindly trying in-game for the right command."*

⚠ **THE PROBLEM IS NOT THAT THE COMMANDS ARE UNDOCUMENTED. It is that the documentation
is in the wrong place** - inside the client, reachable only by already being in the
client and already knowing what to type. A reference you can only read from inside the
thing it explains is not a reference.

★★ SO IT IS EXTRACTED, NEVER MAINTAINED. A hand-written command list is a second copy
that goes stale the first time a branch is renamed, and it goes stale SILENTLY - the
command still works, the list still reads plausibly, and only the person typing finds
out. This reads the dispatchers themselves, so it cannot disagree with the client.

★ WHAT IT REPORTS IS FACT, NOT INFERENCE. The token, whether the branch consumes an
argument, and the first CALL the branch makes. No descriptions are invented: `arm ->
Capture.Arm(rest)` says what it does in the code's own words, and says it takes
something, which is the half a person actually forgets.

    py addons/tools/emit_helpers.py            every addon
    py addons/tools/emit_helpers.py dr         one addon, by its slash or its folder
"""

import io
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__)).replace("\\", "/")
ROOT = os.path.dirname(os.path.dirname(HERE))
ADDONS = os.path.join(ROOT, "addons")

SLASH = re.compile(r'SLASH_([A-Z0-9_]+?)(\d+)\s*=\s*"(/[^"]+)"')
BIND = re.compile(r'SlashCmdList\["([A-Z0-9_]+)"\]\s*=\s*(function\s*\(|[A-Za-z_]\w*)')
CMP = re.compile(r'\b([A-Za-z_]\w*)\s*==\s*"([^"]*)"')
CALL = re.compile(r'\b([A-Z][\w.]*[.:]\w+|\w+)\s*\(')

# ⚠ Lines that are true of every branch and describe none of them. Skipping them is what
# makes the "first call" column mean something rather than print `match(` nine times.
NOISE = ("match", "format", "lower", "tonumber", "tostring", "ipairs", "pairs",
         "type", "print", "return", "if", "local")


def lua_files(d):
    out = []
    for n in sorted(os.listdir(d)):
        if n.endswith(".lua"):
            out.append(os.path.join(d, n))
    return out


def body_of(lines, start):
    """★ From a handler's first line to the end of its function, by counting `function`
    against `end`. ⚠ Crude on purpose: a Lua parser would be the right tool and the wrong
    amount of work, and the failure mode of over-reading is a longer list, not a wrong
    one."""
    depth, out = 0, []
    for i in range(start, len(lines)):
        l = lines[i]
        s = l.split("--")[0]
        # ⚠ EVERY BLOCK OPENER, not just `function`. Counting `end` against `function`
        # alone truncated the DungeonRun handler at its first `for ... do ... end`, so
        # `/dr ui` reported one sub-command where it has six.
        # ★ `elseif` is excluded deliberately: it carries `then` and opens nothing.
        depth += len(re.findall(r'\bfunction\b', s))
        depth += len(re.findall(r'(?<!else)\bif\b', s))
        depth += len(re.findall(r'\bfor\b', s))
        depth += len(re.findall(r'\bwhile\b', s))
        depth -= len(re.findall(r'\bend\b', s))
        out.append((i + 1, l))
        if depth <= 0 and i > start:
            break
    return out


def handler(lines, name):
    """The bound function, whether it is written inline or named elsewhere in the file."""
    for i, l in enumerate(lines):
        m = BIND.search(l)
        if not m or m.group(1) != name:
            continue
        if m.group(2).startswith("function"):
            return body_of(lines, i)
        fn = m.group(2)
        for j, l2 in enumerate(lines):
            if re.search(r'\bfunction\s+' + re.escape(fn) + r'\s*\(', l2):
                return body_of(lines, j)
    return []


def first_call(lines, k):
    """The first real call after a branch opens. ★ Its own words, not mine."""
    for _, l in lines[k + 1:k + 9]:
        s = l.split("--")[0].strip()
        # ⚠ A COMMENT IS NOT THE END OF A BRANCH. Breaking on an empty line meant the
        # branches with the most reasoning written above them — `pin`, `map`, `edit` —
        # reported nothing at all. The densest comment gave the emptiest row, which is
        # exactly backwards.
        if not s:
            continue
        if CMP.search(s):
            break
        for m in CALL.finditer(s):
            fn = m.group(1)
            if fn.split(".")[-1].split(":")[-1] not in NOISE:
                return s if len(s) <= 60 else fn + "(...)"
    return ""


def commands(body):
    """★ TOP LEVEL IS THE VARIABLE THE FIRST COMPARISON USES; anything compared against a
    DIFFERENT name inside is a sub-command. That is how `/dr ui list` comes out as a child
    of `ui` without anything here knowing the word `ui`."""
    rows, top = [], None
    for k, (n, l) in enumerate(body):
        s = l.split("--")[0]
        ms = CMP.findall(s)
        if not ms:
            continue
        var, tok = ms[0]
        if top is None:
            top = var
        toks = [t for v, t in ms if v == var]
        if not toks:
            toks = [t for v, t in ms]
        takes = any(a in s for a in ("rest", "arg"))
        rows.append({"sub": var != top, "toks": toks, "line": n,
                     "takes": takes, "call": first_call(body, k)})
    return rows


def report(only=None):
    found = 0
    for name in sorted(os.listdir(ADDONS)):
        d = os.path.join(ADDONS, name)
        if not os.path.isdir(d) or not name.startswith("COA_"):
            continue
        for path in lua_files(d):
            text = io.open(path, encoding="utf-8", errors="replace").read()
            lines = text.split("\n")
            slashes = {}
            for key, _, cmd in SLASH.findall(text):
                slashes.setdefault(key, []).append(cmd)
            if not slashes:
                continue
            for key, cmds in slashes.items():
                if only and only.lstrip("/") not in (
                        [c.lstrip("/") for c in cmds] + [name.lower(), name[4:].lower()]):
                    continue
                found += 1
                print("")
                print("   %-12s %s" % (" ".join(cmds), name))
                print("   " + "-" * 62)
                rows = commands(handler(lines, key))
                if not rows:
                    print("     (no sub-commands - the bare command is the whole of it)")
                for r in rows:
                    toks = " | ".join(t if t else "(bare)" for t in r["toks"])
                    lead = "       " if r["sub"] else "     "
                    arg = " <arg>" if r["takes"] else ""
                    print("%s%-22s %s" % (lead, toks + arg, r["call"]))
    if not found:
        print("")
        print("   Nothing matched." if only else "   No slash commands found.")
    print("")
    return 0


if __name__ == "__main__":
    sys.exit(report(sys.argv[1] if len(sys.argv) > 1 else None))
