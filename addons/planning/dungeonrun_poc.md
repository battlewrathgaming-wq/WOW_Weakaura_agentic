# Dungeon_run — the capture POC (working note)

_Developed in chat with Battlewrath 2026-08-13, written up before any build. **Nothing is
built.** This is the design as talked out, with the facts it rests on and the calls that are
still his. Companion to `landmark_design.md` (the shipped landmark half) and `satnav_ledger.md`
(the fact basis, cited here as `[Fn]`).

**★ THIS NOTE COVERS CAPTURE AND DISPLAY ONLY.** Notes, export, import and sharing are already governed by `satnav_ledger.md` **laws 6, 7, 7b, 8 and 9** (SELF vs TEAM notes, import-wipes, disposable-vs-sacred, the persistent bin, notes-live-on-the-map). **Start there before designing anything in that space** — §28.2 has the summary._

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

### ★ BOSS DEATH — record `20260813_012626_775__dump.json` (Taragaman the Hungerer)

**The route-meaningful signal, confirmed.** 14 entries, all one attacker:

| | |
|---|---|
| `attacker` | **`"Taragaman the Hungerer"` 14/14** — the boss names itself |
| `spell` | **four distinct ability ids** — `975011`, `2102513`, `2102515`, `2102516` — plus `-1` melee ×7 |
| the killing blow | **spell `2102515`, `-12022`, taken at 67.6% health** — logged **twice** at the same `healthPercent`, so health had not re-read between them |
| `crit` | still absent 14/14 |

**This is the difference the boss made.** The trash death was `spell = -1` on everything, which
looked like the field held nothing. On a boss it identifies **the mechanic that stops people
here** — *"Taragaman's 2102515 takes you from 68% to dead"* is route meaning, and it is not
damage analysis. **That is the case for `spell` re-entering scope as an ABILITY IDENTITY** (a
name to look up), never as a damage number.

### ⚠ TWO FAULTS IN THE SURVEY, AND ONLY ONE WAS A BUG

**1. A defect in `task_dump` — eight values requested, TWO recorded, silently.**
`{ pcall(func) }` plus `#results` is a trap: a nil anywhere makes the table a sequence **with
holes**, and `#` on that is undefined. Fixed with `select("#", ...)`, which reports how many
values were RETURNED, holes included; a returned nil is now stored as the `"<nil>"` tag rather
than left as a hole, because *"the call returned nil"* is itself a fact. **This was rule 1
("no silent caps") being violated by the tool that declares it** — caught on its second real use.

**2. ★ THE SURVEY ASKED FOR STATE THAT CANNOT EXIST AT THAT MOMENT (Battlewrath):**

> *"Some of it assumes those states are active when dead. Like unit name (requires target, death
> drops target). I wasn't in a group."*

**Death drops your target**, so `UnitClassification("target")` and any boss-token read are nil
**by construction** at `PLAYER_DEAD`. I asked for a reading at the one moment the reading is
invalid — the same error shape as AC-24, where a map-boundary refusal returns a number that
satisfies every tier.

**★ THE RULE THAT FALLS OUT, and it is the important part:
ANYTHING ABOUT *WHAT YOU WERE FIGHTING* MUST BE CAPTURED DURING COMBAT, NOT AT DEATH.**

Which is precisely why DeathRecap works at all: **it buffers during the fight and survives the
death.** So boss identity for a terminal stop comes from the buffer's `attacker` — exactly the
one field §6c already scoped us to. The narrowing was right for a second reason we had not seen.

**Consequence if boss-vs-trash tagging is ever wanted:** sample `UnitExists("boss1")` at the
**combat-START marker** or on `INSTANCE_ENCOUNTER_ENGAGE_UNIT` (present on this fork — event
census, and `TargetFrame.lua:985` registers it; `C_Instance.lua:83` reads `boss1` directly).
Never at death.

### ★★ CLOSED — WE ALREADY HAVE IT, AND THE REST WOULD COST CONTINUOUS LOGGING

> *"We have that in the death recap, no? And to capture the outside events, we have to log for
> them all the time. Which becomes computational weight."* — Battlewrath, 2026-08-13

**Both halves are right, and together they close the attribution question for good.**

`attacker` already names the boss, per death, at zero cost to us — **somebody else's listener
paid for it.** Anything the recap does *not* hold means attribution for pulls we **survived**,
and that requires a CLEU listener running through **every pull of every run**. That is the
computational weight, and it is also the combat-parser lane we deliberately left (§6c).

**★ SO THE ASYMMETRY IS NOT A GAP — IT IS THE CORRECT SHAPE:**

| | Attribution | Cost |
|---|---|---|
| a pull you **died** to | the recap names it | **free** — already computed |
| a pull you **survived** | none | would need continuous logging |

**And that is exactly the right way round.** A successful pull is route *geometry* — position,
order, timing, which we already capture in full. **A terminal stop is route *meaning*, and it is
the only place attribution changes what a route tells you.** We get the information precisely
where it matters and pay nothing precisely where it does not.

*One correction to my own suggestion above, so it is not over-read: registering
`INSTANCE_ENCOUNTER_ENGAGE_UNIT` would be **one rare event, not continuous logging** — the cost
objection does not apply to it. But by the asymmetry above we do not want it either: a boss pull
you survived is just a pull, and a boss pull you died to already names itself.*

**Nothing further is designed for attribution.** — *but see §6d: the ENCOUNTER question reopens
on different grounds, and my reason for closing it was wrong.*

---

## 6d. ★ BOSS ENCOUNTERS — ROUTE IDENTITY, NOT ATTRIBUTION (Battlewrath, 2026-08-13)

> *"I think we can cap their death — that rides in the death/kill watch. Instance encounter
> engage unit sounds like it fits in that. It's an event we can display. And then **the route
> boss count can be shown with names. As some bosses are skipped in runs.** So that all follows
> value add."*

**★ MY REASON FOR DECLINING THIS IN §6c WAS WRONG.** I argued *"a boss pull you survived is just
a pull."* **For route IDENTITY it is not.** A Ragefire run that kills two of four bosses is a
**different route** from one that kills four, and **which bosses were skipped is precisely what
distinguishes one route from another.** That is structure, in the same class as marker order —
not attribution, which is what I had filed it under.

**And the cost objection never applied to it:** `INSTANCE_ENCOUNTER_ENGAGE_UNIT` is **one event
registration that fires rarely**, not continuous logging.

### The bracket, and why it needs no CLEU

The event brackets the fight; **our existing markers supply the outcome**:

| Signal | Source |
|---|---|
| a boss was **engaged**, and its **name** | `INSTANCE_ENCOUNTER_ENGAGE_UNIT` → `UnitName("boss1".. "boss5")` |
| the fight **ended** | the disengage / `boss1` ceasing to exist |
| **killed vs wiped** | our own end marker's `dead` flag (DR-13) |
| **skipped** | a boss that never engaged across the whole run — an ABSENCE, which is only readable because the route records the ones that did |

**No combat log, no polling, no second listener.** *"Their death"* is inferred from the bracket
closing while we were alive — we never watch the boss's health at all.

### ⚠ THE UNKNOWN THAT GATES IT, and it is a real one

**Does the event actually fire in this fork's classic dungeons?** `INSTANCE_ENCOUNTER_ENGAGE_UNIT`
is a **retail-era** mechanism that is present in the client (event census; `TargetFrame.lua:985`
registers it; `C_Instance.lua:83` reads `boss1`). **Presence in the client is not proof the
SERVER populates it for a vanilla dungeon like Ragefire.** Boss frames may simply never appear
there — in which case this whole section is moot and the fallback is the recap's `attacker`,
which we already have.

**★ CHECK IT BEFORE DESIGNING ON IT — same discipline that paid on DeathRecap.** Mid-boss-fight,
one line (and it will now record all three values, since the nil-hole truncation is fixed):

```
/coadump r dump UnitExists("boss1"), UnitName("boss1"), UnitName("boss2")
```

**Requires a redeploy of `COA_DevDump` first.** If `boss1` exists mid-fight, the surface is real
and §6d is buildable. If it does not, this closes for a good reason rather than a guessed one.

### ★★ GATE PASSED — record `20260813_014009_176__dump.json`, mid-fight vs Taragaman

