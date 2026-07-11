# BEHAVIOUR — intent = the overall class of action (WORKING DRAFT)

The next big item: classify each spell by its **intent** — its overall class of action —
so intent can drive *what to track*. This doc is the seed, not a settled scheme.

## RULE: terminology is SOURCED, not authored

Do **not** harden category names off a first draft — that's inventing the frame
(`[[one-reasoning-element]]`). The vocabulary is grounded from two sources:
1. **Tooltip-diff** of our own corpus (done — below). The game's own recurring verbs.
2. **External WoW play-research** (PENDING) — the standard play-archetypes
   (builder/spender/resource/proc-spend/major-CD/DoT/HoT/utility).

License to use retail knowledge: Discord players describe COA classes as *"hybrids of 2–3
classes… just combinations of things really."* So the WoW **play-grammar transfers**; only
the content (specific spells) is custom. Pattern-match known archetypes onto custom spells —
don't invent categories. `[[grammar-vs-content]]`

## The game's own verbs (tooltip-diff, 3612 descriptions, 21 classes)

The atoms of intent are **action-verbs**, not my nouns. Frequency = how load-bearing.

| game term (verbatim) | freq | the signal it carries |
|---|---|---|
| **increases / reduces** | 1273 / 503 | **modify** — most of the table shapes *other* intents (passive talent math); matches 57% `apply_aura`→`add_modifier` |
| **for N sec** | 1052 | duration — buff / summon / maintained state |
| **restore / heal** | 905 | healing output |
| **stack / stacking** | 573+260 | build-toward-payoff (pervasive, first-class) |
| **chance to / when you** | 396+48 | proc / reactive |
| **reduces the cooldown** | 369 | CD manipulation (a category neither of us first named) |
| **generates → consume / your next** | 311 → 150+167 | resource **builder → spender** |
| **every N sec** | 228 | periodic (DoT / HoT) |
| **summon / raise / animate** | 136 | deferred-payoff pet (mostly in baseline spellbook, not talents) |
| **critical strike** | 482+460 | dominant modifier theme |

`referencedTerms` (game's cross-ref nouns: Demonfire, Insanity, Felfury, Frozen, Command,
Advantage…) name specific **mechanics/states** — the *content* layer, not the intent layer.

## Structural grounding (effect × aura — enums SOURCED)

The other half of the vocabulary: the DBC `effect`/`effectAura` codes, resolved to meaning.
Enums sourced verbatim (not guessed) in `Scripts/spell_enums.py` — SpellEffect 0..164
(WowPacketParser) + AuraType 0..316 (TrinityCore). The behaviour DNA, readable:
- **`proc_trigger_spell` (aura 42) = 992** — biggest apply-aura subtype: procs (= "high proc traffic")
- `add_flat/pct_modifier` (729+510) = passive talent math · `periodic_damage` 339 = DoT ·
  `periodic_trigger_spell(_with_value)` 156+131 = tick-proc · `periodic_heal` 79 = HoT ·
  `school_damage` 1153 / `normalized_weapon_dmg` 379 = direct hits · `summon` 135

**Structure ↔ language AGREE** (the re-diff after grounding — the fact→intent bridge is
double-grounded, fact predicting tooltip and vice-versa):

| structural fact | dominant tooltip language |
|---|---|
| `add_flat/pct_modifier` | **increases/reduces 91%** |
| `summon` | **for N sec 89%** |
| `periodic_damage` / `periodic_heal` | **damage/heal + every N sec** |
| `proc_trigger_spell` | **chance to · stack** |
| `school_damage` | **damage** |
| CC auras (stun/root/fear) | **for N sec** |

