# Dungeon sat-nav — project ledger

_Scoped context for the in-dungeon route pointer. Everything here is either LIVE-PROVEN (with
the capture that proves it) or explicitly marked as assumption. Bench-level state lives in
`operations/Addons_load.md`, which points here; this file is the project's own memory._

Opened 2026-08-08.

## 1. The want (Battlewrath, verbatim intent)

A **light** in-dungeon sat-nav pointer. Explicitly **not** Mythic Dungeon Tools — that's too
feature-rich. Reference points: pfQuest (installed), TomTom (not on this client generation).

> Pick a map. Pick a role. Place a point and leave a note. The system knows when you're in the
> zone of that marker, then waits / progresses to point to the next marker.

All hand-authored, nothing smart. Possible import/export string so the community converges on
shared routes.

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
| F4 | **Setter accepted; engine stores it** | `IsSuperTrackingAnything()` → true |
| F5 | **Beacon renders inside an instance** | visible on screen at the marked spot |
| F6 | **Beacon does NOT clear on approach** | observed — *this absence IS our mechanism*, not a defect |
| F7 | **Dungeon map art exists and is addressable** | `GetMapInfo()` → `Ragefire, 668, 768` |
| F8 | **Map-space position works indoors** | `GetPlayerMapPosition("player")` → real fractions |
| F9 | **`C_WorldMap.GetWorldPosition` returns nil inside instances** | probed; Astrolabe uses it for outdoor zones only |
| F10 | **World units are YARDS** | a beacon-measured **50-yard** leg computed to **49.7** |
| F11 | **`GetMapInfo`'s 668/768 are TEXTURE dims, not world extent** | they contradict the measured extent (below); 668 is the standard map-frame width |

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

**Calibration cost per dungeon:** two captured points with decent map separation — which a
route's first run produces naturally. **ASSUMPTION (untested):** that the 3:2 aspect holds for
all dungeon maps; if so one well-separated leg gives both scales. Verify on a second dungeon
before relying on it.

## 5. Design laws (decided)

1. **A marker can only be born where a player stood.** Three capture sources, all ground
   truth: **combat start**, **combat end**, and a **widget tap**. Rationale (Battlewrath): a
   2D map image cannot supply height, so a spawned point would need an invented z — which
   puts the beacon inside geometry or on the wrong floor. F9 later added a second support:
   the engine can't give world x/y from map coordinates either.
   **Consequence worth keeping: every marker in every shared route is provably reachable,
   because someone physically stood on it.** A click-to-place editor cannot promise that.
2. **The editor never creates or relocates arbitrarily.** It orders, annotates, assigns,
   prunes, and **nudges within a limited range**. A nudge updates BOTH representations (§4
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

## 6. Accepted with a gate

**"What was killed in this pull"** — during an open fight, note identities so the editor can
write "pull 3: two Troggs and a Shaman" as a first-draft note. Battlewrath accepted this
*with a performance acceptance gate*: it must not measurably move framerate during a pull,
verified rather than assumed. Design keeps it minimal: one combat-log handler filtering to
`UNIT_DIED` only, appending names, bounded per pull. **The instrument for the gate already
exists** — `task_callwitness` / `task_perf` can measure our own addon.

## 7. Open questions

- **Does mapID change across dungeon FLOORS?** Decides whether a floor is a data-model concept
  or just a z value. One dump at the top and bottom of a staircase settles it. Ragefire is
  single-level so this is still untested.
- **3D vs 2D proximity for advancing.** The engine's own POI logic is 2D; inclination is 3D
  for advancing and 2D for display, but the numbers should decide.
- **Does the 3:2 map aspect generalise?** (§4.)
- **How dungeon map textures are addressed** for display — tiled from the base name in this
  era, but unverified on this fork.
- **Role model:** separate lists per role, or one shared ordered path with role-gated points
  and per-role notes? Undecided.
- `GetSuperTrackedWorldPosition` returned four values not obviously matching the set position
  — coordinate space **unestablished**. We never need it (proximity compares our stored
  coords against live ones, same function, same space by construction). Left alone
  deliberately.

## 8. Build state

**Nothing built.** Fact basis established; design laws set; no code, no addon folder, no
acceptance criteria written yet. Next step when resumed is a design/AC document in the shape
of `callwitness_design.md` — criteria before build — not implementation.
