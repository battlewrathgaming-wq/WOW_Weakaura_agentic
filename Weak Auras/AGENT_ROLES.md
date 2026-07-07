# Agent roles - core maintainer vs class implementer

Settled with Battlewrath 2026-07-10. Splits future work on this project
into two roles, matching a fault line that already existed in the file
layout (`Templates/`+`Tiers/`+`ELEMENT_INVENTORY.md` vs a per-class
folder) but had never been made an explicit working rule. Written as a
standalone handoff doc, same pattern as `Mob_Autogroup/DESIGN.md` - meant
to be handed to a **fresh agent session with no memory of this
conversation**, so it has to be self-contained.

## The two roles

**Core maintainer** - this thread (the one that built Necromancer and
Reaper). Owns:
- `Templates/build_templates.py` - the REGISTRY of opportunity-type
  schemas/templates and the FRAGMENTS (`glow_source`,
  `power_threshold_effect`, `press_wash_effect`, `load_conditions`,
  `class_accent_tick_end`, `stack_counter_overlay`).
- `template_filler.py` - fills a template with real per-instance values.
- `Tiers/*.py` (currently just `resources_base.py`) - shared, class-
  agnostic builders for a tier's standard slot content.
- `ELEMENT_INVENTORY.md` - the mask, positional truth only.
- Any genuinely new mechanic that needs source-level verification
  (Prototypes.lua/BuffTrigger2.lua/etc.) before it can be trusted, and
  the live-test loop that goes with it (build -> Battlewrath tests
  in-game -> report -> trace source -> fix -> rebuild).

**Class implementer** - a freshly spun-up agent, one per new class,
scoped tightly:
- **Read-only** against `Templates/`, `Tiers/`, `ELEMENT_INVENTORY.md`,
  `layer_builder.py`, `weakaura_codec.py`, `fuse_check.py`. Never edits
  these.
- **Write-only** inside its own class folder (`<ClassName>/`) and the
  matching `Outputs/` artifacts for that class.
- Job: scaffold the folder, then build each tier using ONLY existing,
  already-proven builders/templates - no new opportunity_type, no new
  fragment, no bespoke Lua.

Why asymmetric rather than symmetric peer roles: most new-class work
(Reaper's Resources tier was the concrete example - every builder except
Soul Fragment itself was a straight reuse of `resources_base.py`) is pure
consumption of already-proven capability. That's genuinely decoupled work
and doesn't need core-file access at all. It also means the highest-
blast-radius file (`build_templates.py` - the one that keeps taking FUSE-
lag hits, since it's the file edited most often across unrelated class
work) gets touched less often once class work stops writing to it.

## What a class-implementer session should do

1. **Scaffold the folder**, mirroring `Necromancer/` and `Reaper/`
   exactly: `theme.json` (accent color), `<ClassName>_fantasy_playstyle.md`
   (added 2026-07-10 - what the class IS and what matters to it: the
   resource economy, the class-tree baseline, and each spec's identity and
   UI priorities, sourced from `Input/<class>_talents.json` +
   `Outputs/readouts/<class>_readout.md` - see
   `Necromancer/Necromancer_fantasy_playstyle.md` /
   `Reaper/Reaper_fantasy_playstyle.md` as the worked examples; write this
   BEFORE `spell_index.md`/`slot_assignment.md` so slot-priority decisions
   have something to reason against, not after as an afterthought),
   `spell_index.md` (real spell IDs/mechanics, sourced from
   db.ascension.gg / trainer captures / live testing - never invented),
   `slot_assignment.md` (a ledger table: mask position -> content ->
   opportunity_type -> trigger -> status), `BUILD_METHOD.md` (why the
   folder exists, confirms the class is real and distinct if relevant,
   reaffirms mask-is-truth), `inventory.py`.
2. **Read the mask** (`ELEMENT_INVENTORY.md`) to know what slot addresses
   exist and what role each one plays. Do not invent new slots or move
   existing ones - if the class's kit doesn't fit the existing mask,
   that itself is an escalation (see below), not something to route
   around locally.
