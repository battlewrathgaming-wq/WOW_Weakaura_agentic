# WeakAura opportunity index

A separate reference from the talent-relationship pipeline (PIPELINE.md) -
built for one specific question: **which of a class's abilities are worth
building a WeakAura for, and what does the trigger need?**

Necromancer only for now. Script: `Scripts/build_weakaura_index.py`. Output:
`Outputs/weakaura_index/necromancer_weakaura_index.json`.

```bash
cd Scripts
python3 build_weakaura_index.py ../Input/necromancer_talents.json <mpq_data_dir> ../Outputs/weakaura_index/necromancer_weakaura_index.json
```

## Why the spell ID matters

Every field in the index comes straight from Spell.dbc, and the `spellId`
on each entry is exactly what WeakAuras needs to build a trigger - "Spell
- Cooldown Progress," "Aura," and "Combat Log" trigger types all take an
exact spell ID (or name, which resolves to an ID client-side anyway).
Nothing here requires guessing an in-game tooltip name - the ID is already
resolved and verified against the real client data by the rest of this
pipeline.

## The four opportunity types

Each is a plain filter over fields already extracted elsewhere in this
project - no new game knowledge, no prose parsing.

**`cooldown_tracker`** - a first-class (toolkit) ability with a real
cooldown. You press this yourself; you want to know when it's up again.
→ WeakAuras trigger: **Cooldown Progress (Spell)**, spell ID direct.
Example: `Glacial Tap` (spell 805369, 12 sec CD).

**`proc_alert`** - a second-order (talent/passive) ability with
`ProcChance < 100`. It fires on its own, without you pressing anything, and
a sub-100% chance means it's easy to miss entirely without a visual cue.
→ WeakAuras trigger: **Combat Log > Spell Cast Success / Aura Applied**,
filtered to the spell ID. Example: `Graverobber` (spell 503757, 33%
chance - though Graverobber itself is a permanent passive modifier, not a
proc; a cleaner proc_alert example from the same data is any talent with
`isFirstClass: false` and a sub-100 `procChance` tied to a triggered
effect, not just its own permanent-uptime aura).

**`buff_uptime`** - has a real, non-instant duration. Splits into two
display styles: a **permanent on/off icon** when `durationMs` is negative
("Until cancelled" - a toggle state, not a timer) or a **countdown bar**
when it's a positive, finite number.
→ WeakAuras trigger: **Aura**, spell ID direct.

**`stack_counter`** - `CumulativeAura > 1` on the ability's own record.
→ Not a trigger of its own - a stack-count text/overlay layered on
whichever trigger above already applies.

`isFirstClass` (the same `SPELL_ATTR0_PASSIVE`-bit test documented in
PIPELINE.md) is what decides `cooldown_tracker` vs. `proc_alert` -
you don't put a "ready to press" icon on something you never press.

## Known limitation - stacking data can under-report

This index does NOT apply the wrapper/same-name-trigger merge the main
DBC pipeline uses (PIPELINE.md section 9). A number of talents' own
records are just a thin wrapper - the real `CumulativeAura`/duration value
lives on a second, differently-ID'd spell the wrapper triggers (same
pattern as Bone King). Confirmed case: `Diabolical` (spell 704723) shows
`maxStacks: null` here, but its actual stack cap (15) lives on a different
spell (706504) referenced only in its description text
(`$706504u`), which this simpler script doesn't resolve. Necromancer's
count of 2 `stack_counter` hits is very likely an undercount for this
reason - worth revisiting if this index gets used seriously, by reusing
the merge logic from `build_abilities_reference_dbc.py`.

## Extended taxonomy (2026-07-04) - new opportunity types + the glow-source mechanism

Settled while scoping phase 3 of the WeakAuras reference/template work (see
`Weak Auras/USE_CASE.md`'s three-phase plan and
`Weak Auras/CAPABILITY_INVENTORY.md`'s phase-1 findings, which is where the
extra trigger types below were actually confirmed to exist). Four new
opportunity types, closing gaps this doc already flagged or that phase 1's
capability read surfaced:

