# Graveyard (805197) — observed behaviour

**Necromancer ability; DBC-absent on this fork** (checked 2026-08-09: `805197` and the name
"Graveyard" appear nowhere in `dependencies/coa_spells.json` or `Input/necromancer_talents.json`).
So its behaviour is known only by **observation** — three `/combatlog` captures, parsed with
[`graveyard_observe.py`](graveyard_observe.py). Caster: Gravekeeper (Battlewrath's Necromancer).
Damage magnitudes are gear/level-scaled; the **structure** (layout, cadence, counts, durations) is
the ability.

Logs (verbatim, in [`logs/graveyard/`](logs/graveyard/)):
- `2026-08-09-08.26.47` — zone only (no Corpse Explosion)
- `2026-08-09-08.41.41` — Corpse Explosion at the ~20s mark (the consume)
- `2026-08-09-08.45.04` — Corpse Explosion as an expiry probe (two no-fire attempts)

## The mechanic — a corpse-factory zone

1. **Cast** (`805197`) → summons **5 "Tombstone" units** in a fixed layout (2 via `899900`
   "Layout A" + 3 via `899901` "Layout B") and lands a **20s debuff (`805197`)** on every enemy in
   the zone.
2. Each Tombstone **pulses every ~5s** — 5 pulses over the 20s window, the 5th at zone-end: deals
   ~270–300 damage (`500365`) to enemies in range **and summons 1 "Risen Ghoul."** 5 Tombstones →
   **5 ghouls per pulse.**
3. Each **Risen Ghoul rises and dies in ~0.4s** (`UNIT_DIED`). *That death is the corpse.* →
   **25 corpses per cast**, in bursts of 5 every ~5s.
4. **Corpses persist the whole zone** and **~4–5s beyond** (≈ one pulse-cycle), then **batch-fade.**
5. **Corpse Explosion** (`533239` cast → `533240` per-corpse AoE, instantaneous) **detonates every
   available corpse at once.**

## Measured (all three logs consistent)

| quantity | value | note |
|---|---|---|
| Tombstones | **5** | fixed layout (2 + 3) |
| Zone / enemy debuff | **19.95–19.98s ≈ 20s** | measured 3× — tooltip (20) confirmed; the eyeballed "15" was low |
| Pulses | **5**, every ~4.95–5.03s | the 5th coincides with zone end |
| Corpses per cast | **25** (5×5), summoned = died | `UNIT_DIED`, flagged as the player's |
| Corpse lifespan (rise→death) | **~0.37–0.46s** avg | |
| Corpse grace after last pulse | **~4–5s** (≈ one pulse-cycle) | stopwatch; log-bracketed **(1.8s, 7.0s)** — alive at +1.8s (consume), gone by +7.0s (failed CE) |
| Corpse Explosion | 1 cast → **all corpses at once** | `533240` ~764/hit (1146 crit), gear-scaled |

The grace is stated at human-operable precision — pinning it tighter buys nothing below reaction time.

## For a corpse/duration WeakAura

- **Trigger / duration:** Graveyard cast (`SPELL_CAST_SUCCESS 805197`) → a **20s** zone timer.
- **Corpse count:** each **Risen Ghoul `UNIT_DIED`** = +1 corpse — **loud, not** the silent-TTL trap
  from the summon work. Builds 5 every ~5s to 25.
- **Clear:** a successful Corpse Explosion (`533240` seen) → count 0; else **auto-clear ~5s after
  zone end** (the batch-fade).
- **Do NOT** use Corpse-Explosion *failure* to detect expiry: the corpse-less CE logs
  `SPELL_CAST_FAILED … "You can't do that right now."` — a **generic** string, not corpse-specific.

## Spell-id map (fills the DBC gap for 805197)

| id | name (as logged) | role |
|---|---|---|
| **805197** | Graveyard | cast + 20s enemy debuff |
| 899900 / 899901 | Graveyard Tombstone Layout A / B | summon the 5 Tombstones |
| 500365 | Graveyard | Tombstone pulse: damage + Risen Ghoul summon |
| 805465 | Graveyard | Tombstone self-buff (per-pulse refresh) |
| 805412 | Graveyard | Risen Ghoul rise-buff (applied→removed around rise/death) |
| **533239** | Corpse Explosion | cast |
| 533240 | Corpse Explosion | per-corpse AoE damage |

## Gear

`py graveyard_observe.py "<log path>"` — extracts the lifecycle (cast · tombstones · zone duration ·
pulses · corpses · lifespan · Corpse Explosion consume/expiry with the alive/gone-after-last-pulse
bracket). Runs on any of the logs above; reproduces this table.
