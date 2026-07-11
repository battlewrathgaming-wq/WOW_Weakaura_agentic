# dependencies/

Checked-in build inputs that are **expensive or impossible to regenerate on a fresh
clone** — they need the live Ascension client MPQ (or an in-game scrape) that not every
machine has. Tracked deliberately so the pipeline downstream of them runs anywhere.

This is the counterpart to the ignored scratch under `Outputs/` (e.g.
`Outputs/spell_dbc/`, the 163MB full `Spell.dbc` store): the big regenerable dumps stay
ignored; the small **filtered, indexed** products land here and get committed.

| file | produced by | what it is |
|---|---|---|
| `coa_spells.json` | `Weak Auras/ability_inventory/filter_coa_spells.py` | the COA-relevant spell table (9152: 6922 class-hooked + 2230 triggered), class:spec-keyed, carrying the `effectTriggerSpell` proc graph — the class inventory's authoritative **content** source. |

Regenerating `coa_spells.json` requires `Outputs/spell_dbc/spell_dbc_full.json` first
(`Scripts/extract_spell_dbc.py`, needs the client MPQ). If you have the committed file
and no client, just use it — that's the point of tracking it.
