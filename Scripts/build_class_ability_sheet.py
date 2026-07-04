"""
build_class_ability_sheet.py - EXPERIMENTAL. A separate, simpler deliverable
from the DBC-sourced pipeline in Scripts/*_dbc.py: ONE combined "class
sheet" HTML covering all classes, grounded in the same real Spell.dbc data,
but with ALL of the talent-relationship modeling (own/triggers/teaches/
modifies/compounds, the first-class/second-order split, family grouping)
deliberately stripped out.

Each talent slot gets exactly one card: its own resolved stats and
normalized description. Nothing about what modifies it, what it modifies,
or whether it's "first-class." Class is the primary filter (dropdown),
spec is the secondary filter (tabs) within the selected class. This is
meant to be handed out as-is - a flat reference sheet, not the analysis
tool.

The only data-correctness carry-over from the main pipeline: the
wrapper/same-name-trigger merge (a talent's own spell frequently just
triggers a second, differently-ID'd spell with the exact same name that
carries the real duration/effect numbers - e.g. Bone King 707175 -> 707176,
both named "Bone King"). Without this merge the sheet would show blank
duration/effects for a large fraction of cards, which isn't a talent-
relationship question, it's just getting the OWN stats right.

Usage:
    python3 build_class_ability_sheet.py <input_dir> <mpq_data_dir> <out.html>

Processes every <input_dir>/*_talents.json in one run (one Spell.dbc load
shared across all classes) into a single output HTML file.
"""
import json, re, struct, sys, html, os, glob
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

CLASS_COLORS = {
    'Barbarian': '#ae7251', 'Witch Doctor': '#f500ff', 'Felsworn': '#75fa00', 'Witch Hunter': '#866edd',
    'Stormbringer': '#007ded', 'Knight of Xoroth': '#fc0005', 'Guardian': '#9c9482', 'Templar': '#fffab3',
    'Bloodmage': '#c66161', 'Ranger': '#bff06b', 'Chronomancer': '#ffed4a', 'Necromancer': '#45db9c',
    'Pyromancer': '#ff6112', 'Cultist': '#9c45f2', 'Starcaller': '#8fffff', 'Sun Cleric': '#ffb340',
    'Tinker': '#d9d9d9', 'Venomancer': '#6ba600', 'Reaper': '#0a876b', 'Primalist': '#e38c59', 'Runemaster': '#40c7eb',
}
DEFAULT_ACCENT = '#c9a227'
SPELL_ATTR0_PASSIVE = 0x40  # bit 6 - WotLK's own "never directly cast" flag

def load_simple_dbc(mpq, name):
    data = mpq.read_file('DBFilesClient\\' + name)
    magic, rc, fc, rs, sbs = struct.unpack('<4sIIII', data[:20])
    out = {}
    for i in range(rc):
        base = 20 + i * rs
        vals = struct.unpack('<4i', data[base:base+16])
        out[vals[0]] = vals[1]
    return out

def load_float_dbc(mpq, name):
    data = mpq.read_file('DBFilesClient\\' + name)
    magic, rc, fc, rs, sbs = struct.unpack('<4sIIII', data[:20])
    out = {}
    for i in range(rc):
        base = 20 + i * rs
        rec_id, val = struct.unpack('<if', data[base:base + 8])
        out[rec_id] = val
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

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from tooltip_normalize import make_normalizer


def first_nonzero_radius(rec, radii):
    for i in range(3):
        idx = rec.get(f'EffectRadiusIndex_{i}')
        if idx:
            val = radii.get(idx)
            if val:
                return val
    return None


