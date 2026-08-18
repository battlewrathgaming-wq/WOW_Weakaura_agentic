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

## RI-1 · The note: OWNED by the child, or REFERENCED from a table? *(R1 · B2 · T11)*

**The question.** When an author types a note on a child, is that string a field on the child, or
an entry in a shared table the child points at?

    OWNED       `child.note = "pull left, LOS the caster"`. Simple, no new object. Two
                children with the same note hold two copies; editing one changes one.
    REFERENCED  `child.note = <id>` into `Store.NoteTable` (`d.notes` — ★ the table ALREADY
                EXISTS and is empty). Edit once, everything pointing at it changes.
    THIRD WAY   referenced in the STORE, owned in the PANE — the author sees a text box on
                the child and never meets a "note object"; sharing one note across children
                is a separate, later action. **Analyst's position; the bench agrees.**

**Why it was ruled once already.** §91 REMOVED the per-child note setters on Battlewrath's words:
*"with ids a note is likely a CONSUMER several children reference — you update one note. On route
export, the same note or a ref lookup is set into both."* ⚠ Going OWNED re-breaks that ruling, so
it needs to be a deliberate reversal rather than a default.

**IMPACT**

    if OWNED        ~10 lines, no new object. ⚠ §91's ruling is reversed and should say so.
                    Export carries nothing extra.
    if REFERENCED   the author gains an object that can be ORPHANED - deletion, cleanup and
                    a "which children use this" question all become real. Export must carry
                    the note table, which touches RI-4's trim list.
    either way      A4.1 holds unchanged - "a note resolves to EXACTLY ONE string at runtime".
                    A4.2 is the row that names which world we are in; it was written to hold
                    both. G1 is BLOCKED until this lands and nothing else is.

## RI-2 · The band: does the ±2.5 default live in `ReachOf`, or in the consumer? *(R2 · T10)*

**⚠ The number is not in question.** §287 settled ±2.5, both directions, a reject check erring
tight. This is only about where the default is applied.

**And the two positions may not be opposed.** A1.3 wants ±2.5 to apply to a node whose author
typed nothing; §12b P1 wants `ReachOf` not to RETURN a default that is indistinguishable from a
typed one. R6's raw/resolved split satisfies both, and the code already uses it twice
(`OutcomeOf`/`Outcome`, `SenseOf`/`Sense`):

    ReachOf(x)              returns nil        the RAW read - "did the author set a band?"
    the consumer applies    2.5 when nil       the RESOLVED read - "what band does this have?"

**The bench's read:** the split above. The author configures nothing and gets ±2.5; the bench can
still tell an authored 2.5 from an unset one.

**IMPACT**

    if the SPLIT      nothing shipped changes. A1.3's wording moves from "ReachOf returns
                      ±2.5" to "the resolved band is ±2.5 when unset", and P1 stands.
    if IN ReachOf     one `or` on one line in `routes.lua`. ⚠ And the bench loses the
                      ability to tell "unset" from "typed 2.5" at the read - which matters
                      for the adaptor's question layer, because an author who typed 2.5
                      answered a question and one who typed nothing did not.
    blocking          nothing. DRIVER_BASIS says G2 → ordinal → G10 do not wait on it,
                      and they did not.

## RI-3 · Where does the test driver live? *(R3 · B3 · T12)*

**⚠ The option as written may not exist.** `/dr walk` is GONE — §112 removed `walk.lua`, and it
survives only in two source comments. Its unrunnable-stages report now lives as one line in the
object pane. So *"a mode of `/dr walk`"* is not a mode of anything currently running.

**So the real question is where the test driver lives:**

    (a)  revive `/dr walk` as a suite entry, the driver as a mode of it     — S10's "suite option"
    (b)  its own entry INSIDE Dungeon Run                                    — target §9's MVP:
         *"a TEST DRIVER as a suite option INSIDE Dungeon Run"*
    (c)  neither — it belongs to the consumer addon, and Dungeon Run only exports to it

**The bench's read:** (b). The thing being tested is *the author's route in front of the author*,
which is Dungeon Run's side of target §9's sorting rule. ★ And §7 noted this may be an EXTENSION
rather than a build, which would make item 2 materially smaller either way.

**IMPACT**

    if (a)   `/dr walk` has to come back first - a build before the build.
    if (b)   item 2 lands beside the existing suite entries; no revival needed.
    if (c)   item 2 leaves Dungeon Run entirely and target §9's prerequisite (*"the producer
             must be able to write something the consumer can run"*) becomes the whole of it.
    blocking A6.1 and A6.2 are UNCOVERED until this lands. Nothing else waits.

## RI-4 · `satnav_ledger.md` laws 6–9 vs "export trims to what import will mint" — which governs?

**They conflict exactly, and the conflict is one line.** The ledger's contract (§5.10):

    unpackage(package(route)) == route      for every field, every kind of point

*"A round trip is the agreement. A field the packer writes and the unpacker ignores dies in the
round trip and the test says so."* ⚠ **Trimming breaks that equality by design** — if export drops
`atX/atY/atWorldX/atWorldY`, the id counters and the placement pair, the round trip cannot return
`== route`.

**The bench's read: compatible once the comparison is redefined, and the ledger's architecture
survives whole.**

    ONE DOOR              package/unpackage, our own addons use it too — unaffected
    ZERO-TRUST BOTH ENDS  including the re-export-laundering case — unaffected
    THE ROUND TRIP        survives as the agreement, but compares against the MINT CONTRACT
                          rather than the stored bytes: same places, same identities, same
                          properties, and no origin/current pair BECAUSE IT HAS NEVER BEEN
                          DRAGGED — which is true of it on the far side.

⚠ **Context the designer should have:** the bench walked into this material mid-design and was
stopped — *"You're reading the archive. Not the build target."* The ledger is older basis. **Which
way this goes, it wants a line in `DRIVER_BASIS` so nobody walks into it again.**

**IMPACT**

    if the LEDGER governs unchanged   "export trims" is withdrawn and export carries the mint
                                      data. ⚠ Then an imported route arrives already-dragged,
                                      carrying an origin it never had - which contradicts
                                      "the import is the minting".
    if EXPORT-TRIMS governs           the ledger's §5.10 keeps its laws and its round-trip
                                      test is restated against the mint contract. Its §5.9-
                                      5.11 get a banner saying so.
    either way                        §17's addressed store and the RID work sit downstream
                                      and should not start until this lands - the trim list
                                      IS part of what an address has to carry.

---

# DRAINED

_Nothing yet. An item lands here with its outcome and where it was recorded, then leaves once the
records carry it._

    RI-n  <one line: what was ruled, and which records now say so>
