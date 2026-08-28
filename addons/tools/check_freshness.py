# -*- coding: utf-8 -*-
r"""check_freshness.py - which planning docs the CODE THEY NAME has moved under.

    py addons/tools/check_freshness.py            the suspect ones
    py addons/tools/check_freshness.py --all      every doc, with its tier and topic
    py addons/tools/check_freshness.py --untiered only the docs with no tier yet

★★★ WHY THIS EXISTS - RI-82, closed by the Analyst 2026-08-27, and the close REMOVED a field.

Battlewrath asked for a freshness checker and a per-doc lifecycle tag. Measured then: 48 of 59
docs carry a date, **37 of those disagree with their own last git touch**, and the date is an
ORIGIN stamp - git already holds last-touched for free.

★★ THE ANALYST'S CLOSE, and this tool is built to it:

    TIER      governing · reference · scope · history · BENCH   (the fifth was added because
              ten docs are the seats' own apparatus and must never enter a code-move queue)
    TOPIC     ⟶ NOT a hand tag. **54 of 59 docs already name their own code**, and
              `check_cites` resolves 442 such citations. A hand-kept topic beside a citation
              naming `map.lua:317` is a SECOND COPY of a dependence the doc already states -
              and per-LINE rather than per-bucket, so it is the sharper signal of the two.
    VERIFIED  `<date> · <seat>` - the ONLY field no machine can infer. Git gives touched-at
              free; verified-at is a claim by a person that they read the doc against the code.

⟶ SO THE QUESTION THIS ANSWERS IS NOT "is this doc old". It is: **has the code this doc names
moved since somebody last read it against that code?** Age measures attention; this measures
divergence, and only the second is a queue.

⚠⚠ THE CEILING, ON SCREEN EVERY RUN - and RI-82 named it before the tool existed.

Five docs name NO code: `README` · `driver_use_case_target` · `driver_user_journey` ·
`mvp_scope` · `test1_runsheet`. Three are governing and are code-free BY DESIGN - they carry
intent, not implementation. ★ For them the topic is `none`, and **`none` is a FACT, not a gap**.

⚠ **THIS TOOL PRINTS FOUR, AND THE FIFTH IS `README`** - it is tier `bench`, and bench docs are
filtered out BEFORE topic is consulted (the Analyst's (1): they must never enter a code-move
queue). 4 + README = their 5. ★ Stated because two counts of one corpus differing by one is
either an explanation or a defect, and an unexplained difference is how a checker starts lying.

★★★ AND `mvp_scope` IS THE CASE NOTHING HERE CATCHES, stated twice in RI-82 and repeated here
because a tool that hides its blind spot is worse than none. It reads *"`Routes.BeaconAt` has no
caller anywhere in the addon. That is the whole of what is missing."* The Manager runtime
shipped since - **and `BeaconAt` genuinely still has no caller.** A reader checks the one fact
the file offers, finds it TRUE, and draws the wrong conclusion. **No mechanical check catches a
framing that died while its fact survived.** This tool does not claim to.

★ EXACTLY ONE THING IS FATAL, and it is deliberately not staleness:

    [!] EXIT 1   a `VERIFIED:` line this tool cannot parse. That is a stamp somebody wrote
                 that no reader can use - the one failure that is unambiguous.
    ~   TOLD     everything else. A doc whose code moved is a QUEUE, not a defect. Failing on
                 that would make this permanently red on a correct corpus, which is the lesson
                 `check_cites` paid for at §468 and `check_anchors` inherited.

★ `untiered` IS GONE (§757). It was the honest answer while the vocabulary was unwritten;
RI-86 □1 wrote it, and the tier is now DERIVED for every doc. ⚠ `--untiered` still runs and
now prints nothing, which is the correct reading rather than a dead flag.
"""

import io
import os
import re
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
PLANNING = os.path.join(ROOT, "addons", "planning")

# ★ THE TEN THE ANALYST NAMED. They direct no one about the PRODUCT - they are the seats' own
# apparatus - and they are also the noisiest citers in the corpus (`ARCHITECT_INBOX` names 38
# distinct files). ⟶ TIER filters them out before TOPIC is ever consulted, which is what stops
# the citation-derived topic smearing across every commit.
BENCH = {
    "ANALYST_LOG.md", "ARCHITECT_LOG.md", "ARCHITECT_INBOX.md", "ARCHITECT_PROPOSALS.md",
    "UI_LOG.md", "UI_INBOX.md", "UI_SEAT.md", "UI_FOR_THE_BENCH.md",
    "Reconcile_inbox.md", "README.md",
}

