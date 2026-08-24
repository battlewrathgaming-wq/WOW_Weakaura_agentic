# UI_LOG — the UI specialist's outcomes and reasoning

_Opened 2026-08-23 when Battlewrath stood the seat up ("Yes. Proceed."). Same form as `ARCHITECT_LOG.md`:
one entry per act or decision — the question · the outcome · the reasoning · what it cites · where it LANDED ·
whose word. The log never carries a ruling's body. Read newest first. **The seat's guide is `UI_SEAT.md`;
its #0 is `ARCHITECT_PROPOSALS.md` AP-13 until the registry exists and becomes #0 itself.**_

    ENTRY FORM    UL-N · date · from (conversation | ARCHITECT_INBOX AI-N | Reconcile_inbox RI-N) ·
                  QUESTION · OUTCOME · REASONING · CITES · LANDED IN · WORD

---

## UL-15 · 2026-08-24 · the input grammar, settled from source — and every claim of mine he corrected
**QUESTION** — the three AL-46 borrows into `panespec`, then his steer on feedback: *"notification
should be non-alarming"* → *"it was also a metaphore"* → *"reserve discrete label space"* → *"register
the whole unit"* → *"their already using the keyboard, no?"* → *"drop downs need it less"*.

### ★★★ THE LAW, in his words
> *"A terminal input that gives no response when a command is sent leaves you wondering."*

**AN ACTION WITH NO ANSWER IS INDISTINGUISHABLE FROM ONE THAT FAILED.** And the metaphor carries its
own shape — ECHO (the value is still there) · NEW PROMPT (you may go on) · ERROR (and why).

### THE DEFECT WAS AN ASYMMETRY INSIDE ACEGUI, not a missing feature
    :108-109  the BUTTON's click   editbox:ClearFocus()  THEN  EditBox_OnEnterPressed(editbox)
    :66-73    OnEnterPressed       PlaySound + HideButton  -  and NO ClearFocus
⟶ Same commit, two end states. The mouse path finishes the field; **Enter commits and leaves the
cursor blinking**. That is the NEW PROMPT missing — echo and error were both already there.

### ★★ THE COMMIT BOUNDARY IS A PROPERTY OF THE KIND
    free-hand text   Enter                                       button optional
    multi-line       the ACCEPT button (Enter makes a newline)    button REQUIRED
    dropdown         THE SELECTION                                -
    checkbox         the toggle                                   -
    slider           OnMouseUp - the release                      -
★★★ **The slider settles it and names an old complaint's cause.** `AceGUIWidget-Slider.lua` fires
BOTH — `:60-66` `OnValueChanged` continuously while dragging, `:74-76` `OnMouseUp` on release, and
`:96-109` its editbox's Enter raises `OnMouseUp` too. **`OnValueChanged` tells the USER, `OnMouseUp`
tells the RECORD** — the same grammar as `OnTextChanged`/`OnEnterPressed`. ⟶ *"Weird stalling if it
updates per entry"* is **a consumer bound to the wrong callback**, writing on every pixel of a drag.
**A callback choice, not a throttle** — and that is a far smaller thing than the complaint carried.

### ★ THE RESPONSE AREA — reserved, hidden, and only where the echo is ambiguous
His: *"reserve discrete label space for 'Saved (Green tick)'… Hidden by default."* **Budgeted always,
drawn sometimes, so nothing moves in any state** — the opposite of §571's tell-collapse, which
resized the pane under the cursor. It also dissolves the tick-versus-button collision: the button
keeps the inside-right slot, the response lives outside it.

    free-hand · multi-line   display shows what you TYPED - ambiguous   -> response NEEDED
    slider                   Stored -> Change -> Settled                -> beside the value box
    dropdown · checkbox      the RESOLVED value / the state itself      -> NONE (his ruling)

★★ **A dropdown cannot be ambiguous because you cannot type into it.** Its echo and its value are the
same object. ⟶ **The response area resolves an ambiguity, so it belongs only where the ambiguity
is** — which is what stops it becoming decoration.

⚠ **Measured tension, his to rule:** *"trails the top surface"* puts the label in the row-to-row gap,
which is **8**, against a size-10 line at **9.92** (UL-10). It would overlap the row above — F·29's
fault in a new place. The variant the numbers allow is the row's own band, in reserved WIDTH.

### ⚠⚠ FOUR OF MY CLAIMS DIED THIS SESSION, ALL TO SOURCE OR TO HIM
- *"WA declares `childGroups = 'tab'`"* — **zero** occurrences in all of WeakAurasOptions; WA creates
  the TabGroup itself.
- *"The tick and the accept button contend for one slot"* — true, and **his reserved area dissolves
  it** rather than choosing between them.
- *"Removing the button makes commit mouse-impossible"* — **withdrawn**: to have something pending in
  a free-hand field you TYPED it, so the path I was protecting is one nobody takes.
- *"Notification"* — I meant machine→machine; he answered machine→person. **A fair reading of the
  word**, so the spec now names them apart.
★ And his button hypothesis was the one prediction that survived contact with the source intact.

**LANDED IN** — `planning/ui_panespec_borrows_spec.md` §1–§5 · `concepts/input-commit.md` ·
`ARCHITECT_INBOX.md` AI-26 (the registry shape, which is AP-13's to extend).

**WORD** — Battlewrath, 2026-08-24, throughout.

---

## UL-14 · 2026-08-24 · collapse buys 84%, and the object pane does not fit open at any width
**QUESTION** — his: *"Last proof for the sheet, in the same WA type. Is a collapsing draw of data /
fields."* Then, on the run: *"That works great. WA uses icon widgets like arrows too. But the premise
is proven."*

### ★★★ THE NUMBERS, and they settle F·30
The object pane's OWN five zones with their real control counts (24 fields), measured at 3620×2036
@ 0.86:

    state        240    280    what it is
    open         744    744    every section expanded - the ceiling
    shut         120    120    every section collapsed to its header - the FLOOR
    one-open     328    328    first open, rest shut - what a person actually sees

    at 240:  open 744 -> shut 120   saves 624px (84%)
    a shut section costs 24px, uniformly. Five headers = 120.

⟶ **THE PANE DOES NOT FIT OPEN.** `object.lua:582` holds it at a fixed **240 × 600**, and the same
content fully expanded needs **744**. That is F·30 and `ui_overhaul_scope`'s *"575px in a pane held
at 330"* arriving from a third direction, and this time as a number the design can act on.
⟶ **ONE-OPEN FITS WITH 272px TO SPARE.** And it composes with UL-13: a tab strip is 37, so
strip + one-open = **365 of 600**. There is room for both devices at once, which no argument had
established.

⚠ Width-invariant across 240 and 280, as expected: these fields are full-width and single-line, so
nothing here wraps. That is a property of the specimen, not a general law.

### ★★ THE MECHANISM IS WA'S, AND THE DIFFERENCE IS RECORDED RATHER THAN GLOSSED
`WeakAurasOptions/CommonOptions.lua`: the header is `type = "execute"` (**a button**, `:139`);
`IsCollapsed`/`SetCollapsed` flip a **stored flag** (`:113`, `:121`); every member of the section
gets `hidden = collapsedFunc` (`:293`) — or a **wrapper**, collapsed OR the option's own hidden
(`:285-291`). Nothing hides children; the option table declares them hidden and the dialog re-feeds.
★ That wrapper is the half that matters to us: **collapse must COMPOSE with existing visibility, not
replace it** — exactly what `panespec`'s `rowHidden` static subject set would face.
⚠ And we cannot copy it: WA drives AceConfigDialog from an option table; `panespec` is
zones→rows→cells and its `hidden` is kept STATIC because that is what makes it offline-checkable.
The sheet measures the AceGUI form and names WA's as the cited original.

### ☐ OWED, from his note — `WA uses icon widgets like arrows too`
The board draws `-` / `+` as text. WA uses a texture: `AceGUIWidget-WeakAurasExpandSmall.lua:63-72`
swaps `Media\Textures\gear` / `geardown` on the collapsed flag. ⟶ **A chevron is a token, not a
mechanism** — it belongs to the registry AP-13 is for, and it changes nothing measured above. Filed
as a refinement, not built, because he closed the proof in the same breath: *"But the premise is
proven."*

### THE SHEET SERIES, as it now stands
    one    text extent          per-glyph advances, fitted, held out
    two    control widths       what an AceGUI widget BECOMES when asked
    three  art vs rect          how far the picture runs past the box
    four   input-commit         does the widget OBEY the grammar
    five   wrap                 where the client BREAKS A LINE
    six    tabs                 does a strip wrap, and what does it cost
    seven  collapse             what a section WEIGHS open and shut
★ Each one built on the one before, which was his rule from the start: *"A sheet at a time. Each
building on the display capability of the next."*

**LANDED IN** — `sheet_decl.lua` v7 · `task_sheet.lua` (measurement, clickable board, focus guard) ·
`check_sheet.py --collapse`.

**WORD** — Battlewrath, 2026-08-24.

---

## UL-13 · 2026-08-24 · tabs WORK, sub-tabs work — and two strips cost 43% of a 240 pane
**QUESTION** — his: *"Prove we can make tabs that work. And then tabs and sub-tabs. (One to move the
page. One to move sub-page content.)"* Then, on the first run: *"No tabs seen. Maybe check out how WA
implements it?"* Then: *"No errors this time. Escapement on the box works. Tabs load first time."*

