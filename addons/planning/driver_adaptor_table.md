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

> The instruction is the AUTHOR'S ANSWER — *"boss killed: ⟨name⟩ → advance"*, *"boss engaged:
> ⟨name⟩ → say the note"* — and the driver calls its own functions on it. **Arming, witnesses,
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
| `sense` | *the question the block asks;* the pane labels it **detect** | §321 | stage one of `sense → when true → next` |
| `reachHere` | **reach here** | §321 | the DEFAULT. Picking it clears; it is never stored |
| `ordinal` | **order** | §312 | blank = a satellite, live whenever its beacon is current |
| `radius` | **radius** | pre-existing | a GEOMETRY term. Passes §3b unchanged |
| `radius:listen` | **come here** | RI-2, 2026-08-18 | ★ the OUTER of the two radii. Named by Battlewrath when RI-2 drained |
| `radius:sense` | **found** | RI-2, 2026-08-18 | the INNER. ⚠ SAME control shape as `radius:listen` - one question asked twice, not two controls |
| `bandUp` | **up** | pre-existing | §85's asymmetric half that matters |
| `bandDown` | **down** | pre-existing | |
| `role` → `complete` | **stage complete** | pre-existing | from `ROLE_TEXT`, object.lua |
| `role` → `set` | **set stage** | pre-existing | |
| `role` → `start` | **start of stage** | pre-existing | |
| `role` → `update` | **updater** | pre-existing | ⚠ close to technical; flagged for the naming pass, not changed here |
| `action` → `supertrack` | **point the tracker** | pre-existing | |
| `outcome` → `advance` | **advance (+1)** | pre-existing | |
| `outcome` → `stage` | **go to stage** | pre-existing | |

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

    boss killed: ⟨name⟩  → advance
    boss engaged: ⟨name⟩ → say the note

★ One question, one answer, one row-shape. The `⟨name⟩` is picked, not typed, and it is part of
the answer rather than a term of its own. **What arms it, what witnesses it and what listens are
the driver's functions** — model §2c is corrected to say those tabs were the driver's, not the
author's, and none of them reaches a pane.

| code | user | landed | note |
|---|---|---|---|
| `sense` → `bossKilled` + `boss` | **boss killed: ⟨name⟩** | §321, reshaped §324 | one question. The name is picked from the run and is part of the ANSWER |
| `sense` → `bossEngaged` + `boss` | **boss engaged: ⟨name⟩** | §321, reshaped §324 | |

⚠ **No row for `ArmsWith`.** It is the arming contract — a function, unlabeled, never in a pane —
and the fact that it is the whole of A3.3 does not make it the author's business.

---

## ⚠ Terms that reach a pane and have NO user word — A9.3's red

| code | where | why it is a problem |
|---|---|---|
| `ratchet` | `object.lua` — *"ratchets when found"* | §3b fails *once · latch · edge · level · hysteresis · activate · trip* as author-facing, and `ratchet` is that family — one of our three stage registers. It reached the author in a string G2 extended, not introduced. Needs a word. |
| `on-ramp` | `object.lua` — the answers line | ours. The model calls the idea *the way in*. |
| ~~`satellite`~~ | ★ **FIXED §326** | the string now says what it DOES — *"no order - listens whenever this beacon does"* — and needs no term at all. ★ That is the naming law working rather than a word swapped for a nicer one: the author never needed our word for the SHAPE, only for the behaviour. |

★ **Three rows, and I put two of them there myself this week.** That is the argument for the
checker (A5.3) rather than for trying harder: a rule I have to remember at the moment of typing a
string is a rule that gets remembered most of the time.

---

## What this file is NOT

⚠ **Not a plan.** §9/A5.4: *"the inventory FOLLOWS the code… what lands and is confirmed gets a
real inventory."* No row here anticipates a term.

⚠ **Not a vocabulary for the machinery.** The function layer has no rows and wants none.

⚠ **Not the enforcement.** A5.3 puts a third check in `check_interface.py`: every user-visible
string in a pane resolves through this table, and every code term reaching a pane has a row. ★ Its
first red is the table above.
