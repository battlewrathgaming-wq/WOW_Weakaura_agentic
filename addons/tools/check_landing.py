"""check_landing.py - the two landing guards must stay INDEPENDENT and DEFAULT SAFE.

★ WHY THIS EXISTS. `addons/landing/pull.py` carries two guards that stop two different
things, and for a while one field set both:

    stage: testing   -> lands in gitignored staging/     (stops repo churn)
    not swept        -> excluded from the default sweep  (stops SURPRISE)

Wanting "lands automatically, stays out of git" was inexpressible, so the only way to
watch a testing source was `--source` - which REPLACES the name list, so you traded away
watching devdump to get it. §265 split them: `sweep: True` opts one row in.

⚠ THE FAILURE THIS GUARDS IS QUIET IN BOTH DIRECTIONS.

    Too open   a new row lands into a watcher somebody left running, and an addon
               starts being collected because a dict grew - the exact surprise the
               original exclusion was written to prevent.
    Too shut   a dev capture does not land, and NOTHING SAYS SO. The walk is in the
               client's SavedVariables and gets overwritten by the next flush. Run 1
               was lost this way; a lost run looks identical to a run never taken.

So the assertions below are about DEFAULTS, not about today's manifest: a row that says
nothing must be tracked-and-swept (the devdump shape), and a row that says only
`stage: testing` must be excluded. The live rows are checked separately and are allowed
to change - `sweep: True` on dungeonrun is temporary by intent (Battlewrath, 2026-08-17:
*"We'll turn it off when out of the heavy dev loop now."*).
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "landing"))
import pull  # noqa: E402

fails = []


def check(label, got, want):
    if got != want:
        fails.append(f"{label}: got {got!r}, expected {want!r}")
        print(f"  FAIL  {label}: got {got!r}, expected {want!r}")
    else:
        print(f"  ok    {label}")


def main():
    print("landing guards - defaults")
    # A bare row is the devdump shape: tracked, and therefore swept.
    bare = {}
    check("bare row is swept", pull.swept(bare), True)
    check("bare row lands in records", pull.dest(bare).name, "records")

    # ★ The surprise guard. Adding a row must not make it land.
    testing = {"stage": "testing"}
    check("testing row is NOT swept", pull.swept(testing), False)
    check("testing row lands in staging", pull.dest(testing).name, "staging")

    # ★ And the two are independent: opted into the sweep, still out of git.
    opted = {"stage": "testing", "sweep": True}
    check("testing + sweep IS swept", pull.swept(opted), True)
    check("testing + sweep STILL staging", pull.dest(opted).name, "staging")

    # ⚠ sweep must not drag a row into records - that would make one flag do two
    # things again, in the opposite direction.
    check("sweep alone does not track", pull.dest({"sweep": True, "stage": "testing"}).name,
          "staging")

    print("\nlanding guards - the live manifest")
    for n, src in pull.SOURCES.items():
        print(f"  {n:14} stage={src.get('stage', 'tracked'):8}"
              f" swept={str(pull.swept(src)):5} -> {pull.dest(src).name}")

    # Every source must be reachable one way or another, or it is dead config.
    for n, src in pull.SOURCES.items():
        if not pull.swept(src) and src.get("stage") != "testing":
            fails.append(f"{n}: unswept but not testing-stage - unreachable by default")
            print(f"  FAIL  {n} is unswept and not testing-stage")

    if fails:
        print(f"\nLANDING GUARDS BROKEN - {len(fails)}:")
        for f in fails:
            print(f"  {f}")
        return 1
    print("\nlanding guards OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
