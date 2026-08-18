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

_Filed 2026-08-18 (§350) after the §346–§349 build leg. **RI-11..RI-14 are INDEPENDENT** — no
item's answer changes another's, so they can be taken in parallel, one heading each. Next item
takes RI-15._

---

## RI-11 · Three pane controls are positioned by hand and NOTHING verifies them

**The fact.** `object.sense`, `object.ordinal` and `object.note` are placed with literal
`SetPoint` offsets in `object.lua`. `check_rects` — the tool that exists to catch overlapping
and off-pane controls — reads `panespec.lua`, and none of the three is in it. ★ So the pane has
three controls the positional checker is structurally unable to see.

**How it surfaced.** G1's note row was first placed at `-252`, which is `hint`'s own fixed point.
A child's hint is usually the empty string, so the two would have collided ONLY while
armed-for-pick or mid-drag — correct almost always, garbled at the two moments an author is
busiest. I found it by reading the offsets, not by running anything. ⚠ `check_rects` also still
reports against **a 240x330 pane**; the pane has been 600 tall since §104.

**Options**

    a  BRING THEM IN - declare the three in panespec and let the engine place them.
       cost: panespec has no zone for a note row; the note is neither identity, behaviour,
       stage nor children. A new zone is 39px of chrome (§ the merge that saved it).
    b  EXTEND THE CHECKER - have check_rects read literal SetPoints out of object.lua
       alongside panespec. cost: a source scanner over positioning code, and it is the
       class of tool that goes quietly stale (see A9.2, ten dead anchors).
    c  ACCEPT AND SAY SO - leave them hand-placed, and make check_rects NAME the controls
       it cannot see rather than reporting a clean pane. cost: no verification, but the
       silence stops reading as coverage.
    d  FIX THE STALE PANE SIZE ONLY - orthogonal to a/b/c and true regardless: 240x330
       is wrong and every check_rects result is computed against it.

**Bench read (overturnable in one word):** **c + d.** ★ The reason is the machine principle
rather than laziness — (a) invents a layout zone to satisfy a tool, and (b) builds a second
source scanner whose staleness is the exact failure A9.2 is currently demonstrating. A checker
that says *"3 controls not verified"* is honest and costs nothing. (d) is not optional either
way: a positional checker with the wrong canvas is worse than none.

    IMPACT
      on disk now      addons/COA_DungeonRun/panespec.lua · addons/tools/smoke/check_rects.lua
                       · object.lua (only under (a))
      shipped guards   check_rects currently reports "no overlaps" for object - under (c) or
                       (d) that sentence changes meaning, and under (d) it may go RED on
                       controls that were always outside the real pane
      criteria         none names pane geometry today; a new A-row may be owed
      does nothing to  routes.lua, the store, the registry (105/105 unaffected)

---

## RI-12 · Half of A4.2's test cannot run, because export does not exist

**The fact.** A4.2's drained criterion ends: *"export → route notes travel, personal notes on the
same map do not (mutation: route the export through the personal plane → the travel assert must
fail)."* **There is no export function in the addon.** The named mutation has nothing to mutate.

**What stands in its place today.** The two planes are asserted to be **two tables**
(`Store.RouteNoteTable() ~= Store.NoteTable()`), which is the shape RI-10 chose precisely so that
export cannot become a filter somebody has to remember. That is a structural guarantee, not a
behavioural one.

**Options**

    a  LEAVE A4.2 CLOSED, carry the travel assert as OWED against whenever export lands.
    b  RE-OPEN A4.2 to "closed except the travel half" so the roster's covered count stops
       claiming a criterion it only half tests.
    c  BUILD A MINIMAL EXPORT NOW to make the assert runnable, ahead of its place in the
       order. cost: export is a real feature with the mint-contract/round-trip law over it
       (RI-4), and it is not in the standing order at all.

