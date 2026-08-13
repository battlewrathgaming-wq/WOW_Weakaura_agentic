# COA_DungeonRun — the capture POC

_v0.5.0, built 2026-08-13. **Capture + display stage one.** No beacon, no editor, no comparison.
Spec: `addons/planning/dungeonrun_poc.md`. Facts: `addons/planning/satnav_ledger.md`._

## What it is

**A dungeon route IS a sequence of pulls, so the pulls ARE the route.** Nothing is placed by
hand. You name a run, arm it, and play — combat start and end become the markers, and the path
between them is sampled once a second.

```
/dr                 show / hide the widget
/dr map             show / hide the MAP for where you are (argument-free: macro it)
/dr arm <name>      start recording
/dr stop            close the run
/dr list            what has been recorded
/dr status          is it recording, and is storage healthy
/dr delete <id>     remove a run
```

Everything about *reading* a run happens **offline, against the records**. This addon's whole
job is to write an honest file.

## The design, in one line each

| | |
|---|---|
| **DR-1** | `PLAYER_REGEN_DISABLED/ENABLED` are **edges**; the state is re-read from `UnitAffectingCombat("player")` |
| **DR-3** | travel legs sampled at **1/s, out of combat, inside an instance only** |
| **DR-4** | **both clocks** on every point — `time()` joins, `GetTime()` measures |
| **DR-6** | **record every combat.** No filter, no dedupe, no merge, ever |
| **DR-7** | both entrances: the outdoor point at arm time, the in-instance arrival on zone-in |
| **DR-13** | `dead` on end markers, `ghost` on legs — **without these a wipe and a clean finish are identical** |
| **DR-30** | the instance identity **and difficulty** at arrival, **write-once** — a normal and a heroic pass are different routes |
| **DR-31** | which bosses the route **ENGAGED** — every engagement, never deduped at capture |
| **★ DR-34** | the map's **tile art** at arrival, write-once — without it a run can only be drawn while standing in the dungeon |
| **★ DR-33** | the dungeon **FLOOR** on every point — 42 of 43 multi-floor dungeons stack floors over the same footprint, so it **cannot be recovered from x/y afterwards** |
| **DR-32** | `killedBy` on a terminal stop — distinct attackers from the client's own DeathRecap. **One consumed field**; see `DRIVER_CONTRACT.md` |

## ★ Three things that would fail SILENTLY, and are asserted in the smoke

Run `.tools/lua51/lua5.1.exe addons/tools/smoke/smoke_dungeonrun.lua` — and if you change
anything here, **mutation-test it**: break the guard and confirm the smoke fails on *its own*
assertion. **All twenty guards were verified that way** — and the harness earned its keep:
it found three cases where MY TEST was too weak to tell two bugs apart, not the code.

1. **Trusting the regen edge.** `PLAYER_REGEN_ENABLED` also fires when lockdown lifts for
   reasons that are not a pull ending. A build that trusts it writes phantom markers, and the
   record looks entirely plausible. **Verified against the installed WeakAuras fork** rather than
   recalled — `WeakAuras.lua:1700-1701` registers both events on `loadFrame`, and `:1570`
   recomputes `UnitAffectingCombat("player")` on every scan. The most load-sensitive addon on
   this client never infers combat state from the event that woke it.
2. **An ungated sampler.** Without the out-of-combat and in-instance gates it silently doubles
   the record and fills it with the open world — which reads as *data*, not as a bug.
3. **A missing `dead`/`ghost` flag.** *You cannot find a fault in a field you did not collect.*
   Both are one API read on an event or tick already in hand.

## ★ What we do NOT record, and why

**No boss roster, so no fraction and no missing list.** A route reports *"engaged: Taragaman the
Hungerer"* — never *"2 of 4 bosses"* or *"skipped: Bazzalan"*. Both need a **denominator**, which
is dungeon CONTENT, and content lives out of our data: *"We're not trying to map what exists.
Just what this route dictates."* **Skipped is visible by COMPARING two routes** — the user
supplies the denominator, because they know the dungeon.

**No damage analysis.** `damage`, `school`, `healthPercent` and the crit flag all sit in the
DeathRecap table we read, and we take none of them. Combat parsers serve that lane well. **A
field you do not consume cannot drift under you** — and on this fork, things drift in days.

**No attribution for pulls you SURVIVED.** That would need a combat-log listener running through
every pull of every run. The asymmetry is correct: a survived pull is route *geometry*, which we
already capture in full; a terminal stop is route *meaning*, and that is the only place
attribution changes what the route tells you.

## Why it records so much

> *"Better to be rich and find faults, than lean and never find bounds."* — Battlewrath

Lean capture does not merely lose data — **it never reveals the boundaries of what you are
measuring.** You cannot tell whether a filter is correct if you only ever kept what the filter
let through. So nothing is filtered here; judgement happens offline against the whole set.

**Where "free" stops:** free means *already in hand* — a field on an event we receive anyway, a
branch we decline to take. It does **not** extend to anything needing its own registration,
poll, or scan.

## Frame cost

**Zero when not recording.** The `OnUpdate` is installed by `Capture.Arm` and cleared by
`Capture.Stop`, so `emit_addon_census.py` reports **no persistent OnUpdate** — the standard we
hold other addons to. While recording it is one accumulator compare per frame, and the throttle
sits **before** the work (the census once caught `COA_Landmarks` calling
`GetCurrentPlayerPosition()` 59 times a second and discarding it — the throttle was real and sat
in the wrong place).

## Files

| | |
|---|---|
| `store.lua` | **the only file that touches `COA_DungeonRunDB`.** A rewrite replaces this file, not a search |
| `DRIVER_CONTRACT.md` | what we consume from `AscensionUI.DeathRecap`, and the traps in the fields we deliberately do NOT read |
| `capture.lua` | the events and the sampler |
| `map.lua` | display stage one — our own map frame, floor paging, placement from the captured fraction |
| `widget.lua` | name, arm/stop, live count. Deliberately small |
| `core.lua` | init and the slash surface |

## The test plan is two runs, and the second is deliberately messy

**Run 1** — a clean pass of a simple dungeon; answers the mechanism questions.
**Run 2** — **wipes, re-pulls, corpse runs.** Answers what an editor will have to survive.

> **★ RUN 2 IS A FIXTURE, NOT A FAILED TEST.** Do not discard it and do not re-capture it clean.
> It is the highest-value record this arc will produce, and a messy run cannot be manufactured
> honestly after the fact.

## What the first runs should answer

Written down so the records are *read against a question* rather than admired:

- Does `mapID` change across dungeon **floors**? (A migration if learned after building.)
- Do coordinates **collide** between floors?
- How many markers does a normal run produce — the **density** number?
- Do chain pulls collapse the run to too few markers?
- Is the start↔end **drift** large enough that the waypoint should be derived, not the start?
- Do the legs draw a path that looks right?
