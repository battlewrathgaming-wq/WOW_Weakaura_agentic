"""crypt_analyze.py - aggregate a CHANNELED spell (Crypt Swarm) from a combat log.

Companion to parse_combatlog.py (which handles DoT/periodic abilities). Crypt
Swarm (501886) channel: damage ticks = SPELL_DAMAGE id 800343; Runic Power =
SPELL_ENERGIZE id 800344 (amount, powerType 6); channel window =
SPELL_AURA_APPLIED/REMOVED 501886. A few damage ticks trail just past the
channel end, so we AGGREGATE across all casts in the file (one condition) and
divide by cast count -> per-cast output. Compare a baseline file vs a +haste
file. Reason on the landing, never on the raw lines.

Validated 2026-07-27 on the two 3-cast Crypt Swarm logs (baseline vs +5 archers):
ticks identical (haste adds none), output flat within RNG, channel ~2% longer.

Run:  py crypt_analyze.py "<path to ... WoWCombatLog.txt>" --player Gravekeeper
"""
import csv, io, argparse
from datetime import datetime

TS_SPLIT = "  "


def pts(ts, y):
    try:
        return datetime.strptime(f"{y}/{ts}", "%Y/%m/%d %H:%M:%S.%f")
    except ValueError:
        return None


def parse_line(line, y):
    line = line.rstrip("\r\n")
    if TS_SPLIT not in line:
        return None
    ts, pl = line.split(TS_SPLIT, 1)
    try:
        row = next(csv.reader(io.StringIO(pl)))
    except StopIteration:
        return None
    if not row:
        return None
    sub = row[0]
    e = {"ts": ts, "time": pts(ts, y), "sub": sub}
    if len(row) >= 7:
        e.update(srcName=row[2], dstName=row[5])
    if sub.startswith(("SPELL_", "RANGE_")) and len(row) >= 10:
        e.update(spellId=row[7], spellName=row[8], suffix=row[10:])
    else:
        e.update(spellId=None, spellName=None, suffix=row[7:] if len(row) > 7 else [])
    return e


def amt(e):
    try:
        return int(e["suffix"][0])
    except (ValueError, IndexError):
        return 0


ap = argparse.ArgumentParser()
ap.add_argument("logfile")
ap.add_argument("--player", required=True)
ap.add_argument("--spell", default="Crypt Swarm")
ap.add_argument("--year", type=int, default=2026)
a = ap.parse_args()

ev = []
with open(a.logfile, encoding="utf-8", errors="replace") as fh:
    for line in fh:
        e = parse_line(line, a.year)
        if e:
            ev.append(e)

mine = [e for e in ev if e.get("srcName") == a.player and e.get("spellName") == a.spell]
casts = [e for e in mine if e["sub"] == "SPELL_CAST_SUCCESS"]
dmg = [e for e in mine if e["sub"] in ("SPELL_DAMAGE", "SPELL_PERIODIC_DAMAGE")]
enr = [e for e in mine if e["sub"] in ("SPELL_ENERGIZE", "SPELL_PERIODIC_ENERGIZE")]
dmg_total = sum(amt(e) for e in dmg)
rp_total = sum(amt(e) for e in enr)

wins, start = [], None
for e in mine:
    if e["sub"] == "SPELL_AURA_APPLIED":
        start = e["time"]
    elif e["sub"] == "SPELL_AURA_REMOVED" and start:
        wins.append((e["time"] - start).total_seconds())
        start = None

nc = len(casts) or 1
print(f"=== {a.logfile}")
print(f"casts                : {len(casts)}")
if wins:
    print(f"channel durations    : {[round(w, 3) for w in wins]}  (avg {sum(wins) / len(wins):.3f}s)")
print(f"damage ticks (800343): {len(dmg):>3}  total {dmg_total:>5}   -> per cast: {len(dmg) / nc:.2f} ticks, {dmg_total / nc:.0f} dmg")
print(f"RP energizes (800344): {len(enr):>3}  total {rp_total:>5}   -> per cast: {len(enr) / nc:.2f} ticks, {rp_total / nc:.1f} RP")
