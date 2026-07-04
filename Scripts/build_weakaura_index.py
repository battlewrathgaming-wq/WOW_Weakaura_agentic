"""
build_weakaura_index.py - EXPERIMENTAL. Builds a per-ability WeakAuras
opportunity index from the same real Spell.dbc data as the rest of the
pipeline. Not a talent-relationship tool - purpose-built for one question:
"which of this class's abilities are worth building a WeakAura for, and
what trigger config does it need?"

Three opportunity categories, each a filter over fields we already extract
(no new game knowledge, no prose parsing):

- cooldown_tracker: a first-class (toolkit) ability with a real cooldown -
  candidate for a "Cooldown Progress (Spell)" trigger by spellId.
- proc_alert: a second-order (talent/passive) ability with ProcChance < 100
  - it fires automatically and is easy to miss - candidate for a
  "Combat Log > Spell Cast Success / Aura Applied" trigger filtered by
  spellId.
- buff_uptime: has a real duration (timed or "Until cancelled") - candidate
  for an "Aura" trigger by spellId, either a countdown bar (timed) or an
  on/off icon (permanent toggle).
- stack_counter: CumulativeAura > 1 - candidate for a stack-count text/
  overlay on top of whichever trigger above already applies.

isFirstClass uses the same SPELL_ATTR0_PASSIVE bit test as the ability
sheet (Docs/PIPELINE.md) - it's what decides cooldown_tracker vs proc_alert
eligibility, since you don't put a cooldown-ready icon on something you
never press yourself.

Usage:
    python3 build_weakaura_index.py <class_talents.json> <mpq_data_dir> <out.json>
"""
import json, re, struct, sys, os
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

SPELL_ATTR0_PASSIVE = 0x40

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
    with open(talents_path, encoding='utf-8') as f:
        class_data = json.load(f)
    talents = class_data['talents']
    class_name = class_data['class']

    mpq = open_mpq_set(data_dir)
    print('Loading Spell.dbc (this takes ~30-40s)...')
    spell_by_id = load_spell_dbc(mpq)
    durations = load_simple_dbc(mpq, 'SpellDuration.dbc')
    print('Loaded', len(spell_by_id), 'spell records')

    abilities = []
    for t in talents:
        sid = t.get('spellId')
        rec = spell_by_id.get(sid) if sid else None
        if not rec:
            continue

        cooldown_ms = rec['CategoryRecoveryTime'] or rec['RecoveryTime']
        duration_ms = durations.get(rec['DurationIndex'])
        proc_chance = rec['ProcChance'] or None
        max_stacks = rec['CumulativeAura'] or None
        is_first_class = not (rec['Attributes'] & SPELL_ATTR0_PASSIVE)

        opportunities = []
        if is_first_class and cooldown_ms and cooldown_ms > 0:
            opportunities.append({
                'type': 'cooldown_tracker',
                'trigger': 'Cooldown Progress (Spell) - use Spell ID directly',
            })
        if (not is_first_class) and proc_chance is not None and proc_chance < 100:
            opportunities.append({
                'type': 'proc_alert',
                'trigger': f'Combat Log: Spell Cast Success or Aura Applied, Spell ID = this ability ({proc_chance}% chance - fires automatically, easy to miss without an alert)',
            })
        if duration_ms is not None and duration_ms != 0:
            style = 'permanent on/off icon' if duration_ms < 0 else 'countdown bar'
            opportunities.append({
                'type': 'buff_uptime',
                'trigger': f'Aura trigger by Spell ID - {style}',
            })
        if max_stacks and max_stacks > 1:
            opportunities.append({
                'type': 'stack_counter',
                'trigger': f'Stack sub-display on the Aura trigger above (max {max_stacks} stacks)',
            })

        abilities.append({
            'name': rec['Name_0'],
            'spellId': sid,
            'tree': t['tree'],
            'maxPoints': t['maxPoints'],
            'isFirstClass': is_first_class,
            'cooldownMs': cooldown_ms or None,
            'cooldown': fmt_ms(cooldown_ms) if cooldown_ms else None,
            'durationMs': duration_ms,
            'duration': fmt_ms(duration_ms),
            'procChance': proc_chance,
            'maxStacks': max_stacks,
            'school': school_mask_to_names(rec['SchoolMask']),
            'opportunities': opportunities,
        })

    by_type = {}
    for a in abilities:
        for o in a['opportunities']:
            by_type[o['type']] = by_type.get(o['type'], 0) + 1

    payload = {'class': class_name, 'abilities': abilities, 'opportunityCounts': by_type}
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(payload, f, indent=2)
    print('Opportunity counts:', by_type)
    print(f'Wrote {out_path} ({len(abilities)} abilities)')


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Usage: python3 build_weakaura_index.py <class_talents.json> <mpq_data_dir> <out.json>")
        sys.exit(1)
    build(sys.argv[1], sys.argv[2], sys.argv[3])
