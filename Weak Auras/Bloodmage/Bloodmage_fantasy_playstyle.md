# Bloodmage - fantasy & playstyle

Single source per class, same purpose as
`Necromancer/Necromancer_fantasy_playstyle.md` and
`Reaper/Reaper_fantasy_playstyle.md` - what this class is and what matters
to it, for a class-implementer agent (see `../AGENT_ROLES.md`) to reason
against when prioritizing what to build. Written FIRST per that doc's
step-1 ordering, before `spell_index.md`/`slot_assignment.md`. Sourced from
`Input/bloodmage_talents.json`, `Outputs/readouts/bloodmage_readout.md`,
and `Outputs/skill_indices/bloodmage_skill_index.json` (123 skills) - not
invented.

## Player intent & role (Battlewrath, 2026-07-07)

Battlewrath's own party composition and direction for this character: they
already run a DPS (Necromancer) and a tank (Reaper), so **Bloodmage fills
the SUPPORT slot, played as Fleshweaver, with a PvP focus.** This is the
steer to prioritize the UI against - not raw class completeness:

- **Fleshweaver is the spec.** Pooled Vitality (the 10-stack support/
  sustain economy) is the identity; the group-heal payoffs (`Blood
  Rituals`, `Vitality For Later`, `Hemoglobe`) and the `Vampyr's Rage` /
  `Sanguine Mend` sustain hang off it. The other three specs (Accursed /
  Eternal / Sanguine) drop down the priority list unless Battlewrath
  revisits.
- **PvP focus reshapes what matters** vs. a PvE support build: reacting to
  ENEMY casts (interrupt / peel windows - `enemy_cast_aurabar` is an
  existing REGISTRY capability), defensive/shield uptime while focused
  (`Blood Shield` / `Vital Shield`, the spend-life-for-mitigation half of
  the kit), self-sustain leech awareness while spending HP under pressure,
  and low-HP proc/CC windows (`Wretched` / `Essence Harvester`-style
  below-35% triggers - flagged as a possible future primitive). Ally-target
  healing output matters more than personal DPS uptime.
- **Health-as-resource management is higher-stakes in PvP** - spending into
  the bottom of the HP Reserve bar while being focused is the real risk the
  top-50%-100% clamp is meant to communicate; that framing gets more
  load-bearing here than it would for a PvE bruiser.

**Roster context** (Battlewrath, 2026-07-07): all three of Battlewrath's
characters are self-sufficient, solo-friendly archetypes - Necromancer wins
solo through an army (pets), Reaper through durability (tank), and Bloodmage
through a self-sustaining **DPS/heal hybrid** kit (deal damage, heal it back
via the spend-life-then-leech loop). So **self-sustain is a first-class part
of Bloodmage's identity, co-equal with ally support** - it heals itself solo
AND supports allies when grouped / in PvP. Practical consequence for build
priority: own-HP / leech / self-heal-uptime awareness is as build-worthy as
ally-target tooling (e.g. the heal suggester,
`CAPABILITY_REQUEST_heal_suggester.md`) - which one leads depends on whether
the moment is solo or grouped, so ideally the UI serves both without
over-committing to either.

## Design principle: flatten or enrich, never replicate (Battlewrath, 2026-07-07)

Where the game already has a native UI for something, DO NOT rebuild it.
Battlewrath's rule: "The game already has a native UI for showing the
stacks. So our work is to either flatten the information, or enrich it. But
not replicate it." This is the same call already established for
Necromancer's Life Force and Reaper's Reaped Soul (both left untracked -
native UI covers them). Two allowed moves:

- **FLATTEN** - turn information you currently have to READ into a state you
  can GLANCE. Not "you have N stacks" (native already says that), but the
  single actionable moment distilled: "at dump threshold" / "empowered
  now" as one binary/threshold signal. Reduces cognitive load, which
  matters most in PvP where attention is scarce.
