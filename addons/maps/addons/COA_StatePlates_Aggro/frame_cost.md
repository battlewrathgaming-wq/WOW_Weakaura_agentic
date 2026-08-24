# Frame cost — COA_StatePlates_Aggro

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._
_Source fingerprint `2af42707fc0f` — run `py addons/tools/emit_addon_census.py --check` to find out if this has gone stale._

**Read the OnUpdate table first.** It is the only kind of entry that runs *every frame*; everything below it fires when something happens.

**Lifetime is arithmetic: `installs − clears`.** **transient** = every handler is torn down again, so it runs only while something is happening (a drag, a running session task). **PERSISTENT** = none are, so they run for as long as the addon is loaded — that is where a cost would live. **MIXED** = both in one file, which a boolean hid on the first pass.

**★ `hot?` marks a COMBAT-FREQUENCY event.** Only events we have MEASURED go on that list - currently the two combat-log events, at 57-82 lines/second in a dungeon here (`addons/planning/cleu_on_this_fork.md`). It is where to look first when something is blamed on cost, and it is deliberately NOT a list of events someone guessed were expensive.

**`throttle?` is a LEAD, not a verdict.** It reports whether the file contains an accumulator pattern at all. **`no` means go and look** — it does not mean the handler is unthrottled. The parent `README.md` records what the first run flagged and why every one of it was correct-by-design.

## ★ OnUpdate — runs every frame

| File | Installs | Clears | Lifetime | throttle? |
|---|---|---|---|---|
| — | — | — | — | — |

**0 handler(s) installed; 0 PERSISTENT.** The persistent ones are the whole point of this page.

## Timers

| File | Detail |
|---|---|
| — | — |

## ★ HOT events — combat frequency

_The first place to look when anything is blamed on cost. Measured at 57-82 lines/second in a dungeon on this fork — `addons/planning/cleu_on_this_fork.md`. Whatever ships must be no heavier than the handler that number was measured on._

| File | Detail |
|---|---|
| — | — |

## Events we listen for

| File | Detail |
|---|---|
| `Options.lua` | ADDON_LOADED |

## ★ Hooks — hooksecurefunc

_The highest-risk column: a hook runs inside someone else's flow._

| File | Detail |
|---|---|
| — | — |

## ★ Hooks — HookScript on frames we do not own

_Anyone else doing the same can clobber ours, and silently._

| File | Detail |
|---|---|
| — | — |
