# Promotion · the play button that was never clipped

_Commits: `11c45c9` §103 · `823a5bc` §104 · `a275469` §113_

## The question

The play button beside the route selector looked cut off. It had looked cut off for weeks.

## The reasoning

**I said it was the pane edge. Twice.** x=208, a 52-wide button, a 280-wide frame — so it must be
running off. ⚠ It never was: 208 + 52 = 260, which is **twenty pixels inside**. The arithmetic said
so the first time anyone did it, and I had asserted it without doing it.

★ The geometry probe then measured the live pane and agreed: `promoter.play` sits at 208, 52 wide,
nothing outside, no overlaps. **So the story died twice** — once to arithmetic, once to the
client's own numbers — and I still had no cause.

**He found it by looking:**

> *"It looks like the drop down selector is sitting above the button. And that the button looks to
> not have content."*

Then, on strata:

> *"Above as in strata."*

And the piece I did not have:

> *"The content field, and the click drop-down art, that reacts, aren't the same thing."*

★★★ **That was the whole thing.** `UIDropDownMenu_SetWidth(dd, w)` sets **three** different extents
from one argument, and I had been treating them as one:

    field  w        the sunken area the selection reads in
    text   w - 25   the string inside it
    art    w + 50   the frame, and the arrow that reacts to a click

`SharedXML/UIDropDownMenu.lua:962` — sourced after the fact, and it agreed with the live measurement
exactly. Asked for 200, so the art painted to **252**, and the button started at **208**. A 44 × 20
overlap, leaving eight pixels of a 52-wide button clear. That sliver is what "looks to not have
content" means.

### The wrong turns

- ⚠ **Blamed the pane edge** — twice, and dressed an assumption as a diagnosis both times.
- ⚠ **Assumed the check could see it.** It could not: the route dropdown was **never registered**,
  so the probe read four controls in a pane that has five. A collision needs two operands and the
  check only ever got one.
- ⚠ **Reached for `SetWidth(dd, 200, 0)`** as a fix, because a third argument exists that would
  make the *frame* 200. ★ It does not escape anything — `Left(25) + Middle(w) + Right(25)` is still
  `w + 50` of artwork, now overflowing a frame that claims to be smaller. **Worse than the honest
  version**: it hides the overflow from the rect check meant to catch it.

### And it was in my own wireframe

Budgeting a dropdown at its asked-for width put two 96s at x=0 and x=108 that are really 146s — a
38px collision the smoke could not see, because it sized its stub to the number in the spec rather
than the number the client builds. **Same class, my file, found only because the footprint became
honest.**

## What fell out

- **`Layout.DROPDOWN_PAD = 50`**, and `FIELD` / `TEXT` / `ART` as three named extents. → `layout.lua`
- **The registry names; the pane enumerates.** `task_geom` now walks a pane's children and measures
  everything in it, registered or not. An unregistered widget lands as `(unregistered Frame #3)` and
  collides loudly. → §103
- **Strata and frame level joined the capture.** The first run recorded rects and nothing else, so
  his strata question was unanswerable from it — and `task_frames` had been recording both all
  along.
- **The pane grew instead of the controls shrinking.** His call: *"make the pane bigger. It already
  takes over the UI. No point fighting that."* 280 → 320; the dropdown asks 200 again; the button
  moved to 258. → §104
- ⚠ **The wireframe was re-laid** — one dropdown per row, because `2W + 100` leaves under 50 in a
  204 column. That forced two zone merges to pay for the height.
- 💀 **The button itself is gone.** §113 removed `walk.lua`, which was its engine. It was a
  *test-drive* button, and testing became its own bounded activity.

## What it left in the factual file

`interface/promotion.md` · the three dropdown extents in
`dungeonrun_interface_inventory.md` → **Constants, sourced**.
