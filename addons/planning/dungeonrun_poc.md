# Dungeon_run — the capture POC (working note)

_Developed in chat with Battlewrath 2026-08-13, written up before any build. **Nothing is
built.** This is the design as talked out, with the facts it rests on and the calls that are
still his. Companion to `landmark_design.md` (the shipped landmark half) and `satnav_ledger.md`
(the fact basis, cited here as `[Fn]`)._

---

## 1. The fork that chose this, and why

Two ways forward were on the table (his framing):

> *"Do we develop the Landmark addon, so that Dungeon_run has more basis for refactoring. Or
> bring Dungeon_run up to parity with Landmark on its understanding and basic function?"*

**Chose Dungeon_run.** The reasoning, because it will need re-checking if the situation moves:

- **Open world is solved outside the map editor** (his read), so "develop Landmark" resolves to
  a single concrete thing: **build the V2 editor.**
- The editor is a **curation-at-scale** surface — search/filter, find one item among many across
  the world. A route is the opposite: **order a handful within one map.** Different shape, so it
  transfers very little.
- **★ THE DIRECTION OF LEARNING HAS REVERSED.** The first increment transferred almost
  everything (capture, storage, beacon control, pins, icons, the arrival model) — which is why
  landmarks-first was right and why it paid. **That transfer is now collected.** What remains
  unproven is what he named: **many-pins and many-updates**, and Landmark *structurally cannot*
  exercise either, because it never does that thing. Further Landmark work would be for
  Landmark's sake — legitimate, but it can no longer be justified as basis-building.
- The density/cadence findings **flow back the other way**: if the pin layer is expensive at
  fifteen markers, Landmark's pin layer learns from it. This direction feeds both.

**"Parity" is explicitly NOT the target.** Tags, owner model, autocomplete, orphan recovery are
solved and exercise nothing new. The minimum that touches the real unknowns is small.

**The editor stays banked and loses nothing by waiting** — it is a self-contained surface over a
storage model that is already settled.

---

## 2. What it is — a route EMITTED from play, not placed by hand

His design, and it is better than the hand-placement shape this was heading toward:

> 1. *"Arm the combat log to capture on combat start and end. The enter and exit markers."*
> 2. *"A field to name the run."*
> 3. *"Automatic capture of the starting zone/subzone (dungeon entrance)."*

**★ AND THE PART THAT DOES THE MOST WORK:**

> *"The capture start to finish in a simple dungeon will self-report the map handling."*

This **retires the floors question and the dungeon-texture question as DESIGN work.** We do not
model floors. We capture a run through a multi-floor dungeon and **read what came back** — if
`mapID` is constant across floors the records say so; if coordinates collide between floors they
say that too. Same discipline as the atlas census and the supertrack probe: emit, then look.

A dungeon route **is a sequence of pulls**, so the pulls are the route.

---

## 3. Mechanism — the edges, then re-read the state

**Not the combat log.** `PLAYER_REGEN_DISABLED` / `PLAYER_REGEN_ENABLED` *are* the enter and
exit markers: two events, no filtering, none of CLEU's cost. Mancer commits its own fights on
exactly that.

