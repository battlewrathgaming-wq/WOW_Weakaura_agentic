"""boot.py - the boot sequence, EXECUTED rather than remembered.

    py operations/boot.py --lane Addons

Battlewrath, 2026-08-12: *"We might need to harden the boot sequence, so it's doing the
work instead of regret of missing it."*

PROTOCOL.md's boot rule is a ritual spread across five files, and the protocol already
carries the law that kills rituals: discipline rules fail slowly, a field that does not
exist cannot fail. Same shape here - a REMEMBERED sequence fails slowly. This runs it.

THE SEQUENCE, in his words (it is anchored on ROLE, not on status):

    1. You carry your role.                         -> --lane, asserted by you
    2. Check if YOUR ROLE has the helm.              -> HELM
    3. If not, clarify the CONDITIONS on why not.    -> the [!] blocks
    4. If that is a communication / close-out issue, THAT is the work.
    5. And answer why the trunk moved, for a bench arriving cold.  -> WHY

Two things it is for (his reasons, and they are what the output is shaped around):
**it stops incorrect merges of git**, and it **gives a new bench starting cold the
reasoning on why the trunk has moved.** "New bench" means a DIFFERENT bench - not a
later session of your own.

DESIGN RULES, each one load-bearing:

* **It reports; it never TAKES the helm.** A lock you acquire by looking at it is worse
  than one you forget. Taking stays a deliberate act with a stated heading.
* **It emits evidence and raises QUESTIONS; it does not classify.** A held helm is either
  a live hold or a close-out failure, and nothing on disk distinguishes "still working"
  from "session died". So it shows days held, commits since, and who moved the trunk
  last - and names the question. The reader decides.
* **It stores nothing.** Everything is computed at invocation from git and HELM.md, so
  it cannot rest stale - the same rule the addon census follows.
* **It carries only CROSS-BENCH content.** Bench-specific staleness (the addon census
  --check, repo-vs-client drift) stays in that bench's own tooling. A shared file whose
  content is not shared is exactly the mis-identification PROTOCOL.md 2 dissolved.

Exit code: 0 clear to proceed - 1 conditions raised (read them before committing).
"""

import argparse
import re
import subprocess
import sys
from collections import Counter
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OPS = ROOT / "operations"

# Lane -> its operations file. Verified against what is on disk 2026-08-12, NOT invented:
# the aura bench has no lane file of its own and writes its now-state to STATE.md. If it
# ever gets one, this is the line to change.
ALIASES = {
    "addons": "Addons_load.md",
    "aura": "STATE.md",
    "class_design": "Class_design.md",
    "class-design": "Class_design.md",
    "class_identity": "Class_identity.md",
    "class-identity": "Class_identity.md",
    "suno": "Class_identity.md",
    "macros": "Macros.md",
    # 2026-08-22 - two more DungeonRun seats. Their lane file is the seat's own LOG under
    # addons/planning (a repo-relative path, not an operations file), because that is where
    # each seat writes its now-state. Drill 3 (AI-2 A8) found two of four seats could not
    # run the mandated boot as themselves.
    # ⚠ CORRECTED 2026-08-23: this comment used to read *"the two DungeonRun seats that are
    # NOT the addons bench"*. They ARE addons - see SEATS below. That wrong model is exactly
    # why `mine()` was never taught about them, and it cost a false lockout for a day.
    "analyst": "addons/planning/ANALYST_LOG.md",
    "architect": "addons/planning/ARCHITECT_LOG.md",
    "ui": "addons/planning/UI_LOG.md",            # UI specialist (stood up 2026-08-23)
}

