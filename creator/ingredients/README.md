# ingredients — the palette (by trigger type · by region)

_The creator-side pantry. When an ask arrives ("make this aura"), the agent INVENTS the logic freely — composed from
these ingredients — and the MACHINE constrains it (gate: words/liveness/domains · canon: WA's own acceptor · live: the
game). Nobody hand-validates the logic upstream; failures bounce back mechanically, with citations._

## What these files are

One file per **trigger type** (`trigger.<type>.md`) and per **region** (`region.<type>.md`): every ingredient, **what it
does** (fact — cited to the engine sheets/maps) and **what it's good for** (designer notation — the taste half, which is
why this lives in `creator/`, not the engine). Curated OVER the sheets, never instead of them:

- the complete surface = `engine/Fact_basis/sheets/` (trigger/display/load) — these files spotlight, the sheet settles
- **only LIVE keys appear here** — `maps/live_keys.json` filters; a dead/residue key is never on the menu
- stored forms = `maps/arg_shapes.json` · class tokens = `maps/class_table.json`

## The laws (start inside them)

- **Drive from the primary user-meaning ID**; auto icon; prefer conditions over extra triggers; never hardcode a route.
- **Match family, not rank** — the ID goes in `auranames` (name-catch, all ranks); exact-ID pins one rank (policy off).
- **WA-literal only** — every token look-upable in the sheets. If it isn't there, it doesn't exist.
- **Region-appropriate content** — ICON wants timed/boolean (cooldown/aura); BAR wants progress. Live client outranks theory.
- **Per-aura conditions read local state** (this ability's cooldown), not compound global state.
- **Cross-aura effects: pull, not push** — each aura reads the native buff-window itself.

## Further reading (secondary — concepts, never facts)

Upstream WeakAuras2: the [wiki](https://github.com/WeakAuras/WeakAuras2/wiki) (custom-trigger guides, %text docs,
condition semantics — the "why" behind the surfaces) and the [source](https://github.com/weakauras/weakauras2).
Cold-start page: [Aura Types](https://github.com/WeakAuras/WeakAuras2/wiki/Aura-Types) — the display-model overview
(the upstream mirror of the `region.*` files here).
**Caveat: our client runs Ascension's 3.3.5 backport (5.21.2 / iv86)** — upstream documents retail-era WA. Use it for
orientation and meaning; the INSTALLED FORK stays the authority for every fact (that's what the maps harvest from).
Invariant 7 applies: nothing is accepted from upstream without a fork-source confirm.

## The maturation direction (Battlewrath, 2026-07-14)

Future wiki passes + live runs flatten into **CHECKLISTS** — the operational form: per-task pre-flight cards
(authoring a proc display · a stack alarm · a target tracker…) combining the authors' pedagogy × the fork facts ×
**our own what-works-for-us** (exact-id on shared names · show-on-missing wants a displayIcon fallback · the
attention budget · one glow per screen · …). The palette teaches; the checklist executes. Grown per task as the
custom backlog reveals which tasks recur.

## The walk

ask → pick the trigger type (what native signal tracks it) → compose CATCH / SHOW / READ from its ingredients → pick the
region (how it looks) + its reactive surface (what conditions may change) → docket (micro-contract) → populate → gate →
machine → live. The **asset library** (proven compositions: the Target tracker, the tome) is advisory reference, never a gate.

## The form and the chain (read these first)

- `docket.blank.md` — **what a single slot item looks like**: the blank form, slot by slot, who reads each, + a
  live-proven minimal example. The table structure to engrain.
- `custody.md` — **how it works, forever**: the chain of custody from author to live, what each station may and may
  not do, the proofs behind each claim, and where a fix goes when something's wrong.

## Coverage — the aura's main levers (the UI's own top level)

- **trigger** — `triggers.md` (the overview: the four info channels + the behavioral taxonomy) · `trigger.aura2.md` (the buff/debuff window reader; 66% of real-world authorship)
- **display** — `display.md` (the shared layer + subRegions + the choosing rule) · per region:
  `region.icon.md` · `region.aurabar.md` · `region.dynamicgroup.md` (boolean/timed · progress · container)
- **load** — `load.md` (when the aura exists at all; 41 fields; the pack idiom + the spellknown gate)
- **conditions** — `conditions.md` (the reaction layer: check → changes, the three reactive surfaces, the four actions)
- **custom** — `custom.md` (the scripting surface: the custom trigger/TSU, aura_env + the sandbox, the scaffold lane;
  packs stay structured, scripting earns its place where structure can't reach)
- Cooldown/spell trigger, text/glow subregion detail, the WA-env surface for scripting… — **unharvested walls**: when
  an ask needs one, harvest its liveness first (`harvest_live_keys.py` grows per type), then it earns its file here.
