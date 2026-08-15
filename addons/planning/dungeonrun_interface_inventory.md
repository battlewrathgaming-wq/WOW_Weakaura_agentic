# DungeonRun interface inventory — the source of truth

★★★ **This file is the AUTHORITY, not a report.** It is not generated from the code and it does not
mirror it. The code has to comply with what is written here; where the two disagree, **the code is
wrong** until we decide otherwise. His ruling:

> *"Once made, the inventory is authority / source of truth until our consideration changes."*

★★ **And nothing reaches the client that is not in here first.**

> *"It is allocated on the disk first, then makes it in-game after geometry checks. […] If we don't
> know how we'll track it, don't add it to the game until we know how."*

★★★ **And what it is FOR, in his words:**

> *"Collating all the abstracts into a fixed reasoning space."*

⚠ Which is why every seeding pass has found something. A number in a source file is a fact
about that file; the same number written HERE has to sit beside the others and answer to them.
Curation's dead space, three unregistered dropdowns, an orphaned header, a 5px nudge nobody
could explain - none of them were hidden. They were just never in one place at one scale.

⚠ **Seeded once from the code as it stood on 2026-08-15**, because the first version has to come from
somewhere. From this point it is authored. Every ⚠ below is a place the code does not yet match.

---

## The slots

| slot | what it expresses |
|---|---|
| **pane** | which window it lives in |
| **zone** | which group, under which header |
| **row** | its line within that zone |
| **span** | `full` · `left` · `right` — never an x |
| **kind** | dropdown · edit · check · button · readout |
| **job** | one line on what it is *for* |
| **subjects** | when it applies |
| **numbers** | the settled values, so the geometry tool has something to **assert** rather than only recompute |
| **build** | the code that makes it exist in-game, for inspection |

★★★ **No pixels in the intent slots.** A `108` expresses *"second column"* — write the 108 and we keep
the arithmetic and lose the reason. `layout.lua` derives every offset from its constants.

★★★ **`numbers` and `build` sit next to each other on purpose.** That adjacency is what caught the
field-vs-art bug: `build` said `SetWidth(200)` and `numbers` said the art is 250, and the play button
was sitting in the 50 nobody had accounted for.

⚠ **A dropdown has three widths and they are not interchangeable** (`layout.lua`, sourced from
`SharedXML/UIDropDownMenu.lua:962`):

    field  w        the sunken area the selection reads in
    text   w - 25   the string inside that field
    art    w + 50   the frame, and the arrow that reacts to a click

---

## Object pane

**320 × 600.** Content column starts at x=18 and is **204** wide. Declared in
`addons/COA_DungeonRun/panespec.lua`; built by `object.lua`.

⚠⚠ **The pane is NOT yet built from the spec.** Every `build` line below is the hand-positioned code
as it stands, and the disagreements are listed rather than quietly reconciled.

### zone: identity — always shown

```
object.fact
  zone      identity          row 1        span full        kind readout
  job       what this object is, in one line
  subjects  all (including none selected)
  numbers   w 204 · h 14
  build     object.lua:432  f:CreateFontString(nil,"OVERLAY","GameFontDisableSmall")
            SetWidth(204)
  ⚠ NOT REGISTERED — invisible to the geometry probe
```

```
object.name
  zone      identity          row 2        span left+       kind edit
  job       rename this object
  subjects  beacon · child · note
  numbers   w 170 · h 20
  build     object.lua:424  CreateFrame("EditBox","COA_DungeonRunObjectName",f,"InputBoxTemplate")
            SetWidth(192); SetHeight(20)
  ⚠ build says 192, inventory says 170
```

```
object.move
  zone      identity          row 2        span right-edge  kind check
  job       drag this object to a new place on the map
  subjects  beacon · child · note
  numbers   w 26 · h 20
  build     object.lua:438  CreateFrame("CheckButton","COA_DungeonRunObjectMove",f,"UICheckButtonTemplate")
            SetWidth(20); SetHeight(20)
  ⚠ the template is 32x32; we override to 20. Inventory says 26 wide — reconcile
```

```
object.delete
  zone      identity          row 3        span left        kind button
  job       remove this object from the route
  subjects  beacon · child · note
  numbers   w 80 · h 20
  build     object.lua:453  CreateFrame("Button",nil,f,"UIPanelButtonTemplate")
            SetWidth(70); SetHeight(20)
  ⚠ build says 70, inventory says 80
```

