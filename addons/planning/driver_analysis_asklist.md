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

**RETURNED 2026-08-17 by the addons bench.** Answers are terse, as asked. Every one was looked up
before it was written — nothing from recall.

⚠ **`[R#]` markers point into the RECONCILIATION footer.** The reasoning lives there, and so does
every place our own record was found wrong. Read a marker when the terse answer is not enough, or
when you want to know how much to trust it.

★ **Read §F before the rest.** Two items nobody asked about change the shape of the work.

★ **And §G is my asks back.** They are the ones a lookup cannot answer — **you hold the
theory, this bench holds the files** — plus a short list of things that are Battlewrath’s ruling
rather than yours, so nobody spends effort deriving a taste call.

---

## A. Q1 — throttler → guarantee

**A1. The throttler exists and tightens as distance shrinks.**
- RESOLVED: an adaptive throttler already exists in this project line; tick interval decreases
  as distance to the beacon decreases, "to catch the landing." `chat`
- **RETURN — CONFIRMED, but it is in `COA_Landmarks`, not `COA_DungeonRun`.**
  `addons/COA_Landmarks/beacon.lua` → `poll()` `:192`, driven by `onUpdate` `:234`, armed only
  while a pin is held (`:125`). DungeonRun has no driver and therefore no throttler. **[R1]**
- **RETURN — schedule: a FORMULA, not a step table.**

      slack  = (dist - Store.TierYards(tier)) / MAX_CLOSING_SPEED
      nextIn = max(POLL_MIN, min(POLL_MAX, slack))

      MAX_CLOSING_SPEED = 30 yd/s   POLL_MIN     = 0.20 s
      POLL_MAX          = 2.00 s    ARRIVAL_HOLD = 1.00 s

**A2. Speeds it must hold against.**
- RESOLVED: run speed and mounted are the cases named. `brief §4.1`
- **RETURN — one number exists and it is NOT a measurement:** `MAX_CLOSING_SPEED = 30` yd/s, a
  deliberately generous ceiling (`beacon.lua:60`). **No run/mounted tier speeds are recorded
  anywhere.** Derivable from the corpus (D1); nobody has derived them.

**A3. Minimum authorable radius.**
- RESOLVED: no floor on the author's radius is mentioned anywhere I've read. `chat` `brief §4.1`
- **RETURN — CONFIRMED, no floor and no clamp.** `Routes.SetChildReach` (`routes.lua:688`) takes
  any number, negatives included. Yours to derive.
- **RETURN — three engine numbers to derive against:**

      ~5.5 yd    the ENGINE'S OWN arrival radius, bracketed 5.46-5.59 (F31, F37).
                 UNSETTABLE, and it cannot carry a per-object tier
      727 yd     InRange -> Occluded    } SuperTracker.lua alpha cuts, NOT engine
      1500 yd    forced to Invalid      } limits (F22, F32)

  ★ True distance still returned at **1,291 yd** and **3,742 yd** (F32, F35) — our readout is
  uncapped even where the client stops drawing.

**A4. Detection is a chord problem, not a diameter problem.**
- RESOLVED: missability = `v·T` step longer than the chord through the detector. `brief §4.1`
- **RETURN — LARGELY NOT A PROBLEM, and my brief was wrong to lead with it.** The existing formula
  is already at its 0.20 s floor eleven yards out, giving **7.1 samples** through a 5 yd detector
  at run speed, 3.6 mounted, 1.7 at the 30 yd/s ceiling. ★ **What survives is the GRAZING pass**,
  and placement across a doorway suppresses that by construction. Take the open question as
  *what fraction of real transits a given R captures*, measured. **[R2]**

## B. Q2 — reach evaluation

**B1. Reach shape is RULED, not open.**
- RESOLVED: vertical cylinder, `radius` + asymmetric `bandUp`/`bandDown`. `brief §2` `brief §6`
- **RETURN — SHAPE ruled; EVALUATION does not exist.** There is **no live reach check anywhere in
  `COA_DungeonRun`** — `bandUp`/`bandDown` are written by `Routes.SetChildReach` (`:688`) and read
  only by the Object pane for display. Nothing consumes them.
- **RETURN — nearest live relative has no band at all:** Landmarks' `arrivalConditionMet()`
  (`beacon.lua:167`) is state check + mapID check + `dist <= TierYards(tier)`.
- ★ So your `fire = (d3D ≤ R) AND (dz ∈ [−bandDown, +bandUp])` is **a proposal to specify, not a
  form to confirm** — and it is a real deliverable. **[R3]**

