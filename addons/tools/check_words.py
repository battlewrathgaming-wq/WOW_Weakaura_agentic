# -*- coding: utf-8 -*-
r"""check_words.py - no pane TYPES a word the adaptor already owns.

    py addons/tools/check_words.py            the second copies
    py addons/tools/check_words.py --all      every display literal it inspected

★★★ WHY THIS EXISTS - a rule the code ASSERTED about itself and did not keep.

`object.lua:159` has said since RI-16: *"Every user word now comes from `NS.Adaptor.Word`."*
Measured 2026-08-27: **six sites typed their own** - the outcome dropdown's current text and
both its entries, four role entries, `radius`, and `supertrack`. The words happened to match,
so nothing looked wrong and nothing was.

⚠⚠ AND A MUTATION PROVED THERE WAS NO GUARD. Reverting one converted site to its literal ran
**SILENT** through the whole suite: the values agreed, so no assertion could tell a READ from
a COPY. ⟶ A copy that agrees today is the definition of drift-in-waiting, and this is the
check that can say NO.

★ Battlewrath, 2026-08-27, on why it is worth a tool: *"I'd still have it read the adaptor, so
we have built in single source correction. But they can be =="* - the VALUE may be identical;
the SOURCE must not be duplicated.

⚠ WHAT IT CANNOT SAY: whether a word is the RIGHT one. It proves a display string is not a
second copy of an adaptor entry - never that the entry says what an author needs.

★★★ EXACTLY ONE THING IS FATAL:

    [!] EXIT 1   a display literal that EXACTLY equals an adaptor word's value. Unambiguous:
                 the adaptor owns that string, and the pane spelled it out anyway.
    ~   TOLD     a display literal with NO adaptor entry. That is the pane naming something
                 the vocabulary has not ruled - `wire` is the standing case (*"OPEN in the
                 table - must name a SHAPE"*), and `nothing` is the absence of a value rather
                 than a value. Failing on those would make the gate permanently red, which is
                 the lesson `check_cites.py` paid for at §468.
"""

import io
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
ADDON = os.path.join(ROOT, "COA_DungeonRun")

# ★ THE DISPLAY SITES, not every string in the file. A pane says a word to a person in a
# small number of shapes, and widening this to "any literal" would report prose and keys.
SITES = [
    re.compile(r'\btext\s*=\s*"([^"]+)"'),
    re.compile(r'SetText\s*\(\s*[^,()]+,\s*"([^"]+)"'),
    re.compile(r'\bname\s*=\s*"([^"]+)"\s*,\s*$'),
]

# ⚠ THE PANES ONLY. `adaptor.lua` IS the source and must be skipped, or every entry reports
# itself; the smokes carry expected strings on purpose.
PANES = ("object.lua", "options.lua", "map.lua", "editor.lua", "promoter.lua",
         "widget.lua", "ui.lua", "drive.lua")


def adaptor_words():
    """code -> user, read off `adaptor.lua`'s own table."""
    raw = io.open(os.path.join(ADDON, "adaptor.lua"), encoding="utf-8",
                  errors="replace").read()
    out = {}
    for m in re.finditer(r'^\s{4}([A-Za-z_][A-Za-z0-9_]*)\s*=\s*"([^"]*)"\s*,',
                         raw, re.M):
        out[m.group(2)] = m.group(1)
    return out


def main():
    show_all = "--all" in sys.argv[1:]
    words = adaptor_words()
    if not words:
        sys.exit("check_words: read no entries from adaptor.lua - the table shape moved")

    copies, unruled, ok = [], [], []

    for name in sorted(PANES):
        path = os.path.join(ADDON, name)
        if not os.path.exists(path):
            continue
        for i, line in enumerate(io.open(path, encoding="utf-8",
                                         errors="replace").read().split("\n"), 1):
            # ⚠ COMMENTS ARE NOT DISPLAY. This file's own prose quotes words constantly.
            if line.lstrip().startswith("--"):
                continue
            for pat in SITES:
                for lit in pat.findall(line):
                    where = "%s:%d" % (name, i)
                    if lit in words:
                        copies.append((where, lit, words[lit]))
                    else:
                        unruled.append((where, lit))
                    ok.append(where)

    print("")
    print("   WORDS - does any pane type a string the adaptor already owns")
    print("   " + "-" * 62)

    for where, lit, key in copies:
        print("   [!] SECOND COPY  %-28s %s" % (where, '"%s"' % lit))
        print("                    the adaptor owns it as `%s` - ask for it" % key)
    if copies:
        print("       ★ `NS.Adaptor.Word(\"%s\")` returns exactly this string today. That is"
              % copies[0][2])
        print("         the point: a copy that AGREES is drift-in-waiting, not a match.")

    if unruled and (show_all or not copies):
        print("")
        print("   ~ %d display literal(s) with NO adaptor entry - the pane naming something"
              % len(unruled))
        print("     the vocabulary has not ruled. TOLD, never fatal:")
        for where, lit in unruled[:12]:
            print("       %-28s %s" % (where, '"%s"' % lit))

    print("")
    print("   inspected %d   second-copy %d   unruled %d"
          % (len(ok), len(copies), len(unruled)))
    print("")
    print("   ⚠ IT CANNOT SAY A WORD IS THE RIGHT ONE. It proves a display string is not a")
    print("     second copy of an adaptor entry - never that the entry says what an author")
    print("     needs. A5.1 PASSES A MISS THROUGH, so a missing entry is silent by design.")
    print("")
    return 1 if copies else 0


if __name__ == "__main__":
    sys.exit(main())