### ★★★ THE PRODUCT ANSWER — his three tabs FIT
Measured at 3620×2036 @ 0.86, `check_sheet.py --tabs`. Rows needed, by asked width:

    set            tabs    200   240   280   400   600
    unified           3     2!     1     1     1     1     Curation · Promotion · Object
    remote            2      1     1     1     1     1     Run · Test drive
    beacon            3     2!     1     1     1     1     Face · Stage 1 · Stage 2
    beacon-kids       3     2!    2!     1     1     1     Face · Children · What they are doing
    child-first       3     2!     1     1     1     1     Face · Stage 1 · Action (N)
    child             2      1     1     1     1     1     Face · Action (N)

⟶ **`Curation · Promotion · Object` is ONE ROW at 240.** So is the remote's pair, and three of the
four node strips. ⚠ **`beacon-kids` is the exception and it needs TWO rows at 240** — *"What they are
doing"* is the label that does not fit. `ui_overhaul_scope.md` wrote that strip; nothing until now
could say it costs a second row on the pane it will live on.
⚠ And the margin is thin: at **200** every three-tab strip wraps. 240 is not comfortable, it is
sufficient.

### THE PRICE OF A STRIP, measured
    1 row   37px      2 rows   57px      3 rows   77px       (a row is 20)

### ★★ SUB-TABS WORK, AND THE COST COMPOUNDS
A TabGroup inside a TabGroup's content, `Object` (outer) → `Face · Stage 1 · Stage 2` (inner), against
a 220px probe:

    width   outer rows   inner rows   inner drew   both strips   content left
      200        2            2          yes           114            80
      240        1            2          yes            94           100
      280        1            1          yes            74           120

⟶ **The inner strip renders at every width — his second half is possible.** But at 240 the inner needs
**two rows even though the outer needs one**, because the inner sits inside the outer's CONTENT, which
is narrower than the pane. ★ Nesting does not cost one strip, it costs a strip plus the width the
outer took away.
⟶ **At 240 the two strips are 94px of a 220px pane — 43% before a single control.** That is the number
the design has to answer, and it is now a measurement rather than a worry.

### ⚠⚠ ONE ANOMALY, REPORTED NOT EXPLAINED
`three-wide` (three ten-M tabs) needs 3 rows at 200/240/280 and its strip cost comes back **691px** —
against 77 for the other 3-row strip (`eight` at 200). The jump is not 20 per row and nothing here
accounts for it. **Candidate: a 3-row strip breaks the container's content anchoring in this AceGUI.**
⟶ If that is real, it is a reason never to permit a third row rather than a curiosity — filed as a
thing to reproduce, not a conclusion.

### ★ WHAT MADE THE FIRST RUN SHOW NOTHING — two faults, both instructive
- **The PATH, not the call.** I did `grp.frame:SetParent(host)` + `SetPoint`; WA does
  `container:SetLayout("Fill")` → `container:AddChild(tabsWidget)` → `SetTitle("")`
  (`WeakAurasOptions/OptionsFrames/OptionsFrame.lua:1197-1231`). A container positions its children,
  and a widget whose frame was parented by hand is not a child of anything.
- **RELEASED WHAT IT MEASURED.** 45 strips built, measured, released — correct run, empty pane. ⚠ That
  is verbatim the fault `task_sheet.lua`'s own header already records about sheets two and three, in a
  comment this seat wrote. ⟶ A persistent, CLICKABLE tab board now stays on the sheet, because *does
  the page move* is not a question any measurement asks.

### AND TWO THINGS THE RUN SURFACED THAT WERE NOT ABOUT TABS
- **★★★ THE FORK SHIPS ACE ITSELF.** The error path read
  `Interface\LibraryXML\AceGUI-3.0\AceGUI-3.0-1.#INF.lua:237` — not an addon's copy. That is why every
  Ace minor reads `1.#INF` and why no addon copy can win LibStub. §580 said *"first to load wins"*; the
  truer statement is **the client loads its own first, at infinity**. ⟶ The r33/r41 diff was between two
  copies NEITHER OF WHICH RUNS. ☐ `LibraryXML` is packed, not on disk; reading it is owed.
- **The focus trap.** His: *"One of the text boxes is pervasive, controlling / locking expected input."*
  `InputBoxTemplate` autofocuses, so a swatch built to be LOOKED at had been taking every keystroke in
  the game since the board landed. Now `SetAutoFocus(false)` + `ClearFocus()` + `OnEscapePressed`.

### ★★★ HIS BOUND, SAME DAY — AND IT NAMES A DISTINCTION THIS ENTRY BLURRED
> *"As it stands there is no intent of a third nested row. There might be a use for action tabs to
> spread from row 1 to row 2, but the same group of containers."*

⟶ **ROWS ARE NOT LEVELS**, and the two were running together above:

    ROWS    one strip WRAPPING. Still ONE group, one selection, one page.  2 is IN SCOPE.
    LEVELS  a TabGroup inside a TabGroup's content. A SECOND group, its own selection.

★ So the `beacon-kids` two-row result at 240 is **allowed**, not a defect — and the nest's *inner
rows 2* is a strip wrapping inside one group, not a third level. **A third LEVEL was never
proposed.**
⟶ And the **691px anomaly is BOUNDED rather than solved**: it is a THREE-ROW strip, and three rows
are now out of scope. `check_sheet --tabs` applies the bound where the numbers are — any strip at
3+ rows is called OUT OF SCOPE, with the forcing calibration sets named as the ones that are
supposed to land there. **A specimen set landing there would be a design fact, not a tolerance to
widen.**

**LANDED IN** — `sheet_decl.lua` v6 (kind `tab`, 9 sets × 5 widths) · `task_sheet.lua` (measurement,
tab board, focus guard) · `check_sheet.py --tabs`.

**WORD** — Battlewrath, 2026-08-24: the commission, the WA steer, and *"No errors this time.
Escapement on the box works. Tabs load first time."*

---

## UL-12 · 2026-08-24 · the surface structure, from his word — and his own sketch had it six days ago
**HIS WORD, verbatim** — *"Remote is the Run widget. That stays on it's own."* · *"Run and Test drive will
live tabbed on the remote. (Capture and test route)"* · *"Map as it's own pane."* · *"Bolton unified pane,
Curation, Promotion, Object."* · *"Re-read the thread."*

### THE STRUCTURE
    MAP                  its own pane. Map controls LOCKED to it. Never docks.
    UNIFIED BOLT-ON      THREE tabs - Curation · Promotion · Object
    REMOTE (the Run       its own widget, TWO tabs - Run (capture) · Test drive (test route)
      widget)

### ★★★ AND RE-READING THE THREAD IS THE POINT — IT WAS ALL IN THE 2026-08-18 SKETCH
`audit/ui_drawio_model_decoded.xml`, read off the geometry rather than the prose:

    Unified input pane   THREE Tab chips     x = 1441 · 1476 · 1511   (y 50)
    Remote               TWO Tab chips       x = 1272                 (y 540, 570)
      the two things that tab onto it, sitting right beside those chips:
        `Run controls and map open option widget`   x 1310 y 540
        `Route test drive control widget`           x 1441 y 540
    Map control. Locked to map                     separate box
    Map surface                                    its own

⟶ **Three on the pane, two on the remote, drawn six days before the question was asked.** And
`options.lua:10-13` says the same thing in its own comment — *"Battlewrath's diagram shows the three lanes
twice"* — while `:113-131` BUILDS exactly three: `run` (whose comment reads *"A10.2a folds editor.lua's
curation bar in LAST"*, i.e. curation) · `promote` · `node`. ★ **The option table's three lanes ARE his
three tabs.** AI-21's LANE option was the right one.

### ⚠⚠ WHAT THIS SUPERSEDES, and both are named rather than left to rot
- **`AL-47`'s APPLICATION** (not its rule): it derived *four today, five when remote exists* — `drive` owed
  a fold-in into the unified pane, `remote` BORN a tab. His word: **three on the pane; remote stays its own
  and takes drive as its second tab.** The architect's dated supersession note is theirs to write; filed.
- **`interface/drive.md`'s own ☐** — *"ITS HOME IS G3, NOT THIS PANE. D-E puts the test drive's entry at the
  primary frame's G3 tab."* ⟶ Its home is a **tab on the remote**, not a tab in the primary frame.

