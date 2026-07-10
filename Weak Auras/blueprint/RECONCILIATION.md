# Reconciliation — the Templates plane vs. the blueprint plane

Decision (Battlewrath, 2026-07-10): **rebuild the generic plane from scratch,
harvest the shapes the existing content already proves, archive the rest
reachably.** This doc reconciles the two planes so the rebuild harvests instead
of loses. Nothing is moved or archived until the go word.

## The finding

The `Templates/` + `template_filler.py` system **is** the blueprint architecture,
already implemented — but as **bespoke Python instead of data**. Every blueprint
component has a working counterpart:

| Blueprint component | Templates-plane counterpart | Form today |
|---|---|---|
| Blocks (WA parts) | JSON in `Templates/templates/*.template.json` (region + trigger + subRegion shapes) | **data ✓** — harvest near-directly |
| Slices (operators) | templates (bundled base) + fragments (`glow_source`, `power_threshold`, `press_wash`, `stack_counter`, `class_accent_tick_end`, `load_conditions`) | half data / half code |
| Docket / IR (intake) | `Templates/schemas/*.schema.json` — `required` = fills, `properties` = params | **data ✓** — harvest |
| Assembler (distribute+pair) | `template_filler.py`'s per-`opportunity_type` branches | **bespoke code — being replaced** |
| Mask (geometry) | `x`/`y` passed in from `<Class>/inventory.py` + slot docs | separate, already built |
| Modernize (canonicalize) | *not used* — filler emits final dicts directly | **new capability the rebuild adds** |
| Validator | schema required-check + `wa_validate` + the game | exists ✓ |

## Why archive reachably — the insurance ("if this doesn't work")

The old Templates plane **works** — it is the safety net, not a graveyard. The
from-scratch generic rebuild is a *bet*, and Battlewrath's "(it doesn't work)"
was conditional: **if the new approach doesn't land the MVP, we've lost nothing**
— everything is archived, so we fall back to **rebuilding from the data samples**
(the proven templates / schemas / real captured outputs) rather than
re-inventing. Take the bet precisely because the fallback is preserved.

The rebuild's aim is to turn each per-`opportunity_type` join into a **data
slice/join definition** consumed by one generic distribute+pair engine — instead
of the current hand-written `elif` branches in `template_filler.py`. (That the
branches don't compose well is an engineering read of the current code, not
Battlewrath's stated reason for the decision — the stated driver is the safe-bet
+ reachable-archive logic above.)

## What harvests

1. **Block shapes** — the template JSON → Layer-0 blocks almost directly.
2. **Schemas** — → the docket/IR contract (fills; required vs. optional).
3. **The join recipes** — buried in `template_filler.py`'s Python **and** the
   schemas' `"verified"` fields. THE TREASURE, each bought with a live in-game
   test: `sub.N.glow` vs `glowexternal`; single-condition auto-revert vs paired
   show/hide; `disjunctive:any` for momentary triggers; name-vs-ID matching
   across ranks; `unit:target` for debuff-presence. These become **data slice
   definitions**, not lost.

Full harvest inventory (standalone templates): cooldown_tracker_icon,
resource_spender_icon, proc_alert_icon, buff_uptime_icon, buff_uptime_aurabar,
resource_threshold_aurabar, health_range_aurabar, missing_buff_icon,
enemy_cast_aurabar, player_cast_aurabar, swing_timer_aurabar, swing_timer_icon,
backing_plate_aurabar, backing_plate_icon, pet_summon_countdown_icon,
stack_gain_flash_text, stack_delta_flash_text, stance_loader_icon,
minion_presence_icon. Fragments (join operators): glow_source,
stack_counter_overlay, class_accent_tick_end, power_threshold_effect,
press_wash_effect, load_conditions. Plus `_base_envelope`.

## What archives

`template_filler.py`, `build_templates.py`, `Templates/` → a reachable
`_archive/` once harvested — Battlewrath's "retire as a reachable archive if we
need to refactor again." The archive is **insurance + a rebuild-from-samples
source**: if the generic rebuild fails, these proven, live-tested artifacts are
the data samples we re-derive from, not throwaway. Do not archive until the new
plane has actually proven the MVP — until then the old plane is the working system.

## New over old

Modernize as canonicalizer lets the new assembler be **dumber and generic** —
emit a reasonable table, let WA finish it — which is exactly what frees it from
the bespoke per-field precision the filler hand-maintains.

## Reframed MVP

Prove the **new generic plane** on cooldown+desaturate: harvest the
cooldown_tracker block + author its slice/join as **data** → generic
distribute+pair → Modernize → encode → import. The old filler's output for the
same aura is the **reference to eyeball**, not a byte-oracle (we replace, not
reproduce). See [REQUIREMENTS_AND_MVP](REQUIREMENTS_AND_MVP.md), [README](README.md).
