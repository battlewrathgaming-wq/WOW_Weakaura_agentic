# Agent blueprint: designing a WeakAura element

First-pass method for turning a `HUD_DESIGN.md` tier into a buildable
WeakAuras spec, using the real technical vocabulary (Aura Types, Trigger
Types, Load, Conditions) confirmed against this project's WeakAuras build
(v5.21.2, Interface 30300). This is a **blueprint - a repeatable checklist,
not an implementation**. No export string, no real anchor coordinates, no
in-game testing happens here. That's gated on the injection-stability
question in `USE_CASE.md`, still blocked on the live client.

## The seven steps

**1. Place it on a tier.** Using `HUD_DESIGN.md`, decide which of the five
tiers this ability/info belongs to. This sets its rough distance from
center, its neighbors, and its base visual treatment (brightness/saturation
grammar vs. the footer's grey-until-active grammar).

**2. Map it to an opportunity type.** Using the ability-index pipeline
(`Docs/WEAKAURA_INDEX.md`, `necromancer_weakaura_index.json`), find which of
the four opportunity types apply: `cooldown_tracker`, `proc_alert`,
`buff_uptime`, `stack_counter`. This is a data lookup, not a judgment call -
the classification is already resolved per ability.

**3. Convert opportunity type to Trigger Type.** Already-fixed mapping:
`cooldown_tracker` → Cooldown Progress (Spell); `proc_alert` → Combat Log
(Spell Cast Success / Aura Applied); `buff_uptime` → Aura; `stack_counter` →
a stack-count sub-display layered on whichever of the above already applies,
not its own trigger.

**4. Choose Aura Type and grouping.** Given the "state via brightness, not
text" grammar from `HUD_DESIGN.md`, default to Icon or Texture-type auras
over Text-heavy ones. For grouping: use static **Groups**, not **Dynamic
Groups** - Dynamic Groups exist specifically to auto-compact and reflow
their children, which directly violates the fixed-channel rule (every
element keeps its address, fading rather than disappearing-and-shifting
neighbors).

**5. Anchor it.** Borrow the two-tier structure noticed in Fojji's Classic
pack: one shared anchor/positioning scaffold built once, then per-class
content slotted into fixed positions relative to it, rather than each class
inventing its own layout. A tier's position is decided once, here, and
every class's version of that tier's content reuses the same anchor.

**6. Set Load conditions.** This is where "self-state only" and "per-tier
decision-relevance fade" actually get encoded: Player Class (always -
every element is class/spec-scoped, given 21 custom classes), and for the
Consumable/Prep footer specifically, an In Combat condition that reduces
presence rather than a hard hide (check whether WeakAuras' Load tab can
express a soft fade on a state change, or whether that has to move to the
Conditions tab instead - open technical question, not yet checked against
this build).

**7. Set Conditions for state, not alarm.** Map "ready" vs. "on
cooldown/unavailable" to alpha and color-saturation changes on the
Conditions tab, not to Animation-tab flashing or pulsing. Reserve any
motion/animation for the Proc/Condition tier only, and even there keep it
to a single clean state transition rather than a repeating alarm loop.

## Positional geometry model (2026-07-02)

Once step 5 (Anchor it) gets past "which tier" and into actual coordinates,
use this model instead of hand-placing or hand-dragging numbers - the
`Template_shadow.py` scaffold work surfaced a real bug (icons resized
25x25 -> 40x30 without recomputing row-to-row vertical spacing overlapped
by ~5 units) that only got caught by chance, and a real drift (two
flanking tiers placed independently ended up at different distances from
center instead of mirroring). Both are exactly the class of mistake this
model exists to prevent.

Every positioned element is described the same way, regardless of tier:

