"""
populate.py - the document-populating utility. Point it at a CONTRACT; it seeks the members from our spell info
and populates the contract's emit form per member -> Production/_authored/<pid>/<family>.docket.json.

The split: all WA-literal lives in the contract (.json half); this utility is a dumb gear - generic select over the
resolved axes + named exclusion rules + placeholder substitution. Zero WA knowledge here. IDs are the OUTPUT of the
seek, never authored at the top. Gate takes the documents from there (acceptance -> generation -> pickup), unchanged.

  py populate.py target_tracker.contract.json NECROMANCER Death
"""
import json
import os
import re
import sys
from collections import defaultdict

from pull_target_tracker import CC, references_gain, spec_spells   # ONE source for the earned rules

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.normpath(os.path.join(_THIS, "..", ".."))
COA = os.path.join(_ROOT, "dependencies", "coa_spells.json")
RESOLVED = os.path.join(_THIS, "resolved.json")
_FB = os.path.join(_ROOT, "Weak Auras", "engine", "Fact_basis")
MAPS = os.path.join(_FB, "maps", "class_table.json")
ARG_SHAPES = os.path.join(_FB, "maps", "arg_shapes.json")        # stored-form grammar (harvest_arg_shapes.py)
LOAD_SHEET = os.path.join(_FB, "sheets", "load", "load.json")    # load field -> arg type
AUTHORED = os.path.join(_ROOT, "Weak Auras", "engine", "Production", "_authored")


def excluded(rule, d, res, sid, auras):
    if rule == "control_only":
        return bool(auras) and not (auras - CC)
    if rule == "builder":
        return references_gain(d, res, sid)
    raise SystemExit("unknown exclusion rule: %s" % rule)


def seek(contract, d, res, cls, spec):
    """generic select: axes match + named exclusions + family dedupe -> {family: rep_id}."""
    sel = contract["select"]
    fams = defaultdict(list)
    for sid, s in spec_spells(d, cls, spec).items():
        ax = (res.get(sid) or {}).get("axes") or {}
        if not all(ax.get(k) in v for k, v in sel["axes"].items()):
            continue
        auras = {e.get("aura_name") for e in (res.get(sid) or {}).get("edges", [])
                 if e.get("rel") == "applies_aura"} - {None}
        if any(excluded(r, d, res, sid, auras) for r in sel["exclude"]):
            continue
        fams[s.get("name") or sid].append(int(sid))
    return {fam: min(sids) for fam, sids in fams.items()}


def fill(node, subs):
    """substitute {placeholders} through the emit form."""
    if isinstance(node, dict):
        return {k: fill(v, subs) for k, v in node.items()}
    if isinstance(node, list):
        return [fill(v, subs) for v in node]
    if isinstance(node, str):
        return re.sub(r"\{(\w+)\}", lambda m: str(subs[m.group(1)]), node)
    return node


def _apply_template(tpl, name, value):
    """mechanical substitution of <name>/<value> through a stored-form template (zero shape knowledge here)."""
    def sub(x):
        if isinstance(x, dict):
            return {sub(k): sub(v) for k, v in x.items()}
        if isinstance(x, str):
            x = x.replace("<name>", name)
            return value if x == "<value>" else x.replace("<value>", str(value))
        return x
    return sub(tpl)


def shape_load(load, ltypes, shapes):
    """meaning-level load ({class: TOKEN}) -> the WA-literal stored form, via load-sheet type x arg_shapes template.
    The shape comes from the MAP (harvested from ConstructFunction), never hand-written here."""
    out = {}
    for field, value in load.items():
        ty = ltypes.get(field)
        tpl = ((shapes.get("types") or {}).get(ty) or {}).get("template")
        if ty == "multiselect" and isinstance(tpl, dict):        # multi_pick = the UI-native form (live-capture shape)
            out.update(_apply_template(tpl["multi_pick"], field, str(value)))
        elif ty is None:
            out[field] = value                                   # not a load-sheet field - pass through, gate judges
        else:
            raise SystemExit("populate: load field %r is type %r - shaping not wired yet (wall->expand)" % (field, ty))
    return out


def main():
    cpath, cls, spec = sys.argv[1], sys.argv[2], sys.argv[3]
    contract = json.load(open(os.path.join(_THIS, cpath), encoding="utf-8"))
    d = json.load(open(COA, encoding="utf-8"))
    res = json.load(open(RESOLVED, encoding="utf-8"))
    token = next(c["api_name"] for c in json.load(open(MAPS, encoding="utf-8"))["classes"]
                 if c["api_name"] == cls)                            # the maps table is the class-token authority
    shapes = json.load(open(ARG_SHAPES, encoding="utf-8"))
    lsheet = json.load(open(LOAD_SHEET, encoding="utf-8"))
    ltypes = {c["name"]: c.get("type") for c in lsheet.get("conditions", [])}

    kebab = lambda s: re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")   # "Black Knight" -> black-knight (pid-clean)
    subs_base = {"class_lower": kebab(cls), "spec_lower": kebab(spec), "class_token": token, "spec": spec}
    pid = fill(contract["pid"], subs_base)
    os.makedirs(AUTHORED, exist_ok=True)                             # stage reads _authored/ FLAT (machine's contract)

    def press(form, subs, fname):
        doc = fill(form, subs)
        if doc.get("load"):                                          # meaning-level -> WA-literal stored form (map-driven)
            doc["load"] = shape_load(doc["load"], ltypes, shapes)
        fp = os.path.join(AUTHORED, "%s.docket.json" % fname[:60])
        json.dump(doc, open(fp, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
        print("populated  %s" % os.path.relpath(fp, _ROOT))

    # a pack IS a group (pickup: exactly 1 group docket + members) - press the group document first
    press(contract["emit_group"], dict(subs_base, pid=pid,
          group_uid="coa%s%sTargetGrp" % (cls[:3].title(), spec[:5].title())), pid + "__GROUP")

    members = seek(contract, d, res, cls, spec)
    for fam, rep in sorted(members.items()):
        camel = re.sub(r"[^A-Za-z0-9]", "", fam.title())
        press(contract["emit"], dict(subs_base, pid=pid, family=fam, rep_id=rep,
              uid="coa%s%s%s" % (cls[:3].title(), spec[:5].title(), camel[:12])),   # deterministic; inventory uids win when they exist
              "%s__%s" % (pid, camel[:40]))
    print("\n1 group + %d members -> _authored/ (flat)  |  stage.py gates from here" % len(members))


if __name__ == "__main__":
    main()
