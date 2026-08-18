# The adaptor — `code : user`, one row per term that reaches a pane

_Started 2026-08-18 (§321), owing since §308's T14. **Corrected §324 by the Analyst's review** —
two of the first rows contradicted the record, and both faults were MODEL faults rather than
naming ones. `driver_programmatic_model.md` §5 rules how it is built: **"inventory current code
terms into the `code` column AS EACH IS TOUCHED, correct drift there, THEN free the `user` column
for the author's words."** So this file FOLLOWS the code — never a term planner, and a row appears
the day its term does._

---

## ★★★ WHAT THE ADAPTOR CARRIES — the question layer, and only that

**Battlewrath's boundary, relayed by the Analyst 2026-08-18, and it is the rule this file was
missing:**

> The instruction is the AUTHOR'S ANSWER — *"boss killed: ⟨name⟩ → advance"*, *"sense: here →
> give the note, immediately"* (~~boss engaged → say the note~~ — ⚠ SUPERSEDED (RI-15 settled, 2026-08-18): engaged not offered) —
> and the driver calls its own functions on it. **Arming, witnesses,
> listener are FUNCTIONS: unlabeled, never in a pane.** Not every function needs a label; a
> question is the end product of how a function would answer.

    THE QUESTION LAYER   what the author is asked, and what they answer with.
                         Rows here.
    THE FUNCTION LAYER   how the driver makes that answer true - arming, witnesses,
                         the listener, the gate, the fold. NO ROWS, NO LABELS, NO PANE.

⚠ **So a term is not owed a row because it exists.** `ArmsWith`, `ListensNow`, `Store.BossNames`
and `AcceptanceOf` are functions the author never meets, and giving them user words would invent a
vocabulary for machinery — which is the opposite of what §3b asked for.

★ **And it is the test for a new row:** *is this something the author ANSWERS, or something the
driver DOES about their answer?* Only the first gets a row.

## ⚠ Pass-through is DEGRADE-TO-LEGIBLE, not silent failure (A5.1, corrected §324)

I had read the pass-through rule as a tolerance. **It is a guarantee.** When a question-layer term
has no row — a version mismatch between an addon and a table, say — the pane renders the **code
name**, so *what the instruction was calling for is still expressed to the author*. It degrades to
legible, never to blank, and never to a control that means nothing.

★ The checker (A5.3) is what makes the same miss LOUD at the bench. **Two audiences, two
behaviours, one event** — silent-and-legible for the author, loud for us.

---

## Rows — the QUESTION layer, filed as the term landed

| code | user | landed | note |
|---|---|---|---|
| `sense` | *the question the block asks;* the pane labels it **detect** | §321 | stage one of `sense (location + behaviour in R) → what I do (rows)`; the third stage (`next`) was WITHDRAWN (RI-5); boss is not a value here (RI-15) |
| `reachHere` | **reach here** | §321 | the DEFAULT. Picking it clears; it is never stored |
| `ordinal` | **order** | §312 | blank = a satellite, live whenever its beacon is current |
| `routeNote` | **Route instructions** | §346 | ghost: *"Instructions for the player running the route"*. ★ RI-10: **`note` alone reads as a dev-note slot**, so neither kind may carry the bare word |
| `note` (personal) | **Personal note** | §346 — OWED | the map plane, §60. The row is filed because the DE-CONFLATION is what makes either word safe; the string itself is not yet written |
| `radius` | **radius** | pre-existing | a GEOMETRY term. Passes §3b unchanged |
| ~~`radius:listen`~~ | ⚠ **PULLED §328** | see below |
| ~~`radius:sense`~~ | ⚠ **PULLED §328** | see below |
| `bandUp` | **up** | pre-existing | §85's asymmetric half that matters |
| `bandDown` | **down** | pre-existing | |
| `role` → `complete` | **stage complete** | pre-existing | from `ROLE_TEXT`, object.lua. ⚠ `role / action / outcome` rows are the SHIPPED code shape that A10.3 REPLACES (A10.2a) — not the author's model; they retire with the old pane |
| `role` → `set` | **set stage** | pre-existing | |
| `role` → `start` | **start of stage** | pre-existing | |
| `role` → `update` | **updater** | pre-existing | ⚠ close to technical; flagged for the naming pass, not changed here |
| `action` → `supertrack` | **point the tracker** | pre-existing | |
| `outcome` → `advance` | **advance (+1)** | pre-existing | |
| `outcome` → `stage` | **go to stage** | pre-existing | |

