# Class behavior profiles

A deliberate step back, requested by Battlewrath (2026-07-08): "The way WoW
plays is time old. And right now we're defining the class of behaviours...
I'd say we take some time to understand and document the general behaviour
profiles first that WeakAura is generally used to help track / flatten."
Everything built so far (`stance_loader_icon`, `stack_delta_flash_text`,
`cooldown_tracker_icon`, etc.) was derived one at a time from Necromancer's
own kit. This doc checks that taxonomy against how WeakAuras is actually
used across other classes/roles, using real rotation guides rather than
first-principles guessing - the same "evidenced, not invented" standard as
the rest of this project.

## Sources

Five Wowhead Season-of-Discovery "Rotation, Cooldowns, and Abilities"
guides, chosen to span role and resource-system diversity: a tank, a
healer, and three different DPS resource models (pure caster, combo-point
melee, DoT/pet hybrid).

| Class/role | URL | Why it was picked |
|---|---|---|
| Druid Feral Tank | `.../classes/druid/tank-rotation-cooldowns-abilities-pve` | Battlewrath's own example. Forms (stance-style exclusivity), threat/defensive utility. |
| Priest Healer | `.../classes/priest/healer-rotation-cooldowns-abilities-pve` | Reactive (not fixed-sequence) play, external/ally-targeted cooldowns, compound buff+cooldown fields. |
| Mage DPS | `.../classes/mage/dps-rotation-cooldowns-abilities-pve` | Pure caster, self-risk stacking mechanic, chained cooldowns. |
| Rogue DPS | `.../classes/rogue/dps-rotation-cooldowns-abilities-pve` | Combo-point dual-resource system, externally-sourced procs. |
| Warlock DPS | `.../classes/warlock/dps-rotation-cooldowns-abilities-pve` | Pet class (closest real analog to Necromancer), multi-DoT maintenance, curse-slot exclusivity. |

All five fetched 2026-07-08. Guides are patch 1.15.8 (SoD), not vanilla
3.3.5a - names/numbers won't map onto this server directly, but the
*behavioral shapes* (what a player has to track, and why) are the same
genre of problem this project already solves for, so they're used here as
a taxonomy check, not a source of literal spell data.

## Existing taxonomy (for reference)

From `Docs/WEAKAURA_INDEX.md` + `Weak Auras/README.md`'s Templates section:
`cooldown_tracker`, `proc_alert`, `buff_uptime`, `resource_threshold`,
`missing_buff`, `stance_loader`, `stack_gain_flash`/`stack_delta_flash`,
`player_cast`, `swing_timer`, `backing_plate`, `pet_summon_countdown`,
`enemy_cast`. Each of the archetypes below is checked against this list -
most are direct confirmations; a handful surface a real gap, flagged
explicitly rather than silently built around.

## Confirmed archetypes (existing taxonomy covers these)

**Stance/mode exclusivity** - one icon, N mutually-exclusive self-buffs,
only one true at a time. Druid's Bear/Cat/two Travel forms are the direct
cross-class confirmation of the exact pattern `stance_loader_icon` already
models on Undead Stance (Assault/Protect/Pacify) and Battlewrath's own
hand-built Ward active (Fetid/Bone). Three independent real-game instances
of the same shape now (Druid forms, Undead Stance, Ward active) - strong
enough evidence to call this a genuinely general WoW pattern, not a
Necromancer quirk.

**Debuff/DoT uptime maintenance** - a single debuff kept alive by
periodic recast, `buff_uptime`'s aurabar/countdown variant. Confirmed
independently in three kits with different flavors: Priest's Weakened
Soul-paired PW:Shield spam, Mage's Scorch-maintained Improved Scorch
stack (a target debuff, recast "periodically to keep this debuff up"),
and Warlock's individual DoTs (Corruption/Immolate-equivalent/a curse).
No new mechanism needed - just confirms the trigger choice already made.

**Proc-driven follow-up (self-sourced)** - `proc_alert`. Confirmed by
Mage's Fingers of Frost -> instant Deep Freeze and Priest's Surge of
Light -> instant Flash Heal/Heal. Same shape as anything already flagged
`proc_alert` in the Necromancer index.

**Resource-threshold gating (own power/health)** - `resource_threshold`.
Confirmed by Rogue's energy-gated finisher timing ("if your energy is
close to topping out, send the 4 combo point finishing move") and
Warlock's Life Tap mana-floor management ("the goal is to minimize the
need for Life Taps").

