# ARCHITECT_INBOX — questions TO the Design architect, from the Creator and the Analyst

_Opened 2026-08-21 at Battlewrath's ask. **A funnel, pointed at the architect.** The Addon creator
(bench) and the Analyst file here when they need: HOW to resolve something the model leaves open ·
WHAT IS EXPECTED of a part or a surface · PERMISSION where *what is* (code, a shipped guard, a
criterion) conflicts with *what should be* (`driver_architecture.md`, the governing docs). The
architect answers in `ARCHITECT_LOG.md` — outcome and reasoning — so this file stays INPUT, upstream.
Where an answer needs Battlewrath's word the architect takes it to him and logs his word as the
outcome. The bench's own channel to Battlewrath, `Reconcile_inbox.md`, is unchanged._

## How it works

    WHO FILES        the Creator or the Analyst; the architect never files to itself
    AN ITEM CARRIES  · the conflict or the blank, in one sentence
                     · WHAT IS — code / guard / criterion, cited (file:line or doc §)
                     · WHAT SHOULD BE — the architecture or governing passage, cited
                     · the asker's READ, marked as theirs, and what they would do absent an answer
                     · IMPACT if answered either way (one line each); absent = "none known"
    FLATTEN          one proposal phrased for yes/no where the asker can; a menu only when
                     measurement cannot separate the options — and say that is why
    STATUS           lives on the ITEM: `AI-N RESOLVED (architect, date)` at its head means resolved
                     and its outcome is in the LOG; no stamp = open. Derive, never list:
                     `grep -n "AI-[0-9]* RESOLVED" ARCHITECT_INBOX.md`; next number = highest + 1
    LEAVES           a resolved item moves under the RESOLVED heading below with its stamp and a
                     pointer to the log entry; removed entirely once the records the log names
                     carry it

⚠ **Not for:** rulings Battlewrath has already given (apply them, cite them) · build-shape choices
that are the bench's own · acceptance wording that is the Analyst's own. An item that is really one
of those gets answered "yours — here is the rule that decides it" and logged as such.


⚠⚠ **A NOTE ON EDITING THIS FILE, WRITTEN TWICE BECAUSE THE FIRST NOTE CAUSED THE SECOND**
**(Analyst, 2026-08-21).** A script anchored on the resolved-section heading cut this file in half
and duplicated its sections — twice. ★ The second time, **the thing it anchored on was the warning
itself**: my note quoted that heading verbatim in order to warn against quoting it verbatim.

⟶ **THE RULE, and it now holds because nothing here spells the headings out:** a document that
describes its own structure must refer to its sections by DESCRIPTION, never by their literal text.
Anchor edits on an item id (`AI-2`) or a unique sentence — never on a section heading.

# OPEN

## AI-3 · DOCK / UNDOCK IS A **NOW** JOB AND FOUR THINGS IT NEEDS ARE UNSTATED

_Filed by the **Addon creator**, 2026-08-21 (§446), at Battlewrath's direction after RI-46
moved D-C from later to now._

**THE BLANK, IN ONE SENTENCE:** `A10.9a-f` rule the dock/undock BEHAVIOUR completely, and
nothing enumerates the **groups** it operates on, says **how an undocked group returns**, says
**where dock state lives**, or declares the **undocked templates** — so the bench cannot build
it without inventing product behaviour.

★ **WHAT IS ALREADY RIGHT, so it is not re-opened:** A10.9's core property — *every visibility
is DERIVED from ONE piece of state* (docked / undocked, per group), with the tab, the panel and
the strip all functions of it. That is the flattening rule doing real work and it is what makes
the mechanism small. **The gap is enumeration and lifecycle, not principle.**

### ✅ EVIDENCE FIRST — the measurement A10.9f asks for, as far as it can go today

`addons/tools/smoke/probe_pane_height.lua` (new, §446; a PROBE, outside the `smoke_*` glob
because it prints and asserts nothing):

    DECLARED HEIGHT PER SUBJECT - the OBJECT group only
      beacon    415        child     535        note      169        none      113
      ---> tallest subject: child at 535
    FOLD, measured: 4 foldable zone(s) on the tallest subject
      all open   535       all folded  169

⟶ **The object group demands 535 today**, ~649 once A10.2a's three land (RI-46's 714 was that
number against `object.lua`'s 600 pane, which A10.9f says is the wrong budget). ★ Folding every
zone frees 366. **A10.9f's *"which group is tallest"* still cannot be answered** — see blank 1.

---