| Opportunity type | Trigger | Region (tier) | Spell IDs | Status |
|---|---|---|---|---|
| `resource_threshold` | Power/Health status trigger + a `subtick` marker at a fixed value | `aurabar` (Resources) | 0 (unit resource, not spell-based) | Closes this doc's own former "not yet covered" gap - `subtick`'s existence (`CAPABILITY_INVENTORY.md`) is what makes it buildable without waiting on PIPELINE.md's "Class Resource" primitive work. **Template built:** `Weak Auras/Templates/resource_threshold_aurabar.*` |
| `missing_buff` | `aura2`, `matchesShowOn == "showOnMissing"` | `icon` (Buffs/Utility dynamic slots) | 1 | Already load-bearing in the live scaffold (`Template_shadow.py` v0.13+). **Template built:** `Weak Auras/Templates/missing_buff_icon.*` |
| `enemy_cast` | Cast, `unit = target/focus` | `aurabar` or `icon`, a future DynamicGroup module | 0-1 (can filter to specific dangerous casts, or show any) | Confirmed buildable (`Prototypes.lua`), not built into Template_shadow - sits outside the five HUD tiers by design (variable-count, not fixed-address). **Template stub built:** `Weak Auras/Templates/enemy_cast_aurabar.*` (structural only, per its own schema's "verified" note) |
| `pet_summon_countdown` | Cooldown Progress (Spell) keyed to a `SPELL_..._SUMMON` combat-log event, hardcoded duration per summon type | `icon`, a class-specific pet tracker | 1 (the summon spell) | Confirmed real-world pattern (Necromancer Temp-Summon Tracker, `db.ascension.gg` - see `USE_CASE.md`). **Template built:** `Weak Auras/Templates/pet_summon_countdown_icon.*` |

**All four opportunity types above, plus the original `cooldown_tracker`,
`proc_alert`, `buff_uptime` (both icon and aurabar variants), now have a
real JSON Schema + template pair - see `Weak Auras/README.md`'s
`Templates/` entry. Round-trip tested through `weakaura_codec.py`'s real
encode/decode; not yet live-tested in-game.**

**The glow-source mechanism - not a fifth new type, a second role the
existing types can play.** `HUD_DESIGN.md`'s Proc/Condition tier already
settled that when a procced ability has its own Rotation button, that
button reacting in place (brighten/glow) *is* the proc communication - no
separate icon needed. Mechanically, that means a `cooldown_tracker`
template (a Rotation or Power-button icon) can optionally carry a **second
spell ID**, itself just a normal `proc_alert` or `buff_uptime` row from
this same table, that drives a Condition setting the icon's `subglow`
properties (`glow`/`glowType`/`useGlowColor` - see `CAPABILITY_INVENTORY.md`)
instead of getting a region of its own. Nothing new to classify - `proc_alert`
and `buff_uptime` already cover "what counts as a proc/buff worth
watching"; this just names the second job either can do.

**Corrected against a real capture (2026-07-04).** The `conditions` shape
this mechanism relies on was originally a guess; Battlewrath pasted a real
single-icon import string ("Multi-condition example") that settled its
actual shape once decoded - see `CAPABILITY_INVENTORY.md`'s "Conditions"
section and `weakaura_codec.py`'s `REAL_MULTI_CONDITION_EXAMPLE_STRING`
for the full write-up. `conditions` is a list (not a dict), and a change's
target property (`sub.N.glow`) addresses the glow subRegion by its actual
1-based position in the aura's `subRegions` array, not a fixed index -
`template_filler.py` has been corrected accordingly. The one piece still
unconfirmed: the real capture only showed a trigger reacting to *its own*
state, not a genuinely second, independent trigger - so the specific
two-trigger glow-source case remains inferred by analogy pending a real
two-trigger example or a live test.

**Settled scope (2026-07-04): one glow-source per template for now.**
Battlewrath: "I think settling for 1 effect is fine. Expanding that
feature is mostly just adding another of the same schema section" - so
phase 3's JSON Schema should model the glow-source slot as a **list**
(length 1 today) rather than a single fixed field, so supporting an
ability with two independent procs later is purely additive (append
another entry to the same array) rather than a schema change.

## Not yet covered

**Resource-threshold alerts** now have a classification (`resource_threshold`
above) and a confirmed buildable mechanism (`subtick`), but no actual
extraction pipeline yet - PIPELINE.md's "Class Resource" primitive
category (which unit resource is a spell/class actually keyed to) is still
the open dependency for generating these automatically from ability data,
same as before. The gap has moved from "no classification" to "classified,
mechanism confirmed, extraction not wired up" - worth being precise about
which of those three it still is when this gets picked up again.

## Worked example (from the real Necromancer output)

| Ability | Spell ID | isFirstClass | Opportunity | Trigger |
|---|---|---|---|---|
| Glacial Tap | 805369 | true | cooldown_tracker | Cooldown Progress (Spell) |
| Graverobber | 503757 | false | proc_alert + buff_uptime | Combat Log (33%) + permanent Aura icon |
| Raise: Ghoul | 500971 | true | buff_uptime | Aura, permanent on/off icon (pet is up or not) |
| Diabolical | 704723 | false | buff_uptime | Aura, permanent icon (stack count under-reported - see limitation above) |

Necromancer totals from this pass: 23 cooldown_tracker, 37 proc_alert, 148
buff_uptime, 2 stack_counter (out of 160 talents).