3. **Build `inventory.py`** the same shape as `Reaper/inventory.py`:
   import `Tiers/resources_base.py` as `rb`, use its position constants
   (`CLASS_RESOURCE_POS`, `CLASS_ENERGY_POS`, `CAST_BAR_POS`,
   `SWING_TIMER_POS`, `DIVIDER_POS`) and slot builders (`resource_slot`,
   `health_slot`, `cast_bar_backing_slot`, `cast_bar_slot`,
   `swing_timer_backing_slot`, `swing_timer_slot`, `divider_strip_slot`)
   for anything standard.
   Reference `Templates/build_templates.py`'s `REGISTRY` dict for the
   full list of already-built opportunity types (`cooldown_tracker_icon`,
   `proc_alert_icon`, `buff_uptime_icon`, `buff_uptime_aurabar`,
   `resource_threshold_aurabar`, `health_range_aurabar`, `missing_buff_icon`,
   `enemy_cast_aurabar`, `player_cast_aurabar`, `swing_timer_aurabar`,
   `backing_plate_aurabar`, `backing_plate_icon`, `pet_summon_countdown_icon`,
   `stack_gain_flash_text`, `stack_delta_flash_text`, `stance_loader_icon`,
   `minion_presence_icon`) and `FRAGMENTS` for optional attachable effects.
   Only bespoke, wholly-owned content (like Reaper's Soul Fragment, which
   has no base-layer entry since it isn't a standard WoW power type) gets
   built directly in the class's own `inventory.py`, using an EXISTING
   template (e.g. `buff_uptime_aurabar`) - not a new one.
4. **Build via `layer_builder.py <ClassName> <ClassName>/inventory.py
   <LayerName>`**, same invocation as every prior class.
5. **Round-trip verify**: decode the resulting import string via
   `weakaura_codec.decode_group_import_string`, spot-check child count,
   order, positions/sizes, trigger shapes, unique UIDs.
6. **Update `slot_assignment.md`** with the real ledger and status,
   same table shape as `Necromancer/slot_assignment.md` /
   `Reaper/slot_assignment.md`.
7. Watch for FUSE mount-lag the whole way through - `CLAUDE.md` (this
   folder's working agreement) has the full recovery workflow
   (`fuse_check.py --resync`); it hits `.py`/`.json`/`.md` files that get
   edited more than once in a session, not just the core files.

## The escalation rule - "first class / primitive issue"

**Stop the moment the class needs a mechanic that doesn't already exist
as a REGISTRY entry, a FRAGMENT, or a `resources_base.py` builder.**
Concrete examples of what counts: a new trigger category never used
before, a resource bar shape that doesn't fit `resource_threshold_aurabar`
or `buff_uptime_aurabar`, a new tier structure the mask doesn't have a
slot for, a mechanic needing bespoke Lua beyond what
`stack_delta_flash_text`'s pattern already covers.

**Do not invent a workaround inside the class folder.** No copy-pasted
near-duplicate of an existing template with one field changed, no inline
bespoke dict that reimplements schema logic the core layer already owns.
That's exactly the drift `resources_base.py` was built to prevent (two
classes independently re-deriving the same Runic Power bar was the
original motivating problem, 2026-07-09).

**Bring it back as a primitive issue, not a pre-built fix.** Write a
short gap report and hand it back to Battlewrath / the core-maintainer
thread, containing:
- What the class needs (the real mechanic/spell, with source - trainer
  capture, db.ascension.gg, live-test observation).
- Which existing opportunity_type/fragment/builder is closest, and
  specifically why it doesn't cover this case.
- Whether anything about it has already been confirmed live or by direct
  source read (Prototypes.lua/BuffTrigger2.lua/etc.), vs. genuinely
  unknown and needing a live test once built.
- What's blocked in the class folder pending this (so work can resume
  immediately once the core gets the new capability).

This mirrors how Soul Fragment's `show_when_missing`/`show_stacks` came
about on `buff_uptime_aurabar` this session, and how `resources_base.py`
itself came about (a capability gap noticed while building Reaper,
fixed once at the core layer, then consumed by both classes) - the
difference is just that a class-implementer agent surfaces the gap and
stops, rather than fixing it itself inline.

