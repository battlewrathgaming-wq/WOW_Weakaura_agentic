"""
spell_graph.py - PROTOTYPE (creator/planning/, incubating; graduates to creator/ when it proves out).

The lean stack from research.md: networkx (analysis) + pyvis (viz). No graph DB - 9,152 nodes is small.
Builds the TYPED spell graph from coa_spells.json, scores centrality, VALIDATES that the high-centrality hubs
ARE the class mechanics, and emits a per-class pyvis web to INSPECT.

  py spell_graph.py    -> per-class top-hub validation report + out/<CLASS>.html per class
"""
import json
import os
from collections import Counter
import networkx as nx
from pyvis.network import Network

_THIS = os.path.dirname(os.path.abspath(__file__))
COA = os.path.join(_THIS, "..", "..", "dependencies", "coa_spells.json")   # read location (constant)
OUT = os.path.join(_THIS, "out")


def build(d):
    """typed DiGraph. node = spell (name + fingerprint); edge = via -> spell, rel='triggered', tagged cls/ability."""
    G = nx.DiGraph()
    for sid, s in d.items():
        G.add_node(sid, name=(s.get("name") or sid), cooldownMs=s.get("cooldownMs") or 0)
    for sid, s in d.items():
        for tb in ((s.get("coa") or {}).get("triggeredBy") or []):
            via = str(tb.get("via") or "")
            if via and via in G and via != sid:
                G.add_edge(via, sid, rel="triggered", cls=tb.get("class"), ability=tb.get("ability"))
    return G


def dominant_class(G, sid):
    """the class that most-triggers this node (its home, from inbound edges)."""
    c = Counter(dat.get("cls") for _, _, dat in G.in_edges(sid, data=True) if dat.get("cls"))
    return c.most_common(1)[0][0] if c else None


def emit_class(G, cls, indeg, cap=80):
    """a pyvis web of class `cls`'s trigger-graph (edges tagged cls); node size ~ in-degree. Returns node count."""
    edges = [(u, v, dat) for u, v, dat in G.edges(data=True) if dat.get("cls") == cls]
    if not edges:
        return 0
    nodes = set(n for u, v, _ in edges for n in (u, v))
    if len(nodes) > cap:                                       # keep the busiest, for inspectability
        nodes = set(sorted(nodes, key=lambda s: indeg.get(s, 0), reverse=True)[:cap])
        edges = [(u, v, dat) for u, v, dat in edges if u in nodes and v in nodes]
    net = Network(height="820px", width="100%", directed=True, bgcolor="#1b1b1b", font_color="#dddddd")
    for n in nodes:
        net.add_node(n, label=(G.nodes[n]["name"] or n)[:22], value=indeg.get(n, 0) + 1,
                     title="%s  (in=%d)" % (G.nodes[n]["name"], indeg.get(n, 0)))
    for u, v, dat in edges:
        net.add_edge(u, v, title=dat.get("ability") or "")
    net.write_html(os.path.join(OUT, "%s.html" % cls))
    return len(nodes)


def main():
    d = json.load(open(COA, encoding="utf-8"))
    G = build(d)
    print("graph: %d nodes, %d typed edges (rel=triggered)" % (G.number_of_nodes(), G.number_of_edges()))

    indeg = dict(G.in_degree())
    pr = nx.pagerank(G)
    prrank = {sid: i for i, sid in enumerate(sorted(pr, key=pr.get, reverse=True), 1)}

    by_class = {}
    for sid in G:
        if indeg.get(sid, 0) > 0:
            c = dominant_class(G, sid)
            if c:
                by_class.setdefault(c, []).append(sid)

    print("\nper-class TOP HUB by in-degree (= the mechanic candidate)  [pr# = pagerank rank]:")
    for c in sorted(by_class):
        top = max(by_class[c], key=lambda s: (indeg[s], pr.get(s, 0)))
        print("  %-14s %-26s in=%-3d  pr#%d" % (c, (G.nodes[top]["name"] or "?")[:26], indeg[top], prrank.get(top, 0)))

    os.makedirs(OUT, exist_ok=True)
    n = sum(1 for c in sorted(by_class) if emit_class(G, c, indeg))
    print("\n%d class webs -> %s/<CLASS>.html  (open in a browser to inspect)" % (n, os.path.relpath(OUT, _THIS)))


if __name__ == "__main__":
    main()
