# addons — the client-side Lua bench (root sibling of `corpus/` · `creator/` · `operations/`)

_Established 2026-07-15. A dedicated bench so the addons goal never has to flip against the aura-pipeline goal.
**Same ecosystem, one tree of truth**: this bench reads the whole repo for supporting information and input, and the
other benches consume what it produces._

## The charter — what this bench owns

**Lua that runs in the client.** Capture/dump tooling (COA_DevDump's evolution), QoL addons, harvest addons that feed
the maps, and eventually the scripting lane's in-game half. NOT owned here: the aura pipeline (dockets → strings —
that's `creator/` + the engine), the corpus refinement (`corpus/`).

## The custody line (the inter-bench contract)

**This bench produces captures, dumps, and harvests; the other benches consume them.** COA_DevDump already formed the
client-side basis of the whole project (talent/trainer/spellbook scrapes → `coa_spells.json`; the probe pattern;
SavedVariables as the receipts channel) — that flow is the standing model. Outputs land where the consumer expects
them (`Weak Auras/ingest/inbox/` for aura captures; `Outputs/` for data dumps), provenance-stamped.

## The ecosystem seat (what to read from the wider tree)

- `operations/` — STATE · roadmap · HOW (the invariants; **invariant 7 applies here doubly** — client Lua IS the fork)
- `operations/Addons_load.md` — **this bench's mental-load ledger** (open threads, banked refinements, arcs)
- `creator/ingredients/custody.md` — how the aura side works (this bench's biggest consumer)

## The residents (refreshed 2026-08-13)

**Products (deployed via `deploy.py`; each has its own README):**
- `COA_DevDump/` — the capture spine (task registry + SV mailbox; the task SHELF is the point)
- `MancerLedger/` — long-term minion averages over Mancer's per-fight data (profiles, calm
  window, flight-recorder token; READ `DRIVER_CONTRACT.md` before touching the fold)
- `COA_Landmarks/` — **a self-authored scrapbook of places on the world map**: mark somewhere
  that matters, write why, get back to it later. Feeds the client's own supertrack beacon rather
  than drawing a pointer. *"How I play, not what exists"* — deliberately not a gathering
  database. Spec: `addons/planning/landmark_design.md`; facts: `satnav_ledger.md`. `/lm`
- `COA_DungeonRun/` — **dungeon routes: capture, display and curation.** A route IS a sequence
  of pulls, so it records the pulls. Combat start/end are the markers (regen EDGES, state re-read
  from `UnitAffectingCombat`), the path between is sampled 1/s **in combat and out** (DR-35), both
  entrances captured. Records everything and filters nothing. Draws a run back onto the client's
  own tiles and **never learns a dungeon**; the curation pane slices it by TIME and **only ever
  changes what you see.** No beacon and no promotion yet.
  Spec: `addons/planning/dungeonrun_poc.md`. `/dr`
- `COA_PetGrid/` — the Necromancer pet micro-grid (personal tooling; capture lane pending the
  two-witness retirement decision)
- `COA_GuardianPlates/` + `COA_StatePlates_Aggro/Friendly/Enemy` — the State Plates family
  (core + per-concern satellites; two banked bugs live in the ledger)
- `Mob_Autogroup/` — a design doc

**Reference silos (poisoned references — understanding + interop contracts only, never copied):**
- `refs_libellus/` — Mancer/LibellusLeti (THE driver MancerLedger consumes; incl. the 0.9.553
  dev drop w/ provenance) · `refs_recount/` · `refs_signalfire/` · `refs_threat/`

## The files here

- `invariants.md` — the transferable laws + the collaboration posture (read FIRST, before any code)
- `bench.md` — the validation loop + the fact basis (client paths, lua51, version anchors, doc standings)
- `backlog.md` — the missions (three are banked and unblock the aura bench on day one)
- `planning/` — the incubator: messy on purpose, DELETED when proven (the standing charter)

## The bench tooling (built 2026-07-15 — the loop's two ends, mechanized)

- `menu.bat` — **THE pinned terminal** (keys-only, root-launcher model): hosts the watcher,
  steers deploys/pulls/git. One terminal access for the whole bench.
- `deploy.py` — repo→client dispatcher: manifest of residents, byte-copy + stray cleanup +
  by-exception receipt. Check mode (no args) is read-only. Game CLOSED for deploys (anti-cheat:
  new addon code needs a full client restart; /reload can't load it).
- `landing/pull.py` — client→repo: clones the flushed SavedVariables mailbox verbatim into
  `landing/raw/` (local receipt, gitignored), parses via the codec-proven `lua_table.py` into
  `landing/records/<runId>__<task>.json` (tracked), deduped on runId. `watch` mode = the
  leave-it-running half.
- `tools/smoke/` — the offline smoke harnesses (lua51-driven, stubbed frame API): one per
  product; run the relevant one after ANY addon change, before deploy.
- **The third witness lane (2026-07-31): `/combatlog`** — the client's own CLEU-to-disk
  stream (`Logs/<datetime> WoWCombatLog.txt`), parseable by
  `Class_design/Necromancer/tests/parse_combatlog.py`. The cheapest
  does-this-fork-emit-X instrument: no capture task, no deploy, no reload.
- `COA_DevDump/` v2 — the in-game half rewritten as a task-registry spine (core + task files,
  one-envelope mailbox, by-exception chat, shorthand verbs `r/st/sp/list/clear`). See its README.

## The census (THE FIRST GOAL — delivered 2026-07-15, live-proven same day)

- `maps/census/` — **the client-surface census**: 88 declared C_* namespaces (1028 attested members w/
  sightings) · 736 events (213 custom-registered) · the stock-3.3.5 baseline (from the client's own
  APIDocumentation addon) · `runtime/` = the three-witness reduction off the live `census` task's
  51,855-global _G walk (284 runtime-only members = uncalled API). Start: `census.routes.md`.
- `maps/atlas/` — the **art** fact basis, the counterpart to `maps/census/`'s API one: the
  client's 4,503 named atlas entries classified by CLAIM OF USE (1,359 claimed / 3,144 free),
  so "which icon may we use" is read, not re-decided by eye per project. Start: its `README.md`.
- `maps/addons/` — **our OWN code held to the standard we hold theirs to**: every function we
  define, every OnUpdate/timer/event/hook (what runs without the user asking), and what each
  addon pulls from and pushes to the client. `frame_cost.md` is the half that matters — the
  page `task_callwitness` had to be built to produce for somebody else's addon. Start: its
  `README.md`.
- `tools/` — the deterministic emitters: `extract_interface.py` (patch-B.MPQ → study copy) ·
  `baseline_extract.lua` (run APIDocumentation under lua51) · `emit_census.py` ·
  `reduce_census.py` · `emit_atlas_census.py` · `emit_addon_census.py` · `read_spell_dbc.py`.