```
UnitExists("boss1"), UnitName("boss1"), UnitName("boss2")   ->   1, "Taragaman the Hungerer", <nil>, <nil>
```

**The server DOES populate encounter data for a vanilla dungeon on this fork.** `boss1` exists
and is named during the fight. §6d is real, not a retail leftover.

Three facts worth keeping:

- **`UnitExists` returns `1`, not `true`** — a 3.3.5-ism. `== true` would fail.
- **`boss2` is nil**, so Taragaman is a single-boss encounter. The token set is sparse; iterate
  `boss1..boss5` and stop caring about gaps.
- **Four values from three expressions is CORRECT Lua** — only the LAST call expands, and
  `UnitName` returns `name, realm`. **The nil-hole fix validated itself in the field on its first
  use:** both trailing nils were recorded instead of vanishing.

**Verified vs inferred, labelled honestly:** the TOKEN is live-verified. The **event firing** is
inferred — it is what drives the client's own boss frames, and the token cannot populate without
it — but we polled here rather than observing the event. Confirm on build; it is one listener.

### ★ AND "SKIPPED" IS A COMPARISON, NOT A LOOKUP — the no-database law holds

His value case is *"some bosses are skipped in runs."* **We can only record what was ENGAGED.**
Knowing what was *skipped* would need the dungeon's full boss roster — **a per-dungeon database,
which this project has refused from the start**: *"all self-authored content rather than me
trying to map every dungeon."* Same law as no tag registry and no character roster.

**It costs nothing, because skipped is visible by COMPARISON:** route A engaged four, route B
engaged two, and the difference is right there in the two records. **The user sees the skip
without us ever owning a roster** — and it stays correct when the fork adds or changes a boss,
which a shipped roster would not.

> **★ RULED (Battlewrath, 2026-08-13):** *"I'd let that content live out of the data. We're not
> trying to map what exists. Just what this route dictates."*
>
> The same law as the scrapbook's *"How I play, not what exists"*, and it binds the **display**
> as much as the storage.
>
> **THE CONCRETE PROHIBITION, because a later editor would add it innocently: never show a
> FRACTION or a MISSING list.** "2 of 4 bosses" and "skipped: Bazzalan" both require the
> **denominator** — content we have refused to hold. A route reports **"engaged: Taragaman the
> Hungerer"** and stops there.
>
> **The user supplies the denominator; they know the dungeon.** We describe the route, not the
> place. Every version of this we have hit — tags, characters, boss rosters — has the same
> answer: **don't acquire the knowledge, provide the path.**

**Noted, not designed:** he also flags it as **displayable live** ("an event we can display") —
a boss-engaged indicator. That is V2 surface, out of the POC.

**Gate: `Build!` — not authorised.**

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

---

## 12. BUILD LOG — v0.2.0 (2026-08-13): the three captures he named

> *"Does the run builder need upgrading to capture the events we've determined of value?"*
> — combat markers · per-second position · map start · death recap · boss encounter.

**Three of the five were already in v0.1.0** (DR-1, DR-3, DR-7). The two that were not are now
built, plus **difficulty**, which he added.

| | |
|---|---|
| **DR-30** | instance identity + **difficulty** at arrival, **write-once**. Signature read from `RaidProfiles.lua:540`, not assumed |
| **DR-31** | boss **engagements** — `INSTANCE_ENCOUNTER_ENGAGE_UNIT` → `boss1..boss5` names, recorded per engagement, never deduped at capture |
| **DR-32** | `killedBy` on a **terminal stop** — distinct attackers from `AscensionUI.DeathRecap`, read at `PLAYER_DEAD`, spent at the end marker, **and only when `dead`** |

**No CLEU listener anywhere.** DR-31 and DR-32 are one rare event each, and DR-32 consumes work
somebody else already paid for. Census: **4 files, 41 fn, 0 persistent OnUpdate.**

**`DRIVER_CONTRACT.md` written** — one consumed field, the read timing, the traps in the fields
we deliberately do NOT read, and a **live-verified vs source-derived** split.

**Drift fails LOUD, in the record:** `killedByUnavailable` carries the REASON when attribution
cannot be read. A silent absence would say *"nothing killed us."*

### ★ THE MUTATION HARNESS FOUND MY TESTS THREE TIMES, NOT THE CODE

The most useful part of the session, and it generalises:

1. **A masked guard.** *"Attribution only on a terminal stop"* went **SILENT** — my test set
   `dead = false` on a *later* pull, by which point the pending value had already been spent.
   Replaced with a **battle rez** (die, get resurrected, combat then drops), which is not a
   contrivance — it is what happens in a dungeon.
2. **Two guards masking each other.** `pendingKilledBy` was cleared at combat-start *and* at
   Stop, so neither could be tested. **Arm refuses while a run is live**, which makes the extra
   clear unreachable. Collapsed to ONE, at the run's end, symmetric with the OnUpdate teardown.
   *(An untestable line is a line I cannot defend — the same reason a combat-start clear was
   deleted a step earlier.)*
3. **A constant hiding an overwrite.** `GetInstanceInfo` returned fixed values in the stub, so
   write-once could not be distinguished from last-wins. Driven from test state instead.

**The rule: two guards for one hazard means neither is tested.** And a stub that returns
constants cannot observe an overwrite.

**A fourth, on a downstream test:** an absolute `pulls == 4` broke the moment tests were inserted
above it. Made relative. **A brittle test gets edited rather than believed.**

### Banked for later — mythic + level (his ask)

Surface **located, not built**: **`C_Keystones`** exists (12 functions incl.
`GetKeystoneInInventory`, `GetDungeonBest`, `GetCurrentSetString`), `C_ChallengeMode.GetCompletionInfo`
exists, and `Ascension_MythicPlus/MythicPlusObjectiveTracker.lua:51` reads
**`activeKeystone.keystoneLevel`**. The live accessor for `activeKeystone` needs one dump to
confirm — do that before designing on it, same as §6d.

### Still not built

No beacon work, no editor, no display, no CLEU. **The next move is his two runs.**

---

## 13. RUN 1 — `RFC_run1_clean-1` (2026-08-13), read against §10

Record: `addons/landing/records/20260813_020119__RFC_run1_clean-1__dungeonrun.json`.
**15 pulls (30 markers) · 99 travel legs · 332 s · mapID 389 throughout · zero deaths.**

| §10's question | What run 1 says |
|---|---|
| **Density** | **15 pulls, 30 markers, 99 legs.** Manageable — no pressure on a pin layer at this size |
| **★ start↔end DRIFT** | **0.1 → 82.6 yards**, with five pulls over 50: `0.1 2.2 2.5 7.5 8.2 10.6 22.0 22.2 26.0 38.9 51.7 52.3 55.7 58.0 82.6`. **Large and variable — the waypoint should be DERIVED, not taken as the start point** |
| Chain pulls | 15 markers for RFC reads as fine rather than collapsed. His taste call |
| **Floors** | **UNANSWERED** — Ragefire is single-level. Needs a multi-floor dungeon |
| Legs draw a path | 99 samples over 332 s; shape unreviewed until something draws it |

Boss engagement worked: **Taragaman the Hungerer, recorded twice** — two engage events for one
fight, exactly as DR-31 intends (record every engagement, fold offline).

### ⚠ THE DEFECT IT EXPOSED — arming INSIDE captured no origin

`arrival`, `instance` and difficulty were **all nil**. `captureOrigin` only ran on
`PLAYER_ENTERING_WORLD`, so **arming inside the dungeon — the natural workflow, since you zone in
and then start recording — got none of them.** The event had fired before the run existed.

**Fixed:** the origin capture is callable from `Capture.Arm` too. Armed inside takes the origin
there; armed outside takes the world-side entrance and the origin lands on zone-in. Both are
write-once in the store, so the paths cannot fight. `captureOrigin` is **forward-declared** — Arm
calls it and it is defined below, the same silent scoping failure that shipped once in
COA_Landmarks. Three mutations bite, including `LEAKED GLOBAL: captureOrigin`.

### ⚠ AND A GAP IN THE LANDING LANE, which was mine

**`pull.py` was hardcoded to `COA_DevDump.lua`.** I built an addon that writes its own
SavedVariables and never extended the lane, so the loop this bench documents — *SV →
`pull.py watch` → records* — did not cover it. Nothing would have landed however long he waited.