- **ENRICH** - surface what native does NOT show. The proven precedent is
  Reaper's Soul Infusion: rather than duplicate the Reaped Soul count, it
  put a subtle "empowered" texture on the SPENDER icon (`glow_source`'s
  `external_empower`). The Fleshweaver equivalent: at 10 Pooled Vitality
  stacks, Mortal Form Rage spells are empowered - mark THAT ability's icon
  as empowered, not a redundant stack bar. Other enrich candidates native
  likely omits: a decay/expiry warning, or whether a consume payoff
  (`Vitality For Later` / `Hemoglobe`) is worth spending now.

This principle applies to every spec's stacking sub-resource below (Blood
Shard, Thirst) and to any future element - check whether native UI already
covers the raw value before building a tracker for it.

## What the class is

A blood-magic caster/melee hybrid that pays for its power in its own life.
The class's signature is that many of its strongest spells **cost health**
rather than mana - confirmed directly in the skill index: talents
explicitly reference "spells that cost health" (`Pooled Vitality`,
`Gore Barrage`, `Barely Human`), and several talents exist only to REMOVE
the health cost of specific spells (`One Man's Curse...` removes Accursed
Form's health cost, `Crimson Etchings` removes Blood/Vital Shield's). The
class then buys that health back through leech, self-heal procs, and shield
absorbs - a deliberate spend-life-then-recover-life loop, not a static
health pool. `Nightmare` makes it literal: "abilities that cost Rage now
consume 2% of your maximum health to damage or heal your target for an
additional 10%." Battlewrath's original one-line steer ("uses their own
life as a resource as well as mana and such") is confirmed by source, with
one correction below: the second resource is Rage, not Mana.

## Resource economy (the confirmed, universal part)

Two resources are present in every spec and are what the Resources tier is
built around:

- **Health-as-resource (the class's core meter).** Not just a survival
  bar - it is spent as fuel and recovered as reward. This is the "primary
  resource bar" role the mask (`ELEMENT_INVENTORY.md` Row C, `Class
  resource`) reserves for "the class's core meter." Built via
  `Tiers/resources_base.py`'s `health_slot(...)` as a bar clamped to the
  **top 50%-100% of max HP** - i.e. "the health you can afford to spend,"
  full at 100%, empty at 50%. This is the exact mechanic that was
  formalized into a core capability specifically for this class
  (`BUILD_METHOD.md`'s "FORMALIZED as a core capability" - native `Health`
  unit trigger + the aurabar region's `adjustedMin`/`adjustedMax` percent
  clamp, live-confirmed by a real Battlewrath export
  `Bloodmage_hp_resouece_50-100%`).
- **Rage (secondary resource).** Confirmed NOT Mana (Battlewrath: "the
  other energy is rage, not mana"; only two "Mana" strings appear in the
  entire skill index and both are the word "emanate"). Bloodmage uses **no
  Mana and only minimal Rage** (Battlewrath, 2026-07-07) - its economy is
  really health-first, with Rage a light secondary. Rage is generated by
  auto-attacks and damage dealt (`Bloody Claws`: "generate 20% increased
  Rage from damage dealt and critical strikes with auto attacks") and spent
  by abilities (33 talent references to Rage cost/gen). Standard WoW
  `PowerType` = Rage (1), built via `resource_slot(..., POWERTYPE_RAGE,
  ...)` at the mask's secondary-resource slot (`Class energy`, Row D).

**No Mana bar at all** - like Reaper, Bloodmage's Resources tier has no
Mana slot; the primary-resource slot holds Health instead.

## Class tree (baseline, available to every spec)

Confirmed via `"tree": "Class"` talent entries in the skill index. The
shared blood-mage baseline every spec inherits:
- **Defensive shields that (by default) cost health**: `Blood Shield` /
  `Vital Shield` (`Crimson Etchings`, `Bloodbound Etchings` +50%,
  `Coagulation`, `Visceral Magic`) - the spend-life-for-mitigation half of
  the loop.
- **Self-sustain / life recovery**: `Sanguine Mend` (heal, `Saturating
  Sutures` can make it free via proc), `Blood Runs Cold` (+20% heal on
  Blood Pact), `Vampiric Pools` (`Liquify` heals in an AoE),
  `Bloodleaper` (Lunge CDR), `Fleshcraft` (Sated heal).
- **Mobility / utility**: `Blood Trails` / `Trail of Blood` (movement-speed
  pools), `Lunge` (gap closer), `Predator` (AoE cleave on several spells).
- **`Cursed Form`** - a baseline transformable combat state each spec
  reshapes into its own signature form (Accursed Form, Eternal Curse,
  etc.). This is the class's "shapeshift-ish" identity hook.

The through-line: a melee-capable blood caster who trades health for
shields/damage and claws it back through leech and self-heal - felt the
same in every spec, before spec talents specialize it.

## Specs

Four specs, confirmed via `Outputs/readouts/bloodmage_readout.md`. Each
folds the Class tree in. Below is each spec's identity and what a future
UI tier (beyond Resources) would most want to surface for it.

### Accursed - the melee beast-form bruiser

Talents center on `Cursed Form` -> `Accursed Form`: a 30-second demonic
transformation (`Accursed Form`: "+50% of your Agility as attack power")
that costs health to enter (`One Man's Curse...` removes that cost and
instead heals 15% max HP on entry). Kit is bleed/execute melee -
`Bloodfang Bite`, `Reave`, `Aortic Assault` (a 3s recurring strike),
`Veinburst`, `Hemoburst` (execute, guaranteed crit vs. bleeding targets).
Has its own stacking sub-resource: **Blood Shard** (`Battleweaver`:
"generate 1 Blood Shard... up to 8"; `Blood Shards` passive stacks
DMG/CRIT), consumed/launched by `Bloodbolt`.

