# COA_PetGrid — the Necromancer pet combat micro-grid (personal tooling)

_Built 2026-07-31 (passes 1–3 of the pet-parser arc). Status: **personal tooling** — the
combat-state readout half of the original pet-parser want. The lifetime-averaging half was
pivoted to `MancerLedger/` (Mancer as capture driver); PetGrid was deliberately NOT offered
to the Mancer author (their MinionHpHud + WeakAuras already solve TTL/HP display — offering
it would tread finished work). Facts basis: `addons/planning/pet_parser_scope.md`._

## What it is

A Recount-like in-game micro grid where **the rows are your pets**. Two sections:

- **Raise** (the persistent army): one row per living individual GUID, sorted by Life Force
  cost descending (investment order — stable, no dancing rows). Columns:
  name · HP bar with % overlaid (the read is "healthy or not", not a value) · fight-scoped
  Dmg · Crit% · Miss% (sample floor 20 → `-`).
- **Animate** (the temp swarm: zombies, archers, tomb king...): one row per FAMILY —
  name · TTL window (the same bar element, amber, counting down to the next count drop) ·
  ×count · rates. No HP column: no nameplate expected for animates by design.

HP has a 3-state anti-flicker machine: LIVE (colored, updating from plate-window reads) →
STALE (greys at last-known when the plate drops) → GONE (row collapses). Container is pinned
by its TOP-LEFT corner so row changes only ever grow DOWN (drag/lock/scale persist in SV).

## Liveness model (the record-verified part)

- **Combat deaths: push-driven.** UNIT_DIED fires for pets on this fork (proven via
  /combatlog disk witness, 2026-07-31), and the per-type minion-buff removal LEADS the death
  event by 17–122ms — either signal collapses a row instantly.
- **The buff-instance witness is the count authority**: Necro minion buffs are one instance
  per individual (3 ghouls = 3 auras), so a UnitAura sweep gives per-type population; CLEU
  attributes which GUID (least-recent-signal closes first, plate-visible last).
- **Overwrite-despawn is CLEU-silent** (the one silent case — proven, 71-summon record):
  re-summoning replaces a pet with no event. The witness sweep is the only detector.
- Animates run on the LF/TTL table (from Input talents + Battlewrath's class knowledge);
  buffless types fall back to activity+plate liveness (60s orphan sweep).

## Files

- `core.lua` — chassis (pooled rows/headers, grow-down pin, writer tick) + feed slot.
- `feed_live.lua` — the real feed: CLEU at the verified 3.3.5 varargs positions
  (canonical API is furniture on this fork), summon registry + srcName adoption after
  /reload, accumulators, witness reconcile, SV lifetime normals folding on every close
  (both lanes), fight-scoped dmg reset on regen.
- `feed_demo.lua` — the chassis-proving fake feed (`/petgrid demo` toggles).
- SV: `COA_PetGridDB` = `{ topX/topY, scale, locked, mode, normals{} }`.
- Slash: `/petgrid` → `lock|unlock|scale <x>|reset|demo|stats|resetstats`.

## Known rims

- Banshee / Skeletal Mage / Gargoyle buff ids unknown (never summoned in the source record)
  — those types use the fallback liveness until captured.
- Skeletal Archer TTL reads 15s; the +3s talent isn't modeled.
- No idle/off mode — live and demo are the only feeds (disable via the AddOns list).

## The open retirement question

MancerLedger's arrival means the CAPTURE lane here (accumulators/normals) duplicates the
driver's parsing. Plan of record: a **two-witness window** — run PetGrid's counters beside
Mancer's ring for a stretch, diff per fight; agreement validates both, then PetGrid's capture
lane retires and the grid keeps only what nobody else has: the live STATE display (witness
liveness, TTL windows, 3-state HP). Until that window runs, both stand.

Offline smoke: `addons/tools/smoke/smoke_petgrid.lua` — drives the LIVE feed through a
simulated fight at the verified varargs positions (registry, adoption, witness-close,
TTL-fold, regen-reset) plus the chassis pools. Run after any change:
`.tools\lua51\lua5.1.exe addons\tools\smoke\smoke_petgrid.lua`
