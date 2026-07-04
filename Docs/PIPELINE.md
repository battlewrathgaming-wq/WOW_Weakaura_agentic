# Talent data pipeline

How the readouts get built, and what to do when Ascension pushes a talent
tree update on Voljin Alpha (or any realm/patch change).

## 0. Folder structure

Reorganized 2026-07-01 into a flat top-level layout:

```
World of Warcraft - Conquest of Azeroth/
  Input/                  <class>_talents.json  x21  (source talent data)
    Archive/              dated snapshots of old patches (empty until needed)
  Scripts/                every .py tool + example_build.json test fixture
  Outputs/
    skill_indices/        <class>_skill_index.json  x21
    readouts/              <class>_readout.md  x21
    readout_html/          <class>_readout.html  x21
    dbc_preview/            DBC-sourced ability analysis (Necromancer only)
    class_sheets/           flat all-classes ability sheet (no relationships)
    weakaura_index/         per-ability WeakAuras opportunity data (Necromancer only)
    nested_preview/         experimental prose-regex produces/nesting model
    Archive/               deprecated/superseded artifacts (tree-diagram POC)
  Display/                README.md - pointer/index into every browsable
                          HTML deliverable in Outputs/, organized by kind.
                          Added 2026-07-02 as a navigation layer, not a copy.
  Weak Auras/             README.md - pointer/index into the WeakAuras
                          opportunity work (points at Docs/WEAKAURA_INDEX.md,
                          Outputs/weakaura_index/, and back into Display/ for
                          reference material). Added 2026-07-02.
  Docs/                   this file, WEAKAURA_INDEX.md, spell_family_index.json
```

Everything under `Outputs/` is a pure function of `Input/` + `Scripts/` -
it's always safe to delete and regenerate. `Input/` is the only folder
that requires the manual extraction step in section 2 to rebuild.
`Display/` and `Weak Auras/` are pure navigation - index/README files with
relative links into `Outputs/` and `Docs/`, never a duplicate copy of the
underlying data. Keep it that way: when a new HTML or WeakAuras-index
output gets built, add a link to it in the relevant README rather than
copying the file itself, so there's only ever one place regeneration can
go stale.

## 1. Stages

```
ascension.gg CoA Builder (live site)
        |  (A) extraction - manual/browser-assisted, not a script
        v
Input/<class>_talents.json   x21
        |  (B) python3 build_skill_index.py
        v
Outputs/skill_indices/<class>_skill_index.json
        |  (C) python3 build_flattened_readout.py      (D) python3 generate_readout_html.py
        v                                                v
Outputs/readouts/<class>_readout.md             Outputs/readout_html/<class>_readout.html
```

C and D both read the same two inputs (`<class>_talents.json` +
`<class>_skill_index.json`) independently of each other - regenerating the
HTML never requires touching the markdown and vice versa. Only stage B
needs to rerun before C/D if the source talent data itself changed.

## 2. Stage A - extraction (talent data itself changed)

This is the only stage that isn't a script, because the site is a Next.js
app with no public API. Original method:

1. Open `https://ascension.gg/en/v2/coa-builder/voljin-alpha` (or whatever
   realm/class URL) in Chrome.
2. Pull the page's RSC streaming payload (`self.__next_f.push([1,"..."])`
   blocks) via `get_page_text`/`javascript_tool` rather than the rendered
   DOM - the talent data (costs, prerequisites, descriptions, position)
   lives in that JSON, not in visible text.
3. Unescape the JSON-string-inside-a-string payload and brace-balance-parse
   out the `all_nodes` / `class_tabs` objects.
4. Map fields into the schema below. The one bug worth remembering: the
   site's `requiredIds` = hard AND-logic gate (schema field
   `specialRequirement`), `connectedNodeIds` = OR-logic "any one of these"
   gate (schema field `prerequisites`) - it's easy to get these backwards
   (we did, once) since the names don't obviously map that way.
5. Output one JSON per class into `Input/`, using the schema in section 3.

There's no shortcut here yet - if this becomes a recurring task (e.g. every
major patch), it's worth turning steps 2-4 into a saved script against a
headless browser rather than redoing it by hand each time.

Per-class accent colors used by `generate_readout_html.py` (`CLASS_COLORS`
dict) were extracted the same way, in one pass: open the class picker
modal on the CoA Builder page and read each class button's
`--coa-picker-class-color` inline style via JS - one page load covers all
21, no need to visit each class individually. Only needs re-doing if
Ascension re-themes a class.

## 3. Input schema (`<class>_talents.json`)

Top-level fields that matter for versioning:

