# Class_design/tools — extraction tooling (class-agnostic)

Shared, reusable tools for pulling ground-truth data into the Class_design lane.

## decode_build.py — CoA builder export / share decoder

Turns an ascension.gg CoA build (export string **or** share URL) into the list
of selected nodes, named against this repo's data. Prototyped + validated
2026-07-27 on a real Reaper build.

**Codec:** URL-decode → base64 → raw DEFLATE (zlib wbits −15) → a `:`-delimited
token list. Each token = an integer id, optionally `tN`:
- plain id = an ABILITY node (keyed by **spellId**)
- id`tN` = a TALENT node at rank N (keyed by the talent's **node id** — the same
  `id` field as the Necromancer's `12165` Sepulchral Might, not the spellId)

**Why this path is clean:** selection is *implicit* — only chosen nodes appear
(presence = selected). There is no "is this selected?" check to get wrong, which
is exactly the reliability question a live talent-tree walk has to answer.

**Mapping sources:** `dependencies/coa_spells.json` (spellId → name) +
`Input/<class>_talents.json` (node id / spellId → name, tree, type). It loads all
class files, so it decodes any class without being told which.

```
py decode_build.py "<export string>"
py decode_build.py "https://ascension.gg/en/v2/builder/coa/overview/<segment>"
```

Gaps: an id absent from the repo snapshot prints as **unresolved** (e.g. a node
newer than the scrape). Backfill from a fresh scrape or the in-game addon.

## Combat-log tools (sibling — currently in `../Necromancer/tests/`)

`parse_combatlog.py` (DoT/periodic) and `crypt_analyze.py` (channel) were born on
the Necromancer haste tests and live there with their method notes
(`../Necromancer/tests/README.md`). They're class-agnostic too; promote them here
if/when a second class needs them.
