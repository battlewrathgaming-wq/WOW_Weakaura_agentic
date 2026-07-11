"""
coa_domains.py - consolidate the COA custom-class enumerations that WA builds at RUNTIME
(class_types / spec_types / ...) from our own scattered files, to fill the inventory-sourced
residue in index_runtime_residue.json (see ground_index.py).

Source of truth: Input/*_talents.json (one per class, each with class/classId/trees). The
WA class TOKEN isn't stored explicitly - it's the display name uppercased, spaces removed
(confirmed vs the corpus: Necromancer->NECROMANCER, Reaper->REAPER, Son of Arugal->
SONOFARUGAL). Multi-word tokens (Knight of Xoroth->KNIGHTOFXOROTH) follow the rule but
warrant a live spot-check.

Emits coa_value_domains.json: { class_types, class_ids, class_trees, class_specs }.
Gaps left explicit: form_types (not in the talent files) + roster completeness (corpus has
SONOFARUGAL, absent from the 21 talent files, so the live roster may exceed these).

    py coa_domains.py
"""
import glob
import json
import os
import sys

sys.stdout.reconfigure(encoding="utf-8")
_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.dirname(os.path.dirname(_THIS))
INPUT = os.path.join(_ROOT, "Input")

# WA class tokens are SERVER-DEFINED and NOT derivable from the display name - they are
# DEV-PROCESS HOLDOVERS (legacy internal codenames from before a class was renamed): the
# class was prototyped under a generic name, renamed to its COA identity, but the internal
# token never migrated. ALL 21 tokens are now CONFIRMED first-hand via UnitClass (trainer/
# spellbook scrape stamped playerClass per char, 2026-07-11). 7 are holdovers (below), the
# other 14 happen to match display-upper. Overrides map display -> real token.
TOKEN_OVERRIDE = {
    "Bloodmage": "SONOFARUGAL",       # <- "Son of Arugal"
    "Felsworn": "DEMONHUNTER",        # <- Demon Hunter (trees Infernal/Slayer; char Felelffel)
    "Knight of Xoroth": "FLESHWARDEN",# <- Flesh Warden (trees Hellfire/War; char Felorcpork)
    "Templar": "MONK",                # <- Monk (tree Zealot; char Blindinglite)
    "Primalist": "WILDWALKER",        # <- Wildwalker (tree Geomancy; char Primaltroll)
    "Venomancer": "PROPHET",          # <- Prophet (tree Stalking; char Spidernom)
    "Runemaster": "SPIRITMAGE",       # <- Spirit Mage (char Elfwithrune)
}
ALL_TOKENS_CONFIRMED = True           # every class scraped; UnitClass reported the real token


def token(display):
    if display in TOKEN_OVERRIDE:
        return TOKEN_OVERRIDE[display]
    return display.upper().replace(" ", "").replace("'", "")   # confirmed = matches capture


def main():
    class_types, class_ids, class_trees, class_specs = {}, {}, {}, {}
    for f in sorted(glob.glob(os.path.join(INPUT, "*_talents.json"))):
        d = json.load(open(f, encoding="utf-8"))
        disp = d.get("class")
        if not disp:
            continue
        tok = token(disp)
        trees = d.get("trees")
        names = list(trees.keys()) if isinstance(trees, dict) else \
            [(t.get("name") if isinstance(t, dict) else t) for t in (trees or [])]
        class_types[tok] = disp
        class_ids[tok] = d.get("classId")
        class_trees[tok] = names
        class_specs[tok] = [n for n in names if n != "Class"]   # "Class" = shared base tree

    # all 21 tokens confirmed first-hand via UnitClass captures (see ALL_TOKENS_CONFIRMED)
    token_confidence = {tok: "confirmed" for tok in class_types}
    holdovers = {v: k for k, v in TOKEN_OVERRIDE.items()}
    out = {
        "class_types": class_types,
        "class_ids": class_ids,
        "class_trees": class_trees,
        "class_specs": class_specs,
        "token_confidence": token_confidence,
        "_provenance": {
            "source": "Input/*_talents.json (display+classId+trees) + in-game UnitClass captures",
            "token_rule": "Tokens are SERVER-DEFINED dev-process holdovers, NOT derivable from "
                          "display. ALL 21 now CONFIRMED first-hand via UnitClass (trainer/"
                          "spellbook scrape stamped playerClass). 7 are holdover overrides "
                          "(display->token); the other 14 match display-upper (also capture-"
                          "confirmed).",
            "holdover_tokens": {tok: holdovers[tok] for tok in sorted(holdovers)},
            "gaps": [
                "form_types not sourced here (not in talent files)",
                "spec-reference mapping: how load.spec references specs (tab-index vs name) "
                "- needs WA spec model / a real load block",
            ],
        },
    }
    json.dump(out, open(os.path.join(_THIS, "coa_value_domains.json"), "w", encoding="utf-8"),
              indent=1, ensure_ascii=False)

    print(f"consolidated {len(class_types)} COA classes -> coa_value_domains.json")
    print(f"  all {len(class_types)} tokens confirmed first-hand (UnitClass)")
    print(f"  holdover overrides ({len(TOKEN_OVERRIDE)}): "
          + ", ".join(f"{k}->{v}" for k, v in TOKEN_OVERRIDE.items()))
    print(f"  gaps: form_types (absent), spec-reference mapping")


if __name__ == "__main__":
    main()
