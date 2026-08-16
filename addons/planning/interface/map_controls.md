# Map controls — the view pad

_`map.lua:1848` · `COA_DungeonRunMapControls` · **240 × 168** · content x=18, width 204_

★★★ **The factual register.** What exists, or what the code must comply with.

★ **Reconciled by `check_interface.py`** — the file and global named above, the declared size, and every `forms · phrase` citation. Bench menu **[7] Reconcile**, or run it directly. ⚠ It checks the mechanical part only; whether `does`, `how` and `refuses` are still true is curation.

---

## ★★★ The model — what it IS

**Map controls GENERATES better reading through population.** It makes the picture more legible
**without changing what is in it**.

> *"Curation can filter from the data set. Map controls can generate better reading through
> population."*

★★ **The cut against Curation is one question:** *does it change WHICH captured data is present,
or does it draw something that was never captured?* Curation is **subtractive** — it filters the
set. This surface is **additive** — it populates the view with aids.

★ **So magnification is the first member of a family, not the whole of it.** Zoom, pan and
recentre change nothing about the data and make it readable; a detector radius and a painted
same-height zone do the same job by drawing something the capture never held.

⚠ **And that is what keeps the interface from being whack-a-mole.** A new control has exactly one
place it can go, decided by what it DOES rather than by where there was room.

## does

Moves the **view**, and nothing else. Zoom, pan, recentre, reset, and two opt-in input ticks.

★★ **It is a widget of its own rather than buttons on the map** because the map's surface is the
drawing area — putting view controls on it spends the thing being looked at.

## refuses

⚠⚠ **It takes neither the mouse wheel nor right-drag without being asked.** Both are ticks and both
default **OFF**:

> the wheel belongs to the world camera, and right-drag to camera-look — an addon should not take
> either without being asked.

★ That is the same manner as the note being pulled on hover rather than announced: **a tool does
not help itself to an input the player is already using.**

## how

    reads    Map.Zoom / Map.Stage
    writes   Map.StepZoom · Map.PanStep · Map.Recenter · Map.ResetZoom · Map.CycleZoomStage

★ **Every button calls one Map function and then `refreshControls()`.** The pane holds no view
state of its own — it is a remote for the map's, which is why the two can never disagree.

★★ **Zoom anchors on the VIEW CENTRE, not the cursor.** The cursor is also the *pen*, and drawing
tools are unusable on the coarser maps where a 5-yard radius is under two pixels.

## interacts

    zoom -    up      zoom +          a 3 × 3 pad, laid out as it reads
    <       Re-centre    >
    100%     down     Reset

★ **`100%` is a CYCLE, not a label** — it steps 100 / 125 / 150 / 200 and takes you there. One
button instead of four, which is the flattening rule: reduce the decision, do not add a choice.

★ **Pan moves a quarter view per press**, so the same press means the same thing at every zoom.

## relates

    opened by   the Map's "Controls" button
    opens       nothing

## children

```
mapcontrols.title    kind readout  forms map.lua · `local t = controls:CreateFontString(nil, "OVERLAY", "GameFon`, GameFontNormal, "Map controls"
mapcontrols.zoomout  kind button   forms map.lua · `b = CreateFrame(` via btn()   numbers w 54 at (16, -40)
mapcontrols.up       kind button                                  numbers w 46 at (96, -40)
mapcontrols.zoomin   kind button                                  numbers w 54 at (166, -40)
mapcontrols.left     kind button                                  numbers w 30 at (40, -64)
mapcontrols.recentre kind button                                  numbers w 76 at (82, -64)
mapcontrols.right    kind button                                  numbers w 30 at (174, -64)
mapcontrols.stage    kind button   does cycles 100/125/150/200 and goes there
                                                                  numbers w 54 at (16, -88)
mapcontrols.down     kind button                                  numbers w 46 at (96, -88)
mapcontrols.reset    kind button                                  numbers w 54 at (166, -88)
                     ★ all nine are built by one local `btn(label, w, x, y, fn)` helper,
                       height 20, which is why this pane has no hand-typed height anywhere

mapcontrols.wheel    kind check    forms map.lua · `wheelTick = CreateFrame(`, COA_DungeonRunWheelZoom
                     does  opt in to mouse-wheel zoom.  ⚠ DEFAULTS OFF
                     numbers w 20 · h 20, label "enable mouse wheel zooming"
mapcontrols.pan      kind check    forms map.lua · `panTick = CreateFrame(`, COA_DungeonRunRightPan
                     does  opt in to right-click panning.  ⚠ DEFAULTS OFF
                     numbers w 20 · h 20
```

★ **The two ticks are the only NAMED frames here**, and they are named because
`UICheckButtonTemplate`'s label is `$parentText` — the name is how the label is reached.

☐ **Nothing here is registered**, so the geometry probe cannot see it.

---

## Outstanding

<!-- OUTSTANDING:BEGIN - emitted by emit_outstanding.py, do not edit by hand -->

1 item:

- Nothing here is registered, so the geometry probe cannot see it.

<!-- OUTSTANDING:END -->

---

## Hopes and dreams

_What this surface still needs so **the model** can be realized (`dungeonrun_model.md`). Not technical — the backlog to realize._

★ **Generated reading aids** — the family this surface turns out to own, once the FILTER vs
GENERATE cut named it:

- **The radius around a beacon or child detector**, drawn so a theatre can be **seen** rather
  than inferred. ★ A beacon is a theatre; today you have to imagine its extent.
- **Same-height areas painted as a zone**, matched by Z within a tolerance — *"matching samples
  by Z (tolerance) and emitting a painted zone"*. It answers *which of these dots are on the
  floor I am looking at* without reading a number.
- **And each plane free to claim a colour for that view.** ★★ The user choosing what to
  distinguish is *we give context, they derive meaning* exactly — we supply the axis, they decide
  what it separates.

⚠ All three GENERATE: none of them is in the capture. That is why they are here and not in
Curation, and the cut is what decided it rather than where there was room.