### ★★ THE PRINCIPLE THE CORRECTION CARRIES, and it is why AL-47's rule over-reached
AL-47's rule reads *"everything that is an individual widget / pane now is a tab in the unified pane"* and
applied globally it swallows the remote. His structure says the grouping is by **WHO IS USING IT AND WHEN**:

    AUTHORING the record   curation · promotion · object   -> the unified pane
    RUNNING the route      capture · test drive            -> the remote
    THE FLOOR BOTH STAND ON  the map                       -> its own pane

★ Which is `AL-7` restated at the surface level — *"that lets the flight and the steering be placed
separately and not control so much of the user's UI"* — and it is why `drive.md` calling itself *"the
AUTHOR'S DIAGNOSTICS"* does not put it on the authoring pane: it is a thing you DO to a route, not a field
you EDIT on one.

**LANDED IN** — this entry · `ARCHITECT_INBOX.md` AI-24 (the two supersessions, which are not mine to write
into their files). ⚠ Nothing built; the tab count the unified-pane board needs is now **three**.

---

## UL-11 · 2026-08-24 · the metric swapped, Ace scoped, and both inbox items drained
**QUESTION** — his, in order: swap the 0.55em guess · *"keep checking Ace as it may already express how it
handles your questions"* · *"Fully scope ace and see what it saves us from developing."*

### ★★★ THE OFFLINE TEXT MODEL IS MEASURED NOW — 69.5% → 92.8-95.6%
`emit_text_metric.py` reads the client's own fonts out of `locale-enUS.MPQ` (through `check_sheet`'s
loader — ONE reader of the archive) and emits `smoke/text_metric_data.lua`: per-character em advances plus
a linear correction fitted on CALIBRATION strings and scored on SPECIMEN strings it never saw. Line-count
agreement over 660 client wrap cells, per configuration: **93.5 · 95.6 · 92.8 · 93.6 · 95.5%**.

    q   = 3 * (screenW/screenH) / (10 * uiScale)      11 configs, 4 resolutions, worst 1.01e-07
    q_v = 3 * (16/9)          / (10 * uiScale)        the SAME formula on the NOMINAL aspect

⟶ **One mechanism, two aspects.** `1/q_v = uiScale x 1.875` and 1.875 = 15/8 = (10/3)/(16/9) exactly; at
1920x1080 the two quanta are identical and they only diverge off 16:9. That explains UL-10's 0.0123%
without a second mechanism. ⚠ Predicted, not proven — the vertical grid is measured at one resolution;
**one sheet run at 4:3 falsifies or confirms it.**

### ⚠⚠ THREE FAULTS, EACH ALREADY WRITTEN DOWN SOMEWHERE I HAD NOT LOOKED
- **`CreateFontString(n)` took ONE argument** and dropped the layer and template, so every FontString in
  the model was an anonymous size-12 string. The per-glyph table was useless until that was fixed — the
  width model was blind on the wrong side of the call.
- **One `k` per font, applied at every uiScale**: 46.7% at one configuration, **WORSE than the guess it
  replaced**, beside 85.8% and 92.8% at others. `frames.lua`'s own header has said since it was written
  that the per-em constant *"is NOT smooth in scale … an unmeasured scale must be MEASURED, never
  interpolated."* Now keyed by (font, uiScale); an unmeasured scale gets NO answer, not a neighbour's.
  ★ **A model right at three scales and wrong at a fourth is more dangerous than one evenly mediocre.**
- **r33 and r41 disagree on the accessor** — `Label` calls `GetHeight()` in ours and `GetStringHeight()`
  in AI_VoiceOver's, and Button/EditBox/CheckBox/Dropdown/Heading all differ too. §579 had taught the model
  only the first. ⟶ Both now answer, and NOT by delegation: `GetHeight` short-circuits on a set `_h` while
  `GetStringHeight` must always report the text's height.

### ★★ AND "WHICH ACE RUNS" IS NOT A VERSION QUESTION ON THIS FORK
Every Ace minor reads `1.#INF` (`task_sheet.lua:285-297`, confirmed by every capture). LibStub replaces
only when `oldminor < minor`; with both infinite that is false, so **the FIRST copy to load wins and no
later copy can displace it.** The Ace field audit's open line *"whether AI_VoiceOver's AceGUI 41 wins at
runtime (load order; F1)"* is answered inside its own parenthesis. Addendum written there.

### THE TWO RULINGS THAT LANDED, AND WHAT THEY HAND THIS SEAT
**AL-46 (from AI-23) — the Ace3 posture: YES, scoped.** Plumbing defaults to USE, adopt ON TOUCH; the
layout/offline domain is explicitly the PRODUCT. ⚠ My least-sure row was settled by a CAPABILITY fact
rather than the latency measurement I asked for: AceBucket keeps only arg1 with a count and drops every
other argument, so it cannot hold multi-arg readings at any latency. **I framed a capability question as a
performance one, and performance is the more expensive kind to answer.**
★★ Three BORROWS come back to this lane (gap §1): the **width unit** (170 base, half/double/relative —
resolution-independence with zero screen reads), **validate → error / confirm → popup**, and
**NotifyChange**. ⟶ The width unit is the sharpest: it reaches resolution-independence by never asking,
where our offline model had to compute the aspect. Ours must, because it reproduces rasterisation; a PANE
never should.

**AL-47 (from AI-21) — membership is DERIVED, never counted.** Battlewrath: *"Everything that is a
individual widget / pane now, is a tab in the unified pane. And when it comes out of being a tab, it is a
better form of the panes that exist today."* ⟶ `curation`·`promotion`·`object` are tabs; **`drive` is the
one individual pane now and is owed a fold-in**, its 280×206 UIParent window being the legacy form its
undocked form supersedes; `remote` has no code so it is BORN a tab. **Four today, five when remote exists
— a membership, not a constant.**
⟶ **This unblocks the unified-pane board**, which had no honest tab count until now.

**LANDED IN** — `addons/tools/emit_text_metric.py` · `smoke/text_metric_data.lua` · `smoke/frames.lua` ·
`smoke/wrap_predict.lua` · `check_sheet.py --wrap` · `addons/tools/emit_ace_scope.py` ·
`audit/ace3_scope_2026-08-24.md` · an addendum on `audit/prior_art_ace_field_2026-08-21.md`.

**WORD** — Battlewrath, 2026-08-24: *"Yes. Go for it"* (the swap) · *"keep checking Ace as it may already
express how it handles your questions"* · *"No point building everything custom where a lot is done."*

---

## UL-10 · 2026-08-23 · sheet five — the line advance has its OWN grid, and the rule is `round(size / q_v)`
**QUESTION** — AL-45 ruled a measured-height cell kind YES and bounded the offline half to *"measured,
quantised, MARKED"*. That half is this seat's, and **it could not be derived from UL-1**: width settled how
far a string reaches; nothing settled where it BREAKS. A wrap point is a decision the client makes.
Battlewrath: *"Devdump is there to calibrate as needed."*

**OUTCOME** — KIND `wrap` (decl v4 → v5): font × string × width, run twice at 3620×2036 @ 0.86.

### ★ FOUR THINGS MEASURED, NONE DERIVED
    METHODS         PRESENT GetStringHeight · SetNonSpaceWrap · **SetWordWrap** · ABSENT GetNumLines.
                    ⚠ I expected SetWordWrap to be later-client API on 3.3.5. It is here. Nothing was
                    called blind, and the absent one is a fact about the client rather than a gap.
    ONE LINE        all 660 heights are whole multiples of the font's measured `oneLine`, inside 0.02
                    — CHECKED, because if it were false it would matter more than any row in the table
    MID-WORD        `supercalifragilisticexpialidocious` → 3 / 2 / 2 / 1 / 1 / 1 lines at
                    60 / 96 / 154 / 204 / 244 / 600. The client breaks a too-long token AT THE WIDTH.
                    That is the rule the declaration said we did not know, and now do.
    GetStringWidth  after `SetWidth`, 104 of 180 came back OVER the set width ⟶ it reports the
                    **unwrapped advance**, not the laid-out line. The declaration refused to assume it.

### ★★★ THE FINDING — a SECOND quantum, and it is not the width's
Every font sat OFF UL-1's width grid by the same ~0.002 q. A consistent offset is a different grid, not
error. Derived with the tool's own `derive_quantum` on the advances alone:

    q_v = 0.6201550525625      1/q_v = 1.612500      advances = 16 · 19 · 23 · 26 q_v  (EXACT)
    q   = 0.6202312336768756   1/q   = 1.612302      q_v / q = 0.999877173

⟶ **The line advance is quantised on its own grid, 0.0123% off the width's.** Four distinct advances,
all exact integers of one q_v — and the two-font derivation and the four-font derivation agree to 13
significant figures, so the grid was not an artefact of two points.

### ★★ AND THE RULE, WRITTEN AS A TEST RATHER THAN A FIT
    advance = round(size / q_v) × q_v
    size/q_v = 16.125 · 19.350 · 22.575 · 25.800   →   16 · 19 · 23 · 26
