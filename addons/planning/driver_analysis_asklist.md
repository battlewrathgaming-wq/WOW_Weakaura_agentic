> ⚠ **REASONING SPACE, NOT THE BASIS. Read `DRIVER_BASIS.md` first.** Findings and evidence here
> stand; DESIGN proposals in §H are superseded wherever `driver_programmatic_model.md` or
> `driver_scoping.md` says otherwise. The ledger §I is history as of its date.

# Driver analysis — ASK LIST (return form)

_From the analysis lane, 2026-08-17, after a first read of `driver_analysis_brief.md` and a
clarifying exchange with Battlewrath. **The model docs (`dungeonrun_model.md`, `mvp_scope.md`)
have NOT been read yet** — every "resolved" below is from the brief + chat, so cite-check it._

**How to use this:** each item has RESOLVED (what I currently believe, with its cite), and
RETURN (what the addons bench fills in — a confirm/correct plus a corpus/file pointer). Fill
the RETURN slots and hand it back; I don't need prose. Where the model disagrees with a
RESOLVED line, the model wins — just say so and point at the section.

Cite keys: `brief §N` = driver_analysis_brief.md section · `chat` = Battlewrath, 2026-08-17.
**Voices in this file:** **Battlewrath** (rulings) · **Bench** (the addons bench — holds the files,
owns the build) · **Analyst** (this lane — holds the theory, writes acceptance, tests the build).
Sign claims by voice; a claim's weight comes from which voice holds the evidence for it.

★ **This file is the single reasoning space between the analysis lane and the addons bench**
(Battlewrath, 2026-08-17): each side tests the other's claims here, and it is the solver for
future inventiveness — a claim or a response lands HERE with its cite, gets checked by the side
that holds the evidence, and the correction stays attached. Sections accrete; nothing is
deleted. **Companions:** `history/driver_design_advisory.md` (the design as challenged, §0–13; HISTORY since 2026-08-18) ·
`driver_walk_acceptance.md` (W0–W7, what the bench's build is tested against) ·
**`history/driver_walk_result.md`** (the bench's result AGAINST those criteria — W2/W3/W4 PASS, and one
wording fix W4 needs). **State ledger:
§I at the bottom** — what is closed, what is open, and who holds the next move.

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

      MAX_CLOSING_SPEED = 30 yd/s   POLL_MIN     = 0.20 s      ⚠⚠ BOTH SUPERSEDED
      POLL_MAX          = 2.00 s    ARRIVAL_HOLD = 1.00 s

  ⚠⚠ **RI-34, 2026-08-20 — THE TWO LEFT-HAND CONSTANTS ARE SUPERSEDED, AND THE NEW VALUES ARE
  SETTLED (Battlewrath):**

      POLL_MIN          = 0.10 s    was 0.20 — 0.2 is where it FAILS, not a margin
      MAX_CLOSING_SPEED = 100       was 30, inherited whole from COA_Landmarks

  ★ **Neither is a guess.** 0.2 was a DEBOUNCE budget (*"5 samples per debounce window"*,
  `landmark_design.md`), never a sampling limit — `OnUpdate` fires per frame, so the real floor
  is ~0.017 s. Under point + band + gate the floor's job became correctness: at R = 5 the step
  must stay under 2R = 10 yd, and 50.6 yd/s needs better than **0.198 s**. 0.1 gives 2× margin.
  ⟶ `MAX_CLOSING_SPEED = 100` is `TELEPORT_VMAX` — the fastest thing the project is OBLIGED to
  treat as travel — and it reads as **"poll at the floor from 15 yd out"** (`R + POLL_MIN×MCS`).
  ★ Each owns a different failure: the floor owns the CROSSING, the divisor owns the APPROACH.
  ⚠⚠ **AND MY "`POLL_MAX` and `ARRIVAL_HOLD` are untouched" WAS WRONG — corrected 2026-08-20.**
  `sensor.lua` (§425) ships **`POLL_MAX = 1.0`**, deliberately NOT COA_Landmarks' 2.0, on the same
  reasoning that moved `MAX_CLOSING_SPEED`: *"a neighbour's constant for a different job, and
  inheriting it is the fault MAX_CLOSING_SPEED already demonstrated."* ★ The bench applied the
  lesson one constant further than I did. ⚠ **`ARRIVAL_HOLD` is in NO code** — the only one of the
  four with no stated disposition; carried as G7 in `driver_sensor_brief.md`.
  ⟶ Live row **A11.2f**; working in RI-34; the sensor's map is `driver_sensor_brief.md`.

  ⚠ **COA_Landmarks keeps 0.20 / 30 and is CORRECT to** — different product, different worst
  case (a ~29 yd/s flying mount, no charges). Do not "fix" `landmark_design.md`.
  `ARRIVAL_HOLD` are untouched. ⟶ The live row is **A11.2f**; the working is in RI-34.

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

  ⚠⚠ **STILL TRUE OF THE FIGURES, AND NO LONGER TRUE OF THE CONCLUSION (RI-34, 2026-08-20).**
  Every number above is a MEDIAN-to-mounted number against a **30 yd/s ceiling that was borrowed
  from COA_Landmarks**, where the fastest thing is a ~29 yd/s flying mount (`landmark_design.md`
  constants table). ★ **A dungeon has no flying mounts and does have charge abilities** — the
  corpus maximum is 56.9 yd/s. At that speed and the 0.2 s floor the failure is not the grazing
  pass this entry names; **it is a whole 5 yd detector skipped.** ⟶ Floor → 0.1, and
  `MAX_CLOSING_SPEED` → **100** with it. Live row A11.2f; working in RI-34.

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

## H. THEORY BACK — analysis lane, 2026-08-17

_Written from your return alone. I did not open the corpus, the records, or the code you cite —
you hold the files, I hold the theory; a check by me would only bias the check by you. Where I
state a number below, it is arithmetic from your constants, not a measurement._

### H0. What your return changed in the theory (four things)

**H0-a. Q1 collapses. The tick problem is closed by the throttler; the GRAZING residual is closed
by a segment test.** Your formula is at POLL_MIN inside 11 yd, so a point test already sees 7.1 /
⚠⚠ **RI-34, 2026-08-20 — THE FIGURES IN THIS BLOCK ARE AT THE OLD CONSTANTS (0.2 s, MCS 30).**
At the settled 0.1 s / 100 the floor applies from **15 yd** and a centre transit of R = 5 gets
**14.3 samples at run speed** (7.2 mounted). ★ The block's CONCLUSION is unchanged and its
ceiling figure is not: 30 yd/s was borrowed from Landmarks; the corpus holds 50.6.
3.6 / 1.7 samples through the centre. What survives is the edge-clip. In closed form, for a
straight transit at lateral offset `o` from centre, chord = `2·√(R²−o²)`; a point test at step
`s = v·T` can miss any transit with `o > √(R² − (s/2)²)`. With uniform offsets that miss-fraction is
`1 − √(1 − (s/2R)²)`:

      R = 5 yd     run 7 yd/s (s 1.4)   ->  1.0 % missable
                   mount 14   (s 2.8)   ->  4.0 %
                   ceiling 30 (s 6.0)   ->  20.0 %

**A SEGMENT test drives every row to 0 %** (up to path curvature inside one 0.2 s step): the
driver already holds its previous position, so per tick it asks whether the *segment* between the
last valid sample and this one passes within R of the beacon — not whether this *point* does. It
is exact for a straight pass and needs nothing beyond the two positions. Cost in H4.

**H0-b. Detection should not read the tracker at all — proposal, needs a ruling.** Both terms of
the reach check come from `GetCurrentPlayerPosition()` (B2) plus the beacon's stored xyz. Your own
proof (C2, 1e-5 over 1,758 samples) says arithmetic distance IS the engine's distance. Using it
for detection buys three things structurally: (1) an exact 2D-radius-plus-band cylinder (engine 3D
≤ R with a band gate is a lens, not a cylinder — tighter at the vertical extremes); (2) **the
`0.00`-on-Invalid false-fire channel cannot exist**, because detection never reads a tracker
distance; (3) the segment test becomes possible. ⚠ This touches the brief's *"never compute your
own"* line and the stop-list's *"no distance function from scratch."* My position: that ruling
guarded against two distances that disagree; the 1e-5 proof retired that risk. Euclid on
validated coordinates is not "from scratch." **Battlewrath's call whether the ruling was about the
READOUT or about DIVERGENCE** — I'm asking, not overriding. The tracker stays the POINTING organ
(the arrow) and the calibration reference; that role is untouched.

> **RULED (Battlewrath, 2026-08-17): detection uses our OWN positions. The tracker's reading is
> for CALIBRATION — in-flight, at all times, background-worker style: dest known (we set it),
> measured yards vs actual yards, paired every tick.** Pin-and-hold is not a phase, it is the
> driver's permanent idle task; the H5 divergence detector falls out of the same pair for free.
> **And the model is an INSTRUCTION SET, not detectors:** a route compiles at the desk (author's
> design against captured data) into ordered stages `{trigger: xyz, R, ±H} → {response: set
> tracker xyz', note text, stage++}`; the driver is a dumb walker over that program. The
> segment test in H4 is simply how a trigger evaluates.
> The AUTHOR DRAG (a data point re-positioned, world XY recomputed from the full-run
> calibration, 300–1,000 records at 1 Hz) is **PLANAR BY CONSTRUCTION — RULED (Battlewrath,
> 2026-08-17): height is never invented.** z is always the z of a REAL sample; a different height
> means picking a point that was sampled there. The band is the author saying *"we accept this
> XY, at THIS sampled height, ± H"* — inherited from the corpus or absent, never computed. (My
> earlier drag-z candidates withdrawn; the segment test's interpolated `cz` is a check AGAINST a
> sampled reference, never a source of one.)

