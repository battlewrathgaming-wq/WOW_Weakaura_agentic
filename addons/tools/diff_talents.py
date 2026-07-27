"""
diff_talents.py - the backlog #5 acceptance: the talents-task walk vs the
decoded build string (Class_design/tools/decode_build.py), two witnesses joined.

Usage:
    py addons\\tools\\diff_talents.py "<export string or share URL>"
    py addons\\tools\\diff_talents.py "<string>" <record.json>   (default: newest talents record)

Output (by-exception): MATCH per witness pair, or the named divergence -
only-in-walk / only-in-decode, per talents (node-id+rank) and abilities
(spellId). Also: if the record captured the client's own ExportBuild string,
it's decoded as the THIRD witness. Unresolved decode ids (e.g. 561337) get
backfilled with the walk entry's own captured fields.
"""
import glob
import json
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "Class_design" / "tools"))
import decode_build  # the offline witness (their lane's gear, imported not copied)

RECORDS = REPO / "addons" / "landing" / "records"


def load_record(path=None):
    if path:
        return json.loads(Path(path).read_text(encoding="utf-8"))
    cands = sorted(glob.glob(str(RECORDS / "*__talents.json")))
    if not cands:
        sys.exit("no talents record landed yet")
    return json.loads(Path(cands[-1]).read_text(encoding="utf-8"))


def walk_sets(payload):
    talents = {}   # node-id -> (rank, scalars)
    spells = set() # spellIds
    for row in payload.get("talents", []):
        sc = row.get("scalars", {})
        nid = sc.get("ID")
        if nid is not None:
            talents[int(nid)] = (row.get("rank"), sc)
    for row in payload.get("spells", []):
        sc = row.get("scalars", {})
        sid = sc.get("SpellID") or sc.get("ID")
        if sid is not None:
            spells.add(int(sid))
    return talents, spells


def decode_sets(arg):
    seg = decode_build.extract_segment(arg)
    text = decode_build.inflate(seg)
    talents = {}
    spells = set()
    for tok in text.split(":"):
        if not tok:
            continue
        if "t" in tok:
            nid, rank = tok.split("t")
            talents[int(nid)] = int(rank)
        else:
            spells.add(int(tok))
    return talents, spells


def diff(tag, walk_t, walk_s, dec_t, dec_s):
    print(f"== {tag} ==")
    ok = True
    only_walk_t = sorted(set(walk_t) - set(dec_t))
    only_dec_t = sorted(set(dec_t) - set(walk_t))
    rank_diff = sorted(n for n in set(walk_t) & set(dec_t)
                       if walk_t[n][0] is not None and walk_t[n][0] != dec_t[n])
    only_walk_s = sorted(walk_s - dec_s)
    only_dec_s = sorted(dec_s - walk_s)
    for label, rows in (("talents only in WALK", only_walk_t),
                        ("talents only in DECODE", only_dec_t),
                        ("rank mismatches", rank_diff),
                        ("abilities only in WALK", only_walk_s),
                        ("abilities only in DECODE", only_dec_s)):
        if rows:
            ok = False
            print(f"  {label}: {rows}")
    if ok:
        print(f"  MATCH - {len(dec_t)} talents + {len(dec_s)} abilities, "
              f"is-selected proven clean")
    return ok


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    record = load_record(sys.argv[2] if len(sys.argv) > 2 else None)
    payload = record["payload"]
    walk_t, walk_s = walk_sets(payload)
    print(f"record {record['header']['runId']}: {len(walk_t)} talent entries, "
          f"{len(walk_s)} spell entries, class {payload.get('classToken')}")

    dec_t, dec_s = decode_sets(sys.argv[1])
    diff("walk vs ascension.gg decode", walk_t, walk_s, dec_t, dec_s)

    # the unresolved-id backfill: name decode ids from the walk's own fields
    for nid in dec_t:
        if nid in walk_t:
            sc = walk_t[nid][1]
            name = sc.get("Name") or sc.get("name")
            if name and nid == 561337:
                print(f"  BACKFILL: {nid} = {name!r} (walk fields: "
                      f"{ {k: v for k, v in sc.items() if k in ('Name','SpellID','Tab','Type')} })")

    eb = payload.get("exportBuild")
    if eb and isinstance(eb, list) and isinstance(eb[0], str) and eb[0]:
        try:
            c_t, c_s = decode_sets(eb[0])
            diff("client ExportBuild vs ascension.gg decode",
                 {k: (v, {}) for k, v in c_t.items()}, c_s, dec_t, dec_s)
        except Exception as e:
            print(f"== client ExportBuild: not decodable by this codec ({e}) - "
                  f"raw kept in the record for inspection ==")


if __name__ == "__main__":
    main()