**Fixed with a SOURCE TABLE** (his call: *"2 sounds better. More dynamic"*). `deploy.py`'s
MANIFEST stays the one authority on who **exists**; this is the one authority on who **lands**,
and an addon joins by adding a row. Two `kind`s, because the shapes genuinely differ:

| kind | shape | dedupe |
|---|---|---|
| `envelope` | ONE `{header, payload}`, replaced every run | by `header.runId` |
| `collection` | a KEYED table that **accumulates** — the file only grows | **per key**; "already" is the normal answer |

`watch()` now watches **every** source — one `/reload` flushes them all, and watching a single
file while calling it *the watcher* is exactly what lost run 1. `once` runs every source,
`--source` picks one, `sources` prints the table.

Collection records carry a synthetic header (`tool` · `kind` · `collection` · `key` · `status`
derived from `closedAt`, so an **open** run says so) and keep full provenance. An entry with no
usable timestamp still lands under a `00000000_000000` stamp — **no timestamp is a FACT about the
entry, not a reason to drop it.** Idempotency verified: a second pass reports *"1 entr(ies), none
new"*.

---

## 14. RUN 2 — `RFC_Run2_Messy-2`, the adversarial fixture (2026-08-13)

Deliberately messy, per §9b. **28 markers (14 pulls) · 232 legs · 573 s · 2 deaths · 4 boss
engagement records.** Landed to `staging/` — the source is testing-stage, so **this record is
currently LOCAL ONLY** (see the decision at the end).

### ✅ The arm-inside fix works

`arrival` captured, `instance` captured, armed **inside** the dungeon with no zone-in event.
Run 1's defect closed, and proven on the next real run rather than only in the smoke.

### ★ The fixture produced exactly the three pressures §9b predicted

| Pressure | Evidence |
|---|---|
| **near-duplicate markers** | starts for pulls **10 / 11 / 14 sit 6.2–10.0 yards apart** — the re-pull cluster an editor must merge or trim |
| **terminal stops** | pull 3 `killedBy = [Ragefire Trogg, Ragefire Shaman]` · pull 11 `killedBy = [Taragaman the Hungerer, `**`Environment`**`]` |
| **wipe-and-retry** | boss engaged at pull **9**, death at pull **11**, re-engaged at pull **13** — legible without us modelling "attempt" at all |

**★ `[Taragaman the Hungerer, Environment]` is the whole case for DR-32 in one field.** Not
*"a wipe happened here"* but *"the boss put you in the lava here"* — and we hold no damage
numbers, no schools and no health curve to say it. One consumed field, and it is route meaning.

### ★ Drift is worse than run 1, and settles the waypoint question

`27.8 · 2.0 · `**`133.8`**` · 99.3 · 30.6 · 0.8 · 87.2 · 68.0 · 3.6 · 7.7 · 18.6 · 7.4 · 30.0 · 7.5`
— **max 133.8 yd, median 27.8.**

**★ AND THE CONCLUSION I DREW FROM IT WAS WRONG (Battlewrath, 2026-08-13).** I wrote *"the
waypoint must be DERIVED, not taken as the combat-start point."* His counter:

> *"I would counter. Capture in a stable form. The map editor will be the curation. **Deriving
> means inventing meaning we don't know in the wild.**"*

**Correct, and it is the ADR line: invention belongs only in contained spaces, and the capture
is not one.** A derived waypoint means US choosing a rule — midpoint? start-biased? weighted by
duration? — about what a pull's "true" location is, with no idea what that means across content
we have never seen. That is the pipeline authoring meaning instead of emitting facts.

**★ AND THE SHARPER REASON: a derived point is a position NOBODY EVER STOOD AT.** Every value in
this record is somewhere the player actually was. Synthesising a third point breaks that
property for the whole file — and once written it would be **indistinguishable from an observed
one**, which is the same class of harm as a silently truncated record.

**So the drift number is a FINDING, not an instruction.** What it actually settles:

- **§4's decision to capture BOTH ends was right**, and now demonstrated rather than argued —
  at 133 yards apart, a single marker would have been the wrong marker most of the time.
- **The editor must SHOW both**, because with drift this large the pair is the honest picture.
- **The choice between them is CURATION** — the user's, in the editor. They know what the pull
  means; we do not.

**★ AND THE LEGS ARE WHY NOTHING NEEDS DERIVING AT ALL (Battlewrath, 2026-08-13):**

> *"The user can see their leg steps. So that shows a story the eye can intuit."*

Start marker + end marker + **the sampled path between them** is not three data points — it is a
picture: *pulled here, dragged 130 yards down that corridor, finished there.* **The eye reads
that instantly and correctly, and no rule we could write would encode it.**

**So a derived waypoint is not merely risky, it is SUBTRACTIVE** — it replaces a legible story
with a single number, and throws away the very thing that made the story readable.

This is also the leg sampler (§6b) paying off twice. It went in to *"fill the dotted line between
capture points a consistent story"*; it turns out to be what **removes the need to invent a
waypoint** in the first place. The cheapest thing in the capture is carrying the most meaning.

We capture in a stable form and stop there.

*(Second time today an observation got promoted to a mechanism on my side — the beacon throttle
was the first. The tell is the same both times: a number I measured turning into a rule I
invented, with no source for the rule.)*

### Sampler behaviour, characterised

**232 legs over 591 s = 0.39/sec**, so roughly **61% of the run was in combat** with the sampler
correctly gated off. Thirteen gaps over 3 s, all consistent with combat windows and zone
transitions. The 1/s rate produced a usable path without flooding anything.

### ★ `ghost` RECORDED ZERO ACROSS BOTH DEATHS — AND THAT IS CORRECT

The record could not tell me whether the flag was broken or the mechanic never occurred.
**Battlewrath settled it from game knowledge, which is not derivable from the data:**

> *"Ghost returns you to a location. You don't corpse run like in the open world."*

**So `ghost` is expected to be FALSE for every leg inside an instance on this fork**, and zero is
the healthy reading. **Written down because without it the next reader sees `ghost: 0` on every
run and starts debugging a working field** — the failure mode where correct behaviour looks like
a bug because nobody recorded what correct looks like.

**The field STAYS.** It is free (one read on a tick already running), and its constancy is now a
recorded bound rather than an assumption — if the fork ever changes, the record will say so.

### ⚠→✅ `difficultyName` came back EMPTY — CLOSED

```
instance = { name = "Ragefire Chasm", type = "party", difficultyIndex = 1,
             difficultyName = "", maxPlayers = 5 }
```

**`GetInstanceInfo()`'s 4th return is not populated on this fork.** The index is there and
usable; the label is not.

### ✅ CLOSED by a live probe — record `20260813_055307_481__dump.json`

```
GetDifficultyInfo(1), GetInstanceDifficulty(), GetDungeonDifficulty(), GetInstanceInfo()
-> "Normal", 1, 1, "Ragefire Chasm", "party", 1, "", 5, 0, false, 389
```

**Two findings, and only one was the thing I went looking for.**

1. **`GetDifficultyInfo(index)` resolves the label** — `1 -> "Normal"`. DR-30 now falls back to it
   when the raw name is empty, and **prefers the raw value whenever the fork does supply one**, so
   if it ever starts populating we follow theirs rather than a lookup that could drift from it.
2. **★ `GetInstanceInfo()` RETURNS EIGHT VALUES ON THIS FORK, NOT SEVEN.** The client's own call
   sites unpack seven at most (`RaidProfiles.lua:540`), so this is undocumented even by the
   client. **The 8th is the mapID (389)** — and it only surfaced because the probe put the call
   **last**, where Lua lets it expand fully instead of truncating it to one value.

   **It is captured, deliberately redundantly.** Every point already carries a mapID from
   `GetCurrentPlayerPosition`; two independent sources for one fact make a **disagreement
   visible instead of silent**.

**★ The lesson is the dump discipline, not the field.** Asking for the values I expected would
have returned exactly the values I expected. Asking for *everything the call returns* found a
return nobody on this client unpacks. **"Better to be rich and find faults, than lean and never
find bounds"** — applied to a call signature rather than a data set.

Three mutations bite: the resolver, raw-name-wins, and the 8th return.

