# Object — the edit pane

_`object.lua` · `COA_DungeonRunObject` · **240 × 600** · content column x=18, width **204**_

★ **The only surface declared in `panespec.lua`** — and the two are reconciled: `check_interface.py` compares every cell the spec BUILDS against the width and height declared below. ⚠ **This file is the authority**; a difference reads as the spec having drifted, never as this being out of date.

☐ **But the pane is not yet BUILT from it** — every `forms` line below is the hand-positioned code.

⚠⚠ **AND THE DISAGREEMENTS ARE STRUCTURAL, NOT PIXELS.** This line used to say they *"are listed
rather than quietly reconciled"* and then listed none of them. Enumerated now, identity zone,
`panespec.lua` against `object.lua`:

    ORDER     spec  fact -> name -> delete
              code  name (-38) -> fact (-66) -> move+delete (-84)
    PAIRING   spec  pairs `object.name` with `object.move` on one row (0 and 178)
              code  pairs `object.move` with `object.delete` (16 and 150)
    TITLE     the spec has NO row for `object.title` — it was declared to the inventory in §134
              and never to the spec
    COLUMN    code uses 16, 18 and 22 inside one zone; the spec computes every x from 18

★★★ **WHICH SETTLES A SEQUENCING QUESTION.** I had argued the panespec port was the exception to
*content first* — arrangement-neutral, verifiable by re-capturing the same rects. **It is not.**
Building from the spec would visibly rearrange the identity zone, so the port IS a redesign, and
his read was right: *"it's wrapped up in the UI overhaul."*

★ **The spec is a PROPOSAL, not a description** — `panespec.lua` says so in its own header: *"the
arrangement below is a PROPOSAL to be cut about."* Two descriptions of this pane exist and neither
is marked as the intended one, because the intended one has not been decided.

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
object.pane        zone —              row —      span —      kind frame   usage — (the surface itself)
                   does  the pane itself. `set("close")` hides it, `read` reports shown
                   ★ REGISTERED, so a test line can open and close the surface it is testing

object.title       zone identity  row 0  span full   kind readout   usage readout   forms object.lua · `title = f:CreateFontString(`
                   does  ★ NAMES THE SUBJECT, not the surface — "child - in a beacon". It is
                         the one line that says what the rest of the pane is describing
                   ★★ FOUND BY THE REGION WALK (§134) · measured 108.6 × 11.9
object.fact        zone identity  row 1  span full   kind readout   usage readout
                   does  what this object is, in one line
                   ⚠ THE ID WAS INLINED HERE FOR ONE COMMIT (§229) AND MOVED OUT (§230).
                     This text is variable-length, so the id slid left and right with the
                     word in front of it — the opposite of a fixed slot. See `object.id`.
                   numbers w 204 · h 14      forms object.lua · `factLine = f:CreateFontString(`   ⚠ NOT REGISTERED
object.name        zone identity  row 2  span left   kind edit   usage input · identifying      forms object.lua · `nameBox = CreateFrame(`
                   numbers w 170 · h 20      ⚠ build says 192
object.move        zone identity  row 2  span right  kind check   usage arm     forms object.lua · `moveChip = CreateFrame(`
                   ⚠ AN ARM BY CONSTRUCTION, NOT BY NECESSITY. *"We use arm for move
                     because that's how we made it, not that it's optimal. But it works for
                     us. Keep things static until you want to move it."* Unlike `remote.arm`,
                     which is forced by there being no trigger to declare against, this one
                     is a build choice with a principle behind it — and not a precedent.
                   does  arms the MAP to drag this object
                   numbers w 26 · h 20       ⚠ build says 20; template is 32
object.delete      zone identity  row 3  span left   kind button   usage action    forms object.lua · `delBtn = CreateFrame(`
                   numbers w 80 · h 20       ⚠ build says 70

object.role        zone behaviour row 1  span full   kind dropdown   usage selection · dropdown  forms object.lua · `roleDD = CreateFrame(`
                   does  which detector this child uses
                   numbers field 154 · art 204 · h 32   ⚠ build asks 96 → 146 of art
object.match       zone behaviour row 2  span full   kind readout   usage readout   forms object.lua · `roleMatch = f:CreateFontString(nil, "OVERLAY", "GameFontDisa`
                   does  whether another child already claims this role   ⚠ NOT REGISTERED
object.shape       zone behaviour row 3  span full   kind dropdown   usage selection · dropdown  forms object.lua · `shapeDD = CreateFrame(`
                   ⚠ build asks 96
object.reach       zone behaviour row 4  span left   kind edit   usage input · identifying      forms object.lua · `radBox = numBox(`
                   does  the flat radius · code name `radBox` · build says 38
                   set  MIRRORS the OnTextChanged handler — writes the box AND calls
                        Routes.SetChildReach, because SetText alone commits nothing
