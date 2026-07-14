"""
build_tables.py - split the data into per class:spec TABLES, local to creator (creator/planning/tables/).

Decomposes coa_spells.json into one table per class:spec slice: the slice's spells (fingerprint + in-slice centrality),
its web (edges), its hub (the mechanic candidate), and a crude shape hint (proc/flat vs summon/state). The creator works
from these sliced tables, not the global pool. Reuses the graph from spell_graph.py.

  py build_tables.py    -> tables/<CLASS>/<SPEC>.json per slice + tables/_index.json  (a visibility method)
"""
import json
import os
from collections import Counter
from spell_graph import build, slice_edges, _safe, COA

_THIS = os.path.dirname(os.path.abspath(__file__))
TABLES = os.path.join(_THIS, "tables")


def _passive(attr):
    return bool(attr & 0x40) if isinstance(attr, int) else None       # DBC attr bit 0x40 = passive


def slice_table(d, cls, spec, edges):
    indeg = Counter(v for u, v, _ in edges)
    nodes = set(n for u, v, _ in edges for n in (u, v))
    hub_id, hub_in = indeg.most_common(1)[0] if indeg else (None, 0)
    # crude shape hint (a first pass, to refine): a resource/proc hub CONVERGES (high in-degree);
    # a summon/state hub fans OUT (low in-degree despite a busy web) -> the custom/hard bucket.
    if hub_in >= 5:
        shape = "proc/resource (flat)"
    elif len(edges) >= 10 and hub_in <= 2:
        shape = "summon/state (custom?)"
    else:
        shape = "mixed/small"
    spells = [{"id": n, "name": d.get(n, {}).get("name"), "in_degree": indeg.get(n, 0),
               "cooldownMs": d.get(n, {}).get("cooldownMs"), "gcdMs": d.get(n, {}).get("gcdMs"),
               "manaCost": d.get(n, {}).get("manaCost"), "durationMs": d.get(n, {}).get("durationMs"),
               "powerType": d.get(n, {}).get("powerType"), "passive": _passive(d.get(n, {}).get("attr"))}
              for n in sorted(nodes, key=lambda s: indeg.get(s, 0), reverse=True)]
    return {"class": cls, "spec": spec,
            "hub": {"id": hub_id, "name": d.get(hub_id, {}).get("name"), "in_degree": hub_in},
            "shape_hint": shape, "spell_count": len(nodes), "edge_count": len(edges),
            "spells": spells,
            "edges": [{"src": u, "dst": v, "ability": dat.get("ability")} for u, v, dat in edges]}


def main():
    d = json.load(open(COA, encoding="utf-8"))
    sl = slice_edges(build(d))
    os.makedirs(TABLES, exist_ok=True)
    index = []
    for (cls, spec), edges in sl.items():
        t = slice_table(d, cls, spec, edges)
        cdir = os.path.join(TABLES, _safe(cls))
        os.makedirs(cdir, exist_ok=True)
        with open(os.path.join(cdir, "%s.json" % _safe(spec)), "w", encoding="utf-8") as f:
            json.dump(t, f, ensure_ascii=False, indent=1)
        index.append({"class": cls, "spec": spec, "hub": t["hub"]["name"],
                      "shape": t["shape_hint"], "spells": t["spell_count"], "edges": t["edge_count"]})
    with open(os.path.join(TABLES, "_index.json"), "w", encoding="utf-8") as f:
        json.dump(sorted(index, key=lambda x: (x["class"], x["spec"])), f, ensure_ascii=False, indent=1)
    print("%d class:spec tables -> tables/<CLASS>/<SPEC>.json  (+ tables/_index.json)" % len(sl))


if __name__ == "__main__":
    main()
