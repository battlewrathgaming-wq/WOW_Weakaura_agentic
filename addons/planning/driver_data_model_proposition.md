# THE DATA MODEL — the bench's proposal, and the gaps it lets us name

_Addons bench, 2026-08-18 (§375). **A proposal, not a governing document** — it directs nothing.
Written at Battlewrath's ask after the shaping run recorded in `audit/data_model_findings.md`.
The point of it is §5: HOW is mostly solved, so the GAPS can be enumerated instead of guessed at._

---

## 0 · THE TWO ACCEPTANCES

Battlewrath, 2026-08-18, closing the shaping:

> *"We accept TABLES, where they keep the line read light. We accept COMPOSING, where that is
> the correct solution."*

★ Both are exceptions to a default the bench already holds — one line, one truth, derive don't
store — and both are earned rather than convenient:

    A TABLE      is accepted when it takes weight OFF the line the driver reads. A side table
                 the driver never opens costs it nothing and costs the format its free text.
    COMPOSING    is accepted when the value is DETERMINISTIC from something already true, so
                 storing it would be a copy that can lie (A8.1's `StageOf`, one layer out).

⚠ And the consequence he named: **the editor's store is NOT 1:1 with the export.** That is a
DECISION here, not a drift — see §4.

---

## 1 · THE LINE — identifiers and numbers, nothing else

    MapID : RID : Stage : Step : BID : CID : POS : R : Band : Next:N : Sense : action : trigger : arg

**Gate order first** — `MapID` and `RID` are bucketable at ingest and cost nothing per pass;
`Stage:Step` is the lock-out, tested before any payload. Then the address, then the sensing
payload, then the node's characteristic, then the row.

★★ **NO FREE TEXT ANYWHERE ON THE LINE.** Every human-authored string is an ID reference
(§2), including the `arg` — *"even the Arg can be IDs, so it knows which to present to the
user."*

⚠⚠ **Which deletes a whole problem rather than solving it.** With no free text there is nothing
to escape, no delimiter to defend, and no sentinel needed on the line at all. The reject-at-input
rule (*"nice-ness breaks down when you can break the reader"*) applies to the TABLE writers
instead — one class of door rather than six.

★ **And it makes isolation CHECKABLE rather than asserted:** a smoke can hold that no line
carries a token which is not a number or an identifier, and it goes red the day a label is put
back into a payload.

---

## 2 · THE TABLES — address → text, and the driver never opens them

    NAMES     MapID
              RID:Name
              RID:BID:Name
              RID:BID:CID:Name

    NOTES     RID:BID:CID:NoteID : content

★ **This is what resolves reconstruction.** Names carry over — they are simply not on the
driver's path. So the choice between *"nodes are iconography and cannot be named"* and *"names
ride the line"* is not a choice that has to be made: nodes keep names, the driver never loads
them.

★★ **And the note table is RI-1 arriving at its destination.** RI-1 ruled notes *"referenced in
the STORE, owned in the PANE"*, with sharing *"a later re-point"*. A `NoteID` on the line IS the
reference — two rows carrying one NoteID is sharing, and it costs nothing rather than being a
later feature.

⚠ Both tables have exactly ONE free field and it is LAST after its key, so *everything after the
address is the value* parses without escaping. Same trick as arg-last, in the one place it is
still needed.

---

## 3 · WHAT IS STORED vs WHAT IS COMPOSED

    STORED       identity  RID · BID · CID · NoteID          never moves
                 place     POS · R · Band
                 behaviour Sense · action · trigger · arg · Next:N
                 character ordinal

    COMPOSED     Stage : Step        derived at EXPORT from the live tree

★★★ **`Stage:Step` are composed, and that answers the objection they raised.** They are
PROPERTIES (RI-6) — they move when an author restages — so putting them in a stored key would
re-key a note the first time anybody reordered anything. `smoke_dungeonrunroutes:658` already
asserts exactly that: *"THE NOTE FOLLOWED A PROPERTY: restaging the beacon and reordering the
child must not move a note."*

★ Battlewrath: *"They can be composed at export. They are deterministic at read time. And
without them you don't know when to show the note."* So the driver gets the liveness it cannot
work without, and the store keeps a key that cannot rot. **Same law as `Routes.StageOf`** (A8.1:
one hop, computed, never stored, with a live mutation that fails if a stale copy is believed) —
applied at the export boundary instead of at a call site.

---

## 4 · THE STORE IS NOT 1:1 WITH THE EXPORT — and that is correct

    EDITOR    many tables, references, derived views, the capture corpus beside it
    EXPORT    flat lines + two side tables, everything an id, nothing derived left implicit
    DRIVER    the lines only. Never the tables, never the store, never an import path

⚠ **A8.6 says "the flat form IS the stored form"**, and this proposal is in tension with it as
worded — the export is a PROJECTION of the store rather than a copy of it. ★ Reported, not
resolved: A8.6's own criterion is *"panes are views over the flat list"*, which is about panes
not holding second copies, and that still holds. But the sentence and this shape want reconciling
before either is built against. **(GAP 1.)**

★★ And the split is not free-form: everything the export drops is either **derivable** (§3) or
**not the consumer's** (the capture corpus — 4 MB of samples against 2 KB of route, measured in
`audit/data_model_findings.md` §6b). Which is the same measurement that justifies Dungeon Routes
being a separate addon at all.

