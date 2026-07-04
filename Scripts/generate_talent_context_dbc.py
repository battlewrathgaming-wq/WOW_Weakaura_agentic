"""
generate_talent_context_dbc.py - EXPERIMENTAL. The "talent context" half of
the DBC-sourced pivot: same ability graph as build_abilities_reference_dbc.py
(talent's own spell -> what it triggers -> what it teaches, all real spell-ID
links from Spell.dbc), but organized per spec like the existing tree readouts
(Class > Spec > Ability > Talent) instead of one flat class-wide list.

The one filtering rule that matters here: an ability only appears on a given
spec's page if at least one talent FROM THAT SPEC (or Class) actually applies
to it. An ability that's only reachable through some other spec's talent gets
dropped from this spec's view entirely - the goal is flattening investment
reasoning per spec, not showing every ability the class could ever touch.

Usage:
    python3 generate_talent_context_dbc.py <class_talents.json> <mpq_data_dir> <out.html>
"""
import json, re, struct, sys, html, os
from collections import defaultdict
import mpyq
from tooltip_normalize import make_normalizer, load_float_dbc

FIELD_NAMES = [
    'ID','Category','DispelType','Mechanic','Attributes','AttributesEx','AttributesExB','AttributesExC',
    'AttributesExD','AttributesExE','AttributesExF','AttributesExG',
    'ShapeshiftMask_0','ShapeshiftMask_1','ShapeshiftExclude_0','ShapeshiftExclude_1',
    'Targets','TargetCreatureType','RequiresSpellFocus','FacingCasterFlags',
    'CasterAuraState','TargetAuraState','ExcludeCasterAuraState','ExcludeTargetAuraState',
    'CasterAuraSpell','TargetAuraSpell','ExcludeCasterAuraSpell','ExcludeTargetAuraSpell',
    'CastingTimeIndex','RecoveryTime','CategoryRecoveryTime',
    'InterruptFlags','AuraInterruptFlags','ChannelInterruptFlags',
    'ProcTypeMask','ProcChance','ProcCharges','MaxLevel','BaseLevel','SpellLevel','DurationIndex',
    'PowerType','ManaCost','ManaCostPerLevel','ManaPerSecond','ManaPerSecondPerLevel',
    'RangeIndex','Speed','ModalNextSpell','CumulativeAura',
    'Totem_0','Totem_1',
    'Reagent_0','Reagent_1','Reagent_2','Reagent_3','Reagent_4','Reagent_5','Reagent_6','Reagent_7',
    'ReagentCount_0','ReagentCount_1','ReagentCount_2','ReagentCount_3','ReagentCount_4','ReagentCount_5','ReagentCount_6','ReagentCount_7',
    'EquippedItemClass','EquippedItemSubclass','EquippedItemInvTypes',
    'Effect_0','Effect_1','Effect_2',
    'EffectDieSides_0','EffectDieSides_1','EffectDieSides_2',
    'EffectRealPointsPerLevel_0','EffectRealPointsPerLevel_1','EffectRealPointsPerLevel_2',
    'EffectBasePoints_0','EffectBasePoints_1','EffectBasePoints_2',
    'EffectMechanic_0','EffectMechanic_1','EffectMechanic_2',
    'EffectImplicitTargetA_0','EffectImplicitTargetA_1','EffectImplicitTargetA_2',
    'EffectImplicitTargetB_0','EffectImplicitTargetB_1','EffectImplicitTargetB_2',
    'EffectRadiusIndex_0','EffectRadiusIndex_1','EffectRadiusIndex_2',
    'EffectAura_0','EffectAura_1','EffectAura_2',
    'EffectAuraPeriod_0','EffectAuraPeriod_1','EffectAuraPeriod_2',
    'EffectAmplitude_0','EffectAmplitude_1','EffectAmplitude_2',
    'EffectChainTargets_0','EffectChainTargets_1','EffectChainTargets_2',
    'EffectItemType_0','EffectItemType_1','EffectItemType_2',
    'EffectMiscValue_0','EffectMiscValue_1','EffectMiscValue_2',
    'EffectMiscValueB_0','EffectMiscValueB_1','EffectMiscValueB_2',
    'EffectTriggerSpell_0','EffectTriggerSpell_1','EffectTriggerSpell_2',
    'EffectPointsPerCombo_0','EffectPointsPerCombo_1','EffectPointsPerCombo_2',
    'EffectSpellClassMask_A_0','EffectSpellClassMask_A_1','EffectSpellClassMask_A_2',
    'EffectSpellClassMask_B_0','EffectSpellClassMask_B_1','EffectSpellClassMask_B_2',
    'EffectSpellClassMask_C_0','EffectSpellClassMask_C_1','EffectSpellClassMask_C_2',
    'SpellVisualID_0','SpellVisualID_1','SpellIconID','ActiveIconID','SpellPriority',
] + [f'Name_{i}' for i in range(16)] + ['Name_lang_mask'] \
  + [f'NameSubtext_{i}' for i in range(16)] + ['NameSubtext_lang_mask'] \
  + [f'Description_{i}' for i in range(16)] + ['Description_lang_mask'] \
  + [f'AuraDescription_{i}' for i in range(16)] + ['AuraDescription_lang_mask'] \
  + [
    'ManaCostPct','StartRecoveryCategory','StartRecoveryTime','MaxTargetLevel',
    'SpellClassSet','SpellClassMask_0','SpellClassMask_1','SpellClassMask_2',
    'MaxTargets','DefenseType','PreventionType','StanceBarOrder',
    'EffectChainAmplitude_0','EffectChainAmplitude_1','EffectChainAmplitude_2',
    'MinFactionID','MinReputation','RequiredAuraVision',
    'RequiredTotemCategoryID_0','RequiredTotemCategoryID_1',
    'RequiredAreasID','SchoolMask','RuneCostID','SpellMissileID','PowerDisplayID',
    'EffectBonusCoefficient_0','EffectBonusCoefficient_1','EffectBonusCoefficient_2',
    'DescriptionVariablesID','Difficulty',
]
assert len(FIELD_NAMES) == 234

