# Dungeon Run — BENCH PROPOSITION for docket items 1–3

_Addons bench, 2026-08-17, answering the docket from Battlewrath via the Analyst. Read against
`driver_use_case_target.md §9` (sorting), `driver_scoping.md` (fifteen + §R),
`driver_programmatic_model.md §5` (the four holes, the ruled order), `driver_user_journey.md`
(the capture milestones). **Nothing here is built.** Sequence, insertion points, and three things
I want ruled before I touch the panes._

---

## 0. Three corrections to the docket's picture of the code

I read the files before proposing, and the ground differs from the account in three places. All
three change the shape of the work.

**★ G2 is a FIELD gap, not a logic gap — the fallback already ships.**
`routes.lua:862` `OnRampOf(b)` returns the beacon when no child carries the on-ramp;
`routes.lua:893` `AcceptanceOf(b)` returns the beacon when `#ChildrenOf(b) == 0`. The childless
beacon is *already* lure + acceptance in one, exactly as S2's addendum rules. What is missing is
that a beacon has nowhere to put `radius / up / down` — a child has `Routes.SetChildReach`
(`:688`) and a beacon has nothing. **So this is one storage field plus one accessor, not a
second code path.**

**⚠⚠ G1 is NOT "restore the removed field", and this is the one I will not guess at.**
`routes.lua:802` records that §91 removed the per-child note setters **on a ruling**, in his
words: *"with ids a note is likely a CONSUMER several children reference — you update one note.
On route export, the same note or a ref lookup is set into both."* `store.lua:407`
`Store.NoteTable()` already exists for that shape. Target §4 rules a note is a choice option
≤ ~200 chars but does not re-decide **owned or referenced**. Putting a string back on the child
re-breaks §91; building the table adds an object the author must manage. → **R1 below.**

**★ G10's picker already has its source, with a bound attached.**
`store.lua:364` accumulates `r.bosses` per pull, and `capture.lua:234` states the bound plainly:
*"NOT 'bosses', AND NOT ENCOUNTERS. We hold unit names that had a boss token at that moment."*
So the picker offers **names**, the author picks one, and nothing claims a set or a count. That
is target §3's "picked, never typed" satisfied by construction, and §17 not crossed.

---

## 0b. THE ARCHITECTURE LINE — and why there is no second artifact

**Battlewrath, §294:** *"'Move super tracker because X says so' holds. But right now it's hard
coded. Where it's the load route, then, start route (arm), then, instruction says: Driver reads,
acts."*

    load route      the author's form, as stored
    arm             compile it HERE, in memory
    instruction     read from that
    driver          acts

★★ **What `task_chain` is missing is X, not the mechanism.** The task holds the instruction
itself — *arrive within 5 → advance → set next* — so the driver is not reading an instruction, it
**is** one. `emit_chain_route.py` writes `{x, y, z, mapID, kind, n}` and nothing more, because the
beacons have nothing more: sense, when-true and next are exactly what item 1 puts on the panes.
**The hard-coding is a placeholder shaped like item 1's output.**

### ★★★ ONE STORED FORM — checked against WeakAuras, not assumed

Battlewrath raised it and it is checkable from our own basis (`audit/addon_weakauras.md`):

    data.load / triggers / conditions       what is STORED — a declarative table
    ConstructFunction(load_prototype, …)    compiled to a Lua source string ON `Add`
    Private.LoadFunction → checkConditions  in memory, per session, NEVER persisted

★ **So WA's "flatten" is a function applied at load, not a second artifact** — and `Modernize` is
the proof rather than an inference: it exists to upgrade *old stored auras on the way in*, which
you only ever need if what is stored is the author's versioned form. Compiled output you would
simply recompile. The transported form is the same form again (`serialize → compress → encode`).

⚠⚠ **This bears on D-3's MECHANISM, not its ruling.** D-3 ruled two languages *by construction* —
editor source, consumer flattened. WA's shape says **one stored language, compiled at arm**. The
intent survives; the second artifact does not.

### The adaptor carries the two vocabularies instead (Battlewrath, §295)

    STORED        one form, in the CODE's meaning — travels, compiles at arm
    THE PANES     render through a LOOKUP FUNCTION: code term → author word
    THE CONSUMER  reads the stored form directly; nothing to translate

★★ **A called function cannot drift the way a documented table can.** §3b asked for the `code :
user` table as documentation with a grep rule; making the panes **call** it means a string cannot
reach a pane except through the table. The grep still earns its place — it catches the stray
literal that bypassed the function — but it is now catching an exception rather than enforcing
the rule.

**RULED (Battlewrath, §295): PASS THROUGH on a miss.** A row that does not exist renders the code
term. ★ And that is the better split, not a compromise: the author never sees our bookkeeping,
and **the bench does** — the function is silent, the checker is loud, each in front of the person
who can act on it.

