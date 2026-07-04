"""
generate_reference_sheet.py - builds a single self-contained HTML reference sheet for a
CoA Builder class: one visual talent-tree layout per branch (Class + specs), with
connector lines, hover tooltips, and a skill search that highlights every node touching
a chosen skill across the whole class.

Usage:
    python3 generate_reference_sheet.py bloodmage_talents.json bloodmage_skill_index.json bloodmage_reference.html
"""
import json, sys, html

def build(talents_path, skill_index_path, out_path):
    with open(talents_path) as f:
        class_data = json.load(f)
    with open(skill_index_path) as f:
        skill_idx = json.load(f)

    talents = class_data['talents']
    class_name = class_data['class']

    # invert skill index -> talent name -> list of {skill, statMod, mockValue, primitiveEffect}
    talent_affects = {}
    for skill, info in skill_idx['skills'].items():
        for m in info['modifyingTalents']:
            talent_affects.setdefault(m['talent'], []).append({
                'skill': skill,
                'statModification': m['statModification'],
                'mockValue': m['mockValueOnBaseline10'],
                'primitiveEffect': m['primitiveEffect'],
            })

    # attach affects + spellType (if this talent IS a base skill) to each talent record
    for t in talents:
        t['affects'] = talent_affects.get(t['name'], [])
        base_info = skill_idx['skills'].get(t['name'])
        t['isBaseSkill'] = bool(base_info and base_info.get('isBaseAbilityInTree'))
        t['baseSkillType'] = base_info['spellType'] if base_info else None

    trees = class_data['trees']
    # put Class first if present
    trees = sorted(trees, key=lambda x: (x != 'Class', x))

    payload = {
        'class': class_name,
        'trees': trees,
        'talents': talents,
        'skillList': sorted(skill_idx['skills'].keys()),
        'mostModified': sorted(
            [(k, len(v['modifyingTalents'])) for k, v in skill_idx['skills'].items()],
            key=lambda x: -x[1]
        )[:15],
    }

    html_doc = TEMPLATE.replace('__CLASS_NAME__', html.escape(class_name)).replace(
        '__DATA_JSON__', json.dumps(payload)
    )
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(html_doc)
    print(f"Wrote {out_path} ({len(html_doc)} chars), {len(talents)} talents across {len(trees)} trees")


