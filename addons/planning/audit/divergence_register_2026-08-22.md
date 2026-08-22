# DIVERGENCE REGISTER — the governing set against the shipped code, 2026-08-22

_Analyst (Opus 5), at Battlewrath's ask: **"our task is mainly to state capture the code. Carefully
inspect the governing docs and see where the gap is and how to make both match, expose the
divergence (without alarm) and then push to design or push to addon creator."**_

⚠⚠ **NO ALARM, AND THE STRUCTURE CARRIES THAT RATHER THAN THE TONE.** Every row below is
**two records disagreeing** — not a defect, not a severity, not a ranking. A document written
ahead of its build is the NORMAL state of this project and is listed as such.

★ **AND THE ROUTING RESULT IS THE HEADLINE: almost nothing needed filing.** The bench's RI-58..71
and the architect's AI-14..18 already hold both sides of what the sweep found. **What was genuinely
new was the Analyst's own — three acceptance rows behind the code — and it is corrected.**

---

## THE METHOD, and its one honest limit

**`addons/tools/emit_divergence.py`** (new). It reads the **thirteen** governing documents — the
authority is `DRIVER_BASIS.md`, and the list is read AT RUN TIME out of `check_targets.py` so a
fourth copy cannot drift — and compares them to every identifier and every closed list the product
defines.

    ⚠ IT ANSWERS A NAMING QUESTION AND NOTHING MORE.
      IT CAN SAY      does the governing set MENTION this · does the code DEFINE it
      IT CANNOT SAY   is it CALLED · reachable · correct · needed

★ That limit is deliberate. §497 measured `emit_built_state`'s STRANDED bucket **47% wrong**
because a name search was answering a question about USE. [[a-name-is-not-a-use]] is not violated
by asking whether a name appears — only by concluding use from the answer. **Nothing here
concludes use.**

⟶ **The gap it closes:** `emit_built_state` reads the FIVE acceptance briefs. The other eight
governing documents — the data model, the programmatic model, scoping, the user journey, ROUTER —
**were read by no tool we own.**

---

## AXIS 1 · IDENTIFIERS — **the two records agree**

    373 identifiers defined in the product
    13 governing documents read
    ⟶ LIVE DIVERGENCES: 0

Eleven candidates surfaced and every one resolved to a record rather than a disagreement:

    19  HEADSTONED     named only inside a retirement note. `Rule.OPEN`, `Routes.SetChildFireOn`,
                       `Routes.Place`, `Adaptor.Codes` and fifteen more. ★ `rule.lua` itself opens
                       *"THERE IS NO `Rule.OPEN`, AND ITS ABSENCE IS THE POINT."*
     4  EXTERNAL       `SuperTrackerUtil.*` (the client), `Beacon.Clear` (COA_Landmarks),
                       `AscensionUI.DeathRecap` (the fork), `Private.ScanEvents` (WeakAuras).
                       **Named by our docs, not ours to define.**
     2  READ BY HAND   `Driver.Promote` and one further `Rule.OPEN` mention sit outside the
                       three-line marker window but read as records of the gap, not claims.

★★ **THIS IS A GOOD RESULT AND IT IS WORTH STATING PLAINLY:** on the identifier axis the governing
set and the code do not diverge. ⟶ Which is what told the sweep to look somewhere else.

---

## AXIS 2 · VOCABULARY — the fourteen closed lists, captured

    Routes.SENSE_WORDS      whenOn · seen · whenOff
    Routes.ROW_ACTIONS      boss · note · say
    Routes.ROW_ARG          name · content
    Routes.ROW_ARG_RULE     per action: type · source · max
    Routes.NEXT_TYPES       step · stage · set
    Routes.TRIGGERS         once · every
    Routes.ROLES            start · update · complete · set
    Routes.SHAPES           radius · wire
    Routes.ACTIONS          supertrack
    Contract.ADDRESS / BEHAVIOUR / CHARACTERISTIC / COMPOSED
    Spec.SUBJECTS           beacon · child · note · none

### ⟶ ONE LIVE DIVERGENCE, and the bench has it — this adds a sentence, not an item

**`Routes.ACTIONS = { supertrack }` sits beside `Routes.ROW_ACTIONS = { boss, note, say }`.**
Disjoint, same file. `supertrack` is the word **AL-19 retired as an action** (it became the LED TO
tick, a characteristic).

