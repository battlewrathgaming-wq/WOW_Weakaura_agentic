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
- `creator/ingredients/custody.md` — how the aura side works (this bench's biggest consumer)
- `addons/COA_DevDump/` — the seed tool (repo copy; live copy in the client's `Interface/AddOns/`)
- **The residents (moved in 2026-07-15):** `COA_DevDump/` (the seed probe/dump tool) · `COA_GuardianPlates/`
  ("COA State Plates" — the shipped nameplates addon, WITH `deploy_to_game.bat`: **the deploy pattern** — repo =
  source of truth, byte-copy to the game folder, stale-file cleanup; agents never write into the client's AddOns
  directly. Generalize it per-addon as bench work) · `Mob_Autogroup/` (a design doc) · `refs_threat/` (third-party
  threat/nameplate addons as REFERENCE material — secondary standing, study not authority)

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
- `COA_DevDump/` v2 — the in-game half rewritten as a task-registry spine (core + task files,
  one-envelope mailbox, by-exception chat, shorthand verbs `r/st/sp/list/clear`). See its README.

## The census (THE FIRST GOAL — delivered 2026-07-15, live-proven same day)

- `maps/census/` — **the client-surface census**: 88 declared C_* namespaces (1028 attested members w/
  sightings) · 736 events (213 custom-registered) · the stock-3.3.5 baseline (from the client's own
  APIDocumentation addon) · `runtime/` = the three-witness reduction off the live `census` task's
  51,855-global _G walk (284 runtime-only members = uncalled API). Start: `census.routes.md`.
- `tools/` — the deterministic emitters: `extract_interface.py` (patch-B.MPQ → study copy) ·
  `baseline_extract.lua` (run APIDocumentation under lua51) · `emit_census.py` · `reduce_census.py`.
