"""
spell_graph.py - PROTOTYPE (creator/planning/, incubating; graduates to creator/ when it proves out).

networkx + pyvis on coa_spells.json. Builds the typed trigger-graph, then SLICES the insight per CLASS:SPEC - not the
total pool. A class plays differently per spec, auras load per class:spec, and the mechanic is really a *spec's* hub.
Each slice's top-centrality node = that spec's mechanic candidate. Emits a per-slice pyvis web to inspect.

  py spell_graph.py    -> per class:spec top-hub readout + out/<CLASS>/<SPEC>.html per slice
"""
import json
import os
import re
from collections import Counter, defaultdict
import networkx as nx
from pyvis.network import Network

_THIS = os.path.dirname(os.path.abspath(__file__))
COA = os.path.join(_THIS, "..", "..", "dependencies", "coa_spells.json")   # read location (constant)
OUT = os.path.join(_THIS, "out")


def build(d):
    """typed DiGraph. node = spell; edge = via -> spell, rel='triggered', tagged cls/spec/ability (the slice keys)."""
    G = nx.DiGraph()
    for sid, s in d.items():
        G.add_node(sid, name=(s.get("name") or sid))
    for sid, s in d.items():
        for tb in ((s.get("coa") or {}).get("triggeredBy") or []):
            via = str(tb.get("via") or "")
            if via and via in G and via != sid:
                G.add_edge(via, sid, rel="triggered", cls=tb.get("class"), spec=tb.get("spec"), ability=tb.get("ability"))
    return G


def slice_edges(G):
    """edges grouped by (class, spec) - each is a spec's own sub-web. Insight is per slice, not the total pool."""
    sl = defaultdict(list)
    for u, v, dat in G.edges(data=True):
        if dat.get("cls"):
            sl[(dat["cls"], dat.get("spec") or "-")].append((u, v, dat))
    return sl


def _safe(s):
    return re.sub(r"[^A-Za-z0-9]+", "_", str(s)).strip("_") or "x"


def emit(G, cls, spec, edges, cap=70):
    """a pyvis web of one class:spec slice; node size ~ in-slice in-degree."""
    indeg = Counter(v for u, v, _ in edges)
    nodes = set(n for u, v, _ in edges for n in (u, v))
    if len(nodes) > cap:
        nodes = set(sorted(nodes, key=lambda s: indeg.get(s, 0), reverse=True)[:cap])
        edges = [(u, v, dat) for u, v, dat in edges if u in nodes and v in nodes]
    net = Network(height="820px", width="100%", directed=True, bgcolor="#1b1b1b", font_color="#dddddd")
    for n in nodes:
        net.add_node(n, label=(G.nodes[n]["name"] or n)[:22], value=indeg.get(n, 0) + 1,
                     title="%s  (in=%d)" % (G.nodes[n]["name"], indeg.get(n, 0)))
    for u, v, dat in edges:
        net.add_edge(u, v, title=dat.get("ability") or "")
    cdir = os.path.join(OUT, _safe(cls))
    os.makedirs(cdir, exist_ok=True)
    net.write_html(os.path.join(cdir, "%s.html" % _safe(spec)))


def main():
    d = json.load(open(COA, encoding="utf-8"))
    G = build(d)
    print("graph: %d nodes, %d typed edges (rel=triggered)" % (G.number_of_nodes(), G.number_of_edges()))
    sl = slice_edges(G)

    by_class = defaultdict(list)
    for (c, sp), edges in sl.items():
        by_class[c].append((sp, edges))

    print("\nSLICED INSIGHTS - per class:spec top hub (the spec's mechanic candidate):")
    for c in sorted(by_class):
        print("\n%s" % c)
        for sp, edges in sorted(by_class[c], key=lambda x: -len(x[1])):        # biggest web first
            indeg = Counter(v for u, v, _ in edges)
            node, ind = indeg.most_common(1)[0]
            print("  * %-16s %-24s in=%-3d (%d edges)" % (sp, (G.nodes[node]["name"] or "?")[:24], ind, len(edges)))

    os.makedirs(OUT, exist_ok=True)
    for (c, sp), edges in sl.items():
        emit(G, c, sp, edges)
    print("\n%d class:spec slices -> out/<CLASS>/<SPEC>.html" % len(sl))


if __name__ == "__main__":
    main()
