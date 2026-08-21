# ANALYST_LOG — what was settled, in one line each: IS · IS NOT · why · where

_Opened 2026-08-21 at Battlewrath's ask: **"Then a log to extract the IS / IS NOT and reasoning /
outcome."** The sibling of `ARCHITECT_LOG.md`, one level down: that log carries the ARCHITECT's
outcomes on the macro model; this one carries what the Addon creator and the Analyst settled
between them, and what Battlewrath ruled when an item reached him._

★ **THE FORM IS HIS AND PREDATES THIS FILE** (2026-08-19): **question · outcome · NOT statement ·
IS statement · cite.** ⚠⚠ **The NOT line is the point.** An outcome recorded only as what we chose
leaves the rejected shape free to drift back in; naming it once is what stops that. Every row below
was written in that form inside the inbox — this file is where they now live, because **a
conversation and its conclusions should not share a page.**

    THE INBOX   `Reconcile_inbox.md` — the CONVERSATION. Open items, options, measurements,
                marked reads. Each seat takes from it and inputs as needed.
    THIS LOG    the CONCLUSIONS. An item leaves the inbox and arrives here.

⚠ **THIS LOG DIRECTS NOTHING.** The CITE column names the record that governs; where a cite and a
row here disagree, **the cite wins**. It is an index of settled things, not a second copy of them.

⚠ **Derive status, never read it:** `py addons/tools/check_inbox.py`.

---

# 2026-08-21 — THE UI REFRAME AND THE DRIVER'S SETTLEMENTS

