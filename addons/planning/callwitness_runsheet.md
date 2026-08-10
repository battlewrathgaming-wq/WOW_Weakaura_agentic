# Call-witness run sheet — the four arms

_Execution card for `addons/planning/callwitness_design.md` §5. Settings per arm, commands,
and what to check before trusting each capture._

## Pre-flight (once)

1. **Full client restart** — `task_callwitness.lua` is a new file; `/reload` cannot load it.
2. **Turn the profiler on** (it was switched off after the last session):
   ```
   /console scriptProfile 1
   ```
   then `/reload`. Without it the engine-CPU cross-check columns (AC8) are meaningless zeros.
3. Confirm the task registered: `/coadump list` should show `callwitness`.
4. Isolate addons: for a clean read only the driver, COA_DevDump, and whatever you need to
   play should be loaded. Note anything else left on — it belongs in the arm notes.

**Note on conditions-as-a-capture:** the core allows only ONE open session task at a time, so
`cvarlog` cannot run alongside `callwitness`. It doesn't need to — `callwitness` snapshots the
nameplate CVars, the driver settings, the zone and the live plate count at **both** start and
end (AC6). Your written conditions are the second witness; the record is the first.

## The arms

Same command in every arm — only the conditions change:

```
/coadump st callwitness
   ... hold conditions for ~2 minutes, playing normally ...
/coadump sp
/reload
```

| arm | where | driver settings | answers |
|---|---|---|---|
| **A — worst** | packed capital, peak | plates **ON** · every names-only/text-only option **ticked** · capital mute **OFF** | Q1 which function · Q3 calls-vs-cost · Q4 burst shape |
| **B — best** | quiet/empty area | **identical to A** | Q5 population scaling, by contrast with A |
| **C — mute on** | packed capital, peak | identical to A **except capital mute ON** (plates off) | **Q2** — does the scan keep running with no plates? |
| **D — calibration** | packed capital, peak, as A | as A | AC7c — observer cost |

**Arm D is different:** it does NOT use `callwitness` (that always wraps). Run the unwrapped
sampler in the same conditions instead:

```
/coadump st perf LibellusLeti,COA_DevDump
   ... ~2 minutes ...
/coadump sp
/reload
```

Then compare its addon-level CPU against arm A's. That difference is the observer cost
measured independently of the in-task probe.

Keep A, B and C's settings **identical apart from the one named variable**. B changes location
only; C changes the mute only. If a setting drifts between arms the comparison is lost — and
the record will show it, which is the point of capturing settings at both ends.

## Check each summary line before moving on

The commit line prints:
`callwitness: N fn, N calls, Xms measured, Yms est. observer cost, N buckets, N outliers, unwrap N/N`

- **`fn` count** — should be well above the 11 the offline harness produced; the real driver
  exposes far more. A low number means paths didn't resolve; check `missingTargets`.
- **`calls`** — zero or near-zero in arm C would itself be the answer to Q2. Genuinely.
- **observer cost** — if it reads `0ms`, the client's `debugprofilestop` isn't advancing and
  the timing columns need distrusting (call counts remain valid).
- **`unwrap N/N`** — must be equal. Anything less means a wrapper was replaced underneath us
  and the client is left partly instrumented until reload.
- **`TRUNCATED`** — if present, shorten the window rather than trusting totals.

## After each arm

`/reload` flushes the mailbox; the watcher lands the record. **One arm per record** — the
mailbox holds the latest run only, so land each before starting the next.

Record which arm each `runId` belongs to as you go; the envelope carries the conditions but
not the arm's *name*.
