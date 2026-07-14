"""
taxonomy.py - the keyword taxonomy: catalog the domain's key TERMS for visibility (Battlewrath's "taxonomy of keywords").

Mounts the vocabulary from coa_spells.json + the graph so we can SEE the terms instead of re-reading the pool:
  - classes + their specs (the structural vocabulary)
  - mechanic hubs per class:spec (the mechanic-name vocabulary)
  - power types (the resource vocabulary) · mechanic-field values (CC/mechanic types) · effect-code presence
Codes stay as codes for now (powerType/mechanic/effect are DBC enums); mapping code->name is a later pass.

  py taxonomy.py    -> taxonomy.json  (a visibility method)
"""
import json
import os
from collections import Counter, defaultdict
from spell_graph import build, slice_edges, COA

_THIS = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(_THIS, "taxonomy.json")


def _as_list(v):
    return v if isinstance(v, list) else ([v] if v else [])


def main():
    d = json.load(open(COA, encoding="utf-8"))
    sl = slice_edges(build(d))

    specs = defaultdict(set)
    hubs = {}
    for (c, sp), edges in sl.items():
        specs[c].add(sp)
        indeg = Counter(v for u, v, _ in edges)
        if indeg:
            hub = indeg.most_common(1)[0][0]
            hubs["%s:%s" % (c, sp)] = d.get(hub, {}).get("name")

    powertypes = Counter(s.get("powerType") for s in d.values() if s.get("powerType") is not None)
    mechanics = Counter(s.get("mechanic") for s in d.values() if s.get("mechanic"))
    effects = Counter(e for s in d.values() for e in _as_list(s.get("effect")) if e)

    classes = sorted(specs)
    tax = {
        "_meta": "keyword taxonomy - the domain vocabulary, mounted for visibility. Codes are DBC enums (name-map = later pass).",
        "classes": classes,
        "specs": {c: sorted(specs[c]) for c in classes},
        "mechanic_hubs": dict(sorted(hubs.items())),        # class:spec -> mechanic candidate name
        "power_types": powertypes.most_common(),            # resource vocabulary (enum code, count)
        "mechanic_types": mechanics.most_common(),          # CC/mechanic field vocabulary (enum code, count)
        "effect_codes_top20": effects.most_common(20),      # effect vocabulary (enum code, count)
    }
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(tax, f, ensure_ascii=False, indent=1)
    print("taxonomy.json: %d classes | %d class:spec hubs | %d powerTypes | %d mechanic-types | %d effect-codes"
          % (len(classes), len(hubs), len(powertypes), len(mechanics), len(effects)))


if __name__ == "__main__":
    main()
