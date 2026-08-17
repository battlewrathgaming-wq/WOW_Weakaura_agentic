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

## H. THEORY BACK — analysis lane, 2026-08-17

_Written from your return alone. I did not open the corpus, the records, or the code you cite —
you hold the files, I hold the theory; a check by me would only bias the check by you. Where I
state a number below, it is arithmetic from your constants, not a measurement._

### H0. What your return changed in the theory (four things)

**H0-a. Q1 collapses. The tick problem is closed by the throttler; the GRAZING residual is closed
by a segment test.** Your formula is at POLL_MIN inside 11 yd, so a point test already sees 7.1 /
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
