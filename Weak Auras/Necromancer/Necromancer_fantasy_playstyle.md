# Necromancer - fantasy & playstyle

Single source per class, added 2026-07-10 per Battlewrath's request, to sit
alongside `spell_index.md`/`slot_assignment.md`/`BUILD_METHOD.md` as the
place a class-implementer agent (see `../AGENT_ROLES.md`) goes to reason
about **what this class is and what matters to it** - not just which spell
ID goes in which slot, but why one slot should outrank another when
choosing what to build next. Sourced from `Input/necromancer_talents.json`
(160 real talents, 4 trees: Class/Animation/Death/Rime) and
`Outputs/readouts/necromancer_readout.md` - not invented, same
evidence-only discipline as every other doc in this folder.

## What the class is

An undead-summoning caster/commander. The throughline across every spec is
raising minions and spending resources to make them act, not a personal
weapon-swing rotation - `Command` family spells (`Command: Hook`, etc.) are
a client-to-server call making every currently-summoned minion each cast
its own version of the command. The class's power is expressed through its
army, not its own hands.

## Resource economy (shared across all 3 specs - already built)

Three separate resources, each doing a different job:

- **Mana** - the budget resource. Funds `Raise`/`Animate` casts and the
  core caster kit. Tracked (`resource_threshold_aurabar`, Resources tier).
- **Runic Power** - the spend resource. `Command` spells consume it to
  make already-summoned minions act. Tracked (`resource_threshold_aurabar`,
  same tier, shared builder in `Tiers/resources_base.py`).
- **Life Force** - a third, capped resource gating how many minions can be
  fielded at once (confirmed per-minion costs: Abomination 3, Gargoyle 3,
  Banshee 2, Skeletal Mage 1, Ghoul 1). Deliberately **NOT tracked** by
  this project - it already has its own native in-game UI element
  (`BUILD_METHOD.md`'s "Open items"). Its only WeakAuras treatment is a
  transient combat-text alert on budget change, not a persistent bar.

**What this means for the UI:** the Resources tier's whole job is
answering "can I afford to keep my army up and my spells flowing" - Mana +
Runic Power are the two tracked bars. Don't add a Life Force bar; that's
solved ground, re-litigating it duplicates a native display.

## Class tree (baseline, available to every spec)

Confirmed via `Input/necromancer_talents.json`'s `"tree": "Class"` entries:
`Raise: Abomination`, `Command: Hook`, `Glacial Tap` (instant 30 Runic
Power), `Fetid Ward`, `Ner'zhul's Blessing` (+20% max Runic Power),
`Phylactery` (death-prevention cooldown), `Life For Power` (absorb
shield from healing taken). This is the always-available minion-raising +
Command-spending loop plus a couple of defensive/utility tools - anything
built here benefits all 3 specs equally.

## Specs

### Animation - the summoner spec

Talents: `Animate: Skeletal Archer`, `Raise: Ghoul`, `Animate: Tomb King`,
`Animate: Bone Wraith`, `Scourge Disciple` (+5% haste per active Skeletal
Archer), `Summoning Prodigy`/`Summoner` (minion duration/cooldown).

**Identity**: "go wide" - fields the widest variety and count of minions
simultaneously. Power scales with how many/which pets are currently up,
not with optimizing a personal rotation.

**What this means for spell allocation**: minion PRESENCE tracking is the
single highest-value thing to build for this spec - already exists
(`minion_presence_icon`, proven on Abomination/Skeleton/Crypt Keeper).
Life Force budget awareness (how much army you can still afford) is the
natural second priority. Individual rotational-ability icons matter less
here than for the other two specs.

### Death - the disease/DoT spec

Talents: `Flesh to Worms`, `Crypt Plague`, `Plague of Undeath`,
`Virulency` (refresh + copy all diseases onto target), `Damnation`
(+5% Shadow damage, doubled below 35% target health), `Creeping Crypt`
(crit vs. low-health targets).

**Identity**: a disease-stacking, execute-scaling caster - success depends
on disease uptime and target-health thresholds, not minion count.

**What this means for the UI**: `buff_uptime`-style tracking on the
diseases themselves (Flesh to Worms/Plague of Undeath uptime) would
matter far more here than minion tracking does. A target-health-threshold
check (is the target below 35%, i.e. Damnation/Creeping Crypt's execute
window) is a named, still-open gap in `CLASS_BEHAVIOR_PROFILES.md` - this
spec is exactly where it would first get used.

### Rime - the frost burst spec

Talents: `Ice Barrage`, `Glacial Impact` (requires a Frozen target),
`Refreshing Chill` (proc: resets Ice Barrage CD + empowers next cast),
`Runic Reservoir` (+15 max Runic Power), `Frigid Death`.

**Identity**: proc-driven frost burst, with abilities explicitly
conditional on target state (`Glacial Impact`'s "Requires Frozen Target").

**What this means for the UI**: `glow_source`/`proc_alert` tier matters
most here (Refreshing Chill-style procs empowering the next cast), plus a
"target is Frozen" state check - another named open gap
(`CLASS_BEHAVIOR_PROFILES.md`'s "externally-sourced procs" /
target-state-conditional row), not yet built for any class.

## Net takeaway for a class-implementer agent

- The Resources tier (Mana/Runic Power/Cast Bar/Swing Timer/divider) is
  genuinely shared across all 3 specs - already built and proven, don't
  re-derive or second-guess it per spec.
- Beyond Resources, priority diverges hard by spec: Animation wants
  minion-presence tracking, Death wants disease-uptime + target-health-
  threshold tracking, Rime wants proc/frozen-state tracking. Building one
  generic "Rotation tier" without regard to spec risks solving the wrong
  problem for two of the three specs.
- `load_conditions` (class + combat gating, already proven) is the
  mechanism that would let spec-specific tiers coexist in one class UI -
  gate each spec's extra content so it only loads for that spec, once
  Ascension's own `specialization` load-field is wired up (currently
  catalogued but not built, per `load_conditions.schema.json`'s "verified"
  field).
