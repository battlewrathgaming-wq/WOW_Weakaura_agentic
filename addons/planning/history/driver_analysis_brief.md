> ⚠ **THE OPENING BRIEF — HISTORY. Read `DRIVER_BASIS.md` first.** §2's "never compute your own
> distance" is OVERRULED (detection uses own positions, R-a). Bounds §5 and stops §6 still hold.

# Driver analysis — A BRIEF

_For the analysis lane (data modelling · computational geometry · corpus work). Written by the
addons bench, 2026-08-16. **You are enriching a driver that does not exist yet, from a considered
point — so that we build to a spec rather than discover one.**_

⚠ **Read `dungeonrun_model.md` first, then `mvp_scope.md`.** This brief gives you the basis, the
constraints and the questions. It does not restate the model, and where the two disagree the model
wins.

---

## 1. What the driver is

A player authors a **route**: an ordered set of beacons, each a position captured by someone
actually standing there. The driver walks that route at runtime — points the player at the current
beacon, notices arrival, advances a **ratchet**, points at the next. That is the whole of it.

    on-ramp    stage becomes N   ->  set the supertracker to beacon N
    off-ramp   within reach      ->  advance the ratchet
    finish     last stage satisfied

**The v1 cut is deliberately smaller than the model**: a route of childless beacons, ratchet only,
no branching, no boss triggers, no correction path. Everything you propose should serve *that* first
and generalise second.

★ **The driver's real product is disagreement.** Every ruling in this model since §78 was argued
against a consumer that did not exist. The first walk is what tells us whether any of it was right.

---

## 2. The basis — PROVEN, do not re-derive

| fact | strength |
|---|---|
| **The world-map transform is a LOOKUP** from the client's own DBC boxes — correct on the first visit to a dungeon nobody has run | worst error `0.000000` across **1,462** captured points, four runs, two dungeons — **re-proven on every emit** |
| **And a separate RUNTIME fit** (`calibrate.lua`) derives a per-map, **per-floor** constant from runs we already hold | `0.000203` yd worst, measured. ⚠ Needs runs; ABSENT for an unrun dungeon |
| **Calibration is a constant of the MAP, not of a run.** Fitted from runs we already hold; a dungeon nobody has run has **no** calibration | measured; and it is a design rule, not just a result |
| **`GetSuperTrackedPosition`'s distance is engine 3D yards** | mean error `1e-5` over 1,758 samples. ⚠ **Never compute your own** where this is available |
| **`C_Timer.After` is frame-driven and identical to an OnUpdate accumulator** | measured, both clocks, same second |
| **Capture samples at 1 Hz**, and every point carries both clocks: `t = time()` joins, `gt = GetTime()` measures | in the data |
| **Reach is a vertical cylinder with an ASYMMETRIC band** — `radius` + `bandUp` + `bandDown` | a design decision, not an open question: a child on a walkway wants reach for whoever stands *on* it |

⚠ **`GetSuperTrackedPosition` returns SCREEN x/y plus a distance — not the target's world
position.** You can only compute a second term if you know where the target was put. That is why
calibration is designed as *the run pins at arm and holds it*: the run knows the coordinates because
it set them.

---

## 3. The platform — what a solution has to live inside

**Lua 5.1.5, inside a game client.** These are not preferences.

- **There is no time except a frame.** No threads, no sleep, no yield, no coroutine scheduler you
  can rely on. A long computation **stalls the client outright** — the game stops rendering. Any
  in-game algorithm is either cheap enough for one frame or must be chunked across frames by hand.
- **Doubles only.** No integer type, no `continue`, no `goto`.
- **SavedVariables are the only persistence**, written on `/reload` or logout — never incrementally.
  **No filesystem and no network at runtime.**
- ⚠ **The supertracker can be LOST while you still hold the intent** — a map boundary invalidates
  it, and other writers overwrite silently. A route may need a low-cadence heartbeat re-setting the
  position. **Reinforcement, never arbitration**: nothing is being contested.
- ⚠⚠ **Across a map boundary, supertracking reports state Invalid with distance `0.00` — not nil.**
  **Zero satisfies every radius test.** Any distance-only *"am I there yet"* check fires the instant
  you zone, and a loading screen does the same.

