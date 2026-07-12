# Blueprint — how to reason about this system (read first)

The single mental model. Not a status log (that's the memories + `COMPOSITION_GRAMMAR.md`
+ `ingest/`); this is *how to think* so reasoning stays coherent and doesn't drift.
Fresh basis — replaceable wholesale if it proves wrong.

## The model
A **knowledge-grounded, human-in-the-loop compiler**: turn **intent** (what to
display) into a WA-valid aura by composing from a vocabulary WA itself defines,
attaching parts by a grammar learned from real auras, and letting WA validate.
We do not *approximate* WeakAuras — we **harness** it: its source for the
vocabulary, its own engine for validation.

**The pipeline (one coherent whole — this era enriched the middle, replaced nothing):**
```
intent
 ├─ [Mask]            WHERE — defined position / spatial budget            · stands
 ├─ [Class inventory] WHAT fills each position — the docket/BOM (agent)    · stands
 ─► [WA index + Grammar]  HOW it's expressed — vocabulary (what WA accepts:
 │                     Family→Type→Options, input_kind, value-domains) +
 │                     composition grammar (how parts attach)              · ENRICHED this era
 ─► [Assembler]       JOIN + WRAP — dumb distribute+pair into a table       · stands
 ─► [WA Lua env]      FILTER — Modernize/validate, part of export           · stands
 ─► import string
   grounded by [ingest/ training pool]  real auras = evidence of how WAs are composed
```
The index + grammar are the **"how it's expressed"** layer — what an agent reasons
with when *building the class inventory*. They slotted INTO the existing pipeline
(mask / inventory / assembler / WA-engine all stand); they enriched the thin old
"blocks/slices" idea into WA-sourced vocabulary + evidenced grammar.

## THE governing constraint: one reasoning element
The **class inventory is the ONLY place reasoning happens** — the agent decides what
fills each position (intent → docket/BOM). **Everything else is structural FACT** the
agent must fit within, never invent — *specifically so agents can't invent the frame:*
- **Mask** — positions we've *already agreed*; not the agent's to move.
- **WA index** — WA's own vocabulary; the agent picks from it, can't fabricate a lever.
- **Grammar** — how parts *provably* attach; evidenced, not invented.
- **Assembler** — dumb mechanical join+wrap; zero reasoning.
- **WA Lua env** — WA validates; the final arbiter.

The agent is **inventive WITHIN the inventory** (composing intent from the factual
vocabulary + grammar) but **cannot invent the frame** — position, lever, join, or
validation. That is what makes agent-driven building *sound*: invention is channeled
into one sandbox, surrounded on all sides by hard, WA-sourced, pre-agreed facts +
WA's own validation. It can't hallucinate structure, because structure isn't its to
author. Everything upstream of the inventory is the hard facts it must fit within.