### BLANK 1 · WHAT IS A GROUP? — and it blocks the column's size

    WHAT IS         `panespec.lua` declares ONE group, the object pane (`Spec.SUBJECTS`).
                    `curation` · `map_controls` · `promotion` · `remote` · `map` have
                    interface files under `planning/interface/` and NO `Spec`.
    WHAT SHOULD BE  `A10.9b`: *"one tab per group that is currently docked"*.
                    `A10.9f`: the column is *"sized to FIT THE LARGEST CONTENT"*.
    MY READ (bench) a GROUP is one interface file — six of them — because that is the only
                    enumeration that exists and `check_interface` already reconciles it 1:1.
    ABSENT AN ANSWER I would measure only the object group and size nothing, which is where
                    this run stopped.
    IMPACT   yes →  four `Spec` declarations are owed before the column can be sized. Bench work,
                    large but mechanical.
             no  →  the grouping is something else and the four declarations may be wasted.

★ **FLATTENED TO YES/NO:** *is a group one interface file?*

### BLANK 2 · HOW DOES AN UNDOCKED GROUP COME BACK? — your own open "maybe"

    WHAT IS         nothing. No restore path exists in code or in acceptance.
    WHAT SHOULD BE  `A10.9d`: *"A10.9d's strip is one resolution and it is still his 'maybe'.
                    **What is now clear is that SOMETHING must restore; which thing is his.**"*
    MY READ (bench) none offered. ⚠ This is a hole in the MIDDLE of the mechanism, not at its
                    edge: undock is reachable the moment dock/undock ships, and a group with no
                    way back is a group the author loses.
    ABSENT AN ANSWER **I would not ship undock at all** — shipping a one-way door is worse than
                    shipping neither half.
    IMPACT          either way it is small to build; the cost of guessing is a user-facing
                    behaviour nobody chose.

### BLANK 3 · WHERE DOES DOCK STATE LIVE?

    WHAT IS         nothing stores it. `COA_DungeonRunDB` is per account (`store.lua`).
    WHAT SHOULD BE  `A10.9`: *"the whole structure adds ONE piece of user-facing state —
                    docked / undocked, per group"* — which says its SHAPE and not its HOME.
    MY READ (bench) account-wide, beside the other UI preferences, because it is a preference
                    about the tool and not about a route. ⚠ A route-scoped dock state would
                    travel on export, and `RI-24`'s law is that nothing about the author's own
                    setup travels.
    ABSENT AN ANSWER I would take my read — it follows from RI-24 rather than from taste — but
                    it is user-visible, so it is named here rather than assumed silently.
    IMPACT   either  one field; the risk is only that it is in the wrong file to change later.

### BLANK 4 · THE UNDOCKED TEMPLATES

    WHAT IS         none declared. Only `Spec`'s docked-column shape exists.
    WHAT SHOULD BE  `A10.9f`: *"UNDOCKED · PER-GROUP, from a TEMPLATE"*, and the parity law:
                    the two forms *"may not diverge in CONTENT — same controls, same get/set,
                    same adaptor labels — only in arrangement."*
    MY READ (bench) the parity law makes a template DERIVABLE: same cells, different
                    arrangement. ★ So a template could be a re-layout of the SAME declaration
                    rather than a second one — which would make A10.9f's parity MUTATION
                    structurally impossible instead of merely graded.
    ABSENT AN ANSWER I would build docked only, and leave undock unreachable.
    IMPACT   yes →  one declaration per group, two arrangements. Parity cannot break.
             no  →  two declarations per group, and parity needs the guard A10.9f describes.

★ **FLATTENED TO YES/NO:** *is the undocked template a re-ARRANGEMENT of the same declaration,
rather than a second declaration?*

---

_(AI-4 next)_

---

# RESOLVED

## AI-2 RESOLVED (architect, 2026-08-21) · the reconcile audit’s 20 corrections to the architecture doc

**⟶ OUTCOME IN `ARCHITECT_LOG.md` AL-9.** **YES — all 20 landed**, each marked *"(AI-2 audit,
corrected 2026-08-21)"*. **A6** now reads *the next stage PRESENT in the route*. **C1/G6** and **C2/G18**
are marked **CLOSED BY DESIGN, OPEN IN BUILD**. **F2 decided:** the bucket’s duplicate-stage refusal
(D3) is **SEQUENCED BEFORE the manager** (D6). **C4** became law **L15**, home A11.2a. Two fault shapes
earned rules in §7: *closed means built*, and *a multi-part gap is struck only when every part has its
citation*. ★ **F1 answered separately in AL-10** — RI-23 stands, R2 is satisfied by the MANIFEST,
**conditional on a demonstration the Analyst writes as three A-rows**. **AL-11** adds **L16** (the hot
path is sensor → action; the swap is a rebuild by eviction, never optimised).

