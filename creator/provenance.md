# provenance — what we can know, and where it truly lives

_Solidified 2026-07-14 from a **verified audit** (checked against the raw DBC, not asserted). The reference of what each
source authoritatively holds, what the merge preserved vs flattened, and where to reach back for anything reasoning lacks.
This is graduated, audited knowledge — it lives in `creator/`, not the incubator._

## Why this exists

`coa_spells.json` is **not an authority** — it's a **merge** of two authorities (the raw DBC + the in-game class
scrapes), and a merge can silently *flatten*: drop a field, and there's nothing left to miss it. So before we build
completeness on it, we verify what it kept. Discipline (carried from the sheets): **complete to the AUTHORITY, not to a
convenient copy of it.**

## The three sources

| source | location | authoritative for |
|---|---|---|
| **Raw DBC** | `Outputs/spell_dbc/spell_dbc_full.json` — 237,447 spells, 164 MB, gitignored; extractor `Scripts/extract_spell_dbc.py` | mechanics: full effects **incl. `effectClassMask`**, conditions, raw `desc`. Codes are NUMERIC (not enumerated). |
| **In-game scrapes** | `Weak Auras/ability_inventory/out/*.json` (per class) + `Input/*_talents.json` (talents) | meaning: `spec`, `sources` (tree), **`description`** (resolved), `cost`, `levelReq`, `isPassive`, `ranks`, `spellIds`, icon |
| **coa_spells.json** (the MERGE) | `dependencies/coa_spells.json` — 9,152 COA spells; merge/filter `Weak Auras/ability_inventory/filter_coa_spells.py` | the working set: effect slots + fingerprint + `coa.triggeredBy` attribution — **with flattening (below)** |

## What the merge PRESERVED (verified byte-identical to the raw DBC)

The per-slot effect data is faithful: `effect`, `effectAura`, `effectMisc`, `effectTargetA`, `effectTriggerSpell` — all
three slots, identical to raw. **The resolver can read the effect slots straight from `coa_spells.json`.**

## What the merge FLATTENED (dropped from the raw DBC)

| dropped field | resolver-critical? | reach back to |
|---|---|---|
| **`effectClassMask`** | **YES.** The per-effect *family-target mask*. `effectTriggerSpell` gives a *direct* spell→spell edge (we have it); but *family-based* effects — "reduce the cooldown of all [family] spells" — resolve their targets via `effectClassMask` × the targets' `spellClassMask`. Without it, **family-based cross-links are underivable.** | raw DBC — or heal the filter to carry it |
| `desc` | no (meaning, not mechanics) | scrapes (resolved `description`) / raw DBC |
| `casterAuraState`, `targetAuraState`, `shapeshift`, `dispelType` | not yet | raw DBC |
| `id` | redundant (it's the key) | — |

## The resolver's grounding (the decision)

- Build the effect interpretation on `coa_spells.json` — faithful for the effect slots.
- **Heal at the source, not around it:** extend `filter_coa_spells.py` to carry **`effectClassMask`** into
  `coa_spells.json`, so the family-based cross-links you want (proc → modify-cooldown-of-family) are derivable and the
  working set stops flattening the one field the resolver needs. (A one-field filter change + a regenerate — confirm before
  regenerating, since everything reads `coa_spells.json`.)
- `desc`/meaning comes from the scrapes; the condition fields from the raw DBC if reasoning later needs them.

## The rule

`coa_spells.json` is a **derivative**. When completeness matters, verify against the authority (raw DBC / scrapes) — as
this audit did — or heal the filter so the working set is faithful. Never build completeness on an unexamined flattening.
