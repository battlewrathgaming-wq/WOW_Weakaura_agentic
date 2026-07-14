"""
citizenship.py - PASS 2: DERIVE the views over the resolved axes (fact -> taste).

Pass 1 (resolver.py) stored the deterministic COORDINATES per spell: axes = {invocation, persistence, target, verb, hub}.
This step doesn't re-read raw fields - it reads those axes and projects the view the generator actually consumes: which
native SIGNAL tracks this spell. That mapping IS the taste (which coordinates earn a tracker), kept explicit and in one
place, so the old controlled/empowering/offensive labels stop being a stored enum we keep re-cutting.

  native signal:  mechanic | cooldown | buff-window | debuff | resource | none
  first-class  =  any signal but 'none' (it earns a tracker)

Reads coa_spells.json (for the couple of raw fields the mapping needs) + resolved.json (run resolver.py first).

  py citizenship.py
"""
import json
import os
import sys
from collections import Counter, defaultdict

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.normpath(os.path.join(_THIS, "..", ".."))
sys.path.insert(0, os.path.join(_ROOT, "Scripts"))
import spell_enums as se  # noqa: F401  (kept: the enum authority these axes were read against)

COA = os.path.join(_ROOT, "dependencies", "coa_spells.json")
RESOLVED = os.path.join(_THIS, "resolved.json")

SIGNALS = ("mechanic", "cooldown", "buff-window", "debuff", "resource", "none")


def signal_of(r, s):
    """DERIVED VIEW: which native signal tracks this spell, read off the stored axes (+ a couple raw fields)."""
    ax = r.get("axes") or {}
    inv, per, tgt, verb, hub = (ax.get("invocation"), ax.get("persistence"),
                                ax.get("target"), ax.get("verb"), ax.get("hub"))
    selfish = tgt in ("self/ally", "both")
    enemy = tgt in ("enemy", "both")
    if hub and verb == "apply_aura" and selfish:
        return "mechanic"                               # the class hub - a stacks/resource state you watch
    if inv == "pressed" and (s.get("cooldownMs") or 0) > 0:
        return "cooldown"                               # a button with a cooldown to watch
    if selfish and per == "window":
        return "buff-window"                            # a buff you hold (proc / temporary empowerment)
    if enemy and per == "window":
        return "debuff"                                 # a debuff on the target, paired to its source ability
    if verb and "energize" in verb:
        return "resource"                               # generates the class resource
    return "none"                                       # passive / instant output / background - no tracker


def first_class(r, s):
    return signal_of(r, s) != "none"


def source_of(r, s, d):
    """for a debuff: walk to the pressed ability that applies it (the pairing). triggeredBy first, else the direct owner."""
    tb = (s.get("coa") or {}).get("triggeredBy") or []
    if tb:
        return tb[0].get("ability")
    direct = (s.get("coa") or {}).get("direct") or []
    return direct[0].get("ability") if direct else "(own effect)"


def main():
    d = json.load(open(COA, encoding="utf-8"))
    res = json.load(open(RESOLVED, encoding="utf-8"))
    counts = Counter()
    per_spec = defaultdict(Counter)
    samples = defaultdict(list)
    for sid, s in d.items():
        r = res.get(sid, {})
        sig = signal_of(r, s)
        counts[sig] += 1
        for a in (s.get("coa") or {}).get("direct", []):
            per_spec[(a.get("class"), a.get("spec"))][sig] += 1
        if len(samples[sig]) < 8:
            samples[sig].append(s.get("name") or sid)

    tot = sum(counts.values())
    fc = tot - counts["none"]
    print("NATIVE SIGNAL breakdown (%d spells) - the derived view over the axes:" % tot)
    for sig in SIGNALS:
        print("  %-12s %5d  (%4.1f%%)" % (sig, counts[sig], 100 * counts[sig] / tot))
    print("  -> first-class (earns a tracker): %d  (%.1f%%)" % (fc, 100 * fc / tot))
    print()
    for sig in SIGNALS:
        print("%-12s e.g.: %s" % (sig, ", ".join(str(x) for x in samples[sig][:6])))
    print()
    print("debuff -> source (the pairing, walked off the resolved edges):")
    shown = 0
    for sid, s in d.items():
        if shown >= 8:
            break
        r = res.get(sid, {})
        if signal_of(r, s) == "debuff":
            print("  %-26s <- %s" % ((s.get("name") or sid)[:26], source_of(r, s, d)))
            shown += 1
    print()
    print("per class:spec signal mix (Reaper + Necromancer):")
    for (cls, spec), cc in sorted(per_spec.items()):
        if cls in ("REAPER", "NECROMANCER"):
            print("  %-13s %-14s %s" % (cls, spec, dict(cc)))


if __name__ == "__main__":
    main()
