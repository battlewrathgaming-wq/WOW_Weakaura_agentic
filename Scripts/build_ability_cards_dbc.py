"""
build_ability_cards_dbc.py - EXPERIMENTAL. First pass at building ability data
FROM THE GAME'S OWN Spell.dbc (extracted from the client's MPQ patches) instead
of parsing tooltip prose. The Ascension talent tree JSON (Input/<class>_talents.json)
is used only as a POINTER for "which spell IDs are actually live on the tree
right now" (via its per-talent spellId field) - the real ability data (base
cooldown/cast time/mana cost/duration, and what a talent's spell actually
triggers) is read directly from Spell.dbc + SpellCastTimes.dbc + SpellDuration.dbc.

Static readout only (no interactive tick-selector yet) - proving the data
pivot is sound before adding interactivity on top, per plan.

Key finding this confirms: a talent-tree node's own spell record often carries
the PLAYER-FACING cadence (cooldown, cast time) while the effect it actually
triggers (EffectTriggerSpell) is a SEPARATE spell record carrying the real
mechanical specifics (duration, effect base points). Both get shown.

Usage:
    python3 build_ability_cards_dbc.py <class_talents.json> <mpq_data_dir> <out.html>
"""
import json, re, struct, sys, html
import mpyq

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

def load_simple_dbc(mpq, name):
    """4-field (ID, Value, PerLevel, Min/Max) DBCs - SpellCastTimes, SpellDuration."""
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
    """Spell.dbc lives in patch-T.MPQ, SpellCastTimes/SpellDuration in patch-S.MPQ
    in this client install - open both, callers just ask for a file by name."""
    import os
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

def spell_summary(rec):
    cooldown_ms = rec['CategoryRecoveryTime'] or rec['RecoveryTime']
    return {
        'id': rec['ID'],
        'name': rec['Name_0'],
        'desc': rec['Description_0'],
        'castingTimeIndex': rec['CastingTimeIndex'],
        'cooldownMs': cooldown_ms,
        'manaCost': rec['ManaCost'],
        'procChance': rec['ProcChance'],
        'schoolMask': rec['SchoolMask'],
        'durationIndex': rec['DurationIndex'],
        'effect': [rec['Effect_0'], rec['Effect_1'], rec['Effect_2']],
        'effectTriggerSpell': [rec['EffectTriggerSpell_0'], rec['EffectTriggerSpell_1'], rec['EffectTriggerSpell_2']],
        'effectBasePoints': [rec['EffectBasePoints_0'], rec['EffectBasePoints_1'], rec['EffectBasePoints_2']],
    }

