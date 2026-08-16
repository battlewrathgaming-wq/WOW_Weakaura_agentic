# Object · zones, and the heading nothing could hide

_Commits: `82bee08` §99 · `90cf435` §101 · `11c45c9` §103_

## The question

> *"I think the UI needs updating to reflect the change. Or the UI isn't clear for what it
> represents. […] We've just not done the under-pinning work yet."*

And then, on how to start:

> *"Confirm the presentation structure first, then work out how to represent it?"*

## The reasoning

Two bugs were on screen, and neither was a mistake in the writing — **they are what
hand-positioning IS**:

    an ORPHANED HEADING   `behaviour` created once at y=-136, held in a local nothing else
                          can reach, never hidden. It survives every pane state including
                          the empty one, and sits beside an unrelated dropdown added three
                          sections later
    a CLIPPED BUTTON      which turned out not to be clipped at all — see
                          devlog/promotion/field-vs-art.md

★★ **Being careful is the failure mode.** Neither is fixable by trying harder.

His shape:

> *"---------------(divider, see if we can find a nice texture) / Header (To be maintained) /
> {Content slot ...} And what populates it is dynamic. And we develop a ratio vs content to
> maintain as a constant."*

★★★ **The divider belongs to the zone.** That is the whole binding. What orphaned `behaviour` was
not chrome-ness — it was being **free-floating**. A zone hides its rule, its header and its rows
together because they are one declaration, so the orphan class becomes **unrepresentable** rather
than caught.

And `hidden` is a *function of the subject*, not a flag someone sets — which is the difference
between "this zone does not apply to a note" being declared once beside the zone, and being
remembered in every branch of a refresh.

### The wrong turns

- ⚠ **Read `GetPoint()` back to preserve each widget's x.** Fragile twice over: a widget with no
  point has none to read, and the offline stub answers differently from the client. ★ Replaced with
  cells declaring their own x — *a row owns the Y, a cell owns its X*.
- ⚠ **Invented the constants.** `GAP = 6`, `ROW_H = 20`, `ZONE_GAP = 12`. Two of three were wrong,
  and the client's own panels had the answers: **6** header-to-content, **8** row-to-row, **12**
  zone-to-zone. I had collapsed the first two into one — a label and the thing it labels sit tighter
  than two neighbouring controls.
- ⚠ **Decreed a row height.** The client's controls are not one height, and a 32-tall dropdown in a
  20-tall row draws the next row twelve pixels into it. ★ A row is now as tall as its tallest cell —
  a collision the engine itself would have caused.
- ⚠ **Used the template heights.** `object.lua` sizes almost everything itself. Checking against
  26 and 22 checks a pane we do not have; dropping that distinction was **silent** through every
  check.

## What fell out

- **`layout.lua`** — zones, computed y, hides what it skips, sizes a pane to what is shown.
- **`panespec.lua`** — the pane as data. Zone, row, span, kind, subject. No pixels.
- **The constants, sourced and cited**, with 24 recorded and not adopted.
- **Four subject states checked offline**, including *nothing selected* — the state the orphan
  survived into, and the one that gets forgotten because it is boring.
- **The pane grew to 600**, because the child state needs 575 and cutting zones to fit a number
  nobody had measured is how the magic offsets happened in the first place.
- ⚠ **Two zone merges** — `detect`+`action` → **behaviour**, `stage`+`arrival` → **stage** — to pay
  for the height. Each zone costs 39px of chrome. ★ Both are one declaration to undo, and
  `behaviour` is the word the orphaned heading was reaching for.

## Still open

☐ **The pane is declared and still hand-positioned.** Every `forms` line in
`interface/object.md` is the old code, and the disagreements are listed rather than reconciled.

☐ **The footer readout** — one high-contrast space fed by hover or last action. Its contrast is not
specified and the hover half is not built.
