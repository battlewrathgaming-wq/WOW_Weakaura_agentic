"""make_live_check.py - Phase 2's closing step: ONE importable string per V1 lane, for the
live hand-import check (invariant 6: headless-green != live-proven; the runway's one planned
pause). Strings come from the machine's own bundle (expand->fill->bounce->codec) fed the SAME
dockets press_templates presses - nothing minted here is shell output.

  py make_live_check.py     -> out/live_check/<lane>.txt (3 strings) + a receipt
"""
import copy
import json
import os
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.abspath(os.path.join(_HERE, "..", ".."))
_PLANE = os.path.join(_ROOT, "Weak Auras", "plane")
_SCRATCH = os.path.join(_HERE, "out", "live_check", "_dockets")
OUT_DIR = os.path.join(_HERE, "out", "live_check")

sys.path.insert(0, _PLANE)
sys.path.insert(0, _HERE)
import bundle as bundlemod          # noqa: E402
import press_templates as pt        # noqa: E402


def write_docket(d, name):
    os.makedirs(_SCRATCH, exist_ok=True)
    p = os.path.join(_SCRATCH, name + ".docket.json")
    json.dump(d, open(p, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    return p


def main():
    ref_group, ref_member = pt.reference_dockets()

    # dot_target: BOTH fragments ride the check as two members (distinct id+uid - pack hygiene)
    appear = copy.deepcopy(ref_member)
    appear["id"] = "Blight - appear"
    appear["uid"] = "coaLCdtAppear"
    persist = pt.persist_variant(ref_member)
    persist["id"] = "Blight - persist"
    persist["uid"] = "coaLCdtPersist"
    dt_group = copy.deepcopy(ref_group)
    dt_group["id"] = "COA live-check - DoT target"
    dt_group["uid"] = "coaLCdtGrp"

    packs = {
        "dot_target": (dt_group, [appear, persist]),
        "dot_multi": (pt.corpus_docket("DOTS"), [pt.corpus_docket("DOT")]),
        "pet": (pt.corpus_docket("Pet_health_test"), [pt.corpus_docket("Pet_health_spawner")]),
    }

    os.makedirs(OUT_DIR, exist_ok=True)
    for lane, (group, members) in packs.items():
        paths = [write_docket(m, f"{lane}_{i}") for i, m in enumerate(members)]
        s = bundlemod.bundle({"group": group, "children": paths})
        out = os.path.join(OUT_DIR, lane + ".txt")
        with open(out, "w", encoding="utf-8") as f:
            f.write(s + "\n")
        print(f"  {lane:12s} -> out/live_check/{lane}.txt  ({len(members)} member{'s' if len(members)!=1 else ''}, {len(s)} chars)")
    print("\nlive check: import each in the real client - import clean, display right, test events safe.")


if __name__ == "__main__":
    main()