def build(talents_path, data_dir, out_path):
    with open(talents_path) as f:
        class_data = json.load(f)

    mpq = open_mpq_set(data_dir)
    print('Loading Spell.dbc (this takes ~30-40s)...')
    spell_by_id = load_spell_dbc(mpq)
    print('Loaded', len(spell_by_id), 'spell records')
    cast_times = load_simple_dbc(mpq, 'SpellCastTimes.dbc')
    durations = load_simple_dbc(mpq, 'SpellDuration.dbc')

    def resolve_cast_ms(idx):
        return cast_times.get(idx, None)

    def resolve_duration_ms(idx):
        return durations.get(idx, None)

    def fmt_ms(ms):
        if ms is None:
            return None
        if ms == 0:
            return 'Instant'
        if ms >= 60000 and ms % 60000 == 0:
            return f'{ms // 60000} min'
        if ms >= 1000:
            return f'{ms / 1000:g} sec'
        return f'{ms} ms'

    cards = []
    missing = []
    for t in class_data['talents']:
        sid = t.get('spellId')
        rec = spell_by_id.get(sid) if sid else None
        if not rec:
            missing.append(t['name'])
            continue
        own = spell_summary(rec)
        base = {
            'cooldown': fmt_ms(own['cooldownMs']),
            'castTime': fmt_ms(resolve_cast_ms(own['castingTimeIndex'])),
            'manaCost': own['manaCost'] or None,
            'school': school_mask_to_names(own['schoolMask']),
            'procChance': own['procChance'] or None,
        }
        triggers = []
        for tsid in own['effectTriggerSpell']:
            if tsid and tsid in spell_by_id and tsid != sid:
                trec = spell_by_id[tsid]
                tsum = spell_summary(trec)
                triggers.append({
                    'id': tsid,
                    'name': tsum['name'],
                    'duration': fmt_ms(resolve_duration_ms(tsum['durationIndex'])),
                    'effectBasePoints': [v for v in tsum['effectBasePoints'] if v not in (0, -1)],
                    'desc': tsum['desc'],
                })
        teaches = []
        for m in TEACH_TAG.finditer(own['desc'] or ''):
            tid = int(m.group(1))
            if tid in spell_by_id and tid != sid:
                teaches.append({'id': tid, 'name': spell_by_id[tid]['Name_0']})

        cards.append({
            'name': t['name'], 'tree': t['tree'], 'x': t['x'], 'y': t['y'],
            'maxPoints': t['maxPoints'], 'requiredLevel': t.get('requiredLevel', 0),
            'spellId': sid, 'dbcName': own['name'],
            'base': base, 'triggers': triggers, 'teaches': teaches,
            'rawDesc': own['desc'],
        })

    print('Matched', len(cards), 'of', len(class_data['talents']), 'talents to DBC records.')
    if missing:
        print('Unmatched (no spellId or spellId not found in DBC):', missing[:10], '...' if len(missing) > 10 else '')

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
<title>__CLASS_NAME__ - Ability Cards (DBC-sourced, experimental)</title>
<style>
  :root { --bg:#17161a; --panel:#201e1a; --line:#3a3630; --text:#ece8e0; --muted:#969084; --accent:#45db9c; --head-hover:#2a2721; }
  * { box-sizing: border-box; }
  body { background: var(--bg); color: var(--text); font-family: -apple-system, "Segoe UI", Arial, sans-serif; margin:0; padding:24px 20px 60px; max-width:960px; margin-inline:auto; }
  h1 { font-size:22px; margin:0 0 4px; color:var(--accent); font-weight:700; }
  .banner { background:#2a2313; border:1px solid #6b5a1f; color:#e8cf7a; font-size:12.5px; padding:8px 12px; border-radius:6px; margin-bottom:16px; line-height:1.5; }
  .card { background:var(--panel); border:1px solid var(--line); border-radius:8px; margin-bottom:10px; padding:14px 16px; }
  .card h2 { font-size:16px; margin:0 0 6px; }
  .meta { color:var(--muted); font-size:12px; margin-bottom:8px; }
  .stat-row { display:flex; gap:14px; flex-wrap:wrap; margin:8px 0; font-size:12.5px; }
  .stat { background:#1c1a17; border:1px solid var(--line); border-radius:6px; padding:4px 9px; }
  .stat b { color:var(--accent); }
  .desc { color:var(--muted); font-size:12.5px; line-height:1.45; margin:8px 0; }
  .trigger-box { border-left:2px solid var(--accent); padding-left:10px; margin-top:8px; }
  .trigger-box h3 { font-size:13px; margin:4px 0; }
  .teaches { font-size:12px; color:var(--muted); margin-top:6px; }
  .section-label { text-transform:uppercase; letter-spacing:0.05em; font-size:10.5px; color:var(--muted); margin-top:8px; }
</style>
</head>
<body>
<h1>__CLASS_NAME__ &mdash; ability cards (DBC-sourced, experimental)</h1>
<div class="banner">Base state (cooldown, cast time, mana cost, school, duration, trigger chain, teach links) is read directly from the client's Spell.dbc + SpellCastTimes.dbc + SpellDuration.dbc - not parsed from tooltip text. Static readout only, no talent tick-selector yet.</div>
<div id="cards"></div>
<script>
const DATA = __DATA_JSON__;
const el = document.getElementById('cards');
DATA.cards.forEach(c => {
  const card = document.createElement('div');
  card.className = 'card';
  let statRow = '<div class="stat-row">';
  if (c.base.cooldown) statRow += `<span class="stat"><b>CD</b> ${c.base.cooldown}</span>`;
  if (c.base.castTime) statRow += `<span class="stat"><b>Cast</b> ${c.base.castTime}</span>`;
  if (c.base.manaCost) statRow += `<span class="stat"><b>Cost</b> ${c.base.manaCost}</span>`;
  if (c.base.procChance) statRow += `<span class="stat"><b>Proc</b> ${c.base.procChance}%</span>`;
  statRow += `<span class="stat"><b>School</b> ${c.base.school.join('/')}</span>`;
  statRow += '</div>';

  let triggersHtml = '';
  c.triggers.forEach(tr => {
    triggersHtml += `<div class="trigger-box"><h3>${tr.name}</h3>`;
    if (tr.duration) triggersHtml += `<div class="stat-row"><span class="stat"><b>Duration</b> ${tr.duration}</span>`;
    if (tr.effectBasePoints.length) triggersHtml += `<span class="stat"><b>Base points</b> ${tr.effectBasePoints.join(', ')}</span>`;
    triggersHtml += `</div><div class="desc">${(tr.desc||'').replace(/\n/g,'<br>')}</div></div>`;
  });

  let teachesHtml = '';
  if (c.teaches.length) {
    teachesHtml = `<div class="teaches">Teaches: ${c.teaches.map(t => t.name).join(', ')}</div>`;
  }

  card.innerHTML = `
    <h2>${c.name}</h2>
    <div class="meta">${c.tree} &middot; ${c.maxPoints} pt${c.maxPoints===1?'':'s'} &middot; spellId ${c.spellId}${c.requiredLevel ? ' &middot; req level ' + c.requiredLevel : ''}</div>
    ${statRow}
    <div class="desc">${(c.rawDesc||'').replace(/\n/g,'<br>')}</div>
    ${triggersHtml ? '<div class="section-label">Triggers</div>' + triggersHtml : ''}
    ${teachesHtml}
  `;
  el.appendChild(card);
});
</script>
</body>
</html>
"""

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Usage: python3 build_ability_cards_dbc.py <class_talents.json> <mpq_data_dir> <out.html>")
        sys.exit(1)
    build(sys.argv[1], sys.argv[2], sys.argv[3])