**UI priority (future tiers):** Accursed Form uptime/remaining (the whole
spec keys off being in-form), Blood Shard state, and execute-window
awareness (targets below 35% - `Blood Scent`/`Hemoburst`). All are
spec/talent-gated, not universal. Check native UI before building a Blood
Shard counter (flatten/enrich, not replicate - see the design principle).

### Eternal - the summoner / pack-master

The pet spec. `Call of the Darkwing`, `Shadow Bats`, `Howl`, `Ravenous
Strike`, `Shadow Colony` are SUMMON-tagged; `Monstrous Hunger`,
`Petrified Legions`, `Packleader`, `Grim Omen` all buff summoned creatures.
Signature form is **Eternal Curse** (a baseline-in-tree ability,
`isBaseAbilityInTree: true`, +Stamina/+AP from Agility & Strength via
`Vitality`/`Feral Strength`). Plays as a durable blood-beastmaster who
fights alongside summoned darkwings/bats.

**UI priority (future tiers):** summon presence/uptime (a
`minion_presence_icon`-shaped problem, already proven on Necromancer -
note its documented count-accuracy limitation for 2+ same-type pets),
Eternal Curse form uptime, `Howl`/`Call of the Darkwing` cooldowns.

### Fleshweaver - the Pooled Vitality sustain/support spec

The stacking-resource spec built directly on the health-cost mechanic.
**Pooled Vitality** (`Starting Talent`, stacks to 10) is granted by
"spells that cost health"; at 10 stacks it empowers Mortal Form Rage
spells (`Unchained`/`Pooled Vitality` on `Mortal Form`). A dense web of
talents keys off the stack count - `Gruesome Rituals` (+1% damage per
stack), `Organ Orbs` (+3% Spirit per stack), `Acquired Taste` (+stacks
from Infuse/Vampyr's Kiss), `Vitality For Later`/`Hemoglobe` (raid heals
on consume). Also has `Vampyr's Rage` (`Black Heart`: regen 20% max Rage)
and heavy `Blood Rituals` group-healing. This is the healer/support-leaning
spec whose whole rotation is a stack-management minigame feeding both its
own damage and raid healing. **This is Battlewrath's chosen spec (see
"Player intent & role" above).**

