import json, re, sys
from collections import defaultdict

if len(sys.argv) != 3:
    print("Usage: python3 build_skill_index.py <class_talents.json> <output_skill_index.json>")
    sys.exit(1)
with open(sys.argv[1]) as f:
    data = json.load(f)

talents = data['talents']
by_name = {t['name']: t for t in talents}

NUM_UNIT = re.compile(r'by\s+(-?\d+(?:\.\d+)?)\s*(%|sec\b|seconds\b|yds\b|Rage\b)?')

def parse_stat_mods(desc):
    if not desc or desc.startswith('$'):
        return []
    mods = []
    for m in NUM_UNIT.finditer(desc):
        val = float(m.group(1))
        unit = m.group(2) or 'flat'
        unit = {'seconds': 'sec'}.get(unit, unit)
        mods.append({'value': val, 'unit': unit})
    return mods

def mock_value(mods):
    baseline = 10.0
    pct_mods = [m for m in mods if m['unit'] == '%']
    if not pct_mods:
        return None
    result = baseline
    for m in pct_mods:
        result *= (1 + m['value'] / 100)
    return round(result, 2)

LANES = {
    'DMG': 'Damage', 'STATS': 'Primary/secondary stats', 'CRIT': 'Crit chance/damage',
    'CDR': 'Cooldown', 'CAST': 'Cast time', 'HASTE': 'Haste', 'SPEED': 'Movement speed',
    'HEAL': 'Healing', 'SHIELD': 'Shield/absorb', 'MITIGATION': 'Damage mitigation',
    'RESOURCE': 'Resource generation', 'COST': 'Resource cost', 'DURATION': 'Duration',
    'AOE': 'AoE / target count', 'CC': 'Crowd control', 'ARMOR': 'Armor',
    'SUMMON': 'Summon / pet', 'MISC': 'Other',
}

LANE_PATTERNS = {
    'DMG': re.compile(r'damage(?!\s*taken)|spell power scaling|attack power\b'),
    'STATS': re.compile(r'\b(agility|strength|stamina|intellect|spirit)\b|hit rating|expertise|dodge rating|parry rating'),
    'CRIT': re.compile(r'critical(ly)? (strike|strikes|hit|struck)|\bcrit\b'),
    'CDR': re.compile(r'\bcooldown\b|resets? the cooldown'),
    'CAST': re.compile(r'cast time'),
    'HASTE': re.compile(r'\bhaste\b'),
    'SPEED': re.compile(r'movement speed|mounted movement'),
    'HEAL': re.compile(r'\bheal(s|ing|ed)?\b|restores?\s+.*health|leech(es)?|siphon'),
    'SHIELD': re.compile(r'\babsorb|\bshield\b'),
    'MITIGATION': re.compile(r'damage taken.*reduc|reduc\w*.*damage taken|damage reduction|reduces? all damage'),
    'RESOURCE': re.compile(r'generat\w*.*(rage|mana|energy|stack)|grants?\s+.*stack|restores?.*(rage|mana|energy)'),
    'COST': re.compile(r'reduces? the \w* ?cost|costs? -?\d+.*less|cost.*reduced|-\d+%?\s*(less|reduced)\s*\w*\s*cost'),
    'DURATION': re.compile(r'\bduration\b'),
    'AOE': re.compile(r'additional (target|enem\w*)|\bradius\b|nearby enem\w*|strikes?\s+\d+\s+additional|\d+\s+additional\s+(target|enem\w*)|nearby allies'),
    'CC': re.compile(r'\bstun\b|\broot\b|\bsilence\b|\bfear\b|\btaunt\b|\bslow\w*|\bconfus\w*|\bincapacitat'),
    'ARMOR': re.compile(r'\barmor\b'),
    'SUMMON': re.compile(r'\bsummon\w*|\bcalls?\b.*(to aid|to appear)|\bpet\b'),
}
PROC_PATTERN = re.compile(r'\bchance\b')
STACK_PATTERN = re.compile(r'\bstack(s|ing)?\b')

def classify(desc):
    if not desc or desc.startswith('$'):
        return {'lanes': ['MISC'], 'flags': [], 'unresolved': True}
    d = desc.lower()
    lanes = [code for code, pat in LANE_PATTERNS.items() if pat.search(d)]
    if not lanes:
        lanes = ['MISC']
    flags = []
    if PROC_PATTERN.search(d):
        flags.append('PROC')
    if STACK_PATTERN.search(d):
        flags.append('STACK')
    return {'lanes': lanes, 'flags': flags, 'unresolved': False}

def get_desc(t):
    ranks = t.get('rankDescriptions') or []
    return ranks[-1]['description'] if ranks else t['description']

skill_index = defaultdict(list)
own_ability_index = {}

for t in talents:
    desc = get_desc(t)
    mods = parse_stat_mods(desc)
    cls = classify(desc)
    record = {
        'talent': t['name'], 'tree': t['tree'],
        'position': {'x': t['x'], 'y': t['y']},
        'cost': {'abilityEssence': t['abilityEssenceCost'], 'talentEssence': t['talentEssenceCost']},
        'maxPoints': t['maxPoints'],
        'requiredLevel': t.get('requiredLevel', 0),
        'specialRequirement': t.get('specialRequirement') or [],
        'statModification': mods,
        'mockValueOnBaseline10': mock_value(mods),
        'lanes': cls['lanes'], 'flags': cls['flags'], 'description': desc,
    }
    own_name_refs = [r for r in t['referencedTerms'] if r != t['name']]
    if own_name_refs:
        for skill in own_name_refs:
            skill_index[skill].append(record)
    else:
        own_ability_index[t['name']] = {
            'lanes': cls['lanes'], 'flags': cls['flags'], 'description': desc,
            'tree': t['tree'], 'position': {'x': t['x'], 'y': t['y']},
            'cost': {'abilityEssence': t['abilityEssenceCost'], 'talentEssence': t['talentEssenceCost']},
            'maxPoints': t['maxPoints'],
            'requiredLevel': t.get('requiredLevel', 0),
            'specialRequirement': t.get('specialRequirement') or [],
        }

