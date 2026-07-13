# WA state sheets — the complete sourced option surface

A **state sheet** is the whole configurable surface of a WeakAura, per domain and type, laid out statically
from WA source: JSON (machine, for the pipeline) + Markdown (human) + a light **routing index** (browse-menu).
It is the *reasoning canvas* — the sheet pays the source-trace **once** so design reads instead of re-derives.
Disk is cheap, reasoning is scarce, so it emits generously: the whole surface **and** each lever's handling rule.

## Two-tier menu + the shared catalog

```
statesheets/
  domains.json              SHARED value-domain catalog (135) — every select/multiselect resolves here by name
  trigger/                  one file per trigger TYPE
    spell.json  …           full DETAIL: levers + handling (the shaping grammar)
    spell.routes.md …       ROUTING INDEX: main levers, one line each → open .json for detail
    spell.md    …           human-readable full table
  display/                  one file per REGION
    icon.json / icon.routes.md …
    _shared.json            the regionPrototype cross-cutting layer (offsets + condition actions), emitted ONCE
  load/         load.json   the load-condition options (AND chain)
  animations/   (TODO)
```

**Two-tier menu (guards context-overload/drift):** browse the light `.routes.md` (main input levers, ~8–12% of the
sheet's weight), open the `.json` only for the lever you pick. **Shared vocab stays shared:** `domains.json` (value
domains) and `display/_shared.json` (regionPrototype change-targets + actions) are cross-cutting — emitted once and
referenced by name, never duplicated per type/region.

## Trigger types — sourced worklist (all DONE)

`set(p.type for p in event_prototypes)` + two specials (function-driven, self-reported via `triggeroptions`):
unit · item · spell · event · combatlog · addons (event_prototypes) · **aura2** (BuffTrigger2) · **custom** (GenericTrigger).

## What a sheet row records — SELECT + HANDLING (the paired rule)

Each event fans to `options.{inputs, provides, internal}` plus a per-event `handling`:
- **input** — a control the user fills (`arg_type`, `input_kind`, `value_domain`, `default`).
- **provides** — `store=true`; a state field the trigger OUTPUTS (read by conditions/subregions). Captures are blind
  to these — they exist only in source.
- **internal** — test-only.

**HANDLING = the shaping grammar, sourced WITH the lever so the docket is born correct:**
- per lever: `multiEntry`/`value_shape:"array"` (value+operator stored as ARRAYS), `operator_types` (the operator
  set), `reads` (the `init` flatten expression = what native signal it *means*), `conditionType`.
- per event: `progressType` (none/static/timed — the region-compat axis; static-progress on an icon crashes it) and
  `statesParameter` (state scope: one/all/unit).

Correct-by-construction: the inventory reasons over select+handling, so shape rules (arrays, region-fit) are settled
at authoring, not discovered by round-tripping. (memory: `source-is-authority-for-rule-sets`, `three-reactive-surfaces`.)

## The contract (`../contract.json`) — the pre-flight resource

`compile_contract.py` JOINs sheets + domains into ONE resource the class-inventory pre-flight checks against:
`must_assert`, `condition_vars` (the conditionType axis), each region's `change_targets` (region-specific ∪ the shared
regionPrototype layer), `display_shared` (the condition actions), the load AND-chain, and every lever's handling. It
also flags dangling domain references. Docket + fill stay dumb; the reasoning and checking live in the inventory.

## Regenerate (deterministic)

```
py ../emit_state_sheet.py     # trigger sheets + routes (all types)
py ../emit_display_sheet.py   # region sheets + routes + _shared.json
py ../emit_domains.py         # the shared domain catalog
py ../compile_contract.py     # join → contract.json
```

Source: `extract.lua` (`prototypes` / `region` / `types` / `regionprototype` / `triggeroptions` modes) over the
unmodified WA source — the authority. Fast-follows: display-side field HANDLING (a region-options-builder extract
mode, for `alpha` + region field types/domains), `AddCommonTriggerOptions` (the trigger-side shared code-boxes), and
load/display domain linkage.
