r"""emit_store_inventory.py - WHAT IS STORED, AND WHETHER ANYTHING READS IT.

★★★ WHY THIS IS A MACHINE AND NOT A WRITTEN LIST. `store.lua`'s own header carries a
`Shape:` block describing the saved-variables table. It documents `runs`, `markers` and
`legs` - and does not mention `routes`, `routeNotes` or `notes`, all three of which the
same file creates. **A hand-written inventory of a live store is stale on the day after
it is written**, which is the whole argument for emitting this one.

    py addons/tools/emit_store_inventory.py            markdown to stdout
    py addons/tools/emit_store_inventory.py --out P    write it to P
    py addons/tools/emit_store_inventory.py --check    apparatus check only, exit 1 on fail

★★ IT PROVES ITS APPARATUS FIRST. A field list that comes back empty and a field list
that comes back complete look identical in a file, so `--check` asserts that a set of
fields KNOWN to exist (they are read out of the source by hand in the acceptance docs)
are actually found. If the extractor breaks, the emit refuses rather than shipping a
short list that reads like good news.

⚠⚠ WHAT IT CANNOT KNOW, stated so nobody reads more out of the table than is in it:
  - It is TEXTUAL. A field reached through a variable key (`t[k] = v`) is invisible to it.
  - "read" means the token appears as a field access somewhere that is not a write. It
    does NOT mean the value is CONSUMED - see the standing lesson that a stored field is
    not a live one. A field with reads can still be dead; a field with ZERO reads is the
    only claim here, and that one is solid.
  - It does not know which RECORD a field hangs off. It reports the RECEIVER NAMES seen
    at the write sites, which is a fact, instead of guessing a schema, which is not.
"""

import argparse
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "COA_DungeonRun")

# ★★★ WHY ONLY TWO FILES WRITE. DR-20 rules that `store.lua` is the ONLY module that
# touches `COA_DungeonRunDB`; `routes.lua` mutates the route tables it is handed out of
# that global. Everything else in the addon holds VIEWS - pane state, layout numbers,
# probe scratch - which is not "what is stored" and would bury the answer if counted.
# ⚠ So WRITES are read from these two; READS are counted across the whole addon,
# because the consumption question is about who looks at the stored value.
WRITE_FILES = ("store.lua", "routes.lua")

# Fields the extractor MUST find. Each is read straight out of the source in a doc that
# cites its line, so a miss means the extractor is broken, not that the field is gone.
APPARATUS = {
    "stage": "routes.lua AddBeacon - b.stage",
    "ordinal": "routes.lua SetChildOrdinal - child.ordinal",
    "mapX": "store.lua Point - the map fraction",
    "setStage": "routes.lua SetChildStage - the Set(N) target",
    "schemaVersion": "store.lua Load - the version stamp",
    "beacons": "routes.lua - the route's beacon list",
}

# Receivers that are plainly not records. Lua stdlib and our own module tables.
NOT_A_RECORD = set("""
table string math os io coroutine debug package
Store Routes NS Map Object UI Editor Promoter Capture Core Adaptor Layout Widget
Options Panespec Calibrate F C L
""".split())

# Field names that are module functions or stdlib calls rather than stored data.
NOT_A_FIELD = set("""
insert remove concat sort format find match gsub gmatch sub len rep upper lower byte char
floor ceil abs max min sqrt huge random time date clock getn setn unpack pcall
""".split())

ASSIGN = re.compile(r"\b([A-Za-z_]\w*)\.([A-Za-z_]\w*)\s*=(?!=)")
# `r.beacons[#r.beacons + 1] = b` is a write to `beacons`, and ASSIGN cannot see it
# because the field is followed by a subscript rather than by `=`.
INDEXED = re.compile(r"\b([A-Za-z_]\w*)\.([A-Za-z_]\w*)\s*\[[^\]]*\]\s*=(?!=)")
# ⚠ Leading whitespace matters: constructor pairs are INDENTED, never line-initial.
PAIR = re.compile(r"(?:^\s*|[{,]\s*)([A-Za-z_]\w*)\s*=(?!=)")
ACCESS = re.compile(r"\.([A-Za-z_]\w*)\b")
BRACKET = re.compile(r"\[\s*[\"']([A-Za-z_]\w*)[\"']\s*\]")
PYGET = re.compile(r"\.get\(\s*[\"']([A-Za-z_]\w*)[\"']")


def strip_comments(text):
    """Remove -- line comments. Crude but the source has no --[[ blocks in play."""
    out = []
    for line in text.split("\n"):
        i = line.find("--")
        # keep it simple: a -- inside a string is rare here and only costs us a
        # false candidate, never a missed one, because we drop unknown receivers.
        out.append(line if i < 0 else line[:i])
    return "\n".join(out)


def lua_files():
    """(label, path) for everything that may READ a stored field.

    ⚠⚠ THE SMOKES ARE IN HERE FOR A MEASURED REASON. The first emit of this tool
    scanned only `COA_DungeonRun/` and reported `bosses` and `names` as read by
    nobody - while `smoke_dungeonrun.lua` asserts on both (`:366-368`). **A debt list
    that cannot see the test suite marks tested fields as dead**, which is the one
    way this tool could do real damage.
    """
    out = [(f, os.path.join(SRC, f)) for f in os.listdir(SRC) if f.endswith(".lua")]
    smoke = os.path.join(os.path.dirname(os.path.abspath(__file__)), "smoke")
    if os.path.isdir(smoke):
        out += [("smoke/" + f, os.path.join(smoke, f))
                for f in os.listdir(smoke) if f.endswith(".lua")]
    # ⚠⚠ AND THE DESK SIDE READS THE SAVED FILE TOO. `walk.py` consumes `testPinSet`
    # straight off a landed run (`head.get("testPinSet")`), so a Lua-only scan calls a
    # field with a live Python consumer dead. The saved variables are a CONTRACT
    # between two languages and the inventory has to see both ends of it.
    for d in (os.path.dirname(os.path.abspath(__file__)),
              os.path.join(ROOT, "landing")):
        if os.path.isdir(d):
            out += [(os.path.basename(d) + "/" + f, os.path.join(d, f))
                    for f in os.listdir(d) if f.endswith(".py")]
    return sorted(out)


