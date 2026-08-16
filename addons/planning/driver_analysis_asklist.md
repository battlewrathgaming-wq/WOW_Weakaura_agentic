# Driver analysis — ASK LIST (return form)

_From the analysis lane, 2026-08-17, after a first read of `driver_analysis_brief.md` and a
clarifying exchange with Battlewrath. **The model docs (`dungeonrun_model.md`, `mvp_scope.md`)
have NOT been read yet** — every "resolved" below is from the brief + chat, so cite-check it._

**How to use this:** each item has RESOLVED (what I currently believe, with its cite), and
RETURN (what the addons bench fills in — a confirm/correct plus a corpus/file pointer). Fill
the RETURN slots and hand it back; I don't need prose. Where the model disagrees with a
RESOLVED line, the model wins — just say so and point at the section.

Cite keys: `brief §N` = driver_analysis_brief.md section · `chat` = Battlewrath, 2026-08-17.

---

**RETURNED 2026-08-17 by the addons bench.** Every answer below was looked up before it was
written; nothing here is from recall. ⚠ **Read §F first — two items nobody asked about change
the shape of the work, and one of them corrects my own brief.**

---

## A. Q1 — throttler → guarantee

**A1. The throttler exists and tightens as distance shrinks.**
- RESOLVED: an adaptive throttler already exists in this project line; tick interval decreases
  as distance to the beacon decreases, "to catch the landing." `chat`
- **RETURN — file/function:** `addons/COA_Landmarks/beacon.lua` → `poll(elapsed)` at `:192`,
  driven by `onUpdate` at `:234`. ⚠ **It is in COA_Landmarks, NOT COA_DungeonRun** — same
  project line, different addon and different product. DungeonRun has no driver, so it has no
  throttler. The poll exists **only while a pin is held** (`Beacon.Pin` `:125`); idle cost is
  exactly zero.
- **RETURN — schedule:** a **formula**, not a step table.

      slack  = (dist - Store.TierYards(tier)) / MAX_CLOSING_SPEED
      nextIn = max(POLL_MIN, min(POLL_MAX, slack))

      MAX_CLOSING_SPEED = 30    yd/s   ceiling, deliberately generous
      POLL_MIN          = 0.20  s      floor
      POLL_MAX          = 2.00  s      ceiling
      ARRIVAL_HOLD      = 1.00  s      the condition must HOLD this long (AC-26)

  ★ It paces on **how soon arrival is even possible**, not on movement. An earlier two-tier
  movement throttle (0.05s moving / 1s still) was killed by Battlewrath's challenge *"where is
  the benefit to the polling cadence as stands?"* — 20 samples per debounce window discards 19.

- ⚠⚠ **AND ITS CORRECTNESS ARGUMENT DOES NOT TRANSFER TO A ROUTE. This is the most important
  line on this list for Q1.** AC-29's reasoning is explicit:

  > *"Being WRONG about it only ever makes an arrival LATE, never missed — the next poll still
  > sees a distance inside the tier, because you stopped there. That is why the ceiling can be
  > loose and the floor tight."*

  ⚠⚠ **I WROTE THAT THE ARGUMENT DOES NOT TRANSFER. BATTLEWRATH CHALLENGED IT AND THE ARITHMETIC
  BACKS HIM (§243).** The "you stopped there" line justifies only the loose **ceiling**, and the
  ceiling is never engaged near the target: `(11−5)/30 = 0.2`, so the formula has already clamped
  to POLL_MIN by eleven yards out. Against a 5 yd detector — his doorway case, 10 yd edge to edge:

      run      7 yd/s   ->  0.20 s  ->  1.40 yd step  ->  7.1 samples inside
      mount   14 yd/s   ->  0.20 s  ->  2.80 yd step  ->  3.6 samples
      ceiling 30 yd/s   ->  0.20 s  ->  6.00 yd step  ->  1.7 samples

  ★★★ **It transfers because it paces on DISTANCE-TO-TIER, which is the quantity that governs a
  pass-through as much as an arrival.** The formula does not care *why* you are close.

  ★ **So Q1 is not a tick-rate question.** What survives is the GRAZING pass — a chord much
  shorter than the diameter — and his placement argument closes most of that too: a 5 yd detector
  across a 10 yd doorway means every transit passes near centre **by construction**. Geometry of
  placement, not the clock. **What is genuinely open is the residual: for radius R across a
  corridor of width W, what fraction of real transits are captured — answerable from the corpus,
  not from theory.**