# ★★★ A SEAT IS NOT A BENCH, AND THE HELM BELONGS TO THE BENCH.
#
# Battlewrath, 2026-08-23: *"Addon Creator, Opus 5 Analyst, Design Architect are the current
# addon residents."* ⟶ Three seats, ONE bench, ONE trunk lock between them.
#
# ⚠⚠ WHY THIS EXISTS: without it `mine()` compared strings, so `mine("addons", "analyst")` was
# False and boot printed **"LOCKED OUT - repo-read-only. Do not commit."** to two of the four
# seats on EVERY boot. A false stop is worse than a silent guard: obeyed, it halts legitimate
# work; ignored, it trains the seat to discount the guard, and then it cannot be trusted on the
# day the lockout is REAL. ★ Both outcomes spend trust rather than fail to earn it.
#
# ⚠ ONLY WHAT WAS STATED IS HERE. The class-identity / suno pair looks like the same
# relationship and is deliberately NOT assumed - an unmapped seat resolves to itself, which is
# the old behaviour. Ask before adding a row; a guessed org chart is a guessed lockout.
SEATS = {
    "addons": "addons",                    # the Addon creator
    "analyst": "addons",                   # Opus 5 Analyst
    "architect": "addons",                 # Design architect
    "ui": "addons",                        # UI specialist - Battlewrath, 2026-08-23: "stand a new agent up as a UI specialist" - yes, proceed
    # ★ Confirmed 2026-08-23, and ALIASES already corroborated it: `suno` and `class_identity`
    #   route to the SAME lane file (`Class_identity.md`), which is the seat/bench relation
    #   written down one layer lower.
    "class_identity": "class_identity",
    "class-identity": "class_identity",
    "suno": "class_identity",
}


def lane_path(name):
    """A lane file is an operations/ file unless the alias carries a repo-relative path."""
    return name if "/" in name else f"operations/{name}"


CAP = 12  # commits shown in WHY. Never a silent truncation - the overflow is printed.
SEP = "\x01"


def git(*args, ok_fail=True):
    """Run git at the repo root. Returns stdout stripped, or '' when it failed."""
    r = subprocess.run(
        ["git", *args], cwd=ROOT, capture_output=True, text=True,
        encoding="utf-8", errors="replace",
    )
    if r.returncode != 0 and not ok_fail:
        sys.exit(f"git {' '.join(args)} failed:\n{r.stderr.strip()}")
    return r.stdout.strip() if r.returncode == 0 else ""


# ---------------------------------------------------------------- HELM.md

FIELD = re.compile(r"^(holder|since|heading|runway)\s*:\s*(.*)$", re.I)


def read_helm():
    """Parse HELM.md into fields + the lines that should not be there.

    The stub form IS the check (PROTOCOL.md appendix): 'any extra line is by definition
    outstanding'. Counting them is free; a human glance is not. Both drifts that were
    hardened against historically are mechanical to spot - a `since:` carrying a
    parenthetical report, and heading/runway left behind at release.
    """
    path = OPS / "HELM.md"
    if not path.exists():
        return {"missing": True, "fields": {}, "extras": ["HELM.md is missing"]}

    fields, extras = {}, []
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.rstrip()
        if not line.strip():
            continue
        m = FIELD.match(line)
        if m:
            fields[m.group(1).lower()] = m.group(2).strip()
        elif line.startswith("#") or line.startswith("_"):
            continue  # the title and the one rules/pointer line are the stub form
        else:
            extras.append(line)

    since = fields.get("since", "")
    if "(" in since:
        extras.append(f"since: carries a parenthetical - it is a BARE DATE: {since}")
    if fields.get("holder", "").upper() == "RELEASED":
        for f in ("heading", "runway"):
            if fields.get(f, "").strip(" -—"):
                extras.append(f"{f}: still set while RELEASED - it is CLEARED at release")

    return {"missing": False, "fields": fields, "extras": extras}


def age_days(datestr):
    m = re.match(r"(\d{4})-(\d{2})-(\d{2})", datestr or "")
    if not m:
        return None
    return (date.today() - date(*map(int, m.groups()))).days


def bench_of(name):
    """A seat resolves to its bench; anything unmapped is its own bench (the old behaviour)."""
    k = (name or "").strip().lower().replace(" ", "_")
    return SEATS.get(k, k)


