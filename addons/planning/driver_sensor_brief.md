# THE SENSOR — the lines it is built on, and the gaps it is built toward

_Opus 5 (Analyst), 2026-08-20, at Battlewrath's ask: **"We might need a more considered design
brief for sensor. Just so they know the lines and the gaps their coding for."**_

⚠⚠ **THIS BRIEF RULES NOTHING.** It is a MAP of what is already ruled and where the edges are.
Every line cites the row that governs it; **where this file and a cited row disagree, the row
wins.** It carries no governing number — whether the model gains a CONSTRUCTION section is
RI-36's open question and the designer's call, not something a brief may settle by existing.

★ Grounded in `sensor.lua` as built (§425), read line by line, not in the acceptance alone.

---

## 0 · WHAT THE SENSOR IS, in one shape

    THE RULE      `rule.lua` — point + band + gate. Pure. No memory. Same list, same
                  samples, same answer.                                    (A11.2a, A11.3)
    THE SENSOR    `sensor.lua` — the armed object. Holds state so the rule has none, and
                  it is INSIDE the driver, not in "the caller".            (A11.3, RI-25)

⟶ Every purity test applies to the RULE unchanged. Everything that must remember is the
SENSOR's. ★ That split is the whole design; most of the gaps below are questions about which
side of it something falls on.

---

