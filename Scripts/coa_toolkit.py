"""
coa_toolkit.py - Analysis toolkit for Conquest of Azeroth (Ascension) CoA Builder talent data.

Loads the per-class JSON files produced from the ascension.gg CoA Builder and provides:

  - Graph construction over the OR-logic prerequisite structure
  - A legal-build validator (budget caps, row/essence gating, OR-prereqs, partial ranks)
  - Structural analysis: hub nodes (win-condition candidates) and capstones (terminal payoffs)
  - A cross-reference graph built from in-tooltip named callouts (referencedTerms)
  - A build coherence report: connectivity, filler ratio, thematic overlap, capstone alignment

This is a stats/structure tool, not a DPS simulator - it is meant to help judge whether a
chosen set of talents reads as ONE compounding build or a scatter of unrelated picks.

Usage:
    python3 coa_toolkit.py bloodmage_talents.json --tree Sanguine --list
    python3 coa_toolkit.py bloodmage_talents.json --tree Sanguine --hubs
    python3 coa_toolkit.py bloodmage_talents.json --tree Sanguine --capstones
    python3 coa_toolkit.py bloodmage_talents.json --tree Sanguine --path "Nightmare"
    python3 coa_toolkit.py bloodmage_talents.json --tree Sanguine --validate build.json
    python3 coa_toolkit.py bloodmage_talents.json --tree Sanguine --coherence build.json

Or import as a module:
    from coa_toolkit import ClassData
    cd = ClassData.load("bloodmage_talents.json")
    tree = cd.tree("Sanguine")
    print(tree.hubs())
    print(tree.coherence_report({"Nightmare": 1, "Everhungry": 1, ...}))
"""

from __future__ import annotations
import json
import sys
import argparse
from dataclasses import dataclass, field
from collections import defaultdict, deque


# ---------------------------------------------------------------------------
# Data loading
# ---------------------------------------------------------------------------

@dataclass
class ClassData:
    raw: dict

    @classmethod
    def load(cls, path: str) -> "ClassData":
        with open(path, "r", encoding="utf-8") as f:
            return cls(json.load(f))

    @property
    def class_name(self) -> str:
        return self.raw["class"]

    @property
    def budget(self) -> dict:
        return self.raw.get("budget", {"abilityEssence": 26, "talentEssence": 25})

    def tree_names(self) -> list[str]:
        return self.raw["trees"]

    def tree(self, name: str) -> "TalentTree":
        nodes = [t for t in self.raw["talents"] if t["tree"] == name]
        if not nodes:
            raise ValueError(
                f"No tree named {name!r} in {self.class_name}. "
                f"Available: {self.tree_names()}"
            )
        currency = "abilityEssence" if name == "Class" else "talentEssence"
        cap = self.budget["abilityEssence"] if currency == "abilityEssence" else self.budget["talentEssence"]
        return TalentTree(class_name=self.class_name, name=name, nodes=nodes,
                           currency=currency, budget_cap=cap)


# ---------------------------------------------------------------------------
# Tree graph + queries
# ---------------------------------------------------------------------------