object.reach.up    zone behaviour row 4  span mid    kind edit   usage input · identifying      forms object.lua · `upBox = numBox(`
                   does  the UPWARD half of the band, and §85 says it is the half that
                         matters — a child on a walkway wants reach for whoever stands ON it
object.reach.down  zone behaviour row 4  span right  kind edit   usage input · identifying      forms object.lua · `downBox = numBox(`
                   does  the downward half
                   ★★ THESE TWO WERE FOUND BY REGISTERING (§131). The row said `reach`
                      and the code has three boxes; nothing could reach the asymmetric
                      half that does the work.
object.action      zone behaviour row 5  span full   kind dropdown   usage selection · dropdown  forms object.lua · `actionDD = CreateFrame(`
                   ⚠⚠ ONE-OF TODAY, MANY-OF IN THE OVERHAUL (§179). This drop-down lets a
                     child do ONE thing - `nothing` or `supertrack`. The tab shape makes each
                     action its own tab, several per child: update notes AND set way tracker
                     AND say LOS. ★ Which is WeakAuras' shape - one trigger, its conditions,
                     and a LIST of actions. See planning/ui_overhaul_scope.md.
object.target      zone behaviour row 6  span full   kind dropdown   usage selection · dropdown  forms object.lua · `targetDD = CreateFrame(`
                   ★★★ POSITION LEADS, LABEL FOLLOWS, ID IS THE FALLBACK (§228). An entry
                     reads `3.  Kill room`, or `4.  child 7` when nothing is typed. The
                     position renumbers on a delete and that is HONEST - a position is what
                     moved. ⚠ It used to read `child 3` with the LOOP INDEX as the name, so
                     an unlabelled child changed what it was called when a SIBLING went.
                     The fallback is `c.id` - never reused - and its gaps are ordinary:
                     *"gap isn't a flaw. Not something to pronounce loudly either."*
                   set  mirrors the menu entry — Routes.SetChildGoTo(beacon, child, id)
                   ⚠ itself is never offered: a cycle of one pins the tracker where you
                     already are, and Routes refuses it
object.childstage  zone identity  row 3  span right  kind edit   usage input · identifying      forms object.lua · `setBox = CreateFrame(`
                   does  the value this child WRITES to the route's stage when satisfied —
                         `Routes.SetChildStage`, gated on `child.role == "set"`
                   ⚠⚠ THE ROW SAID "the CHILD's own stage… ordered against its siblings" AND
                      THAT IS WRONG AGAINST THE CODE (§226). A child has no stage of its own
                      and must not have one: stage is its PARENT's, one hop away through the
                      intrinsic answer, and a copy would go stale on every restage. This is an
                      ACTION PARAMETER, which is config — see the model's address sheets
object.outcome.n   zone behaviour row 5  span right  kind edit   usage input · identifying      forms object.lua · `outcomeBox = CreateFrame(`
                   does  the stage the outcome GOES TO, live only when outcome is "go to stage"
                   ⚠ NOT numeric-only, deliberately: 4.1 is an ordinary stage, and
                     SetNumeric would refuse the decimal that makes insertion non-destructive

object.stage       zone stage     row 1  span left   kind edit   usage input · identifying      forms object.lua · `stageBox = CreateFrame(`
                   ⚠ build says 44
object.stagematch  zone stage     row 1  span right  kind readout   usage readout   forms object.lua · `matchText = f:CreateFontString(nil, "OVERLAY", "GameFontDisa`
                   does  ★ how many other beacons hold this stage. ⚠ A WARNING, not a readout:
                         stage is ORDINAL, so a duplicate costs it its meaning. The fraction is
                         the intended answer - 4.0 and 4.1, never two 4s
                   ⚠ NOT REGISTERED · code name `matchText`
object.outcome     zone stage     row 2  span full   kind dropdown   usage selection · dropdown  forms object.lua · `outcomeDD = CreateFrame(`
                   does  what satisfying this object does to the index
                   ⚠⚠ NOT REGISTERED · build asks 92
object.ramp        zone stage     row 3  span left   kind check   usage selection · tick     forms object.lua · `rampChip = CreateFrame(`
                   does  this object is the on-ramp — come find me
object.unseen      zone stage     row 3  span right  kind check   usage selection · tick     forms object.lua · `unseenChip = CreateFrame(`
object.answers     zone stage     row 4  span full   kind readout   usage readout   forms object.lua · `answersLine = f:CreateFontString(nil, "OVERLAY", "GameFontDi`
                   does  the three answers — on-ramp, note, ratchet
                   ⚠ NOT REGISTERED · hand-placed at a fixed y=-96

