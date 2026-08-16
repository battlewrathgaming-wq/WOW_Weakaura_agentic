# Curation — the slicing surface

_`editor.lua` · `COA_DungeonRunEditor` · **320 × 366** · content column x=18, width 284_

★★★ **The factual register.** What exists, or what the code must comply with.

★ **Reconciled by `check_interface.py`** — the file and global named above, the declared size, and every `forms · phrase` citation. Bench menu **[7] Reconcile**, or run it directly. ⚠ It checks the mechanical part only; whether `does`, `how` and `refuses` are still true is curation.

---

## ★★★ The model — what it IS

**Curation is the instrument of DISTINCTION, and it has two sides.**

### 1 — valuation, ACROSS runs

> *"That is you curating that run. Assigning value. Out of 10 runs, 2 might represent the best
> runs. (Pulling the right amount of mobs. Taking the right routes, not wiping.) This lets you
> rank/value your own performance, and curate runs before you seek to extract."*

★★ **Naming and commenting are not conveniences — they ARE the curation.** They are how a set of
captures becomes a ranked set, so you know which two of ten are worth extracting from before you
open Promotion. ★ That is why they are the only things here that touch the record: a judgement
about a run is *about* the run, and it has to survive.

⚠ So the run selector is not a file picker. It is the surface of a **valued set**.

### 2 — readability, WITHIN a run

★★ **Information becomes noise when distinction cannot be made.** A run arrives as an
undifferentiated mass; this is what makes it legible enough to reason about.

**And a run is a DURATION, which cannot be read at once.** So the envelope, window, step and play
are not filters — they are how you **move through** it. That is what makes the map's *recount
moments in time* possible rather than aspirational.

### ★ The line against Promotion

| | |
|---|---|
| **Curation frames and values** | changes what is in view, and what a run is worth. Reversible; creates no route |
| **Promotion reduces** | extracts and commits. Produces a new artifact |

★★★ **You cannot reduce what you cannot read.** Curation is not a convenience upstream of
Promotion — it is a precondition. ⚠ And it is why *only ever changes what you see* holds for the
readability half: framing that could alter the evidence would make every later reduction a
question about what was trimmed.

## does

1. **Loads a captured run** onto the map.
2. **Names and comments it** — rename, delete, a free-text note.
3. **Filters what is drawn** by kind — combat legs, travel legs.
4. **Slices it by TIME** — an envelope, a movable window, step, play, peek.
5. **Opens Promotion**, which is where a run turns into a route.

## refuses

★★★ **⚠ CURATION ONLY EVER CHANGES WHAT YOU SEE. Nothing it does touches the record.**

That is the load-bearing rule of the whole surface. Filtering, windowing, peeking and playing are
all *view* state. The captured run is immutable once landed — judgement happens offline against
the whole set, and a curation that could edit the capture would make every later reading of that
run a question about what was trimmed.

⚠ Rename, delete and comment are the exceptions, and they are **metadata about** the run rather
than the samples in it.

★ **And it does not decide at capture time.** His: *"combat movement is very messy when
in-pull."* The truthful view needs a way to be **quietened**, not a decision at capture time
about what to keep. So the filter is here, downstream, and reversible.

## how

    reads     Map.LoadedId("run")   which run is on screen
              Map.Window/Envelope/Span/SkipStep   the time slice
              Store.Get             the run record, for the name and comment

    writes    Map.Show(kind, on)    filter state — VIEW only
              Map.SetWindow/SetEnvelope/SetPeek    the slice — VIEW only
              Store.Rename/SetComment              metadata ABOUT the run
              Store.SetUI                          its own window position

★★ **The time model is three numbers.** An **envelope** (the outer bounds you have narrowed to),
a **window** (position and width inside it), and a **skip step** derived from the width. Every
control moves one of them.

★★★ **Playback is auto-skip, once a second — and the rate is not arbitrary.** It makes Play obey
the same invariant as the step buttons: ten steps crosses whatever you framed, so ten seconds
plays it, whether that is one pull or the whole run. ⚠ **There is no speed control because the
window width already is one.**