### ★ THE TWO PINNED EXEMPLARS — and they are DESIGN INPUT, not just evidence

**Both runs are tracked in `addons/landing/records/`, and the `dungeonrun` source stays at
`testing`.** Routine runs remain local; these two are permanent.

| Record | What it is |
|---|---|
| `20260813_020119__RFC_run1_clean-1__dungeonrun.json` | the **clean** pass — 15 pulls, 99 legs, 332 s |
| `20260813_052802__RFC_Run2_Messy-2__dungeonrun.json` | the **adversarial fixture** — 2 deaths, a re-pull cluster, a wipe-and-retry, 133 yd drift |

**★ Battlewrath's reason for pinning, which reframes what they are for:**

> *"Add to records. **They'll be basis for our reasoning on how and what to display.**"*

So these are not archived proof of settled findings — they are the **INPUT to the display and
editor design**, and every question that stage raises gets answered against them rather than
against a hypothetical run. *"Would the editor cope with X?"* has a file to check.

That also makes the messy one the more valuable of the two, exactly as §9b predicted: **a clean
run tells you what the happy path looks like; the fixture tells you what the UI must survive.**

*Mechanically this needed nothing new: `pull.py`'s already-landed check spans **both**
destinations, so a testing-stage source cannot re-land a pinned record as a duplicate. Verified
after pinning — `dungeonrun: already: 2 entr(ies), none new`.*

---

## 15. DR-33 — the FLOOR, and the third irreversible field (2026-08-13)

**§7 said there were two things the POC must not get wrong. There were three.**

Drawing a marker needs `mapID` → tile art → **the right floor's box** → the M3 transform. We had
everything but the floor — and the world-map fact basis showed it is **not recoverable**:

| Multi-floor maps (43) | Floor derivable from world x/y? |
|---|---|
| **6** — one identical box on every floor | **impossible** |
| **36** — overlapping boxes | **ambiguous** in the overlap |
| **1** — Scarlet Monastery, disjoint wings | yes |

**42 of 43 stack their floors over the same footprint**, which is what makes them multi-floor at
all. And **`z` cannot rescue it**: `DungeonMap.dbc` carries no z bounds, so inferring floor from
height would be inventing a rule for a mapping we have never seen — the thing ruled out in §14.

**We only got away with it because both runs were Ragefire, which has one floor.** The exemplars
are fine by luck, not design. Worth recording so a future reader does not assume floor was
considered and rejected.

**★ The floor rides the SAME TRUST BOUNDARY as the map fraction, deliberately.**
`GetCurrentMapDungeonLevel()` reports what the **map is showing**, which equals the player's
floor only after `SetMapToCurrentZone` — and we refuse to call that while the user has the map
open (we do not fight their view). So an untrusted fraction and an untrusted floor arrive
together, and **both go nil rather than one of them landing a plausible wrong number.**

Three mutations bite: the field's absence, an untrusted floor being recorded, and reading it
before the snap instead of after.

---

## 16. SFK RUN 2 — the multi-floor proof (2026-08-13)

`SFK_Run2_Legs_capture-4` — a **foot trace, no clearing** (he had already cleared the dungeon, so
this is a descent from the last boss). **315 legs · 321 s · one deliberate combat pair · zero
markers otherwise.** Pinned as the third exemplar: it is the only multi-floor capture we have.

### ✅ DR-33 works — the floor MOVES

`6 → 5 → 4 → 3 → 7 → 1 → 2 → 1` across **seven transitions**, all seven floors present,
**0 of 315 legs missing a floor**. The one risk left after the capture test — whether
`GetCurrentMapDungeonLevel()` tracks the player rather than sitting constant — is answered.

### ✅★ THE LOOKUP HOLDS ON EVERY FLOOR

317 points, per reported floor, DBC box vs the client's own fraction:

| floor | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|
| points | 148 | 12 | 33 | 20 | 25 | 24 | 55 |
| worst error | **0.000000** | **0.000000** | **0.000000** | **0.000000** | **0.000000** | **0.000000** | **0.000000** |

**Second dungeon, all seven floors, boxes we had never tested.** The transform is not a Ragefire
coincidence — it is the client's own arithmetic, and the retired calibration cost stays retired.

### ★ THE AMBIGUITY, DEMONSTRATED RATHER THAN ARGUED

Floors **3, 4 and 5 share one identical box** (`2103.8..2256.2` × `-193.2..-91.6`) and their
captured x/y ranges **overlap**:

| floor | world x | world y | world z |
|---|---|---|---|
| 3 | -186.2 .. -105.1 | 2154.5 .. 2189.4 | 100.5 .. 125.6 |
| 4 | -181.9 .. -135.5 | 2162.3 .. 2183.9 | 127.2 .. 132.6 |
| 5 | -160.2 .. -119.6 | 2158.5 .. 2203.5 | 136.8 .. 149.7 |

**Without DR-33 these three are unrecoverable.** Same box, overlapping footprint, identical
fractions — a point would be placeable on the map and simply be on the wrong level.

**⚠ AND THE z COLUMN IS A TRAP, so read it carefully.** The three z ranges happen to be
**disjoint** here. That is a fact about Shadowfang Keep, **not a rule** — and it is not a licence
to derive floor from height:

- `DungeonMap.dbc` carries **no z bounds**, so any z→floor rule would be **per-dungeon
  calibration** — precisely the cost the world-map fact basis retired.
- It fails wherever floors interleave vertically: ramps, spiral towers, overlapping wings.
- It is §14's ruling again. Deriving means inventing meaning we do not know in the wild.

What the disjoint z **does** tell us is something worth having: **the floor index tracks real
physical levels**, so a floor is a coherent thing to draw rather than an arbitrary art grouping.

### Also confirmed

- **markers carry `floor` too** — the combat pair landed with `floor = 1` on both ends.
- `mapID 33` for Shadowfang (not 666), `mapC/mapZ = (-1, 0)` again — M9 on a second dungeon.
- **The floor index is not ground-up ordering**, and we do not care: *"we don't 'care' where
  players start. That's 3D dungeon design. Not data capture."* **We never interpret the index —
  we record it and match it to the box the DBC gives for it.** No ordering is assumed anywhere.

### What this closes

**§10's five questions are now all answered**, and the capture POC has nothing open. Floors were
the last one, and they were answered *before* anything was built on them rather than after.

---

## 17. ★ DISPLAY ARCHITECTURE RULING — THE ADDON NEVER LEARNS DUNGEONS (2026-08-13)

> *"This stays in the data capture and in the display sequence. We don't want to create a system
> that needs per dungeon tracking first."* — Battlewrath

**The capture already has that property** — nothing is registered, nothing is calibrated, and a
dungeon nobody has ever run records correctly on the first visit. **The ruling is that display
must not quietly lose it**, and there is a specific way it would have.

### The trap we would have walked into

Display has to place a stored point on our own map frame. The obvious route is the M3 transform
— world coords through the floor's bounding box. **But Lua cannot read DBCs.** So that route
means **shipping the box table inside the addon**, which is:

- a data table we maintain, that **goes stale the moment the fork adds or reshapes a dungeon**;
- — and therefore **per-dungeon tracking**, just ours instead of the user's.

It would have looked principled right up until a new dungeon drew wrong.

### ✅ The answer, and it needs nothing new

**A point is already stored with the client's own fraction**, computed by the client against the
correct floor at the moment of capture. **710 of 710 points across all four runs carry one —
100%.**

> **`(mapX, mapY, floor)` + the tile art for that floor IS the placement.**
> **No box. No DBC. No table. No per-dungeon anything.**

The addon stores what the client told it and draws it back onto the client's own art. It never
learns a dungeon, so it can never be behind on one.

### ★ What licenses trusting the fraction — and it is not a shortcut

We did not decide to trust it; we **proved it equals the box**. Zero residual, twice:
389 points at Ragefire, then **317 points across all seven Shadowfang floors including three that
share one box** (§16). **The captured fraction and the DBC arithmetic are the same number.**

So the `worldmap` census has its role fixed by this ruling:

| | |
|---|---|
| **What it IS** | **verification and design infrastructure** — desk-side proof that the fractions are trustworthy, the floors table, the traps (M4, M6, M8, M9) |
| **What it is NOT** | a runtime dependency. **Nothing in the addon reads it.** It is how *we* know the capture is sound, not how the addon works |

