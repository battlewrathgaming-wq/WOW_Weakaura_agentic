# COA Identity Index - a WeakAuras scoping exercise (resolved, no addon built)

Status: **RESOLVED, 2026-07-08 - not built, and not going to be, as
originally framed.** What started as an addon-family proposal reasoned
itself down, round by round, to a conclusion that needs no addon at all:
see "Final resolution" at the end of this document. Everything above that
section is kept as the reasoning trail that got there, not a spec to build
against - same historical-record role this project already gives
superseded framings elsewhere, not a mistake to delete.

## Research proof gates (2026-07-08) - checked against real source, not assumed

Three questions asked before this goes any further, answered directly from
this client's actual installed `WeakAuras/*.lua` (not general WeakAuras
knowledge - this build's real source) plus this project's own prior
addon-review docs.

**1. Can WeakAuras actually render a region anchored to a nameplate frame,
tracking it?** Yes, confirmed directly in source, and it's more built-in
than expected. `WeakAuras.lua` has a dedicated
`anchorFrameType == "NAMEPLATE"` branch (~line 5711) that calls
`WeakAuras.GetNamePlateForUnit(unit)` (`AuraEnvironment.lua:145`, itself
wrapping `LibGetFrame-1.0`'s `GetUnitNameplate`) and anchors the region
directly to the real plate frame it returns - ordinary `SetPoint`-based
anchoring, so it tracks the plate the same way any child frame tracks its
parent. On top of that, WeakAuras already has a full **native "nameplate"
unit-group trigger type** (`Prototypes.lua`, `trigger.unit == "nameplate"`,
alongside `group`/`raid`/`party`) that auto-populates one synthetic unit
per currently-visible plate (`Types.lua:3532`, `nameplate1`..`nameplate100`)
and spawns a clone per unit automatically. Rendering a tracked dot on a
nameplate isn't a gap to solve at all - it's stock.

**2. What prior work already handles this?** Two layers, both real and
already reviewed by this project. `Tools/COA_GuardianPlates/
CAPABILITY_INVENTORY.md` already documents three installed addons
(TurboPlates, Kui_Nameplates_Auras, PlateBuffs) that render live buff/debuff
icons on nameplates today, on this exact server, via three different
curation philosophies (fixed-category-with-priority, pre-curated
per-class list, reactive learn-as-you-go) - full working prior art for the
rendering problem, no WeakAuras involved. Separately, WeakAuras' own native
nameplate trigger/anchor (above) is itself prior art for the same problem
inside WeakAuras specifically - nothing about "can an aura track a plate"
needed inventing.

**3. Is there an actual need, or does the API already do enough?**
For the plain case - "show something on whatever nameplate is currently on
screen" - the native trigger plus the three installed addons already cover
it completely; no addon proposed here adds anything for that case. The
real gap is narrower than the original framing below suggested, and is now
confirmed rather than assumed: WeakAuras' native nameplate clones are keyed
by the raw unit token itself (`Types.lua:3532` populates
`multiUnitUnits.nameplate` with the literal `"nameplate3"`-style strings,
not GUID) - the exact identity that isn't stable across a pooled-frame
reassignment, the same problem GuardianPlates had to build `unitIndex`/GUID
to solve for its own bookkeeping. Native WeakAuras has no equivalent fix -
a clone tracking `nameplate3` has no way to notice the occupant underneath
changed. That instability, plus true persistent/off-screen tracking (which
by definition nothing nameplate-based, native or addon, can ever do, since
it requires a plate to exist at all), are the two things that survive
scrutiny as a real need. One correction to the original framing: totems do
get real nameplates on this client while on-screen (GuardianPlates already
colors them via the `UnitPlayerControlled` split) - so it's specifically
the off-screen and cross-reassignment cases that stay unsolved, not "totems
have no visibility at all."

**Net effect on scope:** Phase 0 (expose GP's existing GUID-stable
`unitIndex` as a real API) is the part that now has direct, confirmed
justification - it's fixing a gap just verified to exist in native
WeakAuras, not a hypothetical one. Phase 1 (persistent pet/party-pet
tracking) remains the piece that delivers the actual stated goal. Phases
2/3 (totem combat-log tracking) matter specifically for off-screen totem
persistence and cross-attribution, not for "can a totem be seen at all" -
that part already works today, natively, with zero new code.

## Prior art, round 2 - five real wago.io examples (2026-07-08)

Checked against five live, published WeakAuras (not hypothetical designs)
to see how real authors already solved pieces of this problem.

Two (`Overpower on Nameplate`, `!ZulgAuras! - NamePlate Targets`) are
plain confirmation of tier 1 - a single icon or text field on the native
"nameplate" unit group, no custom code, live production use. Nothing new,
but real-world proof the mechanism the source-code research found is the
one people actually reach for.

`Sweb's NamePlate SunderArmor` is a live, shipped stack-count-plus-expiry-
glow tracker anchored per nameplate - a real instance of the "rowed
tracking bar" idea, just scoped to one debuff rather than a general
framework. It also carries the exact caveat flagged above: built on the
native nameplate group, which is unit-token-keyed rather than GUID-keyed,
so a stack count could in principle survive a frame reassignment and
misattribute to the wrong occupant for a moment - low-stakes for a short
single-target debuff at this scale, but the same gap, not a different one.

`Default Nameplate Debuffs - SoD` proves the curated-debuff-display
pattern (already documented from TurboPlates/Kui_Nameplates_Auras/
PlateBuffs as standalone Lua addons in `CAPABILITY_INVENTORY.md`) can also
be built as a pure WeakAuras group at real production quality (actively
versioned, multiple installs) - and it explicitly punts CC detection to a
dedicated addon rather than trying to cover everything itself, the same
curation discipline already on record from the Lua-addon review.

`Classic:Dummy-Tracker` is the one that actually moves the needle. It
independently reinvents two pieces of this proposal's hardest tier,
unprompted: it keys everything by GUID specifically to avoid name
collisions (a pet named after its owner, a same-named player from another
realm) - the identical reasoning this project used for `unitIndex`, arrived
at independently by an unrelated author. And its actual mechanism for
"which dummy/totem-like summon belongs to which player" is exactly tier 4:
catch the summon event, record summonedGUID -> ownerGUID once, then match
later death/damage events against that stored pairing. That's shipped,
multiply-versioned, working code doing the exact correlation this proposal
marked as the expensive, needs-live-testing tier - a real reference
implementation to adapt from, not something being invented from scratch.

Two corrections it surfaces, both worth folding into how this proposal
talks about itself:

- **Combat log isn't omniscient either.** The author states outright that
  its death/reconnect detection "does not really work over distance"
  outside instances - combat log visibility is itself range/zone-bounded,
  just a different (usually wider) boundary than nameplate camera-frustum
  culling, not the unconditionally-persistent signal this document's
  phrasing implied. See the acceptance note below - this isn't a flaw to
  fix, it's the actual shape of what's achievable.
- **Event overloading is a real landmine, not a hypothetical one.**
  `GROUP_ROSTER_UPDATE` fires on a resurrect, not just on roster changes -
  it silently corrupted an unrelated code path until the author special-
  cased it. Worth remembering once this proposal's own event handlers get
  written: an event firing for a reason beyond its obvious name is a
  normal WoW-API hazard, not an edge case.

## Acceptance: this tracks what's around the player, not the whole game

Every stream this proposal relies on - nameplates, unit tokens, combat log
- only ever gives visibility into what's near the player. Summons happen
around the player; combat log events fire for what the player's client
can see; nameplates render for what the client draws. There is no stream
available that provides global, server-wide awareness, and `Classic:
Dummy-Tracker`'s own admission above confirms this isn't just a
theoretical limit - a real, mature addon hit it directly. "Persistent,
off-screen tracking" earlier in this document means *persistent relative
to the player's own presence and combat log range* - a pet or totem that
stays trackable as long as it's within that radius, not a claim of
tracking anything anywhere on the server. That's the actual, accepted
shape of the capability, not a gap to eventually close.

## Scope narrowing, round 3 - canceling against what's already free (2026-07-08)

Battlewrath drew a tighter boundary before this goes any further: this
addon isn't trying to index every summoned entity in the game, or every
effect one other player has on another - it's anchored strictly around
the player themselves, in five relationship categories: things I did,
what I did to other players, what they did to me, who's in my group, who's
in my raid. Explicit test applied to each: cancel it unless either no
native API/WeakAuras mechanism already answers it, or it does, but only by
making every separate consumer duplicate real work a shared cache would
do once.

- **What I did to other players** (in group/raid) - cancels. WeakAuras'
  own aura trigger already filters by caster, and its native group/raid
  unit-group trigger already iterates the roster through its own
  internally-cached tables (`multiUnitUnits.group`/`.raid`/`.party`,
  confirmed in the gate-1 source read above). "Is my buff on this raid
  member" is already answerable with zero addon code.
- **What they did to me** - cancels. Exactly the mechanism
  `COMBAT_LOG_CAPABILITIES.md` already documented: `destGUID == player` or
  the destFlags "Mine" bit, a single flag check per event, no state held
  anywhere, regardless of whether the source is friend or foe.
- **Who is in my group** / **who is in my raid** - both cancel. Native
  roster API, and WeakAuras already caches this internally the same way a
  shared identity index would.
- **Things I did** - splits, and this is the one that changes Phase 1
  below. A player's own pet is a fully native, always-addressable unit
  token (`pet`) - a WeakAura can trigger on it directly, on-screen or off,
  with zero addon involved. That cancels "persistent pet tracking" as a
  reason to build anything. What doesn't cancel: anything summoned that
  isn't a pet - totems and similarly-shaped things with no dedicated unit
  token at all. Nothing native tracks "does this thing I summoned still
  exist" as a queryable fact; only combat log (`SPELL_SUMMON` correlation,
  `Classic:Dummy-Tracker`'s pattern from round 2) can answer it.

**Net result:** four of five categories, and the pet half of the fifth,
cancel completely against native API or WeakAuras' own internal caching.
What survives is narrow - existence/identity tracking for non-pet things
the player personally summons, because that's the one question nothing
native answers at any tier. The one place the performance clause (rather
than the impossibility clause) still applies: if more than one WeakAura
eventually wants this data - a healing-totem row and a separate
damage-totem alert, say - each independently rebuilding its own summon-
correlation table is real duplicated combat-log work a shared module
avoids, not "impossible otherwise," just wasteful to repeat per consumer.

**The bigger lesson, not just about this proposal:** most of what looked
like justified addon scope turned out to already be reachable by using
WeakAuras' own native triggers correctly - nameplate anchoring (round 1),
group/raid rosters and caster-filtered auras (this round), and a player's
own pet token (this round) are all things WeakAuras can already do
directly, no custom code, once the native mechanism actually gets checked
instead of assumed missing. The habit this reinforces going forward:
check what WeakAuras itself already exposes before reaching for an addon,
and let "build an addon" mean only the sliver of combat-log-only entities
WeakAuras genuinely cannot see any other way - not a default first move.

This also re-scopes Phase 0 below, not just cancels Phase 1. Phase 0's
original framing was a general-purpose "any nameplate's GUID-stable
identity" API for arbitrary future consumers - but under this narrower
five-category boundary, no such general consumer need has actually been
shown. What Phase 0 still is: real infrastructure specifically in service
of the one surviving need - a totem is nameplate-visible while on-screen
(confirmed round 1), so its existence there still benefits from
GUID-stable tracking, feeding the same claims table its off-screen
combat-log tracking uses. Narrower justification, not narrower code.

## Where this came from

GuardianPlates' own `unitIndex` (v2.2) already solves one real identity
problem: a pooled nameplate frame gets reassigned to a different occupant
mid-fight, so tracking "this specific entity" by frame or unit token alone
is unsafe - `UnitGUID` is the only thing that stays stable across that
reassignment. That was built purely for GuardianPlates' own bookkeeping
(restoring a plate's true state before a reused frame gets handed to a new
occupant), with no consumer outside the addon.

The design conversation that produced this doc asked whether that same
GUID-stable identity could be exposed as a shared resource - so a
WeakAura could spawn a genuinely per-entity row/bar keyed by GUID, which
WeakAuras cannot do on its own (its native triggers only key off unit
tokens, and unit tokens are exactly the thing that isn't stable here).
That's "the issue we had with guardians": a naive per-slot tracker breaks
the moment the frame underneath gets recycled, silently showing a
different guardian's data under the same row.

Two things followed from there. First: GuardianPlates' own visibility is
nameplate-existence-driven, which is itself camera-frustum and range
gated by the client - a minion behind you or out of range simply has no
nameplate and drops out of view entirely, resuming under the same GUID
once it's back in range. If persistent, off-screen tracking (not just
"whatever's currently rendered") is the actual goal, that can't be done
through nameplates at all - it needs direct unit-token polling (`pet`,
party-pet slots) for entities that have one, and combat log for entities
that don't (totems have no dedicated unit token on this client era at
all, but do have a stable GUID in their own damage/heal log lines).
Second: because that's a genuinely different trigger surface from
GuardianPlates' nameplate-event model, it has to be its own addon, not a
mode inside GuardianPlates - sharing a contract with GP, not sharing its
runtime code.