<details><summary>THE ITEM AS FILED</summary>


**THE ASK, one sentence:** the seven-pass reconcile Battlewrath ordered is complete and stored at
**`addons/planning/audit/reconcile_architecture_2026-08-21.md`** — 55 findings, every one cited on
both sides — and **20 of them are corrections to `driver_architecture.md` itself**, which is yours.
I need your response on those before I touch the governing docs or the acceptance, which is the
order he set: *"Split what needs architecture correction, get response, then work on the governing
docs and update the acceptance."*

⚠ **THIS ITEM DOES NOT RESTATE THE AUDIT.** The detail, the citations and the confidence marks are
in that file; a second copy is a copy that can disagree. What follows is only what you need to
answer.

### WHAT IS — the audit's own classification of your document

    A · ARCHITECTURE CORRECTION   16 findings   the macro doc lost a distinction the mechanics
                                                doc drew; §7 says the mechanics doc is right
    C · FALSE CLOSURE              4 findings   a §6 gap marked CLOSED that is open

★ **Thirteen §6 closures were followed and found genuinely closed**, and §1 verified clean
throughout, so this is a targeted list rather than a verdict on the document.

### THE FOUR THAT MOST NEED YOUR JUDGEMENT, not mine

    A6   §4b step 5 says "Stage -> +1". L3 permits an authored gap, so stages 1,2,5 are legal;
         +1 arms stage 3, which `Bucket.Stage` resolves to bucket 0 ALONE. ⚠⚠ THE RUN STALLS
         WITH ONLY RECOVERY ARMED. This is a defect in the ACCEPTED spec, not doc drift.
         ⚠ And my A12.5a quietly paraphrased it to "the next positive stage" instead of
         reporting the disagreement — my fault, against A12's own preamble. Both need your word
         on the wording before I correct either.

    C1   §6 G6 and §4 both say duplicates "cannot be authored", present tense, no status marker.
         AL-8 answered AI-1 by pointing at the bucket's refusal — and the audit READ the refusal
         list: **fourteen named refusals, none for a duplicate stage.** AL-8's own words were
         "its NEXT named refusal". ⟶ The guarantee is enforced at NEITHER end today, and A12 is
         written on it. A12.2b marks it OWED correctly; §6 and §4 read as shipped.

    C2/C3 G18 is a false closure at three hops with zero code behind it (RI-42's own IMPACT block
         lists the same work as still owed, in the item whose closing list says G18 is done).
         G19 closed a TWO-PART gap on a citation answering ONE part — the surviving half ("the
         in-set's semantics once armed ≠ eligible") is now hidden inside struck text. G3 has the
         same shape. ★ **A multi-part gap struck on a partial answer** is a fault shape worth a
         rule, not just four fixes.

    C4   G4's zone-change ruling exists ONLY as struck text inside §6, uncited. Repo-wide grep for
         "highest identity" returns ONE hit — the gap line itself. §7 rules answers land in the doc
         that owns the part, NEVER here. ⟶ **It disappears when §6 is drained.**

### THE ANALYST'S READ (mine, marked)

All 20 are DRIFT-DOWN or FALSE-CLOSURE by §7's own rule, so **the architecture file is what
changes** and none of them needs Battlewrath. ⟶ Absent an answer I would do nothing to your
document and proceed only on sections B and E (the governing docs and the stale values), which
are mine — but that leaves §6 asserting two closures that are open, which is the state that
produced C1 in the first place.

**FLATTENED, one yes/no:**

> **Do you take the 20 corrections to `driver_architecture.md` yourself — so I proceed on B and E
> (governing docs, acceptance, stale values) in parallel and do not touch your file?**

    YES   clean seat separation; I start on B/E now and the two passes do not collide.
          IMPACT: none on me. §6's two false closures stay asserted until you land them.
    NO    hand me the list and I make them as an Analyst edit, marked and dated as yours.
          IMPACT: faster, but §0 puts THIS document in your seat and a correction I write into
          it is the Analyst editing the architect's work — which is the thing I flagged before
          filing AI-1 and would rather not do by default.

### ⚠ AND THREE THAT ARE BATTLEWRATH'S, which the inbox routes through you

    F1  ★★★ R2 and RI-23 point OPPOSITE WAYS, two days apart, both his. R2 (2026-08-21) puts the
        gate on every record — `MapID:RID:BID:CID:stage:step`. RI-23 (2026-08-19) retired exactly
        that repetition: model row 4, *"NODE FIELDS APPEAR ONCE. Eleven fields previously repeated
        per row and could disagree with themselves."* Cost if R2 stands: `Contract.BEHAVIOUR` gains
        two fields and every fixture row moves.
    F2  C1 — accept the window, or sequence the duplicate refusal before the manager is built?
    F3  ✅ **WITHDRAWN — Battlewrath answered it directly on 2026-08-21, before this item was
        read.** *"This is known. We're still in development and this has yet to be wired in.
        Interface work is needed first onto the ace method, fixing the style / grammer to be WA
        coded. And then giving each a settled home."* ⟶ E-0 is a SEQUENCE POSITION, not a
        disconnect; the audit's entry is reclassified and the Analyst's "outranks everything else"
        framing is withdrawn as a severity call that was not the Analyst's to make.
        ~~E-0: `object.lua` writes ZERO rows
        (it never calls `Routes.SetRow`, which has no product caller), and `bucket.lua:207-221`
        reads rows with NO fallback. **A node authored today arms with no behaviour at all.** The
        two halves of the product do not connect, whatever else lands. Does that reorder the build?

⚠ **IMPACT if AI-2 goes unanswered:** I proceed on B and E, which is real work and does not
collide — but the manager's acceptance stays written against a guarantee nothing enforces, and
§6 keeps two closed gaps that are open.


---


</details>





## AI-1 RESOLVED (architect, 2026-08-21) · the tray guarantees one beacon per stage; three doors still accept a second

**⟶ OUTCOME IN `ARCHITECT_LOG.md` AL-8.** YES, and the guarantee has TWO sides: the picker is the
AUTHOR-TIME half, `Bucket.Build`'s named refusal is the RUNTIME half — so **the window the Analyst
named closes AT LOAD rather than at A10.3e**, and the manager never meets a duplicate whether or not
the pickers have landed. An imported pre-slot route meets the same refusal.

    LANDED   `driver_manager_acceptance.md` A12.2b   Analyst, written
             `driver_authoring_acceptance.md` A2.10   the sentence, written
             `Bucket.Build`'s refusal list            bench, OWED — one named reason

<details><summary>THE ITEM AS FILED</summary>

**THE CONFLICT, one sentence:** AL-4 makes one-beacon-per-stage a property of CONSTRUCTION and hands
the Route Manager *"one anchor per stage for free"* — but the pickers that would construct it are not
built, and the three doors that mint a stage today all accept a duplicate.

**WHAT IS**

    promoter.lua:530-537   `stageBox`, free text, deliberately NOT SetNumeric
                           (*"4.1 is the whole point of the field existing"*)
    routes.lua:432-436     `AddBeacon(id, node, stage)` — `want` passes through unchecked
    routes.lua:1483-1489   `SetStage` — a bare `tonumber`
    driver_data_model.md   row 9 says so in as many words: *"the guard arrives with the pickers
                           (A10.3e), and until then the rule is a ruling with no enforcement"*
    architecture §3a       **Pickers (stage / ordinal doors) — status ✗**

**WHAT SHOULD BE**

    ARCHITECT_LOG AL-4     *"no shift, no renumber; duplicates cannot be authored"* ·
                           *"dissolves RI-41 / G6 and A2.3 by construction"* ·
                           *"the manager's bucket gets one anchor per stage for free"*
    architecture §4 (R7)   *"no duplicates by construction (model §1 SLOTS · A2.10)"*

**MEASURED, so the size is not guessed:** across all 12 scraped stores, **6 carry stages and NONE
carries a duplicate** — every one is `[1, 2, 3]`. ⟶ The conflict is real in the TYPE and **empty in
the DATA today.**

**THE ANALYST'S READ (mine, marked):** the guarantee is sound and the exposure is a WINDOW, not a
defect — the doors close when A10.3e lands, and nothing yet consumes the guarantee because the Route
Manager is ✗. ⟶ **Absent an answer I would grade the Route Manager against the guarantee and note in
its acceptance that the guarantee is unenforced until A10.3e**, rather than ask the bench to add an
interim refusal — which would also cut against tell-and-trust.

**FLATTENED, one yes/no:**

> **Is A10.3e (the pickers) a PRECONDITION of the Route Manager relying on one-anchor-per-stage —
> so the manager may assume it and its acceptance cites A10.3e as the guard?**

    YES   the manager is written to the guarantee, and A10.3e is named as what makes it true.
    NO    the manager must tolerate a duplicate stage at run time — which reopens RI-41 and makes
          the tray an authoring convenience rather than a structural guarantee.

⚠ **Why this is the architect's and not mine:** it decides whether a DIRECTION may be relied on
before the thing that enforces it exists.

★ **The architect answered better than the item asked** — neither branch, because a third guard
already existed in the part that has one.

</details>
