# Reaper slot assignment ledger

Real, traceable per-slot record - same principle as `Necromancer/
slot_assignment.md`. Positions come from `Tiers/resources_base.py`
(itself mirroring the mask), never from a live in-game capture - see
`BUILD_METHOD.md`'s "Mask is still the sole source of truth" section.

## Resources tier - built 2026-07-09 (`Resources_v1_import.txt`)

| Slot (mask position) | Content | Opportunity type | Trigger | Status |
|---|---|---|---|---|
| CLASS_RESOURCE_POS (-64.5, -152.5) | Soul Fragment (805077) | `buff_uptime_aurabar` | aura2, spell 805077, + `show_when_missing` second trigger (`disjunctive: any`) | Built, round-trip verified. Prototype fields (barColor, base trigger shape) previously live-tested by Battlewrath directly; the `show_when_missing`/`show_stacks` formalization itself not yet re-tested live in this exact built form. |
| CLASS_ENERGY_POS (-64.5, -167.5) | Runic Power | `resource_threshold_aurabar` (`Tiers/resources_base.py`'s `resource_slot`) | Power, powertype 6 | Built, round-trip verified. Shares Necromancer's own live-tested mechanism; Reaper-specific recolor not independently re-confirmed (see `inventory.py`'s own flag). |
| CAST_BAR_POS (64.5, -152.5) | Cast Bar Backing + Cast Bar | `backing_plate_aurabar` + `player_cast_aurabar` | Unit Characteristics (always-true) + Cast | Built, round-trip verified. Shared, already-live-tested mechanism (Necromancer). |
| SWING_TIMER_POS (64.5, -167.5) | Swing Timer Backing + Swing Timer | `backing_plate_aurabar` + `swing_timer_aurabar` | Unit Characteristics (always-true) + Swing Timer | Built, round-trip verified. Shared, already-live-tested mechanism (Necromancer). |
| DIVIDER_POS (0, -160) | Resources Divider | `backing_plate_aurabar` (valueless, `divider_strip_slot`) | Unit Characteristics (always-true) | Built, round-trip verified. Color set to Reaper's own theme accent (`#0a876b`), NOT Necromancer's - resolves `resources_base.py`'s own open flag about cross-class-constant vs. per-class-themed color. |

**No Mana slot** - Reaper has no Mana resource at all (Battlewrath: "this
class only uses souls and runic power") - Soul Fragment occupies that
vacated address instead, per `spell_index.md`'s own note.

**Verification method**: `layer_builder.py Reaper Reaper/inventory.py
Resources` -> `Resources_v1_import.txt`, decoded via
`weakaura_codec.decode_group_import_string` and spot-checked: 7 children,
correct order (Soul Fragment, Runic Power, Cast Bar Backing, Cast Bar,
Swing Timer Backing, Swing Timer, Resources Divider), correct positions/
sizes, Soul Fragment's two-trigger `disjunctive: any` shape present, both
`%p` (INNER_LEFT) and `%s` (INNER_RIGHT) subtext present, divider
`backgroundColor` matches Reaper's accent RGBA exactly.

## FUSE-lag incidents hit while building this layer (2026-07-09)

Two files went stale mid-session, same recurring bug documented across
this project (`fuse_check.py`'s own docstring has the general recovery
pattern):
- `Templates/build_templates.py` - truncated at 2502 of 2596 real lines
  (mid-string in a docstring, `SyntaxError: unterminated string literal`).
- `template_filler.py` - truncated at 720 of 768 real lines, cutting off
  mid-comment BEFORE the function's own `return result` line - the file
  still parsed cleanly (a truncated comment isn't a syntax error), so
  `fill_template()` silently returned `None` for every call until this was
  caught and fixed. Worth remembering: a clean `ast.parse()` pass does NOT
  guarantee a file isn't truncated - only that the truncation point
  happened to land on a comment/statement boundary.
- `Tiers/resources_base.py` - a NEW variant: 263 stray null bytes inside
  an otherwise-plain-text file, surfaced as `ValueError: source code
  string cannot contain null bytes` on import (not a `SyntaxError` at
  all). Same `--resync` recovery fixed it.

All three resolved via the established `Write` a `.fresh` sibling ->
`python3 fuse_check.py --resync` -> re-verify workflow.

## Not yet built

- **Reaped Soul tracker** - deliberately not built at all, see
  `spell_index.md`'s closing note (native in-game UI already covers it).
- **Any Rotation/Buffs/Utility tier content** - Reaper's ability kit
  hasn't been scoped for those tiers yet; Resources is the only layer
  built so far, mirroring how Necromancer's own build started.