@dataclass
class TalentTree:
    class_name: str
    name: str
    nodes: list  # list of talent dicts
    currency: str  # "abilityEssence" | "talentEssence"
    budget_cap: int

    def __post_init__(self):
        self.by_name = {n["name"]: n for n in self.nodes}
        # fan_in[X] = names of nodes that list X as one of their OR-prerequisites
        self.fan_in = defaultdict(list)
        for n in self.nodes:
            for p in n["prerequisites"]:
                self.fan_in[p].append(n["name"])

    def cost(self, node: dict) -> int:
        return node["abilityEssenceCost"] if self.currency == "abilityEssence" else node["talentEssenceCost"]

    def req_threshold(self, node: dict) -> int:
        return node["reqTreeAbilityEssence"] if self.currency == "abilityEssence" else node["reqTreeTalentEssence"]

    # -- structural analysis -------------------------------------------------

    def hubs(self, top_n: int = 10) -> list[tuple[str, int]]:
        """Nodes most depended-upon by others (candidate win-condition / keystone talents)."""
        scored = [(name, len(deps)) for name, deps in self.fan_in.items()]
        scored.sort(key=lambda x: -x[1])
        return scored[:top_n]

    def capstones(self) -> list[str]:
        """Terminal nodes: nothing lists them as a prerequisite, and they sit in the deepest rows."""
        max_y = max(n["y"] for n in self.nodes)
        return [n["name"] for n in self.nodes
                if n["y"] >= max_y - 1 and n["name"] not in self.fan_in]

    def entry_points(self) -> list[str]:
        """Nodes with no OR-prerequisite at all - valid first picks."""
        return [n["name"] for n in self.nodes if not n["prerequisites"]]

    def shortest_legal_path(self, target: str) -> list[str] | None:
        """
        Minimum-node path of picks that legally unlocks `target`, ignoring essence-threshold
        gating (which is a cumulative-points check, not a specific-node check) but respecting
        OR-prerequisite connectivity. This is the "minimum filler" answer: the fewest picks
        you technically need connected before you can take the target node.
        """
        if target not in self.by_name:
            return None
        # BFS backwards over "requires one of" edges, picking the cheapest branch at each hop
        seen = {target}
        queue = deque([[target]])
        while queue:
            path = queue.popleft()
            head = path[-1]
            prereqs = self.by_name[head]["prerequisites"]
            if not prereqs:
                return list(reversed(path))
            # pick the OR-branch with the lowest cost to reach an entry point (cheapest first)
            cheapest = min(prereqs, key=lambda p: self.cost(self.by_name[p]) if p in self.by_name else 999)
            if cheapest in seen:
                return list(reversed(path))
            seen.add(cheapest)
            queue.append(path + [cheapest])
        return list(reversed(path))

    # -- cross-reference / synergy graph -------------------------------------

    def reference_graph(self) -> dict[str, set[str]]:
        """
        Maps node name -> set of OTHER node names in this tree that it explicitly namedrops
        in its tooltip (via referencedTerms). This captures functional synergy that the
        prerequisite graph doesn't (e.g. two talents that both modify the same buff, even if
        one isn't structurally required by the other).
        """
        names = set(self.by_name)
        graph = defaultdict(set)
        for n in self.nodes:
            for term in n.get("referencedTerms", []):
                if term in names and term != n["name"]:
                    graph[n["name"]].add(term)
        return dict(graph)

    # -- build validation ------------------------------------------------------

    def validate_build(self, picks: dict[str, int]) -> dict:
        """
        picks: {talent_name: rank_invested}
        Returns a report: {valid: bool, errors: [...], spent: int, remaining: int}
        Checks: node exists, rank <= maxPoints, budget cap, OR-prerequisite connectivity
        (>=1 point in >=1 listed prerequisite, or the node has no prerequisite), and row/essence
        gating (cumulative spend in this tree >= node's reqTreeEssence threshold BEFORE this pick).
        """
        errors = []
        # order picks by (y, x) so we can validate row-gating progressively, matching how
        # points are actually spent in-game
        ordered = sorted(picks.items(), key=lambda kv: (self.by_name[kv[0]]["y"], self.by_name[kv[0]]["x"])
                          if kv[0] in self.by_name else (999, 999))

        spent_so_far = 0
        invested = set()
        for name, rank in ordered:
            node = self.by_name.get(name)
            if node is None:
                errors.append(f"'{name}' is not a node in {self.name}")
                continue
            if rank < 1 or rank > (node["maxPoints"] or 1):
                errors.append(f"'{name}': rank {rank} invalid (maxPoints={node['maxPoints']})")
                continue
            threshold = self.req_threshold(node)
            if spent_so_far < threshold:
                errors.append(
                    f"'{name}': needs {threshold} {self.currency} already spent in {self.name} "
                    f"before this pick, only {spent_so_far} spent so far"
                )
            if node["prerequisites"]:
                if not any(p in invested for p in node["prerequisites"]):
                    errors.append(
                        f"'{name}': requires 1 point in one of {node['prerequisites']} (OR) - none invested"
                    )
            if node["specialRequirement"]:
                missing = [p for p in node["specialRequirement"] if p not in invested]
                if missing:
                    errors.append(f"'{name}': special requirement not met, missing {missing} (AND)")
            spent_so_far += self.cost(node) * rank
            invested.add(name)

        if spent_so_far > self.budget_cap:
            errors.append(f"Total spend {spent_so_far} exceeds {self.currency} budget of {self.budget_cap}")

        return {
            "valid": len(errors) == 0,
            "errors": errors,
            "spent": spent_so_far,
            "remaining": self.budget_cap - spent_so_far,
            "currency": self.currency,
        }

    # -- coherence report --------------------------------------------------

    def coherence_report(self, picks: dict[str, int]) -> dict:
        """
        Heuristic build-coherence analysis. Not a power score - a structure/synergy score.
        Combines:
          - connectivity: how many disconnected islands the picks form (fewer = more coherent)
          - filler_ratio: fraction of picks that exist ONLY to satisfy essence thresholds
            (a "filler" here is a pick with no prerequisite/synergy link to any other pick and
            isn't a hub/capstone itself)
          - synergy_density: fraction of possible pairs among your picks connected via
            referencedTerms callouts
          - capstone_alignment: does the build actually reach a capstone, and how many
            picks lie on the direct prerequisite chain to it vs off to the side
          - theme_keywords: most repeated referencedTerms across your picks (the recurring
            "nouns" your build keeps coming back to)
        """
        picked = set(picks)
        valid_names = {p for p in picked if p in self.by_name}

        # 1. structural connectivity among picks (edges = prerequisite OR reference link)
        adj = defaultdict(set)
        for name in valid_names:
            node = self.by_name[name]
            for p in node["prerequisites"]:
                if p in valid_names:
                    adj[name].add(p)
                    adj[p].add(name)
        ref_graph = self.reference_graph()
        for name in valid_names:
            for other in ref_graph.get(name, ()):
                if other in valid_names:
                    adj[name].add(other)
                    adj[other].add(name)

        seen = set()
        components = []
        for name in valid_names:
            if name in seen:
                continue
            stack = [name]
            comp = set()
            while stack:
                cur = stack.pop()
                if cur in comp:
                    continue
                comp.add(cur)
                stack.extend(adj[cur] - comp)
            seen |= comp
            components.append(comp)

        # 2. filler picks: isolated (no structural/synergy edge to any other pick) AND not a hub/capstone
        hub_names = {n for n, _ in self.hubs(top_n=999) if self.fan_in.get(n)}
        capstone_names = set(self.capstones())
        filler = [n for n in valid_names
                  if len(adj[n]) == 0 and n not in hub_names and n not in capstone_names]

        # 3. synergy density among picks
        n_picks = len(valid_names)
        possible_pairs = n_picks * (n_picks - 1) / 2 if n_picks > 1 else 1
        actual_edges = sum(len(v) for v in adj.values()) / 2
        synergy_density = round(actual_edges / possible_pairs, 3) if possible_pairs else 0.0

        # 4. capstone alignment
        reached_capstones = [c for c in capstone_names if c in valid_names]
        on_chain = set()
        for cap in reached_capstones:
            chain = self.shortest_legal_path(cap) or []
            on_chain |= set(chain)
        off_chain = valid_names - on_chain if reached_capstones else valid_names

        # 5. recurring themes
        term_counts = defaultdict(int)
        for name in valid_names:
            for term in self.by_name[name].get("referencedTerms", []):
                term_counts[term] += 1
        recurring_themes = sorted(
            [(t, c) for t, c in term_counts.items() if c > 1], key=lambda x: -x[1]
        )

        return {
            "class": self.class_name,
            "tree": self.name,
            "picks": n_picks,
            "connected_components": len(components),
            "largest_component_fraction": round(max((len(c) for c in components), default=0) / n_picks, 2) if n_picks else 0,
            "filler_picks": sorted(filler),
            "filler_ratio": round(len(filler) / n_picks, 2) if n_picks else 0,
            "synergy_density": synergy_density,
            "reached_capstones": sorted(reached_capstones),
            "picks_off_main_chain": sorted(off_chain) if reached_capstones else "no capstone reached yet",
            "recurring_themes": recurring_themes[:10],
            "read": self._coherence_reading(len(components), len(filler) / n_picks if n_picks else 0, synergy_density, bool(reached_capstones)),
        }

    @staticmethod
    def _coherence_reading(n_components: int, filler_ratio: float, synergy_density: float, has_capstone: bool) -> str:
        if n_components == 1 and filler_ratio < 0.25 and has_capstone:
            return "Coherent: build forms one connected structure funneling into a capstone with little dead weight."
        if n_components > 1:
            return f"Scattered: picks form {n_components} disconnected clusters - consider cutting one cluster and reinforcing the other."
        if filler_ratio >= 0.4:
            return "Toll-heavy: a large share of picks exist only to hit essence thresholds, not to reinforce the build's function."
        if not has_capstone:
            return "Unresolved: no capstone reached yet - the build hasn't committed to a payoff."
        return "Mixed: mostly connected but with some loose threads - see filler_picks and picks_off_main_chain."


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser(description="Query and analyze CoA Builder talent JSON.")
    ap.add_argument("file", help="Path to a class talent JSON file")
    ap.add_argument("--tree", required=True, help="Tree name, e.g. Sanguine or Class")
    ap.add_argument("--list", action="store_true", help="List all nodes in the tree")
    ap.add_argument("--hubs", action="store_true", help="Show most-depended-upon nodes")
    ap.add_argument("--capstones", action="store_true", help="Show terminal/payoff nodes")
    ap.add_argument("--entry-points", action="store_true", help="Show nodes with no prerequisite")
    ap.add_argument("--path", metavar="NODE", help="Show minimum-filler path to a node")
    ap.add_argument("--validate", metavar="BUILD_JSON", help="Path to {name: rank} JSON to validate")
    ap.add_argument("--coherence", metavar="BUILD_JSON", help="Path to {name: rank} JSON to score for coherence")
    args = ap.parse_args()

    cd = ClassData.load(args.file)
    tree = cd.tree(args.tree)

    if args.list:
        for n in sorted(tree.nodes, key=lambda n: (n["y"], n["x"])):
            print(f"y={n['y']:<3} {n['name']:<40} cost={tree.cost(n)} maxPts={n['maxPoints']} "
                  f"prereq={n['prerequisites']}")

    if args.hubs:
        for name, count in tree.hubs():
            print(f"{name:<40} depended on by {count} node(s)")

    if args.capstones:
        for name in tree.capstones():
            print(name)

    if args.entry_points:
        for name in tree.entry_points():
            print(name)

    if args.path:
        path = tree.shortest_legal_path(args.path)
        print(" -> ".join(path) if path else "not found")

    if args.validate:
        with open(args.validate) as f:
            picks = json.load(f)
        print(json.dumps(tree.validate_build(picks), indent=2))

    if args.coherence:
        with open(args.coherence) as f:
            picks = json.load(f)
        print(json.dumps(tree.coherence_report(picks), indent=2))


if __name__ == "__main__":
    main()
