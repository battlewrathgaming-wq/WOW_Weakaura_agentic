# Composition grammar (STUB)

**Status: working hypothesis**, grounded in the current corpus (73 displays,
~60 real conditions, 2026-07-11). Battlewrath will pull more WA examples to test
whether each rule holds or where it must expand. Every empirical claim is tagged
`[evidence]` (what the current corpus shows) and `[expand?]` (what more examples
might add). Structural rules (lanes/addressing) are high-confidence from the data
shape; the join/combination/value rules are the ones to stress-test.

The grammar is the **handling** layer above the [index](../wa_index/) vocabulary:
how the indexed parts *attach* into a valid aura. Grammar GENERATES, index
VALIDATES, WA FINISHES. Single-aura scope for now (no groups). See
[SLICE_CLAIM_MODEL](SLICE_CLAIM_MODEL.md), [RECONCILIATION](RECONCILIATION.md).

## Lanes + addressing (structural)
- `region` — the body, exactly one.
- `triggers[1..N]` — integer-indexed dict, `+ activeTriggerMode + disjunctive`.
- `subRegions[1..M]` — positional array; referenced as `sub.M` (1-based).
- `conditions[]` — list of `{check, changes}`.

## The join — the one generative operation
Attach an effect driven by a state. The condition is `{check, changes}` where the
CHECK is **recursive** (a leaf, or an AND/OR tree of checks) and CHANGES is a
**list** (may drive several properties at once):
```
1. ensure each state's trigger exists  -> triggers[N]  (next free index)
2. ensure each effect's target exists  -> a region property, or subRegions[M]
3. append condition { check, changes }:
   check   := leaf | { variable:"AND"|"OR", checks:[ check, ... ] }         # recursive
   leaf    := { trigger:N, variable:<state-lever>, [op:<operator>], value:<int|str|null> }
   changes := [ { property:<region-prop | "sub.M.prop" | customcode | glowexternal>,
                  value:<typed> }, ... ]                                    # multi-entry
```
`[evidence — Battlewrath corpus, v86]` base case: `show`-only leaf checks, single
change (`desaturate`, `sub.N.glow`, ...).
`[evidence — 9 ascension-DB packs, v52-86, 410 conditions]` matured the grammar:
- CHECK is **recursive** — 119/410 use `AND`/`OR` trees of sub-checks.
- CHECK `variable` = **any `state` lever**: show(153), onCooldown(82), stacks(44),
  spellUsable(17), duration(17), expirationTime(10), charges(10), buffed, spellId,
  percentpower, unitCount, ...
- `op` = full comparison set: `<`, `<=`, `>`, `>=`, `==` (from `operator_types`).
- value types: int, **string**, null (string checks confirmed).
- CHANGES is **multi-entry** — 138/410 drive >1 change.
- change `property` = any `role:change` lever + `sub.M.<prop>` (glow, glowType,
  text_visible, border_color/visible) + imperative `glowexternal` + **`customcode`**
  (a condition running Lua — script-insertion via conditions).
`[caveat]` version mix; the v86 packs alone show most of this cleanly. Some empty-
property / null artifacts are older-version shape drift — Modernize would tidy them.
`[still watch]` the exact `customcode` contract; group ARRANGEMENT levers.

## Combination
Trigger combination (`triggers.disjunctive`), full set now seen:
- `"any"` (OR) — complementary states co-persist (footprint survives, cf. T5).
- `"all"` (AND) — every trigger must be active.
- `"custom"` — custom-Lua decides activation (a script-insertion point).
- unset — default (single trigger, or all-required).
- `activeTriggerMode:-10` (first_active) as the usual active-trigger picker.

`[evidence — 21 packs]` disjunctive: `any`(420+), `all`(28), `custom`(60), unset.
Check trees nest to **depth 4** (AND/OR of AND/OR).

## Group arrangement (dynamicgroup)
A `dynamicgroup` positions its children via a fixed lever set (all present on every
group seen): `grow` (DOWN / RIGHT / HORIZONTAL / GRID / CUSTOM), `align`, `sort`,
`space`, `stagger`, `rowSpace`, `columnSpace`, `gridType`, `arcLength`,
`constantFactor`. `controlledChildren` is the ordered membership; arrangement is
these levers. (`group` = static/manual placement; `dynamicgroup` = auto-arranged.)

