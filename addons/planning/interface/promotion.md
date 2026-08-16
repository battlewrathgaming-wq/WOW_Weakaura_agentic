# Promotion — the minting surface

_`promoter.lua` · `COA_DungeonRunPromoter` · **320 × 400** · content column x=18, width 284_

★★★ **The factual register.** Everything here describes what exists or what the code must comply
with. Directional rules live in `addons/maps/intent.md`.

★ **Reconciled by `check_interface.py`** — the file and global named above, the declared size, and every `forms · phrase` citation. Bench menu **[7] Reconcile**, or run it directly. ⚠ It checks the mechanical part only; whether `does`, `how` and `refuses` are still true is curation.

---

## ★★★ The model — what it IS

**Promotion is REDUCTION.** A run is many samples; a route is few beacons. This is the surface
that decides which of the evidence was of value enough to become the basis of an instruction.

> *"Promotion is extracting from a single run, allowing inspection of others, and organising
> that into a coherent, reduced data set that becomes a Route."*

★★ **The product is COHERENCE, not capture.** Which is what the running order, the stage
numbering and the gaps line are all for — they are not conveniences, they are how you see whether
the reduction holds together.

★★★ **AND THE ROUTE'S FORM IS DICTATED BY ITS CONSUMER.**

> *"A route has to be able to communicate to a player using the route. So this is done as
> Beacons and stages."*

★ A beacon is not a convenient way to store a point. It is the shape of **telling someone what to
do next** — which is why it carries the three answers, and why *"a beacon either directly calls a
player, or expands into many signals and instructions."*

### What falls out of it

| behaviour | why |
|---|---|
| **the run and route slots load independently** | *"extracting from a single run, allowing inspection of others"* — you can swap the evidence under a route without disturbing it |
| **it holds no edit controls** | reduction is choosing WHICH; meaning is attached afterwards, in the Object pane |
| **it never writes to a run** | the evidence must survive every reduction taken from it |
| **duplicate stages are accepted, and COUNTED** | stage is ORDINAL, so a duplicate costs it its meaning. The match count is a warning, not a readout — we tell and trust rather than refuse |
| **the ghosted stage walks gaps, and 4.1 is legal** | ★ the fraction is the INTENDED way to say *these two belong together* — one boss or the other is **4.0 and 4.1**, never two 4s |

### ⚠ A question this raises about the interface

⚠ *"Allowing inspection of others"* is structurally true — the run and route slots are separate —
but the **run selector lives in Curation, not here**. So the inspect-and-reduce loop crosses two
panes: mint here, go back to Curation to change the evidence, return. ★ Recorded as a question
about whether the loop is in the right shape, not as a fault.

## does

Three things, and only three:

1. **Selects the route** that is loaded — or creates one.
2. **Mints a beacon** into that route, from the point selected on the map.
3. **Mints a personal note** onto the player's own plane, out of the route entirely.

★★ **And then it hands off.** It holds no edit controls. Everything *about* an object — name,
behaviour, stage, children — lives in the Object pane.

> *"All edit options of an object live within its edit mode interface. […] Instead of promotion
> being both a spawning and editing tool."*

⚠ §69 got this wrong: right-click opened the promoter and the in-field editors were to "land in
that space". It made the creation pane double as an editor, which he saw before he named it —
*"the note is treating the promote window like it's information"*. It was, because it had been
made to.

## refuses

- ⚠ **It does not edit.** No rename of an object, no behaviour, no stage after the mint.
- ⚠ **It does not validate the author.** Duplicate stages, out-of-order stages and fractions are
  all legal. It **tells** you (match count, gaps line, running order) and then trusts you.
  Refusing would be grading the work.
- ⚠ **It does not write to a run.** Minting reads a captured node and writes a *route*; the run
  record is never touched. §29 rests on this.

## how

    reads     Map.Selected()        the point under the cursor selection
              Map.LoadedId("route") which route is on screen
              Map.AuthoringMapID()  which map plane a note would land on
              Routes.Get/StageOrder/NextStage/NoteCount/OutcomeOf

    writes    Routes.Create         a new route
              Routes.AddBeacon      a beacon into the loaded route
              Routes.AddNote        a note onto the player's plane
              Routes.Rename
              Store.SetUI           its own window position

★★ **Every mint ends with `Map.Load`, never a repaint.** Loading is the one entry point, so the
map ends in exactly the state the selector would have produced. A repaint would be a second way
to arrive at the same picture, and the two would drift.

