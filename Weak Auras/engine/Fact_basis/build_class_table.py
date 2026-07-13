"""
build_class_table.py - regenerate the class fact basis (class_table.json). SOURCED, nothing authored.

The user-facing name <-> WA/game class API TOKEN <-> classId pairing comes from the trainer-scrape consolidation
(ability_inventory/out/<TOKEN>.json - each file's class/display/classId). `wa_load_verified` comes from whether the token
appears in a real aura's load.class in the corpus (battlewrath_displays.json) = WA-usage proven live. COA classes ride
base-class shells, so the api_name is an OPAQUE codename you can't guess (SONOFARUGAL=Bloodmage, MONK=Templar,
DEMONHUNTER=Felsworn, WILDWALKER=Primalist) - which is why we source it, never guess it.

  py build_class_table.py   -> class_table.json
"""
import json
import glob
import os

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.normpath(os.path.join(_THIS, "..", "..", ".."))
OUT_INV = os.path.join(_ROOT, "Weak Auras", "ability_inventory", "out")
CORPUS = os.path.join(_ROOT, "Outputs", "aura_corpus", "battlewrath_displays.json")
OUT = os.path.join(_THIS, "class_table.json")


def _pairing():
    pair = {}
    for f in glob.glob(os.path.join(OUT_INV, "*.json")):
        try:
            d = json.load(open(f, encoding="utf-8"))
        except Exception:
            continue
        if isinstance(d, dict) and d.get("class"):
            pair[d["class"]] = {"display": d.get("display"), "classId": d.get("classId")}
    return pair


def _corpus_load_tokens():
    """distinct class tokens seen in a real aura's load.class in the corpus = WA-usage proven live."""
    toks = set()
    if not os.path.exists(CORPUS):
        return toks

    def walk(o):
        if isinstance(o, dict):
            ld = o.get("load")
            lc = ld.get("class") if isinstance(ld, dict) else None
            if isinstance(lc, dict):
                if isinstance(lc.get("multi"), dict):
                    toks.update(lc["multi"].keys())
                if lc.get("single"):
                    toks.add(lc["single"])
            for v in o.values():
                walk(v)
        elif isinstance(o, list):
            for v in o:
                walk(v)
    walk(json.load(open(CORPUS, encoding="utf-8")))
    return toks


def build():
    pair, corpus = _pairing(), _corpus_load_tokens()
    classes = [{"class_name": pair[t]["display"], "api_name": t, "classId": pair[t]["classId"],
                "wa_load_verified": t in corpus} for t in sorted(pair)]
    return {"_meta": {
        "what": "COA class fact basis: user-facing name <-> WA/game class API token <-> classId.",
        "api_name": "FACT - the game class API token (GetClassInfo, trainer scrape). COA rides base-class shells so the "
                    "token is an opaque codename (SONOFARUGAL=Bloodmage, MONK=Templar). Sourced, never guessed.",
        "wa_load_verified": "token seen in a real aura's load.class in the corpus (WA-usage proven live). false = the "
                            "token is fact but WA-load use not yet corpus-confirmed (it IS the game class token, so expected).",
        "source": "api_name/classId/display <- ability_inventory/out/<TOKEN>.json; wa_load_verified <- "
                  "Outputs/aura_corpus/battlewrath_displays.json load.class. Regenerate: py build_class_table.py.",
        "count": len(classes)}, "classes": classes}


def main():
    table = build()
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(table, f, ensure_ascii=False, indent=1)
        f.write("\n")
    v = sum(c["wa_load_verified"] for c in table["classes"])
    print("class_table.json: %d classes | %d wa_load_verified (corpus)" % (len(table["classes"]), v))


if __name__ == "__main__":
    main()
