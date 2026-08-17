# Driver — NEIGHBOURS (installed-addon audit, collated)

_Analyst, 2026-08-17. Five blind auditors, one per neighbour, read the addons AS INSTALLED on this
client (3.3.5 Ascension), reporting mechanism with `file:line` and closing every section with
REUSABLE MECHANISM / POSTURE NOT TO INHERIT. Raw reports, unedited:_

    audit/addon_weakauras.md          the conditional machine (D-1's model)   596 lines
    audit/addon_tomtom.md             positional sequencing / arrival ring    360
    audit/addon_pfquest_gathermate.md shipped position DB, pins, detection    213
    audit/addon_dbm.md                encounter state; mechanism vs knowledge 307
    audit/addon_loggers.md            CLEU at volume (Recount/Details/Skada)  347

⚠ **Client FACTS live in `operations/ROUTER.md`, not here.** Where a neighbour's mechanism reflects
what stock 3.3.5 lacked rather than what THIS fork has, the ROUTER wins — e.g. `C_Timer` exists
(ROUTER:75-76), CLEU is the varargs tuple and `CombatLogGetCurrentEventInfo` is furniture (:93),
boss engagement is an event + token poll (:96), two position APIs with differing arg order (:103),
`UnitPosition` does not exist (:105). Neighbours are read for SHAPE; the ROUTER for what the
client actually offers.

_This file collates: §1 mechanisms that CONVERGE across neighbours (the strongest signal) · §2
per-neighbour verdict in one paragraph · §3 what none of them do (the gaps we own) · §4 the
consolidated NOT-TO-INHERIT list · §5 how it reads against Battlewrath's D-1 rules. Data and
labelled positions; no rulings._

---

## 1. CONVERGENT MECHANISMS — independently arrived at by more than one neighbour

| # | mechanism | WA | TomTom | pfQuest/GM2 | DBM |
|---|---|---|---|---|---|
| 1 | **Event → dirty flag → drain once per OnUpdate.** Events set flags; one frame pass does the work. WA BuffTrigger2 `matchDataChanged` → `UpdateStates` per OnUpdate; GT aggregates "did anything change" per aura per event; pfQuest quest.lua event→flag→throttled drain with a typed change queue; GM2 heavy rebuild at 2 s + light per-frame re-place gated on movement. | ✓ | — | ✓ | — |
| 2 | **Index by event, O(1) miss.** WA `loaded_events[event][id][trigger]` with an extra key for CLEU subevent; DBM single event frame + per-event subscriber list + "call the method if defined". Nothing iterates everything on every event. | ✓ | — | — | ✓ |
| 3 | **Arm predicate compiled once; re-evaluate only on the events that can change it.** WA `loadEvents[event][id]`, tri-state armed store, "changed count" gate; DBM LoadOnDemand by zone from TOC metadata on `ZONE_CHANGED_NEW_AREA`; GM2_Data LoadOnDemand + import-then-free. | ✓ | — | ✓ | ✓ |
| 4 | **Create the object at arm, tear it down at disarm; state confined to what is armed.** WA `EnsureRegion` at load, `wipe(triggerState)` at unload, `Private.SetAllStatesHidden`; DBM `mod:Stop()` cancels timers + unschedules by owner. | ✓ | — | — | ✓ |
| 5 | **Self-stopping OnUpdate.** WA `RegionPrototype` FrameTick starts/stops on subscriber count; WA scanner queue and thread scheduler hide themselves when empty; TomTom installs its ring poll only while a marker exists. **Counter-example inside WA itself:** Animations.lua's OnUpdate is never torn down. | ✓ | ✓ | — | ✓ (heap on OnUpdate) |
| 6 | **Own scheduler on OnUpdate.** DBM min-heap with owner-tagged tasks and mass-unschedule; WA budgeted thread pools in `debugprofilestop` units; pfQuest debounced rebuilds. ⚠ This is the NEIGHBOURS' posture (written for stock 3.3.5), NOT a client fact: **`operations/ROUTER.md` records that `C_Timer` EXISTS on this fork and `C_Timer.After` is frame-driven, the same clock as an OnUpdate accumulator (measured, `records/20260816_160953_117__timers.json`).** The reusable part is the OWNER-TAGGED, MASS-CANCELLABLE scheduling shape, not the avoidance of `C_Timer`. | ✓ | — | ✓ | ✓ |
| 7 | **Two radii on one position, transition-fired.** TomTom ring list (clear 10 / arrive 15, act on ring-index change); GM2 distance-banded pin state (icon→circle→fade→drop). | — | ✓ | ✓ | — |
| 8 | **Refuse the unbounded firehose at authoring time.** WA refuses unfiltered CLEU triggers outright — not throttled, not accepted (GT:1842-1846 "We don't register CLEU events without parameters anymore"; :1906-1908 "very performance costly"); DBM registers CLEU per mod and stops everything on encounter end. **Battlewrath: WA is the source for filtering — they explicitly forbade unfiltered.** For us that lives in the EDITOR's flatten: a `boss` child must carry a name; the consumer only ever receives `UNIT_DIED` + one dest name; the format cannot express the firehose. | ✓ | — | — | ✓ |
| 8b | **CLEU dispatch = ONE registration → table lookup keyed by the SUBEVENT STRING → handler.** WA (`loaded_events[CLEU][subevent]`), Recount, Details, Skada — all four, independently. Nothing before the lookup in Details; on/off flag + ignore-table first in Recount/Skada. **The strongest single convergence in the audit.** Only Skada UNREGISTERS CLEU as a runtime policy (`Core.lua:1305-1316`) — the model for "only while armed". Nobody bounds cost per event; cost lives in gating, 1 s tickers, table pools. | ✓ | — | — | ✓ + all 3 loggers |
| 8c | **Death = `UNIT_DIED/DESTROYED/DISSIPATES` aliased to one handler, attributed by DEST.** All three loggers; Skada's log-only "did the flagged creature id die" (`Core.lua:4029`) is the one reusable line for a named-unit death. Boss identity = creature-id lists everywhere (LibBossIDs / per-zone tables) with four different GUID slicers; nobody uses `INSTANCE_ENCOUNTER_ENGAGE_UNIT` or `UnitClassification`. | — | — | — | ✓ + loggers |
| 8d | **Encounter window from the log alone = OPEN on the log, CLOSE on a 1 s `UnitAffectingCombat` poll across the group.** All three loggers and DBM's wipe poll converge; none trusts `PLAYER_REGEN_ENABLED` alone. Skada's tentative segment (5 accepted events within 1 s) is a bounded log-only fight filter. | — | — | — | ✓ + loggers |
| 9 | **Runtime-derived yard scale, never a shipped table.** TomTom + GM2 via `C_WorldMap.GetWorldPosition`; pfQuest-ascension is the counter-example (hand-shipped yard table with duplicate keys). | — | ✓ | ✓/✗ | — |
| 10 | **Integer-packed position as identity/wire form.** TomTom `floor(x·1e4)·1e4+floor(y·1e4)`; GM2 one integer per node with floor in the low digits; sortable, string-safe, diffable. | — | ✓ | ✓ | — |
| 11 | **Replay the arming event on arm** so state is correct immediately (WA "Replay events that lead to loading" + `force_events`); DBM `combatInitialized` 1.5 s guard against reload-in-combat false engage. | ✓ | — | — | ✓ |
| 12 | **Dedupe / anti-spam on side effects.** DBM `AntiSpam(window,id)`, bar identity `name\targs`; WA post-login squelch window (10 s) for actions/sounds. | ✓ | — | — | ✓ |

Convergence reads: neighbours agree on *how a conditional machine stays cheap* (#1–#6, #8, #11)
and on *how positions are keyed and scaled* (#9, #10). They do NOT converge on arrival — only
TomTom and GM2 have any (#7), and both are transition-fired with no hold.

---

## 2. PER-NEIGHBOUR VERDICT

**WeakAuras — the machine, at source.** Compiled load predicate + event-keyed re-scan; trigger
systems pluggable; `loaded_events[event][id][trigger]` with CLEU one level deeper and two early
exits; per-trigger `state` with `show`/`changed`, evaluated in ONE pass (`UpdatedTriggerState`),
regions created at load and collapsed at unload; deferred re-entrant dispatch queue; login as a
budgeted coroutine; import = serialize→compress→encode with `Modernize` on the way in. Its own
hazards are instructive: events are never UNregistered once registered; prototype watchers have
`loadFunc` but no `unloadFunc`; Animations' OnUpdate never stops; a profiling string concat sits
on the hot path even with profiling off. **Verdict: the model for D-1 as ruled — copy the shape
of arm/index/dirty-flag/one-pass/confine; do not copy the always-on edges.**

**TomTom — arrival ring, dead indoors.** No position math of its own (client-shipped Astrolabe →
`GetWorldPosition`, 2D, no Z); minimap icon and arrow HIDE on `IsInInstance()` — the pipe is dead
in dungeons by design (the auditor notes the repo's own probe F8 shows `GetPlayerMapPosition`
returning real fractions in Ragefire, so it is product posture, not API). Arrival = ring-list
state machine, transition-only, 0.1 s throttle, no hold/hysteresis; "next" = nearest-by-yards,
no order, no skip, no visited state; never touches the supertracker; public API takes a
caller-supplied `distance = {[yards]=fn}` callback map. **Verdict: one reusable SHAPE (ring +
transition + `(uid, radius, dist, lastDist)` callback); nothing reusable for the in-instance
case; and it re-implements a beacon the client already has.**

**pfQuest (+ascension) / GatherMate2 — a shipped position DB, and what it costs.** ~75 MB of Lua
loaded wholesale; zone keys matched by LOCALISED NAME; a hand-shipped yard table with collisions;
baked per-map offsets; greedy nearest-neighbour as the "route" (order emergent from position,
re-flips as you move); completion by locale-pattern parsing of quest text; **no position-based
completion at all**; instances treated as outside the product. GM2 is the tidier half: integer
node key + inline squared-yard radius test with FLOOR EQUALITY ("what is near me on this floor"),
two-rate minimap loop, runtime-derived yard sizes, distance-banded pin state, base+diff patch
pack with a sentinel delete. **Verdict: the data-economy neighbour shows both the cheap idioms
(integer keys, buckets, dirty rebuilds, LoD + free) and the exact posture we refuse (per-dungeon
authored node lists, name-keyed identity, shipped scale tables).**

**DBM — encounter state; the mechanism/knowledge line drawn sharp.** On THIS client DBM uses no
boss-unit API (no `boss1..5`, no `INSTANCE_ENCOUNTER_ENGAGE_UNIT`): engage = `PLAYER_REGEN_DISABLED`
→ scan `target`/`partyN-target` GUIDs for an AUTHORED creature ID + `UnitAffectingCombat`; end =
CLEU `UNIT_DIED` on authored cIds or a group wipe poll (3 s/5 s two-pass, <30 s = not a pull);
boss identity = cId parsed from GUID (nibble 5, hex 9-12); mods LoadOnDemand by zone from TOC
metadata; own min-heap timer; announce dedupe/anti-spam; sync trusts any peer. **Verdict: the
Core is a fully generic engine parameterised by authored `(cId, spellId, string, duration, zone)`
tuples — every boss file is 100 % knowledge.** ⚠ Apparent conflict with our capture: our
`capture.lua` uses the engage event + boss tokens and `rfc_combat` measured them live. Both true:
DBM was written for stock 3.3.5 and never reaches for what Ascension exposes. Consequence: the
event is Ascension-only (fine for the audience) and DBM's target-scan + wipe-poll is the documented
FALLBACK SHAPE if it is ever absent. Side findings for the drive: `DBM-HelpFunctions.lua` not in
TOC; Party TOCs reference `MythicChampion.lua` while the file is `Mythic_Champion.lua`; a `return`
-for-skip bug at `Core:1810`.

**Loggers (Recount / Details / Skada) — CLEU at volume, and the same skeleton three times.**
One registration → subevent-string table lookup → handler (rows 8b–8d). Args: Recount and Skada
positional varargs (Recount adds a per-event tail-call shim, being a 4.1 build); Details calls
`CombatLogGetCurrentEventInfo(...)` WITH varargs forwarded — the ROUTER says the bare call is
furniture on this fork; the forwarded-args behaviour was NOT verified by the auditor. Death by
dest; boss by creature-id lists; no per-event cost bounding anywhere; clocks `GetTime()` for
deltas / `time()` for labels (Skada pairs both per event); segments open on the log, close on a
1 s group `UnitAffectingCombat` poll. Self-measurement: Details opt-in `debugprofilestop`
profiler; Skada memory only; Recount none. **Verdict: for "listen for ONE named unit's death,
only while armed" the reusable line is Skada's — register CLEU on arm, subevent lookup, dest
creature-id (or name) equality, UNREGISTER on disarm — and nothing else from a damage meter.**

---

## 3. WHAT NONE OF THEM DO — the gaps this project owns

- **Position-based completion inside instances.** TomTom hides; pfQuest has none anywhere; DBM
  is combat-state, not position; WA has range/proximity triggers but no waypoint model. The
  in-dungeon "you are within R of a sampled place, on this floor" acceptance is ours alone.
- **An AUTHORED order.** TomTom and pfQuest sequence by nearest; DBM sequences by authored
  timeline per boss; WA orders nothing. A route as an ordered graph of positions with a ratchet
  has no neighbour.
- **Height as a sampled fact.** TomTom/pfQuest ignore Z; GM2 uses floor equality only; DBM has
  no position. Band-on-a-sampled-z is ours.
- **Using the client's supertracker as the arrow.** TomTom bypasses it; nobody else touches it.
- **A route + dataset economy that is NOT per-dungeon authored content.** GM2_Data and
  pfQuest-ascension are exactly the shipped-knowledge model §17 refuses; the "seed once from a
  read, carry forever, no dataset needed to run" shape has no neighbour.

---

## 4. CONSOLIDATED — POSTURE NOT TO INHERIT (across all four)

- Never unregistering events / one-way arming (WA GT; WA prototype watchers).
- Always-on OnUpdate frames (WA Animations; TomTom's per-frame arrow recompute).
- Hot-path string building for diagnostics with diagnostics off (WA GT profiling labels).
- Fire-on-first-sample arrival with no hold/hysteresis; outward re-fire (TomTom).
- Nearest-as-successor; newest-wins-on-add; no visited state (TomTom, pfQuest).
- Localised-name identity for zones/nodes/bosses (pfQuest, GM2 collector, DBM boss names).
- Hand-shipped yard/scale tables and baked coordinate offsets (pfQuest-ascension).
- Per-dungeon authored content of any kind: node lists per floor (GM2_Data), unit/object lists
  (pfQuest-ascension), creature IDs / yells / timers per boss (every DBM mod).
- Retail-3.3.5 class/talent constants on a custom-class server (DBM spec inference).
- Trusting any peer's state (DBM sync); usage-census pings (pfQuest-ascension).
- Title as identity key; no version stamp on SV or wire (TomTom).
- Treating instances as "outside the product" while shipping instance data anyway (pfQuest).

---

## 5. READ AGAINST D-1 (Battlewrath's rules for the machine)

    "do what is cheap frequently"           #1 dirty flags per event; #2 O(1) index miss;
                                             #7 transition-fired rings; GM2 inline squared test
    "do what is expensive when needed"      #3 arm predicates re-evaluated only on their events;
                                             #4 create-at-arm / tear-down-at-disarm; DBM LoD by zone
    "take the direct path to the info"      #9 runtime scale via the client, never a table;
                                             DBM cId from GUID; WA replay-on-arm (#11)
    "API > CLEU, but not a limit"           WA refuses unfiltered CLEU and indexes by subevent
                                             (#8); DBM's fallback shows what to do when the API
                                             is not there; our engage event is the API path
    "non-invasive, arm conditions"          #4 + #5 confinement and self-stopping loops; the
                                             WA/DBM counter-examples show what invasive looks
                                             like when it is not designed for

> **Posture (Battlewrath, 2026-08-17): we are built for CoA.** Using a fork-native feature when it
> reduces the project's computational needs is correct — the engage event, `GetCurrentPlayerPosition`,
> `C_Timer`, `SetSuperTrackedPosition` — and portability to stock 3.3.5 is NOT a design constraint.
> ⚠ "Slot" is NOT a thing (Battlewrath): the supertracker is a reachable FUNCTION that accepts any
> source, plus a plain global holding the last write. No ownership, no lock, no handover — which is
> what W6 measured (overwrite instantaneous, "the pin only cares about being set").
> "That's not shyness." Neighbours' fallbacks (DBM's target-scan/wipe-poll, TomTom's re-implemented
> beacon) are recorded as fallback SHAPES, not as things to build.

**Analyst's position, labelled:** the neighbours confirm the D-1 ruling at source — WA's shape
is the right one — and they sharpen it in one place the ruling did not name: **the machine's
edges must be TWO-WAY** (register/unregister, arm/disarm, start/stop) or it is not non-invasive,
whatever its interior looks like. Every hazard found inside WA and DBM is a one-way edge.

---

_Report status: all five neighbours complete (loggers landed on re-run; the first attempt was
cut by a session limit)._