INT32_FIELDS = {
    'PowerType','Reagent_0','Reagent_1','Reagent_2','Reagent_3','Reagent_4','Reagent_5','Reagent_6','Reagent_7',
    'EquippedItemClass','EquippedItemSubclass','EquippedItemInvTypes',
    'EffectDieSides_0','EffectDieSides_1','EffectDieSides_2',
    'EffectBasePoints_0','EffectBasePoints_1','EffectBasePoints_2',
    'EffectMiscValue_0','EffectMiscValue_1','EffectMiscValue_2',
    'EffectMiscValueB_0','EffectMiscValueB_1','EffectMiscValueB_2',
    'EffectTriggerSpell_0','EffectTriggerSpell_1','EffectTriggerSpell_2',
    'StanceBarOrder','RequiredAreasID','PowerDisplayID','DescriptionVariablesID',
}
STRING_FIELDS = {f for f in FIELD_NAMES if (f.startswith('Name_') or f.startswith('NameSubtext_')
                 or f.startswith('Description_') or f.startswith('AuraDescription_')) and not f.endswith('lang_mask')}

SCHOOL_NAMES = {1: 'Physical', 2: 'Holy', 4: 'Fire', 8: 'Nature', 16: 'Frost', 32: 'Shadow', 64: 'Arcane'}
def school_mask_to_names(mask):
    return [name for bit, name in SCHOOL_NAMES.items() if mask & bit] or ['None']