### One honest limit on the older exemplars

The two Ragefire runs predate DR-33, so **0/389 of their points carry a floor**. Recoverable
there and only there: **Ragefire has exactly one floor**, so the floor is unambiguous — which is
true for **30 of 73** mapped dungeons and false for the other 43. **A missing floor is
recoverable only where there is nothing to be ambiguous about.**

### The rule, stated for whoever builds the display

**If a design step would require knowing something about a specific dungeon in advance — a box, a
roster, a calibration, a supported-dungeons list — it is the wrong step.** Everything needed is
either on the point or comes from a live client call (`GetMapInfo`, `GetNumDungeonMapLevels`,
`GetCurrentMapDungeonLevel`). This is the same law as no tag registry, no character roster and no
boss roster: **don't acquire the knowledge, provide the path.**

---

## 18. THE THREE PINNED EXEMPLARS — what each one proves

> *"I think evidence that last leg run. And it becomes our basis for building on."* — Battlewrath

`SFK_Run2_Legs_capture-4` is the basis. The other two are not superseded by it — **they prove
different things, and no single run covers all of it.** Test against the one that carries the
case, not the nearest one to hand.

| Exemplar | What it is the evidence FOR | What it CANNOT test |
|---|---|---|
| **`SFK_Run2_Legs_capture-4`** ★ | **the geometry basis.** 7 floors, 7 transitions, 315 legs of continuous path, the lookup at zero residual on every floor, and **floors 3/4/5 sharing one box** — the ambiguity DR-33 exists for | marker density: it has **2** markers |
| **`RFC_Run2_Messy-2`** | **the pressure basis.** The re-pull cluster at 6–10 yards, two terminal stops (one `[Taragaman, Environment]`), a wipe-and-retry, 133 yd drift | floors — Ragefire has one, and it predates DR-33 (**no `floor` field at all**) |
| **`RFC_run1_clean-1`** | **the happy path.** 15 clean pulls, 99 legs, one boss engagement, zero deaths — what a good route looks like with nothing to forgive | floors; anything adversarial |

**⚠ Two traps this table exists to prevent:**

1. **Do not test floor logic against a Ragefire run.** Both predate DR-33 and Ragefire is
   single-floor — it will pass by having nothing to get wrong.
2. **Do not test marker rendering or cluster-merge against the SFK run.** Two markers, both on
   floor 1. It will look correct because there is nothing to overlap.