- an **index** - its position within its row (0-based)
- its own **position requirements** - width, height, and the row's gap
  rule (default to HUD_DESIGN.md's spacing rule: small and fixed, 2-4px,
  never a percentage of element size - see that doc's "Compactness and
  cohesive spacing" cross-cutting rule for why)
- a **center line at x=0** - every centered row solves around it, and
  every mirrored flanking pair (like Buffs/Utility) is built as an exact
  reflection of it, never as two independently-placed halves

`geometry.py` (this folder) is the actual reusable tool, not just the
description - three functions cover every case seen so far:

- `row_x_offsets(n, width, gap)` - one row of N identical slots,
  centered at 0.
- `mirror_flanks(n, width, gap, inner_edge, group_gap)` - two flanking
  groups built as an exact left/right mirror, guaranteed by construction
  (`right = -left`, not by careful manual placement).
- `stack_rows_y(heights, gap, top)` - vertical stacking, top to bottom,
  with per-transition gaps (a single number or a list) so growing one
  row's height can't silently overlap its neighbor the way it did before
  this tool existed.

Its own self-tests (`python3 geometry.py`) reproduce `Template_shadow.py`
v0.3's real, live-tested numbers exactly, as a regression check - if a
future change to this module ever stops matching that output, something
broke.

**Correction (v0.8, 2026-07-02): row-to-row gap defaults to 0.** Earlier
versions (v0.4-v0.6) treated the gap between tiers as its own, larger
category - 6-10px, on the unchecked assumption that different tiers need
more breathing room than icons within a tier do. A live reference edit
and a real Luxthos Mage screenshot both showed the opposite: tiers hug
exactly like icons do, just like HUD_DESIGN.md's compactness rule always
said gaps in general should. There's no separate "row gap" convention -
default it to 0 (touching) and only add space between tiers for a
specific, checked reason. Different-height elements sharing a tier
(e.g. Buffs/Utility at 30x20 next to Power's 40x30) still stack at 0 gap
by aligning a shared edge (top, in that case) instead of forcing equal
centers.

Use **[space_audit.py](space_audit.py)** to check this kind of thing
going forward - it reads any decoded version and reports every within-
row gap, every row-to-row gap, and each row's own span in one pass,
instead of spot-checking one comparison by hand whenever a question
comes up (which is exactly how the row-to-row mistake above went
unnoticed for three versions).

## Per-element caveats to check before finalizing

- If the ability is stack-based, check the raw description for a `$<id>u`
  token pointing to a different spell ID before trusting `maxStacks` - the
  index doesn't apply the wrapper-merge the main pipeline does (see the
  Diabolical case in `WEAKAURA_INDEX.md`).
- If the design calls for "alert at N resource," that opportunity type
  doesn't exist yet - flag it as unsupported rather than forcing it into an
  existing category.
- Nothing here has been tested end to end in the live client yet. Treat
  every output of this process as a spec to build and test, not a
  finished aura, until the injection-stability question is resolved.

## Worked example (illustrative only - not yet built)

**Glacial Tap** (spell 805369, `cooldown_tracker`, first-class, 12 sec CD) -
already the worked example in `WEAKAURA_INDEX.md`.

1. Tier: **RESOLVED (2026-07-04).** 12 seconds is short enough to feel
   like Rotation (frequent, steady rhythm) rather than a deliberate,
   longer-cycle spend - confirmed by the settled threshold below, so this
   specific example lands cleanly in Rotation, not as an open boundary
   case anymore.

   **Rotation vs. Power-button cooldown threshold, settled:** Battlewrath,
   acknowledging the call is inherently subjective ("I would lean towards
   30/40 seconds"), grounded it in WoW's own existing cooldown-bracket
   convention rather than inventing a number: short/frequent cooldowns
   naturally cluster around 15/30/45 seconds and still read as Rotation
   cadence, while "major" cooldowns are already a well-known, cross-role
   WoW design pattern at 1/2/5 minutes - tank defensives (1min/2min/5min),
   healer big AoE heals, DPS big buffs/defensives all sit in that bracket
   regardless of role. So: **cooldowns at or under the 15/30/45-second
   bracket default to Rotation; cooldowns in the 1/2/5-minute "major"
   bracket default to Power-button**, since that split already matches how
   WoW's own ability design separates "press it every so often" from "this
   is a deliberate, occasional spend" - not a threshold invented for this
   project. Anything landing genuinely between those brackets (rare) still
   gets judged case by case, but the common cases no longer need a fresh
   decision each time.
2. Opportunity type: `cooldown_tracker` (already resolved in the index).
3. Trigger: Cooldown Progress (Spell), spell ID 805369 direct.
4. Aura Type: Icon, static Group (not Dynamic).
5. Anchor: whichever tier it's placed in from step 1, at a fixed slot
   within that tier's shared anchor.
6. Load: Player Class = Necromancer (single mode).
7. Conditions: full brightness/color when off cooldown, dimmed/desaturated
   while on cooldown - no flash on readiness.

The open question in step 1 is the actual point of running this example -
it shows the blueprint surfaces real design gaps instead of forcing a
premature answer.
