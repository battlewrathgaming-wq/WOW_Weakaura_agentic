# Baseline prompt - WeakAuras agent

Paste this as the opening message when starting a fresh session to work on
WeakAuras for this project. No specific ability/task is assumed - fill
that in after this context is established.

Rewritten 2026-07-06 - the previous version (2026-07-02) predated almost
everything below: the Templates/ schema+template system, `weakaura_codec.py`,
`layer_builder.py`/`inventory.py`, the Necromancer folder, `HUD_DESIGN.md`'s
five-tier model, the FUSE mount-lag bug, `CLAUDE.md`'s working agreement,
and the git repo. If this file ever goes stale again the same way, treat
that staleness itself as worth fixing before building anything else - a
fresh agent working from an outdated version of this prompt will genuinely
misunderstand the project's current capability.

---

You're helping design WeakAuras for **Conquest of Azeroth**, a heavily
custom WotLK 3.3.5a private server (Ascension) with 21 custom classes on
top of the base 10 WoW classes. Talent trees and abilities are custom -
don't assume generic WoW/Classic knowledge about what a named ability does
without checking the real data first, and don't assume race/class or
class-identity mechanics follow retail rules (they don't - see
`Docs/PIPELINE.md` for confirmed specifics, e.g. these 21 classes aren't
even real `ChrClasses.dbc` entries).

## Read these first, in this order

1. **`CLAUDE.md`** (this folder) - the working agreement, settled after a
   real mistake this session (feedback treated as an instant fix-it
   instruction, twice, in opposite directions, before anyone was aligned
   on what was even true). The core rule: **discuss intent before acting**
   - when Battlewrath points something out, that's an invitation to talk
   it through, not a green light to immediately edit/rebuild. Also covers
   two sandbox-specific traps worth knowing before touching anything: a
   FUSE mount-lag bug where the bash tool's view of a repeatedly-edited
   `.py`/`.json` file can go stale (fix: `fuse_check.py`, then a heredoc
   rewrite - never trust a confusing syntax error on a file you've edited
   more than once without checking this first), and that **git must never
   be run through the sandbox's bash tool against this project** - it
   corrupts `.git`'s own internal files outright. The project is tracked
   at `github.com/battlewrathgaming-wq/WOW_Weakaura_agentic` - if a git
   operation is ever needed, write a script and run it locally (e.g. via
   computer-use double-clicking it in File Explorer), don't shell out to
   `git` from the sandbox.
2. **`README.md`** (this folder) - the actual index of everything below,
   kept current as things get built. Start here for "what exists and
   where."
3. **`HUD_DESIGN.md`** - the settled shape: a five-tier radial HUD model
   (proc/condition, rotation, power-button, HP/resources, consumable/prep
   footer) and the rules holding it together (fixed channels, self-state
   only, one visual grammar).
4. **`Template_shadow.py`** + **`ELEMENT_INVENTORY.md`** - the positional
   "mask" every class's real content mirrors exactly (absolute x/y, not
   re-derived), and the per-slot breakdown of what each position is
   *for*, in the abstract, across every class.

## How a real ability actually gets built (the pipeline)

This is the part most likely to be missing from an agent's working
memory if it hasn't read the code directly - don't hand-build a WeakAuras
JSON structure from scratch, the pipeline already exists:

1. **Classify the opportunity type** - `Docs/WEAKAURA_INDEX.md`'s
   taxonomy, extended well past its original four rows. As of 2026-07-06
   there are 10: `cooldown_tracker`, `proc_alert`, `buff_uptime` (icon or
   aurabar), `resource_threshold` (aurabar - Mana/Runic Power bars are
   real, built examples), `missing_buff`, `enemy_cast`, `player_cast`,
   `swing_timer`, `backing_plate`, `pet_summon_countdown` - plus
   composable fragments (`glow_source`, `stack_counter_overlay`,
   `class_accent_tick_end`, `power_threshold_effect`). See
   `Templates/build_templates.py`'s `REGISTRY`/`FRAGMENTS` dicts for the
   authoritative current list - don't rely on a count from an older doc.
2. **Pick the schema+template pair** - `Templates/schemas/*.schema.json` +
   `Templates/templates/*.template.json`, one pair per opportunity type.
   Regenerate both from `Templates/build_templates.py` (`python3
   build_templates.py`) if you ever change a template - don't hand-edit
   the JSON files directly, they're generated output.
3. **Fill it** - `template_filler.py`'s `fill_template(name, params)`
   substitutes real spell IDs/positions/options into the template and
   converts JSON string trigger-keys to WeakAuras' real integer keys.
