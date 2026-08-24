# CONCEPT HOME · `input commit` — when typing becomes a record

_A HOME is an INDEX, never a second copy (AL-26). It says what the concept IS, its closed list, and
POINTS at every place that rules or grades it. Opened 2026-08-23 by the UI specialist. ⚠ **Written
on a BLANK SLATE, at Battlewrath's instruction:** *"Our prior work doesn't factor into decisions.
This seat and our work is part of the UI overhaul. So we get to have a blank slate and we'll
retrofit where needed."* Existing DungeonRun and Landmarks handling is EVIDENCE here, never
constraint._

## WHAT IT IS
The rule for how a text field turns keystrokes into a written record — as **one repeatable unit**,
identical on every field and every surface, rather than a decision each field makes for itself.

> **`OnTextChanged` tells the USER. `OnEnterPressed` tells the RECORD.**

That single separation is the whole grammar. Live feedback — validation, a count, a colour — rides
the advisory event and never touches the record.

## ★★ THE BASE IS ACE'S NATIVE HANDLING, UNMODIFIED
Battlewrath, 2026-08-23: *"I would lean on Ace's native handling, as this is form most likely
observed in other addons so matches user expectation."* ★ Measured against the source, his three
rulings need **no change to Ace at all** — they are already what it does.

    TYPE, text differs      the accept button APPEARS, and `SetTextInsets(0,20,3,3)` reserves its
                            space so it never sits on the text.  AceGUIWidget-EditBox.lua:96-104
    ENTER                   fires `OnEnterPressed(value)`; the handler may CANCEL, and if it does
                            the button stays and the field stays dirty.  :66-73
    ACCEPT BUTTON           `ClearFocus()` then the same Enter path.  :106-110
    ESCAPE                  `AceGUI:ClearFocus()` — no revert, no commit.  :62-64
    FOCUS LOSS              nothing. The edit STAYS PENDING.  (his ruling; and Ace's behaviour)
    PROGRAMMATIC SetText    hides the button.  :146
    THE BUTTON IS ON        `OnAcquire` calls `DisableButton(false)`.  :122

⚠ **AceConfigDialog never binds `OnTextChanged`** — only `OnEnterPressed` → `ActivateControl`
(`AceConfigDialog-3.0.lua:1130`). So an option's `set` runs **once per commit**, never per keystroke.

★★★ **WHICH MEANS THE HAZARD DOES NOT EXIST HERE, RATHER THAN BEING GUARDED.** No
`OnTextChanged`→write means no refresh→SetText→refresh loop to defend against — with a comparison,
with a `userInput` flag, or at all. ⟶ The DungeonRun evidence is what made this legible: its stall
was never the loop, it was `refresh()` on every keystroke (`object.lua:681`). This grammar cannot
reach that state.

## HIS RULINGS, 2026-08-23
    commit partial on focus loss    NO  — "I would avoid commit partial."
    discard on focus loss           NO  — "Discard feels clunky."
    stay pending                    YES — and it is Ace's own behaviour, for Escape too.

## THE SECOND ACT — sourced from WeakAuras, and it is NOT a field variant
His instruction: *"On the sensitive. I'd look at what WA does for second act accept. Rather than
going on my invention."* ⚠ It corrected mine as well: I had proposed a sensitive field that refuses
its own first commit, so the pending state doubles as the confirmation. **WA does nothing of the
kind.**

★★ **WeakAuras confirms destructive acts with the client's own `StaticPopupDialogs`, and its text
inputs carry no extra ceremony at all.** The option table's `confirm` key exists in AceConfig and WA
uses it **once** in the entire addon (`AuthorOptions.lua:2196`, Delete Entry). Everything that
matters goes through a popup — `WEAKAURAS_CONFIRM_DELETE`, `WEAKAURAS_CONFIRM_TRIGGER_DELETE`,
`WEAKAURAS_CONFIRM_REPAIR`.

⟶ So the second act attaches to an **ACTION**, never to a field. Text editing is uniformly plain.

### The popup's shape, from two instances that agree
    text        BUILT PER CALL, and it states the SCOPE and the IRREVERSIBILITY:
                "You are about to delete %d aura(s). |cFFFF0000This cannot be undone!|r
                 Would you like to continue?"          WeakAurasOptions.lua:485
    button1     THE ACT — "Delete". Never "OK".        :443
    button2     "Cancel"
    OnAccept    does the work, reading its payload from `self.data`
    OnCancel    clears `self.data`
    data        passed as StaticPopup_Show's 4th argument — no global state.  :487
    timeout     0 — a destructive confirm must NOT expire out from under you
    showAlert   1 — the alert icon carries the weight
    whileDead   1 · preferredindex 4
    re-entry    `WEAKAURAS_CONFIRM_TRIGGER_DELETE` holds a `triggerDeleteDialogOpen` flag so the
                dialog cannot stack.  TriggerOptions.lua:398

## THE KINDS
Two were proposed and one collapsed; what survives is **one input kind**.

    plain       Ace native, unmodified. EVERY text field. There is no second input kind, because
                WA has none and the affordance it would have added is already on by default.
    (action)    NOT an input kind. A destructive ACT is an `execute` guarded by a StaticPopup of
                the shape above. It lives on the action, not on the field that fed it.

★ A "guarded" kind for expensive downstream writes was dropped: Ace never writes live, so the case
cannot arise.

## WHERE IT IS RULED (read these; this page only points)
    Libs/AceGUI-3.0/widgets/AceGUIWidget-EditBox.lua   the grammar itself, lines cited above
    Libs/AceConfig-3.0/.../AceConfigDialog-3.0.lua     :1118-1135 the input branch · :571 confirmPopup
    audit/ui_wa_grammar.md                             the option-table grammar; `confirm` = 1 use
    WeakAurasOptions/WeakAurasOptions.lua               :441-487 the delete popup and its builder
    WeakAurasOptions/TriggerOptions.lua                 :380-398 the second instance, and its re-entry flag
    concepts/art-and-rect.md                            the neighbouring concept; the accept button's
                                                        20px inset is a rect fact, not an art one

## WHAT IS OWED — derive it; never read it here
Nothing is built against this yet. The `behaviour` sheet kind is the intended proof: capture the
event sequence per widget so the grammar is MEASURED per control rather than assumed from one
widget's source, and a control that behaves differently appears as a row instead of as a bug someone
finds later.

⚠ Deliberately NOT settled, so nobody reads a decision into this page:
- whether the advisory `OnTextChanged` feedback is a colour, a border, a count, or nothing. His
  *"Highlight react?"* is an open question, not a ruling.
- how existing DungeonRun and Landmarks fields are retrofitted, and when. Blank slate for the
  overhaul; the retrofit is a separate decision with its own cost.

---

## ★ COMMIT FEEDBACK — added 2026-08-24, on his ruling
> *"I think notification should be non-alarming. Not dramatic. Maybe a green indicator next to the
> input field... A tick within the box?"* — Battlewrath, closing a question he first asked on
> 2026-08-23 (*"Some feedback on the text input field. (Highlight react?)"*).

**IT IS MOSTLY ALREADY BUILT.** `AceGUIWidget-EditBox.lua:66-73` plays a soft sound and HIDES the
accept button on a successful `OnEnterPressed`; a handler that returns truthy (`cancel`) leaves the
button up and plays nothing. ⟶ Pending = the button is there. Committed = it is gone. Refused = it
stays. **Three states already, and none of them flashes.**

⚠ **The one decision:** the button sits at `RIGHT, -2, 0`, 40 × 20 — the same slot a tick would
occupy. One slot, three states, no layout movement. A green outline around the whole box is the
louder alternative, and it reads as a state of the FIELD rather than an event that happened.

★ The colour, the art and the linger are TOKENS and belong to the registry, not to this page.
Full shape: `planning/ui_panespec_borrows_spec.md` §4.

## ★★★ THE BLINKING CURSOR — the asymmetry, 2026-08-24
`AceGUIWidget-EditBox.lua`: the accept BUTTON clears focus then commits (`:108-109`); **Enter commits
and does not** (`:66-73`). Same commit, two end states — the mouse path finishes the field and the
keyboard path leaves the cursor blinking, which reads as *still editing*.
⟶ **COMMITTED must clear the focus.** Four states: UNTOUCHED · PENDING (button shown, userInput
only) · COMMITTED (sound · button gone · focus cleared) · REFUSED (button stays, `cancel` truthy).
⚠ Fixed in OUR handler; nothing needs forking.

★★ **And what a commit indicator MAY CLAIM is bounded** (his, same day): our proof is delayed, so it
means **STORED**, never **CORRECT**. Receipt · resolution · effect are three tiers, and only the first
is available at commit time — the third lives on the remote's Test drive tab.

## ★★★ IT WAS A METAPHOR — the law, and the EditBox is only its first instance
> *"It was also a metaphore. A terminal input that gives no response when a command is sent leaves
> you wondering."* — Battlewrath, 2026-08-24

⟶ **AN ACTION WITH NO ANSWER IS INDISTINGUISHABLE FROM ONE THAT FAILED.** Not a property of edit
boxes; a property of anything a person sets in motion.

★ And the metaphor carries its own shape. A terminal that DOES answer gives three things, and each
has a counterpart here:

    ECHO         the command is still on screen        the value stays visible in the field
    NEW PROMPT   you may go on                         the pending marker clears · the cursor STOPS
    ERROR        it did not work, and why              the refusal path, which persists

★★ **The `ClearFocus` asymmetry above is the NEW PROMPT missing** — the echo was there and the error
path was there, and the one thing absent was *you may go on*. Which is why the box felt unanswered
while technically having answered.

### ⚠ WHERE ELSE THE SAME QUESTION APPLIES — candidates, UNCHECKED
Named so they can be asked, not asserted as faults. None has been measured:

    Create beacon · Pin here · Arm · Drive     buttons that DO something
    object.delete                              already ruled *"irreversible - warns before"*
    a dropdown selection                       the value changes; is that answer enough?
    a map click that places a node             the pin appears - which IS the echo
    Promotion's `0 beacons · 1 personal note here`   ★ already an answer, and a good one

★ Several of ours already answer by SHOWING THE RESULT — the pin, the count, the tells. The law is
not "add indicators"; it is **no action ends in silence**, and where the result is already visible
that is the answer.

⚠⚠ **AND THE BOUND FROM THE SAME CONVERSATION STILL HOLDS:** the answer may only claim what it knows.
**STORED, never CORRECT.** Our proof is delayed; the effect tier lives on the remote's Test drive tab.

## ★★ THE RESPONSE AREA — reserved, hidden by default (his, 2026-08-24)
> *"reserve discrete label space for 'Saved (Green tick)'... Hidden by default. But a response area."*

★ **Reserved-and-hidden is the point**: budgeted always, drawn sometimes, so **nothing moves in any
state**. The opposite of §571's tell-collapse, which resized the pane under the cursor.
★ It also dissolves the tick-versus-accept-button collision: the button keeps the inside-right slot
(`RIGHT, -2, 0`), the response lives outside it.

⚠ **Measured tension:** the row-to-row gap is **8** and one line at size 10 is **9.92** (`UL-10`), so a
label riding the top edge overlaps the row above — F·29's fault in a new place. The variant the
numbers allow is the row's OWN band, in reserved WIDTH (§1's units). **His to rule; full shape at
`planning/ui_panespec_borrows_spec.md` §4.**

## ★★★ WHY THE BUTTON EXISTS — confirmed from source, 2026-08-24
Battlewrath's hypothesis: *"maybe for multi-line text where enter to step the input row would also
register as accept. And that's why they use the botton."* ⟶ **Right.**
`AceGUIWidget-WeakAurasMultiLineEditBox.lua:367` sets `SetMultiLine(true)`, `:374` binds only
`OnEscapePressed`, and there is **no `OnEnterPressed` script on the editbox at all** — the commit is
raised by the button (`:60`, `:330`). Enter inserts a newline, so it cannot commit.

    MULTI-LINE    button REQUIRED - Enter is taken by the text
    SINGLE-LINE   button OPTIONAL - Enter commits

⚠⚠ **Not vestigial on a single line, though:** the button is the MOUSE commit path
(`AceGUIWidget-EditBox.lua:108-109`, `ClearFocus()` then commit). Removing it makes commit
keyboard-only — a product decision, not a cleanup.
