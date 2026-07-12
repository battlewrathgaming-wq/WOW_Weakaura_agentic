# WA state sheets — the complete sourced option surface

A **state sheet** is the whole configurable surface of a WeakAura, per domain and type, laid out
statically as JSON (machine, for the generation pipeline) + Markdown (human, for reasoning). It is the
*reasoning canvas*: a `parts/` file is a **projection** of a sheet (the holes we chose to drive + the
locked seeds); the sheet is the full menu those choices are made from.

Why it exists: the corpus shows only what users *selected*; hand-built parts show only what we *considered*;
the source has everything but as a multi-step trace, not a browsable menu. The sheet pays that trace **once**,
from source, so design reads instead of re-derives. Disk is cheap; reasoning is scarce — so it emits generously.

## Layout — one folder per WA DOMAIN

```
statesheets/
  trigger/      spell.json · unit.json · item.json · event.json · combatlog.json · addons.json   (+ .md)
  load/         (TODO)   the load-condition options
  display/      (TODO)   per region type (icon, aurabar, …)
  animations/   (TODO)   the animation options
```

A WA has several domains (load · trigger · display · animations · …); each gets its own folder.

## Trigger types — the sourced worklist

The trigger-type list is **not hand-picked**. It is `set(p.type for p in event_prototypes)` (== WA's
`Private.category_event_prototype`) plus two specials WA drives outside the prototype system:

| type | UI category | source |
|---|---|---|
| `unit` | Player/Unit Info | event_prototypes |
| `item` | Item | event_prototypes |
| `spell` | Spell | event_prototypes |
| `event` | Other Event | event_prototypes |
| `combatlog` | Combat Log | event_prototypes |
| `addons` | Other Addon | event_prototypes |
| `aura2` | Aura | BuffTrigger2 (special, TODO) |
| `custom` | Custom | GenericTrigger custom path (special, TODO) |

## What a sheet row records

Each event fans out to `options.{inputs, provides, internal}`:
- **input** — has a control (`arg_type`); the user *fills* it. `input_kind` = reference/toggle/value/dropdown.
- **provides** — `arg_type=None, store=true`; a state field the trigger *outputs* (read by conditions / subregions).
  Captures are **blind** to these (never written to a clean-slate export) — they exist only in source.
- **internal** — neither; a test-only field.

Per row: `value_domain` (from the grounded index), `default`, `required_seed` (required → `use_X=true`),
`gated`/`enabled_when` (has an `enable` → conditional; the readable condition is a fast-follow), and any
companion-toggle `policy` (e.g. exact-spell-name → **our-policy OFF**, match-family-not-rank).

`default_state` per event = the seed the emitter would plug (required→`use_X` + scalar defaults; exact off).
For Spell Usable this is `{type:spell, event:"Action Usable", use_spellName:true}` — byte-identical to the
native exact-off capture, i.e. source-emit == real UI. Captures validate the **input** surface; source
alone reveals the **provides** surface.

## Regenerate (deterministic)

```
py ../emit_state_sheet.py            # all sourced trigger types
py ../emit_state_sheet.py spell      # one type
py ../emit_state_sheet.py spell --no-md
```

Source: `event_prototypes` via `extract.lua` (the authority) + `index_grounded.json` (value domains, display,
input_kind). Fast-follows: readable `enabled_when` (enable-dependency probe = tier-1 exclusivity), the
region-needs × trigger-provides map (tier-2, the icon-vs-power class), subregion fan-out, and the two special types.
