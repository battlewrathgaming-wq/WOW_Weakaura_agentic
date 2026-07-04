"""
generate_readout_html_nested.py - EXPERIMENTAL. Renders the *_skill_index_nested.json
output (see build_skill_index_nested.py) instead of the regular skill index.

The one real difference vs generate_readout_html.py: any skill of kind
'produced' (a pet/buff/proc/stack with a named parent ability) does NOT get
its own top-level card. Instead it's rendered nested *inside* the body of
every parent card that spawns it (full duplication if it has more than one
parent, per the agreed design - "appear nested in each parent... the tool
should help flatten reasoning, not fan out and then have to attribute to the
parent"). A nested child's own talent list mixes both kinds of talent that
apply to it: the ones that spawn/trigger it more (tagged "Spawns") and any
that upgrade it once it already exists (tagged normally).

Separate file from generate_readout_html.py on purpose - same reasoning as
build_skill_index_nested.py: keep the existing pipeline as an untouched
fallback while this heuristic gets eyeballed against real output.

Usage:
    python3 generate_readout_html_nested.py <class_talents.json> <skill_index_nested.json> <out.html>
"""
import json, sys, html
from collections import defaultdict

CLASS_COLORS = {
    'Barbarian': '#ae7251',
    'Witch Doctor': '#f500ff',
    'Felsworn': '#75fa00',
    'Witch Hunter': '#866edd',
    'Stormbringer': '#007ded',
    'Knight of Xoroth': '#fc0005',
    'Guardian': '#9c9482',
    'Templar': '#fffab3',
    'Bloodmage': '#c66161',
    'Ranger': '#bff06b',
    'Chronomancer': '#ffed4a',
    'Necromancer': '#45db9c',
    'Pyromancer': '#ff6112',
    'Cultist': '#9c45f2',
    'Starcaller': '#8fffff',
    'Sun Cleric': '#ffb340',
    'Tinker': '#d9d9d9',
    'Venomancer': '#6ba600',
    'Reaper': '#0a876b',
    'Primalist': '#e38c59',
    'Runemaster': '#40c7eb',
}
DEFAULT_ACCENT = '#c9a227'

def stat_parts(mod):
    parts = []
    for m in mod.get('statModification', []):
        sign = '+' if m['value'] > 0 else ''
        parts.append(f"{sign}{m['value']:g}{m['unit']}")
    return parts

def talent_payload(m, edge_role='modifies'):
    cost = m['cost']
    per_rank_cost = cost['abilityEssence'] or cost['talentEssence']
    points = m.get('maxPoints', 1) if per_rank_cost else 0
    free_tag = None
    if points == 0:
        req_level = m.get('requiredLevel', 0)
        special_req = m.get('specialRequirement') or []
        if special_req and not req_level:
            free_tag = 'Starting Talent'
        elif req_level:
            free_tag = 'Spec passive'
        else:
            free_tag = 'Free'
    return {
        'name': m['talent'],
        'kind': 'Class talent' if m['tree'] == 'Class' else 'Spec talent',
        'points': points,
        'freeTag': free_tag,
        'lanes': m.get('lanes', []),
        'flags': m.get('flags', []),
        'stat': stat_parts(m),
        'description': m['description'],
        'sharedFromFamily': m.get('sharedFromFamily'),
        'foldedFromChild': m.get('foldedFromChild'),
        'edgeRole': edge_role,
    }

