# Frame cost — COA_GuardianPlates

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._
_Source fingerprint `e3804950121a` — run `py addons/tools/emit_addon_census.py --check` to find out if this has gone stale._

**Read the OnUpdate table first.** It is the only kind of entry that runs *every frame*; everything below it fires when something happens.

**Lifetime is arithmetic: `installs − clears`.** **transient** = every handler is torn down again, so it runs only while something is happening (a drag, a running session task). **PERSISTENT** = none are, so they run for as long as the addon is loaded — that is where a cost would live. **MIXED** = both in one file, which a boolean hid on the first pass.

**`throttle?` is a LEAD, not a verdict.** It reports whether the file contains an accumulator pattern at all. **`no` means go and look** — it does not mean the handler is unthrottled. The parent `README.md` records what the first run flagged and why every one of it was correct-by-design.

## ★ OnUpdate — runs every frame

| File | Installs | Clears | Lifetime | throttle? |
|---|---|---|---|---|
| `Core.lua` | 1 | 0 | **PERSISTENT** | yes |
| `FriendlyPlates.lua` | 1 | 0 | **PERSISTENT** | yes |

**2 handler(s) installed; 2 PERSISTENT.** The persistent ones are the whole point of this page.

## Timers

| File | Detail |
|---|---|
| `Core.lua` | C_Timer.After |

## Events we listen for

| File | Detail |
|---|---|
| `Core.lua` | GROUP_ROSTER_UPDATE, NAME_PLATE_UNIT_ADDED, NAME_PLATE_UNIT_REMOVED, PLAYER_ENTERING_WORLD, PLAYER_ROLES_ASSIGNED, ROLE_CHANGED_INFORM, UNIT_HEALTH, UNIT_MAXHEALTH, UNIT_THREAT_LIST_UPDATE, UNIT_THREAT_SITUATION_UPDATE |

## ★ Hooks — hooksecurefunc

_The highest-risk column: a hook runs inside someone else's flow._

| File | Detail |
|---|---|
| `Core.lua` | `frame`, `texture` |

## ★ Hooks — HookScript on frames we do not own

_Anyone else doing the same can clobber ours, and silently._

| File | Detail |
|---|---|
| — | — |
