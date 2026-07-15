"""mint_harness.py - Phase 4: the shell's mint vs the MACHINE, decode-diff CLEAN or fail.

Same picks, two roads:
  machine road: the same dockets press_templates lifts -> bundle (expand->fill->bounce->codec)
  shell road:   shell/mint.js filling out/templates.json + the ported codec (node)
Decode BOTH with the trusted decoder; the tables must deep-match (envelope `s` excluded - each
road names itself; empty {}=[] normalized as everywhere).

  py mint_harness.py     -> per-lane verdicts, exit 1 on any mismatch
"""
import copy
import json
import os
import subprocess
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.abspath(os.path.join(_HERE, "..", ".."))
sys.path.insert(0, os.path.join(_ROOT, "Weak Auras"))
sys.path.insert(0, os.path.join(_ROOT, "Weak Auras", "plane"))
sys.path.insert(0, _HERE)
import weakaura_codec as wc      # noqa: E402
import bundle as bundlemod       # noqa: E402
import press_templates as pt     # noqa: E402
from codec.harness import lua_to_json, norm  # noqa: E402  (the proven mirror + comparator)

_SCRATCH = os.path.join(_HERE, "out", "live_check", "_harness")
TEMPLATES = json.load(open(os.path.join(_HERE, "out", "templates.json"), encoding="utf-8"))


def write_docket(d, name):
    os.makedirs(_SCRATCH, exist_ok=True)
    p = os.path.join(_SCRATCH, name + ".docket.json")
    json.dump(d, open(p, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    return p


def js_mint(req):
    r = subprocess.run(["node", os.path.join(_HERE, "codec", "mint_check.mjs")],
                       input=json.dumps(req, ensure_ascii=False), capture_output=True,
                       text=True, encoding="utf-8")
    if r.returncode != 0:
        raise RuntimeError("mint_check failed:\n" + r.stderr[:500])
    return r.stdout.strip()


def compare(lane, machine_string, js_string):
    m = norm(wc.decode_import_string_raw(machine_string))
    j = norm(wc.decode_import_string_raw(js_string))
    m.pop("s", None); j.pop("s", None)   # each road names itself
    if m == j:
        print(f"  {lane:12s} CLEAN (machine == mint, decode-equivalent)")
        return True
    print(f"  {lane:12s} MISMATCH")
    for k in sorted(set(m) | set(j)):
        if m.get(k) != j.get(k):
            print(f"    key {k!r}: machine {json.dumps(m.get(k))[:160]}")
            print(f"    key {k!r}: mint    {json.dumps(j.get(k))[:160]}")
    return False


def main():
    ref_group, ref_member = pt.reference_dockets()
    ok = True

    # ---- dot_target (appear): one member, fixed identities on both roads
    g = copy.deepcopy(ref_group); g["id"] = "HARNESS dt"; g["uid"] = "harnessGrp01"
    a = copy.deepcopy(ref_member); a["id"] = "Blight"; a["uid"] = "harnessMem01"
    machine = bundlemod.bundle({"group": g, "children": [write_docket(a, "dt_a")]})
    js = js_mint({"templates": TEMPLATES, "lane": "dot_target", "classToken": "NECROMANCER",
                  "specName": "Death", "scope": "target",
                  "picks": [{"family": "Blight", "repId": "500217"}], "fragment": "appear",
                  "groupName": "HARNESS dt", "uids": ["harnessMem01", "harnessGrp01"]})
    ok &= compare("dot_target", machine, js)

    # ---- pet: the proven shape, fixed identities
    pg = pt.corpus_docket("Pet_health_test"); pg["id"] = "HARNESS pet"; pg["uid"] = "harnessGrp02"
    pm = pt.corpus_docket("Pet_health_spawner"); pm["id"] = "Death - guardian health"; pm["uid"] = "harnessMem02"
    machine = bundlemod.bundle({"group": pg, "children": [write_docket(pm, "pet_m")]})
    js = js_mint({"templates": TEMPLATES, "lane": "pet", "classToken": "NECROMANCER",
                  "specName": "Death", "scope": None, "picks": [], "fragment": None,
                  "groupName": "HARNESS pet", "uids": ["harnessMem02", "harnessGrp02"]})
    ok &= compare("pet", machine, js)

    print("\nmint harness:", "ALL CLEAN" if ok else "FAILURES")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
