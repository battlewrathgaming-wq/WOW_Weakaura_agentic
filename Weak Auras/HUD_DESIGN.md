# HUD design principles

Settled design philosophy from a discussion session (2026-07-02), reached
before any implementation - deliberately kept separate from `AGENT_PROMPT.md`
(technical grounding) and `USE_CASE.md` (why this project exists, external
reference research). This doc is the *shape* the HUD should take. See
`AURA_BLUEPRINT.md` for how a tier here becomes an actual buildable aura.

## The governing idea

A HUD's job is to answer a question before you consciously ask it - that's
different from a dashboard, which answers questions you deliberately go
looking for. The scarce resource is attention, not screen space. More visible
information does not mean a better HUD; less time between a state change and
you noticing it does.

Distance from the screen's center roughly tracks urgency and frequency of
relevance - but the actual placement rule is **adjacency by gameplay
coupling**, not a pure linear scale. Two tiers sit next to each other because
they interact in the same glance, not just because they carry similar
urgency.

## The five tiers, center to edge

1. **Proc / Condition** (innermost, highest urgency, shortest lifecycle).
   The "do the thing, it's ready" layer - passive/talent procs and stack
   thresholds. Tightly coupled to Rotation, because a proc's whole purpose
   is to change what you press next - the two need to be readable in one
   glance. State communicated by brightness/saturation swap (dim +
   desaturated when unavailable, full color + brightness when ready), never
   by flashing, strobing, or alarm-style color. Information, not demand.

   Scope, refined 2026-07-02: if the procced ability already has its own
   Rotation button, that button reacting in place (glow/brighten on its
   own icon) IS the proc communication - no separate tier-1 icon needed,
   since reusing the same physical slot as the action itself is the
   tightest form of "tightly coupled to Rotation" this doc already argues
   for. This tier is reserved for procs/conditions that genuinely can't
   be shown that way: the affected ability isn't a standing Rotation
   button (an off-bar spell made free/instant), the condition doesn't map
   to one specific button (a stacking buff, a "next spell of this type"
   effect with no fixed target), or multiple simultaneous states need
   disambiguating space a single icon can't hold. This replaces "routine
   vs. rare" as the actual dividing line below - routine-ness was never
   the real criterion, communicability-via-existing-button is.

   Considered and rejected, same day: a "fly-out" badge sitting as a hat
   on top of the Rotation button, rather than the button itself reacting
   in place. Rejected on principle, not just gut feel - it's an
   appear/disappear event on a brand-new visual element, which is exactly
   what the "fixed channels" cross-cutting rule below already prohibits
   (fade/dim an existing element, never appear-disappear-reflow). It also
   breaks "one visual grammar": some Rotation buttons would sprout a
   decoration and others wouldn't, making the row's rhythm non-uniform
   rather than every button speaking the same brightness/saturation
   language regardless of whether it currently has a proc riding on it.
   And it invites real layout edge cases - overlapping hats when two
   adjacent buttons proc simultaneously, collision with subregion text/
   cooldown swipe already occupying icon corners, illegibility at small
   icon sizes (25-40px). Glow/brighten-in-place stays the approach.

2. **Rotation** (steady rhythm, not urgency). What you press by default,
   driven by resource/priority state rather than a readiness question -
   reflexive, not deliberate. For healers and tanks this lane is fuzzier
   than for DPS, since their "default loop" is often reactive to external
   state (raid HP, threat) rather than a fixed priority chain.

3. **Power-button** (deliberate, longer cycle, less proc-coupled). Real,
   long-cooldown, first-class abilities - "press this because I chose to
   spend it now, not because priority says so this GCD." Lower frequency
   and longer lifecycle than Rotation, and rarely proc-coupled, so it sits
   one layer further out - below the Rotation bar, neighboring the cadence
   of HP/Resources rather than Proc/Condition. For tank and healer roles
   this lane may carry more of the actual skill expression than Rotation
   does, but it doesn't get extra visual weight for that (see "known open
   questions" below - resolved, the HUD gives a fixed eye location
   regardless of role, not role-weighted emphasis).

   **Rotation/Power-button cooldown threshold, settled (2026-07-04):**
   cooldowns at or under the 15/30/45-second bracket default to Rotation;
   the 1/2/5-minute "major cooldown" bracket (tank defensives, healer big
   AoE heals, DPS big buffs/defensives - already a standard WoW pattern
   across roles) defaults to Power-button. See `AURA_BLUEPRINT.md`'s
   worked example for the full reasoning.

