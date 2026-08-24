# THE RANGE CONTROL — its shapes, its behaviour, and where the clunk actually is

_UI specialist, 2026-08-24, on his ask: *"we probably want to take it's shapes. Examine it's
behaviour and build it better. Researching media / data set sliders and slicers for UI/UX
considerations. Right now it's a little clunky."*_

★★ **A DESIGN, NOT A BUILD, AND NOT A MANDATE** (his ruling, same day). The Addon creator owns
`editor.lua`. This is the RANGE kind's first registry entry, written in **kind · form · composition**.

⚠⚠ **AND MOST OF IT IS ALREADY RIGHT.** The control carries more considered input work than anything
else we own, and the proposal below must not cost any of it — §3 lists what may not be broken.

---

## 1 · THE SHAPES — what a range control has

    ENVELOPE   the dim track: where the window MAY go        editor.lua:423 track · :427 envFill
    WINDOW     the bright band: what is on screen            :431 winFill  ★ a RANGE, not a point
    LO / HI    two draggable marks                           :469-513 handle("lo") / handle("hi")
    READOUT    `window 0:40  of  0:00 - 0:40`                :177
    STEPPERS   `- +` halve/double the WIDTH · `< >` step      :730 - and they input ONTO the range

★ **THREE TARGETS, not two.** Every media scrubber, D3 `brushX`, DAW loop region and BI slicer gives
the user the two edges **and the BODY** — grab the middle, slide the whole window without changing its
width. ⟶ **That third target is the one we do not have as a drag**, and §2 is why it matters.

## 2 · ★★★ WHERE THE CLUNK IS — the edges slide and the middle TELEPORTS

    :438   bar:SetScript("OnMouseDown", function(self)
             ... Map.SetWindow(toSec(x, span) - (width or 0)/2, width); refresh()
           end)

**One shot. No `OnUpdate` installed.** So:

    LO / HI    press-to-grab, continuous, follows the cursor      :507
    THE BODY   a single JUMP that centres the window on the click  :438

⟶ **Same object, two interaction models.** The edges scrub; the middle cannot. To move a window you
click, look where it landed, and click again — **scrubbing is impossible, you can only teleport.**
★ That asymmetry is what *"a little clunky"* feels like from the inside, and it is one behaviour, not
a diffuse quality.

⚠ **And it fires on `OnMouseDown`**, so the window has already moved before you can think better of
it. There is no press-and-cancel.

### The other three, smaller
- **No keyboard at all.** The handles are `Button` frames with `RegisterForClicks` and nothing else.
  ⚠ The W3C ARIA APG multi-thumb pattern requires *"each thumb is in the page tab sequence and has
  the keyboard interactions described in the Slider Pattern"*, and that tab order stays stable even
  if thumbs cross. **We have none of it.** ⟶ It is also the natural PRECISION path, which the
  `-`/`+` (halve/double the width) does not provide for a specific time.
- **Coincident handles.** `:462-466` names it — two handles at the same second overlap exactly, one
  hides the other, and whichever is on top takes every press. A minimum separation is enforced at
  draw, so they never fully coincide; **which handle wins a grab in the crowded case is still
  unstated.**
- **The readout is not an input.** `window 0:40 of 0:00 - 0:40` is a FontString. Every BI slicer pairs
  its handles with typed bounds, because a pixel is a poor way to say *1:07*.

### ⚠ What the research does NOT say
The APG is **explicitly silent on the region between thumbs** — *"no explicit guidance about styling,
labeling, or functional behavior of the space between thumbs."* ⟶ **Body-drag is a media/data
CONVENTION, not an accessibility requirement.** It is still the right change, and it is worth knowing
which of the two it is: the keyboard gap is a standards gap; the body-drag is a convention gap.

## 3 · ⚠⚠ WHAT MAY NOT BE BROKEN — every line of this was paid for
    16 px invisible grab over a 4 px visual      :467 - the hit target IS the fix for "stuck"
    handles at bar frame level + 5               :471 - they swallow their own clicks
    minimum pixel separation at draw time        :466
    the drag ticker INSTALLED ON DRAG START      :507 - `emit_addon_census` caught the permanent
                                                 OnUpdate; the census exists because of it
    OnHide clears the ticker                     :511 - a grab ending off-button used to stick
    clamped to the TRACK before conversion       :492 - "stuck at the ends" was this
    cursor / bar:GetEffectiveScale()             :498 - and the note that it is right by
                                                 COINCIDENCE today, since handle and bar share a scale
    halve/double rather than a fixed step        :730 - one control spans a 13-minute run and a
                                                 5-second pull
    no speed control                             :761 - "the window width already IS the speed control"

★ **A rebuild that loses any of these is a regression that will read as new clunk.**

## 4 · THE PROPOSAL — one interaction model, three targets

    BODY DRAG    press-to-grab on the window band, exactly the handles' idiom: OnMouseDown installs
                 the ticker, OnMouseUp and OnHide clear it. The window SLIDES; width is untouched.
    CLICK        keep jump-to-here, but move it to a press that did NOT move
                 ⟶ press-and-slide = scrub · press-and-release = jump · and cancel exists again
    KEYBOARD     each handle tab-reachable; ←/→ nudge one step, shift larger, Home/End to the
                 envelope ends; thumbs may not cross (APG)
    PRECISION    the readout becomes an input unit - and it is `input.freehand` from the registry,
                 so it inherits commit-on-Enter, focus cleared, and its own response slot

⟶ **Then all three targets behave the same way, and the control has a keyboard path and a typed
path.** Nothing above changes the arithmetic; every item is in the input layer, which is where all
three previously-found causes lived too.

## 5 · AS A REGISTRY ENTRY

    KIND          range          two bounds over an envelope. ⚠ Not in AceGUI; ours.
    FORM          press-to-grab everywhere · press-without-move = jump · thumbs cannot cross ·
                  grab target >= 16 px over any visual · ticker installed on demand, never persistent
    COMPOSITION   envelope + window + two handles + readout(input) + width steppers
    OMISSION      no speed control - the window width IS the speed control (:761)
    ⚠ CARRY THE OMISSION. A registry that only lists parts invites someone to add the one that was
      deliberately left out.

## What this does not settle
Whether it is worth doing now. The control works and its faults are named; `AL-46`'s *adopt on touch*
is the posture, and the natural moment is the next time `editor.lua` is open. ⚠ And nothing here has
been measured in-client — the sheet has no `range` kind, because there is one instance and a kind
with one instance is a specimen, not a standard.
