"""ui_run.py - reconcile a `/dr ui run` against what actually reached the disk.

★★★ WHY THE TWO SIDES CANNOT BE ONE. Addon Lua cannot read files from disk - a tagged
fact - so the client is authoritative for BEHAVIOUR and blind to ARTEFACTS. It can say
*I asked for a shot labelled "pane open"* and can never say a file exists. This is the
other half, and the split is forced by what each side can observe rather than chosen.

★★ INTENT IS STORED, OBSERVATION IS DERIVED. The run record holds what each step
expected and what it got - a declaration nothing else can reconstruct. The file count
is computed fresh on every read, because a stored count is a claim that can go stale,
and this bench has been bitten twice by exactly that.

⚠ THE JOIN IS KEYED, NOT POSITIONAL. The first round-trip matched two labels to two
files by counting, which works until a shot is dropped - and then every label after it
points at the wrong image, silently. Each shot now carries the clock at its request,
so a label maps to a FILENAME.

⚠ ±1 SECOND, DELIBERATELY. WoW names the file when the frame ends, so a request on a
second boundary can produce a name one second later. The window is stated here rather
than discovered as a mystery.

Usage:
    py addons\\tools\\ui_run.py            reconcile the newest run
"""
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
sys.path.insert(0, str(REPO / "Weak Auras"))
from lua_table import parse_file, LuaParseError   # noqa: E402 - reused, not re-derived

CLIENT = Path(r"F:\games\Ascension_wow\resources\ascension-live")
SV = CLIENT / "WTF" / "Account" / "BATTLEWRATH" / "SavedVariables" / "COA_DungeonRun.lua"
SHOTS = CLIENT / "Screenshots"
STEM = re.compile(r"^WoWScrnShot_(\d{6}_\d{6})\.jpg$", re.I)
WINDOW = 1          # seconds either side; the capture happens at frame end


def _shot_stems():
    """Every screenshot on disk, by its timestamp stem. ⚠ Derived every call."""
    return {m.group(1) for p in SHOTS.glob("*.jpg")
            for m in [STEM.match(p.name)] if m}


def _near(stem, have):
    """The stem, or one within the window. Returns what was found, or None."""
    if stem in have:
        return stem, 0
    date, tm = stem.split("_")
    h, m, s = int(tm[0:2]), int(tm[2:4]), int(tm[4:6])
    for d in range(-WINDOW, WINDOW + 1):
        if d == 0:
            continue
        total = (h * 3600 + m * 60 + s + d) % 86400
        cand = "%s_%02d%02d%02d" % (date, total // 3600, (total % 3600) // 60, total % 60)
        if cand in have:
            return cand, d
    return None, None


def find_run(tree):
    """The uiRun record, wherever the per-character table put it."""
    db = tree.get("COA_DungeonRunDB") or {}
    for _, per in (db.get("ui") or {}).items():
        if isinstance(per, dict) and per.get("uiRun"):
            return per["uiRun"]
    return None


# ★ A SELF-TEST, because the matcher is the one piece with real logic in it and the
# reconciler cannot exercise it on a run that predates `shotAt`. Same shape as
# `check_escapes.py --selftest` and `geometry.py`'s own tests: the tolerance is
# asserted rather than described.
def _selftest():
    have = {"081526_165303", "081526_165304"}
    cases = [
        ("081526_165303", "081526_165303", 0,  "exact"),
        ("081526_165302", "081526_165303", 1,  "one second EARLY - capture at frame end"),
        ("081526_165305", "081526_165304", -1, "one second late"),
        ("081526_165310", None, None,          "outside the window must MISS"),
        ("081526_000000", None, None,          "midnight does not wrap into a hit"),
    ]
    for stem, want, wantd, why in cases:
        hit, drift = _near(stem, have)
        assert hit == want and drift == wantd, (
            "%s: expected %s (%s), got %s (%s)" % (why, want, wantd, hit, drift))
    print("ui_run self-tests: %d case(s) OK" % len(cases))
    return 0


def main():
    if "--selftest" in sys.argv:
        return _selftest()

    if not SV.exists():
        print("no SavedVariables at %s" % SV)
        return 2
    try:
        tree = parse_file(str(SV))
    except LuaParseError as e:
        print("could not parse the saved variables: %s" % e)
        return 2

    run = find_run(tree)
    if not run:
        print("no uiRun in the saved variables - has the client flushed? "
              "SVs only reach disk on /reload or logout")
        return 1

    steps = run.get("steps") or {}
    if isinstance(steps, dict):                    # lua arrays parse as 1-keyed dicts
        steps = [steps[k] for k in sorted(steps, key=lambda x: int(x))]

    have = _shot_stems()
    failed, missing, found = [], [], []
    for i, s in enumerate(steps, 1):
        if s.get("ok") is False:
            failed.append("%d %s %s -> %s" % (i, s.get("verb"), s.get("key") or "",
                                              s.get("actual")))
        if s.get("verb") == "shot":
            stem = s.get("shotAt")
            if not stem:
                # ⚠ An older run, from before the clock was recorded. Say so rather
                # than fall back to counting, which is the thing being replaced.
                missing.append("%s (no shotAt - positional join not attempted)"
                               % (s.get("label") or "unlabelled"))
                continue
            hit, drift = _near(stem, have)
            if hit:
                found.append((s.get("label") or "unlabelled", hit, drift))
            else:
                missing.append("%s (expected ~%s)" % (s.get("label") or "unlabelled", stem))

    print("run %s  ·  %d step(s)  ·  %d shot(s) matched"
          % (run.get("id"), len(steps), len(found)))
    for label, hit, drift in found:
        print("   %-24s %s%s" % (label, hit, "" if drift == 0 else "  (%+ds)" % drift))

    # ★★ BY EXCEPTION below this line: silence when intent and disk agree.
    if failed:
        print("\n⚠ steps that did not match:")
        for f in failed:
            print("    " + f)
    if missing:
        print("\n⚠ shots with no file:")
        for m in missing:
            print("    " + m)

    if not failed and not missing:
        print("\nintent and disk agree")
    return 1 if (failed or missing) else 0


if __name__ == "__main__":
    sys.exit(main())
