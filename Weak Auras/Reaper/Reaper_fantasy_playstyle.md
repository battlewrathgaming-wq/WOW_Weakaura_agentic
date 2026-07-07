# Reaper - fantasy & playstyle

Single source per class, added 2026-07-10 per Battlewrath's request, same
purpose as `Necromancer/Necromancer_fantasy_playstyle.md` - what this
class is and what matters to it, for a class-implementer agent (see
`../AGENT_ROLES.md`) to reason against when prioritizing what to build
next. Sourced from `Input/reaper_talents.json` (real talents, 4 trees:
Class/Domination/Harvest/Soul) and `Outputs/readouts/reaper_readout.md` -
not invented.

## What the class is

A melee soul-harvester, own class (confirmed live: a real captured
WeakAuras Load-tab value shows `class.single: "REAPER"`, not a Necromancer
spec - see `BUILD_METHOD.md`). Where Necromancer expresses power through
an army it commands, Reaper expresses it directly through its own weapon:
every spec revolves around melee strikes that generate and spend a souls
economy. **No Mana at all** - per Battlewrath, "this class only uses souls
and runic power" - a resource model built from the ground up around melee
combat, not a caster's mana pool.

## Resource economy (shared across all 3 specs - already built)

- **Runic Power** - spent through melee abilities (`Murder`, `Slaughter`,
  `Dirge`, `Soul Strike`, `Reap`, etc.), same tracked bar mechanism as
  Necromancer's (`resource_threshold_aurabar`, `Tiers/resources_base.py`).
- **Soul Fragment** (805077) - stacks to 3, sub-3s time-to-live per
  fragment, converts to 1 Reaped Soul at 3 stacks. **Talent-gated, not
  baseline** (confirmed `isBaseAbilityInTree: false`) - its two known
  generation sources sit in DIFFERENT specs (Domination's `Soulsight`,
  Harvest's `Shudder Scythe`), meaning a given build may not have this
  mechanic active at all. Tracked (`buff_uptime_aurabar` with
  `show_when_missing`/`show_stacks`) - the ONLY tier-1 tracker built so
  far that's genuinely conditional on spec/talent choice rather than
  universally present.
- **Reaped Soul** - the capped resource Soul Fragments feed into. Already
  has its own native in-game UI element - deliberately **NOT tracked** by
  this project, same "don't compete with a native display" principle as
  Necromancer's Life Force.

**What this means for the UI**: Resources tier tracks Runic Power + Soul
Fragment (the thing with no native display); Reaped Soul itself stays
untouched. Because Soul Fragment generation is talent-gated and split
across specs, its `show_when_missing` footprint-preservation isn't a
nice-to-have polish item - it's load-bearing: an un-talented character or
a Soul-spec character genuinely may never generate one, and the bar still
needs to hold its Resources-tier slot regardless.

## Class tree (baseline, available to every spec)

Confirmed via `Input/reaper_talents.json`'s `"tree": "Class"` entries:
`Wraithblade` (generates 3 Reaped Souls directly), `Scythe Rush` (gap
closer, generates Runic Power), `Tormented Souls` (consumes Reaped Souls
for a Runic Power/damage effect), `Veilwalk`/`Spectre Stride` (mobility
kit). A melee weapon-swing-plus-soul-consumption loop available to every
spec - the thing that makes this class feel like a scythe-wielding melee
class first, regardless of spec.

## Specs

### Domination - the tanky/control spec

Talents: `Behemoth` (+20% Stamina, +Armor penetration), `Bolstered Form`
(temporary buffed state, +30 Runic Power, +Armor), `Dreadknight` (+armor
from mail/plate), `Empyrean Fortitude` (parrying generates 2 Runic Power),
`Dreadwake` (AoE cone, generates 1 Reaped Soul). Also the tree that
contains `Soulsight`, one of the two confirmed Soul Fragment generation
sources.

**Identity**: durability/control - stacks defensive stats and ties Runic
Power generation to mitigation (parrying), rather than pure offense.

**What this means for the UI**: this spec cares about uptime of its
defensive cooldown (`Bolstered Form`) and mitigation-triggered resource
generation more than raw damage procs. It's also the spec where Soul
Fragment tracking is most directly load-bearing, since `Soulsight` lives
here.

### Harvest - the sustain/lifesteal spec

Talents: `Harvester` (passive self-heal for 15% of all damage dealt),
`Doomrend`, `Crow's Harvest`, `Slaughter` (generates 1 Reaped Soul),
`Shudder Scythe` (upgrades `Murder`, costs more Runic Power but generates
Soul Fragments - the tree's own confirmed generation source). Damage
output doubles as self-sustain throughout this tree.

**Identity**: damage-as-healing sustain - its normal rotation naturally
feeds the Soul Fragment economy as a side effect of doing damage, not as
a deliberate resource-management minigame.

**What this means for the UI**: Soul Fragment generation/uptime tracking
matters most directly here (this spec's rotation IS the generation
source), with self-heal uptime as a secondary, lower-priority signal.

### Soul - the dual-wield burst spec

Talents: `Dirge` (generates 2 Soul Fragments, explicitly dagger-flavored -
"130% [damage] if a dagger"), `Ghostly Weapon` (temporary weapon-imbue
proc), `Deathchaser`, `Soulforged Weaponry` (off-hand-focused, dual-wield
auto-attacks). Weapon-choice-sensitive text (dagger bonus) is unique to
this spec among the three.

**Identity**: dual-wield-specific burst/proc spec - timing a temporary
weapon-imbue buff and favoring a specific weapon type (daggers) for bonus
effect.

**What this means for the UI**: `buff_uptime`-style tracking on
`Ghostly Weapon`'s imbue window is the natural build target here, plus
Soul Fragment generation via `Dirge`. A weapon-type-conditional check
(dagger equipped or not) isn't built anywhere in this project yet - flag
as a possible future primitive if this spec's UI is ever prioritized (see
`../AGENT_ROLES.md`'s escalation rule - this would be a genuinely new
mechanic, not an existing REGISTRY entry).

## Net takeaway for a class-implementer agent

- The Resources tier (Runic Power/Soul Fragment/Cast Bar/Swing Timer/
  divider) is shared across all 3 specs - already built and proven, reuse
  as-is.
- Soul Fragment's `show_when_missing` isn't cosmetic - it's the direct
  consequence of generation being talent-gated and split across two of
  the three specs (Domination, Harvest). Any future Reaper content that
  reads Soul Fragment state should assume it may be absent by design, not
  treat absence as a bug.
- Priority beyond Resources diverges by spec: Domination wants
  defensive-cooldown/mitigation-triggered-resource tracking, Harvest wants
  its own Soul-Fragment-generation rotation surfaced (since that spec's
  kit feeds the resource directly), Soul wants weapon-imbue-buff tracking
  plus a not-yet-built weapon-type check.
