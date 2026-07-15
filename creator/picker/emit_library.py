"""emit_library.py - Phase 0: the picker's data, flattened to ONE file. Show what we have, not rework it.

One dumb emit (defined I/O, deterministic, rerunnable): reads the four sources AS THEY SIT and joins them
per class -> per spec. Verbatim fields; no invention; custom_N gaps carried AS gaps (the "not provided by
CoA" rule renders them - this gear never papers over). No wall-clock in the output (idempotent bytes).

  py emit_library.py          -> out/library.json + a printed receipt

Sources (the pool assessed READY, picker_tree.md):
  dependencies/coa_spells.json          the live-DB spell corpus (names, durations, attribution)
  creator/planning/resolved.json        axes + effects + edges + gaps per spell (the chains)
  Input/*_talents.json                  dev-authored cards (description 100%); VERBATIM incl. its quirks
                                        (stringly values, referencedTerms as a repr-string)
  creator/planning/tables/_index.json   per-class:spec captions (hub/shape/counts)
  pull_target_tracker.families()        the DoT shelf select - one source of truth with the press
"""
import json
import os
import sys
from collections import defaultdict

_HERE = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.abspath(os.path.join(_HERE, "..", ".."))
_PLANNING = os.path.join(_ROOT, "creator", "planning")
sys.path.insert(0, _PLANNING)
from pull_target_tracker import families  # noqa: E402  (the select recipe, as data)

COA = os.path.join(_ROOT, "dependencies", "coa_spells.json")
RESOLVED = os.path.join(_PLANNING, "resolved.json")
INDEX = os.path.join(_PLANNING, "tables", "_index.json")
INPUT_DIR = os.path.join(_ROOT, "Input")
OUT = os.path.join(_HERE, "out", "library.json")

CARD_FIELDS = ("spellId", "name", "tree", "entryType", "description", "isPassive",
               "iconPath", "referencedTerms")


def load_inputs(d):
    """Input talent files keyed by LIVE class name, matched MECHANICALLY: each file's
    talents' spellIds are attributed in the corpus - the majority class IS the class.
    No name normalization, no alias table (the builder renamed 7 classes vs live:
    bloodmage->SONOFARUGAL etc. - derived 2026-07-15 by this same join, unanimous 7/7).
    Requires >=90% agreement; anything less is a warning, never a guess."""
    sid2cls = {}
    for sid, s in d.items():
        for r in (s.get("coa") or {}).get("direct", []) or []:
            if r.get("class"):
                sid2cls.setdefault(sid, set()).add(r["class"])
    out, unmatched = {}, []
    for f in sorted(os.listdir(INPUT_DIR)):
        if not f.endswith("_talents.json"):
            continue
        data = json.load(open(os.path.join(INPUT_DIR, f), encoding="utf-8"))
        hits = defaultdict(int)
        total = 0
        for t in data.get("talents") or []:
            total += 1
            for c in sid2cls.get(str(t.get("spellId")), ()):
                hits[c] += 1
        best = max(hits.items(), key=lambda kv: kv[1]) if hits else (None, 0)
        if best[0] and total and best[1] / total >= 0.9:
            out[best[0]] = (f, data)
        else:
            unmatched.append(f"{f} (best: {best[0]} {best[1]}/{total})")
    return out, unmatched


def chain_closure(res, seed_sids):
    """The class's chain slice: seed spells + every edge destination, to fixpoint.
    The library face walks ID->ID->ID; a dst must not dead-end just because it
    wasn't directly attributed."""
    seen = set()
    frontier = [s for s in seed_sids if s in res]
    while frontier:
        sid = frontier.pop()
        if sid in seen:
            continue
        seen.add(sid)
        for e in res[sid].get("edges") or []:
            dst = e.get("dst")
            if dst and dst in res and dst not in seen:
                frontier.append(dst)
    return seen


def shelf_rows(fams):
    """families() output -> shelf rows (sorted, sets flattened, exclusions honest)."""
    order = {"DoT": 0, "bane": 1, "builder": 2, "control": 3}
    rows = []
    for name, f in sorted(fams.items(), key=lambda kv: (min(order[x] for x in kv[1]["flav"]), kv[0])):
        flav = sorted(f["flav"], key=lambda x: order[x])
        excluded = (f["flav"] == {"control"} and "control (CC only)") or \
                   (f["flav"] == {"builder"} and "resource builder") or None
        rows.append({
            "family": name,
            "flavour": "/".join(flav),
            "spellIds": sorted(f["sids"]),
            "durS": sorted(f["dur"]),
            "cdS": sorted(f["cd"]),
            "auras": sorted(f["auras"]),
            **({"excluded": excluded} if excluded else {}),
        })
    return rows


