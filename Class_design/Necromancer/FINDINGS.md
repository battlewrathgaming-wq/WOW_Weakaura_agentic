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

**Pet-count → SP scaling — LINEAR** (measured 2026-07-29, `GetSpellBonusDamage`
API at settle — **ghouls, no buffs: the raw mechanic**). Keep two layers apart:

- **Shape (general, the finding):** SP scales **LINEARLY** with minion count —
  dead steady, **no cap, no diminishing** through 5 — plus a **one-time
  first-minion bonus** (the first pet is worth double). It's general SP (all
  schools move together). This *structure* is the mechanic and should hold across
  pet types (measured on ghouls).
- **Magnitude (scoped — do NOT overclaim):** for an **unbuffed ghoul** it was
  **+15 SP each, +30 the first** (`SP = 220 + 15×ghouls (+15 once any is up)` →
  220/250/265/280/295/310). But the per-pet number is **pet-dependent** (per-pet
  SP scales with that pet's stamina/Life Force — a Colossus/Abom adds *more* than
  a ghoul) **and buff-dependent** (Stamina + the Stamina loop raise each pet's
  contribution). So +15 is a *baseline for a bare ghoul*, not a per-minion
  constant.

Reinforces "go wide" (no falloff for stacking pets) and composes with the Stamina
loop (more player Stam → more per-pet Stam → a bigger per-pet SP). Resolves the
necro-Discord confusion — the "colossus flat 2nd" was live-tracker noise (read the
API at settle). WHY the first-pet doubling: likely a flat active-minion SP grant,
unverified (a 1→0→1 or a different first pet would confirm).

**A community re-run + a new open question (2026-07-29).** LtGenZombie posted a
ladder whose steps *look* consistent with **+15/ghoul**, but under **unknown
conditions** (buffs, base, pet type not stated) — suggestive, **not a controlled
reproduction**; don't lean on it. Their leading **−75** is an uncontrolled
artifact — Battlewrath's *guess*, from his own similar run, is a big-pet→ghoul
transition (losing a large pet's SP); consistent with the pet-dependence above but
it does not *quantify* it. **Protocol:** start ladders from a *truly empty* base
(clear all, settle, confirm) — a lingering pet poisons the baseline. **Stale values — CHARACTERIZED** (transient, not persistent; relayed to the class
Discord 2026-07-29). The bonus-damage (SP) value recomputes **lazily / throttled,
not continuously**: after removing pets the old value **lingers ~3–5s** (idle /
ambient recompute) before dropping to the floor; an **event** (summoning a minion)
triggers a tighter **~1s** recompute. *Caveat (Battlewrath):* could be a **single**
internal clock, the 1s-vs-3–5s split just being read-timing on either side of the
tick — not necessarily two mechanisms. Crucially it **corrects** → no
history-dependent residue, **no permanent bug**. **Gameplay:** SP lags a pet change
by up to ~3–5s when **idle** (stale-high after pet loss, stale-low after gain);
likely shorter in active combat where events keep poking the recalc (unconfirmed).
**Measurement:** read *at settle* (wait for the value to jump/drop) — the API reads
the same throttled internal value.

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
- **Crit** — inherited by the army (your crit → army crit). Real, not filler.
- **Haste** — inherited by the army (attacks/casts faster). Harvest Plague ticks
  are haste-immune (real potion + DBC flag). Crypt Swarm × *positive* haste is
  **open** — our archer test was invalidated by the bug below (it was −haste),
  and a real haste source would likely *shorten* the channel. So haste's value is
  uncertain, not dismissed. See `tests/harvest-plague-haste-test.md`,
  `tests/crypt-swarm-haste-test.md`.
- **⚠ KNOWN BUG — Scourge Disciple:** the archer-haste talent applies **negative**
  haste (community-confirmed, class Discord 2026-07-27). While bugged it is a
  haste **penalty**, not a bonus — a trap for an Animation build, and it poisoned
  our Crypt Swarm "haste" test (that condition was really −haste).
- **Spell Pen** — mostly endgame / resistant-target / PvP.

**Build implication:** Battlewrath's **Boneward (`681528`, +10% stam)** and
**Foul Mandate (`573297`)** stam-stacking is a confirmed *damage* line, not a
survival tax — push it. Favour **high-Life-Force minions** (Abom/Colossus/
Gargoyle) when Life Force allows; the loop scales multiplicatively with a
minion's Life Force (Abom's stam gain was ~3.9× a Ghoul's —
`tests/stamina-loop-test.md`).

## Open items

1. **Harvest Plague × Haste — RESOLVED (no).** Haste does NOT affect Harvest
   Plague's tick rate, so it adds no summon rolls; Haste stays modest. Three
   witnesses agree: combat-log A/B (interval unchanged), DBC flag unset, and the
   tooltip didn't move under archer/potion spell-haste. Live spell = `583255`, a
   **24s / 8-tick @ ~3s** DoT (the DBC `500968`/18s was a lower rank). Full
   write-up: `tests/harvest-plague-haste-test.md`.
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
