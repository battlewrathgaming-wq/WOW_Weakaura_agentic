"""
classify_lanes.py - FIRST-CUT behavioural lane classifier over the COA ability inventory.

Reads dependencies/coa_spells.json + the inventory (for explicit rank-collapse), assigns each
rank-collapsed ability to a behavioural LANE using four SOURCED axes (see Scripts/spell_enums.py
and blueprint/BEHAVIOUR.md):
  WHAT  = effect x effectAura (unioned across all 3 slots)
  WHO   = effectImplicitTargetA -> target_category (self/single/aoe/cone/chain)
  HOW-gated = attr flags (passive/hidden/channeled)
  HOW-triggered = procFlags / proc auras

Master split is ACTIVE vs PASSIVE (attr passive/hidden): passives are the modifier/proc
substrate (~65%), actives (~34%) are what earn an aura.

LANE NAMES HERE ARE PROVISIONAL — terminology is sourced, not hardened (external WoW-play
research pending). The aim is clean lane SEPARATION, not per-spell resolution
(blueprint/BEHAVIOUR.md); opaque custom/dummy spells ride their other signals into a lane.

    py classify_lanes.py            # print the lane distribution
    py classify_lanes.py --emit     # + write Outputs/lane_index.json (grab-by-class, traceable)

Emitted index (Outputs/lane_index.json, regenerable):
  byClass[CLASS][spec][lane] -> [ability names]   # grab a lane when working a class
  abilities: [ {class, spec, ability, spellId, lane, active, why:{effects,auras,who,flags}} ]
The `why` block makes every lane assignment TRACEABLE back to the sourced axes that drove it.
"""
import json
import glob
import os
import sys
from collections import Counter, defaultdict

sys.stdout.reconfigure(encoding="utf-8")
_HERE = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.dirname(_HERE)
sys.path.insert(0, _HERE)
from spell_enums import EFFECT, AURA, target_category, is_passive, is_hidden, is_channeled

COA = os.path.join(_ROOT, "dependencies", "coa_spells.json")
INV = os.path.join(_ROOT, "Weak Auras", "ability_inventory", "out")

CC = {"mod_stun", "mod_root", "mod_fear", "mod_silence", "mod_confuse", "mod_charm",
      "mod_pacify", "mod_pacify_silence"}
UTIL = {"mod_increase_speed", "mod_decrease_speed", "mod_stealth", "mod_invisibility",
        "mod_speed_always", "mod_shapeshift", "water_walk", "feather_fall", "hover", "mod_minimum_speed"}
DMG = {"school_damage", "normalized_weapon_dmg", "weapon_percent_damage", "weapon_damage",
       "health_leech", "power_burn"}
PROC = {"proc_trigger_spell", "proc_trigger_damage", "proc_trigger_spell_with_value",
        "periodic_trigger_spell", "periodic_trigger_spell_with_value", "add_target_trigger",
        "add_caster_hit_trigger"}
_APPLY = (6, 27, 35, 65, 143)  # effect types that carry an effectAura


def _ismod(a):
    return bool(a) and (a.startswith("mod_") or a.startswith("add_flat") or a.startswith("add_pct")
                        or a in ("override_class_scripts", "haste_spells", "haste_ranged",
                                 "mana_shield", "school_absorb", "damage_shield"))


def axes(rec):
    """Union the four axes across all 3 effect slots."""
    eff = [e or 0 for e in (rec.get("effect") or [0, 0, 0])]
    aur = [a or 0 for a in (rec.get("effectAura") or [0, 0, 0])]
    tgt = [t or 0 for t in (rec.get("effectTargetA") or [0, 0, 0])]
    E = {EFFECT.get(eff[i]) for i in range(3) if eff[i]}
    A = {AURA.get(aur[i]) for i in range(3) if eff[i] in _APPLY and aur[i]}
    cats = {target_category(t) for t in tgt if t}
    who = ("aoe" if cats & {"aoe_enemy", "aoe_ally", "aoe", "cone", "chain"} else
           "single" if cats & {"single_enemy", "single_ally"} else
           "self" if "self" in cats else "n/a")
    return E, A, who