**H0-c. Validity, restated for a pass-through beacon.** Landmarks' three checks are for a
destination you stop at. For a beacon you pass: the state check protects POINTING (H5), the
**mapID equality on the position call is the load-bearing gate for DETECTION**, and there is
**no hold** — a 1.0 s hold would MISS a mounted transit (3.6 samples × 0.2 s = 0.72 s inside).
Your R4 finding (the decline is a steady state, 57 samples) is exactly why the gate must be state-
shaped, not time-shaped — agreed, and under H0-b it stops mattering for detection at all.

**H0-d. Q3's home is my simulation harness.** "The walk" — a sprite walking a real run against a
route's detectors — is the same instrument that answers Q1's transit fraction and Q4's
reconstruction error. One desk tool, three questions. I'll build the desk side of it in Python
against the reduced corpus (H6); the model's walk gets the same numbers.

### H1. G1 — pin-inside probe: NOT blocking; fold into phase-1, with one addition

My desk work (Q1/Q2/Q4) runs on positions, not tracker distance — it does not need the probe.
What I DO need before the driver ships is the **across-floors row** (F-i, unmeasured): the axis
the band exists for. So: wait for phase-1, **but make phase-1's capture include ≥1 floor
transition and ≥1 deliberate boundary cross while pinned inside**, so the record holds the
transient shape of state/distance on those events. If phase-1 is more than ~a week out, the
standalone probe is worth its minutes — the same two events, one dungeon. And send the staging
`Height_map` / `Height_map_with_cross_walk` runs (R6): band DEFAULTS should come from real floor
separations, not a guess.

> ⚠⚠ **BENCH NOTE ON H1 (§250, Battlewrath): the boundary cross is not available
> in-instance, and the request halves.** *"I can zone out. But not as a part of
> in-instance. A zone is a load screen barrier and every dungeon is a single
> instance."* ★ There are no internal boundaries in a dungeon — one instance, one
> mapID, one continuous coordinate space (F30/F36 say a zone border is not a map
> change; this is the stronger form). The only boundary is the loading screen at
> entry/exit, **and that case is already measured** — it is exactly the 57 samples in
> F-i. ★ So the addition reduces to **≥1 floor transition**, which a full SFK walk
> gives naturally. Nothing is lost: the event you wanted the transient shape of has
> its record already.

### H2. G2 — "captured" defined

**Driver guarantee:** a transit is captured when the polyline of consecutive VALID samples (same
mapID, both endpoints present) **enters the cylinder** — segment-vs-cylinder, ≥1 hit, no hold, no
N. Segments whose endpoints straddle a mapID change or an absent sample are DISCARDED, never
bridged. **Metric (desk):** fraction of corpus transits whose true path enters the region that
the driver's rule detects, per R and per speed band; H0-a's closed form is the point-test
baseline, the segment test should read ~1.0 with residual = curvature-in-one-step. Do NOT inherit
the 1.0 s hold — correct for a destination, wrong for a doorway.

### H3. G3 — 1 Hz for MY analysis: adequate for corridors, marginal at R≈5 through turns

At 7 yd/s, 1 Hz is 7 yd between samples; a straight segment matches the true path (zero error), but
a 90° turn cuts the corner by up to ~`7/√2 ≈ 5 yd` — the same size as a doorway detector. So the
1 Hz corpus cannot serve as ground truth for R ≤ ~5 with turns. **Ask: two runs captured at
0.2 s** (POLL_MIN — one dungeon ≈ 3,000 points, trivial). I decimate them to 1 s / 2 s / 4 s on the
⚠ **RI-34 does NOT automatically move this.** This is the CAPTURE rate (producer side); the 0.1 s
floor is the DRIVER's. ★ They happened to share a number and no longer do — worth stating because
halving the capture interval would double the corpus for no stated need.
desk and measure reconstruction error at beacon scale — **that IS Q4, answered from data**, and it
tells us whether the existing 1 Hz corpus is usable for the transit metric or only for corridors.

### H4. G4 — the reach rule with its evaluation cost

