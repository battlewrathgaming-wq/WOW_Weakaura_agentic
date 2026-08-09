#!/usr/bin/env python
"""
graveyard_observe.py -- characterize Necromancer's Graveyard (805197) from a combat log.

Graveyard is DBC-absent on this fork (checked 2026-08-09: 805197 appears nowhere in
coa_spells.json / talents), so its behaviour is known ONLY by observation. This gear
extracts the whole lifecycle from a /combatlog capture:

  - the cast (805197)                    -> t0, caster
  - Tombstones summoned                  -> the zone structures
  - enemy debuff (805197) apply..remove  -> zone duration
  - pulses: Risen Ghoul summons          -> cadence + count/pulse
  - Risen Ghoul UNIT_DIED                -> corpse creation (rise-and-die)
  - corpse lifespan (summon -> death)
  - Corpse Explosion 533239 cast:
        SPELL_CAST_SUCCESS + 533240 AoE  -> a consume (corpses present)
        SPELL_CAST_FAILED "..."          -> the expiry marker (no corpses)
    ...and, relative to the last pulse, whether corpses were ALIVE or GONE at that time.

Usage:  py graveyard_observe.py "<log path>" [--player <Name>]

The STRUCTURE (5x5 layout, ~5s cadence, counts, ~20s zone) is the ability; damage
magnitudes are gear/level-scaled to the captured character.
"""
import sys, csv, argparse

GRAVEYARD = "805197"   # cast + enemy debuff
CE_CAST   = "533239"   # Corpse Explosion cast
CE_DMG    = "533240"   # Corpse Explosion per-corpse AoE damage


def parse_time(tod):            # "HH:MM:SS.mmm" -> seconds since midnight
    hh, mm, rest = tod.split(":")
    ss, ms = rest.split(".")
    return int(hh) * 3600 + int(mm) * 60 + int(ss) + int(ms) / 1000.0


def read_events(path):
    out = []
    with open(path, encoding="utf-8", errors="replace") as f:
        for line in f:
            line = line.rstrip("\n")
            if "  " not in line:
                continue
            stamp, rest = line.split("  ", 1)          # ts is delimited by TWO spaces
            bits = stamp.split(" ", 1)
            if len(bits) != 2:
                continue
            try:
                t = parse_time(bits[1])
            except ValueError:
                continue
            row = next(csv.reader([rest]), None)
            if row:
                out.append((t, row))
    return out


def field(r, i):
    return r[i] if len(r) > i else ""


def cluster(times, gap=1.0):
    groups = []
    for t in sorted(times):
        if groups and t - groups[-1][-1] <= gap:
            groups[-1].append(t)
        else:
            groups.append([t])
    return groups


def rel(t, t0):
    return f"+{t - t0:6.2f}s"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("log")
    ap.add_argument("--player", default=None)
    a = ap.parse_args()
    ev = read_events(a.log)

    cast = next(((t, r) for t, r in ev
                 if field(r, 0) == "SPELL_CAST_SUCCESS" and field(r, 7) == GRAVEYARD), None)
    if not cast:
        print("No Graveyard (805197) cast in this log.")
        return
    t0, cr = cast
    caster = a.player or field(cr, 2)
    print(f"== Graveyard ({GRAVEYARD}) cast by {caster!r} at t0 ==")

    tombs = [r for t, r in ev if field(r, 0) == "SPELL_SUMMON"
             and field(r, 2) == caster and field(r, 5) == "Tombstone"]
    print(f"Tombstones summoned : {len(tombs)}")

    applied = [t for t, r in ev if field(r, 0) == "SPELL_AURA_APPLIED" and field(r, 7) == GRAVEYARD]
    removed = [t for t, r in ev if field(r, 0) == "SPELL_AURA_REMOVED" and field(r, 7) == GRAVEYARD]
    if applied and removed:
        print(f"Zone debuff (805197): {rel(min(applied), t0)} .. {rel(max(removed), t0)}"
              f"  =>  {max(removed) - t0:.2f}s")

    gs = [(t, r) for t, r in ev if field(r, 0) == "SPELL_SUMMON" and field(r, 5) == "Risen Ghoul"]
    gd = [(t, r) for t, r in ev if field(r, 0) == "UNIT_DIED"   and field(r, 5) == "Risen Ghoul"]
    pulses = cluster([t for t, _ in gs])
    print(f"\nPulses (Risen Ghoul summons): {len(pulses)}")
    prev = None
    for i, g in enumerate(pulses, 1):
        gap = f"  (+{g[0] - prev:.2f}s)" if prev is not None else ""
        print(f"  pulse {i}: {rel(g[0], t0)}  x{len(g)}{gap}")
        prev = g[0]
    print(f"Corpses: {len(gs)} summoned = {len(gd)} died")

    born = {field(r, 4): t for t, r in gs}
    lifes = [dt - born[g] for g, dt in ((field(r, 4), t) for t, r in gd) if g in born]
    if lifes:
        print(f"Corpse lifespan (rise->death): avg {sum(lifes)/len(lifes):.2f}s "
              f"(min {min(lifes):.2f}, max {max(lifes):.2f})")

    last_pulse = pulses[-1][0] if pulses else t0
    print("\nCorpse Explosion (533239 / 533240):")
    saw = False
    for t, r in ev:
        if field(r, 0) == "SPELL_CAST_SUCCESS" and field(r, 7) == CE_CAST:
            saw = True
            hits = sum(1 for tt, rr in ev if field(rr, 0) == "SPELL_DAMAGE"
                       and field(rr, 7) == CE_DMG and 0 <= tt - t <= 1.0)
            print(f"  CONSUME {rel(t, t0)}: {hits} AoE hits (>= corpses; AoE overlaps targets)"
                  f"  -> corpses ALIVE at +{t - last_pulse:.2f}s after last pulse")
        elif field(r, 0) == "SPELL_CAST_FAILED" and field(r, 7) == CE_CAST:
            saw = True
            print(f"  FAILED  {rel(t, t0)}: {field(r, -1)!r}"
                  f"  -> corpses GONE by +{t - last_pulse:.2f}s after last pulse")
    if not saw:
        print("  (none in this log)")


if __name__ == "__main__":
    main()
