# Object — the edit pane

_`object.lua` · `COA_DungeonRunObject` · **240 × 600** · content column x=18, width **204**_

★ **The only surface declared in `panespec.lua`** — and the two are reconciled: `check_interface.py` compares every cell the spec BUILDS against the width and height declared below. ⚠ **This file is the authority**; a difference reads as the spec having drifted, never as this being out of date.

☐ But the pane is not yet BUILT from it — every
`forms` line below is the hand-positioned code, and the disagreements are listed rather than
quietly reconciled.

---

## does

Everything **about one selected object** — a beacon, a child, or a personal note:

1. **Identity** — what it is, its name, delete it, arm it for dragging.
2. **Behaviour** (child only) — how it detects, what it does when it has.
3. **Stage** — the number it satisfies, and what satisfying it does to the index.
4. **On-ramp** — whether it is the *come find me* point.
5. **Children** (beacon only) — spawn them here or from a picked point.

## refuses

★★★ **It is not the creation surface, and the promoter is not an editor.**

> *"All edit options of an object live within its edit mode interface. So where its values and
> information is defined, self contained. Instead of promotion being both a spawning and editing
> tool."*

- ⚠ **It holds no object of its own.** Only the map's selection. A pane that remembers what it is
  looking at can describe something the map is not showing — §63's fault.
- ⚠ **It does not validate.** Duplicate stages, gaps and fractions are legal; it shows a match
  count and a free-numbers line and then trusts the author.
- ⚠ **It warns before only when the act is IRREVERSIBLE, and emits after for everything else.**
  Minting a child is one delete from undone, so a warning buys little — and it can be missed
  entirely by someone who never hovers, where an emission is produced BY the press and cannot be.

## how

    reads     Map.Selected()         the subject — never stored
              Map.LoadedId("route")
              Routes.ParentOf        the child's anchor, FOUND not stored (§83)
              Routes.Outcome / AcceptanceOf / OnRampOf / RoleMatches

    writes    Routes.SetChildRole / SetChildShape / SetChildReach / SetChildAction
              Routes.SetChildGoTo / SetOutcome / SetChildOnRamp
              Map.SetMoveArmed       arms the MAP to perform a drag
              Map.Select / Map.Repaint
              Store.SetUI            its own window position

★★ **A determined option is not shown.** Picking `radius` does not then ask you to tick "one
point"; the set-target box appears only for `set`, and the target picker only for an action that
uses one. **Absent rather than disabled** — the authoring-pane rule, and the inverse of the HUD's.

★ **Dropdowns, not rows of ticks.** A four-option choice collapses to one line, it is the client's
own idiom, and at 240 wide a tree of radio rows does not fit.

## the test surface

★★★ **One line at the foot, blank until something is asked of it.** A REGISTRY, not a line per
control — adding a test is one registration, which is what makes *"we can feed other tests into
it"* true rather than aspirational.

> *"I say a test as it responds to what you click, rather than over reporting. And we can feed
> other tests into it."*

⚠ **It emits on the act; it does not catch before it.** The first cut fired on hover:

> *"Rather than catch, emit. They're clicking the button, so that can emit the look-up and return
> to the comment box."*

★★ A hover warns with a **prediction**; a click reports what actually **happened**, with the value
it actually used. One is a guess about the future written in the present tense.

⚠ **The failure mode it was built for is silent:** `child here` gives the child the *beacon's*
height, and dragging it afterwards does not change that — so a child dragged onto a walkway still
tests its band against the floor it was born on. It renders, it sits where you put it, and it
answers about the wrong storey.

⚠ **X/Y is deliberately not reported.** Out of bounds is the only way to get it wrong, and the map
shows you that by drawing the thing off the art.

## holds

    (subject)     NOT held    asks Map.Selected every refresh
    window pos    persists    Store.SetUI

## relates

    opened by   the Map, on right-click
    opens       nothing
    ★ its FOOTER readout copies the pattern the Driver's used to set —
      *"training the eyes the same way the driver widget will do"*
    ⚠ that Driver was removed in §113; the pattern outlived it

## children

★ Declared in `panespec.lua` across four zones — **identity · behaviour · stage · children** —
plus a footer that is not a zone. `behaviour` merges detect and act; `stage` merges the ratchet and
the on-ramp. Both merges bought back the 39px of chrome each zone costs, and both are one
declaration to undo.

Heights: `edit 20 · check 20 · button 20 · dropdown 32 · text 14`. ⚠ The dropdown is the one we do
**not** size — `UIDropDownMenu_SetWidth` sets the width only, so the template's 32 is what the row
must carry, and a dropdown's ART is always its asked-for width **+ 50**.

