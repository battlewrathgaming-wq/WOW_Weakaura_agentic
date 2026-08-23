# `/coadump r sheet` — the run card

_The UI test sheet: spawn it, measure every declared cell, record it. **Read-only** — it creates its
own frames and reads them; nothing on any push list is called and no client state moves._

## ★★★ One command. No arguments. Every time.

Battlewrath, 2026-08-23: *"I get lost writing the test commands manually."* ⟶ There is nothing to
remember and nothing to type differently at any setting. **The run reads the configuration off the
client rather than being told it**, so a resolution sweep is the same two lines repeated.

## Before (once)

```
py addons\deploy.py COA_DevDump
```

⚠ **Scoped on purpose.** `deploy.py` with no argument copies every resident, and at the time this card
was written `COA_DungeonRun` had two files (`drive.lua`, `routes.lua`) modified but not deployed by
another seat. Carrying someone else's in-flight work into the client as a side effect of a UI capture
is not a thing this run should be able to do. ★ `py addons\deploy.py status` is read-only and says
what is pending before you copy anything.

Then a **full client restart** — new files (`sheet_decl.lua`, `task_sheet.lua`), not a `/reload`.

Leave the watcher running in a second terminal; it lands every flush on its own:

```
py addons\landing\pull.py watch
```

## The loop — repeat per configuration

In-game:

```
/coadump r sheet
/reload
```

In the repo:

```
py addons\tools\check_sheet.py
```

That is the whole sweep. Change the client's resolution or UI scale, run the same two lines again.

## What a good run looks like

- the chat summary ends with the **resolution and uiScale it just measured** — that is your receipt
  that the configuration actually changed;
- the sheet is **on screen** after the run (drag it by its body, close it with the X). ⚠ It is shown
  *because* it is measured: across seven prior captures every shown FontString width sits on the
  client's integer grid and the never-shown control width is the only value off it, 1.7% out — the
  worst kind of wrong, because nothing downstream would flag it;
- `check_sheet.py`'s **configurations** table gains a row, and once there are two it prints the
  q-across-configs verdict;
- the eleven swatch rows are the *taste* half — they are there to be looked at, not measured.

## ⚠⚠ Read the apparatus line first

★★★ **A zero and a measurement that never happened look identical in a file.** The run measures a
known string before believing anything; if that comes back zero it writes `apparatus = "dead"`,
records nothing else, and says so. **If you see `APPARATUS DEAD`, nothing in the run is usable.**
That is the design working.

⚠ And if `sheet_decl.lua` is not loaded, the run **refuses** rather than measuring specimens it
invented — a standard the measuring tool made up is not a standard.

## What the sweep is for

One question is open: **what q is.** The returned unit is `1/q` = 1.5936 device px, while
`uiScale × screenH/768` = 2.2534 — so the client's rasterisation pixel size is not the obvious one.

| if the sweep shows | then |
|---|---|
| **q moves** with the configuration | it is a device-pixel artefact; the rasterisation size is derivable, and *hinted* advances should close the residual |
| **q is fixed** across configurations | it is a font-engine constant, and "±N q, marked" is the final answer |

★ Either outcome closes it, and closes it for every future cell kind at once — templates, surfaces,
placement. **Two configurations is the minimum; three or four make the relationship readable rather
than merely different.** Vary uiScale *and* resolution, not only one of them — they enter the
suspected mapping as a product, so moving one at a time is what separates them.

⚠ The run also records `GetScreenWidth`/`GetScreenHeight` and `UIParent`'s own extent at every
setting. Those are the client's idea of its UI size, and they are the missing term if q turns out to
be a device pixel.

## The loop constraint nobody can remove

**run → reload → read.** SavedVariables only reach disk on `/reload` or logout.

Related: `ui_sheet_spec.md` (why the sheet is shaped this way) · `UI_LOG.md` UL-1/UL-2 ·
`geom_probe_runsheet.md` (the run this one grew out of) · `addons/tools/check_sheet.py`.