TEACH_TAG = re.compile(r'@s:(\d+):\d+@')
CLASS_COLORS = {
    'Barbarian': '#ae7251', 'Witch Doctor': '#f500ff', 'Felsworn': '#75fa00', 'Witch Hunter': '#866edd',
    'Stormbringer': '#007ded', 'Knight of Xoroth': '#fc0005', 'Guardian': '#9c9482', 'Templar': '#fffab3',
    'Bloodmage': '#c66161', 'Ranger': '#bff06b', 'Chronomancer': '#ffed4a', 'Necromancer': '#45db9c',
    'Pyromancer': '#ff6112', 'Cultist': '#9c45f2', 'Starcaller': '#8fffff', 'Sun Cleric': '#ffb340',
    'Tinker': '#d9d9d9', 'Venomancer': '#6ba600', 'Reaper': '#0a876b', 'Primalist': '#e38c59', 'Runemaster': '#40c7eb',
}
DEFAULT_ACCENT = '#c9a227'

def load_simple_dbc(mpq, name):
    data = mpq.read_file('DBFilesClient\\' + name)
    magic, rc, fc, rs, sbs = struct.unpack('<4sIIII', data[:20])
    out = {}
    for i in range(rc):
        base = 20 + i * rs
        vals = struct.unpack('<4i', data[base:base+16])
        out[vals[0]] = vals[1]
    return out

def load_spell_dbc(mpq):
    data = mpq.read_file('DBFilesClient\\Spell.dbc')
    magic, record_count, field_count, record_size, string_block_size = struct.unpack('<4sIIII', data[:20])
    assert magic == b'WDBC' and field_count == 234
    records_start = 20
    records_end = records_start + record_count * record_size
    string_block = data[records_end:records_end + string_block_size]

    def read_cstr(offset):
        if offset == 0:
            return ''
        end = string_block.find(b'\x00', offset)
        return string_block[offset:end].decode('utf-8', errors='replace')

    by_id = {}
    for i in range(record_count):
        base = records_start + i * record_size
        raw = struct.unpack('<234I', data[base:base + record_size])
        rec = {}
        for idx, fname in enumerate(FIELD_NAMES):
            val = raw[idx]
            if fname in INT32_FIELDS:
                val = struct.unpack('<i', struct.pack('<I', val))[0]
            elif fname in STRING_FIELDS:
                val = read_cstr(val)
            rec[fname] = val
        by_id[rec['ID']] = rec
    return by_id

def open_mpq_set(data_dir):
    archives = [mpyq.MPQArchive(os.path.join(data_dir, 'patch-T.MPQ')),
                mpyq.MPQArchive(os.path.join(data_dir, 'patch-S.MPQ'))]
    class MultiMPQ:
        def read_file(self, name):
            for a in archives:
                try:
                    d = a.read_file(name)
                    if d:
                        return d
                except Exception:
                    pass
            return None
    return MultiMPQ()

def fmt_ms(ms):
    if ms is None:
        return None
    if ms < 0:
        return 'Until cancelled'
    if ms == 0:
        return 'Instant'
    if ms >= 60000 and ms % 60000 == 0:
        return f'{ms // 60000} min'
    if ms >= 1000:
        return f'{ms / 1000:g} sec'
    return f'{ms} ms'