**Bench read (overturnable):** **a.** ★ But said out loud rather than left comfortable: the
roster prints "A4.1–A4.3 covered", and one of those three is covered by a structural stand-in.
I flagged it in §347 and in the standing order rather than in a silence, and (b) is a
one-character change if the designer would rather the count told the truth.

    IMPACT
      on disk now      addons/planning/driver_authoring_acceptance.md (A4.2's row) ·
                       smoke_dungeonrunroutes.lua's SLOTS table (under b)
      shipped guards   none break under (a) or (b); (c) opens the mint contract
      criteria         A4.2 · and whatever export's own row becomes
      does nothing to  the built model - G1 is complete on every half that has a surface

---

## RI-13 · "Personal note" is an adaptor row with no string behind it

**The fact.** RI-10 de-conflated two things that shared the word `note`. The ROUTE side landed
§346 — the pane says **"Route instructions"** with ghost *"Instructions for the player running
the route"*. ★ The PERSONAL side still says **"note"** everywhere it appears, because personal
notes had no pane work in this leg. So the de-conflation is half-applied, and the half that is
still ambiguous is the one an author meets first (the map plane, §60/§61).

I filed the adaptor row as **`note` (personal) → "Personal note" — §346, OWED**, so the checker
counts it rather than letting it pass silently.

**Options**

    a  RELABEL NOW - it is a string change in the promoter and the map plane, no model change.
    b  WAIT for the personal-note work in model §4b, and relabel with it.
    c  RULE THAT IT NEEDS NO PREFIX - "note" alone is correct for the personal one BECAUSE it
       is the default kind, and only the travelling kind needs qualifying.

**Bench read (overturnable):** **a**, weakly held. ⚠ And I want to mark WHY it is weak: (c) is a
real position and it is the designer's to take, not mine — RI-10's ruling was that `note` alone
*"reads as a dev-note slot on first read"*, which argues against (c), but that sentence was
written about the ROUTE kind and I should not extend it to the personal kind by myself.

    IMPACT
      on disk now      promoter.lua · map.lua strings · driver_adaptor_table.md (the OWED row)
      shipped guards   check_interface counts the OWED row today; under (a) or (c) it comes off
      criteria         A5.x (the adaptor) - no new row needed either way
      does nothing to  the two tables, the keys, the export question (RI-12)

---

## RI-14 · A retired trap moved from code into a comment, and nothing guards it

**The fact.** A1.1 (§349) removed the branch inside `ReachOf` that resolved a beacon through
`AcceptanceOf`. That branch was deliberately written as an `if`, because the tidy one-liner

    local p = (x.kind == "beacon") and Routes.AcceptanceOf(x) or x

yields `x` when acceptance is nil — so a half-authored stage (children present, none flagged)
falls through to the beacon and **reads as runnable**. The branch is gone; **the trap is not.**
Any call site that writes `ReachOf(AcceptanceOf(b) or b)` reintroduces it exactly, and there is
now no code in `routes.lua` to mutate, so the mutation was RETIRED rather than reworded.

★ The trap moved from one guarded place to every future call site, and there is exactly one call
site today (`object.lua`'s ratchet tell), which is why this is cheap to decide NOW and expensive
later.

**Options**

    a  A HEADSTONE ONLY - the comment in routes.lua, as it stands. Costs nothing, guards nothing.
    b  A NAMED COMPOSER - `Routes.AcceptanceReachOf(b)` that does the composition once, so
       call sites cannot spell it wrong. cost: a second `<Noun>Of`-adjacent name, and N5's
       rule is what motivated A1.1 in the first place - this must not smuggle the selection
       rule back into routes.lua under a new name.
    c  A CHECKER RULE - fail on the literal `AcceptanceOf(` followed by ` or ` in any call.
       cost: a source-text rule, cheap and narrow, and it can only catch the spelling it names.
    d  ACCEPT - one call site, and the smoke asserts nil-acceptance reads nil.

**Bench read (overturnable):** **a + c.** ⚠ I am flagging this rather than building it because
(b) is the tempting one and it is the one that could quietly undo A1.1: a composer function in
`routes.lua` is the resolving branch again, wearing a different name. That judgement is worth a
second pair of eyes precisely because I am the one who just removed it.

    IMPACT
      on disk now      routes.lua (headstone already in) · addons/tools/check_interface.py
                       or a new rule file (under c) · object.lua (under b)
      shipped guards   the retired mutation "the and/or trap" - it is GONE from the spec, and
                       under (b) or (c) a new one is owed
      criteria         A1.1's row - it names a pure accessor, and (b) would need it reworded
      does nothing to  the values: §349's table pins every composed and bare answer

---

# ★ STATUS FOR INSPECTION — not questions, things to check the above against

_Filed with RI-11..14 so the drain is not reading blind. Battlewrath, §344: include what they
need to inspect._

    LANDED THIS LEG
      §346  G1   route note - own table (d.routeNotes), keyed RID:BID:CID, capped 200 on BOTH
                 doors, pane "Route instructions" + ghost. A4.1/A4.2/A4.3 flipped. 7 mutations.
                 ⚠ found: a hidden EditBox keeps its text and UI.Read goes to the WIDGET, so a
                 beacon's pane reported the last child's note. Fixed; the file already carried
                 that exact warning at §238 for other controls.
      §348  A1.2 tightened - the criterion's COMPOSED form is now the one asserted; the
                 "unaffected by A1.1" claim became a swept invariant instead of prose.
      §349  A1.1 ReachOf is a PURE ACCESSOR; acceptance composes at the call site. One
                 production call site. ★ The MASKING mutation retired - it had asserted the
                 defect as correct behaviour, which is how the defect passed a review green.

    STANDING REDS - unchanged by this leg, listed so they are not re-discovered
      A9.2   ★ MEASURED 2026-08-18: an anchor sweep over all 306 mutations found 10 dead,
             EVERY ONE in `map`. map.lua has not been edited since §320. The failure mode is
             the bad one - a dead anchor still sits in the file looking like coverage.
      A9.3   `ratchet` still reaches a pane with no user word. `on-ramp` GONE with A2.6,
             `satellite` FIXED §326 - one term left of the three.
      A8.2   SetChildIcon / IconOf have no caller.
      A9.5   W7 golden is unwatched.
      A2.5   wording.
      A7.2   named in the acceptance, missing from the roster.
      naming `wire` / `updater` - flagged at §13's naming pass, not changed.

    WHAT THE BENCH DOES NEXT, needing no ruling
      A6 - the TEST DRIVE inside Dungeon Run (RI-3's home), first proof = advance on a boss
      kill alone. Nothing in RI-11..14 blocks it.

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

    RI-10 DRAINED (Battlewrath, 2026-08-18): SEPARATE SHELF — the route note plane, its own
          table under the personal one (§60); export takes it whole, never the personal plane
          (structural, no tag). WORDS: "personal note" / "route note" — "reader" rejected (a
          reader is anyone reading either, author or consumer). LABEL the author sees: "Route
          instructions" (one adaptor row: term `route note` → label "Route instructions";
          "note" reads as a dev-note slot on first read); "Personal note" stays; ghost text
          "Instructions for the player running the route". PERSONAL NOTES SCOPED (model §4b): a player using
          both addons; per-place, role/class-specific experience; shown in a DESIGNATED SLOT
          beside the route note during runs, by position; may push the tracker by explicit act,
          the route overwrites; how routes become lessons learned; off the authoring path; never
          travel. → acceptance A4.2 reworded (the Analyst's wrong-shelf owned); model §4b;
          target §4 two slots. **G1 UNBLOCKED.**

_Items above leave entirely once every record named carries them._
