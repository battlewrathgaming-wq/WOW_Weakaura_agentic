# Reconcile_inbox — the relay for questions that need a ruling

_Standing channel, opened 2026-08-18 (§325) at Battlewrath's ask. **The bench files items here;
the designer DRAINS them** — rules, reconciles the records against the outcome, and tests the
change against its impact. Kept short on purpose: an inbox that grows is one nobody empties._

## How it works

    THE BENCH FILES     a question it cannot settle alone, with everything needed to settle it -
                        options, costs, what is already built on an assumption, and the bench's
                        own read MARKED AS THE BENCH'S so it can be overturned in one word.
    ★ A TIE BREAK      is a DIFFERENT SHAPE (Battlewrath, §342): "tie break with instruction
                        instead of deliberation." When two governing docs disagree the rule has
                        ALREADY decided which wins - weighing them again is the builder doing
                        the thing the rule forbids. So it states the tie and lists INSTRUCTION
                        LINES to pick from. No bench read.
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

_**RI-10 filed 2026-08-18**, and it stops G1 one line short of the build. A4.2 names
`Store.NoteTable` — which is ALREADY the PERSONAL note plane, a store whose written contract is
that it is *"not part of a route"* and *"never travels with an exported route"*. RI-4 says notes
DO travel. ★ Battlewrath: *"Personal notes aren't reflected in the model currently as they had
no pressure. But it's good to de-conflate and properly scope the difference."*_

## RI-10 · DE-CONFLATE the two note kinds, and scope the difference *(blocks G1's store)*

**Battlewrath, filing it:** *"Personal notes aren't reflected in the model currently as they had
no pressure. But it's good to de-conflate and properly scope the difference."*

⚠ **The collision is live in A4.2's wording.** It says a reader note *"creates/updates a
`Store.NoteTable` entry keyed to that child"* — and `Store.NoteTable()` is **already** the
PERSONAL note plane, whose own contract at `routes.lua:1408` is:

> *"**NOT PART OF A ROUTE**, and that is the whole point of them. §60: 'personal notes will have
> their own note plane, **with the route note plane under it**.' They are YOURS — so they **never
> travel with an exported route**, they need no route to exist."*

★ **So a reader note stored there would be a note that MUST travel, living in the one store built
not to** — against RI-4, already in `DRIVER_BASIS`: *"metadata OUTSIDE identity/place (notes,
radii, bands, names) SURVIVES."*

### The two kinds, by their properties — fact, not opinion

    |                    | PERSONAL (exists)          | READER / ROUTE (G1, does not exist)  |
    | whose              | YOURS                      | the AUTHOR's, for the READER         |
    | belongs to         | a MAP PLANE, keyed mapID   | a CHILD, keyed by its address        |
    | needs a route      | NO - stands alone          | YES - it is part of one              |
    | travels on export  | NEVER (§60, explicit)      | YES (RI-4: notes SURVIVE)            |
    | in the model       | ⚠ ABSENT - "no pressure"   | YES - "say a note (≤ ~200)", §2      |
    | in the code        | NotePlane/AddNote/GetNotes | nothing                              |
    | the promoter       | offered ABOVE the divider, | n/a                                  |
    |                    | ungated by the route (§61) |                                      |

★★ **They agree on nothing except the word.** Same noun, opposite answers on every row that
matters — which is why the wording collided the moment G1 came up rather than years later.

### INSTRUCTIONS — pick one line for the STORE, one for the WORD

    STORE
    S-a  "A route note plane, under the personal one."   §60's own phrasing. A second plane
                                                         beside `d.notes`, keyed by the child's
                                                         RID:BID:CID. A4.2's wording corrected
                                                         to name it.
    S-b  "Same table, namespaced."                       One store, two key shapes. ⚠ Then
                                                         export has to filter by key shape, and
                                                         a filter is the thing that gets missed.
    S-c  "On the child."                                 ⚠ Reverses RI-1 and re-breaks §91.
                                                         Listed for completeness, not proposed.

    WORD
    W-a  "personal note" / "reader note"      the model already says READER for the audience.
    W-b  "personal note" / "route note"       matches §60's own phrase, "route note plane".
    W-c  something else at the naming pass    ⚠ then the code needs a placeholder that is not
                                              either word, or it will stick.

