"""
blocks_db.py - build the Layer-0 block LIBRARY as a SQLite parts catalog.

Scope (settled with Battlewrath): AGNOSTIC of actual aura instances. It houses
the reusable code snippets keyed by a stable constant block-ID; aura instances
stay in the corpus JSON (for mining). An aura is DERIVED at assembly, not
stored: pull snippets by key ID, mint a run-unique string per pulled block
(WA's uid), fill the option-holes from a header, allocate WA indices, ship.

Each block's invariant code vs its holes is DERIVED by diffing every instance of
that block in the corpus: fields constant across all instances = the invariant
code ("the trigger-for-a-spell taking options 1-5 is always the same"); fields
that vary = holes (where options / run-unique IDs go).

Tables:
  block(block_id PK, kind, code_template JSON, holes JSON, usage_count)
  bom(bom_id PK, name, description)                       -- pattern index, empty until mined
  bom_block(bom_id, block_id, slot_index, operator, variant)   -- ready-empty

Read-only against the corpus. Writes Outputs/aura_corpus/blocks.db (regenerable).
    py blocks_db.py
"""
import json
import os
import re
import sqlite3
import sys

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
_PROJECT_ROOT = os.path.dirname(_THIS_DIR)
CORPUS = os.path.join(_PROJECT_ROOT, "Outputs", "aura_corpus", "battlewrath_displays.json")
DB = os.path.join(_PROJECT_ROOT, "Outputs", "aura_corpus", "blocks.db")

# region-level fields that are envelope/container, not part of the region block's code
REGION_EXCLUDE = {"triggers", "conditions", "subRegions", "load", "controlledChildren",
                  "id", "uid", "parent", "internalVersion", "tocversion", "authorOptions",
                  "config", "information", "xOffset", "yOffset", "anchorPoint", "selfPoint",
                  "anchorFrameType", "anchorFrameFrame", "frameStrata"}
_MISSING = object()


def _slug(s):
    return re.sub(r"[^a-z0-9]+", "_", str(s).lower()).strip("_")


def _trigger_slots(trg):
    slots = []
    if isinstance(trg, list):
        for v in trg:
            if isinstance(v, dict) and "trigger" in v:
                slots.append(v["trigger"])
    elif isinstance(trg, dict):
        for k, v in trg.items():
            if isinstance(v, dict) and "trigger" in v:
                slots.append(v["trigger"])
    return slots


def collect_instances(displays):
    """block_id -> (kind, [instance dict, ...]) across the whole corpus."""
    inst = {}

    def add(bid, kind, d):
        e = inst.setdefault(bid, {"kind": kind, "instances": []})
        e["instances"].append(d)

    for a in displays.values():
        add(f"region.{_slug(a.get('regionType', '?'))}", "region",
            {k: v for k, v in a.items() if k not in REGION_EXCLUDE})
        for t in _trigger_slots(a.get("triggers")):
            add(f"trigger.{_slug(t.get('type', '?'))}.{_slug(t.get('event', '?'))}", "trigger",
                {k: v for k, v in t.items() if k not in ("type", "event")})
        for s in (a.get("subRegions") or []):
            if isinstance(s, dict):
                add(f"subregion.{_slug(s.get('type', '?'))}", "subregion",
                    {k: v for k, v in s.items() if k != "type"})
        for c in (a.get("conditions") or []):
            if not isinstance(c, dict):
                continue
            for ch in (c.get("changes") or []):
                if isinstance(ch, dict) and ch.get("property"):
                    add(f"condition.{_slug(ch['property'])}", "condition", c)
        load = a.get("load") or {}
        for key, val in load.items():
            if not key.startswith("use_"):
                add(f"load.{_slug(key)}", "load", {key: val})
    return inst


def diff_invariant(instances):
    """Fields equal across ALL instances = invariant code; the rest = holes."""
    all_keys = set().union(*(set(d.keys()) for d in instances)) if instances else set()
    invariant, holes = {}, []
    for k in sorted(all_keys):
        vals = [d.get(k, _MISSING) for d in instances]
        if vals[0] is not _MISSING and all(v == vals[0] for v in vals[1:]):
            invariant[k] = vals[0]
        else:
            holes.append(k)
    return invariant, holes


def build():
    displays = json.load(open(CORPUS, encoding="utf-8"))
    inst = collect_instances(displays)

    if os.path.exists(DB):
        os.remove(DB)
    con = sqlite3.connect(DB)
    con.executescript("""
        CREATE TABLE block (
            block_id TEXT PRIMARY KEY, kind TEXT NOT NULL,
            code_template TEXT NOT NULL, holes TEXT NOT NULL, usage_count INTEGER NOT NULL);
        CREATE TABLE bom (bom_id TEXT PRIMARY KEY, name TEXT, description TEXT);
        CREATE TABLE bom_block (
            bom_id TEXT NOT NULL REFERENCES bom(bom_id),
            block_id TEXT NOT NULL REFERENCES block(block_id),
            slot_index INTEGER NOT NULL, operator TEXT NOT NULL, variant TEXT);
        CREATE INDEX ix_block_kind ON block(kind);
    """)
    rows = []
    for bid, e in sorted(inst.items()):
        invariant, holes = diff_invariant(e["instances"])
        rows.append((bid, e["kind"], json.dumps(invariant, ensure_ascii=False),
                     json.dumps(holes, ensure_ascii=False), len(e["instances"])))
    con.executemany("INSERT INTO block VALUES (?,?,?,?,?)", rows)
    con.commit()

    print(f"built {DB}")
    for kind, n in con.execute("SELECT kind, COUNT(*) FROM block GROUP BY kind ORDER BY 1"):
        print(f"  {kind:10s} {n} blocks")
    print(f"  bom / bom_block: ready-empty (pattern index; mining fills later)\n")
    print("sample blocks (invariant field count vs holes):")
    for bid, kind, ct, hl, n in con.execute(
            "SELECT block_id,kind,code_template,holes,usage_count FROM block "
            "WHERE kind IN ('trigger','subregion') ORDER BY usage_count DESC LIMIT 6"):
        inv = json.loads(ct); holes = json.loads(hl)
        print(f"  {bid:34s} x{n:<3} invariant:{len(inv)} holes:{holes[:6]}")
    con.close()


if __name__ == "__main__":
    if not os.path.exists(CORPUS):
        raise SystemExit(f"corpus not found: {CORPUS} (run aura_scrape.py first)")
    build()
