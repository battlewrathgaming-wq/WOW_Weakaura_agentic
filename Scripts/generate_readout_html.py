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

def build(talents_path, skill_index_path, out_path):
    with open(talents_path) as f:
        class_data = json.load(f)
    with open(skill_index_path) as f:
        skill_idx = json.load(f)

    class_name = class_data['class']
    accent = CLASS_COLORS.get(class_name, DEFAULT_ACCENT)
    spec_trees = [t for t in class_data['trees'] if t != 'Class']
    lane_taxonomy = skill_idx.get('laneTaxonomy', {})

    specs_payload = []
    for spec in spec_trees:
        available_trees = {'Class', spec}
        skill_to_mods = defaultdict(list)
        for skill, info in skill_idx['skills'].items():
            for m in info['modifyingTalents']:
                if m['tree'] in available_trees:
                    skill_to_mods[skill].append(m)

        skills_payload = []
        def is_family(s):
            return skill_idx['skills'].get(s, {}).get('kind') == 'family'
        ordered_skills = sorted(skill_to_mods, key=lambda s: (is_family(s), -len(skill_to_mods[s])))
        for skill in ordered_skills:
            mods = skill_to_mods[skill]
            base_info = skill_idx['skills'].get(skill, {})
            talent_list = []
            for m in sorted(mods, key=lambda x: (x['tree'] != 'Class', x['position']['y'])):
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
                talent_list.append({
                    'name': m['talent'],
                    'kind': 'Class talent' if m['tree'] == 'Class' else 'Spec talent',
                    'points': points,
                    'freeTag': free_tag,
                    'lanes': m.get('lanes', []),
                    'flags': m.get('flags', []),
                    'stat': stat_parts(m),
                    'description': m['description'],
                    'sharedFromFamily': m.get('sharedFromFamily'),
                })
            all_lanes = sorted(set(l for t in talent_list for l in t['lanes']))
            skills_payload.append({
                'skill': skill,
                'lanes': all_lanes,
                'talents': talent_list,
                'isFamily': is_family(skill),
                'familyChildren': base_info.get('familyChildren', []),
            })
        specs_payload.append({'spec': spec, 'skills': skills_payload})

    payload = {'class': class_name, 'laneTaxonomy': lane_taxonomy, 'specs': specs_payload}
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
<title>__CLASS_NAME__ - Skill Investment Readout</title>
<style>
  :root {
    --bg: #17161a; --panel: #201e1a; --line: #3a3630; --text: #ece8e0; --muted: #969084;
    --class-tag: #c98a3d; --spec-tag: #4d8fc4; --accent: __ACCENT__; --head-hover: #2a2721;
  }
  * { box-sizing: border-box; }
  body { background: var(--bg); color: var(--text); font-family: -apple-system, "Segoe UI", Arial, sans-serif; margin: 0; padding: 24px 20px 60px; max-width: 960px; margin-inline: auto; }
  h1 { font-size: 22px; margin: 0 0 4px; color: var(--accent); font-weight: 700; }
  .sub { color: var(--muted); font-size: 13.5px; margin-bottom: 18px; line-height: 1.5; }
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
</style>
</head>
<body>

<h1>__CLASS_NAME__ &mdash; skill investment readout</h1>
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
DATA.specs.forEach(s => s.skills.forEach(sk => sk.talents.forEach(t => t.lanes.forEach(l => allLanesUsed.add(l)))));
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
    card.dataset.searchText = (sk.skill + ' ' + sk.talents.map(t => t.name).join(' ')).toLowerCase();

    let bodyOut = '<ul class="talents">';
    sk.talents.forEach(t => {
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
      bodyOut += `<li data-lanes='${JSON.stringify(t.lanes)}'>` +
             `<span class="tname">${t.name}</span>` +
             `<span class="tag ${tagClass}">${tagLabel}</span>` +
             pointsHtml + sharedHtml +
             `<div class="lchips">${lanesHtml} ${flagsHtml}</div>` +
             `<div class="desc">${descHtml}</div>` +
             `</li>`;
    });
    bodyOut += '</ul>';

    const n = sk.talents.length;
    const familyTagHtml = sk.isFamily ? `<span class="family-tag">Family</span>` : '';
    card.innerHTML =
      `<button class="skill-head" aria-expanded="false">` +
        `<span class="chevron">&#9656;</span>` +
        familyTagHtml +
        `<h2>${sk.skill}</h2>` +
        `<span class="preview-lanes">${previewDotsHtml(sk.lanes)}</span>` +
        `<span class="tcount">${n} talent${n===1?'':'s'}</span>` +
      `</button>` +
      (sk.isFamily && sk.familyChildren.length
        ? `<div class="applies-to">Applies to: ${sk.familyChildren.join(', ')}</div>`
        : '') +
      `<div class="skill-body-wrap"><div class="skill-body-inner"><div class="skill-body-pad">${bodyOut}</div></div></div>`;

    const head = card.querySelector('.skill-head');
    const wrap = card.querySelector('.skill-body-wrap');
    head.addEventListener('click', () => setCardOpen(head, wrap, !head.classList.contains('open')));

    section.appendChild(card);
  });
  sectionsEl.appendChild(section);
});

function openAll() {
  document.querySelectorAll('.skill-card').forEach(card => {
    setCardOpen(card.querySelector('.skill-head'), card.querySelector('.skill-body-wrap'), true);
  });
}
function closeAll() {
  document.querySelectorAll('.skill-card').forEach(card => {
    setCardOpen(card.querySelector('.skill-head'), card.querySelector('.skill-body-wrap'), false);
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
        print("Usage: python3 generate_readout_html.py <talents.json> <skill_index.json> <out.html>")
        sys.exit(1)
    build(sys.argv[1], sys.argv[2], sys.argv[3])
