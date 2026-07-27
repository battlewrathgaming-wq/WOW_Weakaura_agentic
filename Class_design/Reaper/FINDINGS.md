# Reaper (Domination) — Findings

Battlewrath's Reaper; **Domination = a tank.** First pass, 2026-07-27. Evidence-
first — mechanics cite `Input/reaper_talents.json`; nodes not yet read are
flagged, not guessed. Run against the method (`../METHOD.md`): EXPRESSION (the
decoded build) × INTENT (the thesis) × MECHANICS.

## Thesis (INTENT — Battlewrath)

A **soul-economy tank** — dark-fantasy, 2H, mobile, plate, ghost-stealth. Engine:

- **Runic Power** (builder) **and Reap** both mint **soul fragments**; **3 fragments = 1 Reaped Soul**; **Reaped Souls stack to 3 = Soul Infusion.**
- Spenders tier up: some cost Runic Power · some cost Reaped Souls (and may also spend Soul Infusion) · **Soul-Infusion spenders clear the 3-stack.** Soul Infusion is the escalated payoff that resets the ladder.
- **Mitigation is active:** self-heal (Deathwind AOE, Soul Strike) + debuffs + tree passives, plus survivability cooldowns — not a block/armor wall.

The "key thing" = the **soul ladder feeding active mitigation** (fed *and* cashed well?) + **sustain-as-mitigation** (does self-heal/debuff/passive carry survivability?).

## Expression (decoded — `../tools/decode_build.py`)

Class + heavy **Domination**. Abilities: Wraithblade · Scythe Rush · Tormented
Souls · Soul Harvester · Tormentor · Backswing · Veilwalk · Soul Warden (2/2) ·
Jailer's Bargain · Bolstered Form · Harvester's Scythe. Domination talents:
Dreadwake · Dreadknight (r2) · Behemoth · Soul Slip · Empyrean Fortitude · Dark
Soldier · Soultaker · Requiem · Lifestealer · Essence Binder · Soulsight ·
Spectral Scythe · + Class: Soulfused Constitution · Dominion.

## Mechanics grounded (the engine + sustain the build actually takes)

- **Wraithblade** (805258) — "**Generates 3 Reaped Souls**" + a big Shadow strike (ignores resist/absorb/invuln) → jumps straight to a full ladder / Soul Infusion.
- **Scythe Rush** (500359) — rush + **15 Runic Power** (mobility + builder; 1/target/20s).
- **Backswing** (706790) — **Reap's RP +5** (builder booster).
- **Soul Harvester** (804311) — killing blow → 2 RP/sec for 10s (sustained-combat RP).
- **Tormented Souls** (500483) — the mitigation payoff: **consumes Reaped Souls + Soul Infusion** → per stack **−10% direct damage taken** and **heal = 35 + 5.8% AP + 24% Stamina** (20s).
- **Soul Strike** (leech self-heal, RP-cost) — amplified TWICE in the build: **Harvester's Scythe** (805188, +15% leeched) + **Lifestealer** (301366, +3% of missing-health generated). A low-health-scaled leech.
- **Jailer's Bargain** (805718) — CD: **absorb 30% of max health, 10s** + Undead / immune to fear/sleep/charm.

## First talking points

1. **Realization — the core loop is coherent with the thesis (strong).** Builders
   (Scythe Rush, Backswing/Reap, Wraithblade's instant 3 souls, Soul Harvester)
   feed the ladder; **Tormented Souls** cashes it into −10% damage-taken +
   self-heal; **Soul Strike** leeches and the build *double-invests* in it
   (Harvester's Scythe + Lifestealer); **Jailer's Bargain** is the panic CD. The
   build is realizing sustain-as-mitigation, not fighting it.
2. **Stat lean — Stamina is the premier stat (the "helps most" stub).** Double
   duty, echoing the Necro finding but for a tank: Stamina is raw EHP **and** it
   scales the main self-heal — **Tormented Souls heals 24% of Stamina per stack.**
   **Attack Power** is the co-scaler (that heal's +5.8% AP; the mobility shield
   +33% AP; Wraithblade +18% AP). → **Stam + AP scale survival throughput;** a
   pure avoidance/armor priority would under-serve this active-mitigation build.
3. **Gameplay-realization (the "are we realizing it in play" edge).** The
   mitigation is a *spender* gated on the ladder: realizing it = **feed the
   ladder (RP/Reap → souls) and cash Tormented Souls proactively** (before big
   hits), keeping −10% + heal-per-stack rolling. This is exactly where an aura
   earns its place — surface soul-ladder state + Tormented Souls stacks/uptime.
   (The downstream product.)

## Open / next (honest gaps — not yet read)

- Domination + Class **talents not yet grounded**: Behemoth · Dreadknight ·
  Empyrean Fortitude · Soulfused Constitution · Soultaker · Requiem · Spectral
  Scythe · Soulsight · Essence Binder · Soul Slip · Dark Soldier · Dreadwake ·
  Dominion. Next pass reads each + traces synergy/topology (the capture record's
  `ConnectedNodes` / `Spells` graph).
- **Deathwind** (the AOE self-heal named in the thesis) — not yet located among
  the picks; confirm whether it's taken.
- **Plan-drift:** Dreadknight is **r2 in-game vs r1** in the saved export (per
  `../tools/CAPTURE.md`) — reconcile (reclaim the point or update the plan).

## Sources
`Input/reaper_talents.json` (ability/talent text) · the decoded build
(`../tools/decode_build.py`) · thesis: Battlewrath 2026-07-27. Mechanics NOT simmed.