TEMPLATE = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>__CLASS_NAME__ - CoA Talent Reference Sheet</title>
<style>
  :root {
    --bg: #14100f;
    --panel: #1c1613;
    --line: #4a3a30;
    --ae: #d98c2b;
    --te: #6a9fd9;
    --text: #e8e0d5;
    --muted: #9a8b7c;
    --highlight: #ffe066;
  }
  * { box-sizing: border-box; }
  body {
    background: var(--bg);
    color: var(--text);
    font-family: -apple-system, "Segoe UI", Arial, sans-serif;
    margin: 0;
    padding: 20px;
  }
  h1 { margin: 0 0 4px 0; font-size: 22px; }
  .sub { color: var(--muted); font-size: 13px; margin-bottom: 16px; }
  .toolbar {
    display: flex; gap: 12px; align-items: center; flex-wrap: wrap;
    background: var(--panel); border: 1px solid var(--line); border-radius: 8px;
    padding: 10px 14px; margin-bottom: 18px; position: sticky; top: 10px; z-index: 50;
  }
  .toolbar input {
    background: #0f0c0a; border: 1px solid var(--line); color: var(--text);
    padding: 7px 10px; border-radius: 6px; font-size: 14px; width: 260px;
  }
  .toolbar .hint { color: var(--muted); font-size: 12px; }
  .legend { display: flex; gap: 14px; font-size: 12px; color: var(--muted); margin-left: auto; }
  .legend span.dot { display:inline-block; width:10px; height:10px; border-radius:50%; margin-right:4px; vertical-align:middle; }
  #matchPanel {
    display: none; background: var(--panel); border: 1px solid var(--highlight);
    border-radius: 8px; padding: 10px 14px; margin-bottom: 16px; font-size: 13px;
  }
  #matchPanel b { color: var(--highlight); }
  .tree-block { margin-bottom: 34px; }
  .tree-title {
    font-size: 16px; font-weight: 600; margin-bottom: 8px; padding-bottom: 4px;
    border-bottom: 1px solid var(--line);
  }
  .tree-canvas {
    position: relative; width: 100%; max-width: 1100px; height: 560px;
    background: radial-gradient(ellipse at top, #241c18 0%, #14100f 70%);
    border: 1px solid var(--line); border-radius: 10px; overflow: hidden;
  }
  svg.connectors { position: absolute; inset: 0; width: 100%; height: 100%; pointer-events: none; }
  svg.connectors line { stroke: #55453a; stroke-width: 1.5; }
  .node {
    position: absolute; width: 46px; height: 46px; margin-left: -23px; margin-top: -23px;
    border-radius: 8px; border: 2px solid #6b5744; background: #2a221c;
    display: flex; align-items: center; justify-content: center;
    font-size: 9px; text-align: center; line-height: 1.05; color: var(--text);
    cursor: default; transition: box-shadow .15s, border-color .15s, opacity .15s;
    padding: 2px; overflow: hidden;
  }
  .node.ae { border-color: var(--ae); }
  .node.te { border-color: var(--te); }
  .node.base-skill { background: #33291f; box-shadow: 0 0 0 1px #6b5744 inset; }
  .node .cost-badge {
    position: absolute; bottom: -8px; right: -8px; font-size: 8px; background: #000a;
    border-radius: 4px; padding: 1px 3px; color: var(--muted);
  }
  .node:hover { z-index: 20; box-shadow: 0 0 0 2px #fff5; }
  .node.dim { opacity: 0.18; }
  .node.match { box-shadow: 0 0 0 3px var(--highlight), 0 0 14px var(--highlight); z-index: 30; }
  .tooltip {
    position: fixed; max-width: 340px; background: #100d0b; border: 1px solid var(--highlight);
    border-radius: 8px; padding: 10px 12px; font-size: 12.5px; line-height: 1.4; z-index: 100;
    display: none; pointer-events: none; box-shadow: 0 6px 24px #000a;
  }
  .tooltip h4 { margin: 0 0 4px 0; font-size: 13.5px; color: var(--highlight); }
  .tooltip .meta { color: var(--muted); font-size: 11px; margin-bottom: 6px; }
  .tooltip .affects { margin-top: 6px; border-top: 1px solid var(--line); padding-top: 6px; }
  .tooltip .affects div { margin-bottom: 3px; }
  .tooltip .skillname { color: #8fd08f; font-weight: 600; }
</style>
</head>
<body>

<h1>__CLASS_NAME__ &mdash; CoA Talent Reference Sheet</h1>
<div class="sub">Ability Essence (orange) funds the Class tree. Talent Essence (blue) funds each spec tree (only one spec is active at a time in-game). Hover any node for full detail. Search a skill name to highlight every talent touching it across all trees.</div>

<div class="toolbar">
  <input id="skillSearch" type="text" placeholder="Search a skill, e.g. Bloodbolt..." list="skillOptions" autocomplete="off">
  <datalist id="skillOptions"></datalist>
  <span class="hint">or pick from "most modified" below</span>
  <div class="legend">
    <span><span class="dot" style="background:var(--ae)"></span>Ability Essence</span>
    <span><span class="dot" style="background:var(--te)"></span>Talent Essence</span>
    <span><span class="dot" style="background:var(--highlight)"></span>Matches search</span>
  </div>
</div>

<div id="matchPanel"></div>

<div id="mostModified" style="margin-bottom:18px; font-size:12.5px; color:var(--muted);"></div>

<div id="trees"></div>

<div class="tooltip" id="tooltip"></div>

<script>
const DATA = __DATA_JSON__;

const treesEl = document.getElementById('trees');
const tooltip = document.getElementById('tooltip');
const searchInput = document.getElementById('skillSearch');
const matchPanel = document.getElementById('matchPanel');
const skillOptions = document.getElementById('skillOptions');
const mostModifiedEl = document.getElementById('mostModified');

DATA.skillList.forEach(s => {
  const opt = document.createElement('option');
  opt.value = s;
  skillOptions.appendChild(opt);
});

mostModifiedEl.innerHTML = 'Most-modified skills: ' + DATA.mostModified.map(
  ([name, count]) => `<a href="#" onclick="searchSkill('${name.replace(/'/g,"\\'")}');return false;" style="color:#c9b28a;">${name} (${count})</a>`
).join(' &middot; ');

function nodeId(treeName, talentName) {
  return 'node__' + treeName.replace(/\W+/g,'_') + '__' + talentName.replace(/\W+/g,'_');
}

function renderTree(treeName) {
  const nodes = DATA.talents.filter(t => t.tree === treeName);
  const xs = nodes.map(n => n.x), ys = nodes.map(n => n.y);
  const minX = Math.min(...xs), maxX = Math.max(...xs);
  const minY = Math.min(...ys), maxY = Math.max(...ys);
  const spanX = Math.max(maxX - minX, 1), spanY = Math.max(maxY - minY, 1);

  const block = document.createElement('div');
  block.className = 'tree-block';
  block.innerHTML = `<div class="tree-title">${treeName}</div>`;
  const canvas = document.createElement('div');
  canvas.className = 'tree-canvas';
  block.appendChild(canvas);

  const svgNS = 'http://www.w3.org/2000/svg';
  const svg = document.createElementNS(svgNS, 'svg');
  svg.setAttribute('class', 'connectors');
  canvas.appendChild(svg);

  const byName = {};
  nodes.forEach(n => byName[n.name] = n);

  function pct(n) {
    const px = 6 + ((n.x - minX) / spanX) * 88;
    const py = 8 + ((n.y - minY) / spanY) * 84;
    return { left: px + '%', top: py + '%' };
  }

  // connectors first (under nodes)
  nodes.forEach(n => {
    (n.prerequisites || []).forEach(p => {
      const target = byName[p];
      if (!target) return;
      const a = pct(n), b = pct(target);
      const line = document.createElementNS(svgNS, 'line');
      line.setAttribute('x1', a.left); line.setAttribute('y1', a.top);
      line.setAttribute('x2', b.left); line.setAttribute('y2', b.top);
      svg.appendChild(line);
    });
  });

  nodes.forEach(n => {
    const div = document.createElement('div');
    const currency = n.abilityEssenceCost ? 'ae' : (n.talentEssenceCost ? 'te' : '');
    div.className = 'node ' + currency + (n.isBaseSkill ? ' base-skill' : '');
    div.id = nodeId(treeName, n.name);
    const pos = pct(n);
    div.style.left = pos.left; div.style.top = pos.top;
    div.textContent = n.name.length > 22 ? n.name.slice(0, 20) + '…' : n.name;
    const cost = n.abilityEssenceCost || n.talentEssenceCost || 0;
    if (cost) {
      const badge = document.createElement('span');
      badge.className = 'cost-badge';
      badge.textContent = (n.maxPoints > 1 ? '0/' + n.maxPoints : cost);
      div.appendChild(badge);
    }
    div.dataset.talent = n.name;
    div.dataset.affects = JSON.stringify((n.affects || []).map(a => a.skill.toLowerCase()));
    div.addEventListener('mousemove', e => showTooltip(e, n));
    div.addEventListener('mouseleave', () => tooltip.style.display = 'none');
    canvas.appendChild(div);
  });

  treesEl.appendChild(block);
}

function showTooltip(e, n) {
  let html = `<h4>${n.name}</h4>`;
  html += `<div class="meta">${n.tree} &middot; y${n.y} x${n.x} &middot; cost ${n.abilityEssenceCost ? n.abilityEssenceCost+' AE' : n.talentEssenceCost+' TE'} &middot; max ${n.maxPoints}</div>`;
  if (n.isBaseSkill) {
    html += `<div class="meta">Base skill type: ${(n.baseSkillType||[]).join(', ')}</div>`;
  }
  const desc = (n.description || '').startsWith('$') ? '(template not resolved in source data)' : (n.description || '');
  html += `<div>${desc.replace(/\n/g,'<br>').slice(0, 500)}</div>`;
  if (n.prerequisites && n.prerequisites.length) {
    html += `<div class="meta">Requires 1 of: ${n.prerequisites.join(', ')}</div>`;
  }
  if (n.affects && n.affects.length) {
    html += `<div class="affects">`;
    n.affects.forEach(a => {
      const mod = (a.statModification||[]).map(m => (m.value>0?'+':'') + m.value + m.unit).join(', ') || '—';
      const mock = a.mockValue != null ? ` (10 &rarr; ${a.mockValue})` : '';
      html += `<div><span class="skillname">${a.skill}</span>: ${mod}${mock} &mdash; ${a.primitiveEffect.join('; ')}</div>`;
    });
    html += `</div>`;
  }
  tooltip.innerHTML = html;
  tooltip.style.display = 'block';
  const x = Math.min(e.clientX + 16, window.innerWidth - 360);
  const y = Math.min(e.clientY + 16, window.innerHeight - 200);
  tooltip.style.left = x + 'px';
  tooltip.style.top = y + 'px';
}

DATA.trees.forEach(renderTree);

function applySearch(q) {
  const query = q.trim().toLowerCase();
  const allNodes = document.querySelectorAll('.node');
  if (!query) {
    allNodes.forEach(el => { el.classList.remove('dim'); el.classList.remove('match'); });
    matchPanel.style.display = 'none';
    return;
  }
  let matchCount = 0;
  allNodes.forEach(el => {
    const affects = JSON.parse(el.dataset.affects || '[]');
    const nameMatch = el.dataset.talent.toLowerCase().includes(query);
    const isMatch = nameMatch || affects.some(a => a.includes(query));
    el.classList.toggle('match', isMatch);
    el.classList.toggle('dim', !isMatch);
    if (isMatch) matchCount++;
  });
  matchPanel.style.display = 'block';
  matchPanel.innerHTML = `<b>${matchCount}</b> talent(s) touch "<b>${q}</b>" across all trees (highlighted below).`;
}

searchInput.addEventListener('input', e => applySearch(e.target.value));
function searchSkill(name) {
  searchInput.value = name;
  applySearch(name);
}
</script>
</body>
</html>
"""

if __name__ == '__main__':
    build(sys.argv[1], sys.argv[2], sys.argv[3])