★ `round`, not `floor` — 22.575→23 and 25.800→26 are the two cases that separate them.
**11 of 11 fonts fit exactly, worst residual 8.20e-07**, across TWO font files (`FRIZQT__.TTF`,
`ARIALN.ttf`) and four sizes ⟶ the rule is font-file-independent.
⚠ `q_v` is derived from the advances; the advance is then PREDICTED from the declared SIZE and the
residual printed per font. A rule that is tested can fail visibly on the next run; a fitted one cannot.

### ★★★ THE SWEEP ANSWERED THE SAME DAY — `q_v` IS DERIVABLE
Battlewrath ran three more at one resolution: *"3 samples. Min, Mid, Max."*

       uiScale            q_v        1/q_v   (1/q_v)/uiScale
        0.6400   0.8333334359     1.200000       1.875000000
        0.8200   0.6504065307     1.537500       1.875000058
        0.8600   0.6201550526     1.612500       1.875000099
        1.0000   0.5333333007     1.875000       1.875000185

⟶ **CONSTANT to 3.0e-07 across four scales:  `q_v = 1 / (uiScale × 1.875)`.** So an offline wrapped
height needs **no per-configuration capture** — the vertical grid is computed, exactly as the rule
above computes the advance on it. ⚠ ONE RESOLUTION. This spans uiScale; whether it also holds across
resolutions is untested, and the tool prints that line with the result.

### ⚠⚠ AND THE TEST WAS WRONG BEFORE THE RULE WAS — the yield was a bad TEST
The first sweep read reported **3 of 11** fonts fitting at uiScale 0.64 and **6 of 11** at 1.0, and I
was one step from writing that the rule failed at the extremes. Every residual was ≤ 2.64e-06 on
values near 12: **an ABSOLUTE 1e-6 threshold on a magnitude-12 quantity is 8e-8 relative, finer than
the client's own floats.** The failures were my tolerance.
★ The fix is not "loosen until it passes", which is fitting the tolerance. It is RELATIVE, because
that is how the error scales — `q_v` is one measured advance over an integer, so it carries ~1e-7
relative error and `n × q_v` carries it too. **The teeth survive:** an off-by-one-QUANTUM error is a
residual of ~q_v, relative ~5e-2 — five orders of magnitude above the threshold, which the output
prints beside every verdict. Result: **11 of 11 at every configuration, worst 1.7e-07.**
⚠ Rounding is now explicit half-up rather than Python's banker's `round()`. NOT a finding: no
reported size divides `q_v` exactly, so no tie occurs anywhere in this data and both rules agree on
every row. The choice is UNTESTED and marked as such.

### ☐ AND ONE THING THIS OPENS, marked as a candidate and NOT acted on
`q_v / q` is itself constant — 0.999877359 · 0.999877279 · 0.999877173 across the three configs that
carry both, a spread of 1.9e-07. ⟶ The two quanta are one physical grid reached by two constants,
and it is the VERTICAL one that lands on an exact **15/8**. **So `q = GetScreenWidth()/2560` may be
UL-1's approximation of `1/(uiScale × 1.875)` rather than the true form.** ⚠ That is a claim about
UL-1's finding made from the vertical sweep, and it is not tested here — it belongs to the next width
check, not to this entry.

**LANDED IN** — `addons/COA_DevDump/sheet_decl.lua` v5 (kind `wrap`, 11 fonts × 10 strings × 6 widths =
660 cells; other kinds' fingerprints unchanged) · `task_sheet.lua` · `check_sheet.py --wrap`.

**CITES** — `ARCHITECT_LOG.md` AL-45 · `UI_LOG.md` UL-1 (the width quantum) · `concepts/row.md` ·
F·29 on his 2026-08-23 screenshot, which is the first specimen string.

**WORD** — Battlewrath, 2026-08-23: *"Yes. Devdump is there to calibrate as needed."*

---

## UL-9 · 2026-08-23 · four screenshots, 38 defects — and the repo had already answered the design half
**QUESTION** — his sequence: *"I'll grab a screen shot of in-game as it is today. Then you break it down for
issues… Then you can compare your own attempt against that."* Then the peer: *"screen shots of our peer /
target… Mainly tabs to reduce the burden of any one pane."* Then his own sketch, and *"check Architect log."*

### ★ THE PART THAT WAS WORTH DOING — observation of the live client
**38 numbered defects** across four surfaces, each with a location rather than a category. The ones that are
not taste:
- **F·29 · a three-way collision on one row** — `☐ move`, the wrapped description `completes when found -
  bu… he reaches`, and `Delete` all anchored to one y. The description draws THROUGH the checkbox label and
  is cut off by the button. Worst defect in either shot.
- **F·30 · the object pane's empty half is a KNOWN TRADE, not a defect** — ⚠ I listed it as one and the
  source says otherwise. `object.lua:577-582`: the pane is a fixed `240 x 600`, and *"the wireframe measured
  what each subject actually needs — child 575, beacon 415, note 169"*. The screenshot is a BEACON, so ~415
  of 600 is used and the rest is the cost of ONE fixed height across three subjects — decided at §104, with
  its reason written down. ★ It stays worth showing him, but as an arrangement question the scope doc has
  already framed, never as something broken.
- **F·31 · `advance (+…`** — the dropdown that most needs reading is the one that truncates.
- **D·21 · `not re…`** clipped by `Options` in Dungeon run, and that row has since grown to three buttons
  with the clip untouched.
- **C·17 / F·32 · orphan labels** — `stage` beside `Create beacon`, `free` beside the stage field.
- **B·7 / F·33 · three unlabelled edit boxes.**
- **E·25 · red means nothing** — it is on `Close`, `Options`, `Drive`, `Peek`, `Delete` and `Play`. WA spends
  red only on `Add …`, i.e. *this creates something*.

### ★★★ THE PART THAT WAS NOT — four things derived that the repo already held
    ui_overhaul_scope.md              `575px in a 330px pane · 195 of it chrome · THAT IS AN ARRANGEMENT
                                      DECISION, NOT AN ARITHMETIC ONE` and `which is exactly what tabs
                                      answer` — §571 ran the arithmetic contest anyway
    ui_overhaul_scope.md              THE FOUR TAB STRIPS, derived from what a node IS — Face : Stage 1 :
                                      Stage 2 · Face : Children : What they are doing · Face : Stage 1 :
                                      Action (N) · Face : Action (N). This seat proposed its own four-tab cut
                                      of the same pane, cold
    ui_overhaul_scope.md              `tabs are a partition, and you cannot partition content you have not
                                      got` — an explicit NOT YET on the cut that was proposed
    reference/weakauras_idioms.md     the whole WA lesson list, already read and already marked with what
                                      each idiom answers, including `WA does not scroll five zones, it tabs
                                      them` and `the label sits ABOVE the field`
⚠ **And one WA claim of mine was backwards.** I read two greyed controls off the shots and said *WA keeps
things in place and greys them.* The idioms file has it COUNTED in `WeakAurasOptions`: **dependents are
HIDDEN far more than they are disabled.** A two-instance inference against a counted fact — and it means the
tell-collapse §571 proposed was closer to the peer than the correction that replaced it.

⟶ **THE CAUSE IS MECHANICAL AND IT IS FIXED IN `UI_SEAT.md`, not resolved.** The boot list named
DRIVER_BASIS, AP-13, UI_LOG, two audits and the smoke README — and pointed at **none** of
`ui_overhaul_scope.md`, `reference/weakauras_idioms.md`, `interface/*.md`. A doc boot does not name is a doc
the chat must think to open, and the chat only ever asks its own questions. The boot list now names all three,
with why.

### RETRACTED
- **`object.md`'s 240 width is "wrong by ~25%".** Measured off a screenshot whose resolution and UI scale I
  do not know, against a number `check_interface.py` reconciles. ⚠ Note for whoever picks this up:
  ⚠⚠ **And the follow-up claim was wrong too, killed by one grep of the source.** I said
  `ui_overhaul_scope.md`'s **330px pane** disagreed with `object.md`'s **240**. It does not: **330 is
  a HEIGHT.** `object.lua:577-582` — *"★★ 600 TALL, NOT 330 (§104). The wireframe measured what each
  subject actually needs — child 575, beacon 415, note 169 — against a pane held at 330"* — then
  `f:SetWidth(240); f:SetHeight(600)`. There is no disagreement; I read a height as a width and
  called two documents into conflict over it.
- **"A second tab level is not available."** Struck by Battlewrath the same day, and by `object.md:237`
  (*"the tab shape makes each action its own tab, several per child"*), `:345` (tab 1 SWAPS for the child
  roster) and `driver_architecture.md:77` (*BEHAVIOUR records, N per node — one per action tab*).

**HIS WORD, 2026-08-23** — two rulings, both recorded and applied:
1. **`dock / undock`, never `knock out`.** His sketch's *knock out* and `A10.9`/`§3a`'s *undock* are one
   mechanism; *"Dock / undock is better."* ⟶ one vocabulary, per the no-creator-dialect law.
2. **Tab rows within tab rows are allowed.** *"Action tabs for Beacon and Child will sit lower are 3 entry
   rows."* ⟶ the group strip (one tab per docked group, `driver_architecture.md:129`) sits above; the node's
   own strip sits lower inside the pane. That is `ui_overhaul_scope.md`'s FOUR TAB STRIPS, each 2–3 entries.

**LANDED IN** — `UI_SEAT.md` (the three docs, at the boot list) · this entry. ⚠ Nothing built; `AI-21`
(may a zone collapse under A10.9) was drafted and **withdrawn unfiled** — `ui_overhaul_scope.md` answers it.

**☐ FILED AS `AI-21`, and re-asked from SOURCE** — the first version of this reasoned *AL-13 counted six
files and derived four groups, there are now seven, so five*. Battlewrath: *"I'd check from source rather
than laywering architect's statement."* ⟶ The code says something the sentence never did:
`options.lua:113-131` builds **three** lanes (`run` · `promote` · `node`, `childGroups = "tab"`);
`drive.lua:396` builds its own `UIParent` window and `drive` appears nowhere in `options.lua`; and
**`grep dock` across the whole addon returns ONE hit — a comment.** Dock/undock is not built. The question
the architect now has is whether a dockable group is a LANE or a SURFACE, which decides how many tabs the
strip holds.

### ⚠⚠ AMENDED SAME DAY — a fifth instance, and it is the SCOPE one
`addons/planning/audit/ui_drawio_model.md`, **dated 2026-08-18 and read by the Analyst**, already
decodes Battlewrath's interface-inventory diagram — in **two variants** (`A. FIXED PANES` · `B. TABS`;
he sent B) and **including the annotation boxes cropped out of the image**: *"Promote node lite;
right-click a run node to spawn that node's promoter"* · *"Run remote / arm / doorway"* · *"Route
test arm"* · *"Command strip, display map context. Open chips. Close map"*. It also already records
**"KNOCK-OUT: dock/undock a pane group into a floating widget"** — so today's ruling CONFIRMS a
reading the record made five days ago rather than establishing one.

