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

⚠⚠ **This is the part that would otherwise vanish silently.** These are rules about **the route
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
runnable"*. That is an **authoring** question, not a test one, and it is the one real loss to the
recorder.

★★★ **It does not come back as a side effect of a test tool.** His: *"if we want a audit green
light on a run, it gets named and designed. Not smuggled in."* So it is recorded here as a thing
the recorder may want, to be designed on its own terms and declared in
`dungeonrun_interface_inventory.md` before any of it is built.

---

## Recovering the code

Both files are in git, intact, at the commit **before** the removal. They are not copied to a
holding folder on purpose: a folder of not-quite-live code is read as live eventually, and this
plan plus a commit hash is a better pointer than a directory that looks abandoned.
