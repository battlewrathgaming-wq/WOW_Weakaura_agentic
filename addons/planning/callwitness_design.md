# Call-witness — design criteria and acceptance test (written BEFORE the build)

_The instrument Battlewrath named in the Discord thread: **"a witness we do not have."** The
addon does not report its own call rates or per-function time, so every function-level claim
so far has been a source read. This builds the missing witness by wrapping their functions
in place — the addon calls its own method names, our counter runs inside its own call path.
Nothing on their disk changes; nothing is copied; it lifts off at task stop._

**Home:** a `task_callwitness.lua` in COA_DevDump (registry, envelope, mailbox and landing
pipeline already exist). Witness-satellite split is the designed migration when scopes
multiply — banked, not built (see "Deferred" below).

## 1. The questions this must answer

Each is currently open, and each has been explicitly refused as a guess in the findings bank.

| # | Question | Why it is open today |
|---|---|---|
| **Q1** | **Which function** accounts for the ~23.7 ms/sec? | `GetAddOnCPUUsage` attributes per ADDON. We have never been able to name a function from measurement. |
| **Q2** | Does the plate scan keep running when the capital mute has **plates off**? | Finding 4 is a source read (`ShouldApplyNamesOnly` never checks whether plates exist). Unmeasured. |
| **Q3** | Is the **~7.8 s periodicity** in the CALLS or only in the COST? | Finding 5. Calls flat + cost pulsing ⇒ garbage collection. Calls pulsing ⇒ workload/aliasing. Cannot be told apart at addon level. |
| **Q4** | Is a heavy second **one slow call or many fast ones**? | Determines whether the fix is "call it less" or "make it cheaper". |
| **Q5** | Does cost **scale with plate population**? | The author's own best/worst cases test exactly this; we currently have no population figure recorded at all. |

## 2. What must therefore be captured

- **Per named function, time-resolved (≤1 s buckets):** call count · total ms · **max single
  call ms** — for the driver's functions **and our own** (AC13). (Q1, Q3, Q4)
- **Per-call outlier events:** any single call over a threshold, with its own timestamp and
  duration. (Q4 — gives millisecond "what and when" without logging the 99% that is noise.)
- **Context on the same timeline:** framerate · engine-attributed addon CPU (the independent
  cross-check) · **live plate count**. (Q3, Q5)
- **Arm-defining state, so records cannot be confused later:** the nameplate CVars · the
  capital-mute setting · the relevant display/names-only options · zone name. (Q2, Q5)
- **Provenance:** `scriptProfile` state · driver build identified by **content hash of its
  files, not its version string** · our own wrapper overhead · whether unwrap succeeded.

Two of these exist because our last capture lacked them: **no CVar state** (we had to infer
plate state across a 52-minute gap) and **no population figure**. Both are being fixed here.

## 3. Acceptance criteria — the build is not done until every line is true

A record produced by this task must satisfy all of the following **on its own**, without
reference to notes, memory, or this conversation.

1. **AC1 — Function attribution.** The record names which wrapped function consumed the most
   time, and its share of the total, for any run.
2. **AC2 — Mute case answerable.** From a mute-on run alone, one can state whether the scan
   loop still ran, and at what rate. (Q2 becomes measurement, not inference.)
3. **AC3 — Calls vs cost separable.** Calls-per-second and ms-per-second are recorded as
   independent series per function, so their correlation can be computed offline. (Q3)
4. **AC4 — Burst decomposition.** For any second, the record distinguishes one slow call from
   many fast ones (max-ms and count both present; outliers timestamped). (Q4)
5. **AC5 — Population recorded.** Live plate count is sampled on the same timeline, so
   cost-vs-population is plottable without a second capture. (Q5)
6. **AC6 — Arm self-identifying.** The header states the nameplate CVars, the mute setting,
   the names-only/display options and the zone, at start AND end. Two records from different
   arms can never be mistaken for each other.
7. **AC7 — Observer cost MEASURED, three ways.** Not an assumption and not only a difference:
   (a) a **wrapped no-op probe** called a known number of times at task start, giving
   per-call wrapper cost directly; (b) that cost × observed call counts, giving total
   instrumentation overhead for the run; (c) the calibration arm (arm D) as an independent
   cross-check. If (b) and (c) disagree materially, the record must show both.
