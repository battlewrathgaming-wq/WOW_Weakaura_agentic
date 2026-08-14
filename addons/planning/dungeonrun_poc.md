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
| ~~drop the in-combat gate~~ | ~~*DR-3 FAILED: sampled a leg while IN COMBAT**~~ — **SUPERSEDED by DR-35 (§45): that gate was removed and the assertion inverted.** Kept struck rather than deleted, because this table is the v0.2.0 build's record |
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
| **DR-31** | which units carried a **BOSS TAG** during a pull — `INSTANCE_ENCOUNTER_ENGAGE_UNIT` → `boss1..boss5` names, every firing, never deduped. ⚠ **Not "bosses", not encounters** — §58 |
| **DR-36** | **the CUSTOM PIN** — the capture for what the client emits nothing for. The player as an EVENT SOURCE. Carries no meaning; promote gives it one — §52 |
| **DR-35** | **sample IN COMBAT too**, tagged `combat = true` + `n` = the pull. The out-of-combat-only gate held for short pulls and lost all routing on long ones — §45 |
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
| **`SFK_Run4_Clean_C-Legs_Pins-6`** ★★ | **the COMPLETE one.** 7 floors · 27 pulls · **432 combat legs + 266 travel** · 4 pins · 19 boss engagements · 756 points, **none unplaceable** · 8 floor segments, **0 flickers**. The only run with combat legs, pins and multi-floor together — test promotion against this | — nothing that is actually at risk. It has no deaths, but **terminal stops and `killedBy` are proven on both RFC messy runs** and that path has not been refactored since, so this is a fact about the fixture rather than an exposure |
| **`SFK_Run2_Legs_capture-4`** ★ | **the geometry basis.** 7 floors, 7 transitions, 315 legs of continuous path, the lookup at zero residual on every floor, and **floors 3/4/5 sharing one box** — the ambiguity DR-33 exists for | marker density: it has **2** markers |
| **`RFC_Run2_Messy-2`** | **the pressure basis.** The re-pull cluster at 6–10 yards, two terminal stops (one `[Taragaman, Environment]`), a wipe-and-retry, 133 yd drift | floors — Ragefire has one, and it predates DR-33 (**no `floor` field at all**) |
| **`RFC_run1_clean-1`** | **the happy path.** 15 clean pulls, 99 legs, one boss engagement, zero deaths — what a good route looks like with nothing to forgive | floors; anything adversarial |

**⚠ Two traps this table exists to prevent:**

1. **Do not test floor logic against a Ragefire run.** Both predate DR-33 and Ragefire is
   single-floor — it will pass by having nothing to get wrong.
2. **Do not test marker rendering or cluster-merge against the SFK run.** Two markers, both on
   floor 1. It will look correct because there is nothing to overlap.

**✅ CLOSED 2026-08-13 by `SFK_Run4_Clean_C-Legs_Pins-6`** — the multi-floor run with a full
marker set, and with the two capture kinds that did not exist when this gap was written.

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
| ~~back-reference~~ | **DROPPED 2026-08-13** — see below |

**★ Z-inherited is an ADMISSION the design makes out loud:** *this waypoint is on the same plane
as the node it came from.* We do not know the height between samples, so we do not pretend to —
the same refusal as §14's *deriving means inventing meaning we don't know in the wild*.

**★ AND IT IS SELF-ENFORCING, which is the part worth keeping.** If an offset would need a
different z, you have moved off the base node's plane — and the answer is **promote a nearer
node**, not guess a height. **The constraint tells you when you have overreached**, instead of
silently producing a waypoint hanging in the air or buried under a floor.

⚠ **SOFTENED 2026-08-13 (§60): under EDITING this is a TEACHER, not a gate.** Routes are editable and
**dragging a beacon is the user's choice** — improper, and allowed. Inherited z is what makes a bad
drag *visible*: move it far from its source and it sits at the wrong height on screen. The design
shows you that you went too far instead of stopping you, which is the whole of *"we give them tools
to do it well. But we don't gate them."*

✅ **THE BACK-REFERENCE IS DROPPED (Battlewrath, 2026-08-13).** The doc pass surfaced it as a
tension with §60 — a route that *copies rather than references* is what lets it survive its source run
being deleted — and his ruling resolves it by removing the field rather than reconciling it:

> *"We just decouple the back reference. It doesn't buy us anything. **Beacons will always want to be
> updated as new methods are found.** And then we're just carrying dead weight. Provenance buys
> little on the export side, as **we have nothing to authenticate**. And if we did — **we're not
> running arbitrary code within the route. It's a plot table.**"*

Three reasons, and the second and third are the load-bearing ones:

- **A beacon is EXPECTED to drift from its origin.** Routes get better as methods are found, so the
  link to the node it started from goes stale by design. A field that is wrong by design is worse
  than absent.
- **There is nothing to authenticate.** Provenance implies a claim that can be checked; an author
  name anyone can type is a label, not provenance, and should not be dressed as one.
- **★ A route is DATA, not code — a plot table.** There is no execution surface, so the worst a bad
  route does is put a beacon somewhere wrong. That is a quality problem, not a trust one.
- **★★ AND THE DECISIVE ONE, added after the drop:** *"the in-route consumer is reading and reacting,
  rather than referencing to up-stream data it never had access to across users."* **For the person a
  route is FOR, the reference could never resolve.** They ran nobody's capture; the node it pointed at
  does not exist on their machine. So it was not merely dead weight — it was **structurally
  unresolvable for the primary reader**, and would have been a field that is null for almost everyone
  who ever loads a route.

★ **What that leaves is two independent data forms sharing one space.** Runs and routes both live on
the map and neither depends on the other, so the map shows both without a mode switch. **Promotion is
the only bridge, and it is one-way and one-time** — copy at promotion, independent forever.

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

A waypoint is a **new authored record** carrying its own values — never a flag written onto a leg.
**Captured records stay immutable, which is the property that makes them evidence at all**, and it
means re-reading or trimming a run can never silently invalidate a route.

✅ It used to say *"its own values plus the back-reference"*. With the back-reference **dropped**
(25.2), the independence this section describes is now total rather than nearly so: a promoted record
shares **nothing** with the capture it came from, so §60's *a route does not know about Runs* holds
without exception. Same split as `owner` vs the record in Landmarks, and chrome vs data for the B colour.

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

---

## 29. ★★ THE UNIFIED MODEL — capture is the only spawn (Battlewrath, 2026-08-13)

> *"This all lives in the promotion side. The only basis we have to spawn is to capture. So we
> capture. Then promote into their lanes. **"For me"** — persistent to the map. **"For a run"** —
> stored as a sequence of beacons and notes."*

**This is the architecture in one line, and it collapses several things that were being held
apart.**

### 29.1 One entry point

**CAPTURE IS THE ONLY SPAWN.** Nothing is created from nothing:

| how a point enters | |
|---|---|
| **passively** | travel legs (1/s), combat start/end |
| **deliberately** | a **custom marker dropped where you stand** — still a capture, because you are standing there when you drop it |

**So every point in the system came from someone actually BEING somewhere.** That is §14's
refusal — *a derived point is a position nobody ever stood at* — generalised from a single ruling
into the whole model. **Nothing can be SPAWNED from nothing.**

⚠ **SOFTENED 2026-08-13 (§60). The gate is on ORIGIN, not on POSITION.** This clause used to read
*"there is no free-hand placement anywhere, in any lane, ever"*, which claimed more than was meant and
would have banned dragging a beacon during route editing. Battlewrath: *"users dragging beacons
everywhere is improper - but user choice. We give them tools to do it well. But we don't gate them."*
So: a beacon must come from a capture; where the user moves it afterwards is theirs. The wording was
the fault, not the law — same treatment §58 gave DR-31's *"bosses"*.

### 29.2 Two lanes, chosen at promotion

| lane | lives | shape | lifecycle |
|---|---|---|---|
| **"for me"** | **on the MAP** (ledger law 9) | a persistent personal marker + note | **outlives every route.** Route replacement cannot touch it |
| **"for a run"** | in the ROUTE | an **ordered sequence** of beacons + notes | exportable; **replaced wholesale on import** (law 7) |

**★ The lane is the answer to questions that were being asked separately:**

- *Vicke's "stand here for battle horn"* — **for me**. Map-anchored, so it survives any route he
  ever imports. His case was already served by a law written before he asked.
- *A waypoint on a route* — **for a run**. Ordered, exportable, and law 6's SELF/TEAM split then
  decides which of its notes ride the export.
- *"Denoting skips"* — whichever he means it as. **The user picks the lane; we do not infer it.**

**Law 6 is not replaced, it sits INSIDE the run lane.** The lane decides *where a thing lives*;
law 6 decides *what travels* when a route is shared.

### 29.3 What this settles

**The editor's whole job becomes: choose a captured point, choose a lane, add meaning.** Not
placement — **selection**. Which is why:

- **§25.2's z-inherited rule holds in both lanes** — a promoted point's height is the base node's
  in either case, because there is no other honest source.
- **The trail is the editable surface (§25.3)** applies to *everything*, not just routes. You
  cannot make a personal marker in a room you never entered either.
- **Nothing needs a per-dungeon anything** (§17), because promotion never invents a position — it
  copies one the client already gave us.

**And it explains why capture had to come first.** Not merely as build order: **the promotion
model has no other source.** Without a capture there is nothing to promote, in either lane.

---

## 30. ★ THE LANE CONFLICT, RESOLVED (Battlewrath, 2026-08-13) — design only

§29 gave two lanes; **they collide on one hardware fact.**

### 30.1 The conflict is forced by the client, not by us

**The beacon is a SINGLE SLOT.** `SUPER_TRACKED_POSITION` is one global with a fixed precedence
ladder. A personal marker and a route waypoint **cannot both be it.** Something must yield, and no
design choice of ours can avoid that.

**And it only bites at the IMPORT boundary.** While one person authors both lanes it is latent —
you would not place a personal marker that fights your own route. It becomes live when the route
came from someone who could not know your markers. §8 territory, not today's.

### 30.2 Override, then ROLL FORWARD

> *"We can override until the beacon despawns, then roll-back to the sequence. And if that
> updated because personal spot 1 and sequence 2 overlapped, we just load sequence 2 because 1
> was satisfied. And if they reach the new beacon approach, that takes over — **they already did
> the thing so it's not a fail condition**."*

**★ THE SEQUENCE ADVANCES ON SATISFACTION, NOT ON POSITION-IN-THE-LIST.** That single choice
removes the expensive part: there is no *"where was I"* to restore, only *"which steps are
done"* — so an override **cannot desync it**. An overlap stops being a conflict and becomes a
step that was quietly satisfied.

- personal marker **overrides** until its own tier is satisfied and it despawns;
- the sequence **rolls FORWARD to the first unsatisfied step** — not back to the interruption;
- **overlaps are satisfactions, not failures.** Same temperament as *arriving is silent* [L12] and
  *wrong isn't failure*: the design does not punish a player for doing the thing early.

### 30.3 It needs no new machinery — with one guard

> *"The position is to the marker. And we know that by player position and marker position."*

**Satisfaction does not require holding the beacon.** `GetSuperTrackedPosition`'s distance was
convenient, never necessary — distance is arithmetic on two positions we already hold. So while a
personal marker owns the slot, sequence steps are still evaluated and silently satisfied.

**⚠ THE GUARD:** our own arithmetic has **no map-boundary refusal.** The engine's `sd = 0.00`
across a boundary was a *feature* — it told us the engine had declined [F38, AC-24]. Computing
directly we would happily produce a meaningless number across a boundary or between floors.
**So satisfaction is evaluated ONLY for steps on the current `mapID` and `floor`** — both of
which every point now carries (DR-33).

### 30.4 ★ `< [Current] >` — and why it makes the rest affordable

> *"I do plan for the in-run widget to have a < > arrow to drive current sequence state also.
> Could be `< [Current] >` and that gives users recovery built in."*

**MANUAL RECOVERY LETS THE AUTOMATIC PATH BE ALLOWED TO BE IMPERFECT.** Every edge case the
satisfaction model would otherwise have to solve — two steps satisfying at once, a shortcut
skipping three, a satisfaction firing wrongly, a route whose author walked a different line — has
one answer: **press an arrow.** No merge logic, no conflict resolution, no confirm dialog.

**Same decision as law 7's import-wipes: decline the problem, hand authority to the user**, rather
than arbitrate it. And it is the Landmarks widget's re-pin button one layer up — *cheap manual
correction instead of expensive automatic correctness.*

It also answers something the beacon alone cannot: **where am I in the sequence?** The readout and
the control are the same widget.

**Gate: `Build!` — not authorised. Nothing here is built, and the route sequence does not exist
yet.**

---

## 31. BUILD — the marker art, v0.6.0 (2026-08-13)

Four states, **all four on one texture** (`objecticonsatlas`), so the whole display is a single
texture load with four crops. Every one verified **`claimed: false`** in the atlas census before
use, and every crop is an exact cell.

| state | atlas | reads as |
|---|---|---|
| **leg** | `playerneutral` | white ring, yellow centre · 32×32 · **8 px** |
| **combat start** | `warfronts-basemapicons-horde-constructionbarracks-minimap` | crossed swords, **red** · 37×35 · 16 px |
| **combat end** | `warfronts-basemapicons-alliance-constructionbarracks-minimap` | crossed swords, **blue** · 37×35 · 16 px |
| **terminal stop** | `islands-markedarea` | a red **cross** · 32×32 · 16 px |

**His colour language: red danger, blue safe.** Start is where it began, end is where it was
over — and a **terminal stop is neither**, so it gets its own mark rather than a tint. That is the
marker carrying route *meaning* (`killedBy` hangs off it); reading it as a variation of *"safe
again"* would be the wrong claim.

### Three rules the build holds

1. **An EVENT reads larger than a SAMPLE.** A leg is a sample at 8 px; a marker is an event at
   16. Asserted, because equal sizes would silently hide markers in a 300-dot trail.
2. **Aspect ratio is preserved.** The swords cell is **37×35** — drawn square it squashes into
   something that reads as a different icon. `Map.ArtForPoint` scales by the cell's own ratio.
3. **Markers draw ABOVE legs** (frame level), or a pull start under 300 travel samples is
   invisible exactly where it matters most.

### ★ Why `ArtKey` is a pure function

**Getting it wrong is SILENT.** Every wrong answer still renders a legible marker in the right
*place* — only someone reading the route can tell it lied about what happened there. So the
mapping is pure and asserted, including that **`dead` is checked BEFORE plain `end`** (the more
specific claim wins) and that **`dead` only qualifies an END** (a start is a start).

**Ten mutations bite**, including *"DUPLICATE ART: end-dead shares a crop with end-alive"* — the
check that two states never render identically.

---

## 32. ✅ §21 QUESTION 4 ANSWERED — and the picture matches the record (2026-08-13)

> *"Very clean."*

SFK floor 1, 148 points, the one combat pair standing clear of the trail. **Cross-checked against
the record rather than eyeballed:**

| | |
|---|---|
| recorded drift | **15.8 yards** (start `-222.2, 2188.0` → end `-208.4, 2180.4`) |
| predicted separation at 1002×668 | **45 px**, `dx +22 / dy −39` — up and to the right |
| on screen | the blue icon sits up-and-right of the red, about that far |

**`end.dead` is nil, so it drew the BLUE "walked away" icon** — correct, because he survived that
pull. The **terminal-stop art is untested by definition**: nothing in that run calls for it.

**★ That the on-screen geometry can be PREDICTED from the record is the real result.** Placement,
scale, floor filter and art selection all agreed with the data at once — a single number
disagreeing would have named which one was wrong.

### §21's scoreboard

| | |
|---|---|
| trail follows corridors | ✅ |
| paging puts the right trail on the right level | ✅ |
| a single trail is legible | ✅ |
| **markers sit sensibly on the trail** | ✅ — events read as events, and the pair reads as a pair |
| the 6-px re-pull cluster reads as a cluster | **pending** — `RFC_Run2_Messy`, in Ragefire |

**One question left, and it is the one that tests the art under pressure**: two terminal stops,
a re-pull cluster 6–10 yards wide, and 133 yards of drift.

---

## 33. ★ RUNS ARE A DATA SET — SELECTABLE, not auto-chosen (Battlewrath, 2026-08-13)

> *"Paused the fix. It's a fix on a not complete system. **This is the data set. So they want to
> be selectable and loadable. Not loaded on our preference.**"*

### What happened

§21's last question could not be answered because the display was showing **the wrong run.**
`Map.Show` picked `ids[#ids]`, and `Store.Ids()` sorts **alphabetically** — ASCII puts `'R'` (82)
before `'r'` (114), so `RFC_Run2_Messy-2` sorts *before* `RFC_run1_clean-1` and the older, clean
run won. **No deaths in it, hence no terminal stop to find.** The comment said *"most recent"*;
the code said *"last alphabetically"*; **nothing asserted they were the same thing.**

### ★ And the fix was the wrong fix

I began replacing the sort with `armedAt`. **That would have made a wrong shape work more
reliably** — the defect is not *which* run gets auto-chosen, it is **that one is auto-chosen at
all.**

**Runs are a DATA SET.** Selection is the mechanism, not a fallback for when our ranking guesses
wrong. §22 already said so — *top-right, a dropdown of saved runs keyed on the current zone* — and
I built the auto-pick as scaffolding and then tried to make the scaffolding clever.

**It is the same law as everywhere else in this design:** the user picks the lane (§29), the user
drives the sequence with `< [Current] >` (§30), the user supplies the denominator (§6d), the
transfer control is a selector rather than free text (AC-5c). **We do not choose for them.**

### What replaces it

**The dropdown is the answer**, and it is §22's, not a new idea. When a default is needed —
something must appear when the frame opens — **it is THEIR LAST SELECTION, held as chrome
(`Store.GetUI`), not our ranking.** First open with nothing selected shows the list rather than
guessing, which is the Landmarks widget carrying *"the last selected location to re-pin"*.

**Reverted, not patched.** `map.lua` is back to its committed state and the auto-pick stays as-is
until the dropdown replaces it wholesale — there is no point hardening a mechanism that is going
away.

### ⚠ And §21's question 5 is still unanswered

Everything read off that screenshot was **read against `RFC_run1_clean`**, which has no re-pull
cluster and no terminal stops. **The cluster and both red crosses have never actually been
drawn.** The pixel positions in §32's follow-up were computed from `RFC_Run2_Messy` and are
correct — they were simply not what was on screen.

---

## 34. ★ THE MAP IS THE EDITOR'S MAP — and the editor is a COMPANION (2026-08-13)

> *"What we have right now is the editor version of the map. It's not fit for purpose to run
> in-session. So this is the editing / curation space. **It can effort to be detail rich and have
> edit options.**"*