4. **Resources** (diagnostic, ambient). Useful, not action-driven by
   itself - glanced at rather than watched continuously. No longer
   tracks HP (decided 2026-07-02): the default Blizzard unit frame
   already covers health and stays on screen (this project's UI-
   minimization goal was never "remove everything," just the stock
   action bars/clutter - see USE_CASE.md), so a duplicate custom HP bar
   here is dead weight. That freed slot becomes a second resource
   counter instead, so this tier is two resource counters, not one HP
   bar + one resource bar.

   The `Template_shadow` scaffold's "Health"/"Mana" slots (2026-07-02)
   were placeholders - "Mana" specifically stands in for whatever the
   class's actual primary + secondary resource pair is (e.g. Mana and a
   stacking secondary, or Rage and a stacking secondary, or Energy and a
   stacking secondary - not literally Mana for every class). With 21
   custom classes, this pair varies per class and needs to be resolved
   per class rather than assumed generic; the two slots exist regardless
   of class, what fills each one doesn't.

   **First class resolved (2026-07-05): Necromancer is Mana (primary) +
   Runic Power (spender)**, confirmed directly by Battlewrath rather than
   assumed from ability data (the indexed data alone under-signals both -
   see `Necromancer/spell_index.md`). Tracked traceably in
   `Necromancer/slot_assignment.md`, the real-content counterpart to
   `ELEMENT_INVENTORY.md` for this class. Life Force is a related but
   separate mechanic - deliberately not a Resources-tier slot, see that
   folder's `BUILD_METHOD.md`.

   **Player Cast Bar - added to this tier (2026-07-06), closing a gap
   flagged since the earliest reference-library research** (`reference_
   library.py`'s "Open follow-ups" - both Fojji's and Luxthos's real
   packs have a dedicated cast bar with no equivalent slot in this model).
   Settled: build a custom one rather than lean on the default UI's own
   cast bar (`CastingBarFrame` - confirmed to exist; several standalone
   addons like Quartz/AzCastBar exist specifically to restyle/replace it,
   the same reason this project replaces default action bars with
   Bartender4 despite the default ones working). Placement: **inside
   Resources, alongside Health/Mana** - Luxthos Mage's real convention
   (its "Cast Bar" sits in the same "Resources" section as Health/Mana,
   same `aurabar` region, same size/style - not a separate dedicated
   section the way Fojji splits "Player Cast Bar" out on its own).
   Mechanically nothing new to discover: WeakAuras' **Cast** trigger
   (`unit = player`, already confirmed live-relevant in
   `CAPABILITY_INVENTORY.md`) is the same trigger type `enemy_cast`
   already uses for target/focus - this is that same trigger pointed at
   the player instead. Not yet built - this is the placement decision,
   not an implementation.

   **Swing timer - wanted; dependency concern raised, then resolved,
   2026-07-06.** First pass concluded this needed a separate library addon
   (SwingTimerAPI by Ralgathor), based on a live Wago "[WotLK] Swing Timer"
   pack stating that dependency. Battlewrath pushed back on that - shipping
   a HUD element that forces anyone using it to install an extra library,
   when everything else here is plain WeakAuras, was worth questioning
   rather than accepting. **Checking the real installed WeakAuras source
   directly (`Prototypes.lua`, not just inferring from one pack's
   description) reversed the conclusion**: WeakAuras has a fully native
   **Swing Timer** trigger type (`WeakAuras.InitSwingTimer()`/
   `GetSwingTimerInfo(hand)`, both internal to the addon itself, no
   external library referenced anywhere) - see `CAPABILITY_INVENTORY.md`'s
   newly-verified entry. Supports `main`/`off`/`ranged` natively, so
   dual-wield main+off tracking works out of the box. **No addon beyond
   WeakAuras itself is required** - the earlier Wago pack's dependency was
   a legacy/author-preference choice, not a real technical requirement of
   this client. `IMPLEMENTATION_PLAN.md`'s SwingTimerAPI entry is
   withdrawn accordingly. One honest caveat, straight from WeakAuras' own
   UI text: results are "inaccurate in edge cases," due to Blizzard's own
   API limitations, not a WeakAuras or this-project shortcoming. **Accepted
   as-is by Battlewrath (2026-07-06)**: this HUD is a baseline built on
   plain WeakAuras, not a final answer - a more performant dedicated addon
   could replace just this element later without disturbing anything else,
   since nothing else in the HUD depends on it. Sits outside the five tiers
   proper, same as `enemy_cast` - a combat-utility element, not a
   fixed-address glance point, so it doesn't need a "which
   tier" answer the way Player Cast Bar did.

   **Revised 2026-07-06 (later same day) - both Cast Bar and Swing Timer
   are now bars with a shared idle-shadow treatment, per Battlewrath:**
   "I think the cast / swing should both be bars. Both have a timer on
   the right side, static. Both have a shadow presence when not in use to
   declare their footprint." Swing Timer flips from `icon` back to
   `aurabar` (superseding this section's earlier settled choice and
   Template_shadow.py v0.12's changelog) so it visually matches Cast Bar.
   Both now stay visible at all times - dim and empty when idle, full
   brightness and filling only while actually casting/swinging - via a
   second always-true trigger ("Unit Characteristics", unit=player, no
   checks ticked) combined with the real trigger using WeakAuras'
   `activeTriggerMode = -10` ("first_active"), plus a Condition that
   raises alpha from 0.35 to 1 only while the real trigger is active. A
   static `"%p"` (remaining time) subtext sits anchored to the bar's
   right edge, present but blank while idle. See `Necromancer/
   slot_assignment.md` for the full mechanism writeup and verification
   status.

5. **Consumable / Prep** (outermost, bottom footer). A fixed-width row
   spanning the same footprint as the HP/ability block above it, ten slots
   reserved regardless of class, filled left to right. Greyed out by
   default; present but discreet when active - no celebration on
   activation, matching the "information not demand" rule. Tracks only
   what the player personally applies and controls (flask, food, weapon
   enchant, similar) - never raid buffs, other players' cooldowns, or
   world state. Actively fades once combat starts, because its decision
   window is entirely pre-pull - by the time you're fighting, checking it
   is too late to act on. This is the general fade rule for every tier,
   not just this one: fade based on whether the tier is still
   decision-relevant right now, not a blanket combat/non-combat toggle.

   Covers two sub-categories under the same fade rule, confirmed via the
   `Template_shadow` scaffold (2026-07-02): self-applied **buffs** (the
   original scope - flask/food/enchant) and non-combat **utility actions**
   (hearthstone and similar) - things you press, not states you hold, but
   still entirely pre-pull in nature. Both share the exact same rule
   (present pre-combat, fade once combat starts) rather than needing a
   separate rule for "non-combat action" as a category - the fade logic
   was already general enough. In the scaffold these sit as two flanking
   slot-groups either side of the HP/ability block (buffs left, utility
   right) rather than one combined row - a placement detail, not a rule
   change.

## Cross-cutting rules (apply to every tier)

- **Fixed channels.** Every piece of information has a permanent screen
  address. A state change means fade/dim, never appear-disappear-and-
  reflow-the-neighbors. (This has a direct technical consequence: use
  static Groups, not Dynamic Groups, whose defining feature is auto-
  compaction/reflow - see `AURA_BLUEPRINT.md`.) A real shipped pack
  (`reference_library.py`, 2026-07-02) enforces this same idea by literally
  naming any group other auras anchor off of `"DON'T MOVE - ..."` - worth
  adopting verbatim for our own anchor groups once several tiers share one.
- **One visual grammar for state.** Brightness/saturation/motion mean the
  same thing everywhere, so peripheral vision can parse state without
  reading text. If color means "ready" in one aura, it can't mean "danger"
  in another.
- **Information, not demand.** No siren energy anywhere, including the
  proc layer where the temptation is strongest. Urgency is communicated by
  position (closer to center) and a clean brightness/color state, not by
  alarm animation or sound.
- **Class color as accent, not skin.** Enough to feel thematically like
  yours without consuming the screen or breaking the visual character of
  non-combat/RP moments.
- **Console center-seam end-cap, scoped (added 2026-07-06, Necromancer
  Resources tier).** When two bars/backing plates on a console are matched
  to the same idle darkness (a deliberate cohesion choice, see the
  backing-plate work below), the outer bar can lose its own visible edge -
  it visually fuses with whatever sits next to it at the console's center
  seam, so a 50%-full bar has no reference point to judge its fill
  against. Fix: a permanent class-accent-colored `subtick` end-cap at the
  bar's own 100% position (`class_accent_tick_end` fragment, `Templates/
  schemas`/`Templates/templates`) - confirmed live via screenshot (a
  green tick sitting at Mana's own max extent, distinct from the blue
  fill). **Scope, per Battlewrath:** this only belongs on a bar that sits
  at a console's outer position and touches another element at that
  shared center seam - not a blanket default for every aurabar. A
  standalone bar with open space/game background on both sides already
  has a visible edge and doesn't need one (Cast Bar/Swing Timer are the
  concrete counter-example - they end cleanly against their own backing
  plate and then the game background, so neither gets an end-cap).
- **Self-state only, never world-state.** Every element answers "what's
  available to me right now," never "what is the world/boss doing." The
  judgment call of *when* to act on that availability stays entirely with
  the player, informed by whatever else they're already watching - this
  HUD was never going to carry that information in the first place.
- **Whole-HUD intensity is per-tier state-conditional**, not a global
  combat/non-combat toggle. Each tier fades or brightens based on whether
  its own information is still decision-relevant right now.
- **Deliberate exception to the rule above: mute the entire HUD while
  dead/ghost (2026-07-06).** Unlike ordinary combat/non-combat, being
  dead genuinely does make every tier simultaneously irrelevant at once
  (no rotation, no resources, no procs, nothing to consume) - so a single
  whole-HUD toggle is the right call here specifically, not the
  blanket-toggle anti-pattern the rule above warns against elsewhere.
  Battlewrath's own framing: "let people enjoy running around seeing
  things" - ghost running is a deliberate sightseeing/exploration moment
  in WoW's own design, and a live combat HUD competing with that would
  work against it, not just be pointless clutter. Mechanism: WeakAuras'
  **Unit Characteristics** trigger (`Prototypes.lua` line 1834) has a
  native `dead` field (`type = "tristate"`, backed by
  `UnitIsDeadOrGhost(unit)`) that's also usable directly as a Condition
  (`conditionType = "bool"`) - the real API already distinguishes "dead or
  ghost" as one combined state, matching this rule's own scope exactly, no
  custom Lua needed. (Battlewrath separately confirmed spell 8326 is the
  "Ghost" aura itself - `Apply Aura: Ghost` plus +50% run/swim speed - a
  usable alternative/cross-check via an `aura2` trigger if the
  `UnitIsDeadOrGhost` route ever needs a second source of truth.) Not yet
  built - this is the design decision and the mechanism, not an
  implementation.
- **Class-specific alerts: non-intrusive enrichment, not full suites
  (2026-07-02).** With 21 custom classes, the temptation is to build a
  dedicated tracking system per class-specific mechanic (a whole pet
  roster UI, a full minion-management panel). The Necromancer Life
  Essence work settled the actual default instead: small, single-purpose
  enrichments layered onto the existing five-tier HUD - one fly-out, one
  resource-slot number - not a bespoke interface competing with it. The
  gain-framed "+N LE" phrasing (`USE_CASE.md`) is a specific instance of
  this general instinct: default to the smallest, calmest addition that
  answers the actual question, not the most complete system that could
  be built. Applies to every class-specific mechanic still to come, not
  just this one.
- **Compactness and cohesive spacing reinforce each other - evidenced,
  not invented (2026-07-02).** Gaps between same-tier elements (icon-to-
  icon, row-to-row) should be small and close to a FIXED absolute value,
  not scaled as a percentage of element size. Checked directly against
  two independent real packs rather than assumed: Luxthos Mage's actual
  `DynamicGroup` grow settings (`space=2`, `columnSpace=1`, `rowSpace=1`
  on 48px icons - roughly 4% of width) and the ToxiUI guide's separately
  documented ~2px convention (size-independent) - both land in the same
  small, near-fixed range despite being unrelated authors/packs. A tight
  gap doesn't just look cleaner - it's what makes a row of icons read as
  one cohesive tier at a glance instead of a scattered set of individual
  elements; compactness is what cohesion looks like at this scale.
  - **Positive rule:** default any new gap value to roughly 2-4px
    absolute, pulled from `reference_library.py`'s
    `LUXTHOS_CORE_GROUP_SPACING` (or an equally-checked fresh source) -
    not derived from a formula invented in the moment.
  - **Anti-pattern, tried and rejected:** `gap = round(icon_width *
    0.25)` (`Template_shadow.py` v0.1-v0.3, e.g. 10px on a 40px icon).
    Looked reasonable on paper, read as loose/disconnected once actually
    seen live in-game, and doesn't match how any real pack checked so
    far actually does it - percentage-of-size scaling was the mistake,
    not the specific number chosen.
  - **Comparison logic for next time:** if a proposed gap exceeds
    roughly 10% of the element's own size, treat that as a signal to
    stop and re-check real reference data before building - not to
    trust the formula and find out live.
  - **Correction (2026-07-02): row-to-row means the same thing as
    icon-to-icon - it doesn't get its own, larger convention.**
    `Template_shadow.py` v0.4-v0.6 quietly split "row-to-row" out into
    its own category and gave it 6-10px, on the unstated assumption
    that different tiers need more breathing room between them than
    icons need between each other. That assumption was never checked
    against evidence, and it was wrong: Battlewrath's own reference edit
    of the scaffold put every tier-to-tier transition (Proc-to-Rotation,
    Rotation-to-resource-bar, resource-bar-to-footer) at 1-2px - noise
    from hand-dragging, not a deliberate gap - and a live screenshot of
    Luxthos Mage's actual aura confirmed the same thing: icons, health/
    mana bar, and cast bar all touch directly, no visible air anywhere.
    The fix wasn't a smaller number, it was realizing there's no
    separate category to tune - default row-to-row to 0 (touching) just
    like within-row gaps default to 2-4px, and only introduce space
    between tiers if there's a specific, checked reason to (not as a
    standing default). Different-sized elements (e.g. a 20px-tall flank
    icon next to a 30px-tall button) still stack cleanly at 0 gap by
    aligning a shared edge (top, in that case) rather than forcing equal
    centers - that's a mechanical detail, not a reason to add padding.

## Known open questions (not yet settled)

- **Whether the Power-button lane should carry more visual weight for
  tank/healer specs than for DPS - RESOLVED (2026-07-04): no.** Battlewrath:
  "The player knows the meaning from their key binds. We're just providing
  a fixed eye location for them." The HUD's job is a stable glance-address,
  not re-emphasizing what the player already knows from muscle memory -
  weighting a tier by role would be solving a problem (forgetting what a
  button does) this HUD was never meant to solve.
- **Exact visual treatment of unused reserved Buffs/Utility slots, and how
  many slots each tier actually has - RESOLVED (2026-07-03).** Both
  questions were really one question: the slot count was never reasoned
  about (2 each, inherited from Battlewrath's original scaffold capture,
  not a deliberate choice), and "what shows in an unused slot" had no
  good answer because a static reserved slot is either a dead grey box or
  nothing at all - neither is useful.

  Settled design: each of Tier 3 (Buffs) and Tier 4 (Utility) keeps its 2
  existing static slots for the most important, always-relevant item(s).
  Underneath each, a Dynamic Group of up to 6 slots populates **only out
  of combat**, showing whichever tracked buffs/utility items are
  currently *missing* (flasks, food, weapon oils, etc. - personal
  self-buffs, not raid-wide coverage, which other tools already handle).
  Each missing item slides out of view the moment either (a) it's applied
  (no longer missing) or (b) combat starts (too late to fix, and combat
  is the wrong time to be looking at prep items). A settle-delay prevents
  rapid show/hide flicker from transient state noise.

  This is a second, deliberate exception to the fixed-channels rule -
  same shape as the pet-death alert's exception, and for the same reason:
  a Dynamic Group is normally wrong for this scaffold because it reflows
  fixed-address elements, but here the content is genuinely variable-count
  (0-6 missing items) and confined to a state (out of combat) where
  reflow can't compete with anything that matters in combat. The 2 static
  slots per tier remain fixed-address as always; only the dynamic
  overflow underneath is allowed to appear/reflow/disappear.

  Confirmed technically buildable, not just plausible, by reading this
  build's actual source: `BuffTrigger2.lua` has a real
  `matchesShowOn == "showOnMissing"` mode on the standard Aura trigger
  (show a sub-aura when a named buff is absent - exactly what "populate
  with what's missing" needs), and `Animations.lua` has a genuine
  translate-type animation for the slide transition.

  **Settle-delay, settled (2026-07-04): ~15 seconds, a custom hold (not
  just finish-animation duration).** Battlewrath's reasoning: long enough
  that chain-pulling (short gaps between fights) doesn't repeatedly flag
  the same missing item over and over between pulls; a longer real gap
  between pulls can afford to show it sooner, but 15s is the rough
  starting point rather than something that needs to react differently to
  pull cadence. **Also raised, not yet settled - flagged as a new open
  question:** the Utility side specifically might hide entirely while
  inside a dungeon/instance, on the reasoning that consumable/prep utility
  (hearthstone, etc.) is really a "content is done" signal - you check it
  between instances, not between pulls inside one. TBD, parked alongside
  the other build-time details below rather than decided now.

  `Template_shadow.py` v0.13+ reserves the positional placeholders for
  these dynamic slots (see `ELEMENT_INVENTORY.md`) - positioned below the
  whole footer cluster's actual lowest point (Power's bottom edge, not
  Tier 3/4's own shorter bottom edge, since Power sits at a different
  height and would otherwise collide with a row placed directly under
  the shorter Tier 3/4 icons - a real geometric constraint, not a
  stylistic choice).
- **Cast bars (player/target) and a swing timer have no tier - PARTIALLY
  RESOLVED (2026-07-03).** Player cast bar and swing timer are now built
  into `Template_shadow.py` v0.10+ (Row C/D of `ELEMENT_INVENTORY.md`),
  sharing the resource-bar footprint rather than needing their own tier.
  Target/enemy cast tracking is confirmed technically buildable (WeakAuras'
  "Cast" trigger supports unit=target/focus - checked directly in
  `Prototypes.lua`/`Types.lua`), but deliberately NOT placed here: it's
  inherently variable-count (0-N enemies casting at once), unlike every
  other fixed-address element in this scaffold, so it's planned as a
  separate DynamicGroup module instead. That module isn't built yet.
- **Routine vs. rare procs, one tier or two? - SETTLED FOR NOW (2026-07-04),
  keep 2 tiers, revisit if it stops holding.** Originally framed as
  routine-vs-rare (matching Fojji's "Proc Textures" vs. "Pop-up Group"
  split); superseded by the cleaner criterion above - whether the procced
  ability already has a Rotation button to react in place. Battlewrath
  reframed the remaining "can't react an existing button" question as:
  "did this ability proc, vs. is there a more global proc I'm interested
  in" - and decided to keep that at 2 tiers rather than splitting further:
  "Have to see. But then that's where a dynamic option is needed really,
  as its own tracker. For now I'd keep it to 2 tiers." So a third static
  sub-tier is off the table; if a genuine need for tracking "a more global
  proc of interest" shows up later, that's dynamic-tracker territory (same
  shape as the cast-bar/buff-overflow exceptions above), not a new
  fixed-address slot.
- **Icon aspect ratio: 40x30 confirmed by feel (2026-07-04), scaling math
  still open.** `reference_library.py`'s two sources split evenly -
  uniform 48x48 squares (Luxthos) vs. per-category non-square sizes like
  40x30 (ToxiUI's guide). Battlewrath, after `Template_shadow` live tests
  at this size: "I like the form factor." Locked in over uniform squares.
  New open question this raises: "consider the math for scaling, if 40x30
  proved to eat too much space - as they scale, how do we keep them
  grouped." Not yet checked whether WeakAuras' own Group grow/scale
  behavior already handles this linearly (scaling every child and every
  gap by the same factor, preserving the row's proportions) or whether
  `geometry.py`'s gap math needs its own explicit scale factor threaded
  through separately if icon size ever changes from 40x30.
- **Group backdrops as a framing device - confirmed working, not yet
  decided how far to use (2026-07-02).** Live-tested a Group with
  `border`/`backdropColor` enabled (`Zone_Test_Backdrop`, `border:false`
  in every real pack sampled before this, so untested territory) - it
  renders in-game exactly as encoded: a dark panel with a white edge
  framing the icons inside it. Battlewrath's idea: use this to make
  Resources and Rotation into one shared "central island" - a single
  framed zone rather than two separately-floating tiers, which would be
  a deliberate case of "adjacency by gameplay coupling" (HUD_DESIGN.md's
  own rule) expressed visually, not just by position. Parked for later -
  to be judged by building it and looking, same as the other open
  scale/position questions.
- **Pet-death alert has no tier, and is confirmed to be a fixed-channels
  exception.** Designed in `USE_CASE.md` (2026-07-02, refined same day): a
  Necromancer minion-death ping - `UNIT_DIED`'s generic destName
  cross-checked against a fixed-magnitude change in a personal "Life
  Essence" debuff (Abomination 3, Skeleton Warrior 1) to confirm it was
  one of yours, no HP estimation, one shared fly-out regardless of minion
  count or type-instance. Battlewrath confirmed this should be a small
  transient fly-out ("check yours"), not a fixed-address element -
  a deliberate, acknowledged exception to the fixed-channels rule above,
  on the reasoning that a one-shot "go look" nudge isn't the same kind of
  thing as a persistent state indicator competing for a permanent glance
  position. Still doesn't fit any of the five tiers as a *placement*
  question (it's a pet-state signal, not self-state readiness/resource/
  prep) - same open-gap shape as cast bars/swing timer above - but unlike
  those, its presentation mechanic (transient, not fixed) is now settled.
