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


## Run 1 — 2026-08-15 22:04, Vol'jin, scale 0.85 @ 3620x2036

**Apparatus LIVE.** 11 fonts, 8 templates (0 missing), 4 reference panels, 16 of our controls.

### ★★★ A never-shown frame DOES measure — but not the same number

    shown  'MMMMMMMMMM' = 128.02
    hidden 'MMMMMMMMMM' = 130.15

⚠ **Both were worth having.** `Click()` firing on hidden frames made "hidden works" the natural
assumption, and it is *half* right: the call returns, and it returns something **1.7% different**.
★ **RULING: calibrate on a SHOWN frame.** A number that is nearly right is the worst kind here,
because nothing downstream would ever flag it.

### ★★★ The dropdown, settled from both directions at once

`UIDropDownMenu_SetWidth(dd, 96)` produces a frame **146 wide**. And `SharedXML/UIDropDownMenu.lua:962`
says why:

```lua
_G[frame:GetName().."Middle"]:SetWidth(width);
local defaultPadding = 25;
... frame:SetWidth(width + defaultPadding + defaultPadding);
```

**+50, and the source and the measurement agree exactly.** Two things fall out:

- ⚠ **It requires `GetName()`** — which is why the anonymous template probe could not size one, and
  why `object.lua` names its dropdowns despite the no-globals rule. That is a **forced** global.
- ★ **A third argument exists.** `UIDropDownMenu_SetWidth(dd, 96, 0)` gives `width + padding` instead
  of `width + 50` — a real lever on a 204-wide column, and one we did not know we had.

### Templates: three of eight declare no size at all

    InputBoxTemplate            0 x 0     the caller sizes it
    UIPanelButtonTemplate       0 x 0     the caller sizes it
    UIPanelScrollFrameTemplate  0 x 0     the caller sizes it
    OptionsBaseCheckButton     26 x 26
    InterfaceOptionsCheckButton 26 x 26
    UICheckButtonTemplate      32 x 32
    UIPanelCloseButton         32 x 32
    UIDropDownMenuTemplate     40 x 32

★ **That is itself the norm:** a template carries a size only when the control has one *inherent*
size. Everything else is the caller's business — so `Layout.H` is a default, never an authority.

### Fonts — the norms, and the headers exactly

`GameFontNormalSmall` (size 10): **perM 10.67**, perI 3.14. The zone headers:

    identity 41.4   detect 35.1   action 33.9   stage 29.5   on-ramp 45.8   children 43.3

⚠ `GetHeight()` returned **0** on every font. The extent came from `GetStringWidth`; the *height* of
an unsized FontString is still unmeasured, and a second pass should read it after a `SetText` on a
shown frame.

### ⚠⚠ A real overlap in the live pane

    object.role  over  object.shape  by 146 x 6

`role` sits at y=-104 and is **32 tall** (the dropdown's template height, which `SetWidth` does not
touch); `shape` starts at y=-130. ★ Exactly the class §101's *a row is as tall as its tallest cell*
rule makes unrepresentable — found here in the shipped pane, by the same arithmetic.

### ★★★ And the play button is INSIDE its pane

    promoter.play   x=208   52 x 20   →  right edge 260, in a 280 pane
    [promoter] no overlaps, nothing outside

⚠⚠ **So the visible clipping is NOT a width overflow.** That is the second time that story has died —
first to arithmetic, now to the client's own measurement. **The cause is unknown.** It is not the
rect, so it is something the rect does not describe: art beyond the frame edge, a strata question, or the
pane's position at that moment. ★ No third guess goes in here until something measures it.

### ⚠ And one bug of mine, in the reader

The first pass converted **every** control into `object.pane`'s frame — so the promoter's four
controls, which live in a different frame 970px away, came back as *"outside the pane by 1010"*.
Correct arithmetic about nothing, and it would have **buried** the real promoter answer under four
fabricated ones. Fixed: one frame of reference per pane, keyed by the control's own prefix.