| Field | Meaning |
|---|---|
| `schemaVersion` | Structure version of this JSON (currently `3` - see prerequisite-field fix below). Bump this only when the *shape* of the file changes, not when talent values change. |
| `extracted` | Date (YYYY-MM-DD) the data was pulled from the live site. This is the real "data version" - treat it as the source of truth for "how current is this." |
| `source` | The CoA Builder URL it was pulled from. |
| `realm` | Realm slug (`voljin-alpha`). |
| `totalTalents` | Sanity-check count; should match `len(talents)`. |
| `rules` | Documents the budget/gating mechanics in force at extraction time (spec exclusivity, partial-rank counting, row gating). If Ascension changes how talent budgets work, this block needs a rewrite, not just the talent list. |

Per-talent fields worth knowing when re-extracting: `abilityEssenceCost` /
`talentEssenceCost` (currently always 0 or 1 - see section 6), `maxPoints`
(true total point cost when nonzero), `requiredLevel`, `specialRequirement`
(AND-gate), `prerequisites` (OR-gate), `referencedTerms` (which
skill/ability name(s) this talent's description namedrops - what the
skill-index pivot is built on).

## 4. Regenerating everything for one class

```bash
cd Scripts
python3 build_skill_index.py       ../Input/<class>_talents.json  ../Outputs/skill_indices/<class>_skill_index.json
python3 build_flattened_readout.py ../Input/<class>_talents.json  ../Outputs/skill_indices/<class>_skill_index.json  ../Outputs/readouts/<class>_readout.md
python3 generate_readout_html.py   ../Input/<class>_talents.json  ../Outputs/skill_indices/<class>_skill_index.json  ../Outputs/readout_html/<class>_readout.html
```

## 5. Regenerating everything for all 21 classes

Bash loop used throughout this project - safe to rerun any time, it just
overwrites the three output files per class:

```bash
cd Scripts
for f in ../Input/*.json; do
  base=$(basename "$f" _talents.json)
  python3 build_skill_index.py       "$f" "../Outputs/skill_indices/${base}_skill_index.json"
  python3 build_flattened_readout.py "$f" "../Outputs/skill_indices/${base}_skill_index.json" "../Outputs/readouts/${base}_readout.md"
  python3 generate_readout_html.py   "$f" "../Outputs/skill_indices/${base}_skill_index.json" "../Outputs/readout_html/${base}_readout.html"
done
```

If only `generate_readout_html.py` (or only `build_flattened_readout.py`)
changed - e.g. a UI-only pass like the collapse/expand or dark-theme QOL
updates - you can drop the other two lines from the loop and just
regenerate the one output type across all 21.

**Verification pass, every time:** run `python3 -m py_compile` on any
edited script before the loop, and after copying outputs anywhere, byte-diff
or `wc -c` compare source vs. destination. Large writes into the mounted
project folder have occasionally landed truncated mid-write in this
environment; a size mismatch is the tell. When that happens, write/run from
a plain scratch path instead of the mounted one and copy the finished file
across afterward, then re-verify sizes match.

## 6. Cost-field gotcha (already fixed, but relevant if data structure shifts)

Every non-free talent currently costs exactly 1 point per rank -
`abilityEssenceCost`/`talentEssenceCost` is always `0` or `1`, never
higher. The *total* cost of investing in a talent is `maxPoints`, not the
raw cost field. If a future extraction shows per-rank costs other than 0/1,
the `points = maxPoints if per_rank_cost else 0` logic in
`build_flattened_readout.py` / `generate_readout_html.py` needs revisiting.

