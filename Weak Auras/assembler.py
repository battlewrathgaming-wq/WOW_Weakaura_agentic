"""
assembler.py - reconstruct a WeakAura from Layer-0 blocks (the parts catalog in
blocks.db), and PROVE the round-trip.

The keystone: we could decompose an aura into blocks; this is the first time we
recompose one. An aura is derived, not stored - the assembler pulls block
snippets by constant ID, fills their holes from a manifest, wires the joins
(conditions / trigger meta), and emits the WA table + import string.

Core claim: `library.invariant[block_id] | fills == the block's original`. If
that's lossless (it is, by construction - invariant = fields all instances share,
holes = the rest), then decompose -> assemble is exact.

Three proofs, run over the live corpus:
  A. block losslessness  - reconstruct every block instance, compare to original.
  B. whole-aura round-trip - decompose an aura to a manifest, assemble it back,
     compare (empty / list-vs-int-dict / float tolerant).
  C. ship - assemble an aura, encode a real import string via weakaura_codec,
     decode it, confirm it survives.

    py assembler.py
"""
import json
import os
import re
import sqlite3
import sys

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
_PROJECT_ROOT = os.path.dirname(_THIS_DIR)
sys.path.insert(0, _THIS_DIR)
import weakaura_codec as wc

CORPUS = os.path.join(_PROJECT_ROOT, "Outputs", "aura_corpus", "battlewrath_displays.json")
DB = os.path.join(_PROJECT_ROOT, "Outputs", "aura_corpus", "blocks.db")


def _slug(s):
    return re.sub(r"[^a-z0-9]+", "_", str(s).lower()).strip("_")


def load_library(db):
    con = sqlite3.connect(db)
    lib = {}
    for bid, kind, ct, holes in con.execute("SELECT block_id,kind,code_template,holes FROM block"):
        lib[bid] = {"kind": kind, "invariant": json.loads(ct), "holes": set(json.loads(holes))}
    con.close()
    return lib


def reconstruct(block_id, fills, lib):
    """invariant code | the instance's hole fills = the original block."""
    return {**lib[block_id]["invariant"], **fills}


# --------------------------------------------------------------------------- compare
def _listify(v):
    if isinstance(v, dict) and v:
        try:
            keys = sorted(int(k) for k in v)
        except (ValueError, TypeError):
            return v
        if keys == list(range(1, len(keys) + 1)):
            return [v[k] if k in v else v[str(k)] for k in keys]
    return v


def norm_eq(a, b):
    """Empty []=={}, a Lua-array-as-list == same-as-int-keyed-dict, float tol."""
    if isinstance(a, (list, dict)) and isinstance(b, (list, dict)) and not a and not b:
        return True
    a, b = _listify(a), _listify(b)
    if isinstance(a, dict) and isinstance(b, dict):
        # JSON-loaded dicts have string keys ("1"); assembled dicts have int keys
        # (1) - compare keys as strings so 1 == "1".
        a = {str(k): v for k, v in a.items()}
        b = {str(k): v for k, v in b.items()}
        return set(a) == set(b) and all(norm_eq(a[k], b[k]) for k in a)
    if isinstance(a, list) and isinstance(b, list):
        return len(a) == len(b) and all(norm_eq(x, y) for x, y in zip(a, b))
    if isinstance(a, (int, float)) and isinstance(b, (int, float)) and not isinstance(a, (bool,)):
        return abs(a - b) <= 1e-6
    return a == b


def _trigger_entries(trg):
    """[(entry_dict, key), ...], meta - from list or dict triggers."""
    entries, meta = [], {}
    if isinstance(trg, list):
        entries = [v for v in trg if isinstance(v, dict) and "trigger" in v]
    elif isinstance(trg, dict):
        for k, v in trg.items():
            if isinstance(v, dict) and "trigger" in v:
                entries.append(v)
            elif k in ("disjunctive", "activeTriggerMode"):
                meta[k] = v
    return entries, meta


# --------------------------------------------------------------------------- A
def prove_block_losslessness(displays, lib):
    ok = bad = 0
    fails = []

    def check(block_id, original):
        nonlocal ok, bad
        if block_id not in lib:
            return
        fills = {k: original[k] for k in lib[block_id]["holes"] if k in original}
        if norm_eq(reconstruct(block_id, fills, lib), original):
            ok += 1
        else:
            bad += 1
            if len(fails) < 8:
                fails.append(block_id)

    for a in displays.values():
        entries, _ = _trigger_entries(a.get("triggers"))
        for e in entries:
            t = e["trigger"]
            check(f"trigger.{_slug(t.get('type', '?'))}.{_slug(t.get('event', '?'))}",
                  {k: v for k, v in t.items() if k not in ("type", "event")})
        for s in (a.get("subRegions") or []):
            if isinstance(s, dict):
                check(f"subregion.{_slug(s.get('type', '?'))}", {k: v for k, v in s.items() if k != "type"})
    return ok, bad, fails


