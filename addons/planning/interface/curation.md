# Curation — the slicing surface

_`editor.lua` · `COA_DungeonRunEditor` · **320 × 366** · content column x=18, width 284_

★★★ **The factual register.** What exists, or what the code must comply with.

---

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
editor.title        kind readout   forms editor.lua:282, GameFontNormal, text "Curation"
                    numbers at (18, -16)                                  ⚠ NOT REGISTERED

editor.run          kind dropdown  forms editor.lua:286, UIDropDownMenuTemplate
                    does  selects the loaded run
                    numbers field 200 · text 175 · art 250 · h 32 · at x=2
                    ⚠⚠ NOT REGISTERED — the third unseen dropdown
                    ⚠ art ends at 252 in a column that now runs to 302

editor.rename       kind button    forms editor.lua:298   numbers w 70 · h 20 at (16, -66)
editor.delete       kind button    forms editor.lua:307   numbers w 70 · h 20 at (92, -66)
editor.comment      kind edit      forms editor.lua:318   numbers w 272 · h 20 at (22, -92)
                    ⚠ NOT REGISTERED (all three)

editor.showlabel    kind readout   forms editor.lua:330   numbers at (18, -120), text "show"
                    ★ A HEADER WITH NO DIVIDER AND NO ZONE BINDING — the `behaviour` orphan
                      class §99 made unrepresentable in the Object pane, still alive here

editor.kind.<key>   kind check     forms editor.lua:337, one per FILTERS entry, named
                                         COA_DungeonRunFilter<key>; its label is $parentText,
                                         built from the name rather than read back off the frame
                    does  shows or hides that kind
                    numbers w 22 · h 22 at (16, -136 - (i-1) * 24)  ⇒ a 24 PITCH
                    ★ the only REPEATED row in any pane — its count follows FILTERS, so the
                      PITCH is the number that matters, not a list of y values

editor.bar          kind readout   forms editor.lua:358, a Frame with three textures:
                                         track (BACKGROUND), envFill (ARTWORK), winFill (OVERLAY)
                    does  draws the envelope and the window inside it
                    numbers w 244 (BAR_W) · h 12 at (18, -190)     ⚠ 40 short of the column

editor.handle.<a|b> kind button    forms editor.lua:408 frame + :412 texture
                    does  drags one end of the window
                    numbers grab w 16 (GRAB_PX) · h 20 · VISUAL 4 × 18
                    ★★ The grab area is FOUR TIMES the visual — a 4px handle is unhittable.
                       ⚠ A rect check sees 16, the eye sees 4. Both real, different questions

editor.width        kind readout   forms editor.lua:455   numbers at (18, -208)
editor.step.<n>     kind button    forms editor.lua:462 and :478, two groups
                    numbers w 22 · h 20 at (dx, -226)   ⚠ dx computed in-line, not declared
editor.play         kind button    forms editor.lua:493   numbers w 50 · h 20 at (102, -226)
editor.skip         kind readout   forms editor.lua:499   numbers at (184, -231)
                    ⚠ -231 on a row at -226. A 5px hand-nudge with no stated reason

editor.peek         kind button    forms editor.lua:513   numbers w 60 · h 20 at (16, -252)
editor.latch        kind check     forms editor.lua:520   numbers w 20 · h 20 at (80, -252)
editor.reset        kind button    forms editor.lua:531   numbers w 60 · h 20 at (110, -252)
editor.track        kind check     forms editor.lua:540   numbers w 20 · h 20 at (16, -276)

editor.hint         kind readout   forms editor.lua:551   numbers w 284 at (18, -302)
                    ★ already the full column width — the only thing §107 widened
editor.promote      kind button    forms editor.lua:570   numbers w 110 · h 20, BOTTOMLEFT (16, 14)
                    ★ the only BOTTOM-anchored control in the addon. It survives the pane
                      changing height, which is why it is the right anchor for a footer
```

☐ **Nothing in this pane is registered**, so the geometry probe cannot see any of it.

---

## Outstanding

<!-- OUTSTANDING:BEGIN - emitted by emit_outstanding.py, do not edit by hand -->

2 items:

- The pane got wider and the content did not. §107 took it 280 → 320 for the shared edge, and every x and width below is still laid out for 280. That is the dead space he named.
- Nothing in this pane is registered, so the geometry probe cannot see any of it.

<!-- OUTSTANDING:END -->

---

## Hopes and dreams

_What this surface still needs so **the model** can be realized (`dungeonrun_model.md`). Not technical — the backlog to realize._

- **Dead space trimmed**, and every item either justified or handled properly.

  > *"Looks better. Long term dead-space to trim. But items to justify or handle properly.
  > But the burden is eased."*

- **The panes stop reading through each other.** The Map's own buttons showing through this
  one is not a fault in either pane, and it is still what you see.