**A2. Speeds it must hold against.**
- RESOLVED: run speed and mounted are the cases named. `brief §4.1`
- **RETURN:** we hold exactly one number and **it is not a measurement**: `MAX_CLOSING_SPEED =
  30` yd/s, chosen as a generous ceiling — *"~29 yd/s is a 310% flying mount, so 30 leaves
  headroom"* (`beacon.lua:60`). ⚠ **No run/mounted tier speeds are recorded anywhere.** They are
  derivable from the corpus — 1 Hz positions with both clocks — but nobody has derived them.
  Corpus pointer at D1.

**A3. Minimum authorable radius.**
- RESOLVED: no floor on the author's radius is mentioned anywhere I've read. `chat` `brief §4.1`
- **RETURN — confirmed, no floor and no clamp.** `Routes.SetChildReach` (`routes.lua:688`) is
  `child.radius = tonumber(radius) or child.radius` — any number is accepted, negatives
  included. It is yours to derive.
- ⚠ **But derive it against two engine numbers we already hold:**

      ~5.5 yd    the ENGINE'S OWN arrival radius (NavigationState.InRadius), bracketed
                 5.46-5.59 across two independent runs (F31, F37). UNSETTABLE, and it
                 cannot carry a per-object tier - which is why Landmarks does not use it
      727 yd     InRange -> Occluded          } client-side alpha cuts in SuperTracker.lua,
      1500 yd    forced to Invalid            } NOT engine limits (F22, F32)

  ★ The engine still returned `InRange` and a true distance at **1,291 yd** and again at
  **3,742 yd** (F32, F35) — so our readout is uncapped even when the client stops drawing a
  beacon.

**A4. Detection is a chord problem, not a diameter problem.**
- RESOLVED: missability = `v·T` step longer than the chord through the detector. `brief §4.1`
- **RETURN — REVISED (§243), see A1.** The prior work dismisses it for landmarks, and the
  arithmetic says the dismissal largely holds for transit too, because the pacing formula keys on
  distance-to-tier. ★ **The chord problem is real only for GRAZING passes**, and detector
  placement across a constrained opening suppresses those by construction. Take the open question
  as *what fraction of real transits a given R captures*, measured against the corpus.

## B. Q2 — reach evaluation

**B1. Reach shape is RULED, not open.**
- RESOLVED: vertical cylinder, `radius` + asymmetric `bandUp`/`bandDown`. `brief §2` `brief §6`
- **RETURN — correcting the question rather than answering it: there is NO live reach evaluation
  in COA_DungeonRun.** `bandUp`/`bandDown` are written by `Routes.SetChildReach` (`:688`) and
  read only by the Object pane for display. **Nothing consumes them.** Consistent with the
  MVP scope: everything authors, nothing plays.
- The nearest live relative is Landmarks' `arrivalConditionMet()` (`beacon.lua:167`) and it has
  **no band at all** — state check, mapID check, then `dist <= TierYards(tier)`.
- ★ So `fire = (d3D ≤ R) AND (dz ∈ [−bandDown, +bandUp])` is a **proposal to be specified, not a
  form to confirm.** The model rules the *shape* (asymmetric cylinder, because a child on a
  walkway wants reach for whoever stands ON it); nothing anywhere rules the *evaluation*. That
  gap is yours to fill and it is a real deliverable.

**B2. Both terms are live in-client.**
- **RETURN — player-position API:** `GetCurrentPlayerPosition()` → `x, y, z, mapID`. **Confirmed
  the same call the capture uses** — `Store.Point()` (`store.lua:129`) is the single constructor
  every captured point goes through.
- ⚠ **Its `mapID` is the CONTINENT / INSTANCE map, not the zone** (F30, and a ROUTER row). A
  stored fraction is valid only against the continent+zone pair it was taken on.
- ⚠ Do not reach for `C_WorldMap.GetWorldPosition` — it **returns nil inside instances** (F9).
- **RETURN — `dz`:** nothing computes it today. Your read (player z vs beacon z, both from the
  same call) is the only candidate, and both terms do come from that one API.

**B3. Invalid-state handling on the live check.**
- RESOLVED: across a map boundary the tracker reports Invalid with distance `0.00`. `brief §3`
- **RETURN — in DungeonRun: none, because there is no check at all.** In Landmarks there are
  **three** guards, all inside `arrivalConditionMet()` (`beacon.lua:167`):

      1  GetTargetState() must not be nil and must not be 0   (NavigationState.Invalid)
      2  GetCurrentPlayerPosition()'s mapID must match the pin's        (AC-25)
      3  the condition must hold for ARRIVAL_HOLD = 1.00 s             (AC-26)

  ★ Guard 3 exists because **a loading screen produces a momentary Invalid** — a single frame is
  not an arrival. The ledger calls F38 *"a shipping-grade trap"*, and its own wording is the
  reason: **zero satisfies every radius test.**
