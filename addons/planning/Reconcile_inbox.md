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

## RI-6 · Does a merge ever put two `BID:CID` spaces inside one RID? *(from RI-4, gates A8.4)*

**Where it came from.** Battlewrath, thinking aloud on the address under a merge:

    BID(1):1:CID(1):Nil      ->  BID(2):1:CID(1):1
    BID(1):1:CID(2):Nil          BID(2):1:CID(2):2
    BID(1):1:CID(3):1            BID(2):1:CID(3):2.2
    BID(1):1:CID(4):2            BID(2):1:CID(4):3

> *"Whilst confusing, would still run uniquely, and split apart on stage update cleanly."*

### ★ What the bench can settle from the code, so the ruling starts from fact

**Both counters live on the ROUTE, not the beacon** — `nextBeaconId(r)` and `nextChildId(r)` both
increment `r.<counter>` (`routes.lua`). So **within one route a CID is minted once, ever.**

★ Which makes his example WORK, and the reason his last sentence is true: children re-parented
from BID(1) to BID(2) **keep their CIDs**, stay unique, and gain ordinals under the new parent. A
later restage moves BID(2) and takes them with it, **because the binding is IDENTITY, not stage** —
his own §330 correction, holding under merge.

⚠ **The "confusing" part is real but is not a defect:** a CID minted under BID(1) and now living
under BID(2) is legal and unique, and the NUMBER implies a provenance that is no longer true. The
address is right; the *story* the number tells is stale. **Nothing reads that story** — but a human
does.

### ⚠⚠ The question underneath, and it is the one that can actually break

RI-4 ruled: on import **only the RID is re-minted; `BID:CID` carry unchanged**, because they are
unique within the RID. ★ That is safe when **an import creates a NEW route** — new RID, its own
untouched BID/CID space.

**It is not obviously safe when an import MERGES INTO AN EXISTING route.** Then two independently
minted BID/CID spaces share one RID, and both may hold `BID(1)` and `CID(1)`.

    (a) IMPORT ALWAYS MAKES A NEW ROUTE     merging is a separate authoring act performed
                                            AFTER, inside one route, where ids are already
                                            unique. ★ RI-4 stands untouched. Merge is the
                                            author re-parenting their own children.
    (b) IMPORT MAY MERGE                    then the importer must re-mint BIDs and CIDs on
                                            the way in, and RI-4's "only the RID re-mints"
                                            gains an exception. ⚠ And every instruction's
                                            owner field would need remapping - which is the
                                            failure mode RI-4's ruling removed (§21a: a
                                            missed instruction points at the WRONG NODE,
                                            silently, because the address is still
                                            well-formed).
    (c) MERGE IS NOT A FEATURE              the counters stay per-route, the question is
                                            moot, and it is recorded as refused rather
                                            than unasked.

**The bench's read, marked as the bench's:** **(a)**. It keeps RI-4 whole, keeps the owner fields
inert, and matches what the counters already do. ★ Merge-after-import is then an ordinary
re-parent inside one id space, exactly the case his example walks through — and it already works.

⚠ **I have no target text for this**, only the counters' behaviour and RI-4's shape.

### IMPACT

    ON A8.4 (next in the order)   the RID work assumes BID/CID are stable and route-scoped.
                                  Under (b) the migration would also have to define
                                  re-minting for the lower two segments, which is a
                                  materially bigger criterion. ★ So this gates A8.4's
                                  SHAPE, not its start - the opaque-RID defect (a colon in
                                  a route name) is real either way.
    ON SHIPPED CODE               nothing. Per-route counters already behave as (a) needs.
                                  Under (b) `nextBeaconId`/`nextChildId` gain an import
                                  path they do not have.
    ON THE DISPLAY                whichever way: a CID living under a BID it was not minted
                                  under is legal and reads oddly. ⚠ Worth knowing whether
                                  the pane should ever show raw ids to an author at all -
                                  §17a's split says the author sees `4.1:3`, and that has
                                  no such problem because staging is positional.

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
