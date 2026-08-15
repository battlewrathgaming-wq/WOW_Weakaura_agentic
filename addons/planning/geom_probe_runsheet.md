# `/coadump r geom` — the run card

_Measures the things only the client can answer: **how wide text is**, **how big the stock controls
really are**, **what the client's own panels actually space at**, and **where every one of our
widgets truly sits**. **Read-only.** It creates its own scratch widgets and reads them; nothing on
the census's push list is called and no client state moves._

## Why this run exists

`addons/tools/smoke/frames.lua` resolves the whole object pane offline and **refuses to invent** the
one thing it cannot know — a FontString's extent, which is text × font. The 2010 `WoW UI Designer`
approximated exactly that, and its own release notes concede the result was *"not exactly like
WoWs"*. It had to guess because its renderer was the only output. **We have the client on access.**

⚠ **It also captures far wider than the immediate need**, on his instruction: *"capture broader than
the ask. That exposes trends and norms."* The ask was nine strings; what comes back is every font ×
a calibration set, every stock control template, the client's own shipped panels, and our whole
registry.

## Before

```
py addons\deploy.py
```

Then a **full client restart** — new files (`task_geom.lua`, `panespec.lua`), not a `/reload`.

## Where to run it

**Anywhere.** ★ Unlike the api probe this is deliberately not zone-dependent — it measures text and
templates, which do not care where you are standing.

⚠ **But open the DungeonRun object pane first if you want the last section.** `/dr map`, then
right-click a beacon or a child so the pane exists and has something in it. Without that, the
run still succeeds and simply records that our controls were not there — which is a fair answer,
just a thinner one.

## The run

```
/coadump r geom
/reload
```

Then, in the repo:

```bash
py addons/tools/read_geom.py
```

And to run the offline overlap/overhang checks against the client's **measured** numbers rather than
predicted ones — the same arithmetic, not a second implementation:

```bash
.tools/lua51/lua5.1.exe addons/tools/smoke/check_rects.lua
```

## ⚠⚠ Read the apparatus line first

★★★ **A zero and a measurement that never happened look identical in a file.** Run 1 of `/coadump r
api` filed four disagreements about the client and **all four were false** — the experiments had
never run. So this measures a known string *before* believing anything, and if that comes back zero
it writes `apparatus = "dead"`, records **nothing else**, and says so on the summary line.

**If you see `APPARATUS DEAD`, nothing in the run is usable.** That is the design working.

## What each section answers

| section | the question |
|---|---|
| **apparatus** | does a **never-shown frame** report a real width? ⚠ We measured that `Click()` fires on hidden frames — that is suggestive and is **not this question**, so both are measured side by side |
| **fonts** | per-character norms (`perM`, `perI`) so any future string can be **predicted**, plus our own strings measured exactly |
| **templates** | what the client **builds** vs what the XML declares. ★ Including the one we refused to assert from memory: `UIDropDownMenu_SetWidth(dd, 96)` sets the width only, and the template adds textures either side — **by how much is measured here, never recalled** |
| **reference** | the client's own panels, measured. §101 sourced **6 / 8 / 12** out of their XML; this is whether their shipped panels really space that way |
| **ours** | every registered control's true rect, converted into the pane's own frame of reference |

## What a good run looks like

- the summary line ends `Hidden frames measure: true` or `false` — **either is a finding**
- `read_geom.py` prints a `perM` for most fonts and names any it could not measure
- templates that do not exist on this fork are **named**, not counted
- `check_rects.lua` reports overlaps and overhangs in the live pane

★★ **The last one is the interesting one.** The play button visibly clips and the cause is **still
unproven** — I claimed twice it was width, and 208 + 52 = 260 on a 280 frame is 20 *inside* the edge.
This run measures where it actually is.

## The loop constraint nobody can remove

**run → reload → read.** SavedVariables only reach disk on `/reload` or logout.
