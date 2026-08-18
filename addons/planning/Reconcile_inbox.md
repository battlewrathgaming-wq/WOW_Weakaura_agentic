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

_Filed 2026-08-18 (§362) from the bench's orientation before A10.2's first fold. **RI-15 and
RI-16 are INDEPENDENT.** Next item takes RI-17._

---

## RI-15 · `sense` is a CLASS, and the code has the BOSS PAIR sitting in the class's name

**Battlewrath, 2026-08-18:** *"Sense is a wider class. Boss is { bossEngaged, bossKilled }."*

**The fact.** `routes.lua:932` reads `Routes.SENSES = { "bossEngaged", "bossKilled" }` with
`Routes.SENSE_DEFAULT = "reachHere"`. So the code models sense as a **flat set of three**. The
governing docs model something else:

    RI-5's drain    `sense` = the KIND (reach here + distance · boss engaged/killed ⟨name⟩ ·
                    falling · in combat)
    model §134      STATE: in combat / not in combat · falling / landed · alive / dead
    A10.3a          "reach here · boss engaged ⟨name⟩ · boss killed ⟨name⟩ · …"  ← the ellipsis
    adaptor table   `sense` → `bossKilled` + `boss` = ONE question, the name part of the ANSWER

★ So there are **families**, not one flat list: a DISTANCE sense (reach here, carrying a
distance), an EVENT sense (boss engaged / killed, carrying a name), and STATE senses (falling /
landed · in combat · alive / dead) which are pairs of a different shape again — a state has an
ON and an OFF, which is also why WHAT I DO is DURING | WHEN OFF.

⚠ **AND RI-5's DRAIN CARRIES THE TENSION ITSELF.** It defines the wider KIND in one clause and
closes with *"`sense`'s shipped value set and the A3 block STAND."* Both readings are available:
*the class is complete at three*, or *do not disturb what is built yet*. Battlewrath's line
above says the second. **Reported, not resolved** — this is exactly the disagreement the basis
says a builder hands over.

**Why it lands NOW rather than whenever.** A10.3a's SENSE control is a dropdown over the class.
Built from `Routes.SENSES` as it stands, the author sees three options and the `…` never
arrives; built from a class, the dropdown is a shape that grows without a rework.

**Options**

    a  RENAME ONLY, NO NEW MEMBERS. `Routes.SENSES` becomes `Routes.BOSS_SENSES`, and a
       `Routes.SENSE_KINDS = { reachHere, boss, falling, inCombat }` names the class with
       `falling`/`inCombat` declared but UNIMPLEMENTED and reported as such. Cost: one rename,
       one new table, no behaviour. The author's dropdown can be built once.
    b  RENAME AND IMPLEMENT the state senses now. Cost: `falling` is NOT CAPTURED yet - the
       model says so at §142, "in-combat is captured; falling is not yet: a capture-spec item" -
       so this pulls a capture change into a UI leg.
    c  LEAVE IT. `Routes.SENSES` keeps the class's name and the boss pair, and A10.3a's dropdown
       is built over the three that exist. Cost: the name lies, and the `…` becomes a rework.

**Bench read (overturnable):** **(a)**. ⚠ Not because the class should be half-built, but
because a NAME that says `SENSES` and holds the boss pair is the same defect family as the map's
two sizes and `check_rects`'s stale canvas — **a term whose scope is wrong reads correctly right
up until someone builds on it.** (b) drags capture into a UI leg for a sense nobody has asked to
author yet; (c) is the one that costs a rework.

    IMPACT
      on disk now      routes.lua (SENSES · SenseOf · Sense · SetChildSense · ArmsWith) ·
                       object.lua's sense dropdown · driver_adaptor_table.md's sense rows ·
                       smoke_dungeonrunroutes A3 block
      shipped guards   A3.1-A3.4 all read the shipped value set; under (a) they keep passing
                       against `BOSS_SENSES` with the SAME values - a rename, not a re-rule
      criteria         A3.x wording · A10.3a's dropdown source · RI-5's closing clause
      does nothing to  the note, the ordinal, the floor, or A10.2's first fold

---

## RI-16 · A10.2b needs a runtime adaptor, and A5.1 / A5.2 are still open

**The fact.** A10.2b: *"Each folded control is an option-table entry … its label resolves
through the ADAPTOR (A5.x); pass-through shows the code term, never blank."* **There is no
runtime adaptor.** `object.lua:160` carries a private `ROLE_TEXT` table — one file's own lookup,
which is the scattered form the adaptor exists to replace. `check_interface`'s adaptor check
reads the MARKDOWN table; nothing in Lua resolves a code term to a user word at run time.

⚠ And **A5.1 / A5.2 are UNCOVERED** in `smoke_dungeonrunroutes`'s roster. So A10.2b consumes a
thing whose own criterion has not landed, and nothing sequences the two.

**Options**

    a  ADAPTOR RUNTIME FIRST, then fold. A10.2b is green on the first fold and no row is owed.
       Cost: A10.2a's stated order puts the fold first, so this is a deviation.
    b  FOLD FIRST with labels typed in `options.lua`, and A10.2b goes green when A5.1/A5.2 land.
       Cost: typing the exact strings the adaptor exists to own - and every one is a place the
       two can silently disagree later.
    c  FOLD FIRST but read the labels from the markdown table at BUILD time (a generated Lua
       table, like the FrameXML templates). Cost: a generator, and the labels stop being
       author-editable at runtime - which the adaptor may or may not want.

**Bench read (overturnable):** **(a)**, and it is a deviation from A10.2a's order so it is not
mine to take. The adaptor is small, already specified, and (b) means typing the strings the rule
exists to prevent anyone typing. ★ (c) is interesting and I flag it because it is the same move
that worked for the templates — read the source, generate, never hand-copy — but it changes what
the adaptor IS, and that is a design question rather than a build one.

    IMPACT
      on disk now      a new runtime lookup (routes.lua or its own file) · object.lua's
                       ROLE_TEXT retires into it · options.lua's folded entries
      shipped guards   A5.1/A5.2's own smoke rows go from UNCOVERED to filled under (a)
      criteria         A10.2b's "resolves through the adaptor" · A5.1 · A5.2
      does nothing to  A10.1 (green), the floor, the seating

---

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

    RI-11 DRAINED (Battlewrath, 2026-08-18): (d) NOW — the check_rects canvas is a RED, not an
          option (acceptance A9.6). a/b/c DEFERRED TO THE OVERHAUL: "argumentation over UI
          placement is out of place when we know it needs an overhaul." Until then the checker
          NAMES the three hand-placed controls as unverified (never counts them clean).
    RI-12 DRAINED (Battlewrath, 2026-08-18): (b) — A4.2 reads "closed except the travel half";
          the two-tables assert stays as the structural guard; the travel assert lives in A8.5
          when export lands. The roster's covered count tells the truth.
    RI-13 DRAINED (Battlewrath, 2026-08-18): NOT OPEN — RI-10 already ruled the label "Personal
          note"; the OWED adaptor row is implementation of a drained ruling. Relabel when the
          personal-note pane work happens; ghost text "Your note — stays with you, never
          travels." No reversal.
    RI-14 DRAINED (Battlewrath, 2026-08-18): keep the HEADSTONE in routes.lua; the acceptance
          composition lives ONCE at the CALL LAYER, outside routes.lua, swept by the smoke
          (A1.2's invariant covers every site that goes through it). No source-text scanner.
          `<Noun>Of` accessors stay pure; a composer IN routes.lua would be the branch renamed.

_Items above leave entirely once every record named carries them._