def build(talents_path, skill_index_path, out_path):
    with open(talents_path) as f:
        class_data = json.load(f)
    with open(skill_index_path) as f:
        skill_idx = json.load(f)

    class_name = class_data['class']
    accent = CLASS_COLORS.get(class_name, DEFAULT_ACCENT)
    spec_trees = [t for t in class_data['trees'] if t != 'Class']
    lane_taxonomy = skill_idx.get('laneTaxonomy', {})

    def is_family(s):
        return skill_idx['skills'].get(s, {}).get('kind') == 'family'
    def is_produced(s):
        return skill_idx['skills'].get(s, {}).get('kind') == 'produced'

    specs_payload = []
    for spec in spec_trees:
        available_trees = {'Class', spec}

        # Top-level skills: everything that ISN'T a produced/nested skill.
        skill_to_mods = defaultdict(list)
        for skill, info in skill_idx['skills'].items():
            if info.get('kind') == 'produced':
                continue
            for m in info['modifyingTalents']:
                if m['tree'] in available_trees:
                    skill_to_mods[skill].append(m)

        # ---------------------------------------------------------------
        # Drop family children that add nothing beyond their family header.
        # A child earns its own top-level card only if it shows the reader
        # something they wouldn't already see on the family card. A family
        # with exactly one child (e.g. "Command" / "Command: Hook") always
        # gets folded - the "family" concept only pulls its weight when
        # there's more than one distinct named thing to tell apart, so a
        # lone child is just the same information under a second name. Any
        # genuinely unique talent that lone child had gets folded into the
        # family's own list first, tagged with where it came from, so it
        # isn't lost. A family with 2+ children (e.g. "Animate") keeps any
        # child that has at least one talent not already on the family card
        # (a real distinguishing feature) and drops only the ones that are a
        # pure subset (e.g. "Undead: Assault/Protect/Pacify", which all show
        # the exact same single talent as "Undead Stance" itself).
        # ---------------------------------------------------------------
        dropped_children = set()
        for skill, info in skill_idx['skills'].items():
            if info.get('kind') != 'family':
                continue
            children = info.get('familyChildren', [])
            if not children:
                continue
            family_names = set(m['talent'] for m in skill_to_mods.get(skill, []))
            if len(children) == 1:
                child = children[0]
                for m in skill_to_mods.get(child, []):
                    if m['talent'] not in family_names:
                        folded = dict(m)
                        folded['foldedFromChild'] = child
                        skill_to_mods[skill].append(folded)
                        family_names.add(m['talent'])
                dropped_children.add(child)
            else:
                for child in children:
                    child_mods = skill_to_mods.get(child, [])
                    child_names = set(m['talent'] for m in child_mods)
                    if child_names.issubset(family_names):
                        dropped_children.add(child)
        for child in dropped_children:
            skill_to_mods.pop(child, None)

        # Nested children: every produced skill, attached under EVERY named
        # parent it has (full duplication, not a cross-reference).
        nested_by_parent = defaultdict(list)
        for skill, info in skill_idx['skills'].items():
            if info.get('kind') != 'produced':
                continue
            combined = []
            for m in info.get('producingTalents', []):
                if m['tree'] in available_trees:
                    combined.append(talent_payload(m, 'produces'))
            for m in info.get('modifyingTalents', []):
                if m['tree'] in available_trees:
                    combined.append(talent_payload(m, 'modifies'))
            if not combined:
                continue
            combined.sort(key=lambda t: (t['edgeRole'] != 'produces',))
            all_lanes_child = sorted(set(l for t in combined for l in t['lanes'])) or info.get('lanes', [])
            child_payload = {'skill': skill, 'lanes': all_lanes_child, 'talents': combined}
            for parent in info.get('producedByParents', []):
                nested_by_parent[parent].append(child_payload)

        # A parent may have zero direct modifiers of its own in this spec but
        # still needs a top-level card purely to house its nested children.
        all_top_level = set(skill_to_mods.keys()) | set(nested_by_parent.keys())

        def surviving_children(s):
            info = skill_idx['skills'].get(s, {})
            return [c for c in info.get('familyChildren', []) if c not in dropped_children]

        def is_family_with_children(s):
            # Only worth the "Family" badge/divider if at least one child
            # actually survived as its own card - otherwise (every child
            # turned out fully redundant, e.g. Undead Stance) it now reads
            # exactly like an ordinary single spell, so render it as one.
            return is_family(s) and len(surviving_children(s)) > 0

        skills_payload = []
        def sort_key(s):
            weight = len(skill_to_mods.get(s, [])) + len(nested_by_parent.get(s, []))
            return (is_family_with_children(s), -weight)
        ordered_skills = sorted(all_top_level, key=sort_key)

        for skill in ordered_skills:
            mods = skill_to_mods.get(skill, [])
            talent_list = [talent_payload(m, 'modifies') for m in sorted(mods, key=lambda x: (x['tree'] != 'Class', x['position']['y']))]
            nested_children = nested_by_parent.get(skill, [])
            all_lanes = sorted(set(l for t in talent_list for l in t['lanes']) | set(l for c in nested_children for l in c['lanes']))
            skills_payload.append({
                'skill': skill,
                'lanes': all_lanes,
                'talents': talent_list,
                'isFamily': is_family_with_children(skill),
                'familyChildren': surviving_children(skill),
                'nested': nested_children,
            })
        specs_payload.append({'spec': spec, 'skills': skills_payload})

    payload = {'class': class_name, 'laneTaxonomy': lane_taxonomy, 'specs': specs_payload, 'experimental': True}
    doc = TEMPLATE.replace('__CLASS_NAME__', html.escape(class_name)).replace(
        '__ACCENT__', accent
    ).replace(
        '__DATA_JSON__', json.dumps(payload)
    )
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(doc)
    print(f"Wrote {out_path} ({len(doc)} chars)")