### ⚠⚠ PULLED §328 — the two radii are ACTIONS, and I filed them as SENSES

I filed `radius:listen` and `radius:sense` as question-layer rows the day RI-2 named them.
**Battlewrath's objection, and it is a model objection rather than a naming one:**

> *"They are two ACTIONS. Not two sense types. Sense has: did you step on me, or are you still
> on me. Both are listen in a sense."*

★ **So `sense` asks whether you SEEN it (touched) or are STILL ON it (when on)** [RI-17 words] — and both radii are
listening either way. What differs between them is not the sensing; it is **what happens at
each distance**: *come here* is an action, *found* is an action. Two thresholds, two actions,
one anchor.

⚠ **Which means the names themselves encode the fault.** `radius:sense` reads as *a kind of
sense* and it is not one; it is an action with a distance. Both rows are PULLED rather than
reworded, because a better word for a wrong shape is still a wrong shape.

★ The flight list said this and I did not join it up: *"one child with two thresholds
(supertrack within 150, complete within 50) becomes TWO steps sharing an anchor."* **`supertrack`
and `complete` are ACTIONS.** The pairing was there in the basis; I read the distances and
missed what they were distances TO.

⚠ Battlewrath is taking the model question up the chain — *"to get a better model, or see where
it's a comment vs the model"*. Nothing is filed back here until it returns. See `Reconcile_inbox`
RI-5.

### ⚠⚠ CORRECTED §324 — `wire` is a GEOMETRY term and "trip wire" is a FIRING word

I filed `shape → wire` as **"trip wire"**, which is the string the pane already renders. Two
faults, and the Analyst caught both:

    THE MODEL     §2 is explicit: "wire/radius = GEOMETRY, a separate axis" and
                  "`once | while` is NOT a modifier - it is the FIRING kind... two
                  independent axes." **"Trip" is a firing word.** Calling the geometry
                  term "trip wire" imports the other axis into its name, and an author
                  who reads it that way will look for a firing choice that is not there.
    §3b           the naming law's FAIL list contains `trip` by name. The existing pane
                  string breaks it, and I copied the breach into the table as though
                  transcribing made it correct.

★ **A geometry term should say what the SHAPE is.** `radius` is one place, broad by construction;
`wire` is multi-positional — a line of small radii, many places tracked at once. ⚠ **The user word
is the naming pass's to rule, not mine** — this row is left OPEN rather than guessed at, with the
constraint recorded: it must name a shape and must not carry a firing meaning.

| code | user | state |
|---|---|---|
| `shape` → `wire` | ~~trip wire~~ **OPEN** | must name a SHAPE, never a firing. §3b fails `trip` |

### ⚠⚠ CORRECTED §324 — the boss rows were three mechanical steps, not one question

