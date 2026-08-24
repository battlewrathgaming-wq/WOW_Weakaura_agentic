# SPEC — the three AceConfig borrows into `panespec`

_UI specialist, 2026-08-24. **An INPUT CONTRACT, not a build.** This seat emits the declaration
shape; the Addon creator builds it (`UI_SEAT.md`: *"You emit the INPUT CONTRACT; the bench
HANDLES"*). Ruled by `ARCHITECT_LOG.md` **AL-46**, which rejected AceConfig **for panes** and
BORROWED three ideas into `panespec`, cited. Nothing here adopts a library._

> **AL-46 / `ace3_gap_2026-08-24.md` §1** — *"BORROW, as ideas into panespec, cited: (1) the width
> unit (170 px base, half/double/relative) — resolution-independence with zero screen reads; (2) the
> validate → error, confirm → popup machinery shape (UL-7's popup already matches); (3) NotifyChange
> — one registry notification, open surfaces re-fetch and redraw."*

★★★ **THE CONSTRAINT THAT SHAPES ALL THREE.** `ui_overhaul_scope.md` keeps `hidden` as a STATIC
subject set — `only("beacon","child","note")` — rather than WA's `hidden = function(...)`, and
defends it: **ours is OFFLINE-CHECKABLE**, and the smoke enumerates all four subject states
including *nothing selected*, which is the state the orphaned heading survived into. ⟶ **Every borrow
below is judged first on whether it keeps that**, and where it cannot, it says so and bounds the
damage — the shape AL-45 already used for the measured-height cell.

---

## 1 · THE WIDTH UNIT — and it closes a gap the scope doc already named

### What is
`panespec.lua:184` — `Spec.W = { edit = 100, check = 26, button = 80, dropdown = 100 }`, absolute
pixels. And every cell carries a **hand-typed x**: `{ key, x, kind, w? }` (`:61`), resolved at
`:235-239`.

`ui_overhaul_scope.md` names both as places WeakAuras is *plainly ahead*:

> *"no typed coordinates — ours still carries one per cell… **Our engine already computes y. The x
> is the half we did not finish.**"* and *"width is a UNIT, not pixels — we carry a bag… they carry
> `width_multiplier = 170` and three multipliers off it, and **the pane derives from the unit**.
> That is the thing that would have prevented 'the pane got wider and the content did not'."*

### What Ace does
`AceConfigDialog-3.0.lua:83` `local width_multiplier = 170`; `:1219-1225` branches `"double"` ×2,
`"half"` ÷2, `"full"` → the container. ⚠ **Our shipped minor 49 branches on those STRINGS ONLY** —
a numeric width falls through to the bare multiplier, so WA's `1.3` would render as 170, not 221
(`sheet_decl.lua` declares numeric rows on purpose to demonstrate that in-client).

### The declaration this seat proposes
    Spec.UNIT   = 204            -- the content column, ONE number, already Spec.width
    Spec.WIDTH  = {              -- multiples of UNIT, never pixels
      full = 1.0, half = 0.5, third = 1/3, quarter = 0.25, double = 2.0,
    }
    a cell becomes   { key, kind, w = "half" | 0.25 | nil }      -- ⚠ NO x
    absent w         the kind's natural width from `Spec.W`, itself expressed in units

★ **`x` is DERIVED by flow**: cells fill the row left to right; a row wraps when the next cell would
exceed 1.0. That is `AceGUI-3.0.lua:687,:726`'s rule (`usedwidth > width`), which sheet six measured
on tab strips and found sound.

**OFFLINE-CHECKABLE: YES, and MORE so.** A multiple is data; a typed x is data that can silently
disagree with the width beside it. ⟶ A new check becomes possible: **a row whose units sum above 1.0
is a declaration error, catchable with no client.**

⚠ **NOT SPECIFIED HERE:** the migration. Every existing cell has a typed x and converting them is
the bench's, not this seat's. ★ And the two forms can coexist — a cell with an `x` keeps it, a cell
without derives — so this does not need a big-bang.

---

## 2 · VALIDATE → ERROR, CONFIRM → POPUP

### What is
Nothing. `panespec` declares geometry and `rowHidden`; a bad value reaches the record and the record
finds out. `UL-6` established the commit grammar (`OnTextChanged` tells the USER, `OnEnterPressed`
tells the RECORD) and `UL-7` established that WA's second-act accept is `StaticPopupDialogs` — **his
steer, and the reason we did not invent one**: *"I'd look at what WA does for second act accept.
Rather than going on my invention."*

### What Ace does
An option carries `validate = function(info, value) -> true | "message"` and
`confirm = true | function -> "question"`. AceConfigDialog turns the first into a refusal with a
message and the second into a popup before the set.

### The declaration this seat proposes
    a cell may carry   validate = <name>      -- a KEY into a table the pane owns, never a closure
                       confirm  = <name>      -- likewise

★★★ **NAMES, NOT CLOSURES, AND THAT IS THE WHOLE DESIGN DECISION.** A closure in the declaration
makes `panespec` un-analysable: the smoke could no longer enumerate what a pane does without running
it, which is precisely what `hidden`-as-a-static-set exists to protect. A NAME is data — the checker
can assert every named validator EXISTS, and the `behaviour` kind (sheet four) can drive each one in
the client and report **claim vs observed vs agrees**, which is how the input-commit grammar is
already proven.

⚠ It is also `travelling-data-NAMES-never-supplies` applied one layer in: **the declaration NAMES a
capability from a closed list the pane publishes; it never supplies what it DOES.**

**OFFLINE-CHECKABLE: the WIRING yes, the BEHAVIOUR no.** The checker proves every name resolves and
every validator is reachable; whether a validator is *correct* is a client question and belongs to
sheet four. ⟶ Bounded exactly as AL-45 bounded the measured cell: the guarantee narrows only for
rows that carry one.

⚠ **NOT SPECIFIED HERE:** the popup's wording, and whether `confirm` fires before or after the
commit. `UL-7` says WA uses `StaticPopupDialogs`; the ORDER is a product ruling and is not this
seat's.

---

## 3 · NOTIFYCHANGE — one notification, open surfaces re-fetch

⚠⚠ **TWO THINGS ARE CALLED `NOTIFICATION` AND THEY ARE NOT THE SAME.** Battlewrath read this
section and answered about the OTHER one, which is a fair reading of the word:

    THIS SECTION      MACHINE -> MACHINE.  A surface tells the others to re-fetch. Invisible.
    §4 (below)        MACHINE -> PERSON.   Did my edit land? Visible, and his ruling.

⟶ Named apart here so the spec cannot be read either way again.

### What is
Nothing general. Panes redraw when their own code decides to. ★ **And his surface structure makes
this load-bearing rather than tidy** (`AI-24`): three tabs on the unified pane — Curation, Promotion,
Object — plus a remote with two. **Editing an object changes what Curation should show.** With one
pane that was a private problem; with three surfaces it is a contract.

### What Ace does
`AceConfigRegistry:NotifyChange(appName)` — one call, and every open dialog for that app re-fetches
its values and redraws. The publisher does not know who is listening.

### The declaration this seat proposes
    Spec.SUBJECTS          already exists as the enumeration (AL-13 cites it)
    Pane.OnRecordChanged(subject)     one entry point, called by whoever WROTE
    a surface REGISTERS its interest in a subject and is redrawn; it is never told BY WHOM

★ **The direction is the point.** A writer that names its readers is the *"two owners of one widget"*
anti-pattern `prior_art_worldmap_2026-08-21.md` already flagged on the client's own `WorldMapFrame`.
One notification, many listeners, no back-references.

**OFFLINE-CHECKABLE: YES.** Registration is a static list, so the smoke can assert that every subject
a pane READS is one it registered for — a real check that does not exist today.

⚠ **NOT SPECIFIED HERE:** throttling. A notification per keystroke is `OnTextChanged`'s problem
again, and `UL-6` already ruled the commit boundary — **`OnEnterPressed` tells the RECORD**, so the
notification rides the commit, not the keystroke. If that proves too coarse it is a measurement, not
a redesign.

---

## 4 · COMMIT FEEDBACK — the person's notification, and it is mostly already built

### His ruling, 2026-08-24
> *"I think notification should be non-alarming. Not dramatic. Maybe a green indicator next to the
> input field. Or the input box it's self with a behaviour. Green highlight around the box? A tick
> within the box?"*

★ And it answers a question he asked on 2026-08-23 that was never closed —
*"Some feedback on the text input field. (Highlight react?)"*

### ★★★ WHAT ALREADY HAPPENS, and his instinct matches it
`AceGUIWidget-EditBox.lua:66-73`:

    local cancel = self:Fire("OnEnterPressed", value)
    if not cancel then
        PlaySound("igMainMenuOptionCheckBoxOn")     -- a SOUND
        HideButton(self)                            -- the accept button DISAPPEARS
    end

⟶ **The grammar exists and it is already non-alarming**: the accept button APPEARING is *pending*,
and its DISAPPEARING plus a soft sound is *committed*. Nothing flashes, nothing is red, nothing
moves the layout.
★★ **And `cancel` is the hook §2 needs**: a handler returning truthy leaves the button up and plays
no sound, so the widget ALREADY distinguishes accepted from refused. A `validate` that returns a
message is exactly a handler that cancels. **The two borrows meet at this line.**
⚠ WA adds nothing here — no tint, no tick. Its only `SetTextColor` cases are DISABLED states
(`AceGUIWidget-WeakAurasExpand.lua:94`, `WeakAurasAnchorButtons.lua:52`). So a green confirm is OURS
if we want it, not a field convention we are missing.

### ⚠ THE COLLISION, which is the one thing worth deciding
The accept button sits at `button:SetPoint("RIGHT", -2, 0)`, **40 × 20**
(`AceGUIWidget-EditBox.lua:205-208`) — the right end of the box. **That is the same place a tick
inside the box would go.** ⟶ They cannot both be there, and that is a feature rather than a problem:

    PENDING     the accept button occupies the right end
    COMMITTED   the button goes, and a tick may take the space it left
    REFUSED     the button STAYS (`cancel`), and the message goes where a tick would not fit

★ One slot, three states, no layout movement — which is what *"non-alarming, not dramatic"* asks
for. **A green outline around the whole box is the alternative and it is louder**: it redraws the
control's own edge, and an edge that changes colour reads as a state of the FIELD rather than an
event that just happened.

### ★★★ THE BLINKING CURSOR — his words, and it is an ASYMMETRY INSIDE AceGUI
> *"More importantly is the grammar that we show the input box did something. Instead of 'Leaving a
> blinking cursor'."* — Battlewrath, 2026-08-24

`AceGUIWidget-EditBox.lua`, the two commit paths:

    :108-109   the BUTTON's click    editbox:ClearFocus()   THEN   EditBox_OnEnterPressed(editbox)
    :66-73     OnEnterPressed        PlaySound + HideButton  —  and NO ClearFocus
    :63        OnEscapePressed       AceGUI:ClearFocus()

⟶ **The same commit ends in two different states depending on how you did it.** Click the accept
button and the field finishes: focus gone, cursor stopped, button gone. Press **Enter** and the value
commits while **the cursor keeps blinking** — the box still looks like it is being edited, and the
only thing that changed is a button vanishing at the far right.

★★ **That is the whole defect, and it is not a missing feature — it is an inconsistency.** The mouse
path already has the grammar; the keyboard path drops one line of it.

### THE GRAMMAR, stated as four states
    UNTOUCHED   no button, no focus                     nothing to say
    PENDING     button SHOWN (`ShowButton`, :102, on userInput only)   you have uncommitted input
    COMMITTED   sound · button GONE · ★ FOCUS CLEARED   the cursor STOPS - the field is done
    REFUSED     button STAYS (`cancel` is truthy)       and it is the only state that persists

⚠ **The fix is in OUR handler, not the library.** Our `OnEnterPressed` callback can clear the focus
itself; nothing needs forking, and `travelling-data`-style, we are not changing what Ace supplies.

### THE DECLARATION THIS SEAT PROPOSES
    a cell may carry   feedback = "slot" | "none"     -- default "slot"
    the pane owns      one tick texture and one fade, in the registry (AP-13), never per pane

### ☐ LOGGED AS A CAPABILITY, NOT CHASED — resolution feedback
WA answers *"is this value real"* by showing the thing: `BuffTrigger2.lua:173,208` puts
`image = function() ... end` on the option, so the spell's icon appears beside the field once the id
resolves. **Battlewrath, ruling the scope:** *"We don't handle spells yet. We can log it as a
capability."*
⟶ Filed, not built. ⚠ And note the shape when it comes: WA's is a CLOSURE on the option, which §2
refuses for validators for the same reason — offline-checkability. **A resolver would have to be a
NAME too.**
★ And we are not starting from nothing: the object pane's TELLS — `object.boss.tell` (*no name, it
will not listen*), `object.match`, `object.ordinal.match`, `object.stagematch` — are resolution
feedback already, in text rather than art (`concepts/row.md`).

### ★★ AND THE TIER THAT IS NOT AVAILABLE TO US AT ALL, in his words
> *"some of the inputs have immediate effect. Like what shows on a aura. Our proof is a little
> delayed. So response the input landed shows the system is working. Not that the authored construct
> works. But that comes later."*

    RECEIPT      the system TOOK it            instant · always available · claims nothing
    RESOLUTION   the value resolved to a known thing   where a lookup exists (tells; spells later)
    EFFECT       the authored construct WORKS   ⚠ WA gets this free; OURS IS DELAYED

⟶ **WA can use the effect as the receipt because the aura changes under your hands. We cannot** — a
route is proved by running it. ★★ **So the ladder terminates on a different SURFACE: the remote's
Test drive tab** (`AI-24`), which is why that tab exists.
⚠⚠ **AND IT BOUNDS WHAT THE TICK MAY CLAIM.** A commit indicator means **STORED**, never **CORRECT**.
A tick that appears on a route which later fails is worse than no tick, because it spent trust it did
not have.

⚠ **NOT SPECIFIED HERE:** the tick's art, its colour value, and how long it lingers. Those are
TOKENS — `ui_overhaul_scope`'s registry is where a colour with a why belongs, and this seat does not
author a value cold (`UI_SEAT.md`). ⟶ **The mechanism is specified; the look is his.**

## What this spec does NOT claim
- That any of the three is worth its cost. Each is a shape with a stated benefit and a stated limit;
  the sequencing is the Addon creator's and the ruling is already AL-46's.
- That the width unit fixes the object pane. `UL-14` measured that pane at **744 open in a 600 frame**
  — that is answered by collapse and tabs, not by width.
- Any migration order. All three coexist with what exists; none requires a rewrite to begin.

## Cited
`ARCHITECT_LOG.md` AL-46 · `audit/ace3_gap_2026-08-24.md` §1 · `ui_overhaul_scope.md` (the mechanism
assessment; `hidden` as a static set) · `panespec.lua:48,61,63,76,184,207,227-250` ·
`AceConfigDialog-3.0.lua:83,1219-1225` · `AceGUI-3.0.lua:687,726` · `UI_LOG.md` UL-6, UL-7, UL-13,
UL-14 · `ARCHITECT_INBOX.md` AI-24 (the surface structure).
