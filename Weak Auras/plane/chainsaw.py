"""
chainsaw.py - pattern the OUR-WA pool (ascension packs + our own corpus; retail
skipped) into part contracts, staging what harvest_parts should build at scale.

For each recurring part-type (trigger by event/type; subregion by type), classify
EVERY field across all instances:
  - value or presence VARIES  -> CONTROLLED  (a hole the spec fills)
  - constant + a real field of this type (per wa_index / identity / use_ gate) -> FRAME
  - constant + not a lever of this type                                         -> RESIDUE (drop)
Plus recurring COMPOSITION signatures (region + triggers + condition forms +
subregions) = the reusable slices.

Read-only report. Sources: ingest/reference (origin=ascension) + Outputs/aura_corpus.
Trust structure; older packs have field drift, so FRAME leans on what's constant
ACROSS instances (a one-off drift won't survive as frame).

    py chainsaw.py                 # full report
    py chainsaw.py <trigger-name>  # one trigger part-type, verbose
"""
import json
import os
import re
import sys
from collections import defaultdict, Counter

try:  # Windows console is cp1252; some frame values carry non-encodable chars
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

_THIS = os.path.dirname(os.path.abspath(__file__))
_WA = os.path.dirname(_THIS)
_ROOT = os.path.dirname(_WA)
IDX = os.path.join(_WA, "wa_index", "index.json")
REF = os.path.join(_WA, "ingest", "reference")
CORPUS = os.path.join(_ROOT, "Outputs", "aura_corpus", "battlewrath_displays.json")

_TRIG_IDENTITY = {"type", "event", "unit"}


def index_sets():
    idx = json.load(open(IDX, encoding="utf-8"))
    trg, sub = defaultdict(set), defaultdict(set)
    for r in idx:
        if r["section"] == "trigger":
            trg[r["namespace"]].add(r["name"])
        elif r["section"] == "subregion":
            sub[r["namespace"]].add(r["name"])
    return trg, sub


def our_nodes():
    out = []
    for f in sorted(os.listdir(REF)):
        if not f.endswith(".json") or f.startswith("Retail_"):
            continue
        rec = json.load(open(os.path.join(REF, f), encoding="utf-8"))
        if rec.get("provenance", {}).get("origin") == "retail":
            continue
        out.append(rec.get("root"))
        out += rec.get("children", [])
    if os.path.exists(CORPUS):
        out += list(json.load(open(CORPUS, encoding="utf-8")).values())
    return [n for n in out if isinstance(n, dict)]


def _norm(v):
    return json.dumps(v, sort_keys=True) if isinstance(v, (dict, list)) else v


def classify(instances, valid, identity=()):
    fv = defaultdict(list)
    for inst in instances:
        for k, v in inst.items():
            fv[k].append(_norm(v))
    n = len(instances)
    frame, holes, residue = {}, [], []
    for f, vals in fv.items():
        varies = len(set(vals)) > 1 or len(vals) < n
        if varies:
            holes.append(f)
        elif f in identity or f in valid or (f.startswith("use_") and f[4:] in valid):
            frame[f] = vals[0]
        else:
            residue.append(f)
    return frame, holes, residue, n


def main():
    trg_idx, sub_idx = index_sets()
    nodes = our_nodes()
    trig_g, sub_g, comps = defaultdict(list), defaultdict(list), Counter()

    for a in nodes:
        rt = a.get("regionType")
        trg = a.get("triggers")
        tlist = (list(trg.values()) if isinstance(trg, dict) else trg) or []
        tevents = []
        for t in tlist:
            tr = t.get("trigger") if isinstance(t, dict) else None
            if isinstance(tr, dict):
                key = tr.get("event") or tr.get("type") or "?"
                trig_g[key].append(tr)
                tevents.append(key)
        subs = a.get("subRegions") or []
        for s in subs:
            if isinstance(s, dict) and s.get("type"):
                sub_g[s["type"]].append(s)
        cprops = set()
        for c in (a.get("conditions") or []):
            if isinstance(c, dict):
                for ch in (c.get("changes") or []):
                    if isinstance(ch, dict) and ch.get("property"):
                        cprops.add(re.sub(r"\d+", "N", ch["property"]))
        sig = (rt, tuple(sorted(set(tevents))), tuple(sorted(cprops)),
               tuple(sorted({s.get("type") for s in subs if isinstance(s, dict) and s.get("type")})))
        comps[sig] += 1

    one = sys.argv[1] if len(sys.argv) > 1 else None
    print(f"OUR-WA pool: {len(nodes)} nodes (retail skipped)\n")
    print("=" * 78)
    print("TRIGGER part-types (frame / holes / residue):")
    for name in sorted(trig_g, key=lambda k: -len(trig_g[k])):
        if one and one not in name:
            continue
        frame, holes, residue, n = classify(trig_g[name], trg_idx.get(name, set()), _TRIG_IDENTITY)
        inidx = "idx" if name in trg_idx else "NO-idx"
        print(f"\n  {name!r}  ({n} instances, {inidx})")
        print(f"    FRAME    { {k: frame[k] for k in sorted(frame)} }")
        print(f"    HOLES    {sorted(holes)}")
        print(f"    RESIDUE  {sorted(residue)}")
    if not one:
        print("\n" + "=" * 78)
        print("SUBREGION part-types:")
        for name in sorted(sub_g, key=lambda k: -len(sub_g[k])):
            frame, holes, residue, n = classify(sub_g[name], sub_idx.get(name, set()), {"type"})
            print(f"  {name:14} n={n:4}  frame:{len(frame):2} holes:{sorted(holes)[:6]} residue:{sorted(residue)[:5]}")
        print("\n" + "=" * 78)
        print("RECURRING COMPOSITIONS (region | triggers | cond-props | subregions) x count:")
        for sig, c in comps.most_common(14):
            rt, tv, cp, sr = sig
            print(f"  x{c:4}  {str(rt):8} trig={list(tv)} cond={list(cp)} subs={list(sr)}")


if __name__ == "__main__":
    main()
