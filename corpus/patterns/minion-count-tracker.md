# pattern: minion-count-tracker

_status: **candidate primitive** (Battlewrath: "I like the minion tracker") · provenance: the Necromancer capture
2026-07-14, 5 CLEAN(+1 residue) closures (Ghoul · Skeleton · Abomination · Crypt Fiend · Greater Skeleton Warrior)._

## What it is

One icon per **summon/minion type**, counting how many of that type you have up. The count is NOT stacks — each minion
is its own buff *instance*, and the display reads the **match count**: a subtext showing `%1.matchCountPerUnit`.

## The signature (from the closed dockets)

- trigger: aura2 · `unit: player` · `debuffType: HELPFUL` · `ownOnly: true` · **exact-id catch**
  (`useExactSpellId` + `auraspellids: [<minion buff id>]`) · `useStacks: true`
- display: small icon (30×40), `cooldown: false` (see-the-count, not a timer), zoom crop
- subtext: `text_text: "%1.matchCountPerUnit"` — the count of matching instances on you

## The policy note (a legitimate exact-id exception)

Match-family-not-rank is the house law — but here the **type-distinction IS the information**: each minion type is a
distinct id, and a family/name catch would merge them. Exact-id per type is correct. Record: exact-id is right when
the pattern's meaning is "count THIS type among siblings."

## Why this is the AUTHORITY for permanent minions (cross-bench, 2026-08-08)

Not merely a convenient read — the addons bench's raw CLEU record establishes it as the correct one:
**"Minion buffs are ONE INSTANCE PER INDIVIDUAL (3 ghouls = 3 auras) — the per-type instance count is the
liveness AUTHORITY for Raise types"** (`addons/COA_PetGrid/feed_live.lua` header). The alternatives fail:
`UNIT_DIED` is **silent for overwrite-despawn (0 of 71 proven)**, so a GUID registry holds ghosts; and the
permanent `Raise:` family has no TTL to decay. The buff instance is the only honest witness.

Complement: timed `Animate:` summons carry NO buff and are TTL-governed — those go to
[summon-count-tracker](summon-count-tracker.md). Two patterns, one problem, split by what the game exposes.

## The primitive it wants to become

A member-list contract: `select` = the class's summon-buff ids (derivable — the resolver's summon/apply edges),
`emit` = this signature per member. Five hand-built auras collapse to one contract row set. Candidate for the
Self-tracker family when summon-heavy specs (Necro/Animation) get their packs.
