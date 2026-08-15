# Recorder Remote — the front door

_`widget.lua` · `COA_DungeonRunFrame` · **240 × 124** · content x=16, width 208_

⚠⚠ **RENAME PENDING.** Declared `DungeonRun_Recorder_Remote`; the code still says
`COA_DungeonRunFrame` and `widget.lua`. Frame name, file name and every reference move together
or not at all.

> *"So it's DungeonRun_Recorder_Remote (Like a remote to a TV.) Then DungeonRun_Drive (The addon
> that people use just to run routes) will have _remote as its primary entry."*

★★ **`_Remote` is a PATTERN.** An addon's remote is the one surface that turns it on and reaches
everything else — small, always to hand, and not the thing itself. A TV remote is not the
television.

---

## does

1. **Starts and stops a run** — the capture.
2. **Pins a point** where the client emits no event and the player is the sensor.
3. **Names** the run being captured.
4. **Opens the Map**, which is the door to everything else.

## refuses

- ⚠ **It is not an editor.** Nothing about a captured point is changed here.
- ⚠ **It shows a count, not a judgement.** How many points, not whether that is enough.

## relates

★★★ **It is the ONLY front door.** Everything downstream is reachable only through it:

    Recorder Remote ── starts a run
                    └─ opens Map ─┬─ opens Map controls
                                  └─ opens Curation ── opens Promotion ── mints into Object

⚠ **So a change here is a change to whether the rest of the addon can be reached at all.**

## holds

    window pos     persists    Store.SetUI
    (arm state)    NOT held    it asks Capture every refresh

## children

```
remote.title     kind readout   forms widget.lua:87, GameFontNormal, "Dungeon run" at (16, -14)
remote.pin       kind button    forms widget.lua:102   does drops a point where the client is silent
                 numbers w 200 · h 22 at (20, -34), text "Pin here"
remote.name      kind edit      forms widget.lua:109, COA_DungeonRunNameBox
                 does  names the run being captured
                 numbers w 190 · h 20 at (22, -62)
remote.count     kind readout   forms widget.lua:116   does how many points so far
                 numbers BOTTOMLEFT (18, 18)
remote.arm       kind button    forms widget.lua:119   does starts and stops the capture
                 numbers w 64 · h 22, BOTTOMRIGHT (-14, 14)
remote.map       kind button    forms widget.lua:125   does opens the Map
                 numbers w 52 · h 22, BOTTOMRIGHT (-72, 14)
```

⚠ **Its inset is 16, where every other pane uses 18.** Reconcile or justify.

★ **Three of its six children are BOTTOM-anchored** — count, arm and map. That is the right anchor
for a footer row, and the only other place it appears is Curation's Promotion button.

⚠ **Nothing here is registered**, so the geometry probe cannot see the addon's front door.
