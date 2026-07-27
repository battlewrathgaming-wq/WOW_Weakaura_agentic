# Test: Crypt Swarm x Haste  — RESOLVED 2026-07-27

**Question:** Does haste help Crypt Swarm (a channeled Runic-Power generator)?
The tooltip showed the channel getting *longer* with haste (2.74 → 2.85s), which
is counterintuitive — is that more ticks/RP (a gain) or just a stretched channel
(neutral/loss)?

**Answer: no gain — a mild loss.** Haste adds no ticks and no output; it slightly
lengthens the channel for the same result.

## The spell (`501886`)

3.0s base channel. Damage logs as `SPELL_DAMAGE` id **`800343`**; Runic Power as
`SPELL_ENERGIZE` id **`800344`** (amount, powerType 6). Channel bounded by the
`501886` aura; a few damage ticks trail just past the channel end (so we
aggregate across casts rather than bucket strictly by the aura window).

## Method

`/combatlog`, two files, **3 Crypt Swarm casts each** on a Dynamic Training
Dummy: baseline (no archers) vs +5 Skeletal Archers (Scourge Disciple haste).
Parsed with `crypt_analyze.py` (this folder): aggregate ticks + total RP per cast.

## Result

| Metric | Baseline | +5 archers (haste) |
|---|---|---|
| casts | 3 | 3 |
| channel avg duration | 2.730s | **2.792s** (longer) |
| damage ticks | 19 (6.33/cast) | 19 (6.33/cast) |
| total damage | 1906 (635/cast) | 1870 (623/cast) |
| RP energizes | 19 (6.33/cast) | 19 (6.33/cast) |
| total Runic Power | 88 (29.3/cast) | 91 (30.3/cast) |

- **Tick count identical** (19/19) — haste added zero ticks.
- **Damage & RP flat** within RNG (−2% dmg from one baseline crit; +3% RP).
  Per-second RP ~unchanged (~10.7 vs ~10.9 RP/s).
- **Channel ~2% longer** with haste (measured 2.730→2.792s; tooltip 2.74→2.85).

## Verdict

Haste buys Crypt Swarm **nothing** — same ticks, same output, marginally longer
channel (a slight cast-time inefficiency, not a gain). With the Harvest Plague
result, haste adds no output to Necromancer's periodic/channel damage; its only
value is pet-inheritance (804360). Haste is the weakest Animation secondary.

## Two open hypotheses for the odd lengthening (posted to the class Discord)

1. Crypt Swarm mishandles haste (spell-specific), OR
2. the archer haste computes wrong "to the global".

**Discriminator (not yet run):** cast a normal HARD-CAST spell with 0 vs 5
archers and read the cast time (`SPELL_CAST_START → SPELL_CAST_SUCCESS` gap): if
it shortens correctly, archer haste is globally fine → Hyp 1; if it lengthens,
Hyp 2. Bonus: run Crypt Swarm under the **potion** — if it also stretches, Hyp 1
(source-independent). Third possibility: benign channel-duration rounding to
whole ticks (not a bug). The robust claim regardless: **total output is
unchanged.**

## Run it

```
py crypt_analyze.py "<path to ... WoWCombatLog.txt>" --player Gravekeeper
```
