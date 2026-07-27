"""parse_combatlog.py - mechanical extractor for the Harvest Plague x Haste test.

Reads a WoW 3.3.5 (Ascension/CoA) combat log, filters to one caster + one
spell (matched by NAME - live cast ids differ from the DBC ranks), and lands a
per-application table: tick count, per-tick timeline (offset + interval),
summons (with the tick they fired on), self-heal, aura duration. Reason on the
landing (this table), never on the raw lines.

Validated 2026-07-27 across three logs: the miss-sample (structure/filter/
name-match/miss-handling), the baseline (tick+summon bucketing on a landing
DoT), and the haste run (the A/B). Log line format seen live:
  "M/D HH:MM:SS.mmm" + TWO SPACES + comma-CSV; timestamps are ms-precision;
  no year (comes from the datetime-stamped filename). Field order is standard
  3.3.5 CLEU (see Weak Auras/COMBAT_LOG_CAPABILITIES.md).

Run:  py parse_combatlog.py "<path to ... WoWCombatLog.txt>" --player Gravekeeper
"""
import csv, io, argparse
from collections import Counter

TS_SPLIT = "  "  # two spaces between timestamp and CSV payload


def parse_ts(ts_str, year):
    from datetime import datetime
    try:
        return datetime.strptime(f"{year}/{ts_str}", "%Y/%m/%d %H:%M:%S.%f")
    except ValueError:
        return None


def parse_line(line, year):
    line = line.rstrip("\r\n")
    if TS_SPLIT not in line:
        return None
    ts_str, payload = line.split(TS_SPLIT, 1)
    try:
        row = next(csv.reader(io.StringIO(payload)))
    except StopIteration:
        return None
    if not row:
        return None
    sub = row[0]
    e = {"ts": ts_str, "time": parse_ts(ts_str, year), "sub": sub}
    if len(row) >= 7:
        e.update(srcGUID=row[1], srcName=row[2], srcFlags=row[3],
                 dstGUID=row[4], dstName=row[5], dstFlags=row[6])
    if sub.startswith(("SPELL_", "RANGE_")) and len(row) >= 10:
        e.update(spellId=row[7], spellName=row[8], spellSchool=row[9], suffix=row[10:])
    else:
        e.update(spellId=None, spellName=None, spellSchool=None,
                 suffix=row[7:] if len(row) > 7 else [])
    return e


def secs(a, b):
    return (a - b).total_seconds() if a and b else None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("logfile")
    ap.add_argument("--player", required=True, help="caster name (source filter)")
    ap.add_argument("--spell", default="Harvest Plague", help="DoT spell name to bucket")
    ap.add_argument("--year", type=int, default=2026)
    a = ap.parse_args()

    events = []
    with open(a.logfile, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            e = parse_line(line, a.year)
            if e:
                events.append(e)

    print(f"=== {a.logfile}")
    print(f"lines parsed   : {len(events)}")
    print(f"subevent tally : {dict(Counter(e['sub'] for e in events))}")

    mine = [e for e in events if e.get("srcName") == a.player]
    print(f"\n{a.player} source events: {len(mine)}"
          f"  (casts={sum(1 for e in mine if e['sub']=='SPELL_CAST_SUCCESS')}"
          f", summons={sum(1 for e in mine if e['sub']=='SPELL_SUMMON')})")

    # per-application windows
    windows, cur = [], None
    for e in mine:
        sub, name = e["sub"], e.get("spellName")
        if sub == "SPELL_AURA_APPLIED" and name == a.spell:
            cur = {"start": e["time"], "dst": e.get("dstName"),
                   "ticks": [], "summons": [], "heals": 0, "end": None}
            windows.append(cur)
        elif sub == "SPELL_PERIODIC_DAMAGE" and name == a.spell and cur is not None:
            cur["ticks"].append(e["time"])
        elif sub == "SPELL_HEAL" and name == a.spell and cur is not None:
            cur["heals"] += 1
        elif sub == "SPELL_SUMMON" and cur is not None:
            cur["summons"].append(e["time"])
        elif sub == "SPELL_AURA_REMOVED" and name == a.spell and cur is not None:
            cur["end"] = e["time"]
            cur = None

    print(f"\n=== {a.spell} applications  (the metric for the haste A/B) ===")
    if not windows:
        print("  (no landed applications - e.g. the cast MISSED)")
    for i, w in enumerate(windows, 1):
        ticks = w["ticks"]
        n = len(ticks)
        dur = secs(w["end"], w["start"])
        span = secs(ticks[-1], ticks[0]) if n >= 2 else None
        avg = f"{span / (n - 1):.3f}s" if span else "n/a"
        print(f"\n  #{i} on {w['dst']!r}: ticks={n}  summons={len(w['summons'])}"
              f"  self-heals={w['heals']}  aura_dur={dur}s  tick_span={span}s  avg_interval={avg}")
        prev = None
        for k, t in enumerate(ticks, 1):
            off = secs(t, w["start"])
            d = secs(t, prev)
            fired = any(s and t and abs(secs(s, t)) < 0.15 for s in w["summons"])
            print(f"     tick {k:>2}  t+{off:>6.3f}s   dt={('%.3f' % d) if d is not None else '  -  '}"
                  f"   {'+SUMMON' if fired else ''}")
            prev = t


if __name__ == "__main__":
    main()
