"""
extract_spell_dbc.py - the "store it all" step. Reads the LIVE server Spell.dbc
(area-52/patch-D.MPQ, validated vs the live scrape: see memory/proc-basis-plan.md) and
writes a pared full-manifest record per real (named) spell - EVERY spell in the game data,
not just the ~6922 COA class-hooked ones. Catches classless-mode / un-hooked / triggered /
summoned spells the in-game scrape can't see. Filter for COA-relevance downstream.

Resolves the index fields (cooldown = max(Recovery, Category); castTime/duration/range via
their companion DBCs) and keeps the categorization + PROC-BASIS fields raw (ProcFlags,
EffectTriggerSpell, EffectSpellClassMask x SpellClassMask = the structured talent->ability
linkage). Reuses build_weakaura_index.py's tested loaders.

    py extract_spell_dbc.py
Output: Outputs/spell_dbc/spell_dbc_full.json  (gitignored - large, regenerable).
"""
import json
import os
import struct
import sys

sys.stdout.reconfigure(encoding="utf-8")
_HERE = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.dirname(_HERE)
sys.path.insert(0, _HERE)
import mpyq
from build_weakaura_index import load_spell_dbc, load_simple_dbc  # tested parsers

DATA = r"F:/games/Ascension_wow/resources/ascension-live/Data"
OUT_DIR = os.path.join(_ROOT, "Outputs", "spell_dbc")
INV_DIR = os.path.join(_ROOT, "Weak Auras", "ability_inventory", "out")

# priority order: custom patches first (area-52/patch-D holds the live Spell.dbc, validated),
# then fall through for companion DBCs (SpellCastTimes/Duration/Range) which live in base/other.
MPQ_PRIORITY = [
    "area-52/patch-D.MPQ", "patch-T.MPQ", "patch-B.MPQ", "patch-A.MPQ",
    "patch-5.MPQ", "patch-4.MPQ", "patch-3.MPQ", "patch-2.MPQ",
    "enUS/patch-enUS-3.MPQ", "enUS/patch-enUS-2.MPQ", "enUS/patch-enUS.MPQ",
    "lichking.MPQ", "expansion.MPQ", "common-2.MPQ", "common.MPQ", "enUS/locale-enUS.MPQ",
]


class Multi:
    def __init__(self, base, names):
        self.archives = []
        for n in names:
            p = os.path.join(base, n)
            if os.path.exists(p):
                try:
                    self.archives.append(mpyq.MPQArchive(p))
                except Exception:
                    pass

    def read_file(self, name):
        for a in self.archives:
            try:
                d = a.read_file(name)
                if d:
                    return d
            except Exception:
                pass
        return None


def load_range(mpq):
    """SpellRange.dbc -> {id: maxRange}. Layout: id, minHost, minFriend, maxHost, ..."""
    data = mpq.read_file("DBFilesClient\\SpellRange.dbc")
    _, rc, _, rs, _ = struct.unpack("<4sIIII", data[:20])
    out = {}
    for i in range(rc):
        b = 20 + i * rs
        vals = struct.unpack("<5f", data[b + 4:b + 24])   # after id: minH,minF,maxH,maxF...
        out[struct.unpack("<I", data[b:b + 4])[0]] = round(vals[2])  # maxRangeHostile
    return out


def coa_ids():
    ids = set()
    for f in os.listdir(INV_DIR):
        if f.endswith(".json") and f not in ("_summary.json", "captures.json"):
            d = json.load(open(os.path.join(INV_DIR, f), encoding="utf-8"))
            for a in d["abilities"].values():
                for s in a.get("spellIds", []):
                    ids.add(int(s))
    return ids


def main():
    mpq = Multi(DATA, MPQ_PRIORITY)
    print("loading Spell.dbc (~30-40s)...")
    sp = load_spell_dbc(mpq)
    castt = load_simple_dbc(mpq, "SpellCastTimes.dbc")   # id -> base cast ms
    durs = load_simple_dbc(mpq, "SpellDuration.dbc")     # id -> duration ms
    rng = load_range(mpq)

    out = {}
    for sid, r in sp.items():
        name = r.get("Name_0") or ""
        if not name.strip():
            continue                                     # skip empty/placeholder records
        cd = max(r.get("RecoveryTime") or 0, r.get("CategoryRecoveryTime") or 0)
        out[str(sid)] = {
            "id": sid, "name": name, "rank": r.get("NameSubtext_0") or None,
            "desc": r.get("Description_0") or None, "icon": r.get("SpellIconID"),
            "cooldownMs": cd or None, "castTimeMs": castt.get(r.get("CastingTimeIndex")),
            "durationMs": durs.get(r.get("DurationIndex")),
            "gcdMs": r.get("StartRecoveryTime") or 0, "maxRange": rng.get(r.get("RangeIndex")),
            "powerType": r.get("PowerType"), "manaCost": r.get("ManaCost"),
            "manaCostPct": r.get("ManaCostPct"), "schoolMask": r.get("SchoolMask"),
            "mechanic": r.get("Mechanic"), "dispelType": r.get("DispelType"),
            "attr": [r.get("Attributes"), r.get("AttributesEx"), r.get("AttributesExB"),
                     r.get("AttributesExC"), r.get("AttributesExD"), r.get("AttributesExE"),
                     r.get("AttributesExF"), r.get("AttributesExG")],
            "targets": r.get("Targets"), "shapeshift": r.get("ShapeshiftMask_0"),
            "casterAuraState": r.get("CasterAuraState"), "targetAuraState": r.get("TargetAuraState"),
            "procFlags": r.get("ProcTypeMask"), "procChance": r.get("ProcChance"),
            "procCharges": r.get("ProcCharges"),
            "spellClassSet": r.get("SpellClassSet"),
            "spellClassMask": [r.get("SpellClassMask_0"), r.get("SpellClassMask_1"), r.get("SpellClassMask_2")],
            "effect": [r.get(f"Effect_{i}") for i in range(3)],
            "effectAura": [r.get(f"EffectAura_{i}") for i in range(3)],
            "effectMisc": [r.get(f"EffectMiscValue_{i}") for i in range(3)],
            "effectTriggerSpell": [r.get(f"EffectTriggerSpell_{i}") for i in range(3)],
            "effectTargetA": [r.get(f"EffectImplicitTargetA_{i}") for i in range(3)],
            "effectClassMask": [[r.get(f"EffectSpellClassMask_{ab}_{i}") for ab in "ABC"] for i in range(3)],
            "baseLevel": r.get("BaseLevel"), "spellLevel": r.get("SpellLevel"),
        }

    os.makedirs(OUT_DIR, exist_ok=True)
    outp = os.path.join(OUT_DIR, "spell_dbc_full.json")
    json.dump(out, open(outp, "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))

    coa = coa_ids()
    ids = [int(k) for k in out]
    in_coa = sum(1 for i in ids if i in coa)
    from collections import Counter
    band = Counter((i // 100000) * 100000 for i in ids)
    print(f"total records {len(sp)} | named/real {len(out)} | file {os.path.getsize(outp)//1024//1024} MB")
    print(f"of the {len(out)} real spells: {in_coa} are COA class-hooked (our 6922 set), "
          f"{len(out) - in_coa} are BEYOND COA (classless/un-hooked/triggered)")
    print("id bands (100k):", dict(sorted(band.items())))
    print(f"wrote {os.path.relpath(outp, _ROOT)}")


if __name__ == "__main__":
    main()