def build_class_payload(talents_path, spell_by_id, durations, cast_times, radii, normalize):
    with open(talents_path, encoding='utf-8') as f:
        class_data = json.load(f)
    talents = class_data['talents']
    class_name = class_data['class']
    accent = CLASS_COLORS.get(class_name, DEFAULT_ACCENT)

    cards_by_tree = {}
    tree_order = []
    missing = 0
    for t in talents:
        sid = t.get('spellId')
        rec = spell_by_id.get(sid) if sid else None
        if not rec:
            missing += 1
            continue
        own_name = rec['Name_0']
        cooldown_ms = rec['CategoryRecoveryTime'] or rec['RecoveryTime']
        base_points = [v for v in (rec['EffectBasePoints_0'], rec['EffectBasePoints_1'], rec['EffectBasePoints_2']) if v not in (0, -1)]
        duration = fmt_ms(durations.get(rec['DurationIndex']))
        desc = normalize(rec['Description_0'], rec)
        radius = first_nonzero_radius(rec, radii)

        # Same-name wrapper/implementation merge only - fills gaps in the
        # OWN card's stats, does not surface a relationship list.
        frontier = [sid]; seen = {sid}; depth = 0
        while frontier and depth < 2:
            nf = []
            for cur in frontier:
                crec = spell_by_id.get(cur)
                if not crec:
                    continue
                for tsid in (crec['EffectTriggerSpell_0'], crec['EffectTriggerSpell_1'], crec['EffectTriggerSpell_2']):
                    if tsid and tsid in spell_by_id and tsid not in seen:
                        seen.add(tsid)
                        trec = spell_by_id[tsid]
                        if trec['Name_0'] == own_name:
                            if not duration:
                                duration = fmt_ms(durations.get(trec['DurationIndex']))
                            if not base_points:
                                base_points = [v for v in (trec['EffectBasePoints_0'], trec['EffectBasePoints_1'], trec['EffectBasePoints_2']) if v not in (0, -1)]
                            if radius is None:
                                radius = first_nonzero_radius(trec, radii)
                            note_desc = normalize(trec['Description_0'], trec)
                            if note_desc and (not desc or len(note_desc) > len(desc)):
                                desc = note_desc
                        nf.append(tsid)
            frontier = nf; depth += 1

        card = {
            'name': rec['Name_0'], 'desc': desc, 'maxPoints': t['maxPoints'],
            'cooldown': fmt_ms(cooldown_ms), 'castTime': fmt_ms(cast_times.get(rec['CastingTimeIndex'])),
            'manaCost': rec['ManaCost'] or None, 'school': school_mask_to_names(rec['SchoolMask']),
            'procChance': rec['ProcChance'] or None, 'duration': duration,
            'effectBasePoints': base_points, 'radius': radius,
            # First-class = you actually press this (it's the "toolkit").
            # Second-order = a talent that only modifies/procs/passively
            # buffs something else, with no independent press of its own.
            # Determined structurally from WotLK's own PASSIVE attribute bit
            # - not a guess, not text-parsed - confirmed against known cases
            # (Grave Mastery/Graverobber/Army of the Dead all read passive;
            # Raise: Abomination reads active) in Docs/PIPELINE.md.
            'isFirstClass': not (rec['Attributes'] & SPELL_ATTR0_PASSIVE),
        }
        tree = t['tree']
        if tree not in cards_by_tree:
            cards_by_tree[tree] = []
            tree_order.append(tree)
        cards_by_tree[tree].append(card)

    trees_payload = []
    for tr in tree_order:
        cards = cards_by_tree[tr]
        trees_payload.append({
            'tree': tr,
            'toolkit': [c for c in cards if c['isFirstClass']],
            'talents': [c for c in cards if not c['isFirstClass']],
        })
    payload = {'class': class_name, 'accent': accent, 'trees': trees_payload}
    return payload, len(talents), missing


