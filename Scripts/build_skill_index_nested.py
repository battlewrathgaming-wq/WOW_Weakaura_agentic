"""
build_skill_index_nested.py - EXPERIMENTAL. Same job as build_skill_index.py
(flatten talents onto the skills they touch), plus one more layer: classifies
each talent-to-skill reference as 'modifies' (changes the target's own numbers)
or 'produces' (the target is something the talent makes appear/proc/stack more -
a pet, a buff, a proc, a stack - "spawn" in the general sense, not just NPCs).

A skill that's ever 'produces'-referenced *with a named parent* gets nested
under that parent (under every parent it has, if more than one) instead of
living as its own top-level card - so "I like Harvest Plague, what should I
invest in" already shows Lesser Zombie right there, instead of making the
reader go find Lesser Zombie's card separately and reattribute it by hand.

A skill only stays top-level if it has no named parent anywhere (the trigger
was a plain condition, like "critical strikes", not another named ability).

This is a separate file from build_skill_index.py on purpose - the existing
pipeline/output is left completely alone as a fallback in case this heuristic
doesn't hold up once eyeballed against real output.

Usage:
    python3 build_skill_index_nested.py <class_talents.json> <output_skill_index_nested.json>
"""
import json, re, sys
from collections import defaultdict

if len(sys.argv) != 3:
    print("Usage: python3 build_skill_index_nested.py <class_talents.json> <output_skill_index_nested.json>")
    sys.exit(1)
with open(sys.argv[1]) as f:
    data = json.load(f)

talents = data['talents']

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

# ---------------------------------------------------------------------------
# Produces/modifies edge classification - "spawn" generalized to any produced
# thing (pet, buff, proc, stack), not just NPCs. A referenced name is
# 'produces' if immediately preceded by a produce-type verb; otherwise it's
# 'modifies' (the talent changes that skill's own numbers/behavior).
# ---------------------------------------------------------------------------
PRODUCE_VERB = re.compile(
    r'\b(summons?|creates?|spawns?|calls?\s+forth|conjures?|releases?|unleashes?|'
    r'grants?|triggers?|applies|procs?|gain(?:s)?)\b'
)
# Short lookback window - a produce verb only counts if it's tight against the
# target name (verb + at most an article/number/"to"/possessive in between),
# not just present somewhere earlier in a long sentence. This is what tells
# apart "applies Crypt Plague" (produces) from "...applies Expunge if they
# are Diseased" (Diseased here is a condition being checked, not something
# produced, even though "applies" appears earlier in the same sentence).
PRODUCE_LOOKBACK = 20

def classify_edges(desc, refs, own_name):
    """Returns list of {target, role, occurrences} for each referenced name
    other than the talent's own name. role is 'produces' only if EVERY
    occurrence of that name in the description is tightly preceded by a
    produce verb; if any occurrence looks like a direct modification, role is
    'modifies' (modifying always wins - a talent that both produces X
    sometimes and references X's own stats elsewhere is still modifying it)."""
    edges = []
    for r in refs:
        if r == own_name:
            continue
        roles_seen = set()
        for m in re.finditer(re.escape(r), desc):
            before = desc[max(0, m.start() - PRODUCE_LOOKBACK):m.start()]
            roles_seen.add('produces' if PRODUCE_VERB.search(before) else 'modifies')
        role = 'modifies' if 'modifies' in roles_seen else 'produces'
        edges.append({'target': r, 'role': role})
    return edges

def get_parent_for_edge(edges, target):
    """For a 'produces' edge, the parent is whichever OTHER target in the
    same talent got a 'modifies' role. None if no such target exists (the
    trigger was a plain condition, not a named ability)."""
    others_modifies = [e['target'] for e in edges if e['target'] != target and e['role'] == 'modifies']
    if len(others_modifies) == 1:
        return others_modifies[0]
    if len(others_modifies) > 1:
        return others_modifies[0]  # ambiguous - pick first, flagged via 'ambiguousParents' below
    return None

# ---------------------------------------------------------------------------
# Build modifies-index and produces-index separately
# ---------------------------------------------------------------------------
skill_index = defaultdict(list)       # skill -> list of 'modifies' talent records
producing_index = defaultdict(list)   # skill -> list of 'produces' talent records (each carries 'parent')
own_ability_index = {}