**B2. Both terms are live in-client.**
- **RETURN — API:** `GetCurrentPlayerPosition()` → `x, y, z, mapID`. **Same call the capture
  uses** (`store.lua:129`, the single constructor every point goes through).
- ⚠ Its `mapID` is the **CONTINENT / INSTANCE** map, not the zone (F30).
- ⚠ Do **not** use `C_WorldMap.GetWorldPosition` — it returns nil inside instances (F9).
- **RETURN — `dz`:** nothing computes it today. Your read is the only candidate; both terms come
  from that one call.

**B3. Invalid-state handling on the live check.**
- RESOLVED: across a map boundary the tracker reports Invalid with distance `0.00`. `brief §3`
- **RETURN — DungeonRun: none, there is no check at all.** Landmarks has three, in
  `arrivalConditionMet()` (`beacon.lua:167`):

      1  GetTargetState() not nil and not 0        (NavigationState.Invalid)
      2  player mapID == the pin's mapID           (AC-25)
      3  condition sustained for ARRIVAL_HOLD 1.0s (AC-26)

- ⚠⚠ **The state check is the load-bearing guard, NOT the debounce.** The declined state is
  **sustained**, not momentary — 57 consecutive in-dungeon samples at `ts = 0, sd = 0`. A
  hold-based test that looks only at distance passes it. **[R4]**

## C. Calibration — already-done work I must not re-derive

**C1. Fraction→world is linear per map, error 0.000000 over 389 points.** `brief §2` `brief §5`
- **RETURN — TWO different transforms, and my brief conflated them:**

      THE LOOKUP   maps/worldmap/README.md - read from the client's own DBC boxes.
                   0.000000 worst across 1,462 points, four runs, two dungeons.
                   RE-PROVEN ON EVERY EMIT. Correct on a dungeon nobody has run.

      THE FIT      COA_DungeonRun/calibrate.lua - runtime per-map, PER-FLOOR constant
                   fitted from held runs. 0.000203 yd worst. ABSENT for an unrun dungeon.

- ⚠ **389 was a stale count, now corrected to 1,462** in three places. **[R5]**
- **RETURN — where the constants live:** nowhere persistent, deliberately. A session cache
  `mapID -> { name, floors = { [floor] = fit } }` (`calibrate.lua:58`), recomputed each session. A
  stored per-dungeon table is the tracking §17 refuses.
- **RETURN — script:** `addons/tools/verify_calibration.py`, plus the worldmap emitter's self-proof.

**C2. Distance verification: engine vs arithmetic, mean error 1e-5 over 1,758 samples.** `brief §2`
- **RETURN — probe** `COA_DevDump/task_satnav.lua` · **reader** `tools/read_satnav_probe.py` ·
  **ledger `addons/planning/satnav_ledger.md` (F20–F39) — read this before designing anything that
  touches the tracker.** Raw runs:

      records/20260812_111102_857__satnav.json   945 rows, dist 0..1290.86   Orgrimmar
      records/20260812_112152_164__satnav.json   727 rows, dist 0..3741.99   The Barrens
      records/20260812_113949_493__satnav.json    86 rows, 2 mapIDs          THE BOUNDARY RUN
      records/20260812_125020_316__satnav.json    99 rows, no distance kept

  ★ 3D confirmed at **F28**, independently re-confirmed at **F39**.
- ⚠ **"It always reports 1 yard" is COSMETIC** — F27 saw the readout floor; **F33 corrects it**
  with 15 samples reading `sd = 0.00` exactly. **Read the API, never the readout.**

**C3. Pin-and-hold calibration design.**
- **RETURN — DESIGNED, NOT BUILT.** Nothing reads the tracker in `Store.Point()`; nothing sets a
  pin at arm. No paired samples exist yet.
- **RETURN — phase two** is one sentence in yesterday's chat, not in any scope doc. ★ The line:
  phase one proves the value while the run owns the pin and therefore knows the target's
  coordinates; phase two only earns its place if phase one showed it was worth carrying.

## D. Corpus — Q4 and ground truth

**D1. Capture is 1 Hz; each point carries `t` and `gt`.** `brief §2`
- **RETURN — four runs are IN GIT**, two of them Ragefire:

      records/20260813_020119__RFC_run1_clean-1__dungeonrun.json           mapID 389
      records/20260813_052802__RFC_Run2_Messy-2__dungeonrun.json           mapID 389
      records/20260813_065255__SFK_Run2_Legs_capture-4__dungeonrun.json    Shadowfang
      records/20260813_161554__SFK_Run4_Clean_C-Legs_Pins-6__dungeonrun.json

  ★ More sit in gitignored `staging/` — **ask for `Height_map` and
  `Height_map_with_cross_walk`; they are the multi-floor ones.** **[R6]**