**★ VERIFIED AGAINST THE INSTALLED WEAKAURAS FORK** (Battlewrath's challenge: *"Is that the hook
WeakAuras uses for combat start and end?"*). It is — and reading it taught us the better form:

| Where | What |
|---|---|
| `WeakAuras.lua:1700-1701` | both events registered on `loadFrame` — the **Display Load Handling** frame, i.e. the thing that shows/hides auras in combat |
| `WeakAuras.lua:1570` | `local inCombat = UnitAffectingCombat("player")` — recomputed on every scan |
| `Conditions.lua:693` · `Prototypes.lua:990` · `Profiling.lua:303` | same pair, for the `[combat]` condition, the trigger prototypes, and its own profiler's segmentation |

**The pattern is consistent everywhere: EDGES from the events, STATE from the API.** WeakAuras —
the most load-sensitive addon on this client — never infers combat state from the event that
woke it.

So we do the same: **on `PLAYER_REGEN_DISABLED`, confirm `UnitAffectingCombat("player")` before
capturing.** `PLAYER_REGEN_ENABLED` also fires when lockdown lifts for reasons that are not a
pull ending. **Same lesson as AC-24: do not infer the state from the event that woke you — go
and read it.**

It also settles the cost question by demonstration: if WA does not touch the combat log for
this, a route capture certainly does not need to.

---

## 4. What a marker holds

**Both ends, not just the start** — the pair is information we would otherwise throw away, and
it is free:

| | |
|---|---|
| **combat START** | where the pull begins. **This is the waypoint you route to.** |
| **combat END** | where you finished. Fights drift — you kite, you get pulled, you reposition. |

A pull that ends 30 yards from where it started wants its marker placed differently from one
that ends on the spot. **The delta is the finding.**

The gap between **end-N and start-N+1** is the **travel leg** — the connective tissue manual
taps would add later. We capture endpoints; the path between them stays unclaimed.

**Per marker:** the same positional set landmarks capture (`x,y,z` · `mapX,mapY` · `mapID` ·
zone · subZone) plus ordering, plus **both clocks** — `time()` (wall-clock) and `GetTime()`
(monotonic, session-relative). See §7 for why both.

---

## 5. Rulings taken

**★ RECORD EVERY COMBAT, FILTER OFFLINE.** A run includes trash you do not care about — but a
filter invented now would be class-and-content knowledge we do not have, and **emission is cheap
where interpretation is expensive.** Records can always be thinned; a pull we declined to record
is gone. (Battlewrath accepted; same law as `pipeline-emits-class-knowledge-curates`.)

**Chain pulls are one marker pair, and that is CORRECT rather than under-reporting** — his
answer to the concern: *"That's why we capture combat exit also."* The pair bounds the
engagement however many packs are inside it. How it *feels* is a taste read the first captured
run will settle.

**The beacon needs no work.** Proven and sufficient: `[F5]` the beacon **renders inside an
instance** (captured in Ragefire Chasm), and `[F38]` the engine declines across a map boundary,
returning `sd = 0.00` — already handled by AC-24. A dungeon is comfortably inside **same map,
within ~1.5k yards**. His read, and it holds: *"I feel we don't have to engineer that so much."*

**Both entrances captured — a call I made rather than asked, and it is cheap to overturn.**
"Starting zone/subzone" has two readings and `[F38]` says they cannot be one record because they
are different maps: the **in-instance arrival point** (the route's origin) and the **outdoor
position you zoned in from** (how you reach the dungeon at all). Both are nearly free.

---

## 6. Banked — NOT in the POC (his scope)

**Unit deaths inside the combat window**, via the in-game combat log.

**★ A DISTINCTION HE HAD TO CORRECT ME ON, and it is load-bearing:**

> *"Combatlog is a disk function. But we read the in-game combat logging. It's a transient window
> with events."*

| | |
|---|---|
| **`/combatlog`** | a **disk** function — the client writes CLEU to `Logs\WoWCombatLog.txt`. Offline, after the fact, and it requires the user to have turned it on. |
| **the in-game combat log** | `COMBAT_LOG_EVENT_UNFILTERED` — a **transient window of events**. Live or not at all; there is no retrospective read. |

I had proposed the disk file with an offline timestamp join as a *cheaper version* of his
ambition. It is not — it is a different capability. **And it is not a product path:** we cannot
require a user of Dungeon_run to run `/combatlog`. Capturing deaths means **the addon listening
live**, as he framed it. The disk log stays what it is — **a bench instrument**, useful as a
second witness (run both, diff the counts).

**Scope when built (his call): ENEMY deaths.**

> *"When a friendly or their pet, or when the tank died, is product of a bad run. Not the model
> to build a route against."*

Mechanically that is `UNIT_DIED` with `destFlags` carrying `COMBATLOG_OBJECT_REACTION_HOSTILE`.

**Two facts from our own records that this lane must respect:**
- **`CombatLogGetCurrentEventInfo` is FURNITURE on this fork** — the real CLEU is the **varargs**,
  classic 3.3.5 layout, verified positionally across ~4,000 rows (pet-parser pass 1). So
  `destFlags` sits at a known offset rather than something to discover.
- **`UNIT_DIED` never fired for any of 71 pets** (overwrite despawn is CLEU-silent). That was
  *pets*, so it may not apply to enemies at all — but it means the death lane gets **verified,
  not assumed.**

**★ DECIDED — RECORD ALL DEATHS, MODEL ONLY THE ENEMY ONES (Battlewrath, 2026-08-13):**

> *"Record if it's free. Then we can later trim. **Better to be rich and find faults, than lean
> and never find bounds.**"*

The second sentence is the general law and it is worth carrying past this note: **lean capture
does not merely lose data — it never reveals the BOUNDARIES of what you are measuring.** You
cannot find a fault in a field you did not collect, and you cannot tell whether a filter is
correct if you only ever kept what the filter let through.

**Friendly deaths ARE free here, and that is verified rather than assumed:** it is the same
`UNIT_DIED` event on the same listener, so "record all" is one branch NOT taken — no extra
registration, no extra event, no added cost. They simply never enter the route model.
Separately they answer a different question: *"it might be tricky mobs"* is exactly the note
material the in-dungeon landmark half exists for.

**★ WHERE "FREE" STOPS, so this is not over-applied:** free means *already in hand* — a field on
an event we are receiving anyway, a branch we decline to take. It does **not** extend to
anything needing its own event registration, its own poll, or its own scan. Those are captures
in their own right and get argued on their own merits.

---

## 6b. Banked — RUN REPLAY (Battlewrath, 2026-08-13)

> *"Something like a run-replay might be worth it. Not what we're building right now. But I can
> see use as an analysis / replay, drawn on a map."*

**Not built. But it is not purely a display feature — it is a CAPTURE-SHAPE decision, which is
why it appears here and not only in a V2 list.**

**★ ENDPOINTS ALONE CANNOT BE REPLAYED.** Combat start/end gives a **skeleton**: where each
engagement began and ended. Drawing that on a map yields **straight lines between pulls**, which
is wrong in any dungeon with a corridor — the line goes through walls. The travel legs (§4) are
exactly the part we said stays unclaimed, and replay is the thing that claims them.

**And it is irreversible in the same way the timestamp is:** a run captured without the legs can
never be replayed later. Runs already banked stay skeletons forever.

**★ IN THE POC — DECIDED (Battlewrath, 2026-08-13):** *"That fills the dotted line between
capture points a consistent story."* Record the path, do not draw it:

- Sample player position on a **slow fixed tick (~1/s)**, **only while OUT of combat and inside
  an instance**. In combat the marker pair already covers it; outside an instance there is no run.
- A 20-minute run is **~1,200 points**. Trivial as data, and it *is* the path.
- Frame cost is effectively nil and it **self-clears when the run ends** — the same lifecycle
  discipline `beacon.lua` now holds, and `emit_addon_census.py` will witness it either way.

**★ AND IT CHANGES WHAT A RUN *IS*.** Markers alone are a list of events; markers plus legs are
a **continuous record** — which means a captured run is legible **without the beacon at all.**
Replay becomes a product of CAPTURE rather than of routing, and it stays useful even if the
§8 gate never opens on shipping a route pointer.

**This is record-all-filter-offline again** (§5): recording the legs is cheap, drawing them is
deferred, and the decision only has to be right *before the first run*.

---

## 6c. ★ A STRONGER DEATH SIGNAL — the client already computes it (Battlewrath, 2026-08-13)

> *"There is a stronger death signal. I can capture the frame or we can read it. On death there
> is a 'what killed me' page, with a readout of events surrounding it."*

**It exists, and it is better than either option in §6** — read from the extracted client, not
recalled: `Interface/AddOns/AscensionUI/DeathRecap/`.

**What it actually is** (the mechanism matters, because "a page the client shows you" implies
something it is not): a **CoA-authored addon that listens to `COMBAT_LOG_EVENT_UNFILTERED`
itself** and keeps a rolling buffer of the last **14** damage/heal events taken by the player.

| Fact | Where |
|---|---|
| reachable global — `AscensionUI = Addon`, and `Addon.DeathRecap = Recap` | `AscensionUI.lua:3` · `DeathRecap.lua:12` |
| the buffer: `Recap.Events[Recap.CurrentRecap]`, capped at **14** entries | `DeathRecap.lua:154-157` |
| per entry: `eventTime · spell · attacker · isPlayer · damage · school · periodic · crit` **+ `healthPercent`** | `DeathRecap.lua:142-152` |
| folds 8 CLEU types: SPELL/SPELL_PERIODIC/SWING/RANGE/DAMAGE_SPLIT/ENVIRONMENTAL damage **and SPELL_HEAL / SPELL_PERIODIC_HEAL** | `DeathRecap.lua:172-221` |
| `CurrentRecap` increments on `PLAYER_UNGHOST` **and** `PLAYER_ENTERING_WORLD` | `DeathRecap.lua:258-268` |
| on `PLAYER_DEAD` it emits `\|Hdeath:<player>:<id>\|h[You died.]\|h` | `DeathRecap.lua:127, 264` |
| an addon-comm protocol shares recaps: `ASC_RECAP_REQ/SEND/ERR`, serialize → deflate → encode | `DeathRecap.lua:8-10, 23-60` |

**★ `healthPercent` IS THE PART CLEU CANNOT GIVE US.** It is sampled live at the moment of each
event. A raw combat log tells you what damage landed; this tells you **what your health was
doing while it landed** — which is the difference between "a 4k hit" and "a 4k hit at 12%".
And because it folds heals too, it records what nearly saved you.

**It corrects the §6 framing rather than adding to it.** I had said deaths mean *the addon
listening live to CLEU*. They do not: **a client-shipped addon already does that work**, so we
read a computed result instead of running a second CLEU listener. And unlike `/combatlog` this
**is** a product path — `AscensionUI` ships with the client; nothing is asked of the user.

### What it would take, and what it costs

**Read `AscensionUI.DeathRecap.Events[CurrentRecap]` on `PLAYER_DEAD`** and shallow-copy it into
the run's marker. `PLAYER_DEAD` is the correct moment: `CurrentRecap` has not rolled yet — it
increments on UNGHOST and on ENTERING_WORLD, so reading later reads an empty buffer.

Cost: **one extra event registration and a copy of ≤14 small tables, on an event that fires
rarely.** By §6's own boundary that is *not* free (it needs its own registration), so it is
argued rather than assumed — and the argument is that the payload is already computed by
someone else and we are only carrying it.

### Two disciplines this triggers

1. **★ IT IS A CONSUMER RELATIONSHIP, so it gets a DRIVER_CONTRACT** — the same rule
   `MancerLedger/DRIVER_CONTRACT.md` follows: characterise every consumed field from THEIR
   source before inventing a use for it, and fail LOUD on shape drift rather than silently
   recording nothing. We would be reading another addon's internals; they owe us nothing.
2. **★ VERIFY LIVE BEFORE BUILDING.** Every line above is patch-B **as extracted 2026-08-12**,
   and this fork ships changes in days. `/dump AscensionUI.DeathRecap.CurrentRecap` and a look
   at the buffer after one death settles it in a minute.

### Where it lands in the model

**This is the PLAYER's death, so it enriches the WIPE case** — exactly run 2's fixture material
(§9b), and exactly the *"it might be tricky mobs"* note material the in-dungeon landmark half
exists for. **It does not touch the enemy-death lane** (§6), which stays as scoped.

### ★ LIVE-VERIFIED 2026-08-13 — record `20260813_010321_263__dump.json`

**Landed, not transcribed.** First use of `task_dump`, and the record is the authority from here;
the source read was only the lead.

**Confirmed:**

| | |
|---|---|
| reachable | `AscensionUI.DeathRecap` resolved; `CurrentRecap = 5` |
| `Events` | a **1-based array, one buffer per recap** (1–5 present; 1 and 3 empty, 2/4/5 populated) |
| the 14-cap is **REAL** | buffer 4 held **exactly 14** entries |
| the 9 fields | `isPlayer · spell · healthPercent · eventTime · attacker · periodic · school · crit · damage` — **16/16 entries carried all nine** |
| **★ `healthPercent` IS LIVE** | 0.4846 → 0.4519 → 0.4120 → … → 0.2341 across lava ticks. **The architectural claim holds: this is not reconstructible from CLEU.** |

**★ THREE THINGS THE SOURCE READ ALONE DID NOT GIVE ME** — two found in the record, then all
three confirmed at the call sites (`DeathRecap.lua:179-225`):

1. **`damage` IS SIGNED, AND THE SIGN IS THE DISCRIMINATOR.** Every damage path calls
   `AddEvent(..., -damage, ...)`; both heal paths pass `heal` **unnegated**. So **negative =
   damage taken, positive = healing received**, in one field. 16/16 negative in this record
   (he died to falling and lava).
2. **★ `crit` IS POLYMORPHIC — IT IS NOT A BOOLEAN.** Observed `"FALLING"` and `"LAVA"`.
   `ENVIRONMENTAL_DAMAGE` passes **`damageType` into the `crit` slot**
   (`AddEvent(eventTime, 0, "Environment", false, -damage, school, false, damageType)`).
   **A consumer treating `crit` as a boolean gets a truthy string on every environmental
   entry.** This is exactly what a DRIVER_CONTRACT exists to catch.
3. **`spell` encodes the SOURCE KIND:** real id for spells, **`-1` for melee** (`SWING_DAMAGE`),
   **`0` for environmental**. And **`absorbed` is folded into `damage`** — it is the *effective*
   amount, not the raw landed number.

**★ AND THE DUMP IS SELF-ACCUMULATING, which changes the capture workflow.** `Events` holds
**every** buffer, so **one dump after several deaths captures them all** — there is no need to
dump per death. Battlewrath ran the command four times and only the last envelope survived (the
mailbox holds one, and SavedVariables flush on `/reload`), and **it cost nothing**: all four
deaths are in that single record.

**⚠ THE GAP, and it is the one that matters for a route: every death was ENVIRONMENTAL.**
`attacker` was `"Environment"` 16/16 and `spell` was `0` 16/16, so these remain **unexercised**:

- what `attacker` holds for a mob (a name string, presumably — unverified)
- `spell` carrying a real id, and `-1` for melee
- **`crit` as an actual boolean** — the whole reason finding 2 matters
- `isPlayer` ever true, `periodic` ever true
- **heals appearing as POSITIVE `damage`** — the sign rule's other half

### ★ THE GAP CLOSED — record `20260813_011150_203__dump.json` (mob death, Ragefire)

`Events[CurrentRecap]` at death, 14 entries. **The buffer was FULL.**

| | |
|---|---|
| `attacker` | **real mob names** — Molten Elemental ×7, Ragefire Trogg ×3, Searing Blade Cultist ×2, Searing Blade Enforcer, Earthborer |
| `spell` | **`-1` for melee, 10/14**; real ids for the rest — `2101733`, `2101739`, `2101747`, `975011` (CoA-range) |
| `damage` | 14/14 **negative**, as the sign rule says |
| `healthPercent` | **0.0882 → 0.0111**, a clean death curve. This is the readout the whole thing exists for |

**★★ AND THE FINDING THAT MATTERS MOST: `crit` WAS ABSENT ENTIRELY.** Not false — **the key
does not exist** on any of the 14 entries. `AddEvent` stores `e.crit = critical`, and CLEU
passes **nil** for a non-crit, so the key vanishes from the table. Combined with the
environmental record, `crit` has **THREE states**:

| State | When | Seen |
|---|---|---|
| **absent (nil)** | a non-crit hit from a unit | **live, 14/14** |
| a damage-type **STRING** (`"LAVA"`, `"FALLING"`) | environmental | **live, 16/16** |
| boolean `true` | an actual crit | source only — not yet observed |

**A consumer must treat `crit` as `nil | true | string`, and must not index it blind.** Found on
the first two live reads, which is precisely the job a DRIVER_CONTRACT does.

**★ A SCOPING FACT WITH DESIGN CONSEQUENCE: 14 entries covered ~3 SECONDS.** He entered the
buffer already at 8.8% health. **This is not a fight summary — it is the last breath.** It tells
you *what finished you*, not *what the pull was like*. That is still the right size for a route
marker ("a wipe happened here, to these mobs"), but nothing broader should be expected of it.

**Still unobserved, and all LOW RISK — source is unambiguous, so the contract labels them
SOURCE-DERIVED rather than chasing them:** `crit == true`, `isPlayer == true` (PvP only),
`periodic == true` (DoTs), and heals landing as **positive** `damage`
(`AddEvent(..., heal, ...)` is unnegated at `DeathRecap.lua:214-225`).

**★ The contract can be written now**, with every field labelled **live-verified** or
**source-derived**. That split is the point of the pattern.

**Workflow note:** both commands were run before one `/reload`, so only the second envelope
survived — **one dump per reload.** It cost nothing here (the narrower one held the gap data),
but the whole-table view is the better default since `Events` is self-accumulating.

### ★★ SCOPED — WE TAKE ONE FIELD. THE REST IS SOMEONE ELSE'S LANE (Battlewrath, 2026-08-13)

> *"People can run combat parsers. And they already handle damage taken. That's not our lane.
> **Route forming is.** And if we get into it, **terminal stops** on that route."*

**This is the §8 gate applied to the death lane, and it lands the same way landmarks did:** we
do not compete on what already exists well. `damage`, `school`, `healthPercent`, the crit
flag — that is damage analysis, and Recount, Mancer and Libellus all do it properly.

**★ SO THE STRONGEST THING ABOUT DEATHRECAP IS IN A LANE WE ARE NOT ENTERING.** `healthPercent`
was my whole architectural argument for consuming over capturing — and it is a *damage-analysis*
field. Correct fact, wrong lane. What route-forming wants from a death is far smaller:

> **A TERMINAL STOP: the route ended here, and this is what stopped it.**

**We already hold most of it.** `dead = true` on the end marker plus its position IS the terminal
stop (DR-13). DeathRecap adds exactly one thing worth having: **WHO**. `"Molten Elemental ×7"`
turns *"a wipe happened here"* into *"this pull is where runs die"* — which is route meaning, and
exactly the note material the in-dungeon landmark half exists for.

**★ AND THE DEPENDENCY SHRINKS WITH THE SCOPE, which is the real prize.** Consuming distinct
`attacker` names means we depend on **`Events` · `CurrentRecap` · `attacker`** and nothing else:

| Trap we found live | Now |
|---|---|
| `crit` is `nil \| true \| string` | **moot** — not consumed |
| `damage` sign is the heal discriminator | **moot** |
| `spell` `-1` = melee, `0` = environmental | **moot** |
| `absorbed` folded into `damage` | **moot** |

**Every contract-critical trap we uncovered evaporates**, because a field you do not read cannot
drift under you. The contract goes from a field table to a paragraph, and this fork's
days-long churn stops being a standing risk.

*(The traps stay recorded above anyway — they cost two live captures to find, and the next
consumer of this table, ours or another bench's, should not pay for them twice.)*

**Design consequence for the model:** a route has markers, and **some markers are TERMINAL
STOPS.** That is route structure, not decoration — and run 2, the deliberately messy fixture
(§9b), will be full of them. It is also the first thing an editor will need to trim or keep.

**Gate: `Build!` — not authorised. Not in v0.1.0.**

---

## 7. The things the POC must not get wrong

Both are **irreversible**: everything else in this note can be added later, but these two cannot
be applied retroactively to runs already captured.

**1. Wall-clock timestamps on every marker.** Everything else in this note can be added later. A
run captured without a joinable time reference **can never be joined retroactively** — to the
disk log as a second witness, or to anything else.

`time()` for the join key, `GetTime()` for precise within-session deltas. One field each.

*(Weaker justification than I first gave it: if the addon listens live, the death events arrive
inside the window already and there is nothing to join. The stamps are for the **bench
cross-check**, not the mechanism.)*

**2. The travel legs** (§6b) — **decided IN.** A ~1/s out-of-combat position sample. Cheap to
include, impossible to backfill.

---

## 8. The prerequisite, and why it moved

**★ THE STALE-TARGET BUG IS NOT POLISH — it is on this feature's critical path.** Parked from
the landmark arc (`landmark_design.md` §15, two candidate causes and the one run that separates
them).

**A landmark re-pins rarely** — you pick a place and go. **A route re-pins constantly; that IS
the mechanic.** Advancing to the next marker means setting a position while one is already live,
which is precisely the failing case.

**But capture does not depend on it.** So the order is:

1. **Capture lands first** — no beacon involvement at all.
2. **Read the records** — the map handling self-reports.
3. **Then the beacon work**, resolved against a real recorded route rather than hand-placed
   points.

---

## 9. Still his — nothing open

1. **Widget or the task spine?** He asked for a widget (*"a widget that is all about capture"*)
   with a name field — taken as answered. Noting the alternative only because it is free:
   `/coadump st dungeonrun "Ragefire clockwise"` would land records **today** with zero build,
   the run name as an arg. The widget is friendlier mid-play, and naming a run by slash command
   mid-pull is genuinely worse. **Proceeding on the widget** unless he says otherwise.
2. ~~Friendly deaths~~ — **answered 2026-08-13: record all, model only the enemy ones** (§6).

~~Gate: `Build!` — not authorised.~~ **`Build!` given 2026-08-13 — see §11.**

---

## 9b. ★ THE TEST PLAN IS TWO RUNS, AND THE SECOND IS DELIBERATELY MESSY

Battlewrath, 2026-08-13, matching the build to the intention:

> *"A route is formed through a first capture, and we're doing that in our construction. This
> data might be messy. And I'll make test 2 messy to simulate wipes in the data set. And that
> puts pressure on the editor later."*

| | |
|---|---|
| **Run 1** | a clean pass of a simple dungeon. Answers §10's questions about the mechanism. |
| **Run 2** | **deliberately messy — wipes, re-pulls, corpse runs.** Answers what the EDITOR must survive. |

**★ RUN 2 IS A FIXTURE, NOT A FAILED TEST. Do not discard it and do not re-capture it clean.**
It is the highest-value record this arc will produce, because it is the only one that exercises
the messy case, and a messy run cannot be manufactured honestly after the fact. Keep it, name it
as the adversarial fixture, and test every later editor behaviour against it.

**What "messy" produces, mechanically** — and each is a distinct pressure:

- **Near-duplicate markers** — re-pulling the same pack writes a second start marker metres from
  the first. The editor must **merge or trim**, and it needs to be able to tell them apart.
- **Combat ends that are DEATHS, not disengages** — the run stops mid-route.
- **Corpse-run legs** — travel samples from a graveyard back to the instance, possibly across a
  map boundary `[F38]`, drawn by a naive replay as a bizarre excursion.

### ★ TWO FREE FIELDS THAT MAKE MESSY DATA *LEGIBLE* RATHER THAN MERELY PRESENT

This is §6's breadth law biting on its very next application — *you cannot find a fault in a
field you did not collect.* **Without these two, a wipe and a clean finish are INDISTINGUISHABLE
in the record**, and no later editor can ever offer the trim:

| Field | When | Why it is free |
|---|---|---|
| **player dead/alive at combat end** | on the end marker | one API read on an event we already handle |
| **ghost flag on a travel sample** | on each sample | one API read on a tick we are already running |

Intended mechanism: `UnitIsDead` / `UnitIsGhost` (or `UnitIsDeadOrGhost`) — bedrock 3.3.5, but
**confirm consumption on this fork at build time rather than assuming it**, per the bench rule
that a stored field is not a live one.

Both clear the free bar exactly as §6 defines it: a read on an event or tick already in hand, not
a new registration or poll.

### And it settles a question left open in §1

The pressure run 2 applies is **trim / merge / reorder within one map**. The Landmark V2 editor
is **search / filter across the world**. Different jobs, and this is the second independent
reason to expect **the route editor is NOT the Landmark editor** — which is exactly why building
the V2 editor would not have bought this arc anything.

---

## 10. What the first captured run should answer

Written down now so the run is read against a question rather than admired:

| Question | Why it matters |
|---|---|
| Does `mapID` change across dungeon **floors**? | Decides whether "floor" is a concept in the record. **A migration if we learn it after building.** |
| Do coordinates **collide** between floors? | Same decision, from the other side. |
| How many markers does a normal run produce? | The **density** number the whole pin-layer question rests on. |
| Do chain pulls collapse the run to too few markers? | His taste read on whether the pair is the right unit. |
| Is the start↔end **drift** large enough to matter? | Decides whether the waypoint is the start point or something derived. |
| How many **travel-leg samples** does a run produce, and does the path look right drawn? | Whether §6b's 1/s tick is the correct rate — and the first evidence that replay is worth building. |

**★ THE §8 COMMUNITY GATE IS ABOUT SHIPPING ROUTING, NOT ABOUT LEARNING WHETHER IT WORKS.**
Establishing mechanics is not competing with anyone — it is finding out what we would be
deciding about. Gate stays closed on the product question, open on the probe.

---

## 11. BUILD LOG — v0.1.0 (2026-08-13)

**`addons/COA_DungeonRun/`** — 4 files, 35 functions, **0 persistent OnUpdate**, no hooks.
Registered in `deploy.py`'s MANIFEST (the one authority on residents) and in the bench index.
**Not deployed** — Battlewrath deploys at test time.

| File | Owns |
|---|---|
| `store.lua` | **the only file touching `COA_DungeonRunDB`** — a rewrite replaces it, not a search |
| `capture.lua` | the regen edges, the arrival guard, the 1/s sampler |
| `widget.lua` | name box, arm/stop, live count. Deliberately small |
| `core.lua` | init + `/dr` |

**Everything in §2-§6b implemented as specified — no design drift.** Two carried lessons applied
without being re-learned: the EditBox is **named** (`InputBoxTemplate`'s `$parentMiddle` anchors
`relativeTo` `$parentLeft`/`$parentRight` BY NAME, so a nameless box renders as two floating
end-caps), and the sampler's throttle sits **before** the work, not after.

### ★ Ten mutation tests, and every one bit on its OWN assertion

A green suite proves nothing by itself — AC-26 taught us that when its step fell below a changed
poll floor and it began passing because the code never looked. So each guard was broken
deliberately and the failure message checked:

| Mutation | The assertion that caught it |
|---|---|
| drop the `UnitAffectingCombat` re-read | *DR-1 FAILED: a regen edge was trusted without re-reading UnitAffectingCombat* |
| drop the in-combat gate | *DR-3 FAILED: sampled a leg while IN COMBAT* |
| drop the in-instance gate | *DR-3 FAILED: sampled a leg while OUTSIDE an instance* |
| drop the throttle | *DR-3 FAILED: sampled below the throttle interval* |
| never stamp `dead` | *DR-13 FAILED: a wipe is not distinguishable from a clean finish* |
| never stamp `ghost` | *DR-13: corpse-run legs carry the ghost flag* |
| leave the sampler installed at Stop | *LIFECYCLE FAILED: the sampler outlived the run* |
| drop `local onUpdate` | *LEAKED GLOBAL: onUpdate* |
| make arrival last-wins | *DR-7: arrival is write-once, not last-wins* |
| drop the wall-clock stamp | *DR-4: wall-clock time() stamped* |

The throttle test **exceeds** the interval on purpose, with the reason written into the smoke:
a smaller step would not sample at all, and it would pass because the code never looked.

**★ A PROCESS NOTE, because the harness failed usefully:** it crashed mid-run on a relative exe
path and **left the DR-1 guard stripped from live source.** Caught only because the next thing
run was the smoke rather than a commit. **Mutation testing edits real files — the restore belongs
in a `finally`**, and the harness has one now.

### Still not done, deliberately

No beacon work (the stale-target bug is a prerequisite for **routing**, not for capture), no
editor, no display, no CLEU. **The next move is his two runs**, read against §10.