**Three rims where the fact goes opaque** (route-6 — mark, don't infer):
1. **Ascension-custom enums** — ~360 spells use `effect>164`, 254 use `aura>316` (biggest
   `effect_165`×97, `aura_354`×109). Not in stock headers → resolve by behaviour/dev.
2. **`dummy`/scripted** — `effect=3`×183 + `aura=4`×404 ≈ 587 spells = "handled server-side";
   the code says look at the server, not the fact.
3. **creature behaviour** — the `Raise:`/summon minions (route 4 in DATA_ROUTES): what the
   spawned creature *does* isn't in the spell at all.

## Provisional grouping (SCAFFOLD ONLY — do not cement)

Battlewrath's first-cut buckets, kept as a loose shape to test the sourced verbs against —
NOT the naming:
- **Rotation** (incl. reactive / high-proc-traffic) → deal-damage · heal · other
- **Long-form / deferred payoff** → DoT · HoT · stack-to-spend · stat-modifier-builder · summon
- **Utility** → no clear damage/heal (mobility · position · stealth · dispel · interrupt · CC)

## Core vs rim (same discipline as everywhere)

- **In-schema core** — facts decide cleanly: summon (`effect=28`+dur), DoT/HoT
  (`aura=periodic_*`+dur), direct damage/heal, modify (`add_modifier`).
- **Rim** — needs the *relationship* or the *play*: reactive-traffic **volume**,
  build→spend **pairing**, "maintain" behaviour. Proc graph wires it; observation confirms it.
  Mark which is which. `[[trace-what-we-know-gaps-are-opportunity-or-accepted]]`

## Signal prep (before classifying) — sharpen the axes

Confirmed steps that lift signal / lane-separation, done or queued:
- **Rank-collapse by EXPLICIT grouping, never id-range.** Rank ids are wildly non-contiguous
  (`Ale of The God-King` = 573064→805780; `Barbed Spear` 560558→560881) — an N+1/proximity
  heuristic mis-groups across the seams. Use the inventory's per-ability `spellIds` membership.
  Effect: 6922 direct rows → **4342 unique abilities** (−2580 rank-dup rows, ~37% noise).
- **Read all 3 effect/aura slots.** **52%** of spells (4743/9152) use >1 slot — slot-0-only is
  blind to compound behaviour (`school_damage+trigger_spell`, `periodic_damage+damage_amp`,
  `school_damage+dummy`). The classifier must union across slots.
- **Ground 3 more enum axes** (sourced like `effect×aura`, standard 3.3.5): **WHO** = `targets`
  + `effectImplicitTargetA` (AoE/single/self); **HOW-gated** = `attr` flags (passive/channeled/
  hidden); **HOW-triggered** = `procFlags` (on-hit/crit/cast/kill). `effectImplicitTargetA`
  needs adding to the coa_spells manifest (a filter re-run).
- **Don't** deep-resolve the Ascension-custom enum rim — 3.3.5 leaves those `Unk`; route-6 /
  dev-ask, and multi-signal carries those spells. `[[classify-for-lanes-not-per-spell-resolution]]`

## Classifier aim: lanes, not per-spell resolution

The goal is the **pattern** — which lanes spells occupy and **how they bucket apart** — not
perfect resolution of every spell (Battlewrath, 2026-07-11). Success metric = *do the buckets
come apart with clean gaps* (distinct lane ⇒ distinct tracking treatment), NOT per-row accuracy.
Consequence: **the rims don't block it.** Lane assignment is **multi-signal** — a spell with an
opaque `CUSTOM_*`/`dummy` effect still carries cooldown, cost, targeting, and tooltip verbs and
buckets by *those*; the lane emerges where signals **converge** (the cross-map showed they do),
not from any single field. Don't spend effort perfect-resolving the ambiguous rim — it's the
wrong target; the separation holds without it. `[[classify-for-lanes-not-per-spell-resolution]]`

## Sequence

1. **"What is a spell"** — the schema; blocking sub-task = **ground the effect/aura enums**
   (989-count aura-42 & friends unreadable). The classifier reads the schema; can't classify "?".
2. **Source the terminology** — this tooltip-diff + external WoW play-research.
3. **fact → intent classifier** — core direct; rim matched against the archetype library + `ingest/` corpus (diagnose.py: corpus is ~40% rotation, corroborating). `[[diagnosis-tool-and-corpus-findings]]`

## First-cut result (`Scripts/classify_lanes.py`, PROVISIONAL names)

Four-axis classifier over 4565 rank-collapsed abilities. It CONVERGED — lanes bucket apart
cleanly, examples check out, and opaque custom/dummy spells rode their other signals into a
lane (the lanes-not-perfection principle held).

**Master split is ACTIVE vs PASSIVE** (attr passive/hidden — they coincide 100%):
- **PASSIVE 2979 (65%)** = the modifier/proc substrate: `passive:modifier` 1711 · `passive:proc`
  932 · scripted/other ~336. Mostly NOT auras — they're talent math that shapes other spells.
- **ACTIVE 1586 (34%)** = what earns an aura. Lanes: `active:buff` 330 · `active:proc-driver`
  232 · `damage:single/aoe/self` 209/35/19 · `summon` 98 · `active:scripted` 85 ·
  `utility/mobility` 63 · `cc` 59 · `dot` 51 · `heal` 45 · `hot` 12 · `active:other` ~347.

**Scoping consequence:** the type-configured pack builds for the **~1586 actives**, not 4565
rows — the passive two-thirds is substrate, tracked (if at all) as buffs the actives depend on.
Residual `active:other` (~8%) = auto-attack / trigger-only / defensive — genuinely miscellaneous.
Names stay provisional pending the external play-archetype pass.

**Grab-by-class index** (`py Scripts/classify_lanes.py --emit` → `Outputs/lane_index.json`,
gitignored/regenerable): `byClass[CLASS][spec][lane] → [abilities]` so working a class pulls a
lane by lookup (e.g. `NECROMANCER.Rime.dot`), plus a flat `abilities[]` where every record
carries a `why` block (the effects/auras/who/flags that drove the lane) — so each assignment is
**traceable** back to the sourced axes, auditable per-ability. NEXT (inspection pass): validate
the index is indexed + traceable enough to drive per-class lane work, and sanity-check lanes by
class before hardening any names.

## WA-side: the readers (the mapping's other half)

The spell is the input; the WA **reads** it. `plane/diagnose.py lens` indexes the corpus by
native-signal-read (`spell primitive → native signal → the trigger that reads it`, keyed on
trigger TYPE — `event` is residue on aura2) and **proves two readers carry ~2/3 of all
authorship**: **buff-window 66% + cooldown 28%**, everything else a long tail; most auras are
single-signal reads (primitives), multi-signal compositions (scaffolds) ~20%.
`[[corpus-signal-lens-buffwindow-cooldown-dominate]]`

The **Aura trigger** — the buff-window reader — is function-driven (WA implements it internally
as `BuffTrigger2.lua`), so it was absent from `wa_index/index.json`'s prototype scan — the one
gap. Now closed: `wa_index/aura_trigger_schema.json` characterises it across
**catch / resolve / show / read** (25 fields, domains resolved to `value_domains.json` + confirmed
vs the installed source, weighted by corpus usage). Rank control is the **catch** (name /
ID-in-names = all ranks; exact-id = one rank), NOT `preferred_match` (0/319). `[[aura-trigger-schema-and-matching]]`

**NEXT: the `primitive → native-signal → reader` mapping** over the two dominant readers — the
generation rule that turns a characterised spell into a WA. Then in-game construction, then COA
against the scaffolds.