8. **AC8 — Cross-check present.** Wrapper-summed milliseconds and the engine's addon-level CPU
   appear side by side. Large divergence means we are missing call paths, and the record must
   make that visible rather than hide it.
9. **AC9 — Honest truncation.** If bounds are hit, the record says so explicitly (a flag and a
   dropped-count), never silently truncates. A partial capture must be identifiable as partial.
10. **AC10 — Clean removal.** Unwrap restores originals only where our wrapper is still in
    place, and the record states whether every wrapper came off. The client is never left
    instrumented.
11. **AC11 — No allocation on hot paths.** Wrappers on high-frequency functions allocate
    nothing (count-only tail-call; void-timed where the function returns nothing). We are
    testing a garbage-collection hypothesis — the instrument must not manufacture the effect
    it is measuring.
12. **AC12 — Build identified by content.** The driver's files are hashed into the header.
    Version strings are not trusted (this project ships a tag whose code is 0.9.434, an asset
    labelled 0.9.554 whose toc says 0.9.563, and a drop saying 0.9.553 carrying 554 features).
13. **AC13 — The witness witnesses ITSELF (Battlewrath, 2026-08-08).** COA_DevDump's own
    capture functions are wrapped on exactly the same footing as the driver's and appear in
    the same per-function table — not in a separate "overhead" note. Two reasons: it
    **self-accounts its contribution**, so "how much of this load is your profiler?" is
    answered from the record rather than asserted; and it **gives context for the sample**,
    since our sampler competes for the same frame budget the framerate column reports.
    A record in which our functions are absent, or measured by a different method than
    theirs, fails this criterion.

## 4. Design constraints

- **Representation:** flat integer arrays (ms-since-start, function index into a legend,
  duration in microseconds), not tables-of-tables. This is what makes per-call logging
  affordable — roughly an order of magnitude smaller.
- **Bounded by construction:** per-second buckets always computed, so even a truncated
  per-call log still yields totals (supports AC9).
- **Safety:** wrap only insecure UI functions; preserve `self`; never wrap anything the client
  treats as secure. Restore-if-still-ours on stop.
- **No self-recursion:** wrapping our own functions (AC13) must not instrument the counter
  path itself — the accumulator and the outlier writer stay unwrapped, or the witness measures
  its own measuring and the numbers become meaningless.
- **Guardrail:** instrumenting, never reproducing. No file of theirs is modified or copied
  into our products.

## 5. Test protocol (the arms)

The author's two cases, plus the one that tests our open finding, plus calibration:

| arm | conditions | what it settles |
|---|---|---|
| **A — worst** | packed capital at peak, plates ON, every names-only option ticked, mute OFF | Q1, Q3, Q4 at maximum signal |
| **B — best** | quiet/empty area, same settings | Q5 (population scaling), by contrast with A |
| **C — mute on** | packed capital, same settings, **mute ON** (plates off) | **Q2** — turns Finding 4 from source read into measurement |
| **D — calibration** | as A, wrapping disabled | AC7 — the observer cost |

Arms A and B are the author's own stated conditions and should be quoted as such.

## 6. Out of scope

- Diagnosing root cause on his behalf, or prescribing a fix. We produce the witness.
- Frame-level timing. Context stays at 1 Hz; sub-second resolution comes only from the
  outlier log.
- Any modification, redistribution or reimplementation of their addon.
- Player-damage or other lanes — this witnesses the plate/HUD call paths only.

## 7. Deferred (banked, not built)

**The witness-satellite split** (Battlewrath, 2026-08-08): separate addons, each owning one
witness scope and its own SavedVariables file, all driven from one command via a shared
registry — the State Plates satellite model applied to capture. Genuinely separate files,
failure isolation, independent enable. Deferred because flat-array representation keeps this
capture inside one file, and the split would cost puller changes plus an offline join between
us and the answer the thread is waiting on. Build it when two witness scopes need to run
concurrently with different volumes and lifetimes.
