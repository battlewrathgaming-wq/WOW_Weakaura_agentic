# Driver design — ADVISORY from the analysis lane

_2026-08-17. The result of running design challenges through the analysis lane with Battlewrath,
after the ask-list round-trip (`driver_analysis_asklist.md` §H). **This is advisory, not a
ruling** — where it disagrees with `dungeonrun_model.md`, the model wins; where Battlewrath ruled
in the thread, the ruling is marked. Written so the bench and the model can be checked against it._

---

## 0. The model as it now stands (one paragraph)

A route is an **instruction set**, compiled at the desk from an author's design against
captured data, walked by a dumb driver in the client. There are no "detectors" — there are
pre-configured positions that trigger pre-configured responses. **Detection uses our OWN
positions** (`GetCurrentPlayerPosition`, the same call the capture used); **the supertracker is
for POINTING and for in-flight CALIBRATION** (dest known because we set it; engine yards vs our
yards paired every tick, background-worker style). **Height is never invented** — every z is a
real sample's z; the band is *"we accept this XY at THIS sampled height ± H."* Progress is a
one-way ratchet with forward listening and hard resyncs.

---

## 1. Rulings from the thread (Battlewrath, 2026-08-17)

- **R-a. Detection reads our own positions, not the tracker.** The tracker's reading is calibration
  (in-flight, continuous) and the arrow. Retires the `0.00`-on-Invalid false-fire channel from
  detection by construction.
- **R-b. Height by construction.** The author drag is planar; z is always a sampled z. Want a
  different height → pick a point sampled there. Band = accepted XY at that height ± H.
- **R-c. No auto-grading of non-unique things.** No "packs 2/3" on screen — mobs are not unique,
  bosses are. The spent-set is INTERNAL (serves `requires` and re-fire suppression only).
- **R-d. Children may move the pointer.** Advice to default satellites note-only was heard and
  declined. The pointer is for TRAVEL; notes are for ACTION — that split is what makes it safe.
- **R-e. Exactly one lure per theater, defaulted.** The first child created IS the lure ("come
  here"); the author configures nothing to get a working theater.

---

## 2. State machine — the guide, not the contract

A route is a GUIDE (the player knows where they are and where next), not a CONTRACT (racing
checkpoints). Stage-locked listening is contract behaviour; the guide answers skipping this way:

    forward listen     current + K stages ahead (K = 3 default; author knob)
                       any forward stage satisfied -> jump; intermediates SKIPPED, not done
    ratchet            one-way; behind-stages ignored (a corpse run re-entering from the
                       entrance keeps progress and the arrow leads back to it - a strength)
    hard resync        boss death via CLEU -> AUTHORITATIVE SET (both directions), not max
                       - the cheapest, safest form of the correction path v1 excluded
    listen range       a broad per-stage arm zone (~half dungeon); geometry is ~30 ops and may
                       listen always; the range gates the EXPENSIVE listeners (CLEU, note churn)
    quiet != mute      outside every listen range the driver holds the pointer AND still emits
                       the off-route readout (distance to the route polyline, desk-reduced
                       Douglas-Peucker to ~30-60 segments; a number, never a reroute)

**The risk all of this trades against is FALSE ADVANCE** (a later stage's XY near an early
corridor - dungeons loop and stack). Bounded by: the author's geometry (band for stacked
floors), K, and boss-sets pulling a runaway ratchet back. **Measurable before it ships:** the
walk replays every captured run under K=3 and K=all and counts false advances.

Serves three players: the follower (stage-lock would do), the skipper (forward window), the
wanderer (off-route readout + boss resync).

---

## 3. Beacon / theater / children

    BEACON (childless)   position + R +-H IS the satisfaction. Self-completing. On-enter lure
                         is its own pointer. (= v1)

    THEATER (has kids)   the parent's position + R is the SCENE = the arm zone. Its xyz is a
                         scene centre, NEVER a pointer target. Children live under its identity
                         (4.1, 4.2 ...), inherit map/floor context. Arm only while the theater
                         is current AND the player is inside R. Lifecycle owned by the parent:
                         enter -> children armed -> completor fires -> ALL torn down (no
                         leaked CLEU listeners - the classic bug, closed by ownership).

    child                a beacon-shaped thing with: trigger (position R +-H | on_enter | CLEU
                         event) -> actions (note, pointer, CLEU-on, complete). Typed by what
                         it does, not by position in a list.