### zone: behaviour — child only

★ Detect, then act, in that reading order — his model: *"Detect sits above action."*

```
object.role
  zone      behaviour         row 1        span full        kind dropdown
  job       which detector this child uses
  subjects  child
  numbers   field 154 · text 129 · art 204 · h 32
  build     object.lua:639  CreateFrame("Frame","COA_DungeonRunObjectRole",f,"UIDropDownMenuTemplate")
            UIDropDownMenu_SetWidth(roleDD, 96)
  ⚠ build asks 96 → 146 of art. Inventory says 154 → 204
```

```
object.match
  zone      behaviour         row 2        span full        kind readout
  job       whether another child already claims this role
  subjects  child
  numbers   w 204 · h 14
  build     object.lua:668  roleMatch — f:CreateFontString(...,"GameFontDisableSmall")
  ⚠ NOT REGISTERED · named `roleMatch` in code, `object.match` here
```

```
object.shape
  zone      behaviour         row 3        span full        kind dropdown
  job       the shape of this child's detection volume
  subjects  child
  numbers   field 154 · text 129 · art 204 · h 32
  build     object.lua:681  CreateFrame("Frame","COA_DungeonRunObjectShape",f,"UIDropDownMenuTemplate")
            UIDropDownMenu_SetWidth(shapeDD, 96)
  ⚠ build asks 96 → 146 of art
```

```
object.reach
  zone      behaviour         row 4        span left        kind edit
  job       how far the detection reaches
  subjects  child
  numbers   w 96 · h 20
  build     object.lua:715  radBox — numBox("COA_DungeonRunObjectRad", 56, …)  SetWidth(38)
  ⚠ NOT REGISTERED · build says 38, inventory says 96 · code name `radBox`
  ⚠ `setBox` (object.lua:671) also exists and is not in this inventory — JUSTIFY OR CUT
```

```
object.action
  zone      behaviour         row 5        span full        kind dropdown
  job       what this child does once it has detected the player
  subjects  child
  numbers   field 154 · text 129 · art 204 · h 32
  build     object.lua:753  CreateFrame("Frame","COA_DungeonRunObjectAction",f,"UIDropDownMenuTemplate")
```

```
object.target
  zone      behaviour         row 6        span full        kind dropdown
  job       which object the action points at
  subjects  child
  numbers   field 154 · text 129 · art 204 · h 32
  build     object.lua:776  CreateFrame("Frame","COA_DungeonRunObjectTarget",f,"UIDropDownMenuTemplate")
  ⚠⚠ NOT REGISTERED — a DROPDOWN the probe cannot see. Same class as the route selector
```

### zone: stage — beacon and child

★ The ratchet, the on-ramp and `unseen` are all answers to *what happens when the player gets here*.

```
object.stage
  zone      stage             row 1        span left        kind edit
  job       the stage number this object satisfies
  subjects  beacon · child
  numbers   w 96 · h 20
  build     object.lua:475  CreateFrame("EditBox","COA_DungeonRunObjectStage",f,"InputBoxTemplate")
            SetWidth(44); SetHeight(20)
  ⚠ build says 44, inventory says 96
```

```
object.stagematch
  zone      stage             row 1        span right       kind readout
  job       whether another object already holds this stage number
  subjects  beacon · child
  numbers   w 96 · h 14
  build     object.lua:517  matchText — f:CreateFontString(...,"GameFontDisableSmall")
  ⚠ NOT REGISTERED · code name `matchText`
```

```
object.outcome
  zone      stage             row 2        span full        kind dropdown
  job       what satisfying this object does to the stage index
  subjects  beacon · child
  numbers   field 154 · text 129 · art 204 · h 32
  build     object.lua:528  CreateFrame("Frame","COA_DungeonRunObjectOutcome",f,"UIDropDownMenuTemplate")
            UIDropDownMenu_SetWidth(outcomeDD, 92)
  ⚠⚠ NOT REGISTERED — second unseen dropdown · build asks 92 → 142 of art
  ⚠ `outcomeBox` (object.lua:547) also exists and is not in this inventory — JUSTIFY OR CUT
```

