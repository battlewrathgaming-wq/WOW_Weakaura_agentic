# STATE — where the machine is

_Last updated 2026-07-14. The single "where are we" read. Detail lives in the code + READMEs this points at._

## The shape (two halves at the gate)

```
CREATOR (invent, from our info)          GATE (validate)         ENGINE (mechanical, wrap)
  class inventories (agent authors    →   engine/gate.py     →     engine/Production/  (stage · pickup · run · console)
   dockets - the mechanical proof                                  engine/Fact_basis/  (sheets · contract · maps)
   a slot functions)                                               plane/  (the wrap gears - migrate in later)
```
Generation lives ONLY in the creator space; the pipeline past the gate authors NOTHING, it wraps. WA (headless canon)
finishes. See `Weak Auras/engine/Production/README.md` and `Weak Auras/engine/Fact_basis/README.md`.

## Realized (proven this era)

- **Engine consolidated** — `engine/Fact_basis/` (truth: `sheets/` · `contract/` · `maps/class_table.json`) +
  `engine/Production/` (the machine). Two pillars, one membrane (the gate).
- **The gate** (`engine/gate.py`) — validates a docket's INPUT correctness: correct → silent · incorrect (bad
  enum / spell-id not in the corpus) → INVALID, blocks · unverifiable open box → UNCHECKED, soft. By-exception report.
- **The machine runs end-to-end, self-runnable:** authored dockets (`Production/_authored/`) → gate → `Docket_stage/<PID>/`
  → pickup bundles a PACK (PID = pack id) into ONE group import string → `Docket_complete/` + register + drain.
  - `stage.py` (author→gate→stage) · `pickup.py` (drain a pack → group string) · `run.py` (receipted one-shot) ·
    `console.py` (spawn-and-drive picker; menu `[6]` / `console.bat`).
- **Proven green (headless):** the Venomancer-Procs pack (dynamicgroup + Tome-of-Ahn'kahet aura2 member) round-trips
  reimport-stable; aura2 AND flat-group both survive the wrap. `Docket_stage`/`Docket_complete` are tracked (survive git).
- **Dialect dropped:** fill/expand/bundle speak WA-literal (`regionType`, not slim `region`).

## Open / next (not blocking, discuss before building)

- **LIVE-CLIENT import confirm** — everything is headless-green; the game is the final authority. Import a
  `Docket_complete/*.txt` string in-client, re-export, diff. The one check that can't be run headless.
- **Runtime — deferred half:** online/unattended operation + menu-spawn already done for the console; a true
  push-and-leave drainer + receipts hardening remain.
- **Cheap gate wins:** validate `load.class` against `maps/class_table.json`; populate a `unit`-value domain.
- **Migrate `plane/`'s wrap gears** (expand/fill/bounce/bundle/codec) into `engine/Production/`.
- **The CREATOR half** — its own consolidation (class inventories + the class compile + products), mirroring the engine.

## Ground rules (the how, in one place)

Source (WA/contract) is truth; no creator dialect. Docket is WA-literal. Nothing past the gate authors. Slim =
minimal FOOTPRINT (canon completes), never aliased NAMES. Headless-green ≠ live-proven.
