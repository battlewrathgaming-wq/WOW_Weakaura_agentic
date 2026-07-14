# research — prior art for the classification tool

_Incubating in `creator/planning/`. First pass 2026-07-14. Borrow proven tools; don't reinvent. When this direction is
proven, the tool it describes graduates into `creator/`._

## Thread 1 — traffic / centrality: SOLVED by NetworkX (import, don't build)

Our "traffic = connectivity" is textbook **graph centrality**, and **NetworkX** (Python — stays in our lane) is the
mature tool:
- `nx.degree_centrality(G)` — direct connections = hubs. This IS our current in-degree traffic, normalized.
- `nx.pagerank(G)` — influence propagation: a spell is central if *central* spells point at it. This **refines** traffic —
  it separates a true mechanic hub from a spell merely referenced by many *minor* abilities.
- `nx.betweenness_centrality(G)` — control over flow; would surface "bridge" abilities that link sub-systems.

Takeaway: we do not write centrality. We build the graph (from `coa.triggeredBy` + the effect edges) and let NetworkX
score it. degree = traffic · PageRank = weighted importance · betweenness = bridges.

## Thread 2 — our problem IS link analysis (OSINT confirms the pattern)

OSINT link-analysis (Maltego, SpiderFoot, the Aleph project) is exactly our shape: **entities (nodes) + relationships
(edges), find the patterns / hubs.** The tools are domain-specific (threat intel), so NOT directly reusable — but two
things transfer:
- the **entity-relationship graph** model (which = NetworkX), and
- the value of **visualization** — a human *seeing* how a class plays, as a graph. Worth a viz layer (pyvis / graphviz)
  for the "state readout," alongside the machine-readable slices.

## Thread 3 — right-size the tooling (the valuable NEGATIVE finding)

The "feature store / signal-fusion" search skewed academic + ML-heavy (CNN/transformer fusion for EEG, radar, etc.).
That path is **overkill for us.** We are NOT classifying from raw signals with deep learning — we have a *clean
fingerprint* + an *already-materialized graph*. Our tool is **NetworkX (graph) + simple rules (bucketing) + a viz**, not
an ML platform or a feature store. The research's real service here was steering us **away** from over-engineering.

## Where it leads (the lean direction)

The classification tool =
1. **NetworkX graph analysis** — build from `coa.triggeredBy` + effect edges → centrality for traffic → traverse for
   cross-links (the proc→cooldown-refresh derivation).
2. **rule-based bucketing** — from the fingerprint (`cooldownMs`/`gcdMs`/`manaCost`/`durationMs`/`procFlags`): CD ·
   stack builder-spender · buff · resource.
3. **triage** — clear (auto-generate) vs hard (reason: the scaffolds, the state-carrying).
4. **optional viz** — borrow the OSINT link-analysis visual for human inspection of a class's web.

Storage: an **edge-list + node-features** (json/parquet), NetworkX in-memory. **No graph DB** — 9,152 nodes is small.

## GitHub / tools to pull when we build
- **NetworkX** — the core (centrality, traversal).
- **pyvis / graphviz** — the class-web viz (the borrowed link-analysis visual).
- (inspiration, not direct use) **Aleph / SpiderFoot** — how link-analysis platforms structure entity graphs.

## GitHub launch points (searched 2026-07-14)

Honest finding: **the launch point is the library STACK, not a project to fork.** Stripped down, our tool is small
(edge-list → networkx centrality → rule-bucket → optional pyvis viz), so there's no heavyweight base worth inheriting.
- **The stack:** `networkx` (analysis: centrality + traversal — the hard part, solved) + `pyvis` + `streamlit` (the
  interactive class-web viz). All mature, permissively licensed.
- **Thin reference apps** (pattern reference for the viz wiring, ~200 lines each — don't fork):
  `kennethleungty/Pyvis-Network-Graph-Streamlit` (cleaner, known author) · `ahmadazakaria/stream-graph-viz` (minimal
  Streamlit+networkx+pyvis, loads edge-lists/JSON, but VIZ-ONLY, **license not stated + unmaintained** → pattern only).
- **Skip:** KG builders (`llmgraph`, `knowledge_graph_maker`, `graphiti`) = LLM/text→graph, WRONG shape (our data is
  already a structured graph). RPG-stat NN classifiers = the ML-overkill path (confirmed twice).
- **Design pointer** (from "typed skill graphs" / SkillDAG): the edge TYPE is part of the semantics — proc / refresh /
  buff / modify are distinct relations. Build a **typed** graph (networkx edge attributes), not a plain one.

## Where it leads (updated)

No base to fork → the tool is small → **prototype it on the stack.** Build the *typed* graph from `coa_spells.json`
(`coa.triggeredBy` + effect edges) on networkx, run `pagerank` / `degree`, and **eyeball whether centrality lines up
with the mechanics** — a cheap validation on data we already own. Add a pyvis/streamlit viz to *see* a class's web. That
first prototype incubates here; it graduates into `creator/` when it proves out.

## Sources
- NetworkX centrality — GeeksforGeeks, Bomberbot, python-fiddle tutorials.
- OSINT link analysis — Maltego (Medium/HN), SpiderFoot, the Aleph project.
- Signal fusion (the overkill path) — arXiv / ScienceDirect multi-feature-fusion papers.