### ⚠ And the model has a real gap, which is the scoping half of the ask

**Personal notes are ABSENT from `driver_programmatic_model.md`.** They exist in code, in §60/§61
rulings, and on the promoter's surface — and the model that governs the build does not mention
them. ★ That was fine while nothing pressed on it; G1 is the press.

    the model needs   one line saying personal notes exist, are NOT route content, and are
                      out of the driver's scope entirely - so the next reader does not meet
                      `NotePlane` in the code and wonder which document lost it.

### IMPACT

    G1            BLOCKED on the STORE line only. The pane field, the ≤200 cap and A4.3's
                  "no note renders nothing" are the same under S-a and S-b.
    A4.2          its wording changes under S-a or S-b either way - it names a store that
                  means something else today.
    export        under S-a the filter is structural (a different plane); under S-b it is a
                  key-shape test somebody has to remember. RI-4 says notes travel, and only
                  the ROUTE kind may.
    §24           unaffected and worth stating: A4.2 keys the NOTE BY THE CHILD, so the child
                  holds NOTHING. Nothing can dangle. ★ The "re-point to share" action is where
                  a reference would first appear, and it is correctly deferred.

---

_RI-1..9 drained below and their records reconciled. **RI-10 is OPEN, above.** Next item takes RI-11._

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

    RI-6  DRAINED (Battlewrath, 2026-08-18) — (a) the CID counter stays ROUTE-SCOPED, as the
          code ships. His reason: fewer MISFIRES and less REFERENCING — one global press that
          takes the beacon ID and stamps its running count; (b) would have to look up the
          beacon, count its history, then mint. Identity = `RID:BID:CID`; the full path is
          unique because RID is; only RID re-mints on import (RI-4). No migration for CIDs;
          A8.4 covers the RID alone. Stage/ordinal are properties, never identity; merged-by-
          stage beacons split cleanly because children are referenced through their parent.
          Two beacons on one stage is an authoring collision — TOLD (red "match N"), NEVER
          locked; the driver degrades deterministically and states it (bench). → BASIS
          positions; acceptance A8.4 note; nothing else moves.

    RI-7  DRAINED (Battlewrath, 2026-08-18): `activate` GONE with goTo — it stored another
          node's identity (outward pointing on the mechanical test); the ordinal sub-ratchet is
          the hand-off. Model §2 box struck; scoping §117 superseded by steps (BASIS). If a
          satellite ever must jump the chain: `set step N` (a number). No code deleted.
    RI-8  DRAINED (Battlewrath, 2026-08-18): `onRamp` GONE in the same commit — a second
          mechanism for one fact. Entry = childless beacon → the beacon; with children → the
          FIRST CHILD (acts as the beacon; the lure; can be step 1); then whatever the author
          laid out fires (ordinal 1 sensed / a satellite first). Co-location for the rare
          separate-lure case. Custody comment, chip, 3 interface rows, 2 functions removed.
          **His framing of what survives: UPDATERS and ORDINAL — and both beacons and children
          have both now** (a beacon: ordinal on the stage line, or a non-ordinal updater =
          recovery/boss; a child: ordinal = step, or non-ordinal = satellite/updater).
    RI-9  DRAINED (Battlewrath, 2026-08-18): **BUILD IT — I-2. S8 REVERSED by him as a
          reversal, dated:** notes are IN v1. S8 gets the supersession note; A4 proceeds as
          written (RI-1: referenced in store, owned in pane); G1 stays in the standing order
          (before the test drive); model §5's G1 correction is itself corrected back.

_Items above leave entirely once every record named carries them._
