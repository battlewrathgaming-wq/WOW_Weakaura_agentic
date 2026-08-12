# Addon census — holding our own code to the standard we hold theirs to

**Emitted, never hand-edited.** Regenerate with:

```bash
py addons\tools\emit_addon_census.py
```

## Why it exists

We built `COA_DevDump/task_callwitness.lua` because Libellus Leti had no self-reporting —
*"a witness we do not have"*. Answering **"which function costs frames?"** for somebody else's
addon took a purpose-built instrument, four capture arms and a run sheet.

We then had no witness for our own code either. This is it, and it is a **file you read**
rather than an instrument you run.

## The files

| File | |
|---|---|
| `frame_cost.md` | **read this one.** Every point our code runs without the user asking |
| `addons.routes.md` | per addon and file: functions defined, what it pulls from the client, what it pushes |
| `addons.census.json` | the machine copy |

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