⟶ And the failure has a precise shape, distinct from the four above: I grepped `interface/promotion.md`
and `ui_overhaul_scope.md` for *Promote node lite*, found nothing, and reported *"no hit in source or
planning"* in §573b's message. **The search SCOPE excluded the file that would have refuted me** —
an absence is a claim about everywhere I did not look. `UI_SEAT.md` now names `audit/` as a FOLDER
rather than the two files it happened to list.

### ★ AND ONE THING THE RECORD DID NOT HAVE — `coalesce`, defined
The audit has quoted his phrase *"scaled to current frame/map coalesce"* since 2026-08-18 without a
definition. Asked directly, 2026-08-23: *"Coalesce is the correction for positional data, frame
scaling and map tile scaling. A correction already on the map."*

⟶ The behaviour is BUILT and was unnamed across six call sites; the WORD is the new thing. Home
opened at `concepts/coalesce.md`, indexing `map.lua:1224-1250` (the fraction round trip),
`:1249`/`:289-295`/`:344` (frame scale and uniform zoom), `:1317-1322` (the tile crop), and the
[SILENT] fact they all exist for at `:44-61` — coordinate space 1002×668 against tile art 1024×768,
**+2.2% across and +15% down, caught by eye and by nothing mechanical.** ★ Which makes *"scaled to
current frame/map coalesce"* ONE claim: the surface takes any frame size only BECAUSE the correction
holds, the same argument `options.lua:21-40` makes as SCALE-never-RESIZE.

**FILED THIS DAY** — `AI-21` (is a dockable group a LANE or a SURFACE — three lanes in `options.lua`,
four in AL-13, seven files in `interface/`) · `AI-22` (no cell kind has a height that depends on its
own text, which is what F·29 is).

---

## UL-8 · 2026-08-23 · the object pane reorganised — and the number went the wrong way
**QUESTION** — his test: *"see if you can recreate the current Dungeon Run UI. But not from exact
match. Organising the content with the smoke flash harness."*

**OUTCOME** — every control in `interface/object.md`, for a child (the fullest subject), on a board:
none invented, none dropped, and the three orphans (`object.ordinal` · `object.note` · `object.sense`
— hand-placed, no panespec zone) given one. Two boards from **one `build()`** so the states cannot
drift: `objectpane-2026-08-23-resting` (24 panes, 588px) · `…-telling` (29, 674).

**REASONING — the argument is theirs, not taste.** `object.md` records `195 of the child's 575 is
chrome — five zones × 39 for the divider-and-header shape`, and that two zones were already MERGED to
buy 78px back. So the dressing work went at exactly that: `ChallengeMode-RankLineDivider` (193×9,
wide-3, free, hue 50.8) as a **14px gold hairline** with an inline caption where a header block costs
39. **195 → 100. It worked.**

### ★★★ AND IT CAME OUT 99px TALLER — the saving was real and the ROW POLICY spent it
    chrome     100  (5 hairlines)               today: 195
    content    530  (19 rows — 14 hold ONE control)
    total      674                              today: 575
⟶ **Pairing dominates chrome.** The furniture is the number everyone counts; the row policy is the one
that decides. ⚠ Even resting, five tells collapsed, it is **588 against 575**: today's pane is packed
TIGHTER than my reorganisation of it, and its own file's complaint about chrome is paid for by hard
pairing everywhere else. Concept home opened: `concepts/row.md`.

### ★★ THE FAULT THE PICTURE FOUND AND THE EMITTER COULD NOT
My rule paired **by fit** — two controls whose widths sum under the column. Telling state:
`object.ordinal` pairs with `object.ordinal.match`, which is right. Resting state: that tell is gone,
so it paired with the next thing that fits — **`object.delete`, an irreversible button, landed beside
a text field.** Nothing in the declaration said they belong together; only arithmetic did.
⟶ **Pair by declared RELATION, never by fit** — a fit rule gives a control different neighbours in
different states. Invisible in the emitter, obvious in the render, and it is the clearest case this
bench has yet made for looking at the board.

### ★ THE TELL — 86px of permanent height for five conditional lines
`boss.tell` · `match` · `stagematch` · `ordinal.match` · `note.ghost` each react to the control above
them and each hold a row for something they only sometimes say. ⚠ **Not a new rule:** `object.md`
already records heights-per-subject; this applies it one level down, pane → row. ⚠⚠ **The cost is in
the proposal, not a footnote:** a pane that resizes while you type moves controls under the cursor —
the cousin of his *"weird stalling if it updates per entry"*. Reserving the line costs the 86px and
moves nothing. **The trade is the Addon creator's; both boards exist so it can be made by looking.**

### THE HARNESS ITSELF — the fourth false `passed`, and again it was FRAMING
The first render reported the right board id, the right title and 29 panes over **a picture of the
sidebar**: a 240×674 board in a 960×640 window is a ~200px visible strip. Every false `passed` this
harness has produced has been a framing fault, never a render fault. ⟶ smoke now grows the window to
fit and captures the `#board-canvas` **rect, measured through the DOM** rather than computed from the
board's viewport — zoom, chrome and scroll sit between those two numbers, and a computed guess is what
was wrong the previous three times. ⚠ The person's own **Export PNG** is untouched: `rect` is optional
and absent still means the whole window.

**CITES** — `interface/object.md` (zones · heights · the 195-of-575 line · heights-per-subject · the
three orphans) · `concepts/art-and-rect.md` (why every dropdown asks 154 to draw 204).

**LANDED IN** — `addons/planning/concepts/row.md` · `addons/tools/emit_object_board.py` ·
`PaneBoard/src/main/labTooling/paneBoard/paneBoard.js` (framed capture) · two boards in
`agent-proposals/`. ⚠ **No addon file changed.** A proposal on a board, not a spec and not a
replacement for `panespec.lua`; whether pairing-by-relation is expressible in the current panespec is
open and unexamined.

**WORD** — Battlewrath, 2026-08-23: *"Do you want a test with pane?"* → the test above.

---

## UL-7 · 2026-08-23 · window dressing — the capability, and a register entry that was simply wrong
⚠ **This entry closes a GAP, not fresh work.** Nine commits of atlas/dressing capability landed with no
log entry and no planning doc; grep across `addons/planning/` for `goldborder` / `nine-slice` /
`nineslice` returned nothing, and the only repo-wide mentions are machine-emitted maps. **Work that
exists only in commit messages is work the next bench cannot find.**

**QUESTION** — his: *"there is a big gap so far in display quality between our addons and what the
community produces. Functionality > Display, but nice to start building the capability."* Theme:
**mythical gold, browns and bronze.** Boundary, in his words: *"boarder framing is free use. On a map
the icons have meanings. And that's our curation. But the presentation of our addon we fully own."*

