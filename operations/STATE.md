# STATE — where the machine is

_Last updated 2026-07-14 (evening — restore point before the derived-gears rewrite). The single "where are we" read.
Detail lives in the code + READMEs this points at._

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
- **Classification SOLVED (2026-07-14):** resolver Pass 1 stores the AXES (invocation·persistence·target·verb·hub +
  costed/generates) as fact; Pass 2 derives the SIGNAL view; the **bucket map** (`creator/planning/buckets.md`) = seven
  plain-language "why you press it" meanings → 3 mechanisms → 4 products. Custom-effect gaps named/accepted (190 =
  apply_area_aura +113 edges; residue bounded-opaque, no dev channel).
- **First bucket-born pack SHIPPED through the full machine:** Target tracker contract (select recipe + WA-literal emit)
  → `populate.py` (contract-driven document press) → gate → stage → pickup → `necromancer-death-target.txt` (1 group +
  7 member icons, decode-verified). The tome sample refit to match.
- **Two LIVE catches drove real fixes (the loop working):**
  1. `spellIds` = BuffTrigger1 residue (stored, never read) → contract corrected to `useName`+`auranames`; **gate grew
     the live-key tier** (`harvest_live_keys.py` → `maps/live_keys.json`: aura2 = 77 live / 18 residue keys, source-cited;
     residue declares now BLOCK; tome demonstrated the block).
  2. `load.class` missing `use_class` = dead load config (fill.py:49 hand-translation; `WeakAuras.lua:814` — a
     multiselect load arg needs `use_<name> ~= nil`). Confirmed by Battlewrath's live capture of a real stored load
     block (also verified the 32-token class roster + specialization stored form = index-keyed, 20-entry list whose
     NAMES are still unknown — `load.specialization` stays un-wired).

## Open / next (not blocking, discuss before building)

- **★ THE HEADING: the derived-gears rewrite (agreed, restore point set, not yet built).** Three hand-written stored-form
  shapes found in the gears (fill's load translation — the live bug; expand's type-blind `use_` rule; expand's hand
  multiEntry array shape). One true source authors them all: **`ConstructFunction` (WeakAuras.lua)** — per `arg.type`,
  the stored form + `use_` gate semantics. Plan: harvest → `maps/arg_shapes.json` (source-cited templates, sibling of
  live_keys) · fill drops its load translation (verbatim; fully dumb) · populate shapes load from sheet-type × template ·
  expand's filter shaping goes type-aware off the same map · tome refit · **regression = re-press all dockets, diff:
  byte-identical except load gaining its live form** · rider: flip class_table's 18 unverified tokens off the capture.
- ✅ **LIVE-PROVEN (2026-07-14 evening):** all four packs imported cleanly and correctly in the live client —
  necromancer-death-target (both live fixes aboard), reaper-soul-target, the necromancer-oneoff (showOnMissing), the
  refit tome. Plus the full dry-run battery (green ×4 distinct packs · red 7/7 at the correct tiers) and Battlewrath's
  independent pickup run reproducing the products **byte-identical**. The chain is live-proven end to end.
- Still pending in-game: the specialization list's NAMES (20 index entries) → wire `load.specialization`.
- **Runtime — deferred half:** online/unattended operation + menu-spawn already done for the console; a true
  push-and-leave drainer + receipts hardening remain.
- **Cheap gate wins:** validate `load.class` against `maps/class_table.json`; populate a `unit`-value domain.
- **Migrate `plane/`'s wrap gears** (expand/fill/bounce/bundle/codec) into `engine/Production/`.
- **The CREATOR half — established and producing** (`creator/` at root; the classification headline LANDED — see
  Realized). Its planning incubator holds the bucket map, the Target tracker contract, resolver/citizenship/pull/populate.
  Next contracts (Ready tracker · Self tracker · resource bars) reuse the same spine; graduation out of `planning/`
  when the shape firms.
- **`operations/` + memory split done** — tracking/touchstones → operations; memory slimmed to how-to-find + how-we-work.

## Ground rules (the how, in one place)

Source (WA/contract) is truth; no creator dialect. Docket is WA-literal. Nothing past the gate authors. Slim =
minimal FOOTPRINT (canon completes), never aliased NAMES. Headless-green ≠ live-proven.
