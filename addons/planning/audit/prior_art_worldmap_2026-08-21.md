# PRIOR ART — the client's own map-with-bolted-on-panel (WorldMapFrame, 3.3.5 fork FrameXML)

_Design architect, 2026-08-21, at Battlewrath's pointer: "the default game has a version of this — the
map vs the map with quests on display." Read-only measurement by an `Explore` agent against the FORK's
shipping FrameXML — `Outputs/client_interface/patch-B/` (extracted 2026-08-01 from
`Data/patch-B.MPQ`, manifest sha recorded). Nothing was extracted anew; every line is the fork's.
**This file rules nothing.** The transfer table at the foot is the deliverable._

## a · STRUCTURE — one frame, three coexisting layouts
- `WorldMapFrame` is screen-filling (`WorldMapFrame.xml:5`), a UI panel with `area = "full"` (`UIParent.lua:36`).
- **The invisible ruler:** `WorldMapPositioningGuide` (`WorldMapFrame.xml:281-292`), an empty 1024×768 frame
  anchored CENTER — every piece of full-screen chrome anchors to it (close `:485`, size-down `:497`, the
  objectives checkbox `:1472`, the map). Layout is resolution-independent because nothing anchors to the screen.
- **Map surface:** `WorldMapDetailFrame` 1002×668 (`:528-538`) anchored to the guide; hit layer `WorldMapButton` (`:696`).
- **The bolted-on panel:** `WorldMapQuestScrollFrame` 283×670 anchored `TOPLEFT → WorldMapDetailFrame TOPRIGHT +(6,0)`
  (`:1213-1222`) — **fixed width, a 6 px gutter baked into the anchor, never re-anchored.** The map moves; the
  panel follows. Detail/reward scroll frames hang below the map, chained off each other (`:1267-1344`).
- Chrome in XML: two size buttons stacked at one point, one hidden, both calling ONE handler (`:492-527`);
  the objectives checkbox (`:1466-1496`); a 544×22 drag strip (`:1525-1542`); `WorldMapScreenAnchor`, a
  1×1 movable proxy that remembers where the small map was dragged (`:1519-1524`).
- Created in Lua: the quest rows, pooled by name up to 32 (`WorldMapFrame.lua:2100-2117`); **index 0 is an
  off-screen MEASURING frame** whose font metrics are cached to count wrapped lines (`:223-226`, `:1922-1927`).

## b · THE TOGGLE — one number, derived from content
- The one runtime variable: `WORLDMAP_SETTINGS.size` (`WorldMapFrame.lua:62-69`), three values (`:17-19`):
  `0.573` windowed / `0.691` fullscreen + panel / `1.0` fullscreen, no panel. **The size number is the mode
  enum AND the `SetScale` argument** (`:1810`) — "which mode" and "how big" are one fact and cannot drift.
- The CVar `questPOI` gates whether quests are considered at all (`:331-332`, `.xml:1480`, `:1843-1845`).
- **Panel presence is DERIVED FROM CONTENT**, not a preference: `WorldMapFrame_DisplayQuests` (`:1749-1791`) —
  quests in this zone → grow the panel in (`SetQuestMapView`, `:1765-1767`); none → collapse it out
  (`SetFullMapView`, `:1784-1786`). Re-run on `QUEST_LOG_UPDATE` / `QUEST_POI_UPDATE` (`:342-344`); a
  reconciliation pass on `OnShow` (`:249-255`).
- ⚠ **There is no single "show the panel" function** — four functions each set the size AND hand-list
  ~30 `Show()`/`Hide()` calls (`:1614-1665`, `:1667-1718`, `:1808-1820`, `:1822-1835`). Every widget must be
  remembered in four places. (The anti-pattern; see transfer table.)

## c · THE SIZE MODES AND DOCK/UNDOCK
- `WorldMapFrame_ToggleWindowSize` (`:1581-1612`): capture the map identity → **close the frame first** so the
  panel manager re-runs → flip the CVar and transition → set `blockWorldMapUpdate` → reopen → restore →
  clear. The guard flag suppresses the update storm (`:317`).
- SizeUp (`:1614-1665`): `SetParent(nil)`, `SetAllPoints`, four frames scaled in lockstep (`:1628-1632`), the
  guide re-anchored, chrome re-anchored to the guide. SizeDown (`:1667-1718`): the mirror; the quest panel
  is simply HIDDEN (`:1690-1692`) — never reparented, its anchor stays valid.