**⚠ Versioning: a stamp from day one, no migration code.** WA needs `Modernize` because it has
years of stored auras; **we have none** — Battlewrath: *"right now there is no version control to
be concerned with, but building looking forward is important."* So the stored form carries a
`schema_version` and nothing reads it yet. Same shape as S11's *build so we can, hygienically*.

## 1. SEQUENCE — item 1's four holes, reordered, with the reason

The docket lists them reach · note · boss · ordinal and does not rule an order within the item.
I would take them in this order, because each one's *unknowns* are smaller than the next's:

    1  G2   reach on a childless beacon    a field + one accessor; nothing else waits on a ruling
    2  —    child ordinal (`4.1:3`)         the ADDRESSING every later hole uses to say which child
    3  G10  boss child kind + name picker   the first NEW KIND; proves the kind mechanism on a
                                            source that already exists (store.lua:364)
    4  G1   the reader note                 LAST — blocked on R1, and only on R1

★ **The reason for 2 before 3 and 4:** a new child kind and a note reference both have to say
*which child*. `4.1:3` is the identity everything else addresses through (model §1), so building
a kind first means addressing it twice.

⚠ **What I would NOT do:** touch `map.lua` (2,385 lines) for any of the four. All four land on
the object pane and its store shape — `routes.lua` + `object.lua` + the `object.md` interface
file. The map draws what the store holds; it does not need to know a beacon gained a radius.

## 2. HOW EACH LANDS — insertion points, no rewrite

**G2 — reach on a childless beacon.**
Mirror the child's three numbers onto the beacon and resolve through one accessor:

    Routes.SetBeaconReach(b, radius, up, down)     beside SetChildReach (routes.lua:688)
    Routes.ReachOf(x)                              child fields if present, else beacon's

★ `ReachOf` is the only new call site anything downstream needs; `OnRampOf`/`AcceptanceOf` already
return the right object, so the walk and the flatten ask the same question of both. **Additive.
No existing signature changes.**
⚠ Height stays inherited (`routes.lua:29-31`) — the beacon's `z` comes from its read; the band is
a tolerance over it (§287), never a height.

