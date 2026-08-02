# Addons_load — the addons agent's mental-load ledger

_What I'm carrying between sessions that no other file owns: open threads, banked refinements,
small debts, and walls-with-context. STATE.md says where the machine is; this says what's on my
mind. Pruned when items resolve — an empty section is a healthy section. Est. 2026-07-15._

## Investigation (2026-08-01): the PvE/PvP Power login bug - client-side readout IMPOSSIBLE

Community bug (~30% damage loss on login for many specs; fix = a mode-switch/naked/die/quit
ritual). Traced the full client surface w/ Battlewrath:
- Server applies power as AURA MACHINERY: 'PvE Power (+0..+99)' ids 101600-101699, PvP
  101700-101799 (+993xxxx variants), 'PvE Mode' 9931032 / 'War Mode (PvP)' 84420 as mode
  auras. Mode aura VISIBLE in UnitAura; power auras FULLY SUPPRESSED - not in UnitAura, not
  in CLEU even on a forced mid-session equip re-apply (tested live, silent).
- The character sheet FABRICATES its display: PaperDollFrame_SetPvEPower shows
  UnitPvEPower = client gear-sum; tooltip %s derived from the same sum x local constants.
  Nothing queries applied state -> the desync is invisible BY CONSTRUCTION.
- Detection BOUNDARY: behavioral class only (output vs known-healthy baseline). Any
  tooling there = UNGATED and rests on an unverified premise (multiplier CLEU-visibility -
  one bugged-vs-fixed A/B settles it). Expanding the Mancer/Ledger line to player damage =
  a product-scope decision NOT yet worked (Battlewrath flagged the inventive creep of
  proposing it inside findings).
- DEV REPORT PACKAGE (sharp): fix the apply path; EXPOSE applied power (unhide aura or API)
  = the structural fix players can verify; + found in passing: UnitPvEPower caps PvE by
  PVP_POWER_CAP (UnitUtil.lua copy-paste bug).

## Client-surface finding (2026-08-01, CORRECTED same day - Battlewrath's catch):
## Bartender form paging works natively; the trap is TARGET PAGE NUMBERS

Custom CoA forms work END-TO-END in the paging stack: SpellShapeshiftForm.dbc carries the
OWN-BAR flag (0x1) on most CoA forms (Rotweaver/Vizier/Lich CoA/Cursed/Draconic/Mechsuit/
Elude/Formations...), GetShapeshiftForm()/GetBonusBarOffset() report correctly, entering a
form fires UPDATE_SHAPESHIFT_FORM + UPDATE_BONUS_ACTIONBAR, secure state drivers WAKE, and
[form:N]/[bonusbar:N] conditionals evaluate. **THE TRAP: the right-hand values in a paging
string are ACTION PAGES, valid 1-11 only (11 = the vehicle/possess page, pairing with
[bonusbar:5]). Page 12+ = a SILENT no-op that perfectly imitates driver deafness** - I
banked a false 'forms don't wake drivers' finding off it; the two stacked unknowns
(wake? target?) resolved when Battlewrath questioned the target number. Lesson instance of
[[pipeline-emits-class-knowledge-curates]] + one-variable-at-a-time.
His working pattern: forms share page 8 (populated per spec); probe kit for future form
oddities: /dump GetShapeshiftForm(),GetBonusBarOffset() · SecureCmdOptionParse(specifics
FIRST - first match wins) · the 5-event listener one-liner.
FINAL STRING (validated): `[bonusbar:5]11;[mod:shift]10;[stealth]7;[form:1/2/3/4]8;1` -
priority stack modal > modifier > stealth > OWN forms (whitelist) > home floor. Two late
lessons: (a) the trailing unconditional value IS the else-branch - without it, no-match
emits nothing and the bar goes stale; (b) EXTERNAL morphs set real form-state (Stratholme
fear -> Ghoul form id 7, DBC-flagged OWN-BAR) - bare [form] greedily captures them, the
1-4 whitelist + floor ignores them. Possession rides bonusbar:5 (same page as vehicles).

## Bench capability (2026-08-01): MPQ + DBC reading (client data manifests)

