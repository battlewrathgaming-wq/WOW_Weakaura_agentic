# DRIVER_CONTRACT — `AscensionUI.DeathRecap`

_What COA_DungeonRun consumes from another addon, characterised from **their source and our own
landed records** rather than from assumption. Same discipline as
`MancerLedger/DRIVER_CONTRACT.md`, which exists because one metric invented before
characterisation rendered nonsense._

## The driver

`Interface/AddOns/AscensionUI/DeathRecap/` — **ships with the client**, so unlike `/combatlog`
this is a product path: nothing is asked of the user. It is a **CoA-authored addon** running its
own `COMBAT_LOG_EVENT_UNFILTERED` listener, buffering the last 14 damage/heal events taken by
the player. Reachable because `AscensionUI.lua:3` assigns the addon table to a global.

**We read it so we do not run a second CLEU listener.** Their work is already paid for.

## ★ We consume TWO fields — one for content, one as a filter

```
AscensionUI.DeathRecap.Events[ AscensionUI.DeathRecap.CurrentRecap ][i].attacker
```

**and `isPlayer`, purely to exclude entries.** Distinct `attacker` strings from
entries where `isPlayer` is falsy, first-seen order, attached to a **terminal stop** — a marker where
the run ended because the player died. Nothing else.

**That is a scope decision, not an oversight** (Battlewrath, 2026-08-13): *"People can run combat
parsers. And they already handle damage taken. That's not our lane. Route forming is."*

| Field | Why NOT consumed |
|---|---|
| `damage` · `school` · `healthPercent` · `crit` · `periodic` · `spell` · `eventTime` | damage analysis — Recount, Mancer and Libellus serve it properly |

**★ `isPlayer` MOVED from "not consumed" to "consumed as a filter" (2026-08-13),** because a
real record forced it: `RFC_Run3_Messy` pull 12 recorded
`killedBy = [Gravereaper, Searing Blade Enforcer, Taragaman the Hungerer]` — **Gravereaper is the
player.** The recap folds `SPELL_HEAL`, so a self-heal lands with `attacker` set to the healer.
`attacker` literally means *the caster of this event*, not *an enemy*, and without the filter
`killedBy` meant *who appeared in the last 14 events*. **The field was characterised in this
contract before it was needed, which is the whole point of writing one.**

**The narrow read is the point: a field you do not consume cannot drift under you.** This fork
ships changes in days, and every trap below would otherwise be live risk.

## Read timing — there is only one correct moment

**`PLAYER_DEAD`.** `CurrentRecap` increments on `PLAYER_UNGHOST` **and** `PLAYER_ENTERING_WORLD`
(`DeathRecap.lua:258-268`), so any later read finds an empty buffer.

Combat may not drop for seconds after death, so the value is **held** and spent when the combat-end
marker is written — and **only if that marker is `dead`**. Attaching a stale attacker list to a
pull we walked away from would be a lie.

## ★ Traps found in the fields we do NOT consume

Kept because they cost two live captures to find, and the next consumer of this table — ours or
another bench's — should not pay for them twice.

| Trap | Evidence |
|---|---|
| **`crit` is `nil \| true \| string`.** Absent entirely on a non-crit (the key does not exist); a damage-type STRING (`"LAVA"`, `"FALLING"`) on environmental damage, because `ENVIRONMENTAL_DAMAGE` passes `damageType` into the `crit` slot | live 14/14 absent · live 16/16 string · `DeathRecap.lua:207-211` |
| **`damage` is SIGNED, and the sign is the discriminator** — every damage path passes `-damage`, both heal paths pass `heal` unnegated | `DeathRecap.lua:179-225` |
| **`spell` encodes source kind** — real id for spells, **`-1` melee**, **`0` environmental** | live · `DeathRecap.lua:186-211` |
| **`absorbed` is folded into `damage`** — it is the *effective* amount, not the raw landed number | `DeathRecap.lua:180-182` |
| the buffer holds **14 entries ≈ 3 seconds**. It is the last breath, **not a fight summary** | live: entered the buffer at 8.8% health |

## Drift behaviour — it fails LOUD, in the record

`recapAttackers()` returns `(names, nil)` or `(nil, reason)`, and the reason is written to the
marker as **`killedByUnavailable`**:

| Reason | Meaning |
|---|---|
| `AscensionUI.DeathRecap absent` | the driver is gone, renamed, or not yet loaded |
| `recap buffer absent or not a table` | `Events` / `CurrentRecap` shape changed |
| `recap buffer held no named attacker` | shape fine, `attacker` no longer a string — or a genuinely empty death |

**A silent absence would read as "nothing killed us."** The record says which it was.

We never write to their table, never call their functions, and never assume load order.

## Verified vs derived

| | |
|---|---|
| **Live-verified** | reachability · `Events` is a 1-based array keyed by `CurrentRecap` · the 14-cap · all nine fields present on 16/16 and 14/14 entries · `attacker` holds real mob **and** boss names (`"Taragaman the Hungerer"` 14/14) · `crit` absent · `crit` as a string |
| **Source-derived, not observed** | `crit == true` · `periodic == true` (DoTs) |
| **Live-verified LATER** | **`isPlayer == true`** — not PvP as assumed, but a **self-heal**: `RFC_Run3_Messy` pull 12. And **heals as positive `damage`** with it, since that is the same entry |

Records: `20260813_010321_263__dump.json` (environmental) · `20260813_011150_203__dump.json`
(trash) · `20260813_012626_775__dump.json` (boss) · `RFC_Run3_Messy-5` (the `isPlayer` case).

## Re-verify when

The driver's files change, or a fork patch lands. One line settles it:

```
/coadump r dump AscensionUI.DeathRecap
```