**Reactive/situational utility cooldowns** - still just `cooldown_tracker`
mechanically, but worth naming as its own *behavioral* flavor distinct
from "press this on cooldown as part of the rotation": Druid's Survival
Instincts/Barkskin (panic buttons), Rogue's Vanish (reactive threat-drop),
Warlock's Soulstone (wipe-prevention insurance). These still just need a
plain Cooldown Progress icon - the distinction matters for *where* to put
them (a utility/defensive grouping, not the main Rotation tier row), not
for how to build them.

**Temporary pet/summon tracking** - `pet_summon_countdown`. Priest's
Shadowfiend (2-min cooldown, 2-min duration, no stable per-unit token) is
a fresh cross-role confirmation that this pattern isn't DPS/pet-class
specific - a healer's own kit has the identical shape.

## Gaps surfaced (not yet in the taxonomy)

**1. Stance-loader mechanism generalized to a target/raid debuff, not a
self-buff.** Warlock's curse slot (Curse of Elements/Shadow/Tongues/
Recklessness - "only 1 can be active... at a time," raid-shared, chosen
per comp) is structurally identical to `stance_loader_icon`'s N-mutually-
exclusive-aura2-triggers mechanism, just with `unit=target`/
`debuffType=HARMFUL` instead of `unit=player`/`HELPFUL`. Per the prior
session's build, the schema already exposes `unit` and `debuffType` as
parameters, so this is likely already supported without any code change -
just not yet exercised with those parameter values. Worth a real test
build the next time a class has an analogous shared-debuff-slot mechanic,
rather than assuming it needs new work.

**2. Stance-loader mechanism generalized to a pre-pull "loadout" choice.**
Warlock's pet selection (Succubus for damage vs. Imp/Voidwalker for other
purposes) is chosen once before combat, not toggled reactively mid-fight
the way Undead Stance or a curse slot is. Mechanically it's the same N-
exclusive-aura2 pattern, but the *cadence* is different (set-and-forget
per pull, not a live decision point) - worth remembering this doesn't need
a separate opportunity type, just a note that "stance_loader" covers both
frequently-toggled and rarely-toggled exclusive states equally well.

**3. Externally-sourced procs.** Rogue's Honor Among Thieves grants
*you* a combo point when *any party member* lands a crit - the
proc-triggering event isn't the tracked player's own cast/aura at all.
Every `proc_alert` built so far (and the mechanism as documented) assumes
the combat-log filter is scoped to the player being tracked. This needs a
combat-log trigger scoped to group-wide events instead of `ownOnly` - not
needed for Necromancer today (no comparable kit mechanic found yet), but
flagged so a future class doesn't get force-fit into the self-sourced
assumption.

