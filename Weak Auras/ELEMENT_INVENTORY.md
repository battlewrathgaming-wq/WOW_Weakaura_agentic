# Template_shadow element inventory (v0.14, 2026-07-03)

Every element currently in `Template_shadow.py`'s current version (v0.14,
36 children), with its real position/dimension data pulled directly from
the decoded import string - not re-derived or eyeballed - plus the
expected function each slot is meant to hold. This is the basis for
matching real abilities/effects to a slot going forward: before assigning
anything, check here for what the slot's row, size, and region type imply
it should be used for.

Positions are `xOffset`/`yOffset` from the group's own anchor (center =
0,0); `y` decreases downward, matching every position in `Template_shadow.py`
and `geometry.py`. Region type matters for content: `icon` slots take a
spell/item icon (with cooldown-sweep, stack-count, glow); `aurabar` slots
take a filling progress bar (with text overlay for value/name) - see
`weakaura_codec.py`'s debugging checklist if a slot's region type ever
needs changing, the two types don't share a field set.

## The pipeline - where a mask value actually lives, and where to change it

This file is the mask - the single documented source of truth for every
slot's position/size. **It is a markdown document, not code - nothing
reads it programmatically.** Everything downstream is a *manually
maintained mirror* of these numbers, not a live derivation, so changing a
value here does NOT automatically change anything else. Added 2026-07-09
after a real drift was found and fixed (see the Row C/C.5/D history note
below): the Resources tier's geometry had been updated in code weeks
before this file caught up, so this file briefly stopped being true. The
chain, in the order an update must propagate:

1. **`ELEMENT_INVENTORY.md`** (this file) - the documented position/size
   for a given slot role. Change a number here first, and only here
   decide *what the new value should be*.
2. **`Tiers/resources_base.py`** - for anything in the Resources tier
   (Row C/C.5/D) specifically: `CLASS_RESOURCE_POS`, `CLASS_ENERGY_POS`,
   `CAST_BAR_POS`, `SWING_TIMER_POS`, `DIVIDER_POS`. These constants must
   be hand-edited to match whatever this file now says - there is no
   import or code path that reads this markdown file, so this step is a
   manual, traceable copy, not automation. This is the file every class's
   Resources layer actually builds from (see its own docstring for the
   full 3-layer architecture).
3. **Each class's `inventory.py`** (e.g. `Necromancer/inventory.py`,
   `Reaper/inventory.py`) - for Resources-tier slots, these already pull
   position from step 2's constants (`rb.CLASS_RESOURCE_POS`, etc.), so
   they need NO edit when a Resources position changes - that's the whole
   point of routing through `resources_base.py` instead of hardcoding
   coordinates per class. For any tier that does NOT yet have a shared
   `Tiers/*.py` base file (Rotation, Buffs/Utility, Power-button - only
   Resources has been migrated so far), a class's own `inventory.py` still
   hardcodes that tier's positions directly from this file, and DOES need
   a manual per-class edit if this file's numbers change for those rows.
4. **`layer_builder.py`** - never touched for a position change; it only
   consumes whatever `inventory.py` gives it and has no positional
   constants of its own.
5. **Rebuild** - run `python3 layer_builder.py <class folder> <inventory.py
   path> <layer name>` to regenerate that layer's real import string
   from the now-updated data, then re-import in-game.

**Bottom line: if you want to change a mask value, decide it here first,
then walk steps 2-3 by hand for every place that currently mirrors the old
number.** There is currently no tooling that flags a mismatch between this
file and `resources_base.py` automatically - `fuse_check.py` only catches
stale FUSE-mounted file content, not stale-but-correctly-saved values that
simply drifted from this document. Treat a position change as a small
multi-file edit, not a single-file one.

## Row A - Proc / Condition (Tier 5)

Reactive, off-rotation opportunities - things that need a brightness-based
state change to catch your eye, not a steady press. See HUD_DESIGN.md's
five-tier model for the full reasoning (routine-vs-rare procs still an
open question there).

| Element ID | x | y | w | h | Region |
|---|---|---|---|---|---|
| Tier 5 slot Proc | -107.5 | -105 | 40 | 20 | icon |
| Tier 5 slot 2 | -64.5 | -105 | 40 | 20 | icon |
| Tier 5 slot 3 | -21.5 | -105 | 40 | 20 | icon |
| Tier 5 slot 4 | 21.5 | -105 | 40 | 20 | icon |
| Tier 5 slot 5 | 64.5 | -105 | 40 | 20 | icon |
| Tier 5 slot 6 | 107.5 | -105 | 40 | 20 | icon |

## Row B - Rotation (Tier 1)