- **RETURN — schema** (`store.lua:128`, on every point):

      x, y, z        world yards           mapID          CONTINENT/instance, not zone
      mapX, mapY     0..1 zone fraction    mapC, mapZ     the pair the fraction is valid against
      floor          DR-33                 zone, subZone  text
      t, gt          wall clock (joins) and session timer (measures)

  plus `combat` + `n` (pull index) on combat legs, `ghost` on corpse runs.

**D2. Ground-truth landings.**
- **RETURN — none. No run has ever been driven.** `Routes.BeaconAt` has no caller anywhere; the
  driver does not exist. **Q1 must be simulated against captures.**

**D3. Q4 (is 1 Hz adequate).** — noted, stays in scope.

## E. Parked (confirm parked)

**E1. Q3 convergence.**
- **RETURN — CONFIRMED parked as a driver concern, and it is not homeless.** The model puts it in
  **the walk**: a sprite walking a real run's data against a route's detectors. Authoring review,
  not driver logic — and it is also the tool that answers the far-stage policy question.

---

## F. Two things nobody asked, which change the shape of the work

**F-i. The in-dungeon picture, measured rather than assumed.**

    pin OUTSIDE, player INSIDE   MEASURED. 57 samples at mapID 389 (Ragefire) in
                                 records/20260812_113949_493__satnav.json. All 57:
                                 ts = 0 (Invalid) · sd = 0 · tr = true · gp = 1.
                                 The engine declines, returns ZERO not nil, and still
                                 claims to be tracking.

    pin INSIDE, player INSIDE    WORKS - screenshots only (Ragefire, 76 yds and 54 yds,
                                 same test period). Not in any record.
                                 ★ THIS IS THE DRIVER'S ACTUAL CASE.

    across FLOORS                ⚠ UNMEASURED. The axis the band exists for, the axis
                                 calibrate.lua fits separately, and the axis
                                 DungeonUsesTerrainMap() shifts by one.

★ **The middle row measures itself for free** once phase-1 calibration is built: pinning at arm
happens *inside* the dungeon, so holding it is pin-inside / player-inside across every floor the
run touches. **The calibration build and the floor question want to be one capture, not two.**
**[R4]**

**F-ii. F24: our position OUTRANKS the player's quest, and nothing in the client's flow clears it.**
Landmarks answers with a hard contract, written because passivity does not degrade gracefully —
*"it makes us win permanently and silently block the player's quest arrow"*:

    occupy on an explicit pin  ->  release on arrival  ->  NEVER reclaim   (AC-12, AC-19)

⚠ **A route driver re-points at every stage, which is "reclaim" under that contract.** DungeonRun's
model does rule the tracker ours to set — *"a supertracker arrow is understanding"* — so this is a
legitimate product difference. **It should be deliberate, not inherited.** The driver needs its own
stated answer to *when do we give it back*. **[R7]**

---

## G. ASKS BACK — from the addons bench to the analysis lane

_**You hold the theory. This bench holds the files.** So these are the ones where a lookup
cannot help me — not requests for work, requests for a position. Terse answers are fine, and
"not yet" is one._

**G1. Do you need the pin-inside probe EARLY, or does phase-1 calibration give it to you?**
F-i's middle row — pin inside, player inside — is the driver's actual case and we have
screenshots rather than records. ★ It measures itself for free once phase-1 calibration is
built, because pinning at arm happens inside the dungeon. **But that is only true if your work
can wait for it.** If you need in-dungeon tracker behaviour before then, say so and it becomes a
cheap standalone probe — Battlewrath runs them and one dungeon is minutes.

**G2. What does "captured" mean in your transit-fraction metric?**
≥1 sample inside? ≥N? Sustained across a hold? **This decides what the driver must guarantee**,
and it is a modelling choice rather than a fact I can look up. ⚠ Note that Landmarks answers it
with a 1.0 s sustained hold for arrival — but that is a destination you stop at, so do not
inherit it.

**G3. Is 1 Hz enough for YOUR analysis, separately from whether it is enough for the product?**
Q4 asks whether 1 Hz is adequate to place detectors. This is the other half: if your transit
work needs finer paths than 1 Hz to be trustworthy, that changes what we capture and it is
cheaper to know before the next run than after.

**G4. Return the reach rule with an EVALUATION COST, not only an acceptance region.**
The shape is yours; the frame budget is mine. A region I cannot evaluate cheaply per tick is a
region I have to reject on grounds you would rather have known about. ★ Rough is fine — how many
operations, and does it need anything beyond the one engine distance and a `dz`.

