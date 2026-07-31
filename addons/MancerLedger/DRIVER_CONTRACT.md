# DRIVER_CONTRACT — what MancerLedger depends on, characterized from source

_Every field we consume from MancerDB, characterized from the driver's own code
(LibellusLeti **0.9.553**, silo-archived at `addons/refs_libellus/LibellusLeti-0.9.553-devdrop/`
with provenance). Rule: the source dictates handling — no invented use ships without a
license traced here. Born from a live catch (2026-07-31): we invented cadence = hits/unit-time
and it rendered 174.9 hits/min on a lone warrior, because we hadn't characterized what those
two fields mean TOGETHER. Repo-only doc (not deployed)._

## Fight lifecycle (verified)

- **Open**: `PLAYER_REGEN_DISABLED` → `OnCombatStart` (NecromancerAdvisor.lua:5904). CLEU
  can also open a fight, but ONLY if the player is actually in combat — out-of-combat
  nearby noise is refused (RecordDamage head).
- **Settle**: `PLAYER_REGEN_ENABLED` → `OnCombatEnd` → `FlushAllOpenSummons` (windows close
  "combat_end") → auto-commit (MinionDps.lua:1083–1106). Missed segments commit at the NEXT
  pull's start (`pendingFight`).
- **Storage**: `MancerDB.minionDps.fights` — ring, newest at [1], `MAX_SAVED_FIGHTS = 10`.
- **Dedup**: fingerprint `"%.3f:%.3f:%.0f" % (startedAt, endedAt, totalMinionDamage)`
  (MinionDps.lua:1023). Unchanged since 0.9.434. **Our fold cursor recomputes this exact
  recipe — if their recipe ever changes, our seen-set silently restarts (double-fold risk):
  re-verify on every driver version bump.**

## Attribution (verified at the consumer boundary)

`fight.minions` is keyed by `minionId` — the driver Advisor's lowercase slug (`ghoul`,
`skeletal_warrior_greater`), resolved via its GUID map + name patterns (MINION_TYPES).
We treat the slug as an OPAQUE KEY: fold by it, prettify for display, never interpret it.
Their per-GUID `units` sub-buckets exist but are DELIBERATELY UNFOLDED (our grain is
per-type; folding individuals would double-count against the type bucket).

## Field characterization

| field | accrual (source) | population semantics | our license |
|---|---|---|---|
| `startedAt`/`endedAt` | regen boundaries (or first in-combat CLEU / commit time) | the pull window | fingerprint input; lifetime bookkeeping only |
| `bucket.hits` | +1 per damage event with **amount > 0** (RecordDamage head refuses ≤0) | landed damaging events; **crit NOT distinguished; fully-absorbed hits NOT counted** | attempt counting ✓; "hit" ≠ "swing" (a full absorb vanishes) |
| `bucket.damage` | += amount per landed event (:1867 area) | raw damage sum, context-soaked | RAW LABELED TOTALS ONLY — never a normalized family claim (NORMALS DISCIPLINE) |
| `bucket.misses` + `missTypes` | +1 per avoid event, type normalized UPPERCASE (RecordMiss; DODGE/PARRY/BLOCK/RESIST/ABSORB/IMMUNE...) | per-attempt avoids, window-independent | miss% = misses/(hits+misses) ✓ fully licensed, our sample floor 20 applies |
| `bucket.summonCount` | +1 per opened window: real observed raise (:1717) **OR synthetic** (see below) | **summon-events-observed-in-fight, NOT existence** | display "-" when 0 (unobserved ≠ never existed) — enforced |
| `bucket.activeSeconds` | window close → += lived (:1739). Windows close on: UNIT_DIED (:1282), estimated expiry, or combat end. (Our petlog proved UNIT_DIED silent for OVERWRITE-despawn only; death-by-enemy was NEVER in that sample — no bias-driven claim about their died-close path. CORRECTED 2026-07-31, Battlewrath's catch.) | **observed/estimated unit-time, NOT lifetime** | denominator ONLY under the cadence gate (below) |
| `spells{}` | per-ability sub-buckets, label from spell name, `Melee` = id 1; same hits/misses/damage rules | ability mix | composition shares ✓ (self-normalizing); damage raw-only |
| `units{}` | per-GUID breakdown (temp types) | individual grain | NOT FOLDED (deliberate) |
| `playerSpells`, `peakCounts`, `guidMap`, `openSummons` | — | driver internals | NOT CONSUMED |

## ★ The window-synthesis rule (the load-bearing subtlety)

`EnsureOpenSummonFromDamage` (verified):
- **Temporary minions**: a window OPENS from the minion's first observed action if no summon
  was seen, with expiry **ESTIMATED** from the Advisor duration table / fallback, and
  `summonCount` increments for it (`synthetic = true`). → Temp unit-time is part
  observation, part estimate. **Cadence for temps is therefore an APPROXIMATION, not a
  measurement.** Good enough for long-term averaging; never present it as precise.
- **Permanent minions**: `IsTemporaryMinion` gate — NO synthetic windows, ever. A permanent
  raised before the pull accrues hits with **zero** summons/unit-time. This is why the
  cadence gate exists.
- **`lesser_zombie` is special-cased OUT of synthesis** — zombie unit-time comes only from
  observed Animate summons (plentiful, so their numbers stay honest).

## Derived metrics we invented — license status

| our metric | status |
|---|---|
| miss% (+ breakdown) | LICENSED — per-attempt, window-independent |
| ability mix (hit shares) | LICENSED — composition self-normalizes |
| damage totals | LICENSED as raw + labeled only |
| cadence (hits/unit-min) | **GATED**: requires `activeSeconds > 0 AND summonCount >= fights` (a temp summons ≥ once per fight it acts in; a permanent's sliver window can never divide all-fight hits). Even when shown: approximate (synthetic windows). |
| summons / unit-time columns | display observed accounting; `-` when unobserved |
| crit% | IMPOSSIBLE — the driver does not track crits (verified 0.9.553; the one gap worth suggesting upstream) |

## Drift posture

Shape validated per fight before fold; violations skip the fight and say so once, loudly,
with the driver version. Unknown bucket fields of ANY type (numbers AND tables — 0.9.553's
missTypes taught us tables) are flagged as drift, noted per profile, never folded, never
guessed. On every driver version bump: re-verify the fingerprint recipe, the bucket shape,
and THIS document.
