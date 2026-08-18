# Dungeon Routes — THE USE CASE, as a target for modelling

_Sharpened by the Analyst from Battlewrath's reflection, 2026-08-17. This is the stable surface
the model is scoped AGAINST — a delta row in `driver_reconciliation.md §4` is decided FOR this,
not between the model and the arc on their own terms. Evidence is pinned under each line so the
target is answered from facts, not memory. Lines marked ⟂ are Battlewrath's to fill or confirm;
everything else is his words or the arc's measurements._

---

## 0. The statement (Battlewrath, verbatim in substance)

> **The addon does not compete with combat information — WeakAuras, DBM and others have that
> solved. What is not solved is combat ORGANISATION: getting the player to the combat, giving
> them enough to solve the trash and any notes for the boss, and then where to go and how to
> route to the next engagement. We do this by pre-authoring routes in a WeakAuras-style logic
> builder that can be intuited rather than coded, authored against a captured dataset that gives
> the editor answers a blank 2D map cannot.**

Positioning, in one line: **MDT / keystone.guru for a server that has no MDT data — capture
replaces shipped dungeon data — plus the in-run driver they never had.**
    evidence   MDT and keystone.guru: route authoring + sharing on a map, no in-run driving,
               standing on shipped per-dungeon data (Blizzard maps, MDT mob tables) — the
               exact inversion of §17 "we never learn dungeons". Neighbours audit: no
               installed addon does in-instance position acceptance or authored order
               (`driver_neighbours.md §3`).

## 1. The MOMENT — where the product earns its keep