★★ **THE SENTENCE WORTH ADDING:** `Routes.ACTIONS` is **correct as the migration's source and
wrong as the authoring gate.** `migrateNode` must read the old flat vocabulary — that is what a
migration IS — while `Routes.SetChildAction` gates the *authoring door* on the same table, so the
pane writes the retired word by construction. ⟶ **One table, two jobs, and only one of them is
still valid.**

⬜ **ROUTED TO: nobody new.** `RI-58` already carries the pane half. This register adds only that
the two-vocabulary shape is now **mechanically visible**, so it cannot quietly return.

---

## AXIS 3 · DOC BEHIND CODE — **the Analyst's own, and the only thing that needed fixing**

The sweep's real yield, and it points at me rather than at either bench:

    Routes.TRIGGERS = { once, every }     ✅ SHIPPED, with a setter that refuses anything else
    Routes.NEXT_TYPES = { step, stage, set }  ✅ SHIPPED, writing `child.nextType`

**Three acceptance rows still said these were unbuilt**, written 2026-08-21 and true when written:

    A12.4b   *"the code term is the bench's"*                    → the bench took it: `once | every`
    A12.4e   *"WRITTEN AHEAD … no code term is chosen"*        → the vocabulary exists
    A12.5c   *"⚠ NEW FIELD: nextType/nextArg join the store"*    → they have joined

✅ **All three corrected 2026-08-22.** ⚠ And the direction matters: this is the MIRROR of the
2026-08-21 staleness sweep, which found the docs claiming things were **built** that were not.
★ **Acceptance can be wrong in both directions, and only a tool that reads both records at once
sees the second one.**

---

## AXIS 4 · EXTERNAL DEPENDENCIES — named by our docs, owned by nobody here

`SuperTrackerUtil.SetSuperTrackedPosition` · `ClearSuperTrackedPosition` · `Beacon.Clear` ·
`AscensionUI.DeathRecap` · `Private.ScanEvents`.

⬜ **ROUTED TO: `RI-71`**, which already says `SuperTrackerUtil` is *assumed, never verified on
this fork*. The register's contribution is that the class now has a name and a count, so the next
external dependency is visible the day a document names it.

---

## ⟶ WHERE IT ROUTES, in one place

    DESIGN     nothing new. **AI-15** already asks the vocabulary question at the level that
               matters (*how much of this language must an author hold*) — narrower items would
               be a second copy of it.
    CREATOR    nothing new. **RI-58** holds the `ACTIONS`-as-authoring-gate half; **RI-71** holds
               the external verification.
    ANALYST    ✅ done: the three stale rows above.

★ **Checking before filing is what produced that**, and it is the standing rule
([[the-basis-includes-the-other-benches]]): grep this repo before raising it, because another
bench has often already answered it. **Both had.**

---

## ⚠ THE TOOL'S OWN DEFECTS, found by running it and kept in its header

Three, and each would have put a false row in this register:

    1  IT READ 8 OF 13 GOVERNING DOCS.  The tuple parse stopped at the first `)`, which is inside
       a comment reading *"(2026-08-18)"*. ★ A scope that silently excluded five governing
       documents — **in the tool written to find exactly that.**
    2  IT KNEW ONE SHAPE OF DEFINITION. `= function` only, so `Bucket.BAND_DEFAULT` (a number),
       `Bucket.Resolve` (a deliberate `nil` seam) and `Routes.ROW_ARG_RULE` (a table) all read as
       "the doc names it, the code lacks it".
    3  IT COULD NOT READ A HEADSTONE.   19 identifiers named only inside retirement notes read as
       divergences. ⟶ Fixed by READING `check_retired.py`'s marker vocabulary and window rather
       than restating them, so there is ONE definition of *this text records a retirement*.

★★ **Had this shipped unrun, the register would have opened with eleven divergences and nine of
them would have been the tool.** That is the argument for running a checker against the real corpus
before believing it — and for [[wrong-isnt-failure-emit-dont-interpret]]: emitting made all three
visible in one pass.

## ⚠ WHAT THIS SWEEP DID NOT CHECK — an absence here is not a clean bill

    · BEHAVIOUR. Whether a function does what its governing doc says is a READ, not a name match.
    · PROSE claims with no identifier and no closed list attached.
    · The 315 CODE-AHEAD identifiers, printed per namespace rather than per function. A namespace
      no governing document names is the finding; a helper inside a governed one is not.
    · `audit/` and `history/` — records, deliberately excluded.