**OUTCOME — a capability stack, each layer a tool that emits rather than a claim that persuades**
    emit_atlas_sheet.py      render named atlas art BY NAME, never by coords (--stress --overview
                             --materials) — the name is the contract; coords are the client's business
    emit_art_inventory.py    theme (hue 18–58°) + SCALING CONTRACT over 4471 entries:
                             wide · tall · both · wide-3 · tall-3 · 9slice · fixed
    emit_art_sets.py         border SETS by longest-first name-part matching — exactly ONE complete
                             nine-slice on this client: `store-goldborder`
    emit_dressing_board.py   --set · --nineslice <stem>: eight pieces composed into one border-image
                             source (106×102, slice 36/21/34/53)
    PaneBoard                `nineslice` fit, slice validation, slice preserved across sidebar edits

**THE SCALING CONTRACT, and why it is computable rather than eyeballed** — *art survives stretching
along the axis it is already uniform in*. Measured as middle-uniformity plus cap-difference, so a
piece's contract falls out of its pixels instead of out of a judgement. This is what lets a divider be
called `wide-3` and stretched with confidence (and it is what `concepts/row.md`'s gold hairline rests
on).

### ★★★ `store-goldborder-right` IS WRONG ART IN THE REGISTER — and my own tool had already said so
The composed frame came out gold with **one red bar** in it. First read: a neighbouring texture
cropping in. ⟶ Wrong: the piece's coords land on different art on this fork, and the LEFT edge
mirrored composes a clean frame — which is not a guess, it is why `AtlasInfo` carries fH/fV flip flags
at all. ⚠⚠ **The evidence was already in `emit_art_sets`'s own output and I read past it:** it printed
`8 pieces · 7 warm`, seven at hue 23.7–41.9 / sat 0.17–0.26 and one at **hue 5.8, sat 0.81**.
⟶ So the check went into the tool and **prints by default, never behind a flag** — a guard you have to
ask for is a guard nobody runs, and this one exists because its own evidence sat unread:
`HUE_OUTLIER_DEG = 25.0` · `SAT_OUTLIER_RATIO = 2.5`.
⚠ **Its structural limit is printed with it:** it compares each piece to the set's MEDIAN, so it finds
the ODD ONE OUT and cannot answer *is this set correct* — a set where most entries are wrong has a
wrong median and reports nothing.

**LESSONS** — (a) a **name search is not a use** and a **path with escaped backslashes reports every
texture MISSING**, confidently; (b) three smoke runs reported `passed` while rendering the wrong thing
— canvas never re-rendered · 2× zoom showing one corner · **two material normalisers, one updated**, so
`nineslice` would silently degrade to `cover`; (c) his correction on the hang stands: *"Check protocol.
We have a modified hook on the py command path"* — my attribution was wrong, the hook already blocks
the shape that bit me and the sweep was slow, not hung.

**LANDED IN** — `addons/tools/emit_atlas_sheet.py` · `emit_art_inventory.py` · `emit_art_sets.py` ·
`emit_dressing_board.py` · `PaneBoard/src/renderer/pane-board/*` · `src/main/labTooling/paneBoard/`.

**WORD** — Battlewrath, 2026-08-23: *"Build. And boarder framing is free use"* · *"Yes. You can start to
inventory. The theme I have for the addons is mythical gold, browns and bronze"* · *"Yes. It can hurt.
And the fall back is always me looking in the atlas."*

**☐ OPEN** — whether a genuine gold right-edge piece exists on `Store-Main` · the client-side `dressing`
cell comparing the client's per-edge anchoring against CSS `border-image`.

---

## UL-6 · 2026-08-23 · the input-commit grammar — and WA's answer was not the one I proposed
**QUESTION** — his: *"how it edits records as a repeatable unit. Dungeon run has already worked on this.
(Weird stalling if it updates per entry.) And WA uses accept buttons. We could look at grammar of a
middle ground. Some feedback on the text input field. (Highlight react?)"*

**FRAME** — ⚠ he set it before any of it counted: *"Our prior work doesn't factor into decisions. This
seat and our work is part of the UI overhaul. So we get to have a blank slate and we'll retrofit where
needed."* DungeonRun and Landmarks handling is **evidence** in this entry, never constraint.

**OUTCOME** — the grammar is one line: **`OnTextChanged` tells the USER, `OnEnterPressed` tells the
RECORD.** Live feedback rides the advisory event and never touches the record.

★★ **His three rulings need NO change to Ace, because they already ARE Ace.** Measured against the
source, not assumed: the accept button is on by default (`OnAcquire` → `DisableButton(false)`); Escape
calls `AceGUI:ClearFocus()` with no revert and no commit; focus loss does nothing, so the edit **stays
pending**; and `AceConfigDialog` binds only `OnEnterPressed`, never `OnTextChanged`, so an option's
`set` runs **once per commit**.

★★★ **WHICH MAKES THE HAZARD ABSENT RATHER THAN GUARDED.** No `OnTextChanged`→write means no
refresh→SetText→refresh loop to defend against — not with a comparison, not with a `userInput` flag, not
at all. ⟶ And the DungeonRun evidence is what made that legible: its stall was never the loop (measured
deferred/coalesced/change-only, worst case a one-frame bounce) — it was `refresh()` on **every
keystroke**. A design choice, not a hazard.

**⚠⚠ THE LESSON, AND IT IS HIS CORRECTION** — *"On the sensitive. I'd look at what WA does for second act
accept. Rather than going on my invention."* I had proposed a sensitive field that refuses its own first
commit so the pending state doubles as confirmation. **WA does nothing of the kind.** Its text inputs
carry no extra ceremony at all; destructive acts go through the client's own `StaticPopupDialogs`. The
option table's `confirm` exists in AceConfig and WA uses it **once in the entire addon**.
⟶ So the second act attaches to an **ACTION, never to a field**, and the input kinds collapse to **one**.

★ **The popup's shape, from two instances that agree** — text built per call stating the SCOPE and the
IRREVERSIBILITY · `button1` is the ACT ("Delete"), never "OK" · payload on `self.data`, not a global ·
`timeout = 0` because a destructive confirm must not expire out from under you · a re-entry flag so it
cannot stack.

**CITES** — `AceGUIWidget-EditBox.lua:62-146` · `AceConfigDialog-3.0.lua:1118-1135` ·
`WeakAurasOptions.lua:441-487` · `TriggerOptions.lua:380-398` · `AuthorOptions.lua:2196` ·
`audit/ui_wa_grammar.md` · `COA_DungeonRun/object.lua:660-700` (evidence).

**LANDED IN** — `concepts/input-commit.md`.

**STILL OPEN, deliberately** — what the advisory feedback IS (his *"Highlight react?"* is a question, not
a ruling), and how existing fields are retrofitted. The `behaviour` sheet kind is the intended proof.

**WORD** — Battlewrath, 2026-08-23, as quoted; *"Yes."*

---

## UL-5 · 2026-08-23 · sheets two and three — what six captures actually established
**QUESTION** — from his steer *"expand the sheet into use cases we already have… For the editor side,
Weak auras is our mirror target (In substance, not 1:1)"* and then *"A sheet at a time. Each building on
the display capability of the next."*

**OUTCOME — the order was forced, not chosen.** `text` is the prerequisite for `control`: AceGUI sizes a
Button as `GetStringWidth() + 30` and wraps a Flow row on content width. `control` is the prerequisite
for `art`. The sheet grew `control` (56 cells, 7 widgets × 8 widths, + 3 containers) and `art` (13
subjects, each built twice for the A:B).

**WHAT THE CAPTURES ESTABLISHED**, all emitted by `check_sheet.py` rather than transcribed:
- ★★ **Every Ace library on this fork is at minor `1.#INF`.** The client ships its own under
  `Interface\LibraryXML\`; LibStub keeps the highest minor; **the client's copies always win and ours
  can never run** — nor can the newer AceConfigDialog WeakAuras expects.
- ★★ **WA's width vocabulary does not work here.** `normalWidth 1.3` / `halfWidth 0.65` /
  `doubleWidth 2.6` **all collapse to 170**, measured in-client, because our AceConfigDialog branches on
  the strings `double`/`half`/`full` only. The mirror is a mirror in substance, not in units.
- **Control heights**: Button 24 · CheckBox 24 · Heading 18 · Dropdown 40 · EditBox 44 · Slider 44.
- **Container insets**: SimpleGroup 0/side · InlineGroup 10/side · TabGroup 30/side.
- ⚠ **`full` filled only Button.** `widthProp = fill` was set on every widget; CheckBox, Dropdown and
  Slider stayed at 200. One capture, one host width — observed, not explained.
- ★★★ **`art` reproduced the hand-measured rule.** `UIDropDownMenuTemplate` top **+17**, bottom **+15** —
  `layout.lua`'s `Layout.ART = { dw = 50, h = 64, dy = 17 }` was read off the XML at §103; this is the
  client's own answer off a live frame, and they agree. The named dropdown measures **220** wide for a
  170 field: +50, exactly `Layout.DROPDOWN_ART`.
- ★ **AceGUI's own Dropdown overhangs every edge** — L +15, R +17, T +3, **B +21**. Ours matters more.
- ★★ **The A:B closed list**: `InputBoxTemplate` and `UIDropDownMenuTemplate` **NEED A NAME**;
  `UICheckButtonTemplate`, `UIPanelButtonTemplate`, `UIPanelCloseButton` do not.

**⚠ LESSONS, and every one cost a capture:**
1. **A number that could be infinite must be a STRING before it crosses the mailbox.** SavedVariables
   cannot serialise `inf`: it wrote `["AceGUI-3.0"] = nil --[[ inf ]]` and all four gate values landed as
   null. The client knew — the summary line printed `1.#INF` because it was built before the flush.
   **A nil and an infinity are indistinguishable in the file**, same family as a zero and a measurement
   that never happened.
