"""
citizenship.py - PASS 2 (first look): type each spell's CITIZENSHIP over the resolved data.

Controlled = a thing you PRESS (active, on-GCD or cast, a direct player ability). Empowering = a thing that EMPOWERS you
(applies a buff, modifies a cooldown, a family effect - the mechanic / proc side). A spell can be BOTH (an active buff
you cast), or neither (inert substrate). First cut - to LOOK at, then refine the signals together.

Reads coa_spells.json + resolved.json (run resolver.py first). Reports the first-class breakdown + samples.

  py citizenship.py
"""
import json
import os
import sys
from collections import Counter, defaultdict

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.normpath(os.path.join(_THIS, "..", ".."))
sys.path.insert(0, os.path.join(_ROOT, "Scripts"))
import spell_enums as se

COA = os.path.join(_ROOT, "dependencies", "coa_spells.json")
RESOLVED = os.path.join(_THIS, "resolved.json")
EMPOWER_EDGES = {"applies_aura", "modify_cooldown", "family_effect"}


def type_spell(s, r):
    passive = se.is_passive(s.get("attr"))                           # attr is a LIST; se handles it
    gcd, cast = s.get("gcdMs") or 0, s.get("castTimeMs") or 0
    direct = (s.get("coa") or {}).get("relation") == "direct"
    kinds = {e["rel"] for e in r.get("edges", [])}
    # self-buff (empowers YOU) vs debuff (on the enemy) - from the apply_aura target, not the weak debuff bit
    self_buff = debuff = False
    eff, tgt = s.get("effect") or [], s.get("effectTargetA") or []
    for i in range(3):
        if i < len(eff) and eff[i] == 6:                            # apply_aura
            cat = se.target_category(tgt[i] if i < len(tgt) else 0) or ""
            if "enemy" in cat:
                debuff = True
            elif "self" in cat or "ally" in cat:
                self_buff = True
    dm = s.get("durationMs")
    finite = bool(dm and dm > 0)                                    # a window you watch, vs permanent (-1) always-on
    hub = len((s.get("coa") or {}).get("triggeredBy") or []) >= 5   # a mechanic hub (many things reference it)
    mech_edge = bool(kinds & {"modify_cooldown", "family_effect"})
    # trackable empowerment = a STATE you watch; passive = always-on background stat mod
    trackable = mech_edge or (self_buff and (finite or hub))
    passive_buff = self_buff and not trackable
    controlled = (not passive) and (gcd > 0 or cast > 0) and direct
    if controlled and trackable:
        return "both"
    if controlled:
        return "controlled"
    if trackable:
        return "empowering"                                         # FIRST-CLASS: finite window / proc / mechanic
    if passive_buff:
        return "passive"                                            # always-on empowerment - nothing to track
    if debuff:
        return "offensive"                                          # a debuff/DoT - the OUTPUT, paired to its source
    return "substrate"


def source_of(s):
    """for an offensive/output spell: who applies or triggers it (the pairing). Its triggeredBy attribution."""
    tb = (s.get("coa") or {}).get("triggeredBy") or []
    return tb[0].get("ability") if tb else "(own effect)"


def main():
    d = json.load(open(COA, encoding="utf-8"))
    res = json.load(open(RESOLVED, encoding="utf-8"))
    counts = Counter()
    per_spec = defaultdict(Counter)
    samples = defaultdict(list)
    for sid, s in d.items():
        t = type_spell(s, res.get(sid, {}))
        counts[t] += 1
        for a in (s.get("coa") or {}).get("direct", []):
            per_spec[(a.get("class"), a.get("spec"))][t] += 1
        if len(samples[t]) < 8:
            samples[t].append(s.get("name") or sid)

    types = ("controlled", "empowering", "both", "passive", "offensive", "substrate")
    tot = sum(counts.values())
    print("FIRST-CLASS breakdown (%d spells):" % tot)
    for t in types:
        print("  %-11s %5d  (%4.1f%%)" % (t, counts[t], 100 * counts[t] / tot))
    print()
    for t in types:
        print("%s e.g.: %s" % (t, ", ".join(str(x) for x in samples[t][:6])))
    print()
    # the pairing: offensive/output spells -> the ability that sources them
    print("offensive OUTPUT -> its source (debuff paired to its trigger/ability):")
    shown = 0
    for sid, s in d.items():
        if shown >= 8:
            break
        if type_spell(s, res.get(sid, {})) == "offensive":
            print("  %-26s <- %s" % ((s.get("name") or sid)[:26], source_of(s)))
            shown += 1
    print()
    print("per class:spec (Reaper + Necromancer):")
    for (cls, spec), cc in sorted(per_spec.items()):
        if cls in ("REAPER", "NECROMANCER"):
            print("  %-13s %-14s %s" % (cls, spec, dict(cc)))


if __name__ == "__main__":
    main()
