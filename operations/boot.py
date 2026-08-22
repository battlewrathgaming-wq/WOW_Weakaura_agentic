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
    # 2026-08-22 - the two DungeonRun seats that are not the addons bench. Their lane file
    # is the seat's own LOG under addons/planning (a repo-relative path, not an operations
    # file), because that is where each seat writes its now-state. Drill 3 (AI-2 A8) found
    # two of four seats could not run the mandated boot as themselves.
    "analyst": "addons/planning/ANALYST_LOG.md",
    "architect": "addons/planning/ARCHITECT_LOG.md",
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


def mine(holder, lane):
    """Loose match on purpose - historical holders read 'addons bench', 'AURA', 'suno'."""
    h, l = holder.lower(), lane.lower()
    return bool(h) and h != "released" and (l in h or h.split()[0] in l)


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
        print("       -> yours. You hold the trunk.")
        if days and days >= 1:
            raised.append("your own hold is more than a day old")
            print(f"       [!] held {days}d. If your earlier session closed, this is an "
                  "UNRELEASED hold, not a live one.")
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
        print("           Until then: repo-read-only. Do not commit.")

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
