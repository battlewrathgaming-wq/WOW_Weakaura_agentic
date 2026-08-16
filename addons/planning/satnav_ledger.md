# Landmarks & sat-nav — project ledger

_The **fact basis and design laws** for two related builds. Everything here is either LIVE-PROVEN
(with the capture that proves it) or explicitly marked as assumption. Bench-level state lives in
`operations/Addons_load.md`, which points here; this file is the project's own memory._

**★ READ THIS FIRST — the arc TURNED on 2026-08-12 (§9) and the title above changed with it.**
It opened as an in-dungeon route pointer. It is now **two builds, landmark-first**:

| | Status |
|---|---|
| **`COA_Landmarks`** — the world-map scrapbook | **design closed** → `addons/planning/landmark_design.md` (45 criteria, nothing open). Not behind the §8 gate |
| **the route half** — the in-dungeon pointer | still behind the §8 community gate; a load-or-share consumer of the same understanding |

§1–§8 were written for the route half and are kept as-is: the facts are shared, and the
value propositions still hold. **Where a §7 question belongs only to the route half, it says so.**

Opened 2026-08-08. Last audited 2026-08-12 (cross-references clean, staleness swept).

## 1. The want (Battlewrath, verbatim intent)

A **light** in-dungeon sat-nav pointer. Explicitly **not** Mythic Dungeon Tools — that's too
feature-rich. Reference points: pfQuest (installed), TomTom (not on this client generation).

> Pick a map. Pick a role. Place a point and leave a note. The system knows when you're in the
> zone of that marker, then waits / progresses to point to the next marker.

All hand-authored, nothing smart. Possible import/export string so the community converges on
shared routes.

**★ WHY — the two value propositions (Battlewrath, 2026-08-11). Keep both in view; several
design laws only make sense against them:**

1. **Team cohesion.** Routing matters, and being able to communicate *a series of markers the
   team is following* — one person's design, or a community pool if people work toward that —
   means a group runs one plan instead of five assumptions. This is why the **export** exists
   and why **team notes are role-agnostic** (law 6).
2. **Personal notebooking.** For solo use it gives people a way to *note-book their way
   through content they have done* — learn lessons, set reminders. This is why the **bin
   persists** (law 8), why **boilerplate** is worth shipping, and why the personal layer must
   **outlive any particular route**.

Note that (2) retroactively justifies law 7's wipe: if the personal value is a notebook, the
notebook has to survive route replacement — and it does, because notes live on the map
(law 9), not in the route.

## 2. ★ The scope-changing finding: the sat-nav ALREADY EXISTS

**We do not build a pointer. We feed the client's own.** Getter and setter are a matched
four-value pair — designed as one:

- `GetCurrentPlayerPosition()` → `x, y, z, mapID`. Used by the client's own bug-report frame;
  the devs' tutorial files document the idiom `/run local x,y,_,m = GetCurrentPlayerPosition()`.
- `C_SuperTrack.SetSuperTrackedPosition(x, y, z, mapID)` — via
  `SuperTrackerUtil.SetSuperTrackedPosition`, which runs a priority system
  (corpse > position > quest). Gated by CVar **`showInGameNavigation`**.
- Render is **engine-side**: `GetSuperTrackedPosition()` returns SCREEN coordinates for a
  beacon projected into the world; `Minimap_UpdateSuperTrackPOI` draws a minimap POI using
  **2D distance only, culled at 233 units**.

Nothing in the shipped client UI ever originates a position waypoint — the plumbing exists
unused.

## 3. Live-proven facts (all captured in-dungeon, Ragefire Chasm, mapID 389)

