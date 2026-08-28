# -*- coding: utf-8 -*-
r"""mutate_checkers.py - break each guard on the CHECKER desk and watch it BITE.

    py addons/tools/mutate_checkers.py                  every declared mutation
    py addons/tools/mutate_checkers.py --tool X         one tool
    py addons/tools/mutate_checkers.py --diff           show what changed when a mutation bit

★★★ WHY THIS EXISTS. [[mutation-tests-find-weak-tests]] - the yield is BAD TESTS, not bad code, and
this bench has now put SIX guards into service that printed green while checking nothing:

    §457 · §458 · §465 · §472 · §511   five went inert after the thing they watched moved
    §525                               one was proposed DELIBERATELY, and measurement stopped it

⟶ A checker is code like any other, and nobody was checking the checkers. The question this answers
is the only one that matters about a guard: **if I break it, does anything notice?**

★★ ITS SISTER, AND THE REASON THIS FILE IS NOT CALLED `mutate.py`. **`mutate.py` does exactly this
for the LUA SMOKES** and predates it by many sessions - six bad tests and one live bug, plus the
ruling this file inherits: **a mutation anchor is CODE, never PROSE**, because two anchors written
against comment text died the day that file was documented and went on *looking* like coverage.

    mutate.py            the LUA SMOKES        `py addons/tools/mutate.py dungeonrun`
    mutate_checkers.py   the PYTHON CHECKERS   this file

⚠⚠ HOW THAT WAS LEARNED, 2026-08-22: **I wrote this file straight over `mutate.py` without ever
reading the path.** A mutation harness overwritten by a mutation harness, while this header claimed
nobody was checking the checkers - when the real gap was only that the SMOKE harness did not reach
the Python tools. Restored from `HEAD~1` and renamed. ★ The lesson is not "be careful": it is that
**a new tool's NAME is a claim about what already exists**, and the claim is checkable in one
command before writing a line.

★ THE SIGNATURE IS THE WHOLE OUTPUT. A mutation BIT if stdout or the exit code changed at all; it
was SILENT if the tool printed byte-identical text with a broken guard. ⟶ No per-tool comparator to
write, and therefore no per-tool comparator to get wrong - the only per-tool part is DATA, below.

⚠⚠ A MISSING ANCHOR IS A FAILURE, NEVER A SKIP. When a tool is edited its mutations rot, and a
harness that quietly skips a rotted mutation is the exact inert-guard shape it exists to catch. It
reports and exits non-zero. ★ The one rule this file must never break is its own.

⚠⚠⚠ IT EDITS REAL TOOLS ON DISK. Every write is inside `try/finally`, the original bytes are held
in memory, and the restore is VERIFIED byte-for-byte before it reports. If a restore ever fails it
says so first and loudest, because a mutated checker left on disk is worse than no checker.

⚠ WHAT A `SILENT` RESULT MEANS - and it is not always a defect. A guard can be UNREACHED rather
than wrong: `check_acceptance`'s CITE boundaries are kept although nothing in this corpus reaches
them, because the substring-for-word fault they guard already cost that file a false finding.
⟶ SILENT is a fact to RECORD in the tool, never a number to make go away.
"""

import io
import os
import re
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))


# ⚠⚠ IT COULD ONLY REACH ITS OWN DIRECTORY, and that was found the first time it was pointed at
# a checker outside `addons/tools` (`operations/boot.py`, 2026-08-23). A harness described as
# "the CHECKER desk" that can only see ONE desk is the scope fault this file's own header warns
# about, one layer in. ⟶ A tool name carrying a `/` is REPO-relative; a bare name stays
# desk-relative, so every existing declaration keeps working.
def toolpath(tool):
    return os.path.join(REPO, tool) if "/" in tool else os.path.join(HERE, tool)

