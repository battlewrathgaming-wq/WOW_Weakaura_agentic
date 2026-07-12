# BASE_AURAS — the minimal base aura per type (harvested, not asserted)

The modelling target: for each reader/primitive, the **smallest aura that expresses it
correctly**, drive-from-ID. Each base here is HARVESTED — the canonical (most-common) shape
among single-reader corpus auras of that type (`plane/diagnose.py`), not invented. When the
corpus and a description disagree, the corpus wins (it caught `preferred_match` and the
"buff base needs a condition" errors).

**Signal vs treatment — and the signal has POLARITY.** A condition change conveys a state, and the
state has a *sense*:
- **"can't"** (unavailable — cooldown, no resource, missing req) → a **dimming/blocking** treatment;
  **desaturate** is the canonical.
- **"should"** (opportunity — procced, ready-to-spend, empowered) → a **positive** treatment
  (highlight / border-flash / …) OR a **system** (the rotation group, below).

The treatment must **match the polarity**; *within* a polarity the specific effect is **taste**,
deferred. The corpus's desaturate-dominance (66× vs glow 10×) reflects its **cooldown-weighting**
("can't" is common), NOT a universal default — and per-aura "glow" is rare partly because the
"should" signal is often **systematised** (rotation group), not because glow is disliked.
`[[taste-lives-at-inventory-layer]]`

## Two aura archetypes — the single thing we care about (per aura)

Everything per-ability reduces to two shapes; multiplicities go to systems (below). They differ in
*how we model them*, too:

- **A. Track-and-show** — an aura reads a native signal (event / buff / cooldown) and shows.
  Self-contained, one read. Modelled by **harvesting** the corpus canonical (cooldown ✓, buff ✓) —
  the corpus knows the shape.
- **B. Exist-and-listen (for modifiers)** — an aura **exists for its base ID** and listens for
  what's active that can **modify** it (procs/buffs → the `P→X` relationship). Pull-based
  ([[cross-aura-effects-pull-not-push]]). We **own the mechanism** (base trigger + listener +
  condition) *and* the relationships (the proc basis), so B is built by **mapping our data in
  directly — inspect it, don't harvest a corpus**. More expensive: A is one fixed shape stamped per
  ability; **B must resolve, per ability, which modifiers apply to its base ID** — a data-join, not
  a template. We have the data; the cost is the mapping. (stack-ability + directed proc are both B.)

**A and B compose on one aura — they're layers, not alternatives.** A plain ability is A (e.g. the
cooldown base, doing its one job). When it *also* gets modified by a proc it becomes **A + B** — the
base stays pure ("cooldown does cooldown"), and the proc adds a clean B-layer (listener + condition)
on top. Additive: you stack a concern beside the base, never reach in and complicate it. Complex
auras are just sums of simple ones.

Buff *content shapes* (class buff / general proc) are configs of A. The **systems** (rotation
"what-to-press" stream, DoT/HoT bars, and the global GCD/range/stun indicator) absorb the
multiplicities — the group-spawn / HUD-anchor track.

## Placement is the mask's job — separate from the aura

A single aura carries ONE tracking read. WHERE it shows is a separate concern (the **mask**), and
it has two real MODES plus a spawn option — they differ in *position behaviour* (Battlewrath,
2026-07-12; grounded: corpus `group` examples have `grow=None`, `dynamicgroup` have
`grow=HORIZONTAL/DOWN`):

| layer | what it is | position behaviour |
|---|---|---|
| **aura** (the base) | one read — icon + a trigger | the tracking unit (this doc) |
| **group** (fixed) | children at authored offsets | each buff shows in **its authored place**; inactive → its slot stays empty, neighbours don't move; predictable |
| **dynamic group** (reflow) | children claim a **shared** space | they **compete/claim** a slot — FIFO order, and **reflow / drop-off** when one expires before a neighbour; position is runtime, not authored |
| **+ autoclone** (spawner) | a dynamic group populated one-clone-per-match | track-MANY-**unknown** (the DoT/HoT system) — a population mode of the dynamic group |

So: **the baseline buff is a standalone icon.** Placement is a mask choice layered on top — fixed
(group) vs reflow (dynamic) — NOT part of the aura. In the corpus 63% of buff icons (74/117)
sit inside a container, but that is positioning, not tracking. Ship the aura; the mask/user
picks the mode. `[[templates-plane-replace-from-scratch]]` (mask = WHERE).

## Per-ability base auras (one aura, spell-primitive → reader → aura)

**A trigger is a persistence budget + condition surface, not just a signal-reader** — and both are
uneven. `showAlways` persistence + the availability vars (`insufficientResources`, `spellUsable`,
`onCooldown`, `charges`, `spellInRange`) concentrate in **Cooldown Progress (Spell)** — the maximal,
universal trigger (verified in-game + `wa_index`). So the reader step must pick a trigger that
exposes the levers the primitive needs; **many primitives ride CDP(Spell) even when not "about
cooldown"** (a persistent availability light rides it because `insufficientResources` + persistence
live *only* there). `[[trigger-is-a-persistence-and-condition-surface-budget]]`

### Cooldown  — MODELLED (the `corpse_explosion_slice` MVP)
- **region** icon · **trigger** 1× Cooldown Progress (Spell), `showOn=Always` · **subregion**
  cooldown swipe (native countdown) · **condition** `onCooldown` → desaturate ("on cooldown")