```
object.ramp
  zone      stage             row 3        span left        kind check
  job       this object is the on-ramp — come find me
  subjects  beacon · child
  numbers   w 26 · h 20
  build     object.lua:740  CreateFrame("CheckButton","COA_DungeonRunObjectRamp",f,…)
            SetWidth(20); SetHeight(20)
```

```
object.unseen
  zone      stage             row 3        span right       kind check
  job       satisfied without being seen
  subjects  beacon · child
  numbers   w 26 · h 20
  build     object.lua:722  CreateFrame("CheckButton","COA_DungeonRunObjectUnseen",f,…)
            SetWidth(20); SetHeight(20)
```

```
object.answers
  zone      stage             row 4        span full        kind readout
  job       the three answers this object gives — on-ramp, note, ratchet
  subjects  beacon · child
  numbers   w 204 · h 14
  build     object.lua:814  answersLine — f:CreateFontString(...,"GameFontDisableSmall")
            SetPoint("TOPLEFT", 18, -96); SetWidth(204)
  ⚠ NOT REGISTERED · hand-placed at a fixed y=-96
```

### zone: children — beacon only

```
object.kids
  zone      children          row 1        span full        kind readout
  job       how many children this beacon has
  subjects  beacon
  numbers   w 204 · h 14
  build     object.lua:577  kidText — f:CreateFontString(...,"GameFontDisableSmall")
  ⚠ NOT REGISTERED
```

```
object.here
  zone      children          row 2        span left        kind button
  job       spawn a child at the player's current position
  subjects  beacon
  numbers   w 80 · h 20
  build     object.lua:583  CreateFrame("Button",nil,f,"UIPanelButtonTemplate")  SetWidth(100)
  ⚠ build says 100, inventory says 80
```

```
object.pick
  zone      children          row 2        span right       kind button
  job       spawn a child from a point picked on the map
  subjects  beacon
  numbers   w 80 · h 20
  build     object.lua:606  CreateFrame("Button",nil,f,"UIPanelButtonTemplate")  SetWidth(100)
  ⚠ build says 100, inventory says 80
```

### footer — not a zone

★ It has no divider and no header, because it is not a section of the object. It is a readout about
the last thing you did.

```
object.test
  zone      (footer)          row —        span full        kind readout
  job       ★★★ THE CONTEXT READOUT. One high-contrast space at the foot of the pane, fed by
            hover or last action, that replaces the scattered grey lines. His:
            *"a context specific read out based on hover or last action"* and
            *"at the bottom is fine. Training the eyes the same way the driver widget will do."*
  subjects  all
  numbers   w 204 · h 14        ⚠ CONTRAST NOT YET SPECIFIED — currently GameFontDisableSmall
  build     object.lua:871  testLine — f:CreateFontString(...,"GameFontDisableSmall")
            SetPoint("TOPLEFT", 18, -226); SetWidth(204)
  ⚠ NOT REGISTERED · hand-placed at a fixed y · ⚠ hover half not built; last-action half works
```

---

## Promotion pane

**320 × 400.** Built by `promoter.lua`.

⚠⚠ **NOT DECLARED AT ALL.** There is no promoter block in `panespec.lua`, so no zone, row or span
exists for anything below — its numbers are hand-typed in the client code and nothing offline
watches them. ★ This is the pane that produced the field-vs-art bug, and it is the pane with no
declaration. That is not a coincidence.

```
promoter.route
  zone      —  ⚠ undeclared    row —        span —           kind dropdown
  job       which route is loaded
  subjects  all
  numbers   field 200 · text 175 · art 250 · h 32     at x=2
  build     promoter.lua:390  CreateFrame("Frame","COA_DungeonRunRouteLoad",f,"UIDropDownMenuTemplate")
            UIDropDownMenu_SetWidth(dd, 200)
  ★ registered §103 — it was invisible to the probe before that
```