**G5. What cadence does the tracker heartbeat need?**
The ROUTER records that a route may need a low-cadence reinforcement of the tracked position,
because a map boundary invalidates it and other writers overwrite silently. **Nobody has derived
what "low" is.** I hold the loss evidence (F38, and the 57 sustained-Invalid samples); you hold
the reasoning about what rate is sufficient against those loss modes.

**G6. Do you want the corpus raw, or reduced?**
The run captures are whole `Store.Point()` records. If a reduced form — say `t, gt, x, y, z,
floor` per sample, one file per run — would save you a parsing pass, that is a cheap emitter on
this side and you should not spend a day on it.

### ⚠ NOT for you — these are Battlewrath's rulings, listed so you do not answer them

- **When does the driver give the tracker back?** (F-ii.) Landmarks' contract is *never
  reclaim*; a route re-points every stage. That is a product decision about invasiveness, not a
  derivation.
- **The far-stage policy** — what a satisfaction from a stage you are not on should DO. Bounded
  by bosses as `set:stage` resync points, and answerable by looking rather than reasoning.
- **Any minimum authorable radius we ship as a floor.** You can tell us what R is *safe*; whether
  we then stop an author from going below it is taste, and this project leans hard against
  grading the author's work.

---

## RECONCILIATION — what this leg checked, and what moved

_Not a changelog. **The satnav probe was run to give this leg its basis; this is the basis being
used — and found wrong in seven places.** A corrected fact with its correction attached is worth
more than a clean one, so none of it is deleted._

**[R1] The throttler — I would have reported that none existed.** Two searches of
`COA_DungeonRun` found only the fixed 1 Hz sampler. It lives in a sibling addon, and the design
note (AC-29) records it *replacing* an earlier two-tier movement throttle after Battlewrath asked
*"where is the benefit to the polling cadence as stands?"* — 20 samples per debounce window
discarded 19 of them.

**[R2] The chord problem — my brief led with it and Battlewrath challenged it.** I had written that
AC-29's argument *"does not transfer to a route"*, on the grounds that a landmark is a destination
you stop at while a route beacon is one you pass through. The arithmetic says otherwise:

      5 yd radius, 10 yd edge to edge; formula already at POLL_MIN by 11 yards out
      run      7 yd/s -> 1.40 yd step -> 7.1 samples inside
      mount   14 yd/s -> 2.80 yd step -> 3.6 samples
      ceiling 30 yd/s -> 6.00 yd step -> 1.7 samples

★★ **It transfers because it paces on DISTANCE-TO-TIER**, which governs a pass-through as much as
an arrival — the formula does not care *why* you are close. "You stopped there" justified only the
loose **ceiling**, and the ceiling is never engaged near the target.

**[R3] No live reach evaluation.** Consistent with `mvp_scope.md`: everything authors, nothing
plays. `Routes.BeaconAt` has no caller either. ★ Which is also why the model has never been
contradicted — every ruling since §78 was argued against a consumer that does not exist.

**[R4] The in-dungeon samples — found by searching records by mapID, after two passes by filename
missed them.** Battlewrath's instruction: *"Search by ID on records / evidence."* The 57 rows are
F38's evidence, and they say something F38 does not: **the decline is a steady state.** All 57
consecutive. ⚠ That is what demotes the debounce — `ARRIVAL_HOLD` defends against a *momentary*
Invalid (a loading screen) and cannot see a sustained one.

**[R5] 389 → 1,462, a stale point count in three files.** `emit_worldmap_census.py:216` records the
proof being fixed — *"took the worst residual from 0.544307 back to zero across 1462 points — the
transform was never in question; the PROOF was"* — and the `389` line above it never moved with it.
It then propagated into `calibrate.lua` and into the brief handed to this lane.
⚠ **A coincidence worth an eye rather than a conclusion:** 389 is also Ragefire Chasm's mapID
(F30). 1,462 is the better-attested figure — the README carries it, and the emitter prints its own
count on every run.

**[R6] The tracked corpus — I reported "not in git" and was wrong.** My filename pattern assumed a
milliseconds field these files do not have, so four run records were invisible to the listing and
not to the repo.

**[R7] The ROUTER row written 2026-08-16 said a player *"just opens their journal"* to reclaim the
tracker.** F24 is measured and says otherwise: Position outranks Quest, and nothing in the client's
flow clears ours. A deliberate re-track takes the slot; **nothing passive does.** Corrected in
`operations/ROUTER.md`.