- **So: can `0.00` reach the radius test?** In Landmarks, no. In the driver, **there is nothing
  to stop it yet** — specifying that precondition is part of your deliverable.
- ⚠⚠ **And see F-i for the evidence: the declined state is SUSTAINED.** 57 consecutive in-dungeon
  samples at `ts = 0, sd = 0`. A debounce alone does not catch that; **the state check does the
  work.**

## C. Calibration — already-done work I must not re-derive

**C1. Fraction→world is linear per map, error 0.000000 over 389 points.** `brief §2` `brief §5`
- ⚠⚠ **RETURN — MY BRIEF CONFLATED TWO DIFFERENT TRANSFORMS WITH TWO DIFFERENT PROOFS.
  Correcting:**

      THE LOOKUP    addons/maps/worldmap/README.md - the world-map transform read from the
                    client's own DBC boxes. Verified against 1,462 real captured points
                    across four runs and two dungeons, worst error 0.000000, and the
                    emitter RE-PROVES IT ON EVERY EMIT. ★ Correct on the first visit to a
                    dungeon nobody has ever run.

      THE FIT       addons/COA_DungeonRun/calibrate.lua - a runtime per-map constant fitted
                    from runs we already hold. 0.000203 yd worst, measured (:48). Needs
                    runs; ABSENT for an unrun dungeon, which is the correct degradation.

- ⚠ **And the repo disagrees with itself on the point count:** `calibrate.lua:14` says *"0.000000
  across 389 points"* while `maps/worldmap/README.md` says **1,462 points across four runs**. I
  carried the 389 from the code comment into the brief. **SETTLED §242: 389 is STALE, 1,462 is current.** :216 records the
  proof being fixed — *"took the worst residual from 0.544307 back to zero across 1462 points —
  the transform was never in question; the PROOF was"* — and the 389 line above it was never
  moved with it. It then propagated into  and into my brief. ★ Both corrected;
  the README had it right throughout, and the emitter PRINTS its own count on every run.

- **RETURN — where the constants live:** nowhere persistent, deliberately. `calibrate.lua`
  holds a **session cache** `mapID -> { name, floors = { [floor] = fit } }` (`:58`), recomputed
  each session, *"so it is never a second source of truth that could disagree with them."* A
  stored per-dungeon table is exactly the tracking §17 refuses. ★ **Note the shape: the fit is
  per mapID PER FLOOR.**
- **RETURN — fit/verify script:** `addons/tools/verify_calibration.py`, plus the worldmap
  emitter's self-proof.

**C2. Distance verification: engine vs arithmetic, mean error 1e-5 over 1,758 samples.**
- **RETURN:** probe `addons/COA_DevDump/task_satnav.lua` · reader `addons/tools/read_satnav_probe.py`
  · **ledger `addons/planning/satnav_ledger.md` (F20–F39) — read this before designing anything
  that touches the tracker.** Raw runs:

      records/20260812_111102_857__satnav.json    945 samples, dist 0..1290.86
      records/20260812_112152_164__satnav.json    727 samples, dist 0..3741.99
      records/20260812_113949_493__satnav.json     86 samples, 2 mapIDs (the boundary run)
      records/20260812_125020_316__satnav.json     99 samples, no distance kept

  ★ `distance` is 3D — settled at **F28** and independently re-confirmed at **F39**.
- ★ **And a correction you will need:** the *"it always reports 1 yard"* behaviour is **cosmetic
  and in the client's readout, not in the API.** F27 recorded the floor; **F33 corrects it** —
  15 samples read `sd = 0.00` exactly while stood on the pin, with `hd = 0` and `vd = 0`.
  **Read the API, never the readout.**

**C3. Pin-and-hold calibration design.**
- **RETURN — DESIGNED, NOT BUILT.** Nothing in `Store.Point()` reads the tracker; nothing in the
  run capture sets a pin. There are no paired samples yet.
- **RETURN — phase two:** scoped only as a sentence in yesterday's exchange (*"driver gets a
  lighter in-route passive calibrator"*), not yet written into any scope doc. ★ The line you
  should design to: **phase one proves the value while the run owns the pin and therefore knows
  the target's coordinates; phase two only earns its place if phase one showed it was worth
  carrying.**

## D. Corpus — Q4 and ground truth

**D1. Capture is 1 Hz; each point carries `t` and `gt`.** `brief §2`
- ⚠ **RETURN — CORRECTED §244. There IS a tracked run corpus; I checked by filename pattern and
  my pattern did not match these files.** Four runs are in git:

      records/20260813_020119__RFC_run1_clean-1__dungeonrun.json        Ragefire, mapID 389
      records/20260813_052802__RFC_Run2_Messy-2__dungeonrun.json        Ragefire, mapID 389
      records/20260813_065255__SFK_Run2_Legs_capture-4__dungeonrun.json Shadowfang
      records/20260813_161554__SFK_Run4_Clean_C-Legs_Pins-6__dungeonrun.json

  ★ **So you have real dungeon paths, in two dungeons, straight from the repo.** More sit in
  gitignored `staging/` (SFK Run1, RFC Run3, and the three `dungeonroutes` captures including
  `Height_map` and `Height_map_with_cross_walk`) — ask for those, they are the multi-floor ones.
