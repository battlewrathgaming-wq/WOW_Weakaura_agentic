"""
resolver.py - PASS 1: resolve BROAD (creator/planning/, incubating; graduates to creator/ when it proves out).

For every spell, decode its 3 effect slots via Scripts/spell_enums (the TrinityCore-sourced EFFECT/AURA enum) and
STRUCTURE them into a resolved record: everything populated in `effects`, the typed relationships derived into `edges`,
and the unidentified custom codes kept as NAMED gaps (never guessed). NO citizenship here (controlled vs empowering is
pass 2) - this is the mechanical "what does each spell do", complete.

  py resolver.py    -> resolved.json (per-spell) + coverage report
"""
import json
import os
import sys
from collections import Counter

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.normpath(os.path.join(_THIS, "..", ".."))
sys.path.insert(0, os.path.join(_ROOT, "Scripts"))
import spell_enums as se                                         # the decode authority (TC-sourced)

COA = os.path.join(_ROOT, "dependencies", "coa_spells.json")
OUT = os.path.join(_THIS, "resolved.json")

# Ascension-custom effects (>164) we've IDENTIFIED - sourced/confirmed, not guessed. The rest stay NAMED gaps.
KNOWN_CUSTOM = {165: "modify_cooldown"}      # confirmed 2026-07-14; target = a DIRECT spell id in effectMisc


def _slot(s, key, i):
    v = s.get(key) or []
    return v[i] if i < len(v) else 0


def _overlap(a, b):
    try:
        return any(int(a[i]) & int(b[i]) for i in range(3))
    except Exception:
        return False


def resolve(s, byset):
    effects, edges, gaps = [], [], []
    for i in range(3):
        code = _slot(s, "effect", i)
        if not code:
            continue
        name = KNOWN_CUSTOM.get(code) or se.effect_name(code)
        misc, trig, aura = _slot(s, "effectMisc", i), _slot(s, "effectTriggerSpell", i), _slot(s, "effectAura", i)
        e = {"slot": i, "effect": code, "name": name, "misc": misc}
        if code == 6:                                           # APPLY_AURA carries the aura subtype
            e["aura"], e["aura_name"] = aura, se.aura_name(aura)
        effects.append(e)                                       # EVERYTHING populated
        if name.startswith("CUSTOM") or name.startswith("unk"):
            gaps.append(name)
        # --- derived typed EDGES ---
        if trig:
            edges.append({"rel": "triggers", "dst": str(trig), "slot": i})
        if name == "modify_cooldown":
            edges.append({"rel": "modify_cooldown", "dst": str(misc), "slot": i})   # direct-id target (in effectMisc)
        if code == 6:
            edges.append({"rel": "applies_aura", "aura": aura, "aura_name": se.aura_name(aura),
                          "durationMs": s.get("durationMs"), "slot": i})
        ecm = s.get("effectClassMask") or []                    # standard family-effects: target by mask overlap
        cmask = ecm[i] if i < len(ecm) else None
        if cmask and any(cmask):
            fam = [t for t, m in byset.get(s.get("spellClassSet"), []) if _overlap(cmask, m)]
            if fam:
                edges.append({"rel": "family_effect", "effect": name, "targets": fam[:40],
                              "target_count": len(fam), "slot": i})
    return {"effects": effects, "edges": edges, "gaps": sorted(set(gaps))}


def main():
    d = json.load(open(COA, encoding="utf-8"))
    byset = {}                                                  # spellClassSet -> [(sid, spellClassMask)]  for family lookup
    for sid, s in d.items():
        scm = s.get("spellClassMask")
        if s.get("spellClassSet") is not None and scm and any(scm):
            byset.setdefault(s["spellClassSet"], []).append((sid, scm))

    resolved, edge_kinds, gap_codes = {}, Counter(), Counter()
    for sid, s in d.items():
        r = resolve(s, byset)
        resolved[sid] = r
        for e in r["edges"]:
            edge_kinds[e["rel"]] += 1
        for g in r["gaps"]:
            gap_codes[g] += 1

    json.dump(resolved, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print("resolved %d spells -> resolved.json" % len(resolved))
    print("edge kinds:", dict(edge_kinds))
    print("spells with an unidentified-custom gap:", sum(1 for r in resolved.values() if r["gaps"]),
          "| distinct gap codes:", len(gap_codes))
    print("top gap codes:", gap_codes.most_common(6))


if __name__ == "__main__":
    main()
