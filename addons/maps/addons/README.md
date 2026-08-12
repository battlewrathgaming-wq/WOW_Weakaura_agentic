# Addon census — holding our own code to the standard we hold theirs to

**Emitted, never hand-edited.** Regenerate with:

```bash
py addons/tools/emit_addon_census.py
```

## Why it exists

We built `COA_DevDump/task_callwitness.lua` because Libellus Leti had no self-reporting —
*"a witness we do not have"*. Answering **"which function costs frames?"** for somebody else's
addon took a purpose-built instrument, four capture arms and a run sheet.

We then had no witness for our own code either. This is it, and it is a **file you read**
rather than an instrument you run.

## The files — per addon AND a roll-up

**Inspecting one addon is never a trip through all of them** (Battlewrath): each resident has
its own folder, and every page stands alone with its own legend.

```
maps/addons/
  frame_cost.md            ← the bench roll-up: is ANYTHING costing frames?
  addons.census.json         machine copy, all residents
  COA_Landmarks/
    frame_cost.md          ← this addon alone
    routes.md                its functions, and what it pulls from / pushes to the client
  COA_DevDump/ …
```

**Start with the console line.** It answers *which addon do I even open?*:

```
py addons/tools/emit_addon_census.py
  COA_Landmarks    7 file(s)   71 fn  1 persistent OnUpdate   <- unthrottled-looking handler, look
```

`--addon <name>` filters what is **printed**. It never changes what is **written** — a flag
that emitted a partial census over a whole one would leave a file that lies about the bench,
and this exists to be trusted at a glance.

The resident list comes from **`deploy.py`'s MANIFEST** — the one authority on who lives here.
A second hand-kept list drifts, and `menu.bat`'s did (twice, silently).

## Reading `frame_cost.md`

**Lifetime is arithmetic: `installs − clears`.**

- **transient** — every handler is torn down again, so it runs only while something is
  happening: a drag, a running session task.
- **PERSISTENT** — none are. It runs for as long as the addon is loaded, and that is where a
  cost would live.
- **MIXED** — both, in one file. *A boolean hid this on the first pass:* `MancerLedger/minimap.lua`
  reported "transient" while holding a balanced drag pair **and two persistent animators**.

**`throttle?` is a LEAD, not a verdict.** It reports whether the file contains an accumulator
pattern at all. **`no` means go and look** — it does not mean the handler is unthrottled.

## Calibration — what the first run found

Worth knowing before you trust a red cell, because **all three flags were correct-by-design**:

| Flagged | Verdict |
|---|---|
| `COA_Landmarks/minimap.lua` — no throttle | **fine.** It is the minimap-button drag handler. It runs only while dragging and you *want* it unthrottled — a throttled drag stutters |
| `COA_DevDump/core.lua` — no throttle | **fine.** `D.Cycle` is a paced walker: it does `perFrame` steps and self-clears when done. The OnUpdate *is* the pacing mechanism |
| `MancerLedger/minimap.lua` — 3 installs, 1 clear | **fine, and it found a flaw in this tool instead.** Two persistent animators plus a balanced drag pair. Reported as MIXED now |

So: a first run that surfaced nothing broken, but pointed at exactly the right three places.
**That is the tool working.** A page of green tells you nothing; a page that flags the drag
handler tells you it can see drag handlers.

## The number moved as the tool got honest

**24 → 16 → 8.** The first count treated `SetScript("OnUpdate", nil)` as a second *handler*
rather than a *clear*. The second treated a mixed file as wholly transient. Each correction
made the number smaller and truer.

If a future run reports a big number, suspect the counter before the code.