**Only a child TYPED as a completor moves the stage; satellites never do.** Ownership stays
single (the author designates it) but lives where the author needs it - the doorway, or the
listen event. Any-of completors allowed (doorway OR boss death) - how a theater serves the
skipper. Depth = 1 for now: a child does not have children (nested lifecycles multiply the
false-advance analysis; generalise from evidence if a case demands it).

**Bands by job:** arm zones (theater R) default OPEN band - a scene spanning two floors must not
veto arming on the other floor; satisfaction triggers default TIGHT band. Different defaults,
neither invents a height (R-b).

---

## 4. Satellites — order of ACTION vs order of PROGRESS

Three mob packs: locking to an order means you can only pull them in that order. So satellites
are UNORDERED (fire when reached, any order); progress is a SET, not an ordinal.

    mode: once     edge-triggered. Fires on reach, latches, SPENT forever. Default. Uses the
                   SEGMENT test (never miss a pass-through).
    mode: while    level-triggered. Active while inside, wipes on exit, re-arms. Ambient info
                   ("mobs are here"). Uses the POINT test (a transit too fast to sample inside
                   should not flash a note). Needs HYSTERESIS: enter at R, exit at R + margin
                   (a yard or 10%) or a player on the edge flickers it at 5 Hz. One desk const.

**Notes don't ping around because satellites latch once, not because they are ordered.** Shared
note slots are last-writer-wins, which is correct once each writer fires once: the note reads
as the most recently REACHED thing.

**Where order IS needed, it is a per-child dependency, not a group property - one primitive:**

    requires: [child ids]     = every listed child is CURRENTLY satisfied
                                (once -> spent; while -> inside now)

    satellite   requires nothing            fires when reached, any order
    sequence    each requires the previous  an ordinal chain, only where asked (gauntlets)
    completor   requires: [a, b, c]         the AND case; fires on the third, whatever order
                requires: nothing           a doorway off-ramp
                trigger: CLEU boss death    the hard resync, expressed as a child

`requires` is a static DAG -> **checked at compile time on the desk** (no cycles, every completor
reachable, no orphans). Authoring mistakes die before a frame ever ticks.

---

## 5. Compile target — one stage

    stage N (theater):
      scene:      { xyz, R, band: open }                    arm zone; never a pointer target
      children:
        - { lure: true, trigger: on_enter,
            actions: [ pointer := self, note := "come here" ] }      defaulted, exactly one
        - { trigger: {xyz, R, +-H}, mode: once|while, requires: [...],
            actions: [ note | pointer | cleu_on | complete ] }
        - ...
      sync:       { cleu: <boss name> dies -> SET stage N+1 }        authoritative

    stage N (beacon, childless):
      trigger:    { xyz, R, +-H }  -> complete; on_enter pointer := self

Per-tick cost: (1 + K) parent segment tests + C children of the current theater (segment for
once / point+hysteresis for while) + `requires` = boolean lookups on the spent-set + CLEU parse
ONLY while armed. All frame-safe. Compile-time: DAG check, exactly-one-lure check, band-defaults.

---

## 6. Detection geometry (from asklist §H, unchanged)

Segment-vs-cylinder for `once` triggers: did the path between the last two valid samples pass
within R at an acceptable dz. ~30 ops, one div, no sqrt; POINT fallback when the previous sample
is absent / other mapID. Segments straddling a mapID change are DISCARDED, never bridged. No
hold for pass-through (a 1.0 s hold MISSES a mounted transit). Closed-form miss-fraction of a
point test at R = 5: run 1% · mount 4% · ceiling 20%; segment test -> 0% up to path curvature
in one 0.2 s step.