# ★★★ A NAMED FILE, WITH OR WITHOUT A LINE NUMBER - and that is the ONE place this tool
# deliberately does NOT match `check_cites`.
#
# ⚠⚠ The first cut required `:N` and reported **19 code-free docs** where the Analyst measured
# **5**. A doc naming `map.lua` in prose depends on `map.lua` exactly as much as one naming
# `map.lua:317` - TOPIC is about DEPENDENCE, not about a resolvable pointer. `check_cites`
# resolves POINTERS and needs the line; this asks *what does this doc depend on* and must not.
#
# ★ Their 5 is the check on this reading: matching it means the same thing is being counted.
# ⚠⚠ `.py` AS SERIOUSLY AS `.lua` (RI-87, 2026-08-28). This matched Lua alone, and **35 of 59
# planning docs name a `.py` file** - so a doc whose whole subject is a Python desk tool recorded
# its dependence as whatever Lua it mentioned in passing. `driver_walk_acceptance` is the clean
# case: its own result doc says *"run it yourself: py addons/tools/walk.py"*, and this tool tied it
# to `beacon.lua` and `capture.lua`. ⟶ It queued when the wrong code moved and stayed SILENT when
# `walk.py` did.
#
# ★★ AND THE AGREEMENT THAT HID IT IS THE LESSON. RI-86 recorded *"your 5 was the check on my
# reading"* - the Analyst counted 5 code-free docs, this tool counted 4. **Both used a `.lua`-only
# pattern.** Two measurements that share a prior confirm nothing; the one number meant to be
# independent was not. Same law as the counterpart principle, landing on TOOLS instead of agents.
CITE = re.compile(r"\b([A-Za-z0-9_][A-Za-z0-9_.\-]*\.(?:lua|py))\b")
VERIFIED = re.compile(r"^\s*VERIFIED:\s*(.+?)\s*$", re.M)

# ★★★ `<date> · <seat> · <what was read>` - and the THIRD FIELD is the bench answering
# RI-82's closing ☐: *"worth the bench deciding whether a VERIFIED stamp should have to name
# what it read - a commit, a mutation, a row - so the claim carries its own evidence rather
# than resting on the stamper."*
#
# ★★ THE ANSWER IS YES, and it costs nothing to require. The Analyst named the one direction
# this field can be wrong in: *"nothing mechanical will catch a stamp somebody wrote without
# doing the reading."* ⟶ Naming the evidence does not make the stamp checkable by a machine -
# nothing can - but it makes it **auditable by a person in seconds** rather than a claim that
# rests entirely on who wrote it. A stamp reading `§717 · A12.5c/d mutations` can be looked up;
# a bare date and seat cannot.
#
# ⚠ OPTIONAL IN THE PARSER, REQUIRED IN THE CONVENTION. A stamp without it still parses and is
# reported as `(no evidence named)` - because refusing it would make every existing stamp
# UNPARSABLE, which is this tool's one fatal state, and a gate that reds a corpus for adopting
# a convention it has not adopted yet is the §468 fault.
STAMP = re.compile(
    r"^(\d{4}-\d{2}-\d{2})\s*[·|]\s*([^·|]+?)\s*(?:[·|]\s*(.+?)\s*)?$")


def git(*args):
    r = subprocess.run(["git"] + list(args), capture_output=True, text=True,
                       encoding="utf-8", errors="replace", cwd=ROOT)
    return (r.stdout or "").strip() if r.returncode == 0 else ""


def touched(relpath):
    return git("log", "-1", "--format=%ad", "--date=short", "--", relpath)


def governing():
    """★ TIER IS NOT INVENTED HERE. `DRIVER_BASIS.md` already carries the governing list in
    precedence order, so it is READ rather than restated - the second copy that drifts."""
    p = os.path.join(PLANNING, "DRIVER_BASIS.md")
    if not os.path.exists(p):
        return set()
    body = io.open(p, encoding="utf-8", errors="replace").read()
    head = body.split("## GOVERNING", 1)
    if len(head) < 2:
        return set()
    return set(re.findall(r"`([a-zA-Z0-9_]+\.md)`", head[1].split("\n##", 1)[0]))