object.kids        zone children  row 1  span full   kind readout   usage readout   forms object.lua · `kidText = f:CreateFontString(nil, "OVERLAY", "GameFontDisabl`
                   ⚠ NOT REGISTERED
object.here        zone children  row 2  span left   kind button   usage action    forms object.lua · `hereBtn = CreateFrame(`
object.pick        zone children  row 2  span right  kind button   usage arm    forms object.lua · `pickBtn = CreateFrame(`
                   ⚠ build says 100 for both

object.test        zone footer    row 1  span full   kind readout   usage readout   forms object.lua · `testLine = f:CreateFontString(nil, "OVERLAY", "GameFontDisab`
                   does  ★★★ THE CONTEXT READOUT — one high-contrast space fed by hover or
                         last action, replacing the scattered grey lines
                   ⚠ CONTRAST NOT YET SPECIFIED · hover half not built
                   ⚠⚠ THIS ROW WAS INVISIBLE TO THE CHECKER (§131). It read `(footer)`
                      where every other row reads `zone x`, and the declared-row pattern
                      wants `zone` or `kind` in that position — so the control was in the
                      document, absent from the count, and reported as neither missing
                      nor present. ★ A census is only as wide as the shape it matches.
object.hint        zone footer    row 2  span full   kind readout   usage readout   forms object.lua · `hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSm`
                   does  the standing instruction line, wrapped at 204
object.id          zone footer    row 4  span right  kind readout   usage readout   forms object.lua · `idLine = f:CreateFontString(`
                   does  the object's own ID, and nothing else — `#7`
                   ★★★ A GRAMMAR, NOT A LABEL (§230). *"A grammar of its own identity: the
                     face carries a footnote. Small text, grey on black. But it's ID. Fixed
                     location and inspectable, but not loud."*
                   ★★ THE FIXED POSITION IS WHAT BUYS THE QUIET — a slot the eye has LEARNED
                     is findable at no visual weight, which is the whole trade. So it is
                     never moved, never restyled, and never competes.
                   ★ BOTTOMRIGHT (-14, 10) rather than a computed offset: the pane changes
                     height by subject (113 · 169 · 415 · 575) and the anchor tracks all four
                   ⚠ EMPTY, never hidden, when there is no id — a personal note has none, and
                     a slot that DISAPPEARS is one the eye stops trusting to be there
object.close       zone footer    row 3  span right  kind button   usage action   forms object.lua · `closeBtn = CreateFrame(`
                   does  hides the pane
                   numbers w 60 · h 20, BOTTOMRIGHT (-14, 14)
                   ★ DECLARED IN §133 — it had no row on any surface
