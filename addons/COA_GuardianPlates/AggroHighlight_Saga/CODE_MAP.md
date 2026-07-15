# Native aggroHighlight - Code Map

Where everything from the saga actually lives in the addon's real source, so a future revisit doesn't need to re-read the whole changelog to find the functions. All line numbers as of v3.5.42.

## Core.lua - locate/color/suppress primitives

| Function | Line | Purpose |
|---|---|---|
| `ns.GetNativeAggroHighlightFrame(plate)` | 1142 | Locates the aggroHighlight FRAME (predictable name first, GetChildren() scan fallback) |
| `ns.GetNativeAggroHighlightTexture(plate)` | 1167 | Locates the aggroHighlight TEXTURE (builds on the frame lookup above) |
| `ns.SetNativeAggroHighlightColor(plate, color)` | 1245 | Installs a persistent per-texture re-assert hook (v3.5.40), sets desired color |
| `ns.ClearNativeAggroHighlightColor(plate)` | 1265 | Clears the desired-color record (hook stays installed but goes inert) |
| `ns.SuppressNativeAggroHighlight(plate)` | 1316 | v3.5.42 - persistent Hide() hook, same pattern as color hook |
| `ns.ClearNativeAggroHighlightSuppress(plate)` | 1334 | Clears the suppress flag (hook stays installed but goes inert) |
| `ns.WatchNativeAggroHighlight(plate)` | 1378 | v3.5.39 diagnostic - logs debugstack on Show/Hide/SetVertexColor |
| `ns.ForceShowNativeAggroHighlight(plate, color)` | 1409 | v3.5.20 diagnostic - forces Show()/SetAlpha(1) directly |
| `ns.ClearForcedNativeAggroHighlight(plate)` | 1432 | Undoes the force-show test |
| `ns.ScanGlobalsForPattern(substring)` | 1474 | v3.5.32 - lists global FUNCTIONS matching a substring |
| `ns.ScanGlobalTablesForPattern(substring)` | 1504 | v3.5.35 - lists global TABLES matching a substring |
| `ns.DumpFunctionUpvalues(fn)` | 1529 | v3.5.37 - dumps closure upvalues via debug.getupvalue (blocked on this client) |
| `ns.SetHandRolledGlow(plate, color)` | 1704 | The addon's OWN glow texture - production-primary signal, unrelated to native highlight but built as its replacement |
| `ns.ClearHandRolledGlow(plate)` | 1722 | Clears the hand-rolled glow |
| `ns.SetLogStoreFilter(needle)` | 2240 | v3.5.41 - store-time log filter |
| `ns.GetLogStoreFilter()` | 2244 | Reads current store filter |

## Core.lua - slash command dispatcher (`/coasp`)

| Command | Line | Purpose |
|---|---|---|
| `/coasp probe [unit]` | 2643 | Depth-limited recursive dump of every child frame/region under a nameplate |
| `/coasp scanglobals <substring>` | 2655 | Lists matching global functions |
| `/coasp aggrohooks` | 2670 | Reports which speculative candidate names exist as globals |
| `/coasp scantables <substring>` | 2676 | Lists matching global tables |
| `/coasp upvalues <funcname>` | 2692 | Dumps a function's closure upvalues |
| `/coasp watchaggro [unit]` | 2709 | Installs the Show/Hide/SetVertexColor debugstack watch |
| `/coasp suppressaggro on\|off [unit]` | 2730 | v3.5.42 - persistent Hide() test command |
| `/coasp log filter <substring>\|off\|status` | 2590 | v3.5.41 - store-time log filter subcommand |

## EnemyPlates.lua - render-test modules

| Module name | Line | Purpose |
|---|---|---|
| `"aggroBroadcast"` | 1324 | v3.5.20 - force-show + recolor across every active hostile plate at once |
| `"handRolledGlow"` | 1330 | v3.5.23 - isolated test of the addon's own glow texture |
| `"nativeAggroColor"` | 1342 | v3.5.31 - raw color-swatch test against SetNativeAggroHighlightColor, target only |

All three are run via `/coasp rendertest <module> <state>` or swept together via `/coasp rendertest cycle`.

## Live-test macros (bypass the addon entirely - no reload needed)

Built because Battlewrath's anti-cheat setup treats `/reload`-level code injection as a memory violation, so newly-written Core.lua code (v3.5.41/42) couldn't be loaded and tested mid-session. These use only Blizzard API already resident in the client (`C_NamePlate`, `hooksecurefunc`) - nothing addon-dependent, so they work immediately.

**Suppress ON** (target the mob first):
```
/run local p=C_NamePlate.GetNamePlateForUnit("target")local h=p.UnitFrame.healthBar local f=_G[h:GetName().."aggroHighlight"]if f then COAS=true hooksecurefunc(f,"Show",function(s)if COAS then s:Hide()end end)f:Hide()end
```

**Suppress OFF**:
```
/run COAS=false local p=C_NamePlate.GetNamePlateForUnit("target")local f=_G[p.UnitFrame.healthBar:GetName().."aggroHighlight"]if f then f:Show()end
```

Tested live once (see CHANGELOG.md's "Post-v3.5.42" entry): no visible effect. Caveat this macro doesn't share: it assumes `p.UnitFrame.healthBar` exists with no fallback to `p.healthBar` (the full addon primitive's `GetNativeAggroHighlightFrame` tries both) - worth checking if the macro's silent no-op was actually a missing-frame case rather than a suppress failure, next time this gets picked back up.
