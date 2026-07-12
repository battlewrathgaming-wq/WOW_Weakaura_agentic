# COA data — raw handoff (for Python)

Everything is JSON (`json.load`) except `spell_enums.py`, which you `import`. Load and go — no
lookup layer, no API. Decompiled from the client's own `Spell.dbc`, cross-checked ~99.9% vs a live
in-game scrape (not tooltip-scraped).

## Class keys — read this first

The `class` field (and the inventory filenames) is the internal **UnitClass token**, which for 7
classes is a dev codename ≠ the player-facing name. **Use the `display` field for the real name.**
The 7 that differ:
`SONOFARUGAL`=Bloodmage · `DEMONHUNTER`=Felsworn · `FLESHWARDEN`=Knight of Xoroth · `MONK`=Templar ·
`PROPHET`=Venomancer · `WILDWALKER`=Primalist · `SPIRITMAGE`=Runemaster. The other 14 tokens equal
their display name. `spec` is the tree/spec within a class (e.g. Necromancer → Rime).

## Core

**`dependencies/coa_spells.json`** — the spell table. `dict[str spellId] -> record`. **9,152 spells**
(6,922 class-hooked + 2,230 reached via the proc graph). Each record:
```
name, rank, icon, cooldownMs, castTimeMs, durationMs, gcdMs, maxRange,
powerType, manaCost, manaCostPct, schoolMask, mechanic,
attr[8], targets, procFlags, procChance, procCharges, spellClassSet, spellClassMask[3],
effect[3], effectAura[3], effectMisc[3], effectTriggerSpell[3], effectTargetA[3],
baseLevel, spellLevel,
coa: { direct:[{class, display, spec, source, ability}],
       triggeredBy:[{class, spec, ability, via}],     # this spell reached via another's proc
       relation: "direct" | "triggered" }
```
`effect/effectAura/effectTargetA` are raw enum numbers — decode with `spell_enums.py` below.

**`Weak Auras/ability_inventory/out/<CLASS>.json`** (×21) — per-class ability inventory,
**4,565 abilities / 3,612 talents**. `{ class, display, abilities: { name -> {spec, sources,
primarySpellId, spellIds[], cost, levelReq, isPassive, iconPath, description} } }`. Rank variants are
grouped under `spellIds[]`. (`captures.json` alongside = the raw in-game scrape.)

**`Outputs/lane_index.json`** — behavioural lane per ability. `{ count, byClass: {CLASS:{spec:
{lane:[ability]}}}, abilities:[{class, spec, ability, spellId, lane, active, why:{effects, auras,
who, passive, channeled, proc}}] }`. Regenerate: `py Scripts/classify_lanes.py --emit`.

## Decoders / reference

**`Scripts/spell_enums.json`** — pure data, nothing to run: `EFFECT`, `AURA`, `TARGET` (num→name),
`EFFECT_MAX` / `AURA_MAX` (a code above the max = Ascension-custom, unnamed), and `ATTR_flags`
(bit-AND against `attr[0]`/`attr[1]`). Turns the raw numbers in `coa_spells.json` into meaning.
Sourced verbatim from TrinityCore/WPP. (`target_category` and the attr bit-checks are trivial to
reproduce from these tables.)

**`Weak Auras/wa_index/index.json`** — the WeakAuras capability index, **1,042 levers**:
`list[{section, namespace, name, role, type, values, ...}]` (section ∈ load/trigger/region/
subregion/animation). Companions: `value_domains.json`, `aura_trigger_schema.json` (the Aura/
buff-window trigger, by catch/resolve/show/read).

## Fidelity — raw vs adapted (if you need it raw-accurate)

**Raw from `Spell.dbc` — trust as-is:** `name, icon, castTimeMs, durationMs, maxRange, powerType,
manaCost, manaCostPct, schoolMask, mechanic, attr, procFlags/Chance/Charges, spellClassSet/Mask,
baseLevel, spellLevel`, and the raw `effect / effectAura / effectMisc / effectTriggerSpell /
effectTargetA` **numbers**.

**Resolved — faithful but derived (so you can re-derive if you want):**
- `cooldownMs` = `max(RecoveryTime, CategoryRecoveryTime)`.
- `castTimeMs / durationMs / maxRange` = looked up via their companion DBCs (index → value).
- enum **names** (via `spell_enums.json`) = sourced from TrinityCore/WPP; in-range accurate, but
  **Ascension-custom** codes (`effect>164` / `aura>316`) resolve to `CUSTOM_*` — we can't name them.

**Our interpretation — adapt / verify for your own accuracy:**
- the **`coa` block** (class:spec, `direct`/`triggeredBy`) is OUR mapping from the ability inventory
  (talent + in-game scrape), NOT a DBC field — can have gaps or mis-attribution.
- the **proc closure** (`triggeredBy`, `via`) is our BFS over `effectTriggerSpell` (depth ≤ 3).
- **`lane_index.json`** is a FIRST-CUT classification with **provisional lane names** — a read, not
  ground truth. Re-lane freely.
- `ability_inventory` is merged from 3 sources; the grouping, `display`, and `spec` are our processing.

**Validation:** DBC cross-checked **~99.9%** vs a live in-game scrape (cooldowns) — high, not 100%.
Class tokens confirmed first-hand via `UnitClass`.

## Not for the first drop (huge / regenerable)

`Outputs/spell_dbc/spell_dbc_full.json` — ALL ~237k game spells (163 MB). Send `coa_spells.json`
(the filtered 9,152) unless they explicitly want the whole game.

## What's in-repo vs regenerate

- **In repo (tracked):** `coa_spells.json`, `ability_inventory/out/*`, `wa_index/*`, `spell_enums.py`
- **Regenerate before sending:** `lane_index.json` (`--emit`), the full DBC store (extract script)
