# Audit — TomTom (r240-release, Ascension-patched) as a POSITIONAL SEQUENCER (2026-08-17)

_Independent audit, from files only. Target: `F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns\TomTom`
(TOC `## Interface: 30300`, `## X-Curse-Packaged-Version: r240-release`, `## SavedVariables: TomTomDB, TomTomWaypoints` — `TomTom.toc:1,9,10`).
Files loaded (`TomTom.toc:19-30`): 5 localization files, `TomTom.lua`, `TomTom_Waypoints.lua`, `TomTom_CrazyArrow.lua`,
`TomTom_Corpse.lua`, `TomTom_POIIntegration.lua`, `TomTom_Config.lua`. `Babelfish.lua` and `Changelog-TomTom-r240-release.txt`
are in the folder but not in the TOC. Lua 5.1, no threads (Astrolabe uses coroutines). Cites are `File.lua:line` relative to the
TomTom folder unless prefixed. Quotes are short phrases. No recommendations except the two closing sub-lists per section._

Abbreviations: **T** = `TomTom.lua` · **W** = `TomTom_Waypoints.lua` · **CA** = `TomTom_CrazyArrow.lua` · **POI** = `TomTom_POIIntegration.lua` ·
**CO** = `TomTom_Corpse.lua` · **CFG** = `TomTom_Config.lua` · **A** = the client-shipped `Astrolabe-0.4/Astrolabe.lua`.