2. **Release through the CONTAINER, never the child.** `c:Release()` while parented returned the widget
   to the pool without clearing `group.children`; the next Create handed the same object back and Flow
   anchored a frame to itself (`AceGUI-3.0.lua:767`).
3. **A rect is not resolved in the tick that creates the frame.** The first `art` run returned 6 of 6
   dropdown regions "unplaced". Measurement and Commit moved into `C_Timer.After(0, …)`.
4. **The frame TYPE is part of the specimen.** Three templates drew nothing in BOTH columns because
   every one was created as `"Frame"`; a Button's art is `<NormalTexture>`/`<PushedTexture>`, elements a
   Frame has not got. ★ `InputBoxTemplate` rendered anyway and HID it — its textures are plain
   `<Layers>` regions any frame type carries.
5. **A row is as tall as its tallest cell** — §101, and my own board broke it with a fixed 38px pitch
   against controls 9.9 to 44 tall. **The instrument is not exempt from the rule it measures.**
6. ★★ **The eye was right and the verdict was wrong.** A:B said `InputBoxTemplate … same` while the
   screenshot plainly showed the missing middle: region count matched and rect matched, because the
   texture still EXISTS — it just has no anchors, so it floats. The union's TOP edge went 0 → 75.
   ⟶ **Count and rect are not enough; where the picture reaches is the observable.** The tool's own
   stated limit is what flagged it.
7. ⚠ **A forced global, recorded and ignored.** `geom_probe_runsheet.md` already said a dropdown needs
   `GetName()`; I passed `nil` anyway, so `UIDropDownMenu_SetWidth` did nothing and `ToggleDropDownMenu`
   errored on click. Same root cause as the missing input middle — `$parent` resolution — one cause, two
   symptoms, and the rule now lives in `concepts/art-and-rect.md`.

**LANDED IN** — `sheet_decl.lua` v3 · `task_sheet.lua` · `check_sheet.py` (`--controls`, `--art`, the
A:B verdict) · `concepts/art-and-rect.md` · `ui_sheet_spec.md` · six captures committed as basis.

**WORD** — Battlewrath, 2026-08-23, across the arc; *"Yes. Insert the A:B test on the sheet."*

---

## UL-4 · 2026-08-23 · the picture is not the box — sheet three, and a run card that had been right for a day
**QUESTION** — his: *"The issue was the surrounding art / materials that comes with the UI. Like the
drop down selector's down arrow."* And the method with it: *"build concept out clean and extract
useful comments, over editing in field… reasoning comes from collating and collecting to stable
surfaces."*

**OUTCOME** — the lesson was not in commit history as a search problem. It is **§103, "the neighbour,
not the edge"** (2026-08-15), and its durable form has been in `COA_DungeonRun/layout.lua:108-131`
ever since — in the code, where you are standing. The rule, his bench's words:

> *a rect check UNDER-REPORTS a dropdown by design, and a pane can look wrong exactly where the
> arithmetic says it is fine*

`UIDropDownMenu_SetWidth(dd, w)` gives FIELD `w`, TEXT `w-25`, ART `w+50` — and the arrow that
reacts to a click lives out in that Right texture, outside the frame you sized. Vertically the three
textures are 64 tall on a frame declared 32, anchored at y=+17.

**★ IT ALSO CLOSES THE PLAY BUTTON.** The promoter asked 200, read it as *200 wide*, put a button at
208 — inside the 250 of art. The geometry run measured that button as comfortably INSIDE its pane
and filed the cause as unknown, because **every instrument we own compares rects.**

**⚠⚠ AND `geom_probe_runsheet.md` STILL SAID UNKNOWN — stale by one commit, for eight days.** §102.1
wrote *"no third guess goes in here until something measures it"*; §103 answered it the next commit,
and it even listed *"art beyond the frame edge"* as one of three candidates. ★ That page is what
someone reads **before spending a run**, so a dead question sitting there costs a capture. Corrected
by POINTER, not rewrite (his steer): the dead reasoning stays, because it is the record of *why the
answer was hard to see*.

**WHAT IT NAMES IN MY OWN WORK** — sheet two measured `frame:GetWidth()`. Every number in that table
is what the layout uses and **none of it is what the eye sees**. `Layout.ART = { dropdown = { dw =
50, h = 64, dy = 17 } }` is one entry, hand-measured, for one template.

**LANDED IN** — `concepts/art-and-rect.md` (the concept, built out clean: what it is · the closed
list · the case that paid for it · where it is ruled · what is owed, derived not read) ·
`sheet_decl.lua` kind `art` (13 subjects: 6 stock templates + 7 AceGUI widgets) · `task_sheet.lua`
(region union, VISIBLE regions only, hidden ones COUNTED — "none were hidden" and "we did not look"
are different facts) · `check_sheet.py --art` (per EDGE, because the dropdown is asymmetric and one
"art is bigger" number would hide which neighbour it eats) · the run card's pointer.

**⚠ DELIBERATELY NOT SETTLED**, so nobody reads a decision into the concept home: whether
`frames.lua` should carry art at all, or whether art stays a client-measured table the offline
resolver merely cites. The offline resolver reports overlaps and overhangs in RECTS only, so this
entire class is invisible to it — named as a gap, not closed.

**WORD** — Battlewrath, 2026-08-23, as quoted; *"Proceed how you see fit."*

---

## UL-3 · 2026-08-23 · the scaling half was community knowledge, and I derived it anyway
**QUESTION** — his, and it is a correction I earned: *"WoW is 18 years old if not older. I am sure our
question is a known answer in the addon community."*

**OUTCOME — he is right about the half that mattered most, and the record now starts there.**
1 UI unit = 1/768 of the screen height × a ratio; pixel-perfect scale = `768/vRes`; the game clamps
`uiScale` at 0.64 (Warcraft Wiki, *UI scaling*). And **ElvUI's `E.mult`, which is installed on this very
client**, simplifies to **`768/(vRes × scale)` — one DEVICE PIXEL expressed in UI units**. That is the
whole scale story, solved, published, and sitting in `ElvUI/Core/PixelPerfect.lua` on disk.

**Restated on top of it, our one added term**, measured over **nine** configurations (5 resolutions,
3 aspect ratios, 4 UI scales; worst disagreement **1.0e-07**):

> a FontString width is **quantised to `hRes/2560` device pixels** — equivalently
> `GetScreenWidth()/2560` UI units, equivalently `E.mult × hRes/2560`.

⚠ At a 2560-wide display that is exactly one device pixel. That is plausibly the constant's origin and
it is an **inference**, marked as one — nothing in FrameXML carries a 2560, and the engine is closed.

**⚠⚠ THE FAILURE, WHICH IS THE POINT OF THIS ENTRY.** Prior art did not merely exist — **it was already
on my own shelf and I had read it.** `audit/prior_art_ui_tooling_2026-08-23.md` §5 carries `E.mult`, the
rounding formula and `ratio = 768/screenheight` verbatim; I read that audit at boot, cited it in UL-1's
own basis, and then spent nine captures deriving the scale relationship from scratch — reporting `1/q =
1.5936 vs uiScale × screenH/768 = 2.2534` as an open mystery when the missing term was a *width* one and
the framework for seeing that was in the file. ★ **The law already on the spine is
[[the-basis-includes-the-other-benches]]; what it lacked was a trigger.** A named open question is
exactly the moment to re-read the audit, and "I read it at boot" is not the same as reaching for it when
the question arrives.

★ **And the cost was not zero.** Anchoring on `E.mult` first would have expressed q in DEVICE PIXELS
immediately, where the answer is `hRes/2560` and visible on the **second** configuration rather than the
ninth. The sweep would still have been worth running — nine configurations is what makes 1.0e-07 a
result rather than a coincidence — but it would have been confirmation, not search.

⚠ **What is genuinely NOT in the community record**, checked rather than assumed: two searches plus the
wiki page return nothing on FontString width quantisation, and the commissioned tooling audit
independently filed *"font metrics offline: nobody has them — not found"*. So the `hRes/2560` term looks
like ours. ★ That is a claim about where I looked, not about the world.

