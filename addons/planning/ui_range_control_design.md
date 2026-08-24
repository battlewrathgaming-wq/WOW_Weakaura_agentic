# THE RANGE CONTROL — its shapes, its behaviour, and where the clunk actually is

_UI specialist, 2026-08-24, on his ask: *"we probably want to take it's shapes. Examine it's
behaviour and build it better. Researching media / data set sliders and slicers for UI/UX
considerations. Right now it's a little clunky."*_

★★ **A DESIGN, NOT A BUILD, AND NOT A MANDATE** (his ruling, same day). The Addon creator owns
`editor.lua`. This is the RANGE kind's first registry entry, written in **kind · form · composition**.

⚠⚠ **AND MOST OF IT IS ALREADY RIGHT.** The control carries more considered input work than anything
else we own, and the proposal below must not cost any of it — §3 lists what may not be broken.

---

## 0 · ⚠⚠ CORRECTION — IT IS TWO CONTROLS, NOT ONE, AND §1-§4 BELOW CONFLATED THEM
> *"For me I think it's really 2 controls. One as the slicer, one as the envelope, close together and
> effect each other with visual feedback to both. But right now there is conflict. Trying to move the
> enevelop when a slicer is close, and vice versa. But sibling very close to each other."*
> — Battlewrath, 2026-08-24

**He is right, and the source says so plainly:**

    handle()            Map.SetEnvelope(toSec(x, span), hi)      :494   the HANDLES set the ENVELOPE
    bar OnMouseDown     Map.SetWindow(clickSec - width/2, width) :443   the BAR sets the WINDOW

⟶ **The two handles and the bar do not act on the same quantity.** I wrote the sections below as one
range with two edges and a body; it is **TWO RANGES SHARING ONE 12px STRIP**:

    ENVELOPE   the OUTER bound - where the window MAY go        set by the two handles
    WINDOW     the INNER band  - what is on screen              set by clicking the bar

★★★ **So the conflict is STRUCTURAL, not a precedence bug.** Two controls occupy one 12px-tall
surface, and every fix in `:450-466` — raise the frame level, widen the grab area, enforce minimum
separation — is a Z-ORDER answer to what is really a **crowding** problem. Z-order can only decide
who wins; it cannot stop the two from wanting the same pixel.

### ★★ HIS FIX, and it moves the problem out of Z and into Y
> *"Or as it is. But the thumbs extends the bar with a node / handle above the slicer segment. So the
> bar it's self is mostly moving the envelope."*

    THE BAR       its own surface, uncontested          -> the window / the envelope body
    THE THUMBS    raised on a stem ABOVE the strip      -> the bounds, on their own y

⟶ **No overlap, so no precedence rule is needed at all.** The 16px invisible grab, the +5 frame
level and the minimum separation stop being fixes and become belt-and-braces. ★ And it is a known
form rather than an invention: a DAW loop region and a video-editor trim both put the region on the
track and the trim handles as tabs off it.

⚠ **ONE THING TO DECIDE, and it is his:** which quantity the BAR's surface belongs to. His sentence
says *"the bar it's self is mostly moving the envelope"*; the code today has the bar moving the
WINDOW. **They are different products** — one gives you a big target for framing the view, the other
for framing what is reachable. The raised thumbs work either way; the bar cannot be both.

⟶ Everything from §1 down still holds as ANALYSIS of the parts. Read *"the body"* there as *"the
bar's own surface"*, and read the three-target claim as being about ONE of the two controls, not both.

## 0b · ★★★ NAMING THEM — and there are THREE QUANTITIES, not two
> *"There are two things there. So we're probably best of naming them properly. One set of controls,
> control the total time envelope. Another, is the 'How many nodes on display' in this time range. So
> 20 secs shows all nodes that was present at that span. Widen it shows more nodes that span a
> greater time."* — Battlewrath, 2026-08-24

### ★ HE IS RIGHT ABOUT THE SECOND ONE, AND THE SOURCE PROVES IT
`map.lua:792-795`, the visibility predicate every point passes through:

    if peeking or not winPos or not t0 then return true end
    ...
    return rel >= winPos and rel <= winPos + winWidth

⟶ **A node DRAWS only if its time falls inside the window.** It is a FILTER over which nodes appear,
not a viewport over a picture — *"widen it shows more nodes"* is literally what the code does.

### ★★ AND THE FILE ALREADY NAMES THE LADDER — `map.lua:801-804`, §48
    1  tick shows      which KINDS are in play        `hidden`
    2  time filter     which SPAN of those            the window
    3  time controls   WHERE within it you are        winPos

⟶ **His two things are rung 2 and the bound above it.** But laying his sentence on the ladder shows a
third quantity the CONTROLS do not separate:

    ENVELOPE   lo..hi     what part of the run is in play at all      the two handles
    BREADTH    width      HOW MANY NODES show - his rung 2            `-` / `+` halve and double
    AT         position   WHERE in the envelope that breadth sits     the bar click, and `<` / `>`