## 1 · THE LINES — settled, built, and cited

    L1   ARM TAKES A LIST AND SNAPSHOTS IT.  `Arm(list)` copies each node into a snapshot
         the sensor owns. ★ The copy exists for ONE ordinary reason: the rule takes a
         PRE-SQUARED `r2`, and the alternative home is the AUTHOR'S OWN RECORD — writing a
         derived field back onto the store's data is the fault we refuse everywhere else.
         ⚠ The flight-list property is something the copy EXPRESSES, not something it
         defends.                                                   `sensor.lua:107-135`

    L2   NOTHING ARMED, NOTHING RUNNING.  The `OnUpdate` handler is attached on `Arm` and
         removed on `Disarm`. ⚠ A persistent handler that checks a flag is still running
         every frame — the criterion is "nothing running", not "nothing happening".
         `Sensor.CreateFrame` is a declared SEAM so a smoke can watch the handler arrive
         and leave.                                                  A11.4a, S9

    L3   THE THROTTLE'S THREE CONSTANTS, all load-bearing for CORRECTNESS.

             POLL_MIN            0.1    floor. At R = 5 (10 across) and the corpus max
                                        56.9 yd/s it must be < 2R/v = 0.176 s. 0.2 FAILS.
             POLL_MAX            1.0    base ingest rate.
             MAX_CLOSING_SPEED   100    = `TELEPORT_VMAX`. Beyond it, not travel.

         ⚠⚠ **NEITHER OF THE FIRST TWO IS A COST SETTING ANY MORE.** Under segment they
         were (coarse cost phantoms, fine cost battery). Under point + band + gate there is
         no chord, so **a poll that is too slow MISSES THE BEACON.** Same numbers, new job.
         ★ This is why RI-34 re-derived them instead of re-citing them — and why a future
         change to R, to the floor, or to the ceiling must move the others with it:

             R_min = v_ceiling × POLL_MIN / 2  =  100 × 0.1 / 2  =  5      (the picker's floor)

    L4   THE SCHEDULE NEVER DIVIDES BY A MEASURED SPEED.  `GetUnitSpeed` reports the
         MOVEMENT-STATE rate (7 running, 14 mounted) while the corpus holds legitimate
         displacement at 56.9. **A schedule derived from the reading under-polls in exactly
         the cases it exists for.** The constant is a SAFETY bound whose errors are
         asymmetric: too high costs samples, too low costs a beacon. `ROUTER`, `sensor.lua:146`

    L5   ONE EVALUATION PER NODE PER SAMPLE, shared by that node's rows. `Poll` returns the
         list of nodes that fired, so a caller reads ONE verdict per node.       A11.2g

    L6   REPORTING IS BY ADDRESS, never by index into the list. Shuffle the list → the same
         addresses report.                                                        A11.3b

    L7   RESETTABLE AND ITS STATE READABLE.  `Disarm` returns it to a known state and
         `Armed()` exposes what it holds. ⚠ The REASON changed on 2026-08-20 and the
         requirement did not: outcome grading compares run against run, so a sensor that
         cannot reach a known state makes run 2 incomparable to run 1.            A11.3c

    L8   NOTHING ARMED ON THIS MAP ≠ NOTHING ARMED. The player may be walking to the
         instance, so `NextIn` returns the base rate rather than not polling.  `sensor.lua:168`

★ **And one absence that is deliberate**, kept because the next reader will want to add it back:
there is no `if nearest < 0 then return POLL_MIN` branch. Mutation removed it and **nothing
failed** — the floor clamp two lines down already performs it. It was dead code that READ as
load-bearing, which is the worst kind.                                        `sensor.lua:174`

---

## 2 · THE SEAMS — holes the sensor declares and does not fill

    S1   `Sensor.CreateFrame`   defaults to the client's own. Documented, deliberate (L2).
    S2   `Sensor.Sample`        ⚠⚠ **CALLED AND DEFINED NOWHERE.** `OnUpdate` does
                                `Sensor.Sample and Sensor.Sample()` and treats a nil result
                                as "poll at the base rate". ★ So position acquisition is
                                an UNWIRED seam — the sensor runs, samples nothing, and
                                degrades quietly rather than erroring.

⚠ S2 is not a defect: the degrade is correct and deliberate. **It is named here because
"the sensor is built" and "the sensor is sampling" are different claims**, and only the first
is true today.

---

## 3 · THE GAPS — in the order they will bite

    G1  ✅ CLOSED 2026-08-20 (§433) — `bucket.lua` BUILDS THE FLIGHT LIST.
        `Bucket.Build(mapID, rid)` lays the route out as `bucket[stage][step]` and refuses
        loudly with a NAMED reason; `Bucket.Stage(bucket, stage)` hands out that stage
        WITH stage 0 and cannot fail. Rows 23-27; mutation 16/16.
        ⚠ ONE SEAM DECLARED, NOT FILLED: row 25 wants each `action` resolved to *"the
        function the runtime holds"* and **the runtime holds none** — `adaptor.lua` is a
        VOCABULARY, and the fence below puts the action's handling outside this lane. What
        BUCKET does is check every id against that vocabulary, which is row 25's stated
        rule (*nothing authored is interpreted on the hot path*). `Bucket.Resolve` is the
        hook a binder goes through, and `smoke_bucket` asserts it stays nil.
        ⚠ AND NOTHING CALLS `Bucket` YET — the driver that would run it does not exist, so
        this closes the CONSTRUCTOR gap and not the wiring.

        ~~`Arm` takes whatever list it is handed, and nothing constructs one.~~
        ★ The FORK about who applies the prefix gate is RETIRED — A11.1a and A11.3d already
        answer it: **the gate is resolved AT INGEST by BUCKETING** (mapID → stage → ordinal,
        the no-step bucket always read), not re-armed per stage change and not re-tested per
        poll. ⚠ What is missing is not the RULE but the CONSTRUCTOR: who walks the store,
        applies the bucketing, and hands `Arm` its list.
        DECIDED BY: RI-36 Q1 — does governing #3 gain a CONSTRUCTION section, or point at
        #11 and say so? **Designer's call; a brief must not pre-empt it.**

    G2  ⚠ "PRE-LOAD" HAS NO DEFINITION.  Battlewrath's term (*"the current bucket / pre-load
        items"*), and it appears nowhere on disk. A11.1a's index is built AT INGEST; whether
        pre-load is that same step under another name or a stage before it **is not derivable
        from what is written.**                                    DECIDED BY: RI-36 Q2, his word.

    G3  ⚠⚠ THE TWO SETS ARE OWED.  A11.3d rules a GATED set (current stage/step) and an
        ALWAYS-OPEN set (stage 0, ordinalless children), the second built once at ingest and
        never re-tested. `sensor.lua` holds ONE flat list. ★ Under a stageless V1 every
        node's stage reads 0 → always-open, so the flat list is **behaviourally right today
        and structurally missing the split.** ⟶ Correctly NOT built: no stage to advance
        means the test cannot be written and the split has no consumer.
        BITES WHEN: stages land (V2).

    G4  ★★ THE SENSE WORDS ARE TRANSITIONS AND THE SENSOR KEEPS NO PREVIOUS VERDICT.
        The contract's floor words are `whenOn | seen | whenOff` (`contract.lua`). **All
        three are transitions or histories**, not "is inside now":

            whenOn    was out, is in          seen      has been in at least once
            whenOff   was in, is out

        ⚠ `Poll` does `armed.inSet[n] = hit or nil` — it OVERWRITES without reading the old
        value, and returns only the currently-inside list. **The transition is destroyed each
        poll.** A caller could derive it by differencing successive returns, but A11.3 puts
        that state on the SENSOR'S side of the line, and A11.5 already speaks of *"the previous
        sample; for `while` mode, the in-set"*.
        ⚠ NOT a defect today: nothing consumes a sense word yet, because nothing builds a
        flight list (G1). **Named so it is designed rather than discovered.**
        BITES WHEN: G1 lands and the first action tab asks to fire.

    G5  ⚠ THE IN-SET'S SEMANTICS ARE UNSTATED where armed ≠ eligible. Once G3's split exists,
        "armed" and "eligible" stop being the same thing and the in-set must say which it
        holds.                                                     BITES WHEN: G3 lands.

    G6  ⚠ RE-ARM LIFECYCLE ON A STAGE ADVANCE is unspecified. Under ingest-bucketing it may
        not be needed at all — but nothing has said so, and the retired fork named it as the
        cost of one limb.                                          BITES WHEN: stages land.

    G7  ⚠ `ARRIVAL_HOLD = 1.00 s` IS IN THE ASKLIST'S CONSTANT BLOCK AND NOT IN THE CODE.
        Either it was dropped deliberately with the segment machinery, or it is owed. ★ It is
        the only one of the four original constants with no stated disposition.
        DECIDED BY: nobody yet. **Smallest open item in this brief.**

    G8  ✅ NOT A SENSOR GAP AT ALL — CORRECTED 2026-08-21 (§456).
        ~~A11.9's SUPERTRACKER ESCAPEMENT IS NOT WIRED to the sensor.~~
        ★★★ **Battlewrath:** *"We expressed the park behaviour. **The sensor is blind to what
        it's reading.** So it lives with the manager."*
        ⚠⚠ This row framed the park as something owed a WIRE INTO THE SENSOR. It never was:
        `A12.3c` has the manager write the stage's ENTRY LURE on arming (*"tray-0 items never
        write the arrow"*) and `A12.8a` has it write the PARK at terminal. **All three tracker
        writes are already the manager's, and A12.1a lists them together.**
        ⟶ The sensor reports TRANSITIONS BY ADDRESS. It cannot know that an address is a
        park, a lure, a recovery beacon or a boss - **every one of those is a MEANING, and
        meaning is the manager's.** A sensor that could write the arrow would first have to
        learn what it was looking at.
        ★ Same law as §454's *one lever, one direction*: information flows SENSOR → MANAGER,
        and every interpretation happens on the manager's side.
        WHAT REMAINS: the manager's own wiring, which is L2.6 · A12.3c · A12.8a.

    G9  THE COMPLETION LEDGER (V2) is undrawn — per node, per tab, its interaction with
        Trigger, and what a wipe does to it.                        `driver_data_model.md` E2

---

## 3b · HOW THE FIELD DOES IT — construction and runtime in the prior art

_Added 2026-08-20 at Battlewrath's ask: **"how does our peers and the flight tool take
instructions and then act on them in run time?"** Sourced from `history/prior_art_execution.md`
(§384) and `history/peer_data_stores.md` (§377). ⚠ Reported, PROPOSES NOTHING — §384's own §8
explicitly refuses a `current` field and the modal option._

★★★ **THE FIELD GIVES TWO DIFFERENT ANSWERS, AND THEY DIVIDE ON ONE QUESTION: DOES THE RUNTIME
NEED A CURSOR?**

    GATHERMATE2      NO LOAD PHASE AT ALL. The gate IS the table path -
    (a peer, on      `zone -> nodeType -> locations`. *"Nothing is ever asked 'are you
     this client)    relevant?'"* - the reader indexes to the set it wants, which is why
                     their records carry no gate fields. ★ Bucket-at-ingest, already
                     shipping next door. ⚠ But their data is a static LOOKUP - "what is
                     near me in this zone" - with no order and no progress.

    MAVLINK          AN EXPLICIT, ACKNOWLEDGED LOAD PHASE, then a cursor.
    (the flight          MISSION_COUNT -> per-item REQUEST -> ITEM -> ACK
     tool)               *"items must arrive in order; out-of-sequence messages are
                          dropped and re-requested"*
                     The vehicle then flies from a RESIDENT list, advancing a cursor.
                     `current` marks the active item; `autocontinue` says whether to
                     proceed when a command completes.

⟶ **WE ARE MAVLINK-SHAPED, NOT GATHERMATE-SHAPED**, and the reason is `Stage` and `Next`: a route
is SEQUENTIAL, so something must hold position in it. ⚠ **But our cursor is in the SENSOR, not in
the record** — RI-4 keeps progress out of the file so a shared route carries no one's progress.
★ That is the opposite of `current`, and for a file that gets shared ours is the better half of
the trade. **Not a gap — a difference, already decided.**

★★ **AND WHAT THE FIELD SAYS LOAD IS *FOR*, which is the part that bears on G1/G2.** Five systems
(BehaviorTree.CPP · Amazon States Language · Home Assistant · MAVLink · GatherMate2) share one
shape — *the plan names a capability by ID and the runtime owns it* — and therefore share one
failure: **the plan can name something the runtime does not have.** ASL resolves an ARN that may
not exist; BT.CPP's XML may name an unregistered node; HA's action may name a missing service.

> ⟶ **None of them solves it in the FORMAT. They all fail at LOAD and say what was missing.**
> *"Failing loudly at load is the field's actual answer."*

★★★ **So load is not primarily an optimisation in any of them — it is the VALIDATION BOUNDARY.**
It is the one place where "this plan refers to things that exist" can still be answered before
anything acts. ⚠ Our equivalent is already named and unowned: RI-22's index-into-a-grown-table,
and `Contract.Optional`'s *"one place answers 'is this field allowed to be absent'"*.

⟶ **BEARING ON G1/G2, and stated as a question rather than an answer** (the term is
Battlewrath's and the design is the designer's): if a construction step exists, the field says it
does three things — **RESOLVE** (ids to the capabilities the runtime holds), **INDEX** (the
bucketing A11.1a already rules), and **REFUSE LOUDLY** (name what is missing before anything
arms). ★ `Arm` today does the second only, on a list nobody builds.

## 3c · WEAKAURAS, MEASURED — how an authored trigger runs hot

_At Battlewrath's ask, 2026-08-20: **"With a WA active. How is it working through its trigger
conditions post-authoring… There is a question of human time vs machine time."** Read from the
INSTALLED fork at `Interface/AddOns/WeakAuras`, not from upstream docs._

★★★ **WA'S ANSWER TO HUMAN-TIME-VS-MACHINE-TIME IS ABSOLUTE: every string, every compile and
every table build happens at LOAD. The hot path touches only table indexes and function
pointers.**

    THE LOADED SET     `loaded_auras[id]` - an id -> bool map. Load conditions (class, spec,
                       zone) decide who is in it.                  `GenericTrigger.lua:70`
    THE INDEX          `LoadDisplays` fills `loaded_events[event][subevent][id]` - a TWO-LEVEL
                       bucket, built at load.                                       `:1390-1394`
    THE HOT PATH       local event_list = loaded_events[event]
                       if (not event_list) then return end          `:888-892`
                       ★ A table index and an EARLY OUT. There is no search.
    DEEPER WHERE       COMBAT_LOG_EVENT_UNFILTERED sub-buckets by subevent before touching
    VOLUME IS          any aura - `event_list = event_list[arg2]`.  `:893-899`
    THE COMPILE        custom trigger text is compiled ONCE into a Lua function and CACHED:
                       `self.funcs[string] = func`.                `AuraEnvironment.lua:657`
                       ⟶ At trigger time WA calls a FUNCTION POINTER, never a parser.
    LOAD / UNLOAD      INCREMENTAL. `UnloadDisplays(toUnload)` removes those ids from the
                       buckets; only `UnloadAll` wipes.            `:1248-1258`

### ⟶ WHAT TRANSFERS, AND THE ONE THING THAT DOES NOT

✅ **The shape is the one already chosen** (BUCKET / STAGE): index built at load, hot path indexes
it, rebuild on a load-condition change.

★★ **AND IT NAMES THE HALF WE HAD NOT STATED.** WA resolves not just WHICH auras are live but
WHAT RUNS — the authored string becomes a function pointer before anything fires. ⟶ Battlewrath:
*"the action stage should already be resolved for execution (what function and what arg)."*
**Same requirement, and WA is the proof it is the ordinary answer:** at BUCKET, an `action` id
resolves to the function the runtime holds and `arg` to its resolved value, so STAGE hands the
sampler something callable rather than something to look up.

★ **SUB-BUCKET WHERE VOLUME IS HIGHEST.** WA goes two levels deep only for CLEU. Our equivalent
is step-within-stage, which the staging design already has.

★ **INCREMENTAL BEATS REBUILD.** A stage advance can move one bucket's worth in and out rather
than rebuilding the index — WA only wipes on a full unload.

⚠ **WHAT DOES NOT TRANSFER: WA IS EVENT-DRIVEN AND WE ARE POLL-DRIVEN.** Their biggest saving is
the early-out — *no aura cares about this event, return* — and we have no analogue, because we
always have a sample to test. ★ So the narrowing transfers and the early-out does not: **our
saving has to come from the bucket being SMALL, not from skipping the poll.** Which is exactly
why staging is worth the 12x (G1).

### ★★★ THE MAPPING, CLOSED — WE TAKE THEIR LOAD-CONDITION MACHINERY AND DRIVE IT FROM STAGE

Battlewrath, 2026-08-20: *"the bit that carries is also their load conditions. Their dynamic. We
just take that for the stage rather than player state. Each bucket per stage with it's steps
formed. Then when stage changes, the bucket changes."*

    WEAKAURAS                                       OURS
    ---------------------------------------------   ------------------------------------------
    a dedicated `loadFrame` registered for ~14       THE STAGE ADVANCE - and there is exactly
    state events (talent · difficulty · combat ·     ONE, raised by the sensor's own output
    roster · spells …)              `:1692-1706`
    `ScanForLoads` re-runs `loadFuncs[id]` for       STAGE picks the current stage's bucket
    EVERY aura against current state    `:1607`
    `LoadDisplays` / `UnloadDisplays` move ids       the bucket SWAPS - old one out, new one in
    in and out INCREMENTALLY            `:1248`
    `loaded_events[event][subevent][id]`             `bucket[stage][step]`
    compiled function pointers                       resolved `action` + `arg`

★★ **AND OURS IS STRICTLY SIMPLER, for a structural reason worth stating.** WA needs fourteen
registered events because player state changes from many directions, and it must re-evaluate
EVERY aura when any of them fires — a talent change can affect anything. ⟶ **Our load condition
has ONE input (the stage) and ONE source of change (the sensor's own output), so a stage advance
moves exactly two buckets and re-evaluates nothing.**

    WA          O(all auras) per load event, ~14 event sources
    OURS        O(1) in buckets per advance, 1 source

★ **Because bucket MEMBERSHIP is fixed at BUCKET time and depends on nothing that changes during
a run**, the swap cannot fail — which is the same invariant as the RESOLVE/STAGE boundary,
arrived at from the other end.

⚠ **ONE MORE THING WA COMPILES, and it completes the principle:** `loadFuncs[id]` is itself a
compiled function — **the load TEST, the trigger, and the custom code are all authored text
turned callable before anything runs hot.** ⟶ *Nothing authored is ever interpreted on the hot
path.* That is the whole of WA's answer to human time vs machine time, and it is one sentence.

## 4 · WHAT IS NOT THE SENSOR'S — the fence, so nothing drifts in

    the RULE's purity        point + band + gate stays memoryless           A11.2a
    SEGMENT, interpolated-z, `v_max`   desk-side, and absent on purpose     RI-33
    the ACTION's handling    we generate the input contract, never the consumer's handling
    completion               RI-16's all-tabs rule is not the sensor's today
    the PARK, the LURE,      A11.9's geometry is ruled and the three tracker writes are
    the SUPERTRACK TAB       the MANAGER's (A12.1a · A12.3c · A12.8a). ⚠ The sensor is
                             BLIND to what it reads - an address is not a meaning

---

_How to keep this true: every line cites a row. When a row moves, this file is DOWNSTREAM of
it — re-read the row, not this. ⚠ And per the week's lesson: **a grep finds moved words, not
moved load.** L3 is the standing example — three constants whose text never changed while their
job did._