def build(talents_path, data_dir, out_path):
    with open(talents_path) as f:
        class_data = json.load(f)
    talents = class_data['talents']
    class_name = class_data['class']
    accent = CLASS_COLORS.get(class_name, DEFAULT_ACCENT)
    spec_trees = [t for t in class_data['trees'] if t != 'Class']

    mpq = open_mpq_set(data_dir)
    print('Loading Spell.dbc (this takes ~30-40s)...')
    spell_by_id = load_spell_dbc(mpq)
    cast_times = load_simple_dbc(mpq, 'SpellCastTimes.dbc')
    durations = load_simple_dbc(mpq, 'SpellDuration.dbc')
    print('Loaded', len(spell_by_id), 'spell records')
    radii = load_float_dbc(mpq, 'SpellRadius.dbc')
    normalize = make_normalizer(spell_by_id, durations, radii, fmt_ms)

    talent_by_spell_id = {}
    for t in talents:
        sid = t.get('spellId')
        if sid and sid in spell_by_id:
            talent_by_spell_id[sid] = t

    # Build the full ability graph once (same as build_abilities_reference_dbc.py)
    edges = []  # (talent_spell_id, ability_id, relationship)
    # A talent's own tree-node spell VERY often just triggers a second spell
    # that carries the real duration/effect specifics (e.g. Bone King's own
    # spell 707175 triggers implementation spell 707176 - both literally
    # named "Bone King"). Treat a same-name trigger target as one merged
    # ability, not a second card - only a DIFFERENT-named trigger target
    # (e.g. Command: Hook -> Grave March) is a genuinely separate ability.
    merged_notes = defaultdict(list)
    for sid, t in talent_by_spell_id.items():
        edges.append((sid, sid, 'own'))
        rec = spell_by_id[sid]
        own_name = rec['Name_0']
        frontier = [sid]
        seen = {sid}
        depth = 0
        while frontier and depth < 2:
            next_frontier = []
            for cur in frontier:
                crec = spell_by_id.get(cur)
                if not crec:
                    continue
                for tsid in (crec['EffectTriggerSpell_0'], crec['EffectTriggerSpell_1'], crec['EffectTriggerSpell_2']):
                    if tsid and tsid in spell_by_id and tsid not in seen:
                        seen.add(tsid)
                        trec = spell_by_id[tsid]
                        if trec['Name_0'] == own_name:
                            merged_notes[sid].append({
                                'duration': fmt_ms(durations.get(trec['DurationIndex'])),
                                'effectBasePoints': [v for v in (trec['EffectBasePoints_0'], trec['EffectBasePoints_1'], trec['EffectBasePoints_2']) if v not in (0, -1)],
                                'desc': normalize(trec['Description_0'], trec),
                            })
                        else:
                            edges.append((sid, tsid, 'triggers'))
                        next_frontier.append(tsid)
            frontier = next_frontier
            depth += 1
        for m in TEACH_TAG.finditer(rec['Description_0'] or ''):
            tid = int(m.group(1))
            if tid in spell_by_id:
                edges.append((sid, tid, 'teaches'))

    # Track which spec(s) each ability belongs to via its own/triggers/teaches
    # discovery lineage - needed below because a 'compounds' edge's SOURCE can
    # be a non-talent spell (e.g. "Frenzied Ghoul", only reachable via a
    # teach tag on the talent "Ghoul Mastery"). Such a spell has no tree of
    # its own to check against a spec filter, so it inherits the tree(s) of
    # whatever talent(s) actually reached it.
    ability_owner_trees = defaultdict(set)
    for src_sid, aid, rel in edges:
        t = talent_by_spell_id.get(src_sid)
        if t:
            ability_owner_trees[aid].add(t['tree'])

    # --- SpellClassMask family-modifier pass ---
    # WotLK's spell-family system: a talent's aura can modify (cost,
    # cooldown, cast time, etc) OTHER spells in the same family WITHOUT ever
    # triggering or teaching them. A match exists when the modifying
    # effect's EffectSpellClassMask_A/B/C is non-zero AND bitwise-ANDs
    # against a target spell's own SpellClassMask (both must share the same
    # SpellClassSet - the family id). Targets are restricted to abilities
    # already discovered via own/triggers/teaches to avoid raw-DBC noise
    # (debug/test spells, rank duplicates) from the full family pool.
    known_ability_ids = set(aid for _, aid, _ in edges)
    for sid, t in talent_by_spell_id.items():
        rec = spell_by_id[sid]
        css = rec['SpellClassSet']
        if not css:
            continue
        for e in range(3):
            if rec[f'Effect_{e}'] == 0:
                continue  # dead/unused effect slot - its EffectSpellClassMask is stale
                          # leftover data, not a real modifier declaration (confirmed via
                          # Skeletal Artillery: Effect_2=0 but carried a classmask that
                          # false-matched 5 unrelated Raise/Command spells - see PIPELINE.md)
            a = rec[f'EffectSpellClassMask_A_{e}']
            b = rec[f'EffectSpellClassMask_B_{e}']
            c = rec[f'EffectSpellClassMask_C_{e}']
            if not (a or b or c):
                continue
            for target_id in known_ability_ids:
                if target_id == sid:
                    continue
                trec = spell_by_id[target_id]
                if trec['SpellClassSet'] != css:
                    continue
                if (trec['SpellClassMask_0'] & a) or (trec['SpellClassMask_1'] & b) or (trec['SpellClassMask_2'] & c):
                    edges.append((sid, target_id, 'modifies'))

    # --- Canonicalize duplicate-named abilities ---
    # Ascension frequently ships more than one spell ID for the exact same
    # named ability (rank variants, or a wrapper/impl pair reached
    # independently rather than via a trigger link). Collapse any ability
    # ids sharing an exact Name_0 into one canonical card and remap edges.
    from collections import defaultdict as _dd
    by_name = _dd(list)
    for aid in known_ability_ids:
        by_name[spell_by_id[aid]['Name_0']].append(aid)
    canonical = {}
    for name, ids in by_name.items():
        ids_sorted = sorted(ids, key=lambda i: (i not in talent_by_spell_id, i))
        keep = ids_sorted[0]
        for other in ids_sorted:
            canonical[other] = keep
    edges = sorted(set((sid, canonical[aid], rel) for sid, aid, rel in edges))
    canonical_ids = set(canonical.values())
    print('Modifier (SpellClassMask) edges found:', sum(1 for _, _, rel in edges if rel == 'modifies'))
    print('Duplicate-name groups collapsed:', sum(1 for ids in by_name.values() if len(ids) > 1))

    # --- Name-mention "compounds" pass ---
    # Spells are first-class, not just talents: some compounding
    # relationships (e.g. Army of the Dead buffing Ghouls while scaling off
    # live Abomination count) are stated only in prose, with no spellId or
    # SpellClassMask link to the pets they reference. Ascension's own
    # "Raise: X"/"Animate: X"/"Command: X" naming convention gives a
    # reliable set of pet/mechanic bare names to search other descriptions
    # for - regardless of whether the mentioning spell is a talent's own
    # node, a triggered spell, or a taught spell.
    PET_PREFIXES = ('Raise: ', 'Animate: ', 'Command: ')
    bare_name_to_id = {}
    for aid in canonical_ids:
        name = spell_by_id[aid]['Name_0']
        for p in PET_PREFIXES:
            if name.startswith(p):
                bare_name_to_id[name[len(p):]] = aid
    compound_patterns = {tid: re.compile(r'\b' + re.escape(bare) + r's?\b')
                          for bare, tid in bare_name_to_id.items()}
    desc_cache = {aid: normalize(spell_by_id[aid]['Description_0'], spell_by_id[aid]) or '' for aid in canonical_ids}
    for aid, desc in desc_cache.items():
        for target_id, pat in compound_patterns.items():
            if target_id == aid:
                continue
            if pat.search(desc):
                edges.append((aid, target_id, 'compounds'))
                ability_owner_trees[target_id] |= ability_owner_trees.get(aid, set())
    edges = sorted(set(edges))
    print('Compounds (name-mention) edges found:', sum(1 for _, _, rel in edges if rel == 'compounds'))

    def family_tag(name):
        if ': ' in name:
            return name.split(': ', 1)[0]
        return None

    def card_from_ability(aid, applies):
        rec = spell_by_id[aid]
        cooldown_ms = rec['CategoryRecoveryTime'] or rec['RecoveryTime']
        base_points = [v for v in (rec['EffectBasePoints_0'], rec['EffectBasePoints_1'], rec['EffectBasePoints_2']) if v not in (0, -1)]
        duration = fmt_ms(durations.get(rec['DurationIndex']))
        desc = normalize(rec['Description_0'], rec)
        # Fold in the merged wrapper+implementation spell's specifics (see
        # merged_notes above) - the tree-node's own record is often just a
        # cast/cooldown shell with no duration/base-points of its own, and
        # the real numbers live on the same-named spell it triggers.
        for note in merged_notes.get(aid, []):
            if not duration and note['duration']:
                duration = note['duration']
            if not base_points and note['effectBasePoints']:
                base_points = note['effectBasePoints']
            if (not desc or len(note.get('desc') or '') > len(desc)) and note.get('desc'):
                desc = note['desc']
        return {
            'id': aid, 'name': rec['Name_0'], 'desc': desc, 'family': family_tag(rec['Name_0']),
            'cooldown': fmt_ms(cooldown_ms), 'castTime': fmt_ms(cast_times.get(rec['CastingTimeIndex'])),
            'manaCost': rec['ManaCost'] or None, 'school': school_mask_to_names(rec['SchoolMask']),
            'procChance': rec['ProcChance'] or None, 'duration': duration,
            'effectBasePoints': base_points, 'appliesTalents': applies,
        }

    specs_payload = []
    modifier_note_cache = {}
    for spec in spec_trees:
        available_trees = {'Class', spec}
        # THE FILTERING RULE: only count edges from talents actually in this spec/Class.
        spec_applies_to = defaultdict(list)
        for source_sid, ability_id, rel in edges:
            talent = talent_by_spell_id.get(source_sid)
            source_rec = spell_by_id.get(source_sid)
            if not source_rec:
                continue
            # A direct talent qualifies by its own tree. A non-talent source
            # spell (e.g. "Frenzied Ghoul", reached only via a teach tag) has
            # no tree of its own - it qualifies if the talent(s) that
            # actually discovered it belong to this spec (see
            # ability_owner_trees above).
            if talent:
                qualifies = talent['tree'] in available_trees
            else:
                qualifies = bool(ability_owner_trees.get(source_sid, set()) & available_trees)
            if not qualifies:
                continue
            entry = {
                'talent': talent['name'] if talent else source_rec['Name_0'],
                'tree': talent['tree'] if talent else None,
                'maxPoints': talent['maxPoints'] if talent else None,
                'spellId': source_sid, 'relationship': rel,
            }
            if rel in ('modifies', 'compounds'):
                if source_sid not in modifier_note_cache:
                    modifier_note_cache[source_sid] = normalize(source_rec['Description_0'], source_rec)
                entry['note'] = modifier_note_cache[source_sid]
            spec_applies_to[ability_id].append(entry)
        # Drop any ability with zero applying talents for THIS spec - flatten, don't fan out.
        cards = [card_from_ability(aid, sorted(applies, key=lambda x: (x['relationship'] != 'own', x['talent'])))
                 for aid, applies in spec_applies_to.items() if applies]
        cards.sort(key=lambda c: (not any(a['relationship'] == 'own' for a in c['appliesTalents']), -len(c['appliesTalents'])))
        specs_payload.append({'spec': spec, 'cards': cards})
        print(f'{spec}: {len(cards)} abilities shown (with >=1 applying talent)')

    payload = {'class': class_name, 'specs': specs_payload}
    doc = TEMPLATE.replace('__CLASS_NAME__', html.escape(class_name)).replace(
        '__ACCENT__', accent
    ).replace('__DATA_JSON__', json.dumps(payload))
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(doc)
    print(f"Wrote {out_path} ({len(doc)} chars)")


