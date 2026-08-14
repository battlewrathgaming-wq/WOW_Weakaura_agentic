# COA_DevDump — the bench capture spine (v2)

The addons bench's in-game half: a **task runner** that writes one
self-describing envelope per run into the SavedVariables mailbox, which the
bench watcher (`addons/landing/pull.py`) lands in the repo as a
provenance-stamped record. Since neither macros nor `/devconsole` expose
file I/O, SavedVariables is the only channel from live client to disk —
COA_DevDump owns that channel for the whole bench.

**v1** (built 2026-07-04: the talent/trainer/spellbook campaign tool whose
captures fed `coa_spells.json`) is retired — deleted 2026-07-15, recoverable
from git history (`addons/COA_DevDump/COA_DevDump.lua` before that date).
Its proven patterns (recursive widget walker, pcall-everything discipline,
tooltip `GetSpell()` id-recovery, the accumulate-by-key trick) live on as
`core.lua`'s libraries. Its live-earned gotchas that still apply are kept at
the bottom of this file.

## The shape

- **`core.lua`** — the spine: envelope writer, task registry, walker /
  event-collector / cycler libraries, slash dispatcher. Stable; rarely edited.
- **`task_*.lua`** — one file per registered task. This is the part that
  changes per mission: the agent writes a task file, deploys, one client
  restart, and from then on the task is steered by arguments.
- **The mailbox rule:** `COA_DevDumpDB` holds ONE envelope — the latest run
  only; every run replaces it. History and cross-run merging live in the repo
  landing zone (`addons/landing/`), deduped on the header's `runId`.
- **Chat is by-exception:** one summary line per run, errors only otherwise.
  Session tasks collect silently while you play; the record is read offline.

## Driving it (the shorthand spine)

```
/coadump r  <task> [args]   run a one-shot task
/coadump st <task> [args]   start a session task (listeners collect while you play)
/coadump mark <text>        tell the OPEN session something (task decides what it means)
/coadump sp                 stop the open session task (prints the summary)
/coadump list               installed tasks + help lines
/coadump clear              wipe the mailbox
```

One envelope at a time: a one-shot won't run while a session is open.

## Installed tasks (refreshed 2026-07-31)

One-shots (`/coadump r <task>`):
- **★ `dump <expression>`** — **`/dump`, but it lands on DISK.** Same evaluation as the
  client's own (`ChatFrame.lua:2696` → `DevTools_DumpCommand` → `loadstring("return "..msg)`),
  so anything you would type into `/dump` goes in unchanged, function calls included. Built
  because the alternative was Battlewrath **hand-transcribing values off the screen** — slow,
  and it corrupts the one thing we were reading for. Serialises deeply with **no silent caps**:
  cycles, depth, width and non-string keys each leave a note in `payload.notes`, and functions
  /userdata are kept as type TAGS rather than dropped (a missing key implies the field was not
  there). A compile or runtime error lands **nothing** — a record of our own syntax error would
  read as evidence about the game.
- **`probe <FrameName> [fields]`** — recursive walk of any named frame in `_G`,
  reading plain Lua table fields off every widget (found `spellID`/`rank`/
  `maxRank` on the talent buttons). NOT for stock API-backed frames: their data
  lives behind function calls, so a probe shows structure only.
- **`frames [fields]`** — frame-stack snapshot under the mouse cursor (recorded
  fstack). Doubles as the ANONYMOUS-frame probe: this fork's nameplates have no
  GetName, but a cursor hit reads `unit`/`displayedUnit` off their children.
- **`census`** — the full `_G` walk (51,855 globals, paced 400 keys/frame).
  Offline reduction: `addons/tools/reduce_census.py`.
