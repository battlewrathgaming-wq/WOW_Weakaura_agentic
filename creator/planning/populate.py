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
MAPS = os.path.join(_ROOT, "Weak Auras", "engine", "Fact_basis", "maps", "class_table.json")
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


def main():
    cpath, cls, spec = sys.argv[1], sys.argv[2], sys.argv[3]
    contract = json.load(open(os.path.join(_THIS, cpath), encoding="utf-8"))
    d = json.load(open(COA, encoding="utf-8"))
    res = json.load(open(RESOLVED, encoding="utf-8"))
    token = next(c["api_name"] for c in json.load(open(MAPS, encoding="utf-8"))["classes"]
                 if c["api_name"] == cls)                            # the maps table is the class-token authority
    subs_base = {"class_lower": cls.lower(), "spec_lower": spec.lower(), "class_token": token}
    pid = fill(contract["pid"], subs_base)
    outdir = os.path.join(AUTHORED, pid)
    os.makedirs(outdir, exist_ok=True)

    members = seek(contract, d, res, cls, spec)
    for fam, rep in sorted(members.items()):
        camel = re.sub(r"[^A-Za-z0-9]", "", fam.title())
        subs = dict(subs_base, pid=pid, family=fam, rep_id=rep,
                    uid="coa%s%s%s" % (cls[:3].title(), spec[:5].title(), camel[:12]))  # deterministic; inventory-provided uids win when they exist
        doc = fill(contract["emit"], subs)
        fp = os.path.join(outdir, "%s.docket.json" % camel[:40])
        json.dump(doc, open(fp, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
        print("populated  %s  (rep %s)" % (os.path.relpath(fp, _ROOT), rep))
    print("\n%d documents -> _authored/%s/  (gate takes it from here)" % (len(members), pid))


if __name__ == "__main__":
    main()
