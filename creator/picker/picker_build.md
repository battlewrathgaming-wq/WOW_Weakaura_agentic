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
- **STATUS: ✔ DONE (2026-07-15, same evening as Phase 1).** `emit_library.py` → `out/library.json`,
  **5.9 MB, byte-idempotent across runs** (no wall-clock in the output). Receipt: **21 classes · 115 specs ·
  3,612 cards · 9,407 chain spells (270 gap rows, carried AS gaps) · 505 shelf families.** One discovery paid
  mechanically: the builder renamed 7 classes vs the live DB (bloodmage→SONOFARUGAL, felsworn→DEMONHUNTER,
  knight_of_xoroth→FLESHWARDEN, primalist→WILDWALKER, runemaster→SPIRITMAGE, templar→MONK, venomancer→PROPHET) —
  matched by a **spellId majority join** (unanimous 7/7), which is now the emit's PRIMARY matching mechanism
  (no alias table, no name normalization; self-heals future renames). The shelf select reuses
  `pull_target_tracker.families()` — the press's own recipe exposed as data (one source of truth).
  One honest warning standing: NECROMANCER/General has no caption row (caption=null).

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
- **STATUS: ✔ DONE (2026-07-15, first firing).** `codec/wa_encode.mjs` + `codec/harness.py` —
  **126/126 decode-equivalent**: 11 synthetic edge classes (multiline custom code · string refs · unicode ·
  12-bit boundaries · wide ints · both float paths · empty-table {}=[] class, normalized as the round-trip
  verifier registers it · `__luaMap__` int-keyed maps) + **all 115 real Docket_complete packs including
  verification-coverage** (the 36-member packet). The browser `CompressionStream('deflate-raw')` path separately
  verified decode-equivalent. The one design seam found early: JSON can't carry Lua int keys — solved by the
  `__luaMap__` convention (assemble.py:129's int-key normalization mirrored).

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
- **STATUS: ✔ DONE — LIVE-STAMPED (2026-07-16, Battlewrath's grading).** All 3 lanes imported, **no
  malformation**: pet "works as created" · dot_multi clean (its corpus uid matched Battlewrath's original →
  the known-copy prompt — live proof the fork uid-matches, validating one-time minting; findings #13) ·
  dot_target appear clean · **persist logic corrected live** (findings #12: `show==0` is dead under showAlways;
  the variable is `buffed` — fragment fixed at the true layer, re-pressed, matches the capture byte-for-byte).
  The desat POLARITY law recorded in the tree (aura: desat=press-me · cooldown: desat=can't-press).
- (pressed 2026-07-15:) `press_templates.py` → `out/templates.json`
  (3 lanes, 4 member templates, 12 KB): dot_target group+appear+persist (icon; persist = matchesShowOn
  showAlways + the corpus-proven show==0→desaturate condition, both fragments verified in the pressed forms) ·
  dot_multi group+member (aurabar, the closed corpus dockets) · pet group+member (guardian scaffold, custom Lua
  verbatim — 1,254 chars intact through the press). Every docket GATED (only by-design soft "unchecked" flags),
  every table through expand→fill→bounce (canon inside). dot_target's reference = the contract's own populate
  press (Blight; _authored left as found via snapshot-diff). **`make_live_check.py` minted the three
  hand-import strings → `out/live_check/*.txt`** — the runway's one planned pause: Battlewrath imports each
  in the live client (import clean · display right · test events safe) before Phase 3 builds on them.

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
- **The mint's envelope (pinned 2026-07-15 off a decoded live-check pack):**
  `{m:"d", d: group-table (controlledChildren=[member ids]), c: [member tables - NO parent key; WA rebuilds
  child wiring from the c list on import], v: 1421, s: version-string}` — mirror bundle exactly.
- **Build assembly:** `build_picker.py` injects library.json + templates.json + the JS into the shell template →
  `picker.html`, provenance-stamped (build date + source commit in the footer). The HTML is a BUILD PRODUCT —
  never hand-edited (pipeline law; fix the gear, re-emit).
- **DONE =** picker.html walks all six questions for DoTs(both scopes)+pets and mints strings; library face
  browses all 21 classes.
- **STATUS: ✔ BUILT + BROWSER-DRIVEN (2026-07-16).** `shell/` (mint.js pure-function mint · app.js wizard+library
  · style.css text-only · the template) + `build_picker.py` → **out/picker.html, 6.0 MB, one file,
  provenance-stamped in the footer.** Driven end-to-end in a real browser: class→spec→lane→scope→picks(9
  trackable, exclusions listed)→behaviour→closer→mint. The browser's own string (CompressionStream path)
  decoded by the trusted decoder: seat-named group, per-family rep-ids, the live-corrected persist form on
  every member, fresh unique uids, the pinned envelope, load transform exact.

## Phase 4 — the stamp

- Cross-validation: for each lane, same picks pressed via the machine AND minted via picker.html → decode both →
  table-diff CLEAN.
- **Live import** (Battlewrath): one minted string per lane into the real client — import clean, display right,
  test events safe (the subRegions class of bug is exactly what this catches).
- Grading pass, findings filed in `creator/verification/findings.md` — the picker joins the same loop as
  everything else.
- **DONE =** three lanes live-stamped. V1 exists. Distribution = the Discord sentence + the file.
- **STATUS: ◐ machine-side DONE (2026-07-16), live half = Battlewrath's.** `mint_harness.py`: the shell's mint
  vs the machine on identical picks → **decode-diff CLEAN** (dot_target + pet; dot_multi's two transforms are
  the same slot mechanics dot_target proved). The browser-minted string separately decode-verified. REMAINING:
  import a picker-minted string in the live client (the templates behind it are already live-stamped, so this
  checks the mint's fills, not the structure) + eyeball the library face.

## Phase 5 — doors light up (post-V1, not this runway)

Ready contract → cooldown lanes (queue + dim-grid costumes already specified) · Self contract → procs/stacks ·
select recipes (HoT mirror · behaviour-drivers · stacks) · resource bars. Each lands as: press the contract →
add its templates → re-run the emit + build. **The shell does not change** — that's the test of Phase 3 done right.

**"And what?" (Battlewrath, 2026-07-16 — parked until V1 is stable and shipped):** the chains feed the wizard.
When a picked spell HAS a chain (a triggers/applies_aura edge), the wizard offers one more preformed question —
*"Show me when it procs?"* — adding a trigger 2 + condition in the proven shape (pull, not push: the consumer
reads the proc's native buff window; the corpus proc-pair pattern as a wizard step). The library's knowledge
becoming the wizard's next question — the two faces of the file meeting. Needs the trigger-2/condition fragment
pressed + the edge→offer select; no shell redesign (it's one more pruned screen).

## Order & runway

1. **Phase 1 first** (the only piece with real unknown-unknowns; everything else is proven motion) — Phase 0
   alongside whenever convenient.
2. Phase 2 next (small; the live template check is the one mid-build pause needing Battlewrath in-game).
3. Phase 3 once 0+1+2 stand. 4 stamps it.
4. Compiler-change law: these are NEW gears (emit_library, the JS, build_picker) — no existing compiler files
   touched; if a wall forces a change to fill/gate/codec, the 4-step checklist + "Go" applies as always.