def classify(rec):
    """Return (lane, why) — why is the traceable evidence that drove the lane."""
    E, A, who = axes(rec)
    attr = rec.get("attr")
    passive = is_passive(attr) or is_hidden(attr)
    proc = bool(rec.get("procFlags")) or bool(A & PROC)
    why = {"effects": sorted(x for x in E if x), "auras": sorted(x for x in A if x),
           "who": who, "passive": passive, "channeled": is_channeled(attr), "proc": proc}
    if not passive:
        if "summon" in E: L = "summon"
        elif "periodic_damage" in A: L = "dot"
        elif "periodic_heal" in A: L = "hot"
        elif E & DMG: L = f"damage:{who}"
        elif "heal" in E or "heal_pct" in E: L = "heal"
        elif A & CC: L = "cc"
        elif A & UTIL: L = "utility/mobility"
        elif proc: L = "active:proc-driver"
        elif any(_ismod(a) for a in A): L = "active:buff"
        elif ("dummy" in E) or ("dummy" in A): L = "active:scripted"
        else: L = "active:other"
    elif any(_ismod(a) for a in A): L = "passive:modifier"
    elif proc: L = "passive:proc"
    elif A & UTIL: L = "passive:aura-util"
    elif ("dummy" in E) or ("dummy" in A): L = "passive:scripted"
    else: L = "passive:other"
    return L, why


def load_primaries():
    """[{class, display, spec, ability, spellId, rec}] — rank-collapsed by EXPLICIT grouping."""
    d = json.load(open(COA, encoding="utf-8"))
    out = []
    for f in sorted(glob.glob(os.path.join(INV, "*.json"))):
        if os.path.basename(f) in ("_summary.json", "captures.json"):
            continue
        inv = json.load(open(f, encoding="utf-8"))
        for name, a in inv["abilities"].items():
            pid = a.get("primarySpellId") or (a.get("spellIds") or [None])[0]
            ids = [pid] + [i for i in (a.get("spellIds") or []) if i != pid]
            rec = next((d[str(i)] for i in ids if str(i) in d), None)
            if rec:
                out.append({"class": inv["class"], "display": inv.get("display"),
                            "spec": a.get("spec"), "ability": name, "spellId": pid, "rec": rec})
    return out


def build_index():
    """Traceable records + a byClass[class][spec][lane] grab-index."""
    prim = load_primaries()
    abilities = []
    index = defaultdict(lambda: defaultdict(lambda: defaultdict(list)))
    for p in prim:
        L, why = classify(p["rec"])
        abilities.append({"class": p["class"], "spec": p["spec"], "ability": p["ability"],
                          "spellId": p["spellId"], "lane": L, "active": not why["passive"],
                          "why": why})
        index[p["class"]][p["spec"] or "General"][L].append(p["ability"])
    return abilities, index


def main():
    abilities, _ = build_index()
    lanes = Counter(a["lane"] for a in abilities)
    ex = defaultdict(list)
    for a in abilities:
        if len(ex[a["lane"]]) < 3:
            ex[a["lane"]].append(a["ability"])
    act = {L: c for L, c in lanes.items() if not L.startswith("passive")}
    pas = {L: c for L, c in lanes.items() if L.startswith("passive")}
    na, npa, n = sum(act.values()), sum(pas.values()), len(abilities)
    print(f"=== {n} abilities  |  ACTIVE {na} ({100*na//n}%)  ·  PASSIVE {npa} ({100*npa//n}%) ===")
    print("\nACTIVE lanes (earn an aura):")
    for L, c in sorted(act.items(), key=lambda x: -x[1]):
        print(f"  {c:5d}  {L:<22} e.g. {', '.join(ex[L][:3])}")
    print("\nPASSIVE lanes (modifier/proc substrate):")
    for L, c in sorted(pas.items(), key=lambda x: -x[1]):
        print(f"  {c:5d}  {L:<22} e.g. {', '.join(ex[L][:3])}")


def emit():
    abilities, index = build_index()
    out = {"_note": "FIRST-CUT lane classification (provisional names). Regenerate: "
                    "py Scripts/classify_lanes.py --emit. Axes sourced in Scripts/spell_enums.py.",
           "count": len(abilities), "byClass": index, "abilities": abilities}
    outp = os.path.join(_ROOT, "Outputs", "lane_index.json")
    os.makedirs(os.path.dirname(outp), exist_ok=True)
    json.dump(out, open(outp, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(f"wrote {os.path.relpath(outp, _ROOT)} ({len(abilities)} abilities, "
          f"{len(index)} classes, {os.path.getsize(outp)//1024} KB)")


if __name__ == "__main__":
    if "--emit" in sys.argv:
        emit()
    else:
        main()
