# Reconcile_inbox — the relay for questions that need a ruling

_Standing channel, opened 2026-08-18 (§325) at Battlewrath's ask. **The bench files items here;
the designer DRAINS them** — rules, reconciles the records against the outcome, and tests the
change against its impact. Kept short on purpose: an inbox that grows is one nobody empties._

## How it works

    THE BENCH FILES     a question it cannot settle alone, with everything needed to settle it -
                        options, costs, what is already built on an assumption, and the bench's
                        own read MARKED AS THE BENCH'S so it can be overturned in one word.
    THE DESIGNER DRAINS rules it · reconciles every record the ruling touches · checks the
                        IMPACT list below the item and says which parts actually moved.
    THE ITEM LEAVES     to §DRAINED at the foot with a one-line outcome and where it landed.
                        Removed entirely once the records carry it.

⚠ **An item is not a discussion.** If it needs a conversation it belongs in chat first and arrives
here as a question with options. **A row with no options is not ready to be drained.**

★ **Every item carries an IMPACT block**, because *"test against impact"* is the drain's second
half: a ruling that changes nothing on disk and a ruling that invalidates a shipped guard are
different events and should not look the same in an inbox.

⚠ **This file is a CHANNEL, not a governing document.** It directs nothing; it holds questions
until they are answered. `DRIVER_BASIS.md` is the authority and should carry a pointer to this so
nobody mistakes an open question here for a ruling.

---

# OPEN

_RI-1..5 drained below. **RI-6 filed 2026-08-18** from Battlewrath thinking aloud on the address
under a merge — he said "I'm unsure on this. But I'm thinking", and the thinking landed on
something the bench can only half-answer from the code. Next item takes RI-7._

## RI-6 · Is `CID` scoped to the ROUTE or to its BID? *(REFRAMED §332 — the first cut had the wrong merge)*

### ⚠⚠ The bench's first cut asked the wrong question entirely

I read Battlewrath's two blocks as children being **re-parented** from BID(1) to BID(2), and built
an item about two id spaces colliding on import. **Both halves were wrong.**

> *"I say merge on GROUP. We have no transfer of child to beacon. Nor intend to."* · *"Merge on
> STAGE."*

    BID(1):1:CID(1):Nil        BID(2):1:CID(1):1
    BID(1):1:CID(2):Nil        BID(2):1:CID(2):2
    BID(1):1:CID(3):1          BID(2):1:CID(3):2.2
    BID(1):1:CID(4):2          BID(2):1:CID(4):3

★★ **Both beacons sit at STAGE 1.** That is the merge — **two GROUPS occupying one stage**, each
whole, each keeping its own children. **A child never moves between beacons and is not intended
to.** The address is `BID(<id>) : <stage> : CID(<id>) : <ordinal>`, and only the middle segment is
shared.

★ **And it is already the shipped behaviour.** `Routes.StageMatches(id, stage, except)` counts
other beacons on a number and **never refuses one**; `object.lua:294` renders it as
*"match N"* in red beside the stage box, *"free"* otherwise. §81's rule: it *"never refuses one, it
just stops a collision being invisible at the moment you would create it."* **Merging on stage is
authorable today and told.**

★ *"Split apart on stage update cleanly"* follows: move one beacon to stage 2 and they separate.
Nothing else moves, because **no child ever referenced a stage** — §330's identity rule again.

### The question that actually remains, and it is one line

His notation shows **`CID(1..4)` under BID(1) AND `CID(1..4)` under BID(2)**. Today that cannot
happen in one route:

    nextChildId(r)   increments `r.nextChildId` - the ROUTE's counter (routes.lua)
    nextBeaconId(r)  the same

So a CID is minted once per route, ever, and BID(2)'s children would be CID(5..8).

    (a) CID STAYS ROUTE-SCOPED   the code as shipped. His listing is then illustrative
                                 rather than literal, and BID(2)'s children read CID(5..8).
                                 ⚠ Nothing to build; the question closes as "notation".
    (b) CID BECOMES BID-SCOPED   a child's identity is the PAIR (BID, CID), and CID need
                                 only be unique inside its parent - which is exactly what
                                 "no transfer of child to beacon" makes safe: a child that
                                 can never move cannot outlive its scope.
                                 ★ It also makes his listing literal, and makes each group
                                 self-describing - CID(1) is always "the first child of
                                 this beacon" rather than "the nth child minted anywhere".
                                 ⚠ It is a MIGRATION: existing routes carry route-scoped
                                 CIDs, and A8.4's migration criterion would cover both.

