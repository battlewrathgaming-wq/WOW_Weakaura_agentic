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

## RI-5 · The two thresholds — ⚠ REFRAMED §328. They are ACTIONS, not sense types.

**Status: WITH BATTLEWRATH, going up the chain.** *"So I'll take it up the chain to get a better
model, or see where it's a comment vs the model."* Nothing is built or filed against it until it
returns. This entry exists so the question does not get re-derived from the thread.

### The objection, and it corrects the bench's framing rather than answering it

The first cut of RI-5 asked *"how do `radius:listen` and `radius:sense` sit in the store"* — as
though they were two SENSE TYPES. **Battlewrath:**

> *"They are two ACTIONS. Not two sense types. Sense has: did you step on me, or are you still on
> me. Both are listen in a sense."*

    SENSE           did you STEP ON me   ·   are you STILL ON me
                    ⚠ that is the FIRING pair - the model's `once | while` (§2, G15),
                    which the model itself records as "no model section, no code"
    THE TWO RADII   not senses at all. Two DISTANCES, each with an ACTION at it:
                    come here (point the tracker) · found (satisfy)

★ **Both radii are listening either way.** What differs is not the sensing — it is what happens at
each distance. So the bench's whole framing was one axis out.

★★ **And the basis said so; I read past it.** The flight list: *"one child with two thresholds
(supertrack within 150, complete within 50) becomes TWO steps sharing an anchor, each carrying its
own radius."* **`supertrack` and `complete` are ACTIONS.** The pairing was written down; I took the
distances and missed what they were distances TO.

### What the bench has PULLED rather than left standing

    the adaptor rows   `radius:listen` and `radius:sense` are pulled (§328), not reworded.
                       ⚠ The names encode the fault - `radius:sense` reads as A KIND OF
                       SENSE and it is not one. A better word for a wrong shape is still
                       a wrong shape.
    the (a)/(b)/(c)    the first cut's options are withdrawn. They asked where two SENSES
    options            live; the question is now how an anchor carries two ACTIONS at two
                       distances, which is a different question with different answers.

### What the question becomes, stated so the chain has something to answer

    1  does ONE anchor carry two (action, distance) pairs, or is each pair its own node?
    2  is `sense` therefore the FIRING axis (step-on / still-on) - i.e. is this G15
       arriving, rather than a new thing?
    3  if so, what is the relationship between `sense` as the bench SHIPPED it in G10
       (bossEngaged / bossKilled - an EVENT kind, model §2's third row) and `sense` as
       step-on / still-on (a POSITION kind's firing)? ⚠ Both are called sense in the
       model's box. **The bench does not know whether those are one axis or two, and
       that is the question underneath this one.**

⚠ **(3) is the one the bench would most like answered**, because G10 shipped `sense` with two
EVENT values and no firing values, and if firing is the same axis then the shipped field is
carrying two unrelated kinds of answer.

### IMPACT — unchanged from the first cut, and one addition

    IN FLIGHT     A1.1's change to a pure accessor still waits on this. ⚠ Better ruled
                  before it lands than to make the same function twice.
    SHIPPED       G2 stores ONE radius per point; G10's `sense` holds EVENT values.
                  ★ NEW: if (2)/(3) resolve toward one axis, `sense`'s VALUE SET moves,
                  not just its storage - and that touches SENSES, SetChildSense, the
                  smoke's A3 block and six filed mutations.
    NOT BLOCKED   A9.1 · A8.4 · A5.3 · StageOf. The standing order runs regardless.
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