```
promoter.play
  zone      —  ⚠ undeclared    row —        span —           kind button
  job       TEST-drive the loaded route. ★ Where it came from, in his words: *"We
            started making a driver for the recorder. But as a test tool. And that
            is where the play option in promotion came from."* It is the recorder
            checking its own output, not a player running a route
  subjects  all
  numbers   w 52 · h 20        at x=258, clear of the route art at 252
  build     promoter.lua:414  CreateFrame("Button",nil,f,"UIPanelButtonTemplate")
            SetWidth(52); SetHeight(20); SetPoint("TOPLEFT", 258, -78)
            OnClick -> NS.Walk.StartLines() / NS.Walk.Stop()
  ⚠ DECLARED: it SPAWNS the Test Drive pane and the walk is watched there.
     His: *"the play button should spawn that widget."*
  ⚠⚠ TODAY it drives `walk.lua` and reports through `NS.Say` - the CHAT WINDOW.
     The Test Drive pane is a readout built for exactly this and is not on the
     path. A surface that exists and is wired to nothing
  ★ the field/art bug lived here — 44x20 under the dropdown until §104
```

```
promoter.note      job  mint a personal note        numbers w 110 · h 20   build promoter.lua:379
promoter.create    job  mint a beacon into the route numbers w 110 · h 20  build promoter.lua:470
promoter.name      job  name the route              numbers w 272 · h 20   build promoter.lua:406
promoter.stage     job  the stage to mint at        numbers w 40 · h 20    build promoter.lua:511
                                                    ⚠ NOT REGISTERED
promoter.inherit   job  what carries over from the node   readout w 284    build promoter.lua:466
                                                    ⚠ NOT REGISTERED
promoter.count     job  beacons and notes at this point   readout w 284    build promoter.lua:538
                                                    ⚠ NOT REGISTERED
promoter.hint      job  what to do next             readout w 284          build promoter.lua:542
                                                    ⚠ NOT REGISTERED
```

⚠ **`stageGhost` (promoter.lua:47) is not in this inventory.** JUSTIFY OR CUT.

---

## The panes

★★★ **A pane is an inventory item in its own right.** The elements live inside it, so a file
that describes only the elements cannot describe where they are. His rule:

> *"It is the total, stable, numeric and detail descriptor of anything that exists, related to
> that inventory. If you can't describe it from that file, we're blind."*

★★ **Two slots a pane has that an element does not:**

| slot | what it expresses |
|---|---|
| **column** | the content x and usable width every element's `span` resolves against |
| **relates** | ties to other panes — shared edges, stacking. Decisions that otherwise live nowhere |

★ **And it lists its children**, so the pane is a map of itself rather than something you
reconstruct by scanning. ✅ = the child has its own entry below; ❌ = named only.

⚠ **Enumerated from source**, not remembered — every top-level frame parented to `UIParent`.
The list this replaces named three panes, conflated `widget.lua` with `map.lua`'s controls, and
missed the map frame entirely.

---

## ★★★ The opening chain

Which pane opens which. His: *"Currently it's the only spawning surface for the map. That then
opens curation. That then opens promotion."*

    Recorder Remote ── starts a run
                    └─ opens Map ─┬─ opens Map controls
                                  └─ opens Curation ── opens Promotion ── mints into Object

    Driver  ⚠ not on this chain, and should not be given a door onto it. It is the seed of
            DungeonRun Drive - a SECOND addon with its own remote. `/dr drive` for now

★★ **The Remote is the only front door**, so everything downstream is reachable only through it.
That is worth knowing before anything is moved: a change to the Remote is a change to whether the
rest of the addon can be reached at all.

## ★★★ DECIDED - it is a REMOTE

> *"So it's DungeonRun_Recorder_Remote (Like a remote to a TV.)*
> *Then DungeonRun_Drive (The addon that people use just to run routes) will have _remote as its
> primary entry."*

★★ **`_Remote` is a PATTERN, not a name.** An addon's remote is the one surface that turns it on
and reaches everything else - small, always to hand, and not the thing itself. A TV remote is not
the television.

★★★ **And it says there are TWO ADDONS, not one:**

| addon | who it is for | its remote |
|---|---|---|
| **DungeonRun Recorder** | us - capture, curate, author routes | `DungeonRun_Recorder_Remote` |
| **DungeonRun Drive** | players who only want to RUN a route | `DungeonRun_Drive_Remote` |

⚠⚠ **WHICH EXPLAINS THE DRIVER'S MISSING DOOR.** `driver.lua` was never an unfinished part of the
recorder - it is **the seed of the second addon**, sitting in the first one. That is why nothing
opens it and why he had not seen it: there is no door because the door belongs to an addon that
does not exist yet.

