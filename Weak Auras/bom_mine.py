"""
bom_mine.py - mine recurring block-stack patterns (BOMs) from the corpus.

A BOM = a named, recurring composition of Layer-0 blocks — a Layer-1 *meaning*
("cooldown tracker", "buff uptime"), read out of what actually recurs rather
than invented. This is the read-intent -> formalize move, applied to
composition. Populates blocks.db's bom / bom_block (ready-empty until now).

Signature = region + the sorted set of trigger/subregion/condition block-IDs
(fills ignored — the pattern is *which blocks*, not their values). Base vs
extension falls out of the subset lattice: if pattern A's blocks are a subset of
B's, B is A + extension.

The corpus is single-version / back-port-clean (routed in-game-import ->
SavedVariables -> corpus, so WA's own import gate already sanitized it), so no
version poisoning here; that gate is only for direct wago ingestion.

    py bom_mine.py
"""
import json
import os
import re
import sqlite3

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.dirname(_THIS)
CORPUS = os.path.join(_ROOT, "Outputs", "aura_corpus", "battlewrath_displays.json")
DB = os.path.join(_ROOT, "Outputs", "aura_corpus", "blocks.db")


def _slug(s):
    return re.sub(r"[^a-z0-9]+", "_", str(s).lower()).strip("_")


def _triggers(a):
    trg = a.get("triggers")
    out = []
    if isinstance(trg, list):
        out = [v["trigger"] for v in trg if isinstance(v, dict) and "trigger" in v]
    elif isinstance(trg, dict):
        out = [v["trigger"] for v in trg.values() if isinstance(v, dict) and "trigger" in v]
    return out


def blocks_of(a):
    region = f"region.{_slug(a.get('regionType', '?'))}"
    trigs = sorted(f"trigger.{_slug(t.get('type', '?'))}.{_slug(t.get('event', '?'))}" for t in _triggers(a))
    subs = sorted(f"subregion.{_slug(s.get('type', '?'))}" for s in (a.get("subRegions") or []) if isinstance(s, dict))
    conds = sorted({f"condition.{_slug(ch['property'])}"
                    for c in (a.get("conditions") or []) if isinstance(c, dict)
                    for ch in (c.get("changes") or []) if isinstance(ch, dict) and ch.get("property")})
    return region, trigs, subs, conds


def main():
    displays = json.load(open(CORPUS, encoding="utf-8"))

    sigs = {}          # signature tuple -> [aura ids]
    content = {}       # signature -> frozenset of non-region blocks
    region_of = {}
    versions = set()
    for aid, a in displays.items():
        versions.add(a.get("internalVersion"))
        region, trigs, subs, conds = blocks_of(a)
        sig = (region, tuple(trigs), tuple(subs), tuple(conds))
        sigs.setdefault(sig, []).append(aid)
        content[sig] = frozenset(trigs) | frozenset(subs) | frozenset(conds)
        region_of[sig] = region

    print(f"corpus: {len(displays)} auras, internalVersion(s) present: {sorted(v for v in versions if v is not None)}")
    print(f"distinct block-stack patterns: {len(sigs)}\n")

    # base/extension lattice: for each sig, its base = largest OTHER sig (same
    # region) whose content is a proper subset.
    base_of = {}
    for sig in sigs:
        cand = [s for s in sigs if s != sig and region_of[s] == region_of[sig]
                and content[s] < content[sig]]
        base_of[sig] = max(cand, key=lambda s: len(content[s])) if cand else None

    print("== discovered BOMs (by frequency) ==")
    ordered = sorted(sigs, key=lambda s: (-len(sigs[s]), region_of[s]))
    for sig in ordered:
        region, trigs, subs, conds = sig
        n = len(sigs[sig])
        base = base_of[sig]
        ext = sorted(content[sig] - content[base]) if base else None
        parts = [region.split(".", 1)[1]]
        if trigs:
            parts.append("T:" + ",".join(t.split(".", 2)[-1][:10] for t in trigs))
        if subs:
            parts.append("S:" + ",".join(s.split(".")[-1].replace("sub", "") for s in subs))
        if conds:
            parts.append("C:" + ",".join(c.split(".")[-1][:8] for c in conds))
        tag = f"  extends «{region_of[base].split('.')[-1]}+{len(content[base])}» +{ext}" if base else ""
        print(f"  x{n:<2} {' | '.join(parts)}{tag}")
        print(f"        e.g. {sigs[sig][0]!r}")

    # populate bom / bom_block
    con = sqlite3.connect(DB)
    con.execute("DELETE FROM bom_block")
    con.execute("DELETE FROM bom")
    for i, sig in enumerate(ordered, 1):
        region, trigs, subs, conds = sig
        bom_id = f"bom_{i:02d}_{region.split('.')[-1]}"
        con.execute("INSERT INTO bom VALUES (?,?,?)",
                    (bom_id, f"{region.split('.')[-1]} pattern (x{len(sigs[sig])})",
                     f"blocks: {region}, {list(content[sig])}"))
        base = base_of[sig]
        base_blocks = content[base] if base else frozenset()
        slot = 0
        for blk in [region] + list(trigs) + list(subs) + list(conds):
            op = "extension" if (blk in content[sig] and blk not in base_blocks and base) else "base"
            con.execute("INSERT INTO bom_block VALUES (?,?,?,?,?)", (bom_id, blk, slot, op, None))
            slot += 1
    con.commit()
    nb, nbb = con.execute("SELECT COUNT(*) FROM bom").fetchone()[0], con.execute("SELECT COUNT(*) FROM bom_block").fetchone()[0]
    con.close()
    print(f"\nwrote {nb} bom + {nbb} bom_block rows to blocks.db")


if __name__ == "__main__":
    main()
