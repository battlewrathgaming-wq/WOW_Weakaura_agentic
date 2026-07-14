"""
batch_press.py - the first true PRODUCTION RUN: press one contract across every class:spec that has members.

Enumerate the class:spec pairs from the corpus attribution, measure each pair's membership with the contract's own
select, SKIP the zero-member pairs (honest zeros - pet/healer profiles whose products belong to other contracts;
NOTED, never silently absent), and press the rest through populate. Then the machine as always: one stage sweep,
one pickup drain. The register becomes the product catalog.

  py batch_press.py target_tracker.contract.json
"""
import json
import os
import subprocess
import sys
from collections import defaultdict

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.normpath(os.path.join(_THIS, "..", ".."))
sys.path.insert(0, _THIS)
from pull_target_tracker import CC, references_gain, spec_spells

COA = os.path.join(_ROOT, "dependencies", "coa_spells.json")
RESOLVED = os.path.join(_THIS, "resolved.json")
PRODUCTION = os.path.join(_ROOT, "Weak Auras", "engine", "Production")


def members(d, res, cls, spec):
    fams = defaultdict(list)
    for sid, s in spec_spells(d, cls, spec).items():
        ax = (res.get(sid) or {}).get("axes") or {}
        if ax.get("target") not in ("enemy", "both") or ax.get("persistence") != "window":
            continue
        auras = {e.get("aura_name") for e in (res.get(sid) or {}).get("edges", [])
                 if e.get("rel") == "applies_aura"} - {None}
        if auras and not (auras - CC):
            continue
        if references_gain(d, res, sid):
            continue
        fams[s.get("name") or sid].append(sid)
    return len(fams)


def main():
    contract = sys.argv[1] if len(sys.argv) > 1 else "target_tracker.contract.json"
    d = json.load(open(COA, encoding="utf-8"))
    res = json.load(open(RESOLVED, encoding="utf-8"))
    pairs = sorted({(r["class"], r["spec"]) for s in d.values()
                    for r in (s.get("coa") or {}).get("direct", []) if r.get("class") and r.get("spec")})

    pressed, skipped, failed = [], [], []
    for cls, spec in pairs:
        n = members(d, res, cls, spec)
        if n == 0:
            skipped.append((cls, spec))
            continue
        p = subprocess.run([sys.executable, os.path.join(_THIS, "populate.py"), contract, cls, spec],
                           capture_output=True, text=True, cwd=_THIS)
        (pressed if p.returncode == 0 else failed).append((cls, spec, n, p.stderr.strip()[:80]))
        if p.returncode != 0:
            print("  PRESS FAILED %s/%s: %s" % (cls, spec, p.stderr.strip()[:120]))

    print("pressed %d packs (%d member auras) | skipped %d zero-member pairs | failed %d"
          % (len(pressed), sum(n for _, _, n, _ in pressed), len(skipped), len(failed)))
    print("skipped (honest zeros - other contracts' territory): %s"
          % ", ".join("%s/%s" % p for p in skipped))

    print("\n-- stage --")
    st = subprocess.run([sys.executable, "stage.py"], capture_output=True, text=True, cwd=PRODUCTION)
    print(st.stdout.strip().splitlines()[-1] if st.stdout.strip() else st.stderr[:200])
    print("-- pickup --")
    pk = subprocess.run([sys.executable, "pickup.py"], capture_output=True, text=True, cwd=PRODUCTION)
    print(pk.stdout.strip().splitlines()[-1] if pk.stdout.strip() else pk.stderr[:200])
    for ln in pk.stdout.splitlines():
        if "FAILED" in ln:
            print(ln)


if __name__ == "__main__":
    main()