★ **The `OnUpdate` exists only while playing** — installed by `TogglePlay`, cleared by
`StopPlay`, and cleared again when it runs off the end. Same discipline as the capture sampler,
and what keeps the census reporting zero persistent `OnUpdate`.

## interacts

| you | it |
|---|---|
| pick a run from the dropdown | loads it; the envelope resets to the whole run |
| **Rename** / **Delete** | metadata, through a `StaticPopup` — the client's own dialog, not a bespoke one |
| type in the comment box | stored against the run |
| tick **combat legs** / **travel legs** | shows or hides that kind. Reversible, and never a capture decision |
| drag a **handle** | moves one end of the time window |
| **-** / **+** | narrows or widens the window |
| **<** / **>** | steps it by `SkipStep` — a tenth of the framed span |
| **Play** | steps once a second until it runs off the end, then stops itself |
| hold **Peek** | shows the whole run while held. **Latch** keeps it held |
| **Reset** | restores the full envelope |
| **track most recent node** | follows the newest sample |
| **Promotion** | opens the minting surface |

## holds

    playing        transient   set by TogglePlay, cleared by StopPlay or running off the end
    acc            transient   the playback accumulator, zeroed on stop
    peekHeld       transient   while the button is down
    peekLatched    transient   until unlatched
    window pos     persists    Store.SetUI

⚠ **The window and envelope are the MAP's state, not this pane's.** Curation reads and sets them
through `Map.*`. It keeps no copy — the §63 rule again.

## relates

    opened by   the Map's "Curate" button
    opens       Promotion
    shares      its width with Promotion, so the two stack on one vertical edge (§107)

⚠⚠ **And it OVERLAPS the Map on screen.** Curation is `DIALOG` + toplevel; the Map is `HIGH`. So
Curation draws over it, and the Map's own **"Controls"** and **"Curate"** buttons
(`map.lua:2214`, `:2221`) read through wherever this pane's backdrop is not opaque. ★ That is what
he saw and reported as text sitting across the tab labels — not this pane's widgets at all.

⚠ **No check can see that.** Every geometry check asks whether one pane is internally consistent.
Nothing asks whether two panes collide on screen.

## children

☐ **The pane got wider and the content did not.** §107 took it 280 → 320 for the shared edge, and
every x and width below is still laid out for 280. **That is the dead space he named.**

```
editor.pane        kind frame   usage — (the surface itself)
                    does  the pane itself. `set("close")` hides it, `read` reports shown
                    ★ REGISTERED §128 — which is also how `task_geom` finds this pane to walk

editor.title        kind readout   usage readout   forms editor.lua · `title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")`, GameFontNormal, text "Curation"
                    numbers at (18, -16)                                  ⚠ NOT REGISTERED

editor.run          kind dropdown   usage selection · dropdown  forms editor.lua · `dd = CreateFrame(`, UIDropDownMenuTemplate
                    does  selects the loaded run
                    numbers field 200 · text 175 · art 250 · h 32 · at x=2
                    ⚠⚠ NOT REGISTERED — the third unseen dropdown
                    ⚠ art ends at 252 in a column that now runs to 302

editor.rename       kind button   usage action    forms editor.lua · `renameBtn = CreateFrame(`   numbers w 70 · h 20 at (16, -66)
editor.delete       kind button   usage action    forms editor.lua · `delBtn = CreateFrame(`   numbers w 70 · h 20 at (92, -66)
editor.comment      kind edit   usage input · free      forms editor.lua · `commentBox = CreateFrame(`   numbers w 272 · h 20 at (22, -92)
                    ⚠ NOT REGISTERED (all three)

editor.showlabel    kind readout   usage readout   forms editor.lua · `local show = f:CreateFontString(nil, "OVERLAY", "GameFontNor`   numbers at (18, -120), text "show"
                    ★ A HEADER WITH NO DIVIDER AND NO ZONE BINDING — the `behaviour` orphan
                      class §99 made unrepresentable in the Object pane, still alive here

