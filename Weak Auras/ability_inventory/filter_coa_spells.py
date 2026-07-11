"""
filter_coa_spells.py - the FILTER step: split a focused table off the full Spell.dbc store
(Outputs/spell_dbc/spell_dbc_full.json), limited to our area of interest, and INJECT the
explicit indexing the DBC can't carry (class:spec/source), keyed from our inventory.

Area of interest = the COA class-hooked ids (ability_inventory/out/*.json) PLUS their
effectTriggerSpell closure (the proc buffs / triggered spells they reach - un-hooked but part
of the mechanics; e.g. Bone King -> 707176). Each record carries the DBC manifest + a `coa`
block: `direct` referrers (class/spec/source/ability from the inventory) and, for reached-by-
trigger spells, `triggeredBy` (which class:spec ability reaches it).

    py filter_coa_spells.py
Output: dependencies/coa_spells.json  (tracked - the COA-relevant subset; lives in the
        checked-in dependencies/ folder, NOT under the ignored Outputs/spell_dbc/ store).
"""
import json
import os
import sys
from collections import defaultdict, deque

sys.stdout.reconfigure(encoding="utf-8")
_HERE = os.path.dirname(os.path.abspath(__file__))
_WA = os.path.dirname(_HERE)
_ROOT = os.path.dirname(_WA)
FULL = os.path.join(_ROOT, "Outputs", "spell_dbc", "spell_dbc_full.json")
INV = os.path.join(_HERE, "out")
OUT = os.path.join(_ROOT, "dependencies", "coa_spells.json")

_MANIFEST = ("name", "rank", "icon", "cooldownMs", "castTimeMs", "durationMs", "gcdMs",
             "maxRange", "powerType", "manaCost", "manaCostPct", "schoolMask", "mechanic",
             "attr", "targets", "procFlags", "procChance", "procCharges", "spellClassSet",
             "spellClassMask", "effect", "effectAura", "effectMisc", "effectTriggerSpell",
             "effectTargetA", "baseLevel", "spellLevel")


def main():
    full = json.load(open(FULL, encoding="utf-8"))

    # spellId -> [ {class, display, spec, source, ability} ]  (direct, from the inventory)
    direct = defaultdict(list)
    for f in sorted(os.listdir(INV)):
        if not f.endswith(".json") or f in ("_summary.json", "captures.json"):
            continue
        inv = json.load(open(os.path.join(INV, f), encoding="utf-8"))
        for name, a in inv["abilities"].items():
            for sid in a.get("spellIds", []):
                direct[str(sid)].append({"class": inv["class"], "display": inv.get("display"),
                                         "spec": a.get("spec"), "source": a.get("sources"),
                                         "ability": name})

    # BFS the effectTriggerSpell closure from the direct seeds
    scope = {}                                   # id -> depth
    triggeredBy = defaultdict(list)              # triggered id -> [{class, spec, ability, via}]
    q = deque()
    for sid in direct:
        scope[sid] = 0
        q.append(sid)
    while q:
        sid = q.popleft()
        rec = full.get(sid)
        if not rec or scope[sid] >= 3:
            continue
        for t in rec.get("effectTriggerSpell") or []:
            ts = str(t)
            if t and ts in full:
                for r in (direct.get(sid) or [{"class": None, "spec": None, "ability": None}]):
                    triggeredBy[ts].append({"class": r.get("class"), "spec": r.get("spec"),
                                            "ability": r.get("ability"), "via": int(sid)})
                if ts not in scope:
                    scope[ts] = scope[sid] + 1
                    q.append(ts)

    out = {}
    for sid in scope:
        rec = full.get(sid)
        if not rec:
            continue
        row = {k: rec.get(k) for k in _MANIFEST}
        row["coa"] = {"direct": direct.get(sid, []),
                      "triggeredBy": triggeredBy.get(sid, []),
                      "relation": "direct" if sid in direct else "triggered"}
        out[sid] = row

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    json.dump(out, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)

    n_direct = sum(1 for v in out.values() if v["coa"]["relation"] == "direct")
    n_trig = len(out) - n_direct
    # class:spec key coverage
    keyed = defaultdict(int)
    for v in out.values():
        for r in v["coa"]["direct"]:
            keyed[(r["class"], r["spec"])] += 1
    print(f"COA area of interest: {len(out)} spells | direct {n_direct} | pulled in via triggers {n_trig}")
    print(f"class:spec keys populated (direct): {len(keyed)} distinct")
    print(f"  sample: {dict(list(sorted(keyed.items(), key=lambda x:-x[1]))[:6])}")
    print(f"wrote {os.path.relpath(OUT, _ROOT)} ({os.path.getsize(OUT)//1024} KB)")


if __name__ == "__main__":
    main()
