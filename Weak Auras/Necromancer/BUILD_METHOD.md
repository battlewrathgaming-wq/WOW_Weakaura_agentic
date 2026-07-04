# Build method - Necromancer

Declared before any real content was built (2026-07-05), per Battlewrath's
own instruction: settle *how* the file gets built before building it. This
is the class-specific instantiation of `AURA_BLUEPRINT.md`'s seven-step
method (Trigger Type, Aura Type, Load, Conditions) plus the per-tier
authoring/consolidation process settled in discussion the same day.

## Why this folder exists now

The server goes live 2026-07-04/05 - real use cases start landing instead
of hypothetical ones. This folder is where "real ability assigned to a
real Template_shadow slot" gets tracked, traceably, per class - starting
with Necromancer's Resources tier since that's the first real content
requested.

## The four files, in build order

1. **`theme.json`** - class accent color, both the existing hex reference
   and a WeakAuras-ready 0-1 float RGBA conversion. Sourced from the
   already-established per-class accent system (`Outputs/readout_html/
   necromancer_readout.html`'s `--accent` CSS variable, confirmed against
   `Outputs/class_sheets/ability_sheets_all_classes.html`'s embedded JSON)
   - not invented fresh for this folder.
2. **`spell_index.md`** - a pointer index only, same "pointer layer, not
   duplicated data" principle the rest of `Weak Auras/` already follows
   (see its own README). Points at real spellIds/values already verified
   in `Outputs/dbc_preview/necromancer_abilities_reference.html`, doesn't
   re-derive or duplicate them.
3. **`slot_assignment.md`** - the real, traceable ledger: per
   `Template_shadow.py`'s tier/slot, which spell ID (if any) is assigned,
   its opportunity type + trigger, glow-source/conditions if any, and a
   status column (assigned / built / live-tested). The real-content
   counterpart to `ELEMENT_INVENTORY.md` (which only ever described
   position/size/expected function in the abstract).
4. **The actual buildable file(s)** - real WeakAuras import strings, one
   per tier during development (see "Per-tier authoring" below), later
   consolidated into a single final export once the whole class UI is
   considered done.

## Per-tier authoring, settled 2026-07-05

**Decision: build and live-test each tier as its own small, independent
import during development, mirroring `Template_shadow.py`'s existing
absolute positions exactly - not re-derived, not relative to some other
tier.** Battlewrath's reasoning: "We have the mask to mirror the tier
items against. Thus why it is a mask." `Template_shadow.py` (the "mask")
exists specifically to be the positional reference every real tier build
mirrors, not just a one-time scaffold that gets discarded once real
content lands.

**Why per-tier instead of one big group from the start:**
- Smaller, faster imports to generate and paste while iterating - matches
  the established build/test/screenshot/adjust cycle rather than needing
  the whole class UI finished before anything is testable.
- Isolates a bug to one tier - a malformed Buffs/Utility import doesn't
  block or risk Rotation/Power-button, which are separately tested and
  presumably more stable by that point.
- **Enables nesting `weakaura_codec.py` can't build programmatically.**
  The codec's `encode_group_import_string` explicitly does not support a
  group containing another group (documented limitation, confirmed by
  reading `Transmission.lua`'s real import-version branching). Per-tier
  importing sidesteps this: a tier like Buffs/Utility (2 static icons +
  a DynamicGroup for the missing-buff overflow) or a future target-cast
  tracker (a DynamicGroup for variable-count enemy casts) can be
  **assembled in-game after import** - drag the DynamicGroup into the
  static Group manually via WeakAuras' own UI, which supports this even
  though the codec's encoder doesn't. Building tiers separately is what
  makes this assembly step possible at all; one giant codec-built group
  never could contain a nested DynamicGroup in the first place.

**Final consolidation, once a tier (or the whole class UI) is considered
done:** compile everything into a single unified group *in-game*, by hand
- not re-encoded from scratch via the codec, since nesting still isn't
supported there. Once compiled and confirmed final, export that combined
state from WeakAuras' own Export button and store the resulting string as
the new versioned canonical capture (same pattern as `Template_shadow.py`'s
own version history - a real, live-tested snapshot, not a hypothetical
one).

## Layer numbering + `inventory.py`, formalized 2026-07-06

The per-tier authoring above was always done through one-off Python calls
to `template_filler.fill_template()`, never saved as a reusable file - 13
sessions' worth for Resources alone, then again for Tier 1 Rotation.
Formalized per Battlewrath: each class gets one `inventory.py` (plain
constants only - coordinates, options, spell IDs, per layer - no fill/
encode logic in it) and `../layer_builder.py` (one shared, class-agnostic
builder, unrelated to `Templates/build_templates.py` despite the similar
name - that one generates schema/template JSON pairs; this one consumes
them) turns any single named layer's slot list into a real,
auto-versioned import string.

**"Layer" numbering tracks build order, not tier order** - Resources
(+ the Template_shadow.py placeholder scaffolding it superseded) is
layer 1, Tier 1 Rotation is layer 2, and so on - deliberately allowed to
diverge from HUD_DESIGN.md's own tier numbers. Resources itself hasn't
been retrofitted into `inventory.py` yet (flagged there as a TODO) -
`Resources_v13_import.txt` remains the authoritative build until that
backfill happens as its own step.

**Confirms, doesn't replace, the per-tier/in-game-consolidation
principle above:** `layer_builder.py` builds exactly one layer per call,
same reason as the "why per-tier instead of one big group" list above -
nesting still isn't something the codec supports, so final assembly of
multiple layers (and any DynamicGroup layers) into the complete class UI
still happens by hand, in WeakAuras' own UI, not by this tooling. Per
Battlewrath directly: "The complete compile comes later in-game using
WeakAuras... so we're not asking the compiler to rebuild the full UI
every time." A layer can itself be a `"group"` or `"dynamicgroup"` (set
per-layer in `inventory.py`) - `encode_group_import_string` doesn't care
which, so a future variable-membership layer (e.g. enemy-cast tracking)
fits the same pipeline without a special case.

## Per-ability build steps (within a tier)

For each real ability being assigned to a slot, run `AURA_BLUEPRINT.md`'s
seven steps, using `Templates/`'s JSON Schema + template pairs
(`weakaura_codec.py`'s `README.md` entry) as the starting point rather
than hand-building from scratch:

1. **Opportunity type** - which of `Docs/WEAKAURA_INDEX.md`'s taxonomy
   rows (including the 2026-07-04 extensions) this ability actually is.
2. **Template** - the matching `Templates/schemas/*.schema.json` +
   `templates/*.template.json` pair for that opportunity type + region.
3. **Fill** - `template_filler.py`'s `fill_template()`, with the real
   spell ID(s), position (from `slot_assignment.md`, itself mirroring
   `Template_shadow.py`), and any glow-source/stack-counter params.
4. **Load** - class/spec scoping (Necromancer-only, relevant spec if
   talent-gated).
5. **Verify** - decode the filled result back and sanity-check
   `controlledChildren`/`uid` uniqueness before pasting in-game, same
   discipline as every other WeakAuras build this project has done.
6. **Live test** - paste in-game, screenshot, confirm it looks/behaves as
   intended, record the outcome in `slot_assignment.md`'s status column.
7. **Record** - update `slot_assignment.md` with the final assigned spell
   ID/trigger/status once confirmed, so the file stays traceable.

## Open items this folder inherits (not yet resolved, flag rather than guess)

- **"Life Force" naming - RESOLVED (2026-07-05).** Earlier recorded as
  "Life Essence"; Battlewrath corrected this directly ("It must be life
  force. My error."). The real DBC data
  (`necromancer_abilities_reference.html`) already used "Life Force" - real
  per-minion costs confirmed (Abomination 3, Gargoyle 3, Banshee 2,
  Skeletal Mage 1, Ghoul 1, talent-modified). No literal "starts at 3"
  base value found in text - Battlewrath's stated starting value of 3
  still isn't independently corroborated by the data, only the per-minion
  consumption amounts are, but the naming question itself is closed.
- **Runic Power's spend side - CONFIRMED (2026-07-05), Battlewrath was
  right, our own indexed data was wrong.** Spent mainly by **Command** (a
  client-to-server call making all summoned minions each cast their own
  version of Command). Cross-checked all three Command spell IDs directly
  against `db.ascension.gg`'s live spell pages: all three really do cost
  Runic Power (30/20/30), not the 400/300/300 `manaCost` this project's own
  `necromancer_abilities_reference.html` showed - that file's extraction
  pipeline was mislabeling every cost value `manaCost` regardless of the
  spell's actual power type (confirmed root cause, not just a hypothesis
  now). Two of the three ability names in our data were also wrong
  (504050/504316 - see `spell_index.md` for the corrected names). Still not
  a blocker for building the bar itself (a status read doesn't need
  per-ability costs), but the discrepancy is now resolved rather than
  merely noted.
- **Life Force is deliberately NOT a Resources-tier slot, and gets no
  persistent tracker of any kind (reaffirmed 2026-07-06).** It has its own
  native in-game UI element already (per Battlewrath), and this project
  shouldn't compete with it for count/tracking display, full stop - not
  just skipping the Resources tier specifically. Its WeakAuras treatment
  is a transient combat-text alert, redesigned 2026-07-06 in
  `USE_CASE.md`'s pet-tracking section: fires on any budget change and
  suggests the highest-value summon currently affordable, rather than
  just reporting a raw "+N LF" delta (the original, simpler design,
  superseded but not deleted). Noted here so neither a persistent bar nor
  a bare-number alert gets accidentally rebuilt later.