★ It also settles what the Driver's `relates` means. It does not join the recorder's chain, and
it should not be given a button to make it look like it does.

⚠ **DECLARED HERE, CODE DOES NOT COMPLY YET.** The frame is still `COA_DungeonRunFrame`. Per the
standing rule the name is settled on disk first and the code follows - so this entry is the
authority and `widget.lua` is now out of date with it.

---

```
object.pane
  pane      Object               global  COA_DungeonRunObject
  kind      pane
  job       edit one selected beacon, child or note
  subjects  always (holds a hint when nothing is selected)
  column    x 18 · width 204
  relates   —
  numbers   w 240 · h 600
  build     object.lua:396  CreateFrame("Frame","COA_DungeonRunObject",UIParent)
            SetWidth(240); SetHeight(600)
  children  ✅ fact · name · move · delete · role · match · shape · reach · action · target
            ✅ stage · stagematch · outcome · ramp · unseen · answers · kids · here · pick · test
            ❌ setBox (object.lua:671) · outcomeBox (object.lua:547) - JUSTIFY OR CUT
```

```
promoter.pane
  pane      Promotion            global  COA_DungeonRunPromoter
  kind      pane
  job       load a route, and mint beacons and notes into it
  subjects  always
  column    x 18 · width 284
  relates   ★ Curation matches this WIDTH; the two stack and share one vertical edge.
            Height is each pane's own - it answers to what the pane holds.
  numbers   w 320 · h 400
  build     promoter.lua:345  CreateFrame("Frame","COA_DungeonRunPromoter",UIParent)
            SetWidth(320); SetHeight(400)
  children  ✅ route · play · note · create · name · stage · inherit · count · hint
            ❌ stageGhost (promoter.lua:47) - JUSTIFY OR CUT
  ⚠ no zone/row/span for any of them - this pane is not in panespec.lua
```

```
editor.pane
  pane      Curation             global  COA_DungeonRunEditor
  kind      pane
  job       load a run and slice it - rename, comment, filter by kind, window by time
  subjects  always
  column    x 18 · width 284
  relates   ★ width matched to Promotion (§107) for the stacked edge
  numbers   w 320 · h 366
  build     editor.lua:252  CreateFrame("Frame","COA_DungeonRunEditor",UIParent)
            SetWidth(320); SetHeight(366)
  children  ✅ title · run · rename · delete · comment · showlabel · kind.<key> · bar
            ✅ handle.<a|b> · width · step.<n> · play · skip · peek · latch · reset
            ✅ track · hint · promote
  ★ the "Controls / Curate" text he saw is the MAP's two buttons reading through this
    pane's backdrop - Curation is DIALOG, the Map is HIGH. Not this pane's widgets.
```

```
map.pane
  pane      Map                  global  COA_DungeonRunMap
  kind      pane
  job       draw a run and a route onto the client's own tiles
  subjects  always
  column    x 18 (MARGIN + 2) · width ART_W - 4
  relates   opens the Map controls and the Curation pane
  numbers   ⚠⚠ COMPUTED, not declared - and this is why it could not be seeded with the rest:
            w = ART_W + MARGIN * 2   = 1002 + 32  = 1034
            h = ART_H + STRIP + FOOT = 668 + 40 + 14 = 722
            ART_W, ART_H  map.lua:57    1002 x 668, the COORDINATE space
            MARGIN, STRIP, FOOT  map.lua:2128    16, 40, 14
  build     map.lua:2137  CreateFrame("Frame","COA_DungeonRunMap",UIParent)
            SetWidth(ART_W + MARGIN * 2); SetHeight(ART_H + STRIP + FOOT)
  children  ❌ title · ref · viewport (ScrollFrame, COA_DungeonRunViewport) · canvas + tile textures
            ❌ ctlBtn · editBtn · prevBtn · floorText · nextBtn · readout (+ its title and rows)
  ★ Its numbers slot is a RULE with four named constants, not a pair. That is the shape any
    computed pane needs, and it is why the rule had to be settled before seeding.
```