def skill_lanes(skill_name):
    if skill_name in own_ability_index:
        return own_ability_index[skill_name]['lanes']
    mods = skill_index.get(skill_name, [])
    texts = ' '.join(m.get('description', '').lower() for m in mods)
    lanes = [code for code, pat in LANE_PATTERNS.items() if pat.search(texts)]
    return lanes or ['MISC']

# ---------------------------------------------------------------------------
# 4. Spell families - some skill names are not distinct spells but a family
#    header for a set of specific spells (e.g. "Animate" is the family for
#    "Animate: Bone Wraith", "Animate: Tomb King", etc). Detected purely by
#    naming convention: "Family: Specific" where the bare "Family" name is
#    itself also an observed skill. Also folds simple plural/singular text
#    drift in the source tooltips (e.g. "Animate" vs "Animates") into one
#    canonical family, since that's the same underlying family, just
#    inconsistently worded on the site.
# ---------------------------------------------------------------------------
FAMILY_CHILD_PATTERN = re.compile(r'^(.+?):\s+.+$')

all_skill_names = set(skill_index.keys()) | set(own_ability_index.keys())

alias_map = {}
for name in list(all_skill_names):
    for suffix in ('es', 's'):
        if name.endswith(suffix):
            base = name[:-len(suffix)]
            if base != name and base in all_skill_names:
                alias_map[name] = base
                break

for alias, canonical in alias_map.items():
    skill_index[canonical].extend(skill_index.get(alias, []))
    skill_index.pop(alias, None)
    own_ability_index.pop(alias, None)
    all_skill_names.discard(alias)

family_children_raw = defaultdict(list)
for name in all_skill_names:
    m = FAMILY_CHILD_PATTERN.match(name)
    if m:
        family = m.group(1).strip()
        if family in all_skill_names and family != name:
            family_children_raw[family].append(name)

# A "family" needs 2+ members to mean anything - a bare name with exactly one
# "Name: Child" sibling isn't really a family, so fold its talents into that
# one child instead (same mechanism as the plural-alias merge above) rather
# than showing a one-item family card.
family_children = {}
for fam, children in family_children_raw.items():
    children = sorted(children)
    if len(children) >= 2:
        family_children[fam] = children
    else:
        only_child = children[0]
        existing = {m['talent'] for m in skill_index.get(only_child, [])}
        for m in skill_index.get(fam, []):
            if m['talent'] not in existing:
                shared = dict(m)
                shared['sharedFromFamily'] = fam
                skill_index[only_child].append(shared)
        skill_index.pop(fam, None)
        own_ability_index.pop(fam, None)
        all_skill_names.discard(fam)

# Family-level talents apply to every member of the family - copy them down
# onto each child too (tagged so the readout can show "shared" vs "specific"),
# without duplicating a talent a child already has explicitly.
for family, children in family_children.items():
    family_mods = skill_index.get(family, [])
    for child in children:
        existing = {m['talent'] for m in skill_index.get(child, [])}
        for m in family_mods:
            if m['talent'] not in existing:
                shared = dict(m)
                shared['sharedFromFamily'] = family
                skill_index[child].append(shared)

output = {
    'class': data['class'], 'schemaVersion': 3, 'laneTaxonomy': LANES,
    'note': (
        'Per-skill index: for each observed skill/ability, lists every talent that '
        'modifies it, where it sits in the tree, its parsed stat modification, and a '
        'mock value showing that modification applied to a normalized baseline of 10. '
        'Each modifying talent is tagged with one or more lanes from laneTaxonomy '
        '(DMG/CRIT/CDR/CAST/HASTE/SPEED/HEAL/SHIELD/MITIGATION/RESOURCE/COST/DURATION/'
        'AOE/CC/ARMOR/SUMMON/MISC), plus cross-cutting behavior flags (PROC, STACK) '
        'that describe how the effect triggers rather than what stat it touches. A '
        'handful of nodes have unresolved "$xx" template descriptions in the source '
        'export - these are flagged rather than guessed at. Skills also carry a '
        '"kind" of "family" (a header covering several specific spells, e.g. '
        '"Animate") or "spell" (everything else, including a family\'s specific '
        'members) - family talents are copied onto each of their children and '
        'marked with "sharedFromFamily".'
    ),
    'mockBaseline': 10, 'skills': {}
}
all_skills = sorted(set(list(skill_index.keys()) + list(own_ability_index.keys())))
for skill in all_skills:
    base = own_ability_index.get(skill)
    output['skills'][skill] = {
        'kind': 'family' if skill in family_children else 'spell',
        'familyChildren': family_children.get(skill, []),
        'lanes': base['lanes'] if base else skill_lanes(skill),
        'isBaseAbilityInTree': skill in own_ability_index,
        'baseDescription': base['description'] if base else None,
        'baseTree': base['tree'] if base else None,
        'basePosition': base['position'] if base else None,
        'modifyingTalents': skill_index.get(skill, [])
    }
with open(sys.argv[2], 'w') as f:
    json.dump(output, f, indent=2)
print('Total observed skills:', len(all_skills))
print('Skills with >=1 modifying talent:', sum(1 for s in all_skills if skill_index.get(s)))
print('Skills that are base in-tree abilities with no modifiers found:', sum(1 for s in all_skills if s in own_ability_index and not skill_index.get(s)))
print('Spell families detected:', len(family_children), list(family_children.keys()))
print('Plural/singular aliases merged:', alias_map)
