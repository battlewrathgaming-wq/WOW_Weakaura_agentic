# Addons_load — the addons agent's mental-load ledger

_What I'm carrying between sessions that no other file owns: open threads, banked refinements,
small debts, and walls-with-context. STATE.md says where the machine is; this says what's on my
mind. Pruned when items resolve — an empty section is a healthy section. Est. 2026-07-15._

## Open threads (each has a designed next step)

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
