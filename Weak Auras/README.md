# Weak Auras

An index into the WeakAuras opportunity work - which abilities are worth
building a WeakAura for, and what trigger config each one needs. This
folder is a pointer layer like `Display/` - the generated data lives under
`Outputs/`, this just indexes it.

**[CLAUDE.md](CLAUDE.md)** - working agreement for this folder (2026-07-06):
discuss intent before acting on feedback, correct once aligned, not before.
Also covers the FUSE mount-lag bug and, as of 2026-07-06, why `git` must
never be run through the sandbox's mounted-folder bridge - the whole
project is now tracked at
[github.com/battlewrathgaming-wq/WOW_Weakaura_agentic](https://github.com/battlewrathgaming-wq/WOW_Weakaura_agentic).

## Start here

- **[Tools/COA_DevDump/README.md](Tools/COA_DevDump/README.md)** - a custom
  in-game addon (2026-07-04) for pulling real live-client data into
  `SavedVariables`, since neither macros nor `/devconsole` expose file I/O.
  Confirmed the stock trainer API works cleanly on this server (trainers
  are server-driven, no client-side data to bypass) but the stock talent
  API is fully dead for custom classes (`GetNumTalentTabs()` returns 0) -
  the real talent data instead lives as plain `spellID`/`rank`/`maxRank`
  fields on the custom `CoATalentFrame`'s own button widgets. This is the
  tool + method behind `necromancer_live_reference.json` below; read this
  first before repeating the capture for another class.
- **[wa_lua_verify/](wa_lua_verify/)** - runs the REAL WeakAuras addon
  source under a real Lua 5.1.5 interpreter (matching WoW 3.3.5a's
  actual Lua version) to extract subRegion `default()` tables directly
  from source, and diffs this project's own templates against them -
  catching missing-field gaps (like the one that shipped in
  `class_accent_tick_end`) before a live test has to. First run found
  two candidate gaps: `resource_threshold_aurabar`/`swing_timer_aurabar`'s
  subtext (real, still open) and `cooldown_tracker_icon`'s subglow
  (resolved as a false positive once all 8 subRegion types were run
  through the harness - see `Templates/ICON_REGION_OPTIONS.md`). Also
  live-validated against a real in-game export (`subborder`, 2026-07-06).
- **[Templates/ICON_REGION_OPTIONS.md](Templates/ICON_REGION_OPTIONS.md)**
  - the full real option catalogue for `type: icon` auras (base region
  fields, configurable properties, every subRegion attachment's real
  field set), built from `wa_lua_verify` + direct source reads so new
  icon elements (e.g. a future Tier 1 Rotation slot) can be built by
  choosing from known, verified options instead of reasoning from
  scratch each time.
- **[Templates/ROTATION_ICON_PATTERN.md](Templates/ROTATION_ICON_PATTERN.md)**
  - a parameterized pattern (base spell / optional proc spell(s) /
  optional mana-cost threshold) mapping to real, source-confirmed
  triggers + multi-trigger conditions + subRegions - glow-on-proc and
  desaturate-on-insufficient-mana, composable together. Wired into
  `cooldown_tracker_icon`'s schema/template as of 2026-07-06 (see
  `power_threshold_effect.schema.json`).
- **[Templates/CUSTOM_STATEUPDATE_TRIGGER.md](Templates/CUSTOM_STATEUPDATE_TRIGGER.md)**
  - source-grounded research (2026-07-06/07) into WeakAuras' `Custom`
  (`stateupdate`) trigger type - the mechanism behind polling a live
  stack count and diffing it in Lua, written up after `stack_gain_flash_text`'s
  wizard Combat Log trigger failed three separate live tests for
  Necromancer's Life Force debuff. Confirms the trigger shape, the
  `TSUHelpers.lua` `allstates` API, and a draft Lua implementation. Not
  yet built into an actual test aura.