| # | Fact | How proven |
|---|---|---|
| F1 | **Position works INDOORS** — the classic 3.3.5 blocker does not apply | `GetCurrentPlayerPosition()` returned real values at multiple points |
| F2 | **All three axes live; z tracks elevation** | walked an incline: z −21.9 → −16; walked a decline: −18.15 → −21.68 |
| F3 | **mapID stable across movement** within a level | 389 throughout |
| F4 | **Setter accepted; engine stores it** — ⚠ **but we used the WRONG ENTRY POINT; see F24** | `IsSuperTrackingAnything()` → true. The probe called `C_SuperTrack.SetSuperTrackedPosition` **directly**, which bypasses the client's priority ladder. It works instantly and then gets silently overwritten by the next re-evaluation. The correct call is `SuperTrackerUtil.SetSuperTrackedPosition(x, y, z, mapID)` |
| F5 | **Beacon renders inside an instance** | visible on screen at the marked spot |
| F6 | **Beacon does NOT clear on approach** | observed — *this absence IS our mechanism*, not a defect |
| F7 | **Dungeon map art exists and is addressable** | `GetMapInfo()` → `Ragefire, 668, 768` |
| F8 | **Map-space position works indoors** | `GetPlayerMapPosition("player")` → real fractions |
| F9 | **`C_WorldMap.GetWorldPosition` returns nil inside instances** | probed; Astrolabe uses it for outdoor zones only |
| F10 | **World units are YARDS** | a beacon-measured **50-yard** leg computed to **49.7** |
| F11 | **`GetMapInfo`'s 668/768 are TEXTURE dims, not world extent** | they contradict the measured extent (below); 668 is the standard map-frame width |
| F12 | **The beacon renders its own DISTANCE READOUT in yards** — we do not build one | incidental, from Battlewrath's *illustrative* screenshots (taken to show the community the vision, NOT part of the structured probe series): a diamond marker captioned "76 yds" / "54 yds". Corroborates F10. Consequence: notes can stay purely semantic, since navigation is already on screen |
| F13 | **The beacon reads correctly ACROSS ELEVATION** — visible up a ramp, then on the same plane while closing on it | the point Battlewrath was demonstrating with those screenshots. The 3D projection behaves for the navigation case, not just at a fixed height |
| F14 | **The 233 cull is the MINIMAP POI's, not the world beacon's** | beacon visible and captioned at 76 yds. ~~Beacon max range still UNKNOWN~~ — **answered by F22/F35: full to 727 yd, dimmed to 1,500, and the ENGINE keeps returning true distance to at least 3,742** |
| F15 | **The world-map PIN MECHANISM is addon-reusable — we do not build map markers either** | source read of `Ascension_POI/MapPoiPin.lua` + `WorldMapPOIMixin.lua`. Pins parent to **`WorldMapButton`** and position via `SetPoint("CENTER", WorldMapButton, "TOPLEFT", x, y)` (pixel offsets — our map fraction × frame size lands directly) · hover text uses **`WorldMapTooltip`** (owner/AddLine), exactly the surface for the note readouts · `MapPoiPinMixin` supports a per-pin **`OnClickFunction`**, so click interaction is normal here (promote a node, open a note). **The ART is explicitly NOT reusable — see law 10.** |
| F16 | **The death markers themselves are NOT reusable** — `WorldMapChallengeFailPOIMixin`, server-fed challenge/hardcore failure records (killer, level, ruleset, timestamps) | same source read. Boundary is clean: **the pin machinery is ours to reuse, the death DATA is not** |
| F17 | **★ A PURPOSE-BUILT WAYPOINT ICON FAMILY EXISTS AND IS ALL BUT UNUSED** — and it satisfies law 10 outright | `SharedXML/AtlasInfo.lua` (**4,503** named atlas entries — the authoritative count from the emitter, F20; the 4,425 first quoted here was an ad-hoc undercount). The family lives at `interface\waypoint\waypoinmappinui` (Blizzard's own path typo): **Tracked · Untracked · Highlight** (30×30) · **ChatIcon** (13×13) · **ButtonToggle** (38×38), plus `waypoint-mappin-minimap-tracked/untracked` (32×32) on `objecticonsatlas`. Cross-referenced against 1,130 client source files: **7 of 8 referenced ZERO times.** The one claim is `SuperTracker.lua:131` — `[Enum.SuperTrackingType.Position] = "Waypoint-MapPin-Tracked"` — i.e. the client uses it for a POSITION supertrack, **exactly our use case**. Not a conflict: it is the client naming the correct symbol for us, and it is already what the live beacon renders |
| F18 | **The claim-of-use test is MECHANICAL and proven** | grep an atlas name across the extracted source tree, excluding `AtlasInfo.lua` itself; zero references = unclaimed. Ran ad-hoc over 1,130 files to produce F17. **This is the emitter's whole algorithm** |
| F19 | **The client ships an in-game ATLAS BROWSER** | `AddOns/Ascension_UIDevelopmentTools/AtlasBrowser/` in patch-B (not present in the user's AddOns folder — it lives in the MPQ). ~~Untested whether `LoadAddOn` will open it~~ — **PROVEN IN USE**: opened via `/devconsole` → `ab`, and **every icon in law 10's decision was picked through it**. Visual classification needed no tool from us. Caveat: its **search is broken** — scroll the unfiltered list (`addons/maps/atlas/README.md`) |
| F20 | **★ The census is EMITTED, and the fork's own art was the part that kept going missing** | `addons/tools/emit_atlas_census.py` → `addons/maps/atlas/` (census.json + routes.md + free.md). **4,503 entries · 1,359 claimed · 3,144 free.** Three format variants had to be calibrated in, and **all three were CoA's custom art, not Blizzard's**: (a) fractional sizes `179.2, 69.3`, (b) names beginning `!` (a sort prefix, 96 of them), (c) **Lua arithmetic as a size** — `85*0.24`, `(151+151)/512`. Each was a *silent* drop under a stricter pattern. First flawed run emitted 4,302 and looked perfectly healthy. **CoAResource entries went 39 → 102** once all three landed, including all 7 `ReaperAtlas` class-resource pieces. Lesson, general: *the bespoke rows are the ones a pattern tuned on the common rows drops — and they are exactly the rows we care about.* Guarded by a completeness self-check that compares parsed names against entry-shaped names and **refuses to write** on a shortfall; it fired twice and earned itself. Guard note: it compares NAME SETS, not line counts — the registry genuinely repeats 18 keys (Lua last-wins, so those earlier definitions are dead art), reported not hidden |

| F21 | **★ THE ENGINE PUBLISHES A NAVIGATION STATE — and it ALREADY IMPLEMENTS "arriving is silent"** | `Enum.NavigationState = { Invalid=0, Occluded=1, InRange=2, Disabled=3, InRadius=4 }` (`SharedXML/Enum.lua:1938`), read live via **`C_SuperTrack.GetTargetState()`**. `SuperTracker.lua:55` maps state → beacon alpha: Invalid **0.0** · Occluded **0.6** · InRange **1.0** · Disabled **0.0** · **InRadius 0.1**. So when you reach the target the beacon fades to near-nothing **on its own**. Battlewrath's ruling (§9 walk, stop 4) is not something we build — **we inherit it.** ★ Note the client's own convention, because it is a distinction not a contradiction: `WatchFrame.lua:179` uses that same `InRadius` to *flash a small tracker icon*. The client goes **quiet in the WORLD and acknowledges in the UI** |
| F22 | **Beacon range is BOUNDED, and the numbers are now known — this CLOSES F14's "max range UNKNOWN"** | `SuperTracker.lua:65-72`: `distance > 1500` is forced to `Invalid` (alpha 0, *"dont show too far"*); `distance > 727` downgrades InRange → Occluded (their comment: *"727 = mediumish farclip value"*). **Full strength to 727 yd · dimmed to 1500 yd · gone beyond.** Both thresholds are **Lua-side in FrameXML**, so they are the client's *convention*, not an engine limit — worth knowing, not worth fighting |
| F23 | **Cross-zone supertracking is an ENGINE question, and the probe is now a one-liner** | `FrameXML/SuperTracker.lua` is 140 lines with **zero mapID handling** — it reads `x, y, distance` from `GetSuperTrackedPosition()` and nothing else. So whether a *different-mapID* target works is decided engine-side, and **`GetTargetState()` reports the verdict directly**: `Invalid` = engine declines, `InRange`/`Occluded` **plus a sane distance** = engine handles it. Second signal: `SuperTrackerUtil.HasValidScreenPosition()`. See §7 for the exact test |

| F24 | **★★ THERE IS EXACTLY ONE SUPERTRACK SLOT, AND OUR LANDMARK OUTRANKS THE PLAYER'S QUEST** | `FrameXML/Util/SuperTrackerUtil.lua`. `SUPER_TRACKED_POSITION` is a plain **global** holding one `{x,y,z,mapID}`, and `GetHighestPrioritySuperTrackingType()` is a strict ladder: **ghost → Corpse · position set → Position · quest selected → Quest**. So setting a landmark beacon **replaces the player's quest arrow** until cleared. Unmanaged, that is an uninstall-after-one-session behaviour, and it must be an explicit design decision rather than a side effect. **Consequences, all non-obvious:** ① **Use `SuperTrackerUtil.SetSuperTrackedPosition`, NOT `C_SuperTrack.SetSuperTrackedPosition`** — the C_ call skips the ladder, so the next re-evaluation silently overwrites us (corrects F4). ② `CanSuperTrack()` reads CVar `showInGameNavigation`; when off, `SetToBestSuperTrackingType` calls `ClearSuperTracker`, whose `hooksecurefunc` **nils the global** — so **the client destroys the stored intent, and we must hold our own copy**. ③ The global is runtime-only: **lost on reload**, we restore it. ④ Re-evaluation is triggered by `PLAYER_UNGHOST` · `PLAYER_ALIVE` · `PLAYER_FLAGS_CHANGED` · `QUEST_POI_UPDATE` · a `hooksecurefunc` on `SelectQuestLogEntry` — frequent, but Position survives them all while the global is set. ⑤ **Dying is safe**: ghost pre-empts to Corpse without clearing the global, and `PLAYER_ALIVE`/`PLAYER_UNGHOST` re-assert Position, so the landmark returns after a rez |
| F25 | **★ JOURNEY OBSERVABILITY IS A TWO-CHANNEL MODEL — event for TRANSITIONS, poll for STAGES.** Direct answer to *"are there scripts we can get state behaviour per journey stage?"* | **`SUPER_TRACKING_CHANGED`** is a real event (`SuperTracker.lua:10`), fired when the *target* changes; the client uses it only to show/hide the beacon — that is the **journey started / ended** signal. **Per-stage state has NO event**: `GetTargetState()` is **polled** in `OnUpdate` every frame, and returns the `NavigationState` ladder from F21. So arrival, occlusion and range are **read**, not announced — if we want stage behaviour we detect the transition ourselves from a throttled poll. One value, cheap |
| F26 | **★ THE GUARD USES A DIFFERENT SYSTEM — map LANDMARKS, not supertrack** | `WorldMapFrame.lua:489` — `GetNumMapLandmarks()` / `GetMapLandmarkInfo(i)` → `name, description, textureIndex, x, y, **mapLinkID**`. This is the classic 3.3.5 POI channel and it is **server-fed and read-only** — there is no `SetMapLandmark`, so we cannot write into it. **Two things follow.** ① **An in-game guard inspection observes THIS channel, not the beacon** — worth doing, but the two must not be conflated, and a conclusion drawn from the guard does not transfer to `C_SuperTrack` by default. ② `mapLinkID` is a **map-to-map link carried on a POI** — the closest thing in the client to *"if not in zone, surface the zone needed"*, and therefore worth reading properly when the cross-zone probe (§7) runs. Upside: it is a **second, independent marker channel that does not contend for the single supertrack slot** (F24) |

| F27 | **★ THE SUPERTRACKER IS READABLE, AND ITS "1 yd FLOOR" IS COSMETIC** | Battlewrath observed the readout flooring at 1 when stood on the point. **Cause: `math.ceil` in `GetDistanceString` (`SuperTracker.lua:109`) — the DISPLAY path only.** The raw value is a float below 1 (you are never at exactly 0), so **our tiers are not floored by it**. Three read paths, ranked: ① **`C_SuperTrack.GetSuperTrackedPosition()` third return** — the raw float, use this · ② **`SuperTracker.distance`** — the client's own cache of the same float, updated each `OnUpdate`; the frame **is globally named** (`SuperTracker.xml:5`, parented to `WorldFrame`), so the beacon is inspectable at runtime and the probes are cheaper than assumed · ③ `SuperTracker.DistanceText:GetText()` — avoid, it is ceilinged, formatted and localised |

| F28 | **★ `distance` IS 3D — settled, and law 14's 5 yd tier is SAFE** | Probe run `20260812_111102_857__satnav`, Orgrimmar, **945 samples**. Fitting the engine's `sd` against separation computed from raw player-vs-pin coordinates: **vs 3D, mean error 0.000010 yd, worst 0.000155** · vs 2D, mean 0.215, worst 1.470. Not a judgement call — an exact fit against one and a visibly wrong one against the other. **Vertical separation is counted**, so a vendor on the floor above does *not* read as arrived. Settled without the upstairs manoeuvre ever being run: Orgrimmar's own terrain supplied ~1.5 yd of vertical variation, and because the fit is exact rather than approximate, that was enough |
| F29 | **★ `distance` SURVIVES the target going off-screen — arrival polling is safe** | Same run: **573 screen-invalid samples, all 573 kept a distance**, and **zero** of 945 samples returned no distance at all. Law 14's arrival-wipe works regardless of where the camera points, which was the failure mode that would have broken it silently. ★ Also learned: **`sx`/`sy` are normalised FRACTIONS, not pixels**, and go negative off-screen (observed `sx −2.397 .. 1.289`, `sy −1.732 .. 0.506`). `HasValidScreenPosition`'s `x > 0 and y > 0` is therefore a **loose** test — a point at `sx = 1.29` passes it while sitting off the right edge. We do not use it; recorded so nobody adopts it as a proximity signal |
| F30 | **★★ `mapID` IS THE CONTINENT/INSTANCE MAP, NOT THE ZONE — so cross-zone was never the problem** | Same run: **1,291 yards travelled**, out of Orgrimmar into open terrain (`x 520..1780`, `y −3994..−3706`), and **mapID stayed 1 for all 945 samples**. Kalimdor is one continuous coordinate space; a zone border is not a map change. Corroborated live by Battlewrath before the file was read: *"the beacon persists cross map… useful across zones so long as in the region map (Kalimdor) vs Eastern kingdoms, or other (instance)."* **This REFINES F3** (which read mapID stability as a within-level property; Ragefire's 389 is an *instance* map, same rule). **★ THE DESIGN CONSEQUENCE IS LARGE: retrieval is a DISTANCE problem, not a zone problem.** §9 walk stop 3 was framed around zones; the real boundary is range, and then continent/instance |
| F31 | **★ THE ENGINE'S OWN ARRIVAL RADIUS IS ~5.5 yd — and law 14's `Interact with` tier landed on it independently** | Same run, bracketed from 945 samples: `InRadius` spans `sd 0.00 .. 5.37`, `InRange` starts at `5.73`. **The boundary sits between 5.37 and 5.73 yd.** Battlewrath chose **5 yd** for the tightest tier before this number existed, so the tier is not merely safe (F28) — it is **the engine's own opinion of "you are here"**. Note it remains *unsettable*, so law 14's per-landmark tiers still come from `distance` (not from `InRadius`); this is corroboration, not a mechanism |
| F32 | **★ THE ENGINE REPORTS `InRange` AT 1,291 yd — the 727/1500 thresholds are PURELY the client's, and OUR readout is UNCAPPED** | Same run: **no `Occluded` and no `Invalid` state was ever returned**, at any distance up to 1,290.86 yd. Confirms F22 empirically — `727` and `1500` live in `SuperTracker.lua`'s alpha function, not in the engine. **The consequence is the answer to "surface the zone needed":** `GetSuperTrackedPosition()` hands us **true distance regardless of whether the beacon renders**, so past 1,500 yd we can still say *"Winterspring — 4,200 yd"* in our own UI while the client declines to draw a beacon. We are not blind out there, only un-beaconed |
| F33 | **`distance` can be exactly 0 — corrects F27's framing** | 15 samples read `sd = 0.00` while stood on the pin (`hd = 0`, `vd = 0`). The observed "1 yd floor" is `math.ceil` rounding `(0, 1]` up to 1; an exact 0 displays as `0`. The raw value has no floor |
| F34 | **F24's slot behaviour is stable in practice** | Same run: `gp = 1` and `tr = true` for **every** sample across 3 minutes and 1,291 yards — the client held our position in `SUPER_TRACKED_POSITION` throughout, through zone-text changes and normal play. The single-slot hazard is real (F24) but the hold itself does not drift |

| F35 | **★★ THE LONG-RANGE READOUT IS REAL — distance stays live to at least 3,742 yd, long after the beacon goes dark** | Second probe run `20260812_112152_164__satnav`, **The Barrens, 727 samples, max 3,741.99 yd**. The engine returned **`InRange` the entire way** — never `Invalid`, never `Occluded` — and **zero** samples came back without a distance. Battlewrath live: *"It stopped displaying at 1.5k"*, which is F22's Lua-side cut behaving exactly as read from source. **So past 1,500 yd we are un-beaconed, not blind.** This ANSWERS §7's top question and settles the *"surface the zone needed"* problem as a **presentation** choice rather than a data gap — we can state *"Winterspring — 3,700 yd"* at any range tested. **★ THE GAP IT EXPOSES:** between 1,500 yd and arrival the player has **no on-screen feedback at all** unless we supply it. This is the one place §2's *"we do not build a pointer, we feed the client's own"* stops covering us — the client simply declines to draw out there |
| F36 | **F30 CONFIRMED BY AN ACTUAL ZONE CROSSING, not inference** | Same run: Battlewrath travelled **from The Barrens into another zone** and **mapID stayed 1 for all 727 samples**. Run 1 inferred the continent-space model from range alone; this crossed a real border and nothing changed. `gp = 1` and `tr = true` throughout 3,742 yd and a zone transition — the client held our position the whole way (F34 again, harder) |
| F37 | **The engine's arrival radius narrows to 5.46–5.59 yd — almost certainly 5.5** | Two independent runs bracket it: run 1 `(5.37, 5.73)`, run 2 `(5.46, 5.59)`; the intersection is **`(5.46, 5.59)`**. Tightens F31. Law 14's `Interact with` tier at **5 yd** sits just inside the engine's own notion of *you are here*, which is the correct side to be on — our tier fires marginally later than the engine would, never earlier |

| F38 | **★★★ THE ENGINE DECLINES ACROSS A MAP BOUNDARY — AND RETURNS `sd = 0.00`, NOT NIL. THIS IS A SHIPPING-GRADE TRAP.** | Third probe run `20260812_113949_493__satnav`: pin outside Ragefire in Orgrimmar (mapID 1), then in through the portal (mapID **389**). Battlewrath live: *"Set marker/beacon outside of the instance — visible. Move into the instance — not visible / no guidance."* The record says exactly why, and says something worse. **Inside, across all 57 samples: `NavigationState.Invalid` · `sd = 0.00` · `IsSuperTrackingAnything()` STILL TRUE · `gp = 1`.** So the client **held our pin faithfully** and the **engine refused** — the discrimination `gp` was built for, working. **★ THE TRAP: a refusal is reported as ZERO DISTANCE.** Law 14 compares distance against a tier; **zero satisfies every tier**, so a naive implementation fires *arrived*, wipes the beacon and calls the errand complete **the instant the player zones into any instance**. Neither obvious guard catches it — tracking is still true and a distance *is* returned. Only the **state** distinguishes refusal from arrival |
| F39 | **`distance` is 3D — third independent confirmation, and the cleanest yet** | Same run, restricted to the pin's own map and excluding declined rows: **mean error 0.000000 yd, worst 0.000001** vs 3D; 0.008765 / 0.046056 vs 2D. Three runs, three zones, 1,758 usable samples. Not revisitable |

| F40 | **`showInGameNavigation` is the MASTER SWITCH for the whole supertrack system — not a position-only toggle** | Source: `SuperTrackerUtil.CanSuperTrack()` returns the CVar, and it is tested at the **top** of `SetToBestSuperTrackingType`, *before* the priority ladder — `if not CanSuperTrack() then C_SuperTrack.ClearSuperTracker(); return end`. So turning it off takes the **quest arrow and the corpse arrow** with it, not just position waypoints. §2's *"the plumbing exists unused"* is true of **position** waypoints only; the CVar itself is in active use. It is **user-facing**: a checkbox labelled **"Game Navigation"** under **Interface → Objectives** (confirmed in-game by Battlewrath; `Settings/InterfaceOptions.lua:354`, string `SHOW_IN_GAME_NAVIGATION`), whose `setFunc` re-runs `SetToBestSuperTrackingType`. *(An earlier note here said the Display panel — that came from the legacy `InterfaceOptionsPanels.lua:721` list, not the live UI. Corrected.)* **★ Its in-game tooltip is worth quoting, because it is the client describing our use case in its own words: *"Display an in-world marker indicating the direction and distance of a tracked quest **or waypoint**."* Position waypoints are an intended feature — §2's "unused" means unused by the shipped UI, not unsupported** |
| F41 | **★ THE CVar-OFF PATH, MEASURED — and it is DISTINGUISHABLE from a map-boundary refusal** | Fourth probe run `20260812_125020_316__satnav`, Orgrimmar (Cleft of Shadow), CVar off, 99 samples, **every sample identical**: `GetTargetState()` → **`Invalid` (0)** · `IsSuperTrackingAnything()` → **false** · `SUPER_TRACKED_POSITION` → **nil** (`gp = -1`) · distance → **nil**. Battlewrath confirmed the beacon was absent. **This CONFIRMS BY OBSERVATION what F24 ② had only read in source: the client really does nil our stored intent when the CVar goes off.** ★ **And the two failure modes are cleanly separable**, which matters because both report `Invalid`: <br> • **CVar off** — tracking **false**, `gp = -1`, distance **nil** <br> • **Map-boundary refusal** (F38) — tracking **true**, `gp = 1`, distance **0.00** <br>★ **MY INFERENCE WAS WRONG, and is recorded as wrong:** I read `Enum.NavigationState.Disabled` (3) as the likely CVar-off state on the strength of its name. **It is not** — the client returns `Invalid`. `Disabled` (1,857 samples now) and `Occluded` remain **never observed**. Labelling it an inference rather than a finding is what made it cheap to be wrong |

| F42 | **★★ THE ENGINE RENDERS A DIFFERENT BEACON ICON PER TRACKING TYPE — so sharing the slot does NOT blur the signal** | Battlewrath, live: *"They use different icons… Tapered diamond for a quest. Square diamond for the beacon."* Confirmed at `SuperTracker.lua:129`: <br> `[Quest] = "Navigation-Tracked-Icon"` · `[Position] = "Waypoint-MapPin-Tracked"` · `[Corpse] = "Navigation-Tombstone-Icon"` <br>**This closes F17's loop.** F17 found `Waypoint-MapPin-Tracked` was the ONE claimed entry in the waypoint family, claimed by `SuperTracker.lua` for a **position** supertrack — "the client naming the correct symbol for us". We now see it **actually render**, and it visually separates our beacon from a quest beacon **for free, with no work from us**. ★ It also retires a worry that shaped laws 13–17: taking the quest slot was never going to make the player mistake a landmark for a quest, because **the engine already labels which kind of thing you are following** |

## 4. ★ The map↔world transform — SOLVED, exact

F9 said the engine won't convert map→world indoors. **We derive it ourselves**, and it is
exactly linear.

**Raw captures (Ragefire Chasm; keep for re-verification):**

| pt | world x | world y | world z | map x | map y |
|---|---|---|---|---|---|
| A | 1.49 | −23.39 | −20.50 | 0.64459 | 0.07742 |
| B | −163.68 | −31.16 | −40.35 | 0.65510 | 0.41274 |
| C | −62.60 | −41.34 | −18.15 | 0.66887 | 0.20753 |
| D | −12.94 | −42.62 | −21.68 | 0.67061 | 0.10670 |

**Derived (A/B for the vertical scale, A/D for the horizontal):**

```
world_x = 39.63  −  492.58 × map_y
world_y = 452.96 −  739.00 × map_x
```

**Validation:** predicts all four points to within **0.03 yards**.

Consistency checks that make this trustworthy rather than fitted:
- Axes are **swapped and inverted** (map_y→world_x, map_x→world_y) — the era's convention.
  Un-swapped ratios come out at −15,715 and −23, i.e. absurd.
- Measured world extent **739 × 492.6 yards** = ratio **1.5003**, exactly the 3:2 of the
  standard 1002×668 map frame. The two independently-measured scales confirm each other.

**~~Calibration cost per dungeon~~ — RETIRED 2026-08-13.** It was *"two captured points with
decent map separation"*. **The transform is a LOOKUP**, read from the client's own
`DungeonMap.dbc`: `mapX = (maxX - worldY)/(maxX - minX)`, `mapY = (maxY - worldX)/(maxY - minY)`,
**per floor**. Verified zero-residual against 389 captured points from the two pinned runs, and
the emitter re-runs that proof on every emit. It is correct on the **first** visit to a dungeon
nobody has run. Fact basis: `addons/maps/worldmap/README.md` (M3, M4 — and note M4, the fields
named X bound world **Y**).

_Superseded text, kept for the reasoning it carried:_
> **Calibration cost per dungeon:** two captured points with decent map separation — which a
> route's first run produces naturally. **ASSUMPTION (corroborated, not proven):** pfQuest hardcodes a single `* 1.5` x-correction for **every zone** in a mature addon with a full zone database (`satnav_prior_art.md` §2) — strong third-party evidence, from people who would have noticed variation. Still an assumption here: that the 3:2 aspect holds for
> all dungeon maps; if so one well-separated leg gives both scales. Verify on a second dungeon
> before relying on it.

## 5. Design laws (decided)

**★ THE GOVERNING METAPHOR (Battlewrath, 2026-08-08): "We're not trying to be smart. This is
pen and paper in digital form."** Sticky notes on a map · a drawn path with numbered stops ·
a note near a stop is about that stop · draw a line when you need to be explicit. Use this to
arbitrate scope: if a proposed feature is something you could not do with pen, paper and a
map, question it. It is the standing answer to "should this be cleverer?"

**★ AND ITS ARCHITECTURAL HALF (Battlewrath, 2026-08-12): *"A page doesn't really know what
you've drawn. It just persists. We provide defaults but the user has choice."*** The metaphor
above arbitrates **features**; this arbitrates **mechanism**. **The system is INERT with
respect to user content** — it holds what you put on it and reads none of it. The note is never
parsed, the icon never interpreted, the name never analysed, the `what`/`why` fields never
mined.

This is not a new rule; it is the **name of a pattern already running through the design**, and
having the name makes the next violation easy to spot:

| Law | Is the same statement about |
|---|---|
| **L4** — the session drafts, the human curates | we do not **prompt** |
| **L11** — notes of meaning, not what-where | we do not **author** meaning |
| **L18** — behavioural, not instructional | we do not **explain** |
| **L19** — the icon is presentation only | we do not **read** meaning |
| **AC-4** — name only what we know | we do not **guess** |

A page has lines and the pen has a colour — **we provide defaults** — but nothing on the page
changes what the page does.

1. **A marker can only be born where a player stood.** Three capture sources, all ground
   truth: **combat start**, **combat end**, and a **widget tap**. Rationale (Battlewrath): a
   2D map image cannot supply height, so a spawned point would need an invented z — which
   puts the beacon inside geometry or on the wrong floor. F9 later added a second support:
   the engine can't give world x/y from map coordinates either.
   **Consequence worth keeping: every marker in every shared route is provably reachable,
   because someone physically stood on it.** A click-to-place editor cannot promise that.
2. **The editor never creates or relocates arbitrarily.** It orders, annotates, assigns,
   prunes, and **nudges within a limited range**.
   **★ WHY NUDGING EXISTS (Battlewrath, 2026-08-11): the nudge is the gap between EXECUTION
   and INTENT.** Real-time play does not match planning, and routes need optimising. Capture
   records where you *did* fight; the route should encode where you *should*. Worked example:
   a bad pull entered from the left, when the correct approach is from the right using a LOS
   point — so the node drags to the right and matches the better visual map feature. This is
   also why the **range limit is principled rather than arbitrary**: you are correcting an
   approach within the same room, never relocating the fight. A nudge updates BOTH representations (§4
   makes this possible) and keeps the captured **z**, so it stays on one plane. Arrival is a
   **radius/sphere**, which absorbs the residual error — this is why an approximate
   conversion is good enough.
3. **The map is an orientation surface, not an authoring surface** — a 2D asset plus a note
   stream.
4. **The play session drafts; the human curates.** Combat boundaries auto-draft the route
   spine (a dungeon route IS a sequence of pulls); manual taps add the connective tissue
   ("through this door", "wait for the patrol") that combat can't signal.
5. **Store both coordinate spaces at capture.** We're standing there, both are ground truth,
   and it removes conversion from the common path entirely.
6. **Notes come in two flavours (Battlewrath, 2026-08-08): SELF and TEAM — and they layer.**
   The **export carries locations + TEAM notes only, role-agnostic**. A consumer imports that
   layout and then adds their **own personal notes on top**. The shared artifact stays the
   ROUTE; nobody inherits anyone else's idiosyncrasies. This is what lets "notes for yourself"
   stay the premise while sharing remains a clean consequence.
7. **★ IMPORT WIPES — version control belongs to the USER (Battlewrath, 2026-08-08).**
   An import REPLACES the route; it does not merge. The load carries an **identity** (name /
   author / version stamp) so a user can tell one load from another, but deciding what to
   keep, replace or discard is theirs — not something the addon arbitrates.
   **This deliberately declines a problem rather than solving it.** Merging would demand
   stable per-point IDs, reattachment logic for republished routes, and conflict handling
   when a shared point moves under a personal note. Wiping removes all of it. The cost is
   that personal notes on a replaced route are lost, and that cost is the user's to manage by
   choosing when to import.
   Keeps the system simple, and keeps authority where it belongs.
7b. **★ EXPORTS CARRY A MODE: DISPOSABLE vs SACRED (Battlewrath, 2026-08-11).**
   *"Follow this tank's route"* is disposable — one run, then discard. A **sacred** route is
   one you keep; sacredness comes from **a community pool or the sharer's preference**.
   - **It is metadata, not logic.** The source asserts it, the addon reports it, the user
     decides. Consistent with law 7: give identity, never arbitrate.
   - **★ STRUCTURAL CONSEQUENCE — this modifies law 7.** If import wipes and there is only
     one active route, a pug tank's disposable link destroys a route kept for weeks. So
     routes are a **NAMED COLLECTION per map**, and the wipe **scopes to the entry being
     imported into**, not to everything. Still simple — "you have several routes and they
     have names" — but it is what makes the distinction meaningful rather than decorative.
     (Notes survive regardless, being map-scoped per law 9; it is the *path* that needs
     somewhere safe to sit.)
   - Maps onto the two propositions: **disposable serves team cohesion** (one run, one
     leader's plan), **sacred serves notebooking** (the route you refine and keep). One
     mechanism, two lifecycles.

8. **★ SELF NOTES LIVE IN A BIN, not in the route (Battlewrath, 2026-08-08).** A personal,
   persistent library. Notes are **dragged from the bin onto a LANDMARK** to anchor
   (see law 9 — the target is a promoted node, not a route waypoint).
   - **This is what makes law 7 cheap.** A wipe replaces the route; the bin and the landmarks
     are untouched, so personal notes SURVIVE across different routes and across re-imports.
     Structure solves what merge machinery would otherwise have to.
   - **Reuse:** one note ("pull back to the corner for LOS") serves many points across many
     dungeons instead of being retyped.
   - **Boilerplate:** ships with a few generic starters so a new user can drag something on
     day one. **Keep this set TINY and generic** (interrupt · avoid frontal · wait for patrol
     · LOS pull) — it is UI furniture, and must not drift toward the dungeon database we
     explicitly refused to build (§8 scoping insight).
   - **Spec linking (TENTATIVE — "maybe", his word):** a note may carry a spec, so it shows
     when relevant. **If taken, this likely RESOLVES the role question** — role/spec belongs
     on the NOTE, not on the route, leaving the shared route one role-agnostic path exactly
     as the export already assumes.
9. **★ THE CLEAN CUT — TWO OBJECT KINDS, SEPARATED BY LIFECYCLE (Battlewrath, 2026-08-11).
   This SUPERSEDES the earlier proximity-pairing model; see "retired" below.**

   - **WAYPOINTS *are* the route.** Ordered, carrying **team notes**, exported together,
     disposable or sacred, wiped on import. Role-agnostic.
   - **PROMOTED NODES are personal LANDMARKS.** A captured position can be **promoted to a
     stable fixture** for that map/content. Map-scoped, they outlive every route.
     **Personal notes ANCHOR to them** — explicitly, by the user.
   - **Two optional note readouts: Personal · Team.** Independently toggleable.

   **Two independent display triggers, not one entangled one:**
   - **Route progression** drives the beacon and team notes.
   - **Player proximity to a landmark** drives personal notes — regardless of route position,
     or of whether a route is loaded at all. This is exactly right for the notebooking
     proposition: your landmarks and lessons exist in that dungeon whether or not you are
     following anyone's plan today.

   **★ RETIRED by this cut** (recorded so nobody rebuilds it): derived note↔point pairing by
   proximity · a nearest-wins default for ambiguous pairings · the click-link override for
   the 3D ambiguity case · the pre-flight green dot that existed to make a derivation
   inspectable. **Nothing is derived any more** — a personal note sits on a landmark because
   the user put it there. Nudging reverts to plain placement.

   **★ REFINED, NOT RETIRED, BY §9 (Battlewrath, 2026-08-12): "the routing becomes either a
   LOAD or SHARE operation of the same architecture."** The cut above stands — but it is a cut
   in **lifecycle and provenance**, not in record type. There is **one marker architecture**:
   a position (both spaces), notes, a category, an icon. What makes something "a route" is
   that the collection was **loaded or shared** and carries an **order**; what makes something
   a landmark is that *you authored it* and it persists. Law 9's rules then attach to **where
   the collection came from**, not to what kind of thing it is.
   **★ THE HAZARD THIS CREATES — CONDITIONAL, and worth carrying anyway:** law 7 says
   **import WIPES**. *If* loaded and author-owned markers ever share a store, that wipe has a
   boundary it must never cross. **Constraint in that case: a wipe is scoped to the loaded
   collection and can never reach author-owned landmarks — enforced structurally, not by
   care.** Whether they share a store is an open implementation choice, not a given (§9), so
   this is a **condition on a design decision, not a standing law**. Carried because it is the
   one place a shared store could destroy someone's own work, and it is cheaper to know the
   constraint before choosing than to discover it after. No solution proposed.

10. **★ ICONS CARRY LANGUAGE — DO NOT REUSE IN-USE ART (Battlewrath, 2026-08-11).**
    The client's POI atlas symbols already mean things here (skull, crossed swords, taxi
    node, teleport). **Borrowing a symbol borrows its sentence.** Reuse would both mis-state
    our own signal AND corrupt the client's: a player seeing crossed swords could no longer
    tell a hardcore death from a route pull-point.
    - So F15's reuse is the **MECHANISM ONLY** — parenting, positioning, tooltip, click.
      The **iconography needs its own vocabulary**, visually distinct from anything the
      client uses for its own signals, and internally consistent so a route reads as one
      language.
    - It needs very little: **waypoint · landmark · current target**. Three or four symbols.
      **★ AND F17 SUPPLIES NEARLY ALL OF THEM**, semantically named and unclaimed:
      current target = `Waypoint-MapPin-Tracked` (already what the beacon renders — we
      inherit consistency for free) · other route points = `Waypoint-MapPin-Untracked` ·
      hover = `Waypoint-MapPin-Highlight` · minimap = the two minimap variants · the capture
      widget's button = `Waypoint-MapPin-ButtonToggle` · and `Waypoint-MapPin-ChatIcon` if
      routes are ever shared as chat links.
      ~~The one genuine gap is the LANDMARK symbol~~ — **CLOSED, see the decision below.**
    - **Audit the atlas rather than mine it** — knowing which shapes are TAKEN is the more
      valuable half, because it tells us what to avoid.
    - Worth considering: route markers need not be pictorial. **Numbered or lettered pins**
      carry ordering information a symbol cannot, which suits a sequence better — and sits
      closer to the pen-and-paper metaphor than a borrowed skull would.
    - **★ REFINEMENT (Battlewrath, 2026-08-11): the bar is NOT "no client art" — it is "no art
      that already owns a meaning HERE".** Generic or unused assets are fair game: a flag
      pole, a plain banner, an unclaimed arrow or dot. Something generic enough that **meaning
      is inferred from our usage without us owning the symbol**.
      **The test:** does a player already know what this icon means *in this game*? Crossed
      swords and the skull fail it; a plain flag passes.
    - **★★ REFINEMENT 2 — CLAIMED IS A FILTER, NOT A VERDICT (Battlewrath, 2026-08-12).**
      Ruling, verbatim: *"the supertrack, the diamond seen, is fit for purpose. People know it
      as 'Go here' not the technical 'This is attached to a quest', so that's fair use."*
      This separates two things the census cannot tell apart. The census measures a **code
      binding** — who references this name. Law 10's bar is the **meaning a player reads**.
      They come apart exactly here: the beacon's binding is a quest supertrack, its read is
      "go here". A player never learns the binding, so nothing is corrupted by our using it —
      and consistency with what they already follow is a *gain*, not a cost.
      **The exemption, stated tightly so it stays one:** a CLAIMED entry is still fair use
      when the meaning it owns is (a) **generic** — navigation, position, "here" — and
      (b) **the same as ours**. Both conditions. Crossed swords are claimed by a meaning that
      is specific *and* different; they stay out. `Waypoint-MapPin-Tracked` (the family's one
      claim, `SuperTracker.lua:131`) is claimed by a meaning that is generic *and* identical;
      it is in.
      **Consequence for the build:** the *world* beacon is engine-drawn — never our choice
      and now explicitly endorsed. The **map** side is where our art decisions actually live,
      and the **3,144 free entries are that supply**. So the whole waypoint family is
      available to us, claim included.
    - **★★★ REFINEMENT 3 — THE SAFEST SUPPLY IS ART FROM FEATURES THIS FORK DOESN'T SHIP
      (Battlewrath, 2026-08-12).** His read: *"mainly the warfronts. I think their content from
      the back porting that isn't included in the current content offering."*
      This out-ranks "unclaimed". Unclaimed only says *the code doesn't reference it yet*.
      Art belonging to a **feature the fork never shipped** can never collide in-game, because
      nothing will ever render it in its original sense and **no player of THIS game has an
      association to overwrite**. It is a parts bin by construction.
      **CORROBORATED — and the fork's own devs got there first.** Warfronts art is repurposed
      by this client in **three** separate places, each time for something unrelated:
      `WorldMapPOIMixin.lua:143` uses `warfronts-basemapicons-empty-barracks-minimap` as the
      **hardcore/challenge DEATH marker** · `MapPOI.lua:92` maps `warfront-neutralhero` /
      `-hordehero` to **WorldBoss** POIs · `CharacterSelect.lua:460` uses
      `alliance/hordewarfrontmapbanner` as **faction badges**. They picked *contentless*
      warfronts icons and let usage supply the meaning — refinement 1's rule, executed by the
      people who own the client. The census flagged all five as CLAIMED, which validates it.
      **★ THE CATCH, AND IT IS A REAL ONE: the claim test is per-NAME, confusion is per-LOOK.**
      That death marker sits on **the same world map we are building on**, and our candidate
      `warfronts-fieldmapicons-empty-banner-minimap` is its sibling — *free in code, possibly
      near-identical in the eye*. A route node that reads as "someone died here" is precisely
      the failure law 10 exists to prevent. So: **within any family the fork has already mined,
      a visual check in the AtlasBrowser is MANDATORY before a pick, not optional.** Free is a
      shortlist, never a clearance.
      **Cleanest candidate on this test: `poi-lighthouse-neutral`** — "lighthouse" appears in
      **zero** client Lua/XML outside the registry, the feature is absent, and a lighthouse
      reads as *a fixed landmark you navigate by*, which is the meaning we actually want.
      Same zero-reference result for `embercourt`, `elementalstorm`, `scrapper`.
      **How to establish it cheaply:** the art survey is already a banked bench task (the
      gothic Necro/Reaper UI arc has `extract_interface.py --all-types` over `patch-A.MPQ` as
      its designed first step), so the inventory comes out mechanically rather than by
      eyeballing. The audit's valuable half remains the NEGATIVE one — catalogue what the
      client's own POI, minimap and quest systems have already spoken for, and the safe set
      is what is left.

### ★ ICONS — DECIDED (Battlewrath, 2026-08-12, after inspecting them in the AtlasBrowser)

He ran the mandatory visual check refinement 3 demands, and picked. **This closes law 10.**

**★ THE RULE — SPLIT BY CONTEXT, NOT BY ACTIVITY (Battlewrath, 2026-08-12).** *"I'd keep
landmarks stable. For the open world, they're the destination, not the activity. For the
dungeon use, they're stable notes of consideration for the waypoint. It might be tricky mobs.
The split is to avoid confusion."*

A landmark means a **different thing** in each context, so it gets a different symbol — and
within a context it never varies. Open world: *this is a place I am going to*. In dungeon:
*this is something to know about, attached to the route* — a caster pack, a patrol, a bad
pull. Same word, two jobs; one symbol each so neither borrows the other's meaning.

**This SUPERSEDES the icon-per-category idea** (§9 delta 3, mine): activity does not belong in
the marker symbol at all. It belongs in the sticker layer below, and the *meaning* belongs in
the note. Three marker symbols total, and the user never picks between them — context does.

| Context | Role | Atlas | His description | Registry |
|---|---|---|---|---|
| **Open world** (scrapbook) | landmark | `questbonusobjective-supertracked` | — | `AtlasInfo.lua:657` |
| **In dungeon** | landmark | `vignettekill-supertracked` | gold | `:651` |
| **In dungeon** | route waypoint | `vignettekill` | brown with silver | `:264` |

All three `interface\minimap\objecticonsatlas`, all **64×64**, all **free** in the census.
Tex-coords verified identical to the registry:

```xml
<!-- Open-world landmark -->
<Texture file="interface\minimap\objecticonsatlas">
    <Size x="64" y="64"/>
    <TexCoords left="0.77832" right="0.84082" top="0.12793" bottom="0.19043"/>
</Texture>
```

```xml
<!-- Route waypoint -->
<Texture file="interface\minimap\objecticonsatlas">
    <Size x="64" y="64"/>
    <TexCoords left="0.262695" right="0.325195" top="0.192383" bottom="0.254883"/>
</Texture>
<!-- Landmark -->
<Texture file="interface\minimap\objecticonsatlas">
    <Size x="64" y="64"/>
    <TexCoords left="0.456055" right="0.518555" top="0.192383" bottom="0.254883"/>
</Texture>
```

**The art is a compass rose in a ring** — it reads as *navigation* before anything is
explained, which is the ideal case for law 10: meaning inferred from the shape and our usage,
with nothing borrowed. Shape is shared between the two, **colour carries the role** — so the
pair reads as one system with two ranks, not two unrelated symbols. That is the calm-UI
principle applied to iconography.

**Why it is safe — three independent legs:**
1. **Mechanical.** All 21 entries of the `vignette*` family are unclaimed in the census.
2. **Feature-absent** (refinement 3). The only `vignette` strings in the entire client outside
   the registry are two **`SoundKit.lua` constants** — sound IDs, not wired to this art. The
   vignette system is absent wholesale, not merely unreferenced.
3. **Negative visual evidence.** Battlewrath captured the quest iconography this
   classic-leaning client *actually* uses (Azshara · W. Plaguelands · Tirisfal · Undercity ·
   Kalimdor): yellow `!`, numbered quest circles, X objective marks, skulls, portal swirls,
   dungeon-entrance chests, profession glyphs. **No vignette art appears anywhere in it.** The
   in-use language was established by looking, not assumed.

**★ THE BONUS — the pick lands a complete 2×2 rather than spending a state axis.** The family
ships in four-state sets (`base` · `-pressed` · `-supertracked` · `-pressed-supertracked`).
Reading `-supertracked` as *colour* rather than *state* splits one set cleanly into two roles,
each keeping its own press state:

| | resting | pressed |
|---|---|---|
| **waypoint** | `vignettekill` | `vignettekill-pressed` |
| **landmark** | `vignettekill-supertracked` | `vignettekill-pressed-supertracked` |

All four free, all 64×64, all on one sheet row (`top 0.192383 · bottom 0.254883`). Nothing is
owed. And if a *current-target* emphasis is ever wanted on top of that, **`vignettekillelite`
and `vignettekillboss` are two further complete four-state sets, also entirely free** — so the
supply is not tight and this decision does not corner a later one.

### ~~OPEN ITEM~~ → **CLOSED, ACCEPTED (Battlewrath, 2026-08-12)**

He opened the actual surface — the **Trials** and **Challenges** tabs — and ruled: *"I don't
think there would be user confusion from the asset use."* **`questbonusobjective-supertracked`
stands as the open-world landmark.**

The basis, from what those panels show: the claimed art appears as a **tiny inline glyph in a
row of condition markers** inside a scrolling list — alongside diamonds, stars, skulls, hearts.
Our use is a **64×64 pin on the world map**. Different size, different surface, different act.
Nothing carries across.

**★ WORTH RECORDING FOR ITSELF: the look-check has now fired in BOTH directions.** It *raised*
a risk the name-check missed (the warfronts death marker, same map surface) and it *cleared*
one the name-check flagged (this). That is what keeps `claimed` a filter rather than hardening
into a superstition — the census narrows the field, **eyes decide**, and eyes are allowed to
say yes.

<details><summary>The finding as originally raised (kept for the record)</summary>

`questbonusobjective-supertracked` is **free**, and his tex-coords match `AtlasInfo.lua:657`
exactly. But **the BASE of that set is CLAIMED**, and by something meaningful:

- `Ascension_ChallengesUI/.../ChallengeExtendedInfoMixin.lua:111` —
  `isPvE and "questbonusobjective" or "crossedflags"`, i.e. it is this client's **PvE
  indicator**
- `Ascension_ChallengesUI/.../ChallengeItemMixin.lua:463` — `SetNormalAtlas("questbonusobjective")`

Same sheet row as his pick (`top 0.127930 · bottom 0.190430`), so it is the **same artwork in
a different state** — refinement 3's *claim is per-NAME, confusion is per-LOOK* firing for the
second time.

**Assessed honestly, the risk here is LOW, and materially lower than the warfronts case:** that
claim lives in the **Challenges UI panel**, a different surface from the world map. A player
meets the shape in a challenge list, never while navigating. The death-marker collision we
avoided was on *the same map*. What remains true is that the shape now carries a faint **"PvE"**
association in this client. **Recorded so the decision is informed, not to reverse it** — he has
seen both in the browser and we have not.

</details>

11. **★★ THE PRODUCT THESIS — NOTES OF MEANING, NOT WHAT-WHERE (Battlewrath, 2026-08-12).**
    Verbatim: *"Gather-mate exists. PFquest exists. They all show per-entity spawn locations and
    drop locations. We might step into the same lookup, if we have the data to consume. But
    what we create is **notes of meaning, not what-where**."*

    **★ SHARPENED TO FIVE WORDS (Battlewrath, 2026-08-12): *"This is 'How I play', not what
    exists."*** That is the whole boundary, and it is better than the paragraph below it. *What
    exists* is a database question — per-entity spawn locations, drop tables, node coordinates —
    already answered by addons with far bigger records than we will ever hold. *How I play* is
    nobody's dataset. It is also why the store stays light: **regions of activity, not per-node
    tracking.**

    **This is the sharpest scope fence in the ledger and it is product-defining, not a detail.**
    The existing addons answer *where does thing X spawn* — an entity→location database,
    exhaustive, impersonal, and already built by people who did it well. We answer *why does
    this place matter **to you***. Those are different products that happen to share a map.

    **Two distinct claims, and keeping them distinct is the whole point:**
    - **We never AUTHOR a what-where database.** Not a node list, not a spawn table, not a
      drop index. This is what "indicators, not per-entity nodes" was already protecting, now
      stated as the reason rather than the rule.
    - **We MAY CONSUME one** — *"if we have the data to consume"*. That is the
      [[consumer-contract-pattern]] again, the same move as MancerLedger over its driver:
      let the people who own that data own it, read it under a contract, and add the layer
      they do not provide. **A door left open, not a plan.**

    **Why it matters beyond scoping:** it answers the §8 gate's second stopper
    (*"it may be over-engineering"*) before it is asked. We are not competing with GatherMate;
    we are not duplicating pfQuest. Nobody is building the meaning layer.

12. **★ ARRIVING IS SILENT (Battlewrath, 2026-08-12).** Verbatim: *"Arriving should be silent.
    They've actively moved towards there. They don't need telling what they've pursued the
    journey to perform."*

    **Notes are PULLED, never PUSHED** — in the open world. You read a note by hovering its
    pin (F15's `WorldMapTooltip`), because you asked. Nothing announces itself on approach.

    **★ AND THE CLIENT ALREADY DOES THIS — see F21.** `NavigationState.InRadius` maps to beacon
    alpha **0.1**: reach the target and the beacon fades itself to near-nothing. We inherit the
    behaviour rather than implement it, which is the third time this arc has found the client
    already holding the answer.

    **Scope, stated so it does not over-reach:** this governs the **open world**. Law 9's
    proximity-drives-personal-notes was written for **in-dungeon** notebooking, where you did
    *not* come deliberately — you are following someone's route and the note is a warning you
    could not have asked for. Same split as the icons: context decides. Not a contradiction.

    **Left open, small:** the client's own convention (F21) is quiet-in-the-world **plus** a
    small UI acknowledgement (`WatchFrame.lua:179` flashes a tracker icon on `InRadius`).
    Whether we want that quiet acknowledgement is a separate question from whether arrival
    shouts. Not decided.

13. **★★ WE DO NOT COMPETE FOR THE BEACON — LAST EXPLICIT USER ACTION WINS (Battlewrath,
    2026-08-12).** Verbatim: *"We expect to be over-written and do not compete. They select a
    quest, quest wins. They select a marker they made for them self, that wins. The widget can
    carry the last selected location to re-pin, but that's an over-write, not a race."*

    **★ HONOURING THIS TAKES ACTIVE WORK, because the client implements the OPPOSITE.** F24's
    ladder is **fixed precedence by type, not recency**, and `SUPER_TRACKED_POSITION` is tested
    *above* quest selection. So once our position is set it wins **every** re-evaluation: the
    user selects a quest, the existing `SelectQuestLogEntry` hook re-runs the ladder, our
    position is still set, **Position wins again** and their selection has no effect. Nothing
    in normal play clears that global. **Passivity does not make us lose gracefully — it makes
    us win, silently and indefinitely.**

    **So the mechanism is to YIELD:** clear `SUPER_TRACKED_POSITION` when the user picks a
    quest and let the ladder fall through to Quest. Deliberate, and the opposite of the
    set-it-and-leave-it instinct.

    **No re-assert, ever.** The widget holds the last pinned location so re-pinning is one
    click — *"an over-write, not a race"*. Re-pinning is always a user act; we never reclaim
    the slot on our own.

    **★ SESSION SCOPE — the beacon does NOT persist across login (Battlewrath):** *"dropping it
    on log-in is fine. Last session's goals doesn't mean the player is still pursuing that."*
    **This DELETES work rather than adding it** and supersedes F24's consequence ③: there is no
    restore logic, because there is nothing to restore. The widget's remembered location does
    persist — the *beacon* does not. It also disarms the login trap outright: the client's
    programmatic `SelectQuestLogEntry` on `PLAYER_ENTERING_WORLD` has no pin to drop.

    **OPEN, small, and the only survivor of that trap — `QUEST_TURNED_IN`.** `QuestFrame.lua:27`
    runs `SuperTrackerUtil.UpdateSelectedQuest` on turn-in, which calls `SelectQuestLogEntry`
    **unconditionally** (re-selecting the same quest still calls it). So a naive yield-hook
    drops the user's pin **every time they hand in a quest**, which no user performed as a
    choice. Quest *accept* needs no special case — taking a quest reads as an explicit act of
    pursuing it, so yielding there is correct. Two ways to settle turn-in, his call in the AC
    document: **(a) accept it** — turn-in is quest-flow activity, zero mechanism; or **(b) yield
    only when the selected questID actually CHANGED** — change detection, not intent detection,
    so it stays mechanical and invents nothing.

14. **★★ ARRIVAL IS PER-LANDMARK AND USER-DEFINED, AND ARRIVAL ALWAYS WIPES (Battlewrath,
    2026-08-12).** *"Maybe we can let that be user defined, per landmark… Then we always wipe.
    And the widget gives them an easy re-click to re-find, as it holds the last selected
    landmark per session."*

    | Tier | Radius | Means |
    |---|---|---|
    | **Zone area** | **300 yd** | you are in the right part of the zone |
    | **Within sight** *(he flagged this as misnamed — "within approach"?)* | **100 yd** | you are closing on it |
    | **Interact with** | **5 yd** | you are at it |

    **Why per-landmark rather than one global rule:** "arrived" is not one distance. A farm
    circuit is *somewhere around here*; a vendor is *at the NPC*. A single threshold would be
    wrong for one of them by design.

    **This completes the slot discipline** begun in law 13: **occupy on an explicit pin ·
    release on arrival · never reclaim.** We hold the supertrack only for the duration of a
    deliberate errand and hand it straight back — a stronger form of *do not compete* than
    yielding, because we are rarely still holding it when a quest selection happens. It also
    composes with law 12: the beacon quietly retiring itself **is** the silence.

    **★ MECHANISM CORRECTION — use `distance`, NOT `InRadius`.** I had proposed detecting
    arrival from `NavigationState.InRadius` (F21). Wrong for this: `InRadius` is the **engine's
    own** notion of proximity and its radius is not ours to set, so it cannot carry a
    per-landmark tier. The right source is the **third return of
    `C_SuperTrack.GetSuperTrackedPosition()` — an engine-computed distance in yards** (F10
    verified the unit: a 50 yd leg computed 49.7). Poll it, compare against the landmark's
    stored tier. Mechanical, no invention. `InRadius` remains what it was — the engine's fade
    signal — and stays out of our logic.

    **★★ MANDATORY GUARD — ARRIVAL IS GATED ON *STATE*, NOT DISTANCE (F38).** The engine
    reports a refusal as **`sd = 0.00` with `NavigationState.Invalid`**, while still claiming to
    track. Distance alone therefore fires *arrived* the moment a player zones into any instance.
    **Acceptance criterion for the AC document, not an implementation note:**

    > Arrival requires `C_SuperTrack.GetTargetState() ~= Enum.NavigationState.Invalid`
    > **and** the tier comparison. A zero distance without a valid state is a REFUSAL.

    A natural second invariant, cheap and meaningful in its own right: **the player's current
    mapID must equal the landmark's** — you cannot have arrived at a landmark on another map.

    **★ RESOLVED BY THE PROBE (2026-08-12): the tiers are SAFE.** F28 — `distance` is **3D**, so
    vertical separation counts and a floor above does not read as arrived. F31 — the engine's
    own arrival radius brackets to **5.37–5.73 yd**, so the `Interact with` tier he picked at
    5 yd is the engine's own opinion of *you are here*. F29 — distance survives the target going
    off-screen, so the wipe fires regardless of camera. The paragraph below is kept because it
    is why the probe was run.

    **★ THIS PROMOTED §7'S 3D-vs-2D QUESTION FROM ACADEMIC TO LOAD-BEARING.** At 300 yd the
    difference is noise. **At 5 yd it decides correctness**: a 2D distance says *arrived* when
    the vendor is on the floor above you; a 3D distance says *not yet* when you are standing
    next to them and the stored z was slightly off. The `Interact with` tier cannot be trusted
    until we know which we are getting — so that probe is now a prerequisite for the tightest
    tier, not a curiosity.

    **Session scope, consistent with law 13:** the widget holds the **last selected landmark
    per session** for one-click re-pin. Persists within the session, gone at login.

    **No mechanism needed for "never arrives":** abandon the errand and the beacon simply
    stays until the user pins something else, selects a quest, or logs out. Nothing to build.

    **OPEN — where the tier gets SET.** Walk stop 1 fixed capture as asking *nothing*, so a
    tier cannot be chosen at capture. It therefore needs a **default** plus an edit in
    curation. Two candidates, undecided: a fixed default (middle tier), or **the sticker
    implies it** (vendor → interact, farm → zone area), which would encode the rule and remove
    a decision — but is inference, and inference makes plausible wrongs. His call.

15. **★ OUR SURFACES ARE THE BEACON AND THE WORLD-MAP PIN. THE MINIMAP IS OUT OF SCOPE
    (Battlewrath, 2026-08-12).** *"So far we've only shown interest in the beacon and a
    co-ordinate. The mini-map is noisy and we'd be adding to the noise."*

    **It also follows from law 12.** The beacon shows **one** target the user deliberately
    chose, and retires itself on arrival (law 14). A minimap layer would show **every** landmark
    passively, all the time — an ambient push channel, which is exactly what law 12 rules out.
    Not merely taste: the same principle.

    **Consequence:** `Minimap_UpdateSuperTrackPOI` and its 233-unit cull (§2, F14) stay
    *background facts about the client*, not inputs to our design. Do not reach for them as
    corroboration.

16. **★★ BEYOND BEACON RANGE, THE MAP IS THE INSTRUMENT — WE ADD NOTHING (Battlewrath,
    2026-08-12).** *"Outside of 1.5k is back to pen and paper. They can see it on the map.
    They've been there before."*

    **The two instruments carry different sentences, and neither needs helping:**
    - **The beacon** says *"it is exactly HERE"* — and only inside 1,500 yd, where that claim
      is worth making.
    - **The map landmark** says *"this zone, this area"* — which is the whole of what long
      range needs, because **the player has been there before**. That is the premise of a
      scrapbook: you are not being guided somewhere new, you are being reminded of somewhere
      known.

    **★ THIS CLOSES F35'S GAP BY DECLINING TO FILL IT, and DELETES three things** we had
    reason to build: the long-range distance readout, "surface the zone needed" logic, and any
    cross-zone fallback UI. F35 proved we *could* state *"Winterspring — 3,700 yd"*. Law 16
    says we should not — capability is not a reason.

    **Consequence for the machinery:** distance is polled for **arrival only** (law 14), never
    for display. Since the widest tier is 300 yd, everything beyond that is a cheap comparison
    against a number nobody sees. The beacon renders its own readout inside its own range
    (F12); we still build no pointer and now no readout either.

    ### The widget — first concrete UI, specified in full

    ```
    Landmark name
    Zone                 [Map]   <- red; shown when the BEACON CANNOT GUIDE
    [repin] [clear]
    [make marker]
    ```

    Two lines and three buttons — plus one conditional indicator.

    **★ THE `[Map]` INDICATOR (Battlewrath, 2026-08-12) — the last hole in the widget's
    honesty.** *"The only edge case I can foresee is when I want to go to a marker that's in
    Eastern Kingdoms, and I'm in Kalimdor. We have the widget and the zone. We could add
    `[Map]` in red when it doesn't match. Hides when it does."*

    Without it the widget **lies by omission**: you click `repin`, nothing happens, and nothing
    explains why.

    **★ THE CONDITION IS "THE BEACON CANNOT GUIDE", NOT "THE MAPS DIFFER" (Battlewrath,
    2026-08-12):** *"Being in-zone, but beyond 1.5k yards is possible. So a quick heading check
    is useful."* A first draft keyed it to the mapID mismatch alone, which was **narrower than
    this law** — *beyond beacon range* plainly includes **same map, past 1,500 yd**. **Two
    triggers, one handoff:**

    | Trigger | Cause | `repin` still worth doing? |
    |---|---|---|
    | landmark's `mapID` ≠ player's | the engine **refuses** (F38) | **No** — nothing will happen |
    | same map, `distance > 1500` | the **client's own alpha cut** (F22, F35: the engine is still tracking and still returning true distance) | **Yes** — and the beacon lights up by itself on approach |

    **★ The second case is TEMPORARY AND SELF-RESOLVING, and that is a behaviour we get for
    free:** pin it, travel, and the beacon appears once you are inside 1,500 yd. `[Map]` there
    means *you cannot see the beacon **yet***, not *this will not work*. Recorded so nobody
    later "fixes" the disappearing button.

    Both cases are read from state we already hold — the landmark's `mapID`, the player's, and
    the distance we poll anyway. Nothing new is stored.

    - **Self-hiding.** Present only when it is saying something; invisible the rest of the time.
      Zero noise by construction.
    - **It is law 16's HANDOFF, not an exception to it.** `[Map]` says *the beacon cannot carry
      this one — the map can*, which is the same sentence law 16 already speaks, delivered at
      the moment it becomes relevant.
    - **It covers the instance case for free** (law 17). Walk into Ragefire with a Kalimdor
      landmark held and the maps differ, so the indicator appears. No extra logic.
    - **It is not a warning, and law 17 still holds.** A warning is pushed at you; this is a
      label on a widget you are only looking at because you care. The distinction is stated so
      the two laws do not read as contradictory.

    **DECIDED (Battlewrath): it is a BUTTON that opens the world map to that landmark's zone.**
    One click on the instrument law 16 already names, at the exact moment the player wants it.
    His reason generalises past this button — see **law 18**.

    **Small note on the colour:** red in this client's language means *unavailable*, which is
    accurate here — the beacon genuinely is. Recorded because law 10 governs colour as well as
    shape, and this passes. **Name and zone, not coordinates and not distance** — "this
    zone, this area", the same sentence the map pin speaks.

    - **`make marker`** is walk stop 1's widget affordance: captures where you stand, asks
      nothing (law 4).
    - **`repin`** re-applies the landmark the widget is holding. This is law 13's *"an
      over-write, not a race"* — always a user act, never a reclaim.
    - **`clear`** hands the slot back deliberately, the same release arrival performs (law 14).
    - The widget keeps showing its landmark **after** the beacon is gone — whether arrival
      wiped it or a quest selection took the slot — which is exactly what makes one-click
      re-pinning the answer to contention rather than priority-fighting.

    **Detail for the AC document, not decided:** we capture both `GetRealZoneText` and
    `GetSubZoneText` (the probe records both). Whether the `Zone` line shows the zone, or the
    subzone when one exists (*"Winterspring — Everlook"*), is a one-line choice with real
    effect on a vendor pin.

17. **★★ ATTENTION IS THE ARBITER — the question that keeps producing the simplest answer
    (Battlewrath, across 2026-08-12).** Not a new rule so much as the one underneath laws 12,
    13, 14 and 16, named because it has now settled three separate problems and each time the
    answer was **do less**:

    | Problem | The question | The answer it produced |
    |---|---|---|
    | Beacon slot contention with quests | *is someone mid-quest also hunting their vendor?* | No — different modes, they take turns. The contention window barely exists (law 13) |
    | What happens on arrival | *do they need telling they got where they walked to?* | No — arriving is silent (law 12) |
    | Entering an instance | *is their attention still on the landmark?* | No — so preserve nothing (below) |

    **★ EVIDENCED BY USE, 2026-08-12 — it is no longer reasoning.** Battlewrath, after playing
    with v0.1.3: *"If I'm digging into my quest log, that's on my mind. And re-pin makes it
    cheap to re-anchor if I was just being curious."*

    **The pairing is the point: the yield can be EAGER precisely because RECOVERY IS ONE
    CLICK.** Neither half works alone — an eager yield with expensive recovery would grate, and
    a reluctant yield would block the player's quest arrow indefinitely (F24). Law 13 stated
    this from the contention side (*"an over-write, not a race"*); this is the same thing from
    the player's side, and it is why AC-11's widget must keep holding the landmark after the
    beacon is gone. **That criterion is not convenience — it is what buys the yield its
    licence.**

    **The instance ruling (his words):** *"If I'm entering an instance, my attention is not on
    the landmark any more. And if something inside the instance needs the marker (like our
    later addon), it'll over-write. Then the user re-pins when it has their attention again."*

    **★ So on a map-boundary REFUSAL (F38), we do NOTHING.** Not a mechanism — the deliberate
    absence of three:
    - **Do not fire arrival.** That is the F38 state guard on law 14, and the only code this
      case needs.
    - **Do not clear the slot.** A refusal is not an errand completed. Clearing would be us
      deciding on the player's behalf that they are done.
    - **Do not warn, restore, or re-pin.** The beacon is simply dark, the widget still holds
      the landmark, and one click brings it back when attention returns.

    **★ AND IT SPECIFIES THE TWO ADDONS' RELATIONSHIP, which is: none.** The route follower
    contends for the slot exactly like a quest does — last explicit user action wins (law 13).
    Our own later product gets no privileged access to our own pin. That is the correct
    outcome and it needs no coordination layer between them.

18. **★★ BEHAVIOURAL, NOT INSTRUCTIONAL — and what is actually lost (Battlewrath,
    2026-08-12).** *"Drives the fix to be behavioural rather than instructional. Players know
    how to get to places. It's just the meaning and why and exactly where that gets lost."*

    **The test, applicable to any feature we ever propose: does it DO the thing, or does it
    TELL the player to do the thing?** `[Map]` opens the map. A red label reading *"different
    continent — check your map"* would be instructional, and worse: it spends the player's
    attention to hand them a chore.

    **★ AND IT NAMES WHAT THE PRODUCT ACTUALLY RESTORES.** Four things are in play when
    someone wants to get back to a place they know. **We own three of them, and the fourth is
    not our problem:**

    | What is lost | Our instrument |
    |---|---|
    | **Meaning — why this place matters** | the note, pulled on hover (law 12) |
    | **Exactly where** | the beacon, inside 1,500 yd (F35) |
    | **Which zone, roughly where** | the map pin, and the widget's `Zone` line |
    | ~~How to travel there~~ | **not ours — players already know.** This is why law 16 works: we are not a travel aid |

    That accounting is complete, and it is why the design keeps coming out small. It also
    restates law 11 from the other side: *notes of meaning, not what-where* said what we
    **make**; this says what the player has actually **lost**, which is the same boundary
    approached from the player rather than from the market.

    **Retroactively it explains choices already made** — capture asks nothing rather than
    prompting you (law 4) · arriving is silent rather than announcing (law 12) · every widget
    control performs an act rather than describing one · and there is no tutorial text anywhere
    in the design.

19. **★ WE PROVIDE THE DEFAULT; THEY PICK FROM A PALETTE WE CURATE — AND THE ICON IS
    PRESENTATION ONLY (Battlewrath, 2026-08-12).** *"We provide the default. They can pick from
    a selection of alternatives we've curated (non-conflicting with already formed norms /
    signal use). Then it's just a change on what is rendered."*

    **Three parts, and the third is the one that protects the design:**
    1. **Context sets the default** — law 10's split, which is what you get without choosing.
    2. **We curate the alternatives.** The palette is *our* responsibility, and every entry
       passes law 10's claim test against `addons/maps/atlas/` before it ships. The user picks
       from a safe set; they are never asked to judge whether an icon is free.
    3. **★ NOTHING KEYS OFF THE ICON.** Changing it changes **only what is drawn**. No
       behaviour, no filtering, no defaulting, no sorting may depend on which icon a landmark
       carries — the `Beacon hide` tier is already explicitly *not* implied by it, and that is
       the general rule rather than a one-off.

    **Why (3) is worth stating as law:** *"farm icons should set the farm tier"* and *"group the
    map by icon"* both sound like helpfulness and are both inference [see
    `pipeline-emits-class-knowledge-curates`]. An icon the user chose for how it **looks** would
    start deciding how the addon **behaves**, and a wrong-looking pick would silently become a
    wrong-acting one.

    **Scope:** this build ships the **open-world** palette only. The in-dungeon icons are left
    alone for now (they belong to the route half) — **but the principle applies there
    unchanged.**

## 5.9 ★★★ THE EXPORT PATH IS WHERE THE SAFETY LANDS

_Reasoning only — **not a spec, and not scheduled.** Battlewrath, 2026-08-16: *"Not build yet.
Document for sure. But we're not up to that part of the dev cycle. I think also on the exporter,
we can kill a lot of these concerns."*_

The concerns are the model's: **a route is a document from a stranger**, and text in it reaches
sinks on the runner's machine. The model states the rule; this is where the mechanism would live.

### ★★ What the EXPORTER genuinely kills

**It enumerates what crosses the boundary.** A route in `SavedVariables` is whatever the addon
happens to store; a route in an export is exactly the fields the exporter wrote. So the attack
surface stops being *"the route table"* and becomes **a listed set of typed fields** — a different
size of problem, and one that SHRINKS when the format is tightened rather than growing every time
the addon does.

### ⚠⚠ THE CLIENT HAS NO ENCODER — it is a LIBRARY STACK, and that is a dependency

> *"Wow has it's own encoder I believe. So that's not something we have to build."*

★ Half right, and the half that is wrong changes a decision, so it is read from source rather
than taken. **3.3.5 has nothing native**: no `C_EncodingUtil`, no `EncodeBase64`, nothing that
serialises a table. Grepped across every installed addon — zero hits.

**What WeakAuras actually does** (`Transmission.lua`, the real share path):

    AceSerializer-3.0     table  -> string
    LibDeflate            CompressDeflate
    LibDeflate            EncodeForPrint            (a copyable string)
                          EncodeForWoWAddonChannel  (an addon-channel string)
    and back the same way, with LibCompress:Decompress kept for OLD strings

★★ **So we would not build an encoder — we would take a DEPENDENCY.** That is still a saving, and
it is a different kind of decision from *"the client provides it"*.

⚠⚠ **AND THE DEPENDENCY IS NOT GUARANTEED TO BE THERE.** WeakAuras does not embed these; `Init.lua`
lists them under `LibStubLibs` and takes whatever LibStub happens to hold. On this machine they
exist only because OTHER addons ship them — `LibDeflate` in three copies, inside
`AscensionLogsCompanion` and elsewhere; `LibCompress` inside `Skada`.

★★★ **The tell: `LibSerialize` is referenced by WeakAuras and is NOT INSTALLED AT ALL.** Zero
copies on this client. WA calls `LibStub("LibSerialize")` in its aura-environment code and the
library simply is not there — which is exactly the failure mode we would inherit by assuming.

### ★ There IS a lite version — and knowing which half it covers is the useful part

> *"I think they package a lite version."*

**True, and it is the READ half.** `Transmission.lua` inlines its own `decodeB64` with a 64-entry
table — *"based on the Encode7Bit algorithm from LibCompress, credit to Galmok"* — about sixty
lines, no dependency. ⚠ But it exists to read OLD strings. The live encode path is still
AceSerializer + LibDeflate through LibStub.

### ★★★ DECIDED — our own serializer, a lite encoder, and borrow where we can

> *"Not worth drilling into. We can build a specific serializer and a lite encoder for compression
> (Borrow where possible, we don't need to solve every problem new.)"*

**Which makes the whole dependency question moot for us**, and that is why it is the right call
rather than a shortcut: a route has a schema WE define, so a general serialiser was always the
wrong tool. The positional form is smaller, faster, cannot express an unknown field, and takes
nothing from LibStub.

★ **Borrow where possible** — `decodeB64`'s sixty lines are credited to Galmok and sitting in
`Transmission.lua`; the algorithms are known and public. We are not inventing base64.

### ★★★ THE DONOR PARTS EXIST — `Weak Auras/weakaura_codec.py`, in this repo

> *"If you want a cheap fix. Check out the weak aura bench. We constructed our own export tool
> using donor parts of WA and the Lua emulator."*

⚠ **Cross-bench REFERENCE, not responsibility.** That file is the aura bench's; this is a pointer
and a reading, and nothing here edits or documents their lane.

**What it is:** a standalone, dependency-free port of WeakAuras' real pipeline —
`"!WA:2!" + EncodeForPrint(CompressDeflate(LibSerialize.Serialize(table)))` — in pure stdlib
(`zlib`, `struct`). `EncodeForPrint`/`DecodeForPrint` are ported **byte-for-byte from the
installed `LibDeflate.lua`**; DEFLATE is standard so `zlib` in raw mode interoperates.

★★ **What we can actually borrow, given we are not adopting WA's format:**

    encode_for_print / decode_for_print   the 6-bit printable encoding, proven both ways
    _assert_full_pipeline_round_trip      the round-trip self-test - §165's `unpackage(package(x))
                                          == x` already exists there, written before I proposed it
    the method                            port from the installed source, then LIVE-TEST the
                                          string in-game rather than trusting the round trip

⚠ **What does not transfer:** theirs is Python, offline-authored and pasted in by a human. Ours is
Lua↔Lua, in-game both ends. The algorithms and the confidence transfer; the code does not.

★ **And one finding of theirs bears directly on our store:** hand-editing WeakAuras'
`SavedVariables` was tested and does NOT work — an entry that did not come through the addon's own
import path is silently dropped and overwritten on next save. **The addon does not trust its own
saved file.** Worth holding when we decide what our store guarantees.

### ★★★ WE OWN BOTH ENDS — so the round trip runs IN-GAME, unattended

> *"We can do in-game round trips because we own both parts."*

★★ **That is the thing the aura bench could not have.** They author in Python and WeakAuras
consumes in-game, so every validation was a HUMAN PASTING A STRING AND LOOKING — one direction,
one string, one pair of eyes, and their own header records the encode side sitting *"not yet
live-tested"* until someone did it by hand.

**Our recorder packages and our driver unpackages, and both are our Lua on the same client.** So:

    package(route) -> unpackage -> compare      in Lua, in the game, in one command

No paste, no external tool, no eyeball. ★ And as a `COA_DevDump` task it lands in the record with
provenance, so a pass is EVIDENCE rather than a memory of having checked.

★★★ **And it runs against REAL ROUTES, not fixtures.** Every route in the store is a test case —
which is the difference between proving the codec agrees with itself and proving it survives the
data we actually make. Same argument as the user-story walks: **the walk proves the joins.**

⚠ **Two round trips, and they answer different questions:**

    offline   `.tools/lua51`, in the smoke suite, no client   -> does the code agree with itself
    in-game   a DevDump task, over the real store             -> does it agree with the CLIENT

★ The offline one is fast and runs on every commit. The in-game one is the only one that can
catch a Lua-version difference, a number that stopped being an integer somewhere, or a string the
client's own encoding will not carry — and it is available to us on demand, which is the whole
gift of owning both ends.

### ★★★ AND IT ANSWERS §170's UNRESOLVED — the other bench hit it first

The missing-library contradiction I could not settle is written up in that file's header, dated
2026-07-02:

> *"…still confirmed absent as loose files… only LibStub, LibDeflate, and LibCustomGlow are
> bundled via Archivist — whatever the actual mechanism, Export demonstrably works on this client,
> so Transmission.lua is not short-circuiting the way `IsLibsOK()` being false would imply."*

★★ **Same question, same absence, and a better resolution than mine: they answered it by
OBSERVATION.** Export works, therefore the theory is wrong somewhere, therefore the mechanism does
not matter. I was trying to read my way to it.

⚠⚠ **AND I SPENT FOUR SEARCHES ON THE CLIENT FOR SOMETHING WRITTEN DOWN IN THIS REPO.** The rule
is the bench's oldest — *search our own basis before calling something unverified* — and I applied
it to the game client while not applying it to us. ★ The basis is not only the code; it is the
other benches' findings, in the same tree.
### ⚠ ONE THING LEFT UNRESOLVED, AND SAID RATHER THAN GUESSED AT

`Init.lua` does not LOAD those thirteen libraries — it **checks** them, and any miss sets
`libsAreOk = false`. Every options file then opens `if not WeakAuras.IsLibsOK() then return end`.

⚠⚠ **`LibSerialize` is in that list and nothing on this client provides it** — verified by content
search, not by filename this time. So the check should fail and the options UI should be dead.
**It plainly is not** — the screenshots of 2026-08-16 show it working.

★ **So something about how this fork loads is not understood, and that is the honest state.** Four
searches were spent on it and each one was the wrong instrument — directory heuristic, then depth
limit, then filename, then a literal `NewLibrary("…")` when libraries pass a variable. ⚠ A fifth
theory would be worth less than the admission. It does not block anything: the decision above
removes our need for the answer.

### ⚠⚠ CORRECTION — WeakAuras DOES ship LibDeflate. My search was too shallow twice over.

I wrote that exactly one addon on this client provides the encode libraries, and that WeakAuras'
sharing was one uninstall from breaking. **Battlewrath challenged it on a fact I could not have
known and should have asked for:** *"I only installed that 2 days ago."* Sharing plainly worked
before Tuesday, so the claim had to be wrong.

**A full recursive search — no directory heuristic, no depth limit:**

    LibDeflate        AscensionLogsCompanion · TurboPlates · WeakAuras/Libs/Archivist/libs/
    AceSerializer     AscensionLogsCompanion · PlateBuffs · Recount · Skada · TurboPlates
    LibCompress       Skada

★★★ **WeakAuras ships LibDeflate inside Archivist**, and `Archivist.xml` loads it:
`<Script file="libs\LibDeflate\LibDeflate.lua"/>`. So `embeds.xml` being two lines long meant
nothing — **an include tree has depth, and I read the first level and treated it as the whole.**
The same shape as the search: I stopped at the first layer and reported the result as the fact.

⚠ **What survives the correction:** WeakAuras still carries no AceSerializer of its own — zero
copies under `WeakAuras/` — so that half genuinely does come from LibStub, provided by whichever
of five other addons a player happens to have. ★ Five providers is a very different risk from
one, and *LibStub and hope* is a weaker worry than I made it, not a dead one.

### ★★★ And our payload does not need a general serialiser at all

AceSerializer exists because an aura is an **arbitrary table of unknown shape** — WA cannot know
what a user's custom code hung on it. **A route is not that.** We define the schema; §165's
`package`/`unpackage` pair already enumerates every field.

★★ So a **positional format** — fields written in a known order — is smaller and faster than a
general serialiser, and it carries the same property the rest of this design leans on: **an
unknown field cannot be expressed**. There is no key to smuggle one in under. *Construct, don't
adopt*, made structural rather than enforced.

⚠ Which leaves compression as the only genuine dependency question, and it is optional — a route
is small. ★ The choice when this is built:

    inline, positional, no libs     always works, smallest surface, our own format
    LibDeflate when present         shorter strings for big routes, and a fallback path to write
    LibStub and hope                fails SILENTLY AND LATE, on someone else's machine, at the
                                    moment they try to share

★ Not decided here. But the third option is now known to be the one WeakAuras itself is exposed
to on this very install.

### ★★ It is the client's established model, and we already run one half of it

> *"It's the same model weak auras use. The only way to share a aura is via a export string. (Bar
> giving over your whole saved variables files.) Even our weak aura bench uploads to my client
> that way."*

★ **So the one-door design is not a proposal, it is the practice** — on the addon with the largest
user base on this client, for years, with no second path. ⚠ The only alternative anyone actually
uses is handing over a whole `SavedVariables` file, which is the unsafe fallback the string
exists to make unnecessary. **A share mechanism that is not good enough gets routed around**, and
what it gets routed around by is worse than anything it was protecting against.

★★★ **AND WE ARE ALREADY ON THE OTHER SIDE OF THIS BOUNDARY.** The aura bench emits import strings
that his client consumes — so from WeakAuras' point of view **our own pipeline is an untrusted
document producer**, and WA applies to us exactly the posture we are designing here.

⚠ Which is the useful way to hold it: not *"how do we defend against a hostile author"* but
*"what does a careful consumer do with our output"* — a question we can answer by watching what
the client already does with ours, from the side we are on today.

### ★★★ ONE DOOR — a single package / unpackage pair, and EVERYTHING uses it

> *"Import covers them all. We'll have one package function and unpackage. Everything uses it.
> Even pulling between your own Dungeon_run and Dungeon_route addons."*

⚠ I had raised the risk that *"a paste, a party sync or a file drop"* would open a second door and
inherit the obligation. **There is no second door.** A route moves in exactly one way, so the
boundary is not a rule anybody has to remember — it is the only path that exists.

★★★ **And the sharp part is that our OWN addons use it.** The recorder and the driver do not share
a table or reach into each other's saved variables; they exchange packages. Three consequences
that are worth more than the tidiness:

**1. The driver has no trusted path at all.** It only ever unpackages. There is no fast lane for
*"this one came from our recorder"* — so there is no special case to get wrong, and no drift
between the checked route and the convenient one. ★ The most dangerous input is the one that
arrives by a path nobody thought of as input; here every path is input.

**2. The two addons can ship apart.** The package carries the format version and `unpackage`
refuses one it does not know — which is what lets a recorder and a driver be updated on different
days without either guessing about the other.

**3. ⚠ It makes §161's field-list check EXECUTABLE, and subsumes it.** I proposed testing that the
exporter's and importer's field lists agree. With one pair, the real test is stronger and simpler:

    unpackage(package(route)) == route      for every field, every kind of point

★★ **A round trip is the agreement.** A field the packer writes and the unpacker ignores dies in
the round trip and the test says so; a field that arrives with nowhere to land never comes back.
One property, and it holds the whole contract — including the parts nobody remembered to list.

### ★★★ BOTH ENDS WORK ON ZERO-TRUST

> *"Both the exporter and the importer work on zero-trust."*

★ **The importer's reason is obvious and the exporter's is not**, which is why it is worth writing
down rather than assuming symmetry for its own sake:

| | it must not trust | because |
|---|---|---|
| **importer** | the document | a stranger wrote it, and did not use our exporter |
| **exporter** | **our own store** | `SavedVariables` is a Lua file on disk. A user can edit it, another addon can write into it, and — the sharp one — **a route we IMPORTED is sitting in it** |

⚠⚠ **RE-EXPORT LAUNDERING is the case that decides it.** Someone shares a hostile route; it lands
in our store; a runner later shares it on. Without zero-trust on the way out, **we hand it to the
next person with our name on it** — and the second victim has more reason to trust it than the
first did. ★ An exporter that trusts local data is a laundering machine, however careful the
importer was.

★★ **So it is one field list used twice, in opposite directions.** Both sides CONSTRUCT rather
than adopt; neither trusts what it is handed. ⚠ And that makes it checkable: **the two field
lists must agree**, and a test can say so — a field the exporter writes and the importer never
reads is data that silently dies in transit, and the reverse is a field arriving with nowhere to
land.

### ⚠ What it cannot kill on its own

**A hostile author does not use our exporter.** They write the string by hand. So sanitising on
the way OUT protects the sender's neighbours and nobody else — the guarantee has to be made where
the document is READ.

### ★★★ And the shape of the answer is his own `/say` move, one layer up

    /say      the author supplies a MESSAGE   ·   the command is ours
    import    the document supplies VALUES    ·   the object is ours

**The importer builds a new route field by field from the payload — it never adopts the payload.**
An unknown field is not rejected, it is simply never read, and a field of the wrong type never
reaches the object at all. ★ Improper by construction again: nothing to validate, because nothing
unlisted has anywhere to land.

⚠ Which leaves exactly one job that is genuinely validation rather than construction: **strings
still arrive as strings**, and a name is still rendered. `|c`, `|T` and `|H…|h` are the live hole,
and the RENDER is where they close — whatever the transport does.

## 5.10 ★★★ THE EXPORT / IMPORT LIFE CYCLE — SCOPED

_The settled ground from the 2026-08-16 pass, in the form it would be picked up in. **Not a build
plan and not scheduled** — a scope, so that when the dev cycle reaches it nobody re-argues what is
already decided._

### ★★★ TWO ADDONS, TWO FORMATS — and this is the shape everything else hangs off

> *"Dungeon_Runs carries only the full construction, we'd rebuild from a import string to the full
> construction so we can edit it. Similar to how WA handled old versions. Dungeon_route carries
> only the flat format."*

    Dungeon_Runs   the FULL CONSTRUCTION   rich, editable, ours alone
    the wire        the FLAT FORMAT        what a package contains
    Dungeon_route  the FLAT FORMAT         consumed directly, never reconstructed

★★ **So the flat form is the contract, not a serialisation of the editor's structure.** The driver
eats it as-is. The editor REBUILDS the full construction from it — the same move WeakAuras makes
for old versions (`Modernize.lua`).

⚠⚠ **AND THAT CHANGES THE ROUND-TRIP TEST, which I had as one property.** It is two, and only one
of them is identity:

    driver   flat -> flat            IDENTITY. Byte-for-byte, or the transport is broken.
    editor   full -> flat -> full'   EQUIVALENCE. full' must be EDITABLE and mean the same;
                                     it will not be byte-identical and must not be asserted so.

★ Which also names the real risk of the flat form: **anything the editor needs and flat does not
carry cannot be rebuilt.** That is the thing to check when the field list is drawn — not "does it
round-trip" but "can it be EDITED after a round trip".

### ★★ TRANSPORT — party sync, opt-in, and the negotiation is human

> *"I think party sync. Opt in. And we only join a machine channel when a user hits sync. They all
> have to hit it, or we have a probe on dungeon join. BUT. There is always a negotation at some
> point, as a route has to be selected. Most likely the tank picks. But we it to comms. And import
> via copy is valid. But seen as more friction which kills in-game fluidity."*

| | |
|---|---|
| **in scope** | party sync. A channel is joined **only when a user hits sync** — never on load |
| **discovery** | everyone hits it, or a probe on dungeon join. Open which |
| **paste** | stays valid, and is the fallback. ⚠ It is FRICTION, and friction is what kills in-game fluidity — the reason sync exists at all |
| **NOT ours** | **the negotiation.** A route has to be picked, most likely by the tank, and that is comms. We transmit; we do not arbitrate |

★ That last line is a scope boundary, not a shrug: an addon that picks the route for a group has
started deciding how people play, which is the §157 line in another coat.

### ★★★ USER CONTENT — pass through, and REJECT rather than mangle

> *"We should protect user content, so pass through. Reject as the export stage / import stage if
> we determine malicious / we can't strip it safely."*

★★★ **This is better than escaping and it is a different posture.** Escaping silently rewrites
what somebody wrote; a `|` they typed on purpose comes back changed and they never find out.
**Pass it through untouched, and if it cannot be carried safely, refuse to carry it.**

    at EXPORT   the author finds out immediately, while they can still fix their own note
    at IMPORT   the runner is protected from a document that never went through our exporter

⚠ Both stages, which is §161's zero-trust made concrete: neither end trusts what it is handed, and
neither end quietly repairs it. ★ **A rejection must say WHICH field and WHY** — a refusal with no
reason is the same as a silent strip, one layer up.

### ⚠ COMPRESSION — measured, not guessed

> *"See what the end product looks like and some calc of what a heavy route looks like."*

**What is measured today** (heaviest captured run, `SFK_Run4`, 698 legs · 19 bosses · 58 markers):

    run record, raw JSON      317,382 bytes
    the same, deflated         25,690 bytes    8%

★★ **Coordinate data compresses hard**, which is expected and is the number that matters.

⚠ **But a ROUTE is not a RUN** — promotion is REDUCTION, so the route is beacons and children, not
698 legs. A rough shape for a heavy one, to be replaced by a real measurement the moment a route
of that size exists: ~30 beacons × ~4 children × ~15 fields ≈ **10–25 KB positional**, which is
**13–33 KB once 6-bit encoded**, or **~3–5 KB if deflated first**.

★★★ **And party sync is what decides it.** A pasted string can be 30 KB and nobody cares. An addon
message is capped per message (☐ confirm the cap on this client rather than assume), so 30 KB is a
hundred-odd messages and 4 KB is a handful. **Compression stops being an optimisation the moment
the transport is the channel.**

### Open

- Discovery: everyone hits sync, or a probe on dungeon join.
- Where the pair lives — copied into both addons, or a third format addon they both require.
- What "cannot be stripped safely" means, precisely, as a rule a function can apply.
- The addon-message cap on this fork, and chunk/reassembly if compression does not get us under it.
- **The field list.** ⚠ Genuinely blocked on the beacon/child model settling — it is last, not first.

### Out of scope

- Route selection / who picks. Comms, not software.
- Nested groups, versioning beyond *refuse what we do not know*, and any server-side component.

## 6. Accepted with a gate

**"What was killed in this pull"** — during an open fight, note identities so the editor can
write "pull 3: two Troggs and a Shaman" as a first-draft note. Battlewrath accepted this
*with a performance acceptance gate*: it must not measurably move framerate during a pull,
verified rather than assumed. Design keeps it minimal: one combat-log handler filtering to
`UNIT_DIED` only, appending names, bounded per pull. **The instrument for the gate already
exists** — `task_callwitness` / `task_perf` can measure our own addon.

## 7. Open questions

- ~~What happens past 1,500 yards?~~ — **ANSWERED by F35** (distance stays live to at least
  3,742 yd; only the beacon stops drawing) **and CLOSED by law 16** (we show nothing out there
  — the map is the instrument).
- ~~What happens across a continent / instance boundary?~~ — **ANSWERED by F38: the engine
  declines**, returning `Invalid` and `sd = 0.00` while the client keeps holding our pin
  (`gp = 1`, tracking still true). Behaviourally this needs no work — law 16 already says the
  map is the instrument at that scale, and an instance you have walked into is somewhere you
  are already standing. **What it DOES need is the state guard**, now an acceptance criterion
  on law 14.
  **★ With this, every CAPABILITY question is answered.** What remains in this section is
  design detail and the dungeon-floor question, which belongs to the route half.
- ~~Does the engine supertrack cross-zone?~~ — **DISSOLVED by F30.** There is no zone boundary
  in this coordinate space.
- ~~3D vs 2D proximity~~ — **ANSWERED by F28: 3D**, mean error 0.00001 yd over 945 samples.
- ~~Does distance survive off-screen?~~ — **ANSWERED by F29: yes**, 573 of 573.
- ~~What does the CVar-off path actually do?~~ — **ANSWERED by F41**: `Invalid`, tracking false,
  global nilled, no distance. Distinguishable from a boundary refusal by `tr` and `gp`.
**★ Everything below belongs to the ROUTE HALF.** `COA_Landmarks` has no open capability
questions — see `landmark_design.md` §11.

- ~~**Does mapID change across dungeon FLOORS?**~~ **ANSWERED 2026-08-13: NO — and that is the
  problem.** One `mapID` bundles many floors: **43 of 73 mapped dungeons are multi-floor**,
  deepest **17** (Karazhan, mapID 532). Each floor has its **own bounding box and own tile
  art**, so **a world position is NOT placeable from `mapID` alone** — floor IS a data-model
  concept. `addons/maps/worldmap/dungeon_floors.md` has every box. Original wording:
  *Decides whether a floor is a data-model concept*
  or just a z value. One dump at the top and bottom of a staircase settles it. Ragefire is
  single-level so this is still untested.
- **Does the 3:2 map aspect generalise?** (§4.)
- **How dungeon map textures are addressed** for display — tiled from the base name in this
  era, but unverified on this fork.
- **Does "pick a role" survive at all?** Opening framing had role as a selector (pick a map,
  pick a role), but law 6 makes team notes role-agnostic and law 8's **spec linking on the
  NOTE** would carry role guidance instead — leaving the route one role-agnostic path and
  dropping a dimension from the shared schema. **Leaning: role lives on the note, not the
  route.** Not yet confirmed, because spec linking is itself still tentative.
- `GetSuperTrackedWorldPosition` returned four values not obviously matching the set position
  — coordinate space **unestablished**. We never need it (proximity compares our stored
  coords against live ones, same function, same space by construction). Left alone
  deliberately.

## 8. ★ GATE — put to the community BEFORE building (Battlewrath, 2026-08-08)

Posted to the PvE and tanking discussions, framed as a tank question but scoped to all roles.
**Two explicit checks named up front, and either can stop or reshape the build:**

1. **A tool may already exist for CoA** — if so, the move is the consumer-contract pattern
   ([[consumer-contract-pattern]]), not a duplicate: adopt or extend, characterise its data
   before inventing uses. Same posture as MancerLedger over Mancer.
2. **It may be over-engineering** — accept a scope-down or a drop on that answer.

The pitch as posted, which sharpens two things this ledger should carry:
- **"All self-authored content rather than me trying to map every dungeon."** THE scoping
  insight — we ship the tool, users author routes. No dungeon database to build or maintain,
  and no obligation to cover content we don't play. This is what keeps it a "dumb Mythic
  Dungeon Tools" rather than a data project.
- **"Notes for yourself" is the premise** — the community sharing string is a
  consequence, not the purpose. Do not let import/export pull the design toward
  authored-for-others.
- Skips and jumps are a **double-tap** on the widget; ordinary pull points still come free
  from combat enter/exit on the first run.

## 9. ★ THE BLUEPRINT GENERALISES — the world-map scrapbook (Battlewrath, 2026-08-12)

His recognition: *"this is the same blue print to another addon I wanted. Basically a scrap
book for the world map. Farm locations. Vendors you prefer to use. Basically land mark
navigation that is self authored."*

**Sharper than "same blueprint": it is LAW 9'S LANDMARK HALF, already specified, with the
route half removed.** Read law 9 with the waypoint bullet covered — promoted nodes are
personal landmarks, map-scoped, outliving every route; personal notes anchor to them by hand;
and **proximity to a landmark drives personal notes regardless of whether a route is loaded at
all**. That last clause was written for the notebooking proposition inside a dungeon. It is,
unchanged, the scrapbook.

**★ WHAT "ARCHITECTURE" MEANS HERE — CORRECTED (Battlewrath, 2026-08-12).** Verbatim:
*"Architecture in the way we are developing and understanding the system. And making it
repeatable. The implementation may differ. We don't have to codify them explicitly."*

The shared thing is the **method and the understanding** — how we develop against this client
and how we come to know it — **not a committed code structure.** An earlier draft of this
section claimed "same total work, one codebase instead of two"; that was an implementation
promise nobody made, and it is withdrawn. **The two may share a great deal of code or almost
none, and that is decided when it is built, against what is then known — not now, on paper.**

This is [[adr-inventiveness-confined-to-contained-spaces]] applied to ourselves: **do not
codify the abstraction ahead of need.** A shared core is a *candidate* shape, not a decision.
Writing it into law before either thing exists would be inventing structure to fit a
prediction, which is the failure mode this ledger exists to avoid.

**What IS decided is the ORDER, and the reason is knowledge, not reuse** — see the next
subsection.

**Second consequence, and it partly de-risks §8: the foundation's value does not depend on the
community answer.** The gate asks whether the *routing* proposition is wanted. Self-authored
landmarks are personal utility either way. So a "no" on §8 scopes the build down rather than
killing it.

### What the scrapbook genuinely needs that law 9 does not yet cover

Stated as deltas, not designed — nothing here is decided.

1. **Whole-world scope.** A dungeon is effectively one mapID; the scrapbook spans zones and
   continents. Needs a per-zone index and cross-zone retrieval that law 9 never required.
2. **★ The primary VERB changes — from *follow* to *find*.** Sat-nav's interaction is
   traversal; the scrapbook's is lookup ("where is my Winterspring herb spot" asked from
   Orgrimmar). Proximity display alone cannot answer that. So search / filter is the main
   surface, not an ordered list — a different UI over the same data.
3. ~~**Categories** — one icon per activity kind.~~ **PROPOSED BY ME, REJECTED, AND REPLACED
   WITH SOMETHING BETTER (Battlewrath, 2026-08-12): a STICKER PALETTE + a TOOLTIP NOTE
   DISPLAY.** Activity is a **layer on** the landmark, not a variant **of** it. The marker
   vocabulary stays at three stable symbols; the variety lives where it cannot dilute them.
   - **★ "Not exactly per-entity nodes but INDICATORS."** This is the load-bearing constraint,
     and it is what keeps the addon from becoming a gathering database. A farming sticker says
     *this area is a farm spot*, **not** *this exact herb spawns here*. Pen and paper, again:
     you circle a region, you do not survey it.
   - **Stickers are USER-CHOSEN from a palette**, unlike the marker symbol which context
     decides. That is the right place to spend a user decision — it annotates rather than
     classifies, so a wrong pick costs nothing.
   - Named so far, both **free**, both `objecticonsatlas`, both **32×32** — half the marker
     size, which reads correctly as *annotation on a thing* rather than *a thing*:

     | Sticker | Atlas | Registry | His read |
     |---|---|---|---|
     | **farming** | `vehicle-trap-gold` | `AtlasInfo.lua:296` | "it's a trap" |
     | **favoured vendor** | `housing-decor-vendor_32` | `:697` | "a distinct gold pouch / bag, different from banker bags" |

     Zero client code touches `vehicle-trap*` or `housing-decor*` anywhere. Supply note, not a
     proposal: `vehicle-trap-grey` and `vehicle-trap-red` are free siblings on the same row, so
     the trap exists as a three-colour set if a state is ever wanted.
   - The **tooltip note display** is the readout surface, and F15 already established the
     mechanism — `WorldMapTooltip` via the pin's hover, no new machinery.
4. **Sharing pressure is lower.** Law 7's *import wipes* and law 9's sacred-vs-disposable
   split exist for a shared route artefact. A personal scrapbook may want neither.
5. **★ Outdoor position may be EASIER, not harder — and this is a PROBE, not a claim.** F9
   found `C_WorldMap.GetWorldPosition` returns nil *inside instances*, which implies it works
   outdoors. If it does, the map↔world transform §4 derives by hand for dungeons is supplied
   by the engine outdoors. **Still untested — and now MOOT for `COA_Landmarks`**: F30 showed `mapID` is the continent, and pins are placed from `GetPlayerMapPosition` map fractions (F8, AC-1), so we never need the conversion. Left here for the route half.

### ★ ORDER DECIDED (Battlewrath, 2026-08-12)

*"We can do the scrap book / land mark feature first. That has broader use, easily tested. And
can be packaged separately as different addons for different use cases later. Then the routing
becomes either a load or share operation of the same architecture."*

Three reasons, his, and each is independently sufficient:

1. **Broader use.** It serves every player outside a dungeon, not only people running routes.
2. **★ EASILY TESTED — and this is the one that matters most to us.** The route half needs a
   group, a dungeon and a plan to exercise. The landmark half is testable by **one player
   standing somewhere**, which is the capture loop this bench already runs daily. It is the
   difference between a feature we can prove and a feature we can only demo.
3. **Separable packaging later.** Different use cases can ship as different addons over the
   same core.

**★ AND THE REAL PAYOFF IS KNOWLEDGE, NOT REUSE (Battlewrath, 2026-08-12):** *"once we have
the landmark feature in, the questions that routing has will be part answered."*

That is the argument for the order, and it stands whatever the code ends up looking like.
Routing's unknowns are mostly **shared mechanics**, and landmarks exercise them under far
easier test conditions — one player, outdoors, no group, no plan. Mapped against §7, honestly,
including where it does *not* help:

| §7 open question | What shipping landmarks does to it |
|---|---|
| **3D vs 2D proximity for advancing** | **Fully exercised.** Landmark proximity drives personal notes — the identical mechanic, with real numbers from real use instead of a judgement call |
| **Does the 3:2 map aspect generalise?** | **Answered more broadly than routing could** — across many zone maps rather than one dungeon |
| **Does "pick a role" survive?** | **Answered directly**, if spec linking ships on landmark notes. That is where the question actually lives |
| `GetSuperTrackedWorldPosition` space | Exercised outdoors, where the setter/getter loop is easiest to read |
| ~~Beacon max range~~ | **ANSWERED** — F22 (thresholds) and F35 (distance stays live to 3,742 yd) |
| **Does mapID change across FLOORS?** | **Partial only** — landmarks settle whether mapID is a sufficient storage key; the dungeon-floor case still needs a dungeon |
| ~~**How dungeon map textures are addressed**~~ | **ANSWERED 2026-08-13** — `Interface\WorldMap\<file>\<file>[<floor>_]<1..12>`, twelve tiles, `<file>` being what `GetMapInfo()` returns. `WorldMapArea.dbc` holds the name; the floor suffix appears only when the level is > 0, and `DungeonUsesTerrainMap()` shifts that index by one. It DID come free — from the client's own `WorldMapFrame.lua:463-476`, not from a rendering experiment |

It also answers questions §7 never listed because routing hadn't reached them: the
serialisation shape, whether pins render correctly at world-map scale, and how the note
readouts actually feel to use.

**Candidate shape, NOT a decision** (per the correction above): a shared core with per-verb
shells — scrapbook's verb is **find**, a follower's is **follow**. This bench has precedent for
it (State Plates core + satellites; MancerLedger over a driver contract), which is why it is
worth *noting*. It is not worth *committing to* before either thing exists.

**★ AND IT UNBLOCKS THE ARC.** §8 gates the *routing* proposition on a community answer. The
landmark feature is not that proposition, so **it is not behind that gate.** The arc goes from
"waiting on other people" to "has an ungated first deliverable" on this decision alone.

### ★ DESIGN WALK 1 — open world, end to end (Battlewrath, 2026-08-12)

Method: walk one story and let decisions surface where they are *met*, rather than listing them
abstractly ([[user-story-walks-as-verification]] — walks prove the joins). The story:
**you are in Winterspring, you find a herbing circuit worth keeping, you mark it; three weeks
later you are in Orgrimmar and want to go back.**

**1 · Marking it — SETTLED, and it asks you NOTHING.** Law 1 (born only where you stood) plus
law 3 (the map orients, it does not author) already fix capture as an in-world act, never a
map click. Confirmed: capture takes **no note, no sticker, no dialog** — it drops a landmark
and gets out of the way, per law 4 (*the session drafts, the human curates*).
**Three affordances, user's choice — not one blessed path:**
- a **widget** that can live on the UI
- a **right-click on the minimap element**
- a **user-authored macro**, something short like `/<addon_abbrev> here`

This is [[design-for-the-everyman-custom-earns-its-place]]: out-of-the-box paths for people who
want one, a text command for people who would rather build their own button.

**2 · Where it lives — BOTH, defaulting to character.** *"Default to character, easy to promote
to account, easy to make character specific again."* So the record carries a **scope** that
moves in **both directions**, cheaply, after the fact. A herb circuit is account knowledge; a
favoured vendor may not be. **Noting a pattern in his design vocabulary rather than proposing
anything: PROMOTION recurs** — capture → promote to fixture (law 9), character → promote to
account. Worth watching in case it wants to be one mechanism.

**3 · Getting back to it — a PROBE, not a decision yet.** His steer: *"We can test this. I know
on retail, it can point towards the main connectors. 'Go to Stormwind' — also, if not in zone,
surface the zone needed."* Two behaviours to establish before designing any retrieval UI: does
the engine point **cross-zone**, and if it cannot, do we **name the zone** instead of failing
silently. **F23 collapses this to a cheap, exact test — see §7.** Retrieval UI stays unspecified
until the probe reports, because the answer changes how much UI is needed at all.

**4 · Arriving — SILENT. Now law 12**, and F21 shows the client already implements it.

**5 · The fence — the product thesis. Now law 11:** notes of meaning, not what-where.

**What this walk did NOT reach** (honest gap, not an omission): editing and deleting a
landmark, what a note actually is (length, plain text vs structured), and how many stickers
ship. ~~Whether landmarks appear on the minimap~~ — **CLOSED by law 15: they do not.** The rest
belong to a second walk — probably *"three weeks later I revisit and the note is wrong"*.

No separate ledger yet — recorded here because it sets *this* build's ordering. It earns its
own file when it is taken up.

## 10. Build state

**`COA_Landmarks` — BUILT, DEPLOYED AND VALIDATED IN PLAY (v0.1.9, 2026-08-12).**
`addons/planning/landmark_design.md` is the spec and is current; `addons/COA_Landmarks/README.md`
is the user-facing half. Prior art inspected (`satnav_prior_art.md`). Fact basis: F1–F42 across
four probe runs, 1,857 samples. **Nothing left to build** — §12's remaining questions need play,
not code. One known issue parked (beacon staleness on re-pin; §15 of the brief).

**The route half — still gated on the community answer (§8)**, and per §9 it is a load-or-share
consumer of the same *understanding*, **not necessarily the same code**.

**Instruments that exist:** `COA_DevDump/task_satnav.lua` (the probe) ·
`addons/tools/read_satnav_probe.py` (the reader) · `addons/tools/smoke/smoke_satnav.lua` ·
`addons/planning/satnav_probe_runsheet.md`. Re-runnable if the client moves.

**★ STALENESS NOTE for whoever builds this.** Every fact here was read from **patch-B as
extracted on 2026-08-12**, or captured live the same day. This fork ships changes in days. Before
trusting a source-read claim, re-check it; before trusting a captured one, re-run the probe —
it takes three minutes and the reader answers all three questions at once. The facts most worth
re-checking are the ones with **numbers** in them: F22's 727/1500 thresholds and F31/F37's
5.46–5.59 arrival radius are the client's own constants and can move.
