# Addons_load — the addons agent's mental-load ledger

_What I'm carrying between sessions that no other file owns: open threads, banked refinements,
small debts, and walls-with-context. STATE.md says where the machine is; this says what's on my
mind. Pruned when items resolve — an empty section is a healthy section. Est. 2026-07-15._

## Open threads (each has a designed next step)

- **🐞 BUG HUNT ITEM (2026-07-17, live error, recorded per Battlewrath):** the NATIVE tank-border
  branch we lit up has a LATENT FORK BUG — `CompactUnitFrame.lua:816` (inside UpdateHealthBorder,
  the branch that only runs when BOTH tank border colors are armed + grouped) throws
  `Usage: UnitDetailedThreatSituation("unit"[,"mob"])` with locals ("player","nameplate11").
  We are the FIRST users of this dormant path — Ascension never play-tested it. Hypotheses:
  (a) stale/mid-recycle nameplate token rejected by the C export, (b) the backported C fn doesn't
  accept nameplate units. NEXT SESSION: check whether it's transient (rare error) or systematic
  (every grouped pull); if systematic → keep the Aggro borders branch DISARMED (arm only ONE color
  slot so line 815's AND-gate stays false) and route borders through the parked hand-rolled glow
  instead; the highlight-hide steering is unaffected (different function).

- **🐞 OPEN BUG (2026-07-17, post-v3.7.0 live): ENEMY plates being suppressed.** Suppression is
  Friendly-module machinery (ns.SetSuppressed, friendly PLAYERS only) — an enemy plate showing it
  means either (a) pooled-plate reuse: a previously-suppressed friendly plate handed to an enemy
  without restore (the SANITATION FIX lane — check whether v3.7.0's gates broke a restore path),
  (b) the dual-announce alias (target token) confusing classification, or (c) the v3.7.0 python
  block-replacement in FriendlyPlates.lua having clipped a non-panel line (diff v3.6.1→v3.7.0
  FriendlyPlates carefully).
  **PRIME SUSPECT (Battlewrath's live evidence: recycle-correlated + one enemy showing the NATIVE
  friendly-player BLUE 0.667/0.667/1.0):** the delta-guard CACHE DESYNC — our direct
  SetStatusBarColor paints never update the native cache fields (healthBar.r/g/b,
  UpdateHealthColor:576), so on pool recycle the guard believes its color is already painted and
  SKIPS the repaint, stranding the previous occupant's visuals on the new unit. FIX SHAPE: stop
  direct-painting entirely in SetHealthBarColor/ClearHealthBarColor — the override + RefreshPlateColor
  paints THROUGH native (cache stays honest); keep direct only for no-UnitFrame fallback and sync
  healthBar.r/g/b there. Suppression symptom likely same family (alpha state on recycled frame). Diagnostics on board: /coasp log on + filter suppress ·
  /coagp status (suppressed count) · /coagp diag (restore log). NEXT SESSION: read the v3.7.0
  FriendlyPlates diff BEFORE theorizing.

- **★ THE NEXT TWO SLICES (Battlewrath, 2026-07-17, post-v3.7.0 live drive — "more stable"):**
  Guardian and friendly-player are still COUPLED in the Friendly module; decouple into:
  1. **Guardian slice** — ownership-resolved: CLEU SPELL_SUMMON registry (sourceGUID=player) →
     match summon GUIDs to plate GUIDs → show /OUR/ pets only ("always the intent"). This is
     `corpus/patterns/guardian-health-tracker.md`'s registry primitive coming home to the addon
     side. Satellite: COA_StatePlates_Guardian.
  2. **Friendly-NPC lane** — satellite COA_StatePlates_NPC: show health bars · bar/name color
     edits · show-bar-when-carrying-Ascension-plate-TAGS (quest giver or not — the native driver's
     own questIcon machinery = the per-plate tag read; CompactUnitFrame setup carries frame.questIcon)
     → "health bar filters attention."
  Model: same two-file satellites on the inert core; Friendly module sheds both concerns.

- **Guardian-tracker POC LIVE-PROVEN + shipped to Discord (2026-07-15 evening)** — the custom TSU
  scaffold (GUID registry from `CLEU:SPELL_SUMMON` sourceGUID=player → resolve to plate tokens →
  static-progress states, clones): four 527-hp Greater Skeletal Warrior bars live, import string
  handed to Snackz. Battlewrath hand-built from the design card; source anchors GenericTrigger.lua
  :1807 (CLEU: filter) / :1331 (nameplate group expand) / BuffTrigger2.lua:3606 (3.3.5 CLEU layout).
  **STATUS: HANDED OFF — closed on our side.** Battlewrath's call (2026-07-15): this is Snackz's
  project; we gave them the key, we don't take it over. The "more abstraction" layer (login
  backfill, off-plate policy) is THEIRS to build — do not re-open it as bench work unless asked.
  What stays OURS: DONE — captured (`export_20260715_202335_01`) + catalogued
  (`corpus/patterns/guardian-health-tracker.md`: code verbatim, repeatable steps, source anchors,
  the plate-population boundary, limits, generalization — the registry = the reusable OWNERSHIP
  primitive for every summoning class). Evidence pair: records 20260715_195725/195846.

- **Clean-profile census re-run** — the runtime record was captured with user addons loaded, so
  `runtime/globals.json`'s 1526 "unattributed" functions = engine-custom ∪ user-addon mixture.
  One re-run with addons disabled at character select (same `/coadump r census`) splits it; the
  reducer already handles a second record (newest wins, runId-anchored). Cheap, high-value.
- **`C_CoA` / `C_ChallengeMode` / `C_RealmMerge`** — attested in shipped code, absent from the
  logged-in runtime. Hypothesis: glue-context (character select / login) or realm-gated. Probe:
  run census (or a tiny probe) while at the glue screen is NOT possible (addon code doesn't run
  there) → next best: grep their call sites in the extraction for context, or accept as
  glue-side. Not blocking anything.
- **The events census has no runtime witness** — events aren't `_G` entries; the declared pass
  (registered + compared + custom-prefix strings) is the only current source. A future
  `st`-mode event-sniffer task (RegisterAllEvents collector on the v2 spine) would add the
  fired-in-practice witness. Design exists in the collector library; build when a consumer asks.
- **Content-JSON reconciliation** (`Data\Content\CharacterAdvancementData.json` +
  `SpellRankData.json` vs `coa_spells.json`) — a candidate third witness for the ability
  inventory + the dev's own rank-family table. DISCUSS-FIRST (grain questions: Realms bitmask
  semantics, CA-entry ≠ castable-ability). Flagged in STATE 2026-07-15.

