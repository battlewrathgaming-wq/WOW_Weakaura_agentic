# Build method - Reaper

Mirrors `Necromancer/BUILD_METHOD.md` exactly - same seven-step
`AURA_BLUEPRINT.md` method, same `theme.json` / `spell_index.md` /
`slot_assignment.md` / `inventory.py` file set, same `layer_builder.py` +
`Templates/` pipeline. Not re-explained in full here; see that file for
the complete rationale. This file only records what's specific to Reaper.

## Why this folder exists now (2026-07-09)

Confirmed live that Reaper is its own top-level class, not a Necromancer
spec - a real captured WeakAuras Load-tab value showed `class.single:
"REAPER"`, distinct from Necromancer. Battlewrath: "Reaper is it's own
class." Its first real content need arrived the same session Necromancer's
Resources tier was refactored into `Tiers/resources_base.py` - Reaper
needs the exact same Runic Power / Cast Bar / Swing Timer / divider-strip
mechanism, plus one genuinely bespoke element (Soul Fragment, 805077) that
has no equivalent anywhere else in the project.

## Mask is still the sole source of truth for position

Same reaffirmation as Necromancer's own file: `Tiers/resources_base.py`'s
`CLASS_RESOURCE_POS`/etc. (which themselves mirror the mask) are what
`inventory.py` always reads from - never a live in-game capture. The one
real prototype Battlewrath hand-built for Soul Fragment
(`Necromancer/_soulfrag_prototype_raw.txt` - kept in that folder as the
historical capture location, since Soul Fragment itself wasn't yet known
to be a Reaper-only element when it was captured) was used to confirm
FIELD VALUES (barColor, trigger shape, spell ID) - never its position,
which this build takes from `resources_base.py`'s current geometry
instead.

## Three-layer architecture, applied

Reaper's `inventory.py` is a thin selection layer, same as Necromancer's
own post-backfill Resources definition:
- Runic Power, Cast Bar, Swing Timer, the divider strip: all built via
  `Tiers/resources_base.py`'s shared builders, no re-derivation.
- Soul Fragment: wholly Reaper-owned bespoke content (not a standard WoW
  power type - there is no base-layer entry for it), built via the
  now-formalized `buff_uptime_aurabar` template with `show_when_missing`/
  `show_stacks` (see `Templates/build_templates.py`'s
  `BUFF_UPTIME_AURABAR_SCHEMA` for the full mechanism trail).

## Divider-strip color

`Tiers/resources_base.py`'s `divider_strip_slot()` defaults to
Necromancer's accent, explicitly flagged there as "NOT yet confirmed as a
deliberate cross-class-constant choice." Resolved here: Reaper passes its
own `theme.json` accent (`#0a876b`) instead of inheriting Necromancer's -
each class's Resources tier gets its own accent-tinted divider, not a
shared hardcoded color.
