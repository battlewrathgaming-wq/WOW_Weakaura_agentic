# OUR CUSTOM CONTROLS — kind · form · composition, and which are just a COAT

_UI specialist, 2026-08-24, on his ask: *"inspecting our own custom controls to see where we can
improve them consuming them into the registry… We have the map pane it's self and the control widget
for the map. Some controls might be other controls in a different coat. And the play back controller
under curation that is a custom slider with controls that input onto it."*_

★★★ **THE QUESTION THIS PAGE ANSWERS, per control:** is it a **NEW KIND** (nothing published does
this) or a **COAT** (a standard kind wearing different art)? ⟶ A coat should stop being custom. A new
kind is what the registry is FOR.

⚠ **First pass, from source, and it does not classify what it has not read.** Anything absent below is
absent because it was not surveyed, not because it was found to be nothing.
⚠ **Not a mandate** (his ruling, same day): this is an offer and an inspection. Dev finds the edges.

---

## The survey — what our panes actually build
`CreateFrame` counts and the stock templates each file uses:

    map.lua        13    UIPanelButtonTemplate
    editor.lua     18    InputBox · UICheckButton · UIDropDownMenu · UIPanelButton
    object.lua     21    InputBox · UICheckButton · UIDropDownMenu · UIPanelButton
    promoter.lua    9    InputBox · UIDropDownMenu · UIPanelButton
    widget.lua      7    InputBox · UIPanelButton
    drive.lua       7    UIPanelButtonTemplate

★ **Every text/choice control we own is already a stock template.** Nothing bespoke is being used
where Blizzard or Ace publishes one — so the custom surface is narrower than it looks, and the
interesting cases are the three below.

---

## ⚠⚠ SUPERSEDED IN PART, 2026-08-24 — the RANGE IS NOT A TYPE BY THE TEST WE NOW USE
This page called the playback controller *"the clearest registry candidate"*. `UL-18` applies the
Addon creator's test — **a type needs a SECOND citable instance** — and the range has **one**
(`editor.lua`), with **AceGUI publishing none**. ⟶ **It fails.** Home: `concepts/type-or-feature.md`.

★ What survives, and it is most of the page: the CLASSIFICATION work (new kind vs coat vs already
written) and every measurement. What does not survive is the word *candidate* — a citable ABSENCE
marks something we may have to **define**, which is not the same as a unit other callers select.
⚠ Read §1 below as *the strongest thing we own that is NOT yet a type*.

## 1 · THE PLAYBACK CONTROLLER (Curation) — ★ A NEW KIND, and the clearest registry candidate

**Not a slider.** `editor.lua`:

    :423   track    BACKGROUND   the dim filled track - where the window MAY go
    :427   envFill  ARTWORK      the envelope
    :431   winFill  OVERLAY      ★ the WINDOW - bright, and it is a RANGE not a point
    :473   two handles, each its own texture
    :507   h:SetScript("OnMouseDown", function(self) self:SetScript("OnUpdate", drag) end)
    :438   bar:SetScript("OnMouseDown", ...)   the bar itself takes a click to MOVE the window

⟶ **A two-handle RANGE over an envelope.** AceGUI publishes a Slider — one value, one thumb — and
**no range widget at all**. So this is not a slider in a coat; it is a kind nobody gave us.

    KIND          RANGE (lo..hi window over an envelope)          ★ ours, genuinely
    FORM          press-to-grab drag · click-the-bar to move the whole window
    COMPOSITION   range + `- + < Play >` steppers + Peek + Reset + the `window X of Y - Z` readout
                  ⟶ the steppers INPUT ONTO the range - his words, and that is the composition

★★ **AND IT ALREADY CARRIES HARD-WON FORM KNOWLEDGE**, which is exactly what a registry entry is for
rather than a comment only its author will read:
- `:454-458` — *press-to-grab has no threshold*, and *the bar UNDERNEATH takes a click as "move the
  window"*, so an 8px handle miss does the wrong thing. **A conflict between two mouse targets, named
  in place.**
- `:761` — *"No speed control, because the window width already IS the speed control."* **A control
  that was NOT built, and why.** ⟶ The registry should carry the omission as readily as the part.

## 2 · THE MAP CONTROL WIDGET — ⚠ A COAT, and it should stop being custom
`map.lua` builds it from **`UIPanelButtonTemplate` only** — zoom −/+, up/down/left/right, Re-centre,
100%, Reset, plus two checkboxes.

    KIND          Button · CheckBox        the client's, unchanged
    FORM          a 3x3 pad: the d-pad occupies the cross, zoom and reset take the corners
    COMPOSITION   ★ THE PAD ITSELF is the only custom thing here

⟶ **Nothing about the parts is new; the ARRANGEMENT is.** ★ And `UL-9`'s A·2–A·3 already measured what
that arrangement costs: every button is sized to its own text so the three columns do not line up, and
*"the d-pad is actually right and the corners hide it."* ⟶ A `pad` composition in the registry —
**declared as a 3×3 with named slots and one width for the column** — would fix the alignment by
construction rather than by hand-typing nine x values.

## 3 · THE MAP SURFACE — ★ A NEW KIND, and it is already documented
Not a control at all in Ace's sense: a **scaled canvas with its own coordinate space**.

    KIND          CANVAS (a coordinate space + tiles + placed points)
    FORM          zoom is `canvas:SetScale` - UNIFORM, so 3x covers 3x the ground
                  pan is clamped in scaled units; a point is a FRACTION, never a pixel
    ⚠ AND ITS CORRECTION HAS A NAME AND A HOME:  `concepts/coalesce.md`

★ `map.lua:44-61`'s [SILENT] fact — the coordinate space is 1002×668 and the tile art is 1024×768, so
confusing them renders **wrong by +2.2% across and +15% down and nothing reports it** — is precisely
the class of thing a registry exists to stop being rediscovered. ⟶ **The canvas kind's entry is
mostly written already**; it needs consuming, not deriving.

---

## What falls out — ⚠ REWRITTEN 2026-08-24, because the first version said the opposite
1. **The RANGE is NOT the thing to register first.** It is used ONCE, and by the test in
   `concepts/type-or-feature.md` one instance is a feature. ⟶ What it IS: **the strongest candidate
   for something we may have to DEFINE**, because `AceGUI` publishes no range widget — a citable
   absence rather than a citable second instance. ★ Its form knowledge (`:454-458`, `:761`) is still
   worth extracting; extraction is not the same as minting a type.
2. **One COAT to stop hand-building: the map pad.** Its parts are stock; only the 3×3 arrangement is
   ours, and `UL-9` already measured the cost of doing it by hand. ⚠ A coat is not a type either —
   what would be registered is the PAD composition, and it too has one instance.
3. **One kind already written but not consumed: the CANVAS**, via `concepts/coalesce.md`. Also one
   instance.

⚠⚠ **SO THIS PAGE FINDS NO TYPES, and that is the honest reading.** Every custom control we own is
used once. ⟶ The types this bench has are the ones the Addon creator found (`UI-2`: variant slot,
sourced picker, stepped ladder) and the two the FIELD supplies (collapse, tabs) — **not the bespoke
things, which is the opposite of what a custom-control inventory expects to conclude.**

⚠ **NOT surveyed and therefore not classified:** `promoter.lua`'s running-order list, `widget.lua`'s
remote, `drive.lua`'s readouts, and the Landmarks / PetGrid / StatePlates addons entirely. Each may
hold a coat or a kind; nobody has read them for this.
