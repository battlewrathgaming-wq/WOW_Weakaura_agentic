# ability_inventory

The **complete, spellID-keyed ability inventory for all 21 COA classes**, plus a
single-file HTML reference for community handoff. This is the *content foundation* the
class-inventory reasoning is built on: every ability a class has, keyed by `spellId`,
spec-tagged, with the talent↔ability cross-references wired.

## Where the data comes from (three sources, merged)

| source | what it gives | provenance |
|---|---|---|
| **talents** — `Input/<class>_talents.json` | talent-tree abilities: spellId, tree/spec, description, `referencedTerms`, costs, icon | dev-authored, scraped from ascension.gg's CoA builder — ground truth |
| **trainer** — `COA_DevDump /coadump trainer` | *trainable* baseline abilities, all ranks, per-rank spellIds, cost/level/desc | in-game (stock trainer API + tooltip `GetSpell` for the id) |
| **spellbook** — `COA_DevDump /coadump spellbook` | *learned* abilities, spec-tagged by book tab | in-game (`GetSpellLink` `\|Hspell:ID\|`) |

Trainer (trainable) + spellbook (learned) together are the full baseline sampling;
talents come from the repo. See `../Tools/COA_DevDump/` for the addon.

## Pipeline

```
in-game, per class (character of that class):
    /coadump trainer          (at the class trainer)
    /coadump spellbook         (anywhere)
    /reload                    (flush COA_DevDumpDB to disk)

lua5.1 dump_captures.lua       # game SavedVariables (Lua) -> out/captures.json
py consolidate.py             # captures + Input/ talents -> out/<CLASS>.json + _summary.json
py build_reference.py         # out/<CLASS>.json + Input/ -> reference.html
```

Class match: the capture's `playerClass` TOKEN → talent file, via
`../wa_index/coa_value_domains.json` (7 dev-holdover tokens are overridden there, e.g.
`SONOFARUGAL`→Bloodmage, `DEMONHUNTER`→Felsworn). All 21 tokens are confirmed first-hand
via `UnitClass`.

## Outputs

- **`out/captures.json`** — raw trainer+spellbook export. *Tracked* (it's the only repo
  copy of the scrape; not reproducible from the repo — it comes from the game client).
- **`out/<CLASS>.json`** ×21 — the merged inventory, keyed by base ability:
  `{ name, spec, sources[], ranks{rank:spellId}, primarySpellId, spellIds[], cost,
  levelReq, isPassive, iconPath, description }`. Ranks are grouped under the base ability.
- **`out/_summary.json`** — per-class counts (abilityCount, bySpec).
- **`reference.html`** — the community deliverable: search + Class/Spec filters + two
  views (abilities-with-talents-attached / talents-with-abilities-referenced), cross-linked;
  ability rows show their spellId rank range. *Not tracked* — regenerable via
  `build_reference.py` from the tracked `out/*.json`.

## Adding / refreshing a class

Scrape it in-game (the two `/coadump` commands + `/reload`), then re-run the three
commands above. `COA_DevDumpDB` is account-wide and accumulates; re-scrapes just dedup by
spellId. To wipe and start clean: `/coadump clear`.

## Attachments & what's next

`build_reference.py` resolves `talent.referencedTerms` → abilities/talents by first-pass
name matching (exact-normalised or whole-substring, singular/plural tolerant; categories
like "Command" fan out to all `Command:` abilities). This is the **proc basis** in
embryo — see `memory/proc-basis-plan.md`. The next passes on top of this dataset:
tighter **term resolution**, **talent-effect** parsing, and **ability-type**
classification (defensive / major cooldown / rotation).
