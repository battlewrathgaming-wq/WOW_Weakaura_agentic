import json, sys
from collections import defaultdict

def mod_summary(mod):
    parts = []
    for m in mod.get('statModification', []):
        sign = '+' if m['value'] > 0 else ''
        parts.append(f"{sign}{m['value']:g}{m['unit']}")
    stat = ', '.join(parts)
    lanes = ', '.join(mod.get('lanes', []))
    flags = ', '.join(mod.get('flags', []))
    tag = f"[{lanes}]" if lanes else ""
    if flags:
        tag += f" ({flags})"
    if stat and tag:
        return f"{tag} {stat}"
    return tag or stat or "(non-numeric effect, see description)"

def build(talents_path, skill_index_path, out_path):
    with open(talents_path) as f:
        class_data = json.load(f)
    with open(skill_index_path) as f:
        skill_idx = json.load(f)

    class_name = class_data['class']
    spec_trees = [t for t in class_data['trees'] if t != 'Class']

    lines = [f"# {class_name} - Skill Investment Readout\n"]
    lines.append(
        "For each spec, every skill that has at least one talent modifying it, and the "
        "flat list of talents to invest in for it. Class-tree talents are always available "
        "regardless of spec, so they're folded into each spec's list rather than shown "
        "separately. Pick the skill you already like, take the talents underneath it.\n"
    )

    for spec in spec_trees:
        available_trees = {'Class', spec}
        lines.append(f"\n## {spec} (+ Class)\n")

        skill_to_mods = defaultdict(list)
        for skill, info in skill_idx['skills'].items():
            for m in info['modifyingTalents']:
                if m['tree'] in available_trees:
                    skill_to_mods[skill].append(m)

        if not skill_to_mods:
            lines.append("*(no cross-referenced modifiers found for this spec)*\n")
            continue

        def is_family(s):
            return skill_idx['skills'].get(s, {}).get('kind') == 'family'

        ordered_skills = sorted(skill_to_mods, key=lambda s: (is_family(s), -len(skill_to_mods[s])))
        printed_family_header = False
        for skill in ordered_skills:
            if is_family(skill) and not printed_family_header:
                lines.append("\n#### Spell families\n")
                lines.append(
                    "*Families below are not a single spell - they're a shared label "
                    "covering several specific spells. Their talents also show up under "
                    "each specific spell above (marked \"shared\").*\n"
                )
                printed_family_header = True
            mods = skill_to_mods[skill]
            base_info = skill_idx['skills'].get(skill, {})
            skill_lane_tags = ', '.join(base_info.get('lanes', [])) if base_info else ''
            heading = f"\n### {skill}"
            if is_family(skill):
                heading += "  *(Family)*"
            heading += f"  *[{skill_lane_tags}]*" if skill_lane_tags else ""
            lines.append(heading)
            if is_family(skill):
                children = base_info.get('familyChildren', [])
                if children:
                    lines.append(f"*Applies to: {', '.join(children)}*")
            for m in sorted(mods, key=lambda x: (x['tree'] != 'Class', x['position']['y'])):
                cost = m['cost']
                per_rank_cost = cost['abilityEssence'] or cost['talentEssence']
                points = m.get('maxPoints', 1) if per_rank_cost else 0
                if points == 0:
                    req_level = m.get('requiredLevel', 0)
                    special_req = m.get('specialRequirement') or []
                    if special_req and not req_level:
                        point_str = "Starting Talent"
                    elif req_level:
                        point_str = "Spec passive"
                    else:
                        point_str = "Free"
                else:
                    point_str = f"{points} point" + ("s" if points != 1 else "")
                talent_kind = "Class talent" if m['tree'] == 'Class' else "Spec talent"
                shared_note = ""
                if m.get('sharedFromFamily'):
                    shared_note = f" *(shared: {m['sharedFromFamily']} family)*"
                lines.append(
                    f"- **{m['talent']}** ({talent_kind}, {point_str}) - {mod_summary(m)}{shared_note}"
                )

    with open(out_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    print(f"Wrote {out_path}")

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Usage: python3 build_flattened_readout.py <talents.json> <skill_index.json> <out.md>")
        sys.exit(1)
    build(sys.argv[1], sys.argv[2], sys.argv[3])
