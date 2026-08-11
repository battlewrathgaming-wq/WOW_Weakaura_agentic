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
| F4 | **Setter accepted; engine stores it** | `IsSuperTrackingAnything()` → true |
| F5 | **Beacon renders inside an instance** | visible on screen at the marked spot |
| F6 | **Beacon does NOT clear on approach** | observed — *this absence IS our mechanism*, not a defect |
| F7 | **Dungeon map art exists and is addressable** | `GetMapInfo()` → `Ragefire, 668, 768` |
| F8 | **Map-space position works indoors** | `GetPlayerMapPosition("player")` → real fractions |
| F9 | **`C_WorldMap.GetWorldPosition` returns nil inside instances** | probed; Astrolabe uses it for outdoor zones only |
| F10 | **World units are YARDS** | a beacon-measured **50-yard** leg computed to **49.7** |
| F11 | **`GetMapInfo`'s 668/768 are TEXTURE dims, not world extent** | they contradict the measured extent (below); 668 is the standard map-frame width |
| F12 | **The beacon renders its own DISTANCE READOUT in yards** — we do not build one | incidental, from Battlewrath's *illustrative* screenshots (taken to show the community the vision, NOT part of the structured probe series): a diamond marker captioned "76 yds" / "54 yds". Corroborates F10. Consequence: notes can stay purely semantic, since navigation is already on screen |
| F13 | **The beacon reads correctly ACROSS ELEVATION** — visible up a ramp, then on the same plane while closing on it | the point Battlewrath was demonstrating with those screenshots. The 3D projection behaves for the navigation case, not just at a fixed height |
| F14 | **The 233 cull is the MINIMAP POI's, not the world beacon's** | beacon visible and captioned at 76 yds. Beacon max range still UNKNOWN |
| F15 | **The world-map PIN MECHANISM is addon-reusable — we do not build map markers either** | source read of `Ascension_POI/MapPoiPin.lua` + `WorldMapPOIMixin.lua`. Pins parent to **`WorldMapButton`** and position via `SetPoint("CENTER", WorldMapButton, "TOPLEFT", x, y)` (pixel offsets — our map fraction × frame size lands directly) · hover text uses **`WorldMapTooltip`** (owner/AddLine), exactly the surface for the note readouts · `MapPoiPinMixin` supports a per-pin **`OnClickFunction`**, so click interaction is normal here (promote a node, open a note). **The ART is explicitly NOT reusable — see law 10.** |
| F16 | **The death markers themselves are NOT reusable** — `WorldMapChallengeFailPOIMixin`, server-fed challenge/hardcore failure records (killer, level, ruleset, timestamps) | same source read. Boundary is clean: **the pin machinery is ours to reuse, the death DATA is not** |
| F17 | **★ A PURPOSE-BUILT WAYPOINT ICON FAMILY EXISTS AND IS ALL BUT UNUSED** — and it satisfies law 10 outright | `SharedXML/AtlasInfo.lua` (**4,503** named atlas entries — the authoritative count from the emitter, F20; the 4,425 first quoted here was an ad-hoc undercount). The family lives at `interface\waypoint\waypoinmappinui` (Blizzard's own path typo): **Tracked · Untracked · Highlight** (30×30) · **ChatIcon** (13×13) · **ButtonToggle** (38×38), plus `waypoint-mappin-minimap-tracked/untracked` (32×32) on `objecticonsatlas`. Cross-referenced against 1,130 client source files: **7 of 8 referenced ZERO times.** The one claim is `SuperTracker.lua:131` — `[Enum.SuperTrackingType.Position] = "Waypoint-MapPin-Tracked"` — i.e. the client uses it for a POSITION supertrack, **exactly our use case**. Not a conflict: it is the client naming the correct symbol for us, and it is already what the live beacon renders |
| F18 | **The claim-of-use test is MECHANICAL and proven** | grep an atlas name across the extracted source tree, excluding `AtlasInfo.lua` itself; zero references = unclaimed. Ran ad-hoc over 1,130 files to produce F17. **This is the emitter's whole algorithm** |
| F19 | **The client ships an in-game ATLAS BROWSER** | `AddOns/Ascension_UIDevelopmentTools/AtlasBrowser/` in patch-B (not present in the user's AddOns folder — it lives in the MPQ). Untested whether `LoadAddOn` will open it; if it does, visual classification needs no tool from us at all |
| F20 | **★ The census is EMITTED, and the fork's own art was the part that kept going missing** | `addons/tools/emit_atlas_census.py` → `addons/maps/atlas/` (census.json + routes.md + free.md). **4,503 entries · 1,359 claimed · 3,144 free.** Three format variants had to be calibrated in, and **all three were CoA's custom art, not Blizzard's**: (a) fractional sizes `179.2, 69.3`, (b) names beginning `!` (a sort prefix, 96 of them), (c) **Lua arithmetic as a size** — `85*0.24`, `(151+151)/512`. Each was a *silent* drop under a stricter pattern. First flawed run emitted 4,302 and looked perfectly healthy. **CoAResource entries went 39 → 102** once all three landed, including all 7 `ReaperAtlas` class-resource pieces. Lesson, general: *the bespoke rows are the ones a pattern tuned on the common rows drops — and they are exactly the rows we care about.* Guarded by a completeness self-check that compares parsed names against entry-shaped names and **refuses to write** on a shortfall; it fired twice and earned itself. Guard note: it compares NAME SETS, not line counts — the registry genuinely repeats 18 keys (Lua last-wins, so those earlier definitions are dead art), reported not hidden |

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

**★ THE GOVERNING METAPHOR (Battlewrath, 2026-08-08): "We're not trying to be smart. This is
pen and paper in digital form."** Sticky notes on a map · a drawn path with numbered stops ·
a note near a stop is about that stop · draw a line when you need to be explicit. Use this to
arbitrate scope: if a proposed feature is something you could not do with pen, paper and a
map, question it. It is the standing answer to "should this be cleverer?"

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
      **The one genuine gap is the LANDMARK symbol**, which must read as distinct from a
      route waypoint — one symbol to choose, from 4,503, with a mechanical claim-test (F18)
      to prove it free.
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

## 9. Build state

**Nothing built, and now gated on the community answer (§8).** Fact basis established; design
laws set; no code, no addon folder, no acceptance criteria written. If the gate clears, the
next step is a design/AC document in the shape of `callwitness_design.md` — criteria before
build — not implementation.
