# Test: Harvest Plague x Haste  — RESOLVED 2026-07-27

**Question:** Does Haste add ticks to Harvest Plague? If it did, it would
multiply Lesser-Zombie summon rolls (Unrelenting Army `705747` procs off each
Harvest Plague damage event) → Haste would become a pet-generation stat.

**Answer: NO.** Haste does not affect Harvest Plague's tick rate — so no extra
ticks, no extra summon rolls. Confirmed by three independent witnesses. Haste
stays a modest Animation stat.

## The spell (corrections vs the DBC)

- Live cast id = **`583255`**, matched by NAME in the parser — NOT the DBC ranks
  `500968`/`501890` I first pulled. A hardcoded-id parser would have matched
  nothing and reported a false "0 ticks".
- **24-second DoT, ~3s per tick = 8 ticks.** The in-game tooltip states
  "3 sec per tick over 24 seconds" — confirming the measurement. (DBC `500968`
  said 18s; a different/lower rank.)
- School `0x28` = 40 (Shadow+Nature); also **self-heals the caster ~41/tick**.

## Method

Native `/combatlog` → `<client>/Logs/<datetime> WoWCombatLog.txt` (ms-precision
timestamps; two-space separator; standard CLEU). Parsed with
`parse_combatlog.py` (this folder), which filters to caster + spell by NAME and
buckets each application into a tick timeline + summon count.

Two files, on a level-appropriate **Dynamic Training Dummy** (a lvl-63 static
dummy made Harvest Plague MISS — a level/hit issue, itself a "Hit matters" data
point):

- **Baseline** (`01.37.56`): no haste.
- **Haste** (`01.46.28`): +100 haste rating via **Potion of Lesser Haste
  (`17520`)** — applied `34.841`, DoT cast `35.771`, so ticks 1–6 were under it.

## Result

| | Baseline | +Haste |
|---|---|---|
| ticks | 8 | 8 |
| avg interval | 3.008s | 3.008s |
| aura duration | 24.0s | 23.987s |

Per-tick intervals while the potion was active (ticks 1–6): 3.020, 3.005,
2.955, 3.107, 2.892 — all the baseline ~3.0s. No compression, no added ticks.

## Three witnesses agree

1. **Combat-log measurement** — interval identical with the potion active.
2. **DBC** — the "haste-affects-periodic" attribute (AttributesEx5 `0x80000`) is
   UNSET on Harvest Plague (base-WotLK DoT behaviour: haste doesn't tick it).
3. **Tooltip oracle (Battlewrath)** — pumped haste via **Skeletal Archers**
   (Scourge Disciple, a class *spell*-haste source) and watched whether the
   tooltip's tick timing updated (it does on this server when a stat applies).
   It did NOT move. This also closes the "potion spell vs melee haste?" caveat —
   the archer source is unambiguously spell haste.

## Summon-timing note (not the verdict, but honest)

Summons proc off Harvest Plague damage events. Baseline summoned on ticks
**5–8** (looked like an end-ramp); the haste run summoned on ticks **1, 2, 3, 8**.
Both: 4 summons / 8 ticks (~50%). So the single-sample "intensify toward the
end" read is NOT supported across both — it reads like a ~per-tick chance with
RNG spread. The tooltip may describe a mild ramp, but two samples can't separate
it from luck. (Irrelevant to the verdict, which rests on the flat tick rate.)
Bonus: the summoned Zombies cast **Zombie Plague** (`504022`) + swing, so they
add real AoE damage, not just bodies.

## Verdict

**Haste does not increase Harvest Plague ticks or summons.** It stays a modest
Animation stat — inherited by the army (804360 → pets attack/cast faster), but
not a DoT/summon multiplier. Animation priority unchanged:
`SP ≥ Int ≈ Stam > Hit→cap > Crit ≈ Haste > Spell Pen`.

## Run it

```
py parse_combatlog.py "<path to ... WoWCombatLog.txt>" --player Gravekeeper
```