```
mapcontrols.pane
  pane      Map controls         global  COA_DungeonRunMapControls
  kind      pane
  job       zoom, pan, recentre and reset the map view
  subjects  always (opened from the Map)
  column    x 18 · width 204
  relates   belongs to the Map; opened by its ctlBtn
  numbers   w 240 · h 168
  build     map.lua:1848  CreateFrame("Frame","COA_DungeonRunMapControls",UIParent)
            SetWidth(240); SetHeight(168)
  children  ❌ title · control buttons (map.lua:1874, stage/pan pad/recentre/reset)
            ❌ wheelTick (COA_DungeonRunWheelZoom) · panTick (COA_DungeonRunRightPan)
  ★ Both ticks default OFF on purpose: the wheel belongs to the world camera and right-drag
    to camera-look, and an addon should not take either without being asked.
```

```
recorder_remote.pane
  pane      Recorder Remote      global  ⚠ declared COA_DungeonRunRecorderRemote
                                         code still says COA_DungeonRunFrame
  kind      pane (remote)
  job       the remote for the Recorder - start a run, pin a point, open the map.
            ★ Like a remote to a TV: the one surface that turns it on and reaches
            everything else, and not the thing itself
  subjects  always
  column    x 16 · width 208
  relates   opens the Map
  numbers   w 240 · h 124
  build     widget.lua:65  CreateFrame("Frame","COA_DungeonRunFrame",UIParent)
            SetWidth(240); SetHeight(124)
  children  ❌ title · pinBtn · nameBox · countText · armBtn · mapBtn
  ⚠ its inset is 16, not the 18 every other pane uses. Reconcile or justify
  ⚠ RENAME PENDING - see "DECIDED - it is a REMOTE" above. Frame name, file name and
    every reference move together or not at all
```

```
testdrive.pane
  pane      Test Drive           global  ⚠ declared COA_DungeonRunTestDrive
                                         code still says COA_DungeonRunDriver
  kind      pane
  job       WATCH a route being test-driven - which stage, and what satisfies it.
            ★ His: *"the current drive should be renamed Test_drive."* It is the
            recorder checking its own output. The thing players will eventually
            use is a different addon, DungeonRun Drive, with its own remote
  subjects  ⚠ DECLARED: spawned by `promoter.play`. Today it is created hidden
            (driver.lua:290) with `/dr drive` (core.lua:137) as its only door -
            no pane opens it and no button spawns it. ★ That is why he said
            "Driver doesn't exist yet from what I know": a surface with no door
            is indistinguishable from one that was never built
  column    x 18 · width 204
  relates   ★ the readout at its foot is the pattern the object pane's footer copies -
            *"training the eyes the same way the driver widget will do"*
            ⚠⚠ AND NOTHING FEEDS IT. `promoter.play` runs `walk.lua` and reports to
            CHAT; `walk.lua` borrows `Driver.Reached` for the detection maths and
            nothing else. So driver.lua does two unrelated jobs - the maths, which
            IS used, and this readout, which is not.
            ★ Separating those two is the real question behind the rename: the maths
            belong to whoever detects, and the readout belongs to DungeonRun Drive
  numbers   w 240 · h 110
  build     driver.lua:273  CreateFrame("Frame","COA_DungeonRunDriver",UIParent)
            SetWidth(240); SetHeight(110)
  children  ❌ title · dd (route select) · armBtn · readout
```

---

★★ **Two of seven have element entries; all seven now have a pane entry.** Nothing in the five
without element entries may change until they are in here.

## Curation pane

**320 × 366.** Content column x=18, width **284**. Built by `editor.lua`; not in `panespec.lua`.

⚠⚠ **THE PANE GOT WIDER AND THE CONTENT DID NOT.** §107 took it 280 → 320 for the shared edge
with Promotion, but every x and width below is still laid out for 280. The time bar is 244 in a
284 column; the tick rows, the buttons and the step pad all sit where they sat. **That is the
dead space he named**, and I made it — widening a pane without widening what is in it.

★ Listed as disagreements rather than silently fixed. The inventory is where that decision gets
made.

### zone: identity

```
editor.title
  zone      identity          row 1        span full        kind readout
  job       names the pane
  subjects  always
  numbers   at (18, -16) · GameFontNormal · text "Curation"
  build     editor.lua:282  f:CreateFontString(nil,"OVERLAY","GameFontNormal")
  ⚠ NOT REGISTERED
```