def main():
    d = json.load(open(COA, encoding="utf-8"))
    res = json.load(open(RESOLVED, encoding="utf-8"))
    index = json.load(open(INDEX, encoding="utf-8"))
    inputs, unmatched_inputs = load_inputs(d)

    captions = {(r["class"], r["spec"]): r for r in index}
    pairs = sorted({(r["class"], r["spec"]) for s in d.values()
                    for r in (s.get("coa") or {}).get("direct", []) if r.get("class") and r.get("spec")})
    classes = sorted({c for c, _ in pairs})

    lib = {"classes": {}}
    warnings = []
    totals = defaultdict(int)

    for cls in classes:
        specs = sorted(sp for c, sp in pairs if c == cls)
        input_hit = inputs.get(cls)
        display, talents = (input_hit[1].get("class"), input_hit[1].get("talents") or []) if input_hit else (cls.title(), [])
        if not input_hit:
            warnings.append(f"{cls}: no Input talent file matched (cards empty)")

        by_tree = defaultdict(list)
        for t in talents:
            by_tree[t.get("tree")].append({k: t.get(k) for k in CARD_FIELDS})
        for tree in by_tree:
            if tree not in specs:
                warnings.append(f"{cls}: Input tree '{tree}' has no attribution spec (cards kept under it anyway)")

        entry = {"display": display, "specs": {}, "chains": {}}
        class_pool = set()
        for spec in specs:
            pool_sids = {sid for sid, s in d.items()
                         if any(r.get("class") == cls and r.get("spec") == spec
                                for r in ((s.get("coa") or {}).get("direct")
                                          or (s.get("coa") or {}).get("triggeredBy") or []))}
            class_pool |= pool_sids
            fams = families(d, res, cls, spec)
            entry["specs"][spec] = {
                "caption": {k: captions[(cls, spec)][k] for k in ("hub", "shape", "spells", "edges")}
                           if (cls, spec) in captions else None,
                "cards": by_tree.get(spec, []),
                "shelves": {"dot_target": shelf_rows(fams)},
            }
            totals["cards"] += len(by_tree.get(spec, []))
            totals["shelf_families"] += len(fams)
            if (cls, spec) not in captions:
                warnings.append(f"{cls}/{spec}: no caption row in tables/_index.json")

        # trees in Input but not in the attribution's spec list still ship their cards
        for tree, cards in by_tree.items():
            if tree not in entry["specs"]:
                entry["specs"][tree] = {"caption": None, "cards": cards, "shelves": {"dot_target": []}}
                totals["cards"] += len(cards)

        chain_sids = chain_closure(res, class_pool)
        for sid in sorted(chain_sids):
            row = dict(res[sid])
            name = (d.get(sid) or {}).get("name")
            if name:
                row["name"] = name  # a JOIN from the corpus, not invention
            entry["chains"][sid] = row
        totals["chain_spells"] += len(chain_sids)
        totals["gap_rows"] += sum(1 for sid in chain_sids if res[sid].get("gaps"))

        lib["classes"][cls] = entry
        totals["specs"] += len(entry["specs"])

    lib["_provenance"] = {
        "emitted_by": "creator/picker/emit_library.py (Phase 0)",
        "sources": {
            "spells": "dependencies/coa_spells.json",
            "chains": "creator/planning/resolved.json",
            "cards": "Input/*_talents.json (verbatim, incl. stringly values + repr-string referencedTerms)",
            "captions": "creator/planning/tables/_index.json",
            "shelves": "pull_target_tracker.families() - the press's own select",
        },
        "input_extracts": {k: v[1].get("extracted") for k, v in sorted(inputs.items())},
        "counts": dict(totals, classes=len(classes)),
        "gap_rule": "chains[].gaps (CUSTOM_effect_N) render as 'not provided by CoA' - never papered over",
    }

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        json.dump(lib, f, ensure_ascii=False, sort_keys=True, indent=None, separators=(",", ":"))
    size_mb = os.path.getsize(OUT) / 1e6

    print(f"library.json emitted: {size_mb:.1f} MB")
    print(f"  classes {len(classes)} | specs {totals['specs']} | cards {totals['cards']} | "
          f"chain spells {totals['chain_spells']} (gap rows {totals['gap_rows']}) | "
          f"shelf families {totals['shelf_families']}")
    if unmatched_inputs:
        print(f"  Input files the spellId join could not place: {', '.join(unmatched_inputs)}")
    for w in warnings:
        print(f"  ! {w}")


if __name__ == "__main__":
    main()
