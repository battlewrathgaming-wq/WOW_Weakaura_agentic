# Map — the drawing surface

_`map.lua` · `COA_DungeonRunMap` · **size is a RULE, not a pair** · content x = `MARGIN + 2` = 18_

★★★ **The factual register.** What exists, or what the code must comply with.

★ **Reconciled by `check_interface.py`** — the file and global named above, the declared size, and every `forms · phrase` citation. Bench menu **[7] Reconcile**, or run it directly. ⚠ It checks the mechanical part only; whether `does`, `how` and `refuses` are still true is curation.

---

## numbers — computed, not declared

    w = ART_W + MARGIN * 2      = 1002 + 32       = 1034
    h = ART_H + STRIP + FOOT    = 668 + 40 + 14   = 722

    ART_W, ART_H          map.lua:57      1002 × 668 — the COORDINATE space
    MARGIN, STRIP, FOOT   map.lua:2128    16, 40, 14
    TILE_COLS/ROWS/PX     map.lua:56      4 × 3 × 256 — the ART grid

★★★ **The coordinate space is NOT the tile grid, and that distinction is load-bearing.** The tiles
are power-of-two art with dead padding. Placing against the tile grid instead of the detail frame
stretches everything **+2.2% horizontally and +15% vertically** — which draws a trail that still
follows corridors and is wrong everywhere, worst furthest from the origin.

⚠ Caught by eye on the first art-bearing draw: *"there is some displacement as a constant across
them."* A wrongness that still looks plausible is the expensive kind.

★ **This is the shape any computed pane needs** — a rule with its constants named, not two numbers
someone typed.

## ★★★ The model — what it IS

**The map is the primary storytelling space.** It is where data becomes legible; where a person
recounts moments in time and assigns meaning to them; and where events become lessons for the
next run.

> *"It is where data becomes legible, where the human can infer from the data. Where they can
> recount moments in time and then assign meaning - and where they can turn data, time and
> events, into lessons for the future."*

★★★ **WE GIVE CONTEXT. THEY DERIVE MEANING.** His line, and it is the whole boundary in four
words: *"we do not derive meaning. We just help give context on it."* Legibility is ours to owe
— what happened, when, where, what was nearby. The moment we suggest what a moment MEANT we have
crossed into expertise, and it will look like helpfulness on the way over.

★★ **AND INFORMATION BECOMES NOISE WHEN DISTINCTION CANNOT BE MADE.** That is why filtering and
display options exist at all — not as convenience, but because an undifferentiated picture is not
legible. ⚠ And it is why they change **what you see, never the record**: distinction is a READING
operation.

### What falls out of it

| behaviour | why |
|---|---|
| **never learns a dungeon** | pre-loaded knowledge is someone else's story imposed on yours |
| **run and route load independently** | you need the evidence and the interpretation on screen together to recount and assign |
| **the whole time machinery** — envelope, window, step, play | *recounting moments in time* is the reason. Time is a dimension you move THROUGH, not a filter you set |
| **tooltip, never a panel** | recounting is done by looking. Something that announces is telling the story for you |
| **the dots are the picture** | the record is not the story; the drawing is |
| **meaning lands in the Object pane** | assigning is a separate act on a thing you have already recounted |

### ⚠ Two boundaries, marked so they are not absorbed

⚠⚠ **IT SHIPS, so it is WHOEVER HOLDS IT's storytelling space — not ours.** His: *"This tool
will ship also. So another person will use the same tools to tell their own story."* ★ That is a
SECOND and independent argument for never learning a dungeon: a map carrying our assumptions
about which route or which moment mattered would be handing someone our story in their tool.

⚠ **"Direction for the next player" is NOT this surface.** It is true of the product, and it
belongs to the **post-promotion export path** — `satnav_ledger.md`. The map is where direction is
MADE. Left unmarked, this pane would start growing sharing affordances because the model appeared
to ask for them.

## does

1. **Draws a captured run** onto the client's own dungeon tiles.
2. **Draws a route** — beacons and their children — on a second layer.
3. **Draws personal notes** on a third.
4. **Zooms and pans**, 1× to 4×.
5. **Selects** a point, and right-click opens the Object pane on it.
6. **Opens** the Map controls and Curation.

