# Addressable HUD concept - future direction (not started)

Captured 2026-07-08, during the class-behavior-profile pass, once the real
scale of "one hand-built HUD per class" became explicit: 21 classes x
3-4 specs each - roughly 69 total specs, each currently requiring the same
per-slot judgment calls (which opportunity type, what trigger, what
position) this project has been making one at a time for Necromancer.
Battlewrath's framing: "Doing every spec... and getting them right, is a
massive ask." This doc is the concept that came out of that framing - not
a build, a plan for a build that isn't started yet.

## The actual idea

Not a general-purpose WeakAuras editor. Battlewrath was explicit about the
boundary: "The moment it is free form, then we're just an offline/out of
game weak aura simulator. They can do all of this in-game, if they know
what fields / conditions to set." Free placement or raw field access adds
nothing a player doesn't already have in WeakAuras itself.

The actual shape: a **pre-formed, indexed/addressable HUD** - a fixed mask
(same idea as `Template_shadow.py`'s five-tier model, `ELEMENT_INVENTORY.md`'s
per-slot position/region-type data), where every slot already has a known
address (`Tier 1, slot 1`, `Tier 1, slot 2`, ...) and a known shape (icon
vs. aurabar vs. text, fixed by the mask's own geometry). New masks might
get made later, but any given mask is fixed once published - this is
explicitly not a layout editor.

**What the player actually fills in, per slot:** one question - "what is
happening?" - answered from a closed dropdown, not free text. The answer
set is this project's own existing opportunity taxonomy
(`Docs/WEAKAURA_INDEX.md` + the Templates section of `Weak Auras/README.md`):
`cooldown_tracker`, `proc_alert`, `buff_uptime`, `resource_threshold`,
`stance_loader`, `stack_delta_flash`, `pet_summon_countdown`, `player_cast`,
`swing_timer`, `enemy_cast`, `missing_buff`. The slot's own fixed region
type narrows the dropdown before the player even opens it - an icon-shaped
slot only offers icon-flavored types (`cooldown_tracker`, `proc_alert`,
`stance_loader`, `missing_buff`, `pet_summon_countdown`), a bar-shaped slot
only offers bar-flavored ones (`resource_threshold`, `player_cast`,
`swing_timer`, `enemy_cast`). Once a type is picked, the form asks only
that type's own small param set - a spell ID for `cooldown_tracker`, a
power type for a resource bar, N spell/buff names for `stance_loader` -
never a raw trigger, condition, or region field. Output: a real WeakAuras
import string, via the already-proven `weakaura_codec.py` encode path.

## Why this is more than a hopeful idea - concrete evidence already in hand

This isn't a cold-start proposal. The template/schema/filler pipeline
already built for Necromancer is most of the mechanism:

- `player_cast_aurabar`, `swing_timer_aurabar`, `backing_plate_aurabar` -
  already fully class-agnostic. No Necromancer-specific logic in any of
  them beyond which spell/position was chosen.
- `cooldown_tracker_icon`, `buff_uptime_icon`/`_aurabar`, `proc_alert_icon` -
  the mechanism is generic; the only class-specific input was ever a spell
  ID.
- `stance_loader_icon` - proven to generalize *three independent times*,
  not just designed to in theory: Undead Stance (this project), Ward
  active (Battlewrath's own hand-build, same mechanism, unassisted), and
  Druid's Bear/Cat/Travel forms (a completely unrelated class, found via
  `CLASS_BEHAVIOR_PROFILES.md`'s guide survey). Three-for-three is real
  evidence the abstraction holds, not a hope that it will.
- `resource_threshold_aurabar` - already parameterized on `power_type`
  (confirmed real integer enum, not a guess - see `USE_CASE.md`'s "Open
  items"), and WoW's power types are a small, fully enumerable list
  (Mana/Rage/Energy/Focus/Runic Power/etc.) - a dropdown, not open text.

## Where the real risk is - flagged, not glossed over

**Not every mechanic degrades safely into a form field.** Necromancer's
own Life Force stack tracker is the cautionary example already on record:
the naive approach (Combat Log `SPELL_AURA_APPLIED_DOSE`) failed three
separate live tests before the working fix (a Custom/`stateupdate` trigger
that polls and diffs the value in Lua) was built - see
`Templates/CUSTOM_STATEUPDATE_TRIGGER.md`. If a generic "stacking
resource" slot ships assuming the simple Combat Log path works for any
class's equivalent mechanic, some class's version will silently misbehave
the same way, and a player filling in a form has no way to know why or fix
it. **Conclusion: ship stacking-resource slots on the more robust
mechanism by default, and expect some class's version to need a real,
manual look - this can't be fully delegated to a form.**

**Fancier visual flourishes have already proven fragile.** The
glow-source proc-condition mechanism and the Tier 1 press-feedback wash
were both live-tested and partially withdrawn - press-wash "never
reliably fired in-game" per `Weak Auras/README.md`'s own changelog. These
should stay opt-in extras layered on a slot, not part of the guaranteed
baseline, since this project's own experience shows they don't always
survive contact with the real client.

**Layout is the one open architectural decision, and the only expensive
one.** Everything above is trigger/mechanism work, which is largely done.
The geometry/mask work (`geometry.py`, `HUD_DESIGN.md`'s five-tier model,
`space_audit.py`) is the heavier investment, and reusing it as a *fixed*
mask (vs. a free editor) is exactly what keeps this project's scope sane -
confirmed as the right call by Battlewrath directly this session.

## Personal vs. community - not yet decided

Raised, not settled. A personal tool (Battlewrath plus friends on this one
server) is low-risk and could reuse proven mechanisms almost as-is. A
community-facing tool raises the stakes to every class's own quirks the
way Life Force needed real debugging - more classes means more chances to
hit an undiscovered "this doesn't actually work the simple way" case.
Revisit once there's more than one class's worth of real-world experience
to generalize from.

## Current decision (2026-07-08)

**Continue Necromancer for now, deliberately.** Per Battlewrath: "This
would help shape all our options we can cater / serve." Necromancer stays
the reference implementation - every real slot type, mechanism, and
failure case discovered while building it directly informs which
dropdown options and param forms the eventual tool needs to expose. Not
"finish all remaining Necromancer specs exhaustively" - keep building/
refining it as it's actually used, the same low-risk/iterative posture
this project has had throughout, per its own project-level instructions.
No GUI work has started. This doc exists so the framing survives session
handoff, not as a spec to build against yet.