4. **Assemble a layer** - for a whole tier's worth of slots at once, use
   `layer_builder.py` (shared, class-agnostic) against a class's own
   `<Class>/inventory.py` (plain per-layer constants only - coordinates,
   options, spell IDs, no logic). `layer_builder.py` builds exactly ONE
   layer per call and auto-versions the output file
   (`<slug>_vN_import.txt`) - it deliberately does not assemble multiple
   layers into a final compiled UI; that consolidation happens by hand,
   in WeakAuras' own UI, once each layer is live-tested (`weakaura_codec.py`
   can't encode nested groups, so this isn't a missing feature to add).
5. **Encode and paste** - `weakaura_codec.py` turns the filled Python
   dict into a real WeakAuras import string. Round-trip it (encode then
   decode, check `controlledChildren`/`uid` uniqueness) before pasting
   in-game - this has caught real bugs before they shipped (see
   `Necromancer/slot_assignment.md`'s change log for examples).
6. **Live-test and record** - paste in-game, confirm it looks/behaves as
   intended, then record the outcome in that class's `slot_assignment.md`
   - the traceable ledger of what's actually built and confirmed, as
   opposed to `ELEMENT_INVENTORY.md`'s abstract per-slot description.

`Necromancer/` is the first (and so far only) class with real content:
`theme.json` (accent color), `spell_index.md` (pointer to real ability
data, not a copy), `slot_assignment.md` (the ledger), `inventory.py` (the
layer data `layer_builder.py` consumes). `BUILD_METHOD.md` is the fuller
process writeup this section summarizes. Two layers exist so far:
Resources (built ad-hoc before `inventory.py` existed - not yet
retrofitted into it, flagged as a TODO there) and Tier 1 Rotation (built
through the full pipeline above, live-tested, confirmed working).

## Known limitations - don't overtrust the data past these points

- **Stack counts can under-report.** Confirmed on `Diabolical` (spell
  704723), whose real 15-stack cap lives on a *different* spell ID only
  referenced in its description text. Check the ability's raw description
  in `Outputs/dbc_preview/necromancer_abilities_reference.html` for a
  `$<id>u` token pointing elsewhere before assuming stack data is wrong.
- **Some mechanics are genuinely invisible to any addon**, WeakAuras
  included - not a data gap, a game-engine one. Confirmed case: `Army of
  the Dead`'s crit/haste buff scales with live Abomination count via
  server-side scripting with zero client-side footprint. A WeakAura can
  only react to what the client can actually observe.
- **`wa_lua_verify/`'s findings are a fast pre-check, not ground truth.**
  It runs real WeakAuras source under a real Lua interpreter but stubs
  the whole game API. Validate a genuinely novel/uncertain finding
  against a real in-game export before treating it as settled - but don't
  re-run this ritual on things already well-established (see `CLAUDE.md`).
- **Necromancer only, and low-level.** No other class has real content
  built yet, and Battlewrath's own Necromancer is still low-level with
  most of its kit unlearned - don't assume a full endgame rotation exists
  to build against yet.

## How to work

- Ground every suggestion in real data (client DBC data, `db.ascension.gg`,
  or a real decoded in-game export) - not general WoW instinct. These are
  custom spells with custom numbers, and this project has caught its own
  extraction pipeline mislabeling costs before (see
  `Necromancer/spell_index.md`'s Command-ability correction).
  `db.ascension.gg/?spell=<id>` is a real, already-existing public
  database worth checking directly when this project's own indexed data
  doesn't cover a spell ID yet.
  Also, this build has two more direct verification tools worth knowing
  about (`DEV_TOOLS.md`): the "Show IDs in Tooltips" option and
  `/devconsole`'s `dump`/`tinspect` - closer to ground truth than either
  extraction pipeline when something's genuinely in question.
- Follow `CLAUDE.md`: discuss before rebuilding in response to feedback,
  and treat a confusing file-execution error as a possible FUSE-lag
  symptom before assuming your own edit is wrong.
- If asked to build something outside the existing opportunity types,
  say so explicitly and propose extending `Templates/build_templates.py`
  rather than forcing it into an existing category or hand-writing a
  one-off structure that bypasses the pipeline.
- WeakAuras syntax/version specifics (export string format, trigger UI
  labels) should be confirmed against this project's own installed addon
  source (mounted read-access under `Interface/AddOns/WeakAuras/`) when in
  doubt, not assumed from general WeakAuras knowledge - versions differ.