- **RETURN — schema** is whatever `Store.Point()` (`store.lua:128`) builds, on every point:

      x, y, z          world yards, from GetCurrentPlayerPosition
      mapID            CONTINENT/instance map, not the zone
      mapX, mapY       0..1 fraction across the drawn zone
      mapC, mapZ       the continent+zone pair the fraction is valid against
      floor            DR-33 - without it a multi-floor run is permanently unplaceable
      zone, subZone    text
      t, gt            wall clock (joins) and session timer (measures)

  plus `combat` + `n` (pull index) on combat legs, and `ghost` on corpse runs.

**D2. Ground-truth landings.**
- **RETURN — none. No run has ever been driven.** `Routes.BeaconAt` has no caller anywhere in
  the addon; the driver does not exist. **Q1 must be simulated against captures.**

**D3. Q4 (is 1 Hz adequate).** — noted, stays in scope.

## E. Parked (confirm parked)

**E1. Q3 convergence.**
- **RETURN — confirmed parked as a DRIVER concern, but it is not homeless.** The model puts it in
  **the walk**: a sprite walking a real run's data against a route's detectors, which is how
  *"are the detectors where the paths converge, or only where I happened to walk?"* gets
  answered. That is an authoring-review feature. ★ It also stays the tool that answers the
  far-stage policy question, so it is scheduled work rather than a dropped question.

---

## F. Two things nobody asked, which change the shape of the work

**F-i. THE IN-DUNGEON PICTURE, now measured rather than assumed (§244).**
Searching the records by **mapID** rather than by filename found what two earlier passes missed.

    pin OUTSIDE, player INSIDE     MEASURED. records/20260812_113949_493__satnav.json carries
                                   57 samples at player mapID 389 (Ragefire). Every one of them:
                                   ts = 0 (NavigationState.Invalid) · sd = 0 · tr = true ·
                                   gp = 1. The engine declines, reports ZERO not nil, and still
                                   claims to be tracking - F38, and this is its evidence.

    pin INSIDE, player INSIDE      WORKS, but only screenshot evidence: Ragefire Chasm, tracker
                                   live at 76 yds and 54 yds, same test period. Not in any
                                   record. ★ This is the DRIVER'S actual case.

    across FLOORS                  ⚠ UNMEASURED, and it is the axis the band exists for, the
                                   axis calibrate.lua fits separately, and the axis
                                   DungeonUsesTerrainMap() shifts by one.

★★★ **AND THE DECLINE IS A STEADY STATE, NOT A BLIP.** All 57 consecutive samples read Invalid
with `sd = 0`. ⚠ **This sharpens B3:** `ARRIVAL_HOLD`-style debouncing defends against a
*momentary* Invalid (a loading screen), and would NOT save you here — a sustained Invalid with
`sd = 0` passes any hold-based test that looks only at distance. **The state check is the
load-bearing guard; the debounce is the secondary one.**

★★★ **And a dungeon has no zones. It has floors.** Floors are the axis the asymmetric band exists
for, the axis `calibrate.lua` fits separately, and the axis `DungeonUsesTerrainMap()` shifts by
one. **That is the driver's entire environment and it is unmeasured.** Design against it as an
open question, not a solved one — and say what you would need probed, because a probe is cheap
and Battlewrath runs them.

**F-ii. ⚠ F24: OUR POSITION OUTRANKS THE PLAYER'S QUEST, AND NOTHING IN THE CLIENT'S FLOW CLEARS
IT.** Landmarks' response is a hard contract, written because passivity does not degrade
gracefully here — *"it makes us win permanently and silently block the player's quest arrow"*:

    occupy on an explicit pin  ->  release on arrival  ->  NEVER reclaim   (AC-12, AC-19)

⚠ **A route driver re-points at every stage, which is "reclaim" under that contract.** DungeonRun's
model does rule the tracker ours to set — *"a supertracker arrow is understanding"* — so this is a
legitimate product difference. But it should be a **deliberate** difference, not one inherited by
accident, and the driver needs its own stated answer to *when do we give it back*.

★ This also corrects a ROUTER row added 2026-08-16 on the strength of a chat line that a player
*"just opens their journal"* to get it back. A deliberate re-track would take the slot; **nothing
passive does.** The addons bench owns fixing that row.