- **[layer_builder.py](layer_builder.py)** - the shared, class-agnostic
  tool that turns one class's `inventory.py` (plain per-layer constants)
  into a real, auto-versioned import string, one layer at a time - see
  `DEV_TOOLS.md`'s tool 4 and `Necromancer/BUILD_METHOD.md`'s "Layer
  numbering" section. First real consumer: `Necromancer/inventory.py`'s
  "Tier 1 Rotation" layer.
- **[Necromancer/](Necromancer/)** - the first per-class real-content
  folder (2026-07-05, server-live day), starting with the Resources tier.
  `BUILD_METHOD.md` declares the process (per-tier authoring mirroring
  `Template_shadow.py`'s positions, in-game nesting/consolidation, since
  `weakaura_codec.py` can't encode nested groups) before any content;
  `theme.json` holds the class's already-established accent color
  (`#45db9c`); `spell_index.md` points at real Mana/Runic Power/Life Force
  data in `Outputs/dbc_preview/necromancer_abilities_reference.html`;
  `slot_assignment.md` is the traceable ledger of what's actually assigned
  to which `Template_shadow.py` slot - the real-content counterpart to
  `ELEMENT_INVENTORY.md`. **Resources tier built, 2026-07-06, revised
  later same day:** Mana, Runic Power, Cast Bar, and Swing Timer all
  filled from their templates and assembled into one real import string.
  Cast Bar and Swing Timer were then revised per Battlewrath's direct
  request - both are `aurabar`s (Swing Timer converted from `icon`) with
  an always-shown idle-shadow footprint (dim/empty when not in use,
  brightens and fills when active) and a static right-side timer text.
  Mana/Runic Power then got a left-side `"%p"` current-value readout
  (also catching and fixing a real pre-existing bug: an unresolved
  `"{{threshold_value}}"` placeholder baked into every resource bar's
  subtick, now fixed to be a proper optional fill-time addition). Colors
  then synced from Battlewrath's real in-game edits (Runic Power/Cast Bar
  recolored, Swing Timer set to white). Live-testing the idle-shadow
  mechanism then found it backwards (bar hid once actually triggered,
  opposite of intent) - withdrawn per Battlewrath ("the backing entity is
  the fix here rather than over complicate the auras") in favor of a
  separate, always-shown `backing_plate_aurabar` element sitting at
  `frameStrata: 2` (BACKGROUND) behind each bar, which stays back to
  simple single-trigger behavior. A follow-up "icon-spacing gap" fix
  (disabling `icon`) was itself corrected right back - the icon costs no
  extra footprint (it's carved out of the bar's existing width, not
  added beyond it) and it's genuinely useful: with `iconSource: -1`, the
  bar auto-displays whichever spell/weapon icon its own trigger already
  returns. Live-testing then surfaced one more mismatch: the backing
  plate's idle darkness was lighter than the real bars' own empty look
  (it stacked a region alpha on top of the same backgroundColor the real
  bars use at full alpha) - fixed by dropping the plate to alpha 1, so it
  dims the same single way the real bars do (v9, confirmed live as
  "great and locked in"). That fix also erased the seam that used to
  mark Mana/Runic Power's own bar-edge, so a permanent class-accent-
  colored `subtick` end-cap (`tick_placement_mode: AtPercent`, `[100]`,
  tracks the live max regardless of level/gear) was added to both,
  discussed with Battlewrath before building per `CLAUDE.md` (v10). Live
  testing then caught a real field-parity bug: the subtick fragment was
  missing 3 fields from `SubRegionTypes/Tick.lua`'s own default table and
  stored its placement as a number instead of a string, so it shipped at
  the wrong position (50, not 100) until manually corrected in-game.
  Fixed, and per Battlewrath's request, promoted into a new named,
  reusable fragment - `class_accent_tick_end` (`Templates/schemas/
  Templates/templates`, registered alongside `stack_counter_overlay`) -
  meant as a shared design-language element for any class's aurabars
  going forward (v11). Cast Bar then got a center `"%n"` ability-name
  text (same mechanism as the existing `"%p"` timer, confirmed via
  Prototypes.lua's Cast trigger and `Private.dynamic_texts`), matching
  real Blizzard cast bar behavior per Battlewrath's request. An
  interrupted-cast flash and a silence/stun overlay were discussed as
  considerations but not built - both would need a second trigger type
  the Cast trigger doesn't natively expose (see `CAST_ERROR_OVERLAY.md`
  for the fuller write-up on surfacing the real fail reason natively).
  Battlewrath then live-edited the name text in-game and pasted the real
  export back - synced its actual values (font Arial Narrow, size 6,
  nudged left) matching the stated intent ("visual confirmation than
  explicit confirmation... enough to register it's the right skill"),
  also picking up two structural facts the client itself adds
  (`subforeground` subRegion, text-format metadata fields) for byte
  fidelity. Current: `Necromancer/Resources_v13_import.txt` - round-trip
  verified, not yet live-tested. **Tier 1 Rotation built and live-tested,
  2026-07-06:** Necromancer's first three real rotation abilities
  (Lichfrost, Crypt Swarm, Command: Undead - real spell IDs/costs pulled
  from `db.ascension.gg`, none of which existed in this project's own
  indexed data yet) built via the new `layer_builder.py` +
  `Necromancer/inventory.py` pattern (see below) rather than one-off
  scripting - each uses `cooldown_tracker_icon` plus the new
  `power_threshold` fragment (desaturate when unaffordable, plus an
  afford-glow on Command: Undead once enough Runic Power is banked).
  Pasted into WeakAuras in-game and confirmed working. **Superseded later
  the same day (v6):** Lichfrost and Crypt Swarm were both dropped after
  being confirmed pure Runic Power builders (no cooldown, no decision
  point - see `Necromancer/slot_assignment.md`'s "SCOPE RULE" walkthrough),
  and a press-wash feature added in between (v2-v5) was pulled from
  Command: Undead's build after it never reliably fired in-game. Current
  state is just Command: Undead - see `Necromancer/slot_assignment.md`'s
  "CURRENT STATE" note at the top of its "Tier 1 Rotation" section, not
  this changelog entry, for what's actually live. Other classes get their
  own sibling folder the same way once their turn comes.
- **[AGENT_PROMPT.md](AGENT_PROMPT.md)** - baseline prompt for starting a
  fresh agent session to work on WeakAuras for this project. Paste it in
  first, then give the actual task (build a specific aura, review an
  import string, etc.) - it's deliberately task-agnostic.
- **[USE_CASE.md](USE_CASE.md)** - the *why*: the actual goal is UI
  replacement (minimize default Blizzard UI, custom taste), not just
  ability tracking. Covers design-philosophy reference research (icon-set
  vs HUD approach), and the open items still blocking real work (injection
  stability untested, no in-project reference auras yet, frame-replacement
  scope undefined).
- **[HUD_DESIGN.md](HUD_DESIGN.md)** - the settled *shape*: a five-tier
  radial HUD model (proc/condition, rotation, power-button, HP/resources,
  consumable/prep footer) and the cross-cutting rules that hold it together
  (fixed channels, self-state only, one visual grammar, adjacency by
  gameplay coupling). Reached through discussion, before any build work.
- **[CAST_ERROR_OVERLAY.md](CAST_ERROR_OVERLAY.md)** - flagged future
  feature, not built, not a blocker: an element in the Cast Bar's own
  space showing the real reason a cast failed (silenced, interrupted, out
  of mana, etc.), via a native Custom trigger reading `UI_ERROR_MESSAGE`.
  Captures the feasibility research from the Necromancer Cast Bar work -
  what the built-in trigger options can and can't detect, and why a
  Custom trigger (still fully native, no dependency) is the real path to
  the actual reason text rather than just "cast failed."
- **[AURA_BLUEPRINT.md](AURA_BLUEPRINT.md)** - the *method*: a seven-step
  checklist for turning a HUD_DESIGN.md tier into a buildable WeakAuras
  spec (Trigger Type, Aura Type, Load, Conditions), with a worked example
  that deliberately surfaces an open design gap rather than forcing an
  answer. Blueprint only - nothing here has been built or tested in-game.
- **[IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)** - the addon-level
  plan for clearing the stock UI to make room for the HUD: Bartender4 on
  the action bars, MoveAnything for whatever else. Different scope from
  AURA_BLUEPRINT.md - this is about clearing space, not building WeakAuras
  content. Live testing underway on `Weakauratest` / `Area 52 - Free-Pick`.
- **[Template_shadow.py](Template_shadow.py)** - versioned, real import
  strings for `Template_shadow`, Battlewrath's in-game positional
  scaffold for the HUD_DESIGN.md five-tier model. Fourteen captures (v0
  through v0.14, no v0.7 - superseded before it was ever tested live),
  each a decodable snapshot from an actual live test cycle rather than a
  hypothetical mockup - built, pasted in-game, screenshotted, and
  adjusted based on what that showed. v0.8 and v0.12 were both approved
  baselines in turn, since superseded. v0.13 shipped and was live-tested
  but got the Dynamic-Group buff/utility overflow wrong on two counts
  (8 new slots instead of 4, and a disconnected wide row instead of a
  compact rectangle) - kept in version history as a documented-wrong
  version, not erased. **v0.14 is current:** corrects both - 8 new
  dynamic slots (4 per side, not 6), arranged as a 2-column x 3-row
  rectangle directly below each side's 2 static icons (same x-columns,
  stacked rows immediately underneath) rather than a separate far-off
  row. See HUD_DESIGN.md's "known open questions" section for the full
  design writeup. See **[ELEMENT_INVENTORY.md](ELEMENT_INVENTORY.md)**
  for the full per-element breakdown (position, size, region type,
  expected function) - the reference to check before assigning any real
  ability to a slot. Positions from v0.4 onward are computed with
  `geometry.py` rather than hand-derived; use `space_audit.py` to check
  any future version's gaps before trusting it by eye.
- **[ELEMENT_INVENTORY.md](ELEMENT_INVENTORY.md)** - every element in
  Template_shadow.py's current version (v0.14, 36 children),
  with real position/dimension/region-type data pulled directly from the
  decoded string, grouped by row, plus the expected function each slot
  is meant to hold. Built specifically as the basis for matching real
  abilities to slots - answers AURA_BLUEPRINT.md's step 1 (which tier)
  and step 5 (anchor position) with real numbers already in hand.
- **[weakaura_codec.py](weakaura_codec.py)** - a standalone, dependency-free
  Python tool that reimplements WeakAuras' actual import-string encoding
  pipeline (LibSerialize + DEFLATE + LibDeflate's EncodeForPrint, ported
  directly from this project's installed addon source). Takes a Python
  dict/list mirroring a Lua aura table and produces a real WeakAuras import
  string to paste into the in-game Import dialog - the supported path for
  getting agent-authored aura data into the game, since direct
  SavedVariables editing was tested and confirmed not to work (see
  USE_CASE.md). Run it directly (`python3 weakaura_codec.py`) for
  self-tests. **Fully live-validated, both directions, for single auras.**
  Decode was proven byte-for-byte against a real in-game export (the
  "Test" aura's debug-table dump). Encode was then proven by pasting this
  codec's own generated import string into WeakAuras' in-game Import
  dialog - it imported cleanly, wasn't malformed, and survived
  delete/reimport. The full round trip (agent-authored Python data to a
  real in-game aura) is confirmed working end to end. This also settled
  the earlier concern about this WeakAuras install missing libraries its
  own `Init.lua` checks for - Import/Export works regardless.
  **Also now supports flat groups, fully live-validated**:
  `encode_group_import_string`/`decode_group_import_string` build/read a
  group (one parent + plain leaf children, no nesting). Decode validated
  byte-for-byte against a real captured group export ("Example_group", 4
  icon children); encode then live-tested by pasting a codec-generated
  group string into WeakAuras' Import dialog - imported with no
  malformation. Nested groups (a group inside a group) aren't supported -
  see the code comment above `encode_group_import_string` and
  `reference_library.py` for why.
  **If a pasted string ever throws an error or renders wrong in-game,
  read the "DEBUGGING CHECKLIST" in this file's own module docstring
  first** - it covers the two real failure classes hit so far
  (duplicate `uid` across children, `controlledChildren` not matching
  `c[]`) plus what to check next if it's neither of those.
- **[CAPABILITY_INVENTORY.md](CAPABILITY_INVENTORY.md)** - research packet
  for phase 1 of the `reference_library.py` expansion initiative
  (2026-07-04): a systematic inventory of what WeakAuras' real addon
  source actually supports (region types, sub-region types, trigger
  types, animations, conditions, built-in templates), grounded in real
  file paths under this build's `Interface/AddOns/WeakAuras/`. Scopes the
  task before doing it - what to read, in what order, what "done" looks
  like per category - rather than continuing to discover capabilities one
  at a time only when a specific build happens to need one. Findings get
  appended here as each category is actually read; once complete, this
  becomes the checklist phase 2 (prior-art survey) uses against each new
  pack sampled.
- **[Templates/](Templates/) + [template_filler.py](template_filler.py)** -
  phase 3 of the `reference_library.py` expansion initiative (2026-07-04):
  a JSON Schema + template pair per row in `WEAKAURA_INDEX.md`'s extended
  opportunity taxonomy (`cooldown_tracker_icon`, `proc_alert_icon`,
  `buff_uptime_icon`/`_aurabar`, `resource_threshold_aurabar`,
  `missing_buff_icon`, `enemy_cast_aurabar`, `pet_summon_countdown_icon`,
  plus two added 2026-07-06 for the Resources tier's Cast Bar and Swing
  Timer - `player_cast_aurabar` (Cast trigger, unit=player) and
  `swing_timer_aurabar` (the native Swing Timer trigger, no addon
  dependency; converted from an earlier `swing_timer_icon` attempt later
  the same day, per Battlewrath's request that both bars match) - both
  now share an "idle-shadow" mechanism (a second always-true trigger plus
  a Condition, keeping the bar visibly present but dim/empty until
  active) and a static right-side timer text - 10 total, plus
  `glow_source`/`stack_counter_overlay` fragment schemas),
  so building a new ability's aura means filling in spell IDs/position on a
  known-working template rather than re-deriving a region's field set from
  scratch each time. Every field name is pulled directly from phase 1's
  capability read (`CAPABILITY_INVENTORY.md`) or from `weakaura_codec.py`'s
  own live-validated `EXAMPLE_TEST_AURA` envelope shape - not invented.
  `template_filler.py`'s `fill_template()` validates required params,
  substitutes them into the template, and converts the JSON-only string
  trigger-index keys ("1", "2") to the real integer keys WeakAuras'
  `triggers` dict actually uses (JSON can't represent int object keys -
  see the module's own docstring for why this conversion is a deliberate
  step, not an afterthought). Handles the settled "glow-source" mechanism
  (a Rotation/Power-button icon's optional second spell ID that brightens
  it in place, per `HUD_DESIGN.md`'s Proc/Condition scope) as a list of
  length 1, so a second independent proc later is additive. Round-trip
  tested through `weakaura_codec.py`'s real `encode_group_import_string`/
  `decode_group_import_string` - fills 4 templates (including one with a
  glow-source), encodes them as a group, decodes it back, and confirms
  `controlledChildren` matches and no `uid` collides. **Not yet
  live-tested in-game** - the `conditions` block behind the glow-source
  mechanism specifically is flagged in `glow_source.schema.json` as a
  plausible-but-unverified structure, since Conditions.lua's exact schema
  wasn't fully enumerated in phase 1. Regenerate the JSON files from
  `Templates/build_templates.py` if the taxonomy in `WEAKAURA_INDEX.md`
  changes.
- **[reference_library.py](reference_library.py)** - real WeakAuras
  structures pulled from a free, public community export (Fojji's "Class
  Pack Anchors [Classic]" pack), kept as reference material rather than
  designing every anchor/section pattern from scratch. Proof of concept:
  single source so far. Surfaced a real section taxonomy to compare
  against HUD_DESIGN.md's five tiers (and two gaps: cast bars and swing
  timer aren't covered yet), a "DON'T MOVE - ..." naming convention worth
  adopting directly, a nested-anchor-group pattern, and an alternate
  texture-region proc-glow technique distinct from the icon+subglow
  approach in `weakaura_codec.py`'s own example. Also surfaced a
  weakaura_codec.py gap: group-aura exports use a different envelope
  shape (top-level `c` children array) than the single-aura envelope the
  codec currently handles - noted in the file, not yet fixed.
- **[geometry.py](geometry.py)** - reusable positional-layout math
  (row centering, exact left/right mirroring, vertical row stacking with
  per-transition gaps), extracted after building `Template_shadow.py` by
  hand rederived the same math each revision and once got it wrong
  (icons resized bigger without recomputing vertical spacing overlapped
  two rows). Self-tests reproduce `Template_shadow.py` v0.3's real
  numbers as a regression check. Documented as the standard method in
  `AURA_BLUEPRINT.md`'s "Positional geometry model" section - use this
  instead of hand-placing coordinates for any future tier/element.
  **Correction (v0.8):** row-to-row (tier-to-tier) gaps default to 0
  (touching), the same as icon-to-icon defaults to 2-4px - there is no
  separate, larger "row gap" convention. See HUD_DESIGN.md's compactness
  rule for the evidence (a live reference edit and a real Luxthos Mage
  screenshot both showed full hugging, not spaced-out tiers).
- **[space_audit.py](space_audit.py)** - reads a decoded
  `Template_shadow.py` version and produces the full gap inventory in
  one pass: every element's edges, within-row gaps, row-to-row gaps, and
  each row's own left/right span - instead of spot-checking one
  comparison at a time whenever a question comes up (which is how the
  same width/gap mismatches kept resurfacing as "surprises" across
  several versions). Built for the agent's own reasoning, not as a
  user-facing report - run it against any version before making spacing
  claims rather than eyeballing or recomputing by hand. Its "flag gaps
  over 10% of element size" check is a blunt instrument at icon scale
  (it flags plenty of already-correct 3px gaps on 30-40px icons) - useful
  for the row-span comparison, not for judging small gaps in isolation.
- **[Docs/WEAKAURA_INDEX.md](../Docs/WEAKAURA_INDEX.md)** - the methodology:
  the four opportunity types (`cooldown_tracker`, `proc_alert`,
  `buff_uptime`, `stack_counter`), how each maps to an actual WeakAuras
  trigger type, why the spell ID is what makes this usable directly (no
  guessing tooltip names - WeakAuras' Cooldown/Aura/Combat Log triggers all
  take a spell ID), and the known limitation (stack counts can
  under-report - see the Diabolical case in that doc).

- **[DEV_TOOLS.md](DEV_TOOLS.md)** - two built-in client tools found
  2026-07-06: "Show IDs in Tooltips" (Interface > Help - hover any ability
  for its real ID, no external lookup needed) and `/devconsole` (a real
  in-game Lua console - `dump`/`tinspect`/`lookup` among its commands,
  full list transcribed in the file). Stronger verification method than
  either this project's own DBC extraction or `db.ascension.gg` - both
  proved to have real gaps this session. Not yet exercised against a real
  open item; first use case is tomorrow's live-validation pass.
- **[DISCORD_POST.md](DISCORD_POST.md)** - a ready-to-paste community post
  (2026-07-05, revised same day to cut generic-WeakAuras items and keep
  only what's actually unique to this server) proposing five concrete
  documentation gaps worth the community filling: per-class resource/
  power-type identity, a shared custom spell-ID reference, a
  custom-mechanic-naming glossary, a per-class list of server-side
  mechanics with zero addon-visible footprint (genuinely untrackable, not
  just unfigured-out), and an index of existing CoA-tagged packs.
  Deliberately excludes generic "how WeakAuras works" material (import/
  export quirks, condition mechanics, pet-tracking API limits) since that
  isn't specific to this server - see the file's own "Notes for
  Battlewrath" section before posting as-is.

## Data

- [necromancer_weakaura_index.json](../Outputs/weakaura_index/necromancer_weakaura_index.json) -
  160 Necromancer abilities, each with its spell ID, `isFirstClass`
  (toolkit vs. talent), cooldown/duration/procChance/maxStacks, and a list
  of applicable opportunity types with a plain-language trigger
  description. Built by `Scripts/build_weakaura_index.py`:

  ```bash
  cd Scripts
  python3 build_weakaura_index.py ../Input/necromancer_talents.json <mpq_data_dir> ../Outputs/weakaura_index/necromancer_weakaura_index.json
  ```

- [necromancer_live_reference.json](../Outputs/live_reference/necromancer_live_reference.json)
  (2026-07-04) - a durable reference built from **real live-client captures**,
  not DBC extraction. Covers a gap the DBC pipeline structurally can't reach:
  baseline/leveling abilities with zero talent-tree link (`Undead: Pacify`/
  `Protect`/`Assault`, `Grave March`, `Bone Ward`, `Scourge Apprentice
  Training`, and dozens of ranked trainer-taught spells like `Crypt Swarm`
  ranks 1-8 and `Lichfrost` ranks 1-11), captured via the `COA_DevDump`
  addon (`Tools/COA_DevDump/`) against a real trainer NPC ("Nightmarish Book
  of Ascension") and the custom `CoATalentFrame` talent UI. **Keyed by
  ability NAME, not spellId** - a deliberate design call (Battlewrath,
  2026-07-04): rank-variant abilities can have a dozen or more distinct
  spellIds (Crypt Swarm alone has 15 in Spell.dbc), too many to track
  cleanly by ID, and WeakAuras' own name-based triggers already resolve to
  whatever rank a player has learned. `spellId` is still included as a
  best-effort field wherever independently confirmed (84 of 121 abilities),
  cross-referenced against `Input/necromancer_talents.json` by exact name -
  absent otherwise, not guessed. Every entry carries `verifiedLive: true`
  and a `source` of `"trainer"` (real gold cost/level requirement/fully
  server-resolved description text, no `$s1`-style tokens) or `"talent"`
  (spellID/rank/maxRank read directly off the live talent UI's own button
  widgets, since this server's talent system doesn't use the stock
  Blizzard talent API at all - confirmed via `GetNumTalentTabs()` returning
  0 through both known call shapes). Raw captures kept alongside for
  traceability: `necromancer_trainer_raw.json` (125 entries),
  `necromancer_talentnodes_raw.json` (80 entries).

## Reference materials (dip into Display for these)

Designing an actual aura needs more context than the index alone gives you
- what an ability's toolkit/talent status means, what a modifier talent
actually does, real cooldown/duration numbers straight from the client.
That's all in **[../Display/](../Display/README.md)**:

- The **class ability sheet** (`ability_sheets_all_classes.html`) is the
  fastest way to look up a specific ability's real stats and confirm its
  Toolkit-vs-Talents lane before deciding which opportunity type applies.
- The **DBC-sourced abilities reference** pages show the full relationship
  picture (what modifies/compounds on what) if you need to understand why
  an ability behaves the way it does before building a tracker for it.

## Not yet covered

Resource-threshold alerts (e.g. "alert at 80 Runic Power") aren't an
opportunity type yet - that needs the "Class Resource" primitive category
from `Docs/PIPELINE.md`'s still-open synthesized-family work, not just a
field filter. Revisit once that classification exists.

Necromancer only so far - same rollout status as the DBC-sourced pipeline
in Display.