- **Persistence is asymmetric on purpose:** only the mini/full axis is saved (`SetCVar("miniWorldMap")`,
  `:1593/:1596`, read `:326-330`); the panel axis is re-derived every open.
- **Dock/undock is a separate axis** (`WorldMapFrame_SetMiniMode`, `:2374-2403`, CVar `advancedWorldMap`):
  undocked = UIPanel area `"center"`, movable, anchored to the 1×1 `WorldMapScreenAnchor` proxy (`:2386`);
  docked = area `"doublewide"`, not movable, panel-managed (`:2391-2400`). Drag stop walks the proxy to the
  new position (`:2450-2452`) so placement survives reparenting.
- **The art trick:** the two modes' chrome differs by SIX textures (`WorldMapFrameTexture13..18`,
  `.xml:196-268`) shown in one mode and hidden in the other (`:1817-1819` / `:1832-1834`) — not a rebuild.

## d · THE PANEL ITSELF
- Rebuilt wholesale on every event (`WorldMapFrame_UpdateQuests`, `:1848-1983`): rows pooled and over-allocated
  once, hidden thereafter; **chain-anchored** (first to the child frame, each to the previous `BOTTOMLEFT`,
  `:1885-1889`); **variable height** `SetHeight(max(measured, MIN))` (`:1947`).
- Selection is an ID re-resolved by scan after a rebuild (`:1793-1806`), never a frame reference; ONE shared
  moving highlight frame re-pointed and resized onto the active row (`:2012-2014`).
- No collapse affordance; the checkbox is global. The width 283 is a hard constant in three places.
- ⚠ `QuestLogFrameShowMapButton`'s visibility is owned by TWO files (`WorldMapFrame.lua:1733-1737`,
  `QuestLogFrame.lua:344-346`) and it is reparented between frames (`:951`). Two owners, one widget.

## e · WHAT TRANSFERS

| client idiom | file:line | maps to ours |
|---|---|---|
| an invisible RULER frame all chrome anchors to | `.xml:281-292` | **take**: one ruler per size mode; layout stops caring about resolution (ours anchors to `UIParent` today — `map.lua:1894`, `:2187`) |
| the panel bolted to the map's edge by ONE anchor set at creation, never re-anchored; hide ≠ re-anchor | `.xml:1213-1222`; `:1690-1692` | **take**: the bolt-on is an anchor, not a layout; dock state only shows/hides |
| one number = mode enum = scale argument | `:17-19`, `:62-69`, `:1810` | **take**: two sizes are two scale constants; mode and size cannot drift |
| panel presence DERIVED from content, persisted only on the axis the user chose | `:1749-1791`; `:1593/:326` | **take**: our derived visibility (A10.9); persist dock state per group (account-wide), never "is the panel visible" |
| close → mutate → reopen with a re-entrancy guard | `:1589-1611`, `:317` | take if a panel manager is used; the guard is the load-bearing half |
| position lives in a 1×1 PROXY frame; the real frame reparents freely | `.xml:1519-1524`; `:2386`, `:2450-2452` | **take** for undocked windows: the per-group position is a proxy, not a saved anchor on the frame |
| chain-anchored variable-height rows; a hidden ruler row to measure text | `:1885-1889`, `:1947`, `:223-226` | take for variable tab content; the only way to count wrapped lines on 3.3.5 |
| selection as an ID re-resolved after a rebuild; one shared highlight | `:1793-1806`, `:2012-2014` | **take**: never hold a frame reference across a rebuild (our address does this by nature) |
| two modes differ by a texture SET, not a rebuild | `.xml:196-268`, `:1817-1819` | take the principle: the collapsed strip is the panel's own textures in a second arrangement — one language |
| ANTI: ~30 hand-listed Show/Hide per transition, ×4 functions | `:1635-1648`, `:1683-1700`, `:1814-1833` | **do not take** — this is exactly what "every visibility is derived from one state" replaces: one `ApplyMode` over a declarative per-mode table |
| ANTI: one widget's visibility owned by two files, reparented between them | `WorldMapFrame.lua:1733`, `QuestLogFrame.lua:344`, `:951` | **do not take** — single owner per widget |

**Fork deltas, UNVERIFIED against stock:** a zone-story header inside the same panel that shifts the first row
down 50 px when shown (`.xml:1000-1052`, `.lua:1778-1782`, `:1888`) — a real precedent for a second content
block (our tab strip) sharing the panel; filter button/dropdown (`.xml:900-987`); abandon/share in the reward
frame; POI pools and `C_*` helpers. Everything in the table above matches stock naming and structure.