**UI priority (future tiers):** the Pooled Vitality economy is the spec -
BUT the raw stack count has a native in-game UI, so per the "flatten or
enrich, never replicate" design principle above, DO NOT build a plain stack
counter. The real openings are: FLATTEN to a single "at 10 / empowered /
ready to dump" glance signal, or ENRICH by marking the empowered state on
the Mortal Form Rage ability icon it gates (`glow_source`'s
`external_empower`, proven on Reaper's Soul Infusion) and/or a
decay/consume-payoff-window cue native doesn't show. Confirm exactly what
the native UI already displays before scoping which of these adds value.

### Sanguine - the Thirst vampire-lord

The other stacking-resource spec, built on **Thirst** (`Starting Talent`,
`isBaseAbilityInTree: true`). `Vampiric Fang` "Expends Thirst Stacks"
(damage +10% per stack, "Clears Insatiable and Thirst stacks"), and Thirst
stacks reduce cast times / increase damage of `Valanar's Vengeance` and
`Keleseth's Calamity`. `Wretched` (from `Essence Harvester`, triggered by
being struck below 35% HP) "generates 10 Rage and 1 stack of Thirst every
1 sec." Flavored as the Blood-Prince-Council vampire caster
(`Taldaram's Torment`, `Keleseth's Calamity`, `Valanar's Vengeance`,
`Blood Prince's Command`). A build-and-dump caster: stack Thirst, then
spend it in a `Vampiric Fang` burst.

**UI priority (future tiers):** the Thirst dump window (are we at enough
stacks to spend?) and the low-HP `Wretched`/`Essence Harvester` proc
awareness (a below-35%-HP trigger). Same flatten/enrich-not-replicate
caveat as Pooled Vitality - check native UI before building any raw Thirst
counter; the actionable "ready to dump" state is the flatten play.

## Net takeaway for a class-implementer agent

- **Resources tier (build now, all proven):** Health-as-resource at the
  primary slot via `health_slot("HP Reserve", 50, 100, CLASS_RESOURCE_POS,
  bar_color=ACCENT_COLOR)` + Rage at the secondary slot via
  `resource_slot(..., POWERTYPE_RAGE, CLASS_ENERGY_POS)` + Cast Bar +
  Swing Timer + accent divider. Every piece is an already-proven
  `resources_base.py` builder; the health bar is the one this class exists
  to consume, and it was formalized as a core capability BEFORE this pass
  precisely so it could be reused here with no escalation.
- **Priority order is set by role, then filtered by "flatten or enrich,
  never replicate"** (see both sections above): Fleshweaver support/PvP
  first, but NOT a raw Pooled Vitality stack counter (native UI exists).
  The real next builds are the flatten/enrich plays - an "empowered / ready
  to dump" glance signal and/or an `external_empower` mark on the gated
  ability icon - plus PvP-support signals (enemy-cast reactions via
  `enemy_cast_aurabar`, shield/defensive uptime). Self-sustain awareness
  (own-HP / leech) is co-equal, since the class is also a solo-friendly
  self-sustaining hybrid (see "Roster context"). Confirm what native
  already shows before scoping.
- **Beyond that, priority diverges hard by spec** and every divergence is a
  stacking sub-resource or a form uptime: Accursed = Blood Shard + Accursed
  Form, Eternal = summon presence + Eternal Curse, Fleshweaver = Pooled
  Vitality, Sanguine = Thirst. The stacking ones all carry the same
  native-UI check (flatten/enrich, not replicate); the form/presence ones
  (Accursed Form, Eternal Curse, summons) are genuine uptime trackers
  proven elsewhere (`buff_uptime`, `minion_presence_icon`).
- **No new primitive is needed for the Resources tier.** If a later tier
  needs a below-35%-HP execute/proc trigger (Accursed `Blood Scent`,
  Sanguine `Essence Harvester`) or an "empowered at N stacks" threshold on
  a stack bar, check the REGISTRY/fragments first and raise a gap report
  per `../AGENT_ROLES.md` rather than improvising - those are not scoped or
  confirmed here.