## Animation — rarely used (deprioritize)
`[evidence — 12 retail packs]` only **3 of 2784** animation phase-slots are non-none.
Even expert packs almost never use WA's built-in start/main/finish animations; "feel"
comes from conditions / glows / textures. The animation levers are indexed and
available, but composing them is low-priority.

## Value semantics (from harvested recipes — the real subtlety)
- **declarative** props (`desaturate`, `sub.M.glow`, `sub.M.textureVisible`)
  auto-revert -> **one** condition (set on when check true).
- **imperative** actions (`glowexternal`) don't auto-revert -> **paired**
  show/hide conditions.
- props whose **baseline is "on"** -> **both** states stated explicitly.

`[expand?]` confirm per-property which class it is; the index's `input_kind`
likely predicts it (`action` = imperative/paired; `toggle`/`change` = declarative/
single) — test that this holds as more effects appear.

## The loop: grammar generates, index validates
- `check.variable` must be a **`state`** lever (`input_kind:state`) of trigger N.
- `change.property` must be a **`change`** lever (`role:change`) of the region, or
  of subRegion M.
- `value` must match that lever's `input_kind`.
- WA (Modernize headless + in-game import) is the final validator.

## Expansion test-list (what to look for in more examples)
1. ~~Checks beyond `show`~~ — **CONFIRMED:** any `state` lever + `op`.
2. ~~Multi-check AND/OR conditions~~ — **CONFIRMED (9-pack):** recursive check tree.
3. ~~Combination modes beyond `any`~~ — **CONFIRMED (retail):** any / all / custom.
4. ~~Change forms / multi-entry~~ — **CONFIRMED:** any `role:change` lever incl.
   `customcode`/`glowexternal`; multi-entry `changes`.
5. ~~Group / dynamicgroup composition + arrangement~~ — **CONFIRMED:** membership via
   `controlledChildren`; arrangement via grow/align/sort/space/stagger/grid levers.
6. **SCRIPT-INSERTION = the expert frontier (next workstream).** "custom" appears at
   every join point: `customcheck` (condition), `custom` (trigger-combination),
   `customcode` (change), custom triggers. Map the CONTRACT (what Lua each slot
   receives / must return, and the aura_env sandbox) — from GenericTrigger.lua +
   AuraEnvironment.lua. This is where expert packs get their edge.

## Ingest note (learned from wa881)
Scraping a pack's **displayed decoded JSON** is fragile: a child with custom
functions renders Lua whose characters make the JSON non-reparseable (broke at the
custom child). The robust ingest is the **import string -> weakaura_codec** (lossless,
version-agnostic decode), then **Modernize v?->v86** to our authority version,
then analyze. Published packs are `internalVersion` < 86 (wa881 = 53), so version
normalization is mandatory for field-level fidelity, though structural findings
(the join expansions above) hold across versions.

## Evidence log
- Battlewrath corpus (73 displays, v86): established the base grammar (show-only checks).
- wa881 "Auff's Felsworn Infernal Pack" (db.ascension.gg, v53, 28 elements):
  expanded check side (state-var + op), change side (barColor), confirmed groups.
- 9 ascension-DB packs (v52-86, ~370 nodes, 410 conditions), 2026-07-11: matured the
  grammar - recursive AND/OR check trees (119), any-state-lever checks, full operator
  set, string checks, multi-entry changes (138), `customcode` change (48). Core join
  held; the CHECK became recursive and the value/change sides broadened.
- 12 retail packs (WA 3.1.9-5.20.2, iv 40-85 - all BELOW our 86, Modernize-up),
  ~1600 nodes, 2026-07-11: closed COMBINATION (any/all/custom) + GROUP ARRANGEMENT
  levers + check-depth-4; found animation is near-unused (3/2784). transfer_check.py
  graded them vs wa_index: 6/12 fully reproducible on our WA, rest transferable minus
  retail-only blocks (Spell Activation Overlay, M+ keystone score/deplete, retail
  unit-states, Item Set). Confirmed the INDEX is a working transferability filter -
  learn expert grammar, skip foreign content. All 21 packs in ingest/reference/.
