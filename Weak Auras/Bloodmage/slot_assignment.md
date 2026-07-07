# Bloodmage slot assignment ledger

Real, traceable per-slot record - same principle and table shape as
`Necromancer/slot_assignment.md` / `Reaper/slot_assignment.md`. Positions
come from `Tiers/resources_base.py` (itself mirroring the mask,
`ELEMENT_INVENTORY.md`), never from a live in-game capture - see
`BUILD_METHOD.md`'s "Mask is still the sole source of truth for position".

## Resources tier - built 2026-07-07 (`Resources_v2_import.txt`)

| Slot (mask position) | Content | Opportunity type | Trigger | Status |
|---|---|---|---|---|
| CLASS_RESOURCE_POS (-64.5, -152.5) | HP Reserve (top 50%-100% of max HP) | `health_range_aurabar` (`rb.health_slot`) | unit / `Health` / player, `adjustedMin: "50%"` `adjustedMax: "100%"` `useAdjustededMin/Max: true` | Built, round-trip verified. Mechanism formalized at the core layer BEFORE this pass (native Health trigger + adjustedMin/Max % clamp), confirmed by direct source read AND a real Battlewrath live export (`Bloodmage_hp_resouece_50-100%`). This exact built form (via `health_slot`) not yet re-tested in-game. |
| CLASS_ENERGY_POS (-64.5, -167.5) | Rage | `resource_threshold_aurabar` (`rb.resource_slot`) | unit / `Power` / player, `powertype: 1` (Rage), `use_powertype: true` | Built, round-trip verified. Standard WoW PowerType mechanism, already live-tested for Necromancer/Reaper power bars. **Bar color flagged**: no Bloodmage Rage capture exists; set to Blizzard's canonical `PowerBarColor["RAGE"]` `[0.77, 0.25, 0.25, 1]` as a documented (not fabricated) default - replace if captured. See `inventory.py`/`spell_index.md`. |
| CAST_BAR_POS (64.5, -152.5) | Cast Bar Backing + Cast Bar | `backing_plate_aurabar` + `player_cast_aurabar` | Unit Characteristics (always-true) + unit / `Cast` / player | Built, round-trip verified. Shared, already-live-tested mechanism (Necromancer/Reaper). No overrides needed - template defaults match the real captured Cast Bar. |
| SWING_TIMER_POS (64.5, -167.5) | Swing Timer Backing + Swing Timer | `backing_plate_aurabar` + `swing_timer_aurabar` | Unit Characteristics (always-true) + `Swing Timer` (main hand) | Built, round-trip verified. Shared, already-live-tested mechanism (Necromancer/Reaper). |
| DIVIDER_POS (0, -160) | Resources Divider | `backing_plate_aurabar` (valueless, `rb.divider_strip_slot`) | Unit Characteristics (always-true) | Built, round-trip verified. `backgroundColor` set to Bloodmage's own theme accent `#c66161` (`[0.7765, 0.3804, 0.3804, 1]`), same per-class-accent convention Reaper established. |

**No Mana slot** - Bloodmage has no Mana resource at all (confirmed: only
"Mana" substrings in the skill index are the word "emanate"). The
primary-resource slot holds Health-as-resource instead, per
`Bloodmage_fantasy_playstyle.md` and `spell_index.md`. Health-as-resource
is the class's core meter (spells cost health, then it is clawed back via
leech/shields/self-heal), so it correctly occupies the mask's "primary
resource bar" role rather than being a survival bar bolted on elsewhere.

**Verification method**: `layer_builder.py Bloodmage Bloodmage/inventory.py
Resources` -> `Resources_v2_import.txt`, decoded via
`weakaura_codec.decode_group_import_string` and spot-checked: parent
`controlledChildren` length 7 and order matches the 7 decoded children
(HP Reserve, Rage, Cast Bar Backing, Cast Bar, Swing Timer Backing, Swing
Timer, Resources Divider); every position/size matches the
`resources_base.py` constants; all 7 UIDs unique; HP Reserve's
`adjustedMin/Max: "50%"/"100%"` + `useAdjustededMin/Max: true` present
(the top-half-HP clamp); HP Reserve trigger is unit/`Health`/player; Rage
trigger is unit/`Power`/player with `powertype: 1`; divider
`backgroundColor` matches the accent RGBA exactly.

## FUSE mount-lag incident hit while building this layer (2026-07-07)

`Bloodmage/inventory.py` went stale mid-build, the same recurring bug
documented across this project (`CLAUDE.md`/`fuse_check.py`): after the
Edit tool filled in `LAYERS`, bash still served the original empty-slot
scaffold bytes, so the first build (`Resources_v1_import.txt`, 696 chars)
produced a group with **0 children**. Caught immediately by round-trip
decode (`controlledChildren: 0` vs. Reaper's reference 7), diagnosed via
`fuse_check.py` showing the stale on-disk size, and fixed with the
documented `Write` fresh-copy -> `python3 fuse_check.py --resync
<fresh> Bloodmage/inventory.py` workflow (hash-verified match), plus
clearing the stale `__pycache__/inventory*.pyc`. Rebuild then produced the
correct `Resources_v2_import.txt` (2428 chars, 7 children). The three
`.md` files written this pass hit the same lag (truncated at their
original placeholder byte counts) and were resynced the same way.
`Resources_v1_import.txt` is retained only as the empty pre-resync
artifact - **`Resources_v2_import.txt` is the authoritative build.**

## Escalations raised this pass

None. Every Resources-tier slot used an already-proven
`Tiers/resources_base.py` builder (`health_slot`, `resource_slot`,
`cast_bar_backing_slot`, `cast_bar_slot`, `swing_timer_backing_slot`,
`swing_timer_slot`, `divider_strip_slot`) and an existing REGISTRY
opportunity type (`health_range_aurabar`, `resource_threshold_aurabar`,
`backing_plate_aurabar`, `player_cast_aurabar`, `swing_timer_aurabar`) -
no new opportunity_type, no new fragment, no bespoke Lua, per
`../AGENT_ROLES.md`'s class-implementer scope. The health-as-resource
mechanic that would once have been an escalation was pre-formalized as
`health_slot()` specifically so this pass could consume it directly.

## Not yet built

- **Spec-defining stacking sub-resources / forms** - deferred to future
  tiers (talent/spec-gated, not universal): Accursed's **Blood Shard**
  (stacks to 8) + Accursed Form uptime, Eternal's summon presence +
  Eternal Curse form, Fleshweaver's **Pooled Vitality** (stacks to 10,
  empowers at 10), Sanguine's **Thirst** stacks. See
  `Bloodmage_fantasy_playstyle.md`'s per-spec "UI priority" notes. Three
  of four are a `buff_uptime_aurabar` + `show_stacks` shape (proven on
  Reaper's Soul Fragment); Eternal's is a `minion_presence_icon` shape
  (proven on Necromancer, with its documented count-accuracy limitation).
  Confirm against source and check the REGISTRY/fragments before building -
  raise a gap report per `../AGENT_ROLES.md` if any needs a below-35%-HP
  trigger or an "empowered at N stacks" threshold that isn't already a
  proven capability.
- **Any Rotation/Buffs/Utility tier content** - Bloodmage's ability kit
  hasn't been scoped for those tiers yet; Resources is the only layer built
  so far, mirroring how Necromancer's and Reaper's builds started.