Zero-cost talents split into two categories, both tagged rather than shown
as "0 pts":
- `specialRequirement` non-empty + `requiredLevel == 0` -> **Starting
  Talent** (the free opener that unlocks a spec's identity mechanic).
- `requiredLevel > 0` -> **Spec passive** (the automatic level-gated
  passive chain, usually 5 rungs per spec at level 10/20/30/40/50).

## 7. Versioning input and output when the talent trees change

Recommended approach, kept deliberately lightweight for a low-risk
experimental project (no git/CI needed):

1. **Never edit a `_talents.json` in place for a patch update.** Extract
   the new version into `Input/Archive/<date>/` first (e.g.
   `Input/Archive/2026-08-15/`), leaving the live `Input/` untouched. This
   preserves the ability to diff old vs. new builds (e.g. "what did they
   nerf") without losing history.
2. Once the new snapshot is spot-checked, promote it: move the *current*
   `Input/*.json` files into `Input/Archive/<their own extracted date>/`
   (e.g. `Input/Archive/2026-07-01/`), then move the new dated files up
   into `Input/` directly. `Input/` (top level, no date) always means
   "current."
3. Regenerate all three output types for all 21 classes from the new
   `Input/` using the loop in section 5. `Outputs/` is always a pure
   function of the current input - it doesn't need its own dated archive
   unless you specifically want to keep an old readout around for
   comparison, in which case copy `Outputs/skill_indices/`,
   `Outputs/readouts/`, and `Outputs/readout_html/` wholesale into
   `Outputs/Archive/<date>/` before regenerating.
4. Bump `schemaVersion` only if the JSON *shape* changes (new/renamed
   fields, changed gating semantics) - not for ordinary talent value
   changes. Note the change in this file's section 3 table when it
   happens.
5. If the budget/gating rules themselves change (e.g. dual-spec becomes
   possible, or row-gating math changes), update the `rules` block in the
   input schema first, since `coa_toolkit.py`'s validation logic reads
   directly from it.

This keeps "what's live" unambiguous (`Input/` top level, no suffix) while
still letting you keep prior patches around for reference, without
requiring any tooling beyond folder moves.

## 8. Experimental: produces/nesting model (Necromancer only so far)

A separate, parallel pipeline - `Scripts/build_skill_index_nested.py` +
`Scripts/generate_readout_html_nested.py` - reading `Input/<class>_talents.json`
straight (not the regular skill index) and writing to `Outputs/nested_preview/`,
never touching the production files above. Same regeneration pattern as
section 4:

```bash
cd Scripts
python3 build_skill_index_nested.py     ../Input/<class>_talents.json  ../Outputs/nested_preview/<class>_skill_index_nested.json
python3 generate_readout_html_nested.py ../Input/<class>_talents.json  ../Outputs/nested_preview/<class>_skill_index_nested.json  ../Outputs/nested_preview/<class>_readout_nested.html
```

It classifies each talent-to-skill reference as `modifies` (changes the
target's own numbers) or `produces` (the target is a pet/buff/proc/stack the
talent makes appear more), via a verb-lookback regex (`PRODUCE_VERB`,
`PRODUCE_LOOKBACK` window in `build_skill_index_nested.py`). A skill that's
ever produced *with a named parent* nests under that parent instead of
getting its own top-level card, duplicated under every parent it has. It
also generalizes the family-of-spells grouping (naming convention `"X: Y"`)
to resolve headers that don't match exactly (e.g. `"Undead Stance"` for
`"Undead: Assault"`), and drops any family child whose talent list is a full
subset of its family header's - or, for a single-child family, folds that
child's one unique talent into the header and drops the child entirely
(tagged `foldedFromChild` so the origin isn't lost).

**Known edge case - "Command: Hook" (not fixed, verb-matching hits its
ceiling here):** in Necromancer, `Command: Hook` is a real talent in its own
right (Class, 1pt, "Command your Abominations to hook an enemy...") that
correctly modifies the `Abomination` skill. But the *same name* is also the
literal skill that ~20 unrelated talents ("Casting Command spells...")
modify generically, because their text never names a specific pet - the
game data just happens to resolve "Command spells" to this one literal spell
name. So `Command: Hook` is legitimately a child of `Abomination` by its own
description, *and* simultaneously the stand-in target for a completely
generic mechanic that has nothing to do with Abominations specifically. Two
things raw regex can't resolve here:

1. `"Command your Abominations to..."` doesn't match any verb in
   `PRODUCE_VERB` (summon/create/spawn/grant/trigger/apply/proc/gain) - it's
   a different relationship (grants an existing pet a new specific action,
   not spawning a new entity), so it isn't even a candidate for nesting yet.
2. Even if it were, deciding *which* pet a generic "Command" variant belongs
   to (Abomination vs Ghoul vs Banshee vs Decaying Colossus) requires
   knowing what each pet actually does in-game, not just pattern-matching
   the sentence.

Likely eventual solution: a small manual override file (talent/skill name ->
explicit parent and/or relationship kind) layered on top of the regex
classification, for the handful of cases like this per class that text
pattern-matching will never get right on its own. Not built yet - flagging
it here so it isn't rediscovered from scratch next time this gets picked
back up.

### What regex owns, vs where a manual tag is the honest answer

Worth keeping this line clear as more classes get run through the
experimental model, so new edge cases get triaged quickly instead of
re-litigated each time:

**Regex reliably owns** - anything that's a *structural* pattern in the text
or a *set comparison* over data already extracted, with no game knowledge
required:
- modifies vs. produces, when a produce verb sits tight against the target
  name (`PRODUCE_VERB` + `PRODUCE_LOOKBACK`)
- which of a talent's other named targets is the "parent" for a produces
  edge, when exactly one other target on that same talent classified as
  modifies (unambiguous by construction)
- family-of-spells structural detection (`"X: Y"` naming convention) and
  header resolution, including the prefix fallback (`"Undead Stance"` for
  `"Undead: Assault"`)
- whether a family child adds anything - a pure subset check of talent names
  against the family header's own list

These all scale automatically across all 21 classes with zero per-class
tuning, because none of them depend on knowing what a spell actually *does*
- only on how the sentence and the data are shaped.

**Regex can't own** - anything that depends on knowing what a pet/mechanic
actually does in-game, not just how the sentence is structured:
- picking which specific pet a generic, multi-target mechanic belongs to
  when the text names several candidates (or none) - "Command: Hook" is
  exactly this: legitimately Abomination's by its own description, but also
  the generic stand-in target for ~20 unrelated "Command spells" talents
- recognizing a new relationship verb (e.g. "Command your X to...") without
  risking false positives elsewhere the moment it's added to `PRODUCE_VERB`
- a family header that is *also* a legitimate standalone ability in its own
  right (dual identity) - no set comparison resolves which identity should
  win

For this second bucket, the fix is a small manual override file (e.g.
`Input/overrides/<class>_manual_tags.json`, keyed by talent/skill name,
explicit parent/kind per entry) reviewed and applied by hand for the
handful of cases per class where the text genuinely doesn't carry enough
signal - not an ever-growing regex. If a new edge case can be described as
"a pattern in the text/data," it belongs in the script. If it can only be
described as "here's what actually happens in-game," it belongs in a
manual tag.

If a proper abilities dataset ever becomes available (pet ability lists,
spell-to-caster/owner links, tooltip IDs - anything that states which pet
or unit actually owns a given ability, rather than us inferring it from
talent flavor text), that's the real fix for the "regex can't own" bucket
above, not just a bigger manual-tag file. It would let "Command: Hook
belongs to Abomination" be looked up as a known fact instead of guessed at,
and could seed or replace the manual overrides with actual anchors. Worth
checking for when picking this back up.

## 9. Experimental: DBC-sourced ability anchors (Necromancer only so far)

The abilities dataset section 8 asked for turned out to exist on disk: the
Ascension client ships a real `Spell.dbc` (WotLK 3.3.5a format, 234 fields,
936 bytes/record, 229,862 records - stock WotLK has ~48,000, so this is
heavily custom) inside `patch-T.MPQ`/`patch-S.MPQ` in the game install's
`Data` folder. That's a factual anchor - actual cooldowns, cast times, mana
costs, durations, and (critically) real spell-ID links between a talent and
whatever it triggers/teaches/modifies - instead of inferring relationships
from tooltip prose.

This is a **separate, parallel pipeline** from sections 1-8, reading
`Input/<class>_talents.json` (for the `spellId` field schemaVersion 3
already carries per talent) plus the client's `Spell.dbc` directly, writing
to `Outputs/dbc_preview/`. Three scripts, all Necromancer-only:

- `Scripts/build_ability_cards_dbc.py` - first prototype, one card per
  talent's own spell.
- `Scripts/build_abilities_reference_dbc.py` - the real class-wide page:
  every distinct ability the tree touches (own spell + everything it
  triggers/teaches/modifies), each ability as its own anchor card listing
  every talent that relates to it.
- `Scripts/generate_talent_context_dbc.py` - the same graph, tabbed per
  spec (`Class`+spec only), with abilities that have zero applying talents
  for that spec dropped entirely (flattening intent, not a full class dump).

```bash
cd Scripts
python3 build_abilities_reference_dbc.py ../Input/necromancer_talents.json <mpq_data_dir> ../Outputs/dbc_preview/necromancer_abilities_reference.html
python3 generate_talent_context_dbc.py   ../Input/necromancer_talents.json <mpq_data_dir> ../Outputs/dbc_preview/necromancer_talent_context.html
```

`<mpq_data_dir>` is the WoW install's `Data` folder (contains `patch-T.MPQ`
and `patch-S.MPQ`) - reading Spell.dbc takes ~30-40s each run.

### Relationship types (real data, not inferred)

- **`own`** - the talent's own tree-node spell.
- **`triggers`** - `EffectTriggerSpell_0/1/2`, walked 2 levels deep. A
  wrapper spell whose trigger target shares the exact same `Name_0` (e.g.
  Bone King's own spell triggers a second, differently-ID'd "Bone King"
  that carries the real duration/effect numbers) is merged into one card
  instead of rendered as two - only a genuinely different-named target
  (Command: Hook -> Grave March) becomes a separate ability.
- **`teaches`** - Ascension's own tooltip tag `@s:<id>:<mask>@` found in
  `Description_0`, parsed by `TEACH_TAG` regex. Reliable because it embeds
  a literal spell ID, not a name to fuzzy-match.
- **`modifies`** (added this pass) - the WotLK spell-family modifier
  mechanism: a talent's own effect carries a non-zero
  `EffectSpellClassMask_A/B/C`, and that bitmask overlaps (bitwise AND != 0)
  with a target spell's own `SpellClassMask_0/1/2` - required both share
  the same `SpellClassSet` (Necromancer's entire kit uses family id `29`
  uniformly, confirmed across talent stubs, implementation spells, and
  modifiers alike). This is how a cost/cooldown/cast-time talent like
  **Graverobber** ("reduces the cost and cast time of your Raise and
  Animate spells") is linked to all 11 Raise/Animate abilities it actually
  affects, without any of them sharing a trigger or teach relationship.

Matching is deliberately restricted to abilities already discovered via
`own`/`triggers`/`teaches`, not the raw ~1,300-spell family-29 pool in the
DBC - the full pool is full of debug/test spells and duplicate rank
variants (`Mixed Damage Magic Absorb Test`, a dozen near-identical
`Raise: Skeletal Warrior` IDs at different power levels) that would produce
noise, not signal. Scoping to the known ability universe kept every match
clean on inspection.

**Correction - dead effect slots carry stale classmask data.** First pass
only checked "is `EffectSpellClassMask_A/B/C` non-zero for this effect
index," without checking whether that effect index is actually *used*
(`Effect_e != 0`). Caught via user report: `Skeletal Artillery` ("Your
Animate: Skeletal Archers now summons 1 additional Skeletal Archer")
matched 5 completely unrelated spells (Raise: Ghoul, Raise: Skeletal Mage,
Raise: Decaying Colossus, Raise: Banshee, Command: Blight) and never
matched the one ability its own tooltip actually names. Root cause: its
`effect2` slot has `Effect_2 = 0` (SPELL_EFFECT_NONE - unused) but still
carries a leftover `EffectSpellClassMask` value, almost certainly copied
from whatever template spell Ascension cloned to build this one and never
cleared. That stale mask happened to share a bit with several unrelated
Raise spells' own `SpellClassMask`, producing confident-looking but false
matches - while `Skeletal Artillery`'s real effects (`effect0`/`effect1`,
both dummy/proc-type auras with `MiscValue` 3/12, not a spell-ID reference)
carry no classmask at all, meaning the true relationship isn't
classmask-encoded and belongs in the "confirmed gap" bucket alongside Army
of the Dead.

Fixed by skipping any effect index where `Effect_e == 0` before reading its
`EffectSpellClassMask`. Impact was large: **21 of the original 41
"modifier" talents were pure false positives** entirely from dead-slot
noise (Game of Bones, Winds of Northrend, Plague Science, Living Dead,
Summoning Prodigy, Lich Essence, Necrosis, Plague Protection, Bone Legion,
Withering, Lich Commander, Unholy Runes, Expediting Death, Crypt Keeper,
Frigid Death, Glacier Lord, Hoarfrost Hands, Frigid Power, Master Animator,
and Skeletal Artillery itself), and a further 4 (Touch of Death, Festering
Decay, Runic Animation, Mutation) had a mix of real and false matches that
needed the same filter to separate. Total modifier edges dropped from 133
to 86 after the fix - the remaining 86 are the real ones. This is the same
lesson as the wrapper/trigger and duplicate-name fixes: DBC field presence
alone (a non-zero value sitting in a record) is not proof of an active,
intentional relationship - always check whether the effect slot carrying
that value is actually live.

**Confirmed limitation - not everything is in Spell.dbc.** "Army of the
Dead" (buffs Ghoul crit/haste conditional on how many Abominations are
out) has `SpellClassMask` and `EffectSpellClassMask_A/B/C` all zero on its
own record - this relationship is implemented as custom Ascension
server-side scripting (checking pet type at cast time), invisible to any
client-side data. This class of relationship stays permanently
text-only/unresolvable from game files; it's the same "regex can't own it"
bucket from section 8, just confirmed from the factual side now instead of
assumed.

### Duplicate-name canonicalization

The classmask pass surfaced a second, independent cause of duplicate cards
(distinct from the wrapper/trigger merge above): Ascension sometimes ships
multiple spell IDs for the *exact same named ability*, reached
independently by different talents rather than via a shared trigger chain
(e.g. `Crypt Plague` existed as both spell 570131 and 92121 in the
Necromancer universe). Fixed with a canonicalization pass - group all
discovered ability ids by `Name_0`, keep one id per name (preferring an id
that is itself some talent's own `spellId`), remap every edge to the kept
id. Necromancer: 11 duplicate-name groups collapsed (193 -> 180 distinct
ability cards), while total talent-application coverage went **up** (192
old regex-model associations -> 340: 160 own + 133 modifies + 38 triggers +
9 teaches), since `modifies` alone added more real associations than the
canonicalization removed.

### Display grouping tags

Per the "custom tags to help group the display" idea from section 8:
rather than inventing labels for what an individual `SpellClassMask` bit
means (there's no official legend, and the same bit means different things
depending which other bits it's combined with - not a clean 1:1 mapping),
each ability card gets a **family badge** from Ascension's own naming
convention (`"Raise: X"` / `"Animate: X"` / `"Command: X"` -> badge `Raise`
/ `Animate` / `Command`). This is the same structural signal section 8's
family-of-spells grouping already relies on, just surfaced as a visible tag
on the DBC-sourced cards too, instead of trying to reverse-engineer bit
semantics that the data doesn't actually name.

### The "compiled index" - what's anchored so far

`Docs/spell_family_index.json` is the seed of a small, hand-verified table
(not auto-generated, not guessed) recording what's been empirically
confirmed about Ascension's `SpellClassSet` family ids - so far just
`29 -> Necromancer` (1,311 total spells in that family client-wide, 180
surfaced as player-facing abilities in the current tree). Extend this file
per class as the DBC pipeline gets run against them, rather than
re-deriving the family id from scratch each time.

### Text normalization (`Scripts/tooltip_normalize.py`)

Raw `Description_0` text is not display-ready: it's the WoW client's own
tooltip source, full of `|cAARRGGBB...|r` color codes and `$`-variable
tokens (`$s1`, `$504862m1`, `${$504862m1*2}`, `$/1000;302910S2`, `$t1`,
`$a1`, `$?s<id>[X][Y]`, `@ext:...:ext@`, etc). `tooltip_normalize.py`
resolves the confirmed token types against the spell's own record or a
cross-referenced spell (see the module's own docstring for the full list
and the worked examples that pin down each format - e.g. Command: Banshee's
raw `19` resolves to displayed `20%`/`40%`, confirming the WotLK
`abs(EffectBasePoints+1)` display convention). Needed a float-aware reader
for `SpellRadius.dbc` specifically (id + 3 floats, not ints - confirmed
against raw bytes, id 7 = 2.0 yds). Anything that needs live caster stats to
compute (spell power, intellect - `$SP`, `$INT`, `$sps`, `$spfr`) is shown
as `(scales with caster stats)` rather than a fabricated number - this
module normalizes static text, it does not calculate.

Every card's `desc` (own ability text and the wrapper/impl merged-note
text) is run through this normalizer. Additionally, each `modifies`-type
talent entry now carries a `note` field - the modifying talent's own
normalized description - so a reader looking at e.g. "Raise: Ghoul" can see
right there in the talent list that "Graverobber" modifying it means
"Reduces the mana cost and cast time of your Raise and Animate spells by
30%," without navigating to Graverobber's own card. Worth flagging: a
modifier's own tooltip text doesn't always name every ability its
classmask actually touches (e.g. Skeletal Artillery's text only describes
its extra-summon effect, but its classmask also matches Raise: Ghoul) - the
note shows what the talent's tooltip says, which is a reasonable proxy but
not a per-target-specific description.

### Spells are first-class, not talents - the `compounds` relationship

User feedback after reviewing Army of the Dead's card: it showed as its own
isolated card with nothing pointing to it, when conceptually it should
appear nested under **both** `Ghoul` (it buffs their crit/haste) and
`Abomination` (its effect scales off how many are active) - neither of
which is a classmask/spellId relationship, both are stated only in prose.
The deeper point: the pipeline was still implicitly treating *talents* as
the first-class thing being organized, with abilities as anchors talents
happen to attach to. The actual goal is the reverse - abilities/mechanics
are the anchors, and ANY spell that compounds on one should show up there,
whether or not it's a talent's own tree node.

Two changes:

1. **New `compounds` edge type** - a name-mention scan. Ascension's
   `"Raise: X"` / `"Animate: X"` / `"Command: X"` naming convention gives a
   reliable "bare name" for each pet/mechanic anchor (`Ghoul`,
   `Abomination`, `Skeletal Archer`, ...). Every ability's normalized
   description (not just talents' - the full 180-card universe) is
   scanned for other abilities' bare names (word-boundary match, simple
   plural). A hit becomes a `compounds` edge from the mentioning spell to
   the mentioned ability. Confirmed: `Army of the Dead` -> both `Raise:
   Ghoul` and `Raise: Abomination`. Necromancer: 26 compounds edges found.
   Known limitation, deliberately left as-is for now: a mentioning spell
   whose OWN name happens to contain the anchor's bare name (e.g.
   `Frenzied Ghoul`'s description literally contains the word "Ghoul")
   produces a match that's more "same lineage" than "deliberate compounding
   effect" - still arguably useful (it IS a related form), just worth
   knowing the mechanism can't yet tell the two apart.

2. **Generalized entry-building to not require a talent record.** The
   `compounds` scan (and in principle any edge) can have a *source* that
   isn't itself a talent's own spellId - e.g. `Frenzied Ghoul` is a
   non-talent spell only reachable via a teach tag on the talent `Ghoul
   Mastery`. The old code silently dropped any edge whose source wasn't in
   `talent_by_spell_id` (built the entry from `talent['tree']` etc, so a
   `None` there meant no entry at all). Fixed to build every entry from the
   source spell's own record (name always available), attaching
   `tree`/`maxPoints` only when the source genuinely is a talent's own
   node - otherwise those fields are `null` and the UI shows "non-talent
   spell" instead of fabricating a tree. For the per-spec page
   (`generate_talent_context_dbc.py`), a non-talent source's spec
   eligibility is inherited from whichever talent(s) actually discovered it
   in the first place (`ability_owner_trees`, built from the
   own/triggers/teaches edges before the compounds pass runs).

3. **Section label changed from "Talents" to "Related spells"** on both
   DBC-sourced pages, since an entry can now be a talent, a triggered
   spell, a taught spell, a classmask modifier, or a prose-mentioned
   compounding spell - "Talents" stopped being an accurate description of
   what's listed there.

### Not yet done

- Rollout beyond Necromancer.
- Reconciling/merging this DBC-sourced model with the production pipeline
  (sections 1-7) or the prose-regex nested model (section 8) - all three
  currently coexist as separate, independently-useful experiments.
- Telling deliberate compounding mentions apart from same-name/lineage
  coincidences in the `compounds` scan (see limitation above) - left alone
  for now per explicit direction, revisit if it gets noisy at scale.

### Next phase direction: a per-spell JSON record, not more per-issue passes

This session landed four real fixes (dead-effect-slot classmask false
positives, duplicate-name canonicalization, wrapper/trigger merge, the
talent-first-class blind spot that missed `compounds`) as separate patches
layered onto the same two scripts (`build_abilities_reference_dbc.py`,
`generate_talent_context_dbc.py`), which duplicate almost the entire
graph-building pass between them. Explicit direction for next pickup: stop
adding fixes one issue at a time and instead define a **canonical per-spell
JSON record** - one first-class object per real spell ID (not per talent),
something like:

```
{
  "id": 500971, "name": "Raise: Ghoul", "family": null,
  "own": {cooldown, castTime, manaCost, school, duration, effectBasePoints, desc},
  "relationships": [
    {"sourceId": 503757, "type": "modifies", "confidence": "high", "basis": "classmask"},
    {"sourceId": 800001, "type": "compounds", "confidence": "medium", "basis": "name-mention"},
    ...
  ]
}
```

Build this once per class as an intermediate artifact (e.g.
`Outputs/dbc_preview/necromancer_spells.json`) that both the class-wide
reference page and the per-spec page read from, instead of each script
independently re-deriving the whole graph from raw Spell.dbc. A `basis`/
`confidence` field on each relationship (classmask vs name-mention vs
trigger-chain vs teach-tag) would also let filtering/routing decisions
(e.g. "hide low-confidence name-mention matches," "flag self-name
coincidences") become a query over the JSON rather than another
if-statement threaded through two rendering scripts. Not started - this is
a data-architecture note for the next session, not a request to rebuild
now.

**Case study confirming this is the right call, not fixed ad hoc:**
`Plague Horde` (talent spell 802986, Animation) surfaced three distinct
problems at once, each a different flavor of the same root cause (treating
"one relationship type = one regex/rule" instead of a structured record):

1. **Raw teach-tag leaking into display text.** `TEACH_TAG` extracts the
   id from `@s:807653:0@` to build the `teaches` edge, but never strips the
   tag itself out of the normalized description - so `@s:807653:0@` shows
   up verbatim at the end of the card text. `tooltip_normalize.py` doesn't
   own this because it's not really a *tooltip* variable, it's the same
   custom Ascension "teach" tag `TEACH_TAG` already parses elsewhere -
   two different modules both need to agree on stripping it.
2. **Duplicate-name canonicalization merged two DIFFERENT spells.**
   Verified: spell 807653 is *also* named "Plague Horde" but is a
   completely different effect (a self-Enrage buff on the minion, `Effect
   6,6,6`, no trigger chain) from 802986 (the proc-cast-a-Zombie-Plague
   effect, `Effect 190,190`, triggers `504022`/`803557`). These aren't a
   wrapper/impl pair like Bone King - they're two unrelated spells that
   happen to share a display name for flavor reasons. The exact-name
   canonicalization rule (built to fix the Bone King/Crypt Plague case)
   collapsed them into one card anyway, producing a confusing
   self-referential-looking "Plague Horde own" + "Plague Horde teaches"
   pair on the same card. Telling these two cases apart needs more than a
   name match - probably effect-shape similarity, not just identical
   `Name_0`.
3. **Family tagging by name-prefix is too narrow.** `Plague Horde` has no
   `"X: Y"` prefix so gets no family badge, but it's conceptually in the
   same produces/summon category as the `Raise:`/`Animate:` cards (it
   causes a minion to proc-summon an effect). The naming-convention
   shortcut only catches abilities Ascension happened to name with a
   colon - a real family classification needs to look at what an ability's
   effects actually *do* (trigger chains, summon effects), not just its
   string shape.

None of these were patched individually - captured here as concrete design
inputs (verified against real DBC data, not guessed) for whenever the
per-spell JSON schema work above gets picked up.

### First-class vs. second-order: the `PASSIVE` attribute flag

Working session with the user landed a real product framing: the resource
is grounded around "if I click this ability, what makes it more powerful?"
- which means every ability needs to be sorted into exactly two buckets
before anything else happens:

- **First-class** - something that teaches you an ability you can actually
  interact with (you press it, it does its thing) - e.g. `Raise:
  Abomination`. These are the page's real anchors/sections.
- **Second-order** - a talent whose entire purpose is to modify or produce
  a first-class ability, with no independent press of its own (Grave
  Mastery, Graverobber, Army of the Dead, Skeletal Artillery). These nest
  under their parent(s) via the existing `modifies`/`compounds` edges - no
  top-level section of their own.

First attempt at this split used "does it have an outgoing
`modifies`/`compounds` edge" as the test - **wrong**, caught immediately:
`Command: Hook`/`Command: Blight`/`Command: Bonefreeze` all have outgoing
`compounds` edges (their text names the pet they're used through: "Command
your Abominations to hook..."), but they are absolutely still first-class -
each is its own real, separately-castable, separately-cooled-down action.
The `compounds` edge staying visible on their cards is correct and useful
regardless of this classification question - the bug was conflating "is
this edge worth showing" with "does this edge disqualify the source from
being first-class." Those are different questions.

**The real signal, found by checking the DBC directly rather than parsing
prose again: WotLK's `SPELL_ATTR0_PASSIVE` attribute bit (`Attributes &
0x40`).** A spell with this flag is, by the game's own data, never
directly cast - it's an always-on effect once learned. Checked against all
180 Necromancer cards: **123 passive / 57 active**, and every previously
confirmed case lands correctly - Grave Mastery, Graverobber, Army of the
Dead, Skeletal Artillery, Bone King (surprising given the name, but it
turns out to be a passive proc, not a summon-and-press ability) all read
`passive=True`. `Raise: Abomination` and all three `Command: X` spells read
`passive=False` (genuinely first-class, confirmed - each has its own real
`RecoveryTime` cooldown). Zero regex, zero prose parsing - this is a single
bitflag check and it is the primary `isFirstClass` determination for the
per-spell JSON schema.

### Synthesized family grouping - still open, explicitly flagged for later

The passive-flag test correctly keeps `Command: Hook`/`Blight`/`Bonefreeze`
in the first-class bucket, but doesn't capture the user's mental model:
conceptually these are three mutually-exclusive *outcomes* of pressing one
button ("Command"), not three independent buttons - "the ability is
Command; the modification is that when you press Command, if you have an
Abomination present, it now casts Hook." Checked whether a literal
"Command" spell exists to nest them under: no - every DBC spell literally
named "Command" belongs to a completely different class's `SpellClassSet`.
For Necromancer, "Command" is a pure UI/keybind concept with no backing
spellId at all.

So there's a second axis beyond first-class/second-order: some first-class
actives need to visually collapse under a **synthesized (virtual, no real
spellId) parent** - built from the existing `"X: Y"` naming-convention
family tag, when multiple active siblings share a prefix that has no
literal base spell of its own. Explicitly flagged by the user as "something
to develop" rather than solved now, and noted to be a bigger category than
just this one naming pattern - **procs, class passives, and stat mods all
live in this same "grouped, not fully independent" space** and will need
the same synthesized-parent mechanism, not just the `Command:` case. Not
started. When it is: the per-spell JSON schema sketch above should grow an
`isFirstClass` boolean (from the passive-flag check) and a `syntheticGroup`
field (nullable - the virtual parent name/id a card collapses under, if
any), separate from the real `relationships` list.

**First step when picked back up: assess every class (not just Necromancer)
to find trending/recurring concepts worth promoting to custom parents.**
`Raise:`/`Animate:`/`Command:` are Necromancer-specific naming conventions
- the synthesized-parent idea needs to generalize across all 21 classes'
own vocabulary. Candidate primitive categories identified so far, each
grounded in a real Necromancer card that doesn't fit the pet-summon family
at all:

- **Class Resource** - `Glacial Tap` ("instantly regenerating 30 Runic
  Power") - explicitly flagged by the user as ambiguous against the next
  category: its own modifier, `Lich's Prodigy`, changes both the resource
  amount AND the cost, so a single card can plausibly belong to more than
  one primitive.
- **Class Stat Mods** - `Summoning Expert` ("Increases your maximum Life
  Force by 1 and your Undead minion's Stamina by 10%"), `Life For Power`
  ("absorb 20% of healing taken and gain a shield") - flat/passive
  character or pet stat changes with no summon and no resource generation.
- **Class Effect Procs** - `Mindless Fury` ("Casting Animate or Command
  spells now increases your haste by 1% for 10 sec, stacking 5 times") -
  reactive, triggered off the player's OWN actions rather than pressed
  directly.
- **Utility** - `Create Frozen Reliquary` ("Create 1 Frozen Reliquary that
  restores 30% of your missing mana") - a consumable/tool-creation effect,
  not a combat stat or resource mechanic at all.

Not started - this is the concrete jumping-off point for the next session's
first task: run this same card-by-card read across all 21 classes' Spell.dbc
data before finalizing what the primitive category set actually is, rather
than generalizing from Necromancer alone.
