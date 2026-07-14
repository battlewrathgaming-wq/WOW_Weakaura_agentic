"""
name_gaps.py - isolate what each Ascension-custom effect code MEANS, from data already in hand.

The CUSTOM_effect_<n> codes are opaque to our (TrinityCore) enum - Ascension added the handlers server-side. But we
already scraped the game's rendered descriptions, and each spell carries the code's OWN slot fields. A description is the
whole (blended) spell, so we isolate a code three ways at once:
  1. slot-local mechanical fields across the cohort (target / misc / trigger at the code's slot - unblended fact),
  2. the phrase DISTINCTIVE to the cohort's descriptions (lift vs all gap descriptions - not the whole text),
  3. spells where the code is the SOLE effect (description ~= the code itself).
Convergence of the three names the code; where they don't converge, the code is the real scrape residue.

  py name_gaps.py
"""
import json
import os
import sys
import glob
import re
from collections import Counter, defaultdict

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.normpath(os.path.join(_THIS, "..", ".."))
sys.path.insert(0, os.path.join(_ROOT, "Scripts"))
import spell_enums as se

COA = os.path.join(_ROOT, "dependencies", "coa_spells.json")
NAMED = {165}  # already named (modify_cooldown) - skip
STOP = set("the a an of to your you and or by for with in on that this it its their them then each time when will "
           "are was is be being been as at from into every not up down out over off you're inflict deal dealing "
           "target enemy enemies also has have had can causes cause caused per sec min all any more most".split())


def clean(t):
    t = re.sub(r"\|c[0-9a-fA-F]{8}|\|r", "", t or "")   # colour codes
    t = re.sub(r"\$[a-zA-Z<>]*\d*", "", t)              # $s1 / $m1 template tokens
    return re.sub(r"\s+", " ", t).strip()


def toks(t):
    words = [w for w in re.findall(r"[a-zA-Z]+", clean(t).lower()) if len(w) >= 3 and w not in STOP]
    uni = set(words)
    bi = set(words[i] + " " + words[i + 1] for i in range(len(words) - 1))
    return uni | bi


def main():
    d = json.load(open(COA, encoding="utf-8"))
    desc = {}
    for f in glob.glob(os.path.join(_ROOT, "Weak Auras", "ability_inventory", "out", "*.json")):
        if os.path.basename(f) in ("_summary.json", "captures.json"):
            continue
        for ab in json.load(open(f, encoding="utf-8"))["abilities"].values():
            if ab.get("description"):
                for sid in ab.get("spellIds", []):
                    desc[str(sid)] = ab["description"]

    code_hits = defaultdict(list)                       # code -> [(sid, slot)]
    for sid, s in d.items():
        eff = s.get("effect") or []
        for i in range(3):
            c = eff[i] if i < len(eff) else 0
            if c and c not in NAMED:
                name = se.effect_name(c)
                if name.startswith("CUSTOM") or name.startswith("unk"):
                    code_hits[c].append((sid, i))

    described_gap = set(s for hits in code_hits.values() for s, _ in hits if s in desc)
    gtok = Counter()
    for s in described_gap:
        for t in toks(desc[s]):
            gtok[t] += 1
    G = max(1, len(described_gap))

    print("%d custom codes over %d spell-slots | %d gap spells described\n"
          % (len(code_hits), sum(len(h) for h in code_hits.values()), len(described_gap)))
    for code, hits in sorted(code_hits.items(), key=lambda kv: -len(kv[1])):
        described = [(s, i) for s, i in hits if s in desc]
        tgt, misc, trig = Counter(), Counter(), 0
        for s, i in hits:
            rec = d[s]
            ta, mm, tr = rec.get("effectTargetA") or [], rec.get("effectMisc") or [], rec.get("effectTriggerSpell") or []
            tgt[se.target_category(ta[i]) if i < len(ta) else None] += 1
            misc[mm[i] if i < len(mm) else 0] += 1
            if i < len(tr) and tr[i]:
                trig += 1
        solo = [s for s, i in hits if sum(1 for x in (d[s].get("effect") or []) if x) == 1]
        ctok = Counter()
        for s, i in described:
            for t in toks(desc[s]):
                ctok[t] += 1
        C = max(1, len(described))
        lift = sorted(((cnt / C) / (gtok[t] / G + 1e-9), cnt, t) for t, cnt in ctok.items() if cnt >= 3)
        lift.reverse()
        print("== CUSTOM_effect_%d ==  %d spells (%d desc) | slots %s | trigger %d/%d"
              % (code, len(hits), len(described), dict(Counter(i for _, i in hits)), trig, len(hits)))
        print("   target:", dict(tgt.most_common(3)), "| misc top:", misc.most_common(3))
        print("   distinctive:", ", ".join("%s(x%.0f/%d)" % (t, l, c) for l, c, t in lift[:9]) or "(none)")
        if solo:
            s = solo[0]
            print("   SOLO [%s] %s: %s" % (s, d[s].get("name"), clean(desc.get(s, "")) [:110] or "(no desc)"))
        print()


if __name__ == "__main__":
    main()