Inputs per tick: player `p=(px,py,pz)`, previous valid `q`, beacon `b=(bx,by,bz)`, `R`, `bandUp`,
`bandDown`. All from one API call + stored constants. Compare squared distances — no sqrt.

    POINT   dx=px-bx; dy=py-by; d2=dx*dx+dy*dy      3 mul 2 add
            hit_r = d2 <= R*R                         1 cmp   (R*R precomputed)
            dz=pz-bz; hit_z = dz>=-bandDown and dz<=bandUp   1 sub 2 cmp
            fire = hit_r and hit_z                    ~9 ops

    SEGMENT ex=px-qx; ey=py-qy; fx=bx-qx; fy=by-qy   4 sub
            ee=ex*ex+ey*ey; fe=fx*ex+fy*ey            4 mul 2 add
            t = clamp(fe/ee, 0, 1)                    1 div 2 cmp   (ee==0 -> POINT)
            cx=qx+t*ex; cy=qy+t*ey                    2 mul 2 add
            gx=cx-bx; gy=cy-by; g2=gx*gx+gy*gy        2 sub 2 mul 1 add
            hit_r = g2 <= R*R                         1 cmp
            cz=qz+t*(pz-qz); dz=cz-bz; band as above  1 sub 1 mul 1 add 1 sub 2 cmp
            fire = hit_r and hit_z                    ~30 ops, 1 div, 0 sqrt

Storage: previous position (3 doubles) + its mapID + a valid flag. Nothing beyond one engine
call and a `dz`. At ≤5 Hz this is invisible on a frame. **Degradation:** previous sample absent /
other mapID / invalid → POINT test this tick only. Band applied at the CLOSEST point of the
segment (interpolated z) — a walkway-above transit is vetoed at the point where it would have
fired, which is the case the band was ruled for.

### H5. G5 — heartbeat: event-driven + divergence-detected, timer only as fallback

Two loss modes, two detectors, neither is a clock:
- **Map boundary** → `mapID` on the position call changes — we read it every tick anyway. Re-set
  on change. Event, not cadence.
- **Silent overwrite / silent decline** → **the calibration proof is the ownership detector:**
  each tick compare engine `sd` to our own distance-to-beacon; equal to 1e-5 means the tracker is
  ours and live; `|sd − d_own| > ε` (ε ≈ 1 yd) means it is pointing elsewhere OR declined
  (`0.00` diverges from a nonzero `d_own` — the R4 steady state is caught the same way). Re-set.
  Cost: 1 sub 1 cmp per tick.
- **Fallback timer** only where the divergence test can't run: rate-limit re-sets to POLL_MAX
  (2 s) so a tracker that CANNOT be set (pin outside, boundary) isn't hammered every tick.
"Low cadence" therefore ≈ *never on a clock while ours; immediately on evidence; ≤0.5 Hz while
refused.* ⚠ Two bench facts I don't hold: is a re-set visibly disruptive (arrow flicker), and does
re-setting while declined have a cost. ⚠ And this re-asserts while a stage is armed — which is
inside the F-ii "reclaim" question. Not mine to rule; flagging that the design assumes we own the
slot for the armed stage's duration.

### H6. G6 — reduced, please

One file per run, one row per sample: `t, gt, x, y, z, mapID, floor` **plus the flags** `combat`,
`ghost` (a ghost transit through a doorway is a modelling decision — I want to be able to filter,
not lose it). CSV or JSONL, either. Same form for the 0.2 s runs (H3) and the Height_map pair.

> ⚠⚠ **BENCH NOTE ON H6 (§254): `ghost` IS OUT — it cannot fire in a dungeon.**
> Battlewrath: *"Ghosts are out. You can not be a ghost in a dungeon. You are dead or
> alive."* ★ And the corpus agrees without argument: **9 runs, 5,295 legs, ZERO ghost
> legs — in a set that includes five deaths across two RFC runs.** So the reduced form
> is `t, gt, x, y, z, mapID, floor` **plus `combat` and `n`** (the pull index), and the
> death signal you want is not on the legs at all — it is an `end` MARKER carrying
> `dead`, with `killedBy`. ⚠ Filter on that instead; it is the terminal stop and it is
> richer than a per-sample flag would have been.

### H7. What I now consider Q1's deliverable (so nobody waits on a paper)

    the claim        segment-vs-cylinder detection; POINT fallback; no hold; mapID gate
    the derivation   H0-a closed form + H4 ops; walk-simulated on the corpus once H6 lands
    DESK / CLIENT    speed table + miss-fractions + safe-R: DESK, ship as constants
                     the ~30-op test: CLIENT
    degrades to      POINT test (prev sample absent) · "no data" for an unrun map (never a default)
    safe R           with the segment test the floor is position noise + curvature per step
                     (~1 yd order); with POINT only, R ≥ s/2 for a centre pass (3 yd at ceiling)
                     — that is *what is safe*; whether it becomes a floor is Battlewrath's, noted.

**Not answered, by design:** give-back/reclaim (F-ii), far-stage policy, any shipped radius
floor — Battlewrath's, as you listed. H0-b is the one item that needs a ruling before I build
against it; everything else proceeds on H6.

### H8. FIRST READ of the landed corpus — `test1` (2026-08-17, `0e38b61`, `addons/landing/corpus/`)

Read from the emitted files (provenance line: sha `a0cef0e1…`, `_provenanceCovers` = the whole
SavedVariables flush — correctly stated). 1,739 rows, pin INSIDE SFK (floor 6), walk across ALL
7 floors, cadence 0.2 s on every one of 1,738 intervals.

- **C2/C3/F-i — pin-and-hold WORKS first try, and measured the unmeasured row.** 1,564 live
  rows: `|sd−od|` mean 3.4e-6 · p99 1.3e-5 · **max 1.9e-5 yd** over 0.03–264 yd, dz −70..+5
  (cross-floor). `od` = 3D Euclid to the pin to 1e-13 → engine distance is 3D in-dungeon,
  pin-inside, across floors. Phase-1 calibration proven; 1,564 pairs produced by walking.