for t in talents:
    desc = get_desc(t)
    mods = parse_stat_mods(desc)
    cls = classify(desc)
    base_record = {
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
    refs = [r for r in t['referencedTerms'] if r != t['name']]
    if refs:
        edges = classify_edges(desc, refs, t['name'])
        for e in edges:
            if e['role'] == 'modifies':
                skill_index[e['target']].append(dict(base_record))
            else:
                parent = get_parent_for_edge(edges, e['target'])
                rec = dict(base_record)
                rec['parent'] = parent
                producing_index[e['target']].append(rec)
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
    mods = skill_index.get(skill_name, []) + producing_index.get(skill_name, [])
    texts = ' '.join(m.get('description', '').lower() for m in mods)
    lanes = [code for code, pat in LANE_PATTERNS.items() if pat.search(texts)]
    return lanes or ['MISC']

# ---------------------------------------------------------------------------
# Plural/singular alias merge (e.g. "Animate" / "Animates") - same as the
# production script, applied across both indices.
# ---------------------------------------------------------------------------
all_skill_names = set(skill_index.keys()) | set(producing_index.keys()) | set(own_ability_index.keys())

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
    producing_index[canonical].extend(producing_index.get(alias, []))
    skill_index.pop(alias, None)
    producing_index.pop(alias, None)
    own_ability_index.pop(alias, None)
    all_skill_names.discard(alias)
    for lst in (skill_index, producing_index):
        for recs in lst.values():
            for r in recs:
                if r.get('parent') == alias:
                    r['parent'] = canonical

# ---------------------------------------------------------------------------
# Family detection (naming-convention based, same mechanism as production
# script) - independent of the produces/modifies mechanism above.
# ---------------------------------------------------------------------------
FAMILY_CHILD_PATTERN = re.compile(r'^(.+?):\s+.+$')

def resolve_family_header(prefix, names):
    """A colon-child's family header is normally the bare prefix itself
    (e.g. "Animate" for "Animate: Bone Wraith"). But sometimes the umbrella
    skill carries an extra word (e.g. "Undead Stance" is the real header for
    "Undead: Assault"/"Undead: Protect"/"Undead: Pacify" - the bare prefix
    "Undead" is never a skill by itself, only "Undead Stance" is). Fall back
    to a whole-word-prefix match against the observed skill names, but only
    when it's unambiguous."""
    if prefix in names:
        return prefix
    candidates = [s for s in names if s.startswith(prefix + ' ')]
    if len(candidates) == 1:
        return candidates[0]
    return None

family_children_raw = defaultdict(list)
for name in all_skill_names:
    m = FAMILY_CHILD_PATTERN.match(name)
    if m:
        prefix = m.group(1).strip()
        header = resolve_family_header(prefix, all_skill_names)
        if header and header != name:
            family_children_raw[header].append(name)

# A colon-child family with 2+ members obviously means something. A *single*
# child is still kept as a real family (not folded away into that child)
# if the header itself already has real independent identity - several
# talents of its own - since folding a well-established mechanic under
# whichever one literal spell happens to share its naming prefix is
# misleading (e.g. "Command", with 8+ talents describing the general
# mechanic, getting relabeled as "Command: Hook" - one incidental spell -
# just because that's its only literal colon-suffixed sibling).
FAMILY_HEADER_MIN_TALENTS = 2

family_children = {}
for fam, children in family_children_raw.items():
    children = sorted(children)
    own_count = len(skill_index.get(fam, []))
    if len(children) >= 2 or own_count >= FAMILY_HEADER_MIN_TALENTS:
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
        producing_index.pop(fam, None)
        own_ability_index.pop(fam, None)
        all_skill_names.discard(fam)
        # fam no longer exists as a skill - any 'produces' edge that named it
        # as a parent (e.g. "Command" folded into "Command: Hook") needs to
        # point at the surviving name instead, or it becomes a phantom
        # top-level card with nothing real behind it.
        for recs in producing_index.values():
            for r in recs:
                if r.get('parent') == fam:
                    r['parent'] = only_child

for family, children in family_children.items():
    family_mods = skill_index.get(family, [])
    for child in children:
        existing = {m['talent'] for m in skill_index.get(child, [])}
        for m in family_mods:
            if m['talent'] not in existing:
                shared = dict(m)
                shared['sharedFromFamily'] = family
                skill_index[child].append(shared)

# ---------------------------------------------------------------------------
# Produced-by-parents rollup: which skills nest, and under whom
# ---------------------------------------------------------------------------
produced_by_parents = defaultdict(set)
for skill, recs in producing_index.items():
    for r in recs:
        if r.get('parent'):
            produced_by_parents[skill].add(r['parent'])

produces_children = defaultdict(set)
for child, parents in produced_by_parents.items():
    for p in parents:
        produces_children[p].add(child)

all_skills = sorted(all_skill_names | set(skill_index.keys()) | set(producing_index.keys()))

output = {
    'class': data['class'], 'schemaVersion': 1, 'experimental': True, 'laneTaxonomy': LANES,
    'note': (
        'EXPERIMENTAL nested variant of the skill index. Every talent-to-skill '
        'reference is classified as "modifies" (changes the target\'s own numbers) '
        'or "produces" (the target is a pet/buff/proc/stack that talent makes '
        'appear more, generalized from literal NPC summons to any produced '
        'effect). A skill with producedByParents non-empty should be rendered '
        'nested under EVERY one of those parents (duplicated, not cross- '
        'referenced) rather than as its own top-level card. Skills with no '
        'named parent anywhere stay top-level since there\'s nothing to nest '
        'under. Family grouping (kind=family) is a separate, independent '
        'mechanism based on "Name: Child" naming convention.'
    ),
    'mockBaseline': 10, 'skills': {}
}
for skill in all_skills:
    base = own_ability_index.get(skill)
    parents = sorted(produced_by_parents.get(skill, []))
    kind = 'family' if skill in family_children else ('produced' if parents else 'spell')
    output['skills'][skill] = {
        'kind': kind,
        'familyChildren': family_children.get(skill, []),
        'producedByParents': parents,
        'producesChildren': sorted(produces_children.get(skill, [])),
        'lanes': base['lanes'] if base else skill_lanes(skill),
        'isBaseAbilityInTree': skill in own_ability_index,
        'baseDescription': base['description'] if base else None,
        'baseTree': base['tree'] if base else None,
        'basePosition': base['position'] if base else None,
        'modifyingTalents': skill_index.get(skill, []),
        'producingTalents': producing_index.get(skill, []),
    }

with open(sys.argv[2], 'w') as f:
    json.dump(output, f, indent=2)

print('Total observed skills:', len(all_skills))
print('Skills with >=1 modifying talent:', sum(1 for s in all_skills if skill_index.get(s)))
print('Skills that nest under a parent (kind=produced):', sum(1 for s in all_skills if output['skills'][s]['kind'] == 'produced'))
print('Spell families detected:', len(family_children), list(family_children.keys()))
print('Plural/singular aliases merged:', alias_map)
