# CLEU on this fork — the study, the probes, and the decision

_2026-08-13. Addons bench. **Decision: PUSH with a lean mask.** Evidence-backed on this client
rather than assumed, which is the point of the note._

⚠⚠ **2026-08-16 — THIS DECISION MAY BE SUPERSEDED, AND IS NOT OVERTURNED HERE.**

> *"We already suggested some logging for kills in a run (what was included in the pull). But
> ideally I'd off-load it to combat loggers and just piggy back cheaper on run-time."*

★★ If a poll of another addon's segment can report **what died in a pull**, the listener this file
argues for may not be needed at all — and **the cheapest CLEU listener is one we never registered.**
⚠ The measurement below stands: a lean masked arm sat at or below the no-listener arm, so cost is
not the argument. The argument is that a thing we never registered cannot break when the client
changes. ☐ Confirm what a segment actually exposes first — `planning/timed_breakdown_scope.md`.

---

## Why this exists

`COA_DungeonRun` holds *what died in a pull* as a wanted thing, and that needs `UNIT_DIED`, which
means `COMBAT_LOG_EVENT_UNFILTERED`. The addon deliberately has **no CLEU listener** — DR-31 and
DR-32 are one rare event each, and DR-32 reads the client's own DeathRecap rather than running a
second listener. Battlewrath: *"we've skirted around the CLEU. And we've used it. But I don't think
pushed it to be as lean / efficient as we can make it, with tightened filtering and such. Basically
building masks for the data to fall through."*

**The "no CLEU" rule was a COST CLAIM, and cost claims are testable.** So it was tested.

His method, and the ordering is deliberate: *"look at prior work on this branch of WoW... study how
it's done from different projects. Then determine best-fit. **Then** we look at cadence and
consumption need."* Consumption need **last** — study the space before defining the requirement,
which is the opposite of choosing the pattern you had already decided on.

## What the fork DECLARES — a full retained-buffer API

`APIDocumentation/Documentation/CombatlogDocumentation.lua` declares a whole `CombatLog` namespace:

| | |
|---|---|
| `CombatLogAddFilter(events, srcGUID, srcMask, destGUID, destMask)` | richer than the 3-arg form Blizzard's own log calls |
| `CombatLogGetNumEntries(ignoreFilter)` | **filtered vs total count, one call each** |
| `CombatLogGetCurrentEntry(ignoreFilter)` | the full 8 fields + varargs |
| `CombatLogAdvanceEntry(count, ignoreFilter)` · `SetCurrentEntry(index, ignoreFilter)` | a cursor, with random access |
| `CombatLogGetRetentionTime()` / `SetRetentionTime(seconds)` | |
| `CombatLogClearEntries()` · `CombatLogResetFilter()` | |
| `CombatLog_Object_IsA(unitFlags, mask)` → bool | the flag test **below Lua**, not `bit.band` in ours |

That reads as a **pull model**: walk a retained buffer on your own cadence, with the mask applied
below Lua. It would have decoupled cadence from event rate entirely.

## The probes — read-only, cheapest first

All via `/coadump r dump`, landed with provenance.

| record | probe | result |
|---|---|---|
| `20260813_182140_299` | do the six functions exist | **all six `function`** |
| `20260813_182855_357` | counts + retention, **in combat** | **50 total · 18 filtered · 300 s** |
| `20260813_183449_998` | count, **in combat** | **5** |
| `20260813_183832_400` | `LoggingCombat()` + count | **off · 0** |
| `20260813_184700_333` | same, **with logging ON** | **on · 0** |

### ★ The finding: the buffer is not a history

**In combat it held 50, then 5. With logging on it held 0.** ALC's own comment puts a raid pull at
*thousands of events per second*. So `RetentionTime = 300` is a **maximum age, not a promise about
contents** — whatever the mechanism (drained by the client's own log as it renders, or never filled
for a Lua caller), **at the moment you read it there is nothing there to walk.**

Walking it on a 1/s cadence would have been **lossy by construction and silently so** — a
plausible-looking subset, which is the worst failure shape this bench has.

### And a second finding, incidental but load-bearing

**50 total vs 18 filtered means a filter was ALREADY SET** — almost certainly Blizzard's combat log,
from the user's own UI settings. So `CombatLogAddFilter` is a **live shared singleton**. Calling it
would change what the user's combat log window shows: the same shape as `SetMapByID` mutating the
shared world map, which DR-34 called a **we-don't, not a we-can't**.

## Prior art on this exact client

Every CLEU consumer installed, read in place rather than recalled — the same authority rule as
reading the installed WeakAuras for DR-1.

**Three damage meters — Recount → Skada → Details! — are the same job three times**, each written
partly because the last was too heavy, so they show the answer evolving rather than three opinions.
Plus DBM-Core (must-not-miss), WeakAuras (always-loaded-cheap), PlateBuffs/TurboPlates (narrow
interest), and **AscensionLogsCompanion (fork-native)**.