## What "identity index" actually means here

Not a HoT/DoT tracker itself, and not a rendering addon. The proposed
addon's only job is to answer, for any GUID it has a claim on: does it
currently exist, where (unit token/frame, if any), is it friend or foe,
and who/what created it - and to say clearly when a claim has ended so a
consumer doesn't have to guess. WeakAuras (or anything else) reads that
shared resource and does its own triggering/rendering on top of it. Same
"don't own content, expose real state" principle that shaped every design
call on GuardianPlates itself (bar-only healer reveal, armed-gate color
override) - this just generalizes it from "one addon's own suppression
logic" to "a lookup surface other things can depend on."

### The claims contract

A single GUID-keyed table, maintained by the addon, read (not written) by
consumers:

- **Existence** - is this GUID currently claimed at all.
- **Locator** - current unit token/frame, if the stream that produced this
  claim has one (nameplate- or unit-token-derived claims do; combat-log-
  only claims like totems don't - there's nothing to hand a WeakAura to
  anchor on for those, only the fact that the GUID exists and is active).
- **Affiliation** - friend or foe, from whichever stream provided it.
- **Provenance** - what created it, where known (e.g. a totem's
  summoning spell/caster).
- **Claim-ended signal** - explicit where the source stream gives one
  (nameplate REMOVED, unit-token loss); inferred via staleness where it
  doesn't (see TTL section below).