- One reader; the dim reads off the condition surface ([[trigger-activestate-vs-condition-surface]]).
  Drive-from-ID → auto icon. `[[plane-mvp-build]]`
- **Desaturate on `onCooldown`, NOT `spellUsable`** (both on the same trigger — free switch).
  **DOCUMENTED** (WA `Prototypes.lua:4105`; warcraft.wiki `API_IsUsableSpell`): `spellUsable` ==
  raw `IsUsableSpell()` — it reflects **resources (mana/reagents) + reactive-availability +
  spell-known**, and does **NOT** include cooldown or range. So it reads `true` *while on cooldown*
  → wrong variable for a cooldown dim; `onCooldown` is the cooldown state. Its global-smear risk is
  a **shared resource** (spend your mana → every mana icon dims at once), not range (range =
  `IsSpellInRange`, separate). **Per-aura conditions read ability-LOCAL state; global/shared state
  (resource, stun) → one HUD indicator, not repeated per-aura.** `spellUsable` is genuinely the
  right signal for **reactive / spender** abilities ("is this affordable / reactively up") — just
  not for cooldown.

### Buff  — MODELLED (harvested from 197 pure single-Aura buff auras)
- **region** icon (117/197) · **subregion** `subtext` (the load-bearing one: timer/stacks;
  subbackground+subborder are default dressing) · **trigger** 1× Aura, `player`, own-only
  (optional) · **catch** id-in-names (all ranks; corpus over-uses brittle exact-id) ·
  **showOn** = the one real parameter · **conditions NONE** (60% have zero — `showOn` does the work)
- Two canonical variants, same base, differ only by `showOn`:
  - **Active** (`showOnActive`/default ≈70%) — "I have it," counting down
  - **Availability** (`showOnMissing` ≈24%) — the reapply reminder (single most-common discrete shape)
- **Long buff** → same base **+ clickable-buff region option** (click-to-cancel). A region flag, not a new reader.
- stacks/remaining are *displayed* (via subtext), rarely *gated*.

### Buff CONTENT shapes — the inventory shapes the base by meaning

Same buff base (Aura reader + icon), but what the buff *means* configures three knobs —
**showOn · placement · where it reflects**. This is content filling the scaffold; the reasoning
is the class inventory's ("of this buff, what is it, so how should it show?").
`[[taste-lives-at-inventory-layer]]` `[[one-reasoning-element]]`

| content | meaning | showOn | placement | reflects |
|---|---|---|---|---|
| **expected / class buff** | keep it up for every advantage; a maintenance signal | **persistent** (always) | **fixed** (always know where) | standalone; **saturation flags the missing state** |
| **general proc** | an opportunity window; changes *playstyle*, affects the **character** not one spell | **active-only** (transient) | **dynamic group** (comes/goes, competes) | standalone |
| **directed proc** | one event empowering a **specific ability / series** | drives a **condition** | **on the ability's aura**, or both | **indicate the empowered ability** (reflect ON it, not free-floating; treatment deferred) — optionally also float in a dynamic group |

- The **directed proc is the same mechanism as the stack-ability base**: a buff-window read used
  as a *condition* on another aura, not as its own icon — just pointed at different content.
- Its wiring is **data, not hand-linked**: "which ability does this proc empower" comes from the
  proc basis (`effectTriggerSpell` / referenced-terms graph). `[[proc-basis-plan]]` `[[drive-from-id-never-hardcode]]`
- Wiring is **PULL, not push**: the listener (trigger 2, Aura reading the proc) lives IN the
  affected ability's OWN aura — never a central proc aura reaching out and addressing others by
  UID (fragile, dies on delete/rearrange). Each aura reads the native buff-window itself; forced
  by "users arrange their own UI". `[[cross-aura-effects-pull-not-push]]`

### Stack / threshold ability — archetype B (two-reader base; MAP from data, not harvest)
- **trigger 1 (driver)** Action Usable → base show/active state; **trigger 2 (listener)** Aura
  stack-count (or Power) → the modifier/threshold; **condition** `threshold met` → **indicate**
  "spend now" (treatment deferred). The *shape* is fixed; the **wiring** (which stacks/procs modify
  this base ID) is the per-ability data-join — the expensive part.
  `[[lanes-collapse-to-primitives-scaffolds-are-the-value]]` `[[cross-aura-effects-pull-not-push]]`

## Deferred — systems, not single auras

- **DoT/HoT row of timer bars, `unit=target`** — a **spawner**: `dynamicgroup + Aura(autoclone) +
  aurabar`, one bar per active DoT/HoT. Dissolves the whole "N DoTs" problem into one mechanism.
- **Rotation dynamic group — "what should I press now"** — a shared reflow space that surfaces
  procced / available / opportunity actions ("this procced, use it now"). The **system form of the
  "should"-polarity signal**, alongside per-aura indication — and likely why per-aura glow is rare.

Not everything needs a single-aura answer; repeat problems get a system. Both deferred.

## Method

Harvest each base with `plane/diagnose.py` (filter to single-reader auras of the type, take the
modal region / showOn / subregions / catch / conditions). Lock it here once confirmed against the
corpus. Then the `primitive → reader → base aura` mapping is a lookup, not a design task each time.
