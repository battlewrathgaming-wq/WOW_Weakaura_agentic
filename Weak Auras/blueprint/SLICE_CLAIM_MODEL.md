# Slice-claim model — archetype → claim → slices → coverage algebra

DRAFT proposal (Battlewrath + Claude, 2026-07-10), grounded on the real
"Target items (Increased complexity)" set (spell 805040, Skeletal Archers).
A thing to shoot at — replace wholesale if wrong, cheaply. No code until "Go".

## Where the intelligence lives — one place only

The reasoning lives in the **agent authoring the class inventory**. Everything
downstream is **dumb** (assembly + injection). Do **not** hard-design the slice
declaration or bake coverage into the machine — the inventory is soft (logic,
checklist, pattern-detection) and evolves; the machine stays dumb.

**Class inventory = part-selection + reasoning → a BOM.** Car analogy: the agent
reasons what the thing is, then emits a bill of materials —

```
wheels ×4, size 123, white   |   body: model xay   |   engine: turbo
```

— then adds **design-consideration reasoning** on top: *"oh, it needs an exhaust."*
Completeness / dependency catches, done by the agent, not by a schema.

## The layers

**1 · Archetype — the agent's first reasoning question, per ability.**
*"Does this live in a slot, or is it a temporary proc display?"*
- **Slot resident** — reserved mask position; footprint **always present**; effects
  ride on top; never hides. (Design consideration: persistence ⇒ the agent claims
  an exhaustive trigger pair.)
- **Proc display** — no reserved footprint; appears on an **event**, **auto-hides**;
  momentary. (Harvest: proc_alert + glow_source.)

**2 · BOM — the agent's output.** Parts (slices/blocks) + their configs (filled
holes) + effects, plus the design-consideration catches. This is the class
inventory entry (the docket). Soft format — the agent's reasoning surface, not a
locked schema.

**3 · Slices/blocks — the parts the BOM references.** Pure primitives:
load / availability / cooldown / buff-uptime / proc / …

**4 · Dumb assembly + injection.** Takes the BOM, drops parts into lanes,
allocates indices, injects. Zero reasoning.

**5 · Coverage algebra = LATER verification, not a generative rule.** A state read
+ a check (agent **and** user) that the assembled aura behaves — e.g. persistence
actually holds (regions exhaustive), states are mutually exclusive (`any` is
safe), effects bind to the right region. Persistence is *reasoned* by the agent at
BOM time and *confirmed* here — never *enforced* by the composer.

## The state-space (for a slot-resident ability)

An ability is, at any instant, in exactly one region:
`ready (usable)` · `on-cooldown` · `unusable-for-other-reason (resource/range)`.

- **Availability** slice claims `ready` (Action Usable, showOnReady).
- **Not-usable** slice claims `¬ready` (Action Usable, **inverse**) — this is the
  *robust* persistence half: `ready ∪ ¬ready = always`, **by construction**,
  regardless of *why* it's not usable.
- **Cooldown** slice claims `on-cooldown` (Cooldown Progress, inverse) — narrower
  than `¬ready`; pairing it with `ready` leaves a **coverage gap** when the ability
  is off-cooldown but unaffordable (the fragile version).

Optimal persistence anchor = **usable + its own inverse** (one predicate, two
complementary halves). Already live-proven in the archive as
`resource_spender_icon`'s trigger pair — a harvest target, not an invention.
(WA flag semantics — showOnReady vs showOnCooldown+inverse — to be confirmed
in-game; Battlewrath is the authority.)

## The five targets, re-read as claims

| Target | Region(s) claimed | Derived composition |
|---|---|---|
| T1 Load | (orthogonal) class gate | `load.use_class` — applies to any archetype |
| T2 Availability | `ready` | single trigger, no condition |
| T3b Persistence | `¬ready` | trigger + desaturate-on-self |
| T3a Cooldown | `on-cooldown` | trigger + desaturate-on-self |
| **T5 Combined** | `ready` + `¬ready` | composer sets `any`; **persistence derived**; desaturate → `¬ready` |

**T5 is not special-cased — it is what a slot-resident claim compiles to** over the
availability + not-usable slices. That is the whole thesis: declare archetype +
claim, get the composition.

## Proposed inventory authoring surface (per ability)

```
ability: Skeletal Archers
spell_id: 805040
archetype: slot                 # slot | proc
slot: <mask slot id>            # position (out of MVP scope, but declared here)
claim:
  track: 805040
  effects: [desaturate_when_unusable]
  load: { class: NECROMANCER }  # optional (T1's slice)
  # persistence NOT declared — implied by archetype: slot
```

Composer expands → triggers(usable + not-usable) · `disjunctive: any` ·
desaturate condition on the not-usable trigger · load block → **the T5 data table**
→ Modernize → encode → import.

## Open questions

1. ~~What a slice declares for coverage algebra~~ — **deferred, deliberately.** The
   agent drives this as reasoning; don't lock a schema at the gate. Coverage is
   verification (layer 5), not a generative contract.
2. Minimum a **part** must expose so dumb assembly can place + inject it (its lane,
   its holes) — this *is* worth pinning, since the machine is dumb.
3. What the **BOM** carries as its stable interface to the machine (parts + configs
   + effects) vs. what stays free-form agent reasoning above it.
4. Proc archetype's parts — event + auto-hide + glow — harvested from
   proc_alert / glow_source.
5. Where the BOM lives concretely: `<Class>/inventory.py` (the docket), per
   [4_inventory](4_inventory.md) / [REFERENCE_MODEL](REFERENCE_MODEL.md).

See [RECONCILIATION](RECONCILIATION.md), [REQUIREMENTS_AND_MVP](REQUIREMENTS_AND_MVP.md).
