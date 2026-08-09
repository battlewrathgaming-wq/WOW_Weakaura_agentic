# pattern: engagement-registry — "did I touch this?" (SEED, not built)

_status: **BACKLOG SEED, designed 2026-08-09 (Battlewrath + aura bench), nothing built.** Parked with its
design, its costs, and the facts already proven, so a future session starts cold from here rather than
re-deriving it._

## The problem it solves

Every corpse/kill tracker built so far counts `UNIT_DIED` in CLEU range. That over-counts, and **none of
the available filters fix it**:

- **No source.** `UNIT_DIED` carries no killer at all — GUID all zeros, name `nil`, flags `0x80000000`
  (proven in our logs). So "my kill" is inexpressible on the death event.
- **No proximity API.** The client census attests nothing that enumerates nearby corpses (only own-death
  recovery: `CORPSE_IN_RANGE`, `RetrieveCorpse`, `UnitIsCorpse`…). CLEU range is the only spatial gate.
- **Flag filters are blunt.** Reaction (`Hostile`) drops neutral wildlife that leaves perfectly good
  corpses; object type (`NPC`) is the best available cut but says nothing about *whose fight it was*.

## The idea

**Register the GUID of anything you damage; count a death only if its GUID is in the table, then drop it.**

The registry primitive is already proven twice on this bench (guardian-health-tracker feeds it from
`SPELL_SUMMON`; the summon-count death-accurate upgrade would feed it the same way) — this is a third feed,
from damage events.

**Why it beats every alternative: if you damaged it, it was in your range.** Damage *requires* proximity,
so the registry is a true distance proxy rather than the time-based approximation the current builds use
("5s since death" standing in for "still near me").

## Why it matters more than the open-world case (Battlewrath, 2026-08-09)

The current mitigation is a **Load: Instance Type** gate (5-man / 10 / 20 / 25 / 40) — the instance boundary
standing in for a population filter, on the assumption that everything dying in range is your group's doing.

**That assumption breaks when raids split.** Two groups on different packs are still in the same instance,
so the gate passes while the events are someone else's. The registry doesn't degrade that way — it answers
per-unit regardless of who else is in the zone. So instance-gating is the cheap approximation; this is the
correct filter.

## The costs to weigh first

- **High-volume CLEU.** Damage subevents are the busiest in the game. Survivable with an early
  `src ~= UnitGUID("player")` return (plus pet GUIDs), but it is a real step up from the zero-Lua footprint
  the current builds enjoy.
- **Pruning.** Units you hit then walked away from linger in the table; it needs an age-out, which is more
  bookkeeping than "add on damage, drop on death".
- **Undercounts in groups.** A party member's kill leaves a usable corpse the registry never saw. So this
  does NOT replace instance-gating for coordinated group play — the two are complementary, and a build
  might want both (registry OR same-instance-and-recent).

## Already proven — no re-derivation needed

- CLEU arg layout: `1 ts · 2 subevent · 3 srcGUID · 4 srcName · 5 srcFlags · 6 dstGUID · 7 dstName ·
  8 dstFlags · 9 spellId · … · 12 amount` (findings #17). No `hideCaster`, no raid flags.
- Bare `COMBAT_LOG_EVENT_UNFILTERED` is disabled in this fork — use filtered `CLEU:<SUBEVENT>` forms.
- `UNIT_DIED` puts the dead unit at dstGUID[6] with an all-zero source (findings #18).
- Object-type bits: `Player 1024 · NPC 2048 · Pet 4096 · Guardian 8192 · Object 16384`
  (`Prototypes.lua` objectTypeToBit). **Pet corpses despawn** (Battlewrath) — so pet-typed deaths should
  never count regardless of which filter is used.
- The registry + resolver split generalises: see `guardian-health-tracker.md`.

## The gate hierarchy it would join

Current corpse trackers stack three filters, each seeing a dimension the others can't:
**instance type** = whose activity · **in combat** = whether it is live · **N-second window** = whether it
is still reachable. The registry would replace the first and sharpen the third.

## Revisit trigger

When open-world corpse tracking starts mattering, **or** when a split-raid situation makes the instance gate
visibly wrong. Until then the three-gate stack is working and this stays parked.