I filed `bossEngaged`, `bossKilled` and `boss` as three separate rows. **That asks the author to
assemble one question out of three parts we happen to store separately.** The author's unit is the
INSTRUCTION:

    boss killed: ⟨name⟩  → advance   (default: set stage = this beacon's next — recovery)
    ~~boss engaged: ⟨name⟩ → say the note~~   ⚠ SUPERSEDED (RI-15 settled, 2026-08-18): the note is given on the arena sense

★ One question, one answer, one row-shape. The `⟨name⟩` is picked, not typed, and it is part of
the answer rather than a term of its own. **What arms it, what witnesses it and what listens are
the driver's functions** — model §2c is corrected to say those tabs were the driver's, not the
author's, and none of them reaches a pane.

| code | user | landed | note |
|---|---|---|---|
| the row's ACTION word `boss` (declaration `When on:boss:⟨name⟩`) | **boss: ⟨name⟩** (outcome — the kill completes the stage) | §321 · §324 · RI-15 · RI-17 | one question. The name is the ARG, picked from the run. ★ RI-17 (2026-08-18): a row is one declaration `<sense>:<action>:<arg>`; `bossKilled` as a stored value retires into the action word `boss`; sense-words `When on` / `Seen` / `When off` (the floor words) are the first term |
| ~~`bossEngaged`~~ | — NOT OFFERED (2026-08-18) | §321 · RI-15 settled | ⚠ Battlewrath: *no interest in knowing you're in a fight without killing it* — the arena sense gives the note moment. A driver-side arming witness at most (§2c): FUNCTION layer, no row, no pane |

⚠ **No row for `ArmsWith`.** It is the arming contract — a function, unlabeled, never in a pane —
and the fact that it is the whole of A3.3 does not make it the author's business.

---

## ⚠ Terms that reach a pane and have NO user word — A9.3's red

| code | where | why it is a problem |
|---|---|---|
| `ratchet` | **Next stage** (the stage ratchet, +N) · **Next step** (the ordinal ratchet) — a LABEL with a FIELD beside it, never a direct control | §3b RED → WORDED 2026-08-18 (Battlewrath) | *"Ratchet (explains: can't regress): Next stage / Next step. But this is a label, not a direct control. (Has a field with it.)"* `ratchet` stays the code word and the explanation; the author reads *Next stage* / *Next step*. A9.3's red closes on this row |
| *the once \| every control* — NOT BUILT; code term the bench's the day it lands (no identifier invented here) | **Trigger** — dropdown: **One time** · **Every time** | 2026-08-18 (Battlewrath) | resolves the SEEN / IF SEEN collision: **Seen** is the sense-word (touched me); the re-arm control is labelled **Trigger**. Meaning unchanged (RI-5) |
| ~~`on-ramp`~~ | ★ **GONE §340** | not reworded — the FEATURE went (A2.6 / RI-8), and the string with it. ★ The strongest way to fix a term the author should not meet is for there to be nothing to name. |
| ~~`satellite`~~ | ★ **FIXED §326** | the string now says what it DOES — *"no order - listens whenever this beacon does"* — and needs no term at all. ★ That is the naming law working rather than a word swapped for a nicer one: the author never needed our word for the SHAPE, only for the behaviour. |

★ **Three rows, and I put two of them there myself this week.** That is the argument for the
checker (A5.3) rather than for trying harder: a rule I have to remember at the moment of typing a
string is a rule that gets remembered most of the time.

---

## What this file is NOT

⚠ **Not a plan.** §9/A5.4: *"the inventory FOLLOWS the code… what lands and is confirmed gets a
real inventory."* No row here anticipates a term.

⚠ **Not a vocabulary for the machinery.** The function layer has no rows and wants none.

★ **THE ENFORCEMENT LANDED §336** — `check_interface.py`'s fourth check, and it reports the
two directions DIFFERENTLY because §295 ruled they are different events:

    a §3b FAIL WORD in a pane string      DRIFT, exit 1. Not legal in either direction.
    a vocabulary value with NO ROW         a NOTE, exit 0. Pass-through is LEGAL for the
                                          author - it degrades to legible, never blank.
    the OWED list below                   a NOTE, counted. ★ Self-emptying: strike a row
                                          when its string is fixed and the number falls,
                                          which is how `satellite` came off in §326.

⚠ The checker enforces what is WRITTEN and reports what is JUDGED. `ratchet` and `on-ramp`
are this bench's judgement about §3b's family, not the law by name — so it counts them and
does not fail on them. **A checker that cannot tell a law from an opinion teaches people to
argue with it.**

⚠ **Not the enforcement.** A5.3 puts a third check in `check_interface.py`: every user-visible
string in a pane resolves through this table, and every code term reaching a pane has a row. ★ Its
first red is the table above.
