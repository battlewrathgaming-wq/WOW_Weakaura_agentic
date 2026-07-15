# picker_build — the runway (from what we need to how it's built)

_The manufacture plan for the HTML picker V1. The SPEC is `picker_tree.md` (8 laws, seams closed, pool assessed,
feasibility confirmed) — this doc only orders the pressing. Pace: easy, no rushing (agreed). Each phase names its
inputs, output, verification, and what DONE means. Nothing here invents; invention finished in the tree._

## The shape of the build

```
Phase 0  library emit      (data → library.json)          ─┐ independent,
Phase 1  JS codec port     (encode chain + cross-check)   ─┘ parallelizable
Phase 2  template press    (the machine presses the lanes' templates + 2 behaviour fragments)
Phase 3  the shell         (wizard + library face + minting, over 0/1/2)
Phase 4  the stamp         (cross-validation → live import → grading)
Phase 5  doors light up    (post-V1: contracts land → regenerate library.json; shell untouched)
```

V1 ships with the lanes that exist: **DoTs (target + catch-all) and pets**. Every other door renders as
knowledge only (the library face) until its contract lands.

---

## Phase 0 — the library emit gear

**One dumb emit** (house style: defined I/O, build-once, deterministic — rerunnable forever).

- **Inputs:** `Input/*_talents.json` (cards: spellId·name·tree·description·terms·passive) ·
  `creator/planning/resolved.json` (chains: axes+edges+effects, 9,152 spells) ·
  `creator/planning/tables/_index.json` (spec captions) · the DoT select outputs (ID-family shelves).
- **Output:** `library.json` — one file, per-class → per-spec → {cards, chains, shelves, captions}. Verbatim
  fields, provenance stamped (source paths + extraction date in a header block). `custom_N` gaps carried AS
  gaps (the "not provided by CoA" rule renders them; the emit never papers over).
- **Verification:** counts reconcile against sources (spells in = spells out, per class); spot-check 3 classes'
  chains against resolved.json by eye; the gate's spirit — word-match any enum the shell will trust.
- **DONE =** `py emit_library.py` → library.json, idempotent, counts printed as a receipt.

## Phase 1 — the JS codec port (encode-only)

The one riskiest-bounded piece — start it first (parallel with Phase 0; they don't touch).

- **Reference:** `Weak Auras/weakaura_codec.py` (LibSerialize port, live-proven; EncodeForPrint alphabet).
  Port the SERIALIZER only — the shell never decodes (one-time minting: emit, never ingest).
- **Pieces:** LibSerialize serialize (few hundred lines, translate the Python) · DEFLATE raw via native
  `CompressionStream('deflate-raw')` with inline pako fallback (no CDN — self-contained law) ·
  EncodeForPrint (~20 lines) · the `"!WA:2!"` prefix.
- **Cross-validation harness (build-side, Python):** take N pressed packs from the machine → hand the SAME
  tables to the JS encoder (run under node for the harness) → decode BOTH strings with the existing decoder →
  **table-diff must be CLEAN**. Decode-equivalence, not string bytes (DEFLATE output legitimately varies).
  Test vectors: the codec's own edge cases (floats %.14g, embedded strings, empty tables, multiline custom code
  — findings #8's class).
- **DONE =** harness green on the coverage packet's 36 members (every region/trigger type through the JS chain).

## Phase 2 — the template press

The machine presses V1's parts AT BUILD TIME; the shell ships completed tables and never authors.

- **The two behaviour fragments** (gap ledger #3): *appear* (trigger show-state only) and *persist-styled*
  (showAlways + ability-local condition flips). Authored as docket fragments, pressed through gate → fill →
  canon like everything else. Small; unlocks Q4 for every lane.
- **Lane templates:** DoT-target member+group (from the pressed Target tracker contract) · DoT catch-all
  (from the multidot pattern) · pet (from the guardian pattern; its custom Lua rides verbatim — authored on the
  addons bench, wrapped here per the charter). Each × its legal behaviour fragments = the template set.
- **Slots:** each template declares its fillable slots (spellId/name/auranames · load class+spec · group
  placement xOffset) — blank-slate parts law: authored frame + fillable slots, no residue.
- **Verification:** every template through canon.lua headless-green; ONE of each lane hand-imported live before
  the shell work leans on them (invariant 6 — don't build three phases on an unproven template).
- **DONE =** `templates.json` (pressed, slot-annotated), stamped into library.json or beside it.

## Phase 3 — the shell

One HTML file. Text-only (law 8). No framework — vanilla JS + inline CSS; everything embedded (data + codec).

- **The wizard:** the 6+2 screens exactly as the tree's script (Q0→Q5 + Q2.5 scope + Q4.5 closer). Single-pick
  lane loop (law 7). Prune-forward at every step (law 1) — menus render FROM the data, no hardcoded lists.
- **Minting:** slot substitution into pressed templates · one-right placement (HxW+px, static groups only) ·
  "COA — <Spec> <bucket> (<scope>)" id + mint randomizer (one-time minting — no ingest path anywhere) ·
  class+spec load always · group name as editable prefill · Copy button + the 3-line import instruction +
  the law-6 sentence ("packs, not a HUD — arrange and restyle in-game").
- **The library face:** browse classes → specs → chains ID→ID→ID · spec captions from _index · "not provided
  by CoA" on custom_N gaps · **"track this" renders ONLY on pressed lanes** and drops into the wizard at Q4.
- **Build assembly:** `build_picker.py` injects library.json + templates.json + the JS into the shell template →
  `picker.html`, provenance-stamped (build date + source commit in the footer). The HTML is a BUILD PRODUCT —
  never hand-edited (pipeline law; fix the gear, re-emit).
- **DONE =** picker.html walks all six questions for DoTs(both scopes)+pets and mints strings; library face
  browses all 21 classes.

## Phase 4 — the stamp

- Cross-validation: for each lane, same picks pressed via the machine AND minted via picker.html → decode both →
  table-diff CLEAN.
- **Live import** (Battlewrath): one minted string per lane into the real client — import clean, display right,
  test events safe (the subRegions class of bug is exactly what this catches).
- Grading pass, findings filed in `creator/verification/findings.md` — the picker joins the same loop as
  everything else.
- **DONE =** three lanes live-stamped. V1 exists. Distribution = the Discord sentence + the file.

## Phase 5 — doors light up (post-V1, not this runway)

Ready contract → cooldown lanes (queue + dim-grid costumes already specified) · Self contract → procs/stacks ·
select recipes (HoT mirror · behaviour-drivers · stacks) · resource bars. Each lands as: press the contract →
add its templates → re-run the emit + build. **The shell does not change** — that's the test of Phase 3 done right.

## Order & runway

1. **Phase 1 first** (the only piece with real unknown-unknowns; everything else is proven motion) — Phase 0
   alongside whenever convenient.
2. Phase 2 next (small; the live template check is the one mid-build pause needing Battlewrath in-game).
3. Phase 3 once 0+1+2 stand. 4 stamps it.
4. Compiler-change law: these are NEW gears (emit_library, the JS, build_picker) — no existing compiler files
   touched; if a wall forces a change to fill/gate/codec, the 4-step checklist + "Go" applies as always.