## North star (unchanged): a community service
A *workshop taking commissions* — a requester brings a user story ("flare when
Voidseeker procs"); the pipeline returns a working, generic (multi-user) WeakAura.
Reasoning/assembly/fitness stay **in-house**; the requester's only job is the story
(+ optional *homework*, e.g. a spell ID). An **agent** writes the docket from the
story, bounded to the known vocabulary + grammar; gaps are marked homework, never
guessed; a homework package self-verifies (the game lights up on import, or not).
The **HUD** (Necromancer, since Battlewrath plays it) is the *proof we can constrain
the unknowns* — not the end. Service is downstream of a factual basis + working
outputs.

## Reasoning anchors — reason WITH these (the load-bearing distinctions)
1. **Provide vs Handle.** We generate the **input contract** (what a real export
   contains). WA does its own **handling** (derive/normalize/evaluate/apply). Never
   emit handling-forms or pre-empt WA. `[[provide-vs-handle-boundary]]`
2. **Grammar vs Content.** *Grammar* (structure — how parts attach) is transferable
   and reproducible. *Content* (spells, values, retail-only features) is game-
   specific. Learn grammar broadly; the **index is the filter** for what content is
   reproducible on our WA.
3. **Generate / Validate / Handle — three roles.** Index+grammar **generate**;
   index+WA **validate**; WA **handles** (Modernize + runtime). Keep them distinct.
4. **Index = generative source, not just a validator.** It's the categorized space
   of what we *can* provide + the shaping grammar → the agent invents **compositions**
   (valid combinations no example shows) — but only *within the inventory, from factual
   levers*. Compositional invention (yes) ≠ inventing the frame (never — see the
   governing constraint). Harvest/pool = **grounding, not the ceiling**; WA's own
   engine *licenses* the invention (says yes/no). We are not trapped scraping examples.
5. **Per-lever: Choice / Controlled / Frame / Residue.** Choice = which type; Controlled
   = what the agent sets (varies); Frame = fixed skeleton from the choice; Residue =
   inert leftovers → **dropped on emit** (clean auras; agents amplify residue into
   drift), mined only as per-choice witnesses on ingest.
6. **Intent ↔ Structure.** The pool pairs *purpose* (pack filenames) with *composition*
   (decoded) — the seed for the eventual intent→grammar mapping the service needs.
7. **Data sourcing: probe → manifest → store → filter; Source vs Verification.** Gather
   comprehensively, THEN filter — don't pre-filter to what you think you need (the store
   catches classless/un-hooked/triggered spells the in-game scrape can't see). The
   repeatable authority (`Spell.dbc`) is the **SOURCE**; the live in-game scrape is
   **VERIFICATION** — a fallback you keep reaching for is *pressure to change approach*,
   not a crutch to lean on. Corollaries: **commonality ≠ quality** (the corpus is inertia;
   most-common is often the stale copy — current-best comes from reasoning+testing, not the
   norm), and **completeness > richness** (a partial signal biases conclusions — worse than
   an absent one; why cast-type was dropped). `[[proc-basis-plan]]` `[[diagnosis-tool-and-corpus-findings]]`

## The dumb-machine rule
All the intelligence lives in the agent authoring the **BOM** (the docket: part-
selection + reasoning). Everything downstream — assemble, inject — is **dumb**, zero
reasoning. Correctness is not enforced by the machine; it's *reasoned* by the agent
and *validated* by WA. `[[pipeline-not-agent-handwriting]]`

## Component map (honest current state)
| piece | role | state |
|---|---|---|
| mask (`mask_build.py`, `masks/`) | WHERE — position / spatial budget | **built** (stands) |
| class inventory (`<Class>/inventory.py`) | WHAT fills each position — the docket/BOM authoring surface | stands; **content now DATA-SOURCED** (`coa_spells.json`); redesign around index/grammar pending |
| `wa_index/` | HOW-expressed: the vocabulary WA accepts (1042 levers, input_kind, value-domains, name-reconciled) | **built** |
| `COMPOSITION_GRAMMAR.md` | how parts attach — evidenced across 21 packs | **evidenced, maturing** |
| `ingest/` | training pool (ascension + retail), transferability-filtered, intent-labelled | **built** |
| `weakaura_codec.py` | lossless import-string ↔ table | **built** |
| `plane/` | dumb assembler MVP — reproduced a hand-build byte-for-byte | **proven (thin)** |
| WA `Modernize` (headless) | canonicalize/validate | **harnessable** |
| generative assembler (BOM → distribute+pair) | the real backend | **designed** |
| agent/resolver (story → BOM) | the reasoning front-end | **designed** |
| script-insertion (custom check/combination/code contract) | the expert frontier | **next workstream** |
| **data foundation** (`dependencies/coa_spells.json`, `ability_inventory/`) | the class inventory's CONTENT — every COA-relevant spell (6922 class-hooked + 2230 triggered) + categorisation signals (cooldown/cost/castTime/range) + the `effectTriggerSpell` PROC GRAPH; class:spec-keyed | **built + live-validated** (DBC `Spell.dbc` @ patch-D, 99.97% vs full live scrape; probe→manifest→store→filter) |
| type-configured pack (first product) | every ability as a pre-built type-config drive-from-ID aura; users arrange own UI; external-input → blank-basis scaffold | **designed** `[[type-configured-pack-first-product]]` |

## Drift-verifiers — make the holes loud
If reasoning has drifted, one of these is being violated:
- Emitting WA's **handling-forms** or **residue** (should provide clean input only).
- Letting **foreign/retail content** into what we'd *generate* (grammar ok, content no).
- The **assembler doing reasoning** (it must be dumb; reasoning lives in the BOM/agent).
- Trusting **fields** from non-v86 packs (trust *structure* only, until Modernized).
- Generating only from **harvested examples** (trapped) instead of the index+grammar
  (inventive, WA-validated).
- Claiming an aura "works" when the bytes weren't **pipeline-produced + unedited**.

## Docs
This · [DATA_ROUTES](DATA_ROUTES.md) (flight record: how we route through the data + where
each route stops; the behaviour log) · [BEHAVIOUR](BEHAVIOUR.md) (next item: intent = class
of action; sourced terminology, not hardened) · [BASE_AURAS](BASE_AURAS.md) (the minimal base
aura per type — harvested from the corpus; primitive vs layout vs system) · [REFERENCE_MODEL](REFERENCE_MODEL.md) (generic 11-component scaffold) ·
[COMPOSITION_GRAMMAR](COMPOSITION_GRAMMAR.md) · [SLICE_CLAIM_MODEL](SLICE_CLAIM_MODEL.md)
· [REQUIREMENTS_AND_MVP](REQUIREMENTS_AND_MVP.md) · [RECONCILIATION](RECONCILIATION.md)
(why the bespoke `template_filler` was retired for a data-driven approach).

Per-layer docs — **all still apply**; the index+grammar *enriched* the middle:
[1_mask](1_mask.md) (WHERE, stands) · [4_inventory](4_inventory.md) (WHAT, stands) ·
[5_assembler](5_assembler.md) (JOIN+WRAP, stands) · [6_wa_engine](6_wa_engine.md)
(FILTER, stands). [2_slices](2_slices.md) + [3_blocks](3_blocks.md) describe the
thin early expression layer now **matured into** `wa_index` + `COMPOSITION_GRAMMAR`.