_Written 2026-08-21 from the items' own drain stamps, not from memory. ⚠ **The log was
20 items behind** — the invariant *"either a full entry in the inbox or a row here, never both"* was
violated the whole day it was written. ★ These are the eight that a cold reader needs first, because
they are the reframe the next build steps stand on._

    RI-33  Q  which does the driver need — the desk's machinery, or less?
           O  LESS. Build from need, not from precedence.
           ✗  segment · interpolated-z · `v_max` are NOT the driver's · W7.1 byte-equality is NOT
              its grade · precedence is NOT a reason to ship
           ✓  point + band + gate, and what is ABSENT is absent on purpose · the desk keeps its own
              machinery · the driver is graded on OUTCOMES at the ruled radii and cadence
           →  A11.2a · `rule.lua` · W7 (rescoped)

    RI-34  Q  can we poll below 0.2, and does the floor alone make it safe?
           O  0.1 — and NO, the floor alone changes nothing.
           ✗  0.2 is NOT a limit (it was a DEBOUNCE budget from COA_Landmarks; `OnUpdate` fires per
              frame) · the floor does NOT fix the approach · `MAX_CLOSING_SPEED` 30 is NOT ours
           ✓  POLL_MIN 0.10 owns the CROSSING · MAX_CLOSING_SPEED 100 (= `TELEPORT_VMAX`) owns the
              APPROACH · both move together or neither does anything · R, the floor and the ceiling
              are ONE relationship: `R_min = v_ceiling x POLL_MIN / 2 = 5`
           →  A11.2f · A11.2a · `sensor.lua` · A10.3e-R

    RI-36  Q  the model is not specific enough on CONSTRUCTION — how does a store become runnable?
           O  TWO PHASES, named by what they do: BUCKET, then STAGE.
           ✗  "pre-load" is NOT a term any more · the sensor is NOT the designator · construction is
              NOT the sensor's
           ✓  BUCKET once per run, MAY fail and should fail LOUDLY · STAGE per advance, MAY NOT fail
              · **if STAGE can fail, BUCKET did not do its job** · the bucket IS the stage; steps are
              the bare rows; a childless stage is an item of one
           →  model §A5b rows 23-27 · `bucket.lua`

    RI-37  Q  an open band has no wire spelling — which of three?
           O  RETIRED — the premise was wrong. There is no open band.
           ✗  `Rule.OPEN` is NOT a data state (it was the pure rule's fallback, since deleted) ·
              the picker does NOT go below 2.5
           ✓  the menu is CLOSED and floors at 2.5 · a store `band` of nil means the AUTHOR DID NOT
              PICK (RI-2), not "open" · the conversion is PER FIELD: stage/step -> 0, band -> 2.5
           →  model row 27 · A11.2h · `rule.lua`

    RI-38  Q  who DESIGNATES the current bucket?
           O  the ROUTE MANAGER — the one stateful owner.
           ✗  NOT the sensor (its own output would change its input mid-poll) · NOT `Bucket.Stage`,
              which hands out any stage asked for
           ✓  the manager owns `currentStage` with the completion ledger · the sensor RAISES, the
              manager PERFORMS the swap, after a poll returns · `FirstStage`, not 0
           →  A12.1a · A12.5a · A12.6a · §4b

    RI-40/41  Q  a stage-0 sequence, and two beacons sharing one step cursor?
           O  DISSOLVED BY THE STRUCTURE, not ruled on.
           ✗  `left`/`right` pairing is NOT expressed in authoring — it was a construction of the
              implementation · `[stage][step]` is NOT the shape · `Stage:Step` is NOT composed at
              runtime (row 11 forbids storing properties in a key)
           ✓  one bucket PER STAGE holding BARE ROWS · stage says WHICH BUCKET, step says WHICH ITEM
              · several items may hold Step:0 — always-eligible is a VALUE, not a slot
           →  model §A5b row 23 · RI-41's drain

    RI-44  Q  the development line items — when, and does any chain run first?
           O  BOTH CHAINS, the defect today, the engine on synthetics — with ONE sequence note over
              the pacing.
           ✗  the reader's screen does NOT come first · A/B client testing is NOT how we prove ·
              Dungeon Routes does NOT prove what Run already proved
           ✓  **Dungeon Run to RICHNESS first** · the bench proves on SYNTHETIC rows · Dungeon Routes
              EARNS everything Run proves · Chain 1 leads, Chain 2 to proof depth, Chain 3 waits
           →  `driver_architecture.md` §7 · RI-44's chains

    RI-46  Q  the object pane needs 714 on a 600 ceiling — fold, grow, or both at once?
           O  NONE OF THE THREE. DOCK / UNDOCK moves from a later job to a NOW job.
           ✗  the pane does NOT have to hold everything · 600 is NOT the side panel's budget · no
              zone defaults folded to make room
           ✓  the bolt-on has the MAP SURFACE'S vertical extent · sized to FIT THE LARGEST CONTENT ·
              a group has ONE declaration and TWO arrangements · the way back is carried by the pane
              that left, plus a dock-all strip
           →  `driver_ui_scope.md` D-C · A10.9a-h

⚠⚠ **TEN OLDER ITEMS ARE STILL OWED A ROW: RI-19 · RI-22 · RI-24 · RI-26 · RI-27 · RI-29 · RI-30 ·
RI-31 · RI-32 · RI-35.** ★ **Deliberately not written from memory** — those were drained before or
early in this Analyst's tenure, and a wrong IS / IS NOT line in an INDEX is worse than a missing
one, because the index is what people read instead of the item. **Each needs its item read first.**

---

# THE SETTLED SET — the MIGRATED items, flattened

⚠ **NOT "every drained item" — corrected 2026-08-20.** ★ The invariant, verified by complement:
**an item is EITHER a full entry above OR a row here, never both.** A drained item keeps its
prose in this file until that prose moves to `history/Reconciliation_inbox_drained.md`, and it
gains a row here at that moment. ⟶ 22 rows below; RI-19 · 22 · 24 · 26 · 27 · 29 · 30 · 31 ·
32 · 33 · 34 are drained ABOVE and await migration. **Nothing is unaccounted for — but do not
read this index as the whole set.**

_Form (Battlewrath, 2026-08-19): **question · outcome · NOT statement · IS statement · cite.**
The prose these came from is `history/Reconciliation_inbox_drained.md`; nothing was deleted.
★ **The NOT line is the point.** An outcome recorded only as what we chose leaves the rejected
shape free to drift back in; naming it once is what stops that._

⚠ **This footer directs nothing.** It is a settled-set index — the CITE column names the record
that governs. Where a cite and this line disagree, the cite wins.

    RI-1   Q  is a child's note copied per child, or referenced?
           O  the THIRD WAY
           ✗  NOT copied per child · NOT on the personal plane
           ✓  referenced in the STORE, owned in the PANE; sharing is a later re-point
           →  A4.2 · model §5

    RI-2   Q  does ReachOf return a raw value or a resolved default?
           O  SPLIT them
           ✗  ReachOf does NOT resolve · nil is NOT an error
           ✓  raw (nil = the author set nothing); the consumer resolves ±2.5; the author ticks
           →  A1.3 · model §3

    RI-3   Q  "walk" has meant two things - which is which?
           O  they SEPARATE
           ✗  `/dr walk` is NOT revived
           ✓  TEST DRIVE = its own suite entry inside Dungeon Run; assurance = the diagnostic suite
           →  A6.1

    RI-4   Q  what re-mints when a route is imported?
           O  ONLY THE RID
           ✗  NOT a full waterfall · the origin on someone else's data does NOT travel
           ✓  BID:CID carry unchanged; place carries as current; metadata outside identity survives
           →  BASIS positions · A8.4 · ledger §5.9-5.11

    RI-5   Q  are the two distance thresholds two kinds of sense?
           O  NO - they are ACTIONS at distances
           ✗  there is NO firing field · NO beacon-level "next" over children
           ✓  two (action, distance) pairs = two tabs = two steps; the pane is SENSE · WHAT I DO ·
              TRIGGER; the FIRST CHILD acts as the beacon
           →  model §1/§2 · A2.5

    RI-6   Q  is the CID counter route-scoped or per-BID?
           O  ROUTE-SCOPED, as shipped
           ✗  stage and ordinal are NEVER identity · two beacons on one stage is NEVER locked
           ✓  `RID:BID:CID`; only the RID re-mints; a collision is TOLD and the driver states it
           →  BASIS positions · A8.4

    RI-7   Q  does `activate` survive goTo's removal?
           O  GONE with it
           ✗  no node stores another node's IDENTITY
           ✓  the ordinal sub-ratchet is the hand-off; a jump is `set step N` - a number
           →  model §2 · A2.6

    RI-8   Q  does `onRamp` survive?
           O  GONE in the same commit
           ✗  NOT a second mechanism for entry
           ✓  entry = the childless beacon, else the FIRST CHILD. What survives is UPDATERS and
              ORDINAL, and both beacons and children have both
           →  A2.6 · BASIS positions

    RI-9   Q  are notes v1 or v2 (S8 against G1)?
           O  BUILD IT - S8 reversed, as a reversal
           ✗  notes are NOT deferred
           ✓  notes are IN v1; G1 stays in the standing order
           →  scoping S8 note · model §5 · A4

    RI-10  Q  one note table with two key shapes, or two tables?
           O  A SEPARATE SHELF
           ✗  export is NEVER a filter · the personal plane NEVER travels
           ✓  two tables; the words are "route note" / "personal note"; the author's label is
              "Route instructions"
           →  A4.2 · model §4b · store.lua:471

    RI-11  Q  which UI placement option?
           O  (d) - fix the canvas now, defer the rest
           ✗  UI placement is NOT argued before the overhaul
           ✓  check_rects' canvas is a RED; hand-placed controls are NAMED unverified
           →  A9.6

    RI-12  Q  is A4.2 closed?
           O  (b) - closed except the travel half
           ✗  the travel assert is NOT written yet
           ✓  the two-tables structural guard stands; the behavioural assert lands with A8.5
           →  A4.2 · A8.5

    RI-13  Q  relabel the personal note?
           O  NOT OPEN - RI-10 already ruled it
           ✗  NOT a reversal
           ✓  implementation of a drained ruling; relabel when the pane work happens
           →  RI-10 · adaptor

    RI-14  Q  where does acceptance composition live?
           O  ONCE, at the CALL LAYER
           ✗  NOT inside routes.lua · NO source-text scanner
           ✓  the headstone stays; the smoke sweeps every call site
           →  A1.2 · A1.4

    RI-15  Q  is boss a sense, and what is the better taxonomy?
           O  NEITHER - the class dissolved rather than got a better name
           ✗  boss is NOT a sense · player-state predicates are NOT senses (scrubbed, RI-17)
           ✓  sense = the LOCATION and the behaviour whilst in its R; boss is the ACTION word;
              the author's condition is KILLED only
           →  model §2 · A3 · A3.5 · A10.3a

    RI-16  Q  does the runtime lookup land before the first fold?
           O  YES
           ✗  NOT a deviation from the fold order
           ✓  one function over one constant table, pass-through on a miss; ROLE_TEXT and
              SENSE_TEXT retire into it. Same turn: a child completes when ALL its tabs have
           →  A10.2 precondition · A2.7

    RI-17  Q  how is a WHAT-I-DO row expressed?
           O  THE DECLARATION GRAMMAR
           ✗  NO separate condition field · falling / in-combat / encounter are NEVER terms
           ✓  a row IS one declaration `<sense>:<action>:<arg>`, stored and exported whole; the
              third sense-word is "When off"
           →  model §2 · A3.2 · adaptor · A10.3a

    RI-18  Q  the data model's six questions
           O  ALL SIX SETTLED
           ✗  the export is NOT a copy of the store · NO free text on the line
           ✓  identifiers and numbers only; two side tables; Stage:Step composed at export;
              reconcile-and-tell on import; order asserted at ingest; notes by NoteID in the
              editor too
           →  #3 §A · A11.1a/c · A8.6 · A4.2

    RI-20  Q  a version token, a coordinate bound, a non-finite - what does the format do?
           O  P1 DE-PRIORITISED · P2b CLOSED · P2a CARRIED
           ✗  NO version token now · a derived bound CANNOT refuse a bad value
           ✓  no V1 and no installed base means no stale reader to protect; precision follows the
              configured minimum radius
           →  #3 A17 · #3 §B

    RI-21  Q  none - it was an inventory of what the field does
           O  ABSORBED
           ✗  nothing in it was PROPOSED
           ✓  the techniques weighed and not taken are #3 §C; D1 and D13 became seeds S1 and S2
           →  #3 §C · #3 §D

    RI-23  Q  what is the unit that must be independently readable - the node or the row?
           O  THE NODE
           ✗  a row is NEVER interpretable cold · nothing AUTO-UPDATES · NO `0` in a dropdown ·
              beacon stages are NEVER fractional
           ✓  a node record plus row records; stage 0 = always eligible; whole-number beacons and
              the author's choice for ordinals; the absence is a TICK; the selector shows the store
              and derives nothing
           →  #3 §A1/§A3 · A10.3e

    RI-25  Q  identity, characteristics and behaviours as separate records?
           O  YES - TWO record kinds
           ✗  NO ownership table · the driver as a whole is NOT pure
           ✓  the address IS the chain; a pure RULE plus a stateful SENSOR that holds the resolved
              parameters, the two gate sets, and later the completion ledger
           →  #3 §A1/§A5 · A11.3