def mine(holder, lane):
    """Does LANE sit on the bench that holds the trunk?

    ⚠ The loose match stays and is still on purpose - historical holders read 'addons bench',
    'AURA', 'suno'. What is NEW is that both sides resolve through SEATS first, so a seat is
    measured by its BENCH rather than by whether its name happens to be a substring.
    """
    h, l = (holder or "").lower(), (lane or "").lower()
    if not h or h == "released":
        return False
    hb, lb = bench_of(h.split()[0] if h.split() else h), bench_of(l)
    return hb == lb or l in h or (h.split()[0] in l if h.split() else False)


def same_seat(holder, lane):
    """The seat itself holds it, as opposed to a bench-mate."""
    h, l = (holder or "").lower(), (lane or "").lower()
    return bool(h) and (h == l or l in h or (h.split()[0] in l if h.split() else False))


# ---------------------------------------------------------------- commits

def commits(rangespec):
    """[(sha, date, subject, [top-level dirs touched])] - newest first."""
    out = git("log", f"--format={SEP}%h|%ad|%s", "--name-only", "--date=short", rangespec)
    got = []
    for chunk in out.split(SEP):
        if not chunk.strip():
            continue
        head, *files = chunk.strip().splitlines()
        sha, when, subject = head.split("|", 2)
        areas = sorted({(f.split("/")[0] if "/" in f else f) for f in files if f.strip()})
        got.append((sha, when, subject, areas))
    return got


def show(rows, indent="       "):
    for sha, when, subject, areas in rows[:CAP]:
        subject = subject if len(subject) <= 72 else subject[:69] + "..."
        print(f"{indent}{sha}  {when}  {subject}")
        if areas:
            print(f"{indent}          areas: {', '.join(areas[:6])}")
    if len(rows) > CAP:
        print(f"{indent}... +{len(rows) - CAP} more (raise CAP or use git log)")


# ---------------------------------------------------------------- the sequence