```

★ **`setBox` and `outcomeBox` are now `object.childstage` and `object.outcome.n`** (§131) —
justified rather than cut, and the line-number citations that carried this ☐ are gone with it.

☐ **`object.stage`'s setter does not commit.** `set` writes the box and `OnTextChanged` guards on
`userInput`, so a typed line lands the stage in the field and not in the route. Carried forward
knowingly at registration; the fix is to mirror the handler the way the three reach boxes now do.

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

5 items:

- But the pane is not yet BUILT from it — every `forms` line below is the hand-positioned code.
- `object.stage`'s setter does not commit. `set` writes the box and `OnTextChanged` guards on `userInput`, so a typed line lands the stage in the field and not in the route. Carried forward knowingly at registration; the fix is to mirror the handler the way the three reach boxes now do.
- Wire the pane to `panespec.lua` - it is declared and still hand-positioned.
- `object.test` contrast is NOT YET SPECIFIED, and its hover half is not built.
- A beacon that gains a child SWAPS tab 1 for the child roster — each child by name, each with an opacity slider (§225). *"Its tab 1 controls for behaviour is swapped with a child tab."* The beacon's own behaviour tab duplicates the special child, which §219 already says IS that behaviour; the roster is what the slot is worth once children exist. ★ It is also where §224's per-child opacity lives — addressed from the parent, one row per child, never per kind. Design only; the tab stack itself waits on `planning/ui_overhaul_scope.md`.

<!-- OUTSTANDING:END -->

---

☐ **A beacon that gains a child SWAPS tab 1 for the child roster** — each child by name, each with
an opacity slider (§225). *"Its tab 1 controls for behaviour is swapped with a child tab."* The
beacon's own behaviour tab duplicates the special child, which §219 already says IS that behaviour;
the roster is what the slot is worth once children exist. ★ It is also where §224's per-child
opacity lives — addressed from the parent, one row per child, never per kind. Design only; the
tab stack itself waits on `planning/ui_overhaul_scope.md`.

★★★ **THE BEACON HAS AN ID (§227), and the delete addresses it.** It called
`Routes.DeleteBeacon(route, p.stage)` while `routes.lua`:200 deliberately PERMITS duplicate
stages — so two beacons at stage 4 meant deleting the second removed the first, and the pane went
on showing the one you picked. ⚠ It never fired in ordinary use, because stages are normally
distinct; **that made it worse, not better — the trigger was a state the design invites.** Now
`b.id` is minted per route by `nextBeaconId`, monotonic and never reused, and the duplicate case
is a test.

⚠ **AND I OVER-CLAIMED `outcome` IN §226.** I called it a beacon→beacon link. It is not — it sets
an INDEX, and `BeaconAt` resolves at-or-above, which is deliberate: *"what lets an index land on 4
when the route jumps from 3 to 7."* ★ It points at a POSITION ON THE ORDINAL AXIS, not at an
object, so giving it an ID would have broken the gap tolerance it was built for. **The ID's job is
delete, and export handles later. Nothing else today.**

## Hopes and dreams

- ★★★ **`object.action` GROWS — and announce is the next one.**

  > *"There are some fun things we can do with it. Such as letting the addon use chat to announce
  > things. "LOS PULL" when they reach a updater marker / supertracker and such. Or for the user
  > who wanted to taunt - /cast X"*

  Today the dropdown offers **two** values — `nothing` and `supertrack` (*point the tracker*). It
  is the thinnest control on the pane and the one with the most room in it.

  ★★ **ANNOUNCE FITS THE DECOMPOSITION EXACTLY**, which is the test §154 set: the trigger is
  already there (reach a child with a detector), the condition is already there (role, stage),
  and *"say LOS PULL"* is purely the instruction half. Nothing about it asks a user to describe a
  behaviour.

  ★ **And the client already does it.** WeakAuras declares `chat` as a property type with a
  `SendChat` action, beside `sound`, `customcode` and `glowexternal` — so an addon announcing in
  chat is established on this client, not something we would be proving.

  ⚠ **`/cast X` is NOT established and must not be assumed.** ★ A first piece of evidence, and it
  is only evidence: **WeakAuras' own action list has sound, chat, custom code and glow — and no
  cast.** An addon that offers to run arbitrary code on a trigger and still does not offer a cast
  is a strong hint that the client does not permit one. ⚠⚠ A hint is not a finding, and this is
  exactly the shape the macros bench holds absolutely: *any external code lead is an UNVERIFIED
  NAME until confirmed against this client.* ☐ Answerable from the client, whenever it matters.

  ★★★ **AND THE CAPABILITY QUESTION IS MOOT.** *"Even if capable, we might wipe /cast off the
  table. That might fall into bot behaviour. Automated gameplay."* A thing we would not ship does
  not need to be possible — see the model's *we inform, we do not act for the player*. The ☐ above
  stands only if that leaning reverses.

  ⚠ And the boundary is already written: we generate the INPUT CONTRACT, never the consumer's
  HANDLING. If a cast turns out to need a secure button the player presses, that is a *provide*,
  and the shape of the answer changes rather than the answer being no.


- ★★★ **A FACE AND TABS, TAKEN FROM WEAKAURAS.** His shape, 2026-08-16:

  > *"I think object can take a lot from their tabs.*
  > *face: What it is*
  > *Tab 1: Behaviours"*

  ★★ **The FACE is what stays**: the subject's identity, visible whatever tab is open, because
  every tab is describing THAT object and a pane that can forget what it is describing is the
  §63 fault in another coat. The Object pane's `title` already does this job — it names the
  SUBJECT (*"child - in a beacon"*) rather than the surface.

  ★ **And the zones are already the tabs.** The rows carry a `zone` each, and the split falls out
  of what is written rather than out of a new design:

        face        identity   title · fact · name · move · delete · childstage
        Tab 1       behaviour  role · match · shape · reach ×3 · action · target · outcome.n
                    stage      stage · stagematch · outcome · ramp · unseen · answers
        Tab ?       children   kids · here · pick
        Tab ?       footer     test · hint · close

  ⚠ **`behaviour` and `stage` are two zones and one tab**, or two tabs — undecided, and it is a
  real question rather than a formatting one: a beacon's stage is what it ANSWERS, and its
  behaviour is what it DOES. §79 called the outcome *"the whole of what a checkpoint is"*, which
  argues they belong together.

  ⚠ **What tabs cost:** the pane stops showing everything at once, so anything a person compares
  ACROSS tabs has to move to the face or to the readout box. That is a gain, not a loss — it
  forces the question of what is actually being compared — but it is the work, not a side effect.

  ★ Idioms and what each answers: `planning/reference/weakauras_idioms.md`.


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
