"""
ground_index.py - join the resolved value-domains onto the index levers.

The extractor already resolved every value-domain into value_domains.json (159 of them),
but the flat lever list in index.json only references domains by NAME. This joins them:
each lever's `values` becomes the actual {code: label} dict when resolvable, tagged with
its provenance. Non-destructive: writes index_grounded.json (index.json stays the raw
extract).

The residue - domains value_domains.json can't hold - are the ones WA builds at RUNTIME
from the live client (class/spec/form/race enumerations). A static source-read can't
produce those by nature; the COA-custom ones (class/spec/form) are sourced from our own
class inventory instead.

    py ground_index.py
"""
import json
import os
import sys
from collections import Counter

sys.stdout.reconfigure(encoding="utf-8")
_THIS = os.path.dirname(os.path.abspath(__file__))

# runtime/client-built domains that a static source-read cannot resolve. The COA-custom
# ones are sourced from the class inventory, not WA.
_INVENTORY_SOURCED = {"class_types", "specialization_types", "spec_types_all", "form_types"}


def main():
    idx = json.load(open(os.path.join(_THIS, "index.json"), encoding="utf-8"))
    vd = json.load(open(os.path.join(_THIS, "value_domains.json"), encoding="utf-8"))

    stats = Counter()
    runtime = Counter()          # unresolved domain -> lever count
    grounded = []
    for e in idx:
        e = dict(e)
        v = e.get("values")
        if isinstance(v, dict):
            e["values_source"] = "inline"          # already resolved in the extract
            stats["inline"] += 1
        elif isinstance(v, str):
            e["values_domain"] = v
            if v in vd:
                e["values"] = vd[v]
                e["values_source"] = "joined"
                stats["joined"] += 1
            else:
                e["values"] = None
                e["values_source"] = "function" if v == "<function>" else \
                    ("inventory" if v in _INVENTORY_SOURCED else "runtime")
                stats[e["values_source"]] += 1
                runtime[v] += 1
        else:
            e["values_source"] = None
            stats["no_domain"] += 1
        grounded.append(e)

    out = os.path.join(_THIS, "index_grounded.json")
    json.dump(grounded, open(out, "w", encoding="utf-8"), indent=1, ensure_ascii=False)

    resolved = stats["inline"] + stats["joined"]
    print(f"grounded {len(grounded)} levers | dropdowns resolved: {resolved} "
          f"(inline {stats['inline']} + joined {stats['joined']})")
    print(f"unresolved (runtime-built, static source can't produce): "
          f"{stats['runtime'] + stats['inventory'] + stats['function']} levers across "
          f"{len(runtime)} domains:")
    for dom, n in runtime.most_common():
        tag = "  <- INVENTORY-sourced (COA custom)" if dom in _INVENTORY_SOURCED else \
              ("  <- runtime function" if dom == "<function>" else "  <- client runtime")
        print(f"    x{n:<3} {dom}{tag}")
    json.dump({"unresolved_domains": dict(runtime),
               "inventory_sourced": sorted(_INVENTORY_SOURCED)},
              open(os.path.join(_THIS, "index_runtime_residue.json"), "w", encoding="utf-8"),
              indent=1, ensure_ascii=False)
    print(f"\nwrote index_grounded.json + index_runtime_residue.json")


if __name__ == "__main__":
    main()
