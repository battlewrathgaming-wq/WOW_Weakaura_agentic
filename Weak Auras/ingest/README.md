# ingest/ — external WeakAura pack training pool

A **separate pool** from `Outputs/aura_corpus/` (Battlewrath's clean, in-game,
v86 authoritative corpus). This one is **grammar / training breadth**: published
packs (e.g. db.ascension.gg) decoded for evidence of *how WAs can be composed*.
Kept separate and provenance-stamped so foreign / old-version shapes never
contaminate the clean corpus. See `../blueprint/COMPOSITION_GRAMMAR.md`.

## Workflow
1. On a pack's page, click **Copy Import String** (not the JSON view — the
   display JSON is fragile to re-parse when a pack has custom functions).
2. Save it as a `.txt` file in **`inbox/`** (one import string per file; name it
   anything, e.g. `felsworn_infernal.txt`).
3. Run: `py ingest.py`
4. Each file is decoded to **`reference/<name>.json`** (provenance header + `root`
   + `children`), and the source `.txt` is moved to **`processed/`** (the tag).

## Retail packs — name them `Retail_<name>.txt`
Retail WA is a **grammar goldmine** (expert composition) but a **content minefield**
(retail spells / trigger types / systems don't exist on our WotLK 3.3.5a server, and
retail WA may be a *higher* internalVersion than our 86 — can't Modernize down). The
`Retail_` prefix stamps `provenance.origin = retail`. Learn the *structure*; the
index tells you which blocks are reproducible.

## Transferability check — `py transfer_check.py`
Grades each `reference/` pack against our `wa_index/index.json`: which region types,
trigger types, check variables, and change properties are **in our WA** (transferable)
vs **foreign** (retail-only / non-reproducible). Ascension packs read mostly CLEAN;
retail packs surface exactly which expert blocks we can adopt vs must skip. Read a
flag with the `origin`/`iv` columns: v86-ascension flag ≈ index-coverage gap; retail
flag ≈ genuinely foreign feature. `py transfer_check.py <name>` for one pack, verbose.

## Trust model (sanitation)
- `reference/*.json` carries `provenance.internalVersion` + `modernized:false`.
  **Trust the structure (grammar), not the exact field shapes**, until Modernized.
- Old-format (version 0/1) strings can't be decoded and are reported, not ingested.
- Modernize `v?->v86` is a separate later pass (needs the harness hardened) — not
  required for structural/grammar analysis, which is version-robust.

## Folders
- `inbox/` — drop zone. **gitignored** (transient, local).
- `processed/` — source import strings after ingest. **tracked** (reproducible seed).
- `reference/` — decoded JSON training library. **tracked** (the library).