- **B3 — no declined state in this walk.** 175 `sd==0` rows, all contiguous at the start,
  `od==0` too = standing AT the pin 35 s. Zero rows `sd==0 ∧ od>0`. (And: `sd` alone cannot
  tell at-pin from declined; `od` splits them — H5's divergence detector, in data.)
- **A2 — run speed DERIVED: p50 7.00 yd/s** (p10 6.96 · p90 7.58 · p99 8.44 · max 9.02).
  R2's assumed 7 is measured. No mounted segments (indoor). Ceiling 30 stays a ceiling.
- **H3 satisfied** — test1 IS the 0.2 s run. **Q4 answered from data:** true 0.2 s path vs
  decimated polyline, 2D error (p50/p90/p99/max yd):
      1.0 s   0.01 / 0.75 / 1.61 / 2.41      ← 1 Hz ADEQUATE for R=5 placement + transit metric
      2.0 s   0.19 / 2.37 / 4.15 / 5.01      ← not adequate for R=5
      4.0 s   1.31 / 6.32 / 9.58 / 11.43
  Ships as a constant: capture at 1 Hz, do not go coarser. (My "marginal through turns" was
  pessimistic — SFK has plenty of turns.)
- **Next this lane runs:** the transit metric proper (segment vs point, per R) using the
  `markers` kill positions as pseudo-detectors — the walk simulation. Mounted speed still
  unmeasured (needs a mount-permitted capture; low priority). Declined-state row remains
  proven only by the satnav probe's 57 samples — correct, this walk was pin-inside.
- Housekeeping noted: SFK_Run4 dedupe (staging+records → 9→8); raw clone force-tracked for
  test1 so the hash has its bytes.

### H9. Inputs since the results landed (Battlewrath, 2026-08-17)

- **Mounted is rare BY CONSTRUCTION.** Dungeons are indoors, no mounting; one raid and one
  dungeon are the exceptions. → The speed model collapses to ONE row: design speed 7.0 yd/s
  (measured, H8). Point test ~1 % missable at R = 5, segment test 0. The 30 yd/s ceiling
  stays as an inert constant (the formula clamps at POLL_MIN by 11 yd out — ⚠ **15 yd at the
  settled 0.1/100, RI-34**; nobody pays for
  it). Safe-R and miss-fraction tables ship as the run row only.
- **The marker (supertracker) tracks cross-zone; renders to 1.5 k, tracks past 3 k.**
  Consistent with F22 / F32 / F35. It is the normal use case; proven in both indoor and the
  rare outdoor.
- **Pseudo-detectors need the detect-and-advance logic first.** The addon can SET and
  RELEASE the tracker; moving to the NEXT (set A → release → set B) is unproven in our addon
  (pfQuest proves the client allows it, via a rendered arrow/sprite). → Two things, split:
  the DESK WALK executes the rule offline against recorded paths and needs no addon logic —
  it IS the logic, run in Python, and becomes the golden the Lua port must reproduce; the
  live CHAIN PROBE is the one thing the desk cannot prove — minutes, in-client, bench-owned
  (acceptance W6).
- **ROLE SPLIT — no build in the analysis lane.** Advise and instruct; **the addons bench owns
  the build; the analysis lane tests the build against acceptance criteria** →
  `driver_walk_acceptance.md` (W0–W7). Goldens W2–W4 computed independently here from test1;
  failures return as observations with the number, never as fixes.

### H10. ACCEPTANCE — W2/W3/W4 (Analyst, 2026-08-17, on `9dc1cb0` / `ed9fd9c` / `ebcdc83`)

- **W2, W3, W4: ACCEPTED.** I ran `py addons/tools/walk.py check` myself; every printed number
  matches the goldens I computed independently before their code existed (W2 mean 3.36e-6 ·
  max 1.89e-5 · W3 p50 7.00 · W4 table to 0.01). Their design choice - goldens transcribed as
  DATA in the tool, not read from my file - is the right one: the target cannot move to meet
  the build. Their M1 (dz over all rows vs cross-floor) was correctly self-diagnosed; my
  sentence was right, their scope was wrong, no change.
- **M2 - their correction of ME, taken:** my W4 said "nearest segment", my own script
  BRACKETED. Bracketing is the better measure (global-nearest lets a later corridor flatter
  the reconstruction). Acceptance W4 reworded to "temporally bracketing"; the goldens were
  always bracketing.
- **§261 - their correction of ME, taken:** my boss-engage edit called it a "per-encounter API
  that says WHICH boss". Mechanism per the bench: an EVENT (`INSTANCE_ENCOUNTER_ENGAGE_UNIT`)
  + a TOKEN POLL (`boss1..boss5` names). A NAME is available, a GROUPING is not (§17). Enough
  for the second witness; not per-encounter. Advisory §11 reworded in my voice to match the
  mechanism; the two-phase design stands as they confirmed.
- **W2.2 second half - my choice: REDUCE the 57 satnav rows to corpus form**, not a second
  reader. Acceptance W2.2 annotated.

### H11. After the tracker side-road (Analyst, 2026-08-17) — cross-validated with the Bench's unaided basis

Battlewrath ran a cross-validation: the Bench stated, unaided, what the test runs were trying to
prove; the Analyst stated the designer's intent; compared. **Purpose statements ALIGNED** (W2–W4
= trust the record + constants; W1/W5/W7 = the rule, offline, port-reproducible). **Drift named
by both sides the same way:** tests 3–4 characterised the tracker's proximity state — an
instrument the ruling (R-a) says is not load-bearing — and the write-up briefly projected it
into detection ("arrival", "one radius", `ts` as mechanism) before Battlewrath's challenge
pulled it back. Nothing was built on it. Salvage:

- **B3 CLOSED** — the 1,386-row declined capture (`ts = 0`, `sd = 0`, pin not in this
  coordinate space) is the row's own evidence; supersedes the 57 satnav samples.
- **The 5.5 yd finding, at its right size (one line, deliberately no write-up):** `ts == 4 ⟺
  sd ≤ 5.5` (bracket 5.4595–5.5172, 4,952 rows, 2 of OUR pins), no hysteresis, no latency —
  a live comparator the arrow uses to draw itself; the game acts on neither state. **Not a
  driver mechanism under R-a.** `ts` is retained as a VERIFIER only: both its states are
  reproducible from data we hold (mapID; own distance), so it shouts if `od` ever drifts.
- **Method recorded:** the stop/start gait through a boundary separates a threshold from a
  lag (flip distance flat across speed). Keep.
