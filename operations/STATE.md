# STATE — where the machine is

_Last updated 2026-07-16 (the picker V1 session). The single "where are we" read. Detail lives in the code + READMEs this points at._

## Aura bench 2026-07-16 — THE PICKER V1: BUILT, LIVE-GRADED, IN THE DEVS' HANDS

- **The whole runway ran in ~a day** (`creator/picker/` — spec `picker_tree.md`, runway `picker_build.md`, all
  phases stamped in place): Phase 1 JS codec port (126/126 decode-equivalent incl. all 115 real packs) · Phase 0
  library emit (5.9MB byte-idempotent; 21 classes / **70 real specs** dev-tree-adjudicated + triple-witnessed;
  7 builder→live class renames solved by spellId majority join; 3 ghost trees marked; Class/General pseudo-trees
  folded into spec shelves) · Phase 2 templates pressed + LIVE-stamped (3 lanes; persist fragment live-corrected:
  `buffed` not `show` under showAlways — findings #11-13) · Phase 3 shell built + browser-driven · Phase 4
  machine-side CLEAN (mint harness decode-diff; browser-minted string decoded by the trusted decoder).
- **Live grading (Battlewrath):** paste landed perfectly; library face refined on his walk (edges render from
  what they carry — the 8,916 no-dst applies_aura flood; chain back-stepping + return-to-selection; General tile
  dropped); the everything-ticked wizard collapse fixed (no mid-render redirects). **Prototype handed to the
  devs.** Method banked: user-story walks prove the JOINS where harnesses prove parts (memory).
- **NEXT (after a mental degauss):** the **cooldown+usable lane — abilities and cooldown are ONE bucket**
  (the Ready contract: spell-trigger palette + liveness harvest first; both Q4 costumes + desat polarity
  pre-specified in the tree). Then **procs as their own bucket**; down the line procs refine into the
  "And what?" stage as an injected TRIGGER 2 on the consumer (not their own aura). All refinement, no invention.
- Charter note: the inter-bench division locked in HOW.md (addons = Lua→WoW + custom code; aura bench =
  Lua→WA→WoW + repeatability/design/taste/dockets; no court, bounded conversations).

## Addons bench 2026-07-15 (the dedicated addons agent's first build session)

- **✅ LIVE-PROVEN 2026-07-15 19:04 (Battlewrath, one pass, zero fixes):** deploy `all` → restart → `/coadump r
  frames` → `/reload` → the watcher landed `20260715_190433_704__frames.json` in 1s (envelope complete, header
  stamped NECROMANCER/Gravekeeper, real frame stack in the payload). Battlewrath: "Pipeline proven. And a clear
  improvement over past pipeline." Rider settled: Lua errors do NOT reach `Logs\LUA.txt` (load milestones only).
- **The bench loop MECHANIZED end to end** (headless-green; live proof costs one client restart):
  `addons/menu.bat` (the pinned keys-only bench terminal — hosts the watcher, steers deploys/pulls/git)
  · `addons/deploy.py` (repo→client dispatcher: manifest, byte-copy, stray cleanup, by-exception receipt)
  · `addons/landing/pull.py` (client→repo: verbatim raw clone gitignored + parsed record tracked, runId-deduped,
  `watch` = leave-it-running) · **COA_DevDump v2** (task-registry spine: core.lua + task files, ONE-envelope
  mailbox SV, by-exception chat, shorthand `r/st/sp/list/clear`; v1 campaign tool retired to git history;
  offline smoke test green under lua51 stubs). First tasks: `probe` + `frames` (v1 patterns rebuilt).
- **Design law recorded (Battlewrath):** bounded tasks against a self-descriptive-but-limited spine; shorthand
  for session-driven verbs (`st`/`sp`); tasks self-cycle with their own event listeners (no watching a 300-line
  chat window); SV = concise mailbox (latest run only — history lives in the repo landing zone).
- **Real catch on the way through:** the Cowork doc pass had appended a literal `</content>` line to the repo's
  GuardianPlates `Core.lua` + `.toc` (a paste artifact — a Lua syntax error had it ever deployed). Stripped,
  verified byte-equal to live otherwise (repo carries one 7-char doc polish live doesn't have yet). deploy.py's
  read-only check mode caught it on its first run.
- **Anti-cheat constraint on record** (from the Materials fact-sheet, now baked into bench.md + the tooling):
  new/edited addon CODE needs a FULL client restart — /reload only flushes data. Tasks are installed once and
  steered by arguments, never edited between passes.
- **THE FIRST GOAL'S DECLARED PASS: EMITTED (`3e9653c`) — `addons/maps/census/`** (the sheets model on the whole
  client): 88 C_* namespaces / 1028 attested members with file:line sightings · 736 events (213 custom REGISTERED =
  the candidate aura-trigger vocabulary) · 3578 UI functions · baseline.json = stock 3.3.5 run out of the client's
  own APIDocumentation addon (2081 fn / 592 ev). Anchored to patch-B.MPQ sha256. Grain: ATTESTED USAGE — the runtime
  census task is the completeness check. Source: patch-B.MPQ = ALL client code (extract_interface.py; CompactUnitFrame
  now readable; the Cowork mpyq wall doesn't hold locally).
- **★ THE FIRST GOAL DELIVERED same evening (`a5518bd`+`b66d1da`): the RUNTIME census landed + the three-witness
  reduction emitted** — `/coadump r census` walked 51,855 globals (6282 fn / 29,777 widgets / **91 C_* namespaces**)
  in one cycled pass; `reduce_census.py` joined RUNTIME × DECLARED × BASELINE → `maps/census/runtime/`: **1003
  attested / 284 RUNTIME-ONLY members** (real API, zero shipped call sites — C_MysticEnchant 35, C_GMTicket 24, whole
  namespaces C_CollectorCache · C_LoyaltyPass) / 18 declared-only + 3 declared-only namespaces (C_ChallengeMode ·
  **C_CoA** · C_RealmMerge). Flat functions bucketed 2058 stock / 2698 shipped-ui / 1526 unattributed (user addons
  were loaded — a CLEAN-PROFILE re-run splits engine-custom from user-addon; cheap, banked). Gitignore catch: the
  unanchored `runtime/` rule swallowed the reduction dir — anchored to `/runtime/`.
- **NEXT here:** contracts drag their areas from the census (spec capture first: ASCENSION_CA_SPECIALIZATION_ACTIVE_ID_CHANGED
  + C_ClassInfo/C_CharacterAdvancement rows) · the clean-profile census re-run · the Content-JSON reconciliation
  (discussed-first) · Battlewrath: git push (the day is local-only).
- **FIND (Battlewrath pointed at the client root): `Data\Content\*.json` — loose dev-authored custom game data,
  plain JSON, no MPQ extraction.** `CharacterAdvancementData.json` (7MB: class→ability entries, ALL 21 COA classes
  under dev tokens + Reborn* stock, 44 Class values, Realms bitmask) · `SpellRankData.json` (the rank-family table:
  firstSpellId/level/rank/spellId) · `SpellToSpellSuggestionData.json` + siblings (11MB relationship graphs) ·
  SkillCard/TradeSkill/etc. A potential NEW WITNESS for the ability inventory (vs Input talents + DBC∩scrape) and a
  direct source for rank policy. Recorded in addons/bench.md fact basis; NOT yet cross-validated against
  coa_spells.json — that reconciliation is a bench-mission candidate, discuss before building.

## Morning 2026-07-15 (on top of the session close below)

- **MULTIDOT DISCOVERED LIVE (Battlewrath, in-game):** aura2 `unit:"multi"` works built-in on the fork (CLEU-driven —
  `BuffTrigger2.lua:3671`; no nameplate units needed). One aurabar + one id per DOT family in `auranames` + `showClones`,
  in a `sort: ascending` dynamicgroup = the ambient multi-dot tracker (top bar = next dot to fall). Captured through the
  corpus's own intake (export → stub → CLEAN closure) — **`corpus/patterns/multidot-tracker.md`** is the versioned
  template (his live config verbatim; taste layer credited). `group_count` = REQUIRED multi kit, operator **`>= 1`**
  (the export's `<=` was an authoring slip the stub→grading loop caught pre-live; his in-game copy owes the flip).
  The buckets.md "least-verified" caveat SUPERSEDED. Destined: a per-class multidot contract (dot lists already
  computed by the batch select) + a picker scaffold shelf item.
- **PICKER V1 SETTLED** (roadmap): ONE portable .html carrying the runtime exporter — pre-bounced tables + JS codec
  (conformance-gated vs the python codec), **part-pick → one group string**, shelves = singles (class:spec slicing) +
  scaffolds (patterns as units), assembly stays in-game, dumb type-to-type. **The agreed next build** (easy pace).
- **Two press-ready builds on the bench:** the picker · the per-class multidot contract.
- **The `addons/` BENCH established + populated (2026-07-15):** root sibling for the dedicated addons agent —
  charter/invariants/bench/backlog (the handoff kit) + the residents moved in (COA_DevDump · COA_GuardianPlates with
  `deploy_to_game.bat` = the deploy pattern: repo = source of truth, byte-copy to the game, agents never write the
  client folder · Mob_Autogroup · refs_threat). **FIRST GOAL: the client-surface census** (probe _G + stock-3.3.5
  baseline diff + source-grep → unique tables of every custom lever/API; the spec capture and WA-env harvest are rows
  of it). The agent boots on `addons/invariants.md`.

## Session close (the day's final state — everything below it stands)

- **THE PRODUCTION RUN:** `batch_press.py` pressed the Target tracker across the whole game — **110 packs · 427 member
  auras · 578 staged 0 blocked · 0 failures**. `Docket_complete/` = the product catalog. 5 honest zero-specs noted
  (pet/healer profiles — Self-tracker/friendly-select territory).
- **The corpus fired:** `corpus/planning/stub.py` (the reverse gear) — **35/36 closures** on Battlewrath's own Necro pack
  (residue LEDGER quantifies UI type-switch leftovers; 1 failure = the open press-path `\`-escape bug, findings #8).
  First two **patterns/** entries: minion-count-tracker (candidate primitive, the exact-id policy exception) ·
  backing-pair (workaround-lead, prune criteria). Selection law + **invariant 7** (versioned source backing) locked.
- **Validation triangle** (`description_report.py`: mine/rows/agree): select × description-words × effect-mechanics.
  After lexicon iteration 1: **AGREE 175 · MECH? 76 · DESC? 62 · ?? 114** (the ?? = custom AURA codes). Aura-code
  gravity mapped then **corrected by family-dedupe** (grain is a claim): big-four = engine codes (Self-slice concern);
  338 = a 4-class shared bleed. **Probe shortlist ready:** Greater Devotion of Radiance 575045 · Aspect of the
  Huntress 805356 · Bane of Fire 707901 · Soulrend 572341 · Stormflow 567555.
- **The custom backlog WORKS:** two Discord requests → **live-confirmed packs in minutes each**
  (cultist-godblade-voidseeker: the PowerAuras proc swirl, corpus resolved the player's whole description;
  prophet-fortitude-exposedflesh: stack bands + max alarm). Third exact-id case = a STANDING PATTERN (shared-name
  variants; exact-id is the norm for proc/mechanic buffs). `spellknown` load gate live-proven.
- **The seats named:** taste/feel/subtlety = Battlewrath's; computational logic/composition = Claude's. Attention
  intensity (calm/warn/alarm) = a future taste dial in the palette.
- **Awaiting:** dev reply (DOT/HOT register = potential third→fourth witness; Discord pinning = distribution) ·
  spec-name capture (20 entries → `load.specialization`) · Battlewrath's aura-code DB probes.

## Late-evening additions (after the derived-gears restore point below)

- **Everything below LANDED and was LIVE-PROVEN** (see roadmap ✅s): five packs imported clean; the dry-run battery
  (green ×4 · red 7/7); Battlewrath's independent pickup byte-identical; three live fixes (select-stores-KEY gate rule ·
  `subRegions` always-present · V17); **the round trip verified LOSSLESS** (client adds only its own furniture —
  custody's central claim proven from the client's mouth).
- **`creator/verification/`** — the instrument set: `coverage.py` (36-member pressure test) · `roundtrip_diff.py` **with
  memory** (`known_deltas.json` — 768 deltas → 19 recognized lines → CLEAN; judgment appends, recognition mechanical) ·
  `findings.md` (all dispositioned).
- **`creator/ingredients/`** — the agent menu complete: the aura's full anatomy (trigger/display+3 regions/load/
  conditions/custom), the blank docket, the custody chain.
- **`corpus/` at root** (sibling of creator/operations; engine joins when we uproot): refinement stages
  intake→raw→dockets→patterns + planning. Goal: **noise → signal**. Selection: unique-lead or anti-common, not
  precious, primitive-or-perish. First occupant queued: **the stub tool** (aura → docket, closure-loop parity proof).
- **The terminology bridge** (HOW.md): block era → now (blocks→patterns · inventory→a class's contracts in
  `creator/<class>/` hives · mask unchanged + sharpened as the human-feel stabilizer, foldable into contracts).
- **Expected flatten:** the corpus exercise should flatten the spell-index/table work — the settled maps
  (condition_vars · trigger_args · signals) already hold answers those tables were waiting on.

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