editor.kind.<key>   kind check   usage selection · tick     forms editor.lua · `cb = CreateFrame(`, one per FILTERS entry, named
                                         COA_DungeonRunFilter<key>; its label is $parentText,
                                         built from the name rather than read back off the frame
                    does  shows or hides that kind
                    numbers w 22 · h 22 at (16, -136 - (i-1) * 24)  ⇒ a 24 PITCH
                    ★ the only REPEATED row in any pane — its count follows FILTERS, so the
                      PITCH is the number that matters, not a list of y values

editor.bar          kind readout   usage readout   forms editor.lua · `bar = CreateFrame(`, a Frame with three textures:
                                         track (BACKGROUND), envFill (ARTWORK), winFill (OVERLAY)
                    does  draws the envelope and the window inside it
                    numbers w 244 (BAR_W) · h 12 at (18, -190)     ⚠ 40 short of the column

editor.handle.<a|b> kind button   usage selection · range    forms editor.lua · `h = CreateFrame(` + its `t = h:CreateTexture(`
                    does  drags one end of the window
                    numbers grab w 16 (GRAB_PX) · h 20 · VISUAL 4 × 18
                    ★★ The grab area is FOUR TIMES the visual — a 4px handle is unhittable.
                       ⚠ A rect check sees 16, the eye sees 4. Both real, different questions

editor.width        kind readout   usage readout   forms editor.lua · `widthText = f:CreateFontString(nil, "OVERLAY", "GameFontDisa`   numbers at (18, -208)
editor.step.<n>     kind button   usage selection · range    forms editor.lua · `local function stepBtn(` and its sibling group
                    numbers w 22 · h 20 at (dx, -226)   ⚠ dx computed in-line, not declared
editor.play         kind button   usage arm   forms editor.lua · `playBtn = CreateFrame(`   numbers w 50 · h 20 at (102, -226)
editor.skip         kind readout   usage readout   forms editor.lua · `skipText = f:CreateFontString(nil, "OVERLAY", "GameFontDisab`   numbers at (184, -231)
                    ⚠ -231 on a row at -226. A 5px hand-nudge with no stated reason

editor.peek         kind button   usage arm   forms editor.lua · `peekBtn = CreateFrame(`   numbers w 60 · h 20 at (16, -252)
editor.latch        kind check   usage arm     forms editor.lua · `latchBtn = CreateFrame(`   numbers w 20 · h 20 at (80, -252)
editor.reset        kind button   usage action    forms editor.lua · `resetBtn = CreateFrame(`   numbers w 60 · h 20 at (110, -252)
editor.track        kind check   usage selection · tick     forms editor.lua · `trackBtn = CreateFrame(`   numbers w 20 · h 20 at (16, -276)

editor.hint         kind readout   usage readout   forms editor.lua · `hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSm`   numbers w 284 at (18, -302)
                    ★ already the full column width — the only thing §107 widened
editor.promote      kind button   usage action    forms editor.lua · `promoteBtn = CreateFrame(`   numbers w 110 · h 20, BOTTOMLEFT (16, 14)
                    ★ the only BOTTOM-anchored control in the addon. It survives the pane
                      changing height, which is why it is the right anchor for a footer