- **`macros`** — the macro-conditional probe (backlog #4 payload).
- **`talents`** — talent/spellbook capture v2 w/ rank arrays (fed the
  Class_design walk-vs-decode diff; capture loop handover:
  `Class_design/tools/CAPTURE.md`).
- **`spec`** — the spec-index capture (load.specialization support).
- **`tooltip`** — tooltip-id harvest (payload_tooltipids).

Session tasks (`/coadump st <task>` ... `sp`):
- **`plates`** — nameplate window capture (the SignalFire arc's evidence tool).
- **`perf [Addon1,Addon2] [secs]`** — fps/cpu/mem/chat-rate sampler; per-addon
  CPU needs `/console scriptProfile 1` + reload (stamped in the envelope; turn
  it off after). Attributed the Mancer hitching 2026-07-31 (24ms/s steady,
  48-108ms spikes, 8-for-8 trough alignment).
- **`petlog`** — the pet-parser capture gate: SPELL_SUMMON registry + raw CLEU
  (first-20-args, canon/varargs mode-stamped) + plate-window pet/owner stat
  pairs + player-aura sweep. Its one record (20260731_104452) settled the
  petlog v0 checklist AND disproved the canonical-CLEU assumption.
- **`cvarlog`** — the nameplate-CVar flight recorder: baseline + change rows
  (t/key/from/to) + Mancer backup-table snapshots per flip. Diagnosed the
  capital-city plate mute in one session.

- **★ `cleu`** — **what a CLEU listener actually COSTS here.** Three arms switched
  in-session so client state does not differ between them: `none` (unregistered — the
  baseline), `count` (the cost of being CALLED), `masked` (subevent compare + hostile-flag
  test — the realistic shape). **It measures ALLOCATION, not time**, because ALC's profiling
  on this fork found GC pressure rather than call count, and because timing a handler that
  does almost nothing measures mostly the timer. **And it invalidates its own comparison**
  — unequal pull counts across arms mean it was not the same errand, and it says so in the
  summary line rather than leaving a figure to be trusted. `st cleu`, `mark count`,
  `mark masked`, `sp`. Study: `addons/planning/cleu_on_this_fork.md`.

- **★★ `api`** — **the bench checking its own model of the client.** `harness.lua` teaches the
  offline stubs to behave like the client (`SetText` fires `OnTextChanged`, `Show`/`Hide` fire on
  transitions, `SetTexture` resets `TexCoord`) — and ⚠ **every one of those claims was reasoned,
  never measured**, so the whole test suite has been green against a model nobody checked. This runs
  each as a scripted experiment in the live client and reports `claim` vs `observed` vs `agrees`,
  alongside a matrix of the read-only API against `nil`, wrong types and out-of-range inputs —
  answering *"does this return nil or throw?"*, which guard clauses have been guessing at.
  ★ **A disagreement is worth more than a clean sheet.** ⚠ **READ-ONLY, as a hard line**: nothing on
  the census's PUSH list is touched, because a diagnostic that changes the machine it is diagnosing
  is not a diagnostic. `r api`. Run card: `addons/planning/api_probe_runsheet.md`.

The task shelf is the point: each investigation leaves its instrument behind.

**`mark` exists because a session that can only be started and stopped cannot be TOLD
anything.** Core owns the verb, the task owns the meaning — `cleu` reads it as an arm name.
The gap predates it: `satnav`'s whole design is "do manoeuvre A, then B, then C, in any
order" with no way to record which was which.

## The loop (repo → client → repo)

1. Edit here (repo = source of truth; never hand-edit the game copy).
2. `py addons\deploy.py COA_DevDump` — byte-copy to the client
   (game **closed**: new/edited addon files need a full client restart on
   this account — anti-cheat; `/reload` cannot load new code).
3. In-game: run the task (`/coadump r probe CoATalentFrame`), then `/reload`
   to flush the mailbox to
   `WTF/Account/BATTLEWRATH/SavedVariables/COA_DevDump.lua`.
4. The watcher (`addons/landing/pull.py watch`, hosted by `addons/menu.bat`)
   sees the flush and lands the record in `addons/landing/`.

## Live-earned gotchas that still apply (from the v1 campaigns)

1. **Pooled-widget UIs only instantiate the visible tab.** `GetChildren()`
   on the talent tree view only returns nodes for the tab on screen — one
   probe per tab, by design.
2. **Header rows in list UIs can carry uninitialized reads** (a trainer
   header row once reported `cost = 1816288370`). Filter by row type, don't
   interpret the number.
3. **Always `/reload` before closing the client** so a capture is flushed
   regardless of what happens at quit (one crash-at-quit was observed; timing
   cleared the addon, but the rule is cheap).
4. **The SavedVariables file gets big fast.** Read it tooling-side with
   targeted offsets (the puller does this), not as one gulp.