★ **`Routes.Inherit` decides what carries.** Place carries — `x,y,z`, `mapX/mapY`, `floor`,
`mapID`. Event does not — `t`, `kind`, `n`, `killedBy`, `combat`. A beacon is a statement about a
**spot**, and §61 dropped the back-reference so nothing downstream could tell borrowed fields from
owned ones.

## interacts

| you | it |
|---|---|
| pick a route from the dropdown | loads it onto the map, and the running order redraws |
| pick `+ create new` | swaps the name label for a text field — the field never has to distinguish modes itself |
| click a point on the map, then **Create beacon** | mints at that point, at the ghosted stage or the one you typed |
| type in the stage box | overrides the ghost. ★ Empty means "use the default", which is what makes the field free to ignore |
| click **Personal note** | mints onto your own plane and loads that plane, so you can see what you made |

⚠ **Both mint buttons are disabled with nothing selected**, and that is a fact about the data —
there is nothing to copy a position from — rather than a rule being enforced.

## holds

    creating       transient   nil, or true while a new route is being named
    (route id)     NOT held    it asks Map.LoadedId every refresh
    window pos     persists    Store.SetUI

★★★ **It remembers no selection of its own.** Only the map's. A pane that remembers what it is
looking at can describe something the map is not showing — the fault §63 shipped when two
surfaces each kept their own idea of the subject.

## relates

    opened by   Curation's Promotion button
    opens       nothing — it hands to the Object pane, which the MAP opens on right-click
    shares      its width with Curation, so the two stack on one vertical edge

## children

☐ **Not declared in `panespec.lua`** — every number below is hand-typed in `promoter.lua` and no
offline check watches it. This is the pane that produced the field-vs-art bug.