**ALSO SETTLED THIS PASS** — `k` (quanta per em) depends on **uiScale alone**: identical to four decimals
across four resolutions and three aspect ratios at scale 0.64, and across three at scale 1.00. The
earlier "1440×1080 is an outlier" reading was mine and is **withdrawn** — `em_UI` looked unstable only
because it is `k × q` and q carries the resolution. ⚠⚠ `k` is NOT smooth in scale: 0.64→0.65 jumps
14.608→15.853 with non-overlapping plateaus, so an unmeasured scale must be **measured, never
interpolated**. ⚠ `c` still wobbles ±2 quanta between resolutions at one scale; fit artefact vs client
fact is unseparated.

**CITES** — warcraft.wiki.gg *UI scaling* · installed `ElvUI/Core/PixelPerfect.lua` ·
`audit/prior_art_ui_tooling_2026-08-23.md` §5 and §(f) · nine `*__sheet.json` records.

**LANDED IN** — `operations/ROUTER.md` (the row now leads with the community formula and cites it) ·
`ui_sheet_spec.md` · this entry.

**WORD** — Battlewrath, 2026-08-23, as quoted. Taken as a standing correction, not a one-off.

---

## UL-2 · 2026-08-23 · the sheet got a spawner, and the sweep got a command he does not have to remember
**QUESTION** — from conversation: *"If we have the sheet spawner and the sheet reader, and the landed
file (on /reload) on the bench tool - watcher pickup into inbox. Then I'll sweep through a few UI
resolutions."* ⟶ then the requirement that shaped it: *"Spawner and read command / dispatch instruction
in-game. **I get lost writing the test commands manually.**"*

**OUTCOME** — `/coadump r sheet`, **one command, no arguments, the same at every setting.** The run
reads the configuration off the client rather than being told it, so a sweep is two lines repeated:
`/coadump r sheet` · `/reload`. `check_sheet.py` prints those two lines as its own last output, so the
dispatch instruction lives in the tool and the run card is the backup rather than the mechanism.

**REASONING** — [[plays-by-flattening-decisions]]: the load to remove is not typing, it is *deciding
what to type*. An argument he has to get right at each of four resolutions is four chances to record a
configuration under the wrong label, and the label is the whole experiment.

★ **The sheet is SHOWN while it is measured, and that is correctness rather than presentation.** UL-1
measured the never-shown control width as the only captured value off the client's grid — 1.7% out,
the worst kind of wrong. So the host is parented, positioned and visible, and the record says so.
★ Being visible is also the taste half: eleven swatch rows to look at, which no machine can judge.

⚠ **Two things checked rather than assumed, either of which would have failed silently mid-sweep.**
`pull.py` has **no task whitelist** — it keys on the SavedVariables source, so `sheet` lands as
`<runId>__sheet.json` with no change to the watcher. And **agreement is now checked WITHIN a
configuration, never across one**: the first reader compared every run to every other and would have
reported 275 disagreements the moment the sweep began — the alarm firing on the data it exists to
collect. Both branches walked against synthetic records in the scratchpad before he runs anything:
q-fixed, q-moved, and same-configuration disagreement all behave (the last refuses to model, exit 2).

**WHAT THE SWEEP DECIDES** — q moves with the configuration ⟶ device-pixel artefact, rasterisation
size derivable, hinted advances should close the residual. q fixed ⟶ font-engine constant and
"±N q, marked" is final. ★ Either closes it for every future cell kind at once. ⚠ Vary uiScale AND
resolution, not one at a time — they enter the suspected mapping as a product.

**LANDED IN** — `addons/COA_DevDump/task_sheet.lua` + `.toc` · `addons/tools/check_sheet.py` (configs,
per-configuration q, dispatch line) · `addons/planning/sheet_runsheet.md` (the run card).

**WORD** — Battlewrath, 2026-08-23, as above. ⚠ Nothing is deployed or captured yet: `deploy.py` needs
the game closed and the client restarted (new files, not a `/reload`), and both are his.

---

## UL-1 · 2026-08-23 · the width check answered off the shelf, and the sheet became the instrument
**QUESTION** — UL-0 act 1: is offline text "exact" or "±N px, marked"? And then, from him mid-act:
should a **test sheet** in COA_DevDump carry it instead of a one-off run?

**OUTCOME, four parts.**
1. **The client half was already on disk.** UL-0 asks for `GetStringWidth` on ~10 strings.
   `task_geom.lua` has measured **26 strings × 11 font objects** since 2026-08-15 and **seven live
   runs** are in `addons/landing/records/`, all agreeing. No client run was needed for act 1.
2. **The answer is ±N q, MARKED, and N is per font object, not global.** Held-out error: **1 q =
   0.63 UI units on FRIZQT @ 12** (GameFontNormal/Highlight/Red/Disable — the workhorse) up to
   **9 q = 5.65 UI units on FRIZQT @ 10**. Emitted by `check_sheet.py`, not transcribed.
3. **★ Client text widths sit on an integer grid**, q = 0.6275280733 UI units — 275/275 shown
   FontString widths on it. **The never-shown control width is the only captured value off it**,
   which is the geom runsheet's existing *calibrate on a SHOWN frame* ruling reached from a second,
   independent direction.
4. **The sheet supersedes the one-off run**, and `task_geom`'s `reference` section with it.

**REASONING** — his: *"doing it against an active addon only tells you about that addon rather than
a broad insight."* ⟶ the directional rule now in the spec: **calibrate on the sheet, check our panes
with the calibrated model, never the reverse** — the reverse is circular and would read as success.
⟶ and the standard must be **append-only**, or every prior run's numbers stop being comparable with
nothing to flag it. The fit is **held out** (constants from the `calibration` strings, error reported
on the `specimen` strings) because fitting on everything measures the fitter, not the model.

⚠ **Two things the sheet found about itself, both worth more than the verdict.** The FRIZQT @ 10
residual is a **bias, not scatter** — 3–6 q high on nearly every real label, 9 q low on the longest —
so the calibration strings do not represent the letter mix of real labels at that size; the next
append is letter-mix-representative strings, which needs a capture and so is a proposal, not a build.
And **a contaminating value did not announce itself**: the first `derive_quantum` fed the never-shown
width in with the rest, and because any `q/n` also fits a set it silently drove the search to a 5×
finer grid and reported *289/289 on the grid*. It looked like a cleaner answer, not an outlier.

**STILL OPEN, one thing** — q's identity. `1/q` = 1.5936 device px per returned unit while
`uiScale × screenH/768` = 2.2534, so the client's rasterisation pixel size is not the obvious one and
no guess goes here. All seven captures share **one** configuration (uiScale 0.85, 3620×2036), so every
number above is conditional on it. ★ One sheet run at a second uiScale separates a device-pixel
artefact from a font-engine constant — and settles it for every future cell kind at once.

**CITES** — AP-13 (2)(5) · `geom_probe_runsheet.md` Run 1 · `smoke/README.md` (the FontString hole) ·
`prior_art_ui_tooling_2026-08-23.md` §(f) *font metrics offline: nobody has them*.

**LANDED IN** — `addons/COA_DevDump/sheet_decl.lua` (the standard, v1) · `addons/tools/check_sheet.py`
(the diff) · `addons/planning/ui_sheet_spec.md` (the reasoning) · `UI_SEAT.md` (the boundary, below).

**WORD** — Battlewrath, 2026-08-23: the sheet, *"Yes. Once proven we can build on it"*; placement as
sheet two; then *"Build."* ★ And the boundary refined in the same breath: *"Pane in the broad context
is against an active addon. You're free to work on Devdump as part of calibration and knowledge
forming."* ⟶ **this seat may build in COA_DevDump.** Recorded in `UI_SEAT.md`; the panes of a shipping
addon remain the Addon creator's.

---

## UL-0 · 2026-08-23 · the seat opened — first three acts, in order (the architect's, from AP-13; Battlewrath: "Yes")
1. **The width check.** `COA_DevDump task_geom` `GetStringWidth` on ~10 strings vs the offline FreeType widths
   (client font from `Data/enUS/locale-enUS.MPQ`, 12px: "Dungeon Run" = 77). Decides whether offline text is
   "exact" or "±N px, marked". Lands as a row in the smoke README's divergence table either way.
2. **The capture widget** in `COA_DevDump`: hover a control → its measured facts (inset · stack · inline ·
   size parts · type role · surface · border) → pick one → Battlewrath types the why → one record =
   bucket · tier · job · why (+ M3 category on controls). Source vocabulary: `audit/prior_art_ui_vocabulary_2026-08-23.md`.
3. **The census** over the 254 launcher addons, captured geometry first, source second. The registry is
   curated FROM it, with him — never authored cold.
Nothing here is built yet; each act is the Addon creator's to land against this seat's spec, or this seat's
own where it is a tool (`addons/tools/`), on the word.
