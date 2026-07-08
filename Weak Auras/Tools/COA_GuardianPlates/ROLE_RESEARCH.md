# Phase 2: per-role nameplate info needs (research findings)

Community consensus on what tanks/healers/DPS actually rely on from
nameplates, gathered to sanity-check the Phase 1 capability inventory before
building anything. Sources are mostly modern-retail-era guides (nameplate
mechanics have been stable in shape since Legion regardless of expansion,
and WotLK/Ascension has no native filtering at all, so the underlying
role-based reasoning transfers even though none of this is Wrath-specific).

## Consensus by role

**Tank** - wants the most information of any role, specifically: aggro/
threat state (color or a dedicated indicator) as the single most important
signal, health values precise enough to make cooldown-timing decisions (not
just percentage), and full cast-bar visibility across every enemy in the
pull (since a tank is the one expected to interrupt or react to any
dangerous cast, not just casts on themselves).

**Healer** - the hardest role to serve well, and the one filtering benefits
most, because they're the only role routinely watching *both* enemy and
friendly nameplates simultaneously while their attention is mostly on raid/
party frames. The standard experienced pattern (repeated in every source
found) is: learn an encounter once, then explicitly hide every debuff that's
just background noise (permanent DoTs, unavoidable raid-wide damage, "you
already soaked" markers) so only the few debuffs that require *action*
(interrupt, dispel, get-out) stay visible. Community guidance leans toward
healers minimizing reliance on friendly nameplates for health tracking at
all (raid frames do that job better) and using nameplates mainly for enemy
cast-bar/dispel-timing information.

**DPS** - the simplest needs: threat awareness (so they know when they're
about to pull aggro, without needing a full threat meter), health percentage
for execute-window abilities, and cast-bar visibility for interrupt
rotations where the group shares interrupt duty.

## The core theme, repeated everywhere: filtering > adding

Every source frames the actual skill as *curation*, not information density.
The named examples of "noise that shouldn't be showing" are telling: a
permanent DoT from a talent that never needs refreshing, a raid-wide damage
aura every player already has and can't avoid, a "can't soak again yet"
marker in a pre-assigned rotation. In each case the debuff is real and
correctly displayed, but has zero decision value once you know the fight -
it just adds visual load. This directly matches Battlewrath's own framing at
the start of this task ("information overload... in stead of 'what does a
healer need to know'").

## Long-standing prior art for combat-log-based role detection (PvP)

H.H.T.D. ("Healers Have To Die," 7.8M downloads, in continuous
development for over a decade, still updated for the current retail client)
is a mature, widely-used addon built entirely around one idea: watch the
combat log for actual heal casts within the last 60 seconds, rank who's
"currently healing" by a configurable threshold, and mark their nameplate
with a class-colored symbol. This validates the same reactive detection
shape TurboPlates' `HealerDetection.lua` uses (see Phase 1 inventory) as a
legitimate, long-proven pattern for identifying an active healer without
needing spec/talent introspection - useful if GuardianPlates ever adds its
own healer-marking capability, PvP or PvE.

## What this means for Phase 3 (GuardianPlates)

Given the user's explicit scope for this pass (per-character selection
only, no profiles/specs, "very light versions," per-capability on/off), the
research suggests three build candidates, roughly in priority order:

1. **Tank-mode-style health-bar color differentiation** (holding threat /
   losing it / no threat) - the single most load-bearing piece of info for
   the tank role, confirmed by every source, and already scoped in Phase 1
   from both TurboPlates and Kui_Nameplates as a well-proven tri-state
   (Off/Smart/Always) toggle.
2. **A small, fixed "needs action" debuff/cast highlight** - not a full aura
   tracker, just picking out the couple of mechanic classes every source
   flags as decision-relevant (an interruptible cast, a CC effect) rather
   than showing every buff/debuff. This is squarely a curation feature, not
   an information-density feature - matches the "avoid overload" goal
   directly, and reuses the "fixed small category set" shape from
   TurboPlates' TurboDebuffs (Phase 1) rather than its full 10-category
   version.
3. **Threat/aggro visual cue for DPS** (not just tanks) - cheap to add once
   (1) exists, and every DPS-focused source independently named this as
   wanted.

Deliberately not pursuing, per research + explicit user scope: full buff/
debuff trackers, healer-marking (PvP-only use case, out of scope for a PvE-
focused low-risk theorycraft addon), personal resource bars, combo points -
these either need infrastructure this pass isn't scoped for (spec/profile
awareness) or duplicate what other installed addons already do well.

Sources:
- [WoW Midnight Nameplates Guide - All Settings & Addons](https://boosting-ground.com/wow-boosting/guides/leveling-guides/wow-midnight-nameplates-settings-addons)
- [H.H.T.D. - CurseForge](https://www.curseforge.com/wow/addons/h-h-t-d)
- [Threat Plates - CurseForge](https://www.curseforge.com/wow/addons/tidy-plates-threat-plates)
- [SimpleClassicThreatNameplates - CurseForge](https://www.curseforge.com/wow/addons/simpleclassicthreatnameplates)