★★★ **THE FENCE THAT SHOULD SHAPE YOUR DESIGN: decide, for every result, whether it lives at the
DESK or in the CLIENT.** Anything expensive is welcome offline — we have a landed corpus of real
runs and a Python bench — and ships as constants. Anything the driver evaluates live must be cheap
and frame-bounded. **A clustering pass that is elegant in Python is unshippable inside a frame**, and
that constraint should shape the work rather than be discovered at the end.

---

## 4. The questions, ranked

**1. What fraction of real transits does a detector of radius R capture? (REVISED §243.)**
⚠ **This was written as a tick-rate question and that was wrong.** The existing pacing formula
(`COA_Landmarks/beacon.lua`, see the ask list) keys on **distance-to-tier**, which governs a
pass-through as much as an arrival — so it has already clamped to its 0.20 s floor eleven yards
out, and a 5 yd detector gets 7 samples at run speed, 3.6 mounted, 1.7 at the generous 30 yd/s
ceiling. **The clock is not the problem.**

What survives is the **grazing** pass, where the chord is far shorter than the diameter. And even
that is mostly closed by placement: a detector across a doorway means transits pass near centre
**by construction**. ★ So the real question is empirical, not geometric — **for radius `R` across
an opening of width `W`, what fraction of REAL transits are captured?** The corpus has the paths.

**2. What rejection rule do we apply to one scalar? (REFRAMED §243.)**
⚠ **There is no metric to choose.** Battlewrath: *"A position is a point… the game only ever
treats it as a single point. It is our rejection that gives it shape."* The engine returns ONE
number — a 3D distance. Sphere, cylinder and capsule do not exist to it; they are names for
which combinations of `(distance, dz)` **we refuse**.

★ So the question is: given `d3D` from the engine and a `dz` we compute ourselves, what
acceptance region do we want, and what does it cost to evaluate? The asymmetric band is ruled;
how it combines with the distance is not.

**3. Convergence over the corpus.**
*"Are the detectors where the paths CONVERGE, or only where I happened to walk?"* Clustering over
real landed runs. This is the one with data waiting for it.

**4. Is 1 Hz adequate for reconstruction?**
Separate from the driver's tick. A sampling question about whether a 1 Hz path is a good enough
record to place detectors against at all.

**And the calibration design, for your input rather than your decision:** the run sets a supertracker
pin at arm and holds it, so every sample carries the engine's distance *and* a known target
position — a continuous engine-versus-arithmetic pair at every range a dungeon offers. Phase two
moves a lighter passive version into the driver, if phase one shows it was worth carrying.

---

## 5. Bounds — lines that do not move

- ⚠⚠ **NEVER produce anything that tells the user what a good route IS.** The model's hardest line,
  and the one an optimiser crosses by default: *"anything that starts telling the user what a good
  route IS has crossed it — and it will look like helpfulness on the way over."* **We build the
  instrument, not the expertise.**
- **Ours is what changes what the player KNOWS** — a marker, the tracker, a readout. **Not ours is
  anything performing a gameplay input on their behalf.** *"A supertracker arrow is understanding. A
  cast is the world."*
- **We never learn dungeons.** No shipped per-dungeon table, no DBC dependency, no authored map
  data — *"so it can never be behind on a dungeon it has not seen."*
- ★ **ABSENT, NOT WRONG.** Every model you propose needs a defined *"we do not know yet"* state
  rather than a default. A dungeon nobody has run has no calibration, and that is the correct
  degradation.
- **Emit, don't interpret.** A number the user can look at is ours. A recommendation is not.

---

## 6. Stops — specific things not to spend effort on

    ✖ re-deriving units or the fraction->world fit          proven, error 0.000000
    ✖ designing a distance function from scratch            the engine gives 3D yards at 1e-5
    ✖ any route optimiser, scorer or ranker                 crosses the hardest bound above
    ✖ anything assuming threads, sleep, yield or a tick
      you control independently of frames                   there is no such thing here
    ✖ anything needing per-dungeon authored data            §17, and it is load-bearing
    ✖ deciding the reach SHAPE is open                      the asymmetric band is a ruling

---

## 7. What a usable deliverable looks like

**A spec the addon bench can build against**, not a paper. For each result:

    the claim          stated as a formula, a constant, or a threshold
    the derivation     shown, so it can be checked rather than trusted
    DESK or CLIENT     which side of the fence it is computed on
    what it degrades   to, when the inputs are absent

★ **And every finding phrased as something measurable.** *"Three runs converge within 4 yards here"*
is ours. *"Place your detector here"* is not — and the second is what the first turns into if nobody
says otherwise.