## What's already proven and safe to reuse without any escalation

- Resources tier: Mana/Energy-type bar + Cast Bar + Swing Timer + center
  divider, via `resources_base.py`'s builders - proven twice
  (Necromancer, Reaper).
- `stance_loader_icon` - proven 3x independently (Undead Stance, Ward
  active, and cross-referenced against real Druid form data in
  `CLASS_BEHAVIOR_PROFILES.md`).
- `cooldown_tracker_icon` with `power_threshold`/`press_wash`/
  `desaturate_on_cooldown` - proven on Necromancer's Lichfrost/Crypt
  Swarm/Command: Undead/Skeletal Archers.
- `minion_presence_icon` - proven on Necromancer's Minion tracker
  (known limitation: presence-accurate, not count-accurate for 2+
  simultaneous same-type pets - documented in the schema itself, not a
  blocker for building it, just don't oversell the stack count).
- `load_conditions` (class/combat gating) - proven live once.
- `stack_delta_flash_text` - proven on Necromancer's Life Force.
- `health_range_aurabar` / `resources_base.py`'s `health_slot()` - a
  Health-trigger sibling of `resource_threshold_aurabar` for a bar clamped
  to a percent-of-max-health window (e.g. "top 50%-100% of HP" - HP you
  can afford to lose/use). Formalized 2026-07-09, BEFORE any class actually
  consumes it, per Battlewrath: "I'd formalize the health side as a
  capability. Then the class agent can work from there... It comes between
  us as a primitive capability first." Confirmed two ways: direct source
  read (Prototypes.lua's native "Health" unit trigger,
  RegionPrototype.lua's adjustedMin/adjustedMax percent-suffix clamp) AND a
  real, live-built and live-confirmed WeakAuras export Battlewrath pasted
  in-game (id `Bloodmage_hp_resouece_50-100%`). `health_slot()` takes
  plain numbers for min/max percent and appends the required `%` itself -
  do not hand-build this template's params dict directly, since the real
  prototype that motivated this capability had exactly that field
  (missing the `%`) silently wrong. See `Bloodmage/BUILD_METHOD.md`'s
  "Escalation flag - RESOLVED" / "Upgraded to REAL-CAPTURE confirmed"
  sections for the full trail.

## What's still open even at the core layer (don't treat as solid)

- `glow_source`'s second-trigger Condition shape - real by source read,
  not independently live-tested for a genuinely separate trigger yet.
- `stance_loader_icon`'s `border_colors` Condition-driven border - real
  field, condition-driven addressing inferred by analogy, not
  independently live-tested.
- `minion_presence_icon`'s matchCount/bestMatch limitation - a noted
  possible future fix path via `sourceGUID`/`destGUID` Combat Log
  triggers exists (added 2026-07-10), not built, not designed.

If a class implementer's build touches one of these, that's worth a
note too, even if it's not a hard blocker - same "don't oversell
certainty" principle as everything else in this project.

## Git identity convention for agent-made commits (added 2026-07-07)

The repo's stored `user.name`/`user.email` (`Battlewrath <...>`) stays
Battlewrath's own identity - never change it. When an agent session
commits its own work directly (rather than leaving everything for
Battlewrath to commit by hand via `git_push.bat`), override the identity
for that single command only, using this session's own sandbox id as the
distinguishing suffix:

```bash
git -c user.name="Claude (session <sandbox-id>)" \
    -c user.email="<sandbox-id>@agent.session.local" \
    commit -m "..."
```

The `-c` flags only apply to that one git invocation - they never touch
the persistent repo config, so Battlewrath's own commits (via
`git_push.bat`) are unaffected. Each new session gets a different sandbox
id automatically, so distinct sessions naturally get distinct authors in
`git log` with zero setup. Purpose: `git log`/`git blame` can distinguish
human-authored commits from agent-authored ones (and, per-session, which
agent run did what), rather than every agent-written change being
indistinguishable from Battlewrath's own hand-authored history. See
`CLAUDE.md`'s git section for the related bash-vs-native-script safety
rule this is layered on top of.
