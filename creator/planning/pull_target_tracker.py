"""
pull_target_tracker.py - the first bucket PULL: the Target tracker's members for one class:spec.

Select recipe (from buckets.md): your kept-up things on the enemy - target:enemy|both, persistence:window.
Flavour-tagged: DoT (periodic damage aura) vs bane (non-periodic amp/vuln/weaken/heal-cut) vs control-only
(CC auras - deliberately NOT tracked, listed as the near-miss so the exclusion is readable too).
Deduped by family name (match family, not rank). Read the pull, tune the recipe - nothing is emitted.

  py pull_target_tracker.py NECROMANCER Death
"""
import json
import os
import sys
from collections import defaultdict

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.normpath(os.path.join(_THIS, "..", ".."))
COA = os.path.join(_ROOT, "dependencies", "coa_spells.json")
RESOLVED = os.path.join(_THIS, "resolved.json")

CC = {"mod_stun", "mod_root", "mod_decrease_speed", "mod_silence", "mod_confuse", "mod_fear", "mod_taunt",
      "transform", "mod_pacify", "mod_disarm", "mod_charm"}          # transform added: Ghoulify leaked as "bane"


def spec_spells(d, cls, spec):
    """spell-ids belonging to class:spec - direct, plus triggered spells reached from its abilities."""
    out = {}
    for sid, s in d.items():
        coa = s.get("coa") or {}
        refs = coa.get("direct") or coa.get("triggeredBy") or []
        if any(r.get("class") == cls and (r.get("spec") == spec or spec == "*") for r in refs):
            out[sid] = s
    return out


def main():
    cls, spec = (sys.argv[1] if len(sys.argv) > 1 else "NECROMANCER"), (sys.argv[2] if len(sys.argv) > 2 else "Death")
    d = json.load(open(COA, encoding="utf-8"))
    res = json.load(open(RESOLVED, encoding="utf-8"))
    pool = spec_spells(d, cls, spec)

    fams = defaultdict(lambda: {"flav": set(), "sids": [], "dur": set(), "cd": set(), "auras": set(), "src": set()})
    for sid, s in pool.items():
        r = res.get(sid, {})
        ax = r.get("axes") or {}
        if ax.get("target") not in ("enemy", "both") or ax.get("persistence") != "window":
            continue                                                    # the select recipe
        auras = {e.get("aura_name") for e in r.get("edges", []) if e.get("rel") == "applies_aura"}
        auras.discard(None)
        periodic = any("periodic" in a for a in auras)
        non_cc = auras - CC
        flav = "DoT" if periodic else ("bane" if non_cc else "control")
        f = fams[s.get("name") or sid]
        f["flav"].add(flav)
        f["sids"].append(sid)
        f["dur"].add(round((s.get("durationMs") or 0) / 1000))
        f["cd"].add(round((s.get("cooldownMs") or 0) / 1000))
        f["auras"] |= auras
        tb = (s.get("coa") or {}).get("triggeredBy") or []
        f["src"].add(tb[0].get("ability") if tb else "(pressed)")

    order = {"DoT": 0, "bane": 1, "control": 2}
    print("TARGET TRACKER pull - %s %s  (%d spells in spec pool -> %d families selected)\n"
          % (cls, spec, len(pool), len(fams)))
    for name, f in sorted(fams.items(), key=lambda kv: (min(order[x] for x in kv[1]["flav"]), kv[0])):
        flav = "/".join(sorted(f["flav"], key=lambda x: order[x]))
        dur = ",".join(str(x) for x in sorted(f["dur"]))
        cd = ",".join(str(x) for x in sorted(f["cd"]))
        mark = "  [EXCLUDED - CC only]" if f["flav"] == {"control"} else ""
        print("  %-7s %-28s dur %ss cd %ss  x%d  src:%s%s" % (flav, name[:28], dur, cd, len(f["sids"]),
                                                              "/".join(sorted(f["src"]))[:30], mark))
        print("          auras: %s" % ", ".join(sorted(f["auras"]))[:100])


if __name__ == "__main__":
    main()
