# Capability complexity classification

No complexity taxonomy existed in this project before 2026-07-10 (checked:
`Docs/WEAKAURA_INDEX.md`, `HUD_DESIGN.md`, `ROTATION_ICON_PATTERN.md`, every
other design doc - the only existing "tier" language is HUD_DESIGN.md's
five-tier *screen layout* model, Rotation/Power-button/Resources/Buffs/
Proc-Condition, which is about slot placement, not build complexity).

This doc defines one, scored retroactively against every template in
`Templates/build_templates.py`'s `REGISTRY`, per Battlewrath's request
(2026-07-10) after formalizing `resource_spender_icon` from Reaper's
"Tormented Souls" build: "capture it as a capability, give it a class of
complexity, as this WA does enough to compare our existing ones against as
a standard." `resource_spender_icon` is the new ceiling case the other
16 are measured against.

## The four axes

Every template is scored on four objective properties, read straight off
its own `REGISTRY` entry (trigger count/shape, `conditions` count,
distinct real-world visual states, and companion-aura dependency) - not a
subjective feel-based rating:

1. **Trigger count** - how many WeakAuras triggers the aura's OWN
   definition carries (a fragment like `glow_source`/`power_threshold`
   that adds a numbered trigger counts here; a companion aura's own
   triggers do NOT, since that's a separate WeakAuras object).
2. **Condition branches** - how many `conditions` list entries drive a
   property change off some trigger's state.
3. **Visual states** - how many genuinely distinct on-screen appearances
   the element can show across its full lifecycle (not just show/hide -
   e.g. desaturated vs. saturated vs. glowing all count separately).
4. **Self-containment** - does the FULL lifecycle live in one aura, or
   does completing the visual story require a paired companion aura
   (e.g. `backing_plate_aurabar` sitting behind `player_cast_aurabar`)?
   A template that only works as half of a pair is capped below Class IV
   regardless of its own trigger count, since the capability isn't
   self-contained.

## The four classes

| Class | Triggers | Conditions | Visual states | Self-contained | Example |
|---|---|---|---|---|---|
| **I - Primitive** | 1 | 0 | 1-2 (show/hide) | yes (or paired-by-design, e.g. a backing plate) | `proc_alert_icon`, `buff_uptime_icon` |
| **II - Modulated** | 1-2 | 1 | 2-3 | yes | `resource_threshold_aurabar`, `cooldown_tracker_icon` (bare) |
| **III - Composite** | 2+ (or N mutually-exclusive) | 1-2 | 3-4 | yes | `stance_loader_icon`, `cooldown_tracker_icon` + `power_threshold` + afford-glow |
| **IV - Self-contained lifecycle** | 3+ | 3+ | 5+ | yes, with BOTH an availability gate and a self-tracked resulting effect in the same aura | `resource_spender_icon` |

The line between III and IV isn't just trigger count - `stance_loader_icon`
can have many triggers (one per mutually-exclusive option) and still stay
Class III, because every trigger is doing the SAME job (which option is
active). Class IV specifically requires two DIFFERENT jobs stacked in one
aura: a gate on whether the action is available, AND independent tracking
of what happens after it's used. That's the "spender + buff timer" shape
Battlewrath asked to capture, and no existing template combined both
before `resource_spender_icon`.

## Scored inventory (all 18 `REGISTRY` templates)

| Template | Class (bare) | Class (common combo) | Why |
|---|---|---|---|
| `cooldown_tracker_icon` | II | III | Bare: 1 trigger (Cooldown Progress), optional `desaturate_on_cooldown` reads its own state - no second trigger needed, stays II. Reaches III when a real second trigger is attached (`power_threshold`'s afford-glow, or `glow_source`) - 2 triggers, 2 conditions, 3-4 states (desaturated/ready/glowing/on-cooldown). Never reaches IV: the second trigger tracks either a linear power cost or an EXTERNAL proc/buff, never a resulting effect this same ability grants itself. |
| `resource_spender_icon` | **IV** | IV (+ stacked) | 3 triggers (ready, cooldown, own resulting buff), 3 conditions, 5 real states (Battlewrath's own confirmed list: no-resource/no-buff, resource/unused, used+glow, expired+no-resource, expired+has-resource) as a bare instance. The reference standard - both an availability gate (Action Usable pair) and a self-tracked result (the granted buff), fully self-contained, no fragment bolt-on required to reach this. UPGRADED 2026-07-10 (second pass, same day): the real Tormented Souls v4 build adds a SECOND `glow_source` entry (`external_empower`, Soul Infusion) stacked on the same icon - 4 triggers, 5 conditions, 6 real states (adds "empowered" as an independent overlay state that can co-occur with any of the original 5). This is `glow_source`'s multi-entry case confirmed real, not theoretical (see `glow_source.schema.json`'s "verified" field) - a Class IV capability can stack a SECOND, independent signal (an unrelated buff empowering it) on top of its own spender+buff-timer lifecycle, without needing a second aura or a higher class. |
| `proc_alert_icon` | I | I | 1 trigger (Combat Log), 0 conditions, plain show/hide. |
| `buff_uptime_icon` | I | I | 1 trigger (aura2 toggle), 0 conditions. |
| `buff_uptime_aurabar` | I | II | Bare: 1 trigger + baked-in timer text, 0 conditions. With `show_when_missing` + `show_stacks`: 2 triggers, `disjunctive:any`, still 0 explicit Conditions (visibility-only) - II, not III, since nothing drives a property CHANGE, just presence. |
| `resource_threshold_aurabar` | II | II | 1 trigger (Power, continuous status) + a value readout + optional tick marker(s) - no Condition branching at all, just a static display of trigger state. |
| `health_range_aurabar` | II | II | 1 trigger (Health, continuous status, `progressType='static'` same as Power) + a percenthealth readout + the region's own `adjustedMin`/`adjustedMax` percent clamp - no Condition branching, same shape and class as its Power-trigger sibling `resource_threshold_aurabar`. Formalized 2026-07-09 from a real live-built and live-confirmed Bloodmage capture. |
| `missing_buff_icon` | I | I | 1 trigger (aura2, `showOnMissing`), 0 conditions. |
| `enemy_cast_aurabar` | I | I | 1 trigger (Cast), structural stub, never live-tested. |
| `player_cast_aurabar` | I | II (as a pair) | 1 trigger alone. Only reaches a 2nd visual state (idle footprint) by pairing with `backing_plate_aurabar` as a SEPARATE aura - capped below III since the capability isn't self-contained in one aura (the idle-shadow-in-one-aura mechanism was tried and explicitly withdrawn as backwards, per this schema's own "verified" field). |
| `swing_timer_aurabar` | I | II (as a pair) | Same shape and same withdrawn-mechanism history as `player_cast_aurabar`. |
| `backing_plate_aurabar` | I | I | 1 trigger (always-true Unit Characteristics), 0 conditions - deliberately the simplest template in the registry by design. |
| `backing_plate_icon` | I | II | Bare: 1 trigger, 0 conditions. With `missing_state_option_names`: 2 triggers, 1 condition (iconSource swap) - II. Still companion-only by design (exists to sit behind another icon), so it's capped there regardless. |
| `pet_summon_countdown_icon` | I | I | 1 trigger (Combat Log keyed to a SUMMON event, `use_duration`), 0 conditions. Not yet live-tested. |
| `stack_gain_flash_text` | I | I | 1 trigger (Combat Log DOSE event, native auto-revert), 0 conditions - momentary flash, no branching. |
| `stack_delta_flash_text` | II | II | Only 1 formal trigger (Custom/stateupdate), but that trigger embeds a real stateful Lua computation (delta tracking via `lastCount`, live UnitAura polling) - bumped to II on logic complexity despite the low trigger count, since the "condition" logic lives inside the trigger's own Lua rather than a declarative Condition entry. |
| `stance_loader_icon` | III | III | N (>=2) mutually-exclusive triggers, `disjunctive:any` + `activeTriggerMode:-10`, optional per-option border Conditions (1 per option). Every trigger does the same job (which option is active), so this stays III even at high N - see the class-boundary note above for why this doesn't cross into IV. |
| `minion_presence_icon` | II | II | 1 trigger (aura2 + `useStacks`) per child icon; the real complexity is at the DynamicGroup level (N children re-flowing), not within a single child aura. |

## Stacking within a class: multi-entry `glow_source`

`glow_source` was originally scoped (2026-07-04) to "1 effect for now." That
scope is now proven wrong: Battlewrath's real Tormented Souls v4 build
stacks TWO simultaneous `glow_source` entries on one `resource_spender_icon`
- `buff_uptime` (the ability's own granted buff, Soul Infusion's earlier
Tormented Souls buff) and `external_empower` (Soul Infusion itself, an
unrelated resource-threshold buff that empowers this ability, shown as a
quiet ambient texture rather than a border glow). `template_filler.py`'s
`glow_source` handling was fixed to loop over every entry in the list
(previously hardcoded to `entry[0]`) to support this.

The complexity-scoring implication: stacking additional `glow_source`
entries doesn't change a template's CLASS (it's still a Class IV capability
either way - the axis this affects is trigger count/visual states, not
self-containment or the gate+result structure that defines IV), but it does
mean the "common combo" column for any template that accepts `glow_source`
can legitimately grow past a single entry. Battlewrath's own framing for why
this matters beyond just Reaper: "it gives me some framing to consider some
of Necro's current slots... we can do more with them, and limit the overall
UI space we need... as opposed to layering signals" - i.e. prefer stacking a
second signal into an existing self-contained icon over adding a whole
separate icon/aura for it, when the two signals genuinely belong on the
same slot.

## What this changes going forward

`resource_spender_icon` is now the concrete Class IV reference - any future
ability that gates on real castability AND grants its own tracked result
(a shield, a stacking buff, a resource conversion) should be evaluated
against it before reaching for a fragment-stacked `cooldown_tracker_icon`
instead. Everything else in the registry stays where it is; this doc adds
a shared vocabulary for design conversations ("that's a Class III ask" /
"that's genuinely Class IV, it needs the spender template") rather than
changing any existing template's behavior.
