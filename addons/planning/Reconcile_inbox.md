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

_RI-1..4 drained below and their records reconciled 2026-08-18. **RI-5 filed the same day, out
of RI-2's drain** — a detail arrived with a ruling that the bench had no model for, and it was
recorded as a consequence rather than a question. That is the failure this channel exists to
stop, so it is here._

## RI-5 · The two radii — how do `radius:listen` and `radius:sense` sit in the store? *(from RI-2)*

**Where it came from.** RI-2 drained with a detail the bench had no model for: *"the SAME control
shape for the two radii — **radius:listen (come here)** and **radius:sense (found)**."* ⚠ The bench
recorded that as a consequence and carried on, which is exactly what this inbox exists to stop —
so it is filed rather than noted.

**The question.** A node today carries ONE radius and a band (`radius` · `bandUp` · `bandDown`).
Two named radii do not fit that shape. **Where do they live, and what does the accessor return?**

    (a) TWO FIELDS ON ONE NODE     `radiusListen` + `radiusSense`, sharing one band.
                                   One node, one place, two numbers - the simplest thing for
                                   an author who is describing ONE spot they want found.
    (b) TWO STEPS ON ONE POSITION  the beacon carries `listen`, a flagged child carries
                                   `sense` (or the reverse). ⚠ This is T8's reading, taken
                                   from the flight list - *"not two radii on one node, but
                                   two steps on one position"* - which §15e re-ranked as
                                   BASIS-ONLY, so it is a candidate rather than a rule.
                                   G2's beacon reach already makes it expressible.
    (c) ONE RADIUS + ITS KIND      each node keeps one radius, and what it MEANS comes from
                                   the node's sense/role. Two radii = two nodes, deliberately.

⚠ **And two sub-questions that do not answer themselves whichever way (a)/(b)/(c) goes:**

    THE BAND    one band shared by both radii, or a band each? A `listen` at 40 yd and a
                `sense` at 5 yd plausibly want the same height tolerance - but nothing has
                said so, and §85's asymmetry was argued for ONE radius.
    THE BEACON  does a childless beacon get BOTH radii (it is the everyday unit and
                self-completes), or only `sense`?

**The bench's read, and it is weak — I have no target text for this.** (a) reads as what the
author is doing: one spot, *"tell them to come here from 40, and count it found at 5"*. (b) is
structurally tidier and matches how the flatten wants to emit steps. ★ **I would not build either
without the ruling**, because the two produce different data on disk and export carries whichever
we choose.

**IMPACT**

    ALREADY SHIPPED, and this is why it is filed now rather than later:
      SetChildReach / SetBeaconReach take ONE radius. `ReachOf` returns ONE triple.
      The pane renders THREE EDIT BOXES (radius · up · down), not the tick-slider RI-2
      names. ⚠ NONE OF IT IS WRONG YET - nothing has ruled two radii into the store -
      but all of it is the first thing (a) or (b) touches.

    IN FLIGHT, and the collision is real:
      A1.1 is mid-change - `ReachOf` becomes a PURE ACCESSOR reading one point's own
      fields (Analyst, accepted §324). ⚠ If (a) lands, "its own fields" becomes two radii
      and the accessor's SHAPE changes at the same time its SEMANTICS do. ★ Better to
      rule this BEFORE A1.1's change than to make the same function twice.

    DOWNSTREAM:
      export/import - the trim list carries whatever shape wins (RI-4's mint contract)
      the adaptor    - `radius:listen` / `radius:sense` are already filed as question-layer
                       rows; if (c) wins they are not two terms but one term with a kind
      the flatten    - (b) emits two steps by construction; (a) emits two steps from one
                       node, which is the denormalisation the flight list described

    NOT BLOCKED BY THIS:
      A9.1's audit · A8.4's RID + migration criterion · A5.3's checker · StageOf. The
      standing order runs regardless; this only blocks touching `ReachOf` again.

**Also for the drain — the control shape.** RI-2 names *a slider the author TICKS to change, with
light text ("changes the height of detection")*. The panes ship edit boxes. ⚠ Is that a change
that rides with this ruling, or its own UI pass? ★ The bench's read: **its own pass.** The store
shape is the decision; a box and a slider write the same field, and swapping them is cheap once
there is one field to swap them onto.

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

_Items above leave entirely once every record named carries them._
