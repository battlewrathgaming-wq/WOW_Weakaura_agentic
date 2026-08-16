# Recorder Remote — the front door

_`widget.lua` · `COA_DungeonRunFrame` · **240 × 124** · content x=16, width 208_

★★★ **THE 16 IS JUSTIFIED, NOT A DEVIATION.** Every other surface declares 18.
*"The remote is more compact by nature. UI's that claim space prefer presentation over
compactness."* A gate is small and every pixel it takes is one it did not need; a pane that has
claimed a third of the screen owes structure back. See the model's *compactness and
presentation* section.

★★★ **The factual register.** What exists, or what the code must comply with.

★ **Reconciled by `check_interface.py`** — the file and global named above, the declared size, and every `forms · phrase` citation. Bench menu **[7] Reconcile**, or run it directly. ⚠ It checks the mechanical part only; whether `does`, `how` and `refuses` are still true is curation.

⚠ **The header still names the CURRENT file and global, not the declared ones** — deliberately. The checker reconciles against what exists; the rename is the ☐ below.

☐ **RENAME PENDING.** Declared `DungeonRun_Recorder_Remote`; the code still says
`COA_DungeonRunFrame` and `widget.lua`. Frame name, file name and every reference move together
or not at all.

> *"So it's DungeonRun_Recorder_Remote (Like a remote to a TV.) Then DungeonRun_Drive (The addon
> that people use just to run routes) will have _remote as its primary entry."*

★★ **`_Remote` is a PATTERN.** An addon's remote is the one surface that turns it on and reaches
everything else — small, always to hand, and not the thing itself. A TV remote is not the
television.

---

## ★★★ The model — what it IS

**The Remote is a GATE OF ACTIVITY.** Two branches, and everything else is downstream of picking
one:

> *"It's a gate of activity. (I'm doing a run) or (I'm reviewing a run). Each branch from there."*

    I'm DOING a run      →  name it, arm it, pin what the client will not tell us
    I'm REVIEWING a run  →  open the Map, and the whole reviewing chain behind it

★★ **Which is why it is small, and why it must stay small.** A gate needs two doors, not a
control panel. Every control that is not one of the two branches is a control asking to be
somewhere else.

### ★★★ And nobody should have to know a command to use it

> *"A user shouldn't have to know every command or macro access we create. That's power user
> space."*

★ So the Remote is the **discoverable** path and the slash surface is the **power** path. ⚠ They
are not alternatives of equal standing: a slash command you have to already know is not a
surface, and anything reachable ONLY by typing is, by that fact, not available to most users.

### What falls out of it

| behaviour | why |
|---|---|
| **240 × 124, six children** | a gate, not a panel |
| **it is the only front door** | a gate is where you choose; everything downstream is behind a choice |
| **it opens the Map and nothing else** | reviewing is one branch, and the Map is its door — not five shortcuts to five panes |
| **it shows a count, never a judgement** | how many points, not whether that is enough |
| **it is not an editor** | choosing an activity is not doing it |

★ **The two branches are already in the layout**, though not marked as such: `name` · `pin` ·
`arm` · `count` serve DOING; `map` serves REVIEWING.

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
remote.pane      kind frame   usage — (the surface itself)
                 does  the pane itself. `set("close")` hides it, `read` reports shown
                 ★ REGISTERED §128

remote.title     kind readout   usage label     forms widget.lua · `local title = f:CreateFontString(nil, "OVERLAY", "GameFontNo`, GameFontNormal, "Dungeon run" at (16, -8)
remote.pin       kind button   usage action    forms widget.lua · `pinBtn = CreateFrame(`   does drops a point where the client is silent
                 numbers w 208 · h 22 at (16, -34), text "Pin here"
remote.name      kind edit   usage input · identifying      forms widget.lua · `nameBox = CreateFrame(`, COA_DungeonRunNameBox
                 does  names the run being captured
                 numbers w 208 · h 20 at (16, -58)
remote.count     kind readout   usage readout   forms widget.lua · `countText = f:CreateFontString(nil, "OVERLAY", "GameFontDisa`   does how many points so far
                 numbers TOPLEFT (16, -88)
remote.arm       kind button   usage arm    forms widget.lua · `armBtn = CreateFrame(`   does starts and stops the capture
                 numbers w 64 · h 22, BOTTOMRIGHT (-16, 14)
remote.map       kind button   usage action    forms widget.lua · `mapBtn = CreateFrame(`   does opens the Map
                 numbers w 50 · h 22, BOTTOMRIGHT (-82, 14)
                 ⚠⚠ WAS -72 AND OVERLAPPED `remote.arm` BY SIX PIXELS (§144). Right
                    edge 240-72 = 168 against arm's left edge 162. Live, shipped, and
                    confirmed in game once the board drew it — two identical 3-slice
                    buttons read as ONE button with a missing end cap, not as an overlap.
                 ★ §145: -82 and w 50 are HIS, dragged on the board. Right edge 158
                   against arm's 160 is a 2px gap, four off the house GAP of 6 — outside
                   the normaliser's tolerance, so it is read as a decision, not a tremor.
```

★★★ **THE HEADER SAID `content x=16, width 208` ALL ALONG — AND NOTHING EVER CHECKED IT.**
The code shipped `pin` at 20 w200 and `name` at 22 w190. Three numbers, three different content
boxes, and the one at the top of this file was the only one nobody was following. §145's drag did
not invent a form; it landed on what this document had already declared.

☐ **`check_interface.py` does not read the header's content box.** It reconciles the file, the
global and the declared SIZE, but not the stated inset and width against the children's numbers.
That check would have caught this the day it was written.

★ **Three of its six children are BOTTOM-anchored** — count, arm and map. That is the right anchor
for a footer row, and the only other place it appears is Curation's Promotion button.

★ **All seven are registered** (§131) — the probe sees the whole front door.

---

## Outstanding

<!-- OUTSTANDING:BEGIN - emitted by emit_outstanding.py, do not edit by hand -->

2 items:

- RENAME PENDING. Declared `DungeonRun_Recorder_Remote`; the code still says `COA_DungeonRunFrame` and `widget.lua`. Frame name, file name and every reference move together or not at all.
- `check_interface.py` does not read the header's content box. It reconciles the file, the global and the declared SIZE, but not the stated inset and width against the children's numbers. That check would have caught this the day it was written.

<!-- OUTSTANDING:END -->

---

## Hopes and dreams

_What this surface still needs so **the model** can be realized (`dungeonrun_model.md`). Not technical — the backlog to realize._

- **It becomes `DungeonRun_Recorder_Remote`.** A remote to a TV — the one surface that turns
  the recorder on and reaches everything else.

  > *"So it's DungeonRun_Recorder_Remote (Like a remote to a TV.) Then DungeonRun_Drive (The
  > addon that people use just to run routes) will have _remote as its primary entry."*

- **And it gets a sibling.** A second addon for players who only want to run a route, with a
  remote of its own. This one records; that one drives.
