# Capability request (UPSTREAM) - weighted heal suggester

Raised 2026-07-07 by the Bloodmage class-implementer pass, per
`../AGENT_ROLES.md`'s escalation rule. Battlewrath's own framing: this is
"an upstream task first for the generic capability" - a NEW core mechanic,
not a class-folder build. Captured here so it isn't lost; belongs to the
core-maintainer thread + live-test loop, not this folder.

## What it is

A 1-slot "show one" dynamic group, off to the side, that surfaces the
single best healing ability to use RIGHT NOW. Battlewrath's shorthand:
"friend.target HP = Ability that covers the HP gap with lowest mana. A
conditional script that has weighting." I.e. read a friendly target's
missing health (the HP gap), evaluate the candidate healing abilities, and
recommend the one that covers that gap for the lowest cost - a weighted
conditional evaluation, not a fixed priority list.

Fits the class's support/PvP role (see `Bloodmage_fantasy_playstyle.md`'s
"Player intent & role"). It ENRICHES rather than replicates (per that
doc's design principle): native UI shows unit health, but nothing computes
a cost-efficient heal recommendation against a live deficit.

## Why no existing capability covers it (why it's upstream)

- Every current `REGISTRY` template shows a KNOWN state (a cooldown, a
  buff, a power value, an aura presence). NONE compute a recommendation by
  comparing multiple abilities' heal-vs-cost against a live HP deficit.
- It needs a **Custom / stateupdate** WeakAuras trigger running a **bespoke
  weighted Lua script** - explicitly the "genuinely new mechanic that needs
  source-level verification (Prototypes.lua / BuffTrigger2.lua / etc.)"
  class that `../AGENT_ROLES.md` reserves for the core-maintainer + the
  build -> live-test -> trace-source -> fix loop. Out of class-implementer
  scope by definition.
- The "dynamicgroup that shows exactly ONE child, driven by a computed
  selection" display pattern is new. Partial precedent: Necromancer's
  Minion tracker is a `dynamicgroup`, but its children are fixed presence
  icons, not a computed single pick.

## Confirmed vs. unknown

- **Nothing built or live.** Entirely a design + core-build item. No source
  verification done yet; no Lua written; no live test.

## Open design decisions (Battlewrath's / core thread's to make)

1. **Unit definition** - what is "friend.target"? The friendly unit the
   player currently targets? Focus? A party/raid scan for the lowest-HP
   ally? PvP arena vs. party vs. raid changes this a lot.
2. **Candidate ability dataset** - which heals are in the pool, and where
   do their heal amount + cost come from? A static per-spec table we
   maintain, or live spell data? Heal amounts scale with SP/Spirit, so
   "amount" is dynamic, not a fixed number - the script needs a scaling
   model or a live read.
3. **The weighting model** - "lowest cost that covers the gap" is the
   baseline, but "weighting" implies more: cast time (instant vs. GCD),
   cooldown availability, overheal avoidance, range, target CC/LoS. Which
   factors, and their relative weights?
4. **Edge behavior** - what shows when NO ability covers the gap (biggest
   heal? nothing?), and when the target is full (hide? blank slot?).
5. **Cost resource is NOT mana - for Bloodmage it's HEALTH.** Bloodmage
   uses no Mana at all and only **minimal Rage** (Battlewrath, 2026-07-07);
   its heals are paid for primarily in the caster's **own health** (the
   spend-life-to-heal loop, see `Bloodmage_fantasy_playstyle.md`). So for
   this class "lowest mana" literally means "the heal that covers the ally's
   HP gap for the least of MY OWN life" - a life-economy tool, not a mana
   calculator, and squarely on-theme. Design implication: the generic
   capability must PARAMETERIZE the cost resource (health / rage / mana /
   energy / ...), not hardcode mana - the very first class to want it spends
   health, so a mana-only build would be dead on arrival here. The
   weighting also gains a real tension unique to this class: spending health
   to heal an ally lowers the caster's OWN survivability (esp. in PvP under
   focus), so "cheapest heal" and "safest for me" can conflict - worth
   deciding whether self-HP-risk is one of the weighting factors (see #3).

## What's blocked

**Nothing in the Bloodmage folder.** This is net-new upstream capability -
no current build depends on it. Once the core layer provides the mechanic
plus a way to DECLARE an instance (unit, candidate abilities, cost/heal
data, weights), the class folder consumes it like any other template, and
this note can be closed out into a real `slot_assignment.md` row.