**Headline, stated up front:** TomTom carries **no position or distance math of its own.** Every position, distance and bearing
comes from `DongleStub("Astrolabe-0.4")` (`T:7`, `W:12`, `CA:9`), and **no Astrolabe file exists anywhere under `Interface\AddOns`**
(swept: no `Astrolabe*` file, no `DongleStub =` definition, no `Libs` folder in TomTom, no `## OptionalDeps` in the TOC). The library
the addon runs on is the one **the client itself ships inside `Data\patch-B.MPQ` at `Interface\LibraryXML\Astrolabe-0.4\`**
(study copy: `Outputs\client_interface\patch-B\Interface\LibraryXML\Astrolabe-0.4\Astrolabe.lua`, 975 lines; `DongleStub` lives in
the client's `FrameXML\LibStub.lua:88-235`, registration is the Ascension-only `DongleStub:RegisterAscension(Astrolabe, activate)` `A:947`).
That Astrolabe is **not** the 2009 upstream: its distance engine is `C_WorldMap.GetWorldPosition` (`A:154-155`) and it has **no
`WorldMapSize` yards-per-zone table at all** (declared `A:53 local WorldMapSize, MinimapSize, ValidMinimapShapes;` — only
`ValidMinimapShapes` is ever assigned, `A:956`). So the "TomTom" behaviour audited here is TomTom's *sequencing* layered on the
*client's* positional engine. Where a finding is Astrolabe's, the cite says `A:`.

Evidence that this TomTom was hand-patched for Ascension (not stock r240): `W:85 --local cring = MiniMapCompassRing:GetFacing()`
commented out with `W:86 local cring = GetPlayerFacing()` beneath it (same at `W:367-368`); `T:897 return C_WorldMap.GetMapFileByAreaID(Z)`;
`GetCurrentMapAreaID()` used throughout in place of a zone index (`T:209,733,1095,1150`, `POI:40`, `CO:41,112`);
`T:1048 print(msg)` debug print left inside the `/way` handler.

---

## 1. POSITION SOURCE

**API.** The player position is `GetPlayerMapPosition("player")` — inside `Astrolabe:GetCurrentPlayerPosition()` (`A:228-254`),
which TomTom calls at `T:187, 937, 958, 980, 1003, 1038`. TomTom itself calls `GetPlayerMapPosition("player")` directly once,
in the corpse module on death (`CO:114 x,y = GetPlayerMapPosition("player")`, guarded by `CO:113 if not IsInInstance()`).
No `UnitPosition`. No `C_Player`/`C_Map` position call. `GetPlayerFacing()` is used for heading only (§5).

**Coordinate space.** Map fraction 0..1 on the currently *selected* world map. TomTom's public surface multiplies by 100
(`T:228 x*100, y*100`, `T:983`, `T:1039`) and `AddZWaypoint` divides back (`T:789 self:GetCoord(x / 100, y / 100)`,
`T:807 self:SetWaypoint(c,z,x/100,y/100, ...)`). Internally a waypoint is `(c, z, x, y)` with `x,y` fractions (`W:161-164`).
Zone key `z` is **`GetCurrentMapAreaID()`** (an areaID, not a zone index) — `T:733`, `T:1095`. Continent `c` is
`GetCurrentMapContinent()`.

**Conversion to world yards** is done by the client, not the addon: `A:154 local worldX1, worldY1 = C_WorldMap.GetWorldPosition(z1, x1, y1)`
takes (areaID, fx, fy) → world coordinates; `A:172-185 TranslateWorldMapPosition` goes back via
`C_WorldMap.GetMapPosition(C_WorldMap.GetMapIDByAreaID(Z), worldX, worldY, 0)`. TomTom's own `GetMapFile(C, Z)` (`T:892-899`) maps
`(c, areaID)` → map-file name through `C_WorldMap.GetMapFileByAreaID(Z)` (`T:897`), falling back to a hard-coded
`continentMapFile` table for `Z == 0` (`T:869-875`: `Cosmic/World/Kalimdor/Azeroth/Expansion01` — **no Northrend entry**, i.e.
`c=4` at continent zoom returns nil).

**"No data" cases.**
- `GetCurrentPlayerPosition` treats `x <= 0 and y <= 0` as "no position", then tries `SetMapToCurrentZone()` and the continent map
  before giving up: `A:242-244 -- we are in an instance or otherwise off the continent map ... return;`. If a world map is open
  (`A:231 self.WorldMapVisible`) it returns nil rather than flip the map. Map zoom is restored (`A:248-250`).
- Instances: TomTom **hides** rather than computes. `W:340 if not dist or IsInInstance() then self:Hide() return end` (minimap icon)
  and `CA:116 if not dist or IsInInstance() then ... self:Hide() return end` (arrow). Comment `CA:114-115`: "The only time we cannot
  calculate the distance is when the waypoint is on another continent, or we are in an instance". Corpse search is skipped in
  instances (`CO:63 if not IsInInstance()`).
- Continent/zone validity: `T:736 if not c or not z or c < 1 then ... return end` (AddWaypoint), `T:792 if not zone then return end`
  (AddZWaypoint). `AddWaypoint` briefly flips the map (`T:732 SetMapToCurrentZone()` … `T:734 SetMapZoom(_c, _z)`) to read the
  player's real `(c, areaID)`.
- Astrolabe's own `ComputeDistance` returns nil if `GetWorldPosition` returns nil for either end (`A:157-159`) **and also** if the
  two points share an exact world X or world Y (`A:165-167 if xDelta == 0 or yDelta == 0 then return nil, nil, nil end`) — an
  Ascension-fork quirk; a waypoint due north/east of the player has "no distance".

REUSABLE MECHANISM
- `(areaID, fx, fy)` as the stored waypoint tuple + `C_WorldMap.GetWorldPosition(areaID, fx, fy)` for yards — the client does the calibration; nothing to ship (`A:154`, `T:733`).
- The "flip map, read, restore" idiom for getting `(c, areaID)` without leaving the user's map where you found it (`T:731-734`, `A:236-250`), and the `WorldMapVisible` guard that refuses to flip while the map is open (`A:231-235`).
- Treating `x<=0 and y<=0` as the no-position sentinel (`A:230`).

POSTURE NOT TO INHERIT
- "Hide in instances" (`W:340`, `CA:116`) — TomTom is an outdoor product; the position pipe is dead indoors by design, not by API limit (the repo's own probe F8 has `GetPlayerMapPosition` returning real fractions in Ragefire).
- Map-file names as the zone key (`T:790`) — a display-string index over an areaID that is already numeric.
- The nil-on-axis-alignment quirk (`A:165`) — do not copy `xDelta == 0 or yDelta == 0 → nil`.
- Hard-coded continent table lacking Northrend (`T:869-875`).

---

## 2. DISTANCE

**Formula.** 2D Euclidean in world yards, computed by Astrolabe: `A:161 local dist = sqrt((worldX2 - worldX1)^2 + (worldY2 - worldY1)^2)`
with `xDelta, yDelta` returned alongside (`A:162-169`). **No Z / no 3D.** No elevation term anywhere in TomTom or this Astrolabe.

**Who computes, when.** TomTom never calls `ComputeDistance` itself. It reads a cached number: `W:266-269 TomTom:GetDistanceToWaypoint(uid)`
→ `Astrolabe:GetDistanceToIcon(point.minimap)` → `A:697-702 return data.dist, data.xDist, data.yDist` — the value Astrolabe's
minimap-icon engine last wrote for that icon. That engine (`A:469-573` incremental, `A:597-669` full) runs from a processing frame's
OnUpdate (`A:823-833`) and, on the incremental path, **does not re-query the world**: it subtracts the player's delta since the last
tick from each icon's stored offset — `A:528-530 xDist = data.xDist - xDelta … dist = sqrt(xDist*xDist + yDist*yDist)`. A full
recompute against `GetWorldPosition` happens on zoom change / zone change / new icon (`A:626`, `A:798`, `A:813`, `A:850`).
Consequence: **distance exists only while the waypoint has a live minimap icon** — `RemoveIconFromMinimap` deletes it (`A:427-430`),
and Astrolabe itself removes icons whose distance goes nil on a full update (`A:633-635`) or all icons if the player's own delta is
nil (`A:554-560 self:RemoveAllMinimapIcons()`).

**Calibration table.** None shipped. Upstream Astrolabe's `WorldMapSize` yards-per-zone table is absent from this fork (`A:53`
declares it; nothing populates it; grep of the file for `WorldMapSize` finds only that line). Minimap radius in yards comes from an
Ascension widget method, `A:297 local mapRadius = minimap:GetViewRadius()` (also used by the client's own `FrameXML\Minimap.lua:668`).
The `MinimapSize` table is likewise declared and never defined. So the answer to "where does the per-zone constants table come from"
is: **from the client, at call time, via `C_WorldMap.GetWorldPosition`; there is no table.**

**Throttling of the distance read** is done by the consumers (§3, §5). `T:11 Astrolabe.MinimapUpdateTime = 0.1` is a **no-op** on
this fork — no such field is read anywhere in `Astrolabe.lua` (grep returns nothing); the engine budgets by
`A:489 numPerCycle = min(50, GetFramerate() * (self.MinimapUpdateMultiplier or 1))` icons per frame instead.

REUSABLE MECHANISM
- 2D yards via `GetWorldPosition` on both ends then `sqrt(dx²+dy²)` (`A:154-161`) — one line, no calibration.
- Delta-accumulation of many icon offsets from a single player delta (`A:520-535`) if you ever carry many markers.

POSTURE NOT TO INHERIT
- Distance-as-a-side-effect-of-a-minimap-icon (`W:268` → `A:698`): the number dies with the icon and is only as fresh as the icon engine's last tick.
- Ignoring Z: a dungeon driver reads across ramps/levels; this pipe cannot see them.
- Setting `Astrolabe.MinimapUpdateTime` (`T:11`) — a knob that does not exist here.

---

## 3. ARRIVAL

**Two radii, both in the profile, both applied per waypoint at creation:**
- `persistence.cleardistance` — default **10** yards (`T:114`), config `min = 0, max = 150, step = 1` (`CFG:610`), `0` disables
  auto-clear (`CFG:609` "A setting of 0 turns off the auto-clearing feature … only takes effect after reloading").
- `arrow.arrival` — default **15** yards (`T:80`), config `min = 0, max = 150, step = 5` (`CFG:219`), described as the distance at
  which "the waypoint arrow switches to a downwards arrow" (`CFG:218`).

**How they bind.** `AddZWaypoint` builds a `callbacks.distance[yards] = fn` map: `T:765-780` — if the two radii coincide one
function does both; else `callbacks.distance[cleardistance] = _both_clear_distance` and `callbacks.distance[arrivaldistance] = _both_ping_arrival`.
`SetWaypoint` sorts the keys into `point.dlist` (`W:172-180`).

**The decision.** In `Minimap_OnUpdate` (`W:336-431`), throttled to 0.1 s (`W:345-350`), read `dist` and classify it into a ring
index: smallest `i` with `dist <= list[i]`, else `-1` (`W:389-411`). A callback fires **only on a ring-index transition**
(`W:417 if state ~= newstate then`), and the callback fired is the one keyed to the **new** ring's radius (`W:420-423
local distance = list[newstate]; local callback = callbacks.distance[distance]; if callback then callback("distance", data.uid, distance, dist, data.lastdist)`).
Properties that follow directly from that code:
- **No hold, no debounce, no hysteresis** — the 0.1 s throttle is the only rate limit; one sample `<= r` fires.
- **First sample fires too**: on the very first update `state` is computed and `newstate` is nil, so `state ~= newstate` is true and
  `newstate = newstate or state` (`W:419`) → a waypoint created inside a ring fires that ring's callback immediately (this is why a
  `/way` at your own feet clears itself).
- **Moving outward from ring 1 into ring 2 fires ring 2's callback** (the "new" ring is 2) — with defaults, walking out of 10 yd
  into 15 yd re-pings; leaving 15 yd entirely (`-1`) fires nothing (`list[-1]` is nil).
- The `IsInInstance()` hide at `W:340` sits **above** this block: inside a dungeon the icon frame is hidden, its OnUpdate stops, and
  **no arrival/clear ever fires**. Also `W:334 local minimap_count = 0` is one counter shared by every icon frame — with N icons the
  throttle window is crossed by whichever frame's OnUpdate happens to tick over it, not by each icon.

**What happens on arrival.**
- Clear: `T:669-673 _both_clear_distance` → `TomTom:RemoveWaypoint(uid)` unless `UnitOnTaxi("player")`. Removal deletes the
  saved-variable entry too (`T:709-719`).
- Ping: `T:675-679 _both_ping_arrival` → `PlaySoundFile("Interface\\AddOns\\TomTom\\Media\\ping.mp3")` if `arrow.enablePing`
  (default false, `T:93`).
- Arrow: `CA:135 if dist <= arrive_distance then` swaps to the animated `Arrow-UP` texture in `goodcolor` (`CA:136-157`);
  no state is latched — it flips back the moment `dist > arrive_distance` (`CA:158-164`).
- Auto-set-next: not from arrival directly. `RemoveWaypoint` → `ClearWaypoint` (`W:244-264`) makes `IsValidWaypoint` false; on the
  next arrow tick `CA:116-124` sees `not dist`, then `not IsValidWaypoint(active_point)` → `active_point = nil` and, if
  `arrow.setclosest` (default true, `T:92`), `TomTom:SetClosestWaypoint()`. So "arrive → clear → next-closest" is a chain of three
  ticks across two OnUpdates, not one decision.
- Dead code: `T:383-396 WaypointCallback` handling an `"OnDistanceArrive"` event is defined and never referenced (grep: only its definition).

REUSABLE MECHANISM
- Ring-list state machine with transition-only firing (`W:382-430`): sorted radii, index the current ring, act on index change. Small, deterministic, one table per marker.
- Callback signature carrying `(uid, ringRadius, dist, lastDist)` (`W:423`) — enough to tell inbound from outbound.
- Radii as per-marker data bound at creation (`T:765-780`), not read live from options.

POSTURE NOT TO INHERIT
- Fire-on-first-sample and no hold/hysteresis — a route driver that must not advance on a graze needs both.
- The shared throttle counter across icon frames (`W:334`).
- Auto-clear on taxi guard only (`T:670`) as the sole "false arrival" defence.
- Outward transition firing the outer ring's callback (`W:420`) — re-pings on leaving.
- Arrival gated behind `IsInInstance()` (`W:340`).

---

## 4. AUTO-ADVANCE / SEQUENCING

**There is no ordered list.** Waypoints are a set keyed by uid (`T:47 local waypoints = {}`, `T:812-824`) with a per-zone index
`waypoints[zone][uid] = true` (`T:824`). Persistence keeps insertion order in an array per zone (`T:829 table.insert(self.waypointprofile[zone], data)`),
but nothing consumes that order except `ReloadWaypoints` (`T:224 for idx,waypoint in ipairs(data)`), which re-adds them all.

**"Next" is nearest-by-yards in the current zone.** `T:1002-1019 GetClosestWaypoint`: reads player `(c,z)`, resolves `zone`,
iterates `waypoints[zone]`, keeps the min of `GetDistanceToWaypoint(uid)`; `T:1021-1027 SetClosestWaypoint` points the arrow at it
via `SetCrazyArrow(uid, arrival, title)`. Waypoints in other zones are invisible to this (only `waypoints[zone]`), and waypoints
whose distance is nil (icon gone) are skipped (`T:1010`).

**Triggers for re-selection** (all funnel into `SetClosestWaypoint`):
- Arrow tick finds its target invalid and `arrow.setclosest` is on (`CA:116-124`).
- Dropdown "Clear waypoint from crazy arrow" (`CA:272-283`) — picks closest **only if it differs from the one just cleared** (`CA:278 if uid and uid ~= prior`).
- `/cway`, `/closestway` (`T:1029-1033`).
- New waypoint added with `arrow.autoqueue` on (default true, `T:84`; `T:787-810`) — **the newest waypoint takes the arrow**, regardless of distance.

**Skipping.** No skip primitive. The user's options are: remove the current waypoint (`CA:286-291`), clear the arrow (which may
re-select the same nearest via `CA:277-281`), or set another explicitly (`T:422-430` "Set as waypoint arrow"). Nothing marks a
waypoint "visited"; a cleared-by-arrival waypoint is simply removed.

**Quest-POI auto-advance** (`POI:102-146`) is a separate closest-of-a-different-kind: hooks `WatchFrame_Update`, takes the **first
watched quest** (`POI:108 GetQuestIndexForWatch(1)`), removes its previously set waypoints (`POI:132-134`), and sets one at that
quest's POI icon (`POI:135`). "Closest" is in the comments (`POI:104-105`, `CFG:665`), but the code selects by watch slot 1, not
distance. Off by default (`T:127 setClosest = false`).

REUSABLE MECHANISM
- The three-part shape: `GetClosest*()` pure query → `SetClosest*()` mutator → callers (`T:1002-1027`); the "differs from prior" guard when re-selecting after a clear (`CA:278`).
- Per-zone bucketing so nearest is scoped to the current map (`T:1007`).

POSTURE NOT TO INHERIT
- Nearest-by-yards as the successor rule — a route is an order; TomTom's "next" is whichever marker is closest, which can be the one you just left if you did not clear it.
- Newest-wins on add (`autoqueue`, `T:808`).
- No visited state, no skip, no index — sequencing here is emergent from remove+nearest, not modelled.
- Quest-POI "closest" that is really "watch slot 1" (`POI:108`).

---

## 5. THE ARROW

**Heading.** `CA:166-169`: `angle = TomTom:GetDirectionToWaypoint(active_point)` minus `GetPlayerFacing()`. The bearing comes from
Astrolabe: `A:708-718 GetDirectionToIcon` = `atan2(-data.yDist, data.xDist)` normalised to `[0, 2π)` — from the **cached** icon
offset (§2), so bearing has the same freshness as distance. Rendered as a sprite-sheet cell: `CA:179 cell = floor(angle / twopi * 108 + 0.5) % 108`,
9 columns of 56×42 px on a 512² texture (`CA:180-187`). Colour is a red→yellow→green gradient on how far off-heading you are:
`CA:171 perc = |(π - |angle|) / π|` → `ColorGradient` (`CA:14-36`, `CA:173-177`). The minimap-edge arrow uses the same
`GetDirectionToIcon` plus `rad_135`, minus `GetPlayerFacing()` only when `rotateMinimap` is on (`W:77-92`, `W:356-374`).

**Cadence.** `CA:254 wayframe:SetScript("OnUpdate", OnUpdate)` — **every frame while shown**, no throttle on distance/heading/colour/texcoord.
The one throttled part is the ETA: `CA:192-194 tta_throttle … if tta_throttle >= 1.0` → speed = `(last_distance - dist) / tta_throttle`
smoothed over two samples (`CA:196-208`), text `%01d:%02d` or `***` (`CA:210-215`).

**Cost management.** Frame hides itself when there is no target (`CA:107-110`), when distance is nil or in an instance (`CA:116-127`),
and when the arrow is disabled (`CA:249-250`); OnUpdate stops with the hide. Texture/size swaps are latched on `showDownArrow`
(`CA:136-142`, `CA:159-164`) so they happen once per state change. Everything else (three `unpack` of profile colour tables,
gradient, texcoord) is per-frame. The optional LDB feed runs a second OnUpdate at `feeds.arrow_throttle` (default 0.1 s, `T:122`;
`CA:406-444`).

**Hijack API** (`CA:451-520`): `TomTom:HijackCrazyArrow(onupdate)` replaces the frame's OnUpdate wholesale (`CA:505-509`);
`SetCrazyArrowDirection(angle)` (`CA:482`, caller subtracts `GetPlayerFacing()` themselves per `CA:479-481`), `SetCrazyArrowColor(r,g,b,a)`
(`CA:492`), `SetCrazyArrowTitle(title, status, tta)` (`CA:498`), `ReleaseCrazyArrow()` (`CA:512`), `CrazyArrowIsHijacked()` (`CA:518`).

REUSABLE MECHANISM
- `bearing - GetPlayerFacing()` → 108-cell sprite index (`CA:166-187`) and the `atan2(-dy, dx)` → `[0,2π)` normalisation (`A:711-716`).
- Latch texture swaps on a boolean (`CA:136,159`) so the per-frame path is texcoord-only.
- Hijack seam: a driver could **borrow the rendered arrow** without TomTom's waypoint model (`CA:505-509`).

POSTURE NOT TO INHERIT
- Unthrottled per-frame recompute of colour/heading (`CA:106-188`); TomTom accepts this because there is exactly one arrow.
- ETA from a two-sample speed average (`CA:202-208`) — cosmetic, drifts on stop/start.
- Bearing from a cached minimap offset (`A:709`) rather than a live read.

---

## 6. TRACKER USE

**None.** grep of the TomTom folder for `SUPER_TRACK`, `SuperTrack`, `SetSuperTrackedQuestID`, `SuperTrackerUtil`,
`C_SuperTrack` returns nothing. TomTom does not read or write the client's supertracker.

What it *does* touch of the client's quest/POI surface (`POI` file only):
- `hooksecurefunc("QuestPOI_DisplayButton", …)` (`POI:91-100`) to `HookScript("OnClick", poi_OnClick)` on each POI button and
  `RegisterForClicks("AnyUp")` (`POI:96-97`); a modified right-click reads the button's **anchor offset** back into map fractions
  (`POI:5-19 POIAnchorToCoord` — divides `GetPoint()` x/y by `WorldMapDetailFrame` size and relative scale) and adds a TomTom waypoint
  at that spot titled with `GetQuestLogTitle` (`POI:39-56`).
- `hooksecurefunc("WatchFrame_Update", …)` (`POI:142-146`) → `updateClosestPOI` (§4), reading `GetQuestIndexForWatch(1)`,
  `GetQuestLogTitle`, `GetNumQuestLeaderBoards`, `WATCHFRAME_FILTER_TYPE`, `LOCAL_MAP_QUESTS[questID]` (`POI:108-126`).
- WatchFrame POI clicks are redirected to the map's quest frame (`POI:78-85 if self.parentName == "WatchFrameLines"`).
- Global writes: `POI:113 numObjectives = …` leaks a global (no `local`).

For contrast (not TomTom): the client's own `FrameXML\Minimap.lua:660-675` places a `SuperTrackPOI` on the minimap using
Astrolabe-derived math ("-- Astrolabe function", `Minimap.lua:667`) — the client tracker and TomTom share an ancestor for icon
placement but never talk to each other.

REUSABLE MECHANISM
- Reading a POI button's map position from its anchor (`POI:5-19`) — a way to harvest client-placed pins without a position API.
- `hooksecurefunc` on the display function to hook buttons once each (`POI:90-100 hooked[buttonName]`).

POSTURE NOT TO INHERIT
- Bypassing the client tracker entirely — TomTom re-implements a beacon it could not use in 2010; on this client the supertracker beacon exists (repo probes F4-F6) and TomTom's overlay is a second, unrelated marker.
- Quest-watch auto-waypointing that overrides manual waypoints (`CFG:665` "WILL override the setting of manual waypoints").

---

## 7. PERSISTENCE + SHARING

**SavedVariables.** Two AceDB-3.0 databases (`T:138-139`): `TomTomDB` (options, `defaults` at `T:52-130`, profile keyed
`"Default"`) and `TomTomWaypoints` (`waydefaults` `T:132-136`: `profile = { ["*"] = {} }`). Waypoint shape, per profile:

```
TomTomWaypoints.profiles[<profile>][<mapFile>] = { "<coord>:<title>", ... }      -- T:828-829
```
where `<mapFile>` is the `GetMapFile(c, z)` string (`T:790`) and `<coord>` is a single integer packing both fractions:
`T:905-907 GetCoord(x, y) = floor(x*10000+0.5)*10000 + floor(y*10000+0.5)`; inverse `T:908-910 GetXY(id)`. Precision: 1e-4 of the
map (0.01 on the 0-100 scale). Title after the colon; empty title stored as `""` (`T:828 desc or ""`) and read back as nil
(`T:225-226`). Load: `T:208-231 ReloadWaypoints` re-adds each with `persistent=false` so it is not re-inserted (`T:228`).
`persistent` defaults to `persistence.savewaypoints` (default true, `T:115`, `T:784`). Toggle per waypoint from the dropdown
(`T:467-500`), test via `T:576-591 UIDIsSaved` (linear scan for the `"coord:title"` string). Removal scans and deletes the string
(`T:709-719`). **No versioning field** in either DB; no migration code (grep for `version` in the SV path finds only
`T:25 version = GetAddOnMetadata("TomTom", "Version")` for display).

**Sharing.** One waypoint at a time over addon comms: `T:593-597 SendWaypoint(uid, channel)` →
`SendAddonMessage("TOMTOM2", "<mapFile>:<coord>:<title>", channel)` for `PARTY / RAID / BATTLEGROUND / GUILD` (`T:503-537`);
receiver `T:599-613 CHAT_MSG_ADDON` filters `prefix ~= "TOMTOM2"`, ignores self, `string.split(":", data)`, resolves `(c,z)` via
`GetCZ(zone)` (`T:900-902` — a reverse table built from `Astrolabe.ContinentList`, `T:879-890`) and adds it (`T:610`).
Note: `GetCZ` returns a **zone index** from `ContinentList` while `AddZWaypoint` expects an **areaID** in `z` (`T:733`, `T:897`);
whether the received `z` resolves depends on those two numberings coinciding — this audit did not run it. `comm.enable/prompt`
options exist in defaults (`T:109-112`) and in the options panel (`CFG:571,578`) but neither is read by any runtime path —
`SendWaypoint`/`CHAT_MSG_ADDON` never consult them (grep: only those two definition sites).

**Import/export string:** none. **Slash surface** (`T:987-1171`, `T:1029-1040`): `/way <x> <y> [desc]`, `/way <zone> <x> <y> [desc]`
(fuzzy zone match over `GetMapZones`, `T:995-1000`, `T:1122-1136`), `/way reset all`, `/way reset <zone>`; aliases `/tway /tomtomway`;
`/cway /closestway` (§4); `/wayb /wayback` (waypoint at own position, `T:1035-1040`). No `/way list`, no bulk add.

REUSABLE MECHANISM
- Packing `(fx, fy)` into one integer at 1e-4 (`T:905-910`) — compact, sortable, string-safe for chat.
- `mapFile:coord:title` as a one-line wire form (`T:595`) and the AceDB `["*"] = {}` per-zone default (`T:134`).
- Load path that re-creates from SV with `persistent=false` to avoid double-insert (`T:228`).

POSTURE NOT TO INHERIT
- Title as part of the identity key (`"coord:title"`, `T:478,579,683,709`) — renaming a note orphans its SV entry.
- No version stamp on the SV or wire form.
- Single-waypoint sharing with no list/route unit; no import/export string.
- Zone-index vs areaID ambiguity across the wire (`T:608-610` vs `T:733`).

---

## 8. HOOKS FOR OTHER ADDONS

Public surface, with exact signatures as written. **`AddMFWaypoint` does not exist in this version** (grep of the folder: no hits;
that is a later-TomTom API). Nor do `AddWaypointToCurrentZone`, `GetKeyArgs`, or an `AddWaypoint(mapId, x, y, opts)` table form.

- `T:730 function TomTom:AddWaypoint(x, y, desc, persistent, minimap, world, silent)` — x,y on 0-100; zone = player's current.
  **Bug as shipped:** forwards as `T:741 self:AddZWaypoint(c, z, x, y, desc, persistent, minimap, world, silent)` — `silent` lands
  in the `custom_callbacks` slot; passing `silent=true` makes `callbacks = true` and `T:769/775 callbacks.distance[...]` will error.
- `T:744 function TomTom:AddZWaypoint(c, z, x, y, desc, persistent, minimap, world, custom_callbacks, silent, crazy)` — the real
  entry. `z` is an **areaID**; `x,y` on 0-100; nil `persistent/minimap/world/crazy` fall to profile defaults (`T:784-787`);
  duplicate `(zone, coord, title)` returns the existing uid (`T:797-805`); returns `uid` (`T:838`). `custom_callbacks` shape
  (`T:749-762`): `{ minimap = {onclick, tooltip_show, tooltip_update}, world = {…}, distance = { [yards] = fn } }`; TomTom **still
  injects** its clear/ping distance callbacks into whatever table you pass (`T:765-780`), so a caller must supply a `distance`
  table or index into nil.
  - Distance callback signature: `fn("distance", uid, ringRadius, dist, lastDist)` (`W:423`).
  - Click: `fn("onclick", uid, frame, button)` (`W:290`). Tooltip: `fn("tooltip_show", tooltip, uid, dist)` (`W:313`),
    `fn("tooltip_update", tooltip, uid, dist)` (`W:282`).
- `T:861 function TomTom:SetCustomWaypoint(c,z,x,y,callback,minimap,world, silent)` → `AddZWaypoint(c, z, x, y, desc, false, …)`
  where `desc` is an undeclared global (nil) — a titleless non-persistent waypoint with custom callbacks.
- `T:704 function TomTom:RemoveWaypoint(uid)`; `T:841 function TomTom:WaypointExists(c, z, x, y, desc)` (**returns after the first
  uid in the zone, comparing title only — `T:850-857`; does not check `coord`**).
- `W:266 function TomTom:GetDistanceToWaypoint(uid)` → `dist, xDist, yDist` or nil; `W:271 function TomTom:GetDirectionToWaypoint(uid)`
  → radians `[0,2π)` or nil; `W:212 function TomTom:IsValidWaypoint(uid)`; `W:217 function TomTom:HideWaypoint(uid, minimap, worldmap)`;
  `W:232 function TomTom:ShowWaypoint(uid)` (references `point.data.show_minimap`, a field never assigned — `W:235,238`; would error).
- `CA:86 function TomTom:SetCrazyArrow(uid, dist, title)` — `dist` is the arrival radius for the arrow's "arrived" swap (`CA:88`, `CA:135`).
- `T:1002 function TomTom:GetClosestWaypoint()` → uid or nil; `T:1021 function TomTom:SetClosestWaypoint()`.
- Conversions: `T:892 GetMapFile(C, Z)`, `T:900 GetCZ(mapFile)`, `T:905 GetCoord(x, y)`, `T:908 GetXY(id)`.
- Arrow hijack: `CA:482 SetCrazyArrowDirection(angle)`, `CA:492 SetCrazyArrowColor(r, g, b, a)`, `CA:498 SetCrazyArrowTitle(title, status, tta)`,
  `CA:505 HijackCrazyArrow(onupdate)`, `CA:512 ReleaseCrazyArrow()`, `CA:518 CrazyArrowIsHijacked()`.
- `W:94 function TomTom:ReparentMinimap(minimap)` — for minimap replacements.
- Internal, documented as not-for-addons (`W:5-8`): `W:102 TomTom:SetWaypoint(c, z, x, y, callbacks, show_minimap, show_world)`,
  `W:244 TomTom:ClearWaypoint(uid)`.
- Exposed tables: `TomTom.waypoints[uid] = {title, coord, x, y, zone}` (`T:812-818`, `T:153`), `TomTom.db`, `TomTom.waydb`,
  `TomTom.profile` (`T:200`).
- Events emitted for other addons: **none** (no `CallbackHandler`, no custom event fire; grep for `Fire(`/`callbacks:Fire` returns nothing).
  Arrival is observable only through the per-waypoint `distance` callback table you pass in.

REUSABLE MECHANISM
- Per-marker callback table with named sub-tables (`minimap/world/distance`) and a `distance = { [yards] = fn }` map — the caller declares its own radii and receives `(uid, radius, dist, lastDist)` (`T:749-762`, `W:423`).
- uid indirection (`W:37-67 getuid/resolveuid`) so callers hold an integer, not a frame.
- Frame pool for markers (`W:33 pool`, `W:104`, `W:262`).

POSTURE NOT TO INHERIT
- Injecting the product's own clear/ping callbacks into a caller-supplied table (`T:765-780`).
- Positional-argument APIs eleven wide (`T:744`) with a mis-ordered forwarder (`T:741`).
- Half-alive functions (`ShowWaypoint`, `WaypointExists`, `SetCustomWaypoint`'s nil `desc`) sitting on the public surface.
- No event bus — arrival cannot be observed by an addon that did not create the waypoint.