TEMPLATE = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Ability Sheets - all classes</title>
<style>
  :root { --bg:#17161a; --panel:#201e1a; --line:#3a3630; --text:#ece8e0; --muted:#969084; --accent:#c9a227; --head-hover:#2a2721; }
  * { box-sizing: border-box; }
  body { background: var(--bg); color: var(--text); font-family: -apple-system, "Segoe UI", Arial, sans-serif; margin:0; padding:24px 20px 60px; max-width:960px; margin-inline:auto; }
  h1 { font-size:22px; margin:0 0 4px; color:var(--accent); font-weight:700; }
  .sub { color:var(--muted); font-size:13px; margin-bottom:14px; }
  .toolbar { display:flex; gap:10px; flex-wrap:wrap; position:sticky; top:0; background:var(--bg); padding:10px 0; z-index:10; border-bottom:1px solid var(--line); margin-bottom:14px; }
  select, input { padding:9px 12px; border:1px solid var(--line); border-radius:6px; font-size:14px; background:var(--panel); color:var(--text); }
  #classSelect { flex: 0 0 240px; font-weight:600; }
  #search { flex: 1 1 220px; }
  .tabs { display:flex; gap:6px; margin-bottom:14px; flex-wrap:wrap; }
  .tab { padding:7px 14px; border:1px solid var(--line); border-radius:6px; background:var(--panel); cursor:pointer; font-size:13.5px; color:var(--muted); }
  .tab.active { border-color:var(--accent); color:var(--accent); font-weight:600; }
  .tree-section { display:none; }
  .tree-section.active { display:block; }
  .card { background:var(--panel); border:1px solid var(--line); border-radius:8px; margin-bottom:10px; padding:14px 16px; }
  .card h2 { font-size:16px; margin:0 0 6px; display:inline-block; }
  .idtag { color:var(--muted); font-size:11px; margin-left:8px; }
  .stat-row { display:flex; gap:14px; flex-wrap:wrap; margin:8px 0; font-size:12.5px; }
  .stat { background:#1c1a17; border:1px solid var(--line); border-radius:6px; padding:4px 9px; }
  .stat b { color:var(--accent); }
  .desc { color:var(--muted); font-size:12.5px; line-height:1.45; margin:8px 0 0; }
  .lane-label { text-transform:uppercase; letter-spacing:.06em; font-size:11.5px; color:var(--accent); font-weight:700; margin:18px 0 8px; }
  .lane-label:first-child { margin-top:0; }
  .lane-sub { color:var(--muted); font-size:11.5px; font-weight:400; text-transform:none; letter-spacing:normal; margin-left:8px; }
  .card.talent-card { opacity:0.82; border-style:dashed; }
</style>
</head>
<body>
<h1 id="pageTitle">Ability sheet</h1>
<div class="sub">Every talent's own ability, real stats straight from Spell.dbc. No talent-relationship data (what modifies it, what it modifies, family grouping) - just what each one does on its own. Class first, spec second.</div>
<div class="toolbar">
  <select id="classSelect"></select>
  <input id="search" type="text" placeholder="Search an ability name...">
</div>
<div class="tabs" id="tabs"></div>
<div id="sections"></div>
<script>
const DATA = __DATA_JSON__;  // { classes: [ {class, accent, trees:[{tree, cards}]} ] }
const classSelect = document.getElementById('classSelect');
const tabsEl = document.getElementById('tabs');
const sectionsEl = document.getElementById('sections');
const pageTitle = document.getElementById('pageTitle');

DATA.classes.forEach((c, i) => {
  const opt = document.createElement('option');
  opt.value = i;
  opt.textContent = c.class;
  classSelect.appendChild(opt);
});

function renderClass(classIndex) {
  const cls = DATA.classes[classIndex];
  document.documentElement.style.setProperty('--accent', cls.accent);
  pageTitle.textContent = cls.class + ' — ability sheet';
  tabsEl.innerHTML = '';
  sectionsEl.innerHTML = '';

  cls.trees.forEach((tr, i) => {
    const tab = document.createElement('div');
    tab.className = 'tab' + (i === 0 ? ' active' : '');
    tab.textContent = tr.tree + ' (' + tr.toolkit.length + ')';
    tab.onclick = () => setActiveTree(i);
    tabsEl.appendChild(tab);

    const section = document.createElement('div');
    section.className = 'tree-section' + (i === 0 ? ' active' : '');
    section.dataset.treeIndex = i;

    function renderCard(c, isTalentLane) {
      const card = document.createElement('div');
      card.className = 'card' + (isTalentLane ? ' talent-card' : '');
      card.dataset.searchText = c.name.toLowerCase();
      let statRow = '<div class="stat-row">';
      if (c.cooldown) statRow += `<span class="stat"><b>CD</b> ${c.cooldown}</span>`;
      if (c.castTime) statRow += `<span class="stat"><b>Cast</b> ${c.castTime}</span>`;
      if (c.manaCost) statRow += `<span class="stat"><b>Cost</b> ${c.manaCost}</span>`;
      if (c.procChance) statRow += `<span class="stat"><b>Proc</b> ${c.procChance}%</span>`;
      if (c.duration) statRow += `<span class="stat"><b>Duration</b> ${c.duration}</span>`;
      if (c.effectBasePoints.length) statRow += `<span class="stat"><b>Base points</b> ${c.effectBasePoints.join(', ')}</span>`;
      if (c.radius) statRow += `<span class="stat"><b>Radius</b> ${c.radius} yd</span>`;
      statRow += `<span class="stat"><b>School</b> ${c.school.join('/')}</span></div>`;
      card.innerHTML = `<h2>${c.name}</h2><span class="idtag">${c.maxPoints} pt${c.maxPoints===1?'':'s'}</span>${statRow}<div class="desc">${(c.desc||'').replace(/\n/g,'<br>')}</div>`;
      return card;
    }

    const toolkitLabel = document.createElement('div');
    toolkitLabel.className = 'lane-label';
    toolkitLabel.innerHTML = `Toolkit <span class="lane-sub">- abilities you actually press (${tr.toolkit.length})</span>`;
    section.appendChild(toolkitLabel);
    tr.toolkit.forEach(c => section.appendChild(renderCard(c, false)));

    if (tr.talents.length) {
      const talentsLabel = document.createElement('div');
      talentsLabel.className = 'lane-label';
      talentsLabel.innerHTML = `Talents <span class="lane-sub">- passives/procs that modify the toolkit above, no independent press (${tr.talents.length})</span>`;
      section.appendChild(talentsLabel);
      tr.talents.forEach(c => section.appendChild(renderCard(c, true)));
    }
    sectionsEl.appendChild(section);
  });
  applySearch();
}

function setActiveTree(i) {
  document.querySelectorAll('.tab').forEach((el, idx) => el.classList.toggle('active', idx === i));
  document.querySelectorAll('.tree-section').forEach(el => el.classList.toggle('active', +el.dataset.treeIndex === i));
}

function applySearch() {
  const q = document.getElementById('search').value.trim().toLowerCase();
  document.querySelectorAll('.card').forEach(card => {
    card.style.display = (!q || card.dataset.searchText.includes(q)) ? '' : 'none';
  });
}

classSelect.addEventListener('change', () => renderClass(+classSelect.value));
document.getElementById('search').addEventListener('input', applySearch);

renderClass(0);
</script>
</body>
</html>
"""

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Usage: python3 build_class_ability_sheet.py <input_dir> <mpq_data_dir> <out.html>")
        sys.exit(1)
    input_dir, data_dir, out_path = sys.argv[1], sys.argv[2], sys.argv[3]

    mpq = open_mpq_set(data_dir)
    print('Loading Spell.dbc (this takes ~30-40s, once for all classes)...')
    spell_by_id = load_spell_dbc(mpq)
    durations = load_simple_dbc(mpq, 'SpellDuration.dbc')
    cast_times = load_simple_dbc(mpq, 'SpellCastTimes.dbc')
    radii = load_float_dbc(mpq, 'SpellRadius.dbc')
    normalize = make_normalizer(spell_by_id, durations, radii, fmt_ms)
    print('Loaded', len(spell_by_id), 'spell records')

    classes_payload = []
    for talents_path in sorted(glob.glob(os.path.join(input_dir, '*_talents.json'))):
        payload, total, missing = build_class_payload(talents_path, spell_by_id, durations, cast_times, radii, normalize)
        classes_payload.append(payload)
        print(f'{payload["class"]}: {total} talents, {missing} missing spellId match')

    classes_payload.sort(key=lambda p: p['class'])
    doc = TEMPLATE.replace('__DATA_JSON__', json.dumps({'classes': classes_payload}))
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(doc)
    print(f'\nWrote {out_path} ({len(doc)} chars, {len(classes_payload)} classes)')
