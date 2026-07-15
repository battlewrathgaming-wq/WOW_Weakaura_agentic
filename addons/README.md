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