---

## 5 · THE GAPS — the reason for the exercise

_HOW is mostly solved. These are what is left, and naming them is the deliverable._

    G1  A8.6 vs PROJECTION. "The flat form is the stored form" against an export that is a
        projection. §4. Wording, or a real disagreement - the bench cannot tell which.

    G2  NO UPDATE PATH, BY CONSTRUCTION. RI-4 re-mints the RID on import, so an export imported
        twice is TWO ROUTES, not a route and its revision. A consumer wanting the new version
        holds both and deletes one by hand. ⚠ And they are indistinguishable except by RID -
        same name, same beacons - which makes §374's `promoter.id` load-bearing beyond what it
        was built for.

    G3  ONE LINE PER ROW, OR A REPEATING GROUP? A node has several rows (A2.7: ALL tabs must
        complete). Arg-last FORCES one line per row - so the node-level fields (`Next:N`) repeat
        on every row of that node and can disagree with themselves. Either first-occurrence
        wins and the rest are ignored (⚠ silently ignoring hides a bad export), or import
        reconciles them, or node fields move to their own record type.

    G4  `Next:N` - ONE FIELD OR TWO POSITIONS? `DRIVER_BASIS:181` rules Next is ONE field.
        `Next:N` on the wire may be one field in two positions, which is coherent - but it has
        to be SAID, or the wire form teaches the next reader that `Step` beside a stranded `4`
        is expressible.

    G5  THE REPRESENTATION. Positional array, serialised line, or keyed table? Decides whether
        field order costs anything (a hash lookup does not care) and whether "empty means
        absent" is expressible. Open since `audit/data_model_findings.md` O1.

    G6  IS ROW ORDER PART OF THE FORMAT? The sort-order gate (no-stage first, then stage, then
        step) makes "always listen" free - and makes order a LOAD-BEARING CONTRACT living in
        the exporter. Asserted on ingest, or not depended upon. Open since O2.

    G7  POS AND BAND ARE COMPOUND. Three numbers and two. Their internal separator has to be
        pinned or a positional parse cannot count.

    G8  WHO RESOLVES NAMES FOR A HUMAN? The driver reports `hit · skip · false_advances` against
        `RID:BID:CID`, which is right for it and unreadable in a report. The editor has the name
        index; a bare consumer may not. ★ The face/meta split one layer out, and it decides
        whether the readout ships with a table.

    G9  THE INDEX INHERITS THE RE-MINT. Only the RID re-mints (RI-4), so `RID:BID:CID:Name` keys
        migrate with it. Nothing new as a rule; one more table to walk, and forgetting it
        orphans every name in the file.

    G10 G1's NOTE STORAGE DIFFERS FROM THIS. `SetRouteNote` stores the TEXT keyed by
        `RID:BID:CID` (§346, shipped). This proposes `NoteID → content` with the row carrying
        the id. ⚠ A4.2's test passes either way - *two children, independently typed → two
        entries* - so the suite will not tell anyone which world they are in.

    G11 EXPORT MUST BE EDITOR-SIDE, ALWAYS. Composing `Stage:Step` requires the live tree. That
        is fine and probably obvious, but it means export can never be a consumer-side act, and
        the two-addon split has to carry that.

---

## 6 · WHAT THE BENCH TAKES AS SETTLED (correct me)

    · the line carries identifiers and numbers only; every human string is an ID ref
    · names live in an address-keyed index the driver never opens
    · notes are `NoteID → content`; the row carries the id, so sharing is a re-point
    · `Stage:Step` are COMPOSED at export, never stored on a key
    · gate order: MapID · RID · Stage:Step before any payload
    · reject the reserved character at ANY input - a reader you can break is not a place
      for leniency
    · the export is a PROJECTION; the store is richer, deliberately

---
_Nothing here is built. §5 is the deliverable; §6 is what §5 rests on and is the part most
worth disagreeing with._
