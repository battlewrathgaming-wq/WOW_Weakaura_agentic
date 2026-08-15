# The pane inventory — the source of truth

★★★ **This file is the AUTHORITY, not a report.** It is not generated from the code and it does not
mirror it. The code has to comply with what is written here; where the two disagree, **the code is
wrong** until we decide otherwise. His ruling:

> *"Once made, the inventory is authority / source of truth until our consideration changes."*

★★ **And nothing reaches the client that is not in here first.**

> *"It is allocated on the disk first, then makes it in-game after geometry checks. […] If we don't
> know how we'll track it, don't add it to the game until we know how."*

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
  job       drive the loaded route
  subjects  all
  numbers   w 52 · h 20        at x=258, clear of the route art at 252
  build     promoter.lua:414  CreateFrame("Button",nil,f,"UIPanelButtonTemplate")
            SetWidth(52); SetHeight(20); SetPoint("TOPLEFT", 258, -78)
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

## Panes not yet inventoried

★ Named so the gap is visible rather than implied. Nothing in them may change until they are in here.

- **Curation** (`editor.lua`) — **320 × 366**. The run selector, rename/delete, the Controls/Curate
  tabs, the show ticks, the time envelope row, peek/reset, track-most-recent.
  ★ **Width matched to Promotion (§107)** so the two share one vertical edge when stacked;
  height stays its own. ⚠ I had seeded this page saying 240 × 330 — that was a guess, and
  `editor.lua` said 280 × 366. **The authority carried a number nobody had read.**
  ⚠ Something appears to sit across the *Controls / Curate* labels on screen; unmeasured.
- **Map widget** (`widget.lua`) — zoom/pan pad, stage button, recentre, reset.
- **Driver** (`driver.lua`) — the in-run readout.

---

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