def collect():
    """-> writes {field: {file: [receivers]}}, reads {field: {file: count}}"""
    writes, reads = {}, {}
    for name, path in lua_files():
        raw = io.open(path, encoding="utf-8", errors="replace").read()
        text = strip_comments(raw)

        if name in WRITE_FILES:
            for rx in (ASSIGN, INDEXED):
                for recv, field in rx.findall(text):
                    if recv in NOT_A_RECORD or field in NOT_A_FIELD:
                        continue
                    writes.setdefault(field, {}).setdefault(name, set()).add(recv)

        # table-constructor pairs: only while inside braces, so `local x = 1` is out
        depth = 0
        for line in text.split("\n") if name in WRITE_FILES else []:
            # depth > 0 catches multi-line constructors; a `{` on THIS line catches
            # the single-line form, which the depth counter only sees afterwards.
            if depth > 0 or "{" in line:
                for field in PAIR.findall(line):
                    if field not in NOT_A_FIELD:
                        writes.setdefault(field, {}).setdefault(name, set()).add("{}")
            depth += line.count("{") - line.count("}")
            if depth < 0:
                depth = 0

        found = BRACKET.findall(text)
        # Lua reads a field with a dot; Python reads the same saved table with a
        # subscript or a .get(). Only those two precise forms count on the py side -
        # a bare quoted word in a message is not a read.
        found += (PYGET.findall(text) if name.endswith(".py") else ACCESS.findall(text))
        for field in found:
            if field in NOT_A_FIELD:
                continue
            reads.setdefault(field, {})
            reads[field][name] = reads[field].get(name, 0) + 1

    return writes, reads


def check(writes):
    bad = [f for f in APPARATUS if f not in writes]
    for f in sorted(bad):
        sys.stderr.write("  APPARATUS MISS  %-14s %s\n" % (f, APPARATUS[f]))
    return not bad


def emit(writes, reads):
    out = []
    w = out.append
    w("# STORE INVENTORY - emitted, do not hand-edit")
    w("")
    w("_Generated by `addons/tools/emit_store_inventory.py`. Re-run it rather than")
    w("correcting it. It reports what the SOURCE says, which is the only inventory that")
    w("cannot drift from the source._")
    w("")
    w("⚠ **What a row means.** `written in` is where a field is assigned; `receivers` are")
    w("the variable names it is assigned on, reported rather than resolved into a schema.")
    w("`read in` counts field accesses outside the write itself. ★ **A field with ZERO")
    w("reads is the solid claim here** - the reverse is not: a field WITH reads can still")
    w("be dead, because an access is not a consumption.")
    w("")

    rows = []
    for field, where in writes.items():
        wfiles = sorted(where)
        recvs = sorted(set(r for s in where.values() for r in s))
        rfiles = reads.get(field, {})
        # a write site also matches the read regex; discount the obvious self-hits
        total = sum(rfiles.values())
        elsewhere = sorted(f for f in rfiles if f not in wfiles)
        rows.append((field, wfiles, recvs, total, elsewhere))

    dead = [r for r in rows if not r[4]]
    live = [r for r in rows if r[4]]

    w("## FIELDS WRITTEN AND READ ONLY IN THEIR OWN FILE (%d)" % len(dead))
    w("")
    w("⚠ **This is the debt list.** A field nothing outside its writer ever looks at is")
    w("either private working state or a stored value with no consumer. The tool cannot")
    w("tell those apart - a person must.")
    w("")
    w("| field | written in | receivers |")
    w("|---|---|---|")
    for field, wfiles, recvs, _, _ in sorted(dead):
        w("| `%s` | %s | %s |" % (field, " · ".join(wfiles), " · ".join(recvs[:6])))
    w("")

    w("## FIELDS READ OUTSIDE THE FILE THAT WRITES THEM (%d)" % len(live))
    w("")
    w("| field | written in | receivers | read in |")
    w("|---|---|---|---|")
    for field, wfiles, recvs, _, elsewhere in sorted(live):
        w("| `%s` | %s | %s | %s |" % (field, " · ".join(wfiles),
                                       " · ".join(recvs[:6]), " · ".join(elsewhere)))
    w("")
    w("_%d fields total across %d source files._" % (len(rows), len(lua_files())))
    return "\n".join(out) + "\n"


def main():
    ap = argparse.ArgumentParser(description="what is stored, and whether anything reads it")
    ap.add_argument("--out")
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()

    writes, reads = collect()
    ok = check(writes)
    if not ok:
        sys.stderr.write("\n  ⚠ APPARATUS FAILED - refusing to emit a list that may be short.\n")
        return 1
    if a.check:
        sys.stdout.write("apparatus OK - %d known fields found, %d fields total\n"
                         % (len(APPARATUS), len(writes)))
        return 0

    text = emit(writes, reads)
    if a.out:
        io.open(a.out, "w", encoding="utf-8", newline="\n").write(text)
        sys.stdout.write("wrote %s (%d fields)\n" % (a.out, len(writes)))
    else:
        sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
