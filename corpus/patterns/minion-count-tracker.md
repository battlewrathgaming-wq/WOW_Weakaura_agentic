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

## The primitive it wants to become

A member-list contract: `select` = the class's summon-buff ids (derivable — the resolver's summon/apply edges),
`emit` = this signature per member. Five hand-built auras collapse to one contract row set. Candidate for the
Self-tracker family when summon-heavy specs (Necro/Animation) get their packs.