## Streams, ranked by how much they already give you for free

This ordering *is* the lightest-first guardrail, not a separate rule
bolted on afterward: cheaper, more-flattened streams get used before
reaching for one that requires building correlation logic by hand.

1. **Nameplate events** (`NAME_PLATE_UNIT_ADDED`/`_REMOVED`) - GP already
   does this. Zero inference: the client tells you a claim started and
   ended, directly. Locator is a real frame. Bounded to whatever currently
   has a plate (camera/range gated).
2. **Direct unit-token polling** (`pet`, `party1pet`..`party4pet`, etc.) -
   also zero inference: `UnitGUID`/`UnitExists`/`UnitHealth` on a known,
   fixed token answers existence and identity directly, with no
   nameplate required at all. This is what makes persistent off-screen
   tracking of the player's own pet straightforward - the token is always
   addressable regardless of camera or range.
3. **Combat log affiliation flags** - for entities with no addressable
   token (totems), the combat log already flattens the one question that
   matters most before reaching for real correlation: `sourceFlags`/
   `destFlags` carry a real bit for "is this mine"
   (`COMBATLOG_OBJECT_AFFILIATION_MINE`, confirmed live and documented in
   `COMBAT_LOG_CAPABILITIES.md`), plus `InParty`/`InGroup` bits for
   group-relative affiliation. Checking that bit on a totem's own
   damage/heal line answers "is this mine" with no summon-event tracking
   needed at all - the server already computed it.
