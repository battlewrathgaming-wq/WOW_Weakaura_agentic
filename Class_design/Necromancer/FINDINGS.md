# Necromancer — Findings

Battlewrath plays **Animation**. Evidence-first summary of how the class works
and what to gear for. Sources at the bottom; every number traces to one. "NOT
simmed" throughout — these are mechanics-grounded reasonings + live
measurements, not sim output.

## What it is

An undead-summoning caster/commander. You don't swing — your **army** does.
Every spec raises minions and spends a resource to make them act; throughput is
"how much army is up × how hard I can make it act," not a personal weave.

## Resource economy (all specs)

| Resource | Job | Note |
|---|---|---|
| **Mana** | budget | funds `Raise` / `Animate` — getting minions out |
| **Runic Power** | spend | `Command` spells burn it to make the whole army act at once |
| **Life Force** | cap | how many minions you can field: Abom 3, Gargoyle 3, Banshee 2, Skeletal Mage 1, Ghoul 1 |

The two questions the moment always asks: *is my army up?* and *can I afford to
make it act?* (Life Force has its own native in-game orb UI.)

## The pet-scaling engine — the core of Animation

Two mechanics that form a **convergent loop** (verified in-game 2026-07-27; see
`tests/stamina-loop-test.md`):

1. **Necromancy** passive (`spell 804360`): minions gain **Attack Power + Spell
   Power from your Intellect + Spell Power**, scaled by the **minion's Life
   Force** (bigger minions inherit more). They also inherit **a portion of your
   hit, crit, haste, armor, resistances** and **gain expertise from your hit
   chance**. Dev Grey: Intellect feeds pets at **~½ the rate of Spell Power**.
2. **Sepulchral Might** talent (`spell 706472`, Animation, 2 pts): "+5%/10% your
   Stamina; your spell damage += **15%/30% of your Raised minions' total
   Stamina**."

The loop:

> **your Stam ↑ → minions' Stam/HP ↑ → your SP ↑ (Sepulchral Might) → their SP ↑ (804360)**

It converges (minion SP doesn't feed back into stam). Two talents feed the
minion-stam side: `807494` (Lv30 passive: +1 max Life Force & +10% minion
Stamina) and `300748` (needs Fetid Ward: +5/10% max health of you & summons).

**Consequence:** crit / haste / hit are **not filler** — inherited by the whole
army. And Stamina is a genuine **damage** stat, not just survival.

## Stat priority — Animation (measured + reasoned)

**Spell Power ≥ Intellect ≈ Stamina > Spell Hit (to cap) > Crit ≈ Haste > Spell Pen**

- **Spell Power** — anchor (1.0). Scales every pet + your own casts.
- **Intellect** — pet AP/SP at ~½ SP; plus your mana / own SP / crit.
- **Stamina** — **measured ~0.5 SP per point** for your damage via the loop
  (`tests/stamina-loop-test.md`) — ≈ Intellect — **plus** pet HP/survival
  **plus** it feeds every pet's SP. Caveat: the 0.5 rate is **army-dependent**
  (Sepulchral reads *total* minion stam → more/bigger pets up = more SP per
  stam; solo with no pets = ~0 damage value).
- **Hit → cap** — feeds pets (hit chance + expertise); a missed cast/disease is
  a dead GCD. (Hit-cap behaviour is standard for this client generation — worth
  a one-time CoA confirm.)
- **Crit ≈ Haste** — inherited by the army (crit = army crit, haste = army acts
  faster). Real, not filler.
- **Spell Pen** — mostly endgame / resistant-target / PvP.

**Build implication:** Battlewrath's **Boneward (`681528`, +10% stam)** and
**Foul Mandate (`573297`)** stam-stacking is a confirmed *damage* line, not a
survival tax — push it. Favour **high-Life-Force minions** (Abom/Colossus/
Gargoyle) when Life Force allows; the loop scales multiplicatively with a
minion's Life Force (Abom's stam gain was ~3.9× a Ghoul's —
`tests/stamina-loop-test.md`).

## Open items

1. **Harvest Plague × Haste** — does haste add DoT ticks (→ more Lesser-Zombie
   summon rolls via Unrelenting Army `705747`)? Harvest Plague = `spell 500968`,
   18s DoT. Custom-coded, so the DBC can't settle it → resolve by `/combatlog`
   tick-count A/B (`tests/harvest-plague-haste-test.md`). If yes, Haste climbs.
2. **Exact Life-Force slope** — multiplicative confirmed; a third data point
   (Banshee LF2 / Gargoyle) would pin linear-×LF vs slightly steeper.
3. **Hit-cap value under pet-heavy play** — pets inherit hit, but a "can't miss"
   pet (Cryptfiend) is an exception; the your-casts vs pet-autos damage split
   sets Hit's true weight.

## Other specs (not Battlewrath's — brief, for completeness)

- **Death** — disease/DoT + execute (harder below 35% target HP via Damnation /
  Creeping Crypt). Win condition = disease uptime + `Virulency` spread.
- **Rime** — proc-driven frost burst; watch the Refreshing Chill proc + keep the
  target Frozen for Glacial Impact. Community stat feel (Ophana, "no sim"): Hit
  cap > ~60 spell pen > SP > crit > int ≈ haste — spellcaster-damage shaped,
  unlike Animation.

## Sources

- `Input/necromancer_talents.json` — talent/ability DB (dev-authored).
- `dependencies/coa_spells.json` — spell DBC dump (804360, 500968, 706472, …).
- In-game: Necromancy tooltip (804360); stamina-loop A/B test 2026-07-27.
- `Weak Auras/Necromancer/Necromancer_fantasy_playstyle.md` — class fantasy / spec identities.
- `Weak Auras/COMBAT_LOG_CAPABILITIES.md` — CLEU capture reference (pending Harvest Plague test).
- Community/dev: necro Discord — dev **Grey** (pet scaling), Ophana (Rime feel).
