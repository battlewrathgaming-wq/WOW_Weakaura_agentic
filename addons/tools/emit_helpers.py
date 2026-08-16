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

★★ A DOORWAY, NOT A DUMP. Bench key [H] opens the list of addons and you pick one -
because that is how it is used: you are looking for ONE command, not reading a
catalogue. The doorway is discovered, never listed, for the same reason the commands
are: hard-coding seven addons into the menu would drift the moment an eighth
registers one.

    py addons/tools/emit_helpers.py            the doorway - pick one, or A for all
    py addons/tools/emit_helpers.py dr         straight to one, by slash or folder
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


def discover():
    """Every registered slash surface, found rather than listed.

    ★ THE DOORWAY IS DATA-DRIVEN FOR THE SAME REASON THE COMMANDS ARE. Hard-coding the
    seven addons into the bench menu would drift the moment an eighth registers one — the
    exact staleness this tool exists to avoid, reintroduced one level up."""
    out = []
    for name in sorted(os.listdir(ADDONS)):
        d = os.path.join(ADDONS, name)
        if not os.path.isdir(d) or not name.startswith("COA_"):
            continue
        for path in lua_files(d):
            text = io.open(path, encoding="utf-8", errors="replace").read()
            slashes = {}
            for key, _, cmd in SLASH.findall(text):
                slashes.setdefault(key, []).append(cmd)
            for key, cmds in slashes.items():
                out.append({"addon": name, "key": key, "cmds": cmds,
                            "lines": text.split("\n")})
    return out


def show(e):
    print("")
    print("   %-18s %s" % (" ".join(e["cmds"]), e["addon"]))
    print("   " + "-" * 62)
    rows = commands(handler(e["lines"], e["key"]))
    if not rows:
        print("     (no sub-commands - the bare command is the whole of it)")
    for r in rows:
        toks = " | ".join(t if t else "(bare)" for t in r["toks"])
        lead = "       " if r["sub"] else "     "
        arg = " <arg>" if r["takes"] else ""
        print("%s%-22s %s" % (lead, toks + arg, r["call"]))


def matches(e, only):
    q = only.lstrip("/").lower()
    return q in ([c.lstrip("/").lower() for c in e["cmds"]]
                 + [e["addon"].lower(), e["addon"][4:].lower()])


def door(entries):
    """★★ ONE ADDON AT A TIME, because that is how you use it — you are looking for one
    command, not reading a catalogue. ⚠ KEYS ONLY, the same posture as the bench menu it
    hangs off: an unrecognised press re-prints rather than doing anything."""
    keys = "123456789"
    while True:
        print("")
        print("   HELPERS - in-game slash commands, read off the source")
        print("   " + "-" * 62)
        for i, e in enumerate(entries[:9]):
            print("     [%s]  %-18s %s" % (keys[i], " ".join(e["cmds"]), e["addon"]))
        print("")
        print("     [A]  all of them")
        print("     [Q]  back")
        print("")
        try:
            k = input("   Press a key: ").strip().lower()[:1]
        except (EOFError, KeyboardInterrupt):
            return 0
        if k == "q":
            return 0
        if k == "a":
            for e in entries:
                show(e)
            print("")
            continue
        if k in keys[:len(entries)]:
            show(entries[keys.index(k)])
            print("")


def report(only=None):
    entries = discover()
    if not entries:
        print("")
        print("   No slash commands found.")
        print("")
        return 0
    if only is None:
        return door(entries)
    hit = [e for e in entries if matches(e, only)]
    for e in hit:
        show(e)
    if not hit:
        print("")
        print("   Nothing matched.")
    print("")
    return 0


if __name__ == "__main__":
    sys.exit(report(sys.argv[1] if len(sys.argv) > 1 else None))