**4. Target-health execute phase gating - confirmed valid (Battlewrath,
2026-07-08).** Warlock's explicit "Under 35% Health" rotation table and
Mage's AoE-rotation enemy-count branching are both phase-style triggers
keyed to the *target's* or *encounter's* state, not the player's own
Power/Health. This is the standard WoW "execute phase" pattern (a
rotation/priority change once the target crosses a fixed health
percentage) and Battlewrath confirmed it directly: "highlighting a user is
in execute phase on their target is useful." `resource_threshold` as
documented ("Power/Health status trigger... unit resource, not
spell-based") reads as player-self-scoped today. A target-health variant
(`unit=target`, same Health trigger type already confirmed in
`CAPABILITY_INVENTORY.md`'s trigger catalog) would be a straightforward
extension, not a new mechanism - just not yet built or named. This is the
strongest gap in the list - worth an actual `execute_phase` opportunity
type (or a `resource_threshold` variant with `unit` exposed as a
parameter) the next time a class kit has an execute-phase ability.
Enemy-count gating (2+/8+ targets) is a separate, harder case - no
single-unit trigger covers "how many enemies are nearby" - and stays a
lower priority since nothing in Necromancer's kit needs it yet.

**5. Danger/ceiling stacks - no "approaching a harmful cap" flavor.**
Mage's Balefire Bolt stacks up to 5, and hitting 5 while it's still active
kills the caster outright ("if your Spirit reaches 0... you will
immediately die"). Both `stack_gain_flash_text` and `stack_delta_flash_text`
are built to *celebrate* a stack gain (a "+N" flash) - neither
distinguishes a beneficial stack from one nearing a self-damaging ceiling.
A real fix would be cheap (the same delta-flash mechanism, with a color/
urgency change keyed to `current_stacks >= max_stacks - 1`) but nothing in
Necromancer's kit needs it today, so it's filed as a future variant, not
built speculatively.

**6. Compound buff-duration + own-recast-cooldown on the same spell.**
Priest's Fear Ward has both a 10-minute immunity *duration* and its own
30-second *recast* cooldown - two independent timers on one spell, not
one or the other. This is the same shape as this project's existing
glow-source/compound-icon idea (an icon that shows a cooldown sweep AND a
separate active/consumed overlay) - not a new mechanism, but a second
real-world confirmation that the compound pattern is common enough to be
worth keeping as a first-class option rather than a one-off.

**7. Chained cooldowns - reclassified as self-resolving, not a gap
(Battlewrath, 2026-07-08).** Mage's Icy Veins explicitly resets the
cooldown on Combustion/Fire Blast-equivalent mid-fight ("Icy Veins, which
finishes the cooldown on all of your Frost spells"). Originally filed here
as a "pair these two icons in layout" note, but Battlewrath's correction
goes further: **the "is usable" read on a `cooldown_tracker` icon comes
straight from the game's own live cooldown state, so it's already correct
regardless of *why* the cooldown cleared** - a reset from an Icy-Veins-
style effect shows up exactly the same as the cooldown simply finishing
naturally. No new mechanism, no special-casing "this ability's cooldown
can be reset early" - the icon just is right, for free. The one real
design decision is which ability to build a tracker for when the two
aren't both already on the HUD: "If those skills have a reset proc, and
are a part of the rotation units, then they'd be shown as available
again. If their not tracked, in the proc units, we surface the master
proc in that chain. Then it falls back on the user and their hot bar."
In other words - if the reset *target* (Combustion) is already a tracked
Rotation icon, nothing else is needed. If it isn't tracked, track the
*resetting* ability (Icy Veins) instead, since that's the actionable
moment worth surfacing; anything further down the chain is left to the
player's own hotbar and game knowledge, not modeled explicitly. Downgraded
from "gap" to a build-prioritization rule.

**8. External/ally-targeted cooldowns.** Priest's Power Infusion is cast
onto an ally, not the priest; Warlock's Soulstone/Healthstone are handed
to specific raid members. The cooldown itself is still the caster's own
(a plain `cooldown_tracker` covers "is Power Infusion off cooldown for
me"), so this isn't a gap in the trigger mechanism - just a reminder that
"whose cooldown is this" and "who receives the effect" are different
questions, and only the former is what WeakAuras needs to answer.

## What this means for Necromancer specifically

Nothing above forces new build work right now - Necromancer's own kit
doesn't currently have a curse-slot analog, a combo-point resource, an
externally-sourced proc, a target-health-gated rotation swap, or a
Balefire-Bolt-style danger stack. The value of this pass is confirming
the *existing* taxonomy (four original opportunity types + the six
2026-07-04 extensions) already covers the large majority of real
cross-class WeakAuras use, and having named, sourced answers ready for the
day a Necromancer mechanic (or a second class) actually needs one of the
seven remaining gaps above, instead of re-deriving them from scratch under
time pressure. Of those seven, #4 (execute phase) is the one Battlewrath
flagged as most worth building for real next; #7 (chained cooldowns) was
reviewed and downgraded to "no work needed" - self-resolving off the
existing `cooldown_tracker` mechanism.

## Changelog

- 2026-07-08: initial version, five guides (Druid Feral Tank, Priest
  Healer, Mage DPS, Rogue DPS, Warlock DPS), cross-referenced against
  `Docs/WEAKAURA_INDEX.md` + `Weak Auras/README.md`'s taxonomy. Eight gaps
  identified, none built - documentation-only pass per Battlewrath's
  explicit "step back... understand and document... first" framing.
- 2026-07-08 (second pass, same day): Battlewrath reviewed the eight gaps.
  #4 (target-health execute phase) confirmed as genuinely valid and worth
  pursuing - "highlighting a user is in execute phase on their target is
  useful." #7 (chained cooldowns) reclassified as self-resolving, not a
  gap at all: a tracked ability's own "is usable" read already reflects
  any cooldown reset regardless of source, so the only real design
  question is which ability to build a tracker for when the reset-target
  isn't already tracked (build the resetting/"master" ability instead,
  and leave the rest to the player's hotbar) - not a technical gap, a
  build-prioritization rule. Seven gaps remain open.