## For the aura bench (relay when their custom lane develops)

- **Custom-code performance discipline** (Battlewrath, 2026-07-15, from the guardian-tracker
  profiling: naive ~14× vs targeted in plate-dense areas): TSU handlers should dispatch off the
  event's own args (unit events name their unit), set `changed` only on real deltas, early-exit
  on empty state, and full-rescan only on STATUS. The as-captured pattern snippet = demonstrator,
  not adoptable form. A palette/ingredients note when custom.md grows.
  Rider (Battlewrath, Discord close): the gap policy for plate-bound trackers = **TTL +
  update-on-refind** (state survives a plate drop with a decay clock, refreshes when the GUID
  resolves again) — steadier UI than hide-on-gap, cheaper than a CLEU estimator.

## Small debts (cheap, non-blocking)

- **The tooltip merge gear** (post-capture, 2026-07-17): fold the rendered lines from
  `20260717_042514_616__tooltip.json` into the inventory text for the 119 hole ids
  (`maps/tooltip_holes.json` = the join). Small offline tool; the render is the arbiter,
  accept-empty on the game's verdict. Coordinate the landing spot with the aura bench
  (inventory out/ is their data).

- ~~`frames` task wants a field list~~ — BUILT + deployed v2.1.0 (2026-07-15): `frames
  [fields]` reads the walker's field list off every hit (`displayedUnit` added to defaults);
  anonymous hits keep a `table:` addr. Smoke-green; LIVE CONFIRM = the guardian-plate
  mouseover re-run (unit token expected in the record).