def main():
    ap = argparse.ArgumentParser(description="Role-anchored boot check for the COA trunk.")
    ap.add_argument("--lane", required=True,
                    help="YOUR role, e.g. Addons / aura / Class_design / Macros / Suno")
    ap.add_argument("--fetch", action="store_true",
                    help="git fetch first - otherwise origin is only as fresh as your last fetch")
    args = ap.parse_args()

    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

    key = args.lane.strip().lower().replace(" ", "_")
    name = ALIASES.get(key) or (f"{args.lane}.md" if (OPS / f"{args.lane}.md").exists() else None)
    if not name:
        print(f"Unknown lane {args.lane!r}. Known: {', '.join(sorted(set(ALIASES)))}")
        print("Or name an operations file directly: " +
              ", ".join(sorted(p.stem for p in OPS.glob("*.md"))))
        return 2
    raised = []

    if args.fetch:
        git("fetch", "origin")

    # 1 - ROLE. Asserted, never inferred: PROTOCOL.md 1 makes the human the authority
    #     on identity, so a tool that guessed here would be claiming an authority it
    #     does not have.
    print(f"\nROLE   {args.lane}   (you assert this; this tool never guesses it)")
    print(f"       lane file: {lane_path(name)}")
    # ★ THE BAND, pointed at rather than restated. Four lines atop every message; the schema
    # is PROTOCOL.md 1b. ⚠ It lived in ONE agent's memory until 2026-08-22, so every other seat
    # was expected to reproduce a convention nobody had published - which is the same fault as a
    # rule that is known but never read before flight.
    print("       band: Boot · Files · Memories · Instrument   (schema: operations/PROTOCOL.md 1b)")

    # 2/3 - HELM, and the CONDITION when it is not yours.
    helm = read_helm()
    f = helm["fields"]
    holder, since = f.get("holder", "?"), f.get("since", "?")
    days = age_days(since)
    aged = f" ({days}d)" if days is not None else ""
    print(f"\nHELM   {holder}  since {since}{aged}")

    custody = commits("-1 -- operations/HELM.md") or commits("-1")
    if custody:
        sha, when, subject, _ = custody[0]
        print(f"       last custody: {sha} {when}  {subject[:64]}")

    if helm["extras"]:
        raised.append("HELM.md has grown beyond the stub form")
        print("       [!] BEYOND THE STUB - any extra line is by definition outstanding:")
        for e in helm["extras"]:
            print(f"           - {e}")

    if holder.upper() == "RELEASED":
        print("       -> free. TAKE IT when you go into motion, with a stated heading.")
    elif mine(holder, args.lane):
        # ★ NOT LOCKED OUT EITHER WAY - but a bench-mate's hold is a COORDINATION fact, and
        # collapsing the two would hide that someone else on your bench has motion in flight.
        if same_seat(holder, args.lane):
            print("       -> yours. You hold the trunk.")
            # ⚠⚠ AGE IS NOT A SYMPTOM ON YOUR OWN SEAT EITHER - the THIRD false alarm, and
            # the two halves of this branch had disagreed since the bench-mate case was
            # fixed. A multi-day hold was already the steady state below; declaring it
            # normal there and a CONDITION here was the same fact answered two ways.
            #
            # Battlewrath, 2026-08-23, ruling it: *"if every process is a helm court
            # hearing, we spend more time on that than the work product."*
            #
            # ★★★ AND THE PREMISE THE OLD WARNING RESTED ON IS NOT TRUE HERE. It read *"if
            # your earlier session closed, this is an UNRELEASED hold"* - i.e. a lock left
            # behind by an agent nobody was watching. His: *"I don't do automation, every
            # agent active is because I'm on the other end of the wire."* ⟶ There is no
            # unattended session to abandon one. A hold can still outlive its session - one
            # did, 2026-08-22 to 2026-08-23 - but the cost is a STALE HEADING, not a
            # collision, and a stale heading is not an alarm.
            #
            # ★ THE SIGNAL IS KEPT AND THE ALARM IS DROPPED: the age still prints, and so
            # does what it might mean. Only `raised` loses the row - the same distinction
            # this file already draws between EVIDENCE and a CONDITION.
            if days and days >= 1:
                print(f"       held {days}d - expected: three seats, one trunk, and it "
                      "sits with the bench.")
                print("          ☐ if your earlier session closed, the HEADING is stale "
                      "rather than the hold wrong.")
        else:
            print(f"       -> YOUR BENCH ({bench_of(args.lane)}) holds it, taken as "
                  f"{holder}. Not a lockout.")
            print("          ⚠ A BENCH-MATE, NOT YOU. Their heading above is live work - read "
                  "it before")
            print("            you go into motion, and do not re-take a trunk your bench "
                  "already holds.")
            # ⚠ AGE IS NOT A SYMPTOM HERE, and raising it as one was a second false alarm.
            # Battlewrath, 2026-08-23: *"the current pace of dev means helm would be
            # impractical to keep bouncing between seats."* ⟶ A bench holding its own trunk
            # across days is the STEADY STATE, so a condition that fires on every boot forever
            # teaches the seat to scroll past the block that also carries the real ones.
            # ★ Printed as a fact, never RAISED - the distinction this file already draws
            # between evidence and a condition.
            if days and days >= 1:
                print(f"          held {days}d - expected: the trunk sits with the bench "
                      "rather than bouncing between seats.")
    else:
        raised.append(f"trunk is held by {holder}")
        print(f"       [!] LOCKED OUT - {holder} holds it, not {args.lane}.")
        take = git("log", "-1", "--format=%H", "--", "operations/HELM.md")
        since_take = commits(f"{take}..HEAD") if take else []
        # Exactly what this measures: commits since HELM.md last CHANGED. For a genuinely
        # held helm that IS the take, because nothing has touched the file since.
        print(f"           {len(since_take)} commit(s) on main since HELM.md last changed.")
        if since_take:
            newest = since_take[0]
            print(f"           newest: {newest[0]} {newest[1]}  {newest[2][:58]}")
        if days is not None and days >= 2:
            print(f"           CONDITION TO CLARIFY: held {days} days. Nothing on disk "
                  "separates a LIVE hold")
            print("           from a session that died holding it. If it is a close-out "
                  "or communication")
            print("           failure, THAT is the work - surface it to Battlewrath, one "
                  "word clears it.")
        # ⚠⚠ THIS SAID **"repo-read-only. Do not commit."** UNTIL 2026-08-23, AND THE
        # GOVERNING DOC NEVER SAID IT. PROTOCOL.md 3 calls the helm *"the LOCK that keeps
        # co-working threads from colliding"*, and its only mention of committing is a BOOT
        # ORDER item - read HELM.md before you commit - which this had hardened into a
        # prohibition. ★ [[a-docket-is-a-working-set-not-a-basis]]: the tool invented a rule
        # one level below the document that governs it, and then printed it as law.
        # ⟶ Battlewrath, 2026-08-23: *"It mainly exists to not merge pushes, but only addon
        # creator is managing push to git."* ⟶ So the cost of a lockout is the PUSH, never the
        # work. A seat that stops committing because of this loses its own history for nothing.
        print("           WHAT THIS COSTS YOU: the PUSH, not the work. Commit freely on your")
        print("           own lane - the lock exists so co-working threads do not collide on")
        print("           `main`. Do not push or merge over another bench's hold; hand it to")
        print("           them, or ask for the trunk with a stated heading.")

    # TRUNK - the merge guard. His second reason for wanting this.
    branch = git("rev-parse", "--abbrev-ref", "HEAD") or "?"
    dirty = [l for l in git("status", "--porcelain").splitlines() if l.strip()]
    print(f"\nTRUNK  branch {branch}")
    counts = git("rev-list", "--left-right", "--count", f"origin/{branch}...HEAD")
    behind = ahead = 0
    if counts and "\t" in counts:
        behind, ahead = (int(x) for x in counts.split("\t")[:2])
        state = "in sync" if not (behind or ahead) else f"{ahead} ahead, {behind} behind"
        print(f"       vs origin/{branch}: {state}" +
              ("" if args.fetch else "   (last-fetched state; --fetch to refresh)"))
        if behind:
            raised.append(f"origin/{branch} is {behind} ahead of you")
            print(f"       [!] PULL FIRST - {behind} commit(s) landed that you do not have. "
                  "Committing on top")
            print("           of a stale tip is how a merge goes wrong.")
        if ahead:
            print(f"       [!] {ahead} local commit(s) unpushed.")
            raised.append(f"{ahead} unpushed commit(s)")
    else:
        print(f"       vs origin/{branch}: no remote-tracking ref found")

    if dirty:
        raised.append(f"{len(dirty)} uncommitted change(s)")
        print(f"       [!] {len(dirty)} uncommitted change(s):")
        for l in dirty[:8]:
            print(f"           {l}")
        if len(dirty) > 8:
            print(f"           ... +{len(dirty) - 8} more")
    else:
        print("       tree clean")

    # 5 - WHY THE TRUNK MOVED. The cold-start answer, and it costs nothing to produce:
    #     it is the commit messages we already write. Which is the quiet payoff - the
    #     discipline of a commit message carrying the story stops being a courtesy and
    #     becomes the boot input for the next bench.
    last = git("log", "-1", "--format=%H", "--", lane_path(name))
    print(f"\nWHY    what landed since {args.lane} last wrote {lane_path(name)}:")
    if not last:
        print("       (no history for that file)")
    else:
        rows = commits(f"{last}..HEAD")
        if not rows:
            print("       nothing. You are the last writer on the trunk.")
        else:
            print(f"       {len(rows)} commit(s) - this is the reasoning a cold bench needs.")
            # The ROLL-UP first, because a truncated flat list buries the answer: a lane
            # that has been away for weeks gets a range dominated by whichever bench was
            # busiest, and "which areas moved, and how much" is the actual cold-start read.
            tally = Counter(a for _, _, _, areas in rows for a in areas)
            print("       areas: " + " · ".join(
                f"{a} {n}" for a, n in tally.most_common(8)))
            print("       most recent:")
            show(rows)

    print()
    if raised:
        print("CONDITIONS RAISED - read them before you commit:")
        for r in raised:
            print(f"  [!] {r}")
        print()
        return 1
    print("Clear. Take the helm when you go into motion.\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