# =====================================================================================
# THE DECLARATION - the only per-tool part. (tool, label, find, replace)
#
# ★ WRITE THE MUTATION A REAL AUTHOR WOULD MAKE: drop a boundary, widen a scope, delete a
#   clause of a condition. A mutation nobody would ever type proves nothing about the guard.
# ⚠ ONE GUARD PER ENTRY. Breaking two at once cannot tell you which one bit.
# =====================================================================================
MUTATIONS = (
 ("check_acceptance.py", "ROW loses the -R tail (the hyphen truncation)",
  'ROW = re.compile(r"^- \\*\\*(A[0-9][0-9.a-z]*(?:-[A-Z])?)")',
  'ROW = re.compile(r"^- \\*\\*(A[0-9][0-9.a-z]*)")'),

 ("check_acceptance.py", "CITE loses the -R tail (citations mis-attributed)",
  r'CITE = re.compile(r"\bA[0-9]+\.[0-9]+[a-z]?(?:-[A-Z])?\b")',
  r'CITE = re.compile(r"\bA[0-9]+\.[0-9]+[a-z]?\b")'),

 ("check_acceptance.py", "CITE_DIRS drops the smokes (scope narrowed)",
  'CITE_DIRS = (SOURCE, os.path.join(ROOT, "tools", "smoke"))',
  'CITE_DIRS = (SOURCE,)'),

 ("check_acceptance.py", "the queue stops excluding STATED rows",
  "if status_of(head) or not GRADES.search(body) or rid not in cites:",
  "if not GRADES.search(body) or rid not in cites:"),

 ("check_acceptance.py", "the queue stops requiring a `grades` line",
  "if status_of(head) or not GRADES.search(body) or rid not in cites:",
  "if status_of(head) or rid not in cites:"),

 # ⚠ KNOWN SILENT, KEPT ON PURPOSE - see the header. `[0-9]+` is greedy and `[a-z]?` optional, so
 # `A12.1` cannot match inside `A12.10b` with or without the boundaries. The guard is UNREACHED by
 # this corpus, not wrong, and the fault it guards already cost that file a false finding.
 ("check_acceptance.py", "CITE loses its word boundaries  [known SILENT, recorded]",
  r'CITE = re.compile(r"\bA[0-9]+\.[0-9]+[a-z]?(?:-[A-Z])?\b")',
  r'CITE = re.compile(r"A[0-9]+\.[0-9]+[a-z]?(?:-[A-Z])?")'),

 # ★ A SECOND TOOL, so that "reusable" is DEMONSTRATED rather than claimed. The mechanism above
 #   knows nothing about either file.
 ("check_inbox.py", "the drain stamp stops requiring the word DRAINED",
  r'STAMP = re.compile(r"RI-\d+ DRAINED")',
  r'STAMP = re.compile(r"RI-\d+")'),

 ("check_retired.py", "the headstone WINDOW widens from 3 lines to 60",
  "WINDOW = 3",
  "WINDOW = 60"),

 # ★★ THE SEAT/BENCH MAP (2026-08-23). Before it, boot printed "LOCKED OUT - repo-read-only"
 #    to the analyst and architect seats on every run. These break it in both directions: the
 #    map going empty must re-lock a bench-mate, and the lockout must still fire for a genuinely
 #    other bench - a fix that unlocks EVERYONE is the worse bug.
 # ⚠ THE ANCHOR HERE ROTTED ONCE, THE SAME DAY IT WAS WRITTEN (2026-08-23): it carried the
 #   trailing comment `# Opus 5 Analyst`, and realigning the block for two new rows moved the
 #   whitespace. ★ The harness FAILED rather than skipping, which is its one promise about
 #   itself - and the fix is the ruling `mutate.py` already carries: **an anchor names the LINE
 #   THAT DOES THE WORK.** The bare mapping is code; the comment beside it is decoration.
 ("operations/boot.py", "SEATS forgets that analyst is an addons seat",
  '"analyst": "addons",',
  '"analyst": "analyst",'),

 ("operations/boot.py", "bench_of stops resolving seats (map ignored)",
  "    return SEATS.get(k, k)",
  "    return k"),

 ("operations/boot.py", "same_seat collapses into mine (bench-mate reads as YOURS)",
  "        if same_seat(holder, args.lane):",
  "        if True:"),

 # =====================================================================================
 # ★★★ THE OTHER TEN CHECKERS (2026-08-26). Battlewrath: *"Do the check to see if they can red."*
 #
 # ⚠⚠ WHY THIS WAS OWED. The push receipt prints a `can-go-red` column derived from THIS table, and
 #   it read **3 of 13**. Ten checkers were being run at every push, exiting 0, and logged as
 #   greens **with no bulb proven behind them** - which reads as coverage and is not. Seven inert
 #   guards were measured on this bench in one week; a receipt full of unproven OKs would have been
 #   the eighth failure of the same shape.
 # ⟶ One mutation per tool, each an edit a REAL AUTHOR would type: a dropped boundary, a widened
 #   window, a clause deleted from a condition, a unicode character typed as its ASCII lookalike.
 # =====================================================================================

 # ⚠ ANCHOR RE-AIMED 2026-08-27, not deleted. The harness reported `matched 0 times - the tool moved
 #   and the mutation did not`, which is its one promise about itself. `check_cites` widened CITE to
 #   accept file stems carrying digits, dots and hyphens and broke the pattern across two lines.
 #   ★ The GUARD is unchanged - the line-range tail is still what this breaks.
 ("check_cites.py", "CITE loses the line-RANGE tail (file.lua:10-14 mis-parsed)",
  r'([A-Za-z0-9_][A-Za-z0-9_.\-]*\.lua):(\d+)(?:\s*-\s*(\d+))?")',
  r'([A-Za-z0-9_][A-Za-z0-9_.\-]*\.lua):(\d+)")'),

 ("check_escapes.py", "VALID forgets that numeric escapes are legal (\\065)",
  'VALID = set("abfnrtv\\\\\\"\'\\n") | set("0123456789")',
  'VALID = set("abfnrtv\\\\\\"\'\\n")'),

 ("check_grades.py", "SYMBOL loses its anchors (a symbol matches INSIDE a longer string)",
  'SYMBOL = re.compile(r"^[A-Z][A-Za-z]*\\.[A-Za-z]+$")',
  'SYMBOL = re.compile(r"[A-Z][A-Za-z]*\\.[A-Za-z]+")'),

 # ⚠ SILENT, DIAGNOSED 2026-08-26: the probe carries 20 `name =` lines and EVERY ONE is already in
 #   whole-line form, so the widened pattern matches the identical set. The guard is REACHED and
 #   simply has no nested `name=` to discriminate against in this corpus. Kept: the day someone
 #   nests one, this entry is the thing that was already watching.
 ("check_harness.py", "PROBE_NAME stops requiring a whole line  [known SILENT, recorded]",
  'PROBE_NAME = re.compile(r\'^\\s*name\\s*=\\s*"([^"]+)"\\s*,\\s*$\', re.M)',
  'PROBE_NAME = re.compile(r\'name\\s*=\\s*"([^"]+)"\', re.M)'),

 ("check_harness.py", "MARKER stops requiring a Lua comment (prose BEHAVIOUR: counts)",
  "MARKER = re.compile(r'^\\s*--\\s*BEHAVIOUR:\\s*(.+?)\\s*$', re.M)",
  "MARKER = re.compile(r'^\\s*BEHAVIOUR:\\s*(.+?)\\s*$', re.M)"),

 # ★ THE UNICODE ONE IS NOT HYPOTHETICAL ON THIS BENCH - a multiplication sign typed as an ASCII
 #   `x` is the exact class of fault [[author-in-a-file-not-in-the-shell]] was written for.
 # ★★ THIS ONE WAS SILENT AND IS NOW LIVE - the whole arc, kept because it is the case that shows
 #   what a parked mutation is FOR. It read silent because `check_interface` reported size
 #   MISMATCHES only, so zero parsed sizes yielded zero mismatches: **it could not tell "no sizes
 #   declared" from "all sizes agree."** Filed RI-83 rather than fixed here, since changing what a
 #   checker reports is the bench's call.
 # ⟶ The Addon creator ruled the shape (2026-08-27): **report the DENOMINATOR, not a floor** - a
 #   floor needs a number nobody measured and goes stale; a denominator is derived at run time and
 #   cannot. `check_interface` now prints `sizes: N declared size(s) parsed and compared`, a line a
 #   run that read nothing cannot print. **The mutation bit the moment that line existed.**
 ("check_interface.py", "SIZE reads an ASCII x instead of × (the size denominator goes to zero)",
  'SIZE = re.compile(r"(\\d+)\\s*×\\s*(\\d+)")',
  'SIZE = re.compile(r"(\\d+)\\s*x\\s*(\\d+)")'),

 ("check_interface.py", "HEADER stops requiring the surface's kind field",
  'HEADER = re.compile(r"_`([\\w.]+)(?::\\d+)?`\\s*·\\s*`(\\w+)`\\s*·\\s*\\*\\*(.+?)\\*\\*")',
  'HEADER = re.compile(r"_`([\\w.]+)(?::\\d+)?`\\s*·\\s*`(\\w+)`")'),

 ("check_landing.py", "the sweep check drops its `testing` stage clause",
  '        if not pull.swept(src) and src.get("stage") != "testing":',
  '        if not pull.swept(src):'),

 # ⚠ SILENT, DIAGNOSED: `overlaps()` IS reached - 7 boards over 3 pages - but no two boards on this
 #   sheet share an exact edge, so inclusive and exclusive agree. An unreached FAULT, not an
 #   unreached guard. ⟶ The containment boundary below is the reachable half.
 ("check_layout.py", "overlap goes inclusive (touching edges overlap)  [known SILENT, recorded]",
  '            if (a["left"] < b["right"] and b["left"] < a["right"]',
  '            if (a["left"] <= b["right"] and b["left"] < a["right"]'),

 ("check_layout.py", "containment goes inclusive (a board flush to the frame reads as overhang)",
  '        if r["left"] < box["left"]:',
  '        if r["left"] <= box["left"]:'),

 # ★ THE SAME SHAPE AS check_retired's PROVEN ONE - a window widened until it stops discriminating.
 # ⚠ SILENT, DIAGNOSED: the screenshots exist, but every record's stem matches EXACTLY (the `d==0`
 #   path), so the ±window is never consulted. Widening it changes nothing until a request and its
 #   file land in different seconds - which is precisely the case it was written for.
 ("check_sheet.py", "SHOT_WINDOW widens from 1 to 60  [known SILENT, recorded]",
  "SHOT_WINDOW = 1",
  "SHOT_WINDOW = 60"),

 # ⚠ SILENT, DIAGNOSED: LOOSENING a tolerance that everything already passes cannot change an
 #   outcome. The reachable direction is the other one - a tolerance TIGHTENED past the float noise
 #   in the measurement, which is the edit an author makes when a residual looks too good.
 ("check_sheet.py", "the q residual loosens 1e-6 -> 1e-2  [known SILENT, recorded]",
  "        if max(abs(v[2] - round(v[2] / q) * q) / v[2] for v in nonzero) < 1e-6:",
  "        if max(abs(v[2] - round(v[2] / q) * q) / v[2] for v in nonzero) < 1e-2:"),

 ("check_sheet.py", "the q residual TIGHTENS to 1e-12 (past the measurement's own noise)",
  "        if max(abs(v[2] - round(v[2] / q) * q) / v[2] for v in nonzero) < 1e-6:",
  "        if max(abs(v[2] - round(v[2] / q) * q) / v[2] for v in nonzero) < 1e-12:"),

 # ⚠ SILENT, DIAGNOSED: there are ZERO `SUPERSEDED__` files in planning/ today, so that half of the
 #   tuple is genuinely unreached. `ARCHIVE__` has one, and is the reachable half.
 ("check_targets.py", "RECORD_PREFIXES forgets SUPERSEDED__  [known SILENT, recorded]",
  'RECORD_PREFIXES = ("ARCHIVE__", "SUPERSEDED__")',
  'RECORD_PREFIXES = ("ARCHIVE__",)'),

 # ⚠ SILENT TOO, AND THE DIAGNOSIS IS THE SAME ONE LEVEL IN: the prefix only bites when a source
 #   file CITES a record, and today **no `.lua` cites an ARCHIVE__ or SUPERSEDED__ doc at all.**
 #   The whole record-prefix guard is unreached by this corpus - correctly, since it exists to
 #   catch a fault nobody has committed yet. ⟶ HEAD is the reachable guard on this tool.
 ("check_targets.py", "RECORD_PREFIXES forgets ARCHIVE__  [known SILENT, recorded]",
  'RECORD_PREFIXES = ("ARCHIVE__", "SUPERSEDED__")',
  'RECORD_PREFIXES = ("SUPERSEDED__",)'),

 # ⚠⚠ RE-AIMED 2026-08-28, and the harness caught the drift the same hour I caused it. RI-84 moved
 #   the window from a constant to a DERIVED one (`head_lines`: the file's leading comment block,
 #   floored at HEAD), so `HEAD = 12` stopped being the line that does the work.
 # ★ AND IT MATCHED TWICE, because the comment I wrote explaining the change QUOTED the constant.
 #   `mutate.py`'s ruling one level in: **an anchor is CODE, never prose** — and prose that looks
 #   like the code is the same fault wearing a different hat. The comment was reworded.
 # ⚠ SILENT, DIAGNOSED 2026-08-28: every scanned file's leading comment block is ALREADY ≥ 12 lines,
 #   so the floor never binds on this corpus. It is a guard against a fault nobody has committed —
 #   a source file with a short header — and it is kept for the day someone writes one. The
 #   REGRESSION mutation below is the reachable half and it bites.
 ("check_targets.py", "the header window loses its FLOOR  [known SILENT, recorded]",
  "    return lines[:max(n, HEAD)]",
  "    return lines[:n]"),

 # ★ THE REACHABLE ONE, AND IT IS THIS DESK'S OWN HISTORY. `rename_laws.py` shipped a pattern that
 #   required TWO spaces where one file had one, and nine of ten renames read as complete. A legacy
 #   alternative dropped in a cleanup is the same fault: **2 files still say `-- Spec:`.**
 # ⚠⚠ SILENT, AND THE DIAGNOSIS IS THE FINDING. Two files carry the legacy form; one is out of
 #   `sources()` scope entirely and the other - `COA_Landmarks/core.lua` - declares it at **line
 #   18, past HEAD=12**, so this tool has never read it. ⟶ The `Spec` branch is dead in practice,
 #   and core.lua reads "unenforced" while plainly declaring a target. Harmless only because
 #   Landmarks is not in ENFORCED; a FALSE "NO TARGET DECLARED" the day it is. Filed RI-84.
 # ★ MY OWN SCOPE FAULT, RECORDED: I measured `-- Spec:` across all of addons/ and concluded it was
 #   reached. `sources()` walks TOP-LEVEL `COA_*` only. [[the-scope-protected-the-claim]], again.
 ("check_targets.py", "CITE drops the legacy Spec: form  [known SILENT, recorded]",
  'CITE = re.compile(r"^--\\s*(?:Model|Spec):\\s*([^\\s,;]+\\.md)")',
  'CITE = re.compile(r"^--\\s*Model:\\s*([^\\s,;]+\\.md)")'),

 # ★ THE WINDOW NARROWED BACK TO THE OLD CONSTANT — the regression RI-84 fixed. `core.lua`'s
 #   line-18 declaration must go back to invisible if the derived window is lost.
 ("check_targets.py", "the window reverts to the flat 12 lines (RI-84's regression)",
  "    return lines[:max(n, HEAD)]",
  "    return lines[:HEAD]"),

 # ⚠ SILENT, DIAGNOSED: the driver names ZERO `Unit*.Something` symbols, so that entry guards
 #   nothing in this corpus. `C_` names two and is the reachable half.
 ("emit_divergence.py", "NOT_OURS forgets Unit*  [known SILENT, recorded]",
  'NOT_OURS = ("C_", "Blizzard", "Lib", "Ace", "WeakAuras", "GameTooltip", "Unit",',
  'NOT_OURS = ("C_", "Blizzard", "Lib", "Ace", "WeakAuras", "GameTooltip",'),

 # ⚠ SILENT, DIAGNOSED: the two `C_*.x` symbols in the driver are named in CODE, and this tool
 #   reports what the DOCS name against what the code defines - so a code-only symbol never reaches
 #   the bucket the prefix would move it out of. ⟶ NAMED is the reachable guard.
 ("emit_divergence.py", "NOT_OURS forgets the C_ namespace  [known SILENT, recorded]",
  'NOT_OURS = ("C_", "Blizzard", "Lib", "Ace", "WeakAuras", "GameTooltip", "Unit",',
  'NOT_OURS = ("Blizzard", "Lib", "Ace", "WeakAuras", "GameTooltip", "Unit",'),

 # ★★ THE DESK GREW, AND THE RECEIPT SAID SO BEFORE ANYONE UPDATED A LIST (2026-08-27). `[7]`'s own
 #   staleness was measured against a hand-kept list; this column is derived, so `check_anchors` and
 #   `check_words` landing at §719 flipped it from **13 of 13 to 13 of 15** on the next run, with no
 #   edit anywhere. ⟶ The two rows below are what closes it - and §719's own "open instruments" list
 #   had already named them: *"two checkers with no rows in mutate_checkers.py."*
 # ⚠ BOTH OF THESE ARE SECOND ATTEMPTS, and the first pair is worth recording rather than hiding:
 #   `n != 1 -> n < 1` on the anchor count and dropping the `SetText` site both ran SILENT, because
 #   no anchor resolves twice today and none of the ten inspected words comes from a `SetText` site.
 #   ⟶ Unreached SITES, not weak guards. ★ And neither tool has RI-83's defect - both already print
 #   a denominator (`resolved 442 …`, `inspected 10 …`), which is the Addon creator's ruling landing
 #   in new tools before it was written down anywhere.
 ("check_anchors.py", "the [PENDING] exemption goes away (a parked row reads as an orphan)",
  '            if what.startswith("[PENDING"):',
  '            if False:'),

 # ★★ THE 16th CHECKER, AND THE RECEIPT CAUGHT IT UNPROVEN (2026-08-28). `check_freshness` landed at
 #   §723 to find stale docs and nothing had ever watched IT fail - the derived `can-go-red` column
 #   went 15 of 16 on the next run with no edit anywhere. ⚠ The instrument built to say "unmeasured,
 #   never clean" was itself unmeasured.
 # ★ The guard broken here is the one the Analyst's RI-82 close argued for: `bench` is the ONLY
 #   tier that excludes, and it excludes BEFORE topic is consulted - which is what stops the
 #   derived topic smearing across every commit, since the bench docs are the corpus's noisiest.
 ("check_freshness.py", "the queue stops excluding bench docs (the noisiest corpus floods it)",
  '        if tier == "bench":\n            continue',
  '        if False:\n            continue'),

 # ★★ THE TIER DEFAULT POINTS **INTO** THE CHECK (RI-86 □1, built §757). The rule's whole
 #   argument is directional: an over-tiered doc costs one extra read, while an under-tiered
 #   one is silently exempt from the queue forever. `bench` is the ONLY tier that excludes, so
 #   defaulting there is precisely the fault - and it is invisible in a green run, because a
 #   corpus that quietly stops being checked reports the same clean line as one that passes.
 ("check_freshness.py", "the tier default EXEMPTS instead of enrolling (docs vanish from the queue)",
  '            tier = "reference"',
  '            tier = "bench"'),

 # ★ AND THE INTENT SUFFIXES ARE READ, not a hand list. ⚠ `_asklist` is deliberately NOT here -
 #   an asklist records open questions and code landing can ANSWER one, so it must stay
 #   queue-able. The rule caught that about itself on its first run.
 ("check_freshness.py", "a `_scope` doc stops being recognised (the tier stops being derived)",
  '        elif name[:-3].endswith("_scope") or name[:-3].endswith("_plan"):',
  '        elif False:'),

 ("check_words.py", "PANES forgets promoter.lua (a hand-kept list drops a pane)",
  '''PANES = ("object.lua", "options.lua", "map.lua", "editor.lua", "promoter.lua",''',
  '''PANES = ("object.lua", "options.lua", "map.lua", "editor.lua",'''),

 ("emit_divergence.py", "NAMED accepts a lowercase member (Foo.bar reads as a symbol)",
  'NAMED = re.compile(r"\\b([A-Z][A-Za-z0-9]*)\\.([A-Z][A-Za-z0-9_]*)\\b")',
  'NAMED = re.compile(r"\\b([A-Z][A-Za-z0-9]*)\\.([A-Za-z][A-Za-z0-9_]*)\\b")'),
)

