# Test: Crypt Swarm x Haste  — REOPENED 2026-07-27 (input was bugged)

> **UPDATE 2026-07-27 (community — Johp, class Discord):** the archer-haste
> talent **Scourge Disciple is a KNOWN BUG — it applies NEGATIVE haste.** So
> this test's "+5 archers" condition was actually **−haste**, not +haste. That
> *explains* the longer channel (less haste → longer channel) and means Crypt
> Swarm **is** haste-responsive. The original "no benefit" conclusion is
> **invalid** (wrong direction tested); Crypt Swarm × *positive* haste is
> **reopened**. Clean re-test = potion, NO archers/Scourge Disciple. The raw
> measurements below still stand — only the interpretation flips.

**Question:** Does haste help Crypt Swarm (a channeled Runic-Power generator)?
The tooltip showed the channel getting *longer* with "haste" (2.74 → 2.85s).

**Original (invalidated) answer:** "no gain" — but the "+archers" input was
bugged −haste (see UPDATE). Corrected reading in the Verdict.

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

## Verdict (corrected)

The measured result — channel ~2% longer, same 19 ticks, flat output — was under
**bugged −haste** (Scourge Disciple), so it actually reads: *less* haste
lengthens the channel → **Crypt Swarm IS haste-responsive.** By symmetry a real
positive haste source would *shorten* the channel (faster RP cadence); whether it
also adds ticks/RP is **untested and open.** The earlier "haste buys nothing"
claim is **withdrawn.** (Harvest Plague's haste-immunity is separate and still
holds — tested with the real potion + the DBC flag.)

## The two hypotheses — RESOLVED to Hyp 2 (community)

1. Crypt Swarm mishandles haste (spell-specific), OR
2. **the archer haste computes wrong "to the global" ← CONFIRMED.**

Johp (class Discord): **Scourge Disciple is a known bug that applies negative
haste.** So the lengthening wasn't Crypt Swarm misbehaving — it was the *input*
being inverted, affecting everything haste-sensitive (GCD, casts, channels). No
discriminator run needed; the community pinned it. **Build note:** while bugged,
Scourge Disciple is a haste *penalty* — a trap talent for an Animation build.

## Run it

```
py crypt_analyze.py "<path to ... WoWCombatLog.txt>" --player Gravekeeper
```
