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
/coadump sp                 stop the open session task (prints the summary)
/coadump list               installed tasks + help lines
/coadump clear              wipe the mailbox
```

One envelope at a time: a one-shot won't run while a session is open.

## Installed tasks

- **`probe <FrameName> [field1,field2,...]`** (one-shot) — recursive walk of
  any named frame in `_G`, reading plain Lua table fields off every widget
  (how CoA's custom frames stash data — this is what found
  `spellID`/`rank`/`maxRank` on the talent buttons). NOT for stock API-backed
  frames (e.g. `TotemFrame`): their data lives behind a function call, so a
  probe shows structure only.
- **`frames [field1,field2,...]`** (one-shot) — frame-stack snapshot under the
  mouse cursor (the `fstack` idea, recorded instead of displayed), reading the
  field list (default: core's DEFAULT_FIELDS) off every hit. Doubles as the
  ANONYMOUS-frame probe: this fork's nameplates have no GetName, but a cursor
  hit reads `unit`/`displayedUnit` straight off their UnitFrame children.
- **`census`** (one-shot, self-cycling) — the full `_G` walk: every global's
  kind + one-level `C_*` namespace expansion, paced at 400 keys/frame so the
  client never hitches. Live-proven 2026-07-15 (51,855 globals in one pass).
  Reduction vs the declared pass + baseline happens offline
  (`addons/tools/reduce_census.py` → `addons/maps/census/runtime/`).

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
