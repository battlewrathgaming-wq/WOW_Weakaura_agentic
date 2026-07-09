# Pipeline — chain map

Walk the arrows. Each strand has a supporting doc (linked) for its model; each
file's docstring holds the detail. Reason *to* a stage by following the chain.

Two laws thread the whole chain:
- **Authority = computed geometry** (the mask) **/ WA's own schema.** Live captures = intent only, never authority.
- **Mask owns the budget; the class inventory owns the composition.**

---

## A · Build the mask (authority) — [MASK.md](MASK.md)
[geometry.py](geometry.py) → [mask_build.py](mask_build.py) (relational matrix: grid ±21/±63/±105, bands ±125/±185, plateau P, size-by-throughput)
&nbsp;&nbsp;→ [masks/Central_hud.mask.json](masks/Central_hud.mask.json) — families = anchor + budget + composition(`single|subdivide`) + provenance(`live|design`)

## B · Read the intent (validates A, never defines it) — [CORPUS.md](CORPUS.md)
game `WeakAuras.lua` → [lua_table.py](lua_table.py) → [aura_scrape.py](aura_scrape.py) → `Outputs/aura_corpus/battlewrath_displays.json` (corpus)
&nbsp;&nbsp;→ [mask_trends.py](mask_trends.py) → `gravity_wells.json` (intent) → **validates** A's computed anchors

## C · Check a class against the mask — see [MASK.md](MASK.md)
`mask.json` + `<Class>/inventory.py` + `build_templates` REGISTRY → [mask_validate.py](mask_validate.py) → HARD / WARN / INFO

## D · Assemble & ship — [ASSEMBLER.md](ASSEMBLER.md)
manifest (stack of `{block-ID, fill}`) → [assembler.py](assembler.py) (resolve by ID · mint run-unique uid · fill holes · allocate WA indices)
&nbsp;&nbsp;→ import string.  **PROVEN:** block losslessness 238/238 · whole-aura round-trip 59/59 · encode→decode ✓

## E · Blocks & meaning — [BLOCK_SYSTEM.md](BLOCK_SYSTEM.md)
corpus → [aura_blocks.py](aura_blocks.py) → `native_blocks.json` (Layer-0 vocabulary) → [blocks_db.py](blocks_db.py) → `blocks.db` (parts catalog: block-ID → code + holes)
&nbsp;&nbsp;→ *next:* BOM miner (mine recurring stacks → named patterns)

## F · Validate against WA itself — [WA_VALIDATION.md](WA_VALIDATION.md)
`.tools/lua51` (Lua 5.1.5) + real WA 5.21.2 source → [wa_lua_verify/](wa_lua_verify/) harnesses → WA `default()` schemas
&nbsp;&nbsp;→ [wa_validate.py](wa_validate.py) — our block fields vs WA's fields ("expected vs other")

---

## Discarded
`Template_shadow.py` — deprecated v1 scaffold. Nothing reads it. Do **not** re-source from it.

## Open threads (`!build`-gated)
1. Re-emit resource layers to **scheme A** (clears validator drift + 3→2 divider over-budget).
2. Regenerate `ELEMENT_INVENTORY.md` **from** `mask.json` (closes prose drift).
3. **Class inventory → manifest** (the front-end that feeds D; forces the generative joining layer).
4. **BOM mining** (populate `bom`/`bom_block`).
5. **wago.io ingestion** (bigger training set → sharper library + patterns).
6. **Trigger-schema harness** (`Prototypes.lua`) — extend F beyond region/subregion.
7. Reconcile the old docs (`ELEMENT_INVENTORY.md`, `Docs/PIPELINE.md`, `AGENT_ROLES.md`, READMEs) — they still describe the discarded pipeline.