## refuses

- ⚠ **It never learns a dungeon.** No stored floor plans, no roster, no list of what exists. It
  draws onto the client's own tiles and reads its own captures.
- ⚠ **It takes neither the wheel nor right-drag without being asked.** Mouse-wheel zoom and
  right-click pan are ticks that default **OFF** — the wheel belongs to the world camera and
  right-drag to camera-look.
- ⚠ **Point facts live on the MAP as a tooltip**, not in a pane. Hovering answers; nothing
  announces.

## how

★★ **THE LAYER TABLE IS THE MODEL** (`map.lua:377`). Three rows, and adding the third cost exactly
one row — which is the test that the layering is real rather than two special cases:

    key      timed   art    lists
    run      true    true   RUN_LISTS      a capture, sliced by time
    route    false   false  beacons        an authored route
    notes    false   false  notes          your own plane, keyed by mapID

★ **`run` and `route` load independently.** Authoring a route means looking at the evidence it came
from, so both can be on screen at once.

★ **Notes are keyed by `mapID`, not by route.** They are yours: they need no route, never travel
with one, and there is one plane per dungeon with nothing to choose.

    time      envLo/envHi (envelope) · winPos/winWidth (window) · SkipStep — a tenth of the span
    view      zoom 1–4, anchored on the VIEW CENTRE rather than the cursor
    drawing   Painted(floor) is a QUERY over the loaded slots

⚠⚠ **`Map.Painted` answers the same whether or not anything repainted**, so asserting against it
proves the record and never the picture. **The dots are the picture.**

★ **Zoom anchors on the view centre, not the cursor**, and that is deliberate: the cursor is also
the *pen*, and drawing tools are unusable on the coarser maps where a 5-yard radius is under two
pixels.

## interacts

| you | it |
|---|---|
| left-click a point | selects it — Promotion mints from the selection |
| right-click a beacon, child or note | opens the **Object** pane on it |
| **Controls** | opens the Map controls pane |
| **Curate** | opens Curation |
| **◀ / ▶** | previous / next floor |
| hover a point | a tooltip with that point's facts |
| mouse wheel · right-drag | ⚠ **only if you ticked them on** |

## holds

    envLo/envHi, winPos/winWidth   the time slice — Curation reads and sets these
    zoom, scroll                   view state
    layerOff, hidden               what is drawn
    tracking                       follow the newest node
    moveArmed, pickArmed           the Object pane arms these; the map performs them

★★ **The map owns the selection and the time state; every other pane reads it from here.** That is
the §63 rule — two surfaces each remembering what they are looking at is how they come to disagree.

## relates

    opened by   the Remote
    opens       Map controls · Curation · the Object pane (right-click)
    ⚠ Curation and Promotion (DIALOG) draw OVER this pane (HIGH), and its own "Controls"
      and "Curate" buttons read through their backdrops

## children

☐ **Not declared in `panespec.lua`.** Every number is hand-typed in `map.lua`.