# --------------------------------------------------------------------------- B/C
def decompose(aura, lib):
    rid = f"region.{_slug(aura.get('regionType', '?'))}"
    region_fields = set(lib[rid]["invariant"]) | lib[rid]["holes"] if rid in lib else set()
    region_fills = {k: aura[k] for k in (lib[rid]["holes"] if rid in lib else ()) if k in aura}
    header = {k: v for k, v in aura.items()
              if k not in region_fields and k not in ("triggers", "conditions", "subRegions", "load")}

    entries, meta = _trigger_entries(aura.get("triggers"))
    triggers = []
    for e in entries:
        t = e["trigger"]
        tid = f"trigger.{_slug(t.get('type', '?'))}.{_slug(t.get('event', '?'))}"
        triggers.append({"id": tid, "type": t.get("type"), "event": t.get("event"),
                         "untrigger": e.get("untrigger", {}),
                         "fills": {k: t[k] for k in lib[tid]["holes"] if k in t} if tid in lib else {}})
    subs = []
    for s in (aura.get("subRegions") or []):
        if isinstance(s, dict):
            sid = f"subregion.{_slug(s.get('type', '?'))}"
            subs.append({"id": sid, "type": s.get("type"),
                         "fills": {k: s[k] for k in lib[sid]["holes"] if k in s} if sid in lib else {}})
    return {"header": header, "region": {"id": rid, "fills": region_fills},
            "triggers": triggers, "trigger_meta": meta, "conditions": aura.get("conditions", []),
            "subregions": subs, "load": aura.get("load", {})}


def assemble(m, lib):
    a = dict(m["header"])
    if m["region"]["id"] in lib:
        a.update(reconstruct(m["region"]["id"], m["region"]["fills"], lib))
    trg = {}
    for i, t in enumerate(m["triggers"], 1):
        block = reconstruct(t["id"], t["fills"], lib) if t["id"] in lib else {}
        if t["type"] is not None:
            block["type"] = t["type"]
        if t["event"] is not None:
            block["event"] = t["event"]
        trg[i] = {"trigger": block, "untrigger": t.get("untrigger", {})}
    trg.update(m["trigger_meta"])
    a["triggers"] = trg
    a["conditions"] = m["conditions"]
    a["subRegions"] = [{**(reconstruct(s["id"], s["fills"], lib) if s["id"] in lib else {}),
                        "type": s["type"]} for s in m["subregions"]]
    a["load"] = m["load"]
    return a


def main():
    displays = json.load(open(CORPUS, encoding="utf-8"))
    lib = load_library(DB)
    print(f"library: {len(lib)} blocks | corpus: {len(displays)} auras\n")

    ok, bad, fails = prove_block_losslessness(displays, lib)
    print(f"== A · block losslessness ==\n  {ok} reconstructed == original, {bad} mismatched"
          f"{'  ' + str(fails) if fails else ''}\n")

    rt_ok, rt_bad, rt_fail = 0, 0, []
    for aid, a in displays.items():
        if norm_eq(assemble(decompose(a, lib), lib), a):
            rt_ok += 1
        else:
            rt_bad += 1
            if len(rt_fail) < 8:
                rt_fail.append(aid)
    print(f"== B · whole-aura round-trip (decompose -> assemble) ==\n"
          f"  {rt_ok}/{len(displays)} exact{'  fails: ' + str(rt_fail) if rt_fail else ''}\n")

    # C - ship: assemble a real aura, encode an import string, decode it back.
    sample = next(n for n, a in displays.items() if a.get("regionType") == "icon")
    rebuilt = assemble(decompose(displays[sample], lib), lib)
    s = wc.encode_import_string(rebuilt)
    back = wc.decode_import_string(s)
    print(f"== C · ship ({sample!r}) ==\n  encoded {len(s)}-char import string; "
          f"decode round-trips: {norm_eq(back, rebuilt)}")
    print(f"  string head: {s[:48]}…")


if __name__ == "__main__":
    main()
