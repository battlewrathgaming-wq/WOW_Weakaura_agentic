"""
coa_skill_lookup.py - Query the per-skill talent index built by build_skill_index.py.

The skill index inverts the usual tree-first view: instead of "here's a tree, here's its
nodes," it's "here's a skill you already like, here's every talent across the whole class
that touches it." That's the intended workflow - a player picks a spell they enjoy, then
scans the flattened modifier list rather than re-deriving it by reading 200 tooltips.

Data note: a handful of nodes (Transgression, Thirst, Bloodsores, Eternal Curse, Sanguine
Essence, Final Embrace, Darkcasting, Bloodsurge, Relentless) have unresolved "$xx" template
descriptions in the raw export - the site never expands them client-side either, so their
mechanical text isn't recoverable from this data source. They still appear in the index
(as referenced skills) but with no parsed stat modification.

Usage:
    python3 coa_skill_lookup.py bloodmage_skill_index.json --skill "Bloodbolt"
    python3 coa_skill_lookup.py bloodmage_skill_index.json --list-skills
    python3 coa_skill_lookup.py bloodmage_skill_index.json --list-skills --type Offensive
    python3 coa_skill_lookup.py bloodmage_skill_index.json --most-modified 10
"""

import json
import argparse


def load(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def show_skill(idx, skill_name):
    skills = idx["skills"]
    # case-insensitive fuzzy match
    match = next((k for k in skills if k.lower() == skill_name.lower()), None)
    if not match:
        candidates = [k for k in skills if skill_name.lower() in k.lower()]
        print(f"No exact match for '{skill_name}'.")
        if candidates:
            print("Did you mean:", ", ".join(candidates))
        return

    info = skills[match]
    print(f"=== {match} ===")
    print(f"Spell type: {', '.join(info['spellType'])}")
    if info["isBaseAbilityInTree"]:
        print(f"Base ability defined in-tree: {match} ({info['baseTree']}, "
              f"x={info['basePosition']['x']} y={info['basePosition']['y']})")
        print(f"Base description: {info['baseDescription']}")
    else:
        print("Base ability is core kit (not itself a talent node in this class tree).")

    mods = info["modifyingTalents"]
    if not mods:
        print("\nNo talents in this class modify it further.")
        return

    print(f"\n{len(mods)} talent(s) modify this skill:\n")
    for m in sorted(mods, key=lambda x: (x["tree"], x["position"]["y"], x["position"]["x"])):
        cost = m["cost"]
        cost_str = f"{cost['abilityEssence']} AE" if cost["abilityEssence"] else f"{cost['talentEssence']} TE"
        mod_str = ", ".join(f"{d['value']:+g}{d['unit']}" for d in m["statModification"]) or "(non-numeric effect)"
        mock = m["mockValueOnBaseline10"]
        mock_str = f"  mock: 10 -> {mock}" if mock is not None else ""
        print(f"  [{m['tree']:<12} y={m['position']['y']:<2} x={m['position']['x']:<3}] "
              f"{m['talent']:<35} cost={cost_str:<6} mod={mod_str}{mock_str}")
        print(f"      effect: {', '.join(m['primitiveEffect'])}")
        print(f"      \"{m['description'][:140]}{'...' if len(m['description'])>140 else ''}\"")


def list_skills(idx, type_filter=None):
    for name, info in sorted(idx["skills"].items()):
        if type_filter and type_filter not in info["spellType"]:
            continue
        n_mods = len(info["modifyingTalents"])
        print(f"{name:<35} type={','.join(info['spellType']):<30} modified by {n_mods} talent(s)")


def most_modified(idx, top_n):
    scored = [(name, len(info["modifyingTalents"])) for name, info in idx["skills"].items()]
    scored.sort(key=lambda x: -x[1])
    print("Most-modified skills (best places to look for a compounding build core):\n")
    for name, count in scored[:top_n]:
        print(f"  {name:<35} {count} modifying talents")


def main():
    ap = argparse.ArgumentParser(description="Query a CoA per-skill talent index.")
    ap.add_argument("file", help="Path to a *_skill_index.json file")
    ap.add_argument("--skill", help="Show every talent that modifies this skill")
    ap.add_argument("--list-skills", action="store_true", help="List all observed skills")
    ap.add_argument("--type", help="Filter --list-skills by spell type (Offensive/Defensive/Utility/Heal (Self)/Heal (Other))")
    ap.add_argument("--most-modified", type=int, metavar="N", help="Show the N most-modified skills")
    args = ap.parse_args()

    idx = load(args.file)

    if args.skill:
        show_skill(idx, args.skill)
    if args.list_skills:
        list_skills(idx, args.type)
    if args.most_modified:
        most_modified(idx, args.most_modified)


if __name__ == "__main__":
    main()