Core, frequently-pressed rotation abilities - steady rhythm, not reactive.
Matches the "leaning 40x30, not yet locked" icon convention from
HUD_DESIGN.md, though these are 40x20-adjacent to Row A specifically for
vertical compactness (Proc is 40x20, Rotation is 40x30 - see Template_shadow.py
v0.7's changelog for why Proc alone got shortened).

| Element ID | x | y | w | h | Region |
|---|---|---|---|---|---|
| Tier 1 slot Rotation | -107.5 | -130 | 40 | 30 | icon |
| Tier 1 slot 2 | -64.5 | -130 | 40 | 30 | icon |
| Tier 1 slot 3 | -21.5 | -130 | 40 | 30 | icon |
| Tier 1 slot 4 | 21.5 | -130 | 40 | 30 | icon |
| Tier 1 slot 5 | 64.5 | -130 | 40 | 30 | icon |
| Tier 1 slot 6 | 107.5 | -130 | 40 | 30 | icon |

## Row C - Resource grid, top half

**REVISED 2026-07-09 - center-seam divider strip.** Every Resources-tier
bar shrank from 127.5 to 126 wide and stepped 0.75 further from center
(±63.75 -> ±64.5), opening a precise 3px gap at x=0 for a new fixed
divider element to fill (see Row C/D center seam below) - each bar's
OUTER edge is unchanged, only the inner edge moved. This replaced the
older `class_accent_tick_end` permanent-subtick mechanism, which turned
out to depend on `GetMinMaxProgress()` returning a real value range - a
dependency that silently breaks (hides the tick) for any trigger lacking
live progress data, including the `show_when_missing` "anti statement"
state a bar like Reaper's Soul Fragment needs. Superseded live via
`Necromancer/Resources_v14_import.txt`; see
`Necromancer/slot_assignment.md`'s own writeup for the full derivation.
This row's numbers were out of date relative to the actual shipped
geometry for a few days after that change landed in
`Tiers/resources_base.py` - caught and fixed 2026-07-09 (see the pipeline
note above).

| Element ID | x | y | w | h | Region | Expected function |
|---|---|---|---|---|---|---|
| Class resource | -64.5 | -152.5 | 126 | 15 | aurabar | Primary resource bar (Mana/Energy/Rage/whatever the class's core meter is - class-agnostic label, not literally Mana). |
| Cast bar | 64.5 | -152.5 | 126 | 15 | aurabar | Player's own cast-time progress. Confirmed buildable via WeakAuras' "Cast" trigger, unit=player (`Prototypes.lua` line ~7010). |

## Row C.5 - Class accents

Sits between the two resource-grid rows, restoring width-parity with the
footer below (375 wide, matching Row E). Deliberately generic - "color
texture blocks," not functional trackers, per Battlewrath: "we can always
redefine later."

| Element ID | x | y | w | h | Region | Expected function |
|---|---|---|---|---|---|---|
| Class Accent Left | -157.5 | -160 | 60 | 30 | icon | Decorative class-identity accent. Not yet assigned a concrete meaning. |
| Class Accent Right | 157.5 | -160 | 60 | 30 | icon | Decorative class-identity accent. Not yet assigned a concrete meaning. |

## Row C/D center seam - Resources Divider

**Added 2026-07-09**, alongside the Row C/Row D resize above - not part
of the original v0.14 scaffold, so it has no `Template_shadow.py` history
of its own the way every other row does. Sits at the exact x=0 seam
between the left column (Class resource/Class energy) and right column
(Cast bar/Swing Timer), spanning both rows' combined height (15+15=30,
centered on the shared y midpoint between -152.5 and -167.5). A single
fixed, valueless bar (`backing_plate_aurabar`, `Unit Characteristics`
trigger - always true, never computes a percentage) tinted with the
owning class's own accent color, giving the resource grid a stable visual
break where the tick-based mechanism used to. See
`Tiers/resources_base.py`'s `divider_strip_slot()`.

| Element ID | x | y | w | h | Region | Expected function |
|---|---|---|---|---|---|---|
| Resources Divider | 0 | -160 | 3 | 30 | aurabar | Fixed, always-shown center-seam divider - class-accent-tinted, no trigger data, purely a visual break between the two resource-grid columns. |

## Row D - Resource grid, bottom half

Same 2026-07-09 center-seam divider resize as Row C above - see that
row's note for the full history; not repeated here.

| Element ID | x | y | w | h | Region | Expected function |
|---|---|---|---|---|---|---|
| Class energy | -64.5 | -167.5 | 126 | 15 | aurabar | Secondary resource bar (combo points/runic power/whatever the class's second resource is, shown as a fill rather than a count). |
| Swing Timer | 64.5 | -167.5 | 126 | 15 | aurabar | Melee auto-attack swing/rhythm tracker. Relevant mainly for melee-oriented classes/specs - may sit unused for pure casters. **REVISED 2026-07-06 (later same day):** region type flipped back to `aurabar` per Battlewrath's direct request ("the cast / swing should both be bars... the same with the swing timer") - supersedes the earlier `icon` decision noted in Template_shadow.py v0.12's changelog. Both Cast bar and Swing Timer now share one visual treatment: an always-shown "shadow" bar (dim, 0.35 alpha, empty) that brightens to full alpha and fills only while actually casting/swinging, plus a static right-side timer text. See `Necromancer/slot_assignment.md` and `Templates/schemas/swing_timer_aurabar.schema.json` for the mechanism. |

## Row E - Footer (Buffs / Utility / Power)

Buffs and Utility flank Power at a different y (-185 vs -190) because
they're top-edge-aligned with Power's taller icon rather than center-aligned
- see `geometry.py`'s `mirror_flanks` and HUD_DESIGN.md's compactness
correction for why this reads as one row despite the y difference.

| Element ID | x | y | w | h | Region | Expected function |
|---|---|---|---|---|---|---|
| Tier 3 Buffs 2 | -172.5 | -185 | 30 | 20 | icon | Buff-uptime tracking - self-buffs worth keeping visible/active. |
| Tier 3 Buffs 3 | -142.5 | -185 | 30 | 20 | icon | Buff-uptime tracking (second slot). |
| Tier 4 Standard utility CD 2 | 142.5 | -185 | 30 | 20 | icon | Consumable/Prep footer - utility cooldowns, consumables, prep-phase items. |
| Tier 4 Standard utility CD 3 | 172.5 | -185 | 30 | 20 | icon | Consumable/Prep footer (second slot). |
| Tier 2 slot Power buttons | -107.5 | -190 | 40 | 30 | icon | Power-button tier - resource-priority/spender abilities. Closest tier to actual moment-to-moment skill expression (HUD_DESIGN.md flags whether this should carry more visual weight for tank/healer specs as still open). |
| Tier 2 slot 2 | -64.5 | -190 | 40 | 30 | icon | Power-button tier. |
| Tier 2 slot 3 | -21.5 | -190 | 40 | 30 | icon | Power-button tier. |
| Tier 2 slot 4 | 21.5 | -190 | 40 | 30 | icon | Power-button tier. |
| Tier 2 slot 5 | 64.5 | -190 | 40 | 30 | icon | Power-button tier. |
| Tier 2 slot 6 | 107.5 | -190 | 40 | 30 | icon | Power-button tier. |

## Row F - Buffs/Utility dynamic overflow (positional placeholders only)

Reserved space for the Dynamic Group design settled in HUD_DESIGN.md
(2026-07-03): **6 slots total per side (2 static + 4 dynamic)**,
arranged as a compact 2-wide x 3-tall rectangle - the 2 static icons
(Row E) form the unmoved top row, the 4 dynamic ones stack directly
below at the exact same two x-positions. Populated only out of combat
with whichever tracked buff/utility item is currently *missing*, sliding
away once satisfied or once combat starts. These are pure position/size
placeholders - no trigger, Load, or Condition logic exists yet; that's
real aura-building work via AURA_BLUEPRINT.md once specific items are
chosen to track.

Corrected from an earlier attempt (v0.13, superseded) that got both the
count wrong (6 *new* slots on top of the 2 static, 8 total) and the
placement wrong (one wide row far below, touching Power's bottom edge,
disconnected from the static pair it was meant to extend). Stacking
straight down in the static pair's own two columns instead sidesteps the
Power-collision concern entirely, since those columns already sit outside
Power's x-range - no need to reach all the way down to Power's edge.

| Element ID | x | y | w | h | Region | Expected function |
|---|---|---|---|---|---|---|
| Tier 3 Buffs 4 dynamic | -172.5 | -205 | 30 | 20 | icon | Missing personal buff/prep item - outer column, row 2. |
| Tier 3 Buffs 5 dynamic | -142.5 | -205 | 30 | 20 | icon | Missing personal buff/prep item - inner column, row 2. |
| Tier 3 Buffs 6 dynamic | -172.5 | -225 | 30 | 20 | icon | Missing personal buff/prep item - outer column, row 3. |
| Tier 3 Buffs 7 dynamic | -142.5 | -225 | 30 | 20 | icon | Missing personal buff/prep item - inner column, row 3. |
| Tier 4 Standard utility CD 4 dynamic | 142.5 | -205 | 30 | 20 | icon | Missing utility/consumable item - inner column, row 2. |
| Tier 4 Standard utility CD 5 dynamic | 172.5 | -205 | 30 | 20 | icon | Missing utility/consumable item - outer column, row 2. |
| Tier 4 Standard utility CD 6 dynamic | 142.5 | -225 | 30 | 20 | icon | Missing utility/consumable item - inner column, row 3. |
| Tier 4 Standard utility CD 7 dynamic | 172.5 | -225 | 30 | 20 | icon | Missing utility/consumable item - outer column, row 3. |

## Not in this scaffold at all

Two things discussed this session deliberately live outside Template_shadow,
not as an oversight:

- **Enemy/target cast tracking** - confirmed technically buildable (Cast
  trigger supports unit=target/focus, `Types.lua`'s `actual_unit_types_cast`),
  but inherently variable-count (0-N enemies casting at once) rather than
  fixed-address, so it's planned as a separate DynamicGroup module instead
  of a fixed slot here.
- **Pet-death alert** (Necromancer) - a transient fly-out, not a fixed-address
  element, per USE_CASE.md's design writeup. Confirmed exception to the
  fixed-channels rule, not a missing tier.

## Using this for ability assignment

When matching a real ability to a slot, `AURA_BLUEPRINT.md`'s seven-step
process still applies (Trigger Type, Aura Type, Load, Conditions) - this
inventory answers step 1 (which tier) and step 5 (anchor position) with
real numbers already in hand, so the remaining steps are what's actually
left to resolve per ability.