```
promoter.pane       kind frame   usage — (the surface itself)
                                          `read` reports shown
                    ★ REGISTERED — the surface is drivable, not only its contents

promoter.title   kind readout   usage label     forms promoter.lua · `title = f:CreateFontString(`
                 does  names the surface — "Promotion". Measured 62.8 × 11.9
                 ★★ FOUND BY THE REGION WALK (§134). Four surfaces declared their title and
                    two did not, and a title is a FontString — so it was invisible to every
                    capture taken before §133 grew the second loop
promoter.name.current  kind readout   usage readout   forms promoter.lua · `nameLabel = f:CreateFontString(`
                 does  the route currently loaded, beside the name box. Measured 160.0 wide
promoter.stage.ghost   kind readout   usage readout   forms promoter.lua · `stageGhost = f:CreateFontString(`
                 does  §80's GHOST — what the stage WOULD be, shown rather than pre-filled,
                       so the field stays empty and the suggestion is visibly a suggestion
promoter.order.title   kind readout   usage readout   forms promoter.lua · `orderTitle = f:CreateFontString(`
                 does  the heading over the running order — "running order"
promoter.order.<n>     kind readout   usage readout   forms promoter.lua · `local r = f:CreateFontString(`
                 does  one line per beacon in stage order, ORDER_ROWS of them, the last
                       reserved for the "... N more" overflow
                 ★ × 9 measured (§134), each 240 wide — a family, so its members carry
                   concrete keys `promoter.order.1` … rather than one row standing for nine
promoter.gaps    kind readout   usage readout   forms promoter.lua · `gapsText = f:CreateFontString(`
                 does  reports holes in the stage sequence. Empty at capture, so it measured 1 × 1
promoter.route      kind dropdown   usage selection · dropdown   forms promoter.lua · `dd = CreateFrame(`, UIDropDownMenuTemplate, named
                                           COA_DungeonRunRouteLoad because
                                           UIDropDownMenu_SetWidth needs GetName()
                    does   selects the loaded route; its menu carries "+ create new" IN the
                           list rather than beside it
                    numbers field 200 · text 175 · art 250 · h 32 · at x=2
                    ★ registered §103 — before that it was invisible to the geometry probe,
                      which is how a 44px collision went unseen

promoter.name       kind edit   usage input · identifying       forms promoter.lua · `nameBox = CreateFrame(`, InputBoxTemplate
                    does   names a route while creating; hidden and replaced by a label plus
                           a Rename button once one is loaded
                    numbers w 272 · h 20

promoter.rename     kind button   usage action
promoter.delete     kind button   usage action     forms promoter.lua · `deleteBtn = CreateFrame(`
                    does  deletes the LOADED route and everything on it, behind the
                          client's own confirm - with the route's NAME in the prompt
                    ★★★ `Routes.Delete` EXISTED SINCE THE ROUTE STORE AND HAD NO CALLER (§227).
                      Found by walking the address sheets, not by anything failing.
                      **A capability with no door is not a capability.**
                    ⚠ `showAlert`, unlike rename: this destroys authored work and there
                      is no undo. It follows Rename's enable/disable exactly, because
                      both act ON the loaded route and both are dead without one
                    numbers w 70 · h 20    ⚠ PLACEMENT UNMEASURED - clears `nameBox` above
                      and `inherit` below by 4px on paper; the probe settles it
promoter.create     kind button   usage action     forms  promoter.lua · `createBtn = CreateFrame(`   does mints a beacon
promoter.note       kind button   usage action     forms promoter.lua · `noteBtn = CreateFrame(`   does mints a personal note
                    numbers w 110 · h 20 each

promoter.stage      kind edit   usage input · identifying       forms promoter.lua · `stageBox = CreateFrame(`   ⚠ NOT REGISTERED
                    does   the stage to mint at. Ghosted with the next free round number,
                           walks gaps, accepts a 4.1 between 4 and 5
                    numbers w 40 · h 20

promoter.inherit    kind readout   usage readout
promoter.count      kind readout   usage readout
promoter.hint       kind readout   usage readout
                    numbers w 284 each
promoter.close   kind button   usage action   forms promoter.lua · `closeBtn = CreateFrame(`
                 does  hides the pane
                 numbers w 60 · h 20, BOTTOMRIGHT (-14, 14)
                 ★ DECLARED IN §133 — it had no row on any surface
```

☐ `stageGhost` (`promoter.lua:47`) is in code and in no entry — **justify or cut**.

⚠ **`promoter.play` was removed in §113.** It test-drove the route through `walk.lua` and
reported to chat. Both left with the debugging suite; see `addons/planning/debug_suite_plan.md`.

---

☐ **FOUR LEFT EDGES IN ONE PANE, AND THE HEADER PICKS ONE.** `promoter.lua` reads:

    16   noteBtn · createBtn
    18   title · rule · carries · inherit · countText · hint · orderTitle   <- what the header declares
    22   nameBox · nameLabel · the nine order rows
     2   dd, the route dropdown - and that is its ART, so its FIELD lands at 27

★ **The sketch of 2026-08-16 dragged six of them onto 16**, which is the edge `note` and `create`
already sat on. ⚠ But 16 is the COMPACT inset and this is a presenting pane, so the reconcile
runs the other way: `note` and `create` move to 18 and the rest join them.

⚠⚠ **AND A DROPDOWN CANNOT SIT ON AN 18px CONTENT LINE.** Its art is 25 wider on the left than
its field (§103), so a field at 18 puts the art at −7 — off the pane. That is why `dd` is at 2:
somebody pushed it as far left as it would go and the field landed at 27. **Either the route
selector is the one control that does not meet the line, or the line moves to 25 for dropdowns
and is stated as such.** Not a nudge — a rule, and it is the same rule on every pane that carries
a selector.

## Outstanding

<!-- OUTSTANDING:BEGIN - emitted by emit_outstanding.py, do not edit by hand -->

3 items:

- Not declared in `panespec.lua` — every number below is hand-typed in `promoter.lua` and no offline check watches it. This is the pane that produced the field-vs-art bug.
- `stageGhost` (`promoter.lua:47`) is in code and in no entry — justify or cut.
- FOUR LEFT EDGES IN ONE PANE, AND THE HEADER PICKS ONE. `promoter.lua` reads:

<!-- OUTSTANDING:END -->

---

## Hopes and dreams

- ★★★ **THE RUNNING ORDER BECOMES THE READOUT BOX.** His note, written on the board against
  `running order` (2026-08-16):

  > *"All of the below will become a dynamic readout in a read out box. Maybe a drop down to
  > force a readout focus and a release button."*

  ★ Which is the first CONTENT for the footer readout the model already carries — *"if it informs
  decision making, it belongs in the readout box we'll be making in the footer space."* Nine
  fixed lines plus an overflow row is a readout box built the long way: it reports, it is what
  you weigh before promoting, and it takes 96px of the pane to say so.

  ⚠ **A drop-down to FORCE a focus, and a release** — so the box can be pinned to one subject
  instead of following the selection. That is a control on the readout, which is a different
  thing from the readout itself, and it is the first sign the box has its own behaviour rather
  than being a place text lands.


_What this surface still needs so **the model** can be realized (`dungeonrun_model.md`). Not technical — the backlog to realize._

- **A route you can trust before you drive it.** An audit green light on a run —
  ★ *"if we want a audit green light on a run, it gets named and designed. Not smuggled in."*
  So: named and designed here first, never arriving as a side effect of a test tool.