mpyq (already in the toolchain via extract_interface.py) reads ANY client MPQ + its DBC
files directly - proven by the Undead-Venomancer diagnosis: CharBaseInfo.dbc (the client's
LOCAL race x class manifest, single copy in patch-M) decoded in-place -> Venomancer(29,
'PROPHET') granted to races 4/8 only, Undead row MISSING -> create UI blocks client-side
(IsRaceClassValid) before the server allow can surface. Dev-side miss, relayed precisely.
Pattern: the client gates on SHIPPED manifests (DBC in the patch chain), not runtime checks
against the server - "is there a local manifest?" is now a mechanical yes-and-here-it-is.
Glue chain for create-gating: CharacterCreateUtil.IsRaceClassEnabledAndValid =
IsRaceClassValid(DBC) AND C_CharacterCreate.CanCreateClass (realm/account side).

## Bench capability (2026-07-31): the /combatlog disk witness

`/combatlog` toggles the client's own CLEU-to-disk stream -> `Logs\<datetime> WoWCombatLog.txt`
(addon-free, zero cost, ms timestamps, standard 3.3.5 CSV after a two-space split).
`Class_design/Necromancer/tests/parse_combatlog.py` parses it as-is (`parse_line` is the
reusable piece - proven by importing it against the bench's own questions). For any future
"does this fork emit X" question this is the CHEAPEST instrument on the bench: no capture
task, no deploy, no reload. First bench use: hunting the pet-UNIT_DIED answer (Battlewrath
deliberately exposing the capability - all prior testing was dummies).

## First scaling observation (2026-07-31, MancerLedger naked/geared A/B, Rates page)

Pet MISS% responds to owner gear - consistent across types with sample: Greater Skeletal
Warrior 10%->4% (-6pp), Decaying Colossus 9%->4% (-5pp), Lesser Zombie 0%->2% (noise-level).
Anchors: naked stam 102/int 108/shadowSP 68 vs geared 222/192/362. Evidence toward pet
hit-inheritance; Class_design's lane to pursue (lab pairs would pin WHICH stat). Lesser
Zombie cadence 33.3->64.9 EXPLAINED (Battlewrath, class knowledge): zombie per-unit rate
SCALES WITH PACK SIZE - the runs had 3 vs 18 summons; the cadence measured population, not
gear. Comparability caveat class discovered: POPULATION-DEPENDENT rates (zombie cadence
comparable only at matched counts) - a third axis beside fight-length and target-defense.
Data: his MancerLedger SV (naked/geaed profiles) + screenshots this session.

## Open threads (each has a designed next step)

- **OPPORTUNITY (Battlewrath, 2026-07-30): the PET COMBAT PARSER — inspect Libellus-Leti FIRST.**
  Target addon: https://github.com/ltgenzombie/Libellus-Leti/releases (full big-pane combat
  parser; silo-ingest per the SignalFire pattern — describe-don't-anchor; STARRED read = their
  CLEU pet/guardian ATTRIBUTION logic (the solved hard problem) + their accumulator data model +
  a perf read against our render-economics knowledge). OURS DIFFERS: micro pane (row per living
  pet, budgeted-worker discipline from birth) + THE HISTORY EXPORTER — 'what have ALL your aboms
  ever looked like': longitudinal per-entry-id database, repo-side via the landing lane (records,
  offline aggregation - no SV bloat; no addon on this client can match it because none has a
  landing zone).
  THE METRIC INVENTORY (designed, 4 capture classes): (A) registry = the guardian-tracker
  ownership primitive (SPELL_SUMMON GUID + entry-id + lifetime); (B) CLEU streams, GUID-keyed,
  plate-independent = damage done per-ability w/ crit flags, miss table, damage taken, healing
  received, casts, time-in-combat -> DPS/crit%/shares; (C) ★ PLATE-WINDOW STAT SNAPSHOTS -
  UnitAttackPower/UnitDamage/UnitAttackSpeed WORK on plate-bound pets: snapshot on
  NAME_PLATE_UNIT_ADDED for registered GUIDs PAIRED WITH OWNER STATS same-instant -> (owner
  stamina, pet AP) correlation rows = THE PET-SCALING LAB (feeds Class_design's Life-Force-slope
  question; scaling derived from data, not known); (D) boundary class - HP plate-window only,
  last-known + staleness off-plate. BOUNDARY (Battlewrath, 2026-07-30): the parser does NOT
  manage nameplate CVars (Libellus does; we explicitly do not adopt it - method 3 cross-check
  closed as REJECTED for us). Plate visibility belongs to the client + the user's nameplate
  addon (TurboPlates is now his baseline - feature-rich; State Plates coexists on the same
  driver). Plate-window snapshots are OPPORTUNISTIC: read plates as they come, never engineer
  the gate. 'Let lanes that work well carry load.' 
  DISPLAY SPEC (Battlewrath, 2026-07-30): Recount-like in-game micro grid where THE ROWS ARE
  PETS, each anchored on the ACTIVE GUID (individuals, not Libellus-style type buckets; row born
  at SPELL_SUMMON, closed at UNIT_DIED -> closed rows = the history exporter's archive feed).
  ROW SORT = a DYNAMIC WEIGHT function (Battlewrath: keep the row weight pluggable so different
  weight types feed in later - v1 weight = LIFE FORCE COST; future providers: souls economy,
  damage share, taste-defined). V1 semantics: investment order - expensive minions top, stable,
  no dancing rows;
  generalizes as summon-resource cost, but SCOPE (Battlewrath): V1 = NECROMANCER ONLY — the LF
  row-weight is Necro-specific; Reaper guardians = a later generalization with its own economy
  anchor; LF table from OUR basis, not Libellus's).
  COLUMNS: [Name (numbered twins)][HP bar (plate-window, dims stale)][Dmg][crit% (sample floor
  ~20 else '-')][miss% (the live hit-cap evidence)][Age (doubles as temp-minion TTL)][Taken].
  DPS = exporter-side analysis, not glance.
  BUILD PATH (house two-step): capture BEFORE display - a petlog session task on the v2 spine
  proves the metric set via landed envelopes + offline parse; the grid addon then displays a
  PROVEN column set (satellite model if it joins the State Plates family).
  ★ MANCER FINDINGS BANK -> addons/planning/mancer_findings.md (Battlewrath, 2026-07-31:
  'bank all the findings and the suggested fixes so we have them loaded'). Three findings
  HELD w/ evidence + fix shapes: (1) CVar three-lane corruption class [design]; (2) guardian
  suppression polling race [mechanical, the icebreaker; fix = OnShow hook]; (3) the hitching
  ATTRIBUTED [profiler-proven: Mancer 24ms/s steady + 48-108ms spikes, 8-for-8 trough
  alignment; MancerLedger 0.0ms = his 1.5s hunch acquitted]. ACTIVE HEADING: prove the
  LEDGER'S UTILITY first through ordinary play (profiles accumulating, a real regear compare)
  - engage carrying working software that embodies the principles (opt-in - the consumer/game
  source drives updates - dedupe). We advocate nothing we don't ship.
  SEQUENCE AGREED (2026-07-31): (1) Battlewrath captures the A/B - profile 'naked' 5min dummy
  (2-3 pulls, combat drops between) -> gear up -> profile 'geared' same fight same army ->
  compare = the show-piece + the scaling lab's first controlled observation (does pet miss%
  respond to owner gear?). (2) THEN I build the WINDOW against his real SV data (design
  settled: profiles list w/ name-box+New/Use/Delete, stats table, compare view w/ per-type
  ROW TRIPLETS A / signed-delta-middle / B, capture lines as frame; rates delta in
  percentage POINTS, dmg deltas keep the raw label; native Interface Options page; slash
  demoted to alias). Build gated on his data landing.
  ★★ DIRECTION PIVOT UNDER DISCUSSION (Battlewrath, 2026-07-31, leaning, not yet Build!-gated):
  COMPLETE REBUILD around Mancer (LtGenZombie's addon, the evolved Libellus) as the PRIMARY
  DRIVER, us as CONSUMER. Verified mechanism: fights auto-commit on PLAYER_REGEN_ENABLED into
  MancerDB.minionDps.fights, a 10-fight ring with dedup fingerprints (startedAt:endedAt:dmg) =
  a ready-made fold cursor; lazy lossless harvest. Architecture becomes: (1) Mancer = capture +
  per-fight review (theirs); (2) CONSUMER plugin (ours) = lifetime normals + STAT-EPOCH BUCKETS
  (buckets emerge from stat-stability periods, ±tolerance on stam/int/SP anchor, fold-time
  paper-doll read; 'how do pets look anchored stam vs int' = inspectable surface).
  ★ OFFER SPLIT (Battlewrath, 2026-07-31): the LONG-TERM AVERAGING is THE offer - it lands on
  LtGenZombie's own stated boundary ('just a per fight thing, not a life time') = easy sell,
  no treading. The compact COMBAT READOUT is NOT offered: TTL/HP is already solved (their
  MinionHpHud + WeakAuras) - offering it treads finished work, an offensive sell they'd be
  precious about. v0.2's grid stays PERSONAL tooling only. Our capture lane retires after a
  two-witness window (run both, diff counters). Consumer fails LOUD on 0.9.x shape drift.
  ★ PASS 1 LANDED + VERDICTS IN (2026-07-31, record 20260731_104452): checklist facts settled -
  see pet_parser_scope.md for the full verdict block. Headlines: canonical CLEU API is FURNITURE
  (all 4000 rows varargs; classic 3.3.5 layout verified positionally); minions are TYPE_PET not
  GUARDIAN (0x1111); lab pairs real; DODGE/MISS + crit flags confirmed at era positions;
  witness = per-TYPE presence buffs (no count buff exists); ★ UNIT_DIED NEVER FIRED for any of
  71 pets (overwrite despawn is CLEU-silent) -> row-collapse must composite activity-TTL + plate
  presence + type-buff witness. Two summon lanes: Raise (persistent army) vs Animate (zombie
  swarm, 36 in 148s, mostly never plate-bound). REMAINING BEFORE THE GRID: (a) his call on
  SWARM ROWS (36 zombie GUIDs would flood a micro grid; candidate = one collapsed family row);
  (b) LF-cost table offline; (c) the UI chassis stub.


- **OPPORTUNITY (Battlewrath, 2026-07-20, pick up as a FRESH run): the Necro/Reaper custom UI.**
  His mains, they feel the same - one UI serves both. TASTE: gothic ironwork; little gothic-styled
  headers; RE-USE the Necromancer class widget elements (the client's own art). THE BASIS EXISTS
  (see 'interfaces basis' - patch-B code extraction + census + live-proven panel patterns + render
  economics). FIRST BOUNDED STEP (designed, not started): the ASSET SURVEY -
  (1) extract patch-A.MPQ art trees via extract_interface.py --all-types (CoAResource 33 files =
  the class-resource widget art, HUD, SpellShadow, TALENTFRAME, borders/flourishes; gitignored
  study copy like patch-B); (2) locate the CoAResource/class-widget CODE in patch-B FrameXML and
  map which art each class widget uses (the Necro elements named file-by-file); (3) emit the
  reusable-elements SHELF (browsable inventory: frames/borders/headers/fills/glows, keyed by what
  they are + where the client uses them; BLP eyeballing in-game or via converter). Then design
  over a real shelf: taste picks, facts assemble. Related standing work: the pressure-queue demo,
  guardian scaffold, class-systems-as-skill-lines - all Necro/Reaper-centered display candidates.


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

- **task_perf instrument notes (from the 4-arm SignalFire run, 2026-07-19/20):** mem column reads
  0 (GetAddOnMemoryUsage name resolves for CPU but not mem - investigate); the envelope should
  STAMP the watched addon's own option states (arms must self-describe - arm D's parser state had
  to be asked); watch MULTIPLE addons (st perf SignalFire,Chatter) so interaction arms show who
  pays. Arm D pending: Battlewrath to confirm parser was off (decides the Chatter-doubles-residual
  read). The furniture probe (live filter roster / OnUpdate / AddMessage audit) is banked at
  refs_signalfire/inspection/furniture_probe.lua - console paste, not yet run.


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