```

☐ **Nothing in this pane is registered**, so the geometry probe cannot see any of it.

---

## Outstanding

<!-- OUTSTANDING:BEGIN - emitted by emit_outstanding.py, do not edit by hand -->

6 items:

- The pane got wider and the content did not. §107 took it 280 → 320 for the shared edge, and every x and width below is still laid out for 280. That is the dead space he named.
- Nothing in this pane is registered, so the geometry probe cannot see any of it.
- The four `<pattern>` keys escape the coverage score — and the capture says what they hold.
- The two window-width buttons are undeclared — CONFIRMED by measurement, 22 × 20 each, sitting in the walk as `editor.(unregistered Button #10..#13)` beside the two steps. `widthBtn("-")` and `widthBtn("+")` halve and double the window; `editor.width` is the readout beside them, not them.
- The two envelope handles report NO WIDTH AND NO HEIGHT. `w` and `h` came back null where every other child returned a number. They are `CreateFrame("Button", nil, f)` sized only by the texture they carry, so the frame itself was never given an extent. ⚠ This is the same shape as the bug that crashed the offline resolver — arithmetic on a nil width — except here it is the LIVE object, and it means a drift check cannot compare them against anything.
- `editor.close` is declared nowhere, and neither is Promotion's or the Object pane's. Three panes carry a 60 × 20 Close and no surface file has a row for one. ★ Not a naming slip: it is the control every one of those panes ends on, and the document that is supposed to describe a surface whole has never mentioned it.

<!-- OUTSTANDING:END -->

---

★★★ **MEASURED, §132** — the greedy capture (`records/20260816_053425_564__geom.json`) walked this pane with
all six open. **20 children, 11 registered, 9 not**, and every one of the nine is named below.

☐ **The four `<pattern>` keys escape the coverage score — and the capture says what they hold.**

    editor.kind.<key>     2   COA_DungeonRunFiltercombatleg · COA_DungeonRunFilterleg
    editor.handle.<a|b>   2   ⚠ BOTH UNSIZED — see below
    editor.step.<n>       2   22 × 20
    map.tile.<n>         12   TILE_COLS × TILE_ROWS

★ The pattern keys were the honest form for a family, but they bought that honesty by leaving the
members uncounted — and *how many* is exactly what nobody could answer from the document. Now
measured. Either expand them to concrete keys, or teach the checker to count a pattern as N.

☐ **The two window-width buttons are undeclared** — CONFIRMED by measurement, 22 × 20 each, sitting
in the walk as `editor.(unregistered Button #10..#13)` beside the two steps. `widthBtn("-")` and
`widthBtn("+")` halve and double the window; `editor.width` is the readout beside them, not them.

☐ **The two envelope handles report NO WIDTH AND NO HEIGHT.** `w` and `h` came back null where
every other child returned a number. They are `CreateFrame("Button", nil, f)` sized only by the
texture they carry, so the frame itself was never given an extent. ⚠ This is the same shape as the
bug that crashed the offline resolver — arithmetic on a nil width — except here it is the LIVE
object, and it means a drift check cannot compare them against anything.

☐ **`editor.close` is declared nowhere**, and neither is Promotion's or the Object pane's. Three
panes carry a 60 × 20 Close and no surface file has a row for one. ★ Not a naming slip: it is the
control every one of those panes ends on, and the document that is supposed to describe a surface
whole has never mentioned it.


## Hopes and dreams

_What this surface still needs so **the model** can be realized (`dungeonrun_model.md`). Not technical — the backlog to realize._

### Readability modes — moving through a run

★ A duration cannot be read at once, and there is more than one way to step through one:

- **Group the combat legs between their start and end**, and move through just your **pulls**.
- **Isolate the combat-end → combat-start groups** and jump between them — the TRAVEL between
  pulls, which is the other half of a route and currently has no way to be read on its own.
- **Full filtering of data types from view.** Today that is two ticks, combat legs and travel
  legs; the shape wants to be a general selection rather than a fixed pair.

★ **Population and display generation are NOT here.** A detector radius and a same-height
painted zone draw something the capture never held, so they belong to Map controls — see the
inventory's **FILTER vs GENERATE** cut. This surface subtracts; that one adds.

- **Dead space trimmed**, and every item either justified or handled properly.

  > *"Looks better. Long term dead-space to trim. But items to justify or handle properly.
  > But the burden is eased."*

- **The panes stop reading through each other.** The Map's own buttons showing through this
  one is not a fault in either pane, and it is still what you see.