Heartbeat: event-driven (mapID change) + divergence-detected (engine `sd` vs own distance,
> ~1 yd -> re-set) - falls out of in-flight calibration for free - + a rate-limit at POLL_MAX
while refused. Not a clock while ours.

---

## 7. Withdrawn during the thread (so nobody rebuilds them)

- `repeat` flag -> superseded by `mode: while`.
- Drag-z candidates (nearest sample / z-plane) -> R-b, height by construction.
- "Children never advance" -> "only completor-TYPED children advance."
- On-screen satellite progress count -> R-c.
- Child 1 as a special case -> the lure is a child with `trigger: on_enter` and `lure: true`.
- Positions as live `(dataset_hash, sample_index)` references -> seed once, carry forever
  (§12); the dataset gates SPAWN / RE-SEAT only, never holding or running a route.
- Embedding datasets in route packages -> datasets are their own economy.

## 9. Pointer close — we own it (the supertracker has no auto-close)

A pointer's CLOSE is a trigger like any other, evaluated on our own positions (R-a), owned by
the pointer action that set it. Two presets, one property:

    close: arrive    clears within R_close of the target (default 5 yd), SEGMENT-tested so a
                     mounted pass through a chokepoint still closes it.  "get TO here."
    close: lead-in   clears at a radius >> arrival, or on entering the theater's arm zone -
                     before the player would ever reach the target. The lure's pointer:
                     "come INTO here." Its job ends when the invitation is accepted.

    always           a pointer never survives its stage - teardown on advance closes it
                     regardless of mode. Last-writer-wins covers the REPLACED case; explicit
                     close covers the UNREPLACED one; teardown catches the rest.

Defaults (author configures nothing): a lure's pointer -> lead-in; any other pointer -> arrive 5.

