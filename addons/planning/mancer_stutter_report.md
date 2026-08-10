# Libellus Leti — stutter: a measured observation + diagnostic lead

_Prepared by Battlewrath (Gravekeeper, Vol'jin — Conquest of Azeroth), 2026-07-31.
Offered because the same symptom has now been reported independently and the author is
asking which addon/settings/version are involved. This is a measurement, not a diagnosis:
what the profiler recorded, what it can't tell you, and where I'd look first._

## How it was measured (provenance)

- **Instrument:** a self-built capture task (COA_DevDump v2.2.0, task `perf`) sampling once
  per second: framerate, per-addon CPU milliseconds and memory, chat volume, latency.
- **Attribution:** run with `/console scriptProfile 1` (stamped in the record header as
  `profiler=1`, so a zero column is a measured zero, not an unmeasured one).
- **Record:** runId `20260731_152651_494`, window `15:26:51 → 15:29:04` (131s, 131 samples),
  client build 30300, character/class/realm stamped in the header.
- **Watchlist recorded in the record itself:** `LibellusLeti, TurboPlates, MancerLedger,
  COA_DevDump`.
- **Conditions:** standing in a capital city. Before this run I isolated by elimination —
  disabling my other addons one at a time — and the stutter persisted with Libellus Leti
  alone, which is why the profiled run was made.
- Two earlier runs (`20260731_151539`, `20260731_152232`) show the same framerate trough
  shape; the third run is the attributed one quoted here.

## What the record shows

Over the 131-second window, **Libellus Leti accounted for 3,111 ms of CPU — a mean of
23.7 ms per second of continuous work**, and it was the only addon in the table with a
measurable cost (my own sampler, for scale, cost 12.6 ms across the entire window).

That cost is not evenly spread. **17 of 130 sampled seconds contain a burst above 40 ms,
arriving on a regular cadence — median gap 8 seconds** — peaking at 108 ms in a single
second. The effect on framerate is direct:

| | mean framerate |
|---|---|
| seconds containing a burst | **55** |
| seconds without one | **97** |

And the alignment is exact. Taking the eight worst framerate seconds in the run
independently, **all eight land on a Libellus Leti burst in that same second**, with every
other watched addon at 0.0 ms:

```
 t+14s   fps 31.0   Mancer  58.4 ms
 t+30s   fps 38.5   Mancer  53.9 ms
 t+38s   fps 35.4   Mancer 100.3 ms
 t+46s   fps 32.1   Mancer  92.0 ms
 t+77s   fps 35.1   Mancer  84.0 ms
 t+92s   fps 39.5   Mancer  76.8 ms
 t+107s  fps 31.7   Mancer  48.1 ms
 t+130s  fps 31.1   Mancer  47.7 ms
```

For context: at ~90 fps a whole frame is about 11 ms, so a 100 ms burst inside one second
is roughly nine frames' worth of budget spent at once — which is what a visible lock feels
like.

## What this does NOT show (stated so it isn't over-read)

- **It cannot resolve per-frame timing.** The sampler ticks once per second, so a
  23.7 ms/sec average is invisible if it is spread across sixty frames, and a dropped frame
  every second if it is concentrated. The other reporter's "a flicker every second or two"
  is *consistent with* the concentrated case, but my data does not prove that cadence — a
  frame-time sampler would be needed to measure it.
- **It does not identify which code is spending the time.** `GetAddOnCPUUsage` attributes to
  the addon, not the function.
- **It is one machine, one session, in a capital city.** The framerate impact elsewhere may
  differ; the CPU figure is the durable part.

## Diagnostic lead (a hypothesis, not a finding)

Reading the published source for cadences that could match: several timers are installed
unconditionally at init rather than being gated on whether their display is shown, and a few
run very frequently — `RegenTracker.POLL_INTERVAL = 0.05` and two `ICON_PULSE_INTERVAL = 0.05`
loops (20/sec each), alongside `CLOAK_REASSERT 0.30`, `CLOAK_SCAN 0.50`, `SPELL_CD_SYNC 0.25`,
`ALERT_REFRESH 0.35`, `NAMEPLATE_SYNC 1.25`, `UNIT_SCAN 3.0`, and 5.0s sheet/seed refreshes.

Two observations worth checking against your own knowledge of the code:

1. The other reporter's stated 1–2 second rhythm coincides with
   `RegenTracker.DISPLAY_INTERVAL = 1.95`, `REGEN_TICK_SECONDS = 2` and
   `ADVISOR_POLL_INTERVAL = 2.0`. RegenTracker's `OnUpdate` is installed at init with no
   shown-state gate, so it runs whether or not anything is displayed.
2. My measured bursts land on a ~8 second cadence, which doesn't match any single interval
   above — so it may be a compound (several timers coinciding), or work whose *size* varies
   with the plate/unit population rather than its frequency. The capital-city setting would
   fit a population-scaled explanation.

If it helps, the periodic full plate-discovery sweep is the kind of work that scales with
what's on screen, and hooking each plate's `OnShow` once at discovery would let the reassert
cadence drop a long way — but that's your call and your codebase; I'm offering the
measurement, not prescribing the fix.

## Raw data

The full per-second table (framerate + per-addon CPU for all four watched addons, 130 rows)
is available as CSV, and the original record with its provenance header as JSON. Happy to
share either, re-run the capture under different conditions, or run a finer-grained
frame-time capture if that would be more useful than one-second sampling.