**★ NOT ONE of them calls `CombatLogAddFilter`.** Zero users across all six. For the portable addons
that could be explained by portability — they must run on stock 3.3.5 too, and we only ever run
here — but combined with the probes it is not a close call.

### ★★ ALC's profiled finding, which is the useful one

`AscensionLogsCompanion` is fork-native, and two of its comments are worth more than its code:

> *"We intentionally do NOT scrape COMBAT_LOG_EVENT_UNFILTERED for boss names on every event. That
> would process thousands of events/sec in raid combat for what is already adequately covered by
> target/mouseover detection."*

> mouseover detection was removed because it *"added baseline allocation pressure (UnitName + lower)
> for ~zero detection benefit once combat is live. Was a meaningful contributor to mid-fight GC
> pressure reported by Nace's ZG report 7976."*

**So on this client the cost is ALLOCATION, not call count.** Someone profiled it here and the killer
was `UnitName` + `lower` per event, not the calls themselves. That gives "lean" a concrete target
rather than a feeling.

Their handlers match: two separate registrations, each opening `local _, subEvent = ...` and
returning immediately on mismatch. Their Telemetry keeps a hostile-NPC ledger via `bit.band` on the
object flags.

*(Also: their `RELAY_FAILEDTYPE_ARG_INDEX = 12` carries "validated via /alcprobe on 2026-04-30... if
a future client patch shifts args, re-run the probe." The same probe-don't-recall discipline, arrived
at independently.)*

## ⚠ The disk objection, which closes the logging-gated routes

Battlewrath: *"Isn't combat logging expensive in its own right. And presumptive of the users disk?"*

**Yes — and it inverts the comparison.** Calling the offline `/combatlog` join "free" was counting
cost on OUR side of the line only: what pays for it is the client writing every combat line to disk
and a log file growing without bound on the user's drive. **Dodging a per-event Lua call by making
the client do full disk I/O is backwards, and it is their disk.** It also collides with
design-for-the-everyman: requiring `/combatlog` locks out everyone who does not already log.

## ✅ THE DECISION

**Push, with a lean mask.** Register `COMBAT_LOG_EVENT_UNFILTERED`, unpack the subevent, compare,
return, **allocate nothing in the hot path**. Flag masks via the `COMBATLOG_OBJECT_*` constants when
a subevent survives.

Not because it is the only option — because the alternatives measured worse **here**:

| | |
|---|---|
| retained buffer | empty when read, in five samples across four conditions. Lossy by construction |
| `CombatLogAddFilter` | a live shared singleton — it is the user's combat log |
| logging-gated anything | costs the user disk I/O and an unbounded file to save us a call |

## ✅✅ MEASURED (2026-08-13) — THE COST OBJECTION IS RETIRED

Two runs of his control segment: *"pull from the start of SFK to the boss. Kill them all. Repeat."*

| | `none` (no listener) | `count` | `masked` |
|---|---|---|---|
| **run 1** `20260813_192057_270` | **194.3 kb/s** | 204.4 kb/s | **190.5 kb/s** |
| **run 2** `20260813_194657_186` | **178.8 kb/s** | 180.3 kb/s | **178.8 kb/s** |
| lines/s median · p90 · **peak** | — | 4 · 23 · **57** | 4 · 29 · **82** |

**Run 2 is within 0.8% across all three arms**, and in both runs the *masked* arm sits at or below
the arm with no listener at all. The client and the user's other addons churn ~180-200 kb/s
regardless; **a lean handler does not register against it.**

### ★ And the premise it was built on does not survive dungeon scale

ALC's *"thousands of events/sec"* is **raid** combat, 25 players. A dungeon here peaks at **57-82
lines/second** across two runs — two orders of magnitude below the number the objection assumed.

> **TL;DR (his): our use is nothing compared to the general runtime, and we can move freely. We just
> keep a test on WHY we need it.**

⚠ **Cost stopped being the gate; PURPOSE still is.** Cheap is what makes things easy to add, and
§55's line does not move: a listener that drifts into damage analysis is out of lane whatever it
costs. The burden moved from *can we afford it* to *why do we need it* — his original ordering
arriving, with **consumption need still the unanswered step.**

### ⚠ What these runs do NOT establish

- **Mask yield (~1%: 16/1615 and 15/1099) is CONDITION-SPECIFIC.** Deaths arrived clustered at pull
  end in these segments, and that is a property of *this control*, not of pulls — Battlewrath: *"real
  pulls can be a big burst or a trickle."* The allocation and line-rate figures do not have that
  problem; those are continuous.
