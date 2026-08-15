# The debugging suite — what left the recorder, and what it owes

★★★ **This is the ledger for a removal.** `driver.lua` and `walk.lua` leave `COA_DungeonRun`, and
they carried behavioural coverage of the route model with them. Written **before** the deletion,
because after it the list is much harder to reconstruct.

His ruling:

> *"Remove it. That all comes in the driver / debugging side. And if we want a audit green light
> on a run, it gets named and designed. Not smuggled in."*

★★ **The recorder records. It does not drive, and it does not test.** A consumer that grew inside
the authoring tool because it was convenient is exactly the thing that gets mistaken for the
design later.

---

## What is leaving

| | | why |
|---|---|---|
| `driver.lua` | the whole file | superseded by `walk.lua` before children existed |
| `walk.lua` | the whole file | the test driver — its own bounded activity now |
| `promoter.play` | button + registry entry | its engine is `walk.lua`; without it, it is a button with nothing behind it |
| `/dr drive` · `/dr walk` | both verbs | doors onto the removed surfaces |
| `NS.Driver.Init()` · `NS.Walk.Init()` | `core.lua` | |
| 26 mutation entries | 8 driver, 18 walk | |
| ~13 smoke regions | `smoke_dungeonrunpromoter.lua` | |

⚠ **`Store.SetUI("driverPos")` is orphaned.** A saved key in `COA_DungeonRunDB` with nothing to
read it. Harmless, and it stays until something is written that would clear it — a migration for
one dead key is more risk than the key.

---

## ★★★ THE COVERAGE THAT LEAVES WITH THEM

⚠⚠ **This is what the suite has to rebuild.** These are rules about **the route
model** — `routes.lua` — that were only ever asserted *through* the consumer. `routes.lua` has 51
mutations of its own and they do **not** cover these.

### From `driver.lua` — the detection maths (`Reached`)

    the height check is applied
    the planar check is applied
    the radius is not squared twice
    no height requirement means a SPHERE
    a band is a tolerance, not a floor
    the band's DOWN half is judged separately
    an unplaceable stage is refused (loudly)
    ★ THE RATCHET - an outcome can never walk the index backwards

★ Seven of the eight guard `Reached`, which is geometry: *is the player inside this radius, at
this height*. **That maths has to exist wherever detection happens** — the suite, and eventually
DungeonRun Drive. It is the most-tested thing being removed.

⚠ The eighth is the ratchet, and it guarded `Driver.Promote` — the copy nothing called. The LIVE
ratchet was inline in `Walk.Apply`, and it leaves too.

### From `walk.lua` — the model's behaviour

    the walk consults the height band
    a detector speaks once per visit
    leaving the radius re-arms the detector
    a held ratchet is reported, not silent
    set assigns without the max
    if-unseen blocks a repeat set
    the ledger records the stage that completed
    a stage with no acceptance is reported
    the action points at the goTo TARGET
    detect and action fire independently
    a dangling target is reported
    the next stage is found by LABEL, not by arithmetic
    the tracker goes to the on-ramp's own position
    past the last stage it still ANSWERS
    a childless beacon is its own detector
    the anchor satisfies without carrying a role
    the start report carries the unrunnable stages
    a bad route id reports a reason

★★★ **Read that list as a specification.** `set` versus `complete`, the ratchet, `if unseen`, the
anchor acting as its own satisfier, a detector speaking once per visit — that is §83–§95's whole
model, and the only place it was ever executed was the walk.

---

## What the suite owes

1. **`Reached`, with its seven mutations.** Geometry, and the first thing to land — nothing else
   can detect without it.
2. **The eighteen behavioural rules above**, restored as assertions against whatever drives.
3. **The ratchet guard pointed at the LIVE implementation**, not a second copy. That was the
   standing fault: two ratchets, and the tested one was the one nothing called.

⚠ **And it will be HEAVIER than the route runner, not the same thing scaled down.** His:
*"the test driver will be more populated than the version we build for the route runner in
content. (Putting super trackers against every position to see them and such.)"* Supertracking
every position to make it visible is instrument behaviour and would be wrong to ship to a player.
★ So the runner is not the suite with parts removed, and building it that way would start from
the wrong shape.

---

## ⚠ The audit green light — NAMED, not smuggled

`Walk.Unrunnable` and `Walk.MultipleAcceptance` answered *"is what I just authored actually
runnable"*. That is an **authoring** question rather than a test one.

⚠ **I called that a real loss. It is not.** His: *"We're not up to the point of development
where those questions matter."* Nothing is authoring routes at a volume where an automated
runnable-check earns its place, and treating an unused capability as a loss is how a removal
acquires conditions it does not need.

★★★ **It does not come back as a side effect of a test tool.** His: *"if we want a audit green
light on a run, it gets named and designed. Not smuggled in."* So it is recorded here as a thing
the recorder may want, to be designed on its own terms and declared in
`dungeonrun_interface_inventory.md` before any of it is built.

---

## Recovering the code

★★★ **Lifted wholesale to `addons/backlog/debug_suite/` before the cut**, by
`py addons/tools/emit_backlog.py debug_suite`. His: *"can we emit the content wholesale to a
backlog folder as snippets, before we cut them from code?"*

⚠ **Wholesale is the operative word.** A hand-picked excerpt is a summary, and a summary of code
is the one thing you cannot rebuild from. What is there:

| | |
|---|---|
| `driver.lua` · `walk.lua` | whole, 328 + 392 lines |
| `mutations.json` | all 26 entries, as a SPECIFICATION - their `find` anchors point at code that moved |
| `smoke_regions.lua` | 13 regions with their original line numbers |
| the five call sites | both verbs, both `Init` calls, the Play button **with its rationale**, its registry entry |

★ The play button's block opens on its COMMENT rather than its `CreateFrame`. The rationale above
a widget is the part that cannot be rebuilt from the widget - *"a slash command you have to
already know is not a surface"* is a decision; the code beneath it is only its consequence.

⚠ **It cannot reach a client.** `deploy.py`'s MANIFEST is keyed by addon folder name, so
`addons/backlog/` is invisible to it - checked, not assumed.

And both files remain in git at **`ac41961`**, the last commit with them live.

---

## ★★ A rule the suite inherits

**the driver INFORMS, it never grades** — no completion counts, no *"you missed one"*, no
scores, no streaks. It says where things are; what that is worth is not ours to say.

⚠ This lived as a tagged note inside `driver.lua` and `addons/maps/intent.md` cited it. Removing
the file left the citation dangling — and the guard caught it, which is the guard working.

★★★ **The rule did not stop being true; it stopped having anywhere to live.** Deleting the
intent row would have lost a decision, and re-homing the note in an unrelated file to make a
citation resolve would have been worse — a pointer that resolves to the wrong place is not a
fixed pointer. So the row is marked `⌛ awaiting code · planning/debug_suite_plan.md`, and
`emit_notes.py` now checks that the document named actually exists. **"Awaiting" must not become
a way to silence the guard.**

★ Whatever informs next — this suite, or DungeonRun Drive — carries it, and the citation
returns to code at that point.
