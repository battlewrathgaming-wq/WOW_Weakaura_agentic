# picker_tree — the wizard's decision tree (prototype, 2026-07-15)

_The HTML picker V1's navigation as a story: every screen is a QUESTION, every answer is a NARROWING, and every leaf
must land on a docket we can press. This file is the talk-through artifact: the script on the left, the mechanical
backing on the right, the gaps marked honestly. The same script runs in the future addon shell — it just skips Q0._

**Status marks:** ✔ pressed & live-proven · ◐ basis proven, contract/recipe unbuilt · ✗ gap (named below)

---

## Q0 — "What class?"

21 crests, one click. The only question the addon shell wouldn't ask (spec detection is API-driven in-game).

| backing | status |
|---|---|
| class list = the batch press's enumeration (`batch_press.py`, `Input/*_talents.json`) | ✔ |

## Q1 — "What spec?"

The class's specs. Same class:spec slicing the 110-pack production run pressed on.

| backing | status |
|---|---|
| spec enumeration + member lists (`pull_target_tracker.py` spec_spells) | ✔ |
| `load.specialization` wiring (index-keyed, Prototypes.lua:1075) — solved mechanically; the 20 display names await the addons bench's spec-name capture | ◐ |

## Q2 — "What do you want on screen?"

The buckets speaking plain language for the first time. No WA vocabulary on this screen.

| choice (user-facing) | product behind it | backing | status |
|---|---|---|---|
| **My DoTs on enemies** | Target tracker + multidot | contract PRESSED, 110 packs live-proven (`target_tracker.contract.json`); multidot press-ready (`corpus/patterns/multidot-tracker.md`, per-class ID-family name lists from the batch select) | ✔ / ◐ |
| **My HoTs on allies** | HoT tracker (the ally mirror) | the multidot name-capture/print primitive generalizes (who I healed + what's still ticking, buckets.md); friendly-side select recipe + a HELPFUL `unit="multi"` live check = the open work | ◐ |
| **My cooldowns — what's ready** | Ready tracker | mechanism named (Cooldown Progress (Spell), the maximal trigger — persistence + condition budget); **contract unbuilt**: needs the spell-trigger palette + its liveness harvest | ✗ |
| **My procs & windows** | Self tracker (narrowed — see Q4) | mechanism known: aura2 `unit=player`, exact-id STANDING pattern; anchor on the CONSUMER, pull not push (buckets.md); **contract unbuilt** | ✗ |
| **My stacks & mechanics** | Self tracker (counter face) | same contract as procs, different face: stack count climbing + trigger-2 flip at threshold (gate→payoff, buckets.md) | ✗ (rides the Self contract) |
| **My resources** | resource-bar pack | "resolved — it's a pack, not a classification problem" (buckets.md): one bar per power type, all classes; unit-power trigger knowledge in hand (powertype = real content, written on selection) | ◐ |
| **My pets/guardians** | guardian tracker | scaffold closure-stamped (`corpus/patterns/guardian-health-tracker.md`); custom Lua = the addons bench's lane (charter) | ✔ |

## Q3 — "Which ones?"

Now and only now, actual spells: the pressed library for that class:spec:bucket — names + icons, checkboxes.
A shelf you were walked to, never a warehouse.

| bucket | the select behind the shelf | status |
|---|---|---|
| DoTs | the batch select output (dot ID-families per class) | ✔ |
| HoTs | friendly mirror of the dot select (HELPFUL, ally-target verbs) | ✗ recipe |
| cooldowns | axes carry `costed`/invocation — a ready-select off resolver output | ✗ recipe (falls out of the Ready contract) |
| procs | the behaviour-driver cut ("have proc, use spell"; weather skipped) — validation-triangle lexicon is partial evidence, not yet a select | ✗ recipe |
| stacks | class-mechanic + talent-local stack spells | ✗ recipe |
| resources | power-type enumeration per class (cheap, finite) | ◐ |
| pets | pet-spec detection (the guardian scaffold's registry names the family) | ◐ |

## Q4 — "How should it behave?"

Taste offered as a menu, never demanded as knowledge. **Proc's insight (Battlewrath): this is the same question
narrowed to two primitives** — not a new bucket, a behaviour fork inside one:

- **"Appear when it happens"** → show-on-active (you *react* to it appearing — the proc's native read)
- **"Always there, light up when live"** → persistent + condition flip (you *anticipate* it — the payoff/cooldown read)

Everything on this screen compiles to the three reactive surfaces (existence / mapping / reaction) — preset names on
the front, trigger-show-state + condition fragments on the back.

| preset (user-facing) | mechanical form | status |
|---|---|---|
| Always show | showAlways + styled states (dim on cooldown — ability-local `onCooldown`, never compound) | ◐ known form, not a docket fragment |
| Appear when active | trigger show-state only | ◐ |
| Light up when ready/live | persistent + trigger-2 / condition flip | ◐ |
| (V1 stops at ~3 presets) | | |

**✗ gap: the presets don't exist yet as named docket fragments** — formalizing them is small (each is a conditions
block + show policy we've already shipped variants of).

## Q5 — the string

One group, one import string, copy → done. The machine's pickup/bundle path is proven (`stage → gate → pickup`).

| backing | status |
|---|---|
| bundling + encode (the machine, server-side) | ✔ |
| the HTML shell doing the same encode client-side in JS (deflate+b64 of the picked parts) | ✗ the picker build proper |

---

## The gap ledger (ranked)

1. **Ready tracker contract** — the one structural gap: a whole mechanism-column (spell-trigger/cooldown) with no
   contract. Needs the spell-trigger palette + liveness harvest first. Unlocks Q2-cooldowns AND Q3-cooldowns.
2. **Self tracker contract** — procs + stacks + windows ride it; mechanism fully known, narrowing decided (two
   primitives at Q4). Second press after Ready.
3. **Style presets as docket fragments** — small, high leverage: three named fragments, reused by every product.
4. **Select recipes** (HoT mirror · proc behaviour-drivers · stacks) — each a bounded pull off data in hand.
5. **Spec display names** — chartered to the addons bench (census mission); index wiring already solved.
6. **JS-side encoder** — belongs to the picker build itself, not the tree.

**The shape of the ledger:** one real contract to invent (Ready), one to assemble from known parts (Self), and the
rest is recipes + formalization. The tree is walkable end-to-end today for DoTs and pets; every other leaf knows
exactly what it's waiting on.