- **Neither run was COMPARABLE by the harness's own check.** Run 1 voided on pull counts (2/0/1, a
  late arm switch), run 2 on segment durations. **A rate does not need the errands to match, only the
  arm to have been live**, which is why the answer stands — but the TOTALS in these records must not
  be read as a comparison.

### ⚠ Three faults in the instrument, all mine, the last one left in on purpose

1. **`kbDelta` was broken as designed.** `collectgarbage("count")` is heap IN USE, so a GC cycle
   inside a segment makes end-minus-start negative regardless of what was allocated — run 1 duly
   reported `count = -13248kb`. Now the **sum of positive per-second rises**, collections counted
   rather than subtracted, reported as a rate.
2. **Per-event timing was ruled out on a raid-scale assumption.** At 82/s with `debugprofilestop`
   measured here at **0.094 µs a call**, it was affordable throughout. Not folded into the existing
   arms — that would stop them being the shape under test — but available as a fourth arm.
3. **⚠ KNOWN-WRONG AND LEFT IN: the 25% duration guard.** It voided run 2, whose arms matched on
   pull count and whose rates agreed to 0.8%. The threshold predates the summary reporting **rates**,
   and a rate is already duration-normalised. The right rule is **sample sufficiency, not duration
   matching** — pull count stays strict, because that genuinely is the errand. Left as a note because
   the instrument's job is done and a guard nobody is using is not worth a build.
   **Fix it before the next run, not after.**

### A claim I made and had to withdraw

That deaths clustering at pull end meant combat-end catches the whole burst. **That was our test
condition, not a fact about pulls.** The useful half survives on a better justification: **combat-end
is after every death that belonged to that combat BY DEFINITION**, which holds for a trickle as well
as a burst. The observation was doing work it did not need to do, and that was the part that could
not generalise.

## ★ FINDING THE LISTENER WITHOUT DIGGING — and the bench already had two

`emit_addon_census.py` flags **HOT events** — combat-frequency registrations — on its console line
and in `maps/addons/frame_cost.md`, above the general event list. Battlewrath: *"so long as we know
where to address it without digging."*

⚠ **An event only joins that list once it has been MEASURED.** Currently the two combat-log events,
at 57-82 lines/second here. Seeding it with `UNIT_AURA` or `UNIT_HEALTH` on a hunch would make the
flag mean *"someone thought this was expensive"* rather than *"this is the event we measured"* — and a
flag that means the first thing is a flag people learn to skip.

**It found two on its first run, and corrected something this note implied:**

| | |
|---|---|
| `COA_PetGrid/feed_live.lua` | a **live product**, registering CLEU in its `start` and clearing it with `UnregisterAllEvents` in `stop` — transient, the same discipline as our OnUpdates |
| `COA_DevDump/task_petlog.lua` + `task_cleu.lua` | capture tasks, session-scoped |

**So "no CLEU listener" was a COA_DungeonRun property, not a bench stance.** DungeonRun would be the
bench's *second* shipped listener, not its first, and PetGrid's transient registration is the
precedent for how.

⚠ One honest difference: PetGrid's handler is `pcall(onCleu, ...)` per event — more than the shape
the 178.8 kb/s figure was measured on. That is consistent with the bench's pcall-everything v1
pattern and is not a criticism; it is a reminder that **the number belongs to the handler it was
measured on**, not to the event.

## What is parked, and what would overturn this

- **The in-depth run OFFER** (his): an opt-in mode capturing as if a full parser, keyed on time and
  unit count across a whole dungeon. **Out of scope**, and parking it costs nothing — **DR-4's wall
  clock is already the join key** it would need, on every point since the first run.
- **The offline `/combatlog` join stays alive as OPPORTUNISTIC ONLY.** For someone already logging it
  is zero *marginal* cost, because they are paying it anyway. Never a requirement, never the primary
  path. This finding does not touch it — that reads the disk file, which logging definitely writes.
- **✅ The measurement HAPPENED** — see above; the cost objection is retired. The instrument is
  `/coadump st cleu`. Three arms (`none` / `count` / `masked`) switched in-session, per-second
  line counts and `collectgarbage("count")`, and a comparability check that **voids its own result** if
  the arms were not the same errand. It measures allocation rather than time, for the reason this note
  records: the profiled cost here is GC pressure, and timing a near-empty handler measures the timer.
  The control is his: *"I can pull from the start of SFK to the boss. Kill them all. Repeat."*
  **✅ NEED IS NOW ON RECORD TOO** — `dungeonrun_poc.md` §59: **pull COMPOSITION**, because in M+ each
  unit carries a value toward completing the dungeon, so *was that the right pull* and *could two
  merge* both need to know which mobs were in it. It is the first need that genuinely requires CLEU —
  DeathRecap is only your death, boss tags are only tagged units. **And the assessment stays human:**
  *"we don't touch the assessment... it's the route designer's eye. Pen and paper."*
