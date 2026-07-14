# corpus — the reference material's home (root sibling of `creator/` and `operations/`)

_Started fresh 2026-07-14. The engine joins the root when we're ready to uproot it; until then it stays at
`Weak Auras/engine/`. Nothing was moved here — the old holdings (`Weak Auras/ingest/`, `Outputs/aura_corpus/`,
`Weak Auras/reference_captures/`) stay where they are and KEEP WORKING; pieces earn a home here by being rebuilt
into their proven shape, not by being carried over._

## What this space is for

**The goal of the corpus is to reduce noise to signal — so we can learn and replicate.** The WA reference material
as a worked resource, not scattered json: imports stripped to dockets (the reverse gear), compositions recognized as
patterns, the knowledge re-applied instead of re-reasoned. The long direction (roadmap): the corpus decomposes into
graph / feature-store / slice storage.

## The selection principle (what earns a place in patterns/)

- **Unique lead, or anti-common.** The common is already known — it collapses into the registries/maps and is not
  worth shelf space. What lands is what DEVIATES: a novel composition, an uncommon solution, a lead worth chasing.
  (The same by-exception law as everywhere: the gate speaks only on disagreement; roundtrip_diff surfaces only the
  novel; the corpus keeps only what teaches.)
- **Not precious.** A pattern's value is whether it **becomes a primitive** — adopted into the creator machinery.
  Entries that never graduate are disposable; prune without ceremony.
- **NOTHING is accepted without source backing — versioned.** Corpus frequency is evidence of USE, never of TRUTH:
  an observation in ore is a LEAD; acceptance (into a pattern, a map, a registry) requires the source citation
  (file:line) **plus the fork's version anchor** — `WeakAuras <toc Version> / internalVersion <n>` (currently
  5.21.2 / iv86). Staleness is then mechanical: current fork ≠ cited fork → re-verify before trusting. The proven
  sequence (`%matchCountPerUnit`: observed in ore → traced to BuffTrigger2:551 → accepted cited) is the mandatory one.
- *(Eventually, maybe: the creators' single look-up source for known patterns. Noted, deliberately not built toward —
  that's rushing.)*

## Structure (settled 2026-07-14 — refinement stages, ore → metal)

- `intake/` — the drop→decode flow (the ingest gears, rebuilt here when proven; the old `Weak Auras/ingest/` serves until then)
- `raw/` — decoded imports, **provenance-stamped** (`{source, author, captured, origin-class}`), append-only. Origin
  (ours / Ascension / retail) is a FIELD, not a folder — folders multiply, fields filter.
- `dockets/` — the reverse gear's output: authored intent, each carrying its **CLOSURE stamp** (CLEAN = stub→press→
  roundtrip_diff came back registry-clean = perfectly understood; else it names the missing map = a finding)
- `patterns/` — **the point of the corpus**: recognized compositions as md+json pairs (human why + machine signature).
  HARD RULE: nothing enters patterns/ without a CLEAN closure stamp.
- `planning/` — **the start-up incubator: messy, exploratory, DELETED when proven.** Same charter as `creator/planning/`.

Files-first; the graph/feature-store shape earns its place at a real query wall (wall→expand), not before.

## The terminology bridge (the block era survives under matured terms)

blocks/BOM/parts → **patterns** (rebuilt through the gears, never recovered from blocks.db) · class inventory →
**a class's contracts** (`creator/<class>/` hives) · **mask** → unchanged: the WHERE authority + the human-feel
stabilizer, foldable into contracts (a 90 doesn't shift to a 70 across re-presses) · the old scrapes → `raw/` ore ·
blocks.db/native_blocks/gravity_wells → archaeology. Full table: `operations/HOW.md`.