**Child ordinal.**
A stored field on the child + a display rule. The parent's surface manages ordinals *across* the
set (model §1); each child still edits its own on its own pane. `Routes.ChildrenOf` returns an
array today, so order is positional — the ordinal makes it **explicit and sparse** (`3.1` inserts
without renumbering, which is the model's whole point).
⚠ One real risk: two children given the same ordinal. **Tell-and-trust (S4)** — the pane shows the
collision, the flatten reports it, nothing refuses.

**G10 — boss child kind.**
A `kind` on the child (today `role` carries `complete`/`set`; the four kinds of model §1b are a
different axis) + a picker fed from `Store` over the run's `r.bosses`. Two senses per the model:
*boss engaged* and *boss killed*.
⚠ The kill witness is `UNIT_DIED` by dest name — Skada's shape (`driver_neighbours.md` 8b/8c):
**register CLEU on arm, subevent lookup, unregister on disarm.** That is consumer-side, not
editor-side, so item 1 stops at *the author can pick a name and say what happens*; the listener is
Dungeon Routes' (target §9 sorting).

**G1 — the note.** Deferred to R1.

## 3. ITEM 2 — the test driver has a home and a precedent

⚠ It should not be a seventh surface. `/dr walk` already exists and already reports per-stage
runnability (`routes.lua:890` names its unrunnable-stages report), and `editor.lua` has the play
pacer the model wrote. S10 rules the MVP is *"a suite option of Dungeon Run"*.

**Proposition: the test driver is a MODE of the existing walk, not a new pane.** Two things S4 asks
for, both readouts over what the store already holds:

    walk the dataset      per node: its triggers, and whether each would fire on this run
    cycle nodes near me   in-client: step through nodes by distance and see what they do

★ **First proof, per the journey's milestones:** a stage advance on **just a boss kill**, against
what is already captured — names + engage timestamps + `UNIT_DIED` (all present). No new capture
needed for it, which is why it is the right first proof.
⚠ It needs the **per-stage pin trace (C-4)** before it can replay *"point here"* — that is the one
capture change the journey rules as **now**, and it is small: record what the driver pointed at and
when, the way `task_chain` already does (`§289`, every set/arrive/clear as an event row).

## 4. ITEM 3 — the adaptor table, and a checker that already exists

§3b wants the `code : user` table **verifiable**: every user-visible string in a pane resolves
through it; every code term reaching a pane has a row.

★★ **`addons/tools/check_interface.py` is already that checker, one check short.** It reads
`addons/planning/interface/*.md` as the authority (`:43`), regex-extracts declared controls
(`:259`) and asserts registration both directions (`:268`, currently 98 of 98). **Adding "every
user-visible string resolves through the adaptor table" is a third function in the same file,
same pattern, same exit code.** No new machinery, and it makes the naming law gradeable rather
than reviewable.

⚠ Per the docket: inventory the `code` column **as each term is touched**, correct drift there,
then free the `user` column. **I would not sweep** — a sweep is a rewrite wearing a different
name, and `driver_reconciliation.md §1#10` shows what a rename-in-bulk costs.

---

## 5. WHAT I WANT RULED FIRST — three, in order of what they block

**R1 · Is a note OWNED by a child, or REFERENCED from a note table?** *(blocks G1, nothing else)*
§91 removed the per-child setters on the referenced reading; `Store.NoteTable()` exists for it;
target §4 does not re-decide it. Owned is one field and re-breaks a ruling. Referenced is a table,
a picker, and an author-facing object — but it is what §91 actually said. **I will not pick this
one.**

**R2 · Does a childless beacon carry a band, or inherit the ±2.5 default?** *(sizes G2's pane)*
§287 rules the band a tolerance erring tight, and §286 rules its ceiling is set by where beacons
go. If it is a **default**, the beacon carries one number (`radius`) and the pane is one field. If
it is **per-beacon**, three fields and three ways to get it wrong. ★ My leaning, labelled: default,
with the band exposed only where an author has a reason — but the pane size is the author's call.

**R3 · Is the test driver a MODE of `/dr walk`, or its own suite entry?** *(sizes item 2)*
`/dr walk` exists with a per-stage report. S10 says "suite option". These may be the same thing
said twice — if so it is an extension, and item 2 gets materially smaller.

---

## 6. Bounds check on this proposition

    own-position detection            G2/ordinal/G10 are authoring; detection unchanged
    height never invented             beacon z stays inherited (routes.lua:29-31); band is
                                      tolerance over a sampled z
    no combat model                   the boss picker offers NAMES from the run; no grouping,
                                      no count, no pack (capture.lua:234 bound carried through)
    no dungeon knowledge              nothing shipped per-dungeon; the picker's source is the
                                      run's own record
    no route grading                  the test driver reports what fired, never whether it
                                      was good
    consumer computes nothing         the CLEU listener is consumer-side and out of item 1;
      resolvable at authoring         the boss NAME is resolved at authoring
    beacon only from a read           unchanged — no new spawn path proposed

## 7. Housekeeping owed, and where it sits

The audits' bench items are independent of 1–3 and I would take them first, in one pass, because
several are stale TEXT that a reader would act on: `walk.py` W1 summary "eight" → ten · the
`w32` MEASURED/UNMEASURED contradiction · W5 emitting first-proximity time and timeline rows to a
file (W7.1's golden does not exist yet) · posture §3 and the `rfc_combat` result marked withdrawn
in place · the "12 landed runs mapID-constant" claim corrected and `20260812_113949_493__satnav`
added as a **W1.3 real-data fixture** — ⚠ that last one is the better finding of the two: the
straddle branch was reachable all along and my "synthetic by necessity" was wrong.

**`COA_DevDump/route_chain.lua` — RULED (Battlewrath, §292/§293), and my guard was aimed at the
wrong thing twice before it landed.**

I flagged it as looking like the per-dungeon content §17 refuses (`driver_reconciliation.md §2 /
C3 §5.3`) and offered gitignore-or-name. **§292: keep it, with its why-not.** So I annotated it as
a *fixture* and drew the line at the file — probe input here, shipped content there.

⚠⚠ **§293 moved the line where it belongs:** *"it is the UPSTREAM being invalidated for that code.
IE. loading the route. Inherently they are the same. Take information. Use it perform function."*

★★★ **Loading a route is loading a route.** The consumer takes information and performs a
function; it cannot see what produced the file and does not need to. **So `route_chain.lua` is not
a fixture resembling a route — it IS one**, and there is no second species to defend it against.

    VALID     every position came from a READ. This file: generated from a landed
              capture, carrying its sha.
    INVALID   positions invented, typed, or shipped as knowledge nobody observed —
              which is what §17 refuses, and what pfQuest/GatherMate2's node lists are.
              Not because of where they live. Because nobody read them.

⚠ **So the failure condition is not "it moves out of a probe addon". It is a position in it that
did not come from a read** — the seed-once law, which is the only thing that has ever separated us
from the shipped-data neighbours. Location is incidental; provenance is the whole of it.

★ **Consequence for §3 above:** I under-labelled `task_chain` as *"not the driver"*. If loading and
driving are the same operation, it is **a consumer with a fixed rule and no ratchet** — partial,
not a different kind of thing. That makes item 2's test driver less of a new build than the
proposition assumed, and strengthens R3.

---

_Asked back: R1, R2, R3. Everything else in items 1–3 I can sequence and land without a further
ruling. The Analyst tests what is built against W1–W7 and the naming pass against §3b._