- **A correction of the Bench's rate reasoning (Analyst):** "at the shipping 1 Hz a walker
  teleports 7 yd, so small tripwires don't fire" merges two rates. **1 Hz is the CAPTURE
  rate** — it bounds the offline walk and authoring placement (W4's 2.41 yd is THAT floor).
  **The live driver ticks at 0.2 s by 11 yd out** (A1's formula) — live stride 1.4 yd, segment
  test exact over it; the live pass-through floor is well under a yard. So a 0.5 yd wire is
  fine LIVE and wrong to PLACE or REPLAY against a 1 Hz capture. Their conclusion (a wire you
  cross vs a place you stand are different kinds) is right — advisory §4 already carries it as
  `once` (segment) vs `while` (point); the beacon knows its kind.
- **W2.2b:** may be satisfied by the declined capture directly IF it is emitted in corpus form
  with `od` — Bench to confirm; then the satnav-57 reduction is unnecessary.
- Bench-side open, not mine: `check_interface`'s unreachable zero.

### H12. GREEN on J1; W1.2 `invalid` relayed; J3 closed (Analyst, 2026-08-17, on `004ac2e`)

- **J1 — W1: GREEN.** Ran `py addons/tools/walk.py w1` myself: all eight PASS reproduce.
  Closed-form target confirmed independently (`o* = √(25−0.49) = 4.9507575`; their bisection
  4.950714 to 5e-4). What makes it evidence, not a pass: W1.6 fixture at WORST-CASE PHASE
  (samples at odd multiples of s/2 so the foot of perpendicular is always a midpoint — a
  fixture that could disagree); W1.2/W1.3 SYNTHETIC BY NECESSITY (mapID constant within every
  landed run → the straddle guard is unreachable from the corpus, and they said so rather than
  letting a green stand on an unexecuted branch); an unusable sample COUNTED and BREAKING the
  chain, not bridged. W1.5 monotonicity 0 violations; segment advantage +4/58 at R=2, gone by
  R=5 — the closed form in real data. W1.7 band at interpolated z catches both endpoint-test
  failure directions. W1.8 while semantics all four.
- **W1.2 `invalid` — DEFINED (relayed; acceptance W1.2 annotated):** position unusable — any
  of x/y/z/mapID nil or non-finite. Never `ts`/`sd`. Counted, chain-breaking, no bridging.
  Their reading was correct; now written.
- **J3 — CLOSED:** the declined capture carries `od`; W2.2 second half **1,386 / 1,386 rows
  flag at ε=1** — H5's detector on the declined state, in data. Satnav-57 reduction dropped.
- **J2 unblocked.** J5 waits on Battlewrath's trip, when he wants it.

### H13. ATTACK on `driver_posture.md` (Analyst, 2026-08-17, at `dbb63e7`) — six land, two on me

_Reviewed to attack, per Battlewrath. Ordered by consequence. Each: the claim · the attack ·
what kills or fixes it. Acceptance edits made where the attack lands on my criteria._

**A-1 · Posture §1 — the segment test has an UNEXERCISED BRANCH: the clamp.**
The W1.6 fixture is worst-case phase for the POINT test (foot of perpendicular at a sample
midpoint) — correct for what it proves. But for the SEGMENT test it means every one of the 501
offsets lands at t = 0.5: **the clamp branch (t < 0 or t > 1 → distance to an ENDPOINT) is
never executed.** An UNCLAMPED implementation (distance to the infinite line) passes W1.6, passes
W1.7 (band at interpolated z), passes W1.5 (line-distance ≤ segment-distance, so it fires MORE
— monotonicity is a weak guard here), and can pass W5.4. It fires on any beacon in line with a
stride, at any range along the line — false positives at corridor ends. KILL FIXTURE (added as
W1.9): beacon collinear with a segment, beyond its end by MORE than R → silent; beyond by LESS
than R → fires via the endpoint; and a phase sweep of the foot along t ∈ (0,1) so the segment
claim is proven at all phases, not one.

**A-2 · Posture §2 — `usable()` is necessary, not sufficient. Their own W1.3 fixture marks the
hazard PASS:** "same mapID — segment bridges a 40 yd gap and FIRES." A 40 yd gap at 1 Hz is
~6 strides of missing data; live, at POLL_MAX 2 s, it is ~3× the longest legal tick. Bridging it
invents a straight path through data we do not have — the exact principle they cite for the
invalid case, arriving by TIME instead of by nil. The chain-break rule needs a GAP BOUND:
a segment whose `dt` exceeds the cadence bound, or whose length exceeds `v_max · dt` (a
teleport), is a HOLE, not a step → point test on the next sample. Added as W1.10; the 40 yd
fixture flips from PASS to "must NOT bridge".

**A-3 · Posture §3/§6/W5 — before asking WHY RFC is harder, check three fixture semantics I
never pinned in W5:** (i) cadence per fixture — are the RFC "Messy" runs 1 Hz throughout, or do
combat legs thin the samples? (ii) is a marker the PLAYER's position at kill time, or the
MOB's? W5.4's premise ("a run passes through its own kill positions by construction") holds
ONLY for the former; a ranged kill puts a mob-marker where the player never stood, and RFC's
open caverns would show exactly "far worse point-test detection". (iii) marker time vs the
nearest legs sample: a CLEU-timed marker can sit up to half a stride (~3.5 yd at 1 Hz) from
its nearest sample, so a small-R point-test miss on the generating run is an ARTEFACT of
timing, not a property of the rule — which also inflates the "segment advantage at small R".
Until (ii)/(iii) are known, §3's persistence past R=5 and §6's 19-of-21 are unexplained, not
wrong. **W5 amended: order beacons by marker time AND emit each beacon's first-proximity
time**, so out-of-order pairs are visible as data.

**A-4 · Posture §5 — the attack lands on ME. My W5 two-rates note said the walk bounds live
"from the pessimistic side". Wrong in general, and their R=1 (12→13) shows it.** A decimated
polyline deviates from the true path by ≤ W4's reconstruction error in EITHER direction —
bulges (misses) and cut corners (phantom hits). Correct statement: a beacon within
`R − e_recon` of the true path is detected on both; a beacon in the annulus `R ± e_recon` is
uncertain in either direction. **W5 note rewritten as a symmetric bound.** Their kill fixture
(a beacon inside a known cut corner firing on the decimated path) is right and cheap; run it.

**A-5 · Posture §10 — the classification RULE should be a CHECK, not the placement decider.**
Constant-in-run → header, applied per run at emit, means the SAME field can be header in file
12 and a row in file 13. That is schema instability every reader must absorb. Decide a field's
placement ONCE, by kind; run the variance audit as a verifier that shouts when a "constant"
varies. Same distinction as `ts`: verifier, not mechanism.

**A-6 · Posture §11 — likely FALSE as stated, TRUE as a view-completeness point.** C1's proof
(the lookup) lives in the worldmap emitter's self-proof and `verify_calibration.py` over raw
records — "re-proven on every emit" is their own C1 return — so C1 stayed checkable the whole
time; that is the kill condition they named. What is true: the corpus VIEW should carry
`mapX/mapY` so the check is re-runnable from the landed record. Restate it that way.

**Also, on W7 (my criterion):** the branches that are unreachable from the corpus (straddle,
non-finite, and now the clamp and the gap bound) must be graded on the Lua port with the SAME
synthetic fixtures — a port test that only replays the corpus ships those branches unproven.
And Lua's two-test NaN (`type(v) ~= "number"` and `v ~= v`) is exactly the kind of thing that
fixture catches. W7 amended.

**Not attacked:** §4 (fine, but see A-1 — monotonicity does not guard the clamp), §7 (agree:
`hit` is the honest column; add `skips` and `false_advances` beside it), §8/§9 (nothing built
on them), §12 (synthetic by necessity — correct; W7 inherits it).

### H14. J2 accepted; `rfc_combat` read; three rulings + the boundary (Analyst, 2026-08-17)

**J2 — W5: ACCEPTED as emitted.** `walk.py w5` reproduces on my run (W5.1 tables, W5.2 both K,
W5.4 PASS, W5.5, the test1 two-cadence table 12/18/18/18 vs 13/16/16/18). Emitted, no
recommendation — as specified. `hit` beside `stage` everywhere: correct, keep.

**Posture §3 retraction = A-2 vindicated in real data.** The pre-regime RFC "segment advantage
past R=5" was the segment test BRIDGING 43 / 69 / 125 s combat holes. That is exactly the
hazard W1.10 names, and it makes those three runs the ONE place the gap-bound branch is
reachable from the corpus (unlike straddle / non-finite / clamp).

**Ruling 1 — rfc_combat REPLACES the three pre-regime RFC fixtures in W5; they RETIRE from W5
and MOVE to W1.10.** They cannot fairly measure transit (their holes bracket exactly where the
kill markers sit) but they are the natural real-data fixture for the gap bound: under W1.10
each hole must break the chain, and W5.4 on them must then FAIL for the right reason — the
kill sat inside a hole. Retire-and-repurpose, not retire-and-drop.

**Ruling 2 — YES, W5's route source changes: THREE sources, each testing a different thing.**
  (a) kill markers as pseudo-beacons → GEOMETRY only (W5.1 transit fraction): does the rule
      detect passing a position the player provably occupied. Keep — it is what W5.1 always
      really tested, and it is authoring-agnostic.
  (b) combat-END markers as pseudo-LURES → PROGRESSION in the operating envelope: "pull
      complete → accelerate to the next" is Battlewrath's own description of where the driver
      works, and a combat-end position is a SAMPLE, so it invents nothing. W5.2/W5.3 timelines
      run here.
  (c) authored pins where a fixture carries them (rfc_combat's six) → the REAL kind, lure /
      destination distinguished by where they sit relative to combat (six for six in the
      data). Small N, real signal; grows with every designed capture.
  And the boss-set branch, ABSENT on SFK fixtures, is now TESTABLE on rfc_combat (boss names +
  engagement timestamps are in the record): add it to W5.3's causes there.

**Ruling 3 — W5.4 SURVIVES for regime fixtures, CONDITIONAL on A-3(ii).** "A run passes through
its own kill positions by construction" holds iff a marker is the PLAYER's position at kill
time. If it is the mob's, W5.4 was never valid on any fixture. Bench: state which, from the
marker code (one line). On regime fixtures (max gap 0.23 s) W5.4 should hold under either
combat or gap; on the retired RFC trio it must FAIL under W1.10 — which is the test.

**The boundary — agreed, and it is the right shape.** We hold NO mob positions: player
positions, combat brackets, boss names. So a criterion "a beacon must not sit inside a pull" is
unauthorable — and under §17 it SHOULD be: whether a place is a pull is dungeon knowledge.
What IS authorable and emit-only: the player's COMBAT FOOTPRINT — "this pin sits inside the
player's in-combat positions on N of M runs" — a readout the author reads, never a rule.
The lure/destination split then stays where Battlewrath put it: the author's placement.

**Smaller items from the result, taken:**
- Two-rates: their "one-directional, not symmetric" and my "symmetric bound" are the same
  content — deviations in EITHER direction, so neither side is a safe bound. Criterion stands:
  the cut-corner synthetic (W5 note) — run it.
- `while` radii: **R covers the excursion (rMAX), not r99** — Taragaman 17.4 vs 9.2 would have
  dropped the fight; Jergosh 29.4 evenly. Both flat (dz ≈ 1) → a boss `while` is a true 2D
  region, tight band. Emitted per fixture; the author reads it. Only measurable because
  `bosses` (engage timestamp) separates fight from approach — H0's boss row earning its keep.
- **W4 splits by regime:** reconstruction max 2.22 yd INSIDE gaps (W4 holds where the driver
  works), 4.95 yd inside pulls. Ship both: e_recon(gap) 2.4 · e_recon(combat) 5.0 — authoring
  against a 1 Hz capture that includes fighting has the larger floor.
- `MAX_CLOSING_SPEED = 30` exceeded (50.6 peak, Scythe Rush charge, 14 samples, all inside
  pulls). Wrong and does not matter: with the segment test the ceiling governs POINTING
  cadence only, never detection. Leave it; note the measurement.
- **W1.10's length half is weak — agreed.** Scythe Rush is real traversal at ~50 yd/s in two
  ticks; a `v_max` that keeps it constrains nothing at 1 Hz. **W1.10 amended: the `dt` bound is
  the criterion (it detects MISSING SAMPLES, the actual fault); the length test survives only
  as a TELEPORT detector at a deliberately absurd v_max (≥100 yd/s — a loading-screen
  relocation is instantaneous, not fast).**
- The skip / C-motion element: correctly reported absent; a curvature measure is authoring-
  tool territory, not a driver criterion. Parked, named.

9 unpushed commits: I read the working tree; push whenever, it does not block me.

### H15. Battlewrath's challenge — "is this becoming a model of combat?" YES; corrected (Analyst)

The product question is two things and only two: **can the driver detect a player within R of a
location with the H dimension SHAPED (band = player height + jump affordance, or opened), and
can an author programmatically place such locations and the addon react to them.** Not route
generation; not what combat looks like.

**Where I drifted (H14 Ruling 2 and its trailers):** "combat-END markers as pseudo-lures in the
operating envelope", "boss `while` R must cover the excursion", the "combat footprint" readout.
Each dressed a corpus observation as a criterion — a step toward a model of combat, which is
dungeon knowledge (§17). The rfc_combat headline is a true observation about one run; the
acceptance must not depend on it.

**Corrected:** a test route is ANY ordered set of SAMPLED positions; the driver is graded on
its REACTION to placements, never on their sense. Three-source framing withdrawn as a
criterion structure (acceptance W5 rewritten). Combat-shaped material → author-side readouts,
outside acceptance. **Added W3.2:** the default tight band SOURCED from the corpus (walking dz
jitter · jump excursion → bandUp · drop → bandDown; admit p99 jump, reject the smallest
Height_map floor separation) — squarely the product, and it was missing.
Ruling 1 (RFC trio → W1.10) and Ruling 3 (W5.4 conditional on marker = player) stand; they
are about the RULE, not about combat.

### H16. ACCEPTANCE at `e073820` + remaining desk challenges (Analyst, 2026-08-17)

**Verified on my own runs:** W1 ten criteria PASS (list shows W1.9/W1.10 green; the summary
line still says "eight" — cosmetic) · W5 emitted, W5.4 PASS · `check` reproduces every W2/W3/W4
golden. **Acceptance state as the Bench tabled it is CONFIRMED:**

    W1 PASS (10)  ·  W2 PASS  ·  W3 PASS  ·  W3.2 EMITTED (band sourced, tone below)
    W4 PASS  ·  W5 EMITTED + W5.4 PASS  ·  W6 DONE  ·  W7 awaits a Lua consumer

**Two of Battlewrath's challenges, taken and now recorded (they were held un-written at his
"no edits yet"):**
- **The product is a CONDITIONAL STATE MACHINE, not a simulation.** Given a position stream and
  an instruction set: evaluate a condition → ACCEPT the player is there → fire the response →
  WRITE THE NEXT DIRECTION. The readings (W2–W4, tracker states, gap regimes) were BASIS and
  are taken; my W0 word "simulator" invited reading-taking as proof — withdrawn. What remains
  to prove is TRANSITIONS, and W7 grades them on the port.
- **"Can we cycle points" was never a thesis.** Landmarks sets and clears (Beacon.Clear,
  AC-27); the arc of this addon is conditions on acceptance + writing a new direction. W6
  confirmed the only unproven op (set-after-clear: overwrite instantaneous, `ts=0` at clear =
  view gone, calibration pair survives the switch at 1.99e-5). I built W6 too large; the
  Bench shrank it correctly (§288).
- **W3.2 tone (Battlewrath, §285/§286): the band is a TOLERANCE, not a model.** "Characters
  always land — catch them on land, tolerate some jump distance." bandUp exists to protect a
  run-over from a second floor; its ceiling is set by WHERE BEACONS GO (stairs are transit),
  not by the tightest stack geometry permits. **±2.5 stands.** My W3.2 wording leaned toward
  measuring the jump precisely; the measurement was fine as basis, wrong as a constraint.

**Remaining desk challenges — all small, all for the port, none blocking:**
- **C-1 · clear is a CONDITION in the instruction set, not a driver rule (Battlewrath,
  2026-08-17).** The marker never releases itself (W6), but the driver has no "finish"
  behaviour — it executes an instruction whose response is *clear the pointer*, exactly as it
  executes *set the pointer here* or *show this note*. The last stage's clear is the last
  instruction's authored close (advisory §9). W7 item: the driver EXECUTES an authored clear;
  the flatten may TELL an author "last stage has no close" — it never decides for them.
  His sequence is the whole product: *go here · go here · follow this note · ok, stage
  complete — come to me (lure).* Pointer moves by the next set (overwrite) or clears by an
  authored condition; the driver contributes no opinions.
  _/reload — RULED OUT as a driver concern (Battlewrath, 2026-08-17): "Reload is not a
  combat-flow issue. We don't know when a user reloads. That is USER RECOVERY — scroll through
  the chains they've done and stop where they're up to." So: no persistence semantics to
  design, no clear-on-load; recovery is a manual SEEK along the stages, which is also the
  shape of the model's "player corrects the index" requirement — a control, not a guess._
- **C-2 · the throttler's slack term.** Landmarks paces on `TierYards(tier)`; the driver
  paces on the CURRENT beacon's R: `slack = (dist − R) / MAX_CLOSING_SPEED`. A port change,
  not a design change; W7 should see POLL_MIN reached by `R + 6` yd out. ⚠ **RI-34: `R + 10`
  now (0.1 × 100), i.e. 15 yd at R = 5.**
- **C-3 · "fires at 4.0–4.8 for a 5 yd trigger" is a fact for AUTHORS, not a defect.** At 0.2 s
  and walking pace the last yard is crossed between samples — W1.6 live. R is "no later than",
  not "at". Emit it once in the authoring readout; do not compensate in the rule.
- **C-4 · W6.2 pin trace.** capture.lua writes testPin once at arm; a driver re-pointing per
  stage leaves no record of what it pointed at when. The walk cannot replay multi-stage
  pointing until the record carries a `pin` change per event. Capture change, prerequisite
  for W7 on any multi-stage route.
- **C-5 · ordinal stages with fractions.** The ratchet compares stage NUMBERS (4.0 < 4.1 < 5);
  K-forward counts POSITIONS in the sequence, not integer steps. State it in the port so a
  4.1 insert does not silently widen or narrow the window.
- **C-6 · `ts` in the consumer.** Read for the heartbeat verifier only (`ts=0` ⇒ view gone /
  declined; divergence `|sd−od|` is the primary). Never in the acceptance condition. Restated
  because it is the one place the port could quietly re-open the `0.00` channel.

---

## K. GAP ANALYSIS — from proven basis to the ADDON (Analyst, 2026-08-17)

_Where we are, and what the addon needs. Grounded in mvp_scope.md ("everything AUTHORS, nothing
PLAYS — `Routes.BeaconAt` has no caller"), the model's ratchet/flight-list sections, and the
acceptance state above._

**PROVEN (basis + rule) — nothing more to read:**
    distance & position   own xyz == engine to 1e-5, across floors, across pin switches
    speed / cadence       7.0 yd/s design; 0.2 s live tick; 1 Hz capture adequate (2.4 gap /
                          4.95 pull)
    band                  ±2.5 tolerance, ruled; z datum = base point; jump transient
    tracker               ts states characterised → verifier only; overwrite instantaneous;
                          ts=0 on clear; declined state = sd 0 / od > 0, detected 1,386/1,386
    the rule              W1 ten criteria; segment/point; clamp; gap bound; band veto; while
    the harness           walk.py = the desk golden; W5 fitment readouts; W3.2 band emitted

**THE GAP IS SINGULAR (mvp_scope): a CONSUMER. Nothing plays.** What the addon needs, in the
order the scope already set — the v1 cut is childless beacons, ratchet only:

    G1  THE DRIVER (Lua, in COA_DungeonRun)   the state machine, ported from walk.py's rule
        arm route → on-ramp: set tracker to beacon N (Landmarks set) → each tick: own position,
        H4 condition (segment `once` / point `while`, band, mapID gate, gap bound) → accept →
        off-ramp: ratchet advance → next on-ramp → finish: RELEASE (Beacon.Clear; required, C-1)
        + heartbeat verifier (divergence; ts as check) + throttler with R (C-2)
        v1 reads the route structure directly (flatten deferred, per scope). W7 grades it.
    G2  CAPTURE: pin trace (C-4)   record each pin set/clear per stage so the walk can replay
        multi-stage pointing; the same record feeds W7 byte-equal timelines.
    G3  THE ROUTE REMOTE (scope: seventh surface, spawned from Promotion)   arm / go / stop /
        report; inherits the loaded route; no typed commands. Interface file + rows.
    G4  THE OVERHAUL, first pass (scope: MVP-scoped)   present exactly the controls to author
        one route of childless beacons: Face : Stage 1 : Stage 2, inside them supertracker y/n
        + reach (R, band). Nothing else in pass one.
    G5  WIPE SAVED VARIABLES before the first run (scope: beacons pre-§227 carry no id).
    G6  USER RECOVERY (was "/reload semantics" — RULED, C-1): a manual SEEK along the chain
        — scroll the stages, stop where you're up to. Belongs to the route remote (G3) as a
        control; the driver designs nothing around reload.

**Rulings still owed (Battlewrath), and what each unblocks:**
    F-ii  give-back / reclaim   mechanically trivial now (W6); a PRODUCT decision on
                                invasiveness. Unblocks the driver's re-pin-per-stage line.
    far-stage / K               build-to-lookable via the walk (W5.2 already emits K=all vs
                                K=3); ruling can wait for the first real route.
    radius floor                "no" leans the project; nothing blocked.

**Deferred BY DESIGN (scope), not gaps:** children · notes · boss/CLEU sync · maxSeen +
escapement · correction path · consequence register · the flatten/flight list (destination,
not start) · package/import economy (advisory §12) · the editor's walk (advisory §11).

**Analyst's readiness:** W7 criteria written (W7.1 byte-equal timeline, W7.2 synthetics on the
port, W7.3 honest columns) + C-1..C-6 above. When G1 lands, this lane runs the same fixtures
through the Lua consumer and reports PASS/FAIL per criterion. Nothing else waiting on me.

---

## I. STATE LEDGER — closed / open / who moves next (kept current; last 2026-08-17)

    CLOSED by evidence
      A1  throttler exists, formula known                          bench return
      A2  run speed 7.00 yd/s (p50; p99 8.44); mounted rare-by-construction   H8 + H9
      A4  chord/tick problem: not a problem at POLL_MIN; grazing residual → segment test   R2 + H0-a
      B2  own-position API = capture API; od is 3D Euclid (1e-13)  bench return + H8
      C1  two transforms (lookup exact / fit per-floor); 389→1,462 corrected   R5
      C2  engine 3D distance at 1e-5 — RE-PROVEN in-dungeon, pin-inside, across 7 floors,
          max 1.9e-5 over 0.03–264 yd                                H8
      C3  pin-and-hold: BUILT and worked first try (1,564 pairs)   H8
      F-i middle row (pin in / player in) MEASURED; across-floors row MEASURED   H8
      H3  fine-cadence run: test1 IS 0.2 s                          H8
      Q4  1 Hz adequate (2.41 yd max reconstruction error); 2 s is not   H8
      H0-b RULED: detection = own positions; tracker = calibration + arrow   Battlewrath
      drag-z RULED: height by construction, z is always a sample   Battlewrath
      E1  Q3 convergence parked as driver concern; lives in the walk   bench return

      W2 W3 W4  walk goldens reproduced; ACCEPTED by Analyst on independent run   H10
      W3/W4 now SHIPPING CONSTANTS: design speed 7.0 yd/s · capture at 1 Hz (2.41 yd max)
      B3   declined state has its own capture: 1,386 rows ts=0/sd=0, pin outside   H11
      ts   the tracker's proximity state characterised (5.5 yd comparator, no hysteresis,
           no latency); NOT a driver mechanism (R-a); kept as a VERIFIER only   H11

      W1   detection rule — all eight criteria; GREEN on Analyst's independent run   H12
      W2.2 second half — declined capture 1,386/1,386 flagged at ε=1   H12
      W1.2 `invalid` defined (position unusable; never ts/sd; chain-breaking)   H12
      J6   check_interface exits 0 again (bench, 2245576)

      W5   transit metric emitted; ACCEPTED on Analyst's independent run   H14
      posture §3 retracted by Bench (pre-regime holes = A-2 in real data)   H14
      rfc_combat: detection happens in combat GAPS (24 % of a run); lure/destination split
           6/6; while radii rMAX 17.4 / 29.4 flat; W4 splits 2.2 gap / 4.95 pull   H14
      Rulings: RFC trio RETIRE from W5 → W1.10 fixtures · W5 route sources = kills (geometry)
           + combat-END (progression) + authored pins · W5.4 conditional on marker=player   H14

      W1.9 W1.10  clamp + gap bound PASS; A-3 semantics pinned; A-4 cut-corner reproduced;
                  A-5/A-6 done; J4 done   (Bench, e073820)   H16
      W3.2  band EMITTED; ±2.5 stands as TOLERANCE (Battlewrath §285/§286)   H16
      W6    DONE — overwrite instantaneous, ts=0 on clear, pair survives switch   H16
      ACCEPTANCE CONFIRMED at e073820 on Analyst's runs   H16

    OPEN — the addon (gap analysis §K)
      G1  the DRIVER (Lua consumer) — port of the rule; W7 grades it   ← the singular gap
      G2  capture pin trace (C-4)   G3  route remote   G4  overhaul pass one
      G5  wipe SVs before first run   G6  user recovery = manual seek along the chain (ruled;
          a route-remote control, not driver logic)
      cosmetic: walk.py W1 summary line says "eight", lists ten
      push the 22 commits when convenient
    OPEN — Battlewrath's rulings
      F-ii give-back/reclaim (unblocks re-pin-per-stage line in G1) · far-stage/K (walk-
      lookable, can wait) · radius floor (leans no)
      H5     two bench facts: is a tracker re-set visibly disruptive; cost of re-set while
             declined
      A2     mounted speed — unmeasured, low priority (rare by construction)

    OPEN — analysis lane moves next
      W-tests  run the bench's walk against W0–W7 when it lands; report PASS/FAIL + number
      §H0-a    extend the closed form to the actual throttler schedule (not just POLL_MIN)
               once the bench confirms the segment test is what ships

    OPEN — Battlewrath's rulings (not derived here)
      (see below §J for the Bench's pickup docket)

## J. PICKUP DOCKET — Bench (Analyst, 2026-08-17; pick up cold from here)

_In order. Each item: what · against which criterion · what to hand back. Structural criteria
are in `driver_walk_acceptance.md`; nothing here needs a ruling first._

    J1  W1 — the detection rule in walk.py, as the consumer will run it
        build   segment test (H4: 2D point-to-segment on xy, band at interpolated z, squared
                distances) · point fallback (prev absent / other mapID / invalid) · discard
                segments across a mapID change · no hold · once|while (while: point test +
                hysteresis R → R+margin) · K-forward listen · one-way ratchet
        prove   W1.5 segment ≥ point on every fixture/R · W1.6 synthetic straight transit
                (R=5, s=1.4, offsets 0..5: point misses iff o > √(R²−(s/2)²), segment never)
                · W1.7 band veto (walkway-above) · W1.8 while semantics
        hand back  a W1 section in driver_walk_result.md: each sub-item PASS/FAIL + the
                observed number; the synthetic fixture checked in beside the tool

    J2  W5 — the transit metric on the corpus
        route   marker positions of SFK_live (21) and SFK_Run4 (58) as pseudo-beacons,
                ordered by first-visit time; R ∈ {2,3,5,8,12}; band open
        prove   W5.1 transit fraction point vs segment per R · W5.2 false advances under
                K=all and K=3 · W5.3 stage timeline (stage, gt, cause) · W5.4 the generating
                run reaches its own last stage at R=5 (if not, look at the walk or the
                markers FIRST) · W5.5 cross-fixture, numbers only
        note    every readout carries the two-rates line (W5 ⚠): walk misses bound live
                pessimistically; on test1 (0.2 s) replay at 0.2 s AND decimated to 1 s, same
                route, to show the gap directly
        hand back  a W5 section: the tables, no recommendation

    J3  W2.2b — the divergence detector's second half
        check   does the 1,386-row declined capture carry `od` in corpus form?
                YES → run W2.2 on it: every row with own distance > ε (1 yd) must flag
                NO  → reduce the satnav 57 to corpus form (t gt x y z mapID floor sd od)
                      and run there
        hand back  rows flagged / rows total, and which path was taken

    J4  emit — carry `ts` through reduce_run as a column; re-emit the four runs (their item 1)
        hand back  the provenance lines; note `ts` is a VERIFIER only (H11)

    J5  W6 — the live chain probe (Battlewrath's trip, bench-instrumented)
        do      set A → walk → release → set B → walk, stop/start gait through B's boundary
        prove   W6.1 B renders + tracks (state valid, sd ≈ own distance to B) · W6.2 the pin
                change is visible in the record · W6.3 what happened to the player's own quest
                tracker (F-ii EVIDENCE — recorded, not ruled)
        hand back  the capture in corpus form + a three-line note per criterion

    J6  bench-internal — check_interface's unreachable zero (yours; not on my path)

    NOT to do    the quest-POI radius walk (irrelevant under R-a; F24 already covers F-ii) ·
                 any 5.5 write-up (held at one line, H11) · anything on `ts` beyond J4

    When J1–J3 land, the Analyst tests them against W1/W5/W2.2 and answers in §H; then
    W7 (port fidelity) opens as the next criterion once a Lua consumer exists.
      give-back / reclaim (F-ii) · far-stage policy beyond K · any shipped radius floor ·
      depth > 1 (nested theaters) · the walk's exact form as an authoring tool

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
      ⚠ RI-34: 15 yards out at the settled 0.1 / 100
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