```
map.pane        kind frame   usage — (the surface itself)
                does  the pane itself. `set("close")` hides it, `read` reports shown
                ★ REGISTERED §128 — the walker locates panes by their `*.pane` key

map.title       kind readout   usage readout    forms map.lua · `title = frame:CreateFontString(nil, "OVERLAY", "GameFontNorm`, GameFontNormal, at (MARGIN + 2, -16)
map.ref         kind readout   usage readout    forms map.lua · `ref = frame:CreateFontString(nil, "OVERLAY", "GameFontDisabl`, LEFT of title + 10
map.viewport    kind scroll   usage — (container)     forms map.lua · `viewport = CreateFrame(`, ScrollFrame, COA_DungeonRunViewport
                does  clips and scrolls the canvas
map.canvas      kind frame   usage — (container)      forms map.lua · `canvas = CreateFrame(`, inside the viewport
                does  holds the tile textures and every drawn point
map.tile.<n>    kind texture   usage icon    forms map.lua · `local t = canvas:CreateTexture(nil, "BACKGROUND")`, one per tile in a 4 × 3 grid at 256px
                ★ the coordinate space is ART_W × ART_H, NOT the tile grid — see numbers
                ⚠ A PATTERN, not a control (§131). It was `map.tiles` and read as ONE
                  thing to register — but there are TILE_COLS × TILE_ROWS of them and
                  they are homogeneous art, so a single key would have named one tile
                  and hidden the rest. It joins the other three patterns.
map.controls    kind button   usage action     forms map.lua · `ctlBtn = CreateFrame(`, "Controls", TOPRIGHT -MARGIN-64, -12
                                numbers w 70 · h 20
map.curate      kind button   usage action     forms map.lua · `editBtn = CreateFrame(`, "Curate", TOPRIGHT -MARGIN, -12
                                numbers w 60 · h 20
                ⚠⚠ These two are what read through Curation's backdrop when it is open
map.prev        kind button   usage action     forms map.lua · `prevBtn = CreateFrame(`   does previous floor
map.floor       kind readout   usage readout    forms map.lua · `floorText = frame:CreateFontString(nil, "OVERLAY", "GameFont`   does which floor
map.next        kind button   usage action     forms map.lua · `nextBtn = CreateFrame(`   does next floor
map.readout     kind frame   usage — (container)      forms map.lua · `readout = CreateFrame(` + its `readout.title = readout:CreateFontString(`
                does  the point facts panel
```

★ **All eleven are registered** (§131) — pane, title, ref, viewport, canvas, the four buttons,
floor and readout. ⚠ This ☐ said *"nothing here is registered"* for three commits after they were,
which is the drift the reconciler exists to catch and does not: `check_interface.py` reads the
registry, not the prose beside it.

---

## ★★★ MARKER / NODE TYPES — what they measure, and how

_The map's controls are listed above. **This is what the map is FOR** — and it had no entry_
_anywhere until §206. Nine draw-kinds from eight data-kinds, and they split three ways._

⚠ These are **not controls**: no key, no registry, nothing to click in the sense the list above
means. They are rendered CONTENT, and they carry code attachments like anything else that exists.

### The three origins, which is the useful cut

| | | |
|---|---|---|
| **CAPTURED** | `leg` · `combatleg` · `start` · `end` | the machine sampled it. Capture is the only spawn |
| **HUMAN** | `pin` | the client was silent and the player was the sensor |
| **AUTHORED** | `beacon` · `child` · `note` | minted at promotion, out of a reduction |

### ★★ TWO ORTHOGONAL CHANNELS — and promoted objects speak a different language

    CAPTURE points    COLOUR = combat state   red in combat, blue out of it. Everywhere.
                      SHAPE  = what kind      dot = sample · swords = event · cross = terminal

    PROMOTED objects  ICONOGRAPHY carries it  *"just iconography of the item. It has meaning."*
                      A beacon is not reporting a state - it is an INSTRUCTION.

☐ **`gt` is written on every point and read NOWHERE (§226).** `store.lua`:142 and :330 stamp
`t = time(), gt = GetTime()` on every point `Store.Point()` builds, and all six spawn paths go
through it. Every live consumer takes `t` — the timeline span :627, floor-at-a-moment :721,
`Map.InWindow` :787, the tooltip :1092. ★ NOT a defect: nothing addresses a sample, so nothing
needed it. It is the unused half of the `t:gt` pair the address sheets name, and the first note or
icon on a sample is what cashes it in.

★★★ **THE ICON IS THE CHILD'S, AND IDENTITY IS SPLIT FROM APPEARANCE (§231).** `Map.KindKey`
answers what a point IS; `Map.ArtKey` answers which crop to draw, and **only `ArtForPoint` asks it
now.** Visibility, rank, the tooltip's name and its colour all moved to the kind — the four
identity questions §226 found being answered by a picture. ⚠ `RANK.kill` and `LABEL.kill` are
GONE: they existed only to undo the icon's identity claim by hand, and with the claim gone the
patches are dead weight. ★ The completeness walk INVERTED with them — it used to demand a label, a
colour and a rank for every CROP, which is the conflation written as a test; it now asks each table
its own question. ★★ And the palette is a table: `local PALETTE = { "kill" }`, one word today, and
adding another is two rows and no code. *"Build the capability. Then we'll worry what fills it as a
table lookup."*

☐ **THE ICON HAS NO PICKER YET.** `Routes.SetChildIcon` validates against the palette and the map
draws it; nothing offers the choice. ★ Deferred deliberately — *"that's part of the overhaul. Might
be a tab solution. Or a face picker."* ⚠ **MEASURED, AND NARROWER THAN I CLAIMED (§239).** `object.target` spans 519.8–551.8 and a
non-empty `object.hint` spans ~516–526 — **a 6.2px overlap**, the arithmetic confirmed. ★ But it
needs THREE things at once: a child selected, an action that USES a target (or `target` stays
hidden), and `hint` carrying text — empty, it collapses to 1px and there is nothing to hit. Two
captures caught neither combination. ★ Not introduced by the icon work: the child pane has no
free row, and THAT is the thing to fix rather than the pixels.
 *"Icon should
never have been an identity claim. As there's no uniqueness."* `Map.ArtKey` returns a beacon's
icon, and five call sites consume that key — only `ArtForPoint` is asking about appearance; the
other four ask what a thing IS. ⚠ `Map.Rank` resolves through it, and `child = 8` against
`kill = 7` means an iconed child would tie with the beacon it is minted exactly on top of. **Art
answers what you look like; rank answers what you are.** Full reasoning in `dungeonrun_model.md`.

★ And the size says which register a thing is in: **`DOT_PX` 8 for a sample, `MARK_PX` 16 for an
event** — *"an EVENT reads larger than a SAMPLE."*

### The types

| type | what it measures | how it comes to exist | draws as | rank |
|---|---|---|---|---|
| **leg** | position at a moment, out of combat | `Store.AddLeg` on the movement sampler. ⚠ It has **no `kind` field at all** | `artifactquest` — white ring, BLUE centre, 8px | 2 |
| **combatleg** | position at a moment, **during a pull** | the same call with `point.combat = true` and `n` = the pull index | `playerenemy` — white ring, RED centre, 8px | 1 |
| **start** | where a pull began | `Store.AddMarker(…, "start", pulls)` | horde barracks — crossed swords, RED, 16px | 4 |
| **end · done** | where a pull ended, alive | `Store.AddMarker(…, "end", …)` with no `dead` | alliance barracks — crossed swords, BLUE | 3 |
| **end · dead** | ★★★ **A TERMINAL STOP** — see below | the same marker with `dead`, plus `killedBy` and `killedByUnavailable` | `islands-markedarea` — a red CROSS | 5 |
| **pin** | a moment the client does not emit | `Widget.Pin()` → `Store.AddMarker(…, "pin", …)`. A person pressed a button | `racing` — a chequered flag | 6 |
| **beacon** | an instruction placed on the route | minted at promotion | ★ **its OWN ICON**, the field the user picked | 7 |
| **child** | one signal or instruction under a beacon | `routes.lua` · `place.kind = "child"` | the child crop | **8** |
| **note** | something you said to yourself | `routes.lua` · `p.kind = "note"` | `chatballon` — a speech balloon | 9 |

### ★★★ THE TERMINAL STOP — `end · dead`, and what it actually holds

> **A TERMINAL STOP: the route ended here, and this is what stopped it.**

★ **`dead = true` on the end marker plus its position IS the terminal stop** (DR-13). DeathRecap
adds exactly one thing worth having: **WHO**. *"`Molten Elemental ×7` turns "a wipe happened here"
into "this pull is where runs die" — which is route meaning."*

**DR-32, in full:** `killedBy` on a terminal stop — **distinct attackers** from
`AscensionUI.DeathRecap`, **read at `PLAYER_DEAD`**, **spent at the end marker**, and **only when
`dead`**.

    dead                  stamped ONLY when true. Absent means the pull did not end that
                          way - without it a wipe and a clean finish are indistinguishable
    killedBy              the distinct attackers, spent once
    killedByUnavailable   WHY it could not be read, when it could not

⚠⚠ **Three facts underneath it that are silent, and each cost something to find:**

**1. `AscensionUI.DeathRecap` is readable ONLY at `PLAYER_DEAD`.** Any other moment gives
`CurrentRecap` instead. ★ So the value is captured at death and held as `pendingKilledBy` until
the end marker exists — **a read that cannot be retried.**

**2. The recap covers the last ~14 seconds and does NOT only contain enemies.** Without a guard it
put *"Gravereaper"* — his own character — into a `killedBy` in `RFC_Run3_Messy`. ⚠ **Without that
guard `killedBy` means "who appeared in the last 14 seconds"**, which is not what the field says.

**3. ★ The guard for *"attribution only on a terminal stop"* went SILENT once.** A test set
`dead = false` on a *later* pull, by which point the pending value had already been spent — so the
guard could not fire. Replaced with a **battle rez**: die, get resurrected, combat then drops.
**Not a contrivance — it is what happens in a dungeon.**

### ⚠ And `end · done` has no parity with it — yet

A terminal stop records *dead*, *who*, and *where*. **A pull you survived records only where and
when**, so every survived pull looks equally survived and only the one that killed you is
distinguished. ★ §205's **HP at pull end is the margin** that closes it — finishing at 4% is nearly
a terminal stop; finishing at 95% was never close.

☐ **A survived pull has no margin.** HP at pull end, so an `end · done` carries something comparable to a terminal stop's `killedBy`. Not built.

### ★★★ THE MECHANICAL BASIS — which API every one of these rests on

_*"The source of truth should enable us to inspect it in code from what it uniquely shows it_
_functions on. More so with the WoW API as we depend on them."*_

**Every fact above is a client call.** ⚠ So this table is the real dependency list: **if one of
these changes, the row that names it is what breaks** — and nothing else has to be searched for.

| what we claim | the call that provides it | what can make it wrong |
|---|---|---|
| **world position** `x · y · z · mapID` | `GetCurrentPlayerPosition()` | ⚠ **an Ascension global, not stock 3.3.5.** The whole record rests on a fork API |
| **map fraction** `mapX · mapY` | `GetPlayerMapPosition("player")` | ⚠ answers about **the map the WORLD MAP IS SHOWING**, not where you stand |
| **continent · zone · floor** | `GetCurrentMapContinent()` · `GetCurrentMapZone()` · `GetCurrentMapDungeonLevel()` | same exposure — all three follow the open map |
| **the art to draw on** | `GetMapInfo()` → mapFile, w, h · `DungeonUsesTerrainMap()` | same again, and **write-once**: a wrong file is permanent |
| **join clock** `t` | `time()` | whole seconds only. DR-4: this is the one that **joins** |
| **measure clock** `gt` | `GetTime()` | monotonic within a session, no wall anchor of its own |
| **in a pull** `combat` · `n` | `UnitAffectingCombat("player")` | DR-1 — **read the STATE, do not infer it** |
| **corpse run** `ghost` | `UnitIsGhost("player")` | DR-13, one read on a tick already running |
| **who killed you** `killedBy` | `AscensionUI.DeathRecap`, at `PLAYER_DEAD` | ⚠ fork API, **readable at that one moment only** |

### What DRIVES each write

    LEGS         an OnUpdate accumulator, SAMPLE_EVERY = 1.0 (DR-3), gated on
                 runId and inInstance() before anything is read
    START        PLAYER_REGEN_DISABLED    -> AddMarker(…, "start", pulls)
    END          PLAYER_REGEN_ENABLED     -> AddMarker(…, "end", pulls, dead, by, why)
    the WHO      PLAYER_DEAD              -> pendingKilledBy, spent at the end marker
    instance     PLAYER_ENTERING_WORLD · ZONE_CHANGED_NEW_AREA
    boss names   INSTANCE_ENCOUNTER_ENGAGE_UNIT

★★ **The sampler's own names, for the same reason:** `capture.lua` · `onUpdate(_, elapsed)` ·
`SAMPLE_EVERY = 1.0`, installed by `Capture.Arm` and cleared by `Capture.Stop`.

⚠ **ONE OF TWO IN THE ADDON.** Its twin is Curation's playback step — `editor.lua` · `tick(_,
elapsed)` · `STEP_EVERY = 1.0`, on `editor.play`'s row in `curation.md`. **The same accumulator
pattern, byte for byte, with its own `acc`.** ★ Not shared and not to be: their LIFETIMES differ —
one lives for a run, the other for a playback — so a single clock would couple two unrelated
features. **Named on both sides so a THIRD copy is a decision rather than an accident.**

★★★ **So a leg is a TICK and a start/end is an EVENT** — and that is the whole difference between
them. A leg is *where you were once a second*; a start is *the moment the client said combat*. ⚠
**Neither is a guess, and neither is the other's kind of truth.**

### ⚠ Three rulings the basis carries

**1. ⚠⚠ THERE IS AN OnUpdate, AND IT IS SCOPED TO A RUN.** `SetScript("OnUpdate", onUpdate)` at arm,
`SetScript("OnUpdate", nil)` at disarm. ★ *"Zero persistent OnUpdate"* means **outside a run** —
during one there is exactly one, at 1 Hz, and it is the sampler. Worth saying plainly, because the
census phrase reads as an absolute and is not.

★★★ **AND IT STAYS.** A move to `C_Timer` was decided, tested, and withdrawn — measured twice,
at 20 fps and 137 fps, the two mechanisms agree to a mean of **0.00000s** and never diverge by more
than **1ms**. **`C_Timer` is the frame loop wearing a different name**, so a rewrite of the capture
path would buy nothing measurable. `planning/timed_breakdown_scope.md` carries the numbers.

**2. ★★ THE THROTTLE SITS BEFORE THE WORK.** *"The addon census caught COA_Landmarks calling
`GetCurrentPlayerPosition()` 59 times a second and throwing the result away — the throttle was real
and sat in the wrong place."* ⚠ A float compare returns first; nothing is read until the second is
up.

**3. ★★★ DEFER, DO NOT DROP — and §66 got it exactly backwards.** The map art is written **only
when the world map is CLOSED**, and retried every tick until it lands. §66 instead REFUSED to write
unless it could confirm we were looking at ourselves, comparing `GetCurrentMapAreaID() - 1` against
the player's mapID — *an assumption about two id spaces that was never verified.* ⚠ **It failed
CLOSED, which is the worse failure**: a missing mapFile is write-once and permanent, so the run was
in-zone-only forever. Caught as a regression on the first runs after it shipped.

☐ **`GetCurrentPlayerPosition` and `AscensionUI.DeathRecap` are FORK APIs**, and the two most
load-bearing calls in the addon. `operations/ROUTER.md` is where a client behaviour is recorded —
neither has a row there yet.

### ⚠⚠ Four rulings that live only in comments today

**1. `combatleg` is decided BEFORE `kind` is consulted.** *"Checked before `kind` so a marker is
never mistaken for one — markers carry `n` too, and only legs carry `combat`."* ★ The two share a
field, and the order of the test is what keeps them apart.

**2. ★★★ A BEACON DRAWS AS ITS ICON, AND AN UNKNOWN ICON FALLS BACK.** *"A route authored on a
later build with a word we do not have draws as a beacon instead of erroring."* ⚠ That is a
**forward-compatibility decision** sitting in a comment — and it is the same posture as `unpackage`
refusing a version it does not know, one layer down.

**3. ★★ A CHILD RANKS ABOVE ITS OWN ANCHOR, and it is not a taste call.** `AddChildHere` mints one
at EXACTLY the beacon's position, so a child ranking below would be **un-clickable and
un-selectable — buried under the thing that made it.** ★ The ladder decides the CLICK as well as
the draw, which is the whole reason it exists.

**4. ⚠ EVERY BEACON ICON NEEDS A RANK ROW.** `kill` is a WORD a beacon wears, not a kind — so it
ranks 7, the same as `beacon`. **An unranked key falls to list order**, which is the exact fault
the ladder prevents, in the one place nobody would look.

### What every point carries, before any of the above

    x · y · z · mapID          world position
    mapX · mapY · mapC · mapZ  map fraction
    floor                      DR-33 - without it a multi-floor run is permanently unplaceable
    t = time()                 wall clock. DR-4 says this one JOINS
    gt = GetTime()             monotonic, sub-second. This one MEASURES

★ Then per kind: `kind` · `n` (pull index) · `combat` · `dead` · `killedBy` ·
`killedByUnavailable` · `ghost` (a corpse run, so DR-13 keeps it legible).

☐ **The icon vocabulary has an open word.** *"The word for 'stop, there's a jump, a thing, not just
movement' is still OPEN — his to choose, and one row when it lands."* Three exist: `note`,
`beacon`, `kill`. ⚠ Each icon is a WORD in a curated vocabulary, **not a picker over 3,144
entries** — so adding one is a design act, and it needs an `ART` row and a `RANK` row together.

---

## Outstanding

<!-- OUTSTANDING:BEGIN - emitted by emit_outstanding.py, do not edit by hand -->

8 items:

- Not declared in `panespec.lua`. Every number is hand-typed in `map.lua`.
- `gt` is written on every point and read NOWHERE (§226). `store.lua`:142 and :330 stamp `t = time(), gt = GetTime()` on every point `Store.Point()` builds, and all six spawn paths go through it. Every live consumer takes `t` — the timeline span :627, floor-at-a-moment :721, `Map.InWindow` :787, the tooltip :1092. ★ NOT a defect: nothing addresses a sample, so nothing needed it. It is the unused half of the `t:gt` pair the address sheets name, and the first note or icon on a sample is what cashes it in.
- THE ICON HAS NO PICKER YET. `Routes.SetChildIcon` validates against the palette and the map draws it; nothing offers the choice. ★ Deferred deliberately — *"that's part of the overhaul. Might be a tab solution. Or a face picker."* ⚠ MEASURED, AND NARROWER THAN I CLAIMED (§239). `object.target` spans 519.8–551.8 and a non-empty `object.hint` spans ~516–526 — a 6.2px overlap, the arithmetic confirmed. ★ But it needs THREE things at once: a child selected, an action that USES a target (or `target` stays hidden), and `hint` carrying text — empty, it collapses to 1px and there is nothing to hit. Two captures caught neither combination. ★ Not introduced by the icon work: the child pane has no free row, and THAT is the thing to fix rather than the pixels. *"Icon should never have been an identity claim. As there's no uniqueness."* `Map.ArtKey` returns a beacon's icon, and five call sites consume that key — only `ArtForPoint` is asking about appearance; the other four ask what a thing IS. ⚠ `Map.Rank` resolves through it, and `child = 8` against `kill = 7` means an iconed child would tie with the beacon it is minted exactly on top of. Art answers what you look like; rank answers what you are. Full reasoning in `dungeonrun_model.md`.
- A survived pull has no margin. HP at pull end, so an `end · done` carries something comparable to a terminal stop's `killedBy`. Not built.
- `GetCurrentPlayerPosition` and `AscensionUI.DeathRecap` are FORK APIs, and the two most load-bearing calls in the addon. `operations/ROUTER.md` is where a client behaviour is recorded — neither has a row there yet.
- The icon vocabulary has an open word. *"The word for 'stop, there's a jump, a thing, not just movement' is still OPEN — his to choose, and one row when it lands."* Three exist: `note`, `beacon`, `kill`. ⚠ Each icon is a WORD in a curated vocabulary, not a picker over 3,144 entries — so adding one is a design act, and it needs an `ART` row and a `RANK` row together.
- Unverified until the next capture: this is written and not yet measured.
- `map.readout` holds nine FontStrings of its own — a title and four key/value rows — declared as one frame. Same question as the tile pattern: one row for a family, and the members uncounted.

<!-- OUTSTANDING:END -->

---

★★★ **The pane walk now sees readouts (§133).** `GetChildren` returns frames; a FontString is a
REGION, so all 21 registered readouts were reachable by a typed line and had never been measured.
`task_geom`'s pane walk grew the second loop the REFERENCE walk had from the start — regions
enumerated, keys resolved the same way, and a readout's `text` recorded beside its rect because the
text is what its width is a consequence of.

⚠ **The gap was only ever in OUR half** — the half nobody was comparing against a second source.
☐ Unverified until the next capture: this is written and not yet measured.

☐ **`map.readout` holds nine FontStrings of its own** — a title and four key/value rows — declared
as one frame. Same question as the tile pattern: one row for a family, and the members uncounted.


## Hopes and dreams

_What this surface still needs so **the model** can be realized (`dungeonrun_model.md`). Not technical — the backlog to realize._

_Nothing recorded yet._ ⚠ Empty on purpose — this half is his, and inventing hopes on his
behalf would put fiction in the one place meant to read as direction.
