"""
roundtrip.py - the plane_v2 anchor test. Drives a MINIMAL, source-authored aura (the reasoned delta only)
through the P11 body and asserts it is reimport-stable:

    minimal  --canon-->  A  --encode-->  string  --decode-->  B  --canon-->  B2   ;   diff(A, B2) == clean

canon = WA's own acceptor headless (wa_lua_verify/canon.lua). "clean" here means reimport-STABLE under the
fast proxy - NOT the ground-truth gate (that stays the live client: import the string, re-export, diff).
This is the red/green anchor the rest of the pipeline is built to turn green. No corpus in the loop.

  py roundtrip.py
"""
import json
import os
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
_WA = os.path.dirname(_THIS)                 # Weak Auras/
sys.path.insert(0, _WA)
sys.path.insert(0, _THIS)
import weakaura_codec as wc
import diff as diffmod
import fill as fillmod
import reconcile as rec                       # the fill/canon -> codec gate (bounce); owns canon now

DOCKET = os.path.join(_THIS, "dockets",
                      sys.argv[1] if len(sys.argv) > 1 else "corpse_explosion.v2.docket.json")


# the aura-table delta comes from the DOCKET via the dumb filler (no hand-literal, no reasoning in the docket).
MINIMAL = fillmod.fill(json.load(open(DOCKET, encoding="utf-8")))


def main():
    A = rec.bounce(MINIMAL)                              # WA completes our minimal, reconciled codec-ready
    s = wc.encode_import_string(A)                       # export
    B = wc.decode_import_string(s)                       # reimport (decode)
    B2 = rec.bounce(B)                                   # WA completes the reimport, reconciled
    d = diffmod.deep_diff(A, B2)                         # reimport-stable?
    diffs = d if isinstance(d, list) else ([] if not d else [d])
    print("minimal authored : %d fields" % len(MINIMAL))
    print("WA-completed (A)  : %d fields" % len(A))
    print("import string     : %d chars" % len(s))
    if diffs:
        print("\nRED - reimport diff (%d):" % len(diffs))
        for line in diffs[:40]:
            print("   ", line)
        sys.exit(1)
    print("\nGREEN - reimport-stable headless. (Ground-truth gate remains the live client.)")


if __name__ == "__main__":
    main()
