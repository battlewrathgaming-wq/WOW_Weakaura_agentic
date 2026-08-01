"""read_spell_dbc.py - decode the fork's client Spell.dbc and report shipped
field values for named spells (the changelog-verification instrument).

THE FIELD MAP IS FORK-SPECIFIC and was CALIBRATED EMPIRICALLY (2026-08-01)
against known values from the in-game scrape (dependencies/coa_spells.json):
uniform +2 shift vs stock 3.3.5a. name=136 rank=153 procChance=35
durationIndex=40 powerType=41 manaCostPct=204 maxAffectedTargets=212
effectBonusMultiplier=229-231 (floats).

The tool SELF-VERIFIES the calibration on every run (anchor spells with known
values) and refuses to answer if the anchors fail - a new client patch that
reshapes Spell.dbc makes this loud, never silently wrong.

Spell.dbc lives in patch-T.MPQ, SpellDuration.dbc in patch-S.MPQ (as of
2026-08-01; the archive scan below re-finds them if they move).

Usage:
    py addons\\tools\\read_spell_dbc.py "Venom Bolt" "Spore" ...
"""
import struct
import sys
from pathlib import Path

import mpyq

DATA = Path(r"F:\games\Ascension_wow\resources\ascension-live\Data")

F_NAME, F_RANK, F_PROC, F_DURIDX, F_POWER, F_MCP, F_MAXTGT = 136, 153, 35, 40, 41, 204, 212
F_MULT = (229, 230, 231)
NFIELDS = 234

# calibration anchors: (name, rank, field, expected) - from coa_spells.json
ANCHORS = [
    ("Raise: Greater Skeletal Warrior", "Rank 2", F_MCP, 38),
    ("Raise: Lesser Skeletal Warrior", "Rank 1", F_MCP, 32),
]


def find_archive(filename):
    for p in sorted(DATA.glob("*.MPQ")) + sorted(DATA.glob("*.mpq")):
        try:
            a = mpyq.MPQArchive(str(p), listfile=True)
            for f in a.files or []:
                if f.lower() == filename.lower().encode():
                    return a
        except Exception:
            continue
    raise SystemExit(f"no archive carries {filename}")


def load():
    a = find_archive("DBFilesClient\\Spell.dbc")
    data = a.read_file("DBFilesClient\\Spell.dbc")
    _, recs, fields, recsize, _ = struct.unpack("<4sIIII", data[:20])
    if fields != NFIELDS:
        raise SystemExit(f"Spell.dbc now has {fields} fields (map assumes {NFIELDS}) - RECALIBRATE")
    strings = data[20 + recs * recsize:]

    ad = find_archive("DBFilesClient\\SpellDuration.dbc")
    dd = ad.read_file("DBFilesClient\\SpellDuration.dbc")
    _, drecs, dfields, drecsize, _ = struct.unpack("<4sIIII", dd[:20])
    durations = {}
    for i in range(drecs):
        v = struct.unpack_from(f"<{dfields}i", dd, 20 + i * drecsize)
        durations[v[0]] = v[1]
    return data, recs, recsize, strings, durations


def sread(strings, off):
    end = strings.find(b"\0", off)
    return strings[off:end].decode("utf-8", "replace")


def rows_by_name(data, recs, recsize, strings, wanted_lower):
    cache = {}
    for i in range(recs):
        u = struct.unpack_from(f"<{NFIELDS}I", data, 20 + i * recsize)
        no = u[F_NAME]
        nm = cache.get(no)
        if nm is None:
            nm = sread(strings, no).lower()
            cache[no] = nm
        if nm in wanted_lower:
            f = struct.unpack_from(f"<{NFIELDS}f", data, 20 + i * recsize)
            yield u, f


def main():
    names = sys.argv[1:]
    if not names:
        print(__doc__)
        return
    data, recs, recsize, strings, durations = load()

    # anchors first - refuse to answer on a drifted map
    anchor_want = {a[0].lower() for a in ANCHORS}
    seen = {}
    for u, _ in rows_by_name(data, recs, recsize, strings, anchor_want):
        seen[(sread(strings, u[F_NAME]), sread(strings, u[F_RANK]))] = u
    for (nm, rk, fi, expect) in ANCHORS:
        u = seen.get((nm, rk))
        assert u and u[fi] == expect, (
            f"CALIBRATION ANCHOR FAILED: {nm} {rk} field {fi} != {expect} - "
            f"the field map has drifted; recalibrate before trusting ANY output")
    print(f"(calibration anchors verified: {len(ANCHORS)})\n")

    want = {n.lower() for n in names}
    out = []
    for u, f in rows_by_name(data, recs, recsize, strings, want):
        out.append((sread(strings, u[F_NAME]), u[0], sread(strings, u[F_RANK]),
                    u[F_MCP], u[F_PROC], u[F_MAXTGT],
                    durations.get(u[F_DURIDX], 0) if u[F_DURIDX] else 0,
                    [round(f[i], 3) for i in F_MULT]))
    out.sort()
    cur = None
    for (name, sid, rank, mcp, proc, mt, dms, bm) in out:
        if name != cur:
            cur = name
            print(f"== {name} ==")
        print(f"  id {sid:>6} rank {rank!r:16} mana%={mcp:>3} proc%={proc:>3} "
              f"maxTgt={mt:>3} dur={dms}ms mult={bm}")
    print(f"\nrows: {len(out)}")


if __name__ == "__main__":
    main()
