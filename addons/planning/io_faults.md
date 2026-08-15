# `OSError: [Errno 22] Invalid argument` — three incidents

_The raw stream lives in `addons/staging/io_faults.jsonl`, which is gitignored and
transient. **This is the promoted record**: what happened, and what each one narrowed._

★★★ **Capture over retry** is his ruling, and this page is the reason it was right. A
retry would have made all three invisible, and the interesting thing about them is
the **pattern**, which only exists because they were recorded rather than absorbed.

## What happened

| # | when | op | file | tool | what it cost |
|---|---|---|---|---|---|
| 1 | earlier (pre-capture) | read | a repo file | scratchpad work | recorded only in `mutate.py`'s docstring |
| 2 | 2026-08-15, §85 | read | `map.lua` + `task_cleu.lua` | `mutate.py` | ⚠⚠ **two mutants left in the tree** — the read was outside the `try`, so the restoring `finally` never ran |
| 3 | 2026-08-15 14:46 | **write** | `walk.lua` | `mutate.py` | nothing. The `finally` restored, the re-run was clean |

**Incident 3, as captured:**

```json
{"at": "2026-08-15T14:46:24", "op": "write", "path": "COA_DungeonRun\\walk.lua",
 "errno": 22, "winerror": null, "strerror": "Invalid argument",
 "bytes": 15613, "exists": true, "size": 15612, "tool": "mutate.py"}
```

## What it narrows

★★ **The tool is the same all three times.** `mutate.py` is by far the heaviest writer
on this bench — it rewrites one file, runs a suite, rewrites it back, dozens of times
in a row. If frequency of access is the variable, it is the instrument most likely to
find the limit, and it did.

★★ **The third is a WRITE, where the first two were reads.** So it is not a read-side
problem, and it is not the file being locked *by* something else in the obvious way —
the same process had just written that file successfully many times.

★ **The sizes are one byte apart** — 15,613 attempted against 15,612 on disk. That is
exactly the mutant-versus-original difference for the edit in flight, so the fault
landed between two writes of nearly identical size rather than on anything unusual
about the content.

⚠ **What it does NOT establish.** Nothing here distinguishes his pacing hypothesis
(*"a pacing issue in the OS runtime / write-read speeds"*) from a scanner holding the
file for a moment after a write. Both predict exactly this shape. Separating them
needs a timestamp compared against Defender's own log, which is a step worth taking
only if there is a fourth.

## The standing position

- **Do not retry.** A recovery would restore the frequency data to zero.
- **The tooling survives it.** `mutate.py`'s read moved inside the `try` after
  incident 2, and incident 3 proved that: the tree came back clean without anyone
  noticing at the time.
- ★ **A fourth incident is the trigger** for the Defender-log comparison, not another
  round of hardening.
