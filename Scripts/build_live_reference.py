"""
build_live_reference.py

Turns a class's raw COA_DevDump captures (trainer.json + talentnodes.json,
already converted from the SavedVariables Lua via lupa - see
addons/COA_DevDump/README.md for that step) into the final
name-keyed live reference JSON.

Usage:
    python3 build_live_reference.py <class_name> <talents_json> <trainer_json> <talentnodes_json> <output_json>

Example:
    python3 build_live_reference.py Necromancer \
        ../Input/necromancer_talents.json \
        ../Outputs/live_reference/necromancer_trainer_raw.json \
        ../Outputs/live_reference/necromancer_talentnodes_raw.json \
        ../Outputs/live_reference/necromancer_live_reference.json

Design notes (why this shape, not a spellId-keyed one):
- Keyed by ability NAME, not spellId, per Battlewrath's direction
  (2026-07-04). Rank-variant abilities can have a dozen-plus distinct
  spellIds in Spell.dbc (Crypt Swarm alone has 15) - too many to track
  cleanly by ID, and WeakAuras' own name-based triggers already resolve to
  whatever rank a player has actually learned.
- spellId is still attached as a best-effort field wherever independently
  known (matched by exact name against the class's own Input/*_talents.json),
  never guessed. Trainer-only baseline abilities (no talent-tree link at
  all - e.g. Undead: Pacify/Protect/Assault) will legitimately have no
  spellId - that's expected, not a bug in this script.
- Every entry carries verifiedLive: true, since both source types
  (trainer, talent) are real live-client captures, not DBC-derived guesses.
"""
import json
import sys
from collections import OrderedDict


def build(class_name, talents_json_path, trainer_json_path, talentnodes_json_path, output_path):
    with open(trainer_json_path) as f:
        trainer = json.load(f)
    with open(talentnodes_json_path) as f:
        talentnodes = json.load(f)
    with open(talents_json_path) as f:
        known_talents = json.load(f)

    name_to_spellid = {}
    spellid_to_name = {}
    spellid_to_tree = {}
    for t in known_talents['talents']:
        name_to_spellid.setdefault(t['name'], t['spellId'])
        spellid_to_name[t['spellId']] = t['name']
        spellid_to_tree[t['spellId']] = t['tree']

    # --- Trainer entries: group by name, collect rank rows ---
    trainer_by_name = OrderedDict()
    current_tree = None
    for row in trainer:
        if row.get('serviceType') == 'header':
            # Header rows carry garbage cost/levelReq (confirmed live,
            # e.g. cost=1816288370) - they're tree-name markers only.
            current_tree = row.get('name')
            continue
        name = row.get('name')
        if not name:
            continue
        entry = trainer_by_name.setdefault(name, {
            'name': name,
            'tree': current_tree,
            'source': 'trainer',
            'verifiedLive': True,
            'ranks': [],
        })
        entry['ranks'].append({
            'rankLabel': row.get('subText') or None,
            'cost': row.get('cost'),
            'levelReq': row.get('levelReq'),
            'serviceType': row.get('serviceType'),
            'description': row.get('description'),
        })

    for entry in trainer_by_name.values():
        entry['ranks'].sort(key=lambda r: (r['levelReq'] if r['levelReq'] is not None else 0))
        matched = name_to_spellid.get(entry['name'])
        entry['spellId'] = matched
        entry['spellIdSource'] = f'{talents_json_path} exact name match' if matched else None

    # --- Talent node entries: one per spellID, name resolved via the
    #     class's own talents.json (talentnodes itself has no name field -
    #     only spellID/rank/maxRank/position, read directly off the live
    #     widget) ---
    talent_by_name = OrderedDict()
    for sid_str, node in talentnodes.items():
        sid = node['spellID']
        name = spellid_to_name.get(sid, f'(unknown spellId {sid})')
        tree = spellid_to_tree.get(sid, node.get('tree'))
        talent_by_name[name] = {
            'name': name,
            'tree': tree,
            'source': 'talent',
            'verifiedLive': True,
            'spellId': sid,
            'spellIdSource': 'live talentnodes capture',
            'liveRank': node.get('rank'),
            'liveMaxRank': node.get('maxRank'),
            'position': {'left': node.get('left'), 'top': node.get('top')},
        }

    # --- Merge (trainer entries take priority as the base record if a
    #     name appears in both; talent-node data folds in as a sub-field) ---
    abilities = OrderedDict()
    for name, entry in trainer_by_name.items():
        abilities[name] = entry
    for name, entry in talent_by_name.items():
        if name in abilities:
            abilities[name]['spellId'] = abilities[name]['spellId'] or entry['spellId']
            abilities[name]['spellIdSource'] = abilities[name]['spellIdSource'] or entry['spellIdSource']
            abilities[name]['talentNode'] = {
                k: v for k, v in entry.items() if k in ('liveRank', 'liveMaxRank', 'position')
            }
        else:
            abilities[name] = entry

    resolved = sum(1 for a in abilities.values() if a.get('spellId'))

    out = {
        '_readme': (
            f"Durable live-verified reference for the {class_name} class, built to support "
            "WeakAuras work. Keyed by ability NAME (not spellId) deliberately - rank-variant "
            "abilities can have too many distinct spellIds to track cleanly by ID, and "
            "WeakAuras' own combat-log/cast triggers can match by name directly, which "
            "naturally covers whatever rank a player has learned. spellId is included as a "
            "best-effort cross-reference where independently known, not as the primary key. "
            "Two source types: 'trainer' (gold-trained baseline/leveling abilities, captured "
            "live via the stock GetTrainerServiceInfo API) and 'talent' (talent-point "
            "investments, captured live by reading spellID/rank/maxRank fields directly off "
            "the custom CoATalentFrame's button widgets - see "
            "addons/COA_DevDump/README.md for why the stock talent API doesn't work "
            "on this server). verifiedLive:true on every entry reflects a real live client "
            "capture, not a derived/guessed value."
        ),
        'class': class_name,
        'schemaVersion': 1,
        'totalAbilities': len(abilities),
        'spellIdResolvedCount': resolved,
        'abilities': abilities,
    }

    with open(output_path, 'w') as f:
        json.dump(out, f, indent=2)

    print(f'Total unique abilities: {len(abilities)}')
    print(f'  from trainer: {len(trainer_by_name)}')
    print(f'  from talentnodes: {len(talent_by_name)}')
    print(f'  spellId resolved: {resolved} / {len(abilities)}')
    print(f'Wrote {output_path}')


if __name__ == '__main__':
    if len(sys.argv) != 6:
        print(__doc__)
        sys.exit(1)
    build(*sys.argv[1:6])