KNOWN_SILENT = ("[known SILENT",)

# ⚠⚠ RUN EACH TOOL AT ITS LOUDEST. Found by this harness ON ITS OWN FIRST RUN: the `-R` mutation
# read SILENT, because `check_acceptance`'s DEFAULT output prints only the queue's COUNT, and
# collapsing two rows onto one id does not change a count. The rows themselves are behind `--queue`.
# ⟶ A signature taken from the default output is a SCOPE THAT EXCLUDES THE EVIDENCE, which is the
# fault this desk keeps finding ([[the-scope-protected-the-claim]]) - here inside the instrument
# built to find it. ★ So a tool that hides detail behind a flag must be DECLARED with that flag.
LOUDEST = {
    "check_acceptance.py": ["--all", "--queue"],
    # ★ boot.py answers a QUESTION PER SEAT, so the seat is part of making it speak. `analyst`
    #   is the one the seat/bench map was added for.
    "operations/boot.py": ["--lane", "analyst"],
}


def run(tool):
    r = subprocess.run([sys.executable, toolpath(tool)] + LOUDEST.get(tool, []),
                       capture_output=True, text=True, encoding="utf-8", errors="replace",
                       cwd=REPO)
    return r.stdout, r.returncode


def main():
    argv = sys.argv[1:]
    only = argv[argv.index("--tool") + 1] if "--tool" in argv else None
    show_diff = "--diff" in argv

    todo = [m for m in MUTATIONS if not only or only in m[0]]
    tools = sorted(set(m[0] for m in todo))

    print("")
    print("   MUTATION - break each guard, and see whether anything NOTICES")
    print("   " + "-" * 68)

    base, good = {}, {}
    for t in tools:
        path = toolpath(t)
        if not os.path.isfile(path):
            print("   [!] no such tool: %s" % t)
            return 2
        # ⚠⚠ `newline=""` ON EVERY READ AND WRITE IN THIS FILE, and it is not a style choice.
        # Without it Python translates on the way in and `newline="\n"` writes LF on the way out,
        # so a CRLF tool comes back byte-DIFFERENT with identical text. Measured 2026-08-26:
        # check_cites, check_layout and check_sheet were left falsely dirty in git by exactly this.
        # ★ AND THE VERIFIED-RESTORE BELOW COULD NOT SEE IT - it compared two universal-newline
        #   reads, which normalise the very difference it exists to catch. **A guard blind to the
        #   fault it causes.**
        good[t] = io.open(path, encoding="utf-8", newline="").read()
        base[t] = run(t)
        print("   baseline  %-24s exit %d, %d lines%s"
              % (t, base[t][1], len(base[t][0].split("\n")),
                 "  (" + " ".join(LOUDEST[t]) + ")" if t in LOUDEST else ""))
    print("")

    silent, rotted, current = [], [], None
    try:
        for tool, label, find, repl in todo:
            if current != tool:
                current, _ = tool, print("   %s" % tool)
            path = toolpath(tool)
            n = good[tool].count(find)
            if n != 1:
                # ⚠ THE ANCHOR ROTTED. Never a skip - see the header.
                rotted.append((tool, label, n))
                print("       %-58s ⚠ ANCHOR x%d - NOT TESTED" % (label, n))
                continue
            io.open(path, "w", encoding="utf-8", newline="").write(
                good[tool].replace(find, repl, 1))
            out, code = run(tool)
            io.open(path, "w", encoding="utf-8", newline="").write(good[tool])

            bit = (out, code) != base[tool]
            known = any(k in label for k in KNOWN_SILENT)
            mark = "BIT " if bit else ("SILENT (recorded)" if known else "⚠ SILENT")
            print("       %-58s %s" % (label, mark))
            if bit and show_diff:
                a, b = base[tool][0].split("\n"), out.split("\n")
                for x, y in zip(a, b):
                    if x != y:
                        print("           - %s" % x.strip()[:76])
                        print("           + %s" % y.strip()[:76])
                        break
            if not bit and not known:
                silent.append((tool, label))
    finally:
        # ⚠⚠ VERIFIED RESTORE. Loudest thing this file can say.
        broke = [t for t in tools
                 if io.open(toolpath(t), encoding="utf-8", newline="").read() != good[t]]
        for t in broke:
            io.open(toolpath(t), "w", encoding="utf-8", newline="").write(good[t])
        again = [t for t in tools
                 if io.open(toolpath(t), encoding="utf-8", newline="").read() != good[t]]
        if again:
            print("")
            print("   [!!!] RESTORE FAILED - THESE TOOLS ARE MUTATED ON DISK: %s" % ", ".join(again))
            print("         `git checkout -- addons/tools/` before running anything else.")
            return 3

    print("")
    print("   %d mutation%s  ·  %d silent and unexplained  ·  %d anchor%s rotted"
          % (len(todo), "" if len(todo) == 1 else "s", len(silent),
             len(rotted), "" if len(rotted) == 1 else "s"))
    for t, l in silent:
        print("   [!] %s: breaking `%s` changed NOTHING." % (t, l))
    for t, l, n in rotted:
        print("   [!] %s: `%s` matched %d times - the tool moved and the mutation did not."
              % (t, l, n))
    if silent:
        print("")
        print("   ⚠ A SILENT MUTATION IS NOT AUTOMATICALLY A BUG. The guard may be UNREACHED by")
        print("     this corpus rather than wrong. ⟶ Decide which, then RECORD it in the tool and")
        print("     mark the entry `[known SILENT]` here. Deleting it to clear the count is the")
        print("     one move that turns a real finding into a lie.")
    print("")
    return 1 if (silent or rotted) else 0


if __name__ == "__main__":
    sys.exit(main())
