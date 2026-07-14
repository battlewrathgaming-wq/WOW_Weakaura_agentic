# load — when the aura exists at all

_The cheapest lever: an unloaded aura costs nothing and shows nowhere. Fact source: `sheets/load/load.json` (41 fields)
+ `maps/arg_shapes.json` (stored forms) + `maps/class_table.json` (verified tokens). Live-proven trap: a multiselect
load field participates ONLY when its `use_<name>` is present (`WeakAuras.lua:814`) — omit the gate and the filter
silently never runs (the shipped dead-config bug). populate shapes these from meaning-level automatically._

## Stored forms (from arg_shapes — never hand-compose)

- **tristate** — `use_<name>: true` (require), `false` (require NOT), omit (don't care)
- **multiselect** — `use_<name>: false` + `<name>: {multi: {KEY: true}}` (the UI-native form) · `true` + `{single: KEY}`
- **string / number** — `use_<name>: true` + `<name>` (+ `<name>_operator` for numbers)

## Identity — who the player is

| ingredient | type | good for |
|---|---|---|
| `class` | multiselect | **the pack loader** — tokens from `maps/class_table.json` (all 21 COA + base verified live) |
| `specialization` | multiselect | per-spec packs — **index-keyed; the index→name order is UNRESOLVED — do not wire yet** |
| `race` / `faction` / `level` | multiselect/number | rarely ours; level-gated content |

## Capability — what the player knows/has

| ingredient | type | good for |
|---|---|---|
| `spellknown` / `not_spellknown` | spell | **load a tracker only if the ability is known** — the natural per-member gate for packs (no dead icons for unlearned skills) |
| `knowntalent` | talent | talent-gated trackers (a proc display only when its talent is taken) |
| `mysticenchantactive` / `not_` | mysticenchant | Ascension enchant-driven behaviour |
| `itemequiped` / `not_` / `itemtypeequipped` | item/multiselect | weapon-dependent displays |

## Situation — where/when

| ingredient | type | good for |
|---|---|---|
| `combat` | tristate | combat-only HUDs — the ambient-vs-combat taste lever |
| `alive` / `mounted` / `vehicle` / `vehicleUi` | tristate | hiding while dead/mounted |
| `encounter` / `encounterid` | tristate/string | raid-encounter-specific auras |
| `pvpmode` | tristate | PvP-only pressure displays |
| `manastorm` | tristate | Ascension-custom event state |
| `zone` / `zoneId` / `subzone` | string | location-gated |

## Group context

| ingredient | type | good for |
|---|---|---|
| `ingroup` / `groupSize` / `size` / `difficulty` | multiselect/number | raid-size/difficulty scoping |
| `role` / `spec_position` / `raid_role` / `group_leader` | multiselect | role-scoped (tank-only warnings) |
| `ruleset` | multiselect | Ascension ruleset scoping |

## Person / kill-switch

| ingredient | type | good for |
|---|---|---|
| `player` / `realm` / `namerealm` / `guild` / `guildcheck` / `ignoreNameRealm` | string | author-personal auras — not pack material |
| `never` | toggle | the off-switch — disable without deleting |

## Pack idiom (proven + pending)

`use_class: false` + `class: {multi: {TOKEN: true}}` — live-proven. Add `spellknown` per member when packs want
no-dead-icons. `specialization` joins the moment its index order is captured in-game.