To the combat → through it with the author's notes → on to the next. Inside a pull the product
is quiet; at a boss it is the sync; at a wipe it is the arrow leading back to progress.
    evidence   rfc_combat: combat gaps = 24 % of the run, 9 windows 1.2–13.6 s, 0–78 yd of
               travel; the design pins the author placed sat in gaps and were followed by
               travel, 3 for 3 (`history/driver_walk_result.md` rfc_combat) — an OBSERVATION of one
               run, not a model of combat (asklist H15).
    not ours   what happens inside the fight (WA/DBM); which mob is in which pack (§3 below).
    the wipe, made concrete (Battlewrath, 2026-08-17 — a DEATH LOCATION POINTER): on the
               DEATH event remember the reader's own position and point at it; on the ALIVE
               event write the route's current lure again. Alive/dead only — no ghost state
               in dungeons; both from the log. **No "give back" mechanism:** if anything else
               sets the tracker meanwhile it wins, by our logic (reinforcement, never
               arbitration) and by construction (last write). The ratchet never moved. A
               sampled place (the reader's own), so no invention. The READER's option, OFF by
               default. Sorted → Dungeon Routes. Testable on the corpus: death rows exist —
               replay shows engage on death, hold, re-write on alive.

## 2. The READER — who is on the other end

Anyone in the group, on their own screen, hands on movement, eyes on the group; can spare a
glance at an arrow and one short line. **One author, many readers.** Every reader's driver is
its own sensor (own position, own ratchet) on the SAME instruction set. Nothing is pushed.
    evidence   own-position detection ruled (asklist H0-b / R-a); measured to 1e-5 in-dungeon
               across 7 floors and across pin switches (H8, W6).
    CONFIRMED (Battlewrath): no leader, no cross-talk. The game already shows where others are
               (the map), and there is no unit-position API — the only route to it would be
               sharing positions over a private channel, and that helps no single player get
               through a dungeon. Five sensors, not one plus four displays.
    build target   per-user, for people who enjoy tinkering with routes. Adoption will be slow
               and that is expected; MASS ADOPTION IS NOT THE BUILD TARGET.

## 3. The AUTHOR — what they can express, and only that

A route: places (from reads), radius + band per place, notes, order (activation edges; a chain
where the path is the path), a boss sync (from the run's engaged names), one lure per theater,
`once|while`, close conditions, **stage as a ratchet with maxSeen tracked (skip expected), and
RECOVERY beacons outside the sequence — a boss-kill trigger with `set:stage(N)` — for dungeons
that are not end-to-end (Blockades: three bosses, T-hall, no right order)** (scoping S6).
Nothing else is authorable; anything not on this list is not in the editor.
    evidence   advisory §13 entity table + instructions; height by construction (R-b); boss
               name = sampled fact, pre-populated; ordinals as drawn chains, not a form.
    the sample OFFERS, the author DECIDES:
      - places: every position is a copied read; drag re-seats onto another read
      - heights: always a sample's z; band = accepted tolerance ±2.5 (§285/§286)
      - boss names: the run's engaged names, as an option list — picked, never typed
      - trash: NO OFFER (Battlewrath, correcting the earlier line). The note is a RECIPE the
        author writes. We have no per-bracket certainty of which mob belonged to which pull
        when they over-pulled, and a creature-type count would rest on knowledge we cannot
        back. The sample offers nothing here; the author says it all.
    accepted limit   we do not know which mob is in which pack, and we do not pretend to by
               counting.

## 4. What the reader SEES — surfaces

The arrow (the client's own supertracker, set by us, a heading not a waypoint chain) and a
note. The pointer is for TRAVEL, notes are for ACTION.
    evidence   `SetSuperTrackedPosition` is a reachable function accepting any source; overwrite
               instantaneous; `ts=0` on clear (W6). Pointer as heading; the line as the one
               precise exception (advisory §10).
    RULED (Battlewrath): a note is a CHOICE option, and MINIMAL — about 200 characters at most.
               Surface and persistence between stages: the model's readout-box rulings
               (§268–454, untouched by the arc) remain the reference.
    TWO NOTE SLOTS (Battlewrath, 2026-08-18, RI-10): the ROUTE note (the author's, travels with
               the route: "do X on this leg") and, in its own DESIGNATED SLOT, the reader's
               PERSONAL note (theirs, per place, role/class-specific, never travels: "what I
               normally face here"). Personal notes may push the tracker by an explicit act;
               the route overwrites in its sequence. Off by choice; off the authoring path.
               → model §4b.

## 5. What TRAVELS — and how consent works

The instruction set is portable: copy-paste string, or an in-dungeon machine channel. A driver
listens ONLY because its user chose "listen for route from a member of my group". The tank
SAYS "I have a route" — human communication; the reader then SELECTS which to run.
    evidence   route package = meta / flat / source; datasets their own economy; a route runs
               and tweaks with no dataset held (advisory §12). Skada's register-on-arm /
               unregister-on-disarm as the CLEU shape (`driver_neighbours.md` 8b).
    CONFIRMED (Battlewrath): matches exactly — the channel carries the flattened instruction set
               only, and a received route is inert until selected. Dataset sharing is not
               ruled out but is OUT OF BAND (Discord and the like): a dataset is an AUTHOR's
               interest, and authors are by nature the ones invested enough to do the work.
               "The consumer just needs petrol in their engine and go."

## 6. What it must NEVER do (reader-facing form of the brief's bounds)

- tell the reader what a good route IS (no optimiser, scorer, ranker, reroute)
- perform a gameplay input on their behalf (a cast is the world; an arrow is understanding)
- carry knowledge of a dungeon it has not seen (no shipped per-dungeon table)
- invent a position, a height, or a boss name (all from reads or the run's record)
- push a route onto a screen that did not ask (§5)
- pull the reader off their natural line (pointer = heading; zig-zag only for a LINE)
- compete with combat information (no cooldowns, no mechanics — WA/DBM's job)
- do expensive work while quiet (arm conditions gate CLEU and note churn; two-way edges)

## 7. "IT WORKED" — from the reader's side, each measurable

- they moved off toward the right place before they would have had to ask
- nothing on screen asked them to stop, turn back, or read more than a line
- a skip did not strand them (funnel sensors + boss set catch up)
- a wipe did not lose them (ratchet holds; the arrow leads back to progress)
- the note for THIS pull was there when they reached it, and gone when it did not apply
- the boss note was there at engage; the stage advanced on the kill
- nothing fired that should not have (false advances = 0 on the walk for that route)
    evidence   W1 ten criteria; W5 fitment (first-hit / hit / skip / false advances); W6 chain;
               W7 port fidelity when the consumer exists.
    LIVE ACCEPTANCE (Battlewrath) — what the reader reports after the first real route:
      1. they COMPLETED the dungeon
      2. they KNEW WHERE TO GO
      3. they did NOT get stuck — on an index, on an instruction, or on a loose supertracker
         left pointing at something forgotten
      4. it did NOT add to the noise of combat, and did not make them work around the UI
         while trying to play
    The rest above stay walk-measured.

## 8. What the model is scoped FOR (the sentence a delta row is judged against)

**A route authored once against a captured run, driven independently on every reader's screen
by a dumb consumer that reacts to sampled places with a fixed rule, and never claims to know a
dungeon, a pull, or a good path.**

## 9. TWO PRODUCTS, ONE FOCUS — the guard rail (Battlewrath, 2026-08-17)

    DUNGEON RUN      the PRODUCER  — capture (sample collection) + the route EDITOR
    DUNGEON ROUTES   the CONSUMER  — the driver + the sensor the reader has at runtime

Both need work. Both are enriched by everything above. **Right now the focus is the CONSUMER —
Dungeon Routes.** One prerequisite crosses the line: **the producer must be able to write
something the consumer can run** (a flattened route of childless beacons is enough for v1).
That is the only parallel need; everything else in Dungeon Run waits.

**Sorting rule — every work item is tested before it lands:**
    does the CONSUMER read it at runtime?            → Dungeon Routes
    does an AUTHOR touch it, or does it produce
    the thing the consumer reads?                    → Dungeon Run
    is it a fact about the client?                   → operations/ROUTER.md, not either addon
    is it about what combat looks like?              → nobody's (§6)

Applied to the gap analysis (`driver_analysis_asklist.md §K`):
    Dungeon Routes   G1 the driver · C-2 throttler on R · C-6 ts as verifier only · the CLEU
                     listener (arm on engage, unregister on disarm) · W7 port fidelity ·
                     the "listen for route" channel and route selection (§5) · user recovery
                     as a manual seek (G6, if it is a runtime control)
    Dungeon Run      G2 pin trace in capture · G3 the TEST DRIVE REMOTE (RI-3 + D-E: a visible
                     control, not a dispatcher line) · G4 overhaul first pass ·
                     G5 wipe SVs · the flatten/export · trash-count and boss-name offers (§3)
    prerequisite     Dungeon Run's flatten of a childless route → Dungeon Routes' input
    neither          any combat model; any per-dungeon knowledge; any route grading

**Acceptance is per product:** W1–W7 gate Dungeon Routes; the editor's own criteria (not yet
written) gate Dungeon Run. A green on one is not a green on the other.

**SEQUENCE (Battlewrath, scoping S10/S12, 2026-08-17):**
    1. capture spec — what a run must record vs not — then NEW SAMPLES
    2. the programmatic model — behaviours → how constructed → logical names (WA-kind
       "how does an author select"); vocabulary audit follows it (S3/S5/S7/S9)
    3. the OVERHAUL, first pass (scope §53-68)
    4. the MVP = **TEST DRIVE**, its own suite entry INSIDE Dungeon Run — the author IN THE
       WORLD hitting their waypoints (RI-3, 2026-08-18; an extension of the editor's play
       pacer, `/dr walk` is gone). The ASSURANCE side — walk nodes and triggers on a dataset,
       the py walk, per-node fitment — is the test/debug/diagnostic suite. Tell-and-trust made
       visible (S1/S4) on both.
    5. Dungeon Routes proper — written once the test driver has produced enough proof to be a
       basis. W7 grades it against the desk walk (D-2) until new samples say otherwise.
"Or we're building the driver on inventiveness instead of handling the dataset given."

---

_Status: **STABLE — every ⟂ line filled by Battlewrath, 2026-08-17.** This file is the target;
`driver_reconciliation.md §4` is decided against it, section by section (scoping — Battlewrath's;
the Analyst checks the result against this file afterward)._