TEMPLATE = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>__CLASS_NAME__ - Skill Investment Readout (nested preview)</title>
<style>
  :root {
    --bg: #17161a; --panel: #201e1a; --line: #3a3630; --text: #ece8e0; --muted: #969084;
    --class-tag: #c98a3d; --spec-tag: #4d8fc4; --accent: __ACCENT__; --head-hover: #2a2721;
  }
  * { box-sizing: border-box; }
  body { background: var(--bg); color: var(--text); font-family: -apple-system, "Segoe UI", Arial, sans-serif; margin: 0; padding: 24px 20px 60px; max-width: 960px; margin-inline: auto; }
  h1 { font-size: 22px; margin: 0 0 4px; color: var(--accent); font-weight: 700; }
  .sub { color: var(--muted); font-size: 13.5px; margin-bottom: 18px; line-height: 1.5; }
  .experimental-banner { background: #2a2313; border: 1px solid #6b5a1f; color: #e8cf7a; font-size: 12.5px; padding: 8px 12px; border-radius: 6px; margin-bottom: 16px; line-height: 1.5; }
  .toolbar { position: sticky; top: 0; background: var(--bg); padding: 10px 0; z-index: 10; border-bottom: 1px solid var(--line); margin-bottom: 14px; display: flex; flex-direction: column; gap: 8px; }
  .toolbar-row { display: flex; gap: 8px; }
  .toolbar input { flex: 1; padding: 9px 12px; border: 1px solid var(--line); border-radius: 6px; font-size: 14px; background: var(--panel); color: var(--text); }
  .btn { padding: 8px 12px; border: 1px solid var(--line); border-radius: 6px; background: var(--panel); cursor: pointer; font-size: 12.5px; color: var(--muted); white-space: nowrap; }
  .btn:hover { background: var(--head-hover); color: var(--text); }
  .tabs { display: flex; gap: 6px; margin-bottom: 10px; flex-wrap: wrap; }
  .tab { padding: 7px 14px; border: 1px solid var(--line); border-radius: 6px; background: var(--panel); cursor: pointer; font-size: 13.5px; color: var(--muted); }
  .tab.active { border-color: var(--accent); color: var(--accent); font-weight: 600; }
  .lane-filter { display: flex; gap: 5px; flex-wrap: wrap; margin-bottom: 18px; }
  .lane-filter .lchip { cursor: pointer; opacity: 0.5; }
  .lane-filter .lchip.on { opacity: 1; }
  .spec-section { display: none; }
  .spec-section.active { display: block; }
  .skill-card { background: var(--panel); border: 1px solid var(--line); border-radius: 8px; margin-bottom: 10px; overflow: hidden; }
  .skill-head { display: flex; align-items: center; gap: 10px; width: 100%; padding: 13px 16px; background: none; border: none; cursor: pointer; text-align: left; font: inherit; color: inherit; }
  .skill-head:hover { background: var(--head-hover); }
  .skill-head:focus-visible { outline: 2px solid var(--accent); outline-offset: -2px; }
  .chevron { flex: 0 0 auto; display: inline-block; font-size: 12px; color: var(--muted); transition: transform 0.25s ease, color 0.25s ease; }
  .skill-head.open .chevron { transform: rotate(90deg); color: var(--accent); }
  .skill-head h2 { font-size: 17px; font-weight: 700; margin: 0; flex: 0 1 auto; color: var(--text); }
  .preview-lanes { display: flex; gap: 3px; flex-wrap: wrap; align-items: center; }
  .preview-dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; opacity: 0.85; }
  .tcount { margin-left: auto; padding-left: 10px; color: var(--muted); font-size: 12px; flex: 0 0 auto; white-space: nowrap; }
  .skill-body-wrap { display: grid; grid-template-rows: 0fr; transition: grid-template-rows 0.28s ease; }
  .skill-body-wrap.open { grid-template-rows: 1fr; }
  .skill-body-inner { overflow: hidden; }
  .skill-body-pad { padding: 2px 16px 14px; }
  ul.talents { list-style: none; margin: 0; padding: 0; }
  ul.talents li { padding: 8px 0; border-top: 1px solid var(--line); font-size: 13.5px; line-height: 1.5; }
  ul.talents li:first-child { border-top: none; }
  ul.talents li.hidden-by-lane { display: none; }
  .tname { font-weight: 600; margin-right: 6px; color: var(--text); }
  .tag { display: inline-block; font-size: 10.5px; padding: 1px 6px; border-radius: 4px; margin-right: 4px; color: #1a1a1a; vertical-align: 1px; }
  .tag.class { background: var(--class-tag); }
  .tag.spec { background: var(--spec-tag); color: #0d1720; }
  .points { color: var(--muted); font-size: 12px; }
  .freetag { color: #10230f; background: #7ea569; font-size: 10.5px; font-weight: 600; padding: 1px 7px; border-radius: 4px; vertical-align: 1px; }
  .lchips { margin-top: 4px; display: flex; gap: 4px; flex-wrap: wrap; align-items: center; }
  .lchip { display: inline-flex; align-items: center; gap: 4px; font-size: 11px; font-weight: 600; padding: 2px 7px; border-radius: 10px; color: #fff; white-space: nowrap; }
  .lchip .val { font-weight: 700; }
  .flag { display: inline-block; font-size: 10px; padding: 1px 6px; border-radius: 10px; border: 1px solid var(--line); color: var(--muted); }
  .desc { color: var(--muted); font-size: 12.5px; margin-top: 6px; line-height: 1.45; max-width: 720px; }
  .no-match { color: var(--muted); font-style: italic; padding: 20px 0; }
  .family-tag { display: inline-block; font-size: 10.5px; padding: 1px 7px; border-radius: 4px; margin-right: 4px; color: var(--bg); background: var(--accent); font-weight: 600; vertical-align: 1px; }
  .applies-to { color: var(--muted); font-size: 12px; padding: 0 16px 10px; margin-top: -2px; }
  .shared-tag { display: inline-block; font-size: 10px; padding: 1px 6px; border-radius: 10px; border: 1px solid var(--line); color: var(--muted); margin-left: 4px; }
  .family-divider { color: var(--muted); font-size: 12px; text-transform: uppercase; letter-spacing: 0.06em; margin: 18px 0 8px; padding-top: 10px; border-top: 1px solid var(--line); }

  .produces-divider { color: var(--muted); font-size: 11px; text-transform: uppercase; letter-spacing: 0.06em; margin: 10px 0 6px; }
  .nested-list { margin-top: 4px; border-left: 2px solid var(--accent); padding-left: 10px; }
  .nested-card { background: #1c1a17; border: 1px solid var(--line); border-radius: 6px; margin-bottom: 8px; overflow: hidden; }
  .nested-head { display: flex; align-items: center; gap: 8px; width: 100%; padding: 9px 12px; background: none; border: none; cursor: pointer; text-align: left; font: inherit; color: inherit; }
  .nested-head:hover { background: var(--head-hover); }
  .nested-head h3 { font-size: 14px; font-weight: 700; margin: 0; color: var(--text); }
  .nested-head .chevron { font-size: 11px; }
  .spawn-tag { display: inline-block; font-size: 10px; padding: 1px 6px; border-radius: 4px; margin-right: 4px; color: #1a1a1a; background: var(--accent); font-weight: 600; vertical-align: 1px; }
</style>
</head>
<body>

<h1>__CLASS_NAME__ &mdash; skill investment readout (nested preview)</h1>
<div class="experimental-banner">Experimental variant: pets/buffs/procs that only ever get named by another talent (e.g. "summon a Lesser Zombie") are nested inside the ability that spawns them instead of getting their own top-level card. Compare against the regular readout for the same class.</div>
<div class="sub">Pick a skill you already like, press it to draw out the talents underneath it. Each dot/chip is a lever (DMG/CDR/HEAL/etc) - click a lane below to isolate and reveal talents that pull it. Class talents are always available; spec talents require committing to that spec.</div>

<div class="toolbar">
  <div class="toolbar-row">
    <input id="search" type="text" placeholder="Search a skill or talent name...">
    <button class="btn" id="expandAllBtn">Expand all</button>
    <button class="btn" id="collapseAllBtn">Collapse all</button>
  </div>
</div>

<div class="tabs" id="tabs"></div>
<div class="lane-filter" id="laneFilter"></div>
<div id="sections"></div>

<script>
const DATA = __DATA_JSON__;

const LANE_COLORS = {
  DMG: '#c0442f', CRIT: '#c8862a', CDR: '#3a6ea5', CAST: '#4d7fb8', HASTE: '#7457a8',
  SPEED: '#2f8f7a', HEAL: '#3e8f4a', SHIELD: '#3a9aa5', MITIGATION: '#5a7a95',
  RESOURCE: '#b89b2e', COST: '#96842a', DURATION: '#6b6660', AOE: '#a15a9a',
  CC: '#8a2f3a', ARMOR: '#7a6650', SUMMON: '#5a4a8a', STATS: '#726a35', MISC: '#807a72'
};

const tabsEl = document.getElementById('tabs');
const laneFilterEl = document.getElementById('laneFilter');
const sectionsEl = document.getElementById('sections');
const searchEl = document.getElementById('search');

const allLanesUsed = new Set();
DATA.specs.forEach(s => s.skills.forEach(sk => {
  sk.talents.forEach(t => t.lanes.forEach(l => allLanesUsed.add(l)));
  (sk.nested || []).forEach(n => n.talents.forEach(t => t.lanes.forEach(l => allLanesUsed.add(l))));
}));
const activeLaneFilters = new Set();

Array.from(allLanesUsed).sort().forEach(lane => {
  const chip = document.createElement('span');
  chip.className = 'lchip on';
  chip.style.background = LANE_COLORS[lane] || '#807a72';
  chip.textContent = lane;
  chip.title = DATA.laneTaxonomy[lane] || lane;
  chip.onclick = () => toggleLane(lane, chip);
  laneFilterEl.appendChild(chip);
});

function toggleLane(lane, chipEl) {
  if (activeLaneFilters.has(lane)) {
    activeLaneFilters.delete(lane);
    chipEl.classList.add('on');
  } else {
    activeLaneFilters.add(lane);
    chipEl.classList.remove('on');
  }
  applyLaneFilter();
  if (activeLaneFilters.size > 0) {
    openAll();
  } else {
    closeAll();
  }
}

function applyLaneFilter() {
  document.querySelectorAll('li[data-lanes]').forEach(li => {
    const lanes = JSON.parse(li.dataset.lanes);
    const suppressed = activeLaneFilters.size > 0 && !lanes.some(l => !activeLaneFilters.has(l));
    li.classList.toggle('hidden-by-lane', suppressed);
  });
}

function chipHtml(lane, valueText) {
  const color = LANE_COLORS[lane] || '#807a72';
  return `<span class="lchip" style="background:${color}" title="${DATA.laneTaxonomy[lane] || lane}">${lane}${valueText ? '<span class="val">' + valueText + '</span>' : ''}</span>`;
}

function previewDotsHtml(lanes) {
  return lanes.map(l => `<span class="preview-dot" style="background:${LANE_COLORS[l] || '#807a72'}" title="${DATA.laneTaxonomy[l] || l}"></span>`).join('');
}

function setCardOpen(head, wrap, open) {
  head.classList.toggle('open', open);
  head.setAttribute('aria-expanded', open ? 'true' : 'false');
  wrap.classList.toggle('open', open);
}

function talentLiHtml(t) {
  const tagClass = t.kind === 'Class talent' ? 'class' : 'spec';
  const tagLabel = t.kind === 'Class talent' ? 'Class' : 'Spec';
  const stat = t.stat.length ? t.stat.join(', ') : '';
  let lanesHtml = '';
  if (t.lanes.length) {
    lanesHtml = t.lanes.map(l => chipHtml(l, t.lanes.length === 1 ? stat : '')).join(' ');
    if (t.lanes.length > 1 && stat) lanesHtml += ` <span style="font-size:12px;color:var(--muted)">${stat}</span>`;
  } else if (stat) {
    lanesHtml = `<span style="font-size:12px;color:var(--muted)">${stat}</span>`;
  }
  const flagsHtml = t.flags.map(f => `<span class="flag">${f}</span>`).join(' ');
  const descHtml = (t.description || '').replace(/\n/g, '<br>');
  const pointsHtml = t.freeTag
    ? `<span class="freetag">${t.freeTag}</span>`
    : `<span class="points">${t.points} pt${t.points===1?'':'s'}</span>`;
  const sharedHtml = t.sharedFromFamily
    ? `<span class="shared-tag" title="Applies to every spell in the ${t.sharedFromFamily} family">shared: ${t.sharedFromFamily}</span>`
    : '';
  const foldedHtml = t.foldedFromChild
    ? `<span class="shared-tag" title="${t.foldedFromChild} showed nothing else this family card didn't already have, so it was folded in here instead of getting its own card">from: ${t.foldedFromChild}</span>`
    : '';
  const spawnHtml = t.edgeRole === 'produces'
    ? `<span class="spawn-tag" title="This talent is what spawns/triggers this">Spawns</span>`
    : '';
  return `<li data-lanes='${JSON.stringify(t.lanes)}'>` +
         spawnHtml +
         `<span class="tname">${t.name}</span>` +
         `<span class="tag ${tagClass}">${tagLabel}</span>` +
         pointsHtml + sharedHtml + foldedHtml +
         `<div class="lchips">${lanesHtml} ${flagsHtml}</div>` +
         `<div class="desc">${descHtml}</div>` +
         `</li>`;
}

function buildNestedCard(child) {
  const card = document.createElement('div');
  card.className = 'nested-card';
  let body = '<ul class="talents">';
  child.talents.forEach(t => { body += talentLiHtml(t); });
  body += '</ul>';
  const n = child.talents.length;
  card.innerHTML =
    `<button class="nested-head" aria-expanded="false">` +
      `<span class="chevron">&#9656;</span>` +
      `<h3>${child.skill}</h3>` +
      `<span class="preview-lanes">${previewDotsHtml(child.lanes)}</span>` +
      `<span class="tcount">${n} talent${n===1?'':'s'}</span>` +
    `</button>` +
    `<div class="skill-body-wrap"><div class="skill-body-inner"><div class="skill-body-pad">${body}</div></div></div>`;
  const head = card.querySelector('.nested-head');
  const wrap = card.querySelector('.skill-body-wrap');
  head.addEventListener('click', () => setCardOpen(head, wrap, !head.classList.contains('open')));
  return card;
}

DATA.specs.forEach((s, i) => {
  const tab = document.createElement('div');
  tab.className = 'tab' + (i === 0 ? ' active' : '');
  tab.textContent = s.spec;
  tab.onclick = () => setActiveSpec(i);
  tabsEl.appendChild(tab);

  const section = document.createElement('div');
  section.className = 'spec-section' + (i === 0 ? ' active' : '');
  section.dataset.specIndex = i;
  let dividerShown = false;
  s.skills.forEach(sk => {
    if (sk.isFamily && !dividerShown) {
      const divider = document.createElement('div');
      divider.className = 'family-divider';
      divider.textContent = 'Spell families';
      section.appendChild(divider);
      dividerShown = true;
    }
    const card = document.createElement('div');
    card.className = 'skill-card';
    const nestedNames = (sk.nested || []).map(n => n.skill + ' ' + n.talents.map(t => t.name).join(' ')).join(' ');
    card.dataset.searchText = (sk.skill + ' ' + sk.talents.map(t => t.name).join(' ') + ' ' + nestedNames).toLowerCase();

    let bodyOut = '<ul class="talents">';
    sk.talents.forEach(t => { bodyOut += talentLiHtml(t); });
    bodyOut += '</ul>';

    const n = sk.talents.length + (sk.nested || []).length;
    const familyTagHtml = sk.isFamily ? `<span class="family-tag">Family</span>` : '';
    card.innerHTML =
      `<button class="skill-head" aria-expanded="false">` +
        `<span class="chevron">&#9656;</span>` +
        familyTagHtml +
        `<h2>${sk.skill}</h2>` +
        `<span class="preview-lanes">${previewDotsHtml(sk.lanes)}</span>` +
        `<span class="tcount">${n} item${n===1?'':'s'}</span>` +
      `</button>` +
      (sk.isFamily && sk.familyChildren.length
        ? `<div class="applies-to">Applies to: ${sk.familyChildren.join(', ')}</div>`
        : '') +
      `<div class="skill-body-wrap"><div class="skill-body-inner"><div class="skill-body-pad">${bodyOut}</div></div></div>`;

    if (sk.nested && sk.nested.length) {
      const pad = card.querySelector('.skill-body-pad');
      const divider = document.createElement('div');
      divider.className = 'produces-divider';
      divider.textContent = 'Produces';
      pad.appendChild(divider);
      const nestedList = document.createElement('div');
      nestedList.className = 'nested-list';
      sk.nested.forEach(child => nestedList.appendChild(buildNestedCard(child)));
      pad.appendChild(nestedList);
    }

    const head = card.querySelector('.skill-head');
    const wrap = card.querySelector('.skill-body-wrap');
    head.addEventListener('click', () => setCardOpen(head, wrap, !head.classList.contains('open')));

    section.appendChild(card);
  });
  sectionsEl.appendChild(section);
});

function openAll() {
  document.querySelectorAll('.skill-head, .nested-head').forEach(head => {
    setCardOpen(head, head.parentElement.querySelector('.skill-body-wrap'), true);
  });
}
function closeAll() {
  document.querySelectorAll('.skill-head, .nested-head').forEach(head => {
    setCardOpen(head, head.parentElement.querySelector('.skill-body-wrap'), false);
  });
}
document.getElementById('expandAllBtn').onclick = openAll;
document.getElementById('collapseAllBtn').onclick = closeAll;

function setActiveSpec(i) {
  document.querySelectorAll('.tab').forEach((el, idx) => el.classList.toggle('active', idx === i));
  document.querySelectorAll('.spec-section').forEach(el => el.classList.toggle('active', +el.dataset.specIndex === i));
}

searchEl.addEventListener('input', e => {
  const q = e.target.value.trim().toLowerCase();
  document.querySelectorAll('.skill-card').forEach(card => {
    const matches = !q || card.dataset.searchText.includes(q);
    card.style.display = matches ? '' : 'none';
    if (q && matches) {
      setCardOpen(card.querySelector('.skill-head'), card.querySelector('.skill-body-wrap'), true);
      card.querySelectorAll('.nested-head').forEach(nh => setCardOpen(nh, nh.parentElement.querySelector('.skill-body-wrap'), true));
    }
  });
  if (q) {
    document.querySelectorAll('.spec-section').forEach(sec => sec.classList.add('active'));
    document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
  } else {
    closeAll();
    setActiveSpec(0);
  }
});
</script>
</body>
</html>
"""

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Usage: python3 generate_readout_html_nested.py <talents.json> <skill_index_nested.json> <out.html>")
        sys.exit(1)
    build(sys.argv[1], sys.argv[2], sys.argv[3])
