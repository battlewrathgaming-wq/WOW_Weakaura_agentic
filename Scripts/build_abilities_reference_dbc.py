"""
build_abilities_reference_dbc.py - EXPERIMENTAL. The "abilities" half of the
DBC-sourced pivot: one page listing every distinct ability touched by a
class's tree (every talent's own spell, everything those spells trigger, and
everything they teach), each as its own anchor card with real base state from
Spell.dbc/SpellCastTimes.dbc/SpellDuration.dbc - then nested under each
anchor: every talent that invests in it (its own tree node) or produces/
triggers it. This replaces the old prose-regex "produces" guessing with
direct spell-ID links, so relationships like Command: Hook -> Abomination
are stated by the game data, not inferred from a sentence.

The talent-tree-driven view (pick a spec, see what to invest in) stays a
SEPARATE page/section - this script only builds the ability reference half.
Necromancer only, static, no tick-selector yet - same staged plan as
build_ability_cards_dbc.py.

Usage:
    python3 build_abilities_reference_dbc.py <class_talents.json> <mpq_data_dir> <out.html>
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

def family_tag(name):
    """Ascension's own naming convention already marks a lot of family
    groupings ('Raise: X', 'Animate: X', 'Command: X') - surface that as a
    lightweight display tag rather than trying to invent bit-level labels
    for SpellClassMask (there's no official legend for what any given bit
    means; the classmask numbers are useful for finding relationships, not
    for naming them)."""
    if ': ' in name:
        return name.split(': ', 1)[0]
    return None

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

    ability_ids = set(talent_by_spell_id.keys())
    edges = []
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
                            ability_ids.add(tsid)
                            edges.append((sid, tsid, 'triggers'))
                        next_frontier.append(tsid)
            frontier = next_frontier
            depth += 1
        for m in TEACH_TAG.finditer(rec['Description_0'] or ''):
            tid = int(m.group(1))
            if tid in spell_by_id:
                ability_ids.add(tid)
                edges.append((sid, tid, 'teaches'))

    # --- SpellClassMask family-modifier pass ---
    # WotLK's spell-family system: a talent's aura can modify (cost,
    # cooldown, cast time, etc) OTHER spells in the same family WITHOUT ever
    # triggering or teaching them. A match exists when the modifying
    # effect's EffectSpellClassMask_A/B/C is non-zero AND bitwise-ANDs
    # against a target spell's own SpellClassMask (both must share the same
    # SpellClassSet - the family id; Necromancer's whole kit uses family 29).
    # We restrict targets to abilities already discovered via own/triggers/
    # teaches - matching against the raw DBC family pool (1,300+ spells,
    # including debug/test/rank-duplicate entries) produces heavy noise;
    # scoping to abilities the tree already touches keeps this precise.
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
            for target_id in list(ability_ids):
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
    # independently rather than via a trigger link, so the same-name merge
    # above never saw them together). Collapse any ability_ids sharing an
    # exact Name_0 into one canonical card - prefer an id that is itself
    # some talent's own spellId, else the lowest id - and remap every edge.
    by_name = defaultdict(list)
    for aid in ability_ids:
        by_name[spell_by_id[aid]['Name_0']].append(aid)
    canonical = {}
    for name, ids in by_name.items():
        ids_sorted = sorted(ids, key=lambda i: (i not in talent_by_spell_id, i))
        keep = ids_sorted[0]
        for other in ids_sorted:
            canonical[other] = keep
    edges = sorted(set((sid, canonical[aid], rel) for sid, aid, rel in edges))
    ability_ids = set(canonical.values())

    print('Modifier (SpellClassMask) edges found:', sum(1 for _, _, rel in edges if rel == 'modifies'))
    print('Duplicate-name groups collapsed:', sum(1 for ids in by_name.values() if len(ids) > 1))

    # --- Name-mention "compounds" pass ---
    # Spells are first-class, not just talents: some of the most important
    # compounding relationships (e.g. Army of the Dead buffing Ghouls while
    # scaling off live Abomination count) are stated only in prose, with NO
    # spellId or SpellClassMask link to the pets they reference at all. We
    # can't infer that generically, but Ascension's own "Raise: X"/
    # "Animate: X"/"Command: X" naming convention gives us a reliable set of
    # pet/mechanic bare names (Ghoul, Abomination, Skeletal Archer, ...) to
    # search for. Any ability's normalized description that mentions another
    # ability's bare name gets a 'compounds' edge - this catches
    # relationships regardless of whether the mentioning spell is itself a
    # talent's own node, a triggered spell, or a taught spell.
    PET_PREFIXES = ('Raise: ', 'Animate: ', 'Command: ')
    bare_name_to_id = {}
    for aid in ability_ids:
        name = spell_by_id[aid]['Name_0']
        for p in PET_PREFIXES:
            if name.startswith(p):
                bare_name_to_id[name[len(p):]] = aid
    compound_patterns = {tid: re.compile(r'\b' + re.escape(bare) + r's?\b')
                          for bare, tid in bare_name_to_id.items()}
    desc_cache = {aid: normalize(spell_by_id[aid]['Description_0'], spell_by_id[aid]) or '' for aid in ability_ids}
    for aid, desc in desc_cache.items():
        for target_id, pat in compound_patterns.items():
            if target_id == aid:
                continue
            if pat.search(desc):
                edges.append((aid, target_id, 'compounds'))
    edges = sorted(set(edges))
    print('Compounds (name-mention) edges found:', sum(1 for _, _, rel in edges if rel == 'compounds'))

    applies_to = defaultdict(list)
    modifier_note_cache = {}
    # Spells are first-class here, not just talents: a source can be a talent's
    # own node (has tree/maxPoints), OR a non-talent spell reached via
    # trigger/teach/compounds (e.g. "Frenzied Ghoul", reached only via a teach
    # tag) - those still need to show up, just without tree/maxPoints info.
    for source_sid, ability_id, rel in edges:
        talent = talent_by_spell_id.get(source_sid)
        source_rec = spell_by_id.get(source_sid)
        if not source_rec:
            continue
        entry = {
            'talent': talent['name'] if talent else source_rec['Name_0'],
            'tree': talent['tree'] if talent else None,
            'maxPoints': talent['maxPoints'] if talent else None,
            'spellId': source_sid, 'relationship': rel,
        }
        if rel in ('modifies', 'compounds'):
            # Neither relationship says what the source spell actually does on
            # its own - surface its own (normalized) description inline so the
            # reader doesn't have to go find that spell's own card to find out.
            if source_sid not in modifier_note_cache:
                modifier_note_cache[source_sid] = normalize(source_rec['Description_0'], source_rec)
            entry['note'] = modifier_note_cache[source_sid]
        applies_to[ability_id].append(entry)

    cards = []
    for aid in sorted(ability_ids):
        rec = spell_by_id.get(aid)
        if not rec:
            continue
        cooldown_ms = rec['CategoryRecoveryTime'] or rec['RecoveryTime']
        base_points = [v for v in (rec['EffectBasePoints_0'], rec['EffectBasePoints_1'], rec['EffectBasePoints_2']) if v not in (0, -1)]
        duration = fmt_ms(durations.get(rec['DurationIndex']))
        desc = normalize(rec['Description_0'], rec)
        for note in merged_notes.get(aid, []):
            if not duration and note['duration']:
                duration = note['duration']
            if not base_points and note['effectBasePoints']:
                base_points = note['effectBasePoints']
            if (not desc or len(note.get('desc') or '') > len(desc)) and note.get('desc'):
                desc = note['desc']
        cards.append({
            'id': aid,
            'name': rec['Name_0'],
            'family': family_tag(rec['Name_0']),
            'desc': desc,
            'cooldown': fmt_ms(cooldown_ms),
            'castTime': fmt_ms(cast_times.get(rec['CastingTimeIndex'])),
            'manaCost': rec['ManaCost'] or None,
            'school': school_mask_to_names(rec['SchoolMask']),
            'procChance': rec['ProcChance'] or None,
            'duration': duration,
            'effectBasePoints': base_points,
            'appliesTalents': sorted(applies_to.get(aid, []), key=lambda x: (x['relationship'] != 'own', x['tree'] or 'zzz', x['talent'])),
        })

    cards.sort(key=lambda c: (not any(a['relationship'] == 'own' for a in c['appliesTalents']), -len(c['appliesTalents'])))

    print('Total abilities surfaced:', len(cards))
    print('Abilities with 2+ talents applying to them:', sum(1 for c in cards if len(c['appliesTalents']) >= 2))

    payload = {'class': class_data['class'], 'cards': cards}
    doc = TEMPLATE.replace('__CLASS_NAME__', html.escape(class_data['class'])).replace(
        '__DATA_JSON__', json.dumps(payload)
    )
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(doc)
    print(f"Wrote {out_path} ({len(doc)} chars)")


TEMPLATE = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>__CLASS_NAME__ - Abilities Reference (DBC-sourced, experimental)</title>
<style>
  :root { --bg:#17161a; --panel:#201e1a; --line:#3a3630; --text:#ece8e0; --muted:#969084; --accent:#45db9c; --head-hover:#2a2721;
          --class-tag:#c98a3d; --spec-tag:#4d8fc4; }
  * { box-sizing: border-box; }
  body { background: var(--bg); color: var(--text); font-family: -apple-system, "Segoe UI", Arial, sans-serif; margin:0; padding:24px 20px 60px; max-width:960px; margin-inline:auto; }
  h1 { font-size:22px; margin:0 0 4px; color:var(--accent); font-weight:700; }
  .banner { background:#2a2313; border:1px solid #6b5a1f; color:#e8cf7a; font-size:12.5px; padding:8px 12px; border-radius:6px; margin-bottom:16px; line-height:1.5; }
  .toolbar { position: sticky; top:0; background:var(--bg); padding:10px 0; z-index:10; border-bottom:1px solid var(--line); margin-bottom:14px; }
  .toolbar input { width:100%; padding:9px 12px; border:1px solid var(--line); border-radius:6px; font-size:14px; background:var(--panel); color:var(--text); }
  .card { background:var(--panel); border:1px solid var(--line); border-radius:8px; margin-bottom:10px; padding:14px 16px; }
  .card h2 { font-size:16px; margin:0 0 6px; display:inline-block; }
  .idtag { color:var(--muted); font-size:11px; margin-left:8px; }
  .stat-row { display:flex; gap:14px; flex-wrap:wrap; margin:8px 0; font-size:12.5px; }
  .stat { background:#1c1a17; border:1px solid var(--line); border-radius:6px; padding:4px 9px; }
  .stat b { color:var(--accent); }
  .desc { color:var(--muted); font-size:12.5px; line-height:1.45; margin:8px 0; }
  .section-label { text-transform:uppercase; letter-spacing:0.05em; font-size:10.5px; color:var(--muted); margin-top:10px; }
  .talent-list { list-style:none; margin:6px 0 0; padding:0; }
  .talent-list li { padding:5px 0; border-top:1px solid var(--line); font-size:12.5px; }
  .talent-list li:first-child { border-top:none; }
  .tag { display:inline-block; font-size:10px; padding:1px 6px; border-radius:4px; margin-left:6px; color:#1a1a1a; }
  .tag.own { background:var(--accent); }
  .tag.triggers { background:var(--spec-tag); color:#0d1720; }
  .tag.teaches { background:var(--class-tag); }
  .tag.modifies { background:#c45b96; color:#2a0f1e; }
  .tag.compounds { background:#e0a63f; color:#2a1c05; }
  .fam-badge { display:inline-block; font-size:10.5px; padding:1px 7px; border-radius:10px; margin-left:8px; background:#1c1a17; border:1px solid var(--line); color:var(--muted); vertical-align:middle; }
  .no-match { color:var(--muted); font-style:italic; padding:20px 0; }
  .talent-note { color:var(--muted); font-size:11.5px; line-height:1.4; margin:3px 0 0; }
</style>
</head>
<body>
<h1>__CLASS_NAME__ &mdash; abilities reference (DBC-sourced, experimental)</h1>
<div class="banner">Every ability the tree touches (talent nodes, plus whatever they trigger or teach), read straight from Spell.dbc - not tooltip text. Each card lists every talent that invests in, triggers, or teaches it. This is the ability anchor list; the talent-tree investment view is a separate page.</div>
<div class="toolbar"><input id="search" type="text" placeholder="Search an ability or talent name..."></div>
<div id="cards"></div>
<script>
const DATA = __DATA_JSON__;
const el = document.getElementById('cards');
DATA.cards.forEach(c => {
  const card = document.createElement('div');
  card.className = 'card';
  card.dataset.searchText = (c.name + ' ' + c.appliesTalents.map(a => a.talent).join(' ')).toLowerCase();

  let statRow = '<div class="stat-row">';
  if (c.cooldown) statRow += `<span class="stat"><b>CD</b> ${c.cooldown}</span>`;
  if (c.castTime) statRow += `<span class="stat"><b>Cast</b> ${c.castTime}</span>`;
  if (c.manaCost) statRow += `<span class="stat"><b>Cost</b> ${c.manaCost}</span>`;
  if (c.procChance) statRow += `<span class="stat"><b>Proc</b> ${c.procChance}%</span>`;
  if (c.duration) statRow += `<span class="stat"><b>Duration</b> ${c.duration}</span>`;
  if (c.effectBasePoints.length) statRow += `<span class="stat"><b>Base points</b> ${c.effectBasePoints.join(', ')}</span>`;
  statRow += `<span class="stat"><b>School</b> ${c.school.join('/')}</span>`;
  statRow += '</div>';

  let talentsHtml = '';
  if (c.appliesTalents.length) {
    talentsHtml = '<div class="section-label">Related spells</div><ul class="talent-list">' +
      c.appliesTalents.map(a => `<li>${a.talent} <span class="tag ${a.relationship}">${a.relationship}</span> <span class="idtag">${a.tree ? `${a.tree}, ${a.maxPoints} pt${a.maxPoints===1?'':'s'}` : 'non-talent spell'}</span>${a.note ? `<div class="talent-note">${a.note.replace(/\n/g,'<br>')}</div>` : ''}</li>`).join('') +
      '</ul>';
  }

  card.innerHTML = `
    <h2>${c.name}</h2>${c.family ? `<span class="fam-badge">${c.family}</span>` : ''}<span class="idtag">spell ${c.id}</span>
    ${statRow}
    <div class="desc">${(c.desc||'').replace(/\n/g,'<br>')}</div>
    ${talentsHtml}
  `;
  el.appendChild(card);
});

document.getElementById('search').addEventListener('input', e => {
  const q = e.target.value.trim().toLowerCase();
  document.querySelectorAll('.card').forEach(card => {
    card.style.display = (!q || card.dataset.searchText.includes(q)) ? '' : 'none';
  });
});
</script>
</body>
</html>
"""

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Usage: python3 build_abilities_reference_dbc.py <class_talents.json> <mpq_data_dir> <out.html>")
        sys.exit(1)
    build(sys.argv[1], sys.argv[2], sys.argv[3])