4. **Combat log event correlation** (linking a `SPELL_SUMMON` line's
   casterGUID to the summoned entity's own GUID, to attribute later
   damage/heal lines back to a specific owner beyond "mine/not mine" -
   e.g. *which* raid member's totem this is) - the only tier that
   requires the addon to build and hold its own state across events
   rather than reading something the client already computed. Reach for
   this only for questions tiers 1-3 can't answer; it's real inference,
   not a lookup.

Battlewrath's framing for why this ordering matters: "so we don't try to
infer from streams what the API can already flatten." Tier 3 exists
specifically because it already answers the exact question ("is this
totem mine") that a naive design would otherwise reach for tier 4's full
summon-correlation to get - the affiliation bit makes that correlation
unnecessary for the most common case.

## Claim-ended: authoritative where possible, TTL-inferred where not

Nameplate and unit-token claims get a real end signal from the client
(REMOVED event, `UnitExists` going false) - no inference needed, mirrors
how GuardianPlates already restores state on `NAME_PLATE_UNIT_REMOVED`.

Combat-log-only claims (totems) have no equivalent - there's no reliable
"totem expired" event in this client era. For these: maintain a TTL per
GUID, refreshed forward by each new log line naming that GUID, same
pattern as `healerModeTTL` (refresh-forward-on-activity, let staleness
itself be the signal, confirmed live and working in GuardianPlates
v2.1/v2.2). Staleness without a new signal covers all three real end
cases without needing to tell them apart: the totem died, the player
moved out of combat-log range of it, or it was replaced - a replacement
totem is a new summon with its own new GUID, so it becomes its own
independent claim with its own TTL rather than something the old claim's
expiry logic needs to special-case. One rule, three causes, no
per-cause branching needed.

TTL duration itself is a tuning question (long enough to survive the
normal gap between a totem's own attack/heal ticks, short enough that
"gone" doesn't lag reality) - a live-test number, not an architecture
decision, same as `healerModeTTL`'s 4s default was.

## Guardrail: lightest version first

Explicit build-order constraint, so this doesn't turn into building all
four tiers at once: each phase should be buildable and useful on its own,
and later phases should only add a stream once the question in front of
them genuinely can't be answered by what's already there.

- **Phase 0** - **re-scoped, round 3.** Originally framed as a
  general-purpose "any nameplate's GUID-stable identity" API for
  arbitrary future consumers. No such general consumer need survived the
  round-3 boundary check, so this is no longer independently justified -
  it now exists only as infrastructure for Phase 2/3's totem tracking (a
  totem is nameplate-visible while on-screen, so its identity there feeds
  the same claims table its off-screen combat-log tracking uses). Same
  code, narrower reason to build it.
- **Phase 1 - canceled, round 3.** Originally: add direct unit-token
  polling for the player's own pet and party-pet slots. A player's own
  `pet` is already a fully native, always-addressable unit token - a
  WeakAura can trigger on it directly, on-screen or off, with zero addon
  code. Nothing to build here at all.
- **Phase 2** - add combat log, but only the affiliation-flag check
  (tier 3) for entities with no unit token (totems): does a claim exist,
  is it mine. No summon-event correlation yet.
- **Phase 3** - only if a real use case needs cross-attribution beyond
  "mine" (e.g. "which ally's totem is this") - full `SPELL_SUMMON`
  correlation plus the TTL-based staleness scheme above. This is the
  expensive tier and the one most likely to need real live-testing
  before trusting it.

Each phase is a legitimate stopping point, not a partial build waiting on
the next one - if Phase 1 covers what's actually needed, there's no
obligation to build Phase 2 or 3 just because they're on this list.

## Open questions before this becomes a real task

- Confirm no dedicated unit token exists for totems on this client build
  at all (assumed from prior project research, not yet directly tested
  against a live totem).
- TTL duration for combat-log-only claims - needs a live totem to tune
  against, not guessable in advance.
- Whether Phase 0's API surface should be a plain global table (simplest,
  matches this project's existing SavedVariables-adjacent style) or a
  small function-based API (`GetClaim(guid)`, `IterateClaims()`) -
  function-based is safer against a consumer accidentally mutating shared
  state, worth deciding before Phase 0 ships rather than after.

## Final resolution (2026-07-08) - this was a WeakAuras scoping exercise

Everything above traces one continuous reduction, each round removing a
layer of assumed-necessary infrastructure once it got checked against
something real rather than left as an assumption:

1. **Standalone addon, four-phase framework** (original framing) - a
   whole addon family, mirroring GuardianPlates' own shape.
2. **Gate 1** - nameplate anchoring/tracking turned out to be fully
   native to WeakAuras already; no addon or custom code needed for that
   piece at all.
3. **Round 2** (five real wago.io examples) - the rendering half of the
   problem already has multiple live, working solutions, several of them
   pure WeakAuras with no addon involved; `Classic:Dummy-Tracker` showed
   the hardest correlation tier (`SPELL_SUMMON` -> owner GUID) already has
   a working reference implementation, and that combat log itself isn't
   omniscient - it's player-proximity-bounded, same as everything else.
4. **Round 3** (the five-category boundary) - four of five relationship
   categories, and half of the fifth (a player's own pet), cancel
   completely against native API/WeakAuras' own internal caching. What
   survived: existence tracking for non-pet things a player personally
   summons.
5. **Performance/usability pass** - a standalone addon is measurably
   faster per event (no WeakAuras dispatch/sandbox indirection) but loses
   on distribution (an import string beats a downloadable addon for
   adoption), GUI-editability, and free debug tooling (`DebugLog.lua`).
6. **Universal parser + hidden GUID-keyed children** - a real, sound
   design (confirmed via `WeakAuras.GetTriggerStateForTrigger` and
   custom-trigger clone keys, which can be GUID strings unlike the native
   nameplate trigger's forced unit-token keying) that gets every
   WeakAuras-native advantage *and* solves the one thing native nameplate
   tracking couldn't - but built to serve multiple entity types from one
   shared source.
7. **The reduction that closes it** - totems and non-Shaman guardian-type
   summons are class-exclusive; a single character only ever plays one
   class, so no consumer ever needs more than one entity-type category
   tracked at once. The "universal" part of round 6 was buying flexibility
   against a combination that never actually occurs. Battlewrath's own
   framing: universality is worth its cost when the future need is
   genuinely unknown; here the need is already fully specified per class,
   so building a dispatcher for it is more work than solving the one,
   known case directly.

**What's left, and it needs no addon, no shared aura, no running service
at all:** capture the proven script shape - subevent-filtered custom
trigger, `SPELL_SUMMON` -> owner GUID correlation, GUID-keyed clone if a
visual row is wanted, TTL-based staleness where no authoritative end
event exists - as a reusable pattern, and re-parameterize it per class
exactly the way this project already builds every other class-specific
capability: through `Templates/build_templates.py`/`template_filler.py`'s
schema-and-fill convention (Necromancer/Reaper/Bloodmage's own tiers),
not a new architectural layer. When a class actually needs this shape of
tracking, it gets built as that class's own template instance - the same
process already proven, not a new one invented for this problem.

Net effect on the family task list: no `COA_IdentityIndex` addon gets
built. The five-category boundary check, the `GetTriggerStateForTrigger`/
clone-key mechanism, and the "check WeakAuras' native reach before
reaching for an addon" habit are the durable outputs of this exercise -
worth remembering next time a tracking need shows up, not worth shipping
as a standing piece of infrastructure for a need that was already fully
answered by the tools already in hand.

## Standing principle - capability isn't justification

The broader lesson here outlasts this one proposal. Battlewrath's own
framing: demonstrating that an addon *can* now be built isn't a reason to
build one every time a new idea comes up - "just because we can now make
addons, doesn't mean we should based on my sparks." An idea being
buildable was never the bar; whether it earns its place against what
already exists is.

GuardianPlates is the actual contrast case, and it's worth naming why it
cleared that bar when this proposal didn't. GP does real, substantial
work - but that work is filtering and conditional signaling laid over
existing native content, never content of its own competing with it: it
suppresses/reveals the real health bar, recolors the real name text,
holds a reveal open on a real threshold crossing - every one of its
features is a decision about *whether and how* something the game already
draws gets shown, not a new thing drawn on top of it. That's the same
instinct that shaped the bar-only healer reveal (drop the custom %HP text,
let the native bar speak for itself) and the armed-gate color override
(never touch anything while disabled) - GP earns its place by conditioning
on real state, not by generating new content the player has to reconcile
against what's already there.

This proposal, chased all the way through, never found that same
justification: every piece of it turned out to be either already native
(nameplate anchoring, roster iteration, caster-filtered auras, pet
tracking) or a narrow correlation problem better solved as a captured
script than a running service. The right question for the next spark
isn't "can this be built" - it's "does this filter/condition real
signals without competing with them, the way GP already does" - and if
the honest answer is no, or "not yet, not until a concrete need shows up,"
that's a reason to hold it as a documented idea, same as this one, not a
reason to build it anyway because building it is now possible.