**A constraint lifted.** §22 already separated the review surface from the live one; this states
the consequence — **the map frame has no in-session duty**, so it does not need trimming against
a use it will never have. Detail-rich is *correct* here.

**The live surface is a different build and probably not a map at all** — most likely the beacon
plus a small readout (`< [Current] >`, §30). Nothing about this frame should be shaped by it.

### The companion, and the reason that beats mine

> *"But I still favor companion. **Isolates the bug fixing / edits.**"*

I argued screen space and reading-vs-editing. **His reason is build hygiene, and it is the better
one:** a bug in the editor cannot break the map, and either can be worked on without touching the
other. **Same discipline as `store.lua` owning the DB alone and the smokes testing modules
separately** — separation for diagnosability, not tidiness.

It also means **the companion can be rebuilt or discarded without risking the surface that is now
proven working** (§27, §32).

### The split

| | |
|---|---|
| **map frame** | which run · which floor · the plot. **Reading and curation context.** |
| **companion** | the selected point · its lane · its note · promote. **Authoring.** |

**⚠ CORRECTED (Battlewrath, same day): the load selector goes at the TOP OF THE COMPANION.**

> *"It's why I pushed that order, instead of putting it on the map and then taking it out and
> putting it into the editing suite."*

I had placed it on the map because *"which run am I looking at"* reads as a reading question.
**But loading a specific run is an act of CURATION, not of reading your surroundings.** The map
stays purely location-driven (§20.2); the companion overrides it when you are working. Cleaner
than the split I wrote, and it means **the map needs no selector at all.**

**★ And the ordering principle stands on its own: sequence the work so nothing gets built in the
wrong place first.** He ordered companion-before-selection specifically to avoid building the
dropdown on the map and then moving it — rework spotted *before* it happened. Same instinct as
*build first, capture once with better information* (§21).

**★ One coupling point, and it is the only one: SELECTION STATE.** Which point is currently
picked. `Map` owns it, the companion reads it, clicking a dot sets it. Worth deciding
deliberately, because it is the single thing the two frames share and the thing that would tangle
them if it lived in the wrong place.

### Order

1. ~~the `isPlayer` filter~~ — **done, §35**
2. **the companion editor pane**
3. **the load selector**, at the top OF THE COMPANION

**Gate: `Build!`**

---

## 35. ★ `killedBy` EXCLUDES `isPlayer` — found by a record, not by reasoning (2026-08-13)

`RFC_Run3_Messy` pull 12:

```
killedBy = [ Gravereaper, Searing Blade Enforcer, Taragaman the Hungerer ]
```

**`Gravereaper` is the player.**

**The cause is in the driver's own shape.** DeathRecap folds `SPELL_HEAL` as well as damage, so a
heal lands in the buffer with `attacker` set to the **healer**. Read literally, **`attacker` means
*the caster of this event*, not *an enemy*** — so without a filter, `killedBy` meant *"who appeared
in the last 14 events"*, and in a group it would have named your healer.

**One guard, on a field the contract had already characterised:** `isPlayer`
(`COMBATLOG_OBJECT_TYPE_PLAYER` off `casterFlags`). Excluding players is exactly the scope ruling
already on record — *"when a friendly or their pet, or when the tank died, is product of a bad
run. Not the model to build a route against."*

**★ The field was characterised BEFORE it was needed, which is the whole point of writing a
contract.** `isPlayer` moves from *not consumed* to *consumed as a filter*, and the contract's
verified/derived table moves `isPlayer == true` from **source-derived to live-verified** — not as
PvP, which is what we assumed would demonstrate it, but as a **self-heal.**

### ⚠ And the smoke's assertion ORDER was wrong

The player check sat behind the count assertion, so removing the filter failed on *"not deduped to
DISTINCT names"* and **reported the wrong cause** — the specific message never ran.

**An assertion that cannot be REACHED is the same class as one that is vacuous.** Reordered, so a
missing filter names itself: *"isPlayer FILTER FAILED: a self-heal put the PLAYER in killedBy"*.

Both mutations bite with their own messages. **v0.7.0.**

### Order from here (his)

1. ~~the `isPlayer` filter~~ — **done**
2. **the companion editor pane**
3. **the load selection**, at the top

---

## 36. ★ LOCATION SORTS THE LIST; IT NEVER CHOOSES THE VIEW (Battlewrath, 2026-08-13)

> *"It can load the map you're in. If you're in one. **It can not auto-load a run data set.** It
> can offer runs of that dungeon first in the selector, and then resort to naming alphabetical
> when not in an instance."*

**The line, stated once:**

| | |
|---|---|
| **map art** | **may** follow you — it is just *where you are* |
| **run data** | **never** auto-loads — it is a claim about what you are looking at, and that is yours |
| **the selector's ORDER** | location-aware: **runs of this dungeon first**, then alphabetical by name |
| **outside an instance** | alphabetical, full stop — no cleverness |

**★ Location informs the ORDER of the list. It never chooses the CONTENTS of the view.** Sorting is
a convenience; selecting is a decision. That resolves the tension between §20.2 (*listens to
where you are*) and §33 (*runs are a data set, selectable*) — both were right, about different
things.

### What it makes wrong in the current build

**`Map.Show` auto-picks a run** (and picks the wrong one, §33). Under this ruling it should not
pick at all:

- **open the frame** → the dungeon you are standing in, **and no run** — an empty canvas over real
  art;
- **choose a run** → it supplies its **own** `mapFile` (DR-34) and its points.

Which is precisely what DR-34 was built for: **the selector works from anywhere**, because a run
carries the art it needs. Standing in Orgrimmar and loading a Shadowfang route is the same code
path as standing in Shadowfang.

**An empty canvas over real art is HONEST** — it says *"this is where you are, and you have not
asked for anything yet."* The auto-pick said *"here is a run"*, and was wrong about which.

---

## 37. BUILD — the companion editor pane, v0.8.0 (2026-08-13)

