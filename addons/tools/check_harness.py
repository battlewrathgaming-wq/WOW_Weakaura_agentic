"""check_harness.py - the offline MODEL and the live PROBE must cover the same set.

★★ §70's completeness walk, applied one level up. Its lesson was that a gap in a
hand-maintained parallel structure CANNOT BE NOTICED unless the whole set can be
enumerated and each member interrogated the same way - *"nothing could have noticed,
because there was no way to ask what the full set WAS."* §63 added three kinds to
`ART` and missed `LABEL` and `TIP_COLOR`; the walk found `kill` had no `RANK` on its
first run.

The same shape exists here, and nothing was watching it:

    addons/tools/smoke/harness.lua   the behaviours we MODEL offline
    addons/COA_DevDump/task_api.lua  the behaviours we MEASURE in the client

⚠ TWO HAND-MAINTAINED LISTS THAT MUST AGREE. Add a divergence to the harness and
forget the probe, and coverage silently shrinks with every test still green - which
is the exact failure mode the harness exists to prevent, one layer up.

The join is the BEHAVIOUR NAME, written identically in both files:

    harness.lua      a `-- BEHAVIOUR: <name>` marker above each modelled divergence
    task_api.lua     the `name = "<name>"` field of a BEHAVIOURS entry

⚠ A NAME IS A WEAK JOIN and that is deliberate. A stronger one would mean the addon
reading a repo file at runtime, which it cannot do - the client never sees
`addons/tools/`. So the check lives at the desk, runs with the suite, and fails loudly.

Usage:
    py addons\\tools\\check_harness.py
"""
import io
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ADDONS = HERE.parent

HARNESS = ADDONS / "tools" / "smoke" / "harness.lua"
PROBE = ADDONS / "COA_DevDump" / "task_api.lua"

MARKER = re.compile(r'^\s*--\s*BEHAVIOUR:\s*(.+?)\s*$', re.M)
PROBE_NAME = re.compile(r'^\s*name\s*=\s*"([^"]+)"\s*,\s*$', re.M)

# ⚠ SCOPED TO THE TABLE, not the file. Unscoped, this matched `name = "api"` from
# D.RegisterTask and reported the TASK as an unmodelled behaviour - a tool whose
# first finding was its own false positive. A checker that cries wolf once is one
# people start passing over.
PROBE_TABLE = re.compile(r'^local BEHAVIOURS = \{(.*?)^\}', re.M | re.S)

# ★ EXPLORATORY probes have no model counterpart YET, and that is legitimate: the
# harness cannot honestly model a behaviour nobody has measured. They are REPORTED
# rather than failed — but they are reported, because an exploration that never
# becomes a model is one that quietly stops mattering.
ENTRY = re.compile(r'\{\s*\n(.*?)\n\s*\},', re.S)
EXPLORATORY = re.compile(r'exploratory\s*=\s*true')


def read(p):
    if not p.exists():
        sys.exit(f"missing: {p}")
    return io.open(p, encoding="utf-8", newline="").read()


def probe_names(text):
    """(settled, exploratory) name sets from the probe's BEHAVIOURS table."""
    m = PROBE_TABLE.search(text)
    if not m:
        sys.exit("check_harness: cannot find `local BEHAVIOURS = {` in task_api.lua - "
                 "the probe's shape changed and this check is reading nothing.")
    settled, exploratory = set(), set()
    for entry in ENTRY.findall(m.group(1)):
        names = PROBE_NAME.findall(entry)
        if not names:
            continue
        (exploratory if EXPLORATORY.search(entry) else settled).add(names[0])
    return settled, exploratory


def main():
    modelled = set(MARKER.findall(read(HARNESS)))
    probed, exploratory = probe_names(read(PROBE))

    unprobed = sorted(modelled - probed - exploratory)
    unmodelled = sorted(probed - modelled)

    def exploring():
        if not exploratory:
            return
        # ASCII on the console: this terminal is cp1252 and an em-dash renders as
        # noise. Same rule the census emitter follows for its star.
        print(f"  {len(exploratory)} exploratory - measured, not yet modelled. The "
              "harness cannot model what has not been measured:")
        for n in sorted(exploratory):
            print(f"      {n!r}")

    if not modelled:
        print("check_harness: NO BEHAVIOUR MARKERS in harness.lua")
        print("  Each modelled divergence needs a `-- BEHAVIOUR: <name>` line above it,")
        print("  or this check silently passes by having nothing to compare.")
        return 1

    if not (unprobed or unmodelled):
        print(f"check_harness: OK - {len(modelled)} behaviour(s) modelled and probed")
        exploring()
        return 0

    print("check_harness: THE MODEL AND THE PROBE HAVE DRIFTED\n")
    for n in unprobed:
        print(f"  MODELLED, NEVER MEASURED   {n!r}")
        print("      harness.lua claims this and no live run has ever checked it.")
    for n in unmodelled:
        print(f"  MEASURED, NEVER MODELLED   {n!r}")
        print("      task_api probes this and the offline stubs do not reproduce it,")
        print("      so a smoke cannot fail on it however wrong the addon gets.")
    exploring()
    print("\n  The join is the behaviour NAME, byte-identical in both files.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
