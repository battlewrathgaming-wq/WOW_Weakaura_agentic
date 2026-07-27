# Test: Harvest Plague × Haste  (PENDING — not yet run)

**Question:** Does Haste add ticks to Harvest Plague? If it does, it multiplies
Lesser-Zombie summon rolls (via Unrelenting Army `705747` — 20%/40% chance per
Harvest Plague damage event) → Haste becomes a pet-generation stat for
Animation, on top of the confirmed haste-inheritance (Necromancy `804360`).

**Why the DBC can't answer it:** Harvest Plague (`spell 500968`, 18s DoT,
instant, Shadow+Nature) applies a periodic-damage aura, but the summon is
custom-coded (a DUMMY effect + a custom aura type). The standard 3.3.5 "haste
affects periodic" attribute (AttributesEx5 `0x80000`) is unset in the record —
but that's non-conclusive on a custom core (cores often enable hasted DoTs
globally). So: resolve by measurement, not by reading data.

## Method — `/combatlog` tick-count A/B

Tick count per 18s cast is **deterministic** (no RNG) → 1–2 clean casts per
condition settle it.

1. In-game: `/combatlog` on (writes `<client>/Logs/WoWCombatLog.txt`;
   `/combatlog` again to stop). File appends — clear between conditions or let
   the parser bucket by cast.
2. On a **target dummy**, only Harvest Plague up.
3. Two conditions, record haste % each: **strip all haste** vs **stack max haste**.
4. A couple of casts per condition.

## Read

- Filter the log to `SPELL_PERIODIC_DAMAGE` + `500968` / `"Harvest Plague"`,
  source = you; bucket ticks per cast (`SPELL_AURA_APPLIED → _REMOVED`, the 18s
  window).
- **More ticks per cast at high haste → haste adds summon rolls → Haste climbs
  the stat list. Same count → it doesn't.**
- `SPELL_SUMMON` (Lesser Zombie) lines are the downstream payoff, but you don't
  need to grind that RNG — summons = ticks × proc-chance.

## Tooling

- Native export works today (no build). Parser = a small build-once Python
  script (CLEU field order documented in `Weak Auras/COMBAT_LOG_CAPABILITIES.md`).
- ms-precision upgrade (for exact inter-tick interval, not just count): a
  Custom-trigger WeakAura stamping `GetTime()` per tick into SavedVariables
  (the live-proven Pitho pattern, same doc).

**Status:** awaiting log capture; parser not yet built.