def main():
    argv = sys.argv[1:]
    show_all, only_untiered = "--all" in argv, "--untiered" in argv

    gov = governing()
    rows, unparsable = [], []

    for name in sorted(os.listdir(PLANNING)):
        if not name.endswith(".md"):
            continue
        rel = "addons/planning/" + name
        path = os.path.join(PLANNING, name)
        if not os.path.isfile(path):
            continue
        body = io.open(path, encoding="utf-8", errors="replace").read()

        # ---- TIER, derived as far as it honestly can be -------------------
        if name in BENCH:
            tier = "bench"
        # ★ THE BASIS IS GOVERNING BY CONSTRUCTION, and it cannot be listed into it: the governing
        # set is READ from this file's own `## GOVERNING` section, and **a list cannot contain
        # itself**. It reported `untiered` - the tool's own derivation rule failing on the one
        # document that defines the rule. Its first line settles what it is: *"Read this first; it
        # says what governs NOW."* ⟶ It DIRECTS the set. (AI-44 → AL-69 answered the neighbouring
        # question - whether `dungeonrun_model.md` belonged IN the list - and that was a real
        # omission; this is not the same question and is not an omission.)
        elif name == "DRIVER_BASIS.md":
            tier = "governing"
        elif name in gov:
            tier = "governing"
        elif name.startswith("ARCHIVE__") or name.startswith("SUPERSEDED__"):
            tier = "history"
        # ★★★ RI-86 □1, THE ANALYST'S RULE (2026-08-27), BUILT §757. **TIER answers one
        # question: what falsifies this doc?** It read `untiered` here until the vocabulary was
        # written down - *"inventing it would be this tool deciding a vocabulary that is the
        # Analyst's"* - and thirty-four hand-labels would have been the second copy RI-82 was
        # closed to avoid. ⟶ Derived, so a new doc is tiered the day it lands.
        elif name[:-3].endswith("_scope") or name[:-3].endswith("_plan"):
            # ⚠ INTENT, NOT WORK-LISTS. `_asklist` is deliberately absent: the rule caught that
            # on its own first run - an asklist records OPEN QUESTIONS and code landing can
            # ANSWER one, so it is queue-able and filing it here would take it out.
            tier = "scope"
        else:
            # ★★ `reference` IS THE DEFAULT, AND THE DIRECTION IS THE ARGUMENT. A default of
            # `reference` puts a doc **IN** the queue; its failure mode is one extra candidate
            # to read. The failure mode of any other default is a doc silently exempt from the
            # queue forever. ⟶ Default INTO the check, never out of it.
            #
            # ⚠ AND `scope` DOES NOT EXEMPT EITHER - the Analyst corrected their own §721
            # framing on measuring it: `mvp_scope` names no code so TOPIC already keeps it out,
            # while `ui_overhaul_scope` and `pet_parser_scope` DO name code and are genuinely
            # suspect when it moves. **`bench` is the only tier that excludes.** The
            # reference/scope split is for READING, not filtering.
            tier = "reference"

        # ---- TOPIC, read off the doc's own citations ----------------------
        named = sorted({m.group(1) for m in CITE.finditer(body)})

        # ---- VERIFIED ------------------------------------------------------
        vm = VERIFIED.search(body)
        vdate = vseat = vwhat = None
        if vm:
            sm = STAMP.match(vm.group(1))
            if sm:
                vdate, vseat = sm.group(1), sm.group(2)
                vwhat = sm.group(3)
            else:
                unparsable.append((name, vm.group(1)))

        rows.append((name, rel, tier, named, vdate, vseat, touched(rel), vwhat))

    print("")
    print("   DOC FRESHNESS - has the code a doc NAMES moved since anyone read it against that code")
    print("   " + "-" * 74)

    if only_untiered:
        for name, _, tier, _, _, _, _, _ in rows:
            if tier == "untiered":
                print("   ~   %s" % name)
        print("\n   %d untiered" % len([r for r in rows if r[2] == "untiered"]))
        return 0

    # ★★ THE QUEUE: a doc whose named code moved AFTER its VERIFIED stamp. ⚠ `bench` docs are
    # excluded before topic is consulted - the Analyst's (1), and the reason the derived topic
    # does not smear across every commit.
    queue, never, codefree = [], [], []
    for name, rel, tier, named, vdate, vseat, tch, vwhat in rows:
        if tier == "bench":
            continue
        if not named:
            codefree.append((name, tier))
            continue
        if not vdate:
            never.append((name, tier, len(named)))
            continue
        moved = [f for f in named
                 if _moved_since(f, vdate)]
        if moved:
            queue.append((name, tier, vdate, vseat, moved, vwhat))

    for name, tier, vdate, vseat, moved, vwhat in queue:
        print("   ~!  %-38s %-10s verified %s by %s" % (name, tier, vdate, vseat))
        # ★ THE EVIDENCE, SHOWN. A reader deciding whether to re-verify wants to know what
        # the last reading actually covered - that is the whole reason the field exists.
        print("       last reading claimed: %s" % (vwhat or "(no evidence named)"))
        print("       code it names that moved since: %s" % ", ".join(moved[:6]))
    if queue:
        print("       ★ THIS IS A QUEUE, NOT A DEFECT - the doc may still be right; nobody")
        print("         has said so since the code under it moved.")

    if never or show_all:
        print("")
        print("   ~ %d doc(s) name code and carry NO `VERIFIED:` stamp - never read against it"
              % len(never))
        for name, tier, n in never[:14]:
            print("       %-38s %-10s names %d file(s)" % (name, tier, n))

    print("")
    print("   ~ %d doc(s) name NO code at all - the honest ceiling, printed every run:"
          % len(codefree))
    for name, tier in codefree:
        print("       %-38s %s" % (name, tier))
    # ⚠⚠ THIS NOTE WENT STALE THE MOMENT ITS OWN TOOL WAS FIXED (RI-87, 2026-08-28), and it is
    # worth keeping the correction visible: it read *"RI-82 counted FIVE … 4 + README = 5, the
    # readings agree."* ⟶ They agreed because BOTH counted `.lua` only. `test1_runsheet.md` names a
    # `.py` and was never code-free. The reconciliation was arithmetic over a shared blind spot.
    print("       ⚠ RI-82 counted FIVE and this tool counted FOUR, and BOTH WERE WRONG the same")
    print("         way - `.lua` only, while 35 of 59 docs name a `.py` (RI-87). `test1_runsheet`")
    print("         was never code-free. ⟶ THREE, plus `README` at tier `bench`, filtered before")
    print("         topic is consulted. ★ The readings agree now, and for the right reason.")
    print("       ★ `none` is a FACT, not a gap: a doc that names no code cannot be made")
    print("         suspect by code moving. ⚠ `mvp_scope.md` is here, and it is the case")
    print("         nothing mechanical catches - see this file's header.")

    for name, raw in unparsable:
        print("   [!] UNPARSABLE VERIFIED  %-30s %r" % (name, raw))
    if unparsable:
        print("       ★ expected `VERIFIED: <YYYY-MM-DD> · <seat>` - a stamp no reader can")
        print("         use is the one unambiguous failure here.")

    tiers = {}
    for r in rows:
        tiers[r[2]] = tiers.get(r[2], 0) + 1
    print("")
    print("   %d doc(s)   " % len(rows) + "   ".join(
        "%s %d" % (k, v) for k, v in sorted(tiers.items())))
    print("   queue %d   never-verified %d   code-free %d   unparsable %d"
          % (len(queue), len(never), len(codefree), len(unparsable)))
    print("")
    print("   ⚠ AGE IS NOT TRUTH. This reports DIVERGENCE - code moving under a doc since")
    print("     someone read it - never whether the doc is right. A framing can die while")
    print("     every fact in it survives, and no check reaches that.")
    print("")
    return 1 if unparsable else 0


def _moved_since(basename, date, cache={}):
    """Has any file with this basename been committed since `date`?

    ⚠ BY BASENAME, because that is what a citation gives. A doc naming `core.lua` may mean any
    of six; treating a move of ANY of them as suspicion is the conservative direction - it can
    over-queue, never under-queue, and over-queueing is a reading nobody had to do anyway.
    """
    key = (basename, date)
    if key in cache:
        return cache[key]
    out = git("log", "--since", date, "--format=%h", "--name-only", "--", "*/" + basename)
    cache[key] = bool(out.strip())
    return cache[key]


if __name__ == "__main__":
    sys.exit(main())
