"""
diff_talents.py - the talents-walk vs build-string diff, rank-aware, exposing
OUTLIERS AS SELECTION TARGETS (Battlewrath: "it gives me a target to select for").

Usage:
    py addons\\tools\\diff_talents.py "<export string or share URL>" [record.json]

Joins:
  talents  : node-id + rank (walk) vs id+tN tokens (decode)
  abilities: walk entry-id -> rank-1 spellId via Input/<class>_talents.json,
             vs plain decode tokens. Decode lists EACH RANK as its own spellId
             (proven: Soul Warden 560419 rank1 + 561337 rank2), so leftover
             decode tokens are attributed against matched nodes' unconsumed
             rank slots (maxPoints from the snapshot) before being called
             targets. Exact per-rank join arrives with the task's Spells-array
             capture (v2).

Output sections:
  MATCHED / ATTRIBUTED (extra-rank tokens) / TARGETS (planned-not-known -
  what to select next) / KNOWN-NOT-PLANNED (walk-only).

Grain: spec-GRANTED abilities (e.g. Reaper Dreadwake 803992 / advancement
30720, granted on spec pick) appear in NEITHER witness - they are outside the
build contract by nature, not a divergence.
"""
import glob
import json
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "Class_design" / "tools"))
import decode_build  # noqa: E402

RECORDS = REPO / "addons" / "landing" / "records"


def load_record(path=None):
    if path:
        return json.loads(Path(path).read_text(encoding="utf-8"))
    cands = sorted(glob.glob(str(RECORDS / "*__talents.json")))
    if not cands:
        sys.exit("no talents record landed yet")
    return json.loads(Path(cands[-1]).read_text(encoding="utf-8"))


def snapshot(class_token):
    # class token -> Input file; fall back to scanning all
    files = glob.glob(str(REPO / "Input" / "*_talents.json"))
    rows = []
    for f in files:
        d = json.loads(Path(f).read_text(encoding="utf-8"))
        rows += d if isinstance(d, list) else d.get("talents", d.get("nodes", []))
    return {e["id"]: e for e in rows if isinstance(e, dict) and e.get("id") is not None}


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    record = load_record(sys.argv[2] if len(sys.argv) > 2 else None)
    p = record["payload"]
    snap = snapshot(p.get("classToken"))

    # decode side
    seg = decode_build.extract_segment(sys.argv[1])
    text = decode_build.inflate(seg)
    dec_talents, dec_spells = {}, set()
    for tok in text.split(":"):
        if not tok:
            continue
        if "t" in tok:
            nid, rank = tok.split("t")
            dec_talents[int(nid)] = int(rank)
        else:
            dec_spells.add(int(tok))

    # walk side
    walk_talents = {}
    for row in p.get("talents", []):
        sc = row.get("scalars", {})
        if sc.get("ID") is not None:
            walk_talents[int(sc["ID"])] = (row.get("rank"), sc.get("Name"))
    walk_nodes = {}   # ability entry-id -> (rank1 spellId via snapshot, name, maxPoints, spells[] if captured)
    for row in p.get("spells", []):
        sc = row.get("scalars", {})
        nid = sc.get("ID")
        if nid is None:
            continue
        e = snap.get(int(nid), {})
        spells = row.get("arrays", {}).get("Spells") if row.get("arrays") else None
        walk_nodes[int(nid)] = {
            "spellId": e.get("spellId"), "name": sc.get("Name") or e.get("name"),
            "maxPoints": e.get("maxPoints") or 1, "spells": spells,
            "rank": row.get("rank"),
        }

    print(f"record {record['header']['runId']} ({p.get('classToken')}): "
          f"{len(walk_talents)} talents, {len(walk_nodes)} ability nodes | "
          f"decode: {len(dec_talents)} talents, {len(dec_spells)} ability tokens")

    # ---- talents ----
    t_only_walk = sorted(set(walk_talents) - set(dec_talents))
    t_only_dec = sorted(set(dec_talents) - set(walk_talents))
    t_rank = [(n, walk_talents[n][0], dec_talents[n], walk_talents[n][1])
              for n in set(walk_talents) & set(dec_talents)
              if walk_talents[n][0] is not None and walk_talents[n][0] != dec_talents[n]]

    # ---- abilities: join + rank attribution ----
    matched, remaining = {}, set(dec_spells)
    for nid, info in walk_nodes.items():
        # exact join if the walk captured the Spells rank array (task v2)
        hit = None
        if info["spells"]:
            hit = [s for s in info["spells"] if s in remaining]
        elif info["spellId"] in remaining:
            hit = [info["spellId"]]
        if hit:
            for s in hit:
                remaining.discard(s)
            matched[nid] = (info["name"], hit)
    # attribute leftovers to unconsumed rank slots of matched multi-rank nodes
    slots = sum(max(0, (walk_nodes[n]["maxPoints"] or 1) - len(matched[n][1]))
                for n in matched)
    attributed = []
    if remaining and slots >= len(remaining):
        attributed = sorted(remaining)
        remaining = set()

    unjoined_walk = sorted(n for n in walk_nodes if n not in matched)

    print("== talents ==")
    if not (t_only_walk or t_only_dec or t_rank):
        print(f"  MATCH ({len(dec_talents)} nodes)")
    else:
        if t_only_walk: print(f"  known-not-planned: {t_only_walk}")
        if t_only_dec: print(f"  TARGETS (planned-not-known): "
                             f"{[(n, 'rank ' + str(dec_talents[n])) for n in t_only_dec]}")
        if t_rank:
            for n, wr, dr, name in t_rank:
                print(f"  rank differs: node {n} ({name}): known rank {wr}, planned rank {dr}"
                      + ("  -> TARGET: take it to rank " + str(dr) if (dr or 0) > (wr or 0) else ""))

    print("== abilities ==")
    print(f"  matched nodes: {len(matched)}/{len(walk_nodes)}")
    if attributed:
        print(f"  attributed to extra ranks of matched multi-rank nodes: {attributed} "
              f"({slots} unconsumed rank slots available)")
    if remaining:
        named = []
        for s in sorted(remaining):
            owner = [i for i in snap.values() if i.get("spellId") == s]
            named.append((s, owner[0]["name"] if owner else "UNRESOLVED"))
        print(f"  TARGETS (planned-not-known): {named}")
    if unjoined_walk:
        print(f"  known-not-planned (walk-only nodes): "
              f"{[(n, walk_nodes[n]['name']) for n in unjoined_walk]}")
    if not remaining and not unjoined_walk and not t_only_dec and not t_rank:
        print("  BUILD COMPLETE vs plan - no targets outstanding")


if __name__ == "__main__":
    main()