**First slice: the frame, the selection readout, nothing else.** Not here yet: the load selector
(next, at the **top of this pane** — §34's correction), promotion into lanes (§29), notes, or any
editing at all. **The pane is an INSPECTOR first; authoring lands on top of it.**

### ★ The coupling is one-way, and it is the only one

`Map` owns selection, exposes `Select` / `Selected`, and fires **one optional callback**. **Map
holds no reference to the editor and does not know whether anything is listening** — asserted
directly: *selection still works with nothing registered.* **A map that needed the companion would
defeat the isolation the companion exists for.**

### `Map.Describe` is pure

Because it is **the pane's entire readout** — a wrong answer mislabels captured evidence and
nothing else would catch it. It reports the kind in words (**a death is a TERMINAL STOP, never
"combat end"**), the pull, floor, world and map coordinates, zone, the wall clock,
`killedBy`, and **`killedByUnavailable`** — the drift reason, because a silent absence reads as
*"nothing killed us"*.

The pane also **says when its readout is truncated** rather than showing a short list that looks
complete — `task_dump`'s no-silent-caps rule, applied to a UI.

### Feedback

Clicking a dot selects it; the selected point draws **1.6× larger at a higher frame level**.
Without some feedback you cannot tell what you clicked, and the readout would be the only
evidence — **exactly the kind of thing that reads as a bug while working correctly.**

### ⚠ The spy had to be fixed before the test meant anything

A list-based spy **cannot observe `Map.Select(nil)`**, because appending nil to a table is a
no-op — and clearing is precisely the case that would leave a stale point on the pane. Changed to
a counter plus a last-value, and the mutation then bites.

**Ten mutations bite.** `/dr edit` and a **Curate** button on the map. 6 files, 70 functions,
**0 persistent OnUpdate**.
---

## 38. ★ ENTER OVER EXIT — the marker precedence ladder (Battlewrath, 2026-08-13)

> *"Ordering, I think combat enter and terminal always win over combat exit. Enter is more
> deterministic — it's where the mobs and you meet. Exit is just where you was."*

**★ ENTER IS A FACT ABOUT THE ENCOUNTER; EXIT IS A FACT ABOUT YOU.**

Combat enter is where the aggro line was crossed, and that line is geometry the **dungeon** owns —
leash range, patrol path, line of sight. The next runner meets it in the same place, which is
exactly what makes it worth putting on a route. Combat exit is wherever the last mob happened to
fall: it moves with kiting, pull-backs, a feared add, a wipe. It is also the marker most likely to
be **spurious** in a messy run, because a re-pull emits enter/exit/enter/exit and only the *enters*
stack meaningfully.

The ladder:

| rank | | why |
|---|---|---|
| 4 | **terminal stop** | rarest, and the only marker carrying a payload (`killedBy`) — burying it hides the one point with something to say |
| 3 | **combat enter** | the encounter's own geometry |
| 2 | **combat exit** | where you happened to end up |
| 1 | travel sample | the path between |

### ★ It is two fixes, not one

Frame level drives **hit testing** as well as draw order. Before the ladder every marker sat at one
level and ties fell to **list order** — which puts the exit last, i.e. on top. In a 7 px re-pull
cluster you would both *draw* and *click* the least meaningful marker of the group.

### It points forward

This is the ranking §29's promotion will work against. **Enters are waypoint candidates; exits are
evidence.** Not acted on yet — recorded here so the promotion build does not have to re-derive it.

---

## 39. ★ THE COMMAND STRIP — and the map name was nowhere on screen (2026-08-13)

His layout, from the third draw:

> *"The curate button, on the map, would be better on the top right corner. And floors in the
> middle. Maybe a command strip with the loaded content and map name as reference on the left.
> Bottom can be trimmed upwards."*

One header row — **left**: what is loaded and what it is drawn on · **middle**: `< floor` · `floor N`
· `floor >` · **right**: `Curate`. The bottom bar is gone.

### ★ Why the reference pair earns its place

**The map name was nowhere on screen.** The art was the only evidence of which dungeon you were
looking at — and that is exactly the path that can lie, because a pre-DR-34 run *borrows* the art of
the zone you are standing in (§24; guarded on identity, but still borrowed). Naming the file makes
the borrow **visible** instead of merely plausible.

`Map.ShownArt()` was added at the same time for the same reason: the resolution is the one step that
can put a real route onto another dungeon's tiles, and until now it was observable **only by looking
at the screen**. Now the smoke asserts it.

### ★ The trim is bigger than the button bar

The tiles are 1024×768; the coordinate space is 1002×668. The grid **overhangs by 22 px right and
100 px bottom**, and that overhang is power-of-two padding which the stock detail frame clips —
so nothing cropped here is ever drawn by the game's own map either. Cropping buys the frame back
**and** removes a standing confusion: after it, the canvas *is* what you see.

The two sizes stay separate in code, and the smoke still asserts they never converge. It is only the
**drawn region** that now matches.

⚠ The crop is re-applied **inside `paint()`**, not once at Init — §19's trap: `SetTexture` RESETS
`TexCoord`. The smoke's texture stub had to be corrected to reset it too, or the test would have
passed on code that cropped only at Init.

---

## 40. ★ STRATA — "you're not concerned with your hot bars" (Battlewrath, 2026-08-13)

Both frames inherited their strata and competed with whatever else sat at MEDIUM, which is what was
bleeding through the pane in the third draw.

- map → **HIGH**, above the action bars. *"When you're using it, you're not concerned with your hot
  bars."*
- companion → **DIALOG**, one strata above the map. It **annotates** the map, so it must never end
  up buried under it.

Both `SetToplevel(true)`, so clicking raises.

---

## 41. BUILD — the strip, the ladder, and §36's LOAD SELECTOR, v0.9.0 (2026-08-13)

§38, §39, §40 above, plus the selector §36 has been waiting for.

### ★ The auto-pick is retired

`Map.Show()` with no argument took `ids[#ids]` and called it *"most recent"*. It is **alphabetical**:
on the live set it opened `RFC_run1_clean` every time — the oldest run, from before floor and
`mapFile` existed. A wrong answer, delivered confidently, with nothing on screen to say so.

Now: **no argument = no run.** The map opens on the art of where you stand; run data loads only
because someone chose it. §36's law, enforced rather than intended.

### The selector

At the **top of the companion** — his ordering, deliberately: *"it's why I pushed that order,
instead of putting it on the map and then taking it out and putting it into the editing suite."*

- runs for the dungeon you are standing in first, then everything else alphabetical
- the grouping is **drawn as titles**, not left for the user to infer
- `- no run -` is a real entry: **unloading must be as reachable as loading**
- an empty set says *"no runs recorded"* rather than presenting a menu with one dead entry
- the selector's text tracks **what the map has loaded**, not what was last clicked — a selector
  that quietly disagrees with the picture is worse than no selector

### The dependency now runs both ways, so say it exactly

| | |
|---|---|
| **selection** | map → companion (the map owns it, fires one optional callback) |
| **loading** | companion → map (`Map.Show(id)`, a public entry point) |

Both are the **companion depending on the map's API**. The map still holds no reference to the
companion and does not know whether anything is listening — asserted directly. §34's isolation is
intact; it was never "no calls", it was "the map does not need the pane to work".

### Two things the load must do, and both were mutation-caught

1. **Clear the selection.** A point from the previous run would sit in the pane describing evidence
   that is no longer on screen.
2. **Notify.** Clearing without the callback leaves the pane showing it anyway.

`Map.SeedFloor` decides which floor a load opens on: standing in its dungeon, the floor you are on;
loaded from elsewhere (§22, editing from a city), **the run's own floor** — otherwise every run
opens on floor 0.

`Map.Toggle` re-shows what you loaded. Toggling a window is not a decision to discard your run.

### 21 mutations bite, each on its own message

Including the three the smoke could not previously reach: **paint using the ladder** (frame levels
are file-local, so the stub now records every frame created), **the crop surviving a repaint**, and
**which art paint resolved to**. Also `- no run -`, the group titles and the empty case, by loading
`editor.lua` into the map smoke with dropdown stubs — its menu shape is real logic and none of it is
reachable from map.lua's pure functions.

⚠ One idiom is called out in the source because it is a trap: `run and Map.ArtFor(...) or hereFile`
would fall through to the local art whenever `ArtFor` **refused** — precisely the wrong-map case its
identity guard exists to stop. Written as a branch, and mutation-tested as one.

**6 files, 81 functions, 0 persistent OnUpdate.**

---

## 42. ⚠ LIVE DEFECT — `paint` was a forward reference, and the fixtures could not reach it (2026-08-13)

First click on a dot with a run loaded:

```
map.lua:229: attempt to call global 'paint' (a nil value)
map.lua:229: in function `Select'
```

`Map.Select` is defined **above** `paint` and calls it, so the name resolved as a **global** and was
nil. Fixed by forward-declaring `local paint` with the other file-locals and assigning with
`function paint(...)` — the same shape `capture.lua` already uses for `captureOrigin`.

### ★ Why the smoke did not catch it, and that is the real lesson

The call sits behind `if shownRunId`. **Every `Map.Select` in the fixtures ran while no run was
loaded**, so the branch was never taken. A guard whose failure case the fixtures cannot REACH is
untested, not safe — the fourth of that exact kind on this addon, and the reason it keeps recurring
is that the *fixtures* look complete while the *paths* are not.

The test added asserts the dot's **frame level rises** rather than merely that nothing errored, so it
also proves the repaint happened — without it the 1.6× highlight never appears and the pane's readout
is the only evidence of what you clicked.

Two mutations now guard it: dropping the declaration (bites as `LEAKED GLOBAL: paint`) and
**shadowing** it with `local function` (bites as `attempt to call upvalue 'paint'`). The second
matters — re-adding `local` in front of the definition is the natural-looking edit that puts the bug
straight back, so the source says so at the definition.

### The whole bench was swept for the same shape

Every `addons/*/*.lua` checked for a call preceding its own `local function` definition, comments
stripped so prose mentions do not count: **clean**, this was the only one.

**23 mutations bite on their own message.** v0.9.1.

---

## 43. ★★ THREE SURFACES, THREE QUESTIONS (Battlewrath, 2026-08-13)

> *"Map information I think should live on the map. As the curator suite is going to pack a lot of
> content itself."*
>
> *"That lives separate. Another pane. That's all about promotion. Curation is trimming / filtering
> / replay selection and isolation. Configuring how the information is presented."*

| surface | question | owns |
|---|---|---|
| **map** | *what IS this?* | the picture, and point facts on hover |
| **curation** | *what am I LOOKING at?* | trimming · filtering · replay selection · isolation · presentation |
| **promotion** | *what does this BECOME?* | §29's lanes, the selected point, offsets, z-inheritance |

§34's build-hygiene argument extends to all three: each pane isolated, each depending on the map's
API rather than on each other.

### ★★ AND IT SETTLES DR-9

**DR-9** — *a point is written as captured; we never clean, merge or dedupe* — was in apparent
tension with an editor that trims. Under this split it is not:

> **CURATION EDITS THE VIEW, NEVER THE CAPTURE.**

A trimmed wipe is **hidden**, not deleted. An isolated pull is a **filter**, not a subset written
back. Promotion is the only thing that produces durable objects, and §29 already says it **copies**.
Two panes, two verbs, and neither can damage the record.

**Consequence:** curation state is **per-view**. It does not belong in the record at all — which
also means it never has to survive an import (ledger law 7).

---

## 44. BUILD — the map answers "what is this?", v0.9.2 (2026-08-13)

The map side only; the rest of §43 is held for design.

**The point readout is a tooltip.** Native pin idiom, zero screen space, works on all 434 points
without the pane ever growing. **`Map.Describe` is unchanged** — it was already the tested readout
and simply has a different consumer. Colours follow the art's own language (red danger, blue safe);
the **label** distinguishes a start from a terminal stop rather than a fourth invented colour.

**HOVER READS, CLICK TARGETS.** Worth having on its own: you can inspect the whole route without
changing what you are about to act on.

**The pane sheds the ten readout rows** and keeps the loader — 130 px tall now instead of 330. It
**says** what is coming (*"trimming, filtering, replay and isolation land here"*) rather than
presenting a blank box that reads as broken.

`Map.FillTooltip(tip, point)` is split out from the handler so it is testable without a frame: an
empty tooltip is the map answering *"what is this?"* with **silence**, and nothing else on screen
would catch it.

### ⚠ A vacuous assertion the harness caught immediately

`assert(dot.OnEnter, "NO TOOLTIP HANDLER")` **can never fail** — the smoke's frame stub hands back a
no-op function for any unset method, so the name is truthy whether or not the script was ever
registered. Deleting the handler bit on the *next* assertion's message. Fixed with `rawget`, and the
reason is written at the assertion so it is not re-introduced.

That is the same family as the list-based spy that could not observe `Select(nil)` (§37): **a
permissive stub makes "is this wired?" assertions vacuous by construction.**

**27 mutations bite on their own message.** v0.9.2.

---

## 45. ★★ DR-35 — THE LEGS STOP WHERE THE FIGHTING STARTS (Battlewrath, 2026-08-13)

He put the fourth draw up as a puzzle — *"just to see if you can reason the problem, I already have
the answer"* — and the answer is in the picture: **continuous dot chains down the corridors where he
WALKED, and bare floor between markers in the western rooms where he FOUGHT.**

Sampling was gated out-of-combat, so **every pull is a jump from the red marker to the blue one with
nothing recorded between.** His confirmation:

> *"On short pulls the absence is clarity. On long pulls / big packs, all routing gets lost."*

### Why it is not cosmetic

The part of a route a guide most wants to speak about — **where you pull them back to, where you
fight this pack from** — is precisely the part we did not hold. We had where it started and where it
ended, and the shape between them was invented by whoever read the map.

**And it degrades as the group gets BETTER.** A chain-pulling run records almost no path at all.

### The fix, and what it costs

Nothing. The tick already ran at 1/s and simply **returned** in combat; now it writes. The original
comment — *"in combat the marker pair already covers it"* — was the reasoning that was wrong, and it
is corrected in place rather than deleted, because the wrong version explains the gap.

In-combat samples carry:

- **`combat = true`** — the qualifier, exactly as `ghost` already is. The display keys off it.
- **`n` = the pull index** — free, because capture is already counting it, and it is **the join**
  that lets curation isolate one pull's movement later.

⚠ `n` is deliberately **not** what identifies a combat leg: markers carry an `n` too, so keying on it
would draw every pull start as a dot. `combat` is the discriminator and the smoke asserts both ways.

### The ladder gets one more rung

`dead > start > done > leg > combatleg`. Same reasoning as §38 one level down: **the out-of-combat
path IS the route; in-pull movement is the mess around it.** Where they overlap, the deterministic
one reads.

---

## 46. ★★ RED VS BLUE — colour becomes one axis (Battlewrath, 2026-08-13)

His offer, and he left it open: *"If we want to make legs blue to copy the blue combat exit. Then the
conversation is red vs blue. Not a must. Depends if you think useful or not."*

**Taken**, because it makes the encoding orthogonal:

| channel | meaning |
|---|---|
| **colour** | **combat state.** Red in combat, blue out of it — everywhere |
| **shape** | **what kind.** Dot = sample · crossed swords = event · cross = terminal |

The leg was yellow-centred, which made colour a *third* thing meaning "sample" — redundantly with
shape, since a dot already says that.

**The payoff is that the route now reads its own combat rhythm at a glance:** blue stretches are
travel, red clumps are where the fighting happened, and you do not have to read a single marker to
see it. That is exactly what the fourth draw could not tell you.

| | atlas crop | reads as |
|---|---|---|
| leg | `artifactquest` | white ring, **blue** centre |
| combat leg | `playerenemy` | white ring, **red** centre |
| combat enter | warfronts…horde…barracks | crossed swords, **red** |
| combat exit | warfronts…alliance…barracks | crossed swords, **blue** |
| terminal stop | `islands-markedarea` | a **red** cross |

All five are crops on **one sheet** (`Interface\Minimap\ObjectIconsAtlas`), so the whole display is
still a single texture load.

---

## 47. BUILD — DR-35, the colour axis, and curation's first control, v0.10.0 (2026-08-13)

§45 and §46, plus the filter §43 said curation owns.

### The filter is a VIEW filter, and that is the whole point

`Map.SetHidden(key, on)` / `Map.VisibleOn(run, floor)`. **Nothing is removed from the record**, and
the state is deliberately **not stored on the run** — §43 makes curation state per-view, so it never
enters the data and never has to survive an import (ledger law 7).

Kept as a **separate function from `PointsOn`** on purpose: the floor filter is a *fact about the
run*, the view filter is a *choice about the view*, and conflating them is how one silently becomes
the other.

The pane's box reads **checked = shown**, so it says what it does, and it **reads its state from the
map** rather than its own memory — same rule as the selector: a control that disagrees with the
picture is worse than no control.

### 37 mutations, now across four files

The harness reached `capture.lua` and `store.lua` for the first time, running each file against
*its* smoke. Two SILENT results it caught while this was being built, both the same shape — **a pure
function tested, and its USE untested**:

1. Swapping `VisibleOn` back to `PointsOn` in `paint()` passed. The filter worked perfectly and
   changed nothing on screen. Fixed by counting the **drawn** dots either side of a toggle.
2. `rawget` again — `o.point` is truthy on *every* frame the stub ever made, so a "count the dots"
   loop silently counted the map frame too.

**6 files, 85 functions, 0 persistent OnUpdate.** v0.10.0.

---

## 48. ★★ THE CURATION PANE — design, agreed in chat (Battlewrath, 2026-08-13)

**DESIGN ONLY. Nothing here is built.** Recorded because it was worked out in conversation and the
reasoning is most of it. The open questions are listed at the bottom **on purpose** — this note
nearly carried three decisions that were mine rather than his, and the correction was *"you're
overstating on design decisions we've not discussed yet."*

### The shape

```
[ run selector          ▾ ]
Rename ·  Comment
[Delete]   [Export?]
─────────────────────────────────
show:  ☑ travel legs  ☑ combat legs
       (trim / replay / isolate)
─────────────────────────────────
[------------|||-----------]      the time bar: envelope, and the window inside it
[-]  time  [+]     min / sec      the window WIDTH
[Play]                            becomes Pause
[<] [Skip] [>]
```

### ★★ THE LAW

> **Curation changes VISIBILITY and AVAILABILITY. It never changes PRESENCE.**
> **Promotion is the extraction — not deleting individual content.**

So the only destructive verb in the pane is **delete the whole run**, as a unit, deliberately. There
is no operation anywhere that removes a single point. If a point matters you promote a copy of it
out (§29); if it does not, you hide it.

*"The sample collected is its own source of truth and not governed bar limited management."* Rename,
comment, delete, export — that is the whole of the management, and it is all run-level.

- **Rename is already safe.** `id` and `name` were separated at capture (`name` as typed, `id` =
  `name-n`, uniqueness from `n` alone), so renaming moves the label and no handle.
- **Comment is a short post-activity descriptor**, limited field. His example — *"bad run but good
  pull around 178"* — references a pull **in prose**, which tells us the field needs no structure,
  no linking and no per-point attachment. Distinct from the satnav ledger's two-tier point notes
  (laws 6, 9): run-level says *what this capture was*; point-level says *what happens here*.

### ★ THE LADDER — three rungs, each only narrowing

| | rung | governs |
|---|---|---|
| 1 | **tick shows** | which **kinds** are in play. A standing choice |
| 2 | **time filter** | which **span** of those is in play. Envelope, then window |
| 3 | **time controls** | **where** within it you are. Scroll, play, skip |

**A lower rung can never reintroduce what an upper rung removed** — play cannot jump you to a combat
leg you unticked. The pane reads top-to-bottom in the same order the data flows.

**The peek** (*"clear filter on / press / filter off"*) is **momentary, not a toggle** — a toggle is
a state you can sit in without noticing, and then the map is lying about what you framed. It
releases **one rung**: back to the tick-filtered whole run, so you can see where you are against it
without changing what you are inspecting.

### ★ TRIM IS TIME, NOT NODES

Node isolation would be **all or nothing**. The envelope is the trim.

**Three separate time quantities, and conflating them is how this gets built wrong:**

1. **envelope** — min/max on the bar. Starts as the whole run; shrinks and grows.
2. **window width** — `[-] time [+]`, min/sec. How much is on screen at once.
3. **position** — where the window sits inside the envelope. Scrolled, or advanced by Play.

**★ One second is the floor, and it is a FACT not a preference.** Points carry `t` (wall clock, whole
seconds) and `gt` (sub-second, meaningless across sessions), so playback is `t - armedAt` in integer
seconds — and capture samples at 1/s anyway. `RFC_Run3_Messy` spans 800 s, which is why min/sec is
the right unit pair.

**Skip is derived, not another decision:** **`window ÷ 10`, floored at 1 second.** Ten presses always
crosses whatever you have framed — a pull or a three-minute corpse run — and at the fine end one step
is one sample. A curve was considered and dropped: it trades a learnable invariant for tuning that
`[-] time [+]` already does explicitly.

### ★★ WHY TIME IS THE AXIS

Battlewrath: *"it reduces the 3D pathing into 'what directions was relevant to me in this time
window'."* **A route is 1-dimensional in time even when it is 3-dimensional in space**, and time is
the only filter that exploits that.

- **Captured, not derived.** Every point carries `t` from the client. Nothing infers it.
- **Continuous, where the obvious rival is not.** Pull index `n` cannot represent the walk from pull
  6 to pull 7, so slicing by it drops exactly the travel a route is made of. `n` makes a good
  **bookmark** for jumping the window; a bad filter for defining it.
- **It untangles a self-crossing path** — which these runs have (rings on two levels). Spatially a
  knot with no order in it; constrain time and it is trivially a sequence.
- **★ It de-duplicates repeat traversals.** His case: *"6 overlapping tracks, 1 min apart, all get
  hidden per-run by time."* Without it the corridor you ran six times draws six times as heavy, so
  an untimed route silently becomes a **frequency map** — asserting the run-back corridor is the most
  important thing in the dungeon. **A route is a sequence; a heatmap is a census.** The time window
  is precisely what stops one run from becoming an accidental heatmap, which is his own line about
  not trying to win by force.
- **Dead time is not a cost.** It is information, the bar's density shows it, and skip crosses it.

**Two boundaries, forward-looking:**

1. **Comparison is probably not time.** Two runs' clocks do not align — A's minute 4 is B's minute 6.
   What lines up across runs is **pull index**. Not a contradiction: `t` reads one run, `n` compares.
2. **Consumption is not time either.** In-run a user experiences **position** — "what is next from
   where I am standing." **Time is the AUTHORING axis**, and that line is worth holding so the time
   control does not leak into the in-run widget, which answers a different question.

### ★ EXPORT IS TWO THINGS — three weights, two audiences (Battlewrath, 2026-08-13)

*"We haven't split them yet. Because we haven't needed to."*

| | weight | audience |
|---|---|---|
| **capture** | heavy — the full positional basis | **creators**. Involved; it takes consideration to jump in and use |
| **personal notes** | heavy — the "for me" lane (§29) | you |
| **route** | lean — beacon markers, agnostic light notes on priority | **consumers**. Drop in and run |

All three are **born from promotion** except the capture itself, which is the only thing capture
produces.

**So the two exports defer for DIFFERENT reasons, and filing them together would hide that:**

- **Route export is BLOCKED.** The object does not exist until promotion does.
- **Capture export is DEFERRED BY PRIORITY.** Nothing technical blocks it — the audience is just
  small. But small is not unimportant: *"having data sets to share is useful. It makes 1 dungeon run
  something 10 people can use."* A shared capture MULTIPLIES in a way a route does not.

### ★★ THE TRUST ASYMMETRY — the leaner the artefact, the more trust it demands

A creator handed a **capture** can inspect it: every sample, every timestamp, the whole evidence
trail is present, and a bad one costs them an afternoon. A consumer handed a **route** can check
nothing — a wrong beacon walks them into a pack.

**So the route format is not simply "the capture with fields removed"** — it is read by someone who
cannot check it, and that has to shape what it carries.

⚠ **CORRECTED 2026-08-13: the asymmetry stands, but PROVENANCE was the wrong remedy.** This
originally said the route format *"will need provenance and self-consistency"*. Battlewrath: *"we have
nothing to authenticate. And if we did — we're not running arbitrary code within the route. It's a
plot table."*

**A route is DATA, not code.** There is no execution surface, so the failure mode is a beacon in a bad
place — a **quality** problem, and provenance would not have fixed it. And an author field anyone can
type is a label, not a claim that can be checked. What survives of this section is the observation
that the consumer cannot verify anything; what does not survive is my inference about what to do
about it.

It also settles two economies that had been implicit:

- **Capture stays rich.** *"Better to be rich and find faults, than lean and never find bounds"*
  holds because the capture never has to leave your disk to be useful.
- **The route goes on a diet.** It is the thing that gets shared, so weight is a real constraint on
  it rather than a preference.

⚠ Consequence to VERIFY before asserting: the satnav ledger's export/import laws (7, 7b, 8,
including that an import wipes) were written about **routes**. Whether they were meant to cover a
shared capture as well has not been re-read this session.

### ✅ THE LIST IS CLOSED (Battlewrath, 2026-08-13)

**1. The envelope does NOT persist.** *"It can't. Runs are different so its min-max is different."*
The envelope is min-max **of a specific run** — not a preference that could travel, but a coordinate
in one run's timeline. It has no meaning outside the run it was drawn on.

**★★ CONSEQUENCE, and it is a simplification rather than a restriction: ALL CURATION STATE IS
TRANSIENT, WITH NO EXCEPTIONS.** Filter views do not persist; the envelope cannot. So **nothing
curation produces is ever written** — no new field on any point, no new field on any run. §43's
*"curation edits the view, never the capture"* stops being a discipline someone has to maintain and
becomes **structural: there is nowhere for curation to write even if it wanted to.**

⚠ Reading, not a ruling: that makes **availability** a LIVE property too — what is eligible to be
acted on *in this view* — rather than a stored judgement. He used the word; he never defined it, and
this note has already invented in that exact spot once.

**2. Export is reclassified, not scheduled.** See ★ EXPORT IS TWO THINGS above.

On the ledger: *"we made the laws in the spirit of exporting. But we didn't know what the export
would be."* So laws 7, 7b, 8 stand as **intent**, written against an object we had not yet seen — and
we now know there are **two**. They most likely hold for routes and want re-reading for captures.
**Banked as a thread, not resolved either way.**

**3. The comment field is 40 characters.** His own example is the proof the cap works: *"bad run but
good pull around 178"* is 32. Eight to spare, and no room for it to grow into a log.

---

## 49. ★★ AVAILABILITY FOLLOWS VISIBILITY EXACTLY (Battlewrath, 2026-08-13)

> *"Availability is — I can't see it. And mousing over items I can't see and getting a pop-up is
> sloppy. So a general layer of in-view by filter = true = tooltip."*

**If it is not drawn, it is not there.** No tooltip, no click, no selection.

That collapses §48's two words into **one gate**. Availability is never checked separately and never
stored — the dot is either painted or it is not, and that single fact answers both questions. It is
also the last piece of the simplification §48 closed on: with all curation state transient and
availability derived from what is painted, **curation has no state of its own anywhere.**

### ⚠ THE TRAP THIS EXISTS TO CATCH — and it is in front of us, not behind

Today's code already obeys the rule, but **by luck of implementation rather than by rule**: `paint`
builds from `VisibleOn`, `clearDots` hides every dot before showing the survivors, and a hidden frame
receives no mouse events. Unticking combat legs already kills their tooltips.

**The time filter is where it breaks.** The natural way to implement a window is to FADE what falls
outside it — and **`SetAlpha(0)` leaves hit testing fully on.** You get an invisible point that still
pops a tooltip, which reads as a *ghost* rather than as a bug, and it is exactly the sloppiness he
named.

> **FILTERING HIDES. IT NEVER FADES.** Anything that wants to be dimmed rather than removed must give
> up its mouse explicitly.

### The guard

One assertion, in `smoke_dungeonrunmap.lua`: **no shown dot may carry a filtered-off kind.** An
alpha-based implementation fails it the moment it is written, because the dot is still `Show()`n.

⚠ Two count assertions beside it are labelled **BACKSTOPS** in the source: no single-edit mutation
reaches them, because the §49 check and the `SetHidden` reports-its-state check both fire first. They
are kept for two-part failures those cannot see. **Labelled rather than assumed** — an unreached
assertion that says so is honest; one that is presented as proven is the vacuous kind this brief has
now caught three times.

**37 mutations still bite on their own message**, and the paint-skips-the-filter mutation now bites
on §49's message rather than on the count — the more precise cause, fired first.

---

## 50. BUILD — the curation pane, v0.11.0 (2026-08-13)

§48 and §49 built as written, plus his late refinement on the peek.

### Limited management

**Rename · Comment · Delete**, all run-level, through the client's own `StaticPopup` path rather
than bespoke dialogs — a custom confirm is one more thing a user has to learn.

- **Rename moves the label and no handle**, which works only because `id` and `name` were separated
  at capture. The smoke asserts the id is unchanged, because the failure would be silent: the
  selector would simply lose the run.
- **Comment is 40, enforced twice** — `SetMaxLetters` on the widget and a cap in the store. A cap you
  can see stop you beats one that truncates on save.
- **Delete is the only destructive verb**, takes a whole run, confirms first, and **unloads it** so
  the map cannot be left drawing a run that no longer exists.

### The time filter

`TimeSpan` · `ClampWindow` · `SetEnvelope` · `SetWindow` · `SkipStep` · `SetPeek` · `InWindow`, all
pure or near it, because **every wrong answer here is a window that looks reasonable** — off the end
of the run, or narrower than a sample.

The bar draws **both quantities at once**: the envelope as the dim filled track, the window as the
bright band inside it. Different lengths on screen is the cheapest way to stop them being confused.

`[-] [+]` **halve and double** rather than step by a constant, so the control spans a 13-minute run
and a 5-second pull in the same number of presses.

**★ PLAYBACK IS AUTO-SKIP, once a second** — which is not an arbitrary rate. It makes Play obey the
same invariant as the buttons: *ten steps crosses whatever you framed, so ten seconds plays it.* No
speed control, because **the window width already is the speed control.**

### The peek, and why the latch is not a nicety

> *"I like the peek button as the main use. But next to it should be a hold open. Smaller. So it is
> still easy to make a promotion in that same space without needing to edit the envelope. Purely
> peek would be a race or frustration."*

Hold-to-peek **plus** click-a-point is two gestures at once. Peeking is `held OR latched` — one
state, two ways in, and the latch is visibly depressed so it is never something you are silently
sitting inside.

**The ladder is asserted directly:** with a kind unticked and a window set, peeking restores the
whole run **in time** and the unticked kind stays gone. A lower rung cannot reintroduce what an upper
rung removed.

### ⚠ THE CENSUS CAUGHT A REGRESSION I INTRODUCED

The envelope drag first shipped as a **permanently registered `OnUpdate`** guarded by
`if not dragging then return end`. That reads as throttled and is not — it is a handler running every
frame, forever, for two pixels of drag. `emit_addon_census.py` reported **this addon's first
persistent OnUpdate**, which is the entire reason that tool exists.

Fixed by installing on `OnDragStart` and clearing on `OnDragStop`, the same discipline as capture's
sampler and the playback ticker. **And the smoke now refuses it too** — *no frame may carry an
`OnUpdate` after Init* — so it cannot come back between censuses.

### One weak test the harness found

*"A load clears the peek"* passed with the clearing removed, because the test sequence had already
set peek to false — the assertion was **vacuous**. Fixed by peeking deliberately before the reload.
Same family as the four before it: **a guard whose failure case the fixtures cannot reach.**

**6 files, 112 functions, 0 persistent OnUpdate. 54 mutations bite on their own message.** v0.11.0.

---

## 52. ★★ DR-36 — THE CUSTOM PIN, and the player as an EVENT SOURCE (Battlewrath, 2026-08-13)

> *"It's putting the event in the player's hands. And it's important. A jump skip. A point to use
> potions. When they use invisibility. **Asking them to infer through events they didn't have input
> is asking them to guess.**"*

Everything else this addon captures is emitted by **play**: regen edges the client hands us, a tick
every second, a death recap. But a route's most useful beats emit **nothing at all** — a jump skip,
a route-shape decision, a moment that matters for a reason the game has no event for.

The only alternative would be inferring from a gap in the legs. That is **deriving**, already ruled
out at §14 — and it is worse here, because we would be guessing at something **the player knew at
the time.**

> **The bench thesis was: we can infer through observable, recordable events.**
> **DR-36 extends it: where the client emits nothing, THE PLAYER IS THE SENSOR.**

### ★ It carries no meaning, and that took two corrections

A first draft of this called the pin *"a claim rather than evidence."* Battlewrath: **"It's capture.
Then later promote gives it meaning."** Calling it a claim puts interpretation at the one place this
addon refuses it. A pin is a **point**. The smoke asserts it carries no note, text, label or reason.

A second draft had approach notes *"hanging off the enter marker"* — which invents a type system for
promotion, in a layer that has taught us nothing yet. **"That's defining promotion and it's content
before we're there."**

### ★ It is the CATCH-ALL, not the tactical marker

Not built around the in-combat case. Approach is a different question with better-typed sources
already, and building the pin around it would have made a catch-all compete with the right tool.
**The pin covers what nothing else captures.** Ungated beyond armed — refusing a capture needs a
reason and there isn't one — but that is permissiveness, not an argument for reaching for it there.

### Cheap in play, or it is worthless

A pin dropped **in the moment** carries the right position, floor and second. Asking afterwards is
reconstruction, which is the thing this addon exists to avoid. So:

- **No dialog.** The meaning waits for promotion, so there is nothing to ask at the time.
- **`/dr pin`, argument-free** like `/dr map` — the macro string stays stable and the keybind stays
  the user's. **That is the path that is usable mid-pull; the button is how you find it.**
- **The widget button is full width, above the name controls**, because during a run the name box is
  disabled and this is the only live control on the surface.
- **Disabled, not hidden, when unarmed.** Disabled says *this exists and needs a run*; hidden says
  nothing.
- **The widget shows a pin count once there is one** — immediate confirmation that an in-play press
  landed. Hidden at zero, because a permanent `0 pin(s)` is clutter on a surface whose job is to be
  small.

### The art: `racing`, a checkered flag

Chosen against `monsterfriend`, `none` (a magnifying glass) and `loreobject`. **The other three all
carry meaning**, and the pin's contract is that it has none until promotion — a magnifying glass says
*look at this*, a lore object says *read this*, and both would prime a user to fill in a reason at
capture. **A flag says "marked", not "marked because".**

It is also **achromatic** (brown pole, black-and-white check), so it claims no combat state on an
axis where colour now means exactly that (§46); and its **form matches nothing else**, so it cannot
be read as a sample, an event or a terminal.

**It tops the ladder**, above the terminal stop: it is the only point that exists because someone
**chose** it, and burying a deliberate mark under an automatic one inverts the reason for having it.

### It inherits everything

Because §29 keeps it a capture, a pin lands in the same record with a time, a floor and a fraction —
so the time filter, the tooltip, the ladder and the flip book all work on it with nothing built.

### ⚠ TWO WEAK TESTS AND A TREE LEFT MUTATED

1. **`Capture.Pin() == nil` passed with the guard removed.** `Store.AddMarker(nil, ...)` also returns
   nil, so the assertion could not tell the two apart. Now asserted on the **reason string**.
2. **Counting a pin as a pull bit on the wrong message** — *"Counts reports pins"* fired before *"a
   pin is not a pull"*. Reordered so the precise one goes first.
3. **★ The harness left a mutation on disk for the second time**, and again it was caught only
   because the next command was the smoke. The `finally` restore is not enough on its own, so the
   harness now **verifies its own restore** and names any file it failed to put back.

**6 files, 114 functions, 0 persistent OnUpdate. 61 mutations bite on their own message.** v0.12.0.

---

## 53. ✅ THE MUTATION HARNESS IS A TOOL NOW (2026-08-13)

`addons/tools/mutate.py` + `addons/tools/mutations/dungeonrun.json`.

```bash
py addons/tools/mutate.py dungeonrun
py addons/tools/mutate.py dungeonrun --only "the pin"
```

It had been hand-written into scratchpad **three times**, which is exactly the shape
`machines-do-the-mechanical-work` names: defined I/O, so build the tool once. The spec is **data**
(`file · what · find · replace · expect · smoke`), so adding a guard means adding an entry, not
editing a script.

**Three guards it gained on promotion, each from something that actually happened:**

1. **Baseline before mutating.** Mutating on top of a red suite makes every result meaningless, and
   the failure reads as the harness rather than the tree.
2. **Restore, then VERIFY the restore.** The scratchpad version left a mutation on disk **twice** —
   once in `editor.lua` — and both times it was caught only because the next command happened to be
   the smoke. Every file is read back and compared; anything that did not go back is named and fails
   the run.
3. **Re-run the suite after.** Belt to the braces.

**The cause, resolved:** Battlewrath — *"I had a connection issue. So might have been that."* An
interrupted volume gives exactly `errno 22` on open, and it explains why a **repo** file failed while
the harness was mid-run. So the failure came from **outside the process**, which raises the stakes on
the check rather than lowering them: **if reads can blip, writes can too**, and the restore itself is
a thing that can fail for reasons the harness cannot see.

Hardened accordingly: the restore is wrapped **per file**, so one that raises still names itself
instead of taking the whole report down, and a verify that cannot read counts as **dirty** rather
than throwing.

**61 mutations, five files, two smokes.**

---

## 54. ✅ SFK_Run4 — the field result, and the pins DISPROVE derivation (2026-08-13)

First run on v0.12.0. `SFK_Run4_Clean_C-Legs_Pins-6`, pinned to `records/`.

| | |
|---|---|
| span | 702 s (11:42) · 27 pulls · 27 ends · **0 terminal stops** |
| legs | **698** — 266 travel, **432 combat** |
| coverage | **99.6%** of seconds carry a sample. Travel-only would have been **37.9%** |
| points | 756, **zero unplaceable** |
| floors | all 7 · 8 segments · **0 flickers** |
| bosses | 19 engagements, 9 distinct |

**DR-35 in one number: 62% of that path did not exist before it.**

### The floor check, which was the risk

A wrong floor reads as plausible, so the signature to look for is a **flicker** — floor N→M→N
across a second or two, which no player does. **There are none.** Eight segments, each ≥21 s:

`1 (215s) → 2 (73s) → 1 (78s) → 7 (119s) → 3 (47s) → 4 (48s) → 5 (21s) → 6 (92s)`

**Floor index is not route order** — 1→2→back to 1→**7**→3→4→5→6 — which is why the layout appears
to flip about during playback. It is correct; the numbering simply is not the walk. And floors 3/4/5
share one bounding box, so `floor` is the only field separating them at all.

### ★★ THE PINS DISPROVE DERIVATION — and that is the useful result

He named them afterwards: **1 buffs · 2 talk to the NPC to open the door · 3 a jump skip · 4 just
data input.** Measured against the surrounding legs:

| pin | he meant | the capture around it |
|---|---|---|
| +1s | buffs | **9 consecutive steps of 0.0 yd** — stood perfectly still |
| +97s | NPC / door | 10 of 16 steps under 0.5 yd — stood still, small shuffles |
| +151s | **a jump skip** | **12.6 yd step, 10.5 vertical** — the largest single step in the run |
| +699s | **nothing** | **11.7 yd step, 10.5 vertical** — statistically the same event |

Baseline over 697 pairs: median 0.0, 90th 7.0, 99th 7.9, max 12.6.

**The two big-displacement pins are indistinguishable in the data, and one is a route insight while
the other is nothing.** The two stillness pins are indistinguishable too — and standing still is also
what waiting, reading chat and going AFK look like.

> Battlewrath, before the numbers were in: **"You won't be able to get meaning."**

So the analysis is only interesting as a **negative**. It shows the record is rich enough that the
events are visible — and it shows that **which of them mattered is not recoverable from it.** That is
DR-36 and §14 demonstrated rather than argued: the player is the sensor because the sensor is the
only thing that knows.

⚠ Do not come back to this table looking for a classifier. It is the evidence that there isn't one.

### ★★ WHAT A POINT KNOWS — and the hindsight that makes it look like more

> **"The positional data knows what type, from what source, in what state, when and where.
> Nothing more."** — Battlewrath, 2026-08-13

| | |
|---|---|
| **type** | `kind` — leg, combat leg, pull start, combat end, terminal stop, pin |
| **source** | what emitted it: a client event, our 1/s tick, or the PLAYER (DR-36) |
| **state** | `combat`, `ghost`, `dead` — the conditions it was taken under |
| **when** | `t` the wall clock, `gt` the session timer (DR-4) |
| **where** | `x,y,z` · `mapX,mapY` · `floor` · `zone`, `subZone` |

**And nothing more.** No why, no meaning, no significance.

★ **The trap this section exists to name: the reads above only looked right BECAUSE the labels came
first.** Told "jump skip", a 12.6-yard step is obviously a jump. Untold, it is one of two identical
events and one of them means nothing. That is hindsight dressed as inference, and it is exactly what
an agent will do with this data if it is left alone with it.

**So the pin is not a signal for a machine — it is an INDEX INTO THE AUTHOR'S MEMORY.** It does not
record what happened. It records that *something* did, so that at promotion the author can be put
back on the spot and go *"oh yeah"*. The meaning was never in the file; it was always in the person,
and the pin's whole job is to find them again.

---

## 55. What we think we are making (2026-08-13) — held lightly

> *"We're not trying to solve the authoring for them. That takes insight. Experience with the
> encounters — or lessons learned, and this is their tool for learning."* — Battlewrath

**Not a law.** His own instruction on recording it: *"we'll refine it as we go... just don't
over-harden to be over-confident."* So this is the current understanding and it is expected to move.

### What it changes about a rule we already had

"Record if it's free — better to be rich and find faults than lean and never find bounds" has always
been justified from **our** side: a richer file is one where we can find our own mistakes. If this is
a tool for **learning**, the stronger reason is the user's: **the learner does not yet know what will
matter.** Filtering at capture decides for them, before they have had the run that would have taught
them. Same rule, a better reason, and the better reason is harder to argue away.

### The boundary it draws

**We build the instrument, not the expertise.**

That turns out to be the same line already drawn from four other directions — §17's *never learn
dungeons*, the five refusals to hold a roster or a list of anything the user owns, the refusal to
become a heatmap, and §43's *curation edits the view, never the capture*. We hold **what happened**,
and hand over the means to see it. Anything that begins telling the user what a good route **is** has
crossed it, and it will look like helpfulness on the way over.

### It widens the pin

DR-36 was framed around an expert marking a known thing. Under this, a pin is equally a **learner**
marking *"something happened here and I do not know what yet"* — same capture, and promotion is where
the lesson lands once they have worked it out. Which fits §54: a pin is an index into the author's
memory, and memory includes the things you have not made sense of yet.

### ⚠ Why "held lightly" is the honest framing

The answer to *what is this* has already moved three times, and each move came from play rather than
from thinking harder:

| | |
|---|---|
| §1 | a capture POC — write an honest file about pulls |
| §17-§27 | ...that has to be **displayed**, which is where the axis question appeared |
| §43-§48 | ...and **curated**, which is where the view/record split appeared |
| §52 | ...by a player who is also a **sensor**, which is where the pin appeared |

Expect a fifth. The thing that would move it is the same thing that moved the others: a run that does
something the model has no room for.

---

## 56. BUILD — two tightens on the curator, v0.13.0 (2026-08-13)

### ⚠ The envelope handles: three input bugs, no arithmetic bugs

His report: *"when they're set right against the time scale in the envelope, they get stuck and stop
responding. When in that mode they're good for trimming the time-scale more granular than the -/+."*

Nothing was wrong with `SetEnvelope`. All three causes were in the **input path**:

1. **`RegisterForDrag` has a movement threshold.** A small precise nudge — which is exactly what the
   handles are *for* — never starts a drag at all. **Press-to-grab has no threshold.**
2. **The bar underneath takes a click as "move the window".** Miss an 8 px handle by a pixel and
   something else happens, which reads as the handle ignoring you rather than as a miss. The handles
   now sit **above** the bar and swallow their own clicks.
3. **At the extremes the cursor maps past the track**, `SetEnvelope` pins it, and the handle sits
   still while you keep dragging — *"stuck at the ends"*. The drag is now clamped to the track.

Plus one that had not bitten yet: **two handles on the same second overlap exactly**, so one hides
the other and whichever is on top takes every press. `Map.SeparateHandles` nudges the **draw** apart
by 8 px while leaving the envelope untouched, so the numbers stay honest.

A 16 px invisible grab area over a 4 px visual, and `OnHide` clears the ticker — a grab that ends off
the button would otherwise leave it stuck to the cursor, which is the same symptom again.

### ★★ Track the most recent node

**SFK_Run4 is why:** floor index is not route order (1 → 2 → back to 1 → **7** → 3 → 4 → 5 → 6), so
scrubbing across a transition empties the map with nothing on screen to say where the route went.
You end up hunting floors by hand to follow a route the record already knows the order of.

`Map.FloorAt(run, atRel)` — the floor of the **last point at or before** the window's end, across
every floor. **At or before, not inside**: a window in a quiet stretch still shows where you *are*,
because the run has not left a floor just because nothing was sampled in the last few seconds.

**Paging by hand turns tracking OFF** rather than fighting it. Otherwise the pager looks broken: you
press it, the floor changes, and the next scrub silently puts it back.

**One control surface, on the curator** — his call over a second floating widget on the map.

### Reset

A narrowed envelope had no way back except reloading the run, which also threw the selection away.
`Reset` sits under the controls it resets, and is **time only** — the tick filters are a separate
rung and it must not reach across them.

### ⚠ Two weak tests, both the same shape: BORROWED STATE

1. The tracking block relied on `Map.Show` resetting the envelope — which is exactly what another
   mutation removes, so it **stole that guard's bite**. Made self-contained with an explicit
   `ResetView()`.
2. The load-reset test then went **SILENT**, because the new Reset test left the envelope already at
   the full run — so the load had nothing to throw away and the assertion passed either way.
   Narrowed deliberately first.

**A test that borrows another guard's behaviour weakens both.** That is a fourth form to add to the
three in `memory/mutation-tests-find-weak-tests.md`.

**6 files, 120 functions, 0 persistent OnUpdate. 68 mutations bite on their own message.** v0.13.0.

---

## 57. ★★ THE LAWS, AUDITED — five families, not eleven items (2026-08-13)

Fifty-six sections and a flat list of eleven laws. The audit's finding: **they are not eleven
things.** Several are one law seen from different sides, and the flat list was hiding that — twice in
one session the same connection had to be rediscovered because nothing recorded it.

### A · WE HOLD WHAT HAPPENED — not what the world is, not what it meant

The hard spine, and everything in it is a refusal.

| | |
|---|---|
| §17 | the addon **never learns dungeons** — no box, no DBC, no shipped table |
| §54 | a point knows **type · source · state · when · where. Nothing more** |
| §14 | **never derive.** A derived point is a position nobody stood at |
| DR-9 | written **as captured** — never cleaned, merged or deduped |
| §55 | **we build the instrument, not the expertise** *(held lightly)* |
| — | five refusals to hold a roster or a list of anything the user owns; the refusal to become a heatmap |

**Two edges of one law: no WORLD knowledge, no MEANING knowledge.** §17 and §55 are the same
sentence — one refuses facts about the dungeon, the other refuses facts about how to play it.
Anything that starts telling the user what a good route *is* has crossed it, **and it will look like
helpfulness on the way over.**

### B · EVERYTHING ENTERS THROUGH CAPTURE, AND EVERYTHING DOWNSTREAM INHERITS

| | |
|---|---|
| §29 | **capture is the only spawn** — nothing is created from nothing. ⚠ The gate is on ORIGIN, **not on position**: dragging a promoted beacon is the user's choice (§60) |
| DR-36 | where the client emits nothing, **the player is the sensor** — and the pin carries no meaning until promote |
| DR-35 | **sample in combat too** — don't decide at capture what will matter, because the learner doesn't know yet either |
| §25.2 | promotion **copies the base; z is inherited, never computed** — ⚠ under EDITING that is a **teacher, not a gate**: drag far from the source and the beacon sits at the wrong height, visibly (§60) |
| §56 | the **sequence integers ride free from source** — order is inherited, not authored |

**One law: nothing downstream INVENTS what capture already holds.** Every violation looks like a
feature (a derived midpoint, a computed z, a connect-the-dots UI) and every one replaces a fact with
a guess.

### C · THE VIEW IS A LENS. IT HAS NOWHERE TO WRITE

| | |
|---|---|
| §43 | **curation edits the VIEW, never the capture** |
| §49 | **availability follows visibility exactly** — filtering hides, it never fades |
| §36 | **location sorts the list; it never chooses the view** |
| §48 | all curation state is **transient** — filter views aren't saved, the envelope *can't* be |

**Structural rather than a discipline:** with nothing persisted, there is nowhere for curation to
write even if a future build wanted to.

### D · THE DISPLAY GRAMMAR — his taste, crystallised

| | |
|---|---|
| §46 | **colour = combat state, shape = what kind.** Red in, blue out; dot · swords · cross |
| §38 | **enter over exit** — enter is the encounter's geometry, exit is where you happened to be |
| §38/DR-36 | the ladder: `pin > dead > start > done > leg > combatleg` — and it decides the CLICK, not only the draw |

⚠ **Do not re-derive these from first principles.** They came from his eye on real draws. If one
seems wrong, that is a question for him, not an argument to make.

### E · BUILD HYGIENE

| | |
|---|---|
| §34 | separate frames, so a bug in one cannot break the other |
| — | **zero persistent OnUpdate** — install on demand, clear when the work stops. Asserted in the smoke, not just the census |
| — | every guard gets a `mutate.py` entry. **An untested guard is what this exists to make visible** |

---

## ⚠ ANTI-STATEMENTS — read before adding to this brief

Every correction on 2026-08-13 had **one shape**: something TRUE, extended one step past the
evidence. It always sounds like insight, because that is the shape insight has.

**★★ BUT THIS IS SCOPE, NOT SUPPRESSION.** Battlewrath, on the list itself: *"Your instinct is to be
helpful... bring value from your own instinct which I appreciate. **So it's not to flatten input.
Just scope it on where we are.**"* The thought is usually the right thought — the fault is its
**status**. So the move is not silence, it is **offering it as an offer, marked as beyond where we
are**: *"noting it for when X exists"*, *"my reading, not a ruling"*, *"that's a guess, correct me"*.
A version of this table read as seven STOPs produces a flat, withholding agent, which is worse than
what it guards. **If in doubt, say the thing and label its status.**

| you are about to write | stop |
|---|---|
| *"there is no third / that's the complete set"* | Say **"two so far"** and name what a third would look like. If you just explained away every candidate, that is motivated reasoning wearing analysis |
| *"which means we can also…"* | A fact is not a capability. A timestamp is not pacing. A position is not a route |
| *"X hangs off Y" / "type A takes notes of form B"* | You are designing a layer that has taught you nothing yet |
| *"the data confirms he meant…"* | You had the label first. Would the data have PRODUCED it? If no, that is hindsight |
| a meaning at capture time | A pin is a point. Promote gives it meaning |
| a caveat that is not a risk | Proven and untouched is a fact about the fixture, not an exposure |
| a law | Did it come from **play**, or from thinking harder? Only the first earns the word |

**★ And the second-order tell: when a framing is rejected, the right next output is SHORTER — not a
different framing.** Withdraw, state the smaller true thing, stop.

Full version, with his words attached: `memory/dont-extend-past-the-evidence.md`.

---

## 58. DR-31 IS BOSS **TAGS**, NOT BOSSES — and an easy test settled it (2026-08-13)

His question: *"Is that from the boss unit frame / engagement tag, or unique name alone?"*

**The engagement tag and the boss unit tokens, never a name list.**
`INSTANCE_ENCOUNTER_ENGAGE_UNIT` fires, and we then read `boss1`..`boss5` with `UnitExists` and
`UnitName`. Those tokens are server-populated for the encounter; Blizzard's boss frames are just
another consumer of them, so it works whether or not those frames are shown. No roster, no matching,
nothing shipped — which is why it stays inside §17.

### The test he asked for: who shared a firing with whom

`SFK_Run4`, all 19 firings, in order:

| pull | the boss-token set at that moment |
|---|---|
| 2 | Rethilgore ×2 |
| 6 | Razorclaw ×2 · **Razorclaw + Baron Silverlaine ×2** · Silverlaine ×1 |
| 9 · 13 · 14 · 20 · 24 · 25 | Springvale · Odo · Midwinter · Fenrus · Nandos · Arugal — **one name each, ×2** |

**19 firings · 8 pulls · 9 distinct names · exactly ONE co-occurrence.**

So the doubling is **the event firing twice per engagement**, not a second unit — and his sub-boss
reading holds in exactly one place: **pull 6 engaged two tagged units at once.** Which is a real fact
about that route, and a more interesting one than a boss count: that pull took two.

### ★ Why the word had to change

> *"People think boss, they think the big enemy they're hitting. But we don't need to pretend we
> know."*

We hold **unit names that carried a boss token at a moment, inside a pull.** Whether two of them
belong to one fight is dungeon knowledge, which §17 says we do not hold — so 9 names is **not** 9
fights, and we have no way to tell which. Calling the field "bosses" asserts encounter structure we
never captured.

His framing for what it actually is: **the same shape as "what died in this pull", except the boss
tags are what flew out.**

⚠ Consequence for the display: if this is ever surfaced it must be labelled per-pull as tagged units,
not as a boss list or a count. **The record is right; only the word was wrong** — which is why this
is a wording fix and not a capture change.

---

## 59. ★★ THE NEED — pull COMPOSITION, and the assessment stays human (Battlewrath, 2026-08-13)

**DESIGN ONLY. Nothing built.** This closes the step his own ordering left open: study → best-fit →
**then** cadence and consumption need. Cost was retired by measurement (`cleu_on_this_fork.md`); this
is the *why*.

### The need, in his words

> *"Routes, and in M+, per unit carries a value to complete the dungeon. So knowing what pulls what
> mobs leads into — is this the optimal unit size. Could 2 pulls be merged. **We don't try to know
> the values. That's the runner of the addon deciding this in combat. Then having an inspectable
> surface after to optimise.**"*

So the question a route designer is actually asking is **was that the right pull**, and answering it
needs to know **which mobs were in it**. That is pull COMPOSITION.

### ★ It is the first need that genuinely requires CLEU

Everything else this addon holds arrives from events the client hands us for free — regen edges, the
death recap, boss tags. **Composition cannot come from any of them**: DeathRecap is only *your* death,
and boss tags are only tagged units. `UNIT_DIED` is the one thing that answers it.

**And it joins on `n`.** Markers and combat legs already carry the pull index, so a death stamped
with `n` slots into the existing structure — same join, one more kind of thing hanging off it. No new
concept.

### ★★ WE DO NOT TOUCH THE ASSESSMENT

> *"We don't touch the assessment. That's curation. We just provide the record. And it's the route
> designer's eye and assessment. Pen and paper."*

Not just the M+ values — **the reasoning itself.** A first draft of this note offered that distance
and time between pull starts are computable from records we already hold, which is the assessment's
arithmetic done on the designer's behalf. It is out.

**⚠ The consequence lands on the DISPLAY, not only the logic.** A surface that sorts pulls by size,
or highlights close pairs, is assessment wearing UI. Pulls get presented **neutrally** — this is what
pull 6 was, this is what pull 7 was — and the comparing belongs to the designer.

**The precedent is the flip book (§54).** It did not answer the cluster question; it made the thing
visible and the question dissolved. Same move: **make the record legible, do not reason over it.**

And it sharpens why the record must be rich. If we are deliberately not helping, the record has to be
complete enough to reason from unaided — **the designer does not yet know which mob will turn out to
matter.** Same argument as §55, arriving from the other side.

### Where it attaches

**The combat START marker carries the composition** (his call). Consistent with §38: enter is the
deterministic point, the fact about the encounter, so what the encounter *was* belongs to it. The
deaths are known by combat end and written back to the pull they belonged to.

### ★ The end markers do two different jobs, and one of them is empty

**"Combat exit competes with terminal stop. Which does a different job."** Both are `kind = "end"`
today, separated by `dead`. But they answer different questions:

| | reports |
|---|---|
| **terminal stop** | *you died, and here is why* — `killedBy` already does this (DR-32) |
| **combat exit** | *you survived — by this much* — **nothing today** |

His idea: **grab player HP at combat exit.** One API read on an event we already handle, which is
exactly DR-13's shape — *"one API read on an event we already handle, and without it a wipe and a
clean finish are identical in the record."*

It is a captured fact, not a judgement: *that pull left me at 8%* is route information the designer
reads and acts on. We never say the pull was dangerous.

⚠ Mine, not his, and correct me: capture **current and max** rather than a percentage. A percentage
alone loses the raw numbers and picks a normalisation on the reader's behalf; both is free.

### ⚠ Not decided

- **Nothing here is built**, and nothing above says what the surface looks like beyond *neutral*.
- **M+ keystone level and affixes remain an accepted gap** — no access to probe (`cleu_on_this_fork.md`).
  Composition does not depend on them; it is useful in any dungeon and merely matters most in M+.
- The listener itself is unwritten. The shape is settled (`push with a lean mask`), the cost is
  measured, and **the need is now on record** — which is the last thing that was missing.

---

## 60. THE ROUTE OBJECT AND THE IN-ROUTE SURFACE — captured intent (Battlewrath, 2026-08-13)

**★ THIS IS CAPTURED INTENT, NOT LAW.** His instruction on recording it. Nothing here is built,
nothing is settled, and the parts he called undefined are left undefined rather than filled in.
Written down because it was worked out in conversation and would otherwise be lost.

### The objects

| | |
|---|---|
| **Run** | the product of **capture**. Heavy. The record |
| **Route family** | the **envelope / table / transportable data set** that wraps the beacons — *"what the route selector and the run-time run against"*. Lean. The deliverable |
| **Beacon** | a node inside a route family, carrying a **Stage** and a **Cue** |
| **Personal note** | map-anchored, and **escapes route membership** entirely |

**The family is one object doing three jobs** — what the selector lists, what the runtime runs, and
what travels. Which means **what you run is exactly what you share**: no packing step, no separate
export format, no chance of the shipped thing differing from the tested one.

So route-level facts live on the **family**, not on beacons — name, mapID, description.
(⚠ An earlier draft said *"and whatever provenance the trust asymmetry requires"*. **Dropped** — a
route is a plot table with nothing to authenticate; see §25.2.) Beacons stay cheap, which matters when they
are the thing read mid-fight.

⚠ Structurally it is the Run's shape at a different weight: an envelope of identity plus an array.
The storage pattern therefore already exists rather than needing inventing (DR-20).

### The promotion form — his fields

```
Name:
Type:           Personal Note | Beacon    ⚠ SUPERSEDED by §61 - it is the BUTTON you pressed
Stage:          (beacon only — unique within the family)
Cue:            (beacon only)
Note:
Radius listen:
Radius close:
Icon pick:      (⚠ §61: a CURATED set, not the whole atlas)
```

*"Both have a projection and satisfy space."* Three of those already have a fact basis rather than
needing invention:

- **`Radius listen` / `Radius close`** sit on characterised ground — the client gives distance, and
  the Landmark arc mapped the tiers including the 5-yard *Interact with* boundary.
- **`Icon pick`** has `maps/atlas/` behind it: 4,503 named entries classified by **claim of use**
  (1,359 claimed, 3,144 free), so a picker can offer what is genuinely unused.
- **`Stage`** is the sequence integer that *"rides free from source"* materialising — inherited as a
  default and **editable**, which is the overwrite §48 called for.

⚠ Mine, not his: `Type` being a **field** rather than two object kinds means one record shape with a
discriminator. That may be what §29's "two sinks" was always describing — one object, two
destinations — and would also explain why *a note that also needs a beacon* feels like an awkward
third rather than a natural one.

### ★★ A ROUTE DOES NOT KNOW ABOUT RUNS

> *"Start new route. It doesn't know about Runs, it just knows nodes are on the map to child from /
> copy from. But they exist in the table of that route."*

**It copies; it does not reference.** That single decision reconciles four things already on record,
from a direction none of them anticipated:

- **A route survives its source run being deleted** — which matters because delete-the-whole-run is
  the only destructive verb we have (§48), and a referencing design would have made it capable of
  orphaning routes, forcing us to weaken it.
- **A route can be built from more than one run** with nothing added for it. Nodes from two captures
  are just nodes on the map.
- **It is why §25.2's "promotion copies the base" mattered** — recorded as a z rule without seeing
  the larger reason: copying is what makes the route independent.
- **It is what lets a route travel.** §48's trust asymmetry required a shared route to stand alone,
  because the consumer gets no evidence trail.

⚠ **A route is a SNAPSHOT, and divergence is expected rather than a fault.** Re-curate the run
afterwards and the route does not move. Correct, but the kind of correct that reads as a bug the
first time someone meets it.

⚠ And *"nodes on the map"* means a route's contents are a function of **what the map was showing when
you promoted** — which is exactly where §48's aggregate-view trap lands. The overwrite is the
mitigation; the pre-flight walk (each node big in turn) is what makes a wrong pick visible.

### Validity is by mapID, NOT difficulty

> *"The object is what tells the selector that the route is valid for the dungeon that you're in. By
> MapID, not difficulty. That is user choice based on description, we just surface the designers
> intent/meaning."*

**Gate on facts, surface meaning.** MapID is structurally true; whether a heroic route still applies
on normal is a judgement, and judgement is the user's with the designer's words in front of them.

⚠ **This looks like it contradicts DR-30 and does not.** DR-30 says a normal and a heroic pass are
different routes *so difficulty is route identity* — that is about **capture**, where difficulty is
an unrecoverable fact about what happened. This is about the **selector**, which does not enforce the
match, because deciding a route invalid for a bracket would be us judging content.

**Consequence: the description becomes load-bearing rather than decorative.** It is the only channel
a designer has to say *"this is a +15 route, the normal pulls are bigger"* — so it cannot be buried
behind a hover or truncated in the selector. It carries the weight our refusal put down.

And it keeps route count low: one route serves every bracket unless the designer chooses otherwise.
*"A route may hold useful from mythic to mythic +5. Breakpoint is for the tank and the designer to
negotiate — and for the tank to fail and seek otherwise. Or make their own run and route on what
they learned."*

**★ That closes a loop: the route's failure mode IS the learning event**, and the thing that teaches
it produces the next capture.

### Editing, and where the gate actually is

> *"A route can be edited. But it needs run data / nodes populated to spawn new events. And users
> dragging beacons everywhere is improper — but user choice. We give them tools to do it well. But we
> don't gate them."*

**ORIGIN is gated; POSITION is not.** A beacon must come from a capture. Where the user drags it
afterwards is theirs — improper, and allowed. See the §29 wording correction below.

**Editing a route is more promotion, not a different verb**, so a route can only grow where captures
exist. That is a constraint *from the data* rather than a rule imposed on behaviour: the user is not
told no, they are told there is nothing there yet, and the fix is to go and run it.

**And the "tools to do it well without gating" property is already built.** §25.2's inherited z stops
being a prohibition and becomes a **teacher**: drag a beacon far from its source and it sits at the
wrong height, visibly. The design shows you that you went too far instead of stopping you.

### The in-route surface — his vision

- **A heading view that always frames you, the current beacon and the next one.** The in-game
  minimap is poorly implemented; this is *"broader context on heading"*. ⚠ Note: this is `map.lua`'s
  projection with a **computed viewport** rather than the whole dungeon at fixed bounds — same
  arithmetic. Which means it inherits the floor problem: a next beacon on another floor has to be
  *said*, not silently omitted.
- **Two note planes at fixed positions** — personal above, route below. **Collapse when empty rather
  than appear**: *"appearing or moving around is attention cost."*
- **Beacons progress automatically**, with a **display range** and a **satisfied range**, biased to
  **show EARLY**: *"you mostly want the information before you are about to engage, rather than as
  you do."*
- **In combat suppresses the next beacon** — *"it's mental load when you need to focus."*
- **A progress count gates overlapping beacons.** Player at 3/20; beacon 19 needs state 18.
  ★ This is the same move as the time window arriving from the other end: **authoring de-duplicates a
  self-crossing route by TIME, consumption de-duplicates it by SEQUENCE STATE.**
- **Correction via `< [current] >` is POST-FIGHT.** *"The user shouldn't be trying to fix position
  whilst fighting."*
- **On a terminal stop, re-pin the last state.** ⚠ Already supported by the record: the terminal
  marker carries the pull index it died on.
- **Maybe a hide-all** — hides notes, suppresses beacons, **keeps tracking**. Un-hiding is a
  **resume of current state, not a backlog**: *"you've already resolved the challenge the information
  was to help."* ★ Stale guidance has no value, which is the opposite of stale capture.
- **Cue text anchored above the beacon** — *"LOS", "Kick X"* — so the highlight is readable without
  reading the note. ⚠ Feasibility: `C_SuperTrack.GetSuperTrackedPosition()` returns **screen x/y**
  plus validity, so a fontstring can be anchored there. The satnav probe's finding B is the thing to
  design around — **screen position goes invalid off-screen while the distance survives**, so
  "beacon is behind you" needs an explicit answer.

### ⚠ The law it might be, once there is something to test it against

**The route never asks for attention during a fight.** In-combat suppression, post-fight correction,
cues instead of notes, show-early rather than show-on-arrival and no in-route configuration all fall
out of it. If it holds, it is also the test: anything the design wants to add gets asked whether it
costs attention at the wrong moment.

Held as an observation, not adopted.

### ⚠ Undefined — left undefined on purpose

- **A note that also needs a beacon for a specific pull.** *"Might be a self inject option. But
  that's down the road."*
- **Whether `Cue` is capped.** It is the field read mid-combat, so "LOS" and a sentence are different
  products — the same argument as the comment's 40 characters.
- **Whether `listen` must be ≥ `close`.** Probably a validation rather than a choice.
- **Whether the in-route surface is one thing or two** — running someone else's route is not obviously
  the same as running your own while still forming it.
- **Whether the stepper is the fallback or the primary.** Automatic advance with manual recovery, or
  the user driving and the addon confirming. Play answers that in ten minutes; argument does not
  answer it at all.

---

## 61. THE PROMOTER — scoping, captured intent (Battlewrath, 2026-08-13)

**★ CAPTURED INTENT, NOT LAW.** Same treatment as §60. Nothing built, and the open parts are left
open rather than filled in.

§43's third surface: **what does this become.** A separate frame for the same build-hygiene reason the
curator is separate, acting on the map's selection, which stays map-owned and one-way (§34).

### His layout

```
[Personal note]                     <-- ALWAYS available
------------------------------------
[Select route  v]                   (selection loads that route's existing beacons)
[Name]                              (populated by selection, or typed to create)
Node selected;
What information will carry over from the node

[create beacon]
```

*"Everything from there is then in-field of the new node."*

### ★ Three things that layout settles

**1. `Type` is the BUTTON YOU PRESSED, not a field.** §60 recorded `Type: Personal Note | Beacon` as
part of the form. This supersedes it: personal note above the divider, create beacon below, and the
route selector between them **because it only gates the second one**. One less decision, and the
structure explains itself.

**2. CREATE THEN EDIT — and it is the house pattern's third appearance.** The beacon exists the moment
you press create, carrying only what it inherited; everything after is edited in-field. Capture then
promote · pin then meaning · mint then author. **The mechanical part is immediate and the meaning
waits**, which is also why none of the three needs a dialog.

**3. `+ create new` belongs IN the dropdown**, as its first entry. That makes the mode a *selection*
rather than something inferred from how you typed — and it is the pattern the curator's run selector
already set tonight, where `- no run -` is a real entry because unloading must be as reachable as
loading. **The separate `[create route]` button falls out**: one control instead of two, and no state
where the name field's contents mean different things depending on what you did before.

### Renaming follows the RUN's method

His ruling on the one inconsistency: *"follow the current form / discipline. So follow the run's
method. The user can expect the same in both surfaces."* So a route is renamed by a **button with the
client's own confirm**, exactly as a run is — which costs nothing to build (already wired) and nothing
to learn (already known).

**Consequence: the name field stops being dual-purpose.** Text entry when `+ create new` is selected,
because you must type something; a **label with a Rename button** when an existing route is selected.
The field never distinguishes modes, because the dropdown already declared which.

### "What information will carry over from the node"

Doing more work than it looks. It makes the **inheritance visible before commit** — the same move as
the map strip naming the tile file, a borrow shown rather than assumed. It also pre-empts the z
question: you *saw* z come from the node, so when you drag the beacon later and it sits at the wrong
height, that reads as the design telling you something (§25.2's teacher) rather than as a bug.

### The two halves

| | |
|---|---|
| **Create** | a selected node becomes an object. Name · Cue · Note · Stage · Radius listen · Radius close · Icon — all edited in-field after minting |
| **Manage** | a family's beacons listed: edit, renumber, drag, delete, and the **pre-flight walk** (step the sequence, each node big in turn). That belongs here because it reads a ROUTE, not a record |

### ★★ THE STRUCTURAL CONSEQUENCE — the map must hold TWO things at once

*"Selection loads existing beacons."* So the working state is a run's nodes **and** a route's beacons
on screen together — you promote *from* one *into* the other.

**The map today holds exactly one loaded thing (`shownRunId`)**, and everything around it assumes
that: the caption, the floor seed, the time envelope, the reset-on-load. **This is the largest single
implication of the promoter, and it lands on the MAP rather than on the promoter.**

It also implies **a second tick row** — run nodes and route beacons want independent visibility,
because half the time you are checking placement against the trail and half the time you want the
trail out of the way.

### ✅ Display — RULED

**Beacon and personal note live on TOP of the ladder** (his call, confirming the inference). So it
extends to:

```
beacon · personal note  >  pin  >  terminal stop  >  combat enter  >  combat exit  >  travel leg  >  combat leg
```

The reasoning holds all the way down: **the authored thing outranks its raw material**, the pin is the
most deliberate *capture*, and everything below that is emitted by play. Burying a product under its
own source inverts the ladder's logic — and since the ladder decides the **click** as well as the draw
(§38), a beacon you cannot select because a leg sits on top of it would be the same fault in a worse
place.

✅ **And colour is RULED, by being the wrong question.** *"Just iconography of the item. It has
meaning."*

**The two object classes use different visual languages, because they answer different questions:**

| | |
|---|---|
| **capture points** | **colour = combat state, shape = kind** (§46). Facts about what happened |
| **promoted objects** | **iconography carries the MEANING** — what the beacon asks of you |

That is the right axis for an authored thing: a beacon is not reporting a state, it is an
**instruction**. His two examples are already two different words — a kill/pull vignette (*"brown with
a silver cross"*, his description, atlas entry to be resolved when the set is chosen), and one for
*"stop, there's a jump, a thing, not just movement."* **Movement versus action** is a distinction
colour could not carry and an icon can.

★ **Which raises what `Icon pick` is.** In a curated set, **each icon is a word in the vocabulary** —
so adding one is a design act rather than a convenience, and the set stays small for the same reason a
language does.

### ✅ The promoter takes the SAME none-option

*"The promotor needs the same none display option. So it's fluid in what you load and see and work
on."*

So the route dropdown carries `- no route -` exactly as the run selector carries `- no run -`, and
for the same reason: **unloading must be as reachable as loading** (§36). Third surface, same pattern.

**★ Which resolves the two-things-at-once problem cleanly rather than complicating it.** The map holds
**two independent slots** — a run and a route — each loadable and unloadable on its own. Run only,
route only, both, or neither. That is one more slot rather than a new concept, and it is exactly the
*fluid* he asked for.

### ✅ Icons are a CURATED design language, not the atlas

*"The icons will be more specific design language. Using the one we selected and a few more, rather
than exposing the user to the full DBC."*

So `Icon pick` offers **a small chosen set**, not a browser over 3,144 free entries. That is
plays-by-flattening-decisions applied to authoring: the taste is spent once, by us, and the user
picks from a vocabulary rather than a warehouse.

⚠ It also relocates what `maps/atlas/` is FOR in this feature. It stays the fact basis — which entries
are free, which are claimed — but it sits **upstream of the user** as the source we choose from, not
the picker we ship.

### What it refuses

**No creation from nothing** — it needs a selected node, and that is a constraint from the data rather
than a rule: nothing there yet means go and run it. **No assessment** — no sorting by size, no
suggesting merges, no scoring. The pre-flight **shows**; it does not judge.

### ⚠ Open

- **Does the promoter create families, or does that live elsewhere?** The dropdown answers it for now.
- **Is dragging in the promoter or the curator?** It edits a promoted object (promoter) but happens on
  the map (neither).
- **What happens to Stage when a beacon is deleted?** Renumber and the gate keys shift under any route
  in flight; leave gaps and *"19 needs 18"* needs a rule for a missing 18.
- **One pane or two.** Create and Manage may not want the same frame, and five minutes of use will say
  more than any amount of argument.

---

## 62. THE MAP'S SECOND SLOT — built (2026-08-14)

§61's largest implication is not the promoter's layout. It is that **the map can no longer hold a
run.** You author a route by looking at the evidence it came from, so a run's nodes and a route's
beacons have to be on screen together. One slot cannot do that.

Built as **a table of layers**, not as a second variable:

```lua
local LAYERS = {
    { key = "run",   timed = true,  art = true,  lists = RUN_LISTS },
    { key = "route", timed = false, art = false, lists = { "beacons" } },
}
```

Four facts per slot, and every difference between the two is one of them:

| fact | what it decides |
|---|---|
| `key` | how the selector addresses the slot |
| `timed` | is this source on the RUN'S timeline (§48)? |
| `art` | may it decide which dungeon art we draw? |
| `lists` | which of its lists carry drawable points |

A third slot costs one row. That is what the table is for — **it is not a prediction that there
will be one.**

### ★★ `timed` is the one that matters

`Map.Show` reset the time envelope on every load, because there was only ever one thing to load.
With two slots that becomes a bug you would not report as a bug: you trim a window down to the
pull you care about, load a route to work against, **and the window silently goes back to the whole
run.** That reads as the map forgetting, not as a fault, so it would have survived a long time.

`Map.Load(key, id)` gates floor-seeding and the time reset behind `if L.timed then`. The route slot
loads without touching the run's view at all.

Time also does not FILTER the route layer — and that holds twice over: the layer declares
`timed = false`, and a route has no legs to give `TimeSpan` an origin. Worth stating precisely
because no single edit can flip it, so no mutation can speak to it; the smoke asserts the behaviour
and says why the mutation table is silent there.

### What moved

- `Map.PointsOn(run, floor, lists)` — the lists are the LAYER'S to declare. Hard-coding legs+markers
  is exactly what would have made the second slot paint nothing at all, silently.
- `Map.VisibleOn(run, floor, timed, lists)` — `timed` defaults **true**, so every existing caller
  keeps the run's behaviour untouched.
- `Map.Painted(floor)` — the one place that knows the map shows more than a run. `paint()` just draws
  what it hands back.
- `Map.LayerShown / SetLayerShown` — a **different axis** from the §43 tick filters. A tick hides a
  KIND wherever it came from; this hides a SOURCE whatever kinds it holds. No art-key filter could
  express it, because a route's beacons and a run's markers share kinds.
- `Map.LoadedId(key)` defaults to `"run"`; `Map.Show(runId)` stays as the run alias.
- `Map.Caption(run, mapFile, n, routeName)` — a route alone is a legitimate view (§61's none-option),
  and "no run loaded" over beacons that are plainly on screen leaves the loaded thing unnamed.

### The integration point is real, not a seam

The route slot resolves through **`NS.Routes`**, which is what the promoter will provide. Until it
exists the slot resolves to nil, which is indistinguishable from empty — so the second slot ships
**inert rather than broken**, and the day the promoter lands there is nothing on the map side to do.

### ⚠ Not built

The **selector** for the route slot. §61 wants the same none-option and the same discipline as the
run selector, and that belongs with the promoter rather than ahead of it.

---

## 63. THE PROMOTER — the MINT, built (2026-08-14)

§61's third surface, first slice. `routes.lua` (the objects) and `promoter.lua` (the pane), opened
from a **button at the bottom of the curation pane** — his placement.

### ★ THE ORDER IS BUTTON PRESSES, NOT A SEQUENCE

His correction, and it matters enough to be the first thing in this section. I had written the chain
**Map → Curation → Promotion** as though the system enforced it — "one path in, no second door",
"you must arrive through curation". He scoped it back:

> *"the order is button presses. Nothing forced as in sequence. In reality the map doesn't care.. it
> just accepts load conditions."*

So the placement **suggests** and never gates. Run only, route only, both, neither, notes-with-no-run
— every combination is legal and none of them is arrived at *wrongly*. Nothing in `promoter.lua`
checks how you got there, and it works opened first.

The value argument stands on its own without being a rule: *"without opening and loading
curation/run, the edit palette of promotion has little meaning. And worst case it's a ritual to get
to editing beacons / notes. But it's like opening a briefcase."* And the escape hatch is cheap
because `/dr` already exists — *"for power users we might make it a macro hook."*

### What was built

| | |
|---|---|
| **`routes.lua`** | route families, beacons, and the personal-note planes. Owns the SHAPE; `store.lua` still owns the global (DR-20), so DR-21's schema refusal covers all three data forms for free |
| **`promoter.lua`** | his sketch exactly — `[Personal note]` above the divider, route dropdown, name-or-label, the carries-over readout, `[Create beacon]` |
| **`editor.lua`** | the `Promotion` button, bottom-left, opposite Close |
| **`map.lua`** | promoted art, the ladder top, and §60's note plane as a **third layer** |

### ★★ WHAT CARRIES OVER — the one rule

```
PLACE carries.      x,y,z · mapX,mapY,mapC,mapZ · floor · mapID
EVENT does not.     t,gt · kind · n · combat · dead · killedBy · ghost · zone
```

A beacon is a statement about a **spot**. When that pull happened, what it was, and who killed you
there are facts about a *capture* — true of the run, not of the place — and copying them would make
the beacon assert things it cannot know for the next person to stand there. §60 already said it:
**origin is gated, position is not.**

Written as an explicit **whitelist**, not a copy-with-deletions. A field added to capture tomorrow
must be a *decision* to carry; the other direction fails silently, with the beacon quietly starting
to assert a new fact nobody chose.

★ `z` rides in that list, which is §25.2 doing its teaching job: inherited, never computed, so a
beacon dragged to the wrong height reads as the design telling you something.

### ★★ PERSONAL NOTES ARE A PRIVACY PROPERTY, not just a plane

§60 put notes on their own plane. Built, that turns into something sharper: **a note must never be
inside a route**, because a route is the exportable object and a note is yours. If notes lived in the
route table, sharing a route would publish your own annotations without anyone being asked. The smoke
asserts it directly, and the mutation for it is the plausible one-word version — the note plane drawn
from the route table.

Notes are keyed by **mapID** (one plane per dungeon, nothing to choose), and `GetNotes` deliberately
does **not** create: the map asks constantly, and a plane minted by looking at it would put an empty
table in the save file for every dungeon you ever opened the map in.

### The display

Promoted objects speak a different visual language (§61): capture points use colour = combat state
and shape = kind; a beacon is an **instruction**, so its **iconography** carries the meaning. A beacon
draws as **its icon** — the word the author picked — with a fallback so a route authored on a later
build carrying a word we do not have draws as a beacon instead of taking the map down.

Three words so far, rectangles read from the client's own `SharedXML/AtlasInfo.lua`:

| word | atlas entry | |
|---|---|---|
| `note` | `chatballon` | a speech balloon — a thing you said to yourself |
| `beacon` | `vignetteevent` | the default a beacon mints with |
| `kill` | `vignettekill` | his own pick, *"brown with a silver cross"* |

⚠ The word for *"stop, there's a jump, a thing, not just movement"* is still **open** — his to choose,
and one row when it lands.

**Ladder:** `note > beacon > pin > dead > start > done > leg > combatleg`. §61 ruled promoted objects
above the pin. ⚠ It named the pair *"beacon · personal note"* **without ordering them against each
other** — note-above-beacon is **my call**: a route may carry twenty beacons and your notes are few
and yours, so when they collide the one you can still reach should be your own. One number to change.

### Two things this forced

**Many selection listeners, not one.** `Map.SetOnSelect` held a single slot. With a third surface,
whichever pane initialised last would silently take it and the other would simply never update —
which looks like a dead pane, not like a wiring fault. Now `Map.AddOnSelect`, and nothing changed on
the map's side of the boundary: it still knows nothing about who listens.

**§60's note plane cost one row** of §62's layer table. That is the door left open being used the
first time it was needed, one day later.

### ⚠ My call, flagged: minting from a promoted object is refused

Selecting a beacon and pressing Create would duplicate it, with a position someone had already
dragged. Refused as a fact about the data — *that is not a node* — the same shape as §61's other two
refusals. §61 does not name this case. Cheap to reverse: one function and one caller.

### Not built (designed in §61)

- **The in-field editors** — name · cue · note · stage · radius listen · radius close · icon pick.
  CREATE THEN EDIT means the mint is immediate and the meaning waits; this is the waiting half.
- **The Manage half** — list, renumber, drag, delete, the pre-flight walk.
- **The second tick row** (§61) — run nodes and route beacons want independent visibility. The
  mechanism exists (`Map.SetLayerShown`, §62); the checkboxes do not.
- **The macro hook.**

### An open question answered by not moving

§61 asked what happens to `Stage` when a beacon is deleted. `Routes.DeleteBeacon` **leaves the
survivors' numbers alone** — renumbering would shift the gate keys under any route in flight. Gaps
are the cheaper problem, and *"19 needs 18"* wanting a rule for a missing 18 is a question for the
in-route runtime, where it can be answered with the route in hand.

### ⚠ §63.1 — the first deploy found two, and both were the SAME MISTAKE

Battlewrath, on the first live run: *"either the event driver or the wiring into record creation for
promote isn't active. And note is greyed regardless of state."* Two symptoms, and underneath them two
faults that are the same shape — **an assumption that held while the map had one slot.**

**1. The promoter never registered for the selection.** §63 grew `map.lua` from one selection
callback to many *specifically so this pane could listen* — and then did not call `Map.AddOnSelect`.
So `refresh()` ran once at Init, with nothing selected, and both buttons latched disabled forever.
The whole surface reads as dead.

★ The smoke asserted the map could **serve** two listeners and never that the promoter **was** one.
A guard whose failure case the fixtures cannot reach is not safe, it is untested — the fifth time
that law has caught this class here. The fix is one line; the coverage is a **pane block** that
stubs the frames and drives the thing end to end: select a node → note enables → mint → the record
exists → pick `+ create new` → name it → create → the beacon exists, the route loads, and **three
points draw from three layers at once.**

**2. `Map.Load` cleared the selection on EVERY load.** Correct with one slot; with three it destroys
the promoter's entire working gesture — *select a node, load a route, mint* — because the node is
gone by the time you get there. Minting a personal note loaded the note plane, which dropped the very
node it had just copied.

★★ **This is §62's time reset again, one layer down.** The rule was never "loading clears the
selection"; it was **"nothing is selected which is not on the map."** Now:

```lua
loaded[key] = src and id or nil
if not stillLoaded(selected) then selected = nil end
```

`stillLoaded` walks every layer's raw lists — deliberately the RAW lists, not the visible ones, since
a point hidden by a tick filter or scrubbed past by the time window is still loaded, and unselecting
it because you moved the window would fight the user.

★ **And the old test said the right thing about the wrong fixture.** It claimed *"a point from the
previous run cannot survive a load"* while selecting a point of the run it then loaded — which stays
on screen and proves nothing. Repointed at another run's point, so the assertion now tests its own
sentence, and the surviving half got the guard it never had.

**Also:** `Map.Load` fired `fireSelect(nil)` unconditionally. It now announces whatever the selection
**is** — which may be unchanged — because telling every pane to clear a point still on screen is the
same bug wearing a different coat.

### §63.2 — the second deploy: order of operations, and the plane nobody loaded

**1. ★★ A ROUTE IS OPENED, NOT MINTED FROM SOMETHING.** Battlewrath: *"a route can't be created
without minting a beacon, currently, but order of operations wise that compounds two choices into one
only option. Starting a route is like starting a run. Just enter the name. Collection follows."*

Taken, and it was my misreading of §61 rather than a gap in it. §61's *"one control instead of two"*
is about the pane not growing a second **button** — I turned it into the route being created as a
**side effect** of placing the first beacon, which made a selected node a precondition for having a
route at all.

The fix keeps one control by making **the button's verb follow the mode**, exactly as the name
field's mode is declared by the dropdown:

| mode | button | needs |
|---|---|---|
| `+ create new` | **Create route** | a name, nothing else |
| a route loaded | **Create beacon** | a selected node |

`Routes.Create` was already free of any node; only the pane had tied them together.

**2. Nothing ever loaded the personal-note plane except minting one.** The only call site was inside
the mint, so notes were recorded and then invisible the moment you reloaded — with no selector to
bring them back, and by his own framing there should not *be* one: **one plane per dungeon and
nothing to choose between**, so a selector would be a decision with a single answer.

The plane now **follows the view**, and follows the *run* rather than the player — §22 edits a route
from a city, and the notes that belong on screen are the ones for the dungeon being LOOKED at. With
nothing loaded, where you stand decides. `SetLayerShown("notes", false)` remains the way to quiet
them; that is a different question from loading them.

**3. ⚠ Known and NOT fixed: a fresh mint hides under its own source.** *"The node selection to spawn
it had priority until I selected something else, then that updated."*

The selected point draws at frame level 10 — above the whole ladder, deliberately — and a minted
object inherits the node's exact position, so it lands underneath the selection ring until you look
away. Every remedy costs more than the symptom: clearing the selection after a mint breaks minting a
note *and* a beacon from one node, and demoting the selection buries the thing you are pointing at.
Recorded as cosmetic, self-resolving.

### ★ Two weak tests found while covering this

- **`Map.Painted` is a QUERY, not a record of what drew.** Both "the mint repaints" guards asserted
  against it and were silent under mutation — removing the repaint changes nothing Painted can see.
  Rewritten against the **dots**, which are the picture.
- **The frame stub answers any non-underscore key with a no-op function**, so `o.point` was truthy on
  every frame ever made and the new dot count silently meant *"how many frames exist"*. `rawget` —
  the same trap the map smoke already documents, which is exactly why it is documented.

### ★★ §63.3 — AUTHORING IS LOAD-DRIVEN; the RUN-SIDE is location-driven

The correction that matters most in this arc, and it is a **layer** distinction rather than a
detail. Battlewrath:

> *"On the run-side, yes, the content of the note is local to where you are. But this is all on the
> authoring side. And that should all be driven from what is loaded on the map."*

I had made the personal-note plane follow `GetCurrentPlayerPosition` — **the in-route consumer's
model imported into the authoring surface.** On the run side the player *is* the cursor and location
is the only sensible driver. On the authoring side the surfaces are driven by **load state**, and a
plane that never changed no matter what you loaded read exactly as he described it: *"either it has
no driver. Or it holds no value to check."*

| | driver |
|---|---|
| **in-route (§60, not built)** | where the player is |
| **authoring — map, curation, promotion** | what is loaded |

`Map.AuthoringMapID()` is now the single answer to *which dungeon is being authored*: **the loaded
run's, else the loaded route's, else nothing.** No player fallback, on purpose — §22 edits a route
from a city, so where your body is says nothing about what you are working on.

### ★ It exposed a bug that would have shipped looking normal

The promoter filed **new routes and new notes under `GetCurrentPlayerPosition`**. Author Shadowfang
from a city and the route is created for the city — and then never offered again, because it does not
match any map you load. Nothing would have looked wrong at the moment it happened. Both now ask the
map.

### ★★ ONE MAP AT A TIME, and the run decides which

> *"it is the map selection. So that's driven by the run. Which does create a conflict."*
> *"Routes, on creation, are on that map that's loaded. And are offered to load only for the map that
> is loaded."*

The conflict is real: a route authored for one dungeon, left loaded while you load a run from
another, draws its beacons onto the wrong art. Placed by **fraction**, they land inside corridors and
look like a plausible route rather than like an error — the same silent-wrongness class as §19's
scale trap.

Resolved on both sides:

- **Eviction.** Loading a run drops a loaded route belonging to a different mapID. Only when the two
  are *known* to differ — a route with no mapID is not one we can call wrong (§17), so it is
  unoffered rather than unloadable.
- **The list FILTERS.** `Routes.List(mapID)` returns only that map's routes, and **nothing at all**
  when no map is loaded.

★ **This is a filter where §36 is a sort, and the difference is which fact does the work.** §36 says
LOCATION sorts and never picks, because where your body happens to be is not a choice about what to
work on. **The loaded map IS that choice.** So offering another dungeon's route is not helpfulness —
it is offering to draw beacons onto art they were never placed against. The dropdown's groups
disappear with it: there is one dungeon on offer and the map already names it.

**Consequence, stated plainly:** with nothing loaded the promoter offers no routes and cannot create
one. That is the briefcase — the authoring surface has nothing to work on, and says so.

---

## 64. THE PREMISE — three surfaces, one authority (Battlewrath, 2026-08-14)

### The chain

**Map (rendering space) → Curator (selection) → Promoter (creation).**

*"One can't come before the other."*

Two levels, and they do not conflict. **In the UI there is no gate** — any pane, any order, nothing
checks how you arrived. **In the data there is a strict chain**: each surface's output is the next
one's input. Which is *why* no gate is needed. Open the promoter first and it is not refusing you;
there is simply nothing upstream to work from.

Consequence worth keeping: **each surface's refusals are inherited, not authored.** "No node
selected", "no route", "no map" are upstream absences showing through, not rules the promoter
invented — so they should always read as *the chain has not reached here yet*, never as *you did it
wrong*.

### ★★ ONE DRIVER AS AUTHORITY, and it is the RUN

His own accounting of where the problem came from:

> *"this comes from one of my rulings that was ill considered. I stated both runs and routes can load
> independently prior, but that wasn't taking into consideration the potential mismatch. Having one
> driver as authority was the resolution. And because promoted elements need something to spawn from,
> it makes most sense to drive it from where all the actionable elements are."*

§61 gave the map **independent slots** — run only, route only, both, neither — for fluidity, and §62
built them. The case that ruling did not carry is **mismatch**: two slots naming different dungeons,
with beacons placed by *fraction*, so a route drawn on the wrong art lands inside corridors and looks
like a plausible route rather than an error.

**The resolution is not arbitration between the two. It is that only one of them is an authority.**

★ And the reason it is the run is positive, not procedural: **promotion needs something to spawn
from, so authority follows the actionable elements.** Nodes live in the run. A route has nothing to
spawn from — it is the destination, not the source. Letting it name the map would be the destination
deciding what may be shipped to it.

That also disposes of the fallback I had added (route names the map when no run is loaded) on its own
terms: a route is *selected against* the map in play, so it cannot be what establishes it.

### What it settles, concretely

| question | answer |
|---|---|
| which dungeon is being authored | `Map.AuthoringMapID()` — the loaded run's, from its own captured data (DR-30 identity, else its points). Nothing else. |
| which routes are offered | only that map's, and none when no run is loaded |
| where a new route or note is filed | that map — never `GetCurrentPlayerPosition` |
| a loaded route naming another map | evicted on run load, when the two are *known* to differ (§17) |

**Fluidity survives where it was actually wanted.** Route-only remains a legal *display* state; what
it no longer is, is a state that can name a dungeon.

⚠ Note the layer this applies to. **Authoring is load-driven; the in-route consumer (§60) is
location-driven**, where the player *is* the cursor. The same fact — a personal note's relevance —
has a different driver on each side, and importing one into the other is what produced the plane that
never changed no matter what you loaded.

### ★★ §64.1 — what the authority rule GAVE us: the route is the constant

Battlewrath, using it:

> *"Routes up for the map. Then swapping the data set, it lets you at a glance check the trend of
> that route against different runs. And swapping to a new map clears both the notes and the route
> selection."*

Nobody built this. It falls out of eviction keying on the **map** rather than on the run: a route
survives every run swap within its own dungeon, so you can hold one authored line still and cycle
evidence underneath it. Any difference you see is the run, because the route did not change.

It is also the first thing here that answers the A:B question from the display stage **without being
a comparison feature**. There is no compare mode, no diff, no second panel — one slot holds still
while the other moves.

★ **And it works BECAUSE §61 dropped the back-reference.** His reason, which is stronger than the
export argument that originally retired it:

> *"linking a later run to a route would break it and ignore how we got here - someone loading a
> route against their own data doesn't have the original."*

A route pointing at its origin run could not be read against another without a mismatch to reconcile,
and on a recipient's machine the origin does not exist at all. **The absence is the mechanism**, not
merely a simplification.

Guarded in the smoke, because this is exactly the kind of capability a well-meaning edit removes in
silence — clear the route slot on every run load and every other test stays green.

⚠ One honest note on the mutation table: the run-swap guard and the same-map-reload guard are served
by **one line**, so no single mutation separates them. The run-swap message is asserted first so the
mutation reports the capability rather than the mechanism.

---

## 65. CALIBRATION — fraction → world, from our own records (2026-08-14)

A captured point carries both a map fraction and a world position. A point **authored** by dragging
carries only a fraction — a drag gives us screen position and nothing else. Anything needing a metric
distance (§60's listen radius, satisfied radius) needs world units, and **a fraction is not one**:
the same fractional delta is a different number of yards on every map.

### ★★ It is a constant of the MAP, not of a run

Battlewrath's correction, and it is the design:

> *"Or. A map constant? Not a run constant. And it uses mapid then nodes stored as a many sample
> calibrator?"*

Per-run fitting was refitting one constant over and over from whichever slice of evidence happened to
be loaded — and would fail outright on a corridor run with no spread, when another run of that
dungeon had already answered it.

★ **So the runs are the samples.** Nothing new is stored: walk every run held for that mapID, take
the pairs it already carries, fit. His framing, which is the whole §17 justification:

> *"That way it's not learning a DB of maps. It's 'What does the current data tell me on how to offer
> the fit'."*

⚠ **The §17 question, answered rather than waved past.** §17 forbids the addon *learning* dungeons —
no shipped box, no DBC, no per-dungeon table — because *"it can never be behind on a dungeon it has
not seen."* Nothing here is shipped or authored, and a dungeon nobody has run has **no calibration:
absent, not wrong**, which is the degradation §17 wants. The cache is a computation over records we
already hold, rebuilt each session, so it is never a second source of truth that could disagree with
them. `addons/maps/worldmap/` has the real boxes and would be a lookup — but it is desk-only by
ruling (*"Do not ship it"*), precisely because a shipped table goes stale the moment the fork adds a
dungeon.

### The fit

**Full affine, six parameters**, `x = a·mapX + b·mapY + c` and the same for `y` — not two independent
scales. The client's map axes are swapped and negated relative to the world's, and the convention
differs by map, so the full form means **we never assume which axis pairs with which**. The data says
it. Least squares over every sample, so one bad capture cannot define a dungeon.

**Conditioning sits in front of the arithmetic, and refuses.** Least squares always returns numbers;
on degenerate input they are confident and wrong and nothing downstream could detect it. Three
refusals, each naming which way it is blind: fewer than three samples · no spread on an axis (a
corridor) · collinear (a diagonal walk, which clears both spread tests and is still undetermined).

**Every `nil` carries a reason** — no runs here yet · no samples on that floor · the samples cannot
determine a plane. Three different facts, and only the last is about the fit.

### ★★ Measured, not assumed — `addons/tools/verify_calibration.py`

Two claims sat under this and neither was safe to take on faith. The second is the one **per-run
fitting could never have tested**, and it is the one the design rests on.

Fit from one run, predict a *different* run's points on the same map. Against the landed captures —
two dungeons, nine floor groups, ~2,650 paired points:

```
CROSS-RUN: 20 case(s), worst error 0.000203 yards
```

Two ten-thousandths of a yard, and that worst case is the **thinnest** run predicting the others —
every other pairing lands near `0.00001`. The transform is exactly linear and it is genuinely a
constant of the map. The runs really are interchangeable samples.

### What is NOT built

**Resolution and the drag itself.** This is the lookup table and its proof, nothing more. The two new
position fields, `new else original`, and the drag handler are the next slice — deferred on his call:
*"Then worry about the resolution later. It's then a table look up rather than a per node compute."*

---

## 66. THE TERRAIN-MAP SHIFT — and ARM IS THE CONSENT BOUNDARY (2026-08-14)

He asked how sure we are that map *presentation* is solved for dungeons no one has run yet. Answered
per component, because they are not equally sure.

**Universal by construction — no per-dungeon risk:** `1002×668` is `WorldMapDetailFrame`'s size, a UI
constant · **12 tiles** is `NUM_WORLDMAP_DETAIL_TILES`, a client constant · **the fraction** is
computed by the client against its own box, correct per-map by definition (§17, and the 706-point
zero-residual proof) · **M9's sentinel trap** and **M8's off-by-one** are both already handled.

### ⚠ One real gap, and it was in our own fact basis

`maps/worldmap/README.md` **M7** records that the client decrements the dungeon level for terrain
maps (`WorldMapFrame.lua:463`). `Map.TilePath` did not. On such a dungeon:

- **lowest level** → we ask `<file>1_i` where the client asks `<file>i` → **blank tiles**
- **any level above** → **the wrong floor's art under the right points**, which looks like a working
  map

We wrote the fact down and never consumed it — the stored-field-isn't-live failure in its purest
form. Neither SFK nor Ragefire is a terrain map, which is why nothing had broken and nothing would
have said so.

**Exposure is BOUNDED - see §66.1 below.** `DungeonUsesTerrainMap()` is a C function and the DBC
census carries no flag for it — `defaultDungeonFloor` is 0 for 156 of 159 maps and all 73 multi-floor maps
start at floor 1, so there is no discriminator in the data we hold. Two ways to bound it, both still
open: probe in game per dungeon visited, or enumerate the art in the MPQs (a dungeon with unsuffixed
`<file>1..12` tiles present is the tell).

### ★★ WHERE IT IS CAPTURED, AND WHY THAT IS A CONSENT QUESTION

I proposed "at arrival". His correction reframed it entirely:

> *"My issue with populating at arrival is - there is no data store to ref again. Because I do a
> dungeon doesn't mean I want to run a capture there. And if we populate at arrival, we're tracking
> every dungeon they've ever been to without their consent or confirmation they have intent for our
> addon to capture information during that session. **Arm tells us that.**"*

**Arm is the consent boundary.** Nothing is written, sampled, or observed until the user says so.
Verified across every path rather than assumed: `captureOrigin` returns immediately without a
`runId`, every event handler is gated the same way, and the sampler is installed by Arm and cleared
by Stop. Zone into a dungeon unarmed and the addon does nothing at all.

★ **The constraint that follows, and it is the durable part:** the flag lives **on the run**, never in
a per-mapID table. A map table would outlive the runs — delete every Shadowfang run and it would
still record that you had been there. **On the run, deletion is complete.**

That is also, in retrospect, why §65's calibration computes from runs rather than storing a fit:
delete the run and the calibration recomputes from what is left, with no residue. The property was
not designed in; it fell out of keeping the record as the only store.

★ And *arm is arrival* in the real flow — `Capture.Arm` calls `captureOrigin()` directly when you are
already inside, which is how anyone actually records (*"I'm ready to start, I'm about to do my first
pull"*). RFC_run1 taught us that the hard way: 15 pulls, 99 legs, `instance = nil`, because the
zone-in event had fired before the run existed. So there is one place for the flag and no new
decision about when.

### The trust guard that came with it

`GetMapInfo()` and `DungeonUsesTerrainMap()` both describe **the map the world map is showing**, not
the player. Arm with your map open on another zone and DR-34 wrote *that* zone's tile file as the
run's art — write-once, permanent. `Map.ArtFor`'s identity guard catches the mismatch and refuses, so
the symptom is a blank canvas rather than a wrong map; but the stored fact is wrong forever and the
run becomes in-zone-only.

Now guarded the way `store.lua`'s `mapFraction()` already guards the fraction: snap the map when it
is closed, never fight it when open, and — when it *is* open — **compare `GetCurrentMapAreaID() - 1`
against where we stand.** That turns M8 from a caution into a check.

⚠ Narrower than I first claimed. I built the case on arming outside and zoning in with the map open;
given arming is in-dungeon, it needs your map open on a *different* zone at the moment you arm. Small
hole, worth the guard because the write is permanent.

### §66.1 — the terrain exposure, BOUNDED (2026-08-14)

§66 left this open: *"exposure is unbounded from the desk."* It no longer is. Battlewrath's guess
pointed the search, and the client's own DBCs answered it — the web search added nothing beyond
confirming the function exists and is used this way in Blizzard's own map code.

> *"I think it might be related to the raid mount hyjal."* … *"Oh and maybe the caverns of time
> dungeons. They have large, world like terrains."*

**Right in kind, and the data sharpens it into two different cases.**

**1. Mount Hyjal and the Caverns of Time instances have NO DungeonMap floors at all.**

| mapID | tileFile | floors |
|---|---|---|
| 534 | `CoTMountHyjal` | 0 |
| 269 | `CoTTheBlackMorass` | 0 |
| 560 | `CoTHillsbradFoothills` | 0 |

No floors means `GetCurrentMapDungeonLevel()` is 0, no suffix is composed, and **§66's shift is a
no-op there.** We were already correct for exactly the maps he suspected — because there is no
numbered level to shift.

**2. ★ The real exposure is the opposite shape — a terrain base WITH numbered floors.** Exactly three
floored maps in the whole client carry `defaultDungeonFloor = -1`; the other **70 carry `0`**:

| mapID | tileFile | floors |
|---|---|---|
| 595 | `CoTStratholme` | 1 |
| **603** | **`Ulduar`** | **5** |
| 904 | `OrgrimmarDepths` | 5 |

Culling of Stratholme begins in the outdoor streets and then goes inside; Ulduar has the vehicle
approach before the interior. Both are exactly *"large, world like terrain"* followed by floors —
which is his framing, arrived at from the other direction:

> *"It is when an existing world map is used for dungeon basis. So an instanced version of a world
> map construction, rather than a room to room dungeon."*

### ⚠ Status of each claim

| | |
|---|---|
| **FACT** | 3 floored maps carry `defaultDungeonFloor = -1`, 70 carry `0` |
| **FACT** | Hyjal / Black Morass / Old Hillsbrad have zero floors, so nothing shifts |
| **INFERENCE** | the `-1` marks the terrain-base case. A three-map correlation, not a proof — `DungeonUsesTerrainMap()` is C-side and `defaultDungeonFloor` is a different column that happens to line up |
| **UNSETTLED** | his *"instanced world map construction"* explanation. Plausible and it fits all three; the census cannot decide it |

### ★ A negative result worth keeping

**`parentWorldMapID` is NOT a discriminator.** It looked like the obvious way to test "reuses a world
map" — but **every** dungeon floor carries one, pointing at its containing outdoor zone (Shadowfang's
floors point at 21, Silverpine). The terrain candidates use 495 / 321 / 161, ordinary dungeons use 32
/ 29 / 492 / 21 / 23. Same shape, no signal. Recorded so nobody spends the hour again.

### The decisive test, and it is now one command

`/dr probe` reports five raw readings for the map you are standing on — file, mapID, the map being
*shown*, `GetCurrentMapDungeonLevel()` of `GetNumDungeonMapLevels()`, the terrain flag, and the art
size. No verdict, just the readings. Stand in Ulduar or Culling of Stratholme once and the inference
becomes a fact or dies.

⚠ **The probe is not smoke-covered.** `core.lua`'s slash surface is loaded by no smoke at all — a
pre-existing gap this adds one line to. Its only real failure mode is a nil concatenation and every
field goes through `tostring`. Slash-surface coverage is a task of its own, not something to smuggle
in here.

---

## 67. CONSTRUCT FROM SAMPLE — the shipped-table question, RULED (2026-08-14)

A poisoned lead (his word: *"Take as poisoned"*) proposed shipping the client's DBC tables. Audited
against our own basis, it produced two wrong claims, one real table we had never read, and one
correction to a statement of ours. The ruling it forced is the important part.

### ★★ THE RULING

> *"Construct from sample. It's completely agnostic. And means our addon can survive any version so
> long as the API's remain available."*

**No shipped per-dungeon table, in any form.** §17 holds in full, and the property is now stated
positively rather than as a prohibition: **the addon's only dependency is that the APIs remain
available.** Never data currency, never a table someone has to regenerate, never a version of the
addon that is wrong for content the fork added last week.

That closes the question I had raised. My own position had been *fast path plus fallback* — ship the
boxes for an exact first-visit answer, keep §65's fit for everything else. It is defensible and it is
worse: it buys exactness we already have to within 0.0002 yards, at the cost of the one property that
makes the addon outlive its own release.

### What the audit found

| claim | verdict |
|---|---|
| `DungeonMapChunk.dbc` exists with `WMOGroupID` / `MinZ` | ✅ **true** — 2,696 rows in `patch-M.MPQ`, schema confirmed against Shadowfang |
| `DefaultDungeonFloor` is a pointer into `DungeonMap.dbc` | ❌ **refuted** — `dungeonMapID` runs 5..3003 over 200 values; the field only ever carries `0` or `-1` |
| the normalization formula | ⚠️ **axis fields swapped** — right idea, reads the Y-named columns where M4 establishes the X-named fields bound world Y. Exactly the trap M4 calls *"the single most expensive thing to get wrong, and it is invisible"* |
| the Lua snippet | ⚠️ **not our client's shape** — ours is an `if` at `WorldMapFrame.lua:463`; the `and/or` form given is also the classic Lua footgun, working here only because `level - 1` can be `0`, which is truthy |

Recorded as **M10** and **M11** in `maps/worldmap/README.md`, with two negative results kept
deliberately: `defaultDungeonFloor` is not a pointer, and `parentWorldMapID` is not a discriminator
(every dungeon floor carries one naming its containing outdoor zone). Both looked promising and cost
an hour; nobody should spend it twice.

### ★★ And it caught a weak PROOF, not a weak transform

Adding the chunk table to the emitter moved a number we lean on:

```
transform verified against 1462 captured point(s) from 4 run(s): worst error 0.544307
```

The README's headline had been `0.000000`. **`verify()` was picking the first floor box that
contained the point** rather than the floor the point was captured on. Fine on Ragefire — which is
why it read zero for months — and wrong the moment Shadowfang's seven overlapping floors landed (M6:
42 of 43 multi-floor dungeons overlap; 6 share one identical box). It was comparing the right
fraction against the wrong box and calling the difference a transform error.

**DR-33 captures the floor precisely so nobody has to guess it.** Keyed on that, the residual is
`0.000000` again — now across **1,462 points from four runs**, four times the evidence the old claim
rested on.

★ The transform was never in question. **A proof that passes for the wrong reason is worth less than
its number suggests**, and the only reason this surfaced is that the emitter re-runs its own proof on
every emit instead of quoting a number written down once.

### ⚠ The correction to our own basis

We had written that floor-from-height is impossible because *"DungeonMap.dbc carries no z bounds."*
True of that file, **incomplete about the client** — `DungeonMapChunk.dbc` carries `MinZ` per WMO
group per floor.

The conclusion survives with a better reason: the join key is `WMOGroupID` and **no Lua call reports
which WMO group the player is in**. Z alone cannot substitute — Shadowfang's floors 1, 2 and 7 all
carry the `-10000` sentinel and would be indistinguishable. **The data exists; the key to it is not
exposed.** DR-33 stands. Corrected in `store.lua` where the original claim lived.

### ★★ §67.1 — and we would not want it even if the key WERE exposed

The closure above was too weak. It said floor-from-z is impossible *because the join key is not
exposed*, which implies we would use it if it were. Battlewrath:

> *"We don't exactly care. And it doesn't exactly serve us. Part of a skip might be climbing a wall,
> a jump onto a terrain, and then a drop. We capture per-sec to surface read, instead of basis on
> floor min value."*

**A skip is exactly where floor classification lies.** Climb a wall, land on terrain, drop off the far
side — a floor-min-Z basis resolves all of it to *"floor 5"* and discards the only thing that made it
a route. The per-second surface read keeps the shape: the climb, the height held, the drop, because
it records where you WERE rather than which layer you would be sorted into.

★ Which is §14 from a new angle: **floor-from-z is a derivation competing with a sample we already
hold**, and the sample is the better record even where the derivation would be correct.

It lands on the promoted objects too. §25.2's inherited-never-computed `z` is what lets a beacon sit
on top of the wall; compute it and the beacon drops to the floor that wall belongs to — which is
precisely not where you need to be standing.

⚠ **Consequence worth stating: mid-skip, the client's reported floor and your `z` can disagree.** You
are above the geometry the floor describes. That disagreement is DATA, not error, and nothing
downstream should reconcile it.

---

## 68. THE DRAG — placement without judgement (2026-08-14)

§61 left "is dragging in the promoter or the curator?" open. It is in **neither**: it happens on the
map, because that is where the object is.

### ★★ KEEP ORIGINAL, ADD NEW

His design, and it dissolves the problem rather than trading against it:

> *"Keep original. A new field for both. And then the marker spawner for the in-game beacon, and the
> source projection walk. New else, Original."*

| question | reads |
|---|---|
| where do I spawn the marker | **`atX/atY`, else `mapX/mapY`** |
| where did this come from | **`mapX/mapY`**, always |

★ **The origin becomes a value, not a reference.** The coordinates it came from ride on the object,
so *how we got here* survives export and works on a stranger's machine — which a back-reference to
the run could never do (§61 dropped it: *"someone loading a route against their own data doesn't have
the original"*). Provenance without the link.

★ **And overwriting would destroy the note case.** A note dragged off the route is not a correction —
it is placed for its **radius**, where you will actually walk through it. The original is where the
thing happened; the new position is where you want to be reminded. Overwrite it and the only record
of which is which is gone.

Rhymes with §43 one level up: curation edits the view and never the capture; dragging edits the
**placement** and never the origin.

**One resolution point.** `Map.Offset` is the only place the rule is applied, so a dragged object
moves in every draw, hit test and readout at once. Read as a **pair** — a half-written placement
falls back whole rather than mixing one authored axis with one inherited one, which would put the
object somewhere neither says. It also returns nil rather than multiplying by a nil, because a bad
point inside paint's loop takes the whole map down.

### What is untouched, and why each one matters

- **`z`** — §25.2, and §67.1 is the reason it earns its keep: inherited-never-computed is what lets a
  beacon sit on top of a wall. Compute it and the beacon drops to the floor that wall belongs to,
  which is precisely not where you need to be standing.
- **`stage`** — order is authored (§56). Moving a beacon in space must never re-sort the route.
- **capture points** — `Map.Draggable` is the line between *edit the placement* and *edit the
  record*. A node is evidence (DR-9, §43) and no gesture may move one.

### The world pair resolves, or is absent

§60's listen and satisfied radii are **distance** checks and a fraction is not metric. His ruling:

> *"Ideally, the drag would resolve, so a system that projects listen range is from the new position.
> We always run against a run in view, so we have local calibration."*

So the drop writes world coordinates through §65's fit. And where the samples cannot determine one it
writes **nothing** — an uncalibrated map is not a reason to invent a world position.

### ★ NO SNAPPING, NO VALIDATION

> *"I would leave that to the human eye. We don't need to over-engineer what a map is. It paints
> walls. Put it past a wall and that's the users doing — and radius still tracks and triggers on it.
> Pen and paper."*

Measured, and the numbers close the question rather than open it: across all 200 dungeon floors in
the client a map pixel is **0.1–2.8 yards, typically 0.2–0.7** (Shadowfang floor 6 is 0.198). The eye
is already working below the precision anyone needs, so there was nothing to engineer. Whether a
placement is *good* is the route designer's call — the same line as curation never touching the
assessment.

### The three that were NOT drift

His question — *"did we resolve the map resolution / drift to actual positioning?"* — has three
answers and only one was ever open:

| | |
|---|---|
| world → fraction, captured | `0.000000` worst across 1,462 points, 4 runs, 2 dungeons |
| fraction → world, the fit | `0.000203` yards worst across 20 cross-run cases |
| **drag granularity** | **0.1–2.8 yd/px — his call, and finer than the eye needs** |

### Census

`COA_DungeonRun` now trips the *unthrottled-looking handler* lead. Looked, as the tool asks: the drag
OnUpdate is per-frame **by design** — an accumulator makes the object lag the cursor — and it is
installed on drag start and cleared on stop, which is why persistent OnUpdate stays `0`. Recorded in
`maps/addons/README.md` beside the other examined flags, so the by-exception signal stays honest.

### §68.1 — a drag moves pixels; the drop writes the record

> *"Can we pause the paint loop whilst dragging?"*

Checked before answering: **the paint loop was not running.** `dragTo` repositions only the dragged
dot, and `paint()` is called once at `EndDrag`. The single full repaint is `Map.Select` at drag
start.

★ But the question found a real fault next to the one it asked about. `Routes.Place` was being called
**every frame** — so one gesture became ~60 writes a second to a saved-variables object, each with
its own calibration lookup. **The gesture is one placement and should be one write.**

Now: the drag stores a candidate fraction and moves the dot; `EndDrag` commits once.

Two things beyond the cost:

- **An interrupted drag leaves the record untouched.** Hide the frame or reload mid-gesture and
  nothing is half-committed at wherever the cursor happened to be.
- **The stored state stops being a moving target** for anything reading the object while you drag.

And the guard that came with it: **no valid fraction, no write.** If the canvas geometry cannot be
read, the drop leaves the record alone rather than committing whatever fell out of the arithmetic.

⚠ Three weak tests found writing this, all mine:

- an assertion that *"a drag that never moved commits nothing"* — **a behaviour I invented.** Pressing
  and releasing on a beacon drops it where the cursor is, and that is correct. Replaced with the
  reachable guard: unreadable geometry.
- the unreadable-geometry mutation **crashed** instead of producing a plausible wrong. Rewritten as
  the version someone would actually ship — a defensive `0, 0` default.
- the no-position test cleared the placement **through `Unplace`**, so the Unplace guard then ran
  against a beacon with nothing to undo and could not reach its own failure. One test must not route
  through the function another guard owns.

---

## 69. THE ARM — four gestures on one object (2026-08-14)

§68 shipped every promoted object grabbable all the time, so any press near one risked moving it.
His model fixes that and adds the rest of the interaction in one shape:

| gesture | does |
|---|---|
| hover | the reading, transient |
| **left click** | selects, **and pins the same reading** |
| **right click** | opens that object's editor |
| **chip** | `move` ⇄ locked — armed, left-drag freely; press again to lock |

### ★★ THE ARM IS AN OBJECT, NOT A MODE

> *"It is on that object. Only promoted options. So the specific beacon, the specific note, based on
> its edit menu and its chip click."*

A global move-mode would let you grab a neighbour in a cluster and never notice. Arming one object
means the only thing that can move is the thing you opened the menu on — and **arming is exclusive by
construction**: it holds one object, so arming another disarms the first without anything having to
remember to.

Same shape as §48's peek latch: the gesture and the commitment are the same control, pressed twice.

★ **The arm cannot outlive its object.** Unload the route and the arm clears, or it is a gesture
waiting for something that cannot be grabbed — and it would silently re-arm if the same table came
back.

★ **And it made a guard dead.** `BeginDrag` had its own `Draggable` check on top of the arm — but the
arm can only ever hold a promoted object, so `== armed` implies it. Removed rather than kept: a guard
whose failure case cannot be reached is not defence in depth, it is a line nobody can test. The
mutation for it went with it.

### ★★ ONE CONTENT SOURCE, TWO PRESENTATIONS

> *"Left click also shows the same as hover does, but stably."*

`Map.Describe` was already the pure content source — the tooltip only rendered it — so the pinned
panel renders the same call rather than carrying its own copy. **That copy is the thing that would
rot**: the two would drift a field at a time and nobody would know which was right. The smoke asserts
they *agree*, not merely that both exist.

Bottom-left, on the map (§49: *"map information should live on the map"*), with mouse disabled so it
can never eat a click meant for a dot beneath it.

### Right-click routes to the promoter

§34's boundary for the third gesture: the map fires and knows nothing about who listens. The
promoter shows the object being edited and owns the chip. The in-field editors — name · cue · note ·
stage · radius listen · radius close · icon — are §61's unbuilt half and land in that space; the
gesture works now so the interaction can be felt before the fields exist.

⚠ **`fillReadout` needed forward declaring**, the same trap as `paint` in §50 — `Map.Select` is
defined above it. That one shipped live because no fixture selected a point with a run loaded. The
fixtures do now, and this was caught before it left the desk.

### §69.1 — one content source, one PLACE

> *"Is it possible to show the information in the same space as the tool-tip would populate. 2
> different reading zones is counter-intuitive."*

§69 got the content right and the geography wrong. The hover appears at the cursor; the pinned copy
was bottom-left. Same words, two places, and **you had to know which question you had asked to know
where to look.**

The panel now anchors beside the point, where `ANCHOR_RIGHT` would have put the tooltip — to the
**canvas at the point's offset**, not to the dot frame, because dots are pooled and reused every
repaint and a panel anchored to one would follow whatever object inherited that frame.

**It flips left near the right edge**, which is the one thing the real tooltip does for free and a
hand-placed panel does not — without it the reading runs off the art exactly when the point is
somewhere interesting.

**An off-floor point hides it.** There is nothing to sit beside, and a panel describing something you
cannot see is worse than no panel.

**And PAINT owns it, not `Select`.** Its position depends on the floor being drawn and the offsets
that draw resolves; owning it in two places means two answers, and the `Select` one would be the
stale one.

### ★ Two dead lines removed, and one weak test that had been waiting

- **The left-edge clamp is unreachable.** The flip only fires past `dx 780` on a 1002-wide canvas
  with a 210-wide panel, and `780 - 222` is still positive. Removed. If the panel ever outgrows the
  canvas that needs rethinking, not defending.
- **`fillReadout` in `Select`** was redundant against paint's call. Removed.
- ⚠ **A test in the map smoke used `o.point` without `rawget`.** The stub answers any non-underscore
  key with a no-op function, so `o.point` is truthy on *every* frame — that loop only worked because
  dots were the sole frames carrying a `_level`. §69's readout panel now has one, at which point
  `o.point.kind` indexes a function. **The trap the stub's own comment warns about, sitting in a test
  that never used the guard**, and it took a new frame to expose it.

---

## 70. TWO REGRESSIONS I SHIPPED, AND THE GUARD THAT GENERALISES (2026-08-14)

### 1. ⚠ §66's trust guard FAILED CLOSED

*"No map art (Pre DR 34 and not in zone). Zone seems to be too tight."*

Not the display — `Map.ArtFor` returns a stored `mapFile` **unconditionally** and resolves anywhere,
so §22 was intact. Those runs had **no `mapFile` at all**, because §66's guard refused to write it.

The guard compared `GetCurrentMapAreaID() - 1` against the player's mapID — **an assumption about two
id spaces that was never verified** — and when it could not confirm, it wrote nothing. A missing
`mapFile` is write-once and permanent: the run is in-zone-only forever, which is precisely the
pre-DR-34 state DR-34 exists to end.

★ **And it rested on a claim of mine that was false.** §66 said *"Map.ArtFor's identity guard catches
the mismatch."* It does not. The identity check governs only the in-zone **fallback**; a wrong stored
file is used anywhere, forever. So the guard was defending something real — **the failure mode was
the wrong one.**

**Fixed by deferring, not dropping.** Write only when the world map is CLOSED — provable, because we
snap it to the current zone ourselves and `GetMapInfo` is then definitionally about where we stand —
and **retry every tick until it lands**. The first moment the user closes their map, the art is
captured. No comparison, no assumption, and no run left undisplayable because the map happened to be
open at arm.

★ His framing is the rule underneath: **authoring works out of zone on mapID; only in-route content
needs you to be there.** Anything that makes a run un-authorable away from its dungeon is too tight
by definition.

### 2. ⚠ A live crash on hovering a personal note

```
map.lua:860: attempt to index local 'c' (a nil value)   -- TIP_COLOR[key]
```

§63 added `beacon`, `note` and `kill` to `ART` and to the **ladder**, and missed `TIP_COLOR` and the
label table. Hovering a note indexed a nil colour and took the tooltip down.

★★ **The fix is not three table entries — it is that the question could not be asked.** Every test
asked about the keys it already knew; none asked *what the full set is*. So `Map.ArtKeys()` and
`Map.KeyFacts()` now expose it, and the smoke **walks every art key** and refuses any that cannot be
named, coloured or ranked.

**It found a second bug on its first run.** `kill` was in `ART` with **no rank at all** — a beacon
wearing that icon would fall to list order, which is the exact fault the ladder exists to prevent, in
the one place nobody would look.

⚠ **The next kind we add will forget the same two tables. That walk is what will say so.**

### Three dead lines removed, one claim withdrawn

- `LABEL[key] or key` — `ArtKey` only ever returns a key `ART` carries, and the walk guarantees each
  is named. The fallback was unreachable.
- The completeness accessors were first written **above** `TIP_COLOR` and resolved it as a global —
  the `paint`/`fillReadout` trap for the third time in one session. Moved below the tables.
- ⚠ **A claim I could not support, withdrawn rather than asserted:** that the retry stops snapping the
  map once the art has landed. It does, but the effect is **invisible** — `store.lua`'s
  `mapFraction()` already snaps every tick to trust the fraction, so counting snaps measures the
  sampler. A test that cannot tell them apart would pass for the wrong reason. Recorded as not
  asserted, in the smoke, next to what is.

### §70.1 — the object stuck to the cursor

*"On move, it doesn't listen to a click event to drop the item."*

★★ **`BeginDrag` was repainting.** It called `Map.Select(dot.point)` to select what you grabbed —
and `paint()` **hides every dot and re-points them from the pool**. The frame you grabbed stops being
the thing you grabbed, so the client's drag has nothing coherent to stop on: `OnDragStop` never
arrives, the OnUpdate keeps running, and the object stays glued to the cursor. Clicking did nothing
because nothing was listening for a click.

The select was redundant anyway — you right-clicked the object to open its editor and pressed its
chip, so it is already the selection.

**And a click now drops it**, which is what he reached for. `OnDragStop` is the client's own
end-of-gesture and stays; this answers a press that never became one, and a drag the UI interrupted.
The canvas listens **only while a grab is in flight** — installed with it and removed with it — so it
is otherwise as click-through as before. Left listening it would swallow every press on empty map for
the rest of the session, which is asserted too.

★ **The proof that it does not repaint is that it does not ANNOUNCE.** Checking the dot still holds
its point would pass on luck — a repaint may hand the same pooled frame the same object. A grab that
fires no selection callback cannot have repainted.

⚠ **I reintroduced a fault I had fixed an hour earlier**: the new fixture cleared a placement through
`Routes.Unplace`, so the mid-drag test then failed for `Unplace`'s reason. Cleared directly. **A test
must not route through the function another guard owns** — worth stating as a rule now that it has
cost twice.

### Also confirmed, not faults

- **RFC's older runs will not load.** They predate DR-33/DR-34; only `RFC_Run3_Messy` carries enough.
  Versioning, not a regression.
- **The note shows no information.** §61's in-field editors are the unbuilt half, so right-click can
  only offer the object's name and its chip — which is why it reads as a creation pane wearing an
  editor's hat.