**The bench's read, marked as the bench's: (b) is the better model and (a) is the cheaper truth.**
★ (b) follows from his own constraint — a child that cannot be re-parented has no reason to carry
a route-wide number, and per-BID numbering makes a group readable on its own. ⚠ But it changes
minting and needs a migration, where (a) needs nothing and is what the counters already do.

### IMPACT

    IF (a)   nothing. The item closes as a notation clarification and A8.4 proceeds on
             RID alone.
    IF (b)   `nextChildId` moves from the route to the beacon; existing routes need their
             CIDs renumbered per-BID, which folds into A8.4's migration criterion rather
             than being a second one. ⚠ And the ADDRESS gains a real property it does not
             have today: `BID:CID` becomes self-describing rather than a pair of
             independent counters that happen to be unique.
    EITHER   merge-on-stage needs NO work - it ships, it is reported, and §330's identity
             rule already makes the split clean.
    ON RI-4  unaffected either way. Import re-mints the RID; under (b) the lower segments
             are already scoped beneath it, which if anything makes RI-4 tidier.
---

# DRAINED (2026-08-18, Battlewrath; records reconciled by the Analyst)

    RI-1  THIRD WAY — referenced in the store, owned in the pane. §91 survives; sharing a note
          across children is a later re-point. → acceptance A4.2 names the world; G1 unblocked.
    RI-2  THE SPLIT — `ReachOf` raw (nil = author set nothing); consumer resolves ±2.5. UI: a
          slider the author TICKS to change, with light text ("changes the height of
          detection"); the SAME control shape for the two radii — radius:listen (come here) and
          radius:sense (found). → acceptance A1.3 reworded; model §3 defaults carry the UI note.
    RI-3  "walk" has meant two things and they separate: the author IN THE WORLD hitting their
          waypoints = TEST DRIVE → its own suite entry INSIDE Dungeon Run (option b), an
          extension of the editor's play pacer; an ASSURANCE piece (offline replay, the py walk,
          per-node fitment) = the test/debug/diagnostic suite. → acceptance A6.1 home = test
          drive; W-tests stay the diagnostic side. `/dr walk` is not revived.
    RI-4  BEST WORKING MODEL (his "unsure exactly"): a node carries created-from (origin data
          point) and current; origin is METADATA once not current. On import to another
          author's editor, **ONLY THE RID IS RE-MINTED** — past the RID everything is unique to
          it, so `BID:CID` carries unchanged (no full waterfall). Place carries as current;
          metadata OUTSIDE identity/place (notes, radii, bands, names) SURVIVES; the origin-on-
          someone-else's-data does NOT travel — the import landing becomes the new origin. So
          export-trims governs, the ledger's round-trip law compares against the MINT CONTRACT
          (identity · place · properties), one-door and zero-trust untouched. → DRIVER_BASIS
          positions; ledger §5.9–5.11 want a banner (bench); addressed store / RID may proceed.

    RI-5  DRAINED (Battlewrath, 2026-08-18) — the two thresholds are ACTIONS at distances, not
          sense types. (1) one anchor, two (action, distance) pairs = TWO TABS -> two steps in the
          flat form. (2)/(3) `sense` = the KIND (reach here + distance · boss engaged/killed ⟨name⟩
          · falling · in combat); there is NO firing field — time lives in WHAT I DO as an
          open/close pair, DURING (whilst on) | WHEN OFF, plus IF SEEN (once | every) as its own
          control; G15 (`while`) IS that pairing. Advance / set are ACTIONS in what-I-do, per tab;
          no separate "what happens next"; a beacon-level next exists only for a childless beacon
          (with children the beacon is not in play — its FIRST CHILD acts as the beacon: lure +
          note; last delete; tabs return to the parent; completion SHED to any child; taste: the
          parent is the biggest node, children are the discrete placeable ones). Position is the
          NODE's, not on the pane. → model §1 (beacon), §2 head; acceptance A2.5 (new); A1.1's
          pure-accessor change UNBLOCKED; `sense`'s shipped value set and the A3 block STAND.

_Items above leave entirely once every record named carries them._