### ⚠⚠ AND `Map.Window(pos, width)` FUSES THE LAST TWO INTO ONE CALL
`map.lua:670` `function Map.Window() return winPos, winWidth end` · `:765 SetWindow(pos, width)`.
**Breadth and position travel together in every call.** ⟶ That is why the bar and the handles
compete: a bar click sets BOTH (it re-centres while preserving width), so the one surface is the only
way to say either. **Separate them and each gets its own target, which is §0's raised-thumb fix
arriving from the other direction.**

### ⚠⚠ RETRACTED — TIME IS THE ANCHOR, and the readout was already right
> *"How many isn't useful. Time is the anchor. No one selects for node count but they do time
> envelope. So play back is a function of time elapse."* — Battlewrath, 2026-08-24

**This seat proposed a `showing 14 of 60 nodes` readout. Withdrawn.** He described what the control
DOES to nodes; I read that as what a user SELECTS FOR, and turned an effect into a purpose. ⟶ Nobody
asks for fourteen nodes. They ask for *0:40 to 1:20*, and the node count is what falls out.

★★★ **The whole control is TIME-DOMAIN and must stay so.** Playback advances time; breadth is a time
width; the envelope is time bounds. **A count is a different quantity, and putting it in the readout
would be a category error** — a number that changes as you drag and that no decision is made on.

⟶ `editor.lua:177`'s `window 0:40 of 0:00 - 0:40` **was correct**, and the *"measures the wrong
thing"* claim above it is wrong. There is no missing feedback here: you set 0:40 because you wanted
0:40, and the readout says 0:40.

⚠ **The names are HIS to set** — this seat does not author a vocabulary (`UI_SEAT.md`). Offered with
their reasons, and one constraint from the source:

    ENVELOPE   ★ keep. His word, the code's word, and it already means exactly this.
    BREADTH    a candidate for rung 2. ⚠ `SPAN` is TAKEN - `Map.Span()` is the RUN's full duration
               and is the conversion basis for every x->seconds; reusing it would collide.
    AT         a candidate for rung 3, or `POSITION`.

## 0c · ★★★ THE ARRANGEMENT, HIS — one bar, two sides, and it FORCES the API split
> *"I think the one bar. And then above is for handles to decide the play back window. Then handles
> below for the actual time slice. And then clicking the middle of that item is the drag position.
> Below it sit controls to skip back and forth by a percent of the breadth. And manual controls to
> step the beadth larger. That's how I undertand the play back today."*
> — Battlewrath, 2026-08-24

        ●━━━━━━━━━━━━━━━━━━━━━━━━━━━━━●        handles ABOVE   the playback window (envelope)
    ════════════▓▓▓▓▓▓▓▓▓▓▓════════════        ONE BAR - and the bright band is the SLICE
                ●━━━━━━━━━●                    handles BELOW   the time slice (breadth)
                  ↕ drag                       the slice's MIDDLE  -> position
    [ < ]  [ > ]        skip by a PERCENT of the breadth
    [ - ]  [ + ]        step the breadth

### ★★ EACH OF THE THREE QUANTITIES GETS ITS OWN TARGET — which is the fix
`§0b` found that `Map.Window(pos, width)` **fuses breadth and position into one call**, and that this
is why the bar and the handles compete: one surface was the only way to say either.

    ENVELOPE   the handles ABOVE the bar
    BREADTH    the handles BELOW the bar, and `-` / `+`
    POSITION   the SLICE BODY itself, and `<` / `>`

⟶ **No two targets share a pixel, so no precedence rule is needed** — and the arrangement cannot be
built without splitting `SetWindow(pos, width)` into two calls. **The layout forces the API to say
what it means.** ★ That is the strongest kind of design change: the geometry makes the wrong shape
impossible rather than discouraged.

### ★ AND HIS READING OF PLAYBACK IS EXACT — `map.lua:660-666` confirms it
    -- SKIP IS DERIVED: window / 10, floored at one second.
    -- TEN PRESSES ALWAYS CROSSES WHATEVER YOU FRAMED - a pull or a three-minute corpse run -
    -- and at the fine end one step is one sample. A curve was considered and dropped: it trades
    -- a learnable invariant for tuning that [-] time [+] already does explicitly.

    function Map.SkipStep() return math.max(MIN_WIDTH, math.floor((winWidth or MIN_WIDTH) / 10)) end

⟶ *"skip back and forth by a percent of the breadth"* **is what is built** — 10%, and the invariant
is *ten presses crosses whatever you framed*. ⚠ **Do not replace it with a curve**; the file already
records that decision and its reason, and it is the same taste as `:761`'s *"no speed control"*.

### ⟶ WHAT THIS LEAVES
Everything in `§3` still may not be broken. `§4`'s proposal reduces to the parts his arrangement does
not already settle:

    BODY DRAG   the slice's middle becomes press-to-grab, the handles' own idiom
    CLICK       jump-to-here survives as a press that did NOT move (and cancel returns)
    KEYBOARD    still absent, still an APG requirement, and now FOUR targets need it
    ⚠ MIN WIDTH the two handle pairs can approach each other; the slice cannot be wider than the
                envelope. That constraint is currently implicit in `ClampWindow` and would become
                visible - two pairs that can collide across the bar rather than along it.

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