**The one combination we have never captured: a multi-floor run WITH a full marker set** — he
cleared Shadowfang before tracing it, deliberately, to get a clean footprint. **Nothing is
blocked by that** (SFK's two markers do prove a marker carries its floor), but if the display
ever needs floors and density together, that is the run to ask for.

**All three live in `addons/landing/records/` and are permanent.** The `dungeonrun` landing
source stays at `testing`, so routine runs land to gitignored `staging/` and only exemplars are
pinned — they are **design input**, not archive.

---

## 19. DISPLAY ART — the leg dot (Battlewrath, 2026-08-13)

**`playerneutral`** — *"a white ring with a yellow centre. So high contrast for whatever the map
art is."* His call; the contrast reasoning is the point, since dungeon map art ranges from pale
stone to near-black.

```xml
<Texture file="interface\minimap\objecticonsatlas">
    <Size x="32" y="32"/>
    <TexCoords left="0.475586" right="0.506836" top="0.637695" bottom="0.668945"/>
</Texture>
```

**Verified before use, both ways:**
- **`claimed: false` in the atlas census** — nothing else on this client uses it, so we are not
  borrowing a meaning players already read as something else.
- **The crop is exact.** Both spans are `0.03125` = **1/32**, i.e. a 1024×1024 sheet of 32 px
  cells. The coordinates are a clean cell, not a hand-eyeballed rectangle.

### ⚠ THE SIZE IS A DISPLAY PARAMETER, NOT 32

`<Size x="32" y="32"/>` is the **cell** size, and drawing at it would smear the trail. From the
SFK exemplar:

| | |
|---|---|
| floor 1's box | 352.4 yards across |
| tile art | 12 tiles, ~1024 px wide |
| **scale** | **~2.9 px per yard** |
| legs while walking | ~7 yd apart → **~20 px apart** |

**At 32 px, adjacent legs overlap by a third and the trail becomes one continuous blob** — the
ring-and-centre detail that makes it high-contrast is exactly what gets lost. **Around 8 px reads
as a trail with visible spacing**; the individual samples stay legible, which matters because a
leg is a *sample*, not a line segment we drew.

**So the dot size scales with zoom rather than being baked.** Same conclusion the 6-pixel re-pull
cluster reached from the other direction (§"the number that should shape the design"): **overlap
handling is the display problem, and art choice sits downstream of it.**

### ✅ HOW IT IS DRAWN — the stock mixin already does the sizing

`SharedXML/Util/Mixin.lua` carries the full machinery (`Mixin` · `MixinSafe` · `MixinAndLoad`), and
**`WorldMapPOIMixin` implements clamped, aspect-preserving resize** (`RecalculateSize`,
`SetMaxSize`). So a leg dot is:

```lua
local dot = CreateFrame("Button", nil, ourMapFrame)
Mixin(dot, WorldMapPOIMixin)
dot:SetAtlas("playerneutral")   -- texture + crop + size in one call
dot:SetMaxSize(px, px)          -- px driven by zoom
```

**This is the "surface is ours, markers can be theirs" split paying off** (§ the custom-frame
discussion): we inherit sizing, atlas handling, highlight and tooltip type, and never touch
`WorldMapFrame`. The zoom driver becomes **one `SetMaxSize` sweep per zoom change**, not per-dot
maths — positions scale with the map, size is clamped per level.

**Two traps in the stock code:**

1. **`SetTexture` RESETS the crop** — `self:GetNormalTexture():SetTexCoord(0, 1, 0, 1)` runs
   inside it. Going manual instead of `SetAtlas` means setting TexCoords **after**, never
   before, or the whole 1024² sheet draws as one dot. Silent in code, unmissable on screen.
2. **`RecalculateSize` only clamps DOWN.** It shrinks past `maxWidth/maxHeight` and does nothing
   below them, so `SetMaxSize(8, 8)` gives the 8 px dot but cannot scale *up* past the atlas
   cell. Fine here; worth knowing before someone expects zoom-in to enlarge them.

**★ And the sizing numbers above are a STARTING POINT, not a finding.** Battlewrath: *"in-game
handling will indicate otherwise."* The 2.9 px/yard scale and the ~8 px suggestion are derived
from a captured box and a captured cadence — defensible, and still not the same thing as looking
at it. **The first draw is the arbiter**, exactly as the bench thesis has it: infer from
observable events, then go and observe.

---

## 20. THE DISPLAY SURFACE — as designed (Battlewrath, 2026-08-13)

Four decisions, taken in order. **Nothing built.**

### 20.1 Entry: the existing widget anchor + a text command

> *"We use the same widget anchor, and a text command that can go into a macro. Then key bind is
> controlled by the user in the normal manner."*

**We supply a command and stay out of both the macro system and the keybinding system — the user
already owns those.** Same law as no tag registry, no character roster, no boss roster, no
per-dungeon table: **don't own what the user already owns.**

Mechanically free: our map frame is **non-secure**, so a macro toggling it works **in combat**
with no lockdown to engineer around.

*Not taken, and noted so it is not re-proposed as an oversight:* a `bindings.xml` +
`BINDING_NAME_*` would put a native entry in the client's Key Bindings panel. Eight lines, and
**more surface for the same outcome**. Only worth it if discoverability in that panel is wanted.

### 20.2 ★ The model: it listens to where you are

> *"It should listen to where you are. Load it like the map would. Then any runs live on top of
> that."*

**This inverts "pick a run, show its map" into "show your map, draw what belongs here"** — and it
is strictly better:

- **The command needs no argument**, so the macro string is stable forever. That is the whole
  point of putting it in a macro, and it is why the earlier `/dr map <id>` question dissolved
  rather than being answered.
- **The display becomes STATELESS.** It derives everything from *where you are* + *what matches*.
  No stored selection, no "current run" concept, nothing to go stale — the same property §17
  gave the placement layer.
- **It enables the comparison case for free.** §6d ruled that skipped bosses are a *comparison*,
  not a lookup. Two runs of Shadowfang overlay on Shadowfang because that is where they are;
  we never build a "compare mode".

Floor navigation pages through the dungeon's levels the way the stock map does, defaulting to the
one you are standing on.

**⚠ The read that decides which runs match is `GetCurrentMapAreaID()`, and it is OFF BY ONE**
from the internal mapID (M8 — the client's own code subtracts it). Get it wrong and a dungeon you
have recorded shows an empty map.

> **★ 20.3 AND 20.4 ARE STAGE TWO. See §21 — they are banked, not next.**

### 20.3 ★ Scope: A:B, and ten is a DIFFERENT solution

> *"I'd say A:B. If we ever get into 10, that becomes a parser and heat map solution, instead of
> trying to win by force."*

**Two runs overlaid. Not a filter, not a threshold — the answer is two.**

This is the bench's existing idiom rather than a new one: `landmark_design.md` frames its open
questions as **A:B**, and MancerLedger's compare view is **A / signed-delta / B** row triplets.

**BANKED, NOT DESIGNED: the many-run case is a parser + HEAT MAP** — aggregation over overlay,
offline over in-game. Recorded explicitly so a later reader does not try to grow the A:B view
into it. *Don't scale a design past its shape.*

### 20.4 A is canonical; B is tinted

> *"A always being the true representation. B has a color picker and an alpha."*

**A is never altered**, so the canonical reading is always on screen and any distortion is
confined to the thing chosen to be distorted. That matters because §19's dot was picked for
**contrast** — `playerneutral`, a white ring with a yellow centre — and `SetVertexColor`
**multiplies**, so tinting would degrade exactly the property it was chosen for. Tinting only B
spends that cost where it is acceptable.

**The picker is the client's own.** `ColorPickerFrame` with `hasOpacity` / `opacityFunc` /
`func` / `SetColorRGB`, used by the client's own `WorldMapFrame.lua:2490` and by shipped
libraries. Nothing to build.

**⚠ THE TRAP: `OpacitySliderFrame` IS INVERTED.** Every call site reads
`local a = 1 - OpacitySliderFrame:GetValue()` and writes `ColorPickerFrame.opacity = 1 - a`. The
slider is named for opacity and carries **transparency**. Silent, and it produces a B overlay
that is invisible exactly when the user asked for solid.

**Storage:** the B colour is **chrome, not data.** It goes in `Store.GetUI/SetUI` (per character,
beside the widget position) and **never into a run record** — records are data only, the same
split `COA_Landmarks` AC-49 holds.

---

## 21. ★ STAGE ONE IS ONE RUN — a sequencing correction (Battlewrath, 2026-08-13)

> *"We moved into comparing runs before we showed we can display our current data in a
> meaningful way."*

**Correct, and it is the same catch as "display wins" applied one level in.** That call was
*editing needs something to see to edit*. This one is **comparing needs something to read before
it can be compared** — and §20.3/20.4 were designed past it.

**★ It is not merely premature ordering. A:B's VIABILITY depends on facts only the first draw
produces.** If a single trail is already dense at a readable dot size, **two overlaid is
unreadable however B is tinted** — and the colour-picker design would have been solving a
problem that turns out not to be the one in the way. Everything in §20.3/20.4 is cheap and
recorded; **none of it should shape stage one.**

### Stage one, stated

**One run, on the map for where you are, at the floor you are on.** Nothing else:
no comparison, no tint, no picker, no filter, no editing.

That is §20.1 (entry) and §20.2 (location-driven, stateless) plus §17's placement rule and §19's
dot. **Those four are the build.** The rest waits.

### ★ What the first draw is READ AGAINST

Written down now so it is examined rather than admired — the same discipline §10 applied to the
capture, and the reason both runs produced findings instead of impressions:

| Question | Why it decides something |
|---|---|
| **Does the trail follow corridors, or cut through walls?** | the single decisive test of §17's placement rule. Wrong → the fraction or the floor art pairing is wrong, and nothing else matters |
| **Does paging floors work — does the right trail appear on the right level?** | proves DR-33 end to end, from capture through to draw |
| **Is a single trail legible at a readable dot size?** | **the precondition for §20.3 existing at all** |
| **Do the two markers sit sensibly on the trail?** | markers and legs share a coordinate path; a disagreement between them is a bug in one |
| **Does the 6-pixel re-pull cluster read as a cluster, or as one dot?** | the overlap problem, seen rather than calculated — use `RFC_Run2_Messy` for this, per §18 |

### ★ The scoping rule for this stage (Battlewrath, 2026-08-13)

> *"Build on the current needs. Expand as we prove / tune the current model."*

**And the exemplars we hold answer all five questions above, in zone.** A recapture was offered
and declined for a reason worth keeping: **two display-design sessions each surfaced a missing
capture field** (floor, then tile art). If the first draw surfaces a fifth, a recapture made now
would have been made twice. **Build, draw, then capture once with better information.**

*(RFC's missing `floor` is harmless for its role — `DungeonMap.dbc` gives Ragefire exactly one
floor, so there is nothing to be ambiguous about. Out-of-zone display is the only thing the
current exemplars cannot exercise, and it is a convenience requirement rather than a stage-one
question.)*

**The exemplar for the first three is `SFK_Run2_Legs_capture-4`** (7 floors, 315 legs, a
continuous path). **The last two need `RFC_Run2_Messy-2`.** §18's table exists precisely so this
does not get tested against whichever run is nearest to hand.

---

## 22. DR-34 — the tile art, so a run displays OUT OF ZONE (2026-08-13)

> *"Maybe an option to load map based on a run selected out of zone. Editing whilst in a city,
> for example. **Editing only in the dungeon is asking a lot of hoops to use the addon.**"*

**A framing correction first, and it matters:** what §20 designs is the **review / edit surface**,
not the live one. *"I'm running this now, guide me"* is a different build with different
constraints — probably the beacon, not a map frame — and it is **unstated and unbuilt**. Blurring
them is how the edit surface would inherit requirements it does not have.

So §20.2's *"listens to where you are"* is the **default, not a constraint**: location seeds the
view, and a selected run overrides it. **A is the primary run displayed.**

### The consequence: one more capture field

Tile art is `Interface\WorldMap\<file>\<file>[<floor>_]<1..12>`, and `<file>` comes from
`GetMapInfo()` — **which only answers for where you ARE, or what the map is showing.** Standing
in Orgrimmar we cannot name Shadowfang's tiles. Three ways out:

| | |
|---|---|
| `SetMapByID(mapID)` then read it | **a WE-DON'T, not a we-can't.** The API exists — the client calls it — but it **mutates the shared world map**, the singleton we have stayed out of throughout, and the user would open their map to find it moved |
| look it up in a shipped table | **§17's forbidden per-dungeon data** |
| **★ store what the client told us, while standing in it** | the same pattern as the fraction and the floor |

**Recorded as we-can't-vs-we-don't deliberately**, so a later reader who discovers `SetMapByID`
does not mistake it for a shortcut we missed.

`GetMapInfo()` also returns the art's **dimensions**, which cost nothing and the display frame
needs — so `mapFile`, `mapW`, `mapH`, **write-once on the run** (constant for the whole run: a
floor selects a *suffix*, not a different file).

**This is the FOURTH irreversible field** — timestamp (§7), legs (§6b), floor (§15), and now tile
art. Runs captured before it are **displayable in zone only**. Three mutations bite: the field's
absence, last-wins instead of write-once, and dropping the dimensions.

### And his client check, which confirms the architecture

> *"In the client the map is locked to continent and zone. But there's no native way to see
> dungeon maps and explore them when outside of them. What is locked is the map START position."*

**The lock is on the stock UI's navigation, not on the art.** The textures are addressable from
anywhere; only the stock map's *starting point* is bound to the player. **Out-of-zone display is
therefore possible only because we compose our own frame** — a decision taken to avoid conflict
with other addons, now paying off for a reason it was not chosen for.

### The dropdown

Top-right, keyed to the current zone, **mirroring the store** — the same rule as the transfer
control's owner list (AC-5c): *mirror the data, assemble nothing.* A list of the user's own runs
is theirs; it is not knowledge we acquired.

---

## 23. BUILD LOG — display stage one, v0.5.0 (2026-08-13)

**`map.lua`.** §21's scope exactly, nothing beyond it.

| | |
|---|---|
| **frame** | our own, twelve tiles (M1). `WorldMapFrame` untouched |
| **placement** | `(mapX, mapY)` + `floor` + `mapFile` — all three from the client, per §17 |
| **identity** | `GetCurrentPlayerPosition()`'s mapID — **the same call capture used**, so the two cannot disagree. NOT `GetCurrentMapAreaID()`: off by one (M8) **and** a different id space |
| **command** | `/dr map`, **argument-free** — §20.2's model is what allows that, and it is what makes the macro string stable forever |
| **dot** | `WorldMapPOIMixin` at 8 px, TexCoord set **after** `SetTexture` (§19's trap) |
| **cost** | **zero persistent OnUpdate** — redraws on demand |

**Nine mutations, all biting** — the axis negation (a flip yields a *mirrored route that still
looks like a route*), the fraction guard, the floor filter, the tile-suffix rule, the pre-DR-30
fallback, the nil-mapID guard, and the empty-map message.

### ★ The harness found my TEST twice more

1. **The nil-mapID guard came back SILENT** — no fixture could exercise it, because every run
   had a real mapID so a nil match had nothing to match against. Added an **empty run** (armed
   and stopped with nothing captured, which is realistic) and it bites. **A guard whose failure
   case cannot occur in the fixtures is untested, not safe.**
2. **Inserting that fixture renumbered every id-based expectation below it.** Those now assert on
   the run's **name**: an id embeds creation ORDER. **A test that has to be renumbered gets
   edited rather than believed** — the same lesson `smoke_dungeonrun`'s pull count taught, in a
   different file, which is why it is worth stating as a rule rather than a fix.

### Next: the first draw

Read against §21's five questions, in zone, using `SFK_Run2_Legs` for the first three and
`RFC_Run2_Messy` for the last two. **Needs a deploy** — `capture.lua` (DR-34), `map.lua`, the
widget button, the toc.

---

## 24. ★ THE FIRST DRAW (2026-08-13) — positions right, and a promise found unkept

> *"It lacks map textures. But the positions seem right."*

### ✅ What it proved

Seven floors paged in turn: **148 / 12 / 33 / 20 / 25 / 24 / 55 points** — an **exact match for
the record's own counts.** That verifies the whole pipeline end to end: capture → floor filter →
fraction → draw. **The trail follows the corridor, and paging puts the right trail on the right
level.** §21's first three questions: answered.

### ⚠ What it exposed — and no smoke could have

**The canvas was empty**, and not because the drawing was wrong. **All three pinned exemplars
predate DR-34**, so they carry no `mapFile`; `TilePath` returns nil and `SetTexture(nil)` draws
nothing. Positions were unaffected, because they only need the fraction.

**But §22 promised those runs would be *"displayable IN ZONE ONLY"* — and he WAS in Shadowfang.**
`GetMapInfo()` answers for the map you are standing on. **The fallback was specified and simply
not implemented.**

**★ A gap between the spec and the build, where BOTH were internally consistent.** The smoke
asserted what the build does; the note asserted what it should do; neither could see the other.
**Only the draw could.** That is the argument for §21's ordering, made by the thing itself.

### The fix, and the guard that is the whole point

`Map.ArtFor(run, hereMapID, hereFile)` — stored art first, else the client's answer for where you
stand. **Guarded on IDENTITY**: without it, opening a pre-DR-34 Shadowfang run while standing in
Ragefire would draw **Shadowfang's route onto RAGEFIRE'S ART** — a picture that looks entirely
plausible and is completely wrong. **Nothing else in the display can produce that failure.**

`Map.MapIDOf` was extracted so `RunsFor` and `ArtFor` share **one** definition of which map a run
belongs to, rather than two that could drift.

And the readout now says **why** a canvas is empty — *"no map art (pre-DR-34 run, and not in its
zone)"* — rather than presenting a blank one. **A known limitation should not be left to be
guessed at.**

### ★ The harness found my test a THIRD time

The fallback's mutation came back **SILENT**: the fixture already carried stored art, so every
assertion passed through the stored-art branch and the two paths were indistinguishable. Clearing
it first makes the branch reachable, and it bites.

Same class as the nil-mapID guard an hour earlier, and now worth stating as a rule:
**A GUARD WHOSE FAILURE CASE THE FIXTURES CANNOT REACH IS UNTESTED, NOT SAFE.**

### Still open from §21

Questions 4 and 5 — **markers on the trail**, and whether **the 6-px re-pull cluster reads as a
cluster** — need `RFC_Run2_Messy`, in Ragefire.

---

## 25. ★ THE EDITOR FOUNDATION — a waypoint is a PROMOTION (2026-08-13)

**Design only. Nothing built.** Recorded now because the reasoning is intact and it is the kind
that gets re-derived badly from a transcript.

### 25.1 Waypoints are AUTHORED, not captured

> *"Waypoint is a promotion of a leg or a combat marker, or the custom marker we add (denoting
> skips or whatever else the user wants to capture)."*

| | |
|---|---|
| **captured** | legs · combat markers — **facts about what happened** |
| **authored** | **waypoints** — promoted from a leg, a combat marker, or a custom point |

**A combat marker is not a waypoint.** It is evidence that a waypoint *could* go there. The route
is the set of promotions the user makes from the evidence.

**★ So the route is authored FROM EVIDENCE rather than onto a blank map.** You are not placing
pins where you think you went — you are selecting from where you demonstrably were. That is the
scrapbook's *"notes of meaning, not what-where"*, and **the promotion model only exists because
the capture came first.**

**Consequence for display art:** do not spend `vignettekill` (chosen for *route waypoint*) on a
combat marker. Different claim — *"combat started here"* is not *"go here"*.

### 25.2 ★ Promotion COPIES the base, and Z is inherited

> *"Promotion is copying the base's values. We can offset the X,Y as a function of triangulation
> of near points. And Z (height) is constant to the base node."*

| field | on promotion |
|---|---|
| world **x, y** | copied, and **may be offset** — triangulated from near captured points, so the nudge is bounded by local sample geometry |
| world **z** | **COPIED, NEVER COMPUTED** |
| `mapID` · `floor` · fraction | copied (the fraction re-derives if x,y move — see 25.4) |
| back-reference | which node it was promoted from |

**★ Z-inherited is an ADMISSION the design makes out loud:** *this waypoint is on the same plane
as the node it came from.* We do not know the height between samples, so we do not pretend to —
the same refusal as §14's *deriving means inventing meaning we don't know in the wild*.

**★ AND IT IS SELF-ENFORCING, which is the part worth keeping.** If an offset would need a
different z, you have moved off the base node's plane — and the answer is **promote a nearer
node**, not guess a height. **The constraint tells you when you have overreached**, instead of
silently producing a waypoint hanging in the air or buried under a floor.

### 25.3 The trail is the EDITABLE SURFACE

A map is 2D; a waypoint that drives the beacon needs **x, y AND z**. Free-handing on a map cannot
supply the third. **The surrounding capture can** — approaching legs, the combat pair, continuing
legs, all carrying `z`.

So: **you cannot place a waypoint in a room you never entered**, because there is no terrain data
there. That is **correct rather than restrictive** — you do not know it is reachable. The
*we-don't-map-the-dungeon* law showing up as an affordance instead of a rule we impose.

It also stays inside §14: **deriving a waypoint from start+end is US inventing meaning; the user
dragging one, bracketed by observed points, is AUTHORING.** The difference is who decides, and
whether evidence brackets the result.

### 25.4 ★ The run carries its own inverse

A drag produces a new `(mapX, mapY)`; the beacon needs **world** coordinates. Inverting normally
needs the DBC bounding box — **which §17 forbids the addon from carrying.**

**The run already contains the inversion.** Every captured point is a `(world, fraction)` pair,
and that relationship is exactly linear — proven at residual `0.000000` across 706 points. So a
run **fits its own inverse, per floor, from its own points**: no box, no table, no per-dungeon
knowledge. **The run's capture is its calibration**, and it works on the first visit to a dungeon
nobody has run, because the run *is* the visit.

Two honest bounds: it needs **two well-separated points on that floor** (a floor with one point
cannot invert — and has nothing to edit anyway), and **z is read from the base node, never fitted.**

### 25.5 Promotion must NOT mutate the capture

A waypoint is a **new authored record** carrying its own values plus the back-reference — never a
flag written onto a leg. **Captured records stay immutable, which is the property that makes them
evidence at all**, and it means re-reading or trimming a run can never silently invalidate a
route. Same split as `owner` vs the record in Landmarks, and chrome vs data for the B colour.

---

## 26. ★ THE SECOND DRAW — art lands, and a constant scale error (2026-08-13)

> *"There is some displacement as a constant across them."*

**The art draws.** Seven floors of Shadowfang under the trail, from a freshly captured run
carrying DR-34's `mapFile` — no fallback needed. §21's first two questions confirmed a second
time, now with the map underneath.

### The bug: two sizes, and I used the wrong one

| `WorldMapFrame.xml` | | |
|---|---|---|
| **:528** | `WorldMapDetailFrame` | **1002 × 668** — *the coordinate space* |
| **:541** | `WorldMapDetailTile` | 256 × 256, laid 4×3 = **1024 × 768** — *the art grid* |

The tile grid is **power-of-two art with dead padding**; the map's coordinate space is the detail
frame. Placing across the tile grid stretches everything by **+2.2% horizontally and +15%
vertically** — worst furthest from the origin, which is why floor 7's trail ran off the bottom.

### ★ Why it looked plausible, and why that is the lesson

**A uniform stretch preserves SHAPE.** The trail still followed corridors, still turned where it
should, still sat inside rooms. It was simply wrong everywhere. **Nothing in the picture said
"scale error"** — only a human looking at art he already knows could see it.

And §21's first three questions are all *shape* questions, answerable at a glance. **This error
hid behind exactly the checks that were meant to catch problems**, because it did not deform the
thing those checks look at.

### What it says about the two draws

| draw | what it found | a test could not, because… |
|---|---|---|
| **first** | the missing in-zone art fallback | the gap was between the **spec and the build**, each internally consistent |
| **second** | the placement scale | the gap was between the **build and the CLIENT** — my `4×3×256` was an assumption, recorded at the time as *"testable on first draw"*, and it was wrong |

**Both argue the same way for §21's ordering.** Neither was reachable from the desk.

### The fix, and the guard

Canvas = the coordinate space (1002×668); tiles anchored to its TOPLEFT and **overhanging right
and bottom**, exactly as the stock detail frame does — the overhang is padding, not map content.
The outer frame sizes to the tile grid so no visible art is clipped.

`Map.ArtSize()` and `Map.TileGrid()` are exposed so the smoke asserts the two are not conflated
again — **including an assertion that they DIFFER: if they ever match, one of them is wrong.**

---

## 27. ✅ STAGE ONE CONFIRMED (2026-08-13)

> *"Amazing. And 2 pictures show me running rings on both levels, separately."*

With the scale corrected, the trail sits **on** the corridors across all seven floors.

### ★ The two rings are the strongest proof in the set

Floors **3, 4 and 5 share one identical bounding box** (§16) — the exact ambiguity DR-33 exists
for. Floors 4 and 5 are the tower's two circular levels: **same shape, same footprint, different
level.**

**Without the floor field those two rings would draw superimposed on one map** and read as a
single messy loop. Seeing them **separately, each on its own level, is the ambiguity resolving —
made visible.** A screenshot doing what 317 zero-residual points could only assert.

### §21's questions

| | |
|---|---|
| does the trail follow corridors, or cut through walls? | **✅ follows them** |
| does paging floors put the right trail on the right level? | **✅ yes** — and the shared-box floors prove it |
| is a single trail legible at a readable dot size? | **✅ yes** at 8 px — so §20.3's A:B has a foundation to stand on |
| do the markers sit sensibly on the trail? | **pending** — they draw, but as leg dots. Needs the combat-event art |
| does the 6-px cluster read as a cluster? | **pending** — needs `RFC_Run2_Messy` in Ragefire |

**Stage one is proven.** What remains is one art decision, and it is the only thing standing
between here and §21's last two questions.

---

## 28. ★ FIRST COMMUNITY SIGNAL — and a note model that was not written down (2026-08-13)

Discord, Battlewrath + **Vicke**, on seeing the two rings. Recorded because **three things in it
are new input rather than confirmation of what we already hold.**

### 28.1 ★ A use case we did not design for, from someone who is not us

> **Vicke:** *"What I would use it for is exact coordinates for where I need to stand when I
> press battle horn."*

**That is not a route.** It is a **single precise standing spot**, wanted for a mechanical reason
we never considered — and it lands squarely on the **custom marker** (§25.1's third promotion
source), which until now had only *"denoting skips"* as its justification.

**It validates custom markers INDEPENDENTLY of routing**, which matters: the feature had been
riding along inside the route model, and it turns out to stand on its own. First evidence that
someone else's need reaches the same primitive by a different road.

### 28.2 TWO LAYERS OF NOTES — already explored, and the ledger holds it

I first recorded this as a new design element. It is not: **`satnav_ledger.md` law 6, 2026-08-08.**

> **Law 6.** *"Notes come in two flavours: SELF and TEAM — and they layer. The **export carries
> locations + TEAM notes only, role-agnostic**. A consumer imports that layout and then adds
> their **own personal notes on top**. The shared artifact stays the ROUTE; nobody inherits
> anyone else's idiosyncrasies."*

Two more that sit with it and had not been connected here:

| | |
|---|---|
| **Law 7 — import WIPES** | an import replaces the route rather than merging. **Declines the merge problem deliberately**: no stable per-point IDs, no reattachment logic, no conflict handling. The named cost is that personal notes *on a replaced route* are lost, and that is the user's to manage by choosing when to import |
| **Law 7b — exports carry a MODE** | **disposable vs sacred**. *"Follow this tank's route"* is one run then discard; a sacred route is one you keep. **Metadata, not logic** |

**★ And the distinction that resolves Vicke's case cleanly:** law 9 puts notes **on the map, not
in the route.** A *"stand here for battle horn"* marker is map-anchored, so **route replacement
never touches it** — which is why (2) in the ledger's value propositions says the notebook has to
outlive any particular route, *and it does.* The lost-on-import cost applies to notes attached to
a **route**, not to the personal notebook.

**Nothing here is locked.** These are decisions taken five days ago in a design still forming,
and Battlewrath has been carrying the feature set in his head faster than the record has caught
up — *"we're still building the layers."* Recorded so the two documents point at each other, not
because either is settled.

**The useful repair is the cross-reference**, which is now in this note's header:
`dungeonrun_poc.md` covers **capture and display**; **notes, export, import and sharing live in
`satnav_ledger.md` laws 6, 7, 7b, 8, 9.**

### 28.3 The §8 community gate — first evidence, and it cuts toward building

> **Vicke:** *"Imagine like retail dungeon tool, you can share your own string with a route to
> the party."*

§8 gated routing on whether it competes with what already exists. **The first unprompted community
reaction reached for the MDT comparison by itself, as a WANT rather than an objection** — and
followed it with *"as a tool it has so many possibilities."*

**One data point, and it is one.** But it is the first external signal the gate has ever had, and
it points at *share the route you actually ran* rather than *author a route from a database* —
which is the half we are built for and MDT is not.

### 28.4 Confirmation, not new — but worth noting that it EXPLAINS

Battlewrath described the promotion model to a third party, unprompted and correctly: *"one of
these nodes can be promoted as the positional parent — establishes X, Y, Z. X and Y can be
dragged around, but **Z is a constant once spawned**. Then it's that which can become a beacon."*

**§25.2 verbatim, to someone who had not seen it.** A design that survives being explained cold
is a design that is actually settled rather than merely written down.

And the architectural thesis, stated plainly:

> *"Eh. A bunch of small projects really. Most of this uses what WoW gives us for free."*

**True of everything built today** — the stock `Mixin`, the stock `ColorPickerFrame`, the client's
own tile art, its own DeathRecap, its own map fractions. *Don't own what the user already owns*
is not only a principle about scope; **it is what keeps the scope tractable.**