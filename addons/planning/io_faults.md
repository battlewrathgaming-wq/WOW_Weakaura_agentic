# `OSError: [Errno 22] Invalid argument` — four incidents, two captured

_The raw stream lives in `addons/staging/io_faults.jsonl`, which is gitignored and
transient. **This is the promoted record**: what happened, and what each one narrowed._

★★★ **Capture over retry** is his ruling, and this page is the reason it was right. A
retry would have made all four invisible, and the interesting thing about them is the
**pattern**, which exists only because they were recorded rather than absorbed.

## What happened

| # | when | op | file | tool | what it cost |
|---|---|---|---|---|---|
| 1 | earlier (pre-capture) | read | a repo file | scratchpad work | recorded only in `mutate.py`'s docstring |
| 2 | 2026-08-15, §85 | read | `map.lua` + `task_cleu.lua` | `mutate.py` | ⚠⚠ **two mutants left in the tree** — the read was outside the `try`, so the restoring `finally` never ran |
| 3 | 2026-08-15 14:46 | **write** | `walk.lua` | `mutate.py` | nothing. The `finally` restored, the re-run was clean |
| 4 | 2026-08-15 16:34 | **write** | `routes.lua` | `mutate.py` | nothing. Same — tree clean, 272/272 on re-run |

**The two captured, side by side:**

```json
{"at":"…14:46:24","op":"write","path":"COA_DungeonRun\\walk.lua",
 "errno":22,"bytes":15613,"exists":true,"size":15612,"tool":"mutate.py"}
{"at":"…16:34:55","op":"write","path":"COA_DungeonRun\\routes.lua",
 "errno":22,"bytes":51804,"exists":true,"size":51771,"tool":"mutate.py"}
```

## What two captures narrow that one could not

★★ **Both are WRITES, and both are the APPLY rather than the restore.** In each, the
bytes attempted exceed the size on disk — 15,613 over 15,612, and 51,804 over 51,771
— which is the mutant (longer) going over the original (shorter). So the fault lands
while *applying* a mutation, moments after that same file was read.

★★ **It is not size-dependent.** 15 KB and 51 KB, three and a half times apart.

★ **Same tool, four for four.** `mutate.py` is the heaviest writer on the bench by a
wide margin — read a file, write a mutant, run a suite, write it back, dozens of
times per run. If frequency is the variable, it is the instrument that would find the
limit, and it is the only one that has.

## The fourth-incident diagnostic — run, and inconclusive BY DESIGN

The standing plan said a fourth incident triggers a Defender-log comparison rather
than more hardening. Run:

- **Defender is active and healthy.** Events 1150/1151 at 16:35:00, five seconds
  after the fault — but those are periodic *health reports*, not scans.
- ⚠⚠ **Real-time protection does not log individual file scans.** Only detections and
  status reach the Operational log. So **absence of an event is not absence of a
  scan**, and this instrument cannot separate the two hypotheses. The plan was sound
  and the tool cannot answer it.

**Disk health, since it speaks to the other hypothesis:**

```
CT1000MX500SSD1              SSD  Healthy  OK
SAMSUNG MZVLW128HEGR-00000   SSD  Healthy  OK
SanDisk Ultra II 480GB       SSD  Healthy  OK
F: NTFS  health=Healthy  free=99.4GB of 446.6GB
```

★ All SSDs report healthy, and F: has plenty of room. That **weakens** a failing-media
story without eliminating it — a healthy SMART reading and a transient write refusal
are not mutually exclusive.

## Where it stands

**Still not separated:** a scanner holding a just-written file, and OS/filesystem
pacing under rapid rewrite, predict exactly the same shape. Everything measured so far
is consistent with both.

⚠ **The one experiment that would separate them is an exclusion test** — take the repo
folder out of real-time scanning and see whether the faults stop. That changes the
machine's security posture, so it is **his call and not mine**, and it is recorded here
as the option rather than done.

**The standing position is unchanged and has now been validated twice:**

- **Do not retry.** A recovery would restore the frequency data to zero.
- **The tooling survives it.** `mutate.py`'s read moved inside the `try` after
  incident 2; incidents 3 and 4 both left the tree clean without anyone noticing at
  the time.
- ★ **The next thing to learn is a rate, not another anecdote.** Four incidents in one
  long session is the only number we have; whether that is one-per-heavy-run or
  one-per-thousand-writes is what would actually distinguish pacing from bad luck, and
  the log now accumulates toward it on its own.