- ~~GuardianPlates client copy one deploy behind~~ — RESOLVED 2026-07-15: Battlewrath deployed
  to parity; check-mode confirms both residents zero-delta.
- **5 files failed extraction from patch-B** (named in `Outputs/client_interface/patch-B/
  manifest.json`: GlueXML RaceSelect/SoundOptionsFrame + SharedXML AnimationTemplates —
  read_file returned None, likely a compression variant). Glue screens, census-marginal.
  Revisit only if a question lands exactly there.
- **8 tiny MPQ archives are unlistable** (no internal listfile: patch-4/5/C/CZZ/P/W/WB/WC).
  Almost certainly art overrides. Ladik's MPQ Editor on Battlewrath's machine is the named
  fallback if one ever matters.
- **The census smoke harness lives in the session scratchpad** (smoke_devdump.lua /
  smoke_census.lua) — regenerable but not in the repo. If regression-testing the spine becomes
  routine, promote them to `addons/tools/tests/`.

## Standing cautions (so they don't get re-learned)

- **Two agent sessions share ONE trunk** (addons + aura benches, same repo, same main). Diagnosed
  2026-07-15 after a scare: the picker session's close replayed its chain on top of mine mid-evening —
  benign (nothing lost; rev-list proved 0 missing), but the interleave was luck. Discipline: `git log
  --oneline -3` BEFORE each commit (see whose tip you're on), and diagnose-before-repair on any odd
  push range — the trunk moving under you looks exactly like history loss until you count.
  Calibration (Battlewrath): parallel sessions are the EXCEPTION, not his practice (one focus,
  chase it out, settle) — this is a rare-condition check, not a per-commit ritual.
  MECHANISM (2026-07-15): **`operations/HELM.md`** — the trunk LOCK. Read before first commit;
  another bench's name = locked out; RELEASE at close-off. Supersedes tip-glancing as the guard.

- **One envelope at a time is load-bearing:** the census task's Begin→(cycle)→Commit spans
  ~seconds; another `r`/`st` during the cycle would clobber the open envelope. The dispatcher
  guards sessions but NOT an in-flight cycler. Acceptable at current scale; a `D.busy` flag is
  the fix if it ever bites.
- **Lua errors do not reach disk** (`Logs\LUA.txt` = load milestones only; live-tested).
  In-game error dialogs must be reported by hand. An error-catcher hook (seterrorhandler →
  mailbox) is a possible future task — weigh against the anti-cheat restart cost.
- **`.gitignore` patterns want anchors** — the unanchored `runtime/` rule silently swallowed
  `addons/maps/census/runtime/` (fixed `b66d1da`). When adding ignore rules, anchor to root
  (`/x/`) unless multi-level matching is the actual intent.
- **The Cowork-era "mpyq can't read these MPQs" claim is false locally** — only the 8
  listfile-less archives fail. Don't re-inherit that wall from old notes.

## The lane (Battlewrath, 2026-07-15)

**Addons = the mechanical game relation** (client surface, capture tooling, evidence, source facts).
**Auras = the WA bridge** (patterns, corpus, dockets, adoption). Either can step into the other, but
it's a lane: hand off ACROSS it, don't do the other bench's documentation. Caught live: the
guardian-tracker pattern write-up was aura-lane work done from this bench — kept this once
(`corpus/patterns/guardian-health-tracker.md`, flagged as addons-authored draft for the aura bench
to tighten/own); future = hand off the snippet + facts, let auras document.

## The seat (how this bench runs — one line each)

Repo = truth; deploy.py byte-copies (game closed; new code = full restart). SV = one-envelope
mailbox; watcher lands records runId-deduped. Tasks are bounded units on the v2 spine, steered
by args, self-cycling, by-exception chat. Census tables answer "what does the client offer" —
contracts drag their areas out by citation, never by re-derivation.
