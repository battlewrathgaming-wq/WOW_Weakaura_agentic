# Reaper (Domination) — bar map + grounded kit

_Battlewrath's control surface (level 33, 2026-07-27), each bind grounded against
`Input/reaper_talents.json` (descriptions) + `dependencies/coa_spells.json`
(cost/CD). **RP costs are stored ×10** (300 = 30 RP). Bar model: Shift = shift-bar
overlay · Alt = bar 2 · Stealth = stealth overlay on bar 1. Empty slots = level-33
unlocks pending._

## The grid (key → ability → grounded → ergonomic fit)

| Key | Ability | Grounded | Fit |
|---|---|---|---|
| **Q** | Reap | core RP builder (+5 via Backswing) | ✓ hot = spam builder |
| Shift-Q | Scythe Rush | rush + **15 RP**, 1/target/20s | ✓ builder+mobility |
| Alt-Q | Soul Capture | 15s CD; **1 Reaped Soul + 10% HP, corpse-gated** (player-filled) — situational | ✓ situational → alt |
| **E** | `castseq Dreadwake, Dreadwake, Murder` | Dreadwake 30 RP → 1 Reaped Soul + cone; Murder 30 RP strike | ✓ 30-RP column |
| Shift-E | Deathwind (`@player`) | 30 RP, AOE self-heal, 10s | ✓ |
| **R** | Soul Strike | **40 RP** leech self-heal (missing-hp scaled; +Lifestealer/Harvester's Scythe) | ✓ hot = primary heal |
| Shift-R | Wraithblade | **40 RP → 3 Reaped Souls** + big Shadow strike, 30s CD | ✓ instant full ladder |
| Alt-R | Will of the Forsaken (racial) | 120s CD escape | ✓ long-CD → alt |
| **F** | Reliquary of the Lost | **20s CD**, spends reaped souls — the DEFAULT spend | ✓ hot = default |
| Shift-F | Tormented Souls | **20s CD**, spends Reaped Souls/Soul Infusion → −10% dmg + heal (35 + 5.8% AP + **24% Stam**)/stack, 20s | ✓ shift = situational |
| **T** | `castseq Requiem, Requiem, Soulrend` | Requiem: AoE + −20% atk speed + RP; Soulrend: soul-infusion spender | ✓ cold = ST-earned |
| Shift-T | Soulslam | 45s CD spender | ✓ |
| **V** | Spectral Scythe | 45s CD, spends Reaped Souls/Soul Infusion → scythes per soul; **Soul Strike spreads them to +5 nearby** | ✓ cold |
| **1** | Bolstered Form | 60s CD: **+30 RP**, +25% armor, +25% parry, 15s | ✓ defensive |
| **2** | Jailer's Bargain | 120s CD: absorb 30% max HP + immune fear/sleep/charm | ✓ defensive |
| **3** | Trinket (defensive; will change) | — | |
| Shift-W | Veilwalk | 2 charges / 60s: +50% speed 5s, cleanse movement, stealth-usable | ✓ mobility |
| Shift-S | Ghost Claw | 15s CD snare (8s) | ✓ snare |

Empty (level-33 unlocks pending): Alt-E · Alt-F · Shift-V · Alt-V · Alt-T · power 4.

## Reads

- **Ergonomic fit: coherent.** Position matches cadence throughout — builders +
  primary leech hot (Q/R); the *default* reaped-soul spend (Reliquary) hot on F
  with the *situational* one (Tormented Souls) on Shift-F; 30-RP spenders on the E
  column; long-CD on cold/alt keys; defensives on 1/2. "Reliquary usually wins" is
  literally encoded (F vs Shift-F). No glaring mismatch — well-tuned.
- **Runic Power is the throttle.** One pool feeds THREE demands: the leech-heal
  (Soul Strike 40), the soul-converters (Wraithblade 40→3, Dreadwake 30→1), and
  the 30-RP strikes/debuffs (Murder/Deathwind). So RP generation (Reap + Backswing
  +5, Scythe Rush +15, Bolstered Form +30) throttles heal, souls, AND damage
  together — a bigger throughput lever than any single stat. Bolstered Form &
  Scythe Rush refuel RP *as* a defensive / mobility — pressing them is refuelling.
- **Latent synergy: Spectral Scythe × Soul Strike** — cash reaped souls into
  Spectral Scythe, then Soul Strike spreads the scythes to +5 nearby → a
  reaped-soul → AoE combo across V + R.
- **TS/Reliquary contention, precise:** each carries its OWN 20s cooldown
  (separate, not shared) AND both spend reaped souls → contend on both cadence and
  resource. (Battlewrath's 20s-cadence instinct was grounded.)

## Player-read (Battlewrath, 2026-07-27) — spend model + divergences

- **The soul ladder is strict + consecutive** (Battlewrath, clarified): 3 fragments
  → 1 Reaped Soul; 3 Reaped Souls → 1 Soul Infusion; resources spent whole — no
  partial/rolling "spend-2-keep-1" formation. **F = reaped-soul spenders**
  (Reliquary / Tormented Souls); **T = Soul-Infusion spenders** (Requiem→Requiem→
  Soulrend). F-before-T is a positional spend-order reminder.
- **RESOLVED — the Soul-Infusion spend priority** (Battlewrath, player-confirmed
  mechanic). Soul Infusion exists ONLY at the 3-stack, and **F (Reliquary / TS)
  spent at 3 consumes BOTH the reaped souls AND the Soul Infusion.** T
  (Requiem→Soulrend) *requires* Soul Infusion (in practice, 3 stacks). F *can*
  fire at 1–2 stacks but is CD-limited (20s). ⇒ **the rule: build to 3, then —**
  1. **F if off CD** — Reliquary usually · Tormented Souls for ST + an expected big hit;
  2. **else T** (Requiem→Soulrend) — the macro gates it to the 3-stack, filling F's
     20s cooldown window.
  F and T are rivalrous per 3-stack (F eats the Infusion T needs) → F is the
  priority spender, T covers F's downtime. **Settles F@2-vs-F@3 → F@3** (the old
  spend-at-2 habit was leaving F's value on the table). **This priority IS the
  aura's core decision-flatten:** one input (at 3?), one branch (F up?), one loud
  answer.
- **Deathwind is the sustain BASIS** (player): a rolling 10s AOE self-heal
  (maintain it, don't spot-cast) — the always-on floor, with Tormented Souls the
  situational spike above it. (Corrects an earlier read that put TS as the core.)
- **✓ Bolstered Form cooldown — RESOLVED (60s):** grounded data was right —
  **15s duration / 60s cooldown**. Battlewrath (2026-07-29): *"Reaper is 1min, I
  was confused with the uptime."* So its **+30 RP** is an *occasional* income spike
  tied to a 60s defensive, **not** a rotational refuel — the steady RP fuel is
  Reap+Backswing and Scythe Rush (20s/target).

_No unresolved bar gaps remain (Soul Capture filled by player knowledge above)._