```
editor.run
  zone      identity          row 2        span full        kind dropdown
  job       which captured run is loaded
  subjects  always
  numbers   field 200 · text 175 · art 250 · h 32 · at x=2
  build     editor.lua:286  CreateFrame("Frame","COA_DungeonRunRunLoad",f,"UIDropDownMenuTemplate")
            UIDropDownMenu_SetWidth(dd, 200)
  ⚠⚠ NOT REGISTERED — a DROPDOWN the geometry probe cannot see. Third of its kind
  ⚠ art ends at 252 in a column that now runs to 302 — 50 short since §107
```

```
editor.rename        job rename the loaded run        numbers w 70 · h 20 · at (16, -66)
                     build editor.lua:298   ⚠ NOT REGISTERED
editor.delete        job delete the loaded run        numbers w 70 · h 20 · at (92, -66)
                     build editor.lua:307   ⚠ NOT REGISTERED
editor.comment       job free-text note on the run    numbers w 272 · h 20 · at (22, -92)
                     build editor.lua:318   ⚠ NOT REGISTERED
```

### zone: filter

```
editor.showlabel
  zone      filter            row 1        span full        kind readout
  job       heads the kind ticks
  subjects  always
  numbers   at (18, -120) · GameFontNormalSmall · text "show"
  build     editor.lua:330
  ★ This is a HEADER with no divider and no zone binding — precisely the `behaviour` orphan
    class §99 made unrepresentable in the object pane, still present here
```

```
editor.kind.<key>
  zone      filter            row 2..n     span left        kind check
  job       show or hide one kind of captured node
  subjects  always
  numbers   w 22 · h 22 · at (16, -136 - (i-1) * 24)   ⇒ a 24 PITCH, one per FILTERS entry
  build     editor.lua:337  CreateFrame("CheckButton","COA_DungeonRunFilter"..key,f,
                                        "UICheckButtonTemplate")
            label is $parentText, built from the name rather than read back off the frame
  ⚠ NOT REGISTERED (any of them)
  ★ The only REPEATED row in any pane — its count follows FILTERS, so `row` is a range and the
    pitch is the number that matters, not a list of y values
```

### zone: time

```
editor.bar
  zone      time              row 1        span full        kind readout
  job       the run's whole timeline, as a track
  subjects  always
  numbers   w 244 (BAR_W, editor.lua:62) · h 12 · at (18, -190)
  build     editor.lua:358  CreateFrame("Frame", nil, f)
            track / envFill / winFill textures at editor.lua:362, 366, 370
  ⚠ 244 in a 284 column — 40 short since §107
  ⚠ NOT REGISTERED
```

```
editor.handle.<a|b>
  zone      time              row 1        span —           kind button
  job       drag the ends of the time window
  subjects  always
  numbers   grab w 16 (GRAB_PX) · h 20 · VISUAL 4 × 18
  build     editor.lua:408 (frame) and :412 (texture)
  ★★ The grab area is FOUR TIMES the visual — a 4px handle is unhittable, so the frame is 16
    and the texture is 4. ⚠ A rect check sees 16 and the eye sees 4; both numbers are real and
    they answer different questions, exactly like the dropdown's field and art
```

```
editor.width         job how wide the window is       numbers at (18, -208)
                     build editor.lua:455   ⚠ NOT REGISTERED
editor.step.<n>      job nudge the window             numbers w 22 · h 20 · at (dx, -226)
                     build editor.lua:462 and :478, two groups
                     ⚠ NOT REGISTERED · dx computed in-line, not declared
editor.play          job play the window across the run   numbers w 50 · h 20 · at (102, -226)
                     build editor.lua:493   ⚠ NOT REGISTERED
editor.skip          job what the window is skipping   numbers at (184, -231)
                     build editor.lua:499   ⚠ NOT REGISTERED
                     ⚠ -231 where its row is -226. A 5px hand-nudge with no stated reason
```

### zone: state

```
editor.peek          job show the whole run briefly   numbers w 60 · h 20 · at (16, -252)
                     build editor.lua:513   ⚠ NOT REGISTERED
editor.latch         job keep peek held               numbers w 20 · h 20 · at (80, -252)
                     build editor.lua:520   ⚠ NOT REGISTERED
editor.reset         job restore the full envelope    numbers w 60 · h 20 · at (110, -252)
                     build editor.lua:531   ⚠ NOT REGISTERED
editor.track         job follow the most recent node  numbers w 20 · h 20 · at (16, -276)
                     build editor.lua:540   ⚠ NOT REGISTERED
```