TEMPLATE = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>__CLASS_NAME__ - Talent Context by Spec (DBC-sourced, experimental)</title>
<style>
  :root { --bg:#17161a; --panel:#201e1a; --line:#3a3630; --text:#ece8e0; --muted:#969084; --accent:__ACCENT__; --head-hover:#2a2721;
          --class-tag:#c98a3d; --spec-tag:#4d8fc4; }
  * { box-sizing: border-box; }
  body { background: var(--bg); color: var(--text); font-family: -apple-system, "Segoe UI", Arial, sans-serif; margin:0; padding:24px 20px 60px; max-width:960px; margin-inline:auto; }
  h1 { font-size:22px; margin:0 0 4px; color:var(--accent); font-weight:700; }
  .banner { background:#2a2313; border:1px solid #6b5a1f; color:#e8cf7a; font-size:12.5px; padding:8px 12px; border-radius:6px; margin-bottom:16px; line-height:1.5; }
  .sub { color:var(--muted); font-size:13px; margin-bottom:14px; line-height:1.5; }
  .tabs { display:flex; gap:6px; margin-bottom:14px; flex-wrap:wrap; position:sticky; top:0; background:var(--bg); padding:10px 0; z-index:10; border-bottom:1px solid var(--line); }
  .tab { padding:7px 14px; border:1px solid var(--line); border-radius:6px; background:var(--panel); cursor:pointer; font-size:13.5px; color:var(--muted); }
  .tab.active { border-color:var(--accent); color:var(--accent); font-weight:600; }
  .spec-section { display:none; }
  .spec-section.active { display:block; }
  .card { background:var(--panel); border:1px solid var(--line); border-radius:8px; margin-bottom:10px; overflow:hidden; }
  .card-head { display:flex; align-items:center; gap:10px; width:100%; padding:13px 16px; background:none; border:none; cursor:pointer; text-align:left; font:inherit; color:inherit; }
  .card-head:hover { background:var(--head-hover); }
  .chevron { flex:0 0 auto; font-size:12px; color:var(--muted); transition:transform .25s ease, color .25s ease; }
  .card-head.open .chevron { transform:rotate(90deg); color:var(--accent); }
  .card-head h2 { font-size:16px; margin:0; flex:1; color:var(--text); }
  .tcount { color:var(--muted); font-size:12px; }
  .card-body-wrap { display:grid; grid-template-rows:0fr; transition:grid-template-rows .25s ease; }
  .card-body-wrap.open { grid-template-rows:1fr; }
  .card-body-inner { overflow:hidden; }
  .card-body-pad { padding:2px 16px 14px; }
  .stat-row { display:flex; gap:14px; flex-wrap:wrap; margin:8px 0; font-size:12.5px; }
  .stat { background:#1c1a17; border:1px solid var(--line); border-radius:6px; padding:4px 9px; }
  .stat b { color:var(--accent); }
  .desc { color:var(--muted); font-size:12.5px; line-height:1.45; margin:8px 0; }
  .section-label { text-transform:uppercase; letter-spacing:.05em; font-size:10.5px; color:var(--muted); margin-top:8px; }
  .talent-list { list-style:none; margin:6px 0 0; padding:0; }
  .talent-list li { padding:5px 0; border-top:1px solid var(--line); font-size:12.5px; }
  .talent-list li:first-child { border-top:none; }
  .tag { display:inline-block; font-size:10px; padding:1px 6px; border-radius:4px; margin-left:6px; color:#1a1a1a; }
  .tag.own { background:var(--accent); }
  .tag.triggers { background:var(--spec-tag); color:#0d1720; }
  .tag.teaches { background:var(--class-tag); }
  .tag.modifies { background:#c45b96; color:#2a0f1e; }
  .tag.compounds { background:#e0a63f; color:#2a1c05; }
  .talent-note { color:var(--muted); font-size:11.5px; line-height:1.4; margin:3px 0 0; }
  .fam-badge { display:inline-block; font-size:10.5px; padding:1px 7px; border-radius:10px; margin-left:8px; background:#1c1a17; border:1px solid var(--line); color:var(--muted); vertical-align:middle; }
</style>
</head>
<body>
<h1>__CLASS_NAME__ &mdash; talent context by spec (DBC-sourced, experimental)</h1>
<div class="banner">Same ability graph as the abilities reference page (real spell-ID links from Spell.dbc, not tooltip text), but scoped per spec. An ability only shows up here if a talent from that spec (or Class) actually applies to it - abilities only reachable through a different spec are left off, to keep each spec's view flat.</div>
<div class="sub">Pick a spec tab, press an ability to see which talents invest in, trigger, or teach it.</div>
<div class="tabs" id="tabs"></div>
<div id="sections"></div>
<script>
const DATA = __DATA_JSON__;
const tabsEl = document.getElementById('tabs');
const sectionsEl = document.getElementById('sections');

function setCardOpen(head, wrap, open) {
  head.classList.toggle('open', open);
  wrap.classList.toggle('open', open);
}

DATA.specs.forEach((s, i) => {
  const tab = document.createElement('div');
  tab.className = 'tab' + (i === 0 ? ' active' : '');
  tab.textContent = s.spec + ' (' + s.cards.length + ')';
  tab.onclick = () => setActiveSpec(i);
  tabsEl.appendChild(tab);

  const section = document.createElement('div');
  section.className = 'spec-section' + (i === 0 ? ' active' : '');
  section.dataset.specIndex = i;

  s.cards.forEach(c => {
    const card = document.createElement('div');
    card.className = 'card';
    let statRow = '<div class="stat-row">';
    if (c.cooldown) statRow += `<span class="stat"><b>CD</b> ${c.cooldown}</span>`;
    if (c.castTime) statRow += `<span class="stat"><b>Cast</b> ${c.castTime}</span>`;
    if (c.manaCost) statRow += `<span class="stat"><b>Cost</b> ${c.manaCost}</span>`;
    if (c.procChance) statRow += `<span class="stat"><b>Proc</b> ${c.procChance}%</span>`;
    if (c.duration) statRow += `<span class="stat"><b>Duration</b> ${c.duration}</span>`;
    if (c.effectBasePoints.length) statRow += `<span class="stat"><b>Base points</b> ${c.effectBasePoints.join(', ')}</span>`;
    statRow += `<span class="stat"><b>School</b> ${c.school.join('/')}</span></div>`;

    const talentsHtml = '<div class="section-label">Related spells</div><ul class="talent-list">' +
      c.appliesTalents.map(a => `<li>${a.talent} <span class="tag ${a.relationship}">${a.relationship}</span> <span style="color:var(--muted);font-size:11px">${a.tree ? `${a.tree}, ${a.maxPoints} pt${a.maxPoints===1?'':'s'}` : 'non-talent spell'}</span>${a.note ? `<div class="talent-note">${a.note.replace(/\n/g,'<br>')}</div>` : ''}</li>`).join('') +
      '</ul>';

    card.innerHTML =
      `<button class="card-head" aria-expanded="false">` +
        `<span class="chevron">&#9656;</span><h2>${c.name}</h2>${c.family ? `<span class="fam-badge">${c.family}</span>` : ''}` +
        `<span class="tcount">${c.appliesTalents.length} talent${c.appliesTalents.length===1?'':'s'}</span>` +
      `</button>` +
      `<div class="card-body-wrap"><div class="card-body-inner"><div class="card-body-pad">` +
        statRow + `<div class="desc">${(c.desc||'').replace(/\n/g,'<br>')}</div>` + talentsHtml +
      `</div></div></div>`;

    const head = card.querySelector('.card-head');
    const wrap = card.querySelector('.card-body-wrap');
    head.addEventListener('click', () => setCardOpen(head, wrap, !head.classList.contains('open')));
    section.appendChild(card);
  });
  sectionsEl.appendChild(section);
});

function setActiveSpec(i) {
  document.querySelectorAll('.tab').forEach((el, idx) => el.classList.toggle('active', idx === i));
  document.querySelectorAll('.spec-section').forEach(el => el.classList.toggle('active', +el.dataset.specIndex === i));
}
</script>
</body>
</html>
"""

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Usage: python3 generate_talent_context_dbc.py <class_talents.json> <mpq_data_dir> <out.html>")
        sys.exit(1)
    build(sys.argv[1], sys.argv[2], sys.argv[3])
