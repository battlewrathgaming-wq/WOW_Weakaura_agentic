# Frame cost — COA_StatePlates_Enemy

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

**Read the OnUpdate table first.** It is the only kind of entry that runs *every frame*; everything below it fires when something happens.

**Lifetime is arithmetic: `installs − clears`.** **transient** = every handler is torn down again, so it runs only while something is happening (a drag, a running session task). **PERSISTENT** = none are, so they run for as long as the addon is loaded — that is where a cost would live. **MIXED** = both in one file, which a boolean hid on the first pass.

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