- **F-ii lives here.** "When do we give the tracker back" (Battlewrath's ruling) has its
  mechanism in `close`: close = release; the next stage's lure = reclaim. Landmarks' contract
  (release-on-arrival, never reclaim) and the route's are the same vocabulary with a different
  policy line - deliberate, not inherited.
- **Close trades against calibration coverage.** The in-flight worker pairs samples only while a
  pin is held: `arrive 5` yields engine-vs-own pairs down to 5 yd; `lead-in` gives up the near
  range on that stage. Detection never depends on the tracker, so this is UX vs calibration
  data only - the calibration analysis should read coverage knowing which mode each stage used.

## 10. The pointer is a HEADING, not a waypoint chain (Battlewrath, 2026-08-17)

The arrow says *"the play space is that way"*; the player's path through the terrain is theirs.
The pointer must never make a player feel they have to zig-zag to touch locations or divert a
natural line. Hence `lead-in` as the default: point at the space, let go before it could pull
anyone off their path.

    the exception    when the path IS the path - a terrain skip, jump, climb, a route through
                     somewhere the area wasn't built for. Precision is the content. Expressed as
                     a LINE: a `sequence` of children (each requires the previous), `close:
                     arrive` at a tight radius, the NOTE carrying "jump here." Opted into,
                     never the default.

    desk readout     zig-zag is measurable, not ruled: pointer targets per 100 yd of route, and
                     heading change between consecutive pointers. Emitted as a number at
                     compile time; never a warning ("looks like helpfulness on the way over").

Corollary for R-d (children may point): pointer moves inside a theater want to be sparse -
author's taste, made visible by the readout rather than constrained by the model.

## 11. The fence, corrected — THREE tiers, not two (Battlewrath's challenge, 2026-08-17)

"Desk" above conflated two things; only one exists in the product. The product is TWO addons.

    DEV DESK      Python bench + corpus. Our analysis. Produces CONSTANTS that ship as Lua
                  literals (speed table, miss-fractions, POLL_*, hysteresis margin, safe-R).
                  Never in the product. Budget: unlimited.

    EDITOR        addon 1 - capture + author, in-game Lua 5.1. Owns the FLATTEN: route ->
                  instruction set, on save/compile. May be moderately expensive but must be
                  CHUNKED across frames or accepted as a save-time hitch. Also the authoring
                  readouts. Budget: seconds, chunked.

    CONSUMER      addon 2 - the driver, in-game Lua 5.1. Walks flattened data per tick and
                  computes NOTHING that could have been resolved at flatten time.
                  Budget, three rows of different KIND:
                    geometry   ~30 ops x (1 + K + C) per throttler tick
                    CLEU       EVENT-driven, not per-tick: dozens of events/s in a pull, so
                               the filter is the cheapest early-exit (subevent == UNIT_DIED,
                               then destName ==, done). **ARM ON ENGAGE, not on theater
                               entry** (Battlewrath, 2026-08-17: a boss-ENGAGEMENT API is
                               confirmed on this client - per-encounter, far quieter than
                               CLEU). Two-phase sync: engage API says WHICH boss and that it
                               is live -> CLEU UNIT_DIED on that name VALIDATES -> authoritative
                               SET. Two independent witnesses before a set that can pull the
                               ratchet BACKWARD. Listener lives for the encounter window only;
                               disarm on encounter end / wipe (no death -> no set, ratchet
                               untouched, re-arm on next engage). API name = bench fact.
                               Engage is also a legitimate TRIGGER KIND for cues ("boss
                               engaged -> note: mechanics") - entity kind `boss`, no position;
                               flatten resolves the two phases, the author writes a name.
                    API        the plumbing that makes it work: position read, tracker
                               set/clear, note display, event frames, SavedVariables. Bench
                               holds the call names on this client (file facts, not theory).

Reclassified (everything I wrote "desk" for at compile time is EDITOR):
  DAG / requires check · exactly-one-lure · band + close defaults · zig-zag readout   trivial
  calibration fit (least squares, ~1000 pts)                                          O(n)
  Douglas-Peucker on 300-1000 pts    worst O(n^2) ~ 1e6 ops = a MULTI-FRAME STALL naive in
                                     Lua 5.1 -> chunk, or accept as save-time hitch; CACHE
                                     the reduced polyline in the flattened output
  the WALK (replay a run vs the route: ~1000 x ~20 x 30 ~ 6e5 ops)   chunked; and it lives
                                     where the author is - the authoring review tool

**Flatten contract for the consumer:** DATA ONLY (no functions/closures) so it serializes to a
string and travels between players like a WA - that IS the distribution model, same codec
discipline. Every default resolved (lure, bands, close), `requires` resolved to INDICES not
names, reduced polyline baked in, DAG already checked. The consumer never computes a default
and never validates: if it is in the string, it has been checked. Reasoning at author time,
dumb walker at runtime.

## 12. Import / tweak / re-share, WA-style — the PACKAGE

WA has ONE format: the export string IS the editable table, runtime and editor read the same
thing, Modernize upgrades on import. We have a real compile step (flatten) and a dataset the
consumer doesn't need, so we keep the PRINCIPLE, not the shape: **the string carries source;
the runtime form is derived and never travels alone.** A route without positional data has no
meaning in the editor (height law, drag) - so the dataset is part of what travels.

**Three economies, three units (Battlewrath, 2026-08-17 - datasets are their OWN economy):**

    DATASET        its own string, its own import/export. Consumers: replay watchers (the
                   time-window playback) and authors composing against it. Identity = hash.
    ROUTE PACKAGE  meta / flat / source. REFERENCES datasets by hash, never embeds. Small.
    READER         needs `flat` alone; never touches the dataset economy.

    route package:
      meta      { schema_version, origin, version, datasets: [hash...], provenance chain }
      flat      the flattened instruction set  <- CONSUMER reads ONLY this. checked, ready.
      source    the route as authored (children/requires by NAME, defaults unresolved),
                where every beacon CARRIES ITS OWN SEEDED xyz - copied from a surface read at
                spawn, travelling with the route from then on. (Provenance dataset/sample may
                ride along as an audit field; nothing depends on it.)

**SEED ONCE, CARRY FOREVER - decoupled by construction (Battlewrath, 2026-08-17).** A beacon
can only be SPAWNED from a surface read - that is the gate against invented locations and
where H gets its guarantee. Once seeded, the route needs no dataset: an importer can tweak
everything (children, actions, notes, radii, bands, requires) with no dataset held. What needs
a surface is SPAWNING a new beacon or RE-SEATING an existing one - "moving" is not a drag to a
free point, it is re-seating onto another read; without samples the tool does not offer the
operation. **There is no way to make a beacon that did not come from a read.**

Like a binary shipped with its source in a debug section. Consumer: reads `flat`, checks two
things only (schema_version understood, integrity hash matches), computes nothing. Editor:
reads `source`, self-contained for tweaking; loads a dataset only to spawn / re-seat.

Loop: paste -> editor resolves dataset -> loads SOURCE -> author drags / adds children / edits
notes (samples present, so height law holds) -> save -> re-flatten -> export a new package
(new flat, edited source, same dataset_hash, provenance chain origin -> tweaker). Same format
in and out.

Integrity for free, WA's own idiom: on import the editor re-flattens `source` and diffs against
the shipped `flat` - clean diff = the package is what it claims. Reimport-diff-clean, one
layer up.

Settled by the format:
- **Dataset separate from route - always, and the route does not depend on it.** Many routes
  from one capture; a route imported with no dataset held is fully tweakable and fully
  runnable; only SPAWN / RE-SEAT are unavailable ("needs a surface read" - ABSENT NOT WRONG).
  Reader-only users and tweakers are never blocked by the dataset economy:
  less-authors-than-readers, expressed in the format.
- **schema_version from day one** (our internalVersion): consumer refuses newer; editor
  upgrades older on import (a Modernize of our own). The one field that hurts to add later.
- Mechanics: serialize -> compress -> encode, same codec discipline as the WA work; which libs
  WA uses on this client = bench fact. Route packages are small (structure + refs); DATASET
  strings carry the weight (~1000 x 7 fields), compress well; delta-encode positions first if
  it ever matters.

## 13. Instruction set = ENTITY TABLE + INSTRUCTIONS (Battlewrath's shape, 2026-08-17)

Split what an entity IS (facts, held once) from what it DOES (instructions it self-reports
against its ID). IDs unique PER ROUTE (the package is the namespace; merging = prefix-at-merge).

    ENTITIES  - one row per ID; the trigger IS the row (no separate T line)
      id   parent  kind      pos x y z   R    up  down  mode
      B1   -       theater   <read>      40   open       -       scene; stage order = row order
      C1   B1      on_enter  -           -    -          once    the lure (first child, default)
      C2   B1      pos       <read>      5    2   3      once    every pos is a COPIED READ (§12)
      C3   B1      pos       <read>      5    2   3      once
      C4   B1      boss      "Boss Name" -    -          once    the sync: engage-API arms,
                                                                CLEU death validates (§11)

    INSTRUCTIONS - A (action, order = execution order) and Q (requires), keyed by owner ID
      C1  A pointer C2 close=lead-in     pointer targets an ID, never a copied xyz
      C1  A note "come here"
      C2  A note "mobs are here"
      C3  Q C2
      C3  A complete                     the completor
      C4  A complete

- Membership = the `parent` column (typo check: every parent exists). `mode` (once|while) is
  an entity fact; `close` is an action property; the boss sync is an entity of kind cleu with
  a `complete` action.
- Positions held ONCE: pointers target IDs, so re-seating an entity moves everything that
  points at it; the seed-once law has exactly one home per entity.
- **This is already the consumer's shape.** Flatten = resolve IDs -> array indices: `E[i]` is
  what per-tick geometry reads, `I[i]` the action list run when `E[i]` fires. Two Lua arrays,
  O(1) lookups, no parsing at runtime; a reimport-diff is a row diff a human can read.

## 8. Not decided here (Battlewrath's, or the model's)

Give-back / reclaim of the tracker (F-ii) · far-stage policy beyond K · any shipped radius floor
· whether nesting (depth > 1) is ever wanted · the walk's exact form.