```
object.fact        zone identity  row 1  span full   kind readout
                   does  what this object is, in one line
                   numbers w 204 · h 14      forms object.lua · `factLine = f:CreateFontString(`   ⚠ NOT REGISTERED
object.name        zone identity  row 2  span left   kind edit      forms object.lua · `nameBox = CreateFrame(`
                   numbers w 170 · h 20      ⚠ build says 192
object.move        zone identity  row 2  span right  kind check     forms object.lua · `moveChip = CreateFrame(`
                   does  arms the MAP to drag this object
                   numbers w 26 · h 20       ⚠ build says 20; template is 32
object.delete      zone identity  row 3  span left   kind button    forms object.lua · `delBtn = CreateFrame(`
                   numbers w 80 · h 20       ⚠ build says 70

object.role        zone behaviour row 1  span full   kind dropdown  forms object.lua · `roleDD = CreateFrame(`
                   does  which detector this child uses
                   numbers field 154 · art 204 · h 32   ⚠ build asks 96 → 146 of art
object.match       zone behaviour row 2  span full   kind readout   forms object.lua · `roleMatch = f:CreateFontString(nil, "OVERLAY", "GameFontDisa`
                   does  whether another child already claims this role   ⚠ NOT REGISTERED
object.shape       zone behaviour row 3  span full   kind dropdown  forms object.lua · `shapeDD = CreateFrame(`
                   ⚠ build asks 96
object.reach       zone behaviour row 4  span left   kind edit      forms object.lua · `radBox = numBox(`
                   ⚠ NOT REGISTERED · code name `radBox` · build says 38
object.action      zone behaviour row 5  span full   kind dropdown  forms object.lua · `actionDD = CreateFrame(`
object.target      zone behaviour row 6  span full   kind dropdown  forms object.lua · `targetDD = CreateFrame(`
                   ⚠⚠ NOT REGISTERED — a DROPDOWN the probe cannot see

object.stage       zone stage     row 1  span left   kind edit      forms object.lua · `stageBox = CreateFrame(`
                   ⚠ build says 44
object.stagematch  zone stage     row 1  span right  kind readout   forms object.lua · `matchText = f:CreateFontString(nil, "OVERLAY", "GameFontDisa`
                   ⚠ NOT REGISTERED · code name `matchText`
object.outcome     zone stage     row 2  span full   kind dropdown  forms object.lua · `outcomeDD = CreateFrame(`
                   does  what satisfying this object does to the index
                   ⚠⚠ NOT REGISTERED · build asks 92
object.ramp        zone stage     row 3  span left   kind check     forms object.lua · `rampChip = CreateFrame(`
                   does  this object is the on-ramp — come find me
object.unseen      zone stage     row 3  span right  kind check     forms object.lua · `unseenChip = CreateFrame(`
object.answers     zone stage     row 4  span full   kind readout   forms object.lua · `answersLine = f:CreateFontString(nil, "OVERLAY", "GameFontDi`
                   does  the three answers — on-ramp, note, ratchet
                   ⚠ NOT REGISTERED · hand-placed at a fixed y=-96

object.kids        zone children  row 1  span full   kind readout   forms object.lua · `kidText = f:CreateFontString(nil, "OVERLAY", "GameFontDisabl`
                   ⚠ NOT REGISTERED
object.here        zone children  row 2  span left   kind button    forms object.lua · `hereBtn = CreateFrame(`
object.pick        zone children  row 2  span right  kind button    forms object.lua · `pickBtn = CreateFrame(`
                   ⚠ build says 100 for both

object.test        (footer)              span full   kind readout   forms object.lua · `testLine = f:CreateFontString(nil, "OVERLAY", "GameFontDisab`
                   does  ★★★ THE CONTEXT READOUT — one high-contrast space fed by hover or
                         last action, replacing the scattered grey lines
                   ⚠ CONTRAST NOT YET SPECIFIED · hover half not built · NOT REGISTERED
```

☐ `setBox` (`object.lua:671`) and `outcomeBox` (`object.lua:547`) exist in code and in no entry —
**justify or cut**.

☐ Wire the pane to `panespec.lua` - it is declared and still hand-positioned.

☐ `object.test` contrast is NOT YET SPECIFIED, and its hover half is not built.

## heights, per subject

    none    113      the hint only
    note    169
    beacon  415      + stage, on-ramp, children
    child   575      + behaviour

★★ **195 of the child's 575 is chrome** — five zones × 39 for the divider-and-header shape. That is
the price of the template, and it is worth seeing rather than discovering.

---

## Outstanding

<!-- OUTSTANDING:BEGIN - emitted by emit_outstanding.py, do not edit by hand -->

4 items:

- But the pane is not yet BUILT from it — every `forms` line below is the hand-positioned code, and the disagreements are listed rather than quietly reconciled.
- `setBox` (`object.lua:671`) and `outcomeBox` (`object.lua:547`) exist in code and in no entry — justify or cut.
- Wire the pane to `panespec.lua` - it is declared and still hand-positioned.
- `object.test` contrast is NOT YET SPECIFIED, and its hover half is not built.

<!-- OUTSTANDING:END -->

---

## Hopes and dreams

_What this surface still needs so **the model** can be realized (`dungeonrun_model.md`). Not technical — the backlog to realize._

- **One readout at the foot, in a space of its own.** High contrast, not grey on black,
  answering to hover or the last thing you did — and it absorbs the scattered grey lines
  rather than sitting beside them.

  > *"The main things to place/own, is the text. Designing what job it does, and giving it a
  > high contrast space to live, rather than grey on black. So a context specific read out
  > based on hover or last action."*

  ★ At the **bottom**, so the eye always knows where to look — *"training the eyes the same
  way the driver widget will do."*

- **Dead space trimmed.** *"Long term dead-space to trim. And items to justify or handle
  properly."*
