"""
consolidate.py - build the per-class ability inventory by unioning the three sources,
each keyed by spellId, into one merged list of abilities:

  trainer   (COA_DevDump /coadump trainer)  -> TRAINABLE, all ranks, per-rank spellIds,
                                               cost / levelReq / description
  spellbook (COA_DevDump /coadump spellbook) -> LEARNED, spec-tagged (tab = spec tree)
  talents   (Input/<class>_talents.json)     -> full metadata: tree, description, icon,
                                               costs, prerequisites, rankDescriptions

Merge unit = the BASE ability (ranks grouped): "Create Bone Reliquary" -> ranks {2:803768,
3:803769}. The trainer already separates base name from rank (spellName / spellRank), so no
name-parsing is needed for it; spellbook/talent names are normalised defensively.

Class match: the capture's playerClass TOKEN -> talent file, via coa_value_domains.json
(SONOFARUGAL -> Bloodmage handled by the token override there).

    lua5.1 dump_captures.lua      # first: SavedVariables -> out/captures.json
    py consolidate.py            # then: -> out/<CLASS>.json + a summary

Read-only w.r.t. the game; writes only under ability_inventory/out/.
"""
import glob
import json
import os
import re
import sys
from collections import Counter

sys.stdout.reconfigure(encoding="utf-8")
_THIS = os.path.dirname(os.path.abspath(__file__))
_WA = os.path.dirname(_THIS)
_ROOT = os.path.dirname(_WA)
INPUT = os.path.join(_ROOT, "Input")
OUT = os.path.join(_THIS, "out")
COA = os.path.join(_WA, "wa_index", "coa_value_domains.json")

_VANITY = {"Ascension Vanity Items"}
_BASELINE_TAB = "General"


def rank_num(rank_str):
    if not rank_str:
        return 1
    m = re.search(r"\d+", str(rank_str))
    return int(m.group()) if m else 1


def norm(name):
    if not name:
        return ""
    return re.sub(r"\s*\(?\s*rank\s*\d+\s*\)?", "", str(name), flags=re.I).strip()


def talent_file_for(token, coa):
    disp = coa["class_types"].get(token)
    if not disp:
        return None, None
    fn = disp.lower().replace(" ", "_").replace("'", "") + "_talents.json"
    path = os.path.join(INPUT, fn)
    return (path if os.path.exists(path) else None), disp


def main():
    caps = json.load(open(os.path.join(OUT, "captures.json"), encoding="utf-8"))
    coa = json.load(open(COA, encoding="utf-8"))

    # group captures by class token
    trainer_by = {}
    for cap in caps.get("trainer", []):
        trainer_by.setdefault(cap.get("playerClass"), []).append(cap)
    book_by = {}
    for cap in caps.get("spellbook", []):
        book_by.setdefault(cap.get("playerClass"), []).append(cap)

    tokens = sorted(set(trainer_by) | set(book_by))
    tokens = [t for t in tokens if t]
    os.makedirs(OUT, exist_ok=True)
    summary = []

    for token in tokens:
        abilities = {}

        def get(name):
            k = norm(name)
            return abilities.setdefault(k, {"name": k, "spec": None, "sources": set(),
                                            "ranks": {}, "spellIds": set()})

        # --- trainer: authoritative per-rank spellIds + cost/level/desc ---
        for cap in trainer_by.get(token, []):
            for s in cap.get("services", []):
                sid = s.get("spellId")
                if not sid:
                    continue
                a = get(s.get("spellName") or s.get("name"))
                a["sources"].add("trainer")
                a["ranks"][str(rank_num(s.get("spellRank")))] = sid
                a["spellIds"].add(sid)
                a.setdefault("cost", s.get("cost"))
                a.setdefault("levelReq", s.get("levelReq"))
                if s.get("description"):
                    a.setdefault("description", s.get("description"))

        # --- spellbook: spec tag (tab = tree) + learned confirmation ---
        for cap in book_by.get(token, []):
            for tab in cap.get("tabs", []):
                tn = tab.get("tabName")
                if tn in _VANITY:
                    continue
                for sp in tab.get("spells", []):
                    sid = sp.get("spellId")
                    if not sid:
                        continue
                    a = get(sp.get("name"))
                    a["sources"].add("spellbook")
                    a["spellIds"].add(sid)
                    a.setdefault("learnedSpellId", sid)
                    if tn and not a["spec"]:
                        a["spec"] = tn                       # spec tree, or "General"

        # --- talents: dev-authored metadata + authoritative tree ---
        tfile, disp = talent_file_for(token, coa)
        classId = coa.get("class_ids", {}).get(token)
        if tfile:
            tdata = json.load(open(tfile, encoding="utf-8"))
            for t in tdata.get("talents", []):
                a = get(t.get("name"))
                a["sources"].add("talent")
                if t.get("spellId"):
                    a["spellIds"].add(t["spellId"])
                    a.setdefault("talentSpellId", t["spellId"])
                if t.get("tree"):
                    a["spec"] = t["tree"]                    # talent tree is authoritative
                for f in ("description", "iconPath", "isPassive"):
                    if t.get(f) is not None:
                        a.setdefault(f, t[f])

        # finalize
        out_abilities = {}
        for k, a in abilities.items():
            if not k:
                continue
            ranks = {int(r): sid for r, sid in a["ranks"].items()}
            primary = ranks[max(ranks)] if ranks else a.get("learnedSpellId") or \
                a.get("talentSpellId") or (sorted(a["spellIds"])[0] if a["spellIds"] else None)
            out_abilities[k] = {
                "name": k, "spec": a["spec"] or _BASELINE_TAB,
                "sources": sorted(a["sources"]),
                "primarySpellId": primary,
                "ranks": {str(r): ranks[r] for r in sorted(ranks)} or None,
                "spellIds": sorted(a["spellIds"]),
                "cost": a.get("cost"), "levelReq": a.get("levelReq"),
                "isPassive": a.get("isPassive"),
                "iconPath": a.get("iconPath"), "description": a.get("description"),
            }

        by_spec = Counter(v["spec"] for v in out_abilities.values())
        by_src = Counter(tuple(v["sources"]) for v in out_abilities.values())
        rec = {"class": token, "display": disp, "classId": classId,
               "abilityCount": len(out_abilities),
               "bySpec": dict(by_spec),
               "abilities": dict(sorted(out_abilities.items()))}
        json.dump(rec, open(os.path.join(OUT, token + ".json"), "w", encoding="utf-8"),
                  indent=1, ensure_ascii=False)

        src_str = ", ".join("+".join(k) + ":" + str(n) for k, n in by_src.most_common())
        print(f"{token} ({disp}) id={classId}: {len(out_abilities)} abilities")
        print(f"   by spec:   {dict(by_spec)}")
        print(f"   by source: {src_str}")
        summary.append(rec)

    json.dump([{k: v for k, v in r.items() if k != "abilities"} for r in summary],
              open(os.path.join(OUT, "_summary.json"), "w", encoding="utf-8"),
              indent=1, ensure_ascii=False)
    print(f"\nwrote out/<CLASS>.json for {len(tokens)} classes + out/_summary.json")


if __name__ == "__main__":
    main()