### footer — not a zone

```
editor.hint          job what to do next              numbers w 284 · at (18, -302)
                     build editor.lua:551   ⚠ NOT REGISTERED
                     ★ Already the full column width — the only thing §107 widened
editor.promote       job open the Promotion pane      numbers w 110 · h 20 · BOTTOMLEFT (16, 14)
                     build editor.lua:570   ⚠ NOT REGISTERED
                     ★ The only BOTTOM-anchored control in the addon. It survives the pane
                       changing height, which is why it is the right anchor for a footer
```

### ⚠⚠ And the "Controls / Curate" text he saw is NOT this pane's

Sourced, not guessed. `map.lua:2214` and `:2221` create the Map's own two buttons — **"Controls"**
and **"Curate"** — at its TOPRIGHT. And the strata explain the rest:

    Map        HIGH     + toplevel     map.lua:2147
    Curation   DIALOG   + toplevel     editor.lua:265
    Promotion  DIALOG   + toplevel     promoter.lua:355
    Object     DIALOG   + toplevel     object.lua:404

**DIALOG sits above HIGH**, so Curation draws over the Map — and the Map's two buttons read
through wherever the Curation backdrop is not opaque. ★ Not a Curation fault, and not a layout
fault: two panes overlapping on screen, which no per-pane geometry check can ever see.

⚠ **That is a real gap in the checking.** Every check so far asks "is this pane internally
consistent". Nothing asks "do two panes collide on screen", and the answer to that one is
`relates` plus a screen-level pass.

## ⚠ Declared and not yet built — the Test Drive wiring

★★★ **Disk first.** Both of these are settled here and the code does not match yet, which is the
standing rule working rather than a backlog: *"It is allocated on the disk first, then makes it
in-game after geometry checks."*

**1 — the rename.** `Driver` → `Test Drive`, and it moves as one piece or not at all:

| | from | to |
|---|---|---|
| file | `driver.lua` | `testdrive.lua` |
| module | `NS.Driver` | `NS.TestDrive` |
| frame | `COA_DungeonRunDriver` | `COA_DungeonRunTestDrive` |
| verb | `/dr drive` | `/dr testdrive` |
| TOC | `driver.lua` | `testdrive.lua` |

⚠⚠ **AND ONE THING THE RENAME MISLABELS.** `Driver.Reached` (driver.lua:118) is the **detection
maths**, and `walk.lua` is its only caller. It is not test-driving anything - it answers "is the
player inside this radius". Under `TestDrive.Reached` it sits beneath a name that does not own it.
★ Recorded, not fixed: extracting it is a second change and bundling the two would make a rename
into a refactor.

**2 — Play spawns it.** `promoter.play` opens the Test Drive pane and starts the walk; the pane is
where the run is watched instead of the chat window.

⚠ **The pane's readout does not report a walk today.** `report()` (driver.lua:150) reads the
DRIVER's own armed state - `armed`, `routeId`, `index` - and a walk sets none of them. What it
needs is already there: **`Walk.State(id)`** (walk.lua:209) returns

    walk: stage 3  ·  5/7 stages have acceptance  ·  2 seen

★ So the readout prefers `Walk.State` while a walk is running and falls back to its own report
otherwise. One line of precedence, not a new mechanism.

⚠ **Chat keeps the errors.** `StartLines` can fail with a reason, and a reason that appears only
in a pane you may not be looking at is a reason nobody reads.

## Standing counts

| | |
|---|---|
| entries | 24 |
| ⚠ not registered | **13** — invisible to the geometry probe |
| ⚠⚠ unregistered **dropdowns** | **2** (`object.target`, `object.outcome`) — the class that hid a 44px collision |
| ⚠ build disagrees with numbers | 9 |
| ⚠ in code, absent here | 3 (`setBox`, `outcomeBox`, `stageGhost`) |
| panes with no declaration | 4 of 5 |

★★★ **Thirteen of twenty-four are unregistered.** The geometry probe's run measured 16 controls and
reported nothing wrong, because it could only ever ask about the ones on the list. §103's walker
fixes the *instrument*; this file is what says whether the answer was right.
