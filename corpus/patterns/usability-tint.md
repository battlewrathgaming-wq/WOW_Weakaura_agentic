# pattern: usability-tint (three ability states, three looks)

_status: **primitive — LIVE-PROVEN 2026-08-09** on the Corpse Explosion aura (Battlewrath, in play).
Pure structure: two conditions on a Cooldown Progress (Spell) trigger, no Lua._

## The principle

**Borrow the action bar's own vocabulary rather than inventing one.** The player already reads these
three looks without being taught:

| state | look | means |
|---|---|---|
| `onCooldown` | **desaturate** | you genuinely can't press it |
| `insufficientResources` | **colour → blue tint** | ready, but feed it resource first |
| neither | full colour | press me |

Grey-for-everything (the naive build) **flattens a distinction that matters**: on many classes a missing
resource is one GCD away, not a wall (Battlewrath, on Necromancer runic power — "Grey would flatten the
signal too much"). Blue says *fixable*; grey says *wait*.

## The mechanics (source-verified, fork 5.21.2/iv86)

Cooldown Progress (Spell) natively provides all of it — **no inference, no Lua**:
`onCooldown` · `insufficientResources` · `spellUsable` · `spellInRange` · `charges` · `readyTime`
(`maps/condition_vars.json`, "Cooldown Progress (Spell)").

- Trigger: Cooldown Progress (Spell), Show **Always** (the icon is a fixture, not a proc).
- **Condition ORDER matters — later wins on a shared property.** Put `insufficientResources → colour`
  FIRST and `onCooldown → desaturate` SECOND, so "can't" out-ranks "need power" when both are true.

## The companion law — do not add a fourth state

**The icon answers "can I press this"; numbers answer "is it worth it".** Resist encoding opportunity
(stacks, targets, kill counts) as another tint — it collapses a judgement into a signal and adds mental
load. Show the number; let the player join the two. Live case: the CE aura's kill count is text only,
deliberately never a tint.

## Where it goes next

This is the **Ready contract's face**, pre-proven ahead of the contract existing — see
`creator/picker/picker_tree.md` (the desat POLARITY law: aura desat = *press me* · cooldown desat =
*can't press me*, the two lanes carrying opposite meanings for the same lever).
